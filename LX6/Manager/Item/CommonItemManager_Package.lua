-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_Package.lua
-- Decompiled from: 02209_CommonItemManager_Package.lua_381e0801c130.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local ConsumableTabConfig = LTConfig.ConsumableTabConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local MessageConfig = LTConfig.MessageConfig
local UnitState = UX.Game.TwoDimConfig.UnitState
local MapentranceConfig = LTConfig.MapentranceConfig
local BAG_CONFIG_ID = LTConfig.ExtractionShooterBagConfig
local DecorationConfig = LTConfig.DecorationConfig
local M = C_CommonItemManager
M.RED_DOT_BATCH_SIZE = 20
M.RED_DOT_MIN_INTERVAL = 1

M.GetParentTabId = function(self, cfg)
	return cfg and cfg.parentTab or 0
end

M.OnInitPackage = function(self)
	self.OtherItemType = {}
	self.redDotPendingList = {}
	self.redDotTimer = nil

	self.InitPackItem(self)

	for i = 0, ConsumableTypeConfig.count - 1 do
		local typeCfg = ConsumableTypeConfig.LoadAt(i)

		if typeCfg.StackMaxCount ~= 0 then
			self.OtherItemType[typeCfg.Id] = true
		end
	end
end

M.InitPackItem = function(self)
	self.packItems = {}

	self.InitSharedItemMemory(self)

	self.realPackItemDict = {}
	self.weaponPackItemDict = {}
	self.equippedDecorationPackItemDict = {}
	self.packItemDict = setmetatable({}, {
		__index = function (_, uniqueId)
			return self:GetPackItemDictValue(uniqueId)
		end,
		__newindex = function (_, uniqueId, packItem)
			self:SetPackItemDictValue(uniqueId, packItem)
		end
	})
	self.packTabItems = {}
	self.packTabChildren = {}
	self.packTabParent = {}

	for i = 0, ConsumableTabConfig.count - 1 do
		local cfg = ConsumableTabConfig.LoadAt(i)
		self.packTabItems[cfg.Id] = {}
		self.packTabChildren[cfg.Id] = {}
	end

	for i = 0, ConsumableTabConfig.count - 1 do
		local cfg = ConsumableTabConfig.LoadAt(i)
		local parentTabId = self.GetParentTabId(self, cfg)
		self.packTabParent[cfg.Id] = parentTabId

		if parentTabId <= 0 and self.packTabChildren[parentTabId] then
			table.insert(self.packTabChildren[parentTabId], cfg.Id)
		end
	end

	self.fishPackItemDict = {}
end

M.InitSharedItemMemory = function(self)
	self.sharedItemMemory = {
		["\\xcf\\xde+\\xff"] = 0,
		uniqueIdItems = {},
		templateIdItems = {},
		templateIdCounts = {}
	}
end

M.GetSharedItemMemory = function(self)
	if not self.sharedItemMemory then
		self.InitSharedItemMemory(self)
	end

	return self.sharedItemMemory
end

M.MarkSharedItemMemoryDirty = function(self)
	local memory = self:GetSharedItemMemory()
	memory.version = (memory.version or 0) + 1
end

M.InsertSharedPackItemByPackOrder = function(self, items, packItem)
	local packOrder = {}

	for i = 1, #self.packItems do
		local item = self.packItems[i]
		packOrder[item] = i

		if item.UniqueId == nil then
			packOrder[item.UniqueId] = i
		end
	end

	local insertOrder = packOrder[packItem] or packOrder[packItem.UniqueId] or #self.packItems + 1

	for i = 1, #items do
		local item = items[i]
		local itemOrder = packOrder[item] or packOrder[item.UniqueId] or #self.packItems + i

		if insertOrder >= itemOrder then
			table.insert(items, i, packItem)

			return
		end
	end

	table.insert(items, packItem)
end

M.AddSharedPackItem = function(self, packItem)
	if not packItem or packItem.UniqueId ~= nil or packItem.TemplateId ~= nil then
		return
	end

	local memory = self.GetSharedItemMemory(self)

	if memory.uniqueIdItems[packItem.UniqueId] then
		self.RemoveSharedPackItem(self, memory.uniqueIdItems[packItem.UniqueId])
	end

	local templateId = packItem.TemplateId
	memory.uniqueIdItems[packItem.UniqueId] = packItem
	memory.templateIdItems[templateId] = memory.templateIdItems[templateId] or {}

	if self._sharedBatchMode then
		table.insert(memory.templateIdItems[templateId], packItem)
	else
		self.InsertSharedPackItemByPackOrder(self, memory.templateIdItems[templateId], packItem)
	end

	memory.templateIdCounts[templateId] = (memory.templateIdCounts[templateId] or 0) + (packItem.Count or 0)

	self:MarkSharedItemMemoryDirty()
end

M.RemoveSharedPackItem = function(self, packItem)
	if not packItem or packItem.UniqueId ~= nil or packItem.TemplateId ~= nil then
		return
	end

	local memory = self.GetSharedItemMemory(self)
	local templateId = packItem.TemplateId
	memory.uniqueIdItems[packItem.UniqueId] = nil
	local items = memory.templateIdItems[templateId]

	if items then
		for i = #items, 1, -1 do
			if items[i] ~= packItem or items[i].UniqueId ~= packItem.UniqueId then
				table.remove(items, i)

				break
			end
		end

		if #items ~= 0 then
			memory.templateIdItems[templateId] = nil
		end
	end

	local count = (memory.templateIdCounts[templateId] or 0) - (packItem.Count or 0)
	memory.templateIdCounts[templateId] = count <= 0 and count or nil

	self:MarkSharedItemMemoryDirty()
