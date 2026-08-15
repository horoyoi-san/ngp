local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ScriptBattleUnit = require("LX6/Utils/FormulaScriptBattleUnit")
local CarRaceManager = L50.Spoon.CarRaceManager
C_ChallengeCheckBlock = DefClass("C_ChallengeCheckBlock", C_ChallengeCheckBlock)
local M = C_ChallengeCheckBlock

function M:ctor(taskId, type, ...)
	self.params = {
		...
	}
	self.taskId = taskId
	self.initFuc = self["OnInit" .. type]
	self.checkFunc = self["OnCheck" .. type]
	self.disposeFunc = self["OnDispose" .. type]
	self.isDispose = true
end

function M:Init()
	self.isDispose = false

	if self.initFuc then
		self:initFuc(unpack(self.params))
	end
end

function M:Check()
	if self.checkFunc then
		return self:checkFunc()
	end

	return false, 0
end

function M:Dispose()
	if self.disposeFunc then
		self:disposeFunc()
	end

	self.isDispose = true
end

function M:OnInitRankCountTime(holdTime)
	self.holdTime = holdTime
	self.isRecording = false
	self.recordMax = 0
	self.recordTime = 0
	self.startTime = 0
	self.rank = gCarRaceManager:GetPlayerRank()

	function self.handler()
		self.rank = gCarRaceManager:GetPlayerRank()
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_SPEED_RACE, self.handler)
end

function M:OnCheckRankCountTime()
	if self.rank == 1 and not self.isRecording then
		self.isRecording = true
		self.startTime = gLogicTime.time
	end

	if self.isRecording then
		self.recordTime = gLogicTime.time - self.startTime
		self.recordMax = Mathf.Max(self.recordMax, self.recordTime)

		if self.rank > 1 then
			self.isRecording = false
			self.recordTime = 0
		end
	end

	return self.holdTime <= self.recordMax, math.floor(Mathf.Min(self.recordTime, self.holdTime))
end

function M:OnDisposeRankCountTime()
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_SPEED_RACE, self.handler)
end

function M:OnInitHang(hangTime)
	self.hangTime = hangTime
	self.isRecording = false
	self.recordMax = 0
	self.recordTime = 0
end

function M:OnCheckHang()
	local hang = self:CheckIsHang()

	if hang and not self.isRecording then
		self.isRecording = true
		self.startTime = gLogicTime.time
	end

	if self.isRecording then
		self.recordTime = gLogicTime.time - self.startTime
		self.recordMax = Mathf.Max(self.recordMax, self.recordTime)

		if not hang then
			self.isRecording = false
			self.recordTime = 0
		end
	end

	return self.hangTime <= self.recordMax, math.floor(Mathf.Min(self.recordTime, self.hangTime))
end

function M:CheckIsHang()
	return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Swing or gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Feisuo or gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Fall or gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.FaithLeap or gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.AirRush or gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.SwingOut
end

function M:OnInitCombo(comboNum)
	self.comboNum = comboNum
	self.comboMax = 0
	self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)

	function self.handler(eventId, data)
		if data.TaskId == self.taskId then
			self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)
end

function M:OnCheckCombo()
	local combo = 0

	for i = 1, #self.values do
		if self.values[i] > 0 then
			combo = combo + 1
		else
			self.comboMax = Mathf.Max(self.comboMax, combo)
			combo = 0
		end
	end

	return self.comboNum <= self.comboMax, Mathf.Min(self.comboMax, self.comboNum)
end

function M:OnDisposeCombo()
	gMessageManager:RemoveMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)

	self.values = nil
end

function M:OnInitMaxSpeedTime(speed, holdTime)
	self.speed = speed
	self.holdTime = holdTime
	self.isRecording = false
	self.recordMax = 0
	self.recordTime = 0
end

