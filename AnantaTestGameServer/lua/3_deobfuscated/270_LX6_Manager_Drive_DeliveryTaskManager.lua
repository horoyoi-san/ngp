C_DeliveryTaskManager = DefClass("C_DeliveryTaskManager", C_DeliveryTaskManager)
local ScriptBattleUnit = require("LX6/Utils/FormulaScriptBattleUnit")
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local UberSimConfig = LTConfig.UberSimConfig
local RandomGoodsConfig = LTConfig.UberSimRandomGoodsConfig
local DestructibleConfig = LTConfig.DestructibleConfig
local DestructibleManager = LX6.Item.DestructibleMgr
local MessageConfig = LTConfig.MessageConfig
local M = C_DeliveryTaskManager
local DeliveryJobId = LTConfig.UrbanJobJobClassConfig.Delivery
local EXP = 1e-05
local timeBuff = 52959496

function M:Init()
	self.tIndex = 0
	self.isUpdate = false
	self.finishTime = 0
	self.isEventRegister = false
	self.orderList = {}
	self.lastDialogTime = 0
	self.curEvent = 0
	self.updateAngleTime = 1
	self.continueSpeedTime = 0
	self.checkSpeedTime = 1
end

function M:ctor()
	self:Init()

	self.pickUpPos = {}
	self.deliveryPos = {}
	self.isInTeachingTask = false
	self.TitleType = {
		WaitOrderText = 1,
		PickUpOrderText = 2,
		highOrderText = 5,
		SendOrderText = 4,
		LoseStateText = 3
	}

	self:InitConfigData()

	self.isAuto = false
	self.CargoType = {
		special = 1,
		normal = 0
	}
	self.CargoState = {
		NoPickUp = 0,
		SeriousDamage = 4,
		Intact = 1,
		Lose = 5,
		Finish = 6,
		ModerateDamage = 3,
		SlightDamage = 2
	}
	self.curTitleType = 1
	self.msgEvents = {
		[gEventConstants.ON_GOOD_OPEN_INTEGRITY_PLANE] = function (_, data)
			self:ChangePanelOpen(data.isOpen, data)
		end,
		[gEventConstants.ON_GOODS_TASK_FINISH] = function (_, data)
			self:SaveDeliveryHistoryInfo(data)
		end,
		[gEventConstants.ON_ACCEPT_TRUCK_JOB_ORDER] = function (_, data)
			self:AddOrderInfo(data)
		end,
		[gEventConstants.DESTRUCTIBLE_EVENT] = function (_, data)
			self:DestructibleByTag(data)
		end,
		[gEventConstants.ON_TRUCK_ORDER_OBSOLETED] = function (_, data)
			self:RemoveTruckOrder(data, true)
		end,
		[gEventConstants.BEFORE_SWITCH_SCENE] = function (_, data)
			self:BeforeSwitchScene(data)
		end,
		[gEventConstants.AFTER_SWITCH_SCENE] = function (_, data)
			self:OnAfterSwitchScene(data)
		end,
		[gEventConstants.LANGUAGE_CHANGE] = function (_, data)
			self:InitConfigData()
		end
	}

	gMessageManager:AddMessageListener(gEventConstants.JOB_CHANGE_EVENT, function (_, data)
		if data == nil then
			gCoroutineManager:StartCoroutine(function ()
				while gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene do
					coroutine.yield(nil)
				end

				data = gSpiritJobManager.GetCurSpiritJobClassId()

				self:OnJobStateChange(data, false)
			end)
		else
			local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(data)
			local jobClassId = urbanJobCfg and urbanJobCfg.JobClass or 0

			self:OnJobStateChange(jobClassId, true)
		end
	end)
	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, function (_, data)
		self:OnChangeSpirit(data)
	end)

	self.isRegister = false
end

function M:BeforeSwitchScene(switchType)
	if gSwitchSceneType.Reconnect < switchType then
		self:ExitOrderMode()

		gDeliveryTaskManager.guideHasTakeOrder = false
		self.isInTeachingTask = false
	end
end

function M:SetGuideHasTakeOrder(guideHasTakeOrder)
	self.guideHasTakeOrder = guideHasTakeOrder
end

function M:AddTruckNpcGpsHelper(taskId, gpsNameSourceType, sIconId, gpsName)
	local eventId = gTaskNodeManager:GetTaskLineByTask(taskId).TaskLineId
	local info = self:GetOrderByEventId(eventId)

	if info == nil or info.npcInstanceId == nil then
		print_error("truck info : ", eventId, self.orderList)

		return
	end

	local gpsLText = nil

	if gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.CargoPickup or gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.CargoTarget or gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.Cargo then
		if gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.CargoPickup then
			gpsLText = GpsLText.CreateCargoPickupText(eventId)
		elseif gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.CargoTarget then
			gpsLText = GpsLText.CreateCargoDeliveryText(eventId)
		else
			gpsLText = GpsLText.CreateCargoText(eventId)
		end
	else
		gpsLText = GpsLText.CreateString(gpsName)
	end

	local params = {
		sIconId = sIconId,
		gpsLText = gpsLText,
		visibleOnBigMap = true,
		showVehicleNav = true,
		taskId = taskId
	}

	gMapSubSystem_TaskGps:AddDynamicGpsElement("spoonGpsTruckGoalNPC", {
		unitPid = info.npcInstanceId
	}, params)
end

function M:AddTruckNpcGps(taskId, gpsNameSourceType, sIconId, gpsName)
	gCoroutineManager:StartCoroutine(function ()
		while gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene do
			coroutine.yield(nil)
		end

		self:AddTruckNpcGpsHelper(taskId, gpsNameSourceType, sIconId, gpsName)
	end)
end

function M:OnAfterSwitchScene(switchType)
	if switchType == gSwitchSceneType.NewScene or switchType == gSwitchSceneType.Image or switchType == gSwitchSceneType.Reconnect then
		local jobClassId = gSpiritJobManager.GetCurSpiritJobClassId()

		self:OnJobStateChange(jobClassId, false, true)

		if self.isDeliveryJob then
			gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end

				if not clientTruckOrderView or not clientTruckOrderView.Orders then
					return
				end

				for i = 1, #clientTruckOrderView.Orders do
					local orderInfo = clientTruckOrderView.Orders[i]

					if orderInfo.AcceptInfo ~= nil and orderInfo.ResultInfo == nil and self:GetOrderByUniqueId(orderInfo.UniqueId) == nil then
						self:AddOrderInfo(orderInfo)
					end
				end
			end
		end
	end
end

function M:GetOrderByUniqueId(uniqueId)
	for _, v in pairs(self.orderList) do
		if v.UniqueId == uniqueId then
			return v
		end
	end
end

function M:GetOrderToDrone()
	local order = self.orderList[1]
	local orderInfo = {}

	if order then
		table.insert(orderInfo, order.npcInstanceId)

		for _, cargo in pairs(order.cargoInfoList) do
			table.insert(orderInfo, cargo.instanceId)
		end
	end

	return orderInfo
end

function M:CheckCargoState(instanceId)
	for _, order in pairs(self.orderList) do
		for _, cargo in pairs(order.cargoInfoList) do
			if cargo.instanceId == instanceId then
				local sceneItem = gCS.SceneItemMgr:GetSceneItemHold(instanceId)
				local unit = gCS.SceneDataMgr.GetUnit(order.npcInstanceId)

				if sceneItem and unit then
					return self.LoseDistancePara.para1 * (unit.LocalPosition.x - sceneItem.objPosition.x) * (unit.LocalPosition.x - sceneItem.objPosition.x) + self.LoseDistancePara.para2 * (unit.LocalPosition.y - sceneItem.objPosition.y) * (unit.LocalPosition.y - sceneItem.objPosition.y) + self.LoseDistancePara.para3 * (unit.LocalPosition.z - sceneItem.objPosition.z) * (unit.LocalPosition.z - sceneItem.objPosition.z) > self.LoseDistance * self.LoseDistance
				end
			end
		end
	end

	return false
end

function M:CompleteTruckOrder(data, preRank, nowRank, rewardPoint)
	local currentJobInfo, levelCfg, cfg = self:GetDeliveryJobInfo()
	local order = self:GetOrderByUniqueId(data.UniqueId)

	self:ShowOrderFinishPanel({
		data = data,
		preRank = preRank,
		nowRank = nowRank,
		rewardPoint = rewardPoint,
		spiritJob = currentJobInfo,
		levelCfg = levelCfg,
		cfg = cfg,
		drop = order and order.drop
	})
	self:RemoveTruckOrder(data.UniqueId, false)
