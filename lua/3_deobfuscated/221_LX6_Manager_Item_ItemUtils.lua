local ConsumableConfig = LTConfig.ConsumableConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local CollectionSubQuestConfig = LTConfig.CollectionSubQuestConfig
local CollectionQuestConfig = LTConfig.CollectionQuestConfig
local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
local TaskTitle = require("LX6/Manager/Task/TaskTitle")
local TaskConfig = LTConfig.TaskConfig
local ItemReason = UX.Game.ItemReason
local TaskEventConfig = LTConfig.TaskEventConfig
local M = {
	GetQuality = function (self, templateId)
		local consumableCfg = ConsumableConfig.GetConfig(templateId)

		if consumableCfg then
			return consumableCfg.Quality
		end

		local fightSpiritCfg = FightSpiritConfig.GetConfig(templateId)

		if fightSpiritCfg then
			return 1
		end

		local stoneQuality = gStoneManager.GetStoneQuality(templateId)

		if stoneQuality then
			return stoneQuality
		end

		return 0
	end,
	GetItemName = function (self, templateId)
		local cfg = ConsumableConfig.GetConfig(templateId)

		if cfg == nil then
			return ""
		end

		return cfg.Name
	end,
	GetItemTemplateId = function (self, item)
		if item.templateId then
			return item.templateId
		elseif item.itemId then
			return item.itemId
		elseif item.TemplateId then
			return item.TemplateId
		elseif item.ItemId then
			return item.ItemId
		end

		return nil
	end,
	GetDropListItem = function (self, cfg, count)
		if not cfg then
			return nil
		end

		return {
			ItemId = cfg.Id,
			Cfg = cfg,
			Image = cfg.SItemIconId or cfg.IconId or cfg.resID or cfg.ImageId,
			ImageClipRange = {
				0,
				0,
				-1,
				-1
			},
			Count = count,
			Quality = cfg.Quality
		}
	end
}

function M:HandleCompleteParam(param, detail)
	local reason = detail.Reason
	local extraInfo = detail.ExtraInfo
	param.Param = param.Param or {}
	param.Param.TipType = param.Param.TipType or TaskTipsType.Task
	param.Param.taskState = gTaskManager.TaskState.Finish

	if reason == ItemReason.Collection then
		local collectionInfo = extraInfo and extraInfo.CollectionInfo

		if not collectionInfo or collectionInfo.SubQuestId == 0 and collectionInfo.BlockId == 0 then
			return
		end

		local subquestId = collectionInfo.SubQuestId
		local unlockCount = collectionInfo.Count
		local totalCount = collectionInfo.TotalCount

		if not subquestId or subquestId == 0 then
			param.Param.TipType = TaskTipsType.Tower
		else
			local subQuest = CollectionSubQuestConfig.GetConfig(subquestId)
			local quest = CollectionQuestConfig.GetConfig(subQuest.QuestCategory)
			param.Param.name = quest.QuestName
			param.Param.des = totalCount == unlockCount and LTConfig.TextScriptTextConfig.GetConfig(89900103).Text or unlockCount .. "/" .. totalCount
			param.Param.iconId = quest.SQuestIcon
			local taskConfig = TaskConfig.GetConfig(subQuest.TaskId)

			if taskConfig then
				local taskTitle = taskConfig.Title

				if taskTitle == TaskTitle.TanLaboratory or taskTitle == TaskTitle.CHALLENGE then
					param.Param.name = subQuest.QuestDescription .. LTConfig.TextScriptTextConfig.GetConfig(89900749).Text
				end
			end
		end
	elseif reason == ItemReason.Challenge then
		param.SkipDisplay = true
	elseif reason == ItemReason.Task then
		local taskCfg = TaskConfig.GetConfig(extraInfo.TaskId)

		if taskCfg then
			param.Param.taskState = gTaskManager.TaskState.Finish
			param.Param.name = taskCfg.Name .. LTConfig.TextScriptTextConfig.GetConfig(89900749).Text
		end
	elseif reason == ItemReason.TaskEvent then
		local eventCfg = TaskEventConfig.GetConfig(extraInfo.EventId)

		if eventCfg then
			param.Param.taskState = gTaskManager.TaskState.Finish
			param.Param.name = eventCfg.EventName .. LTConfig.TextScriptTextConfig.GetConfig(89900749).Text
		end
	end
end

