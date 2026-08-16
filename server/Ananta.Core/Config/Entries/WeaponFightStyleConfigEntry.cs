using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class WeaponFightStyleConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("FightSkillTypes")]
        public List<uint> FightSkillTypes { get; set; } = new();
    }
}
