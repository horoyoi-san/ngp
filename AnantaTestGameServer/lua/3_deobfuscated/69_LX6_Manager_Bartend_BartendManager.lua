local BartenderConfig = LTConfig.BartenderConfig
local ElementsConfig = LTConfig.BartenderElementsConfig
local DrinkMenuConfig = LTConfig.BartenderDrinkMenuConfig
local MenuStepConfig = LTConfig.BartenderMenuStepConfig
local ElementType = ElementsConfig.TypeType
local TalkBeforeOrderConfig = LTConfig.BartenderTalkBeforeOrderConfig
local CustomerSuperConfig = LTConfig.BartenderCustomerSuperConfig
local OrderTypeConfig = LTConfig.BartenderOrderTypeConfig
local ABPVarConfig = LTConfig.ABPVarConfig
local ABPVarManager = MuGenStates.Logic.ABPVarManager
local AgentConfig = LTConfig.AgentConfig
local GameInputManager = LX6.Manager.GameInputManager
local JOB_ID = 11300010
local SIGNAL_GET_INGREDIENT = 1603
local SIGNAL_POUR_INGREDIENT = 1604
local SIGNAL_STOP_POURING = 1605
local SIGNAL_POUR_IN_SHAKER = 1606
local SIGNAL_START_SHAKE = 1609
local SIGNAL_PERFECT_SHAKE = 1610
local SIGNAL_DELIVER = 1611
local SIGNAL_ADD_ICE = 1612
local SIGNAL_GET_GLASS_LEFT_HAND = 1616
local SIGNAL_NORMAL_SHAKE = 1617
local SIGNAL_RETURN_COMMON = 1618
local SIGNAL_DRINK = 1619
local SIGNAl_END = 1621
local SIGNAL_NPC_START_MOVE = 1624
local OUT_SIGNAL_RETURN_COMPLETE = 1300
local OUT_SIGNAL_DELIVER_COMPLETE = 1301
local OUT_SIGNAL_START_POUR_SHAKE = 1302
local OUT_SIGNAL_PICK_COMPLETE = 1303
local OUT_SIGNAL_PICK_START = 1304
local OUT_SIGNAL_RETURN_START = 1305
local OUT_SIGNAL_NPC_DRINK_END = 1306
local MIXER_NAME = "混合液体"
local MIXER_ID = 99999999
local MIXER_COLOR = "FFFFFF"
local StatusCtrlType = {
	PickIngredientAndAimContainer = 2,
	EmptyHand = 0,
	PickCupAndAimNPC = 4,
	Pour = 3,
	Pick = 1,
	PickCup = 6,
	Empty = 5
}
local PourCtrlType = {
	Ready = 1,
	Pouring = 2,
	Normal = 0
}
local ShakerCtrlType = {
	Ready = 1,
	Going = 2,
	Normal = 0
}
local HoverType = {
	NPC = 2,
	ELEMENT = 3,
	TABLE = 1,
	NONE = 0
}
local UnBindType = {
	EXCHANGEPOUR = 4,
	EXCHANGE = 3,
	SHAKE = 2,
	ORIGIN = 1,
	TABLE = 0
}
local CustomerType = {
	Normal = 3,
	Story = 1,
	Super = 2
}
local CustomerAnimState = {
	Drink = 5,
	Angry = 3,
	Chat = 1,
	Performance = 4,
	Wait = 2
}
local CustomerWaitState = {
	Leave = 3,
	Angry = 2,
	Normal = 1
}
local CustomerSPLevel = {
	IRRITABLE = 2,
	SAD = 1,
	HAPPY = 4,
	RELAX = 3
}
local OrderType = {
	Tag = 2,
	Clear = 1,
	Cp = 3
}
local FSMState = {
	Pour = 3,
	Waiting = 1,
	Shake = 4,
	Deliver = 5,
	Normal = 2
}
local FSMTransition = {
	Waiting_Normal = 1,
	Normal_Waiting = 8,
	Pour_Normal = 3,
	Shake_Normal = 5,
	Normal_Pour = 2,
	Normal_Deliver = 6,
	Shake_Deliver = 9,
	Pour_Waiting = 10,
	Shake_Waiting = 11,
	Normal_Shake = 4,
	Deliver_Waiting = 7
}
local PANEL_ID = gPanelId.S_BARTENDER_MAIN_PANEL
C_BartendManager = DefClass("C_BartendManager", C_BartendManager)
local M = C_BartendManager

function M:ctor()
	self.SpoonSendType = {
		EndPerformance = 2,
		ShowPos1 = 5,
		StartPerformance = 1,
		HidePos2 = 8,
		HidePos1 = 6,
		HidePos3 = 10,
		ShowPos2 = 7,
		UIExit = 3,
		MakeGrade = 4,
		ShowPos3 = 9
	}
	self.FSM = nil
	self.isPlaying = false
	self.cfg = nil
	self.store = nil
	self.curCheckMenuCfg = nil
	self.drinkMenuCfg = nil
	self.allStepCfg = {}
	self.shakeStepIndex = 0
	self.shakeStepCfg = nil
	self.placePosId = nil
	self.curCustomerData = nil
	self.updateHandler = nil
	self.beforeShakeCheckList = nil
	self.afterShakeCheckList = nil
	self.ingredientElementList = {}
	self.posList = {}
	self.maxPosCount = 3
	self.talkCfg = nil
	self.orderTypeCfg = nil
	self.isLoadScene = false
	self.sceneNodeOp = nil
	self.sceneNodeGo = nil
	self.sceneNode = nil
	self.tableCollider = nil
	self.pourCameraList = {}
	self.performCameraList = {}
	self.curHoverType = HoverType.NONE
	self.curHoverCollider = nil
	self.curHoverElementData = nil
	self.curTableHitPos = nil
	self.isHoldItem = false
	self.curRightHoldElementData = nil
	self.curRightHoldContainerData = nil
	self.curLeftHoldElementData = nil
	self.elementList = {}
	self.elementColliderDic = {}
	self.containerDataDic = {}
	self.talkLibrary = {}
	self.isRealPouring = false
	self.curGlassComp = nil
	self.curHoverContainerData = nil
	self.curVolumeList = nil
	self.curAddVolume = nil
	self.curRemoveVolume = nil
	self.x = 0
	self.y = 0
	self.isCurShakePerfect = false
	self.maxTemperature = 0
	self.minTemperature = 0
	self.minPerfectTemperature = 0
	self.maxPerfectTemperature = 0
	self.curTemperature = 0
	self.isLockInput = false
	self.facingLerpSpeed = 5
	self.lastFacingVector = nil
	self.meUnit = nil
	self.waitTimer = nil
	self.signalHandler = nil
	self.pickStartAction = nil
	self.putStartAction = nil
	self.dialogShowEndHandler = nil
	self.dialogEndHandler = nil
end

function M:ClearPlayData()
	self.store = nil
	self.curMenuId = nil
	self.curCheckMenuCfg = nil
	self.drinkMenuCfg = nil
	self.beforeShakeSteps = {}
	self.afterShakeSteps = {}
	self.placePosId = nil
	self.curHoverType = HoverType.NONE
	self.curHoverCollider = nil
	self.curHoverElementData = nil
	self.curTableHitPos = nil
	self.isHoldItem = false
	self.curRightHoldElementData = nil
	self.curRightHoldContainerData = nil

	for i = 1, #self.containerDataDic do
		local containerData = self.containerDataDic[i]

		containerData.glass:ResetFluid()
	end

	self.isRealPouring = false
	self.curGlassComp = nil
	self.curHoverContainerData = nil
	self.curVolumeList = nil
	self.curAddVolume = nil
	self.curRemoveVolume = nil
	self.x = 0
	self.y = 0
	self.isCurShakePerfect = false
	self.maxTemperature = 0
	self.minTemperature = 0
	self.minPerfectTemperature = 0
	self.maxPerfectTemperature = 0
	self.curTemperature = 0

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	if self.signalHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL, self.signalHandler)

		self.signalHandler = nil
	end

	if self.mouseMoveMsg then
		gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.mouseMoveMsg)

		self.mouseMoveMsg = nil
	end

	if self.mouseScrollAction then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollAction)

		self.mouseScrollAction = nil
	end

	self:ClearDialogHandler()

	self.pickStartAction = nil
	self.putStartAction = nil

	for i, v in ipairs(self.pourCameraList) do
		if v and not gCS.LuaUtils.IsNull(v) and not gCS.LuaUtils.IsNull(v.gameObject) then
			v.gameObject:SetActive(false)
		end
	end

	for i, v in ipairs(self.performCameraList) do
		if v and not gCS.LuaUtils.IsNull(v) and not gCS.LuaUtils.IsNull(v.gameObject) then
			v.gameObject:SetActive(false)
		end
	end

	self:SetLockActionAndView(false)
end

function M:OnBeforeSwitchScene()
	self:ClearAllData()
end

function M:ClearAllData()
	self:UnRegisterUpdate()
	self:ClearPlayData()

	self.cfg = nil
	self.isLoadScene = false

	if self.sceneNodeGo then
		gResourceManager:UnloadAssetLoadOp(self.sceneNodeOp)
	end

	self.sceneNodeOp = nil

	if self.sceneNodeGo and not gCS.LuaUtils.IsNull(self.sceneNodeGo) then
		GameObject.Destroy(self.sceneNodeGo)
	end

	self.sceneNodeGo = nil
	self.sceneNode = nil
	self.tableCollider = nil
	self.pourCameraList = {}
	self.performCameraList = {}

	if self.posList then
		for i, v in pairs(self.posList) do
			if v then
				self:TrueLeave(v.id)
			end

			self:SetShowInteractionBtn(i, false)
		end
	end

	self.posList = {}
	self.maxPosCount = 3
	self.elementList = {}
	self.elementColliderDic = {}
	self.containerDataDic = {}
	self.meUnit = nil
end

