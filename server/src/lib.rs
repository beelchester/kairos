use std::{net::TcpListener, str::FromStr};

use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use chrono::{DateTime, Utc};
use dotenv::dotenv;
use sqlx::{types::chrono, PgPool};
use uuid::Uuid;

mod db;

#[derive(serde::Deserialize, serde::Serialize)]
struct User {
    #[serde(rename = "userId")]
    user_id: Uuid,
    name: String,
    email: String,
    #[serde(rename = "totalTime")]
    total_time: i64,
    #[serde(rename = "createdAt")]
    created_at: DateTime<Utc>,
    #[serde(rename = "updatedAt")]
    updated_at: DateTime<Utc>,
}

impl User {
    fn new(
        user_id: Uuid,
        name: String,
        email: String,
        total_time: i64,
        created_at: DateTime<Utc>,
        updated_at: DateTime<Utc>,
    ) -> Self {
        Self {
            user_id,
            name,
            email,
            total_time,
            created_at,
            updated_at,
        }
    }
}

#[derive(serde::Deserialize, serde::Serialize)]
struct Session {
    #[serde(rename = "sessionId")]
    session_id: Uuid,
    #[serde(rename = "userId")]
    user_id: Uuid,
    #[serde(rename = "startedAt")]
    started_at: DateTime<Utc>,
    #[serde(rename = "endedAt")]
    ended_at: Option<DateTime<Utc>>,
    duration: i32,
}

impl Session {
    fn new(
        session_id: Uuid,
        user_id: Uuid,
        started_at: DateTime<Utc>,
        ended_at: Option<DateTime<Utc>>,
        duration: i32,
    ) -> Self {
        Self {
            session_id,
            user_id,
            started_at,
            ended_at,
            duration,
        }
    }
}

async fn health_check() -> impl Responder {
    HttpResponse::Ok().finish()
}

