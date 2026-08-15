C_BowlingScoreBattlePanelStore = DefClass("C_BowlingScoreBattlePanelStore", C_BowlingScoreBattlePanelStore, C_StoreGroup)
GroupName2Class.BowlingScoreBattlePanelStore = C_BowlingScoreBattlePanelStore
local M = C_BowlingScoreBattlePanelStore
local BowlingUtils = require("LX6/MiniGame/BowlingGame/BowlingUtils")

function M:OnAwake()
	self.maxFrameCount = 3
	self.isClosed = false

	self:RegisterSingleEvent(gEventConstants.BOWLING_GAME_SCORE_ARROW, self:CreateAction("RefreshScoreArrow"))
end

function M:OnShow(_, _)
	self:ClearPlayerScore()
	self:ClearNpcScore()

	self.dataSetEvents = {
		{
			gBowlingGameManager.currentGame.dataSet,
			"score",
			self:CreateAction(self.RefreshScoreSet)
		}
	}

	self:RegisterDataSetEvents(self.dataSetEvents)

	local scorePanelWidget = self.bindData.scorePanelWidget
	self.scorePanelStore = gStoreManager:GetStoreGroup(scorePanelWidget.Store):GetStoreByWidget(scorePanelWidget)
	self.scorePanelStore.playerName = gPlayerManager.infoLogin.bindData.name
	self.scorePanelStore.npcName = gBowlingGameManager.currentGame:GetNpcName()

	if gBowlingGameManager:IsOnlineGame() and gBowlingGameManager.gameMode.localPlayerIndex == 2 then
		self.scorePanelStore.playerName = self.scorePanelStore.npcName
		self.scorePanelStore.npcName = self.scorePanelStore.playerName
	end
end

function M:GetScoreText(score, isSplit)
	if score == nil or score <= 0 then
		return "-"
	end

	return isSplit and ("(%s)"):format(score) or tostring(score)
end

function M:SetStrike(frame, isStrike, isNpc)
	local prefix = isNpc and "N" or "D"
	local strikeElement = self.bindData[prefix .. "F" .. frame .. "Strike"]

	strikeElement.gameObject:SetActive(isStrike or false)
end

function M:SetSpare(frame, isSpare, isNpc)
	local prefix = isNpc and "N" or "D"
	local spareElement = self.bindData[prefix .. "F" .. frame .. "Spare"]

	spareElement.gameObject:SetActive(isSpare or false)
end

function M:SetFrameScore(frame, throwIndex, score, isSplit, isNpc)
	local prefix = isNpc and "N" or "D"
	local suffix = "S" .. throwIndex

	if frame == self.maxFrameCount then
		if throwIndex == 2 then
			suffix = "S2"
		elseif throwIndex == 3 then
			suffix = "S3"
		end
	end

	local textComp = self.bindData[prefix .. "F" .. frame .. suffix]

	if score == -1 then
		textComp.text = ""
	else
		textComp.text = self:GetScoreText(score, isSplit)
	end
end

function M:ClearFrameScore(frame, throwIndex, isNpc)
	self:SetFrameScore(frame, throwIndex, -1, false, isNpc)
end

function M:SetCumulativeScore(frame, totalScore, isNpc)
	local prefix = isNpc and "N" or "D"
	local textElement = self.bindData[prefix .. "F" .. frame .. "ST"]
	textElement.text = tostring(totalScore)
end

function M:ClearAllFrameUI(isNpc)
	local prefix = isNpc and "N" or "D"

	for frame = 1, self.maxFrameCount do
		self.bindData[prefix .. "F" .. frame .. "S1"].text = ""
		self.bindData[prefix .. "F" .. frame .. "S2"].text = ""

		if frame == self.maxFrameCount then
			self.bindData[prefix .. "F3S3"].text = ""
		end

		self.bindData[prefix .. "F" .. frame .. "ST"].text = ""
	end

	for frame = 1, self.maxFrameCount do
		self:SetStrike(frame, false, isNpc)
		self:SetSpare(frame, false, isNpc)
	end

	self.bindData[prefix .. "F3Strike2"].gameObject:SetActive(false)
	self.bindData[prefix .. "F3Strike3"].gameObject:SetActive(false)
	self.bindData[prefix .. "F3Spare2"].gameObject:SetActive(false)
end

function M:ClearPlayerScore()
	self:ClearPlayerData(false)
	self:ClearScoreArrowPlayer()
end

