-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\QiMengBoxPanelStore.lua
-- Decompiled from: 00855_QiMengBoxPanelStore.lua_f4ed83ef752e.luajit

local GachaConfig = LTConfig.GachaConfig
local GachaPoolConfig = LTConfig.GachaPoolConfig
local GachaPoolContentConfig = LTConfig.GachaPoolContentConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local GachaPoolTierRuleConfig = LTConfig.GachaPoolTierRuleConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local MallMainTabConfig = LTConfig.MallMainTabConfig
local TextConfig = LTConfig.TextConfig
local MessageConfig = LTConfig.MessageConfig
local MoneyType = UX.Game.MoneyType
local TIER_DEFS = {
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "G\\xcf\\xdf(:?\\xcfh.\\xd2f\\x89J\\xc9\\xe2",
		["\\x8d!,:Q\\x99g\\xd02\\xa6\\xbd"] = "1\\xd0`\\xd5\\x84T\\xadS\\x99\\xb2",
		rarity = GachaPoolContentConfig.PoolTierRarityType.SS
	},
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "T8\\xa9\\x91\\xb2̼\\xcc5\\xae\\xa6\n9",
		["\\x8d!,:Q\\x99g\\xd02\\xa6\\xbd"] = "\\I\\x98~I\\xa0\\xc0RfWH",
		rarity = GachaPoolContentConfig.PoolTierRarityType.S
	},
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "F8\\xa9\\x91\\xb2̼\\xcc5\\xae\\xa6\n9",
		["\\x8d!,:Q\\x99g\\xd02\\xa6\\xbd"] = "NI\\x98~I\\xa0\\xc0RfWH",
		rarity = GachaPoolContentConfig.PoolTierRarityType.A
	},
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "E8\\xa9\\x91\\xb2̼\\xcc5\\xae\\xa6\n9",
		["\\x8d!,:Q\\x99g\\xd02\\xa6\\xbd"] = "MI\\x98~I\\xa0\\xc0RfWH",
		rarity = GachaPoolContentConfig.PoolTierRarityType.B
	},
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "D8\\xa9\\x91\\xb2̼\\xcc5\\xae\\xa6\n9",
		["\\x8d!,:Q\\x99g\\xd02\\xa6\\xbd"] = "LI\\x98~I\\xa0\\xc0RfWH",
		rarity = GachaPoolContentConfig.PoolTierRarityType.C
	}
}

local BuildTierList = function(poolCfg)
	local tiers = {}

	for _, def in ipairs(TIER_DEFS) do
		local ruleId = poolCfg[def.ruleIdField]

		if ruleId == nil then
			table.insert(tiers, {
				TierRarity = def.rarity,
				RuleId = ruleId or 0,
				SamplingMethod = poolCfg[def.samplingField] or 0
			})
		end
	end

	return tiers
end

C_QiMengBoxPanelStore = DefClass("C_QiMengBoxPanelStore", C_QiMengBoxPanelStore, C_StoreGroup)
GroupName2Class.QiMengBoxPanelStore = C_QiMengBoxPanelStore
GroupName2Class.QiMengBoxGachaPanelStore = C_QiMengBoxPanelStore
local M = C_QiMengBoxPanelStore

