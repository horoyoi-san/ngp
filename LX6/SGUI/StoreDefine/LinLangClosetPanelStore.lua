-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LinLangClosetPanelStore.lua
-- Decompiled from: 01795_LinLangClosetPanelStore.lua_5b1b166ab0ff.luajit

local GachaConfig = LTConfig.GachaConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local GachaPoolConfig = LTConfig.GachaPoolConfig
local GachaPoolContentConfig = LTConfig.GachaPoolContentConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local TextConfig = LTConfig.TextConfig
local MoneyType = UX.Game.MoneyType
local SamplingMethodType = {
	[":A\\x9f\\x87\\x97D"] = 1,
	["pU±\\x81\\xac\r\\xc6\\xe6"] = 2,
	["\\x98\\xa5\\xa5n?\\xec7"] = 0
}
local TIER_DEFS = {
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "G\\xcf\\xdf(:?\\xcfh.\\xd2f\\x89J\\xc9\\xe2",
		rarity = GachaPoolContentConfig.PoolTierRarityType.SS
	},
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "T8\\xa9\\x91\\xb2̼\\xcc5\\xae\\xa6\n9",
		rarity = GachaPoolContentConfig.PoolTierRarityType.S
	},
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "F8\\xa9\\x91\\xb2̼\\xcc5\\xae\\xa6\n9",
		rarity = GachaPoolContentConfig.PoolTierRarityType.A
	},
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "E8\\xa9\\x91\\xb2̼\\xcc5\\xae\\xa6\n9",
		rarity = GachaPoolContentConfig.PoolTierRarityType.B
	},
	{
		["\\xe2R<\\xd9\\xb1g\\xa8S\\xbc\\xb2"] = "D8\\xa9\\x91\\xb2̼\\xcc5\\xae\\xa6\n9",
		rarity = GachaPoolContentConfig.PoolTierRarityType.C
	}
}
C_LinLangClosetPanelStore = DefClass("C_LinLangClosetPanelStore", C_LinLangClosetPanelStore, C_StoreGroup)
GroupName2Class.LinLangClosetPanelStore = C_LinLangClosetPanelStore
local M = C_LinLangClosetPanelStore

