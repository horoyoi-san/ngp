-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NormalTaskPanelStore.lua
-- Decompiled from: 00934_NormalTaskPanelStore.lua_9877ecb3e92c.luajit

C_NormalTaskPanelStore = DefClass("C_NormalTaskPanelStore", C_NormalTaskPanelStore, C_StoreGroup)
GroupName2Class.NormalTaskPanelStore = C_NormalTaskPanelStore
local M = C_NormalTaskPanelStore
local TaskConfig = LTConfig.TaskConfig
local TaskShortCutConfig = LTConfig.TaskShortCutConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local MessageConfig = LTConfig.MessageConfig
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local FightSpiritConfig = LTConfig.FightSpiritConfig
local AgentConfig = LTConfig.AgentConfig

M.ctor = function(self)
	self.isStart = false
	self.isStartCb = {}
	self.progressStore = nil
	self.isQuitPressing = false
	self.branchList = {}
	self.childCounterData = {}
	self.curIsTrueBranch = false
	self.checkCount = 0
	self.hasAwake = false
	self.curBranchListIndex = -1
	self.lastTotalHeight = 0
	self.templateHeight = gTaskUtils:GetMobileDefaultTemplateHeight(gTaskUtils.TaskGuideSubPanel.Normal)
	self.defaultHeight = gTaskUtils:GetMobileTaskPaneDefaultHeight(gTaskUtils.TaskGuideSubPanel.Normal)
	self.isTaskGuideBtnActive = false
	self.isSetCurTaskBtnActive = false
	self.isQuitBtnActive = false
	self.isWatching = nil
	self.watchingTaskId = nil
	self.watchingTaskInfo = nil
end

M.OnAwake = function(self)
	self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	self.bindData.nTaskGuideBtn.luaClick = self:CreateAction("OnClickBtn")
	self.bindData.nTaskGuideBtn.luaLongPress = self:CreateAction("OnLongPressBtn")
	self.bindData.setCurTaskBtn.luaClick = self:CreateAction("OnClickGpsSwitch")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.nQuitBtn.luaBeginLongPress = self.CreateAction(self, "OnQuitTaskPress")
		self.bindData.nQuitBtn.luaEndLongPress = self.CreateAction(self, "OnQuitTaskRelease")
	else
		self.bindData.nQuitBtn.luaClick = self.CreateAction(self, "OnMobileQuitTask")
	end

	if self.bindData.heightBox then
		self.bindData.heightBox.luaSizeChanged = self.CreateAction(self, "OnSizeChanged")
	end

	self.bindData.nTaskList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTaskItem")
	self.bindData.nTaskList.luaSimpleClick = self.CreateAction(self, "OnBranchItemClick")
	self.bindData.nTaskList.poolMode = SGUI.EPoolMode.FarAway
	self.bindData.progressList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderProgressList")
	self.bindData.progressList.poolMode = SGUI.EPoolMode.FarAway
	self.hasAwake = true
end

local curSecond = 0

M.OnUpdate = function(self)
	if self.isQuitPressing then
		curSecond = curSecond + Time.deltaTime

		if self.isQuitPressing then
			if not gCS.LuaUtils.IsMobilePlatform() then
				self.bindData.quitPCFillAmount = curSecond
			end

			if curSecond > 1 then
				self.GiveUpTask(self)

				self.bindData.isQuitLongPressImg = 0
				curSecond = 0
				self.isQuitPressing = false
			end
		end
	end
end

M.OnSizeChanged = function(self)
	self.CalculateHeightBox(self)
end

M.CalculateHeightBox = function(self)
	if not self.bindData.heightBox then
		return
	end

	local height = self.bindData.heightBox:GetTargetHeight()
	local heightBoxOffsetY = math.abs(self.bindData.heightBox.rectTransform.anchoredPosition.y)

	gTaskUtils:SetBloodBarPosition(heightBoxOffsetY + height)
	gTaskUtils:SendMobileTaskPanelChange(height + gTaskUtils:GetGameBarPanelHeight())
end

M.OnStart = function(self)
	self.isStart = true

	if self.isStartCb then
		for _, cb in ipairs(self.isStartCb) do
			cb()
		end
	end

	self.isStartCb = {}
end

M.OnGroupEnable = function(self)
	self.msgEvents = {
		[gEventConstants.CURRENT_TASK_CHANGE] = self.CreateAction(self, "OnCurrentChange"),
		[gEventConstants.SWITCH_GPS_SHOW_MODE] = self.CreateAction(self, "OnSwitchGpsShowMode"),
		[gEventConstants.TASK_EVENT_CHANGE] = self.CreateAction(self, "OnTaskEventChange"),
		[gEventConstants.TASK_CHANGE_CURRENT_DES] = self.CreateAction(self, "OnCurrentDesChange"),
		[gEventConstants.TASK_SHORTCUT_CHANGE] = self.CreateAction(self, "OnTaskShortcutChange"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, self.OnPhoneAppShow),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, self.OnPhoneAppHide),
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "OnLinkModeChange")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnWatchingTaskChange = function(self, eventId, data)
	self.isWatching = data.isWatching

	if data.isWatching then
		self.lastListType = self.bindData.listType
		self.lastShortCutState = self.bindData.shortcut
		self.lastGiveUpState = self.bindData.giveup
		self.bindData.listType = 2
		self.bindData.shortcut = 1
		self.bindData.giveup = 1

		self.bindData.setCurTaskBtn:SetActive(false)
		self:RefreshWatchingInfo(data)
	else
		self:RefreshTaskInfo()

		self.bindData.listType = self.lastListType
		self.bindData.shortcut = self.lastShortCutState
		self.bindData.giveup = self.lastGiveUpState

		self.bindData.setCurTaskBtn:SetActive(self.isSetCurTaskBtnActive)

		self.watchingTaskId = nil
		self.watchingTaskInfo = nil
	end