M.ctor = function(self)
	self.validGachaPools = {}
	self.targetGachaType = 2
	self.currentPoolIndex = 1
	self.currentPoolCfg = nil
	self.endTimestamp = 0
	self.tabDataList = {}
	self.milestoneList = {}
	self.parentStore = nil
	self.gachaSceneMap = {}
	self.gachaCommodityMap = {}
	self.currentMilestone = nil
	self.isMilestoneClaimable = false
	self.gachaSafetyTimer = nil
	self.isGachaInProgress = false
	self.jumpBtnCommodities = {}
	self.jumpBtnStore = nil
	self.jumpBtnTimer = nil
	self.scrollAnimDuration = 0
	self.scrollAnimTimer = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.giftCtrlEnum = {
		["\\\\xb38\\xfbx\\xa1;&t\\xa2\\xea,\\xd6\\xe9"] = 2,
		["Nz\\xa0TC\\xbe\\xfeBin{H"] = 1,
		["T-s^"] = 3,
		["\r%4\\xc5\\x94\\xd4;\\xa4#\\xe3\\xf1\\xf2q\\xff"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.giftCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	if self.jumpBtnStore and self.jumpBtnCommodities and #self.jumpBtnCommodities <= 1 then
		self.StartJumpBtnTimer(self)
	end
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	self.StopJumpBtnTimer(self)
	self.StopScrollAnimTimer(self)
end

M.OnDestroy = function(self)
	self.validGachaPools = {}
	self.targetGachaType = 2
	self.currentPoolIndex = 1
	self.currentPoolCfg = nil
	self.endTimestamp = 0
	self.tabDataList = {}
	self.milestoneList = {}
	self.gachaSceneMap = {}
	self.gachaCommodityMap = {}
	self.currentMilestone = nil
	self.isMilestoneClaimable = false

	self.ClearGachaLock(self)
	self.StopJumpBtnTimer(self)
	self.StopScrollAnimTimer(self)

	self.jumpBtnCommodities = {}
	self.jumpBtnStore = nil
	self.scrollAnimDuration = 0
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.parentStore = data and data.parentStore or nil
	self.targetGachaType = data and data.boxGachaType ~= 3 and 3 or 2
	self.bindData.extraRewardBtn.enabledTooltip = false

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if self.parentStore and self.parentStore.rootArea then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.parentStore.rootArea
		else
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootGo:GetComponent("UNavigationArea")
		end
	end

	self.InitGachaPools(self)
	self.BuildGachaSceneMap(self)
	self.UpdateTabList(self)
	self.InitJumpBtnCommodities(self)
	self.SetupJumpBtnScrollTemplate(self)

	if #self.validGachaPools <= 0 then
		self.bindData.tabList:SelectItem(0, true)
	end

	self.bindData.oneGachaText = TextConfig.GetConfig(73977013).Text
	self.bindData.tenGachaText = TextConfig.GetConfig(73977014).Text
	self.bindData.poolBtnText = TextConfig.GetConfig(73977015).Text
	self.bindData.canGetDesText = TextConfig.GetConfig(73977017).Text
	self.bindData.allGetDesText = TextConfig.GetConfig(73977038).Text

	self.PlayOpenAnim(self)
end

M.PlayOpenAnim = function(self)
	if not self.rootGo then
		return
	end

	local anim = self.rootGo:GetComponent("Animation")

	if anim then
		gCS.LuaUtils.PlayAnimationByName(anim, "S_Gacha_open")
	end
end

M.PlayPoolAnim = function(self)
	if not self.currentPoolCfg then
		return
	end

	if not self.parentStore or not self.parentStore.PlayVideo then
		return
	end

	local gachaConfig = GachaConfig.GetConfig(self.currentPoolCfg.Id)
	local videoId = gachaConfig and gachaConfig.ButtonVideo or 0

	if videoId < 0 then
		return
	end

	self.parentStore:PlayVideo(videoId, nil, , , self.bindData.bgVideoRT)
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitGachaPools = function(self)
	self.validGachaPools = gMallManager:BuildSortedGachaPools(self.targetGachaType)
end

M.BuildGachaSceneMap = function(self)
	self.gachaSceneMap = {}
	self.gachaCommodityMap = {}

	for _, poolCfg in ipairs(self.validGachaPools) do
		local gachaCfg = GachaConfig.GetConfig(poolCfg.Id)

		if gachaCfg then
			local commodityId = gachaCfg.GrandPrizeCommodityId or 0

			if commodityId <= 0 then
				local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

				if commodityCfg then
					local commodityData = gMallManager:GenMallCommodityItem(commodityCfg)
					local sceneId = commodityCfg.SceneId or 0

					if sceneId <= 0 then
						self.gachaSceneMap[poolCfg.Id] = sceneId
						self.gachaCommodityMap[poolCfg.Id] = commodityData
					end
				end
			end
		end
	end
end

M.ShowPoolInfo = function(self, poolCfg)
	if not poolCfg then
		return
	end

	self.currentPoolCfg = poolCfg
	self.bindData.titleText = poolCfg.Name or ""
	local sceneId = self.gachaSceneMap[poolCfg.Id] or 0
	local commodityData = self.gachaCommodityMap[poolCfg.Id]
	local hasScene = sceneId and sceneId == 0

	if hasScene and self.parentStore then
		if self.parentStore.TryOnFashion and commodityData then
			self.parentStore:TryOnFashion(commodityData)
		else
			self.parentStore:ApplyMallSceneById(sceneId)
			self.parentStore:SetModelBtnActive(false)
		end
	end

	if self.bindData.spine then
		self.bindData.spine.parent.gameObject:SetActive(not hasScene)
	end

	if hasScene then
		self.bindData.spineActive = false
	else
		self.bindData.spineActive = self.currentPoolCfg.Id ~= 1
	end

	if self.bindData.playBtn then
		self.bindData.playBtn.gameObject:SetActive(self.currentPoolCfg.ButtonVideo == 0)
	end

	self.bindData.bgIconId = hasScene and 0 or poolCfg.BackgroundImage

	self:UpdatePricesAndMoneyIcon()
	self:InitCountDown()
	self:UpdatePityInfoText()
	self:ParseMilestones()
	self:UpdateGiftStatus()
	self:WarmupNeighborPoolScenes(poolCfg.Id)
end

M.WarmupNeighborPoolScenes = function(self, currentPoolId)
	if not self.validGachaPools or #self.validGachaPools ~= 0 then
		return
	end

	local centerIndex = -1

	for i, cfg in ipairs(self.validGachaPools) do
		if cfg.Id ~= currentPoolId then
			centerIndex = i

			break
		end
	end

	if centerIndex >= 1 then
		return
	end

	local sceneMap = self.gachaSceneMap
	slot4 = gMallSceneManager

	slot4:ScheduleWarmupNeighborScenes(self.validGachaPools, centerIndex, function (poolCfg)
		return sceneMap and poolCfg and sceneMap[poolCfg.Id] or 0
	end)
end

M.UpdatePricesAndMoneyIcon = function(self)
	if not self.currentPoolCfg then
		return
	end

	local prizePoolIds = self.currentPoolCfg.PrizePoolIds

	if not prizePoolIds or #prizePoolIds ~= 0 then
		return
	end

	local poolId = prizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)

	if not poolCfg then
		return
	end

	local moneyCfg = ConsumableConfig.GetConfig(poolCfg.MoneyId)

	if moneyCfg then
		self.bindData.iconOneId = moneyCfg.SItemIconId
		self.bindData.iconTenId = moneyCfg.SItemIconId
	end

	local singleCost = 0
	local tenCost = 0

	if poolCfg.CostCount and #poolCfg.CostCount <= 0 then
		singleCost = poolCfg.CostCount[1].cost
		tenCost = singleCost * 10
	end

	self.bindData.price1Text = tostring(singleCost)
	self.bindData.price10Text = tostring(tenCost)
end

M.InitCountDown = function(self)
	local now = gLuaDataManager.serverTime
	self.endTimestamp = 0

	if self.currentPoolCfg and self.currentPoolCfg.EndTime then
		local endTime = self.currentPoolCfg.EndTime

		if not gMallManager:IsTimeEmpty(endTime) then
			self.endTimestamp = gTimeUtils:GetUnixTime(endTime.year or 0, endTime.month or 0, endTime.day or 0, endTime.hour or 0, endTime.minute or 0, endTime.second or 0)

			if self.endTimestamp and now >= self.endTimestamp then
				local remainingTime = self.endTimestamp - now

				self.bindData.countDown:Play(remainingTime)
			else
				self.endTimestamp = 0
			end
		end
	end
end

M.UpdatePityInfoText = function(self)
	self.bindData.info2Text = ""
	self.bindData.info1Text = ""

	if not self.currentPoolCfg then
		return
	end

	local prizePoolIds = self.currentPoolCfg.PrizePoolIds

	if not prizePoolIds or #prizePoolIds ~= 0 then
		return
	end

	local poolId = prizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)

	if not poolCfg then
		return
	end

	local tierList = BuildTierList(poolCfg)
	local pityRuleId = 0
	local pityTierRuleCfg = nil

	for i = 1, #tierList do
		local ruleId = tierList[i].RuleId

		if ruleId and ruleId <= 0 then
			local ruleCfg = GachaPoolTierRuleConfig.GetConfig(ruleId)

			if ruleCfg and ruleCfg.RuleType ~= GachaPoolTierRuleConfig.RuleTypeType.Pity then
				pityRuleId = ruleId
				pityTierRuleCfg = ruleCfg

				break
			end
		end
	end

	if not pityTierRuleCfg then
		return
	end

	local drawsSinceLastReset = 0
	local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

	if playerGachaInfo and playerGachaInfo.PityInfos and playerGachaInfo.PityInfos[pityRuleId] then
		drawsSinceLastReset = playerGachaInfo.PityInfos[pityRuleId].DrawsSinceLastReset or 0
	end

	local remainingDraws = pityTierRuleCfg.PityThreshold - drawsSinceLastReset

	if remainingDraws >= 0 then
		remainingDraws = 0
	end

	local textCfg = TextConfig.GetConfig(self.currentPoolCfg.PanelTexts[1] or 73977002)
	self.bindData.info1Text = string.format(textCfg.Text, remainingDraws)