function M:ClearNpcScore()
	self:ClearPlayerData(true)
	self:ClearScoreArrowNpc()
end

function M:ClearPlayerData(isNpc)
	local prefix = isNpc and "N" or "D"

	for frame = 1, self.maxFrameCount do
		self.bindData[prefix .. "F" .. frame .. "S1"].text = ""
		self.bindData[prefix .. "F" .. frame .. "S2"].text = ""
		self.bindData[prefix .. "F" .. frame .. "ST"].text = ""

		if frame == self.maxFrameCount then
			self.bindData[prefix .. "F3S3"].text = ""
		end
	end

	for frame = 1, self.maxFrameCount do
		self.bindData[prefix .. "F" .. frame .. "Strike"].gameObject:SetActive(false)
		self.bindData[prefix .. "F" .. frame .. "Spare"].gameObject:SetActive(false)

		if frame == self.maxFrameCount then
			self.bindData[prefix .. "F3Strike2"].gameObject:SetActive(false)
			self.bindData[prefix .. "F3Strike3"].gameObject:SetActive(false)
			self.bindData[prefix .. "F3Spare2"].gameObject:SetActive(false)
		end
	end
end

function M:ClearScoreArrow()
	self:ClearScoreArrowPlayer()
	self:ClearScoreArrowNpc()
end

function M:ClearScoreArrowPlayer()
	self:ClearScoreArrows(false)
end

function M:ClearScoreArrowNpc()
	self:ClearScoreArrows(true)
end

function M:ClearScoreArrows(isNpc)
	local prefix = isNpc and "N" or ""

	for frame = 1, self.maxFrameCount do
		self.bindData[prefix .. "F" .. frame .. "SA1"].gameObject:SetActive(false)
		self.bindData[prefix .. "F" .. frame .. "SA2"].gameObject:SetActive(false)

		if frame == self.maxFrameCount then
			self.bindData[prefix .. "F3SA3"].gameObject:SetActive(false)
		end
	end
end

function M:IsViewClosed()
	return self.isClosed or not self.STATE_EnableOnce
end

function M:RefreshScoreSet()
	if self:IsViewClosed() or gBowlingGameManager:IsOnlineGame() then
		return
	end

	self:ClearScoreArrow()
	self:RefreshScore(gBowlingGameManager.currentGame.dataSet.score)
end

function M:RefreshScore(params)
	if params == nil or self:IsViewClosed() then
		return
	end

	self:ClearScoreArrow()

	if params.currentPlayerIndex == 1 then
		self:RefreshPlayerScore(params)
	else
		self:RefreshNpcScore(params)
	end
end

function M:RefreshPlayerScore(params)
	if self:IsViewClosed() then
		return
	end

	local args = {
		currentFrame = params.currentFrame,
		currentThrow = params.currentThrow,
		knockedPins = params.knockedPins,
		isSplit = params.isSplit,
		frameSpares = params.frameSpare
	}

	if params.currentFrame == 1 then
		args.fs1Text = self.bindData.DF1S1
		args.strike = self.bindData.DF1Strike
		args.spare = self.bindData.DF1Spare
		args.fs2Text = self.bindData.DF1S2

		self:RefreshRoundView(args)
	elseif params.currentFrame == 2 then
		args.fs1Text = self.bindData.DF2S1
		args.strike = self.bindData.DF2Strike
		args.spare = self.bindData.DF2Spare
		args.fs2Text = self.bindData.DF2S2

		self:RefreshRoundView(args)
	elseif params.currentFrame == self.maxFrameCount then
		args.fs1Text = self.bindData.DF3S1
		args.strike = self.bindData.DF3Strike
		args.spare = self.bindData.DF3Spare
		args.fs2Text = self.bindData.DF3S2

		self:RefreshRoundView(args)
	elseif params.currentFrame == 4 then
		if params.currentThrow == 1 then
			if params.frameSpare[params.currentFrame - 1] == 1 then
				if params.knockedPins ~= 10 then
					self.bindData.DF3S2.text = self:GetScoreText(params.knockedPins, params.isSplit)
				else
					self.bindData.DF3Strike2.gameObject:SetActive(true)
				end
			elseif params.knockedPins ~= 10 then
				self.bindData.DF3S3.text = self:GetScoreText(params.knockedPins, params.isSplit)
			else
				self.bindData.DF3Strike3.gameObject:SetActive(true)
			end
		elseif params.frameSpare[params.currentFrame] == 2 then
			self.bindData.DF3Spare2.gameObject:SetActive(true)
		else
			self.bindData.DF3S3.text = self:GetScoreText(params.knockedPins, params.isSplit)
		end
	elseif params.knockedPins ~= 10 then
		self.bindData.DF3S3.text = self:GetScoreText(params.knockedPins, params.isSplit)
	else
		self.bindData.DF3Strike3.gameObject:SetActive(true)
	end

	local total = 0

	for fIndex, score in ipairs(params.frameScores) do
		total = total + score

		if fIndex == 1 then
			if params.frameCompleted[fIndex] then
				self.bindData.DF1ST.text = tostring(total)
			end
		elseif fIndex == 2 then
			if params.frameCompleted[fIndex] then
				self.bindData.DF2ST.text = tostring(total)
			end
		elseif fIndex == self.maxFrameCount then
			if params.frameCompleted[fIndex] then
				self.bindData.DF3ST.text = tostring(total)
			end
		elseif params.frameCompleted[fIndex] then
			self.bindData.DF3ST.text = tostring(total)
		end
	end
