local LayerConstants = LX6.Constants.LayerConstants
local VehicleConfig = LTConfig.VehicleConfig
local DriveUtils = LX6.Drive.DriveUtils

require("LX6/Manager/Baike/BaikeCameraManager")

C_BaikeCarPreviewPanelStore = DefClass("C_BaikeCarPreviewPanelStore", C_BaikeCarPreviewPanelStore, C_StoreGroup)
GroupName2Class.BaikeCarPreviewPanelStore = C_BaikeCarPreviewPanelStore
local M = C_BaikeCarPreviewPanelStore
M.baikeType = {
	Text = 2,
	Vehicle = 4,
	Item = 0,
	Pets = 1,
	Fashion = 3
}
M.HideCtrl = {
	Hide = 1,
	Show = 0
}

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.vehicleTypeToVehicleIds = {}
	self.vehicleTypeList = {}
	self.currentVehicleType = nil
	self.currentVehicleId = nil
	self.fashionInfoStore = nil
	self.SortTypeIdMap = {
		GetTime = 2,
		Quality = 1
	}
	self.SELECT_TYPE = {
		FALSE = 0,
		TRUE = 1
	}
	self.allVehicleListData = {}
	self.currentVehicle = nil
	self.loadedVehicleId = nil
	self.currentCameraTemplateId = nil
	self.inHyperLink = false
	self.rootArea = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:InitVehicleData()
end

function M:InitTopTemplate()
	if self.rootGo then
		self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	end

	self.SubGroup.BaikeTopTemplateStore:SetData({
		onSearchItemClick = self:CreateAction("OnSearchItemClick"),
		switchToRootArea = function ()
			if self.rootArea then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
			end
		end,
		onBeforeOpenPlayFashion = self:CreateAction("OnBeforeOpenPlayFashion")
	})
	self.SubGroup.BaikeTopTemplateStore:InitPlayerFashionHead()
end

function M:OnEnable()
	self.loadedVehicleId = 0

	self:LoadVehicle(self.currentVehicleId)

	if self.subModelStore then
		self.subModelStore:ResetCfg()
	end
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	gCS.GuiUtils.SetXuWeiWeatherState(false)
	self:ClearVehicle()
	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, false)
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.bindData.modelTab.selectedIndex = 0
	gDressManager.SelectType.brand = {}
	self.bindData.hideCtrl = self.HideCtrl.Show

	self:InitTopTemplate()
	self:InitFashionInfoStore()
	self:InitSelectorList()

	if #self.vehicleTypeList == 0 then
		self.bindData.tabList:SetSimpleList(0)

		return
	end

	self.bindData.tabList:SetSimpleList(#self.vehicleTypeList)

	local targetVehicleId = data and data.targetItemId

	if targetVehicleId then
		self:JumpToVehicle(targetVehicleId)
	else
		self:SelectVehicleType(0)
	end

	self.SubGroup.FilterSorterComponentStore:SetFilterMenuState(false)
	self:UpdateTipVisibility()
end

function M:OnClose()
	self.subModelStore = nil

	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, false)
end

function M:PlayOpenAnimation()
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "s_vx_BaikeCarPreviewPanel_open")
end

function M:OnModelPanelDisplay()
	self.subModelStore = gStoreManager:GetStoreGroup("BaikeModelViewerStore")

	if self.subModelStore then
		self.subModelStore:SetSceneLoadCompleteCallback(function ()
			self:PlayOpenAnimation()
		end)
	end

	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(self.currentVehicleId)

	self:LoadVehicle(self.currentVehicleId, vehicleCfg)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	self:UpdateTipVisibility()
end

function M:InitVehicleData()
	self.vehicleTypeToVehicleIds = {}
	local vehicleTypeSet = {}
	local vehicleCount = LTConfig.VehicleConfig.count

	for i = 0, vehicleCount - 1 do
		local vehicleCfg = LTConfig.VehicleConfig.LoadAt(i)
		local vehicleType = vehicleCfg.VehicleType

		if vehicleCfg.ShowInPedia and vehicleType then
			local vehicleTypeCfg = LTConfig.VehicleTypeConfig.GetConfig(vehicleType)

			if vehicleTypeCfg then
				if not self.vehicleTypeToVehicleIds[vehicleType] then
					self.vehicleTypeToVehicleIds[vehicleType] = {}
					vehicleTypeSet[vehicleType] = true
				end

				table.insert(self.vehicleTypeToVehicleIds[vehicleType], vehicleCfg.Id)
			end
		end
	end

	self.vehicleTypeList = {}

	for vehicleType, _ in pairs(vehicleTypeSet) do
		table.insert(self.vehicleTypeList, vehicleType)
	end

	table.sort(self.vehicleTypeList)
