using System;
using System.Collections.Generic;
using System.Text;
using AnantaTestGameServer.Configs;
using AnantaTestGameServer.Packets.Req;

namespace AnantaTestGameServer
{
    public partial class Server
    {
        private static string BuildGmVehicleUi()
        {
            StringBuilder options = new();
            foreach (uint vehicleId in ClientToGameserver.GetUnlockedVehicleConfigIds())
            {
                string displayName = ClientToGameserver.GetVehicleDisplayName(vehicleId);
                string tag = vehicleId == ClientToGameserver.DefaultGmDrivableVehicleConfigId
                    ? " default"
                    : vehicleId == ClientToGameserver.MilkVehicleConfigId
                        ? " milkcar"
                        : "";
                string selected = vehicleId == ClientToGameserver.DefaultGmDrivableVehicleConfigId ? " selected" : "";
                options.Append("<option value=\"")
                    .Append(vehicleId)
                    .Append("\"")
                    .Append(selected)
                    .Append(">")
                    .Append(vehicleId)
                    .Append(" - ")
                    .Append(displayName)
                    .Append(tag)
                    .AppendLine("</option>");
            }

            return $$"""
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Ananta GM Vehicle Tool</title>
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
      grid-template-columns: 1.1fr 0.9fr;
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
      margin-bottom: 7px;
      color: var(--muted);
      font-size: 13px;
      font-weight: 600;
    }
    input, select {
      width: 100%;
      height: 40px;
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 0 12px;
      background: rgba(2,6,23,.35);
      color: var(--text);
      font: inherit;
      outline: none;
    }
    input:focus, select:focus { border-color: var(--accent); }
    select { min-height: 240px; padding: 8px; }
    .row {
      display: grid;
      grid-template-columns: 1fr 100px 100px;
      gap: 10px;
      margin-bottom: 12px;
    }
    .coords {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 10px;
      margin-top: 14px;
      padding-top: 14px;
      border-top: 1px solid var(--line);
    }
    .check {
      display: flex;
      align-items: center;
      gap: 8px;
      color: var(--muted);
      font-size: 13px;
      font-weight: 600;
    }
    .check input { width: 16px; height: 16px; accent-color: var(--accent); }
    .buttons {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 10px;
      margin-top: 14px;
    }
    button {
      min-height: 42px;
      border: 0;
      border-radius: 6px;
      padding: 0 14px;
      background: var(--accent);
      color: #fff;
      font-weight: 700;
      font-size: 14px;
      cursor: pointer;
    }
    button:hover { background: var(--accent-dark); }
    button.secondary {
      background: rgba(59,130,246,.14);
      color: var(--text);
      border: 1px solid rgba(59,130,246,.35);
    }
    button.secondary:hover { background: rgba(59,130,246,.22); }
    button.danger { background: var(--danger); color: #fff; }
    button.danger:hover { filter: brightness(.9); }
    .quick {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin: 8px 0 14px;
    }
    .quick button {
      min-height: 34px;
      padding: 0 11px;
      font-size: 13px;
    }
    .color-presets {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      margin-bottom: 14px;
    }
    .color-swatch {
      min-height: 32px !important;
      padding: 0 10px !important;
      font-size: 12px !important;
      border: 1px solid rgba(255,255,255,.15) !important;
      text-shadow: 0 1px 3px rgba(0,0,0,.5);
      min-width: 60px;
      justify-content: center;
    }
    .color-swatch:hover {
      filter: brightness(1.2);
      border-color: rgba(255,255,255,.4) !important;
    }
    pre {
      min-height: 230px;
      margin: 0;
      white-space: pre-wrap;
      word-break: break-word;
      border-radius: 10px;
      border: 1px solid var(--line);
      background: #020617;
      color: #93c5fd;
      padding: 13px;
      font: 13px/1.5 Consolas, "Courier New", monospace;
    }
    .hint {
      margin-top: 10px;
      color: var(--muted);
      font-size: 13px;
      line-height: 1.45;
    }
    #fleetTableWrap table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
      font-family: Consolas, "Courier New", monospace;
    }
    #fleetTableWrap th {
      text-align: left;
      padding: 6px 8px;
      border-bottom: 1px solid var(--line);
      color: var(--muted);
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    #fleetTableWrap td {
      padding: 6px 8px;
      border-bottom: 1px solid var(--line);
      vertical-align: middle;
    }
    #fleetTableWrap tr.current td {
      background: rgba(16, 185, 129, 0.12);
    }
    #fleetTableWrap .mini-btn {
      background: var(--accent);
      border: none;
      color: #fff;
      padding: 4px 10px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 11px;
      font-family: inherit;
    }
    #fleetTableWrap .mini-btn.danger {
      background: var(--danger);
    }
    #fleetTableWrap .mini-btn:hover { filter: brightness(1.2); }
    #fleetTableWrap .empty-fleet {
      text-align: center;
      padding: 20px;
      color: var(--muted);
      font-style: italic;
    }
    @media (max-width: 820px) {
      header, .grid { display: block; }
      section { margin-bottom: 14px; }
      .row, .coords, .buttons { grid-template-columns: 1fr; }
      select { min-height: 180px; }
    }
  </style>
{{GmStrings.GetI18nScript()}}
</head>
<body>
{{GmStrings.GetLangSelector()}}
  <main>
    <header>
      <div>
        <h1 data-t="vehicleTitle">Ananta GM Vehicle Tool</h1>
        <div class="sub" data-t="vehicleSub">Local GM vehicle tool, port {{GameConfig.GmToolPort}}. Enter the game first.</div>
      </div>
      <button class="secondary" onclick="refreshStatus()" data-t="refreshStatus">Refresh Status</button>
    </header>

    <div class="grid">
      <section>
        <h2 data-t="vehicleSelect">Vehicle Selection</h2>
        <div class="row">
          <div>
            <label for="vehicleSearch" data-t="searchOrEnter">Search or enter Vehicle Config ID</label>
            <input id="vehicleSearch" value="{{ClientToGameserver.DefaultGmDrivableVehicleConfigId}}" placeholder="e.g. 81001001">
          </div>
          <div>
            <label for="seat" data-t="seat">Seat</label>
            <input id="seat" type="number" value="0" min="0">
          </div>
          <div>
            <label for="facing" data-t="facing">Facing</label>
            <input id="facing" type="number" placeholder="自动">
          </div>
        </div>

        <label for="colorConfigId" data-t="color">Color (Color Config ID)</label>
        <input id="colorConfigId" type="number" value="0" placeholder="0=auto" style="margin-bottom:8px;">
        <div class="color-presets">
          <button class="secondary color-swatch" data-color="262" style="background:#285090;" onclick="pickColor('262')" title="262 - Metallic Blue 2">Blue</button>
          <button class="secondary color-swatch" data-color="263" style="background:#a83030;" onclick="pickColor('263')" title="263 - Metallic Red 3">Red</button>
          <button class="secondary color-swatch" data-color="264" style="background:#38b038;" onclick="pickColor('264')" title="264 - Metallic Blue 4">Green</button>
          <button class="secondary color-swatch" data-color="265" style="background:#d89830;" onclick="pickColor('265')" title="265 - Metallic Blue Pale">Yellow</button>
          <button class="secondary color-swatch" data-color="266" style="background:#384088;" onclick="pickColor('266')" title="266 - Metallic Navy Dark">Navy</button>
          <button class="secondary color-swatch" data-color="267" style="background:#283068;" onclick="pickColor('267')" title="267 - Metallic Navy 1">Navy 2</button>
          <button class="secondary color-swatch" data-color="268" style="background:#303878;" onclick="pickColor('268')" title="268 - Metallic Navy 3">Navy 3</button>
          <button class="secondary color-swatch" data-color="269" style="background:#384088;" onclick="pickColor('269')" title="269 - Metallic Navy 4">Navy 4</button>
          <button class="secondary color-swatch" data-color="17" style="background:#d8d8d8; color:#000;" onclick="pickColor('17')" title="17 - Light Gray (White) Gloss">White</button>
          <button class="secondary color-swatch" data-color="30" style="background:#1a1a1a;" onclick="pickColor('30')" title="30 - Black Matte">Black</button>
          <button class="secondary color-swatch" data-color="38" style="background:#e02020;" onclick="pickColor('38')" title="38 - Red (Formula) Gloss">Formula Red</button>
          <button class="secondary color-swatch" data-color="9" style="background:#f5d000; color:#000;" onclick="pickColor('9')" title="9 - Lamborghini Yellow Gloss">Lambo Yellow</button>
        </div>
        <details style="margin-bottom:8px;">
          <summary style="cursor:pointer; color:var(--muted); font-size:12px;">All 429 Colors (click to expand)</summary>
          <div id="allColors" style="max-height:300px; overflow-y:auto; margin-top:8px; display:grid; grid-template-columns:repeat(auto-fill, minmax(28px,1fr)); gap:2px;"></div>
        </details>
        <script>
          (function(){
            const colors = {
              gloss: [{id:1,n:"Dark Gray",h:"#4a4a4a"},{id:2,n:"Light Gray",h:"#8c8c8c"},{id:3,n:"White",h:"#f0f0f0"},{id:4,n:"Peach Soft",h:"#ffd5c2"},{id:5,n:"Red (Pink)",h:"#e8637a"},{id:6,n:"Orange",h:"#f0943a"},{id:7,n:"Orange (Red)",h:"#e06030"},{id:8,n:"Beige",h:"#d4c4a0"},{id:9,n:"Lamborghini Yellow",h:"#f5d000"},{id:10,n:"Pale Lime (Yellow)",h:"#d8e840"},{id:11,n:"Pale Lime",h:"#c8e048"},{id:12,n:"Pale Green",h:"#90d090"},{id:13,n:"Light Blue",h:"#80c0e8"},{id:14,n:"Light Blue 2",h:"#70b8e0"},{id:15,n:"Pale Purple",h:"#c8a0d8"},{id:16,n:"Fuchsia Pink",h:"#e060a0"},{id:17,n:"Light Gray (White)",h:"#d8d8d8"},{id:18,n:"Pale Light Blue",h:"#a8d8f0"},{id:33,n:"Dark Gray 2",h:"#505050"},{id:34,n:"Blue-ish White",h:"#e0e8f0"},{id:35,n:"Yellow-ish White",h:"#f0ece0"},{id:36,n:"White 2",h:"#f8f8f8"},{id:37,n:"Red (Orange)",h:"#e85040"},{id:38,n:"Red (Formula)",h:"#e02020"},{id:39,n:"Orange (Yellow)",h:"#f0a020"},{id:40,n:"Orange 2",h:"#e88030"},{id:41,n:"Lamborghini Yellow 2",h:"#f0c800"},{id:42,n:"Racing Yellow",h:"#f0d818"},{id:43,n:"Pale Green 2",h:"#a0d870"},{id:44,n:"Green",h:"#40a840"},{id:45,n:"Dark Mint",h:"#308868"},{id:46,n:"Porsche Riviera Blue",h:"#3878c0"},{id:47,n:"Pale Light Blue 2",h:"#90c8e8"},{id:48,n:"Dark Blue",h:"#204080"},{id:49,n:"Light Purple",h:"#a080c0"},{id:50,n:"Light Magenta",h:"#c070b0"},{id:51,n:"Pink",h:"#e880a0"},{id:52,n:"Burgundy",h:"#802040"},{id:53,n:"Toxic Pink",h:"#d04080"},{id:54,n:"Beige 2",h:"#c8b890"},{id:55,n:"Cyan",h:"#40b0b0"},{id:56,n:"Racing Yellow 2",h:"#e8d020"},{id:64,n:"Silver Metallic",h:"#b8b8b8"},{id:65,n:"Gray",h:"#808080"},{id:66,n:"Gray Lighter",h:"#989898"},{id:67,n:"Olive",h:"#808040"},{id:68,n:"Sand",h:"#c8b080"},{id:69,n:"Silver Metallic 2",h:"#c0c0c0"},{id:70,n:"Black",h:"#202020"},{id:71,n:"Red Orange Pearl",h:"#d84030"},{id:72,n:"White 3",h:"#f0f0f0"},{id:73,n:"Lemon",h:"#e8e040"},{id:76,n:"Jaguar Dark Green",h:"#1a4020"}],
              matte: [{id:19,n:"Light Gray Metallic",h:"#b0b0b0"},{id:20,n:"Light Gray",h:"#a0a0a0"},{id:21,n:"Dark Gray Metallic",h:"#606060"},{id:22,n:"Dark Red Metallic",h:"#8b2020"},{id:23,n:"Dark Red Brown",h:"#6b3030"},{id:24,n:"Copper",h:"#b87333"},{id:25,n:"Bronze",h:"#a08040"},{id:26,n:"Dark Green Metallic",h:"#2d5a27"},{id:27,n:"Pale Green",h:"#7dba6a"},{id:28,n:"Cyan Metallic",h:"#40a0a0"},{id:29,n:"Purple Dark Blue",h:"#3a3a6a"},{id:30,n:"Black",h:"#1a1a1a"},{id:31,n:"Brown Metallic",h:"#6a4a30"},{id:32,n:"Gold",h:"#c8a830"},{id:80,n:"Red Dark",h:"#501010"},{id:81,n:"Red 1",h:"#681818"},{id:82,n:"Red 2",h:"#802020"},{id:83,n:"Red 3",h:"#983030"},{id:84,n:"Red 4",h:"#b04040"},{id:85,n:"Red Pale",h:"#c85050"},{id:86,n:"Orange Dark",h:"#502008"},{id:87,n:"Orange 1",h:"#683010"},{id:88,n:"Orange 2",h:"#804018"},{id:89,n:"Orange 3",h:"#985020"},{id:90,n:"Orange 4",h:"#b06028"},{id:91,n:"Orange Pale",h:"#c87030"},{id:92,n:"Golden Yellow Dark",h:"#504008"},{id:93,n:"Golden Yellow 1",h:"#685010"},{id:94,n:"Golden Yellow 2",h:"#806018"},{id:95,n:"Golden Yellow 3",h:"#987020"},{id:96,n:"Golden Yellow 4",h:"#b08028"},{id:97,n:"Golden Yellow Pale",h:"#c89030"},{id:98,n:"Lemon Yellow Dark",h:"#505008"},{id:99,n:"Lemon Yellow 1",h:"#686010"},{id:100,n:"Lemon Yellow 2",h:"#807018"},{id:101,n:"Lemon Yellow 3",h:"#988020"},{id:102,n:"Lemon Yellow 4",h:"#b09028"},{id:103,n:"Lemon Yellow Pale",h:"#c8a030"},{id:104,n:"Sheen Green Dark",h:"#104010"},{id:105,n:"Sheen Green 1",h:"#185818"},{id:106,n:"Sheen Green 2",h:"#207020"},{id:107,n:"Sheen Green 3",h:"#288828"},{id:108,n:"Sheen Green 4",h:"#30a030"},{id:109,n:"Sheen Green Pale",h:"#38b838"},{id:110,n:"Lime Green Dark",h:"#205010"},{id:111,n:"Lime Green 1",h:"#306818"},{id:112,n:"Lime Green 2",h:"#408020"},{id:113,n:"Lime Green 3",h:"#509828"},{id:114,n:"Lime Green 4",h:"#60b030"},{id:115,n:"Lime Green Pale",h:"#70c838"},{id:116,n:"Forest Green Dark",h:"#103010"},{id:117,n:"Forest Green 1",h:"#184818"},{id:118,n:"Forest Green 2",h:"#206020"},{id:119,n:"Forest Green 3",h:"#287828"},{id:120,n:"Forest Green 4",h:"#309030"},{id:121,n:"Forest Green Pale",h:"#38a838"},{id:122,n:"Emerald Green Dark",h:"#104830"},{id:123,n:"Emerald Green 1",h:"#186040"},{id:124,n:"Emerald Green 2",h:"#207850"},{id:125,n:"Emerald Green 3",h:"#289060"},{id:126,n:"Emerald Green 4",h:"#30a870"},{id:127,n:"Emerald Green Pale",h:"#38c080"},{id:128,n:"Mint Green Dark",h:"#105040"},{id:129,n:"Mint Green 1",h:"#186850"},{id:130,n:"Mint Green 2",h:"#208060"},{id:131,n:"Mint Green 3",h:"#289870"},{id:132,n:"Mint Green 4",h:"#30b080"},{id:133,n:"Mint Green Pale",h:"#38c890"},{id:134,n:"Cyan Dark",h:"#104850"},{id:135,n:"Cyan 1",h:"#186068"},{id:136,n:"Cyan 2",h:"#207880"},{id:137,n:"Cyan 3",h:"#289098"},{id:138,n:"Cyan 4",h:"#30a8b0"},{id:139,n:"Cyan Pale",h:"#38c0c8"},{id:140,n:"Light Blue Dark",h:"#104058"},{id:141,n:"Light Blue 1",h:"#185870"},{id:142,n:"Light Blue 2",h:"#207088"},{id:143,n:"Light Blue 3",h:"#2888a0"},{id:144,n:"Light Blue 4",h:"#30a0b8"},{id:145,n:"Light Blue Pale",h:"#38b8d0"},{id:146,n:"Blue Dark",h:"#102050"},{id:147,n:"Blue 1",h:"#183068"},{id:148,n:"Blue 2",h:"#204080"},{id:149,n:"Blue 3",h:"#285098"},{id:150,n:"Blue 4",h:"#3060b0"},{id:151,n:"Blue Pale",h:"#3870c8"},{id:152,n:"Navy Blue Dark",h:"#101840"},{id:153,n:"Navy Blue 1",h:"#182050"},{id:154,n:"Navy Blue 2",h:"#202860"},{id:155,n:"Navy Blue 3",h:"#283070"},{id:156,n:"Navy Blue 4",h:"#303880"},{id:157,n:"Navy Blue Pale",h:"#384090"},{id:158,n:"Indigo Dark",h:"#201040"},{id:159,n:"Indigo 1",h:"#301858"},{id:160,n:"Indigo 2",h:"#402070"},{id:161,n:"Indigo 3",h:"#502888"},{id:162,n:"Indigo 4",h:"#6030a0"},{id:163,n:"Indigo Pale",h:"#7038b8"},{id:164,n:"Violet Dark",h:"#301050"},{id:165,n:"Violet 1",h:"#401868"},{id:166,n:"Violet 2",h:"#502080"},{id:167,n:"Violet 3",h:"#602898"},{id:168,n:"Violet 4",h:"#7030b0"},{id:169,n:"Violet Pale",h:"#8038c8"},{id:170,n:"Purple Dark",h:"#381050"},{id:171,n:"Purple 1",h:"#481868"},{id:172,n:"Purple 2",h:"#582080"},{id:173,n:"Purple 3",h:"#682898"},{id:174,n:"Purple 4",h:"#7830b0"},{id:175,n:"Purple Pale",h:"#8838c8"},{id:176,n:"Magenta Dark",h:"#401040"},{id:177,n:"Magenta 1",h:"#581858"},{id:178,n:"Magenta 2",h:"#702070"},{id:179,n:"Magenta 3",h:"#882888"},{id:180,n:"Magenta 4",h:"#a030a0"},{id:181,n:"Magenta Pale",h:"#b838b8"},{id:182,n:"Pink Dark",h:"#501038"},{id:183,n:"Pink 1",h:"#681848"},{id:184,n:"Pink 2",h:"#802058"},{id:185,n:"Pink 3",h:"#982868"},{id:186,n:"Pink 4",h:"#b03078"},{id:187,n:"Pink Pale",h:"#c83888"},{id:188,n:"Grayscale Black",h:"#101010"},{id:189,n:"Grayscale Dark",h:"#303030"},{id:190,n:"Grayscale 1",h:"#505050"},{id:191,n:"Grayscale 2",h:"#707070"},{id:192,n:"Grayscale 3",h:"#909090"},{id:193,n:"Grayscale Pale",h:"#b0b0b0"}],
              metallic: [{id:194,n:"Red Dark",h:"#601010"},{id:195,n:"Red 1",h:"#781818"},{id:196,n:"Red 2",h:"#902020"},{id:197,n:"Red 3",h:"#a83030"},{id:198,n:"Red 4",h:"#c04040"},{id:199,n:"Red Pale",h:"#d85050"},{id:200,n:"Orange Dark",h:"#602808"},{id:201,n:"Orange 1",h:"#783810"},{id:202,n:"Orange 2",h:"#904818"},{id:203,n:"Orange 3",h:"#a85820"},{id:204,n:"Orange 4",h:"#c06828"},{id:205,n:"Orange Pale",h:"#d87830"},{id:206,n:"Golden Yellow Dark",h:"#604808"},{id:207,n:"Golden Yellow 1",h:"#785810"},{id:208,n:"Golden Yellow 2",h:"#906818"},{id:209,n:"Golden Yellow 3",h:"#a87820"},{id:210,n:"Golden Yellow 4",h:"#c08828"},{id:211,n:"Golden Yellow Pale",h:"#d89830"},{id:212,n:"Lemon Yellow Dark",h:"#605808"},{id:213,n:"Lemon Yellow 1",h:"#786810"},{id:214,n:"Lemon Yellow 2",h:"#907818"},{id:215,n:"Lemon Yellow 3",h:"#a88820"},{id:216,n:"Lemon Yellow 4",h:"#c09828"},{id:217,n:"Lemon Yellow Pale",h:"#d8a830"},{id:218,n:"Sheen Green Dark",h:"#185018"},{id:219,n:"Sheen Green 1",h:"#206820"},{id:220,n:"Sheen Green 2",h:"#288028"},{id:221,n:"Sheen Green 3",h:"#309830"},{id:222,n:"Sheen Green 4",h:"#38b038"},{id:223,n:"Sheen Green Pale",h:"#40c840"},{id:224,n:"Lime Green Dark",h:"#286018"},{id:225,n:"Lime Green 1",h:"#387820"},{id:226,n:"Lime Green 2",h:"#489028"},{id:227,n:"Lime Green 3",h:"#58a830"},{id:228,n:"Lime Green 4",h:"#68c038"},{id:229,n:"Lime Green Pale",h:"#78d840"},{id:230,n:"Forest Green Dark",h:"#184018"},{id:231,n:"Forest Green 1",h:"#205820"},{id:232,n:"Forest Green 2",h:"#287028"},{id:233,n:"Forest Green 3",h:"#308830"},{id:234,n:"Forest Green 4",h:"#38a038"},{id:235,n:"Forest Green Pale",h:"#40b840"},{id:236,n:"Emerald Green Dark",h:"#185838"},{id:237,n:"Emerald Green 1",h:"#207048"},{id:238,n:"Emerald Green 2",h:"#288858"},{id:239,n:"Emerald Green 3",h:"#30a068"},{id:240,n:"Emerald Green 4",h:"#38b878"},{id:241,n:"Emerald Green Pale",h:"#40d088"},{id:242,n:"Mint Green Dark",h:"#186048"},{id:243,n:"Mint Green 1",h:"#207858"},{id:244,n:"Mint Green 2",h:"#289068"},{id:245,n:"Mint Green 3",h:"#30a878"},{id:246,n:"Mint Green 4",h:"#38c088"},{id:247,n:"Mint Green Pale",h:"#40d898"},{id:248,n:"Cyan Dark",h:"#185860"},{id:249,n:"Cyan 1",h:"#207078"},{id:250,n:"Cyan 2",h:"#288890"},{id:251,n:"Cyan 3",h:"#30a0a8"},{id:252,n:"Cyan 4",h:"#38b8c0"},{id:253,n:"Cyan Pale",h:"#40d0d8"},{id:254,n:"Light Blue Dark",h:"#185068"},{id:255,n:"Light Blue 1",h:"#206880"},{id:256,n:"Light Blue 2",h:"#288098"},{id:257,n:"Light Blue 3",h:"#3098b0"},{id:258,n:"Light Blue 4",h:"#38b0c8"},{id:259,n:"Light Blue Pale",h:"#40c8e0"},{id:260,n:"Blue Dark",h:"#183060"},{id:261,n:"Blue 1",h:"#204078"},{id:262,n:"Blue 2",h:"#285090"},{id:263,n:"Blue 3",h:"#3060a8"},{id:264,n:"Blue 4",h:"#3870c0"},{id:265,n:"Blue Pale",h:"#4080d8"},{id:266,n:"Navy Blue Dark",h:"#182048"},{id:267,n:"Navy Blue 1",h:"#202858"},{id:268,n:"Navy Blue 2",h:"#283068"},{id:269,n:"Navy Blue 3",h:"#303878"},{id:270,n:"Navy Blue 4",h:"#384088"},{id:271,n:"Navy Blue Pale",h:"#404898"},{id:272,n:"Indigo Dark",h:"#281850"},{id:273,n:"Indigo 1",h:"#382068"},{id:274,n:"Indigo 2",h:"#482880"},{id:275,n:"Indigo 3",h:"#583098"},{id:276,n:"Indigo 4",h:"#6838b0"},{id:277,n:"Indigo Pale",h:"#7840c8"},{id:278,n:"Violet Dark",h:"#381860"},{id:279,n:"Violet 1",h:"#482078"},{id:280,n:"Violet 2",h:"#582890"},{id:281,n:"Violet 3",h:"#6830a8"},{id:282,n:"Violet 4",h:"#7838c0"},{id:283,n:"Violet Pale",h:"#8840d8"},{id:284,n:"Purple Dark",h:"#401860"},{id:285,n:"Purple 1",h:"#502078"},{id:286,n:"Purple 2",h:"#602890"},{id:287,n:"Purple 3",h:"#7030a8"},{id:288,n:"Purple 4",h:"#8038c0"},{id:289,n:"Purple Pale",h:"#9040d8"},{id:290,n:"Magenta Dark",h:"#481850"},{id:291,n:"Magenta 1",h:"#602068"},{id:292,n:"Magenta 2",h:"#782880"},{id:293,n:"Magenta 3",h:"#903098"},{id:294,n:"Magenta 4",h:"#a838b0"},{id:295,n:"Magenta 5",h:"#c040c8"},{id:296,n:"Magenta Pale",h:"#d848e0"},{id:297,n:"Pink Dark",h:"#601848"},{id:298,n:"Pink 1",h:"#782060"},{id:299,n:"Pink 2",h:"#902878"},{id:300,n:"Pink 3",h:"#a83090"},{id:301,n:"Pink Pale",h:"#c038a8"},{id:302,n:"Grayscale Black",h:"#181818"},{id:303,n:"Grayscale Dark",h:"#383838"},{id:304,n:"Grayscale 1",h:"#585858"},{id:305,n:"Grayscale 2",h:"#787878"},{id:306,n:"Grayscale 3",h:"#989898"},{id:307,n:"Grayscale Pale",h:"#b8b8b8"}],
              pearl: [{id:308,n:"Red Dark",h:"#701818"},{id:309,n:"Red 1",h:"#882020"},{id:310,n:"Red 2",h:"#a02828"},{id:311,n:"Red 3",h:"#b83030"},{id:312,n:"Red 4",h:"#d03838"},{id:313,n:"Red Pale",h:"#e84040"},{id:314,n:"Orange Dark",h:"#703010"},{id:315,n:"Orange 1",h:"#884018"},{id:316,n:"Orange 2",h:"#a05020"},{id:317,n:"Orange 3",h:"#b86028"},{id:318,n:"Orange 4",h:"#d07030"},{id:319,n:"Orange Pale",h:"#e88038"},{id:320,n:"Golden Yellow Dark",h:"#705010"},{id:321,n:"Golden Yellow 1",h:"#886018"},{id:322,n:"Golden Yellow 2",h:"#a07020"},{id:323,n:"Golden Yellow 3",h:"#b88028"},{id:324,n:"Golden Yellow 4",h:"#d09030"},{id:325,n:"Golden Yellow Pale",h:"#e8a038"},{id:326,n:"Lemon Yellow Dark",h:"#706010"},{id:327,n:"Lemon Yellow 1",h:"#887018"},{id:328,n:"Lemon Yellow 2",h:"#a08020"},{id:329,n:"Lemon Yellow 3",h:"#b89028"},{id:330,n:"Lemon Yellow 4",h:"#d0a030"},{id:331,n:"Lemon Yellow Pale",h:"#e8b038"},{id:332,n:"Sheen Green Dark",h:"#206020"},{id:333,n:"Sheen Green 1",h:"#287828"},{id:334,n:"Sheen Green 2",h:"#309030"},{id:335,n:"Sheen Green 3",h:"#38a838"},{id:336,n:"Sheen Green 4",h:"#40c040"},{id:337,n:"Sheen Green Pale",h:"#48d848"},{id:338,n:"Lime Green Dark",h:"#307020"},{id:339,n:"Lime Green 1",h:"#408828"},{id:340,n:"Lime Green 2",h:"#50a030"},{id:341,n:"Lime Green 3",h:"#60b838"},{id:342,n:"Lime Green 4",h:"#70d040"},{id:343,n:"Lime Green Pale",h:"#80e848"},{id:344,n:"Forest Green Dark",h:"#205020"},{id:345,n:"Forest Green 1",h:"#286828"},{id:346,n:"Forest Green 2",h:"#308030"},{id:347,n:"Forest Green 3",h:"#389838"},{id:348,n:"Forest Green 4",h:"#40b040"},{id:349,n:"Forest Green Pale",h:"#48c848"},{id:350,n:"Emerald Green Dark",h:"#206840"},{id:351,n:"Emerald Green 1",h:"#288050"},{id:352,n:"Emerald Green 2",h:"#309860"},{id:353,n:"Emerald Green 3",h:"#38b070"},{id:354,n:"Emerald Green 4",h:"#40c880"},{id:355,n:"Emerald Green Pale",h:"#48e090"},{id:356,n:"Mint Green Dark",h:"#207050"},{id:357,n:"Mint Green 1",h:"#288860"},{id:358,n:"Mint Green 2",h:"#30a070"},{id:359,n:"Mint Green 3",h:"#38b880"},{id:360,n:"Mint Green 4",h:"#40d090"},{id:361,n:"Mint Green Pale",h:"#48e8a0"},{id:362,n:"Cyan Dark",h:"#206868"},{id:363,n:"Cyan 1",h:"#288080"},{id:364,n:"Cyan 2",h:"#309898"},{id:365,n:"Cyan 3",h:"#38b0b0"},{id:366,n:"Cyan 4",h:"#40c8c8"},{id:367,n:"Cyan Pale",h:"#48e0e0"},{id:368,n:"Light Blue Dark",h:"#205870"},{id:369,n:"Light Blue 1",h:"#287088"},{id:370,n:"Light Blue 2",h:"#3088a0"},{id:371,n:"Light Blue 3",h:"#38a0b8"},{id:372,n:"Light Blue 4",h:"#40b8d0"},{id:373,n:"Light Blue Pale",h:"#48d0e8"},{id:374,n:"Blue Dark",h:"#203868"},{id:375,n:"Blue 1",h:"#284880"},{id:376,n:"Blue 2",h:"#305898"},{id:377,n:"Blue 3",h:"#3868b0"},{id:378,n:"Blue 4",h:"#4078c8"},{id:379,n:"Blue Pale",h:"#4888e0"},{id:380,n:"Navy Blue Dark",h:"#202850"},{id:381,n:"Navy Blue 1",h:"#283060"},{id:382,n:"Navy Blue 2",h:"#303870"},{id:383,n:"Navy Blue 3",h:"#384080"},{id:384,n:"Navy Blue 4",h:"#404890"},{id:385,n:"Navy Blue Pale",h:"#4850a0"},{id:386,n:"Indigo Dark",h:"#302060"},{id:387,n:"Indigo 1",h:"#402878"},{id:388,n:"Indigo 2",h:"#503090"},{id:389,n:"Indigo 3",h:"#6038a8"},{id:390,n:"Indigo 4",h:"#7040c0"},{id:391,n:"Indigo Pale",h:"#8048d8"},{id:392,n:"Violet Dark",h:"#402068"},{id:393,n:"Violet 1",h:"#502880"},{id:394,n:"Violet 2",h:"#603098"},{id:395,n:"Violet 3",h:"#7038b0"},{id:396,n:"Violet 4",h:"#8040c8"},{id:397,n:"Violet Pale",h:"#9048e0"},{id:398,n:"Purple Dark",h:"#482068"},{id:399,n:"Purple 1",h:"#582880"},{id:400,n:"Purple 2",h:"#683098"},{id:401,n:"Purple 3",h:"#7838b0"},{id:402,n:"Purple 4",h:"#8840c8"},{id:403,n:"Purple Pale",h:"#9848e0"},{id:404,n:"Magenta Dark",h:"#502058"},{id:405,n:"Magenta 1",h:"#682870"},{id:406,n:"Magenta 2",h:"#803088"},{id:407,n:"Magenta 3",h:"#9838a0"},{id:408,n:"Magenta 4",h:"#b040b8"},{id:409,n:"Magenta Pale",h:"#c848d0"},{id:410,n:"Pink Dark",h:"#602050"},{id:411,n:"Pink 1",h:"#782868"},{id:412,n:"Pink 2",h:"#903080"},{id:413,n:"Pink 3",h:"#a83898"},{id:414,n:"Pink 4",h:"#c040b0"},{id:415,n:"Pink Pale",h:"#d848c8"},{id:416,n:"Grayscale Black",h:"#202020"},{id:417,n:"Grayscale Dark",h:"#404040"},{id:418,n:"Grayscale 1",h:"#606060"},{id:419,n:"Grayscale 2",h:"#808080"},{id:420,n:"Grayscale 3",h:"#a0a0a0"},{id:421,n:"Grayscale Pale",h:"#c0c0c0"}],
              livery: [{id:74,n:"White LightBlue Livery",h:"#e0e8f0"},{id:75,n:"White Golden Livery",h:"#f0e8d0"},{id:77,n:"White Lime Livery",h:"#e0f0d0"},{id:78,n:"Red Yellow-White Livery",h:"#e84030"},{id:79,n:"Black Pink Livery",h:"#301020"},{id:422,n:"Cat Express Silver (Reifence)",h:"#b0b0b0"},{id:423,n:"Cat Express Silver (Korou)",h:"#b8b8b8"},{id:424,n:"Red Dirty (Kazama)",h:"#8b3020"},{id:425,n:"Vault Security (Kazama)",h:"#4a6040"},{id:426,n:"Vault Security (Korou)",h:"#506848"},{id:427,n:"Cat Express Blue",h:"#305888"}]
            };
            const container = document.getElementById('allColors');
            const cats = ['gloss','matte','metallic','pearl','livery'];
            for (const cat of cats) {
              const hdr = document.createElement('div');
              hdr.style.cssText = 'grid-column:1/-1;font-size:11px;color:var(--accent);padding:4px 0 2px;font-weight:600;text-transform:uppercase;';
              hdr.textContent = cat;
              container.appendChild(hdr);
              for (const c of colors[cat]) {
                const btn = document.createElement('button');
                btn.className = 'color-swatch';
                btn.style.cssText = 'width:26px;height:26px;border:1px solid rgba(255,255,255,.15);border-radius:3px;cursor:pointer;padding:0;background:' + c.h + ';';
                btn.title = c.id + ' - ' + c.n;
                btn.onclick = function(){ pickColor(String(c.id)); };
                container.appendChild(btn);
              }
            }
          })();
        </script>

        <div class="quick">
          <button class="secondary" onclick="pickVehicle('{{ClientToGameserver.DefaultGmDrivableVehicleConfigId}}')" data-t="defaultDrivable">Default Drivable</button>
          <button class="secondary" onclick="pickVehicle('{{ClientToGameserver.MilkVehicleConfigId}}')" data-t="milkcar">Milkcar</button>
          <button class="secondary" onclick="location.href='/gm/vehicle/list'" data-t="textList">Text List</button>
          <button class="secondary" onclick="location.href='/gm/vehicle/help'" data-t="apiDocs">API Docs</button>
          <button class="secondary" onclick="runSimpleCommand('/gm/vehicle/add')" data-t="addVehicle">Add Vehicle</button>
          <button class="secondary" onclick="runSimpleCommand('/gm/vehicle/add_all')" data-t="addAll">Add All</button>
        </div>

        <label for="vehicleList" data-t="recordedVehicles">Recorded Vehicle IDs</label>
        <select id="vehicleList" size="12" onchange="pickVehicle(this.value)">
{{options}}
        </select>

        <div class="coords">
          <label class="check">
            <input id="useCoords" type="checkbox">
            <span data-t="specifyCoords">Specify Coordinates</span>
          </label>
          <div>
            <label for="x">X</label>
            <input id="x" type="number" step="0.01">
          </div>
          <div>
            <label for="y">Y</label>
            <input id="y" type="number" step="0.01">
          </div>
          <div>
            <label for="z">Z</label>
            <input id="z" type="number" step="0.01">
          </div>
        </div>
        <div class="hint" data-t="coordHint">If coordinates are not specified, the server will use the last recorded player position to spawn the vehicle.</div>
      </section>

      <section>
        <h2 data-t="gmOperations">GM Operations</h2>
        <div class="buttons">
          <button onclick="runVehicleCommand('/gm/vehicle/spawn_enter')" data-t="spawnAndDrive">Spawn & Drive</button>
          <button class="secondary" onclick="runVehicleCommand('/gm/vehicle/spawn')" data-t="spawnOnly">Spawn Only</button>
          <button class="secondary" onclick="runSimpleCommand('/gm/vehicle/enter')" data-t="enterVehicle">Enter Nearest</button>
          <button class="danger" onclick="runSimpleCommand('/gm/vehicle/exit')" data-t="exitVehicle">Exit Vehicle</button>
          <button class="danger" onclick="runSimpleCommand('/gm/vehicle/destroy')" data-t="destroy">Destroy</button>
          <button class="secondary" onclick="runSimpleCommand('/gm/vehicle/horn')" data-t="horn">Horn</button>
          <button class="secondary" onclick="runSimpleCommand('/gm/vehicle/color')" data-t="changeColor">Change Color</button>
        </div>
        <p class="hint" data-t="enterHint">"Enter Nearest" uses the server's LastSpawnedVehicleId; useful for spawning first, then manually entering to test.</p>

        <h2 style="margin-top:18px;" data-t="doors">Doors</h2>
        <div class="row" style="grid-template-columns:1fr 1fr 1fr;">
          <div>
            <label for="doorIndex" data-t="doorIndex">Door Index</label>
            <input id="doorIndex" type="number" value="0" min="0" max="3">
          </div>
          <div>
            <label for="doorState" data-t="doorState">State (0=Close, 1=Open)</label>
            <input id="doorState" type="number" value="1" min="0" max="1">
          </div>
          <div>
            <label>&nbsp;</label>
            <button onclick="runDoorCommand()" data-t="toggleDoor">Toggle Door</button>
          </div>
        </div>

        <h2 style="margin-top:18px;" data-t="statusResults">Status & Results</h2>
        <pre id="output" data-t="waiting">Waiting...</pre>

        <h2 style="margin-top:18px;">
          Live Spawned Vehicles
          <button class="secondary" style="float:right;font-size:12px;" onclick="refreshFleet()">Refresh</button>
          <button class="secondary" style="float:right;font-size:12px;margin-right:6px;" onclick="purgeFleet()">Purge Destroyed</button>
        </h2>
        <div class="sub" style="margin-bottom:8px" id="fleetStatus">Loading...</div>
        <div id="fleetTableWrap"></div>
      </section>
    </div>
  </main>

  <script>
    const output = document.getElementById('output');
    const vehicleSearch = document.getElementById('vehicleSearch');
    const vehicleList = document.getElementById('vehicleList');

    function pickVehicle(id) {
      vehicleSearch.value = id;
      for (const option of vehicleList.options) {
        option.selected = option.value === String(id);
      }
    }

    function buildVehicleQuery() {
      const query = new URLSearchParams();
      query.set('vehicleId', vehicleSearch.value.trim() || '{{ClientToGameserver.DefaultGmDrivableVehicleConfigId}}');
      query.set('seat', document.getElementById('seat').value || '0');
      query.set('colorConfigId', document.getElementById('colorConfigId').value.trim() || '0');

      const facing = document.getElementById('facing').value.trim();
      if (facing) query.set('facing', facing);

      if (document.getElementById('useCoords').checked) {
        for (const key of ['x', 'y', 'z']) {
          const value = document.getElementById(key).value.trim();
          if (value) query.set(key, value);
        }
      }

      return query.toString();
    }

    function pickColor(id) {
      document.getElementById('colorConfigId').value = id;
    }

    async function runDoorCommand() {
      const query = new URLSearchParams();
      query.set('index', document.getElementById('doorIndex').value || '0');
      query.set('state', document.getElementById('doorState').value || '1');
      await run('/gm/vehicle/door?' + query.toString());
    }

    async function fetchText(url) {
      const response = await fetch(url, { cache: 'no-store' });
      const text = await response.text();
      if (!response.ok) throw new Error(text || response.statusText);
      return text;
    }

    async function runVehicleCommand(path) {
      const query = buildVehicleQuery();
      await run(path + '?' + query);
    }

    async function runSimpleCommand(path) {
      const query = new URLSearchParams();
      query.set('seat', document.getElementById('seat').value || '0');
      query.set('vehicleId', vehicleSearch.value.trim() || '{{ClientToGameserver.DefaultGmDrivableVehicleConfigId}}');
      query.set('colorConfigId', document.getElementById('colorConfigId').value.trim() || '0');
      await run(path + '?' + query.toString());
    }

    async function run(url) {
      output.textContent = 'Requesting: ' + url;
      try {
        const text = await fetchText(url);
        output.textContent = text;
        setTimeout(refreshStatus, 250);
      } catch (error) {
        output.textContent = String(error.message || error);
      }
    }

    async function refreshStatus() {
      try {
        output.textContent = await fetchText('/gm/vehicle/status');
      } catch (error) {
        output.textContent = String(error.message || error);
      }
    }

    vehicleSearch.addEventListener('input', () => {
      const needle = vehicleSearch.value.trim();
      for (const option of vehicleList.options) {
        if (option.value.includes(needle)) {
          option.selected = true;
          break;
        }
      }
    });

    // ── Live Fleet (spawned vehicles) ────────────────────────────
    const fleetStatus = document.getElementById('fleetStatus');
    const fleetTableWrap = document.getElementById('fleetTableWrap');

    function escapeHtml(s) {
      return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
    }

    async function refreshFleet() {
      try {
        const r = await fetch('/gm/vehicle/spawns', { cache: 'no-store' });
        if (!r.ok) { fleetStatus.textContent = await r.text(); fleetTableWrap.innerHTML = ''; return; }
        const data = await r.json();
        fleetStatus.textContent = `Active: ${data.activeCount} · Total (incl. destroyed): ${data.totalCount}`;
        if (!data.vehicles || data.vehicles.length === 0) {
          fleetTableWrap.innerHTML = '<div class="empty-fleet">No spawned vehicles yet. Use Spawn Only or Spawn & Drive above.</div>';
          return;
        }
        const rows = data.vehicles.map(v => {
          const destroyed = v.IsDestroyed ? '<span style="color:var(--danger)"> [destroyed]</span>' : '';
          const isCurrent = v.EntityId === data.currentId;
          const rowCls = isCurrent ? 'current' : '';
          const currentTag = isCurrent ? '<span style="color:var(--ok)"> ◀ current</span>' : '';
          return `<tr class="${rowCls}">
            <td>${v.EntityId}</td>
            <td>${v.ConfigId}${destroyed}</td>
            <td>(${v.SpawnX.toFixed(1)}, ${v.SpawnY.toFixed(1)}, ${v.SpawnZ.toFixed(1)})</td>
            <td>${v.Facing.toFixed(1)}°</td>
            <td>${v.SpawnTime}</td>
            <td>
              <button class="mini-btn" onclick="fleetEnter('${v.EntityId}')">Enter</button>
              <button class="mini-btn danger" onclick="fleetDestroy('${v.EntityId}')">Destroy</button>
              <button class="mini-btn secondary" onclick="fleetTeleport('${v.EntityId}')">Teleport</button>
              ${currentTag}
            </td>
          </tr>`;
        }).join('');
        fleetTableWrap.innerHTML = `<table>
          <thead><tr><th>EntityId</th><th>ConfigId</th><th>Position</th><th>Facing</th><th>Spawn Time</th><th>Actions</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>`;
      } catch (e) {
        fleetStatus.textContent = 'Fleet fetch error: ' + e.message;
        fleetTableWrap.innerHTML = '';
      }
    }

    async function fleetEnter(entityId) {
      await run('/gm/vehicle/enter?vehicleId=' + encodeURIComponent(entityId));
      setTimeout(refreshFleet, 300);
    }

    async function fleetDestroy(entityId) {
      await run('/gm/vehicle/destroy?vehicleId=' + encodeURIComponent(entityId));
      setTimeout(refreshFleet, 300);
    }

    async function fleetTeleport(entityId) {
      await run('/gm/vehicle/teleport_to?vehicleId=' + encodeURIComponent(entityId));
    }

    async function purgeFleet() {
      await run('/gm/vehicle/purge_destroyed');
      setTimeout(refreshFleet, 300);
    }

    refreshStatus();
    refreshFleet();
    setInterval(refreshStatus, 3000);
    setInterval(refreshFleet, 3000);
  </script>
</body>
</html>
""";
        }

