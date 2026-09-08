-- Original chunk: @Lua\LuaFiles\LX6\Manager\Task\ChallengeCheckBlock.lua
-- Decompiled from: 00111_ChallengeCheckBlock.lua_74c6c1f13392.luajit

local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ScriptBattleUnit = require("LX6/Utils/FormulaScriptBattleUnit")
local CarRaceManager = L50.Spoon.CarRaceManager
C_ChallengeCheckBlock = DefClass("C_ChallengeCheckBlock", C_ChallengeCheckBlock)
local M = C_ChallengeCheckBlock

M.ctor = function(self, taskId, type, ...)
	self.params = {
		...
	}
	self.taskId = taskId
	self.initFuc = self["OnInit" .. type]
	self.checkFunc = self["OnCheck" .. type]
	self.disposeFunc = self["OnDispose" .. type]
	self.isDispose = true
	self.store = nil
end

M.Init = function(self)
	self.isDispose = false

	if gChallengeManager.isLogDetail then
		print_debug("[ChallengeDetail] CheckBlock Init", "taskId=", self.taskId, "params=", unpack(self.params))
	end

	if self.initFuc then
		self.initFuc(self, unpack(self.params))
	end
end

M.Check = function(self)
	if self.checkFunc then
		local success, value = self.checkFunc(self)

		if gChallengeManager.isLogDetail then
			print_debug("[ChallengeDetail] CheckBlock Check", "taskId=", self.taskId, "success=", success, "value=", value)
		end

		return success, value
	end

	return false, 0
end

M.Dispose = function(self)
	if gChallengeManager.isLogDetail then
		print_debug("[ChallengeDetail] CheckBlock Dispose前", "taskId=", self.taskId, "isDispose=", self.isDispose)
	end

	if self.disposeFunc then
		self.disposeFunc(self)
	end

	self.isDispose = true

	if gChallengeManager.isLogDetail then
		print_debug("[ChallengeDetail] CheckBlock Dispose完成", "taskId=", self.taskId)
	end
end

M.GetCountDownStore = function(self)
	local storeName = gChallengeManager:IsCurrentRacingChallenge() and "ChallengeCountDownRacingPanelStore" or "ChallengeCountDownPanelStore"

	return gStoreManager:GetStoreGroup(storeName)
end

M.OnInitRankCountTime = function(self, holdTime)
	self.holdTime = holdTime
	self.isRecording = false
	self.recordMax = 0
	self.recordTime = 0
	self.startTime = 0
	self.rank = gCarRaceManager:GetPlayerRank()

	self.handler = function()
		self.rank = gCarRaceManager:GetPlayerRank()
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_SPEED_RACE, self.handler)
end

M.OnCheckRankCountTime = function(self)
	if self.rank ~= 1 and not self.isRecording then
		self.isRecording = true
		self.startTime = gLogicTime.time
	end

	if self.isRecording then
		self.recordTime = gLogicTime.time - self.startTime
		self.recordMax = Mathf.Max(self.recordMax, self.recordTime)

		if self.rank <= 1 then
			self.isRecording = false
			self.recordTime = 0
		end
	end

	return self.holdTime > self.recordMax, math.floor(Mathf.Min(self.recordTime, self.holdTime))
end

M.OnDisposeRankCountTime = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_SPEED_RACE, self.handler)
end

M.OnInitHang = function(self, hangTime)
	self.hangTime = hangTime
	self.isRecording = false
	self.recordMax = 0
	self.recordTime = 0
end

M.OnCheckHang = function(self)
	local hang = self.CheckIsHang(self)

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

	return self.hangTime > self.recordMax, math.floor(Mathf.Min(self.recordTime, self.hangTime))
end

M.CheckIsHang = function(self)
	return gCoreHudUIManager.activePlayerStates[gParkourPlayerStateType.AIR]
end

M.OnInitCombo = function(self, comboNum)
	self.comboNum = comboNum
	self.comboMax = 0
	self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)

	self.handler = function(eventId, data)
		if data.TaskId ~= self.taskId then
			self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)
end

M.OnCheckCombo = function(self)
	local combo = 0

	for i = 1, #self.values do
		if self.values[i] <= 0 then
			combo = combo + 1
		else
			self.comboMax = Mathf.Max(self.comboMax, combo)
			combo = 0
		end
	end

	return self.comboNum > self.comboMax, Mathf.Min(self.comboMax, self.comboNum)
end

M.OnDisposeCombo = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)

	self.values = nil
