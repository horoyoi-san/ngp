using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class SpiritTalentConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("SpiritId")]
        public uint SpiritId { get; set; }

        [JsonPropertyName("TalentId")]
        public List<uint> TalentId { get; set; } = new();
    }
}
