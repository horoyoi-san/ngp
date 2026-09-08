-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChallengeTaskStore.lua
-- Decompiled from: 01453_ChallengeTaskStore.lua_74ae5d348038.luajit

C_ChallengeTaskStore = DefClass("C_ChallengeTaskStore", C_ChallengeTaskStore, C_StoreGroup)
GroupName2Class.ChallengeTaskStore = C_ChallengeTaskStore
local M = C_ChallengeTaskStore
local TaskConfig = LTConfig.TaskConfig
local TaskShortCutConfig = LTConfig.TaskShortCutConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice

M.ctor = function(self)
	self.isStart = false
	self.isStartCb = nil
	self.isQuitPressing = false
	self.checkCount = 0
	self.hasAwake = false
	self.isTaskGuideBtnActive = false
	self.isQuitBtnActive = false
end

M.OnAwake = function(self)
	self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	self.bindData.nTaskGuideBtn.luaClick = self:CreateAction(self.OnClickBtn)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.nQuitBtn.luaBeginLongPress = self.CreateAction(self, self.OnQuitTaskPress)
		self.bindData.nQuitBtn.luaEndLongPress = self.CreateAction(self, self.OnQuitTaskRelease)
	else
		self.bindData.nQuitBtn.luaClick = self.CreateAction(self, self.OnMobileQuitTask)
	end

	self.bindData.goalList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderGoalItem)
	self.bindData.goalList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnRenderGoalItem)
	self.hasAwake = true
	self.msgEvents = {
		[gEventConstants.CURRENT_TASK_CHANGE] = self.CreateAction(self, self.OnCurrentChange),
		[gEventConstants.SWITCH_GPS_SHOW_MODE] = self.CreateAction(self, self.OnSwitchGpsShowMode),
		[gEventConstants.TASK_EVENT_CHANGE] = self.CreateAction(self, self.OnTaskEventChange),
		[gEventConstants.TASK_CHANGE_CURRENT_DES] = self.CreateAction(self, self.OnCurrentDesChange),
		[gEventConstants.TASK_SHORTCUT_CHANGE] = self.CreateAction(self, self.OnTaskShortcutChange),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, self.OnPhoneAppShow),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, self.OnPhoneAppHide),
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, self.OnLinkModeChange),
		[gEventConstants.CHALLENGE_GOAL_START] = self.CreateAction(self, self.OnGoalStart),
		[gEventConstants.CHALLENGE_GOAL_END] = self.CreateAction(self, self.OnGoalEnd)
	}

	if self.bindData.heightBox then
		self.bindData.heightBox.luaSizeChanged = self.CreateAction(self, "OnSizeChanged")
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

M.OnUpdate = function(self)
	self.OnGoalUpdate(self)
end

M.OnStart = function(self)
	self.isStart = true

	if self.isStartCb == nil then
		self.isStartCb()
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnCurrentChange = function(self, eventId, data)
	if not self.isStart then
		self.isStartCb = function()
			self:OnCurrentChange(nil, data)
		end

		self.isStartCb = nil

		return
	end

	if data then
		local taskInfo = gTaskManager:GetTaskInfo(data.TaskId)

		if taskInfo then
			self.RefreshTaskInfo(self)
		end
	end
end

M.OnShow = function(self, data)
	self.bindData.quitPCFillAmount = 0

	if not self.p then
		self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	end

	if not self.hasAwake then
		return
	end

	if self.p then
		if self.p.IsFirstTime then
			self.InitAllBtns(self)
		end

		self:OnOnlineChange(_, gLinkManager:CheckInLinkMode())
	end

	self:HandleTaskShortCut()

	self.isQuitBtnActive = self.p.isShowGiveUp
	self.bindData.giveup = self.isQuitBtnActive and 0 or 1

	self:RefreshTaskInfo()

	if gChallengeManager.currentChallengeTaskId == -1 then
		self.OnGoalStart(self, _, gChallengeManager.currentChallengeTaskId)
	end
end

