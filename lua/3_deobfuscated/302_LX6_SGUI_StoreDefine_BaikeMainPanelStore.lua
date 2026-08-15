C_BaikeMainPanelStore = DefClass("C_BaikeMainPanelStore", C_BaikeMainPanelStore, C_StoreGroup)
GroupName2Class.BaikeMainPanelStore = C_BaikeMainPanelStore
local M = C_BaikeMainPanelStore
M.baikeType = {
	Text = 2,
	Vehicle = 4,
	Item = 0,
	Pets = 1,
	Fashion = 3
}

function M:ctor()
	self.searchResultListData = {}
end

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputValueChanged")
	self.bindData.searchResultList.luaSimpleRenderItem = self:CreateAction("OnSearchResultRenderItem")
	self.bindData.searchResultList.onGetTIndex = self:CreateAction("OnGetSearchResultListTIndex")
	self.bindData.searchMaskButton.luaClick = self:CreateAction("OnSearchMaskClick")
	self.bindData.inputField.onActivateAction = self:CreateAction("OnInputFieldActivate")
	self.bindData.searchExitButton.luaClick = self:CreateAction("OnSearchExitClick")
	self.redDotAction = self:CreateAction("OnRenderRedDot")
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot and SGUI.RedDotMgr.onRenderRedDot + self.redDotAction or self.redDotAction

	self:InitMessages()

	self.hasDestroy = nil
end

function M:OnGroupEnable()
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.BAIKE_MAIN_PANEL) and 1 or 0
end

function M:InitMessages()
	local messageEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose"),
		[gEventConstants.ON_BAIKE_ITEM_HAS_READ] = self:CreateAction("RefreshButtonRedDot"),
		[gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE] = self:CreateAction("RefreshCreditInfo")
	}

	self:RegisterMessageEvents(messageEvents)
end

function M:RefreshPlayerFashionHeadRedDot()
	local hasRedDot = gBaiKeArchiveManager.CheckPlayFashionPanelHasRedDot()
	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey, true)
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)

	self.inClose = false
end

function M:InitModel(_)
	self.defaultSelectedFisrtClassId = nil
	self.fashionFirstClassId = nil
	self.vehicleFirstClassId = nil
	local count = LTConfig.CityPediaFirstClassConfig.count
	local cityPediaFirstClassList = {}

	for i = 0, count - 1 do
		local cityPeditFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)

		table.insert(cityPediaFirstClassList, cityPeditFirstClassCfg)

		if cityPeditFirstClassCfg.Type == self.baikeType.Fashion then
			self.fashionFirstClassId = cityPeditFirstClassCfg.Id
		elseif cityPeditFirstClassCfg.Type == self.baikeType.Vehicle then
			self.vehicleFirstClassId = cityPeditFirstClassCfg.Id
		end
	end

	table.sort(cityPediaFirstClassList, function (a, b)
		return a.CategoryNodeIndex < b.CategoryNodeIndex
	end)

	local firstUnlockedClassId = nil

	for _, cityPeditFirstClassCfg in ipairs(cityPediaFirstClassList) do
		local hasUnlocked = gBaiKeArchiveManager.CheckCityPediaFisrtClassHasUnlocked(cityPeditFirstClassCfg.Id)

		if hasUnlocked then
			firstUnlockedClassId = cityPeditFirstClassCfg.Id

			break
		end
	end

	self.defaultSelectedFisrtClassId = firstUnlockedClassId
	self.creditPointMap = {}
	local fashionCurrentPoint, fashionTotalPoint, fashionCurrentCount, fashionTotalCount = gBaiKeArchiveManager.CalculateTotalOwnedFashionScore()
	self.creditPointMap[self.baikeType.Fashion] = {
		current = fashionCurrentPoint,
		total = fashionTotalPoint,
		currentCount = fashionCurrentCount,
		totalCount = fashionTotalCount
	}
	local vehicleCurrentPoint, vehicleTotalPoint, vehicleCurrentCount, vehicleTotalCount = gBaiKeArchiveManager.CalculateTotalOwnedVehicleScore()
	self.creditPointMap[self.baikeType.Vehicle] = {
		current = vehicleCurrentPoint,
		total = vehicleTotalPoint,
		currentCount = vehicleCurrentCount,
		totalCount = vehicleTotalCount
	}
