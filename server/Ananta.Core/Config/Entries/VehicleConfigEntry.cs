using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class VehicleConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("VehicleName")]
        public string VehicleName { get; set; } = "";

        [JsonPropertyName("VehicleIntro")]
        public string VehicleIntro { get; set; } = "";

        [JsonPropertyName("VehicleDesc")]
        public string VehicleDesc { get; set; } = "";

        [JsonPropertyName("VehicleControlId")]
        public int VehicleControlId { get; set; }

        [JsonPropertyName("ModuleConfigName")]
        public string ModuleConfigName { get; set; } = "";

        [JsonPropertyName("VehicleType")]
        public int VehicleType { get; set; }

        [JsonPropertyName("VehicleFxId")]
        public int VehicleFxId { get; set; }

        [JsonPropertyName("VehicleSoundId")]
        public int VehicleSoundId { get; set; }

        [JsonPropertyName("VehicleSeatNum")]
        public int VehicleSeatNum { get; set; }

        [JsonPropertyName("MaxBrokenImpulse")]
        public double MaxBrokenImpulse { get; set; }

        [JsonPropertyName("VehicleDropId")]
        public int VehicleDropId { get; set; }

        [JsonPropertyName("VehicleColor")]
        public List<uint> VehicleColor { get; set; } = new();

        [JsonPropertyName("VehicleFlag")]
        public int VehicleFlag { get; set; }

        [JsonPropertyName("VehicleQuality")]
        public int VehicleQuality { get; set; }

        [JsonPropertyName("StartVersion")]
        public string StartVersion { get; set; } = "";

        [JsonPropertyName("EndVersion")]
        public string EndVersion { get; set; } = "";

        [JsonPropertyName("ShowInPedia")]
        public bool ShowInPedia { get; set; }

        [JsonPropertyName("Order")]
        public int Order { get; set; }

        [JsonPropertyName("Brand")]
        public int Brand { get; set; }

        [JsonPropertyName("VehicleCanGet")]
        public bool VehicleCanGet { get; set; }

        [JsonPropertyName("VehicleGetway")]
        public int VehicleGetway { get; set; }

        [JsonPropertyName("VehicleCost")]
        public int VehicleCost { get; set; }

        [JsonPropertyName("VehicleCostCount")]
        public int VehicleCostCount { get; set; }

        [JsonPropertyName("VehicleAttr")]
        public int VehicleAttr { get; set; }

        [JsonPropertyName("Skills")]
        public List<long> Skills { get; set; } = new();

        [JsonPropertyName("CommonSkill")]
        public int CommonSkill { get; set; }

        [JsonPropertyName("ActiveSkill")]
        public long ActiveSkill { get; set; }

        [JsonPropertyName("IntelligentDrive")]
        public bool IntelligentDrive { get; set; }

        [JsonPropertyName("Weight")]
        public double Weight { get; set; }

        [JsonPropertyName("HeightType")]
        public int HeightType { get; set; }

        [JsonPropertyName("SVehicleFrontIconId")]
        public long SVehicleFrontIconId { get; set; }

        [JsonPropertyName("SVehicleIconId")]
        public long SVehicleIconId { get; set; }

        [JsonPropertyName("CollectionScore")]
        public int CollectionScore { get; set; }

        [JsonPropertyName("TagList")]
        public List<int> TagList { get; set; } = new();

        [JsonPropertyName("GeneralModel")]
        public string GeneralModel { get; set; } = "";

        [JsonPropertyName("VehicleSize")]
        public List<double> VehicleSize { get; set; } = new();

        [JsonPropertyName("VehicleCenterOffset")]
        public List<double> VehicleCenterOffset { get; set; } = new();

        [JsonPropertyName("License01")]
        public int License01 { get; set; }

        [JsonPropertyName("HubColorList")]
        public List<int> HubColorList { get; set; } = new();

        [JsonPropertyName("UndeformedModel")]
        public string UndeformedModel { get; set; } = "";

        [JsonPropertyName("SlightlyDeformedModel")]
        public string SlightlyDeformedModel { get; set; } = "";

        [JsonPropertyName("ModerateDeformedModel")]
        public string ModerateDeformedModel { get; set; } = "";

        [JsonPropertyName("HeavilyDeformedModel")]
        public string HeavilyDeformedModel { get; set; } = "";

        [JsonPropertyName("Country")]
        public List<int> Country { get; set; } = new();

        [JsonPropertyName("HypeLinkID")]
        public int HypeLinkID { get; set; }

        [JsonPropertyName("PediaCameraTemplate")]
        public int PediaCameraTemplate { get; set; }

        [JsonPropertyName("SVehicleBrandIcon")]
        public int SVehicleBrandIcon { get; set; }

        [JsonPropertyName("SVehicleBrandSmallIcon")]
        public int SVehicleBrandSmallIcon { get; set; }

        [JsonPropertyName("VehicleBrandPicIcon")]
        public int VehicleBrandPicIcon { get; set; }

        [JsonPropertyName("VehicleLightPic")]
        public int VehicleLightPic { get; set; }

        [JsonPropertyName("SBuyVehicleIconId")]
        public int SBuyVehicleIconId { get; set; }

        [JsonPropertyName("VehicleReplaceText")]
        public string VehicleReplaceText { get; set; } = "";

        [JsonPropertyName("CanShowWindow")]
        public bool CanShowWindow { get; set; }

        [JsonPropertyName("CameraType")]
        public string CameraType { get; set; } = "";

        [JsonPropertyName("ArtName")]
        public string ArtName { get; set; } = "";

        [JsonPropertyName("VehicleBase")]
        public int VehicleBase { get; set; }

        [JsonPropertyName("WheelNumA")]
        public int WheelNumA { get; set; }

        [JsonPropertyName("WheelSizeA")]
        public List<double> WheelSizeA { get; set; } = new();

        [JsonPropertyName("WheelModelA")]
        public List<int> WheelModelA { get; set; } = new();

        [JsonPropertyName("HubAOffset")]
        public List<double> HubAOffset { get; set; } = new();

        [JsonPropertyName("WheelNumB")]
        public int WheelNumB { get; set; }

        [JsonPropertyName("WheelSizeB")]
        public List<double> WheelSizeB { get; set; } = new();

        [JsonPropertyName("WheelModelB")]
        public List<int> WheelModelB { get; set; } = new();

        [JsonPropertyName("HubBOffset")]
        public List<double> HubBOffset { get; set; } = new();

        [JsonPropertyName("WheelNumC")]
        public int WheelNumC { get; set; }

        [JsonPropertyName("WheelSizeC")]
        public List<double> WheelSizeC { get; set; } = new();

        [JsonPropertyName("WheelModelC")]
        public List<int> WheelModelC { get; set; } = new();

        [JsonPropertyName("HubCOffset")]
        public List<double> HubCOffset { get; set; } = new();

        [JsonPropertyName("RoofModify")]
        public List<int> RoofModify { get; set; } = new();

        [JsonPropertyName("HoodList")]
        public List<int> HoodList { get; set; } = new();

        [JsonPropertyName("SpoilerList")]
        public List<int> SpoilerList { get; set; } = new();

        [JsonPropertyName("TyreOffset")]
        public List<string> TyreOffset { get; set; } = new();

        [JsonPropertyName("CarPaintList")]
        public List<int> CarPaintList { get; set; } = new();

        [JsonPropertyName("DefaultPaint")]
        public int DefaultPaint { get; set; }

        [JsonPropertyName("VehicleKit")]
        public List<int> VehicleKit { get; set; } = new();

        [JsonPropertyName("WheelModify")]
        public List<int> WheelModify { get; set; } = new();

        [JsonPropertyName("TyreModify")]
        public List<int> TyreModify { get; set; } = new();

        [JsonPropertyName("PediaModelOffset")]
        public VehiclePediaModelOffsetData? PediaModelOffset { get; set; }

        [JsonPropertyName("GeneralModelChassisBounceRate")]
        public List<VehicleModelRateData> GeneralModelChassisBounceRate { get; set; } = new();

        [JsonPropertyName("GeneralModelZoomRate")]
        public List<VehicleModelSeatRateData> GeneralModelZoomRate { get; set; } = new();

        [JsonPropertyName("GeneralModelBorrowPoint")]
        public List<VehicleModelSeatOffsetData> GeneralModelBorrowPoint { get; set; } = new();

        [JsonPropertyName("GeneralModelPoliceGuardPoint")]
        public List<VehicleModelSeatOffsetData> GeneralModelPoliceGuardPoint { get; set; } = new();

        [JsonPropertyName("__IDX__VehicleName")]
        public long IdxVehicleName { get; set; }

        [JsonPropertyName("__RAW__VehicleName")]
        public string RawVehicleName { get; set; } = "";

        [JsonPropertyName("__IDX__VehicleIntro")]
        public long IdxVehicleIntro { get; set; }

        [JsonPropertyName("__RAW__VehicleIntro")]
        public string RawVehicleIntro { get; set; } = "";

        [JsonPropertyName("__IDX__VehicleDesc")]
        public long IdxVehicleDesc { get; set; }

        [JsonPropertyName("__RAW__VehicleDesc")]
        public string RawVehicleDesc { get; set; } = "";
    }

    public class VehiclePediaModelOffsetData
    {
        [JsonPropertyName("x")]
        public double X { get; set; }

        [JsonPropertyName("y")]
        public double Y { get; set; }

        [JsonPropertyName("z")]
        public double Z { get; set; }
    }

    public class VehicleModelRateData
    {
        [JsonPropertyName("BodyType")]
        public int BodyType { get; set; }

        [JsonPropertyName("Rate")]
        public double Rate { get; set; }
    }

    public class VehicleModelSeatRateData
    {
        [JsonPropertyName("Seat")]
        public int Seat { get; set; }

        [JsonPropertyName("BodyType")]
        public int BodyType { get; set; }

        [JsonPropertyName("Rate")]
        public double Rate { get; set; }
    }

    public class VehicleModelSeatOffsetData
    {
        [JsonPropertyName("Seat")]
        public int Seat { get; set; }

        [JsonPropertyName("offsetx")]
        public double OffsetX { get; set; }

        [JsonPropertyName("offsety")]
        public double OffsetY { get; set; }

        [JsonPropertyName("offsetz")]
        public double OffsetZ { get; set; }
    }
}
