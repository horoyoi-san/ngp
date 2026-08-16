using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class VehicleBuffConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("BuffName")]
        public string BuffName { get; set; } = "";
    }
}
