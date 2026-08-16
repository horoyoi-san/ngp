using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class FactionConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("imageId")]
        public int ImageId { get; set; }

        [JsonPropertyName("TooltipImageId")]
        public int TooltipImageId { get; set; }

        [JsonPropertyName("PlayerLockTargetType")]
        public int PlayerLockTargetType { get; set; }

        [JsonPropertyName("DispositionItem")]
        public int DispositionItem { get; set; }

        [JsonPropertyName("ShowInACDMap")]
        public bool ShowInACDMap { get; set; }

        [JsonPropertyName("MaxDispositionLevel")]
        public int MaxDispositionLevel { get; set; }

        [JsonPropertyName("FactionDescription")]
        public string FactionDescription { get; set; } = "";

        [JsonPropertyName("LevelEffectTooltip")]
        public int LevelEffectTooltip { get; set; }

        [JsonPropertyName("ChangeDescription")]
        public string ChangeDescription { get; set; } = "";

        [JsonPropertyName("LevelEffectTitle")]
        public string LevelEffectTitle { get; set; } = "";

        [JsonPropertyName("BaseCampEvent")]
        public int BaseCampEvent { get; set; }

        [JsonPropertyName("GangMapInformationPic")]
        public int GangMapInformationPic { get; set; }

        [JsonPropertyName("FactionOccupationDescription")]
        public string FactionOccupationDescription { get; set; } = "";

        [JsonPropertyName("ShowInQMSMap")]
        public bool ShowInQMSMap { get; set; }

        [JsonPropertyName("EffectName")]
        public string EffectName { get; set; } = "";

        [JsonPropertyName("EffectIcon")]
        public long EffectIcon { get; set; }

        [JsonPropertyName("worshipDescription")]
        public string WorshipDescription { get; set; } = "";

        [JsonPropertyName("friendlyDescription")]
        public string FriendlyDescription { get; set; } = "";

        [JsonPropertyName("indifferentDescription")]
        public string IndifferentDescription { get; set; } = "";

        [JsonPropertyName("hostilityDescription")]
        public string HostilityDescription { get; set; } = "";

        [JsonPropertyName("hatredDescription")]
        public string HatredDescription { get; set; } = "";

        [JsonPropertyName("InnerLineColor")]
        public string InnerLineColor { get; set; } = "";

        [JsonPropertyName("PolygonColor")]
        public string PolygonColor { get; set; } = "";

        [JsonPropertyName("CampId")]
        public List<int> CampId { get; set; } = new();

        [JsonPropertyName("LevelEffect")]
        public List<int> LevelEffect { get; set; } = new();

        [JsonPropertyName("InfluenceAreaId")]
        public List<int> InfluenceAreaId { get; set; } = new();

        [JsonPropertyName("BaseCampUnlock")]
        public List<int> BaseCampUnlock { get; set; } = new();

        [JsonPropertyName("EliteEventId")]
        public List<int> EliteEventId { get; set; } = new();

        [JsonPropertyName("Center")]
        public List<FactionVector2Data> Center { get; set; } = new();

        [JsonPropertyName("DetailDisposition")]
        public List<FactionDetailDispositionData> DetailDisposition { get; set; } = new();

        [JsonPropertyName("LevelEffectImage")]
        public List<FactionLevelEffectImageData> LevelEffectImage { get; set; } = new();

        [JsonPropertyName("DonateUnlockFan")]
        public List<DonateUnlockFanEntry> DonateUnlockFan { get; set; } = new();

        [JsonPropertyName("DispositionChangeWorldState")]
        public List<int> DispositionChangeWorldState { get; set; } = new();

        [JsonPropertyName("PersonImage")]
        public List<FactionPersonImageData> PersonImage { get; set; } = new();

        [JsonPropertyName("PersonDistribution")]
        public List<int> PersonDistribution { get; set; } = new();

        [JsonPropertyName("BaseCampLocation")]
        public List<int> BaseCampLocation { get; set; } = new();

        [JsonPropertyName("OuterLineColors")]
        public FactionColorData? OuterLineColors { get; set; }

        [JsonPropertyName("HighlightLineColors")]
        public FactionColorData? HighlightLineColors { get; set; }

        [JsonPropertyName("__IDX__name")]
        public long IdxName { get; set; }

        [JsonPropertyName("__RAW__name")]
        public string RawName { get; set; } = "";

        [JsonPropertyName("__IDX__FactionDescription")]
        public long IdxFactionDescription { get; set; }

        [JsonPropertyName("__RAW__FactionDescription")]
        public string RawFactionDescription { get; set; } = "";

        [JsonPropertyName("__IDX__ChangeDescription")]
        public long IdxChangeDescription { get; set; }

        [JsonPropertyName("__RAW__ChangeDescription")]
        public string RawChangeDescription { get; set; } = "";

        [JsonPropertyName("__IDX__LevelEffectTitle")]
        public long IdxLevelEffectTitle { get; set; }

        [JsonPropertyName("__RAW__LevelEffectTitle")]
        public string RawLevelEffectTitle { get; set; } = "";

        [JsonPropertyName("__IDX__EffectName")]
        public long IdxEffectName { get; set; }

        [JsonPropertyName("__RAW__EffectName")]
        public string RawEffectName { get; set; } = "";

        [JsonPropertyName("__IDX__worshipDescription")]
        public long IdxWorshipDescription { get; set; }

        [JsonPropertyName("__RAW__worshipDescription")]
        public string RawWorshipDescription { get; set; } = "";

        [JsonPropertyName("__IDX__friendlyDescription")]
        public long IdxFriendlyDescription { get; set; }

        [JsonPropertyName("__RAW__friendlyDescription")]
        public string RawFriendlyDescription { get; set; } = "";

        [JsonPropertyName("__IDX__indifferentDescription")]
        public long IdxIndifferentDescription { get; set; }

        [JsonPropertyName("__RAW__indifferentDescription")]
        public string RawIndifferentDescription { get; set; } = "";

        [JsonPropertyName("__IDX__hostilityDescription")]
        public long IdxHostilityDescription { get; set; }

        [JsonPropertyName("__RAW__hostilityDescription")]
        public string RawHostilityDescription { get; set; } = "";

        [JsonPropertyName("__IDX__hatredDescription")]
        public long IdxHatredDescription { get; set; }

        [JsonPropertyName("__RAW__hatredDescription")]
        public string RawHatredDescription { get; set; } = "";
    }

    public class FactionVector2Data
    {
        [JsonPropertyName("x")]
        public double X { get; set; }

        [JsonPropertyName("y")]
        public double Y { get; set; }
    }

    public class FactionDetailDispositionData
    {
        [JsonPropertyName("DispositionID")]
        public int DispositionID { get; set; }

        [JsonPropertyName("Chat")]
        public int Chat { get; set; }
    }

    public class FactionLevelEffectImageData
    {
        [JsonPropertyName("DispositionID")]
        public int DispositionID { get; set; }

        [JsonPropertyName("ImageID")]
        public int ImageID { get; set; }
    }

    public class FactionPersonImageData
    {
        [JsonPropertyName("PerfabType")]
        public int PerfabType { get; set; }

        [JsonPropertyName("EnableDisposition")]
        public int EnableDisposition { get; set; }

        [JsonPropertyName("weight")]
        public int Weight { get; set; }
    }

    public class FactionColorData
    {
        [JsonPropertyName("r")]
        public int R { get; set; }

        [JsonPropertyName("g")]
        public int G { get; set; }

        [JsonPropertyName("b")]
        public int B { get; set; }

        [JsonPropertyName("a")]
        public int A { get; set; }
    }

    public class DonateUnlockFanEntry
    {
        [JsonPropertyName("DispositonLevel")]
        public int DispositonLevel { get; set; }

        [JsonPropertyName("Fan")]
        public int Fan { get; set; }
    }
}