end

function M:InitView(_)
	local current, total = self:GetTotalProgress()
	self.bindData.current = current
	self.bindData.total = total
	self.bindData.searchNodeActive = false
	self.rootArea = self.rootGo:GetComponent("UNavigationArea")

	self:InitCategoryButton()
	self:InitPlayerFashionHead()
	self:OpenDefaultToolTips()
end

function M:InitPlayerFashionHead()
	local playerFashionHead = self.bindData.playerFashionHead

	if not playerFashionHead then
		return
	end

	self.playerFashionHead = gStoreManager:GetStoreGroup(playerFashionHead.Store):GetStoreByWidget(playerFashionHead)
	local currentCredit = gBaiKeArchiveManager.GetCityPediaCredit()
	local currentLevel = gBaiKeArchiveManager.GetCityPediaCreditLevel()
	local nextLevelCfg = LTConfig.CityPediaCollectionLevelConfig.GetConfig(currentLevel + 1)
	local nextLevelPoint = nextLevelCfg and nextLevelCfg.value or currentCredit
	self.playerFashionHead.fillPercent = currentCredit / nextLevelPoint
	self.bindData.pointText = tostring(currentCredit)
	self.bindData.totalPointText = tostring(nextLevelPoint)
	local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
	local cfg = LTConfig.ImageAvatarConfig.GetConfig(path)
	self.playerFashionHead.headIcon = (cfg or LTConfig.ImageAvatarConfig.GetConfig(LTConfig.ImageAvatarConfig.AdultMH)).SguiImageId

	function self.playerFashionHead.button.luaClick()
		self:OnBeforeOpenPlayFashion()
		gPanelManager:CheckShow(gPanelId.PLAY_FASHION_PANEL)
	end

	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()
	self.playerFashionHead.button.redKey = redDotKey

	self:RefreshPlayerFashionHeadRedDot()
end

function M:OpenDefaultToolTips()
	if self.defaultSelectedFisrtClassId then
		local button = self.buttonStoreMap[self.defaultSelectedFisrtClassId].button

		button:OpenTooltip(0)
	end
end

function M:GetTotalProgress()
	local count = LTConfig.CityPediaFirstClassConfig.count
	local current = 0
	local total = 0

	for i = 0, count - 1 do
		local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)
		local categoryCurrent, categoryTotal = gBaiKeArchiveManager.GetCityPediaFisrtClassPorgress(cityPediaFirstClassCfg.Id)
		current = current + categoryCurrent
		total = total + categoryTotal
	end

	return current, total
end

