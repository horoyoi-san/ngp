C_DriverJobPanelStore = DefClass("C_DriverJobPanelStore", C_DriverJobPanelStore, C_StoreGroup)
GroupName2Class.DriverJobPanelStore = C_DriverJobPanelStore
local M = C_DriverJobPanelStore
local UberSimConfig = LTConfig.UberSimConfig
local SguiImageConfig = LTConfig.SguiImageConfig
local RandomGoodsConfig = LTConfig.UberSimRandomGoodsConfig
local TaskConfig = LTConfig.TaskConfig
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local PanelState = {
	call = 2,
	branch = 0,
	wait = 1,
	normal = 3
}
local CargoState = {
	finish = 1,
	doing = 0
}
local StoreState = {
	branch = 1,
	normal = 0
}
local BranchPadKey = {
	19,
	18,
	20,
	21
}
local TaskItemMode = {
	pc = 0,
	phone = 2,
	pad = 1
}
local AutoState = {
	ON = 1,
	OFF = 0
}
local AutoTipText = {
	ON = 591,
	OFF = 590
}
local ButtonTextState = {
	replace = 1,
	receiving = 0
}

function M:ctor()
	self.orderList = {}
	self.orderDataList = {}
	self.curIsTrueBranch = false
	self.checkCount = 0
	self.branchList = {}
	self.panelState = PanelState.wait
	self.mobileOpenAnim = "vx_S_DIDITask_List_open"
	self.openAnim = "vx_S_DIDITask_PC_List_open"
	self.closeAnim = "vx_S_DIDITask_PC_List_close"
end

function M:OnAwake()
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction(self.ChangeBtnState),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction(self.ChangeBtnState),
		[gEventConstants.JOB_ORDER_LIST_REFRESH] = self:CreateAction(self.JobOrderListRefresh),
		[gEventConstants.JOB_ORDER_LIST_TIME] = self:CreateAction(self.JobOrderTimeRefresh),
		[gEventConstants.ON_GOOD_INTEGRITY_CHANGE] = self:CreateAction(self.ChangeIntegrity),
		[gEventConstants.DELIVERY_PANEL_STATE_CHANGE] = self:CreateAction(self.ChangePanelState),
		[gEventConstants.HIGH_VALUE_ORDER] = self:CreateAction(self.ShowHighValueOrder),
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction(self.PanelStateToWait),
		[gEventConstants.DELIVERY_STATE_EVENT] = self:CreateAction(self.PanelHudTitleEvent),
		[gEventConstants.DELIVERY_GUIDE_HUD] = self:CreateAction(self.RegisterTaskEvent),
		[gEventConstants.DELIVERY_AUTO_TAKE_ORDER_CHANGED] = self:CreateAction(self.RefreshAutoTakeOrderState),
		[gEventConstants.TASK_STATE_CHANGED] = self:CreateAction(self.CheckTeachTaskState)
	}
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.JobOrderListRender)
	self.bindData.list.onGetTIndex = self:CreateAction(self.GetJobOrderIndex)
	self.bindData.taskList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTaskItem)
	self.bindData.taskList.luaSimpleClick = self:CreateAction(self.OnBranchItemClick)
	self.bindData.acceptBtn.luaClick = self:CreateAction(self.AcceptOnClick)
	self.bindData.cancelBtn.luaClick = self:CreateAction(self.CancelOnClick)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.logBtn.luaClick = self:CreateAction(self.OpenApp)
		self.bindData.appOpenBtn.luaClick = self:CreateAction(self.OpenApp)
		self.bindData.logBtn.luaLongPress = self:CreateAction(self.OpenApp)
		self.bindData.appOpenBtn.luaLongPress = self:CreateAction(self.OpenApp)
		self.bindData.autoBtn.luaLongPress = self:CreateAction(self.LongPressAutoTask)
		self.bindData.padAutoBtn.luaLongPress = self:CreateAction(self.LongPressAutoTask)
		self.bindData.quitTaskBtn.luaClick = self:CreateAction(self.ClickQuitTask)
		self.bindData.padQuitTaskBtn.luaLongPress = self:CreateAction(self.ClickQuitTask)
	else
		self.bindData.mobileExitBtn.luaClick = self:CreateAction(self.AskAbandonCurrentTask)
		self.bindData.mobileOpenBtn.luaClick = self:CreateAction(self.OpenApp)
		self.bindData.mobileAutoBtn.luaClick = self:CreateAction(self.LongPressAutoTask)
		self.bindData.mobileQuitBtn.luaClick = self:CreateAction(self.ClickQuitTask)
	end

	self:RegisterMessageEvents(self.msgEvents)
	self:InitConfig()
