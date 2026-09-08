-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopHomePagePanelStore.lua
-- Decompiled from: 01321_ShopHomePagePanelStore.lua_35c678e7a1ae.luajit

local MallConfig = LTConfig.MallConfig
local MallMainTabConfig = LTConfig.MallMainTabConfig

local GetTabRectIndex = function(tabId)
	local cfg = MallMainTabConfig.GetConfig(tabId)

	return cfg and cfg.TabRectIndex or 0
end

local ConsumableConfig = LTConfig.ConsumableConfig
local PlayerPrefs = UnityEngine.PlayerPrefs

require("LX6/Manager/Shop/MallCameraManager")

C_ShopHomePagePanelStore = DefClass("C_ShopHomePagePanelStore", C_ShopHomePagePanelStore, C_StoreGroup)
GroupName2Class.ShopHomePagePanelStore = C_ShopHomePagePanelStore
local M = C_ShopHomePagePanelStore
M.TabType = {}
M.TabUnlockMapping = {}
M.TabMoneyConfig = {}
M.MainTabToMallIdMap = {}
M.MainTabToSubTabsMap = {}
M.TabSwitchFunctionMap = {
	[MallMainTabConfig.Recommend] = gSwitchFunctionId.MALL_RECOMMEND,
	[MallMainTabConfig.Sale] = gSwitchFunctionId.MALL_SALE,
	[MallMainTabConfig.Box] = gSwitchFunctionId.MALL_RADIANT_CHEST,
	[MallMainTabConfig.Closet] = gSwitchFunctionId.MALL_CLOSET,
	[MallMainTabConfig.Gacha] = gSwitchFunctionId.MALL_GACHA_SYSTEM
}

M.InitMallTabConfigs = function(self)
	self.TabType = {}
	self.TabUnlockMapping = {}
	self.TabMoneyConfig = {}
	self.MainTabToMallIdMap = {}
	self.MainTabToSubTabsMap = {}

	for i = 0, MallMainTabConfig.count - 1 do
		local mainTabCfg = MallMainTabConfig.LoadAt(i)

		if mainTabCfg and mainTabCfg.Id == MallMainTabConfig.Charge and mainTabCfg.Id == MallMainTabConfig.Bundle then
			local tabId = mainTabCfg.Id
			self.TabType[tabId] = tabId

			if mainTabCfg.UnlockId and mainTabCfg.UnlockId <= 0 then
				self.TabUnlockMapping[tabId] = mainTabCfg.UnlockId
			end
		end
	end

	for i = 0, MallConfig.count - 1 do
		local mallCfg = MallConfig.LoadAt(i)

		if mallCfg and mallCfg.Tab then
			local mallId = mallCfg.Id
			local mainTabId = mallCfg.Tab.Main
			local subTabId = mallCfg.Tab.Second

			if mainTabId and not self.MainTabToMallIdMap[mainTabId] then
				self.MainTabToMallIdMap[mainTabId] = mallId
			end

			if mainTabId then
				if not self.MainTabToSubTabsMap[mainTabId] then
					self.MainTabToSubTabsMap[mainTabId] = {}
				end

				table.insert(self.MainTabToSubTabsMap[mainTabId], {
					mallId = mallId,
					subTabId = subTabId or 0,
					name = mallCfg.SubTabName or "",
					icon = mallCfg.SubTabIcon or 0
				})
			end

			if mallCfg.ShowItemIds and #mallCfg.ShowItemIds <= 0 then
				self.TabMoneyConfig[mallId] = mallCfg.ShowItemIds
			end
		end
	end

	for _, subTabs in pairs(self.MainTabToSubTabsMap) do
		table.sort(subTabs, function (a, b)
			return (a.subTabId or 0) <= (b.subTabId or 0)
		end)
	end
end

M.ctor = function(self)
	self:InitMallTabConfigs()

	local firstTabId = next(self.TabType)
	self.currentTab = firstTabId or 1
	self.currentTabStore = nil
	self.tabsData = {}
	self.selectedSpiritId = nil
	self.tryOnFashionId = 0
	self.hasCharacterChange = false
	self.currentCameraTemplateId = nil
	self.commodityDataCache = nil
	self.bgIconId = 0
	self.pendingSubTabId = 0
	self.pendingCommodityId = 0
	self.rootArea = nil
	self.lastTabRectIndex = -1
	self.mallCameraEnabled = false
	self.currentPreviewCommodityId = 0
	self.mallLookAtCommodityId = 0
	self.boxTabGachaType = 2
	self.lastTryOnCommodityData = nil
	self._suppressNextTabChanged = false
	self._preloadSceneTimer = nil
	self._preloadSceneList = nil
	self._preloadSceneIndex = 0
	self._closingAnim = false
	self._stage2DelayHandle = nil
	self.currentSubMallId = 0
	self._videoBtnCallback = nil
	self._bgBlackFrameTimer = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.InitTabsData(self)

	if self.rootGo then
		self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	end
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	if gCS.LuaUtils.IsOnPS5 and (self.lastTabRectIndex ~= 1 or self.lastTabRectIndex ~= 2) then
		local iconId = self.m_Id * 100 + self.lastTabRectIndex

		gPanelManager:RemovePS5StoreIconPanel(iconId)
	end
