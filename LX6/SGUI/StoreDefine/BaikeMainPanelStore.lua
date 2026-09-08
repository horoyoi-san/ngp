-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeMainPanelStore.lua
-- Decompiled from: 01572_BaikeMainPanelStore.lua_5fe6f33e69c8.luajit

C_BaikeMainPanelStore = DefClass("C_BaikeMainPanelStore", C_BaikeMainPanelStore, C_StoreGroup)
GroupName2Class.BaikeMainPanelStore = C_BaikeMainPanelStore
local M = C_BaikeMainPanelStore
local FirstClassTypeType = LTConfig.CityPediaFirstClassConfig.TypeType

M.ctor = function(self)
	self.searchResultListData = {}
end

M.OnAwake = function(self)
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

M.OnGroupEnable = function(self)
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.BAIKE_MAIN_PANEL) and 1 or 0
end

M.InitMessages = function(self)
	local messageEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose"),
		[gEventConstants.ON_BAIKE_ITEM_HAS_READ] = self.CreateAction(self, "RefreshButtonRedDot"),
		[gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE] = self.CreateAction(self, "RefreshCreditInfo")
	}

	self.RegisterMessageEvents(self, messageEvents)
end

M.RefreshPlayerFashionHeadRedDot = function(self)
	local hasRedDot = gBaiKeArchiveManager.CheckPlayFashionPanelHasRedDot()
	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey, true)
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)

	self.inClose = false
end

M.InitModel = function(self, _)
	self.defaultSelectedFisrtClassId = nil
	local count = LTConfig.CityPediaFirstClassConfig.count
	local cityPediaFirstClassList = {}

	for i = 0, count - 1 do
		local cityPeditFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)

		table.insert(cityPediaFirstClassList, cityPeditFirstClassCfg)
	end

	table.sort(cityPediaFirstClassList, function (a, b)
		return a.CategoryNodeIndex <= b.CategoryNodeIndex
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
end

M.InitView = function(self, _)
	local current, total = self:GetTotalProgress()
	self.bindData.current = current
	self.bindData.total = total
	self.bindData.searchNodeActive = false
	self.rootArea = self.rootGo:GetComponent("UNavigationArea")

	self:InitCategoryButton()
	self:InitPlayerFashionHead()
	self:OpenDefaultToolTips()
end

M.InitPlayerFashionHead = function(self)
	local playerFashionHead = self.bindData.playerFashionHead

	if not playerFashionHead then
		return
	end

	self.bindData.playerFashionHead.transform.parent.gameObject:SetActive(false)

	self.playerFashionHead = gStoreManager:GetStoreGroup(playerFashionHead.Store):GetStoreByWidget(playerFashionHead)
	local currentCredit = gBaiKeArchiveManager.GetCityPediaCredit()
	local currentLevel = gBaiKeArchiveManager.GetCityPediaCreditLevel()
	local nextLevelCfg = LTConfig.CityPediaCollectionLevelConfig.GetConfig(currentLevel + 1)
	local nextLevelPoint = nextLevelCfg and nextLevelCfg.value or currentCredit
	self.playerFashionHead.fillPercent = currentCredit / nextLevelPoint
	self.bindData.pointText = tostring(currentCredit)
	self.bindData.totalPointText = tostring(nextLevelPoint)
	local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
	local cfg = LTConfig.ImageNewAvatarConfig.GetConfig(path)
	self.playerFashionHead.headIcon = (cfg or LTConfig.ImageNewAvatarConfig.GetConfig(LTConfig.ImageNewAvatarConfig.AdultMH)).SguiImageId

	self.playerFashionHead.button.luaClick = function()
		self:OnBeforeOpenPlayFashion()
		gPanelManager:CheckShow(gPanelId.PLAY_FASHION_PANEL)
	end

	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()
	self.playerFashionHead.button.redKey = redDotKey

	self:RefreshPlayerFashionHeadRedDot()
end

M.OpenDefaultToolTips = function(self)
	if self.defaultSelectedFisrtClassId then
		local button = self.buttonStoreMap[self.defaultSelectedFisrtClassId].button

		button.OpenTooltip(button, 0)
	end
end

M.GetTotalProgress = function(self)
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

M.InitCategoryButton = function(self)
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
			store.unlockIcon = cityPediaFirstClassCfg.ClassIconID
			store.name = cityPediaFirstClassCfg.Name

			store.pointTemplate.gameObject:SetActive(false)

			local current, total = gBaiKeArchiveManager.GetCityPediaFisrtClassPorgress(cityPediaFirstClassId)
			store.current = current
			store.total = total
			store.button.luaTooltipPopup = self:CreateActionWithArgs("OnToolTipsPopup", cityPediaFirstClassId)
			store.openBtn.luaClick = self:CreateActionWithArgs("OnCategoryButtonClick", cityPediaFirstClassId)
			self.buttonStoreMap[cityPediaFirstClassId] = store
			local redDotKey = gBaiKeArchiveManager.GetCityPediaFirstClassRedDotKey(cityPediaFirstClassId)
			store.button.redKey = redDotKey
			local hasRedDot = gBaiKeArchiveManager.CheckCityPediaFirstClassHasRedDot(cityPediaFirstClassId)

			SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

			store.id = cityPediaFirstClassId

			store.button.luaBlur = function()
				store.button.isSelected = false
			end
		end
	end
end

M.RefreshButtonRedDot = function(self)
	local count = LTConfig.CityPediaFirstClassConfig.count

	for i = 0, count - 1 do
		local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)
		local cityPediaFirstClassId = cityPediaFirstClassCfg.Id
		local redDotKey = gBaiKeArchiveManager.GetCityPediaFirstClassRedDotKey(cityPediaFirstClassId)
		local hasRedDot = gBaiKeArchiveManager.CheckCityPediaFirstClassHasRedDot(cityPediaFirstClassId)

		SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey, true)
	end