end

function M:SetTruckJobDrop(RewardInfo)
	local reward = RewardInfo.Reward
	local extraInfo = RewardInfo.ExtraInfo
	local fineMoney = 0
	local jobExpInfo = 0

	for _, rewardDetail in pairs(reward) do
		fineMoney = fineMoney + rewardDetail.Money

		if rewardDetail.JobExpInfo and rewardDetail.JobExpInfo[LTConfig.UrbanJobJobClassConfig.Delivery] then
			jobExpInfo = rewardDetail.JobExpInfo[LTConfig.UrbanJobJobClassConfig.Delivery]
		end
	end

	if extraInfo ~= nil then
		local order = self:GetOrderByUniqueId(self:GetCurOrderId())

		if order ~= nil then
			order.drop = {
				fineMoney = fineMoney,
				jobExpInfo = jobExpInfo
			}
		end
	end
end

function M:InitConfigData()
	self.GoodsFarthestDistance = UberSimConfig.GoodsFarthestDistance
	self.PackupTxt = UberSimConfig.PackupTxt
	self.PackupAgainTxt = UberSimConfig.PackupAgainTxt
	self.IntegrityRungsChangeTxt = UberSimConfig.IntegrityRungsChangeTxt
	self.HaveMaxTimeTxt = UberSimConfig.HaveMaxTimeTxt
	self.WhenJobStartTxt = UberSimConfig.WhenJobStartTxt
	self.TimeoutTxt = UberSimConfig.TimeoutTxt
	self.ResidentActivityTxt1 = UberSimConfig.ResidentActivityTxt1
	self.ResidentActivityTxt2 = UberSimConfig.ResidentActivityTxt2
	self.QuickPickup = UberSimConfig.QuickPickup
	self.ContinueTime1 = UberSimConfig.ContinueTime1
	self.ContinueTime2 = UberSimConfig.ContinueTime2
	self.ContinueTime3 = UberSimConfig.ContinueTime3
	self.ContinueTriggerSpeed = UberSimConfig.ContinueTriggerSpeed
	self.InclineBadge = UberSimConfig.InclineBadge
	self.TemparatureBadge = UberSimConfig.TemparatureBadge
	self.IntactSectionDescription = UberSimConfig.IntactSectionDescription
	self.dialogCd = UberSimConfig.DialogCD
	self.TitleMap = {
		[self.TitleType.WaitOrderText] = UberSimConfig.TruckStateDescribe1,
		[self.TitleType.PickUpOrderText] = UberSimConfig.TruckStateDescribe2,
		[self.TitleType.LoseStateText] = UberSimConfig.TruckStateDescribe3,
		[self.TitleType.SendOrderText] = UberSimConfig.TruckStateDescribe4
	}
	self.HighOrderText = UberSimConfig.TruckStateDescribe5
	self.LoseDistance = UberSimConfig.LoseDistance
	self.LoseDistancePara = UberSimConfig.LoseDistancePara
end

function M:OnChangeSpirit(data)
	local spirit = gSpiritManager:GetSpirit(data)

	if spirit == nil then
		return
	end

	local jobId = spirit.SpiritInfo.SpiritJobInfo.CurrentJob
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
	local jobClassId = urbanJobCfg and urbanJobCfg.JobClass or 0

	self:OnJobStateChange(jobClassId, false)
end

function M:PlayDialog(str, param)
	if self.dialogCd < gCS.TimeManager.ServerUnixTime - self.lastDialogTime then
		self.lastDialogTime = gCS.TimeManager.ServerUnixTime

		gDialogManager:ShowGeneralDialog(str, gDialogSource.Delivery, nil, param)
	end
end

function M:PlayRandomDialog(strList)
	local maxCount = #strList

	math.randomseed(os.time())

	local randomIndex = math.random(1, maxCount)

	self:PlayDialog(strList[randomIndex])
end

function M:OnJobStateChange(data, isShowDialog, isOnlyOpenPanel, isGuide)
	if data == DeliveryJobId then
		if not self.isDeliveryJob and isShowDialog then
			self:PlayRandomDialog(self.WhenJobStartTxt)
		end

		self:InitConfigData()

		if not self.isDeliveryJob or isOnlyOpenPanel then
			self.isDeliveryJob = true

			gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Delivery, {
				isOnlyOpenPanel = isOnlyOpenPanel,
				isGuide = isGuide
			})
		end

		if self.isDeliveryJob and isGuide then
			gMessageManager:SendMessage(gEventConstants.DELIVERY_GUIDE_HUD)
		end

		self:RegisterMessages()
	else
		self:UnRegisterMessages()

		if self.isDeliveryJob then
			gTaskUtils:HandleTaskGuideClose()
			gTaskUtils.TryShowNewestMainTaskGuide()
		end

		self.isDeliveryJob = false

		self:ExitOrderMode()
	end
end

function M:CloseCountDownPanel()
	gMessageManager:SendMessage(gEventConstants.ON_GOOD_COUNT_DOWN_FINISH)
end

function M:SendDropItemEvent()
	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.State.CurIsInteractDestruction then
		gCS.BaseUnitModuleUtils.LogicStateSendWorldEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.WorldEventType.AbortItem)
	end
end

function M:SetOrderObsolete(orderId)
	for _, v in pairs(self.orderList) do
		if v.UniqueId == orderId then
			v.isClientObsolete = true
		end
	end
end

function M:ChangeDeliveryPanelTitle(titleId)
	self.curTitleType = titleId

	gMessageManager:SendMessage(gEventConstants.DELIVERY_STATE_EVENT, {
		title = self.TitleMap[titleId]
	})
end

function M:RefreshStoreText()
	gMessageManager:SendMessage(gEventConstants.DELIVERY_STATE_EVENT, {
		title = self.TitleMap[self.curTitleType]
	})
end

function M:FinishOrderByEvent(eventId, abortedOrder)
	for index, v in pairs(self.orderList) do
		if v.AcceptedEventId == eventId then
			if v.cargoInfoList ~= nil then
				for _, cargoInfo in pairs(v.cargoInfoList) do
					if cargoInfo.instanceId and gCS.LuaUtils.CheckCargoDestructible(cargoInfo.instanceId, gCS.MyPlayerManager.PlayerUnit) then
						self:SendDropItemEvent()
					end
				end
			end

			if abortedOrder and not v.isClientObsolete then
				self:PlayDialog(self.TimeoutTxt)
			end

			self:RemoveOrderNpcBtn(v)
			self:CloseCountDownPanel()
			table.remove(self.orderList, index)

			break
		end
	end

	self:RefreshOrder()

	if #self.orderList == 0 then
		self:StopUpdate()
	end
end

function M:RemoveAllNpcBtn()
	for index, v in pairs(self.orderList) do
		self:RemoveOrderNpcBtn(v)
	end
end

function M:ExitOrderMode()
	self:StopUpdate()
	self:Init()
end

function M:RegisterMessages()
	if not self.isRegister then
		self.isRegister = true

		gMessageManager:RegisterEventHandlers(self.msgEvents)
	end
end

function M:UnRegisterMessages()
	if self.isRegister then
		self.isRegister = false

		gMessageManager:UnregisterEventHandlers(self.msgEvents)
	end
end

function M:GetOrderByEventId(eventId)
	for _, v in pairs(self.orderList) do
		if v.AcceptedEventId == eventId then
			return v
		end
	end
end

function M:ForcePushPositionSync(orderData)
	local cargoList = {}

	for _, cargo in pairs(orderData.cargoInfoList) do
		table.insert(cargoList, cargo.instanceId)
	end

	gCS.SceneItemMgr:ForcePushPositionSync(cargoList)
end

function M:PreSettleTruckOrder(eventId, completeCb)
	local info = self:GetOrderByEventId(eventId)

	self:ForcePushPositionSync(info)

	gClientToGameDelegate:AskPreSettleTruckOrder(info.UniqueId, self:GetCargoIntegrityList(info)).Callback = function (err, truckJobOrderWrap)
		if err == MessageConfig.Ok then
			self:SetOrderComplete(info, true)

			info.result = truckJobOrderWrap
		end

		completeCb:DynamicInvoke()
	end
end

