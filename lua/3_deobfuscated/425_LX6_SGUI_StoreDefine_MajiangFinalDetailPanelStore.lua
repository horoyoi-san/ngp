local MahjongConfig = LTConfig.MahjongConfig
local MahjongRoomType = UX.Game.MahjongRoomType
local MjActionType = UX.Game.MjActionType
local ColorConfig = LTConfig.ColorConfig
local bit = require("bit")
C_MajiangFinalDetailPanelStore = DefClass("C_MajiangFinalDetailPanelStore", C_MajiangFinalDetailPanelStore, C_StoreGroup)
GroupName2Class.MajiangFinalDetailPanelStore = C_MajiangFinalDetailPanelStore
local M = C_MajiangFinalDetailPanelStore
local ACTION_FORMATTER = "#c%s%s#n"
local UPDATE_FREQUENCY = 5

function M:ctor()
	self.isRank = false
	self.frameCount = 0
	self.closeStartTime = 0
	self.closeInitTime = 30
end

function M:OnAwake()
	self.bindData.actionList.luaSimpleRenderItem = self:CreateAction(self.RenderActionItem)
	self.bindData.exitBtn.luaClick = self:CreateAction("ExitMaJiang", gMaJiangManager)
	self.bindData.nextBtn.luaClick = self:CreateAction("OneMore", gMaJiangManager)
end

function M:OnShow(panelId, data)
	self.closeStartTime = Time.time
	self.closeInitTime = MahjongConfig.MahjongExitTime or 30
	self.isRank = gMaJiangManager.roomInfo.RoomType == MahjongRoomType.Pve
	self.bindData.matchType = self.isRank and 0 or 1

	self:RefreshDetailScore()
	self:RefreshMyActions()
end

function M:OnClose()
	return
end

function M:OnUpdate()
	if self.closeStartTime > 0 then
		self.frameCount = self.frameCount + 1

		if self.frameCount < UPDATE_FREQUENCY then
			return
		end

		self.frameCount = 0
		local countTime = math.floor(self.closeInitTime - (Time.time - self.closeStartTime))
		self.bindData.countTime = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900882).Text, countTime)

		if countTime <= 0 then
			gMaJiangManager:ExitMaJiang()
		end
	end
end

function M:RefreshDetailScore()
	local mySeatID = gMaJiangManager.mySeatID
	local winScore = gMaJiangManager.finalScores[mySeatID + 1]

	if self.isRank then
		local rankScore = MahjongConfig.MahjongRankScore[gMaJiangManager.finalRankings[mySeatID + 1]]
		self.bindData.rankScore = gMaJiangManager:FormatScoreString(rankScore)
		self.bindData.totalScore = gMaJiangManager:FormatScoreString(winScore * MahjongConfig.MahjongCoefficient + rankScore)
		self.bindData.winScore = gMaJiangManager:FormatScoreString(winScore * MahjongConfig.MahjongCoefficient)
	else
		self.bindData.winScore = gMaJiangManager:FormatScoreString(winScore)
	end
end

function M:RefreshMyActions()
	local views = {}
	local typeNames = MahjongConfig.MahjongActionType
	local typeCols = MahjongConfig.MahjongActionTypeColor
	local huPatterns = MahjongConfig.MahjongHuPattern
	local huPatternCols = MahjongConfig.MahjongHuPatternColor
	local huActions = MahjongConfig.MahjongHuAction
	local huActionCols = MahjongConfig.MahjongHuActionColor
	local formatter = ACTION_FORMATTER
	local formatFunc = gString.Format
	local colStr = "ffffff"
	local scoreFormatter = self.isRank and self:CreateAction("FormatRankScoreString", gMaJiangManager) or self:CreateAction("FormatScoreString", gMaJiangManager)
	local myRecords = gMaJiangManager.finalRecords

	for i = 1, #myRecords do
		local action = myRecords[i]
		local type = action.Type
		local actionStrs = {}

		if type == MjActionType.Hu then
			local colCfg = ColorConfig.GetConfig(huPatternCols[action.Pattern + 1])

			if colCfg == nil then
				print_error("ColorConfig not found, ID =", huPatternCols[action.Pattern + 1])
			else
				colStr = colCfg.Color
			end

			actionStrs[#actionStrs + 1] = formatFunc(formatter, colStr, huPatterns[action.Pattern + 1])
			local val = 1
			local huAction = action.HuAction

			for j = 1, #huActions do
				if bit.band(huAction, val) > 0 then
					colCfg = ColorConfig.GetConfig(huActionCols[j])

					if colCfg == nil then
						print_error("ColorConfig not found, ID =", huActionCols[j])
					else
						colStr = colCfg.Color
					end

					actionStrs[#actionStrs + 1] = formatFunc(formatter, colStr, huActions[j])
				end

				val = val * 2
			end
		else
			local colCfg = ColorConfig.GetConfig(typeCols[type + 1])

			if colCfg == nil then
				print_error("ColorConfig not found, ID =", typeCols[type + 1])
			else
				colStr = colCfg.Color
			end

			actionStrs[#actionStrs + 1] = formatFunc(formatter, colStr, typeNames[type + 1])
		end

		local gen = action.NumOfGen

		if gen > 0 then
			actionStrs[#actionStrs + 1] = formatFunc(formatter, ColorConfig.GetConfig(ColorConfig.MahjongColor2).Color, tostring(gen) .. LTConfig.TextScriptTextConfig.GetConfig(89900318).Text)
		end

		local str = table.concat(actionStrs, "，")

		if action.Owner == gMaJiangManager.mySeatID then
			local targets = action.Targets

			for j = 1, #targets do
				if action.Score < 0 then
					views[#views + 1] = {
						isWin = false,
						action = str,
						score = scoreFormatter(action.Score),
						seat = gMaJiangManager:GetSeatName(targets[j])
					}
				else
					views[#views + 1] = {
						isWin = true,
						action = str,
						score = scoreFormatter(action.Score),
						seat = gMaJiangManager:GetSeatName(targets[j])
					}
				end
			end
		elseif action.Score < 0 then
			views[#views + 1] = {
				isWin = true,
				action = str,
				score = scoreFormatter(-1 * action.Score),
				seat = gMaJiangManager:GetSeatName(action.Owner)
			}
		else
			views[#views + 1] = {
				isWin = false,
				action = str,
				score = scoreFormatter(-1 * action.Score),
				seat = gMaJiangManager:GetSeatName(action.Owner)
			}
		end
	end

	self.actionListData = views

	self.bindData.actionList:SetSimpleList(#views)
end

function M:RenderActionItem(btn, csIndex)
	local data = self.actionListData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.descLabel = data.action
	store.seatLabel = data.seat
	store.scoreLabel = data.score
	store.isWin = data.isWin and 0 or 1
end