function M:SpoonEnterBartender(param)
	local bartenderId = param.bartenderId
	local entityInstanceId = param.entityInstanceId
	local gameObject = param.gameObject

	self:ClearAllData()

	self.bartenderId = bartenderId
	self.entityInstanceId = entityInstanceId
	local bartenderCfg = BartenderConfig.GetConfig(bartenderId)

	if not bartenderCfg then
		print_error("[Bartender]未找到BartenderConfig，bartenderId=" .. bartenderId)

		return
	end

	self.cfg = bartenderCfg
	self.meUnit = gCS.MyPlayerManager.PlayerUnit

	self:LoadSceneNode(gameObject)
	self:InitFSM()
	self:InitTalkLibrary()
	self:RegisterUpdate()

	for i = 1, self.maxPosCount do
		self.posList[i] = nil
	end
end

function M:ExitBartender()
	if not self.isLoadScene then
		return
	end

	self:ClearAllData()
	gClientToGameGMDelegate:GmClearBartenderGame()
	gClientToGameGMDelegate:GmJobEnd()
	gClientToGameGMDelegate:GmJobQuit(JOB_ID)
end

function M:SpoonBartenderNPC(param)
	local posId = param.posId
	self.currentPosId = posId

	if not self.FSM or self:GetFSMState() ~= FSMState.Waiting then
		print_error("[Bartender]状态机异常，当前状态不允许对话，state=" .. tostring(self:GetFSMState()))

		return
	end

	self:ClearPlayData()

	if self.maxPosCount < posId then
		print_error("[Bartender]placePosId超出范围，placePosId=" .. posId)

		return
	end

	local customer = self.posList[posId]

	if not customer then
		print_error("[Bartender]当前座位无NPC，placePosId=" .. posId)

		return
	end

	if customer.state ~= CustomerAnimState.Wait and customer.state ~= CustomerAnimState.Angry then
		print_error("[Bartender]当前NPC状态异常，无法对话，state=" .. tostring(customer.state))

		return
	end

	self.curCustomerData = customer

	if customer.talked then
		if not customer.drinkMenuCfg then
			print_error("[Bartender]当前NPC对话已结束但未选择配方，placePosId=" .. posId)
		else
			gBartendManager:StartBartend()

			return
		end
	end

	customer.talked = true

	self:SetCustomerState(customer, CustomerAnimState.Chat)
	self:SetActiveCustomerTimer(customer, false)
	self:ClearDialogHandler()

	local talkCfg = nil

	if customer.customerType == CustomerType.Normal then
		talkCfg = self:GetRandomTalkBySpLevel(customer.spLevel)
	else
		local index = customer.superCfg.TalkBeforeOrderDialogID
		talkCfg = TalkBeforeOrderConfig.LoadAt(index - 1)
	end

	if not talkCfg then
		print_error("[Bartender]未找到合适的对话，customerAgentId=" .. tostring(customer.agentCfg.Id))

		return
	end

	self.talkCfg = talkCfg

	function self.dialogShowEndHandler(eventId, dialogId)
		for i, v in ipairs(talkCfg.AnswerScore) do
			if v.DialogId == dialogId then
				self:ClearDialogEndHandler()

				gBartendManager.curCustomerData.spScoreModify = gBartendManager.curCustomerData.spScoreModify + v.SPScoreChange

				print_debug("[Bartender]对话单句结束回调，dialogId=" .. tostring(dialogId) .. "，SPScoreChange=" .. tostring(v.SPScoreChange))

				return
			end
		end
	end

	function self.dialogEndHandler(eventId, firstDialogId)
		print_debug("[Bartender]对话整段结束回调，dialogId=" .. tostring(firstDialogId))
		self:ClearDialogHandler()
		gBartendManager:ShowOrderDialog()
	end

	gMessageManager:AddMessageListener(gEventConstants.DIALOG_SHOW_END, self.dialogShowEndHandler)
	gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.dialogEndHandler)
	gDialogManager:ShowGeneralDialog(talkCfg.DialogID, gDialogSource.Bartender)
end

function M:ShowOrderDialog()
	if not self.curCustomerData then
		print_error("[Bartender]当前客户数据为空，无法点单")

		return
	end

	local orderType = 1
	local menuId = 0
	local dialogId = 0
	local orderTypeCfg = 0

	if self.curCustomerData.customerType == CustomerType.Normal then
		orderType = self:GetRandomOrderType()

		if orderType == OrderType.Clear then
			local menuList = self.cfg.DrinkMenuList
			menuId = menuList[math.random(1, #menuList)]
		else
			orderTypeCfg = self:GetRandomCfg(OrderTypeConfig)
		end
	else
		local orderTypeInfo = self.curCustomerData.superCfg.OrderType
		orderType = OrderType[orderTypeInfo.OrderType]

		if orderType == OrderType.Clear then
			menuId = orderTypeInfo.DrinkMenuID
		else
			orderTypeCfg = OrderTypeConfig.GetConfig(orderTypeInfo.OrderTypeID)
		end
	end

	self:ClearDialogHandler()

	if orderType == OrderType.Clear then
		local menuCfg = DrinkMenuConfig.GetConfig(menuId)

		if not menuCfg then
			print_error("[Bartender]未找到BartenderDrinkMenuConfig，menuId=" .. menuId)

			return
		end

		print_debug("[Bartender]明确点单，menuId=" .. tostring(menuId))

		self.curCustomerData.drinkMenuCfg = menuCfg
		dialogId = menuCfg.Order_Clear[self.curCustomerData.agentCfg.Personality].dialogID
	else
		if not orderTypeCfg then
			print_error("[Bartender]未找到合适的OrderTypeConfig")

			return
		end

		self.orderTypeCfg = orderTypeCfg
		dialogId = orderTypeCfg.DialogID1
	end

	if dialogId == 0 then
		print_error("[Bartender]未找到点单对话，orderType=" .. tostring(orderType) .. "，menuId=" .. tostring(menuId))

		return
	end

	if not self.curCustomerData.drinkMenuCfg then
		function self.dialogShowEndHandler(eventId, dialogId)
			print_debug("[Bartender]对话单句结束回调，dialogId=" .. tostring(dialogId))

			for i, v in ipairs(orderTypeCfg.TagMenu1) do
				if v.DialogID == dialogId then
					self:ClearDialogShowEndHandler()
					print_debug("[Bartender]根据对话选择配方，dialogId=" .. tostring(dialogId) .. "，MenuID=" .. tostring(v.MenuID))

					gBartendManager.curCustomerData.drinkMenuCfg = DrinkMenuConfig.GetConfig(v.MenuID)

					break
				end
			end
		end

		gMessageManager:AddMessageListener(gEventConstants.DIALOG_SHOW_END, self.dialogShowEndHandler)
	end

	function self.dialogEndHandler(eventId, firstDialogId)
		print_debug("[Bartender]对话整段结束回调，dialogId=" .. tostring(firstDialogId))
		self:ClearDialogHandler()
		gBartendManager:SetCustomerState(gBartendManager.curCustomerData, CustomerAnimState.Wait)
		gBartendManager:SetActiveCustomerTimer(gBartendManager.curCustomerData, true)
		gBartendManager:StartBartend()
	end

	gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.dialogEndHandler)
	gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Bartender)
end

function M:RegisterUpdate()
	self.updateHandler = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandler)
end

function M:UnRegisterUpdate()
	if self.updateHandler then
		UpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end
end

function M:Update()
	for i, v in ipairs(self.posList) do
		if v then
			if not v.isTimerActive then
				-- Nothing
			else
				v.waitTimer = v.waitTimer + Time.deltaTime

				if v.waitState == CustomerWaitState.Normal and v.angryTime <= v.waitTimer then
					self:ResetCustomerTimer(v)

					v.waitState = CustomerWaitState.Angry

					self:SetCustomerState(v, CustomerAnimState.Angry)
				elseif v.waitState == CustomerWaitState.Angry and v.leaveTime <= v.waitTimer then
					self:SetActiveCustomerTimer(v, false)

					v.waitState = CustomerWaitState.Leave

					self:AskCustomerLeave(v)
				end
			end
		end
	end
end

function M:StartBartend()
	if not self.isLoadScene then
		print_error("[Bartender]场景节点未加载，无法开始调酒")

		return
	end

	if not self.curCustomerData then
		print_error("[Bartender]当前客户数据为空，无法开始调酒")

		return
	end

	if not self.curCustomerData.drinkMenuCfg then
		print_error("[Bartender]未找到配方")

		return
	end

	self.lastFacingVector = self.meUnit.ClientData.FacingDirection
	self.isPlaying = true
	self.drinkMenuCfg = self.curCustomerData.drinkMenuCfg

	self:LoadMenuCfg()
	print_debug("[Bartender]开始调酒，menuId=" .. tostring(self.drinkMenuCfg.Id))
	gPanelManager:CheckShow(PANEL_ID)

	function self.signalHandler(_, data)
		gBartendManager:HandleGamePlayOutwardSignal(data)
	end

	gMessageManager:AddMessageListener(gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL, self.signalHandler)
	gClientToGameGMDelegate:GmStartBartenderGame(self.cfg.Id)
end

function M:LoadMenuCfg()
	self.allStepCfg = self.drinkMenuCfg.MenuStep

	for i, v in pairs(self.drinkMenuCfg.MenuStep) do
		local cfg = MenuStepConfig.GetConfig(v)

		if cfg.ActionType == MenuStepConfig.ActionTypeType.Shake then
			self.shakeStepCfg = cfg
			self.shakeStepIndex = i
		end
	end

	self.beforeShakeCheckList = {}
	self.afterShakeCheckList = {}

	for index, _ in ipairs(self.allStepCfg) do
		if self.shakeStepIndex == 0 or index < self.shakeStepIndex then
			self.beforeShakeCheckList[index] = false
		else
			self.afterShakeCheckList[index] = false
		end
	end

	for i, v in pairs(self.containerDataDic) do
		v.beforeShakeCheckList = table.clone(self.beforeShakeCheckList)
		v.afterShakeCheckList = table.clone(self.afterShakeCheckList)
	end
end

