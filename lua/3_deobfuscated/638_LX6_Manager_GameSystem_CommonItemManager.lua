local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local FactionConfig = LTConfig.FactionConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local NpcShopCommodityCfg = LTConfig.ShopCommodityConfig
local MoneyType = UX.Game.MoneyType
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local DropConfig = LTConfig.DropConfig
local FashionConfig = LTConfig.FashionConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local VehicleConfig = LTConfig.VehicleConfig
local VehicleTypeConfig = LTConfig.VehicleTypeConfig
local HouseConfig = LTConfig.HouseConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local AgentConfig = LTConfig.AgentConfig
local AgentSpecificTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local PhoneConfig = LTConfig.PhoneContactConfig
local StaticProps = {
	ITEM_TYPE = {
		URBAN_ATTR = 6,
		COMMON_ITEM = 1,
		WEAPON = 3,
		FAVOR = 2,
		STONE = 4,
		UNKNOWN = 0
	},
	Template2Index = {
		DIEKA_TEXT = 3,
		SEC_TEXT = 1,
		HYPER_LINK = 5,
		REWARD_LIST = 6,
		WARN_TEXT = 7,
		MAIN_TEXT = 2,
		ICON_TEXT = 4,
		Title = 0
	},
	CommonItemRenderSizeCtl = {
		NORMAL = 0,
		SMALL = 1
	},
	CommonItemRenderCountCtl = {
		UP = 1,
		DOWN = 0
	},
	DropItemToFakeItem = {
		Money = ConsumableConfig.RewardMoney,
		BindingGold = ConsumableConfig.RewardBindingGold
	},
	HIDE_QUALITY = ConsumableConfig.QualityType.NoQuality
}
C_CommonItemManager = DefClass("C_CommonItemManager", C_CommonItemManager, nil, StaticProps)
local M = C_CommonItemManager

function M:ctor()
	self.itemCountLimitMax = {}
	self.showItemNumSubType = {}
	self.quantumWalletStartTime = 0
	self.ITEM_TYPE = {
		FASHION_SUIT = 3,
		COMMON = 0,
		PHONE_THEME = 4,
		FASHION = 2,
		VEHICLE = 1
	}
	self.SUBTYPE2ITEM_TYPE = {
		[LTConfig.ConsumableTypeConfig.Vehicle] = self.ITEM_TYPE.VEHICLE,
		[LTConfig.ConsumableTypeConfig.Fashion] = self.ITEM_TYPE.FASHION,
		[LTConfig.ConsumableTypeConfig.PhoneTheme] = self.ITEM_TYPE.PHONE_THEME
	}
end

function M:OnInit()
	self.itemLimitDict = {}
	self.viewItemList = {}
	self.enableExchange = false
	local itemSortPower = {}

	for i = 1, #DropConfig.ItemShowRank do
		itemSortPower[DropConfig.ItemShowRank[i]] = i
	end

	for i = 1, #DropConfig.HighValuableRank do
		itemSortPower[DropConfig.HighValuableRank[i]] = 0
	end

	for i = 1, #DropConfig.LowValuableRank do
		itemSortPower[DropConfig.LowValuableRank[i]] = math.huge
	end

	self.itemSortPower = itemSortPower
	self.itemToolTipRefBtn = nil
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:OnInit()
	end
end

function M:GetTemplateId(data)
	if data.templateId then
		return data.templateId
	elseif data.TemplateId then
		return data.TemplateId
	elseif data.itemId then
		return data.itemId
	elseif data.ItemId then
		return data.ItemId
	elseif data.Id then
		return data.Id
	end
end