        private static string BuildGmHelp()
        {
            return string.Join(Environment.NewLine, new[]
            {
                "Ananta GM Vehicle Tool",
                "",
                "Open these URLs after entering the game:",
                $"http://127.0.0.1:{GameConfig.GmToolPort}/gm/vehicle/spawn_enter",
                $"http://127.0.0.1:{GameConfig.GmToolPort}/gm/vehicle/exit",
                $"http://127.0.0.1:{GameConfig.GmToolPort}/gm/vehicle/spawn_enter?vehicleId={ClientToGameserver.DefaultGmDrivableVehicleConfigId}",
                $"http://127.0.0.1:{GameConfig.GmToolPort}/gm/vehicle/spawn_enter?vehicleId={ClientToGameserver.MilkVehicleConfigId}",
                $"http://127.0.0.1:{GameConfig.GmToolPort}/gm/vehicle/list",
                $"http://127.0.0.1:{GameConfig.GmToolPort}/gm/vehicle/enter",
                $"http://127.0.0.1:{GameConfig.GmToolPort}/gm/vehicle/status",
                "",
                $"Default drivable candidate: {ClientToGameserver.DefaultGmDrivableVehicleConfigId}.",
                $"Milkcar is still available: {ClientToGameserver.MilkVehicleConfigId}.",
                "Optional query params: vehicleId, entityId, seat, x, y, z, facing."
            });
        }