end

M.UpdateSharedPackItem = function(self, packItem, prevTemplateId, prevCount)
	if not packItem or packItem.UniqueId ~= nil or packItem.TemplateId ~= nil then
		return
	end

	local memory = self:GetSharedItemMemory()
	local oldTemplateId = prevTemplateId or packItem.TemplateId
	local oldCount = prevCount or 0
	local newTemplateId = packItem.TemplateId
	local newCount = packItem.Count or 0

	if oldTemplateId == newTemplateId then
		local oldItems = memory.templateIdItems[oldTemplateId]

		if oldItems then
			for i = #oldItems, 1, -1 do
				if oldItems[i] ~= packItem or oldItems[i].UniqueId ~= packItem.UniqueId then
					table.remove(oldItems, i)

					break
				end
			end

			if #oldItems ~= 0 then
				memory.templateIdItems[oldTemplateId] = nil
			end
		end

		memory.templateIdItems[newTemplateId] = memory.templateIdItems[newTemplateId] or {}

		self:InsertSharedPackItemByPackOrder(memory.templateIdItems[newTemplateId], packItem)
	end

	memory.uniqueIdItems[packItem.UniqueId] = packItem
	local oldTemplateCount = (memory.templateIdCounts[oldTemplateId] or 0) - oldCount
	memory.templateIdCounts[oldTemplateId] = oldTemplateCount <= 0 and oldTemplateCount or nil
	memory.templateIdCounts[newTemplateId] = (memory.templateIdCounts[newTemplateId] or 0) + newCount

	self:MarkSharedItemMemoryDirty()
end

M.RebuildSharedItemMemory = function(self)
	self.InitSharedItemMemory(self)

	self._sharedBatchMode = true

	for i = 1, #self.packItems do
		self.AddSharedPackItem(self, self.packItems[i])
	end

	self._sharedBatchMode = false
end

M.GetSharedPackItemByUniqueId = function(self, uniqueId)
	local memory = self:GetSharedItemMemory()

	return uniqueId and memory.uniqueIdItems[uniqueId] or nil
end

M.GetSharedPackItemByTemplateId = function(self, templateId)
	local memory = self:GetSharedItemMemory()
	local items = templateId and memory.templateIdItems[templateId] or nil

	return items and items[1] or nil
end

M.GetSharedPackItemsByTemplateId = function(self, templateId)
	local memory = self:GetSharedItemMemory()

	return templateId and memory.templateIdItems[templateId] or nil
end

M.GetSharedPackItemNum = function(self, templateId)
	local memory = self:GetSharedItemMemory()

	return templateId and memory.templateIdCounts[templateId] or 0
end

M.GetSharedItemMemoryVersion = function(self)
	local memory = self:GetSharedItemMemory()

	return memory.version or 0
end

M.GetWeaponPackTabId = function(self)
	return ConsumableTabConfig.Weapon
end

M.IsWeaponPackTab = function(self, tabId)
	local weaponTabId = self:GetWeaponPackTabId()

	return weaponTabId == nil and weaponTabId == 0 and tabId ~= weaponTabId
end

M.GetQuickItemPackTabId = function(self)
	return ConsumableTabConfig.QuickItem
end

M.IsQuickItemPackTab = function(self, tabId)
	local quickItemTabId = self:GetQuickItemPackTabId()

	return quickItemTabId == nil and quickItemTabId == 0 and tabId ~= quickItemTabId
end

M.CheckIsQuickItem = function(self, itemId)
	local sceneitemCfg = self.GetSceneitemCfg and self:GetSceneitemCfg(itemId) or nil

	if sceneitemCfg then
		return not self.CheckIsWeaponCategory(self, sceneitemCfg.Category)
	end

	local consumableCfg = self.GetSceneitemConsumableCfg(self, itemId)

	if not consumableCfg then
		return false
	end

	if ConsumableTypeConfig.BattleItems and consumableCfg.SubType ~= ConsumableTypeConfig.BattleItems then
		return true
	end

	if ConsumableTypeConfig.Weapon and consumableCfg.SubType ~= ConsumableTypeConfig.Weapon then
		return false
	end

	local typeCfg = ConsumableTypeConfig.GetConfig(consumableCfg.SubType)

	return typeCfg and typeCfg.StackMaxCount and typeCfg.StackMaxCount >= 1 or false
end

M.CheckIsWeaponSceneitem = function(self, itemId)
	if self.CheckIsQuickItem(self, itemId) then
		return false
	end

	local cfg = self.GetSceneitemCfg and self:GetSceneitemCfg(itemId) or nil

	return cfg == nil
end

M.CheckSceneitemPackItemInTab = function(self, packItem, tabId)
	if not packItem then
		return false
	end

	if tabId ~= nil then
		return true
	end

	if self.IsQuickItemPackTab(self, tabId) then
		return self.CheckIsQuickItem(self, packItem.TemplateId)
	end

	if self.IsWeaponPackTab(self, tabId) then
		return self.CheckIsWeaponSceneitem(self, packItem.TemplateId)
	end

	return false
