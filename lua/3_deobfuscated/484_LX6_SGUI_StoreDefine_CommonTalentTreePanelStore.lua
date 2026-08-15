local TalentConfig = LTConfig.TalentTreeTalentConfig
local TalentTreeConfig = LTConfig.TalentTreeConfig
local EInvokeTime = SGUI.EInvokeTime
C_CommonTalentTreePanelStore = DefClass("C_CommonTalentTreePanelStore", C_CommonTalentTreePanelStore, C_StoreGroup)
GroupName2Class.CommonTalentTreePanelStore = C_CommonTalentTreePanelStore
local M = C_CommonTalentTreePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.mgr = gTalentTreeMgr
end

function M:DefineAllVariables()
	self.currentTalent = 0
	self.jobClass = 0
	self.treeId = 0
	self.cfg = nil
	self.toolTipStore = nil
	self.talentId2Btn = {}
	self.itemToolTipData = {}
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.SPIRIT_TALENT_ACTIVE] = self:CreateAction(self.OnSpiritTalentActive),
		[gEventConstants.SELECTED_TALENT_ID] = self:CreateAction(self.SetSelectedTalentId)
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
	self:GenMessageEvents()
end

function M:OnShow(panelId, data)
	self.jobClass = data and data.jobClass or 0
	self.treeId = data and data.treeId or 0
	self.cfg = TalentTreeConfig.GetConfig(self.treeId)
	self.itemToolTipData = gCommonItemManager:GetItemRenderData(data and data.itemId or 0)
	self.bindData.talentPointBtn.interactable = not string.is_null_or_empty(self.itemToolTipData.name)

	self:OnSpiritJobInfoChange()

	self.bindData.showReset = BOOL2CTL[self.cfg and self.cfg.EnableReset or false]
end

function M:OnClose()
	self.talentId2Btn = {}

	self:DefineAllVariables()

	self.bindData.talentTree.url = ""
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnSpiritTalentActive(eventId, data)
	if data.spiritId ~= gBattleSpiritMgr.currentSpiritTemplateId then
		return
	end

	if data.jobClassId ~= self.jobClass then
		return
	end

	local btn = self.talentId2Btn[data.talentId]

	if not btn then
		return
	end

	btn:InvokeCallback(EInvokeTime.User1)
end

function M:RegisterWidget()
	self.bindData.talentTree.luaSelectedChanged = self:CreateAction(self.OnTalentTreeItemChange)
	self.bindData.talentTree.luaOnSetTalentData = self:CreateAction(self.OnTalentTreeSet)
	self.bindData.talentTree.luaRenderItem = self:CreateAction(self.OnTalentTreeRenderItem)
	self.bindData.talentTree.luaInitBackground = self:CreateAction(self.OnTalentTreeInitBackground)
	self.bindData.talentPointBtn.luaRenderTooltip = self:CreateAction(self.OnRenderToolTips)
	self.bindData.resetBtn.luaClick = self:CreateAction(self.OnResetBtnClick)
end

function M:OnResetBtnClick()
	self.mgr:OnResetTalentTree(self.jobClass)
end

function M:OnRenderToolTips(btn, popup, index)
	if table.isNilOrEmpty(self.itemToolTipData) then
		return
	end

	gCommonItemManager:OnRenderToolTips(self.itemToolTipData, btn, popup, index)
end

function M:OnTalentTreeItemChange(UTalentTree)
	local data = UTalentTree.selectedItem

	if not data then
		return
	end

	self:OnSetSelectedTalentId(data.talentId, true, false)
end

function M:OnChangeToolTips(flag, fromset)
	self.bindData.showTooltip = BOOL2CTL[flag]

	if flag == true and self.currentTalent ~= 0 then
		if not fromset then
			self.bindData.talentToolTip:InvokeCallback(EInvokeTime.User1)
		end

		self.bindData.talentToolTip:InvokeCallback(EInvokeTime.Show)

		self.toolTipStore = self.mgr:RefreshTalentToolTip(self.bindData.talentToolTip, self.currentTalent, self.jobClass, self:CreateAction(self.OnDeSelectedData))
	else
		self.bindData.talentTree:DeselectAll()
	end
end

function M:OnDeSelectedData()
	if self.bindData.showTooltip == BOOL2CTL[false] then
		return
	end

	self:OnSetSelectedTalentId(0, false, false)
end

