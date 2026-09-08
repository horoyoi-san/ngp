-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_Drop.lua
-- Decompiled from: 02207_CommonItemManager_Drop.lua_e77097b18b11.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local FactionConfig = LTConfig.FactionConfig
local DropConfig = LTConfig.DropConfig
local M = C_CommonItemManager

M.IsItemNumDisabled = function(self, itemId)
	for i = 1, #ConsumableConfig.BlockItemInfoShowNumItems do
		if ConsumableConfig.BlockItemInfoShowNumItems[i] ~= itemId then
			return true
		end
	end

	return false
end

M.RefreshItemCountLimit = function(self)
	local limitList = gPlayerManager.infoItem and gPlayerManager.infoItem.bindData and gPlayerManager.infoItem.bindData.itemCountLimitInfoList

	if limitList then
		for i = 1, #limitList do
			local item = limitList[i]
			self.itemLimitDict[item.ItemId] = item
		end
	end

	if table.isNilOrEmpty(self.itemCountLimitMax) then
		for i = 0, ConsumableTypeConfig.count - 1 do
			local cfg = ConsumableTypeConfig.LoadAt(i)
			self.itemCountLimitMax[cfg.Id] = cfg.MaxHaveNum
		end
	end
end

M.CheckAddItemCountLimit = function(self, itemId, count)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		return 0
	end

	local maxCount = self.itemCountLimitMax[cfg.SubType]

	if not maxCount then
		return count
	end

	local limitInfo = self.itemLimitDict[itemId]

	if not limitInfo then
		return math.min(count, maxCount)
	end

	local curTime = gLuaDataManager.serverTime
	local currentCount = limitInfo.Count or 0

	if limitInfo.NextRefreshTime and limitInfo.NextRefreshTime < curTime then
		currentCount = 0
	end

	if maxCount < currentCount then
		return 0
	end

	return math.min(count, maxCount - currentCount)
end

M.IsItemCountLimitReached = function(self, itemId)
	return self:CheckAddItemCountLimit(itemId, 1) > 0
end

M.GetItemTotalCDTime = function(self, itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)
	local singleCD = cfg.CDTime
	local commonCD = nil
	local commonCDType = cfg.CDType

	if commonCDType then
		local cdCfg = LTConfig.ConsumableCDTypeConfig.GetConfig(commonCDType)
		commonCD = cdCfg and cdCfg.ShareCDTime
	end

	return commonCD or singleCD
end

M.GetRewardList = function(self, dropId)
	local rewardList = {}
	local templateId = 0
	local dropItemList = self.GetItemSortedListByDropList(self, dropId, true)

	if not table.isNilOrEmpty(dropItemList) then
		for i = 1, #dropItemList do
			local dropItem = dropItemList[i]
			local item = {
				name = ConsumableConfig.GetConfig(dropItem.Id).Name,
				count = dropItem.Count,
				templateId = dropItem.Id
			}
			templateId = dropItem.Id

			table.insert(rewardList, item)
		end
	end

	return rewardList, templateId
end

M.GetItemSortPower = function(self, item)
	return self.itemSortPower[item.SubType] or math.huge
end

M.SortItem = function(self, a, b)
	if a.Quality == b.Quality then
		return b.Quality <= a.Quality
	end

	local aPower = self.GetItemSortPower(self, a)
	local bPower = self.GetItemSortPower(self, b)

	if aPower == bPower then
		return aPower <= bPower
	end

	return a.Id <= b.Id
end

M.GetRenderItemSortPower = function(self, item)
	return self.itemSortPower[item.subType] or math.huge
end

M.SortRenderItem = function(self, a, b)
	if a.quality == b.quality then
		return b.quality <= a.quality
	end

	local aPower = self.GetRenderItemSortPower(self, a)
	local bPower = self.GetRenderItemSortPower(self, b)

	if aPower == bPower then
		return aPower <= bPower
	end

	return a.itemId <= b.itemId
end

