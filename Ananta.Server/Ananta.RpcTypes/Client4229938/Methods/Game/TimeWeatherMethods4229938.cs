using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract(Inline = true)]
internal sealed class SyncPlayerCurrentTime4229938
{
    public uint realTime;
    public uint raidDaySeconds;
    public bool fix;
    public bool isPause;
    public uint transitionSecond;
    public int reason;
    public int nodeId;
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerWeather4229938
{
    public uint weatherTypeId;
    public uint nextWeatherTypeId;
    public uint transitionSecond;
}

[UxContract(Inline = true)]
internal sealed class PassingTimeArgs4229938
{
    public uint hour;
    public uint minute;
}

[UxContract(Inline = true)]
internal sealed class GmSetTimeArgs4229938
{
    public uint hour;
    public uint minute;
    public uint transition;
}

[UxContract(Inline = true)]
internal sealed class GmFixRaidTimeArgs4229938
{
    public uint hour;
    public uint minute;
    public bool clear;
}

[UxContract]
internal sealed class PersonalTimeSetting4229938
{
    public string Label = string.Empty;
    public uint Hour;
    public uint Minute;
}

[UxContract(Inline = true)]
internal sealed class ChangePersonalTimeSettingArgs4229938
{
    public int index;
    public PersonalTimeSetting4229938? info;
}

[UxContract(Inline = true)]
internal sealed class GmSetWeatherArgs4229938
{
    public uint weatherId;
}

[UxContract(Inline = true)]
internal sealed class GmSetWeatherParamArgs4229938
{
    public uint weatherParamId;
}