end

function M:ObsoleteTruckJobOrder(callBack)
	local orderId = gDeliveryTaskManager:GetCurOrderId()

	if orderId then
		gDeliveryTaskManager:SetOrderObsolete(orderId)

		gClientToGameDelegate:AskObsoleteTruckJobOrder(orderId).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			if callBack then
				callBack()
			end
		end
	else
		callBack()
	end
end

function M:AcceptOnClick()
	if self.orderUniqueId then
		self:ObsoleteTruckJobOrder(function ()
			gClientToGameDelegate:AskAcceptTruckJobOrder(self.orderUniqueId).Callback = function (errorId, callbackTruckJobOrderWrap, npcInstanceId)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end
			end

			self:StopTaskTimeFill()
		end)
	end
end

function M:CancelOnClick()
	self:StopTaskTimeFill()
end

function M:OnShow(data)
	if not data or not data.isOnlyOpenPanel then
		self.needRefresh = true
		self.curBranch = 1

		self:SetPanelState(PanelState.wait)
		gDeliveryTaskManager:ChangeDeliveryPanelTitle(gDeliveryTaskManager.TitleType.WaitOrderText)
	end

	self:CheckAppHomePanelState()
	self:CheckTeachTaskState()
	self:SetAutoState()

	if data and data.isGuide then
		self:RegisterTaskEvent()
		self:RefreshOrderListPanel()
	end
end

function M:SetAutoState()
	gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gDeliveryTaskManager:SetIsAuto(clientTruckOrderView.AutoAccept)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.autoBtn:SetPCKeyInfoTipNameId(clientTruckOrderView.AutoAccept and AutoTipText.ON or AutoTipText.OFF)

			self.bindData.padAutoState = clientTruckOrderView.AutoAccept and AutoState.ON or AutoState.OFF
		else
			self.bindData.autoState = clientTruckOrderView.AutoAccept and AutoState.ON or AutoState.OFF
		end
	end
end

function M:InitConfig()
	self.InitAcceptCount = UberSimConfig.InitAcceptCount
	self.AddAcceptBadgeList = UberSimConfig.AddAcceptBadgeList
	self.taskTime = UberSimConfig.HighPriceTipsTime
	self.deliveryShortCutDefault = UberSimConfig.DeliveryShortCut[1]
	self.deliveryShortCutUp = UberSimConfig.DeliveryShortCut[2]
	self.startTaskTime = gLogicTime.time
	self.startTaskUpdate = false
	self.pressTime = 1
end

function M:PanelHudTitleEvent(_, data)
	self.hudTitle = data.title

	self:RefreshPanelHudTitle()
end

function M:RefreshPanelHudTitle()
	if self.needRefresh and not self.isGuide then
		self.bindData.hudTitle = self.hudTitle
	end
end

function M:CheckIsPhoneOpen()
	return gPanelManager:IsPanelShowing(gPanelId.S_PHONE_APP_HOME_PANEL) or gPanelManager:IsPanelShowing(gPanelId.S_HALF_PHONE_APP_HOME_PANEL)
end

function M:CheckAppHomePanelState()
	if self:CheckIsPhoneOpen() then
		self:ChangeBtnState(gEventConstants.ON_PHONE_APP_HOME_SHOW)
	else
		self:ChangeBtnState(gEventConstants.ON_PHONE_APP_HOME_HIDE)
	end
end

function M:ShowHighValueOrder(_, order)
	local orderInfo = order.OrderInfo
	self.highCargoId = orderInfo.CargoId
	self.bindData.btnTextState = gDeliveryTaskManager:IsHaveOrder() and ButtonTextState.replace or ButtonTextState.receiving

	self:SetHighValueText()

	self.bindData.money = orderInfo.DropMoney
	self.orderUniqueId = order.UniqueId

	self:StartTaskTimeFill()
end