function M:ShowTruckDeliveryAiDialog(eventId, setResultCb, completeCb)
	local info = self:GetOrderByEventId(eventId)

	if info.result then
		setResultCb:DynamicInvoke(true)

		local condition = self:GetTruckOrderCondition2(info.result)
		local dialogId = gDialogManager:GetTruckOrderDialogId(condition)

		local function cb(callbackDialogId, index, state)
			if state == gClientConst.DialogState.End and index == 1 then
				setResultCb:DynamicInvoke(false)
				self:SetOrderComplete(info, false)
			end
		end

		function self.onDialogEnd(_, data)
			local FirstDialogId = data[0]
			local configType = data[1]

			if configType == 1 and FirstDialogId == dialogId then
				gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END_OTHER, self.onDialogEnd)

				self.onDialogEnd = nil

				completeCb:DynamicInvoke()
			end
		end

		gMessageManager:AddMessageListener(gEventConstants.DIALOG_END_OTHER, self.onDialogEnd)
		gDialogManager:ShowTruckOrderDialog(dialogId, info.result.OrderInfo, cb)

		return
	end

	print_error("@策划", eventId, "节点配在错误 在预结算之前调用AIDialog")
	completeCb:DynamicInvoke()
end

function M:SetOrderNpcBtn(eventId, instanceId)
	for _, v in pairs(self.orderList) do
		if v.AcceptedEventId == eventId and instanceId and not ulong.equals(instanceId, ulong.zero) and gCS.SceneDataMgr.GetUnit(instanceId) and not v.isHasBtn then
			local unit = gCS.SceneDataMgr.GetUnit(instanceId)

			if unit then
				local info = LX6.Interact.UnitBtnInfo.New(1, instanceId, 0, function ()
					gClientToGameSceneDelegate:AskDoTruckNpcAction(instanceId, eventId).Callback = function (err)
						if err ~= LTConfig.MessageConfig.Ok then
							print_warn("AskDoTruckNpcAction Fail", gCS.Error.GetNameById(err), eventId)
						end
					end
				end, nil, 74003801)

				L50.L50App.L50Game.InteractBtnMgr:AddBtn(info)

				v.isHasBtn = true
			else
				print_error("SetOrderNpc not find npc in ", eventId, ulong.tostring(instanceId))
			end
		end
	end
end

function M:RemoveOrderNpcBtn(order)
	if order.npcInstanceId and not ulong.equals(order.npcInstanceId, ulong.zero) and order.isHasBtn then
		L50.L50App.L50Game.InteractBtnMgr:RemoveBtnByType(order.npcInstanceId, LX6.Interact.BtnTargetType.Unit)

		order.isHasBtn = false
	end
end

function M:SaveDeliveryHistoryInfoCS(eventId, callback)
	self:SaveDeliveryHistoryInfo({
		eventId = eventId,
		callback = function ()
			if callback == nil then
				return
			end

			callback:DynamicInvoke()
		end
	})
end

function M:SaveDeliveryHistoryInfo(data)
	local order = self:GetOrderByEventId(data.eventId)

	if not order then
		print_error("@liufuqiang01 client not have this event ", data.eventId)

		return
	end

	if order.isComplete then
		self:FinishDeliveryOrder(order, data)
	else
		self:ForcePushPositionSync(order)

		gClientToGameDelegate:AskPreSettleTruckOrder(order.UniqueId, self:GetCargoIntegrityList(order)).Callback = function (err, truckJobOrderWrap)
			if err == MessageConfig.Ok then
				self:SetOrderComplete(order, true)
				self:FinishDeliveryOrder(order, data)
			end
		end
	end
end

function M:FinishDeliveryOrder(order, data)
	gClientToGameDelegate:AskSettleTruckOrder(order.UniqueId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:CloseCountDownPanel()
		self:SetOrderComplete(order, true)
		gMessageManager:SendMessage(gEventConstants.ON_GOOD_OPEN_INTEGRITY_PLANE, {
			isOpen = false,
			eventId = data.eventId
		})

		if data.callback then
			data.callback()
		end
	end
end

function M:AskAbandonCurrentTask()
	gClientToGameDelegate:AskFinishJob().Callback = function (err)
		self:ExitOrderMode()
	end
end

function M:CalVehicleScore()
	if not self.CheckTruckActivityHasOpen() or gPauseManager.isBreak then
		return
	end

	local vehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle

	if (vehicle == nil or vehicle.baseVehicle == nil or vehicle.baseVehicle.Speed < self.ContinueTriggerSpeed) and (gCS.PaoKuManager.ParkourStateLua ~= LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Moto or Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.InputVelocity, Vector3.New(0, 0, 0)) < self.ContinueTriggerSpeed) then
		self.continueSpeedTime = 0

		return
	end

	self.continueSpeedTime = self.continueSpeedTime + 1
	local time, value, addValue, interval = self:GetContinueTimeData(self.continueSpeedTime)

	if time == nil then
		return
	end

	if math.abs(self.continueSpeedTime - time) < EXP then
		self:UpdateAllOrderScore(self.ResidentActivityTxt2, value)

		return
	end

	if math.abs((self.continueSpeedTime - time) % interval) < EXP then
		self:UpdateAllOrderScore(self.ResidentActivityTxt2, addValue)

		return
	end
end

function M:UpdateAllOrderScore(text, score)
	local orderIds = {}

	for _, v in pairs(self.orderList) do
		table.insert(orderIds, v.UniqueId)
	end

	self:UpdateDeliveryScoreHelper(text, score, orderIds)
end

function M:PlayerScoreUIHelper(text, score)
	if not gPanelManager:IsPanelShowing(gPanelId.S_DELIVERY_SCORE_PANEL) then
		gPanelManager:CheckShow(gPanelId.S_DELIVERY_SCORE_PANEL, {
			typeText = text,
			score = score
		})
	else
		gMessageManager:SendMessage(gEventConstants.DELIVERY_SCORE_EVENT, {
			typeText = text,
			score = score
		})
	end
end

function M:UpdateDeliveryScoreHelper(text, score, orderIds)
	gClientToGameDelegate:AskAddTruckOrderSpecialPointRewards(orderIds, score).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self:PlayerScoreUIHelper(text, score)
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:UpdateDeliveryScore(text, score, orderId)
	self:UpdateDeliveryScoreHelper(text, score, {
		orderId
	})
end

function M:GetContinueTimeData(time)
	if self.ContinueTime3[1] <= time then
		return self.ContinueTime3[1], self.ContinueTime3[2], self.ContinueTime3[3], self.ContinueTime3[4]
	elseif self.ContinueTime2[1] <= time then
		return self.ContinueTime2[1], self.ContinueTime2[2], self.ContinueTime2[3], self.ContinueTime2[4]
	elseif self.ContinueTime1[1] <= time then
		return self.ContinueTime1[1], self.ContinueTime1[2], self.ContinueTime1[3], self.ContinueTime1[4]
	end
end

function M:OnUpdate()
	if self.isUpdate == false then
		return
	end

	local nowTime = gCS.TimeManager.ServerUnixTime
	local tickTime = nowTime - self.lastTime
	self.lastTime = gCS.TimeManager.ServerUnixTime
	local isAllPickUp = true
	local isAnyLose = false

	for _, order in pairs(self.orderList) do
		for _, v in pairs(order.cargoInfoList) do
			if v.isUpdate and v.instanceId and v.needCheck then
				v.isLose, v.hp = gCS.LuaUtils.CalCargoIntegrity(v.instanceId, self.GoodsFarthestDistance, v.hp)
				isAnyLose = isAnyLose or v.isLose or isAnyLose
			end

			if not v.isUpdate then
				isAllPickUp = false
			end
		end

		if not self:CheckTimeBuff() then
			local time = order.orderTime > 0 and Mathf.Clamp(1 - (nowTime - order.startTime - order.timeStop) / order.orderTime, 0, 1) or 1

			gMessageManager:SendMessage(gEventConstants.JOB_ORDER_LIST_TIME, {
				isUpdateTime = true,
				eventId = order.AcceptedEventId,
				time = time,
				colorState = time < 0.33 and 1 or 0
			})
		else
			order.timeStop = tickTime + order.timeStop

			gMessageManager:SendMessage(gEventConstants.JOB_ORDER_LIST_TIME, {
				isUpdateTime = false,
				eventId = order.AcceptedEventId
			})
		end
	end

	self:CheckOrderTitleState(isAllPickUp, isAnyLose)
	self:UpdateCargoIntegrity()