function M:OnCheckMaxSpeedTime()
	local speed = CarRaceManager.Instance:GetPlayerVehicleSpeed()

	if self.speed <= speed and not self.isRecording then
		self.isRecording = true
		self.startTime = gLogicTime.time
	end

	if self.isRecording then
		self.recordTime = gLogicTime.time - self.startTime
		self.recordMax = Mathf.Max(self.recordMax, self.recordTime)

		if speed < self.speed then
			self.isRecording = false
			self.recordTime = 0
		end
	end

	return self.holdTime <= self.recordMax, math.floor(Mathf.Min(self.holdTime, self.recordTime))
end

function M:OnInitCollect(needNum)
	self.needNum = needNum
	self.curNum = 0
	self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)

	function self.handler(eventId, data)
		if data.TaskId == self.taskId then
			self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)
end

function M:OnCheckCollect()
	local nowCounterValue = 0

	for i = 1, #self.values do
		nowCounterValue = self.values[i] + nowCounterValue
	end

	self.curNum = nowCounterValue

	return self.needNum <= self.curNum, Mathf.Min(self.curNum, self.needNum)
end

function M:OnDisposeCollect()
	gMessageManager:RemoveMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)

	self.values = nil
end

function M:OnInitFinishRank(expectedRank)
	self.expectedRank = expectedRank
	self.curRank = gCarRaceManager:GetPlayerRank()
	self.finishRank = nil

	function self.handler(eventId)
		if not self.finishRank then
			self.finishRank = self.curRank
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

function M:OnCheckFinishRank()
	self.curRank = gCarRaceManager:GetPlayerRank()

	return self.finishRank and self.finishRank <= self.expectedRank, self.curRank
end

function M:OnDisposeFinishRank()
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

function M:OnInitFinishInTime(timeLimit)
	self.timeLimit = timeLimit
	self.store = gStoreManager:GetStoreGroup("ChallengeCountDownPanelStore")
	self.beginTime = self.store.startTime or 0
	self.finishTime = nil

	function self.handler(eventId)
		if not self.finishTime then
			self.finishTime = gLogicTime.time
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

function M:OnCheckFinishInTime()
	self.beginTime = self.store.startTime or 0

	return self.finishTime and self.finishTime - self.beginTime <= self.timeLimit, gLogicTime.time - self.beginTime
end

function M:OnDisposeFinishInTime()
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

function M:OnInitCollectInTime(timeLimit, needNum)
	self.timeLimit = timeLimit
	self.needNum = needNum
	self.store = gStoreManager:GetStoreGroup("ChallengeCountDownPanelStore")
	self.beginTime = self.store.startTime or 0
	self.curNum = 0
	self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)

	function self.handler(eventId, data)
		if data.TaskId == self.taskId then
			self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)
end

function M:OnCheckCollectInTime()
	self.beginTime = self.store.startTime or 0

	if gLogicTime.time - self.beginTime <= self.timeLimit then
		local nowCounterValue = 0

		for i = 1, #self.values do
			nowCounterValue = self.values[i] + nowCounterValue
		end

		self.curNum = nowCounterValue
	end

	return self.needNum <= self.curNum, self.curNum
end

function M:OnDisposeCollectInTime()
	gMessageManager:RemoveMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)

	self.values = nil
end

function M:OnInitCollectWithoutLand(needNum)
	self.needNum = needNum
	self.curNum = 0
	self.lastCounterValue = 0
	self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)

	function self.handler(eventId, data)
		if data.TaskId == self.taskId then
			self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)
end

function M:OnCheckCollectWithoutLand()
	local nowCounterValue = 0

	for i = 1, #self.values do
		nowCounterValue = self.values[i] + nowCounterValue
	end

	if self.lastCounterValue < nowCounterValue then
		if self:CheckIsHang() then
			self.curNum = self.curNum + nowCounterValue - self.lastCounterValue
		end

		self.lastCounterValue = nowCounterValue
	end

	return self.needNum <= self.curNum, self.curNum
end

function M:OnDisposeCollectWithoutLand()
	gMessageManager:RemoveMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)

	self.values = nil
end

