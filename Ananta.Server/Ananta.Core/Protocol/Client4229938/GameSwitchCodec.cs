using Ananta.SDK.Serialization;

namespace Ananta.Server.Protocol.Client4229938;

internal static class GameSwitchCodec
{
    
    private const byte ObjectMarkCommon = 0xFF;

    
    private const byte TpBoolObject = 2;

    
    internal static GameSwitchFraming ParseFraming(string? value)
        => value?.Trim().ToLowerInvariant() switch
        {
            "count7bitnomark" => GameSwitchFraming.Count7BitNoMark,
            "count7bit" => GameSwitchFraming.Count7Bit,
            "count32" => GameSwitchFraming.Count32,
            "nullterminated" => GameSwitchFraming.NullTerminated,
            "nullterminatedmarked" => GameSwitchFraming.NullTerminatedMarked,
            _ => GameSwitchFraming.Count7BitNoMark,
        };

    
    
    
    
    
    
    
    
    
    
    internal static byte[] BuildPush(
        IReadOnlyDictionary<string, bool>? overrides = null,
        GameSwitchFraming framing = GameSwitchFraming.Count7BitNoMark)
    {
        var defaults = GameSwitchCatalog.Defaults;

        
        var final = new Dictionary<string, bool>(defaults, StringComparer.Ordinal);
        if (overrides is not null)
        {
            foreach (var kv in overrides)
                final[kv.Key] = kv.Value;
        }

        var w = new UxWriter();

        
        switch (framing)
        {
            case GameSwitchFraming.Count7BitNoMark:
                w.Int7(final.Count);
                break;
            case GameSwitchFraming.Count7Bit:
                w.U8(ObjectMarkCommon);
                w.Int7(final.Count);
                break;
            case GameSwitchFraming.Count32:
                w.U8(ObjectMarkCommon);
                w.I32(final.Count);
                break;
            
        }

        var marked = framing == GameSwitchFraming.NullTerminatedMarked;

        foreach (var kv in final)
        {
            w.UxString(kv.Key);
            if (marked)
                w.U8(ObjectMarkCommon);   
            w.U8(TpBoolObject);
            w.Bool(kv.Value);
        }

        if (framing is GameSwitchFraming.NullTerminated or GameSwitchFraming.NullTerminatedMarked)
            w.U8(0x00);                   

        return w.ToArray();
    }

    
    
    
    
    
    
    
    internal static (int Bytes, int Switches, int Enabled, string Head, string Tail) Probe(
        GameSwitchFraming framing = GameSwitchFraming.Count7BitNoMark)
    {
        var body = BuildPush(framing: framing);
        var head = Convert.ToHexString(body.AsSpan(0, Math.Min(32, body.Length)));
        var tail = Convert.ToHexString(body.AsSpan(Math.Max(0, body.Length - 6)));
        return (body.Length, GameSwitchCatalog.Count, GameSwitchCatalog.EnabledCount,
            head + (body.Length > 32 ? "..." : string.Empty), tail);
    }

    
    internal static int ExpectedBytes(GameSwitchFraming framing)
    {
        var marked = framing == GameSwitchFraming.NullTerminatedMarked;
        var payload = 0;
        foreach (var kv in GameSwitchCatalog.Defaults)
        {
            var len = System.Text.Encoding.UTF8.GetByteCount(kv.Key);
            payload += VarIntLen(len + 1) + len + 1  + 1 ;
            if (marked)
                payload += 1;
        }

        return framing switch
        {
            GameSwitchFraming.Count7BitNoMark => VarIntLen(GameSwitchCatalog.Count + 1) + payload,
            GameSwitchFraming.NullTerminated or GameSwitchFraming.NullTerminatedMarked => payload + 1,
            GameSwitchFraming.Count7Bit => payload + 1 + VarIntLen(GameSwitchCatalog.Count + 1),
            _ => payload + 1 + 4,
        };
    }

    private static int VarIntLen(int value)
    {
        var n = 1;
        var v = (uint)value;
        while (v >= 0x80)
        {
            v >>= 7;
            n++;
        }
        return n;
    }
}

internal enum GameSwitchFraming
{
    
    
    
    
    
    Count7BitNoMark = 0,

    
    Count7Bit = 1,

    
    Count32 = 2,

    
    NullTerminated = 3,

    
    NullTerminatedMarked = 4,
}
