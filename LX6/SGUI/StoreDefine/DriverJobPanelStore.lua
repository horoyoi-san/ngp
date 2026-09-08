-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DriverJobPanelStore.lua
-- Decompiled from: 01840_DriverJobPanelStore.lua_ffe38aa5509c.luajit

C_DriverJobPanelStore = DefClass("C_DriverJobPanelStore", C_DriverJobPanelStore, C_StoreGroup)
GroupName2Class.DriverJobPanelStore = C_DriverJobPanelStore
local M = C_DriverJobPanelStore
local UberSimConfig = LTConfig.UberSimConfig
local RandomGoodsConfig = LTConfig.UberSimRandomGoodsConfig
local TaskConfig = LTConfig.TaskConfig
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local PanelState = {
	["y#qW"] = 2,
	["Z\\x90\\x80\\x80I"] = 0,
	["m#tO"] = 1,
	["G\\x83\\x83\\x82M"] = 3
}
local CargoState = {
	["A\\x9f\\x87\\x90I"] = 1,
	["I\\xa1\\xab\\xa1\\xb1"] = 0
}
local BranchPadKey = {
	19,
	18,
	20,
	21
}
local AutoState = {
	["/'"] = 1,
	["\\xa1N@"] = 0
}
local AutoTipText = {
	["/'"] = 591,
	["\\xa1N@"] = 590
}
local ButtonTextState = {
	["\\xcb\\xde'\\xf4"] = 1,
	["QBolG?"] = 0
}

M.ctor = function(self)
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

M.OnAwake = function(self)
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, self.ChangeBtnState),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, self.ChangeBtnState),
		[gEventConstants.JOB_ORDER_LIST_REFRESH] = self.CreateAction(self, self.JobOrderListRefresh),
		[gEventConstants.JOB_ORDER_LIST_TIME] = self.CreateAction(self, self.JobOrderTimeRefresh),
		[gEventConstants.ON_GOOD_INTEGRITY_CHANGE] = self.CreateAction(self, self.ChangeIntegrity),
		[gEventConstants.DELIVERY_PANEL_STATE_CHANGE] = self.CreateAction(self, self.ChangePanelState),
		[gEventConstants.HIGH_VALUE_ORDER] = self.CreateAction(self, self.ShowHighValueOrder),
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, self.PanelStateToWait),
		[gEventConstants.DELIVERY_STATE_EVENT] = self.CreateAction(self, self.PanelHudTitleEvent),
		[gEventConstants.DELIVERY_GUIDE_HUD] = self.CreateAction(self, self.RegisterTaskEvent),
		[gEventConstants.DELIVERY_AUTO_TAKE_ORDER_CHANGED] = self.CreateAction(self, self.RefreshAutoTakeOrderState),
		[gEventConstants.TASK_STATE_CHANGED] = self.CreateAction(self, self.CheckTeachTaskState)
	}
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.JobOrderListRender)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.GetJobOrderIndex)
	self.bindData.taskList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTaskItem)
	self.bindData.taskList.luaSimpleClick = self.CreateAction(self, self.OnBranchItemClick)
	self.bindData.acceptBtn.luaClick = self.CreateAction(self, self.AcceptOnClick)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.CancelOnClick)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.logBtn.luaClick = self.CreateAction(self, self.OpenApp)
		self.bindData.appOpenBtn.luaClick = self.CreateAction(self, self.OpenApp)
		self.bindData.logBtn.luaLongPress = self.CreateAction(self, self.OpenApp)
		self.bindData.appOpenBtn.luaLongPress = self.CreateAction(self, self.OpenApp)
		self.bindData.autoBtn.luaLongPress = self.CreateAction(self, self.LongPressAutoTask)
		self.bindData.padAutoBtn.luaLongPress = self.CreateAction(self, self.LongPressAutoTask)
		self.bindData.quitTaskBtn.luaClick = self.CreateAction(self, self.ClickQuitTask)
		self.bindData.padQuitTaskBtn.luaLongPress = self.CreateAction(self, self.ClickQuitTask)
	else
		self.bindData.mobileExitBtn.luaClick = self.CreateAction(self, self.AskAbandonCurrentTask)
		self.bindData.mobileOpenBtn.luaClick = self.CreateAction(self, self.OpenApp)
		self.bindData.mobileAutoBtn.luaClick = self.CreateAction(self, self.LongPressAutoTask)
		self.bindData.mobileQuitBtn.luaClick = self.CreateAction(self, self.ClickQuitTask)
	end

	self.RegisterMessageEvents(self, self.msgEvents)
	self.InitConfig(self)
