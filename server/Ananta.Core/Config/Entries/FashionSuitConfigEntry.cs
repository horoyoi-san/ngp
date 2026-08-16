using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class FashionSuitConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";
    }
}
