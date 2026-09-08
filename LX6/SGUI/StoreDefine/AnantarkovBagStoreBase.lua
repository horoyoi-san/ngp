-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovBagStoreBase.lua
-- Decompiled from: 01609_AnantarkovBagStoreBase.lua_447a6f99e459.luajit

local RightClickMenu = {}
C_AnantarkovBagStoreBase = DefClass("C_AnantarkovBagStoreBase", C_AnantarkovBagStoreBase, C_StoreGroup, RightClickMenu)
local M = C_AnantarkovBagStoreBase

M.GetCanPlaceBagAndContainerId = function(self, uGridList)
	return self.currentInventoryBagId
end

M.CheckCanPlaceOverlapBlocked = function(self, overlaps)
	return false
end

M.GetBagListWidget = function(self, bagConfigId)
	return nil
end

M.OnBeforeRefreshCommonBagListView = function(self, bagConfigId)
end

M.GetBagListItemSize = function(self, itemX, itemY, capacityX, capacityY)
	return Vector2.Fetch(itemX, itemY)
end

M.SetupBagListDragOut = function(self, bagList, bagConfigId, itemInfoList)
end

M.SetupBagListExtraCallbacks = function(self, bagList, bagConfigId, itemInfoList)
end

M.OnCanTransfer = function(self, srcList, srcIndex, dstList, targetIndex, dstPos)
	return true
end

M.AfterRefreshCommonBagListView = function(self, bagList, bagConfigId, itemInfoList)
end

M.CheckCanRefreshBagExpansionView = function(self)
	return true
end

M.GetBagGamePlayTypeId = function(self)
	return nil
end

M.DecorateExpansionBagViewDataList = function(self, viewDataList, canAddBagMaxCount)
	return viewDataList
end

M.GetExpansionBagDisplayIndex = function(self, data, index)
	return index + 1
end

M.OnSelectInventoryBag = function(self, bagId)
end

M.OnRenderExtraStoreBagExtraItem = function(self, btn, data)
end

M.IsSlotBag = function(self, bagConfigId)
	return bagConfigId ~= self.bagStoreSet.strengthen or bagConfigId ~= self.bagStoreSet.shield or bagConfigId ~= self.bagStoreSet.wheel
end

M.GetCanPlaceSrcItemInfo = function(self, srcList, srcIndex)
	local bagId, containerId = self.GetCanPlaceBagAndContainerId(self, srcList)
	local list = nil

	if bagId then
		list = gExtractionShooterManager.GetBagInfoByConfigId(bagId).ItemInfoList
	elseif containerId then
		local containerInfo = gExtractionShooterManager:GetContainerInfo(containerId)
		list = containerInfo and containerInfo.ItemList
	end

	return list and list[srcIndex + 1] or nil
end

M.GetOrBuildCanPlaceCtx = function(self, uGridList)
	local bagId, containerId = self:GetCanPlaceBagAndContainerId(uGridList)
	self._dragCanPlaceCtx = self._dragCanPlaceCtx or {}

	if bagId then
		if self.IsSlotBag(self, bagId) then
			return nil
		end

		local ctx = self._dragCanPlaceCtx[bagId]

		if not ctx then
			ctx = gExtractionShooterUtils.BuildBagContextByConfigId(bagId)
			self._dragCanPlaceCtx[bagId] = ctx
		end

		return ctx
	elseif containerId then
		local key = "c" .. tostring(containerId)
		local ctx = self._dragCanPlaceCtx[key]

		if not ctx then
			local containerInfo = gExtractionShooterManager:GetContainerInfo(containerId)

			if not containerInfo then
				return nil
			end

			local containerCfg = LTConfig.ExtractionShooterItemContainerConfig.GetConfig(containerInfo.CfgId)
			ctx = gExtractionShooterUtils.BuildBagContext(containerCfg.Capacity.x, containerCfg.Capacity.y, containerInfo.ItemList)
			self._dragCanPlaceCtx[key] = ctx
		end

		return ctx
	end

	return nil