end

M.OnDestroy = function(self)
	self._TeardownMall(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if not gSwitchFunctionManager:CheckEnable(gSwitchFunctionId.MALL_MAIN) then
		gPanelManager:Close(self.m_Id)

		return
	end

	self.bindData.CCPlayer:Init()
	self.bindData.CCPlayer.gameObject:SetActive(true)
	self.bindData.videoAndBgRT.gameObject:SetActive(true)
	self.bindData.bgBlackImage.gameObject:SetActive(true)

	self._teardownDone = false

	gMallSceneManager:SetMallVCamera(self.bindData.VCamera)
	gMallSceneManager:StartListenDynamicGoLoaded()
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	self.bindData.camera.transform:SetParent(nil, false)
	self.bindData.camera.gameObject:GetOrAddComponent(typeof(LX6.GUI.DestroyOnPlayModeExit))
	self.bindData.camera.transform:GetChild(0).gameObject:SetActive(true)

	self.bindData.camera.transform.position = gCS.CameraDataMgr.MainCamera.transform.position
	self.bindData.camera.transform.rotation = gCS.CameraDataMgr.MainCamera.transform.rotation

	gMallManager:OnMallOpened()

	self.bindData.showUICtrl = 1

	self:InitMallTabConfigs()

	self.currentTab = MallMainTabConfig.Recommend
	self.boxTabGachaType = data and data.boxGachaType ~= 3 and 3 or 2
	self.bindData.modelTab.selectedIndex = 0
	self.tryOnFashionId = 0
	self.hasCharacterChange = false
	self.selectedSpiritId = data and data.spiritId or gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	self.bindData.bgActive = false

	self:SetModelBtnActive(false)

	self.bgIconId = MallConfig.BackGroundIconId or 0

	self:InitCommodityData()
	self:RefreshMoneyDisplay()
	self:SetMainTabVisible(true)

	self.pendingSubTabId = data and data.subTabId or 0
	self.pendingCommodityId = data and data.commodityId or self.pendingCommodityId or 0

	if data and data.tabId then
		local targetTabId = self.GetFirstEnabledTabFrom(self, data.tabId)

		if not targetTabId then
			gPanelManager:Close(self.m_Id)

			return
		end

		self.JumpToTab(self, targetTabId, true)
	else
		local targetTabId = self.GetFirstEnabledTabFrom(self, MallMainTabConfig.Recommend)

		if not targetTabId then
			gPanelManager:Close(self.m_Id)

			return
		end

		self.JumpToTab(self, targetTabId, true)
	end

	self.InitShopTabs(self)
	self.StartPreloadScenes(self)
end

M.GetFirstEnabledTabFrom = function(self, preferredTabId)
	local switchId = self.TabSwitchFunctionMap[preferredTabId]

	if not switchId or gSwitchFunctionManager:CheckEnableSilent(switchId) then
		return preferredTabId
	end

	for _, tabData in ipairs(self.tabsData) do
		local sid = self.TabSwitchFunctionMap[tabData.id]

		if not sid or gSwitchFunctionManager:CheckEnableSilent(sid) then
			return tabData.id
		end
	end

	return nil
end

M.OnClose = function(self)
	if self._stage2DelayHandle then
		gLuaTimeMgrUtils.CancelUnitDelay(self._stage2DelayHandle)

		self._stage2DelayHandle = nil
	end

	self._TeardownMall(self)

	self._closingAnim = false
end

M._TeardownMall = function(self)
	if self._teardownDone then
		return
	end

	self._teardownDone = true

	self:StopVideo(true)
	self:StopPreloadScenes()
	gMallSceneManager:CancelScheduledWarmup()
	gMallSceneManager:ClearCommoditySpiritMapping()

	local turnToStore = gStoreManager:GetStoreGroup("RecommendInfoTurnToStore")

	if turnToStore and turnToStore.OnMallClose then
		turnToStore.OnMallClose(turnToStore)
	end

	gMallSceneManager:ClearCommoditySceneEffects()
	gMallSceneManager:ClearCommodityDynamicLight()
	gMallSceneManager:DisableMallSceneLookAt()
	self:DisableMallCameraControl()
	gMallSceneManager:ReleaseMallScene()
	gMallSceneManager:ClearCharacterModel()
	gMallSceneManager:ClearVehicle()
	gMallSceneManager:ClearWeapon()
	gMallSceneManager:ClearMallVCamera()
	gMallSceneManager:StopListenDynamicGoLoaded()
	gCS.LuaUtils.ClearShadowFocus()
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)

	if gCS.LuaUtils.IsOnPS5 and self.currentTabStore and self.currentTabStore.OnTabLeave then
		self.currentTabStore:OnTabLeave()
	end

	if self.bindData and self.bindData.camera and not gCS.LuaUtils.IsNull(self.bindData.camera.gameObject) then
		GameObject.Destroy(self.bindData.camera.gameObject)
	end