function M:HandleGamePlayOutwardSignal(data)
	local signalId = data:GetCfgId()

	if signalId == OUT_SIGNAL_RETURN_START then
		if self.putStartAction then
			self.putStartAction()

			self.putStartAction = nil
		end
	elseif signalId == OUT_SIGNAL_PICK_START then
		if self.pickStartAction then
			self.pickStartAction()

			self.pickStartAction = nil
		end
	elseif signalId == OUT_SIGNAL_DELIVER_COMPLETE then
		self.store:SetTempCtrl(0)

		if self.isCurShakePerfect then
			gSpoonClientMgr:ReleaseContextEvent(gBartendManager.entityInstanceId, gSpoonEventType.MessageTrigger, {
				message = gEventConstants.BARTENDER_SIGNAL,
				param = self.SpoonSendType.EndPerformance
			})
			self.FSM:SendSignal(FSMTransition.Shake_Deliver)
			self:NPCEndPerformance()
		else
			self.FSM:SendSignal(FSMTransition.Normal_Deliver)
		end
	elseif signalId == OUT_SIGNAL_START_POUR_SHAKE then
		if self:GetFSMState() == FSMState.Pour then
			-- Nothing
		elseif self:GetFSMState() == FSMState.Shake then
			function self.mouseMoveMsg(eventId, delta)
				self:OnShake(delta)
			end

			gMessageManager:AddMessageListener(gEventConstants.MOUSE_MOVE, self.mouseMoveMsg)
		else
			print_error("[Bartender]状态机异常，当前状态不允许开始倒酒或摇壶，state=" .. tostring(self:GetFSMState()))
		end
	elseif signalId == OUT_SIGNAL_PICK_COMPLETE or signalId == OUT_SIGNAL_RETURN_COMPLETE then
		self:SetLockActionAndView(false)
	elseif signalId == OUT_SIGNAL_NPC_DRINK_END then
		self:OnNPCDrinkEnd()
	end
end

function M:EndBartend()
	self.isPlaying = false

	if self.FSM and self:GetFSMState() ~= FSMState.Waiting then
		self.FSM:SendSignalSmartImmediately(FSMState.Waiting)
	else
		self:OnWaitingEnter()
		print_error("[Bartender]状态机异常为空，请注意检查")
	end

	gClientUtils.SetCameraRotateEnabled(true)
	gPanelManager:Close(PANEL_ID)
	gSpoonClientMgr:ReleaseContextEvent(gBartendManager.entityInstanceId, gSpoonEventType.MessageTrigger, {
		message = gEventConstants.BARTENDER_SIGNAL,
		param = self.SpoonSendType.UIExit
	})
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAl_END)
	self:ResetElementList()
	self:ClearPlayData()

	for i, v in ipairs(self.posList) do
		if v and v.waitState ~= CustomerWaitState.Leave and v.state ~= CustomerAnimState.Drink then
			self:SetShowInteractionBtn(i, true)
		else
			self:SetShowInteractionBtn(i, false)
		end
	end
end

function M:OnSyncCustomerInfo(customerInfo)
	if not customerInfo then
		print_error("[Bartender]收到客户信息同步，数据为空")

		return
	end

	for i, v in ipairs(customerInfo) do
		if not self.isLoadScene then
			print_error("[Bartender]场景节点未加载，无法处理客户，id=" .. ulong.tostring(v.Id))
			self:TrueLeave(v.Id)
		elseif not v or not v.Id then
			print_error("[Bartender]收到客户信息同步，数据异常")
		else
			local pos = self:GetEmptyPos()

			if pos == -1 then
				print_debug("[Bartender]座位已满，无法加载更多客户，id=" .. ulong.tostring(v.Id))
				self:TrueLeave(v.Id)
			else
				self:LoadCustomer(v, pos)
				self:SetShowInteractionBtn(pos, true)
			end
		end
	end
end

function M:OnStoreAwake()
	self.FSM:SendSignal(FSMTransition.Waiting_Normal)
end

function M:InitFSM()
	if self.FSM then
		self.FSM:Dispose()

		self.FSM = nil
	end

	self.FSM = gFSMManager:GetFSM(self)

	self.FSM:AddStates(FSMState)
	self.FSM:AddTransitions(FSMState, FSMTransition)
	self.FSM:SetInitState(FSMState.Waiting)
end

function M:InitTalkLibrary()
	local cfg, spList = nil

	for i = 0, TalkBeforeOrderConfig.count - 1 do
		cfg = TalkBeforeOrderConfig.LoadAt(i)

		if not cfg.IsCustomerSuper then
			spList = cfg.SPLevelList

			for j, v in ipairs(spList) do
				if not self.talkLibrary[v] then
					self.talkLibrary[v] = {}
				end

				table.insert(self.talkLibrary[v], cfg)
			end
		end
	end
end

function M:LoadSceneNode(parent)
	self.isLoadScene = true
	local sceneNodePath = self.cfg.BartenderSceneNodeName
	self.sceneNodeOp = gResourceManager:LoadAssetWithCallBack(sceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		local sceneNodeGo = UnityEngine.GameObject.Instantiate(loadOp.asset)
		sceneNodeGo.gameObject.name = "BartenderSceneNode"

		sceneNodeGo.gameObject.transform:SetParent(parent.transform)
		sceneNodeGo.gameObject.transform:SetLocalPosition(Vector3.zero)

		sceneNodeGo.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		self.sceneNodeGo = sceneNodeGo

		self:InitSceneNode()
		self:OnSceneLoadComplete()
	end)
end

function M:InitSceneNode()
	self.sceneNode = self.sceneNodeGo.transform:GetComponent(typeof(L18.Gameplay.BartenderSceneNode))

	self:LoadElementList()

	if not self.sceneNode.bartendTableCollider then
		print_error("[Bartender]未找到bartendTableCollider")
	end

	self.tableCollider = self.sceneNode.bartendTableCollider

	for i = 0, self.sceneNode.pourCameraList.Count - 1 do
		local v = self.sceneNode.pourCameraList[i]

		if not v or gCS.LuaUtils.IsNull(v) then
			print_error("[Bartender]未找到pourCameraList相机，index=" .. tostring(i))

			break
		end

		table.insert(self.pourCameraList, v:GetComponent(typeof(Cinemachine.CinemachineVirtualCamera)))
	end

	for i = 0, self.sceneNode.performCameraList.Count - 1 do
		local v = self.sceneNode.performCameraList[i]

		if not v or gCS.LuaUtils.IsNull(v) then
			print_error("[Bartender]未找到performCameraList相机组件，index=" .. tostring(i))

			break
		end

		table.insert(self.performCameraList, v:GetComponent(typeof(Cinemachine.CinemachineVirtualCamera)))
	end
end

function M:OnSceneLoadComplete()
	gClientToGameGMDelegate:GmJobTake(JOB_ID).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			print_error("[Bartender]请求获取调酒职业失败，err=" .. gCS.Error.GetNameById(err))

			return
		end

		gClientToGameGMDelegate:GmJobStart(JOB_ID).Callback = function (err1)
			if err1 ~= LTConfig.MessageConfig.Ok then
				print_error("[Bartender]请求开始调酒职业失败，err=" .. gCS.Error.GetNameById(err1))
			end

			gClientToGameDelegate:AskStartBartenderGame(gBartendManager.cfg.Id).Callback = function (err2)
				if err2 ~= LTConfig.MessageConfig.Ok then
					print_error("[Bartender]请求进入调酒职业失败，err=" .. gCS.Error.GetNameById(err2))
				end
			end
		end
	end
end

function M:LoadCustomer(info, pos)
	local go = self.sceneNode.customerPointList[pos - 1]
	local unit = gCS.SceneDataMgr.GetUnit(info.Id)
	unit.PlayerObj.position = go.transform.position
	unit.PlayerObj.eulerAngles = go.transform.eulerAngles
	local clientData = unit.ClientData
	local agentId = clientData.AgentId > 0 and clientData.AgentId or clientData.SubType
	local agentCfg = AgentConfig.GetConfig(agentId)
	local customer = {
		id = info.Id,
		agentCfg = agentCfg,
		unit = unit,
		collider = unit.HitCollider,
		name = unit.HitCollider.gameObject.name,
		customerType = info.Type,
		waitState = CustomerWaitState.Normal
	}
	local angryTime = math.random(self.cfg.WaitTime_Angry.minT_Angry, self.cfg.WaitTime_Angry.maxT_Angry)
	local leaveTime = math.random(self.cfg.WaitTime_Leave.minT_Leave, self.cfg.WaitTime_Leave.maxT_Leave)
	customer.angryTime = angryTime
	customer.leaveTime = leaveTime
	customer.spScoreModify = 0
	local spLevel = 1

	if customer.customerType == CustomerType.Normal then
		spLevel, customer.originSPScore = self:GetNormalSPLevelAndValue()
	else
		local superCfg = self:GetSuperCfgByAgentId(agentId)
		customer.superCfg = superCfg
		spLevel = self:GetSPLevelByValue(superCfg.StartSp)
		customer.originSPScore = superCfg.StartSp
	end

	self:ResetCustomerTimer(customer)
	self:SetActiveCustomerTimer(customer, true)
	print_debug(string.format("加载客户，AgentID=%s，id=%s，CustomerType=%d，SPLevel=%d，OriginSPScore=%d", tostring(agentId), ulong.tostring(customer.id), customer.customerType, spLevel, customer.originSPScore))

	self.posList[pos] = customer

	if self.store then
		self.store:OnNpcEnter(customer)
	end

	Timer.New(function ()
		if self.FSM and self.posList[pos] then
			self:SetCustomerSPLevel(customer, spLevel)
			self:SetCustomerState(customer, CustomerAnimState.Wait)
			self:SetCustomerPersonality(customer, agentCfg.Personality)
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, SIGNAL_NPC_START_MOVE)
		end
	end, 0.5, false):Start()
end

function M:LoadElementList()
	self.elementList = {}
	self.elementColliderDic = {}
	self.ingredientElementList = {}

	for i, v in ipairs(self.cfg.SceneElements) do
		local go = self.sceneNode.elementPointList[v.prefabID - 1]
		local cfg = ElementsConfig.GetConfig(v.ElementsID)

		self:LoadElementInfo(cfg, go, v.prefabID)
	end
end

