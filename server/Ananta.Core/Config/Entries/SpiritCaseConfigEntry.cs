using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class SpiritCaseConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("FightSpiritId")]
        public uint FightSpiritId { get; set; }

        [JsonPropertyName("UrbanAttribute")]
        public List<int> UrbanAttribute { get; set; } = new();
    }
}
