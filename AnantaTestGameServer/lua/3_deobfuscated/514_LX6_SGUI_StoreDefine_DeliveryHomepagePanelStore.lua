C_DeliveryHomepagePanelStore = DefClass("C_DeliveryHomepagePanelStore", C_DeliveryHomepagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryHomepagePanelStore = C_DeliveryHomepagePanelStore
local M = C_DeliveryHomepagePanelStore

function M:OnAwake()
	self.bindData.orderButton.luaClick = self:CreateAction("OnOrderClick")
	self.bindData.takeOrderList.luaSimpleRenderItem = self:CreateAction("OnTakeOrderRendererItem")
	self.bindData.takeOrderList.luaLayoutSet = self:CreateAction("OnTakeOrderListLayoutSet")
	self.bindData.takeOrderList.onGetTIndex = self:CreateAction("OnTakeOrderGetTIndex")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.takeOrderList.luaSimpleDynamicRenderItem = self:CreateAction("OnTakeOrderRendererItem")
	self.bindData.callFunctionList.luaSimpleRenderItem = self:CreateAction("OnCallFunctionRenderItem")
	self.bindData.supportDetailBtn.luaClick = self:CreateAction("OnControllerOrderSupportItemDetailClick")
	self.bindData.supportConfirmBtn.luaClick = self:CreateAction("OnControllerOrderSupportItemClick")
	self.bindData.autoBtn.luaClick = self:CreateAction("OnAutoBtnClick")
	self.bindData.takeOrderList.luaBeginDrag = self:CreateAction("OnTakeOrderBeginDrag")
	self.bindData.takeOrderList.luaDrag = self:CreateAction("OnTakeOrderDrag")
	self.bindData.takeOrderList.luaEndDrag = self:CreateAction("OnTakeOrderEndDrag")
	self.bindData.refreshBtn.luaClick = self:CreateAction("OnRefreshBtnClick")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_TRUCK_ORDER_OBSOLETED] = self:CreateAction("OnOrderStateChange"),
		[gEventConstants.ON_TRUCK_ORDER_COMPLETED] = self:CreateAction("OnTruckOrderCompleted"),
		[gEventConstants.ON_CURRENT_TRUCK_ORDER_CHANGE] = self:CreateAction("OnCurrentOrderChange"),
		[gEventConstants.ON_ACCEPT_TRUCK_JOB_ORDER] = self:CreateAction("OnAcceptTruckJobOrder"),
		[gEventConstants.REFRESH_DELIVERY_DATA] = self:CreateAction("DeliveryHomeRefresh"),
		[gEventConstants.SUMMON_STATE_SWITCH] = self:CreateAction("OnSummonStateSwitch"),
		[gEventConstants.REFRESH_HEADVIEW_BUFFS] = self:CreateAction("RefreshCallFunctionListView"),
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction("RefreshRedDotView"),
		[gEventConstants.DELIVERY_SPOON_ORDER_DATA_CHANGED] = self:CreateAction("OnDeliverySpoonOrderDataChanged"),
		[gEventConstants.DELIVERY_DEFAULT_VEHICLE_CHANGED] = self:CreateAction("OnDeliveryDefaultVehicleChanged"),
		[gEventConstants.DELIVERY_AUTO_TAKE_ORDER_CHANGED] = self:CreateAction("RefreshAutoTakeOrderState"),
		[gEventConstants.TASK_STATE_CHANGED] = self:CreateAction("CheckTeachTaskState"),
		[gEventConstants.ON_DELIVERY_TRUNK_ORDER_NEW_DAY] = self:CreateAction("OnTruckOrderNewDay")
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.Order_List_Template_Type = {
		Refresh = 0,
		Order = 1
	}
	self.Order_State_Control = {
		Take = 0,
		Empty = 2,
		Accept = 1
	}
	self.Take_State_Control = {
		GiveUp = 1,
		PickUp = 0,
		None = 2
	}
	self.Refresh_Tip_State_Control = {
		Hide = 0,
		Show = 1
	}
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	self.customOrderData = gDeliveryTaskManager:GetSpoonCustomOrderData()
	self.RefreshOrderTime = LTConfig.UberSimConfig.TakeOrderRefreshTime
	local clientTruckOrderView = args.clientTruckOrderView
	self.clientTruckOrderView = clientTruckOrderView
	self.defaultVehicleId = self.clientTruckOrderView.DefaultVehicleId or 0
	self.takeOrderList = self.customOrderData and self.customOrderData.orders or clientTruckOrderView.Orders
	self.currentOrderId = self.customOrderData and self.customOrderData.currentOrderId or clientTruckOrderView.CurrentOrderId
	self.countDownTime = self.RefreshOrderTime
	self.refreshNav = true
	self.acceptCountDownIndex = {}
	self.orderViewDataList = nil
	self.canInteract = true
	self.lastClickTime = 0
	self.isInRefreshTimer = false

	gDeliveryTaskManager:SetIsAuto(clientTruckOrderView.AutoAccept)