end

M.ClearWeaponPackItemDict = function(self)
	for uniqueId in pairs(self.weaponPackItemDict) do
		self.weaponPackItemDict[uniqueId] = nil
	end
end

M.GetPackItemDictValue = function(self, uniqueId)
	if uniqueId ~= nil then
		return nil
	end

	local packItem = self.realPackItemDict[uniqueId]

	if packItem then
		return packItem
	end

	packItem = self.weaponPackItemDict[uniqueId]

	if packItem then
		return packItem
	end

	packItem = self.equippedDecorationPackItemDict and self.equippedDecorationPackItemDict[uniqueId]

	if packItem then
		return packItem
	end

	packItem = self.fishPackItemDict and self.fishPackItemDict[uniqueId]

	if packItem then
		return packItem
	end

	return self.BuildWeaponPackItemByUniqueId(self, uniqueId)
end

M.SetPackItemDictValue = function(self, uniqueId, packItem)
	self.realPackItemDict[uniqueId] = packItem
end

M.BuildWeaponPackItem = function(self, weapon)
	if not weapon or weapon.InstanceId ~= nil or weapon.TemplateId ~= nil then
		return nil
	end

	local weaponCfg = self.GetSceneitemCfg(self, weapon.TemplateId)

	if not weaponCfg or not weaponCfg.IsShowInBag then
		return nil
	end

	local uniqueId = weapon.InstanceId
	local packItem = self.weaponPackItemDict[uniqueId] or {}
	local consumableCfg = self:GetSceneitemConsumableCfg(weapon.TemplateId)
	local isQuickItem = self:CheckIsQuickItem(weapon.TemplateId)
	packItem.UniqueId = uniqueId
	packItem.TemplateId = weapon.TemplateId
	packItem.Count = isQuickItem and (weapon.Durability or 0) or 1
	packItem.ExpiryTime = 0
	packItem.CreateTime = 0
	packItem.CDFinishTime = 0
	packItem.IsNew = weapon.WeaponFlags and weapon.WeaponFlags.ShowRedDot or false
	packItem.IsWeaponPackItem = true
	packItem.WeaponData = weapon
	packItem.Cfg = packItem.Cfg or {}
	packItem.Cfg.Id = weapon.TemplateId
	packItem.Cfg.Quality = weaponCfg.Quality or 0
	packItem.Cfg.SubType = consumableCfg and consumableCfg.SubType or ConsumableTypeConfig.Fashion or 0
	packItem.Quality = packItem.Cfg.Quality
	packItem.SubType = packItem.Cfg.SubType
	self.weaponPackItemDict[uniqueId] = packItem

	return packItem
end

M.BuildWeaponPackItemByUniqueId = function(self, uniqueId)
	local weapon = gWeaponManager:GetWeaponByInstanceId(uniqueId)

	return self:BuildWeaponPackItem(weapon)
end

M.GetCurrentSceneitemPackItems = function(self, tabId)
	self:ClearWeaponPackItemDict()

	local ret = {}
	local uniqueIds = {}

	local AddWeapon = function(weapon)
		if not weapon or uniqueIds[weapon.InstanceId] then
			return
		end

		local packItem = self:BuildWeaponPackItem(weapon)

		if self:CheckSceneitemPackItemInTab(packItem, tabId) and not uniqueIds[packItem.UniqueId] then
			uniqueIds[packItem.UniqueId] = true

			table.insert(ret, packItem)
		end
	end

	local weapons = gWeaponManager:GetCurrentWeapons()

	if weapons then
		local weaponCount = weapons.Length

		for i = 1, weaponCount do
			AddWeapon(weapons[i])
		end
	end

	local spiritBindData = gPlayerManager.infoSpirit and gPlayerManager.infoSpirit.bindData or nil
	local slotDict = spiritBindData and spiritBindData.SpiritWeaponSlotDict or nil

	if slotDict and self.IsWeaponPackTab(self, tabId) then
		for _, slots in pairs(slotDict) do
			local slotCount = slots and (slots.Length or slots.Count or #slots) or 0

			for i = 1, slotCount do
				AddWeapon(slots[i])
			end
		end
	end

	local armoryWeapons = gWeaponManager:GetMainArmoryWeapons()

	if armoryWeapons then
		for _, weapon in pairs(armoryWeapons) do
			AddWeapon(weapon)
		end
	end

	return ret
end

M.GetCurrentWeaponPackItems = function(self)
	return self.GetCurrentSceneitemPackItems(self, self.GetWeaponPackTabId(self))
end

M.GetCurrentQuickItemPackItems = function(self)
	return self.GetCurrentSceneitemPackItems(self, self.GetQuickItemPackTabId(self))
end

M.GetWeaponPackItemsByTemplateId = function(self, templateId)
	local ret = {}

	if templateId ~= nil or ConsumableConfig.GetConfig(templateId) == nil or not self.GetSceneitemCfg(self, templateId) then
		return ret
	end

	local items = self.GetCurrentSceneitemPackItems(self)

	for i = 1, #items do
		if items[i].TemplateId ~= templateId then
			table.insert(ret, items[i])
		end
	end

	return ret
end

M.SetPlayerInfoItem = function(self, infoItem)
	self.InitPackItem(self)

	self._sharedBatchMode = true
	local otherItemChanged = false

	for i = 1, infoItem.PackItems.Length do
		local packItem = infoItem.PackItems[i]
		local itemCfg = ConsumableConfig.GetConfig(packItem.TemplateId)

		if itemCfg ~= nil then
			print_error("仓库里有物品找不到对应配表，ConsumableConfig，TemplateId=", packItem.TemplateId)
		else
			table.insert(self.packItems, packItem)

			self.packItemDict[packItem.UniqueId] = packItem

			self.AddSharedPackItem(self, packItem)

			local isOtherItem = self.SetItemToSubPack(self, packItem, itemCfg)
			local tabIndex = self.GetPackTabByTemplateId(self, packItem.TemplateId)

			if tabIndex and self.packTabItems[tabIndex] == nil then
				table.insert(self.packTabItems[tabIndex], packItem)
			else
				print_error("[PlayerItemManager] 背包中tab物品增加失败，TemplateId=", packItem.TemplateId)
			end

			otherItemChanged = otherItemChanged or isOtherItem
		end
	end

	self._sharedBatchMode = false

	gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)

	if otherItemChanged then
		gMessageManager:SendMessage(gEventConstants.OTHER_ITEM_CHANGED)
	end
