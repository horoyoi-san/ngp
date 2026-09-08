-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovBagPanelStore.lua
-- Decompiled from: 01987_AnantarkovBagPanelStore.lua_483e09319583.luajit

C_AnantarkovBagPanelStore = DefClass("C_AnantarkovBagPanelStore", C_AnantarkovBagPanelStore, C_AnantarkovBagStoreBase)
GroupName2Class.AnantarkovBagPanelStore = C_AnantarkovBagPanelStore
local M = C_AnantarkovBagPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.itemStatusCtrlEnum = {
		["M\\x90\\x9c\\x80I"] = 2,
		["FT\\xfd\\xb8\\x85\\xbb\\xcc\\xec"] = 3,
		["\r\\xf7W)\\xe3\\xb7S\\xa2^\\xb5\\xb2"] = 4,
		["H\\xa3\\xb2\\xbb\\xaf"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.searchCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.showContainerCtrlEnum = {
		["\\xea\\xcf#\\xf4"] = 2,
		["\\xacg~"] = 1,
		["\\xfd\\xd2(\\xf4"] = 0
	}
	self.endModeCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["\\xaf\\xb4$\\xa8~7\\xe86"] = 0
	}
	self.inGameCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.showExpandCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.showStorageListCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.showTabCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.searchCtrlEnum = nil
	self.showContainerCtrlEnum = nil
	self.endModeCtrlEnum = nil
	self.inGameCtrlEnum = nil
	self.showExpandCtrlEnum = nil
	self.showStorageListCtrlEnum = nil
	self.showTabCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnDestroy = function(self)
	self.activeEndMode = nil

	self.StopSearchStateTracker(self)

	if self.containerInstanceId then
		gExtractionShooterManager:AskExtractionShooterEndSearchContainer(self.containerInstanceId)
	end

	self.containerInstanceId = nil
	self._dragCanPlaceCtx = nil

	self.ClearMessageEvents(self)

	self.bindData.bagList = nil
	self.bindData.safeBoxList = nil
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.BAG_LIST_WIDTH_EXTRA = 20
	self.expansionBagViewDataList = nil
	self.containerInstanceId = args and args.containerInstanceId
	self.itemContainerId = args and args.itemContainerId
	self.containerNameId = args and args.containerNameId
	self.nextButtonClick = args and args.nextButtonClick
	self.exitButtonClick = args and args.exitButtonClick
	self.activeEndMode = args and args.activeEndMode
	self.gamePlayTypeId = args and args.gamePlayTypeId or 1
	self.bagStoreSet = gExtractionShooterManager.GetBagStoreSet(self.gamePlayTypeId)
	self.bagListNameByBagId = {
		[self.bagStoreSet.normal] = "bagList",
		[self.bagStoreSet.safebox] = "safeBoxList",
		[self.bagStoreSet.strengthen] = "strengthenList",
		[self.bagStoreSet.shield] = "shieldList"
	}
end

M.InitView = function(self, args)
	self.bindData.showTabCtrl = self:GetShowTabCtrl(args)
	self.currentInventoryBagId = self.bagStoreSet.inventory
	self.bindData.showExpandCtrl = self.showExpandCtrlEnum.active
	local bagWeaponCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(self.bagStoreSet.wheel)
	local isShowBackCircle = bagWeaponCfg.IsShow
	self.SubGroup.BackCircleAnantarkovStore.activeEndMode = self.activeEndMode
	self.SubGroup.BackCircleAnantarkovStore.containerInstanceId = self.containerInstanceId
	self.SubGroup.BackCircleAnantarkovStore.bagStoreSet = self.bagStoreSet

	self.SubGroup.BackCircleAnantarkovStore:OnShow({
		cellSize = self.bindData.bagList.gridSize,
		gamePlayTypeId = self.gamePlayTypeId
	})
	self.SubGroup.BackCircleAnantarkovStore.rootWidget:SetActive(isShowBackCircle)

	self.bindData.showContainerCtrl = self:GetBagShowTypeCtrl()
	self.bindData.inGameCtrl = gExtractionShooterManager.CheckInGame() and 0 or 1

	self:InitDragList()
	self:RefreshPanelView()

	if self.nextButtonClick then
		self.bindData.nextButton.luaClick = self.nextButtonClick
	end

	if self.exitButtonClick then
		self.bindData.exitButton.luaClick = self.exitButtonClick
	end

	self.bindData.endModeCtrl = self.activeEndMode and self.endModeCtrlEnum.active or self.endModeCtrlEnum.deActive

	self:RefreshBagExpansionView()
end

M.GetShowTabCtrl = function(self, args)
	if args and args.isFromMainTabPage or gPanelManager:IsPanelShowing(gPanelId.ANANTARKOV_MAIN_PANEL) then
		return 1
	end

	return 0
end

M.RefreshMoneyTemplateView = function(self)
	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)
end

M.GetMoneyDataList = function(self)
	local moneyDataList = {}

	table.insert(moneyDataList, {
		["a\\x9f\\x8a\\x86Y"] = 0,
		itemId = LTConfig.ConsumableConfig.RewardMoney
	})
end

M.CheckCanRefreshBagExpansionView = function(self)
	return self.bindData.inventoryList.activation
end

M.GetBagGamePlayTypeId = function(self)
	return self.gamePlayTypeId
end

M.DecorateExpansionBagViewDataList = function(self, viewDataList, canAddBagMaxCount)
	local canAddBag = canAddBagMaxCount >= #viewDataList - 1

	if self:GetCurrentExpandSionId(self.currentInventoryBagId) then
		table.insert(viewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 2
		})
	end

	if canAddBag and self.GetCurrentUnlockBagExpansionId(self) then
		table.insert(viewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 1
		})
	end

	local targetDataList = {}

	for index, viewData in ipairs(viewDataList) do
		table.insert(targetDataList, viewData)

		if index == #viewDataList then
			table.insert(targetDataList, {
				["a\\x9f\\x8a\\x86Y"] = 3
			})
		end
	end

	return targetDataList
end