function M:LoadElementInfo(cfg, parent, prefabID)
	local path = cfg.FileName

	gResourceManager:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		if not loadOp or not loadOp.asset then
			print_error("[Bartender]调酒元素资源加载失败，path=" .. path)

			return
		end

		local go = UnityEngine.GameObject.Instantiate(loadOp.asset)

		go.gameObject.transform:SetParent(parent.transform)
		go.gameObject.transform:SetLocalPosition(Vector3.zero)

		go.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)

		go.gameObject:SetActive(true)

		local colliderGo = go.transform:Find("Collider")
		local collider = nil

		if not colliderGo then
			print_error("[Bartender]未找到Collider节点，path=" .. path)
		else
			collider = colliderGo:GetComponent(typeof(UnityEngine.Collider))
		end

		local data = {
			parent = parent,
			go = go,
			cfg = cfg,
			collider = collider
		}
		self.elementList[prefabID] = data

		if cfg.Type == ElementType.Drink or cfg.Type == ElementType.Bottle then
			table.insert(self.ingredientElementList, data)
		end

		if not collider then
			print_error("[Bartender]未找到Collider，path=" .. path)
		else
			self.elementColliderDic[collider] = data
		end

		if cfg.Type == ElementType.Cup or cfg.Id == 87005240 then
			local container = {
				glass = go:GetComponent(typeof(L18.Gameplay.BartenderGlass)),
				volumeList = {},
				iceAdded = false,
				isShaken = false,
				ozLimit = cfg.OzLimit,
				isInUse = false
			}

			if not container.glass then
				print_error("[Bartender]未找到BartenderGlass组件，path=" .. path)
			end

			self.containerDataDic[cfg.Id] = container

			if cfg.Id == 87005240 then
				data.glassBody = go.transform:Find("linshi_dj_A706006_gm").gameObject
			else
				data.glassBody = go.transform:Find("GlassBody").gameObject
			end
		end
	end)
end

function M:ResetElementList()
	for i, v in pairs(self.elementList) do
		GameObject.Destroy(v.go)
	end

	self:LoadElementList()
end

function M:AskCustomerLeave(customer)
	if not customer then
		print_error("[Bartender]客户数据为空，无法离开")

		return
	end

	if self.store then
		self.store:OnNpcLeave(customer)
	end

	if customer == self.curCustomerData then
		self:EndBartend()
	end

	self:TrueLeave(customer.id)

	local _, index = table.find(self.posList, customer)

	if not index then
		print_error("[Bartender]未找到客户数据，id=" .. customer.id)

		return
	else
		self.posList[index] = nil
	end
end

function M:TrueLeave(id)
	gClientToGameDelegate:AskBartenderCustomerLeave(id).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			print_error("[Bartender]客人离开失败，err=" .. gCS.Error.GetNameById(err))
		end
	end
end

function M:OnWaitingEnter()
	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(0.5)
end

function M:OnWaitingToNormalTransition()
	self.store = gStoreManager:GetStoreGroup("BartenderMainPanelStore")
end

function M:OnNormalEnter()
	self:SetLockActionAndView(false)
	self:SetUIStatus(StatusCtrlType.EmptyHand)
	self.store:SetPourCtrl(PourCtrlType.Normal)
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByCfgId(self.cfg.Camera, 1)
end

function M:OnCameraUpdate()
	if self:GetFSMState() ~= FSMState.Normal then
		return
	end

	self:SetMeFacing()

	if self.isLockAction then
		return
	end

	self:RaycastCheck()
	self:RefreshUIStatus()
end

function M:RaycastCheck()
	local screenCenter = Vector3.New(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2, 0)
	local hitInfo = gCS.LuaUtils.RaycastByScreenPos(screenCenter, LX6.Constants.LayerConstants.AllWithoutPlayer)

	if not hitInfo.collider then
		self.curHoverType = HoverType.NONE

		self.store:SetVolumeCtrl(false)
		self.store:SetTipsCtrl(false)

		return
	end

	if self.curHoverCollider and hitInfo.collider == self.curHoverCollider then
		if self.curHoverType == HoverType.TABLE then
			self.curTableHitPos = hitInfo.point
		end

		return
	end

	print_debug("[Bartender]hitInfo", hitInfo.collider.gameObject.name)

	if self.outLineEffect then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.outLineEffect)
	end

	self.curHoverCollider = hitInfo.collider
	self.curHoverElementData = nil

	if self:IsHitTable(hitInfo.collider) then
		self.curTableHitPos = hitInfo.point
		self.curHoverType = HoverType.TABLE

		self.store:SetVolumeCtrl(false)
		self.store:SetTipsCtrl(false)

		return
	end

	if self:IsHitNpc(hitInfo.collider) then
		self.curHoverType = HoverType.NPC

		self.store:SetVolumeCtrl(false)
		self.store:SetTipsCtrl(true)
		self.store:SetTipsSimpleContent("交付给顾客")
		self.store:SetTipsTarget(hitInfo.collider.gameObject)

		return
	end

	for i, v in pairs(self.elementColliderDic) do
		if hitInfo.collider == i then
			print_debug("[Bartender]element collider match", v.cfg.ElementsName)

			self.curHoverElementData = v
			self.curHoverType = HoverType.ELEMENT

			self:OnHoverValid(v)

			local effectGo = v.glassBody or v.go
			self.outLineEffect = gCS.EffectMgr:PlayGameObjectMaterialEffect(538000445, "BartenderElementHover", effectGo)

			return
		end
	end

	self.store:SetTipsCtrl(false)

	self.curHoverType = HoverType.NONE
end

function M:OnPourEnter()
	if not self.curGlassComp then
		print_error("[Bartender]@liyachao02 current cup has no BartenderGlass component, cannot pour wine.")

		return
	end

	if self.outLineEffect then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.outLineEffect)
	end

	self:SetUIStatus(StatusCtrlType.Pour)
	self.store:SetPourCtrl(PourCtrlType.Ready)
	self.store:SetShowFloatingHints(false)
	self.store:SetTipsCtrl(false)

	local isShaker = self:IsCurHoldCocktailShaker()

	self:RefreshCheckCondition(self.curHoverContainerData)
	self.store:RefreshMenuList(self.curHoverContainerData)
	self:PourBind()

	self.pourCameraList[self.currentPosId].LookAt = self.curHoverElementData.go.transform

	self.pourCameraList[self.currentPosId].gameObject:SetActive(true)

	local signal = isShaker and SIGNAL_POUR_IN_SHAKER or SIGNAL_POUR_INGREDIENT

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, signal)

	if gCS.LuaUtils.IsNonMobileAdaptive() and not isShaker then
		self.mouseScrollAction = self:CreateAction(self.OnMouseScroll)

		GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollAction)
	end

	if not self.isRealPouring then
		self:OnRealPourEnter()
	end
end

function M:OnPourExit()
	if self.isRealPouring then
		self:OnRealPourExit()
	end

	self.curAddVolume = nil
	self.curRemoveVolume = nil

	self.store:SetShowFloatingHints(true)
	self.store:SetTipsCtrl(true)
	self.pourCameraList[self.currentPosId].gameObject:SetActive(false)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_STOP_POURING)

	if not self.curGlassComp then
		print_error("[Bartender]@liyachao02 glass is nil, cannot end pouring wine.")

		return
	end

	self:PourUnBind()

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.mouseScrollAction then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollAction)
	end
end

function M:PourBind()
	local bottleGo = self.curRightHoldElementData.go

	bottleGo.transform:SetParent(nil)
	self.curGlassComp:BindBottle(bottleGo, true)
	print_debug("[Bartender]StartPourWine, bind hand to bottle." .. bottleGo.name)
	self.sceneNode:PourWineSetTransformTarget(bottleGo.transform, false)
end

function M:PourUnBind()
	local bottleGo = self.curGlassComp:GetBottle().gameObject

	self.sceneNode:PourWineSetTransformTarget(nil, true)
	self.curGlassComp:BindBottle(bottleGo, false)
	self:BindItemToHand(self.curRightHoldElementData)
end

function M:OnRealPourEnter()
	self.isRealPouring = true
	local isShaker = self:IsCurHoldCocktailShaker()

	self:AddNewVolume(self.curHoverContainerData)

	self.curIngredientTarget = self:GetIngredientTarget(self.curRightHoldElementData.cfg.Id)
	self.curAddVolume = self:GetVolumeById(self.curVolumeList, isShaker and MIXER_ID or self.curRightHoldElementData.cfg.Id)
	self.curRemoveVolume = isShaker and self.curRightHoldContainerData.volumeList[1]
	self.originalHeight = self.curGlassComp:GetFluidHeight()
	self.originalPercent = self:GetVolumeById(self.curVolumeList, isShaker and MIXER_ID or self.curRightHoldElementData.cfg.Id).percent

	self.store:SetPourCtrl(PourCtrlType.Pouring)

	self.x = 0
	self.y = 0

	self.curGlassComp:PourWater(Vector2.New(0, 0))

	function self.mouseMoveMsg(_, delta)
		self:OnPourWine(delta)
	end

	gMessageManager:AddMessageListener(gEventConstants.MOUSE_MOVE, self.mouseMoveMsg)
end

function M:OnRealPourExit()
	self.isRealPouring = false

	self.store:SetPourCtrl(PourCtrlType.Ready)
	self.curGlassComp:PourWater(Vector2.New(0, 0))

	if self.mouseMoveMsg then
		gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.mouseMoveMsg)
	else
		print_error("[Bartender]倒酒状态退出时，发现mouseMoveMsg为空，请注意检查")
	end

	self:RefreshCheckCondition(self.curHoverContainerData)
	self.store:RefreshMenuList(self.curHoverContainerData)
end

function M:OnNormalToShakeCheck()
	if not self:CanShake() then
		print_error("[Bartender]当前状态不允许摇壶")

		return false
	end

	return true
end

