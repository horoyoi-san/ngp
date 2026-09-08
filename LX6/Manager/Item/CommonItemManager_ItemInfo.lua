-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_ItemInfo.lua
-- Decompiled from: 02206_CommonItemManager_ItemInfo.lua_e271b962e57b.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local DecorationConfig = LTConfig.DecorationConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local ITEM_QUALITY_FIELD = {
	[ConsumableConfig.QualityType.White] = "White",
	[ConsumableConfig.QualityType.GreenGrey] = "GreenGrey",
	[ConsumableConfig.QualityType.Green] = "Green",
	[ConsumableConfig.QualityType.Blue] = "Blue",
	[ConsumableConfig.QualityType.Purple] = "Purple",
	[ConsumableConfig.QualityType.Gold] = "Gold",
	[ConsumableConfig.QualityType.Orange] = "Orange",
	[ConsumableConfig.QualityType.NoQuality] = "NoQuality"
}
local M = C_CommonItemManager

M.TryGetConsumableItem = function(self, itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		return nil
	end

	local ret = {
		["\\xd4\\xd4\r\\xf5"] = 0,
		["ZI鴂\\x88\\xca\\xe3"] = false,
		name = cfg.Name,
		iconId = cfg.SItemIconId,
		description = cfg.Description or " ",
		shortDesc = cfg.ShortDescription or " ",
		templateId = itemId,
		rewardList = {},
		quality = cfg.Quality
	}

	return ret
end

M.TryGetMallItem = function(self, itemId)
	local cfg = MallCommodityConfig.GetConfig(itemId)

	if not cfg then
		return nil
	end

	local rewardList, templateId = self:GetRewardList(cfg.DropId)
	local refreshTime = cfg.RefreshTime and gCS.LuaUtils.GetNextTime(cfg.RefreshTime) - gCS.TimeManager.ServerUnixTime or -1
	local ret = {
		["\\xd4\\xd4\r\\xf5"] = 0,
		name = cfg.Name,
		iconId = cfg.Picture,
		description = cfg.Desc,
		templateId = templateId,
		rewardList = rewardList,
		discount = cfg.DiscountPrice and cfg.DiscountPrice <= 0 and cfg.Price and cfg.Price <= 0 and cfg.DiscountPrice / cfg.Price or 1,
		refreshTime = refreshTime,
		crontabTime = cfg.RefreshTime,
		price = cfg.Price,
		limitNum = cfg.LimitNum or 0
	}

	return ret
end

M.GetItemNum = function(self, itemId, isTarkov)
	if itemId ~= ConsumableConfig.ActionPoint then
		return gPlayerManager.infoMinorNpcCultivation.bindData.InteractPoint
	end

	local num = self.GetPackItemNum(self, itemId, isTarkov)

	if self.IsMoneyItem(self, itemId) then
		return self.BuildLargeNum(self, num)
	end

	return num
end

M.GetSystemPrice = function(self, itemId)
	if self._fishSystemPriceCache == nil then
		local price = self._fishSystemPriceCache
		self._fishSystemPriceCache = nil

		return price
	end

	if self.CheckIsWeapon(self, itemId) then
		local weaponCfg = self:GetSceneitemCfg(itemId)

		return weaponCfg and weaponCfg.SystemPrice or 0
	end

	local cfg = ConsumableConfig.GetConfig(itemId)

	return cfg and cfg.SystemPrice or 0
end

M.TryGetItemInfo = function(self, data)
	local ret = {}
	ret = self._TryGetFishInfo(self, data)

	if not table.isNilOrEmpty(ret) then
		return table.combine(data, ret)
	end

	ret = self._TryGetItemInfo(self, data)

	if not table.isNilOrEmpty(ret) then
		return table.combine(data, ret)
	end

	ret = self._TryGetFashionInfo(self, data)

	if not table.isNilOrEmpty(ret) then
		return table.combine(data, ret)
	end

	local fromConsume = data and data.fromConsume or nil

	if fromConsume ~= nil then
		fromConsume = true
	end

	ret = self.TryGetWeaponInfo(self, data, fromConsume)

	if not table.isNilOrEmpty(ret) then
		return table.combine(data, ret)
	end

	ret = self._TryGetVechicleInfo(self, data)

	if not table.isNilOrEmpty(ret) then
		return table.combine(data, ret)
	end

	return table.combine(data, ret)
end

M._TryGetFishInfo = function(self, data)
	if not data then
		return nil
	end

	local itemId = self.GetTemplateId(self, data)

	if not itemId then
		return nil
	end

	local fishItem = nil

	if data._isFish then
		fishItem = data
	elseif data.UniqueId then
		fishItem = self.packItemDict[data.UniqueId]
	end

	if not fishItem then
		return nil
	end

	local fishCfg = LTConfig.FishingFishConfig.GetConfig(itemId)

	if not fishCfg then
		return nil
	end

	local weight = fishItem._weight or 0
	local length = fishItem._length or 0
	local systemPrice = 0

	if fishCfg.ConsumableId and fishCfg.ConsumableId == 0 then
		local consumableCfg = ConsumableConfig.GetConfig(fishCfg.ConsumableId)

		if consumableCfg and consumableCfg.SystemPrice then
			systemPrice = math.floor(weight * consumableCfg.SystemPrice)
		end
	end

	self._fishSystemPriceCache = systemPrice

	return {
		["POc{Z:;"] = "",
		["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
		["POc~m,"] = false,
		name = fishCfg.Name,
		fishSizeText = string.format(LTConfig.FishingConfig.FishSizeFormat, weight, length),
		iconId = fishCfg.IconRes,
		description = fishCfg.Description or "",
		itemId = itemId,
		quality = fishCfg.Quality,
		subType = ConsumableTypeConfig.Fish,
		rewardList = {}
	}
end

M.GetFishSubQualityCtrl = function(self, fishItem)
	if not fishItem or not fishItem._isFish then
		return self.SUB_QUALITY_CTRL.NONE
	end

	local explicitQuality = fishItem._secondQuality or fishItem.SecondQuality

	if type(explicitQuality) ~= "number" and self.SUB_QUALITY_CTRL.D < explicitQuality and explicitQuality < self.SUB_QUALITY_CTRL.S then
		return explicitQuality
	end

	local fishCfg = LTConfig.FishingFishConfig.GetConfig(fishItem.TemplateId)

	if not fishCfg then
		return self.SUB_QUALITY_CTRL.NONE
	end

	local consumableCfg = ConsumableConfig.GetConfig(fishCfg.ConsumableId)
	local thresholds = consumableCfg and consumableCfg.SecondQuality
	local thresholdCount = thresholds and #thresholds or 0

	if thresholdCount ~= 0 then
		return self.SUB_QUALITY_CTRL.D
	end

	local weight = fishItem._weight or fishItem.Weight or 0
	local quality = self.SUB_QUALITY_CTRL.D

	if thresholdCount ~= 4 then
		for i = 1, thresholdCount do
			if thresholds[i] < weight then
				quality = math.min(self.SUB_QUALITY_CTRL.D + i, self.SUB_QUALITY_CTRL.S)
			else
				break
			end
		end
	else
		for i = 1, math.min(thresholdCount, self.SUB_QUALITY_CTRL.S) do
			if thresholds[i] < weight then
				quality = i
			else
				break
			end
		end
	end

	return quality
end

M._TryGetItemInfo = function(self, data)
	local itemId = self.GetTemplateId(self, data)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		return nil
	end

	local ret = {
		name = cfg.Name,
		iconId = cfg.SItemIconId,
		description = cfg.Description or "",
		shortDesc = cfg.ShortDescription or "",
		itemId = itemId,
		quality = cfg.Quality,
		subType = cfg.SubType,
		showCount = cfg.IfShowHoldNum,
		showSource = data.showSource ~= nil and true or data.showSource,
		rewardList = {}
	}
	local addition = {}

	if cfg.SubType then
		addition = table.combine(addition, self.GetAdditionInfoBySubType(self, cfg.SubType, data))
	end

	if cfg.Drop == 0 then
		addition = table.combine(addition, self.GetAdditionInfoByDropId(self, cfg.Drop, data))
	end

	if not table.isNilOrEmpty(addition) then
		ret = table.combine(ret, addition)
	end

	if cfg.BindId and cfg.BindId == 0 and not data._fromBindId then
		local bindData = {
			["\\xa0220u\\xbfH\\xd73\\x83\\xbd"] = true,
			itemId = cfg.BindId
		}
		local bindRet = self.TryGetItemInfo(self, bindData)

		if not table.isNilOrEmpty(bindRet) then
			ret = table.combine(bindRet, ret)
		end
	end

	if cfg.SubType ~= ConsumableTypeConfig.Decoration and cfg.BindId and cfg.BindId == 0 then
		local decoCfg = DecorationConfig.GetConfig(cfg.BindId)

		if decoCfg then
			ret.iconId = decoCfg.Icon
		end
	end

	return ret
end

M._TryGetFashionInfo = function(self, data)
	local itemId = self.GetTemplateId(self, data)
	local cfg, isSuit = self._TryGetFashinConfig(self, itemId)

	if not cfg then
		return nil
	end

	local ret = {
		["POc{Z:;"] = "",
		["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
		["POc~m,"] = false,
		name = cfg.Name,
		iconId = cfg.Icon,
		description = cfg.Description,
		itemId = itemId,
		quality = cfg.Quality,
		subType = ConsumableTypeConfig.Fashion
	}

	return ret
end

M.GetAdditionInfoByDropId = function(self, dropId, data)
	local rewardList, _ = self.GetRewardList(self, dropId)

	if table.isNilOrEmpty(rewardList) then
		return {}
	end

	return {
		rewardList = rewardList
	}
end

M.GetAdditionInfoBySubType = function(self, subType, data)
	if subType ~= ConsumableTypeConfig.Favor then
		if not data.spiritId then
			print_error("C_CommonItemManager 错误的道具信息，没有spiritId")

			return {}
		end

		local cfg = NpcCultivationConfig.GetConfig(data.spiritId)

		if not cfg then
			print_error("C_CommonItemManager 错误的道具信息，没有spiritId对应的NpcCultivationConfig")

			return {}
		end

		local name = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901031).Text, cfg.Name)
		local desc = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901032).Text, cfg.Name)

		return {
			["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
			["POc~m,"] = false,
			iconId = cfg.SChatHeadId,
			name = name,
			description = NpcCultivationConfig.FavorDescription,
			shortDesc = desc
		}
	end

	if subType ~= ConsumableTypeConfig.UrbanAttr then
		return {
			["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
			["POc~m,"] = false
		}
	end

	return {}
end

M.GetItemDescList = function(self, data, ret)
	local hasSource = false
	local skipCommonDesc = false

	if data and data.itemId then
		if self.CheckIsWeapon(self, data.itemId) then
			array.concat(ret, self.GetWeaponPreDesc(self, data.itemId, data.UniqueId, data.isTarkov, data.gamePlayTypeId))

			skipCommonDesc = true
		elseif self.CheckIsDecoartion(self, data.itemId) then
			array.concat(ret, self.GetDecoartionPreDesc(self, data.itemId))

			skipCommonDesc = true
		end
	end

	local hasShort = not string.is_null_or_empty(data.shortDesc)
	local hasDes = not string.is_null_or_empty(data.description)

	if not skipCommonDesc and (hasShort or hasDes) then
		table.insert(ret, {
			tIndex = self.Template2Index.Title,
			text = LTConfig.TextScriptTextConfig.GetConfig(89901023).Text
		})

		if hasShort then
			table.insert(ret, {
				tIndex = self.Template2Index.MAIN_TEXT,
				text = data.shortDesc
			})
		end

		if hasDes then
			table.insert(ret, {
				tIndex = self.Template2Index.SEC_TEXT,
				text = data.description
			})
		end
	end

	if data.showSource ~= true then
		local sourceList = gItemHyperLinkManager:GetItemHyperLink(data.itemId)

		if not table.isNilOrEmpty(sourceList) then
			array.concat(ret, sourceList)

			hasSource = true
		end
	end

	if not table.isNilOrEmpty(data.rewardList) then
		table.insert(ret, {
			tIndex = self.Template2Index.Title,
			text = LTConfig.TextScriptTextConfig.GetConfig(89900929).Text
		})
		table.insert(ret, {
			tIndex = self.Template2Index.REWARD_LIST,
			rewardList = data.rewardList
		})
	end

	if data.warnText then
		table.insert(ret, {
			tIndex = self.Template2Index.WARN_TEXT,
			text = data.warnText
		})
	end

	return hasSource
end

M.GetItemElementList = function(self, id, data)
	local elementList = {}

	if data and data.fishSizeText then
		table.insert(elementList, {
			iconId = LTConfig.FishingConfig.FishSizeIconId,
			name = data.fishSizeText
		})
	end

	local itemId = self.GetTemplateId(self, {
		itemId = id
	})

	if self.CheckIsWeapon(self, itemId) then
		elementList = self.GetWeaponElements(self, itemId)
	end

	return elementList
end

M.GetItemQualityLabel = function(self, data)
	if not data then
		return ""
	end

	local typeConfig = ConsumableTypeConfig.GetConfig(data.subType)

	if not typeConfig then
		return ""
	end

	local qualityField = ITEM_QUALITY_FIELD[data.quality] or "NoQuality"
	local qualityText = typeConfig[qualityField]

	if string.is_null_or_empty(qualityText) then
		return typeConfig.Description or ""
	end

	return gString.Format("{0}·{1}", typeConfig.Description or "", qualityText)
end
