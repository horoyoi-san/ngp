-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonTalentTreePanelStore.lua
-- Decompiled from: 01541_CommonTalentTreePanelStore.lua_a057a6505646.luajit

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

M.ctor = function(self)
	self.mgr = gTalentTreeMgr
end

M.IsMobileAdaptive = function(self)
	return self._isMobileAdaptive
end

M.DefineAllVariables = function(self)
	self.currentTalent = 0
	self.jobClass = 0
	self.gameplayId = 0
	self.treeId = 0
	self.cfg = nil
	self.toolTipStore = nil
	self.talentId2Btn = {}
	self.btn2TalentId = {}
	self.itemToolTipData = {}
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SPIRIT_TALENT_ACTIVE] = self.CreateAction(self, self.OnSpiritTalentActive),
		[gEventConstants.GAMEPLAY_TALENT_ACTIVE] = self.CreateAction(self, self.OnGameplayTalentActive),
		[gEventConstants.GAMEPLAY_TALENT_CHANGE] = self.CreateAction(self, self.OnGameplayTalentChange),
		[gEventConstants.SELECTED_TALENT_ID] = self.CreateAction(self, self.SetSelectedTalentId)
	}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)

	self._isMobileAdaptive = not gCS.LuaUtils.IsNonMobileAdaptive()

	self.RegisterWidget(self)
	self.GenMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.gameplayId = data and data.gameplayId or 0

	if self.gameplayId == 0 then
		self.treeId = data and data.treeId or self.mgr:GetGameplayTalentTreeId(self.gameplayId)
	else
		self.jobClass = data and data.jobClass or 0
		self.treeId = data and data.treeId or 0
	end

	self.cfg = TalentTreeConfig.GetConfig(self.treeId)
	self.itemToolTipData = gCommonItemManager:GetItemRenderData(data and data.itemId or 0)
	self.bindData.talentPointBtn.interactable = not string.is_null_or_empty(self.itemToolTipData.name)

	self:OnSpiritJobInfoChange()

	self.bindData.showReset = BOOL2CTL[self.cfg and self.cfg.EnableReset or false]

	self.bindData.talentTree:InvokeCallback(EInvokeTime.Custom1)
	self.bindData.talentPointBtn:InvokeCallback(EInvokeTime.Custom1)

	if self.bindData.talentToolTip then
		self.bindData.talentToolTip:InvokeCallback(EInvokeTime.Custom1)
	end
end

M.OnClose = function(self)
	self.talentId2Btn = {}

	self.DefineAllVariables(self)

	self.bindData.showTooltip = BOOL2CTL[false]
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnSpiritTalentActive = function(self, eventId, data)
	if self.gameplayId == 0 then
		return
	end

	if data.spiritId == gBattleSpiritMgr.currentSpiritTemplateId then
		return
	end

	if data.jobClassId == self.jobClass then
		return
	end

	if self.currentBtn then
		self.currentBtn:CloseTooltip()

		self.currentBtn = nil
	end

	local btn = self.talentId2Btn[data.talentId]

	if not btn then
		return
	end

	btn.InvokeCallback(btn, EInvokeTime.User1)
end

M.OnGameplayTalentActive = function(self, eventId, data)
	if self.gameplayId ~= 0 then
		return
	end

	if not data or data.gameplayId == self.gameplayId then
		return
	end

	local btn = self.talentId2Btn[data.talentId]

	if not btn then
		return
	end

	btn.InvokeCallback(btn, EInvokeTime.User1)
end

M.OnGameplayTalentChange = function(self, eventId, data)
	if self.gameplayId ~= 0 then
		return
	end

	if data and data.gameplayId and data.gameplayId == self.gameplayId then
		return
	end

	self.OnTalentInfoChange(self)
end

M.RegisterWidget = function(self)
	self.bindData.talentTree.luaSelectedChanged = self.CreateAction(self, self.OnTalentTreeItemChange)
	self.bindData.talentTree.luaOnSetTalentData = self.CreateAction(self, self.OnTalentTreeSet)
	self.bindData.talentTree.luaRenderItem = self.CreateAction(self, self.OnTalentTreeRenderItem)
	self.bindData.talentTree.luaInitBackground = self.CreateAction(self, self.OnTalentTreeInitBackground)
	self.bindData.talentPointBtn.luaRenderTooltip = self.CreateAction(self, self.OnRenderToolTips)
	self.bindData.resetBtn.luaClick = self.CreateAction(self, self.OnResetBtnClick)
end

M.OnResetBtnClick = function(self)
	if self.gameplayId == 0 then
		self.mgr:OnResetGameplayTalentTree(self.gameplayId)
	else
		self.mgr:OnResetTalentTree(self.jobClass)
	end
end

M.OnRenderToolTips = function(self, btn, popup, index)
	if table.isNilOrEmpty(self.itemToolTipData) then
		return
	end

	gCommonItemManager:OnRenderToolTips(self.itemToolTipData, btn, popup, index)
