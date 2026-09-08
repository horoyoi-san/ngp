-- Original chunk: @Lua\LuaFiles\LX6\Manager\GachaManager.lua
-- Decompiled from: 00698_GachaManager.lua_94a79b5a8a64.luajit

local FightSpiritConfig = LTConfig.FightSpiritConfig
local StoneConfig = LTConfig.StoneConfig
local GachaConfig = LTConfig.GachaConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local MessageConfig = LTConfig.MessageConfig
local GachaPoolConfig = LTConfig.GachaPoolConfig
local GachaPoolContentConfig = LTConfig.GachaPoolContentConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local FashionConfig = LTConfig.FashionConfig
local CommonItemConfig = LTConfig.CommonItemConfig
local DropConfig = LTConfig.DropConfig
local StaticProps = {
	ItemType = {
		["~\\x9a\\x8d\\x81\\x93"] = 1,
		["I_\\x8b_x\\x8d\\xc1wCHWx"] = 0
	}
}
local NORMAL_BG_VIDEO_ID = 24104359
C_GachaManager = DefClass("C_GachaManager", C_GachaManager, nil, StaticProps)
local M = C_GachaManager
M.EventHandler = {
	[gEventConstants.GACHA_VIDEO_STOP] = function (eventId, settleImmediately)
		if not gGachaManager.isGachaing then
			print_error("抽卡结果为空")

			return
		end

		if not gGachaManager.isDeca then
			gPanelManager:CheckShow(gPanelId.GACHA_SETTLE_ONCE, {
				result = gGachaManager.gachaResult[1],
				clickCB = function ()
					gGachaManager:OnSettleEnd()
				end
			})
		else
			gGachaManager:DecaSettle(settleImmediately)
		end
	end
}

M.ctor = function(self)
	for event, func in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(event, func)
	end

	self.configDataTypeList = {
		FightSpiritConfig,
		StoneConfig
	}
	self.poolCfg = nil
	self.currentDrawGachaId = nil
	self.suppressChargeReward = false
end

M.IsSuppressingChargeReward = function(self)
	return self.suppressChargeReward ~= true
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType and self.isGachaing then
		self:OnSettleEnd()
	end
end

M.OnAskGachaSuccess = function(self, count, result, rewards, itemMap)
	if self.isGachaing then
		self:OnSettleEnd()
	end

	self.isGachaing = true
	self.isDeca = count ~= 10
	self.itemMap = itemMap
	self.gachaCount = #result
	self.gachaResult = {}
	self.totalRewards = {}
	local totalRewardsMap = {}

	for i = 1, self.gachaCount do
		local oneGacha = {
			["*9\\xf1c\\xab\\xe7=\\xba&\\xf2\\xd6\\xf4{\\xeb"] = false,
			id = result[i].TemplateId,
			uid = result[i].InstanceId,
			isNew = itemMap[result[i].TemplateId] ~= nil
		}
		itemMap[result[i].TemplateId] = true
		local spriteCfg, _ = self:GetGachaResultCfg(result[i].TemplateId)

		if rewards[i] then
			local popupParam = gItemUtils:ConvertRewardDetail(rewards[i])
			oneGacha.rewards = popupParam.Rewards

			for j = 1, #popupParam.Rewards do
				local r = popupParam.Rewards[j]

				if not totalRewardsMap[r.ItemId] then
					totalRewardsMap[r.ItemId] = {
						ItemId = r.ItemId,
						Count = r.Count,
						Icon = r.Icon,
						Quality = r.Quality
					}
				else
					totalRewardsMap[r.ItemId].Count = totalRewardsMap[r.ItemId].Count + r.Count
				end
			end
		end

		self.gachaResult[i] = oneGacha
	end

	for _, v in pairs(totalRewardsMap) do
		table.insert(self.totalRewards, v)
	end

	gDropManager:AddToNextFrameList({
		Rewards = self.gachaResult
	}, C_DropManager.DEFAULT_SHOW_TYPE)
	gDropManager:AddToNextFrameList({
		Rewards = self.totalRewards
	}, C_DropManager.DEFAULT_SHOW_TYPE)
end

M.OnSettleEnd = function(self)
	self.isGachaing = false
	self.isDeca = nil
	self.gachaResult = nil
	self.gachaCount = nil
	self.currentGachaIndex = nil
	self.totalRewards = nil
	self.itemMap = {}