M.GetExpansionBagDisplayIndex = function(self, data, index)
	return data.realIndex + 1
end

M.OnSelectInventoryBag = function(self, bagId)
	self.currentInventoryBagId = bagId
	self.bindData.inventoryBagName = self:GetBagName(self.currentInventoryBagId)

	self:RefreshCommonBagListView(self.currentInventoryBagId)

	self.expansionBagViewDataList = self:GetExpansionBagViewDataList()

	self.bindData.extraStoreBagList:SetSimpleList(#self.expansionBagViewDataList)
end

M.OnRenderExtraStoreBagExtraItem = function(self, btn, data)
	if data.tIndex ~= 1 then
		btn.luaClick = self.CreateAction(self, "OnAddExtraBagList")
	elseif data.tIndex ~= 2 then
		btn.luaClick = self.CreateAction(self, "OnBagExpandClick")
	end
end

M.GetBagShowTypeCtrl = function(self)
	if self.containerInstanceId then
		return self.showContainerCtrlEnum.Box
	end

	if gExtractionShooterManager.CheckInGame() and not self.activeEndMode then
		return self.showContainerCtrlEnum.Disable
	end

	return self.showContainerCtrlEnum.Storage
end

M.InitDragList = function(self)
	self.bindData.normalBagName = self:GetBagName(self.bagStoreSet.normal)
	self.bindData.safeBoxBagName = self:GetBagName(self.bagStoreSet.safebox)
	self.bindData.inventoryBagName = self:GetBagName(self.currentInventoryBagId)
	local bd = self.bindData
	local enableDragList = {
		bd.containerList,
		bd.bagList,
		bd.inventoryList,
		bd.safeBoxList,
		bd.shieldList,
		bd.strengthenList
	}

	bd.containerList:SetEnabledDragList(enableDragList)
	bd.bagList:SetEnabledDragList(enableDragList)
	bd.safeBoxList:SetEnabledDragList(enableDragList)
	bd.inventoryList:SetEnabledDragList(enableDragList)
	bd.strengthenList:SetEnabledDragList(enableDragList)
	bd.shieldList:SetEnabledDragList(enableDragList)
end

M.RefreshPanelView = function(self)
	self.RefreshBringOutLimitView(self)
	self.RefreshTotalPriceAndWeight(self)
	self.RefreshContainerListView(self)
	self.RefreshCommonBagListView(self, self.bagStoreSet.normal)
	self.RefreshCommonBagListView(self, self.bagStoreSet.safebox)
	self.RefreshCommonBagListView(self, self.currentInventoryBagId)
	self.RefreshCommonBagListView(self, self.bagStoreSet.strengthen)
	self.RefreshCommonBagListView(self, self.bagStoreSet.shield)
	self.RefreshMoneyTemplateView(self)
end

M.RefreshTotalPriceAndWeight = function(self)
	local totalPrice, totalWeight = gExtractionShooterManager.GetBagTotalPriceAndWeight(self.gamePlayTypeId)
	self.bindData.totalValue = totalPrice
	self.bindData.totalLoad = LTConfig.ExtractionShooterConfig.BagTotalWeight:format(totalWeight)
end

M.RefreshContainerListView = function(self)
	self._dragCanPlaceCtx = nil
	local containerList = self.bindData.containerList
	local containerInfo = gExtractionShooterManager:GetContainerInfo(self.containerInstanceId)

	if containerInfo then
		local containerId = containerInfo.CfgId
		local containerCfg = LTConfig.ExtractionShooterItemContainerConfig.GetConfig(containerId)
		local containerNameCfg = LTConfig.ExtractionShooterContainerNameConfig.GetConfig(self.containerNameId)
		self.bindData.containerName = containerNameCfg and containerNameCfg.Name or ""
		local x = containerCfg.Capacity.x
		local y = containerCfg.Capacity.y
		local height = containerList.rowSpacing * (y - 1) + containerList.gridSize.y * y
		local widthExtra = self.BAG_LIST_WIDTH_EXTRA
		local width = containerList.colSpacing * (x - 1) + containerList.gridSize.x * x + widthExtra
		containerList.transform.sizeDelta = Vector2.Fetch(width, height)
		containerList.rowCount = y
		local itemInfoList = containerInfo.ItemList

		containerList.onGetItemPos = function(index)
			local itemInfo = itemInfoList[index + 1]

			return Vector2.Fetch(itemInfo.CellX, itemInfo.CellY)
		end

		containerList.onItemTransfer = self:CreateAction("OnItemTransfer")

		containerList.onItemRotate = function(index, newItemSize, newPos)
			local itemInfo = itemInfoList[index + 1]
			local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)
			local isRotated = newItemSize.x == itemCfg.Volume.x

			if itemInfo.IsRotated == isRotated or newPos.x == itemInfo.CellX or newPos.y == itemInfo.CellY then
				gExtractionShooterManager:AskExtractionShooterShiftContainerItem(self.containerInstanceId, itemInfo.CellX, itemInfo.CellY, newPos.x, newPos.y, isRotated)
			end
		end

		containerList.onExternalDrop = function(source, uGridList, newPos)
			self:OnExternalDrop(source, uGridList, newPos)
		end

		containerList.onItemPosChange = function(index, newPos)
			local itemInfo = itemInfoList[index + 1]

			gExtractionShooterManager:AskExtractionShooterShiftContainerItem(self.containerInstanceId, itemInfo.CellX, itemInfo.CellY, newPos.x, newPos.y, itemInfo.IsRotated)
		end

		containerList.onGetItemSize = function(index)
			local itemInfo = itemInfoList[index + 1]
			local itemId = itemInfo.Id
			local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemId)
			local itemX, itemY = gExtractionShooterUtils.GetRotatedVolume(itemCfg, itemInfo.IsRotated)

			return Vector2.Fetch(itemX, itemY)
		end

		containerList.luaButtonEndDrag = function(index, _, pointerEnterGameObject)
			if self.activeEndMode or not pointerEnterGameObject then
				return
			end

			if pointerEnterGameObject.transform.parent ~= self.rootWidget.transform then
				local itemInfo = itemInfoList[index + 1]
				local id = itemInfo.Id

				if gExtractionShooterManager.CheckItemCanDiscard(id) then
					gExtractionShooterManager:AskExtractionShooterRemoveContainerItem(self.containerInstanceId, itemInfo.CellX, itemInfo.CellY)
				end
			end
		end

		containerList.onCheckCanPlace = function(srcList, srcIndex, dstList, cellPos, isRotated)
			return self:OnCheckCanPlace(srcList, srcIndex, dstList, cellPos, isRotated)
		end

		containerList:SetList(#itemInfoList)
		self:RefreshSearchCtrlView()
		self:StartSearchStateTracker()

		return
	end

	containerList.SetList(containerList, 0)
end

M.RefreshSearchCtrlView = function(self)
	if self.containerInstanceId then
		local containerInfo = gExtractionShooterManager:GetContainerInfo(self.containerInstanceId)
		local itemInfoList = containerInfo.ItemList
		local isSearching = array.any(itemInfoList, function (itemInfo)
			local itemSearchControl = self:GetContainerItemSearchStatusCtrl(itemInfo)

			return itemSearchControl ~= self.itemStatusCtrlEnum.search
		end)
		self.bindData.searchCtrl = isSearching and self.searchCtrlEnum.active or self.searchCtrlEnum.normal
	end
end

M.GetBagListWidget = function(self, bagConfigId)
	if bagConfigId ~= self.currentInventoryBagId then
		return self.bindData.inventoryList
	end

	local listName = self.bagListNameByBagId[bagConfigId]

	return listName and self.bindData[listName] or nil
end

M.SetupBagListDragOut = function(self, bagList, bagConfigId, itemInfoList)
	bagList.luaButtonEndDrag = function(index, _, pointerEnterGameObject)
		if self.activeEndMode or not pointerEnterGameObject then
			return
		end

		if pointerEnterGameObject.transform.parent ~= self.rootWidget.transform then
			local itemInfo = itemInfoList[index + 1]
			local id = itemInfo.Id

			if gExtractionShooterManager.CheckItemCanDiscard(id) then
				gExtractionShooterManager:AskExtractionShooterRemoveItem(bagConfigId, itemInfo.CellX, itemInfo.CellY)
			end
		end
	end
end

M.SetupBagListExtraCallbacks = function(self, bagList, bagConfigId, itemInfoList)
	bagList.onExternalDrop = function(source, uGridList, newPos)
		self:OnExternalDrop(source, uGridList, newPos)
	end
end

M.OnCanTransfer = function(self, srcList, srcIndex, dstList, targetIndex, dstPos)
	local fromBagConfigId = self.GetBagConfigIdOrContainerInstanceId(self, srcList)

	if fromBagConfigId then
		local fromBagInfo = gExtractionShooterManager.GetBagInfoByConfigId(fromBagConfigId)
		local srcItemInfo = fromBagInfo.ItemInfoList[srcIndex + 1]
		local toBagConfigId = self.GetBagConfigIdOrContainerInstanceId(self, dstList)

		if toBagConfigId and srcItemInfo then
			local result = gExtractionShooterManager.CheckCellAllowed(toBagConfigId, srcItemInfo.Id)

			return result
		end
	end

	return true
end

M.GetBagListItemSize = function(self, itemX, itemY, capacityX, capacityY)
	return Vector2.Fetch(math.min(itemX, capacityX), math.min(itemY, capacityY))
end

M.AfterRefreshCommonBagListView = function(self, bagList, bagConfigId, itemInfoList)
	local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagConfigId)

	bagList.SetActive(bagList, bagCfg.IsShow)

	if (bagConfigId ~= self.bagStoreSet.strengthen or bagConfigId ~= self.bagStoreSet.shield) and bagList.backgroundInstance then
		bagList.backgroundInstance:SetActive(#itemInfoList ~= 0)
	end

	self.bindData.shieldSlot = self.GetShieldSlotHasAddCellCount(self)
	self.bindData.safeBoxCount = self.GetBagCount(self, self.bagStoreSet.safebox)
	self.bindData.normalBagCount = self.GetBagCount(self, self.bagStoreSet.normal)
	self.bindData.inventoryBagCount = self.GetBagCount(self, self.currentInventoryBagId)
end

M.GetBagCount = function(self, bagId)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagId)
	local itemCount = #bagInfo.ItemInfoList
	local bagX, bagY = gExtractionShooterManager.GetBagCapacity(bagId)

	return ("%d/%d"):format(itemCount, bagX * bagY)
