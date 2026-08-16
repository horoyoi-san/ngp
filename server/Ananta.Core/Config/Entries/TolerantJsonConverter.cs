using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace AnantaTestGameServer.Configs
{
    public class TolerantJsonConverterFactory : JsonConverterFactory
    {
        public override bool CanConvert(Type typeToConvert) => true;

        public override JsonConverter CreateConverter(Type typeToConvert, JsonSerializerOptions options)
        {
            if (typeToConvert.IsGenericType && typeToConvert.GetGenericTypeDefinition() == typeof(List<>))
            {
                var elementType = typeToConvert.GetGenericArguments()[0];
                var converterType = typeof(TolerantListConverter<>).MakeGenericType(elementType);
                return (JsonConverter)Activator.CreateInstance(converterType)!;
            }

            if (typeToConvert == typeof(string))
                return new TolerantStringConverter();

            if (typeToConvert == typeof(int) || typeToConvert == typeof(int?))
                return new TolerantIntConverter();

            if (typeToConvert == typeof(uint) || typeToConvert == typeof(uint?))
                return new TolerantUIntConverter();

            if (typeToConvert == typeof(long) || typeToConvert == typeof(long?))
                return new TolerantLongConverter();

            if (typeToConvert == typeof(double) || typeToConvert == typeof(double?))
                return new TolerantDoubleConverter();

            if (typeToConvert == typeof(float) || typeToConvert == typeof(float?))
                return new TolerantFloatConverter();

            if (typeToConvert == typeof(bool) || typeToConvert == typeof(bool?))
                return new TolerantBoolConverter();

            return null!;
        }
    }

    public class TolerantListConverter<T> : JsonConverter<List<T>>
    {
        private static readonly Type UnderlyingType = Nullable.GetUnderlyingType(typeof(T)) ?? typeof(T);

        public override List<T> Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            var list = new List<T>();
            if (reader.TokenType != JsonTokenType.StartArray)
                return list;

            while (reader.Read())
            {
                if (reader.TokenType == JsonTokenType.EndArray)
                    break;

                var value = ReadElement(ref reader);
                if (value != null)
                    list.Add(value);
            }

            return list;
        }

        private T? ReadElement(ref Utf8JsonReader reader)
        {
            if (UnderlyingType == typeof(int))
                return (T?)(object?)ReadInt(ref reader);
            if (UnderlyingType == typeof(long))
                return (T?)(object?)ReadLong(ref reader);
            if (UnderlyingType == typeof(uint))
                return (T?)(object?)ReadUInt(ref reader);
            if (UnderlyingType == typeof(double))
                return (T?)(object?)ReadDouble(ref reader);
            if (UnderlyingType == typeof(float))
                return (T?)(object?)ReadFloat(ref reader);
            if (UnderlyingType == typeof(string))
                return (T?)(object?)ReadString(ref reader);
            if (UnderlyingType == typeof(bool))
                return (T?)(object?)ReadBool(ref reader);

            try
            {
                var elementOptions = new JsonSerializerOptions();
                var result = JsonSerializer.Deserialize<T>(ref reader, elementOptions);
                return result;
            }
            catch
            {
                reader.Skip();
                return default;
            }
        }

        private static int? ReadInt(ref Utf8JsonReader reader)
        {
            if (reader.TokenType == JsonTokenType.Number)
            {
                try { return reader.GetInt32(); } catch { reader.Skip(); return null; }
            }
            if (reader.TokenType == JsonTokenType.String)
            {
                var s = reader.GetString();
                if (int.TryParse(s, out int val)) return val;
                if (double.TryParse(s, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out double d))
                    return (int)d;
                reader.Skip(); return null;
            }
            if (reader.TokenType == JsonTokenType.True) { reader.Skip(); return 1; }
            if (reader.TokenType == JsonTokenType.False) { reader.Skip(); return 0; }
            reader.Skip(); return null;
        }

        private static long? ReadLong(ref Utf8JsonReader reader)
        {
            if (reader.TokenType == JsonTokenType.Number)
            {
                try { return reader.GetInt64(); } catch { reader.Skip(); return null; }
            }
            if (reader.TokenType == JsonTokenType.String)
            {
                var s = reader.GetString();
                if (long.TryParse(s, out long val)) return val;
                reader.Skip(); return null;
            }
            reader.Skip(); return null;
        }

        private static uint? ReadUInt(ref Utf8JsonReader reader)
        {
            if (reader.TokenType == JsonTokenType.Number)
            {
                try
                {
                    if (reader.TryGetUInt32(out uint val)) return val;
                    if (reader.TryGetInt64(out long lv) && lv >= 0) return (uint)lv;
                } catch { }
                reader.Skip(); return null;
            }
            if (reader.TokenType == JsonTokenType.String)
            {
                var s = reader.GetString();
                if (uint.TryParse(s, out uint val)) return val;
                reader.Skip(); return null;
            }
            reader.Skip(); return null;
        }

        private static double? ReadDouble(ref Utf8JsonReader reader)
        {
            if (reader.TokenType == JsonTokenType.Number)
            {
                try { return reader.GetDouble(); } catch { reader.Skip(); return null; }
            }
            if (reader.TokenType == JsonTokenType.String)
            {
                var s = reader.GetString();
                if (double.TryParse(s, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out double val))
                    return val;
                reader.Skip(); return null;
            }
            reader.Skip(); return null;
        }

        private static float? ReadFloat(ref Utf8JsonReader reader)
        {
            if (reader.TokenType == JsonTokenType.Number)
            {
                try { return reader.GetSingle(); } catch { reader.Skip(); return null; }
            }
            if (reader.TokenType == JsonTokenType.String)
            {
                var s = reader.GetString();
                if (float.TryParse(s, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out float val))
                    return val;
                reader.Skip(); return null;
            }
            reader.Skip(); return null;
        }

        private static string? ReadString(ref Utf8JsonReader reader)
        {
            if (reader.TokenType == JsonTokenType.String)
                return reader.GetString() ?? "";
            if (reader.TokenType == JsonTokenType.Number) { return reader.GetDouble().ToString(System.Globalization.CultureInfo.InvariantCulture); }
            if (reader.TokenType == JsonTokenType.True) { reader.Skip(); return "true"; }
            if (reader.TokenType == JsonTokenType.False) { reader.Skip(); return "false"; }
            if (reader.TokenType == JsonTokenType.Null) { reader.Skip(); return ""; }
            reader.Skip(); return "";
        }

        private static bool? ReadBool(ref Utf8JsonReader reader)
        {
            if (reader.TokenType == JsonTokenType.True) return true;
            if (reader.TokenType == JsonTokenType.False) return false;
            if (reader.TokenType == JsonTokenType.Number) { try { return reader.GetInt32() != 0; } catch { reader.Skip(); return null; } }
            reader.Skip(); return null;
        }

        public override void Write(Utf8JsonWriter writer, List<T> value, JsonSerializerOptions options)
        {
            writer.WriteStartArray();
            var elementOptions = new JsonSerializerOptions(options);
            elementOptions.Converters.Clear();
            foreach (var item in value)
            {
                JsonSerializer.Serialize(writer, item, elementOptions);
            }
            writer.WriteEndArray();
        }
    }

    public class TolerantStringConverter : JsonConverter<string>
    {
        public override string Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            try
            {
                if (reader.TokenType == JsonTokenType.String)
                    return reader.GetString() ?? "";
                if (reader.TokenType == JsonTokenType.Number)
                {
                    var raw = reader.GetDouble().ToString(System.Globalization.CultureInfo.InvariantCulture);
                    return raw;
                }
                if (reader.TokenType == JsonTokenType.True)
                    return "true";
                if (reader.TokenType == JsonTokenType.False)
                    return "false";
                if (reader.TokenType == JsonTokenType.Null)
                    return "";
                if (reader.TokenType == JsonTokenType.StartObject || reader.TokenType == JsonTokenType.StartArray)
                {
                    reader.Skip();
                    return "";
                }
            }
            catch
            {
                reader.Skip();
            }
            return "";
        }

        public override void Write(Utf8JsonWriter writer, string value, JsonSerializerOptions options)
        {
            writer.WriteStringValue(value);
        }
    }

    public class TolerantIntConverter : JsonConverter<int>
    {
        public override int Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            try
            {
                if (reader.TokenType == JsonTokenType.Number)
                    return reader.GetInt32();
                if (reader.TokenType == JsonTokenType.String)
                {
                    var s = reader.GetString();
                    if (int.TryParse(s, out int val))
                        return val;
                    if (double.TryParse(s, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out double d))
                        return (int)d;
                    return 0;
                }
                if (reader.TokenType == JsonTokenType.True)
                    return 1;
                if (reader.TokenType == JsonTokenType.False)
                    return 0;
            }
            catch
            {
            }
            reader.Skip();
            return 0;
        }

        public override void Write(Utf8JsonWriter writer, int value, JsonSerializerOptions options)
        {
            writer.WriteNumberValue(value);
        }
    }

    public class TolerantUIntConverter : JsonConverter<uint>
    {
        public override uint Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            try
            {
                if (reader.TokenType == JsonTokenType.Number)
                {
                    if (reader.TryGetUInt32(out uint val))
                        return val;
                    if (reader.TryGetInt64(out long lval) && lval >= 0)
                        return (uint)lval;
                    var raw = reader.GetDouble().ToString(System.Globalization.CultureInfo.InvariantCulture);
                    if (uint.TryParse(raw, out uint uv))
                        return uv;
                    return 0;
                }
                if (reader.TokenType == JsonTokenType.String)
                {
                    var s = reader.GetString();
                    if (uint.TryParse(s, out uint val))
                        return val;
                    return 0;
                }
            }
            catch
            {
            }
            reader.Skip();
            return 0;
        }

        public override void Write(Utf8JsonWriter writer, uint value, JsonSerializerOptions options)
        {
            writer.WriteNumberValue(value);
        }
    }

    public class TolerantLongConverter : JsonConverter<long>
    {
        public override long Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            try
            {
                if (reader.TokenType == JsonTokenType.Number)
                    return reader.GetInt64();
                if (reader.TokenType == JsonTokenType.String)
                {
                    var s = reader.GetString();
                    if (long.TryParse(s, out long val))
                        return val;
                    return 0;
                }
            }
            catch
            {
            }
            reader.Skip();
            return 0;
        }

        public override void Write(Utf8JsonWriter writer, long value, JsonSerializerOptions options)
        {
            writer.WriteNumberValue(value);
        }
    }

    public class TolerantDoubleConverter : JsonConverter<double>
    {
        public override double Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            try
            {
                if (reader.TokenType == JsonTokenType.Number)
                    return reader.GetDouble();
                if (reader.TokenType == JsonTokenType.String)
                {
                    var s = reader.GetString();
                    if (double.TryParse(s, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out double val))
                        return val;
                    return 0;
                }
            }
            catch
            {
            }
            reader.Skip();
            return 0;
        }

        public override void Write(Utf8JsonWriter writer, double value, JsonSerializerOptions options)
        {
            writer.WriteNumberValue(value);
        }
    }

    public class TolerantFloatConverter : JsonConverter<float>
    {
        public override float Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            try
            {
                if (reader.TokenType == JsonTokenType.Number)
                    return reader.GetSingle();
                if (reader.TokenType == JsonTokenType.String)
                {
                    var s = reader.GetString();
                    if (float.TryParse(s, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out float val))
                        return val;
                    return 0;
                }
            }
            catch
            {
            }
            reader.Skip();
            return 0;
        }

        public override void Write(Utf8JsonWriter writer, float value, JsonSerializerOptions options)
        {
            writer.WriteNumberValue(value);
        }
    }

    public class TolerantBoolConverter : JsonConverter<bool>
    {
        public override bool Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            try
            {
                if (reader.TokenType == JsonTokenType.True)
                    return true;
                if (reader.TokenType == JsonTokenType.False)
                    return false;
                if (reader.TokenType == JsonTokenType.Number)
                    return reader.GetInt32() != 0;
                if (reader.TokenType == JsonTokenType.String)
                {
                    var s = reader.GetString();
                    if (bool.TryParse(s, out bool val))
                        return val;
                    if (int.TryParse(s, out int ival))
                        return ival != 0;
                }
            }
            catch
            {
            }
            reader.Skip();
            return false;
        }

        public override void Write(Utf8JsonWriter writer, bool value, JsonSerializerOptions options)
        {
            writer.WriteBooleanValue(value);
        }
    }
}
