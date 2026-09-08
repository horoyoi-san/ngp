-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InspireMainTabStore.lua
-- Decompiled from: 01829_InspireMainTabStore.lua_5694f45c37b0.luajit

C_InspireMainTabStore = DefClass("C_InspireMainTabStore", C_InspireMainTabStore, C_StoreGroup)
GroupName2Class.InspireMainTabStore = C_InspireMainTabStore
local M = C_InspireMainTabStore

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.msgEvents = {
		[gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE] = self.CreateAction(self, self.OnTotalLeftMoneyChange),
		[gEventConstants.ON_SYNC_PLAYER_FAN_INFO] = self.CreateAction(self, self.OnSyncPlayerFanInfo),
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self.CreateAction(self, self.OnLevelRewardUpdate)
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.DefineAllVariables = function(self)
	self.instance = {
		["\\x81:\\xff\\xaeV&\\xd2h\\xc4\\xeb RX\\xe3/\\xb8\\xce"] = 1,
		seasonId = gInspireHubManager:GetSeasonId()
	}
end

M.RegisterWidget = function(self)
	self.bindData.moneyShowMoreBtn.luaClick = self.CreateAction(self, self.OnMoneyShowMoreBtnClick)
	self.bindData.withdrawBtn.luaClick = self.CreateAction(self, self.OnWithdrawBtnClick)
	self.bindData.selectLeftTabBtn.luaClick = self.CreateActionWithArgs(self, self.OnSelectTabBtnClick, -1)
	self.bindData.selectRightTabBtn.luaClick = self.CreateActionWithArgs(self, self.OnSelectTabBtnClick, 1)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnTabListRenderItem)
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, self.OnTabListItemClick)
	self.bindData.eventList.luaSimpleRenderItem = self.CreateAction(self, self.OnEventListRenderItem)
	self.bindData.eventList.onGetTIndex = self.CreateAction(self, self.OnEventListGetTIndex)
	self.bindData.eventList.luaSimpleClick = self.CreateAction(self, self.OnEventListItemClick)
	self.bindData.followee = ""
	self.bindData.money = ""
end

M.OnTabShow = function(self, parentStore)
	self.parentStore = parentStore

	self.InitView(self)
end

M.InitView = function(self)
	if self.instance.viewInited then
		return
	end

	self.instance.viewInited = true

	self.RefreshPageData(self)
end

M.RefreshPageData = function(self)
	gInspireHubUtils.RenderInspireHubFans(self.bindData.fans)
	self.OnTotalLeftMoneyChange(self)

	local tabListMap = {}

	for i = 0, LTConfig.InspireHubGamePlayConfig.count - 1 do
		local cfg = LTConfig.InspireHubGamePlayConfig.LoadAt(i)
		local isSeasonGamePlay = cfg.SeasonGamePlayId == 0
		local item = {
			cfg = cfg,
			tIndex = isSeasonGamePlay and 1 or 0
		}
		local canShow = gHotCenterManager.CheckInspireHubGamePlayShowUnlock(cfg)

		if cfg.JobId <= 0 then
			canShow = canShow and gSpiritJobManager:GetAvailableJobByClass(cfg.JobId) == nil
		end

		if canShow and cfg.NpcCultivationId <= 0 then
			if cfg.NpcCultivationId ~= 1 then
				canShow = gSpiritManager:CheckIsMainCharacter()
			else
				local tid = gSpiritManager:GetCurFirstSpiritTid()
				local spirit = LTConfig.FightSpiritConfig.GetConfig(tid)
				local currentNpcCultivationId = spirit.NpcCultivationRelatedId
				canShow = currentNpcCultivationId ~= cfg.NpcCultivationId
			end
		end

		if canShow and cfg.HyperLinkId == 0 then
			local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(cfg.HyperLinkId, nil)
			canShow = hyperLinkInfo == nil and hyperLinkInfo.state ~= 2

			if canShow then
				local hyperLinkCfg = LTConfig.HyperLinkConfig.GetConfig(cfg.HyperLinkId)

				if hyperLinkCfg.IncomeId ~= 16 then
					canShow = gTaskNodeManager:OpenMapByTaskType(hyperLinkCfg.TabIndex, true)
				elseif hyperLinkCfg.IncomeId ~= 17 then
					canShow = gMainPhoneUtils.CheckAppCanShow(hyperLinkCfg.TabIndex)
				end
			end
		end

		canShow = canShow and array.contains(cfg.LinkShowMode, gMapUtils:UXLinkModeEnum2ConfigEnum(gLinkManager.LinkMode))

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
			if a.unlocked == b.unlocked then
				return a.unlocked
			end

			return b.cfg.Weight <= a.cfg.Weight
		end)
		table.insert(tabListData, eventListData)
	end

	table.sort(tabListData, function (a, b)
		return a.id <= b.id
	end)

	self.instance.tabListData = tabListData

	self.bindData.tabList:SetSimpleList(#tabListData)
	self:SelectTab(1)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.instance = nil
end

M.OnMoneyShowMoreBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.INSPIRE_INFO_PANEL, {
		id = LTConfig.MessageExplainConfig.HeatGainExplain
	})
