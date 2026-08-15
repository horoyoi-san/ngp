local InputState = {
	Down = 1,
	Hold = 2,
	Up = 3,
	None = 4
}
local InputType = {
	Shoot = 0,
	Jump = 2,
	Rush = 1
}
local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
C_BasketballHUDGameplayStore = DefClass("C_BasketballHUDGameplayStore", C_BasketballHUDGameplayStore, C_StoreGroup)
GroupName2Class.BasketballHUDGameplayStore = C_BasketballHUDGameplayStore
local M = C_BasketballHUDGameplayStore

function M:ctor()
	self.exitDelay = nil
	self.rightStickValue = {
		x = 0,
		y = 0
	}
end

function M:DefineAllVariables()
	self.pressState = {
		[InputType.Shoot] = false,
		[InputType.Rush] = false,
		[InputType.Jump] = false
	}
	self.pressStateLast = {
		[InputType.Shoot] = false,
		[InputType.Rush] = false,
		[InputType.Jump] = false
	}
	self.inputState = {
		[InputType.Shoot] = InputState.None,
		[InputType.Rush] = InputState.None,
		[InputType.Jump] = InputState.None
	}
	self.isShooting = false
	self.isShootingEffect = false
	self.allowInput = false
	self.isBtnTipsChange = false
end

function M:ClearFlag()
	self.pressState[InputType.Shoot] = false
	self.pressState[InputType.Rush] = false
	self.pressState[InputType.Jump] = false
	self.pressStateLast[InputType.Shoot] = false
	self.pressStateLast[InputType.Rush] = false
	self.pressStateLast[InputType.Jump] = false
	self.inputState[InputType.Shoot] = InputState.None
	self.inputState[InputType.Rush] = InputState.None
	self.inputState[InputType.Jump] = InputState.None

	gCS.LuaUtils.SetBasketballKeyInput(InputType.Shoot, InputState.None)
	gCS.LuaUtils.SetBasketballKeyInput(InputType.Rush, InputState.None)
	gCS.LuaUtils.SetBasketballKeyInput(InputType.Jump, InputState.None)

	self.isShooting = false
	self.isShootingEffect = false
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
end

function M:OnShow(panelId, data)
	self:GenMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)

	self.allowInput = true
end

function M:OnClose()
	self:ClearFlag()
	self:ClearMessageEvents()

	self.allowInput = false
end

function M:OnUpdate()
	if self.isBtnTipsChange and gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.BasWithBall then
		self.bindData.rushBtn:SetPCKeyInfoTipNameId(388)

		self.isBtnTipsChange = false

		if self.bindData.shootCtrl ~= 1 then
			self.bindData.dribbleBtn:SetActive(true)
		end
	elseif gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.BasCatchBall then
		if not self.isBtnTipsChange then
			self.bindData.rushBtn:SetPCKeyInfoTipNameId(453)

			self.isBtnTipsChange = true
		end

		self.bindData.dribbleBtn:SetActive(false)
	elseif self.bindData.shootCtrl == 1 then
		self.bindData.dribbleBtn:SetActive(false)
	end

	self:UpdateGamepadCamera()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.SWITCH_BASKETBALL_SHOOTING] = self:CreateAction("SwitchToShooting"),
		[gEventConstants.SWITCH_BASKETBALL_SHOOTING_EXIT] = function ()
			self.allowInput = false
			self.isShootingEffect = false
			self.exitDelay = gLuaTimeMgrUtils.Delay(function ()
				self.bindData.shootCtrl = 0
				local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

				gameplayControlStore:StopGameplayByType(gHUDGameplayType.BASKETBALL)

				self.exitDelay = nil
			end, 0.6)
		end,
		[gEventConstants.BASKETBALL_SHOOTING_CHECK_MOTION_INPUT] = function ()
			self:CheckInputState(InputType.Shoot)
			self:CheckInputState(InputType.Rush)
			self:CheckInputState(InputType.Jump)
		end,
		[gEventConstants.SWITCH_BASKETBALL_SHOOTING_ENTER] = function ()
			self.bindData.shootCtrl = 0

			if self.exitDelay then
				gLuaTimeMgrUtils.CancelUnitDelay(self.exitDelay)
			end
		end,
		[gEventConstants.BASKETBALL_SHOOTING_CANCEL] = function (eventId, isMe)
			if isMe then
				self.bindData.shootCtrl = 0

				self.bindData.rushBtn:SetPCKeyInfoTipNameId(453)

				self.isBtnTipsChange = true

				self.bindData.dribbleBtn:SetActive(false)
			end
		end,
		[gEventConstants.AFTER_SWITCH_SCENE] = function (eventId, switchType)
			if switchType == gSwitchSceneType.Reconnect then
				return
			end

			self.bindData.shootCtrl = 0
			local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

			gameplayControlStore:StopGameplayByType(gHUDGameplayType.BASKETBALL)

			self.exitDelay = nil
		end
	}
