-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingSettleBattlePanelStore.lua
-- Decompiled from: 01649_BowlingSettleBattlePanelStore.lua_96e821e09bac.luajit

C_BowlingSettleBattlePanelStore = DefClass("C_BowlingSettleBattlePanelStore", C_BowlingSettleBattlePanelStore, C_StoreGroup)
GroupName2Class.BowlingSettleBattlePanelStore = C_BowlingSettleBattlePanelStore
local M = C_BowlingSettleBattlePanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if data and data.settleData then
		self.ClearPlayerScore(self)
		self.ClearNpcScore(self)
		self.RefreshScoreBoardComplete(self, data.settleData)
	end
end

M.OnClose = function(self)
end

M.GetScoreText = function(self, score, isSlipt)
	if score and score <= 0 then
		if isSlipt then
			return "(" .. tostring(score) .. ")"
		else
			return tostring(score)
		end
	end

	return "-"
end

M.ClearPlayerScore = function(self)
	self.bindData.DF1S1.text = ""
	self.bindData.DF1S2.text = ""
	self.bindData.DF1ST.text = ""
	self.bindData.DF2S1.text = ""
	self.bindData.DF2S2.text = ""
	self.bindData.DF2ST.text = ""
	self.bindData.DF3S1.text = ""
	self.bindData.DF3S2.text = ""
	self.bindData.DF3S3.text = ""
	self.bindData.DF3ST.text = ""
	self.bindData.T.text = ""

	self.bindData.DF1Strike.gameObject:SetActive(false)
	self.bindData.DF1Spare.gameObject:SetActive(false)
	self.bindData.DF2Strike.gameObject:SetActive(false)
	self.bindData.DF2Spare.gameObject:SetActive(false)
	self.bindData.DF3Strike.gameObject:SetActive(false)
	self.bindData.DF3Strike2.gameObject:SetActive(false)
	self.bindData.DF3Strike3.gameObject:SetActive(false)
	self.bindData.DF3Spare.gameObject:SetActive(false)
	self.bindData.DF3Spare2.gameObject:SetActive(false)
end

M.ClearNpcScore = function(self)
	self.bindData.NF1S1.text = ""
	self.bindData.NF1S2.text = ""
	self.bindData.NF1ST.text = ""
	self.bindData.NF2S1.text = ""
	self.bindData.NF2S2.text = ""
	self.bindData.NF2ST.text = ""
	self.bindData.NF3S1.text = ""
	self.bindData.NF3S2.text = ""
	self.bindData.NF3S3.text = ""
	self.bindData.NF3ST.text = ""
	self.bindData.NT.text = ""

	self.bindData.NF1Strike.gameObject:SetActive(false)
	self.bindData.NF1Spare.gameObject:SetActive(false)
	self.bindData.NF2Strike.gameObject:SetActive(false)
	self.bindData.NF2Spare.gameObject:SetActive(false)
	self.bindData.NF3Strike.gameObject:SetActive(false)
	self.bindData.NF3Strike2.gameObject:SetActive(false)
	self.bindData.NF3Strike3.gameObject:SetActive(false)
	self.bindData.NF3Spare.gameObject:SetActive(false)
	self.bindData.NF3Spare2.gameObject:SetActive(false)
end

M.RefreshScoreBoardComplete = function(self, settleData)
	if not settleData then
		return
	end

	if not settleData.players or #settleData.players >= 2 then
		return
	end

	self.RefreshScoreBoardPlayer(self, settleData.players[1])
	self.RefreshScoreBoardNpc(self, settleData.players[2])
end

M.RefreshScoreBoardPlayer = function(self, params)
	if not params then
		return
	end

	if params.frameScores[1] then
		if params.frameSpare[1] ~= 1 then
			self.bindData.DF1Strike.gameObject:SetActive(true)
		elseif params.frameSpare[1] ~= 2 then
			self.bindData.DF1Spare.gameObject:SetActive(true)

			self.bindData.DF1S1.text = self:GetScoreText(params.knockedPinsHistory[1][1])
		else
			self.bindData.DF1S1.text = self.GetScoreText(self, params.knockedPinsHistory[1][1])
			self.bindData.DF1S2.text = self.GetScoreText(self, params.knockedPinsHistory[1][2])
		end
	end

	if params.frameScores[2] then
		if params.frameSpare[2] ~= 1 then
			self.bindData.DF2Strike.gameObject:SetActive(true)
		elseif params.frameSpare[2] ~= 2 then
			self.bindData.DF2Spare.gameObject:SetActive(true)

			self.bindData.DF2S1.text = self:GetScoreText(params.knockedPinsHistory[2][1])
		else
			self.bindData.DF2S1.text = self.GetScoreText(self, params.knockedPinsHistory[2][1])
			self.bindData.DF2S2.text = self.GetScoreText(self, params.knockedPinsHistory[2][2])
		end
	end

	if params.frameScores[3] then
		if params.frameSpare[3] ~= 1 then
			self.bindData.DF3Strike.gameObject:SetActive(true)
		elseif params.frameSpare[3] ~= 2 then
			self.bindData.DF3Spare.gameObject:SetActive(true)

			self.bindData.DF3S1.text = self:GetScoreText(params.knockedPinsHistory[3][1])
		else
			self.bindData.DF3S1.text = self.GetScoreText(self, params.knockedPinsHistory[3][1])
			self.bindData.DF3S2.text = self.GetScoreText(self, params.knockedPinsHistory[3][2])
		end
	end

	if params.frameScores[4] then
		if params.frameSpare[3] ~= 1 then
			if params.frameSpare[4] ~= 1 then
				self.bindData.DF3Strike2.gameObject:SetActive(true)
			elseif params.frameSpare[4] ~= 2 then
				self.bindData.DF3S2.text = self:GetScoreText(params.knockedPinsHistory[4][1])

				self.bindData.DF3Spare2.gameObject:SetActive(true)
			else
				self.bindData.DF3S2.text = self.GetScoreText(self, params.knockedPinsHistory[4][1])
				self.bindData.DF3S3.text = self.GetScoreText(self, params.knockedPinsHistory[4][2])
			end
		elseif params.frameSpare[4] ~= 1 then
			self.bindData.DF3Strike3.gameObject:SetActive(true)
		else
			self.bindData.DF3S3.text = self.GetScoreText(self, params.knockedPinsHistory[4][1])
		end
	end

	if params.frameScores[5] and params.knockedPinsHistory[5] then
		if params.knockedPinsHistory[5][1] ~= 10 then
			self.bindData.DF3Strike3.gameObject:SetActive(true)
		else
			self.bindData.DF3S3.text = self.GetScoreText(self, params.knockedPinsHistory[5][1])
		end
	end

	local total = 0

	for fIndex, score in ipairs(params.frameScores) do
		total = total + score

		if fIndex ~= 1 then
			self.bindData.DF1ST.text = tostring(total)
		elseif fIndex ~= 2 then
			self.bindData.DF2ST.text = tostring(total)
		elseif fIndex ~= 3 then
			self.bindData.DF3ST.text = tostring(total)
		else
			self.bindData.DF3ST.text = tostring(total)
		end
	end

	self.bindData.T.text = tostring(total)