M.ctor = function(self)
	self.validGachaPools = {}
	self.currentPoolIndex = 1
	self.currentPoolCfg = nil
	self.endTimestamp = 0
	self.tabDataList = {}
	self.parentStore = nil
	self.gachaSafetyTimer = nil
	self.isGachaInProgress = false
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.validGachaPools = {}
	self.currentPoolIndex = 1
	self.currentPoolCfg = nil
	self.endTimestamp = 0
	self.tabDataList = {}

	self.ClearGachaLock(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.parentStore = data and data.parentStore or nil

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if self.parentStore and self.parentStore.rootArea then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.parentStore.rootArea
		else
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootGo:GetComponent("UNavigationArea")
		end
	end

	self.InitGachaPools(self)
	self.UpdateTabList(self)

	if #self.validGachaPools <= 0 then
		self.bindData.tabList:SelectItem(0, true)
	end

	self.bindData.poolBtnText = LTConfig.TextConfig.GetConfig(73977015).Text
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitGachaPools = function(self)
	self.validGachaPools = gMallManager:BuildSortedGachaPools(1)
end

M.ShowPoolInfo = function(self, poolCfg)
	if not poolCfg then
		return
	end

	self.currentPoolCfg = poolCfg
	self.bindData.titleText = poolCfg.Name or ""
	local sceneId = poolCfg.SceneId
	local hasScene = sceneId and sceneId == 0

	if hasScene and self.parentStore then
		local gachaCfg = GachaConfig.GetConfig(poolCfg.Id)
		local commodityId = gachaCfg and gachaCfg.GrandPrizeCommodityId or 0
		local commodityCfg = commodityId <= 0 and MallCommodityConfig.GetConfig(commodityId) or nil
		local commodityData = commodityCfg and gMallManager:GenMallCommodityItem(commodityCfg) or nil

		if self.parentStore.TryOnFashion and commodityData then
			self.parentStore:TryOnFashion(commodityData)
		else
			self.parentStore:ApplyMallSceneById(sceneId)
			self.parentStore:SetModelBtnActive(false)
		end
	end

	if self.bindData.spineParent then
		self.bindData.spineParent.gameObject:SetActive(not hasScene)
	end

	if hasScene then
		self.bindData.spineActive = false
	else
		self.bindData.spineActive = self.currentPoolIndex ~= 1
	end

	self.bindData.bgIconId = poolCfg.BackgroundImage or 0

	if self.bindData.playBtn then
		self.bindData.playBtn.gameObject:SetActive(self.currentPoolCfg.ButtonVideo == 0)
	end

	self.UpdateMoneyIcon(self)
	self.InitCountDown(self)
	self.UpdateInfoTexts(self)
	self.UpdateGachaButtonState(self)
	self.WarmupNeighborPoolScenes(self, poolCfg.Id)
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

	slot3 = gMallSceneManager

	slot3:ScheduleWarmupNeighborScenes(self.validGachaPools, centerIndex, function (poolCfg)
		return poolCfg and poolCfg.SceneId or 0
	end)
end

M.GetHighestTierContents = function(self, poolId)
	local itemsByTier = {}

	for j = 0, GachaPoolContentConfig.count - 1 do
		local content = GachaPoolContentConfig.LoadAt(j)

		if content and content.PoolId ~= poolId and (content.weight or 0) <= 0 then
			local rarity = content.PoolTierRarity
			itemsByTier[rarity] = itemsByTier[rarity] or {}

			table.insert(itemsByTier[rarity], content)
		end
	end

	for _, def in ipairs(TIER_DEFS) do
		if itemsByTier[def.rarity] then
			return def, itemsByTier[def.rarity]
		end
	end

	return nil, {}
end

M.CheckGrandPrizeLocked = function(self)
	if not self.currentPoolCfg then
		return false
	end

	local prizePoolIds = self.currentPoolCfg.PrizePoolIds

	if not prizePoolIds or #prizePoolIds ~= 0 then
		return false
	end

	local poolId = prizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)

	if not poolCfg then
		return false
	end

	local highestDef, contentList = self.GetHighestTierContents(self, poolId)

	if not highestDef then
		return false
	end

	local samplingMethod = poolCfg[highestDef.samplingField] or 0

	if samplingMethod == SamplingMethodType.Collection then
		return false
	end

	local playerPoolInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos.PoolInfos[poolId]

	if not playerPoolInfo or not playerPoolInfo.WonItemIds then
		return false
	end

	for i = 1, #contentList do
		if not playerPoolInfo.WonItemIds[contentList[i].Id] then
			return false
		end
	end

	return true
end

M.UpdateMoneyIcon = function(self)
	if not self.currentPoolCfg then
		return
	end

	local prizePoolIds = self.currentPoolCfg.PrizePoolIds
	local poolId = prizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)
	local moneyCfg = ConsumableConfig.GetConfig(poolCfg.MoneyId)
	self.bindData.iconOneId = moneyCfg.SItemIconId

	if self.CheckGrandPrizeLocked(self) then
		self.bindData.price1Text = "999999"
	else
		local currentDrawCount = 0
		local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

		if playerGachaInfo and playerGachaInfo.PoolInfos then
			local poolInfo = playerGachaInfo.PoolInfos[poolId]

			if poolInfo then
				currentDrawCount = poolInfo.DrawCount or 0
			end
		end

		local cost = gGachaManager:GetCostByDrawCount(poolCfg.CostCount, currentDrawCount + 1)
		self.bindData.price1Text = tostring(cost)
	end
end

M.UpdateGachaButtonState = function(self)
	if not self.currentPoolCfg then
		return
	end

	local isLocked = self.CheckGrandPrizeLocked(self)
	self.bindData.oneGachaBtn.interactable = not isLocked
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