end

function M:CheckOrderTitleState(isAllPickUp, isAnyLose)
	if not isAllPickUp then
		self:ChangeDeliveryPanelTitle(self.TitleType.PickUpOrderText)
	elseif isAnyLose then
		self:ChangeDeliveryPanelTitle(self.TitleType.LoseStateText)
	else
		self:ChangeDeliveryPanelTitle(self.TitleType.SendOrderText)
	end
end

function M:GetCargoState(cargoInfo, isNeedMessage)
	local state = cargoInfo.cargoState

	if cargoInfo and not cargoInfo.isFinish then
		if cargoInfo.isFinish then
			state = self.CargoState.Finish
		elseif not cargoInfo.isUpdate then
			state = self.CargoState.NoPickUp
		elseif cargoInfo.isLose then
			state = self.CargoState.Lose
		else
			local integrity = self:GetCargoIntegrity(cargoInfo)

			for id, v in ipairs(self.IntactSectionDescription) do
				if v.min <= integrity and integrity <= v.max then
					state = id
				end
			end
		end

		if state ~= cargoInfo.cargoState and isNeedMessage then
			gMessageManager:SendMessage(gEventConstants.ON_CARGO_STATE_CHANGE, {
				cargoState = Mathf.Pow(2, state),
				uniqueId = cargoInfo.instanceId
			})
		end
	end

	cargoInfo.cargoState = state

	return cargoInfo.cargoState
end

function M:GetCargoStateByDestructible(instanceId)
	for _, order in pairs(self.orderList) do
		for _, v in pairs(order.cargoInfoList) do
			if v.instanceId == instanceId then
				return v.cargoState
			end
		end
	end

	return -1
end

function M:CompleteCargo(cargo)
	cargo.isFinish = true
	cargo.isUpdate = false

	self:RefreshOrder()
end

function M:DeliverCargoByDestructible(instanceId)
	for _, order in pairs(self.orderList) do
		for _, v in pairs(order.cargoInfoList) do
			if v.instanceId == instanceId then
				self:CompleteCargo(v)
			end
		end
	end
end

function M:SetOrderComplete(order, isComplete)
	order.isComplete = isComplete

	for _, v in pairs(order.cargoInfoList) do
		if v.cargoState ~= self.CargoState.NoPickUp then
			v.isUpdate = not isComplete
		end
	end

	if isComplete then
		self:RemoveOrderNpcBtn(order)
	else
		self:SetOrderNpcBtn(order.AcceptedEventId, order.npcInstanceId)
	end
end

function M:AddOrderInfo(data)
	if data and data.OrderInfo and data.AcceptInfo then
		self.orderList = {}
		local orderInfo = data.OrderInfo
		local orderAcceptInfo = data.AcceptInfo
		local endPosConfig = LTConfig.UberSimDeliveryConfig.GetConfig(orderInfo.EndPos.ConfigId)
		local order = {
			Data = data,
			startTime = orderAcceptInfo.AcceptTime,
			AcceptedEventId = orderAcceptInfo.AcceptedEventId,
			orderTime = orderInfo.EstimatedFinishSeconds,
			UniqueId = data.UniqueId,
			isComplete = false
		}
		self.tIndex = self.CargoType.normal
		order.timeStop = 0
		order.isHasBtn = false
		order.npcInstanceId = data.npcInstanceId
		order.finishPosText = endPosConfig and endPosConfig.information or ""
		order.cargoInfoList = {}

		if orderInfo.CargoInfoList then
			for i = 1, #orderInfo.CargoInfoList do
				local originalCargoInfo = orderInfo.CargoInfoList[i]
				local config = RandomGoodsConfig.GetConfig(originalCargoInfo.CargoId)
				local startPosConfig = LTConfig.UberSimPickupConfig.GetConfig(originalCargoInfo.StartPos.ConfigId)
				local cargoInfo = {
					isFinish = false,
					integrity = 0,
					hp = 1,
					isLose = false,
					maxIntegrity = 100,
					isUpdate = false,
					cargoId = originalCargoInfo.CargoId,
					instanceId = originalCargoInfo.UniqueId,
					angle = config.angle,
					imageId = config.image,
					name = config.information,
					isCheckAngle = config.angle ~= 0,
					cargoState = self.CargoState.NoPickUp,
					startPosText = startPosConfig and startPosConfig.information or "",
					orderCfg = config
				}

				table.insert(order.cargoInfoList, cargoInfo)
			end
		end

		order.firstCargo = order.cargoInfoList[1]

		table.insert(self.orderList, order)
		self:ChangeCurOrder(order.AcceptedEventId)
		self:StartUpdate()

		if data.npcInstanceId then
			self:SetOrderNpcBtn(order.AcceptedEventId, data.npcInstanceId)
		end
	else
		print_error("@liufuqiang01 AddOrderInfo error")
	end
end

function M:ModifyOrderCargoInfo(data)
	local order = self:GetOrderByUniqueId(data.UniqueId)

	if order and data.OrderInfo and data.OrderInfo.CargoInfoList then
		local orderInfo = data.OrderInfo

		for i = 1, #orderInfo.CargoInfoList do
			if order.cargoInfoList[i] then
				order.cargoInfoList[i].instanceId = orderInfo.CargoInfoList[i].UniqueId
			end
		end
	end
end

function M:SwitchDeliveryPanel(eventId, integrity, cargoId)
	integrity = ulong.tonum2(integrity)
	local order = self:GetOrderByEventId(eventId)

	if not order then
		print_error("@liufuqiang01 SwitchDeliveryPanel get order error ")

		return
	end

	local config = RandomGoodsConfig.GetConfig(cargoId)

	if config then
		order.firstCargo.imageId = config.image
		order.firstCargo.name = config.information
		order.firstCargo.orderCfg = config
	end

	self.tIndex = self.CargoType.special
	order.firstCargo.integrity = self:GetFirstIntegrity(order) / 100 * integrity
	order.firstCargo.maxIntegrity = integrity

	self:RefreshOrder()
end

function M:GoodsHpChange(instanceId, hp)
	for _, v in pairs(self.orderList) do
		for _, carInfo in pairs(v.cargoInfoList) do
			if carInfo.instanceId == instanceId then
				carInfo.hp = hp
			end
		end
	end
end

function M:UpdateCargoIntegrity()
	for _, order in pairs(self.orderList) do
		local isNeedChange = false
		local isNeedDialog = false

		for _, v in pairs(order.cargoInfoList) do
			local lastIntegrity = v.integrity

			if v.isUpdate and v.needCheck then
				if v.isLose then
					v.integrity = 0
				else
					v.integrity = v.hp * v.maxIntegrity
				end
			elseif v.isUpdate and v.checkVehicle and v.vehicleId then
				local vehicle = gDriveVehiclesManager:GetVehicleInScene(v.vehicleId)

				if not gCS.LuaUtils.IsNull(vehicle) then
					self:CalVehicleHpData(v, vehicle)
				else
					v.integrity = 0
				end
			end

			if EXP < math.abs(lastIntegrity - v.integrity) then
				isNeedChange = true
			end

			if EXP < lastIntegrity - v.integrity then
				isNeedDialog = true
			end
		end

		if isNeedChange then
			self:ChangePanelIntegrity(order)
		end

		if isNeedDialog then
			self:PlayRandomDialog(self.IntegrityRungsChangeTxt)
		end
	end
end

function M:CheckTimeBuff()
	return gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, timeBuff)
end

function M:StartUpdate()
	if self.isUpdate == false then
		self.isUpdate = true
		self.lastAngleTime = gCS.TimeManager.ServerUnixTime
		self.lastSpeedTime = gCS.TimeManager.ServerUnixTime
		self.lastTime = gCS.TimeManager.ServerUnixTime

		self:ChangeDeliveryPanelTitle(self.TitleType.PickUpOrderText)
		gLuaClient:RegisterDynamicUpdate("DeliveryTaskManager", self, false)
		gMessageManager:SendMessage(gEventConstants.DELIVERY_PANEL_STATE_CHANGE, true)
	end
end

