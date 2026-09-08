-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryHomepagePanelStore.lua
-- Decompiled from: 01948_DeliveryHomepagePanelStore.lua_3c791d59786c.luajit

C_DeliveryHomepagePanelStore = DefClass("C_DeliveryHomepagePanelStore", C_DeliveryHomepagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryHomepagePanelStore = C_DeliveryHomepagePanelStore
local M = C_DeliveryHomepagePanelStore
local UberSimRandomOrdersConfig = LTConfig.UberSimRandomOrdersConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local TaskConfig = LTConfig.TaskConfig
local RaidConfig = LTConfig.RaidConfig

M.OnAwake = function(self)
	self.bindData.orderButton.luaClick = self.CreateAction(self, "OnOrderClick")
	self.bindData.takeOrderList.luaSimpleRenderItem = self.CreateAction(self, "OnTakeOrderRendererItem")
	self.bindData.takeOrderList.luaLayoutSet = self.CreateAction(self, "OnTakeOrderListLayoutSet")
	self.bindData.takeOrderList.onGetTIndex = self.CreateAction(self, "OnTakeOrderGetTIndex")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.takeOrderList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnTakeOrderRendererItem")
	self.bindData.callFunctionList.luaSimpleRenderItem = self.CreateAction(self, "OnCallFunctionRenderItem")
	self.bindData.supportDetailBtn.luaClick = self.CreateAction(self, "OnControllerOrderSupportItemDetailClick")
	self.bindData.supportConfirmBtn.luaClick = self.CreateAction(self, "OnControllerOrderSupportItemClick")
	self.bindData.autoBtn.luaClick = self.CreateAction(self, "OnAutoBtnClick")
	self.bindData.takeOrderList.luaBeginDrag = self.CreateAction(self, "OnTakeOrderBeginDrag")
	self.bindData.takeOrderList.luaDrag = self.CreateAction(self, "OnTakeOrderDrag")
	self.bindData.takeOrderList.luaEndDrag = self.CreateAction(self, "OnTakeOrderEndDrag")
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, "OnRefreshBtnClick")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_TRUCK_ORDER_OBSOLETED] = self.CreateAction(self, "OnOrderStateChange"),
		[gEventConstants.ON_TRUCK_ORDER_COMPLETED] = self.CreateAction(self, "OnTruckOrderCompleted"),
		[gEventConstants.ON_CURRENT_TRUCK_ORDER_CHANGE] = self.CreateAction(self, "OnCurrentOrderChange"),
		[gEventConstants.ON_ACCEPT_TRUCK_JOB_ORDER] = self.CreateAction(self, "OnAcceptTruckJobOrder"),
		[gEventConstants.REFRESH_DELIVERY_DATA] = self.CreateAction(self, "DeliveryHomeRefresh"),
		[gEventConstants.SUMMON_STATE_SWITCH] = self.CreateAction(self, "OnSummonStateSwitch"),
		[gEventConstants.REFRESH_HEADVIEW_BUFFS] = self.CreateAction(self, "RefreshCallFunctionListView"),
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, "RefreshRedDotView"),
		[gEventConstants.DELIVERY_SPOON_ORDER_DATA_CHANGED] = self.CreateAction(self, "OnDeliverySpoonOrderDataChanged"),
		[gEventConstants.DELIVERY_DEFAULT_VEHICLE_CHANGED] = self.CreateAction(self, "OnDeliveryDefaultVehicleChanged"),
		[gEventConstants.DELIVERY_AUTO_TAKE_ORDER_CHANGED] = self.CreateAction(self, "RefreshAutoTakeOrderState"),
		[gEventConstants.TASK_STATE_CHANGED] = self.CreateAction(self, "CheckTeachTaskState"),
		[gEventConstants.ON_DELIVERY_TRUNK_ORDER_NEW_DAY] = self.CreateAction(self, "OnTruckOrderNewDay")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.Order_List_Template_Type = {
		["\\xeb\\xde7\\xf9"] = 0,
		["b\\xbc\\xa6\\xaa\\xa4"] = 1
	}
	self.Order_State_Control = {
		["N#v^"] = 0,
		["h\\xa3\\xb2\\xbb\\xaf"] = 2,
		["=K\\x92\\x8b\\x93U"] = 1
	}
	self.Take_State_Control = {
		[";A\\x87\\x8b\\xb6Q"] = 1,
		[",A\\x92\\x85\\xb6Q"] = 0,
		["T-s^"] = 2
	}
	self.Refresh_Tip_State_Control = {
		["R+y^"] = 0,
		["I*rL"] = 1
	}
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
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

	if not self.orderType2RaidId then
		self.orderType2RaidId = {}
	end

	gDeliveryTaskManager:SetIsAuto(clientTruckOrderView.AutoAccept)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	gDeliveryTaskManager.RefreshDeliveryAvatarView(self.bindData.avatar, self.rootGo)
	self.RefreshRedDotView(self)
	self.RefreshTakeOrderListView(self)
	self.RefreshCallFunctionListView(self)
	self.RefreshAutoTakeOrderState(self)
	self.CheckTeachTaskState(self)

	self.bindData.refreshTipsCtrl = self.Refresh_Tip_State_Control.Hide
