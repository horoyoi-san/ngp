using System;
using System.Collections.Generic;
using System.Text;
using AnantaTestGameServer.Configs;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer
{
    public partial class Server
    {
        private static string BuildGmSpawnNpc(Connection conn, Dictionary<string, string> query)
        {
            if (!query.ContainsKey("npcId"))
            {
                return "Missing npcId parameter.";
            }

            if (!uint.TryParse(query["npcId"], out uint npcId))
            {
                return "Invalid npcId parameter.";
            }

            try
            {
                // Enviar comando para spawnar NPC
                UxRpcMessage msg = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcAddData
                };

                // Criar dados do NPC usando o tipo correto
                ClientStaticNpcInitData npcData = new ClientStaticNpcInitData()
                {
                    Id = (ulong)new Random().NextInt64(),
                    StaticNpcInfoId = (ulong)npcId,
                    NpcFormworkId = npcId,
                    AgentPersonaId = 45200058,
                    NpcPid = (int)npcId,
                    UrbanDiversityId = 88888000,
                    PoiActionId = 0,
                    Position = conn.LastKnownPlayerPosition ?? new UXVector3() { X = 1003, Y = 0, Z = 2000 },
                    AgentSyncClientInfo = new AgentSyncClientInfo()
                    {
                        stimIDList = new int[0],
                        CanBeExaminedByPolice = true,
                        indoorList = new(),
                        roomIds = new int[0],
                        SpoonAgentId = (int)npcId,
                        treeName = "",
                        petPerformData = "",
                        spawnEffectId = new uint[0],
                        randomModelCfgId = 0,
                        LeaveDistance = 10000,
                        approachDistance = 10000,
                        FashionSuitId = 11190001,
                    }
                };

                msg.SetArgs(MethodId.SyncAetherAIStaticNpcAddData, npcData);
                conn.SendPacket(msg);

                return $"Spawned NPC with ID={npcId} at player position.";
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GM] Error spawning NPC {npcId}: {ex.Message}");
                return $"Failed to spawn NPC with ID={npcId}: {ex.Message}";
            }
        }

        private static string BuildGmSpawnAllNpcs(Connection conn)
        {
            uint[] npcIds = Game.State.NpcStateFactory.BuildNpcFormworkIds();

            if (npcIds == null || npcIds.Length == 0)
            {
                return "No NPCs available to spawn. The NPC list is empty.";
            }

            int spawned = 0;
            foreach (uint npcId in npcIds)
            {
                try
                {
                    UxRpcMessage msg = new UxRpcMessage()
                    {
                        Mode = UxRpcPacketMode.Notify,
                        RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcAddData
                    };

                    ClientStaticNpcInitData npcData = new ClientStaticNpcInitData()
                    {
                        Id = (ulong)new Random().NextInt64(),
                        StaticNpcInfoId = (ulong)npcId,
                        NpcFormworkId = npcId,
                        AgentPersonaId = 45200058,
                        NpcPid = (int)npcId,
                        UrbanDiversityId = 88888000,
                        PoiActionId = 0,
                        Position = conn.LastKnownPlayerPosition ?? new UXVector3() { X = 1003, Y = 0, Z = 2000 },
                        AgentSyncClientInfo = new AgentSyncClientInfo()
                        {
                            stimIDList = new int[0],
                            CanBeExaminedByPolice = true,
                            indoorList = new(),
                            roomIds = new int[0],
                            SpoonAgentId = (int)npcId,
                            treeName = "",
                            petPerformData = "",
                            spawnEffectId = new uint[0],
                            randomModelCfgId = 0,
                            LeaveDistance = 10000,
                            approachDistance = 10000,
                            FashionSuitId = 11190001,
                        }
                    };

                    msg.SetArgs(MethodId.SyncAetherAIStaticNpcAddData, npcData);
                    conn.SendPacket(msg);
                    spawned++;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[GM] Error spawning NPC {npcId}: {ex.Message}");
                }
            }

            return $"Spawned {spawned}/{npcIds.Length} NPCs at player position.";
        }

        private static string BuildGmNpcsUi()
        {
            var npcIds = Game.State.NpcStateFactory.BuildNpcFormworkIds();

            var npcNames = new Dictionary<uint, string>()
            {
                { 40923169, "Mecha Silver" },
                { 40923324, "Mecha Yellow" },
                { 40924600, "Old Man Statue" },
                { 40924701, "Chainsaw Car" },
                { 40924922, "Turbo Rampager" },
                { 40951000, "Monk" },
                { 40966121, "Mascot Thing" },
                { 40966210, "Hot Dog Guy" },
                { 40968615, "Slime" },
                { 40968618, "Woman in Swimsuit" },
                { 40968628, "Child" },
                { 40968659, "Maid Cafe Girl" },
            };

            StringBuilder npcOptions = new();
            foreach (uint npcId in npcIds)
            {
                string name = npcNames.TryGetValue(npcId, out string? n) ? n : "Unknown";
                npcOptions.Append("<option value=\"")
                    .Append(npcId)
                    .Append("\">")
                    .Append(npcId)
                    .Append(" - ")
                    .Append(name)
                    .AppendLine("</option>");
            }

            return "<!doctype html>\n" +
"<html lang=\"zh-CN\">\n" +
"<head>\n" +
"  <meta charset=\"utf-8\">\n" +
"  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n" +
"  <title>Ananta GM NPC Panel</title>\n" +
"  <style>\n" +
"    :root {\n" +
"      color-scheme: dark;\n" +
"      --bg: #0b1020;\n" +
"      --panel: #0f172a;\n" +
"      --line: rgba(255,255,255,.12);\n" +
"      --text: #e5e7eb;\n" +
"      --muted: rgba(229,231,235,.72);\n" +
"      --accent: #22c55e;\n" +
"      --accent-dark: #16a34a;\n" +
"      --danger: #ef4444;\n" +
"    }\n" +
"    * { box-sizing: border-box; }\n" +
"    body {\n" +
"      margin: 0;\n" +
"      min-height: 100vh;\n" +
"      background: radial-gradient(1200px 600px at 50% -10%, rgba(34,197,94,.18), transparent 60%), var(--bg);\n" +
"      color: var(--text);\n" +
"      font-family: \"Microsoft YaHei\", \"Segoe UI\", Arial, sans-serif;\n" +
"    }\n" +
"    main {\n" +
"      width: min(1120px, calc(100vw - 32px));\n" +
"      margin: 0 auto;\n" +
"      padding: 28px 0 36px;\n" +
"    }\n" +
"    header {\n" +
"      display: flex;\n" +
"      align-items: flex-end;\n" +
"      justify-content: space-between;\n" +
"      gap: 16px;\n" +
"      margin-bottom: 18px;\n" +
"    }\n" +
"    h1 {\n" +
"      margin: 0;\n" +
"      font-size: 30px;\n" +
"      line-height: 1.2;\n" +
"      letter-spacing: 0;\n" +
"    }\n" +
"    .sub { margin-top: 6px; color: var(--muted); font-size: 14px; }\n" +
"    .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }\n" +
"    section {\n" +
"      background: rgba(15,23,42,.9);\n" +
"      border: 1px solid var(--line);\n" +
"      border-radius: 10px;\n" +
"      padding: 18px;\n" +
"      box-shadow: 0 14px 34px rgba(0,0,0,.25);\n" +
"      backdrop-filter: blur(6px);\n" +
"    }\n" +
"    h2 { margin: 0 0 14px; font-size: 18px; letter-spacing: 0; }\n" +
"    label { display: block; font-size: 13px; color: var(--muted); margin-bottom: 6px; font-weight: 700; }\n" +
"    input, select {\n" +
"      width: 100%;\n" +
"      height: 40px;\n" +
"      border: 1px solid var(--line);\n" +
"      border-radius: 8px;\n" +
"      padding: 0 12px;\n" +
"      background: rgba(2,6,23,.35);\n" +
"      color: var(--text);\n" +
"      outline: none;\n" +
"      font: inherit;\n" +
"    }\n" +
"    select { min-height: 220px; padding: 8px; }\n" +
"    .row { display: grid; grid-template-columns: 1fr 120px; gap: 10px; margin-bottom: 12px; }\n" +
"    .row-wide { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; margin-bottom: 12px; }\n" +
"    .quick { display:flex; flex-wrap:wrap; gap: 8px; margin: 8px 0 14px; }\n" +
"    button {\n" +
"      min-height: 42px;\n" +
"      border: 0;\n" +
"      border-radius: 8px;\n" +
"      padding: 0 14px;\n" +
"      background: var(--accent);\n" +
"      color: #052e14;\n" +
"      font-weight: 800;\n" +
"      font-size: 14px;\n" +
"      cursor: pointer;\n" +
"    }\n" +
"    button:hover { background: var(--accent-dark); }\n" +
"    button.secondary { background: rgba(34,197,94,.14); color: var(--text); border: 1px solid rgba(34,197,94,.35); }\n" +
"    button.secondary:hover { background: rgba(34,197,94,.22); }\n" +
"    button.danger { background: var(--danger); color: #fff; }\n" +
"    button.danger:hover { filter: brightness(.9); }\n" +
"    .hint { margin-top: 10px; color: var(--muted); font-size: 13px; line-height: 1.5; }\n" +
"    pre {\n" +
"      margin: 0;\n" +
"      min-height: 140px;\n" +
"      white-space: pre-wrap;\n" +
"      word-break: break-word;\n" +
"      border-radius: 10px;\n" +
"      border: 1px solid var(--line);\n" +
"      background: #020617;\n" +
"      color: #c7d2fe;\n" +
"      padding: 13px;\n" +
"      font: 13px/1.5 Consolas, \"Courier New\", monospace;\n" +
"    }\n" +
"    @media (max-width: 880px) { .grid { grid-template-columns: 1fr; } }\n" +
"  </style>\n" +
GmStrings.GetI18nScript() + "\n" +
"</head>\n" +
"<body>\n" +
GmStrings.GetLangSelector() + "\n" +
"  <main>\n" +
"    <header>\n" +
"      <div>\n" +
"        <h1 data-t=\"npcTitle\">Ananta GM NPC Panel</h1>\n" +
"        <div class=\"sub\" data-t=\"npcSub\">Port " + GameConfig.GmToolPort + " - Enter the game first</div>\n" +
"      </div>\n" +
"      <button class=\"secondary\" onclick=\"refreshStatus()\" data-t=\"refreshStatus\">Refresh Status</button>\n" +
"    </header>\n" +
"\n" +
"    <div class=\"grid\">\n" +
"      <section>\n" +
"        <h2 data-t=\"npcSelect\">NPC Selection</h2>\n" +
"        <div class=\"row\">\n" +
"          <div>\n" +
"            <label for=\"npcSearch\" data-t=\"searchOrEnterNpc\">Search or enter NPC Formwork ID</label>\n" +
"            <input id=\"npcSearch\" placeholder=\"e.g. 40923169\">\n" +
"          </div>\n" +
"          <div>\n" +
"            <label>&nbsp;</label>\n" +
"            <button onclick=\"spawnNpc()\" data-t=\"spawnNpc\">Spawn NPC</button>\n" +
"          </div>\n" +
"        </div>\n" +
"\n" +
"        <div class=\"quick\">\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40923169')\">Mecha Silver</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40923324')\">Mecha Yellow</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40924600')\">Old Man</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40924701')\">Chainsaw</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40924922')\">Rampager</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40951000')\">Monk</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40966121')\">Mascot</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40966210')\">Hot Dog</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40968615')\">Slime</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40968628')\">Child</button>\n" +
"          <button class=\"secondary\" onclick=\"pickNpc('40968659')\">Maid Cafe</button>\n" +
"        </div>\n" +
"\n" +
"        <label for=\"npcList\" data-t=\"npcFormworkIds\">NPC Formwork IDs</label>\n" +
"        <select id=\"npcList\" size=\"8\" onchange=\"pickNpc(this.value)\">\n" +
"          " + npcOptions.ToString() + "\n" +
"        </select>\n" +
"\n" +
"        <div class=\"coords\" style=\"margin-top:14px; padding-top:14px; border-top:1px solid var(--line); display:grid; grid-template-columns:repeat(4,1fr); gap:10px;\">\n" +
"          <label class=\"check\" style=\"display:flex; align-items:center; gap:8px; color:var(--muted); font-size:13px; font-weight:600;\">\n" +
"            <input id=\"useCoords\" type=\"checkbox\" style=\"width:16px; height:16px; accent-color:var(--accent);\">\n" +
"            <span data-t=\"specifyCoords\">Specify Coordinates</span>\n" +
"          </label>\n" +
"          <div><label for=\"x\">X</label><input id=\"x\" type=\"number\" step=\"0.01\"></div>\n" +
"          <div><label for=\"y\">Y</label><input id=\"y\" type=\"number\" step=\"0.01\"></div>\n" +
"          <div><label for=\"z\">Z</label><input id=\"z\" type=\"number\" step=\"0.01\"></div>\n" +
"        </div>\n" +
"        <div class=\"hint\" data-t=\"coordDefaultHint\">Leave coordinates empty to use default position (1003, 0, 2000).</div>\n" +
"      </section>\n" +
"\n" +
"      <section>\n" +
"        <h2 data-t=\"gmOperations\">GM Operations</h2>\n" +
"        <div class=\"row\" style=\"grid-template-columns:1fr 1fr;\">\n" +
"          <button onclick=\"spawnNpc()\" style=\"margin-bottom:8px;\" data-t=\"spawnNpc\">Spawn NPC</button>\n" +
"          <button class=\"secondary\" onclick=\"spawnBatch()\" style=\"margin-bottom:8px;\" data-t=\"spawnAll\">Spawn All</button>\n" +
"        </div>\n" +
"        <div class=\"row\" style=\"grid-template-columns:1fr 1fr;\">\n" +
"          <button class=\"secondary\" onclick=\"refreshNpcs()\" style=\"margin-bottom:8px;\" data-t=\"refreshNpcs\">Refresh Spawn</button>\n" +
"          <button class=\"danger\" onclick=\"destroyNpcs()\" style=\"margin-bottom:8px;\" data-t=\"destroyAllNpcs\">Destroy All NPCs</button>\n" +
"        </div>\n" +
"        <h2 style=\"margin-top:18px;\">NPC Manipulation</h2>\n" +
"        <div class=\"row\" style=\"grid-template-columns:1fr 1fr;\">\n" +
"          <div><label for=\"npcEntityId\">NPC EntityId</label><input id=\"npcEntityId\" type=\"number\" placeholder=\"Enter EntityId\"></div>\n" +
"          <div><label for=\"npcState\">State</label>\n" +
"            <select id=\"npcState\">\n" +
"              <option value=\"Idle\">Idle</option>\n" +
"              <option value=\"Walking\">Walking</option>\n" +
"              <option value=\"Running\">Running</option>\n" +
"              <option value=\"Shopping\">Shopping</option>\n" +
"              <option value=\"Talking\">Talking</option>\n" +
"              <option value=\"Combat\">Combat</option>\n" +
"              <option value=\"Fleeing\">Fleeing</option>\n" +
"              <option value=\"Celebrating\">Celebrating</option>\n" +
"            </select>\n" +
"          </div>\n" +
"        </div>\n" +
"        <div class=\"row\" style=\"grid-template-columns:1fr 1fr 1fr;\">\n" +
"          <button class=\"secondary\" onclick=\"teleportToNpc()\">Teleport To NPC</button>\n" +
"          <button class=\"secondary\" onclick=\"setNpcState()\">Set State</button>\n" +
"          <button class=\"danger\" onclick=\"destroyNpcOne()\">Destroy NPC</button>\n" +
"        </div>\n" +
"        <div class=\"row\" style=\"margin-top:8px;\">\n" +
"          <button class=\"secondary\" onclick=\"listNpcs()\">List All NPCs (JSON)</button>\n" +
"        </div>\n" +
"        <h2 style=\"margin-top:18px;\" data-t=\"statusResults\">Status & Results</h2>\n" +
"        <pre id=\"output\" data-t=\"waiting\">Waiting...</pre>\n" +
"      </section>\n" +
"    </div>\n" +
"  </main>\n" +
"\n" +
"  <script>\n" +
"    const output = document.getElementById('output');\n" +
"    const npcSelect = document.getElementById('npcList');\n" +
"    const npcSearch = document.getElementById('npcSearch');\n" +
"\n" +
"    function pickNpc(id) {\n" +
"      npcSearch.value = id;\n" +
"      for (const option of npcSelect.options) {\n" +
"        option.selected = option.value === String(id);\n" +
"      }\n" +
"    }\n" +
"\n" +
"    function buildNpcQuery() {\n" +
"      const query = new URLSearchParams();\n" +
"      query.set('npcId', npcSearch.value.trim() || npcSelect.value || '40924922');\n" +
"      if (document.getElementById('useCoords').checked) {\n" +
"        for (const key of ['x', 'y', 'z']) {\n" +
"          const value = document.getElementById(key).value.trim();\n" +
"          if (value) query.set(key, value);\n" +
"        }\n" +
"      }\n" +
"      return query.toString();\n" +
"    }\n" +
"\n" +
"    async function fetchText(url) {\n" +
"      const response = await fetch(url, { cache: 'no-store' });\n" +
"      const text = await response.text();\n" +
"      if (!response.ok) throw new Error(text || response.statusText);\n" +
"      return text;\n" +
"    }\n" +
"\n" +
"    async function run(url) {\n" +
"      output.textContent = 'Requesting: ' + url;\n" +
"      try {\n" +
"        const text = await fetchText(url);\n" +
"        output.textContent = text;\n" +
"        setTimeout(refreshStatus, 500);\n" +
"      } catch (e) {\n" +
"        output.textContent = String(e.message || e);\n" +
"      }\n" +
"    }\n" +
"\n" +
"    async function spawnNpc() {\n" +
"      const npcId = npcSearch.value.trim() || npcSelect.value;\n" +
"      if (!npcId) { output.textContent = 'Enter NPC ID'; return; }\n" +
"      await run('/gm/npcs/spawn?' + buildNpcQuery());\n" +
"    }\n" +
"\n" +
"    async function spawnBatch() {\n" +
"      const query = new URLSearchParams();\n" +
"      if (document.getElementById('useCoords').checked) {\n" +
"        for (const key of ['x', 'y', 'z']) {\n" +
"          const value = document.getElementById(key).value.trim();\n" +
"          if (value) query.set(key, value);\n" +
"        }\n" +
"      }\n" +
"      const qs = query.toString();\n" +
"      await run('/gm/npcs/spawn_batch' + (qs ? '?' + qs : ''));\n" +
"    }\n" +
"\n" +
"    async function destroyNpcs() {\n" +
"      await run('/gm/npcs/destroy');\n" +
"    }\n" +
"\n" +
"    async function refreshNpcs() {\n" +
"      await run('/gm/npcs/refresh');\n" +
"    }\n" +
"\n" +
"    async function teleportToNpc() {\n" +
"      const entityId = document.getElementById('npcEntityId').value.trim();\n" +
"      if (!entityId) { output.textContent = 'Enter NPC EntityId'; return; }\n" +
"      await run('/gm/npcs/teleport_to?entityId=' + encodeURIComponent(entityId));\n" +
"    }\n" +
"\n" +
"    async function setNpcState() {\n" +
"      const entityId = document.getElementById('npcEntityId').value.trim();\n" +
"      const state = document.getElementById('npcState').value;\n" +
"      if (!entityId) { output.textContent = 'Enter NPC EntityId'; return; }\n" +
"      await run('/gm/npcs/set_state?entityId=' + encodeURIComponent(entityId) + '&state=' + encodeURIComponent(state));\n" +
"    }\n" +
"\n" +
"    async function destroyNpcOne() {\n" +
"      const entityId = document.getElementById('npcEntityId').value.trim();\n" +
"      if (!entityId) { output.textContent = 'Enter NPC EntityId'; return; }\n" +
"      await run('/gm/npcs/destroy_one?entityId=' + encodeURIComponent(entityId));\n" +
"    }\n" +
"\n" +
"    async function listNpcs() {\n" +
"      await run('/gm/npcs/list');\n" +
"    }\n" +
"\n" +
"    async function refreshStatus() {\n" +
"      try {\n" +
"        output.textContent = await fetchText('/gm/npcs/status');\n" +
"      } catch (e) {\n" +
"        output.textContent = 'Error: ' + e.message;\n" +
"      }\n" +
"    }\n" +
"\n" +
"    npcSearch.addEventListener('input', () => {\n" +
"      const needle = npcSearch.value.trim();\n" +
"      for (const option of npcSelect.options) {\n" +
"        if (option.value.includes(needle)) {\n" +
"          option.selected = true;\n" +
"          break;\n" +
"        }\n" +
"      }\n" +
"    });\n" +
"\n" +
"    refreshStatus();\n" +
"    setInterval(refreshStatus, 5000);\n" +
"  </script>\n" +
"</body>\n" +
"</html>";
        }
    }
}