function M:StopUpdate()
	if self.isUpdate then
		self.isUpdate = false
		self.curOrderId = nil

		self:CloseCountDownPanel()
		self:RemoveAllNpcBtn()
		self:ChangeDeliveryPanelTitle(self.TitleType.WaitOrderText)
		gMessageManager:SendMessage(gEventConstants.DELIVERY_PANEL_STATE_CHANGE, false)
		gLuaClient:UnregisterDynamicUpdate("DeliveryTaskManager")
		self:SendDropItemEvent()
	end
end

function M:IsHaveOrder()
	return self.isUpdate
end

function M:SetCurrentOrder(order)
	self.curOrderId = order.UniqueId
	self.curEvent = order.AcceptedEventId

	self:ChangeCountDownPlane(order)
end

function M:ChangeCurOrder(eventId)
	for _, v in pairs(self.orderList) do
		if eventId == v.AcceptedEventId then
			self:SetCurrentOrder(v)
		end
	end

	self:RefreshOrder()
end

function M:GetCurOrderId()
	return self.curOrderId
end

function M:RefreshOrder()
	gMessageManager:SendMessage(gEventConstants.JOB_ORDER_LIST_REFRESH)
end

function M:ChangeCurOrderByUniqueId(uniqueId)
	for _, v in pairs(self.orderList) do
		if uniqueId == v.UniqueId then
			self:SetCurrentOrder(v)
			self:RefreshOrder()
		end
	end
end

function M:CheckPickUpTime(order)
	if not self.CheckTruckActivityHasOpen() then
		return
	end

	local nowTime = gCS.TimeManager.ServerUnixTime
	local time = nowTime - order.startTime
	local pickTime = self.QuickPickup[1]
	local pickScore = self.QuickPickup[2]

	if time < pickTime then
		self:UpdateDeliveryScore(self.ResidentActivityTxt1, pickScore, order.UniqueId)
	end
end

function M:CheckOrderHasPickUp(uniqueId, cargoId)
	if not self.orderList then
		return
	end

	for _, order in pairs(self.orderList) do
		if order.UniqueId == uniqueId and order.cargoInfoList then
			for _, cargoInfo in ipairs(order.cargoInfoList) do
				if cargoInfo.cargoId == cargoId then
					return cargoInfo.cargoState ~= self.CargoState.NoPickUp
				end
			end
		end
	end

	return false
end

function M:ChangePanelOpen(isOpen, data)
	for _, order in pairs(self.orderList) do
		if order.AcceptedEventId == data.eventId then
			if isOpen then
				for _, v in pairs(order.cargoInfoList) do
					if data.needCheck then
						if v.instanceId == data.goodsData then
							v.isLose, v.hp = gCS.LuaUtils.CalCargoIntegrity(v.instanceId, self.GoodsFarthestDistance, v.hp)
							v.integrity = v.hp * 100
							v.isUseTag = data.isUseTag
							v.destructibleTag = data.destructibleTag
							v.isUpdate = true
							v.needCheck = data.needCheck
						end
					elseif data.needCheckVehicle and data.vehicle then
						v.vehicleId = data.vehicle
						v.isUpdate = true
						v.checkVehicle = data.needCheckVehicle
						local vehicle = gDriveVehiclesManager:GetVehicleInScene(v.vehicleId)

						if vehicle then
							self:CalVehicleHpData(v, vehicle)
						end
					else
						v.hp = 0
						v.integrity = data.integrity or v.integrity
						v.isUpdate = true
					end

					if not v.isUpdate then
						isAllPickUp = false
					end
				end

				self:ChangePanelIntegrity(order)
			else
				for _, v in pairs(order.cargoInfoList) do
					v.isUpdate = false
				end
			end
		end
	end
end

function M:CalVehicleHpData(cargoData, vehicle)
	cargoData.vehicleMaxHp = vehicle.MaxHp == 0 and 1 or vehicle.MaxHp
	cargoData.hp = Mathf.Clamp(vehicle.CurrentHp / cargoData.vehicleMaxHp, 0, 1)
	cargoData.integrity = cargoData.hp * 100
end

function M:DestructibleByTag(data)
	if data.eventType ~= gSpoonEventType.DestructibleEventType.Raise and data.eventType ~= gSpoonEventType.DestructibleEventType.HandHold and data.eventType ~= gSpoonEventType.DestructibleEventType.Break or not data.instanceId then
		return
	end

	local isBreak = data.eventType == gSpoonEventType.DestructibleEventType.Break

	for _, order in pairs(self.orderList) do
		for _, v in pairs(order.cargoInfoList) do
			if not isBreak then
				if v.isUseTag and v.instanceId ~= data.instanceId then
					local sceneItem = gCS.DestructibleMgr:GetDestructibleByUniqueId(data.instanceId)

					if sceneItem then
						local cfgId = sceneItem.destructibleTemplateId
						local config = DestructibleConfig.GetConfig(cfgId)

						if config and config.TriggerTag == v.destructibleTag then
							v.instanceId = data.instanceId
							v.hp = DestructibleManager.Instance:GetDestructibleHpById(v.instanceId)
						end
					end
				end

				if v.instanceId == data.instanceId then
					self:PlayRandomDialog(self.PackupTxt)
				end
			elseif v.instanceId == data.instanceId then
				self:PlayRandomDialog(self.PackupAgainTxt)
			end
		end
	end
end

function M:ChangeCountDownPlane(order, isNotAnimal)
	local data = {
		isCountDown = true,
		param = {
			startTime = order.startTime,
			isPick = order.isUpdate,
			TimeLimit = order.orderTime,
			timeStop = order.timeStop,
			eventId = order.AcceptedEventId,
			isNotAnimal = isNotAnimal
		}
	}

	if order.orderTime > 0 then
		gPanelManager:CheckShow(gPanelId.S_DELIVERY_COUNT_DOWN_PANEL, {
			showMillisecond = false,
			isCountDown = true,
			redTenSeconds = true,
			countDownSecondNum = order.orderTime
		})
	else
		self:CloseCountDownPanel()
	end
end

function M.RefreshOrderDetailView(widget, truckJobOrderWrap)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local orderInfo = truckJobOrderWrap.OrderInfo
	local resultInfo = truckJobOrderWrap.ResultInfo

	if resultInfo == nil then
		return
	end

	store.money = resultInfo.DropMoney or 0
	store.time = os.date("%Y.%m.%d", resultInfo.FinishTime)
	local randomGoodsCfg = LTConfig.UberSimRandomGoodsConfig.GetConfig(orderInfo.CargoId)
	store.name = randomGoodsCfg.information
	local finishTime = resultInfo.FinishTime - truckJobOrderWrap.AcceptInfo.AcceptTime
	local minutes = math.floor(finishTime / gClientConst.SECONDS_PER_MINUTE)
	local seconds = finishTime % gClientConst.SECONDS_PER_MINUTE
	store.useTime = ("%02d:%02d"):format(minutes, seconds)
	store.integrity = math.ceil(resultInfo.CargoIntegrity)
	store.progressBar.value = resultInfo.CargoIntegrity
	store.rankControl = resultInfo.Evaluation
	store.score = ("+%d"):format(resultInfo.RewardPoint)
	store.jobExp = gDeliveryTaskManager.GetJobExp(resultInfo)
	local comment = gDeliveryTaskManager.GetTruckOrderComment(truckJobOrderWrap) or ""
	store.comment = comment

	gDeliveryTaskManager.RefreshOrderTagView(store, randomGoodsCfg.TagIconIdList)
	gDeliveryTaskManager.RefreshOrderLocationView(store, truckJobOrderWrap)
end

function M.GetJobExp(resultInfo)
	local dropId = LTConfig.UberSimConfig.OrderRewardDropId
	local jobExpInfo = LTConfig.DropConfig.GetConfig(dropId).JobExp[1]
	local jobExp = jobExpInfo.count * resultInfo.DropCoefficient

	return math.ceil(jobExp)
end

function M.RefreshOrderTagView(store, tagIconIdList)
	function store.typeList.luaRenderItem(typeBtn, _, data)
		local typeStore = gStoreManager:GetStoreGroup(typeBtn.Store):GetStoreByWidget(typeBtn)
		local orderTagCfg = LTConfig.UberSimOrderTagConfig.GetConfig(data.id)
		typeStore.iconId = orderTagCfg.iconId
		typeStore.name = orderTagCfg.name
		local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
		typeBtn.enabledTooltip = isMobile
		local cfgId = data.id

		function typeBtn.luaRenderTooltip(_, comp, _)
			local popStore = gStoreManager:GetStoreGroup(comp.Store):GetStoreByWidget(comp)
			local popOrderTagCfg = LTConfig.UberSimOrderTagConfig.GetConfig(cfgId)
			popStore.name = popOrderTagCfg.name
		end
	end

	local typeViewDataList = {}

	for _, tagId in ipairs(tagIconIdList) do
		table.insert(typeViewDataList, {
			id = tagId
		})
	end

	store.typeList:SetList(typeViewDataList)
