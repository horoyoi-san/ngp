C_TaskFullscreenStore = DefClass("C_TaskFullscreenStore", C_TaskFullscreenStore, C_StoreGroup)
GroupName2Class.TaskFullscreenStore = C_TaskFullscreenStore
local M = C_TaskFullscreenStore
local TaskConfig = LTConfig.TaskConfig
local TaskTitleConfig = LTConfig.TaskTitleConfig
local FloorToInt = math.floor

function M:ctor()
	self.m_TaskFailCountDown = nil
	self.m_TaskId = 0
end

function M:OnAwake()
	self.bindData.RePlayBtn.luaClick = self:CreateAction("RePlay")
	self.bindData.GiveUpBtn.luaClick = self:CreateAction("GiveUp")
	self.bindData.JumpBtn.luaClick = self:CreateAction("Jump")
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
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

				self:DelayClose(3)
			end
		end
	end

	if data.ShowType == 0 then
		if data.TaskStartMainLabel then
			self.bindData.TaskStartMainLabel = data.TaskStartMainLabel
		end

		if data.TaskStartSecondLabel then
			self.bindData.TaskStartSecondLabel = data.TaskStartSecondLabel
		end

		local delay = TaskConfig.TaskFullscreenPanelClose

		self:DelayClose(delay)
	elseif data.ShowType == 1 then
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

		if waitUnloadMaxTime > 5 then
			waitUnloadMaxTime = 5
		end

		self._delayGiveUpHandle = gLuaTimeMgrUtils.Delay(function ()
			self._delayGiveUpHandle = nil
			self.bindData.failedPanelMode = 1
		end, waitUnloadMaxTime, nil, nil, true)
	elseif data.ShowType == 2 then
		if data.TaskSubmitMainLabel then
			self.bindData.TaskSubmitMainLabel = data.TaskSubmitMainLabel
		end

		if data.TaskSubmitSecondLabel then
			self.bindData.TaskSubmitSecondLabel = data.TaskSubmitSecondLabel
		end

		local delay = TaskConfig.TaskFullscreenPanelClose

		self:DelayClose(delay)
	end
end

function M:OnUpdate()
	if self.bindData.ShowType == 1 and self.m_TaskFailCountDown > 0 then
		self.m_TaskFailCountDown = self.m_TaskFailCountDown - Time.deltaTime
		self.bindData.TaskFailCountDownText = tostring(FloorToInt(self.m_TaskFailCountDown))

		if self.m_TaskFailCountDown <= 0 then
			self:RePlay()
		end
	end
end

function M:OnClose()
	if not self._delayCloseHandle then
		gLuaTimeMgrUtils.CancelUnitDelay(self._delayCloseHandle)

		self._delayCloseHandle = nil
	end

	if not self._delayCloseHandle then
		gLuaTimeMgrUtils.CancelUnitDelay(self._delayCloseHandle)

		self._delayCloseHandle = nil
	end

	self.bindData.failedPanelMode = 1

	if gDeadManager.isDead then
		gDeadManager:Revive(UX.Game.ReviveType.TaskRevive, true)
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:DelayClose(delay)
	if not delay or delay <= 0 then
		delay = 1
	end

	self._delayCloseHandle = gLuaTimeMgrUtils.Delay(function ()
		self._delayCloseHandle = nil

		gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
	end, delay, nil, nil, true)
end

function M:RePlay()
	if self.m_TaskId then
		gClientToGameDelegate:AskReAcceptTaskFailGroup(self.m_TaskId).Callback = function ()
			return
		end

		self.bindData.failedPanelMode = 0
		local waitLoadMaxTime = TaskConfig.WaitLoadMaxTime

		L18.Spoon.Task.TaskManager.Instance:WaitTaskResourceDependedLoadComplete(self.m_TaskId, waitLoadMaxTime, function ()
			self.bindData.failedPanelMode = 1

			gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
		end)
	else
		gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
	end
end

function M:GiveUp()
	gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)
	gTaskManager:RemoveCurrentTask(self.m_TaskId)
end

function M:Jump()
	gPanelManager:Close(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL)

	if self.m_TaskId and self.m_TaskId ~= 0 then
		gClientToGameDelegate:AskForceSkipTask(self.m_TaskId).Callback = function ()
			return
		end
	end
end
