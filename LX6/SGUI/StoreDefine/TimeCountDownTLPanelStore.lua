-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimeCountDownTLPanelStore.lua
-- Decompiled from: 01349_TimeCountDownTLPanelStore.lua_608395c4354a.luajit

C_TimeCountDownTLPanelStore = DefClass("C_TimeCountDownTLPanelStore", C_TimeCountDownTLPanelStore, C_StoreGroup)
GroupName2Class.TimeCountDownTLPanelStore = C_TimeCountDownTLPanelStore
local M = C_TimeCountDownTLPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
	self.StopCountDownCo(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if type(data) == "table" then
		data = data.ToTable(data)
	end

	self.startGameTime = data.startGameTime or 0
	self.targetGameTime = data.targetGameTime or 0
	self.duration = data.duration or 0

	self:StartTimeCountDown()
end

M.StopCountDownCo = function(self)
	if self.countDownCo then
		coroutine.stop(self.countDownCo)

		self.countDownCo = nil
	end
end

M.StartTimeCountDown = function(self)
	self.StopCountDownCo(self)

	self.countDownCo = coroutine.start(function ()
		self.SubGroup.TimeWheelScrollV2Store:StartWheel(self.startGameTime, self.targetGameTime, self.duration, true)
		coroutine.step()
		self.SubGroup.TimeWheelScrollV2Store:StartWheel(self.startGameTime, self.targetGameTime, self.duration, false)
	end)
end

M.OnClose = function(self)
	self.StopCountDownCo(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
