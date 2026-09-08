-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComputerCoreHudTaskGuideStore.lua
-- Decompiled from: 01546_ComputerCoreHudTaskGuideStore.lua_ae3df4918a8a.luajit

C_ComputerCoreHudTaskGuideStore = DefClass("C_ComputerCoreHudTaskGuideStore", C_ComputerCoreHudTaskGuideStore, C_StoreGroup)
GroupName2Class.ComputerCoreHudTaskGuideStore = C_ComputerCoreHudTaskGuideStore
local M = C_ComputerCoreHudTaskGuideStore
local COMPUTER_TASK_GUIDE_TASK_IDS = {
	[60017737.0] = true,
	[60017736.0] = true
}

M.ctor = function(self)
	self.isStart = false
	self.panelCallback = {}
	self.curTaskId = 0
	self.currentTaskType = 0
	self.curTaskIsFirst = false
	self.curTaskInfo = nil
	self.preTaskInfo = nil
	self.curType = -1
	self.curTypeStore = nil
	self.shortCutRecordById = {}
	self.curCfgId = 0
	self.isShowShortCut = false
	self.isShowMapPanel = false
	self.cultivationId = nil
	self.listenHpChanged = false
	self.isInTaskRaid = false
	self.isInRelateTaskRaid = false
	self.taskGuideActive = true
	self.isNoTaskGuide = false
	self.isShowGiveUp = false
	self.isShowRetry = false
	self.isShowTaskCounter = false
end

M.OnAwake = function(self)
	self.msgEvents = {
		[gEventConstants.CURRENT_TASK_CHANGE] = self:CreateAction("OnCurrentChange"),
		[gEventConstants.TASK_EVENT_CHANGE] = self:CreateAction("OnTaskEventChange"),
		[gEventConstants.TEMPORARY_CURRENT_TASK_CHANGE] = self:CreateAction("OnTempChange"),
		[gEventConstants.TASK_SHORTCUT_CHANGE] = self:CreateAction("OnTaskShortcutChange"),
		[gEventConstants.ON_SYNC_TASK_RIDE_NPC_CULTIVATION_ID] = self:CreateAction("OnSyncRideCultivationId"),
		[gEventConstants.CHANGE_COUNTER_DES_GPS] = self:CreateAction("OnChangeCurDes")
	}

	self:RegisterMessageEvents(self.msgEvents)
	self.bindData.gameBarPanel:SetActive(false)

	self.bindData.tab.OnRenderTab = self:CreateAction("OnRenderTaskTab")

	if self.bindData.entranceBtn then
		self.bindData.entranceBtn:SetActive(false)
	end
end

M.OnStart = function(self)
	self.isStart = true

	if self.panelCallback then
		for _, func in ipairs(self.panelCallback) do
			func()
		end

		self.panelCallback = {}
	end
end

M.OnShow = function(self)
	self.RefreshComputerTaskGuide(self)
end

M.OnGroupDisable = function(self)
	self.isStart = false
	self.panelCallback = {}
	self.curTaskId = 0
	self.currentTaskType = 0
	self.curTaskIsFirst = false
	self.curTaskInfo = nil
	self.preTaskInfo = nil
	self.curType = -1
	self.curTypeStore = nil
	self.shortCutRecordById = {}
	self.curCfgId = 0
	self.isShowShortCut = false
	self.cultivationId = nil
	self.listenHpChanged = false
	self.isInTaskRaid = false
	self.isInRelateTaskRaid = false
	self.taskGuideActive = true
	self.isNoTaskGuide = false
	self.isShowGiveUp = false
	self.isShowRetry = false
	self.isShowTaskCounter = false
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnRenderTaskTab = function(self, _, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(self.curTypeData)
	end
end

M.OpenTaskPanel = function(self, type, data)
	if not self.isStart then
		table.insert(self.panelCallback, function ()
			self:OpenTaskPanel(type, data)
		end)

		return
	end

	self.curType = type
	self.curTypeData = data
	self.bindData.tab.selectedIndex = self.curType
end

M.CloseTaskPanel = function(self, data)
	if not self.isStart then
		table.insert(self.panelCallback, function ()
			self:CloseTaskPanel(data)
		end)

		return
	end

	if self.curTypeStore and self.curTypeStore.OnClose then
		self.curTypeStore:OnClose(data)
	end

	self.curType = -1
	self.curTypeStore = nil
	self.curTypeData = nil

	if self.bindData.tab then
		self.bindData.tab.selectedIndex = self.curType
	end
end

M.SetTaskGuidePanelActive = function(self, active)
	self.bindData.taskGuidePanel:SetActive(active)
end

M.CheckTaskPanelState = function(self, panelState)
	return self.curType ~= panelState
end

M.HandlePanelClose = function(self)
	if self.curTaskInfo then
		self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.Normal)
	else
		self.CloseTaskPanel(self)
	end
