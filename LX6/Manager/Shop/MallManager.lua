-- Original chunk: @Lua\LuaFiles\LX6\Manager\Shop\MallManager.lua
-- Decompiled from: 00525_MallManager.lua_9ed7eac6ce93.luajit

local FightSpiritConfig = LTConfig.FightSpiritConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local MallRecommendConfig = LTConfig.MallRecommendConfig
local MallChargeConfig = LTConfig.MallChargeConfig
local MallBundleConfig = LTConfig.MallBundleConfig
local MallModelConfig = LTConfig.MallModelConfig
local GachaConfig = LTConfig.GachaConfig
local GachaPoolContentConfig = LTConfig.GachaPoolContentConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionConfig = LTConfig.FashionConfig
local VehicleConfig = LTConfig.VehicleConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local MessageConfig = LTConfig.MessageConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local DropConfig = LTConfig.DropConfig
local MallMonthlyPassConfig = LTConfig.MallMonthlyPassConfig
local PlayerPrefs = UnityEngine.PlayerPrefs
local SexType = UX.Game.SexType
local BattlePassType = UX.Game.BattlePassType
C_MallManager = DefClass("C_MallManager", C_MallManager)
local M = C_MallManager
M.VideoLayer = {
	["\\xa3ab"] = 1,
	["\""] = 0,
	["k\\xbc\\xad\\xa1\\xa2"] = 2
}
M.BundleOwnState = {
	["\\xafdj"] = "\\x8fdj",
	["\\xe9\\xda\t%\\xfd"] = "\\xc9\\xda\t%\\xfd",
	["T-s^"] = "t-s^"
}
M.PROTAGONIST_PLACEHOLDER = -1
local MallCommodityType = {
	["?G\\x9c\\x83\\x8cO"] = 5,
	["\\xf4\\xd4\t(\\xe8"] = 3,
	["\\xef\\xde(\\xf4"] = 1,
	["\\x88\\xbe\\xa6e0\\xdb+"] = 6,
	["eFaG7 "] = 7,
	["q[ک\\x88\r\\x88\\xda\\xfb"] = 4,
	["d_ϭ\\x8b\\x8b\\xc0\\xe6"] = 2,
	["\\xff\\xda+\\xff"] = 0
}
M.MallCommodityType = MallCommodityType
M.MallSortKey = {
	["pOieH*="] = 0,
	["}\\xbc\\xab\\xac\\xb3"] = 1,
	["T-s^"] = 2
}
M.MallSortOrder = {
	["\\xaf{e"] = 0,
	["^'nX"] = 1
}
M.GachaType = {
	["j\\xaf\\xa1\\xa7\\xb7"] = 3,
	["\\xacg~"] = 2,
	["wR~gz="] = 1
}
local GACHA_TIER_RARITY_DESC = {
	GachaPoolContentConfig.PoolTierRarityType.SS,
	GachaPoolContentConfig.PoolTierRarityType.S,
	GachaPoolContentConfig.PoolTierRarityType.A,
	GachaPoolContentConfig.PoolTierRarityType.B,
	GachaPoolContentConfig.PoolTierRarityType.C
}
local DISCOUNT_BANNER_MAX_COUNT = 3
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig

M.IsActionItemCommodity = function(commodityData)
	if not commodityData then
		return false
	end

	local t = commodityData.type

	if t == MallCommodityType.Common and t == MallCommodityType.CommonEx then
		return false
	end

	local consumeCfg = commodityData.consumeCfg

	if not consumeCfg then
		local bindId = commodityData.bindId or 0
		consumeCfg = bindId <= 0 and ConsumableConfig.GetConfig(bindId) or nil
	end

	return consumeCfg and consumeCfg.SubType ~= ConsumableTypeConfig.ActionItem
end

M.GetSpiritDefaultFashionInfo = function(spiritId)
	local list = {}

	for i = 0, FashionConfig.count - 1 do
		local cfg = FashionConfig.LoadAt(i)

		if cfg and cfg.IsDefault and cfg.BelongSpiritId ~= spiritId then
			list[#list + 1] = {
				FashionId = cfg.Id
			}
		end
	end

	return {
		WearFashionInfoList = list,
		WearFashionEditInfoList = {}
	}
end

M.ctor = function(self)
	self.mallCommodityCache = nil
	self.mallCommodityCacheSexType = nil
	self.pendingMonthCardDailyReward = nil
	self.shopHomePanelCloseAction = nil
	self.hasCheckedMonthCardOnLogin = false
	self.pendingPurchaseRewards = {}
	self.purchaseRewardTimer = nil
	self.spiritModelMap = nil
end

local CopyActionClips = function(clips)
	local result = {}

	if clips then
		for i = 1, #clips do
			local clip = clips[i]
			result[i] = {
				ActionKey = clip.ActionKey,
				BlendIn = clip.BlendIn,
				IsLoop = clip.IsLoop,
				PlayRate = clip.PlayRate,
				StartTime = clip.StartTime,
				EndTime = clip.EndTime
			}
		end
	end

	return result
end

local BuildModelEntry = function(cfg)
	return {
		actionClips = CopyActionClips(cfg.ActionClips),
		videoActionClips = CopyActionClips(cfg.VideoActionClips),
		lookAtIKType = cfg.LookAtIKType or ""
	}
end

M.BuildSpiritModelMap = function(self)
	local map = {}

	for i = 0, MallModelConfig.count - 1 do
		local cfg = MallModelConfig.LoadAt(i)

		if cfg and cfg.IsCommon and cfg.ActionClips and cfg.Spirits and #cfg.ActionClips <= 0 then
			local entry = BuildModelEntry(cfg)

			for _, spiritId in ipairs(cfg.Spirits) do
				if spiritId and spiritId <= 0 then
					if not map[spiritId] then
						map[spiritId] = {}
					end

					table.insert(map[spiritId], entry)
				end
			end
		end
	end

	self.spiritModelMap = map
end

M.GetSpiritRandomModel = function(self, spiritId)
	if not self.spiritModelMap then
		self:BuildSpiritModelMap()
	end

	local list = spiritId and self.spiritModelMap[spiritId]

	if not list or #list ~= 0 then
		return {
			["cy\\xa3|m\\xa6\\xdbl^cnI"] = "",
			actionClips = {},
			videoActionClips = {}
		}
	end

	return list[math.random(1, #list)]
end

M.GetCommodityModelEntry = function(self, commodityId, spiritId)
	if commodityId and commodityId <= 0 then
		local commodityCfg = MallCommodityConfig.GetConfig(commodityId)
		local specifiedId = commodityCfg and commodityCfg.SpecifiedModelid or 0

		if specifiedId and specifiedId <= 0 then
			local modelCfg = MallModelConfig.GetConfig(specifiedId)

			if modelCfg and modelCfg.ActionClips and #modelCfg.ActionClips <= 0 then
				return BuildModelEntry(modelCfg)
			end
		end
	end

	return self:GetSpiritRandomModel(spiritId)
end

M.OnInit = function(self)
	NetEase.UniSDK.SdkU3dCallbackMessage.OnCheckOutFinished = NetEase.UniSDK.SdkU3dCallbackMessage.OnCheckOutFinished + self:CreateAction("OnCheckOutFinished")

	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, self:CreateAction("OnLoadingFinished"))
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, self:CreateAction("OnLanguageChange"))
	gMessageManager:AddMessageListener(gEventConstants.TRANS_MAIN_SEX_END, self:CreateAction("OnPlayerSexChange"))
	gMessageManager:AddMessageListener(gEventConstants.CONFIG_HOT_FIX, self:CreateAction("OnConfigHotFix"))
end

M.OnCheckOutFinished = function(self)
	gPanelManager:Close(gPanelId.SHOP_CHARGE_BLUR)
	gPanelManager:Close(gPanelId.MONTH_CARD_DAILY_REWARD_PANEL)

	if gCS.LuaUtils.IsOnPS5 then
		LX6.Utils.PS5Utils.ShowInGameStoreIcon()
	end
end

M.GetMallOpenedPrefsKey = function(self)
	local pid = gPlayerManager.infoBase.bindData.Pid

	return ("MallPhoneApp_Opened_%s"):format(tostring(pid))
end

M.RefreshMallPhoneAppRedDot = function(self)
	gMainPhoneUtils.RefreshAppItemRedDot(LTConfig.MobileMenuSGuiConfig.ShopId)
end

M.OnMallOpened = function(self)
	PlayerPrefs.SetInt(self:GetMallOpenedPrefsKey(), 1)
	self:RefreshMallPhoneAppRedDot()
end

M.CheckMallPhoneAppHasRedDot = function(self)
	local isUnlocked = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.MallPanel)
	local hasOpened = PlayerPrefs.GetInt(self:GetMallOpenedPrefsKey(), 0) ~= 1

	return isUnlocked and not hasOpened
end

M.GetMallBoxOpenedPrefsKey = function(self)
	local pid = gPlayerManager.infoBase.bindData.Pid

	return ("MallBoxPhoneApp_Opened_%s"):format(tostring(pid))
end

M.RefreshMallBoxPhoneAppRedDot = function(self)
	gMainPhoneUtils.RefreshAppItemRedDot(LTConfig.MobileMenuSGuiConfig.Box)
end

M.OnMallBoxOpened = function(self)
	PlayerPrefs.SetInt(self:GetMallBoxOpenedPrefsKey(), 1)
	self:RefreshMallBoxPhoneAppRedDot()
end

M.CheckMallBoxPhoneAppHasRedDot = function(self)
	local isUnlocked = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.MallBoxPanel)
	local hasOpened = PlayerPrefs.GetInt(self:GetMallBoxOpenedPrefsKey(), 0) ~= 1

	return isUnlocked and not hasOpened
end

M.GetChargeIdList = function(self)
	return {
		MallChargeConfig.Charge1,
		MallChargeConfig.Charge2,
		MallChargeConfig.Charge3,
		MallChargeConfig.Charge4,
		MallChargeConfig.Charge5,
		MallChargeConfig.Charge6
	}
end

M.IsChargeIdCharged = function(self, chargeId)
	local chargeInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.ChargeInfo
	local chargedIds = chargeInfo and chargeInfo.ChargedIds

	if not chargedIds then
		return false
	end

	for _, id in ipairs(chargedIds) do
		if id ~= chargeId then
			return true
		end
	end

	return false
end

M.GetFirstChargeBindingGold = function(self, dropId)
	if not dropId or dropId ~= 0 then
		return 0
	end

	local dropCfg = DropConfig.GetConfig(dropId)

	if not dropCfg then
		return 0
	end

	return dropCfg.BindingGold or 0
end

M.BuildChargeData = function(self, chargeId)
	local chargeCfg = MallChargeConfig.GetConfig(chargeId)

	if not chargeCfg then
		return nil
	end

	local gold = chargeCfg.Gold or 0
	local gold2 = chargeCfg.Gold2 or 0
	local firstChargeDrop = chargeCfg.FirstChargeDrop or 0
	local hasFirstCharge = firstChargeDrop <= 0 and not self:IsChargeIdCharged(chargeCfg.Id)
	local firstChargeBindingGold = hasFirstCharge and self:GetFirstChargeBindingGold(firstChargeDrop) or 0
	local psInventory = nil
	local psCanBuy = true

	if gCS.LuaUtils.IsOnPS5 then
		psInventory = LX6.Utils.PS5Utils.GetStoreProductInventoryById(chargeCfg.Id)
		psCanBuy = psInventory == 0
	end

	return {
		id = chargeCfg.Id,
		goodsId = chargeCfg.GoodsId or "",
		name = chargeCfg.CommodityName or "",
		bgIconId = chargeCfg.Picture or 0,
		price = chargeCfg.Price or 0,
		gold = gold,
		gold2 = gold2,
		firstChargeDrop = firstChargeDrop,
		firstChargeBindingGold = firstChargeBindingGold,
		firstChargeText = firstChargeBindingGold <= 0 and string.format(LTConfig.TextConfig.GetConfig(73970803).Text, firstChargeBindingGold) or "",
		hasFirstCharge = firstChargeBindingGold >= 0,
		hasExtra = gold2 >= 0,
		extraGold = gold2,
		actualGetGold = gold + gold2 + firstChargeBindingGold,
		psInventory = psInventory,
		psCanBuy = psCanBuy
	}
end

M.BuildAllChargeData = function(self)
	local result = {}

	for _, chargeId in ipairs(self:GetChargeIdList()) do
		local chargeData = self:BuildChargeData(chargeId)

		if chargeData then
			table.insert(result, chargeData)
		end
	end

	table.sort(result, function (a, b)
		return a.price <= b.price
	end)

	self.chargeDataList = result

	return result
