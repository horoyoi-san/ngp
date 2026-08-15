local GameConfig = LTConfig.GameConfig
local DragEventListener = SGUI.EventSystems.DragEventListener
C_RobotSpiderControlStore = DefClass("C_RobotSpiderControlStore", C_RobotSpiderControlStore, C_StoreGroup)
GroupName2Class.RobotSpiderControlStore = C_RobotSpiderControlStore
local M = C_RobotSpiderControlStore

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
	self.grappleEnable = true
	self.grappleBuffEnable = false
	self.GrappleBuff = 52606166
	self.recall = false
	self.abpEnable = true
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
	self.btnGrappleStore = self:GetStoreByWidget(self.bindData.btnGrapple)
	self.btnRushStore = self:GetStoreByWidget(self.bindData.btnRush)
	self.btnSwitchControlStore = self:GetStoreByWidget(self.bindData.btnSwitchControl)
	self.btnSwitchViewStore = self:GetStoreByWidget(self.bindData.btnSwitchView)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()

	self.btnSkillStore = nil
	self.btnRecallStore = nil
	self.btnJumpStore = nil
	self.btnNormalAttackStore = nil
	self.btnGrappleStore = nil
	self.btnRushStore = nil
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
	self.show = true
	self.bindData.POVCtrl = 0
	self.cs_unit = data.cs_unit

	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.grappleBuffEnable = gCS.MyPlayerManager.PlayerUnit and gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, self.GrappleBuff)

	self:RefreshGrappleButtonState()
	self:SetBanButton()
end

function M:OnClose()
	self.show = false
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

	local energy = gCS.LuaUtils.GetSpiderEnergy(self.cs_unit)
	self.bindData.energyFill = energy

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue GetSpiderEnergy ", energy)
	end

	local screenPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.rootTrans, self.cs_unit.PlayerObj.position)
	self.bindData.energyBarTrans.anchoredPosition = screenPos
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.FEISUO_GPS_EXIST_CHANGE] = self:CreateAction("RefreshGrappleButtonState"),
		[gEventConstants.ON_BUFF_ADD] = self:CreateAction("OnBuffAdd"),
		[gEventConstants.ON_BUFF_REMOVE] = self:CreateAction("OnBuffRemove"),
		[gEventConstants.HACK_SUMMON_QUERY_CHANGED] = self:CreateAction("OnTagQueryChanged")
	}
end

