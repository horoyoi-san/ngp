-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WushuTournamentPanelStore.lua
-- Decompiled from: 01201_WushuTournamentPanelStore.lua_6e1db7bd7978.luajit

local SeasonConfig = LTConfig.WushuTournamentSeasonConfig
local RoundConfig = LTConfig.WushuTournamentRoundConfig
local OpponentConfig = LTConfig.WushuTournamentOpponentConfig
C_WushuTournamentPanelStore = DefClass("C_WushuTournamentPanelStore", C_WushuTournamentPanelStore, C_StoreGroup)
GroupName2Class.WushuTournamentPanelStore = C_WushuTournamentPanelStore
local M = C_WushuTournamentPanelStore
local LEVEL_STATUS_CTRL = {
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["V\r^p"] = 1,
	["/m\\xb2\\xbc\\xa6u"] = 2
}
local LEVEL_NAVIGATION_CTRL = {
	["\\x87\\x85\\x87\\x82"] = 2,
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["V[o"] = 1,
	["X\rIs"] = 3
}

M.ctor = function(self)
	self.seasonInfo = nil
	self.seasonCfg = nil
	self.roundsMap = nil
	self.curRoundIdx = 0
	self.curRoundCfg = nil
	self.curDropIdList = nil
	self.curOpponentCfgList = nil
	self.curOppIds = nil
	self.curChoiceIdx = 0
	self.curTitle = ""
	self.itemRenderDataList = nil
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.InitMessages(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	local info = gWushuTournamentManager:GetSeasonInfo()

	if info then
		self.RefreshBySeasonInfo(self, info)
	end
end

M.OnClose = function(self)
	gWushuTournamentManager:OnSelectPanelExit()
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.InitMessages = function(self)
	self.RegisterMessageEvents(self, {
		[gEventConstants.WUSHU_TOURNAMENT_SEASON_DATA_READY] = self.CreateAction(self, "OnSeasonDataReady")
	})
end

M.OnSeasonDataReady = function(self)
	local info = gWushuTournamentManager:GetSeasonInfo()

	if info then
		self.RefreshBySeasonInfo(self, info)
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnClickStartBtn)
	self.bindData.prepareBtn.luaClick = self.CreateAction(self, self.OnClickPrepareBtn)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.leftBtn.luaClick = self.CreateAction(self, self.OnClickLeftBtn)
		self.bindData.rightBtn.luaClick = self.CreateAction(self, self.OnClickRightBtn)
	end

	self.bindData.tournamentList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTournamentListItem)
	self.bindData.tournamentList.luaSelectedChanged = self.CreateAction(self, self.OnSelectTournamentList)
	self.bindData.choiceList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderChoiceListItem)
	self.bindData.choiceList.luaSelectedChanged = self.CreateAction(self, self.OnSelectChoiceList)
	self.bindData.goalList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderGoalListItem)
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderRewardListItem)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.WUSHU_TOURNAMENT_PANEL)
end

M.OnClickStartBtn = function(self)
	local roundId = self.curRoundIdx + 1
	local opponentId = self.curOppIds and self.curOppIds[self.curChoiceIdx + 1] or 0

	if opponentId ~= 0 then
		print_error("[WushuTournament] start but no opponent selected")

		return
	end

	self.bindData.startBtn.interactable = false
	slot3 = gWushuTournamentManager

	slot3:SelectOpponent(roundId, opponentId, function (ok)
		if not ok then
			self.bindData.startBtn.interactable = true
		end
	end)
end

M.OnClickPrepareBtn = function(self)
	gPanelManager:CheckShow(gPanelId.WEAPON_ARMORY_PANEL)
end

M.OnClickLeftBtn = function(self)
	if self.CanNavToLeft(self) then
		self.bindData.tournamentList:SelectItem(self.curRoundIdx - 1, true)
	end
end

M.OnClickRightBtn = function(self)
	if self.CanNavToRight(self) then
		self.bindData.tournamentList:SelectItem(self.curRoundIdx + 1, true)
	end
end

M.OnSimpleRenderTournamentListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local roundIndex = index + 1
	local roundId = self.seasonCfg.RoundIds[roundIndex]
	local locked = self:IsRoundLocked(roundIndex)
	btn.interactable = not locked
	local finished = roundIndex > (self.seasonInfo.CurrentRound or 0)
	local bestStars = self:GetBestStars(roundIndex)
	local roundCfg = roundId and RoundConfig.GetConfig(roundId) or nil
	store.statusCtrl = locked and (roundCfg and roundCfg.isSecret and LEVEL_STATUS_CTRL.SECRET or LEVEL_STATUS_CTRL.LOCK) or LEVEL_STATUS_CTRL.NORMAL
	store.finishCtrl = finished and 1 or 0
	store.titleText = roundCfg and roundCfg.Title
	store.numberText = index + 1 < 9 and "0" .. tostring(index + 1) or index + 1
	store.navigationCtrl = index ~= self.curRoundIdx and self:GetNavigationCtrl() or LEVEL_NAVIGATION_CTRL.NORMAL
	local starList = store.starList

	starList.luaSimpleRenderItem = function(starBtn, starIdx)
		local starStore = gStoreManager:GetStoreGroup(starBtn.Store):GetStoreByWidget(starBtn)

		if starStore then
			starStore.finishCtrl = starIdx >= bestStars and 1 or 0
		end
	end

	starList:SetSimpleList(3)
end

M.OnSelectTournamentList = function(self, uList)
	local index = uList.selectedIndex

	if index > 0 then
		self.curRoundIdx = index
		self.curRoundBestStars = self:GetBestStars(self.curRoundIdx + 1)

		self:RefreshChoiceList()
		self.bindData.tournamentList:RefreshLogicList()
	end
end

M.OnSimpleRenderGoalListItem = function(self, btn, goalIdx)
	local goalStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not goalStore then
		return
	end

	local target = self.curRoundCfg and self.curRoundCfg.ChallengeTargets[goalIdx + 1] or ""
	local value = self.curRoundCfg and self.curRoundCfg.CounterValues[goalIdx + 1] or 0
	goalStore.isCheckCtrl = goalIdx >= self.curRoundBestStars and 1 or 0
	goalStore.goalText = string.gsub(target, "%%s", tostring(value))
end

M.OnSimpleRenderRewardListItem = function(self, btn, rewardIdx)
	local rewardStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not rewardStore then
		return
	end

	local renderData = self.itemRenderDataList[rewardIdx + 1]

	gCommonItemManager:OnCommonItemRender(btn, rewardIdx, renderData)
end