function M:ConvertRewardDetail(detail)
	local popupParam = {}
	local rewardData = {
		CurrencyItems = {},
		Items = {},
		Stones = {},
		Fashions = {},
		FashionJob = {}
	}
	local rewardList = detail.Reward
	local currency = {}

	table.insert(currency, {
		KeyName = "Money",
		ItemId = ConsumableConfig.RewardMoney
	})
	table.insert(currency, {
		KeyName = "FreeGold",
		ItemId = ConsumableConfig.RewardGold
	})
	table.insert(currency, {
		KeyName = "BindingGold",
		ItemId = ConsumableConfig.RewardBindingGold
	})
	table.insert(currency, {
		KeyName = "PlayerExp",
		ItemId = ConsumableConfig.RewardExp
	})

	for _, rewardDetail in pairs(rewardList) do
		if currency then
			for _, v in ipairs(currency) do
				local vc = rewardDetail[v.KeyName]

				if vc ~= nil and vc ~= 0 then
					self:Append_Currency(rewardData.CurrencyItems, v.ItemId, vc)
				end
			end
		end

		if rewardDetail.Items then
			for _, item in ipairs(rewardDetail.Items) do
				self:Append_Item(rewardData.Items, item)
			end
		end

		if rewardDetail.UrbanAbilityInfo then
			local info = rewardDetail.UrbanAbilityInfo

			if info.Count > 0 then
				popupParam.SixDimsUrbanAbility = info
			end
		end

		if rewardDetail.JobExpInfo then
			local info = rewardDetail.JobExpInfo

			if not table.isNilOrEmpty(info) then
				popupParam.JobExpInfo = rewardDetail.JobExpInfo
				popupParam.Money = rewardDetail.Money
			end
		end

		if rewardDetail.EyeCoinRewardCount ~= 0 then
			self:Append_Item(rewardData.Items, {
				TemplateId = ConsumableConfig.RewardCoin,
				Count = rewardDetail.EyeCoinRewardCount
			})
		end
	end

	if detail.ExtraInfo and detail.ExtraInfo.BadgeIdList then
		local itemList = {}
		local badgeIdList = detail.ExtraInfo.BadgeIdList

		for i = 1, #badgeIdList do
			local badgeId = badgeIdList[i]
			local item = array.find_if(itemList, function (item)
				return item.TemplateId == badgeId
			end)

			if item then
				item.Count = item.Count + 1
			else
				table.insert(itemList, {
					Count = 1,
					TemplateId = badgeId
				})
			end
		end

		for _, item in ipairs(itemList) do
			self:Append_Item(rewardData.Items, item)
		end
	end

	popupParam.Rewards = gItemUtils:SortRewardData(rewardData)

	if detail.ExtraInfo and detail.ExtraInfo.JobExpInfo then
		local info = detail.ExtraInfo.JobExpInfo

		if not table.isNilOrEmpty(info) then
			info.Reward = detail.Reward
			popupParam.JobExpInfo = info
		end
	end

	if detail.FirstItemInfo then
		local firstGetIdList = detail.FirstItemInfo

		for i = 1, #popupParam.Rewards do
			if table.contains(firstGetIdList, popupParam.Rewards[i].TemplateId) then
				popupParam.Rewards[i].First = true
			end
		end
	end

	if detail.ExtraInfo and detail.ExtraInfo.AchievementInfo and #detail.ExtraInfo.AchievementInfo > 0 then
		popupParam.Achievements = detail.ExtraInfo.AchievementInfo
	end

	popupParam.AllItems = {}
	local allItems = popupParam.Rewards

	for i = 1, #allItems do
		if allItems[i].TemplateId then
			table.insert(popupParam.AllItems, {
				ItemId = allItems[i].TemplateId,
				Count = allItems[i].Count
			})
		elseif allItems[i].ItemId then
			table.insert(popupParam.AllItems, {
				ItemId = allItems[i].ItemId,
				Count = allItems[i].Count
			})
		end
	end

	self:HandleCompleteParam(popupParam, detail)

	if detail.ExtraInfo and detail.ExtraInfo.CollectionInfo and detail.ExtraInfo.CollectionInfo.InvestigatorGalleryId and detail.ExtraInfo.CollectionInfo.InvestigatorGalleryId ~= 0 then
		popupParam.InvestigatorGalleryId = detail.ExtraInfo.CollectionInfo.InvestigatorGalleryId
	end

	if detail.ExtraInfo and detail.ExtraInfo.ExpInfo and detail.ExtraInfo.ExpInfo.ExpAdd > 0 then
		popupParam.PlayerExpInfo = detail.ExtraInfo.ExpInfo
	end

	if detail.ExtraInfo and detail.ExtraInfo.UniqueId then
		popupParam.Uid = detail.ExtraInfo.UniqueId
	end

	popupParam.Reason = detail.Reason

	return popupParam