end

M.OnDecaSettleClose = function(self)
	if self.isGachaing then
		local data = self.totalRewards

		FrameTimer.New(function ()
			gDropManager:ShowRewardWindow({
				["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
				Rewards = data
			})
		end, 3):Start()
		self:OnSettleEnd()
	end
end

M.ShowGachaResult = function(self, drawDetails, isGrandPrizeWithAllFillers)
	if not drawDetails or #drawDetails ~= 0 then
		print_error("ShowGachaResult: drawDetails is nil or empty")

		return
	end

	if not self.currentDrawGachaId then
		print_error("ShowGachaResult: currentDrawGachaId is nil")

		return
	end

	local gachaCfg = GachaConfig.GetConfig(self.currentDrawGachaId)
	local gachaType = gachaCfg.GachaType

	if not gachaType then
		print_error("ShowGachaResult: gachaType is nil, gachaId=", self.currentDrawGachaId)

		return
	end

	if gachaType ~= 1 then
		self:ShowClosetGachaResult(drawDetails, isGrandPrizeWithAllFillers)
	elseif gachaType ~= 2 or gachaType ~= 3 then
		self:ShowBoxGachaResult(drawDetails, gachaType)
	else
		print_error("ShowGachaResult: unknown gachaType", gachaType)
	end
end

M.PlayGrandPrizeExtraVideo = function(self, hasGrandPrize, grandPrizeContentId, onFinish)
	if not hasGrandPrize then
		onFinish()

		return
	end

	local prizeVideoId = 0
	local contentCfg = grandPrizeContentId and GachaPoolContentConfig.GetConfig(grandPrizeContentId)

	if contentCfg then
		prizeVideoId = contentCfg.PrizeVideo or 0
	end

	if not prizeVideoId or prizeVideoId ~= 0 then
		print_warn("PlayGrandPrizeExtraVideo: PrizeVideo 配置缺失, contentId=", grandPrizeContentId)
		onFinish()

		return
	end

	FrameTimer.New(function ()
		local extraSkipped = false

		gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
			["*'-\\xe1w\\x91\\xf6 \\xad\n\\xfe\\xfb\\xf2W\\xf9"] = true,
			["[\\xbd\\x81\\x8cQ"] = false,
			videoId = prizeVideoId,
			exitCb = function ()
				if extraSkipped then
					return
				end

				onFinish()
			end,
			skipCb = function ()
				extraSkipped = true

				onFinish()
			end
		})
	end, 1):Start()
end

M.ShowClosetGachaResult = function(self, drawDetails, isGrandPrizeWithAllFillers)
	local rewardItems = self:ParseGachaDrawDetails(drawDetails)
	local hasGrandPrize = false
	local grandPrizeContentId = nil

	for i = 1, #drawDetails do
		if drawDetails[i].IsGrandPrize then
			hasGrandPrize = true
			grandPrizeContentId = drawDetails[i].PoolContentId

			break
		end
	end

	local gachaCfg = GachaConfig.GetConfig(self.currentDrawGachaId)

	if rewardItems[1] then
		gPanelManager:CheckShow(gPanelId.GACHA_RESULT, {
			["\\xe9\\xc91%\\xf5"] = true,
			rewardItems = rewardItems
		})
	end

	local onDone = function()
		self:PlayGrandPrizeExtraVideo(hasGrandPrize, grandPrizeContentId, function ()
			gPanelManager:CheckShow(gPanelId.GACHA_RESULT, {
				["DFoaO*="] = 1,
				rewardItems = rewardItems
			})
		end)
	end

	local isSingle = #drawDetails ~= 1
	local timelineName = gachaCfg and (isSingle and gachaCfg.SingleTimeline or gachaCfg.tenxTimeline)

	if timelineName and timelineName == "" then
		gDropManager.rewardWindowDisable = true
		local tlData = gTimelineManager:Timeline_CreateTimelineData()
		tlData.supportStreamingActor = false
		tlData.supportStreamingAnim = false
		tlData.supportStreamingEffect = false
		tlData.specialTagGroups = {
			"~\\xbf<\\xf2k\r\\xa4{-\"8&~\\xb3\\xca<\\xc9\\xe2"
		}
		tlData.specialTags = {
			self:GetTimelineColorTag(rewardItems)
		}

		tlData.onLoadDoneCallback = function()
			gPanelManager:SetActiveById(gPanelId.SHOP_HOME_PAGE, false)
			gBlackScreenManager:OpenBlackInstantly(gPanelId.SHOP_HOME_PAGE)
		end

		tlData.onFinishCallback = function()
			gDropManager.rewardWindowDisable = false

			gPanelManager:SetActiveById(gPanelId.SHOP_HOME_PAGE, true)
			gBlackScreenManager:ClearTransition(gPanelId.SHOP_HOME_PAGE)
			onDone()
		end

		gTimelineManager:Timeline_LoadAndPlay(timelineName, tlData)
	else
		local videoId = hasGrandPrize and gachaCfg.DrawVideo[2] or gachaCfg.DrawVideo[1]
		local hasSkipped = false
		gCS.CameraDataMgr.Instance.MainCameraEnabled = false

		gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
			["*'-\\xe1w\\x91\\xf6 \\xad\n\\xfe\\xfb\\xf2W\\xf9"] = true,
			["[\\xbd\\x81\\x8cQ"] = false,
			videoId = videoId,
			exitCb = function ()
				if hasSkipped then
					return
				end

				onDone()

				gCS.CameraDataMgr.Instance.MainCameraEnabled = true
			end,
			skipCb = function ()
				hasSkipped = true

				onDone()

				gCS.CameraDataMgr.Instance.MainCameraEnabled = true
			end
		})
	end
