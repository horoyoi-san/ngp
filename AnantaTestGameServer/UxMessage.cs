using Google.Protobuf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer;
public enum UxMessageType : byte // TypeDefIndex: 51679
{
    Start = 0,
    S2CHandShake = 1,
    Heartbeat = 2,
    C2SHandshake = 3,
    RPCBegin = 4,
    Raw = 5,
    BroadcastClient = 6,
    BroadcastServer = 7,
    Route = 8,
    RouteWithPid = 9,
    End = 10
}
public class UxMessage
{
    public UxMessageType Type;
    public byte[] Body=new byte[0];
    protected MemoryStream _buildStream;
    protected BinaryWriter _writer;
    public UxMessage(UxMessageType type)
    {
        this.Type = type;
        _buildStream = new MemoryStream();
        _writer = new BinaryWriter(_buildStream);
    }
    public UxMessage(UxMessageType type, byte[] buff)
    {
        this.Type=type;
        this.Body=buff;
        _buildStream = new MemoryStream();
        _writer = new BinaryWriter(_buildStream);
    }
    public override string ToString()
    {
        string bodyHex = Body != null ? BitConverter.ToString(Body).Replace("-", "") : "null";
        return $"UxMessageType: {Type} Body: {bodyHex}";
    }
    public string ToHex()
    {
        string bodyHex = Body != null ? BitConverter.ToString(Body).Replace("-", "") : "null";
        return $"Body: {bodyHex}";
    }
    protected void FinalizeBuild()
    {
        Body = _buildStream.ToArray();
        _buildStream = new MemoryStream();
        _writer = new BinaryWriter(_buildStream);
    }
    public virtual void Build() { }
    public virtual void Parse() { }
    public byte[] ToBytes()
    {
        using (var ms = new MemoryStream())
        using (var bw = new BinaryWriter(ms))
        {
            bw.Write(Body.Length);
            bw.Write((byte)Type);
            bw.Write(Body);
            return ms.ToArray();
        }
    }
    protected void WriteByte(byte value)
    {
        _writer.Write(value);
    }

    protected void WriteBool(bool value)
    {
        _writer.Write(value);
    }
    protected void WriteArray(byte[] value)
    {
        _writer.Write(value.Length);
        _writer.Write(value);
    }
    protected void WriteShort(short value)
    {
        _writer.Write(value);
    }

    protected void WriteUShort(ushort value)
    {
        _writer.Write(value);
    }

    protected void WriteInt(int value)
    {
        _writer.Write(value);
    }

    protected void WriteUInt(uint value)
    {
        _writer.Write(value);
    }

    protected void WriteLong(long value)
    {
        _writer.Write(value);
    }

    protected void WriteULong(ulong value)
    {
        _writer.Write(value);
    }

    protected void WriteFloat(float value)
    {
        _writer.Write(value);
    }

    protected void WriteDouble(double value)
    {
        _writer.Write(value);
    }

    protected void WriteBytes(byte[] value)
    {
        _writer.Write(value);
    }

    protected void WriteRawBytes(byte[] value)
    {
        _writer.Write(value);
    }

    protected void WriteString(string value)
    {
        if (value == null)
        {
            _writer.Write((ushort)0);
            return;
        }

        byte[] data = Encoding.UTF8.GetBytes(value);
        _writer.Write((ushort)data.Length);
        _writer.Write(data);
    }
}