end

function M:RefreshRoundView(args)
	local currentFrame = args.currentFrame
	local currentThrow = args.currentThrow
	local knockedPins = args.knockedPins
	local isSplit = args.isSplit
	local frameSpares = args.frameSpares
	local fs1Text = args.fs1Text
	local strike = args.strike
	local spare = args.spare
	local fs2Text = args.fs2Text

	if currentThrow == 1 then
		if knockedPins ~= 10 then
			fs1Text.text = self:GetScoreText(knockedPins, isSplit)
		else
			strike.gameObject:SetActive(true)
		end
	elseif frameSpares[currentFrame] == 2 then
		spare.gameObject:SetActive(true)
	else
		fs2Text.text = self:GetScoreText(knockedPins, isSplit)
	end
end

function M:RefreshNpcScore(params)
	if self:IsViewClosed() then
		return
	end

	local args = {
		currentFrame = params.currentFrame,
		currentThrow = params.currentThrow,
		knockedPins = params.knockedPins,
		isSplit = params.isSplit,
		frameSpares = params.frameSpare
	}

	if params.currentFrame == 1 then
		args.fs1Text = self.bindData.NF1S1
		args.strike = self.bindData.NF1Strike
		args.spare = self.bindData.NF1Spare
		args.fs2Text = self.bindData.NF1S2

		self:RefreshRoundView(args)
	elseif params.currentFrame == 2 then
		args.fs1Text = self.bindData.NF2S1
		args.strike = self.bindData.NF2Strike
		args.spare = self.bindData.NF2Spare
		args.fs2Text = self.bindData.NF2S2

		self:RefreshRoundView(args)
	elseif params.currentFrame == self.maxFrameCount then
		args.fs1Text = self.bindData.NF3S1
		args.strike = self.bindData.NF3Strike
		args.spare = self.bindData.NF3Spare
		args.fs2Text = self.bindData.NF3S2

		self:RefreshRoundView(args)
	elseif params.currentFrame == 4 then
		if params.currentThrow == 1 then
			if params.frameSpare[params.currentFrame - 1] == 1 then
				if params.knockedPins ~= 10 then
					self.bindData.NF3S2.text = self:GetScoreText(params.knockedPins, params.isSplit)
				else
					self.bindData.NF3Strike2.gameObject:SetActive(true)
				end
			elseif params.knockedPins ~= 10 then
				self.bindData.NF3S3.text = self:GetScoreText(params.knockedPins, params.isSplit)
			else
				self.bindData.NF3Strike3.gameObject:SetActive(true)
			end
		elseif params.frameSpare[params.currentFrame] == 2 then
			self.bindData.NF3Spare2.gameObject:SetActive(true)
		else
			self.bindData.NF3S3.text = self:GetScoreText(params.knockedPins, params.isSplit)
		end
	elseif params.knockedPins ~= 10 then
		self.bindData.NF3S3.text = self:GetScoreText(params.knockedPins, params.isSplit)
	else
		self.bindData.NF3Strike3.gameObject:SetActive(true)
	end

	local total = 0

	for fIndex, score in ipairs(params.frameScores) do
		total = total + score

		if fIndex == 1 then
			if params.frameCompleted[fIndex] then
				self.bindData.NF1ST.text = tostring(score)
				self.bindData.NF1ST.text = tostring(total)
			end
		elseif fIndex == 2 then
			if params.frameCompleted[fIndex] then
				self.bindData.NF2ST.text = tostring(total)
			end
		elseif fIndex == self.maxFrameCount then
			if params.frameCompleted[fIndex] then
				self.bindData.NF3ST.text = tostring(total)
			end
		elseif params.frameCompleted[fIndex] then
			self.bindData.NF3ST.text = tostring(total)
		end
	end