end

M.OnRenderTalentItemTooltip = function(self, btn, popup, index)
	local talentId = self.btn2TalentId[btn]

	if not talentId then
		return
	end

	local activeBtnCb = nil

	if self.gameplayId == 0 then
		activeBtnCb = function()
			self.mgr:AskActiveGameplayTalent(self.gameplayId, talentId)
		end
	else
		activeBtnCb = function()
			self.mgr:AskActiveTalent(nil, self.jobClass, talentId)
		end
	end

	if self.gameplayId == 0 then
		self.mgr:RefreshGameplayTalentToolTip(popup, talentId, self.gameplayId, self:CreateAction(self.OnDeSelectedData), activeBtnCb)
	else
		self.mgr:RefreshTalentToolTip(popup, talentId, self.jobClass, self:CreateAction(self.OnDeSelectedData), activeBtnCb)
	end

	self.currentBtn = btn
end

M.OnTalentTreeItemChange = function(self, UTalentTree)
	local data = UTalentTree.selectedItem

	if not data then
		return
	end

	self.OnSetSelectedTalentId(self, data.talentId, true, false)
end

M.OnChangeToolTips = function(self, flag, fromset)
	if self.IsMobileAdaptive(self) then
		self.bindData.showTooltip = BOOL2CTL[false]

		if flag ~= false then
			self.bindData.talentTree:DeselectAll()
		end

		return
	end

	self.bindData.showTooltip = BOOL2CTL[flag]

	if flag ~= true and self.currentTalent == 0 then
		self.bindData.talentPointBtn:InvokeCallback(EInvokeTime.Custom1)
		self.bindData.talentToolTip:InvokeCallback(EInvokeTime.Custom1)

		local activeBtnCb = nil

		if self.gameplayId == 0 then
			activeBtnCb = function()
				self.mgr:AskActiveGameplayTalent(self.gameplayId, self.currentTalent)
			end
		else
			activeBtnCb = function()
				self.mgr:AskActiveTalent(nil, self.jobClass, self.currentTalent)
			end
		end

		if self.gameplayId == 0 then
			self.toolTipStore = self.mgr:RefreshGameplayTalentToolTip(self.bindData.talentToolTip, self.currentTalent, self.gameplayId, self:CreateAction(self.OnDeSelectedData), activeBtnCb)
		else
			self.toolTipStore = self.mgr:RefreshTalentToolTip(self.bindData.talentToolTip, self.currentTalent, self.jobClass, self:CreateAction(self.OnDeSelectedData), activeBtnCb)
		end
	else
		self.bindData.talentTree:DeselectAll()
	end
end

M.OnDeSelectedData = function(self)
	if self._isMobileAdaptive then
		if self.currentBtn then
			self.currentBtn:CloseTooltip()

			self.currentBtn = nil
		end
	elseif self.bindData.showTooltip ~= BOOL2CTL[false] then
		return
	end

	self.OnSetSelectedTalentId(self, 0, false, false)
end

M.OnTalentTreeSet = function(self, itemDatas)
	local itemList = itemDatas.ToTable(itemDatas)

	for i = 1, #itemList do
		local talentId = itemList[i].talentId
		local isLocked, canUnlock = nil

		if self.gameplayId == 0 then
			isLocked = self.mgr:CheckGameplayTalentIsLocked(talentId, self.gameplayId)
			canUnlock, _ = self.mgr:CheckGameplayTalentCanUnlock(talentId, self.gameplayId, true)
		else
			isLocked = self.mgr:CheckTalentIsLocked(talentId, self.jobClass)
			canUnlock, _ = self.mgr:CheckTalentCanUnlock(talentId, true)
		end

		local lockState = canUnlock and self.mgr.LOCK_STATE.CAN_UNLOCK or self.mgr.LOCK_STATE.LOCKED
		itemList[i].locked = isLocked and lockState or self.mgr.LOCK_STATE.ACTIVE
	end

	if self.currentTalent ~= 0 and not table.isNilOrEmpty(itemList) then
		local minItem = itemList[1]

		for i = 2, #itemList do
			if itemList[i].talentId >= minItem.talentId then
				minItem = itemList[i]
			end
		end

		minItem.selected = true

		self.OnSetSelectedTalentId(self, minItem.talentId, true, true)
	end
end

M.OnTalentTreeInitBackground = function(self, talentTree, wid)
	local storeGroup = gStoreManager:GetStoreGroup(wid.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, wid)

	if not store then
		return
	end

	self.bgStore = store

	self.OnRefreshBackGroudStore(self, store)
end

M.SetSelectedTalentId = function(self, _, talentId)
	self.bindData.talentTree:SelectItemById(talentId)
end

M.OnSetSelectedTalentId = function(self, talentId, flag, fromset)
	self.currentTalent = talentId

	self.OnChangeToolTips(self, flag, fromset)
end

M.OnRefreshBackGroudStore = function(self, store)
end