function M:InitCategoryButton()
	local categoryRoot = self.bindData.categoryRoot.transform
	self.buttonStoreMap = {}
	local count = LTConfig.CityPediaFirstClassConfig.count

	for i = 0, count - 1 do
		local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)
		local cityPediaFirstClassId = cityPediaFirstClassCfg.Id
		local childName = ("Category0%d"):format(cityPediaFirstClassCfg.CategoryNodeIndex)
		local categoryNode = categoryRoot:Find(childName)
		local widget = categoryNode and categoryNode:GetComponent("UWidget")

		if widget then
			local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
			store.button.enabledTooltip = true
			store.button.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", cityPediaFirstClassId)
			local hasUnlocked = gBaiKeArchiveManager.CheckCityPediaFisrtClassHasUnlocked(cityPediaFirstClassId)
			store.button.interactable = hasUnlocked
			store.hasUnlocked = hasUnlocked and 1 or 0
			store.name = cityPediaFirstClassCfg.Name

			store.pointTemplate.gameObject:SetActive(cityPediaFirstClassCfg.Type == self.baikeType.Fashion or cityPediaFirstClassCfg.Type == self.baikeType.Vehicle)

			if self.creditPointMap[cityPediaFirstClassCfg.Type] then
				local pointData = self.creditPointMap[cityPediaFirstClassCfg.Type]
				store.pointText = tostring(pointData.current)
			else
				store.pointText = gBaiKeArchiveManager.GetCityPediaCreditPoint(cityPediaFirstClassCfg.Type)
			end

			local current, total = gBaiKeArchiveManager.GetCityPediaFisrtClassPorgress(cityPediaFirstClassId)
			store.current = current
			store.total = total
			store.button.luaTooltipPopup = self:CreateActionWithArgs("OnToolTipsPopup", cityPediaFirstClassId)
			self.buttonStoreMap[cityPediaFirstClassId] = store
			local redDotKey = gBaiKeArchiveManager.GetCityPediaFirstClassRedDotKey(cityPediaFirstClassId)
			store.button.redKey = redDotKey
			local hasRedDot = gBaiKeArchiveManager.CheckCityPediaFirstClassHasRedDot(cityPediaFirstClassId)

			SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

			store.id = cityPediaFirstClassId

			function store.button.luaBlur()
				store.button.isSelected = false
			end
		end
	end
end

function M:RefreshButtonRedDot()
	local count = LTConfig.CityPediaFirstClassConfig.count

	for i = 0, count - 1 do
		local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)
		local cityPediaFirstClassId = cityPediaFirstClassCfg.Id
		local redDotKey = gBaiKeArchiveManager.GetCityPediaFirstClassRedDotKey(cityPediaFirstClassId)
		local hasRedDot = gBaiKeArchiveManager.CheckCityPediaFirstClassHasRedDot(cityPediaFirstClassId)

		SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey, true)
	end
end

function M:RefreshCreditInfo()
	if not self.buttonStoreMap then
		return
	end

	local fashionCurrentPoint, fashionTotalPoint, fashionCurrentCount, fashionTotalCount = gBaiKeArchiveManager.CalculateTotalOwnedFashionScore()
	self.creditPointMap[self.baikeType.Fashion] = {
		current = fashionCurrentPoint,
		total = fashionTotalPoint,
		currentCount = fashionCurrentCount,
		totalCount = fashionTotalCount
	}
	local vehicleCurrentPoint, vehicleTotalPoint, vehicleCurrentCount, vehicleTotalCount = gBaiKeArchiveManager.CalculateTotalOwnedVehicleScore()
	self.creditPointMap[self.baikeType.Vehicle] = {
		current = vehicleCurrentPoint,
		total = vehicleTotalPoint,
		currentCount = vehicleCurrentCount,
		totalCount = vehicleTotalCount
	}

	for cityPediaFirstClassId, store in pairs(self.buttonStoreMap) do
		local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(cityPediaFirstClassId)

		if cityPediaFirstClassCfg.Type == self.baikeType.Fashion or cityPediaFirstClassCfg.Type == self.baikeType.Vehicle then
			local pointData = self.creditPointMap[cityPediaFirstClassCfg.Type]

			if pointData then
				store.pointText = tostring(pointData.current)
			else
				store.pointText = gBaiKeArchiveManager.GetCityPediaCreditPoint(cityPediaFirstClassCfg.Type)
			end
		end
	end

	if self.playerFashionHead then
		local currentCredit = gBaiKeArchiveManager.GetCityPediaCredit()
		local currentLevel = gBaiKeArchiveManager.GetCityPediaCreditLevel()
		local nextLevelCfg = LTConfig.CityPediaCollectionLevelConfig.GetConfig(currentLevel + 1)
		local nextLevelPoint = nextLevelCfg and nextLevelCfg.value or currentCredit
		self.playerFashionHead.fillPercent = currentCredit / nextLevelPoint
		self.bindData.pointText = tostring(currentCredit)
		self.bindData.totalPointText = tostring(nextLevelPoint)
	end

	self:RefreshPlayerFashionHeadRedDot()