function M:RegisterWidget()
	self.bindData.btnSkillMobile.luaBeginLongPress = self:CreateAction("OnBtnSkillBeginLongPress")
	self.bindData.btnSkillMobile.luaEndLongPress = self:CreateAction("OnBtnSkillEndLongPress")
	self.bindData.btnSkillMobile.luaLongPress = self:CreateAction("OnBtnSkillLongPressClick")
	self.bindData.btnSkillPc.luaBeginLongPress = self:CreateAction("OnBtnSkillBeginLongPress")
	self.bindData.btnSkillPc.luaEndLongPress = self:CreateAction("OnBtnSkillEndLongPress")
	self.bindData.btnSkillPc.luaLongPress = self:CreateAction("OnBtnSkillLongPressClick")
	self.bindData.btnRecall.luaPress = self:CreateAction("OnBtnRecallPress")
	self.bindData.btnRecall.luaRelease = self:CreateAction("OnBtnRecallRelease")
	self.bindData.btnRecall.luaClick = self:CreateAction("OnBtnRecallClick")
	self.bindData.btnJump.luaPress = self:CreateAction("OnBtnJumpPress")
	self.bindData.btnJump.luaRelease = self:CreateAction("OnBtnJumpRelease")
	self.bindData.btnJump.luaClick = self:CreateAction("OnBtnJumpClick")
	self.bindData.btnNormalAttack.luaBeginLongPress = self:CreateAction("OnBtnNormalAttackBeginLongPress")
	self.bindData.btnNormalAttack.luaEndLongPress = self:CreateAction("OnBtnNormalAttackEndLongPress")
	self.bindData.btnNormalAttack.luaLongPress = self:CreateAction("OnBtnNormalAttackLongPressClick")
	self.bindData.btnGrapple.luaPress = self:CreateAction("OnBtnGrapplePress")
	self.bindData.btnGrapple.luaRelease = self:CreateAction("OnBtnGrappleRelease")
	self.bindData.btnGrapple.luaClick = self:CreateAction("OnBtnGrappleClick")
	self.bindData.btnRush.luaPress = self:CreateAction("OnBtnRushPress")
	self.bindData.btnRush.luaRelease = self:CreateAction("OnBtnRushRelease")
	self.bindData.btnRush.luaClick = self:CreateAction("OnBtnRushClick")
	local rushBtnDrag = DragEventListener.Get(self.bindData.btnRush.gameObject)
	rushBtnDrag.onDrag = self:CreateAction("OnBtnRushDrag")
	self.bindData.btnSwitchControl.luaPress = self:CreateAction("OnBtnSwitchControlPress")
	self.bindData.btnSwitchControl.luaRelease = self:CreateAction("OnBtnSwitchControlRelease")
	self.bindData.btnSwitchControl.luaClick = self:CreateAction("OnBtnSwitchControlClick")
	self.bindData.btnSwitchView.luaPress = self:CreateAction("OnBtnSwitchViewPress")
	self.bindData.btnSwitchView.luaRelease = self:CreateAction("OnBtnSwitchViewRelease")
	self.bindData.btnSwitchView.luaClick = self:CreateAction("OnBtnSwitchViewClick")
	self.bindData.btnTakePhoto.luaClick = self:CreateAction("OnBtnTakePhotoClick")
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

function M:OnBtnRecallPress()
	self.recall = true
	self.bindData.ShowRecallCtrl = 1
	self.needUpdateRecall = true
	self.recallStartTime = Time.time

	self:SetRecallProgress(0)
	self:DisableButtonForRecall()
	self:PlayBtnDownAnime(self.btnRecallStore)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnRecallPress")
	end
end

function M:OnBtnRecallRelease()
	self.recall = false
	self.bindData.ShowRecallCtrl = 0
	self.needUpdateRecall = false

	self:EnableButtonForRecall()
	self:PlayBtnUpAnime(self.btnRecallStore)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnRecallRelease")
	end
end

function M:OnBtnRecallClick()
	return
end

function M:SetRecallProgress(val)
	val = Mathf.Clamp01(val)
	self.bindData.recallFillAmount = val
	self.bindData.recallPercent = math.floor(val * 100)
end

function M:OnBtnJumpPress()
	self:PlayBtnDownAnime(self.btnJumpStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.spiderjumpPress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue Send3CEvent spiderjumpPress")
	end
end

function M:OnBtnJumpRelease()
	self:PlayBtnUpAnime(self.btnJumpStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.spiderjumpRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue Send3CEvent spiderjumpRelease")
	end
end

function M:OnBtnJumpClick()
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

function M:OnBtnGrapplePress()
	self:PlayBtnDownAnime(self.btnGrappleStore)

	if gFeisuoUIUpdateMgr.selectFeisuoInfo.select then
		local targetPos = gFeisuoUIUpdateMgr.selectFeisuoInfo.pos
		local direction = targetPos - self.cs_unit.LocalPosition

		gCS.DestroyWindowModuleMgr.GadgetInitPos(self.cs_unit, LTConfig.ABPGadgetConfig.SpiderC, targetPos, direction)
	end

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue Send3CEvent spiderCPress")
	end
end

function M:OnBtnGrappleRelease()
	self:PlayBtnUpAnime(self.btnGrappleStore)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnGrappleRelease")
	end
end

function M:OnBtnGrappleClick()
	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue gFeiSuoCrouchManager:OnBtnGrappleClick")
	end
end

function M:RefreshGrappleButtonState()
	self.grappleEnable = gFeisuoUIUpdateMgr.hasAddGps
	self.bindData.btnGrapple.interactable = not self.recall and self.grappleEnable

	self.bindData.btnGrapple:SetActive(self.grappleBuffEnable)
end

function M:OnBuffAdd(eventId, buffId)
	if not self.show then
		return
	end

	if buffId == self.GrappleBuff then
		self.grappleBuffEnable = gCS.MyPlayerManager.PlayerUnit and gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, self.GrappleBuff)

		self:RefreshGrappleButtonState()
	end
end

function M:OnBuffRemove(eventId, buffId)
	if not self.show then
		return
	end

	if buffId == self.GrappleBuff then
		self.grappleBuffEnable = gCS.MyPlayerManager.PlayerUnit and gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, self.GrappleBuff)

		self:RefreshGrappleButtonState()
	end