end

M.OnCountDownFinished = function(self)
	local oldPoolCfg = self.currentPoolCfg

	self.InitGachaPools(self)
	self.UpdateTabList(self)

	if #self.validGachaPools <= 0 then
		local newIndex = 0

		if oldPoolCfg then
			for i, poolCfg in ipairs(self.validGachaPools) do
				if poolCfg.Id ~= oldPoolCfg.Id then
					newIndex = i - 1

					break
				end
			end
		end

		self.bindData.tabList:SelectItem(newIndex, false)
	else
		self.bindData.info1Text = ""
		self.bindData.info2Text = ""
		self.bindData.spineActive = false
	end
end

M.UpdateTabList = function(self)
	self.tabDataList = {}

	for index, poolCfg in ipairs(self.validGachaPools) do
		local tabData = {
			index = index,
			poolCfg = poolCfg,
			name = poolCfg.Name or "",
			id = poolCfg.Id or 0
		}

		table.insert(self.tabDataList, tabData)
	end

	self.bindData.tabList:SetSimpleList(#self.tabDataList)

	if #self.tabDataList < 1 then
		self.bindData.tabList.gameObject:SetActive(false)
	else
		self.bindData.tabList.gameObject:SetActive(true)
	end
end

M.OnTabSelectedChanged = function(self, uList)
	local selectedIndex = uList.selectedIndex

	if selectedIndex <= 0 or selectedIndex > #self.validGachaPools then
		return
	end

	self.currentPoolIndex = selectedIndex + 1
	local poolCfg = self.validGachaPools[self.currentPoolIndex]

	self.ShowPoolInfo(self, poolCfg)
	self.PlayPoolAnim(self)
end

M.ParseMilestones = function(self)
	self.milestoneList = {}
	local milestones = self.currentPoolCfg.Milestone

	if not milestones or #milestones ~= 0 then
		return
	end

	for i = 1, #milestones do
		local milestone = milestones[i]

		if milestone and milestone.count and milestone.dropId then
			table.insert(self.milestoneList, {
				count = milestone.count,
				dropId = milestone.dropId
			})
		end
	end
end

M.GetCurrentDrawCount = function(self)
	if not self.currentPoolCfg then
		return 0
	end

	local prizePoolIds = self.currentPoolCfg.PrizePoolIds

	if not prizePoolIds or #prizePoolIds ~= 0 then
		return 0
	end

	local poolId = prizePoolIds[1].id
	local currentDrawCount = 0
	local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

	if playerGachaInfo and playerGachaInfo.PoolInfos then
		local poolInfo = playerGachaInfo.PoolInfos[poolId]

		if poolInfo then
			currentDrawCount = poolInfo.DrawCount or 0
		end
	end

	return currentDrawCount
end

M.GetClaimedMilestones = function(self)
	if not self.currentPoolCfg then
		return {}
	end

	local gachaId = self.currentPoolCfg.Id
	local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

	if playerGachaInfo and playerGachaInfo.GroupInfos then
		local groupInfo = playerGachaInfo.GroupInfos[gachaId]

		if groupInfo and groupInfo.ClaimedMilestoneCounts then
			return groupInfo.ClaimedMilestoneCounts
		end
	end

	return {}
end

M.UpdateGiftStatus = function(self)
	if self.targetGachaType ~= 2 then
		self.bindData.giftCtrl = 3
		self.currentMilestone = nil
		self.isMilestoneClaimable = false

		return
	end

	local currentDrawCount = self.GetCurrentDrawCount(self)
	local claimedMap = self.GetClaimedMilestones(self)
	local nextMilestone = nil

	for i = 1, #self.milestoneList do
		local milestone = self.milestoneList[i]

		if not claimedMap[milestone.count] then
			nextMilestone = milestone

			break
		end
	end

	if not nextMilestone then
		self.bindData.giftCtrl = self.giftCtrlEnum.AllCollected
		self.currentMilestone = nil
		self.isMilestoneClaimable = false

		if #self.milestoneList <= 0 then
			local lastMilestone = self.milestoneList[#self.milestoneList]

			self.ShowExtraRewardInfo(self, lastMilestone, false)
		end
	elseif nextMilestone.count < currentDrawCount then
		self.bindData.giftCtrl = self.giftCtrlEnum.AvailableCollection

		self.ShowExtraRewardInfo(self, nextMilestone, true)
	else
		self.bindData.giftCtrl = self.giftCtrlEnum.NotAllCollected
		local remainingDraws = nextMilestone.count - currentDrawCount
		self.bindData.leftNumText = tostring(remainingDraws)
		self.bindData.leftNumDesText = gString.Format(TextConfig.GetConfig(73977016).Text, remainingDraws)

		self.ShowExtraRewardInfo(self, nextMilestone, false)
	end
end

M.ShowExtraRewardInfo = function(self, milestone, isClaimable)
	if not milestone or not self.bindData.extraRewardBtn then
		return
	end

	local itemList, randomList = gCommonItemManager:ConvertDropToFakeItem(milestone.dropId, 1)

	if itemList and #itemList <= 0 and itemList[1] then
		local item = itemList[1]
		local renderData = gCommonItemManager:GetItemRenderData({
			["\\xd0\\xcf01\\xfc"] = 0,
			itemId = item.Id
		})
		local store = gCommonItemManager:OnCommonItemRender(self.bindData.extraRewardBtn, 0, renderData)

		store:Commit("vx_complateCtrl", isClaimable and 1 or 0, COMMIT_FORCE)
	end

	self.currentMilestone = milestone
	self.isMilestoneClaimable = isClaimable
end

M.OnTabRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.tabDataList[luaIndex]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.titleText = data.name
	store.isNewCtrl = 1
end

M.InitJumpBtnCommodities = function(self)
	self.jumpBtnCommodities = {}
	local targetType = MallCommodityConfig.TypeType.GachaRareExchange

	for i = 0, MallCommodityConfig.count - 1 do
		local commodityCfg = MallCommodityConfig.LoadAt(i)

		if commodityCfg and commodityCfg.Type ~= targetType and commodityCfg.IsCarousel then
			table.insert(self.jumpBtnCommodities, commodityCfg)
		end
	end
end

M.SetupJumpBtnScrollTemplate = function(self)
	self.StopJumpBtnTimer(self)

	if not self.bindData.jumpBtn or #self.jumpBtnCommodities ~= 0 then
		return
	end

	local store = gStoreManager:GetStoreGroup(self.bindData.jumpBtn.Store):GetStoreByWidget(self.bindData.jumpBtn)

	if not store then
		return
	end

	self.jumpBtnStore = store
	store.mergedItems = self.jumpBtnCommodities
	store.currentSelectedBarIndex = 0
	store.subtitleCtrl = 0
	store.tagCtrl = 0
	self.bindData.jumpBtn.autoClickOnHighlight = false
	local barCount = #self.jumpBtnCommodities

	if store.barList then
		store.barList:SetSimpleList(barCount)

		if not store.jumpBtnBarRegistered then
			store.barList.luaSimpleRenderItem = self.CreateAction(self, "OnJumpBtnBarRenderItem")
			store.barList.luaSimpleClick = self.CreateAction(self, "OnJumpBtnBarClick")
			store.jumpBtnBarRegistered = true
		end

		store.barList:SelectItem(0, true)
	end

	if store.leftBtn and store.rightBtn and not store.jumpBtnArrowRegistered then
		store.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnJumpBtnArrowClick", -1)
		store.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnJumpBtnArrowClick", 1)
		store.jumpBtnArrowRegistered = true
	end

	self.UpdateJumpBtnDisplay(self, 0)

	self.scrollAnimDuration = 0

	if self.bindData.scrollAnim then
		local clip = self.bindData.scrollAnim:GetClip("S_GachaRecommendWideTemplate_Scroll")

		if clip then
			self.scrollAnimDuration = clip.length
		end
	end

	if barCount <= 1 then
		self.StartJumpBtnTimer(self)
	end
end

M.UpdateJumpBtnDisplay = function(self, index)
	if not self.jumpBtnStore then
		return
	end

	local cfg = self.jumpBtnCommodities[index + 1]

	if not cfg then
		return
	end

	self.jumpBtnStore.titleText = cfg.Name or ""
	self.jumpBtnStore.bgIconId = cfg.Carouselmage or cfg.Picture
end

M.SwitchJumpBtnTo = function(self, index)
	if not self.jumpBtnStore or not self.jumpBtnCommodities[index + 1] then
		return
	end

	if self.bindData.scrollAnim and self.scrollAnimDuration and self.scrollAnimDuration <= 0 then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.scrollAnim, "S_GachaRecommendWideTemplate_Scroll")

		local halfDur = self.scrollAnimDuration * 0.5

		self.StopScrollAnimTimer(self)

		self.scrollAnimTimer = gLuaTimeMgrUtils.Delay(function ()
			self.scrollAnimTimer = nil

			self:DoSwitchJumpBtnTo(index)
		end, halfDur)
	else
		self.DoSwitchJumpBtnTo(self, index)
	end
end

M.DoSwitchJumpBtnTo = function(self, index)
	if not self.jumpBtnStore or not self.jumpBtnCommodities[index + 1] then
		return
	end

	self.jumpBtnStore.currentSelectedBarIndex = index

	if self.jumpBtnStore.barList then
		self.jumpBtnStore.barList:RefreshList()
	end

	self.UpdateJumpBtnDisplay(self, index)
end

M.StopScrollAnimTimer = function(self)
	if self.scrollAnimTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.scrollAnimTimer)

		self.scrollAnimTimer = nil
	end
