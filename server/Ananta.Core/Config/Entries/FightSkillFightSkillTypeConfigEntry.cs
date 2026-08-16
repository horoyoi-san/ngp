using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class FightSkillFightSkillTypeConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("SpiritId")]
        public List<uint> SpiritId { get; set; } = new();

        [JsonPropertyName("DefaultFightSkill")]
        public uint DefaultFightSkill { get; set; }
    }
}
