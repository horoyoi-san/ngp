local DataSet = require("LX6/DataBind/DataSet")
local ChallengeConfig = LTConfig.ChallengeConfig
local ChallengeParamConfig = LTConfig.ChallengeParamConfig
local TaskState = UX.Game.TaskState
local TaskEventState = UX.Game.TaskEventState
local ChallengeType = LTConfig.ChallengeConfig.ChallengeTypeType
local CombatTrainingConfig = LTConfig.CombatTrainingConfig
local CombatTrainingTabConfig = LTConfig.CombatTrainingTabConfig
local JobClassConfig = LTConfig.UrbanJobJobClassConfig
C_ChallengeManager = DefClass("C_ChallengeManager", C_ChallengeManager)
local M = C_ChallengeManager

function M:ctor()
	self.MedalStatusEnum = {
		empty = 0,
		silver = 2,
		gold = 3,
		copper = 1
	}
	self.CounterTypeEnum = {
		combo = 4,
		rank = 5,
		timeCount = 2,
		hang = 3,
		taskCounter = 1
	}
	self.ChallengeJobType = {
		Racer = 1,
		None = 0
	}
	self.currentChallengeId = -1
	self.currentChallengeTaskId = -1
	self.counterData = {}
	self.challengeData = DataSet.New({
		IsChallenging = false
	})
	self.coroutineData = {}
	self.taskRelatedChallengeIdTable = {}

	for index = 0, ChallengeConfig.count - 1 do
		local curChallengeCfg = ChallengeConfig.LoadAt(index)

		for i = 1, #curChallengeCfg.RelatedTask do
			self.taskRelatedChallengeIdTable[curChallengeCfg.RelatedTask[i]] = curChallengeCfg.Id
		end
	end

	local freeCombatCfg = CombatTrainingConfig.GetConfig(CombatTrainingConfig.Free)
	self.freeCombatTraingTaskId = freeCombatCfg and freeCombatCfg.TaskId or 0

	self:EndOfOnlineChallenge()
	gMessageManager:AddMessageListener(gEventConstants.TASK_STATE_CHANGED, self:CreateAction(self.OnTaskStatusChange))
end

function M:Log(...)
	if gGameManager.Env.isEditor then
		print_debug("[C_ChallengeManager]", ...)
	end
end

function M:OnTaskStatusChange(eventId, taskData)
	local curTaskId = taskData[1]
	local state = taskData[2]

	self:Log("OnTaskStatusChange", curTaskId, state)

	if self:GetChallengeIdByTaskId(curTaskId) ~= nil and curTaskId ~= self.currentChallengeTaskId and state == TaskState.Accepted then
		self.currentChallengeTaskId = curTaskId
		self.currentChallengeId = self:GetChallengeIdByTaskId(curTaskId)
		self.challengeData.IsChallenging = true
		self.counterData = {}

		self:StartChallenge(curTaskId)
	elseif self.currentChallengeTaskId == curTaskId and state ~= TaskState.Accepted then
		local isSubmited = state == TaskState.Submited

		if isSubmited then
			gMessageManager:SendMessage(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL)
		end

		self:EndChallenge(self.currentChallengeId)

		self.preTaskId = self.currentChallengeTaskId
		self.preChallengeId = self.currentChallengeId
		self.preCounterData = self.counterData
		self.currentChallengeTaskId = -1
		self.currentChallengeId = -1
		self.challengeData.IsChallenging = false

		if isSubmited then
			self:_PullChallengeResult()
		end
	end
end

function M:GetTaskIdByChallengeId(challengeId)
	local cfg = ChallengeConfig.GetConfig(challengeId)

	if not cfg then
		return nil
	end

	return cfg.RelatedTask[1]
end

function M:GetChallengeIdByTaskId(taskId)
	return self.taskRelatedChallengeIdTable[taskId]
end

function M:GetChallengeConfigByTaskId(taskId)
	if self.taskRelatedChallengeIdTable[taskId] ~= nil then
		return ChallengeConfig.GetConfig(self.taskRelatedChallengeIdTable[taskId])
	else
		print_error("错误！尝试获取一个不在Collection Challenge表的任务的Challenge Config信息，请先让策划给该挑战任务配Challenge表！TaskId：", taskId)
	end