function M:OnTalentTreeSet(itemDatas)
	local itemList = itemDatas:ToTable()

	for i = 1, #itemList do
		local talentId = itemList[i].talentId
		local isLocked = self.mgr:CheckTalentIsLocked(talentId, self.jobClass)
		local canUnlock, _ = self.mgr:CheckTalentCanUnlock(talentId, true)
		local lockState = canUnlock and self.mgr.LOCK_STATE.CAN_UNLOCK or self.mgr.LOCK_STATE.LOCKED
		itemList[i].locked = isLocked and lockState or self.mgr.LOCK_STATE.ACTIVE

		if isLocked and self.currentTalent == 0 and canUnlock then
			itemList[i].selected = true

			self:OnSetSelectedTalentId(talentId, true, true)
		end
	end

	if self.currentTalent == 0 and not table.isNilOrEmpty(itemList) then
		itemList[1].selected = true

		self:OnSetSelectedTalentId(itemList[1].talentId, true, true)
	end
end

function M:OnTalentTreeInitBackground(talentTree, wid)
	local store = gStoreManager:GetStoreGroup(wid.Store):GetStoreByWidget(wid)

	if not store then
		return
	end

	self.bgStore = store

	self:OnRefreshBackGroudStore(store)
end

function M:SetSelectedTalentId(_, talentId)
	self.bindData.talentTree:SelectItemById(talentId)
end

function M:OnSetSelectedTalentId(talentId, flag, fromset)
	self.currentTalent = talentId

	self:OnChangeToolTips(flag, fromset)
end

function M:OnRefreshBackGroudStore(store)
	return
end

function M:OnTalentTreeRenderItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local cfg = TalentConfig.GetConfig(data.talentId)

	if not store or not cfg then
		return
	end

	btn.guide.guideID = cfg.GuideId

	if not string.is_null_or_empty(cfg.GuideId) then
		store.controllerGuideId = cfg.GuideId .. "_Controller"
	end

	store.iconId = cfg.IconId
	store.pointNumLabel = cfg.CostPoint
	store.isLackTalentPoint = BOOL2CTL[self.mgr:GetCurrentTalentPoint(self.jobClass) < cfg.CostPoint]

	if cfg.LayerNum > 1 then
		local talentDict = self.mgr:GetCurrentTalentDict(self.jobClass)
		local currentLayerNum = talentDict[data.talentId] and talentDict[data.talentId].Layer or 0
		store.layerLabel = currentLayerNum .. "/" .. cfg.LayerNum

		store.layerList:InitSimpleList()

		for i = 1, cfg.LayerNum do
			store.layerList:AddSimpleData(0, false, currentLayerNum < i)
		end

		store.layerList:RefreshList()
	else
		store.layerLabel = ""

		store.layerList:SetSimpleList(0)
	end

	local progressStu = {
		progress = store.progress,
		id = data.talentId
	}
	self.talentId2Btn[data.talentId] = btn
	btn.luaBeginLongPress = self:CreateActionWithArgs(self.OnBeginLongPress, progressStu)
	btn.luaEndLongPress = self:CreateActionWithArgs(self.OnEndLongPress, progressStu)
end

function M:OnBeginLongPress(progressStu)
	if table.isNilOrEmpty(progressStu) then
		return
	end

	local canUnlock, _ = self.mgr:CheckTalentCanUnlock(progressStu.id)

	if not canUnlock then
		return
	end

	local progress = progressStu.progress

	if self.toolTipStore then
		self.toolTipStore.progress:ProgressToValue(1, TalentTreeConfig.ActiveLongPressTime, 0, DG.Tweening.Ease.Linear)
	end

	progress:ProgressToValueWithCallBack(1, TalentTreeConfig.ActiveLongPressTime, 0, DG.Tweening.Ease.Linear, self:CreateActionWithArgs(self.OnEndProgressEnd, progressStu))
end

function M:OnEndLongPress(progressStu)
	if table.isNilOrEmpty(progressStu) then
		return
	end

	local progress = progressStu.progress

	progress:StopProgress()
	progress:ProgressToValue(0, 0, 0, DG.Tweening.Ease.Linear)

	if self.toolTipStore then
		self.toolTipStore.progress:StopProgress()
		self.toolTipStore.progress:ProgressToValue(0, 0, 0, DG.Tweening.Ease.Linear)
	end
end

function M:OnEndProgressEnd(progressStu)
	progressStu.progress:ProgressToValue(0, 0, 0, DG.Tweening.Ease.Linear)

	if self.toolTipStore then
		self.toolTipStore.progress:ProgressToValue(0, 0, 0, DG.Tweening.Ease.Linear)
	end

	self.mgr:AskActiveTalent(nil, self.jobClass, progressStu.id)
end

function M:OnSpiritJobInfoChange(param)
	self.bindData.talentTree.url, self.stage, self.nextStageCount = self.mgr:GetCurrentGraphPath(self.treeId)
	self.bindData.talentCount = self.mgr:GetCurrentTalentPoint(self.jobClass)

	self.bindData.talentTree:SelectItemById(self.currentTalent)

	if self.bgStore then
		self:OnRefreshBackGroudStore(self.bgStore)
	end
end
