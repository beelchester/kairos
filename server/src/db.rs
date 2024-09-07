use sqlx::postgres::PgPoolOptions;
use sqlx::PgPool;
use std::env;

pub async fn create_pool() -> PgPool {
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await
        .expect("Error connecting to the database")
}

// pub async fn get_client(pool: &PgPool) -> PgPool {
//     pool.clone()
// }