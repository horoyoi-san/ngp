using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class TaskEventConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("NextEventIds")]
        public List<uint> NextEventIds { get; set; } = new();

        [JsonPropertyName("EventName")]
        public string EventName { get; set; } = "";

        [JsonPropertyName("NewTaskInfo")]
        public string NewTaskInfo { get; set; } = "";

        [JsonPropertyName("StartTask")]
        public uint StartTask { get; set; }

        [JsonPropertyName("CenterPos")]
        public List<float> CenterPos { get; set; } = new();

        [JsonPropertyName("UrbanJob")]
        public uint UrbanJob { get; set; }
    }
}