        private static string BuildGmVehicleList()
        {
            List<string> lines = new()
            {
                "Unlocked vehicle config ids known by the test server:",
                $"default-drivable-candidate={ClientToGameserver.DefaultGmDrivableVehicleConfigId}",
                $"milkcar={ClientToGameserver.MilkVehicleConfigId}",
                ""
            };

            foreach (uint vehicleId in ClientToGameserver.GetUnlockedVehicleConfigIds())
            {
                string displayName = ClientToGameserver.GetVehicleDisplayName(vehicleId);
                string tag = vehicleId == ClientToGameserver.DefaultGmDrivableVehicleConfigId
                    ? " default"
                    : vehicleId == ClientToGameserver.MilkVehicleConfigId
                        ? " milkcar"
                        : "";
                lines.Add($"{vehicleId} {displayName}{tag}");
            }

            return string.Join(Environment.NewLine, lines);
        }

        // JSON payload: { vehicles: [...], activeCount, totalCount, currentId, lastId }
        // Each vehicle: { EntityId, ConfigId, ConfigName, SpawnX/Y/Z, Facing, ColorConfigId, SpawnTime, IsDestroyed }
        private static string BuildGmVehicleSpawnsJson(Connection? conn)
        {
            var sb = new StringBuilder();
            sb.Append("{");
            if (conn == null)
            {
                sb.Append("\"error\":\"No active game connection\",\"vehicles\":[],\"activeCount\":0,\"totalCount\":0,\"currentId\":\"0\",\"lastId\":\"0\"");
            }
            else
            {
                int activeCount = 0;
                var items = new List<string>();
                foreach (var v in conn.SpawnedVehicles)
                {
                    if (!v.IsDestroyed) activeCount++;
                    string configName = EscapeJson(ClientToGameserver.GetVehicleDisplayName(v.ConfigId));
                    items.Add($"{{\"EntityId\":\"{v.EntityId}\",\"ConfigId\":{v.ConfigId},\"ConfigName\":\"{configName}\"," +
                        $"\"SpawnX\":{v.SpawnX.ToString(System.Globalization.CultureInfo.InvariantCulture)}," +
                        $"\"SpawnY\":{v.SpawnY.ToString(System.Globalization.CultureInfo.InvariantCulture)}," +
                        $"\"SpawnZ\":{v.SpawnZ.ToString(System.Globalization.CultureInfo.InvariantCulture)}," +
                        $"\"Facing\":{v.Facing.ToString(System.Globalization.CultureInfo.InvariantCulture)}," +
                        $"\"ColorConfigId\":{v.ColorConfigId},\"SpawnTime\":\"{v.SpawnTime:HH:mm:ss}\"," +
                        $"\"IsDestroyed\":{(v.IsDestroyed ? "true" : "false")}}}");
                }
                sb.Append($"\"vehicles\":[{string.Join(",", items)}],");
                sb.Append($"\"activeCount\":{activeCount},");
                sb.Append($"\"totalCount\":{conn.SpawnedVehicles.Count},");
                sb.Append($"\"currentId\":\"{conn.CurrentVehicleId}\",");
                sb.Append($"\"lastId\":\"{conn.LastSpawnedVehicleId}\"");
            }
            sb.Append("}");
            return sb.ToString();
        }