end

function M:OnBtnRushPress()
	self:PlayBtnDownAnime(self.btnRushStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.spiderrushPress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue Send3CEvent spiderrushPress")
	end
end

function M:OnBtnRushRelease()
	self:PlayBtnUpAnime(self.btnRushStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.spiderrushRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue Send3CEvent spiderrushRelease")
	end
end

function M:OnBtnRushClick()
	return
end

function M:OnBtnRushDrag(eventPointer)
	gCS.CameraDataMgr.cameraControllerManager:OnControlCameraAngle(eventPointer.delta)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnRushDrag ", eventPointer.delta)
	end
end

function M:OnBtnSwitchControlPress()
	gLoadingManager:Quick_ViewFocusChange_Robot()
	self:PlayBtnDownAnime(self.btnSwitchControlStore)
	gClientToGameSceneDelegate:AskStopControlAgent(false)
end

function M:OnBtnSwitchControlRelease()
	self:PlayBtnUpAnime(self.btnSwitchControlStore)
end

function M:OnBtnSwitchControlClick()
	return
end

function M:OnBtnSwitchViewPress()
	self:PlayBtnDownAnime(self.btnSwitchViewStore)
end

function M:OnBtnSwitchViewRelease()
	self:PlayBtnUpAnime(self.btnSwitchViewStore)
end

function M:OnBtnSwitchViewClick()
	local first = not LX6.Cinemachine.BaseBotCameraState.SetFirstView
	LX6.Cinemachine.BaseBotCameraState.SetFirstView = first
	self.bindData.POVCtrl = first and 1 or 0
end

function M:OnBtnTakePhotoClick()
	gTakePhotoUtils.TryTakePhoto()
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
	self.bindData.btnGrapple.interactable = not self.recall and self.grappleEnable
	self.bindData.btnRush.interactable = false
	self.bindData.btnJump.interactable = false
	self.bindData.btnNormalAttack.interactable = false
	self.bindData.btnSkillMobile.interactable = false
	self.bindData.btnSkillPc.interactable = false
	self.bindData.btnSwitchControl.interactable = false
	self.bindData.btnSwitchView.interactable = false
	self.bindData.btnTakePhoto.interactable = false
end

function M:EnableButtonForRecall()
	self.bindData.btnGrapple.interactable = not self.recall and self.grappleEnable
	self.bindData.btnRush.interactable = true
	self.bindData.btnJump.interactable = true
	self.bindData.btnNormalAttack.interactable = true
	self.bindData.btnSkillMobile.interactable = true
	self.bindData.btnSkillPc.interactable = true
	self.bindData.btnSwitchControl.interactable = self.abpEnable and not self.recall
	self.bindData.btnSwitchView.interactable = true
	self.bindData.btnTakePhoto.interactable = true
end

function M:PlayBtnDownAnime(store)
	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, self.BTN_ANIME.DOWN)
end

function M:PlayBtnUpAnime(store)
	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, self.BTN_ANIME.UP)
end

function M:OnTagQueryChanged(eventId, value)
	self.abpEnable = value
	self.bindData.btnSwitchControl.interactable = self.abpEnable and not self.recall
end