end

function M:TransferRewardLevelToMedal(medalIndex, rewardLevel)
	if medalIndex <= rewardLevel then
		return medalIndex
	else
		return self.MedalStatusEnum.empty
	end
end

function M:GetChallengeParamStruct(paramId, value)
	local cfg = ChallengeParamConfig.GetConfig(paramId)
	local pattern = "%%s"

	if not cfg then
		return {}
	end

	local desNumType = cfg.DesNumType
	local index = 1
	local flag = 0
	local name = cfg.Name:gsub(pattern, function (match)
		if desNumType[index] == 1 then
			index = index + 1

			return match
		else
			index = index + 1
			flag = flag + 1

			return value["value" .. flag]
		end
	end)
	local ele = {
		isFirst = true,
		realValue = 0,
		name = name,
		paramId = paramId,
		value = value,
		desc = gString.Format(name, 0)
	}

	return ele
end

function M:GetChallengeJobType(taskId)
	local cfg = self:GetChallengeConfigByTaskId(taskId)

	if cfg == nil then
		return self.ChallengeJobType.None
	end

	if cfg.UrbanJobType == JobClassConfig.Racer then
		return self.ChallengeJobType.Racer
	end

	return self.ChallengeJobType.None
end

function M:InitCounterValue(challengeLists)
	for i = 1, #challengeLists do
		self.counterData[i] = false
	end
end

function M:SetCounterValue(counterId, newValue)
	self.counterData[counterId] = newValue

	gMessageManager:SendMessage(gEventConstants.CHALLENGE_SUB_COUNTER_VALUE_CHANGED, counterId)
end

function M:GetChallengeData()
	return self.preChallengeId, self.preTaskId, self.preCounterData
end

function M:GetChallengeScore()
	return self.score
end

function M:CommonChallengeResult(nodeId)
	return
end

function M:_PullChallengeResult()
	local currentChallengeId, currentChallengeTaskId, counterData = self:GetChallengeData()
	local score = self:GetChallengeScore()

	self:Log("CommonChallengeResult", currentChallengeId, currentChallengeTaskId, counterData)

	gClientToGameDelegate:SetNewChallengeData(currentChallengeId, counterData, score).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end
	end
end

function M:GetParamDescription(paramId, value)
	local cfg = ChallengeParamConfig.GetConfig(paramId)

	return gString.Format(cfg.Name, value.value1, value.value2, value.value3, value.value4)
end

function M:GenCheckBlock(taskId, paramId, value)
	local cfg = ChallengeParamConfig.GetConfig(paramId)
	local block = C_ChallengeCheckBlock.new(taskId, cfg.CheckName, value.value1, value.value2, value.value3, value.value4)

	block:Init()

	return block
end

function M:StartChallenge(taskId)
	local store = gStoreManager:GetStoreGroup("NormalTaskPanelStore")

	store:OnGoalStart(taskId)

	self.beginTime = gLogicTime.time
end

function M:EndChallenge(challengeId)
	self:Log("EndChallenge", challengeId)

	local store = gStoreManager:GetStoreGroup("NormalTaskPanelStore")

	store:OnGoalEnd()

	local cfg = ChallengeConfig.GetConfig(challengeId)
	local challengeType = cfg and cfg.ChallengeType or 0

	if challengeType == ChallengeType.Racing then
		self.score = gCarRaceManager:GetPlayerRank()
	else
		self.score = gLogicTime.time - (self.beginTime or 0)
	end
end

function M:OpenFinalRankPanel(isOnline)
	local rankList, title = nil

	if not isOnline then
		rankList = gCarRaceManager:GetFinalRankData()
	else
		rankList = self.onlineChallengeData
		title = gLinkManager:GetPlayModeName(gLinkManager.targetPlayId)
	end

	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_RANK_PANEL, {
		data = rankList,
		isOnline = isOnline,
		title = title
	})
end

function M:ExitFinalRankPanel()
	gPanelManager:Close(gPanelId.S_CHALLENGE_RANK_PANEL)
	gBlackScreenManager:AutoTransition(gBlackScreenId.CHALLENGE_RANK_PANEL, "", false, false, 0, 3, 0)