end

M.SetPackItem = function(self, addList, updateList, deleteList, reason)
	local updateDict = {}
	local otherItemChanged = false
	local bulletItemChangedDict = {}

	if #deleteList <= 0 then
		for i = #self.packItems, 1, -1 do
			for j = 1, #deleteList do
				if self.packItems[i].UniqueId ~= deleteList[j].UniqueId then
					updateDict[self.packItems[i].UniqueId] = self.packItems[i].TemplateId

					self.RecordBulletItemChange(self, bulletItemChangedDict, self.packItems[i].TemplateId)
					self.RemoveSharedPackItem(self, self.packItems[i])

					self.packItemDict[self.packItems[i].UniqueId] = nil
					local packTabIndex = self.GetPackTabByTemplateId(self, self.packItems[i].TemplateId)

					if packTabIndex then
						array.remove(self.packTabItems[packTabIndex], self.packItems[i])
					end

					table.remove(self.packItems, i)

					deleteList[j].Count = 0
					otherItemChanged = self:SetItemToSubPack(deleteList[j]) or otherItemChanged

					break
				end
			end
		end
	end

	if #updateList <= 0 then
		for i = 1, #updateList do
			local prevData = self.packItemDict[updateList[i].UniqueId]

			if prevData ~= nil then
				print_error("#NoCreateIssue 客户端不存在UniqueId=", updateList[i].UniqueId, "的物品，TemplateId=", updateList[i].TemplateId)

				break
			end

			local prevTemplateId = prevData.TemplateId
			local prevCount = prevData.Count or 0

			self:UpdateItemData(updateList[i], prevData)
			self:UpdateSharedPackItem(prevData, prevTemplateId, prevCount)

			updateDict[updateList[i].UniqueId] = updateList[i].TemplateId

			self:RecordBulletItemChange(bulletItemChangedDict, updateList[i].TemplateId)

			otherItemChanged = self:SetItemToSubPack(updateList[i]) or otherItemChanged
		end
	end

	self._sharedBatchMode = true

	for i = 1, #addList do
		table.insert(self.packItems, addList[i])

		self.packItemDict[addList[i].UniqueId] = addList[i]

		self.AddSharedPackItem(self, addList[i])

		local packTabIndex = self.GetPackTabByTemplateId(self, addList[i].TemplateId)

		if packTabIndex and self.packTabItems[packTabIndex] == nil then
			table.insert(self.packTabItems[packTabIndex], addList[i])
		else
			print_error("[PlayerItemManager] 背包中tab物品增加失败，TemplateId=", addList[i].TemplateId)
		end

		self:RecordBulletItemChange(bulletItemChangedDict, addList[i].TemplateId)

		otherItemChanged = self:SetItemToSubPack(addList[i]) or otherItemChanged
	end

	self._sharedBatchMode = false

	if otherItemChanged then
		gMessageManager:SendMessage(gEventConstants.OTHER_ITEM_CHANGED)
	end

	gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED, {
		addList = addList,
		updateDict = updateDict,
		changeType = gPackagePanelManager.itemType.Item
	})
	self:SendBulletItemChanged(bulletItemChangedDict)
end

M.IsBulletItem = function(self, templateId)
	if not templateId then
		return false
	end

	local itemCfg = ConsumableConfig.GetConfig(templateId)

	if not itemCfg then
		return false
	end

	local subType = itemCfg.SubType

	return subType ~= ConsumableTypeConfig.Bullet or subType ~= ConsumableTypeConfig.MediumBullet or subType ~= ConsumableTypeConfig.HeavyBullet
end

M.RecordBulletItemChange = function(self, bulletItemChangedDict, templateId)
	if self.IsBulletItem(self, templateId) then
		bulletItemChangedDict[templateId] = true
	end
end

M.SendBulletItemChanged = function(self, bulletItemChangedDict)
	for templateId in pairs(bulletItemChangedDict) do
		gMessageManager:SendMessage(gEventConstants.BULLET_ITEM_CHANGED, templateId)
	end
end

M.SetItemToSubPack = function(self, packItem, itemCfg)
	local otherItemChanged = false

	if not itemCfg then
		itemCfg = ConsumableConfig.GetConfig(packItem.TemplateId)

		if not itemCfg then
			return otherItemChanged
		end
	end

	return otherItemChanged
