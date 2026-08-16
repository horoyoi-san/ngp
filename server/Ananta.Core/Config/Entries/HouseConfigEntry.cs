using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class HouseConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("Quality")]
        public int Quality { get; set; }

        [JsonPropertyName("Location")]
        public string Location { get; set; } = "";
    }
}
