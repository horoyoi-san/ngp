-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceResultTipsStore.lua
-- Decompiled from: 00790_PoliceResultTipsStore.lua_45a13c530454.luajit

local PoliceConfig = LTConfig.PoliceConfig
C_PoliceResultTipsStore = DefClass("C_PoliceResultTipsStore", C_PoliceResultTipsStore, C_StoreGroup)
GroupName2Class.PoliceResultTipsStore = C_PoliceResultTipsStore
local M = C_PoliceResultTipsStore

M.ctor = function(self)
	self.timer = nil
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OpenPanel)
end

M.OnShow = function(self, panelId, data)
	self.bindData.noticeType = data and data.notice or 0
	self.timer = Timer.New(function ()
		self:OnExit()
	end, PoliceConfig.ForceQuitNoticeShowTime):Start()
end

M.OnClose = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.OpenPanel = function(self)
	gPoliceJobManager.panelMgr:OpenNoticePanel()
	self:OnExit()
end

M.OnExit = function(self)
	gPanelManager:Close(gPanelId.POLICE_RESULT_TIPS)
end

M.OnActiveDeviceChange = function(self, device)
end