end

M.ShowBoxGachaResult = function(self, drawDetails, gachaType)
	local rewardItems = self:ParseGachaDrawDetails(drawDetails)
	local hasGrandPrize = false
	local grandPrizeContentId = nil

	for i = 1, #drawDetails do
		if drawDetails[i].IsGrandPrize then
			hasGrandPrize = true
			grandPrizeContentId = drawDetails[i].PoolContentId

			break
		end
	end

	local gachaCfg = GachaConfig.GetConfig(self.currentDrawGachaId)

	if rewardItems[1] then
		gPanelManager:CheckShow(gPanelId.GACHA_RESULT, {
			["\\xe9\\xc91%\\xf5"] = true,
			rewardItems = rewardItems
		})
	end

	local onDone = function()
		self:PlayGrandPrizeExtraVideo(hasGrandPrize, grandPrizeContentId, function ()
			gPanelManager:CheckShow(gPanelId.GACHA_RESULT, {
				rewardItems = rewardItems,
				gachaType = gachaType
			})
		end)
	end

	local isSingle = #drawDetails ~= 1
	local timelineName = gachaCfg and (isSingle and gachaCfg.SingleTimeline or gachaCfg.tenxTimeline)

	if timelineName and timelineName == "" then
		gDropManager.rewardWindowDisable = true
		local tlData = gTimelineManager:Timeline_CreateTimelineData()
		tlData.supportStreamingActor = false
		tlData.supportStreamingAnim = false
		tlData.supportStreamingEffect = false
		tlData.specialTagGroups = {
			"~\\xbf<\\xf2k\r\\xa4{-\"8&~\\xb3\\xca<\\xc9\\xe2"
		}
		tlData.specialTags = {
			self:GetTimelineColorTag(rewardItems)
		}

		tlData.onLoadDoneCallback = function()
			gPanelManager:SetActiveById(gPanelId.SHOP_HOME_PAGE, false)
			gBlackScreenManager:OpenBlackInstantly(gPanelId.SHOP_HOME_PAGE)
		end

		tlData.onFinishCallback = function()
			gDropManager.rewardWindowDisable = false

			gBlackScreenManager:ClearTransition(gPanelId.SHOP_HOME_PAGE)
			gPanelManager:SetActiveById(gPanelId.SHOP_HOME_PAGE, true)
			onDone()
		end

		gTimelineManager:Timeline_LoadAndPlay(timelineName, tlData)
	else
		local videoId = hasGrandPrize and gachaCfg.DrawVideo[2] or gachaCfg.DrawVideo[1]
		local hasSkipped = false
		gCS.CameraDataMgr.Instance.MainCameraEnabled = false

		gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
			["*'-\\xe1w\\x91\\xf6 \\xad\n\\xfe\\xfb\\xf2W\\xf9"] = true,
			["[\\xbd\\x81\\x8cQ"] = false,
			videoId = videoId,
			exitCb = function ()
				if hasSkipped then
					return
				end

				onDone()

				gCS.CameraDataMgr.Instance.MainCameraEnabled = true
			end,
			skipCb = function ()
				hasSkipped = true

				onDone()

				gCS.CameraDataMgr.Instance.MainCameraEnabled = true
			end
		})
	end
