using System.Text.Json;

namespace Ananta.Server.Handlers.Game;

internal static class CinemaContent
{
    
    internal sealed record Movie(
        uint Id,
        string Name,
        string Description,
        string Video,
        int Price,
        int VideoDuration,
        string Author,
        int[] Types)
    {
        internal string TypeText => Types is { Length: > 0 } ? string.Join("/", Types) : "-";
    }

    
    internal sealed record Cinema(
        uint Id,
        string Name,
        string NameLeft,
        string NameRight,
        uint Raidid,
        int CameraSets,
        int MultiMovieTimeTableId,
        uint[] Movies);

    private static readonly Lazy<IReadOnlyList<Cinema>> CinemaCache = new(LoadCinemas);
    private static readonly Lazy<IReadOnlyList<Movie>> MovieCache = new(LoadMovies);
    private static readonly Lazy<IReadOnlyDictionary<uint, string>> MovieNames = new(() =>
        MovieCache.Value.ToDictionary(m => m.Id, m => m.Name));

    internal static IReadOnlyList<Cinema> AllCinemas => CinemaCache.Value;
    internal static IReadOnlyList<Movie> AllMovies => MovieCache.Value;

    private static string ConfigPath(string file)
    {
        var path = Path.Combine(AppContext.BaseDirectory, "ClientData", "4229938", "Configs", file);
        if (File.Exists(path)) return path;

        
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        for (var i = 0; i < 6 && dir is not null; i++, dir = dir.Parent)
        {
            var cand = Path.Combine(dir.FullName, "Ananta.Server", "ClientData", "4229938", "Configs", file);
            if (File.Exists(cand)) return cand;
        }
        return path;
    }

    private static List<Dictionary<string, JsonElement>> ReadRecords(string file)
    {
        var result = new List<Dictionary<string, JsonElement>>();
        try
        {
            var path = ConfigPath(file);
            if (!File.Exists(path))
            {
                Console.WriteLine($"[CINEMA] 找不到 {file}");
                return result;
            }

            using var doc = JsonDocument.Parse(File.ReadAllBytes(path));
            if (!doc.RootElement.TryGetProperty("records", out var recs)
                || recs.ValueKind != JsonValueKind.Array)
                return result;

            foreach (var r in recs.EnumerateArray())
            {
                var d = new Dictionary<string, JsonElement>();
                foreach (var p in r.EnumerateObject()) d[p.Name] = p.Value;
                result.Add(d);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[CINEMA] 载入 {file} 失败: {ex.GetType().Name}: {ex.Message}");
        }
        return result;
    }

    private static string Str(Dictionary<string, JsonElement> d, string k)
        => d.TryGetValue(k, out var v) && v.ValueKind == JsonValueKind.String ? v.GetString() ?? "" : "";

    private static uint UInt(Dictionary<string, JsonElement> d, string k)
        => d.TryGetValue(k, out var v) && v.ValueKind == JsonValueKind.Number ? v.GetUInt32() : 0u;

    private static int Int(Dictionary<string, JsonElement> d, string k)
        => d.TryGetValue(k, out var v) && v.ValueKind == JsonValueKind.Number ? v.GetInt32() : 0;

    private static uint[] UIntArr(Dictionary<string, JsonElement> d, string k)
    {
        if (!d.TryGetValue(k, out var v) || v.ValueKind != JsonValueKind.Array) return Array.Empty<uint>();
        return v.EnumerateArray().Where(x => x.ValueKind == JsonValueKind.Number)
            .Select(x => x.GetUInt32()).ToArray();
    }

    private static int[] IntArr(Dictionary<string, JsonElement> d, string k)
    {
        if (!d.TryGetValue(k, out var v) || v.ValueKind != JsonValueKind.Array) return Array.Empty<int>();
        return v.EnumerateArray().Where(x => x.ValueKind == JsonValueKind.Number)
            .Select(x => x.GetInt32()).ToArray();
    }

    private static IReadOnlyList<Cinema> LoadCinemas()
    {
        var list = new List<Cinema>();
        foreach (var d in ReadRecords("CinemaConfig.json"))
        {
            list.Add(new Cinema(
                UInt(d, "Id"), Str(d, "Name"), Str(d, "NameLeft"), Str(d, "NameRight"),
                UInt(d, "Raidid"), Int(d, "CameraSets"), Int(d, "MultiMovieTimeTableId"),
                UIntArr(d, "Movies")));
        }
        Console.WriteLine($"[CINEMA] 载入 {list.Count} 家影院");
        return list;
    }

    private static IReadOnlyList<Movie> LoadMovies()
    {
        var list = new List<Movie>();
        foreach (var d in ReadRecords("CinemaMovieConfig.json"))
        {
            var video = d.TryGetValue("Video", out var v) && v.ValueKind == JsonValueKind.Number
                ? v.GetUInt32().ToString() : "";
            list.Add(new Movie(
                UInt(d, "Id"), Str(d, "Name"), Str(d, "Description"), video,
                Int(d, "Price"), Int(d, "VideoDuration"), Str(d, "Author"),
                IntArr(d, "type")));
        }
        Console.WriteLine($"[CINEMA] 载入 {list.Count} 部影片");
        return list;
    }

    
    internal static object Overview() => new
    {
        cinemaTotal = AllCinemas.Count,
        movieTotal = AllMovies.Count,
        note = "影院播放的是预渲染 Video（CinemaMovieConfig.Video），"
             + "不是 Timeline 实时演算。剧情播片请看 /api/story/timelines。",
        cinemas = AllCinemas.Select(c => new
        {
            c.Id,
            c.Name,
            displayName = $"{c.NameLeft} {c.NameRight}".Trim(),
            c.Raidid,
            c.CameraSets,
            c.MultiMovieTimeTableId,
            movies = c.Movies.Select(id => new
            {
                id,
                name = MovieNames.Value.TryGetValue(id, out var n) ? n : $"#{id}",
            }),
        }),
        movies = AllMovies.Select(m => new
        {
            m.Id, m.Name, m.Video, m.Price, m.VideoDuration, m.Author,
            types = m.TypeText,
            m.Description,
        }),
    };
}