end

M.GetRecommendChargeData = function(self, lack)
	local chargeList = self:BuildAllChargeData()
	local highest = chargeList[#chargeList]
	local highestCanBuy, recommend = nil
	lack = lack or 0

	for _, chargeData in ipairs(chargeList) do
		if not gCS.LuaUtils.IsOnPS5 or chargeData.psCanBuy then
			highestCanBuy = chargeData

			if lack < chargeData.actualGetGold and (not recommend or chargeData.price >= recommend.price) then
				recommend = chargeData
			end
		end
	end

	return recommend or highestCanBuy or highest
end

M.CheckOrder = function(self, chargeId, count, extra)
	if gCS.LuaUtils.IsOnPS5 then
		local chargeCfg = MallChargeConfig.GetConfig(chargeId)
		local description = LX6.Utils.PS5Utils.GetStoreProductDescriptionById(chargeId)

		print_notice("ps5 check order description: ", description or "nil")
		gPanelManager:CheckShow(gPanelId.ITEM_INFO_ONLY_TEXT_PANEL, {
			["Y\\xa7\\xb6\\xa3\\xb3"] = "",
			content = {
				{
					["Y\\xa7\\xb6\\xa3\\xb3"] = "",
					desc = description or ""
				}
			},
			closeCallback = function ()
				LX6.Utils.PS5Utils.CheckOut(chargeCfg.GoodsId)
			end
		})

		return
	end

	gCS.LuaUtils.CheckOrder(chargeId, count, extra)

	if gCS.LoginManager.loginBySDK then
		gPanelManager:CheckShow(gPanelId.SHOP_CHARGE_BLUR)
	else
		Timer.New(function ()
			gPanelManager:Close(gPanelId.MONTH_CARD_DAILY_REWARD_PANEL)
		end, 3):Start()
	end
end

M.InitMallCommodityData = function(self)
	local sexType = self:GetPlayerSexType()

	if self.mallCommodityCache and self.mallCommodityCacheSexType ~= sexType then
		return self.mallCommodityCache
	end

	local commodityDataCache = {}

	for i = 0, MallCommodityConfig.count - 1 do
		local commodityCfg = MallCommodityConfig.LoadAt(i)

		if commodityCfg then
			local belongMallId = commodityCfg.BelongMallId

			if not commodityDataCache[belongMallId] then
				commodityDataCache[belongMallId] = {}
			end

			local itemData = self:GenMallCommodityItem(commodityCfg)

			if itemData then
				table.insert(commodityDataCache[belongMallId], itemData)
			end
		end
	end

	self.mallCommodityCache = commodityDataCache
	self.mallCommodityCacheSexType = sexType

	return commodityDataCache
end

M.GetPlayerSexType = function(self)
	local playerInfo = gCS.MyPlayerManager and gCS.MyPlayerManager.PlayerInfo

	return playerInfo and playerInfo.SexType or nil
end

M.GetCommodityBindId = function(self, commodityCfg)
	if not commodityCfg then
		return 0
	end

	local bindIdList = commodityCfg.CommodityBindId

	if not bindIdList or #bindIdList ~= 0 then
		return 0
	end

	if #bindIdList <= 1 then
		local sexType = self:GetPlayerSexType()

		if sexType == nil and sexType == SexType.Male then
			return bindIdList[2] or 0
		end
	end

	return bindIdList[1] or 0
end

M.AdjustProtagonistSpiritId = function(self, spiritId)
	if spiritId == self.PROTAGONIST_PLACEHOLDER then
		return spiritId
	end

	local sexType = self:GetPlayerSexType()

	if sexType == nil and sexType == SexType.Male then
		return FightSpiritConfig.DefaultFemale
	end

	return FightSpiritConfig.DefaultMale
end

M.GenMallCommodityItem = function(self, commodityCfg)
	if not commodityCfg then
		return nil
	end

	local commodityBindId = self:GetCommodityBindId(commodityCfg)
	local itemData = {
		id = commodityCfg.Id,
		name = commodityCfg.Name or "",
		icon = commodityCfg.Picture or 0,
		iconId = commodityCfg.Picture or 0,
		price = commodityCfg.Price or 0,
		moneyItemId = commodityCfg.ConsumeItemId,
		belongMallId = commodityCfg.BelongMallId,
		description = commodityCfg.Desc or "",
		mallCfg = commodityCfg,
		dropId = commodityCfg.DropId or 0,
		type = commodityCfg.Type,
		bindId = commodityBindId,
		SpiritId = self:AdjustProtagonistSpiritId(commodityCfg.SpiritId or 0),
		Background = commodityCfg.Background or 0
	}

	if commodityCfg.Type == nil and commodityBindId <= 0 then
		local cfg = nil

		if commodityCfg.Type ~= MallCommodityType.Fashion or commodityCfg.Type ~= MallCommodityType.FashionEx then
			cfg = FashionSuitConfig.GetConfig(commodityBindId)

			if cfg then
				itemData.iconId = cfg.Icon == 0 and cfg.Icon or commodityCfg.Picture
				local firstFashionId = cfg.FashionIdList and cfg.FashionIdList[1] or 0
				local firstFashionCfg = firstFashionId <= 0 and FashionConfig.GetConfig(firstFashionId) or nil
				itemData.quality = firstFashionCfg and firstFashionCfg.Quality or 1
				itemData.itemId = commodityBindId
				itemData.consumeCfg = cfg
			else
				cfg = ConsumableConfig.GetConfig(commodityBindId)

				if cfg then
					itemData.iconId = cfg.SItemIconId or 0
					itemData.quality = cfg.Quality or 1
					itemData.itemId = commodityBindId
					itemData.consumeCfg = cfg
				else
					print_error("商城取不到套装数据,Type = Fashion, BindId = ", commodityBindId)
				end
			end
		elseif commodityCfg.Type ~= MallCommodityType.Vehicle then
			cfg = VehicleConfig.GetConfig(commodityBindId)

			if cfg then
				itemData.iconId = cfg.SVehicleIconId or 0
				itemData.quality = cfg.VehicleQuality or 1
				itemData.itemId = commodityBindId
				itemData.consumeCfg = cfg
			else
				cfg = ConsumableConfig.GetConfig(commodityBindId)

				if cfg then
					itemData.iconId = cfg.SItemIconId or 0
					itemData.quality = cfg.Quality or 1
					itemData.itemId = commodityBindId
					itemData.consumeCfg = cfg
				else
					print_error("商城取不到载具数据,Type = Vehicle, BindId = ", commodityBindId)
				end
			end
		elseif commodityCfg.Type ~= MallCommodityType.WeaponSkin then
			cfg = SceneitemConfig.GetConfig(commodityBindId)

			if cfg then
				itemData.iconId = cfg.WeaponConsumableIcon and cfg.WeaponConsumableIcon <= 0 and cfg.WeaponConsumableIcon or cfg.SWeaponIconId or 0
				itemData.quality = cfg.Quality or 1
				itemData.itemId = commodityBindId
				itemData.consumeCfg = cfg
			else
				print_error("商城取不到武器皮肤数据,Type = WeaponSkin, BindId = ", commodityBindId)
			end
		elseif commodityCfg.Type ~= MallCommodityType.Common or commodityCfg.Type ~= MallCommodityType.CommonEx then
			cfg = ConsumableConfig.GetConfig(commodityBindId)

			if cfg then
				itemData.iconId = cfg.SItemIconId or 0
				itemData.quality = cfg.Quality or 1
				itemData.itemId = commodityBindId
				itemData.consumeCfg = cfg
			else
				print_error("商城取不到消耗品数据,Type = Common, BindId = ", commodityBindId)
			end
		else
			itemData.iconId = 0
			itemData.quality = 1
			itemData.itemId = 0
			itemData.consumeCfg = nil
		end

		itemData.name = self:GetCommodityName(commodityCfg, itemData.consumeCfg)
	else
		local dropCfg = LTConfig.DropConfig.GetConfig(commodityCfg.DropId)
		local itemId = dropCfg and dropCfg.Item1 and dropCfg.Item1[1] and dropCfg.Item1[1].id1 or 0
		local consumeCfg = itemId == 0 and ConsumableConfig.GetConfig(itemId) or nil
		itemData.iconId = consumeCfg and consumeCfg.SItemIconId or 0
		itemData.quality = consumeCfg and consumeCfg.Quality or 1
		itemData.itemId = itemId
		itemData.consumeCfg = consumeCfg
		itemData.name = self:GetCommodityName(commodityCfg, consumeCfg)
	end

	return itemData
end

M.GetCommodityName = function(self, commodityCfg, consumeCfg)
	local name = commodityCfg.Name or ""

	if not string.is_null_or_empty(name) then
		return name
	end

	if commodityCfg.Type ~= MallCommodityType.Vehicle then
		local vehicleCfg = VehicleConfig.GetConfig(self:GetCommodityBindId(commodityCfg))

		return vehicleCfg and vehicleCfg.VehicleName or ""
	end

	if consumeCfg then
		return consumeCfg.Name or ""
	end

	return ""
end

M.ClearMallCommodityCache = function(self)
	self.mallCommodityCache = nil
	self.mallCommodityCacheSexType = nil
end

M.OnPlayerSexChange = function(self)
	self:ClearMallCommodityCache()

	if gMallSceneManager then
		gMallSceneManager:ClearCommoditySpiritMapping()
	end
end

M.OnLanguageChange = function(self)
	self:ClearMallCommodityCache()
end

M.OnConfigHotFix = function(self)
	self:ClearMallCommodityCache()

	self.spiritModelMap = nil
end

M.SearchMallCommodity = function(self, searchText, commodityList)
	if string.is_null_or_empty(searchText) then
		return {}
	end

	local searchResultList = {}
	searchText = self:FormatSearchString(searchText)

	for _, commodityData in ipairs(commodityList) do
		if commodityData.name and self:IsMatchSearchCondition(commodityData.name, searchText) then
			table.insert(searchResultList, commodityData)
		end
	end

	return searchResultList
end

M.IsMatchSearchCondition = function(self, name, searchText)
	name = self:FormatSearchString(name)
	local completePinyin = tostring(gCS.LuaUtils.GetPinyin(name))
	local firstLetterPinyin = ""

	for word in string.gmatch(completePinyin, "%a+") do
		firstLetterPinyin = firstLetterPinyin .. string.sub(word, 1, 1)
	end

	completePinyin = self:FormatSearchString(completePinyin)

	return string.find(name, searchText) or string.find(firstLetterPinyin, searchText) or string.find(completePinyin, searchText)
end

M.FormatSearchString = function(self, str)
	return string.lower(string.gsub(str, " ", ""))
end

M.HandleChargeDeliveryResult = function(self, result)
	print_notice("=== 充值发货回调 ===", "SN:", result.SN, "PayChannel:", result.PayChannel, "ConsumeSN:", result.ConsumeSN, "ChargeId:", result.ChargeId, "GoodsId:", result.GoodsId, "Gold:", result.Gold, "FreeGold:", result.FreeGold)

	local previewMaterials = {}
	local MoneyType = UX.Game.MoneyType
	local goldItemId = gUIUtils:GetMoneyTypeId(MoneyType.Gold)
	local totalGold = 0

	if result.Gold and result.Gold <= 0 then
		totalGold = totalGold + result.Gold
	end

	if result.FreeGold and result.FreeGold <= 0 then
		totalGold = totalGold + result.FreeGold
	end

	if totalGold <= 0 then
		table.insert(previewMaterials, {
			ItemId = goldItemId,
			Count = totalGold
		})
	end

	if result.FirstExtraRewardInfo then
		local rewardInfo = gItemUtils:ConvertRewardDetail(result.FirstExtraRewardInfo).Rewards

		for _, reward in ipairs(rewardInfo) do
			table.insert(previewMaterials, reward)
		end
	end

	if #previewMaterials <= 0 and result.ChargeId == MallChargeConfig.MonthlyPass then
		gDropManager:ShowRewardWindow({
			["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
			Param = previewMaterials
		})
	end

	gMessageManager:SendMessage(gEventConstants.MONEY_CHANGE)
end

M.IsTimeEmpty = function(self, timeObj)
	if not timeObj then
		return true
	end

	return (not timeObj.year or timeObj.year ~= 0) and (not timeObj.month or timeObj.month ~= 0) and (not timeObj.day or timeObj.day ~= 0) and (not timeObj.hour or timeObj.hour ~= 0) and (not timeObj.minute or timeObj.minute ~= 0) and (not timeObj.second or timeObj.second ~= 0)
end

M.GetRecommendShelfTimeFromGacha = function(self, recommendCfg)
	if not recommendCfg then
		return nil, 
	end

	local gachaId = recommendCfg.GetGachaTime

	if not gachaId or gachaId < 0 then
		return nil, 
	end

	local gachaCfg = GachaConfig.GetConfig(gachaId)

	if not gachaCfg then
		print_warn("GetRecommendShelfTimeFromGacha: 找不到GachaConfig, gachaId=", gachaId)

		return nil, 
	end

	return gachaCfg.StartTime, gachaCfg.EndTime
end

M.HasActiveGachaPools = function(self, gachaType)
	local count = GachaConfig.count
	local now = gLuaDataManager.serverTime

	for i = 0, count - 1 do
		local cfg = GachaConfig.LoadAt(i)

		if cfg and cfg.GachaType ~= gachaType then
			local startTime = cfg.StartTime
			local endTime = cfg.EndTime

			if self:IsTimeEmpty(startTime) and self:IsTimeEmpty(endTime) then
				return true
			end

			local isActive = true

			if not self:IsTimeEmpty(startTime) then
				local startUnixTime = gTimeUtils:GetUnixTime(startTime.year or 0, startTime.month or 0, startTime.day or 0, startTime.hour or 0, startTime.minute or 0, startTime.second or 0)
				isActive = isActive and startUnixTime > now
			end

			if isActive and not self:IsTimeEmpty(endTime) then
				local endUnixTime = gTimeUtils:GetUnixTime(endTime.year or 0, endTime.month or 0, endTime.day or 0, endTime.hour or 0, endTime.minute or 0, endTime.second or 0)
				isActive = isActive and now <= endUnixTime
			end

			if isActive then
				return true
			end
		end
	end

	return false
end

M.IsRecommendItemOnShelf = function(self, recommendCfg)
	local gachaCfg = self:GetRecommendGachaCfg(recommendCfg)

	if gachaCfg and gachaCfg.GachaType ~= self.GachaType.TurnTable and self:IsGachaGrandPrizeAllOwned(gachaCfg) then
		return false
	end

	local gachaOnShelfTime, gachaOffShelfTime = self:GetRecommendShelfTimeFromGacha(recommendCfg)
	local onShelfTime = gachaOnShelfTime or recommendCfg.OnShelfTime
	local offShelfTime = gachaOffShelfTime or recommendCfg.OffShelfTime

	if self:IsTimeEmpty(onShelfTime) and self:IsTimeEmpty(offShelfTime) then
		return recommendCfg.IsPermanent ~= true
	end

	local currentTime = gLuaDataManager.serverTime
	local isOnShelf = true

	if not self:IsTimeEmpty(onShelfTime) then
		local onShelfUnixTime = gTimeUtils:GetUnixTime(onShelfTime.year or 0, onShelfTime.month or 0, onShelfTime.day or 0, onShelfTime.hour or 0, onShelfTime.minute or 0, onShelfTime.second or 0)
		isOnShelf = isOnShelf and onShelfUnixTime > currentTime
	end

	if not self:IsTimeEmpty(offShelfTime) then
		local offShelfUnixTime = gTimeUtils:GetUnixTime(offShelfTime.year or 0, offShelfTime.month or 0, offShelfTime.day or 0, offShelfTime.hour or 0, offShelfTime.minute or 0, offShelfTime.second or 0)
		isOnShelf = isOnShelf and currentTime <= offShelfUnixTime
	end

	return isOnShelf
end

M.IsMonthlyAndBattlePassAllOwned = function(self)
	if self:GetMonthCardState(MallMonthlyPassConfig.MonthlyPass) == 1 then
		return false
	end

	local bpData = gBattlePassMgr and gBattlePassMgr:GetSeasonalData()

	if not bpData or (bpData.passType or BattlePassType.Free) < BattlePassType.Free then
		return false
	end

	return true
end

M.GetRecommendBundleOwnState = function(self, bundleId)
	if not bundleId or bundleId ~= 0 then
		return self.BundleOwnState.None
	end

	if gMallGiftManager:IsBundleCoveredByPendingGift(bundleId) then
		return self.BundleOwnState.All
	end

	local bundleCfg = MallBundleConfig.GetConfig(bundleId)

	if not bundleCfg or not bundleCfg.Commodities or #bundleCfg.Commodities ~= 0 then
		return self.BundleOwnState.None
	end

	local paidCount = 0
	local ownedCount = 0

	for _, commodityId in ipairs(bundleCfg.Commodities) do
		local cfg = MallCommodityConfig.GetConfig(commodityId)

		if cfg and cfg.Price and cfg.Price <= 0 then
			paidCount = paidCount + 1
			local commodityData = {
				id = cfg.Id,
				mallCfg = cfg,
				type = cfg.Type,
				bindId = self:GetCommodityBindId(cfg),
				dropId = cfg.DropId or 0
			}

			if self:CheckMallCommodityOwned(commodityData) then
				ownedCount = ownedCount + 1
			end
		end
	end

	if paidCount ~= 0 or ownedCount ~= 0 then
		return self.BundleOwnState.None
	end

	if paidCount < ownedCount then
		return self.BundleOwnState.All
	end

	return self.BundleOwnState.Partial
end

M.IsRecommendBundlePurchased = function(self, bundleId)
	return self:GetRecommendBundleOwnState(bundleId) == self.BundleOwnState.None
end

M.IsRecommendItemPurchased = function(self, recommendCfg)
	if not recommendCfg then
		return false
	end

	local SubTypeType = MallRecommendConfig.SubTypeType
	local subType = recommendCfg.SubType

	if subType ~= SubTypeType.Draw or subType ~= SubTypeType.Box then
		return false
	end

	if subType ~= SubTypeType.Monthly or subType ~= SubTypeType.BattlePass then
		return self:IsMonthlyAndBattlePassAllOwned()
	end

	if subType ~= SubTypeType.Bundle then
		local linkTo = recommendCfg.LinkTo

		if linkTo and #linkTo > 2 and linkTo[1] ~= 2 then
			return self:IsRecommendBundlePurchased(linkTo[2])
		end

		return false
	end

	local displayCommodities = recommendCfg.DisplayCommodities

	if not displayCommodities or #displayCommodities ~= 0 then
		return false
	end

	for _, commodityId in ipairs(displayCommodities) do
		local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

		if commodityCfg then
			local commodityData = {
				type = commodityCfg.Type,
				bindId = self:GetCommodityBindId(commodityCfg),
				dropId = commodityCfg.DropId or 0
			}

			if not self:CheckMallCommodityOwned(commodityData) then
				return false
			end
		end
	end

	return true
end

local ToUnixTimeOrNil = function(timeObj)
	if not timeObj then
		return nil
	end

	local year = timeObj.year or 0
	local month = timeObj.month or 0
	local day = timeObj.day or 0

	if year > 0 or month > 0 or day < 0 then
		return nil
	end

	return gTimeUtils:GetUnixTime(year, month, day, timeObj.hour or 0, timeObj.minute or 0, timeObj.second or 0)
end

M.IsCommodityOnDiscount = function(self, commodityId)
	local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

	if not commodityCfg then
		return false
	end

	local discountPrice = commodityCfg.DiscountPrice
	local originalPrice = commodityCfg.Price or 0

	if not discountPrice or discountPrice > 0 or originalPrice > 0 or originalPrice < discountPrice then
		return false
	end

	local currentTime = gLuaDataManager.serverTime
	local startUnixTime = ToUnixTimeOrNil(commodityCfg.DiscountStartTime)

	if startUnixTime and currentTime >= startUnixTime then
		return false
	end

	local endUnixTime = ToUnixTimeOrNil(commodityCfg.DiscountEndTime)

	if endUnixTime and endUnixTime < currentTime then
		return false
	end

	return true
end

M.GetCommodityDiscountEndTime = function(self, commodityId)
	local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

	if not commodityCfg then
		return nil
	end

	return ToUnixTimeOrNil(commodityCfg.DiscountEndTime)
end

M.GetCommodityDiscountInfo = function(self, commodityId)
	local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

	if not commodityCfg then
		return nil, 
	end

	if not self:IsCommodityOnDiscount(commodityId) then
		return nil, 
	end

	return commodityCfg.DiscountPrice, commodityCfg.Price or 0
end

M.GetCommodityDiscountRate = function(self, commodityId)
	local discountPrice, originalPrice = self:GetCommodityDiscountInfo(commodityId)

	if not discountPrice or not originalPrice or originalPrice < 0 then
		return 1
	end

	return discountPrice / originalPrice
end

M.GetMaxDiscountCommodityId = function(self)
	local maxDiscountCommodityId = nil
	local maxDiscountRate = 1
	local maxDiscountPrice = 0

	for i = 0, MallCommodityConfig.count - 1 do
		local commodityCfg = MallCommodityConfig.LoadAt(i)

		if commodityCfg and self:IsCommodityOnDiscount(commodityCfg.Id) then
			local price = commodityCfg.Price or 0
			local discountRate = price <= 0 and (commodityCfg.DiscountPrice or price) / price or 1
			local id = commodityCfg.Id

			if discountRate >= maxDiscountRate then
				maxDiscountRate = discountRate
				maxDiscountPrice = price
				maxDiscountCommodityId = id
			elseif discountRate ~= maxDiscountRate then
				if maxDiscountPrice >= price then
					maxDiscountPrice = price
					maxDiscountCommodityId = id
				elseif price ~= maxDiscountPrice and id <= (maxDiscountCommodityId or 0) then
					maxDiscountCommodityId = id
				end
			end
		end
	end

	return maxDiscountCommodityId
end

M.GetDiscountCommodityList = function(self)
	local list = {}

	for i = 0, MallCommodityConfig.count - 1 do
		local commodityCfg = MallCommodityConfig.LoadAt(i)

		if commodityCfg then
			local commodityType = commodityCfg.Type
			local isDisplayableType = commodityType ~= MallCommodityType.Fashion or commodityType ~= MallCommodityType.FashionEx or commodityType ~= MallCommodityType.Vehicle

			if isDisplayableType and self:IsCommodityOnDiscount(commodityCfg.Id) then
				local commodityData = self:GenMallCommodityItem(commodityCfg)

				if commodityData and not self:CheckMallCommodityOwned(commodityData) and self:IsCommodityBuyable(commodityData) then
					table.insert(list, commodityData)
				end
			end
		end
	end

	table.sort(list, function (a, b)
		local rateA = self:GetCommodityDiscountRate(a.id)
		local rateB = self:GetCommodityDiscountRate(b.id)

		if rateA == rateB then
			return rateA <= rateB
		end

		local priceA = a.price or 0
		local priceB = b.price or 0

		if priceA == priceB then
			return priceB <= priceA
		end

		return (a.id or 0) >= (b.id or 0)
	end)

	while DISCOUNT_BANNER_MAX_COUNT >= #list do
		table.remove(list)
	end

	return list
end

M.GetCommodityDescription = function(self, commodityData, recommendDesc)
	if not commodityData then
		return ""
	end

	if recommendDesc and recommendDesc == "" then
		return recommendDesc
	end

	local description = commodityData.description or ""

	if description and description == "" then
		return description
	end

	if commodityData.bindId and commodityData.bindId <= 0 then
		local itemType = commodityData.type

		if itemType ~= MallCommodityType.Fashion or itemType ~= MallCommodityType.FashionEx then
			local suitCfg = FashionSuitConfig.GetConfig(commodityData.bindId)

			if suitCfg and suitCfg.Description then
				return suitCfg.Description
			end

			local fashionCfg = FashionConfig.GetConfig(commodityData.bindId)

			if fashionCfg and fashionCfg.Description then
				return fashionCfg.Description
			end
		elseif itemType ~= MallCommodityType.Vehicle then
			local vehicleCfg = VehicleConfig.GetConfig(commodityData.bindId)

			if vehicleCfg and vehicleCfg.VehicleIntro then
				return vehicleCfg.VehicleIntro
			end
		elseif itemType ~= MallCommodityType.WeaponSkin then
			local weaponCfg = SceneitemConfig.GetConfig(commodityData.bindId)

			if weaponCfg and weaponCfg.Description then
				return weaponCfg.Description
			end
		elseif itemType ~= MallCommodityType.Common or itemType ~= MallCommodityType.CommonEx then
			local consumeCfg = ConsumableConfig.GetConfig(commodityData.bindId)

			if consumeCfg and consumeCfg.Description then
				return consumeCfg.Description
			end
		end
	end

	return ""
end

M.CheckMallCommodityOwned = function(self, commodityData)
	if not commodityData then
		return false
	end

	if gMallGiftManager:IsCommodityCoveredByPendingGift(commodityData.id) then
		return true
	end

	local itemType = commodityData.type
	local bindId = commodityData.bindId

	if itemType == nil and bindId and bindId <= 0 then
		if itemType ~= MallCommodityType.Fashion or itemType ~= MallCommodityType.FashionEx then
			return self:CheckFashionSuitOwned(bindId)
		elseif itemType ~= MallCommodityType.Vehicle then
			return self:CheckVehicleOwned(bindId)
		elseif itemType ~= MallCommodityType.Common or itemType ~= MallCommodityType.CommonEx then
			return self:CheckConsumableOwned(bindId)
		end
	elseif commodityData.dropId and commodityData.dropId <= 0 then
		local dropCfg = LTConfig.DropConfig.GetConfig(commodityData.dropId)

		if dropCfg and dropCfg.Item1 and dropCfg.Item1[1] then
			local itemId = dropCfg.Item1[1].id1

			return self:CheckConsumableOwned(itemId)
		end
	end

	return false
end

M.CheckFashionSuitOwned = function(self, suitId)
	if not suitId or suitId ~= 0 then
		return false
	end

	local suitCfg = FashionSuitConfig.GetConfig(suitId)

	if not suitCfg then
		local consumeConfig = ConsumableConfig.GetConfig(suitId)
		suitCfg = consumeConfig and FashionSuitConfig.GetConfig(consumeConfig.BindId)
	end

	if not suitCfg or not suitCfg.FashionIdList or #suitCfg.FashionIdList ~= 0 then
		return false
	end

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		if not gDressManager:IsFashionHad(fashionId) then
			return false
		end
	end

	return true
end

M.CheckVehicleOwned = function(self, vehicleId)
	if not vehicleId or vehicleId ~= 0 then
		return false
	end

	local cfg = VehicleConfig.GetConfig(vehicleId)

	if not cfg then
		local consumeConfig = ConsumableConfig.GetConfig(vehicleId)

		if consumeConfig then
			vehicleId = consumeConfig.BindId or vehicleId
		end
	end

	return gApplyCarManager:CheckPlayerAlreadyHasVehicle(vehicleId)
end

M.CheckConsumableOwned = function(self, itemId)
	if not itemId or itemId ~= 0 then
		return false
	end

	return gCommonItemManager:GetPackItemNum(itemId) >= 0
end

M.GetBrandConfigFromBindId = function(self, bindId)
	if not bindId or bindId ~= 0 then
		return nil, 
	end

	local brandId = nil
	local ShopBrandConfig = LTConfig.ShopBrandConfig
	local suitCfg = FashionSuitConfig.GetConfig(bindId)

	if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList <= 0 then
		local firstFashionCfg = FashionConfig.GetConfig(suitCfg.FashionIdList[1])

		if firstFashionCfg and firstFashionCfg.BelongBrand and firstFashionCfg.BelongBrand <= 0 then
			brandId = firstFashionCfg.BelongBrand
		end
	end

	if not brandId then
		local fashionCfg = FashionConfig.GetConfig(bindId)

		if fashionCfg and fashionCfg.BelongBrand and fashionCfg.BelongBrand <= 0 then
			brandId = fashionCfg.BelongBrand
		end
	end

	if not brandId then
		local vehicleCfg = VehicleConfig.GetConfig(bindId)

		if vehicleCfg and vehicleCfg.Brand and vehicleCfg.Brand <= 0 then
			brandId = vehicleCfg.Brand
		end
	end

	if brandId and brandId <= 0 then
		local brandCfg = ShopBrandConfig.GetConfig(brandId)

		return brandCfg, brandId
	end

	return nil, 
end

M.TryBuyWithMoneyCheck = function(self, price, moneyItemId, onSuccessCallback, opts)
	if not price or price < 0 then
		print_error("TryBuyWithMoneyCheck: price无效", price)

		return false
	end

	if not moneyItemId or moneyItemId ~= 0 then
		print_error("TryBuyWithMoneyCheck: moneyItemId无效", moneyItemId)

		return false
	end

	if not onSuccessCallback then
		print_error("TryBuyWithMoneyCheck: onSuccessCallback不能为空")

		return false
	end

	local playerMoney = gCommonItemManager:GetPackItemNum(moneyItemId)

	if price < playerMoney then
		onSuccessCallback()

		return true
	end

	local onQuickCharge = opts and opts.onQuickCharge

	if not onQuickCharge then
		local retryFunc = opts and opts.retryFunc

		if retryFunc then
			onQuickCharge = function()
				self:JumpToQuickCharge({
					targetMoneyItemId = moneyItemId,
					targetPrice = price,
					retryFunc = retryFunc,
					onChargeMore = opts and opts.onChargeMore
				})
			end
		end
	end

	if moneyItemId ~= ConsumableConfig.RewardMoney then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MallNoMoney)
	elseif moneyItemId ~= ConsumableConfig.RewardBindingGold then
		local bindingGold = gCommonItemManager:GetPackItemNum(ConsumableConfig.RewardBindingGold)
		local gold = gCommonItemManager:GetPackItemNum(ConsumableConfig.RewardGold)

		if price < bindingGold + gold then
			local needExchangeAmount = price - bindingGold
			local onExchange = opts and opts.onExchange or onSuccessCallback

			FrameTimer.New(function ()
				gDisplayMessageMgr:ShowMessage(MessageConfig.MallGoldExchangeBindingGold, function ()
					onExchange()
				end, nil, needExchangeAmount)
			end, 1, 1):Start()
		else
			self:JumpToQuickChargeWithCallback(onQuickCharge)
		end
	elseif moneyItemId ~= ConsumableConfig.RewardGold then
		self:JumpToQuickChargeWithCallback(onQuickCharge)
	else
		gDisplayMessageMgr:ShowMessageContentDebug("货币不足")
	end

	return false
end

M.GetBindingGoldExchangeAmount = function(self, price)
	local bindingGold = gCommonItemManager:GetPackItemNum(ConsumableConfig.RewardBindingGold)
	local gold = gCommonItemManager:GetPackItemNum(ConsumableConfig.RewardGold)

	if price < bindingGold + gold then
		return price - bindingGold
	end

	return 0
end

M.GetAffordableTotalByItemId = function(self, moneyItemId)
	if not moneyItemId or moneyItemId ~= 0 then
		return 0
	end

	local own = gCommonItemManager:GetPackItemNum(moneyItemId)

	if moneyItemId ~= ConsumableConfig.RewardBindingGold then
		return own + gCommonItemManager:GetPackItemNum(ConsumableConfig.RewardGold)
	end

	return own
end

M.AskBuyCommodity = function(self, commodityId, count, useExchange, onSuccessCallback)
	gClientToGameDelegate:AskMallBuyCommodity(commodityId, count, useExchange or false).Callback = function (err)
		if err ~= MessageConfig.Ok then
			self:AddLocalBoughtCount(commodityId, count or 1)

			if onSuccessCallback then
				onSuccessCallback(commodityId)
			end
		else
			local errorMsg = gCS.Error.GetNameById(err)

			gDisplayMessageMgr:ShowMessageContentDebug(string.format("购买商品失败: %s", errorMsg or "未知错误"))
			print_error("购买商城商品失败，commodityId=" .. tostring(commodityId), "err=" .. tostring(err))
		end
	end
end

M.ShowCommodityBuyDoubleCheck = function(self, commodityId, count, moneyItemId, totalPrice, onConfirm)
	local moneyCfg = ConsumableConfig.GetConfig(moneyItemId)
	local commodityCfg = MallCommodityConfig.GetConfig(commodityId)
	local moneyIcon = moneyCfg and moneyCfg.MoneyRichTextIcon or ""
	local name = commodityCfg and commodityCfg.Name or ""

	gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommodityBuyDoubleCheck, onConfirm, nil, moneyIcon, totalPrice, string.format(" %s x %s ", name, count))