end

M.OnCheckCanPlace = function(self, srcList, srcIndex, dstList, cellPos, _)
	local srcItemInfo = self.GetCanPlaceSrcItemInfo(self, srcList, srcIndex)

	if not srcItemInfo then
		return true
	end

	local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(srcItemInfo.Id)

	if not itemCfg then
		return true
	end

	local isRotated = srcItemInfo.IsRotated
	local toBagId = self.GetCanPlaceBagAndContainerId(self, dstList)

	if toBagId then
		if not gExtractionShooterManager.CheckCellAllowed(toBagId, srcItemInfo.Id) then
			return false
		end

		if self.IsSlotBag(self, toBagId) then
			return true
		end
	end

	local dstCtx = self.GetOrBuildCanPlaceCtx(self, dstList)

	if not dstCtx then
		return true
	end

	local Ok = LTConfig.MessageConfig.Ok
	local cellX = math.floor(cellPos.x + 0.5)
	local cellY = math.floor(cellPos.y + 0.5)

	if srcList ~= dstList then
		local _, overlaps = gExtractionShooterUtils.TryGetOverlapItemsByShiftItem(dstCtx, cellX, cellY, itemCfg, isRotated, srcItemInfo)
		local err = gExtractionShooterUtils.CheckShiftItemInBag(dstCtx, srcItemInfo, itemCfg, isRotated, cellX, cellY, overlaps)

		return err ~= Ok
	end

	local srcCtx = self.GetOrBuildCanPlaceCtx(self, srcList)

	if not srcCtx then
		return gExtractionShooterUtils.CheckCanAddItemByCellWithCfg(dstCtx, cellX, cellY, itemCfg, isRotated)
	end

	local _, overlaps = gExtractionShooterUtils.TryGetOverlapItemsByShiftItem(dstCtx, cellX, cellY, itemCfg, isRotated)

	if self.CheckCanPlaceOverlapBlocked(self, overlaps) then
		return false
	end

	local err = gExtractionShooterUtils.CheckShiftItemToOtherBag(srcCtx, srcItemInfo, itemCfg, isRotated, dstCtx, cellX, cellY, overlaps)

	return err ~= Ok
end

