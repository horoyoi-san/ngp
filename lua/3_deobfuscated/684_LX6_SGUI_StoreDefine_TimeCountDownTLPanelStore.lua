C_TimeCountDownTLPanelStore = DefClass("C_TimeCountDownTLPanelStore", C_TimeCountDownTLPanelStore, C_StoreGroup)
GroupName2Class.TimeCountDownTLPanelStore = C_TimeCountDownTLPanelStore
local M = C_TimeCountDownTLPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:StopCountDownCo()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	if type(data) ~= "table" then
		data = data:ToTable()
	end

	self.startGameTime = data.startGameTime or 0
	self.targetGameTime = data.targetGameTime or 0
	self.duration = data.duration or 0

	self:StartTimeCountDown()
end

function M:StopCountDownCo()
	if self.countDownCo then
		coroutine.stop(self.countDownCo)

		self.countDownCo = nil
	end
end

function M:StartTimeCountDown()
	self:StopCountDownCo()

	self.countDownCo = coroutine.start(function ()
		self.SubGroup.TimeWheelScrollV2Store:StartWheel(self.startGameTime, self.targetGameTime, self.duration, true)
		coroutine.step()
		self.SubGroup.TimeWheelScrollV2Store:StartWheel(self.startGameTime, self.targetGameTime, self.duration, false)
	end)
end

function M:OnClose()
	self:StopCountDownCo()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	return
end