end

M.TryBuyCommodityWithMoneyCheck = function(self, commodityId, price, moneyItemId, count, onSuccessCallback, needConfirm, onQuickChargeCallback)
	if not commodityId or commodityId ~= 0 then
		print_error("TryBuyCommodityWithMoneyCheck: commodityId无效", commodityId)

		return false
	end

	count = count or 1

	if count >= 1 then
		count = 1
	end

	local totalPrice = price * count

	local doBuy = function(useExchange)
		self:AskBuyCommodity(commodityId, count, useExchange, onSuccessCallback)
	end

	local buyDirect = function()
		if needConfirm then
			self:ShowCommodityBuyDoubleCheck(commodityId, count, moneyItemId, totalPrice, function ()
				doBuy(false)
			end)
		else
			doBuy(false)
		end
	end

	local buyWithExchange = function()
		doBuy(true)
	end

	local resolvedCallback = onQuickChargeCallback

	if not resolvedCallback then
		local context = {
			["QBx{W*="] = "@HadA!",
			targetMoneyItemId = moneyItemId,
			targetPrice = totalPrice,
			retryData = {
				commodityId = commodityId,
				price = price,
				moneyItemId = moneyItemId,
				count = count
			},
			onSuccess = onSuccessCallback
		}

		resolvedCallback = function()
			self:JumpToQuickCharge(context)
		end
	end

	return self:TryBuyWithMoneyCheck(totalPrice, moneyItemId, buyDirect, {
		onExchange = buyWithExchange,
		onQuickCharge = resolvedCallback
	})