function M:OnInitMaxHangTime(timeLimit)
	self.timeLimit = timeLimit
	self.isFinish = false
	self.isRecording = false
	self.recordMax = 0
	self.recordTime = 0

	function self.handler(eventId)
		if not self.isFinish then
			self.isFinish = true
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

function M:OnCheckMaxHangTime()
	local hang = self:CheckIsHang()

	if hang and not self.isRecording then
		self.isRecording = true
		self.startTime = gLogicTime.time
		self.recordTime = 0
	end

	if self.isRecording then
		self.recordTime = gLogicTime.time - self.startTime
		self.recordMax = Mathf.Max(self.recordMax, self.recordTime)

		if not hang then
			self.isRecording = false
		end
	else
		self.recordTime = 0
	end

	return self.isFinish and self.recordMax < self.timeLimit, self.timeLimit <= self.recordMax and self.timeLimit or self.recordMax
end

function M:OnDisposeMaxHangTime()
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

function M:OnInitRemainHp(hpLimit)
	self.hpLimit = hpLimit
	self.isFinish = false

	function self.handler(eventId)
		if not self.isFinish then
			self.isFinish = true
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

function M:OnCheckRemainHp()
	local currentHp = gDataSetManager.myUnit.hp / gDataSetManager.myUnit.maxhp * 100

	return self.isFinish and self.hpLimit <= currentHp, currentHp
end

function M:OnDisposeRemainHp()
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

function M:OnInitBeHitNum(hitLimit)
	self.hitLimit = hitLimit
	self.isFinish = false

	function self.handler(eventId)
		if not self.isFinish then
			self.isFinish = true
		end
	end

	self.hitCount = 0
	self.unit = ScriptBattleUnit.New(gDataSetManager.myUnit.pid)

	function self.updateHandler(eventId, pid)
		if pid == gDataSetManager.myUnit.pid then
			self.hitCount = self.hitCount + Formula_cs:CalBeHitNumMult(self.unit)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
	gMessageManager:AddMessageListener(gEventConstants.UNIT_BE_ATTACKED, self.updateHandler)
end

function M:OnCheckBeHitNum()
	return self.isFinish and self.hitCount < self.hitLimit, self.hitCount
end

function M:OnDisposeBeHitNum()
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
	gMessageManager:RemoveMessageListener(gEventConstants.UNIT_BE_ATTACKED, self.updateHandler)
end

function M:OnInitKillNum(killLimit)
	self.killLimit = killLimit
	self.isFinish = false
	self.killCount = 0
	self.unit = ScriptBattleUnit.New(gDataSetManager.myUnit.pid)

	function self.updateHandler(eventId, data)
		self.killCount = self.killCount + Formula_cs:CalKillNumMult(self.unit)
	end

	gMessageManager:AddMessageListener(gEventConstants.UNIT_BE_KILLED, self.updateHandler)
end

function M:OnCheckKillNum()
	return self.killLimit <= self.killCount, self.killCount
end

function M:OnDisposeKillNum()
	gMessageManager:RemoveMessageListener(gEventConstants.UNIT_BE_KILLED, self.updateHandler)
end

function M:OnInitRemainTime(timeLimit)
	self.timeLimit = timeLimit
	self.store = gStoreManager:GetStoreGroup("ChallengeCountDownPanelStore")
	self.beginTime = self.store.startTime or 0
	self.endTime = self.store.endTime or 0
	self.finishTime = nil

	function self.handler(eventId)
		if not self.finishTime then
			self.finishTime = gLogicTime.time
		end
	end

	function self.updateHandler(_, state)
		if state then
			self.beginTime = self.store.startTime
			self.endTime = self.store.endTime
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
	gMessageManager:AddMessageListener(gEventConstants.BOSS_HP_PANEL_DOWN, self.updateHandler)
end

function M:OnCheckRemainTime()
	return self.finishTime and self.timeLimit <= self.endTime - gLogicTime.time, self.endTime - gLogicTime.time
end

function M:OnDisposeRemainTime()
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
	gMessageManager:RemoveMessageListener(gEventConstants.BOSS_HP_PANEL_DOWN, self.updateHandler)
end
