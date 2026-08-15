local UNavigationMgr = SGUI.UNavigationMgr
local Screen = UnityEngine.Screen
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
C_InventoryItemDetailInfoTemplateStore = DefClass("C_InventoryItemDetailInfoTemplateStore", C_InventoryItemDetailInfoTemplateStore, C_StoreGroup)
GroupName2Class.InventoryItemDetailInfoTemplateStore = C_InventoryItemDetailInfoTemplateStore
local M = C_InventoryItemDetailInfoTemplateStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local E = math.exp(1)

function M:ctor()
	self:OnInit()

	self.mgr = gCommonItemManager
end

function M:OnInit()
	self.range = {
		0,
		0
	}
	self.val = 0
	self.preTime = 0
	self.selectedItem = {}
	self.onConfirmCallback = nil
	self.onCheckBtnVisible = nil
	self.onValueChangeCallback = nil
	self.stepInterval = 1

	self:OnEndLongPress()
end

function M:OnAwake()
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnConfirmBtnClick")
	self.bindData.backBtn.luaClick = self:CreateAction("OnSubBackBtnClick")
	self.bindData.hyperLinkBtn.luaClick = self:CreateAction(self.OnHyperLinkBtnClick)
	self.bindData.descList.luaSimpleRenderItem = self:CreateAction(self.OnRenderDescItem)
	self.bindData.descList.luaSimpleClick = self:CreateAction(self.OnDescItemClick)
	self.bindData.descList.onGetTIndex = self:CreateAction(self.OnGetDescIndex)
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction(self.OnRenderToolTipTagList)
	self.bindData.descList.maxHeight = Screen.height * 0.45
	self.descList = {}

	self:subStoreAwake()
end

function M:OnRenderDescItem(btn, index)
	local data = self.descList[index + 1]

	self.mgr:OnRenderDescItem(btn, index, data)
end

function M:OnDescItemClick(btn, index)
	local data = self.descList[index + 1]

	self.mgr:OnDescItemClick(btn, data)
end

function M:OnGetDescIndex(index)
	return self.descList[index + 1].tIndex
end

function M:OnRenderToolTipTagList(btn, index, data)
	gNpcFavorManager:OnRenderToolTipTagList(btn, index, self.tagList[index + 1])
end

function M:SetSelectedItem(item, checkBtnVisCallback, onConfirmCallback, onValueChangeCallback, parent)
	self.onConfirmCallback = onConfirmCallback
	self.onCheckBtnVisible = checkBtnVisCallback
	self.onValueChangeCallback = onValueChangeCallback
	self.parentArea = parent and parent or UNavigationMgr.Inst.CurrentActiveArea
	self.selectedItem = item
	self.range = item.range or {}

	if #self.range >= 2 and self.range[2] < self.range[1] then
		self.range[2] = self.range[1]
		self.range[1] = self.range[1]
	end

	self.stepInterval = item.stepInterval or 1

	self:InitCounter()
	self:OnRefreshInfo()
end

function M:OnSubBackBtnClick()
	if gCS.LuaUtils.IsNonMobileAdaptive() and self.parentArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.parentArea
	end
end

function M:OnHyperLinkBtnClick()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.hyperNavigationArea
	end
end

function M:OnConfirmBtnClick()
	if self.onConfirmCallback then
		self.onConfirmCallback(self.data, self.val)
	end
end

