-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterMainOnlineStore.lua
-- Decompiled from: 01728_HotCenterMainOnlineStore.lua_dfc87093bc44.luajit

C_HotCenterMainOnlineStore = DefClass("C_HotCenterMainOnlineStore", C_HotCenterMainOnlineStore, C_StoreGroup)
GroupName2Class.HotCenterMainOnlineStore = C_HotCenterMainOnlineStore
local M = C_HotCenterMainOnlineStore
local LinkHubConfig = LTConfig.LinkHubConfig
local LinkHubTagConfig = LTConfig.LinkHubTagConfig
local LinkHubGameplayConfig = LTConfig.LinkHubGameplayConfig
local ONLINE_CHANGE_ANIM_NAME = "S_vx_HotCenterHome_Online_Change01"

local SetWidgetActive = function(widget, isActive)
	if widget and widget.SetActive then
		widget.SetActive(widget, isActive)
	elseif widget and widget.gameObject then
		widget.gameObject:SetActive(isActive)
	end
end

local IsOnlineLinkMode = function()
	return gLinkManager and UX and UX.Game and gLinkManager.LinkMode == UX.Game.LinkMode.None
end

local GetRootButton = function(storeGroup, fieldName, fallbackPath)
	if not storeGroup then
		return
	end

	local bindData = storeGroup.bindData

	if bindData then
		local btn = bindData[fieldName]

		if btn then
			return btn
		end
	end

	local rootGo = storeGroup.rootGo

	if not rootGo or not rootGo.FindChild then
		return
	end

	local target = rootGo:FindChild(fallbackPath or fieldName)

	if not target then
		return
	end

	return target.GetComponent(target, "UButton")
end

local GetHotCenterHomeStore = function()
	return gStoreManager:GetStoreGroup("HotCenterHomeStore")
end

local PlayRootAnim = function(storeGroup, animName)
	if not storeGroup or not storeGroup.rootWidget or not storeGroup.rootWidget.anim then
		return
	end

	local anim = storeGroup.rootWidget.anim

	anim.Stop(anim)
	anim.Play(anim, animName)
	anim.SampleCurrentAnimation(anim, 0)
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.lockCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.CONTENT_LIST_TEMPLATE = {
		["NEo"] = 1,
		["&\\xc2k\r5\\xe49\\x9bq\\x8dw\\x84\\x93"] = 3,
		["\\x86\\x90,\\x85U\n\\xdf"] = 0,
		["`w7\\x9b!\\xe5\\xc4"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.lockCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	if not self._seasonLevelHandler then
		self._seasonLevelHandler = function()
			self.bindData.contentList:RefreshList()
		end

		gMessageManager:AddMessageListener(gEventConstants.ONLINE_SEASON_LEVEL_CHANGED, self._seasonLevelHandler)
	end
end

M.OnGroupDisable = function(self)
	if self._seasonLevelHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.ONLINE_SEASON_LEVEL_CHANGED, self._seasonLevelHandler)

		self._seasonLevelHandler = nil
	end
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshSwitchModeButtonActive(self)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderContentListItem")
	self.bindData.contentList.luaSimpleClick = self:CreateAction("OnSimpleClickContentList")
	self.bindData.contentList.onGetTIndex = self:CreateAction("OnGetContentListTIndex")
	local switchModeBtn = GetRootButton(self, "switchModeBtnMoblie", "SwitchModeBtnMoblie")
	switchModeBtn = switchModeBtn or GetRootButton(self, "SwitchModeBtnMoblie", "SwitchModeBtnMoblie")

	if switchModeBtn then
		switchModeBtn.luaClick = self.CreateAction(self, "OnSwitchModeBtnClick")
	end

	self.RefreshSwitchModeButtonActive(self)
end

M.RefreshSwitchModeButtonActive = function(self)
	local switchModeBtn = GetRootButton(self, "switchModeBtnMoblie", "SwitchModeBtnMoblie")
	switchModeBtn = switchModeBtn or GetRootButton(self, "SwitchModeBtnMoblie", "SwitchModeBtnMoblie")

	if switchModeBtn then
		SetWidgetActive(switchModeBtn, false)
	end
end

M.OnSimpleRenderContentListItem = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data then
		return
	end

	if data.tIndex == self.CONTENT_LIST_TEMPLATE.TEXT then
		if data.tIndex ~= self.CONTENT_LIST_TEMPLATE.MAIN_TAB then
			local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

			if store then
				self.RefreshRecommendInfo(self, store.slot1, gClientConst.HotCenterOnlineGameType.Rob)
				self.RefreshRecommendInfo(self, store.slot2, gClientConst.HotCenterOnlineGameType.ExtractionShooter)
				self.RefreshRecommendInfo(self, store.slot3, gClientConst.HotCenterOnlineGameType.MidSize)
				self.RefreshPublicEvent(self, store, store.slot4)
				self.RefreshRecommendInfo(self, store.slot5, gClientConst.HotCenterOnlineGameType.SmallSize)
			end
		elseif data.tIndex ~= self.CONTENT_LIST_TEMPLATE.SMALL_CELL then
			gHotCenterManager.RenderOnlineListWidget(btn, data.Id)
		elseif data.tIndex ~= self.CONTENT_LIST_TEMPLATE.DATA_TEMPLATE then
			self.RenderDataTemplate(self, btn)
		end
	end
end

M.RenderDataTemplate = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	gHotCenterManager:RenderSevenDaysPopularityData(store.popularityWidget, true)

	store.goShopBtn.luaClick = function()
		local hyperLinkId = LinkHubConfig.JumpToLinkStore
		local name = LinkHubConfig.JumpToLinkStoreName

		gHotCenterManager.OnGoOnlineHyperLink(name, hyperLinkId)
	end

	gHotCenterManager:RenderSeasonData(store.seasonDataWidget)

	if store.seasonDataWidget then
		store.seasonDataWidget.luaClick = function()
			gPanelManager:CheckShow(gPanelId.SEASON_LOG_MAIN_PANEL)
		end
	end
end

M.RefreshPublicEvent = function(self, mainStore, widget)
	local info = gHotCenterManager:GetCurrentPublicEventInfo()
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	if info then
		mainStore.showPublicCtrl = 1
		local config = LinkHubConfig.GetConfig(gClientConst.HotCenterOnlineGameType.PublicEvent)
		store.name = config.Name
		store.icon = config.PlayImage
		local publicEventCfg = LTConfig.PublicEventConfig.GetConfig(info.publicEvent)

		if store.popularityList then
			store.popularityList:SetSimpleList(publicEventCfg.HeatGainSpeedStar or 0)
		end
	else
		local textId = IsOnlineLinkMode() and 89901837 or 89901836
		store.desc = LTConfig.TextScriptTextConfig.GetConfig(textId).Text
		mainStore.showPublicCtrl = 0
	end

	widget.luaClick = function()
		gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
			["\\x8f!\"3q\\x9ed\\xcf2\\xa4\\xad"] = true,
			mainType = gClientConst.HotCenterType.Online,
			subType = gClientConst.HotCenterSubType.OnlineDetail
		})
	end
