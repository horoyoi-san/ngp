-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MatchGamePanelStore.lua
-- Decompiled from: 00969_MatchGamePanelStore.lua_c44f42a93688.luajit

local MessageConfig = LTConfig.MessageConfig
local MatchGameTextInfos = {
	GameTitle = {
		["N'pK"] = "\\xa6\\xd1\\xe0a\\xbehr\\xfbq\\xaa)+a\\xb6+"
	},
	ScoreLabel = {
		["N'pK"] = "\\x99\\xa0wv\\x91"
	},
	MaxScoreLabel = {
		["N'pK"] = "\\xe9\\x8aL\\xfe\\x87Jw\\xaf\\x8c\\xfc\\x8b\\x9c"
	},
	ComboLabel = {
		["N'pK"] = "\\x94\\x97od\\x9a"
	},
	MaxComboLabel = {
		["N'pK"] = "\\xe9\\x8aL\\xfe\\x87Jz\\x98\\x94\\xff\\x99\\x97"
	},
	TimeLabel = {
		["N'pK"] = "\\x94\\x86Pt\\x97"
	},
	TimeUnit = {
		["N'pK"] = "\\xde"
	},
	RuleText = {
		["N'pK"] = "G\\xf0Hu\\x84B\\xe5\\xe8\\xe8o\\x88\\x9bo\\xb4Qڣ\\xf2\\x89\\xb8 \\xb2\\\\xcf]vt\\xe7\\xa1`\\xe7\\xe9\\x84\\xe1\\xb8z۠ՠU^ \\xf8$\\x9d=K\\xb6\\xa5 \\xb5\r\\x81\\xfb\\xfe\\xf1\\xfbՕ\\xa5ޱJ\\xe8gy\\xaaG\\xde\\xe4(\\xe5b\\xb1\\x86\\x80\\xdeP\\xb2\\xfe\\xdf\\xf1\\xf8J\\xd8]y\\x88E7\\xc5\\xe4\"\\xcao\\x84\\xaf\\x8a\\xed~"
	},
	AwardInfoLabel = {
		["N'pK"] = "\\x83\\xd5_dL@a]\\\r&\"\\xb7j\\xafC"
	},
	EasyLabel = {
		["N'pK"] = "\\x9b\\x86qn\\xb4"
	},
	NormalLabel = {
		["N'pK"] = "\\x9a\\xb1_c\\xbb"
	},
	HardLabel = {
		["N'pK"] = "\\x99\\xb3Ay\\x9f"
	},
	WinTitle = {
		["N'pK"] = "\\xe9\\xaet\\xf1\\xa4]z\\xa9\\xbd\\xf2\\x9d\\xb0"
	},
	LoseTitle = {
		["N'pK"] = "\\xe9\\xaet\\xf1\\xa4]u\\x9c\\x99\\xfc\\x83\\xb3"
	},
	BasicScoreLabel = {
		["N'pK"] = "\\xea\\x89v\\xf0\\x8dRw\\x99\\x9d\\xff\\x96\\xaa"
	},
	TotalScoreLabel = {
		["N'pK"] = "\\xe6\\x91K\\xfe\\xb7Tt\\xa7\\xb1\\xff\\x96\\xaa"
	},
	MaxRecordLabel = {
		["N'pK"] = "\\xe9\\x8aL\\xfe\\x87Jz\\x89\\xba\\xff\\xa3\\xb9"
	},
	RemainingTimeLabel = {
		["N'pK"] = "\\xea\\x9fe\\xf3\\x91Kt\\xb0\\xbc\\xf3\\x89\\x98"
	},
	NewRecordText = {
		["N'pK"] = "լ:^\\xc2=\\xd9<\\xa9"
	},
	AwardListTitle = {
		["N'pK"] = "\\xa6\\xfd\\xf2m\\x94~\\xcfN\\xaa2c\\xb9"
	},
	AwardTimesLabel = {
		["N'pK"] = "\\x8b\\xed^f\\xc8ԍ\\xb1\\xef\\xbaS¯]\\xc6It"
	},
	NoRewardConfirm = {
		["N'pK"] = "e\\xb5|\\x90\\x8b\\xf2\\xe3\\x83\\xca\\xe8\\xea\\xf2v\\xdds\\xe6\\xf3X\\xb8\\x820o\\x82\\xb3v<\\x84Ȅ\\x9b\\xbd\\xb9\\x9d\\x81Ҷ.\\xeb\\xa9\\xf5\\xe6\\x96w\\x98\\xec%\\xeew\\xda\\xe7\\xef\\xa0\\xd3é\\x9a\\xe9>\\x97Y\\x9c"
	}
}
C_MatchGamePanelStore = DefClass("C_MatchGamePanelStore", C_MatchGamePanelStore, C_StoreGroup)
GroupName2Class.MatchGamePanelStore = C_MatchGamePanelStore
local M = C_MatchGamePanelStore
local GameState = {
	["\\x8b\\x83\\x8b\\x8f"] = 1,
	["~\\x9a\\x83\\x9d\\x82"] = 2,
	["}\\x8f\\x97\\x9c\\x93"] = 4,
	[".m\\xa2\\xbb\\xafu"] = 3,
	["?`\\xbe\\xa1\\xb0d"] = 0
}
local CardState = {
	["~{\\xfa\\x9e\\xac7\\x9c+\\xe7\\xcd"] = 2,
	["\\x9e\\x9f*\\x9bO\\xdb"] = 0,
	["3x\\xb4\\xa0\\xa6e"] = 1
}
local GameMode = {
	["_Nb"] = 1,
	["2g\\xa3\\xa3\\xa2m"] = 2,
	["RO"] = 3
}