function M:TryGetConsumableItem(itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		return nil
	end

	local ret = {
		moneyId = 0,
		isGiftPack = false,
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

function M:TryGetMallItem(itemId)
	local cfg = MallCommodityConfig.GetConfig(itemId)

	if not cfg then
		return nil
	end

	local rewardList, templateId = self:GetRewardList(cfg.DropID)
	local refreshTime = cfg.RefreshTime and gCS.LuaUtils.GetNextTime(cfg.RefreshTime) - gCS.TimeManager.ServerUnixTime or -1
	local ret = {
		moneyId = 0,
		isGiftPack = cfg.IfGiftPack,
		name = cfg.CommodityName,
		iconId = cfg.SCommodityIcon,
		description = cfg.Description,
		shortDesc = cfg.ShortDescription,
		templateId = templateId,
		rewardList = rewardList,
		unLockDesc = cfg.UnlockConditionInfo,
		discount = cfg.Discount,
		refreshTime = refreshTime,
		crontabTime = cfg.RefreshTime,
		price = cfg.Price,
		quality = cfg.Quality,
		limitNum = cfg.LimitNum or 0
	}

	return ret
end

function M:GetItemNum(itemId)
	if itemId == ConsumableConfig.ActionPoint then
		return gPlayerManager.infoMinorNpcCultivation.bindData.InteractPoint
	end

	return gPlayerItemManager:GetPackItemNum(itemId)
end

function M:TryGetItemInfo(data)
	local ret = {}
	ret = self:_TryGetItemInfo(data)

	if not table.isNilOrEmpty(ret) then
		return table.combine(data, ret)
	end

	ret = self:_TryGetFashionInfo(data)

	if not table.isNilOrEmpty(ret) then
		return table.combine(data, ret)
	end

	local fromConsume = data and data.fromConsume or nil

	if fromConsume == nil then
		fromConsume = true
	end

	ret = gWeaponManager:TryGetWeaponInfo(data, fromConsume)

	if not table.isNilOrEmpty(ret) then
		return table.combine(data, ret)
	end

	ret = self:_TryGetVechicleInfo(data)

	if not table.isNilOrEmpty(ret) then
		return table.combine(data, ret)
	end

	return table.combine(data, ret)
end

function M:_TryGetItemInfo(data)
	local itemId = self:GetTemplateId(data)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		return nil
	end

	local showCount = self:GetShowItemNumSubType()[cfg.SubType] or false
	local ret = {
		name = cfg.Name,
		iconId = cfg.SItemIconId,
		description = cfg.Description,
		shortDesc = cfg.ShortDescription,
		itemId = itemId,
		quality = cfg.Quality,
		subType = cfg.SubType,
		additionType = M.ITEM_TYPE.COMMON_ITEM,
		showCount = showCount and cfg.IfShowHoldNum,
		showSource = data.showSource == nil and true or data.showSource,
		rewardList = {}
	}
	local addition = {}

	if cfg.SubType then
		addition = table.combine(addition, self:GetAdditionInfoBySubType(cfg.SubType, data))
	end

	if cfg.Drop ~= 0 then
		addition = table.combine(addition, self:GetAdditionInfoByDropId(cfg.Drop, data))
	end

	if not table.isNilOrEmpty(addition) then
		ret = table.combine(ret, addition)
	end

	return ret
end

function M:_TryGetFashionInfo(data)
	local itemId = self:GetTemplateId(data)
	local cfg, isSuit = self:_TryGetFashinConfig(itemId)

	if not cfg then
		return nil
	end

	local ret = {
		showSource = false,
		shortDesc = "",
		showCount = false,
		name = cfg.Name,
		iconId = cfg.Icon,
		description = cfg.Description,
		itemId = itemId,
		quality = cfg.Quality,
		subType = ConsumableTypeConfig.Fashion,
		additionType = M.ITEM_TYPE.COMMON_ITEM
	}

	return ret
end

function M:GetAdditionInfoByDropId(dropId, data)
	local rewardList, _ = self:GetRewardList(dropId)

	if table.isNilOrEmpty(rewardList) then
		return {}
	end

	return {
		rewardList = rewardList
	}
end

function M:GetAdditionInfoBySubType(subType, data)
	if subType == ConsumableTypeConfig.Favor then
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
			showSource = false,
			showCount = false,
			additionType = M.ITEM_TYPE.FAVOR,
			iconId = cfg.SChatHeadId,
			name = name,
			description = NpcCultivationConfig.FavorDescription,
			shortDesc = desc
		}
	end

	if subType == ConsumableTypeConfig.UrbanAttr then
		return {
			showCount = false,
			showSource = false,
			additionType = M.ITEM_TYPE.URBAN_ATTR
		}
	end

	return {}
end

function M:GetItemDescList(data, ret)
	local hasSource = false
	local hasShort = not string.is_null_or_empty(data.shortDesc)
	local hasDes = not string.is_null_or_empty(data.description)

	if hasShort or hasDes then
		table.insert(ret, {
			tIndex = StaticProps.Template2Index.Title,
			text = LTConfig.TextScriptTextConfig.GetConfig(89901023).Text
		})

		if hasShort then
			table.insert(ret, {
				tIndex = StaticProps.Template2Index.MAIN_TEXT,
				text = data.shortDesc
			})
		end

		if hasDes then
			table.insert(ret, {
				tIndex = StaticProps.Template2Index.SEC_TEXT,
				text = data.description
			})
		end
	end

	if data.showSource == true then
		local sourceList = gItemHyperLinkManager:GetItemHyperLink(data.itemId)

		if not table.isNilOrEmpty(sourceList) then
			array.concat(ret, sourceList)

			hasSource = true
		end
	end

	if not table.isNilOrEmpty(data.rewardList) then
		table.insert(ret, {
			tIndex = StaticProps.Template2Index.Title,
			text = LTConfig.TextScriptTextConfig.GetConfig(89900929).Text
		})
		table.insert(ret, {
			tIndex = StaticProps.Template2Index.REWARD_LIST,
			rewardList = data.rewardList
		})
	end

	if data.warnText then
		table.insert(ret, {
			tIndex = StaticProps.Template2Index.WARN_TEXT,
			text = data.warnText
		})
	end

	return hasSource
end

function M:GetItemIdByMoneyType(moneyType)
	if moneyType == MoneyType.Money then
		return ConsumableConfig.RewardMoney
	elseif moneyType == MoneyType.Gold then
		return ConsumableConfig.RewardGold
	elseif moneyType == MoneyType.BindingGold then
		return ConsumableConfig.RewardBindingGold
	else
		return 0
	end
end

function M:GetMoneyImageConfigIdByType(moneyType)
	local cfg = ConsumableConfig.GetConfig(self:GetItemIdByMoneyType(moneyType))

	return cfg and cfg.SMoneyIconId or 0
end

function M:GetMoneyIconAndCount(itemTypeOrId)
	local moneyType = table.contains(MoneyType, itemTypeOrId) and itemTypeOrId or gUIUtils:GetMoneyType(itemTypeOrId)

	if moneyType ~= MoneyType.Default then
		return self:GetMoneyImageConfigIdByType(moneyType), gUIUtils:GetMoneyByType(moneyType)
	end

	local cfg = ConsumableConfig.GetConfig(itemTypeOrId)

	return cfg and cfg.SMoneyIconId, self:GetItemNum(itemTypeOrId) or 0, 0
end

function M:OnSyncQuantumWalletInfo(time)
	self.quantumWalletStartTime = time
end

function M:GetQuantumWalletMoney()
	return Formula_cs:CalcQuantumWalletReward(self.quantumWalletStartTime, gCS.TimeManager.ServerUnixTime)
end

function M:GetShowItemNumSubType()
	if not table.isNilOrEmpty(self.showItemNumSubType) then
		return self.showItemNumSubType
	end

	for i = 4, 7 do
		local tabTypes = gPlayerItemManager.subTypes[i]

		for j = 1, #tabTypes do
			local tabTypeVal = ConsumableTypeConfig[tabTypes[j]]

			if tabTypeVal then
				self.showItemNumSubType[tabTypeVal] = true
			end
		end
	end

	return self.showItemNumSubType
end

function M:IsItemNumDisabled(itemId)
	for i = 1, #ConsumableConfig.BlockItemInfoShowNumItems do
		if ConsumableConfig.BlockItemInfoShowNumItems[i] == itemId then
			return true
		end
	end

	return false
end

function M:RefreshItemCountLimit()
	for i = 1, #gPlayerManager.infoItem.bindData.itemCountLimitInfoList do
		local item = gPlayerManager.infoItem.bindData.itemCountLimitInfoList[i]
		self.itemLimitDict[item.ItemId] = item
	end

	if table.isNilOrEmpty(self.itemCountLimitMax) then
		for i = 1, #ConsumableConfig.ItemCountLimitInfoList do
			local item = ConsumableConfig.ItemCountLimitInfoList[i]
			self.itemCountLimitMax[item.ItemId] = item.MaxCount
		end
	end
end

function M:GetItemTotalCDTime(itemId)
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

function M:GetRewardList(dropId)
	local rewardList = {}
	local templateId = 0
	local dropItemList = self:GetItemSortedListByDropList(dropId, true)

	if table.isNilOrEmpty(dropItemList) then
		return rewardList, templateId
	end

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

	return rewardList, templateId
end

function M:GetItemSortPower(item)
	return math.min(self.itemSortPower[item.SubType], self.itemSortPower[item.Id] or math.huge)
end

function M:SortItem(a, b)
	if a.Quality ~= b.Quality then
		return b.Quality < a.Quality
	end

	local aPower = self:GetItemSortPower(a)
	local bPower = self:GetItemSortPower(b)

	if aPower ~= bPower then
		return aPower < bPower
	end

	return a.Id < b.Id
end

function M:GetRenderItemSortPower(item)
	return math.min(self.itemSortPower[item.subType] or math.huge, self.itemSortPower[item.itemId] or math.huge)
end

function M:SortRenderItem(a, b)
	if a.quality ~= b.quality then
		return b.quality < a.quality
	end

	local aPower = self:GetRenderItemSortPower(a)
	local bPower = self:GetRenderItemSortPower(b)

	if aPower ~= bPower then
		return aPower < bPower
	end

	return a.itemId < b.itemId
end

function M:GetFakeItemInfo(itemId, count, isGot)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg or self.itemSortPower[cfg.SubType] == nil and self.itemSortPower[cfg.Id] == nil then
		return {}
	end

	local ret = {
		isFirstKill = false,
		Id = itemId,
		Quality = cfg.Quality,
		SubType = cfg.SubType,
		Count = count,
		isGot = isGot
	}

	return ret
end

function M:ConvertDropToFakeItem(dropId, count)
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

	for k, v in pairs(M.DropItemToFakeItem) do
		local item = cfg[k]

		if item and item ~= 0 then
			local ret = self:GetFakeItemInfo(v, item * count, isGot)

			if not table.isNilOrEmpty(ret) then
				table.insert(itemList, ret)
			end
		end
	end

	if not table.isNilOrEmpty(cfg.NpcFavor) then
		for i = 1, #cfg.NpcFavor do
			local ret = self:GetFakeItemInfo(ConsumableConfig.NpcFavor, cfg.NpcFavor[i].count * count)

			if not table.isNilOrEmpty(ret) then
				ret.spiritId = cfg.NpcFavor[i].Npcid

				table.insert(itemList, ret)
			end
		end
	end

	if not table.isNilOrEmpty(cfg.Fan) then
		local ret = self:GetFakeItemInfo(ConsumableConfig.RewardFan, "", isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(itemList, ret)
		end
	end

	if cfg.Popularity > 0 then
		local ret = self:GetFakeItemInfo(ConsumableConfig.RewardPopularity, "", isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(itemList, ret)
		end
	end

	local item = cfg.Item1

	for i = 1, #item do
		local itemId = item[i].id1
		local ret = self:GetFakeItemInfo(itemId, item[i].count * count, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(itemList, ret)
		end
	end

	item = cfg.Item2

	for i = 1, #item do
		local itemId = item[i].id2
		local ret = self:GetFakeItemInfo(itemId, 0, isGot)

		if not table.isNilOrEmpty(ret) then
			ret.Count = "x" .. item[i].min * count .. " - " .. item[i].max * count

			table.insert(randomList, ret)
		end
	end

	item = cfg.Item3

	for i = 1, #item do
		local itemId = item[i].id3
		local ret = self:GetFakeItemInfo(itemId, 0, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(randomList, ret)
		end
	end

	item = cfg.Item4Range

	for i = 1, #item do
		local itemId = item[i].id4
		local ret = self:GetFakeItemInfo(itemId, 0, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(randomList, ret)
		end
	end

	local faction = cfg.FactionInfo

	for i = 1, #faction do
		local fCfg = FactionConfig.GetConfig(faction[i].FactionId)

		if fCfg and fCfg.DispositionItem ~= 0 then
			local ret = self:GetFakeItemInfo(fCfg.DispositionItem, faction[i].Disposition * count, isGot)

			if not table.isNilOrEmpty(ret) then
				table.insert(itemList, ret)
			end
		else
			local ret = self:GetFakeItemInfo(FactionConfig.DefaultDispositionItem, faction[i].Disposition * count, isGot)

			if not table.isNilOrEmpty(ret) then
				table.insert(itemList, ret)
			end
		end
	end

	local talentPoint = cfg.CommonSpiritTalentExp + cfg.SpiritTalentExp

	if talentPoint > 0 then
		local ret = self:GetFakeItemInfo(ConsumableConfig.CommonTalentExp, talentPoint * count, isGot)

		if not table.isNilOrEmpty(ret) then
			table.insert(itemList, ret)
		end
	end

	return itemList, randomList
end

function M:GetItemSortedListByDropList(dropList, useSingle)
	if type(dropList) == "number" then
		local dropId = dropList
		dropList = {}

		table.insert(dropList, {
			dropId = dropId
		})
	end

	local rewardList = {}
	local randomList = {}

	for i = 1, #dropList do
		if dropList[i].dropId ~= 0 then
			local itemList, rList = self:ConvertDropToFakeItem(dropList[i].dropId, dropList[i].count)

			if #dropList == 1 then
				rewardList = itemList
				randomList = rList
			else
				for j = 1, #itemList do
					itemList[j].isFirstKill = dropList[i].isFirstKill
					rewardList[itemList[j].Id] = itemList[j]
				end

				for j = 1, #rList do
					rList[j].isFirstKill = dropList[i].isFirstKill
					randomList[rList[j].Id] = rList[j]
				end
			end
		end
	end

	if #dropList > 1 then
		randomList = array.concat(table.to_array(randomList), table.to_array(rewardList))
		rewardList = {}
	end

	if useSingle == true then
		rewardList = array.concat(table.to_array(randomList), table.to_array(rewardList))
		randomList = {}
	end

	table.sort(rewardList, self:CreateAction("SortItem", gCommonItemManager))
	table.sort(randomList, self:CreateAction("SortItem", gCommonItemManager))

	return rewardList, randomList
end

function M:GetSingleSortedListRenderData(dropList)
	local rewardList = self:GetItemSortedListByDropList(dropList, true)
	local itemViews = {}

	for i = 1, #rewardList do
		local view = {
			itemId = rewardList[i].Id,
			itemNum = rewardList[i].Count,
			countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP,
			isFirstKill = rewardList[i].isFirstKill
		}

		table.insert(itemViews, self:GetItemRenderData(view))
	end

	return itemViews
end

function M:GetSingleSortedListRenderDataByList(itemList)
	local itemViews = {}

	for i = 1, #itemList do
		local itemId = self:GetTemplateId(itemList[i])

		if itemId and itemId ~= 0 then
			local view = {
				itemId = itemId,
				itemNum = itemList[i].Count,
				countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP,
				isFirstKill = itemList[i].isFirstKill
			}

			table.insert(itemViews, self:GetItemRenderData(view))
		end
	end

	table.sort(itemViews, self:CreateAction("SortRenderItem", gCommonItemManager))

	return itemViews
end

local BOOL2CTL = gClientConst.BOOL2CTL

function M:OnDescItemClick(btn, data)
	if data.callback then
		data.callback()
	end
end

function M:OnRenderDescItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("ItemInfoPanelStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex == StaticProps.Template2Index.REWARD_LIST then
		return
	end

	store.nameLabel = data.text
	store.descLabel = data.desc or ""
	store.iconId = data.iconId or 0
	store.state = data.state or 0
end

function M:InitRenderList(list, customRenderFunc, customClickFunc)
	list.luaRenderItem = customRenderFunc or self:CreateAction(self.OnCommonItemRender)
end

function M:OnRenderToolTips(data, btn, popup, index)
	self.itemToolTipStore = gStoreManager:GetStoreGroup(popup.Store)

	if not self.itemToolTipStore then
		return
	end

	self.itemToolTipRefBtn = btn

	self.itemToolTipRefBtn:SetSelected(true)
	self.itemToolTipStore:SetSelectedItem(data)
end

function M:OnToolTipsClose(btn, popup, index)
	if not popup then
		btn:SetSelected(false)
	end
end

function M:OnItemToolTipBtnClose()
	self.itemToolTipRefBtn = nil
	self.itemToolTipStore = nil
end

function M:CloseItemToolTips()
	if self.itemToolTipRefBtn then
		self.itemToolTipRefBtn:CloseTooltip(true)
	end
end

function M:OnRenderCommonBuyItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("CommonBuyItemStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.nameLabel = data.name
	store.numLabel = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901018).Text, data.count)
	local itemData = self:GetItemRenderData({
		itemId = data.templateId,
		countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP
	})

	self:OnCommonItemRender(store.itemBtn, 0, itemData)
end

function M:OnRenderNum(itemNum)
	if type(itemNum) == "number" then
		if itemNum == 0 then
			return ""
		end

		return "x" .. gUIUtils:BuildLargeNumStr(itemNum)
	end

	return itemNum or ""
end

function M:OnCommonItemRender(btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.sizeCtl then
		store.sizeCtl = data.sizeCtl
	end

	if data.countCtl then
		store.countCtl = data.countCtl
	end

	store.isFirst = BOOL2CTL[data.isFirstKill]
	store.isLock = BOOL2CTL[data.isLock]

	store:Commit("quality", data.quality, COMMIT_IMMEDIATELY)
	store:Commit("iconId", data.iconId, COMMIT_IMMEDIATELY)

	store.isOwned = BOOL2CTL[data.IsOwned]

	store:Commit("count", self:OnRenderNum(data.itemNum), COMMIT_FORCE)

	btn.interactable = data.interactable
	btn.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderToolTips, data)
	btn.luaTooltipPopup = self:CreateAction(self.OnToolTipsClose)
	store.showUnselect = BOOL2CTL[data.showUnselect]
	store.itemType = self:GetItemDisplayType(data.itemId)

	return store
end

function M:OnCommonItemClick(list, btn, data)
	local itemList = {}
	local selectIndex = 0
	data = data or list:GetData(0)

	if table.isNilOrEmpty(data) then
		return
	end

	local selectId = self:GetTemplateId(data)
	local selectItemId = data and selectId or -1

	for i = 0, list.itemData.Count - 1 do
		local itemId = self:GetTemplateId(list.itemData[i])

		table.insert(itemList, {
			itemId = itemId
		})

		if itemId == selectItemId then
			selectIndex = #itemList
		end
	end

	self:OnShowItemList(itemList, selectIndex)
end

function M:GetItemRenderData(item)
	if type(item) == "number" then
		item = {
			itemId = item
		}
	end

	local itemId = self:GetTemplateId(item)

	if itemId and itemId ~= 0 then
		local itemData = self:TryGetItemInfo(item)

		if table.isNilOrEmpty(itemData) then
			return {
				itemId = itemId
			}
		end

		local ret = {
			itemNum = "",
			isFirstKill = false,
			isLock = false,
			interactable = true,
			showUnselect = false,
			IsOwned = false,
			itemId = itemId,
			name = itemData.name,
			quality = itemData.quality,
			subType = itemData.subType,
			iconId = itemData.iconId
		}
		ret = table.combine(ret, item)

		return ret
	end

	return {
		itemId = itemId
	}
end

function M:OnShowItemList(data, selectIndex)
	if table.isNilOrEmpty(data) then
		return
	end

	local itemViews = {}

	for i = 1, #data do
		if data[i].additionType and data[i].additionType ~= M.ITEM_TYPE.UNKNOWN then
			table.insert(itemViews, data[i])
		elseif data[i].BindItemKeyValuePair then
			table.insert(itemViews, self:GetItemRenderData({
				itemId = data[i].BindItemKeyValuePair.templateId
			}))
		elseif data[i].itemType then
			local itemId = gUIUtils:GetMoneyTypeId(data[i].itemType)

			if itemId == 0 then
				itemId = data[i].itemType
			end

			table.insert(itemViews, self:GetItemRenderData({
				itemId = itemId
			}))
		else
			table.insert(itemViews, self:GetItemRenderData(data[i]))
		end
	end

	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemList = itemViews,
		selectIndex = selectIndex
	})
end

function M:OnShowFakeItemList(data)
	local itemViews = {}

	for i = 1, #data do
		local view = {
			itemId = data[i].Id,
			itemNum = data[i].Count
		}

		table.insert(itemViews, self:GetItemRenderData(view))
	end

	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemList = itemViews
	})
end

function M:OnShowItemRenderData(data)
	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemList = {
			data
		}
	})