        private static string EscapeJson(string s)
        {
            if (s == null) return "";
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }

        private static string BuildGmStatus(Connection conn)
        {
            var liveVehicles = conn.GetLiveVehicles();
            var sb = new System.Text.StringBuilder();
            sb.AppendLine($"Pid={conn.Pid}");
            sb.AppendLine($"LastSpawnedVehicleId={conn.LastSpawnedVehicleId}");
            sb.AppendLine($"CurrentVehicleId={conn.CurrentVehicleId}");
            sb.AppendLine($"CurrentVehicleSeat={conn.CurrentVehicleSeat}");
            sb.AppendLine($"LastCameraFacing={conn.LastCameraFacing}");
            sb.AppendLine($"HasLastKnownPlayerPosition={conn.HasLastKnownPlayerPosition}");
            sb.AppendLine($"LastKnownPlayerPosition=({conn.LastKnownPlayerPosition.X:F1}, {conn.LastKnownPlayerPosition.Y:F1}, {conn.LastKnownPlayerPosition.Z:F1})");
            sb.AppendLine();
            sb.AppendLine($"Live Vehicles: {liveVehicles.Count}");
            sb.AppendLine($"Total Spawned: {conn.SpawnedVehicles.Count}");
            
            if (liveVehicles.Count > 0)
            {
                sb.AppendLine();
                sb.AppendLine("Live Vehicles:");
                foreach (var v in liveVehicles.TakeLast(10))
                {
                    sb.AppendLine($"  ID: {v.EntityId}, Config: {v.ConfigId}, Pos: ({v.SpawnX:F1}, {v.SpawnY:F1}, {v.SpawnZ:F1})");
                }
                if (liveVehicles.Count > 10)
                {
                    sb.AppendLine($"  ... and {liveVehicles.Count - 10} more");
                }
            }
            
            return sb.ToString();
        }
    }
}
