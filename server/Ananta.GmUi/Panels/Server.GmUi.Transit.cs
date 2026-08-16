using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using AnantaTestGameServer.Methods.Return;

namespace AnantaTestGameServer
{
    public partial class Server
    {
        // Maximum LineId shown in the brute-force grid. The real game has ~4
        // confirmed lines (港湾線/中央線/東城線/Feisuo), but the client accepts
        // LineId up to ~24 without crashing — handy for discovering hidden lines.
        private const int TransitBruteForceMax = 24;

        // ── HTML panel ──────────────────────────────────────────────────
        public string BuildGmTransitUi()
        {
            Connection? conn = GetActiveConnection();
            bool hasConn = conn != null;
            var active = hasConn ? conn.ActiveMetroLines : new HashSet<uint> { 1u, 2u, 3u, 4u };
            int trainsPerLine = hasConn ? conn.MetroTrainsPerLine : 1;
            int totalTrains = active.Count * trainsPerLine;

            // Pre-build line button markup server-side (keeps JS simple).
            var lineButtons = new StringBuilder();
            for (uint id = 1; id <= TransitBruteForceMax; id++)
            {
                bool on = active.Contains(id);
                string cls = on ? "line-btn on" : "line-btn";
                string mark = on ? " ✓" : "";
                string name = LineDisplayName(id);
                lineButtons.Append(
                    $"<button class=\"{cls}\" data-id=\"{id}\" onclick=\"toggleLine({id})\">" +
                    $"L{id}{mark}<span class=\"hint\">{name}</span></button>\n");
            }

            // Train status rows
            var trainRows = new StringBuilder();
            if (hasConn)
            {
                var metros = conn.BuildRunningMetros();
                foreach (var m in metros.OrderBy(x => x.LineId).ThenBy(x => x.Id))
                {
                    string fin = m.IsFinalTrain ? " <span class=\"tag final\">FINAL</span>" : "";
                    trainRows.Append(
                        $"<li><b>Train #{m.Id}</b> &nbsp;|&nbsp; Line {m.LineId} ({LineDisplayName(m.LineId)}) " +
                        $"&nbsp;|&nbsp; <span class=\"mono\">t = {m.ElapsedTime:F1}s</span>{fin}</li>\n");
                }
                if (metros.Count == 0)
                    trainRows.Append("<li class=\"empty\">No active lines. Click a line above to enable it.</li>\n");
            }
            else
            {
                trainRows.Append("<li class=\"empty\">No game connection. Enter the game first.</li>\n");
            }

            string activeIds = active.Count == 0
                ? "<i>none</i>"
                : string.Join(", ", active.OrderBy(x => x));

            return $$"""
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Transit Control – Ananta GM</title>
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
      --ok: #10b981;
      --ok-dark: #059669;
      --warn: #06b6d4;
      --warn-dark: #0891b2;
      --danger: #ef4444;
      --danger-dark: #dc2626;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      background: radial-gradient(1200px 600px at 50% -10%, rgba(59,130,246,.15), transparent 60%), var(--bg);
      color: var(--text);
      font-family: "Microsoft YaHei", "Segoe UI", Consolas, monospace;
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
      color: var(--ok);
    }
    .sub {
      margin-top: 6px;
      color: var(--muted);
      font-size: 14px;
    }
    a.back {
      color: var(--accent);
      text-decoration: none;
      font-size: 13px;
    }
    a.back:hover { text-decoration: underline; }

    section {
      background: rgba(15,23,42,.9);
      border: 1px solid var(--line);
      border-radius: 10px;
      padding: 18px;
      box-shadow: 0 14px 34px rgba(0,0,0,.25);
      margin-bottom: 16px;
    }
    h2 {
      margin: 0 0 14px;
      font-size: 16px;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: var(--muted);
    }

    .line-grid {
      display: grid;
      grid-template-columns: repeat(6, 1fr);
      gap: 8px;
    }
    .line-btn {
      background: #1e293b;
      color: var(--muted);
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 12px 8px;
      cursor: pointer;
      text-align: left;
      font-size: 15px;
      font-weight: 600;
      transition: all .15s;
      font-family: inherit;
    }
    .line-btn:hover { border-color: var(--accent); color: var(--text); }
    .line-btn.on {
      background: var(--ok);
      color: #fff;
      border-color: var(--ok);
    }
    .line-btn .hint {
      display: block;
      font-size: 10px;
      font-weight: 400;
      opacity: .85;
      margin-top: 2px;
      text-transform: uppercase;
      letter-spacing: .5px;
    }

    .actions {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }
    .act-btn {
      flex: 1 1 180px;
      border: none;
      border-radius: 8px;
      padding: 12px 16px;
      font-size: 14px;
      font-weight: 600;
      color: #fff;
      cursor: pointer;
      font-family: inherit;
      transition: filter .15s;
    }
    .act-btn:hover { filter: brightness(1.15); }
    .act-btn.ok   { background: var(--ok); }
    .act-btn.warn { background: var(--warn); }
    .act-btn.danger { background: var(--danger); }

    .stat {
      display: flex;
      gap: 24px;
      flex-wrap: wrap;
      margin-bottom: 12px;
      font-size: 13px;
      color: var(--muted);
    }
    .stat b { color: var(--text); font-size: 15px; }

    .ctrl-row {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 12px;
      flex-wrap: wrap;
    }
    .ctrl-row label {
      color: var(--muted);
      font-size: 13px;
      font-weight: 600;
    }
    .ctrl-row input[type=number] {
      background: #1e293b;
      border: 1px solid var(--line);
      border-radius: 6px;
      color: var(--text);
      padding: 6px 10px;
      width: 80px;
      font-family: inherit;
      font-size: 14px;
    }

    ul.trains {
      list-style: none;
      padding: 0;
      margin: 0;
      font-family: Consolas, "Courier New", monospace;
    }
    ul.trains li {
      background: #1e293b;
      border: 1px solid var(--line);
      border-radius: 6px;
      padding: 8px 12px;
      margin-bottom: 6px;
      font-size: 13px;
    }
    ul.trains li.empty {
      background: transparent;
      border-style: dashed;
      color: var(--muted);
      text-align: center;
      font-style: italic;
    }
    .mono { font-family: Consolas, "Courier New", monospace; color: var(--warn); }
    .tag.final {
      background: var(--danger);
      color: #fff;
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 1px;
    }

    .status-bar {
      background: #1e293b;
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 10px 16px;
      font-family: Consolas, monospace;
      font-size: 13px;
      color: var(--ok);
    }
    .status-bar.err { color: var(--danger); }

    .legend {
      display: flex;
      gap: 16px;
      flex-wrap: wrap;
      font-size: 11px;
      color: var(--muted);
      margin-top: 10px;
    }
    .legend span::before {
      content: "";
      display: inline-block;
      width: 8px;
      height: 8px;
      border-radius: 2px;
      margin-right: 4px;
      vertical-align: middle;
    }
    .legend .L1::before { background: #f97316; }
    .legend .L2::before { background: #10b981; }
    .legend .L3::before { background: #3b82f6; }
    .legend .L4::before { background: #a855f7; }

    #perLineCards {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 10px;
    }
    .line-card {
      background: #1e293b;
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 12px;
    }
    .line-card.inactive {
      opacity: 0.45;
    }
    .line-card h3 {
      margin: 0 0 10px;
      font-size: 14px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .line-card h3 .pill {
      background: var(--ok);
      color: #fff;
      font-size: 10px;
      padding: 2px 8px;
      border-radius: 4px;
      letter-spacing: 1px;
    }
    .line-card h3 .pill.off {
      background: var(--danger);
    }
    .line-card .row {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr auto;
      gap: 8px;
      margin-bottom: 8px;
      align-items: end;
    }
    .line-card label {
      font-size: 10px;
      color: var(--muted);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 3px;
    }
    .line-card input[type=number] {
      background: #0f172a;
      border: 1px solid var(--line);
      border-radius: 4px;
      color: var(--text);
      padding: 5px 8px;
      width: 100%;
      font-family: Consolas, monospace;
      font-size: 13px;
    }
    .line-card .mini-btn {
      background: var(--accent);
      border: none;
      color: #fff;
      padding: 6px 12px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 11px;
      font-family: inherit;
    }
    .line-card .mini-btn:hover { filter: brightness(1.15); }
    .train-row {
      background: #1e293b;
      border: 1px solid var(--line);
      border-radius: 6px;
      padding: 8px 12px;
      margin-bottom: 6px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-family: Consolas, "Courier New", monospace;
      font-size: 13px;
    }
    .train-row .final-btn {
      background: #0f172a;
      border: 1px solid var(--line);
      color: var(--muted);
      padding: 4px 10px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 11px;
      font-family: inherit;
    }
    .train-row .final-btn.on {
      background: var(--danger);
      color: #fff;
      border-color: var(--danger);
    }
    .empty-trains {
      background: transparent;
      border: 1px dashed var(--line);
      border-radius: 6px;
      padding: 16px;
      text-align: center;
      color: var(--muted);
      font-style: italic;
    }
    @media (max-width: 820px) {
      #perLineCards { grid-template-columns: 1fr; }
      .line-card .row { grid-template-columns: 1fr 1fr; }
    }
  </style>
</head>
<body>
  <main>
    <header>
      <div>
        <h1>Transit Control</h1>
        <div class="sub">GM control panel for the Ananta metro system (港湾線 · 中央線 · 東城線 · Feisuo)</div>
      </div>
      <a class="back" href="/gm/menu">← GM Menu</a>
    </header>

    <section>
      <h2>Line IDs (1–{{TransitBruteForceMax}} brute-force range)</h2>
      <div class="sub" style="margin-bottom:12px" id="lineSummary">Loading...</div>
      <div class="line-grid" id="lineGrid"></div>
      <div class="legend">
        <span class="L1">L1 港湾線 (Harbor)</span>
        <span class="L2">L2 中央線 (Central)</span>
        <span class="L3">L3 東城線 (EastCity)</span>
        <span class="L4">L4 Feisuo</span>
      </div>
    </section>

    <section>
      <h2>Parameters</h2>
      <div class="ctrl-row">
        <label for="tpl">Trains per line (global default):</label>
        <input type="number" id="tpl" min="1" max="8" value="1">
        <button class="act-btn warn" style="flex:0 0 auto" onclick="setTrainsPerLine()">Apply</button>
      </div>
      <div class="actions">
        <button class="act-btn ok" onclick="resyncAll()">Resync All Active Lines</button>
        <button class="act-btn warn" onclick="restoreDefault()">Restore Metro 1-4</button>
        <button class="act-btn warn" onclick="enableAll()">Enable All 1-20</button>
        <button class="act-btn danger" onclick="disableAll()">Disable All</button>
      </div>
    </section>

    <section>
      <h2>Per-Line Settings <span class="sub" id="perLineStatus"></span></h2>
      <div id="perLineCards"></div>
    </section>

    <section>
      <h2>Train Status</h2>
      <div class="stat" id="statRow"></div>
      <ul class="trains" id="trainList"></ul>
    </section>

    <div class="status-bar" id="status">Ready.</div>
  </main>

  <script>
    const BASE = '/gm/transit';
    const statusEl = document.getElementById('status');
    const lineSummary = document.getElementById('lineSummary');
    const lineGrid = document.getElementById('lineGrid');
    const perLineCards = document.getElementById('perLineCards');
    const perLineStatus = document.getElementById('perLineStatus');
    const statRow = document.getElementById('statRow');
    const trainList = document.getElementById('trainList');
    const tplInput = document.getElementById('tpl');

    function setStatus(msg, isErr) {
      statusEl.textContent = msg;
      statusEl.classList.toggle('err', !!isErr);
    }

    async function hit(path, opts = {}) {
      try {
        const r = await fetch(BASE + path, { cache: 'no-store' });
        const t = await r.text();
        setStatus(t, !r.ok);
        if (r.ok && opts.reload !== false) setTimeout(refreshState, 250);
        return r.ok;
      } catch (e) {
        setStatus('Network error: ' + e.message, true);
        return false;
      }
    }

    function toggleLine(id) { hit('/toggle?lineId=' + id); }
    function resyncAll()    { hit('/resync'); }
    function restoreDefault(){ hit('/restore'); }
    function enableAll()    { hit('/enable_all'); }
    function disableAll()   { hit('/disable_all'); }

    function setTrainsPerLine() {
      const v = parseInt(tplInput.value, 10);
      if (!v || v < 1 || v > 8) { setStatus('Trains per line must be 1..8', true); return; }
      hit('/set_trains?count=' + v);
    }

    function setCycle(lineId) {
      const v = parseFloat(document.getElementById('cycle-' + lineId).value);
      if (!v || v < 10 || v > 3600) { setStatus('Cycle must be 10..3600', true); return; }
      hit('/set_cycle?lineId=' + lineId + '&seconds=' + v);
    }
    function setLineTrains(lineId) {
      const v = parseInt(document.getElementById('trains-' + lineId).value, 10);
      if (isNaN(v) || v < 0 || v > 16) { setStatus('Trains must be 0..16', true); return; }
      hit('/set_line_trains?lineId=' + lineId + '&count=' + v);
    }
    function setOffset(lineId) {
      const v = parseFloat(document.getElementById('offset-' + lineId).value) || 0;
      hit('/set_offset?lineId=' + lineId + '&seconds=' + v);
    }
    function toggleFinal(lineId, idx) {
      hit('/toggle_final?lineId=' + lineId + '&idx=' + idx);
    }

    function teleportToTrain(trainId) {
      hit('/teleport_to_train?trainId=' + trainId);
    }

    function renderLineGrid(state) {
      const cards = state.lines.map(l => {
        const cls = l.active ? 'line-btn on' : 'line-btn';
        const mark = l.active ? ' ✓' : '';
        return `<button class="${cls}" onclick="toggleLine(${l.lineId})">L${l.lineId}${mark}<span class="hint">${l.name}</span></button>`;
      }).join('');
      lineGrid.innerHTML = cards;
      lineSummary.innerHTML = `Active lines: <b>${state.activeCount}</b> — Click a line to toggle. Global trains/line: <b>${state.globalTrainsPerLine}</b>.`;
      tplInput.value = state.globalTrainsPerLine;
    }

    function renderPerLineCards(state) {
      perLineCards.innerHTML = state.lines.map(l => {
        const pillCls = l.active ? 'pill' : 'pill off';
        const pillTxt = l.active ? 'ACTIVE' : 'OFF';
        const cardCls = l.active ? 'line-card' : 'line-card inactive';
        const trainRows = l.running.map(t =>
          `<div class="train-row">
            <span>Train #${t.Id} (idx ${t.Idx}) — <span class="mono" id="elapsed-${l.lineId}-${t.Idx}">t = ${t.ElapsedTime.toFixed(1)}s</span></span>
            <button class="final-btn ${t.IsFinal ? 'on' : ''}" onclick="toggleFinal(${l.lineId}, ${t.Idx})">IsFinal: ${t.IsFinal ? 'ON' : 'off'}</button>
            <button class="mini-btn secondary" onclick="teleportToTrain(${t.Id})">Teleport</button>
          </div>`
        ).join('') || '<div class="empty-trains">No trains (count=0 or line inactive).</div>';
        return `<div class="${cardCls}">
          <h3>L${l.lineId} ${l.name} <span class="${pillCls}">${pillTxt}</span></h3>
          <div class="row">
            <div><label>Cycle (s)</label><input type="number" id="cycle-${l.lineId}" value="${l.cycle.toFixed(0)}" min="10" max="3600"></div>
            <div><label>Trains</label><input type="number" id="trains-${l.lineId}" value="${l.trains}" min="0" max="16"></div>
            <div><label>Offset (s)</label><input type="number" id="offset-${l.lineId}" value="${l.offset.toFixed(1)}" step="0.5"></div>
            <div>
              <button class="mini-btn" onclick="setCycle(${l.lineId})" title="Apply cycle">Cycle</button>
              <button class="mini-btn" onclick="setLineTrains(${l.lineId})" title="Apply trains">Trains</button>
              <button class="mini-btn" onclick="setOffset(${l.lineId})" title="Apply offset">Offset</button>
            </div>
          </div>
          ${trainRows}
        </div>`;
      }).join('');
    }

    function renderTrains(state) {
      let total = 0;
      const rows = [];
      for (const l of state.lines) {
        if (!l.active) continue;
        for (const t of l.running) {
          total++;
          const fin = t.IsFinal ? ' <span class="tag final">FINAL</span>' : '';
          rows.push(`<li><b>Train #${t.Id}</b> &nbsp;|&nbsp; Line ${l.lineId} (${l.name}) &nbsp;|&nbsp; <span class="mono">t = ${t.ElapsedTime.toFixed(1)}s</span>${fin}</li>`);
        }
      }
      statRow.innerHTML = `
        <div>Global trains/line: <b>${state.globalTrainsPerLine}</b></div>
        <div>Active lines: <b>${state.activeCount}</b></div>
        <div>Running trains: <b>${total}</b></div>`;
      trainList.innerHTML = rows.length
        ? rows.join('')
        : '<li class="empty">No active lines. Click a line above to enable it.</li>';
    }

    // Preserve input values across re-renders so typing isn't reset by auto-refresh.
    function snapshotInputs() {
      const snap = {};
      document.querySelectorAll('#perLineCards input, #perLineCards select').forEach(el => {
        snap[el.id] = el.value;
      });
      snap['__focus__'] = document.activeElement ? document.activeElement.id : '';
      return snap;
    }
    function restoreInputs(snap) {
      for (const id in snap) {
        if (id === '__focus__') continue;
        const el = document.getElementById(id);
        if (el) el.value = snap[id];
      }
      if (snap['__focus__']) {
        const f = document.getElementById(snap['__focus__']);
        if (f && f.focus) f.focus();
      }
    }

    let lastLineFingerprint = '';
    async function refreshState() {
      try {
        const r = await fetch(BASE + '/state', { cache: 'no-store' });
        if (!r.ok) { setStatus(await r.text(), true); return; }
        const raw = await r.text();
        const state = JSON.parse(raw);
        if (state.error) {
          setStatus(state.error, true);
          if (!state.lines || state.lines.length === 0) return;
        } else {
          setStatus('Ready.');
        }

        // Structural fingerprint: active flags + cycle/trains/offset per line + train count.
        // If the structure hasn't changed, we only update the live ElapsedTime values
        // (which avoids clobbering user input or focus).
        const fp = state.lines.map(l =>
          `${l.lineId}:${l.active?1:0}:${l.cycle}:${l.trains}:${l.offset}:${l.running.length}:${l.running.map(r=>r.IsFinal?1:0).join(',')}`
        ).join('|') + '|' + state.globalTrainsPerLine;
        const structureChanged = fp !== lastLineFingerprint;
        lastLineFingerprint = fp;

        const snap = structureChanged ? null : snapshotInputs();
        perLineStatus.textContent = `${state.activeCount} active, ${state.lines.length} tracked`;
        renderLineGrid(state);
        if (structureChanged) {
          renderPerLineCards(state);
        } else {
          // Only update elapsed-time text nodes inside existing train rows.
          for (const l of state.lines) {
            for (const t of l.running) {
              const span = document.getElementById(`elapsed-${l.lineId}-${t.Idx}`);
              if (span) span.textContent = `t = ${t.ElapsedTime.toFixed(1)}s`;
            }
          }
        }
        renderTrains(state);
        if (!structureChanged) restoreInputs(snap);
      } catch (e) {
        setStatus('State fetch error: ' + e.message, true);
      }
    }

    refreshState();
    setInterval(refreshState, 2000);
  </script>
</body>
</html>
""";
        }

