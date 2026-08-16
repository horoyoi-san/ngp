using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class FashionConfigEntry : IConfigEntry
    {
        [JsonPropertyName("Id")]
        public uint Id { get; set; }

        [JsonPropertyName("Name")]
        public string Name { get; set; } = "";

        [JsonPropertyName("Description")]
        public string Description { get; set; } = "";

        [JsonPropertyName("BelongSpiritId")]
        public long BelongSpiritId { get; set; }

        [JsonPropertyName("Quality")]
        public int Quality { get; set; }

        [JsonPropertyName("Icon")]
        public long Icon { get; set; }

        [JsonPropertyName("Part")]
        public int Part { get; set; }

        [JsonPropertyName("Types")]
        public List<int> Types { get; set; } = new();

        [JsonPropertyName("SoundSwitch")]
        public string SoundSwitch { get; set; } = "";

        [JsonPropertyName("Gender")]
        public int Gender { get; set; }

        [JsonPropertyName("IsDefault")]
        public bool IsDefault { get; set; }

        [JsonPropertyName("IsDefaultUnderwear")]
        public bool IsDefaultUnderwear { get; set; }

        [JsonPropertyName("IsShow")]
        public bool IsShow { get; set; }

        [JsonPropertyName("IsGet")]
        public bool IsGet { get; set; }

        [JsonPropertyName("BelongBrand")]
        public long BelongBrand { get; set; }

        [JsonPropertyName("Source")]
        public int Source { get; set; }

        [JsonPropertyName("Tags")]
        public List<int> Tags { get; set; } = new();

        [JsonPropertyName("ShowInPedia")]
        public bool ShowInPedia { get; set; }

        [JsonPropertyName("CollectionScore")]
        public int CollectionScore { get; set; }

        [JsonPropertyName("StartVersion")]
        public string StartVersion { get; set; } = "";

        [JsonPropertyName("EndVersion")]
        public string EndVersion { get; set; } = "";

        [JsonPropertyName("TagList")]
        public List<int> TagList { get; set; } = new();

        [JsonPropertyName("FileName")]
        public List<string> FileName { get; set; } = new();

        [JsonPropertyName("Suffix")]
        public List<string> Suffix { get; set; } = new();

        [JsonPropertyName("EditId")]
        public int EditId { get; set; }

        [JsonPropertyName("Folder")]
        public string Folder { get; set; } = "";

        [JsonPropertyName("BottomSize")]
        public int BottomSize { get; set; }

        [JsonPropertyName("DefaultHidePart")]
        public int DefaultHidePart { get; set; }

        [JsonPropertyName("SelectableHiddenPart")]
        public int SelectableHiddenPart { get; set; }

        [JsonPropertyName("sBottom")]
        public bool SBottom { get; set; }

        [JsonPropertyName("FashionConsumableIcon")]
        public long FashionConsumableIcon { get; set; }

        [JsonPropertyName("PropsSoundSwitch")]
        public string PropsSoundSwitch { get; set; } = "";

        [JsonPropertyName("Coloring")]
        public List<int> Coloring { get; set; } = new();

        [JsonPropertyName("Bind")]
        public List<string> Bind { get; set; } = new();

        [JsonPropertyName("Buffs")]
        public List<long> Buffs { get; set; } = new();

        [JsonPropertyName("HypeLinkID")]
        public int HypeLinkID { get; set; }

        [JsonPropertyName("Offset")]
        public List<FashionVector3Data> Offset { get; set; } = new();

        [JsonPropertyName("Rotataion")]
        public List<FashionVector3Data> Rotataion { get; set; } = new();

        [JsonPropertyName("FootEffect")]
        public List<int> FootEffect { get; set; } = new();

        [JsonPropertyName("__IDX__Name")]
        public long IdxName { get; set; }

        [JsonPropertyName("__RAW__Name")]
        public string RawName { get; set; } = "";

        [JsonPropertyName("__IDX__Description")]
        public long IdxDescription { get; set; }

        [JsonPropertyName("__RAW__Description")]
        public string RawDescription { get; set; } = "";
    }

    public class FashionVector3Data
    {
        [JsonPropertyName("x")]
        public double X { get; set; }

        [JsonPropertyName("y")]
        public double Y { get; set; }

        [JsonPropertyName("z")]
        public double Z { get; set; }
    }
}