end

M.DecaSettle = function(self, showDecaSettle)
	if showDecaSettle then
		gPanelManager:CheckShow(gPanelId.GACHA_SETTLE_DECA, {
			["\\xb8\\xb9\n\\xbcK0\\xf7>"] = true,
			result = self.gachaResult,
			closeCB = function ()
				self:OnDecaSettleClose()
			end
		})

		return
	end

	self.currentGachaIndex = (self.currentGachaIndex or 0) + 1

	if self.gachaCount >= self.currentGachaIndex then
		gPanelManager:CheckShow(gPanelId.GACHA_SETTLE_DECA, {
			["\\xb8\\xb9\n\\xbcK0\\xf7>"] = true,
			result = self.gachaResult,
			closeCB = function ()
				self:OnDecaSettleClose()
			end
		})
	else
		gPanelManager:CheckShow(gPanelId.GACHA_SETTLE_ONCE, {
			["\\xb8\\xb9\n\\xbc@+\\xf3#"] = true,
			result = self.gachaResult[self.currentGachaIndex],
			clickCB = self.JumpToNext,
			jumpCB = function ()
				gGachaManager:DecaSettle(true)
			end
		})
	end
end

M.JumpToNext = function()
	gGachaManager:DecaSettle()
end

M.GetGachaResultCfg = function(self, id)
	local configType, cfg = nil

	for i = 1, #self.configDataTypeList do
		configType = self.configDataTypeList[i]
		cfg = configType.GetConfig(id)

		if cfg then
			return cfg, configType
		end
	end
end

M.GetTimelineColorTag = function(self, rewardItems)
	if not rewardItems or #rewardItems ~= 0 then
		return "blue"
	end

	local quality = rewardItems[1].Quality or 0

	if quality > 6 then
		return "red"
	elseif quality > 5 then
		return "gold"
	elseif quality > 4 then
		return "purple"
	elseif quality > 3 then
		return "blue"
	else
		return "green"
	end
end

M.SortGachaResultByQuality = function(self, resultList)
	if not resultList or #resultList < 1 then
		return
	end

	local indexedList = {}

	for i = 1, #resultList do
		table.insert(indexedList, {
			index = i,
			item = resultList[i],
			quality = resultList[i].Quality or 0,
			poolTierRarity = resultList[i].PoolTierRarity or 0,
			isNew = resultList[i].IsNew ~= true
		})
	end

	table.sort(indexedList, function (a, b)
		if a.quality == b.quality then
			return b.quality <= a.quality
		end

		if a.poolTierRarity == b.poolTierRarity then
			return b.poolTierRarity <= a.poolTierRarity
		end

		if a.isNew == b.isNew then
			return a.isNew
		end

		return a.index <= b.index
	end)

	for i = 1, #indexedList do
		resultList[i] = indexedList[i].item
	end
end

M.CheckItemOwned = function(self, itemId)
	if not itemId then
		return false
	end

	local itemCfg = ConsumableConfig.GetConfig(itemId)

	if not itemCfg then
		return false
	end

	local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
	local targetId = itemCfg.BindId and itemCfg.BindId <= 0 and itemCfg.BindId or itemId

	if itemCfg.SubType ~= ConsumableTypeConfig.Fashion then
		local fashionCfg = FashionConfig.GetConfig(targetId)

		if fashionCfg then
			return gDressManager:IsFashionHad(targetId)
		else
			return gMallManager:CheckFashionSuitOwned(targetId)
		end
	elseif itemCfg.SubType ~= ConsumableTypeConfig.Vehicle then
		return gMallManager:CheckVehicleOwned(targetId)
	else
		return gMallManager:CheckConsumableOwned(itemId)
	end
end