end

M.ObsoleteTruckJobOrder = function(self, callBack)
	local orderId = gDeliveryTaskManager:GetCurOrderId()

	if orderId then
		slot3 = gDeliveryTaskManager

		slot3:SetOrderObsolete(orderId)

		slot3 = gClientToGameDelegate

		slot3:AskObsoleteTruckJobOrder(orderId).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
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

M.AcceptOnClick = function(self)
	if self.orderUniqueId then
		self.ObsoleteTruckJobOrder(self, function ()
			gClientToGameDelegate:AskAcceptTruckJobOrder(self.orderUniqueId).Callback = function (errorId, callbackTruckJobOrderWrap, npcInstanceId)
				if errorId == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end
			end

			self:StopTaskTimeFill()
		end)
	end
end

M.CancelOnClick = function(self)
	self.StopTaskTimeFill(self)
end

M.OnShow = function(self, data)
	if not data or not data.isOnlyOpenPanel then
		self.needRefresh = true
		self.curBranch = 1

		self:SetPanelState(PanelState.wait)
		gDeliveryTaskManager:ChangeDeliveryPanelTitle(gDeliveryTaskManager.TitleType.WaitOrderText)
	end

	self.CheckAppHomePanelState(self)
	self.CheckTeachTaskState(self)
	self.SetAutoState(self)

	if data and data.isGuide then
		self.RegisterTaskEvent(self)
		self.RefreshOrderListPanel(self)
	end

	self.InitOrderListPanel(self)
end

M.InitOrderListPanel = function(self)
	if gDeliveryTaskManager.isUpdate then
		self.JobOrderListRefresh(self, _, true)
	end
end

M.SetAutoState = function(self)
	slot1 = gCoroutineManager

	slot1:StartCoroutine(function ()
		while gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene do
			coroutine.yield(nil)
		end

		slot0 = gClientToGameDelegate

		slot0:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
			if errorId == LTConfig.MessageConfig.Ok then
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
	end)
end

M.InitConfig = function(self)
	self.InitAcceptCount = UberSimConfig.InitAcceptCount
	self.AddAcceptBadgeList = UberSimConfig.AddAcceptBadgeList
	self.taskTime = UberSimConfig.HighPriceTipsTime
	self.deliveryShortCutDefault = UberSimConfig.DeliveryShortCut[1]
	self.deliveryShortCutUp = UberSimConfig.DeliveryShortCut[2]
	self.startTaskTime = gCS.TimeManager.ServerUnixTime
	self.startTaskUpdate = false
	self.pressTime = 1
end

M.PanelHudTitleEvent = function(self, _, data)
	self.hudTitle = data.title

	self.RefreshPanelHudTitle(self)
end

M.RefreshPanelHudTitle = function(self)
	if self.needRefresh and not self.CheckCanUseTaskDes() then
		self.SwitchHudTitle(self, self.hudTitle)
	end
end

M.CheckCanUseTaskDes = function(self)
	local taskId = gTaskManager:GetCurTask()

	if taskId ~= 0 or gTaskManager:GetTaskState(taskId) == UX.Game.TaskState.Accepted then
		return false
	end

	local eventId = gTaskNodeManager:GetEventIdByTask(taskId)

	return not table.contains(LTConfig.UberSimConfig.FixedTaskDescription, eventId)
end

M.CheckIsPhoneOpen = function(self)
	return gPanelManager:IsPanelShowing(gPanelId.S_HALF_PHONE_APP_HOME_PANEL) or gPanelManager:IsPanelShowing(gPanelId.S_HALF_PHONE_APP_HOME_PANEL)
end

M.CheckAppHomePanelState = function(self)
	if self.CheckIsPhoneOpen(self) then
		self.ChangeBtnState(self, gEventConstants.ON_PHONE_APP_HOME_SHOW)
	else
		self.ChangeBtnState(self, gEventConstants.ON_PHONE_APP_HOME_HIDE)
	end
