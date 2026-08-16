using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using AnantaTestGameServer.Configs;
using AnantaTestGameServer.Methods.Return;

namespace AnantaTestGameServer
{
    public partial class Server
    {
        private static string BuildGmSpiritStatus(Connection conn)
        {
            var current = conn.GetCurrentSpirit();
            return string.Join(Environment.NewLine, new[]
            {
                $"Pid={conn.Pid}",
                $"CurrentSpirit={current.TemplateId} ({current.TemplateId})",
                $"CurrentSpiritInstanceId={current.Id}",
                $"TotalSpirits={conn.Spirits.Count}"
            });
        }

        private static string BuildGmSpiritUi()
        {
            // Character name mapping
            Dictionary<uint, string> spiritNames = new()
            {
                { 15020967, "Default Male" },
                { 15020968, "Default Female" },
                { 15020989, "Jiamu (嘉姆)" },
                { 15020991, "Banxi (班茜)" },
                { 15020992, "Tafi (塔菲)" },
                { 15020997, "Dila (狄菈)" },
                { 15021016, "Yalan (亚兰)" },
                { 15021017, "Mekanika (梅卡妮卡)" },
                { 15021020, "Krisitingna (克里斯蒂娜)" },
                { 15021021, "Lixi (里希)" },
                { 15021022, "Ringo" },
                { 15021023, "Saimo (赛默)" },
                { 15021024, "Ailin (爱琳)" },
                { 15021025, "Lakarya (莱卡娅)" },
                { 15021029, "Mimigu (弥弥古)" },
                { 15021038, "Ainomi (艾诺米)" },
                { 15021039, "Baijing (白靖)" },
                { 15022030, "Kesi (特摄战原型-科斯)" }
            };

            StringBuilder options = new();
            foreach (var spirit in Connection.GetDefaultSpirits())
            {
                string selected = spirit.TemplateId == 15020967 ? " selected" : "";
                string name = spiritNames.ContainsKey(spirit.TemplateId) ? spiritNames[spirit.TemplateId] : $"Spirit {spirit.TemplateId}";
                options.Append("<option value=\"")
                    .Append(spirit.TemplateId)
                    .Append("\"")
                    .Append(selected)
                    .Append(">")
                    .Append(name)
                    .Append(" (")
                    .Append(spirit.TemplateId)
                    .Append(")")
                    .AppendLine("</option>");
            }

            return $$"""
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Ananta GM Character Switch Tool</title>
  <style>
    :root {
      color-scheme: dark;
      --bg: #0b1020;
      --panel: #0f172a;
      --line: rgba(255,255,255,.12);
      --text: #e5e7eb;
      --muted: rgba(229,231,235,.72);
      --accent: #3b82f6;
      --accent-dark: #2563eb;
      --danger: #ef4444;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      background: radial-gradient(1200px 600px at 50% -10%, rgba(59,130,246,.15), transparent 60%), var(--bg);
      color: var(--text);
      font-family: "Microsoft YaHei", "Segoe UI", Arial, sans-serif;
    }
    main {
      width: min(1120px, calc(100vw - 32px));
      margin: 0 auto;
      padding: 28px 0 36px;
    }
    header {
      display: flex;
      align-items: flex-end;
      justify-content: space-between;
      gap: 16px;
      margin-bottom: 18px;
    }
    h1 {
      margin: 0;
      font-size: 30px;
      line-height: 1.2;
      letter-spacing: 0;
    }
    .sub {
      margin-top: 6px;
      color: var(--muted);
      font-size: 14px;
    }
    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
    }
    section {
      background: rgba(15,23,42,.9);
      border: 1px solid var(--line);
      border-radius: 10px;
      padding: 18px;
      box-shadow: 0 14px 34px rgba(0,0,0,.25);
      backdrop-filter: blur(6px);
    }
    h2 {
      margin: 0 0 14px;
      font-size: 18px;
      line-height: 1.3;
      letter-spacing: 0;
    }
    label {
      display: block;
      font-size: 13px;
      color: var(--muted);
      margin-bottom: 4px;
    }
    input[type="text"], input[type="number"], select {
      width: 100%;
      padding: 8px 10px;
      border: 1px solid var(--line);
      border-radius: 8px;
      font-size: 14px;
      color: var(--text);
      background: rgba(2,6,23,.35);
      outline: none;
      transition: border-color .15s;
    }
    input:focus, select:focus {
      border-color: var(--accent);
    }
    button {
      padding: 9px 18px;
      border: none;
      border-radius: 8px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      background: var(--accent);
      color: #fff;
      transition: background .15s;
    }
    button:hover { background: var(--accent-dark); }
    button.secondary {
      background: rgba(59,130,246,.14);
      color: var(--text);
      border: 1px solid rgba(59,130,246,.35);
    }
    button.secondary:hover { background: rgba(59,130,246,.22); }
    .row {
      display: grid;
      grid-template-columns: 1.2fr 0.8fr;
      gap: 10px;
      margin-bottom: 10px;
    }
    .quick {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      margin-bottom: 10px;
    }
    select {
      width: 100%;
      min-height: 200px;
      font-size: 13px;
    }
    .hint {
      font-size: 12px;
      color: var(--muted);
      margin-top: 8px;
    }
    pre {
      background: #020617;
      border: 1px solid var(--line);
      border-radius: 10px;
      padding: 12px;
      font-size: 13px;
      min-height: 80px;
      max-height: 200px;
      overflow-y: auto;
      color: #93c5fd;
    }
    .spirit-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
      gap: 8px;
      margin-bottom: 12px;
    }
    .spirit-btn {
      padding: 10px;
      border: 1px solid var(--line);
      border-radius: 8px;
      background: rgba(15,23,42,.6);
      cursor: pointer;
      font-size: 13px;
      text-align: center;
      transition: border-color .15s, background .15s;
    }
    .spirit-btn:hover {
      border-color: var(--accent);
      background: rgba(59,130,246,.12);
    }
    .spirit-btn .id {
      font-weight: 600;
      color: var(--accent);
    }
    @media (max-width: 768px) {
      .grid { grid-template-columns: 1fr; }
      .row { grid-template-columns: 1fr; }
      .spirit-grid { grid-template-columns: repeat(2, 1fr); }
    }
  </style>
{{GmStrings.GetI18nScript()}}
</head>
<body>
{{GmStrings.GetLangSelector()}}
  <main>
    <header>
      <div>
        <h1 data-t="characterTitle">Ananta GM Character Switch Tool</h1>
        <div class="sub" data-t="characterSub">Local GM character switch tool, port {{GameConfig.GmToolPort}}. Enter the game first.</div>
      </div>
      <button class="secondary" onclick="refreshStatus()" data-t="refreshStatus">Refresh Status</button>
    </header>

    <div class="grid">
      <section>
        <h2 data-t="charSelect">Character Selection</h2>
        <div class="row">
          <div>
            <label for="spiritSearch" data-t="searchOrEnterSpirit">Search or enter Spirit ID</label>
            <input id="spiritSearch" value="15020967" placeholder="e.g. 15020967">
          </div>
          <div>
            <label>&nbsp;</label>
            <button onclick="runSwitch()" data-t="switchChar">Switch Character</button>
          </div>
        </div>

        <div class="quick">
          <button class="secondary" onclick="pickSpirit('15020967')">Default Male</button>
          <button class="secondary" onclick="pickSpirit('15020968')">Default Female</button>
          <button class="secondary" onclick="pickSpirit('15020989')">Jiamu (嘉姆)</button>
          <button class="secondary" onclick="pickSpirit('15020991')">Banxi (班茜)</button>
          <button class="secondary" onclick="pickSpirit('15020992')">Tafi (塔菲)</button>
          <button class="secondary" onclick="pickSpirit('15020997')">Dila (狄菈)</button>
          <button class="secondary" onclick="pickSpirit('15021017')">Mekanika (梅卡妮卡)</button>
          <button class="secondary" onclick="pickSpirit('15021021')">Lixi (里希)</button>
          <button class="secondary" onclick="pickSpirit('15021023')">Saimo (赛默)</button>
          <button class="secondary" onclick="pickSpirit('15021022')">Ringo</button>
        </div>

        <div class="spirit-grid">
          <div class="spirit-btn" onclick="pickSpirit('15020967')"><span class="id">15020967</span><br>Default Male</div>
          <div class="spirit-btn" onclick="pickSpirit('15020968')"><span class="id">15020968</span><br>Default Female</div>
          <div class="spirit-btn" onclick="pickSpirit('15020989')"><span class="id">15020989</span><br>Jiamu (嘉姆)</div>
          <div class="spirit-btn" onclick="pickSpirit('15020991')"><span class="id">15020991</span><br>Banxi (班茜)</div>
          <div class="spirit-btn" onclick="pickSpirit('15020992')"><span class="id">15020992</span><br>Tafi (塔菲)</div>
          <div class="spirit-btn" onclick="pickSpirit('15020997')"><span class="id">15020997</span><br>Dila (狄菈)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021016')"><span class="id">15021016</span><br>Yalan (亚兰)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021017')"><span class="id">15021017</span><br>Mekanika (梅卡妮卡)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021020')"><span class="id">15021020</span><br>Krisitingna (克里斯蒂娜)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021021')"><span class="id">15021021</span><br>Lixi (里希)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021022')"><span class="id">15021022</span><br>Ringo</div>
          <div class="spirit-btn" onclick="pickSpirit('15021023')"><span class="id">15021023</span><br>Saimo (赛默)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021024')"><span class="id">15021024</span><br>Ailin (爱琳)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021025')"><span class="id">15021025</span><br>Lakarya (莱卡娅)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021029')"><span class="id">15021029</span><br>Mimigu (弥弥古)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021038')"><span class="id">15021038</span><br>Ainomi (艾诺米)</div>
          <div class="spirit-btn" onclick="pickSpirit('15021039')"><span class="id">15021039</span><br>Baijing (白靖)</div>
          <div class="spirit-btn" onclick="pickSpirit('15022030')"><span class="id">15022030</span><br>Kesi (特摄战原型-科斯)</div>
        </div>

        <label for="spiritList" data-t="allSpiritIds">All Spirit IDs</label>
        <select id="spiritList" size="8" onchange="pickSpirit(this.value)">
{{options}}
        </select>
        <div class="hint" data-t="clickCharHint">Click a character button or select from the list, then switch.</div>
      </section>

      <section>
        <h2 data-t="statusResults">Status & Results</h2>
        <pre id="output" data-t="waiting">Waiting...</pre>
      </section>
    </div>
  </main>

  <script>
    const output = document.getElementById('output');
    const spiritSearch = document.getElementById('spiritSearch');
    const spiritList = document.getElementById('spiritList');

    function pickSpirit(id) {
      spiritSearch.value = id;
      for (const option of spiritList.options) {
        option.selected = option.value === String(id);
      }
    }

    async function fetchText(url) {
      const response = await fetch(url, { cache: 'no-store' });
      const text = await response.text();
      if (!response.ok) throw new Error(text || response.statusText);
      return text;
    }

    async function runSwitch() {
      const spiritId = spiritSearch.value.trim();
      if (!spiritId) {
        output.textContent = '请输入 Spirit ID';
        return;
      }
      const url = '/gm/spirit/switch?spiritId=' + spiritId;
      await run(url);
    }

    async function run(url) {
      output.textContent = 'Requesting: ' + url;
      try {
        const text = await fetchText(url);
        output.textContent = text;
        setTimeout(refreshStatus, 300);
      } catch (error) {
        output.textContent = String(error.message || error);
      }
    }

    async function refreshStatus() {
      try {
        output.textContent = await fetchText('/gm/spirit/status');
      } catch (error) {
        output.textContent = String(error.message || error);
      }
    }

    spiritSearch.addEventListener('input', () => {
      const needle = spiritSearch.value.trim();
      for (const option of spiritList.options) {
        if (option.value.includes(needle)) {
          option.selected = true;
          break;
        }
      }
    });

    refreshStatus();
    setInterval(refreshStatus, 3000);
  </script>
</body>
</html>
""";
        }