function M:OnShakeEnter()
	if self.outLineEffect then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.outLineEffect)
	end

	self.curRightHoldContainerData.isShaken = true
	self.maxTemperature = 25
	self.minTemperature = -10
	self.curTemperature = self.maxTemperature

	self.store:SetShakerCtrl(ShakerCtrlType.Going)
	self.store:SetTempCtrl(1)

	if self.shakeStepCfg then
		self.minPerfectTemperature = self.shakeStepCfg.TargetTemp[1]
		self.maxPerfectTemperature = self.shakeStepCfg.TargetTemp[2]

		self.store:SetTempPerfectArea(self.minTemperature, self.maxTemperature, self.minPerfectTemperature, self.maxPerfectTemperature)
	end

	self.store:RefreshTemperatureProgress(1)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_START_SHAKE)
	self:SetLockActionAndView(true)
	gClientUtils.SetCameraRotateEnabled(false)
end

function M:EndShake()
	self.store:SetShakerCtrl(ShakerCtrlType.Normal)
	self.store:SetTempCtrl(0)
	self:SetUIStatus(StatusCtrlType.Empty)
	gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.mouseMoveMsg)
	self.pourCameraList[self.currentPosId].gameObject:SetActive(false)
	gClientUtils.SetCameraRotateEnabled(true)

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	LX6.Units.AnimationManager.SetStateSpeed(self.meUnit, 0, 1)

	if self.shakeStepIndex ~= 0 then
		local isTempPerfect = self:IsPerfectTemperature(self.curTemperature, self.minPerfectTemperature, self.maxPerfectTemperature)
		local isBeforeShakeStepPerfect = table.find(self.curRightHoldContainerData.beforeShakeCheckList, false) == nil
		self.isCurShakePerfect = isTempPerfect and isBeforeShakeStepPerfect
	else
		self.isCurShakePerfect = false
	end

	self:MixVolume(self.curRightHoldContainerData)

	if self.isCurShakePerfect then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_PERFECT_SHAKE)
		self:NPCStartPerformance()
	else
		self.FSM:SendSignal(FSMTransition.Shake_Normal)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_NORMAL_SHAKE)
	end
end

function M:OnDeliverEnter()
	local accuracyScore = self:GetAccuracyScore(self.curRightHoldContainerData)
	local speedScore = self.store:GetSpeedScore()
	local temperatureScore = self:GetTemperatureScore(self.curRightHoldContainerData)

	print_debug(string.format("accuracyScore=%.2f, speedScore=%.2f, temperatureScore=%.2f", accuracyScore, speedScore, temperatureScore))

	local drinkQualityScore = BartenderConfig.AmountWeight.AmountWeight * accuracyScore + BartenderConfig.TempWeight.TempWeight * temperatureScore + BartenderConfig.TimeWeight.TimeWeight * speedScore
	local guestSatisfactionBonus = self:GetGuestSatisfactionBonus(self.curRightHoldContainerData)

	self:SetUIStatus(StatusCtrlType.Empty)
	self.store:SetCrossHairCtrl(false)
	self.store:SetTipsCtrl(false)
	self.store:SetVolumeCtrl(false)
	self.store:SetShakerCtrl(ShakerCtrlType.Normal)
	self.store:EndGame(accuracyScore, speedScore, temperatureScore)

	if self.curCustomerData.customerType ~= CustomerType.Normal then
		self:SetCustomerState(self.curCustomerData, CustomerAnimState.Chat)
		self:ClearDialogHandler()

		local commentId = self:GetCommentDialogId()

		if not commentId or commentId == 0 then
			print_error("[Bartender]未找到评价对话，直接喝酒")
			self:SetCustomerState(self.curCustomerData, CustomerAnimState.Drink)
		else
			function self.dialogEndHandler(_, firstDialogId)
				print_debug("[Bartender]对话整段结束回调，dialogId=" .. tostring(firstDialogId))
				self:ClearDialogEndHandler()
				gBartendManager:SetCustomerState(gBartendManager.curCustomerData, CustomerAnimState.Drink)
			end

			gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.dialogEndHandler)
			gDialogManager:ShowGeneralDialog(commentId, gDialogSource.Bartender)
		end
	else
		self:SetCustomerState(self.curCustomerData, CustomerAnimState.Drink)
	end

	gClientToGameDelegate:AskBartenderGameSettlement(self.cfg.Id, self.curCustomerData.id, self.drinkMenuCfg.Id, drinkQualityScore, guestSatisfactionBonus).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			print_error("[Bartender]请求调酒奖励结算失败，err=" .. gCS.Error.GetNameById(err))
		end
	end

	self:SetShowInteractionBtn(self.currentPosId, false)

	if self.waitTimer then
		print_error("[Bartender]计时器异常不为空，请注意检查")
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(function ()
		self:EndBartend()
	end, 5):Start()
end

function M:OnNPCDrinkEnd()
	self:AskCustomerLeave(self.curCustomerData)
end

function M:IsHitTable(collider)
	return collider == self.tableCollider
end

function M:IsHitNpc(collider)
	for i, v in pairs(self.posList) do
		if collider == v.collider then
			return true
		end
	end

	return false
end

function M:OnHoverValid(data)
	local type = data.cfg.Type

	self.store:SetTipsCtrl(true)
	self.store:SetTipsTarget(data.go)

	if self:IsContainer(data) then
		self.curHoverContainerData = self.containerDataDic[data.cfg.Id]
		self.curVolumeList = self.curHoverContainerData.volumeList
		self.curGlassComp = self.curHoverContainerData.glass

		if not self:IsShakeFinished() then
			self.store:SetVolumeCtrl(true)
			self.store:RefreshVolumeList()
		end

		local total = self:GetTotalPercent(self.curHoverContainerData.volumeList)

		if total > 0 then
			self.store:SetTipsVolumeContent(data.cfg.ElementsName, total * self.curHoverContainerData.ozLimit)
		else
			self.store:SetTipsSimpleContent(data.cfg.ElementsName)
		end
	else
		self.curHoverContainerData = nil
		self.curVolumeList = nil
		self.curGlassComp = nil

		self.store:SetVolumeCtrl(false)
		self.store:SetTipsSimpleContent(data.cfg.ElementsName)
	end
end

function M:OnMouseScroll(context)
	if self.isRealPouring then
		return
	end

	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
		return
	end

	if context.performed then
		local _, index = table.find(self.ingredientElementList, self.curRightHoldElementData)
		local zoom = context:ReadValueVector2().y

		if zoom > 0 then
			index = index - 1

			if index < 1 then
				index = #self.ingredientElementList
			end

			local newElementData = self.ingredientElementList[index]

			print_debug("[Bartender]鼠标滚轮向前，切换到物品：" .. newElementData.cfg.ElementsName)
			self:ExchangeItem(newElementData, true)
		else
			index = index + 1

			if index > #self.ingredientElementList then
				index = 1
			end

			local newElementData = self.ingredientElementList[index]

			print_debug("[Bartender]鼠标滚轮向后，切换到物品：" .. newElementData.cfg.ElementsName)
			self:ExchangeItem(newElementData, true)
		end

		local totalHeight = self.curGlassComp:GetFluidHeight()

		if totalHeight >= 1 then
			self.store:SetTipsOverfillContent()
		else
			self.curIngredientTarget = self:GetIngredientTarget(self.curRightHoldElementData.cfg.Id)
			local volume = self:GetVolumeById(self.curHoverContainerData.volumeList, self.curRightHoldElementData.cfg.Id)
			local curVolumeOZ = (volume and volume.percent or 0) * self.curHoverContainerData.ozLimit
			local isPerfect = self.curIngredientTarget and self.curIngredientTarget > 0 and self:CheckVolumePerfect(curVolumeOZ, self.curIngredientTarget)

			self.store:SetTipsVolumeContent(self.curRightHoldElementData.cfg.ElementsName, curVolumeOZ, isPerfect)
		end
	end
end

function M:OnUseBtnBeginLongPress()
	if self.isLockAction then
		return
	end

	if self:CanPourWine() then
		print_debug("[Bartender]开始倒酒")
		self.FSM:SendSignal(FSMTransition.Normal_Pour)

		return
	end

	if self:CanRealPourWine() then
		print_debug("[Bartender]开始真倒酒")
		self:OnRealPourEnter()

		return
	end
end

function M:OnUseBtnEndLongPress()
	if not self.isPlaying or self.isLockAction then
		return
	end

	if self:GetFSMState() == FSMState.Shake then
		return
	end

	if self:GetFSMState() == FSMState.Pour and self.isRealPouring then
		print_debug("[Bartender]结束真倒酒")
		self:OnRealPourExit()

		return
	end

	if self.curHoverType == HoverType.NONE then
		print_debug("[Bartender]当前没有指向有效，无法交互")

		return
	end

	if not self.isHoldItem then
		if self.curHoverType == HoverType.ELEMENT then
			print_debug("[Bartender]拾取物品")
			self:PickUpItem(self.curHoverElementData)

			return
		end
	else
		if self:IsShakeFinished() and self:IsCurrentHitEmptyCup(false) then
			self:PickAndPutCupOnTable(self.curHoverElementData)

			return
		end

		if self:CanAddIce() then
			print_debug("[Bartender]加冰")
			self:AddIce()

			return
		end

		if self.curHoverType == HoverType.ELEMENT then
			print_debug("[Bartender]交换物品")
			self:ExchangeItem(self.curHoverElementData)

			return
		end

		if self.curHoverType == HoverType.TABLE then
			print_debug("[Bartender]放下物品")
			self:PutDownItem(false)

			return
		end

		if self.curHoverType == HoverType.NPC then
			print_debug("[Bartender]跟Npc交互")

			if self:CanDeliver() then
				self:Deliver()
			end

			return
		end
	end
end

function M:OnCancelBtnClick()
	if not self.isPlaying or self.isLockAction then
		return
	end

	if self:GetFSMState() ~= FSMState.Normal then
		return
	end

	if self.isHoldItem then
		self:PutDownItem(true)
	end
end

function M:OnDrinkBtnClick()
	if self:CanDrink() then
		self:DrinkContainer(self.curRightHoldContainerData)
	end
end

function M:OnPourEndBtnClick()
	if self:GetFSMState() == FSMState.Pour then
		print_debug("[Bartender]结束倒酒")
		self.FSM:SendSignal(FSMTransition.Pour_Normal)

		return
	end
