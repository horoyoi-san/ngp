const {
    MODE_RETURN,
    MODE_NOTIFY,
    MARK_COMMON,
    BinaryWriter,
    BinaryReader,
    RpcPacket,
} = require("../network/protocol");

const METHOD_CHECK_VERSION = 34700853;
const METHOD_CHECK_ACCOUNT = 34339919;
const METHOD_CHECK_ACCOUNT_PASS_BY = 34163006;
const METHOD_TRY_LOGIN = 34529582;
const METHOD_REQUEST_CREATE_ROLE = 34383517;
const METHOD_REQUEST_ENTER_GAME = 34566515;
const METHOD_SYNC_ROLE_LIST = 35167428;

class LoginService {
    constructor() {
        this.defaultPid = 1000000001n;
        this.defaultAid = 10001;
    }

    handleCheckVersion(packet) {
        console.log("[Node.js LoginService] CheckVersion received");
        return [
            new RpcPacket(MODE_RETURN, METHOD_CHECK_VERSION, packet.invokeId, 0)
        ];
    }

    handleCheckAccount(packet) {
        console.log("[Node.js LoginService] CheckAccount received");
        return [
            new RpcPacket(MODE_RETURN, METHOD_CHECK_ACCOUNT, packet.invokeId, 0)
        ];
    }

    handleCheckAccountPassBy(packet) {
        console.log("[Node.js LoginService] CheckAccountPassBy received");
        return [
            new RpcPacket(MODE_RETURN, METHOD_CHECK_ACCOUNT_PASS_BY, packet.invokeId, 0)
        ];
    }

    handleTryLogin(packet) {
        console.log(`[Node.js LoginService] TryLogin -> SyncRoleList pid=${this.defaultPid}`);
        const responses = [];

        // 1. Return response (errId = 0)
        responses.push(new RpcPacket(MODE_RETURN, METHOD_TRY_LOGIN, packet.invokeId, 0));

        // 2. Server Push: SyncRoleList (35167428) -> pid (uint64)
        const writer = new BinaryWriter();
        writer.writeUInt64(this.defaultPid);
        responses.push(new RpcPacket(MODE_NOTIFY, METHOD_SYNC_ROLE_LIST, 0, 0, writer.getBytes()));

        return responses;
    }

    handleRequestCreateRole(packet) {
        console.log(`[Node.js LoginService] RequestCreateRole -> pid=${this.defaultPid}`);
        const writer = new BinaryWriter();
        writer.writeUInt64(this.defaultPid);
        return [
            new RpcPacket(MODE_RETURN, METHOD_REQUEST_CREATE_ROLE, packet.invokeId, 0, writer.getBytes())
        ];
    }

    handleRequestEnterGame(packet, host = "127.0.0.1", port = 8888) {
        console.log(`[Node.js LoginService] RequestEnterGame -> gate ${host}:${port}`);
        const writer = new BinaryWriter();

        // Auto.Reader[580]:
        writer.writeInt32(this.defaultAid);
        writer.writeUInt64(this.defaultPid);

        // Auto.Reader[1573]:
        writer.writeByte(MARK_COMMON);
        writer.writeInt32(this.defaultAid);
        writer.writeUInt64(this.defaultPid);
        writer.writeString(host);
        writer.writeInt32(port);
        writer.writeString("token_nodejs");
        writer.writeInt32(1); // GateServerId
        writer.writeString("Player");

        return [
            new RpcPacket(MODE_RETURN, METHOD_REQUEST_ENTER_GAME, packet.invokeId, 0, writer.getBytes())
        ];
    }
}

module.exports = {
    LoginService,
    METHOD_CHECK_VERSION,
    METHOD_CHECK_ACCOUNT,
    METHOD_CHECK_ACCOUNT_PASS_BY,
    METHOD_TRY_LOGIN,
    METHOD_REQUEST_CREATE_ROLE,
    METHOD_REQUEST_ENTER_GAME,
};