M.OnClose = function(self, data)
	if data and data.TaskCounterChange then
		self.bindData.waFinishAnim = 1

		gLuaTimeMgrUtils.Delay(function ()
			if self.bindData then
				self.bindData.waFinishAnim = 0
			end
		end, TaskConfig.WorkActionFinishAnimDur or 2)
	end
end

M.OnLinkModeChange = function(self)
	self:OnOnlineChange(_, gLinkManager:CheckInLinkMode())
end

M.OnEnable = function(self)
	self.bindData.quitPCFillAmount = 0
end

M.OnDisable = function(self)
	self.bindData.quitPCFillAmount = 0
	self.isTaskGuideBtnActive = false
	self.bindData.shortcut = 1
	self.isQuitBtnActive = false
	self.bindData.giveup = 1
end

M.InitAllBtns = function(self)
	self.isTaskGuideBtnActive = false
	self.bindData.shortcut = 1
	self.isQuitBtnActive = false
	self.bindData.giveup = 1
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

	if eventInfo and eventInfo.TaskLineId ~= TaskEventConfig.RideAndDate and self.p.cultivationId then
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

M.SwitchTaskInfo = function(self, taskInfo)
	self.bindData.nTaskInfo = taskInfo
end

M.GetTaskCounter = function(self)
	local taskInfo = self.p.curTaskInfo
	local taskCounter = ""

	if self.p.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.p.curTaskId)
		local isShowAllCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllCounter)

		if taskInfo.totalValue and not isShowAllCounter then
			allCounterValue = taskInfo.totalValue
		else
			for i = 1, #cfg.Counter do
				local couterNum = cfg.Counter[i]
				allCounterValue = allCounterValue + couterNum
			end
		end

		if isShowAllCounter then
			local tasks = gTaskManager:GetTaskInfo(self.p.curTaskId)
			nowCounterValue = 0

			for i = 1, #tasks.Counters do
				nowCounterValue = tasks.Counters[i].Value + nowCounterValue
			end
		end

		if not taskInfo.NotShowProgress or not not isShowAllCounter then
			taskCounter = "[" .. nowCounterValue .. "/" .. allCounterValue .. "]"
		end
	end

	return taskCounter
end

M.LanguageChange = function(self)
	self.RefreshTaskInfo(self)
	self.HandleTaskShortCut(self)
end

M.SetShortCutButtonActive = function(self, isActive)
	self.isTaskGuideBtnActive = isActive
	self.bindData.shortcut = isActive and 0 or 1
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

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.RefreshPCKey(self, inputCfg, self.p.isShowShortCut)
		self.RefreshPadKey(self, inputCfg, self.p.isShowShortCut)
	end

	self.isTaskGuideBtnActive = self.p.isShowShortCut
	self.bindData.shortcut = self.isTaskGuideBtnActive and 0 or 1
	self.bindData.action = imgId
	self.bindData.keyname = keyName
end

M.RefreshPCKey = function(self, inputCfg, isShow)
	self.bindData.shortcut = isShow and 0 or 1
	local pcKeyId = inputCfg.Key[1]

	self.bindData.nTaskGuideBtn:SetPCKeyInfoWithOutTip(pcKeyId, 0, 0, 0, 10)
end

M.RefreshPadKey = function(self, inputCfg, isShow)
	self.bindData.shortcut = isShow and 0 or 1
end

M.OnClickBtn = function(self)
	if self.p.shortCutRecordById then
		gDialogAction:RunCodeByTask(self.shortcutCallbackFuncStr, self.p.curTaskId)

		return
	end
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
	if gChallengeManager.isWushuMode then
		gChallengeManager:SettleWushuChallenge(false)

		return
	end

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
end

M.OnQuitTaskRelease = function(self)
	self.GiveUpTask(self)
end

M.OnSwitchGpsShowMode = function(self, eventId, data)
	if not self.p.curTaskId or self.p.curTaskId < 0 then
		return
	end

	local active = data ~= 1

	if active then
		self:SetShortCutButtonActive(false)

		self.bindData.HideDes = 0

		self.bindData.goalList.gameObject:SetActive(false)
	else
		if self.isShowShortCut then
			self.SetShortCutButtonActive(self, true)
		end

		self.bindData.HideDes = 1

		self.bindData.goalList.gameObject:SetActive(true)
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

