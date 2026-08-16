using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class SwitchSpiritConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("RaidId")]
        public uint RaidId { get; set; }

        [JsonPropertyName("AgentId")]
        public List<uint> AgentId { get; set; } = new();

        [JsonPropertyName("FightSpiritId")]
        public List<uint> FightSpiritId { get; set; } = new();

        [JsonPropertyName("Position")]
        public List<double> Position { get; set; } = new();

        [JsonPropertyName("LoginInvalid")]
        public bool LoginInvalid { get; set; }

        [JsonPropertyName("Weight")]
        public double Weight { get; set; }

        [JsonPropertyName("EventId")]
        public uint EventId { get; set; }

        [JsonPropertyName("VehicleId")]
        public uint VehicleId { get; set; }
    }
}
