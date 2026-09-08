/**
 * NetEase UX RPC Protocol Codec for Node.js
 */

const MODE_INVOKE = 1;
const MODE_RETURN = 2;
const MODE_NOTIFY = 3;

const MARK_NULL = 0;
const MARK_COMMON = 255;

class BinaryWriter {
    constructor() {
        this.buffers = [];
    }

    writeByte(val) {
        const b = Buffer.alloc(1);
        b.writeUInt8(val & 0xFF, 0);
        this.buffers.push(b);
    }

    writeBoolean(val) {
        this.writeByte(val ? 1 : 0);
    }

    writeInt16(val) {
        const b = Buffer.alloc(2);
        b.writeInt16LE(val, 0);
        this.buffers.push(b);
    }

    writeUInt16(val) {
        const b = Buffer.alloc(2);
        b.writeUInt16LE(val, 0);
        this.buffers.push(b);
    }

    writeInt32(val) {
        const b = Buffer.alloc(4);
        b.writeInt32LE(val, 0);
        this.buffers.push(b);
    }

    writeUInt32(val) {
        const b = Buffer.alloc(4);
        b.writeUInt32LE(val, 0);
        this.buffers.push(b);
    }

    writeInt64(val) {
        const b = Buffer.alloc(8);
        b.writeBigInt64LE(BigInt(val), 0);
        this.buffers.push(b);
    }

    writeUInt64(val) {
        const b = Buffer.alloc(8);
        b.writeBigUInt64LE(BigInt(val), 0);
        this.buffers.push(b);
    }

    writeSingle(val) {
        const b = Buffer.alloc(4);
        b.writeFloatLE(val, 0);
        this.buffers.push(b);
    }

    writeDouble(val) {
        const b = Buffer.alloc(8);
        b.writeDoubleLE(val, 0);
        this.buffers.push(b);
    }

    write7BitEncodedInt(val) {
        let v = Number(val) >>> 0;
        const bytes = [];
        while (v >= 0x80) {
            bytes.push((v | 0x80) & 0xFF);
            v >>>= 7;
        }
        bytes.push(v & 0xFF);
        this.buffers.push(Buffer.from(bytes));
    }

    writeString(val, nullable = false) {
        if (val === null || val === undefined) {
            if (nullable) {
                this.writeByte(MARK_NULL);
            } else {
                this.write7BitEncodedInt(0);
            }
            return;
        }

        if (nullable) {
            this.writeByte(MARK_COMMON);
        }

        const strBuf = Buffer.from(String(val), "utf-8");
        this.write7BitEncodedInt(strBuf.length);
        this.buffers.push(strBuf);
    }

    getBytes() {
        return Buffer.concat(this.buffers);
    }
}

class BinaryReader {
    constructor(buffer) {
        this.buffer = buffer;
        this.offset = 0;
    }

    remaining() {
        return this.buffer.length - this.offset;
    }

    readByte() {
        const val = this.buffer.readUInt8(this.offset);
        this.offset += 1;
        return val;
    }

    readBoolean() {
        return this.readByte() !== 0;
    }

    readInt16() {
        const val = this.buffer.readInt16LE(this.offset);
        this.offset += 2;
        return val;
    }

    readUInt16() {
        const val = this.buffer.readUInt16LE(this.offset);
        this.offset += 2;
        return val;
    }

    readInt32() {
        const val = this.buffer.readInt32LE(this.offset);
        this.offset += 4;
        return val;
    }

    readUInt32() {
        const val = this.buffer.readUInt32LE(this.offset);
        this.offset += 4;
        return val;
    }

    readInt64() {
        const val = this.buffer.readBigInt64LE(this.offset);
        this.offset += 8;
        return val;
    }

    readUInt64() {
        const val = this.buffer.readBigUInt64LE(this.offset);
        this.offset += 8;
        return val;
    }

    readSingle() {
        const val = this.buffer.readFloatLE(this.offset);
        this.offset += 4;
        return val;
    }

    readDouble() {
        const val = this.buffer.readDoubleLE(this.offset);
        this.offset += 8;
        return val;
    }

    read7BitEncodedInt() {
        let count = 0;
        let shift = 0;
        while (shift < 35) {
            const b = this.readByte();
            count |= (b & 0x7F) << shift;
            shift += 7;
            if ((b & 0x80) === 0) {
                return count;
            }
        }
        throw new Error("Invalid 7-bit encoded integer");
    }

    readString(nullable = false) {
        if (nullable) {
            const mark = this.readByte();
            if (mark === MARK_NULL) return null;
        }

        const len = this.read7BitEncodedInt();
        if (len === 0) return "";

        const str = this.buffer.toString("utf-8", this.offset, this.offset + len);
        this.offset += len;
        return str;
    }
}

class RpcPacket {
    constructor(mode, methodId, invokeId = 0, errId = 0, payload = Buffer.alloc(0)) {
        this.mode = mode;
        this.methodId = methodId;
        this.invokeId = invokeId;
        this.errId = errId;
        this.payload = payload;
    }

    encode(includeFraming = true) {
        const writer = new BinaryWriter();
        writer.writeByte(this.mode);
        writer.writeInt32(this.methodId);

        if (this.mode === MODE_INVOKE || this.mode === MODE_RETURN) {
            writer.writeInt32(this.invokeId);
        }

        if (this.mode === MODE_RETURN) {
            writer.writeInt32(this.errId);
        }

        if (this.payload && this.payload.length > 0) {
            writer.buffers.push(this.payload);
        }

        const body = writer.getBytes();
        if (!includeFraming) return body;

        const header = Buffer.alloc(4);
        header.writeUInt32LE(body.length, 0);
        return Buffer.concat([header, body]);
    }

    static decode(buffer) {
        if (buffer.length < 5) throw new Error(`Packet too short: ${buffer.length}`);

        const mode = buffer.readUInt8(0);
        const methodId = buffer.readInt32LE(1);
        let offset = 5;
        let invokeId = 0;
        let errId = 0;

        if (mode === MODE_INVOKE || mode === MODE_RETURN) {
            invokeId = buffer.readInt32LE(offset);
            offset += 4;
        }

        if (mode === MODE_RETURN) {
            errId = buffer.readInt32LE(offset);
            offset += 4;
        }

        const payload = buffer.subarray(offset);
        return new RpcPacket(mode, methodId, invokeId, errId, payload);
    }
}

module.exports = {
    MODE_INVOKE,
    MODE_RETURN,
    MODE_NOTIFY,
    MARK_NULL,
    MARK_COMMON,
    BinaryWriter,
    BinaryReader,
    RpcPacket,
};
