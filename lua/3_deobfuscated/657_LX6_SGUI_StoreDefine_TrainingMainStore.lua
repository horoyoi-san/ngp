C_TrainingMainStore = DefClass("C_TrainingMainStore", C_TrainingMainStore, C_StoreGroup)
GroupName2Class.TrainingMainStore = C_TrainingMainStore
local M = C_TrainingMainStore
local TaskState = UX.Game.TaskState
local TrainingConfig = LTConfig.CombatTrainingTrainWorkactionConfig
local SGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
local SGUIGamepadCofig = LTConfig.InputSGUIGamepadConfig
local curTime = 0

function M:ctor()
	self.guideSuccessAnimName = "S_Vx_TrainingFloatingGuide_success"
	self.btnCloseAnimName = "S_Vx_TrainingBtn_close"

	self:InitData()

	self.buttonNamePCDic = {}
	self.curMobileVXInfo = nil

	for i = 0, LTConfig.InputKeyboardConfig.count - 1 do
		local cfg = LTConfig.InputKeyboardConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.ButtonName) then
			self.buttonNamePCDic[cfg.ButtonName] = cfg
		end
	end

	self.buttonNameGamepadDic = {}

	for i = 0, LTConfig.InputGamepadConfig.count - 1 do
		local cfg = LTConfig.InputGamepadConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.ButtonName) then
			self.buttonNameGamepadDic[cfg.ButtonName] = cfg
		end
	end
end

function M:InitData()
	self.isDestroy = false
	self.delayChildIndex = nil
	self.isPress = false
	self.curHasSetFail = false
	self.currentChildIsFail = false
	self.curTime = 0
	self.isGuide = false
	self.curTaskId = 0
	self.curTaskInfo = nil
	self.curChildIndexList = {}
	self.guideData = {}
	self.curParentCounterIndex = 0
	self.curChildIndex = 0
	self.childGuideMap = {}
end

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	self.typeEnum = {
		guide = 0,
		btn = 1
	}
	self.tipEnum = {
		hide = 1,
		keepshow = 0
	}
	self.btnTypeEnum = {
		longpresshow = 2,
		click = 0,
		longpress = 1
	}
	self.btnTipsEnum = {
		hide = 1,
		show = 0
	}
	self.btnModeEnum = {
		success = 0,
		close = 3,
		fail = 1,
		normal = 2
	}
	self.btnIconEnum = {
		_false = 0,
		_true = 1
	}
	self.padKeyCntEnum = {
		double = 1,
		single = 0
	}
	self.guideFinishEnum = {
		hide = 2,
		_false = 1,
		_true = 0
	}
end

function M:ClearAllEnumsAutoGen()
	self.typeEnum = nil
	self.tipEnum = nil
	self.btnTypeEnum = nil
	self.btnTipsEnum = nil
	self.btnModeEnum = nil
	self.btnIconEnum = nil
	self.padKeyCntEnum = nil
	self.guideFinishEnum = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
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
	self.isDestroy = true

	if self.curMobileVXInfo then
		self.curMobileVXInfo.isActive = false

		gMessageManager:SendMessage(gEventConstants.TASK_WORKACTION_MOBILE_VX, self.curMobileVXInfo)
	end
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self:InitData()

	self.isDestroy = false
	self.guideData = {}
	self.btnMode = {
		Normal = self.btnModeEnum.normal,
		Success = self.btnModeEnum.success,
		Fail = self.btnModeEnum.fail
	}
	self.currentTaskType = gTaskManager.CurrentTaskType.Task1
	local localData = {
		IsFirstTime = true,
		CurrentTaskType = self.currentTaskType
	}

	self:SetCurrentTaskData(localData, true)

	self.lastParentCounterIndex = -1

	if not self.curTaskInfo then
		print_error("@buyifan TrainingMainStore，找不到当前的taskInfo")

		return
	end

	self:RefreshListAfterUpdate()
end

