"""
NetEase UX RPC Protocol Codec
Implements binary serialization and deserialization matching NetEase's UX.RPC / Lua RPC layer.
"""

import struct
from io import BytesIO
from typing import Any, List, Optional, Tuple

# Packet Modes defined in RPCCommonDefine.lua
MODE_INVOKE = 1
MODE_RETURN = 2
MODE_NOTIFY = 3

MARK_NULL = 0
MARK_COMMON = 255


class BinaryWriter:
    """Implements .NET-style BinaryWriter with 7-bit encoded integers and UX RPC primitives."""

    def __init__(self):
        self.buffer = bytearray()

    def get_bytes(self) -> bytes:
        return bytes(self.buffer)

    def write_byte(self, val: int):
        self.buffer.append(val & 0xFF)

    def write_boolean(self, val: bool):
        self.buffer.append(1 if val else 0)

    def write_int16(self, val: int):
        self.buffer.extend(struct.pack("<h", val))

    def write_uint16(self, val: int):
        self.buffer.extend(struct.pack("<H", val))

    def write_int32(self, val: int):
        self.buffer.extend(struct.pack("<i", val))

    def write_uint32(self, val: int):
        self.buffer.extend(struct.pack("<I", val))

    def write_int64(self, val: int):
        self.buffer.extend(struct.pack("<q", val))

    def write_uint64(self, val: int):
        self.buffer.extend(struct.pack("<Q", val))

    def write_single(self, val: float):
        self.buffer.extend(struct.pack("<f", val))

    def write_double(self, val: float):
        self.buffer.extend(struct.pack("<d", val))

    def write_7bit_encoded_int(self, val: int):
        v = val & 0xFFFFFFFF
        while v >= 0x80:
            self.buffer.append((v | 0x80) & 0xFF)
            v >>= 7
        self.buffer.append(v & 0xFF)

    def write_string(self, val: Optional[str], nullable: bool = False):
        if val is None:
            if nullable:
                self.write_byte(MARK_NULL)
            else:
                self.write_7bit_encoded_int(0)
            return

        if nullable:
            self.write_byte(MARK_COMMON)

        encoded = val.encode("utf-8")
        self.write_7bit_encoded_int(len(encoded))
        self.buffer.extend(encoded)

    def write_list_7bit(self, items: list, writer_func):
        self.write_7bit_encoded_int(len(items))
        for item in items:
            writer_func(self, item)


class BinaryReader:
    """Implements .NET-style BinaryReader with 7-bit encoded integers."""

    def __init__(self, data: bytes):
        self.stream = BytesIO(data)

    @property
    def remaining(self) -> int:
        pos = self.stream.tell()
        self.stream.seek(0, 2)
        end = self.stream.tell()
        self.stream.seek(pos)
        return end - pos

    def read_byte(self) -> int:
        b = self.stream.read(1)
        if not b:
            raise EOFError("Unexpected end of stream")
        return b[0]

    def read_boolean(self) -> bool:
        return self.read_byte() != 0

    def read_int16(self) -> int:
        data = self.stream.read(2)
        if len(data) < 2:
            raise EOFError("Unexpected end of stream")
        return struct.unpack("<h", data)[0]

    def read_uint16(self) -> int:
        data = self.stream.read(2)
        if len(data) < 2:
            raise EOFError("Unexpected end of stream")
        return struct.unpack("<H", data)[0]

    def read_int32(self) -> int:
        data = self.stream.read(4)
        if len(data) < 4:
            raise EOFError("Unexpected end of stream")
        return struct.unpack("<i", data)[0]

    def read_uint32(self) -> int:
        data = self.stream.read(4)
        if len(data) < 4:
            raise EOFError("Unexpected end of stream")
        return struct.unpack("<I", data)[0]

    def read_int64(self) -> int:
        data = self.stream.read(8)
        if len(data) < 8:
            raise EOFError("Unexpected end of stream")
        return struct.unpack("<q", data)[0]

    def read_uint64(self) -> int:
        data = self.stream.read(8)
        if len(data) < 8:
            raise EOFError("Unexpected end of stream")
        return struct.unpack("<Q", data)[0]

    def read_single(self) -> float:
        data = self.stream.read(4)
        if len(data) < 4:
            raise EOFError("Unexpected end of stream")
        return struct.unpack("<f", data)[0]

    def read_double(self) -> float:
        data = self.stream.read(8)
        if len(data) < 8:
            raise EOFError("Unexpected end of stream")
        return struct.unpack("<d", data)[0]

    def read_7bit_encoded_int(self) -> int:
        count = 0
        shift = 0
        while shift < 35:
            b = self.read_byte()
            count |= (b & 0x7F) << shift
            shift += 7
            if (b & 0x80) == 0:
                return count
        raise ValueError("Invalid 7-bit encoded int format")

    def read_string(self, nullable: bool = False) -> Optional[str]:
        if nullable:
            mark = self.read_byte()
            if mark == MARK_NULL:
                return None

        length = self.read_7bit_encoded_int()
        if length == 0:
            return ""
        data = self.stream.read(length)
        return data.decode("utf-8", errors="ignore")

    def read_bytes(self, length: int) -> bytes:
        return self.stream.read(length)


class RpcPacket:
    """Represents a UX RPC Packet."""

    def __init__(
        self,
        mode: int,
        method_id: int,
        invoke_id: int = 0,
        err_id: int = 0,
        payload: bytes = b"",
    ):
        self.mode = mode
        self.method_id = method_id
        self.invoke_id = invoke_id
        self.err_id = err_id
        self.payload = payload

    def encode(self, include_framing: bool = True) -> bytes:
        """Encodes packet with TCP 4-byte Int32 length prefix."""
        body = bytearray()
        body.append(self.mode & 0xFF)
        body.extend(struct.pack("<i", self.method_id))

        if self.mode in (MODE_INVOKE, MODE_RETURN):
            body.extend(struct.pack("<i", self.invoke_id))

        if self.mode == MODE_RETURN:
            body.extend(struct.pack("<i", self.err_id))

        body.extend(self.payload)

        if include_framing:
            header = struct.pack("<I", len(body))
            return header + bytes(body)
        return bytes(body)

    @classmethod
    def decode(cls, data: bytes) -> "RpcPacket":
        """Decodes raw packet data (without length prefix)."""
        if len(data) < 5:
            raise ValueError(f"Packet too short: {len(data)} bytes")

        mode = data[0]
        method_id = struct.unpack_from("<i", data, 1)[0]
        offset = 5
        invoke_id = 0
        err_id = 0

        if mode in (MODE_INVOKE, MODE_RETURN):
            if len(data) < offset + 4:
                raise ValueError("Packet truncated at invokeId")
            invoke_id = struct.unpack_from("<i", data, offset)[0]
            offset += 4

        if mode == MODE_RETURN:
            if len(data) < offset + 4:
                raise ValueError("Packet truncated at errId")
            err_id = struct.unpack_from("<i", data, offset)[0]
            offset += 4

        payload = data[offset:]
        return cls(mode, method_id, invoke_id, err_id, payload)
