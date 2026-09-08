-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TaskFullscreenStore.lua
-- Decompiled from: 01407_TaskFullscreenStore.lua_d3b02fce0307.luajit

C_TaskFullscreenStore = DefClass("C_TaskFullscreenStore", C_TaskFullscreenStore, C_StoreGroup)
GroupName2Class.TaskFullscreenStore = C_TaskFullscreenStore
local M = C_TaskFullscreenStore
local TaskConfig = LTConfig.TaskConfig
local TaskTitleConfig = LTConfig.TaskTitleConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local FloorToInt = math.floor

M.ctor = function(self)
	self.m_TaskFailCountDown = nil
	self.m_TaskId = 0
	self.m_WaitHandle = nil
end

M.OnAwake = function(self)
	self.bindData.RePlayBtn.luaClick = self.CreateAction(self, "RePlay")
	self.bindData.GiveUpBtn.luaClick = self.CreateAction(self, "GiveUp")
	self.bindData.JumpBtn.luaClick = self.CreateAction(self, "Jump")
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.ShowType = data.ShowType
	self.m_TaskId = data.TaskId
	self.bindData.failBtnController = 0
	local cfg = TaskConfig.GetConfig(self.m_TaskId)

	if cfg then
		local title = cfg.Title
		local titleCfg = TaskTitleConfig.GetConfig(title)

		if titleCfg then
			local failPanelButton = titleCfg.FailPanelButton

			if not failPanelButton then
				self.bindData.failBtnController = 1

				self.DelayClose(self, 3)
			end
		end
	end

	if data.ShowType ~= 0 then
		if data.TaskStartMainLabel then
			self.bindData.TaskStartMainLabel = data.TaskStartMainLabel
		end

		if data.TaskStartSecondLabel then
			self.bindData.TaskStartSecondLabel = data.TaskStartSecondLabel
		end

		local delay = TaskConfig.TaskFullscreenPanelClose

		self.DelayClose(self, delay)
	elseif data.ShowType ~= 1 then
		self.bindData.GiveUpBtn.gameObject:SetActive(true)

		local eventInfo = gTaskNodeManager:GetTaskLineByTask(self.m_TaskId)

		if not table.isNilOrEmpty(eventInfo) then
			local eventTags = eventInfo.EventTag

			if array.contains(eventTags, TaskEventConfig.EventTagType.FailPanelNoAbort) then
				self.bindData.GiveUpBtn.gameObject:SetActive(false)
			end
		end

		if data.TaskFailMainLabel then
			self.bindData.TaskFailMainLabel = data.TaskFailMainLabel
		end

		if data.TaskFailSecondLabel then
			self.bindData.TaskFailSecondLabel = data.TaskFailSecondLabel
		end

		if data.OtherData then
			local isJump = data.OtherData.CanSkip or false
			self.bindData.JumpBthType = isJump and 1 or 0
		end

		self.m_TaskFailCountDown = TaskConfig.TaskFailedPanelClose
		self.bindData.failedPanelMode = 0
		local waitUnloadMaxTime = TaskConfig.WaitUnloadMaxTime

		if waitUnloadMaxTime <= 5 then
			waitUnloadMaxTime = 5
		end

		self._delayGiveUpHandle = gLuaTimeMgrUtils.Delay(function ()
			self._delayGiveUpHandle = nil
			self.bindData.failedPanelMode = 1
		end, waitUnloadMaxTime, nil, , true)
	elseif data.ShowType ~= 2 then
		if data.TaskSubmitMainLabel then
			self.bindData.TaskSubmitMainLabel = data.TaskSubmitMainLabel
		end

		if data.TaskSubmitSecondLabel then
			self.bindData.TaskSubmitSecondLabel = data.TaskSubmitSecondLabel
		end

		local delay = TaskConfig.TaskFullscreenPanelClose

		self.DelayClose(self, delay)
	end
end

M.OnUpdate = function(self)
	if self.bindData.ShowType ~= 1 and self.m_TaskFailCountDown <= 0 then
		self.m_TaskFailCountDown = self.m_TaskFailCountDown - Time.deltaTime
		self.bindData.TaskFailCountDownText = tostring(FloorToInt(self.m_TaskFailCountDown))

		if self.m_TaskFailCountDown < 0 then
			self.RePlay(self)
		end
	end
end

M.OnClose = function(self)
	if self.m_WaitHandle and self.m_WaitHandle <= 0 then
		L18.Spoon.Task.TaskManager.Instance:ClearTaskCustomResourceDependedLoadedHandle(self.m_WaitHandle)
	end

	self.m_WaitHandle = nil

	if not self._delayCloseHandle then
		gLuaTimeMgrUtils.CancelUnitDelay(self._delayCloseHandle)

		self._delayCloseHandle = nil
	end

	if not self._delayCloseHandle then
		gLuaTimeMgrUtils.CancelUnitDelay(self._delayCloseHandle)

		self._delayCloseHandle = nil
	end

	self.bindData.failedPanelMode = 1
end

M.OnActiveDeviceChange = function(self, device)
end

M.DelayClose = function(self, delay)
	if not delay or delay < 0 then
		delay = 1
	end

	self._delayCloseHandle = gLuaTimeMgrUtils.Delay(function ()
		self._delayCloseHandle = nil

		gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
	end, delay, nil, , true)
end

M.RePlay = function(self)
	if self.m_TaskId then
		if gDeadManager.isDead then
			slot1 = gClientToGameSceneDelegate

			slot1:AskReviveAndReAcceptTask(self.m_TaskId).Callback = function ()
			end
		else
			slot1 = gClientToGameDelegate

			slot1:AskReAcceptTaskFailGroup(self.m_TaskId).Callback = function ()
			end
		end

		self.bindData.failedPanelMode = 0
		local waitLoadMaxTime = TaskConfig.WaitLoadMaxTime
		slot2 = L18.Spoon.Task.TaskManager.Instance
		self.m_WaitHandle = slot2:WaitTaskResourceDependedLoadComplete(self.m_TaskId, waitLoadMaxTime, function ()
			self.bindData.failedPanelMode = 1

			gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
		end)
	else
		gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
	end
end

M.GiveUp = function(self)
	gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
	gTaskManager:RemoveCurrentTask(self.m_TaskId)

	if gDeadManager.isDead then
		gDeadManager:Revive(UX.Game.ReviveType.TaskRevive, true)
	end
end

M.Jump = function(self)
	if gDeadManager.isDead then
		gDeadManager:Revive(UX.Game.ReviveType.TaskRevive, true)
	end

	if self.m_TaskId and self.m_TaskId == 0 then
		slot1 = gClientToGameDelegate

		slot1:AskForceSkipTask(self.m_TaskId).Callback = function ()
		end

		self.bindData.failedPanelMode = 0
		local waitLoadMaxTime = TaskConfig.WaitLoadMaxTime
		slot2 = L18.Spoon.Task.TaskManager.Instance
		self.m_WaitHandle = slot2:WaitTaskResourceDependedLoadComplete(self.m_TaskId, waitLoadMaxTime, function ()
			self.bindData.failedPanelMode = 1

			gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
		end)
	else
		gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
	end
end

M.GetWaitHandle = function(self)
	if self.m_WaitHandle and self.m_WaitHandle <= 0 then
		L18.Spoon.Task.TaskManager.Instance:ClearTaskCustomResourceDependedLoadedHandle(self.m_WaitHandle)
	end

	return self.m_WaitHandle
end