end

M.GetShieldSlotHasAddCellCount = function(self)
	local bagId = self.bagStoreSet.normal
	local bagX, bagY = gExtractionShooterManager.GetBagCapacity(bagId)
	local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagId)
	local baseX = bagCfg.Capacity.x
	local baseY = bagCfg.Capacity.y

	if bagX * bagY <= baseX * baseY then
		return ("+%d"):format(bagX * bagY - baseX * baseY)
	else
		return ""
	end
end

M.OnExternalDrop = function(self, source, uGridList, newPos)
	if source.gameObject.name ~= "Root" and source.transform.parent then
		local weaponItem = source.transform.parent:GetComponentInParent(typeof(SGUI.UButton))

		if weaponItem then
			local slotIndex = gExtractionShooterManager.GetSlotIndexByWidget(weaponItem)

			if slotIndex then
				local fromCellX, fromCellY = gExtractionShooterManager.GetCellIndexBySlotIndex(slotIndex, self.bagStoreSet.wheel)
				local toBagConfigId, containerInstanceId = self.GetBagConfigIdOrContainerInstanceId(self, uGridList)
				local fromBagConfigId = self.bagStoreSet.wheel

				if toBagConfigId then
					gExtractionShooterManager:AskExtractionShooterShiftItem(fromBagConfigId, fromCellX, fromCellY, toBagConfigId, newPos.x, newPos.y)
				elseif containerInstanceId then
					local itemInfo = gExtractionShooterManager.GetItemInfoBySlot(slotIndex, self.bagStoreSet.wheel)

					gExtractionShooterManager:AskExtractionShooterShiftBagItemToContainer(fromBagConfigId, itemInfo, containerInstanceId, newPos.x, newPos.y)
				end
			end
		end
	end
