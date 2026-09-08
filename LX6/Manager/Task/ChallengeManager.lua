-- Original chunk: @Lua\LuaFiles\LX6\Manager\Task\ChallengeManager.lua
-- Decompiled from: 00358_ChallengeManager.lua_f861798f1798.luajit

local DataSet = require("LX6/DataBind/DataSet")
local ChallengeConfig = LTConfig.ChallengeConfig
local ChallengeParamConfig = LTConfig.ChallengeParamConfig
local WushuTournamentOpponentConfig = LTConfig.WushuTournamentOpponentConfig
local TaskState = UX.Game.TaskState
local TaskEventState = UX.Game.TaskEventState
local ChallengeType = LTConfig.ChallengeConfig.ChallengeTypeType
local CombatTrainingConfig = LTConfig.CombatTrainingConfig
local CombatTrainingTabConfig = LTConfig.CombatTrainingTabConfig
local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local MessageConfig = LTConfig.MessageConfig
C_ChallengeManager = DefClass("C_ChallengeManager", C_ChallengeManager)
local M = C_ChallengeManager

M.ctor = function(self)
	self.MedalStatusEnum = {
		["H\\xa3\\xb2\\xbb\\xaf"] = 0,
		["A\\x9d\\x98\\x86S"] = 2,
		["}-q_"] = 3,
		["G\\x81\\x9e\\x86S"] = 1
	}
	self.CounterTypeEnum = {
		["N\\xa1\\xaf\\xad\\xb9"] = 4,
		["h#sP"] = 5,
		["WNalm,"] = 2,
		["r#s\\"] = 3,
		["\\x8b534[\\x92T\\xd7#\\xaf\\xab"] = 1
	}
	self.ChallengeJobType = {
		["\\xaf\\xa1\\xaa\\xa4"] = 1,
		["T-s^"] = 0
	}
	self.currentChallengeId = -1
	self.currentChallengeTaskId = -1
	self.counterData = {}
	self.settlementCtx = nil
	self.challengeResultCache = {}
	self.challengeData = DataSet.New({
		["+\\xf0|$\\xdc\\xb3O\\xa6_\\xbe\\xb1"] = false
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
	self.hidePanel = false
	self.showRank = false
	self.isDebug = false
	self.isLogDetail = false

	self:_ResetRacingSettleState()
	self:EndOfOnlineChallenge()

	self.taskStateChangeHandler = nil

	self:RegisterTaskStateChangeEvent()
	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self:CreateAction(self.OnAfterSwitchScene))

	self.onlineRacerChallengeId = nil
	self.isWushuMode = false
	self.curWushuData = nil
	self.curWushuRoundCfg = nil
	self.curWushuTaskId = 0
	self.curWushuRoundId = 0
	self.curWushuOpponentId = 0
end

M.Log = function(self, ...)
	if self.isDebug then
		print_debug("[ChallengeManager]", ...)
	end
end

M.LogDetail = function(self, ...)
	if self.isLogDetail then
		print_debug("[ChallengeManager][Detail]", ...)
	end
end

M.RegisterTaskStateChangeEvent = function(self)
	self:UnregisterTaskStateChangeEvent()

	self.taskStateChangeHandler = self:CreateAction(self.OnTaskStatusChange)

	gMessageManager:AddMessageListener(gEventConstants.TASK_STATE_CHANGED, self.taskStateChangeHandler)
end

M.UnregisterTaskStateChangeEvent = function(self)
	if not self.taskStateChangeHandler then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.TASK_STATE_CHANGED, self.taskStateChangeHandler)

	self.taskStateChangeHandler = nil
end

M.OnAfterSwitchScene = function(self, _, switchSceneEventParams)
	if switchSceneEventParams.switchSceneType == gSwitchSceneType.Reconnect then
		return
	end

	if self.currentChallengeTaskId ~= -1 then
		return
	end

	local state = gTaskManager:GetTaskState(self.currentChallengeTaskId)

	if state == TaskState.Accepted then
		self:Log("OnAfterSwitchScene: 重连后任务已结束，清理残留 taskId=%s state=%s", self.currentChallengeTaskId, state)
		self:_SealChallenge()
	end
end

