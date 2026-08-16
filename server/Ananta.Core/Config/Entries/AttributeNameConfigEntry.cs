using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class AttributeNameConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("AttributeName")]
        public string AttributeName { get; set; } = "";

        [JsonPropertyName("Default")]
        public double Default { get; set; }

        [JsonPropertyName("IsSpiritAttr")]
        public bool IsSpiritAttr { get; set; }
    }
}