        private static string BuildGmWeaponsStatus(Connection conn)
        {
            var currentSpirit = conn.GetCurrentSpirit();
            var currentWeaponIndex = conn.WeaponIndex;

            StringBuilder sb = new StringBuilder();
            sb.AppendLine($"Pid={conn.Pid}");
            sb.AppendLine($"CurrentSpirit={currentSpirit.TemplateId}");
            sb.AppendLine($"TotalWeapons={conn.Weapons.Count}");
            sb.AppendLine($"CurrentWeaponIndex={currentWeaponIndex}");

            if (conn.Weapons.Count == 0)
            {
                sb.AppendLine("No weapons in inventory.");
                return sb.ToString();
            }

            if (currentWeaponIndex < 0 || currentWeaponIndex >= conn.Weapons.Count)
            {
                currentWeaponIndex = 0;
            }

            var currentWeapon = conn.Weapons[currentWeaponIndex];
            sb.AppendLine($"CurrentWeaponTemplateId={currentWeapon.TemplateId}");
            sb.AppendLine($"CurrentWeaponInstanceId={currentWeapon.InstanceId}");
            sb.AppendLine($"CurrentWeaponDurability={currentWeapon.Durability}");
            sb.AppendLine("---Inventory---");
            for (int i = 0; i < conn.Weapons.Count; i++)
            {
                var w = conn.Weapons[i];
                string marker = (i == currentWeaponIndex) ? " *" : "";
                sb.AppendLine($"[{i}] TID={w.TemplateId} IID={w.InstanceId} DUR={w.Durability}{marker}");
            }
            
            sb.AppendLine();
            sb.AppendLine($"Total Spirits: {conn.Spirits.Count}");
            sb.AppendLine("---Spirits---");
            foreach (var spirit in conn.Spirits.TakeLast(10))
            {
                sb.AppendLine($"  TemplateId={spirit.TemplateId} InstanceId={spirit.Id}");
            }
            if (conn.Spirits.Count > 10)
            {
                sb.AppendLine($"  ... and {conn.Spirits.Count - 10} more");
            }

            return sb.ToString();
        }