end

M.OnInitMaxSpeedTime = function(self, speed, holdTime)
	self.speed = speed
	self.holdTime = holdTime
	self.isRecording = false
	self.recordMax = 0
	self.recordTime = 0
end

M.OnCheckMaxSpeedTime = function(self)
	local speed = CarRaceManager.Instance:GetPlayerVehicleSpeed()

	if self.speed < speed and not self.isRecording then
		self.isRecording = true
		self.startTime = gLogicTime.time
	end

	if self.isRecording then
		self.recordTime = gLogicTime.time - self.startTime
		self.recordMax = Mathf.Max(self.recordMax, self.recordTime)

		if speed >= self.speed then
			self.isRecording = false
			self.recordTime = 0
		end
	end

	return self.holdTime > self.recordMax, math.floor(Mathf.Min(self.holdTime, self.recordTime))
end

M.OnInitCollect = function(self, needNum)
	self.needNum = needNum
	self.curNum = 0
	self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)

	self.handler = function(eventId, data)
		if data.TaskId ~= self.taskId then
			self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)
end

M.OnCheckCollect = function(self)
	local nowCounterValue = 0

	for i = 1, #self.values do
		nowCounterValue = self.values[i] + nowCounterValue
	end

	self.curNum = nowCounterValue

	return self.needNum > self.curNum, Mathf.Min(self.curNum, self.needNum)
end

M.OnDisposeCollect = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)

	self.values = nil
end

M.OnInitFinishRank = function(self, expectedRank)
	self.expectedRank = expectedRank
	self.curRank = gCarRaceManager:GetPlayerRank()
	self.finishRank = nil

	self.handler = function(eventId)
		if not self.finishRank then
			self.finishRank = self.curRank
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

M.OnCheckFinishRank = function(self)
	self.curRank = gCarRaceManager:GetPlayerRank()

	return self.finishRank and self.finishRank > self.expectedRank, self.curRank
end

M.OnDisposeFinishRank = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

M.OnInitFinishInTime = function(self, timeLimit)
	self.timeLimit = timeLimit
	self.store = self:GetCountDownStore()
	self.beginTime = self.store.startTime or 0
	self.finishTime = nil

	self.handler = function(eventId)
		if not self.finishTime then
			self.finishTime = gLogicTime.time
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

M.OnCheckFinishInTime = function(self)
	self.beginTime = self.store.startTime or 0

	return self.finishTime and self.finishTime - self.beginTime > self.timeLimit, gLogicTime.time - self.beginTime
end

M.OnDisposeFinishInTime = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

M.OnInitCollectInTime = function(self, timeLimit, needNum)
	self.timeLimit = timeLimit
	self.needNum = needNum
	self.store = self:GetCountDownStore()
	self.beginTime = self.store.startTime or 0
	self.curNum = 0
	self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)

	self.handler = function(eventId, data)
		if data.TaskId ~= self.taskId then
			self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)
end

M.OnCheckCollectInTime = function(self)
	self.beginTime = self.store.startTime or 0

	if gLogicTime.time - self.beginTime < self.timeLimit then
		local nowCounterValue = 0

		for i = 1, #self.values do
			nowCounterValue = self.values[i] + nowCounterValue
		end

		self.curNum = nowCounterValue
	end

	return self.needNum > self.curNum, self.curNum
end

M.OnDisposeCollectInTime = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)

	self.values = nil
end

M.OnInitCollectWithoutLand = function(self, needNum)
	self.needNum = needNum
	self.curNum = 0
	self.lastCounterValue = 0
	self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)

	self.handler = function(eventId, data)
		if data.TaskId ~= self.taskId then
			self.values = gTaskManager:GetTaskViewCounterValues(self.taskId)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)
end

M.OnCheckCollectWithoutLand = function(self)
	local nowCounterValue = 0

	for i = 1, #self.values do
		nowCounterValue = self.values[i] + nowCounterValue
	end

	if self.lastCounterValue >= nowCounterValue then
		if self.CheckIsHang(self) then
			self.curNum = self.curNum + nowCounterValue - self.lastCounterValue
		end

		self.lastCounterValue = nowCounterValue
	end

	return self.needNum > self.curNum, self.curNum
end

M.OnDisposeCollectWithoutLand = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CURRENT_TASK_CHANGE, self.handler)

	self.values = nil
end