end

M.OnJumpBtnBarRenderItem = function(self, barBtn, index)
	if not self.jumpBtnStore then
		return
	end

	local cfg = self.jumpBtnCommodities[index + 1]

	if not cfg then
		return
	end

	local barStore = gStoreManager:GetStoreGroup(barBtn.Store):GetStoreByWidget(barBtn)

	if not barStore then
		return
	end

	barStore.indexText = tostring(index + 1)
	barStore.colorCtrl = self.jumpBtnStore.currentSelectedBarIndex ~= index and 1 or 0
end

M.OnJumpBtnBarClick = function(self, barBtn, index)
	self.StopJumpBtnTimer(self)
	self.SwitchJumpBtnTo(self, index)
	self.StartJumpBtnTimer(self)
end

M.OnJumpBtnArrowClick = function(self, direction)
	if not self.jumpBtnStore or #self.jumpBtnCommodities ~= 0 then
		return
	end

	local count = #self.jumpBtnCommodities
	local currentIndex = self.jumpBtnStore.currentSelectedBarIndex or 0
	local targetIndex = (currentIndex + direction + count) % count

	self:StopJumpBtnTimer()

	if self.jumpBtnStore.barList then
		self.jumpBtnStore.barList:SelectItem(targetIndex, true)
	end

	self.SwitchJumpBtnTo(self, targetIndex)
	self.StartJumpBtnTimer(self)