M.RefreshGoalAndRewardList = function(self)
	self.bindData.goalList:SetSimpleList(self.curRoundCfg and #self.curRoundCfg.ChallengeTargets or 0)

	local dropDataList = {}

	for k, v in ipairs(self.curDropIdList) do
		table.insert(dropDataList, {
			dropId = v
		})
	end

	local itemInfoList = gCommonItemManager:GetItemSortedListByDropList(dropDataList, true) or {}
	self.itemRenderDataList = {}

	for i = 1, #itemInfoList do
		local item = itemInfoList[i]
		local renderData = gCommonItemManager:GetItemRenderData({
			itemId = item.Id,
			itemNum = item.Count
		})
		self.itemRenderDataList[i] = renderData
	end

	self.bindData.rewardList:SetSimpleList(#self.itemRenderDataList)
end

M.OnSimpleRenderChoiceListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = self.curOpponentCfgList and self.curOpponentCfgList[index + 1] or nil

	if not cfg then
		print_error("[WushuTournament] 选中了无效敌人")

		return
	end

	store.titleText = cfg.MonsterGroupName
	store.desText = cfg.Description
	store.enemyIconId = cfg.IconId or 0
	local weakTypes = cfg.WeakTypes
	local weakCount = weakTypes and #weakTypes or 0

	if weakCount ~= 0 then
		store.showTagCtrl = 0
		store.tagList.luaSimpleRenderItem = nil

		store.tagList:SetSimpleList(0)
	else
		store.showTagCtrl = 1

		store.tagList.luaSimpleRenderItem = function(tagBtn, tagIdx)
			local tagStore = gStoreManager:GetStoreGroup(tagBtn.Store):GetStoreByWidget(tagBtn)

			if tagStore then
				tagStore.name = LTConfig.WushuTournamentConfig.WeakTypeName[weakTypes[tagIdx + 1]]
			end
		end

		store.tagList:SetSimpleList(weakCount)
	end
end

M.OnSelectChoiceList = function(self, uList)
	local index = uList.selectedIndex
	local oppId = self.curOppIds and self.curOppIds[index + 1] or 0

	if oppId ~= 0 then
		print_error("[WushuTournament] 选中了无效敌人")

		return
	end

	self.curChoiceIdx = index
end

M.RefreshBySeasonInfo = function(self, info)
	self.seasonInfo = info
	self.seasonCfg = SeasonConfig.GetConfig(info.SeasonId)
	self.roundsMap = {}
	slot2 = ipairs
	slot4 = info.Rounds or {}

	for _, r in slot2(slot4) do
		local oppBestMap = {}
		slot8 = ipairs
		slot10 = r.OpponentBestStars or {}

		for _, ob in slot8(slot10) do
			oppBestMap[ob.OpponentId] = ob.BestStars
		end

		self.roundsMap[r.RoundId] = {
			BestStars = r.BestStars,
			OppBestMap = oppBestMap
		}
	end

	self.curRoundIdx = self:FindFirstPlayableIdx()
	self.curChoiceIdx = 0
	local roundCount = #(self.seasonCfg and self.seasonCfg.RoundIds or {})

	if roundCount ~= 0 then
		roundCount = 6
	end

	self.bindData.tournamentList:SetSimpleList(roundCount)
	self.bindData.tournamentList:SelectItem(self.curRoundIdx, true)
end

M.RefreshChoiceList = function(self)
	if not self.seasonCfg then
		return
	end

	local cfgRoundId = self.seasonCfg.RoundIds[self.curRoundIdx + 1]
	local roundCfg = cfgRoundId and RoundConfig.GetConfig(cfgRoundId) or nil

	if not roundCfg then
		self.curOppIds = {}
		self.curTitle = ""

		self.bindData.choiceList:SetSimpleList(0)
		self.bindData.choiceList:DeselectAll()

		return
	end

	self.curRoundCfg = roundCfg
	self.curOppIds = roundCfg.OpponentIds
	self.curTitle = roundCfg.Title or ""
	self.curDropIdList = {
		roundCfg.drop1,
		roundCfg.drop2,
		roundCfg.drop3
	}
	self.curOpponentCfgList = {}

	for i = 1, #self.curOppIds do
		local cfg = OpponentConfig.GetConfig(self.curOppIds[i])

		if not cfg then
			print_error("[WushuTournament] 存在无效敌人配表Id", self.curOppIds[i])
		else
			self.curOpponentCfgList[i] = cfg
		end
	end

	self.bindData.choiceList:SetSimpleList(#self.curOppIds)
	self.bindData.choiceList:SelectItem(self.curChoiceIdx, true)
	self:RefreshGoalAndRewardList()
end

M.IsRoundLocked = function(self, roundNo)
	local info = self.seasonInfo

	if not info then
		return true
	end

	local cur = info.CurrentRound or 0

	if roundNo < cur then
		return false
	end

	if not info.IsSeasonCleared and roundNo ~= cur + 1 then
		return false
	end

	return true
end

M.GetBestStars = function(self, roundNo)
	local r = self.roundsMap and self.roundsMap[roundNo]

	return r and r.BestStars or 0
end

M.FindFirstPlayableIdx = function(self)
	local info = self.seasonInfo

	if not info or not self.seasonCfg then
		return 0
	end

	local n = #(self.seasonCfg.RoundIds or {})
	local cur = info.CurrentRound or 0

	if info.IsSeasonCleared or n < cur then
		return 0
	end

	return cur
end

M.CanNavToLeft = function(self)
	return self.curRoundIdx >= 0
end

M.CanNavToRight = function(self)
	return self.curRoundIdx >= #self.seasonCfg.RoundIds - 1 and not self:IsRoundLocked(self.curRoundIdx + 2)
end

M.GetNavigationCtrl = function(self)
	local canLeft = self.CanNavToLeft(self)
	local canRight = self.CanNavToRight(self)

	if canLeft and canRight then
		return LEVEL_NAVIGATION_CTRL.BOTH
	elseif canLeft then
		return LEVEL_NAVIGATION_CTRL.LEFT
	elseif canRight then
		return LEVEL_NAVIGATION_CTRL.RIGHT
	else
		return LEVEL_NAVIGATION_CTRL.NORMAL
	end
end
