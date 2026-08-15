local MoneyType = UX.Game.MoneyType
local ConsumableConfig = LTConfig.ConsumableConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local MessageConfig = LTConfig.MessageConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig

require("LX6/Manager/Baike/BaikeCameraManager")

C_ShopPanelStore = DefClass("C_ShopPanelStore", C_ShopPanelStore, C_StoreGroup)
GroupName2Class.ShopPanelStore = C_ShopPanelStore
local M = C_ShopPanelStore
M.TabType = {
	Recommend = 0,
	Monthly = 2,
	Special = 3,
	Appearance = 1,
	Recharge = 4
}
M.SubTypeCtrl = {
	Weapon = 1,
	prop = 3,
	Car = 2,
	social = 3,
	Fashion = 0
}
M.AppearanceSubTab = {
	Weapon = 4,
	Vehicle = 3,
	Fashion = 2
}
M.SpecialSubTab = {
	social = 7,
	prop = 6
}
M.TabUnlockMapping = {
	[0] = SystemUnlockConfig.MallFeaturedPage,
	SystemUnlockConfig.MallSkinSalePage,
	SystemUnlockConfig.MallMonthlyCardPage,
	SystemUnlockConfig.MallExclusiveSalePage,
	SystemUnlockConfig.MallRechargePage
}

function M:ctor()
	self.tabsData = {}
	self.currentTabType = self.TabType.Recommend
	self.currentSubTabType = 0
	self.subTabsData = {}
	self.currentSuitListData = {}
	self.selectedSuitItemId = 0
	self.tryOnFashionId = 0
	self.currentModelUnit = nil
	self.selectedSpiritId = nil
	self.hasCharacterChange = false
	self.searchResultListData = {}
	self.propListData = {}
	self.commodityDataCache = {}
	self.TabMoneyConfig = {
		[self.TabType.Recommend] = {
			MoneyType.Money,
			MoneyType.Gold,
			MoneyType.BindingGold
		},
		[self.TabType.Appearance] = {
			MoneyType.Money,
			MoneyType.Gold,
			MoneyType.BindingGold
		},
		[self.TabType.Monthly] = {
			MoneyType.Money,
			MoneyType.BindingGold
		},
		[self.TabType.Special] = {
			MoneyType.Gold
		},
		[self.TabType.Recharge] = {
			MoneyType.Gold
		}
	}
end

function M:DefineAllVariables()
	self.settingInit = false
	self.shopTipInit = false
	self.characterListData = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:InitTabsData()
	self:InitCustomSubTabs()
end

function M:OnEnable()
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self:CreateAction("OnPackItemChanged"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("OnSystemUnlockStateChange")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnDestroy()
	self:ClearMessageEvents()

	self.pendingFashionCallback = nil

	if self.currentModelUnit then
		gCS.PauseManager.Instance:ProessUIModelShow(false, self.currentModelUnit)
		self.currentModelUnit:DestroyUnit(true)

		self.currentModelUnit = nil
	end

	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, false)
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	if not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.MallPanel) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.SystemLocked)
		gPanelManager:Close(panelId)

		return
	end

	self.tryOnFashionId = 0
	self.hasCharacterChange = false
	self.selectedSpiritId = data and data.spiritId or gDressManager.CurrentSpiritId
	self.panelId = panelId
	self.bindData.showSettingCtrl = 0
	self.bindData.showDetailCtrl = 0

	self:InitCommodityData()
	self:InitShopTabs()
	self:InitMoneyDisplay()
	self:InitModelViewer()

	if self.tabsData and #self.tabsData > 0 then
		self:RefreshTabContent()
	end

	self:InitBaikeCamera()
end

function M:OnClose()
	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, false)
end

function M:OnPackItemChanged()
	self:RefreshMoneyDisplay()
end

function M:OnSystemUnlockStateChange(eventId, unlockId)
	if (unlockId == SystemUnlockConfig.MallPanel or table.contains(self.TabUnlockMapping, unlockId)) and not gSystemUnlockMgr:IsUnlock(unlockId) then
		gPanelManager:Close(self.panelId)
	end
end

