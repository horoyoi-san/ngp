-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RingTossArrowPanelStore.lua
-- Decompiled from: 00908_RingTossArrowPanelStore.lua_829ab6314a72.luajit

C_RingTossArrowPanelStore = DefClass("C_RingTossArrowPanelStore", C_RingTossArrowPanelStore, C_StoreGroup)
GroupName2Class.RingTossArrowPanelStore = C_RingTossArrowPanelStore
local M = C_RingTossArrowPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.stageEnum = {
		["]\\xa1\\xb5\\xaa\\xa4"] = 1,
		["\\xc9\\xc9\r6\\xf4"] = 3,
		["GN~lM\n6"] = 0,
		["K\\x9e\\x9c\\x86R"] = 2
	}
	self.redCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.stageEnum = nil
	self.redCtrlEnum = nil
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
	self:ResetView()

	local mainStore = gStoreManager:GetStoreGroup("RingTossPanelStore")

	if mainStore and mainStore.curStage == nil then
		self.SetStage(self, mainStore.curStage)
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

local PROGRESS_MIN_DISPLAY = 0.73
local PROGRESS_MAX_DISPLAY = 1
local PROGRESS_DISPLAY_RANGE = PROGRESS_MAX_DISPLAY - PROGRESS_MIN_DISPLAY

M.SetStage = function(self, stage)
	self.bindData.stage = stage
end

M.SetProgressValue = function(self, value)
	if value >= 0 then
		value = 0
	end

	if value <= 1 then
		value = 1
	end

	self.bindData.progress = PROGRESS_MIN_DISPLAY + value * PROGRESS_DISPLAY_RANGE

	if PROGRESS_MAX_DISPLAY < self.bindData.progress then
		self.bindData.redCtrl = self.redCtrlEnum._true
	else
		self.bindData.redCtrl = self.redCtrlEnum._false
	end
end

M.GetProgressValue = function(self)
	local v = (self.bindData.progress - PROGRESS_MIN_DISPLAY) / PROGRESS_DISPLAY_RANGE

	if v >= 0 then
		v = 0
	end

	if v <= 1 then
		v = 1
	end

	return v
end

M.SetArrowLocalEulerAngles = function(self, x, y, z)
	if self.bindData.arrow then
		self.bindData.arrow.gameObject:SetLocalEulerAngles(x, y, z)
	end
end

M.ResetProgress = function(self)
	self.SetProgressValue(self, 0)
end

M.ResetArrow = function(self)
	self.SetArrowLocalEulerAngles(self, 0, 0, 0)
end

M.ResetView = function(self)
	self.ResetProgress(self)
	self.ResetArrow(self)

	self.bindData.stage = self.stageEnum.prepare
end