end

function M:CanDrink()
	if self.isLockAction then
		return false
	end

	if not self.curRightHoldContainerData or #self.curRightHoldContainerData.volumeList == 0 then
		return false
	end

	return true
end

function M:OnShakeBtnClick()
	if self:GetFSMState() == FSMState.Shake then
		self:EndShake()
	else
		self.FSM:SendSignal(FSMTransition.Normal_Shake)
	end
end

function M:OnPourWine(delta)
	if self.curGlassComp:GetFluidHeight() >= 1 then
		print_debug("[Bartender]酒杯已满")

		return
	end

	if self.curRemoveVolume and self.curRemoveVolume.percent <= 0 then
		print_debug("[Bartender]雪克壶已空，无法继续倒酒")

		return
	end

	self.x = Mathf.Clamp01(self.x - delta.x / UnityEngine.Screen.width)
	self.y = Mathf.Clamp01(self.y + delta.y / UnityEngine.Screen.height)

	gCS.AnimationManager.SetAnimatorParams(self.meUnit, self.x, self.y, 0)

	local vector2 = Vector2.New(self.x, self.y)

	self.curGlassComp:PourWater(vector2)
end

function M:UpdateVolume()
	local totalHeight = self.curGlassComp:GetFluidHeight()
	local deltaAddPercent = totalHeight - self.originalHeight
	local deltaOZ = deltaAddPercent * self.curHoverContainerData.ozLimit
	self.curAddVolume.percent = deltaAddPercent + self.originalPercent

	if self.curRemoveVolume then
		local deltaRemovePercent = deltaOZ / self.curRightHoldContainerData.ozLimit
		self.curRemoveVolume.percent = self.curRemoveVolume.percent - deltaRemovePercent
	end

	if totalHeight >= 1 then
		self.store:SetTipsOverfillContent()
	else
		local curVolumeOZ = self.curAddVolume.percent * self.curHoverContainerData.ozLimit
		local isPerfect = self.curIngredientTarget and self.curIngredientTarget > 0 and self:CheckVolumePerfect(curVolumeOZ, self.curIngredientTarget)

		self.store:SetTipsVolumeContent(self.curAddVolume.name, curVolumeOZ, isPerfect)
	end
end

function M:OnShake(delta)
	if delta.x == 0 and delta.y == 0 then
		return
	end

	local height = UnityEngine.Screen.height
	local width = UnityEngine.Screen.width
	local cfgSpeed = LTConfig.BartenderConfig.MouseSpeedScale
	local speed = (delta.x * delta.x + delta.y * delta.y) / (height * height + width * width)
	self.curTemperature = self.curTemperature - 0.1 * speed * 100 * cfgSpeed

	if self.curTemperature < self.minTemperature then
		return
	end

	local aniSpeed = speed * 400

	if aniSpeed > 1 then
		aniSpeed = 1
	end

	LX6.Units.AnimationManager.SetStateSpeed(self.meUnit, 0, aniSpeed * cfgSpeed)

	local progressValue = (self.curTemperature - self.minTemperature) / (self.maxTemperature - self.minTemperature)

	self.store:RefreshTemperatureProgress(progressValue)

	if self.shakeStepCfg then
		local isPerfect = self:IsPerfectTemperature(self.curTemperature, self.minPerfectTemperature, self.maxPerfectTemperature)

		self.store:SetTempCtrl(isPerfect and 2 or 1)
	end

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(function ()
		LX6.Units.AnimationManager.SetStateSpeed(self.meUnit, 0, 0)
	end, 0.3):Start()
end

function M:SetMeFacing()
	if self.isLockAction then
		return
	end

	if not self.meUnit then
		return
	end

	self.meUnit:SetFacing(self.lastFacingVector)
end

function M:PickUpItem(data)
	if self.isHoldItem then
		print_error("[Bartender]已经手持物品，无法再次拾取")

		return
	end

	if not data then
		print_error("[Bartender]传入数据为空，无法拾取")

		return
	end

	if self.outLineEffect then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.outLineEffect)
	end

	self.store:SetTipsCtrl(false)

	self.isHoldItem = true
	self.curRightHoldElementData = data

	self:PickExtra(data)
	self:SetLockActionAndView(true)

	local signalId = SIGNAL_GET_INGREDIENT

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, signalId)

	if self.pickStartAction then
		print_error("[Bartender]拾取动作委托异常不为空，请注意检查")

		self.pickStartAction = nil
	end

	function self.pickStartAction()
		self:BindItemToHand(data)
	end
end

function M:ExchangeItem(data, isPour)
	if self.outLineEffect then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.outLineEffect)
	end

	if isPour then
		self:UnBindItemFromHand(self.curRightHoldElementData, UnBindType.EXCHANGEPOUR, data.go.transform.position)
	else
		self.store:SetTipsCtrl(false)
		self:UnBindItemFromHand(self.curRightHoldElementData, UnBindType.EXCHANGE)
	end

	self.curRightHoldElementData = data

	if isPour then
		self:PourBind()
	else
		self:BindItemToHand(data)
	end

	self:PickExtra(data)
end

function M:PickExtra(data)
	if data.cfg.Type ~= ElementType.Bottle then
		if data.cfg.Type == ElementType.Drink then
			-- Nothing
		elseif self:IsContainer(data) then
			self:PickUpContainer(data)
		end
	end
end

function M:PutDownItem(isReturn)
	if not self.isHoldItem then
		print_error("[Bartender]当前没有手持物品，无法放下")

		return
	end

	local element = self.curRightHoldElementData

	if not element then
		print_error("[Bartender]数据为空，无法放下")

		return
	end

	self.store:SetStatusCtrl(StatusCtrlType.EmptyHand)

	local container = self.curRightHoldContainerData

	if isReturn and container then
		container.isInUse = false
	end

	self.isHoldItem = false
	self.curRightHoldElementData = nil
	self.curRightHoldContainerData = nil

	self:SetLockActionAndView(true)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_RETURN_COMMON)

	if self.putStartAction then
		print_error("[Bartender]信号委托异常不为空，请注意检查")

		self.putStartAction = nil
	end

	function self.putStartAction()
		self:UnBindItemFromHand(element, isReturn and UnBindType.ORIGIN or UnBindType.TABLE)
	end
end

function M:PickAndPutCupOnTable(data)
	self:SetLockActionAndView(true)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_GET_GLASS_LEFT_HAND)

	self.curHoverContainerData.isInUse = true

	if self.pickStartAction then
		print_error("[Bartender]信号委托异常不为空，请注意检查")

		self.putStartAction = nil
	end

	function self.pickStartAction()
		self:BindItemToHand(data, true)

		self.curLeftHoldElementData = data
	end

	if self.putStartAction then
		print_error("[Bartender]信号委托异常不为空，请注意检查")

		self.putStartAction = nil
	end

	function self.putStartAction()
		self:UnBindItemFromHand(self.curLeftHoldElementData, UnBindType.SHAKE)

		self.curLeftHoldElementData = nil
	end
end

function M:PickUpContainer(data)
	self.curRightHoldContainerData = self.containerDataDic[data.cfg.Id]
	self.curRightHoldContainerData.isInUse = true

	if self:CanShake() then
		self.store:SetShakerCtrl(ShakerCtrlType.Ready)
	else
		self.store:SetShakerCtrl(ShakerCtrlType.Normal)
	end

	if data.cfg.Type == ElementType.Cup then
		-- Nothing
	end
end

function M:BindItemToHand(data, isLeft)
	local item = data.go
	local boneName = isLeft and "handL" or "handR"
	local bone = LX6.Utils.UnitUtils.NameToBone(boneName, self.meUnit)

	item.transform:SetParent(bone, true)
	item.transform:SetLocalPosition(Vector3.zero)
	item.transform:SetLocalRotation(Vector3.zero)
	data.collider.gameObject:SetActive(false)
end

function M:UnBindItemFromHand(data, posType, customPos)
	data.collider.gameObject:SetActive(true)

	local trans = data.go.transform

	if posType == UnBindType.TABLE then
		trans:SetParent(nil)

		trans.position = self.curTableHitPos

		trans:SetLocalRotation(Vector3.zero)
	elseif posType == UnBindType.ORIGIN then
		trans:SetParent(data.parent.transform, true)
		trans:SetLocalPosition(Vector3.zero)
		trans:SetLocalRotation(Vector3.zero)
	elseif posType == UnBindType.SHAKE then
		trans:SetParent(nil)

		trans.position = self.tableCollider.transform.position + Vector3.New(0, 0.1)

		trans:SetLocalRotation(Vector3.zero)
	elseif posType == UnBindType.EXCHANGE then
		trans:SetParent(nil)

		trans.position = self.curHoverElementData.go.transform.position

		trans:SetLocalRotation(Vector3.zero)
	elseif posType == UnBindType.EXCHANGEPOUR then
		trans:SetParent(nil)

		trans.position = customPos

		trans:SetLocalRotation(Vector3.zero)
	end
end

function M:NPCStartPerformance()
	self.performCameraList[self.currentPosId].gameObject:SetActive(true)

	for i, v in pairs(self.posList) do
		if v then
			self:SetActiveCustomerTimer(v, false)
			self:SetCustomerState(v, CustomerAnimState.Performance)
		end
	end
end

function M:NPCEndPerformance()
	self.performCameraList[self.currentPosId].gameObject:SetActive(false)

	for i, v in pairs(self.posList) do
		if v and v ~= self.curCustomerData then
			self:SetActiveCustomerTimer(v, true)

			local isAngry = self.curCustomerData.waitState == CustomerWaitState.Angry

			self:SetCustomerState(v, isAngry and CustomerAnimState.Angry or CustomerAnimState.Wait)

			break
		end
	end
end

function M:AddIce(data)
	if self.curHoverContainerData.iceAdded then
		print_debug("[Bartender]当前杯子已经添加过冰块，无法重复添加")

		return
	end

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_ADD_ICE)

	self.curHoverContainerData.iceAdded = true

	self:SetLockActionAndView(true)

	local glassComp = self.curGlassComp

	if self.putStartAction then
		print_error("[Bartender]信号委托异常不为空，请注意检查")

		self.putStartAction = nil
	end

	function self.putStartAction()
		self:SetUIStatus(StatusCtrlType.Pick)
		glassComp:AddIce(3)
		self:RefreshCheckCondition(self.curHoverContainerData)
		self.store:RefreshMenuList(self.curHoverContainerData)
	end
