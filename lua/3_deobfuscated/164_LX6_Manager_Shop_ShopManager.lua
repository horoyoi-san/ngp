local ShopCommodityCfg = LTConfig.ShopCommodityConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local ShopConfig = LTConfig.ShopConfig
local NpcShopCommodityCfg = LTConfig.ShopCommodityConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local ShopCommodityGroupConfig = LTConfig.ShopCommodityGroupConfig
local MessageConfig = LTConfig.MessageConfig
local UXTime = LTUtils.UXTime
local bit = require("bit")
local ModuleShopCommodity = UX.Game.EventConditionImplModule.ShopCommodity
local ModuleShopCommodityShow = UX.Game.EventConditionImplModule.ShopCommodityShow
local CommodityType = LTConfig.ShopCommodityConfig.TypeType
local WeaponConfig = LTConfig.WeaponConfig
local FashionConfig = LTConfig.FashionConfig
local VehicleConfig = LTConfig.VehicleConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local NpcShopCommodityStatus = UX.Game.NpcShopCommodityStatus
local MallExchangeConfig = LTConfig.MallExchangeConfig
local ExternalSourceType = LX6.Audio.ExternalSourceType
C_ShopManager = DefClass("C_ShopManager", C_ShopManager)
local M = C_ShopManager

function M:ctor()
	self.BuyConfirmPage = {
		AskConfirm = 6,
		ShowSpecialBuyConfirm = 7,
		GivePlayerSelect = 5,
		AskPlayerSelect = 4,
		lingFragment = 1,
		GiveConfirm = 3,
		BuyConfirmNoText = 2
	}
	self.REFRESH_TIME = {
		WEEK = 2,
		DAY = 1
	}
	self.brandMap = {}

	function self.CommodityCmp(a, b)
		if a.SoldOut ~= b.SoldOut then
			return not a.SoldOut
		end

		if a.Unlocked ~= b.Unlocked then
			return a.Unlocked
		end

		if a.IsTask ~= b.IsTask then
			return a.IsTask
		end

		if a.DisplayWeight ~= b.DisplayWeight then
			return b.DisplayWeight < a.DisplayWeight
		end

		if a.Quality ~= b.Quality then
			return b.Quality < a.Quality
		end

		return a.SortOrder < b.SortOrder
	end

	function self.CommodityCmpByWeight(a, b)
		if a.DisplayWeight ~= b.DisplayWeight then
			return b.DisplayWeight < a.DisplayWeight
		end

		return a.SortOrder < b.SortOrder
	end

	self.SubType = {
		[3] = ConsumableConfig.packTab3SubType,
		[4] = ConsumableConfig.packTab4SubType,
		[5] = ConsumableConfig.packTab5SubType,
		[6] = ConsumableConfig.packTab6SubType
	}
	self.SubTypeNum = {
		{},
		{},
		{},
		{},
		{},
		{},
		{}
	}
	self.CornerMarkType = {
		"Resurrection",
		"HealingPotion",
		"AttackPotion",
		"DefensePotion"
	}
	self.CornerMarkTypeNum = {}
end

function M:OnInit()
	self:BuildBrandMap()
	self:InitSubTypeInfo()
end

function M:BuildBrandMap()
	self.brandMap = {}

	for i = 0, ShopBrandConfig.count - 1 do
		local brand = ShopBrandConfig.LoadAt(i)

		if brand then
			self.brandMap[brand.Id] = {}
		end
	end

	for i = 0, ShopCommodityCfg.count - 1 do
		local commodity = ShopCommodityCfg.LoadAt(i)

		if commodity and commodity.BelongBrand and self.brandMap[commodity.BelongBrand] then
			table.insert(self.brandMap[commodity.BelongBrand], commodity.Id)
		end
	end
end

function M:InitSubTypeInfo()
	for i = 3, 6 do
		local subTypes = self.SubType[i]

		for _, v in pairs(subTypes) do
			table.insert(self.SubTypeNum[i], ConsumableTypeConfig[v])
		end
	end

	for _, v in pairs(self.CornerMarkType) do
		table.insert(self.CornerMarkTypeNum, ConsumableTypeConfig[v])
	end
end

