using System;
using System.IO;
using System.Text;

namespace AnantaServer.Network
{
    public static class PacketModes
    {
        public const byte Invoke = 1;
        public const byte Return = 2;
        public const byte Notify = 3;

        public const byte MarkNull = 0;
        public const byte MarkCommon = 255;
    }

    public class RpcPacket
    {
        public byte Mode { get; set; }
        public int MethodId { get; set; }
        public int InvokeId { get; set; }
        public int ErrId { get; set; }
        public byte[] Payload { get; set; } = Array.Empty<byte>();

        public RpcPacket(byte mode, int methodId, int invokeId = 0, int errId = 0, byte[]? payload = null)
        {
            Mode = mode;
            MethodId = methodId;
            InvokeId = invokeId;
            ErrId = errId;
            Payload = payload ?? Array.Empty<byte>();
        }

        public byte[] Encode(bool includeFraming = true)
        {
            using var ms = new MemoryStream();
            using var bw = new BinaryWriter(ms);

            bw.Write(Mode);
            bw.Write(MethodId);

            if (Mode == PacketModes.Invoke || Mode == PacketModes.Return)
            {
                bw.Write(InvokeId);
            }

            if (Mode == PacketModes.Return)
            {
                bw.Write(ErrId);
            }

            if (Payload.Length > 0)
            {
                bw.Write(Payload);
            }

            var body = ms.ToArray();
            if (!includeFraming)
            {
                return body;
            }

            using var framed = new MemoryStream();
            using var fbw = new BinaryWriter(framed);
            fbw.Write((uint)body.Length);
            fbw.Write(body);
            return framed.ToArray();
        }

        public static RpcPacket Decode(byte[] data)
        {
            if (data.Length < 5)
                throw new ArgumentException($"Packet too short: {data.Length} bytes");

            using var ms = new MemoryStream(data);
            using var br = new BinaryReader(ms);

            byte mode = br.ReadByte();
            int methodId = br.ReadInt32();
            int invokeId = 0;
            int errId = 0;

            if (mode == PacketModes.Invoke || mode == PacketModes.Return)
            {
                invokeId = br.ReadInt32();
            }

            if (mode == PacketModes.Return)
            {
                errId = br.ReadInt32();
            }

            int remaining = (int)(ms.Length - ms.Position);
            byte[] payload = remaining > 0 ? br.ReadBytes(remaining) : Array.Empty<byte>();

            return new RpcPacket(mode, methodId, invokeId, errId, payload);
        }
    }

    public static class UxBinaryExtensions
    {
        public static void WriteUxString(this BinaryWriter writer, string? val, bool nullable = false)
        {
            if (val == null)
            {
                if (nullable)
                    writer.Write(PacketModes.MarkNull);
                else
                    writer.Write7BitEncodedInt(0);
                return;
            }

            if (nullable)
                writer.Write(PacketModes.MarkCommon);

            byte[] bytes = Encoding.UTF8.GetBytes(val);
            writer.Write7BitEncodedInt(bytes.Length);
            writer.Write(bytes);
        }

        public static string ReadUxString(this BinaryReader reader, bool nullable = false)
        {
            if (nullable)
            {
                byte mark = reader.ReadByte();
                if (mark == PacketModes.MarkNull)
                    return string.Empty;
            }

            int len = reader.Read7BitEncodedInt();
            if (len <= 0) return string.Empty;

            byte[] bytes = reader.ReadBytes(len);
            return Encoding.UTF8.GetString(bytes);
        }
    }
}
