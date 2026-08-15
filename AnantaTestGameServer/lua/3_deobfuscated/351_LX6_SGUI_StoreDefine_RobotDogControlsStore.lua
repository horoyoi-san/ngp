local GameConfig = LTConfig.GameConfig
local DragEventListener = SGUI.EventSystems.DragEventListener
C_RobotDogControlsStore = DefClass("C_RobotDogControlsStore", C_RobotDogControlsStore, C_StoreGroup)
GroupName2Class.RobotDogControlsStore = C_RobotDogControlsStore
local M = C_RobotDogControlsStore

function M:DefineAllVariables()
	self.BTN_ANIME = {
		UP = "s_vx_HudSkillbtn_fanse_up",
		DOWN = "s_vx_HudSkillbtn_fanse"
	}
	self.gamepadUpdateRotate = false
	self.gamepadMode = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)

	self.btnSkillStore = self:GetStoreByWidget(self.bindData.btnSkillMobile)
	self.btnRecallStore = self:GetStoreByWidget(self.bindData.btnRecall)
	self.btnJumpStore = self:GetStoreByWidget(self.bindData.btnJump)
	self.btnNormalAttackStore = self:GetStoreByWidget(self.bindData.btnNormalAttack)
	self.btnCrouchStore = self:GetStoreByWidget(self.bindData.btnCrouch)
	self.btnDodgeStore = self:GetStoreByWidget(self.bindData.btnDodge)
	self.btnSwitchControlStore = self:GetStoreByWidget(self.bindData.btnSwitchControl)
	self.btnSwitchViewStore = self:GetStoreByWidget(self.bindData.btnSwitchView)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()

	self.btnSkillStore = nil
	self.btnRecallStore = nil
	self.btnJumpStore = nil
	self.btnNormalAttackStore = nil
	self.btnCrouchStore = nil
	self.btnDodgeStore = nil
	self.btnSwitchControlStore = nil
	self.btnSwitchViewStore = nil
	self.gamepadUpdateRotate = nil
	self.gamepadMode = nil
	self.rightStickValue = nil
end

function M:OnDestroy()
	self:ClearBanButton()
end

function M:OnShow(panelId, data)
	self.bindData.POVCtrl = LX6.Cinemachine.BaseBotCameraState.SetFirstView and 1 or 0
	self.cs_unit = data.cs_unit

	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())
	self:SetBanButton()
end

function M:OnClose()
	self.cs_unit = nil

	self:ClearBanButton()
end

function M:SetBanButton()
	if not self.buttonBanId then
		self.buttonBanId = gStoreButtonMgr:RegisterOperation({
			stateId = 5,
			priority = 0,
			groupId = LTConfig.HudDescGroupConfig.SummonAgent
		})
	end
end

function M:ClearBanButton()
	if self.buttonBanId then
		gStoreButtonMgr:UnRegisterOperation(self.buttonBanId)

		self.buttonBanId = nil
	end
end

function M:OnUpdate()
	if self.needUpdateRecall then
		local progress = (Time.time - self.recallStartTime) / GameConfig.AndroidCallBtnPressTime

		self:SetRecallProgress(progress)

		if progress >= 1 then
			self.needUpdateRecall = false

			gLoadingManager:Quick_ViewFocusChange_Robot()
			gClientToGameSceneDelegate:AskStopControlAgent(true)
		end
	end

	if self.gamepadMode then
		self:UpdateCameraRotateGamePad()
	end
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.SPOON_SWITCH_ROBOT_DOG] = self:CreateAction("DoSwitchView")
	}
end