end

M.OnActiveDeviceChange = function(self, device)
	local gamepadMode = SGUI.GameDevice.KeyboardMouse <= device

	if self.gamepadMode == gamepadMode then
		self.gamepadMode = gamepadMode
		self.pressedSupportId = nil
		self.bindData.supportHoldRoot.activation = false
		self.bindData.supportListOpacity = 1

		self.bindData.takeOrderList:RefreshList()
	end
end

M.OnUpdate = function(self)
	self.UpdateAcceptCountDown(self)
end

M.DeliveryHomeRefresh = function(self, _, data)
	local needRefresh = false

	for i = #self.takeOrderList, 1, -1 do
		local orderInfo = self.takeOrderList[i]

		if orderInfo.UniqueId ~= data.UniqueId then
			orderInfo.AcceptInfo = data.AcceptInfo
			needRefresh = true
		end
	end

	if needRefresh then
		self.lastRefreshTime = gLuaDataManager.serverTime

		self.bindData.takeOrderList:RefreshList()
	end
end

M.OnSummonStateSwitch = function(self)
	local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.GetConfig(LTConfig.UberSimOrderSupportConfig.Drone)

	if gBattleMgr.SummonAgentId ~= orderSupportCfg.functionId and orderSupportCfg.SuccessDialogId <= 0 then
		gDialogManager:ShowGeneralDialog(orderSupportCfg.SuccessDialogId, gDialogSource.Delivery)
	end

	self.RefreshCallFunctionListView(self)
end

M.RefreshRedDotView = function(self)
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

