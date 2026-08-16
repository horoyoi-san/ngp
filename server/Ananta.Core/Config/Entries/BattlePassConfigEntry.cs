using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class BattlePassConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }
    }
}
