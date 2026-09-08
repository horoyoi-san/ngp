-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HudPanelStore.lua
-- Decompiled from: 01812_HudPanelStore.lua_850847ca6a96.luajit

C_HudPanelStore = DefClass("C_HudPanelStore", C_HudPanelStore, C_StoreGroup)
GroupName2Class.HudPanelStore = C_HudPanelStore
local M = C_HudPanelStore

M.ctor = function(self)
	require("LX6/Manager/HUD/HudMgr")
	require("LX6/Manager/HUD/HudConst")
	gHudMgr:OnInit()
end

M.OnShow = function(self)
	gHudMgr:CreateMySpiritHUD()
	LX6.GUI.HUDNew.HUDManager.RefreshVisibility()
end

M.OnUpdate = function(self)
	if gHudMgr.needUpdateCount <= 0 then
		gHudMgr:Update()
	end
end

M.OnDestroy = function(self)
	gHudMgr:ReleasePool()
end

M.OnLanguageChange = function(self, lang)
end