end

function M:InitView(args)
	M.base.InitView(self, args)
	gDeliveryTaskManager.RefreshDeliveryAvatarView(self.bindData.avatar, self.rootGo)
	self:RefreshRedDotView()
	self:RefreshTakeOrderListView()
	self:RefreshCallFunctionListView()
	self:RefreshAutoTakeOrderState()
	self:CheckTeachTaskState()

	self.bindData.refreshTipsCtrl = self.Refresh_Tip_State_Control.Hide
end

function M:OnActiveDeviceChange(device)
	local gamepadMode = SGUI.GameDevice.KeyboardMouse < device

	if self.gamepadMode ~= gamepadMode then
		self.gamepadMode = gamepadMode
		self.pressedSupportId = nil
		self.bindData.supportHoldRoot.activation = false
		self.bindData.supportListOpacity = 1

		self.bindData.takeOrderList:RefreshList()
	end
end

function M:OnUpdate()
	self:UpdateAcceptCountDown()
end

function M:DeliveryHomeRefresh(_, data)
	local needRefresh = false

	for i = #self.takeOrderList, 1, -1 do
		local orderInfo = self.takeOrderList[i]

		if orderInfo.UniqueId == data.UniqueId then
			orderInfo.AcceptInfo = data.AcceptInfo
			needRefresh = true
		end
	end

	if needRefresh then
		self.lastRefreshTime = gLuaDataManager.serverTime

		self.bindData.takeOrderList:RefreshList()
	end
end

function M:OnSummonStateSwitch()
	local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.GetConfig(LTConfig.UberSimOrderSupportConfig.Drone)

	if gBattleMgr.SummonAgentId == orderSupportCfg.functionId and orderSupportCfg.SuccessDialogId > 0 then
		gDialogManager:ShowGeneralDialog(orderSupportCfg.SuccessDialogId, gDialogSource.Delivery)
	end

	self:RefreshCallFunctionListView()
end

function M:RefreshRedDotView()
	if not self.bindData.avatar then
		return
	end

	local avatarStore = gStoreManager:GetStoreGroup(self.bindData.avatar.Store):GetStoreByWidget(self.bindData.avatar)
	local redDotKey = "DeliveryHomePagePanelAvatarRedDot"
	avatarStore.button.redKey = redDotKey
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Delivery)
	local hasRedDot = gDeliveryTaskManager:CheckCanPromote(targetJobId)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