end

M.StartJumpBtnTimer = function(self)
	self.StopJumpBtnTimer(self)

	if not self.jumpBtnCommodities or #self.jumpBtnCommodities < 1 then
		return
	end

	self.jumpBtnTimer = Timer.New(function ()
		self:OnJumpBtnAutoSwitch()
	end, 5, -1):Start()
end

M.StopJumpBtnTimer = function(self)
	if self.jumpBtnTimer then
		self.jumpBtnTimer:Stop()

		self.jumpBtnTimer = nil
	end
end

M.OnJumpBtnAutoSwitch = function(self)
	if not self.jumpBtnStore or #self.jumpBtnCommodities < 1 then
		return
	end

	local currentIndex = self.jumpBtnStore.currentSelectedBarIndex or 0
	local nextIndex = (currentIndex + 1) % #self.jumpBtnCommodities

	if self.jumpBtnStore.barList then
		self.jumpBtnStore.barList:SelectItem(nextIndex, true)
	end

	self.SwitchJumpBtnTo(self, nextIndex)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged"),
		[gEventConstants.GACHA_POOL_COUNT_CHANGE] = self.CreateAction(self, "OnGachaPoolCountChange"),
		[gEventConstants.GACHA_MILESTONE_CLAIMED] = self.CreateAction(self, "OnGachaMilestoneClaimed"),
		[gEventConstants.PANEL_CLOSE] = self.CreateAction(self, "OnPanelClose")
	}