M.DefineAllVariables = function(self)
	self.cards = {}
	self.cardStores = {}
	self.firstFlipped = nil
	self.flipCount = 0
	self.combo = 0
	self.matchCount = 0
	self.score = 0
	self.comboScore = 0
	self.remainingTime = 0
	self._serverTotalTimeSec = 0
	self.isLocked = false
	self.isClosed = false
	self.isNoReward = false
	self.prePauseState = GameState.START
	self.tickTimer = nil
	self.failDelayTimer = nil
	self.countDownTimer = nil
	self.gameMode = GameMode.NORMAL
	self.remainingTimes = 0
	self.maxScore = 0
	self.maxCombo = 0
	self.curMaxCombo = 0
	self.lastRemainingTimes = 0
	self.totalCards = 0
	self.numPairs = 0
	self._serverBuffCtrl = 0
	self._serverRewardItems = nil
	self._settlePending = false
	self._pauseSec = 0
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
	self.RegisterLists(self)
end

M.RegisterWidget = function(self)
	self.bindData.pauseBtn.luaClick = self.CreateAction(self, "OnClickPause")
	self.bindData.playBtn.luaClick = self.CreateAction(self, "OnClickResume")
	self.bindData.restartBtn.luaClick = self.CreateAction(self, "OnClickPauseRestart")
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnClickExit")
	self.bindData.gameStartBtn.luaClick = self.CreateAction(self, "OnClickStartGame")
	self.bindData.easyBtn.luaClick = self.CreateAction(self, "OnClickEasy")
	self.bindData.normalBtn.luaClick = self.CreateAction(self, "OnClickNormal")
	self.bindData.difficultBtn.luaClick = self.CreateAction(self, "OnClickDifficult")
	self.bindData.resultRestartBtn.luaClick = self.CreateAction(self, "OnClickResultRestart")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBack")
end

M.RegisterLists = function(self)
	self.bindData.cardList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderCard")
	self.bindData.cardList.luaSimpleClick = self.CreateAction(self, "OnClickCard")

	if self.bindData.chooseRewardList then
		self.bindData.chooseRewardList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderChooseReward")
	end

	if self.bindData.resultRewardList then
		self.bindData.resultRewardList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderResultReward")
	end
end

M.OnGroupEnable = function(self)
	self.isClosed = false
end