end

function M.RefreshOrderLocationView(store, truckJobOrderWrap)
	local orderInfo = truckJobOrderWrap.OrderInfo
	local locationIconId = LTConfig.UberSimConfig.OrderDefaultLocationIconId

	if orderInfo.SpecialOrderId > 0 then
		local orderCfg = LTConfig.UberSimOrderConfig.GetConfig(orderInfo.SpecialOrderId)
		locationIconId = orderCfg and orderCfg.PathImage or LTConfig.UberSimConfig.OrderDefaultLocationIconId
	end

	store.locationIconId = locationIconId
	local locationViewDataList = {}
	local endPosConfigId = orderInfo.EndPos.ConfigId
	local endPosCfg = LTConfig.UberSimDeliveryConfig.GetConfig(endPosConfigId)
	local endText = endPosCfg and endPosCfg.information or ""
	local playerPosition = gClientUtils.GetPlayerPosition()
	playerPosition = Vector3.New(playerPosition.X, playerPosition.Y, playerPosition.Z)
	local hasOrderPickUp, startOrderPosition = nil

	for _, cargoInfo in ipairs(orderInfo.CargoInfoList) do
		local startPos = cargoInfo.StartPos
		local startPosConfigId = startPos.ConfigId
		local startPosition = startPos.Pos and Vector3.New(startPos.Pos.X, startPos.Pos.Y, startPos.Pos.Z)
		startOrderPosition = startOrderPosition or startPosition
		local startText = startPosConfigId > 0 and LTConfig.UberSimPickupConfig.GetConfig(startPosConfigId).information or ""
		local hasPickUp = gDeliveryTaskManager:CheckOrderHasPickUp(truckJobOrderWrap.UniqueId, cargoInfo.CargoId)
		hasOrderPickUp = hasOrderPickUp or hasPickUp
		local startDistance = startPosition and Vector3.Distance(startPosition, playerPosition) or 0

		table.insert(locationViewDataList, {
			typeControl = 0,
			tIndex = 0,
			location = startText,
			completeControl = hasPickUp and 1 or 0,
			distance = gClientUtils.FormatDistance(startDistance)
		})
		table.insert(locationViewDataList, {
			tIndex = 1
		})
	end

	local endDistance = nil
	local endPosition = orderInfo.EndPos.Pos and Vector3.New(orderInfo.EndPos.Pos.X, orderInfo.EndPos.Pos.Y, orderInfo.EndPos.Pos.Z)

	if endPosition then
		if hasOrderPickUp then
			endDistance = Vector3.Distance(endPosition, playerPosition)
		else
			endDistance = Vector3.Distance(startOrderPosition, endPosition)
		end
	else
		endDistance = 0
	end

	table.insert(locationViewDataList, {
		typeControl = 1,
		completeControl = 0,
		tIndex = 0,
		location = endText,
		distance = gClientUtils.FormatDistance(endDistance)
	})

	function store.locationList.luaRenderItem(locationBtn, _, locationData)
		if locationData.tIndex == 0 then
			local locationStore = gStoreManager:GetStoreGroup(locationBtn.Store):GetStoreByWidget(locationBtn)
			locationStore.location = locationData.location
			locationStore.distance = locationData.distance
			locationStore.typeControl = locationData.typeControl
			locationStore.completeControl = locationData.completeControl
		end
	end

	store.locationList:SetList(locationViewDataList)
end

function M.GetTruckOrderComment(truckJobOrderWrap)
	local condition = gDeliveryTaskManager:GetTruckOrderCondition2(truckJobOrderWrap)
	local evaluationCfg = nil
	local count = LTConfig.OrderEvaluationConfig.count

	for i = 0, count - 1 do
		evaluationCfg = LTConfig.OrderEvaluationConfig.LoadAt(i)

		if string.starts_with(condition, evaluationCfg.condition) then
			local evaluation = truckJobOrderWrap.ResultInfo.Evaluation
			local targetScoreValue = 6 - evaluation
			targetScoreValue = math.min(5, targetScoreValue)
			local scoreKey = ("score%d"):format(targetScoreValue)

			return evaluationCfg[scoreKey]
		end
	end
end

function M:GetTruckOrderCondition2(truckJobOrderWrap)
	local info = truckJobOrderWrap.OrderInfo
	local result = truckJobOrderWrap.ResultInfo
	local accept = truckJobOrderWrap.AcceptInfo

	if info == nil or result == nil then
		print_error("DIALOG DEBUG => 货车订单数据不完整")

		return
	end

	local cargoIntegrity = nil
	cargoIntegrity = ""
	local totalCargoCount = #info.CargoInfoList
	local cargoCount = 0

	for _, cargoInfo in ipairs(info.CargoInfoList) do
		if cargoInfo.IsCargoNear then
			cargoCount = cargoCount + 1
		end
	end

	if cargoCount == 0 then
		cargoIntegrity = "没有货物"
	elseif cargoCount ~= totalCargoCount then
		cargoIntegrity = "一个货物"
	else
		for _, desc in pairs(UberSimConfig.IntactSectionDescription) do
			if type(desc) == "table" and desc.min <= result.CargoIntegrity and result.CargoIntegrity <= desc.max then
				cargoIntegrity = desc.des

				break
			end
		end

		if cargoIntegrity == "" then
			print_error("完整度区间未找到，检查UberSim表IntactSectionDescription，当前完整度=" .. result.CargoIntegrity)

			return
		end
	end

	local emotion = LTConfig.AIdialogConfig.EmotionMapping[1].aiEmotion
	local agentId = info.DeliveryNpc.NpcId
	local agentCfg = LTConfig.AgentConfig.GetConfig(agentId)

	if agentCfg then
		for _, mapping in pairs(LTConfig.AIdialogConfig.EmotionMapping) do
			if mapping.agentPersonality == agentCfg.Personality then
				emotion = mapping.aiEmotion

				break
			end
		end
	end

	if totalCargoCount ~= 1 then
		local condition = string.format("%s_%s", cargoIntegrity, emotion)

		return condition
	end

	local cargoId = info.CargoId
	local cargoCfg = LTConfig.UberSimRandomGoodsConfig.GetConfig(cargoId)

	if cargoCfg == nil then
		print_error("DIALOG DEBUG => UberSim表中找不到货物Id为", cargoId, "的表项")

		return
	end

	local cargo = cargoCfg.type
	local estimatedFinishSeconds = info.EstimatedFinishSeconds
	local finishTimeRate = nil

	if estimatedFinishSeconds == 0 then
		finishTimeRate = "[0]"
	else
		local finishTime = result.FinishTime - accept.AcceptTime
		finishTimeRate = finishTime / estimatedFinishSeconds

		for _, section in pairs(UberSimConfig.TimeSection) do
			if type(section) == "table" and section.min <= finishTimeRate and finishTimeRate < section.max then
				finishTimeRate = "[" .. section.min .. "," .. section.max .. "]"

				break
			end
		end

		if type(finishTimeRate) == "number" then
			print_warn("完成时间区间未找到，检查UberSim表TimeSection，当前完成时间=" .. finishTime .. "，预估时间=" .. info.EstimatedFinishSeconds)

			finishTimeRate = "[" .. UberSimConfig.TimeSection[1].min .. "," .. UberSimConfig.TimeSection[1].max .. "]"
		end
	end

	local condition = string.format("%s_%s_%s_%s", cargoIntegrity, emotion, cargo, finishTimeRate)

	return condition
end

function M:GetCargoIntegrityList(orderInfo)
	local integrityList = {}

	for index, v in pairs(orderInfo.cargoInfoList) do
		integrityList[index] = Mathf.Clamp(math.ceil(v.integrity / v.maxIntegrity * 100), 0, 100)
	end

	return integrityList
end

function M:GetCargoIntegrity(cargo)
	return Mathf.Clamp(math.ceil(cargo.integrity / cargo.maxIntegrity * 100), 0, 100)
end