function M:SetHighValueText()
	self.bindData.hudTitle = gDeliveryTaskManager.HighOrderText

	if self.highCargoId then
		local config = RandomGoodsConfig.GetConfig(self.highCargoId)

		if config then
			self.bindData.name = config.information
		end
	end
end

function M:ChangeBtnState(eventId)
	local isPadModel = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()

	if isPadModel and not self.isGuide then
		if eventId == gEventConstants.ON_PHONE_APP_HOME_SHOW then
			self.bindData.padOpenAppBtn:SetActive(false)
			self.bindData.padAutoBtn:SetActive(false)
		else
			self.bindData.padOpenAppBtn:SetActive(true)
			self.bindData.padAutoBtn:SetActive(self:CheckAutoBtnCanShow(true))
		end
	end
end

function M:OpenApp()
	gMainPhoneFunctionAction.OpenUberSim()
end

function M:OpenAccount()
	gDeliveryTaskManager.OpenDeliveryAccountPanel()
end

function M:OnUpdate()
	if self.startPress then
		local nowTime = gLogicTime.time
		self.bindData.exitFill = (nowTime - self.startPressTime) / self.pressTime

		if self.pressTime < nowTime - self.startPressTime then
			self:OnPressBtnEndHelper()
			self:AskAbandonCurrentTask()
		end
	end

	if self.startTaskUpdate then
		local nowTime = gLogicTime.time
		self.bindData.timeFill = 1 - (nowTime - self.startTaskTime) / self.taskTime

		if self.taskTime < nowTime - self.startTaskTime then
			self:StopTaskTimeFill()
		end
	end
end

function M:StopTaskTimeFill()
	self.startTaskUpdate = false
	self.needRefresh = true

	self:RefreshPanelState()
	self:RefreshPanelHudTitle()
end

function M:StartTaskTimeFill()
	self.startTaskTime = gLogicTime.time
	self.startTaskUpdate = true
	self.bindData.panelState = PanelState.call
	self.needRefresh = false
end

function M:AskAbandonCurrentTask()
	gDeliveryTaskManager:AskAbandonCurrentTask()
end

function M:OnPressBtnBegin()
	if self.bindData.exitBtnState == 4 then
		return
	end

	self.bindData.longPress = 1
	self.startPress = true
	self.startPressTime = gLogicTime.time
end

function M:OnPressBtnEnd()
	self:OnPressBtnEndHelper()
end

function M:LongPressAutoTask()
	gDeliveryTaskManager:AskAutoAcceptTruckJobOrder(not gDeliveryTaskManager:CheckIsAuto())
end

function M:ClickQuitTask()
	self:ObsoleteTruckJobOrder(function ()
		gDeliveryTaskManager:RemoveCurTruckOrder()
	end)
end

function M:OnPressBtnEndHelper()
	self.startPress = false
	self.bindData.longPress = 0
end

function M:JobOrderListRefresh()
	self:StopTaskTimeFill()
	self:RefreshOrderListPanel()
end

function M:GetJobOrderIndex()
	return gDeliveryTaskManager.tIndex
end

