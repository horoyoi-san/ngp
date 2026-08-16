using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class UrbanAttributeConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("MaxValue")]
        public int MaxValue { get; set; }
    }
}