end

function M:GetItemDisplayType(itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		local fCfg, isSpecial = self:_TryGetFashinConfig(itemId)

		if fCfg then
			return isSpecial and self.ITEM_TYPE.FASHION_SUIT or self.ITEM_TYPE.FASHION
		end

		local vCfg = self:_TryGetVechicleConfig(itemId)

		if vCfg then
			return self.ITEM_TYPE.VEHICLE
		end

		return self.ITEM_TYPE.COMMON
	end

	if cfg.SubType == ConsumableTypeConfig.Fashion then
		local info = self:_TryGetSpFashion(cfg)

		if not info then
			return self.ITEM_TYPE.FASHION
		end

		return info.isSpecial and self.ITEM_TYPE.FASHION_SUIT or self.ITEM_TYPE.FASHION
	end

	return self.SUBTYPE2ITEM_TYPE[cfg.SubType] or self.ITEM_TYPE.COMMON
end

function M:ExchangeMoney(targetMoney)
	if not self.enableExchange then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_SHOP_EXCHANGE_PANEL, {
		ToMoney = targetMoney
	})
end

function M:SwitchExchange(flag)
	self.enableExchange = flag
end

function M:TryGetSpecialItemInfo(data)
	local itemId = self:GetTemplateId(data)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		return nil
	end

	local info = self:_TryGetSpCharacter(cfg)

	if not table.isNilOrEmpty(info) then
		return info
	end

	info = self:_TryGetSpFashion(cfg)

	if not table.isNilOrEmpty(info) then
		return info
	end

	info = self:_TryGetVechicle(cfg)

	if not table.isNilOrEmpty(info) then
		return info
	end

	info = self:_TryGetHouseInfo(cfg)

	if not table.isNilOrEmpty(info) then
		return info
	end

	return nil