end

function M:OnRenderToolTips(categoryId, _, popup, _)
	local rootGo = self.rootGo
	local store = gStoreManager:GetStoreGroup(popup.Store)
	self.tooltipStore = store
	local parentButton = self.buttonStoreMap[categoryId].button
	local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(categoryId)
	local currentPoint, totalPoint, currentCount, totalCount = nil

	if cityPediaFirstClassCfg and self.creditPointMap[cityPediaFirstClassCfg.Type] then
		local pointData = self.creditPointMap[cityPediaFirstClassCfg.Type]
		currentPoint = pointData.current
		totalPoint = pointData.total
		currentCount = pointData.currentCount
		totalCount = pointData.totalCount
	end

	store:RefreshView(categoryId, parentButton, nil, currentPoint, totalPoint, currentCount, totalCount)

	function store.onClickCallback()
		if gClientUtils.IsNil(rootGo) then
			return
		end

		self:OpenItemPanel(categoryId)
	end
end

function M:OnToolTipsPopup(categoryId, _, isPopUp, _)
	if isPopUp then
		local button = self.buttonStoreMap[categoryId].button
		local buttonAnimation = button:GetComponent("Animation")

		gCS.LuaUtils.PlayAnimationByName(buttonAnimation, "s_vx_BaikeCategoryTemplate_close")
	else
		local button = self.buttonStoreMap[categoryId].button
		local buttonAnimation = button:GetComponent("Animation")

		gCS.LuaUtils.PlayAnimationByName(buttonAnimation, "s_vx_BaikeCategoryTemplate_open")
	end

	self.tooltipStore = nil
end

function M:OnBeforeOpenPlayFashion()
	if self.bindData.inputField then
		self.bindData.inputField.interactable = false
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.rootArea.enabled = false
		self.bindData.searchNodeArea.enabled = false

		for _, buttonStore in pairs(self.buttonStoreMap) do
			if buttonStore.button:IsTooltipOpen(0) then
				buttonStore.button:CloseTooltip(false)
			end
		end
	end
end

function M:OnPanelClose(_, panelId)
	if panelId == gPanelId.PLAY_FASHION_PANEL then
		self.bindData.inputField.interactable = true

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.rootArea.enabled = true
			self.bindData.searchNodeArea.enabled = true
		end

		if self.bindData.searchNodeActive then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.searchNodeArea
		else
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
		end
	elseif panelId == gPanelId.BAIKE_ITEM_PANEL or panelId == gPanelId.BAIKE_CAR_PREVIEW_PANEL or panelId == gPanelId.BAIKE_CLOTHES_PANEL then
		if gClientUtils.NotNil(self.bindData.panelAnimation) then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "s_vx_S_BaikeMainPanel_BackItem")
		end

		self.bindData.maskButton.gameObject:SetActive(true)
		self.bindData.maskButton.gameObject:SetActive(false)

		local rootGo = self.rootGo

		if self.bindData.searchNodeActive then
			self.switchSearchNodeAreaCo = coroutine.stop(self.switchSearchNodeAreaCo)
			self.switchSearchNodeAreaCo = coroutine.start(function ()
				coroutine.step()
				coroutine.step()

				if gClientUtils.NotNil(rootGo) then
					SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.searchNodeArea
				end
			end)
		end
	end
end

function M:OnExitClick()
	if self:CheckToolTipsIsOpen() then
		return
	end

	if self.bindData.searchNodeActive then
		self.bindData.inputField.text = ""

		return
	end

	self.inClose = true

	gPanelManager:Close(self.m_Id)
end

function M:CheckToolTipsIsOpen()
	for _, buttonStore in pairs(self.buttonStoreMap) do
		if buttonStore.button:IsTooltipOpen(0) then
			return true
		end
	end
