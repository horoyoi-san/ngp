using System.Text.Json;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Handlers.Game;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;

namespace Ananta.Server.App;

internal sealed partial class DebugApiServer
{
    
    private object EnemyGroupsCatalog()
    {
        var groups = GameRouter.EnemyGroups();
        return new
        {
            ok = true,
            count = groups.Count,
            groups = groups.Take(300).Select(g => new { id = g.Id, name = g.Name, members = g.MemberCount }),
        };
    }

    
    private async Task<object> EnemyGroupSpawnAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        int groupId = 0;
        uint campId = 0;
        int members = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("groupId", out var g) && g.TryGetInt32(out var gv)) groupId = gv;
            if (root.TryGetProperty("campId", out var c) && c.TryGetUInt32(out var cv)) campId = cv;
            if (root.TryGetProperty("members", out var m) && m.TryGetInt32(out var mv)) members = mv;
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"请求解析失败: {ex.Message}" };
        }

        var message = await GameRouter.SpawnEnemyGroupAsync(session, groupId, campId, members, token);
        return new { ok = true, message };
    }

    
    private async Task<object> EnemySpawnAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint? templateId = null;
        int? count = null;
        float? distance = null;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("templateId", out var t) && t.TryGetUInt32(out var tv)) templateId = tv;
            if (root.TryGetProperty("count", out var c) && c.TryGetInt32(out var cv)) count = cv;
            if (root.TryGetProperty("distance", out var d) && d.TryGetSingle(out var dv)) distance = dv;
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"请求解析失败: {ex.Message}" };
        }

        var resolved = templateId ?? Profile.InitialSpiritTemplateId;
        var message = await GameRouter.SpawnEnemyAsync(session, resolved, count ?? 3, distance ?? 6f, token);
        return new { ok = true, message };
    }

    
    private async Task<object> NpcSpawnAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint templateId = 0;
        float distance = 4f;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("templateId", out var t) && t.TryGetUInt32(out var tv)) templateId = tv;
            if (root.TryGetProperty("distance", out var d) && d.TryGetSingle(out var dv)) distance = dv;
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"请求解析失败: {ex.Message}" };
        }

        if (templateId == 0)
            return new { ok = false, error = "缺少 templateId" };

        var message = await GameRouter.SpawnNpcNearPlayerAsync(session, templateId, distance, token);
        return new { ok = true, message };
    }

    
    private async Task<object> AmmoGiveAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint count = 999;
        uint templateId = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("count", out var c) && c.TryGetUInt32(out var cv)) count = cv;
            if (root.TryGetProperty("templateId", out var t) && t.TryGetUInt32(out var tv)) templateId = tv;
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"请求解析失败: {ex.Message}" };
        }

        var message = await GameRouter.GiveAmmoAsync(session, count, templateId, token);
        return new { ok = true, message };
    }

    
    private object AgentCatalog(System.Collections.Specialized.NameValueCollection query)
    {
        var term = query["q"];
        var limit = int.TryParse(query["limit"], out var l) ? Math.Clamp(l, 1, 500) : 100;
        bool? monsters = query["monsters"] switch
        {
            "1" or "true" => true,
            "0" or "false" => false,
            _ => null,
        };
        int? species = int.TryParse(query["species"], out var s) ? s : null;
        int? enemyClass = int.TryParse(query["enemyClass"], out var e) ? e : null;

        var hits = AgentCatalogRepository.Query(term, species, null, enemyClass, monsters, limit);
        return new
        {
            ok = true,
            total = AgentCatalogRepository.Count,
            monsterCount = AgentCatalogRepository.MonsterCount,
            returned = hits.Count,
            agents = hits.Select(a => new
            {
                id = a.Id,
                name = a.Name,
                species = a.SpeciesType,
                agentType = a.AgentType,
                enemyClass = a.EnemyClassType,
                monster = a.IsMonster,
            }),
        };
    }

    

    
    private object StreetNpcList()
        => new
        {
            ok = true,
            count = GameRouter.StreetNpcs().Count,
            npcs = GameRouter.StreetNpcs().Select(n => new
            {
                id = n.Id,
                name = n.Name,
                templateId = n.TemplateId,
                x = n.X,
                y = n.Y,
                z = n.Z,
                facing = n.Facing,
                fashions = n.FashionIds,
            }),
        };

    
    
    
    
    private async Task<object> StreetNpcPlaceAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint templateId;
        string? name = null;
        List<uint>? fashions = null;
        float? x = null, y = null, z = null, facing = null;
        float distance = 4f;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (!root.TryGetProperty("templateId", out var pt) || (templateId = pt.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 templateId" };
            if (root.TryGetProperty("name", out var pn) && pn.ValueKind == JsonValueKind.String)
                name = pn.GetString();
            if (root.TryGetProperty("distance", out var pd) && pd.TryGetSingle(out var dv)) distance = dv;
            if (root.TryGetProperty("x", out var px) && px.TryGetSingle(out var xv)) x = xv;
            if (root.TryGetProperty("y", out var py) && py.TryGetSingle(out var yv)) y = yv;
            if (root.TryGetProperty("z", out var pz) && pz.TryGetSingle(out var zv)) z = zv;
            if (root.TryGetProperty("facing", out var pf) && pf.TryGetSingle(out var fv)) facing = fv;
            if (root.TryGetProperty("fashions", out var pfs) && pfs.ValueKind == JsonValueKind.Array)
                fashions = pfs.EnumerateArray().Where(v => v.TryGetUInt32(out _)).Select(v => v.GetUInt32()).ToList();
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        string message;
        if (x is not null && y is not null && z is not null)
            message = await GameRouter.PlaceStreetNpcAsync(
                session, templateId, new Vec3(x.Value, y.Value, z.Value), facing ?? 0f, name, fashions, token);
        else
            message = await GameRouter.PlaceStreetNpcNearPlayerAsync(session, templateId, distance, fashions, token);

        return new { ok = true, message, npcs = StreetNpcList() };
    }

    
    private async Task<object> StreetNpcRemoveAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        ulong id = 0;
        var all = false;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("id", out var pi) && pi.TryGetUInt64(out var iv)) id = iv;
            all = root.TryGetProperty("all", out var pa) && pa.ValueKind == JsonValueKind.True;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        var message = all
            ? await GameRouter.RemoveAllStreetNpcsAsync(session, token)
            : await GameRouter.RemoveStreetNpcAsync(session, id, token);
        return new { ok = true, message, npcs = StreetNpcList() };
    }
}
