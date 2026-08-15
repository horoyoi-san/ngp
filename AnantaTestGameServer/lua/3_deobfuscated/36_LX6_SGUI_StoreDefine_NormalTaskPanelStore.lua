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
local AnimMgr = SGUI.AnimMgr
local BranchPadKey = {
	19,
	18,
	20,
	21
}

function M:ctor()
	self.curDynamicTemplateCnt = 0
	self.isQuitPressing = false
	self.branchList = {}
	self.YuandiList = {}
	self.curIsTrueBranch = false
	self.checkCount = 0
	self.hasAwake = false
	self.curBranchListIndex = -1
	self.lastTotalHeight = 0
	self.curDynamicTemplateCnt = 0
	self.templateHeight = gTaskUtils:GetMobileDefaultTemplateHeight(gTaskUtils.TaskGuideSubPanel.Normal)
	self.defaultHeight = gTaskUtils:GetMobileTaskPaneDefaultHeight(gTaskUtils.TaskGuideSubPanel.Normal)
	self.isTaskGuideBtnActive = false
	self.isSetCurTaskBtnActive = false
	self.isQuitBtnActive = false
end

function M:OnAwake()
	self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	self.bindData.nTaskGuideBtn.luaClick = self:CreateAction("OnClickBtn")
	self.bindData.setCurTaskBtn.luaClick = self:CreateAction("OnClickGpsSwitch")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.nQuitBtn.luaBeginLongPress = self:CreateAction("OnQuitTaskPress")
		self.bindData.nQuitBtn.luaEndLongPress = self:CreateAction("OnQuitTaskRelease")
	else
		self.bindData.nQuitBtn.luaClick = self:CreateAction("OnMobileQuitTask")
	end

	self.bindData.nTaskList.luaSimpleRenderItem = self:CreateAction("OnRenderTaskItem")
	self.bindData.nTaskList.luaSimpleClick = self:CreateAction("OnBranchItemClick")
	self.bindData.goalList.luaRenderItem = self:CreateAction("OnRenderGoalItem")

	function self.bindData.goalList.onGetTIndex(_)
		return 0
	end

	self.hasAwake = true
end

local curSecond = 0

function M:OnUpdate()
	if self.isQuitPressing then
		curSecond = curSecond + Time.deltaTime

		if self.isQuitPressing then
			if not gCS.LuaUtils.IsMobilePlatform() then
				self.bindData.quitPCFillAmount = curSecond
			end

			if curSecond >= 1 then
				self:GiveUpTask()

				self.bindData.isQuitLongPressImg = 0
				curSecond = 0
				self.isQuitPressing = false
			end
		end
	end

	self:OnGoalUpdate()
end