function M:GetShopCommodityInfo(shopId, callback)
	local shopCfg = ShopConfig.GetConfig(shopId)

	if not shopCfg then
		print_error("ShopConfig表里找不到对应的商店信息，商店id=", shopId, " 请找策划解决。")

		if callback then
			callback(false)
		end

		return
	end

	if shopCfg.CommodityGroupIdList and #shopCfg.CommodityGroupIdList > 0 then
		gClientToGameDelegate:AskNpcShopCommodityInfo(shopId).Callback = function (err, npcShopInfo)
			if err == MessageConfig.Ok then
				local idx = 1
				local groupDict = {}
				local moneyDict = {}

				for _, groupId in ipairs(shopCfg.CommodityGroupIdList) do
					local groupCfg = ShopCommodityGroupConfig.GetConfig(groupId)

					if groupCfg then
						groupDict[groupId] = {}

						for _, commodityId in ipairs(groupCfg.CommodityIDList) do
							local item = self:GenCommodityItem(commodityId, idx)

							if item then
								item.GroupId = groupId
								groupDict[groupId][commodityId] = item
								moneyDict[item.Money] = true
								idx = idx + 1
							end
						end
					end
				end

				local commodityInfoList = npcShopInfo.CommodityInfoList
				local groupList = {}

				for groupId, commodityList in pairs(groupDict) do
					groupList[groupId] = self:MergeSortDictToList(commodityList, commodityInfoList)
				end

				if callback then
					callback(true, groupList, groupDict, {
						CurrentDiscount = npcShopInfo.CurrentDiscount,
						NextDiscount = npcShopInfo.NextDiscount,
						Moneys = moneyDict
					})
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if callback then
					callback(false)
				end
			end
		end
	elseif shopCfg.SellBrands and #shopCfg.SellBrands > 0 then
		gClientToGameDelegate:AskNpcShopCommodityInfo(shopId).Callback = function (err, npcShopInfo)
			if err == MessageConfig.Ok then
				local idx = 1
				local brandDict = {}
				local moneyDict = {}

				for _, brandId in ipairs(shopCfg.SellBrands) do
					local list = self.brandMap[brandId]

					if list then
						brandDict[brandId] = {}

						for _, commodityId in ipairs(list) do
							local item = self:GenCommodityItem(commodityId, idx)

							if item then
								item.BrandId = brandId
								brandDict[brandId][commodityId] = item
								moneyDict[item.Money] = true
								idx = idx + 1
							end
						end
					end
				end

				local commodityInfoList = npcShopInfo.CommodityInfoList
				local brandList = {}

				for brandId, commodityList in pairs(brandDict) do
					brandList[brandId] = self:MergeSortDictToList(commodityList, commodityInfoList)
				end

				if callback then
					callback(true, brandList, brandDict, {
						CurrentDiscount = npcShopInfo.CurrentDiscount,
						NextDiscount = npcShopInfo.NextDiscount,
						Moneys = moneyDict
					})
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if callback then
					callback(false)
				end
			end
		end
	else
		print_error("商店id=", shopId, "配置错误,groupList 和 brandList 都为空, 取不到数据, 请找策划（zhouxingduan@corp.netease.com）解决!")

		if callback then
			callback(false)
		end
	end
end

function M:GetGroupCommodityInfo(shopId, callback)
	local shopCfg = ShopConfig.GetConfig(shopId)

	if not shopCfg then
		print_error("ShopConfig表里找不到对应的商店信息，商店id=", shopId, " 请找策划解决。")

		if callback then
			callback(false)
		end

		return
	end

	gClientToGameDelegate:AskNpcShopCommodityInfo(shopId).Callback = function (err, npcShopInfo)
		if err == MessageConfig.Ok then
			local idx = 1
			local groupDict = {}
			local moneyDict = {}

			for _, groupId in ipairs(shopCfg.CommodityGroupIdList) do
				local groupCfg = ShopCommodityGroupConfig.GetConfig(groupId)

				if groupCfg then
					groupDict[groupId] = {}

					for _, commodityId in ipairs(groupCfg.CommodityIDList) do
						local item = self:GenCommodityItem(commodityId, idx)

						if item then
							item.GroupId = groupId
							groupDict[groupId][commodityId] = item
							moneyDict[item.Money] = true
							idx = idx + 1
						end
					end
				end
			end

			local commodityInfoList = npcShopInfo.CommodityInfoList
			local groupList = {}

			for groupId, commodityList in pairs(groupDict) do
				groupList[groupId] = self:MergeSortDictToList(commodityList, commodityInfoList)
			end

			if callback then
				callback(true, groupList, groupDict, {
					CurrentDiscount = npcShopInfo.CurrentDiscount,
					NextDiscount = npcShopInfo.NextDiscount,
					Moneys = moneyDict
				})
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