function M:RegisterWidget()
	self.bindData.btnSkillMobile.luaBeginLongPress = self:CreateAction("OnBtnSkillBeginLongPress")
	self.bindData.btnSkillMobile.luaEndLongPress = self:CreateAction("OnBtnSkillEndLongPress")
	self.bindData.btnSkillMobile.luaLongPress = self:CreateAction("OnBtnSkillLongPressClick")
	self.bindData.btnSkillPc.luaBeginLongPress = self:CreateAction("OnBtnSkillBeginLongPress")
	self.bindData.btnSkillPc.luaEndLongPress = self:CreateAction("OnBtnSkillEndLongPress")
	self.bindData.btnSkillPc.luaLongPress = self:CreateAction("OnBtnSkillLongPressClick")
	self.bindData.btnRecall.luaBeginLongPress = self:CreateAction("OnBtnRecallBeginLongPress")
	self.bindData.btnRecall.luaEndLongPress = self:CreateAction("OnBtnRecallEndLongPress")
	self.bindData.btnRecall.luaLongPress = self:CreateAction("OnBtnRecallLongPressClick")
	self.bindData.btnJump.luaBeginLongPress = self:CreateAction("OnBtnJumpBeginLongPress")
	self.bindData.btnJump.luaEndLongPress = self:CreateAction("OnBtnJumpEndLongPress")
	self.bindData.btnJump.luaLongPress = self:CreateAction("OnBtnJumpLongPressClick")
	self.bindData.btnNormalAttack.luaBeginLongPress = self:CreateAction("OnBtnNormalAttackBeginLongPress")
	self.bindData.btnNormalAttack.luaEndLongPress = self:CreateAction("OnBtnNormalAttackEndLongPress")
	self.bindData.btnNormalAttack.luaLongPress = self:CreateAction("OnBtnNormalAttackLongPressClick")
	self.bindData.btnCrouch.luaBeginLongPress = self:CreateAction("OnBtnCrouchBeginLongPress")
	self.bindData.btnCrouch.luaEndLongPress = self:CreateAction("OnBtnCrouchEndLongPress")
	self.bindData.btnCrouch.luaLongPress = self:CreateAction("OnBtnCrouchLongPressClick")
	local crouchBtnDrag = DragEventListener.Get(self.bindData.btnCrouch.gameObject)
	crouchBtnDrag.onDrag = self:CreateAction("OnBtnCrouchDrag")
	self.bindData.btnDodge.luaBeginLongPress = self:CreateAction("OnBtnDodgeBeginLongPress")
	self.bindData.btnDodge.luaEndLongPress = self:CreateAction("OnBtnDodgeEndLongPress")
	self.bindData.btnDodge.luaLongPress = self:CreateAction("OnBtnDodgeLongPressClick")
	self.bindData.btnTakePhoto.luaClick = self:CreateAction("OnBtnTakePhotoClick")
	self.bindData.btnSwitchControl.luaBeginLongPress = self:CreateAction("OnBtnSwitchControlBeginLongPress")
	self.bindData.btnSwitchControl.luaEndLongPress = self:CreateAction("OnBtnSwitchControlEndLongPress")
	self.bindData.btnSwitchControl.luaLongPress = self:CreateAction("OnBtnSwitchControlLongPressClick")
	self.bindData.btnSwitchView.luaBeginLongPress = self:CreateAction("OnBtnSwitchViewBeginLongPress")
	self.bindData.btnSwitchView.luaEndLongPress = self:CreateAction("OnBtnSwitchViewEndLongPress")
	self.bindData.btnSwitchView.luaLongPress = self:CreateAction("OnBtnSwitchViewLongPressClick")
	self.bindData.rightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
end

function M:OnBtnSkillBeginLongPress()
	self:PlayBtnDownAnime(self.btnSkillStore)
	gBattleMgr:BtnSkillPressDown(gBattleMgr.SkillBtnType.Basic)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnSkillBeginLongPress")
	end
end

function M:OnBtnSkillEndLongPress()
	self:PlayBtnUpAnime(self.btnSkillStore)
	gBattleMgr:BtnSkillPressUp(gBattleMgr.SkillBtnType.Basic)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnSkillEndLongPress")
	end
end

function M:OnBtnSkillLongPressClick()
	gBattleMgr:BtnSkillPress(gBattleMgr.SkillBtnType.Basic)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnSkillLongPressClick")
	end
end

function M:OnBtnRecallBeginLongPress()
	self.bindData.ShowRecallCtrl = 1
	self.needUpdateRecall = true
	self.recallStartTime = Time.time

	self:SetRecallProgress(0)
	self:DisableButtonForRecall()
	self:PlayBtnDownAnime(self.btnRecallStore)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnRecallBeginLongPress")
	end
end

function M:OnBtnRecallEndLongPress()
	self.bindData.ShowRecallCtrl = 0
	self.needUpdateRecall = false

	self:EnableButtonForRecall()
	self:PlayBtnUpAnime(self.btnRecallStore)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnRecallEndLongPress")
	end
end

function M:OnBtnRecallLongPressClick()
	return
end

function M:SetRecallProgress(val)
	val = Mathf.Clamp01(val)
	self.bindData.recallFillAmount = val
	self.bindData.recallPercent = math.floor(val * 100)
end