function M:JobOrderListRender(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		local data = self.orderDataList[index + 1]

		if data then
			store.timeState = data.orderTime <= 0 and 1 or 0
			store.orderName = data.firstCargo.orderCfg.information

			if gDeliveryTaskManager.tIndex == gDeliveryTaskManager.CargoType.normal then
				local imageCfg = SguiImageConfig.GetConfig(data.firstCargo.imageId)

				if imageCfg then
					store.iconUrl = imageCfg.ImgPath
				end
			end

			store.branchItem.anim:Play()

			if data.firstCargo.isUpdate then
				self:UpdateIntegrity(store, data, gDeliveryTaskManager.tIndex)
			else
				store.cargoState = 0
			end

			self.orderList[data.AcceptedEventId] = store
		end
	end
end

function M:UpdateIntegrity(store, orderInfo, type)
	if not self.curIsTrueBranch then
		if type == gDeliveryTaskManager.CargoType.normal then
			local state = gDeliveryTaskManager:GetCargoState(orderInfo.firstCargo, true)

			if state ~= gDeliveryTaskManager.CargoState.Finish then
				store.cargoState = state
			end
		elseif type == gDeliveryTaskManager.CargoType.special then
			self:AddMoneyEffect(store, orderInfo.firstCargo.integrity)
		end
	else
		for index, v in pairs(orderInfo.cargoInfoList) do
			local cargoStore = store[index]

			self:ChangeCargoIntegrity(cargoStore, v)
		end
	end
end

function M:AddMoneyEffect(store, targetNum)
	local scrollNum = store.ScrollGroup

	scrollNum:PlayToTarget(targetNum)
end

function M:ChangeCargoIntegrity(cargoStore, cargoInfo)
	local state = gDeliveryTaskManager:GetCargoState(cargoInfo, true)

	if state ~= gDeliveryTaskManager.CargoState.Finish then
		cargoStore.cargoState = state
	else
		cargoStore.finishState = 1
	end
end

function M:JobOrderTimeRefresh(_, data)
	local eventId = data.eventId
	local time = data.time
	local store = self.orderList[eventId]

	if store and data.isUpdateTime then
		store.time = time
		store.colorState = data.colorState
	end
end

function M:ChangeIntegrity(_, data)
	local eventId = data.eventId
	local store = self.orderList[eventId]

	if store then
		self:UpdateIntegrity(store, data.orderInfo, data.type)
	end
end

function M:OnEnable()
	self:LanguageChange()
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	return
end

function M:LanguageChange()
	self:InitConfig()

	if self.bindData.panelState == PanelState.branch or self.bindData.panelState == PanelState.normal then
		self:RefreshOrderListPanel()
	end

	if self.bindData.panelState == PanelState.call then
		self:SetHighValueText()
	end

	gDeliveryTaskManager:RefreshStoreText()
	self:RefreshPanelState()
end

function M:OnGroupDisable()
	return
end

function M:ChangePanelState(_, data)
	if not data then
		self.curBranch = 1

		self:UnRegisterTaskEvent()

		if self.bindData.panelState == PanelState.normal then
			self.bindData.list.anim:Play(self.closeAnim)

			local closeTime = self.bindData.list.anim:GetClip(self.closeAnim).length
			self.closeTimer = gLuaTimeMgrUtils.Delay(function ()
				self.closeTimer = nil

				self:SetPanelState(PanelState.wait)
			end, closeTime)
		else
			self:SetPanelState(PanelState.wait)
		end
	end
end

function M:PanelStateToWait()
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Delivery)
	local levelUpControlValue = gDeliveryTaskManager:CheckCanPromote(targetJobId)
	self.bindData.shotCutName = levelUpControlValue and self.deliveryShortCutUp or self.deliveryShortCutDefault

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.logBtn.luaClick = levelUpControlValue and self:CreateAction(self.OpenAccount) or self:CreateAction(self.OpenApp)
		self.bindData.logBtn.luaLongPress = levelUpControlValue and self:CreateAction(self.OpenAccount) or self:CreateAction(self.OpenApp)
		self.bindData.padAppState = levelUpControlValue and 1 or 0
	else
		self.bindData.mobileOpenBtn.luaClick = levelUpControlValue and self:CreateAction(self.OpenAccount) or self:CreateAction(self.OpenApp)
	end
end

function M:ShotCutToDefault()
	self.bindData.shotCutName = self.deliveryShortCutDefault

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.logBtn.luaClick = self:CreateAction(self.OpenApp)
		self.bindData.logBtn.luaLongPress = self:CreateAction(self.OpenApp)
		self.bindData.padAppState = 0
	else
		self.bindData.mobileOpenBtn.luaClick = self:CreateAction(self.OpenApp)
	end
end

function M:RefreshPanelState()
	if self.needRefresh then
		self.bindData.panelState = self.panelState

		if self.panelState == PanelState.wait then
			self:PanelStateToWait()
		else
			self:ShotCutToDefault()
		end
	end
end

function M:SetPanelState(state)
	self.panelState = state

	self:CheckCloseTimer()
	self:RefreshPanelState()
end

function M:CheckCloseTimer()
	if self.closeTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.closeTimer)

		self.closeTimer = nil
	end
end

function M:OnClose()
	self:CheckCloseTimer()
	self:UnRegisterTaskEvent()
end

function M:OnLanguageChange(lang)
	self:LanguageChange()
end