end

M.GetBagConfigIdOrContainerInstanceId = function(self, uGridList)
	local bagConfigId, containerInstanceId = nil

	if uGridList ~= self.bindData.bagList then
		bagConfigId = self.bagStoreSet.normal
	elseif uGridList ~= self.bindData.safeBoxList then
		bagConfigId = self.bagStoreSet.safebox
	elseif uGridList ~= self.bindData.inventoryList then
		bagConfigId = self.currentInventoryBagId
	elseif uGridList ~= self.bindData.containerList then
		containerInstanceId = self.containerInstanceId
	elseif uGridList ~= self.bindData.shieldList then
		bagConfigId = self.bagStoreSet.shield
	elseif uGridList ~= self.bindData.strengthenList then
		bagConfigId = self.bagStoreSet.strengthen
	end

	return bagConfigId, containerInstanceId
end

M.GetCanPlaceBagAndContainerId = function(self, uGridList)
	return self.GetBagConfigIdOrContainerInstanceId(self, uGridList)
end

M.CheckItemCanRotate = function(self, bagConfigId, containerInstanceId, itemInfo)
	if not itemInfo then
		return false
	end

	local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)

	if not itemCfg then
		return false
	end

	if itemCfg.Volume.x ~= itemCfg.Volume.y then
		return false
	end

	local ctx = nil

	if containerInstanceId then
		local containerInfo = gExtractionShooterManager:GetContainerInfo(containerInstanceId)

		if not containerInfo then
			return false
		end

		local containerCfg = LTConfig.ExtractionShooterItemContainerConfig.GetConfig(containerInfo.CfgId)
		ctx = gExtractionShooterUtils.BuildBagContext(containerCfg.Capacity.x, containerCfg.Capacity.y, containerInfo.ItemList)
	elseif bagConfigId then
		ctx = gExtractionShooterUtils.BuildBagContextByConfigId(bagConfigId)
	else
		return false
	end

	local targetRotated = not itemInfo.IsRotated
	local _, overlaps = gExtractionShooterUtils.TryGetOverlapItemsByShiftItem(ctx, itemInfo.CellX, itemInfo.CellY, itemCfg, targetRotated, itemInfo)
	local err = gExtractionShooterUtils.CheckShiftItemInBag(ctx, itemInfo, itemCfg, targetRotated, itemInfo.CellX, itemInfo.CellY, overlaps)

	return err ~= LTConfig.MessageConfig.Ok
end

M.OnItemTransfer = function(self, fromUGridList, toUGridList, currentIndex, newPosition, _, _, newItemSize)
	local fromBagConfigId, fromContainerInstanceId = self.GetBagConfigIdOrContainerInstanceId(self, fromUGridList)
	local toBagConfigId, toContainerInstanceId = self.GetBagConfigIdOrContainerInstanceId(self, toUGridList)
	local toCellX = newPosition.x
	local toCellY = newPosition.y

	if fromBagConfigId then
		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(fromBagConfigId)
		local itemInfoList = bagInfo.ItemInfoList
		local itemInfo = itemInfoList[currentIndex + 1]
		local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)
		local isRotated = newItemSize.x == itemCfg.Volume.x

		if toBagConfigId then
			gExtractionShooterManager:AskExtractionShooterShiftItem(fromBagConfigId, itemInfo.CellX, itemInfo.CellY, toBagConfigId, toCellX, toCellY, isRotated)
		elseif toContainerInstanceId then
			gExtractionShooterManager:AskExtractionShooterShiftBagItemToContainer(fromBagConfigId, itemInfo, toContainerInstanceId, toCellX, toCellY, isRotated)
		end
	elseif fromContainerInstanceId and toBagConfigId then
		local containerInfo = gExtractionShooterManager:GetContainerInfo(fromContainerInstanceId)
		local itemInfoList = containerInfo.ItemList
		local itemInfo = itemInfoList[currentIndex + 1]
		local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)
		local isRotated = newItemSize.x == itemCfg.Volume.x

		gExtractionShooterManager:AskExtractionShooterShiftContainerItemToBag(fromContainerInstanceId, itemInfo.CellX, itemInfo.CellY, toBagConfigId, toCellX, toCellY, isRotated)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_UPDATE] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_REMOVE] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_CLEAR] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_SHIFT_FAIL] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_CONTAINER_UPDATE] = self.CreateAction(self, "OnContainerUpdate"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_CONTAINER_ITEM_REMOVE] = self.CreateAction(self, "RefreshContainerListView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_SPLIT_ITEM] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_RAID_SPLIT_ITEM] = self.CreateAction(self, "RefreshContainerListView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_SELL_ITEM] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_BRING_OUT_CHANGE] = self.CreateAction(self, "RefreshBringOutLimitView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_BAG_CAPACITY_CHANGE] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_BAG_EXPANSION_SUCCESS] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_SORT_BAG_RESULT] = self.CreateAction(self, "RefreshBagListView")
	}
end

M.RegisterWidget = function(self)
	self.bindData.swapButton.luaClick = self.CreateAction(self, "OnClickSwapButton")
	self.bindData.sortButton.luaClick = self.CreateAction(self, "OnClickSortButton")
	self.bindData.closeButton.luaClick = self.CreateAction(self, "OnClickExitButton")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnClickExitButton")
	self.bindData.containerList.luaRenderItem = self.CreateAction(self, "OnRenderContainerItem")
	self.bindData.safeBoxButton.luaClick = self.CreateAction(self, "OnClickSafeBoxButton")
	self.bindData.moneyButton.luaClick = self.CreateAction(self, "OnClickMoneyButton")
	self.bindData.equipmentButton.luaClick = self.CreateAction(self, "OnClickEquipmentButton")

	self.bindData.bagList.luaRenderItem = function(btn, index)
		self:OnRenderBagItem(self.bagStoreSet.normal, btn, index)
	end

	self.bindData.safeBoxList.luaRenderItem = function(btn, index)
		self:OnRenderBagItem(self.bagStoreSet.safebox, btn, index)
	end

	self.bindData.inventoryList.luaRenderItem = function(btn, index)
		self:OnRenderBagItem(self.currentInventoryBagId, btn, index)
	end

	self.bindData.strengthenList.luaRenderItem = function(btn, index)
		self:OnRenderBagItem(self.bagStoreSet.strengthen, btn, index)
	end

	self.bindData.shieldList.luaRenderItem = function(btn, index)
		self:OnRenderBagItem(self.bagStoreSet.shield, btn, index)
	end

	self.bindData.extraStoreBagList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderExtraStoreBagItem")
