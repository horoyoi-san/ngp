-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingScoreBattlePanelStore.lua
-- Decompiled from: 01652_BowlingScoreBattlePanelStore.lua_06a5796213d7.luajit

C_BowlingScoreBattlePanelStore = DefClass("C_BowlingScoreBattlePanelStore", C_BowlingScoreBattlePanelStore, C_StoreGroup)
GroupName2Class.BowlingScoreBattlePanelStore = C_BowlingScoreBattlePanelStore
local M = C_BowlingScoreBattlePanelStore
local BowlingUtils = require("LX6/MiniGame/BowlingGame/BowlingUtils")

M.OnAwake = function(self)
	self.maxFrameCount = 3
	self.isClosed = false

	self.RegisterSingleEvent(self, gEventConstants.BOWLING_GAME_SCORE_ARROW, self.CreateAction(self, "RefreshScoreArrow"))
	self.RegisterSingleEvent(self, gEventConstants.BOWLING_GAME_SWITCH_PANEL_ACTIVE, self.CreateAction(self, "OnActive"))
end

M.OnShow = function(self, _, _)
	self:ClearPlayerScore()
	self:ClearNpcScore()

	self.game = gBowlingGameManager.currentGame
	self.gameMode = self.game.gameMode
	self.dataSetEvents = {
		{
			self.game.dataSet,
			"^\\xad\\xad\\xbd\\xb3",
			self:CreateAction(self.RefreshScoreSet)
		}
	}

	self:RegisterDataSetEvents(self.dataSetEvents)

	local scorePanelWidget = self.bindData.scorePanelWidget
	self.scorePanelStore = gStoreManager:GetStoreGroup(scorePanelWidget.Store):GetStoreByWidget(scorePanelWidget)
	self.scorePanelStore.playerName = gClientUtils.GetCurrentSpiritDisplayName()
	self.scorePanelStore.npcName = self.gameMode:GetOtherPlayerName()

	if gBowlingGameManager:IsOnlineGame() then
		self.scorePanelStore.playerName = gPlayerManager.infoLogin.bindData.playerName

		if gBowlingGameManager.gameInstance.gameMode.localPlayerIndex ~= 2 then
			self.scorePanelStore.playerName = self.scorePanelStore.npcName
			self.scorePanelStore.npcName = self.scorePanelStore.playerName
		end
	end

	self.scorePanelStore.playerRound = 0
end

M.GetScoreText = function(self, score, isSplit)
	if score ~= nil or score < 0 then
		return "-"
	end

	return isSplit and ("(%s)"):format(score) or tostring(score)
end

M.SetStrike = function(self, frame, isStrike, isNpc)
	local prefix = isNpc and "N" or "D"
	local strikeElement = self.bindData[prefix .. "F" .. frame .. "Strike"]

	strikeElement.gameObject:SetActive(isStrike or false)
end

M.SetSpare = function(self, frame, isSpare, isNpc)
	local prefix = isNpc and "N" or "D"
	local spareElement = self.bindData[prefix .. "F" .. frame .. "Spare"]

	spareElement.gameObject:SetActive(isSpare or false)
end

M.SetFrameScore = function(self, frame, throwIndex, score, isSplit, isNpc)
	local prefix = isNpc and "N" or "D"
	local suffix = "S" .. throwIndex

	if frame ~= self.maxFrameCount then
		if throwIndex ~= 2 then
			suffix = "S2"
		elseif throwIndex ~= 3 then
			suffix = "S3"
		end
	end

	local textComp = self.bindData[prefix .. "F" .. frame .. suffix]

	if score ~= -1 then
		textComp.text = ""
	else
		textComp.text = self.GetScoreText(self, score, isSplit)
	end
end

M.ClearFrameScore = function(self, frame, throwIndex, isNpc)
	self.SetFrameScore(self, frame, throwIndex, -1, false, isNpc)
end