M.ParseGachaDrawDetails = function(self, drawDetails)
	local rewardItems = {}

	if not drawDetails or #drawDetails ~= 0 then
		return rewardItems
	end

	local GachaPoolContentConfig = LTConfig.GachaPoolContentConfig

	for i, detail in ipairs(drawDetails) do
		local contentId = detail.PoolContentId
		local contentCfg = GachaPoolContentConfig.GetConfig(contentId)

		if contentCfg then
			local name = contentCfg.name
			local drawresultimage = contentCfg.drawresultimage
			local drawresultimageList = nil

			if type(drawresultimage) == "number" then
				drawresultimageList = drawresultimage
				drawresultimage = drawresultimage and drawresultimage[1] or 0
			else
				drawresultimage = drawresultimage or 0
			end

			local baseimage = contentCfg.baseimage
			local duplicateReturnDropId = contentCfg.duplicateReturnDropId
			local duplicateReturnCount = contentCfg.duplicateReturnCount
			local belongBrand = contentCfg.BelongBrand or 0
			local itemId = nil
			local dropId = contentCfg.dropId

			if dropId and dropId <= 0 then
				local itemList, randomList = gCommonItemManager:ConvertDropToFakeItem(dropId, 1)

				if itemList and #itemList <= 0 and itemList[1] and itemList[1].Id then
					itemId = itemList[1].Id
				end
			end

			local rewardItem = {
				ItemId = itemId,
				Count = contentCfg.Quantity or 1,
				Icon = contentCfg.icondisplayimage or 0,
				Quality = contentCfg.Quality or 0,
				IsNew = detail.IsNew or false,
				IsGrandPrize = detail.IsGrandPrize or false,
				IsConverted = detail.IsConverted or false,
				ContentName = name,
				DrawResultImage = drawresultimage,
				DrawResultImageList = drawresultimageList,
				BaseImage = baseimage,
				DuplicateReturnDropId = duplicateReturnDropId,
				DuplicateReturnCount = duplicateReturnCount,
				BelongBrand = belongBrand,
				PoolTierRarity = contentCfg.PoolTierRarity or 0,
				BgVideo = detail.IsGrandPrize and contentCfg.PrizeVideo and contentCfg.PrizeVideo <= 0 and contentCfg.PrizeVideo or NORMAL_BG_VIDEO_ID
			}

			table.insert(rewardItems, rewardItem)
		else
			print_error("GachaPoolContentConfig not found for id:", contentId)
		end
	end

	if #rewardItems <= 1 then
		self:SortGachaResultByQuality(rewardItems)
	end

	return rewardItems
end

M.GetGachaPoolContentName = function(self, content)
	if not content then
		return ""
	end

	if content.dropId and content.dropId <= 0 then
		local itemList = gCommonItemManager:ConvertDropToFakeItem(content.dropId, 1)

		if itemList and #itemList <= 0 then
			local itemId = itemList[1].Id
			local itemCfg = CommonItemConfig.GetConfig(itemId)

			if itemCfg then
				return itemCfg.Name or ""
			end
		end
	end

	return ""
end

M.GetCostByDrawCount = function(self, costCountList, currentDrawCount)
	if not costCountList or #costCountList ~= 0 then
		return 0
	end

	if #costCountList ~= 1 then
		return costCountList[1].cost
	end

	local cost = costCountList[1].cost

	for i = 1, #costCountList do
		if costCountList[i].drawCount < currentDrawCount then
			cost = costCountList[i].cost
		else
			break
		end
	end

	return cost
end

M.GetPoolDrawCount = function(self, poolId)
	local playerGachaInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.PlayerGachaInfos
	local poolInfos = playerGachaInfo and playerGachaInfo.PoolInfos
	local poolInfo = poolInfos and poolInfos[poolId]

	return poolInfo and poolInfo.DrawCount or 0
end

M.CalcTotalCost = function(self, costCountList, currentDrawCount, drawCount)
	if not costCountList or #costCountList ~= 0 or not drawCount or drawCount < 0 then
		return 0
	end

	local tiers = {}

	for i = 1, #costCountList do
		tiers[i] = costCountList[i]
	end

	table.sort(tiers, function (a, b)
		return a.drawCount <= b.drawCount
	end)

	local startDraw = currentDrawCount + 1
	local endDraw = currentDrawCount + drawCount
	local currentTierIndex = nil

	for i = #tiers, 1, -1 do
		if tiers[i].drawCount < startDraw then
			currentTierIndex = i

			break
		end
	end

	if not currentTierIndex then
		print_error("CalcTotalCost: 找不到适用的价格阶梯，startDraw=", startDraw)

		return 0
	end

	local totalCost = 0

	for drawIndex = startDraw, endDraw do
		local nextTierIndex = currentTierIndex + 1

		if tiers[nextTierIndex] and tiers[nextTierIndex].drawCount < drawIndex then
			currentTierIndex = nextTierIndex
		end

		totalCost = totalCost + tiers[currentTierIndex].cost
	end

	return totalCost