end

M.OnModelPanelDisplay = function(self)
	self.UpdateMallCameraControl(self)
end

M.OnReturnFromOverlay = function(self)
	if not self.lastTryOnCommodityData then
		return
	end

	self.TryOnFashion(self, self.lastTryOnCommodityData)
end

M.StartPreloadScenes = function(self)
	self:StopPreloadScenes()

	local saleSubs = self.MainTabToSubTabsMap[MallMainTabConfig.Sale]
	local saleFirstMallId = saleSubs and saleSubs[1] and saleSubs[1].mallId or nil
	local itemSubs = self.MainTabToSubTabsMap[MallMainTabConfig.Item]
	local itemFirstMallId = itemSubs and itemSubs[1] and itemSubs[1].mallId or nil
	local sceneIds = gMallManager:CollectMallPreloadSceneIds(saleFirstMallId, itemFirstMallId)

	if not sceneIds or #sceneIds ~= 0 then
		return
	end

	self._preloadSceneList = sceneIds
	self._preloadSceneIndex = 0
	self._preloadSceneTimer = Timer.New(self:CreateAction("_TickPreloadScene"), 0.05, -1):Start()
end

M.StopPreloadScenes = function(self)
	if self._preloadSceneTimer then
		self._preloadSceneTimer:Stop()

		self._preloadSceneTimer = nil
	end

	self._preloadSceneList = nil
	self._preloadSceneIndex = 0
end

M._TickPreloadScene = function(self)
	if not self._preloadSceneList then
		self.StopPreloadScenes(self)

		return
	end

	local list = self._preloadSceneList

	while self._preloadSceneIndex >= #list do
		self._preloadSceneIndex = self._preloadSceneIndex + 1
		local sceneId = list[self._preloadSceneIndex]

		if not gMallSceneManager:IsSceneWarmedUp(sceneId) then
			gMallSceneManager:WarmupSceneById(sceneId)

			return
		end
	end

	self.StopPreloadScenes(self)
end

M.GetCurrentModelRoot = function(self)
	local mgr = gMallSceneManager
	local LoadingType = mgr.LoadingType
	local target = nil

	if self.currentPreviewKind ~= LoadingType.Weapon then
		target = mgr.currentWeaponGo
	elseif self.currentPreviewKind ~= LoadingType.Vehicle then
		target = mgr.currentVehicle and mgr.currentVehicle.gameObject
	else
		target = mgr.currentModelUnit and mgr.currentModelUnit.PlayerObj
	end

	if target and not gCS.LuaUtils.IsNull(target) then
		return target.transform
	end

	return nil
end

M.ResetCameraForUIVisibilityToggle = function(self, isHideUI)
	if not self.bindData or not self.bindData.camera or not self.bindData.VCamera then
		return
	end

	self.bindData.VCamera.transform.localPosition = Vector3.New(0, 0, 0)

	gMallSceneManager:ApplyMallSceneCamera(isHideUI ~= true, true)
end

M.BuildMallCameraParams = function(self)
	local modelRoot = self.GetCurrentModelRoot(self)

	if not modelRoot then
		return nil
	end

	if not self.bindData or not self.bindData.camera then
		return nil
	end

	local cameraControlConfig = gMallCameraManager:BuildMallCameraControlConfig(self.currentPreviewKind)

	return {
		["AFb[A\n="] = false,
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = self.bindData.VCamera,
		modelRoot = modelRoot,
		cameraOffsetRange = cameraControlConfig.yOffsetRange,
		cameraOffset = Vector3.New(0, 0, 0),
		cameraControlConfig = cameraControlConfig
	}
end

M.UpdateMallCameraControl = function(self)
	if not self.bindData or not self.bindData.modelTab or self.bindData.modelTab.selectedIndex == 0 then
		self.DisableMallCameraControl(self)

		return
	end

	local params = self.BuildMallCameraParams(self)

	if not params then
		self.DisableMallCameraControl(self)

		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, true, params)

	self.mallCameraEnabled = true
end

