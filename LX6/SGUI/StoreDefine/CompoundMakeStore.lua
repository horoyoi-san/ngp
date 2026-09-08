-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CompoundMakeStore.lua
-- Decompiled from: 01544_CompoundMakeStore.lua_dcc5e3066e9e.luajit

local MoneyType = UX.Game.MoneyType
local CompoundConfig = LTConfig.CompoundConfig
local CompoundCraftingTableConfig = LTConfig.CompoundCraftingTableConfig
local TextConfig = LTConfig.TextConfig
C_CompoundMakeStore = DefClass("C_CompoundMakeStore", C_CompoundMakeStore, C_StoreGroup)
GroupName2Class.CompoundMakeStore = C_CompoundMakeStore
local M = C_CompoundMakeStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}
local BTN_STATE = {
	["I\\x8e\\xb3\\xb0Ѡ\\xca.\\xa7;.\\xbd8"] = 4,
	["\\x84\\xa6\\x87c3\\xf7'"] = 6,
	["nHblW23"] = 3,
	["mHxL@0"] = 1,
	["\\x88\\xbe\n\\xa7N1\\xe9="] = 5,
	["\\x82\\xa2)\\xa4i5\\xfb7"] = 2,
	["2G\\x83\\x83\\x82M"] = 0
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.data = {}
	self.targetItem = {}
	self.targetTab = 0
	self.targetCount = 1
	self.isAscending = true
	self.isCompounding = false
	self.craftingTableId = 0
	self.formulaId = 0
	self.currentUpgradeLevelConfigId = 0
	self.availableCompounds = {}
	self.pandingCrafts = {}
	self.tabListData = {}
	self.itemListData = {}
	self.descListData = {}
	self.consumeListData = {}
	self.upgradeConsumeListData = {}
	self.mgr = gCompoundManager
	self.parent = nil
	self.needUpdateCd = false
	self.cdCompoundId = nil
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "RefreshItemNum"),
		[gEventConstants.COMPOUND_AVAILABLE_CHANGE] = self.CreateAction(self, "OnRefreshPage"),
		[gEventConstants.COMPOUND_COMPLETE] = self.CreateAction(self, "OnCompoundComplete"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnRewardPanelClose")
	}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)

	self.bindData.descList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderDescItem")
	self.bindData.descList.luaSimpleClick = self.CreateAction(self, "OnDescItemClick")

	self.bindData.descList.onGetTIndex = function(index)
		local data = self.descListData[index + 1]

		return data.tIndex or 0
	end

	self.bindData.consumeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderConsumeListItem")

	self.bindData.consumeList.onGetTIndex = function(index)
		local data = self.consumeListData[index + 1]

		return data.tIndex or 0
	end

	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnCommonItemRender")
	self.bindData.itemList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnDynamicRenderItemListItem")
	self.bindData.itemList.luaSelectedChanged = self.CreateAction(self, "OnItemListSelectedChange")

	self.bindData.itemList.onGetTIndex = function(index)
		local data = self.itemListData[index + 1]

		return data.tIndex or 0
	end

	self.bindData.makeBtn.luaClick = self.CreateAction(self, "OnMakeBtnClick")
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnClick")
end

M.OnEnable = function(self)
end

local SHOW_PROGRESSLINE = 1
local HIDE_PROGRESSLINE = 0