M.OnTaskStatusChange = function(self, _, taskData)
	local curTaskId = taskData[1]
	local state = taskData[2]

	self:Log("OnTaskStatusChange", curTaskId, state)

	if self.currentChallengeTaskId == curTaskId and state ~= TaskState.Accepted then
		local newChallengeId = self:GetChallengeIdByTaskId(curTaskId)

		if not newChallengeId or newChallengeId < 0 then
			return
		end

		if self.challengeData.IsChallengeing then
			self:Log("OnTaskStatusChange: 接到新挑战时，当前已有未结束的挑战，先清理旧挑战数据")
			self:_SealChallenge()
		end

		self:_ResetRacingSettleState()

		local cfg = ChallengeConfig.GetConfig(newChallengeId)

		if cfg and cfg.UrbanJobType ~= JobClassConfig.RacingDriver then
			self.onlineRacerChallengeId = newChallengeId
		end

		if not self:IsInOnlineMode() then
			self:StartChallenge(curTaskId, newChallengeId)
		end
	elseif self.currentChallengeTaskId ~= curTaskId and state == TaskState.Accepted then
		self:_SealChallenge()

		if state ~= TaskState.Submited then
			self:_PullChallengeResult()

			local cfg = self.settlementCtx.cfg

			if table.isNilOrEmpty(cfg.CountersDescription) then
				self.hidePanel = true
			else
				self.hidePanel = self.hidePanel
			end

			local ctx = self.settlementCtx

			self:AskFinishNewChallenge(ctx.challengeId, ctx.taskId, function ()
				if cfg and cfg.UrbanJobType ~= JobClassConfig.RacingDriver then
					return
				end

				if not self.hidePanel then
					gPanelManager:CheckShow(gPanelId.S_CHALLENGE_ENDING_PANEL, {
						taskId = ctx.taskId,
						challengeId = ctx.challengeId,
						showRank = self.showRank,
						counterData = ctx.counterData
					})
				end
			end)

			return
		end

		if state ~= TaskState.Aborted then
			local cfg = self:GetChallengeConfigByTaskId(curTaskId)
			local isRacer = cfg.UrbanJobType ~= JobClassConfig.RacingDriver

			if isRacer then
				self:Log("挑战失败，显示失败动画，赛车挑战才有")
				self:ShowEndPanel(false)
			end
		end
	end
end

M.OnEndOfChallenge = function(self, showRank, hidePanel)
	self:Log("OnEndOfChallenge", hidePanel, showRank)

	self.hidePanel = hidePanel
	self.showRank = showRank
end

M._SealChallenge = function(self)
	if self.currentChallengeId ~= -1 then
		return
	end

	gMessageManager:SendMessage(gEventConstants.CHALLENGE_PANEL_CLOSE_SIGNAL)

	local challengeId = self.currentChallengeId

	self:EndChallenge(challengeId)

	self.settlementCtx = self:_BuildSettlementContext()
	self.currentChallengeTaskId = -1
	self.currentChallengeId = -1
end

M._BuildSettlementContext = function(self)
	return {
		taskId = self.currentChallengeTaskId,
		challengeId = self.currentChallengeId,
		cfg = ChallengeConfig.GetConfig(self.currentChallengeId),
		counterData = self.counterData,
		score = self.score
	}
end

M.GetTaskIdByChallengeId = function(self, challengeId)
	local cfg = ChallengeConfig.GetConfig(challengeId)

	if not cfg then
		return nil
	end

	return cfg.RelatedTask[1]
end

M.GetChallengeIdByTaskId = function(self, taskId)
	return self.taskRelatedChallengeIdTable[taskId]
end

M.GetChallengeConfigByTaskId = function(self, taskId)
	if self.isWushuMode and taskId ~= self.curWushuTaskId then
		return self:BuildWushuAdaptCfg()
	end

	if self.taskRelatedChallengeIdTable[taskId] == nil then
		return ChallengeConfig.GetConfig(self.taskRelatedChallengeIdTable[taskId])
	else
		print_error("错误！尝试获取一个不在Challenge表的任务的配表信息，请先让策划给该挑战任务配Challenge表！TaskId：", taskId)

		return nil
	end
end

M.TransferRewardLevelToMedal = function(self, medalIndex, rewardLevel)
	if medalIndex < rewardLevel then
		return medalIndex
	else
		return self.MedalStatusEnum.empty
	end
end

