-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterTabsStore.lua
-- Decompiled from: 01802_HotCenterTabsStore.lua_62ed73c5164c.luajit

C_HotCenterTabsStore = DefClass("C_HotCenterTabsStore", C_HotCenterTabsStore, C_StoreGroup)
GroupName2Class.HotCenterTabsStore = C_HotCenterTabsStore
local M = C_HotCenterTabsStore
local CollectionCountryConfig = LTConfig.CollectionCountryConfig
local InspireHubConfig = LTConfig.InspireHubConfig
local TABS_CHANGE_ANIM_NAME = "S_vx_HotCenterHome_Change01_4"
local TAB_CTRL_SHOW = 0
local TAB_CTRL_HIDE = 1

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
	self.curCountryId = nil
	self.mainType = gClientConst.HotCenterType.Main
	self.cityListData = {}
	self.showCityTab = false
	self.bigCategoryData = nil
	self.smallCategoryData = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_SYNC_PLAYER_FAN_INFO] = self.CreateAction(self, "RefreshCommonWidget"),
		[gEventConstants.ON_PLAYER_POPULARITY_CHANGE] = self.CreateAction(self, "RefreshCommonWidget")
	}
end

M.RegisterWidget = function(self)
	if self.bindData.cityList then
		self.bindData.cityList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderCityItem")
		self.bindData.cityList.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderCityItem")
		self.bindData.cityList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickCityItem")
	end

	if self.bindData.bigTab then
		self.bindData.bigTab.luaClick = self.CreateActionWithArgs(self, "OnStandaloneCardClick", true)
	end

	if self.bindData.smallTab then
		self.bindData.smallTab.luaClick = self.CreateActionWithArgs(self, "OnStandaloneCardClick", false)
	end

	if self.bindData.prevCityBtn then
		self.bindData.prevCityBtn.luaClick = self.CreateAction(self, "OnPrevCityClick")
	end

	if self.bindData.nextCityBtn then
		self.bindData.nextCityBtn.luaClick = self.CreateAction(self, "OnNextCityClick")
	end
end

M.ShowPanel = function(self, data)
	self.mainType = data and data.mainType or gClientConst.HotCenterType.Main

	self:RefreshCountry(data)
	self:RefreshCityListData()
	self:RefreshBaseInfo()
	self:RefreshStandaloneCards()
	self:RefreshCommonWidget()
	self:RefreshCityListWidget()

	if data and (data.playCityChangeAnim or data.playMainModeSwitchAnim) then
		PlayRootAnim(self, TABS_CHANGE_ANIM_NAME)
	end
end

M.RefreshCountry = function(self, data)
	local targetCountryId = data and data.countryId or nil

	if targetCountryId and gHotCenterManager:IsHomeCountryUnlocked(targetCountryId) then
		self.curCountryId = targetCountryId

		return
	end

	if self.curCountryId and gHotCenterManager:IsHomeCountryUnlocked(self.curCountryId) then
		return
	end

	self.curCountryId = gHotCenterManager:GetDefaultHomeCountryId()
end

M.RefreshCityListData = function(self)
	local cityList = gHotCenterManager:GetHomeCountryList() or {}
	self.cityListData = {}

	for _, data in ipairs(cityList) do
		if data.unlocked then
			table.insert(self.cityListData, data)
		end
	end

	self.showCityTab = #self.cityListData >= 1
end

M.GetSelectedCityIndex = function(self)
	for index, data in ipairs(self.cityListData) do
		if data.id ~= self.curCountryId then
			return index - 1
		end
	end

	return -1
end