end

M.ShowHighValueOrder = function(self, _, order)
	local orderInfo = order.OrderInfo
	self.highCargoId = orderInfo.CargoId
	self.bindData.btnTextState = gDeliveryTaskManager:IsHaveOrder() and ButtonTextState.replace or ButtonTextState.receiving

	self:SetHighValueText()

	self.bindData.money = orderInfo.DropMoney
	self.orderUniqueId = order.UniqueId

	self:StartTaskTimeFill()
end

M.SetHighValueText = function(self)
	self.SwitchHudTitle(self, gDeliveryTaskManager.HighOrderText)

	if self.highCargoId then
		local config = RandomGoodsConfig.GetConfig(self.highCargoId)

		if config then
			self.bindData.name = config.information
		end
	end
end

M.ChangeBtnState = function(self, eventId)
	local isPadModel = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	if isPadModel and not self.isGuide then
		if eventId ~= gEventConstants.ON_PHONE_APP_HOME_SHOW then
			self.bindData.padOpenAppBtn:SetActive(false)
			self.bindData.padAutoBtn:SetActive(false)
		else
			self.bindData.padOpenAppBtn:SetActive(true)
			self.bindData.padAutoBtn:SetActive(self:CheckAutoBtnCanShow(true))
		end
	end
end

M.OpenApp = function(self)
	gMainPhoneFunctionAction.OpenUberSim()
end

M.OpenAccount = function(self)
	gDeliveryTaskManager.OpenDeliveryAccountPanel()
end

M.OnUpdate = function(self)
	if self.startPress then
		local nowTime = gLogicTime.time
		self.bindData.exitFill = (nowTime - self.startPressTime) / self.pressTime

		if self.pressTime >= nowTime - self.startPressTime then
			self.OnPressBtnEndHelper(self)
			self.AskAbandonCurrentTask(self)
		end
	end

	if self.startTaskUpdate then
		local nowTime = gCS.TimeManager.ServerUnixTime
		self.bindData.timeFill = 1 - (nowTime - self.startTaskTime) / self.taskTime

		if self.taskTime >= nowTime - self.startTaskTime then
			self.StopTaskTimeFill(self)
		end
	end
end

M.StopTaskTimeFill = function(self)
	self.startTaskUpdate = false
	self.needRefresh = true

	self.RefreshPanelState(self)
	self.RefreshPanelHudTitle(self)
end

M.StartTaskTimeFill = function(self)
	self.startTaskTime = gCS.TimeManager.ServerUnixTime
	self.startTaskUpdate = true
	self.bindData.panelState = PanelState.call
	self.needRefresh = false
end

M.AskAbandonCurrentTask = function(self)
	gDeliveryTaskManager:AskAbandonCurrentTask()
end

M.OnPressBtnBegin = function(self)
	if self.bindData.exitBtnState ~= 4 then
		return
	end

	self.bindData.longPress = 1
	self.startPress = true
	self.startPressTime = gLogicTime.time
end

M.OnPressBtnEnd = function(self)
	self.OnPressBtnEndHelper(self)
end

M.LongPressAutoTask = function(self)
	gDeliveryTaskManager:AskAutoAcceptTruckJobOrder(not gDeliveryTaskManager:CheckIsAuto())
end

M.ClickQuitTask = function(self)
	self.ObsoleteTruckJobOrder(self, function ()
		gDeliveryTaskManager:RemoveCurTruckOrder()
	end)
end

M.OnPressBtnEndHelper = function(self)
	self.startPress = false
	self.bindData.longPress = 0
end

M.JobOrderListRefresh = function(self, _, isOpen)
	if isOpen then
		self.StopTaskTimeFill(self)
	end

	self.RefreshOrderListPanel(self)
end

M.GetJobOrderIndex = function(self)
	return gDeliveryTaskManager.tIndex
end

M.JobOrderListRender = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		local data = self.orderDataList[index + 1]

		if data then
			store.timeState = data.orderTime < 0 and 1 or 0
			store.orderName = data.firstCargo.orderCfg.information

			if gDeliveryTaskManager.tIndex ~= gDeliveryTaskManager.CargoType.normal then
				store.iconUrl = gUIUtils:GetSguiImagePath(data.firstCargo.imageId)
			end

			store.branchItem.anim:Play()

			if data.firstCargo.isUpdate then
				self.UpdateIntegrity(self, store, data, gDeliveryTaskManager.tIndex)
			else
				store.cargoState = 0
				store.typeCtrl = 0
			end

			self.orderList[data.AcceptedEventId] = store
		end
	end