M.GetChallengeParamStruct = function(self, paramId, value)
	local cfg = ChallengeParamConfig.GetConfig(paramId)
	local pattern = "%%s"

	if not cfg then
		return {}
	end

	local desNumType = cfg.DesNumType
	local index = 1
	local flag = 0
	local name = cfg.Name:gsub(pattern, function (match)
		if desNumType[index] ~= 1 then
			index = index + 1

			return match
		else
			index = index + 1
			flag = flag + 1

			return value["value" .. flag]
		end
	end)
	local ele = {
		["\\xd0\\xc827\\xe5"] = true,
		["\t\r"] = 0,
		["QBmex="] = 0,
		name = name,
		paramId = paramId,
		value = value,
		desc = gString.Format(name, 0)
	}

	return ele
end

M.GetChallengeJobType = function(self, taskId)
	local cfg = self:GetChallengeConfigByTaskId(taskId)

	if cfg ~= nil then
		return self.ChallengeJobType.None
	end

	if cfg.ChallengeType ~= ChallengeType.Racing then
		return self.ChallengeJobType.Racer
	end

	return self.ChallengeJobType.None
end

M.IsInOnlineMode = function(self)
	return gClientUtils:CheckIsLinkMode()
end

M.InitCounterValue = function(self, challengeLists)
	for i = 1, #challengeLists do
		self.counterData[i] = false
	end
end

M.SetCounterValue = function(self, counterId, newValue)
	self.counterData[counterId] = newValue

	gMessageManager:SendMessage(gEventConstants.CHALLENGE_SUB_COUNTER_VALUE_CHANGED, counterId)
end

M.GetChallengeData = function(self)
	local ctx = self.settlementCtx

	if not ctx then
		return nil, , {}
	end

	return ctx.challengeId, ctx.taskId, ctx.counterData
end

M.GetChallengeScore = function(self)
	return self.score
end

M.CommonChallengeResult = function(self, nodeId)
end

M._PullChallengeResult = function(self)
	local ctx = self.settlementCtx

	if not ctx then
		return
	end

	if self:IsInOnlineMode() then
		self:Log("_PullChallengeResult skipped: online mode", ctx.challengeId)

		return
	end

	self:Log("_PullChallengeResult", ctx.challengeId, ctx.taskId, ctx.counterData)

	gClientToGameDelegate:SetNewChallengeData(ctx.challengeId, ctx.counterData, ctx.score).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)
		end
	end
end

M.GetParamDescription = function(self, paramId, value)
	local cfg = ChallengeParamConfig.GetConfig(paramId)

	return gString.Format(cfg.Name, value.value1, value.value2, value.value3, value.value4)
end

M.GenCheckBlock = function(self, taskId, paramId, value)
	if self:IsInOnlineMode() then
		self:Log("GenCheckBlock skipped: online mode", taskId, paramId)

		return nil
	end

	local cfg = ChallengeParamConfig.GetConfig(paramId)

	self:LogDetail("GenCheckBlock Init前 taskId=%s paramId=%s checkName=%s params=%s,%s,%s,%s", taskId, paramId, cfg.CheckName, value.value1, value.value2, value.value3, value.value4)

	local block = C_ChallengeCheckBlock.new(taskId, cfg.CheckName, value.value1, value.value2, value.value3, value.value4)

	block:Init()
	self:LogDetail("GenCheckBlock Init后 taskId=%s isDispose=%s", taskId, tostring(block.isDispose))

	return block
end

M.StartChallenge = function(self, taskId, challengeId)
	self:Log("开始挑战", taskId, challengeId)

	self.currentChallengeTaskId = taskId
	self.currentChallengeId = challengeId
	self.challengeResultCache[self.currentChallengeId] = nil
	self.challengeData.IsChallenging = true

	gMessageManager:SendMessage(gEventConstants.CHALLENGE_GOAL_START, taskId)

	self.beginTime = gLogicTime.time
end

M.EndChallenge = function(self, challengeId)
	self:Log("结束挑战", challengeId)
	gMessageManager:SendMessage(gEventConstants.CHALLENGE_GOAL_END, challengeId)

	local cfg = ChallengeConfig.GetConfig(challengeId)
	local challengeType = cfg and cfg.ChallengeType or 0

	if challengeType ~= ChallengeType.Racing then
		self.score = gCarRaceManager:GetPlayerRank()
	else
		self.score = gLogicTime.time - (self.beginTime or 0)
	end

	self.challengeData.IsChallenging = false
