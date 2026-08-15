local CombatTrainingConfig = LTConfig.CombatTrainingConfig
local UNavigationMgr = SGUI.UNavigationMgr
C_TraningPanelStore = DefClass("C_TraningPanelStore", C_TraningPanelStore, C_StoreGroup)
GroupName2Class.TraningPanelStore = C_TraningPanelStore
local M = C_TraningPanelStore
local BOOL2CTL = gClientConst.BOOL2CTL

function M:ctor()
	self.mgr = gChallengeManager
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnExit)
	self.bindData.startBtn.luaClick = self:CreateAction(self.OnStartBtnClick)
	self.bindData.freeBtn.luaClick = self:CreateAction(self.OnFreeBtnClick)
	self.bindData.taskList.luaSelectedChanged = self:CreateAction(self.OnChangeTask)
	self.bindData.taskList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTaskItem)
	self.bindData.taskList.onGetTIndex = self:CreateAction(self.OnGetTIndex)
	self.taskId = 0
	self.currentTab = 0
	self.contentList = {}
	self.back2Base = self:CreateAction(self.OnBack2Base)
end

function M:OnShow(panelId, data)
	self.currentTab = data and data.tabIndex or 0
	local tabList = self.mgr:GetCurrentTrainingTab()

	self.SubGroup.CommonTabSingleStore:SetData(tabList, nil, self.currentTab, nil, self:CreateAction(self.OnChangeTab))
end

function M:OnClose()
	return
end

function M:OnExit()
	gPanelManager:Close(self.m_Id)
end

function M:RefreshPage()
	self.contentList = self.mgr:GetCurrentTrainingList(self.currentTab)

	self.bindData.taskList:SetSimpleList(#self.contentList)
	self.bindData.taskList:SelectItem(0)
end

function M:OnStartBtnClick()
	if self.taskId == 0 then
		return
	end

	self.mgr:StartTraining(self.taskId)
end

function M:OnFreeBtnClick()
	self.mgr:StartTraining(self.mgr.freeCombatTraingTaskId)
end

function M:OnGetTIndex(index)
	local id = self.contentList[index + 1]
	local cfg = CombatTrainingConfig.GetConfig(id)
	local tag = cfg and cfg.AgentTag or 0

	return tag == 0 and 0 or 1
end

function M:OnRenderTaskItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local id = self.contentList[index + 1]
	local cfg = CombatTrainingConfig.GetConfig(id)

	if not cfg or not store then
		return
	end

	store.titleLabel = cfg.Title
	local isCharacter = cfg.AgentTag ~= 0

	if isCharacter then
		gNpcFavorManager:OnRenderHeadAvatar(store.headAvatar, cfg.AgentTag)
	end

	local items = gCommonItemManager:GetItemSortedListByDropList({
		{
			count = 1,
			dropId = cfg.DropId
		}
	}, true)
	local itemList = {}

	for j = 1, #items do
		local view = {
			isFirstKill = true,
			itemId = items[j].Id,
			itemNum = items[j].Count,
			IsOwned = items[j].isGot,
			countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP
		}

		table.insert(itemList, gCommonItemManager:GetItemRenderData(view))
	end

	store.dropList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderDropItem, itemList)

	store.dropList:SetSimpleList(#itemList)

	store.backBtn.luaClick = self.back2Base
end

function M:OnRenderDropItem(itemList, btn, index)
	gCommonItemManager:OnCommonItemRender(btn, 0, itemList[index + 1])
end

function M:OnChangeTask(uList)
	local index = uList.selectedIndex
	local data = self.contentList[index + 1]
	local cfg = CombatTrainingConfig.GetConfig(data)

	if not cfg then
		return
	end

	self.taskId = cfg.TaskId
end

function M:OnChangeTab(uList, isSubTab)
	local item = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
	self.currentTab = item.id

	self:RefreshPage()
end

function M:OnBack2Base()
	if self.bindData.mainNavigationArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.mainNavigationArea
	end
end