M.RefreshCommonBagListView = function(self, bagConfigId)
	self._dragCanPlaceCtx = nil

	self.OnBeforeRefreshCommonBagListView(self, bagConfigId)

	local bagList = self.GetBagListWidget(self, bagConfigId)

	if not bagList then
		return
	end

	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	local x, y = gExtractionShooterManager.GetBagCapacity(bagConfigId)
	local height = bagList.rowSpacing * (y - 1) + bagList.gridSize.y * y
	local widthExtra = (bagInfo.BagId ~= self.bagStoreSet.normal or bagInfo.BagId ~= self.currentInventoryBagId) and self.BAG_LIST_WIDTH_EXTRA or 0
	local width = bagList.colSpacing * (x - 1) + bagList.gridSize.x * x + widthExtra
	local itemInfoList = bagInfo.ItemInfoList

	if bagList.maxHeight <= 0 then
		height = math.min(height, bagList.maxHeight)
	end

	bagList.transform.sizeDelta = Vector2.Fetch(width, height)

	bagList.onGetItemPos = function(index)
		local itemInfo = itemInfoList[index + 1]

		return Vector2.Fetch(itemInfo.CellX, itemInfo.CellY)
	end

	bagList.onItemTransfer = self.CreateAction(self, "OnItemTransfer")

	bagList.onItemRotate = function(index, newItemSize, newPos)
		local itemInfo = itemInfoList[index + 1]
		local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)
		local isRotated = newItemSize.x == itemCfg.Volume.x

		if itemInfo.IsRotated == isRotated or newPos.x == itemInfo.CellX or newPos.y == itemInfo.CellY then
			gExtractionShooterManager:AskExtractionShooterShiftItem(bagConfigId, itemInfo.CellX, itemInfo.CellY, bagConfigId, newPos.x, newPos.y, isRotated)
		end
	end

	bagList.onItemPosChange = function(index, newPos)
		local itemInfo = itemInfoList[index + 1]

		gExtractionShooterManager:AskExtractionShooterShiftItem(bagConfigId, itemInfo.CellX, itemInfo.CellY, bagConfigId, newPos.x, newPos.y, itemInfo.IsRotated)
	end

	bagList.onGetItemSize = function(index)
		if bagConfigId ~= self.bagStoreSet.strengthen or bagConfigId ~= self.bagStoreSet.shield then
			return Vector2.Fetch(1, 1)
		else
			local itemInfo = itemInfoList[index + 1]
			local itemId = itemInfo.Id
			local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemId)
			local itemX, itemY = gExtractionShooterUtils.GetRotatedVolume(itemCfg, itemInfo.IsRotated)

			return self:GetBagListItemSize(itemX, itemY, x, y)
		end
	end

	self.SetupBagListDragOut(self, bagList, bagConfigId, itemInfoList)
	self.SetupBagListExtraCallbacks(self, bagList, bagConfigId, itemInfoList)

	bagList.onCheckCanPlace = function(srcList, srcIndex, dstList, cellPos, isRotated)
		return self:OnCheckCanPlace(srcList, srcIndex, dstList, cellPos, isRotated)
	end

	bagList.onCanTransfer = function(srcList, srcIndex, dstList, targetIndex, dstPos)
		return self:OnCanTransfer(srcList, srcIndex, dstList, targetIndex, dstPos)
	end

	bagList.rowCount = y

	bagList.SetList(bagList, #itemInfoList)
	self.AfterRefreshCommonBagListView(self, bagList, bagConfigId, itemInfoList)
end

M.RefreshBagExpansionView = function(self)
	if not self.CheckCanRefreshBagExpansionView(self) then
		return
	end

	self.bindData.showStorageListCtrl = 1
	self.expansionBagViewDataList = self:GetExpansionBagViewDataList()

	self.bindData.extraStoreBagList.onGetTIndex = function(index)
		local data = self.expansionBagViewDataList[index + 1]

		return data.tIndex
	end

	self.bindData.extraStoreBagList:SetActive(true)
	self.bindData.extraStoreBagList:SetSimpleList(#self.expansionBagViewDataList)
end

M.BuildUnlockedExpansionBagViewDataList = function(self)
	local count = LTConfig.ExtractionShooterBagExpansionConfig.count
	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()
	local unlockedExpansionIds = extractionShooterInfo and extractionShooterInfo.UnlockedExpansionIds or {}
	local gamePlayTypeId = self:GetBagGamePlayTypeId()
	local viewDataList = {}
	local canAddBagMaxCount = 0

	table.insert(viewDataList, {
		["QBmeg "] = 0,
		["a\\x9f\\x8a\\x86Y"] = 0,
		bagId = self.bagStoreSet.inventory
	})

	for i = 0, count - 1 do
		local bagExpansionCfg = LTConfig.ExtractionShooterBagExpansionConfig.LoadAt(i)

		if bagExpansionCfg.BagAddId <= 0 then
			local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagExpansionCfg.BagAddId)

			if bagCfg.GameplayType ~= gamePlayTypeId then
				canAddBagMaxCount = canAddBagMaxCount + 1

				if unlockedExpansionIds[bagExpansionCfg.Id] then
					table.insert(viewDataList, {
						["a\\x9f\\x8a\\x86Y"] = 0,
						id = bagExpansionCfg.Id,
						bagId = bagExpansionCfg.BagAddId,
						realIndex = #viewDataList
					})
				end
			end
		end
	end

	return viewDataList, canAddBagMaxCount
end

M.GetExpansionBagViewDataList = function(self)
	local viewDataList, canAddBagMaxCount = self.BuildUnlockedExpansionBagViewDataList(self)

	return self.DecorateExpansionBagViewDataList(self, viewDataList, canAddBagMaxCount)
end

M.OnRenderExtraStoreBagItem = function(self, btn, index)
	local data = self.expansionBagViewDataList[index + 1]

	if data.tIndex ~= 0 then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		btn.isSelected = data.bagId ~= self.currentInventoryBagId
		local displayIndex = self:GetExpansionBagDisplayIndex(data, index)
		store.index = displayIndex
		store.pcKey = displayIndex
		store.name = self:GetBagName(data.bagId)

		btn.luaClick = function()
			if btn.isSelected then
				return
			end

			self:OnSelectInventoryBag(data.bagId)
		end

		local pcKey = 15 + index

		btn:SetPCKeyInfoWithOutTip(pcKey)
	else
		self.OnRenderExtraStoreBagExtraItem(self, btn, data)
	end
end

M.GetBagName = function(self, bagConfigId)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	local bagId = bagInfo.BagId
	local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagId)

	return bagCfg.IsShow and bagCfg.Name or ""