end

M.OnPanelClose = function(self, _, msg)
	if not msg then
		return
	end

	if msg.panelId ~= gPanelId.GACHA_RESULT or msg.panelId ~= gPanelId.GACHA_TEN_RESULT then
		self.PlayOpenAnim(self)

		if gCS.LuaUtils.IsNonMobileAdaptive() and self.parentStore and self.parentStore.rootArea then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.parentStore.rootArea
		end
	end
end

M.OnPackItemChanged = function(self)
	if self.parentStore and self.parentStore.RefreshMoneyDisplay then
		self.parentStore:RefreshMoneyDisplay()
	else
		self.RefreshMoneyDisplay(self)
	end
end

M.OnGachaPoolCountChange = function(self)
	if self.isGachaInProgress then
		self.ClearGachaLock(self)
	end

	self.UpdatePityInfoText(self)
	self.UpdateGiftStatus(self)

	if self.parentStore and self.parentStore.RefreshMoneyDisplay then
		self.parentStore:RefreshMoneyDisplay()
	end
end

M.OnGachaMilestoneClaimed = function(self)
	self.UpdateGiftStatus(self)

	if self.parentStore and self.parentStore.RefreshMoneyDisplay then
		self.parentStore:RefreshMoneyDisplay()
	end
end

M.InitMoneyDisplay = function(self)
	if not self.SubGroup.MoneyTemplateStore then
		return
	end

	local moneyTemplateData = {
		{
			Type = MoneyType.Gold
		},
		{
			Type = MoneyType.BindingGold
		}
	}

	self.SubGroup.MoneyTemplateStore:SetData(moneyTemplateData)
end

