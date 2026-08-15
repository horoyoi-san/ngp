C_BaikeTopTemplateStore = DefClass("C_BaikeTopTemplateStore", C_BaikeTopTemplateStore, C_StoreGroup)
GroupName2Class.BaikeTopTemplateStore = C_BaikeTopTemplateStore
local M = C_BaikeTopTemplateStore

function M:ctor()
	self.searchResultListData = {}
	self.onSearchItemClick = nil
	self.currentActiveAreaCo = nil
	self.switchSearchNodeAreaCo = nil
	self.switchToRootArea = nil
	self.onBeforeOpenPlayFashion = nil
	self.fashionFirstClassId = nil
	self.vehicleFirstClassId = nil
end

function M:OnAwake()
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputValueChanged")
	self.bindData.inputField.onActivateAction = self:CreateAction("OnInputFieldActivate")
	self.bindData.searchResultList.luaSimpleRenderItem = self:CreateAction("OnSearchResultRenderItem")
	self.bindData.searchResultList.onGetTIndex = self:CreateAction("OnGetSearchResultListTIndex")
	self.bindData.searchMaskButton.luaClick = self:CreateAction("OnSearchMaskClick")
	self.bindData.searchExitButton.luaClick = self:CreateAction("OnSearchExitClick")
	local count = LTConfig.CityPediaFirstClassConfig.count

	for i = 0, count - 1 do
		local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)

		if cityPediaFirstClassCfg.Type == 3 then
			self.fashionFirstClassId = cityPediaFirstClassCfg.Id
		elseif cityPediaFirstClassCfg.Type == 4 then
			self.vehicleFirstClassId = cityPediaFirstClassCfg.Id
		end
	end

	self.redDotAction = self:CreateAction("OnRenderRedDot")
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot and SGUI.RedDotMgr.onRenderRedDot + self.redDotAction or self.redDotAction
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents()
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:RegisterMessageEvents()
	self.msgEvents = {
		[gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE] = self:CreateAction("OnCreditInfoChange"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose")
	}

	for eventId, handler in pairs(self.msgEvents) do
		gMessageManager:AddMessageListener(eventId, handler)
	end
end

function M:ClearMessageEvents()
	if self.msgEvents then
		for eventId, handler in pairs(self.msgEvents) do
			gMessageManager:RemoveMessageListener(eventId, handler)
		end
	end
end

function M:OnCreditInfoChange()
	self:RefreshPlayerFashionHeadRedDot()
end

function M:OnPanelClose(_, panelId)
	if panelId == gPanelId.PLAY_FASHION_PANEL and self.bindData.inputField then
		self.bindData.inputField.interactable = true
	end
end

function M:SetData(data)
	if not data then
		return
	end

	self.onSearchItemClick = data.onSearchItemClick
	self.switchToRootArea = data.switchToRootArea
	self.onBeforeOpenPlayFashion = data.onBeforeOpenPlayFashion
	self.bindData.searchNodeActive = false
end

function M:InitPlayerFashionHead()
	local playerFashionHead = self.bindData.playerFashionHead
	self.playerFashionHead = gStoreManager:GetStoreGroup(playerFashionHead.Store):GetStoreByWidget(playerFashionHead)
	local currentCredit = gBaiKeArchiveManager.GetCityPediaCredit()
	local currentLevel = gBaiKeArchiveManager.GetCityPediaCreditLevel()
	local nextLevelCfg = LTConfig.CityPediaCollectionLevelConfig.GetConfig(currentLevel + 1)
	local nextLevelPoint = nextLevelCfg and nextLevelCfg.value or currentCredit
	self.playerFashionHead.fillPercent = currentCredit / nextLevelPoint
	local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
	local cfg = LTConfig.ImageAvatarConfig.GetConfig(path)
	self.playerFashionHead.headIcon = (cfg or LTConfig.ImageAvatarConfig.GetConfig(LTConfig.ImageAvatarConfig.AdultMH)).SguiImageId

	function self.playerFashionHead.button.luaClick()
		if self.onBeforeOpenPlayFashion then
			if self.bindData.inputField then
				self.bindData.inputField.interactable = false
			end

			self.onBeforeOpenPlayFashion()
		end

		gPanelManager:CheckShow(gPanelId.PLAY_FASHION_PANEL)
	end

	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()
	self.playerFashionHead.button.redKey = redDotKey

	self:RefreshPlayerFashionHeadRedDot()
end

function M:RefreshPlayerFashionHeadRedDot()
	if not self.playerFashionHead then
		return
	end

	local hasRedDot = gBaiKeArchiveManager.CheckPlayFashionPanelHasRedDot()
	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey, true)
end

function M:OnRenderRedDot(redKey, _, widget)
	if redKey == "BaikePlayFashionPanelRedDot" then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

		if store then
			store.num = gBaiKeArchiveManager.GetPlayFashionPanelRedDotCount()
		end
	end
end

function M:OnInputValueChanged()
	local searchText = self.bindData.inputField.text

	if string.is_null_or_empty(searchText) then
		self.bindData.searchNodeActive = false
		self.currentActiveAreaCo = coroutine.start(function ()
			coroutine.step()

			if self.switchToRootArea then
				self.switchToRootArea()
			end
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

		if self.onSearchItemClick then
			self.onSearchItemClick(info.firstClassId, info.itemId, info.brandId, info.type)
		end
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
	if self.bindData.inputField.text == "" then
		self.bindData.searchNodeActive = false
		self.currentActiveAreaCo = coroutine.start(function ()
			coroutine.step()

			if self.switchToRootArea then
				self.switchToRootArea()
			end
		end)

		return
	end

	self.bindData.inputField.text = ""
end

function M:ClearSearchText()
	self.bindData.inputField.text = ""
end

function M:IsSearchActive()
	return self.bindData.searchNodeActive
end

function M:SwitchToSearchNodeArea(rootGo)
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

function M:OnInputFieldActivate()
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.searchNodeArea
end

function M:OnDestroy()
	self.currentActiveAreaCo = coroutine.stop(self.currentActiveAreaCo)
	self.switchSearchNodeAreaCo = coroutine.stop(self.switchSearchNodeAreaCo)

	if self.redDotAction then
		SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction
	end

	self:ClearMessageEvents()
end
