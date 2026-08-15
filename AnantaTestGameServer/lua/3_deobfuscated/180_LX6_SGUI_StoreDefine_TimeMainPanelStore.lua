C_TimeMainPanelStore = DefClass("C_TimeMainPanelStore", C_TimeMainPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.TimeMainPanelStore = C_TimeMainPanelStore
local M = C_TimeMainPanelStore
local DragEventListener = SGUI.EventSystems.DragEventListener
local AtmosphereManager = LX6.Manager.AtmosphereManager
local ShowControl = {
	Hide = 0,
	Show = 1
}
local SelectControl = {
	Selected = 1,
	Normal = 0
}
local TimeListTemplate = {
	CustomTime = 1,
	Add = 2,
	Time = 0
}
local PersonControl = {
	Edit = 1,
	Normal = 0
}
local FixedTimeDataList = {
	{
		currentPeriodTextId = 89901062,
		hour = 6,
		minute = 0
	},
	{
		currentPeriodTextId = 89901063,
		hour = 12,
		minute = 0
	},
	{
		currentPeriodTextId = 89901064,
		hour = 17,
		minute = 0
	},
	{
		currentPeriodTextId = 89901065,
		hour = 23,
		minute = 0
	}
}

function M:OnAwake()
	self.bindData.submit.luaClick = self:CreateAction("OnSubmitClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.lockBackButton.luaClick = self:CreateAction("OnExitClick")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_ASK_PERSONAL_TIME_LIST_SUCCESS] = self:CreateAction(self.OnAskPersonalTimeListSuccess),
		[gEventConstants.ON_ADD_PERSONAL_SETTING_TIME_SUCCESS] = self:CreateAction(self.OnAddPersonalTimeSuccess),
		[gEventConstants.ON_DELETE_PERSONAL_SETTING_TIME_SUCCESS] = self:CreateAction(self.OnDeletePersonalTimeSuccess),
		[gEventConstants.ON_ADD_PERSONAL_SETTING_TIME_FAIL] = self:CreateAction(self.OnAddPersonalTimeFail),
		[gEventConstants.ON_SET_CURRENT_TASK_SUCCESS] = self:CreateAction(self.RefreshLockView),
		[gEventConstants.ON_REMOVE_CURRENT_TASK_SUCCESS] = self:CreateAction(self.RefreshLockView),
		[gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE] = self:CreateAction(self.OnTimeHomeAppClose)
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.recordVibrateEnable = SGUI.VibrationMgr.enable
	SGUI.VibrationMgr.enable = true
	self.timeTaskCfg = gTimeAppUtils.GetTimeTask()

	gTimeAppUtils.AskTimePanelInfo()
end

function M:OnAskPersonalTimeListSuccess(_, personalTimeList)
	self.personalTimeList = personalTimeList
	self.personalTimeList = self.personalTimeList or {
		Count = 0,
		Length = 0
	}

	self:RefreshTimeListView()
end

function M:InitView(args)
	M.base.InitView(self, args)
	self:InitBindData()
	self:RefreshView()
end

function M:InitBindData()
	self.bindData.timeInputField.characterLimit = LTConfig.WeatherConfig.PersonalTimeSettingMaxLabel
	self.bindData.personalCtrl = PersonControl.Normal
	self.timeRollStore = gStoreManager:GetStoreGroup(self.bindData.timeRollWidget.Store):GetStoreByWidget(self.bindData.timeRollWidget)
	self.timeListPanelStore = gStoreManager:GetStoreGroup(self.bindData.timeListWidget.Store):GetStoreByWidget(self.bindData.timeListWidget)
	self.timeRollStore.hourList.luaRenderItem = self:CreateAction("OnHourRenderItem")
	self.timeRollStore.hourList.luaBeginDrag = self:CreateActionWithArgs("SetTimeMaskActive", true)
	self.timeRollStore.hourList.luaEndDrag = self:CreateActionWithArgs("SetTimeMaskActive", false)
	self.timeRollStore.minuteList.luaRenderItem = self:CreateAction("OnMinuteRenderItem")
	self.timeRollStore.minuteList.luaBeginDrag = self:CreateActionWithArgs("SetTimeMaskActive", true)
	self.timeRollStore.minuteList.luaEndDrag = self:CreateActionWithArgs("SetTimeMaskActive", false)
	self.timeListPanelStore.list.onGetTIndex = self:CreateAction("OnTimeItemGetTIndex")
	self.timeListPanelStore.list.luaSimpleRenderItem = self:CreateAction("OnTimeRenderItem")
	self.timeRollStore.hourList.luaSelectedChanged = self:CreateAction("OnHourSelectedChanged")
	self.timeRollStore.hourList.luaBeginDrag = self:CreateActionWithArgs("SetTimeMaskActive", true)
	self.timeRollStore.hourList.luaEndDrag = self:CreateActionWithArgs("SetTimeMaskActive", false)
	self.timeRollStore.minuteList.luaSelectedChanged = self:CreateAction("OnMinuteSelectedChanged")
	self.timeRollStore.minuteList.luaBeginDrag = self:CreateActionWithArgs("SetTimeMaskActive", true)
	self.timeRollStore.minuteList.luaEndDrag = self:CreateActionWithArgs("SetTimeMaskActive", false)
	self.timeListPanelStore.list.luaBeginDrag = self:CreateAction("OnTimeListOnBeginDrag")
	self.bindData.timeInputField.onActivateAction = self:CreateAction("OnInputFieldActivate")
	self.bindData.timeInputField.onDeActivateAction = self:CreateAction("OnInputFieldDeActivate")
end

function M:RefreshView()
	self:RefreshHourListView()
	self:RefreshMinuteListView()
	self:RefreshTimeListView()
	self:RefreshLockView()
	self:GoToTargetTime()
end

function M:GoToTargetTime()
	local hour, minute = self:GetCurrentTime()

	self.timeRollStore.hourList:GoToIndex(hour, true)
	self.timeRollStore.minuteList:GoToIndex(minute, true)
	self:ExecutePlaySoundCo()
end

function M:ExecutePlaySoundCo()
	self.isIgnorePlaySound = true
	self.checkPlaySoundCo = coroutine.stop(self.checkPlaySoundCo)
	self.checkPlaySoundCo = coroutine.start(function ()
		coroutine.step()
		coroutine.step()

		self.isIgnorePlaySound = false
	end)
end

function M:GetCurrentTime()
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local minute = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)

	return hour, minute
end

function M:RefreshHourListView()
	local hourViewDataList = {}

	for i = 0, 23 do
		table.insert(hourViewDataList, {
			hour = i
		})
	end

	self.timeRollStore.hourList:SetList(hourViewDataList)
end

function M:RefreshMinuteListView()
	local minuteViewDataList = {}

	for i = 0, 59 do
		table.insert(minuteViewDataList, {
			minute = i
		})
	end

	self.timeRollStore.minuteList:SetList(minuteViewDataList)
end

function M:RefreshTimeListView(lastNavigation)
	self.timeViewDataList = {}

	for _, data in ipairs(FixedTimeDataList) do
		table.insert(self.timeViewDataList, data)

		data.tIndex = TimeListTemplate.Time
	end

	if self.personalTimeList then
		local personalTimeListCount = self.personalTimeList.Count

		if personalTimeListCount > 0 then
			for index, personalTimeInfo in ipairs(self.personalTimeList) do
				local label = personalTimeInfo.Label

				if string.is_null_or_empty(label) then
					label = self.bindData.timeInputField.placeHolder.text
				end

				table.insert(self.timeViewDataList, {
					tIndex = TimeListTemplate.CustomTime,
					hour = personalTimeInfo.Hour,
					minute = personalTimeInfo.Minute,
					label = label,
					index = index
				})
			end
		end

		if personalTimeListCount < LTConfig.WeatherConfig.PersonalTimeSettingMaxCount then
			table.insert(self.timeViewDataList, {
				tIndex = TimeListTemplate.Add
			})
		end
	end

	if lastNavigation then
		self.timeViewDataList[#self.timeViewDataList].autoNavigation = true
	end

	self.timeListPanelStore.list:SetSimpleList(#self.timeViewDataList)
end

function M:OnHourRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("TimeHourTemplateSStore"):GetStoreByWidget(btn)
	store.hour = ("%02d"):format(data.hour)
	local beginTransform = self.timeRollStore.hourBeginTransform
	local endTransform = self.timeRollStore.hourEndTransform

	store.animationCtrl:InitTargetPosition(beginTransform, endTransform)
end

function M:OnHourSelectedChanged()
	self:PlayVibrateEffect()
	self:OnTimeChanged()
end

function M:PlayVibrateEffect()
	if self.isTimeListOnDrag then
		-- Nothing
	end
end

function M:SetTimeMaskActive(isDrag)
	self.isTimeListOnDrag = isDrag
	self.bindData.timeMaskActive = isDrag
end

function M:OnTimeChanged()
	local hour = self.timeRollStore.hourList.selectedIndex
	local minute = self.timeRollStore.minuteList.selectedIndex
	local isInTaskRange = self:CheckTimeInTaskRange(hour, minute)
	self.bindData.taskTipsCtrl = isInTaskRange and ShowControl.Show or ShowControl.Hide

	self.timeListPanelStore.list:RefreshList()
	self:PlaySound()
end

function M:PlaySound()
	if self.isIgnorePlaySound then
		return
	end

	gSoundMgr:PlaySoundByTid(70601249)
end

function M:OnMinuteRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.minute = ("%02d"):format(data.minute)
	local beginTransform = self.timeRollStore.minuteBeginTransform
	local endTransform = self.timeRollStore.minuteEndTransform

	store.animationCtrl:InitTargetPosition(beginTransform, endTransform)
end

function M:OnMinuteSelectedChanged()
	self:PlayVibrateEffect()
	self:OnTimeChanged()
end

function M:OnTimeListOnBeginDrag()
	if self.isTriggerBeginDelete then
		return
	end

	self:HideDeleteView()
end

function M:OnTimeItemGetTIndex(csIndex)
	local luaIndex = csIndex + 1
	local data = self.timeViewDataList[luaIndex]

	return data.tIndex
end

function M:OnTimeRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.timeViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex == TimeListTemplate.Time then
		self:RefreshTimeItemView(store, data)

		store.currentPeriod = LTConfig.TextScriptTextConfig.GetConfig(data.currentPeriodTextId).Text
	elseif data.tIndex == TimeListTemplate.CustomTime then
		self:RefreshPersonalTimeItemView(data, btn)
	elseif data.tIndex == TimeListTemplate.Add then
		function store.addButton.luaClick()
			self.bindData.personalCtrl = PersonControl.Edit
			self.bindData.timeInputField.text = ""

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				self.activeInputFieldCo = coroutine.start(function ()
					coroutine.step()
					self.bindData.timeInputField:ActivateInputField()
				end)
			end
		end
	end

	if data.autoNavigation then
		data.autoNavigation = nil
		SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
	end
end

function M:RefreshPersonalTimeItemView(data, btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local personTimeInfo = self.personalTimeList[data.index]

	if personTimeInfo.isNew then
		personTimeInfo.isNew = nil
		self.currentActiveContentCo = coroutine.stop(self.currentActiveContentCo)
		self.currentActiveContentCo = coroutine.start(function ()
			coroutine.step()

			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
		end)
	end

	self:RefreshTimeItemView(store, data)

	store.currentPeriod = data.label:gsub("\\n", "")
	store.deleteCtrl = ShowControl.Hide
	store.button.interactable = true
	local uButtonDragListener = DragEventListener.Get(store.button.gameObject)
	local uListDragListener = DragEventListener.Get(self.timeListPanelStore.list.gameObject)
	uButtonDragListener.ignoreClickInDraging = true
	store.isDragDelete = nil
	store.startBeginPositionX = nil

	function uButtonDragListener.onBeginDrag(eventData)
		self.isTriggerBeginDelete = true

		uListDragListener:TriggerOnBeginDrag(eventData)

		store.startBeginPositionX = eventData.position.x

		if self.currentDeleteStore and self.currentDeleteStore ~= store then
			self.currentDeleteStore.deleteCtrl = ShowControl.Hide
			self.currentDeleteStore = nil
		end
	end

	function uButtonDragListener.onDrag(eventData)
		uListDragListener:TriggerOnDrag(eventData)

		local startBeginPositionX = store.startBeginPositionX
		store.isDragDelete = startBeginPositionX and LTConfig.WeatherConfig.TimeListDragDeleteThreshold < startBeginPositionX - eventData.position.x
	end

	function uButtonDragListener.onEndDrag(eventData)
		self.isTriggerBeginDelete = nil

		uListDragListener:TriggerOnEndDrag(eventData)

		store.deleteCtrl = store.isDragDelete and ShowControl.Show or ShowControl.Hide
		self.currentDeleteStore = store.isDragDelete and store or nil

		if store.isDragDelete then
			gSoundMgr:PlaySoundByTid(70601340)
		end
	end

	function store.deleteButton.luaClick()
		local csIndex = data.index - 1
		self.currentDeleteStore = nil
		store.deleteCtrl = ShowControl.Hide

		gTimeAppUtils.DeletePersonalTimeSetting(csIndex)
	end
end

function M:RefreshTimeItemView(store, data)
	store.time = ("%02d:%02d"):format(data.hour, data.minute)
	local viewHour = self.timeRollStore.hourList.selectedIndex
	local viewMinute = self.timeRollStore.minuteList.selectedIndex
	store.selectCtrl = viewHour == data.hour and viewMinute == data.minute and SelectControl.Selected or SelectControl.Normal
	store.button.isSelected = viewHour == data.hour and viewMinute == data.minute
	local isInTaskRange = self:CheckTimeInTaskRange(data.hour, data.minute)
	store.taskCtrl = isInTaskRange and ShowControl.Show or ShowControl.Hide

	function store.button.luaClick()
		local hourIndex = data.hour
		local minuteIndex = data.minute

		self.timeRollStore.hourList:GoToIndex(hourIndex, true)
		self.timeRollStore.minuteList:GoToIndex(minuteIndex, true)
		self:HideDeleteView()
		self:RefreshTimeListView()
	end
end

function M:HideDeleteView()
	if self.currentDeleteStore then
		self.currentDeleteStore.deleteCtrl = ShowControl.Hide
		self.currentDeleteStore = nil
	end
end

function M:RefreshLockView()
	local isTaskLocked = gTimeAppUtils.CheckIsTaskForbiddenChangeTime()
	local hour, minute = self:GetCurrentTime()
	self.bindData.currentHour = ("%02d"):format(hour)
	self.bindData.currentMinute = ("%02d"):format(minute)
	self.bindData.uNavigationArea.enabled = not isTaskLocked

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		self.bindData.taskLockCtrl = ShowControl.Show
		self.bindData.lockTips = LTConfig.TextScriptTextConfig.GetConfig(89901103).Text
	else
		self.bindData.taskLockCtrl = isTaskLocked and ShowControl.Show or ShowControl.Hide

		if self.timeTaskCfg then
			local startTime = self.timeTaskCfg.TimeInterval.startTime
			local endTime = self.timeTaskCfg.TimeInterval.endTime
			local taskTipsText = LTConfig.TextScriptTextConfig.GetConfig(89901066).Text
			local timeText = ("%02d:00-%02d:00"):format(startTime, endTime)
			self.timeRollStore.taskTime = taskTipsText:format(timeText)
			local needNotice = not self:CheckTaskInTimeRange(startTime, endTime)
			self.timeRollStore.noticeCtrl = needNotice and ShowControl.Show or ShowControl.Hide
		else
			self.timeRollStore.noticeCtrl = ShowControl.Hide
		end
	end
end

function M:CheckTaskInTimeRange()
	for _, fixedTimeData in ipairs(FixedTimeDataList) do
		if self:CheckTimeInTaskRange(fixedTimeData.hour, fixedTimeData.minute) then
			return true
		end
	end

	return false
end

function M:CheckTimeInTaskRange(hour, minute)
	if self.timeTaskCfg then
		local targetHourTime = hour + minute / 60
		local startHourTime = self.timeTaskCfg.TimeInterval.startTime
		local endHourTime = self.timeTaskCfg.TimeInterval.endTime
		local isCrossDay = endHourTime < startHourTime

		if isCrossDay then
			if startHourTime <= targetHourTime and targetHourTime < gClientConst.DAY_HOUR or targetHourTime >= 0 and targetHourTime < endHourTime then
				return true
			end
		elseif startHourTime <= targetHourTime and targetHourTime < endHourTime then
			return true
		end
	end

	return false
end

function M:OnSubmitClick()
	if self.bindData.personalCtrl == PersonControl.Edit then
		self:StartAddPersonalTime()
	else
		self:StartRestTime()
	end
end

function M:StartAddPersonalTime()
	if self.isAddPersonalTimeIng then
		return
	end

	gClientUtils.EnvSdkReviewWords(self.bindData.timeInputField.text, function ()
		local targetHour = self.timeRollStore.hourList.selectedIndex
		local targetMinute = self.timeRollStore.minuteList.selectedIndex
		self.isAddPersonalTimeIng = true
		local timeInputField = self.bindData.timeInputField
		local label = timeInputField.text

		gTimeAppUtils.AddPersonalTimeSetting({
			Label = label,
			Hour = targetHour,
			Minute = targetMinute
		})
	end, function ()
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SNSCheckFail)
	end, "TimeMainPanel")
end

function M:OnAddPersonalTimeSuccess(_, personalTimeSettingInfo)
	self.isAddPersonalTimeIng = nil
	personalTimeSettingInfo.isNew = true

	table.insert(self.personalTimeList, personalTimeSettingInfo)

	self.personalTimeList.Count = self.personalTimeList.Count + 1
	self.personalTimeList.Length = self.personalTimeList.Length + 1
	self.bindData.personalCtrl = PersonControl.Normal
	self.isAddPersonalTimeIng = nil

	self:RefreshTimeListView()
end

function M:OnAddPersonalTimeFail()
	self.isAddPersonalTimeIng = nil
end

function M:OnDeletePersonalTimeSuccess(_, csIndex)
	local index = csIndex + 1

	table.remove(self.personalTimeList, index)

	self.personalTimeList.Count = math.max(0, self.personalTimeList.Count - 1)
	self.personalTimeList.Length = math.max(0, self.personalTimeList.Length - 1)
	self.currentDeleteStore = nil

	self:RefreshTimeListView(true)
end

function M:StartRestTime()
	local targetHour = self.timeRollStore.hourList.selectedIndex
	local targetMinute = self.timeRollStore.minuteList.selectedIndex
	local targetGameTime = targetHour * gClientConst.SECONDS_PER_HOUR + targetMinute * gClientConst.SECONDS_PER_MINUTE
	local startGameTime = gCS.AtmosphereManager.Instance:GetGameTime()
	local startMinute = math.floor(startGameTime / 60 % 60)
	local startHour = math.floor(startGameTime / gClientConst.SECONDS_PER_HOUR)

	if startHour == targetHour and startMinute == targetMinute then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900695).Text)

		return
	end

	if targetGameTime - startGameTime < 10 * gClientConst.SECONDS_PER_MINUTE and targetGameTime - startGameTime > 0 then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900695).Text)

		return
	end

	gTimeAppUtils.StartRestTime(targetHour, targetMinute)
end

function M:OnExitClick()
	if self.bindData.personalCtrl == PersonControl.Edit then
		self.bindData.personalCtrl = PersonControl.Normal

		return
	end

	M.base.OnExitClick(self)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_TIME_APP_CONTENT_CLOSE)
end

function M:OnTimeHomeAppClose()
	if self.currentDeleteStore and gClientUtils.NotNil(self.currentDeleteStore.roundMask) then
		self.currentDeleteStore.roundMask.enabled = false
	end
end

function M:ClearData()
	self.currentActiveContentCo = coroutine.stop(self.currentActiveContentCo)
	self.activeInputFieldCo = coroutine.stop(self.activeInputFieldCo)
	self.checkPlaySoundCo = coroutine.stop(self.checkPlaySoundCo)
	self.isTimeListOnDrag = nil
	SGUI.VibrationMgr.enable = self.recordVibrateEnable
	self.isTriggerBeginDelete = nil
	self.currentDeleteStore = nil
	self.isAddPersonalTimeIng = nil
	self.personalTimeList = nil
	self.timeTaskCfg = nil
	self.isAskPassingTimeRpc = nil
end