function M:GetBrandCommodityInfo(shopId, callback)
	local shopCfg = ShopConfig.GetConfig(shopId)

	if not shopCfg then
		print_error("NpcShopConfig表里找不到对应的商店信息，商店id=", shopId, " 请找策划解决。")

		if callback then
			callback(false)
		end

		return
	end

	gClientToGameDelegate:AskNpcShopCommodityInfo(shopId).Callback = function (err, npcShopInfo)
		if err == MessageConfig.Ok then
			local idx = 1
			local brandDict = {}
			local moneyDict = {}

			for _, brandId in ipairs(shopCfg.SellBrands) do
				local list = self.brandMap[brandId]

				if list then
					brandDict[brandId] = {}

					for _, commodityId in ipairs(list) do
						local item = self:GenCommodityItem(commodityId, idx)

						if item then
							item.BrandId = brandId
							brandDict[brandId][commodityId] = item
							moneyDict[item.Money] = true
							idx = idx + 1
						end
					end
				end
			end

			local commodityInfoList = npcShopInfo.CommodityInfoList
			local brandList = {}

			for groupId, commodityList in pairs(brandDict) do
				brandList[groupId] = self:MergeSortDictToList(commodityList, commodityInfoList)
			end

			if callback then
				callback(true, brandList, brandDict, {
					CurrentDiscount = npcShopInfo.CurrentDiscount,
					NextDiscount = npcShopInfo.NextDiscount,
					Moneys = moneyDict
				})
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

function M:GetShopCommodityInfoMap(shopId, callback)
	local shopCfg = ShopConfig.GetConfig(shopId)

	if not shopCfg then
		print_error("ShopConfig表里找不到对应的商店信息，商店id=", shopId, " 请找策划解决。")

		if callback then
			callback(false)
		end

		return
	end

	if shopCfg.CommodityGroupIdList and #shopCfg.CommodityGroupIdList > 0 then
		gClientToGameDelegate:AskNpcShopCommodityInfo(shopId).Callback = function (err, npcShopInfo)
			if err == MessageConfig.Ok then
				local idx = 1
				local groupDict = {}
				local moneyDict = {}

				for _, groupId in ipairs(shopCfg.CommodityGroupIdList) do
					local groupCfg = ShopCommodityGroupConfig.GetConfig(groupId)

					if groupCfg then
						groupDict[groupId] = {}

						for _, commodityId in ipairs(groupCfg.CommodityIDList) do
							local item = self:GenCommodityItem(commodityId, idx, true)

							if item then
								item.GroupId = groupId
								groupDict[groupId][commodityId] = item
								moneyDict[item.Money] = true
								idx = idx + 1
							end
						end
					end
				end

				local commodityInfoList = npcShopInfo.CommodityInfoList
				local groupList = {}

				for groupId, commodityList in pairs(groupDict) do
					groupList[groupId] = self:MergeSortDictToList(commodityList, commodityInfoList)
				end

				if callback then
					callback(true, groupList, groupDict, {
						CurrentDiscount = npcShopInfo.CurrentDiscount,
						NextDiscount = npcShopInfo.NextDiscount,
						Moneys = moneyDict
					})
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if callback then
					callback(false)
				end
			end
		end
	elseif shopCfg.SellBrands and #shopCfg.SellBrands > 0 then
		gClientToGameDelegate:AskNpcShopCommodityInfo(shopId).Callback = function (err, npcShopInfo)
			if err == MessageConfig.Ok then
				local idx = 1
				local brandDict = {}
				local moneyDict = {}

				for _, brandId in ipairs(shopCfg.SellBrands) do
					local list = self.brandMap[brandId]

					if list then
						brandDict[brandId] = {}

						for _, commodityId in ipairs(list) do
							local item = self:GenCommodityItem(commodityId, idx, true)

							if item then
								item.BrandId = brandId
								brandDict[brandId][commodityId] = item
								moneyDict[item.Money] = true
								idx = idx + 1
							end
						end
					end
				end

				local commodityInfoList = npcShopInfo.CommodityInfoList
				local brandList = {}

				for brandId, commodityList in pairs(brandDict) do
					brandList[brandId] = self:MergeSortDictToList(commodityList, commodityInfoList)
				end

				if callback then
					callback(true, brandList, brandDict, {
						CurrentDiscount = npcShopInfo.CurrentDiscount,
						NextDiscount = npcShopInfo.NextDiscount,
						Moneys = moneyDict
					})
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if callback then
					callback(false)
				end
			end
		end
	else
		print_error("商店id=", shopId, "配置错误,groupList 和 brandList 都为空, 取不到数据, 请找策划（zhouxingduan@corp.netease.com）解决!")

		if callback then
			callback(false)
		end
	end