end

M.GetPackItemByTemplateId = function(self, templateId)
	local sharedItem = self.GetSharedPackItemByTemplateId(self, templateId)

	if sharedItem then
		return sharedItem
	end

	local weaponItems = self.GetWeaponPackItemsByTemplateId(self, templateId)

	return weaponItems[1]
end

M.AppendWeaponPackItemsByTemplateId = function(self, result, templateId)
	local weaponItems = self.GetWeaponPackItemsByTemplateId(self, templateId)

	for i = 1, #weaponItems do
		table.insert(result, weaponItems[i])
	end
end

M.GetPackItemsByTemplateId = function(self, templateId)
	local result = {}
	local sharedItems = self.GetSharedPackItemsByTemplateId(self, templateId)

	if sharedItems then
		for i = 1, #sharedItems do
			table.insert(result, sharedItems[i])
		end
	end

	self.AppendWeaponPackItemsByTemplateId(self, result, templateId)

	return result
end

M.GetPackItemNum = function(self, templateId, isTarkov)
	local num = 0

	if table.contains(self.SpecialItemId, templateId) or self.moneyDict[templateId] then
		return self.GetSpecialItemNum(self, templateId)
	end

	if gExtractionShooterManager.CheckInGame() then
		return self.GetTarkovBagItemNumByConsumableId(self, templateId, {
			BAG_CONFIG_ID.Normal
		})
	end

	if isTarkov then
		return self.GetTarkovBagItemNumByConsumableId(self, templateId)
	end

	num = self.GetSharedPackItemNum(self, templateId)
	local weaponItems = self.GetWeaponPackItemsByTemplateId(self, templateId)

	for i = 1, #weaponItems do
		num = num + (weaponItems[i].Count or 0)
	end

	return num
end

M.GetTarkovBagItemNumByConsumableId = function(self, consumableId, bagConfigIds)
	local num = 0
	bagConfigIds = bagConfigIds or {
		BAG_CONFIG_ID.Normal,
		BAG_CONFIG_ID.SafeBox,
		BAG_CONFIG_ID.Inventory
	}

	for _, bagConfigId in ipairs(bagConfigIds) do
		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
		local itemInfoList = bagInfo and bagInfo.ItemInfoList

		if itemInfoList then
			for _, itemInfo in ipairs(itemInfoList) do
				if itemInfo.Id ~= consumableId then
					num = num + itemInfo.StackCount
				end
			end
		end
	end

	return num
end

M.GetSpecialItemNum = function(self, templateId)
	if templateId ~= ConsumableConfig.RewardBindingGold then
		return gPlayerManager.infoItem.bindData.bindGold
	elseif templateId ~= ConsumableConfig.RewardGold then
		return gPlayerManager.infoItem.bindData.gold
	elseif self.moneyDict[templateId] then
		return self.GetExchangeRate(self)
	end

	return 0
end

M.GetSellItemConfig = function(self, templateId)
	local cfg = ConsumableConfig.GetConfig(templateId)

	if cfg then
		return cfg
	end

	return self.GetSceneitemCfg(self, templateId)
end

M.CheckItemCanSell = function(self, templateId)
	local cfg = ConsumableConfig.GetConfig(templateId)

	if cfg then
		if cfg.CanSell ~= true then
			return cfg.CanSell
		end

		local typeCfg = ConsumableTypeConfig.GetConfig(cfg.SubType)

		return typeCfg and typeCfg.CanSell ~= true or false
	end

	local sceneItemCfg = self:GetSceneitemCfg(templateId)

	return sceneItemCfg and sceneItemCfg.CanSell ~= true or false
end

M.CheckPackItemCanSell = function(self, packItem)
	if not packItem or packItem.IsEquippedDecorationPackItem then
		return false
	end

	return self.CheckItemCanSell(self, packItem.TemplateId)
end

M.GetItemSellPrice = function(self, templateId)
	local cfg = self:GetSellItemConfig(templateId)

	return cfg and (cfg.Value or cfg.SystemPrice or 0) or 0
end

M.GetPackItemSellPrice = function(self, packItem)
	if not packItem then
		return 0
	end

	if not packItem._isFish then
		return self.GetItemSellPrice(self, packItem.TemplateId)
	end

	local fishCfg = LTConfig.FishingFishConfig.GetConfig(packItem.TemplateId)
	local consumableId = fishCfg and fishCfg.ConsumableId or 0
	local pricePerKg = consumableId == 0 and self:GetItemSellPrice(consumableId) or 0

	return math.floor((packItem._weight or 0) * pricePerKg)
end

M.GetGeneralBuyBackSellPrice = function(self, shopId, templateId)
	local basePrice = self:GetItemSellPrice(templateId)
	local discount = gShopManager and gShopManager:GetShopGeneralBuyBackDiscount(shopId) or 100

	return math.floor(basePrice * discount / 100)
end

M.GetGeneralBuyBackPackItemSellPrice = function(self, shopId, packItem)
	local basePrice = self:GetPackItemSellPrice(packItem)
	local discount = gShopManager and gShopManager:GetShopGeneralBuyBackDiscount(shopId) or 100

	return math.floor(basePrice * discount / 100)
end

