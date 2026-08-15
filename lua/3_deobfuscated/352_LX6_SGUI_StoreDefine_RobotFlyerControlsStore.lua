local GameConfig = LTConfig.GameConfig
local HudDescConfig = LTConfig.HudDescConfig
C_RobotFlyerControlsStore = DefClass("C_RobotFlyerControlsStore", C_RobotFlyerControlsStore, C_StoreGroup)
GroupName2Class.RobotFlyerControlsStore = C_RobotFlyerControlsStore
local M = C_RobotFlyerControlsStore

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
	self.SWITCH_INTERVAL = 0.3
	self.btnMgr = gStoreButtonMgr
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnGroupEnable()
	self.btnDropStore = self:GetStoreByWidget(self.bindData.btnDrop)
	self.btnRecallStore = self:GetStoreByWidget(self.bindData.btnRecall)
	self.btnUpStore = self:GetStoreByWidget(self.bindData.btnUp)
	self.btnDownStore = self:GetStoreByWidget(self.bindData.btnDown)
	self.btnHitchStore = self:GetStoreByWidget(self.bindData.btnHitch)
	self.btnGearSwitchStore = self:GetStoreByWidget(self.bindData.btnGearSwitch)
	self.btnGearSwitchStore.btnId = HudDescConfig.GEAR_SWITCH_BTN
	self.btnSwitchControlStore = self:GetStoreByWidget(self.bindData.btnSwitchControl)
	self.btnSwitchViewStore = self:GetStoreByWidget(self.bindData.btnSwitchView)
end

function M:OnGroupDisable()
	self.btnDropStore = nil
	self.btnRecallStore = nil
	self.btnUpStore = nil
	self.btnDownStore = nil
	self.btnHitchStore = nil
	self.btnGearSwitchStore = nil
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
	self.gearSwitchTime = 0
	self.bindData.POVCtrl = 0
	self.cs_unit = data.cs_unit
	self.isShow = true

	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.gear = 1

	if self.spoonGear then
		self.gear = self.spoonGear
		self.spoonGear = nil
	end

	self:SetGear(self.gear)
	self:SetBanButton()
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

function M:OnClose()
	self.isShow = false
	self.cs_unit = nil

	self:ClearBanButton()
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

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.btnDrop.luaPress = self:CreateAction("OnBtnDropPress")
	self.bindData.btnDrop.luaRelease = self:CreateAction("OnBtnDropRelease")
	self.bindData.btnDrop.luaClick = self:CreateAction("OnBtnDropClick")
	self.bindData.btnRecall.luaPress = self:CreateAction("OnBtnRecallPress")
	self.bindData.btnRecall.luaRelease = self:CreateAction("OnBtnRecallRelease")
	self.bindData.btnRecall.luaClick = self:CreateAction("OnBtnRecallClick")
	self.bindData.btnUp.luaPress = self:CreateAction("OnBtnUpPress")
	self.bindData.btnUp.luaRelease = self:CreateAction("OnBtnUpRelease")
	self.bindData.btnUp.luaClick = self:CreateAction("OnBtnUpClick")
	self.bindData.btnDown.luaPress = self:CreateAction("OnBtnDownPress")
	self.bindData.btnDown.luaRelease = self:CreateAction("OnBtnDownRelease")
	self.bindData.btnDown.luaClick = self:CreateAction("OnBtnDownClick")
	self.bindData.btnHitch.luaPress = self:CreateAction("OnBtnHitchPress")
	self.bindData.btnHitch.luaRelease = self:CreateAction("OnBtnHitchRelease")
	self.bindData.btnHitch.luaClick = self:CreateAction("OnBtnHitchClick")
	self.bindData.btnGearSwitch.luaClick = self:CreateAction("OnBtnGearSwitchClick")
	self.bindData.btnSwitchControl.luaPress = self:CreateAction("OnBtnSwitchControlPress")
	self.bindData.btnSwitchControl.luaRelease = self:CreateAction("OnBtnSwitchControlRelease")
	self.bindData.btnSwitchControl.luaClick = self:CreateAction("OnBtnSwitchControlClick")
	self.bindData.btnSwitchView.luaPress = self:CreateAction("OnBtnSwitchViewPress")
	self.bindData.btnSwitchView.luaRelease = self:CreateAction("OnBtnSwitchViewRelease")
	self.bindData.btnSwitchView.luaClick = self:CreateAction("OnBtnSwitchViewClick")
	self.bindData.btnTakePhoto.luaClick = self:CreateAction("OnBtnTakePhotoClick")
	self.bindData.mouseScrollRespond.luaGamePadInputChanged = self:CreateAction("OnMouseScroll")
	self.bindData.rightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