end

function M:FullRefreshByScoreData(scoreData)
	if self:IsViewClosed() or scoreData == nil then
		return
	end

	local calculationResults1 = BowlingUtils:CalculatePlayerScore(scoreData[1])

	self:ProcessPlayerFullScore(scoreData[1], calculationResults1, 1)

	local calculationResults2 = BowlingUtils:CalculatePlayerScore(scoreData[2])

	self:ProcessPlayerFullScore(scoreData[2], calculationResults2, 2)

	local lastFrameScore = scoreData[2].score[self.maxFrameCount] or {}
	local isGameContinue = #lastFrameScore < 2 or #lastFrameScore == 2 and lastFrameScore[1] + lastFrameScore[2] >= 10
	local isGameEnd = not isGameContinue
	local isWin = false

	if not isGameEnd then
		return isGameEnd, isWin
	end

	local function xor(a, b)
		return a and not b or not a and b
	end

	isWin = xor(gBowlingGameManager.gameMode.localPlayerIndex == 2, calculationResults2[self.maxFrameCount].cumulativeScore <= calculationResults1[self.maxFrameCount].cumulativeScore)

	return isGameEnd, isWin
end

function M:ProcessPlayerFullScore(playerScoreData, calculationResults, playerIndex)
	if playerScoreData == nil or self:IsViewClosed() then
		return
	end

	local isNpc = playerIndex ~= 1

	self:ClearAllFrameUI(isNpc)

	for frame = 1, self.maxFrameCount do
		local frameResult = calculationResults[frame]

		if frameResult then
			local throwCount = #frameResult.score

			for i = 1, throwCount do
				if frameResult.isStrike[i] then
					if frame == 1 then
						self:SetStrike(frame, true, isNpc)
						self:ClearFrameScore(frame, 1, isNpc)
					elseif frame == 2 then
						self:SetStrike(frame, true, isNpc)
						self:ClearFrameScore(frame, 1, isNpc)
					elseif frame == self.maxFrameCount then
						if i == 1 then
							self:SetStrike(frame, true, isNpc)
							self:ClearFrameScore(frame, 1, isNpc)
						elseif i == 2 then
							self.bindData[(isNpc and "N" or "D") .. "F3Strike2"].gameObject:SetActive(true)
							self:SetFrameScore(self.maxFrameCount, 2, 0, false, isNpc)
						elseif i == 3 then
							self.bindData[(isNpc and "N" or "D") .. "F3Strike3"].gameObject:SetActive(true)
							self:SetFrameScore(self.maxFrameCount, 3, 0, false, isNpc)
						end
					end
				elseif frameResult.isSpare[i] then
					self:SetSpare(frame, true, isNpc)

					if i == 2 then
						self:ClearFrameScore(frame, 2, isNpc)
					end
				elseif frame == self.maxFrameCount then
					local throwIndex = i

					if i == 2 then
						throwIndex = 2
					elseif i == 3 then
						throwIndex = 3
					end

					self:SetFrameScore(frame, throwIndex, frameResult.score[i], frameResult.isSplit[i], isNpc)
				elseif i == 1 or i == 2 and not frameResult.isSpare[i] then
					self:SetFrameScore(frame, i, frameResult.score[i], frameResult.isSplit[i], isNpc)
				end
			end

			if throwCount > 0 then
				self:SetCumulativeScore(frame, frameResult.cumulativeScore, isNpc)
			else
				self:SetCumulativeScore(frame, "", isNpc)
			end
		end
	end

	self:RefreshScoreArrowV2(playerIndex, calculationResults)
end

