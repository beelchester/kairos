use std::net::TcpListener;

use kairos::run;

#[tokio::main]
async fn main() -> Result<(), std::io::Error> {
    let listener = TcpListener::bind("127.0.0.1:3333").expect("Failed to bind random port");
    println!(
        "Listening on port {}",
        listener.local_addr().unwrap().port()
    );
    run(listener)?.await
}