end

M.RefreshCreditInfo = function(self)
	if not self.buttonStoreMap then
		return
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

	self.RefreshPlayerFashionHeadRedDot(self)
end

M.OnRenderToolTips = function(self, categoryId, _, popup, _)
	local rootGo = self.rootGo
	slot6 = gStoreManager
	local store = slot6:GetStoreGroup(popup.Store)
	self.tooltipStore = store
	local parentButton = self.buttonStoreMap[categoryId].button

	store:RefreshView(categoryId, parentButton, nil, , , , )

	store.onClickCallback = function()
		if gClientUtils.IsNil(rootGo) then
			return
		end

		self:OpenItemPanel(categoryId)
	end
end

M.OnCategoryButtonClick = function(self, categoryId)
	local button = self.buttonStoreMap[categoryId].button

	if button.IsTooltipOpen(button, 0) and SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		self.OpenItemPanel(self, categoryId)
	end
end

M.OnToolTipsPopup = function(self, categoryId, _, isPopUp, _)
	if isPopUp then
		local button = self.buttonStoreMap[categoryId].button
		local buttonAnimation = button.GetComponent(button, "Animation")

		gCS.LuaUtils.PlayAnimationByName(buttonAnimation, "s_vx_BaikeCategoryTemplate_close")
	else
		local button = self.buttonStoreMap[categoryId].button
		local buttonAnimation = button.GetComponent(button, "Animation")

		gCS.LuaUtils.PlayAnimationByName(buttonAnimation, "s_vx_BaikeCategoryTemplate_open")
	end

	self.tooltipStore = nil
end

M.OnBeforeOpenPlayFashion = function(self)
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

M.OnPanelClose = function(self, _, panelId)
	if panelId ~= gPanelId.PLAY_FASHION_PANEL then
		self.bindData.inputField.interactable = true

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.rootArea.enabled = true
			self.bindData.searchNodeArea.enabled = true
		end

		if self.bindData.searchNodeActive then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.searchNodeArea
		end
	elseif panelId ~= gPanelId.BAIKE_ITEM_PANEL then
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

