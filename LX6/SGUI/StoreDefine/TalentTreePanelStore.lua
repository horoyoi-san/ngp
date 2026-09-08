-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TalentTreePanelStore.lua
-- Decompiled from: 01412_TalentTreePanelStore.lua_26a76a123a5f.luajit

local TalentTreeConfig = LTConfig.TalentTreeConfig
C_TalentTreePanelStore = DefClass("C_TalentTreePanelStore", C_TalentTreePanelStore, C_StoreGroup)
GroupName2Class.TalentTreePanelStore = C_TalentTreePanelStore
local M = C_TalentTreePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.mgr = gTalentTreeMgr
end

M.DefineAllVariables = function(self)
	self.showData = {}
	self.displayStore = nil
	self.isInLinkMode = false
	self.tabScrollPositions = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.ShowMainPage = BOOL2CTL[gMainPageManager:CheckMainPageShowById(self.m_Id)]
	self.bindData.akxCtrl = BOOL2CTL[gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Akx)]
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	gNewGuideMgr:NotifySignal(EGuideSignal.TalentTreeOpen)
	self.mgr:OnStartCurrent()

	self.isInLinkMode = gLinkManager:CheckInLinkMode()

	self:RefreshTab(data and data.jobClassId, data and data.gameplayId)
end

M.RefreshTab = function(self, jobClass, gameplayId)
	local tabData = self.mgr:GetAllTalentTreeTab(jobClass, gameplayId)
	local currentIndex = 0

	for i = 1, #tabData do
		if tabData[i].current then
			currentIndex = i - 1

			break
		end
	end

	self.SubGroup.CommonTabSingleStore:SetData(tabData, nil, currentIndex, 0, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem), false)
end

M.OnChangeTab = function(self, uList, isSub)
	local item = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
	local id = item and item.id or 0
	local cfg = TalentTreeConfig.GetConfig(id)

	if not cfg then
		return
	end

	self:SaveCurrentScrollPosition()

	local gameplayId = cfg.GameplayId or 0

	if gameplayId == 0 then
		self.showData = {
			gameplayId = gameplayId,
			treeId = cfg.Id,
			itemId = cfg.ConsumableId
		}
	else
		self.showData = {
			jobClass = cfg.JobClassId,
			treeId = cfg.Id,
			itemId = cfg.ConsumableId
		}
	end

	local tabIndex = cfg.TabIndex

	if self.bindData.tabRect.selectedIndex ~= tabIndex then
		self.ShowStore(self, self.displayStore)
	else
		self.bindData.tabRect:SelectIndexWithClose(tabIndex)
	end
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	local id = data and data.id or 0
	local cfg = TalentTreeConfig.GetConfig(id)

	if not cfg then
		return
	end

	btn.redId = cfg.RedDotId
	btn.templateKey = "Base"
end

M.OnClose = function(self)
	if self.displayStore then
		self.displayStore:OnClose()

		self.displayStore = nil
	end

	self.bindData.tabRect:SelectIndexWithClose(-1)
	self.mgr:OnExit()
	self:DefineAllVariables()
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SPIRIT_TALENT_CHANGE] = self.CreateAction(self, "OnSpiritJobInfoChange"),
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "OnLinkModeChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnCloseBtnClick)

	if self.bindData.akxBtn then
		self.bindData.akxBtn.luaClick = self.CreateAction(self, self.OnAkxBtnClick)
	end
end

M.OnTabRectRender = function(self, index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	self:ShowStore(store)
end

M.ShowStore = function(self, store)
	if self.displayStore then
		self.displayStore:OnClose()
	end

	if store then
		store.OnShow(store, self.m_Id, self.showData)

		self.displayStore = store

		self.RestoreScrollPosition(self)
	end
end

M.SaveCurrentScrollPosition = function(self)
	if not self.displayStore then
		return
	end

	local tree = self.displayStore.bindData and self.displayStore.bindData.talentTree
	local treeId = self.showData and self.showData.treeId

	if tree and treeId then
		self.tabScrollPositions[treeId] = tree.normalizedScrollPosition
	end
end

M.RestoreScrollPosition = function(self)
	if not self.displayStore then
		return
	end

	local tree = self.displayStore.bindData and self.displayStore.bindData.talentTree
	local treeId = self.showData and self.showData.treeId
	local saved = treeId and self.tabScrollPositions[treeId]

	if tree and saved then
		tree.normalizedScrollPosition = saved
	end
end

M.OnCloseBtnClick = function(self)
	if gCommonItemManager.itemToolTipRefBtn then
		gCommonItemManager:CloseItemToolTips()

		return
	end

	gPanelManager:Close(self.m_Id)
end

M.OnSpiritJobInfoChange = function(self, evnetId, param)
	if self.displayStore and self.displayStore.OnSpiritJobInfoChange then
		self.displayStore:OnSpiritJobInfoChange(param)
	end
end

M.OnLinkModeChange = function(self)
	local wasInLinkMode = self.isInLinkMode
	self.isInLinkMode = gLinkManager:CheckInLinkMode()

	if wasInLinkMode == self.isInLinkMode then
		if self.displayStore then
			self.displayStore:OnClose()

			self.displayStore = nil
		end

		self.bindData.tabRect:SelectIndexWithClose(-1)
		self:RefreshTab()
	end
end

M.OnAkxBtnClick = function(self)
	gAkxManager:OpenAkxPanel(true, gAkxManager.AkxEntry.TalentTree)
end