M.OnUpdate = function(self)
	if self.needUpdateCd then
		local periodSeconds = math.ceil(self.mgr:GetPeriodResetRemainingSeconds(self.cdCompoundId))

		if periodSeconds <= 0 then
			local h, m, s = gTimeUtils:GetHourMinSecond(periodSeconds)
			self.bindData.limitLeftTime = string.format(TextConfig.GetConfig(73971602).Text, h, m, s)
		else
			self.needUpdateCd = false
			self.cdCompoundId = nil
			self.bindData.limitLeftTime = ""

			self.OnRefreshInfo(self)
			self.RefreshItemList(self)
		end
	end

	if self.targetItem and self.pandingCrafts[self.targetItem.compoundId] then
		local craft = self.pandingCrafts[self.targetItem.compoundId]

		if craft.endTime >= gCS.TimeManager.ServerUnixTime then
			if craft.rewards then
				gDropManager:ShowRewardWindow({
					Param = craft.rewards
				})
			elseif not craft.isLimitItem then
				self.mgr:AskItemStartCompound(self.targetItem.compoundId, self.craftingTableId, craft.compoundCount, {}, nil)
			end

			self.pandingCrafts[self.targetItem.compoundId] = nil

			self.bindData.progressLine:ProgressToValue(0)

			self.bindData.showProgressCtrl = HIDE_PROGRESSLINE
		else
			if self.bindData.btnState == BTN_STATE.CoolDown then
				self.bindData.btnState = BTN_STATE.CoolDown
			end

			local totalTime = craft.endTime - craft.startTime
			local elapsed = gCS.TimeManager.ServerUnixTime - craft.startTime
			local progress = totalTime <= 0 and math.min(elapsed / totalTime, 1) or 1

			self.bindData.progressLine:ProgressToValue(progress)

			self.bindData.showProgressCtrl = SHOW_PROGRESSLINE
		end
	end
end

M.OnCompoundComplete = function(self, eventId, data)
	local compoundId = data.CompoundId
	local isCompound = data.IsCompound

	if not self.targetItem or self.targetItem.compoundId == compoundId then
		return
	end

	if not isCompound then
		self.OnRefreshInfo(self)
		self.RefreshItemList(self)

		return
	end
end

