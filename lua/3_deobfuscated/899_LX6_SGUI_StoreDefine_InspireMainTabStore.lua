C_InspireMainTabStore = DefClass("C_InspireMainTabStore", C_InspireMainTabStore, C_StoreGroup)
GroupName2Class.InspireMainTabStore = C_InspireMainTabStore
local M = C_InspireMainTabStore

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
	self:RegisterSingleEvent(gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE, self:CreateAction(self.OnTotalLeftMoneyChange))
	self:RegisterSingleEvent(gEventConstants.ON_SYNC_PLAYER_FAN_INFO, self:CreateAction(self.OnSyncPlayerFanInfo))
	self:RegisterSingleEvent(gEventConstants.ON_LEVEL_REWARD_UPDATE, self:CreateAction(self.OnLevelRewardUpdate))
end

function M:DefineAllVariables()
	self.instance = {
		currentSelectedIndex = 1,
		seasonId = gInspireHubManager:GetSeasonId()
	}
end

function M:RegisterWidget()
	self.bindData.moneyShowMoreBtn.luaClick = self:CreateAction(self.OnMoneyShowMoreBtnClick)
	self.bindData.withdrawBtn.luaClick = self:CreateAction(self.OnWithdrawBtnClick)
	self.bindData.selectLeftTabBtn.luaClick = self:CreateActionWithArgs(self.OnSelectTabBtnClick, -1)
	self.bindData.selectRightTabBtn.luaClick = self:CreateActionWithArgs(self.OnSelectTabBtnClick, 1)
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction(self.OnTabListRenderItem)
	self.bindData.tabList.luaSimpleClick = self:CreateAction(self.OnTabListItemClick)
	self.bindData.eventList.luaSimpleRenderItem = self:CreateAction(self.OnEventListRenderItem)
	self.bindData.eventList.onGetTIndex = self:CreateAction(self.OnEventListGetTIndex)
	self.bindData.eventList.luaSimpleClick = self:CreateAction(self.OnEventListItemClick)
	self.bindData.followee = ""
	self.bindData.money = ""
end

function M:OnTabShow(parentStore)
	self.parentStore = parentStore

	self:InitView()
end

function M:InitView()
	if self.instance.viewInited then
		return
	end

	self.instance.viewInited = true

	self:RefreshPageData()
end