M.SellItemToShop = function(self, shopId, uniqueId, templateId, count, callback)
	if not shopId or shopId ~= 0 or not uniqueId or not templateId or templateId ~= 0 then
		return
	end

	if not self.CheckItemCanSell(self, templateId) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.ItemCanNotSell)

		return
	end

	count = count or 1

	if count ~= 0 then
		if callback then
			callback(MessageConfig.Ok)
		end

		return
	end

	slot6 = gClientToGameDelegate

	slot6:AskGeneralBuyBackItemToShop(shopId, uniqueId, count).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		if callback then
			callback(err)
		end
	end
end

M.SellWeaponToShop = function(self, shopId, weaponInstanceId, callback)
	if not shopId or shopId ~= 0 or not weaponInstanceId then
		return
	end

	local packItem = self.packItemDict[weaponInstanceId]

	if not packItem then
		gDisplayMessageMgr:ShowMessage(MessageConfig.WeaponNotExist)

		return
	end

	local templateId = packItem.TemplateId

	if not self.CheckItemCanSell(self, templateId) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.ItemCanNotSell)

		return
	end

	slot6 = gReliableRpcManager

	slot6:RegisterRPC(gClientToGameDelegate.AskGeneralBuyBackWeaponToShop, shopId, weaponInstanceId, function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		if callback then
			callback(err)
		end
	end)
end

M.QueryItemById = function(self, templateId)
	local items = self.GetPackItemsByTemplateId(self, templateId)

	for i = 1, #items do
		if items[i].TemplateId ~= templateId and self.CheckItemCanUse(self, items[i]) then
			return true, items[i]
		end
	end

	return false
end

M.CheckItemCanUse = function(self, item)
	return self:GetUseTimes(item.TemplateId) == 0
end

M.GetUseTimes = function(self, templateId)
	local result = ""
	local consumableCfg = ConsumableConfig.GetConfig(templateId)

	if consumableCfg and consumableCfg.DailyCount == -1 then
		local times = gPlayerManager.infoItem.pack.itemUseTimes[templateId] or 0
		result = consumableCfg.DailyCount - times
	end

	return result
end

M.GetPackItemListByTab = function(self, tab)
	return self.GetPackDisplayItems(self, tab)
end

M.HideRedDot = function(self, uniqueId)
	local packItem = self.packItemDict[uniqueId]

	if not packItem or not packItem.IsNew then
		return
	end

	packItem.IsNew = false

	if packItem.IsWeaponPackItem then
		gWeaponManager:ClearWeaponRedDot(uniqueId)

		return
	end

	if not self.redDotPendingList then
		self.redDotPendingList = {}
	end

	table.insert(self.redDotPendingList, uniqueId)

	if self.redDotTimer then
		return
	end

	self.redDotTimer = Timer.New(function ()
		self:ProcessRedDotBatch()
	end, 0.5):Start()
end