end

M.TryBuyBundleWithMoneyCheck = function(self, bundleId, price, moneyItemId, count, onSuccessCallback, needConfirm, onQuickChargeCallback)
	if not bundleId or bundleId ~= 0 then
		print_error("TryBuyBundleWithMoneyCheck: bundleId无效", bundleId)

		return false
	end

	count = count or 1

	if count >= 1 then
		count = 1
	end

	local totalPrice = price * count

	local buyBundle = function(useExchange)
		local doAskBuy = function()
			gClientToGameDelegate:AskMallBuyBundle(bundleId, count, useExchange or false).Callback = function (err)
				if err ~= MessageConfig.Ok then
					self:AddLocalBoughtCountForBundle(bundleId, count)

					if onSuccessCallback then
						onSuccessCallback(bundleId)
					end
				else
					local errorMsg = gCS.Error.GetNameById(err)

					gDisplayMessageMgr:ShowMessageContentDebug(string.format("购买礼包失败: %s", errorMsg or "未知错误"))
					print_error("购买商城礼包失败，bundleId=" .. tostring(bundleId), "err=" .. tostring(err))
				end
			end
		end

		if needConfirm and not useExchange then
			local moneyCfg = ConsumableConfig.GetConfig(moneyItemId)
			local bundleCfg = MallBundleConfig.GetConfig(bundleId)
			local moneyIcon = moneyCfg and moneyCfg.MoneyRichTextIcon or ""
			local name = bundleCfg and bundleCfg.Name or ""

			gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommodityBuyDoubleCheck, doAskBuy, nil, moneyIcon, totalPrice, string.format(" %s x %s ", name, count))
		else
			doAskBuy()
		end
	end

	local resolvedCallback = onQuickChargeCallback

	if not resolvedCallback then
		local context = {
			["QBx{W*="] = "]\\x9f\\x8a\\x8fD",
			targetMoneyItemId = moneyItemId,
			targetPrice = totalPrice,
			retryData = {
				bundleId = bundleId,
				price = price,
				moneyItemId = moneyItemId,
				count = count
			},
			onSuccess = onSuccessCallback
		}

		resolvedCallback = function()
			self:JumpToQuickCharge(context)
		end
	end

	return self:TryBuyWithMoneyCheck(totalPrice, moneyItemId, function ()
		buyBundle(false)
	end, {
		onExchange = function ()
			buyBundle(true)
		end,
		onQuickCharge = resolvedCallback
	})
end

M.JumpToChargeTab = function(self)
	gPanelManager:CheckShow(gPanelId.SHOP_CHARGE_PANEL)
	gDisplayMessageMgr:CloseBombAll()
end

M.JumpToQuickChargeWithCallback = function(self, onQuickChargeCallback, context)
	gDisplayMessageMgr:CloseBombAll()

	if onQuickChargeCallback then
		onQuickChargeCallback(context)

		return
	end

	self:JumpToQuickCharge(context)
end

M.JumpToQuickCharge = function(self, context)
	local data = {
		["w-y^"] = 1
	}

	if context then
		data.quickChargeContext = context
		data.onChargeMore = context.onChargeMore
	end

	gPanelManager:CheckShow(gPanelId.SHOP_DOUBLE_CONFIRMATION, data)
