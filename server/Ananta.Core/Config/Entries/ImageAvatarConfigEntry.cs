using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class ImageAvatarConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("ImageName")]
        public string ImageName { get; set; } = "";

        [JsonPropertyName("ImageId")]
        public uint ImageId { get; set; }
    }
}