end

M.TryExit = function(self)
	local rightCallBack = function()
		if self.isWushuMode then
			gWushuTournamentManager:LeaveWushuTournament()
		else
			local taskId = self.currentChallengeTaskId

			gClientToGameDelegate:AskDeleteTask(taskId, true).Callback = function (err)
				if err == 0 then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		end
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.ChallengeFinish, rightCallBack, nil)
end

M.ShowRacingEndingPanel = function(self, cfg)
	local finalRankData = self.carRaceChallengeData
	local playerRankEntry = nil
	local playerRank = 1
	slot5 = ipairs
	slot7 = finalRankData or {}

	for i, entry in slot5(slot7) do
		if entry.isSelf then
			playerRankEntry = entry
			playerRank = i

			break
		end
	end

	local counterData = self.counterData

	gPanelManager:CheckShow(gPanelId.CHALLENGE_RANK_ENDING_PANEL, {
		["O\\xab\\xb1\\xbb\\xe7"] = false,
		rank = playerRank,
		time = playerRankEntry and playerRankEntry.time or 0,
		bestLapTime = playerRankEntry and playerRankEntry.bestLapTime or 0,
		player = playerRankEntry and playerRankEntry.player or {
			["t#p^"] = ""
		},
		vehicle = playerRankEntry and playerRankEntry.vehicle or {
			["t#p^"] = ""
		},
		best2 = playerRankEntry and playerRankEntry.isBest or false,
		title = cfg.Name,
		closeCb = function ()
			local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

			if self:IsInOnlineMode() then
				self:ShowRankPanel(cfg.RelatedTask[1], cfg.Id, true, nil)
			elseif isMobile then
				self:ShowRankPanel(cfg.RelatedTask[1], cfg.Id, false, counterData)
			else
				self:ShowEndingPanel(cfg.RelatedTask[1], cfg.Id, counterData)
			end
		end
	})
end

M.ShowEndingPanel = function(self, taskId, challengeId, counterData, showRank)
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_ENDING_PANEL, {
		challengeId = challengeId,
		taskId = taskId,
		counterData = counterData,
		showRank = showRank
	})
end

M.ShowRankPanel = function(self, taskId, challengeId, isOnline, counterData)
	local cfg = ChallengeConfig.GetConfig(challengeId)

	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_RANK_PANEL, {
		challengeId = challengeId,
		taskId = taskId,
		title = cfg and cfg.Name or "",
		showonlineCtrl = isOnline and 1 or 0,
		counterData = counterData
	})
end

M.ShowEndPanel = function(self, isSuccess, callback)
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = isSuccess,
		callback = callback
	})
end

M._ResetRacingSettleState = function(self)
	self.racingParticipantInfo = nil
	self.isRacingSettleShown = false
	self.racingZoneSessionId = nil
end

M.OnSyncRacingZoneInfo = function(self, zoneInfo)
	self.racingZoneSessionId = zoneInfo.ZoneSessionId
end

M.OnSyncRacingResultData = function(self, racingResultDatas)
	if not self.racingParticipantInfo then
		self.racingParticipantInfo = L50.Spoon.CarRaceManager.Instance:GetParticipantDisplayInfo()
	end

	self.carRaceChallengeData = self:_BuildRaceRankData(racingResultDatas)

	print_notice("OnSyncRacingResultData", racingResultDatas, "\n participants", self.racingParticipantInfo, "\n rankData", self.carRaceChallengeData)

	if not self.isRacingSettleShown then
		local cfg = nil

		if self:IsInOnlineMode() then
			cfg = self.onlineRacerChallengeId and ChallengeConfig.GetConfig(self.onlineRacerChallengeId) or nil

			gLinkManager:OnMatchEnd(true)
		else
			cfg = ChallengeConfig.GetConfig(self.currentChallengeId)

			if cfg then
				self:_SealChallenge()
				self:_PullChallengeResult()

				local ctx = self.settlementCtx

				self:AskFinishNewChallenge(ctx.challengeId, ctx.taskId, nil)
			end
		end

		if cfg then
			if not self.hidePanel then
				self:ShowRacingEndingPanel(cfg)
				self:ShowEndPanel(true)
			end

			self.isRacingSettleShown = true
		end
	elseif gPanelManager:IsPanelShowing(gPanelId.S_CHALLENGE_ENDING_PANEL) then
		gMessageManager:SendMessage(gEventConstants.RACING_RANK_UPDATE)
	end
