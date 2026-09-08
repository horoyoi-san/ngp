-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeItemPanelStore.lua
-- Decompiled from: 01571_BaikeItemPanelStore.lua_269519f5d6df.luajit

C_BaikeItemPanelStore = DefClass("C_BaikeItemPanelStore", C_BaikeItemPanelStore, C_StoreGroup)
GroupName2Class.BaikeItemPanelStore = C_BaikeItemPanelStore
local M = C_BaikeItemPanelStore
local FirstClassTypeType = LTConfig.CityPediaFirstClassConfig.TypeType
local factionDetail = -1
M.baikeTypeToTabIndex = {
	[FirstClassTypeType.Pets] = 0,
	[FirstClassTypeType.Item] = 1,
	[FirstClassTypeType.Interaction] = 2,
	[FirstClassTypeType.Movie] = 3,
	[FirstClassTypeType.Faction] = 4,
	[factionDetail] = 5,
	[FirstClassTypeType.Fishing] = 6
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")

	self.InitMessages(self)
end

M.InitTopTemplate = function(self)
	self.rootArea = self.rootGo:GetComponent("UNavigationArea")

	self.SubGroup.BaikeTopTemplateStore:SetData({
		onSearchItemClick = self:CreateAction("OnSearchItemClick"),
		switchToRootArea = function ()
			local targetArea = self.rootArea
			local tabRootGo = self.currentRenderStore and self.currentRenderStore.rootGo

			if gClientUtils.NotNil(tabRootGo) then
				targetArea = tabRootGo:GetComponent("UNavigationArea")
			end

			if targetArea then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = targetArea
			end
		end,
		firstClassId = self.targetFirstCategoryId
	})
end

M.InitMessages = function(self)
	local messageEvents = {
		[gEventConstants.ON_BAIKE_TAG_SELECTED] = self.CreateAction(self, "OnTagSelected")
	}

	self.RegisterMessageEvents(self, messageEvents)
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitTopTemplate(self)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.currentRenderStore = nil
	self.targetFirstCategoryId = args and args.targetFirstCategoryId
	self.targetItemId = args and args.targetItemId
	self.petModelWidget = args and args.petModelWidget
	self.petModelWidgetLocalRotation = args and args.petModelWidgetLocalRotation
	self.openFactionDetail = args and args.openFactionDetail

	if self.targetItemId then
		self.currentFactionItemId = self.targetItemId
	end

	self.BuildCategoryIndexMap(self)

	if not self.targetFirstCategoryId then
		self.targetFirstCategoryId = self.firstUnlockedCategoryId
	end
end

M.BuildCategoryIndexMap = function(self)
	self.firstUnlockedCategoryId = nil
	local count = LTConfig.CityPediaFirstClassConfig.count

	for i = 0, count - 1 do
		local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)

		if gBaiKeArchiveManager.CheckCityPediaFisrtClassHasUnlocked(cityPediaFirstClassCfg.Id) then
			self.firstUnlockedCategoryId = cityPediaFirstClassCfg.Id

			break
		end
	end
end

M.InitView = function(self, args)
	if args and args.uCameraRenderImage then
		local renderTexture = args.uCameraRenderImage.targetRawImage.texture
		args.uCameraRenderImage.targetRawImage = self.bindData.uRawImage
		self.bindData.uRawImage.texture = renderTexture

		gCS.LuaUtils.PlayAnimationByName(args.modelSceneAnimation, "S_Vx_Baike3DUI_MainToItem")
	end

	local selectedIndex = self.GetTabIndexByFirstCategoryId(self, self.targetFirstCategoryId)

	if self.openFactionDetail then
		self.openFactionDetail = nil
		selectedIndex = self.baikeTypeToTabIndex[factionDetail]
	end

	if selectedIndex > 0 then
		self.bindData.tabRect:SelectIndexWithClose(selectedIndex)
	end
end

M.GetTabIndexByFirstCategoryId = function(self, targetFirstCategoryId)
	if not targetFirstCategoryId then
		return 0
	end

	local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(targetFirstCategoryId)

	return cityPediaFirstClassCfg and self.baikeTypeToTabIndex[cityPediaFirstClassCfg.Type] or 0
end