end

M.GetTokenCountPerBuy = function(self, commodityId, moneyId)
	local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

	if not commodityCfg then
		return 0
	end

	local dropCfg = DropConfig.GetConfig(commodityCfg.DropId)

	if not dropCfg or not dropCfg.Item1 then
		return 0
	end

	local tokensPerBuy = 0
	local item1 = dropCfg.Item1

	for i = 1, #item1 do
		if item1[i].id1 ~= moneyId then
			tokensPerBuy = tokensPerBuy + item1[i].count
		end
	end

	return tokensPerBuy
end

M.DoDrawGacha = function(self, gachaId, poolId, drawCount, isAutoExchange, onSuccessCallback, onComplete)
	self.currentDrawGachaId = gachaId

	gClientToGameDelegate:AskDrawGacha(poolId, drawCount, isAutoExchange or false).Callback = function (err, updatedGachaInfos)
		if err ~= MessageConfig.Ok then
			local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

			if not playerGachaInfo then
				playerGachaInfo = {
					GroupInfos = {},
					PoolInfos = {},
					PityInfos = {}
				}
				gPlayerManager.infoMinor.bindData.PlayerGachaInfos = playerGachaInfo
			end

			if updatedGachaInfos.GroupInfos then
				for id, info in pairs(updatedGachaInfos.GroupInfos) do
					playerGachaInfo.GroupInfos[id] = info
				end
			end

			if updatedGachaInfos.PoolInfos then
				for id, info in pairs(updatedGachaInfos.PoolInfos) do
					playerGachaInfo.PoolInfos[id] = info
				end
			end

			if updatedGachaInfos.PityInfos then
				for id, info in pairs(updatedGachaInfos.PityInfos) do
					playerGachaInfo.PityInfos[id] = info
				end
			end

			gMessageManager:SendMessage(gEventConstants.GACHA_POOL_COUNT_CHANGE)

			if onSuccessCallback then
				onSuccessCallback()
			end

			if onComplete then
				onComplete(true)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if onComplete then
				onComplete(false)
			end
		end
	end
end

M.TryDrawGachaWithCostCheck = function(self, gachaId, poolId, costItemId, totalCost, drawCount, onSuccessCallback, isFromBox, onAbortCallback)
	if not gachaId or gachaId ~= 0 then
		print_error("TryDrawGachaWithCostCheck: gachaId无效", gachaId)

		if onAbortCallback then
			onAbortCallback()
		end

		return
	end

	if not costItemId or costItemId ~= 0 then
		print_error("TryDrawGachaWithCostCheck: costItemId无效", costItemId)

		if onAbortCallback then
			onAbortCallback()
		end

		return
	end

	if not totalCost or totalCost < 0 then
		print_error("TryDrawGachaWithCostCheck: totalCost无效", totalCost)

		if onAbortCallback then
			onAbortCallback()
		end

		return
	end

	if not drawCount or drawCount == 1 and drawCount == 10 then
		print_error("TryDrawGachaWithCostCheck: drawCount无效", drawCount)

		if onAbortCallback then
			onAbortCallback()
		end

		return
	end

	local playerItemCount = gCommonItemManager:GetPackItemNum(costItemId)

	if totalCost < playerItemCount then
		self:DoDrawGacha(gachaId, poolId, drawCount, false, onSuccessCallback)

		return
	end

	if onAbortCallback then
		onAbortCallback()
	end

	if isFromBox then
		gDisplayMessageMgr:ShowMessage(65420249, function ()
			gTradeManager:OpenPanel()
		end, function ()
		end)

		return
	end

	local poolCfg = GachaPoolConfig.GetConfig(poolId)
	local commodityId = poolCfg and poolCfg.CommodityId or 0

	if commodityId ~= 0 then
		print_error("TryDrawGachaWithCostCheck: 卡池未配置CommodityId，无法补购抽卡券，poolId=", poolId)

		return
	end

	local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

	if not commodityCfg then
		print_error("TryDrawGachaWithCostCheck: 找不到商品配置，commodityId=", commodityId)

		return
	end

	if not commodityCfg.ConsumeItemId or commodityCfg.ConsumeItemId ~= 0 then
		print_error("TryDrawGachaWithCostCheck: 商品未配置ConsumeItemId，commodityId=", commodityId)

		return
	end

	local deficit = totalCost - playerItemCount
	local tokensPerBuy = self:GetTokenCountPerBuy(commodityId, costItemId)

	if tokensPerBuy ~= 0 then
		print_error("TryDrawGachaWithCostCheck: 商品未固定产出抽卡代币，按1:1折算，commodityId=", commodityId, "costItemId=", costItemId)

		tokensPerBuy = 1
	end

	local needBuyCount = math.floor((deficit + tokensPerBuy - 1) / tokensPerBuy)
	local buyPrice = commodityCfg.Price or 0
	local buyCostItemId = commodityCfg.ConsumeItemId
	local buyTotalCost = buyPrice * needBuyCount

	gDisplayMessageMgr:ShowMessage(poolCfg.LackMoneyTip, function ()
		self:_DrawWithAutoBuy({
			gachaId = gachaId,
			poolId = poolId,
			drawCount = drawCount,
			commodityId = commodityId,
			needBuyCount = needBuyCount,
			buyCostItemId = buyCostItemId,
			buyTotalCost = buyTotalCost,
			onSuccessCallback = onSuccessCallback
		})

		return false
	end, nil, needBuyCount, buyTotalCost)