/// Signup user
async fn add_user(pool: web::Data<PgPool>, json: web::Json<User>) -> impl Responder {
    //TODO:check if user already exist
    let user = json.into_inner();
    let result = sqlx::query!(
        "INSERT INTO users (user_id, name, email, total_time, created_at, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6)",
        user.user_id,
        user.name,
        user.email,
        user.total_time,
        user.created_at,
        user.updated_at
    )
    .execute(&**pool)
    .await;

    match result {
        Ok(_) => HttpResponse::Ok().finish(),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

/// Add session for the user
async fn add_session(pool: web::Data<PgPool>, json: web::Json<Session>) -> impl Responder {
    let session = json.into_inner();
    let result = sqlx::query!(
        "INSERT INTO sessions (session_id, user_id, started_at, ended_at, duration)
         VALUES ($1, $2, $3, $4, $5)",
        session.session_id,
        session.user_id,
        session.started_at,
        session.ended_at,
        session.duration
    )
    .execute(&**pool)
    .await;

    match result {
        Ok(_) => HttpResponse::Ok().finish(),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

/// Update the session
/// To end the session
/// Or also to change the duration of the session (start/end) after the session was ended
/// but the changes after the session was ended will not update the user's focus points and total
/// focus time, it will only be reflected in the personal user stats section.
/// Max duration for any running session is set by the user.. by default 4 hours, can be set upto 6
/// hours
/// Max duration to update any past session is 4 hours
async fn update_session(pool: web::Data<PgPool>, json: web::Json<Session>) -> impl Responder {
    let session = json.into_inner();
    let result = sqlx::query!(
        "UPDATE sessions SET ended_at = $1, duration = $2
         WHERE user_id = $3 AND session_id = $4",
        session.ended_at,
        session.duration,
        session.user_id,
        session.session_id
    )
    .execute(&**pool)
    .await;

    match result {
        Ok(rows_affected) if rows_affected.rows_affected() > 0 => HttpResponse::Ok().finish(),
        _ => HttpResponse::NotFound().finish(),
    }
}

/// Check if the active session is already running on another device
/// If found it will be used for syncing purpose
async fn check_active_session(pool: web::Data<PgPool>, user_id: web::Path<Uuid>) -> impl Responder {
    let row = sqlx::query!(
        "SELECT session_id, user_id, started_at, ended_at, duration
         FROM sessions
         WHERE user_id = $1 AND ended_at IS NULL
         LIMIT 1",
        user_id.into_inner()
    )
    .fetch_optional(&**pool)
    .await;

    match row {
        Ok(Some(row)) => {
            if let Some(user_id) = row.user_id {
                let active_session = Session::new(
                    row.session_id,
                    user_id,
                    row.started_at,
                    row.ended_at,
                    row.duration,
                );
                HttpResponse::Ok().json(active_session)
            } else {
                HttpResponse::NotFound().finish()
            }
        }
        _ => HttpResponse::NotFound().finish(),
    }
}

/// Get all user sessions
async fn get_sessions(pool: web::Data<PgPool>, user_id: web::Path<Uuid>) -> impl Responder {
    let rows = sqlx::query!(
        "SELECT session_id, user_id, started_at, ended_at, duration
         FROM sessions
         WHERE user_id = $1",
        user_id.into_inner()
    )
    .fetch_all(&**pool)
    .await;

    match rows {
        Ok(rows) => {
            let sessions: Vec<Session> = rows
                .into_iter()
                .filter_map(|row| {
                    row.user_id.map(|user_id| Session {
                        session_id: row.session_id,
                        user_id,
                        started_at: row.started_at,
                        ended_at: row.ended_at,
                        duration: row.duration,
                    })
                })
                .collect();
            HttpResponse::Ok().json(sessions)
        }
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

// TODO:
/// Get all users ranked by their focus points
// async fn get_users(pool: web::Data<PgPool>) -> impl Responder {
// let rows = sqlx::query!(
//     "SELECT user_id, name, email, total_time, created_at, updated_at
//      FROM users"
// )
// .fetch_all(&**pool)
// .await;
//
// match rows {
//     Ok(users) => HttpResponse::Ok().json(users),
//     Err(_) => HttpResponse::InternalServerError().finish(),
// }
// }

async fn get_user(pool: web::Data<PgPool>, user_id: web::Path<String>) -> impl Responder {
    let uuid = Uuid::from_str(user_id.as_str());
    if let Ok(uuid) = uuid {
        let row = sqlx::query!(
            "SELECT user_id, name, email, total_time, created_at, updated_at
         FROM users
         WHERE user_id = $1",
            uuid
        )
        .fetch_optional(&**pool)
        .await;

        match row {
            Ok(Some(user)) => {
                let user = User::new(
                    user.user_id,
                    user.name,
                    user.email,
                    user.total_time,
                    user.created_at,
                    user.updated_at,
                );
                return HttpResponse::Ok().json(user);
            }
            _ => {
                return HttpResponse::NotFound().finish();
            }
        };
    }
    HttpResponse::NotFound().finish()
}

/// Delete the user and the sessions linked to the user
async fn delete_user(pool: web::Data<PgPool>, user_id: web::Path<Uuid>) -> impl Responder {
    // TODO: Delete the sessions linked as well
    let result = sqlx::query!("DELETE FROM users WHERE user_id = $1", user_id.into_inner())
        .execute(&**pool)
        .await;

    match result {
        Ok(rows_affected) if rows_affected.rows_affected() > 0 => HttpResponse::Ok().finish(),
        _ => HttpResponse::NotFound().finish(),
    }
}

/// Get today's focused duration
async fn get_todays_focus_time(
    pool: web::Data<PgPool>,
    user_id: web::Path<Uuid>,
) -> impl Responder {
    let today = chrono::Utc::now().date_naive();
    let rows = sqlx::query!(
        "SELECT session_id, user_id, started_at, ended_at, duration
         FROM sessions
         WHERE user_id = $1 AND DATE(started_at) = $2",
        user_id.into_inner(),
        today
    )
    .fetch_all(&**pool)
    .await;

    match rows {
        Ok(sessions) => {
            let mut total_duration = 0;
            sessions
                .iter()
                .for_each(|ses| total_duration += ses.duration);
            HttpResponse::Ok().json(total_duration)
        }
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

pub async fn run(listener: TcpListener) -> Result<(), std::io::Error> {
    dotenv().ok();

    let pool = db::create_pool().await;

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(pool.clone()))
            .route("/health_check", web::get().to(health_check))
            .route("/add_user", web::post().to(add_user))
            .route("/add_session", web::post().to(add_session))
            .route("/update_session", web::post().to(update_session))
            .route(
                "/check_active_session/{user_id}",
                web::get().to(check_active_session),
            )
            .route("/get_sessions/{user_id}", web::get().to(get_sessions))
            // .route("/get_users", web::get().to(get_users))
            .route("/get_user/{user_id}", web::get().to(get_user))
            .route("/delete_user/{user_id}", web::delete().to(delete_user))
            .route(
                "/get_todays_focus_time/{user_id}",
                web::get().to(get_todays_focus_time),
            )
    })
    .listen(listener)?
    .run()
    .await
}