end

function M:InitFashionInfoStore()
	self.fashionInfoStore = gStoreManager:GetStoreGroup(self.bindData.baikeFashionInfoTemplate.Store):GetStoreByWidget(self.bindData.baikeFashionInfoTemplate)
end

function M:SelectVehicleType(index)
	if index < 0 or index >= #self.vehicleTypeList then
		return
	end

	local vehicleType = self.vehicleTypeList[index + 1]
	self.currentVehicleType = vehicleType
	local vehicleTypeCfg = LTConfig.VehicleTypeConfig.GetConfig(vehicleType)
	self.bindData.typeName = vehicleTypeCfg.DisplayName

	self.bindData.tabList:SelectItem(index)

	local vehicleIds = self.vehicleTypeToVehicleIds[vehicleType]

	if not vehicleIds or #vehicleIds == 0 then
		self.bindData.itemList:SetSimpleList(0)

		return
	end

	self.allVehicleListData = {}
	local unlockedVehicles = gApplyCarManager.UnlockedVehicles or {}
	local vehicleTimeMap = {}

	if not table.isNilOrEmpty(unlockedVehicles) then
		for i = 1, unlockedVehicles.Count or #unlockedVehicles do
			local vehicleInfo = unlockedVehicles[i]

			if vehicleInfo then
				vehicleTimeMap[vehicleInfo.Id] = vehicleInfo.GainTime or 0
			end
		end
	end

	for _, vehicleId in ipairs(vehicleIds) do
		local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)

		if vehicleCfg then
			local isOwned = gApplyCarManager:CheckPlayerAlreadyHasVehicle(vehicleId)

			table.insert(self.allVehicleListData, {
				vehicleId = vehicleId,
				vehicleCfg = vehicleCfg,
				order = vehicleCfg.Order or 0,
				quality = vehicleCfg.VehicleQuality,
				Brand = vehicleCfg.Brand,
				Source = vehicleCfg.Source or 0,
				GainTime = vehicleTimeMap[vehicleId] or 0,
				isOwned = isOwned,
				isCollect = self.SELECT_TYPE.FALSE
			})
		end
	end

	self.filteredVehicleListData = self:FilterItems(self.allVehicleListData)

	self.bindData.itemList:SetSimpleList(#self.filteredVehicleListData)

	if #self.filteredVehicleListData > 0 then
		self:SelectVehicle(0)
	else
		local brand = gDressManager.SelectType.brand
		local hasFilter = not table.isNilOrEmpty(brand)

		if hasFilter then
			local emptyText = LTConfig.CityPediaConfig.EmptyFilterResultText or ""

			gDisplayMessageMgr:ShowMessageContent(emptyText)
		end
	end
end

function M:SelectVehicle(index, needJump)
	if not self.currentVehicleType then
		return
	end

	if not self.filteredVehicleListData or index < 0 or index >= #self.filteredVehicleListData then
		return
	end

	local vehicleData = self.filteredVehicleListData[index + 1]
	self.currentVehicleId = vehicleData.vehicleId

	self.bindData.itemList:SelectItem(index, true)

	if needJump then
		self.bindData.itemList:SetNavSelectToSelect()
	end

	self:UpdateVehicleInfo(vehicleData.vehicleId)
end

function M:UpdateVehicleInfo(vehicleId)
	if not self.fashionInfoStore or not vehicleId then
		return
	end

	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)

	if not vehicleCfg then
		return
	end

	self.fashionInfoStore.nameText = vehicleCfg.VehicleName or ""
	self.fashionInfoStore.desText = vehicleCfg.VehicleIntro or ""
	local brandId = vehicleCfg.Brand

	if brandId and brandId > 0 then
		local shopBrandCfg = LTConfig.ShopBrandConfig.GetConfig(brandId)

		if shopBrandCfg then
			self.fashionInfoStore.logoIconId = shopBrandCfg.BrandLogo or 0
		end
	end

	local score = gBaiKeArchiveManager.CalculateVehicleScore(vehicleCfg.Id)
	self.fashionInfoStore.pointText = tostring(score)
	self.fashionInfoStore.pointActive = score > 0
	local hyperLinkId = vehicleCfg.HypeLinkID
	local isOwned = gApplyCarManager:CheckPlayerAlreadyHasVehicle(vehicleId)

	if isOwned then
		self.bindData.sourceBtn.gameObject:SetActive(false)
	else
		self.bindData.sourceBtn.gameObject:SetActive(true)

		if hyperLinkId == 0 then
			self.bindData.sourceText = LTConfig.CityPediaConfig.EmptyAcquisitionHintText or ""
			self.currentHyperLinkCallback = nil
			self.bindData.sourceBtn.interactable = false
			self.fashionInfoStore.ctrlerGetActive = false
		else
			local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

			if hyperLinkInfo then
				self.bindData.sourceText = hyperLinkInfo.text or ""
				self.currentHyperLinkCallback = hyperLinkInfo.callback
				local linkCfg = LTConfig.HyperLinkConfig.GetConfig(hyperLinkId)
				local incomeId = linkCfg and linkCfg.IncomeId or 0
				self.bindData.sourceBtn.interactable = incomeId ~= 0
				self.fashionInfoStore.ctrlerGetActive = incomeId ~= 0
			else
				self.bindData.sourceText = LTConfig.CityPediaConfig.EmptyAcquisitionHintText or ""
				self.currentHyperLinkCallback = nil
				self.bindData.sourceBtn.interactable = false
				self.fashionInfoStore.ctrlerGetActive = false
			end
		end
	end

	self:LoadVehicle(vehicleId, vehicleCfg)