end

M.UpdateIntegrity = function(self, store, orderInfo, type, extraParam)
	if not self.curIsTrueBranch then
		if type ~= gDeliveryTaskManager.CargoType.normal then
			if orderInfo.firstCargo and orderInfo.firstCargo.needCheckItemNum then
				if extraParam then
					store.totalText = "/" .. extraParam.maxCount
					store.warnCount = extraParam.warnCount or 0
				end

				if not store.warnCount or store.warnCount >= orderInfo.firstCargo.integrity then
					slot5 = 2
				else
					slot5 = 1
				end

				store.typeCtrl = slot5
				store.numText = orderInfo.firstCargo.integrity
			else
				store.typeCtrl = 0
				local state = gDeliveryTaskManager:GetCargoState(orderInfo.firstCargo, true)

				if state == gDeliveryTaskManager.CargoState.Finish then
					store.cargoState = state
				end
			end
		elseif type ~= gDeliveryTaskManager.CargoType.special then
			self.AddMoneyEffect(self, store, orderInfo.firstCargo.integrity)
		end
	else
		for index, v in pairs(orderInfo.cargoInfoList) do
			local cargoStore = store[index]

			self.ChangeCargoIntegrity(self, cargoStore, v)
		end
	end
end

M.AddMoneyEffect = function(self, store, targetNum)
	local scrollNum = store.ScrollGroup

	scrollNum.PlayToTarget(scrollNum, targetNum)
end

M.ChangeCargoIntegrity = function(self, cargoStore, cargoInfo)
	local state = gDeliveryTaskManager:GetCargoState(cargoInfo, true)

	if state == gDeliveryTaskManager.CargoState.Finish then
		cargoStore.cargoState = state
	else
		cargoStore.finishState = 1
	end
end

M.JobOrderTimeRefresh = function(self, _, data)
	local eventId = data.eventId
	local time = data.time
	local store = self.orderList[eventId]

	if store and data.isUpdateTime then
		store.time = time
		store.colorState = data.colorState
	end
end

M.ChangeIntegrity = function(self, _, data)
	local eventId = data.eventId
	local store = self.orderList[eventId]

	if store then
		self.UpdateIntegrity(self, store, data.orderInfo, data.type, data.extraParam)
	end
end