end

M.OnWithdrawBtnClick = function(self)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo ~= nil then
		print_warn("popularityInfo == nil!")

		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskTakePopularityReward(0).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end
end

M.OnSyncPlayerFanInfo = function(self)
	gInspireHubUtils.RenderInspireHubFans(self.bindData.fans)
end

M.OnLevelRewardUpdate = function(self)
	gInspireHubUtils.RenderInspireHubFans(self.bindData.fans)
end

M.OnTotalLeftMoneyChange = function(self)
	local money = gSocialNetworkUtils.GetTotalLeftMoney()
	self.bindData.withdrawBtn.interactable = money >= 0
	self.bindData.money = tostring(money)
	local needNotify = LTConfig.InspireHubConfig.NotifyWithdrawMoneyThreshold <= money

	SGUI.RedDotMgr.LuaSetRedDot(needNotify, "InspireHub/InspireHub.WithdrawMoney")
end

M.OnTabListRenderItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local index = csIndex + 1
	local data = self.instance.tabListData[index]
	local cfg = LTConfig.InspireHubGamePlayTypeConfig.GetConfig(data.id)
	store.title = cfg.Name
	store.icon = cfg.TabIcon
	local selected = index ~= self.instance.currentSelectedIndex
	store.inSelected = selected and 1 or 0
end

M.OnTabListItemClick = function(self, btn, csIndex)
	local index = csIndex + 1

	if index == self.instance.currentSelectedIndex then
		self.SelectTab(self, index)
	end
end

M.OnSelectTabBtnClick = function(self, dir)
	self.SelectTab(self, self.instance.currentSelectedIndex + dir)
end

M.SelectTab = function(self, index)
	if not self.instance.tabListData then
		return
	end

	if index <= 1 or index <= #self.instance.tabListData then
		return
	end

	local lastSelectedIndex = self.instance.currentSelectedIndex

	if lastSelectedIndex == index then
		self.instance.currentSelectedIndex = index

		self.bindData.tabList:RefreshElement(lastSelectedIndex - 1)
		self.bindData.tabList:RefreshElement(index - 1)
	end

	local eventListData = self.instance.tabListData[index]
	self.instance.eventListData = eventListData

	self.bindData.eventList:SetSimpleList(#eventListData)
	self.bindData.eventList:SetNavSelectToTop(true)
end

M.OnEventListRenderItem = function(self, btn, csIndex)
	local store = self:GetStoreByWidget(btn)
	local index = csIndex + 1
	local data = self.instance.eventListData[index]
	local cfg = data.cfg
	store.title = cfg.Name
	store.background = cfg.IconId
	store.lockCtrl = data.unlocked and self.lockCtrlEnum._false or self.lockCtrlEnum._true
	store.unlockConditionsDes = data.unlocked and "" or cfg.UnlockConditionsDes

	if data.tIndex ~= 1 then
		store.eventTimeCountdown = gInspireHubManager:GetTimeCountDownStr()
		store.subtitle = cfg.Description
	else
		local tags = array.where(cfg.Tags, function (tag)
			return gFormulaUtils:GetInspireHubTagConfigCanShow(tag)
		end)

		store.list.luaSimpleRenderItem = function(tagBtn, tagCsIndex)
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

M.OnEventListGetTIndex = function(self, csIndex)
	local index = csIndex + 1
	local data = self.instance.eventListData[index]

	return data.tIndex
end

M.OnEventListItemClick = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.eventListData[index]

	if data.tIndex ~= 0 then
		local hyperLinkId = data.unlocked and data.cfg.HyperLinkId or data.cfg.LockedHyperLinkId
		local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

		if hyperLinkInfo then
			local hyperLinkCfg = LTConfig.HyperLinkConfig.GetConfig(hyperLinkId)

			if hyperLinkCfg.IncomeId ~= 17 then
				self.parentStore:ClosePanel()
			end

			hyperLinkInfo.callback()
		end
	elseif data.tIndex ~= 1 then
		local params = {
			seasonId = self.instance.seasonId,
			gamePlayId = data.cfg.Id
		}

		gPanelManager:CheckShow(gPanelId.TRIAL_PANEL, params)
	end
end

M.DefineAllEnumsAutoGen = function(self)
	self.levelCtrlEnum = {
		["Z"] = 2,
		["]"] = 3,
		["X"] = 0,
		["["] = 1,
		["\\"] = 4
	}
	self.lockCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.levelCtrlEnum = nil
	self.lockCtrlEnum = nil
end