end

function M:UpdateCameraParams(vehicleCfg)
	if not vehicleCfg then
		return
	end

	local cameraTemplateId = vehicleCfg.PediaCameraTemplate or 0

	if cameraTemplateId == 0 and vehicleCfg.VehicleType then
		local typeCfg = LTConfig.VehicleTypeConfig.GetConfig(vehicleCfg.VehicleType)
		cameraTemplateId = typeCfg and typeCfg.PediaCameraTemplate or 0
	end

	if cameraTemplateId == 0 or self.currentCameraTemplateId == cameraTemplateId then
		return
	end

	self.currentCameraTemplateId = cameraTemplateId
	local cameraCfg = LTConfig.VehicleCameraTemplateConfig.GetConfig(cameraTemplateId)

	if not cameraCfg then
		return
	end

	if not self.subModelStore then
		return
	end

	local modelSlot = self.subModelStore:GetModelSlot()
	local camera = self.subModelStore:GetCamera()
	local params = {
		banRotate = false,
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = camera,
		modelRoot = modelSlot,
		cameraType = gBaikeCameraManager.CameraType.Vehicle,
		cameraOffsetRange = cameraCfg.PediaCameraOffset or {
			20,
			50
		}
	}
	local parm = cameraCfg.PediaCameraParm

	if parm then
		params.cameraOffset = Vector3.New(parm.offsetx or 0, parm.offsety or 0, parm.offsetz or 0)
		params.cameraEuler = Vector3.New(parm.eulerx or 0, parm.eulery or 0, parm.eulerz or 0)
		params.fov = parm.fov ~= 0 and parm.fov or nil
	end

	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, true, params)
end

function M:UpdateTipVisibility()
	local isGamepad = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()

	if isGamepad then
		self.bindData.tipVisibility = 1
	else
		local isHide = self.bindData.hideCtrl == self.HideCtrl.Hide

		if isHide then
			self.bindData.tipVisibility = 0
		else
			self.bindData.tipVisibility = 1
		end
	end
end

function M:LoadVehicle(vehicleId, vehicleCfg)
	if not vehicleId or vehicleId == 0 then
		self:ClearVehicle()

		return
	end

	if self.loadedVehicleId == vehicleId then
		return
	end

	local cfg = vehicleCfg or VehicleConfig.GetConfig(vehicleId)

	if not cfg then
		return
	end

	self:ClearVehicle()

	self.loadedVehicleId = vehicleId

	if self.subModelStore then
		self.subModelStore:LoadVehicleModel(vehicleId, function (vehicle)
			self.currentVehicle = vehicle

			if vehicleCfg then
				self:UpdateCameraParams(vehicleCfg)
			end
		end)
	end
end

