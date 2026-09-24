using Ananta.SDK.Serialization;

namespace Ananta.Server.Protocol.Client4229938;

internal sealed record StoryClientCommand4229938(
    byte TypeMark,
    uint Nid,
    string Name,
    long RpcId,
    bool HasRpcId,
    string? PayloadKind,
    ulong? PayloadVehicleId,
    List<byte>? PayloadSeatIndices,
    bool? PayloadBool,
    long? PayloadInt,
    ulong? PayloadULong);

internal static class StoryVehicleCodec4229938
{
    internal static IReadOnlyList<StoryClientCommand4229938> Parse(ReadOnlySpan<byte> body, out bool fullyConsumed)
    {
        var commands = new List<StoryClientCommand4229938>();
        var reader = new UxReader(body.ToArray());
        fullyConsumed = false;

        try
        {
            
            if (reader.U8() == 0x00)
            {
                fullyConsumed = true;
                return commands;
            }

            int count = reader.Int7();
            for (int i = 0; i < count; i++)
            {
                byte mark = reader.U8();
                if (mark == 0x00)
                    continue;

                switch (mark)
                {
                    case 2: 
                    {
                        long confirmRpcId = reader.I64();
                        (long rpcId, bool hasRpcId) = ParseCommandBase(reader);
                        commands.Add(new StoryClientCommand4229938(2, 0, "ConfirmRpc", rpcId, hasRpcId, "Confirm", (ulong)confirmRpcId, null, null, null, null));
                        break;
                    }

                    case 4: 
                    {
                        uint nid = reader.U32();
                        string name = reader.UxStringNullable() ?? string.Empty;
                        var payload = ParsePayload(reader);
                        (long rpcId, bool hasRpcId) = ParseCommandBase(reader);
                        commands.Add(new StoryClientCommand4229938(4, nid, name, rpcId, hasRpcId,
                            payload.Kind, payload.VehicleId, payload.SeatIndices, payload.Bool, payload.Int, payload.ULong));
                        break;
                    }

                    case 5: 
                    {
                        uint nid = reader.U32();
                        string name = reader.UxStringNullable() ?? string.Empty;
                        var payload = ParsePayload(reader);
                        (long rpcId, bool hasRpcId) = ParseCommandBase(reader);
                        commands.Add(new StoryClientCommand4229938(5, nid, name, rpcId, hasRpcId,
                            payload.Kind, payload.VehicleId, payload.SeatIndices, payload.Bool, payload.Int, payload.ULong));
                        break;
                    }

                    case 3:
                    case 6: 
                    {
                        (long rpcId, bool hasRpcId) = ParseCommandBase(reader);
                        commands.Add(new StoryClientCommand4229938(mark, 0, mark == 3 ? "Rpc3" : "Rpc6", rpcId, hasRpcId, null, null, null, null, null, null));
                        break;
                    }

                    default:
                        return commands;
                }
            }

            fullyConsumed = true;
            return commands;
        }
        catch (Exception)
        {
            return commands;
        }
    }

    private static (long RpcId, bool HasRpcId) ParseCommandBase(UxReader reader)
        => (reader.I64(), reader.Bool());

    private static (string Kind, ulong? VehicleId, List<byte>? SeatIndices, bool? Bool, long? Int, ulong? ULong) ParsePayload(UxReader reader)
    {
        byte mark = reader.U8();
        switch (mark)
        {
            case 5: 
                return ("Bool", null, null, reader.Bool(), null, null);
            case 6: 
                return ("Byte", null, null, null, reader.U8(), null);
            case 12: 
                return ("Int", null, null, null, reader.I32(), null);
            case 44: 
                return ("ULong", null, null, null, null, reader.U64());
            case 35: 
            case 36: 
            {
                ulong vehicleId = reader.U64();
                List<byte>? seats = null;
                if (reader.U8() != 0x00)
                {
                    int n = reader.Int7();
                    seats = new List<byte>(n);
                    for (int i = 0; i < n; i++) seats.Add(reader.U8());
                }
                return ("S011EnterVehicleRequest", vehicleId, seats, null, null, null);
            }
            case 37: 
            {
                ulong vehicleId = reader.U64();
                byte seat = reader.U8();
                return ("S011VehicleAndSeat", vehicleId, [seat], null, null, null);
            }
            default:
                throw new InvalidDataException($"unknown StoryNetPayload type mark {mark}");
        }
    }
}
