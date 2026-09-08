"""
TCP Connection & Session Manager
Handles async socket connections and packet framing.
"""

import asyncio
import struct
from typing import Optional, Dict, Any
from network.protocol import RpcPacket
from network.rpc_dispatcher import RpcDispatcher


class ClientSession:
    """Represents an active client TCP session."""

    def __init__(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter, address):
        self.reader = reader
        self.writer = writer
        self.address = address
        self.account_name: Optional[str] = None
        self.player: Optional[Dict[str, Any]] = None

    async def send_packet(self, packet: RpcPacket):
        data = packet.encode(include_framing=True)
        self.writer.write(data)
        await self.writer.drain()

    def close(self):
        self.writer.close()


class TcpRpcServer:
    def __init__(self, host: str, port: int, dispatcher: RpcDispatcher):
        self.host = host
        self.port = port
        self.dispatcher = dispatcher
        self.server: Optional[asyncio.AbstractServer] = None

    async def start(self):
        self.server = await asyncio.start_server(self._handle_client, self.host, self.port)
        print(f"[TcpRpcServer] UX RPC Server listening on {self.host}:{self.port}")

    async def _handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        addr = writer.get_extra_info("peername")
        print(f"[TcpRpcServer] New client connected from {addr}")
        session = ClientSession(reader, writer, addr)

        recv_buffer = bytearray()

        try:
            while True:
                data = await reader.read(4096)
                if not data:
                    break

                recv_buffer.extend(data)

                # Process all complete packets in buffer
                while len(recv_buffer) >= 4:
                    # 4-byte little-endian length prefix
                    length = struct.unpack_from("<I", recv_buffer, 0)[0]

                    # Sanity check on length
                    if length > 10 * 1024 * 1024:  # > 10MB unlikely
                        # Maybe unframed packet? Check if byte 0 is a valid packet mode (1, 2, or 3)
                        mode = recv_buffer[0]
                        if mode in (1, 2, 3) and len(recv_buffer) >= 5:
                            # Try parsing unframed
                            pkt = RpcPacket.decode(bytes(recv_buffer))
                            recv_buffer.clear()
                            await self._process_packet(pkt, session)
                            break
                        else:
                            print(f"[TcpRpcServer] Invalid packet length: {length}, resetting buffer")
                            recv_buffer.clear()
                            break

                    if len(recv_buffer) < 4 + length:
                        # Wait for remaining packet data
                        break

                    packet_data = bytes(recv_buffer[4 : 4 + length])
                    del recv_buffer[: 4 + length]

                    try:
                        pkt = RpcPacket.decode(packet_data)
                        await self._process_packet(pkt, session)
                    except Exception as e:
                        print(f"[TcpRpcServer] Error decoding packet: {e}")

        except (asyncio.IncompleteReadError, ConnectionResetError):
            pass
        except Exception as e:
            print(f"[TcpRpcServer] Connection error from {addr}: {e}")
        finally:
            print(f"[TcpRpcServer] Client {addr} disconnected")
            session.close()

    async def _process_packet(self, packet: RpcPacket, session: ClientSession):
        responses = self.dispatcher.dispatch(packet, session)
        for resp in responses:
            await session.send_packet(resp)