function M:RefreshListAfterUpdate()
	if self.curTaskInfo.IsGuide then
		if not self.bindData or not self.typeEnum then
			return
		end

		self.bindData.type = self.typeEnum.guide
		self.guideData = {}
		local guideData = {
			SkillId = self.curTaskInfo.SkillId
		}

		table.insert(self.guideData, guideData)
		self:GetList():SetSimpleList(#self.guideData)
	else
		self.guideData = {}
		local taskInfo = gTaskManager:GetTaskInfo(self.curTaskId)
		local childCounters = taskInfo.Counters[self.curParentCounterIndex].Child
		self.curChildIndexList = childCounters
		self.bindData.type = self.typeEnum.btn

		if not string.is_null_or_empty(self.curTaskInfo.WorkDescription) then
			self.bindData.tip = self.tipEnum.keepshow
			local cfg = TrainingConfig.GetConfig(self.curTaskInfo.SkillId)

			if not cfg then
				print_error("#NoCreateIssue @wangshuowei, button模式下战斗教学没配该Id", self.curTaskInfo.SkillId)
			else
				self.bindData.btnTipText = LTConfig.TextCommonTextConfig.GetConfig(cfg.StateDesId).Text
			end
		else
			self.bindData.tip = self.tipEnum.hide
		end

		if #childCounters ~= 0 then
			for i, v in ipairs(childCounters) do
				if i == 1 and self.curChildIndex == 0 then
					self.curChildIndex = 1
				end

				local childInfo = gTaskNodeManager:GetTaskWorkActionInfo(self.curTaskId, v.Index + 1)
				local guideData = {
					curPressTime = 0,
					SkillId = childInfo.SkillId
				}
				local config = TrainingConfig.GetConfig(childInfo.SkillId)
				guideData.StateDesId = config.StateDesId
				guideData.TimingDesId = config.TimingDesId
				guideData.PressTime = config.PressTime
				guideData.InputId = config.InputId
				guideData.padInputId = config.PadInputId
				guideData.mobileId = config.MobileImage
				guideData.mode = self.btnMode.Normal
				guideData.lineActive = i ~= #childCounters

				table.insert(self.guideData, guideData)

				self.childGuideMap[v.Index] = i
			end
		end

		self:GetList():SetSimpleList(#self.guideData)
	end
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device

	self:GetList():SetSimpleList(#self.guideData)
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.TRAIN_WORKACTION_PRESS_FAIL] = self:CreateAction("OnPressFail"),
		[gEventConstants.TRAIN_WORKACTION_PRESS_START] = self:CreateAction("OnPressStart"),
		[gEventConstants.CURRENT_TASK_CHANGE] = self:CreateAction("OnCurrentChange")
	}
end

function M:RefreshListBeforeChange()
	if self.isGuide then
		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			local config = LTConfig.CombatTrainingTrainWorkactionConfig.GetConfig(self.curTaskInfo.SkillId)
			local table = {
				isActive = false,
				MobileImage = config.MobileImage,
				MobileBtnName = config.MobileBtnName
			}

			gMessageManager:SendMessage(gEventConstants.TASK_WORKACTION_MOBILE_VX, table)

			if self.curMobileVXInfo then
				self.curMobileVXInfo = nil
			end
		end

		self:GetList():SetSimpleList(#self.guideData)
	else
		if self.curChildIndex > #self.curChildIndexList then
			return
		end

		local childCounterIndex = self.curChildIndexList[self.curChildIndex].Index

		if gTaskManager.WorkActions.counterValues[self.curTaskId][childCounterIndex + 1] < gTaskManager.WorkActions.configCounterValues[self.curTaskId][childCounterIndex + 1] then
			self.guideData[self.curChildIndex].mode = self.btnModeEnum.fail
			self.curChildIndex = 1
		else
			if self.isPress then
				self.isPress = false
				self.curTime = 0
			end

			self.guideData[self.curChildIndex].mode = self.btnModeEnum.success

			self:GetList():SetSimpleElement(self.curChildIndex - 1, self:OnGetBtnTIndex())

			self.curChildIndex = self.curChildIndex + 1
		end
	end
end

function M:ResetButtonAfterDelay(index, delay)
	Timer.New(function ()
		if self.guideData and index and index >= 1 and index <= #self.guideData then
			self.guideData[index].mode = self.btnModeEnum.normal
			self.guideData[index].curPressTime = 0

			self:GetList():SetSimpleElement(index - 1, self:OnGetBtnTIndex())
		end
	end, delay):Start()
end

function M:ResetBtns()
	for i, v in ipairs(self.guideData) do
		v.mode = self.btnModeEnum.normal
		v.curPressTime = 0
		v.isClose = false
	end

	self:GetList():SetSimpleList(#self.guideData)

	if not self.delayChildIndex or not self.guideData[self.delayChildIndex] then
		return
	end

	Timer.New(function ()
		if self.guideData and self.delayChildIndex and self.guideData[self.delayChildIndex] then
			self.guideData[self.delayChildIndex].mode = self.btnModeEnum.fail

			self:GetList():SetSimpleElement(self.delayChildIndex - 1, self:OnGetBtnTIndex())
			Timer.New(function ()
				if self.guideData and self.delayChildIndex and self.guideData[self.delayChildIndex] then
					self.guideData[self.delayChildIndex].mode = self.btnModeEnum.normal

					self:GetList():SetSimpleElement(self.delayChildIndex - 1, self:OnGetBtnTIndex())

					self.delayChildIndex = nil
				end
			end, 0.8):Start()
		end
	end, 0.1):Start()
end

function M:OnCurrentChange(eventId, data)
	local taskInfo = gTaskManager:GetTaskInfo(self.curTaskId)

	if data.TaskCounterChange then
		if taskInfo and taskInfo.Counters and self.curParentCounterIndex <= #taskInfo.Counters and taskInfo.Counters[self.curParentCounterIndex].Value == 0 and data.changedCounterIndex and data.changedCounterIndex + 1 == self.curParentCounterIndex then
			if self.curChildIndexList and self.curChildIndex > 0 then
				self.delayChildIndex = self.curChildIndex

				self:ResetBtns()
			end

			self.curChildIndex = 0

			self:RefreshListAfterUpdate()

			return
		end

		if self.curParentCounterIndex >= #taskInfo.Counters and taskInfo.Counters[self.curParentCounterIndex].Value == taskInfo.Counters[self.curParentCounterIndex].ConfigValue then
			self:NoTask()
			gPanelManager:Close(gPanelId.TRAINING_MAIN_PANEL)

			return
		end

		if self.curTaskId == 0 then
			return
		end

		local childCounters = taskInfo.Counters[self.curParentCounterIndex].Child
		self.curChildIndexList = childCounters

		if self.curTaskInfo then
			self:RefreshListBeforeChange()
		end

		local function ContinueLogic()
			if self.isDestroy then
				return
			end

			if self.isGuide then
				if taskInfo and taskInfo.Counters and taskInfo.Counters[self.curParentCounterIndex].Value == taskInfo.Counters[self.curParentCounterIndex].ConfigValue then
					self.lastParentCounterIndex = self.curParentCounterIndex
					self.curParentCounterIndex = self.curParentCounterIndex + 1
				end
			elseif self.curChildIndexList and self.curChildIndex > #self.curChildIndexList then
				self.lastParentCounterIndex = self.curParentCounterIndex
				self.curChildIndex = 0
				self.curParentCounterIndex = self.curParentCounterIndex + 1
			end

			local currentTaskType = data.CurrentTaskType
			self.IsFirstTime = data.IsFirstTime or false

			if currentTaskType == gTaskManager.CurrentTaskType.Task1 then
				self:SetCurrentTaskData(data)
			end

			if self.curTaskInfo and self.curParentCounterIndex <= #taskInfo.Counters then
				if self.lastParentCounterIndex ~= self.curParentCounterIndex and self.lastParentCounterIndex ~= -1 then
					self:RefreshListAfterUpdate()

					self.lastParentCounterIndex = self.curParentCounterIndex
				end
			elseif not self.isGuide then
				coroutine.start(function ()
					coroutine.wait(0.5)
					gPanelManager:Close(gPanelId.TRAINING_MAIN_PANEL)
				end)
			end
		end

		if self.curTaskInfo and self.curParentCounterIndex <= #taskInfo.Counters then
			if self.isGuide then
				coroutine.start(function ()
					coroutine.wait(self.guideSuccessAnimTime or 0.5)
					ContinueLogic()
				end)
			elseif self.curChildIndexList and self.curChildIndex > #self.curChildIndexList then
				coroutine.start(function ()
					if self.isDestroy then
						return
					end

					for i, v in ipairs(self.guideData) do
						v.isClose = true
					end

					self:GetList():SetSimpleList(#self.guideData)
					coroutine.wait(0.5)
					ContinueLogic()
				end)
			else
				ContinueLogic()
			end
		end

		return
	end

	local currentTaskType = data.CurrentTaskType
	self.IsFirstTime = data.IsFirstTime or false

	if currentTaskType == gTaskManager.CurrentTaskType.Task1 then
		self:SetCurrentTaskData(data)
	end

	if self.curTaskInfo and self.curParentCounterIndex <= #taskInfo.Counters then
		if self.lastParentCounterIndex ~= self.curParentCounterIndex and self.lastParentCounterIndex ~= -1 then
			self:RefreshListAfterUpdate()

			self.lastParentCounterIndex = self.curParentCounterIndex
		end
	else
		gPanelManager:Close(gPanelId.TRAINING_MAIN_PANEL)
	end
end

function M:SetCurrentTaskData(data)
	local currentTaskType = self.currentTaskType

	if data then
		currentTaskType = data.CurrentTaskType
		self.curTaskIsFirst = data.IsFirstTime or false
	end

	if gTaskNodeManager.NowDoingTask[currentTaskType] == nil or gTaskNodeManager.NowDoingTaskLine[currentTaskType] == nil then
		self:NoTask()

		return
	end

	if gTaskManager:GetTaskState(self.curTaskId) == TaskState.Submited then
		self:NoTask()

		return
	end

	local tempTaskId = gTaskNodeManager.NowDoingTask[currentTaskType]
	self.curTaskId = tempTaskId
	self.currentTaskType = currentTaskType
	self.curTaskInfo, self.taskTargetList = gTaskNodeManager:GetTaskCounterInfo(self.curTaskId)

	if self.curParentCounterIndex == 0 then
		self.curParentCounterIndex = 1
	end

	self.isGuide = self.curTaskInfo.IsGuide
	self.isPress = false
	curTime = 0
	local taskInfo = gTaskManager:GetTaskInfo(self.curTaskId)

	for i, v in ipairs(taskInfo.Counters) do
		if self.curTaskInfo.CounterIndex == v.Index + 1 then
			self.curParentCounterIndex = i
		end
	end

	if self.isGuide and not gCS.LuaUtils.IsNonMobileAdaptive() and self.curTaskInfo.MobileShowVx and not self.isDestroy then
		local table = {}
		local config = TrainingConfig.GetConfig(self.curTaskInfo.SkillId)
		table.MobileImage = config.MobileImage
		table.MobileBtnName = config.MobileBtnName
		table.isActive = true
		self.curMobileVXInfo = table

		gMessageManager:SendMessage(gEventConstants.TASK_WORKACTION_MOBILE_VX, table)
	end
end

function M:NoTask()
	self.curTaskId = 0
	self.curTaskInfo = nil
	self.lastParentCounterIndex = 0
	self.curParentCounterIndex = 0
end

function M:OnUpdate()
	if self.isGuide then
		return
	end

	if not self.isPress then
		return
	end

	if not self.guideData or self.curChildIndex < 1 or self.curChildIndex > #self.guideData then
		self.isPress = false

		return
	end

	local currentGuideData = self.guideData[self.curChildIndex]
	self.curTime = self.curTime + Time.deltaTime
	currentGuideData.curPressTime = math.min(1, self.curTime / currentGuideData.PressTime)

	self:GetList():SetSimpleElement(self.curChildIndex - 1, self:OnGetBtnTIndex())

	if currentGuideData.PressTime <= self.curTime then
		self:OnPressSuccess()
	end
end

function M:OnPressSuccess()
	self.isPress = false
	self.curTime = 0

	if self.guideData and self.curChildIndex > 0 and self.curChildIndex <= #self.guideData then
		self.guideData[self.curChildIndex].curPressTime = 0
		self.guideData[self.curChildIndex].mode = self.btnModeEnum.success

		self:GetList():SetSimpleElement(self.curChildIndex - 1, self:OnGetBtnTIndex())
	end
end

function M:OnPressFail(eventId, data)
	if self.isGuide then
		return
	end

	self.isPress = false
	self.curTime = 0

	if not self.guideData or self.curChildIndex < 1 or self.curChildIndex > #self.guideData then
		return
	end

	local failedIndex = self.curChildIndex
	self.guideData[failedIndex].curPressTime = 0
	self.guideData[failedIndex].mode = self.btnModeEnum.fail

	self:GetList():SetSimpleElement(failedIndex - 1, self:OnGetBtnTIndex())
	self:ResetButtonAfterDelay(failedIndex, 0.8)
end

function M:OnPressStart(eventId, data)
	if self.isGuide then
		return
	end

	self.isPress = true
	self.curTime = 0

	if not string.is_null_or_empty(data) then
		local newPressTime = tonumber(data)

		if newPressTime ~= 0 then
			self.guideData[self.curChildIndex].PressTime = newPressTime
		end
	end
end

function M:RegisterWidget()
	self.bindData.btnList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderBtnListItem")
	self.bindData.btnList.onGetTIndex = self:CreateAction("OnGetBtnTIndex")
	self.bindData.guideList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderGuideListItem")
end

function M:OnGetBtnTIndex(index)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return 0
	else
		return 1
	end
end

function M:OnSimpleRenderBtnListItem(btn, index)
	local data = self.guideData[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		store.btnMode = data.mode
		store.lineActive = data.lineActive

		if data.isClose then
			gClientUtils.ResetAnimation(store.btnAnim, self.btnCloseAnimName)
		else
			local animationState = store.btnAnim:get_Item(self.btnCloseAnimName)

			if animationState then
				animationState.time = 0

				store.btnAnim:Sample()
			end
		end

		if data.StateDesId ~= 0 then
			store.stateDes = LTConfig.TextCommonTextConfig.GetConfig(data.StateDesId).Text
		else
			print_error("#NoCreateIssue 战斗训练没有状态描述, 当前计数器", self.curChildIndexList[self.curChildIndex].Index)
		end

		if data.TimingDesId ~= 0 then
			store.btnTips = self.btnTipsEnum.show
			store.timingDes = LTConfig.TextCommonTextConfig.GetConfig(data.TimingDesId).Text
		else
			store.btnTips = self.btnTipsEnum.hide
		end

		if data.PressTime > 0 then
			if self.isPress and self.curChildIndex == index + 1 then
				store.btnType = self.btnTypeEnum.longpresshow
			else
				store.btnType = self.btnTypeEnum.longpress
			end

			store.btnFill = data.curPressTime
		else
			store.btnType = self.btnTypeEnum.click
		end

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			if self.gamepadMode then
				if data.padInputId then
					local config = SGUIGamepadCofig.GetConfig(data.padInputId)
					local pathList = gCS.RebindMgr:GetBindingDisplayStrings(config.ActionMap, config.ActionName)

					if pathList.Count > 0 then
						if pathList.Count == 1 and pathList[0] then
							local buttonName = pathList.Count > 0 and pathList[0] or nil

							if not string.is_null_or_empty(buttonName) then
								local gamepadCfg = self.buttonNameGamepadDic[buttonName]

								if gamepadCfg then
									local activeDevice = gCS.LuaUtils.GetActiveDevice()
									local iconList, iconId = nil

									if activeDevice == SGUI.GameDevice.PlayStation then
										iconList = gamepadCfg.PSButtonIcon
									else
										iconList = gamepadCfg.XBoxButtonIcon
									end

									iconId = iconList and iconList[1]
									store.padIconId1 = iconId
									store.padKeyCnt = self.padKeyCntEnum.single
								end
							end
						elseif pathList.Count > 1 and pathList[0] and pathList[1] then
							local buttonName1 = pathList[0] or nil
							local buttonName2 = pathList[1] or nil

							if not string.is_null_or_empty(buttonName1) and not string.is_null_or_empty(buttonName1) then
								local gamepadCfg1 = self.buttonNameGamepadDic[buttonName1]
								local gamepadCfg2 = self.buttonNameGamepadDic[buttonName2]

								if gamepadCfg1 and gamepadCfg2 then
									local activeDevice = gCS.LuaUtils.GetActiveDevice()
									local iconList1, iconList2, iconId1, iconId2 = nil

									if activeDevice == SGUI.GameDevice.PlayStation then
										iconList1 = gamepadCfg1.PSButtonIcon
										iconList2 = gamepadCfg2.PSButtonIcon
									else
										iconList1 = gamepadCfg1.XBoxButtonIcon
										iconList2 = gamepadCfg2.XBoxButtonIcon
									end

									iconId1 = iconList1 and iconList1[1]
									iconId2 = iconList2 and iconList2[1]
									store.padIconId1 = iconId1
									store.padIconId2 = iconId2
									store.padKeyCnt = self.padKeyCntEnum.double
								end
							end
						end
					end
				end
			elseif data.InputId then
				local config = SGUIPCKeyConfig.GetConfig(data.InputId)
				local pathList = gCS.RebindMgr:GetBindingDisplayStrings(config.ActionMap, config.ActionName)
				local buttonName = pathList.Count > 0 and pathList[0] or nil

				if not string.is_null_or_empty(buttonName) then
					local keyboardConfig = self.buttonNamePCDic[buttonName]

					if keyboardConfig then
						if not string.is_null_or_empty(keyboardConfig.RebindText) then
							store.btnIcon = self.btnIconEnum._false

							store.btnTextComp:ChangeFontAssetByName(config.KeyFont)

							store.btnKeyText = keyboardConfig.RebindText
						else
							store.btnIcon = self.btnIconEnum._true
							store.iconId = keyboardConfig.GuideIcon
						end
					end
				end
			end
		elseif data.mobileId then
			store.iconId = data.mobileId
		end
	end
end

function M:OnSimpleRenderGuideListItem(btn, index)
	local data = self.guideData[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		if not self.guideSuccessAnimTime then
			self.guideSuccessAnimTime = gCS.LuaUtils.GetAnimationTime(store.guideAnim, self.guideSuccessAnimName)
		end

		local taskInfo = gTaskManager:GetTaskInfo(self.curTaskId)

		if taskInfo.Counters[self.curParentCounterIndex].Value < taskInfo.Counters[self.curParentCounterIndex].ConfigValue then
			if taskInfo.Counters[self.curParentCounterIndex].ConfigValue > 1 then
				store.guideFinish = self.guideFinishEnum._false
				store.guideFinishText = "[" .. taskInfo.Counters[self.curParentCounterIndex].Value .. "/" .. taskInfo.Counters[self.curParentCounterIndex].ConfigValue .. "]"
			else
				store.guideFinish = self.guideFinishEnum.hide
				store.guideFinishText = ""
			end
		else
			store.guideFinish = self.guideFinishEnum._true
		end

		if data.SkillId ~= 0 then
			local trainConfig = TrainingConfig.GetConfig(data.SkillId)
			local inputId = trainConfig.InputId
			local stateDesId = trainConfig.StateDesId

			if stateDesId == 0 then
				print_error("#NoCreateIssue 当前战斗训练Guide描述没有填StateDesId, 当前表Id", data.SkillId)

				return
			end

			if not inputId or inputId == 0 then
				store.guideText = LTConfig.TextCommonTextConfig.GetConfig(trainConfig.StateDesId).Text
			elseif gCS.LuaUtils.IsNonMobileAdaptive() then
				if self.gamepadMode then
					local guideIconIdText = string.format("{controllerCellId, %f}", TrainingConfig.GetConfig(data.SkillId).PadInputId)
					local guideText = gGuideGlyph:GetRichTextByGuideStr(guideIconIdText)
					store.guideText = guideText .. LTConfig.TextCommonTextConfig.GetConfig(trainConfig.StateDesId).Text
				else
					local guideIconIdText = string.format("{pcKey, %f}", TrainingConfig.GetConfig(data.SkillId).InputId)
					local guideText = gGuideGlyph:GetRichTextByGuideStr(guideIconIdText)
					store.guideText = guideText .. LTConfig.TextCommonTextConfig.GetConfig(trainConfig.StateDesId).Text
				end
			else
				store.guideText = LTConfig.TextCommonTextConfig.GetConfig(trainConfig.StateDesId).Text
			end
		end
	end
end

function M:GetList()
	if self.isGuide then
		return self.bindData.guideList
	else
		return self.bindData.btnList
	end
end