end

function M:GenCommodityItem(commodityId, index, tmpIsMap)
	local commodityCfg = NpcShopCommodityCfg.GetConfig(commodityId)

	if not commodityCfg then
		print_error("NpcShopCommodityCfg找不到配置，commodityId=", commodityId, " 请找策划解决!")

		return
	end

	local show = gEventConditionUtils.CheckHasUnlocked(commodityCfg, ModuleShopCommodityShow, "ShowMaxProgress")

	if not show then
		return nil
	end

	local item = {
		UnlockDesc = commodityCfg.UnlockConditionsDes,
		Type = commodityCfg.Type
	}
	local cfg = nil

	if item.Type == CommodityType.Consumable then
		cfg = ConsumableConfig.GetConfig(commodityCfg.BindId)

		if not cfg then
			print_error("商店取不到商品数据,Type = Consumable, BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
		end

		item.Name = cfg and cfg.Name or ""
		item.Description = cfg and cfg.Description or ""
		item.Story = ""
		item.IconId = cfg and cfg.SItemIconId or 0
		item.Quality = cfg and cfg.Quality or 0
	elseif item.Type == CommodityType.Weapon then
		cfg = WeaponConfig.GetConfig(commodityCfg.BindId)

		if not cfg then
			print_error("商店取不到商品数据,Type = Weapon, BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
		end

		item.Name = cfg and cfg.Name or ""
		item.Description = cfg and cfg.WeaponBuffDescription or ""
		item.Story = ""
		item.IconId = cfg and cfg.WeaponConsumableIcon or 0
		item.Quality = cfg and cfg.Quality or 0
	elseif item.Type == CommodityType.Fashion then
		cfg = FashionConfig.GetConfig(commodityCfg.BindId)

		if not cfg then
			print_error("商店取不到商品数据,Type = Fashion, BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
		end

		item.Name = cfg and cfg.Name or ""
		item.Description = cfg and cfg.Description or ""
		item.Story = ""
		item.IconId = cfg and cfg.FashionConsumableIcon or 0
		item.Quality = cfg and cfg.Quality or 0
	elseif item.Type == CommodityType.Vehicle then
		cfg = VehicleConfig.GetConfig(commodityCfg.BindId)

		if not cfg then
			print_error("商店取不到商品数据,Type = Vehicle, BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
		end

		item.Name = cfg and cfg.VehicleName or ""
		item.Description = cfg and cfg.VehicleIntro or ""
		item.Story = ""

		if tmpIsMap then
			item.IconId = cfg and cfg.SVehicleIconId or 0
		else
			item.IconId = cfg and cfg.SVehicleFrontIconId or 0
		end

		item.Quality = cfg and cfg.VehicleQuality or 0
	elseif item.Type == CommodityType.FashionSuit then
		cfg = FashionSuitConfig.GetConfig(commodityCfg.BindId)

		if not cfg then
			print_error("商店取不到商品数据,Type = FashionSuit, BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
		end

		local fashionId = cfg and cfg.FashionIdList and cfg.FashionIdList[1] or 0
		local fashionCfg = FashionConfig.GetConfig(fashionId)

		if not fashionCfg then
			print_error("时装套装取不到时装数据,Type = FashionSuit, BindId = ", commodityCfg.BindId, "fashionId = ", fashionId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
		end

		item.Name = cfg and cfg.Name or ""
		item.Description = cfg and cfg.Description or ""
		item.Story = ""
		item.IconId = cfg and cfg.SuitConsumableIcon or 0
		item.Quality = fashionCfg and fashionCfg.Quality or 0
	end

	item.Cfg = cfg
	item.ShowNum = item.Type == CommodityType.Consumable and commodityCfg.IsShowItemNum
	item.CommodityId = commodityId
	item.ConsumableID = commodityCfg.ConsumableID
	item.BindId = commodityCfg.BindId
	item.PriceOriginal = commodityCfg.Price
	item.PriceCurrent = commodityCfg.Price
	item.PriceCurrentWithLabel = ""
	item.LimitNum = commodityCfg.LimitNum
	item.RemainNum = commodityCfg.LimitNum
	item.RemainByLimit = ""
	item.LimitOnceNum = commodityCfg.LimitOnceNum < 0 and ShopConfig.BuyLimitOnceMaxNum or math.min(commodityCfg.LimitOnceNum, ShopConfig.BuyLimitOnceMaxNum)
	item.SoldOut = false
	item.Unlocked = false
	item.State = 2
	item.ShowCount = false
	item.NoLimit = commodityCfg.LimitNum == -1
	item.SortOrder = index
	item.DisplayWeight = commodityCfg.DisplayWeight
	local moneyCfg = ConsumableConfig.GetConfig(commodityCfg.ConsumeConsumableId)
	item.MoneyIconId = moneyCfg.SMoneyIconId
	item.Money = commodityCfg.ConsumeConsumableId
	item.MoneyName = moneyCfg.Name
	item.Discount = 100
	item.HasDiscount = false
	item.DiscountDesc = "100%"
	item.Status = 0
	item.RedDot = false
	item.RefreshTime = 0
	item.IsTask = false
	item.TaskIconId = 0

	return item
end

function M:MergeSortDictToList(commodityDict, serverInfos)
	self:UpdateCommodityInfo(commodityDict, serverInfos)

	local commodityList = {}

	for _, cInfo in pairs(commodityDict) do
		table.insert(commodityList, cInfo)
	end

	table.sort(commodityList, self.CommodityCmp)

	return commodityList
end

function M:SortCommodityList(list)
	table.sort(list, self.CommodityCmp)
end

function M:SortCommodityListByWeight(list)
	table.sort(list, self.CommodityCmpByWeight)
end

function M:FormatLeftTime(refreshTime, nowTime)
	if not refreshTime then
		return nil, false
	end

	local now = nowTime or UXTime.GetNowUnixTime()
	local remainSecond = refreshTime - now

	if remainSecond <= 0 then
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901019).Text, 0, 0), true
	elseif remainSecond < 3600 then
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900064).Text, math.floor(remainSecond / 60), math.floor(remainSecond % 60)), true
	elseif remainSecond < 86400 then
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901019).Text, math.floor(remainSecond / 3600), math.floor(remainSecond / 60 % 60)), true
	else
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901020).Text, math.floor(remainSecond / 86400), math.floor(remainSecond / 3600 % 24)), false
	end