end

M.OnSyncRacingGameFail = function(self)
	if not gClientUtils:CheckIsLinkMode() then
		return
	end

	self:ShowEndPanel(false, function ()
		if gLinkManager:CheckIsInRace() and gClientUtils:CheckIsLinkMode() then
			gLinkManager:AskLeaveGame(false)
		end
	end)
end

M._BuildRaceRankData = function(self, racingResultDatas)
	local myPid = gPlayerManager.infoLogin.bindData.pid
	local finishedKeys = {}
	local ret = {}

	for _, data in ipairs(racingResultDatas) do
		local isAIEntry = ulong.equals(data.Pid, 0)
		local key = isAIEntry and data.AIVehicle or data.Pid
		local info = self.racingParticipantInfo and self.racingParticipantInfo[key]

		if not info then
			print_error(string.format("[ChallengeManager._BuildRaceRankData] racingParticipantInfo key not match, isAI=%s, Pid=%s, AIVehicle=%s, SeatIndex=%d", tostring(isAIEntry), data.Pid, data.AIVehicle, data.SeatIndex))
		end

		finishedKeys[key] = true

		table.insert(ret, {
			["\\xa2\\xa2#\\xa2d7\\xed;"] = true,
			isSelf = data.Pid ~= myPid,
			pid = data.Pid,
			isAI = isAIEntry,
			time = ulong.tonum2(data.TotalTime) / 1000,
			bestLapTime = ulong.tonum2(data.BestLapTime) / 1000,
			isBest = data.IsBest or false,
			player = {
				name = info and info.name or ""
			},
			vehicle = {
				name = info and info.vehicleName or "",
				icon = info and info.vehicleIcon or 0
			}
		})
	end

	if self.racingParticipantInfo then
		for key, info in pairs(self.racingParticipantInfo) do
			if not finishedKeys[key] then
				table.insert(ret, {
					["\\xa2\\xa2#\\xa2d7\\xed;"] = false,
					["n+p^"] = 0,
					isSelf = key ~= myPid,
					pid = key,
					isAI = info.isAI,
					player = {
						name = info.name
					},
					vehicle = {
						name = info.vehicleName,
						icon = info.vehicleIcon
					}
				})
			end
		end
	end

	return ret
end

M.IsCurrentRacingChallenge = function(self)
	if not self.currentChallengeId or self.currentChallengeId ~= -1 then
		return false
	end

	local cfg = ChallengeConfig.GetConfig(self.currentChallengeId)

	return cfg and cfg.ChallengeType ~= ChallengeType.Racing
end

M.OpenMapBySubQuestId = function(self, subQuestId)
	local autoSelectGpsId = gMapSubSystem_Collection:GetGpsIdBySubQuestId(subQuestId)

	if autoSelectGpsId then
		gMapUtils:CheckRaidCanOpenMap({
			autoSelectGpsId = autoSelectGpsId
		})

		return true
	else
		return false
	end
end

M.OpenMapByChallengeId = function(self, challengeId)
	local taskId = self:GetTaskIdByChallengeId(challengeId)

	if taskId then
		local autoSelectGpsId = gMapSubSystem_Task:GetFirstGpsIdByTaskId(taskId)

		if autoSelectGpsId then
			gMapUtils:CheckRaidCanOpenMap({
				autoSelectGpsId = autoSelectGpsId
			})

			return true
		end

		autoSelectGpsId = gMapSubSystem_Collection:GetGpsIdByTaskId(taskId)

		if autoSelectGpsId then
			gMapUtils:CheckRaidCanOpenMap({
				autoSelectGpsId = autoSelectGpsId
			})

			return true
		end
	end

	gMapUtils:CheckRaidCanOpenMap({
		["\\xa2\\xbf\\xa4e,\\xd77"] = 0,
		raidId = gSceneDataMgr.CurrentRaidId
	})

	return false
end

M.OnSuccessLeaveOnlineGame = function(self)
	if self.challengeData and self.challengeData.IsChallenging then
		self:_SealChallenge()
	end
end

M.EndOfOnlineChallenge = function(self)
	self.onlineChallengeData = {}
	self.isOnlineChallengeSelfEnd = false