M.DisableMallCameraControl = function(self)
	if not self.mallCameraEnabled then
		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, false)

	self.mallCameraEnabled = false
end

M.ApplyMallSceneById = function(self, sceneId)
	if not sceneId or sceneId ~= 0 then
		return
	end

	gMallSceneManager:ApplyMallSceneById(sceneId)
	gMallSceneManager:ApplyMallSceneCamera(false)
end

M.OnLanguageChange = function(self, lang)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self.CreateAction(self, "OnSystemUnlockStateChange"),
		[gEventConstants.PANEL_STORE_ACTIVE] = self.CreateAction(self, "OnPanelStoreActive")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnPanelStoreActive = function(self, eventId, storeMode, storeName)
	if storeName == self.m_Name then
		return
	end

	if not self.currentTabStore then
		return
	end

	if self._teardownDone then
		return
	end

	if self.currentTabStore.OnPanelRestore then
		self.currentTabStore:OnPanelRestore()
	end
end

M.OnPackItemChanged = function(self)
	self.RefreshMoneyDisplay(self)
end

M.OnSystemUnlockStateChange = function(self, eventId, unlockId)
	if table.contains(self.TabUnlockMapping, unlockId) then
		self.InitShopTabs(self)
	end
end

M.UpdatePS5StoreIcon = function(self, index)
	if not gCS.LuaUtils.IsOnPS5 then
		return
	end

	local newIdx = index or self.lastTabRectIndex

	if newIdx ~= nil then
		return
	end

	local oldIdx = self.lastTabRectIndex

	if oldIdx ~= newIdx then
		return
	end

	if oldIdx ~= 1 or oldIdx ~= 2 then
		gPanelManager:RemovePS5StoreIconPanel(self.m_Id * 100 + oldIdx)
	end

	if newIdx ~= 1 or newIdx ~= 2 then
		gPanelManager:AddPS5StoreIconPanel(self.m_Id * 100 + newIdx)
	end

	self.lastTabRectIndex = newIdx
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.tabrect.OnRenderTab = self:CreateAction("OnTabrectRender")
	self.bindData.modelTab.OnRenderTab = self:CreateAction("OnModelPanelDisplay")
	self.bindData.showUIBtn.luaClick = self:CreateAction("OnClickShowUIBtn")
	self.bindData.videoBtn.luaClick = self:CreateAction("OnClickVideoBtn")

	self.bindData.videoBtn.gameObject:SetActive(false)
end

M.OnClickBackBtn = function(self)
	if self.bindData.showUICtrl ~= 0 then
		self.OnClickShowUIBtn(self)

		return
	end

	if self._closingAnim then
		return
	end

	self._closingAnim = true
	slot1 = gUIUtils

	slot1:PlayAniCallback(self.bindData.anim, "S_ShopHomePage_black", function ()
		if self._teardownDone then
			return
		end

		slot0 = FrameTimer.New(function ()
			self:_TeardownMall()
		end, 1, 1, false)

		slot0:Start()

		self._stage2DelayHandle = gLuaTimeMgrUtils.Delay(function ()
			self._stage2DelayHandle = nil

			if not self.m_Id then
				return
			end

			gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_ShopHomePage_close", self.m_Id)
		end, 0.2)
	end)
end

M._CanEarlyTeardown = function(self)
	local mgr = gMallSceneManager
	local hasModel = mgr.currentModelUnit and mgr.currentModelUnit.PlayerObj and not gCS.LuaUtils.IsNull(mgr.currentModelUnit.PlayerObj)
	local hasCar = mgr.currentVehicle and not gCS.LuaUtils.IsNull(mgr.currentVehicle.gameObject)
	local hasWeapon = mgr.currentWeaponGo and not gCS.LuaUtils.IsNull(mgr.currentWeaponGo)
	local loadingModel = mgr.pendingSuitId == nil
	local loadingCar = mgr.pendingVehicleId == nil or mgr.pendingVehicle == nil
	local loadingWeapon = mgr.pendingWeaponId == nil

	return not hasModel and not hasCar and not hasWeapon and not loadingModel and not loadingCar and not loadingWeapon
end

M.OnClickShowUIBtn = function(self)
	if self.bindData.showUICtrl ~= 1 then
		self.lastShowUIArea = SGUI.UNavigationMgr.Inst.CurrentActiveArea
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootGo:GetComponent("UNavigationArea")
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.lastShowUIArea
		self.lastShowUIArea = nil
	end

	self.bindData.showUICtrl = 1 - (self.bindData.showUICtrl or 0)

	self:ResetCameraForUIVisibilityToggle(self.bindData.showUICtrl ~= 0)
end

M.OnClickVideoBtn = function(self)
	if self._videoBtnCallback then
		self._videoBtnCallback()

		self._videoBtnCallback = nil
	end