        private static string BuildGmAddWeapon(Connection conn, Dictionary<string, string> query)
        {
            if (!query.ContainsKey("templateId"))
            {
                return "Missing templateId parameter.";
            }

            if (!uint.TryParse(query["templateId"], out uint templateId))
            {
                return "Invalid templateId parameter.";
            }

            // Verificar se a arma já existe no inventário
            if (conn.Weapons.Any(w => w.TemplateId == templateId))
            {
                return $"Weapon with TemplateId={templateId} already exists in inventory.";
            }

            // Criar uma nova arma com base no templateId
            var newWeapon = new WeaponDetail()
            {
                TemplateId = templateId,
                InstanceId = 600000000000UL + (ulong)conn.Weapons.Count + 1, // Gerar novo ID
                SpecialLabel = "",
                Durability = 10000,
                MagazineAmmo = 1000,
                EventId = 0,
                ReceivedTimeStamp = 0,
                OperatorFlags = 0,
                SourceAgentSpoonId = 0,
                SourceAgentId = 0,
                SourceSceneItemId = 0,
                SceneItemHp = 0
            };

            // Inicializar WeaponFlags corretamente
            newWeapon.WeaponFlags = new WeaponDataFlags()
            {
                IsTaskWheelWeapon = false,
                ShowRedDot = false,
                AdditionalEffectIds = new List<int>()
            };
            
            conn.Weapons.Add(newWeapon);
            conn.SyncWeapons(); // Sincronizar as armas com o cliente
            
            return $"Added weapon with TemplateId={templateId}, InstanceId={newWeapon.InstanceId} to player inventory.";
        }