end

function M:SortRewardData(rewardData)
	local sortedItemList = self:SortItems(nil, {
		itemType = gLuaEnum.CanSortItemType.BaseItem,
		itemDataList = rewardData.Items
	}, {
		itemType = gLuaEnum.CanSortItemType.Weapon,
		itemDataList = rewardData.Stones
	}, {
		itemType = gLuaEnum.CanSortItemType.CurrencyItem,
		itemDataList = rewardData.CurrencyItems
	})
	local items = {}

	for _, v in ipairs(sortedItemList) do
		array.concat(items, v.itemDataList)
	end

	return items
end

local sortKeyList = {}
M.DefaultSortKey = {
	{
		desc = false,
		key = "Sort"
	},
	{
		desc = true,
		key = "Quality"
	}
}

function M:SortItems(defaultSortKey, ...)
	if defaultSortKey == nil then
		defaultSortKey = self.DefaultSortKey
	end

	for i, v in pairs({
		...
	}) do
		sortKeyList = {}

		if not table.isNilOrEmpty(v.sortKeyMap) then
			for j = 1, #defaultSortKey do
				local defaultSortKey = defaultSortKey[j]
				local key = defaultSortKey.key
				local defaultDesc = defaultSortKey.desc
				local overrideInfo = v.sortKeyMap[key]

				if overrideInfo then
					if type(overrideInfo) ~= "table" then
						table.insert(sortKeyList, {
							key = overrideInfo,
							desc = defaultDesc
						})
					else
						table.insert(sortKeyList, {
							key = overrideInfo.key,
							desc = overrideInfo.desc
						})
					end
				else
					table.insert(sortKeyList, defaultSortKey)
				end
			end
		else
			sortKeyList = defaultSortKey
		end

		table.sort(v.itemDataList, M._CompareItems)
	end

	local rTable = {
		...
	}

	table.sort(rTable, function (a, b)
		return a.itemType < b.itemType
	end)

	return rTable
end

function M._CompareItems(data1, data2)
	for i = 1, #sortKeyList do
		local sortKeyInfo = sortKeyList[i]

		if data1[sortKeyInfo.key] ~= nil and data2[sortKeyInfo.key] ~= nil and data1[sortKeyInfo.key] ~= data2[sortKeyInfo.key] then
			if sortKeyInfo.desc then
				return data2[sortKeyInfo.key] < data1[sortKeyInfo.key]
			else
				return data1[sortKeyInfo.key] < data2[sortKeyInfo.key]
			end
		end
	end

	return false
end

function M.SortByItemType(a, b)
	if a.Quality == b.Quality then
		if a.SortItemType == b.SortItemType then
			return M:GetItemTemplateId(a) < M:GetItemTemplateId(b)
		else
			return a.SortItemType < b.SortItemType
		end
	else
		return b.Quality < a.Quality
	end
end

function M:Append_Currency(rewardDetail, itemId, count)
	if count == 0 then
		return nil
	end

	if rewardDetail ~= nil then
		for _, v in ipairs(rewardDetail) do
			if v.ItemId == itemId then
				v.Count = v.Count + count

				return v
			end
		end
	end

	local cfg = ConsumableConfig.GetConfig(itemId)

	if cfg == nil then
		return nil
	end

	local item = {
		Sort = 0,
		ItemId = itemId,
		Icon = cfg.SItemIconId,
		Count = count,
		Quality = cfg.Quality,
		ItemType = gLuaEnum.ItemInfoType.BaseItem
	}

	if rewardDetail ~= nil then
		table.insert(rewardDetail, item)
	end

	return item
end

function M:Append_Item(items, item)
	local cfg = ConsumableConfig.GetConfig(item.TemplateId)

	if cfg ~= nil and cfg.ShowDropResult then
		return self:Append_Item_Merge(item, items, cfg, gLuaEnum.ItemInfoType.BaseItem)
	end

	return nil
end

function M:Append_Item_Merge(item, items, cfg, itemType, raidRewardType)
	local it = items[item.TemplateId]

	if it ~= nil and it.RaidRewardType == raidRewardType then
		it.Count = it.Count + item.Count

		return it
	end

	local element = {
		ItemId = item.TemplateId,
		Icon = cfg.SItemIconId,
		Count = item.Count,
		Quality = cfg.Quality,
		ItemType = itemType,
		RaidRewardType = raidRewardType,
		First = item.First,
		StoneInfo = item.StoneInfo
	}

	if cfg.Sort ~= nil then
		element.Sort = cfg.Sort
	end

	table.insert(items, element)

	return element
end

gItemUtils = M
