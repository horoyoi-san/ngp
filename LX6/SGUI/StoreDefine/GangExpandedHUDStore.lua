-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GangExpandedHUDStore.lua
-- Decompiled from: 01749_GangExpandedHUDStore.lua_a324de764ab1.luajit

local FactionConfig = LTConfig.FactionConfig
C_GangExpandedHUDStore = DefClass("C_GangExpandedHUDStore", C_GangExpandedHUDStore, C_StoreGroup)
GroupName2Class.GangExpandedHUDStore = C_GangExpandedHUDStore
local M = C_GangExpandedHUDStore

M.ctor = function(self)
	self.timer = nil
	self.callBack = nil
end

M.OnAwake = function(self)
end

M.OnExit = function(self)
	gPanelManager:Close(gPanelId.GANG_EXPANDED)
end

M.OnShow = function(self, panelId, data)
	if self.timer then
		self.timer:Stop()
	end

	self.callBack = data and data.CallBack
	local duration = data and data.durationOverride or 0

	if duration < 0 then
		duration = FactionConfig.FactionPopupProgressDuration
	end

	self.timer = Timer.New(function ()
		self:OnExit()
	end, duration):Start()
end

M.OnClose = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	local callBack = self.callBack
	self.callBack = nil

	DoCallBack(callBack)
end

M.OnActiveDeviceChange = function(self, device)
end