M.OnEnable = function(self)
	self.LanguageChange(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.LanguageChange = function(self)
	self:InitConfig()
	gDeliveryTaskManager:InitConfigData()

	if self.bindData.panelState ~= PanelState.branch or self.bindData.panelState ~= PanelState.normal then
		self.RefreshOrderListPanel(self)
	end

	if self.bindData.panelState ~= PanelState.call then
		self.SetHighValueText(self)
	end

	gDeliveryTaskManager:RefreshStoreText()
	self:RefreshPanelState()
end

M.OnGroupDisable = function(self)
end

M.ChangePanelState = function(self, _, data)
	if not data then
		self.curBranch = 1

		self.UnRegisterTaskEvent(self)
		self.SetPanelState(self, PanelState.wait)
	end
end

M.PanelStateToWait = function(self)
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

M.ShotCutToDefault = function(self)
	self.bindData.shotCutName = self.deliveryShortCutDefault

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.logBtn.luaClick = self.CreateAction(self, self.OpenApp)
		self.bindData.logBtn.luaLongPress = self.CreateAction(self, self.OpenApp)
		self.bindData.padAppState = 0
	else
		self.bindData.mobileOpenBtn.luaClick = self.CreateAction(self, self.OpenApp)
	end
end

M.RefreshPanelState = function(self)
	if self.needRefresh then
		self.bindData.panelState = self.panelState

		if self.panelState ~= PanelState.wait then
			self.PanelStateToWait(self)
		else
			self.ShotCutToDefault(self)
		end
	end
end

M.SetPanelState = function(self, state)
	gDeliveryTaskManager:DebugPrint("SetPanelState", state)

	self.panelState = state

	self:RefreshPanelState()
end

M.OnClose = function(self)
	self.UnRegisterTaskEvent(self)
end

M.OnLanguageChange = function(self, lang)
	self.LanguageChange(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.CheckAppHomePanelState(self)

	if self.panelState ~= PanelState.normal or self.panelState ~= PanelState.branch then
		self.RefreshOrderListPanel(self)
	end

	self.RefreshPanelState(self)

	if self.isGuide then
		self.SetBtnGuideState(self, true)
	end
end

M.RefreshBranchList = function(self)
	self.branchList = {}
	local order = gDeliveryTaskManager:GetOrderByEventId(gDeliveryTaskManager.curEvent)

	if not order or #order.cargoInfoList < 1 then
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
		info.taskState = i ~= self.curBranch and 1 or 0
		info.isLast = i ~= branchLength

		table.insert(workActionList, info)
	end

	self.branchList = workActionList
	self.curIsTrueBranch = true
end

M.RefreshOrderListPanel = function(self)
	self.orderList = {}

	self.RefreshBranchList(self)

	if self.curIsTrueBranch then
		self.SetPanelState(self, PanelState.branch)
		self.SetNormalList(self)
	else
		self:SetPanelState(PanelState.normal)

		self.orderDataList = table.clone(gDeliveryTaskManager.orderList)

		self.bindData.list:SetSimpleList(#self.orderDataList)
		self.bindData.list.anim:Play(self:GetOpenAnimName())
	end
end

M.GetOpenAnimName = function(self)
	return gCS.LuaUtils.IsNonMobileAdaptive() and self.openAnim or self.mobileOpenAnim
end

M.IsInPc = function(self)
	return InputActionBind.activeGameDevice ~= GameDevice.KeyboardMouse
end

M.IsInPad = function(self)
	return InputActionBind.activeGameDevice ~= GameDevice.Xbox or InputActionBind.activeGameDevice ~= GameDevice.PlayStation
end

M.SetNormalList = function(self)
	self.orderList[gDeliveryTaskManager.curEvent] = {}
	self.curOrderInfo = gDeliveryTaskManager:GetOrderByEventId(gDeliveryTaskManager.curEvent)

	if self.curOrderInfo then
		self.bindData.taskList:SetSimpleList(#self.branchList)
	end
end

M.OnRenderTaskItem = function(self, btn, index)
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

			if self.curBranch ~= data.index then
				self.SendTraceMessage(self, data.isLast, data.index)
			end

			if self.IsInPad(self) then
				store.controllerState = self.curBranch == data.index and 1 or 0
			end

			store.branchItem:SetPCKeyInfoWithOutTip(data.pcKeyId, 0, 0, 0, 0)

			self.orderList[gDeliveryTaskManager.curEvent][data.index] = store
		end
	end
end

M.SendTraceMessage = function(self, isLast, index)
	if isLast then
		gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_TRACE_CHANGE, {
			["WUmjK*="] = 1
		})
	else
		local order = gDeliveryTaskManager:GetOrderByEventId(gDeliveryTaskManager.curEvent)

		if order and order.cargoInfoList[index] then
			gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_TRACE_CHANGE, {
				["WUmjK*="] = 0,
				uniqueId = order.cargoInfoList[index].instanceId
			})
		end
	end
end

M.OnBranchItemClick = function(self, btn, index)
	index = index + 1

	if not self.IsInPad(self) then
		self.curBranch = index
	else
		local nextIndex = index + 1

		if nextIndex <= #self.branchList then
			nextIndex = 1
		end

		self.curBranch = nextIndex
	end

	self.RefreshOrderListPanel(self)
end

M.RegisterTaskEvent = function(self)
	if not self.isGuide then
		self.isGuide = true
		local taskId = gTaskManager:GetCurTask()

		self:OnCurrentChange(_, {
			taskId
		})
		self:SetBtnGuideState(true)
	end
end

M.SetBtnGuideState = function(self, isGuide)
	self.RefreshAutoBtnState(self, isGuide)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.taskHide = isGuide and 1 or 0

		self.bindData.padOpenAppBtn:SetActive(not isGuide)
		self.bindData.logBtn:SetActive(not isGuide)
		self.bindData.padQuitTaskBtn:SetActive(not isGuide)
		self.bindData.quitTaskBtn:SetActive(not isGuide)
	else
		self.bindData.mobileExitBtn:SetActive(not isGuide)
		self.bindData.mobileOpenBtn:SetActive(not isGuide)
		self.bindData.mobileQuitBtn:SetActive(not isGuide)
	end
end

M.UnRegisterTaskEvent = function(self)
	if self.isGuide then
		self.SetBtnGuideState(self, false)

		self.isGuide = false
	end
end

M.OnCurrentChange = function(self, _, data)
	self.taskId = gTaskManager:GetCurTask()
	self.curTaskInfo = gTaskNodeManager:GetTaskCounterInfo(self.taskId)

	if not self.curTaskInfo then
		return
	end

	local isSameRaid = self.curTaskInfo.RaidId ~= gRaidDataManager.RaidId
	self.isInTaskRaid = isSameRaid and not gUIUtils:IsInOtherWorld()
	local cfg = gTaskManager:GetTaskConfigInfo(self.taskId)
	self.isShowTaskCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowCounter) or self.curTaskInfo.ShowCounter

	self:RefreshCurrentTaskDes()
end

M.RefreshCurrentTaskDes = function(self)
	if not self.curTaskInfo then
		return
	end

	local des = gUtils:GetSpecialDescription(self.curTaskInfo.WorkDescription, true) or ""

	if self.isInTaskRaid then
		self.SwitchHudTitle(self, des .. self.GetTaskCounter(self))
	else
		self:SwitchHudTitle(self.curTaskInfo.EventObjective or "")
	end

	if gTaskManager:IsTaskInRiskControl(self.curTaskInfo.TaskId) then
		self.SwitchHudTitle(self, gDeliveryTaskManager.WaitOrderText)
	end
end

M.GetTaskCounter = function(self)
	local taskInfo = self.curTaskInfo
	local taskCounter = ""

	if self.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.taskId)
		local isShowAllCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllCounter)

		if taskInfo.totalValue and not isShowAllCounter then
			allCounterValue = taskInfo.totalValue
		elseif self.curTaskInfo.TargetType == gTaskManager.ACTION_TYPE.NONE then
			for i = 1, #cfg.Counter do
				local couterNum = cfg.Counter[i]
				allCounterValue = allCounterValue + couterNum
			end
		end

		if isShowAllCounter then
			local tasks = gTaskManager:GetTaskInfo(self.taskId)

			if self.curTaskInfo.TargetType == gTaskManager.ACTION_TYPE.NONE then
				nowCounterValue = 0

				for i = 1, #tasks.Counters do
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