function M:ClearVehicle()
	if self.subModelStore then
		self.subModelStore:ClearVehicle()
	end

	self.currentVehicle = nil
	self.loadedVehicleId = nil
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose"),
		[gEventConstants.AFTER_SWITCH_SCENE] = self:CreateAction("OnAfterSwitchScene")
	}
end

function M:OnPanelClose(_, panelId)
	if panelId == gPanelId.BAIKE_ITEM_PANEL or panelId == gPanelId.BAIKE_CLOTHES_PANEL then
		self.SubGroup.BaikeTopTemplateStore:SwitchToSearchNodeArea(self.rootGo)
	elseif panelId == gPanelId.PLAY_FASHION_PANEL then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.rootArea.enabled = true
			self.SubGroup.FilterSorterComponentStore.bindData.navigationArea.enabled = true
		end

		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
	end

	if self.inHyperLink then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "s_vx_BaikeCarPreviewPanel_back")

		self.inHyperLink = false
	end
end

function M:OnAfterSwitchScene(eventId, switchType)
	if switchType == gSwitchSceneType.Reconnect then
		if self.subModelStore and self.subModelStore.scenePrefab then
			self:PlayOpenAnimation()
		elseif self.subModelStore then
			self.subModelStore:SetSceneLoadCompleteCallback(function ()
				self:PlayOpenAnimation()
			end)
		end
	end
end

function M:OnBeforeOpenPlayFashion()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.rootArea.enabled = false
		self.SubGroup.FilterSorterComponentStore.bindData.navigationArea.enabled = false
	end
end

function M:RegisterWidget()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.hideBtn.luaClick = self:CreateAction("OnClickHideBtn")
	self.bindData.sourceBtn.luaClick = self:CreateAction("OnClickSourceBtn")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTabListItem")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderItemListItem")
	self.bindData.tabList.luaSimpleClick = self:CreateAction("OnSimpleClickTabList")
	self.bindData.itemList.luaSimpleClick = self:CreateAction("OnSimpleClickItemList")
	self.bindData.tabUpBtn.luaClick = self:CreateActionWithArgs("OnClickTabNavBtn", -1)
	self.bindData.tabDownBtn.luaClick = self:CreateActionWithArgs("OnClickTabNavBtn", 1)
	self.bindData.modelTab.OnRenderTab = self:CreateAction("OnModelPanelDisplay")
end

function M:OnSimpleRenderTabListItem(btn, index)
	local vehicleType = self.vehicleTypeList[index + 1]

	if not vehicleType then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local vehicleTypeCfg = LTConfig.VehicleTypeConfig.GetConfig(vehicleType)

	if store and vehicleTypeCfg then
		store.icon = vehicleTypeCfg.Icon or 0
		store.name = vehicleTypeCfg.DisplayName
	end
end

function M:OnSimpleClickTabList(btn, index)
	local vehicleType = self.vehicleTypeList[index + 1]

	if vehicleType == self.currentVehicleType then
		return
	end

	self:SelectVehicleType(index)
	self.bindData.itemList:GoToPos(Vector2.zero, true)
end

function M:OnSimpleRenderItemListItem(btn, index)
	if not self.currentVehicleType then
		return
	end

	if not self.filteredVehicleListData then
		return
	end

	local vehicleData = self.filteredVehicleListData[index + 1]

	if not vehicleData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local vehicleCfg = vehicleData.vehicleCfg

	if store and vehicleCfg then
		store.iconId = vehicleCfg.SVehicleIconId or 0
		local brandId = vehicleCfg.Brand

		if brandId and brandId > 0 then
			local brandConfig = LTConfig.ShopBrandConfig.GetConfig(brandId)
			store.brandId = brandConfig and brandConfig.VehicleSmallLogo or 0
		end

		store.quality = vehicleCfg.VehicleQuality or 1
		local hasOwned = gApplyCarManager:CheckPlayerAlreadyHasVehicle(vehicleCfg.Id)
		store.state = hasOwned and 1 or 2
		store.nameText = vehicleCfg.VehicleName
	end
end

function M:OnSimpleClickItemList(btn, index)
	self:SelectVehicle(index)
end