end

function M:OpenMapByChallengeId(challengeId)
	local taskId = self:GetTaskIdByChallengeId(challengeId)

	if taskId then
		local autoSelectGpsId = gMapSubSystem_Task:GetFirstGpsIdByTaskId(taskId)

		if autoSelectGpsId then
			gMapUtils:CheckRaidCanOpenMap({
				autoSelectGpsId = autoSelectGpsId
			})

			return true
		end
	end

	gMapUtils:CheckRaidCanOpenMap({
		indoorId = 0,
		raidId = gSceneDataMgr.CurrentRaidId
	})

	return false
end

function M:OnSyncOnlineChallengeData(data, success)
	local ret = {}
	local tIndex = gLinkManager:CheckIsInRace() and 1 or 2

	if gLinkManager:CheckHasDuty() then
		tIndex = 3
	end

	for i = 1, #data do
		local playerData = data[i]
		local vehicleCfg = LTConfig.VehicleConfig.GetConfig(playerData.VehicleId)
		local ele = {
			tIndex = tIndex,
			id = playerData.Pid,
			vehicle = {
				name = vehicleCfg and vehicleCfg.VehicleName or "",
				icon = vehicleCfg and vehicleCfg.SVehicleBrandIcon or 0
			},
			award = {},
			time = playerData.ElapsedTime >= 0 and playerData.ElapsedTime or math.huge,
			isSuccess = success
		}

		if playerData.Pid == gPlayerManager.infoLogin.bindData.pid and playerData.Result ~= UX.Game.CompleteStatus.Init and not self.isOnlineChallengeSelfEnd then
			self.isOnlineChallengeSelfEnd = true
		end

		table.insert(ret, ele)
	end

	table.sort(ret, function (a, b)
		if a.time == b.time then
			return a.id < b.id
		end

		return a.time < b.time
	end)

	self.onlineChallengeData = ret

	if self.isOnlineChallengeSelfEnd then
		gLinkManager:OnMatchEnd(success)
	end
end

function M:EndOfOnlineChallenge()
	self.onlineChallengeData = {}
	self.isOnlineChallengeSelfEnd = false
end

function M:StartTraining(taskId)
	gMapUtils:DoAcceptTask(taskId, function ()
		gPanelManager:Close(gPanelId.TRANING_PANEL)
	end)
end

function M:CheckConfigIsOpen(cfg)
	if cfg.AgentTag ~= 0 and gNpcFavorManager:GetCurrentAgentType() ~= cfg.AgentTag then
		return false
	end

	local taskLine = gTaskNodeManager:GetTaskLineByTask(cfg.TaskId)
	local lineState = gTaskManager:GetTaskEventState(taskLine.TaskLineId)

	return lineState ~= TaskEventState.Locked
end

function M:GetCurrentTrainingList(tabIndex)
	local ret = {}

	for i = 0, CombatTrainingConfig.count - 1 do
		local cfg = CombatTrainingConfig.LoadAt(i)

		if cfg.TabId == tabIndex and self:CheckConfigIsOpen(cfg) then
			ret[#ret + 1] = cfg.Id
		end
	end

	return ret
end

function M:GetCurrentTrainingTab()
	local ret = {}

	for i = 1, CombatTrainingTabConfig.count - 1 do
		local cfg = CombatTrainingTabConfig.LoadAt(i)
		local ele = {
			id = cfg.Id,
			title = cfg.Title
		}

		table.insert(ret, ele)
	end

	return ret
end

function M:AskNewChallengeRecord(id, callback)
	gClientToGameDelegate:AskNewChallengeRecord(id).Callback = function (err, challengeRecord)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		if callback then
			callback(challengeRecord)
		end
	end
end

function M:AskFinishNewChallenge(challengeId, callback)
	self:Log("AskFinishNewChallenge", challengeId)

	gClientToGameDelegate:FinishNewChallenge(challengeId, self.preTaskId).Callback = function (err, challengeResult)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		if callback then
			callback(challengeResult)
		end
	end
end

gChallengeManager = gChallengeManager or C_ChallengeManager.new()