end

function M:_TryGetSpCharacter(itemConfig)
	local bId = itemConfig.BindId
	local cfg = FightSpiritConfig.GetConfig(bId)

	if not cfg then
		return nil
	end

	local agentCfg = AgentConfig.GetConfig(cfg.AgentId)
	local specialType = AgentSpecificTypeConfig.GetConfig(agentCfg.AgentSpecificType)
	local headIcon = specialType.HeadIcon
	local phoneCfg = PhoneConfig.GetConfig(specialType.PhoneId)
	local ele = {
		isSpecial = false,
		additionIcon = 0,
		id = itemConfig.Id,
		bId = bId,
		icon = agentCfg.HeadIcon,
		subIcon = table.isNilOrEmpty(headIcon) and 0 or headIcon[1],
		subType = itemConfig.SubType,
		name = cfg.Name,
		desc = phoneCfg and phoneCfg.PhoneNumber or "",
		quality = itemConfig.Quality
	}

	return ele
end

function M:_TryGetSpFashion(itemConfig)
	local bId = itemConfig.BindId
	local cfg, isSpecial = self:_TryGetFashinConfig(bId)

	if not cfg then
		return nil
	end

	local brandId = nil

	if isSpecial then
		local fCfg = FashionConfig.GetConfig(cfg.FashionIdList[1])
		brandId = fCfg and fCfg.BelongBrand or 0
	else
		brandId = cfg.BelongBrand
	end

	local brandCfg = ShopBrandConfig.GetConfig(brandId)
	local ele = {
		subIcon = 0,
		additionIcon = 0,
		id = itemConfig.Id,
		bId = bId,
		icon = cfg.Icon,
		subType = itemConfig.SubType,
		name = cfg.Name,
		desc = brandCfg and brandCfg.BrandName or "",
		isSpecial = isSpecial,
		quality = itemConfig.Quality
	}

	return ele