        private static string BuildGmWeaponsUi()
        {
            return $$"""
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Ananta GM Weapons</title>
  <style>
    :root { --bg:#0b1020; --line:rgba(255,255,255,.12); --text:#e5e7eb; --muted:rgba(229,231,235,.72); --accent:#3b82f6; --green:#22c55e; --red:#ef4444; --purple:#8b5cf6; }
    * { box-sizing:border-box; }
    body { margin:0; background:var(--bg); color:var(--text); font-family:"Segoe UI",Arial,sans-serif; }
    main { max-width:1100px; margin:0 auto; padding:20px; }
    h1 { font-size:24px; margin:0 0 4px; }
    h2 { font-size:16px; margin:0 0 10px; }
    .sub { color:var(--muted); font-size:13px; margin-bottom:16px; }
    .grid { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
    section { background:rgba(15,23,42,.9); border:1px solid var(--line); border-radius:8px; padding:14px; }
    .full { grid-column:1/-1; }
    button { padding:6px 12px; border:none; border-radius:6px; font-size:12px; font-weight:600; cursor:pointer; color:#fff; }
    .btn-add { background:var(--green); } .btn-add:hover { opacity:.85; }
    .btn-equip { background:var(--accent); } .btn-equip:hover { opacity:.85; }
    .btn-rm { background:var(--red); } .btn-rm:hover { opacity:.85; }
    .btn-all { background:var(--purple); } .btn-all:hover { opacity:.85; }
    .btn-sec { background:rgba(59,130,246,.15); color:var(--text); border:1px solid rgba(59,130,246,.3); }
    input { padding:6px 8px; border:1px solid var(--line); border-radius:6px; font-size:13px; color:var(--text); background:rgba(2,6,23,.4); width:80px; }
    pre { background:#020617; border:1px solid var(--line); border-radius:8px; padding:10px; font-size:12px; max-height:250px; overflow-y:auto; color:#93c5fd; white-space:pre-wrap; }
    .cat-item { display:flex; align-items:center; padding:5px 8px; border:1px solid var(--line); border-radius:5px; margin-bottom:3px; font-size:12px; gap:6px; }
    .cat-item:hover { border-color:var(--accent); }
    .cat-tid { color:var(--muted); font-size:11px; min-width:65px; }
    .cat-name { flex:1; }
    .inv-item { display:flex; align-items:center; padding:6px 8px; border:1px solid var(--line); border-radius:5px; margin-bottom:3px; font-size:12px; gap:6px; }
    .inv-item.eq { border-color:var(--green); background:rgba(34,197,94,.08); }
    .inv-idx { font-weight:700; min-width:28px; }
    .inv-info { flex:1; }
    .hdr { display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; }
    .hdr-btns { display:flex; gap:6px; }
    .label { font-size:10px; text-transform:uppercase; color:var(--muted); letter-spacing:1px; margin-bottom:6px; }
    .manual { display:flex; gap:6px; align-items:center; margin-top:8px; }
    @media(max-width:768px) { .grid { grid-template-columns:1fr; } }
  </style>
</head>
<body>
<main>
  <div class="hdr">
    <div><h1>Weapons Panel</h1><div class="sub">Port {{GameConfig.GmToolPort}} - Enter game first</div></div>
    <div class="hdr-btns">
      <button class="btn-sec" onclick="refresh()">Refresh</button>
      <button class="btn-all" onclick="addAll()">+ Add All</button>
      <button class="btn-rm" onclick="removeAll()">Remove All</button>
    </div>
  </div>
  <div class="grid">
    <section>
      <h2>Your Inventory</h2>
      <div class="label">Click Equip/Remove on any weapon below</div>
      <div id="inv" style="max-height:420px;overflow-y:auto;"></div>
      <div class="manual">
        <span style="font-size:12px;">Manual index:</span>
        <input id="invIdx" value="0" type="number" min="0">
        <button class="btn-equip" onclick="doSwitch()">Equip</button>
        <button class="btn-rm" onclick="doRemove()">Remove</button>
      </div>
    </section>
    <section>
      <h2>Weapon Catalog</h2>
      <div class="label">Click + to add a weapon to your inventory</div>
      <input id="catSearch" type="text" placeholder="Search..." oninput="filterCat(this.value)" style="width:100%;margin-bottom:8px;">
      <div id="cat" style="max-height:420px;overflow-y:auto;"></div>
    </section>
    <section class="full">
      <h2>Status / Log</h2>
      <pre id="log">Ready.</pre>
    </section>
  </div>
</main>
<script>
const C=[
[98003001,'Bat'],[98003023,'Hammer'],[98003131,'Claws L'],[98003132,'Claws R'],
[98003184,'Fists'],[98003185,'Wrapped Hand'],[98005002,'Crowbar'],[98005003,'Wrench'],
[98005004,'Pipe Wrench'],[98005005,'Baseball Bat'],[98005006,'Claw Hammer'],[98005007,'Metal Pipe'],
[98005009,'Sign'],[98005010,'Heavy Hammer'],[98005012,'Eclipse'],[98005013,'Fan'],
[98005014,'Tactical Baton'],[98005016,'Pool Cue'],[98005017,'Cone Rod'],[98005019,'SMG'],
[98005020,'Sniper'],[98005021,'Rocket'],[98005022,'Heavy Cannon'],[98005023,'Golf Club'],
[98005024,'Flamethrower'],[98005025,'Freeze Gun'],[98005028,'Milk Box'],[98005029,'Taser'],
[98005030,'Water Gun S'],[98005033,'Spray Gun S'],[98005034,'Flat Gun S'],[98005039,'Ice Pick'],
[98005041,'Wall Hammer'],[98005042,'Shovel'],[98005043,'Drying Fork'],[98005044,'Dagger'],
[98005045,'E-Baton'],[98005051,'Water Gun M'],[98005052,'Water Gun L'],[98005053,'Spray M'],
[98005054,'Spray L'],[98005055,'Flat M'],[98005056,'Flat L'],[98005057,'Cleaner 1'],
[98005058,'Cleaner 2'],[98005059,'Cleaner 3'],[98005060,'Cleaner 4'],[98005061,'Cleaner 5'],
[98005062,'Cleaner 6'],[98005066,'Screwdriver'],[98005067,'Pink Fish'],[98005068,'Garden Saw'],
[98005069,'Break Hammer'],[98005070,'Steel Hammer'],[98005071,'HV Baton'],[98005072,'Welding Gun'],
[98005073,'Tactical Fork'],[98005075,'Tall Saw'],[98005076,'Meat Cleaver'],[98005077,'Spiral'],
[98005078,'Steel Bass'],[98005079,'Saw Axe'],[98005080,'Titan Hammer'],[98005081,'Vortex Hammer'],
[98005082,'Fork'],[98005083,'Fine Fork'],[98005084,'Fish'],[98005085,'Gold Fish'],
[98005086,'Alloy Screwdriver'],[98005087,'Cute Screwdriver'],[98005088,'Good Voice'],[98005089,'Match Point'],
[98005090,'Blizzard'],[98005091,'Dark Gold'],[98005092,'Heartbeat'],[98005093,'Death Loop'],
[98005094,'Meka Rocket'],[98005095,'Meka Cannon'],[98005500,'Riddle Crowbar'],[98005501,'Riddle Sniper'],
[98005502,'Riddle Rocket'],[98005504,'Ultimate Cannon'],[98005505,'Eye Bass'],[98005506,'Strong Guitar'],
[98005507,'Layoff Axe'],[98005508,'Reveal Hammer'],[98005509,'Lunch Shield'],[98005511,'Behavior Stick'],
[98005512,'Black Gold Hammer'],[98005513,'Metal Stream'],[98005514,'Riddle Dual'],[98005515,'Question Shield'],
[98005516,'Solve SMG'],[98005517,'Fan Shield'],[98005518,'Sabbath Rocket'],[98005519,'Staple Gun'],
[98005520,'Office Comfort'],[98005521,'Precision Gun'],[98005523,'Thin Shield'],[98005531,'W5531'],
[98005533,'W5533'],[98005538,'W5538'],[98005547,'W5547'],[98005551,'W5551'],[98005552,'W5552'],
[98005556,'W5556'],[98005557,'W5557'],[98005558,'W5558'],[98005559,'W5559'],[98005562,'W5562'],
[98005564,'W5564'],[98005567,'W5567'],[98005568,'W5568'],[98005572,'W5572'],[98005573,'W5573'],
[98005575,'W5575'],[98005577,'W5577'],[98005578,'W5578'],[98005582,'W5582'],[98005586,'W5586'],
[98005587,'Robot Vacuum'],[98005588,'W5588'],[98005589,'W5589'],[98005590,'Gallery Arm'],
[98006001,'PengPeng Proto'],[98006006,'SMG 2'],[98006009,'Graffiti Sniper'],[98006016,'PengPeng 1'],
[98006020,'Dream SMG'],[98006024,'SMG 3'],[98006025,'SMG 4'],[98006026,'Flashlight'],
[98006028,'Robot Dog'],[98006031,'Tennis'],[98006037,'Kos SMG'],[98006042,'Game Water'],
[98006043,'Graffiti SMG'],[98006102,'Handbag'],[98006103,'Snack Pack'],[98006104,'Coffee'],
[98006105,'Craft Beer'],[98006106,'Gift Box'],[98006107,'Popcorn'],[98006108,'Heart Gift'],
[98006109,'Dim Sum'],[98006110,'Ice Cream'],[98006111,'Sandwich'],[98006112,'Hot Dog'],
[98006114,'Crash Head'],[98006117,'Tea Tray'],[98006118,'Milk'],[98006300,'Heavy Hammer 2'],
[98006301,'Pool Cue 2'],[98006302,'Dagger 2'],[98007000,'McD Bag'],[98007001,'Whale Skeleton'],[98007002,'Slime Bucket']
];
const T={98003001:1,98003023:3,98003131:5,98003132:5,98003184:5,98003185:5,98005002:1,98005003:1,98005004:1,98005005:1,98005006:1,98005007:1,98005009:2,98005010:3,98005012:1,98005013:3,98005014:1,98005016:2,98005017:2,98005019:6,98005020:6,98005021:6,98005022:6,98005023:1,98005024:6,98005025:6,98005028:6,98005029:6,98005030:6,98005033:6,98005034:6,98005039:1,98005041:3,98005042:2,98005043:2,98005044:1,98005045:1,98005051:6,98005052:6,98005053:6,98005054:6,98005055:6,98005056:6,98005057:6,98005058:6,98005059:6,98005060:6,98005061:6,98005062:6,98005066:4,98005067:4,98005068:2,98005069:3,98005070:3,98005071:1,98005072:1,98005073:2,98005075:2,98005076:2,98005077:2,98005078:3,98005079:3,98005080:3,98005081:3,98005082:4,98005083:4,98005084:4,98005085:4,98005086:4,98005087:4,98005088:4,98005089:6,98005090:6,98005091:6,98005092:6,98005093:6,98005094:6,98005095:6,98005500:1,98005501:6,98005502:6,98005504:6,98005505:3,98005506:1,98005507:3,98005508:3,98005509:6,98005511:1,98005512:6,98005513:6,98005514:6,98005515:6,98005516:6,98005517:6,98005518:6,98005519:6,98005520:6,98005521:6,98005523:6,98005531:6,98005533:6,98005538:6,98005547:6,98005551:6,98005552:6,98005556:6,98005557:6,98005558:6,98005559:6,98005562:6,98005564:6,98005567:6,98005568:6,98005572:6,98005573:6,98005575:6,98005577:6,98005578:6,98005582:6,98005586:6,98005587:6,98005588:6,98005589:6,98005590:3,98006001:6,98006006:6,98006009:6,98006016:6,98006020:6,98006024:6,98006025:6,98006026:6,98006028:6,98006031:6,98006037:6,98006042:6,98006043:6,98006102:6,98006103:6,98006104:6,98006105:6,98006106:6,98006107:6,98006108:6,98006109:6,98006110:6,98006111:6,98006112:6,98006114:6,98006117:6,98006118:6,98006300:3,98006301:2,98006302:4,98007000:6,98007001:6,98007002:6};
const CN={1:'Blunt / Strike',2:'Long / Reach',3:'Heavy',4:'Small / Light',5:'Unarmed / Fist',6:'Ranged / Special'};
let activeFilter=0;
const log=document.getElementById('log');
function buildCat(){
  let h='<div style="display:flex;gap:4px;flex-wrap:wrap;margin-bottom:10px;">';
  h+='<button class="btn-sec" style="font-size:11px;padding:4px 8px;'+(activeFilter===0?'border-color:var(--accent);':'')+'" onclick="setFilter(0)">All ('+C.length+')</button>';
  [1,2,3,4,5,6].forEach(t=>{
    const cnt=C.filter(([tid])=>T[tid]===t).length;
    h+='<button class="btn-sec" style="font-size:11px;padding:4px 8px;'+(activeFilter===t?'border-color:var(--accent);':'')+'" onclick="setFilter('+t+')">'+CN[t]+' ('+cnt+')</button>';
  });
  h+='</div>';
  C.forEach(([tid,n])=>{
    const tp=T[tid]||0;
    const show=activeFilter===0||tp===activeFilter;
    h+='<div class="cat-item" data-s="'+n.toLowerCase()+' '+tid+'" data-tp="'+tp+'" style="'+(show?'':'display:none;')+'"><span class="cat-tid">'+tid+'</span><span class="cat-name">'+n+'</span><button class="btn-add" onclick="addW('+tid+')">+</button></div>';
  });
  document.getElementById('cat').innerHTML=h;
}
function setFilter(t){activeFilter=t;buildCat();}
function filterCat(q){q=q.toLowerCase();document.querySelectorAll('.cat-item').forEach(e=>{const match=!q||e.dataset.s.includes(q);const tpMatch=activeFilter===0||parseInt(e.dataset.tp)===activeFilter;e.style.display=(match&&tpMatch)?'':'none';});}
async function api(url){
  log.textContent='Loading: '+url;
  try{const r=await fetch(url,{cache:'no-store'});const t=await r.text();log.textContent=t;return r.ok;}catch(e){log.textContent='Error: '+e.message;return false;}
}
async function addW(tid){if(await api('/gm/weapons/add?templateId='+tid))setTimeout(refresh,300);}
async function addAll(){if(await api('/gm/weapons/addall'))setTimeout(refresh,300);}
async function doSwitch(){const i=document.getElementById('invIdx').value;if(await api('/gm/weapons/switch?index='+i))setTimeout(refresh,300);}
async function doRemove(){const i=document.getElementById('invIdx').value;if(await api('/gm/weapons/remove?index='+i))setTimeout(refresh,300);}
async function removeAll(){if(!confirm('Remove ALL weapons?'))return;if(await api('/gm/weapons/removeall'))setTimeout(refresh,300);}
async function refresh(){
  try{
    const t=await(await fetch('/gm/weapons/status',{cache:'no-store'})).text();
    log.textContent=t;
    const el=document.getElementById('inv');
    let h='';
    t.split('\n').forEach(line=>{
      const m=line.match(/^\[(\d+)\]\s*TID=(\d+)\s*IID=(\d+)\s*DUR=(-?\d+)(\s*\*)?$/);
      if(m){
        const eq=m[5]===' *';
        const name=(C.find(c=>c[0]==m[2])||[])[1]||'?';
        h+=`<div class="inv-item${eq?' eq':''}"><span class="inv-idx">[${m[1]}]</span><span class="inv-info"><b>${name}</b> <span style="color:var(--muted);font-size:11px;">${m[2]} dur=${m[4]}</span></span><button class="btn-equip" onclick="document.getElementById('invIdx').value=${m[1]};doSwitch()">Equip</button><button class="btn-rm" onclick="document.getElementById('invIdx').value=${m[1]};doRemove()">Remove</button></div>`;
      }
    });
    el.innerHTML=h||'<div style="color:var(--muted);font-size:13px;">Empty inventory. Add from catalog.</div>';
  }catch(e){}
}
buildCat();refresh();setInterval(refresh,5000);
</script>
</body>
</html>
""";
        }

