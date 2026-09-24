namespace Ananta.SDK.Rpc;

public enum HandlerPacketKind
{
    Both,
    Invoke,
    Notify
}

[AttributeUsage(AttributeTargets.Method, AllowMultiple = true, Inherited = false)]
public sealed class HandlerAttribute : Attribute
{
    public uint MethodId { get; }
    public HandlerPacketKind PacketKind { get; }

    public HandlerAttribute(uint methodId, HandlerPacketKind packetKind = HandlerPacketKind.Both)
    {
        MethodId = methodId;
        PacketKind = packetKind;
    }
}