end

M.StartTraining = function(self, taskId)
	gMapUtils:DoAcceptTask(taskId, function ()
		gPanelManager:Close(gPanelId.TRANING_PANEL)
	end)
end

M.CheckConfigIsOpen = function(self, cfg)
	if cfg.AgentTag == 0 and gNpcFavorManager:GetCurrentAgentType() == cfg.AgentTag then
		return false
	end

	local taskLine = gTaskNodeManager:GetTaskLineByTask(cfg.TaskId)

	if not taskLine then
		return false
	end

	local lineState = gTaskManager:GetTaskEventState(taskLine.TaskLineId)

	return lineState == TaskEventState.Locked
end

M.GetCurrentTrainingList = function(self, tabIndex)
	local ret = {}

	for i = 0, CombatTrainingConfig.count - 1 do
		local cfg = CombatTrainingConfig.LoadAt(i)

		if cfg.TabId ~= tabIndex and self:CheckConfigIsOpen(cfg) then
			ret[#ret + 1] = cfg.Id
		end
	end

	return ret
end

M.GetCurrentTrainingTab = function(self)
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

M.AskNewChallengeRecord = function(self, id, callback)
	gClientToGameDelegate:AskNewChallengeRecord(id).Callback = function (err, challengeRecord)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		if callback then
			callback(challengeRecord)
		end
	end
end

M.AskFinishNewChallenge = function(self, challengeId, taskId, callback)
	self:Log("AskFinishNewChallenge called with", challengeId, taskId)

	if not challengeId then
		self:Log("AskFinishNewChallenge failed: challengeId is nil", challengeId, taskId)

		if callback then
			callback(nil)
		end

		return
	end

	if self:IsInOnlineMode() then
		self:Log("AskFinishNewChallenge skipped: online mode", challengeId)

		if callback then
			callback(nil)
		end

		return
	end

	local cached = self.challengeResultCache[challengeId]

	if cached then
		self:Log("AskFinishNewChallenge hit cache for challengeId", challengeId)

		if callback then
			callback(cached)
		end

		return
	end

	gClientToGameDelegate:FinishNewChallenge(challengeId, taskId).Callback = function (err, challengeResult)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)
			print_error("FinishNewChallenge failed", err, challengeId, taskId, gCS.Error.GetNameById(err))

			return
		end

		self.challengeResultCache[challengeId] = challengeResult

		if callback then
			callback(challengeResult)
		end
	end
end

M.RenderChallengeRankListTemplate = function(self, itemStore, data, rank)
	itemStore.rankText = rank >= 10 and "0" .. rank or tostring(rank)
	itemStore.nameText = data.player.name
	itemStore.vehicleNameText = data.vehicle.name
	itemStore.selfRankCtrl = data.isSelf and 1 or rank % 2 ~= 0 and 2 or 0
	itemStore.rankBest1Ctrl = 0
	itemStore.rankBest2Ctrl = data.isBest and 1 or 0
	local timeText, lapTimeText = nil

	if not data.isFinish then
		timeText = "--:--:--"
		lapTimeText = "--:--:--"
	else
		timeText = data.time and gTimeUtils:FormatTime(data.time) .. ":" .. gTimeUtils:FormatMs(data.time) or ""
		lapTimeText = data.bestLapTime and data.bestLapTime <= 0 and gTimeUtils:FormatTime(data.bestLapTime) .. ":" .. gTimeUtils:FormatMs(data.bestLapTime) or "--:--:--"
	end

	itemStore.adjust1Text = lapTimeText
	itemStore.adjust2Text = timeText
end

M.PushWushuChallengeData = function(self, roundCfg, roundId, opponentId)
	self.isWushuMode = true

	if self.curWushuData then
		print_error("[ChallengeManager]比武大会数据还未被消耗，可能存在流程错误", self.curWushuData, roundId, opponentId)
	end

	self.curWushuData = {
		roundCfg = roundCfg,
		roundId = roundId,
		opponentId = opponentId
	}
end

M.ClearWushuChallengeData = function(self)
	self.isWushuMode = false
	self.curWushuData = nil
end