function M:GetOrderIntegrity(orderInfo)
	local integrity = 0
	local count = 0

	for _, v in pairs(orderInfo.cargoInfoList) do
		integrity = integrity + v.integrity / v.maxIntegrity * 100
		count = count + 1
	end

	return count == 0 and 0 or integrity / count
end

function M:GetOrderIntegrityByTaskId(taskId)
	local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)
	local eventId = eventInfo.TaskLineId
	local orderInfo = self:GetOrderByEventId(eventId)
	local integrityVal = self:GetOrderIntegrity(orderInfo) or 0

	return integrityVal
end

function M:GetFirstIntegrity(orderInfo)
	return orderInfo.firstCargo.integrity / orderInfo.firstCargo.maxIntegrity * 100
end

function M:ChangeOrderIntegrity(order, isAddMode, isModifyAll, instanceId, integrity)
	for _, v in pairs(order.cargoInfoList) do
		if isModifyAll or instanceId == v.instanceId then
			if isAddMode then
				v.integrity = v.integrity + integrity
			else
				v.integrity = integrity
			end

			if v.instanceId and v.needCheck then
				gCS.LuaUtils.SetCargoHp(v.instanceId, self:GetCargoIntegrity(v) / 100)
			end
		end
	end

	self:ChangePanelIntegrity(order)
end

function M:ChangeOrderIntegrityByTaskId(taskId, isAddMode, isModifyAll, instanceId, integrity)
	local eventId = gTaskNodeManager:GetTaskLineByTask(taskId).TaskLineId
	local info = gDeliveryTaskManager:GetOrderByEventId(eventId)

	if not info then
		print_error("Not order info nodeId", self.nodeId)

		return
	end

	gDeliveryTaskManager:ChangeOrderIntegrity(info, isAddMode, isModifyAll, instanceId, integrity)
end

function M:ChangePanelIntegrity(order)
	gMessageManager:SendMessage(gEventConstants.ON_GOOD_INTEGRITY_CHANGE, {
		eventId = order.AcceptedEventId,
		orderInfo = order,
		type = self.tIndex
	})
end

function M.RefreshDeliveryAvatarView(avatarWidget, rootGo)
	local avatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	avatarStore.headIcon = gSpiritJobManager.GetAvailableJobAvatarId(LTConfig.UrbanJobJobClassConfig.Delivery)

	function avatarStore.button.luaClick()
		gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			if gClientUtils.IsNil(rootGo) then
				return
			end

			gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
				secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.ACCOUNT,
				clientTruckOrderView = clientTruckOrderView
			})
		end
	end
end

function M:OpenDeliveryAccountPanel()
	gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gMainPhoneUtils.ShowPhoneAppContent({
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.DeliveryApp,
			secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.ACCOUNT,
			clientTruckOrderView = clientTruckOrderView
		})
	end
end

function M:GetDeliveryJobInfo()
	local currentJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Delivery)
	local currentJobInfo = gSpiritJobManager.GetCurSpiritJob(currentJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(currentJobId)
	local _, cfg = gSpiritJobManager:GetAvailableJobByClass(LTConfig.UrbanJobJobClassConfig.Delivery)

	if currentJobInfo and urbanJobCfg then
		local spiritTid = gSpiritManager:GetCurFirstSpiritTid()
		local levelCfg = gSpiritJobManager:GetLevelData(urbanJobCfg, spiritTid)

		return currentJobInfo, levelCfg, cfg
	end
end

function M:ShowOrderFinishPanel(data)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.DeliveryEnd, data)
end

function M:AllAcceptTruckOrder(orders)
	self.orderList = {}

	for i = 1, #orders do
		local order = orders[i]

		self:AddOrderInfo(order)
	end
end

function M:RemoveTruckOrder(orderId, isAborted)
	for _, v in pairs(self.orderList) do
		if v.UniqueId == orderId then
			self:FinishOrderByEvent(v.AcceptedEventId, isAborted)
		end
	end
end

function M:RemoveCurTruckOrder()
	for _, v in pairs(self.orderList) do
		if v.UniqueId == self.curOrderId then
			self:FinishOrderByEvent(v.AcceptedEventId, false)
		end
	end
end

function M:GMSetDeliveryOrderIntegrity(id, integrity)
	local orderInfo = self.orderList[id]

	if orderInfo then
		self:ChangeOrderIntegrity(orderInfo, false, true, nil, integrity)
	end
end

function M:GmSetTruckOrderLimitTime(id, time)
	local orderInfo = self.orderList[id]

	if orderInfo then
		gClientToGameGMDelegate:GmSetTruckOrderLimitTime(orderInfo.UniqueId, time).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)
			end
		end

		orderInfo.orderTime = time

		self:ChangeCountDownPlane(orderInfo, true)
	end
end

function M:GMGetAllIntegrity(orderInfo)
	local integrityList = {}

	for index, v in pairs(orderInfo.cargoInfoList) do
		integrityList[index] = 100
	end

	return integrityList
end

function M:GMFinishOrderById(id)
	local orderInfo = self.orderList[id]

	if orderInfo then
		self:ForcePushPositionSync(orderInfo)

		gClientToGameDelegate:AskPreSettleTruckOrder(orderInfo.UniqueId, self:GMGetAllIntegrity(orderInfo)).Callback = function (err)
			if err ~= MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gClientToGameGMDelegate:GmCompleteTruckJobOrder(orderInfo.UniqueId, 100).Callback = function (errorId)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end
			end
		end
	end
end

function M.CheckTruckActivityHasOpen()
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.TruckActivity)
end

function M.CheckIsUnlimitedTimeOrder(randomGoodId)
	local count = LTConfig.UberSimOrderConfig.count

	for i = 0, count - 1 do
		local orderCfg = LTConfig.UberSimOrderConfig.LoadAt(i)

		if orderCfg.RandomGoods == randomGoodId and orderCfg.Time == 0 then
			return true
		end
	end
end

function M.CheckIsSpecialOrder(randomGoodId)
	local count = LTConfig.UberSimOrderConfig.count

	for i = 0, count - 1 do
		local orderCfg = LTConfig.UberSimOrderConfig.LoadAt(i)

		if orderCfg.RandomGoods == randomGoodId then
			return true
		end
	end
end

function M:OpenTalentTree()
	gMainPageManager:TalentTreeOpenTrigger({
		jobClassId = LTConfig.UrbanJobJobClassConfig.Delivery
	})
end

