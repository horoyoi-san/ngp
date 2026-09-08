-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceTaskHUDCompletePanel.lua
-- Decompiled from: 00805_PoliceTaskHUDCompletePanel.lua_99a122a5998a.luajit

C_PoliceTaskHUDCompletePanel = DefClass("C_PoliceTaskHUDCompletePanel", C_PoliceTaskHUDCompletePanel, C_StoreGroup)
GroupName2Class.PoliceTaskHUDCompletePanel = C_PoliceTaskHUDCompletePanel
local M = C_PoliceTaskHUDCompletePanel

M.ctor = function(self)
end

M.OnAwake = function(self)
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
	self.areaIndex = data and data.areaIndex

	Timer.New(self:CreateAction("OnBack"), LTConfig.PoliceConfig.ForceQuitNoticeShowTime):Start()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnBack = function(self)
	gPanelManager:Close(self.m_Id)
end
