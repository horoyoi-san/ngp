-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\WushuTournament\WushuTournamentManager.lua
-- Decompiled from: 00504_WushuTournamentManager.lua_f4bc3b32717a.luajit

local TaskState = UX.Game.TaskState
local SeasonConfig = LTConfig.WushuTournamentSeasonConfig
local RoundConfig = LTConfig.WushuTournamentRoundConfig
local TOTAL_TIME = 600
local FSMState = {
	["/M\\x85\\x9a\\x8fD"] = 4,
	[">I\\x85\\x9a\\x8fD"] = 3,
	["/M\\x9d\\x8b\\x80U"] = 1,
	["\\xe9\\xc9\r6\\xf4"] = 2
}
local FSMTransition = {
	[" \\xe2K8\\xd5#\\x85D\\xb5B\\xbc\\xb3"] = 4,
	["׈\\xfc\\xe3$ȉ\\xf9\\x96,-"] = 3,
	["1\\xe6K8\\xd5#\\x85D\\xadS\\xb3\\xa2"] = 5,
	["1\\xe6K8\\xd5#\\x94@\\xb5B\\xbc\\xb3"] = 6,
	["׈\\xfc\\xe3$ٍ\\xe1\\x87#<"] = 2,
	["ԟ\\xe9\\xd9+\\xf8\\x8d\\xfd\\x832-"] = 1
}
C_WushuTournamentManager = DefClass("C_WushuTournamentManager", C_WushuTournamentManager)
local M = C_WushuTournamentManager

M.ctor = function(self)
	self.FSM = nil
	self.isInWushuMap = false
	self.isRequesting = false
	self.isSelectSuccess = false
	self.isSettleActing = false
	self.isPreparing = false
	self.seasonInfo = nil
	self.seasonCfg = nil
	self.curRoundId = 0
	self.curOpponentId = 0
	self.lastSettlementInfo = nil
	self.lastStarResults = nil
	self.settlementPushHandler = nil
	self.taskStateChangeHandler = nil
	self.curChallengeTaskId = 0
end

M.EnterWushuTournament = function(self)
	self:InitFSM()
end

M.ExitWushu = function(self)
	self:DisposeFSM()
	self:ClearPlayData()

	self.isInWushuMap = false
	self.isSelectSuccess = false
	self.isSettleActing = false

	gPanelManager:Close(gPanelId.WUSHU_TOURNAMENT_PANEL)
	gPanelManager:Close(gPanelId.WUSHU_RESULT_PANEL)
	gPanelManager:Close(gPanelId.CHALLENGE_FAIL_PANEL)
end

M.GetSeasonInfo = function(self)
	return self.seasonInfo
end

M.OnSelectPanelExit = function(self)
	if self.FSM and self:GetFSMState() ~= FSMState.Select and not self.isSelectSuccess then
		self:ExitWushu()
	end
end

M.OnSettlePanelExit = function(self)
	if self.FSM and self:GetFSMState() ~= FSMState.Settle and not self.isSettleActing then
		self:ExitWushu()
	end
end

M.SelectOpponent = function(self, roundId, opponentId, callback)
	if self.isRequesting then
		return
	end

	self.isRequesting = true
	self.curRoundId = roundId
	self.curOpponentId = opponentId
	self.isSelectSuccess = false

	gClientToGameDelegate:AskSelectWushuTournamentOpponent(roundId, opponentId).Callback = function (err)
		self.isRequesting = false

		if err == LTConfig.MessageConfig.Ok then
			self:HandleWushuError(err)

			if callback then
				callback(false)
			end

			return
		end

		self.isSelectSuccess = true

		self.FSM:SendSignal(FSMTransition.Select_Prepare)

		if callback then
			callback(true)
		end
	end
end

M.StartCurChallenge = function(self)
	if not self.curRoundId or self.curRoundId ~= 0 then
		print_error("[WushuTournament]StartCurChallenge 无效 curRoundId=" .. tostring(self.curRoundId))

		return
	end

	self.isPreparing = false

	self:StartChallenge(self.curRoundId)
end

M.StartChallenge = function(self, roundId)
	if self.isRequesting then
		return
	end

	local roundCfg = self:GetRoundCfg(roundId)

	if not roundCfg then
		print_error("[WushuTournament]StartChallenge 无效 roundId=" .. tostring(roundId))

		return
	end

	gChallengeManager:PushWushuChallengeData(roundCfg, self.curRoundId, self.curOpponentId)

	self.isRequesting = true

	gClientToGameDelegate:AskStartWushuTournamentChallenge(roundId).Callback = function (err)
		self.isRequesting = false

		if err == LTConfig.MessageConfig.Ok then
			self:HandleWushuError(err)
			gChallengeManager:ClearWushuChallengeData()

			return
		end

		self.curRoundId = roundId

		self.FSM:SendSignal(FSMTransition.Prepare_Battle)
	end