function M:OnActiveDeviceChange(device)
	self:CheckAppHomePanelState()

	if self.panelState == PanelState.normal or self.panelState == PanelState.branch then
		self:RefreshOrderListPanel()
	end

	self:RefreshPanelState()

	if self.isGuide then
		self:SetBtnGuideState(true)
	end
end

function M:RefreshBranchList()
	self.branchList = {}
	local order = gDeliveryTaskManager:GetOrderByEventId(gDeliveryTaskManager.curEvent)

	if not order or #order.cargoInfoList <= 1 then
		self.curIsTrueBranch = false

		return
	end

	local branchLength = #order.cargoInfoList + 1
	local workActionList = {}

	for i = 1, branchLength do
		local info = {
			index = i
		}
		info.pcKeyId = info.index + 14
		info.padKeyId = BranchPadKey[info.index]
		info.taskState = i == self.curBranch and 1 or 0
		info.isLast = i == branchLength

		table.insert(workActionList, info)
	end

	self.branchList = workActionList
	self.curIsTrueBranch = true
end

function M:RefreshOrderListPanel()
	self.orderList = {}

	self:RefreshBranchList()

	if self.curIsTrueBranch then
		self:SetPanelState(PanelState.branch)
		self:SetNormalList()
	else
		self:SetPanelState(PanelState.normal)

		self.orderDataList = table.clone(gDeliveryTaskManager.orderList)

		self.bindData.list:SetSimpleList(#self.orderDataList)
		self.bindData.list.anim:Play(self:GetOpenAnimName())
	end
end

function M:GetOpenAnimName()
	return gCS.LuaUtils.IsNonMobileAdaptive() and self.openAnim or self.mobileOpenAnim
end

function M:IsInPc()
	return InputActionBind.activeGameDevice == GameDevice.KeyboardMouse
end

function M:IsInPad()
	return InputActionBind.activeGameDevice == GameDevice.Xbox or InputActionBind.activeGameDevice == GameDevice.PlayStation
end

function M:SetNormalList()
	self.orderList[gDeliveryTaskManager.curEvent] = {}
	self.curOrderInfo = gDeliveryTaskManager:GetOrderByEventId(gDeliveryTaskManager.curEvent)

	if self.curOrderInfo then
		self.bindData.taskList:SetSimpleList(#self.branchList)
	end
end

function M:OnRenderTaskItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local data = self.branchList[index + 1]

		if data then
			store.taskState = data.taskState

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				store.pcKeyName = data.index
			end

			if not data.isLast then
				self:ChangeCargoIntegrity(store, self.curOrderInfo.cargoInfoList[data.index])

				store.taskName = self.curOrderInfo.cargoInfoList[data.index].orderCfg.information
				store.finishState = self.curOrderInfo.cargoInfoList[data.index].isFinish and CargoState.finish or CargoState.doing
				store.receiverState = 0
			else
				store.taskName = self.curOrderInfo.finishPosText
				store.finishState = CargoState.doing
				store.receiverState = 1
			end

			if self.curBranch == data.index then
				self:SendTraceMessage(data.isLast, data.index)
			end

			if self:IsInPad() then
				store.controllerState = self.curBranch ~= data.index and 1 or 0
			end

			store.branchItem:SetPCKeyInfoWithOutTip(data.pcKeyId, 0, 0, 0, 0)

			self.orderList[gDeliveryTaskManager.curEvent][data.index] = store
		end
	end
end

function M:SendTraceMessage(isLast, index)
	if isLast then
		gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_TRACE_CHANGE, {
			traceType = 1
		})
	else
		local order = gDeliveryTaskManager:GetOrderByEventId(gDeliveryTaskManager.curEvent)

		if order and order.cargoInfoList[index] then
			gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_TRACE_CHANGE, {
				traceType = 0,
				uniqueId = order.cargoInfoList[index].instanceId
			})
		end
	end
end

function M:OnBranchItemClick(btn, index)
	index = index + 1

	if not self:IsInPad() then
		self.curBranch = index
	else
		local nextIndex = index + 1

		if nextIndex > #self.branchList then
			nextIndex = 1
		end

		self.curBranch = nextIndex
	end

	self:RefreshOrderListPanel()
end

function M:RegisterTaskEvent()
	if not self.isGuide then
		self.isGuide = true
		local taskId = gTaskManager:GetCurTask()

		self:OnCurrentChange(_, {
			TaskId = taskId
		})
		self:SetBtnGuideState(true)
	end