end

M.WrapDoubleClick = function(self, store, btn, callback)
	btn.luaClick = function()
		if store.waitForClick then
			store.waitForClick = false
			store.waitForClickCo = coroutine.stop(store.waitForClickCo)

			if callback then
				callback()
			end
		else
			store.waitForClick = true
			store.waitForClickCo = coroutine.start(function ()
				coroutine.wait(0.2)

				store.waitForClick = false
			end)
		end
	end
end

M.OnToolTipPopup = function(self, btn, isPopUp, popupIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.showSelectboxCtrl = isPopUp and 1 or 0

	if isPopUp then
		self.isPopupIndex = popupIndex
	else
		self.isPopupIndex = nil
	end
end

M.OnRenderPopupItemInfo = function(self, store, args)
	local itemInfo = args.itemInfo
	local itemId = itemInfo.Id
	store.price = gExtractionShooterManager.GetItemSystemPrice(itemId)
	store.iconId = gExtractionShooterManager.GetItemIconId(itemId)
	store.name = gExtractionShooterManager.GetItemName(itemId)
end

M.RefreshBagItemImage = function(self, store, bagConfigId, itemInfo, itemX, itemY)
	if not store.image then
		return
	end

	local gridList = self:GetBagListWidget(bagConfigId)
	local sizeX = gridList.gridSize.x * itemX - 40
	local sizeY = gridList.gridSize.y * itemY - 40
	store.image.transform.sizeDelta = itemInfo.IsRotated and Vector2.Fetch(sizeY, sizeX) or Vector2.Fetch(sizeX, sizeY)
	store.image.transform.localRotation = itemInfo.IsRotated and Quaternion.Euler(0, 0, -90) or Quaternion.Euler(0, 0, 0)
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
end

RightClickMenu.GetRightClickButtonDataList = function(args)
	local gamePlayTypeId = args.gamePlayTypeId
	local itemInfo = args.itemInfo
	local activeEndMode = args.activeEndMode
	local srcBagConfigId = args.srcBagConfigId
	local srcContainerInstanceId = args.srcContainerInstanceId
	local buttonIdList = {}
	local count = LTConfig.ExtractionShooterRightClickButtonConfig.count
	local isSettle = activeEndMode
	local isInSide = gExtractionShooterManager.CheckInGame() and not isSettle
	local isOutSide = not isInSide and not isSettle

	for i = 0, count - 1 do
		local buttonCfg = LTConfig.ExtractionShooterRightClickButtonConfig.LoadAt(i)

		if buttonCfg.IsPermanent then
			if isSettle then
				if buttonCfg.IsSettle then
					table.insert(buttonIdList, buttonCfg.Id)
				end
			elseif isInSide then
				if buttonCfg.IsInside then
					table.insert(buttonIdList, buttonCfg.Id)
				end
			elseif isOutSide and buttonCfg.IsOutside then
				table.insert(buttonIdList, buttonCfg.Id)
			end
		end
	end

	local id = itemInfo.Id
	local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(id)
	local itemTypeCfg = LTConfig.ExtractionShooterItemTypeConfig.GetConfig(itemCfg.Type)
	local buttonConfig = LTConfig.ExtractionShooterRightClickButtonConfig
	local bagConfig = LTConfig.ExtractionShooterBagConfig
	local buttonMap = {
		{
			["K\\xa7\\xa7\\xa3\\xb2"] = "\\xfa\\xda.(\\xfd",
			buttonId = buttonConfig.CanSell
		},
		{
			["K\\xa7\\xa7\\xa3\\xb2"] = "?I\\x9f\\xbb\\x90D",
			buttonId = buttonConfig.CanUse
		},
		{
			["K\\xa7\\xa7\\xa3\\xb2"] = "`Fb]O=6",
			buttonId = buttonConfig.CanTakeOn
		},
		{
			["K\\xa7\\xa7\\xa3\\xb2"] = "p[\\xc0\\x89\\x85\\xbd+\\xcf\\xee",
			buttonId = buttonConfig.CanTakeOff
		},
		{
			["K\\xa7\\xa7\\xa3\\xb2"] = "Lw\\xa2UY\\xab\\xd0Rfv{X",
			buttonId = buttonConfig.CanBuyBullet
		},
		{
			["K\\xa7\\xa7\\xa3\\xb2"] = "\\xfa\\xda06\\xfa",
			buttonId = buttonConfig.CanMark
		},
		{
			["K\\xa7\\xa7\\xa3\\xb2"] = "`FbZA=",
			buttonId = buttonConfig.CanSource
		}
	}

	for _, entry in ipairs(buttonMap) do
		if itemTypeCfg[entry.field] then
			local buttonId = entry.buttonId
			local buttonCfg = buttonConfig.GetConfig(buttonId)

			if buttonCfg then
				if isSettle then
					if buttonCfg.IsSettle then
						table.insert(buttonIdList, buttonCfg.Id)
					end
				elseif isInSide then
					if buttonCfg.IsInside then
						table.insert(buttonIdList, buttonCfg.Id)
					end
				elseif isOutSide and buttonCfg.IsOutside then
					table.insert(buttonIdList, buttonCfg.Id)
				end
			end
		end
	end

	table.sort(buttonIdList, function (id1, id2)
		local buttonCfg1 = buttonConfig.GetConfig(id1)
		local buttonCfg2 = buttonConfig.GetConfig(id2)

		if buttonCfg1.Weight == buttonCfg2.Weight then
			return buttonCfg1.Weight <= buttonCfg2.Weight
		end

		return id1 <= id2
	end)

	local visibleButtonIdList = {}

	for _, buttonId in ipairs(buttonIdList) do
		if buttonId ~= buttonConfig.Split then
			if itemInfo.StackCount <= 1 then
				table.insert(visibleButtonIdList, buttonId)
			end
		elseif buttonId ~= buttonConfig.Extract then
			local fundAmount = gExtractionShooterManager.GetFundAmount(gamePlayTypeId)
			local itemTotalPrice = gExtractionShooterManager.GetItemTotalPrice(itemInfo)

			if itemCfg.ConsumableId <= 0 and itemCfg.CanBringOut and itemTotalPrice < fundAmount then
				table.insert(visibleButtonIdList, buttonId)
			end
		elseif buttonId ~= buttonConfig.Carry then
			if srcBagConfigId ~= bagConfig.Inventory or srcContainerInstanceId then
				table.insert(visibleButtonIdList, buttonId)
			end
		elseif buttonId ~= buttonConfig.PutBack then
			if args.checkCanShowPutBack and args.checkCanShowPutBack() and srcBagConfigId == bagConfig.Inventory and not srcContainerInstanceId then
				table.insert(visibleButtonIdList, buttonId)
			end
		elseif buttonId ~= buttonConfig.PutInSafety then
			if srcBagConfigId == bagConfig.SafeBox then
				table.insert(visibleButtonIdList, buttonId)
			end
		elseif buttonId ~= buttonConfig.CanTakeOn then
			if not gExtractionShooterManager.CheckIsSlotGroupBag(srcBagConfigId) then
				table.insert(visibleButtonIdList, buttonId)
			end
		elseif buttonId ~= buttonConfig.CanTakeOff then
			if gExtractionShooterManager.CheckIsSlotGroupBag(srcBagConfigId) then
				table.insert(visibleButtonIdList, buttonId)
			end
		elseif buttonId ~= buttonConfig.CanRotate then
			if not gExtractionShooterManager.CheckIsSlotGroupBag(srcBagConfigId) and itemCfg.Volume.x == itemCfg.Volume.y and args.checkCanRotate and args.checkCanRotate() then
				table.insert(visibleButtonIdList, buttonId)
			end
		else
			table.insert(visibleButtonIdList, buttonId)
		end
	end

	local targetViewDataList = {}

	for i, buttonId in ipairs(visibleButtonIdList) do
		if i <= 1 then
			table.insert(targetViewDataList, {
				["a\\x9f\\x8a\\x86Y"] = 1
			})
		end

		table.insert(targetViewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			id = buttonId
		})
	end

	return targetViewDataList