function M:OnClickTabNavBtn(direction)
	if not self.currentVehicleType or #self.vehicleTypeList == 0 then
		return
	end

	local currentIndex = -1

	for i, vehicleType in ipairs(self.vehicleTypeList) do
		if vehicleType == self.currentVehicleType then
			currentIndex = i - 1

			break
		end
	end

	if currentIndex < 0 then
		return
	end

	local targetIndex = currentIndex + direction

	if targetIndex < 0 or targetIndex >= #self.vehicleTypeList then
		return
	end

	self:SelectVehicleType(targetIndex)
	self.bindData.itemList:GoToPos(Vector2.zero, true)
	self.bindData.tabList:SetNavSelectToSelect(false)
end

function M:InitSelectorList()
	self.selectorList = {
		{
			title = 560,
			id = self.SortTypeIdMap.GetTime
		},
		{
			title = 553,
			id = self.SortTypeIdMap.Quality
		}
	}

	self.SubGroup.FilterSorterComponentStore:SetData({
		isAscending = false,
		onSortChanged = self:CreateAction("OnSortChanged"),
		sortList = self.selectorList,
		onFilterBtnClick = self:CreateAction("OnFilterBtnClick")
	})
	self.SubGroup.FilterSorterComponentStore:SelectOption(0, true)
end

function M:OnSortChanged(sortId, isAscending)
	if self.currentVehicleType then
		local currentIndex = -1

		for i, vehicleType in ipairs(self.vehicleTypeList) do
			if vehicleType == self.currentVehicleType then
				currentIndex = i - 1

				break
			end
		end

		if currentIndex >= 0 then
			self:SelectVehicleType(currentIndex)
			self.bindData.itemList:GoToPos(Vector2.zero, true)
		end
	end
end

function M:OnFilterBtnClick(showState)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.rootArea.enabled = false
	end

	gPanelManager:CheckShow(gPanelId.CAR_FILTER_PANEL, {
		callBack = self:CreateAction("OnFilterClose")
	})
end

function M:OnFilterClose()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.rootArea.enabled = true
	end

	if self.currentVehicleType then
		local currentIndex = -1

		for i, vehicleType in ipairs(self.vehicleTypeList) do
			if vehicleType == self.currentVehicleType then
				currentIndex = i - 1

				break
			end
		end

		if currentIndex >= 0 then
			self:SelectVehicleType(currentIndex)
			self.bindData.itemList:GoToPos(Vector2.zero, true)
		end
	end

	local brand = gDressManager.SelectType.brand
	local hasFilter = not table.isNilOrEmpty(brand)

	self.SubGroup.FilterSorterComponentStore:SetFilterMenuState(hasFilter)

	if self.currentVehicleType and self.filteredVehicleListData and #self.filteredVehicleListData == 0 and hasFilter then
		local emptyText = LTConfig.CityPediaConfig.EmptyFilterResultText or ""

		gDisplayMessageMgr:ShowMessageContent(emptyText)
	end
end

function M:FilterItems(itemList)
	local items = {}

	if table.isNilOrEmpty(itemList) then
		return items
	end

	local brand = gDressManager.SelectType.brand

	if table.isNilOrEmpty(brand) then
		if not table.isNilOrEmpty(itemList) then
			self:SortItemList(itemList)
		end

		return itemList
	end

	for i = 1, #itemList do
		local item = itemList[i]

		if table.contains(brand, item.Brand) then
			table.insert(items, item)
		end
	end

	if not table.isNilOrEmpty(items) then
		self:SortItemList(items)
	end

	return items
end

function M:SortItemList(itemList)
	if table.isNilOrEmpty(itemList) then
		return
	end

	local selectedSortItem = self.SubGroup.FilterSorterComponentStore:GetSelectedItem()
	local isAscending = self.SubGroup.FilterSorterComponentStore.isAscending
	local sortTypeId = selectedSortItem and selectedSortItem.id or self.SortTypeIdMap.Quality

	table.sort(itemList, function (a, b)
		if sortTypeId == self.SortTypeIdMap.Quality then
			if a.isOwned ~= b.isOwned then
				return a.isOwned
			end

			if a.quality ~= b.quality then
				if isAscending then
					return a.quality < b.quality
				else
					return b.quality < a.quality
				end
			end

			if a.isOwned and b.isOwned and a.GainTime ~= b.GainTime then
				return b.GainTime < a.GainTime
			end
		end

		if sortTypeId == self.SortTypeIdMap.GetTime then
			if a.isOwned ~= b.isOwned then
				return a.isOwned
			end

			if a.isOwned and b.isOwned and a.GainTime ~= b.GainTime then
				if isAscending then
					return a.GainTime < b.GainTime
				else
					return b.GainTime < a.GainTime
				end
			end

			if a.quality ~= b.quality then
				return b.quality < a.quality
			end
		end

		if a.order ~= b.order then
			if isAscending then
				return a.order < b.order
			else
				return b.order < a.order
			end
		end

		return false
	end)