function M:OnEnable()
	self.msgEvents = {
		[gEventConstants.SWITCH_GPS_SHOW_MODE] = self:CreateAction("OnSwitchGpsShowMode"),
		[gEventConstants.TASK_EVENT_CHANGE] = self:CreateAction("OnTaskEventChange"),
		[gEventConstants.TASK_CHANGE_CURRENT_DES] = self:CreateAction("OnCurrentDesChange"),
		[gEventConstants.CHANGE_COUNTER_DES_GPS] = self:CreateAction("OnChangeCurDes"),
		[gEventConstants.TASK_SHORTCUT_CHANGE] = self:CreateAction("OnTaskShortcutChange"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction(self.OnPhoneAppShow),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction(self.OnPhoneAppHide),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("OnLinkModeChange")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnShow(data)
	if not self.p then
		self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	end

	self.lastTotalHeight = 0
	self.curDynamicTemplateCnt = 0

	if not self.hasAwake then
		return
	end

	if self.p then
		if self.p.IsFirstTime then
			self:InitAllBtns()
		end

		self:OnOnlineChange(_, gLinkManager:CheckInLinkMode())
	end

	self.isSetCurTaskBtnActive = gGpsManager:GetGpsShowMode() ~= gGpsShowMode.ShowTaskMode

	self.bindData.setCurTaskBtn:SetActive(self.isSetCurTaskBtnActive)
	self:HandleTaskShortCut()

	self.isQuitBtnActive = self.p.isShowGiveUp

	self.bindData.nQuitBtn.gameObject:SetActive(self.isQuitBtnActive)
	self:RefreshTaskInfo()
	self:RefreshTrueBranchList()

	if self.p.curTaskInfo then
		self.bindData.cNormal = gTaskManager.TaskColor[self.p.curTaskInfo.Title] and Color.NewByStr(gTaskManager.TaskColor[self.p.curTaskInfo.Title])
	end

	if gChallengeManager.currentChallengeTaskId ~= -1 then
		self:OnGoalStart(gChallengeManager.currentChallengeTaskId)
	end

	self:CalculateAndUpdateHeight()
end

function M:CalculateAndUpdateHeight()
	local dynamicCnt = 0

	if self.isTaskGuideBtnActive then
		dynamicCnt = dynamicCnt + 1
	end

	if self.isSetCurTaskBtnActive then
		dynamicCnt = dynamicCnt + 1
	end

	if self.isQuitBtnActive then
		dynamicCnt = dynamicCnt + 1
	end

	dynamicCnt = dynamicCnt + #self.branchList
	local totalHeight = self.defaultHeight + dynamicCnt * self.templateHeight

	if totalHeight ~= self.lastTotalHeight then
		self.lastTotalHeight = totalHeight

		gTaskUtils:SendMobileTaskPanelChange(totalHeight)
	end
end

function M:RefreshCurDynamicCnt(active)
	local oldCnt = self.curDynamicTemplateCnt

	if active then
		self.curDynamicTemplateCnt = self.curDynamicTemplateCnt + 1
	else
		self.curDynamicTemplateCnt = math.max(self.curDynamicTemplateCnt - 1, 0)
	end

	if self.curDynamicTemplateCnt ~= oldCnt then
		self:CalculateAndUpdateHeight()
	end
end

function M:OnClose(data)
	if data and data.TaskCounterChange then
		self.bindData.waFinishAnim = 1

		gLuaTimeMgrUtils.Delay(function ()
			if self.bindData then
				self.bindData.waFinishAnim = 0
			end
		end, TaskConfig.WorkActionFinishAnimDur or 2)
	end
end

function M:OnLinkModeChange()
	self:OnOnlineChange(_, gLinkManager:CheckInLinkMode())
end

function M:InitTrueBranchData()
	gTaskManager.curBranchIndex = -1
end

function M:OnDisable()
	self.isTaskGuideBtnActive = false

	self.bindData.nTaskGuideBtn.gameObject:SetActive(false)

	self.isQuitBtnActive = false

	self.bindData.nQuitBtn.gameObject:SetActive(false)

	self.isSetCurTaskBtnActive = gGpsManager:GetGpsShowMode() ~= gGpsShowMode.ShowTaskMode

	self.bindData.setCurTaskBtn:SetActive(self.isSetCurTaskBtnActive)
	gTaskUtils:SendMobileTaskPanelChange(0)
	self:ClearMessageEvents()
end

function M:InitAllBtns()
	self.isTaskGuideBtnActive = false

	self.bindData.nTaskGuideBtn.gameObject:SetActive(false)

	self.isQuitBtnActive = false

	self.bindData.nQuitBtn.gameObject:SetActive(false)

	self.isSetCurTaskBtnActive = gGpsManager:GetGpsShowMode() ~= gGpsShowMode.ShowTaskMode

	self.bindData.setCurTaskBtn:SetActive(self.isSetCurTaskBtnActive)
	self:CalculateAndUpdateHeight()
end

function M:OnCurrentDesChange(eventId, data)
	if data.isChange then
		local textId = data.textId
		local text = TextCommonTextConfig.GetConfig(textId).Text

		if text then
			self:SwitchTaskInfo(text)
		end
	else
		self:RefreshTaskInfo()
	end
end

function M:OnChangeCurDes(eventId, data)
	if not data then
		return
	end

	if data.taskCountIndex then
		if data.DesId and data.DesId ~= 0 then
			local des = LTConfig.TextConfig.GetConfig(data.DesId).Text

			if self.branchList ~= 0 then
				for i, v in ipairs(self.branchList) do
					if v.CounterIndex == data.taskCountIndex + 1 then
						self.branchList[i].EventObjective = des

						break
					end
				end

				self:SetNormalList()
			elseif #self.branchList == 0 then
				self.bindData.nTaskInfo = des
			end
		end

		if data.GpsPos then
			self:ClearCarRoute()

			local gpsId = self.p.curTaskId .. "_" .. tostring(data.taskCountIndex + 1)

			gMapSystem.container:GetByGpsId(gpsId):ClearTraceInfo()
		end
	elseif data.isRecover then
		self:RefreshCurrentTaskDes()
	else
		local des = nil
		local config = LTConfig.TextCommonTextConfig.GetConfig(data.DesId)

		if config then
			des = LTConfig.TextCommonTextConfig.GetConfig(data.DesId).Text

			self:SwitchTaskInfo(des)
		else
			print_error("#NoCreateIssue 请策划检查：ChangeCounterDes节点，当前选择更改描述，却获取不到对应的Text的描述Id")
		end
	end
end

function M:OnTaskEventChange(eventId, data)
	if not self.p.curTaskId or self.p.curTaskId <= 0 then
		return
	end

	local eventInfo = gTaskNodeManager:GetTaskLineByTask(self.p.curTaskId)

	if table.isNilOrEmpty(eventInfo) then
		return
	end

	if data.EventId and data.EventId == eventInfo.TaskLineId and not data.IsUnderway then
		self.delayShowCurTaskDes = gLuaTimeMgrUtils.Delay(function ()
			self.delayShowCurTaskDes = nil

			self:RefreshCurrentTaskDes()
		end, TaskConfig.StartInfoTime)
		self.bindData.nTaskInfo = TaskConfig.TaskStartInfo
	end
end

function M:RefreshTaskInfo()
	self:RefreshCurrentTaskDes()
	self:RefreshCurrentTaskEventUI()

	self.bindData.HideDes = 1
end

function M:ShowGiveUpButton(isShow, text)
	if isShow then
		self:SetShortCutButtonActive(false)
	end

	self:SetGiveUpButtonActive(isShow)

	if not isShow then
		return
	end

	if self.p.isShowGiveUp then
		self.bindData.giveupCtrl = 0
	elseif self.p.isShowRetry then
		self.bindData.giveupCtrl = 1
	else
		self:SetGiveUpButtonActive(false)
	end

	local imgId = TaskConfig.TaskGuideGivenUpImageId
	self.bindData.quitAction = imgId
end

function M:SetNormalList()
	self.bindData.nTaskList:SetSimpleList(#self.branchList)
	self:CalculateAndUpdateHeight()
end

function M:GetChildTargetCounter(data)
	local workActionInfo = data.workActionInfo
	local cfg = gTaskManager:GetTaskConfigInfo(self.p.curTaskId)
	local isShowChildTargetCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowSubTargetCounter)
	local taskCounter = ""

	if isShowChildTargetCounter then
		local counterIndex = data.CounterIndex
		local nowCounterValue = gTaskManager:GetTaskCounterValue(self.p.curTaskId, counterIndex)
		local allCounterValue = workActionInfo.totalValue
		taskCounter = "[" .. nowCounterValue .. "/" .. allCounterValue .. "]"
	end

	return taskCounter
end

function M:OnRenderTaskItem(btn, index)
	local data = self.branchList[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		if data.EventObjective then
			store.taskName = data.EventObjective .. self:GetChildTargetCounter(data)
		else
			store.taskName = ""
		end

		store.taskState = data.taskState
		store.pcKeyName = data.index

		if self:IsInPad() then
			store.mode = 1
		elseif self:IsInPc() then
			store.mode = 0
		else
			store.mode = 2
		end

		store.gamePadBtnController = data.gamePadBtnController

		store.branchItem:SetPCKeyInfoWithOutTip(data.pcKeyId, 0, 0, 0, 0)
	end
end

function M:RefreshTrueBranchList()
	if not self.p.curTaskInfo or self.p.curTaskId == nil then
		return
	end

	local isBranch = gTaskNodeManager:CheckTaskIsTrueBranch(self.p.curTaskId)
	local newDynamicCnt = 0

	if not isBranch then
		self.branchList = {}
		newDynamicCnt = #self.branchList

		if newDynamicCnt ~= self.curDynamicTemplateCnt then
			self.curDynamicTemplateCnt = newDynamicCnt

			self:CalculateAndUpdateHeight()
		end

		self.curBranchListIndex = -1

		self:SetNormalList()

		self.curIsTrueBranch = false

		return
	end

	self.curIsTrueBranch = true
	local _, workActions = gTaskNodeManager:GetTaskCounterInfo(self.p.curTaskId)
	local workLength = #workActions
	local workActionList = {}
	self.branchList = {}
	self.curBranchListIndex = -1

	for i = 1, workLength do
		local nowActionInfo = workActions[i]

		if nowActionInfo.IsBranchTarget then
			self.targetList = {}
			local info = {}
			local index = #self.targetList + 1
			self.targetList[index] = {
				TargetPos = nowActionInfo.TargetPos,
				CounterIndex = nowActionInfo.CounterIndex
			}

			if #workActionList == 0 then
				info.gamePadBtnController = 1
			else
				info.gamePadBtnController = 0
			end

			info.index = #workActionList + 1
			info.EventObjective = nowActionInfo.EventObjective or ""
			info.workActionInfo = nowActionInfo
			info.CounterIndex = nowActionInfo.CounterIndex
			info.pcKeyId = info.index + 14
			info.targetPos = nowActionInfo.TargetPos
			info.gpsId = self.p.curTaskId .. "_" .. nowActionInfo.CounterIndex
			info.taskState = 0
			info.RelatedTaskEvent = nowActionInfo.RelatedTaskEvent

			table.insert(workActionList, info)

			self.branchList = workActionList
		else
			self:SwitchTaskInfo(nowActionInfo.EventObjective)
		end
	end

	if not self.p.isDriverJob then
		self:SetNormalList()
	end

	self:CalculateAndUpdateHeight()
end

function M:OnBranchItemClick(btn, index)
	self:SwitchBranchByIndex(index)
end

function M:SwitchBranchByGpsId(gpsId)
	local targetIndex = nil

	if self.branchList == nil then
		return
	end

	for i, v in ipairs(self.branchList) do
		if v.gpsId == gpsId then
			targetIndex = i

			break
		end
	end

	if targetIndex then
		self:SwitchBranchByIndex(targetIndex - 1)
	end
end

function M:SwitchBranchByIndex(index)
	local isPad = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	local data = self.branchList[index + 1]

	if not data then
		return
	end

	gTaskManager.curBranchIndex = data.workActionInfo.CounterIndex
	self.curBranchListIndex = data.index

	if not table.isNilOrEmpty(self.branchList) then
		for i, v in pairs(self.branchList) do
			if v.index == data.index then
				v.taskState = 1
			else
				v.taskState = 0
			end
		end
	end

	local nextIndex = index + 1

	if nextIndex > #self.branchList - 1 then
		nextIndex = 0
	end

	if isPad then
		data.gamePadBtnController = 0
		local nextData = self.branchList[nextIndex + 1]
		nextData.gamePadBtnController = 1
	end

	self:SetNormalList()
	gMessageManager:SendMessage(gEventConstants.ON_BRANCH_TASK_CLICK, {
		taskId = self.p.curTaskId,
		index = data.index
	})

	if data.RelatedTaskEvent ~= 0 and self:CheckEventHasAccepted(data.RelatedTaskEvent) then
		self:ToSetChasingEvent(data.RelatedTaskEvent)
	else
		gMapSubSystem_Task:TraceByHudTaskBranchSwitch(self.p.curTaskId, data.gpsId)
	end
end

function M:CheckEventHasAccepted(eventId)
	local eventInfo = gTaskManager.taskEvents[eventId]

	if eventInfo and eventInfo.IsUnderway then
		return true
	end

	return false
end

function M:SetCurrentTask(eventId)
	local taskId = gTaskNodeManager:GetEventNowDoTaskId(eventId)

	if taskId ~= 0 then
		gTaskManager:SetCurrentTask(taskId, function ()
			local taskCfg = TaskConfig.GetConfig(taskId)

			if taskCfg and (taskCfg.RelatedTimeAndWeather.weatherId > 0 or taskCfg.RelatedTimeAndWeather.timeId > 0) then
				gDisplayMessageMgr:ShowMessage(MessageConfig.TaskChangeWeather)
			end
		end, self:GetPlayRole(eventId))
	end
end

function M:GetPlayRole(eventId)
	local taskEventConfig = TaskEventConfig.GetConfig(eventId)
	local playRole = taskEventConfig.PlayRoleInfo.StoryRole

	if playRole ~= 0 then
		return playRole
	elseif next(taskEventConfig.PlayRoles) then
		local sex = gPlayerManager.infoLogin.bindData.sexType

		for _, fid in pairs(taskEventConfig.PlayRoles) do
			local config = FightSpiritConfig.GetConfig(fid)
			local agentConfig = AgentConfig.GetConfig(config.AgentId)

			if agentConfig.SexType == sex then
				return fid
			end
		end
	end

	return 0
end

function M:ToSetChasingEvent(eventId)
	gGpsManager:TryRemoveNowMapGuide()
	self:SetCurrentTask(eventId)
end

function M:RefreshCurrentTaskDes()
	if not self.p then
		self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	end

	if not self.p.curTaskInfo then
		return
	end

	local des = self.p.curTaskInfo.WorkDescription or ""
	local eventInfo = gTaskNodeManager:GetTaskLineByTask(self.p.curTaskId)

	if eventInfo and eventInfo.TaskLineId == TaskEventConfig.RideAndDate and self.p.cultivationId then
		local cultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(self.p.cultivationId)

		if cultivationCfg then
			des = des:format(cultivationCfg.Name)
		end
	end

	if self.p.isInTaskRaid then
		self:SwitchTaskInfo(des .. self:GetTaskCounter())
	else
		self:SwitchTaskInfo(self.p.curTaskInfo.EventObjective or "")
	end

	if gTaskManager:IsTaskInRiskControl(self.p.curTaskInfo.TaskId) then
		self:SwitchTaskInfo(LTConfig.TextScriptTextConfig.GetConfig(89900961).Text)
	end
end

function M:RefreshCurrentTaskEventUI()
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

function M:SwitchTaskInfo(taskInfo)
	self.bindData.nTaskInfo = taskInfo
end

function M:GetTaskCounter()
	local taskInfo = self.p.curTaskInfo
	local taskCounter = ""

	if self.p.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.p.curTaskId)
		local isShowAllCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllCounter)

		if taskInfo.totalValue and not isShowAllCounter then
			allCounterValue = taskInfo.totalValue
		elseif self.p.curTaskInfo.TargetType ~= gTaskManager.ACTION_TYPE.NONE then
			for i = 1, #cfg.Counter do
				local couterNum = cfg.Counter[i]
				allCounterValue = allCounterValue + couterNum
			end
		end

		if isShowAllCounter then
			local tasks = gTaskManager:GetTaskInfo(self.p.curTaskId)

			if self.p.curTaskInfo.TargetType ~= gTaskManager.ACTION_TYPE.NONE then
				nowCounterValue = 0

				for i = 1, #tasks.Counters do
					nowCounterValue = tasks.Counters[i].Value + nowCounterValue
				end
			end
		end

		taskCounter = "[" .. nowCounterValue .. "/" .. allCounterValue .. "]"
	end

	return taskCounter
end

function M:LanguageChange()
	self:RefreshTaskInfo()
	self:RefreshTrueBranchList()
end

function M:SetShortCutButtonActive(isActive)
	self.isTaskGuideBtnActive = isActive

	self.bindData.nTaskGuideBtn.gameObject:SetActive(isActive)

	if self.branchList and #self.branchList > 0 and self.curBranchListIndex ~= -1 then
		local nextIndex = self.curBranchListIndex + 1
		self.branchList[nextIndex].gamePadBtnController = 1
	end

	self:CalculateAndUpdateHeight()
end

function M:SetGiveUpButtonActive(isActive)
	self.isQuitBtnActive = isActive

	self.bindData.nQuitBtn.gameObject:SetActive(isActive)
	self:CalculateAndUpdateHeight()
end

function M:OnTaskShortcutChange(eventId, data)
	self:HandleTaskShortCut()
end

function M:HandleTaskShortCut()
	if self.p and (not self.p.curCfgId or self.p.curCfgId == 0) then
		self.isTaskGuideBtnActive = false

		self.bindData.nTaskGuideBtn.gameObject:SetActive(false)
		self:CalculateAndUpdateHeight()

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

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:RefreshPCKey(inputCfg, self.p.isShowShortCut)
		self:RefreshPadKey(inputCfg, self.p.isShowShortCut)
	end

	self.isTaskGuideBtnActive = self.p.isShowShortCut

	self.bindData.nTaskGuideBtn.gameObject:SetActive(self.isTaskGuideBtnActive)

	self.bindData.action = imgId
	self.bindData.keyname = keyName

	self:CalculateAndUpdateHeight()
end

function M:RefreshPCKey(inputCfg, isShow)
	self.bindData.nTaskGuideBtn.gameObject:SetActive(isShow)

	self.bindData.isTaskLongPress = 0
	local pcKeyId = inputCfg.Key[1]
	local pcKeyName = LTConfig.InputSGUIPCKeyConfig.GetConfig(pcKeyId).Name

	self.bindData.nTaskGuideBtn:SetPCKeyInfoWithOutTip(pcKeyId, 0, 0, 0, 10)

	self.bindData.pcKeyName = pcKeyName
end

function M:RefreshPadKey(inputCfg, isShow)
	self.bindData.nTaskGuideBtn.gameObject:SetActive(isShow)
	self.bindData.padKey.gameObject:SetActive(isShow)

	local padId = inputCfg.GamepadKey
	local iconStyle = inputCfg.GamepadStyle
	local respondType = inputCfg.GamepadType

	if respondType == 1 then
		self.bindData.isTaskLongPress = 1

		self.bindData.padPressText.gameObject:SetActive(true)
	else
		self.bindData.isTaskLongPress = 0

		self.bindData.padPressText.gameObject:SetActive(false)
	end

	if padId ~= 0 and padId then
		if respondType == 1 then
			self.bindData.padKey:ChangeImageAction(padId, 0, nil, 0, iconStyle, -10)
		else
			self.bindData.padKey:ChangeImageAction(padId, 0, nil, 0, iconStyle, 11)
		end
	end
end

function M:OnClickBtn()
	if self.p.shortCutRecordById then
		gDialogAction:RunCodeByTask(self.shortcutCallbackFuncStr, self.p.curTaskId)

		return
	end
end

function M:OnClickGpsSwitch()
	gGpsManager:SwitchGpsShowMode(gGpsShowMode.ShowTaskMode)
end

function M:GiveUpTask()
	if self.p.curTaskId and self.p.curTaskId ~= 0 then
		self:TryGiveUpTask(self.p.curTaskId, function ()
			if self.p.isShowGiveUp then
				gTaskManager:RemoveCurrentTask(self.p.curTaskId)
			else
				gClientToGameDelegate:AskDeleteTask(self.p.curTaskId, false).Callback = function ()
					return
				end
			end
		end)
	end
end

function M:TryGiveUpTask(taskId, okCB)
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

function M:OnMobileQuitTask()
	self:GiveUpTask()
end

function M:OnQuitTaskPress()
	if gCS.LuaUtils.IsMobilePlatform() then
		return
	end

	self.isQuitPressing = true
	curSecond = 0
	self.bindData.isQuitLongPressImg = 1
end

function M:OnQuitTaskRelease()
	self.isQuitPressing = false

	if curSecond < 1 then
		self.bindData.isQuitLongPressImg = 0
		self.bindData.quitPCFillAmount = 0
		curSecond = 0
	end
end

function M:OnSwitchGpsShowMode(eventId, data)
	if not self.p.curTaskId or self.p.curTaskId <= 0 then
		return
	end

	local active = data == 1
	self.isSetCurTaskBtnActive = active

	self.bindData.setCurTaskBtn:SetActive(active)

	if active then
		self:SetShortCutButtonActive(false)

		self.bindData.HideDes = 0

		self.bindData.goalList.gameObject:SetActive(false)
	else
		if self.isShowShortCut then
			self:SetShortCutButtonActive(true)
		end

		self.bindData.HideDes = 1

		self.bindData.goalList.gameObject:SetActive(true)
	end

	self:CalculateAndUpdateHeight()
end

function M:IsInPc()
	return InputActionBind.activeGameDevice == GameDevice.KeyboardMouse
end

function M:IsInPad()
	return InputActionBind.activeGameDevice == GameDevice.Xbox or InputActionBind.activeGameDevice == GameDevice.PlayStation
end

function M:OnPhoneAppShow()
	if self.p.isShowShortCut then
		self:SetShortCutButtonActive(false)
	end
end

function M:OnPhoneAppHide()
	self:RecoverShortCutButtonActive()
end

function M:RecoverShortCutButtonActive()
	if self.p.isShowShortCut then
		self:SetShortCutButtonActive(true)
	end
end

function M:OnRenderGoalItem(btn, index)
	local store = gStoreManager:GetStoreGroup("ChallengeGoalTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.challengeLists[index + 1]
	store.titleCom.text = data.desc

	if data.isFirst then
		data.isFirst = false
		local height = store.titleCom:GetPreferredHeight() + 5
		data.item = btn

		btn:InvokeCallback(SGUI.EInvokeTime.User2)

		btn.localPosition = Vector3.New(0, self.preHeight, 0)
		self.effectHeight[index + 1] = height
		self.preHeight = self.preHeight - height

		if index == #self.challengeLists - 1 then
			self:SetTransRectHeight(self.bindData.goalList.rectTransform, -self.preHeight)
		end
	end
end

function M:SetTransRectHeight(rectTransform, height)
	local rect = rectTransform.rect
	local width = rect.width
	rectTransform.sizeDelta = Vector2.New(width, height)
end

function M:GoalPlayAni(btn, targetY)
	local target = Vector3.New(0, targetY, 0)

	AnimMgr.Move(btn.rectTransform, "BubbleFilmEmojiShowAni", target, 0.2, 1, DG.Tweening.Ease.OutQuad, nil)
end

function M:OnOnlineChange(_, enable)
	if enable then
		self.bindData.Online = 1
	else
		self.bindData.Online = 0
	end
end

function M:OnGoalStart(taskId)
	if not self.STATE_EnableOnce then
		return
	end

	print_debug("OnGoalStart", taskId)

	self.challengeCfg = gChallengeManager:GetChallengeConfigByTaskId(taskId)

	if not self.challengeCfg then
		return
	end

	self.bindData.hasGoal = 1
	self.challengeType = self.challengeCfg.ChallengeType
	self.challengeLists = {}
	self.checks = {}
	self.effectHeight = {}
	self.checkCount = 0
	self.preHeight = 0
	local param = self.challengeCfg.ChallengeParams
	local value = self.challengeCfg.CounterValue

	for i = 1, #param do
		local ele = gChallengeManager:GetChallengeParamStruct(param[i], value[i])
		ele.id = i

		if not table.isNilOrEmpty(ele) then
			self.checks[i] = gChallengeManager:GenCheckBlock(taskId, param[i], value[i])

			table.insert(self.challengeLists, ele)

			self.checkCount = self.checkCount + 1
			self.effectHeight[i] = 0
		end
	end

	gChallengeManager:InitCounterValue(self.challengeLists)
	self.bindData.goalList:SetList(#self.challengeLists)
end

function M:OnGoalEnd()
	self.bindData.hasGoal = 0

	if self.checks then
		for i = 1, #self.checks do
			if not self.checks[i].isDispose then
				local success, value = self.checks[i]:Check()

				self.checks[i]:Dispose()

				self.checks[i] = nil

				gChallengeManager:SetCounterValue(i, success)
			end
		end
	end

	self.checkCount = 0
end

function M:OnGoalUpdate()
	if self.checkCount <= 0 then
		return
	end

	local diff = false
	local currentHeight = 0
	local offset = 0

	for i = 1, #self.checks do
		if self.checks[i] and not self.checks[i].isDispose then
			local success, value = self.checks[i]:Check()
			value = math.floor(value)

			if value ~= self.challengeLists[i].realValue then
				diff = true
				self.challengeLists[i].realValue = value
				self.challengeLists[i].desc = gString.Format(self.challengeLists[i].name, value)
			end

			if success then
				self.checks[i]:Dispose()

				self.checkCount = self.checkCount - 1

				self.challengeLists[i].item:InvokeCallback(SGUI.EInvokeTime.User1)

				offset = offset + 1

				gChallengeManager:SetCounterValue(i, success)
			elseif offset > 0 then
				self:GoalPlayAni(self.challengeLists[i].item, currentHeight)
			end

			currentHeight = success and currentHeight or currentHeight - self.effectHeight[i]
		end
	end

	if diff then
		self.bindData.goalList:RefreshList()
	end
end
