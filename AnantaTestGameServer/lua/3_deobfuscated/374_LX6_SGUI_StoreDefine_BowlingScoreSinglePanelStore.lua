C_BowlingScoreSinglePanelStore = DefClass("C_BowlingScoreSinglePanelStore", C_BowlingScoreSinglePanelStore, C_StoreGroup)
GroupName2Class.BowlingScoreSinglePanelStore = C_BowlingScoreSinglePanelStore
local M = C_BowlingScoreSinglePanelStore

function M:OnAwake()
	self.isClosed = false

	self:RegisterSingleEvent(gEventConstants.BOWLING_GAME_SCORE_ARROW, self:CreateAction("RefreshScoreArrow"))
end

function M:OnShow(_, _)
	self:ClearPlayerScore()

	self.dataSetEvents = {
		{
			gBowlingGameManager.currentGame.dataSet,
			"score",
			self:CreateAction("RefreshScoreSet")
		}
	}

	self:RegisterDataSetEvents(self.dataSetEvents)

	local scorePanelWidget = self.bindData.scorePanelWidget
	self.scorePanelStore = gStoreManager:GetStoreGroup(scorePanelWidget.Store):GetStoreByWidget(scorePanelWidget)
	self.bindData.playerName = gPlayerManager.infoLogin.bindData.name
end

function M:GetScoreText(score, isSplit)
	if not score or score <= 0 then
		return "-"
	end

	return isSplit and ("(%s)"):format(score) or tostring(score)
end

function M:ClearPlayerScore()
	self.bindData.F1S1.text = ""
	self.bindData.F1S2.text = ""
	self.bindData.F1ST.text = ""
	self.bindData.F2S1.text = ""
	self.bindData.F2S2.text = ""
	self.bindData.F2ST.text = ""
	self.bindData.F3S1.text = ""
	self.bindData.F3S2.text = ""
	self.bindData.F3S3.text = ""
	self.bindData.F3ST.text = ""

	self.bindData.F1Strike.gameObject:SetActive(false)
	self.bindData.F1Spare.gameObject:SetActive(false)
	self.bindData.F2Strike.gameObject:SetActive(false)
	self.bindData.F2Spare.gameObject:SetActive(false)
	self.bindData.F3Strike.gameObject:SetActive(false)
	self.bindData.F3Strike2.gameObject:SetActive(false)
	self.bindData.F3Strike3.gameObject:SetActive(false)
	self.bindData.F3Spare.gameObject:SetActive(false)
	self.bindData.F3Spare2.gameObject:SetActive(false)
	self:ClearScoreArrow()
end

function M:ClearScoreArrow()
	self.bindData.F1SA1.gameObject:SetActive(false)
	self.bindData.F1SA2.gameObject:SetActive(false)
	self.bindData.F2SA1.gameObject:SetActive(false)
	self.bindData.F2SA2.gameObject:SetActive(false)
	self.bindData.F3SA1.gameObject:SetActive(false)
	self.bindData.F3SA2.gameObject:SetActive(false)
	self.bindData.F3SA3.gameObject:SetActive(false)
end

function M:IsViewClosed()
	return self.isClosed or not self.bindData
end

function M:RefreshScoreSet()
	if gBowlingGameManager.currentGame.dataSet.score then
		self:RefreshPlayerScore(gBowlingGameManager.currentGame.dataSet.score)
	end
end

function M:RefreshPlayerScore(params)
	if self:IsViewClosed() then
		return
	end

	self:ClearScoreArrow()

	local args = {
		currentFrame = params.currentFrame,
		currentThrow = params.currentThrow,
		knockedPins = params.knockedPins,
		isSplit = params.isSplit,
		frameSpares = params.frameSpare
	}

	if params.currentFrame == 1 then
		args.fs1Text = self.bindData.F1S1
		args.strike = self.bindData.F1Strike
		args.spare = self.bindData.F1Spare
		args.fs2Text = self.bindData.F1S2

		self:RefreshRoundView(args)
	elseif params.currentFrame == 2 then
		args.fs1Text = self.bindData.F2S1
		args.strike = self.bindData.F2Strike
		args.spare = self.bindData.F2Spare
		args.fs2Text = self.bindData.F2S2

		self:RefreshRoundView(args)
	elseif params.currentFrame == 3 then
		args.fs1Text = self.bindData.F3S1
		args.strike = self.bindData.F3Strike
		args.spare = self.bindData.F3Spare
		args.fs2Text = self.bindData.F3S2

		self:RefreshRoundView(args)
	elseif params.currentFrame == 4 then
		if params.currentThrow == 1 then
			if params.frameSpare[params.currentFrame - 1] == 1 then
				if params.knockedPins ~= 10 then
					self.bindData.F3S2.text = self:GetScoreText(params.knockedPins, params.isSplit)
				else
					self.bindData.F3Strike2.gameObject:SetActive(true)
				end
			elseif params.knockedPins ~= 10 then
				self.bindData.F3S3.text = self:GetScoreText(params.knockedPins, params.isSplit)
			else
				self.bindData.F3Strike3.gameObject:SetActive(true)
			end
		elseif params.frameSpare[params.currentFrame] == 2 then
			self.bindData.F3Spare2.gameObject:SetActive(true)
		else
			self.bindData.F3S3.text = self:GetScoreText(params.knockedPins, params.isSplit)
		end
	elseif params.knockedPins ~= 10 then
		self.bindData.F3S3.text = self:GetScoreText(params.knockedPins, params.isSplit)
	else
		self.bindData.F3Strike3.gameObject:SetActive(true)
	end

	local total = 0

	for fIndex, score in ipairs(params.frameScores) do
		total = total + score

		if fIndex == 1 then
			if params.frameCompleted[fIndex] then
				self.bindData.F1ST.text = tostring(total)
			end
		elseif fIndex == 2 then
			if params.frameCompleted[fIndex] then
				self.bindData.F2ST.text = tostring(total)
			end
		elseif fIndex == 3 then
			if params.frameCompleted[fIndex] then
				self.bindData.F3ST.text = tostring(total)
			end
		elseif params.frameCompleted[fIndex] then
			self.bindData.F3ST.text = tostring(total)
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

function M:RefreshScoreArrow(_, params)
	if self:IsViewClosed() then
		return
	end

	self:ClearScoreArrow()
	self:RefreshScoreArrowPlayer(params)
end

function M:RefreshScoreArrowPlayer(params)
	self.scorePanelStore.roundStatus = 3

	if params.currentFrame == 1 then
		self.scorePanelStore.roundStatus = params.currentFrame - 1
	elseif params.currentFrame == 2 then
		self.scorePanelStore.roundStatus = params.currentFrame - 1
	elseif params.currentFrame == 3 then
		self.scorePanelStore.roundStatus = params.currentFrame - 1
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

function M:OnDestroy()
	self.isClosed = true

	self:ClearDataSetEvents()
	self:ClearMessageEvents()

	self.dataSetEvents = nil
end