M.UpdateInfoTexts = function(self)
	local prizePoolIds = self.currentPoolCfg.PrizePoolIds

	if not prizePoolIds or #prizePoolIds ~= 0 then
		return
	end

	local poolId = prizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)

	if not poolCfg then
		return
	end

	local highestDef, contentList = self.GetHighestTierContents(self, poolId)
	local itemName = ""

	if highestDef and contentList[1] then
		itemName = gGachaManager:GetGachaPoolContentName(contentList[1])
	end

	local textCfg1 = TextConfig.GetConfig(self.currentPoolCfg.PanelTexts[1] or 73977000)
	self.bindData.info1Text = gString.Format(textCfg1.Text, itemName)
	local textCfg2 = TextConfig.GetConfig(self.currentPoolCfg.PanelTexts[2] or 73977001)
	self.bindData.info2Text = textCfg2.Text

	self:UpdateMoneyIcon()
	self:UpdateGachaButtonState()
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

	self.ShowPoolInfo(self, self.validGachaPools[self.currentPoolIndex])
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

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged"),
		[gEventConstants.GACHA_POOL_COUNT_CHANGE] = self.CreateAction(self, "OnGachaPoolCountChange"),
		[gEventConstants.PANEL_CLOSE] = self.CreateAction(self, "OnPanelClose")
	}
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

	self.UpdateMoneyIcon(self)
	self.UpdateGachaButtonState(self)

	if self.parentStore and self.parentStore.RefreshMoneyDisplay then
		self.parentStore:RefreshMoneyDisplay()
	end
end

M.OnPanelClose = function(self, _, msg)
	if not msg then
		return
	end

	if msg.panelId ~= gPanelId.GACHA_RESULT then
		self.UpdateGachaButtonState(self)
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
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.infoBtn.luaClick = self.CreateAction(self, "OnClickInfoBtn")
	self.bindData.oneGachaBtn.luaClick = self.CreateAction(self, "OnClickOneGachaBtn")
	self.bindData.poolBtn.luaClick = self.CreateAction(self, "OnClickPoolBtn")

	if self.bindData.playBtn then
		self.bindData.playBtn.luaClick = self.CreateAction(self, "OnClickPlayBtn")
	end
end

M.OnClickBackBtn = function(self)
	if self.parentStore and self.parentStore.OnClickBackBtn then
		self.parentStore:OnClickBackBtn()
	else
		gPanelManager:Close(self.m_Id)
	end
end

M.OnClickInfoBtn = function(self)
	if self.currentPoolCfg then
		gPanelManager:CheckShow(gPanelId.GACHA_INFO, {
			["my\\xb4PM\\xb1\\xfaF^cnI"] = 1,
			gachaId = self.currentPoolCfg.Id
		})
	end
end

M.OnClickPoolBtn = function(self)
	gPanelManager:CheckShow(gPanelId.LIN_LANG_CLOSET_POOL, {
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

	self.parentStore:PlayVideo(videoId, gMallManager.VideoLayer.Mid)
end

M.OnClickOneGachaBtn = function(self)
	if self.isGachaInProgress then
		return
	end

	if not self.currentPoolCfg then
		print_error("OnClickOneGachaBtn: 当前卡池配置为空")

		return
	end

	if self.CheckGrandPrizeLocked(self) then
		print_error("OnClickOneGachaBtn: 已抽到大奖，卡池已锁定")
		self.UpdateGachaButtonState(self)

		return
	end

	local prizePoolIds = self.currentPoolCfg.PrizePoolIds
	local poolId = prizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)

	if not poolCfg then
		print_error("OnClickOneGachaBtn: 找不到奖池配置，poolId=", poolId)

		return
	end

	slot4 = gGachaManager
	local currentDrawCount = slot4:GetPoolDrawCount(poolId)
	local costItemId = poolCfg.MoneyId
	slot6 = gGachaManager
	local singleCost = slot6:CalcTotalCost(poolCfg.CostCount, currentDrawCount, 1)

	self:StartGachaLock()

	slot7 = gGachaManager

	slot7:TryDrawGachaWithCostCheck(self.currentPoolCfg.Id, poolId, costItemId, singleCost, 1, function ()
		self:UpdateInfoTexts()
		gDisplayMessageMgr:CloseBombAll()
	end, nil, function ()
		self:ClearGachaLock()
	end)
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