end

M.RefreshBagListView = function(self, _, bagConfigId)
	self.RefreshTotalPriceAndWeight(self)
	self.RefreshCommonBagListView(self, bagConfigId)
	self.RefreshBagExpansionView(self)
end

M.RefreshBringOutLimitView = function(self)
	self.bindData.fundAmount = gExtractionShooterManager.GetFundAmount(self.gamePlayTypeId)
end

M.OnItemDoubleClick = function(self, args)
	local itemInfo = args.itemInfo
	local bagConfigId = args.bagConfigId

	if self.containerInstanceId then
		gExtractionShooterManager:QuickShiftBagToContainer(bagConfigId, itemInfo, self.containerInstanceId)
	elseif self.bindData.showContainerCtrl ~= self.showContainerCtrlEnum.Storage then
		if bagConfigId ~= self.currentInventoryBagId then
			gExtractionShooterManager:QuickShiftBagToBagByPrice(bagConfigId, itemInfo.CellX, itemInfo.CellY, itemInfo)
		else
			gExtractionShooterManager:QuickShiftBagToBag(bagConfigId, itemInfo.CellX, itemInfo.CellY, itemInfo, self.currentInventoryBagId)
		end
	else
		local toBagConfigId = bagConfigId ~= self.bagStoreSet.normal and self.bagStoreSet.safebox or self.bagStoreSet.normal

		gExtractionShooterManager:QuickShiftBagToBag(bagConfigId, itemInfo.CellX, itemInfo.CellY, itemInfo, toBagConfigId)
	end
end

M.OnRenderToolTips = function(self, args, btn, popup, popupIndex)
	local store = gStoreManager:GetStoreGroup(popup.Store):GetStoreByWidget(popup)

	if popupIndex ~= 0 then
		self.OnRenderPopupItemInfo(self, store, args)
	elseif popupIndex ~= 1 then
		self.OnRenderPopupItemTypeList(self, store, btn, args)
	elseif popupIndex ~= 2 then
		self.OnRenderPopupSplitItemInfo(self, store, btn, args)
	elseif popupIndex ~= 3 then
		self.OnRenderPopupSellItemInfo(self, store, btn, args)
	elseif popupIndex ~= 4 then
		self.OnRenderPopupItemDetail(self, popup, btn, args)
	end
end

M.OnRenderPopupItemDetail = function(self, popup, btn, args)
	local itemInfo = args.itemInfo
	local id = itemInfo.Id
	local toolTipsData = gCommonItemManager:GetItemRenderData({
		["\\xa2\\xa21\\xaax5\\xf1%"] = true,
		itemId = id,
		itemNum = itemInfo.StackCount,
		gamePlayTypeId = self.gamePlayTypeId,
		bagConfigId = args.bagConfigId,
		UniqueId = itemInfo.WeaponData and itemInfo.WeaponData.InstanceId or nil
	})

	gCommonItemManager:OnRenderToolTips(toolTipsData, btn, popup)
end

M.OnRenderPopupSellItemInfo = function(self, store, btn, args)
	local itemInfo = args.itemInfo
	local bagConfigId = args.bagConfigId
	local id = itemInfo.Id
	local systemPrice = gExtractionShooterManager.GetItemSystemPrice(id)
	store.name = gExtractionShooterManager.GetItemName(id)
	store.count = ("%d/%d"):format(1, itemInfo.StackCount)

	store.list.luaSimpleRenderItem = function(childBtn, index)
		local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
		childStore.title = LTConfig.ExtractionShooterConfig.BasicSellText
		childStore.money = systemPrice
	end

	store.list:SetSimpleList(1)

	store.sellMoney = math.floor(systemPrice)

	store.lessButton.luaClick = function()
		local targetValue = store.slider.value - 1
		store.slider.value = targetValue
	end

	store.leastButton.luaClick = function()
		store.slider.value = 1
	end

	store.moreButton.luaClick = function()
		local targetValue = store.slider.value + 1
		store.slider.value = targetValue
	end

	store.mostButton.luaClick = function()
		store.slider.value = itemInfo.StackCount
	end

	store.slider.luaValueChanged = function(value)
		store.count = ("%d/%d"):format(value, itemInfo.StackCount)
		store.sellMoney = math.floor(systemPrice * value)
	end

	store.slider.minValue = 1
	store.slider.maxValue = itemInfo.StackCount
	store.slider.value = 1

	store.cancelButton.luaClick = function()
		btn:CloseTooltip(true)
	end

	store.sellButton.luaClick = function()
		local sellMoney = systemPrice * store.slider.value

		gExtractionShooterManager:AskSellItem(bagConfigId, itemInfo.CellX, itemInfo.CellY, store.slider.value, sellMoney)
		btn:CloseTooltip(true)
	end

	gExtractionShooterManager:RefreshCommonItemInfoView(store.itemWidget, itemInfo)
end

