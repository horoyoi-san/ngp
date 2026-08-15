C_BaikeItemPanelStore = DefClass("C_BaikeItemPanelStore", C_BaikeItemPanelStore, C_StoreGroup)
GroupName2Class.BaikeItemPanelStore = C_BaikeItemPanelStore
local M = C_BaikeItemPanelStore
M.baikeType = {
	Text = 2,
	Vehicle = 4,
	Item = 0,
	Pets = 1,
	Fashion = 3
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")

	self:InitMessages()
end

function M:InitTopTemplate()
	self.rootArea = self.rootGo:GetComponent("UNavigationArea")

	self.SubGroup.BaikeTopTemplateStore:SetData({
		onSearchItemClick = self:CreateAction("OnSearchItemClick"),
		switchToRootArea = function ()
			if self.rootArea then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
			end
		end
	})
	self.SubGroup.BaikeTopTemplateStore:InitPlayerFashionHead()
end

function M:InitMessages()
	local messageEvents = {
		[gEventConstants.ON_BAIKE_TAG_SELECTED] = self:CreateAction("OnTagSelected"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose")
	}

	self:RegisterMessageEvents(messageEvents)
end

function M:OnPanelClose(_, panelId)
	if panelId == gPanelId.BAIKE_CLOTHES_PANEL or panelId == gPanelId.BAIKE_CAR_PREVIEW_PANEL then
		self.SubGroup.BaikeTopTemplateStore:SwitchToSearchNodeArea(self.rootGo)
	end
end

function M:OnShow(_, args)
	self:InitTopTemplate()
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.currentRenderStore = nil
	self.targetFirstCategoryId = args and args.targetFirstCategoryId
	self.targetItemId = args and args.targetItemId
	self.petModelWidget = args and args.petModelWidget
	self.petModelWidgetLocalRotation = args and args.petModelWidgetLocalRotation

	self:BuildCategoryIndexMap()

	if not self.targetFirstCategoryId and #self.unlockedCategories > 0 then
		self.targetFirstCategoryId = self.unlockedCategories[1]
	end
end

function M:BuildCategoryIndexMap()
	self.categoryIdToIndex = {}
	self.unlockedCategories = {}
	local count = LTConfig.CityPediaFirstClassConfig.count
	local index = 1

	for i = 0, count - 1 do
		local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)
		local hasUnlocked = gBaiKeArchiveManager.CheckCityPediaFisrtClassHasUnlocked(cityPediaFirstClassCfg.Id)

		if hasUnlocked then
			self.categoryIdToIndex[cityPediaFirstClassCfg.Id] = index

			table.insert(self.unlockedCategories, cityPediaFirstClassCfg.Id)

			index = index + 1
		end
	end
end

function M:InitView(args)
	if args and args.uCameraRenderImage then
		local renderTexture = args.uCameraRenderImage.targetRawImage.texture
		args.uCameraRenderImage.targetRawImage = self.bindData.uRawImage
		self.bindData.uRawImage.texture = renderTexture

		gCS.LuaUtils.PlayAnimationByName(args.modelSceneAnimation, "S_Vx_Baike3DUI_MainToItem")
	end

	local selectedIndex = self:GetTabIndexByFirstCategoryId(self.targetFirstCategoryId)

	if selectedIndex >= 0 then
		self.bindData.tabRect:SelectIndexWithClose(selectedIndex)
	end
end

function M:GetTabIndexByFirstCategoryId(targetFirstCategoryId)
	if not targetFirstCategoryId then
		return 0
	end

	return self.categoryIdToIndex[targetFirstCategoryId] or 0
end

function M:OnRenderTab(_, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.currentRenderStore = store

	store:ShowPanel({
		targetFirstCategoryId = self.targetFirstCategoryId,
		targetItemId = self.targetItemId,
		petModelWidget = self.petModelWidget,
		petModelWidgetLocalRotation = self.petModelWidgetLocalRotation
	})

	self.targetItemId = nil
end

function M:OnTagSelected(_, cityPediaId)
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(cityPediaId)
	local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaCfg.Class)
	local targetFirstCategoryId = cityPediaSecondClassCfg.FatherId

	if self.targetFirstCategoryId ~= targetFirstCategoryId then
		self.targetFirstCategoryId = targetFirstCategoryId
		self.targetItemId = cityPediaId
		local selectedIndex = self:GetTabIndexByFirstCategoryId(targetFirstCategoryId)

		if selectedIndex >= 0 then
			self.bindData.tabRect:SelectIndexWithClose(selectedIndex)
		end
	else
		self.targetItemId = cityPediaId

		if self.currentRenderStore and self.currentRenderStore.SelectedTargetItem then
			self.currentRenderStore:SelectedTargetItem(cityPediaId)
		end
	end
end

function M:OnExitClick()
	if self.SubGroup.BaikeTopTemplateStore:IsSearchActive() then
		self.SubGroup.BaikeTopTemplateStore:ClearSearchText()

		return
	end

	gPanelManager:Close(self.m_Id)
end

function M:OnSearchItemClick(firstCategoryId, targetItemId, brandId, itemType)
	local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(firstCategoryId)

	if cityPediaFirstClassCfg.Type == self.baikeType.Fashion then
		gPanelManager:Close(gPanelId.BAIKE_ITEM_PANEL)

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
		gPanelManager:Close(gPanelId.BAIKE_ITEM_PANEL)
		gPanelManager:CheckShow(gPanelId.BAIKE_CAR_PREVIEW_PANEL, {
			targetFirstCategoryId = firstCategoryId,
			targetItemId = targetItemId
		})
	elseif self.currentRenderStore and self.currentRenderStore.SelectedTargetItem then
		self.SubGroup.BaikeTopTemplateStore:ClearSearchText()
		self.currentRenderStore:SelectedTargetItem(targetItemId)
	end
end

function M:OnDestroy()
	self.bindData.uRawImage.texture = nil

	self:ClearMessageEvents()
end
