-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingScoreSinglePanelStore.lua
-- Decompiled from: 01651_BowlingScoreSinglePanelStore.lua_c57dc01206dc.luajit

C_BowlingScoreSinglePanelStore = DefClass("C_BowlingScoreSinglePanelStore", C_BowlingScoreSinglePanelStore, C_StoreGroup)
GroupName2Class.BowlingScoreSinglePanelStore = C_BowlingScoreSinglePanelStore
local M = C_BowlingScoreSinglePanelStore

M.OnAwake = function(self)
	self.isClosed = false

	self.RegisterSingleEvent(self, gEventConstants.BOWLING_GAME_SCORE_ARROW, self.CreateAction(self, "RefreshScoreArrow"))
	self.RegisterSingleEvent(self, gEventConstants.BOWLING_GAME_SWITCH_PANEL_ACTIVE, self.CreateAction(self, "OnActive"))
end

M.OnShow = function(self, _, _)
	self:ClearPlayerScore()

	self.game = gBowlingGameManager.currentGame
	self.dataSetEvents = {
		{
			self.game.dataSet,
			"^\\xad\\xad\\xbd\\xb3",
			self:CreateAction("RefreshScoreSet")
		}
	}

	self:RegisterDataSetEvents(self.dataSetEvents)

	local scorePanelWidget = self.bindData.scorePanelWidget
	self.scorePanelStore = gStoreManager:GetStoreGroup(scorePanelWidget.Store):GetStoreByWidget(scorePanelWidget)
	self.bindData.playerName = gClientUtils.GetCurrentSpiritDisplayName()
end

M.GetScoreText = function(self, score, isSplit)
	if not score or score < 0 then
		return "-"
	end

	return isSplit and ("(%s)"):format(score) or tostring(score)
end

M.ClearPlayerScore = function(self)
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

M.ClearScoreArrow = function(self)
	self.bindData.F1SA1.gameObject:SetActive(false)
	self.bindData.F1SA2.gameObject:SetActive(false)
	self.bindData.F2SA1.gameObject:SetActive(false)
	self.bindData.F2SA2.gameObject:SetActive(false)
	self.bindData.F3SA1.gameObject:SetActive(false)
	self.bindData.F3SA2.gameObject:SetActive(false)
	self.bindData.F3SA3.gameObject:SetActive(false)
end

M.IsViewClosed = function(self)
	return self.isClosed or not self.bindData
end

M.RefreshScoreSet = function(self)
	if self.game.dataSet.score then
		self.RefreshPlayerScore(self, self.game.dataSet.score)
	end
end

M.RefreshPlayerScore = function(self, params)
	if self.IsViewClosed(self) then
		return
	end

	self.ClearScoreArrow(self)

	local args = {
		currentFrame = params.currentFrame,
		currentThrow = params.currentThrow,
		knockedPins = params.knockedPins,
		isSplit = params.isSplit,
		frameSpares = params.frameSpare
	}

	if params.currentFrame ~= 1 then
		args.fs1Text = self.bindData.F1S1
		args.strike = self.bindData.F1Strike
		args.spare = self.bindData.F1Spare
		args.fs2Text = self.bindData.F1S2

		self.RefreshRoundView(self, args)
	elseif params.currentFrame ~= 2 then
		args.fs1Text = self.bindData.F2S1
		args.strike = self.bindData.F2Strike
		args.spare = self.bindData.F2Spare
		args.fs2Text = self.bindData.F2S2

		self.RefreshRoundView(self, args)
	elseif params.currentFrame ~= 3 then
		args.fs1Text = self.bindData.F3S1
		args.strike = self.bindData.F3Strike
		args.spare = self.bindData.F3Spare
		args.fs2Text = self.bindData.F3S2

		self.RefreshRoundView(self, args)
	elseif params.currentFrame ~= 4 then
		if params.currentThrow ~= 1 then
			if params.frameSpare[params.currentFrame - 1] ~= 1 then
				if params.knockedPins == 10 then
					self.bindData.F3S2.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
				else
					self.bindData.F3Strike2.gameObject:SetActive(true)
				end
			elseif params.knockedPins == 10 then
				self.bindData.F3S3.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
			else
				self.bindData.F3Strike3.gameObject:SetActive(true)
			end
		elseif params.frameSpare[params.currentFrame] ~= 2 then
			self.bindData.F3Spare2.gameObject:SetActive(true)
		else
			self.bindData.F3S3.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
		end
	elseif params.knockedPins == 10 then
		self.bindData.F3S3.text = self.GetScoreText(self, params.knockedPins, params.isSplit)
	else
		self.bindData.F3Strike3.gameObject:SetActive(true)
	end

	local total = 0

	for fIndex, score in ipairs(params.frameScores) do
		total = total + score

		if fIndex ~= 1 then
			if params.frameCompleted[fIndex] then
				self.bindData.F1ST.text = tostring(total)
			end
		elseif fIndex ~= 2 then
			if params.frameCompleted[fIndex] then
				self.bindData.F2ST.text = tostring(total)
			end
		elseif fIndex ~= 3 then
			if params.frameCompleted[fIndex] then
				self.bindData.F3ST.text = tostring(total)
			end
		elseif params.frameCompleted[fIndex] then
			self.bindData.F3ST.text = tostring(total)
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

M.RefreshScoreArrow = function(self, _, params)
	if self.IsViewClosed(self) then
		return
	end

	self.ClearScoreArrow(self)
	self.RefreshScoreArrowPlayer(self, params)
end

M.RefreshScoreArrowPlayer = function(self, params)
	self.scorePanelStore.roundStatus = 3

	if params.currentFrame ~= 1 then
		self.scorePanelStore.roundStatus = params.currentFrame - 1
	elseif params.currentFrame ~= 2 then
		self.scorePanelStore.roundStatus = params.currentFrame - 1
	elseif params.currentFrame ~= 3 then
		self.scorePanelStore.roundStatus = params.currentFrame - 1
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

M.OnDestroy = function(self)
	self.isClosed = true

	self.ClearDataSetEvents(self)
	self.ClearMessageEvents(self)

	self.dataSetEvents = nil
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