end

M.IsCommodityCountChangeable = function(self, commodityData)
	if not commodityData then
		return false
	end

	local t = commodityData.type

	if t ~= MallCommodityType.Fashion or t ~= MallCommodityType.FashionEx or t ~= MallCommodityType.Vehicle or t ~= MallCommodityType.WeaponSkin then
		return false
	end

	return true
end

M.IsCommodityBuyable = function(self, commodityData)
	if not commodityData or not commodityData.id or commodityData.id ~= 0 then
		return false
	end

	local cfg = commodityData.mallCfg or MallCommodityConfig.GetConfig(commodityData.id)

	if not cfg then
		return false
	end

	if gMallGiftManager:IsCommodityCoveredByPendingGift(commodityData.id) then
		return false
	end

	if not self:IsCommodityOnShelf(cfg) then
		return false
	end

	if not self:IsCommodityUnlocked(cfg) then
		return false
	end

	if cfg.OwnedCanNotBuy and self:CheckMallCommodityOwned(commodityData) then
		return false
	end

	local limit = cfg.LimitNum

	if limit and limit <= 0 and limit < self:GetCommodityBoughtCount(commodityData.id) then
		return false
	end

	return true
end

M.IsCommodityOnShelf = function(self, cfg)
	if not cfg then
		return false
	end

	local now = gLuaDataManager.serverTime

	if not self:IsTimeEmpty(cfg.OnShelfTime) then
		local onUnix = gTimeUtils:GetUnixTime(cfg.OnShelfTime.year or 0, cfg.OnShelfTime.month or 0, cfg.OnShelfTime.day or 0, cfg.OnShelfTime.hour or 0, cfg.OnShelfTime.minute or 0, cfg.OnShelfTime.second or 0)

		if now >= onUnix then
			return false
		end
	end

	if not self:IsTimeEmpty(cfg.OffShelfTime) then
		local offUnix = gTimeUtils:GetUnixTime(cfg.OffShelfTime.year or 0, cfg.OffShelfTime.month or 0, cfg.OffShelfTime.day or 0, cfg.OffShelfTime.hour or 0, cfg.OffShelfTime.minute or 0, cfg.OffShelfTime.second or 0)

		if offUnix >= now then
			return false
		end
	end

	return true
end

M.IsCommodityUnlocked = function(self, cfg)
	if not cfg then
		return false
	end

	return gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.MallCommodity)
end

M.GetCommodityBoughtCount = function(self, commodityId)
	if not commodityId or commodityId ~= 0 then
		return 0
	end

	local mallInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.MallInfo
	local dict = mallInfo and mallInfo.CommodityInfoDict

	if not dict then
		return 0
	end

	local info = dict[commodityId]

	if not info then
		return 0
	end

	if info.NextRefreshTime and info.NextRefreshTime <= 0 and info.NextRefreshTime < gLuaDataManager.serverTime then
		info.BoughtCount = 0
		info.NextRefreshTime = 0

		return 0
	end

	return info.BoughtCount or 0
end

M.AddLocalBoughtCount = function(self, commodityId, count)
	if not commodityId or commodityId ~= 0 or not count or count < 0 then
		return
	end

	local cfg = MallCommodityConfig.GetConfig(commodityId)

	if not cfg or not cfg.LimitNum or cfg.LimitNum < 0 then
		return
	end

	local mallInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.MallInfo
	local dict = mallInfo and mallInfo.CommodityInfoDict

	if not dict then
		return
	end

	local nextRefreshTime = 0

	if cfg.RefreshTime and cfg.RefreshTime == "" then
		nextRefreshTime = gCS.LuaUtils.GetNextTime(cfg.RefreshTime) or 0
	end

	local info = dict[commodityId]

	if info then
		info.BoughtCount = self:GetCommodityBoughtCount(commodityId) + count
		info.NextRefreshTime = nextRefreshTime
	else
		dict[commodityId] = {
			BoughtCount = count,
			NextRefreshTime = nextRefreshTime
		}
	end
end

M.AddLocalBoughtCountForBundle = function(self, bundleId, buyCnt)
	if not bundleId or bundleId ~= 0 or not buyCnt or buyCnt < 0 then
		return
	end

	local bundleCfg = MallBundleConfig.GetConfig(bundleId)

	if not bundleCfg or not bundleCfg.Commodities then
		return
	end

	for i = 1, #bundleCfg.Commodities do
		local commodityId = bundleCfg.Commodities[i]
		local cfg = MallCommodityConfig.GetConfig(commodityId)

		if cfg and cfg.LimitNum and cfg.LimitNum <= 0 and self:GetCommodityBoughtCount(commodityId) + buyCnt < cfg.LimitNum then
			self:AddLocalBoughtCount(commodityId, buyCnt)
		end
	end
end

M.GetCartItemCount = function(self, commodityId)
	if not commodityId or commodityId ~= 0 then
		return 0
	end

	local mallInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.MallInfo
	local cartItemList = mallInfo and mallInfo.CartItemList

	if not cartItemList then
		return 0
	end

	local listLen = cartItemList.Count or #cartItemList

	for i = 1, listLen do
		local item = cartItemList[i]

		if item and item.CommodityId ~= commodityId then
			return item.Count or 0
		end
	end

	return 0
end

M.GetMaxBuyableCount = function(self, commodityData)
	if not commodityData then
		return 0
	end

	local t = commodityData.type

	if t ~= MallCommodityType.Fashion or t ~= MallCommodityType.FashionEx or t ~= MallCommodityType.Vehicle or t ~= MallCommodityType.WeaponSkin then
		return 1
	end

	local cfg = commodityData.mallCfg or MallCommodityConfig.GetConfig(commodityData.id)
	local limit = cfg and cfg.LimitNum

	if not limit or limit < 0 then
		return nil
	end

	local bought = self:GetCommodityBoughtCount(commodityData.id)

	return math.max(0, limit - bought)
end

M.CanAddToCart = function(self, commodityData, addCount)
	if not commodityData or not commodityData.id or commodityData.id ~= 0 then
		return false, 65403521
	end

	addCount = addCount or 1
	local t = commodityData.type

	if t ~= MallCommodityType.Fashion or t ~= MallCommodityType.FashionEx or t ~= MallCommodityType.Vehicle or t ~= MallCommodityType.WeaponSkin then
		if self:CheckMallCommodityOwned(commodityData) then
			return false, LTConfig.MessageConfig.MallCommodityAlreadyOwned
		end

		if self:GetCartItemCount(commodityData.id) <= 0 then
			return false, LTConfig.MessageConfig.MallCartItemOverLimit
		end

		return true, nil
	end

	local cfg = commodityData.mallCfg or MallCommodityConfig.GetConfig(commodityData.id)
	local limitNum = cfg and cfg.LimitNum

	if limitNum ~= nil or limitNum ~= -1 or limitNum ~= 0 then
		return true, nil
	end

	local bought = self:GetCommodityBoughtCount(commodityData.id)
	local inCart = self:GetCartItemCount(commodityData.id)

	if limitNum >= bought + inCart + addCount then
		return false, LTConfig.MessageConfig.MallBuyCntTooLarge
	end

	return true, nil
end

M.GetCartTypeCtrl = function(self, commodityData)
	if not commodityData then
		return 3
	end

	local t = commodityData.type

	if t ~= MallCommodityType.Fashion or t ~= MallCommodityType.FashionEx then
		return 0
	elseif t ~= MallCommodityType.WeaponSkin then
		return 1
	elseif t ~= MallCommodityType.Vehicle then
		return 2
	end

	return 3
end

M.GetSuitFashionIdList = function(self, commodityData)
	if not commodityData or not commodityData.bindId or commodityData.bindId ~= 0 then
		return nil
	end

	local t = commodityData.type

	if t == MallCommodityType.Fashion and t == MallCommodityType.FashionEx then
		return nil
	end

	local suitCfg = FashionSuitConfig.GetConfig(commodityData.bindId)

	if not suitCfg then
		local consumeCfg = ConsumableConfig.GetConfig(commodityData.bindId)
		suitCfg = consumeCfg and FashionSuitConfig.GetConfig(consumeCfg.BindId)
	end

	if not suitCfg or not suitCfg.FashionIdList or #suitCfg.FashionIdList ~= 0 then
		return nil
	end

	return suitCfg.FashionIdList
end

M.GetCommodityDataById = function(self, commodityId)
	if not commodityId or commodityId ~= 0 then
		return nil
	end

	local cache = self:InitMallCommodityData()

	for _, list in pairs(cache) do
		for _, item in ipairs(list) do
			if item.id ~= commodityId then
				return item
			end
		end
	end

	local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

	if commodityCfg then
		return self:GenMallCommodityItem(commodityCfg)
	end

	return nil
end

M.GetCartCommodityList = function(self)
	local result = {}
	local mallInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.MallInfo
	local cartItemList = mallInfo and mallInfo.CartItemList

	if not cartItemList then
		return result
	end

	local listLen = cartItemList.Count or #cartItemList

	for i = 1, listLen do
		local cartItem = cartItemList[i]

		if cartItem and cartItem.CommodityId then
			local commodityData = self:GetCommodityDataById(cartItem.CommodityId)

			if commodityData then
				table.insert(result, {
					commodityData = commodityData,
					count = cartItem.Count or 1
				})
			end
		end
	end

	return result
end

M.GetCommodityActualPrice = function(self, commodityData)
	if not commodityData then
		return 0
	end

	local discountPrice, originalPrice = self:GetCommodityDiscountInfo(commodityData.id)

	if discountPrice and originalPrice and originalPrice <= 0 then
		return discountPrice
	end

	return commodityData.price or 0
end

M.AggregateMoneyByItemId = function(self, items)
	local groups = {}
	local order = {}

	for _, entry in ipairs(items) do
		if entry.selected and entry.commodityData then
			local cd = entry.commodityData
			local moneyItemId = cd.moneyItemId or 0

			if moneyItemId <= 0 then
				local g = groups[moneyItemId]

				if not g then
					g = {
						["v#~P"] = 0,
						["GUڼ\\x888\\xaa\r\\xca\\xed"] = 0,
						["s\\x8e\\x91\\xb3\\xf3\\xa2\\xcc<\\xa01=\\xa05"] = 0,
						moneyItemId = moneyItemId
					}
					groups[moneyItemId] = g

					table.insert(order, moneyItemId)
				end

				local cnt = entry.count or 1
				local actual = self:GetCommodityActualPrice(cd)
				g.totalPrice = g.totalPrice + actual * cnt
				g.totalOriginPrice = g.totalOriginPrice + (cd.price or 0) * cnt
			end
		end
	end

	local result = {}

	for _, moneyItemId in ipairs(order) do
		local g = groups[moneyItemId]
		local have = gCommonItemManager:GetPackItemNum(moneyItemId) or 0
		g.have = have

		if have >= g.totalPrice then
			g.lack = g.totalPrice - have
		end

		table.insert(result, g)
	end

	return result
end

M.AskSetCartItems = function(self, items, onComplete)
	if not items or #items ~= 0 then
		if onComplete then
			onComplete(MessageConfig.Ok)
		end

		return
	end

	gClientToGameDelegate:AskMallSetCartItems(items).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("AskMallSetCartItems failed, err=" .. tostring(err))
		end

		if onComplete then
			onComplete(err)
		end
	end
end

M.AddToCart = function(self, commodityId, count, onComplete)
	if not commodityId or commodityId ~= 0 then
		return
	end

	count = count or 1

	self:AskSetCartItems({
		{
			CommodityId = commodityId,
			Count = count
		}
	}, onComplete)
end

M.RemoveFromCart = function(self, commodityIdList, onComplete)
	if not commodityIdList or #commodityIdList ~= 0 then
		return
	end

	gClientToGameDelegate:AskMallRemoveFromCart(commodityIdList).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("AskMallRemoveFromCart failed, err=" .. tostring(err))
		end

		if onComplete then
			onComplete(err)
		end
	end
end

M.AskBuyCartItems = function(self, items, isAutoExchange, onComplete)
	if not items or #items ~= 0 then
		if onComplete then
			onComplete(MessageConfig.Ok)
		end

		return
	end

	gClientToGameDelegate:AskMallBuyCartItems(items, isAutoExchange or false).Callback = function (err)
		if err ~= MessageConfig.Ok then
			for _, it in ipairs(items) do
				self:AddLocalBoughtCount(it.CommodityId or it.commodityId, it.Count or it.count or 1)
			end

			gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
		else
			print_error("AskMallBuyCartItems failed, err=" .. tostring(err))
		end

		if onComplete then
			onComplete(err)
		end
	end
