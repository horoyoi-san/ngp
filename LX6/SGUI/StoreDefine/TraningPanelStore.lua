-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TraningPanelStore.lua
-- Decompiled from: 01169_TraningPanelStore.lua_4fb0067c1cc2.luajit

local CombatTrainingConfig = LTConfig.CombatTrainingConfig
local UNavigationMgr = SGUI.UNavigationMgr
C_TraningPanelStore = DefClass("C_TraningPanelStore", C_TraningPanelStore, C_StoreGroup)
GroupName2Class.TraningPanelStore = C_TraningPanelStore
local M = C_TraningPanelStore

M.ctor = function(self)
	self.mgr = gChallengeManager
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnExit)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnStartBtnClick)
	self.bindData.freeBtn.luaClick = self.CreateAction(self, self.OnFreeBtnClick)
	self.bindData.bgCloseBtn.luaClick = self.CreateAction(self, self.OnExit)
	self.bindData.taskList.luaSelectedChanged = self.CreateAction(self, self.OnChangeTask)
	self.bindData.taskList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTaskItem)
	self.bindData.taskList.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
	self.taskId = 0
	self.currentTab = 0
	self.contentList = {}
	self.back2Base = self.CreateAction(self, self.OnBack2Base)
end

M.OnShow = function(self, panelId, data)
	self.currentTab = data and data.tabIndex or 0
	local tabList = self.mgr:GetCurrentTrainingTab()

	self.SubGroup.CommonTabSingleStore:SetData(tabList, nil, self.currentTab, nil, self:CreateAction(self.OnChangeTab))
end

M.OnGroupEnable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", true)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", true)
end

M.OnGroupDisable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", false)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", false)
end

M.OnClose = function(self)
end

M.OnExit = function(self)
	gPanelManager:Close(self.m_Id)
end

M.RefreshPage = function(self)
	self.contentList = self.mgr:GetCurrentTrainingList(self.currentTab)

	self.bindData.taskList:SetSimpleList(#self.contentList)
	self.bindData.taskList:SelectItem(0)
end

M.OnStartBtnClick = function(self)
	if self.taskId ~= 0 then
		return
	end

	self.mgr:StartTraining(self.taskId)
end

M.OnFreeBtnClick = function(self)
	self.mgr:StartTraining(self.mgr.freeCombatTraingTaskId)
end

M.OnGetTIndex = function(self, index)
	local id = self.contentList[index + 1]
	local cfg = CombatTrainingConfig.GetConfig(id)
	local tag = cfg and cfg.AgentTag or 0

	return tag ~= 0 and 0 or 1
end

M.OnRenderTaskItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local id = self.contentList[index + 1]
	local cfg = CombatTrainingConfig.GetConfig(id)

	if not cfg or not store then
		return
	end

	store.titleLabel = cfg.Title
	local isCharacter = cfg.AgentTag == 0

	if isCharacter then
		gNpcFavorManager:OnRenderHeadAvatar(store.headAvatar, cfg.AgentTag)
	end

	local items = gCommonItemManager:GetItemSortedListByDropList({
		{
			["N\\xa1\\xb7\\xa1\\xa2"] = 1,
			dropId = cfg.DropId
		}
	}, true)
	local itemList = {}

	for j = 1, #items do
		local view = {
			["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = true,
			itemId = items[j].Id,
			itemNum = items[j].Count,
			IsOwned = items[j].isGot
		}

		table.insert(itemList, gCommonItemManager:GetItemRenderData(view))
	end

	store.dropList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderDropItem, itemList)

	store.dropList:SetSimpleList(#itemList)

	store.backBtn.luaClick = self.back2Base
end

M.OnRenderDropItem = function(self, itemList, btn, index)
	gCommonItemManager:OnCommonItemRender(btn, 0, itemList[index + 1])
end

M.OnChangeTask = function(self, uList)
	local index = uList.selectedIndex
	local data = self.contentList[index + 1]
	local cfg = CombatTrainingConfig.GetConfig(data)

	if not cfg then
		return
	end

	self.taskId = cfg.TaskId
end

M.OnChangeTab = function(self, uList, isSubTab)
	local item = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
	self.currentTab = item.id

	self:RefreshPage()
end

M.OnBack2Base = function(self)
	if self.bindData.mainNavigationArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.mainNavigationArea
	end
end