M.OnRenderPopupSplitItemInfo = function(self, store, btn, args)
	local bagConfigId = args.bagConfigId
	local itemInfo = args.itemInfo
	local containerInstanceId = args.containerInstanceId
	local maxSplitCount = itemInfo.StackCount - 1

	store.lessButton.luaClick = function()
		local targetValue = store.slider.value - 1

		store.slider:ProgressToValue(targetValue)
	end

	store.leastButton.luaClick = function()
		store.slider:ProgressToValue(1)
	end

	store.slider.luaValueChanged = function(value)
		store.count = ("%d/%d"):format(value, maxSplitCount)
	end

	store.moreButton.luaClick = function()
		local targetValue = store.slider.value + 1

		store.slider:ProgressToValue(targetValue)
	end

	store.mostButton.luaClick = function()
		store.slider:ProgressToValue(maxSplitCount)
	end

	store.slider.minValue = 1
	store.slider.maxValue = maxSplitCount
	store.slider.value = 1
	slot8 = "%d/%d"
	store.count = slot8:format(store.slider.value, maxSplitCount)

	store.cancelButton.luaClick = function()
		btn:CloseTooltip(true)
	end

	store.splitButton.luaClick = function()
		local splitCount = store.slider.value

		btn:CloseTooltip(true)

		bagConfigId = bagConfigId or 0
		local isRotated = itemInfo.IsRotated

		if gExtractionShooterManager.CheckInGame() then
			gExtractionShooterManager:AskExtractionShooterRaidSplitItem(bagConfigId, containerInstanceId, itemInfo.CellX, itemInfo.CellY, splitCount, isRotated)
		else
			gExtractionShooterManager:AskExtractionShooterSplitItem(bagConfigId, itemInfo.CellX, itemInfo.CellY, splitCount, isRotated)
		end
	end
end

M.OnRenderPopupItemTypeList = function(self, store, oriButton, args)
	local bagConfigId = args.bagConfigId
	local itemInfo = args.itemInfo
	local containerInstanceId = args.containerInstanceId
	local buttonDataList = C_AnantarkovBagStoreBase.GetRightClickButtonDataList({
		gamePlayTypeId = self.gamePlayTypeId,
		srcBagConfigId = bagConfigId,
		srcContainerInstanceId = containerInstanceId,
		containerInstanceId = self.containerInstanceId,
		itemInfo = itemInfo,
		activeEndMode = self.activeEndMode,
		bagHasContainer = self.containerInstanceId == nil,
		checkCanShowPutBack = function ()
			return self.bindData.inventoryList.bActive or self.containerInstanceId == nil
		end,
		checkCanRotate = function ()
			return self:CheckItemCanRotate(bagConfigId, containerInstanceId, itemInfo)
		end
	})
	local ButtonConfig = LTConfig.ExtractionShooterRightClickButtonConfig

	C_AnantarkovBagStoreBase.SetupRightClickButtonList(store, oriButton, buttonDataList, function ()
		return {
			srcBagConfigId = bagConfigId,
			itemInfo = itemInfo,
			srcContainerInstanceId = containerInstanceId,
			containerInstanceId = self.containerInstanceId,
			activeEndMode = self.activeEndMode,
			gamePlayTypeId = self.gamePlayTypeId
		}
	end, function (data)
		if data.id ~= ButtonConfig.Split then
			oriButton:OpenTooltip(2)
		elseif data.id ~= ButtonConfig.CanSell then
			oriButton:OpenTooltip(3)
		elseif data.id ~= ButtonConfig.Extract then
			local name = gExtractionShooterManager.GetItemName(itemInfo.Id)

			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.BringOutConfirm, function ()
				gExtractionShooterManager:AskBringOutItem(bagConfigId, itemInfo.CellX, itemInfo.CellY)
			end, nil, name)
		elseif data.id ~= ButtonConfig.Detail then
			oriButton:OpenTooltip(4)
		elseif data.id ~= ButtonConfig.PutBack then
			if self.containerInstanceId then
				gExtractionShooterManager:QuickShiftBagToContainer(bagConfigId, itemInfo, self.containerInstanceId)
			else
				local targetBagConfigId = self:TryGetFreeInventoryBagConfigId(itemInfo.Id, itemInfo)

				gExtractionShooterManager:QuickShiftBagToBag(bagConfigId, itemInfo.CellX, itemInfo.CellY, itemInfo, targetBagConfigId)
			end
		end
	end)
end

M.TryGetFreeInventoryBagConfigId = function(self, itemId, srcItemInfo)
	local currentInventoryBagId = self.currentInventoryBagId

	if gExtractionShooterManager.TryGetFreeCellIndexByConfigId(currentInventoryBagId, itemId, srcItemInfo) then
		return currentInventoryBagId
	end

	for _, data in ipairs(self.expansionBagViewDataList) do
		if data.bagId and data.bagId == currentInventoryBagId and gExtractionShooterManager.TryGetFreeCellIndexByConfigId(data.bagId, itemId, srcItemInfo) then
			return data.bagId
		end
	end

	return currentInventoryBagId
end

