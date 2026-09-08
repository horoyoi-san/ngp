-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonGamePlayTalentTreePanelStore.lua
-- Decompiled from: 01527_CommonGamePlayTalentTreePanelStore.lua_8762a03267e1.luajit

local TalentConfig = LTConfig.TalentTreeTalentConfig
local TalentTreeConfig = LTConfig.TalentTreeConfig
local EInvokeTime = SGUI.EInvokeTime
C_CommonGamePlayTalentTreePanelStore = DefClass("C_CommonGamePlayTalentTreePanelStore", C_CommonGamePlayTalentTreePanelStore, C_StoreGroup)
GroupName2Class.CommonGamePlayTalentTreePanelStore = C_CommonGamePlayTalentTreePanelStore
local M = C_CommonGamePlayTalentTreePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.mgr = gTalentTreeMgr
end

M.IsMobileAdaptive = function(self)
	return not gCS.LuaUtils.IsNonMobileAdaptive()
end

M.DefineAllVariables = function(self)
	self.currentTalent = 0
	self.gameplayId = 0
	self.treeId = 0
	self.cfg = nil
	self.toolTipStore = nil
	self.talentId2Btn = {}
	self.btn2TalentId = {}
	self.itemToolTipData = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.showTooltipEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showResetEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showTooltipEnum = nil
	self.showResetEnum = nil
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
	self.gameplayId = data and data.gameplayId or 0
	self.treeId = self.mgr:GetGameplayTalentTreeId(self.gameplayId)
	self.cfg = TalentTreeConfig.GetConfig(self.treeId)
	self.itemToolTipData = gCommonItemManager:GetItemRenderData(data and data.itemId or 0)
	self.bindData.talentPointBtn.interactable = not string.is_null_or_empty(self.itemToolTipData.name)
	self.bindData.showReset = BOOL2CTL[self.cfg and self.cfg.EnableReset or false]

	self:OnGamePlayTalentChange(nil, {
		gameplayId = self.gameplayId
	})
end

M.OnClose = function(self)
	self.talentId2Btn = {}

	self.DefineAllVariables(self)

	self.bindData.showTooltip = BOOL2CTL[false]
	self.bindData.talentTree.url = ""
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.GAMEPLAY_TALENT_CHANGE] = self.CreateAction(self, self.OnGamePlayTalentChange),
		[gEventConstants.GAMEPLAY_TALENT_ACTIVE] = self.CreateAction(self, self.OnGamePlayTalentActive),
		[gEventConstants.SELECTED_TALENT_ID] = self.CreateAction(self, self.SetSelectedTalentId)
	}
end

M.OnGamePlayTalentActive = function(self, eventId, data)
	if not data or data.gameplayId == self.gameplayId then
		return
	end

	local btn = self.talentId2Btn[data.talentId]

	if not btn then
		return
	end

	btn.InvokeCallback(btn, EInvokeTime.User1)
end

M.OnGamePlayTalentChange = function(self, eventId, data)
	if data and data.gameplayId and data.gameplayId == self.gameplayId then
		return
	end

	self.bindData.talentTree.url, _, _ = self.mgr:GetGameplayCurrentGraphPath(self.gameplayId)
	self.bindData.talentCount = self.mgr:GetGameplayTalentPoint(self.gameplayId)

	self.bindData.talentTree:SelectItemById(self.currentTalent)
end

M.RegisterWidget = function(self)
	self.bindData.talentTree.luaSelectedChanged = self.CreateAction(self, self.OnTalentTreeItemChange)
	self.bindData.talentTree.luaOnSetTalentData = self.CreateAction(self, self.OnTalentTreeSet)
	self.bindData.talentTree.luaRenderItem = self.CreateAction(self, self.OnTalentTreeRenderItem)
	self.bindData.talentPointBtn.luaRenderTooltip = self.CreateAction(self, self.OnRenderToolTips)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.talentPointBtn.luaClick = self.CreateAction(self, "OnClickTalentPointBtn")
	self.bindData.resetBtn.luaClick = self.CreateAction(self, "OnClickResetBtn")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
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
		if not fromset then
			self.bindData.talentToolTip:InvokeCallback(EInvokeTime.User1)
		end

		self.bindData.talentToolTip:InvokeCallback(EInvokeTime.Show)

		self.toolTipStore = self.mgr:RefreshGameplayTalentToolTip(self.bindData.talentToolTip, self.currentTalent, self.gameplayId, self:CreateAction(self.OnDeSelectedData))
	else
		self.bindData.talentTree:DeselectAll()
	end
end

M.OnDeSelectedData = function(self)
	if self.bindData.showTooltip ~= BOOL2CTL[false] then
		return
	end

	self.OnSetSelectedTalentId(self, 0, false, false)
end

M.OnTalentTreeSet = function(self, itemDatas)
	local itemList = itemDatas.ToTable(itemDatas)

	for i = 1, #itemList do
		local talentId = itemList[i].talentId
		local isLocked = self.mgr:CheckGameplayTalentIsLocked(talentId, self.gameplayId)
		local canUnlock, _ = self.mgr:CheckGameplayTalentCanUnlock(talentId, self.gameplayId, true)
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

M.SetSelectedTalentId = function(self, _, talentId)
	self.bindData.talentTree:SelectItemById(talentId)
end

M.OnSetSelectedTalentId = function(self, talentId, flag, fromset)
	self.currentTalent = talentId

	self.OnChangeToolTips(self, flag, fromset)
end

M.OnTalentTreeRenderItem = function(self, btn, index, data)
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		print_error("[CommonGamePlayTalentTreePanelStore] storeGroup not found ", btn.Store)

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
	store.isLackTalentPoint = BOOL2CTL[self.mgr:GetGameplayTalentPoint(self.gameplayId) <= cfg.CostPoint or not self.mgr:CheckTalentCostItemEnough(data.talentId, self.gameplayId)]

	if cfg.LayerNum <= 1 then
		local talentDict = self.mgr:GetGameplayTalentDict(self.gameplayId)
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

	btn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPress, progressStu)
	btn.luaEndLongPress = self.CreateActionWithArgs(self, self.OnEndLongPress, progressStu)
end

M.OnBeginLongPress = function(self, progressStu)
	if table.isNilOrEmpty(progressStu) then
		return
	end

	local canUnlock, _ = self.mgr:CheckGameplayTalentCanUnlock(progressStu.id, self.gameplayId)

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

	self.mgr:AskActiveGameplayTalent(self.gameplayId, progressStu.id)
end

M.OnClickTalentPointBtn = function(self)
end

M.OnClickResetBtn = function(self)
	self.mgr:OnResetGameplayTalentTree(self.gameplayId)
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

	self.mgr:RefreshGameplayTalentToolTip(popup, talentId, self.gameplayId, self:CreateAction(self.OnDeSelectedData))
end