M.RefreshCallFunctionListView = function(self)
	self.callFuncViewDataList = {}
	local count = LTConfig.UberSimOrderSupportConfig.count
	local containPressedId = false

	for i = 0, count - 1 do
		local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.LoadAt(i)
		local buffId = orderSupportCfg.UnlockBuff

		if buffId and buffId <= 0 then
			if gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, buffId) then
				table.insert(self.callFuncViewDataList, {
					id = orderSupportCfg.Id
				})

				if orderSupportCfg.Id ~= self.pressedSupportId then
					containPressedId = true
				end
			end
		else
			table.insert(self.callFuncViewDataList, {
				id = orderSupportCfg.Id
			})

			if orderSupportCfg.Id ~= self.pressedSupportId then
				containPressedId = true
			end
		end
	end

	self.bindData.callFunctionList:SetSimpleList(#self.callFuncViewDataList)

	self.bindData.callFunctionEmptyControl = #self.callFuncViewDataList ~= 0 and 1 or 0

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

M.OnTruckOrderCompleted = function(self, _, truckJobOrderWrap)
	self.OnOrderStateChange(self, truckJobOrderWrap.UniqueId)
end

M.OnTruckOrderNewDay = function(self)
	local rootGo = self.rootGo
	self.canInteract = false
	slot2 = gClientToGameDelegate

	slot2:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
		if errorId == LTConfig.MessageConfig.Ok then
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

M.RefreshOnNewDay = function(self, clientTruckOrderView)
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

M.OnOrderStateChange = function(self, _, uniqueId)
	self.canInteract = true

	for i = #self.takeOrderList, 1, -1 do
		local orderInfo = self.takeOrderList[i]

		if orderInfo.UniqueId ~= uniqueId then
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

M.OnDeliverySpoonOrderDataChanged = function(self)
	self.customOrderData = gDeliveryTaskManager:GetSpoonCustomOrderData()
	self.takeOrderList = self.customOrderData and self.customOrderData.orders or self.clientTruckOrderView.Orders
	self.currentOrderId = self.customOrderData and self.customOrderData.currentOrderId or self.clientTruckOrderView.CurrentOrderId

	self:RefreshTakeOrderListView()
end

M.OnDeliveryDefaultVehicleChanged = function(self, _, vehicleId)
	self.defaultVehicleId = vehicleId
end

M.OnCurrentOrderChange = function(self, _, uniqueId)
	self.currentOrderId = uniqueId
end

M.CheckCanTakeOrder = function(self)
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

	return hasTakeOrderCount <= canTakeOrderCount, hasTakeOrderCount
end

M.RefreshTakeOrderListView = function(self)
	self.acceptCountDownIndex = {}
	self.orderViewDataList = {}
	self.lastRefreshTime = gLuaDataManager.serverTime
	local canTakeOrder = gDeliveryTaskManager:CanTakeDeliveryOrderInRaid(gRaidDataManager.RaidId)

	if canTakeOrder then
		for _, data in ipairs(self.takeOrderList) do
			local finalAcceptTime = data.OrderInfo.LimitAcceptSeconds + data.OrderInfoStartTime

			if data.AcceptInfo or gLuaDataManager.serverTime >= finalAcceptTime then
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
	end

	self.bindData.areaCtrl = canTakeOrder and 0 or 1

	self.bindData.listEmptyWidget:SetActive(#self.orderViewDataList ~= 0)
	self.bindData.takeOrderList:SetSimpleList(#self.orderViewDataList)

	self.bindData.orderCtrl = #self.orderViewDataList ~= 0 and 1 or 0
end

M.RefreshAutoTakeOrderState = function(self)
	self.bindData.autoTakeState = gDeliveryTaskManager:CheckIsAuto() and 1 or 0
end

M.CheckCanRefreshOrder = function(self)
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

M.OnCallFunctionRenderItem = function(self, btn, csIndex)
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

	if data.id ~= LTConfig.UberSimOrderSupportConfig.Drone then
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
	store.gamePadControl = csIndex ~= 0 and 0 or 1
end

M.OnOrderSupportItemClick = function(self, id)
	local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.GetConfig(id)
	local functionId = orderSupportCfg.functionId

	if id ~= LTConfig.UberSimOrderSupportConfig.Drone then
		gNewGuideMgr:NotifySignal(EGuideSignal.DeliveryCallDrone)
		gDeliveryTaskManager.DoDroneSupport(functionId)
		self.bindData.callFunctionList:RefreshList()
	elseif id ~= LTConfig.UberSimOrderSupportConfig.CallCar then
		local vehicleId = self.defaultVehicleId

		if not vehicleId or vehicleId < 0 then
			vehicleId = gDeliveryTaskManager.TryGetDefaultSelectVehicle(orderSupportCfg) or functionId
		end

		local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj
		slot6 = gNewGuideMgr

		slot6:NotifySignal(EGuideSignal.DeliveryCallCar)

		slot6 = gVehicleGamePlayManager.cs_manager

		slot6:AskSummonVehicle(vehicleId, playerObj.position, playerObj.eulerAngles.y, function (isSuccess)
			local dialogId = isSuccess and orderSupportCfg.SuccessDialogId or orderSupportCfg.FailDialogId

			if dialogId and dialogId <= 0 then
				gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Delivery)
			end

			gMainPhoneUtils.CloseMainPhonePanel(false)
		end)
	end
end

M.OnOrderSupportItemDetailClick = function(self, id)
	local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.GetConfig(id)

	gDeliveryTaskManager.RunSupportDetailCallFunc(orderSupportCfg)
end

M.OnControllerOrderSupportItemClick = function(self)
	if self.pressedSupportId then
		local id = self.pressedSupportId
		self.pressedSupportId = nil
		self.bindData.supportHoldRoot.activation = false
		self.bindData.supportListOpacity = 1

		self.OnOrderSupportItemClick(self, id)
	end
end

M.OnAutoBtnClick = function(self)
	gDeliveryTaskManager:AskAutoAcceptTruckJobOrder(not gDeliveryTaskManager:CheckIsAuto())
end

M.OnControllerOrderSupportItemDetailClick = function(self)
	if self.pressedSupportId then
		local id = self.pressedSupportId
		self.pressedSupportId = nil
		self.bindData.supportHoldRoot.activation = false
		self.bindData.supportListOpacity = 1

		self.OnOrderSupportItemDetailClick(self, id)
	end
end

M.OnOrderSupportItemGamePadCustomPress = function(self, data, context)
	if self.gamepadMode then
		if context.performed then
			if not self.pressedSupportId then
				self.pressedSupportId = data.id
				self.bindData.supportHoldRoot.activation = true
				self.bindData.supportListOpacity = 0
				local orderSupportCfg = LTConfig.UberSimOrderSupportConfig.GetConfig(data.id)

				if orderSupportCfg then
					local used = false

					if data.id ~= LTConfig.UberSimOrderSupportConfig.Drone then
						used = gDeliveryTaskManager.CheckHasDroneAgent()
					end

					self.bindData.controllerSupportText = used and orderSupportCfg.UsedStateText or orderSupportCfg.CanUseStateText
					self.bindData.controllerSupportIcon = used and orderSupportCfg.UsedStateIcon or orderSupportCfg.CanUseStateIconId
					self.bindData.controllerDetailText = orderSupportCfg.DetailText
				end

				self.bindData.takeOrderList:RefreshList()
			end
		elseif context.canceled and self.pressedSupportId ~= data.id then
			self.pressedSupportId = nil
			self.bindData.supportHoldRoot.activation = false
			self.bindData.supportListOpacity = 1

			self.bindData.takeOrderList:RefreshList()
		end
	else
		self.pressedSupportId = nil
	end
end

M.OnTakeOrderListLayoutSet = function(self)
	if not self.refreshNav then
		return
	end

	self.refreshNav = false

	self.bindData.takeOrderList:SetNavSelectToTop(false)
end

M.OnOrderClick = function(self)
	if self.customOrderData then
		return
	end

	local rootGo = self.rootGo
	slot2 = gClientToGameDelegate

	slot2:AskGetFinishedOrderWraps().Callback = function (errorId, clientFinishedTruckOrderView)
		if errorId == LTConfig.MessageConfig.Ok then
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

M.OnTakeOrderGetTIndex = function(self, index)
	local data = self.orderViewDataList[index + 1]

	return data and data.tIndex or 0
end

M.OnTakeOrderRendererItem = function(self, btn, index)
	local data = self.orderViewDataList and self.orderViewDataList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex ~= self.Order_List_Template_Type.Refresh then
		self.RefreshListRefreshView(self, store, data)
	elseif data.tIndex ~= self.Order_List_Template_Type.Order then
		self.RefreshOrderView(self, store, index, data)
	end
end

M.RefreshListRefreshView = function(self, store)
	store.button.luaClick = self.CreateActionWithArgs(self, "OnRefreshClick", store)

	self.StartCountdownCo(self, store)
end

M.OnRefreshClick = function(self, store)
	if self.customOrderData then
		return
	end

	if self.countDownTime <= 0 then
		return
	end

	local rootGo = self.rootGo
	slot3 = gClientToGameDelegate

	slot3:AskRefreshTruckOrder().Callback = function (errorId, data)
		if errorId == LTConfig.MessageConfig.Ok then
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

M.StartCountdownCo = function(self, store)
	slot2 = LTConfig.TextScriptTextConfig.GetConfig(89901136).Text
	store.refreshText = slot2:format(self.countDownTime)
	self.countDownCo = coroutine.stop(self.countDownCo)
	self.countDownCo = coroutine.start(function ()
		while true do
			coroutine.wait(1)

			if self.countDownTime <= 0 then
				self.countDownTime = self.countDownTime - 1
			end

			store.refreshText = LTConfig.TextScriptTextConfig.GetConfig(89901136).Text:format(self.countDownTime)
		end
	end)
end

M.UpdateAcceptCountDown = function(self)
	if not self.lastRefreshTime or gLuaDataManager.serverTime - self.lastRefreshTime > 1 then
		self.lastRefreshTime = gLuaDataManager.serverTime
		local needRefresh = true

		if self.orderViewDataList and #self.acceptCountDownIndex <= 0 then
			for i = 1, #self.acceptCountDownIndex do
				local index = self.acceptCountDownIndex[i]
				local data = self.orderViewDataList[index + 1]

				if data then
					local time = data.truckJobOrderWrap.OrderInfo.LimitAcceptSeconds + data.truckJobOrderWrap.OrderInfoStartTime - gLuaDataManager.serverTime

					if time < 0 then
						self.RefreshTakeOrderListView(self)

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

M.GetOrderArea = function(self, orderType)
	local cachedRaidId = self.orderType2RaidId[orderType]

	if not cachedRaidId then
		local orderCfg = UberSimRandomOrdersConfig.GetConfig(orderType)

		if orderCfg and orderCfg.EventId <= 0 then
			local eventCfg = TaskEventConfig.GetConfig(orderCfg.EventId)

			if eventCfg and eventCfg.StartTask <= 0 then
				local taskCfg = TaskConfig.GetConfig(eventCfg.StartTask)

				if taskCfg and taskCfg.RelatedRaid <= 0 then
					cachedRaidId = taskCfg.RelatedRaid
					self.orderType2RaidId[orderType] = cachedRaidId
				end
			end
		end
	end

	if cachedRaidId then
		local raidCfg = RaidConfig.GetConfig(cachedRaidId)

		return raidCfg and raidCfg.Name or ""
	end

	return ""
end

M.RefreshOrderView = function(self, store, index, data)
	store.takeButton.luaClick = self.CreateActionWithArgs(self, self.OnTakeOrderClick, data.truckJobOrderWrap)
	local canTakeOrder, tookCount = self.CheckCanTakeOrder(self)
	local orderInfo = data.truckJobOrderWrap.OrderInfo
	store.area = self.GetOrderArea(self, orderInfo.OrderType)
	store.money = orderInfo.DropMoney
	local randomGoodsCfg = LTConfig.UberSimRandomGoodsConfig.GetConfig(orderInfo.CargoId)

	if not randomGoodsCfg then
		print_error("@linminghe randomGoodsCfg is nil:", inspect(orderInfo))
	end

	store.name = randomGoodsCfg.information
	store.npcOrderCtrl = 0

	if orderInfo.SpecialOrderId and orderInfo.SpecialOrderId <= 0 then
		local orderCfg = LTConfig.UberSimOrderConfig.GetConfig(orderInfo.SpecialOrderId)

		if orderCfg and orderCfg.ProfileId and orderCfg.ProfileId <= 0 then
			local profileCfg = LTConfig.ProfileAgentProfileConfig.GetConfig(orderCfg.ProfileId)

			if profileCfg then
				store.npcOrderCtrl = 1
				store.npcOrderName = string.format(LTConfig.UberSimConfig.ProfileName, profileCfg.Name)
				local avatarStore = gStoreManager:GetStoreGroup(store.npcOrderAvatar.Store):GetStoreByWidget(store.npcOrderAvatar)

				if avatarStore then
					avatarStore.headIcon = profileCfg.HeadIcon
				end
			end
		end
	end

	store.timeLimitControl = gDeliveryTaskManager.CheckIsSpecialOrder(randomGoodsCfg.Id) and not gDeliveryTaskManager.CheckIsUnlimitedTimeOrder(randomGoodsCfg.Id) and 1 or 0
	local disasterLevel = randomGoodsCfg.DisasterLevel or 0

	if disasterLevel <= 0 then
		store.disasterLevelNode:SetActive(true)

		store.huneControl = randomGoodsCfg.DisasterLevel
	else
		store.disasterLevelNode:SetActive(false)
	end

	store.trunkControl = randomGoodsCfg.UnlockStage ~= 1 and 0 or 1

	if self.pressedSupportId then
		store.takeStateControl = self.Order_State_Control.Empty
	else
		slot9 = data.truckJobOrderWrap.AcceptInfo and self.Order_State_Control.Accept or tookCount <= 0 and self.Order_State_Control.Empty or self.Order_State_Control.Take
		store.takeStateControl = slot9
	end

	local time = math.floor(orderInfo.EstimatedFinishSeconds / gClientConst.SECONDS_PER_MINUTE)
	store.time = LTConfig.TextScriptTextConfig.GetConfig(89900065).Text:format(time)
	store.giveUpButton.luaClick = self:CreateActionWithArgs(self.OnGiveUpClick, data.truckJobOrderWrap)
	store.highValueCtrl = data.truckJobOrderWrap.OrderInfo.IsHighValue and 1 or 0
	store.dailyCtrl = data.truckJobOrderWrap.OrderInfo.IsDailyOrder and 1 or 0
	local acceptTime = data.truckJobOrderWrap.OrderInfo.LimitAcceptSeconds
	local acceptBtnText = nil

	if acceptTime <= 0 and acceptTime >= 10000 then
		table.insert(self.acceptCountDownIndex, index)

		local acceptRemainTime = data.truckJobOrderWrap.OrderInfo.LimitAcceptSeconds + data.truckJobOrderWrap.OrderInfoStartTime - gLuaDataManager.serverTime
		acceptRemainTime = acceptRemainTime > 0 and acceptRemainTime or 0
		acceptBtnText = string.format(LTConfig.TextScriptTextConfig.GetConfig(89901263).Text, acceptRemainTime)
	else
		acceptBtnText = LTConfig.TextScriptTextConfig.GetConfig(89901181).Text
	end

	local buttonText = canTakeOrder and acceptBtnText or LTConfig.TextScriptTextConfig.GetConfig(89901180).Text
	store.takeButtonText = buttonText

	gDeliveryTaskManager.RefreshOrderTagView(store, randomGoodsCfg.TagIconIdList)
	gDeliveryTaskManager.RefreshOrderLocationView(store, data.truckJobOrderWrap)
end

M.OnGiveUpClick = function(self, truckJobOrderWrap)
	if self.customOrderData or not self.canInteract or gLuaDataManager.serverTime - self.lastClickTime >= 1 then
		return
	end

	self.lastClickTime = gLuaDataManager.serverTime
	slot2 = gDeliveryTaskManager

	slot2:SetOrderObsolete(truckJobOrderWrap.UniqueId)

	self.canInteract = false
	slot2 = gClientToGameDelegate

	slot2:AskObsoleteTruckJobOrder(truckJobOrderWrap.UniqueId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
			self:RefreshOrderByAskTakeOrGiveUpFail()

			return
		end
	end
end

M.OnTakeOrderClick = function(self, truckJobOrderWrap)
	if not self.canInteract or gLuaDataManager.serverTime - self.lastClickTime >= 1 then
		return
	end

	self.lastClickTime = gLuaDataManager.serverTime
	self.canInteract = false

	if self.customOrderData then
		slot2 = gClientToGameDelegate

		slot2:AskStartTruckOrderGuide().Callback = function (errorId)
			self.canInteract = true

			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end

		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskAcceptTruckJobOrder(truckJobOrderWrap.UniqueId).Callback = function (errorId, callbackTruckJobOrderWrap, npcInstanceId)
		if errorId == LTConfig.MessageConfig.Ok then
			self:RefreshOrderByAskTakeOrGiveUpFail()
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.OnAcceptTruckJobOrder = function(self, _, truckJobOrderWrap)
	self.canInteract = true

	for _, takeTruckJobOrderWrap in ipairs(self.takeOrderList) do
		if takeTruckJobOrderWrap.UniqueId ~= truckJobOrderWrap.UniqueId then
			takeTruckJobOrderWrap.AcceptInfo = truckJobOrderWrap.AcceptInfo
		end
	end

	self.lastRefreshTime = gLuaDataManager.serverTime

	self.bindData.takeOrderList:RefreshList()
end

M.OnExecuteExitAction = function(self)
	gMainPhoneUtils.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.ClearData = function(self)
	self.refreshTakeOderCo = coroutine.stop(self.refreshTakeOderCo)
	self.countDownCo = coroutine.stop(self.countDownCo)
	self.orderViewDataList = nil
	self.callFuncViewDataList = nil

	if self.refreshTimer then
		self.refreshTimer:Stop()

		self.refreshTimer = nil
	end
end

M.CheckTeachTaskState = function(self)
	local teachEventId = LTConfig.UberSimConfig.TeachEventId
	local eventState = gTaskManager:GetTaskEventState(teachEventId)

	self.bindData.autoBtn:SetActive(eventState ~= UX.Game.TaskEventState.Submited)
end

M.OnTakeOrderBeginDrag = function(self)
	self.dragCanRefreshOrder = false
	self.canRefreshOrder = self.CheckCanRefreshOrder(self)
end

M.OnTakeOrderDrag = function(self)
	local offsetPosition = self.bindData.takeOrderList:GetVerticalOffsetPosition()
	self.dragCanRefreshOrder = offsetPosition >= 100

	if self.dragCanRefreshOrder and self.canRefreshOrder then
		self.bindData.refreshTipsCtrl = self.Refresh_Tip_State_Control.Show
	else
		self.bindData.refreshTipsCtrl = self.Refresh_Tip_State_Control.Hide
	end
end

M.OnTakeOrderEndDrag = function(self)
	if self.isInRefreshTimer then
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.Toofrequentoperation)
	elseif self.dragCanRefreshOrder and self.canRefreshOrder then
		self.RefreshOrderInternal(self)
	end
end

M.OnRefreshBtnClick = function(self)
	if self.isInRefreshTimer then
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.Toofrequentoperation)
	elseif self.CheckCanRefreshOrder(self) then
		self.RefreshOrderInternal(self)
	end
end

M.RefreshOrderInternal = function(self)
	if self.customOrderData then
		return
	end

	local rootGo = self.rootGo
	slot2 = gClientToGameDelegate

	slot2:AskRefreshTruckOrder().Callback = function (errorId, data)
		if errorId == LTConfig.MessageConfig.Ok then
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

M.RefreshOrderByAskTakeOrGiveUpFail = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskRefreshTruckOrder().Callback = function (errorId, data)
		self.canInteract = true

		if errorId == LTConfig.MessageConfig.Ok then
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