end

M.OnTabrectRender = function(self, index, widget)
	if gCS.LuaUtils.IsOnPS5 and self.currentTabStore and self.currentTabStore.OnTabLeave then
		self.currentTabStore:OnTabLeave()
	end

	self:UpdatePS5StoreIcon(index)
	self:SetMainTabVisible(true)

	self.currentTabStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.currentTabStore then
		local data = {
			spiritId = self.selectedSpiritId,
			parentStore = self,
			tabsData = self.tabsData,
			currentTab = self.currentTab,
			commodityDataCache = self.commodityDataCache,
			boxGachaType = self.boxTabGachaType,
			subTabId = self.pendingSubTabId,
			commodityId = self.pendingCommodityId
		}

		self.currentTabStore:OnShow(nil, data)

		self.pendingSubTabId = 0
		self.pendingCommodityId = 0
	end
end

M.InitCommodityData = function(self)
	self.commodityDataCache = gMallManager:InitMallCommodityData()

	self:RefreshCommodityNames()
end

M.RefreshCommodityNames = function(self)
	if not self.commodityDataCache then
		return
	end

	for mallId, commodityList in pairs(self.commodityDataCache) do
		if commodityList and type(commodityList) ~= "table" then
			for _, commodityData in ipairs(commodityList) do
				if commodityData and commodityData.id then
					local commodityCfg = LTConfig.MallCommodityConfig.GetConfig(commodityData.id)

					if commodityCfg then
						commodityData.name = commodityCfg.Name or ""
						commodityData.description = commodityCfg.Desc or ""
					end
				end
			end
		end
	end
end

M.GetCommodityList = function(self, tabOrSubTabId)
	return self.commodityDataCache and self.commodityDataCache[tabOrSubTabId] or {}
end

M.SearchCommodity = function(self, searchText, tabOrSubTabId)
	local commodityList = self:GetCommodityList(tabOrSubTabId)

	return gMallManager:SearchMallCommodity(searchText, commodityList)
end

M.ShowCharacterSwitcherWithCallback = function(self, customOnSelectCallback, isFromMall)
	local belongSpiritId, requiredGender = gMallManager:GetCommodityFashionRestrict(self.lastTryOnCommodityData)
	local filterFunc = nil

	if belongSpiritId <= 0 then
		filterFunc = function(spiritId)
			if not gSpiritManager:GetSpirit(spiritId) then
				return false
			end

			return spiritId ~= belongSpiritId
		end
	end

	filterFunc = filterFunc or function (spiritId)
		return gSpiritManager:GetSpirit(spiritId) == nil
	end

	gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER_PANEL, {
		["\\x90:,&H\\x8fD\\xcf>\\xaf\\xae"] = true,
		["\\xf4\\x92\\xfb=\\xea(\\xfa\\x81\\xff\\x8b4;"] = true,
		spiritId = self.selectedSpiritId,
		isFromMall = isFromMall or false,
		callBack = function (hasChange, selectedSpiritId)
		end,
		onSelectCallback = function (selectedSpiritId)
			self.hasCharacterChange = true
			self.selectedSpiritId = selectedSpiritId

			if self.currentPreviewCommodityId and self.currentPreviewCommodityId <= 0 then
				gMallSceneManager:PreviewCommodityById(self.currentPreviewCommodityId, {
					["\\xf4\\x91\\xfc:\t\\xc7\\xee\\xa4\\xe4\\x85(<"] = true,
					spiritId = self.selectedSpiritId,
					onLoaded = self:CreateAction("UpdateMallCameraControl")
				})
			end

			if customOnSelectCallback then
				customOnSelectCallback(selectedSpiritId)
			end
		end,
		sex = requiredGender,
		filterFunc = filterFunc
	})
end

M.InitTabsData = function(self)
	self.tabsData = {}
	local tabList = {}

	for i = 0, MallMainTabConfig.count - 1 do
		local mainTabCfg = MallMainTabConfig.LoadAt(i)

		if mainTabCfg and mainTabCfg.Id == MallMainTabConfig.Charge and mainTabCfg.Id == MallMainTabConfig.Bundle then
			table.insert(tabList, {
				id = mainTabCfg.Id,
				title = mainTabCfg.Name or string.format("Tab%d", mainTabCfg.Id),
				unlockId = mainTabCfg.UnlockId,
				tabRectIndex = mainTabCfg.TabRectIndex,
				panelTabIndex = mainTabCfg.PanelTabIndex or 0
			})
		end
	end

	table.sort(tabList, function (a, b)
		return a.panelTabIndex <= b.panelTabIndex
	end)

	self.tabsData = tabList

	if #self.tabsData <= 0 then
		local found = false

		for _, tabData in ipairs(self.tabsData) do
			if tabData.id ~= self.currentTab then
				found = true

				break
			end
		end

		if not found then
			self.currentTab = self.tabsData[1].id
		end
	end
