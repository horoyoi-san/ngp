local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionConfig = LTConfig.FashionConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
C_BaikeClothesPanelStore = DefClass("C_BaikeClothesPanelStore", C_BaikeClothesPanelStore, C_StoreGroup)
GroupName2Class.BaikeClothesPanelStore = C_BaikeClothesPanelStore
local M = C_BaikeClothesPanelStore
M.pageCtrl = {
	BrandInfo = 2,
	Single = 1,
	BrandList = 0
}
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

function M:DefineAllVariables()
	self.currentBrandId = nil
	self.partToFashions = {}
	self.singleTabListData = {}
	self.singleListData = {}
	self.currentPartType = nil
	self.tagList = {}
	self.brandIndexMap = {}
	self.SortTypeIdMap = {
		GetTime = 2,
		Quality = 1
	}
	self.SELECT_TYPE = {
		FALSE = 0,
		TRUE = 1
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:InitFashionData()
end

function M:InitTopTemplate()
	if self.rootGo then
		self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	end

	self.SubGroup.BaikeTopTemplateStore:SetData({
		onSearchItemClick = self:CreateAction("OnSearchItemClick"),
		switchToRootArea = function ()
			if self.bindData.pageCtrl == self.pageCtrl.Single then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.singleArea
			elseif self.bindData.pageCtrl == self.pageCtrl.BrandList then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
			elseif self.bindData.pageCtrl == self.pageCtrl.BrandInfo then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.brandInfoArea
			end
		end,
		onBeforeOpenPlayFashion = self:CreateAction("OnBeforeOpenPlayFashion")
	})
	self.SubGroup.BaikeTopTemplateStore:InitPlayerFashionHead()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	gDressManager.SelectType.approach = {}
	gDressManager.SelectType.brand = {}
	gDressManager.SelectType.tag = {}
	self.currentPageCtrl = self.pageCtrl.BrandList
	self.suitListData = {}
	local secondCfg = LTConfig.CityPediaSecondClassConfig
	self.tabListData = {
		{
			name = secondCfg.GetConfig(12140400).Name,
			pageCtrl = self.pageCtrl.BrandList
		},
		{
			name = secondCfg.GetConfig(12140401).Name,
			pageCtrl = self.pageCtrl.Single
		}
	}

	self:InitTopTemplate()
	self:InitSelectorList()
	self.bindData.typeList:SetSimpleList(#self.tabListData)
	gBaiKeArchiveManager:UpdateBrandOwnedCount()

	local targetBrandId = data and data.targetBrandId
	local targetSuitId = data and data.targetSuitId
	local targetFashionId = data and data.targetItemId
	local brandListData = gBaiKeArchiveManager:GetBrandListData()

	self.bindData.brandLoopList:SetList(brandListData)

	if not targetSuitId then
		self.bindData.brandLoopList:SelectItem(0)
		self.bindData.brandLoopList:GoToIndex(0, true)
	end

	self.currentBrandId = brandListData[1].brandId

	if targetSuitId then
		self:JumpToSuit(targetBrandId, targetSuitId)
	elseif targetBrandId then
		self:JumpToBrand(targetBrandId)
	elseif targetFashionId then
		self:JumpToFashion(targetFashionId)
	else
		self:SwitchToPage(self.pageCtrl.BrandList)
	end

	self.SubGroup.FilterSorterComponentStore:SetFilterMenuState(false)
end

function M:OnClose()
	return
end

function M:JumpToBrand(targetBrandId)
	if not targetBrandId then
		self:SwitchToPage(self.pageCtrl.BrandList)

		return
	end

	if not self:GoToBrand(targetBrandId, false) then
		self:SwitchToPage(self.pageCtrl.BrandList)

		return
	end

	self.currentBrandId = targetBrandId

	self:UpdateBrandInfoPage()
	self:SwitchToPage(self.pageCtrl.BrandInfo)
end

function M:JumpToSuit(targetBrandId, targetSuitId)
	if not targetSuitId then
		self:SwitchToPage(self.pageCtrl.BrandList)

		return
	end

	targetBrandId = targetBrandId or FashionSuitConfig.GetConfig(targetSuitId).Brand
	self.currentBrandId = targetBrandId

	self:UpdateBrandInfoPage()
	self:SwitchToPage(self.pageCtrl.BrandInfo)

	local currentSpiritId = gBattleSpiritMgr.currentSpiritTemplateId

	gPanelManager:CheckShow(gPanelId.BAIKE_FASHION_PREVIEW_PANEL, {
		brandId = targetBrandId,
		suitId = targetSuitId,
		suitListData = self.suitListData,
		spiritId = currentSpiritId
	})
end

function M:JumpToFashion(targetFashionId)
	if not targetFashionId then
		self:SwitchToPage(self.pageCtrl.BrandList)

		return
	end

	local fashionCfg = LTConfig.FashionConfig.GetConfig(targetFashionId)

	if not fashionCfg then
		self:SwitchToPage(self.pageCtrl.BrandList)

		return
	end

	self:SwitchToPage(self.pageCtrl.Single)
	self:InitFashionData()

	local targetPartType = fashionCfg.Part

	if targetPartType then
		self:SwitchToSinglePart(targetPartType)

		for i, tabData in ipairs(self.singleTabListData) do
			if tabData.partType == targetPartType then
				self.bindData.singleTabList:SelectItem(i - 1, true)

				break
			end
		end

		FrameTimer.New(function ()
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.singleList:GetComponent(typeof(SGUI.UNavigationArea))
			local filteredList = self.singleListData

			for i, fashionData in ipairs(filteredList) do
				if fashionData.fashionId == targetFashionId then
					self.bindData.singleList:SelectItem(i - 1)
					self.bindData.singleList:SetNavSelectToSelect(false)

					return
				end
			end
		end, 1, 1):Start()
	end
end

function M:GoToBrand(brandId, instant)
	if not brandId then
		return false
	end

	local brandListData = gBaiKeArchiveManager:GetBrandListData()

	for i, brandData in ipairs(brandListData) do
		if brandData.brandId == brandId then
			self.bindData.brandLoopList:GoToIndex(i - 1, instant)

			return true
		end
	end

	return false
end

function M:InitFashionData()
	self.partToFashions = {}
	local partSet = {}
	local fashionCount = FashionConfig.count

	for i = 0, fashionCount - 1 do
		local fashionCfg = FashionConfig.LoadAt(i)

		if fashionCfg and fashionCfg.ShowInPedia and fashionCfg.BelongBrand and fashionCfg.BelongBrand > 0 and fashionCfg.Part then
			local partType = fashionCfg.Part

			if not self.partToFashions[partType] then
				self.partToFashions[partType] = {
					ownedCount = 0,
					totalCount = 0,
					fashions = {}
				}
				partSet[partType] = true
			end

			table.insert(self.partToFashions[partType].fashions, fashionCfg.Id)

			self.partToFashions[partType].totalCount = self.partToFashions[partType].totalCount + 1

			if gDressManager:IsFashionHaved(fashionCfg.Id) then
				self.partToFashions[partType].ownedCount = self.partToFashions[partType].ownedCount + 1
			end
		end
	end

	local FashionChangeTabIcon = FashionConfig.FashionChangeTabIcon
	local partToIconId = {}

	for i = 1, #FashionChangeTabIcon do
		local iconData = FashionChangeTabIcon[i]

		if iconData then
			partToIconId[iconData.part] = iconData.IconId
		end
	end

	self.singleTabListData = {}

	for partType, _ in pairs(partSet) do
		table.insert(self.singleTabListData, {
			partType = partType,
			iconId = partToIconId[partType] or 0
		})
	end

	table.sort(self.singleTabListData, function (a, b)
		return a.partType < b.partType
	end)
end

function M:InitSingleTabList()
	if #self.singleTabListData > 0 then
		self.bindData.singleTabList:SetSimpleList(#self.singleTabListData)

		if not self.currentPartType and #self.singleTabListData > 0 then
			self:SwitchToSinglePart(self.singleTabListData[1].partType)
		end
	end
end

function M:SwitchToSinglePart(partType)
	self.currentPartType = partType
	local partData = self.partToFashions[partType]

	if not partData then
		return
	end

	self.bindData.singleUnlockNum = partData.ownedCount
	self.bindData.singleAllNum = partData.totalCount
	local allSingleListData = {}
	local playerFashionInfoDict = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.PlayerFashionsInfo and gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict or {}

	for _, fashionId in ipairs(partData.fashions) do
		local fashionCfg = FashionConfig.GetConfig(fashionId)

		if fashionCfg then
			local isOwned = gDressManager:IsFashionHaved(fashionId)
			local fashionInfo = playerFashionInfoDict[fashionId]
			local gainTime = 0

			if isOwned and fashionInfo and fashionInfo.GainTime then
				gainTime = fashionInfo.GainTime
			end

			local score = gBaiKeArchiveManager.CalculateFashionScore(fashionId)

			table.insert(allSingleListData, {
				tIndex = 0,
				fashionId = fashionId,
				fashionCfg = fashionCfg,
				isOwned = isOwned,
				order = fashionCfg.Order or 0,
				score = score,
				quality = fashionCfg.Quality,
				Part = fashionCfg.Part,
				BelongBrand = fashionCfg.BelongBrand,
				Tags = fashionCfg.Tags,
				Source = fashionCfg.Source,
				GainTime = gainTime
			})
		end
	end

	self.singleListData = self:FilterItems(allSingleListData)
	local maxNum = self.bindData.singleList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.singleListData / maxNum.x), maxNum.y)
	local totalCount = maxNum.x * col

	self.bindData.singleList:SetSimpleList(totalCount)
	self.bindData.singleTabList:SetSimpleList(#self.singleTabListData)

	if #self.singleListData > 0 then
		self.bindData.singleList:SelectItem(0, true)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.singleList:DeselectAll(true)
		end
	else
		local tag = gDressManager.SelectType.tag
		local approach = gDressManager.SelectType.approach
		local brand = gDressManager.SelectType.brand
		local hasFilter = not table.isNilOrEmpty(approach) or not table.isNilOrEmpty(brand) or not table.isNilOrEmpty(tag)

		if hasFilter then
			local emptyText = LTConfig.CityPediaConfig.EmptyFilterResultText or ""

			gDisplayMessageMgr:ShowMessageContent(emptyText)
		end
	end
end

function M:SwitchToPage(pageCtrl)
	self.currentPageCtrl = pageCtrl
	self.bindData.pageCtrl = pageCtrl

	self.bindData.typeList:SelectItem(pageCtrl, true)

	if pageCtrl == self.pageCtrl.Single then
		gDressManager.SelectType.approach = {}
		gDressManager.SelectType.brand = {}
		gDressManager.SelectType.tag = {}

		self.SubGroup.FilterSorterComponentStore:SetFilterMenuState(false)
		self:InitSingleTabList()

		if self.currentPartType then
			self:SwitchToSinglePart(self.currentPartType)
		end
	elseif pageCtrl == self.pageCtrl.BrandList then
		self:OnBrandSelectedChanged()
	end
end

function M:UpdateBrandInfoPage()
	local brandListData = gBaiKeArchiveManager:GetBrandListData()
	local brandData = nil

	for _, data in ipairs(brandListData) do
		if data.brandId == self.currentBrandId then
			brandData = data

			break
		end
	end

	if not brandData then
		return
	end

	local brandCfg = brandData.brandCfg

	if not brandCfg then
		return
	end

	self.bindData.brandLogoIconId = brandCfg.BrandLogo or 0
	self.bindData.brandNameText = brandCfg.BrandName or ""
	self.bindData.brandInfoText = brandCfg.BrandDes or ""
	local ownedScore, totalScore = gBaiKeArchiveManager.CalculateBrandOwnedFashionScore(self.currentBrandId)
	self.bindData.brandPointText = tostring(ownedScore)
	self.bindData.brandPointActive = totalScore > 0
	self.bindData.brandUnlockNum = brandData.ownedCount
	self.bindData.brandAllNum = brandData.totalCount
	local brandIdToSuits = gBaiKeArchiveManager:GetBrandIdToSuits()
	local suitIds = brandIdToSuits[self.currentBrandId] or {}
	local suitListData = {}

	for _, suitId in ipairs(suitIds) do
		local suitCfg = FashionSuitConfig.GetConfig(suitId)

		if suitCfg then
			local isOwned, ownedCount, totalCount = gBaiKeArchiveManager:CheckSuitOwned(suitCfg)
			local suitScore = 0

			for _, fashionId in ipairs(suitCfg.FashionIdList) do
				local score = gBaiKeArchiveManager.CalculateFashionScore(fashionId)
				suitScore = suitScore + score
			end

			table.insert(suitListData, {
				suitId = suitId,
				suitCfg = suitCfg,
				ownedCount = ownedCount,
				totalCount = totalCount,
				isOwned = isOwned,
				score = suitScore
			})
		end
	end

	self.suitListData = suitListData

	self.bindData.suitList:SetSimpleList(#suitListData)
	self.bindData.suitList:SelectItem(0, true)
end

function M:SetNavigationAreaEnabled(enabled, includeFilterArea)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local pageCtrl = self.bindData.pageCtrl or self.currentPageCtrl

	if pageCtrl == self.pageCtrl.Single then
		self.bindData.singleArea.enabled = enabled
	elseif pageCtrl == self.pageCtrl.BrandList then
		self.rootArea.enabled = enabled
	elseif pageCtrl == self.pageCtrl.BrandInfo then
		self.bindData.brandInfoArea.enabled = enabled
	end

	if includeFilterArea then
		self.SubGroup.FilterSorterComponentStore.bindData.navigationArea.enabled = enabled
	end
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose")
	}
end

function M:OnPanelClose(_, panelId)
	if panelId == gPanelId.BAIKE_ITEM_PANEL or panelId == gPanelId.BAIKE_CAR_PREVIEW_PANEL then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
	elseif panelId == gPanelId.BAIKE_FASHION_PREVIEW_PANEL then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.brandInfoArea
	elseif panelId == gPanelId.PLAY_FASHION_PANEL then
		self:SetNavigationAreaEnabled(true, true)

		if self.bindData.pageCtrl == self.pageCtrl.Single then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.singleArea
		elseif self.bindData.pageCtrl == self.pageCtrl.BrandList then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
		elseif self.bindData.pageCtrl == self.pageCtrl.BrandInfo then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.brandInfoArea
		end
	end
end

function M:OnBeforeOpenPlayFashion()
	self:SetNavigationAreaEnabled(false, true)
end

function M:RegisterWidget()
	self.bindData.brandLoopList.luaRenderItem = self:CreateAction("OnRenderBrandItem")
	self.bindData.brandLoopList.luaSelectedChanged = self:CreateAction("OnBrandSelectedChanged")
	self.bindData.brandLoopList.luaClick = self:CreateAction("OnClickBrand")
	self.bindData.typeList.luaSimpleRenderItem = self:CreateAction("OnRenderTypeItem")
	self.bindData.typeList.luaSimpleClick = self:CreateAction("OnClickTypeItem")
	self.bindData.suitList.luaSimpleRenderItem = self:CreateAction("OnRenderSuitItem")
	self.bindData.suitList.luaSimpleClick = self:CreateAction("OnClickSuitItem")
	self.bindData.singleTabList.luaSimpleRenderItem = self:CreateAction("OnRenderSingleTabItem")
	self.bindData.singleTabList.luaSimpleClick = self:CreateAction("OnClickSingleTabItem")
	self.bindData.singleList.luaSimpleRenderItem = self:CreateAction("OnRenderSingleItem")
	self.bindData.singleList.luaSelectedChanged = self:CreateAction("OnSingleListSelectedChanged")
	self.bindData.singleList.luaSimpleClick = self:CreateAction("OnClickSingleItem")
	self.bindData.singleList.onGetTIndex = self:CreateAction("OnGetSingleListTIndex")
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction("OnRenderTagList")
	self.bindData.exitButton.luaClick = self:CreateAction("OnClickExitButton")
	self.bindData.singleBackBtn.luaClick = self:CreateAction("OnClickExitButton")
	self.bindData.changePageBtn.luaClick = self:CreateAction("OnClickChangePageBtn")
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnClickTabNavBtn", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnClickTabNavBtn", 1)
	self.bindData.leftBrandBtn.luaClick = self:CreateActionWithArgs("OnClickBrandNavBtn", -1)
	self.bindData.rightBrandBtn.luaClick = self:CreateActionWithArgs("OnClickBrandNavBtn", 1)

	if self.bindData.brandBtnL then
		self.bindData.brandBtnL.luaClick = self:CreateActionWithArgs("OnClickBrandNavBtn", -1)
	end

	if self.bindData.brandBtnR then
		self.bindData.brandBtnR.luaClick = self:CreateActionWithArgs("OnClickBrandNavBtn", 1)
	end

	self.bindData.singleBtn.luaClick = self:CreateAction("OnClickSingleBtn")
	self.bindData.singleTabUpBtn.luaClick = self:CreateActionWithArgs("OnClickSingleTabNavBtn", -1)
	self.bindData.singleTabDownBtn.luaClick = self:CreateActionWithArgs("OnClickSingleTabNavBtn", 1)
end

function M:OnRenderBrandItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.brandIconId = data.brandIcon
	store.bigBrandIconId = data.bigLogo
	store.brandNameText = data.brandCfg.BrandName
	store.brandDesText = data.brandCfg.BrandBrief or ""
	store.numberText = data.brandIndex or string.format("%02d", index)
	self.brandIndexMap[index] = data
	local collectionStore = gStoreManager:GetStoreGroup(store.collection.Store):GetStoreByWidget(store.collection)
	collectionStore.mineNum = data.ownedCount
	collectionStore.totalNum = data.totalCount
	collectionStore.percentValue = data.ownedCount / data.totalCount

	if data.ownedCount ~= data.totalCount then
		collectionStore.typeCtrl = 0
	else
		collectionStore.typeCtrl = 2
	end

	collectionStore = gStoreManager:GetStoreGroup(store.collection2.Store):GetStoreByWidget(store.collection2)
	collectionStore.mineNum = data.ownedCount
	collectionStore.totalNum = data.totalCount
	collectionStore.percentValue = data.ownedCount / data.totalCount

	if data.ownedCount ~= data.totalCount then
		collectionStore.typeCtrl = 0
	else
		collectionStore.typeCtrl = 2
	end

	FrameTimer.New(function ()
		store.anim:Play("s_vx_FashionBrandBigTemplate_open")
	end, 1, 1):Start()
end

function M:OnBrandSelectedChanged(list)
	self.lastFrameCount = Time.frameCount
	local selectedIndex = self.bindData.brandLoopList.selectedIndex
	local brandData = self.brandIndexMap[selectedIndex]

	if brandData then
		self.bindData.brandIndexText = brandData.brandIndex
	end
end

function M:OnClickBrand(btn, data)
	if data and self.lastFrameCount ~= Time.frameCount then
		self.currentBrandId = data.brandId

		self:UpdateBrandInfoPage()
		self:SwitchToPage(self.pageCtrl.BrandInfo)
	end
end

function M:OnRenderTypeItem(btn, index)
	local data = self.tabListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.name = data.name
	end

	btn.isSelected = self.currentPageCtrl == data.pageCtrl
end

function M:OnClickTypeItem(btn, index)
	local data = self.tabListData[index + 1]

	if not data then
		return
	end

	self:SwitchToPage(data.pageCtrl)
end

function M:OnRenderSuitItem(btn, index)
	local data = self.suitListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.suitIcon = data.suitCfg.Icon
		local brandCfg = ShopBrandConfig.GetConfig(self.currentBrandId)

		if brandCfg and brandCfg.SuitBG then
			store.brandBgIconId = brandCfg.SuitBG
		end

		local collectionStore = gStoreManager:GetStoreGroup(store.collectionTemplate.Store):GetStoreByWidget(store.collectionTemplate)
		collectionStore.mineNum = data.ownedCount
		collectionStore.totalNum = data.totalCount
		collectionStore.percentValue = data.ownedCount / data.totalCount

		if data.ownedCount ~= data.totalCount then
			collectionStore.typeCtrl = 0
		else
			collectionStore.typeCtrl = 1
		end
	end
end

function M:OnClickSuitItem(btn, index)
	local data = self.suitListData[index + 1]

	if not data then
		return
	end

	local currentSpiritId = gBattleSpiritMgr.currentSpiritTemplateId

	gPanelManager:CheckShow(gPanelId.BAIKE_FASHION_PREVIEW_PANEL, {
		brandId = self.currentBrandId,
		suitId = data.suitId,
		suitListData = self.suitListData,
		spiritId = currentSpiritId
	})
end

function M:OnRenderSingleTabItem(btn, index)
	local data = self.singleTabListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.icon = data.iconId
	end

	btn.isSelected = self.currentPartType == data.partType
end

function M:OnClickSingleTabItem(btn, index)
	local data = self.singleTabListData[index + 1]

	if not data then
		return
	end

	if data.partType == self.currentPartType then
		return
	end

	self:SwitchToSinglePart(data.partType)
	self.bindData.singleList:GoToPos(Vector2.zero, true)
end

function M:OnRenderSingleItem(btn, index)
	local data = self.singleListData[index + 1]

	if not data or data.tIndex == 1 then
		btn.interactable = false

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local fashionCfg = data.fashionCfg
		store.icon = fashionCfg.Icon
		store.quality = fashionCfg.Quality
		store.isAvailable = 1
		store.dyeType = 0
		store.isCollect = 0
		store.isShowTask = 0
		store.taskIcon = 0
		store.nameText = fashionCfg.Name
		store.lockCtrl = data.isOwned and 1 or 0
	end

	btn.interactable = true
end

function M:OnSingleListSelectedChanged(list)
	local selectedIndex = list.selectedIndex

	if selectedIndex >= 0 and selectedIndex < #self.singleListData then
		local data = self.singleListData[selectedIndex + 1]

		if data then
			self:UpdateSingleItemDetail(data)
		end
	end
end

function M:OnGetSingleListTIndex(index)
	local luaIndex = index + 1

	if luaIndex <= #self.singleListData then
		return self.singleListData[luaIndex].tIndex or 0
	else
		return 1
	end
end

function M:OnClickSingleItem(btn, index)
	return
end

function M:UpdateSingleItemDetail(data)
	if not data or not data.fashionCfg then
		return
	end

	local brandConfig = LTConfig.ShopBrandConfig.GetConfig(data.fashionCfg.BelongBrand)
	self.bindData.singleIconId = brandConfig.BrandBanner
	self.bindData.nameText = data.fashionCfg.Name
	self.bindData.desText = data.fashionCfg.Description
	self.bindData.pointText = data.score
	self.bindData.pointActive = data.score and data.score > 0 or false

	self:SetFashionTagInfo(data.fashionId)

	local hyperLinkId = data.fashionCfg.HypeLinkID
	local isOwned = data.isOwned

	if isOwned then
		self.bindData.singleBtn.gameObject:SetActive(false)
	else
		self.bindData.singleBtn.gameObject:SetActive(true)

		if hyperLinkId == 0 then
			self.bindData.singleBtnText = LTConfig.CityPediaConfig.EmptyAcquisitionHintText or ""
			self.currentHyperLinkCallback = nil
			self.bindData.singleBtn.interactable = false
			self.bindData.singleGetActive = false
		else
			local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

			if hyperLinkInfo then
				self.bindData.singleBtnText = hyperLinkInfo.text or ""
				self.currentHyperLinkCallback = hyperLinkInfo.callback
				local linkCfg = LTConfig.HyperLinkConfig.GetConfig(hyperLinkId)
				local incomeId = linkCfg and linkCfg.IncomeId or 0
				self.bindData.singleBtn.interactable = incomeId ~= 0
				self.bindData.singleGetActive = incomeId ~= 0
			else
				self.bindData.singleBtnText = LTConfig.CityPediaConfig.EmptyAcquisitionHintText or ""
				self.currentHyperLinkCallback = nil
				self.bindData.singleBtn.interactable = false
				self.bindData.singleGetActive = false
			end
		end
	end
end

function M:SetFashionTagInfo(fashionId)
	self.tagList = gDressManager:GetTagList(fashionId)

	self.bindData.tagList:SetSimpleList(#self.tagList)
end

function M:OnRenderTagList(btn, index)
	local data = self.tagList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("DressTagTemplateStore"):GetStoreByWidget(btn)

	if store then
		local color = Color.New(data.color[1] / 255, data.color[2] / 255, data.color[3] / 255, data.color[4] / 255)
		store.title = data.title
		store.color = color
	end
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
	if self.currentPageCtrl == self.pageCtrl.Single and self.currentPartType then
		self:SwitchToSinglePart(self.currentPartType)
		self.bindData.singleList:GoToPos(Vector2.zero, true)
	end
end

function M:OnFilterBtnClick(showState)
	self:SetNavigationAreaEnabled(false, false)
	gPanelManager:CheckShow(gPanelId.S_DRESS_FILTER_PANEL, {
		hideCollectList = true,
		callBack = self:CreateAction("OnFilterClose")
	})
end

function M:OnFilterClose()
	self:SetNavigationAreaEnabled(true, false)

	if self.currentPageCtrl == self.pageCtrl.Single and self.currentPartType then
		self:SwitchToSinglePart(self.currentPartType)
		self.bindData.singleList:GoToPos(Vector2.zero, true)
	end

	local tag = gDressManager.SelectType.tag
	local approach = gDressManager.SelectType.approach
	local brand = gDressManager.SelectType.brand
	local hasFilter = not table.isNilOrEmpty(approach) or not table.isNilOrEmpty(brand) or not table.isNilOrEmpty(tag)

	self.SubGroup.FilterSorterComponentStore:SetFilterMenuState(hasFilter)

	if self.currentPageCtrl == self.pageCtrl.Single and self.singleListData and #self.singleListData == 0 and hasFilter then
		local emptyText = LTConfig.CityPediaConfig.EmptyFilterResultText or ""

		gDisplayMessageMgr:ShowMessageContent(emptyText)
	end

	if self.bindData.pageCtrl == self.pageCtrl.Single then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.singleArea
	elseif self.bindData.pageCtrl == self.pageCtrl.BrandList or self.bindData.pageCtrl == self.pageCtrl.BrandInfo then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
	end
end

function M:FilterItems(itemList)
	local items = {}

	if table.isNilOrEmpty(itemList) then
		return items
	end

	local tag = gDressManager.SelectType.tag
	local approach = gDressManager.SelectType.approach
	local brand = gDressManager.SelectType.brand

	if table.isNilOrEmpty(approach) and table.isNilOrEmpty(brand) and table.isNilOrEmpty(tag) then
		if not table.isNilOrEmpty(itemList) then
			self:SortItemList(itemList)
		end

		return itemList
	end

	local hasApproach = not table.isNilOrEmpty(approach) or false
	local hasBrand = not table.isNilOrEmpty(brand) or false
	local hasTag = not table.isNilOrEmpty(tag) or false

	for i = 1, #itemList do
		local canAdd = true
		local item = itemList[i]

		if hasTag then
			local canAddTag = false

			if item.Tags then
				for j = 1, #tag do
					if table.contains(item.Tags, tag[j]) then
						canAddTag = true

						break
					end
				end
			end

			if not canAddTag then
				canAdd = false
			end
		end

		if hasApproach and not table.contains(approach, item.Source) then
			canAdd = false
		end

		if hasBrand and not table.contains(brand, item.BelongBrand) then
			canAdd = false
		end

		if canAdd then
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

function M:OnClickExitButton()
	if self.SubGroup.BaikeTopTemplateStore:IsSearchActive() then
		self.SubGroup.BaikeTopTemplateStore:ClearSearchText()

		return
	end

	if self.currentPageCtrl == self.pageCtrl.BrandInfo then
		if self.currentBrandId then
			self:GoToBrand(self.currentBrandId, false)
		end

		self:SwitchToPage(self.pageCtrl.BrandList)

		return
	end

	gDressManager.SelectType.approach = {}
	gDressManager.SelectType.brand = {}
	gDressManager.SelectType.tag = {}

	self.SubGroup.FilterSorterComponentStore:SetFilterMenuState(false)
	gPanelManager:Close(gPanelId.BAIKE_CLOTHES_PANEL)
end

function M:OnClickChangePageBtn()
	if self.currentBrandId then
		local brandListData = gBaiKeArchiveManager:GetBrandListData()

		for i, brandData in ipairs(brandListData) do
			if brandData.brandId == self.currentBrandId then
				self.bindData.brandLoopList:GoToIndex(i - 1, false)

				break
			end
		end
	end

	self:SwitchToPage(self.pageCtrl.BrandList)
end

function M:OnClickTabNavBtn(direction)
	local currentIndex = -1

	for i, data in ipairs(self.tabListData) do
		if data.pageCtrl == self.currentPageCtrl then
			currentIndex = i

			break
		end
	end

	if currentIndex <= 0 then
		return
	end

	local targetIndex = currentIndex + direction

	if targetIndex < 1 then
		targetIndex = #self.tabListData
	elseif targetIndex > #self.tabListData then
		targetIndex = 1
	end

	local targetData = self.tabListData[targetIndex]

	if targetData then
		self:SwitchToPage(targetData.pageCtrl)
	end
end

function M:OnClickSingleBtn()
	if self.currentHyperLinkCallback then
		self.currentHyperLinkCallback()
	end
end

function M:OnClickBrandNavBtn(direction)
	local brandListData = gBaiKeArchiveManager:GetBrandListData()

	if not brandListData or #brandListData == 0 then
		return
	end

	local currentBrandIndex = nil

	for i, brandData in ipairs(brandListData) do
		if brandData.brandId == self.currentBrandId then
			currentBrandIndex = i

			break
		end
	end

	if not currentBrandIndex then
		return
	end

	local targetIndex = currentBrandIndex + direction

	if targetIndex < 1 then
		targetIndex = #brandListData
	elseif targetIndex > #brandListData then
		targetIndex = 1
	end

	local selectIndex = targetIndex - 1

	self.bindData.brandLoopList:GoToIndex(selectIndex, false)

	if self.bindData.pageCtrl == self.pageCtrl.BrandList then
		self.bindData.brandLoopList:SelectItem(selectIndex, true)
	end

	self.bindData.brandIndexText = brandListData[targetIndex].brandIndex
	self.currentBrandId = brandListData[targetIndex].brandId

	self:UpdateBrandInfoPage()
end

function M:OnClickSingleTabNavBtn(direction)
	if not self.currentPartType or #self.singleTabListData == 0 then
		return
	end

	local currentIndex = -1

	for i, data in ipairs(self.singleTabListData) do
		if data.partType == self.currentPartType then
			currentIndex = i

			break
		end
	end

	if currentIndex <= 0 then
		return
	end

	local targetIndex = currentIndex + direction

	if targetIndex < 1 or targetIndex > #self.singleTabListData then
		return
	end

	local targetData = self.singleTabListData[targetIndex]

	if targetData then
		self:SwitchToSinglePart(targetData.partType)
		self.bindData.singleList:GoToPos(Vector2.zero, true)
	end
end

function M:OnSearchItemClick(firstCategoryId, targetItemId, brandId, itemType)
	local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(firstCategoryId)

	if cityPediaFirstClassCfg.Type == self.baikeType.Fashion then
		self.SubGroup.BaikeTopTemplateStore:ClearSearchText()

		if itemType == "Brand" then
			self:JumpToBrand(brandId)
		elseif itemType == "Suit" then
			self:JumpToSuit(brandId, targetItemId)
		else
			self:JumpToFashion(targetItemId)
		end
	else
		gPanelManager:Close(gPanelId.BAIKE_CLOTHES_PANEL)

		if cityPediaFirstClassCfg.Type == self.baikeType.Vehicle then
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
end