end

M.RefreshRecommendInfo = function(self, widget, linkHubId)
	if not widget then
		return
	end

	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	if linkHubId then
		local config = LinkHubConfig.GetConfig(linkHubId)
		local name = ""

		if config then
			name = config.Name
			store.name = config.Name
			store.desc = config.Description
			store.icon = config.PlayImage

			if config.Tag <= 0 then
				store.showBadgeCtrl = 1
				local tagCfg = LinkHubTagConfig.GetConfig(config.Tag)
				store.badgeText = tagCfg and tagCfg.Name or ""
				store.quality = tagCfg.Quality
			else
				store.showBadgeCtrl = 0
			end

			if store.popularityList then
				store.popularityList:SetSimpleList(config.HeatGainSpeedStar or 0)
			end
		end

		local curId = linkHubId

		widget.luaClick = function()
			if curId ~= gClientConst.HotCenterOnlineGameType.Rob or curId ~= gClientConst.HotCenterOnlineGameType.ExtractionShooter then
				gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
					mainType = gClientConst.HotCenterType.Online,
					subType = gClientConst.HotCenterSubType.OnlineDetail,
					gameType = curId
				})
			else
				gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
					mainType = gClientConst.HotCenterType.Online,
					subType = gClientConst.HotCenterSubType.OnlineSub,
					gameType = curId
				})
			end
		end
	end
end

M.OnSimpleClickContentList = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= self.CONTENT_LIST_TEMPLATE.SMALL_CELL then
		gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
			mainType = gClientConst.HotCenterType.Online,
			subType = gClientConst.HotCenterSubType.OnlineDetail,
			gameType = data.gameType,
			gameplayId = data.Id
		})
	end
end

M.OnGetContentListTIndex = function(self, index)
	local data = self.contentListData[index + 1]

	if data then
		return data.tIndex or 0
	end

	return 0
end

M.OnSwitchModeBtnClick = function(self)
	local homeStore = GetHotCenterHomeStore()

	if homeStore and homeStore.SwitchToSingleMainMode then
		homeStore.SwitchToSingleMainMode(homeStore)
	end
end

M.ShowPanel = function(self, data)
	slot2 = gHotCenterManager

	slot2:RefreshPlayerState()
	self:RefreshSwitchModeButtonActive()

	self.contentListData = {
		{
			["M\\x98\\x89\\x8bU"] = 10000,
			tIndex = self.CONTENT_LIST_TEMPLATE.DATA_TEMPLATE
		},
		{
			["M\\x98\\x89\\x8bU"] = 9999,
			tIndex = self.CONTENT_LIST_TEMPLATE.MAIN_TAB
		},
		{
			["M\\x98\\x89\\x8bU"] = 9998,
			tIndex = self.CONTENT_LIST_TEMPLATE.TEXT
		}
	}
	local count = LinkHubGameplayConfig.count

	for i = 0, count - 1 do
		local gameplayCfg = LinkHubGameplayConfig.LoadAt(i)

		if gameplayCfg and gameplayCfg.IsRecommended and gFormulaUtils:GetLinkHubGameplayConfigCanShow(gameplayCfg.Id) then
			local tIndex = self.CONTENT_LIST_TEMPLATE.SMALL_CELL

			table.insert(self.contentListData, {
				["\tF\\x9d\\x81\\x80J"] = true,
				Id = gameplayCfg.Id,
				gameType = gameplayCfg.HubID,
				weight = gameplayCfg.Weight,
				tIndex = tIndex
			})
		end
	end

	table.sort(self.contentListData, function (a, b)
		return b.weight <= a.weight
	end)
	self.bindData.contentList:SetSimpleList(#self.contentListData)

	if data and data.playMainModeSwitchAnim then
		PlayRootAnim(self, ONLINE_CHANGE_ANIM_NAME)
	end
end
