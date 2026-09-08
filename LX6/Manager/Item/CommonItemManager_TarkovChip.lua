-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_TarkovChip.lua
-- Decompiled from: 02212_CommonItemManager_TarkovChip.lua_96a112718957.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local DecorationConfig = LTConfig.DecorationConfig
local M = C_CommonItemManager

M.BuildDecorationConsumableCfgMap = function(self)
	self.decorationConsumableCfgMap = {}

	for index = 0, ConsumableConfig.count - 1 do
		local cfg = ConsumableConfig.LoadAt(index)

		if cfg and cfg.SubType ~= ConsumableTypeConfig.Decoration and cfg.BindId and cfg.BindId == 0 then
			self.decorationConsumableCfgMap[cfg.BindId] = cfg
		end
	end
end

M.GetDecorationConsumableCfg = function(self, decorationId)
	if not self.decorationConsumableCfgMap then
		self.BuildDecorationConsumableCfgMap(self)
	end

	return self.decorationConsumableCfgMap[decorationId]
end

M.ResolveTarkovChipEntry = function(self, itemInfo, bagConfigId)
	if not itemInfo then
		return nil
	end

	local consumableCfg = ConsumableConfig.GetConfig(itemInfo.Id)

	if not consumableCfg or consumableCfg.SubType == ConsumableTypeConfig.Decoration then
		return nil
	end

	local decorationCfg = DecorationConfig.GetConfig(consumableCfg.BindId)

	if not decorationCfg then
		return nil
	end

	local extractionItemCfg = gExtractionShooterUtils.GetItemCfgByConsumableId(itemInfo.Id)

	return {
		TemplateId = itemInfo.Id,
		consumableCfg = consumableCfg,
		decoCfg = decorationCfg,
		extItemCfg = extractionItemCfg,
		cell = {
			bagConfigId = bagConfigId,
			cellX = itemInfo.CellX,
			cellY = itemInfo.CellY
		},
		stackCount = itemInfo.StackCount,
		isLocked = itemInfo.IsLocked,
		bindPid = itemInfo.BindPid
	}
end

M.BuildTarkovChipList = function(self, gamePlayTypeId)
	local result = {}
	slot3 = gExtractionShooterManager

	slot3:ForEachTarkovGamePlayBagItem(function (itemInfo, bagConfigId)
		local entry = self:ResolveTarkovChipEntry(itemInfo, bagConfigId)

		if entry then
			table.insert(result, entry)
		end
	end, gamePlayTypeId)

	return result
end

M.CollectTarkovWeaponEntries = function(self, gamePlayTypeId)
	local result = {}
	slot3 = gExtractionShooterManager

	slot3:ForEachTarkovGamePlayBagItem(function (itemInfo, bagConfigId)
		if itemInfo.WeaponData then
			table.insert(result, {
				weaponData = itemInfo.WeaponData,
				bagConfigId = bagConfigId,
				cellX = itemInfo.CellX,
				cellY = itemInfo.CellY
			})
		end
	end, gamePlayTypeId)

	return result
end

M.GetFirstAvailableTarkovStashBag = function(self, gamePlayTypeId, consumableId, extractionItemCfg)
	if not gamePlayTypeId or not consumableId or not extractionItemCfg then
		return nil
	end

	local stashBagConfigIds = gExtractionShooterManager:GetTarkovStashBagConfigIds(gamePlayTypeId)

	for _, bagConfigId in ipairs(stashBagConfigIds) do
		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)

		if bagInfo and bagInfo.BagId ~= bagConfigId and not self.IsTarkovBagFullForItem(self, bagConfigId, consumableId, extractionItemCfg) then
			return bagConfigId
		end
	end

	return nil
end

M.IsTarkovBagFullForItem = function(self, bagConfigId, consumableId, extractionItemCfg)
	if not extractionItemCfg then
		return false
	end

	local bagContext = gExtractionShooterUtils.BuildBagContextByConfigId(bagConfigId)
	local hasFreeCell = gExtractionShooterUtils.TryGetFreeCellByOrderWithRotation(bagContext, extractionItemCfg)

	if hasFreeCell then
		return false
	end

	local maxStackNum = gExtractionShooterUtils.GetBagMaxStackNum(extractionItemCfg)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	local itemInfoList = bagInfo and bagInfo.ItemInfoList or {}

	for _, itemInfo in ipairs(itemInfoList) do
		local canMerge = gExtractionShooterUtils.CanStackMergeRaw(consumableId, 0, false, itemInfo.Id, itemInfo.BindPid or 0, itemInfo.IsLocked or false)

		if canMerge and maxStackNum <= (itemInfo.StackCount or 0) then
			return false
		end
	end

	return true
end
