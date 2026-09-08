-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TalentExpPanelStore.lua
-- Decompiled from: 01397_TalentExpPanelStore.lua_21e85374e3c9.luajit

C_TalentExpPanelStore = DefClass("C_TalentExpPanelStore", C_TalentExpPanelStore, C_StoreGroup)
GroupName2Class.TalentExpPanelStore = C_TalentExpPanelStore
local M = C_TalentExpPanelStore
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local TalentTreeLevelConfig = LTConfig.TalentTreeLevelConfig
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

local OnValidateCounterChar = function(_, _, addedChar)
	if string.byte("0") < addedChar and addedChar < string.byte("9") then
		return addedChar
	end

	return 0
end

local LV_FORMAT_ID = 89901296
local MAX_LEVEL_TEXT_ID = 89901297

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.spiritId = 0
	self.matListData = {}
	self.selectedIndex = -1
	self.isMax = false
	self.totalPreviewExp = 0

	self.onCounterValChange = function(val)
		self:OnCounterValueChanged(val)
	end
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
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	gCommonItemManager:CloseItemToolTips()

	self.spiritId = data and data.spiritId or gBattleSpiritMgr.currentSpiritTemplateId

	self:RefreshMatList()
	self:RefreshHeadAndPreLv()
	self:ClearSelection()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SPIRIT_TALENT_CHANGE] = self.CreateAction(self, self.OnSpiritTalentChange),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, self.OnPackItemChanged)
	}
end

M.OnSpiritTalentChange = function(self)
	self.RefreshHeadAndPreLv(self)

	if self.isMax then
		self.ClearSelection(self)

		return
	end

	if self.selectedIndex > 0 then
		local item = self.matListData[self.selectedIndex + 1]

		if item and not self.BindCounterTo(self, item) then
			self.ClearItemSelection(self, self.selectedIndex)

			return
		end
	end

	self.RefreshNxtLv(self)
end

M.OnPackItemChanged = function(self)
	local materials = gTalentTreeMgr:GetExperienceMaterials()
	local byId = {}

	for _, m in ipairs(materials) do
		byId[m.templateId] = m
	end

	for _, item in ipairs(self.matListData) do
		local fresh = byId[item.templateId]
		item.ownCount = fresh and fresh.ownCount or 0

		if item.ownCount >= item.itemNum then
			item.itemNum = item.ownCount
		end
	end

	if self.selectedIndex > 0 then
		local sel = self.matListData[self.selectedIndex + 1]

		if not sel or sel.ownCount < 0 then
			self.ClearSelection(self)
		elseif not self.BindCounterTo(self, sel) then
			self.ClearItemSelection(self, self.selectedIndex)
		end
	end

	self.bindData.matList:RefreshList()
	self:RefreshNxtLv()
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.OnClickCancelBtn)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.matList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderMatListItem)
	self.bindData.matList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickMatList)
end

