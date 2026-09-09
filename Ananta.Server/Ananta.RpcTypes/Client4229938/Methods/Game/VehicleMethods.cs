using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

/// <summary>
/// Vehicle wire contracts for client 4229938. Signatures verified against dump.cs:
/// GmAddVehicle(uint), AskVehicleShopSpawnVehicle(uint,uint,bool)-&gt;ulong,
/// VehicleDriveStateChange(DriveState-as-byte). DriveState lua enum values are 0/1/2
/// (names obfuscated); the raw byte is preserved so live traffic reveals semantics.
/// </summary>
[UxContract(Inline = true)]
internal sealed class GmAddVehicleArgs
{
    public uint vehicleId;
}

[UxContract(Inline = true)]
internal sealed class AskVehicleShopSpawnVehicleArgs
{
    public uint shopId;
    public uint vehicleId;
    public bool isBind;
}

[UxContract(Inline = true)]
internal sealed class VehicleDriveStateChangeArgs
{
    public byte state;
}
