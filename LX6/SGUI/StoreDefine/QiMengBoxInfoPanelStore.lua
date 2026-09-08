-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\QiMengBoxInfoPanelStore.lua
-- Decompiled from: 00804_QiMengBoxInfoPanelStore.lua_93591dcf35aa.luajit

local GachaConfig = LTConfig.GachaConfig
local GachaPoolConfig = LTConfig.GachaPoolConfig
local GachaPoolContentConfig = LTConfig.GachaPoolContentConfig
local GachaPoolTierRuleConfig = LTConfig.GachaPoolTierRuleConfig
local SamplingMethodType = {
	[":A\\x9f\\x87\\x97D"] = 1,
	["pU±\\x81\\xac\r\\xc6\\xe6"] = 2,
	["\\x98\\xa5\\xa5n?\\xec7"] = 0
}
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

local FormatGachaTime = function(timeObj)
	if not timeObj then
		return ""
	end

	return string.format("%04d-%02d-%02d %02d:%02d", timeObj.year or 0, timeObj.month or 0, timeObj.day or 0, timeObj.hour or 0, timeObj.minute or 0)
end

C_QiMengBoxInfoPanelStore = DefClass("C_QiMengBoxInfoPanelStore", C_QiMengBoxInfoPanelStore, C_StoreGroup)
GroupName2Class.QiMengBoxInfoPanelStore = C_QiMengBoxInfoPanelStore
local M = C_QiMengBoxInfoPanelStore