function M:CheckCanPromote(currentJobId)
	local currentJobInfo = gSpiritJobManager.GetCurSpiritJob(currentJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(currentJobId)

	if currentJobInfo and urbanJobCfg then
		local spiritTid = gSpiritManager:GetCurFirstSpiritTid()
		local levelCfg = gSpiritJobManager:GetLevelData(urbanJobCfg, spiritTid)

		if levelCfg.Exp <= currentJobInfo.Exp then
			local targetTaskId = self:GetPromoteTaskId(currentJobId)

			if targetTaskId then
				local jobIdListChain = gSpiritJobManager:GetJobData(currentJobId)
				local _, index = table.find(jobIdListChain, currentJobId)

				return index < table.count(jobIdListChain)
			end
		end
	end
end

function M:GetPromoteTaskId(currentJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(currentJobId)

	return urbanJobCfg and urbanJobCfg.PromoteTask > 0 and urbanJobCfg.PromoteTask
end

function M:SetSpoonCustomOrderData(orderId, money, accept, callBack)
	self.spoonCustomOrderData = nil

	if not orderId then
		gMessageManager:SendMessage(gEventConstants.DELIVERY_SPOON_ORDER_DATA_CHANGED)
		self:InvokeCallBack(callBack)

		return
	end

	local orderCfg = LTConfig.UberSimOrderConfig.GetConfig(orderId)

	if orderCfg then
		local pickUpIds = {}
		local deliveryIds = {}
		local pickUpId = orderCfg.Pickup
		local deliveryId = orderCfg.Delivery
		local pickUpPos = self.pickUpPos[pickUpId]

		if not pickUpPos then
			table.insert(pickUpIds, pickUpId)
		end

		local deliveryPos = self.deliveryPos[deliveryId]

		if not deliveryPos then
			table.insert(deliveryIds, deliveryId)
		end

		if #pickUpIds > 0 or #deliveryIds > 0 then
			gClientToGameDelegate:AskQueryTruckPosInfo(pickUpIds, deliveryIds).Callback = function (errorId, pickUpTruckPosInfos, deliveryTruckPosInfos)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)
					self:InvokeCallBack(callBack)

					return
				end

				local queryPickUpPos = pickUpTruckPosInfos[1]

				if queryPickUpPos then
					self.pickUpPos[pickUpId] = queryPickUpPos
				end

				local queryDeliveryPos = deliveryTruckPosInfos[1]

				if queryDeliveryPos then
					self.deliveryPos[deliveryId] = queryDeliveryPos
				end

				self:SetSpoonCustomOrderDataInternal(orderId, money, accept, self.pickUpPos[pickUpId], self.deliveryPos[deliveryId])
				self:InvokeCallBack(callBack)
			end
		else
			self:SetSpoonCustomOrderDataInternal(orderId, money, accept, self.pickUpPos[pickUpId], self.deliveryPos[deliveryId])
			self:InvokeCallBack(callBack)
		end

		return
	end

	self:InvokeCallBack(callBack)
end

function M:InvokeCallBack(cb)
	if cb then
		cb:DynamicInvoke()
	end
end

function M:CreateOrderInfo(orderId, money, accept, pickUpPos, deliveryPos)
	local data = {}
	local orderInfos = {}
	local truckJobOrderWrap = {
		isTaskOrder = true,
		OrderInfoStartTime = gLuaDataManager.serverTime
	}
	local orderInfo = {
		IsDailyOrder = false,
		IsHighValue = false,
		LimitAcceptSeconds = 99999,
		SpecialOrderId = orderId,
		DropMoney = money
	}
	local orderCfg = LTConfig.UberSimOrderConfig.GetConfig(orderId)
	orderInfo.CargoId = orderCfg.RandomGoods
	orderInfo.EstimatedFinishSeconds = 0
	orderInfo.StartPos = pickUpPos or {
		ConfigId = 0
	}
	orderInfo.EndPos = deliveryPos or {
		ConfigId = 0
	}
	local cargoInfoList = {}
	local cargoInfo = {
		CargoId = orderInfo.CargoId,
		Integrity = 0,
		IsCargoNear = false,
		StartPos = pickUpPos or {
			ConfigId = 0
		}
	}

	table.insert(cargoInfoList, cargoInfo)

	local len = #cargoInfoList
	cargoInfoList.Length = len
	cargoInfoList.Count = len
	orderInfo.CargoInfoList = cargoInfoList
	truckJobOrderWrap.OrderInfo = orderInfo

	if accept then
		local acceptInfo = {
			AcceptTime = gLuaDataManager.serverTime,
			AcceptEventId = orderCfg.EventId
		}
		truckJobOrderWrap.AcceptInfo = acceptInfo
	end

	table.insert(orderInfos, truckJobOrderWrap)

	len = #orderInfos
	orderInfos.Length = len
	orderInfos.Count = len
	data.orders = orderInfos
	data.currentOrderId = accept and orderId or 0
	self.spoonCustomOrderData = data
end

function M:SetSpoonCustomOrderDataInternal(orderId, money, accept, pickUpPos, deliveryPos)
	if not orderId or not pickUpPos or not deliveryPos then
		print_error("Set custom order data from spoon failed! Data is invalid.")

		return
	end

	if self.spoonCustomOrderData then
		print_error("Set custom order data from spoon failed! SpoonCustomOrderData is allReady exist.")
	end

	self:CreateOrderInfo(orderId, money, accept, pickUpPos, deliveryPos)
	gMessageManager:SendMessage(gEventConstants.DELIVERY_SPOON_ORDER_DATA_CHANGED)
end

function M:GetSpoonCustomOrderData()
	return self.spoonCustomOrderData
end

function M:SetDeliveryGuideHUDState(isOpen, isNeedOrder, orderId, eventId)
	self:OnJobStateChange(isOpen and DeliveryJobId or gSpiritJobManager.GetCurSpiritJobClassId(), false, false, true)

	if isOpen then
		if isNeedOrder then
			self:CreateOrderInfo(orderId, 0, true)
		end

		if not self.spoonCustomOrderData or not self.spoonCustomOrderData.orders or not self.spoonCustomOrderData.orders[1] then
			return
		end

		self.spoonCustomOrderData.orders[1].AcceptInfo.AcceptedEventId = eventId

		self:AddOrderInfo(self.spoonCustomOrderData.orders[1])
	end
end

function M:SetDeliveryIsInTeachingTask(isInTask)
	self.isInTeachingTask = isInTask

	gMessageManager:SendMessage(gEventConstants.DELIVERY_TEACHING_TASK_STATE_CHANGED)
end

function M.TryGetDefaultSelectVehicle(supportConfig)
	local selectVehicleId = nil

	if supportConfig and supportConfig.vehicleId then
		local lastQuality = 99999
		local unlockedVehicles = gApplyCarManager.UnlockedVehicles
		local defaultVehicleId = supportConfig.vehicleId

		for _, vehicleInfo in ipairs(unlockedVehicles) do
			if vehicleInfo.Id > 0 and table.contains(defaultVehicleId, vehicleInfo.Id) then
				local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleInfo.Id)

				if vehicleCfg.VehicleQuality < lastQuality then
					selectVehicleId = vehicleInfo.Id
					lastQuality = vehicleCfg.VehicleQuality
				end
			end
		end
	end

	return selectVehicleId
end

function M.CallOpenDrone(supportConfig)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.DRONE,
		supportConfig = supportConfig
	})
end

function M.CallOpenCallCar(supportConfig)
	gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local callCarInfo = LTConfig.PhoneConfig.ShortCutCallCar
		local contactOptionId = gCallPhoneUtils.GetContactOptionId(callCarInfo.contactId)
		local contactCfg = LTConfig.PhoneContactConfig.GetConfig(callCarInfo.contactId)
		gCallPhoneUtils.currentDialogPhoneNumber = contactCfg.PhoneNumber

		gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
			secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.CallCar,
			supportConfig = supportConfig,
			clientTruckOrderView = clientTruckOrderView,
			onCustomConfirmCallback = function (selectedVehicleId)
				gCallPhoneUtils.CallVehicle(selectedVehicleId, contactOptionId)
			end,
			onDestroyCallback = function ()
				gMessageManager:SendMessage(gEventConstants.HIDE_DIALOG_INCALL_MESSAGE, false)
			end
		})
	end
end

function M.RunSupportDetailCallFunc(supportConfig)
	if supportConfig and supportConfig.DetailCallFunc then
		local funcStr = string.format("Call%s", supportConfig.DetailCallFunc)
		local f = gDeliveryTaskManager[funcStr]

		if f then
			local status, err = xpcall(f, tolua.traceback, supportConfig)

			return status, err
		end
	end

	return false
end

function M.CheckHasDroneAgent()
	local agnetId = gBattleMgr.SummonAgentId
	local unit = gCS.SceneDataMgr.GetUnit(agnetId)

	if unit and unit.ClientData.AgentId > 0 then
		local agentCfg = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)

		if agentCfg then
			return agentCfg.SummonTag == LTConfig.SummonConfig.UAV
		end
	end

	return false
end

function M.DoDroneSupport(skillId)
	if skillId then
		if gDeliveryTaskManager.CheckHasDroneAgent() then
			gClientToGameSceneDelegate:AskStopControlAgent(true)
		else
			gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, skillId)
		end
	end
end

function M.TryGetDroneState()
	local agentId = gBattleMgr.SummonAgentId
	local unit = gCS.SceneDataMgr.GetUnit(agentId)

	if unit then
		local uavModule = LX6.Units.Module.UAV.UAVMotionModifier.GetModule(unit)

		if uavModule then
			return uavModule.logicState
		end
	end

	return nil
end

function M:CheckIsAuto()
	return self.isDeliveryJob and self.isAuto
end

function M:SetIsAuto(isAuto)
	if self.isAuto ~= isAuto then
		self.isAuto = isAuto

		gMessageManager:SendMessage(gEventConstants.DELIVERY_AUTO_TAKE_ORDER_CHANGED)
	end
end

function M:AskAutoAcceptTruckJobOrder(desiredAuto)
	gClientToGameDelegate:AskAutoAcceptTruckJobOrder(desiredAuto).Callback = function (errorId, isAuto)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gDeliveryTaskManager:SetIsAuto(isAuto)
	end
end

gDeliveryTaskManager = gDeliveryTaskManager or C_DeliveryTaskManager.new()

return gDeliveryTaskManager
