using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract(Inline = true)]
internal sealed class AskPhoneAppDownload4229938
{
    public uint appId;
}

[UxContract(Inline = true)]
internal sealed class SyncSpiritJobInfo4229938
{
    public uint spiritId;

    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, Auto.SpiritJob> spiritJobs = new();

    public uint currentJob;
}

[UxContract(Inline = true)]
internal sealed class SyncSpiritHistoryJobInfo4229938
{
    public uint spiritId;

    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, Auto.SpiritJob> historyJobs = new();
}

[UxContract(Inline = true)]
internal sealed class AskTakeJob4229938
{
    public uint jobClassId;
}

[UxContract(Inline = true)]
internal sealed class AskStartJob4229938
{
    public uint jobClassId;
}

[UxContract(Inline = true)]
internal sealed class AskQuitJob4229938
{
    public uint jobClassId;
}

[UxContract(Inline = true)]
internal sealed class AskFinishJob4229938
{
}

[UxContract(Inline = true)]
internal sealed class AskActiveSpiritJobTalentLayer4229938
{
    public uint spiritId;
    public uint jobClassId;
    public uint talentId;
    public uint addLayer;
}

[UxContract(Inline = true)]
internal sealed class AskResetSpiritJobTalent4229938
{
    public uint spiritId;
    public uint jobClassId;
}

[UxContract(Inline = true)]
internal sealed class AskConvertCommonSpiritTalentExp4229938
{
    public uint spiritId;
    public uint convertExp;
}

[UxContract(Inline = true)]
internal sealed class SyncSpiritTalentExpAndLevel4229938
{
    public uint spiritId;
    public uint addExp;
    public uint exp;
    public uint level;
}

[UxContract(Inline = true)]
internal sealed class SyncCommonSpiritTalentExp4229938
{
    public uint changeExp;
    public bool isAdd;
    public uint exp;
}

[UxContract(Inline = true)]
internal sealed class SyncActiveSpiritJobTalentLayer4229938
{
    public uint spiritId;
    public uint jobClassId;
    public uint talentId;
    public uint layer;
}

[UxContract(Inline = true)]
internal sealed class SyncSpiritJobTalentPoint4229938
{
    public uint spiritId;
    public uint jobClassId;
    public uint talentPoint;
    public int reason;
}
