using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class SkillConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("SpiritSkillType")]
        public int SpiritSkillType { get; set; }

        [JsonPropertyName("ChaosSkillId")]
        public uint ChaosSkillId { get; set; }

        [JsonPropertyName("ConnectedCdSkills")]
        public List<uint> ConnectedCdSkills { get; set; } = new();
    }
}
