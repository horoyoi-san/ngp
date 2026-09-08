-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_GameProgress.lua
-- Decompiled from: 00710_LinkManager_GameProgress.lua_3f488af64cc0.luajit

local MessageConfig = LTConfig.MessageConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local M = C_LinkManager

M.OnPlayGameAgain = function(self, pid)
	print_debug("LinkManager:OnPlayGameAgain", pid, self:GetEndMemberList(), self.tryAgainDict)

	self.tryAgainDict[pid] = true

	gMessageManager:SendMessage(gEventConstants.LINK_MEMBER_CHANGE, {
		pid = pid
	})

	if self:CheckAllAgreed() then
		print_debug("LinkManager:OnPlayGameAgain all agreed")

		if self.stageRoom then
			return
		end

		self.tryAgainDict = {}
		local endPanelCfg = self:GetEndPanelConfig()
		local showLoading = endPanelCfg and endPanelCfg.ExitLoading or false

		self:ExitFinalRankPanel(showLoading)
	end
end

M.CheckAllAgreed = function(self)
	if table.isNilOrEmpty(self.tryAgainDict) then
		return false
	end

	if table.count(self.tryAgainDict) == table.count(self.GetEndMemberList(self)) then
		return false
	end

	for _, agreed in pairs(self.tryAgainDict) do
		if not agreed then
			return false
		end
	end

	return true
end

M.AskLeaveGameByEnd = function(self, showLoading)
	if self.GetEndType(self) ~= LTConfig.LinkEndPanelTypeConfig.EndTypeType.BASKETBALL then
		self.ClearLinkGame(self)
		self.EndOfOnlineChallenge(self, showLoading)

		return
	end

	self.AskLeaveGame(self, false, showLoading)
end

M.AskLeaveGame = function(self, hasPunish, showLoading)
	slot3 = gClientToGameDelegate

	slot3:AskPlayGameAgain(false, false, false).Callback = function (err)
		self:ClearLinkGame()
		self:EndOfOnlineChallenge(showLoading)

		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gChallengeManager:OnSuccessLeaveOnlineGame()
	end
end

M.CanSingleMatch = function(self)
	if self.GetEndType(self) ~= LTConfig.LinkEndPanelTypeConfig.EndTypeType.BASKETBALL or self.currentGameCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.Mahjong or self.CheckIsExtractionShooter(self) or self.CheckIsInRaid(self) then
		return false
	end

	if self.currentGameCfg.Id ~= 12111110 then
		return false
	end

	return true
end

M.AskSingleMatch = function(self)
	if not self.CanSingleMatch(self) then
		return
	end

	if self.partyMiniGameMatchConfigId then
		local playId = self.currentGameCfg.Id
		slot2 = gClientToGameSceneDelegate

		slot2:LeaveGameGroundZone().Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			self:ClearLinkGame()
			self:EndOfOnlineChallenge()
			self:AskMatchBegin(playId, true)
		end

		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskPlayGameAgain(false, false, true).Callback = function (err)
		self:ClearLinkGame()
		self:EndOfOnlineChallenge()

		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gChallengeManager:OnSuccessLeaveOnlineGame()
	end
end

M.AskPlayGameAgain = function(self, state, callback)
	print_debug("LinkManager:AskPlayGameAgain", state, self.CheckIsWorldBattle(self))

	self.stageRoom = nil

	if state ~= C_LinkManager.AGAIN_STATE.NEXT then
		slot3 = gClientToGameDelegate

		slot3:AskPlayGameAgain(true, true, false).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if callback then
					callback(false)
				end

				return
			end

			if callback then
				callback(true)
			end
		end

		return
	end

	slot3 = gClientToGameDelegate

	slot3:AskPlayGameAgain(true, false, false).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end

			return
		end

		if callback then
			callback(true)
		end

		self:OnPlayGameAgain(gPlayerManager.infoLogin.bindData.pid)
	end
end

M.OnMatchGameMemberLeave = function(self, room, pid)
	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		self.OnMatchInit(self)
	else
		self.tryAgainDict[pid] = false
		self.matchMemberLeave = true

		if self.matchState == nil then
			gDisplayMessageMgr:ShowMessage(MessageConfig.OnlineMatchMemberExit)
		end

		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end
end

M.CheckAgainState = function(self, isSuccess)
	if self.CheckIsInRaid(self) then
		local linkele = self.multi2Link[self.currentGameCfg.Id]

		if not linkele then
			return C_LinkManager.AGAIN_STATE.None, 244
		end

		if not self.CheckCanTryAgain(self) then
			return C_LinkManager.AGAIN_STATE.None, 244
		end

		if not table.isNilOrEmpty(self.currentGameCfg.NeedKeyIds) then
			return C_LinkManager.AGAIN_STATE.None, 244
		end

		local matchState = self.matchState

		if isSuccess == nil then
			matchState = isSuccess
		end

		if not matchState then
			return C_LinkManager.AGAIN_STATE.REPLAY, 494
		end

		if linkele.next == 0 then
			local cfg = LinkMultiPlayerConfig.GetConfig(linkele.next)
			local currentNum = table.count(self.LinkMemberInfo)
			local raidData = self.selfOnlineChallengeData.settleData.raidSettleData

			if cfg.PlayerNum[1] < currentNum and currentNum < cfg.PlayerNum[2] then
				if not raidData or raidData.CanNextGame then
					return C_LinkManager.AGAIN_STATE.NEXT, 577
				else
					return C_LinkManager.AGAIN_STATE.None, 244
				end
			else
				print_debug("LinkManager:CheckAgainState None, PlayerNum not match", linkele.next, currentNum, cfg.PlayerNum[1], cfg.PlayerNum[2])

				return C_LinkManager.AGAIN_STATE.None, 244
			end
		end
	else
		return C_LinkManager.AGAIN_STATE.AGAIN, 244
	end
