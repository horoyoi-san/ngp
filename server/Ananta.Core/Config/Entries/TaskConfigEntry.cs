using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class TaskConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("WorkDescription")]
        public string WorkDescription { get; set; } = "";

        [JsonPropertyName("TaskFailGroup")]
        public string TaskFailGroup { get; set; } = "";

        [JsonPropertyName("NextTasks")]
        public List<long> NextTasks { get; set; } = new();

        [JsonPropertyName("RelatedRaid")]
        public long RelatedRaid { get; set; }

        [JsonPropertyName("Title")]
        public int Title { get; set; }

        [JsonPropertyName("Counter")]
        public List<int> Counter { get; set; } = new();

        [JsonPropertyName("EventObjective")]
        public List<string> EventObjective { get; set; } = new();

        [JsonPropertyName("IconPath")]
        public string IconPath { get; set; } = "";

        [JsonPropertyName("ImageId")]
        public int ImageId { get; set; }

        [JsonPropertyName("SImageId")]
        public int SImageId { get; set; }

        [JsonPropertyName("TaskMiniMapScale")]
        public double TaskMiniMapScale { get; set; }

        [JsonPropertyName("BlockId")]
        public int BlockId { get; set; }

        [JsonPropertyName("PlaySoundId")]
        public int PlaySoundId { get; set; }

        [JsonPropertyName("IsLimitSoundState")]
        public bool IsLimitSoundState { get; set; }

        [JsonPropertyName("SoundStateDistance")]
        public double SoundStateDistance { get; set; }

        [JsonPropertyName("Drop")]
        public int Drop { get; set; }

        [JsonPropertyName("RoleId")]
        public int RoleId { get; set; }

        [JsonPropertyName("MapEntranceBanTypes")]
        public List<int> MapEntranceBanTypes { get; set; } = new();

        [JsonPropertyName("RaidMultiMainTaskId")]
        public int RaidMultiMainTaskId { get; set; }

        [JsonPropertyName("Tags")]
        public List<int> Tags { get; set; } = new();

        [JsonPropertyName("RelatedItems")]
        public List<int> RelatedItems { get; set; } = new();

        [JsonPropertyName("SoundStateList")]
        public List<int> SoundStateList { get; set; } = new();

        [JsonPropertyName("RelatedTimeAndWeather")]
        public TimeWeatherData? RelatedTimeAndWeather { get; set; }

        [JsonPropertyName("CounterExtraInfo")]
        public List<CounterExtraInfoData> CounterExtraInfo { get; set; } = new();

        [JsonPropertyName("PanelImage")]
        public PanelImageData? PanelImage { get; set; }

        [JsonPropertyName("TimeInterval")]
        public TimeIntervalData? TimeInterval { get; set; }

        [JsonPropertyName("GIRenderPass")]
        public GIRenderPassData? GIRenderPass { get; set; }

        [JsonPropertyName("__IDX__Name")]
        public long IdxName { get; set; }

        [JsonPropertyName("__RAW__Name")]
        public string RawName { get; set; } = "";

        [JsonPropertyName("__IDX__WorkDescription")]
        public long IdxWorkDescription { get; set; }

        [JsonPropertyName("__RAW__WorkDescription")]
        public string RawWorkDescription { get; set; } = "";

        [JsonPropertyName("__IDX__EventObjective")]
        public List<long> IdxEventObjective { get; set; } = new();

        [JsonPropertyName("__RAW__EventObjective")]
        public List<string> RawEventObjective { get; set; } = new();
    }

    public class TimeWeatherData
    {
        [JsonPropertyName("timeId")]
        public int TimeId { get; set; }

        [JsonPropertyName("minutes")]
        public int Minutes { get; set; }

        [JsonPropertyName("fixCurrent")]
        public bool FixCurrent { get; set; }

        [JsonPropertyName("passing")]
        public bool Passing { get; set; }

        [JsonPropertyName("weatherId")]
        public int WeatherId { get; set; }

        [JsonPropertyName("transitionSecond")]
        public int TransitionSecond { get; set; }

        [JsonPropertyName("atmosphereName")]
        public string AtmosphereName { get; set; } = "";
    }

    public class CounterExtraInfoData
    {
        [JsonPropertyName("parent")]
        public int Parent { get; set; }

        [JsonPropertyName("duty")]
        public string Duty { get; set; } = "";

        [JsonPropertyName("waitOtherCounter")]
        public bool WaitOtherCounter { get; set; }

        [JsonPropertyName("waitOtherTask")]
        public bool WaitOtherTask { get; set; }
    }

    public class PanelImageData
    {
        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("ImageId")]
        public int ImageId { get; set; }
    }

    public class TimeIntervalData
    {
        [JsonPropertyName("startTime")]
        public int StartTime { get; set; }

        [JsonPropertyName("endTime")]
        public int EndTime { get; set; }

        [JsonPropertyName("groupName")]
        public string GroupName { get; set; } = "";
    }

    public class GIRenderPassData
    {
        [JsonPropertyName("powerFailure")]
        public bool PowerFailure { get; set; }

        [JsonPropertyName("isNightVision")]
        public bool IsNightVision { get; set; }
    }
}