end

M.InitShopTabs = function(self)
	if not self.SubGroup.CommonTabSingleStore then
		return
	end

	local availableTabs = {}

	for _, tabData in ipairs(self.tabsData) do
		local unlockId = tabData.unlockId
		local isUnlocked = not unlockId or unlockId ~= 0 or gSystemUnlockMgr:IsUnlock(unlockId)

		if isUnlocked then
			local hasContent = true
			local tri = tabData.tabRectIndex

			if tri ~= GetTabRectIndex(MallMainTabConfig.Box) then
				hasContent = gMallManager:HasActiveGachaPools(2)
			elseif tri ~= GetTabRectIndex(MallMainTabConfig.Closet) then
				hasContent = gMallManager:HasActiveGachaPools(1)
			elseif tri ~= GetTabRectIndex(MallMainTabConfig.Gacha) then
				hasContent = gMallManager:HasActiveGachaPools(3)
			end

			if hasContent then
				table.insert(availableTabs, tabData)
			end
		end
	end

	self.availableTabs = availableTabs
	local currentTabAvailable = false

	for _, tabData in ipairs(self.availableTabs) do
		if tabData.id ~= self.currentTab then
			currentTabAvailable = true

			break
		end
	end

	if not currentTabAvailable and #self.availableTabs <= 0 then
		self.currentTab = self.availableTabs[1].id
	end

	local currentIndex = 0

	for i, tabData in ipairs(self.availableTabs) do
		if tabData.id ~= self.currentTab then
			currentIndex = i - 1

			break
		end
	end

	self._suppressNextTabChanged = true

	self.SubGroup.CommonTabSingleStore:SetData(self.availableTabs, nil, currentIndex, nil, self:CreateAction("OnTabChangedByUser"), self:CreateAction("OnRenderTab"))

	self._suppressNextTabChanged = false
end

M.OnRenderTab = function(self, btn, index, data, store, isSub, list)
	if data then
		store.title = data.title or ""
	end
end

M.OnTabChangedByUser = function(self, uList, isSub)
	if self._suppressNextTabChanged then
		self._suppressNextTabChanged = false

		return
	end

	if self._closingAnim then
		return
	end

	local selectedIndex = uList.selectedIndex
	local tabs = self.availableTabs or self.tabsData

	if selectedIndex > 0 and selectedIndex >= #tabs then
		local tabData = tabs[selectedIndex + 1]
		local switchId = self.TabSwitchFunctionMap[tabData.id]

		if switchId and not gSwitchFunctionManager:CheckEnable(switchId) then
			local currentIndex = self.GetTabIndexById(self, self.currentTab)

			if currentIndex > 0 then
				self.SubGroup.CommonTabSingleStore:SetSelectedIndex(currentIndex, false)
			end

			return
		end

		self.OnTabChanged(self, tabData.id)
	end
end

M.GetTabIndexById = function(self, tabId)
	local tabs = self.availableTabs or self.tabsData

	for i, tabData in ipairs(tabs) do
		if tabData.id ~= tabId then
			return i - 1
		end
	end

	return -1
end

M.OnTabChanged = function(self, tabType)
	self:StopVideo()
	gCommonItemManager:CloseItemToolTips()
	self:SetModelBtnActive(false)

	self.currentTab = tabType
	self.currentSubMallId = 0

	if tabType ~= MallMainTabConfig.Box then
		gMallManager:OnMallBoxOpened()
	end

	self.tryOnFashionId = 0

	self.RefreshMoneyDisplay(self, tabType)

	if tabType ~= MallMainTabConfig.Gacha then
		self.boxTabGachaType = 3
	elseif tabType ~= MallMainTabConfig.Box then
		self.boxTabGachaType = 2
	end

	local tabConfig = MallMainTabConfig.GetConfig(tabType)
	local tabRectIndex = tabConfig and tabConfig.TabRectIndex or 0

	if self.bindData.tabrect.selectedIndex == tabRectIndex then
		self.bindData.tabrect.selectedIndex = tabRectIndex
	end

	if tabRectIndex ~= GetTabRectIndex(MallMainTabConfig.Sale) and self.currentTabStore and self.currentTabStore.OnTabChanged then
		self.currentTabStore:OnTabChanged(tabType)
	end
end