M.OnTalentTreeRenderItem = function(self, btn, index, data)
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)
	local cfg = TalentConfig.GetConfig(data.talentId)

	if not store or not cfg then
		return
	end

	btn.guide.guideID = cfg.GuideId

	if not string.is_null_or_empty(cfg.GuideId) then
		store.controllerGuideId = cfg.GuideId .. "_Controller"
	else
		store.controllerGuideId = ""
	end

	store.iconId = cfg.IconId
	store.pointNumLabel = cfg.CostPoint
	local lackPoint = nil

	if self.gameplayId == 0 then
		lackPoint = self.mgr:GetGameplayTalentPoint(self.gameplayId) <= cfg.CostPoint
	else
		lackPoint = self.mgr:GetCurrentTalentPoint(self.jobClass) <= cfg.CostPoint
	end

	store.isLackTalentPoint = BOOL2CTL[lackPoint or not self.mgr:CheckTalentCostItemEnough(data.talentId, self.gameplayId)]

	if cfg.LayerNum <= 1 then
		local talentDict = nil

		if self.gameplayId == 0 then
			talentDict = self.mgr:GetGameplayTalentDict(self.gameplayId)
		else
			talentDict = self.mgr:GetCurrentTalentDict(self.jobClass)
		end

		local currentLayerNum = talentDict[data.talentId] and talentDict[data.talentId].Layer or 0
		store.layerLabel = currentLayerNum .. "/" .. cfg.LayerNum

		store.layerList:InitSimpleList()

		for i = 1, cfg.LayerNum do
			store.layerList:AddSimpleData(0, false, currentLayerNum <= i)
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
	self.btn2TalentId[btn] = data.talentId

	if self.IsMobileAdaptive(self) then
		btn.luaRenderTooltip = self.CreateAction(self, self.OnRenderTalentItemTooltip)
	end

	btn.enabledTooltip = self.IsMobileAdaptive(self)
	btn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPress, progressStu)
	btn.luaEndLongPress = self.CreateActionWithArgs(self, self.OnEndLongPress, progressStu)
end

M.OnBeginLongPress = function(self, progressStu)
	if table.isNilOrEmpty(progressStu) then
		return
	end

	local canUnlock = nil

	if self.gameplayId == 0 then
		canUnlock, _ = self.mgr:CheckGameplayTalentCanUnlock(progressStu.id, self.gameplayId)
	else
		canUnlock, _ = self.mgr:CheckTalentCanUnlock(progressStu.id)
	end

	if not canUnlock then
		return
	end

	local progress = progressStu.progress

	if self.toolTipStore then
		self.toolTipStore.progress:ProgressToValue(1, TalentTreeConfig.ActiveLongPressTime, 0, DG.Tweening.Ease.Linear)
	end

	progress.ProgressToValueWithCallBack(progress, 1, TalentTreeConfig.ActiveLongPressTime, 0, DG.Tweening.Ease.Linear, self.CreateActionWithArgs(self, self.OnEndProgressEnd, progressStu))
end

M.OnEndLongPress = function(self, progressStu)
	if table.isNilOrEmpty(progressStu) then
		return
	end

	local progress = progressStu.progress

	progress.StopProgress(progress)
	progress.ProgressToValue(progress, 0, 0, 0, DG.Tweening.Ease.Linear)

	if self.toolTipStore then
		self.toolTipStore.progress:StopProgress()
		self.toolTipStore.progress:ProgressToValue(0, 0, 0, DG.Tweening.Ease.Linear)
	end
end

M.OnEndProgressEnd = function(self, progressStu)
	progressStu.progress:ProgressToValue(0, 0, 0, DG.Tweening.Ease.Linear)

	if self.toolTipStore then
		self.toolTipStore.progress:ProgressToValue(0, 0, 0, DG.Tweening.Ease.Linear)
	end

	if self.gameplayId == 0 then
		self.mgr:AskActiveGameplayTalent(self.gameplayId, progressStu.id)
	else
		self.mgr:AskActiveTalent(nil, self.jobClass, progressStu.id)
	end
end

M.OnTalentInfoChange = function(self)
	if self.gameplayId == 0 then
		self.bindData.talentTree.url, _, _ = self.mgr:GetGameplayCurrentGraphPath(self.gameplayId, self.treeId)
		self.bindData.talentCount = self.mgr:GetGameplayTalentPoint(self.gameplayId)
	else
		self.bindData.talentTree.url, self.stage, self.nextStageCount = self.mgr:GetCurrentGraphPath(self.treeId)
		self.bindData.talentCount = self.mgr:GetCurrentTalentPoint(self.jobClass)
	end

	self.bindData.talentTree:SelectItemById(self.currentTalent)

	if self.bgStore then
		self.OnRefreshBackGroudStore(self, self.bgStore)
	end
end

M.OnSpiritJobInfoChange = function(self, param)
	self.OnTalentInfoChange(self)
end