end

RightClickMenu.SetupRightClickButtonList = function(store, oriButton, buttonDataList, getArgs, onExtra)
	store.list.onGetTIndex = function(index)
		local data = buttonDataList[index + 1]

		return data.tIndex
	end

	store.list.luaSimpleRenderItem = function(btn, index)
		local data = buttonDataList[index + 1]

		if data.tIndex ~= 0 then
			slot3 = gStoreManager
			slot3 = slot3:GetStoreGroup(btn.Store)
			local childStore = slot3:GetStoreByWidget(btn)
			local buttonCfg = LTConfig.ExtractionShooterRightClickButtonConfig.GetConfig(data.id)
			childStore.name = buttonCfg.Name

			btn.luaClick = function()
				oriButton:CloseTooltip(true)
				RightClickMenu.HandleCommonRightClickButton(data, getArgs, onExtra)
			end
		end
	end

	local templateCount = 0
	local lineCount = 0

	for _, buttonData in ipairs(buttonDataList) do
		if buttonData.tIndex ~= 0 then
			templateCount = templateCount + 1
		elseif buttonData.tIndex ~= 1 then
			lineCount = lineCount + 1
		end
	end

	store.list:SetSimpleList(#buttonDataList)
end

RightClickMenu.HandleCommonRightClickButton = function(data, getArgs, onExtra)
	local buttonId = data.id
	local buttonConfig = LTConfig.ExtractionShooterRightClickButtonConfig
	local args = getArgs()
	local srcBagConfigId = args.srcBagConfigId
	local targetBagConfigId = args.targetBagConfigId
	local srcContainerInstanceId = args.srcContainerInstanceId
	local containerInstanceId = args.containerInstanceId
	local gamePlayTypeId = args.gamePlayTypeId
	local itemInfo = args.itemInfo
	local bagStoreSet = gExtractionShooterManager.GetBagStoreSet(gamePlayTypeId)

	if buttonId ~= buttonConfig.Discard then
		if srcBagConfigId then
			gExtractionShooterManager:AskExtractionShooterRemoveItem(srcBagConfigId, itemInfo.CellX, itemInfo.CellY)
		elseif srcContainerInstanceId then
			gExtractionShooterManager:AskExtractionShooterRemoveContainerItem(srcContainerInstanceId, itemInfo.CellX, itemInfo.CellY)
		end
	elseif buttonId ~= buttonConfig.CanTakeOn then
		local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)
		local toBagConfigId = nil
		local wheelWeaponBagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagStoreSet.wheel)
		local strengthenSlotBagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagStoreSet.strengthen)
		local shieldSlotBagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagStoreSet.shield)
		local itemType = itemCfg.Type

		if table.find(wheelWeaponBagCfg.AllowedItemTypes, itemType) then
			toBagConfigId = wheelWeaponBagCfg.Id
		elseif table.find(strengthenSlotBagCfg.AllowedItemTypes, itemType) then
			toBagConfigId = strengthenSlotBagCfg.Id
		elseif table.find(shieldSlotBagCfg.AllowedItemTypes, itemType) then
			toBagConfigId = shieldSlotBagCfg.Id
		end

		if toBagConfigId then
			local toCellX, toCellY = gExtractionShooterManager.TryGetFreeCellIndexByConfigId(toBagConfigId, itemInfo.Id, itemInfo)

			if toCellX then
				if srcBagConfigId then
					gExtractionShooterManager:AskExtractionShooterShiftItem(srcBagConfigId, itemInfo.CellX, itemInfo.CellY, toBagConfigId, toCellX, toCellY)
				elseif srcContainerInstanceId then
					gExtractionShooterManager:AskExtractionShooterShiftContainerItemToBag(srcContainerInstanceId, itemInfo.CellX, itemInfo.CellY, toBagConfigId, toCellX, toCellY)
				end
			else
				local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(toBagConfigId)
				local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagInfo.BagId)

				gDisplayMessageMgr:ShowMessageContent(LTConfig.ExtractionShooterConfig.BagCellFullTips:format(bagCfg.Name))
			end
		end
	elseif buttonId ~= buttonConfig.CanTakeOff then
		local toBagConfigId = bagStoreSet.normal
		local toCellX, toCellY = gExtractionShooterManager.TryGetFreeCellIndexByConfigId(toBagConfigId, itemInfo.Id, itemInfo)

		if toCellX then
			gExtractionShooterManager:AskExtractionShooterShiftItem(srcBagConfigId, itemInfo.CellX, itemInfo.CellY, toBagConfigId, toCellX, toCellY)
		else
			local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(toBagConfigId)
			local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagInfo.BagId)

			gDisplayMessageMgr:ShowMessageContent(LTConfig.ExtractionShooterConfig.BagCellFullTips:format(bagCfg.Name))
		end
	elseif buttonId ~= buttonConfig.Carry then
		if containerInstanceId then
			gExtractionShooterManager:QuickShiftContainerToBag(containerInstanceId, itemInfo)
		else
			gExtractionShooterManager:QuickShiftBagToBagByPrice(srcBagConfigId, itemInfo.CellX, itemInfo.CellY, itemInfo, gamePlayTypeId)
		end
	elseif buttonId ~= buttonConfig.PutInSafety then
		if srcContainerInstanceId then
			local toBagConfigId = bagStoreSet.safebox
			local toCellX, toCellY = gExtractionShooterManager.TryGetFreeCellIndexByConfigId(toBagConfigId, itemInfo.Id, itemInfo)

			if toCellX then
				gExtractionShooterManager:AskExtractionShooterShiftContainerItemToBag(srcContainerInstanceId, itemInfo.CellX, itemInfo.CellY, toBagConfigId, toCellX, toCellY)
			else
				local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(toBagConfigId)
				local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagInfo.BagId)

				gDisplayMessageMgr:ShowMessageContent(LTConfig.ExtractionShooterConfig.BagCellFullTips:format(bagCfg.Name))
			end
		else
			gExtractionShooterManager:QuickShiftBagToBag(srcBagConfigId, itemInfo.CellX, itemInfo.CellY, itemInfo, bagStoreSet.safebox)
		end
	elseif buttonId ~= buttonConfig.CanRotate then
		if srcContainerInstanceId then
			local isRotated = not itemInfo.IsRotated

			gExtractionShooterManager:AskExtractionShooterShiftContainerItemToBag(srcContainerInstanceId, itemInfo.CellX, itemInfo.CellY, srcContainerInstanceId, itemInfo.CellX, itemInfo.CellY, isRotated)
		elseif srcBagConfigId then
			local isRotated = not itemInfo.IsRotated

			gExtractionShooterManager:AskExtractionShooterShiftItem(srcBagConfigId, itemInfo.CellX, itemInfo.CellY, srcBagConfigId, itemInfo.CellX, itemInfo.CellY, isRotated)
		end
	elseif onExtra then
		onExtra(data)
	end
end