        private static string BuildGmRemoveWeapon(Connection conn, Dictionary<string, string> query)
        {
            if (!query.ContainsKey("index"))
            {
                return "Missing index parameter. Use the inventory index from the Status panel.";
            }

            if (!int.TryParse(query["index"], out int index))
            {
                return "Invalid index parameter.";
            }

            if (conn.Weapons.Count == 0)
            {
                return "No weapons in inventory to remove.";
            }

            if (index < 0 || index >= conn.Weapons.Count)
            {
                return $"Invalid weapon index {index}. Valid range: 0-{conn.Weapons.Count - 1}";
            }

            WeaponDetail weaponToRemove = conn.Weapons[index];
            ulong instanceId = weaponToRemove.InstanceId;
            uint templateId = weaponToRemove.TemplateId;

            conn.Weapons.RemoveAt(index);

            // Adjust WeaponIndex if needed
            if (conn.WeaponIndex >= conn.Weapons.Count && conn.Weapons.Count > 0)
                conn.WeaponIndex = conn.Weapons.Count - 1;
            else if (conn.Weapons.Count == 0)
                conn.WeaponIndex = 0;

            conn.SyncWeapons();

            return $"Removed weapon [{index}] TID={templateId} IID={instanceId}. Remaining: {conn.Weapons.Count} weapons.";
        }
    }
}