M.SetCumulativeScore = function(self, frame, totalScore, isNpc)
	local prefix = isNpc and "N" or "D"
	local textElement = self.bindData[prefix .. "F" .. frame .. "ST"]
	textElement.text = tostring(totalScore)
end

M.ClearAllFrameUI = function(self, isNpc)
	local prefix = isNpc and "N" or "D"

	for frame = 1, self.maxFrameCount do
		self.bindData[prefix .. "F" .. frame .. "S1"].text = ""
		self.bindData[prefix .. "F" .. frame .. "S2"].text = ""

		if frame ~= self.maxFrameCount then
			self.bindData[prefix .. "F3S3"].text = ""
		end

		self.bindData[prefix .. "F" .. frame .. "ST"].text = ""
	end

	for frame = 1, self.maxFrameCount do
		self.SetStrike(self, frame, false, isNpc)
		self.SetSpare(self, frame, false, isNpc)
	end

	self.bindData[prefix .. "F3Strike2"].gameObject:SetActive(false)
	self.bindData[prefix .. "F3Strike3"].gameObject:SetActive(false)
	self.bindData[prefix .. "F3Spare2"].gameObject:SetActive(false)
end

M.ClearPlayerScore = function(self)
	self.ClearPlayerData(self, false)
	self.ClearScoreArrowPlayer(self)
end

M.ClearNpcScore = function(self)
	self.ClearPlayerData(self, true)
	self.ClearScoreArrowNpc(self)
end

M.ClearPlayerData = function(self, isNpc)
	local prefix = isNpc and "N" or "D"

	for frame = 1, self.maxFrameCount do
		self.bindData[prefix .. "F" .. frame .. "S1"].text = ""
		self.bindData[prefix .. "F" .. frame .. "S2"].text = ""
		self.bindData[prefix .. "F" .. frame .. "ST"].text = ""

		if frame ~= self.maxFrameCount then
			self.bindData[prefix .. "F3S3"].text = ""
		end
	end

	for frame = 1, self.maxFrameCount do
		self.bindData[prefix .. "F" .. frame .. "Strike"].gameObject:SetActive(false)
		self.bindData[prefix .. "F" .. frame .. "Spare"].gameObject:SetActive(false)

		if frame ~= self.maxFrameCount then
			self.bindData[prefix .. "F3Strike2"].gameObject:SetActive(false)
			self.bindData[prefix .. "F3Strike3"].gameObject:SetActive(false)
			self.bindData[prefix .. "F3Spare2"].gameObject:SetActive(false)
		end
	end
end

M.ClearScoreArrow = function(self)
	self.ClearScoreArrowPlayer(self)
	self.ClearScoreArrowNpc(self)
end

M.ClearScoreArrowPlayer = function(self)
	self.ClearScoreArrows(self, false)
end

M.ClearScoreArrowNpc = function(self)
	self.ClearScoreArrows(self, true)
end

M.ClearScoreArrows = function(self, isNpc)
	local prefix = isNpc and "N" or ""

	for frame = 1, self.maxFrameCount do
		self.bindData[prefix .. "F" .. frame .. "SA1"].gameObject:SetActive(false)
		self.bindData[prefix .. "F" .. frame .. "SA2"].gameObject:SetActive(false)

		if frame ~= self.maxFrameCount then
			self.bindData[prefix .. "F3SA3"].gameObject:SetActive(false)
		end
	end
end

M.SetScoreArrow = function(self, frame, throwIndex, isNpc)
	if frame <= 1 or self.maxFrameCount >= frame then
		return
	end

	local maxThrow = frame ~= self.maxFrameCount and 3 or 2
	local targetThrow = math.min(math.max(throwIndex, 1), maxThrow)
	local prefix = isNpc and "N" or ""

	self.bindData[prefix .. "F" .. frame .. "SA" .. targetThrow].gameObject:SetActive(true)
end