end

M._DrawWithAutoBuy = function(self, params)
	local buyCostItemId = params.buyCostItemId
	local buyTotalCost = params.buyTotalCost

	local onSuccess = function()
		gMallManager:AddLocalBoughtCount(params.commodityId, params.needBuyCount)

		if params.onSuccessCallback then
			params.onSuccessCallback()
		end
	end

	local doDraw = function(isAutoExchange, onComplete)
		self:DoDrawGacha(params.gachaId, params.poolId, params.drawCount, isAutoExchange, onSuccess, onComplete)
	end

	if buyTotalCost < gCommonItemManager:GetPackItemNum(buyCostItemId) then
		doDraw(false)

		return
	end

	if buyCostItemId ~= ConsumableConfig.RewardBindingGold then
		local needExchangeAmount = gMallManager:GetBindingGoldExchangeAmount(buyTotalCost)

		if needExchangeAmount <= 0 then
			gDisplayMessageMgr:ShowMessage(MessageConfig.MallGoldExchangeBindingGold, function ()
				doDraw(true)
			end, nil, needExchangeAmount)

			return
		end
	end

	gMallManager:JumpToQuickChargeWithCallback(nil, {
		targetMoneyItemId = buyCostItemId,
		targetPrice = buyTotalCost,
		retryFunc = function (onComplete)
			self.suppressChargeReward = true

			doDraw(true, function (success)
				self.suppressChargeReward = false

				if onComplete then
					onComplete(success)
				end
			end)
		end
	})
end

M.IsPoolActive = function(self, poolCfg)
	if not poolCfg then
		return false
	end

	local startTime = poolCfg.StartTime
	local endTime = poolCfg.EndTime

	if gMallManager:IsTimeEmpty(startTime) and gMallManager:IsTimeEmpty(endTime) then
		return true
	end

	local currentTime = gLuaDataManager.serverTime
	local isActive = true

	if not gMallManager:IsTimeEmpty(startTime) then
		local startUnixTime = gTimeUtils:GetUnixTime(startTime.year or 0, startTime.month or 0, startTime.day or 0, startTime.hour or 0, startTime.minute or 0, startTime.second or 0)
		isActive = isActive and startUnixTime > currentTime
	end

	if isActive and not gMallManager:IsTimeEmpty(endTime) then
		local endUnixTime = gTimeUtils:GetUnixTime(endTime.year or 0, endTime.month or 0, endTime.day or 0, endTime.hour or 0, endTime.minute or 0, endTime.second or 0)
		isActive = currentTime <= endUnixTime
	end

	return isActive
end

M.CheckHasActiveClosetPool = function(self)
	for i = 0, GachaConfig.count - 1 do
		local cfg = GachaConfig.LoadAt(i)

		if cfg and cfg.GachaType ~= 1 and self:IsPoolActive(cfg) then
			return true
		end
	end

	return false
end

gGachaManager = gGachaManager or C_GachaManager.new()