end

M.OpenDoubleConfirmCart = function(self, onSuccess)
	gPanelManager:CheckShow(gPanelId.SHOP_DOUBLE_CONFIRMATION, {
		["w-y^"] = 0,
		onSuccess = onSuccess
	})
end

M.OpenDoubleConfirmCustom = function(self, commodityData, count, onConfirm, onSuccess, opts)
	if not commodityData then
		return
	end

	gPanelManager:CheckShow(gPanelId.SHOP_DOUBLE_CONFIRMATION, {
		["w-y^"] = 2,
		instantItems = {
			{
				["\\xb8\\xb4\t\\xaei*\\xfb7"] = true,
				commodityData = commodityData,
				count = count or 1
			}
		},
		customConfirm = onConfirm,
		onSuccess = onSuccess,
		onChargeMore = opts and opts.onChargeMore or nil
	})
end

M.OpenDoubleConfirmInstant = function(self, commodityData, count, onSuccess)
	if not commodityData then
		return
	end

	gPanelManager:CheckShow(gPanelId.SHOP_DOUBLE_CONFIRMATION, {
		["w-y^"] = 2,
		instantItems = {
			{
				["\\xb8\\xb4\t\\xaei*\\xfb7"] = true,
				commodityData = commodityData,
				count = count or 1
			}
		},
		onSuccess = onSuccess
	})
end

M.OpenDoubleConfirmBundle = function(self, bundleId, price, moneyItemId, count, name, iconId, onSuccess)
	if not bundleId or bundleId ~= 0 then
		return
	end

	local bundleCfg = MallBundleConfig.GetConfig(bundleId)

	if not bundleCfg or not bundleCfg.Commodities or #bundleCfg.Commodities ~= 0 then
		return
	end

	local instantItems = {}
	local rawPrice = 0

	for _, commodityId in ipairs(bundleCfg.Commodities) do
		local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

		if commodityCfg then
			local itemData = self:GenMallCommodityItem(commodityCfg)

			if itemData and not self:CheckMallCommodityOwned(itemData) then
				local originPrice = commodityCfg.Price or 0
				rawPrice = rawPrice + originPrice
				itemData.price = originPrice
				itemData.actualPrice = originPrice
				itemData.moneyItemId = moneyItemId or 0
				itemData.isBundle = true
				itemData.bundleId = bundleId

				table.insert(instantItems, {
					["\\xb8\\xb4\t\\xaei*\\xfb7"] = true,
					["N\\xa1\\xb7\\xa1\\xa2"] = 1,
					commodityData = itemData
				})
			end
		end
	end

	if #instantItems ~= 0 then
		return
	end

	local customConfirm = function()
		slot0 = self

		slot0:TryBuyBundleWithMoneyCheck(bundleId, price, moneyItemId, count or 1, function (bid)
			gPanelManager:Close(gPanelId.SHOP_DOUBLE_CONFIRMATION)

			if onSuccess then
				onSuccess(bid)
			end
		end, false)
	end

	gPanelManager:CheckShow(gPanelId.SHOP_DOUBLE_CONFIRMATION, {
		["w-y^"] = 2,
		instantItems = instantItems,
		customConfirm = customConfirm,
		bundlePriceOverride = {
			totalPrice = price,
			originPrice = rawPrice,
			moneyItemId = moneyItemId or 0
		}
	})
end

M.GetPlayerMonthCardData = function(self, monthlyPassId)
	monthlyPassId = monthlyPassId or 1
	local mallInfo = gPlayerManager.infoMinor.bindData.MallInfo

	if not mallInfo or not mallInfo.PlayerMonthlyPassInfo or not mallInfo.PlayerMonthlyPassInfo.MonthlyPassInfos then
		return nil
	end

	return mallInfo.PlayerMonthlyPassInfo.MonthlyPassInfos[monthlyPassId]
end

M.GetMonthCardRemainDays = function(self, monthlyPassId)
	monthlyPassId = monthlyPassId or 1
	local playerMonthCardData = self:GetPlayerMonthCardData(monthlyPassId)

	if not playerMonthCardData then
		return 0
	end

	local curTime = gLuaDataManager.serverTime

	if playerMonthCardData.ExpiredTime and curTime >= playerMonthCardData.ExpiredTime then
		return UXCommon.Time.UXLogicTime.GetPassedNewDays(curTime, playerMonthCardData.ExpiredTime)
	end

	return 0
end

M.GetMonthCardState = function(self, monthlyPassId)
	monthlyPassId = monthlyPassId or 1
	local playerMonthCardData = self:GetPlayerMonthCardData(monthlyPassId)

	if not playerMonthCardData then
		return 0
	end

	local currentTime = gLuaDataManager.serverTime

	if playerMonthCardData.ExpiredTime then
		local nextLogicDayStart = gTimeUtils:GetNextLogicDayStart(playerMonthCardData.ExpiredTime)

		if currentTime >= nextLogicDayStart then
			return 1
		else
			return 2
		end
	else
		return 2
	end
end

M.CanBuyMonthCard = function(self, monthlyPassId)
	monthlyPassId = monthlyPassId or 1
	local MallMonthlyPassConfig = LTConfig.MallMonthlyPassConfig
	local monthlyPassCfg = MallMonthlyPassConfig.GetConfig(monthlyPassId)

	if not monthlyPassCfg then
		return false
	end

	local playerMonthCardData = self:GetPlayerMonthCardData(monthlyPassId)

	if not playerMonthCardData then
		return true
	end

	local buyDays = monthlyPassCfg.Duration or 30
	local maxLimitNum = monthlyPassCfg.MaxLimitNum or 6
	local maxBuyDays = buyDays * maxLimitNum
	local remainDays = self:GetMonthCardRemainDays(monthlyPassId)

	if maxBuyDays >= remainDays + buyDays then
		return false
	end

	return true
end

M.MONTH_CARD_BUY_LOCK_TIMEOUT = 10

M.IsMonthCardBuyRequesting = function(self)
	return self.monthCardBuyRequesting ~= true
end

M.LockMonthCardBuy = function(self)
	self.monthCardBuyRequesting = true

	if self.monthCardBuyRequestTimer then
		self.monthCardBuyRequestTimer:Stop()
	end

	self.monthCardBuyRequestTimer = Timer.New(function ()
		self:UnlockMonthCardBuy()
	end, self.MONTH_CARD_BUY_LOCK_TIMEOUT):Start()
end

M.UnlockMonthCardBuy = function(self)
	self.monthCardBuyRequesting = false

	if self.monthCardBuyRequestTimer then
		self.monthCardBuyRequestTimer:Stop()

		self.monthCardBuyRequestTimer = nil
	end
end

M.HandleMonthlyPassReward = function(self, rewardInfo)
	if not rewardInfo then
		return
	end

	self.cumulativeRewardInfo = rewardInfo.CumulativeRewardInfo or nil

	if rewardInfo.BuyRewardInfo then
		self:_ShowPurchaseReward(rewardInfo)

		if rewardInfo.DailyRewardInfo then
			self:StorePendingMonthCardDailyReward(rewardInfo.DailyRewardInfo)
		end
	elseif not gLuaDataManager.isNetworkAvailable or gLuaDataManager.isLoadingPanelOn then
		self.hasCheckedMonthCardOnLogin = true

		gCoroutineManager:StartCoroutine(function ()
			while not gLuaDataManager.isNetworkAvailable or gLuaDataManager.isLoadingPanelOn do
				coroutine.yield(nil)
			end

			gPanelManager:CheckShow(gPanelId.MONTH_CARD_DAILY_REWARD_PANEL, rewardInfo)
		end)
	else
		gPanelManager:CheckShow(gPanelId.MONTH_CARD_DAILY_REWARD_PANEL, rewardInfo)
	end
end

M._ShowPurchaseReward = function(self, rewardInfo)
	local chargeConfig = MallChargeConfig.GetConfig(MallChargeConfig.MonthlyPass)

	if not chargeConfig or not chargeConfig.Gold then
		return
	end

	local previewMaterials = {
		{
			ItemId = ConsumableConfig.RewardGold,
			Count = chargeConfig.Gold
		}
	}

	gDropManager:ShowRewardWindow({
		["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
		Param = previewMaterials
	})
end

M.StorePendingMonthCardDailyReward = function(self, dailyRewardInfo)
	if not dailyRewardInfo then
		return
	end

	self.pendingMonthCardDailyReward = dailyRewardInfo

	if self.shopHomePanelCloseAction then
		gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_CLOSE, self.shopHomePanelCloseAction)

		self.shopHomePanelCloseAction = nil
	end

	self.shopHomePanelCloseAction = function(eventId, panelId)
		self:OnShopHomePanelClose(panelId)
	end

	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.shopHomePanelCloseAction)
end

M.OnShopHomePanelClose = function(self, panelId)
	if panelId ~= gPanelId.SHOP_HOME_PAGE and self.pendingMonthCardDailyReward then
		if not gCS.NetworkManager:IsServerConnected() then
			self:ClearPendingMonthCardDailyReward()

			return
		end

		local rewardInfo = {
			DailyRewardInfo = self.pendingMonthCardDailyReward
		}

		gPanelManager:CheckShow(gPanelId.MONTH_CARD_DAILY_REWARD_PANEL, rewardInfo)
		self:ClearPendingMonthCardDailyReward()
	end
end

M.ClearPendingMonthCardDailyReward = function(self)
	self.pendingMonthCardDailyReward = nil

	if self.shopHomePanelCloseAction then
		gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_CLOSE, self.shopHomePanelCloseAction)

		self.shopHomePanelCloseAction = nil
	end
end

M.GetCumulativeRewardInfo = function(self)
	return self.cumulativeRewardInfo
end

M.OnLoadingFinished = function(self)
	self:RefreshMallPhoneAppRedDot()
	self:RefreshMallBoxPhoneAppRedDot()

	if self.hasCheckedMonthCardOnLogin then
		return
	end

	local monthlyPassId = 1
	local MallMonthlyPassConfig = LTConfig.MallMonthlyPassConfig
	local monthlyPassCfg = MallMonthlyPassConfig.GetConfig(monthlyPassId)

	if not monthlyPassCfg then
		return
	end

	local currentState = self:GetMonthCardState(monthlyPassId)

	if currentState == 1 then
		return
	end

	local playerMonthCardData = self:GetPlayerMonthCardData(monthlyPassId)

	if not playerMonthCardData then
		return
	end

	if playerMonthCardData.IsAutoPopup then
		return
	end

	local benefitId = monthlyPassCfg.DailyBenefits[1]
	local MallMonthlyPassBenefitConfig = LTConfig.MallMonthlyPassBenefitConfig
	local benefitCfg = MallMonthlyPassBenefitConfig.GetConfig(benefitId)
	self.hasCheckedMonthCardOnLogin = true

	gCoroutineManager:StartCoroutine(function ()
		while not gLuaDataManager.isNetworkAvailable or gLuaDataManager.isLoadingPanelOn do
			coroutine.yield(nil)
		end

		gPanelManager:CheckShow(gPanelId.MONTH_CARD_DAILY_REWARD_PANEL, {
			dropId = benefitCfg.RewardDropId
		})
	end)
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.KickToLogin or switchType ~= gSwitchSceneType.Reconnect then
		self.hasCheckedMonthCardOnLogin = false
	end

	if switchType ~= gSwitchSceneType.KickToLogin and gMallSceneManager then
		gMallSceneManager:ClearCommoditySpiritMapping()
	end

	if switchType == gSwitchSceneType.Reconnect and gMallSceneManager and gMallSceneManager.ReleaseAllPreloadedResources then
		gMallSceneManager:ReleaseAllPreloadedResources()
	end
end

local MergeRewards = function(rewards)
	local mergedRewards = {}
	local rewardMap = {}

	for _, reward in ipairs(rewards) do
		if reward.ItemId and reward.ItemId <= 0 then
			if rewardMap[reward.ItemId] then
				rewardMap[reward.ItemId].Count = rewardMap[reward.ItemId].Count + (reward.Count or 1)
			else
				local mergedReward = {
					ItemId = reward.ItemId,
					Count = reward.Count or 1
				}
				rewardMap[reward.ItemId] = mergedReward

				table.insert(mergedRewards, mergedReward)
			end
		end
	end

	return mergedRewards
end