M.GetOnlineCurrentThrow = function(self, scoreData, playerIndex, currentRound)
	local playerScoreData = scoreData[playerIndex]

	if playerScoreData ~= nil or playerScoreData.score ~= nil then
		return 1
	end

	local frameScores = playerScoreData.score[currentRound]

	if table.isNilOrEmpty(frameScores) then
		return 1
	end

	local throwCount = #frameScores

	if currentRound >= self.maxFrameCount then
		return math.min(throwCount + 1, 2)
	end

	if throwCount < 1 then
		return throwCount + 1
	end

	local firstThrow = frameScores[1] or 0
	local secondThrow = frameScores[2] or 0

	if throwCount ~= 2 and (firstThrow ~= 10 or firstThrow + secondThrow > 10) then
		return 3
	end

	return math.min(throwCount, 3)
end

M.RefreshOnlineScoreArrow = function(self, scoreData)
	if self.IsViewClosed(self) or not gBowlingGameManager:IsOnlineGame() then
		return
	end

	local gameMode = self.gameMode

	if gameMode ~= nil then
		return
	end

	local currentRound = gameMode.currentRound or 1
	local currentPlayerIndex = gameMode.currentPlayerIndex or 1

	if currentRound <= 1 or self.maxFrameCount >= currentRound then
		return
	end

	self:ClearScoreArrow()

	self.scorePanelStore.playerRound = 3
	self.scorePanelStore.npcRound = 3
	local isNpc = currentPlayerIndex == 1

	if isNpc then
		self.scorePanelStore.npcRound = currentRound - 1
	else
		self.scorePanelStore.playerRound = currentRound - 1
	end

	local currentThrow = self.GetOnlineCurrentThrow(self, scoreData, currentPlayerIndex, currentRound)

	self.SetScoreArrow(self, currentRound, currentThrow, isNpc)
end

M.IsViewClosed = function(self)
	return self.isClosed or not self.STATE_EnableOnce
end

M.RefreshScoreSet = function(self)
	if self.IsViewClosed(self) or gBowlingGameManager:IsOnlineGame() then
		return
	end

	self.ClearScoreArrow(self)
	self.RefreshScore(self, self.game.dataSet.score)
end

M.RefreshScore = function(self, params)
	if params ~= nil or self.IsViewClosed(self) then
		return
	end

	self.ClearScoreArrow(self)

	if params.currentPlayerIndex ~= 1 then
		self.RefreshPlayerScore(self, params)
	else
		self.RefreshNpcScore(self, params)
	end
end

M.RefreshPlayerScore = function(self, params)
	if self.IsViewClosed(self) then
		return
	end

	local args = {
		currentFrame = params.currentFrame,
		currentThrow = params.currentThrow,
		knockedPins = params.knockedPins,
		isSplit = params.isSplit,
		frameSpares = params.frameSpare
	}

	if params.currentFrame ~= 1 then
		args.fs1Text = self.bindData.DF1S1
		args.strike = self.bindData.DF1Strike
		args.spare = self.bindData.DF1Spare
		args.fs2Text = self.bindData.DF1S2

		self.RefreshRoundView(self, args)
	elseif params.currentFrame ~= 2 then
		args.fs1Text = self.bindData.DF2S1
		args.strike = self.bindData.DF2Strike
		args.spare = self.bindData.DF2Spare
		args.fs2Text = self.bindData.DF2S2

		self.RefreshRoundView(self, args)
	elseif params.currentFrame ~= self.maxFrameCount then
		args.fs1Text = self.bindData.DF3S1
		args.strike = self.bindData.DF3Strike
		args.spare = self.bindData.DF3Spare
		args.fs2Text = self.bindData.DF3S2

		self.RefreshRoundView(self, args)
	elseif params.currentFrame ~= 4 then
		if params.currentThrow ~= 1 then
			if params.frameSpare[params.currentFrame - 1] ~= 1 then
				if params.knockedPins == 10 then
					self.bindData.DF3S2.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
				else
					self.bindData.DF3Strike2.gameObject:SetActive(true)
				end
			elseif params.knockedPins == 10 then
				self.bindData.DF3S3.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
			else
				self.bindData.DF3Strike3.gameObject:SetActive(true)
			end
		elseif params.frameSpare[params.currentFrame] ~= 2 then
			self.bindData.DF3Spare2.gameObject:SetActive(true)
		else
			self.bindData.DF3S3.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
		end
	elseif params.knockedPins == 10 then
		self.bindData.DF3S3.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
	else
		self.bindData.DF3Strike3.gameObject:SetActive(true)
	end

	local total = 0

	for fIndex, score in ipairs(params.frameScores) do
		total = total + score

		if fIndex ~= 1 then
			if params.frameCompleted[fIndex] then
				self.bindData.DF1ST.text = tostring(total)
			end
		elseif fIndex ~= 2 then
			if params.frameCompleted[fIndex] then
				self.bindData.DF2ST.text = tostring(total)
			end
		elseif fIndex ~= self.maxFrameCount then
			if params.frameCompleted[fIndex] then
				self.bindData.DF3ST.text = tostring(total)
			end
		elseif params.frameCompleted[fIndex] then
			self.bindData.DF3ST.text = tostring(total)
		end
	end