end

function M:ItemIsTask(id)
	local tasks = NpcShopCommodityCfg.GetConfig(id).TaskIcon

	if not tasks or #tasks == 0 then
		return false, nil
	end

	for i, taskId in ipairs(tasks) do
		if gTaskManager:IsCurrentTask(taskId) then
			local cfg = gTaskManager:GetTaskConfigInfo(taskId)

			return true, gTaskManager.TaskSIconId[cfg.Title]
		end
	end

	return false, nil
end

function M:GetExchangeRate(FromMoneyType, ToMoneyType)
	local FromMoneyId = gUIUtils:GetMoneyTypeId(FromMoneyType)
	local ToMoneyId = gUIUtils:GetMoneyTypeId(ToMoneyType)

	for i = 0, MallExchangeConfig.count - 1 do
		local cfg = MallExchangeConfig.LoadAt(i)

		if cfg.FromMoney == FromMoneyType and cfg.ToMoney == ToMoneyType or cfg.FromMoney == FromMoneyId and cfg.ToMoney == ToMoneyId then
			return cfg.Rate
		end
	end

	print_error("找不到moneyType:" .. FromMoneyType .. "到" .. ToMoneyType .. "的兑换比例，请敲liuyf检查传入类型和MallExchangeConfig表")

	return 0