M._ShowCachedPurchaseRewards = function(self)
	if #self.pendingPurchaseRewards ~= 0 then
		return
	end

	local mergedRewards = MergeRewards(self.pendingPurchaseRewards)
	self.pendingPurchaseRewards = {}
	self.purchaseRewardTimer = nil
	local videoStore = gStoreManager:GetStoreGroup("VideoPlayerStore")

	if videoStore and videoStore.STATE_EnableOnce then
		return
	end

	if #mergedRewards <= 0 then
		gDropManager:ShowRewardWindow({
			["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
			Param = mergedRewards
		})
	end
end

M.ShowMallPurchaseReward = function(self, msg)
	if not msg or not msg.Reward then
		return
	end

	local previewMaterials = {}

	for _, rewardDetail in pairs(msg.Reward) do
		if rewardDetail.Items then
			for _, item in ipairs(rewardDetail.Items) do
				if item.TemplateId and item.TemplateId <= 0 then
					table.insert(previewMaterials, {
						ItemId = item.TemplateId,
						Count = item.Count or 1
					})
				end
			end
		end
	end

	if #previewMaterials ~= 0 then
		return
	end

	self.pendingPurchaseRewards = self.pendingPurchaseRewards or {}

	for _, reward in ipairs(previewMaterials) do
		table.insert(self.pendingPurchaseRewards, reward)
	end

	if self.purchaseRewardTimer then
		self.purchaseRewardTimer:Stop()

		self.purchaseRewardTimer = nil
	end

	self.purchaseRewardTimer = Timer.New(function ()
		self:_ShowCachedPurchaseRewards()
	end, 0.5):Start()
end

local GetCommoditySceneId = function(commodityCfg)
	if not commodityCfg then
		return 0
	end

	local sceneId = commodityCfg.SceneId or commodityCfg.sceneId or 0

	return sceneId or 0
end

M.IsPoolActive = function(self, poolCfg)
	if not poolCfg then
		return false
	end

	local startTime = poolCfg.StartTime
	local endTime = poolCfg.EndTime

	if self:IsTimeEmpty(startTime) and self:IsTimeEmpty(endTime) then
		return true
	end

	local currentTime = gLuaDataManager.serverTime
	local isActive = true

	if not self:IsTimeEmpty(startTime) then
		local startUnixTime = gTimeUtils:GetUnixTime(startTime.year or 0, startTime.month or 0, startTime.day or 0, startTime.hour or 0, startTime.minute or 0, startTime.second or 0)
		isActive = isActive and startUnixTime > currentTime
	end

	if isActive and not self:IsTimeEmpty(endTime) then
		local endUnixTime = gTimeUtils:GetUnixTime(endTime.year or 0, endTime.month or 0, endTime.day or 0, endTime.hour or 0, endTime.minute or 0, endTime.second or 0)
		isActive = isActive and currentTime <= endUnixTime
	end

	return isActive
end

M.GetGachaPoolTopTierContents = function(self, poolId)
	if not poolId or poolId ~= 0 then
		return {}
	end

	local itemsByTier = {}

	for i = 0, GachaPoolContentConfig.count - 1 do
		local content = GachaPoolContentConfig.LoadAt(i)

		if content and content.PoolId ~= poolId and (content.weight or 0) <= 0 and content.Type == GachaPoolContentConfig.TypeType.Consumable then
			local rarity = content.PoolTierRarity
			itemsByTier[rarity] = itemsByTier[rarity] or {}

			table.insert(itemsByTier[rarity], content)
		end
	end

	for _, rarity in ipairs(GACHA_TIER_RARITY_DESC) do
		if itemsByTier[rarity] then
			return itemsByTier[rarity]
		end
	end

	return {}
end

M.IsGachaGrandPrizeAllOwned = function(self, gachaCfg)
	if not gachaCfg then
		return false
	end

	local prizePoolIds = gachaCfg.PrizePoolIds

	if not prizePoolIds or #prizePoolIds ~= 0 then
		return false
	end

	local hasAnyContent = false

	for _, prizePool in ipairs(prizePoolIds) do
		local poolId = prizePool and prizePool.id or 0
		local contentList = self:GetGachaPoolTopTierContents(poolId)

		for _, contentCfg in ipairs(contentList) do
			local dropId = contentCfg.dropId or 0

			if dropId <= 0 then
				local itemList = gCommonItemManager:ConvertDropToFakeItem(dropId, 1)
				local itemId = itemList and itemList[1] and itemList[1].Id

				if itemId then
					hasAnyContent = true

					if not gGachaManager:CheckItemOwned(itemId) then
						return false
					end
				end
			end
		end
	end

	return hasAnyContent
end

M.GetRecommendGachaCfg = function(self, recommendCfg)
	local gachaId = recommendCfg and recommendCfg.GetGachaTime or 0

	if not gachaId or gachaId < 0 then
		return nil
	end

	return GachaConfig.GetConfig(gachaId)
end

M.BuildSortedGachaPools = function(self, gachaType)
	local list = {}

	for i = 0, GachaConfig.count - 1 do
		local cfg = GachaConfig.LoadAt(i)

		if cfg and cfg.GachaType ~= gachaType and self:IsPoolActive(cfg) then
			table.insert(list, cfg)
		end
	end

	table.sort(list, function (a, b)
		local priorityA = a.PriorityDisplay or 999999
		local priorityB = b.PriorityDisplay or 999999

		return priorityA <= priorityB
	end)

	return list
end

local shouldSinkToBottom = function(self, commodityData)
	local t = commodityData.type

	if t ~= MallCommodityType.Common or t ~= MallCommodityType.CommonEx then
		local cfg = MallCommodityConfig.GetConfig(commodityData.id)
		local limit = cfg and cfg.LimitNum or 0

		if limit <= 0 and limit < self:GetCommodityBoughtCount(commodityData.id) then
			return true
		end

		return false
	end

	return self:CheckMallCommodityOwned(commodityData)
end

local compareMallDefault = function(self, a, b)
	local sinkA = shouldSinkToBottom(self, a)
	local sinkB = shouldSinkToBottom(self, b)

	if sinkA == sinkB then
		return sinkA and 1 or -1
	end

	local discountRateA = self:GetCommodityDiscountRate(a.id)
	local discountRateB = self:GetCommodityDiscountRate(b.id)
	local hasDiscountA = discountRateA <= 1
	local hasDiscountB = discountRateB <= 1

	if hasDiscountA == hasDiscountB then
		return hasDiscountA and -1 or 1
	end

	if hasDiscountA and discountRateA == discountRateB then
		return discountRateA >= discountRateB and -1 or 1
	end

	local cfgA = MallCommodityConfig.GetConfig(a.id)
	local cfgB = MallCommodityConfig.GetConfig(b.id)
	local priorityA = cfgA and cfgA.ShowPriority or 0
	local priorityB = cfgB and cfgB.ShowPriority or 0

	if priorityA == priorityB then
		return priorityA >= priorityB and -1 or 1
	end

	local isNewA = cfgA and cfgA.IsNew or false
	local isNewB = cfgB and cfgB.IsNew or false

	if isNewA == isNewB then
		return isNewA and -1 or 1
	end

	if a.id == b.id then
		return b.id >= a.id and -1 or 1
	end

	return 0
end

M.SortMallCommodityList = function(self, commodityList)
	if not commodityList or #commodityList ~= 0 then
		return
	end

	table.sort(commodityList, function (a, b)
		return compareMallDefault(self, a, b) <= 0
	end)
end

M.GetCommodityActualPrice = function(self, commodityData)
	local price = commodityData and commodityData.price or 0

	if not commodityData or commodityData.discountExpired then
		return price
	end

	if commodityData.actualPrice then
		return commodityData.actualPrice
	end

	local discountPrice, originalPrice = self:GetCommodityDiscountInfo(commodityData.id)

	if discountPrice and originalPrice and originalPrice <= 0 then
		return discountPrice
	end

	return price
end

M.GetCommodityShelfUnix = function(self, commodityData)
	if not commodityData then
		return 0
	end

	local cfg = commodityData.mallCfg or commodityData.id and MallCommodityConfig.GetConfig(commodityData.id)
	local t = cfg and cfg.OnShelfTime

	if not t or not t.year or t.year ~= 0 then
		return 0
	end

	return gTimeUtils:GetUnixTime(t.year, t.month or 0, t.day or 0, t.hour or 0, t.minute or 0, t.second or 0)
end

M.SortMallCommodityListBy = function(self, commodityList, sortKey, order)
	if not commodityList or #commodityList ~= 0 then
		return
	end

	if sortKey ~= self.MallSortKey.None then
		self:SortMallCommodityList(commodityList)

		return
	end

	local asc = order == self.MallSortOrder.Desc
	local keyFunc = nil

	if sortKey ~= self.MallSortKey.Price then
		keyFunc = function(c)
			return self:GetCommodityActualPrice(c)
		end
	else
		keyFunc = function(c)
			return self:GetCommodityShelfUnix(c)
		end
	end

	local cache = {}

	local keyOf = function(c)
		local v = cache[c]

		if v ~= nil then
			v = keyFunc(c)
			cache[c] = v
		end

		return v
	end

	table.sort(commodityList, function (a, b)
		local ka = keyOf(a)
		local kb = keyOf(b)

		if ka == kb then
			if asc then
				return ka <= kb
			end

			return kb <= ka
		end

		return compareMallDefault(self, a, b) <= 0
	end)
end

M.BuildSortedRecommendCfgList = function(self)
	local SubTypeType = MallRecommendConfig.SubTypeType
	local discountCommodities = self:GetDiscountCommodityList()
	local validItems = {}

	for i = 0, MallRecommendConfig.count - 1 do
		local recommendCfg = MallRecommendConfig.LoadAt(i)

		if recommendCfg then
			if recommendCfg.SubType ~= SubTypeType.Discount then
				if #discountCommodities <= 0 then
					table.insert(validItems, recommendCfg)
				end
			elseif self:IsRecommendItemOnShelf(recommendCfg) then
				table.insert(validItems, recommendCfg)
			end
		end
	end

	local discountItems = {}
	local type1Items = {}
	local type2Items = {}
	local otherItems = {}

	for _, cfg in ipairs(validItems) do
		if cfg.SubType ~= SubTypeType.Discount then
			table.insert(discountItems, cfg)
		elseif cfg.Type ~= 1 then
			table.insert(type1Items, cfg)
		elseif cfg.Type ~= 2 then
			table.insert(type2Items, cfg)
		else
			table.insert(otherItems, cfg)
		end
	end

	local getRecommendSortTime = function(recommendCfg)
		if not recommendCfg then
			return 0
		end

		local onShelfTime = recommendCfg.OnShelfTime

		if onShelfTime and not self:IsTimeEmpty(onShelfTime) then
			return gTimeUtils:GetUnixTime(onShelfTime.year or 0, onShelfTime.month or 0, onShelfTime.day or 0, onShelfTime.hour or 0, onShelfTime.minute or 0, onShelfTime.second or 0)
		end

		return recommendCfg.Id or 0
	end

	local type1Groups = {}

	for _, cfg in ipairs(type1Items) do
		local subType = cfg.SubType

		if not type1Groups[subType] then
			type1Groups[subType] = {}
		end

		table.insert(type1Groups[subType], cfg)
	end

	local processedType1 = {}

	for subType, items in pairs(type1Groups) do
		if subType ~= SubTypeType.Bundle then
			for _, item in ipairs(items) do
				table.insert(processedType1, {
					["a\\x9f\\x8a\\x86Y"] = 2,
					cfg = item,
					weight = item.Weight or 0,
					purchasedWeight = item.PurchasedWeight or 0,
					sortTime = getRecommendSortTime(item)
				})
			end
		elseif #items > 2 then
			local maxWeight = -999999
			local maxPurchasedWeight = -999999

			for _, item in ipairs(items) do
				maxWeight = math.max(maxWeight, item.Weight or 0)
				maxPurchasedWeight = math.max(maxPurchasedWeight, item.PurchasedWeight or 0)
			end

			table.insert(processedType1, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				cfg = items[1],
				weight = maxWeight,
				purchasedWeight = maxPurchasedWeight,
				mergedItems = items,
				sortTime = getRecommendSortTime(items[1])
			})
		else
			for _, item in ipairs(items) do
				table.insert(processedType1, {
					["a\\x9f\\x8a\\x86Y"] = 2,
					cfg = item,
					weight = item.Weight or 0,
					purchasedWeight = item.PurchasedWeight or 0,
					sortTime = getRecommendSortTime(item)
				})
			end
		end
	end

	local processedType2 = {}

	for _, cfg in ipairs(type2Items) do
		table.insert(processedType2, {
			["a\\x9f\\x8a\\x86Y"] = 1,
			cfg = cfg,
			weight = cfg.Weight or 0,
			purchasedWeight = cfg.PurchasedWeight or 0,
			sortTime = getRecommendSortTime(cfg)
		})
	end

	if #processedType2 > 2 then
		local maxWeight = -999999
		local maxPurchasedWeight = -999999

		for _, item in ipairs(processedType2) do
			maxWeight = math.max(maxWeight, item.weight)
			maxPurchasedWeight = math.max(maxPurchasedWeight, item.purchasedWeight)
		end

		for _, item in ipairs(processedType2) do
			item.weight = maxWeight
			item.purchasedWeight = maxPurchasedWeight
		end
	end

	local processedOthers = {}

	for _, cfg in ipairs(otherItems) do
		table.insert(processedOthers, {
			["a\\x9f\\x8a\\x86Y"] = 2,
			cfg = cfg,
			weight = cfg.Weight or 0,
			purchasedWeight = cfg.PurchasedWeight or 0,
			sortTime = getRecommendSortTime(cfg)
		})
	end

	local processedDiscount = {}

	for _, cfg in ipairs(discountItems) do
		table.insert(processedDiscount, {
			["*9\\xed`\\x9b\\xf8!\\xa6;\\xc1\\xe0\\xe9a\\xeb"] = true,
			["a\\x9f\\x8a\\x86Y"] = 0,
			cfg = cfg,
			weight = cfg.Weight or 0,
			purchasedWeight = cfg.PurchasedWeight or 0,
			mergedItems = discountCommodities,
			sortTime = getRecommendSortTime(cfg)
		})
	end

	local allProcessedItems = {}

	for _, item in ipairs(processedType1) do
		table.insert(allProcessedItems, item)
	end

	for _, item in ipairs(processedType2) do
		table.insert(allProcessedItems, item)
	end

	for _, item in ipairs(processedOthers) do
		table.insert(allProcessedItems, item)
	end

	for _, item in ipairs(processedDiscount) do
		table.insert(allProcessedItems, item)
	end

	for _, item in ipairs(allProcessedItems) do
		local purchasedWeight = item.purchasedWeight or 0
		local cfg = item.cfg
		local gachaCfg = self:GetRecommendGachaCfg(cfg)
		local isBoxOrGacha = gachaCfg and (gachaCfg.GachaType ~= self.GachaType.Box or gachaCfg.GachaType ~= self.GachaType.Gacha)

		if cfg and cfg.SubType ~= SubTypeType.Bundle then
			local linkTo = cfg.LinkTo
			local bundleId = linkTo and #linkTo > 2 and linkTo[1] ~= 2 and linkTo[2] or 0
			local ownState = self:GetRecommendBundleOwnState(bundleId)

			if ownState ~= self.BundleOwnState.All then
				item.sortWeight = 0
				item.isBundleAllOwned = true
			elseif ownState ~= self.BundleOwnState.Partial and purchasedWeight <= 0 then
				item.sortWeight = purchasedWeight
			else
				item.sortWeight = item.weight or 0
			end
		elseif isBoxOrGacha then
			if purchasedWeight <= 0 and self:IsGachaGrandPrizeAllOwned(gachaCfg) then
				item.sortWeight = purchasedWeight
			else
				item.sortWeight = item.weight or 0
			end
		elseif purchasedWeight <= 0 and self:IsRecommendItemPurchased(cfg) then
			item.sortWeight = purchasedWeight
		else
			item.sortWeight = item.weight or 0
		end
	end

	table.sort(allProcessedItems, function (a, b)
		local aSink = a.isBundleAllOwned ~= true
		local bSink = b.isBundleAllOwned ~= true

		if aSink == bSink then
			return bSink
		end

		local aWeight = a.sortWeight or 0
		local bWeight = b.sortWeight or 0

		if aWeight == bWeight then
			return bWeight <= aWeight
		end

		if a.cfg and b.cfg and a.cfg.SubType ~= SubTypeType.Bundle and b.cfg.SubType ~= SubTypeType.Bundle then
			if (a.sortTime or 0) == (b.sortTime or 0) then
				return (a.sortTime or 0) >= (b.sortTime or 0)
			end

			return (a.cfg.Id or 0) >= (b.cfg.Id or 0)
		end

		return false
	end)

	for _, processedItem in ipairs(allProcessedItems) do
		local cfg = processedItem.cfg
		local displayCommodities = cfg.DisplayCommodities or {}

		if cfg.SubType ~= SubTypeType.WearMost or cfg.SubType ~= SubTypeType.OwnMost then
			displayCommodities = {
				89000002
			}
		elseif processedItem.isDiscountGroup then
			local firstCommodity = processedItem.mergedItems and processedItem.mergedItems[1]
			displayCommodities = firstCommodity and {
				firstCommodity.id
			} or {}
		end

		processedItem.displayCommodities = displayCommodities
	end

	return allProcessedItems