end

function M:_TryGetVechicle(itemConfig)
	local bId = itemConfig.BindId
	local cfg = VehicleConfig.GetConfig(bId)

	if not cfg then
		return nil
	end

	local vType = cfg.VehicleType
	local vCfg = VehicleTypeConfig.GetConfig(vType)
	local ele = {
		isSpecial = false,
		id = itemConfig.Id,
		bId = bId,
		icon = cfg.SVehicleFrontIconId,
		subIcon = cfg.VehicleBrandPicIcon,
		subType = itemConfig.SubType,
		name = cfg.VehicleName,
		desc = vCfg and vCfg.DisplayName or "",
		additionIcon = cfg.VehicleLightPic,
		quality = itemConfig.Quality
	}

	return ele
end

function M:_TryGetHouseInfo(itemConfig)
	local bId = itemConfig.BindId
	local cfg = HouseConfig.GetConfig(bId)

	if not cfg then
		return nil
	end

	local desc = table.concat(cfg.Tags, ";")
	local ele = {
		isSpecial = false,
		subIcon = 0,
		additionIcon = 0,
		id = itemConfig.Id,
		bId = bId,
		icon = cfg.HouseHeadId,
		subType = itemConfig.SubType,
		name = cfg.Name,
		desc = desc,
		quality = itemConfig.Quality
	}

	return ele
