const {
    MODE_RETURN,
    BinaryWriter,
    RpcPacket,
} = require("../network/protocol");

const METHOD_GATE_LOGIN = 52023760;
const METHOD_GET_SERVER_TIME = 52951195;

class GateService {
    handleGateLogin(packet) {
        console.log("[Node.js GateService] Gate.Login success");
        return [
            new RpcPacket(MODE_RETURN, METHOD_GATE_LOGIN, packet.invokeId, 0)
        ];
    }

    handleGetServerTime(packet) {
        const now = Date.now() / 1000.0;
        const writer = new BinaryWriter();
        writer.writeDouble(now);
        return [
            new RpcPacket(MODE_RETURN, METHOD_GET_SERVER_TIME, packet.invokeId, 0, writer.getBytes())
        ];
    }
}

module.exports = {
    GateService,
    METHOD_GATE_LOGIN,
    METHOD_GET_SERVER_TIME,
};