M.OnRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.currentRenderStore = store

	store:ShowPanel({
		targetFirstCategoryId = self.targetFirstCategoryId,
		targetItemId = self.targetItemId,
		petModelWidget = self.petModelWidget,
		petModelWidgetLocalRotation = self.petModelWidgetLocalRotation
	})
	self.SubGroup.BaikeTopTemplateStore:RefreshUnlockProgress(self.targetFirstCategoryId)
	self:RefreshCategoryText()

	self.targetItemId = nil
end

M.RefreshCategoryText = function(self)
	local cfg = self.targetFirstCategoryId and LTConfig.CityPediaFirstClassConfig.GetConfig(self.targetFirstCategoryId)
	self.bindData.categoryText = cfg and cfg.Name or ""
end

M.ShowFactionDetail = function(self, cityPediaId)
	self.targetItemId = cityPediaId
	self.currentFactionItemId = cityPediaId
	local index = self.baikeTypeToTabIndex[factionDetail]

	if self.bindData.tabRect.selectedIndex ~= index then
		if self.currentRenderStore and self.currentRenderStore.SelectedTargetItem then
			self.currentRenderStore:SelectedTargetItem(cityPediaId)
		end
	else
		self.bindData.tabRect:SelectIndexWithClose(index)
	end
end

M.IsOnFactionDetailTab = function(self)
	return self.bindData.tabRect.selectedIndex ~= self.baikeTypeToTabIndex[factionDetail]
end

M.OnTagSelected = function(self, _, cityPediaId)
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(cityPediaId)
	local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(cityPediaCfg.Class)
	local targetFirstCategoryId = cityPediaSecondClassCfg.FatherId

	if self.targetFirstCategoryId == targetFirstCategoryId then
		self.targetFirstCategoryId = targetFirstCategoryId
		self.targetItemId = cityPediaId
		local selectedIndex = self.GetTabIndexByFirstCategoryId(self, targetFirstCategoryId)

		if selectedIndex > 0 then
			self.bindData.tabRect:SelectIndexWithClose(selectedIndex)
		end
	else
		self.targetItemId = cityPediaId

		if self.currentRenderStore and self.currentRenderStore.SelectedTargetItem then
			self.currentRenderStore:SelectedTargetItem(cityPediaId)
		end
	end
end

M.OnExitClick = function(self)
	if self.SubGroup.BaikeTopTemplateStore:IsSearchActive() then
		self.SubGroup.BaikeTopTemplateStore:ClearSearchText()

		return
	end

	if self.IsOnFactionDetailTab(self) then
		if self.currentRenderStore and self.currentRenderStore.FlushReadSeenSet then
			self.currentRenderStore:FlushReadSeenSet()
		end

		self.targetItemId = self.currentFactionItemId
		local factionHomeIndex = self.GetTabIndexByFirstCategoryId(self, self.targetFirstCategoryId)

		if factionHomeIndex > 0 then
			self.bindData.tabRect:SelectIndexWithClose(factionHomeIndex)

			return
		end
	end

	gPanelManager:Close(self.m_Id)
end

M.OnSearchItemClick = function(self, firstCategoryId, targetItemId, brandId, itemType)
	local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(firstCategoryId)

	if cityPediaFirstClassCfg.Type ~= FirstClassTypeType.Faction then
		self.SubGroup.BaikeTopTemplateStore:ClearSearchText(true)

		self.targetFirstCategoryId = firstCategoryId

		self:ShowFactionDetail(targetItemId)
	else
		self.SubGroup.BaikeTopTemplateStore:ClearSearchText(true)

		if self.targetFirstCategoryId == firstCategoryId then
			self.targetFirstCategoryId = firstCategoryId
			self.targetItemId = targetItemId
			local selectedIndex = self.GetTabIndexByFirstCategoryId(self, firstCategoryId)

			if selectedIndex > 0 then
				self.bindData.tabRect:SelectIndexWithClose(selectedIndex)
			end
		elseif self.currentRenderStore and self.currentRenderStore.SelectedTargetItem then
			self.currentRenderStore:SelectedTargetItem(targetItemId)
		end
	end
end

M.OnDestroy = function(self)
	self.bindData.uRawImage.texture = nil

	self.ClearMessageEvents(self)
end