end

function M:RegisterWidget()
	self.bindData.shootBtn.luaPress = self:CreateAction("OnPressShootBtn")
	self.bindData.rushBtn.luaPress = self:CreateAction("OnPressRushBtn")
	self.bindData.dribbleBtn.luaPress = self:CreateAction("OnPressDribbleBtn")
	self.bindData.shootBtn.luaRelease = self:CreateAction("OnReleaseShootBtn")
	self.bindData.rushBtn.luaRelease = self:CreateAction("OnReleaseRushBtn")
	self.bindData.dribbleBtn.luaRelease = self:CreateAction("OnReleaseDribbleBtn")
	self.bindData.joyStick.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		function self.bindData.rushJoyStick.luaValueChanged(x, y, size)
			LX6.GUI.GuiMgr.Instance.sguiJoystick:OnMove(x, y, size)
		end

		function self.bindData.rushJoyStick.luaBeginDrag()
			self.bindData.rushStateCtrl = 1
			self.pressState[InputType.Rush] = true

			LX6.GUI.GuiMgr.Instance.sguiJoystick:OnJsMoveStart()
			self:SetInputState(InputType.Rush, InputState.Down)
		end

		function self.bindData.rushJoyStick.luaEndDrag()
			self.bindData.rushStateCtrl = 0
			self.pressState[InputType.Rush] = false

			LX6.GUI.GuiMgr.Instance.sguiJoystick:OnJsMoveEnd()
			self:SetInputState(InputType.Rush, InputState.Up)
		end
	end
end

function M:OnPressShootBtn()
	self.pressState[InputType.Shoot] = true

	self:SetInputState(InputType.Shoot, InputState.Down)
	self.bindData.shootAni:Play("s_vx_HudSkillbtn_fanse")
end

function M:OnPressRushBtn()
	self.pressState[InputType.Rush] = true

	self:SetInputState(InputType.Rush, InputState.Down)
	self.bindData.rushAni:Play("s_vx_HudSkillbtn_fanse")
end

function M:OnPressDribbleBtn()
	self.pressState[InputType.Jump] = true

	self:SetInputState(InputType.Jump, InputState.Down)
	self.bindData.moveAni:Play("s_vx_HudSkillbtn_fanse")
end

function M:OnReleaseShootBtn()
	self.pressState[InputType.Shoot] = false

	self:SetInputState(InputType.Shoot, InputState.Up)
	self.bindData.shootAni:Play("s_vx_HudSkillbtn_fanse_up")
end

function M:OnReleaseRushBtn()
	self.pressState[InputType.Rush] = false

	self:SetInputState(InputType.Rush, InputState.Up)
	self.bindData.rushAni:Play("s_vx_HudSkillbtn_fanse_up")
end

function M:OnReleaseDribbleBtn()
	self.pressState[InputType.Jump] = false

	self:SetInputState(InputType.Jump, InputState.Up)
	self.bindData.moveAni:Play("s_vx_HudSkillbtn_fanse_up")
end

function M:OnRightStickControl(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.needUpdateCamera = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.needUpdateCamera = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
	end
end

function M:UpdateGamepadCamera()
	if self.needUpdateCamera then
		gCameraUtils:DoRotateCameraByGamePad(1, self.rightStickValue.x, self.rightStickValue.y)
	end
end

function M:SetInputState(inputType, inputState)
	gCS.LuaUtils.SetBasketballKeyInput(inputType, inputState)

	self.inputState[inputType] = inputState
end

function M:CheckInputState(inputType)
	if self.pressState[inputType] then
		self:SetInputState(inputType, InputState.Hold)
	else
		self:SetInputState(inputType, InputState.None)
	end
end

function M:SwitchToShooting(_, data)
	if self.isShooting then
		return
	end

	self.isShooting = true
	self.isShootingEffect = true

	local function checkFunc()
		return self.inputState[InputType.Shoot] == InputState.Up or self.inputState[InputType.Shoot] == InputState.None
	end

	local function releaseCb(shootType, shootPressPer)
		self.isShooting = false

		gCS.LuaUtils.SendBasketballShootingEvent(shootType, shootPressPer)
	end

	local function closeCb()
		return
	end

	self.SubGroup.BasketBallBar:SetShootingBarParams(data.earlyEndTime, data.perfectStartTime, data.perfectEndTime, data.clipLength, data.keyDownTime, checkFunc, releaseCb, closeCb)

	self.bindData.shootCtrl = 1
end