M.OnRenderGoalItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("ChallengeGoalTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.challengeLists[index + 1]
	store.titleCom.text = data.desc
end

M.OnOnlineChange = function(self, _, enable)
	if enable then
		self.bindData.Online = 1
	else
		self.bindData.Online = 0
	end
end

M.OnGoalStart = function(self, _, taskId)
	gChallengeManager:Log("OnGoalStart taskId=%s", taskId)

	if not self.STATE_EnableOnce then
		return
	end

	if gChallengeManager:IsInOnlineMode() then
		gChallengeManager:Log("OnGoalStart 联机模式跳过渲染挑战目标列表")

		self.bindData.hasGoal = 0
		self.challengeLists = {}
		self.checkCount = 0

		self.bindData.goalList:SetSimpleList(0)

		return
	end

	self.challengeCfg = gChallengeManager:GetChallengeConfigByTaskId(taskId)

	if not self.challengeCfg then
		return
	end

	self.bindData.hasGoal = 1
	self.challengeType = self.challengeCfg.ChallengeType
	self.challengeLists = {}
	self.effectHeight = {}
	self.checkCount = 0
	self.preHeight = 0
	local param = self.challengeCfg.ChallengeParams
	local value = self.challengeCfg.CounterValue

	for i = 1, #param do
		local ele = gChallengeManager:GetChallengeParamStruct(param[i], value[i])
		ele.id = i

		if not table.isNilOrEmpty(ele) then
			ele.checkBlock = gChallengeManager:GenCheckBlock(taskId, param[i], value[i])

			gChallengeManager:LogDetail("OnGoalStart 目标%s paramId=%s checkBlock存在=%s", i, param[i], tostring(ele.checkBlock == nil))
			table.insert(self.challengeLists, ele)

			self.checkCount = self.checkCount + 1
			self.effectHeight[i] = 0
		end
	end

	gChallengeManager:InitCounterValue(self.challengeLists)
	self.bindData.goalList:SetSimpleList(#self.challengeLists)
end

M.OnGoalEnd = function(self)
	self.bindData.hasGoal = 0

	if self.challengeLists then
		for i, v in ipairs(self.challengeLists) do
			if v.checkBlock and not v.checkBlock.isDispose then
				gChallengeManager:LogDetail("OnGoalEnd Check前 id=%s taskId=%s isDispose=%s", v.id, v.checkBlock.taskId, tostring(v.checkBlock.isDispose))

				local success, value = v.checkBlock:Check()

				gChallengeManager:LogDetail("OnGoalEnd Check后 id=%s success=%s value=%s", v.id, tostring(success), tostring(value))
				v.checkBlock:Dispose()

				v.checkBlock = nil

				gChallengeManager:LogDetail("OnGoalEnd SetCounterValue id=%s success=%s", v.id, tostring(success))
				gChallengeManager:SetCounterValue(v.id, success)
			end
		end
	end

	self.checkCount = 0
end

M.OnGoalUpdate = function(self)
	if self.checkCount < 0 then
		return
	end

	local diff = false
	local removed = false

	for i = #self.challengeLists, 1, -1 do
		local ele = self.challengeLists[i]

		if ele.checkBlock and not ele.checkBlock.isDispose then
			local success, value = ele.checkBlock:Check()
			value = math.floor(value)

			if value == ele.realValue then
				diff = true
				ele.realValue = value
				ele.desc = gString.Format(ele.name, value)
			end

			if success then
				gChallengeManager:LogDetail("OnGoalUpdate 提前达成 id=%s value=%s", ele.id, tostring(value))
				ele.checkBlock:Dispose()

				self.checkCount = self.checkCount - 1

				if ele.item then
					ele.item:InvokeCallback(SGUI.EInvokeTime.User1)
				end

				gChallengeManager:LogDetail("OnGoalUpdate SetCounterValue id=%s", ele.id)
				gChallengeManager:SetCounterValue(ele.id, success)
				table.remove(self.challengeLists, i)

				removed = true
			end
		end
	end

	if removed or diff then
		self.bindData.goalList:SetSimpleList(#self.challengeLists)
	end
end