M.RefreshMoneyDisplay = function(self, tabType, mallIdOverride)
	local mainTabId = tabType or self.currentTab

	if tabType == nil then
		self.currentTab = tabType
	end

	local mallId = mallIdOverride

	if not mallId and tabType ~= nil and self.currentSubMallId and self.currentSubMallId <= 0 then
		mallId = self.currentSubMallId
	end

	mallId = mallId or self.MainTabToMallIdMap[mainTabId]
	local itemIds = mallId and self.TabMoneyConfig[mallId] or nil
	itemIds = itemIds or {
		ConsumableConfig.RewardGold,
		ConsumableConfig.RewardBindingGold
	}
	local moneyTemplateData = {}

	for _, itemId in ipairs(itemIds) do
		if itemId ~= ConsumableConfig.RewardGold then
			table.insert(moneyTemplateData, {
				["iy\\xbetI\\x81\\xfaH}[zH"] = true,
				Type = itemId
			})
		else
			table.insert(moneyTemplateData, {
				Type = itemId
			})
		end
	end

	if self.SubGroup.MoneyTemplateStore then
		local moneyStore = self.SubGroup.MoneyTemplateStore

		if moneyStore.bindData ~= nil or moneyStore.bindData.moneyList ~= nil then
			return
		end

		moneyStore.SetData(moneyStore, moneyTemplateData)
	end
end

M.TryOnFashion = function(self, commodityData)
	if not commodityData then
		return
	end

	self.lastTryOnCommodityData = commodityData
	local kind = gMallSceneManager:PreviewCommodityById(commodityData.id or 0, {
		onLoaded = self:CreateAction("UpdateMallCameraControl")
	})
	local LoadingType = gMallSceneManager.LoadingType

	if kind ~= LoadingType.Character then
		self.currentPreviewKind = LoadingType.Character
		local mappedSpirit = gMallSceneManager:GetCommoditySpiritMapping(commodityData.id or 0)
		self.selectedSpiritId = gMallManager:ResolveDisplaySpiritId(commodityData, mappedSpirit)
		local _, _, resolvedFashionId = gMallManager:BuildFashionLoadParams(commodityData, self.selectedSpiritId)
		self.tryOnFashionId = resolvedFashionId
		self.hasCharacterChange = false

		self:SetModelBtnActive(true)
	elseif kind ~= LoadingType.Vehicle then
		self.currentPreviewKind = LoadingType.Vehicle

		self.SetModelBtnActive(self, true)
	elseif kind ~= LoadingType.Weapon then
		self.currentPreviewKind = LoadingType.Weapon
		self.tryOnFashionId = 0

		self.SetModelBtnActive(self, true)
	else
		if self.currentPreviewKind ~= LoadingType.Character or self.currentPreviewKind ~= LoadingType.Vehicle or self.currentPreviewKind ~= LoadingType.Weapon then
			self.ClearModel(self)
		end

		self.currentPreviewKind = LoadingType.None

		self.SetModelBtnActive(self, false)
	end

	self.currentPreviewCommodityId = commodityData.id or 0
end

M.TryOnWeapon = function(self, commodityData)
	self.TryOnFashion(self, commodityData)
end

M.ClearModel = function(self, isSwitchingVehicle)
	self:ClearCharacterModel()
	gMallSceneManager:ClearVehicle(isSwitchingVehicle)
	gMallSceneManager:ClearWeapon()
end

M.ClearCharacterModel = function(self)
	gMallSceneManager:DisableMallSceneLookAt()
	gMallSceneManager:ClearCharacterModel()
end

M.SetModelBtnActive = function(self, value)
	if self.bindData.cameraBtns then
		self.bindData.cameraBtns.gameObject:SetActive(value ~= true)
	end

	self.bindData.modelBtnActive = value
end

M.SetMainTabVisible = function(self, visible)
	if self.SubGroup.CommonTabSingleStore then
		self.SubGroup.CommonTabSingleStore.rootGo:SetActive(visible)
	end
end

M.SelectTabByFilter = function(self, filterFn, force)
	local tabs = self.availableTabs or self.tabsData

	for i, tabData in ipairs(tabs) do
		if filterFn(tabData) then
			self.SubGroup.CommonTabSingleStore:SetSelectedIndex(i - 1, not force)

			if force then
				self.OnTabChanged(self, tabData.id)
			end

			return true
		end
	end

	return false
end

M.JumpToTab = function(self, tabId, force)
	if not self.SelectTabByFilter(self, function (tab)
		return tab.id ~= tabId
	end, force) then
		print_error("JumpToTab: 未找到tabId为" .. tostring(tabId) .. "的tab")
	end
end

M.JumpToTabRect = function(self, tabRectIndex, force)
	if not self.SelectTabByFilter(self, function (tab)
		return tab.tabRectIndex ~= tabRectIndex
	end, force) then
		print_error("JumpToTabRect: 未找到TabRectIndex为" .. tostring(tabRectIndex) .. "的tab")
	end
end