        // Plain-text status (same info as the Train Status section)
        public string BuildGmTransitStatus()
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active game connection.";

            var metros = conn.BuildRunningMetros();
            var sb = new StringBuilder();
            sb.AppendLine($"Active lines ({conn.ActiveMetroLines.Count}): {string.Join(", ", conn.ActiveMetroLines.OrderBy(x => x))}");
            sb.AppendLine($"Trains per line: {conn.MetroTrainsPerLine}");
            sb.AppendLine($"Running trains: {metros.Count}");
            sb.AppendLine($"Simulation enabled: {conn.MetroSimulationEnabled}");
            sb.AppendLine();
            foreach (var m in metros.OrderBy(x => x.LineId).ThenBy(x => x.Id))
            {
                sb.AppendLine($"  Train #{m.Id}  Line {m.LineId} ({LineDisplayName(m.LineId)})");
                sb.AppendLine($"    Time: {m.ElapsedTime:F1}s{(m.IsFinalTrain ? "  [FINAL]" : "")}");
                sb.AppendLine($"    Position: ({m.Position.X:F1}, {m.Position.Y:F1}, {m.Position.Z:F1})");
                sb.AppendLine($"    Facing: {m.Facing:F1}°  Speed: {m.Speed:F2} m/s");
            }
            return sb.ToString();
        }