M.ProcessRedDotBatch = function(self)
	self.redDotTimer = nil

	if not self.redDotPendingList or #self.redDotPendingList ~= 0 then
		return
	end

	local batch = {}

	for i = 1, math.min(self.RED_DOT_BATCH_SIZE, #self.redDotPendingList) do
		table.insert(batch, self.redDotPendingList[i])
	end

	for i = 1, #batch do
		table.remove(self.redDotPendingList, 1)
	end

	slot2 = gClientToGameDelegate

	slot2:AskClearRedPointList(batch).Callback = function (err, info)
		if err == MessageConfig.Ok then
			for i = 1, #batch do
				local uniqueId = batch[i]
				local item = self.packItemDict[uniqueId]

				if item then
					item.IsNew = true
				end
			end
		end

		if #self.redDotPendingList <= 0 then
			self.redDotTimer = Timer.New(function ()
				self:ProcessRedDotBatch()
			end, self.RED_DOT_MIN_INTERVAL):Start()
		end
	end
end

M.GetPackTabByTemplateId = function(self, templateId)
	local cfg = ConsumableConfig.GetConfig(templateId)

	if not cfg then
		return
	end

	local subTypeCfg = ConsumableTypeConfig.GetConfig(cfg.SubType)

	return subTypeCfg.ItemTab
end

M.GetPackDisplayItems = function(self, tabId)
	if tabId ~= ConsumableTabConfig.Fish then
		return self.BuildFishPackItems(self)
	end

	if self.IsWeaponPackTab(self, tabId) then
		return self.GetCurrentWeaponPackItems(self)
	end

	if self.IsQuickItemPackTab(self, tabId) then
		return self.MergeQuickItemPackItems(self, tabId)
	end

	if self.IsDecorationPackTab(self, tabId) then
		return self.MergeEquippedDecorationPackItems(self, tabId)
	end

	local childTabs = self.packTabChildren and self.packTabChildren[tabId]

	if table.isNilOrEmpty(childTabs) then
		return self.packTabItems[tabId] or {}
	end

	local ret = {}
	local selfTabItems = self.packTabItems[tabId] or {}

	for i = 1, #selfTabItems do
		table.insert(ret, selfTabItems[i])
	end

	for i = 1, #childTabs do
		local childItems = self:IsWeaponPackTab(childTabs[i]) and self:GetCurrentWeaponPackItems() or self:IsQuickItemPackTab(childTabs[i]) and self:MergeQuickItemPackItems(childTabs[i]) or self:IsDecorationPackTab(childTabs[i]) and self:MergeEquippedDecorationPackItems(childTabs[i]) or self.packTabItems[childTabs[i]] or {}

		for j = 1, #childItems do
			table.insert(ret, childItems[j])
		end
	end

	return ret
end

M.IsDecorationPackTab = function(self, tabId)
	local typeCfg = ConsumableTypeConfig.GetConfig(ConsumableTypeConfig.Decoration)

	return typeCfg and typeCfg.ItemTab ~= tabId or false
end

M.BuildEquippedDecorationPackItems = function(self)
	self.equippedDecorationPackItemDict = {}
	local ret = {}
	local uniqueIds = {}
	local weaponDict = gWeaponManager and gWeaponManager.weaponDict or nil

	if not weaponDict then
		return ret
	end

	for _, weapon in pairs(weaponDict) do
		local decorations = weapon and weapon.Decorations or nil
		local decorationCount = decorations and (decorations.Length or decorations.Count or #decorations) or 0

		for i = 1, decorationCount do
			local decoration = decorations[i]
			local uniqueId = decoration and (decoration.UniqueId or decoration.ItemId) or nil
			local decorationId = decoration and decoration.DecorationId or 0

			if uniqueId and uniqueId == 0 and decorationId == 0 and not uniqueIds[uniqueId] then
				uniqueIds[uniqueId] = true
				local realPackItem = self.realPackItemDict[uniqueId]

				if not realPackItem then
					local decorationCfg = DecorationConfig.GetConfig(decorationId)
					local consumableId = self:FindConsumableIdByBindId(decorationId)
					local consumableCfg = consumableId and ConsumableConfig.GetConfig(consumableId) or nil
					local packItem = {
						["LR\\x8a~B\\xbb\\xe1O^ssI"] = 0,
						["vB޴\\x96\\x8c\r\\xc4\\xed"] = 0,
						["\\xb8\r\\xf2M`\\x9e\ndL\\xb2nA\\x95a\\xf3\\xb4\\xa1\\xd4W0}\\x8b"] = true,
						["n\\xa1\\xb7\\xa1\\xa2"] = 1,
						["d\\xbd\\x8c\\xaa\\xa1"] = false,
						["pH˼\\x90\r\\x8c\r\\xc4\\xed"] = 0,
						UniqueId = uniqueId,
						TemplateId = consumableId or decorationId,
						DecorationData = decoration,
						OwnerWeaponData = weapon,
						Cfg = consumableCfg or {
							Id = decorationId,
							Quality = decorationCfg and decorationCfg.Quality or 0,
							SubType = ConsumableTypeConfig.Decoration
						}
					}
					packItem.Quality = packItem.Cfg.Quality or 0
					packItem.SubType = packItem.Cfg.SubType or ConsumableTypeConfig.Decoration
					self.equippedDecorationPackItemDict[uniqueId] = packItem

					table.insert(ret, packItem)
				end
			end
		end
	end

	return ret
end

M.MergeEquippedDecorationPackItems = function(self, tabId)
	local ret = {}
	local uniqueIds = {}
	local regularItems = self.packTabItems[tabId] or {}

	for i = 1, #regularItems do
		local item = regularItems[i]
		uniqueIds[item.UniqueId] = true

		table.insert(ret, item)
	end

	local equippedItems = self.BuildEquippedDecorationPackItems(self)

	for i = 1, #equippedItems do
		local item = equippedItems[i]

		if not uniqueIds[item.UniqueId] then
			uniqueIds[item.UniqueId] = true

			table.insert(ret, item)
		end
	end

	return ret
end

M.MergeQuickItemPackItems = function(self, tabId)
	local ret = {}
	local regularTemplateIds = {}
	local regularItems = self.packTabItems[tabId] or {}

	for i = 1, #regularItems do
		table.insert(ret, regularItems[i])

		regularTemplateIds[regularItems[i].TemplateId] = true
	end

	local sceneItems = self.GetCurrentQuickItemPackItems(self)

	for i = 1, #sceneItems do
		local consumableCfg = self:GetSceneitemConsumableCfg(sceneItems[i].TemplateId)
		local consumableId = consumableCfg and consumableCfg.Id or nil

		if not consumableId or not regularTemplateIds[consumableId] then
			table.insert(ret, sceneItems[i])
		end
	end

	return ret
end

M.BuildFishPackItems = function(self)
	self.fishPackItemDict = {}
	local ret = {}
	local minorBindData = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData
	local fishingInfo = minorBindData and minorBindData.FishingInfo

	if not fishingInfo then
		return ret
	end

	slot4 = pairs
	slot6 = fishingInfo.ConsumableFishDict or {}

	for _, fishInfo in slot4(slot6) do
		local item = self._BuildFishPackItem(self, fishInfo)
		self.fishPackItemDict[item.UniqueId] = item

		table.insert(ret, item)
	end

	slot4 = pairs
	slot6 = fishingInfo.OrnamentalFishDict or {}

	for _, fishInfo in slot4(slot6) do
		local item = self._BuildFishPackItem(self, fishInfo)
		self.fishPackItemDict[item.UniqueId] = item

		table.insert(ret, item)
	end

	return ret
end

M._BuildFishPackItem = function(self, fishInfo)
	local fishCfg = LTConfig.FishingFishConfig.GetConfig(fishInfo.TemplateId)
	local quality = fishCfg and fishCfg.Quality or 0

	return {
		["\\xea\\xce)4\\xf4"] = 0,
		["\\xe6\\xd2;7\\xf9"] = true,
		["n\\xa1\\xb7\\xa1\\xa2"] = 1,
		["d\\xbd\\x8c\\xaa\\xa1"] = false,
		["pH˼\\x90\r\\x8c\r\\xc4\\xed"] = 0,
		UniqueId = fishInfo.UniqueId,
		TemplateId = fishInfo.TemplateId,
		Cfg = {
			["\\xea\\xce)4\\xf4"] = 0,
			Quality = quality
		},
		Quality = quality,
		_weight = fishInfo.Weight or 0,
		_length = fishInfo.Length or 0,
		_isPlaced = fishInfo.PlacedInfo == nil or fishInfo.IsPlaced or false,
		_placedInfo = fishInfo.PlacedInfo
	}
end

M.UseItemByTemplateId = function(self, templateId, itemCount, callBack)
	local items = self.GetPackItemsByTemplateId(self, templateId)

	if items ~= nil or #items ~= 0 then
		self.UseItem(self, nil, templateId, itemCount, callBack)
	else
		for i = 1, #items do
			if itemCount < items[i].Count then
				self.UseItem(self, items[i].UniqueId, templateId, itemCount, callBack)

				return
			end
		end
	end
end

M.UseItem = function(self, uniqueId, templateId, itemCount, callBack)
	if not self.UseItemPrecheck(self, templateId) then
		callBack()

		return
	end

	slot5 = gClientToGameDelegate

	slot5:AskUseItems(uniqueId, itemCount).Callback = function (err)
		if err ~= MessageConfig.Ok then
			-- Nothing
		elseif err ~= MessageConfig.ItemNotEnough then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900872).Text)
		else
			print_warn("AskUseItems Fail", gCS.Error.GetNameById(err))
		end

		if callBack then
			callBack(err)
		end
	end

	return true