function M:RefreshScoreArrowV2(playerIndex, calculationResults)
	if self:IsViewClosed() then
		return
	end

	local isNpc = playerIndex ~= 1

	self:ClearScoreArrows(isNpc)

	local prefix = isNpc and "N" or ""
	local currentRound = 1

	for i = self.maxFrameCount, 1, -1 do
		if not table.isNilOrEmpty(calculationResults[i].score) then
			currentRound = i

			break
		end
	end

	if not isNpc then
		self.scorePanelStore.playerRound = currentRound - 1
	else
		self.scorePanelStore.npcRound = currentRound - 1
	end

	for i = 1, 3 do
		self.bindData[prefix .. "F3SA" .. tostring(i)].gameObject:SetActive(false)
	end

	local lastFrameResultScore = calculationResults[self.maxFrameCount].score

	if #lastFrameResultScore > 0 then
		self.bindData[prefix .. "F3SA" .. tostring(#lastFrameResultScore)].gameObject:SetActive(true)
	end
end

function M:CalculateAndDisplayTotals(scores, isNpc)
	local cumulativeTotal = 0

	for frame = 1, self.maxFrameCount do
		local frameScores = scores[frame]

		if not table.isNilOrEmpty(frameScores) then
			local frameTotal = 0
			local throwCount = #frameScores
			local firstThrow = frameScores[1]
			local secondThrow = frameScores[2] or 0

			if frame == self.maxFrameCount then
				for i = 1, throwCount do
					frameTotal = frameTotal + frameScores[i]
				end
			elseif firstThrow == 10 then
				frameTotal = 10
				local nextFrameScores = scores[frame + 1]

				if nextFrameScores and not table.isNilOrEmpty(nextFrameScores) then
					if nextFrameScores[1] == 10 then
						frameTotal = frameTotal + 10
						local nextNextFrameScores = scores[frame + 2]

						if nextNextFrameScores and not table.isNilOrEmpty(nextNextFrameScores) then
							frameTotal = frameTotal + nextNextFrameScores[1]
						end
					else
						frameTotal = frameTotal + nextFrameScores[1]

						if nextFrameScores[2] then
							frameTotal = frameTotal + nextFrameScores[2]
						end
					end
				end
			elseif firstThrow + secondThrow == 10 then
				frameTotal = 10
				local nextFrameScores = scores[frame + 1]

				if nextFrameScores and not table.isNilOrEmpty(nextFrameScores) then
					frameTotal = frameTotal + nextFrameScores[1]
				end
			else
				frameTotal = firstThrow + secondThrow
			end

			cumulativeTotal = cumulativeTotal + frameTotal

			self:SetCumulativeScore(frame, cumulativeTotal, isNpc)
		end
	end
end

function M:RefreshScoreArrow(_, params)
	if self:IsViewClosed() then
		return
	end

	self:ClearScoreArrow()

	if params.currentPlayerIndex == 1 then
		self:RefreshScoreArrowPlayer(params)
	else
		self:RefreshScoreArrowNpc(params)
	end
end

function M:RefreshScoreArrowPlayer(params)
	self.scorePanelStore.playerRound = 3
	self.scorePanelStore.npcRound = 3

	if params.currentFrame == 1 then
		self.scorePanelStore.playerRound = params.currentFrame - 1
	elseif params.currentFrame == 2 then
		self.scorePanelStore.playerRound = params.currentFrame - 1
	elseif params.currentFrame == 3 then
		self.scorePanelStore.playerRound = params.currentFrame - 1
	elseif params.currentFrame == 4 then
		if params.currentThrow == 1 then
			if params.preFrameSpare == 1 then
				self.bindData.F3SA2.gameObject:SetActive(true)
			else
				self.bindData.F3SA3.gameObject:SetActive(true)
			end
		end
	else
		self.bindData.F3SA3.gameObject:SetActive(true)
	end
end

function M:RefreshScoreArrowNpc(params)
	self.scorePanelStore.playerRound = 3
	self.scorePanelStore.npcRound = 3

	if params.currentFrame == 1 then
		self.scorePanelStore.npcRound = params.currentFrame - 1
	elseif params.currentFrame == 2 then
		self.scorePanelStore.npcRound = params.currentFrame - 1
	elseif params.currentFrame == 3 then
		self.scorePanelStore.npcRound = params.currentFrame - 1
	elseif params.currentFrame == 4 then
		if params.currentThrow == 1 then
			if params.preFrameSpare == 1 then
				self.bindData.NF3SA2.gameObject:SetActive(true)
			else
				self.bindData.NF3SA3.gameObject:SetActive(true)
			end
		end
	else
		self.bindData.NF3SA3.gameObject:SetActive(true)
	end
end

function M:OnDestroy()
	self.isClosed = true

	self:ClearDataSetEvents()
	self:ClearMessageEvents()
end