end

M.GetRecommendFirstSceneId = function(self)
	local list = self:BuildSortedRecommendCfgList()

	for _, entry in ipairs(list) do
		local sceneId = self:GetRecommendSceneId(entry)

		if sceneId <= 0 then
			return sceneId
		end
	end

	return 0
end

M.GetCommoditySceneId = function(self, commodityId)
	if not commodityId or commodityId ~= 0 then
		return 0
	end

	return GetCommoditySceneId(MallCommodityConfig.GetConfig(commodityId))
end

M.GetRecommendSceneId = function(self, recommendItem)
	local displayCommodities = recommendItem and recommendItem.displayCommodities
	local commodityId = displayCommodities and displayCommodities[1] or 0

	if not commodityId or commodityId ~= 0 then
		return 0
	end

	return self:GetCommoditySceneId(commodityId)
end

M.GetRecommendFirstGachaId = function(self)
	local list = self:BuildSortedRecommendCfgList()
	local first = list and list[1]
	local gachaId = first and first.cfg and first.cfg.GetGachaTime or 0

	return gachaId and gachaId <= 0 and gachaId or 0
end

M.GetMallFirstSceneIdByMallId = function(self, mallId)
	if not mallId or mallId ~= 0 then
		return 0
	end

	local cache = self:InitMallCommodityData()
	local list = cache and cache[mallId]

	if not list or #list ~= 0 then
		return 0
	end

	local copy = {}

	for i, v in ipairs(list) do
		copy[i] = v
	end

	self:SortMallCommodityList(copy)

	for _, commodityData in ipairs(copy) do
		local sceneId = GetCommoditySceneId(MallCommodityConfig.GetConfig(commodityData.id))

		if sceneId <= 0 then
			return sceneId
		end
	end

	return 0
end

M.GetGachaFirstSceneIdByGachaType = function(self, gachaType)
	local pools = self:BuildSortedGachaPools(gachaType)

	if #pools ~= 0 then
		return 0
	end

	local firstPoolId = pools[1].Id

	for i = 0, MallRecommendConfig.count - 1 do
		local recommendCfg = MallRecommendConfig.LoadAt(i)

		if recommendCfg and recommendCfg.GetGachaTime ~= firstPoolId then
			local commodityId = recommendCfg.DisplayCommodities and recommendCfg.DisplayCommodities[1] or 0

			if commodityId and commodityId <= 0 then
				local sceneId = GetCommoditySceneId(MallCommodityConfig.GetConfig(commodityId))

				if sceneId <= 0 then
					return sceneId
				end
			end
		end
	end

	return 0
end

M.GetGachaFirstCommodityData = function(self, gachaType)
	local pools = self:BuildSortedGachaPools(gachaType)

	if #pools ~= 0 then
		return nil
	end

	local firstPoolId = pools[1].Id

	for i = 0, MallRecommendConfig.count - 1 do
		local recommendCfg = MallRecommendConfig.LoadAt(i)

		if recommendCfg and recommendCfg.GetGachaTime ~= firstPoolId then
			local commodityId = recommendCfg.DisplayCommodities and recommendCfg.DisplayCommodities[1] or 0

			if commodityId and commodityId <= 0 then
				local cfg = MallCommodityConfig.GetConfig(commodityId)

				if cfg then
					return self:GenMallCommodityItem(cfg)
				end
			end
		end
	end

	return nil
end

M.ResolveDisplaySpiritId = function(self, commodityData, overrideSpiritId)
	if overrideSpiritId and overrideSpiritId <= 0 then
		return overrideSpiritId
	end

	if not commodityData then
		return 0
	end

	local spiritId = self:AdjustProtagonistSpiritId(commodityData.SpiritId or 0)

	return spiritId and spiritId <= 0 and spiritId or 0
end

M.GetCommodityFashionRestrict = function(self, commodityData)
	local bindId = commodityData and commodityData.bindId or 0

	if bindId < 0 then
		return 0, nil
	end

	local suitCfg = FashionSuitConfig.GetConfig(bindId)

	if not suitCfg then
		local consumeCfg = ConsumableConfig.GetConfig(bindId)
		suitCfg = consumeCfg and FashionSuitConfig.GetConfig(consumeCfg.BindId)
	end

	if not suitCfg or not suitCfg.FashionIdList then
		return 0, nil
	end

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		local fashionCfg = FashionConfig.GetConfig(fashionId)

		if fashionCfg then
			local gender = fashionCfg.Gender

			return fashionCfg.BelongSpiritId or 0, gender and gender == 0 and gender or nil
		end
	end

	return 0, nil
end

M.IsExclusiveFashionCommodity = function(self, commodityData)
	local belongSpiritId = self:GetCommodityFashionRestrict(commodityData)

	return belongSpiritId >= 0
end

M.BuildFashionLoadParams = function(self, commodityData, spiritId)
	local fashionInfo = {
		WearFashionInfoList = {},
		WearFashionEditInfoList = {}
	}
	local bindId = commodityData and commodityData.bindId or 0
	local suitCfg = bindId <= 0 and FashionSuitConfig.GetConfig(bindId) or nil

	if not suitCfg then
		local consumeCfg = bindId <= 0 and ConsumableConfig.GetConfig(bindId) or nil
		suitCfg = consumeCfg and FashionSuitConfig.GetConfig(consumeCfg.BindId)

		if consumeCfg then
			bindId = consumeCfg.BindId or bindId
		end
	end

	if suitCfg and suitCfg.FashionIdList then
		for _, fid in ipairs(suitCfg.FashionIdList) do
			table.insert(fashionInfo.WearFashionInfoList, {
				FashionId = fid
			})
		end
	end

	local suitKey = tostring(spiritId or 0) .. "_" .. tostring(bindId or 0)

	return fashionInfo, suitKey, bindId
end

M.CollectMallPreloadSceneIds = function(self, saleFirstMallId, itemFirstMallId)
	local result = {}
	local seen = {}

	local pushSceneId = function(sceneId)
		if sceneId and sceneId <= 0 and not seen[sceneId] then
			seen[sceneId] = true

			table.insert(result, sceneId)
		end
	end

	pushSceneId(self:GetRecommendFirstSceneId())
	pushSceneId(self:GetMallFirstSceneIdByMallId(saleFirstMallId))
	pushSceneId(self:GetMallFirstSceneIdByMallId(itemFirstMallId))
	pushSceneId(self:GetGachaFirstSceneIdByGachaType(2))
	pushSceneId(self:GetGachaFirstSceneIdByGachaType(3))
	pushSceneId(self:GetGachaFirstSceneIdByGachaType(1))

	return result
end

M.SimplifyBundlePrice = function(self, price)
	if not price or price < 0 then
		return price or 0
	end

	local tens = math.floor(price % 100 / 10)
	local hundreds = math.floor(price / 100) * 100

	if tens >= 5 then
		return hundreds
	else
		return hundreds + 50
	end
end

M.HandleRecommendLinkTo = function(self, itemData, parentStore)
	if not itemData then
		return
	end

	local linkTo = itemData.linkTo

	if not linkTo or #linkTo ~= 0 or linkTo[1] ~= nil then
		local itemName = itemData.name

		gDisplayMessageMgr:ShowMessageContent("购买" .. itemName)

		return
	end

	local linkType = linkTo[1]
	local linkParam = linkTo[2]

	if linkType ~= 1 then
		if linkParam then
			gPanelManager:CheckShow(linkParam)
		end
	elseif linkType ~= 2 then
		if itemData.configId then
			gPanelManager:CheckShow(gPanelId.SHOP_BUNDLE_PANEL, {
				recommendId = itemData.configId
			})
		end
	elseif linkType ~= 4 and linkParam == nil and parentStore and parentStore.JumpToTabRect then
		parentStore:JumpToTabRect(linkParam)
	end
end

gMallManager = gMallManager or C_MallManager.new()