function M:InitTabsData()
	local mallTabs = LTConfig.MallConfig.MallTabs
	self.tabsData = {}

	for i = 1, 5 do
		local tabId = i - 1
		local unlockId = self.TabUnlockMapping[tabId]

		if not unlockId or gSystemUnlockMgr:IsUnlock(unlockId) then
			table.insert(self.tabsData, {
				id = tabId,
				title = mallTabs[i],
				unlockId = unlockId
			})
		end
	end
end

function M:InitShopTabs()
	self.SubGroup.CommonTabSingleStore:SetData(self.tabsData, nil, self.TabType.Recommend, 0, self:CreateAction("OnTabChanged"), self:CreateAction("OnRenderTab"))
end

function M:OnTabChanged(uList, isSub)
	local selectedIndex = uList.selectedIndex

	if selectedIndex >= 0 and selectedIndex < #self.tabsData then
		local tabData = self.tabsData[selectedIndex + 1]
		local tabType = tabData.id
		local unlockId = self.TabUnlockMapping[tabType]

		if unlockId and not gSystemUnlockMgr:IsUnlock(unlockId) then
			gDisplayMessageMgr:ShowMessage(MessageConfig.SystemLocked)

			return
		end

		self:ClearSearch()
		self:ClearSelection()

		local oldTabType = self.currentTabType
		self.currentTabType = tabType
		local needRefreshSubTabs = oldTabType == self.TabType.Appearance ~= (self.currentTabType == self.TabType.Appearance) or oldTabType == self.TabType.Special ~= (self.currentTabType == self.TabType.Special)

		if needRefreshSubTabs then
			self:RefreshSubTabVisibility()
		end

		self:RefreshTabContent()
	end
end

function M:OnRenderTab(btn, index, data, store, isSub, list)
	if data then
		store.title = data.title or ""
	end
end