end

function M:OnInputValueChanged()
	local searchText = self.bindData.inputField.text

	if string.is_null_or_empty(searchText) then
		self.bindData.searchNodeActive = false
		self.currentActiveAreaCo = coroutine.start(function ()
			coroutine.step()

			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
		end)

		return
	end

	self.bindData.searchNodeActive = true
	self.searchResultListData = gBaiKeArchiveManager:SearchBaikeItems(searchText, self.fashionFirstClassId, self.vehicleFirstClassId)

	self.bindData.searchResultList:SetSimpleList(#self.searchResultListData)
end

function M:OnSearchResultRenderItem(btn, index)
	local data = self.searchResultListData[index + 1]

	if not data or data.tIndex ~= 0 then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local info = gBaiKeArchiveManager:GetSearchItemDisplayInfo(data)
	store.title = info.title
	store.category = info.category
	store.hasUnlockedControl = info.hasUnlocked and 1 or 0

	function store.button.luaClick()
		self.lastActiveContent = btn

		self:OpenItemPanel(info.firstClassId, info.itemId, info.brandId, info.type)
	end
end

function M:OnGetSearchResultListTIndex(index)
	local data = self.searchResultListData[index + 1]

	return data and data.tIndex or 0
end

function M:OnSearchMaskClick()
	self.bindData.inputField.text = ""
end

function M:OnSearchExitClick()
	self.bindData.searchNodeActive = false
	self.currentActiveAreaCo = coroutine.start(function ()
		coroutine.step()

		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
	end)
end

function M:OpenItemPanel(firstCategoryId, targetItemId, brandId, itemType)
	local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(firstCategoryId)

	if cityPediaFirstClassCfg.Type == self.baikeType.Fashion then
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
		gPanelManager:CheckShow(gPanelId.BAIKE_CAR_PREVIEW_PANEL, {
			targetFirstCategoryId = firstCategoryId,
			targetItemId = targetItemId
		})
	else
		gPanelManager:CheckShow(gPanelId.BAIKE_ITEM_PANEL, {
			targetFirstCategoryId = firstCategoryId,
			targetItemId = targetItemId
		})
	end
end

function M:OnInputFieldActivate()
	if not self.inClose then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.searchNodeArea
	end

	gMessageManager:SendMessage(gEventConstants.ON_CLOSE_BAIKE_MAIN_POP_UP)
end

function M:OnRenderRedDot(redKey, _, widget)
	if string.starts_with(redKey, "BaiKeCityPediaFisrtClassRedDot") then
		local strCityPediaFirstClassId = redKey:match("^BaiKeCityPediaFisrtClassRedDot:(%d+)$")
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

		if store then
			local cityPediaFirstClassId = tonumber(strCityPediaFirstClassId)
			store.num = gBaiKeArchiveManager.GetCityPediaFisrtClassRedDotCount(cityPediaFirstClassId)
		end
	elseif redKey == "BaikePlayFashionPanelRedDot" then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

		if store then
			store.num = gBaiKeArchiveManager.GetPlayFashionPanelRedDotCount()
		end
	end
end

function M:OnDestroy()
	self.jumpTargetCo = coroutine.stop(self.jumpTargetCo)
	self.showMaskCo = coroutine.stop(self.showMaskCo)
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction
	self.switchSearchNodeAreaCo = coroutine.stop(self.switchSearchNodeAreaCo)

	gCS.GuiUtils.SetXuWeiWeatherState(false)

	self.hasDestroy = nil
	self.buttonStoreMap = nil

	self:ClearMessageEvents()

	self.autoOpenToolTipsCo = coroutine.stop(self.autoOpenToolTipsCo)
	self.defaultSelectedFisrtClassId = nil
	self.currentActiveAreaCo = coroutine.stop(self.currentActiveAreaCo)
	self.playerFashionHead = nil
end
