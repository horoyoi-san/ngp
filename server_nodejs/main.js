const net = require("net");
const { HttpGateway } = require("./gateway/httpGateway");
const { RpcPacket, MODE_RETURN } = require("./network/protocol");
const {
    LoginService,
    METHOD_CHECK_VERSION,
    METHOD_CHECK_ACCOUNT,
    METHOD_CHECK_ACCOUNT_PASS_BY,
    METHOD_TRY_LOGIN,
    METHOD_REQUEST_CREATE_ROLE,
    METHOD_REQUEST_ENTER_GAME,
} = require("./services/loginService");
const {
    GateService,
    METHOD_GATE_LOGIN,
    METHOD_GET_SERVER_TIME,
} = require("./services/gateService");

const HTTP_PORT = 8080;
const RPC_PORT = 8888;
const HOST = "127.0.0.1";
const SERVER_NAME = "Ananta Node.js Server";

console.log("============================================================");
console.log("      Ananta Private Server (Node.js) - Starting Up         ");
console.log("============================================================");

const loginService = new LoginService();
const gateService = new GateService();

// 1. Start HTTP Gateway
const gateway = new HttpGateway(HTTP_PORT, SERVER_NAME, HOST, RPC_PORT);
gateway.start();

// 2. Start TCP UX RPC Server
const tcpServer = net.createServer((socket) => {
    const remoteAddr = `${socket.remoteAddress}:${socket.remotePort}`;
    console.log(`[Node.js TCP] Client connected: ${remoteAddr}`);

    let recvBuffer = Buffer.alloc(0);

    socket.on("data", (chunk) => {
        recvBuffer = Buffer.concat([recvBuffer, chunk]);

        while (recvBuffer.length >= 4) {
            const packetLength = recvBuffer.readUInt32LE(0);
            if (packetLength > 10 * 1024 * 1024) {
                console.log(`[Node.js TCP] Packet length too large: ${packetLength}`);
                recvBuffer = Buffer.alloc(0);
                break;
            }

            if (recvBuffer.length < 4 + packetLength) {
                // Wait for rest of packet
                break;
            }

            const packetData = recvBuffer.subarray(4, 4 + packetLength);
            recvBuffer = recvBuffer.subarray(4 + packetLength);

            try {
                const packet = RpcPacket.decode(packetData);
                console.log(`[Node.js RPC In] MethodId: ${packet.methodId}, InvokeId: ${packet.invokeId}, Mode: ${packet.mode}`);

                let responses = [];
                switch (packet.methodId) {
                    case METHOD_CHECK_VERSION:
                        responses = loginService.handleCheckVersion(packet);
                        break;
                    case METHOD_CHECK_ACCOUNT:
                        responses = loginService.handleCheckAccount(packet);
                        break;
                    case METHOD_CHECK_ACCOUNT_PASS_BY:
                        responses = loginService.handleCheckAccountPassBy(packet);
                        break;
                    case METHOD_TRY_LOGIN:
                        responses = loginService.handleTryLogin(packet);
                        break;
                    case METHOD_REQUEST_CREATE_ROLE:
                        responses = loginService.handleRequestCreateRole(packet);
                        break;
                    case METHOD_REQUEST_ENTER_GAME:
                        responses = loginService.handleRequestEnterGame(packet, HOST, RPC_PORT);
                        break;
                    case METHOD_GATE_LOGIN:
                        responses = gateService.handleGateLogin(packet);
                        break;
                    case METHOD_GET_SERVER_TIME:
                        responses = gateService.handleGetServerTime(packet);
                        break;
                    default:
                        // Generic fallback
                        responses = [new RpcPacket(MODE_RETURN, packet.methodId, packet.invokeId, 0)];
                        break;
                }

                for (const resp of responses) {
                    socket.write(resp.encode(true));
                }
            } catch (err) {
                console.error("[Node.js TCP] Error decoding packet:", err);
            }
        }
    });

    socket.on("close", () => {
        console.log(`[Node.js TCP] Client ${remoteAddr} disconnected`);
    });

    socket.on("error", (err) => {
        console.log(`[Node.js TCP] Error from ${remoteAddr}:`, err.message);
    });
});

tcpServer.listen(RPC_PORT, () => {
    console.log("============================================================");
    console.log(`  [+] HTTP Gateway Server : http://127.0.0.1:${HTTP_PORT}`);
    console.log(`  [+] UX RPC Socket Server: 127.0.0.1:${RPC_PORT} (TCP)`);
    console.log("  [+] Runtime             : Node.js (JavaScript)");
    console.log("  [+] Status              : READY TO CONNECT");
    console.log("============================================================");
    console.log("Server running. Press Ctrl+C to exit.");
});