M.ctor = function(self)
	self.gachaId = nil
	self.gachaCfg = nil
	self.gachaItemList = {}
	self.boxGachaType = 1
	self._closingAnim = false
	self._pendingNavToTop = false
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.tabBtnCtrlEnum = {
		["\\xbb&!(P\\x94R\\xcd8\\xb8\\xa0"] = 2,
		["\\xaf&/=y\\x9fH\\xd5>\\xbe\\xa0"] = 1,
		["H7q^"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.tabBtnCtrlEnum = nil
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
	self.gachaId = nil
	self.gachaCfg = nil
	self.gachaItemList = {}
	self.boxGachaType = 1
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId

	if not data or not data.gachaId then
		print_error("QiMengBoxInfoPanelStore:OnShow 缺少 gachaId 参数")

		return
	end

	self.gachaId = data.gachaId
	self.gachaCfg = GachaConfig.GetConfig(self.gachaId)
	self.boxGachaType = data.boxGachaType or 1
	self.bindData.titleText = self.gachaCfg.Name
	local startTime = self.gachaCfg.StartTime
	local endTime = self.gachaCfg.EndTime

	if gMallManager:IsTimeEmpty(startTime) and gMallManager:IsTimeEmpty(endTime) then
		self.bindData.timeText = ""
	else
		self.bindData.timeText = FormatGachaTime(startTime) .. " ~ " .. FormatGachaTime(endTime)
	end

	local grandPrizeName = self.GetGrandPrizeName(self)
	local ruleTextCfg = LTConfig.TextConfig.GetConfig(self.gachaCfg.RuleText)

	if ruleTextCfg then
		self.bindData.contentText = gString.Format(ruleTextCfg.Text, grandPrizeName)
	end

	self.bindData.tabBtnCtrl = self.tabBtnCtrlEnum.Rule
	local subTitle2Id = self.boxGachaType ~= 1 and 73977007 or 73977045
	self.bindData.subTitle2Text = LTConfig.TextConfig.GetConfig(subTitle2Id).Text

	self:InitGachaItemList()
	self.bindData.gachaItemList:SetSimpleList(#self.gachaItemList)

	self.bindData.tab1BtnText = LTConfig.TextConfig.GetConfig(73977019).Text
	self.bindData.tab2BtnText = LTConfig.TextConfig.GetConfig(73977020).Text
end

M.OnClose = function(self)
	self.gachaId = nil
	self.gachaCfg = nil
	self.gachaItemList = {}
	self.boxGachaType = 1
	self._closingAnim = false
	self._pendingNavToTop = false
end

M.OnActiveDeviceChange = function(self, device)
	if self.bindData.tabBtnCtrl ~= self.tabBtnCtrlEnum.Probability then
		self.TrySelectFirstGachaItem(self)
	end
end

M.GetDrawsSinceLastResetForRule = function(self, ruleId)
	if not ruleId or ruleId ~= 0 then
		return 0
	end

	local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

	if playerGachaInfo and playerGachaInfo.PityInfos then
		local pityInfo = playerGachaInfo.PityInfos[ruleId]

		if pityInfo then
			return pityInfo.DrawsSinceLastReset or 0
		end
	end

	return 0
end

M.CalculateRealTimeTierProbability = function(self, tierCfg, poolId)
	if not tierCfg then
		return 0
	end

	local probability = 0
	local ruleId = tierCfg.RuleId

	if not ruleId or ruleId ~= 0 then
		probability = 0

		return probability
	end

	local ruleCfg = GachaPoolTierRuleConfig.GetConfig(ruleId)

	if not ruleCfg then
		return 0
	end

	local ruleType = ruleCfg.RuleType

	if ruleType ~= GachaPoolTierRuleConfig.RuleTypeType.Pity then
		local drawsSinceLastReset = self.GetDrawsSinceLastResetForRule(self, ruleId)
		local nextDraw = drawsSinceLastReset + 1

		if ruleCfg.PityThreshold < nextDraw then
			probability = 1
		else
			local baseProb = ruleCfg.BaseProbability / 100000

			if ruleCfg.RampStartDraw < nextDraw then
				probability = baseProb + (nextDraw - ruleCfg.RampStartDraw + 1) * ruleCfg.ProbabilityIncrement / 100000
			else
				probability = baseProb
			end
		end
	elseif ruleType ~= GachaPoolTierRuleConfig.RuleTypeType.Exclusive then
		if not ruleCfg.GrandPrizeProbability then
			return 0
		end

		local poolInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos.PoolInfos[poolId]
		local nextDrawCount = (poolInfo and poolInfo.DrawCount or 0) + 1
		local index = nextDrawCount

		if index <= 0 and index < #ruleCfg.GrandPrizeProbability then
			probability = ruleCfg.GrandPrizeProbability[index] / 100000
		else
			print_error("Exclusive rule probability not found for draw: " .. tostring(nextDrawCount))
		end
	end

	return math.min(probability, 1)
end

M.GetGrandPrizeName = function(self)
	if not self.gachaCfg or not self.gachaCfg.PrizePoolIds or #self.gachaCfg.PrizePoolIds ~= 0 then
		return ""
	end

	local poolId = self.gachaCfg.PrizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)

	if not poolCfg then
		return ""
	end

	local tierList = BuildTierList(poolCfg)

	if #tierList ~= 0 then
		return ""
	end

	local highestTier = tierList[1]

	for j = 0, GachaPoolContentConfig.count - 1 do
		local content = GachaPoolContentConfig.LoadAt(j)

		if content and content.PoolId ~= poolId and content.PoolTierRarity ~= highestTier.TierRarity then
			return gGachaManager:GetGachaPoolContentName(content)
		end
	end

	return ""
end

M.InitGachaItemList = function(self)
	self.gachaItemList = {}

	if not self.gachaCfg or not self.gachaCfg.PrizePoolIds then
		return
	end

	local gachaType = self.gachaCfg.GachaType or 0
	local poolId = self.gachaCfg.PrizePoolIds[1].id
	local poolCfg = GachaPoolConfig.GetConfig(poolId)

	if not poolCfg then
		return
	end

	local tierList = BuildTierList(poolCfg)

	if #tierList ~= 0 then
		return
	end

	local playerPoolInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos.PoolInfos[poolId]
	local wonItemIds = playerPoolInfo and playerPoolInfo.WonItemIds or {}
	local wonItemCount = 0

	for _ in pairs(wonItemIds) do
		wonItemCount = wonItemCount + 1
	end

	local tiersData = {}

	for i = 1, #tierList do
		tiersData[i] = {
			["\\x8b;4>t\\xaaD\\xd00\\xa2\\xad"] = 0,
			cfg = tierList[i],
			items = {}
		}
	end

	for j = 0, GachaPoolContentConfig.count - 1 do
		local content = GachaPoolContentConfig.LoadAt(j)

		if content and content.PoolId ~= poolId and (content.IsFullDisplay == true or gachaType ~= 1) then
			for i = 1, #tiersData do
				if tiersData[i].cfg.TierRarity ~= content.PoolTierRarity then
					table.insert(tiersData[i].items, content)

					break
				end
			end
		end
	end

	local isType3 = self.gachaCfg.GachaType ~= 3
	local remainingProbability = 1

	for i = 1, #tiersData do
		local tierData = tiersData[i]
		local tierCfg = tierData.cfg

		if #tierData.items == 0 then
			local conditionalHitProb = self.CalculateRealTimeTierProbability(self, tierCfg, poolId)

			if not tierCfg.RuleId or tierCfg.RuleId ~= 0 then
				conditionalHitProb = 1
			end

			local tierHitProbability = remainingProbability * conditionalHitProb
			remainingProbability = remainingProbability * (1 - conditionalHitProb)

			if remainingProbability >= 0 then
				remainingProbability = 0
			end

			tierData.totalWeight = 0
			local samplingMethod = tierCfg.SamplingMethod

			if samplingMethod ~= SamplingMethodType.Standard then
				for _, itemContent in ipairs(tierData.items) do
					tierData.totalWeight = tierData.totalWeight + (itemContent.weight or 0)
				end
			else
				for _, itemContent in ipairs(tierData.items) do
					if not wonItemIds[itemContent.Id] then
						tierData.totalWeight = tierData.totalWeight + (itemContent.weight or 0)
					end
				end
			end

			for _, itemContent in ipairs(tierData.items) do
				local currentWeight = itemContent.weight or 0
				local isWon = wonItemIds[itemContent.Id] or false

				if samplingMethod == SamplingMethodType.Standard and isWon then
					currentWeight = 0
				end

				local itemProbabilityInTier = tierData.totalWeight <= 0 and currentWeight / tierData.totalWeight or 0
				local finalProbability = itemProbabilityInTier * tierHitProbability

				if isType3 then
					finalProbability = (itemContent.GachaDisplayProbability or 0) / 10000
				end

				local itemName = gGachaManager:GetGachaPoolContentName(itemContent)
				local itemId = 0

				if itemContent.dropId and itemContent.dropId <= 0 then
					local itemList = gCommonItemManager:ConvertDropToFakeItem(itemContent.dropId, 1)
					local firstItem = itemList and itemList[1]

					if firstItem and firstItem.Id then
						itemId = firstItem.Id
					end
				end

				table.insert(self.gachaItemList, {
					itemId = itemId,
					iconId = itemContent.SmallIcon or itemContent.icondisplayimage or 0,
					count = itemContent.Quantity or 1,
					quality = itemContent.Quality or 0,
					name = itemName,
					isGrandPrize = GachaPoolContentConfig.PoolTierRarityType.S > itemContent.PoolTierRarity,
					isWon = isWon,
					probability = finalProbability
				})
			end
		end
	end

	table.sort(self.gachaItemList, function (a, b)
		if a.quality == b.quality then
			return b.quality <= a.quality
		end

		return a.probability <= b.probability
	end)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.tabBtn.luaClick = self.CreateAction(self, "OnClickTabBtn")
	self.bindData.gachaItemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderGachaItemListItem")
	self.bindData.gachaItemList.luaLayoutSet = self.CreateAction(self, "OnGachaItemListLayoutSet")
end

M.OnClickBackBtn = function(self)
	if self._closingAnim then
		return
	end

	self._closingAnim = true

	gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_NewCommonWindow_Close", self.panelId)
end

M.OnClickTabBtn = function(self)
	if self.bindData.tabBtnCtrl ~= self.tabBtnCtrlEnum.Rule then
		self.bindData.tabBtnCtrl = self.tabBtnCtrlEnum.Probability

		self.TrySelectFirstGachaItem(self)
	else
		self.bindData.tabBtnCtrl = self.tabBtnCtrlEnum.Rule
		self._pendingNavToTop = false
	end
end

M.TrySelectFirstGachaItem = function(self)
	if not gClientUtils.CheckIsGamePadMode() then
		self._pendingNavToTop = false

		return
	end

	if #self.gachaItemList ~= 0 then
		self._pendingNavToTop = false

		return
	end

	self._pendingNavToTop = true

	if self.bindData.gachaItemList:SetNavSelectToTop(true) then
		self._pendingNavToTop = false
	end
end

M.OnGachaItemListLayoutSet = function(self)
	if not self._pendingNavToTop then
		return
	end

	if self.bindData.gachaItemList:SetNavSelectToTop(true) then
		self._pendingNavToTop = false
	end
end

M.OnSimpleRenderGachaItemListItem = function(self, btn, index)
	local luaIndex = index + 1
	local itemData = self.gachaItemList[luaIndex]

	if not itemData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.nameText = itemData.name
	local probability = itemData.probability or 0
	local probabilityPercent = probability * 100

	if probabilityPercent < 0.01 or probabilityPercent ~= 0 then
		store.probabilityText = string.format("%.2f%%", probabilityPercent)
	else
		store.probabilityText = string.format("%.4f%%", probabilityPercent)
	end

	if itemData.isWon and self.boxGachaType ~= 1 then
		store.haveCtrl = 1
		store.haveText = LTConfig.TextConfig.GetConfig(73977029).Text
	else
		store.haveCtrl = 0
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = itemData.itemId or 0
	})

	gCommonItemManager:OnCommonItemRender(store.rewardItem, index, renderData)
end