M.OnRenderBagItem = function(self, bagConfigId, btn, index)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	local itemInfoList = bagInfo.ItemInfoList
	local itemInfo = itemInfoList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if itemInfo then
		slot8 = gExtractionShooterManager

		slot8:RefreshCommonItemInfoView(btn, itemInfo, bagConfigId)

		local itemId = itemInfo.Id
		local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemId)
		local itemX, itemY = gExtractionShooterUtils.GetRotatedVolume(itemCfg, itemInfo.IsRotated)

		self:RefreshBagItemImage(store, bagConfigId, itemInfo, itemX, itemY)

		btn.luaHover = function()
			if not self.isPopupIndex or self.isPopupIndex ~= 0 then
				btn:CloseTooltip(true)
				btn:OpenTooltip(0)
			end
		end

		btn.luaBeginDrag = function()
			btn:CloseTooltip(true)

			local replicaWidget = btn.replicaWidget

			if replicaWidget then
				local cellSizeX = self.bindData.inventoryList.gridSize.x
				local cellSizeY = self.bindData.inventoryList.gridSize.y
				replicaWidget.transform.sizeDelta = Vector2.Fetch(itemX * cellSizeX, itemY * cellSizeY)
				replicaWidget.transform.localScale = Vector2.one
				local replicaStore = gStoreManager:GetStoreGroup(replicaWidget.Store):GetStoreByWidget(replicaWidget)
				replicaStore.showSelectboxCtrl = 0
			end
		end

		store.statusCtrl = 0
		store.waitForClick = nil
		store.waitForClickCo = coroutine.stop(store.waitForClickCo)
		btn.luaTooltipPopup = self:CreateAction("OnToolTipPopup")
		btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", {
			bagConfigId = bagConfigId,
			itemInfo = itemInfo
		})

		self:WrapDoubleClick(store, btn, function ()
			btn:CloseTooltip(true)
			self:OnItemDoubleClick({
				itemInfo = itemInfo,
				bagConfigId = bagConfigId
			})
		end)

		btn.luaEnterDropWidget = function(widget)
			local toSlotIndex = gExtractionShooterManager.GetSlotIndexByWidget(widget)

			if toSlotIndex then
				local toBagConfigId = self.bagStoreSet.wheel

				if gExtractionShooterManager.CheckCellAllowed(toBagConfigId, itemInfo.Id, toSlotIndex) then
					local toCellX, toCellY = gExtractionShooterManager.GetCellIndexBySlotIndex(toSlotIndex)

					gExtractionShooterManager:AskExtractionShooterShiftItem(bagConfigId, itemInfo.CellX, itemInfo.CellY, toBagConfigId, toCellX, toCellY)
				end
			end
		end

		return
	end

	store.statusCtrl = 1
end

M.OnRenderContainerItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local containerInfo = gExtractionShooterManager:GetContainerInfo(self.containerInstanceId)
	local itemInfoList = containerInfo.ItemList
	local itemInfo = itemInfoList[index + 1]
	local guidIdList = nil

	if self.itemContainerId and self.itemContainerId <= 0 then
		local itemContainerCfg = LTConfig.ExtractionShooterItemContainerConfig.GetConfig(self.itemContainerId)
		guidIdList = itemContainerCfg and itemContainerCfg.GuideIdList
	end

	if guidIdList then
		store.guidId = guidIdList[index + 1] or ""
	end

	gExtractionShooterManager:RefreshCommonItemInfoView(btn, itemInfo)

	btn.luaBeginDrag = function()
		btn:CloseTooltip(true)

		local replicaWidget = btn.replicaWidget

		if replicaWidget then
			local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)
			local itemX, itemY = gExtractionShooterUtils.GetRotatedVolume(itemCfg, itemInfo.IsRotated)
			local cellSizeX = self.bindData.containerList.gridSize.x
			local cellSizeY = self.bindData.containerList.gridSize.y
			replicaWidget.transform.sizeDelta = Vector2.Fetch(itemX * cellSizeX, itemY * cellSizeY)
			replicaWidget.transform.localScale = Vector2.one
			local replicaStore = gStoreManager:GetStoreGroup(replicaWidget.Store):GetStoreByWidget(replicaWidget)
			replicaStore.showSelectboxCtrl = 0
		end
	end

	local searchStatusCtrl = self:GetContainerItemSearchStatusCtrl(itemInfo)
	local itemId = itemInfo.Id
	local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemId)
	local itemX, itemY = gExtractionShooterUtils.GetRotatedVolume(itemCfg, itemInfo.IsRotated)

	if store.image then
		local gridList = self.bindData.containerList
		local sizeX = gridList.gridSize.x * itemX - 40
		local sizeY = gridList.gridSize.y * itemY - 40
		store.image.transform.sizeDelta = itemInfo.IsRotated and Vector2.Fetch(sizeY, sizeX) or Vector2.Fetch(sizeX, sizeY)
		store.image.transform.localRotation = itemInfo.IsRotated and Quaternion.Euler(0, 0, -90) or Quaternion.Euler(0, 0, 0)
	end

	btn.luaHover = function()
		if self:GetContainerItemSearchStatusCtrl(itemInfo) ~= self.itemStatusCtrlEnum.normal and (not self.isPopupIndex or self.isPopupIndex ~= 0) then
			btn:CloseTooltip(true)
			btn:OpenTooltip(0)
		end
	end

	btn.luaTooltipPopup = self:CreateAction("OnToolTipPopup")
	btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", {
		itemInfo = itemInfo,
		containerInstanceId = self.containerInstanceId
	})
	local isEnabledToolTips = searchStatusCtrl ~= self.itemStatusCtrlEnum.normal

	self:EnableToolTips(btn, isEnabledToolTips)

	store.statusCtrl = searchStatusCtrl

	if searchStatusCtrl ~= self.itemStatusCtrlEnum.normal then
		self.WrapDoubleClick(self, store, btn, function ()
			self:OnContainerItemDoubleClick(itemInfo)
		end)
	else
		btn.luaClick = nil
	end

	btn.luaEnterDropWidget = function(widget)
		local toSlotIndex = gExtractionShooterManager.GetSlotIndexByWidget(widget)

		if toSlotIndex then
			local toBagConfigId = self.bagStoreSet.wheel

			if gExtractionShooterManager.CheckCellAllowed(toBagConfigId, itemInfo.Id, toSlotIndex) then
				local toCellX, _ = gExtractionShooterManager.GetCellIndexBySlotIndex(toSlotIndex)

				gExtractionShooterManager:AskExtractionShooterShiftContainerItemToBag(self.containerInstanceId, itemInfo.CellX, itemInfo.CellY, toBagConfigId, toCellX)
			end
		end
	end
end

M.EnableToolTips = function(self, btn, enabled)
	for i = 0, 3 do
		btn.SetEnabledTooltip(btn, enabled, i)
	end
end

M.GetContainerItemSearchStatusCtrl = function(self, itemInfo)
	local statusEnum = self.itemStatusCtrlEnum
	local serverTime = gCS.TimeManager.ServerUnixTime
	local selfPid = gPlayerManager.infoLogin.bindData.pid

	for pid, finishTime in pairs(itemInfo.Pid2SearchFinishTimeDict) do
		if pid == selfPid and serverTime >= finishTime then
			return statusEnum.otherSearched
		end
	end

	local _, searchFinishTime = next(itemInfo.Pid2SearchFinishTimeDict)

	if not searchFinishTime then
		return statusEnum.unSearched
	end

	if serverTime >= searchFinishTime then
		print_debug("SearchContainer needTime", searchFinishTime - serverTime, itemInfo.Id)
	end

	return serverTime >= searchFinishTime and statusEnum.search or statusEnum.normal