end

function M:SetBtnGuideState(isGuide)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local isPadModel = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
		self.bindData.taskHide = isGuide and 1 or 0

		if isPadModel then
			self.bindData.padOpenAppBtn:SetActive(not isGuide)
			self.bindData.padAutoBtn:SetActive(self:CheckAutoBtnCanShow())
		else
			self.bindData.logBtn:SetActive(not isGuide)
			self.bindData.autoBtn:SetActive(not isGuide)
		end
	else
		self.bindData.mobileQuitBtn:SetActive(not isGuide)
	end
end

function M:UnRegisterTaskEvent()
	if self.isGuide then
		self:SetBtnGuideState(false)

		self.isGuide = false
	end
end

function M:OnCurrentChange(_, data)
	self.taskId = data.TaskId
	self.curTaskInfo = gTaskNodeManager:GetTaskCounterInfo(self.taskId)

	if not self.curTaskInfo then
		return
	end

	local isSameRaid = self.curTaskInfo.RaidId == gRaidDataManager.RaidId
	self.isInTaskRaid = isSameRaid and not gUIUtils:IsInOtherWorld()
	local cfg = gTaskManager:GetTaskConfigInfo(self.taskId)
	self.isShowTaskCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowCounter) or self.curTaskInfo.ShowCounter

	self:RefreshCurrentTaskDes()
end

function M:RefreshCurrentTaskDes()
	if not self.curTaskInfo then
		return
	end

	local des = gUtils:GetSpecialDescription(self.curTaskInfo.WorkDescription, true) or ""

	if self.isInTaskRaid then
		self:SwitchTaskInfo(des .. self:GetTaskCounter())
	else
		self:SwitchTaskInfo(self.curTaskInfo.EventObjective or "")
	end

	if gTaskManager:IsTaskInRiskControl(self.curTaskInfo.TaskId) then
		self:SwitchTaskInfo(gDeliveryTaskManager.WaitOrderText)
	end
end

function M:GetTaskCounter()
	local taskInfo = self.curTaskInfo
	local taskCounter = ""

	if self.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.taskId)
		local isShowAllCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllCounter)

		if taskInfo.totalValue and not isShowAllCounter then
			allCounterValue = taskInfo.totalValue
		elseif self.curTaskInfo.TargetType ~= gTaskManager.ACTION_TYPE.NONE then
			for i = 1, #cfg.Counter do
				local couterNum = cfg.Counter[i]
				allCounterValue = allCounterValue + couterNum
			end
		end

		if isShowAllCounter then
			local tasks = gTaskManager:GetTaskInfo(self.taskId)

			if self.curTaskInfo.TargetType ~= gTaskManager.ACTION_TYPE.NONE then
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

function M:SwitchTaskInfo(data)
	self.bindData.hudTitle = data
end

function M:RefreshAutoTakeOrderState()
	local auto = gDeliveryTaskManager:CheckIsAuto()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.autoBtn:SetPCKeyInfoTipNameId(auto and AutoTipText.ON or AutoTipText.OFF)

		self.bindData.padAutoState = auto and AutoState.ON or AutoState.OFF
	else
		self.bindData.autoState = auto and AutoState.ON or AutoState.OFF
	end
end

function M:CheckAutoBtnCanShow(phoneIsClosing)
	local teachEventId = LTConfig.UberSimConfig.TeachEventId
	local eventState = gTaskManager:GetTaskEventState(teachEventId)

	return eventState == UX.Game.TaskEventState.Submited and (phoneIsClosing or not self:CheckIsPhoneOpen()) and not self.isGuide
end

function M:CheckTeachTaskState(_, data)
	if self.isGuide and data then
		self:OnCurrentChange(_, data)

		return
	end

	local teachEventId = LTConfig.UberSimConfig.TeachEventId
	local eventState = gTaskManager:GetTaskEventState(teachEventId)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.autoBtn:SetActive(eventState == UX.Game.TaskEventState.Submited)
		self.bindData.padAutoBtn:SetActive(self:CheckAutoBtnCanShow())
	else
		self.bindData.mobileAutoBtn:SetActive(eventState == UX.Game.TaskEventState.Submited)
	end
end