function M:RefreshPageData()
	gInspireHubUtils.RenderInspireHubFans(self.bindData.fans)

	self.InspirePopularityUI = self.InspirePopularityUI or C_InspirePopularityUI.new()

	self.InspirePopularityUI:RenderInspirePopularityChart(self.bindData.popularityChart)
	self:OnTotalLeftMoneyChange()

	local tabListMap = {}

	for i = 0, LTConfig.InspireHubGamePlayConfig.count - 1 do
		local cfg = LTConfig.InspireHubGamePlayConfig.LoadAt(i)
		local isSeasonGamePlay = cfg.SeasonGamePlayId ~= 0
		local item = {
			cfg = cfg,
			tIndex = isSeasonGamePlay and 1 or 0
		}
		local canShow = gFormulaUtils:GetInspireHubGamePlayConfigCanShow(cfg)

		if cfg.JobId > 0 then
			canShow = canShow and gSpiritJobManager:GetAvailableJobByClass(cfg.JobId) ~= nil
		end

		if canShow and cfg.NpcCultivationId > 0 then
			if cfg.NpcCultivationId == 1 then
				canShow = gSpiritManager:CheckIsMainCharacter()
			else
				local tid = gSpiritManager:GetCurFirstSpiritTid()
				local spirit = LTConfig.FightSpiritConfig.GetConfig(tid)
				local currentNpcCultivationId = spirit.NpcCultivationRelatedId
				canShow = currentNpcCultivationId == cfg.NpcCultivationId
			end
		end

		if canShow and cfg.HyperLinkId ~= 0 then
			local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(cfg.HyperLinkId, nil)
			canShow = hyperLinkInfo.state == 2

			if canShow then
				local hyperLinkCfg = LTConfig.HyperLinkConfig.GetConfig(cfg.HyperLinkId)

				if hyperLinkCfg.IncomeId == 16 then
					canShow = gTaskNodeManager:OpenMapByTaskType(hyperLinkCfg.TabIndex, true)
				elseif hyperLinkCfg.IncomeId == 17 then
					canShow = gMainPhoneUtils.CheckAppCanShow(hyperLinkCfg.TabIndex)
				end
			end
		end

		if not canShow then
			-- Nothing
		else
			local unlocked = gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.InspireHubGameplay)
			item.unlocked = unlocked
			local gamePlayType = cfg.GamePlayType

			if tabListMap[gamePlayType] then
				table.insert(tabListMap[gamePlayType], item)
			else
				tabListMap[gamePlayType] = {
					item
				}
			end
		end
	end

	local tabListData = {}

	for k, eventListData in pairs(tabListMap) do
		eventListData.id = k

		table.sort(eventListData, function (a, b)
			if a.unlocked ~= b.unlocked then
				return a.unlocked
			end

			return b.cfg.Weight < a.cfg.Weight
		end)
		table.insert(tabListData, eventListData)
	end

	table.sort(tabListData, function (a, b)
		return a.id < b.id
	end)

	self.instance.tabListData = tabListData

	self.bindData.tabList:SetSimpleList(#tabListData)
	self:SelectTab(1)
end

function M:OnDestroy()
	self:ClearMessageEvents()

	if self.InspirePopularityUI then
		self.InspirePopularityUI = self.InspirePopularityUI:Destroy()
	end

	self.instance = nil
end

function M:OnMoneyShowMoreBtnClick()
	gPanelManager:CheckShow(gPanelId.INSPIRE_INFO_PANEL, {
		id = LTConfig.MessageExplainConfig.HeatGainExplain
	})
end

function M:OnWithdrawBtnClick()
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo == nil then
		print_warn("popularityInfo == nil!")

		return
	end

	gClientToGameDelegate:AskTakePopularityReward(popularityInfo.TotalLeftMoney).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		popularityInfo.TotalLeftMoney = 0

		gMessageManager:SendMessage(gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE)
	end
end

function M:OnSyncPlayerFanInfo()
	gInspireHubUtils.RenderInspireHubFans(self.bindData.fans)
end

function M:OnLevelRewardUpdate()
	gInspireHubUtils.RenderInspireHubFans(self.bindData.fans)
end

function M:OnTotalLeftMoneyChange()
	local money = gSocialNetworkUtils.GetTotalLeftMoney()
	self.bindData.withdrawBtn.interactable = money > 0
	self.bindData.money = tostring(money)
	local needNotify = LTConfig.InspireHubConfig.NotifyWithdrawMoneyThreshold < money

	SGUI.RedDotMgr.LuaSetRedDot(needNotify, "InspireHub/InspireHub.WithdrawMoney")
end

function M:OnTabListRenderItem(btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local index = csIndex + 1
	local data = self.instance.tabListData[index]
	local cfg = LTConfig.InspireHubGamePlayTypeConfig.GetConfig(data.id)
	store.title = cfg.Name
	store.icon = cfg.TabIcon
	local selected = index == self.instance.currentSelectedIndex
	store.inSelected = selected and 1 or 0
end

function M:OnTabListItemClick(btn, csIndex)
	local index = csIndex + 1

	if index ~= self.instance.currentSelectedIndex then
		self:SelectTab(index)
	end
end

function M:OnSelectTabBtnClick(dir)
	self:SelectTab(self.instance.currentSelectedIndex + dir)
end

function M:SelectTab(index)
	if index < 1 or index > #self.instance.tabListData then
		return
	end

	local lastSelectedIndex = self.instance.currentSelectedIndex

	if lastSelectedIndex ~= index then
		self.instance.currentSelectedIndex = index

		self.bindData.tabList:RefreshElement(lastSelectedIndex - 1)
		self.bindData.tabList:RefreshElement(index - 1)
	end

	local eventListData = self.instance.tabListData[index]
	self.instance.eventListData = eventListData

	self.bindData.eventList:SetSimpleList(#eventListData)
	self.bindData.eventList:SetNavSelectToTop(true)
end

function M:OnEventListRenderItem(btn, csIndex)
	local store = self:GetStoreByWidget(btn)
	local index = csIndex + 1
	local data = self.instance.eventListData[index]
	local cfg = data.cfg
	store.title = cfg.Name
	store.background = cfg.IconId
	store.lockCtrl = data.unlocked and self.lockCtrlEnum._false or self.lockCtrlEnum._true
	store.unlockConditionsDes = data.unlocked and "" or cfg.UnlockConditionsDes

	if data.tIndex == 1 then
		store.eventTimeCountdown = gInspireHubManager:GetTimeCountDownStr()
		store.subtitle = cfg.Description
	else
		local tags = array.where(cfg.Tags, function (tag)
			return gFormulaUtils:GetInspireHubTagConfigCanShow(tag)
		end)

		function store.list.luaSimpleRenderItem(tagBtn, tagCsIndex)
			local tag = tags[tagCsIndex + 1]
			local tagCfg = LTConfig.InspireHubTagConfig.GetConfig(tag)
			local tagStore = self:GetStoreByWidget(tagBtn)
			tagStore.title = tagCfg.Name
			tagStore.backgroundColor = LX6.Utils.ColorUtils.GetColorByString(tagCfg.BackgroundColor)
			tagStore.textColor = LX6.Utils.ColorUtils.GetColorByString(tagCfg.TextColor)
		end

		store.list:SetSimpleList(#tags)
	end

	store.levelCtrl = cfg.HeatGainSpeedStar - 1
end

function M:OnEventListGetTIndex(csIndex)
	local index = csIndex + 1
	local data = self.instance.eventListData[index]

	return data.tIndex
end

function M:OnEventListItemClick(btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.eventListData[index]

	if data.tIndex == 0 then
		local hyperLinkId = data.unlocked and data.cfg.HyperLinkId or data.cfg.LockedHyperLinkId
		local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

		if hyperLinkInfo then
			local hyperLinkCfg = LTConfig.HyperLinkConfig.GetConfig(hyperLinkId)

			if hyperLinkCfg.IncomeId == 17 then
				self.parentStore:ClosePanel()
			end

			hyperLinkInfo.callback()
		end
	elseif data.tIndex == 1 then
		local params = {
			seasonId = self.instance.seasonId,
			gamePlayId = data.cfg.Id
		}

		gPanelManager:CheckShow(gPanelId.TRIAL_PANEL, params)
	end
end

function M:DefineAllEnumsAutoGen()
	self.levelCtrlEnum = {
		l3 = 2,
		l4 = 3,
		l1 = 0,
		l2 = 1,
		l5 = 4
	}
	self.lockCtrlEnum = {
		_false = 0,
		_true = 1
	}
end

function M:ClearAllEnumsAutoGen()
	self.levelCtrlEnum = nil
	self.lockCtrlEnum = nil
end