M.RefreshMoneyDisplay = function(self)
	self.InitMoneyDisplay(self)
end

M.RegisterWidget = function(self)
	self.bindData.countDown.luaFinished = self.CreateAction(self, "OnCountDownFinished")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnTabRenderItem")
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, "OnTabSelectedChanged")
	self.bindData.infoBtn.luaClick = self.CreateAction(self, "OnClickInfoBtn")
	self.bindData.tenGachaBtn.luaClick = self.CreateAction(self, "OnClickTenGachaBtn")
	self.bindData.oneGachaBtn.luaClick = self.CreateAction(self, "OnClickOneGachaBtn")

	if self.bindData.backBtn then
		self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	end

	self.bindData.leftNumInfoBtn.luaClick = self.CreateAction(self, "OnClickLeftNumInfoBtn")
	self.bindData.poolBtn.luaClick = self.CreateAction(self, "OnClickPoolBtn")

	if self.bindData.jumpBtn then
		self.bindData.jumpBtn.luaClick = self.CreateAction(self, "OnClickJumpBtn")
	end

	if self.bindData.extraRewardBtn then
		self.bindData.extraRewardBtn.luaClick = self.CreateAction(self, "OnClickExtraRewardBtn")
	end

	if self.bindData.playBtn then
		self.bindData.playBtn.luaClick = self.CreateAction(self, "OnClickPlayBtn")
	end

	if self.bindData.poolListL2Btn then
		self.bindData.poolListL2Btn.luaClick = self.CreateActionWithArgs(self, "OnClickPoolSwitchBtn", -1)
	end

	if self.bindData.poolListR2Btn then
		self.bindData.poolListR2Btn.luaClick = self.CreateActionWithArgs(self, "OnClickPoolSwitchBtn", 1)
	end
end

M.OnClickInfoBtn = function(self)
	if self.currentPoolCfg then
		gPanelManager:CheckShow(gPanelId.GACHA_INFO, {
			gachaId = self.currentPoolCfg.Id,
			boxGachaType = self.targetGachaType
		})
	end
end

M.OnClickTenGachaBtn = function(self)
	if self.isGachaInProgress then
		return
	end

	local prizePoolIds = self.currentPoolCfg.PrizePoolIds
	local poolId = prizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)
	local costItemId = poolCfg.MoneyId
	local totalCost = gGachaManager:CalcTotalCost(poolCfg.CostCount, gGachaManager:GetPoolDrawCount(poolId), 10)

	self:StartGachaLock()

	slot6 = gGachaManager

	slot6:TryDrawGachaWithCostCheck(self.currentPoolCfg.Id, poolId, costItemId, totalCost, 10, function ()
		self:GachaSuccessCallback()
	end, self.targetGachaType ~= 2, function ()
		self:ClearGachaLock()
	end)
end

M.GachaSuccessCallback = function(self)
	self:UpdatePityInfoText()
	gDisplayMessageMgr:CloseBombAll()
end

M.OnClickOneGachaBtn = function(self)
	if self.isGachaInProgress then
		return
	end

	local prizePoolIds = self.currentPoolCfg.PrizePoolIds
	local poolId = prizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)
	local costItemId = poolCfg.MoneyId
	local singleCost = gGachaManager:CalcTotalCost(poolCfg.CostCount, gGachaManager:GetPoolDrawCount(poolId), 1)

	self:StartGachaLock()

	slot6 = gGachaManager

	slot6:TryDrawGachaWithCostCheck(self.currentPoolCfg.Id, poolId, costItemId, singleCost, 1, function ()
		self:GachaSuccessCallback()
	end, self.targetGachaType ~= 2, function ()
		self:ClearGachaLock()
	end)
end

M.OnClickBackBtn = function(self)
	if self.parentStore and self.parentStore.OnClickBackBtn then
		self.parentStore:OnClickBackBtn()
	else
		gPanelManager:Close(self.m_Id)
	end
end

M.OnClickLeftNumInfoBtn = function(self)
	gPanelManager:CheckShow(gPanelId.QI_MENG_BOX_LIZENG, {
		gachaId = self.currentPoolCfg.Id
	})
end

M.OnClickExtraRewardBtn = function(self)
	if self.isMilestoneClaimable and self.currentMilestone then
		self.ClaimMilestone(self, self.currentMilestone.count)
	elseif self.currentPoolCfg then
		gPanelManager:CheckShow(gPanelId.QI_MENG_BOX_LIZENG, {
			gachaId = self.currentPoolCfg.Id
		})
	end
end

M.OnClickPoolBtn = function(self)
	gPanelManager:CheckShow(gPanelId.QIMENG_BOX_POOL or 122, {
		gachaId = self.currentPoolCfg.Id
	})
