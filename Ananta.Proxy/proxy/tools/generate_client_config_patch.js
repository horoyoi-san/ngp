"use strict";

const fs = require("fs");
const path = require("path");
const fengari = require("fengari");
const { lua, lauxlib, to_luastring } = fengari;
const { config, resolveProjectPath } = require("../private_server_config");

const clientVersion = String(config.client.version);
const fastPatchRoot = path.join(resolveProjectPath(config.paths.runtimeFastpatch), clientVersion);
const fileName = "LuaFiles#LX6#SGUI#StoreDefine#UidLayerPanelStore.lua";
const labelEnabled = config.ui?.uidLabel?.enabled !== false;
const label = labelEnabled ? String(config.ui?.uidLabel?.text || "นี่คือเวอร์ชั่น DEV ที่ไม่ได้รับคุณภาพจากเกม Ananta GAY") : "";
const removeStock = config.ui?.removeStockConfidentialLabel !== false;

fs.rmSync(fastPatchRoot, { recursive: true, force: true });
fs.mkdirSync(fastPatchRoot, { recursive: true });

const qLabel = JSON.stringify(label);
const luaSource = `-- Ananta private-server fastpatch for client ${clientVersion}\n` +
`-- Persistent UID/watermark override only. Gameplay Lua is untouched.\n\n` +
`local CSPauseManager = LX6.Engine.PauseManager\n` +
`C_UidLayerPanelStore = DefClass("C_UidLayerPanelStore", C_UidLayerPanelStore, C_StoreGroup)\n` +
`GroupName2Class.UidLayerPanelStore = C_UidLayerPanelStore\n` +
`local M = C_UidLayerPanelStore\n` +
`local PRIVATE_SERVER_LABEL = ${qLabel}\n` +
`local REMOVE_STOCK_LABEL = ${removeStock ? "true" : "false"}\n\n` +
`local function ApplyPrivateServerText(self)\n` +
`    if not self or not self.bindData then return end\n` +
`    local login = gPlayerManager and gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData or nil\n` +
`    local pid = login and login.pid or nil\n` +
`    self.bindData.uidLabel = pid ~= nil and ("UID:" .. ulong.tostring(pid)) or ""\n` +
`    if REMOVE_STOCK_LABEL then self.bindData.confidentialLabel = PRIVATE_SERVER_LABEL end\n` +
`    self.bindData.versionCtrl = 0\n` +
`    self.bindData.showUID = 0\n` +
`end\n\n` +
`M.ctor = function(self)\n` +
`    self.msgEvents = { [gEventConstants.L50_BEFORE_SWITCH_SCENE] = self.CreateAction(self, "OnBeforeSwitchScene") }\n` +
`end\n\n` +
`M.OnAwake = function(self)\n` +
`    self.RegisterMessageEvents(self, self.msgEvents)\n` +
`    gLuaUIMgr.uidLayerPanelStore = self\n` +
`    ApplyPrivateServerText(self)\n` +
`end\n\n` +
`M.OnShow = function(self, panelId, data)\n` +
`    ApplyPrivateServerText(self)\n` +
`end\n\n` +
`M.OnClose = function(self) end\n\n` +
`M.OnDestroy = function(self)\n` +
`    self.ClearMessageEvents(self)\n` +
`    gLuaUIMgr.uidLayerPanelStore = nil\n` +
`end\n\n` +
`M.OnActiveDeviceChange = function(self, device) end\n\n` +
`M.ShowPauseInfo = function(self, serveSpeed)\n` +
`    if not gGameManager.Env.isEditor or not gCS.PauseManager.showPauseTip then\n` +
`        self.bindData.pauseLabel = ""\n` +
`        return\n` +
`    end\n` +
`    local clientSpeed = CSPauseManager.Instance.PauseSpeed\n` +
`    local text = ""\n` +
`    if clientSpeed then\n` +
`        if clientSpeed ~= 0 then\n` +
`            text = text .. "客户端暂停 "\n` +
`        elseif clientSpeed >= 1 then\n` +
`            text = text .. "客户端时缓：" .. gString.Format("%.2f", clientSpeed) .. " "\n` +
`        end\n` +
`    end\n` +
`    if serveSpeed then text = text .. "服务端暂停" else text = "" end\n` +
`    self.bindData.pauseLabel = text\n` +
`end\n\n` +
`M.RefreshUID = function(self) ApplyPrivateServerText(self) end\n` +
`M.RefreshVersion = function(self) ApplyPrivateServerText(self) end\n` +
`M.RefreshUIDDisplay = function(self, show)\n` +
`    if self and self.bindData then self.bindData.showUID = 0 end\n` +
`end\n\n` +
`M.OnBeforeSwitchScene = function(self, eventId, switchSceneEventParams)\n` +
`    ApplyPrivateServerText(self)\n` +
`end\n\n` +
`M.OnLanguageChange = function(self, lang) ApplyPrivateServerText(self) end\n`;
const L = lauxlib.luaL_newstate();
const luaBytes = to_luastring(luaSource);
const status = lauxlib.luaL_loadbuffer(L, luaBytes, luaBytes.length, to_luastring(fileName));
if (status !== lua.LUA_OK) throw new Error("generated UidLayerPanelStore.lua failed Lua syntax validation");

fs.writeFileSync(path.join(fastPatchRoot, fileName), luaSource, "utf8");
fs.writeFileSync(
  path.join(fastPatchRoot, "changelog.txt"),
  `Ananta PRIVATE SERVER FASTPATCH (client ${clientVersion})\n` +
  `UID label: ${label}\n` +
  "Stock development/confidential and version-mismatch captions are suppressed.\n" +
  "No gameplay Lua overrides are included.\n",
  "utf8",
);