end

M.GetBaseAgainLabel = function(self, state)
	if state ~= C_LinkManager.AGAIN_STATE.REPLAY then
		return TextScriptTextConfig.GetConfig(89901274).Text
	elseif state ~= C_LinkManager.AGAIN_STATE.NEXT then
		return TextScriptTextConfig.GetConfig(89901272).Text
	elseif state ~= C_LinkManager.AGAIN_STATE.AGAIN then
		return TextScriptTextConfig.GetConfig(89901273).Text
	end

	return ""
end

M.GetAgainLabel = function(self, state)
	local againNum = 0

	for k, v in pairs(self.tryAgainDict) do
		if v then
			againNum = againNum + 1
		end
	end

	local baseAgainNum = againNum .. "/" .. table.count(self.GetEndMemberList(self))
	local baseText = TextScriptTextConfig.GetConfig(89901271).Text
	local stateText = self.GetBaseAgainLabel(self, state)

	return gString.Format(baseText, baseAgainNum, stateText)
end

M.CheckCanTryAgain = function(self)
	if table.isNilOrEmpty(self.tryAgainDict) then
		return true
	end

	for k, v in pairs(self.tryAgainDict) do
		if not v then
			return false
		end
	end

	return true
end

M.GetLinkIndex = function(self, pid)
	return self.LinkMemberIndex[self.LinkMode][pid]
end

M.TryExit = function(self)
	if self.CheckIsExtractionShooter(self) then
		slot1 = gDisplayMessageMgr

		slot1:ShowMessage(MessageConfig.OnlineRoomExitNormalTip, function ()
			slot0 = gClientToGameSceneDelegate

			slot0:AskQuitExtractionShooter().Callback = function (err)
				if err == MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		end, nil)

		return
	end

	local hasFrontPlayer = gCarRaceManager:CheckHasFrontPlayer()

	if hasFrontPlayer then
		slot2 = gDisplayMessageMgr

		slot2:ShowMessage(MessageConfig.OnlineRoomExitWarnTip, function ()
			gChallengeManager:ShowEndPanel(false, self:CreateActionWithArgs(self.AskLeaveGame, true))
		end)
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.OnlineRoomExitNormalTip, self:CreateActionWithArgs(self.AskLeaveGame, false), nil)
	end
end

M.OnMatchGameLeftFailureCountUpdate = function(self, count)
	self.LinkFailureCount = count

	gMessageManager:SendMessage(gEventConstants.LINK_HUD_INFO_CHANGE)
end

M.OnMatchEnd = function(self, isSuccess)
	print_debug("LinkManager:OnMatchEnd", isSuccess)
	print_notice("OnMatchEnd", isSuccess)

	if self.targetPlayId == LinkMultiPlayerConfig.Bowling and gTimelineManager:Timeline_IsPlaying() then
		coroutine.start(function ()
			local waitTime = 0

			while gTimelineManager:Timeline_IsPlaying() do
				coroutine.wait(0.1)

				waitTime = waitTime + 0.1
			end

			self:DoMatchEnd(isSuccess)
		end)
	else
		self.DoMatchEnd(self, isSuccess)
	end
end

M.DoMatchEnd = function(self, isSuccess)
	if not self.CheckIsInRace(self) then
		self.tryAgainDict = {}
	end

	self.matchState = isSuccess
	self.cs.IsMatchModeInteractable = false
	self.hasPersonalResult = false

	if gLinkManager:CheckIsExtractionShooter() then
		gExtractionShooterManager:ShowEndPanel(isSuccess)

		return
	end

	if self.GetEndType(self) ~= LTConfig.LinkEndPanelTypeConfig.EndTypeType.CUSTOM or self.CheckIsInRace(self) then
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)

		return
	end

	local openResultPanel = function()
		if gPanelManager:IsPanelShowing(gPanelId.PVP_LOADING_PANEL) then
			self._afterLoadingPanel = function()
				self:OpenPersonalResultPanel(isSuccess)
			end
		else
			self:OpenPersonalResultPanel(isSuccess)
		end
	end

	if self.targetPlayId ~= LTConfig.LinkMultiPlayerConfig.Gomoku or self.targetPlayId ~= LTConfig.LinkMultiPlayerConfig.SkillGomoku then
		coroutine.start(function ()
			coroutine.wait(3)
			openResultPanel()
			L50.L50App.Scene.GomokuManager:NotifyOnlineResultPanelOpened()
		end)
	else
		openResultPanel()
	end
end
