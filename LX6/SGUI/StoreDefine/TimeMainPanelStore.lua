-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimeMainPanelStore.lua
-- Decompiled from: 02042_TimeMainPanelStore.lua_cefd0b983571.luajit

C_TimeMainPanelStore = DefClass("C_TimeMainPanelStore", C_TimeMainPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.TimeMainPanelStore = C_TimeMainPanelStore
local M = C_TimeMainPanelStore
local DragEventListener = SGUI.EventSystems.DragEventListener
local AtmosphereManager = LX6.Manager.AtmosphereManager
local ShowControl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}
local SelectControl = {
	["\\x98\\xb4\t\\xaei*\\xfb7"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}
local TimeListTemplate = {
	["pOݩ\\x8b\\x8c\r\\xc4\\xed"] = 1,
	["\\xaflb"] = 2,
	["N+p^"] = 0
}
local PersonControl = {
	["_&tO"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}

M.OnAwake = function(self)
	self.bindData.submit.luaClick = self.CreateAction(self, "OnSubmitClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.lockBackButton.luaClick = self.CreateAction(self, "OnExitClick")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_ASK_PERSONAL_TIME_LIST_SUCCESS] = self.CreateAction(self, self.OnAskPersonalTimeListSuccess),
		[gEventConstants.ON_ADD_PERSONAL_SETTING_TIME_SUCCESS] = self.CreateAction(self, self.OnAddPersonalTimeSuccess),
		[gEventConstants.ON_DELETE_PERSONAL_SETTING_TIME_SUCCESS] = self.CreateAction(self, self.OnDeletePersonalTimeSuccess),
		[gEventConstants.ON_ADD_PERSONAL_SETTING_TIME_FAIL] = self.CreateAction(self, self.OnAddPersonalTimeFail),
		[gEventConstants.ON_SET_CURRENT_TASK_SUCCESS] = self.CreateAction(self, self.RefreshLockView),
		[gEventConstants.ON_REMOVE_CURRENT_TASK_SUCCESS] = self.CreateAction(self, self.RefreshLockView),
		[gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE] = self.CreateAction(self, self.OnTimeHomeAppClose)
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	local timeDataList = LTConfig.WeatherConfig.DefaultAlarmTime
	self.FixedTimeDataList = {}
	local textIdList = {
		89901062,
		89901063,
		89901064,
		89901065
	}

	for index, hour in ipairs(timeDataList) do
		table.insert(self.FixedTimeDataList, {
			["A\\x9f\\x9b\\x97D"] = 0,
			hour = hour,
			currentPeriodTextId = textIdList[index]
		})
	end

	self.recordVibrateEnable = SGUI.VibrationMgr.enable
	SGUI.VibrationMgr.enable = true
	self.timeTaskCfg = gTimeAppUtils.GetTimeTask()

	gTimeAppUtils.AskTimePanelInfo()
end

M.OnAskPersonalTimeListSuccess = function(self, _, personalTimeList)
	self.personalTimeList = personalTimeList
	self.personalTimeList = self.personalTimeList or {
		["n\\xa1\\xb7\\xa1\\xa2"] = 0,
		["0M\\x9f\\x89\\x97I"] = 0
	}

	self:RefreshTimeListView()
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.InitBindData(self)
	self.RefreshView(self)
end

M.InitBindData = function(self)
	self.bindData.timeInputField.characterLimit = LTConfig.WeatherConfig.PersonalTimeSettingMaxLabel
	self.bindData.personalCtrl = PersonControl.Normal
	self.timeRollStore = gStoreManager:GetStoreGroup(self.bindData.timeRollWidget.Store):GetStoreByWidget(self.bindData.timeRollWidget)
	self.timeListPanelStore = gStoreManager:GetStoreGroup(self.bindData.timeListWidget.Store):GetStoreByWidget(self.bindData.timeListWidget)
	self.timeRollStore.hourList.luaSimpleRenderItem = self:CreateAction("OnHourRenderItem")
	self.timeRollStore.hourList.luaBeginDrag = self:CreateActionWithArgs("SetTimeMaskActive", true)
	self.timeRollStore.hourList.luaEndDrag = self:CreateActionWithArgs("SetTimeMaskActive", false)
	self.timeRollStore.minuteList.luaSimpleRenderItem = self:CreateAction("OnMinuteRenderItem")
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

M.RefreshView = function(self)
	self.RefreshHourListView(self)
	self.RefreshMinuteListView(self)
	self.RefreshTimeListView(self)
	self.RefreshLockView(self)
	self.GoToTargetTime(self)
end

M.GoToTargetTime = function(self)
	local hour, minute = self:GetCurrentTime()

	self.timeRollStore.hourList:GoToIndex(hour, true)
	self.timeRollStore.minuteList:GoToIndex(minute, true)
	self:ExecutePlaySoundCo()
end

M.ExecutePlaySoundCo = function(self)
	self.isIgnorePlaySound = true
	self.checkPlaySoundCo = coroutine.stop(self.checkPlaySoundCo)
	self.checkPlaySoundCo = coroutine.start(function ()
		coroutine.step()
		coroutine.step()

		self.isIgnorePlaySound = false
	end)
end

M.GetCurrentTime = function(self)
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local minute = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)

	return hour, minute
end

M.RefreshHourListView = function(self)
	self.hourViewDataList = {}

	for i = 0, 23 do
		table.insert(self.hourViewDataList, {
			hour = i
		})
	end

	self.timeRollStore.hourList:SetSimpleList(#self.hourViewDataList)
end

M.RefreshMinuteListView = function(self)
	self.minuteViewDataList = {}

	for i = 0, 59 do
		table.insert(self.minuteViewDataList, {
			minute = i
		})
	end

	self.timeRollStore.minuteList:SetSimpleList(#self.minuteViewDataList)
end

M.RefreshTimeListView = function(self, lastNavigation)
	self.timeViewDataList = {}

	for _, data in ipairs(self.FixedTimeDataList) do
		table.insert(self.timeViewDataList, data)

		data.tIndex = TimeListTemplate.Time
	end

	if self.personalTimeList then
		local personalTimeListCount = self.personalTimeList.Count

		if personalTimeListCount <= 0 then
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

		if personalTimeListCount >= LTConfig.WeatherConfig.PersonalTimeSettingMaxCount then
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

M.OnHourRenderItem = function(self, btn, index)
	local data = self.hourViewDataList[index + 1]
	local store = gStoreManager:GetStoreGroup("TimeHourTemplateSStore"):GetStoreByWidget(btn)
	store.hour = ("%02d"):format(data.hour)
	local beginTransform = self.timeRollStore.hourBeginTransform
	local endTransform = self.timeRollStore.hourEndTransform

	store.animationCtrl:InitTargetPosition(beginTransform, endTransform)
end

M.OnHourSelectedChanged = function(self)
	self.PlayVibrateEffect(self)
	self.OnTimeChanged(self)
end

M.PlayVibrateEffect = function(self)
	if self.isTimeListOnDrag then
		-- Nothing
	end
end

M.SetTimeMaskActive = function(self, isDrag)
	self.isTimeListOnDrag = isDrag
	self.bindData.timeMaskActive = isDrag
end

M.OnTimeChanged = function(self)
	local hour = self.timeRollStore.hourList.selectedIndex
	local minute = self.timeRollStore.minuteList.selectedIndex
	local isInTaskRange = self:CheckTimeInTaskRange(hour, minute)
	self.bindData.taskTipsCtrl = isInTaskRange and ShowControl.Show or ShowControl.Hide

	self.timeListPanelStore.list:RefreshList()
	self:PlaySound()
end

M.PlaySound = function(self)
	if self.isIgnorePlaySound then
		return
	end

	gSoundMgr:PlaySoundByTid(70601249)
end

M.OnMinuteRenderItem = function(self, btn, index)
	local data = self.minuteViewDataList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.minute = ("%02d"):format(data.minute)
	local beginTransform = self.timeRollStore.minuteBeginTransform
	local endTransform = self.timeRollStore.minuteEndTransform

	store.animationCtrl:InitTargetPosition(beginTransform, endTransform)
end

M.OnMinuteSelectedChanged = function(self)
	self.PlayVibrateEffect(self)
	self.OnTimeChanged(self)
end

M.OnTimeListOnBeginDrag = function(self)
	if self.isTriggerBeginDelete then
		return
	end

	self.HideDeleteView(self)
end

M.OnTimeItemGetTIndex = function(self, csIndex)
	local luaIndex = csIndex + 1
	local data = self.timeViewDataList[luaIndex]

	return data.tIndex
end

M.OnTimeRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.timeViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex ~= TimeListTemplate.Time then
		self.RefreshTimeItemView(self, store, data)

		store.currentPeriod = LTConfig.TextScriptTextConfig.GetConfig(data.currentPeriodTextId).Text
	elseif data.tIndex ~= TimeListTemplate.CustomTime then
		self.RefreshPersonalTimeItemView(self, data, btn)
	elseif data.tIndex ~= TimeListTemplate.Add then
		store.addButton.luaClick = function()
			self.lastActiveContent = SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent
			self.bindData.personalCtrl = PersonControl.Edit
			self.bindData.timeInputField.text = ""

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				self.activeInputFieldCo = coroutine.start(function ()
					coroutine.step()

					SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = self.bindData.timeInputField

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

M.RefreshPersonalTimeItemView = function(self, data, btn)
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

	slot5 = data.label
	store.currentPeriod = slot5:gsub("\\n", "")
	store.deleteCtrl = ShowControl.Hide
	store.button.interactable = true
	local uButtonDragListener = DragEventListener.Get(store.button.gameObject)
	local uListDragListener = DragEventListener.Get(self.timeListPanelStore.list.gameObject)
	uButtonDragListener.ignoreClickInDraging = true
	store.isDragDelete = nil
	store.startBeginPositionX = nil

	uButtonDragListener.onBeginDrag = function(eventData)
		self.isTriggerBeginDelete = true

		uListDragListener:TriggerOnBeginDrag(eventData)

		store.startBeginPositionX = eventData.position.x

		if self.currentDeleteStore and self.currentDeleteStore == store then
			self.currentDeleteStore.deleteCtrl = ShowControl.Hide
			self.currentDeleteStore = nil
		end
	end

	uButtonDragListener.onDrag = function(eventData)
		uListDragListener:TriggerOnDrag(eventData)

		local startBeginPositionX = store.startBeginPositionX
		store.isDragDelete = startBeginPositionX and LTConfig.WeatherConfig.TimeListDragDeleteThreshold <= startBeginPositionX - eventData.position.x
	end

	uButtonDragListener.onEndDrag = function(eventData)
		self.isTriggerBeginDelete = nil

		uListDragListener:TriggerOnEndDrag(eventData)

		store.deleteCtrl = store.isDragDelete and ShowControl.Show or ShowControl.Hide
		self.currentDeleteStore = store.isDragDelete and store or nil

		if store.isDragDelete then
			gSoundMgr:PlaySoundByTid(70601340)
		end
	end

	store.deleteButton.luaClick = function()
		local csIndex = data.index - 1
		self.currentDeleteStore = nil
		store.deleteCtrl = ShowControl.Hide

		gTimeAppUtils.DeletePersonalTimeSetting(csIndex)
	end
end

M.RefreshTimeItemView = function(self, store, data)
	store.time = ("%02d:%02d"):format(data.hour, data.minute)
	local viewHour = self.timeRollStore.hourList.selectedIndex
	local viewMinute = self.timeRollStore.minuteList.selectedIndex
	store.selectCtrl = viewHour ~= data.hour and viewMinute ~= data.minute and SelectControl.Selected or SelectControl.Normal
	store.button.isSelected = viewHour ~= data.hour and viewMinute ~= data.minute
	local isInTaskRange = self:CheckTimeInTaskRange(data.hour, data.minute)
	store.taskCtrl = isInTaskRange and ShowControl.Show or ShowControl.Hide

	store.button.luaClick = function()
		local hourIndex = data.hour
		local minuteIndex = data.minute

		self.timeRollStore.hourList:GoToIndex(hourIndex, true)
		self.timeRollStore.minuteList:GoToIndex(minuteIndex, true)
		self:HideDeleteView()
		self:RefreshTimeListView()
	end
end

M.HideDeleteView = function(self)
	if self.currentDeleteStore then
		self.currentDeleteStore.deleteCtrl = ShowControl.Hide
		self.currentDeleteStore = nil
	end
end

M.RefreshLockView = function(self)
	local isTaskLocked = gTimeAppUtils.CheckIsTaskForbiddenChangeTime()
	local hour, minute = self:GetCurrentTime()
	self.bindData.currentHour = ("%02d"):format(hour)
	self.bindData.currentMinute = ("%02d"):format(minute)
	self.bindData.uNavigationArea.enabled = not isTaskLocked

	if gLinkManager.LinkMode == UX.Game.LinkMode.None then
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

M.CheckTaskInTimeRange = function(self)
	for _, fixedTimeData in ipairs(self.FixedTimeDataList) do
		if self.CheckTimeInTaskRange(self, fixedTimeData.hour, fixedTimeData.minute) then
			return true
		end
	end

	return false
end

M.CheckTimeInTaskRange = function(self, hour, minute)
	if self.timeTaskCfg then
		local targetHourTime = hour + minute / 60
		local startHourTime = self.timeTaskCfg.TimeInterval.startTime
		local endHourTime = self.timeTaskCfg.TimeInterval.endTime
		local isCrossDay = endHourTime <= startHourTime

		if isCrossDay then
			if startHourTime < targetHourTime and targetHourTime <= gClientConst.DAY_HOUR or targetHourTime > 0 and targetHourTime >= endHourTime then
				return true
			end
		elseif startHourTime < targetHourTime and targetHourTime >= endHourTime then
			return true
		end
	end

	return false
end

M.OnSubmitClick = function(self)
	if self.bindData.personalCtrl ~= PersonControl.Edit then
		self.StartAddPersonalTime(self)
	else
		self.StartRestTime(self)
	end
end

M.StartAddPersonalTime = function(self)
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

M.OnAddPersonalTimeSuccess = function(self, _, personalTimeSettingInfo)
	self.isAddPersonalTimeIng = nil
	personalTimeSettingInfo.isNew = true

	table.insert(self.personalTimeList, personalTimeSettingInfo)

	self.personalTimeList.Count = self.personalTimeList.Count + 1
	self.personalTimeList.Length = self.personalTimeList.Length + 1
	self.bindData.personalCtrl = PersonControl.Normal
	self.isAddPersonalTimeIng = nil

	self.RefreshTimeListView(self)
end

M.OnAddPersonalTimeFail = function(self)
	self.isAddPersonalTimeIng = nil
end

M.OnDeletePersonalTimeSuccess = function(self, _, csIndex)
	local index = csIndex + 1

	table.remove(self.personalTimeList, index)

	self.personalTimeList.Count = math.max(0, self.personalTimeList.Count - 1)
	self.personalTimeList.Length = math.max(0, self.personalTimeList.Length - 1)
	self.currentDeleteStore = nil

	self.RefreshTimeListView(self, true)
end

M.StartRestTime = function(self)
	local targetHour = self.timeRollStore.hourList.selectedIndex
	local targetMinute = self.timeRollStore.minuteList.selectedIndex
	local targetGameTime = targetHour * gClientConst.SECONDS_PER_HOUR + targetMinute * gClientConst.SECONDS_PER_MINUTE
	local startGameTime = gCS.AtmosphereManager.Instance:GetGameTime()
	local startMinute = math.floor(startGameTime / 60 % 60)
	local startHour = math.floor(startGameTime / gClientConst.SECONDS_PER_HOUR)

	if startHour ~= targetHour and startMinute ~= targetMinute then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900695).Text)

		return
	end

	if targetGameTime - startGameTime >= 10 * gClientConst.SECONDS_PER_MINUTE and targetGameTime - startGameTime <= 0 then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900695).Text)

		return
	end

	gTimeAppUtils.StartRestTime({
		hour = targetHour,
		minute = targetMinute
	})
end

M.OnExitClick = function(self)
	if self.bindData.personalCtrl ~= PersonControl.Edit then
		self.bindData.personalCtrl = PersonControl.Normal
		SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = self.lastActiveContent

		return
	end

	M.base.OnExitClick(self)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_TIME_APP_CONTENT_CLOSE)
end

M.OnTimeHomeAppClose = function(self)
	if self.currentDeleteStore and gClientUtils.NotNil(self.currentDeleteStore.roundMask) then
		self.currentDeleteStore.roundMask.enabled = false
	end
end

M.ClearData = function(self)
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