M.RefreshCityListWidget = function(self)
	local cityList = self.bindData.cityList

	if not cityList then
		return
	end

	self.bindData.tabCtrl = self.showCityTab and TAB_CTRL_SHOW or TAB_CTRL_HIDE

	cityList:SetSimpleList(self.showCityTab and #self.cityListData or 0)

	if self.showCityTab and cityList.groupType == 0 then
		cityList.SelectItem(cityList, self.GetSelectedCityIndex(self), false)
	end

	self.RefreshCitySwitchBtns(self)
end

M.RefreshCitySwitchBtns = function(self)
	local enableSwitch = self.showCityTab and self.mainType ~= gClientConst.HotCenterType.Main

	if self.bindData.prevCityBtn then
		self.bindData.prevCityBtn:SetActive(enableSwitch)
	end

	if self.bindData.nextCityBtn then
		self.bindData.nextCityBtn:SetActive(enableSwitch)
	end
end

M.RefreshBaseInfo = function(self)
	local cfg = self.curCountryId and CollectionCountryConfig.GetConfig(self.curCountryId)

	if not cfg then
		if self.bindData.desBig then
			self.bindData.desBig.text = ""
		end

		if self.bindData.desSmall then
			self.bindData.desSmall.text = ""
		end

		return
	end

	if self.bindData.desBig then
		self.bindData.desBig.text = cfg.Name or ""
	end

	if self.bindData.desSmall then
		self.bindData.desSmall.text = cfg.InspireHubDes or ""
	end
end

M.RefreshStandaloneCards = function(self)
	local list = gHotCenterManager:GetStandaloneCategoryList(self.curCountryId, true) or {}
	local bigData, smallData = nil

	for _, data in ipairs(list) do
		if not bigData and data.tIndex ~= 0 then
			bigData = data
		elseif not smallData and data.tIndex ~= 1 then
			smallData = data
		end
	end

	for _, data in ipairs(list) do
		if not bigData then
			bigData = data
		elseif not smallData and data.id == bigData.id then
			smallData = data
		end
	end

	self.bigCategoryData = bigData
	self.smallCategoryData = smallData

	self.RefreshStandaloneCard(self, self.bindData.bigTab, bigData)
	self.RefreshStandaloneCard(self, self.bindData.smallTab, smallData)

	if self.bindData.guideRoot then
		self.bindData.guideRoot:SetActive(bigData == nil or smallData == nil)
	end
end

M.RefreshStandaloneCard = function(self, widget, data)
	if not widget then
		return
	end

	widget:SetActive(data == nil)

	if not data then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, widget)

	if not store then
		return
	end

	local cfg = InspireHubConfig.GetConfig(data.id)

	if not cfg then
		widget.SetActive(widget, false)

		return
	end

	store.label = data.label or ""
	store.lockCtrl = data.unlocked and 1 or 0
	store.bg = cfg.PlayImage
	store.guideID = cfg.GuideId
end

M.RefreshCommonWidget = function(self)
	if self.bindData.fansWidget then
		gHotCenterManager.RenderFansData(self.bindData.fansWidget)
	end

	if self.bindData.popularityWidget then
		gHotCenterManager:RenderPopularityData(self.bindData.popularityWidget)
		gHotCenterManager:RenderMainPhoneSevenDaysPopularityData(self.bindData.popularityWidget)
	end

	if self.bindData.rewardWidget then
		gHotCenterManager.RenderRewardData(self.bindData.rewardWidget)
	end
end

M.OnSimpleRenderCityItem = function(self, btn, index)
	local data = self.cityListData[index + 1]

	if not data then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

	if store then
		store.name = data.name or ""
	end
end

M.OnSimpleClickCityItem = function(self, btn, index)
	local data = self.cityListData[index + 1]

	if not data or data.id ~= self.curCountryId then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
		["6\\x91\\xf4\\x88\\xae\\xfc\\xbf\\x99\\x80\\xdc\\xec5û.\\x96\\xef"] = true,
		["PLey}\n3"] = true,
		mainType = self.mainType,
		countryId = data.id
	})
end

M.OnStandaloneCardClick = function(self, isBigCard)
	local data = isBigCard and self.bigCategoryData or self.smallCategoryData

	if not data or not data.unlocked then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
		mainType = gClientConst.HotCenterType.Main,
		subType = gClientConst.HotCenterSubType.Main,
		selectTab = data.id
	})
end

M.SwitchCityByOffset = function(self, offset)
	local count = #self.cityListData

	if count < 1 then
		return
	end

	local curIndex = self.GetSelectedCityIndex(self)

	if curIndex >= 0 then
		curIndex = 0
	end

	local newIndex = (curIndex + offset) % count

	if newIndex >= 0 then
		newIndex = newIndex + count
	end

	local data = self.cityListData[newIndex + 1]

	if not data or data.id ~= self.curCountryId then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
		["6\\x91\\xf4\\x88\\xae\\xfc\\xbf\\x99\\x80\\xdc\\xec5û.\\x96\\xef"] = true,
		["PLey}\n3"] = true,
		mainType = self.mainType,
		countryId = data.id
	})
end

M.OnPrevCityClick = function(self)
	self.SwitchCityByOffset(self, -1)
end

M.OnNextCityClick = function(self)
	self.SwitchCityByOffset(self, 1)
end

M.PlayMainCityChangeAnim = function(self)
	if self.mainType == gClientConst.HotCenterType.Main then
		return
	end

	local firstStore = gStoreManager:GetStoreGroup("HotCenterFirstStore")

	if not firstStore or not firstStore.PlayMainCityChangeAnim then
		return
	end

	firstStore.PlayMainCityChangeAnim(firstStore)
end