end

M.OnCurrentChange = function(self)
	self.RefreshComputerTaskGuide(self)
end

M.OnTaskEventChange = function(self)
	self.RefreshComputerTaskGuide(self)
end

M.OnTempChange = function(self)
	self.RefreshComputerTaskGuide(self)
end

M.OnTaskShortcutChange = function(self)
	self.SyncFromMainTaskGuide(self)

	if self.curTypeStore and self.curTypeStore.HandleTaskShortCut then
		self.curTypeStore:HandleTaskShortCut()
	end
end

M.OnSyncRideCultivationId = function(self, _, cultivationId)
	self.cultivationId = cultivationId

	if self.curTypeStore and self.curTypeStore.RefreshCurrentTaskDes then
		self.curTypeStore:RefreshCurrentTaskDes()
	end
end

M.OnChangeCurDes = function(self, eventId, data)
	if not self.isStart then
		table.insert(self.panelCallback, function ()
			self:OnChangeCurDes(eventId, data)
		end)

		return
	end

	if self.curTypeStore and self.curTypeStore.OnChangeCurDes then
		self.curTypeStore:OnChangeCurDes(eventId, data)
	end
end

M.SyncFromMainTaskGuide = function(self)
	local mainStore = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")

	if not mainStore then
		return
	end

	self.curTaskId = mainStore.curTaskId or 0
	self.currentTaskType = mainStore.currentTaskType or 0
	self.curTaskIsFirst = mainStore.curTaskIsFirst or false
	self.curTaskInfo = mainStore.curTaskInfo
	self.preTaskInfo = mainStore.preTaskInfo
	self.shortCutRecordById = mainStore.shortCutRecordById or {}
	self.curCfgId = mainStore.curCfgId or 0
	self.isShowShortCut = mainStore.isShowShortCut or false
	self.isShowMapPanel = mainStore.isShowMapPanel or false
	self.cultivationId = mainStore.cultivationId
	self.listenHpChanged = mainStore.listenHpChanged or false
	self.isInTaskRaid = mainStore.isInTaskRaid or false
	self.isInRelateTaskRaid = mainStore.isInRelateTaskRaid or false
	self.taskGuideActive = mainStore.taskGuideActive == false
	self.isNoTaskGuide = mainStore.isNoTaskGuide or false
	self.isShowGiveUp = mainStore.isShowGiveUp or false
	self.isShowRetry = mainStore.isShowRetry or false
	self.isShowTaskCounter = mainStore.isShowTaskCounter or false
	self.IsFirstTime = mainStore.IsFirstTime or false
end

M.RefreshComputerTaskGuide = function(self)
	local taskId = gTaskNodeManager:GetNowDoingTask()

	if not taskId or not COMPUTER_TASK_GUIDE_TASK_IDS[taskId] then
		self.CloseTaskPanel(self)

		return
	end

	self.SyncFromMainTaskGuide(self)

	if not self.curTaskInfo or string.is_null_or_empty(self.curTaskInfo.EventObjective or "") then
		self.CloseTaskPanel(self)

		return
	end

	self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.Normal)
end
