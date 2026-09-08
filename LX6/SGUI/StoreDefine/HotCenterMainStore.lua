-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterMainStore.lua
-- Decompiled from: 01763_HotCenterMainStore.lua_eb9346b314a4.luajit

C_HotCenterMainStore = DefClass("C_HotCenterMainStore", C_HotCenterMainStore, C_StoreGroup)
GroupName2Class.HotCenterMainStore = C_HotCenterMainStore
local M = C_HotCenterMainStore
local CollectionCountryConfig = LTConfig.CollectionCountryConfig
local InspireHubConfig = LTConfig.InspireHubConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.lastCityTabIndex = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.lockCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.fansIncreaseCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 0,
		["GNhM\n="] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.lockCtrlEnum = nil
	self.fansIncreaseCtrlEnum = nil
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnLanguageChange = function(self, lang)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_SYNC_PLAYER_FAN_INFO] = self.CreateAction(self, self.OnSyncPlayerFanInfo)
	}
end

M.RegisterWidget = function(self)
	if self.bindData.cityTab then
		self.bindData.cityTab.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderCityTabItem")
		self.bindData.cityTab.luaSimpleClick = self.CreateAction(self, "OnSimpleClickCityTab")
		self.bindData.cityTab.luaSelectedChanged = self.CreateAction(self, "OnCityTabSelectedChanged")
	end

	if self.bindData.categoryList then
		self.bindData.categoryList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderCategoryListItem")
		self.bindData.categoryList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickCategoryList")
		self.bindData.categoryList.onGetTIndex = self.CreateAction(self, "OnGetCategoryListTIndex")
	end

	if self.bindData.leftBtn then
		self.bindData.leftBtn.luaClick = self.CreateAction(self, "OnLeftBtnClick")
	end

	if self.bindData.rightBtn then
		self.bindData.rightBtn.luaClick = self.CreateAction(self, "OnRightBtnClick")
	end
end

M.OnSimpleRenderCityTabItem = function(self, btn, index)
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

	if not store then
		return
	end

	local cfg = CollectionCountryConfig.LoadAt(index)
	store.name = cfg and cfg.Name or ""
end

M.OnCityTabSelectedChanged = function(self, list)
	local selectedIndex = list.selectedIndex
	self.lastCityTabIndex = selectedIndex
	local cfg = CollectionCountryConfig.LoadAt(selectedIndex)
	self.curSelectCountryId = cfg.Id
	self.bindData.cityDesc = cfg.InspireHubDes or ""
	local countryConfig = LTConfig.CollectionCountryConfig.GetConfig(cfg.Id)
	local isUnlocked = gEventConditionUtils.CheckHasUnlocked(countryConfig, UX.Game.EventConditionImplModule.PopularityCountryUnlock, "InspireHubUnlockProgress")
	self.bindData.lockCtrl = isUnlocked and self.lockCtrlEnum._false or self.lockCtrlEnum._true

	if not isUnlocked then
		self.bindData.lockText = countryConfig.InspireHubUnlockConditionsDes
	end

	self.RefreshCategoryList(self)
end

M.OnSimpleClickCityTab = function(self, btn, index)
end

M.OnSimpleRenderCategoryListItem = function(self, btn, index)
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

	if not store then
		return
	end

	local data = self.categoryListData[index + 1]

	if not data then
		return
	end

	local cfg = InspireHubConfig.GetConfig(data.id)
	store.label = data.label or ""
	store.lockCtrl = data.unlocked and self.lockCtrlEnum._true or self.lockCtrlEnum._false
	store.bg = cfg.PlayImage
	store.guideID = cfg.GuideId
end

M.OnSimpleClickCategoryList = function(self, btn, index)
	local data = self.categoryListData[index + 1]

	if not data then
		return
	end

	if not data.unlocked then
		return
	end

	local cfg = InspireHubConfig.GetConfig(data.id)

	if cfg.HyperLinkId <= 0 then
		local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(cfg.HyperLinkId, nil)

		if hyperLinkInfo and hyperLinkInfo.callback then
			hyperLinkInfo.callback()
		end

		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
		mainType = gClientConst.HotCenterType.Main,
		subType = gClientConst.HotCenterSubType.Main,
		selectTab = data.id
	})
end

M.OnGetCategoryListTIndex = function(self, index)
	local data = self.categoryListData[index + 1]

	if data then
		return data.tIndex or 0
	end

	return 0
end

M.OnLeftBtnClick = function(self)
	local newIndex = self.bindData.cityTab.selectedIndex + 1

	if CollectionCountryConfig.count < newIndex then
		newIndex = 0
	end

	self.bindData.cityTab:SelectItem(newIndex, true)
end

M.OnRightBtnClick = function(self)
	local newIndex = self.bindData.cityTab.selectedIndex - 1

	if newIndex >= 0 then
		newIndex = CollectionCountryConfig.count - 1
	end

	self.bindData.cityTab:SelectItem(newIndex, true)
end

M.RefreshCategoryList = function(self)
	self.categoryListData = gHotCenterManager:GetStandaloneCategoryList(self.curSelectCountryId, true)

	self.bindData.categoryList:SetSimpleList(#self.categoryListData)
end

M.OnSyncPlayerFanInfo = function(self)
	gHotCenterManager.RenderFansData(self.bindData.fansWidget)
end

M.ShowPanel = function(self, data)
	self.bindData.cityTab:SetSimpleList(CollectionCountryConfig.count)

	self.curSelectCountryId = nil

	if CollectionCountryConfig.count <= 0 then
		local restoreIndex = self.lastCityTabIndex or 0

		if CollectionCountryConfig.count < restoreIndex then
			restoreIndex = 0
		end

		self.bindData.cityTab:SelectItem(restoreIndex)
	end

	gHotCenterManager.RenderFansData(self.bindData.fansWidget)
	gHotCenterManager:RenderPopularityData(self.bindData.popularityWidget)
	gHotCenterManager.RenderRewardData(self.bindData.rewardWidget)
end
