-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\KTVPausePanelStore.lua
-- Decompiled from: 01776_KTVPausePanelStore.lua_29609d7fe08a.luajit

C_KTVPausePanelStore = DefClass("C_KTVPausePanelStore", C_KTVPausePanelStore, C_StoreGroup)
GroupName2Class.KTVPausePanelStore = C_KTVPausePanelStore
local M = C_KTVPausePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	gKTVGameManager:PauseGame()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.resumeBtn.luaClick = self.CreateAction(self, self.OnClickResumeBtn)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
end

M.OnClickResumeBtn = function(self)
	gPanelManager:Close(gPanelId.S_KTV_PAUSE_PANEL)
	gKTVGameManager:StartCountdown()
end

M.OnClickExitBtn = function(self)
	slot1 = gPanelManager

	slot1:Close(gPanelId.S_KTV_PAUSE_PANEL)

	slot1 = gKTVGameManager

	slot1:EndGame(true, nil, function ()
		gPanelManager:Close(gPanelId.S_KTV_GAME_PANEL)
	end)
end