M.OnGroupDisable = function(self)
	self.isClosed = true

	self:CancelAllTimers()
	gFactorMachineManager:UnregisterSettleCallback()
end

M.OnDisable = function(self)
	gMessageManager:SendMessage(gEventConstants.UPDATE_MATCH_GAME_REMAIN_TIMES)
end

M.OnShow = function(self)
	gFactorMachineManager._matchGameStore = self

	gFactorMachineManager:RegisterSettleCallback(function (result)
		if self.isClosed then
			return
		end

		self:OnSettleReceived(result)
	end)

	self.maxScore = gFactorMachineManager:GetMaxScore(self.gameMode)
	self.maxCombo = gFactorMachineManager:GetMaxCombo(self.gameMode)
	self.remainingTimes = gFactorMachineManager:GetRemainingGameTimes()
	self.lastRemainingTimes = self.remainingTimes

	self:EnterChoosePage()
end

M.EnterChoosePage = function(self)
	self.bindData.stateCtrl = GameState.CHOOSE
	self.bindData.maxScoreText = tostring(self.maxScore)
	self.bindData.maxComboText = tostring(self.maxCombo)

	self:RefreshDifficultyTime()

	local T = gFactorMachineManager.GetGameConfigTable()
	local previewDrops = gFactorMachineManager:GetConstant(T.PreviewDrops)
	local dropList = {}

	if previewDrops then
		if type(previewDrops) ~= "table" then
			for _, dropId in ipairs(previewDrops) do
				table.insert(dropList, dropId)
			end
		else
			table.insert(dropList, previewDrops)
		end
	end

	if #dropList <= 0 and self.bindData.chooseRewardList then
		self.bindData.chooseRewardList:SetSimpleList(#dropList)
	end
end

M.EnterReadyState = function(self)
	self.bindData.stateCtrl = GameState.READY
	local countDown = 3
	self.bindData.countDownText = tostring(countDown)
	self.countDownTimer = Timer.New(function ()
		if self.isClosed then
			return
		end

		countDown = countDown - 1

		if countDown < 0 then
			self.countDownTimer:Stop()

			self.countDownTimer = nil
			self._awardAnimTimer = nil
			self._awardCurrent = 0
			self._awardTotal = 0
			self._awardThreshold = 0

			self:EnterStartState()
		else
			self.bindData.countDownText = tostring(countDown)
		end
	end, 1, -1):Start()
end

M.EnterStartState = function(self)
	if self.countDownTimer then
		self.countDownTimer:Stop()

		self.countDownTimer = nil
	end

	self.bindData.stateCtrl = GameState.START
	self.tickTimer = Timer.New(function ()
		self:OnTick()
	end, 1, -1):Start()
end

M.EnterResultState = function(self, isWin)
	self.bindData.stateCtrl = GameState.RESULT
	self.bindData.winCtrl = isWin and 1 or 0
	self.bindData.awardBarFillAmount = 0
	self.bindData.basicAwardText = "0"
	self.bindData.comboPlusText = ""
	self.bindData.timePlusText = ""
	self.bindData.maxAwardCtrl = 0
	self.bindData.ablerewardCtrl = 0
	self.bindData.newRecordCtrl = 0
	self._rewardItems = nil

	if self.bindData.resultRewardList then
		self.bindData.resultRewardList:SetSimpleList(0)
	end
end

M.EnterPauseState = function(self)
	self.prePauseState = self.bindData.stateCtrl
	self.bindData.stateCtrl = GameState.PAUSE
end

M.OnClickStartGame = function(self)
	if self.isClosed then
		return
	end

	if self.remainingTimes < 0 then
		slot1 = gDisplayMessageMgr
		slot4 = gFactorMachineManager

		slot1:ShowMessageContent(slot4:GetText(MatchGameTextInfos.NoRewardConfirm), gDisplayMessageId.SELECT, nil, function ()
			if self.isClosed then
				return
			end

			self.isNoReward = true
			slot0 = gFactorMachineManager

			slot0:AskStartCardFlipGame(self.gameMode, function (err, startInfo)
				if self.isClosed then
					return
				end

				if err == MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				self:InitGame(startInfo)
			end)
		end, nil)

		return
	end

	slot1 = gFactorMachineManager

	slot1:AskStartCardFlipGame(self.gameMode, function (err, startInfo)
		if self.isClosed then
			return
		end

		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.isNoReward = false

		self:InitGame(startInfo)
	end)
end

M.RefreshDifficultyTime = function(self)
	local T = gFactorMachineManager:GetGameConfigTable()
	local duration = gFactorMachineManager:GetConstant(T.GameDuration)
	self.bindData.timeText = tostring(duration)
end

M.OnClickEasy = function(self)
	self.gameMode = GameMode.EASY

	self.RefreshDifficultyTime(self)
end

M.OnClickNormal = function(self)
	self.gameMode = GameMode.NORMAL

	self.RefreshDifficultyTime(self)
end

M.OnClickDifficult = function(self)
	self.gameMode = GameMode.HARD

	self.RefreshDifficultyTime(self)
end

M.InitGame = function(self, startInfo)
	self.CancelAllTimers(self)

	self.cards = {}

	for i, serverIconId in ipairs(startInfo.IconIds) do
		local realIconId = gFactorMachineManager:GetCardIconAssetId(serverIconId)
		self.cards[i] = {
			id = i,
			iconId = realIconId,
			state = CardState.UNOPENED
		}
	end

	self.totalCards = startInfo.Rows * startInfo.Cols
	self.numPairs = self.totalCards / 2
	self.combo = 0
	self.curMaxCombo = 0
	self.matchCount = 0
	self.score = 0
	self.comboScore = 0
	self.flipCount = 0
	self.firstFlipped = nil
	self.isLocked = false
	self._settlePending = false
	self.remainingTime = startInfo.TotalTimeSec
	self._serverTotalTimeSec = startInfo.TotalTimeSec

	if gFactorMachineManager._debugOverrideGameDuration == 0 then
		self.remainingTime = gFactorMachineManager._debugOverrideGameDuration
	end

	self.cardStores = {}

	self.bindData.cardList:SetSimpleList(#self.cards)
	self:RefreshScore()
	self:RefreshTime()
	self:EnterReadyState()
end

M.OnRenderCard = function(self, btn, index)
	local cardIdx = index + 1
	local card = self.cards[cardIdx]

	if not card then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

	if not store then
		return
	end

	store.cardIconId = card.iconId
	store.cardStateCtrl = card.state
	self.cardStores[cardIdx] = store

	if gFactorMachineManager._debugShowAllCards then
		store.cardStateCtrl = CardState.OPENED
	end
end

M.OnClickCard = function(self, btn, index)
	if self.bindData.stateCtrl ~= GameState.READY then
		return
	end

	if self.isLocked then
		return
	end

	if self.isClosed then
		return
	end

	if self._settlePending then
		return
	end

	if self.flipCount > 2 then
		return
	end

	local cardIdx = index + 1
	local card = self.cards[cardIdx]

	if not card then
		return
	end

	if card.state == CardState.UNOPENED then
		return
	end

	local cardId = card.id

	if self.firstFlipped ~= cardId then
		return
	end

	self.FlipCard(self, cardId, true)

	self.flipCount = self.flipCount + 1

	if self.flipCount ~= 1 then
		self.firstFlipped = cardId
	elseif self.flipCount ~= 2 then
		self.isLocked = true
		local firstCard = self.cards[self.firstFlipped]
		local firstPos = self.firstFlipped - 1
		local secondPos = cardId - 1
		local clientIsMatch = firstCard.iconId ~= card.iconId

		if clientIsMatch then
			firstCard.state = CardState.MATCH_DONE
			card.state = CardState.MATCH_DONE
			self.combo = self.combo + 1
			self.curMaxCombo = math.max(self.curMaxCombo, self.combo)
			self.matchCount = self.matchCount + 1
			local T = gFactorMachineManager.GetGameConfigTable()
			local basePair = gFactorMachineManager:GetConstant(T.BasePairScore)
			local comboBonus = self.combo * gFactorMachineManager:GetConstant(T.ComboBonus)
			self.score = self.score + basePair + comboBonus
			self.comboScore = self.comboScore + comboBonus
			local s1 = self.cardStores[cardId]

			if s1 then
				s1.cardStateCtrl = CardState.MATCH_DONE
			end

			local s2 = self.cardStores[self.firstFlipped]

			if s2 then
				s2.cardStateCtrl = CardState.MATCH_DONE
			end

			self.RefreshScore(self)
		else
			self.combo = 0

			self.RefreshScore(self)
		end

		slot10 = gFactorMachineManager

		slot10:AskFlipCardFlipPair(firstPos, secondPos, function (err, result)
			if self.isClosed then
				return
			end

			if self._settlePending then
				return
			end

			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			if result.IsMatch == clientIsMatch then
				if clientIsMatch then
					firstCard.state = CardState.UNOPENED
					card.state = CardState.UNOPENED
					self.matchCount = self.matchCount - 1
					local s1 = self.cardStores[cardId]

					if s1 then
						s1.cardStateCtrl = CardState.UNOPENED
					end

					local s2 = self.cardStores[self.firstFlipped]

					if s2 then
						s2.cardStateCtrl = CardState.UNOPENED
					end
				else
					firstCard.state = CardState.MATCH_DONE
					card.state = CardState.MATCH_DONE
					self.matchCount = self.matchCount + 1
					local s1 = self.cardStores[cardId]

					if s1 then
						s1.cardStateCtrl = CardState.MATCH_DONE
					end

					local s2 = self.cardStores[self.firstFlipped]

					if s2 then
						s2.cardStateCtrl = CardState.MATCH_DONE
					end
				end
			end

			self.score = result.CurrentScore
			self.combo = result.CurrentCombo
			self.curMaxCombo = math.max(self.curMaxCombo, result.CurrentCombo)

			if math.abs(tonumber(result.RemainingSec) - self.remainingTime) > 3 then
				self.remainingTime = result.RemainingSec
			end

			self:RefreshScore()

			if not clientIsMatch then
				local T = gFactorMachineManager.GetGameConfigTable()
				local failDisplayTime = gFactorMachineManager:GetConstant(T.FailDisplayTime)
				self.failDelayTimer = Timer.New(function ()
					if self.isClosed then
						return
					end

					self:FlipCard(self.firstFlipped, false)
					self:FlipCard(cardId, false)

					self.firstFlipped = nil
					self.flipCount = 0
					self.isLocked = false
					self.failDelayTimer = nil
				end, failDisplayTime):Start()
			else
				self.firstFlipped = nil
				self.flipCount = 0
				self.isLocked = false

				if result.IsCleared then
					self:_ShowClientSettlement(true)
				end
			end
		end)
	end
end

M.FlipCard = function(self, cardId, faceUp)
	local card = self.cards[cardId]

	if not card then
		return
	end

	card.state = faceUp and CardState.OPENED or CardState.UNOPENED
	local store = self.cardStores[cardId]

	if store and (not gFactorMachineManager._debugShowAllCards or card.state == CardState.UNOPENED) then
		store.cardStateCtrl = card.state
	end
end

M.RefreshScore = function(self)
	self.bindData.scoreText = tostring(self.score)
	self.bindData.comboText = tostring(self.combo)
end

M.RefreshTime = function(self)
	self.bindData.timeText = tostring(self.remainingTime)
	local gameDuration = self._serverTotalTimeSec

	if gFactorMachineManager._debugOverrideGameDuration == 0 then
		gameDuration = gFactorMachineManager._debugOverrideGameDuration
	end

	if gameDuration <= 0 then
		self.bindData.timeBarFillAmount = self.remainingTime / gameDuration
	else
		self.bindData.timeBarFillAmount = 0
	end
end

M.OnTick = function(self)
	if self.isClosed then
		return
	end

	if self._settlePending then
		return
	end

	self.remainingTime = math.max(0, self.remainingTime - 1)

	self.RefreshTime(self)

	if self.remainingTime < 0 then
		self.CancelAllTimers(self)
		self._ShowClientSettlement(self, false)
	end
end

M._ShowClientSettlement = function(self, isWin)
	self._settlePending = true

	self:CancelAllTimers()

	self.isLocked = false

	self:EnterResultState(isWin)

	local T = gFactorMachineManager.GetGameConfigTable()
	local baseScore = self.matchCount * gFactorMachineManager:GetConstant(T.BasePairScore)
	local timeBonus = math.floor(math.max(0, self.remainingTime) * gFactorMachineManager:GetConstant(T.TimeBonuePerSec))
	local totalScore = isWin and self.score + timeBonus or self.score
	self.bindData.basicScoreText = tostring(baseScore)
	self.bindData.resultComboText = tostring(self.curMaxCombo)
	self.bindData.comboPlusText = self.comboScore <= 0 and "+" .. tostring(self.comboScore) or ""
	self.bindData.resultTimeText = tostring(self.remainingTime)
	self.bindData.timePlusText = isWin and timeBonus <= 0 and "+" .. tostring(timeBonus) or ""
	self.bindData.totalScoreText = tostring(totalScore)

	if self.maxScore >= totalScore then
		self.maxScore = totalScore
		self.bindData.newRecordCtrl = 1
	else
		self.bindData.newRecordCtrl = 0
	end

	self.bindData.resultMaxScoreText = tostring(self.maxScore)
	self.bindData.buffCtrl = 0
	local threshold = gFactorMachineManager:GetConstant(T.RewardLevelThreshold)
	self.bindData.maxAwardText = tostring(threshold)
	self._awardCurrent = 0
	self._awardTotal = totalScore
	self._awardThreshold = threshold

	self:_AwardStepAnim(0)

	local playTime = gFactorMachineManager:GetConstant(T.PlayTime)
	self.bindData.awardTimesCountText = tostring(self.remainingTimes) .. "/" .. tostring(playTime)
	self.bindData.awardTimesTipText = ""
end

M.OnSettleReceived = function(self, result)
	if self.bindData.stateCtrl == GameState.RESULT then
		self._settlePending = true
		self.isLocked = false

		self.CancelAllTimers(self)
		self.EnterResultState(self, result.IsWin)
	end

	self._settlePending = false

	if not self._awardAnimTimer and self.bindData.stateCtrl ~= GameState.RESULT then
		if self._serverBuffCtrl then
			self.bindData.buffCtrl = self._serverBuffCtrl
		end

		if self._serverRewardItems and self.bindData.resultRewardList then
			self.bindData.resultRewardList:SetSimpleList(#self._serverRewardItems)
		end
	end

	self.bindData.basicScoreText = tostring(result.BaseScore)
	self.bindData.resultComboText = tostring(self.curMaxCombo)
	self.bindData.comboPlusText = result.ComboBonusTotal <= 0 and "+" .. tostring(result.ComboBonusTotal) or ""
	self.bindData.resultTimeText = tostring(result.TimeBonus / math.max(gFactorMachineManager:GetConstant(gFactorMachineManager.GetGameConfigTable().TimeBonuePerSec), 1))
	self.bindData.timePlusText = result.TimeBonus <= 0 and "+" .. tostring(result.TimeBonus) or ""
	self.bindData.totalScoreText = tostring(result.FinalScore)

	if self.maxScore >= result.FinalScore then
		self.maxScore = result.FinalScore
		self.bindData.newRecordCtrl = 1
	else
		self.bindData.newRecordCtrl = 0
	end

	self.bindData.resultMaxScoreText = tostring(self.maxScore)
	local threshold = gFactorMachineManager:GetConstant(gFactorMachineManager.GetGameConfigTable().RewardLevelThreshold)
	self.bindData.maxAwardText = tostring(threshold)
	self._awardTotal = result.FinalScore
	self._awardThreshold = threshold

	if not self._awardAnimTimer then
		self._awardCurrent = 0

		self._AwardStepAnim(self, 0)
	end

	local T = gFactorMachineManager.GetGameConfigTable()
	local playTime = gFactorMachineManager:GetConstant(T.PlayTime)
	self.bindData.awardTimesCountText = tostring(self.remainingTimes) .. "/" .. tostring(playTime)
	self.bindData.awardTimesTipText = ""
	self.lastRemainingTimes = self.remainingTimes
end

M._AwardStepAnim = function(self, step)
	local T = gFactorMachineManager.GetGameConfigTable()
	local threshold = self._awardThreshold

	if threshold < 0 then
		self.bindData.awardBarFillAmount = 1
		self.bindData.basicAwardText = tostring(0)

		self.FinishAwardAnim(self)

		return
	end

	local baseScore = self.matchCount * gFactorMachineManager:GetConstant(T.BasePairScore)
	local timeBonuePerSec = gFactorMachineManager:GetConstant(T.TimeBonuePerSec)
	local timeBonus = math.floor(self.remainingTime * timeBonuePerSec)
	local comboTotal = baseScore + self.comboScore
	local total = baseScore + self.comboScore + timeBonus
	local targets = {
		{
			fill = baseScore / threshold,
			text = tostring(baseScore)
		},
		{
			fill = math.min(comboTotal / threshold, 1),
			text = tostring(comboTotal)
		},
		{
			fill = math.min(total / threshold, 1),
			text = tostring(total)
		}
	}
	local target = targets[step + 1]

	if not target then
		self.FinishAwardAnim(self)

		return
	end

	if step > 1 and self.comboScore <= 0 then
		self.bindData.comboPlusText = "+" .. tostring(self.comboScore)
	end

	if step > 2 then
		local timeBonuePerSec2 = gFactorMachineManager:GetConstant(T.TimeBonuePerSec)
		local timeBonus2 = math.floor(self.remainingTime * timeBonuePerSec2)

		if timeBonus2 <= 0 then
			self.bindData.timePlusText = "+" .. tostring(timeBonus2)
		end
	end

	local TICKS = 30
	local fillStep = (target.fill - self._awardCurrent) / TICKS
	local textStart = tonumber(self.bindData.basicAwardText) or self._awardCurrent
	local textDelta = (tonumber(target.text) - textStart) / TICKS
	local tick = 0
	self._awardAnimTimer = Timer.New(function ()
		if self.isClosed then
			return
		end

		tick = tick + 1

		if TICKS < tick then
			self.bindData.awardBarFillAmount = target.fill
			self.bindData.basicAwardText = target.text
			self._awardCurrent = target.fill

			self._awardAnimTimer:Stop()

			self._awardAnimTimer = nil

			if target.fill > 1 then
				self.bindData.maxAwardCtrl = 1
				self.bindData.ablerewardCtrl = 1
				local nextStep = step + 1

				if nextStep < 1 and self.comboScore <= 0 then
					self.bindData.comboPlusText = "+" .. tostring(self.comboScore)
				end

				if nextStep < 2 then
					local tBonus = math.floor(self.remainingTime * gFactorMachineManager:GetConstant(T.TimeBonuePerSec))

					if tBonus <= 0 then
						self.bindData.timePlusText = "+" .. tostring(tBonus)
					end
				end

				self:FinishAwardAnim()
			elseif step >= 2 then
				self._awardAnimTimer = Timer.New(function ()
					self._awardAnimTimer = nil

					self:_AwardStepAnim(step + 1)
				end, 0.7):Start()
			else
				self:FinishAwardAnim()
			end

			return
		end

		self.bindData.awardBarFillAmount = self._awardCurrent + fillStep * tick
		self.bindData.basicAwardText = tostring(math.floor(textStart + textDelta * tick))
	end, 0.06, -1):Start()
end

M.FinishAwardAnim = function(self)
	local threshold = self._awardThreshold
	local total = self._awardTotal

	if threshold < total then
		self.bindData.maxAwardCtrl = 1
	end

	self.bindData.ablerewardCtrl = 1

	if self._serverBuffCtrl then
		self.bindData.buffCtrl = self._serverBuffCtrl
	end

	if self._serverRewardItems and self.bindData.resultRewardList then
		self.bindData.resultRewardList:SetSimpleList(#self._serverRewardItems)
	end

	if not self.isNoReward then
		self.remainingTimes = self.remainingTimes - 1
	end

	local T = gFactorMachineManager.GetGameConfigTable()
	local playTime = gFactorMachineManager:GetConstant(T.PlayTime)
	self.bindData.awardTimesCountText = tostring(self.remainingTimes) .. "/" .. tostring(playTime)

	if not self.isNoReward then
		self.bindData.awardTimesTipText = "-1"
	end
end

M.CancelAllTimers = function(self)
	if self.tickTimer then
		self.tickTimer:Stop()

		self.tickTimer = nil
	end

	if self.failDelayTimer then
		self.failDelayTimer:Stop()

		self.failDelayTimer = nil
	end

	if self.countDownTimer then
		self.countDownTimer:Stop()

		self.countDownTimer = nil
	end

	if self._awardAnimTimer then
		self._awardAnimTimer:Stop()

		self._awardAnimTimer = nil
	end
end

M.OnClickPause = function(self)
	local curState = self.bindData.stateCtrl

	if curState ~= GameState.CHOOSE or curState ~= GameState.RESULT then
		self.isClosed = true

		self:CancelAllTimers()
		gPanelManager:Close(self.m_Id)

		return
	end

	if curState ~= GameState.PAUSE then
		self.OnClickResume(self)

		return
	end

	self.EnterPauseState(self)

	if self.tickTimer then
		self.tickTimer:Stop()

		self.tickTimer = nil
	end

	self._pauseSec = self.remainingTime
	slot2 = gFactorMachineManager

	slot2:AskPauseCardFlipGame(function ()
	end)
end

M.OnClickResume = function(self)
	local prevState = self.prePauseState
	self.bindData.stateCtrl = prevState
	self.remainingTime = self._pauseSec

	if prevState ~= GameState.START then
		self.tickTimer = Timer.New(function ()
			self:OnTick()
		end, 1, -1):Start()
	end

	slot2 = gFactorMachineManager

	slot2:AskResumeCardFlipGame(function ()
	end)
end

M.OnClickPauseRestart = function(self)
	self:CancelAllTimers()
	gFactorMachineManager:AskAbortCardFlipGame(function ()
	end)
	self:EnterChoosePage()
end

M.OnClickExit = function(self)
	self:CancelAllTimers()
	gFactorMachineManager:AskAbortCardFlipGame(function ()
	end)
	self:EnterChoosePage()
end

M.OnClickResultRestart = function(self)
	self.CancelAllTimers(self)
	self.EnterChoosePage(self)
end

M.OnClickBack = function(self)
	self.EnterChoosePage(self)
end

M.OnClose = function(self)
	self.isClosed = true

	self.CancelAllTimers(self)
end

M.OnRenderChooseReward = function(self, btn, index)
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

	if not store then
		return
	end

	local T = gFactorMachineManager.GetGameConfigTable()
	local previewDrops = gFactorMachineManager:GetConstant(T.PreviewDrops)
	local dropId = nil

	if previewDrops then
		if type(previewDrops) ~= "table" then
			dropId = previewDrops[index + 1]
		else
			dropId = previewDrops
		end
	end

	if not dropId then
		return
	end

	local fakeItems = gCommonItemManager:ConvertDropToFakeItem(dropId, 1)

	if not fakeItems or #fakeItems ~= 0 then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 1,
		itemId = fakeItems[1].Id
	})
	store.bindData.iconId = renderData.iconId
end

M.OnRenderResultReward = function(self, btn, index)
	if not self._serverRewardItems then
		return
	end

	local item = self._serverRewardItems[index + 1]

	if not item then
		return
	end

	local renderData = gCommonItemManager:GetFakeItemRenderData(item)
	local store = gCommonItemManager:OnCommonItemRender(btn, index, renderData)
end
