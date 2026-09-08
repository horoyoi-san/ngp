use crate::protocol::*;
use std::time::{SystemTime, UNIX_EPOCH};

pub const METHOD_CHECK_VERSION: i32 = 34700853;
pub const METHOD_CHECK_ACCOUNT: i32 = 34339919;
pub const METHOD_CHECK_ACCOUNT_PASS_BY: i32 = 34163006;
pub const METHOD_TRY_LOGIN: i32 = 34529582;
pub const METHOD_REQUEST_CREATE_ROLE: i32 = 34383517;
pub const METHOD_REQUEST_ENTER_GAME: i32 = 34566515;
pub const METHOD_SYNC_ROLE_LIST: i32 = 35167428;
pub const METHOD_GATE_LOGIN: i32 = 52023760;
pub const METHOD_GET_SERVER_TIME: i32 = 52951195;

pub struct ServiceHandler {
    pub default_pid: u64,
    pub default_aid: i32,
    pub host: String,
    pub rpc_port: i32,
}

impl ServiceHandler {
    pub fn new(host: &str, rpc_port: i32) -> Self {
        Self {
            default_pid: 1000000001,
            default_aid: 10001,
            host: host.to_string(),
            rpc_port,
        }
    }

    pub fn handle_packet(&self, packet: &RpcPacket) -> Vec<RpcPacket> {
        match packet.method_id {
            METHOD_CHECK_VERSION => {
                println!("[Rust] CheckVersion received");
                vec![RpcPacket::new(MODE_RETURN, METHOD_CHECK_VERSION, packet.invoke_id, 0, vec![])]
            }
            METHOD_CHECK_ACCOUNT | METHOD_CHECK_ACCOUNT_PASS_BY => {
                println!("[Rust] CheckAccount received");
                vec![RpcPacket::new(MODE_RETURN, packet.method_id, packet.invoke_id, 0, vec![])]
            }
            METHOD_TRY_LOGIN => {
                println!("[Rust] TryLogin received -> sending SyncRoleList pid={}", self.default_pid);
                let mut responses = Vec::new();
                // Return packet
                responses.push(RpcPacket::new(MODE_RETURN, METHOD_TRY_LOGIN, packet.invoke_id, 0, vec![]));

                // Notify packet: SyncRoleList (pid u64)
                let mut w = BinaryWriter::new();
                w.write_uint64(self.default_pid);
                responses.push(RpcPacket::new(MODE_NOTIFY, METHOD_SYNC_ROLE_LIST, 0, 0, w.into_bytes()));
                responses
            }
            METHOD_REQUEST_CREATE_ROLE => {
                println!("[Rust] RequestCreateRole -> pid={}", self.default_pid);
                let mut w = BinaryWriter::new();
                w.write_uint64(self.default_pid);
                vec![RpcPacket::new(MODE_RETURN, METHOD_REQUEST_CREATE_ROLE, packet.invoke_id, 0, w.into_bytes())]
            }
            METHOD_REQUEST_ENTER_GAME => {
                println!("[Rust] RequestEnterGame -> gate {}:{}", self.host, self.rpc_port);
                let mut w = BinaryWriter::new();
                // Auto.Reader[580]
                w.write_int32(self.default_aid);
                w.write_uint64(self.default_pid);

                // Auto.Reader[1573]
                w.write_byte(MARK_COMMON);
                w.write_int32(self.default_aid);
                w.write_uint64(self.default_pid);
                w.write_string(&self.host, false);
                w.write_int32(self.rpc_port);
                w.write_string("token_rust", false);
                w.write_int32(1); // GateServerId
                w.write_string("Player", false);

                vec![RpcPacket::new(MODE_RETURN, METHOD_REQUEST_ENTER_GAME, packet.invoke_id, 0, w.into_bytes())]
            }
            METHOD_GATE_LOGIN => {
                println!("[Rust] Gate.Login success");
                vec![RpcPacket::new(MODE_RETURN, METHOD_GATE_LOGIN, packet.invoke_id, 0, vec![])]
            }
            METHOD_GET_SERVER_TIME => {
                let start = SystemTime::now();
                let since_epoch = start.duration_since(UNIX_EPOCH).unwrap_or_default();
                let now = since_epoch.as_secs_f64();
                let mut w = BinaryWriter::new();
                w.write_double(now);
                vec![RpcPacket::new(MODE_RETURN, METHOD_GET_SERVER_TIME, packet.invoke_id, 0, w.into_bytes())]
            }
            _ => {
                // Fallback for any other RPC
                vec![RpcPacket::new(MODE_RETURN, packet.method_id, packet.invoke_id, 0, vec![])]
            }
        }
    }
}