end

M.RefreshRoundView = function(self, args)
	local currentFrame = args.currentFrame
	local currentThrow = args.currentThrow
	local knockedPins = args.knockedPins
	local isSplit = args.isSplit
	local frameSpares = args.frameSpares
	local fs1Text = args.fs1Text
	local strike = args.strike
	local spare = args.spare
	local fs2Text = args.fs2Text

	if currentThrow ~= 1 then
		if knockedPins == 10 then
			fs1Text.text = self.GetScoreText(self, knockedPins, isSplit)
		else
			strike.gameObject:SetActive(true)
		end
	elseif frameSpares[currentFrame] ~= 2 then
		spare.gameObject:SetActive(true)
	else
		fs2Text.text = self.GetScoreText(self, knockedPins, isSplit)
	end
end

M.RefreshNpcScore = function(self, params)
	if self.IsViewClosed(self) then
		return
	end

	local args = {
		currentFrame = params.currentFrame,
		currentThrow = params.currentThrow,
		knockedPins = params.knockedPins,
		isSplit = params.isSplit,
		frameSpares = params.frameSpare
	}

	if params.currentFrame ~= 1 then
		args.fs1Text = self.bindData.NF1S1
		args.strike = self.bindData.NF1Strike
		args.spare = self.bindData.NF1Spare
		args.fs2Text = self.bindData.NF1S2

		self.RefreshRoundView(self, args)
	elseif params.currentFrame ~= 2 then
		args.fs1Text = self.bindData.NF2S1
		args.strike = self.bindData.NF2Strike
		args.spare = self.bindData.NF2Spare
		args.fs2Text = self.bindData.NF2S2

		self.RefreshRoundView(self, args)
	elseif params.currentFrame ~= self.maxFrameCount then
		args.fs1Text = self.bindData.NF3S1
		args.strike = self.bindData.NF3Strike
		args.spare = self.bindData.NF3Spare
		args.fs2Text = self.bindData.NF3S2

		self.RefreshRoundView(self, args)
	elseif params.currentFrame ~= 4 then
		if params.currentThrow ~= 1 then
			if params.frameSpare[params.currentFrame - 1] ~= 1 then
				if params.knockedPins == 10 then
					self.bindData.NF3S2.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
				else
					self.bindData.NF3Strike2.gameObject:SetActive(true)
				end
			elseif params.knockedPins == 10 then
				self.bindData.NF3S3.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
			else
				self.bindData.NF3Strike3.gameObject:SetActive(true)
			end
		elseif params.frameSpare[params.currentFrame] ~= 2 then
			self.bindData.NF3Spare2.gameObject:SetActive(true)
		else
			self.bindData.NF3S3.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
		end
	elseif params.knockedPins == 10 then
		self.bindData.NF3S3.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
	else
		self.bindData.NF3Strike3.gameObject:SetActive(true)
	end

	local total = 0

	for fIndex, score in ipairs(params.frameScores) do
		total = total + score

		if fIndex ~= 1 then
			if params.frameCompleted[fIndex] then
				self.bindData.NF1ST.text = tostring(score)
				self.bindData.NF1ST.text = tostring(total)
			end
		elseif fIndex ~= 2 then
			if params.frameCompleted[fIndex] then
				self.bindData.NF2ST.text = tostring(total)
			end
		elseif fIndex ~= self.maxFrameCount then
			if params.frameCompleted[fIndex] then
				self.bindData.NF3ST.text = tostring(total)
			end
		elseif params.frameCompleted[fIndex] then
			self.bindData.NF3ST.text = tostring(total)
		end
	end
