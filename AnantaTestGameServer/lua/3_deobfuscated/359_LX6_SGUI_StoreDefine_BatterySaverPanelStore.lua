C_BatterySaverPanelStore = DefClass("C_BatterySaverPanelStore", C_BatterySaverPanelStore, C_StoreGroup)
GroupName2Class.BatterySaverPanelStore = C_BatterySaverPanelStore
local M = C_BatterySaverPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.hour = 0
	self.min = 0
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
end

function M:OnUpdate()
	local dt = System.DateTime.Now
	local hour = dt.Hour
	local min = dt.Minute

	if hour ~= self.hour or min ~= self.min then
		self.bindData.timeText = string.format("%02d:%02d", hour, min)
	end

	self.hour = hour
	self.min = min
end

function M:GenMessageEvents()
	return
end
