using System.Text;

namespace AnantaTestGameServer
{
    public partial class Server
    {
        private static string BuildGmMainMenu()
        {
            return @"
<!DOCTYPE html>
<html>
<head>
    <title>GM Tools - Ananta</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 900px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        h1 { color: #00ff88; text-align: center; }
        .menu-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-top: 30px; }
        .menu-card { padding: 25px; background: #2a2a2a; border-radius: 12px; border-left: 4px solid #00ff88; transition: all 0.3s; cursor: pointer; text-decoration: none; color: #e0e0e0; display: block; }
        .menu-card:hover { background: #333; transform: translateY(-5px); box-shadow: 0 8px 16px rgba(0,255,136,0.2); }
        .menu-card h2 { color: #00ff88; margin: 0 0 10px 0; font-size: 24px; }
        .menu-card p { margin: 0; color: #aaa; font-size: 14px; }
        .icon { font-size: 48px; margin-bottom: 15px; }
    </style>
" + GmStrings.GetI18nScript() + @"
</head>
<body>
" + GmStrings.GetLangSelector() + @"
    <h1 data-t=""menuTitle"">GM Tools Menu</h1>
    <div class='menu-grid'>
        <a href='/gm/vehicle' class='menu-card'>
            <div class='icon'>🚗</div>
            <h2 data-t=""vehicleControl"">Vehicle Control</h2>
            <p data-t=""vehicleDesc"">Spawn, summon, and manage vehicles</p>
        </a>
        <a href='/gm/spirit' class='menu-card'>
            <div class='icon'>👤</div>
            <h2 data-t=""characterSwitch"">Character Switch</h2>
            <p data-t=""characterDesc"">Switch between 19 playable characters</p>
        </a>
        <a href='/gm/weapons' class='menu-card'>
            <div class='icon'>🔫</div>
            <h2 data-t=""weaponsPanel"">Weapons Panel</h2>
            <p data-t=""weaponsDesc"">Manage character weapons</p>
        </a>
        <a href='/gm/npcs' class='menu-card'>
            <div class='icon'>👥</div>
            <h2 data-t=""npcPanel"">NPC Panel</h2>
            <p data-t=""npcDesc"">Spawn and manage NPCs</p>
        </a>
        <a href='/gm/weather' class='menu-card'>
            <div class='icon'>🌤</div>
            <h2 data-t=""weatherControl"">Weather Control</h2>
            <p data-t=""weatherDesc"">Change weather conditions</p>
        </a>
        <a href='/gm/time' class='menu-card'>
            <div class='icon'>🕐</div>
            <h2 data-t=""timeControl"">Time Control</h2>
            <p data-t=""timeDesc"">Set game time to any hour</p>
        </a>
        <a href='/gm/teleport' class='menu-card'>
            <div class='icon'>📍</div>
            <h2 data-t=""teleport"">Teleport</h2>
            <p data-t=""teleportDesc"">Teleport to any coordinates</p>
        </a>
        <a href='/gm/player' class='menu-card'>
            <div class='icon'>❤️</div>
            <h2 data-t=""player"">Player</h2>
            <p data-t=""playerDesc"">HP, buffs, revive, attributes</p>
        </a>
        <a href='/gm/items' class='menu-card'>
            <div class='icon'>📦</div>
            <h2 data-t=""items"">Items</h2>
            <p data-t=""itemsDesc"">Add items, money, fashions, weapons</p>
        </a>
        <a href='/gm/quests' class='menu-card'>
            <div class='icon'>📋</div>
            <h2 data-t=""quests"">Quests</h2>
            <p data-t=""questsDesc"">Accept, submit, fail, unlock all</p>
        </a>
        <a href='/gm/spawn' class='menu-card'>
            <div class='icon'>👾</div>
            <h2 data-t=""spawn"">Spawn</h2>
            <p data-t=""spawnDesc"">Spawn enemies and NPCs</p>
        </a>
        <a href='/gm/debug' class='menu-card'>
            <div class='icon'>🔧</div>
            <h2 data-t=""debug"">Debug</h2>
            <p data-t=""debugDesc"">Free skill, cooldowns, durability</p>
        </a>
        <a href='/gm/world' class='menu-card'>
            <div class='icon'>🌍</div>
            <h2 data-t=""world"">World</h2>
            <p data-t=""worldDesc"">Fog, reputation, spirits, vehicles</p>
        </a>
        <a href='/gm/dump' class='menu-card'>
            <div class='icon'>📊</div>
            <h2 data-t=""rpcDump"">RPC Dump</h2>
            <p data-t=""rpcDumpDesc"">View/export unhandled RPCs, toggle debug mode</p>
        </a>
        <a href='/gm/sessions' class='menu-card'>
            <div class='icon'>📋</div>
            <h2 data-t=""sessions"">Sessions</h2>
            <p data-t=""sessionsDesc"">Track game client sessions, detect crashes</p>
        </a>
        <a href='/gm/transit' class='menu-card'>
            <div class='icon'>🚇</div>
            <h2 data-t=""transit"">Transit Control</h2>
            <p data-t=""transitDesc"">Toggle metro lines 1-24, set trains/line, resync</p>
        </a>
    </div>
</body>
</html>";
        }

        private static string BuildGmSessionsPage()
        {
            var sb = new System.Text.StringBuilder();
            sb.AppendLine("<!doctype html>");
            sb.AppendLine("<html lang=\"en\">");
            sb.AppendLine("<head><meta charset=\"utf-8\"><title>Game Sessions</title>");
            sb.AppendLine("<style>body{font-family:monospace;background:#1a1a2e;color:#e0e0e0;padding:20px}");
            sb.AppendLine("h1{color:#00d4ff}h2{color:#ffd700}");
            sb.AppendLine("table{border-collapse:collapse;width:100%;margin:10px 0}");
            sb.AppendLine("th,td{border:1px solid #444;padding:6px 10px;text-align:left}");
            sb.AppendLine("th{background:#16213e;color:#00d4ff}");
            sb.AppendLine("tr:nth-child(even){background:#0f3460}");
            sb.AppendLine("tr:hover{background:#1a5276}");
            sb.AppendLine(".crash{color:#ff4444;font-weight:bold}.active{color:#44ff44}");
            sb.AppendLine(".normal{color:#888}.btn{display:inline-block;padding:6px 14px;margin:4px;border-radius:4px;text-decoration:none;font-size:13px}");
            sb.AppendLine(".btn-d{background:#c0392b;color:#fff}.btn-e{background:#2980b9;color:#fff}");
            sb.AppendLine(".event-log{font-size:12px;color:#aaa;max-height:120px;overflow-y:auto}");
            sb.AppendLine("</style></head><body>");
            sb.AppendLine("<h1> Game Session Tracker</h1>");
            sb.AppendLine($"<p>Total: {GameSessionTracker.TotalCount} | Active: {GameSessionTracker.ActiveCount}</p>");
            sb.AppendLine("<p><a class=\"btn btn-e\" href=\"/gm/sessions/export\"> Export Report</a> ");
            sb.AppendLine("<a class=\"btn btn-d\" href=\"/gm/sessions/clear\"> Clear Data</a> ");
            sb.AppendLine("<a class=\"btn btn-e\" href=\"/gm/menu\"> GM Menu</a></p>");
            sb.AppendLine("<hr>");

            sb.AppendLine("<h2>Active Sessions</h2>");
            sb.AppendLine("<table><tr><th>#</th><th>PID</th><th>Client</th><th>Connected</th><th>Duration</th><th>Events</th><th>Recent</th></tr>");
            bool hasAny = false;

            for (int i = GameSessionTracker.TotalCount - 1; i >= 0; i--)
            {
                var record = GetSessionAt(i);
                if (record == null) continue;
                bool isActive = record.DisconnectTime == null;
                if (!isActive) continue;
                hasAny = true;
                sb.AppendLine($"<tr><td>{record.SessionId}</td><td>{record.Pid}</td><td>{record.RemoteEndPoint}</td>");
                sb.AppendLine($"<td>{record.ConnectTime:HH:mm:ss}</td><td>{record.DurationSeconds:F0}s</td>");
                sb.AppendLine($"<td>{record.Events.Count}</td><td class=\"active\">ACTIVE</td></tr>");
            }
            if (!hasAny) sb.AppendLine("<tr><td colspan=\"7\">No active sessions</td></tr>");
            sb.AppendLine("</table>");

            sb.AppendLine("<h2>Past Sessions (last 50)</h2>");
            sb.AppendLine("<table><tr><th>#</th><th>PID</th><th>Client</th><th>Connect</th><th>Disconnect</th><th>Duration</th><th>Reason</th><th>Events</th><th>Timeline</th></tr>");
            hasAny = false;
            int shown = 0;

            for (int i = GameSessionTracker.TotalCount - 1; i >= 0 && shown < 50; i--)
            {
                var record = GetSessionAt(i);
                if (record == null || record.DisconnectTime == null) continue;
                hasAny = true;
                shown++;
                bool isCrash = record.DisconnectReason != null &&
                               (record.DisconnectReason.Contains("crash", StringComparison.OrdinalIgnoreCase) ||
                                record.DisconnectReason.Contains("connection_lost", StringComparison.OrdinalIgnoreCase));
                string reasonClass = isCrash ? "crash" : "normal";
                sb.AppendLine($"<tr><td>{record.SessionId}</td><td>{record.Pid}</td><td>{record.RemoteEndPoint}</td>");
                sb.AppendLine($"<td>{record.ConnectTime:HH:mm:ss}</td><td>{record.DisconnectTime:HH:mm:ss}</td>");
                sb.AppendLine($"<td>{record.DurationSeconds:F1}s</td><td class=\"{reasonClass}\">{record.DisconnectReason}</td>");
                sb.AppendLine($"<td>{record.Events.Count}</td><td class=\"event-log\">");
                foreach (var e in record.Events)
                {
                    string ts = e.Timestamp.ToString("HH:mm:ss");
                    sb.AppendLine($"<div><b>[{ts}]</b> {e.EventType} — {e.Details}</div>");
                }
                sb.AppendLine("</td></tr>");
            }
            if (!hasAny) sb.AppendLine("<tr><td colspan=\"9\">No past sessions</td></tr>");
            sb.AppendLine("</table>");

            sb.AppendLine("<hr><p><a href=\"/gm/menu\">Back to GM Menu</a></p>");
            sb.AppendLine("</body></html>");
            return sb.ToString();
        }

        private static GameSessionTracker.SessionRecord GetSessionAt(int index)
        {
            return GameSessionTracker.GetSession(index);
        }

        private static string BuildGmWeatherUi()
        {
            return @"
<!DOCTYPE html>
<html>
<head>
    <title>Weather Control - Ananta GM</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 900px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        h1 { color: #00ff88; }
        .weather-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 15px; margin: 20px 0; }
        .weather-btn { padding: 20px 15px; border: none; border-radius: 8px; cursor: pointer; font-size: 15px; background: #2a2a2a; color: #e0e0e0; transition: all 0.3s; text-align: center; }
        .weather-btn:hover { background: #00ff88; color: #000; transform: scale(1.05); }
        .weather-btn.active { background: #00ff88; color: #000; border: 2px solid #fff; }
        .status { padding: 15px; margin: 20px 0; background: #2a2a2a; border-radius: 8px; }
        .note { padding: 10px; margin: 20px 0; background: #332a00; border-left: 4px solid #ffaa00; border-radius: 4px; font-size: 13px; }
    </style>
</head>
<body>
    <h1>🌤 Weather Control</h1>
    <div class='note'>
        ⚠️ <strong>Note:</strong> These weather types are based on common game IDs (0-6). 
        If a type doesn't exist in the game, it may show as default or cause visual glitches.
        Test each one to see which works!
    </div>
    <div class='weather-grid'>
        <button class='weather-btn' onclick='setWeather(0)'>☀️<br/>Type 0</button>
        <button class='weather-btn' onclick='setWeather(1)'>⛅<br/>Type 1</button>
        <button class='weather-btn' onclick='setWeather(2)'>☁️<br/>Type 2</button>
        <button class='weather-btn' onclick='setWeather(3)'>🌧<br/>Type 3<br/>(Default)</button>
        <button class='weather-btn' onclick='setWeather(4)'>⛈<br/>Type 4</button>
        <button class='weather-btn' onclick='setWeather(6)'>🌫<br/>Type 6</button>
    </div>
    <div class='status' id='output'>Ready - Click a weather type above</div>
    <script>
        async function setWeather(id) {
            output.textContent = 'Setting weather to typeId=' + id + '...';
            try {
                const res = await fetch('/gm/weather/set?weatherId=' + id);
                output.textContent = await res.text();
            } catch(e) {
                output.textContent = 'Error: ' + e.message;
            }
        }
    </script>
</body>
</html>";
        }

        private static string BuildGmTimeUi()
        {
            return @"
<!DOCTYPE html>
<html>
<head>
    <title>Time Control - Ananta GM</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        h1 { color: #ffaa00; }
        .time-btn { padding: 15px 25px; margin: 10px; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; background: #2a2a2a; color: #e0e0e0; transition: all 0.3s; }
        .time-btn:hover { background: #ffaa00; color: #000; transform: scale(1.05); }
        .time-input { padding: 10px; margin: 10px; background: #2a2a2a; color: #e0e0e0; border: 1px solid #555; border-radius: 5px; font-size: 16px; }
        .status { padding: 15px; margin: 20px 0; background: #2a2a2a; border-radius: 8px; }
    </style>
</head>
<body>
    <h1>🕐 Time Control</h1>
    <div class='status'>
        <p>Quick presets:</p>
    </div>
    <button class='time-btn' onclick='setTime(6,0)'>🌅 6:00 AM</button>
    <button class='time-btn' onclick='setTime(8,0)'>☀️ 8:00 AM</button>
    <button class='time-btn' onclick='setTime(12,0)'>🌞 12:00 PM</button>
    <button class='time-btn' onclick='setTime(18,0)'>🌇 6:00 PM</button>
    <button class='time-btn' onclick='setTime(20,0)'>🌙 8:00 PM</button>
    <button class='time-btn' onclick='setTime(0,0)'>🌌 12:00 AM</button>
    <div class='status'>
        <p>Custom time:</p>
        <input type='number' class='time-input' id='hour' min='0' max='23' value='12' placeholder='Hour (0-23)' style='width: 80px;'>
        <input type='number' class='time-input' id='minute' min='0' max='59' value='0' placeholder='Min (0-59)' style='width: 80px;'>
        <button class='time-btn' onclick='setCustomTime()'>Set Time</button>
    </div>
    <div class='status' id='output'>Ready</div>
    <script>
        async function setTime(h, m) {
            output.textContent = 'Setting time to ' + h + ':' + m + '...';
            try {
                const res = await fetch('/gm/time/set?hour=' + h + '&minute=' + m);
                output.textContent = await res.text();
            } catch(e) {
                output.textContent = 'Error: ' + e.message;
            }
        }
        async function setCustomTime() {
            const h = parseInt(hour.value) || 12;
            const m = parseInt(minute.value) || 0;
            await setTime(h, m);
        }
    </script>
</body>
</html>";
        }

        private static string BuildGmTeleportUi()
        {
            return @"<!DOCTYPE html>
<html lang=""zh-CN"">
<head>
  <meta charset=""utf-8"">
  <title>GM Teleport</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 600px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
    h1 { color: #00ff88; } input { width: 100%; padding: 8px; margin: 8px 0; background: #2a2a2a; border: 1px solid #444; color: #e0e0e0; border-radius: 4px; }
    button { background: #00ff88; color: #000; border: 0; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: bold; margin-top: 10px; }
    button:hover { background: #00cc66; } .coord-row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
    label { display: block; margin-top: 12px; color: #aaa; font-size: 13px; }
    a { color: #00ff88; } pre { background: #2a2a2a; padding: 10px; border-radius: 4px; margin-top: 10px; }
  </style>
</head>
<body>
  <h1>📍 GM Teleport</h1>
  <a href='/gm/menu' style=""display:block;margin-bottom:20px;"">← Back to Menu</a>
  <label>Coordinates</label>
  <div class=""coord-row"">
    <div><input id=""x"" type=""number"" step=""0.01"" value=""1000"" placeholder=""X""><small>X</small></div>
    <div><input id=""y"" type=""number"" step=""0.01"" value=""0"" placeholder=""Y""><small>Y</small></div>
    <div><input id=""z"" type=""number"" step=""0.01"" value=""2000"" placeholder=""Z""><small>Z</small></div>
  </div>
  <button onclick=""teleport()"">Teleport</button>
  <h3>Quick Locations</h3>
  <button class=""quick"" onclick=""go(1000,0,2000)"">Spawn (1000, 0, 2000)</button>
  <button class=""quick"" onclick=""go(980,0,1980)"">City Objects (980, 0, 1980)</button>
  <button class=""quick"" onclick=""go(1050,0,2100)"">Road (1050, 0, 2100)</button>
  <pre id=""output"">Ready.</pre>
  <script>
    function go(x,y,z) { document.getElementById('x').value=x; document.getElementById('y').value=y; document.getElementById('z').value=z; teleport(); }
    async function teleport() {
      const x=document.getElementById('x').value, y=document.getElementById('y').value, z=document.getElementById('z').value;
      const res=await fetch('/gm/teleport/go?x='+x+'&y='+y+'&z='+z);
      document.getElementById('output').textContent=await res.text();
    }
  </script>
</body>
</html>";
        }

        private static string BuildGmPlayerUi()
        {
            return @"<!DOCTYPE html>
<html lang=""zh-CN"">
<head>
  <meta charset=""utf-8"">
  <title>GM Player</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 700px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
    h1 { color: #00ff88; } h2 { color: #00cc66; margin-top: 24px; }
    input, select { width: 100%; padding: 8px; margin: 4px 0; background: #2a2a2a; border: 1px solid #444; color: #e0e0e0; border-radius: 4px; }
    button { background: #00ff88; color: #000; border: 0; padding: 8px 16px; border-radius: 6px; cursor: pointer; font-weight: bold; margin: 4px; }
    button:hover { background: #00cc66; } label { display: block; margin-top: 8px; color: #aaa; font-size: 13px; }
    a { color: #00ff88; } pre { background: #2a2a2a; padding: 10px; border-radius: 4px; margin-top: 10px; }
    .row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
  </style>
</head>
<body>
  <h1>❤️ GM Player Management</h1>
  <a href='/gm/menu' style=""display:block;margin-bottom:20px;"">← Back to Menu</a>

  <h2>Health</h2>
  <button onclick=""run('/gm/player/heal')"">Full Heal (100% HP)</button>
  <button onclick=""run('/gm/player/revive')"">Revive</button>
  <div style=""display:grid;grid-template-columns:3fr 1fr;gap:10px;"">
    <input id=""hp"" type=""number"" step=""0.01"" value=""1.0"" placeholder=""HP Rate (0-1)"">
    <button onclick=""run('/gm/player/set_hp?hpRate='+document.getElementById('hp').value)"">Set HP</button>
  </div>
  <button onclick=""run('/gm/player/info')"" style=""margin-top:8px;"">Player Info (JSON)</button>

  <h2>Buffs</h2>
  <div style=""display:grid;grid-template-columns:3fr 1fr 1fr;gap:10px;"">
    <input id=""buffId"" type=""number"" value=""52606154"" placeholder=""Buff ID"">
    <button onclick=""run('/gm/player/addbuff?buffId='+document.getElementById('buffId').value)"">Add</button>
    <button onclick=""run('/gm/player/removebuff?buffId='+document.getElementById('buffId').value)"">Remove</button>
  </div>
  <p style=""color:#888;font-size:12px;"">Common buffs: 52606154 (Superman), 52607001 (MultiJump), 52900002 (LongSwing)</p>

  <h2>Attributes</h2>
  <div style=""display:grid;grid-template-columns:2fr 1fr 1fr;gap:10px;"">
    <input id=""attrId"" type=""number"" value=""1"" placeholder=""Attr ID (1-97)"">
    <input id=""attrVal"" type=""number"" value=""1"" placeholder=""Value"">
    <button onclick=""run('/gm/player/setattr?attrId='+document.getElementById('attrId').value+'&value='+document.getElementById('attrVal').value)"">Set</button>
  </div>

  <pre id=""output"">Ready.</pre>
  <script>
    async function run(url) { const res=await fetch(url); document.getElementById('output').textContent=await res.text(); }
  </script>
</body>
</html>";
        }

        private static string BuildGmItemsUi()
        {
            return @"<!DOCTYPE html>
<html lang=""zh-CN"">
<head>
  <meta charset=""utf-8"">
  <title>GM Items</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 700px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
    h1 { color: #00ff88; } h2 { color: #00cc66; margin-top: 24px; }
    input { width: 100%; padding: 8px; margin: 4px 0; background: #2a2a2a; border: 1px solid #444; color: #e0e0e0; border-radius: 4px; }
    button { background: #00ff88; color: #000; border: 0; padding: 8px 16px; border-radius: 6px; cursor: pointer; font-weight: bold; margin: 4px; }
    button:hover { background: #00cc66; } button.danger { background: #ef4444; color: #fff; }
    label { display: block; margin-top: 8px; color: #aaa; font-size: 13px; } a { color: #00ff88; }
    pre { background: #2a2a2a; padding: 10px; border-radius: 4px; margin-top: 10px; }
    .row { display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 10px; }
  </style>
</head>
<body>
  <h1>📦 GM Items</h1>
  <a href='/gm/menu' style=""display:block;margin-bottom:20px;"">← Back to Menu</a>

  <h2>Items</h2>
  <div class=""row"">
    <input id=""itemId"" type=""number"" value=""1"" placeholder=""Item ID"">
    <input id=""itemCount"" type=""number"" value=""1"" placeholder=""Count"">
    <button onclick=""addItem()"">Add</button>
  </div>
  <div class=""row"">
    <input id=""remItemId"" type=""number"" value=""1"" placeholder=""Item ID"">
    <input id=""remItemCount"" type=""number"" value=""1"" placeholder=""Count"">
    <button class=""danger"" onclick=""remItem()"">Remove</button>
  </div>
  <button class=""danger"" onclick=""run('/gm/items/clearbag')"" style=""width:100%;margin-top:8px;"">Clear Bag</button>

  <h2>Money</h2>
  <div style=""display:grid;grid-template-columns:2fr 1fr;gap:10px;"">
    <input id=""money"" type=""number"" value=""10000"" placeholder=""Amount"">
    <button onclick=""run('/gm/items/addmoney?amount='+document.getElementById('money').value)"">Add Money</button>
  </div>

  <h2>Fashions</h2>
  <div style=""display:grid;grid-template-columns:2fr 1fr;gap:10px;"">
    <input id=""fashionId"" type=""number"" value=""1"" placeholder=""Fashion ID"">
    <button onclick=""run('/gm/items/addfashion?fashionId='+document.getElementById('fashionId').value)"">Add</button>
  </div>
  <button onclick=""run('/gm/items/addallfashions')"" style=""width:100%;"">Add All Fashions</button>

  <h2>Fashion Suits</h2>
  <div style=""display:grid;grid-template-columns:2fr 1fr;gap:10px;"">
    <input id=""suitId"" type=""number"" value=""11190001"" placeholder=""Suit ID"">
    <button onclick=""run('/gm/items/addfashionsuit?suitId='+document.getElementById('suitId').value)"">Add</button>
  </div>
  <button onclick=""run('/gm/items/addallfashionsuits')"" style=""width:100%;"">Add All Suits</button>

  <h2>Weapons</h2>
  <div style=""display:grid;grid-template-columns:2fr 1fr;gap:10px;"">
    <input id=""weaponTpl"" type=""number"" value=""60000001"" placeholder=""Template ID"">
    <button onclick=""run('/gm/items/addweapon?templateId='+document.getElementById('weaponTpl').value)"">Add Weapon</button>
  </div>

  <h2>Agents</h2>
  <div style=""display:grid;grid-template-columns:2fr 1fr;gap:10px;"">
    <input id=""agentId"" type=""number"" value=""1001001"" placeholder=""Agent ID"">
    <button onclick=""run('/gm/items/addagent?agentId='+document.getElementById('agentId').value)"">Add</button>
  </div>
  <button onclick=""run('/gm/items/addallagents')"" style=""width:100%;"">Add All Agents</button>

  <pre id=""output"">Ready.</pre>
  <script>
    async function run(url) { const res=await fetch(url); document.getElementById('output').textContent=await res.text(); }
    function addItem() { run('/gm/items/add?itemId='+document.getElementById('itemId').value+'&count='+document.getElementById('itemCount').value); }
    function remItem() { run('/gm/items/remove?itemId='+document.getElementById('remItemId').value+'&count='+document.getElementById('remItemCount').value); }
  </script>
</body>
</html>";
        }

        private static string BuildGmQuestsUi()
        {
            return @"<!DOCTYPE html>
<html lang=""zh-CN"">
<head>
  <meta charset=""utf-8"">
  <title>GM Quests</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 600px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
    h1 { color: #00ff88; } h2 { color: #00cc66; }
    input { width: 100%; padding: 8px; margin: 4px 0; background: #2a2a2a; border: 1px solid #444; color: #e0e0e0; border-radius: 4px; }
    button { background: #00ff88; color: #000; border: 0; padding: 8px 16px; border-radius: 6px; cursor: pointer; font-weight: bold; margin: 4px; }
    button:hover { background: #00cc66; } a { color: #00ff88; }
    pre { background: #2a2a2a; padding: 10px; border-radius: 4px; margin-top: 10px; }
  </style>
</head>
<body>
  <h1>📋 GM Quests</h1>
  <a href='/gm/menu' style=""display:block;margin-bottom:20px;"">← Back to Menu</a>

  <button onclick=""run('/gm/quests/unlockall')"" style=""width:100%;"">Unlock All Quests</button>

  <h2>Task Control</h2>
  <div style=""display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:10px;"">
    <input id=""taskId"" type=""number"" value=""1"" placeholder=""Task ID"">
    <button onclick=""run('/gm/quests/accept?taskId='+document.getElementById('taskId').value)"">Accept</button>
    <button onclick=""run('/gm/quests/submit?taskId='+document.getElementById('taskId').value)"">Submit</button>
    <button onclick=""run('/gm/quests/fail?taskId='+document.getElementById('taskId').value)"">Fail</button>
  </div>

  <pre id=""output"">Ready.</pre>
  <script>
    async function run(url) { const res=await fetch(url); document.getElementById('output').textContent=await res.text(); }
  </script>
</body>
</html>";
        }

        private static string BuildGmSpawnUi()
        {
            return @"<!DOCTYPE html>
<html lang=""zh-CN"">
<head>
  <meta charset=""utf-8"">
  <title>GM Spawn</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 700px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
    h1 { color: #00ff88; } h2 { color: #00cc66; }
    input { width: 100%; padding: 8px; margin: 4px 0; background: #2a2a2a; border: 1px solid #444; color: #e0e0e0; border-radius: 4px; }
    button { background: #00ff88; color: #000; border: 0; padding: 8px 16px; border-radius: 6px; cursor: pointer; font-weight: bold; margin: 4px; }
    button:hover { background: #00cc66; } a { color: #00ff88; }
    pre { background: #2a2a2a; padding: 10px; border-radius: 4px; margin-top: 10px; }
    .coord-row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; }
  </style>
</head>
<body>
  <h1>👾 GM Spawn</h1>
  <a href='/gm/menu' style=""display:block;margin-bottom:20px;"">← Back to Menu</a>

  <h2>Spawn Enemy</h2>
  <div style=""display:grid;grid-template-columns:2fr 1fr;gap:10px;"">
    <input id=""enemyId"" type=""number"" value=""1"" placeholder=""Enemy Config ID"">
    <button onclick=""spawnEnemy()"">Spawn</button>
  </div>

  <h2>Spawn NPC</h2>
  <div style=""display:grid;grid-template-columns:2fr 1fr;gap:10px;"">
    <input id=""npcSpawnId"" type=""number"" value=""40924922"" placeholder=""NPC Formwork ID"">
    <button onclick=""spawnNpc()"">Spawn</button>
  </div>

  <h3>Coordinates</h3>
  <div class=""coord-row"">
    <div><input id=""sx"" type=""number"" step=""0.01"" value=""1000"" placeholder=""X""></div>
    <div><input id=""sy"" type=""number"" step=""0.01"" value=""0"" placeholder=""Y""></div>
    <div><input id=""sz"" type=""number"" step=""0.01"" value=""2000"" placeholder=""Z""></div>
  </div>

  <pre id=""output"">Ready.</pre>
  <script>
    function coord() { return '&x='+document.getElementById('sx').value+'&y='+document.getElementById('sy').value+'&z='+document.getElementById('sz').value; }
    async function run(url) { const res=await fetch(url); document.getElementById('output').textContent=await res.text(); }
    function spawnEnemy() { run('/gm/spawn/enemy?enemyId='+document.getElementById('enemyId').value+coord()); }
    function spawnNpc() { run('/gm/spawn/npc?npcId='+document.getElementById('npcSpawnId').value+coord()); }
  </script>
</body>
</html>";
        }

        private static string BuildGmDebugUi()
        {
            return @"<!DOCTYPE html>
<html lang=""zh-CN"">
<head>
  <meta charset=""utf-8"">
  <title>GM Debug</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 600px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
    h1 { color: #00ff88; } h2 { color: #00cc66; }
    button { width: 100%; padding: 10px; margin: 6px 0; background: #00ff88; color: #000; border: 0; border-radius: 6px; cursor: pointer; font-weight: bold; }
    button:hover { background: #00cc66; } a { color: #00ff88; }
    pre { background: #2a2a2a; padding: 10px; border-radius: 4px; margin-top: 10px; }
    label { display: block; margin-top: 8px; color: #aaa; font-size: 13px; }
    .row { display: grid; grid-template-columns: 2fr 1fr; gap: 10px; }
  </style>
</head>
<body>
  <h1>🔧 GM Debug</h1>
  <a href='/gm/menu' style=""display:block;margin-bottom:20px;"">← Back to Menu</a>

  <button onclick=""run('/gm/debug/resetcooldowns')"">Reset Skill Cooldowns</button>
  <button onclick=""run('/gm/debug/opendebugpos')"">Open Debug Position</button>

  <h2>Toggles</h2>
  <div class=""row"">
    <span>Free Skill (no cooldowns)</span>
    <div><button onclick=""run('/gm/debug/freeskill?enable=1')"" style=""margin:2px;"">ON</button><button onclick=""run('/gm/debug/freeskill?enable=0')"" style=""margin:2px;"">OFF</button></div>
  </div>
  <div class=""row"">
    <span>Weapon Durability Free</span>
    <div><button onclick=""run('/gm/debug/durabilityfree?enable=1')"" style=""margin:2px;"">ON</button><button onclick=""run('/gm/debug/durabilityfree?enable=0')"" style=""margin:2px;"">OFF</button></div>
  </div>
  <div class=""row"">
    <span>NPC Auto-Spawn (scene load + phone)</span>
    <div><button onclick=""run('/gm/debug/npcautospawn/enable')"" style=""margin:2px;"">ON</button><button onclick=""run('/gm/debug/npcautospawn/disable')"" style=""margin:2px;"">OFF</button></div>
  </div>
  <div class=""row"">
    <span>Spawn Types (reconnect to apply)</span>
    <div style=""font-size:0.85em"">
      Static: <button onclick=""run('/gm/debug/spawntype/static/on')"">ON</button><button onclick=""run('/gm/debug/spawntype/static/off')"">OFF</button> &nbsp;
      Crowd: <button onclick=""run('/gm/debug/spawntype/crowd/on')"">ON</button><button onclick=""run('/gm/debug/spawntype/crowd/off')"">OFF</button> &nbsp;
      Traffic: <button onclick=""run('/gm/debug/spawntype/traffic/on')"">ON</button><button onclick=""run('/gm/debug/spawntype/traffic/off')"">OFF</button> &nbsp;
      Parked: <button onclick=""run('/gm/debug/spawntype/parked/on')"">ON</button><button onclick=""run('/gm/debug/spawntype/parked/off')"">OFF</button> &nbsp;
      Metro: <button onclick=""run('/gm/debug/spawntype/metro/on')"">ON</button><button onclick=""run('/gm/debug/spawntype/metro/off')"">OFF</button> &nbsp;
      <button onclick=""run('/gm/debug/spawntype/status')"">Status</button>
    </div>
  </div>

  <h2>Lua Error Collector</h2>
  <div class=""row"">
    <span>Collect Lua RPCs & errors</span>
    <div><button onclick=""run('/gm/debug/luaerrors/enable')"" style=""margin:2px;"">ON</button><button onclick=""run('/gm/debug/luaerrors/disable')"" style=""margin:2px;"">OFF</button></div>
  </div>
  <button onclick=""run('/gm/debug/luaerrors')"">View Collected Errors</button>
  <button onclick=""run('/gm/debug/luaerrors/export')"">Export to File</button>
  <button onclick=""run('/gm/debug/luaerrors/clear')"">Clear</button>

  <pre id=""output"">Ready.</pre>
  <script>
    async function run(url) { const res=await fetch(url); document.getElementById('output').textContent=await res.text(); }
  </script>
</body>
</html>";
        }

        private static string BuildGmWorldUi()
        {
            return @"<!DOCTYPE html>
<html lang=""zh-CN"">
<head>
  <meta charset=""utf-8"">
  <title>GM World</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 600px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
    h1 { color: #00ff88; } h2 { color: #00cc66; margin-top: 24px; }
    input { width: 100%; padding: 8px; margin: 4px 0; background: #2a2a2a; border: 1px solid #444; color: #e0e0e0; border-radius: 4px; }
    button { width: 100%; padding: 10px; margin: 6px 0; background: #00ff88; color: #000; border: 0; border-radius: 6px; cursor: pointer; font-weight: bold; }
    button:hover { background: #00cc66; } a { color: #00ff88; }
    pre { background: #2a2a2a; padding: 10px; border-radius: 4px; margin-top: 10px; }
    .row { display: grid; grid-template-columns: 2fr 1fr; gap: 10px; }
  </style>
</head>
<body>
  <h1>🌍 GM World</h1>
  <a href='/gm/menu' style=""display:block;margin-bottom:20px;"">← Back to Menu</a>

  <button onclick=""run('/gm/world/unlockfog')"">Unlock All Fog Map</button>
  <button onclick=""run('/gm/world/addallspirits')"">Add All Spirits</button>
  <button onclick=""run('/gm/world/addallvehicles')"">Add All Vehicles</button>

  <h2>Reputation</h2>
  <div class=""row"">
    <input id=""factionId"" type=""number"" value=""1"" placeholder=""Faction ID"">
    <input id=""repValue"" type=""number"" value=""100"" placeholder=""Value"">
  </div>
  <button onclick=""run('/gm/world/setreputation?factionId='+document.getElementById('factionId').value+'&value='+document.getElementById('repValue').value)"">Set Reputation</button>

  <pre id=""output"">Ready.</pre>
  <script>
    async function run(url) { const res=await fetch(url); document.getElementById('output').textContent=await res.text(); }
  </script>
</body>
</html>";
        }

        private static string BuildGmDumpUi()
        {
            return @"<!DOCTYPE html>
<html lang=""zh-CN"">
<head>
  <meta charset=""utf-8"">
  <title>GM RPC Dump</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 900px; margin: 40px auto; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
    h1 { color: #00ff88; } h2 { color: #00cc66; }
    button { padding: 10px 20px; margin: 6px; background: #00ff88; color: #000; border: 0; border-radius: 6px; cursor: pointer; font-weight: bold; }
    button:hover { background: #00cc66; } a { color: #00ff88; }
    pre { background: #0a0a1a; padding: 14px; border-radius: 6px; margin-top: 10px; overflow-x: auto; font-size: 12px; line-height: 1.4; border: 1px solid #333; }
    label { display: block; margin-top: 8px; color: #aaa; font-size: 13px; }
    .status { display: inline-block; padding: 4px 12px; border-radius: 12px; font-weight: bold; font-size: 13px; margin: 4px; }
    .on { background: #00ff88; color: #000; }
    .off { background: #444; color: #aaa; }
  </style>
</head>
<body>
  <h1>📊 RPC Dump & Debug Mode</h1>
  <a href='/gm/menu' style=""display:block;margin-bottom:20px;"">← Back to Menu</a>

  <div style=""margin:16px 0;"">
    <span>Debug Mode: </span>
    <span id=""debugStatus"" class=""status off"">OFF</span>
  </div>
  <div style=""margin:16px 0;"">
    <span>Captured: </span>
    <span id=""rpcCount"">0</span> unhandled RPCs
  </div>

  <div style=""margin:16px 0;"">
    <button onclick=""debugOn()"">🔊 Debug ON</button>
    <button onclick=""debugOff()"">🔇 Debug OFF</button>
    <button onclick=""refresh()"">🔄 Refresh View</button>
    <button onclick=""clearDump()"">🗑️ Clear Data</button>
    <button onclick=""exportDump()"">💾 Export to File</button>
  </div>

  <h2>Dump Report</h2>
  <pre id=""output"">Loading...</pre>

  <script>
    async function get(url) { const res=await fetch(url); return res.text(); }
    async function refresh() {
      document.getElementById('output').textContent = 'Loading...';
      document.getElementById('output').textContent = await get('/gm/dump/view?hex=1');
    }
    async function debugOn() {
      const result = await get('/gm/dump/debug_on');
      document.getElementById('debugStatus').textContent = 'ON';
      document.getElementById('debugStatus').className = 'status on';
      document.getElementById('output').textContent = result;
    }
    async function debugOff() {
      const result = await get('/gm/dump/debug_off');
      document.getElementById('debugStatus').textContent = 'OFF';
      document.getElementById('debugStatus').className = 'status off';
      document.getElementById('output').textContent = result;
    }
    async function clearDump() {
      document.getElementById('output').textContent = await get('/gm/dump/clear');
      refresh();
    }
    async function exportDump() {
      document.getElementById('output').textContent = await get('/gm/dump/export');
    }
    refresh();
    setInterval(refresh, 10000);
  </script>
</body>
</html>";
        }
    }
}
