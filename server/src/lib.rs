use actix_cors::Cors;
use actix_web::{dev::Server, http::header, web, App, HttpResponse, HttpServer, Responder};
use lazy_static::lazy_static;
use std::{net::TcpListener, sync::Arc};
use tokio::sync::Mutex;

lazy_static! {
    static ref USERS: Arc<Mutex<Vec<User>>> = Arc::new(Mutex::new(Vec::new()));
}

#[derive(serde::Deserialize, std::fmt::Debug, serde::Serialize)]
struct User {
    #[serde(rename = "userId")]
    user_id: String,
    name: String,
    email: String,
    sessions: Option<Vec<Session>>,
}

#[derive(serde::Deserialize, std::fmt::Debug, serde::Serialize)]
struct Session {
    #[serde(rename = "sessionId")]
    session_id: String,
    #[serde(rename = "startedAt")]
    started_at: String,
    #[serde(rename = "endedAt")]
    ended_at: Option<String>,
    #[serde(rename = "duration")]
    duration: Option<String>,
}

async fn health_check() -> impl Responder {
    HttpResponse::Ok()
}

async fn add_user(json: web::Json<User>) -> impl Responder {
    let json = json.into_inner();
    let mut users = USERS.lock().await;
    users.push(User {
        user_id: json.user_id,
        name: json.name,
        email: json.email,
        sessions: json.sessions,
    });
    HttpResponse::Ok()
}

async fn add_session(user_id: web::Path<String>, json: web::Json<Session>) -> impl Responder {
    let mut users = USERS.lock().await;
    let json = json.into_inner();
    let user = users
        .iter_mut()
        .find(|user| user.user_id == user_id.clone());
    match user {
        Some(user) => match user.sessions {
            Some(ref mut sessions) => {
                sessions.push(json);
            }
            None => {
                user.sessions = Some(vec![json]);
            }
        },
        None => return HttpResponse::NotFound(),
    }
    HttpResponse::Ok()
}

async fn update_session(user_id: web::Path<String>, json: web::Json<Session>) -> impl Responder {
    let mut users = USERS.lock().await;
    let json = json.into_inner();
    let user = users
        .iter_mut()
        .find(|user| user.user_id == user_id.clone());
    match user {
        Some(user) => match user.sessions {
            Some(ref mut sessions) => {
                let session = sessions
                    .iter_mut()
                    .find(|session| session.session_id == json.session_id);
                match session {
                    Some(session) => {
                        session.ended_at = json.ended_at;
                        session.duration = json.duration;
                    }
                    None => {
                        return HttpResponse::NotFound();
                    }
                }
            }
            None => return HttpResponse::NotFound(),
        },
        None => return HttpResponse::NotFound(),
    }
    HttpResponse::Ok()
}

async fn check_active_session(user_id: web::Path<String>) -> impl Responder {
    let mut users = USERS.lock().await;
    let user = users
        .iter_mut()
        .find(|user| user.user_id == user_id.as_str());

    if let Some(user) = user {
        if let Some(sessions) = &mut user.sessions {
            if let Some(session) = sessions
                .iter_mut()
                .find(|session| session.ended_at.is_none())
            {
                HttpResponse::Ok().json(session)
            } else {
                HttpResponse::NotFound().finish()
            }
        } else {
            HttpResponse::NotFound().finish()
        }
    } else {
        HttpResponse::NotFound().finish()
    }
}

async fn get_sessions(user_id: web::Path<String>) -> impl Responder {
    let users = USERS.lock().await;
    let user = users.iter().find(|user| user.user_id == user_id.clone());
    match user {
        Some(user) => match &user.sessions {
            Some(sessions) => HttpResponse::Ok().json(sessions),
            None => HttpResponse::NotFound().finish(),
        },
        None => HttpResponse::NotFound().finish(),
    }
}

async fn get_users() -> impl Responder {
    let users = USERS.lock().await;
    HttpResponse::Ok().json(&*users)
}

async fn get_user(user_id: web::Path<String>) -> impl Responder {
    let users = USERS.lock().await;
    let user = users.iter().find(|user| user.user_id == user_id.clone());
    match user {
        Some(user) => HttpResponse::Ok().json(user),
        None => HttpResponse::NotFound().finish(),
    }
}

async fn delete_user(user_id: web::Path<String>) -> impl Responder {
    let mut users = USERS.lock().await;
    let index = users
        .iter()
        .position(|user| user.user_id == user_id.clone());
    match index {
        Some(index) => users.remove(index),
        None => return HttpResponse::NotFound(),
    };
    HttpResponse::Ok()
}

async fn get_todays_sessions(user_id: web::Path<String>) -> impl Responder {
    let users = USERS.lock().await;
    let user = users.iter().find(|user| user.user_id == user_id.clone());
    match user {
        Some(user) => match &user.sessions {
            Some(sessions) => {
                let today = chrono::offset::Utc::now().date_naive();
                let today_str = today.format("%Y-%m-%d").to_string();
                let sessions = sessions
                    .iter()
                    .filter(|session| session.started_at.starts_with(&today_str))
                    .collect::<Vec<&Session>>();
                if sessions.is_empty() {
                    return HttpResponse::NotFound().finish();
                }
                HttpResponse::Ok().json(sessions)
            }
            None => HttpResponse::NotFound().finish(),
        },
        None => HttpResponse::NotFound().finish(),
    }
}

pub fn run(listener: TcpListener) -> Result<Server, std::io::Error> {
    let server = HttpServer::new(|| {
        App::new()
            .route("/health_check", web::get().to(health_check))
            .route("/add_user", web::post().to(add_user))
            .route("/get_users", web::get().to(get_users))
            .route("/get_user/{user_id}", web::get().to(get_user))
            .route("/add_session/{user_id}", web::post().to(add_session))
            .route("/update_session/{user_id}", web::post().to(update_session))
            .route(
                "/check_active_session/{user_id}",
                web::get().to(check_active_session),
            )
            .route("/delete_user/{user_id}", web::delete().to(delete_user))
            .route("/get_sessions/{user_id}", web::get().to(get_sessions))
            .route(
                "/get_todays_sessions/{user_id}",
                web::get().to(get_todays_sessions),
            )
            .wrap(
                Cors::default()
                    .allow_any_origin()
                    .allowed_methods(vec!["GET", "POST"])
                    .allowed_headers(vec![header::AUTHORIZATION, header::ACCEPT])
                    .allowed_header(header::CONTENT_TYPE)
                    .max_age(3600),
            )
    })
    .listen(listener)?
    .run();
    Ok(server)
}