function M:RefreshTabContent()
	self:InitMoneyDisplay()

	if self.currentTabType == self.TabType.Appearance then
		if self.currentSubTabType == 0 then
			self.currentSubTabType = self.AppearanceSubTab.Fashion
		end

		if not self.commodityDataCache[self.currentSubTabType] then
			slot1 = {}
		end

		self.currentSuitListData = slot1

		self:RefreshList()
	elseif self.currentTabType == self.TabType.Special then
		if self.currentSubTabType == 0 then
			self.currentSubTabType = self.SpecialSubTab.prop
		end

		if not self.commodityDataCache[self.currentSubTabType] then
			slot1 = {}
		end

		self.propListData = slot1

		self.bindData.propList:SetSimpleList(#self.propListData)
	else
		self.currentSuitListData = {}
		self.selectedSuitItemId = 0

		self:RefreshList()
	end
end

function M:InitCustomSubTabs()
	self:RefreshSubTabVisibility()
end

function M:RefreshSubTabVisibility()
	if self.currentTabType == self.TabType.Appearance then
		self.subTabsData = {
			{
				id = self.AppearanceSubTab.Fashion,
				subTypeCtrl = self.SubTypeCtrl.Fashion
			},
			{
				id = self.AppearanceSubTab.Vehicle,
				subTypeCtrl = self.SubTypeCtrl.Car
			},
			{
				id = self.AppearanceSubTab.Weapon,
				subTypeCtrl = self.SubTypeCtrl.Weapon
			}
		}

		self.bindData.subTabList:SetSimpleList(#self.subTabsData)

		self.currentSubTabType = self.AppearanceSubTab.Fashion
		self.bindData.goodsTypeCtrl = self.SubTypeCtrl.Fashion

		self.bindData.subTabList:SelectItem(0, false)
	elseif self.currentTabType == self.TabType.Special then
		self.subTabsData = {
			{
				id = self.SpecialSubTab.prop,
				subTypeCtrl = self.SubTypeCtrl.prop
			},
			{
				id = self.SpecialSubTab.social,
				subTypeCtrl = self.SubTypeCtrl.social
			}
		}

		self.bindData.subTabList:SetSimpleList(#self.subTabsData)

		self.currentSubTabType = self.SpecialSubTab.prop
		self.bindData.goodsTypeCtrl = self.SubTypeCtrl.prop

		self.bindData.subTabList:SelectItem(0, false)
	else
		self.subTabsData = {}

		self.bindData.subTabList:SetSimpleList(0)

		self.currentSubTabType = 0
	end
end

function M:OnSubTabChanged(uList)
	local selectedIndex = uList.selectedIndex

	if selectedIndex >= 0 and selectedIndex < #self.subTabsData then
		self:ClearSearch()
		self:ClearSelection()

		local subTabData = self.subTabsData[selectedIndex + 1]
		self.currentSubTabType = subTabData.id

		if subTabData.subTypeCtrl then
			self.bindData.goodsTypeCtrl = subTabData.subTypeCtrl
		end

		if self.currentTabType == self.TabType.Appearance then
			self.currentSuitListData = self.commodityDataCache[self.currentSubTabType] or {}

			self:RefreshList()
		elseif self.currentTabType == self.TabType.Special then
			self.propListData = self.commodityDataCache[self.currentSubTabType] or {}

			self.bindData.propList:SetSimpleList(#self.propListData)
		end
	end
end

function M:OnSubTabRender(btn, index)
	local subTabData = self.subTabsData[index + 1]

	if not subTabData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local cfg = LTConfig.MallConfig.GetConfig(subTabData.id)
		store.icon = cfg.SubTabIcon
	end
end

function M:InitCommodityData()
	self.commodityDataCache = {}

	for i = 0, MallCommodityConfig.count - 1 do
		local commodityCfg = MallCommodityConfig.LoadAt(i)

		if commodityCfg then
			local belongMallId = commodityCfg.BelongMallId

			if not self.commodityDataCache[belongMallId] then
				self.commodityDataCache[belongMallId] = {}
			end

			local dropCfg = LTConfig.DropConfig.GetConfig(commodityCfg.DropId)
			local itemId = dropCfg and dropCfg.Item1 and dropCfg.Item1[1] and dropCfg.Item1[1].id1 or 0
			local consumeCfg = itemId ~= 0 and LTConfig.ConsumableConfig.GetConfig(itemId) or nil

			table.insert(self.commodityDataCache[belongMallId], {
				id = commodityCfg.Id,
				name = commodityCfg.Name or "",
				icon = commodityCfg.Picture or 0,
				iconId = consumeCfg and consumeCfg.SItemIconId or 0,
				price = commodityCfg.Price or 0,
				quality = consumeCfg and consumeCfg.Quality or 1,
				dropId = commodityCfg.DropId or 0,
				itemId = itemId,
				moneyItemId = commodityCfg.ConsumeItemId,
				belongMallId = commodityCfg.BelongMallId,
				description = commodityCfg.Desc or "",
				mallCfg = commodityCfg,
				consumeCfg = consumeCfg
			})
		end
	end
end

function M:InitMoneyDisplay()
	local moneyTypes = self.TabMoneyConfig[self.currentTabType]
	local moneyTemplateData = {}

	for _, moneyType in ipairs(moneyTypes) do
		table.insert(moneyTemplateData, {
			Type = moneyType
		})
	end

	self.SubGroup.MoneyTemplateStore:SetData(moneyTemplateData)
end

function M:RefreshList()
	self.bindData.suitList:SetSimpleList(#self.currentSuitListData)

	if self.selectedSuitItemId > 0 then
		for i = 1, #self.currentSuitListData do
			if self.currentSuitListData[i].id == self.selectedSuitItemId then
				self.bindData.suitList:SelectItem(i - 1, true)

				break
			end
		end
	end
end

function M:RefreshMoneyDisplay()
	self:InitMoneyDisplay()
end

function M:InitModelViewer()
	if not gDressManager.CurrentSpiritId or gDressManager.CurrentSpiritId == 0 then
		gDressManager:SetCurrentPlayerSpirit()
	end

	if table.isNilOrEmpty(gDressManager.SpriteFashionInfoDict) then
		gDressManager:SetPlayerFashionsInfo()
	end

	if not self.selectedSpiritId then
		self.selectedSpiritId = gDressManager.CurrentSpiritId
	end

	self:LoadCurrentPlayerModel()
end

function M:LoadCurrentPlayerModel()
	local currentSpiritId = self.selectedSpiritId or gDressManager.CurrentSpiritId

	if not currentSpiritId or currentSpiritId == 0 then
		return
	end

	local fashionInfo = nil

	if gDressManager.SpriteFashionInfoDict and gDressManager.SpriteFashionInfoDict[currentSpiritId] then
		local spiritFashionInfo = gDressManager.SpriteFashionInfoDict[currentSpiritId]

		if spiritFashionInfo.WearFashionInfoList then
			fashionInfo = table.clone(spiritFashionInfo)

			if self.tryOnFashionId and self.tryOnFashionId > 0 then
				local tryOnFashionCfg = LTConfig.FashionConfig.GetConfig(self.tryOnFashionId)

				if tryOnFashionCfg and fashionInfo then
					fashionInfo.WearFashionEditInfoList = table.clone(fashionInfo.WearFashionEditInfoList)
					local tryOnPart = tryOnFashionCfg.Part
					local replaced = false

					for i = 1, #fashionInfo.WearFashionEditInfoList do
						local wearFashionId = fashionInfo.WearFashionEditInfoList[i].FashionId
						local wearFashionCfg = LTConfig.FashionConfig.GetConfig(wearFashionId)

						if wearFashionCfg and wearFashionCfg.Part == tryOnPart then
							fashionInfo.WearFashionEditInfoList[i] = {
								FashionId = self.tryOnFashionId
							}
							replaced = true

							break
						end
					end

					if not replaced then
						table.insert(fashionInfo.WearFashionEditInfoList, {
							FashionId = self.tryOnFashionId
						})
					end
				end
			end
		end
	end

	if self.currentModelUnit then
		self.currentModelUnit:DestroyUnit(true)

		self.currentModelUnit = nil
	end

	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(currentSpiritId)
	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)
	local modelId = agentConfig.GeneralModelId
	self.bindData.model = {
		isSetFacing = false,
		customFacing = 0,
		modelId = modelId,
		layer = LX6.Constants.LayerConstants.Player,
		otherData = {
			unitActionLoop = true,
			uiShowModel = true,
			SubType = currentSpiritId,
			cardId = currentSpiritId,
			fashionWearInfo = fashionInfo
		},
		callback = function (unit)
			self.currentModelUnit = unit
			unit.PlayerObj.transform.localScale = Vector3.one

			gCS.PauseManager.Instance:ProessUIModelShow(false, unit)
			gCS.PauseManager.Instance:ProessUIModelShow(true, unit)
			gCS.LuaUtils.SetUIUnitBindItemListLod(unit)
		end
	}
end

function M:TryOnFashion(commodityData)
	if not commodityData or not commodityData.dropId then
		return
	end

	local dropCfg = LTConfig.DropConfig.GetConfig(commodityData.dropId)

	if not dropCfg or not dropCfg.Item1 or not dropCfg.Item1[1] then
		return
	end

	local itemId = dropCfg.Item1[1].id1
	local consumeCfg = LTConfig.ConsumableConfig.GetConfig(itemId)

	if not consumeCfg or not consumeCfg.BindId then
		return
	end

	local fashionId = consumeCfg.BindId
	local fashionCfg = LTConfig.FashionConfig.GetConfig(fashionId)

	if not fashionCfg then
		return
	end

	if not gDressManager.CurrentSpiritId or gDressManager.CurrentSpiritId == 0 then
		gDressManager:SetCurrentPlayerSpirit()
	end

	if table.isNilOrEmpty(gDressManager.SpriteFashionInfoDict) then
		gDressManager:SetPlayerFashionsInfo()
	end

	local oldSelectedSpiritId = self.selectedSpiritId
	self.selectedSpiritId = gDressManager:SelectSuitableSpiritForFashion(fashionCfg, self.selectedSpiritId)

	if oldSelectedSpiritId ~= self.selectedSpiritId then
		self.hasCharacterChange = true
	end

	self.tryOnFashionId = fashionId

	self:LoadCurrentPlayerModel()
end

function M:RegisterWidget()
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.filterButton.luaClick = self:CreateAction("OnClickFilterButton")
	self.bindData.switchRoleButton.luaClick = self:CreateAction("OnClickSwitchRoleButton")
	self.bindData.settingBtn.luaClick = self:CreateAction("OnClickSettingBtn")
	self.bindData.suitList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderSuitListItem")
	self.bindData.searchList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderSearchListItem")
	self.bindData.suitList.luaSimpleClick = self:CreateAction("OnSimpleClickSuitList")
	self.bindData.searchList.luaSimpleClick = self:CreateAction("OnSimpleClickSearchList")
	self.bindData.subTabList.luaSelectedChanged = self:CreateAction("OnSubTabChanged")
	self.bindData.subTabList.luaSimpleRenderItem = self:CreateAction("OnSubTabRender")
	self.bindData.propList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderPropListItem")
	self.bindData.propList.luaSimpleClick = self:CreateAction("OnSimpleClickPropList")
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputValueChanged")
	self.bindData.searchCloseBtn.luaClick = self:CreateAction("OnSearchCloseClick")
end

function M:OnClickBackBtn()
	gPanelManager:Close(self.panelId)
end

function M:OnClickFilterButton()
	return
end

function M:OnClickSwitchRoleButton()
	gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER_PANEL, {
		onlyPreview = true,
		spiritId = self.selectedSpiritId,
		callBack = function (hasChange, selectedSpiritId)
			if hasChange and selectedSpiritId then
				self.hasCharacterChange = true
				self.selectedSpiritId = selectedSpiritId

				self:LoadCurrentPlayerModel()
				self:InitBaikeCamera()
			end
		end,
		onSelectCallback = function (selectedSpiritId)
			self.hasCharacterChange = true
			self.selectedSpiritId = selectedSpiritId

			self:LoadCurrentPlayerModel()
			self:InitBaikeCamera()
		end
	})
end

function M:OnClickSettingBtn()
	if not self.settingInit then
		local settingStore = gStoreManager:GetStoreGroup(self.bindData.shopSetting.Store):GetStoreByWidget(self.bindData.shopSetting)

		if settingStore then
			settingStore.fullBaseBtn.luaClick = self:CreateAction("OnClickSettingBtn")
			settingStore.scroll.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderCharacterListItem")
			settingStore.scroll.luaSimpleClick = self:CreateAction("OnSimpleClickCharacterList")
			settingStore.settingBtn1.luaClick = self:CreateAction("OnClickSettingBtn")
		end

		self.settingInit = true
	end

	if self.bindData.showSettingCtrl == 0 then
		self:RefreshCharacterList()
	end

	self.bindData.showSettingCtrl = 1 - self.bindData.showSettingCtrl
end

function M:RefreshCharacterList()
	self.characterListData = {}

	gSpiritManager:Foreach(function (spirit)
		table.insert(self.characterListData, {
			spiritId = spirit.Id,
			name = spirit.config.Name or ""
		})
	end)

	local settingStore = gStoreManager:GetStoreGroup(self.bindData.shopSetting.Store):GetStoreByWidget(self.bindData.shopSetting)

	if settingStore then
		settingStore.scroll:SetSimpleList(#self.characterListData)
	end
end

function M:OnSimpleRenderCharacterListItem(btn, index)
	local characterData = self.characterListData[index + 1]

	if not characterData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.name = characterData.name
	end

	if characterData.spiritId == self.selectedSpiritId then
		btn.isSelected = true
	end
end

function M:OnSimpleClickCharacterList(btn, index)
	if not btn.isSelected then
		return
	end

	local characterData = self.characterListData[index + 1]

	if not characterData then
		return
	end

	if self.selectedSpiritId ~= characterData.spiritId then
		self.selectedSpiritId = characterData.spiritId
		self.hasCharacterChange = true

		self:LoadCurrentPlayerModel()
	end
end

function M:RenderCommodityItem(store, commodityData)
	if not store or not commodityData then
		return
	end

	store.icon = commodityData.icon ~= 0 and commodityData.icon or commodityData.iconId
	store.iconBg = commodityData.icon
	store.goodsName = commodityData.name
	store.price = commodityData.price
	store.quality = commodityData.quality
	local cfg = ConsumableConfig.GetConfig(commodityData.moneyItemId)

	if cfg then
		store.moneyIcon = cfg.SMoneyIconId
	end

	store.isShowTask = 0
	store.isCollect = 0
	store.dyeType = 0
	store.isAvailable = 1
	store.isHave = 0
	store.isNew = 0
	store.isDiscount = 0

	if store.isDiscount == 1 then
		store.originPrice = commodityData.price
		store.discountNumber = "-66.6%"
	end

	store.isShowTime = 0

	if store.isShowTime == 1 then
		store.timeText = ""
	end
end

function M:OnSimpleRenderSuitListItem(btn, index)
	local commodityData = self.currentSuitListData[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	self:RenderCommodityItem(store, commodityData)
end

function M:InitShopTip()
	if self.shopTipInit then
		return
	end

	local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if shopTipStore then
		shopTipStore.buyBtn.luaClick = self:CreateAction("OnClickBuyBtn")
		shopTipStore.tagList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderShopTipTagListItem")
		shopTipStore.showDetailBtn.luaClick = self:CreateAction("OnClickShowDetailBtn")
	end

	self.shopTipInit = true
end

function M:ShowCommodityDetail(commodityData)
	if not commodityData then
		return
	end

	self:InitShopTip()

	self.selectedSuitItemId = commodityData.id
	local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if shopTipStore then
		shopTipStore.tagList:SetSimpleList(4)

		shopTipStore.price = commodityData.price
		shopTipStore.goodsName = commodityData.name
		local moneyCfg = ConsumableConfig.GetConfig(commodityData.moneyItemId)
		shopTipStore.moneyIcon = moneyCfg and moneyCfg.SMoneyIconId or 0
		shopTipStore.isDiscountCtrl = 0

		if shopTipStore.isDiscountCtrl == 1 then
			shopTipStore.originPrice = commodityData.price
		end

		local num = gPlayerItemManager:GetPackItemNum(commodityData.moneyItemId)
		shopTipStore.moneyEnoughCtrl = num < commodityData.price and 1 or 0
		local content = shopTipStore.detailScrollRect.content
		content.text = commodityData.consumeCfg and commodityData.consumeCfg.Description or commodityData.description
	end

	self:TryOnFashion(commodityData)
end

function M:OnSimpleClickSuitList(btn, index)
	if not btn.isSelected then
		self.selectedSuitItemId = 0
		self.tryOnFashionId = 0

		self:LoadCurrentPlayerModel()

		return
	end

	local commodityData = self.currentSuitListData[index + 1]

	self:ShowCommodityDetail(commodityData)
end

function M:OnSimpleRenderSearchListItem(btn, index)
	local commodityData = self.searchResultListData[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	self:RenderCommodityItem(store, commodityData)
end

function M:OnSimpleClickSearchList(btn, index)
	if not btn.isSelected then
		self.selectedSuitItemId = 0
		self.tryOnFashionId = 0

		self:LoadCurrentPlayerModel()

		return
	end

	local commodityData = self.searchResultListData[index + 1]

	self:ShowCommodityDetail(commodityData)
end

function M:OnClickBuyBtn()
	gDisplayMessageMgr:ShowMessageContentDebug("购买 待实现")
end

function M:OnClickShowDetailBtn()
	self.bindData.showDetailCtrl = 1 - self.bindData.showDetailCtrl
end

function M:OnSimpleRenderShopTipTagListItem(btn, index)
	local tagData = {
		"限时",
		"热销",
		"新品",
		"折扣"
	}
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.title = tagData[index + 1] or ""
	end
end

function M:InitBaikeCamera()
	local cameraOffsetRange = {
		-0.5,
		0.5
	}

	if gDressManager.CurrentSpiritId then
		local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(gDressManager.CurrentSpiritId)

		if fightSpiritConfig then
			local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)

			if agentConfig then
				local modelConfig = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)

				if modelConfig then
					local bodyType = modelConfig.CameraBodyType

					if bodyType == 0 then
						bodyType = modelConfig.BodyType
					end

					local fashionBaseCfg = LTConfig.FashionBaseConfig.GetConfig(bodyType)

					if fashionBaseCfg and fashionBaseCfg.CameraOffset then
						cameraOffsetRange = {
							fashionBaseCfg.CameraOffset[1],
							fashionBaseCfg.CameraOffset[2]
						}
					end
				end
			end
		end
	end

	local cameraParams = {
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = self.bindData.camera,
		modelRoot = self.bindData.modelRoot,
		cameraOffsetRange = cameraOffsetRange,
		banRotate = false,
		cameraType = gBaikeCameraManager.CameraType.Fashion
	}

	gBaikeCameraManager:SetBaikePanelCamera(self.m_Id, true, cameraParams)
end

function M:ClearSearch()
	self.bindData.inputField.text = ""
	self.bindData.searchCtrl = 0
	self.bindData.searchCloseBtnActive = false
	self.searchResultListData = {}

	self.bindData.searchList:SetSimpleList(0)
end

function M:ClearShopTipDetail()
	if not self.shopTipInit then
		return
	end

	local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if shopTipStore then
		shopTipStore.tagList:SetSimpleList(0)

		shopTipStore.price = ""
		shopTipStore.goodsName = ""
		shopTipStore.moneyIcon = 0
		shopTipStore.isDiscountCtrl = 0
		shopTipStore.originPrice = ""
		shopTipStore.moneyEnoughCtrl = 0
		local content = shopTipStore.detailScrollRect.content
		content.text = ""
	end
end

function M:ClearSelection()
	self.selectedSuitItemId = 0
	self.tryOnFashionId = 0

	self.bindData.suitList:SelectItem(-1, false)
	self.bindData.searchList:SelectItem(-1, false)
	self.bindData.propList:SelectItem(-1, false)
	self:ClearShopTipDetail()
	self:LoadCurrentPlayerModel()
end

function M:OnInputValueChanged()
	local searchText = self.bindData.inputField.text

	if string.is_null_or_empty(searchText) then
		self.bindData.searchCtrl = 0
		self.bindData.searchCloseBtnActive = false
		self.searchResultListData = {}

		self.bindData.searchList:SetSimpleList(0)

		return
	end

	self.bindData.searchCloseBtnActive = true
	self.bindData.searchCtrl = 1
	local searchResultList = {}
	local currentCommodityList = self.commodityDataCache[self.currentSubTabType] or {}

	for _, commodityData in ipairs(currentCommodityList) do
		if commodityData.name and self:IsMatchCondition(commodityData.name, searchText) then
			table.insert(searchResultList, commodityData)
		end
	end

	self.bindData.searchCtrl = #searchResultList == 0 and 2 or 1
	self.searchResultListData = searchResultList

	self.bindData.searchList:SetSimpleList(#searchResultList)
end

function M:IsMatchCondition(name, text)
	name = self:GetFormattedString(name)
	text = self:GetFormattedString(text)
	local completePinyin = tostring(gCS.LuaUtils.GetPinyin(name))
	local firstLetterPinyin = ""

	for word in string.gmatch(completePinyin, "%a+") do
		firstLetterPinyin = firstLetterPinyin .. string.sub(word, 1, 1)
	end

	completePinyin = self:GetFormattedString(completePinyin)

	if string.is_null_or_empty(text) then
		return false
	else
		return string.find(name, text) or string.find(firstLetterPinyin, text) or string.find(completePinyin, text)
	end
end

function M:GetFormattedString(str)
	return string.lower(string.gsub(str, " ", ""))
end

function M:OnSearchCloseClick()
	self:ClearSearch()
end

function M:OnSimpleRenderPropListItem(btn, index)
	local propData = self.propListData[index + 1]

	if not propData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.iconId = propData.iconId
		store.quality = propData.quality
		local moneyItemCfg = ConsumableConfig.GetConfig(propData.moneyItemId)

		if moneyItemCfg then
			store.moneyIcon = moneyItemCfg.SMoneyIconId
		end

		store.moneyNum = tostring(propData.price)
		local hasOwned = gPlayerItemManager:GetPackItemNum(propData.itemId) > 0
		store.isHaved = hasOwned and 1 or 0
		store.isAvailable = 1
		store.moneyColor = 0
		store.isShowTask = 0
		store.taskIcon = 0
	end
end

function M:OnSimpleClickPropList(btn, index)
	if not btn.isSelected then
		self.selectedSuitItemId = 0
		self.tryOnFashionId = 0

		self:LoadCurrentPlayerModel()

		return
	end

	local propData = self.propListData[index + 1]

	self:ShowCommodityDetail(propData)
end