end

function M:DrinkContainer(container)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_DRINK)
	self:SetLockActionAndView(true)

	if self.putStartAction then
		print_error("[Bartender]信号委托异常不为空，请注意检查")

		self.putStartAction = nil
	end

	function self.putStartAction()
		self:RefreshUIStatus()
		self:ClearContainerData(self.curRightHoldContainerData)
		self:RefreshCheckCondition(self.curRightHoldContainerData)
		self.store:RefreshMenuList(self.curRightHoldContainerData)
	end
end

function M:AddNewVolume(container, isShaker)
	local volumeList = container.volumeList
	local cfg = self.curRightHoldElementData.cfg
	local id = isShaker and MIXER_ID or cfg.Id

	if not self:GetVolumeById(volumeList, id) then
		local data = {}
		local color = isShaker and MIXER_COLOR or Color.NewByStr(cfg.ElementsColor)
		data.percent = 0
		data.color = color
		data.id = id

		if isShaker then
			data.name = MIXER_NAME
			data.mixture = isShaker and self.curRightHoldContainerData.volumeList[1].mixture
			container.isShaken = true
			container.iceAdded = true
			container.beforeShakeCheckList = self.curRightHoldContainerData.beforeShakeCheckList
		else
			data.name = cfg.ElementsName
		end

		table.insert(volumeList, data)
		self.curGlassComp:UpdateColor(color)
	end
end

function M:AutoPour()
	print_debug("[Bartender]AutoPour")
	coroutine.start(function ()
		coroutine.wait(3)
		coroutine.wait(4)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_GET_INGREDIENT)

		local color = Color.NewByStr("FFFFFF")

		self.curGlassComp:UpdateColor(color)
		coroutine.wait(3)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_POUR_INGREDIENT)

		self.waitTimer = Timer.New(function ()
			print_debug("[Bartender]PourWine")
			gCS.AnimationManager.SetAnimatorParams(self.meUnit, 1, 0.5, 0)
		end, 0.1, 30):Start()

		coroutine.wait(4)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_STOP_POURING)
		coroutine.wait(1)
		coroutine.wait(3)
		self:GetAccuracyScore()
	end)
end

function M:RefreshCheckCondition(container)
	local checkSteps = container.isShaken and container.afterShakeCheckList or container.beforeShakeCheckList

	for i, v in pairs(checkSteps) do
		checkSteps[i] = self:CheckCondition(container, self.allStepCfg[i])
	end
end

function M:CheckCondition(container, id)
	local cfg = MenuStepConfig.GetConfig(id)

	if cfg.ActionType == MenuStepConfig.ActionTypeType.AddLiquid then
		return self:CheckAddLiquid(container, cfg)
	elseif cfg.ActionType == MenuStepConfig.ActionTypeType.AddIce then
		return container.iceAdded
	elseif cfg.ActionType == MenuStepConfig.ActionTypeType.Shake then
		return container.isShaken
	end

	return false
end

function M:GetIngredientTarget(elementId)
	local target = 0
	local menuList = self.drinkMenuCfg.MenuStep

	for i, v in pairs(menuList) do
		local stepCfg = MenuStepConfig.GetConfig(v)

		if stepCfg.AmountOz > 0 and stepCfg.ElementID == elementId then
			target = target + stepCfg.AmountOz
		end
	end

	return target
end

function M:CheckIsNeeded(menuId)
	local cfg = MenuStepConfig.GetConfig(menuId)

	if #cfg.Checklist > 0 then
		return true
	end

	return false
end

function M:CheckAddLiquid(container, cfg)
	if not self.curHoverContainerData then
		return false
	end

	local volumeData = self:GetVolumeById(container.volumeList, cfg.ElementID)

	if not volumeData then
		return false
	end

	local needPercent = cfg.AmountOz / container.ozLimit
	local rate = volumeData.percent / needPercent
	local tolerance = BartenderConfig.ElementsOzTolerance

	if tolerance.ElementsOzLow == -1 then
		tolerance = {
			ElementsOzHigh = 0.05,
			ElementsOzLow = 0.05
		}
	end

	if rate >= 1 - tolerance.ElementsOzLow then
		return true
	end

	return false
end

function M:CheckVolumePerfect(cur, target)
	local excessRange = 0.2
	local rate = cur / target

	if math.abs(rate - 1) <= excessRange then
		return true
	end

	return false
end

function M:CheckAllCompleted(container)
	local cfg = self.drinkMenuCfg

	if not cfg then
		return
	end

	local menuList = cfg.MenuStep

	for i, v in pairs(menuList) do
		if not self:CheckIsCompleted(container, v) then
			return false
		end
	end

	return true
end

function M:CheckIsCompleted(container, menuId)
	self.curCheckMenuCfg = MenuStepConfig.GetConfig(menuId)
	local isCompleted = true

	for _, methodName in pairs(self.curCheckMenuCfg.Checklist) do
		if type(methodName) == "string" then
			local method = self[methodName]

			if method == nil then
				print_error("[Bartender]Method " .. methodName .. " not found in BartendManager")

				isCompleted = false

				break
			elseif method(self, container) == false then
				isCompleted = false

				break
			end
		end
	end

	return isCompleted
end

function M:CorrectCup(container)
	return true
end

function M:RequiredIce(container)
	return container.iceAdded
end

function M:RequiredNoIce(container)
	return not container.iceAdded
end

function M:RequiredIngredients(container)
	return self:GetVolumeById(container.volumeList, self.curCheckMenuCfg.ElementID)
end

function M:Shake()
	if self.curHoverContainerData.isShaken then
		return true
	end

	return false
end

function M:Deliver()
	self:SetLockActionAndView(true)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.meUnit, SIGNAL_DELIVER)
end

function M:GetAccuracyScore(container)
	local volumeList = container.volumeList
	local now = self:GetIngredientList(container)
	local target = {}
	local menuList = self.drinkMenuCfg.MenuStep

	for i, v in pairs(menuList) do
		local stepCfg = MenuStepConfig.GetConfig(v)

		if stepCfg.AmountOz > 0 then
			if target[stepCfg.ElementID] == nil then
				target[stepCfg.ElementID] = {
					amount = 0
				}
			end

			target[stepCfg.ElementID].amount = target[stepCfg.ElementID].amount + stepCfg.AmountOz
		end
	end

	local totalAmount = 0

	for id, v in pairs(target) do
		totalAmount = totalAmount + v.amount
	end

	for id, v in pairs(target) do
		v.weight = v.amount / totalAmount
	end

	local grade = 0
	local excessRange = 0.2

	for id, info in pairs(target) do
		local excess = 0

		if now[id] == nil then
			excess = 1
		else
			local targetAmount = info.amount
			excess = math.abs(now[id] - targetAmount) / targetAmount
		end

		if excessRange >= excess then
			info.score = 1
		else
			info.score = 1 - excess
		end

		grade = grade + info.score * info.weight
	end

	print_debug(tostring(now))
	print_debug(tostring(target))

	return grade
end

function M:GetTemperatureScore(container)
	return 1
end

function M:GetGuestSatisfactionBonus(container)
	local origin = self.curCustomerData.originSPScore
	local totalTagSP = 0

	if self.orderTypeCfg then
		local containedTags = self:GetContainedTag(container)

		for i, v in pairs(self.orderTypeCfg.MustTag) do
			if table.contains(containedTags, v) then
				totalTagSP = totalTagSP + 5
			end
		end

		local limit = 10
		local extraTotal = 0

		for i, v in pairs(self.orderTypeCfg.ExtraTag) do
			if table.contains(containedTags, v) then
				extraTotal = extraTotal + 5

				if limit <= extraTotal then
					extraTotal = limit

					break
				end
			end
		end

		totalTagSP = totalTagSP + extraTotal
	end

	local deltaSP = (self.curCustomerData.spScoreModify + totalTagSP) / origin

	if deltaSP > 1 then
		return math.sqrt(deltaSP)
	else
		return 0
	end
end

function M:IsCurHoldCocktailShaker()
	return self.isHoldItem and self:IsCocktailShaker(self.curRightHoldElementData)
end

function M:IsCocktailShaker(element)
	return element and element.cfg.Id == 87005240
end

function M:IsHoldEmpty()
	return not self.isHoldItem or not self.curRightHoldElementData
end

function M:IsCurrentHitCup()
	return self.curHoverType == HoverType.ELEMENT and self.curHoverElementData and self.curGlassComp ~= nil
end

function M:IsCurrentHitInUseCup(isInUse)
	return self:IsCurrentHitCup() and self.curHoverContainerData.isInUse == isInUse
end

function M:IsCurrentHitEmptyCup(isInUse)
	return self:IsCurrentHitInUseCup(isInUse) and self:IsContainerEmpty(self.curHoverContainerData)
end

function M:IsContainerEmpty(container)
	return self:GetTotalPercent(container.volumeList) == 0
end

function M:CanPourWine()
	if self:GetFSMState() ~= FSMState.Normal then
		return false
	end

	if self:IsHoldEmpty() then
		return false
	end

	if self:IsShakeFinished() and self:IsCurrentHitEmptyCup(true) then
		return true
	end

	if self.curRightHoldElementData.cfg.Type ~= ElementType.Bottle and self.curRightHoldElementData.cfg.Type ~= ElementType.Drink then
		return false
	end

	if not self:IsCurrentHitInUseCup(true) then
		return false
	end

	return true
end

function M:CanRealPourWine()
	if self:GetFSMState() ~= FSMState.Pour then
		return false
	end

	if self.isRealPouring then
		return false
	end

	return true
end

function M:CanShake()
	return self:IsCurHoldCocktailShaker() and self.curRightHoldContainerData and self.curRightHoldContainerData.iceAdded and not self.curRightHoldContainerData.isShaken
end