M.SwitchHudTitle = function(self, data)
	self.bindData.hudTitle = data
end

M.RefreshAutoTakeOrderState = function(self)
	local auto = gDeliveryTaskManager:CheckIsAuto()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.autoBtn:SetPCKeyInfoTipNameId(auto and AutoTipText.ON or AutoTipText.OFF)

		self.bindData.padAutoState = auto and AutoState.ON or AutoState.OFF
	else
		self.bindData.autoState = auto and AutoState.ON or AutoState.OFF
	end
end

M.CheckAutoBtnCanShow = function(self, phoneIsClosing)
	return (phoneIsClosing or not self:CheckIsPhoneOpen()) and not self.isGuide
end

M.CheckTeachTaskState = function(self, _, data)
	if self.CheckCanUseTaskDes() and data then
		self.OnCurrentChange(self, _, data)

		return
	end

	self.RefreshPanelHudTitle(self)
	self.RefreshAutoBtnState(self, self.isGuide)
end

M.RefreshAutoBtnState = function(self, forceHide)
	if forceHide then
		self.SetAutoBtnState(self, false)

		return
	end

	local teachEventId = LTConfig.UberSimConfig.TeachEventId
	local eventState = gTaskManager:GetTaskEventState(teachEventId)

	self:SetAutoBtnState(eventState ~= UX.Game.TaskEventState.Submited)
end

M.SetAutoBtnState = function(self, isShow)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.autoBtn:SetActive(isShow)
		self.bindData.padAutoBtn:SetActive(isShow and self:CheckAutoBtnCanShow())
	else
		self.bindData.mobileAutoBtn:SetActive(isShow)
	end
end