end

M.RefreshWatchingInfo = function(self, data)
	self.watchingTaskId = data.taskId
	self.watchingTaskInfo = data.taskInfo
	local cfg = gTaskManager:GetTaskConfigInfo(self.watchingTaskId)
	local firstCounterIndex = gTaskNodeManager:FindFirstCounterIndexNotMyTask(self.watchingTaskInfo, cfg)
	local taskValue = gTaskNodeManager:GetTaskWorkActionInfo(self.watchingTaskId, firstCounterIndex)
	taskValue.CounterDesId = self.watchingTaskInfo.CounterDesId or 0

	self:RefreshWatchingTaskDes(self.watchingTaskId, taskValue)
	self:RefreshCurrentTaskEventUI(self.watchingTaskId)

	self.bindData.HideDes = 1
end

M.OnGroupDisable = function(self)
	self.isStart = false
	self.isStartCb = {}

	self.ClearMessageEvents(self)
end

M.OnCurrentChange = function(self, eventId, data)
	if not self.isStart then
		table.insert(self.isStartCb, function ()
			self:OnCurrentChange(nil, data)
		end)

		return
	end

	if data then
		local taskInfo = gTaskManager:GetTaskInfo(data.TaskId)

		if taskInfo then
			self.RefreshTaskInfo(self)
			self.RefreshTrueBranchList(self)
			self.CheckAndShowChildCounter(self)
		end
	end
end

M.OnShow = function(self, data)
	if not self.isStart then
		table.insert(self.isStartCb, function ()
			self:OnShow(data)
		end)

		return
	end

	if not self.p then
		self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	end

	self.lastTotalHeight = 0

	if not self.hasAwake then
		return
	end

	if self.p then
		if self.p.IsFirstTime then
			self.childCounterData = nil

			self.InitAllBtns(self)
		end

		self:OnOnlineChange(_, gLinkManager:CheckInLinkMode())
	end

	self.isSetCurTaskBtnActive = not gGpsManager:HudIsShowTaskMode()

	self.bindData.setCurTaskBtn:SetActive(self.isSetCurTaskBtnActive)
	self:HandleTaskShortCut()

	self.isQuitBtnActive = self.p.isShowGiveUp
	self.bindData.giveup = self.isQuitBtnActive and 0 or 1

	self:RefreshTaskInfo()
	self:RefreshTrueBranchList()

	if self.p.curTaskInfo then
		self:CheckAndShowChildCounter()

		self.bindData.cNormal = gTaskManager.TaskColor[self.p.curTaskInfo.Title] and Color.NewByStr(gTaskManager.TaskColor[self.p.curTaskInfo.Title])
	end

	self.CalculateHeightBox(self)
end

M.OnOnlineChange = function(self, _, enable)
	if enable then
		self.bindData.Online = 1
	else
		self.bindData.Online = 0
	end
end