M.OnRewardPanelClose = function(self, eventId, panelId)
	if panelId == gPanelId.S_COMMON_REWARD_WINDOW then
		return
	end

	self.isCompounding = false

	self.OnRefreshInfo(self)

	if not self.targetItem or not self.targetItem.compoundId then
		return
	end

	if not self.CheckMaterialEnough(self, self.targetItem.material, 1) then
		self.RefreshItemList(self)
	end
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if data then
		self.craftingTableId = data.craftingTableId or 0
		self.formulaId = data.formulaId or 0
	end

	gCompoundManager:SetAvailableCompounds(self.craftingTableId)

	if self.SubGroup and self.SubGroup.MoneyTemplateStore then
		self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)
	end

	if self.formulaId == 0 then
		self.targetTab = self.mgr:GetTabIndexByFormula(self.formulaId)
	end

	self.InitTabList(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitTabList = function(self)
	local tabData = self.mgr:GetCompoundTab(self.targetTab)

	for i = 1, #tabData do
		local tabCfg = LTConfig.CompoundTabConfig.GetConfig(tabData[i].tabId)
		tabData[i].guideId = tabCfg and tabCfg.GuideId or ""
	end

	self.SubGroup.CommonTabSingleStore:SetData(tabData, nil, self.targetTab, nil, self:CreateAction("OnTabSelectedChanged"))
end

M.RefreshItemList = function(self)
	self.bindData.showRight = BOOL2CTL[#self.availableCompounds >= 0]

	table.sort(self.availableCompounds, function (a, b)
		if a.isLock == b.isLock then
			return not a.isLock
		end

		local aEnough = self:CheckMaterialEnough(a.material, 1)
		local bEnough = self:CheckMaterialEnough(b.material, 1)

		if aEnough == bEnough then
			return aEnough
		end

		if a.isBan == b.isBan then
			return not a.isBan
		end

		if a.quality == b.quality then
			if self.isAscending then
				return b.quality <= a.quality
			else
				return a.quality <= b.quality
			end
		end

		return a.itemId <= b.itemId
	end)

	self.itemListData = table.clone(self.availableCompounds)
	local maxNum = self.bindData.itemList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.itemListData / maxNum.x), maxNum.y)

	while #self.itemListData >= maxNum.x * col do
		table.insert(self.itemListData, {
			["a\\x9f\\x8a\\x86Y"] = 1
		})
	end

	self.bindData.itemList:SetSimpleList(#self.itemListData)
	self.bindData.itemList:SetNavSelectToTop()

	local selectIndex = 0

	if self.targetItem and self.targetItem.compoundId then
		for i, item in ipairs(self.itemListData) do
			if item.compoundId ~= self.targetItem.compoundId then
				selectIndex = i - 1

				break
			end
		end
	end

	self.bindData.itemList:SelectItem(selectIndex)
end

M.OnRefreshPage = function(self)
	if self.formulaId == 0 then
		self.targetItem = {
			compoundId = self.formulaId
		}
		self.targetTab = self.mgr:GetTabIndexByFormula(self.formulaId)
		self.formulaId = 0
	end

	self.availableCompounds = self.mgr:GetAvailableCompounds(self.targetTab + 1, self.targetItem or {})
	self.targetItem = nil

	self:RefreshItemList()

	self.bindData.titleLabel = self.mgr:GetPanelSubTitle(self.targetTab + 1)
end

M.OnRefreshInfo = function(self)
	self.targetCount = 1
	local hasItem = not table.isNilOrEmpty(self.targetItem)
	self.bindData.showRight = BOOL2CTL[hasItem]

	if not hasItem then
		return
	end

	if not self.RefreshItemBaseInfo(self) then
		return
	end

	local maxMatCost = self.RefreshMat(self)
	local maxMoneyCost = self.CalculateMaxMoneyCost(self)
	local maxRemaining = self.RefreshCompoundCountLimit(self)
	local maxOwnRemain = self.CalculateOwnLimit(self)

	self.RefreshButtonAndSlider(self, maxMatCost, maxMoneyCost, maxRemaining, maxOwnRemain)
end

M.RefreshItemBaseInfo = function(self)
	self.data = gCommonItemManager:TryGetItemInfo({
		["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
		itemId = self.targetItem.itemId
	})
	self.cfg = LTConfig.CompoundConfig.GetConfig(self.targetItem.compoundId)

	if table.isNilOrEmpty(self.data) or not self.cfg then
		return false
	end

	self.bindData.quality = self.data.quality
	self.bindData.iconId = self.data.iconId

	self:OnRefrehNameInfo()

	self.descListData = {}
	local hasSource = gCommonItemManager:GetItemDescList(self.data, self.descListData)

	if not hasSource and #self.descListData <= 0 then
		table.remove(self.descListData, 1)
	end

	self.bindData.descList:SetSimpleList(#self.descListData)

	return true
end

M.CalculateMaxMoneyCost = function(self)
	if not self.targetItem.cost or self.targetItem.cost < 0 then
		return math.huge
	end

	return math.floor(gUIUtils:GetMoneyByType(MoneyType.Money) / self.targetItem.cost)
end

M.RefreshCompoundCountLimit = function(self)
	local compoundId = self.targetItem.compoundId
	local remaining = self.mgr:GetRemainingCompoundCount(compoundId)
	local hasLimit = remaining < 0
	local compoundCfg = LTConfig.CompoundConfig.GetConfig(compoundId)
	local itemId = compoundCfg and compoundCfg.TargetBindId and compoundCfg.TargetBindId == 0 and compoundCfg.TargetBindId or self.targetItem.itemId
	local isTarkov = self:IsExtractionShooterDomain()
	self.bindData.haveCount = string.format(TextConfig.GetConfig(73971600).Text, gCommonItemManager:GetPackItemNum(itemId, isTarkov))
	self.bindData.hasTimesLimitCtrl = hasLimit and 1 or 0

	if hasLimit then
		self.bindData.limitLeftNum = string.format(TextConfig.GetConfig(73971601).Text, remaining)

		self.RefreshPeriodTime(self, compoundId)
	else
		self.bindData.limitLeftTime = ""
		self.needUpdateCd = false
		self.cdCompoundId = nil
	end

	return hasLimit and remaining or math.huge
end

M.RefreshPeriodTime = function(self, compoundId)
	local periodSeconds = math.ceil(self.mgr:GetPeriodResetRemainingSeconds(compoundId))

	if periodSeconds <= 0 then
		local h, m, s = gTimeUtils:GetHourMinSecond(periodSeconds)
		self.bindData.limitLeftTime = string.format(TextConfig.GetConfig(73971602).Text, h, m, s)
		self.needUpdateCd = true
		self.cdCompoundId = compoundId
	else
		self.bindData.limitLeftTime = ""
		self.needUpdateCd = false
		self.cdCompoundId = nil
	end
end

M.CalculateOwnLimit = function(self)
	local compoundId = self.targetItem.compoundId
	local compoundCfg = LTConfig.CompoundConfig.GetConfig(compoundId)
	local itemId = compoundCfg and compoundCfg.TargetBindId and compoundCfg.TargetBindId == 0 and compoundCfg.TargetBindId or self.targetItem.itemId
	local consumeCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
	local typeCfg = consumeCfg and LTConfig.ConsumableTypeConfig.GetConfig(consumeCfg.SubType)
	local maxHaveNum = typeCfg and typeCfg.MaxHaveNum and typeCfg.MaxHaveNum <= 0 and typeCfg.MaxHaveNum or nil

	if not maxHaveNum then
		return math.huge
	end

	local currentHaveNum = gCommonItemManager:GetPackItemNum(itemId, self:IsExtractionShooterDomain())

	if maxHaveNum < currentHaveNum then
		return 0
	end

	local perCraftCount = self.GetPerCraftCount(self, compoundCfg, itemId)

	return math.floor((maxHaveNum - currentHaveNum) / perCraftCount)
end

M.GetPerCraftCount = function(self, compoundCfg, itemId)
	if not compoundCfg or not compoundCfg.DropId then
		return 1
	end

	local rewardList = gCommonItemManager:GetRewardList(compoundCfg.DropId)

	if not rewardList then
		return 1
	end

	for _, reward in ipairs(rewardList) do
		local rewardCfg = LTConfig.ConsumableConfig.GetConfig(reward.templateId)

		if reward.templateId ~= itemId or rewardCfg and rewardCfg.BindId ~= itemId then
			return math.max(1, reward.count or 1)
		end
	end

	return 1
end

M.RefreshButtonAndSlider = function(self, maxMatCost, maxMoneyCost, maxRemaining, maxOwnRemain)
	local maxCost = math.min(maxMatCost, maxMoneyCost, maxRemaining, maxOwnRemain)

	if self.targetItem.unique and self.targetItem.unique <= 0 then
		maxCost = math.min(maxCost, self.targetItem.unique)
	end

	if maxCost ~= math.huge then
		maxCost = 999
	end

	local sliderMax = math.max(math.min(math.floor(maxCost), 999), 1)
	self.bindData.minCompoundNum = 1
	self.bindData.maxCompoundNum = sliderMax

	if self.targetItem.isLock then
		self.bindData.btnState = BTN_STATE.IsLocked
		self.bindData.unlockLabel = self.targetItem.unlockStr
	elseif maxOwnRemain ~= 0 then
		self.bindData.btnState = BTN_STATE.OwnLimit
	elseif maxRemaining ~= 0 then
		self.bindData.btnState = BTN_STATE.NotCompoundCount
	elseif maxMoneyCost >= 1 then
		self.bindData.btnState = BTN_STATE.MoneyLack
	elseif maxMatCost >= 1 then
		self.bindData.btnState = BTN_STATE.NotEnough
	else
		self.bindData.btnState = BTN_STATE.Normal
	end

	if self.SubGroup and self.SubGroup.CommonBuyNumSliderStore then
		self.SubGroup.CommonBuyNumSliderStore:SetData({
			range = {
				1,
				sliderMax
			},
			data = {
				["\\xb8\\xa5 \\xbbY7\\xe46"] = 1,
				moneyId = MoneyType.Money,
				price = self.targetItem.cost or 0
			},
			valChangeCallback = self:CreateAction("OnBuyNumChange")
		})
	end
end

M.RefreshMat = function(self)
	self.consumeListData = {}
	local count = math.huge

	if not self.targetItem or not self.targetItem.material then
		local maxNum = self.bindData.consumeList:GetMaxRowAndColCount(0)
		local col = maxNum.y or 1

		while #self.consumeListData >= maxNum.x * col do
			table.insert(self.consumeListData, {
				["a\\x9f\\x8a\\x86Y"] = 1
			})
		end

		self.bindData.consumeList:SetSimpleList(#self.consumeListData)

		return 0
	end

	local isTarkov = self.IsExtractionShooterDomain(self)

	for i = 1, #self.targetItem.material do
		local mat = self.targetItem.material[i]
		local currentNum = gCommonItemManager:GetItemNum(mat.BindId, isTarkov)
		local targetNum = mat.Num * self.targetCount
		local numStr = nil

		if currentNum >= targetNum then
			numStr = "#R" .. currentNum .. "#z/" .. targetNum
		else
			numStr = currentNum .. "/" .. targetNum
		end

		local ele = {
			["iy\\xbetI\\x81\\xfaH}TkA"] = true,
			["a\\x9f\\x8a\\x86Y"] = 0,
			itemId = mat.BindId,
			itemNum = numStr
		}
		count = math.min(count, math.floor(currentNum / mat.Num))

		table.insert(self.consumeListData, gCommonItemManager:GetItemRenderData(ele))
	end

	table.sort(self.consumeListData, function (a, b)
		if a.quality and b.quality and a.quality == b.quality then
			return b.quality <= a.quality
		end

		return b.itemId <= a.itemId
	end)

	local maxNum = self.bindData.consumeList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.consumeListData / maxNum.x), maxNum.y)

	self.bindData.consumeList:SetSimpleList(#self.consumeListData)

	return count
end

local PadAndSetList = function(list, data)
	local maxNum = list.GetMaxRowAndColCount(list, 0)
	local col = math.max(math.ceil(#data / maxNum.x), maxNum.y)

	while #data >= maxNum.x * col do
		table.insert(data, {
			["a\\x9f\\x8a\\x86Y"] = 1
		})
	end

	list.SetSimpleList(list, #data)
end

M.RefreshUpgradeMat = function(self, levelCfg)
	self.upgradeConsumeListData = {}

	if not levelCfg or table.isNilOrEmpty(levelCfg.Material) then
		PadAndSetList(self.bindData.upgradeConsumeList, self.upgradeConsumeListData)

		return true
	end

	local canAfford = true
	local isTarkov = self.IsExtractionShooterDomain(self)

	for i = 1, #levelCfg.Material do
		local mat = levelCfg.Material[i]
		local currentNum = gCommonItemManager:GetItemNum(mat.BindId, isTarkov)
		local targetNum = mat.Num
		local numStr = nil

		if currentNum >= targetNum then
			numStr = "#R" .. currentNum .. "#z/" .. targetNum
			canAfford = false
		else
			numStr = currentNum .. "/" .. targetNum
		end

		table.insert(self.upgradeConsumeListData, gCommonItemManager:GetItemRenderData({
			["a\\x9f\\x8a\\x86Y"] = 0,
			itemId = mat.BindId,
			itemNum = numStr
		}))
	end

	table.sort(self.upgradeConsumeListData, function (a, b)
		if a.quality == b.quality then
			return b.quality <= a.quality
		end

		return b.itemId <= a.itemId
	end)
	PadAndSetList(self.bindData.upgradeConsumeList, self.upgradeConsumeListData)

	return canAfford
end

M.OnRenderDescItem = function(self, btn, index)
	local data = self.descListData[index + 1]

	if data then
		gCommonItemManager:OnRenderDescItem(btn, index, data)
	end
end

M.OnDescItemClick = function(self, btn, index)
	local data = self.descListData[index + 1]

	if data then
		gCommonItemManager:OnDescItemClick(btn, data)
	end
end

M.OnRenderConsumeListItem = function(self, btn, index)
	local data = self.consumeListData[index + 1]

	if data and data.itemId then
		gCommonItemManager:OnCommonItemRender(btn, index, data)
	end
end

M.OnRenderUpgradeConsumeListItem = function(self, btn, index)
	local data = self.upgradeConsumeListData[index + 1]

	if data and data.itemId then
		gCommonItemManager:OnCommonItemRender(btn, index, data)
	end
end

M.CheckMaterialEnough = function(self, material, count)
	if table.isNilOrEmpty(material) then
		return true
	end

	count = count or 1
	local isTarkov = self:IsExtractionShooterDomain()

	for i = 1, #material do
		local mat = material[i]

		if gCommonItemManager:GetItemNum(mat.BindId, isTarkov) >= mat.Num * count then
			return false
		end
	end

	return true
end

M.OnDynamicRenderItemListItem = function(self, btn, index)
	local data = self.itemListData[index + 1]

	if data and data.itemId then
		gCommonItemManager:OnDynCommonItemRender(btn, index, data)

		btn.enabledTooltip = false
	end
end

M.OnCommonItemRender = function(self, btn, index)
	local data = self.itemListData[index + 1]

	if data and data.itemId then
		local store = gCommonItemManager:OnCommonItemRender(btn, index, data)
		btn.enabledTooltip = false

		if store then
			local enough = self:CheckMaterialEnough(data.material, 1)
			store.notAvailableCtrl = enough and 0 or 1
			local cfg = LTConfig.ConsumableConfig.GetConfig(data.itemId)
			local compoundCfg = LTConfig.CompoundConfig.GetConfig(data.compoundId)

			if cfg then
				if compoundCfg and compoundCfg.Num <= 1 then
					store.count = cfg.Name .. "*" .. compoundCfg.Num
				else
					store.count = cfg.Name
				end
			else
				store.count = ""
			end

			store.showTaskCtrl = data.IsTask and 1 or 0
			store.taskIconId = data.TaskIconId or 0
			local compoundCfg = LTConfig.CompoundConfig.GetConfig(data.compoundId)

			if store.guide then
				store.guide.guideID = compoundCfg and compoundCfg.GuideId or ""
			end
		end
	end
end

M.OnItemListSelectedChange = function(self, uList)
	local selectedIndex = uList.selectedIndex

	if not selectedIndex then
		return
	end

	self.targetItem = self.itemListData[selectedIndex + 1]
	self.bindData.showProgressCtrl = HIDE_PROGRESSLINE

	self.bindData.progressLine:ProgressToValue(0)
	self:OnRefreshInfo()
end

M.OnMakeBtnClick = function(self)
	if not self.targetItem or not self.targetItem.compoundId then
		return
	end

	if self.isCompounding then
		return
	end

	if self.pandingCrafts[self.targetItem.compoundId] then
		return
	end

	local now = gCS.TimeManager.ServerUnixTime
	local compoundEndTime = now + CompoundConfig.CompoundTime
	local compoundId = self.targetItem.compoundId
	local compoundCount = self.targetCount
	self.isCompounding = true

	if self.CheckIsLimitCompoundItem(self, compoundId) then
		slot5 = self.mgr

		slot5:AskItemStartCompound(compoundId, self.craftingTableId, compoundCount, {}, function (rewards)
			print_debug("CompoundMake: AskStartLimitItem")

			self.pandingCrafts[compoundId] = {
				["\\x96'6u\\x94U\\xf0#\\xaf\\xb4"] = true,
				startTime = now,
				endTime = compoundEndTime,
				rewards = rewards
			}
		end)
	else
		print_debug("CompoundMake: AskStartNotLimitItem")

		self.pandingCrafts[compoundId] = {
			["\\x96'6u\\x94U\\xf0#\\xaf\\xb4"] = false,
			startTime = now,
			endTime = compoundEndTime,
			compoundCount = compoundCount
		}
	end
end

M.OnExitBtnClick = function(self)
	if self.isCompounding then
		return
	end

	gPanelManager:Close(self.m_Id)
end

M.OnTabSelectedChanged = function(self, uList, isSub)
	self.targetTab = uList.selectedIndex

	self.OnRefreshPage(self)
end

M.OnBuyNumChange = function(self, num)
	num = math.floor(num)

	if self.targetCount ~= num then
		return
	end

	self.targetCount = num

	self.RefreshMat(self)
end

M.OnRefrehNameInfo = function(self)
	local count = self.targetCount * self.cfg.Num

	if count <= 1 then
		self.bindData.nameLabel = self.data.name .. "*" .. count
	else
		self.bindData.nameLabel = self.data.name
	end
end

M.RefreshItemNum = function(self)
	self.OnRefreshPage(self)
	self.OnRefreshInfo(self)
end

M.CheckIsLimitCompoundItem = function(self, compoundId)
	local cfg = CompoundConfig.GetConfig(compoundId)

	if cfg and string.is_null_or_empty(cfg.RefreshTime) then
		return false
	end

	return true
end

M.IsExtractionShooterDomain = function(self)
	local cfg = CompoundCraftingTableConfig.GetConfig(self.craftingTableId)

	if not cfg then
		return false
	end

	return cfg.Domain ~= CompoundCraftingTableConfig.DomainType.ExtractionShooter
end