M.StartWushuChallenge = function(self)
	if not self.curWushuData then
		print_error("[ChallengeManager] StartWushuChallenge failed: curWushuData is nil")

		return
	end

	local roundCfg = self.curWushuData.roundCfg
	local roundId = self.curWushuData.roundId
	local opponentId = self.curWushuData.opponentId

	if not roundCfg then
		print_error("[ChallengeManager] StartWushuChallenge failed: roundCfg is nil for roundId", roundId)

		return
	end

	self.curWushuData = nil

	self:_StartWushuChallenge(roundCfg, roundId, opponentId)
end

M._StartWushuChallenge = function(self, roundCfg, roundId, opponentId)
	self:Log("StartWushuChallenge roundId=%s opponentId=%s", roundId, opponentId)

	self.isWushuMode = true
	self.curWushuRoundCfg = roundCfg
	self.curWushuTaskId = roundCfg.RelatedTask
	self.curWushuRoundId = roundId
	self.curWushuOpponentId = opponentId
	self.currentChallengeId = roundCfg.Id
	self.challengeData.IsChallenging = true

	gMessageManager:SendMessage(gEventConstants.CHALLENGE_GOAL_START, roundCfg.RelatedTask)

	self.beginTime = gLogicTime.time

	gWushuTournamentManager:OnStartWushuChallenge(self.curWushuTaskId)

	local taskId = roundCfg.RelatedTask

	gClientUtils.SetCameraRotateEnabled(false)
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_START_PANEL, {
		callBack = function ()
			gClientUtils.SetCameraRotateEnabled(true)
			gPanelManager:CheckShow(gPanelId.S_CHALLENGE_COUNTDOWN_PANEL, {
				["\\x96'0m\\x93U\\xfd8\\xbd\\xb7"] = true,
				["\\xe6[\\xde/\\xb3B\\xaeX\\xb4\\xa5"] = true,
				["5\\x85㿃籴\\xbb\\xd8\\xe1=Ȟ\\x8a\\xef"] = 600,
				callback = function (isNormal)
					if not isNormal then
						gClientToGameDelegate:AskDeleteTask(taskId, true).Callback = function (err)
							if err == 0 then
								gDisplayMessageMgr:DisplayServerMessageId(err)
							end
						end
					end
				end
			})
		end
	})
end

M.SettleWushuChallenge = function(self, isSuccess)
	print_debug("[WushuTournament]SettleWushuChallenge", self.isWushuMode)

	if not self.isWushuMode then
		print_error("[WushuTournament]不在比武大会流程中但是SettleWushuChallenge")

		return
	end

	if isSuccess then
		gMessageManager:SendMessage(gEventConstants.WUSHU_TOURNAMENT_VICTORY, true)
	end

	self:_SealChallenge()

	self.isWushuMode = false

	gPanelManager:Close(gPanelId.S_CHALLENGE_COUNTDOWN_PANEL)

	local starResults = {}

	for i = 1, 3 do
		starResults[i] = self.counterData[i] ~= true
	end

	gWushuTournamentManager:OnEndWushuChallenge(isSuccess, starResults)
end

M.EndWushuChallenge = function(self)
	print_debug("[WushuTournament]EndWushuChallenge", self.isWushuMode)

	if not self.isWushuMode then
		return
	end
end

M.AbandonWushuChallenge = function(self)
	if not self.isWushuMode then
		return
	end

	self:_SealChallenge()

	self.isWushuMode = false

	gPanelManager:Close(gPanelId.S_CHALLENGE_COUNTDOWN_PANEL)
end

M.BuildWushuAdaptCfg = function(self)
	local roundCfg = self.curWushuRoundCfg

	if not roundCfg then
		print_error("[ChallengeManager] BuildWushuAdaptCfg roundCfg nil roundId=" .. tostring(self.curWushuRoundId))

		return nil
	end

	local counterValue = {}

	for i = 1, #roundCfg.CounterValues do
		counterValue[i] = {
			["\nI\\x9d\\x9b\\x86"] = 0,
			["\nI\\x9d\\x9b\\x86"] = 0,
			["\nI\\x9d\\x9b\\x86"] = 0,
			value1 = roundCfg.CounterValues[i]
		}
	end

	return {
		["!\\xeb^ \\xd5\\xb1D\\x95O\\xa0\\xb3"] = 0,
		ChallengeParams = roundCfg.ChallengeParams,
		CounterValue = counterValue
	}
end

gChallengeManager = gChallengeManager or C_ChallengeManager.new()