end

function M:OnBtnHitchPress()
	self:PlayBtnDownAnime(self.btnHitchStore)
	gMessageManager:SendMessage(gEventConstants.UAV_SPACE_BTN_DOWN)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnHitchPress")
	end
end

function M:OnBtnHitchRelease()
	self:PlayBtnUpAnime(self.btnHitchStore)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnHitchRelease")
	end
end

function M:OnBtnHitchClick()
	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnHitchClick")
	end
end

function M:OnBtnDropPress()
	self:PlayBtnDownAnime(self.btnDropStore)
	gMessageManager:SendMessage(gEventConstants.UAV_DROP_BTN_DOWN)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDropPress")
	end
end

function M:OnBtnDropRelease()
	self:PlayBtnUpAnime(self.btnDropStore)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDropRelease")
	end
end

function M:OnBtnDropClick()
	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDropClick")
	end
end

function M:OnBtnRecallPress()
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

function M:OnBtnUpPress()
	self:PlayBtnDownAnime(self.btnUpStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.UAVRisePress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnUpPress send3CEvent UAVRisePress")
	end
end

function M:OnBtnUpRelease()
	self:PlayBtnUpAnime(self.btnUpStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.UAVRiseRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnUpRelease send3CEvent UAVRiseRelease")
	end
end

function M:OnBtnUpClick()
	return
end

function M:OnBtnDownPress()
	self:PlayBtnDownAnime(self.btnDownStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.UAVFallPress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDownPress send3CEvent UAVFallPress")
	end
end

function M:OnBtnDownRelease()
	self:PlayBtnUpAnime(self.btnDownStore)
	gCS.LogicStateMachineManager.Send3CEvent(self.cs_unit, LTConfig.ABPCCCEventConfig.UAVFallRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDownRelease send3CEvent UAVFallRelease")
	end
end

function M:OnBtnDownClick()
	return
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

function M:OnBtnGearSwitchClick()
	self:OnGearUp()
end

function M:OnGearUp()
	self.gear = self.gear + 1

	if self.gear > 2 then
		self.gear = 0
	end

	self:SetGear(self.gear)

	self.gearSwitchTime = Time.time
end

function M:OnGearDown()
	self.gear = self.gear - 1

	if self.gear < 0 then
		self.gear = 2
	end

	self:SetGear(self.gear)

	self.gearSwitchTime = Time.time
end

function M:SetGear(gear)
	gCS.LogicStateMachineManager.UAVGearChange(self.cs_unit, gear)

	self.bindData.GearSwitchCtrl = gear

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue LogicStateMachineManager UAVGearChange", gear)
	end
end

function M:SetGearFromSpoon(gear)
	if self.isShow then
		self.gear = gear

		if self.gear < 0 then
			self.gear = 0
		end

		if self.gear > 2 then
			self.gear = 2
		end

		self:SetGear(self.gear)
	else
		self.spoonGear = gear
	end
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

function M:OnMouseScroll(context)
	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue RobotFlyer OnMouseScroll In", context.phase)
	end

	if context.performed and self.SWITCH_INTERVAL < Time.time - self.gearSwitchTime then
		local val = context:ReadValueVector2().y

		if val > 0 then
			self:OnGearUp()
		elseif val < 0 then
			self:OnGearDown()
		end
	end
end

function M:DisableButtonForRecall()
	self.bindData.btnDrop.interactable = false

	self.btnMgr:SetButtonInteractableBase(self.btnGearSwitchStore, false)

	self.bindData.btnUp.interactable = false
	self.bindData.btnDown.interactable = false
	self.bindData.btnHitch.interactable = false
	self.bindData.btnSwitchControl.interactable = false
	self.bindData.btnSwitchView.interactable = false
	self.bindData.btnTakePhoto.interactable = false
end

function M:EnableButtonForRecall()
	self.bindData.btnDrop.interactable = true

	self.btnMgr:SetButtonInteractableBase(self.btnGearSwitchStore, true)

	self.bindData.btnUp.interactable = true
	self.bindData.btnDown.interactable = true
	self.bindData.btnHitch.interactable = true
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