end

function M:UpdateCommodityInfo(commodityDict, serverInfos)
	for _, sInfo in ipairs(serverInfos) do
		local cInfo = commodityDict[sInfo.TemplateId]

		if cInfo then
			cInfo.RemainNum = sInfo.Count
			cInfo.RefreshTime = sInfo.RefreshTime
			cInfo.SoldOut = cInfo.RemainNum == 0 and not cInfo.NoLimit
			cInfo.RemainByLimit = gString.Format("%d/%d", cInfo.RemainNum, cInfo.LimitNum)
			cInfo.Discount = sInfo.Discount
			cInfo.HasDiscount = cInfo.Discount ~= 100

			if cInfo.Discount < 100 then
				cInfo.DiscountDesc = "-" .. 100 - cInfo.Discount .. "%"
			elseif cInfo.Discount > 100 then
				cInfo.DiscountDesc = "+" .. cInfo.Discount - 100 .. "%"
			end

			cInfo.PriceCurrent = sInfo.DiscountPrice
			cInfo.Status = sInfo.Status
			cInfo.Unlocked = bit.band(cInfo.Status, NpcShopCommodityStatus.Locked) == 0
			cInfo.RedDot = bit.band(cInfo.Status, NpcShopCommodityStatus.Readable) ~= 0 and cInfo.Unlocked
			cInfo.PriceCurrentWithLabel = "x" .. tostring(cInfo.PriceCurrent)

			if cInfo.SoldOut then
				cInfo.IsTask = false
			else
				cInfo.IsTask, cInfo.TaskIconId = self:ItemIsTask(sInfo.TemplateId)
			end

			cInfo.State = 0
			cInfo.ShowCount = true

			if cInfo.SoldOut then
				cInfo.State = 1
				cInfo.ShowCount = false
			elseif not cInfo.Unlocked then
				cInfo.State = 2
				cInfo.ShowCount = false
			end

			if not cInfo.NoLimit and cInfo.RemainNum == 1 then
				cInfo.ShowCount = false
			end

			if cInfo.LimitOnceNum == 1 then
				cInfo.ShowCount = false
			end
		end
	end
end

function M:SetShopIdEnterTime(shopId)
	if self.shopIdEnterId == nil then
		self.shopIdEnterId = {}
	end

	self.shopIdEnterId[shopId] = UXTime.GetNowUnixTime()
end

function M:NpcShopExitTime(shopid)
	if self.shopIdEnterId[shopid] then
		local time = UXTime.GetNowUnixTime() - self.shopIdEnterId[shopid]
		self.shopIdEnterId[shopid] = nil

		gClientToGameDelegate:AskPanelBrowsingTime(gPanelId.S_NPC_SHOP_PANEL, shopid, time)
	end
end

function M:PlayVoice(externalVoiceId)
	self:StopVoice()

	if externalVoiceId and externalVoiceId ~= 0 then
		self.currentVoiceNid = gSoundMgr:PlaySoundByExternalSourceId(externalVoiceId, ExternalSourceType.Voice, nil, function (uuid, soundData)
			if uuid <= 0 then
				self:EndVoiceCb()
			end
		end, nil, function (uuid, soundData)
			self:EndVoiceCb()
		end)
	end
end

function M:EndVoiceCb()
	self.currentVoiceNid = nil
end

function M:StopVoice()
	if self.currentVoiceNid and self.currentVoiceNid ~= 0 then
		gSoundMgr:StopSoundByNid(self.currentVoiceNid)

		self.currentVoiceNid = nil
	end
end

gShopManager = gShopManager or C_ShopManager.new()
