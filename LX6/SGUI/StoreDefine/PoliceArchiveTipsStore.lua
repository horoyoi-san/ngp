-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceArchiveTipsStore.lua
-- Decompiled from: 00783_PoliceArchiveTipsStore.lua_968bccf7c7f2.luajit

local PoliceConfig = LTConfig.PoliceConfig
C_PoliceArchiveTipsStore = DefClass("C_PoliceArchiveTipsStore", C_PoliceArchiveTipsStore, C_StoreGroup)
GroupName2Class.PoliceArchiveTipsStore = C_PoliceArchiveTipsStore
local M = C_PoliceArchiveTipsStore

M.ctor = function(self)
	self.timer = nil
	self.mgr = gPoliceJobManager.panelMgr
end

M.OnAwake = function(self)
	self.bindData.arrowBtn.luaClick = self.CreateAction(self, self.OnArrowClick)
end

M.OnShow = function(self, panelId, data)
	local agentId = data and data.agentId or 0
	local info = self.mgr:GetAgentInfo(agentId)
	self.bindData.headIcon = info.icon
	self.bindData.nameLabel = info.name
	self.timer = Timer.New(function ()
		self:_OnExit()
	end, PoliceConfig.FakeFileTipDisplayTime):Start()
end

M.OnClose = function(self)
end

M.OnArrowClick = function(self)
	gPanelManager:CheckShow(gPanelId.POLICE_ARCHIVE_PANEL)
	self:_OnExit()
end

M._OnExit = function(self)
	gPanelManager:Close(self.m_Id)

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end
