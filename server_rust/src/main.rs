mod protocol;
mod services;

use protocol::*;
use services::*;
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::Arc;
use std::thread;

const HTTP_PORT: u16 = 8080;
const RPC_PORT: u16 = 8888;
const HOST: &str = "127.0.0.1";
const SERVER_NAME: &str = "Ananta Rust Server";

fn main() {
    println!("============================================================");
    println!("        Ananta Private Server (Rust) - Starting Up          ");
    println!("============================================================");

    let services = Arc::new(ServiceHandler::new(HOST, RPC_PORT as i32));

    // 1. Start HTTP Gateway in a background thread
    thread::spawn(|| {
        run_http_gateway(HTTP_PORT);
    });

    // 2. Start TCP UX RPC Server
    let listener = TcpListener::bind(format!("0.0.0.0:{}", RPC_PORT)).expect("Failed to bind TCP RPC port");
    println!("============================================================");
    println!("  [+] HTTP Gateway Server : http://127.0.0.1:{}", HTTP_PORT);
    println!("  [+] UX RPC Socket Server: 127.0.0.1:{} (TCP)", RPC_PORT);
    println!("  [+] Runtime             : Rust (High Performance)");
    println!("  [+] Status              : READY TO CONNECT");
    println!("============================================================");
    println!("Server running. Press Ctrl+C to exit.");

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                let services_clone = Arc::clone(&services);
                thread::spawn(move || {
                    handle_client(stream, services_clone);
                });
            }
            Err(e) => {
                eprintln!("[Rust TCP] Accept error: {}", e);
            }
        }
    }
}

fn handle_client(mut stream: TcpStream, services: Arc<ServiceHandler>) {
    let peer = stream.peer_addr().map(|p| p.to_string()).unwrap_or_default();
    println!("[Rust TCP] Client connected: {}", peer);

    let mut recv_buffer = Vec::new();
    let mut chunk = [0u8; 4096];

    loop {
        let read = match stream.read(&mut chunk) {
            Ok(0) => break,
            Ok(n) => n,
            Err(_) => break,
        };

        recv_buffer.extend_from_slice(&chunk[..read]);

        while recv_buffer.len() >= 4 {
            let length = u32::from_le_bytes(recv_buffer[..4].try_into().unwrap()) as usize;
            if length > 10 * 1024 * 1024 {
                eprintln!("[Rust TCP] Packet too large: {}", length);
                recv_buffer.clear();
                break;
            }

            if recv_buffer.len() < 4 + length {
                break;
            }

            let packet_data: Vec<u8> = recv_buffer[4..4 + length].to_vec();
            recv_buffer.drain(..4 + length);

            match RpcPacket::decode(&packet_data) {
                Ok(packet) => {
                    println!(
                        "[Rust RPC In] MethodId: {}, InvokeId: {}, Mode: {}",
                        packet.method_id, packet.invoke_id, packet.mode
                    );

                    let responses = services.handle_packet(&packet);
                    for resp in responses {
                        let encoded = resp.encode(true);
                        if let Err(e) = stream.write_all(&encoded) {
                            eprintln!("[Rust TCP] Write error: {}", e);
                            return;
                        }
                    }
                }
                Err(e) => {
                    eprintln!("[Rust TCP] Error decoding packet: {}", e);
                }
            }
        }
    }

    println!("[Rust TCP] Client {} disconnected", peer);
}

fn run_http_gateway(port: u16) {
    let listener = match TcpListener::bind(format!("0.0.0.0:{}", port)) {
        Ok(l) => l,
        Err(e) => {
            eprintln!("[Rust HTTP] Could not bind port {}: {}", port, e);
            return;
        }
    };
    println!("[Rust HttpGateway] REST API listening on http://127.0.0.1:{}", port);

    for stream in listener.incoming() {
        if let Ok(mut stream) = stream {
            let mut buf = [0u8; 2048];
            if let Ok(n) = stream.read(&mut buf) {
                let req_str = String::from_utf8_lossy(&buf[..n]);
                let first_line = req_str.lines().next().unwrap_or("");
                let path = first_line.split_whitespace().nth(1).unwrap_or("/").to_lowercase();
                println!("[Rust HTTP] {}", first_line);

                let (status, content_type, body) = if path.contains("server_list") || path.contains("gateway") {
                    (
                        "200 OK",
                        "application/json",
                        format!(
                            r#"{{
  "code": 200,
  "msg": "success",
  "servers": [
    {{
      "id": 1,
      "name": "{}",
      "ip": "{}",
      "port": {},
      "status": 0
    }}
  ]
}}"#,
                            SERVER_NAME, HOST, RPC_PORT
                        ),
                    )
                } else if path.contains("unisdk") || path.contains("login") || path.contains("auth") {
                    (
                        "200 OK",
                        "application/json",
                        r#"{
  "code": 200,
  "msg": "success",
  "aid": 10001,
  "token": "token_rust_mock",
  "uid": "1000000001",
  "user_id": "player_rust"
}"#.to_string(),
                    )
                } else {
                    (
                        "200 OK",
                        "text/html; charset=utf-8",
                        format!(
                            r#"<!DOCTYPE html>
<html>
<head><meta charset='utf-8'><title>{}</title>
<style>body{{font-family:Segoe UI,sans-serif;background:#0f172a;color:#f8fafc;padding:40px;}}
.card{{background:#1e293b;border-radius:12px;padding:24px;max-width:600px;margin:0 auto;}}
h1{{color:#38bdf8;margin-top:0;}}
.badge{{background:#22c55e;color:#000;padding:4px 10px;border-radius:99px;font-weight:bold;}}</style>
</head>
<body>
<div class='card'>
    <h1>🎮 {} (Rust)</h1>
    <p><span class='badge'>ONLINE</span> High Performance Rust Server</p>
    <p>UX RPC Socket: <b>{}:{}</b></p>
</div>
</body></html>"#,
                            SERVER_NAME, SERVER_NAME, HOST, RPC_PORT
                        ),
                    )
                };

                let response = format!(
                    "HTTP/1.1 {}\r\nContent-Type: {}\r\nAccess-Control-Allow-Origin: *\r\nContent-Length: {}\r\n\r\n{}",
                    status,
                    content_type,
                    body.as_bytes().len(),
                    body
                );
                let _ = stream.write_all(response.as_bytes());
            }
        }
    }
}