M.GetFakeItemInfo = function(self, itemId, count, isGot)
	itemId = self.NormalizeMoneyItemId(self, itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg or self.itemSortPower[cfg.SubType] ~= nil then
		return {}
	end

	local ret = {
		["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
		Id = itemId,
		Quality = cfg.Quality,
		SubType = cfg.SubType,
		Count = count,
		isGot = isGot
	}

	return ret
end

M.ConvertDropToFakeItem = function(self, dropId, count)
	local itemList = {}
	local randomList = {}

	if not dropId then
		return itemList, randomList
	end

	local cfg = DropConfig.GetConfig(dropId)

	if not cfg then
		print_error("ConvertDropToFakeItem: dropId not found", dropId)

		return itemList, randomList
	end

	count = count or 1
	local isGot = gDropManager:CheckDropLimit(dropId)

	for k, v in pairs(self.DropItemToFakeItem) do
		local item = cfg[k]

		if item and item == 0 then
			local ret = self.GetFakeItemInfo(self, v, item * count, isGot)

			if not table.isNilOrEmpty(ret) then
				table.insert(itemList, ret)
			end
		end
	end

	if not table.isNilOrEmpty(cfg.Fan) then
		local fanCount = 0

		for i = 1, #cfg.Fan do
			fanCount = fanCount + cfg.Fan[i].Count
		end

		local ret = self.GetFakeItemInfo(self, ConsumableConfig.RewardFan, count * fanCount, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(itemList, ret)
		end
	end

	if cfg.Popularity <= 0 then
		local ret = self.GetFakeItemInfo(self, ConsumableConfig.RewardPopularity, count * cfg.Popularity, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(itemList, ret)
		end
	end

	local item = cfg.Item1

	for i = 1, #item do
		local itemId = item[i].id1
		local ret = self.GetFakeItemInfo(self, itemId, item[i].count * count, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(itemList, ret)
		end
	end

	item = cfg.Item2

	for i = 1, #item do
		local itemId = item[i].id2
		local ret = self.GetFakeItemInfo(self, itemId, 0, isGot)

		if not table.isNilOrEmpty(ret) then
			ret.Count = "x" .. item[i].min * count .. " - " .. item[i].max * count

			table.insert(randomList, ret)
		end
	end

	item = cfg.Item3

	for i = 1, #item do
		local itemId = item[i].id3
		local ret = self.GetFakeItemInfo(self, itemId, 0, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(randomList, ret)
		end
	end

	item = cfg.Item4Range

	for i = 1, #item do
		local itemId = item[i].id4
		local ret = self.GetFakeItemInfo(self, itemId, 0, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(randomList, ret)
		end
	end

	local faction = cfg.FactionInfo

	for i = 1, #faction do
		local fCfg = FactionConfig.GetConfig(faction[i].FactionId)

		if fCfg and fCfg.DispositionItem == 0 then
			local ret = self.GetFakeItemInfo(self, fCfg.DispositionItem, faction[i].Disposition * count, isGot)

			if not table.isNilOrEmpty(ret) then
				table.insert(itemList, ret)
			end
		else
			local ret = self.GetFakeItemInfo(self, FactionConfig.DefaultDispositionItem, faction[i].Disposition * count, isGot)

			if not table.isNilOrEmpty(ret) then
				table.insert(itemList, ret)
			end
		end
	end

	local talentPoint = cfg.CommonSpiritTalentExp + cfg.SpiritTalentExp

	if talentPoint <= 0 then
		local ret = self.GetFakeItemInfo(self, ConsumableConfig.CommonTalentExp, talentPoint * count, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(itemList, ret)
		end
	end

	if not table.isNilOrEmpty(cfg.ExtractionShooterItem) then
		for i = 1, #cfg.ExtractionShooterItem do
			local esItem = cfg.ExtractionShooterItem[i]
			local ret = self.GetFakeItemInfo(self, esItem.id, esItem.count * count, isGot)

			if not table.isNilOrEmpty(ret) then
				table.insert(itemList, ret)
			end
		end
	end

	return itemList, randomList
end

M.GetItemSortedListByDropList = function(self, dropList, useSingle)
	if type(dropList) ~= "number" then
		local dropId = dropList
		dropList = {}

		table.insert(dropList, {
			dropId = dropId
		})
	end

	local rewardList = {}
	local randomList = {}

	for i = 1, #dropList do
		if dropList[i].dropId == 0 then
			local itemList, rList = self.ConvertDropToFakeItem(self, dropList[i].dropId, dropList[i].count)

			if #dropList ~= 1 then
				if dropList[1].isFirstKill then
					for j = 1, #itemList do
						itemList[j].isFirstKill = true
					end

					for j = 1, #rList do
						rList[j].isFirstKill = true
					end
				end

				rewardList = itemList
				randomList = rList
			else
				for j = 1, #itemList do
					local item = itemList[j]
					itemList[j].isFirstKill = dropList[i].isFirstKill

					if rewardList[itemList[j].Id] then
						rewardList[itemList[j].Id].Count = rewardList[itemList[j].Id].Count + item.Count
					else
						rewardList[itemList[j].Id] = item
					end
				end

				for j = 1, #rList do
					local item = rList[j]
					rList[j].isFirstKill = dropList[i].isFirstKill

					if randomList[item.Id] then
						randomList[item.Id].Count = randomList[item.Id].Count + item.Count
					else
						randomList[item.Id] = item
					end
				end
			end
		end
	end

	if #dropList <= 1 then
		randomList = array.concat(table.to_array(randomList), table.to_array(rewardList))
		rewardList = {}
	end

	if useSingle ~= true then
		rewardList = array.concat(table.to_array(randomList), table.to_array(rewardList))
		randomList = {}
	end

	local sortCb = self.CreateAction(self, self.SortItem)

	table.sort(rewardList, sortCb)
	table.sort(randomList, sortCb)

	return rewardList, randomList
end

M.GetSingleSortedListRenderData = function(self, dropList)
	local rewardList = self.GetItemSortedListByDropList(self, dropList, true)
	local itemViews = {}

	for i = 1, #rewardList do
		local view = {
			itemId = rewardList[i].Id,
			itemNum = rewardList[i].Count,
			isFirstKill = rewardList[i].isFirstKill
		}

		table.insert(itemViews, self.GetItemRenderData(self, view))
	end

	return itemViews
end

M.GetSingleSortedListRenderDataByList = function(self, itemList)
	local itemViews = {}

	for i = 1, #itemList do
		local itemId = self.GetTemplateId(self, itemList[i])

		if itemId and itemId == 0 then
			local view = {
				itemId = itemId,
				itemNum = itemList[i].Count,
				isFirstKill = itemList[i].isFirstKill
			}
			view = table.combine(view, itemList[i])

			table.insert(itemViews, self.GetItemRenderData(self, view))
		end
	end

	table.sort(itemViews, self.CreateAction(self, "SortRenderItem"))

	return itemViews
end

M._AddFakeItemToDict = function(self, dict, itemId, count, isGot)
	local ret = self.GetFakeItemInfo(self, itemId, count, false)

	if not table.isNilOrEmpty(ret) then
		if dict[ret.Id] then
			dict[ret.Id].Count = dict[ret.Id].Count + ret.Count
		else
			dict[ret.Id] = ret
		end
	end
end

M.ConvertRewardInfos2ItemList = function(self, details)
	local itemDict = {}

	for i = 1, #details do
		local item = details[i]
		local rewardList = item.Reward

		for _, rewardDetail in pairs(rewardList) do
			for k, v in pairs(self.DropItemToFakeItem) do
				local item = rewardDetail[k]

				if item and item == 0 then
					self._AddFakeItemToDict(self, itemDict, v, item, false)
				end
			end

			if rewardDetail.Items then
				for _, item in ipairs(rewardDetail.Items) do
					self._AddFakeItemToDict(self, itemDict, item.TemplateId, item.Count, false)
				end
			end
		end
	end

	local itemList = table.to_array(itemDict)
	local sortCb = self.CreateAction(self, self.SortItem)

	table.sort(itemList, sortCb)

	return itemList
end