M.CheckAndShowChildCounter = function(self)
	if not self.p then
		self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	end

	if not self.p.curTaskInfo or not self.p.curTaskInfo.ShowChildCounter then
		return
	end

	self.counterValues = gTaskManager:GetWKCounterValues(self.p.curTaskId)
	self.configValues = gTaskManager:GetWKCounterConfigValues(self.p.curTaskId)

	if not self.counterValues or not self.configValues then
		return
	end

	self.childCounterData = {}

	if self.p.curTaskInfo and self.p.curTaskInfo.ChildCounterInfos and #self.p.curTaskInfo.ChildCounterInfos <= 0 then
		for i, v in ipairs(self.p.curTaskInfo.ChildCounterInfos) do
			local data = {
				["ZI贊\\xab\\xcc\\xec"] = false,
				index = v.CounterIndex,
				des = v.WorkDescription,
				progressData = v.ProgressData
			}

			table.insert(self.childCounterData, data)
		end
	end

	if #self.childCounterData <= 0 then
		for i, v in ipairs(self.childCounterData) do
			v.CounterValue = self.counterValues[v.index]
			v.ConfigValue = self.configValues[v.index]

			if self.configValues and v.CounterValue and self.configValues[v.index] < v.CounterValue then
				v.isFinished = true
			end

			if v.progressData.SubCounterAgentId == 0 then
				if not self.HpPidIndexDic then
					self.HpPidIndexDic = {}
				end

				self.HpPidIndexDic[v.progressData.SubCounterAgentId] = i
				local hpInfo = {
					["\\xd0\\xc8& \\xe8"] = false,
					["\\x9eab"] = 0,
					[""] = 0,
					["@\\xaf\\xba\\x87\\xa6"] = 0
				}
				v.hpInfo = hpInfo
			end
		end

		if gBloodBarGameManager:CheckAllReady() then
			self.RefreshAllHpBar(self, gBloodBarGameManager.currentTaskReadyPids)
		end

		self.bindData.listType = 1

		self.bindData.progressList:SetSimpleList(#self.childCounterData)
	end
end

M.RefreshSingleHp = function(self, spoonId, hp)
	if self.childCounterData and self.HpPidIndexDic and self.HpPidIndexDic[spoonId] then
		local index = self.HpPidIndexDic[spoonId]
		self.childCounterData[index].hpInfo.hp = hp

		self.bindData.progressList:SetSimpleElement(index - 1, 0)
	end
end

M.RefreshAllHpBar = function(self, pids)
	if not self.childCounterData then
		return
	end

	for i, v in ipairs(pids) do
		local spawnInfo = gCS.SpoonAgentMgr:GetSpawn(v)
		local index = self.HpPidIndexDic[spawnInfo.spoonId]
		self.childCounterData[index].hpInfo.isReady = true
		local unit = gCS.SceneDataMgr.GetUnit(v)

		if unit and self.childCounterData[index].hpInfo then
			self.childCounterData[index].hpInfo.pid = v
			self.childCounterData[index].hpInfo.unit = unit
			self.childCounterData[index].hpInfo.maxHp = unit.ClientData.MaxHp
			self.childCounterData[index].hpInfo.hp = unit.ClientData.Hp
		end
	end
end

M.OnRenderProgressList = function(self, btn, index)
	local data = self.childCounterData[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if data and store then
		store.des = data.des

		if data.progressData.ProgressType ~= 1 and data.hpInfo and data.hpInfo.isReady then
			store.type = 2
			store.hp = data.progressData.HpBarType
			store.progress.value = data.hpInfo.hp / data.hpInfo.maxHp
		else
			store.type = data.progressData.ProgressTemplateId

			if self.p.curTaskInfo and self.p.curTaskInfo.childCounterCnt then
				store.counterDes = self.counterValues[data.index] .. "/" .. self.p.curTaskInfo.childCounterCnt
				store.progress.value = self.counterValues[data.index] / self.p.curTaskInfo.childCounterCnt
				store.counterCircleList.groupType = 2

				store.counterCircleList:SetSimpleList(0)

				for i = 1, data.ConfigValue do
					store.counterCircleList:AddSimpleData(0, data.isFinished)
				end

				store.counterCircleList:RefreshList()
			end
		end
	end
end

M.OnClose = function(self, data)
	if data and data.TaskCounterChange then
		self.bindData.waFinishAnim = 1

		gLuaTimeMgrUtils.NotDestroyDelay(function ()
			if self.bindData then
				self.bindData.waFinishAnim = 0
			end
		end, TaskConfig.WorkActionFinishAnimDur or 2)
	end
end

M.OnLinkModeChange = function(self)
	self:OnOnlineChange(_, gLinkManager:CheckInLinkMode())
end

M.InitTrueBranchData = function(self)
	gTaskManager.curBranchIndex = -1
end

M.OnDisable = function(self)
	self.isTaskGuideBtnActive = false
	self.bindData.shortcut = 1
	self.isQuitBtnActive = false
	self.bindData.giveup = 1
	self.counterValues = nil
	self.configValues = nil
	self.childCounterData = nil
	self.branchList = {}
	self.curBranchListIndex = -1
	self.curIsTrueBranch = false
	gTaskManager.curBranchIndex = -1
	self.isSetCurTaskBtnActive = not gGpsManager:HudIsShowTaskMode()

	self.bindData.setCurTaskBtn:SetActive(self.isSetCurTaskBtnActive)
	gTaskUtils:SendMobileTaskPanelChange(0)
end

M.InitAllBtns = function(self)
	self.isTaskGuideBtnActive = false
	self.bindData.shortcut = 1
	self.isQuitBtnActive = false
	self.bindData.giveup = 1
	self.isSetCurTaskBtnActive = not gGpsManager:HudIsShowTaskMode()

	self.bindData.setCurTaskBtn:SetActive(self.isSetCurTaskBtnActive)
end

M.OnCurrentDesChange = function(self, eventId, data)
	if data.isChange then
		local textId = data.textId
		local text = TextCommonTextConfig.GetConfig(textId).Text

		if text then
			self.SwitchTaskInfo(self, text)
		end
	else
		self.RefreshTaskInfo(self)
	end
end

M.OnChangeCurDes = function(self, eventId, data)
	if not data then
		return
	end

	if data.isRecover then
		self.RefreshCurrentTaskDes(self)
	else
		local des = nil
		local config = LTConfig.TextCommonTextConfig.GetConfig(data.DesId)

		if config then
			des = LTConfig.TextCommonTextConfig.GetConfig(data.DesId).Text

			self.SwitchTaskInfo(self, des)
		else
			print_error("#NoCreateIssue 请策划检查：ChangeCounterDes节点，当前选择更改描述，却获取不到对应的Text的描述Id")
		end
	end
end

M.OnTaskEventChange = function(self, eventId, data)
	if not self.p.curTaskId or self.p.curTaskId < 0 then
		return
	end

	local eventInfo = gTaskNodeManager:GetTaskLineByTask(self.p.curTaskId)

	if table.isNilOrEmpty(eventInfo) then
		return
	end

	if data.EventId and data.EventId ~= eventInfo.TaskLineId and not data.IsUnderway then
		self.delayShowCurTaskDes = gLuaTimeMgrUtils.Delay(function ()
			self.delayShowCurTaskDes = nil

			self:RefreshCurrentTaskDes()
		end, TaskConfig.StartInfoTime)
		self.bindData.nTaskInfo = TaskConfig.TaskStartInfo
	end
end

M.RefreshTaskInfo = function(self)
	self.RefreshCurrentTaskDes(self)
	self.RefreshCurrentTaskEventUI(self)

	self.bindData.HideDes = 1
end

M.ShowGiveUpButton = function(self, isShow, text)
	if isShow then
		self.SetShortCutButtonActive(self, false)
	end

	self.SetGiveUpButtonActive(self, isShow)

	if not isShow then
		return
	end

	if self.p.isShowGiveUp then
		self.bindData.giveup = 0
	elseif self.p.isShowRetry then
		self.bindData.giveup = 1
	else
		self.SetGiveUpButtonActive(self, false)
	end

	local imgId = TaskConfig.TaskGuideGivenUpImageId
	self.bindData.quitAction = imgId
end

M.SetNormalList = function(self)
	self.bindData.listType = 0

	self.bindData.nTaskList:SetSimpleList(#self.branchList)
end

M.GetChildTargetCounter = function(self, data)
	local workActionInfo = data.workActionInfo
	local cfg = gTaskManager:GetTaskConfigInfo(self.p.curTaskId)
	local isShowChildTargetCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowSubTargetCounter)
	local taskCounter = ""
	local allCounterValue = cfg.Counter[data.CounterIndex]

	if isShowChildTargetCounter and allCounterValue <= 1 then
		local counterIndex = data.CounterIndex
		local nowCounterValue = gTaskManager:GetTaskCounterValue(self.p.curTaskId, counterIndex)
		taskCounter = "[" .. nowCounterValue .. "/" .. allCounterValue .. "]"
	end

	return taskCounter
end

M.OnRenderTaskItem = function(self, btn, index)
	local data = self.branchList[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if store and data then
		if data.EventObjective then
			store.taskName = data.EventObjective .. self.GetChildTargetCounter(self, data)
		else
			store.taskName = ""
		end

		store.taskState = data.taskState
		store.pcKeyName = data.index

		if self.IsInPad(self) then
			store.mode = 1
		elseif self.IsInPc(self) then
			store.mode = 0
		else
			store.mode = 2
		end

		store.gamePadBtnController = data.gamePadBtnController

		store.branchItem:SetPCKeyInfoWithOutTip(data.pcKeyId, 0, 0, 0, 0)
	end
end

M.RefreshTrueBranchList = function(self)
	if not self.p.curTaskInfo or self.p.curTaskId ~= nil then
		return
	end

	local isBranch = gTaskNodeManager:CheckTaskIsTrueBranch(self.p.curTaskId)

	if not isBranch then
		self.branchList = {}
		self.curBranchListIndex = -1

		self.SetNormalList(self)

		self.curIsTrueBranch = false
		self.bindData.listType = 2

		return
	end

	self.bindData.listType = 0
	self.curIsTrueBranch = true
	local allWorkActions = gTaskNodeManager:GetTaskWorkAction(self.p.curTaskId)
	local taskInfo = gTaskManager:GetTaskInfo(self.p.curTaskId)
	local cfg = gTaskManager:GetTaskConfigInfo(self.p.curTaskId)
	local workLength = #allWorkActions
	local workActionList = {}
	self.branchList = {}
	self.curBranchListIndex = -1
	local hasSetTaskInfo = false

	for i = 1, workLength do
		local nowActionInfo = gTaskNodeManager:GetTaskWorkActionInfo(self.p.curTaskId, i)
		nowActionInfo.CounterIndex = i
		local des = nowActionInfo.EventObjective
		local eventInfo = gTaskNodeManager:GetTaskLineByTask(self.p.curTaskId)

		if eventInfo and self.CheckIsRideAndDateTask(self, eventInfo.TaskLineId) and self.p.cultivationId then
			local cultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(self.p.cultivationId)

			if cultivationCfg then
				des = des.format(des, cultivationCfg.Name)
			end
		end

		if nowActionInfo.IsBranchTarget then
			local isFinished = taskInfo and taskInfo.Counters and taskInfo.Counters[i] and cfg and cfg.Counter and cfg.Counter[i] > taskInfo.Counters[i].Value

			if not isFinished or not nowActionInfo.hideBranch then
				self.targetList = {}
				local info = {}
				local index = #self.targetList + 1
				self.targetList[index] = {
					TargetPos = nowActionInfo.TargetPos,
					CounterIndex = nowActionInfo.CounterIndex
				}

				if #workActionList ~= 0 then
					info.gamePadBtnController = 1
				else
					info.gamePadBtnController = 0
				end

				info.index = #workActionList + 1
				info.EventObjective = des or ""
				info.workActionInfo = nowActionInfo
				info.CounterIndex = nowActionInfo.CounterIndex
				info.pcKeyId = info.index + 14
				info.targetPos = nowActionInfo.TargetPos
				info.gpsId = self.p.curTaskId .. "_" .. nowActionInfo.CounterIndex
				info.RelatedTaskEvent = nowActionInfo.RelatedTaskEvent

				if isFinished then
					info.taskState = 1
				else
					info.taskState = 0
				end

				table.insert(workActionList, info)

				self.branchList = workActionList
			end
		elseif not hasSetTaskInfo then
			self.SwitchTaskInfo(self, des)

			hasSetTaskInfo = true
		end
	end

	local defaultTrackedIndex = -1
	local isTrueBranchNoDefault = array.contains(cfg.Tags, TaskConfig.TagsType.TrueBranchNoDefault)

	if not isTrueBranchNoDefault then
		local prevBranchIndex = gTaskManager.curBranchIndex
		local restored = false

		if prevBranchIndex and prevBranchIndex == -1 then
			for _, v in ipairs(self.branchList) do
				if v.taskState ~= 0 and v.workActionInfo.CounterIndex ~= prevBranchIndex then
					v.taskState = 2
					self.curBranchListIndex = v.index
					defaultTrackedIndex = v.index
					gTaskManager.curBranchIndex = v.workActionInfo.CounterIndex

					gMapSubSystem_Task:TraceByHudTaskBranchSwitch(self.p.curTaskId, v.gpsId)

					restored = true

					break
				end
			end
		end

		if not restored then
			for _, v in ipairs(self.branchList) do
				if v.taskState ~= 0 then
					v.taskState = 2
					self.curBranchListIndex = v.index
					defaultTrackedIndex = v.index
					gTaskManager.curBranchIndex = v.workActionInfo.CounterIndex

					gMapSubSystem_Task:TraceByHudTaskBranchSwitch(self.p.curTaskId, v.gpsId)

					break
				end
			end
		end
	end

	if defaultTrackedIndex == -1 then
		local total = #self.branchList
		local nextIndex = defaultTrackedIndex % total
		local checked = 0

		while total <= checked do
			local candidate = self.branchList[nextIndex + 1]

			if candidate and candidate.taskState == 1 and candidate.index == defaultTrackedIndex then
				break
			end

			nextIndex = (nextIndex + 1) % total
			checked = checked + 1
		end

		for _, v in ipairs(self.branchList) do
			v.gamePadBtnController = 0
		end

		local nextData = self.branchList[nextIndex + 1]

		if nextData then
			nextData.gamePadBtnController = 1
		end
	end

	self.SetNormalList(self)
end

M.OnBranchItemClick = function(self, btn, index)
	local data = self.branchList[index + 1]

	if not data or data.taskState ~= 1 then
		return
	end

	if self.curBranchListIndex ~= data.index then
		gTaskManager.curBranchIndex = -1
		self.curBranchListIndex = -1
		local taskInfo = gTaskManager:GetTaskInfo(self.p.curTaskId)
		local cfg = gTaskManager:GetTaskConfigInfo(self.p.curTaskId)

		for _, v in pairs(self.branchList) do
			local counterIdx = v.workActionInfo and v.workActionInfo.CounterIndex
			local isFinished = taskInfo and taskInfo.Counters and counterIdx and taskInfo.Counters[counterIdx] and cfg and cfg.Counter and cfg.Counter[counterIdx] > taskInfo.Counters[counterIdx].Value
			v.taskState = isFinished and 1 or 0
		end

		self:SetNormalList()
		gMessageManager:SendMessage(gEventConstants.ON_BRANCH_TASK_CLICK, {
			["D\\xa0\\xa6\\xaa\\xae"] = -1,
			taskId = self.p.curTaskId
		})
		gMapSubSystem_Task:TraceByHudTaskBranchSwitch(self.p.curTaskId, "")
	else
		self.SwitchBranchByIndex(self, index)
	end
end

M.SwitchBranchByGpsId = function(self, gpsId)
	local targetIndex = nil

	if self.branchList ~= nil then
		return
	end

	for i, v in ipairs(self.branchList) do
		if v.gpsId ~= gpsId then
			targetIndex = i

			break
		end
	end

	if targetIndex then
		self.SwitchBranchByIndex(self, targetIndex - 1)
	end
end

M.SwitchBranchByIndex = function(self, index)
	local isPad = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	local data = self.branchList[index + 1]

	if not data then
		return
	end

	gTaskManager.curBranchIndex = data.workActionInfo.CounterIndex
	self.curBranchListIndex = data.index

	if not table.isNilOrEmpty(self.branchList) then
		local taskInfo = gTaskManager:GetTaskInfo(self.p.curTaskId)
		local cfg = gTaskManager:GetTaskConfigInfo(self.p.curTaskId)

		for i, v in pairs(self.branchList) do
			if v.index ~= data.index then
				v.taskState = 2
			else
				local counterIdx = v.workActionInfo and v.workActionInfo.CounterIndex
				local isFinished = taskInfo and taskInfo.Counters and counterIdx and taskInfo.Counters[counterIdx] and cfg and cfg.Counter and cfg.Counter[counterIdx] > taskInfo.Counters[counterIdx].Value
				v.taskState = isFinished and 1 or 0
			end
		end
	end

	local nextIndex = index + 1

	if nextIndex <= #self.branchList - 1 then
		nextIndex = 0
	end

	if isPad then
		local total = #self.branchList
		local checked = 0

		while total <= checked do
			local candidate = self.branchList[nextIndex + 1]

			if candidate and candidate.taskState == 1 and candidate.index == data.index then
				break
			end

			nextIndex = nextIndex + 1

			if nextIndex <= total - 1 then
				nextIndex = 0
			end

			checked = checked + 1
		end

		data.gamePadBtnController = 0
		local nextData = self.branchList[nextIndex + 1]
		nextData.gamePadBtnController = 1
	end

	self:SetNormalList()
	gMessageManager:SendMessage(gEventConstants.ON_BRANCH_TASK_CLICK, {
		taskId = self.p.curTaskId,
		index = data.index
	})

	if data.RelatedTaskEvent == 0 and self.CheckEventHasAccepted(self, data.RelatedTaskEvent) then
		self.ToSetChasingEvent(self, data.RelatedTaskEvent)
	else
		gMapSubSystem_Task:TraceByHudTaskBranchSwitch(self.p.curTaskId, data.gpsId)
	end
end

M.CheckEventHasAccepted = function(self, eventId)
	local eventInfo = gTaskManager.taskEvents[eventId]

	if eventInfo and eventInfo.IsUnderway then
		return true
	end

	return false
end

M.SetCurrentTask = function(self, eventId)
	local taskId = gTaskNodeManager:GetEventNowDoTaskId(eventId)

	if taskId == 0 then
		slot3 = gTaskManager

		slot3:SetCurrentTask(taskId, function ()
			local taskCfg = TaskConfig.GetConfig(taskId)

			if taskCfg and (taskCfg.RelatedTimeAndWeather.weatherId >= 0 or taskCfg.RelatedTimeAndWeather.timeId <= 0) then
				gDisplayMessageMgr:ShowMessage(MessageConfig.TaskChangeWeather)
			end
		end)
	end
end

M.ToSetChasingEvent = function(self, eventId)
	gGpsManager:TryRemoveNowMapGuide()
	self:SetCurrentTask(eventId)
end

M.RefreshCurrentTaskDes = function(self)
	if not self.p then
		self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	end

	if not self.p.curTaskInfo then
		return
	end

	local des = ""

	if self.p.curTaskInfo.CounterDesId == 0 then
		local textCfg = TextCommonTextConfig.GetConfig(self.p.curTaskInfo.CounterDesId)

		if textCfg then
			des = textCfg.Text
		end
	else
		des = self.p.curTaskInfo.WorkDescription or ""
	end

	local eventInfo = gTaskNodeManager:GetTaskLineByTask(self.p.curTaskId)

	if eventInfo and self.CheckIsRideAndDateTask(self, eventInfo.TaskLineId) and self.p.cultivationId then
		local cultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(self.p.cultivationId)

		if cultivationCfg then
			des = des.format(des, cultivationCfg.Name)
		end
	end

	if self.p.isInTaskRaid then
		self.SwitchTaskInfo(self, des .. self.GetTaskCounter(self))
	else
		self:SwitchTaskInfo(gTaskUtils:FormatTaskDes(self.p.curTaskInfo.EventObjective or "", self.p.curTaskId))
	end

	if gTaskManager:IsTaskInRiskControl(self.p.curTaskInfo.TaskId) then
		self.SwitchTaskInfo(self, LTConfig.TextScriptTextConfig.GetConfig(89900961).Text)
	end
end

M.CheckIsRideAndDateTask = function(self, eventId)
	local cultivationParam = LTConfig.NpcCultivationConfig.InvitationParameters

	if not cultivationParam then
		return false
	end

	for _, param in pairs(cultivationParam) do
		if param.EventId ~= eventId then
			return true
		end
	end

	return false
end

M.RefreshCurrentTaskEventUI = function(self)
	if not self.p.curTaskId then
		return
	end

	local eventInfo = gTaskNodeManager:GetTaskLineByTask(self.p.curTaskId)

	if table.isNilOrEmpty(eventInfo) then
		return
	end

	local eventCfg = TaskEventConfig.GetConfig(eventInfo.TaskLineId)

	if eventCfg then
		self.bindData.nEventName = eventCfg.EventName
	end
end

M.RefreshWatchingTaskDes = function(self, taskId, taskInfo)
	if not taskInfo then
		return
	end

	local des = ""

	if taskInfo.CounterDesId == 0 then
		local textCfg = TextCommonTextConfig.GetConfig(taskInfo.CounterDesId)

		if textCfg then
			des = textCfg.Text
		end
	else
		des = taskInfo.WorkDescription or ""
	end

	local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

	if self.p.isInTaskRaid then
		self.SwitchTaskInfo(self, des .. self.GetTaskCounter(self, taskInfo))
	else
		self:SwitchTaskInfo(gTaskUtils:FormatTaskDes(taskInfo.EventObjective or "", taskId))
	end

	if gTaskManager:IsTaskInRiskControl(taskId) then
		self.SwitchTaskInfo(self, LTConfig.TextScriptTextConfig.GetConfig(89900961).Text)
	end
end

M.RefreshWatchingTaskEventUI = function(self, taskId)
	if not taskId then
		return
	end

	local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

	if table.isNilOrEmpty(eventInfo) then
		return
	end

	local eventCfg = TaskEventConfig.GetConfig(eventInfo.TaskLineId)

	if eventCfg then
		self.bindData.nEventName = eventCfg.EventName
	end
end

M.SwitchTaskInfo = function(self, taskInfo)
	self.bindData.nTaskInfo = taskInfo
end

M.GetTaskCounter = function(self, watchingTaskInfo)
	local taskInfo = self.p.curTaskInfo

	if watchingTaskInfo then
		taskInfo = watchingTaskInfo
	end

	local taskCounter = ""

	if self.p.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.p.curTaskId)
		local isShowAllCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllCounter)

		if taskInfo.totalValue and not isShowAllCounter then
			allCounterValue = taskInfo.totalValue
		else
			local allWorkActions = gTaskNodeManager:GetTaskWorkAction(self.p.curTaskId)

			for i = 1, #cfg.Counter do
				local wa = allWorkActions and allWorkActions[i]

				if not wa or not wa.SkipShowCounter then
					local couterNum = cfg.Counter[i]
					allCounterValue = allCounterValue + couterNum
				end
			end
		end

		if isShowAllCounter then
			local tasks = gTaskManager:GetTaskInfo(self.p.curTaskId)
			local allWorkActions = gTaskNodeManager:GetTaskWorkAction(self.p.curTaskId)
			nowCounterValue = 0

			for i = 1, #tasks.Counters do
				local wa = allWorkActions and allWorkActions[i]

				if not wa or not wa.SkipShowCounter then
					nowCounterValue = tasks.Counters[i].Value + nowCounterValue
				end
			end
		end

		if not taskInfo.NotShowProgress or not not isShowAllCounter then
			taskCounter = "[" .. nowCounterValue .. "/" .. allCounterValue .. "]"
		end
	end

	return taskCounter
end

M.LanguageChange = function(self)
	if self.isWatching and self.watchingTaskId and self.watchingTaskInfo then
		self.RefreshWatchingTaskDes(self, self.watchingTaskId, self.watchingTaskInfo)
		self.RefreshWatchingTaskEventUI(self, self.watchingTaskId)

		return
	end

	self.RefreshTaskInfo(self)
	self.RefreshTrueBranchList(self)
	self.HandleTaskShortCut(self)
end

M.SetShortCutButtonActive = function(self, isActive)
	self.isTaskGuideBtnActive = isActive
	self.bindData.shortcut = isActive and 0 or 1

	if isActive then
		if self.curIsTrueBranch then
			local nextIndex = self.curBranchListIndex + 1
			self.branchList[nextIndex].gamePadBtnController = 1
		end

		self.bindData.listType = 2
	else
		if self.curIsTrueBranch then
			self.bindData.listType = 0
		end

		if self.childCounterData and #self.childCounterData <= 0 then
			self.bindData.listType = 1
		end
	end
end

M.SetGiveUpButtonActive = function(self, isActive)
	self.isQuitBtnActive = isActive
	self.bindData.giveup = isActive and 0 or 1
end

M.OnTaskShortcutChange = function(self, eventId, data)
	self.HandleTaskShortCut(self)
end

M.HandleTaskShortCut = function(self)
	if self.p and (not self.p.curCfgId or self.p.curCfgId ~= 0) then
		self.isTaskGuideBtnActive = false
		self.bindData.shortcut = 1

		return
	end

	local inputCfg = TaskShortCutConfig.GetConfig(self.p.curCfgId)

	if not inputCfg then
		return
	end

	if inputCfg.Action then
		self.shortcutCallbackFuncStr = inputCfg.Action
	end

	if not string.is_null_or_empty(inputCfg.GuideId) then
		self.bindData.nGuideID = inputCfg.GuideId
	else
		self.bindData.nGuideID = ""
	end

	local imgId = inputCfg.SImageID
	local keyNameId = inputCfg.KeyName
	local keyName = LTConfig.InputButtonNameConfig.GetConfig(keyNameId).Name
	self.isTaskGuideBtnActive = self.p.isShowShortCut

	if self.isTaskGuideBtnActive and gCS.LuaUtils.IsNonMobileAdaptive() then
		self.RefreshPCKey(self, inputCfg, self.p.isShowShortCut)
		self.RefreshPadKey(self, inputCfg, self.p.isShowShortCut)
	end

	self.bindData.shortcut = self.isTaskGuideBtnActive and 0 or 1
	self.bindData.action = imgId
	self.bindData.keyname = keyName
end

M.RefreshPCKey = function(self, inputCfg, isShow)
	self.bindData.shortcut = isShow and 0 or 1
	self.bindData.isTaskLongPress = 0
	local pcKeyId = inputCfg.Key[1]
	local pcKeyName = LTConfig.InputSGUIPCKeyConfig.GetConfig(pcKeyId).Name

	self.bindData.nTaskGuideBtn:SetPCKeyInfoWithOutTip(pcKeyId, 0, 0, 0, 10)

	self.bindData.pcKeyName = pcKeyName
end

M.RefreshPadKey = function(self, inputCfg, isShow)
	self.bindData.shortcut = isShow and 0 or 1

	self.bindData.padKey.gameObject:SetActive(isShow)

	local padId = inputCfg.GamepadKey
	local iconStyle = inputCfg.GamepadStyle
	local respondType = inputCfg.GamepadType
	local padOrder = inputCfg.GamePadOrder or 0

	if respondType ~= 1 then
		self.bindData.padPressText.gameObject:SetActive(true)
	else
		self.bindData.padPressText.gameObject:SetActive(false)
	end

	if padId == 0 and padId then
		if respondType ~= 1 then
			self.bindData.padKey:ChangeImageAction(padId, 1, nil, 0, iconStyle, padOrder, 0.5)
		else
			self.bindData.padKey:ChangeImageAction(padId, 0, nil, 0, iconStyle, padOrder)
		end
	end
end

M.OnClickBtn = function(self)
	if self.p.shortCutRecordById then
		gDialogAction:RunCodeByTask(self.shortcutCallbackFuncStr, self.p.curTaskId)

		return
	end
end

M.OnLongPressBtn = function(self)
	if self.IsInPad(self) and self.p.shortCutRecordById then
		gDialogAction:RunCodeByTask(self.shortcutCallbackFuncStr, self.p.curTaskId)

		return
	end
end

M.OnClickGpsSwitch = function(self)
	gGpsManager:TaskTrySwitchGpsShowMode()
end

M.GiveUpTask = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		gDisplayMessageMgr:ShowBomb({
			msgType = gDisplayMessageId.SELECT,
			tips1Text = TaskConfig.MobileQuitText,
			btnConfirmCallback = function ()
				self:DoGiveUpTask()
			end
		})

		return
	end

	self.DoGiveUpTask(self)
end

M.DoGiveUpTask = function(self)
	if self.p.curTaskId and self.p.curTaskId == 0 then
		self.TryGiveUpTask(self, self.p.curTaskId, function ()
			if self.p.isShowGiveUp then
				gTaskManager:RemoveCurrentTask(self.p.curTaskId)
			else
				slot0 = gClientToGameDelegate

				slot0:AskDeleteTask(self.p.curTaskId, false).Callback = function ()
				end
			end
		end)
	end
end

M.TryGiveUpTask = function(self, taskId, okCB)
	local cfg = gTaskManager:GetTaskConfigInfo(taskId)

	if not cfg then
		return
	end

	if array.contains(cfg.Tags, TaskConfig.TagsType.GiveUpTaskConfirm) then
		gDisplayMessageMgr:ShowMessage(65107518, okCB)
	else
		okCB()
	end
end

M.OnMobileQuitTask = function(self)
	self.GiveUpTask(self)
end

M.OnQuitTaskPress = function(self)
	if gCS.LuaUtils.IsMobilePlatform() then
		return
	end

	self.isQuitPressing = true
	curSecond = 0
	self.bindData.isQuitLongPressImg = 1
end

M.OnQuitTaskRelease = function(self)
	self.isQuitPressing = false

	if curSecond >= 1 then
		self.bindData.isQuitLongPressImg = 0
		self.bindData.quitPCFillAmount = 0
		curSecond = 0
	end
end

M.OnSwitchGpsShowMode = function(self, eventId, data)
	if not self.p.curTaskId or self.p.curTaskId > 0 or not self.p.curTaskInfo then
		return
	end

	if not self.p.curTaskInfo.TargetType or self.p.curTaskInfo.TargetType ~= gTaskManager.ACTION_TYPE.NONE then
		return
	end

	local active = data ~= 1
	self.isSetCurTaskBtnActive = active

	self.bindData.setCurTaskBtn:SetActive(active)

	if active then
		self.SetShortCutButtonActive(self, false)

		self.bindData.HideDes = 0
		self.bindData.listType = 2
	else
		if self.isShowShortCut then
			self.SetShortCutButtonActive(self, true)
		end

		self.bindData.HideDes = 1

		if self.branchList and #self.branchList <= 0 then
			self.bindData.listType = 0
		end

		if self.childCounterData and #self.childCounterData <= 0 then
			self.bindData.listType = 1
		end
	end
end

M.IsInPc = function(self)
	return InputActionBind.activeGameDevice ~= GameDevice.KeyboardMouse
end

M.IsInPad = function(self)
	return InputActionBind.activeGameDevice ~= GameDevice.Xbox or InputActionBind.activeGameDevice ~= GameDevice.PlayStation
end

M.OnPhoneAppShow = function(self)
	if self.p.isShowShortCut then
		self.SetShortCutButtonActive(self, false)
	end
end

M.OnPhoneAppHide = function(self)
	self.RecoverShortCutButtonActive(self)
end

M.RecoverShortCutButtonActive = function(self)
	if self.p.isShowShortCut then
		self.SetShortCutButtonActive(self, true)
	end
end