end

function M:_TryGetVechicleInfo(data)
	local itemId = self:GetTemplateId(data)
	local cfg = self:_TryGetVechicleConfig(itemId)

	if not cfg then
		return nil
	end

	local ret = {
		showSource = false,
		description = "",
		showCount = false,
		name = cfg.VehicleName,
		iconId = cfg.SVehicleIconId,
		shortDesc = cfg.VehicleIntro,
		itemId = itemId,
		quality = cfg.VehicleQuality,
		subType = ConsumableTypeConfig.Vehicle,
		additionType = M.ITEM_TYPE.COMMON_ITEM,
		rewardList = {}
	}

	return ret
end

function M:_TryGetVechicleConfig(id)
	local cfg = VehicleConfig.GetConfig(id)

	if cfg then
		return cfg
	end

	cfg = ConsumableConfig.GetConfig(id)

	if not cfg then
		return nil
	end

	return self:_TryGetVechicleConfig(cfg.BindId)
end

function M:_TryGetFashinConfig(id)
	local cfg = FashionConfig.GetConfig(id)

	if cfg then
		return cfg, false
	end

	cfg = FashionSuitConfig.GetConfig(id)

	if cfg then
		return cfg, true
	end

	cfg = ConsumableConfig.GetConfig(id)

	if not cfg then
		return nil, false
	end

	return self:_TryGetFashinConfig(cfg.BindId)
end

function M:OnRenderCommonFashion(btn, index, id)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg, isSuit = self:_TryGetFashinConfig(id)

	if not cfg then
		return
	end

	store.icon = cfg.Icon

	if isSuit then
		cfg = self:_TryGetFashinConfig(cfg.FashionIdList[1])
		local brandCfg = ShopBrandConfig.GetConfig(cfg.BelongBrand)
		store.iconBg = brandCfg and brandCfg.SuitBG or 0
	end

	store.quality = cfg.Quality
	btn.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderToolTips, {
		TemplateId = id
	})
	btn.luaTooltipPopup = self:CreateAction(self.OnToolTipsClose)
end

gCommonItemManager = gCommonItemManager or C_CommonItemManager.new()