end

M.UseItemPrecheck = function(self, templateId)
	if not self.IsAutoUseItem(self, templateId) and gCS.MyPlayerManager.CheckEventForbidden(UnitState.UseItem) then
		return false
	end

	if templateId ~= ConsumableConfig.Portal and gMapSubSystem_Entrance.portalPosition then
		gMapSubSystem_Entrance:TryTeleport(MapentranceConfig.PortalItem)

		return false
	end

	local consumableCfg = ConsumableConfig.GetConfig(templateId)

	if consumableCfg and consumableCfg.DailyCount == -1 and gPlayerManager.infoItem.pack.itemUseTimes[templateId] and consumableCfg.DailyCount < gPlayerManager.infoItem.pack.itemUseTimes[templateId] then
		gDisplayMessageMgr:ShowMessage(MessageConfig.DailyCountFull)

		return
	end

	return true
end

M.IsAutoUseItem = function(self, templateId)
	local cfg = ConsumableConfig.GetConfig(templateId)
	local consumableTypeCfg = cfg and ConsumableTypeConfig.GetConfig(cfg.SubType) or nil

	if consumableTypeCfg then
		return consumableTypeCfg.AutoUse
	else
		return false
	end
end

M.GetInventoryPanelId = function(self, isFront)
	if gGameSwitch.EnableNewBag then
		if isFront then
			return gPanelId.S_NEW_INVENTORY_PANEL_FRONT
		end

		return gPanelId.S_NEW_INVENTORY_PANEL
	end

	return gPanelId.S_INVENTORY_PANEL
end

M.OpenInventoryPanel = function(self, showData, isFront)
	gPanelManager:CheckShow(self:GetInventoryPanelId(isFront), showData)
end

M.CloseInventoryPanel = function(self)
	gPanelManager:Close(gPanelId.S_INVENTORY_PANEL)
	gPanelManager:Close(gPanelId.S_NEW_INVENTORY_PANEL)
	gPanelManager:Close(gPanelId.S_NEW_INVENTORY_PANEL_FRONT)
	gPanelManager:Close(gPanelId.S_NEW_INVENTORY_PANEL_FRONT_FS)
end

M.IsInventoryPanelShowing = function(self)
	if gPanelManager:IsPanelShowing(self:GetInventoryPanelId(false)) then
		return true
	end

	return gGameSwitch.EnableNewBag and gPanelManager:IsPanelShowing(self:GetInventoryPanelId(true)) or false
end

M.PreloadInventoryPanel = function(self)
	return gCoroutineManager:StartCoroutine(gPanelManager.Preload, gPanelManager, self:GetInventoryPanelId())
end

M.IsInventoryPanelId = function(self, panelId)
	return panelId ~= gPanelId.S_INVENTORY_PANEL or panelId ~= gPanelId.S_NEW_INVENTORY_PANEL or panelId ~= gPanelId.S_NEW_INVENTORY_PANEL_FRONT or panelId ~= gPanelId.S_NEW_INVENTORY_PANEL_FRONT_FS
end

M.UpdateItemData = function(self, newData, prevData)
	prevData.UniqueId = newData.UniqueId
	prevData.Count = newData.Count
	prevData.ExpiryTime = newData.ExpiryTime
	prevData.IsNew = newData.IsNew
	prevData.RemindState = newData.RemindState
	prevData.SubType = newData.SubType
	prevData.TemplateId = newData.TemplateId
	prevData.CDFinishTime = newData.CDFinishTime
end