M.OnExitClick = function(self)
	if self.CheckToolTipsIsOpen(self) then
		return
	end

	if self.bindData.searchNodeActive then
		self.bindData.inputField.text = ""

		return
	end

	self.inClose = true

	gPanelManager:Close(self.m_Id)
end

M.CheckToolTipsIsOpen = function(self)
	for _, buttonStore in pairs(self.buttonStoreMap) do
		if buttonStore.button:IsTooltipOpen(0) then
			return true
		end
	end
end

M.OnInputValueChanged = function(self)
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
	self.searchResultListData = gBaiKeArchiveManager:SearchBaikeItems(searchText)

	self.bindData.searchResultList:SetSimpleList(#self.searchResultListData)
end

M.OnSearchResultRenderItem = function(self, btn, index)
	local data = self.searchResultListData[index + 1]

	if not data or data.tIndex == 0 then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local info = gBaiKeArchiveManager:GetSearchItemDisplayInfo(data)
	store.title = info.title
	store.category = info.category
	store.hasUnlockedControl = info.hasUnlocked and 1 or 0

	store.button.luaClick = function()
		self.lastActiveContent = btn

		self:OpenItemPanel(info.firstClassId, info.itemId, info.brandId, info.type)
	end
end

M.OnGetSearchResultListTIndex = function(self, index)
	local data = self.searchResultListData[index + 1]

	return data and data.tIndex or 0
end

M.OnSearchMaskClick = function(self)
	self.bindData.inputField.text = ""
end

M.OnSearchExitClick = function(self)
	self.bindData.searchNodeActive = false
	self.currentActiveAreaCo = coroutine.start(function ()
		coroutine.step()

		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
	end)
end

M.OpenItemPanel = function(self, firstCategoryId, targetItemId, brandId, itemType)
	local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(firstCategoryId)

	if cityPediaFirstClassCfg.Type ~= FirstClassTypeType.Faction then
		gPanelManager:CheckShow(gPanelId.BAIKE_ITEM_PANEL, {
			targetFirstCategoryId = firstCategoryId,
			targetItemId = targetItemId,
			openFactionDetail = targetItemId == nil
		})
	else
		gPanelManager:CheckShow(gPanelId.BAIKE_ITEM_PANEL, {
			targetFirstCategoryId = firstCategoryId,
			targetItemId = targetItemId
		})
	end
end

M.OnInputFieldActivate = function(self)
	if not self.inClose then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.searchNodeArea
	end

	gMessageManager:SendMessage(gEventConstants.ON_CLOSE_BAIKE_MAIN_POP_UP)
end

M.OnRenderRedDot = function(self, redKey, _, widget)
	if string.starts_with(redKey, "BaiKeCityPediaFisrtClassRedDot") then
		local strCityPediaFirstClassId = redKey:match("^BaiKeCityPediaFisrtClassRedDot:(%d+)$")
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

		if store then
			local cityPediaFirstClassId = tonumber(strCityPediaFirstClassId)
			store.num = gBaiKeArchiveManager.GetCityPediaFisrtClassRedDotCount(cityPediaFirstClassId)
		end
	elseif redKey ~= "BaikePlayFashionPanelRedDot" then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

		if store then
			store.num = gBaiKeArchiveManager.GetPlayFashionPanelRedDotCount()
		end
	end
end

M.OnDestroy = function(self)
	self.jumpTargetCo = coroutine.stop(self.jumpTargetCo)
	self.showMaskCo = coroutine.stop(self.showMaskCo)
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction
	self.switchSearchNodeAreaCo = coroutine.stop(self.switchSearchNodeAreaCo)

	gCS.GuiUtils.SetXuWeiWeatherState(false)

	self.hasDestroy = nil
	self.buttonStoreMap = nil

	self.ClearMessageEvents(self)

	self.autoOpenToolTipsCo = coroutine.stop(self.autoOpenToolTipsCo)
	self.defaultSelectedFisrtClassId = nil
	self.currentActiveAreaCo = coroutine.stop(self.currentActiveAreaCo)
	self.playerFashionHead = nil
end
