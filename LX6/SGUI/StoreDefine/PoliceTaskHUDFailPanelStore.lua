-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceTaskHUDFailPanelStore.lua
-- Decompiled from: 00791_PoliceTaskHUDFailPanelStore.lua_48858b94134a.luajit

local PoliceConfig = LTConfig.PoliceConfig
C_PoliceTaskHUDFailPanelStore = DefClass("C_PoliceTaskHUDFailPanelStore", C_PoliceTaskHUDFailPanelStore, C_StoreGroup)
GroupName2Class.PoliceTaskHUDFailPanelStore = C_PoliceTaskHUDFailPanelStore
local M = C_PoliceTaskHUDFailPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.OnBack = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnShow = function(self, panelId, data)
	self.bindData.descLabel = gPoliceJobManager.panelMgr:GetViolationDesc(data.Id)

	Timer.New(self:CreateAction("OnBack"), PoliceConfig.ForceQuitNoticeShowTime):Start()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
