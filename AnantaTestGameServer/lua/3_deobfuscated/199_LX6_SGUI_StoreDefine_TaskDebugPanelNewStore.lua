local RoomMgr = LX6.Share.RoomMgr.Instance
C_TaskDebugPanelNewStore = DefClass("C_TaskDebugPanelNewStore", C_TaskDebugPanelNewStore, C_StoreGroup)
GroupName2Class.TaskDebugPanelNewStore = C_TaskDebugPanelNewStore
local M = C_TaskDebugPanelNewStore
local ButtonListInfo = {
	{
		name = "信息",
		Type = 1
	},
	{
		name = "Room",
		Type = 2
	},
	{
		name = "到点触发",
		Type = 3
	}
}

function M:ctor()
	self.buttonList = {}

	self:ResetAll()

	self.workActionCache = {}
end

function M:OnAwake()
	self.EventHandler = {
		[gEventConstants.CURRENT_TASK_CHANGE] = function ()
			self:RefreshTaskData()
		end
	}

	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end

	self:RegisterBtnEvent()
end

function M:RegisterBtnEvent()
	self.bindData.btnTeleport.luaClick = self:CreateAction("OnTeleport")
	self.bindData.btnFinishTask.luaClick = self:CreateAction("OnFinishTask")
	self.bindData.btnHide.luaClick = self:CreateAction("OnHide")
	self.bindData.btnDrwaRomm1.luaClick = self:CreateAction("OnDrwaRomm1")
	self.bindData.btnDrwaRomm2.luaClick = self:CreateAction("OnDrwaRomm2")
	self.bindData.btnDrwaRomm3.luaClick = self:CreateAction("OnDrwaRomm3")
	self.bindData.btnDrwaRomm4.luaClick = self:CreateAction("OnDrwaRomm4")
	self.bindData.btnDrwaRomm5.luaClick = self:CreateAction("OnDrwaRomm5")
	self.bindData.btnList.luaSimpleClick = self:CreateAction("SelectPage")
	self.bindData.btnList.luaSimpleRenderItem = self:CreateAction("SetName")
end

function M:OnShow()
	self:InitButtonList()
	self:RefreshTaskData()
end

function M:OnClose()
	return
end

function M:ResetAll()
	self.bindData.taskName = "当前任务: " .. "无"
	self.bindData.taskRaid = "（当前/任务）副本: " .. "无"
	self.bindData.taskCounter = "当前任务计数器: " .. "无"
	self.bindData.taskLine = "当前任务线: " .. "无"
	self.bindData.taskDialogTrigger = "Dialog是否已自动触发: " .. "无"
	self.bindData.taskGps = "Gps定位: " .. "无"
	self.bindData.taskTitle = "任务调试面板"
end

function M:SetName(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		local type = index + 1

		for i = 1, #ButtonListInfo do
			if ButtonListInfo[i].Type == type then
				store.nameLabel = ButtonListInfo[i].name

				break
			end
		end
	end
end

function M:InitButtonList()
	self.buttonList = {}

	for i = 1, #ButtonListInfo do
		local view = {}
		view = {
			name = ButtonListInfo[i].name
		}

		table.insert(self.buttonList, view)
	end

	self.bindData.btnList:SetSimpleList(#self.buttonList)
	self:SelectTab(0)
end

function M:SelectTab(index)
	if not self.bindData.btnList or not self.bindData.btnList.selectedIndex then
		return
	end

	self.bindData.pageTab = index
end

function M:RefreshTaskData()
	self:ResetAll()

	local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if not taskId or taskId == 0 then
		return
	end

	local cfg = gTaskManager:GetTaskConfigInfo(taskId)

	if not cfg then
		return
	end

	self.bindData.taskName = "当前任务: " .. taskId .. "-" .. cfg.Name
	self.bindData.taskRaid = "（当前/任务）副本: " .. gRaidDataManager.RaidId .. "/" .. cfg.RelatedRaid
	self.bindData.taskCounter = "当前任务计数器: " .. gTaskNodeManager:FindFirstCounterIndex(taskId) .. "/" .. (cfg.Counter and #cfg.Counter or 0)
	local taskLineInfo = gTaskNodeManager:GetTaskLineById(gTaskNodeManager.NowDoingTaskLine)

	if taskLineInfo then
		self.bindData.taskLine = taskLineInfo and "当前任务线: " .. gTaskNodeManager.NowDoingTaskLine .. " - " .. taskLineInfo.EventName or "当前任务线: " .. "无"
	end

	self.bindData.taskDialogTrigger = "Dialog是否已自动触发: " .. tostring(gDialogManager:IsDialogRunning())
end

function M:HideWorkAction()
	if self.workActionCache then
		for _, v in ipairs(self.workActionCache) do
			GameObject.Destroy(v)
		end

		self.workActionCache = {}
	end
end

function M:DrawWorkAction()
	self:HideWorkAction()
end

function M:OnTeleport()
	if not gTaskNodeManager.NowDoingTask or not gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] then
		return
	end

	local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] > 0 then
		local taskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(taskId)

		if not taskInfo then
			return
		end

		local pos = taskInfo.UseTansGuide and not gCS.LuaUtils.IsNull(taskInfo.TargetTrans) and taskInfo.TargetTrans.position or taskInfo.TargetPos

		if pos then
			L50.Gm.AutoQaFunctions.TeleportXYZ(pos.x, pos.y, pos.z)
		else
			gDisplayMessageMgr:ShowMessageContentDebug("无法传送到此")
		end
	end
end

function M:OnFinishTask()
	if not gTaskNodeManager.NowDoingTask or not gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] then
		return
	end

	L50.Gm.AutoQaFunctions.SubmitTask(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])
end

function M:OnHide()
	gPanelManager:Close(gPanelId.TASK_DEBUG_PANEL_NEW)
end

function M:SelectPage()
	self:SelectTab(self.bindData.btnList.selectedIndex)
end

function M:OnDrwaRomm1()
	RoomMgr:DrawRoom(1)
end

function M:OnDrwaRomm2()
	RoomMgr:DrawRoom(0)
end

function M:OnDrwaRomm3()
	RoomMgr:RemoveDrawRoom()
end

function M:OnDrwaRomm4()
	self:DrawWorkAction()
end

function M:OnDrwaRomm5()
	self:HideWorkAction()
end