function M:RefreshCallFunctionListView()
	self.callFuncViewDataList = {}
	local count = LTConfig.UberSimOrderSupportConfig.count
	local containPressedId = false

	for i = 0, count - 1 do
		local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.LoadAt(i)
		local buffId = orderSupportCfg.UnlockBuff

		if buffId and buffId > 0 then
			if gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, buffId) then
				table.insert(self.callFuncViewDataList, {
					id = orderSupportCfg.Id
				})

				if orderSupportCfg.Id == self.pressedSupportId then
					containPressedId = true
				end
			end
		else
			table.insert(self.callFuncViewDataList, {
				id = orderSupportCfg.Id
			})

			if orderSupportCfg.Id == self.pressedSupportId then
				containPressedId = true
			end
		end
	end

	self.bindData.callFunctionList:SetSimpleList(#self.callFuncViewDataList)

	self.bindData.callFunctionEmptyControl = #self.callFuncViewDataList == 0 and 1 or 0

	if self.pressedSupportId then
		if containPressedId then
			self.bindData.droneControllerText = gDeliveryTaskManager.CheckHasDroneAgent() and 1 or 0
		else
			self.pressedSupportId = nil
			self.bindData.supportHoldRoot.activation = false
			self.bindData.supportListOpacity = 1
		end
	end
end

function M:OnTruckOrderCompleted(_, truckJobOrderWrap)
	self:OnOrderStateChange(truckJobOrderWrap.UniqueId)
end

function M:OnTruckOrderNewDay()
	local rootGo = self.rootGo
	self.canInteract = false

	gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			self.canInteract = true

			return
		end

		if gClientUtils.IsNil(rootGo) then
			self.canInteract = true

			return
		end

		self:RefreshOnNewDay(clientTruckOrderView)
	end
end

function M:RefreshOnNewDay(clientTruckOrderView)
	self.canInteract = true
	self.clientTruckOrderView = clientTruckOrderView
	self.defaultVehicleId = self.clientTruckOrderView.DefaultVehicleId or 0
	self.takeOrderList = self.customOrderData and self.customOrderData.orders or clientTruckOrderView.Orders
	self.currentOrderId = self.customOrderData and self.customOrderData.currentOrderId or clientTruckOrderView.CurrentOrderId

	self:RefreshTakeOrderListView()
	self:RefreshCallFunctionListView()
	self:RefreshAutoTakeOrderState()
	self:CheckTeachTaskState()
end

function M:OnOrderStateChange(_, uniqueId)
	self.canInteract = true

	for i = #self.takeOrderList, 1, -1 do
		local orderInfo = self.takeOrderList[i]

		if orderInfo.UniqueId == uniqueId then
			if orderInfo.OrderInfo.IsDailyOrder then
				orderInfo.AcceptInfo = nil

				table.remove(self.takeOrderList, i)
				table.insert(self.takeOrderList, orderInfo)

				break
			end

			table.remove(self.takeOrderList, i)

			break
		end
	end

	self:RefreshTakeOrderListView()
	self.bindData.takeOrderList:SetNavSelectToTop()
end

function M:OnDeliverySpoonOrderDataChanged()
	self.customOrderData = gDeliveryTaskManager:GetSpoonCustomOrderData()
	self.takeOrderList = self.customOrderData and self.customOrderData.orders or self.clientTruckOrderView.Orders
	self.currentOrderId = self.customOrderData and self.customOrderData.currentOrderId or self.clientTruckOrderView.CurrentOrderId

	self:RefreshTakeOrderListView()
end

function M:OnDeliveryDefaultVehicleChanged(_, vehicleId)
	self.defaultVehicleId = vehicleId
end

function M:OnCurrentOrderChange(_, uniqueId)
	self.currentOrderId = uniqueId
end

function M:CheckCanTakeOrder()
	local canTakeOrderCount = LTConfig.UberSimConfig.InitAcceptCount
	local badgeIdList = LTConfig.UberSimConfig.AddAcceptBadgeList

	for _, badgeId in ipairs(badgeIdList) do
		local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

		if gSpiritJobManager:CheckSpiritContainBadge(spiritId, badgeId) then
			canTakeOrderCount = canTakeOrderCount + 1
		end
	end

	local hasTakeOrderCount = 0
	local orderInfoList = self.customOrderData and self.customOrderData.orders or self.clientTruckOrderView.Orders

	for _, orderInfo in ipairs(orderInfoList) do
		if orderInfo.AcceptInfo then
			hasTakeOrderCount = hasTakeOrderCount + 1
		end
	end

	return hasTakeOrderCount < canTakeOrderCount, hasTakeOrderCount
end

function M:RefreshTakeOrderListView()
	self.acceptCountDownIndex = {}
	self.orderViewDataList = {}
	self.lastRefreshTime = gLuaDataManager.serverTime

	for _, data in ipairs(self.takeOrderList) do
		local finalAcceptTime = data.OrderInfo.LimitAcceptSeconds + data.OrderInfoStartTime

		if gLuaDataManager.serverTime < finalAcceptTime then
			if data.OrderInfo.IsHighValue then
				table.insert(self.orderViewDataList, 1, {
					tIndex = self.Order_List_Template_Type.Order,
					truckJobOrderWrap = data
				})
			else
				table.insert(self.orderViewDataList, {
					tIndex = self.Order_List_Template_Type.Order,
					truckJobOrderWrap = data
				})
			end
		end
	end

	self.bindData.listEmptyWidget:SetActive(#self.orderViewDataList == 0)
	self.bindData.takeOrderList:SetSimpleList(#self.orderViewDataList)

	self.bindData.orderCtrl = #self.orderViewDataList == 0 and 1 or 0
end

function M:RefreshAutoTakeOrderState()
	self.bindData.autoTakeState = gDeliveryTaskManager:CheckIsAuto() and 1 or 0
end

function M:CheckCanRefreshOrder()
	if self.customOrderData then
		return false
	end

	local takeOrderList = self.clientTruckOrderView.Orders

	for _, truckJobOrderWrap in ipairs(takeOrderList) do
		local orderInfo = truckJobOrderWrap.OrderInfo

		if orderInfo.IsDailyOrder then
			return false
		end

		local orderCfg = LTConfig.UberSimOrderConfig.GetConfig(orderInfo.SpecialOrderId)

		if orderCfg and orderCfg.IsTeach then
			return false
		end
	end

	return true
end

function M:OnCallFunctionRenderItem(btn, csIndex)
	local data = self.callFuncViewDataList[csIndex + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.GetConfig(data.id)
	store.guideId = orderSupportCfg.GuideId or ""
	store.button.luaClick = self:CreateActionWithArgs("OnOrderSupportItemClick", data.id)
	store.detailButton.luaClick = self:CreateActionWithArgs("OnOrderSupportItemDetailClick", data.id)
	local used = false

	if data.id == LTConfig.UberSimOrderSupportConfig.Drone then
		local skillId = orderSupportCfg.functionId
		used = gDeliveryTaskManager.CheckHasDroneAgent(skillId)
	end

	store.callStateControl = used and 1 or 0
	store.state = used and orderSupportCfg.UsedStateText or orderSupportCfg.CanUseStateText
	store.name = orderSupportCfg.name
	store.iconId = used and orderSupportCfg.UsedStateIcon or orderSupportCfg.CanUseStateIconId
	store.customNavRespond.luaGamePadInputChanged = self:CreateActionWithArgs(self.OnOrderSupportItemGamePadCustomPress, {
		index = csIndex,
		id = data.id
	})
	store.gamePadControl = csIndex == 0 and 0 or 1
end

function M:OnOrderSupportItemClick(id)
	local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.GetConfig(id)
	local functionId = orderSupportCfg.functionId

	if id == LTConfig.UberSimOrderSupportConfig.Drone then
		gNewGuideMgr:NotifySignal(EGuideSignal.DeliveryCallDrone)
		gDeliveryTaskManager.DoDroneSupport(functionId)
		self.bindData.callFunctionList:RefreshList()
	elseif id == LTConfig.UberSimOrderSupportConfig.CallCar then
		local vehicleId = self.defaultVehicleId

		if not vehicleId or vehicleId <= 0 then
			vehicleId = gDeliveryTaskManager.TryGetDefaultSelectVehicle(orderSupportCfg) or functionId
		end

		local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj

		gNewGuideMgr:NotifySignal(EGuideSignal.DeliveryCallCar)
		gVehicleGamePlayManager.cs_manager:AskSummonVehicle(vehicleId, playerObj.position, playerObj.eulerAngles.y, function (isSuccess)
			local dialogId = isSuccess and orderSupportCfg.SuccessDialogId or orderSupportCfg.FailDialogId

			if dialogId and dialogId > 0 then
				gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Delivery)
			end

			gMainPhoneUtils.CloseMainPhonePanel(false)
		end)
	end
end

function M:OnOrderSupportItemDetailClick(id)
	local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.GetConfig(id)

	gDeliveryTaskManager.RunSupportDetailCallFunc(orderSupportCfg)
end

function M:OnControllerOrderSupportItemClick()
	if self.pressedSupportId then
		local id = self.pressedSupportId
		self.pressedSupportId = nil
		self.bindData.supportHoldRoot.activation = false
		self.bindData.supportListOpacity = 1

		self:OnOrderSupportItemClick(id)
	end
end

function M:OnAutoBtnClick()
	gDeliveryTaskManager:AskAutoAcceptTruckJobOrder(not gDeliveryTaskManager:CheckIsAuto())
end

function M:OnControllerOrderSupportItemDetailClick()
	if self.pressedSupportId then
		local id = self.pressedSupportId
		self.pressedSupportId = nil
		self.bindData.supportHoldRoot.activation = false
		self.bindData.supportListOpacity = 1

		self:OnOrderSupportItemDetailClick(id)
	end
end

function M:OnOrderSupportItemGamePadCustomPress(data, context)
	if self.gamepadMode then
		if context.performed then
			if not self.pressedSupportId then
				self.pressedSupportId = data.id
				self.bindData.supportHoldRoot.activation = true
				self.bindData.supportListOpacity = 0
				local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.GetConfig(data.id)

				if orderSupportCfg then
					local used = false

					if data.id == LTConfig.UberSimOrderSupportConfig.Drone then
						used = gDeliveryTaskManager.CheckHasDroneAgent()
					end

					self.bindData.controllerSupportText = used and orderSupportCfg.UsedStateText or orderSupportCfg.CanUseStateText
					self.bindData.controllerSupportIcon = used and orderSupportCfg.UsedStateIcon or orderSupportCfg.CanUseStateIconId
					self.bindData.controllerDetailText = orderSupportCfg.DetailText
				end

				self.bindData.takeOrderList:RefreshList()
			end
		elseif context.canceled and self.pressedSupportId == data.id then
			self.pressedSupportId = nil
			self.bindData.supportHoldRoot.activation = false
			self.bindData.supportListOpacity = 1

			self.bindData.takeOrderList:RefreshList()
		end
	else
		self.pressedSupportId = nil
	end
end

function M:OnTakeOrderListLayoutSet()
	if not self.refreshNav then
		return
	end

	self.refreshNav = not self.bindData.takeOrderList:SetNavSelectToTop(false)
end

function M:OnOrderClick()
	if self.customOrderData then
		return
	end

	local rootGo = self.rootGo

	gClientToGameDelegate:AskGetFinishedOrderWraps().Callback = function (errorId, clientFinishedTruckOrderView)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		if gClientUtils.IsNil(rootGo) then
			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
			secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.COMPLETE,
			clientFinishedTruckOrderView = clientFinishedTruckOrderView
		})
	end
end

function M:OnTakeOrderGetTIndex(index)
	local data = self.orderViewDataList[index + 1]

	return data and data.tIndex or 0
end

function M:OnTakeOrderRendererItem(btn, index)
	local data = self.orderViewDataList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex == self.Order_List_Template_Type.Refresh then
		self:RefreshListRefreshView(store, data)
	elseif data.tIndex == self.Order_List_Template_Type.Order then
		self:RefreshOrderView(store, index, data)
	end
end

function M:RefreshListRefreshView(store)
	store.button.luaClick = self:CreateActionWithArgs("OnRefreshClick", store)

	self:StartCountdownCo(store)
end

function M:OnRefreshClick(store)
	if self.customOrderData then
		return
	end

	if self.countDownTime > 0 then
		return
	end

	local rootGo = self.rootGo

	gClientToGameDelegate:AskRefreshTruckOrder().Callback = function (errorId, data)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		if gClientUtils.IsNil(rootGo) then
			return
		end

		store.refreshText = self.RefreshOrderTime
		self.takeOrderList = data.Orders

		self:RefreshTakeOrderListView()

		self.countDownTime = self.RefreshOrderTime

		self:StartCountdownCo(store)
	end
end

function M:StartCountdownCo(store)
	store.refreshText = LTConfig.TextScriptTextConfig.GetConfig(89901136).Text:format(self.countDownTime)
	self.countDownCo = coroutine.stop(self.countDownCo)
	self.countDownCo = coroutine.start(function ()
		while true do
			coroutine.wait(1)

			if self.countDownTime > 0 then
				self.countDownTime = self.countDownTime - 1
			end

			store.refreshText = LTConfig.TextScriptTextConfig.GetConfig(89901136).Text:format(self.countDownTime)
		end
	end)
end

function M:UpdateAcceptCountDown()
	if not self.lastRefreshTime or gLuaDataManager.serverTime - self.lastRefreshTime >= 1 then
		self.lastRefreshTime = gLuaDataManager.serverTime
		local needRefresh = true

		if self.orderViewDataList and #self.acceptCountDownIndex > 0 then
			for i = 1, #self.acceptCountDownIndex do
				local index = self.acceptCountDownIndex[i]
				local data = self.orderViewDataList[index + 1]

				if data then
					local time = data.truckJobOrderWrap.OrderInfo.LimitAcceptSeconds + data.truckJobOrderWrap.OrderInfoStartTime - gLuaDataManager.serverTime

					if time <= 0 then
						self:RefreshTakeOrderListView()

						needRefresh = false

						break
					end
				end
			end
		end

		if needRefresh then
			self.bindData.takeOrderList:RefreshList()
		end
	end
end

function M:RefreshOrderView(store, index, data)
	store.takeButton.luaClick = self:CreateActionWithArgs(self.OnTakeOrderClick, data.truckJobOrderWrap)
	local canTakeOrder, tookCount = self:CheckCanTakeOrder()
	local orderInfo = data.truckJobOrderWrap.OrderInfo
	store.money = orderInfo.DropMoney
	local randomGoodsCfg = LTConfig.UberSimRandomGoodsConfig.GetConfig(orderInfo.CargoId)

	if not randomGoodsCfg then
		print_error("@linminghe randomGoodsCfg is nil:", inspect(orderInfo))
	end

	store.name = randomGoodsCfg.information
	store.timeLimitControl = gDeliveryTaskManager.CheckIsSpecialOrder(randomGoodsCfg.Id) and not gDeliveryTaskManager.CheckIsUnlimitedTimeOrder(randomGoodsCfg.Id) and 1 or 0
	local disasterLevel = randomGoodsCfg.DisasterLevel or 0

	if disasterLevel > 0 then
		store.disasterLevelNode:SetActive(true)

		store.huneControl = randomGoodsCfg.DisasterLevel
	else
		store.disasterLevelNode:SetActive(false)
	end

	store.trunkControl = randomGoodsCfg.UnlockStage == 1 and 0 or 1

	if self.pressedSupportId then
		store.takeStateControl = self.Order_State_Control.Empty
	else
		store.takeStateControl = data.truckJobOrderWrap.AcceptInfo and self.Order_State_Control.Accept or tookCount > 0 and self.Order_State_Control.Empty or self.Order_State_Control.Take
	end

	local time = math.floor(orderInfo.EstimatedFinishSeconds / gClientConst.SECONDS_PER_MINUTE)
	store.time = LTConfig.TextScriptTextConfig.GetConfig(89900065).Text:format(time)
	store.giveUpButton.luaClick = self:CreateActionWithArgs(self.OnGiveUpClick, data.truckJobOrderWrap)
	store.highValueCtrl = data.truckJobOrderWrap.OrderInfo.IsHighValue and 1 or 0
	store.dailyCtrl = data.truckJobOrderWrap.OrderInfo.IsDailyOrder and 1 or 0
	local acceptTime = data.truckJobOrderWrap.OrderInfo.LimitAcceptSeconds
	local acceptBtnText = nil

	if acceptTime > 0 and acceptTime < 10000 then
		table.insert(self.acceptCountDownIndex, index)

		local acceptRemainTime = data.truckJobOrderWrap.OrderInfo.LimitAcceptSeconds + data.truckJobOrderWrap.OrderInfoStartTime - gLuaDataManager.serverTime
		acceptRemainTime = acceptRemainTime >= 0 and acceptRemainTime or 0
		acceptBtnText = string.format(LTConfig.TextScriptTextConfig.GetConfig(89901263).Text, acceptRemainTime)
	else
		acceptBtnText = LTConfig.TextScriptTextConfig.GetConfig(89901181).Text
	end

	local buttonText = canTakeOrder and acceptBtnText or LTConfig.TextScriptTextConfig.GetConfig(89901180).Text
	store.takeButtonText = buttonText

	gDeliveryTaskManager.RefreshOrderTagView(store, randomGoodsCfg.TagIconIdList)
	gDeliveryTaskManager.RefreshOrderLocationView(store, data.truckJobOrderWrap)
end

function M:OnGiveUpClick(truckJobOrderWrap)
	if self.customOrderData or not self.canInteract or gLuaDataManager.serverTime - self.lastClickTime < 1 then
		return
	end

	self.lastClickTime = gLuaDataManager.serverTime

	gDeliveryTaskManager:SetOrderObsolete(truckJobOrderWrap.UniqueId)

	self.canInteract = false

	gClientToGameDelegate:AskObsoleteTruckJobOrder(truckJobOrderWrap.UniqueId).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
			self:RefreshOrderByAskTakeOrGiveUpFail()

			return
		end
	end
end

function M:OnTakeOrderClick(truckJobOrderWrap)
	if not self.canInteract or gLuaDataManager.serverTime - self.lastClickTime < 1 then
		return
	end

	self.lastClickTime = gLuaDataManager.serverTime
	self.canInteract = false

	if self.customOrderData then
		gClientToGameDelegate:AskStartTruckOrderGuide().Callback = function (errorId)
			self.canInteract = true

			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end

		return
	end

	gClientToGameDelegate:AskAcceptTruckJobOrder(truckJobOrderWrap.UniqueId).Callback = function (errorId, callbackTruckJobOrderWrap, npcInstanceId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			self:RefreshOrderByAskTakeOrGiveUpFail()
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

function M:OnAcceptTruckJobOrder(_, truckJobOrderWrap)
	self.canInteract = true

	for _, takeTruckJobOrderWrap in ipairs(self.takeOrderList) do
		if takeTruckJobOrderWrap.UniqueId == truckJobOrderWrap.UniqueId then
			takeTruckJobOrderWrap.AcceptInfo = truckJobOrderWrap.AcceptInfo
		end
	end

	self.lastRefreshTime = gLuaDataManager.serverTime

	self.bindData.takeOrderList:RefreshList()
end

function M:OnExecuteExitAction()
	gMainPhoneUtils.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:ClearData()
	self.refreshTakeOderCo = coroutine.stop(self.refreshTakeOderCo)
	self.countDownCo = coroutine.stop(self.countDownCo)
	self.orderViewDataList = nil
	self.callFuncViewDataList = nil

	if self.refreshTimer then
		self.refreshTimer:Stop()

		self.refreshTimer = nil
	end
end

function M:CheckTeachTaskState()
	local teachEventId = LTConfig.UberSimConfig.TeachEventId
	local eventState = gTaskManager:GetTaskEventState(teachEventId)

	self.bindData.autoBtn:SetActive(eventState == UX.Game.TaskEventState.Submited)
end

function M:OnTakeOrderBeginDrag()
	self.dragCanRefreshOrder = false
	self.canRefreshOrder = self:CheckCanRefreshOrder()
end

function M:OnTakeOrderDrag()
	local offsetPosition = self.bindData.takeOrderList:GetVerticalOffsetPosition()
	self.dragCanRefreshOrder = offsetPosition > 100

	if self.dragCanRefreshOrder and self.canRefreshOrder then
		self.bindData.refreshTipsCtrl = self.Refresh_Tip_State_Control.Show
	else
		self.bindData.refreshTipsCtrl = self.Refresh_Tip_State_Control.Hide
	end
end

function M:OnTakeOrderEndDrag()
	if self.isInRefreshTimer then
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.Toofrequentoperation)
	elseif self.dragCanRefreshOrder and self.canRefreshOrder then
		self:RefreshOrderInternal()
	end
end

function M:OnRefreshBtnClick()
	if self.isInRefreshTimer then
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.Toofrequentoperation)
	elseif self:CheckCanRefreshOrder() then
		self:RefreshOrderInternal()
	end
end

function M:RefreshOrderInternal()
	if self.customOrderData then
		return
	end

	local rootGo = self.rootGo

	gClientToGameDelegate:AskRefreshTruckOrder().Callback = function (errorId, data)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		if gClientUtils.IsNil(rootGo) then
			return
		end

		self.takeOrderList = data.Orders

		self:RefreshTakeOrderListView()
	end

	self.isInRefreshTimer = true

	if self.refreshTimer then
		self.refreshTimer:Stop()
	end

	self.refreshTimer = Timer.New(function ()
		self.isInRefreshTimer = false
	end, self.RefreshOrderTime):Start()
end

function M:RefreshOrderByAskTakeOrGiveUpFail()
	gClientToGameDelegate:AskRefreshTruckOrder().Callback = function (errorId, data)
		self.canInteract = true

		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local rootGo = self.rootGo

		if gClientUtils.IsNil(rootGo) then
			return
		end

		self.takeOrderList = data.Orders

		self:RefreshTakeOrderListView()
	end
end