function M:OnRefreshInfo()
	if table.isNilOrEmpty(self.selectedItem) or not self.rootWidget or not self.STATE_EnableOnce then
		return
	end

	self.data = gCommonItemManager:TryGetItemInfo(self.selectedItem)

	if table.isNilOrEmpty(self.data) then
		print_error("[InventoryPanelStore] RefreshPage data is nil")

		return
	end

	self.bindData.nameLabel = self.data.name

	self.bindData:Commit("quality", self.data.quality, COMMIT_FORCE)

	self.bindData.iconId = self.data.iconId
	self.bindData.haveLabel = self.selectedItem.Count or self.mgr:GetItemNum(self.data.itemId)
	self.bindData.showCountLabel = BOOL2CTL[self.data.showCount]
	local btnVisible = self.onCheckBtnVisible and self.onCheckBtnVisible(self.data) or false
	self.bindData.showBtn = BOOL2CTL[btnVisible]

	if btnVisible then
		self.bindData.confirmBtn.interactable = true
	end

	self.descList = {}
	local hasSource = gCommonItemManager:GetItemDescList(self.data, self.descList)
	self.bindData.hasHyperLink = BOOL2CTL[hasSource]

	self.bindData.descList:SetSimpleList(#self.descList)

	self.tagList = gNpcFavorManager:GetItemTagList(self.data)

	self.bindData.tagList:SetSimpleList(#self.tagList)

	local hasRange = not table.isNilOrEmpty(self.range)
	self.bindData.showCounter = BOOL2CTL[hasRange]

	if hasRange then
		self:InitCounter()
	end

	self.bindData.itemType = self.mgr:GetItemDisplayType(self.data.itemId)
	local showCreateMoney = self.data.subType == ConsumableTypeConfig.QuantumWallet
	self.bindData.showCreateMoney = BOOL2CTL[showCreateMoney]

	self:RefreshQuantumWallet()
end

function M:OnEnable()
	self:OnRefreshInfo()
end

function M:OnStart()
	return
end

function M:OnDestroy()
	self:OnInit()
	self.mgr:OnItemToolTipBtnClose()
end

function M:subStoreAwake()
	if not self.bindData.inputField then
		return
	end

	self.totalTime = 0
	self.step = 0
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnBuyNumChange")
	self.bindData.inputField.luaEndEdit = self:CreateAction("OnEndEdit")
	self.bindData.minusBtn.luaBeginLongPress = self:CreateAction("OnMinusBeginLongPress")
	self.bindData.minusBtn.luaEndLongPress = self:CreateAction("OnEndLongPress")
	self.bindData.plusBtn.luaBeginLongPress = self:CreateAction("OnPlusBeginLongPress")
	self.bindData.plusBtn.luaEndLongPress = self:CreateAction("OnEndLongPress")
	self.bindData.maxBtn.luaClick = self:CreateAction("OnClickToMax")
end

function M:InitCounter()
	if table.isNilOrEmpty(self.range) or not self.STATE_EnableOnce then
		return
	end

	self.bindData.inputField.digitalMin = self.range[1]
	self.bindData.inputField.digitalMax = self.range[2]
	self.bindData.inputField.text = self.range[1]
	local isSingle = self.range[2] <= self.range[1]
	self.bindData.inputField.interactable = not isSingle
	self.bindData.available = BOOL2CTL[not isSingle]

	self:OnBuyNumChange(self.range[1])
end

function M:CheckValue(value, notUseStep)
	if value == nil then
		return 0
	end

	if not notUseStep then
		value = math.floor(value / self.stepInterval) * self.stepInterval
	end

	value = math.max(self.range[1], math.min(value, self.range[2]))

	return value
end

function M:ChangeValue(value)
	value = self:CheckValue(value)
	self.bindData.inputField.text = value

	return value
end

function M:OnBuyNumChange(data)
	local val = tonumber(data)
	self.val = self:CheckValue(val, true)

	if val == nil or val ~= self.val then
		self.bindData.inputField.text = self.val

		return
	end

	if self.onValueChangeCallback then
		self.onValueChangeCallback(self.val, self.data)
	end

	self.bindData.plusBtn.interactable = self.val < self.range[2]
	self.bindData.minusBtn.interactable = self.range[1] < self.val
end

function M:OnEndEdit()
	self:ChangeValue(self.val)
end

function M:OnUpdate()
	self:RefreshStep()

	if gLogicTime.unscaledTime - self.preTime <= 1 then
		return
	end

	self.preTime = gLogicTime.unscaledTime

	self:RefreshQuantumWallet()
end

function M:OnBeginLongPress(step)
	self.step = step
	self.totalTime = 0
	self.val = self.val + self.step

	self:ChangeValue(self.val)
end

function M:OnEndLongPress()
	self.totalTime = 0
	self.step = 0
end

function M:RefreshStep()
	if self.step ~= 0 then
		if self.step < 0 and self.val <= self.range[1] or self.step > 0 and self.range[2] <= self.val then
			self:OnEndLongPress()

			return
		end

		self.totalTime = self.totalTime + Time.deltaTime

		if self.totalTime < 0.5 then
			return
		end

		local step = self.step * E^(self.totalTime * 0.2)
		self.val = self.val + step

		self:ChangeValue(self.val)
	end
end

function M:OnStepClick(step)
	self.val = self.val + step

	self:ChangeValue(self.val)
end

function M:OnMinusClick()
	local step = self.stepInterval and -1 * self.stepInterval or -1

	self:OnStepClick(step)
end

function M:OnPlusClick()
	local step = self.stepInterval or 1

	self:OnStepClick(step)
end

function M:OnMinusBeginLongPress()
	local step = self.stepInterval and -1 * self.stepInterval or -1

	self:OnBeginLongPress(step)
end

function M:OnPlusBeginLongPress()
	local step = self.stepInterval or 1

	self:OnBeginLongPress(step)
end

function M:OnClickToMax()
	self.val = self.range[2]

	self:ChangeValue(self.val)
end

function M:GetCurrentVal()
	return self.val
end

function M:RefreshQuantumWallet()
	if self.bindData.showCreateMoney == BOOL2CTL[true] then
		local moneyNum = self.mgr:GetQuantumWalletMoney()
		self.bindData.createMoneyCount = string.format("%d", moneyNum)
		self.bindData.confirmBtn.interactable = moneyNum > 0
	end
end