end

M.OnClickPlayBtn = function(self)
	if not self.currentPoolCfg then
		return
	end

	if not self.parentStore or not self.parentStore.PlayVideo then
		return
	end

	local gachaConfig = GachaConfig.GetConfig(self.currentPoolCfg.Id)
	local videoId = gachaConfig and gachaConfig.ButtonVideo or 0

	if videoId < 0 then
		return
	end

	self.parentStore:PlayVideo(videoId, nil, , , self.bindData.bgVideoRT)
end

M.OnClickPoolSwitchBtn = function(self, direction)
	local count = self.validGachaPools and #self.validGachaPools or 0

	if count < 1 then
		return
	end

	local targetIndex = self.currentPoolIndex + direction

	if targetIndex <= 1 or count >= targetIndex then
		return
	end

	self.bindData.tabList:SelectItem(targetIndex - 1, true)
end

M.OnClickJumpBtn = function(self)
	local tabCfg = LTConfig.MallConfig.GetConfig(12)
	local targetSubTabId = tabCfg and tabCfg.Tab.Second or 4
	local targetCommodityId = 0

	if self.jumpBtnStore and self.jumpBtnCommodities and #self.jumpBtnCommodities <= 0 then
		local idx = (self.jumpBtnStore.currentSelectedBarIndex or 0) + 1
		local cfg = self.jumpBtnCommodities[idx]
		targetCommodityId = cfg and cfg.Id or 0
	end

	if self.parentStore and self.parentStore.JumpToTab then
		self.parentStore.pendingSubTabId = targetSubTabId
		self.parentStore.pendingCommodityId = targetCommodityId

		self.parentStore:JumpToTab(MallMainTabConfig.Item, true)

		return
	end

	gPanelManager:CheckShow(gPanelId.SHOP_HOME_PAGE, {
		tabId = MallMainTabConfig.Item,
		subTabId = targetSubTabId,
		commodityId = targetCommodityId
	})
end

M.ClaimMilestone = function(self, milestoneCount)
	if not self.currentPoolCfg then
		return
	end

	local gachaId = self.currentPoolCfg.Id
	local milestoneData = nil

	for i = 1, #self.milestoneList do
		if self.milestoneList[i].count ~= milestoneCount then
			milestoneData = self.milestoneList[i]

			break
		end
	end

	slot4 = gClientToGameDelegate

	slot4:AskClaimGachaMilestone(gachaId, milestoneCount).Callback = function (err)
		if err ~= MessageConfig.Ok then
			local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

			if not playerGachaInfo.GroupInfos then
				playerGachaInfo.GroupInfos = {}
			end

			if not playerGachaInfo.GroupInfos[gachaId] then
				playerGachaInfo.GroupInfos[gachaId] = {}
			end

			if not playerGachaInfo.GroupInfos[gachaId].ClaimedMilestoneCounts then
				playerGachaInfo.GroupInfos[gachaId].ClaimedMilestoneCounts = {}
			end

			playerGachaInfo.GroupInfos[gachaId].ClaimedMilestoneCounts[milestoneCount] = true

			self:UpdateGiftStatus()

			if gEventConstants.GACHA_MILESTONE_CLAIMED then
				gMessageManager:SendMessage(gEventConstants.GACHA_MILESTONE_CLAIMED)
			end

			if milestoneData and milestoneData.dropId and milestoneData.dropId <= 0 then
				local fakeItems = gCommonItemManager:ConvertDropToFakeItem(milestoneData.dropId, 1)
				local previewMaterials = {}

				for _, item in ipairs(fakeItems) do
					table.insert(previewMaterials, {
						ItemId = item.Id,
						Count = item.Count
					})
				end

				if #previewMaterials <= 0 then
					gDropManager:ShowRewardWindow({
						["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
						Param = previewMaterials
					})
				end
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.StartGachaLock = function(self)
	self.ClearGachaLock(self)

	self.isGachaInProgress = true

	self.RefreshGachaLockSafetyTimer(self, 8)
end

M.RefreshGachaLockSafetyTimer = function(self, seconds)
	if self.gachaSafetyTimer then
		self.gachaSafetyTimer:Stop()

		self.gachaSafetyTimer = nil
	end

	self.gachaSafetyTimer = Timer.New(function ()
		self.isGachaInProgress = false
		self.gachaSafetyTimer = nil
	end, seconds):Start()
end

M.ClearGachaLock = function(self)
	if self.gachaSafetyTimer then
		self.gachaSafetyTimer:Stop()

		self.gachaSafetyTimer = nil
	end

	self.isGachaInProgress = false
end