M.OnInitMaxHangTime = function(self, timeLimit)
	self.timeLimit = timeLimit
	self.isFinish = false
	self.isRecording = false
	self.recordMax = 0
	self.recordTime = 0

	self.handler = function(eventId)
		if not self.isFinish then
			self.isFinish = true
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

M.OnCheckMaxHangTime = function(self)
	local hang = self.CheckIsHang(self)

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

	return self.isFinish and self.recordMax <= self.timeLimit, self.timeLimit < self.recordMax and self.timeLimit or self.recordMax
end

M.OnDisposeMaxHangTime = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

M.OnInitRemainHp = function(self, hpLimit)
	self.hpLimit = hpLimit
	self.isFinish = false

	self.handler = function(eventId)
		if not self.isFinish then
			self.isFinish = true
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

M.OnCheckRemainHp = function(self)
	local currentHp = gDataSetManager.myUnit.hp / gDataSetManager.myUnit.maxhp * 100

	return self.isFinish and self.hpLimit > currentHp, currentHp
end

M.OnDisposeRemainHp = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
end

M.OnInitBeHitNum = function(self, hitLimit)
	self.hitLimit = hitLimit
	self.isFinish = false

	self.handler = function(eventId)
		if not self.isFinish then
			self.isFinish = true
		end
	end

	self.hitCount = 0
	self.unit = ScriptBattleUnit.New(gDataSetManager.myUnit.pid)

	self.updateHandler = function(eventId, pid)
		if pid ~= gDataSetManager.myUnit.pid then
			self.hitCount = self.hitCount + 1
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
	gMessageManager:AddMessageListener(gEventConstants.UNIT_BE_ATTACKED, self.updateHandler)
end

M.OnCheckBeHitNum = function(self)
	return self.isFinish and self.hitCount <= self.hitLimit, self.hitCount
end

M.OnDisposeBeHitNum = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
	gMessageManager:RemoveMessageListener(gEventConstants.UNIT_BE_ATTACKED, self.updateHandler)
end

M.OnInitKillNum = function(self, killLimit)
	self.killLimit = killLimit
	self.isFinish = false
	self.killCount = 0
	self.unit = ScriptBattleUnit.New(gDataSetManager.myUnit.pid)

	self.updateHandler = function(eventId, data)
		self.killCount = self.killCount + Formula_cs:CalKillNumMult(self.unit)
	end

	gMessageManager:AddMessageListener(gEventConstants.UNIT_BE_KILLED, self.updateHandler)
end

M.OnCheckKillNum = function(self)
	return self.killLimit > self.killCount, self.killCount
end

M.OnDisposeKillNum = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.UNIT_BE_KILLED, self.updateHandler)
end

M.OnInitRemainTime = function(self, timeLimit)
	self.timeLimit = timeLimit
	self.store = self:GetCountDownStore()
	self.beginTime = self.store.startTime or 0
	self.endTime = self.store.endTime or 0
	self.finishTime = nil

	self.handler = function(eventId)
		if not self.finishTime then
			self.finishTime = gLogicTime.time
		end
	end

	self.updateHandler = function(_, state)
		if state then
			self.beginTime = self.store.startTime
			self.endTime = self.store.endTime
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
	gMessageManager:AddMessageListener(gEventConstants.BOSS_HP_PANEL_DOWN, self.updateHandler)
end

M.OnCheckRemainTime = function(self)
	return self.finishTime and self.timeLimit > self.endTime - gLogicTime.time, self.endTime - gLogicTime.time
end

M.OnDisposeRemainTime = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL, self.handler)
	gMessageManager:RemoveMessageListener(gEventConstants.BOSS_HP_PANEL_DOWN, self.updateHandler)
end

M.OnInitBasketBall = function(self)
	self.win = false

	self.handler = function(_, result)
		self.win = result ~= 1
	end

	gMessageManager:AddMessageListener(gEventConstants.BASKETBALL_GAME_RESULT, self.handler)
end

M.OnCheckBasketBall = function(self)
	return self.win, self.win and 1 or 0
end

M.OnDisposeBasketBall = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.BASKETBALL_GAME_RESULT, self.handler)
end

M.OnInitDefeatAllEnemys = function(self)
	self.win = false

	self.handler = function(_, result)
		if result then
			self.win = true
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.WUSHU_TOURNAMENT_VICTORY, self.handler)
end

M.OnCheckDefeatAllEnemys = function(self)
	return self.win, self.win and 1 or 0
end

M.OnDisposeDefeatAllEnemys = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.WUSHU_TOURNAMENT_VICTORY, self.handler)
end