end

M.GetRoundCfg = function(self, roundId)
	if not self.seasonCfg then
		return nil
	end

	local cfgRoundId = self.seasonCfg.RoundIds[roundId]

	return cfgRoundId and RoundConfig.GetConfig(cfgRoundId) or nil
end

M.OnStartWushuChallenge = function(self, taskId)
	self.curChallengeTaskId = taskId
end

M.OnEndWushuChallenge = function(self, isSuccess, starResults)
	self.curChallengeTaskId = 0
	self.lastStarResults = starResults
	self.isCurChallengeSuccess = isSuccess

	if isSuccess then
		gClientToGameDelegate:AskFinishWushuTournamentRound(self.curRoundId, starResults).Callback = function (err)
			print_debug("[WushuTournament]AskFinishWushuTournamentRound", self.curRoundId, starResults, err)

			if err == LTConfig.MessageConfig.Ok then
				self:HandleWushuError(err)

				return
			end
		end
	else
		self.FSM:SendSignal(FSMTransition.Battle_Settle)
	end
end

M.RegisterTaskStateChange = function(self)
	if self.taskStateChangeHandler then
		print_error("[WushuTournament]重复注册任务状态监听，可能流程有问题")
	end

	self:UnregisterTaskStateChange()

	self.taskStateChangeHandler = self:CreateAction(self.OnTaskStateChange)

	gMessageManager:AddMessageListener(gEventConstants.TASK_STATE_CHANGED, self.taskStateChangeHandler)
end

M.UnregisterTaskStateChange = function(self)
	if self.taskStateChangeHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.TASK_STATE_CHANGED, self.taskStateChangeHandler)

		self.taskStateChangeHandler = nil
	end
end

M.OnTaskStateChange = function(self, _, taskData)
	local curTaskId = taskData[1]
	local state = taskData[2]

	if self.curChallengeTaskId ~= curTaskId and state ~= TaskState.Aborted then
		if self:IsInBattle() then
			self:OnWushuChallengeTaskFail()
		end

		return
	end
end

M.OnWushuChallengeTaskFail = function(self)
	print_debug("OnTaskStatusChange: 比武大会挑战失败，Aborted taskId=%s", self.curChallengeTaskId, self:IsInBattle())
	self:LeaveWushuTournament()
end

M.RequestPostSettlement = function(self, roundId, action)
	if self.isRequesting then
		return
	end

	self.isRequesting = true
	self.isSettleActing = false

	if action ~= UX.Game.WushuTournamentPostSettlementAction.Retry then
		gChallengeManager:PushWushuChallengeData(self:GetRoundCfg(roundId), roundId, self.curOpponentId)
	end

	if action ~= UX.Game.WushuTournamentPostSettlementAction.Exit then
		self:ExitWushu()
	end

	gClientToGameDelegate:AskWushuTournamentPostSettlement(roundId, action).Callback = function (err)
		self.isRequesting = false

		if err == LTConfig.MessageConfig.Ok then
			self:HandleWushuError(err)
			gChallengeManager:ClearWushuChallengeData()

			return
		end

		if not self.FSM then
			return
		end

		self.isSettleActing = true

		if action ~= UX.Game.WushuTournamentPostSettlementAction.Retry then
			self.FSM:SendSignal(FSMTransition.Settle_Battle)
		elseif action ~= UX.Game.WushuTournamentPostSettlementAction.Next then
			self.FSM:SendSignal(FSMTransition.Settle_Select)
		end
	end
end

M.LeaveWushuTournament = function(self)
	if self.isRequesting then
		return
	end

	self.isRequesting = true
	self.isSettleActing = false

	gClientToGameDelegate:AskLeaveWushuTournament().Callback = function (err)
		self.isRequesting = false

		if err == LTConfig.MessageConfig.Ok then
			self:HandleWushuError(err)

			return
		end

		gChallengeManager:AbandonWushuChallenge()
		self:ExitWushu()
	end
end

M.AskSeasonData = function(self)
	self.isRequesting = true

	gClientToGameDelegate:AskWushuTournamentSeasonData().Callback = function (err, seasonInfo)
		self.isRequesting = false

		if err == LTConfig.MessageConfig.Ok then
			self:HandleWushuError(err)

			return
		end

		self.seasonInfo = seasonInfo
		self.seasonCfg = SeasonConfig.GetConfig(seasonInfo.SeasonId)

		gMessageManager:SendMessage(gEventConstants.WUSHU_TOURNAMENT_SEASON_DATA_READY)
	end
end