end

M.RefreshScoreBoardNpc = function(self, params)
	if not params then
		return
	end

	if params.frameScores[1] then
		if params.frameSpare[1] ~= 1 then
			self.bindData.NF1Strike.gameObject:SetActive(true)
		elseif params.frameSpare[1] ~= 2 then
			self.bindData.NF1Spare.gameObject:SetActive(true)

			self.bindData.NF1S1.text = self:GetScoreText(params.knockedPinsHistory[1][1])
		else
			self.bindData.NF1S1.text = self.GetScoreText(self, params.knockedPinsHistory[1][1])
			self.bindData.NF1S2.text = self.GetScoreText(self, params.knockedPinsHistory[1][2])
		end
	end

	if params.frameScores[2] then
		if params.frameSpare[2] ~= 1 then
			self.bindData.NF2Strike.gameObject:SetActive(true)
		elseif params.frameSpare[2] ~= 2 then
			self.bindData.NF2Spare.gameObject:SetActive(true)

			self.bindData.NF2S1.text = self:GetScoreText(params.knockedPinsHistory[2][1])
		else
			self.bindData.NF2S1.text = self.GetScoreText(self, params.knockedPinsHistory[2][1])
			self.bindData.NF2S2.text = self.GetScoreText(self, params.knockedPinsHistory[2][2])
		end
	end

	if params.frameScores[3] then
		if params.frameSpare[3] ~= 1 then
			self.bindData.NF3Strike.gameObject:SetActive(true)
		elseif params.frameSpare[3] ~= 2 then
			self.bindData.NF3Spare.gameObject:SetActive(true)

			self.bindData.NF3S1.text = self:GetScoreText(params.knockedPinsHistory[3][1])
		else
			self.bindData.NF3S1.text = self.GetScoreText(self, params.knockedPinsHistory[3][1])
			self.bindData.NF3S2.text = self.GetScoreText(self, params.knockedPinsHistory[3][2])
		end
	end

	if params.frameScores[4] then
		if params.frameSpare[3] ~= 1 then
			if params.frameSpare[4] ~= 1 then
				self.bindData.NF3Strike2.gameObject:SetActive(true)
			elseif params.frameSpare[4] ~= 2 then
				self.bindData.NF3S2.text = self:GetScoreText(params.knockedPinsHistory[4][1])

				self.bindData.NF3Spare2.gameObject:SetActive(true)
			else
				self.bindData.NF3S2.text = self.GetScoreText(self, params.knockedPinsHistory[4][1])
				self.bindData.NF3S3.text = self.GetScoreText(self, params.knockedPinsHistory[4][2])
			end
		elseif params.frameSpare[4] ~= 1 then
			self.bindData.NF3Strike3.gameObject:SetActive(true)
		else
			self.bindData.NF3S3.text = self.GetScoreText(self, params.knockedPinsHistory[4][1])
		end
	end

	if params.frameScores[5] and params.knockedPinsHistory[5] then
		if params.knockedPinsHistory[5][1] ~= 10 then
			self.bindData.NF3Strike3.gameObject:SetActive(true)
		else
			self.bindData.NF3S3.text = self.GetScoreText(self, params.knockedPinsHistory[5][1])
		end
	end

	local total = 0

	for fIndex, score in ipairs(params.frameScores) do
		total = total + score

		if fIndex ~= 1 then
			self.bindData.NF1ST.text = tostring(total)
		elseif fIndex ~= 2 then
			self.bindData.NF2ST.text = tostring(total)
		elseif fIndex ~= 3 then
			self.bindData.NF3ST.text = tostring(total)
		else
			self.bindData.NF3ST.text = tostring(total)
		end
	end

	self.bindData.NT.text = tostring(total)
end
