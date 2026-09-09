using System.Net;
using System.Text;
using System.Text.Json;
using Ananta.Server.Configuration;
using Ananta.Server.Handlers.Game;
using Ananta.Server.Protocol.Client4229938;

namespace Ananta.Server.App.Admin;

/// <summary>
/// Embedded localhost admin panel (no auth by design — bind 127.0.0.1 only).
/// Configured via private-server.json → admin { enabled, host, port }.
/// </summary>
internal sealed class AdminWebServer(PrivateServerConfig config)
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    };

    internal async Task RunAsync(CancellationToken cancellationToken)
    {
        if (!config.Admin.Enabled)
        {
            Console.WriteLine("[ADMIN] disabled by config (admin.enabled=false)");
            return;
        }
        var prefix = $"http://{config.Admin.Host}:{config.Admin.Port}/";
        var listener = new HttpListener();
        listener.Prefixes.Add(prefix);
        try
        {
            listener.Start();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[ADMIN] failed to listen on {prefix}: {ex.Message}");
            return;
        }
        Console.WriteLine($"[ADMIN] panel at {prefix} (localhost only, no auth)");
        using var registration = cancellationToken.Register(() => listener.Stop());
        while (!cancellationToken.IsCancellationRequested)
        {
            HttpListenerContext ctx;
            try
            {
                ctx = await listener.GetContextAsync();
            }
            catch (HttpListenerException) { break; }
            catch (ObjectDisposedException) { break; }
            _ = Task.Run(() => HandleAsync(ctx, cancellationToken), cancellationToken);
        }
        listener.Close();
    }

    private static async Task HandleAsync(HttpListenerContext ctx, CancellationToken ct)
    {
        var req = ctx.Request;
        var res = ctx.Response;
        try
        {
            var path = req.Url?.AbsolutePath ?? "/";
            if (req.HttpMethod == "GET" && path == "/")
            {
                void_Write(res, "text/html; charset=utf-8", PageHtml);
                return;
            }
            if (req.HttpMethod == "GET" && path == "/api/status")
            {
                void_WriteJson(res, StatusPayload());
                return;
            }
            if (req.HttpMethod == "GET" && path == "/api/vehicles")
            {
                var snap = GameAdminBridge.GetSnapshot();
                void_WriteJson(res, new
                {
                    fleet = GameAdminBridge.FleetIds(),
                    lastVehicleId = snap.LastAdminVehicleId,
                    lastUid = snap.LastSpawnedVehicleUid,
                    lastDriveState = snap.HasVehicleDriveState ? (byte?)snap.LastVehicleDriveState : null,
                });
                return;
            }
            if (req.HttpMethod == "GET" && path == "/api/unknown-log")
            {
                var query = ParseQuery(req.Url?.Query);
                var lines = query.TryGetValue("lines", out var raw) && int.TryParse(raw, out var n) ? Math.Clamp(n, 1, 500) : 100;
                void_WriteJson(res, new { lines = UnknownMethodLogger.Tail(lines) });
                return;
            }
            if (req.HttpMethod == "POST" && path == "/api/teleport")
            {
                var body = await ReadBodyAsync(req);
                var cmd = JsonSerializer.Deserialize<TeleportRequest>(body, JsonOptions) ?? new TeleportRequest();
                if (!float.IsFinite(cmd.X) || !float.IsFinite(cmd.Y) || !float.IsFinite(cmd.Z))
                {
                    void_WriteJson(res, new { ok = false, message = "x/y/z must be finite numbers" }, 400);
                    return;
                }
                var mode = (cmd.Mode ?? "instant").ToLowerInvariant();
                var result = mode == "loading"
                    ? await GameAdminBridge.TeleportWithLoadingAsync(cmd.X, cmd.Y, cmd.Z, cmd.Facing)
                    : await GameAdminBridge.TeleportInstantAsync(cmd.X, cmd.Y, cmd.Z, cmd.Facing);
                void_WriteJson(res, new { ok = result.Ok, message = result.Message });
                return;
            }
            if (req.HttpMethod == "POST" && path == "/api/vehicle/spawn")
            {
                var body = await ReadBodyAsync(req);
                var cmd = JsonSerializer.Deserialize<VehicleSpawnRequest>(body, JsonOptions) ?? new VehicleSpawnRequest();
                if (cmd.VehicleId == 0)
                {
                    void_WriteJson(res, new { ok = false, message = "vehicleId must be non-zero" }, 400);
                    return;
                }
                var result = await GameAdminBridge.SpawnVehicleAsync(cmd.VehicleId);
                void_WriteJson(res, new { ok = result.Ok, message = result.Message, uid = result.Uid });
                return;
            }
            if (req.HttpMethod == "POST" && path == "/api/vehicle/enter")
            {
                var result = await GameAdminBridge.EnterVehicleAsync();
                void_WriteJson(res, new { ok = result.Ok, message = result.Message });
                return;
            }
            if (req.HttpMethod == "POST" && path == "/api/vehicle/exit")
            {
                var result = await GameAdminBridge.ExitVehicleAsync();
                void_WriteJson(res, new { ok = result.Ok, message = result.Message });
                return;
            }
            if (req.HttpMethod == "GET" && path == "/api/scenes")
            {
                void_WriteJson(res, new { presets = GameAdminBridge.ScenePresets() });
                return;
            }
            if (req.HttpMethod == "GET" && path == "/api/weapons")
            {
                void_WriteJson(res, new { weapons = GameAdminBridge.WeaponCatalog() });
                return;
            }
            if (req.HttpMethod == "POST" && path == "/api/weapons/grant")
            {
                var body = await ReadBodyAsync(req);
                var cmd = JsonSerializer.Deserialize<WeaponGrantRequest>(body, JsonOptions) ?? new WeaponGrantRequest();
                var result = await GameAdminBridge.GrantWeaponAsync(cmd.TemplateId);
                void_WriteJson(res, new { ok = result.Ok, message = result.Message });
                return;
            }
            if (req.HttpMethod == "GET" && path == "/api/timeweather")
            {
                void_WriteJson(res, GameAdminBridge.TimeWeatherStatus());
                return;
            }
            if (req.HttpMethod == "POST" && path == "/api/timeweather/time")
            {
                var body = await ReadBodyAsync(req);
                var cmd = JsonSerializer.Deserialize<TimeSetRequest>(body, JsonOptions) ?? new TimeSetRequest();
                var result = await GameAdminBridge.SetTimeAsync(cmd.Hour, cmd.Minute, cmd.Fix, cmd.Transition);
                void_WriteJson(res, new { ok = result.Ok, message = result.Message });
                return;
            }
            if (req.HttpMethod == "POST" && path == "/api/timeweather/weather")
            {
                var body = await ReadBodyAsync(req);
                var cmd = JsonSerializer.Deserialize<WeatherSetRequest>(body, JsonOptions) ?? new WeatherSetRequest();
                var result = await GameAdminBridge.SetWeatherAsync(cmd.WeatherId, cmd.Transition);
                void_WriteJson(res, new { ok = result.Ok, message = result.Message });
                return;
            }            if (req.HttpMethod == "POST" && path == "/api/scene/switch")
            {
                var body = await ReadBodyAsync(req);
                var cmd = JsonSerializer.Deserialize<SceneSwitchRequest>(body, JsonOptions) ?? new SceneSwitchRequest();
                if (!string.IsNullOrWhiteSpace(cmd.Preset))
                {
                    var preset = GameAdminBridge.ScenePresets().FirstOrDefault(p =>
                        string.Equals(p.Key, cmd.Preset, StringComparison.OrdinalIgnoreCase));
                    if (preset is null)
                    {
                        void_WriteJson(res, new { ok = false, message = $"unknown preset '{cmd.Preset}'" }, 400);
                        return;
                    }
                    var result = await GameAdminBridge.SwitchSceneAsync(
                        preset.RaidId, preset.InstanceId, preset.UniverseId,
                        preset.X, preset.Y, preset.Z, preset.Facing);
                    void_WriteJson(res, new { ok = result.Ok, message = result.Message });
                    return;
                }
                var custom = await GameAdminBridge.SwitchSceneAsync(
                    cmd.RaidId, cmd.InstanceId, cmd.UniverseId, cmd.X, cmd.Y, cmd.Z, cmd.Facing);
                void_WriteJson(res, new { ok = custom.Ok, message = custom.Message });
                return;
            }
            void_WriteJson(res, new { ok = false, message = "not found" }, 404);
        }
        catch (JsonException jex)
        {
            void_WriteJson(ctx.Response, new { ok = false, message = "bad request: " + jex.Message }, 400);
        }
        catch (Exception ex)
        {
            void_WriteJson(ctx.Response, new { ok = false, message = ex.Message }, 500);
        }
    }

    private static object StatusPayload()
    {
        var s = GameAdminBridge.GetSnapshot();
        return new
        {
            connected = s.Connected,
            session = s.SessionId,
            lastSeenUtc = s.LastSeenUtc,
            unitId = s.UnitId,
            templateId = s.TemplateId,
            x = s.X, y = s.Y, z = s.Z,
            facing = s.Facing,
            hasTransform = s.HasTransform,
            ready = s.Ready,
            pendingTeleportId = s.PendingTeleportId,
            raidId = s.ActiveRaidId,
            instanceId = s.ActiveInstanceId,
            universeId = s.ActiveUniverseId,
            currentVehicleId = s.CurrentVehicleId,
            currentVehicleSeat = s.CurrentVehicleSeat,
        };
    }

    private static Dictionary<string, string> ParseQuery(string? query)
    {
        var result = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (string.IsNullOrEmpty(query))
            return result;
        foreach (var part in query.TrimStart('?').Split('&', StringSplitOptions.RemoveEmptyEntries))
        {
            var eq = part.IndexOf('=');
            if (eq < 0) { result[Uri.UnescapeDataString(part)] = ""; continue; }
            result[Uri.UnescapeDataString(part[..eq])] = Uri.UnescapeDataString(part[(eq + 1)..]);
        }
        return result;
    }

    private static async Task<string> ReadBodyAsync(HttpListenerRequest req)
    {
        using var reader = new StreamReader(req.InputStream, req.ContentEncoding ?? Encoding.UTF8);
        var text = await reader.ReadToEndAsync();
        return string.IsNullOrWhiteSpace(text) ? "{}" : text;
    }

    private static void void_Write(HttpListenerResponse res, string contentType, string text, int status = 200)
    {
        var bytes = Encoding.UTF8.GetBytes(text);
        res.StatusCode = status;
        res.ContentType = contentType;
        res.ContentLength64 = bytes.Length;
        res.OutputStream.Write(bytes, 0, bytes.Length);
        res.OutputStream.Close();
    }

    private static void void_WriteJson(HttpListenerResponse res, object payload, int status = 200)
        => void_Write(res, "application/json; charset=utf-8", JsonSerializer.Serialize(payload, JsonOptions), status);

    private sealed class TeleportRequest
    {
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }
        public float? Facing { get; set; }
        public string? Mode { get; set; }
    }

    private sealed class VehicleSpawnRequest
    {
        public uint VehicleId { get; set; }
    }

    private sealed class WeaponGrantRequest
    {
        public uint TemplateId { get; set; }
    }

    private sealed class TimeSetRequest
    {
        public int Hour { get; set; }
        public int Minute { get; set; }
        public bool Fix { get; set; } = true;
        public int Transition { get; set; } = 5;
    }

    private sealed class WeatherSetRequest
    {
        public int WeatherId { get; set; }
        public int Transition { get; set; } = 15;
    }

    private sealed class SceneSwitchRequest
    {
        public string? Preset { get; set; }
        public uint RaidId { get; set; }
        public ulong InstanceId { get; set; }
        public uint UniverseId { get; set; }
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }
        public float Facing { get; set; }
    }

    private const string PageHtml = """
        <!doctype html>
        <html lang="en"><head><meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>AnantaPS Admin</title>
        <style>
        body{font-family:Consolas,monospace;background:#111;color:#ddd;max-width:900px;margin:24px auto;padding:0 16px}
        h1{font-size:20px}h2{font-size:15px;color:#9cf;margin-top:28px}
        .card{background:#1b1b1b;border:1px solid #333;border-radius:8px;padding:12px 16px;margin:12px 0}
        label{display:inline-block;min-width:70px;margin:4px 0}
        input,select{background:#222;color:#eee;border:1px solid #555;border-radius:4px;padding:4px 8px;margin:2px}
        button{background:#2a6;color:#fff;border:0;border-radius:4px;padding:6px 14px;cursor:pointer;margin:6px 4px 0 0}
        button:hover{background:#3b7}
        pre{background:#000;border:1px solid #333;border-radius:6px;padding:8px;white-space:pre-wrap;max-height:300px;overflow:auto}
        .pos{font-size:16px;color:#8f8}
        .warn{color:#fc6}
        </style></head><body>
        <h1>AnantaPS Admin Panel <span class="warn">(localhost, no auth)</span></h1>
        <div class="card"><h2>Player status (polls every 2s)</h2>
        <div id="status">connecting…</div></div>
        <div class="card"><h2>Teleport</h2>
        <div><label>X</label><input id="tx" type="number" step="any" value="3142.67">
        <label>Y</label><input id="ty" type="number" step="any" value="0">
        <label>Z</label><input id="tz" type="number" step="any" value="2522.78">
        <label>Facing</label><input id="teleportFacing" type="number" step="any" placeholder="(keep)"></div>
        <div><label>Mode</label><select id="teleportMode"><option value="instant">instant (SyncUnitPosition_P)</option>
        <option value="loading">loading flow (SyncTeleport)</option></select></div>
        <button onclick="teleport()">Teleport</button>
        <button onclick="fillCurrent()">Fill current position</button>
        <pre id="tres"></pre></div>
        <div class="card"><h2>Vehicle spawn (car appears beside you — walk up and press F)</h2>
        <div><label>Fleet</label><select id="vf"></select>
        <label>or id</label><input id="vi" type="number" value="0"></div>
        <button onclick="spawnVehicle()">Spawn vehicle</button>
        <button onclick="enterVehicle()">Enter last spawned vehicle</button>
        <button onclick="exitVehicle()">Exit vehicle</button>
        <pre id="vres"></pre>
        <div id="vstate"></div></div>
        <div class="card"><h2>Scene ("raid") switch</h2>
        <div><label>Preset</label><select id="sf"></select>
        <button onclick="switchPreset()">Switch to preset</button></div>
        <div><label>Raid</label><input id="sr" type="number" value="23300999">
        <label>Instance</label><input id="si" type="number" value="20001223">
        <label>Universe</label><input id="su" type="number" value="76000888"></div>
        <div><label>X</label><input id="sx" type="number" step="any" value="-1638">
        <label>Y</label><input id="sy" type="number" step="any" value="18.025">
        <label>Z</label><input id="sz" type="number" step="any" value="1540.5">
        <label>Facing</label><input id="sfa" type="number" step="any" value="-6.4"></div>
        <button onclick="switchCustom()">Switch to custom</button>
        <pre id="sres"></pre></div>
        <div class="card"><h2>Weapon grant (armory — equip in-game via weapon wheel)</h2>
        <div><label>Weapon</label><select id="wf"></select></div>
        <button onclick="grantWeapon()">Grant weapon</button>
        <pre id="wres"></pre></div>
        <div class="card"><h2>Time + weather</h2>
        <div id="twstate">loading…</div>
        <div><label>Time</label><input id="timeValue" type="time" step="60" value="12:00" aria-label="Game time (24-hour clock)">
        <label>Fix</label><input id="timeFix" type="checkbox" checked>
        <label>Trans</label><input id="tt" type="number" value="5" style="width:60px"></div>
        <button onclick="setTime()">Set time</button>
        <div><label>Weather</label><select id="ws"></select>
        <label>Trans</label><input id="wt" type="number" value="15" style="width:60px"></div>
        <button onclick="setWeather()">Set weather</button>
        <button onclick="clearWeather()">Clear override</button>
        <pre id="twres"></pre></div>
        <div class="card"><h2>Unknown methods (latest)</h2>
        <button onclick="loadUnknown()">Refresh</button>
        <pre id="u"></pre></div>
        <script>
        let cur=null;
        async function status(){
          const r=await fetch('/api/status'); const s=await r.json(); cur=s;
          document.getElementById('status').innerHTML = s.connected
            ? `<span class="pos">pos=(${s.x.toFixed(2)}, ${s.y.toFixed(2)}, ${s.z.toFixed(2)}) facing=${s.facing.toFixed(2)}</span><br>unit=${s.unitId} template=${s.templateId} ready=${s.ready} transform=${s.hasTransform} pendingTeleport=${s.pendingTeleportId}<br>raid=${s.raidId} instance=${s.instanceId} universe=${s.universeId}<br>vehicle=${s.currentVehicleId} seat=${s.currentVehicleSeat}<br>session=${s.session} lastSeen=${s.lastSeenUtc}`
            : 'no player session (log in with the game client first)';
        }
        async function vehicles(){
          const r=await fetch('/api/vehicles'); const v=await r.json();
          const sel=document.getElementById('vf'); sel.innerHTML='';
          (v.fleet||[]).forEach(id=>{const o=document.createElement('option');o.value=id;o.text=id;sel.appendChild(o);});
          document.getElementById('vstate').textContent='lastVehicle='+v.lastVehicleId+' lastUid='+v.lastUid+' lastDriveState='+(v.lastDriveState??'(none yet)');
        }
        function fillCurrent(){ if(!cur||!cur.connected) return;
          tx.value=cur.x.toFixed(2); ty.value=cur.y.toFixed(2); tz.value=cur.z.toFixed(2); teleportFacing.value=cur.facing.toFixed(2); }
        async function teleport(){
          const f=document.getElementById('teleportFacing').value;
          const r=await fetch('/api/teleport',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({x:+tx.value,y:+ty.value,z:+tz.value,facing:f==='' ? null : +f,mode:teleportMode.value})});
          tres.textContent=JSON.stringify(await r.json(),null,2); status();
        }
        async function spawnVehicle(){
          const id=+vi.value||+vf.value;
          const r=await fetch('/api/vehicle/spawn',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({vehicleId:id})});
          vres.textContent=JSON.stringify(await r.json(),null,2); vehicles();
        }
        async function exitVehicle(){
          const r=await fetch('/api/vehicle/exit',{method:'POST'});
          vres.textContent=JSON.stringify(await r.json(),null,2); status();
        }
        async function enterVehicle(){
          const r=await fetch('/api/vehicle/enter',{method:'POST'});
          vres.textContent=JSON.stringify(await r.json(),null,2); status();
        }
        async function loadUnknown(){
          const r=await fetch('/api/unknown-log?lines=60'); const j=await r.json();
          document.getElementById('u').textContent=(j.lines||[]).join('\n')||'(empty)';
        }
        async function weapons(){
          const r=await fetch('/api/weapons'); const j=await r.json();
          const sel=document.getElementById('wf'); sel.innerHTML='';
          (j.weapons||[]).forEach(w=>{const o=document.createElement('option');o.value=w.templateId;o.text=w.name+' ('+w.templateId+')';sel.appendChild(o);});
        }
        async function grantWeapon(){
          const r=await fetch('/api/weapons/grant',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({templateId:+wf.value})});
          wres.textContent=JSON.stringify(await r.json(),null,2);
        }
        async function timeweather(){
          const r=await fetch('/api/timeweather'); const j=await r.json();
          document.getElementById('twstate').textContent=j.connected
            ? `time=${j.hasTime?formatGameTime(j.hour,j.minute)+' ('+String(j.hour).padStart(2,'0')+':'+String(j.minute).padStart(2,'0')+') fix='+j.fix:'(client default)'} weather=${j.hasWeather?j.weatherId:'(client default)'}` : 'no session';
          const sel=document.getElementById('ws'); sel.innerHTML='';
          (j.weathers||[]).forEach(w=>{const o=document.createElement('option');o.value=w.id;o.text=w.name+' ('+w.id+')';sel.appendChild(o);});
        }
        function formatGameTime(hour, minute){
          const displayMinute=String(minute).padStart(2,'0');
          if(hour === 0) return `12:${displayMinute} midnight`;
          if(hour === 12) return `12:${displayMinute} noon`;
          return `${hour % 12}:${displayMinute} ${hour < 12 ? 'AM' : 'PM'}`;
        }
        async function setTime(){
          const [hour,minute]=(timeValue.value||'12:00').split(':').map(Number);
          const r=await fetch('/api/timeweather/time',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({hour,minute,fix:timeFix.checked,transition:+tt.value})});
          twres.textContent=JSON.stringify(await r.json(),null,2); timeweather();
        }
        async function setWeather(){
          const r=await fetch('/api/timeweather/weather',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({weatherId:+ws.value,transition:+wt.value})});
          twres.textContent=JSON.stringify(await r.json(),null,2); timeweather();
        }
        async function clearWeather(){
          const r=await fetch('/api/timeweather/weather',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({weatherId:0,transition:0})});
          twres.textContent=JSON.stringify(await r.json(),null,2); timeweather();
        }
        async function scenes(){
          const r=await fetch('/api/scenes'); const j=await r.json();
          const sel=document.getElementById('sf'); sel.innerHTML='';
          (j.presets||[]).forEach(p=>{const o=document.createElement('option');o.value=p.key;o.text=p.label+' (raid '+p.raidId+')';o.dataset.p=JSON.stringify(p);sel.appendChild(o);});
          sel.onchange=()=>{const p=JSON.parse(sel.selectedOptions[0].dataset.p);
            sr.value=p.raidId;si.value=p.instanceId;su.value=p.universeId;sx.value=p.x;sy.value=p.y;sz.value=p.z;sfa.value=p.facing;};
          if(sel.options.length)sel.onchange();
        }
        async function switchPreset(){
          const r=await fetch('/api/scene/switch',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({preset:sf.value})});
          sres.textContent=JSON.stringify(await r.json(),null,2); status();
        }
        async function switchCustom(){
          const r=await fetch('/api/scene/switch',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({raidId:+sr.value,instanceId:+si.value,universeId:+su.value,x:+sx.value,y:+sy.value,z:+sz.value,facing:+sfa.value})});
          sres.textContent=JSON.stringify(await r.json(),null,2); status();
        }
        status(); vehicles(); scenes(); weapons(); timeweather(); loadUnknown(); setInterval(status,2000);
        </script></body></html>
        """;
}