        // ── Actions (called from Server.Routing.cs) ─────────────────────

        public string TransitToggle(uint lineId)
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            if (lineId < 1 || lineId > TransitBruteForceMax) return $"LineId {lineId} out of range.";

            if (conn.ActiveMetroLines.Contains(lineId))
            {
                conn.ActiveMetroLines.Remove(lineId);
                conn.PushMetroResync();
                return $"Line {lineId} ({LineDisplayName(lineId)}) DISABLED. Active: {conn.ActiveMetroLines.Count}.";
            }
            else
            {
                conn.ActiveMetroLines.Add(lineId);
                conn.PushMetroResync();
                return $"Line {lineId} ({LineDisplayName(lineId)}) ENABLED. Active: {conn.ActiveMetroLines.Count}.";
            }
        }

        public string TransitResync()
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            conn.PushMetroResync();
            return $"Resynced {conn.ActiveMetroLines.Count} active line(s), {conn.ActiveMetroLines.Count * conn.MetroTrainsPerLine} train(s).";
        }

        public string TransitRestore()
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            conn.ActiveMetroLines = new HashSet<uint> { 1u, 2u, 3u, 4u };
            conn.MetroTrainsPerLine = 1;
            conn.MetroLineCycleSeconds = new Dictionary<uint, float>
            {
                { 1u, 300f }, { 2u, 300f }, { 3u, 240f }, { 4u, 240f },
            };
            conn.MetroLineTrainCount = new Dictionary<uint, int>
            {
                { 1u, 1 }, { 2u, 1 }, { 3u, 1 }, { 4u, 1 },
            };
            conn.MetroLineOffsetSeconds = new Dictionary<uint, float>();
            conn.MetroTrainFinalOverride = new Dictionary<string, bool>();
            conn.PushMetroResync();
            return "Restored default: lines 1-4, 1 train/line (L1-L2=300s, L3-L4=240s).";
        }

        public string TransitEnableAll()
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            conn.ActiveMetroLines.Clear();
            for (uint i = 1; i <= 20; i++) conn.ActiveMetroLines.Add(i);
            conn.PushMetroResync();
            return $"Enabled lines 1-20 ({conn.ActiveMetroLines.Count} lines).";
        }

        public string TransitDisableAll()
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            conn.ActiveMetroLines.Clear();
            conn.PushMetroResync();
            return "All lines disabled.";
        }

        public string TransitSetTrains(int count)
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            if (count < 1 || count > 8) return "Trains per line must be 1..8.";
            conn.MetroTrainsPerLine = count;
            conn.PushMetroResync();
            return $"Trains per line set to {count}. Total running: {conn.ActiveMetroLines.Count * count}.";
        }

        // ── Per-line refinement actions ─────────────────────────────────
        public string TransitSetLineCycle(uint lineId, float seconds)
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            if (lineId < 1 || lineId > TransitBruteForceMax) return $"LineId {lineId} out of range.";
            if (seconds < 10f || seconds > 3600f) return "Cycle seconds must be 10..3600.";
            conn.MetroLineCycleSeconds[lineId] = seconds;
            conn.PushMetroResync();
            return $"Line {lineId} cycle set to {seconds}s.";
        }

        public string TransitSetLineTrains(uint lineId, int count)
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            if (lineId < 1 || lineId > TransitBruteForceMax) return $"LineId {lineId} out of range.";
            if (count < 0 || count > 16) return "Trains must be 0..16 (0 = use global default).";
            if (count == 0) conn.MetroLineTrainCount.Remove(lineId);
            else conn.MetroLineTrainCount[lineId] = count;
            conn.PushMetroResync();
            return $"Line {lineId} train count set to {count}.";
        }

        public string TransitSetLineOffset(uint lineId, float seconds)
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            if (lineId < 1 || lineId > TransitBruteForceMax) return $"LineId {lineId} out of range.";
            conn.MetroLineOffsetSeconds[lineId] = seconds;
            conn.PushMetroResync();
            return $"Line {lineId} phase offset set to {seconds}s.";
        }

        public string TransitToggleFinal(uint lineId, int trainIndex)
        {
            Connection? conn = GetActiveConnection();
            if (conn == null) return "No active connection.";
            string key = $"{lineId}_{trainIndex}";
            // Determine current effective final state and flip it.
            int trains = conn.MetroLineTrainCount.TryGetValue(lineId, out var n) ? n : conn.MetroTrainsPerLine;
            bool current = conn.MetroTrainFinalOverride.TryGetValue(key, out var f) ? f : (trainIndex == trains - 1);
            conn.MetroTrainFinalOverride[key] = !current;
            conn.PushMetroResync();
            return $"Line {lineId} train #{trainIndex} IsFinal = {!current}.";
        }

        // ── JSON state endpoint (per-line + per-train details) ──────────
        public string BuildGmTransitStateJson()
        {
            Connection? conn = GetActiveConnection();
            var sb = new StringBuilder();
            sb.Append("{");
            if (conn == null)
            {
                var lineInfos = new List<string>();
                float[] defaultCycles = { 300f, 300f, 240f, 240f }; // L1-L2=300, L3-L4=240
                foreach (var lineId in Enumerable.Range(1, TransitBruteForceMax).Select(x => (uint)x))
                {
                    bool active = (lineId <= 4);
                    float cycle = lineId <= 4 ? defaultCycles[lineId - 1] : 300f;
                    int trains = active ? 1 : 0;
                    float offset = 0f;
                    string name = LineDisplayName(lineId);
                    lineInfos.Add($"{{\"lineId\":{lineId},\"name\":\"{name.Replace("\"", "\\\"")}\"," +
                        $"\"active\":{(active ? "true" : "false")}," +
                        $"\"cycle\":{cycle.ToString(System.Globalization.CultureInfo.InvariantCulture)}," +
                        $"\"trains\":{trains}," +
                        $"\"offset\":{offset.ToString(System.Globalization.CultureInfo.InvariantCulture)}," +
                        $"\"running\":[]}}");
                }
                sb.Append("\"error\":\"No active game connection. Enter the game first.\",");
                sb.Append("\"globalTrainsPerLine\":1,");
                sb.Append("\"activeCount\":4,");
                sb.Append($"\"lines\":[{string.Join(",", lineInfos)}]");
            }
            else
            {
                var metros = conn.BuildRunningMetros();
                var lineInfos = new List<string>();
                foreach (var lineId in Enumerable.Range(1, TransitBruteForceMax).Select(x => (uint)x))
                {
                    bool active = conn.ActiveMetroLines.Contains(lineId);
                    float cycle = conn.MetroLineCycleSeconds.TryGetValue(lineId, out var c) ? c : 300f;
                    int trains = conn.MetroLineTrainCount.TryGetValue(lineId, out var n) ? n : conn.MetroTrainsPerLine;
                    float offset = conn.MetroLineOffsetSeconds.TryGetValue(lineId, out var ph) ? ph : 0f;

                    var lineTrains = new List<string>();
                    int idx = 0;
                    foreach (var m in metros.Where(x => x.LineId == lineId))
                    {
                        lineTrains.Add($"{{\"Id\":{m.Id},\"Idx\":{idx},\"ElapsedTime\":{m.ElapsedTime.ToString(System.Globalization.CultureInfo.InvariantCulture)}," +
                            $"\"IsFinal\":{(m.IsFinalTrain ? "true" : "false")}}}");
                        idx++;
                    }
                    string name = LineDisplayName(lineId);
                    lineInfos.Add($"{{\"lineId\":{lineId},\"name\":\"{name.Replace("\"", "\\\"")}\"," +
                        $"\"active\":{(active ? "true" : "false")}," +
                        $"\"cycle\":{cycle.ToString(System.Globalization.CultureInfo.InvariantCulture)}," +
                        $"\"trains\":{trains}," +
                        $"\"offset\":{offset.ToString(System.Globalization.CultureInfo.InvariantCulture)}," +
                        $"\"running\":[{string.Join(",", lineTrains)}]}}");
                }
                sb.Append($"\"globalTrainsPerLine\":{conn.MetroTrainsPerLine},");
                sb.Append($"\"activeCount\":{conn.ActiveMetroLines.Count},");
                sb.Append($"\"lines\":[{string.Join(",", lineInfos)}]");
            }
            sb.Append("}");
            return sb.ToString();
        }

        // ── Helpers ─────────────────────────────────────────────────────

        // Real names from vfc_387 bundle for L1-L4; others are brute-force probes.
        private static string LineDisplayName(uint lineId) => lineId switch
        {
            1 => "港湾線",
            2 => "中央線",
            3 => "東城線",
            4 => "Feisuo",
            _ => $"probe-{lineId}",
        };
    }
}
