-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineMapCountdownHUDPanelStore.lua
-- Decompiled from: 01124_OnlineMapCountdownHUDPanelStore.lua_fd1e5b042619.luajit

local HideAndSeekConfig = LTConfig.HideAndSeekConfig
C_OnlineMapCountdownHUDPanelStore = DefClass("C_OnlineMapCountdownHUDPanelStore", C_OnlineMapCountdownHUDPanelStore, C_StoreGroup)
GroupName2Class.OnlineMapCountdownHUDPanelStore = C_OnlineMapCountdownHUDPanelStore
local M = C_OnlineMapCountdownHUDPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.endTime = 0
	self.warningTime = 0
end

M.DefineAllEnumsAutoGen = function(self)
	self.timeWarningCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.timeWarningCtrlEnum = nil
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
	local endTime = data and data.endTime or 0

	self:InitPanelData(endTime)
end

M.InitPanelData = function(self, endTime)
	self.endTime = endTime
	self.warningTime = HideAndSeekConfig.WarningTime
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnUpdate = function(self)
	local remainingTime = math.max(self.endTime - LTUtils.UXTime.GetNowUnixTime(), 0)

	if gClientConst.SECONDS_PER_HOUR < remainingTime then
		self.bindData.countdown = string.format("%02d:%02d:%02d", math.floor(remainingTime / gClientConst.SECONDS_PER_HOUR), math.floor(remainingTime % gClientConst.SECONDS_PER_HOUR / gClientConst.SECONDS_PER_MINUTE), remainingTime % gClientConst.SECONDS_PER_MINUTE)
	else
		self.bindData.countdown = string.format("%02d:%02d", math.floor(remainingTime % gClientConst.SECONDS_PER_HOUR / gClientConst.SECONDS_PER_MINUTE), remainingTime % gClientConst.SECONDS_PER_MINUTE)
	end

	if remainingTime >= self.warningTime then
		self.bindData.timeWarningCtrl = self.timeWarningCtrlEnum.active
	else
		self.bindData.timeWarningCtrl = self.timeWarningCtrlEnum.normal
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