M.RefreshMatList = function(self)
	local materials = gTalentTreeMgr:GetExperienceMaterials()
	self.matListData = {}

	for _, m in ipairs(materials) do
		table.insert(self.matListData, {
			["\\xd0\\xcf01\\xfc"] = 0,
			templateId = m.templateId,
			exp = m.exp,
			ownCount = m.ownCount
		})
	end

	self.bindData.matList:SetSimpleList(#self.matListData)
end

M.RenderLvStore = function(self, widget, level, isMax, exp, maxExp)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	store.lv = gString.Format(TextScriptTextConfig.GetConfig(LV_FORMAT_ID).Text, level)
	store.amount = isMax and TextScriptTextConfig.GetConfig(MAX_LEVEL_TEXT_ID).Text or exp .. "/" .. maxExp
end

M.RefreshHeadAndPreLv = function(self)
	local currentExp, maxExp, level = gTalentTreeMgr:GetCurrentExpInfo(self.spiritId)
	self.isMax = maxExp ~= 0
	local headStore = gStoreManager:GetStoreGroup(self.bindData.head.Store):GetStoreByWidget(self.bindData.head)

	if headStore then
		local headIcon, bgColor = gNpcFavorManager:GetAgentFightSpiritHeadInfo(self.spiritId, 0)
		headStore.headIcon = headIcon or 0

		if bgColor then
			headStore.bgColor = bgColor
		end

		if headStore.progress then
			headStore.progress.maxValue = maxExp

			headStore.progress:ProgressToValue(currentExp)
		end
	end

	self.RenderLvStore(self, self.bindData.preLv, level, self.isMax, currentExp, maxExp)

	self.bindData.confirmBtn.interactable = false
end

M.ClearSelection = function(self)
	self.selectedIndex = -1

	for _, item in ipairs(self.matListData) do
		item.itemNum = 0
	end

	self.SubGroup.CommonCounterStore:SetData({
		["\\x8b528}\\x89w\\xd8;\\xbf\\xbc"] = 0,
		range = {
			0,
			0
		},
		valChangeCallback = self.onCounterValChange,
		onValidateChar = OnValidateCounterChar
	})
	self:RefreshNxtLv()
end

M.ClearItemSelection = function(self, index)
	local item = self.matListData[index + 1]

	if not item then
		return
	end

	item.itemNum = 0

	if self.selectedIndex ~= index then
		self.selectedIndex = -1

		self.SubGroup.CommonCounterStore:SetData({
			["\\x8b528}\\x89w\\xd8;\\xbf\\xbc"] = 0,
			range = {
				0,
				0
			},
			valChangeCallback = self.onCounterValChange,
			onValidateChar = OnValidateCounterChar
		})
	end

	self.bindData.matList:RefreshElement(index)
	self:RefreshNxtLv()
end

M.GetRemainExpToMax = function(self)
	local currentExp, maxExp, level = gTalentTreeMgr:GetCurrentExpInfo(self.spiritId)

	if maxExp < 0 then
		return 0
	end

	local remainExp = math.max(0, maxExp - currentExp)

	for lv = level + 1, TalentTreeLevelConfig.count - 1 do
		local cfg = TalentTreeLevelConfig.GetConfig(lv)

		if not cfg then
			break
		end

		remainExp = remainExp + cfg.Exp
	end

	return remainExp
end

M.CalcUsableItemCount = function(self, item, baseRawExp, availableCount)
	if not item or (item.exp or 0) < 0 then
		return 0
	end

	local remainExp = self:GetRemainExpToMax()
	local count = math.max(0, math.floor(availableCount or 0))

	if remainExp > 0 or count < 0 then
		return 0
	end

	local IsEnough = function(useCount)
		local rawExp = baseRawExp + item.exp * useCount

		return remainExp > gTalentTreeMgr:CalcSpiritTalentExpAddition(self.spiritId, rawExp)
	end

	if IsEnough(0) then
		return 0
	end

	if not IsEnough(count) then
		return count
	end

	local left = 1
	local right = count

	while left >= right do
		local mid = math.floor((left + right) / 2)

		if IsEnough(mid) then
			right = mid
		else
			left = mid + 1
		end
	end

	return left
end

M.GetMaxUsableCount = function(self, targetItem)
	local otherRawExp = 0

	for _, item in ipairs(self.matListData) do
		if item == targetItem and item.itemNum <= 0 then
			otherRawExp = otherRawExp + item.exp * item.itemNum
		end
	end

	return self.CalcUsableItemCount(self, targetItem, otherRawExp, targetItem.ownCount)
end

M.ClampSelectionToMax = function(self)
	local changed = false
	local selectedRawExp = 0

	for _, item in ipairs(self.matListData) do
		local selectedCount = math.max(0, math.min(math.floor(item.itemNum or 0), item.ownCount))
		local usableCount = self:CalcUsableItemCount(item, selectedRawExp, selectedCount)

		if item.itemNum == usableCount then
			item.itemNum = usableCount
			changed = true
		end

		selectedRawExp = selectedRawExp + item.exp * usableCount
	end

	return changed
end

M.BindCounterTo = function(self, item)
	local maxCount = self.GetMaxUsableCount(self, item)

	if maxCount < 0 then
		return false
	end

	local targetValue = math.max(1, math.min(item.itemNum, maxCount))

	self.SubGroup.CommonCounterStore:SetData({
		range = {
			1,
			maxCount
		},
		targetValue = targetValue,
		valChangeCallback = self.onCounterValChange,
		onValidateChar = OnValidateCounterChar
	})
	self.onCounterValChange(targetValue)

	return true
end

M.RefreshNxtLv = function(self)
	local currentExp, maxExp, level = gTalentTreeMgr:GetCurrentExpInfo(self.spiritId)
	self.isMax = maxExp ~= 0
	local total = 0

	for _, item in ipairs(self.matListData) do
		if item.itemNum <= 0 then
			total = total + item.exp * item.itemNum
		end
	end

	self.totalPreviewExp = total
	local bonusTotal = gTalentTreeMgr:CalcSpiritTalentExpAddition(self.spiritId, total)

	if bonusTotal == total then
		self.totalPreviewExp = bonusTotal
	end

	if self.isMax then
		self.RenderLvStore(self, self.bindData.nxtLv, level, true, currentExp, maxExp)
	else
		local previewExp, previewLevel, previewMax = self:CalcPreview(currentExp, maxExp, level, bonusTotal)
		local nxtIsMax = previewMax ~= 0

		self:RenderLvStore(self.bindData.nxtLv, previewLevel, nxtIsMax, previewExp, previewMax)
	end

	self.bindData.confirmBtn.interactable = not self.isMax and total >= 0
end

M.CalcPreview = function(self, currentExp, maxExp, level, total)
	local exp = currentExp + total
	local lv = level
	local mx = maxExp

	while mx <= 0 and mx < exp and lv >= TalentTreeLevelConfig.count do
		exp = exp - mx
		lv = lv + 1

		if lv ~= TalentTreeLevelConfig.count then
			return 0, lv, 0
		end

		local cfg = TalentTreeLevelConfig.GetConfig(lv)

		if not cfg then
			return exp, lv, 0
		end

		mx = cfg.Exp
	end

	return exp, lv, mx
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickCancelBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickConfirmBtn = function(self)
	if self.isMax then
		return
	end

	if self.ClampSelectionToMax(self) then
		self.bindData.matList:RefreshList()
		self:RefreshNxtLv()
	end

	local items = {}

	for _, item in ipairs(self.matListData) do
		if item.itemNum <= 0 then
			table.insert(items, {
				templateId = item.templateId,
				count = item.itemNum
			})
		end
	end

	if #items ~= 0 then
		return
	end

	self.bindData.confirmBtn.interactable = false
	slot2 = gTalentTreeMgr

	slot2:RequestAddSpiritTalentExp(self.spiritId, items, function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gPanelManager:Close(self.m_Id)
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			slot1 = self.bindData.confirmBtn
			slot2 = not self.isMax and #items >= 0
			slot1.interactable = slot2
		end
	end)
end

M.OnSimpleRenderMatListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local item = self.matListData[index + 1]

	if not item then
		return
	end

	local unselectedCb = function()
		self:ClearItemSelection(index)
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = item.templateId,
		itemNum = item.itemNum .. "/" .. item.ownCount,
		unselectedCb = unselectedCb
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	store.showUnselect = item.itemNum <= 0 and 1 or 0
	store.notAvailableCtrl = BOOL2CTL[item.ownCount > 0]
	btn.enabledTooltip = false
end

M.OnSimpleClickMatList = function(self, btn, index)
	local item = self.matListData[index + 1]

	if not item or item.ownCount < 0 then
		return
	end

	if self.GetMaxUsableCount(self, item) < 0 then
		return
	end

	self.selectedIndex = index

	self.BindCounterTo(self, item)
end

M.OnCounterValueChanged = function(self, val)
	if self.selectedIndex >= 0 then
		return
	end

	local item = self.matListData[self.selectedIndex + 1]

	if not item then
		return
	end

	local maxCount = self:GetMaxUsableCount(item)
	local normalizedVal = math.max(0, math.min(math.floor(tonumber(val) or 0), maxCount))
	item.itemNum = normalizedVal

	if maxCount <= 0 and normalizedVal == val then
		self.SubGroup.CommonCounterStore:ChangeValue(normalizedVal)

		return
	end

	self.bindData.matList:RefreshElement(self.selectedIndex)
	self:RefreshNxtLv()
end