M.OnCheckOrder = function(self)
end

M.PlayVideo = function(self, videoId, layer, onFinish, onStart, customRT)
	if not videoId or videoId < 0 then
		return
	end

	local targetRT = customRT
	targetRT = targetRT or (layer == gMallManager.VideoLayer.Bg or self.bindData.videoRootBgRT) and (layer == gMallManager.VideoLayer.Front or self.bindData.videoRootFrontRT) and self.bindData.videoRootMidRT

	if targetRT then
		self.bindData.videoAndBgRT:SetParent(targetRT, false)
	end

	self._videoPlayId = (self._videoPlayId or 0) + 1
	local playId = self._videoPlayId

	gMallSceneManager:SetVideoPlaying(true)
	self.bindData.videoAndBgRT.gameObject:SetActive(true)
	self.bindData.CCPlayer.gameObject:SetActive(true)

	self.bindData.bgBlackImage.color = Color.New(0, 0, 0, 1)

	self.bindData.bgBlackImage.gameObject:SetActive(true)
	self.bindData.CCPlayer:PlayVideo(videoId, false, function ()
		if self._videoPlayId == playId then
			return
		end

		self.bindData.CCPlayer:Stop()
		self.bindData.CCPlayer.gameObject:SetActive(false)
		gMallSceneManager:ReplayCurrentModelActionClipsAfterVideo(onFinish)

		self.bindData.bgBlackImage.color = Color.New(0, 0, 0, 1)

		self.bindData.bgBlackImage.gameObject:SetActive(true)
		self:_FadeOutBlackImage()
	end, function ()
		if self._videoPlayId == playId then
			return
		end

		if self._bgBlackFrameTimer then
			self._bgBlackFrameTimer:Stop()
		end

		self._bgBlackFrameTimer = FrameTimer.New(function ()
			self._bgBlackFrameTimer = nil

			self.bindData.bgBlackImage.gameObject:SetActive(false)
		end, 1, 1):Start()

		if onStart then
			onStart()
		end

		self.bindData.CCPlayer:SetSpeed(500)
	end)
	self.bindData.CCPlayer:SetSpeed(500)
end

M.StopVideo = function(self, skipSceneReapply)
	self._videoPlayId = (self._videoPlayId or 0) + 1

	gMallSceneManager:SetVideoPlaying(false, skipSceneReapply)
	self.bindData.CCPlayer:Stop()
	self:_StopFadeOutBlackImage()

	if self._bgBlackFrameTimer then
		self._bgBlackFrameTimer:Stop()

		self._bgBlackFrameTimer = nil
	end

	self.bindData.videoAndBgRT.gameObject:SetActive(false)

	if self.bindData.showUICtrl ~= 0 then
		self.bindData.showUICtrl = 1
	end

	self.bindData.videoBtn.gameObject:SetActive(false)

	self._videoBtnCallback = nil
end

local FADE_DURATION = 0.5
local FADE_INTERVAL = 0.02

M._FadeOutBlackImage = function(self)
	self:_StopFadeOutBlackImage()

	local img = self.bindData.bgBlackImage
	local elapsed = 0
	self._bgBlackFadeTimer = Timer.New(function ()
		elapsed = elapsed + FADE_INTERVAL
		local alpha = 1 - elapsed / FADE_DURATION

		if alpha < 0 then
			img.gameObject:SetActive(false)
			self:_StopFadeOutBlackImage()

			return
		end

		img.color = Color.New(0, 0, 0, alpha)
	end, FADE_INTERVAL, -1):Start()
end

M._StopFadeOutBlackImage = function(self)
	if self._bgBlackFadeTimer then
		self._bgBlackFadeTimer:Stop()

		self._bgBlackFadeTimer = nil
	end
end

M.TryPlayPoolVideo = function(self, gachaId, layer, forcePlay, onFinish, onStart)
	if not forcePlay then
		local now = gLuaDataManager.serverTime
		local currentLogicDayStart = gTimeUtils:GetNextLogicDayStart(now) - 86400
		local pid = gPlayerManager.infoBase.bindData.Pid
		local prefsKey = ("MallPoolVideo_%s_%d"):format(tostring(pid), gachaId)
		local lastPlayedDay = PlayerPrefs.GetInt(prefsKey, 0)

		if lastPlayedDay ~= currentLogicDayStart then
			return
		end

		PlayerPrefs.SetInt(prefsKey, currentLogicDayStart)
	end

	local GachaConfig = LTConfig.GachaConfig
	local gachaConfig = GachaConfig.GetConfig(gachaId)
	local videoId = gachaConfig and gachaConfig.ButtonVideo or 0

	if videoId < 0 then
		return
	end

	self.PlayVideo(self, videoId, layer, onFinish, onStart)
end