function M:OnBtnJumpBeginLongPress()
	self:PlayBtnDownAnime(self.btnJumpStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.dogjumpPress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnJumpBeginLongPress send3CEvent dogjumpPress")
	end
end

function M:OnBtnJumpEndLongPress()
	self:PlayBtnUpAnime(self.btnJumpStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.dogjumpRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnJumpBeginLongPress send3CEvent dogjumpRelease")
	end
end

function M:OnBtnJumpLongPressClick()
	return
end

function M:OnBtnNormalAttackBeginLongPress()
	self:PlayBtnDownAnime(self.btnNormalAttackStore)
	gBattleMgr:BtnSkillPressDown(gBattleMgr.SkillBtnType.Normal)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnNormalAttackBeginLongPress")
	end
end

function M:OnBtnNormalAttackEndLongPress()
	self:PlayBtnUpAnime(self.btnNormalAttackStore)
	gBattleMgr:BtnSkillPressUp(gBattleMgr.SkillBtnType.Normal)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnNormalAttackEndLongPress")
	end
end

function M:OnBtnNormalAttackLongPressClick()
	gBattleMgr:BtnSkillPress(gBattleMgr.SkillBtnType.Normal)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnNormalAttackLongPressClick")
	end
end

function M:OnBtnCrouchBeginLongPress()
	self:PlayBtnDownAnime(self.btnCrouchStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.dogcrawlPress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnCrouchBeginLongPress send3CEvent dogcrawlPress")
	end
end

function M:OnBtnCrouchEndLongPress()
	self:PlayBtnUpAnime(self.btnCrouchStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.dogcrawlRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnCrouchEndLongPress send3CEvent dogcrawlRelease")
	end
end

function M:OnBtnCrouchLongPressClick()
	return
end

function M:OnBtnCrouchDrag(eventPointer)
	gCS.CameraDataMgr.cameraControllerManager:OnControlCameraAngle(eventPointer.delta)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnCrouchDrag ", eventPointer.delta)
	end
end

function M:OnBtnDodgeBeginLongPress()
	self:PlayBtnDownAnime(self.btnDodgeStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.dogrushPress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDodgeBeginLongPress send3CEvent dogrushPress")
	end
end

function M:OnBtnDodgeEndLongPress()
	self:PlayBtnUpAnime(self.btnDodgeStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.dogrushRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDodgeEndLongPress send3CEvent dogrushRelease")
	end
end

function M:OnBtnDodgeLongPressClick()
	return
end

function M:OnBtnTakePhotoClick()
	gTakePhotoUtils.TryTakePhoto()
end

function M:OnBtnSwitchControlBeginLongPress()
	gLoadingManager:Quick_ViewFocusChange_Robot()
	self:PlayBtnDownAnime(self.btnSwitchControlStore)
	gClientToGameSceneDelegate:AskStopControlAgent(false)
end

function M:OnBtnSwitchControlEndLongPress()
	self:PlayBtnUpAnime(self.btnSwitchControlStore)
end

function M:OnBtnSwitchControlLongPressClick()
	return
end

function M:OnBtnSwitchViewBeginLongPress()
	self:DoSwitchView()
	self:PlayBtnDownAnime(self.btnSwitchViewStore)
end

function M:DoSwitchView()
	local first = not LX6.Cinemachine.BaseBotCameraState.SetFirstView
	LX6.Cinemachine.BaseBotCameraState.SetFirstView = first
	self.bindData.POVCtrl = first and 1 or 0
end

function M:OnBtnSwitchViewEndLongPress()
	self:PlayBtnUpAnime(self.btnSwitchViewStore)
end

function M:OnBtnSwitchViewLongPressClick()
	return
end

function M:OnRightStickControl(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.gamepadUpdateRotate = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.gamepadUpdateRotate = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(4, 0, 0)
	end
end

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end

function M:DisableButtonForRecall()
	self.bindData.btnCrouch.interactable = false
	self.bindData.btnDodge.interactable = false
	self.bindData.btnJump.interactable = false
	self.bindData.btnNormalAttack.interactable = false
	self.bindData.btnRushPc.interactable = false
	self.bindData.btnSkillMobile.interactable = false
	self.bindData.btnSkillPc.interactable = false
	self.bindData.btnSwitchControl.interactable = false
	self.bindData.btnSwitchView.interactable = false
	self.bindData.btnTakePhoto.interactable = false
end

function M:EnableButtonForRecall()
	self.bindData.btnCrouch.interactable = true
	self.bindData.btnDodge.interactable = true
	self.bindData.btnJump.interactable = true
	self.bindData.btnNormalAttack.interactable = true
	self.bindData.btnRushPc.interactable = true
	self.bindData.btnSkillMobile.interactable = true
	self.bindData.btnSkillPc.interactable = true
	self.bindData.btnSwitchControl.interactable = true
	self.bindData.btnSwitchView.interactable = true
	self.bindData.btnTakePhoto.interactable = true
end

function M:PlayBtnDownAnime(store)
	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, self.BTN_ANIME.DOWN)
end

function M:PlayBtnUpAnime(store)
	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, self.BTN_ANIME.UP)
end