end

function M:JumpToVehicle(targetVehicleId)
	if not targetVehicleId then
		self:SelectVehicleType(0)

		return
	end

	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(targetVehicleId)

	if not vehicleCfg or not vehicleCfg.VehicleType then
		self:SelectVehicleType(0)

		return
	end

	gDressManager.SelectType.brand = {}
	local targetVehicleType = vehicleCfg.VehicleType
	local vehicleTypeIndex = -1

	for i, vehicleType in ipairs(self.vehicleTypeList) do
		if vehicleType == targetVehicleType then
			vehicleTypeIndex = i - 1

			break
		end
	end

	if vehicleTypeIndex < 0 then
		self:SelectVehicleType(0)

		return
	end

	self:SelectVehicleType(vehicleTypeIndex)

	for i, vehicleData in ipairs(self.filteredVehicleListData) do
		if vehicleData.vehicleId == targetVehicleId then
			self:SelectVehicle(i - 1, true)

			return
		end
	end
end

function M:OnExitClick()
	if self.SubGroup.BaikeTopTemplateStore:IsSearchActive() then
		self.SubGroup.BaikeTopTemplateStore:ClearSearchText()

		return
	end

	gDressManager.SelectType.brand = {}

	self.SubGroup.FilterSorterComponentStore:SetFilterMenuState(false)
	gPanelManager:Close(gPanelId.BAIKE_CAR_PREVIEW_PANEL)
end

function M:OnClickHideBtn()
	self.bindData.hideCtrl = 1 - self.bindData.hideCtrl
	local isHide = self.bindData.hideCtrl == self.HideCtrl.Hide

	if self.rootArea then
		self.rootArea:ChangeButtonNameByActionId(10, isHide and 126 or 104)
	end

	self.bindData.backBtnActive = not isHide

	self:UpdateTipVisibility()
end

function M:OnClickSourceBtn()
	if self.currentHyperLinkCallback then
		self.inHyperLink = true

		self.currentHyperLinkCallback()
	end
end

function M:OnSearchItemClick(firstCategoryId, targetItemId, brandId, itemType)
	local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(firstCategoryId)

	if cityPediaFirstClassCfg.Type == self.baikeType.Fashion then
		gPanelManager:Close(gPanelId.BAIKE_CAR_PREVIEW_PANEL)

		if itemType == "Brand" then
			gPanelManager:CheckShow(gPanelId.BAIKE_CLOTHES_PANEL, {
				targetFirstCategoryId = firstCategoryId,
				targetBrandId = brandId
			})
		elseif itemType == "Suit" then
			gPanelManager:CheckShow(gPanelId.BAIKE_CLOTHES_PANEL, {
				targetFirstCategoryId = firstCategoryId,
				targetSuitId = targetItemId,
				targetBrandId = brandId
			})
		else
			gPanelManager:CheckShow(gPanelId.BAIKE_CLOTHES_PANEL, {
				targetFirstCategoryId = firstCategoryId,
				targetItemId = targetItemId
			})
		end
	elseif cityPediaFirstClassCfg.Type == self.baikeType.Vehicle then
		self.SubGroup.BaikeTopTemplateStore:ClearSearchText()
		self:JumpToVehicle(targetItemId)
	else
		gPanelManager:Close(gPanelId.BAIKE_CAR_PREVIEW_PANEL)
		gPanelManager:CheckShow(gPanelId.BAIKE_ITEM_PANEL, {
			targetFirstCategoryId = firstCategoryId,
			targetItemId = targetItemId
		})
	end
end

function M:InitBaikeCamera()
	local modelSlot = self.subModelStore:GetModelSlot()
	local camera = self.subModelStore:GetCamera()
	local cameraParams = {
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = camera,
		modelRoot = modelSlot,
		cameraOffsetRange = {
			20,
			50
		},
		banRotate = false,
		cameraType = gBaikeCameraManager.CameraType.Vehicle
	}

	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, true, cameraParams)
end