function M:CanAddIce()
	if self:IsHoldEmpty() then
		return false
	end

	if self.curRightHoldElementData.cfg.Type ~= ElementType.Ice then
		return false
	end

	if not self:IsCurrentHitCup() then
		return false
	end

	return true
end

function M:CanDeliver()
	if self:IsHoldEmpty() or not self.curRightHoldContainerData then
		return false
	end

	if self.curRightHoldElementData.cfg.Id == 87005240 then
		return false
	end

	if self.curHoverCollider ~= self.curCustomerData.collider then
		return false
	end

	return true
end

function M:IsPourState()
	return self:GetFSMState() == FSMState.Pour
end

function M:IsPouring()
	return self.FSM:GetCurrentState() == FSMState.Pour and self.isRealPouring
end

function M:IsShaking()
	return self.FSM:GetCurrentState() == FSMState.Shake
end

function M:IsShakeFinished()
	return self:IsCurHoldCocktailShaker() and self.curRightHoldContainerData.isShaken
end

function M:SetLockActionAndView(isLock)
	if self.store then
		self.store:SetShowDrinkBtn(false)
		self.store:SetCrossHairCtrl(not isLock)

		if isLock then
			self:SetUIStatus(StatusCtrlType.Empty)
		end
	end

	self.isLockAction = isLock
end

function M:GetFSMState()
	return self.FSM:GetCurrentState()
end

function M:SetUIStatus(type)
	self.store:SetStatusCtrl(type)
end

function M:RefreshUIStatus()
	if self.isLockAction then
		self:SetUIStatus(StatusCtrlType.Empty)

		return
	end

	if self:CanDrink() and not self:CanShake() then
		self.store:SetShowDrinkBtn(true)
	else
		self.store:SetShowDrinkBtn(false)
	end

	if not self.isHoldItem then
		self:SetUIStatus(StatusCtrlType.EmptyHand)
	elseif self.curHoverType == HoverType.ELEMENT and self:CanPourWine() then
		self:SetUIStatus(StatusCtrlType.PickIngredientAndAimContainer)
	elseif self.curHoverType == HoverType.NPC and self:CanDeliver() then
		self:SetUIStatus(StatusCtrlType.PickCupAndAimNPC)
	elseif self.curHoverType == HoverType.TABLE then
		self:SetUIStatus(StatusCtrlType.Pick)
	else
		self:SetUIStatus(StatusCtrlType.Empty)
	end
end

function M:GetElementList()
	local list = {}

	for i, v in pairs(self.cfg.SceneElements) do
		local cfg = ElementsConfig.GetConfig(v.ElementsID)
		local data = {
			pos = v.prefabID,
			cfg = cfg
		}

		if not list[cfg.Type] then
			list[cfg.Type] = {}
		end

		table.insert(list[cfg.Type], data)
	end

	return list
end

function M:GetMenuCfg()
	return self.drinkMenuCfg
end

function M:GetCurrentVolumeById(id)
	if not self.curVolumeList then
		return nil
	end

	return self:GetVolumeById(self.curVolumeList, id)
end

function M:GetVolumeById(volumeList, id)
	for i, v in pairs(volumeList) do
		if v.id == id then
			return v
		end
	end

	return nil
end

function M:GetVolumeListByIndex(index)
	return self.curVolumeList[index]
end

function M:GetVolumeListNum()
	return #self.curVolumeList
end

function M:GetTotalPercent(volumeList)
	local total = 0

	if not volumeList then
		return total
	end

	for i, v in pairs(volumeList) do
		total = total + v.percent
	end

	return total
end

function M:IsContainer(data)
	return data and (data.cfg.Type == ElementType.Cup or data.cfg.Id == 87005240)
end

function M:IsPerfectTemperature(cur, min, max)
	return min <= cur and cur <= max
end

function M:GetNormalSPLevelAndValue()
	local threshold = BartenderConfig.SP_Threshold
	local rand = math.random()
	local spLevelLayer = {}

	for i, v in pairs(threshold) do
		spLevelLayer[i] = v.SPProbability + (i == 1 and 0 or spLevelLayer[i - 1])
	end

	for i, v in pairs(spLevelLayer) do
		if rand <= v then
			return i, math.random(threshold[i].MinSP, threshold[i].MaxSP)
		end
	end

	return 1, -100
end

function M:GetSPLevelByValue(value)
	local threshold = BartenderConfig.SP_Threshold

	for i, v in pairs(threshold) do
		if v.MinSP <= value and value <= v.MaxSP then
			return v.SPLevel
		end
	end

	print_error("[Bartender]传入的SP值异常，无法匹配对应等级，value: " .. value)

	return 1
end

function M:GetSuperCfgByAgentId(agentId)
	for i = 0, CustomerSuperConfig.count - 1 do
		local cfg = CustomerSuperConfig.LoadAt(i)

		if cfg.AgentID == agentId then
			return cfg
		end
	end

	return nil
end

function M:GetRandomTalkBySpLevel(spLevel)
	local talks = self.talkLibrary[spLevel]

	if not talks or #talks == 0 then
		print_error("[Bartender]当前SP等级没有对应的台词，spLevel: " .. spLevel)

		return nil
	end

	return array.random(talks)
end

function M:GetRandomOrderType()
	local weights = {
		50,
		40,
		10
	}
	local totalWeight = 0

	for i, v in pairs(weights) do
		totalWeight = totalWeight + v
	end

	local rand = math.random(1, totalWeight)
	local cumulativeWeight = 0

	for i, v in pairs(weights) do
		cumulativeWeight = cumulativeWeight + v

		if rand <= cumulativeWeight then
			return i
		end
	end
end

function M:GetRandomCfg(allCfg)
	local random = math.random(0, allCfg.count - 1)

	return allCfg.LoadAt(random)
end

function M:GetContainedTag(container)
	local tags = {}

	for i, v in pairs(container.volumeList) do
		local cfg = ElementsConfig.GetConfig(v.id)

		if cfg and cfg.Tag then
			for _, tag in pairs(cfg.Tag) do
				if not table.find(tags, tag) then
					table.insert(tags, tag)
				end
			end
		end
	end

	return tags
end

function M:SetCustomerSPLevel(customer, spLevel)
	customer.spLevel = spLevel

	ABPVarManager.SetInt(customer.unit, ABPVarConfig.BartenderSPLevel, spLevel)
	print_debug("[Bartender]设置顾客SP等级，spLevel: " .. spLevel)
end

function M:SetCustomerState(customer, state)
	customer.state = state

	ABPVarManager.SetInt(customer.unit, ABPVarConfig.BartenderCustomerState, state)
	print_debug("[Bartender]设置顾客id =" .. customer.name .. "，state: " .. state)
end

function M:SetCustomerPersonality(customer, personality)
	personality = personality <= 3 and personality or 3

	ABPVarManager.SetInt(customer.unit, ABPVarConfig.BartenderPersonality, personality)
	print_debug("[Bartender]设置顾客id =" .. customer.name .. "，personality: " .. personality)
end

function M:ResetCustomerTimer(customer)
	customer.waitTimer = 0
end

function M:SetActiveCustomerTimer(customer, isActive)
	customer.isTimerActive = isActive
end

function M:GetIngredientList(container)
	local list = {}

	for i, v in pairs(container.volumeList) do
		if v.id == MIXER_ID then
			for id, ratio in pairs(v.mixture) do
				if not list[id] then
					list[id] = 0
				end

				local oz = ratio * v.percent * container.ozLimit
				list[id] = list[id] + oz
			end
		else
			if not list[v.id] then
				list[v.id] = 0
			end

			local oz = v.percent * container.ozLimit
			list[v.id] = list[v.id] + oz
		end
	end

	return list
end

function M:MixVolume(container)
	local volumeList = container.volumeList
	local mixture = {}
	local totalPercent = self:GetTotalPercent(volumeList)

	for i, v in pairs(volumeList) do
		if v.id ~= MIXER_ID then
			local ratio = v.percent / totalPercent
			mixture[v.id] = ratio
		end
	end

	local newVolume = {
		percent = totalPercent,
		color = MIXER_COLOR,
		name = MIXER_NAME,
		id = MIXER_ID,
		mixture = mixture
	}
	container.volumeList = {
		newVolume
	}
end

function M:GetEmptyPos()
	for i = 1, self.maxPosCount do
		if not self.posList[i] then
			return i
		end
	end

	return -1
end

function M:GetCommentDialogId()
	local superCfg = self.curCustomerData.superCfg

	if not superCfg then
		return 0
	else
		local isHiddenMenu = self.drinkMenuCfg.Id == superCfg.HiddenDrinkMenuID
		local isCorrectMenu = self.drinkMenuCfg.Id == superCfg.CorrectDrinkMenuID

		if isHiddenMenu then
			return superCfg.HiddenCommentDialogID
		else
			return isCorrectMenu and superCfg.CommentDialog_Success or superCfg.CommentDialog_Fail
		end
	end
end

function M:SetShowInteractionBtn(index, isShow)
	local signal = (isShow and 3 or 4) + index * 2

	gSpoonClientMgr:ReleaseContextEvent(gBartendManager.entityInstanceId, gSpoonEventType.MessageTrigger, {
		message = gEventConstants.BARTENDER_SIGNAL,
		param = signal
	})
end

function M:ClearDialogHandler()
	self:ClearDialogShowEndHandler()
	self:ClearDialogEndHandler()
end

function M:ClearDialogShowEndHandler()
	if self.dialogShowEndHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_SHOW_END, self.dialogShowEndHandler)

		self.dialogShowEndHandler = nil
	end
end

function M:ClearDialogEndHandler()
	if self.dialogEndHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END, self.dialogEndHandler)

		self.dialogEndHandler = nil
	end
end

function M:ClearContainerData(container)
	container.glass:ResetFluid()

	container.volumeList = {}
	container.isInUse = false
	container.iceAdded = false
	container.isShaken = false
	container.beforeShakeCheckList = table.clone(self.beforeShakeCheckList)
	container.afterShakeCheckList = table.clone(self.afterShakeCheckList)
end

gBartendManager = gBartendManager or C_BartendManager.new()
