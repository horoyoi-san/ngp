-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TaskDebugPanelNewStore.lua
-- Decompiled from: 01408_TaskDebugPanelNewStore.lua_d4948e41680e.luajit

local RoomMgr = L18.Spoon.Task.SpoonRoomMgr.Instance
C_TaskDebugPanelNewStore = DefClass("C_TaskDebugPanelNewStore", C_TaskDebugPanelNewStore, C_StoreGroup)
GroupName2Class.TaskDebugPanelNewStore = C_TaskDebugPanelNewStore
local M = C_TaskDebugPanelNewStore
local ButtonListInfo = {
	{
		["t#p^"] = "\\x98\\x97Pb\\x8e",
		["N;m^"] = 1
	},
	{
		["t#p^"] = "H-rV",
		["N;m^"] = 2
	},
	{
		["t#p^"] = "\\xea\\x9e|\\xf0\\xaekz\\x80\\xac\\xff\\x91\\xbd",
		["N;m^"] = 3
	}
}

M.ctor = function(self)
	self.buttonList = {}

	self.ResetAll(self)

	self.workActionCache = {}
end

M.OnAwake = function(self)
	self.EventHandler = {
		[gEventConstants.CURRENT_TASK_CHANGE] = function ()
			self:RefreshTaskData()
		end
	}

	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end

	self.RegisterBtnEvent(self)
end

M.RegisterBtnEvent = function(self)
	self.bindData.btnTeleport.luaClick = self.CreateAction(self, "OnTeleport")
	self.bindData.btnFinishTask.luaClick = self.CreateAction(self, "OnFinishTask")
	self.bindData.btnHide.luaClick = self.CreateAction(self, "OnHide")
	self.bindData.btnDrwaRomm1.luaClick = self.CreateAction(self, "OnDrwaRomm1")
	self.bindData.btnDrwaRomm2.luaClick = self.CreateAction(self, "OnDrwaRomm2")
	self.bindData.btnDrwaRomm3.luaClick = self.CreateAction(self, "OnDrwaRomm3")
	self.bindData.btnDrwaRomm4.luaClick = self.CreateAction(self, "OnDrwaRomm4")
	self.bindData.btnDrwaRomm5.luaClick = self.CreateAction(self, "OnDrwaRomm5")
	self.bindData.btnList.luaSimpleClick = self.CreateAction(self, "SelectPage")
	self.bindData.btnList.luaSimpleRenderItem = self.CreateAction(self, "SetName")
end

M.OnShow = function(self)
	self.InitButtonList(self)
	self.RefreshTaskData(self)
end

M.OnClose = function(self)
end

M.ResetAll = function(self)
	self.bindData.taskName = "当前任务: " .. "无"
	self.bindData.taskRaid = "（当前/任务）副本: " .. "无"
	self.bindData.taskCounter = "当前任务计数器: " .. "无"
	self.bindData.taskLine = "当前任务线: " .. "无"
	self.bindData.taskDialogTrigger = "Dialog是否已自动触发: " .. "无"
	self.bindData.taskGps = "Gps定位: " .. "无"
	self.bindData.taskTitle = "任务调试面板"
end

M.SetName = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		local type = index + 1

		for i = 1, #ButtonListInfo do
			if ButtonListInfo[i].Type ~= type then
				store.nameLabel = ButtonListInfo[i].name

				break
			end
		end
	end
end

M.InitButtonList = function(self)
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

M.SelectTab = function(self, index)
	if not self.bindData.btnList or not self.bindData.btnList.selectedIndex then
		return
	end

	self.bindData.pageTab = index
end

M.RefreshTaskData = function(self)
	self.ResetAll(self)

	local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if not taskId or taskId ~= 0 then
		return
	end

	local cfg = gTaskManager:GetTaskConfigInfo(taskId)

	if not cfg then
		return
	end

	self.bindData.taskName = "当前任务: " .. taskId .. "-" .. cfg.Name
	self.bindData.taskRaid = "（当前/任务）副本: " .. gRaidDataManager.RaidId .. "/" .. cfg.RelatedRaid
	self.bindData.taskCounter = "当前任务计数器: " .. (gTaskNodeManager:FindFirstCounterIndex(taskId) or 0) .. "/" .. (cfg.Counter and #cfg.Counter or 0)
	local taskLineInfo = gTaskNodeManager:GetTaskLineById(gTaskNodeManager.NowDoingTaskLine)

	if taskLineInfo then
		self.bindData.taskLine = taskLineInfo and "当前任务线: " .. gTaskNodeManager.NowDoingTaskLine .. " - " .. taskLineInfo.EventName or "当前任务线: " .. "无"
	end

	self.bindData.taskDialogTrigger = "Dialog是否已自动触发: " .. tostring(gDialogManager:IsDialogRunning())
end

M.HideWorkAction = function(self)
	if self.workActionCache then
		for _, v in ipairs(self.workActionCache) do
			GameObject.Destroy(v)
		end

		self.workActionCache = {}
	end
end

M.DrawWorkAction = function(self)
	self.HideWorkAction(self)
end

M.OnTeleport = function(self)
	if not gTaskNodeManager.NowDoingTask or not gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] then
		return
	end

	local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] <= 0 then
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

M.OnFinishTask = function(self)
	if not gTaskNodeManager.NowDoingTask or not gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] then
		return
	end

	L50.Gm.AutoQaFunctions.SubmitTask(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])
end

M.OnHide = function(self)
	gPanelManager:Close(gPanelId.TASK_DEBUG_PANEL_NEW)
end

M.SelectPage = function(self)
	self.SelectTab(self, self.bindData.btnList.selectedIndex)
end

M.OnDrwaRomm1 = function(self)
	RoomMgr:DrawRoom(1)
end

M.OnDrwaRomm2 = function(self)
	RoomMgr:DrawRoom(0)
end

M.OnDrwaRomm3 = function(self)
	RoomMgr:RemoveDrawRoom()
end

M.OnDrwaRomm4 = function(self)
	self.DrawWorkAction(self)
end

M.OnDrwaRomm5 = function(self)
	self.HideWorkAction(self)
end
