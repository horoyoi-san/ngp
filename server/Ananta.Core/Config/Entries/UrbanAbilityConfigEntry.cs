using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class UrbanAbilityConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("Description")]
        public string Description { get; set; } = "";

        [JsonPropertyName("MaxLevel")]
        public int MaxLevel { get; set; }

        [JsonPropertyName("InitBuffId")]
        public uint InitBuffId { get; set; }
    }
}