M.OnSyncWushuTournamentRoundSettlement = function(self, info)
	print_debug("[WushuTournament]OnSyncWushuTournamentRoundSettlement", info)

	if not self.FSM or self:GetFSMState() == FSMState.Battle then
		print_error("[WushuTournament]非战斗状态收到结算推送,state=" .. tostring(self:GetFSMState()))

		return
	end

	self.lastSettlementInfo = info

	self.FSM:SendSignal(FSMTransition.Battle_Settle)
end

M.InitFSM = function(self)
	if self.FSM then
		self.FSM:Dispose()

		self.FSM = nil
	end

	self.FSM = gFSMManager:GetFSM(self)

	self.FSM:AddStates(FSMState)
	self.FSM:AddTransitions(FSMState, FSMTransition)
	self.FSM:SetInitState(FSMState.Select)
end

M.DisposeFSM = function(self)
	if self.FSM then
		self.FSM:Dispose()

		self.FSM = nil
	end
end

M.GetFSMState = function(self)
	return self.FSM and self.FSM:GetCurrentState() or nil
end

M.IsInBattle = function(self)
	return self.FSM == nil and self:GetFSMState() ~= FSMState.Battle
end

M.OnSelectEnter = function(self)
	gPanelManager:CheckShow(gPanelId.WUSHU_TOURNAMENT_PANEL)
	self:AskSeasonData()
end

M.OnSelectExit = function(self)
	gPanelManager:Close(gPanelId.WUSHU_TOURNAMENT_PANEL)
end

M.OnPrepareEnter = function(self)
	Timer.New(function ()
		if self.FSM and self:GetFSMState() ~= FSMState.Prepare then
			self:StartCurChallenge()
		end
	end, 0.2):Start()
end

M.OnPrepareExit = function(self)
end

M.OnPreparePanelClose = function(self)
end

M.OnPrepareToBattleCheck = function(self)
	if self.curOpponentId ~= 0 then
		print_error("[WushuTournament]未选对手,不允许开始挑战")

		return false
	end

	return true
end

M.OnPrepareToBattleTransition = function(self)
	self.isInWushuMap = true
end

M.OnBattleEnter = function(self)
end

M.OnBattleToSettleCheck = function(self)
	if not self.isCurChallengeSuccess then
		return true
	end

	if not self.lastSettlementInfo or self.lastSettlementInfo.RoundId == self.curRoundId then
		print_error("[WushuTournament]结算 roundId 不符,cur=" .. tostring(self.curRoundId))

		return false
	end

	return true
end

M.OnBattleToSettleTransition = function(self)
end

M.OnSettleEnter = function(self)
	self.isSettleActing = false

	if self.isCurChallengeSuccess then
		gPanelManager:CheckShow(gPanelId.WUSHU_RESULT_PANEL, {
			settlementInfo = self.lastSettlementInfo,
			roundCfg = self:GetRoundCfg(self.curRoundId),
			starResults = self.lastStarResults
		})
	else
		gPanelManager:CheckShow(gPanelId.CHALLENGE_FAIL_PANEL)
	end
end

M.OnSettleExit = function(self)
	gPanelManager:Close(gPanelId.WUSHU_RESULT_PANEL)
	gPanelManager:Close(gPanelId.CHALLENGE_FAIL_PANEL)
end

M.OnSettleToSelectTransition = function(self)
end

M.OnSettleToBattleTransition = function(self)
end

M.CanChallengeRound = function(self, roundId)
	if not self.seasonInfo then
		return false
	end

	local cur = self.seasonInfo.CurrentRound

	if roundId < cur then
		return true
	end

	if roundId ~= cur + 1 and not self.seasonInfo.IsSeasonCleared then
		return true
	end

	return false
end

M.IsRoundLocked = function(self, roundId)
	return not self:CanChallengeRound(roundId)
end

M.GetContinuePoint = function(self)
	if not self.seasonInfo or self.seasonInfo.LastChallengeRound ~= 0 then
		return nil
	end

	return self.seasonInfo.LastChallengeRound, self.seasonInfo.LastChallengeChoice
end

M.HandleWushuError = function(self, err)
	print_error("[WushuTournament]RPC 错误,err=", tostring(err), gCS.Error.GetNameById(err))
end

M.ClearPlayData = function(self)
	self.curRoundId = 0
	self.curOpponentId = 0
	self.lastSettlementInfo = nil
	self.lastStarResults = nil
	self.isRequesting = false
	self.seasonInfo = nil
	self.seasonCfg = nil

	if self.settlementPushHandler then
		self.settlementPushHandler = nil
	end
end

M.OnBeforeSwitchScene = function(self)
	self:ExitWushu()
end

gWushuTournamentManager = gWushuTournamentManager or C_WushuTournamentManager.new()