end

M.FullRefreshByScoreData = function(self, scoreData)
	if self.IsViewClosed(self) or scoreData ~= nil then
		return
	end

	local calculationResults1 = BowlingUtils:CalculatePlayerScore(scoreData[1])

	self:ProcessPlayerFullScore(scoreData[1], calculationResults1, 1)

	local calculationResults2 = BowlingUtils:CalculatePlayerScore(scoreData[2])

	self:ProcessPlayerFullScore(scoreData[2], calculationResults2, 2)
	self:RefreshOnlineScoreArrow(scoreData)

	local lastFrameScore = scoreData[2].score[self.maxFrameCount] or {}
	local isGameContinue = #lastFrameScore <= 2 or #lastFrameScore ~= 2 and lastFrameScore[1] + lastFrameScore[2] < 10
	local isGameEnd = not isGameContinue
	local isWin = false

	if not isGameEnd then
		return isGameEnd, isWin
	end

	local xor = function(a, b)
		return a and not b or not a and b
	end

	isWin = xor(self.gameMode.localPlayerIndex ~= 2, calculationResults2[self.maxFrameCount].cumulativeScore > calculationResults1[self.maxFrameCount].cumulativeScore)

	return isGameEnd, isWin
end

M.ProcessPlayerFullScore = function(self, playerScoreData, calculationResults, playerIndex)
	if playerScoreData ~= nil or self.IsViewClosed(self) then
		return
	end

	local isNpc = playerIndex == 1

	self:ClearAllFrameUI(isNpc)

	for frame = 1, self.maxFrameCount do
		local frameResult = calculationResults[frame]

		if frameResult then
			local throwCount = #frameResult.score

			for i = 1, throwCount do
				if frameResult.isStrike[i] then
					if frame ~= 1 then
						self.SetStrike(self, frame, true, isNpc)
						self.ClearFrameScore(self, frame, 1, isNpc)
					elseif frame ~= 2 then
						self.SetStrike(self, frame, true, isNpc)
						self.ClearFrameScore(self, frame, 1, isNpc)
					elseif frame ~= self.maxFrameCount then
						if i ~= 1 then
							self.SetStrike(self, frame, true, isNpc)
							self.ClearFrameScore(self, frame, 1, isNpc)
						elseif i ~= 2 then
							self.bindData[(isNpc and "N" or "D") .. "F3Strike2"].gameObject:SetActive(true)
							self:ClearFrameScore(self.maxFrameCount, 2, isNpc)
						elseif i ~= 3 then
							self.bindData[(isNpc and "N" or "D") .. "F3Strike3"].gameObject:SetActive(true)
							self:ClearFrameScore(self.maxFrameCount, 3, isNpc)
						end
					end
				elseif frameResult.isSpare[i] then
					if frame ~= self.maxFrameCount and i ~= 3 then
						self.bindData[(isNpc and "N" or "D") .. "F3Spare2"].gameObject:SetActive(true)
						self:ClearFrameScore(frame, 3, isNpc)
					else
						self.SetSpare(self, frame, true, isNpc)
					end

					if i ~= 2 then
						self.ClearFrameScore(self, frame, 2, isNpc)
					end
				elseif frame ~= self.maxFrameCount then
					local throwIndex = i

					if i ~= 2 then
						throwIndex = 2
					elseif i ~= 3 then
						throwIndex = 3
					end

					self.SetFrameScore(self, frame, throwIndex, frameResult.score[i], frameResult.isSplit[i], isNpc)
				elseif i ~= 1 or i ~= 2 and not frameResult.isSpare[i] then
					self.SetFrameScore(self, frame, i, frameResult.score[i], frameResult.isSplit[i], isNpc)
				end
			end

			if throwCount <= 0 then
				self.SetCumulativeScore(self, frame, frameResult.cumulativeScore, isNpc)
			else
				self.SetCumulativeScore(self, frame, "", isNpc)
			end
		end
	end