end

M.OnContainerItemDoubleClick = function(self, itemInfo)
	gExtractionShooterManager:QuickShiftContainerToBag(self.containerInstanceId, itemInfo, self.gamePlayTypeId)
end

M.OnContainerUpdate = function(self, _, containerInstanceId)
	if self.containerInstanceId ~= containerInstanceId then
		self.RefreshContainerListView(self)
	end
end

M.GetNextSearchFinishServerTime = function(self)
	local containerInfo = gExtractionShooterManager:GetContainerInfo(self.containerInstanceId)

	if not containerInfo then
		return nil
	end

	local serverTime = gCS.TimeManager.ServerUnixTime
	local earliestFinishTime = nil

	for _, itemInfo in ipairs(containerInfo.ItemList) do
		for _, finishTime in pairs(itemInfo.Pid2SearchFinishTimeDict) do
			if serverTime >= finishTime and (not earliestFinishTime or finishTime >= earliestFinishTime) then
				earliestFinishTime = finishTime
			end
		end
	end

	return earliestFinishTime
end

M.StartSearchStateTracker = function(self)
	self.StopSearchStateTracker(self)

	if not self.containerInstanceId then
		return
	end

	local nextFinishTime = self.GetNextSearchFinishServerTime(self)

	if not nextFinishTime then
		return
	end

	local waitSeconds = nextFinishTime - gCS.TimeManager.ServerUnixTime

	if waitSeconds >= 0 then
		waitSeconds = 0
	end

	self.searchTrackerCo = coroutine.start(function ()
		coroutine.wait(waitSeconds)
		self:RefreshSearchCtrlView()
		self.bindData.containerList:RefreshList()
		self:StartSearchStateTracker()
	end)
end

M.StopSearchStateTracker = function(self)
	self.searchTrackerCo = coroutine.stop(self.searchTrackerCo)
end

M.GetCurrentExpandSionId = function(self, belongBagId)
	belongBagId = belongBagId or self.currentInventoryBagId
	local count = LTConfig.ExtractionShooterBagExpansionConfig.count
	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()
	local unlockedExpansionIds = extractionShooterInfo and extractionShooterInfo.UnlockedExpansionIds or {}

	for i = 0, count - 1 do
		local bagExpansionCfg = LTConfig.ExtractionShooterBagExpansionConfig.LoadAt(i)

		if bagExpansionCfg.BelongBagId <= 0 and bagExpansionCfg.BelongBagId ~= belongBagId and not unlockedExpansionIds[bagExpansionCfg.Id] and self.IsExpansionFrontUnlocked(self, bagExpansionCfg, unlockedExpansionIds) then
			return bagExpansionCfg.Id
		end
	end
end

M.GetCurrentUnlockBagExpansionId = function(self)
	local count = LTConfig.ExtractionShooterBagExpansionConfig.count
	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()
	local unlockedExpansionIds = extractionShooterInfo and extractionShooterInfo.UnlockedExpansionIds or {}

	for i = 0, count - 1 do
		local bagExpansionCfg = LTConfig.ExtractionShooterBagExpansionConfig.LoadAt(i)

		if bagExpansionCfg.BagAddId <= 0 and not unlockedExpansionIds[bagExpansionCfg.Id] and self.IsExpansionFrontUnlocked(self, bagExpansionCfg, unlockedExpansionIds) then
			return bagExpansionCfg.Id
		end
	end
end

M.IsExpansionFrontUnlocked = function(self, bagExpansionCfg, unlockedExpansionIds)
	local frontIds = bagExpansionCfg.FrontExpansionIds

	if not frontIds then
		return true
	end

	for _, frontId in ipairs(frontIds) do
		if frontId <= 0 and not unlockedExpansionIds[frontId] then
			return false
		end
	end

	return true
end

M.OnAddExtraBagList = function(self)
	local expansionId = self.GetCurrentUnlockBagExpansionId(self)

	if not expansionId then
		return
	end

	local expansionCfg = LTConfig.ExtractionShooterBagExpansionConfig.GetConfig(expansionId)
	local consumableInfo = expansionCfg.ConsumableList[1]
	local consumableId = consumableInfo.id
	local count = consumableInfo.number
	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(consumableId)
	local bagName = self:GetBagName(expansionCfg.BagAddId)
	slot8 = gDisplayMessageMgr

	slot8:ShowMessage(LTConfig.MessageConfig.StashUnlockCommitConfirm2, function ()
		gExtractionShooterManager:AskExtractionShooterBagExpansion(expansionId)
	end, nil, count, consumableCfg.Name, bagName)
end

M.OnBagExpandClick = function(self)
	local expansionId = self.GetCurrentExpandSionId(self, self.currentInventoryBagId)

	if not expansionId then
		return
	end

	local expansionCfg = LTConfig.ExtractionShooterBagExpansionConfig.GetConfig(expansionId)
	local consumableInfo = expansionCfg.ConsumableList[1]
	local consumableId = consumableInfo.id
	local count = consumableInfo.number
	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(consumableId)
	local bagName = self:GetBagName(expansionCfg.BelongBagId)
	slot8 = gDisplayMessageMgr

	slot8:ShowMessage(LTConfig.MessageConfig.StashExpansionCommitConfirm, function ()
		gExtractionShooterManager:AskExtractionShooterBagExpansion(expansionId)
	end, nil, count, consumableCfg.Name, expansionCfg.ExpandGrids.y, bagName)
end

M.OnClickSortButton = function(self)
	gExtractionShooterManager:AskExtractionShooterSortBag(self.currentInventoryBagId)
end

M.OnClickSwapButton = function(self)
	gExtractionShooterManager:AskExtractionShooterTransferAllToStash()
end