end

M.RefreshScoreArrow = function(self, _, params)
	if self.IsViewClosed(self) then
		return
	end

	self.ClearScoreArrow(self)

	if params.currentPlayerIndex ~= 1 then
		self.RefreshScoreArrowPlayer(self, params)
	else
		self.RefreshScoreArrowNpc(self, params)
	end
end

M.RefreshScoreArrowPlayer = function(self, params)
	self.scorePanelStore.playerRound = 3
	self.scorePanelStore.npcRound = 3

	if params.currentFrame ~= 1 then
		self.scorePanelStore.playerRound = params.currentFrame - 1
	elseif params.currentFrame ~= 2 then
		self.scorePanelStore.playerRound = params.currentFrame - 1
	elseif params.currentFrame ~= 3 then
		self.scorePanelStore.playerRound = params.currentFrame - 1
	elseif params.currentFrame ~= 4 then
		if params.currentThrow ~= 1 then
			if params.preFrameSpare ~= 1 then
				self.bindData.F3SA2.gameObject:SetActive(true)
			else
				self.bindData.F3SA3.gameObject:SetActive(true)
			end
		end
	else
		self.bindData.F3SA3.gameObject:SetActive(true)
	end
end

M.RefreshScoreArrowNpc = function(self, params)
	self.scorePanelStore.playerRound = 3
	self.scorePanelStore.npcRound = 3

	if params.currentFrame ~= 1 then
		self.scorePanelStore.npcRound = params.currentFrame - 1
	elseif params.currentFrame ~= 2 then
		self.scorePanelStore.npcRound = params.currentFrame - 1
	elseif params.currentFrame ~= 3 then
		self.scorePanelStore.npcRound = params.currentFrame - 1
	elseif params.currentFrame ~= 4 then
		if params.currentThrow ~= 1 then
			if params.preFrameSpare ~= 1 then
				self.bindData.NF3SA2.gameObject:SetActive(true)
			else
				self.bindData.NF3SA3.gameObject:SetActive(true)
			end
		end
	else
		self.bindData.NF3SA3.gameObject:SetActive(true)
	end
end

M.OnDestroy = function(self)
	self.isClosed = true

	self.ClearDataSetEvents(self)
	self.ClearMessageEvents(self)
end

M.OnActive = function(self, _, active)
	if active then
		self.rootGo:SetActive(true)
		self.bindData.scorePanelWidget.anim:Play("S_vx_ui_panel_Bowling_ScorePanel_open")
		self.bindData.scorePanelWidget.anim:SampleCurrentAnimation(0)
	else
		slot3 = self:PlayAniChain(self.bindData.scorePanelWidget.anim, "S_vx_ui_panel_Bowling_ScorePanel_close")

		slot3:OnComplete(function ()
			self.rootGo:SetActive(false)
		end)
	end
end
