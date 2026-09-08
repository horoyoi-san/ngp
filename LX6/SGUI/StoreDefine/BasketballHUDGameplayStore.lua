-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BasketballHUDGameplayStore.lua
-- Decompiled from: 01657_BasketballHUDGameplayStore.lua_00bfa34128ae.luajit

local InputState = {
	["^-jU"] = 1,
	["R-q_"] = 2,
	["5"] = 3,
	["T-s^"] = 4
}
local InputType = {
	["~\\xa6\\xad\\xa0\\xa2"] = 0,
	P7pK = 2,
	H7nS = 1
}
local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
local LinkBasketballStatus = L18.Gameplay.LinkBasketball.LinkBasketballStatus
local LinkBasketballManagerV2Type = typeof(L18.Gameplay.LinkBasketballV2.LinkBasketballManagerV2)
local MaxPassPressTime = 0.5
local BasketballButtonNameIds = {
	["o\\xa2\\xad\\xac\\xbd"] = 912,
	["\\xaf{m"] = 911,
	["\\x89\\xbd\n\\xa8ao\\xc8b"] = 727
}
local SkillConditionCheckers = {
	[15020989] = function ()
		return not gCS.LuaUtils.IsPlayerInBasketballThreePointLine()
	end
}
C_BasketballHUDGameplayStore = DefClass("C_BasketballHUDGameplayStore", C_BasketballHUDGameplayStore, C_StoreGroup)
GroupName2Class.BasketballHUDGameplayStore = C_BasketballHUDGameplayStore
local M = C_BasketballHUDGameplayStore

M.ctor = function(self)
	self.exitDelay = nil
	self.exitCo = nil
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.shootCtrlEnum = {
		["\\xb8\\xb9\n\\xa4~7\\xf04"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.rushStateCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.stateCtrlEnum = {
		["2G\\x83\\x83\\x82M"] = 6,
		["|\\ȸ\\x8a\\xbdU\\xff\\xb9"] = 1,
		["8?\\xa0\\xe80Q3\\x9a/˙\\x9b0\\x9c\\xc6\\xff\\xdf"] = 2,
		["8?\\xa0\\xe80Q3\\x9a/˙\\x9b0\\x9c\\xc4\\xff\\xdd"] = 8,
		["\\0x^"] = 5,
		["|\\ȸ\\x8a\\xbdW\\xff\\xbb"] = 7,
		["\\xfd\\xde'\\xf4"] = 3,
		["&\\xe6Y)\\xd3\\x98N\\x83W\\xbc\\xba"] = 4,
		["T-s^"] = 0
	}
	self.showSkillCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.btnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.wordsCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.qteVxCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.shootCtrlEnum = nil
	self.rushStateCtrlEnum = nil
	self.stateCtrlEnum = nil
	self.showSkillCtrlEnum = nil
	self.btnHideCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.qteVxCtrlEnum = nil
end

M.DefineAllVariables = function(self)
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
	self.passBtnPressStartTime = nil
	self.isBtnTipsChange = false
	self.gmForceShowSkillBtn = false
end

M.ClearFlag = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() and self.isLongPressRush then
		self.bindData.rushJoyStick:LuaSimulateEndDrag()
	end

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

	self.ClearPassTargetEffect(self)

	self.passBtnPressStartTime = nil
	self.bindData.rushStateCtrl = 0
	self.isLongPressRush = false

	self.SendShiftEvent(self, LTConfig.ABPCCCEventConfig.BasDribbleShiftRelease, LTConfig.ABPCCCEventConfig.BasLocomoveShiftRelease)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.SetButtonName = function(self, btn, nameId)
	local store = self.GetStoreByWidget(self, btn)
	store.notifyWord = LTConfig.InputButtonNameConfig.GetConfig(nameId).Name

	btn.SetTipNameTotally(btn, nameId)

	return store
end

M.OnShow = function(self, panelId, data)
	self:GenMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)

	self.allowInput = true
	self.isBtnTipsChange = false

	self.bindData.dribbleBtn:SetActive(false)
	self:SetButtonName(self.bindData.askBtn, BasketballButtonNameIds.Ask)
	self:SetButtonName(self.bindData.blockBtn, gCS.LinkBasketballManager.Instance:IsMulti() and BasketballButtonNameIds.Block or BasketballButtonNameIds.Block1V1)

	self.skillBtnStore = self:GetStoreByWidget(self.bindData.skillBtn)
	self.isLongPressRush = false
end

M.OnClose = function(self)
	self.ClearFlag(self)
	self.ClearMessageEvents(self)

	self.allowInput = false

	self.CancelPendingExit(self)
end

M.OnUpdate = function(self)
	if self.passBtnPressStartTime then
		if MaxPassPressTime < gLogicTime.unscaledTime - self.passBtnPressStartTime then
			self.OnReleasePassBtn(self)
		else
			self.UpdatePassTarget(self)
		end
	end

	if gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.BasCatchBall then
		if not self.isBtnTipsChange then
			self.bindData.rushBtn:SetPCKeyInfoTipNameId(453)

			self.isBtnTipsChange = true
		end

		self.bindData.dribbleBtn:SetActive(false)
	else
		if self.isBtnTipsChange then
			self.bindData.rushBtn:SetPCKeyInfoTipNameId(388)

			self.isBtnTipsChange = false
		end

		if self.bindData.shootCtrl ~= 1 then
			self.bindData.dribbleBtn:SetActive(false)
		end
	end

	self.UpdateGamepadCamera(self)
	self.UpdateState(self)

	if self.isLongPressRush then
		self.SendShiftEvent(self, LTConfig.ABPCCCEventConfig.BasDribbleShiftPress, LTConfig.ABPCCCEventConfig.BasLocomoveShiftPress)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SWITCH_BASKETBALL_SHOOTING] = self.CreateAction(self, "SwitchToShooting"),
		[gEventConstants.SWITCH_BASKETBALL_SHOOTING_EXIT] = function (_, args)
			local isLinkBasketballExit = type(args) ~= "table" and args.isLinkBasketballExit

			if gCS.LinkBasketballManager.Instance.isInBasketballLink and not isLinkBasketballExit then
				return
			end

			local isExitImmediate = args

			if type(args) ~= "table" then
				isExitImmediate = args.isExitImmediate
			end

			local exitFunc = self

			exitFunc:CancelPendingExit()

			self.allowInput = false
			self.isShootingEffect = false

			local exitFunc = function()
				self.bindData.shootCtrl = 0
				local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

				gameplayControlStore:StopGameplayByType(gHUDGameplayType.BASKETBALL)

				self.exitDelay = nil
				self.exitCo = nil
			end

			if isExitImmediate then
				self.bindData.stateCtrl = self.stateCtrlEnum.None
				self.exitCo = coroutine.start(function ()
					coroutine.step()
					coroutine.step()
					exitFunc()
				end)
			else
				self.exitDelay = gLuaTimeMgrUtils.Delay(exitFunc, 0.6)
			end
		end,
		[gEventConstants.BASKETBALL_SHOOTING_CHECK_MOTION_INPUT] = function ()
			self:CheckInputState(InputType.Shoot)
			self:CheckInputState(InputType.Rush)
			self:CheckInputState(InputType.Jump)
		end,
		[gEventConstants.SWITCH_BASKETBALL_SHOOTING_ENTER] = function ()
			self.bindData.shootCtrl = 0

			self:CancelPendingExit()
		end,
		[gEventConstants.BASKETBALL_SHOOTING_OVER] = function (eventId, isMe)
			if isMe then
				self.bindData.shootCtrl = 0

				self.bindData.rushBtn:SetPCKeyInfoTipNameId(453)

				self.isBtnTipsChange = true

				self.bindData.dribbleBtn:SetActive(false)

				self.isShooting = false
				local bar = self.SubGroup.BasketBallBar
				bar.needUpdate = false
			end
		end,
		[gEventConstants.L50_AFTER_SWITCH_SCENE] = function (eventId, switchSceneEventParams)
			local switchType = switchSceneEventParams.switchSceneType

			if switchType ~= gSwitchSceneType.Reconnect then
				self:ClearFlag()

				return
			end

			self.bindData.shootCtrl = 0

			self:CancelPendingExit()

			local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

			gameplayControlStore:StopGameplayByType(gHUDGameplayType.BASKETBALL)
		end,
		[gEventConstants.ON_BASKETBALL_ENERGY_EVENT] = function (eventId, energy)
			self:UpdateSkillChargeFill()
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.shootBtn.luaPress = self.CreateAction(self, "OnPressShootBtn")
	self.bindData.askBtn.luaPress = self.CreateAction(self, "OnPressAskBtn")
	self.bindData.dribbleBtn.luaPress = self.CreateAction(self, "OnPressDribbleBtn")
	self.bindData.skillBtn.luaPress = self.CreateAction(self, "OnPressSkillBtn")
	self.bindData.defenceBtn.luaPress = self.CreateAction(self, "OnPressDefenceBtn")
	self.bindData.stealBtn.luaPress = self.CreateAction(self, "OnPressStealBtn")
	self.bindData.blockBtn.luaPress = self.CreateAction(self, "OnPressBlockBtn")
	self.bindData.passBtn.luaPress = self.CreateAction(self, "OnPressPassBtn")
	self.bindData.rushBtn.luaBeginLongPress = self.CreateAction(self, "OnBeginLongPressRushBtn")
	self.bindData.rushBtn.luaEndLongPress = self.CreateAction(self, "OnEndLongPressRushBtn")
	self.bindData.shootBtn.luaRelease = self.CreateAction(self, "OnReleaseShootBtn")
	self.bindData.dribbleBtn.luaRelease = self.CreateAction(self, "OnReleaseDribbleBtn")
	self.bindData.skillBtn.luaRelease = self.CreateAction(self, "OnReleaseSkillBtn")
	self.bindData.defenceBtn.luaRelease = self.CreateAction(self, "OnReleaseDefenceBtn")
	self.bindData.stealBtn.luaRelease = self.CreateAction(self, "OnReleaseStealBtn")
	self.bindData.blockBtn.luaRelease = self.CreateAction(self, "OnReleaseBlockBtn")
	self.bindData.passBtn.luaRelease = self.CreateAction(self, "OnReleasePassBtn")
	self.bindData.joyStick.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.rushJoyStick.luaValueChanged = function(x, y, size)
			LX6.GUI.GuiMgr.Instance.sguiJoystick:OnMove(x, y, size)
		end

		self.bindData.rushJoyStick.luaBeginDrag = function()
			self.bindData.rushStateCtrl = 1
			self.pressState[InputType.Rush] = true

			LX6.GUI.GuiMgr.Instance.sguiJoystick:OnJsMoveStart()
			self:SetInputState(InputType.Rush, InputState.Down)

			self.isLongPressRush = true
		end

		self.bindData.rushJoyStick.luaEndDrag = function()
			self.bindData.rushStateCtrl = 0
			self.pressState[InputType.Rush] = false

			LX6.GUI.GuiMgr.Instance.sguiJoystick:OnJsMoveEnd()
			self:SetInputState(InputType.Rush, InputState.Up)

			self.isLongPressRush = false

			self:SendShiftEvent(LTConfig.ABPCCCEventConfig.BasDribbleShiftRelease, LTConfig.ABPCCCEventConfig.BasLocomoveShiftRelease)
		end
	end
end

M.IsWithoutBallFreeLocoMove = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit
	local tags = LTConfig.GameplayTagConfig

	return unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_FreeLocoMoveRun) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_FreeLocoMoveRush)
end

M.IsWithoutBallLocoMove = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit
	local tags = LTConfig.GameplayTagConfig

	return unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_OffLocoMoveRun) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_OffLocoMoveRush) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_AskForBall)
end

M.IsWithoutBallDef = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit
	local tags = LTConfig.GameplayTagConfig

	return unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_CombatDef) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_AutoDef) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_ShiftDef) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_BeCombatDef) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_Steal) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_BlockSuccess) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_BlockMiss)
end

M.IsWithoutBallDefNoBall = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit
	local tags = LTConfig.GameplayTagConfig

	return unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_DefNoBallLocoMoveRun) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_DefNoBallLocoMoveRush) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_DefBallerLocoMoveRun) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_DefBallerLocoMoveRush)
end

M.IsWithBallOffense = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit
	local tags = LTConfig.GameplayTagConfig
	local tagsPass = unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_PassBall) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_ThreeThreat) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_Dribble) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_Shoot) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_Layup) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_CombatDribble) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_FancyDribble) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_FastDribble) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_ShootCancelHoldball) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_Dunk) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withball_BeCombatDribble) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_PreCatchBall) or unit:HasGameplayTag(tags.Motion_Special_Ball_Basketball_Withoutball_CatchBall)

	if not tagsPass then
		return false
	end

	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.basketballStatus == LinkBasketballStatus.InMatch then
		return true
	end

	return linkBasketballManager.isOffenseSide
end

M.OnPressShootBtn = function(self)
	self.pressState[InputType.Shoot] = true

	self:SetInputState(InputType.Shoot, InputState.Down)
	self.bindData.shootAni:Play("s_vx_HudSkillbtn_fanse")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasShootPress)
end

M.OnPressAskBtn = function(self)
	self.bindData.shootAni:Play("s_vx_HudSkillbtn_fanse")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasAskForBall)
end

M.OnPressPassBtn = function(self)
	self.passBtnPressStartTime = gLogicTime.unscaledTime

	self.UpdatePassTarget(self)
end

M.OnPressDribbleBtn = function(self)
	self.pressState[InputType.Jump] = true

	self:SetInputState(InputType.Jump, InputState.Down)
	self.bindData.moveAni:Play("s_vx_HudSkillbtn_fanse")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasDribbleFancyPress)
end

M.OnReleaseShootBtn = function(self)
	self.pressState[InputType.Shoot] = false

	self:SetInputState(InputType.Shoot, InputState.Up)
	self.bindData.shootAni:Play("s_vx_HudSkillbtn_fanse_up")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasShootRelease)
end

M.OnReleaseDribbleBtn = function(self)
	self.pressState[InputType.Jump] = false

	self:SetInputState(InputType.Jump, InputState.Up)
	self.bindData.moveAni:Play("s_vx_HudSkillbtn_fanse_up")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasDribbleFancyRelease)
end

M.OnReleasePassBtn = function(self)
	if not self.passBtnPressStartTime then
		return
	end

	local pressTime = Mathf.Clamp(gLogicTime.unscaledTime - self.passBtnPressStartTime, 0, MaxPassPressTime)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance
	self.passBtnPressStartTime = nil

	if tolua.typeof(linkBasketballManager) ~= LinkBasketballManagerV2Type then
		linkBasketballManager.SendPassBallEvent(linkBasketballManager, pressTime)

		return
	end

	linkBasketballManager.SetPassPressTime(linkBasketballManager, pressTime)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasPassBall)
end

M.UpdatePassTarget = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if tolua.typeof(linkBasketballManager) == LinkBasketballManagerV2Type then
		return
	end

	local pressTime = Mathf.Clamp(gLogicTime.unscaledTime - self.passBtnPressStartTime, 0, MaxPassPressTime)

	return linkBasketballManager.UpdatePassTarget(linkBasketballManager, pressTime)
end

M.ClearPassTargetEffect = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if tolua.typeof(linkBasketballManager) ~= LinkBasketballManagerV2Type then
		linkBasketballManager.ClearPassTargetEffect(linkBasketballManager)
	end
end

M.OnBeginLongPressRushBtn = function(self)
	self.pressState[InputType.Rush] = true

	self:SetInputState(InputType.Rush, InputState.Down)
	self.bindData.rushAni:Play("s_vx_HudSkillbtn_fanse")
	self:SendShiftEvent(LTConfig.ABPCCCEventConfig.BasDribbleShiftPress, LTConfig.ABPCCCEventConfig.BasLocomoveShiftPress)

	self.isLongPressRush = true
end

M.OnEndLongPressRushBtn = function(self)
	self.isLongPressRush = false
	self.pressState[InputType.Rush] = false

	self:SetInputState(InputType.Rush, InputState.Up)
	self.bindData.rushAni:Play("s_vx_HudSkillbtn_fanse_up")
	self:SendShiftEvent(LTConfig.ABPCCCEventConfig.BasDribbleShiftRelease, LTConfig.ABPCCCEventConfig.BasLocomoveShiftRelease)
end

M.OnPressSkillBtn = function(self)
	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	if not self:CheckSkillBtnInteractable(currentSpiritId) then
		return
	end

	self.bindData.skillAni:Play("s_vx_HudSkillbtn_fanse")

	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager.maxEnergy < linkBasketballManager.energy then
		local cfg = gLinkBasketballManager:GetBasketballSkillConfig(currentSpiritId)
		local ultimateSignal = cfg and cfg.UltimateSignal

		if not ultimateSignal or ultimateSignal ~= 0 then
			ultimateSignal = LTConfig.ABPCCCEventConfig.BasSkill
		end

		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, ultimateSignal)
		gClientToGameSceneDelegate:ReportBasketballFinisher()

		linkBasketballManager.energy = 0
	end
end

M.OnPressDefenceBtn = function(self)
	self.bindData.defenceAni:Play("s_vx_HudSkillbtn_fanse")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasDefShiftPress)
end

M.OnPressStealBtn = function(self)
	self.bindData.stealAni:Play("s_vx_HudSkillbtn_fanse")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasDefSteal)
end

M.OnPressBlockBtn = function(self)
	self.bindData.blockAni:Play("s_vx_HudSkillbtn_fanse")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasDefReboundBlock)
	print_notice("[BasketballHUDGameplayStore] Send BasDefReboundBlock Event ", Time.frameCount)
end

M.OnReleaseSkillBtn = function(self)
	self.bindData.skillAni:Play("s_vx_HudSkillbtn_fanse_up")
end

M.OnReleaseDefenceBtn = function(self)
	self.bindData.defenceAni:Play("s_vx_HudSkillbtn_fanse_up")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.BasDefShiftRelease)
end

M.OnReleaseStealBtn = function(self)
	self.bindData.stealAni:Play("s_vx_HudSkillbtn_fanse_up")
end

M.OnReleaseBlockBtn = function(self)
	self.bindData.blockAni:Play("s_vx_HudSkillbtn_fanse_up")
end

M.OnRightStickControl = function(self, context)
	local value = context.ReadValueVector2(context)

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

M.UpdateGamepadCamera = function(self)
	if self.needUpdateCamera then
		gCameraUtils:DoRotateCameraByGamePad(1, self.rightStickValue.x, self.rightStickValue.y)
	end
end

M.SendShiftEvent = function(self, dribbleEvent, locomoveEvent)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if not unit then
		return
	end

	if self.bindData.stateCtrl ~= self.stateCtrlEnum.Offence1V1 or self.bindData.stateCtrl ~= self.stateCtrlEnum.Offence3V3 or self.bindData.stateCtrl ~= self.stateCtrlEnum.Normal then
		gCS.LogicStateMachineManager.Send3CEvent(unit, dribbleEvent)
	else
		gCS.LogicStateMachineManager.Send3CEvent(unit, locomoveEvent)
	end
end

M.SetInputState = function(self, inputType, inputState)
	gCS.LuaUtils.SetBasketballKeyInput(inputType, inputState)

	self.inputState[inputType] = inputState
end

M.CheckInputState = function(self, inputType)
	if self.pressState[inputType] then
		self.SetInputState(self, inputType, InputState.Hold)
	else
		self.SetInputState(self, inputType, InputState.None)
	end
end

M.CancelPendingExit = function(self)
	if self.exitCo then
		coroutine.stop(self.exitCo)

		self.exitCo = nil
	end

	if self.exitDelay then
		gLuaTimeMgrUtils.CancelUnitDelay(self.exitDelay)

		self.exitDelay = nil
	end
end

M.SwitchToShooting = function(self, _, data)
	if self.isShooting then
		return
	end

	self.isShooting = true
	self.isShootingEffect = true

	local checkFunc = function()
		return self.inputState[InputType.Shoot] ~= InputState.Up or self.inputState[InputType.Shoot] ~= InputState.None
	end

	local releaseCb = function(shootType, shootPressPer)
		self.isShooting = false

		gCS.LuaUtils.SendBasketballShootingEvent(shootType, shootPressPer)
	end

	local closeCb = function()
	end

	self.SubGroup.BasketBallBar:SetShootingBarParams(data.earlyEndTime, data.perfectStartTime, data.perfectEndTime, data.shootStartTime, data.shootEndTime, data.keyDownTime, checkFunc, releaseCb, closeCb)

	self.bindData.shootCtrl = 1
end

M.GetBasketBallBarShootResult = function(self)
	local bar = self.SubGroup.BasketBallBar

	return bar.GetShootResultAndCloseIfPerfect(bar)
end

M.UpdateState = function(self)
	if self.exitCo then
		return
	end

	local linkBasketballManager = gCS.LinkBasketballManager.Instance
	local is3V3 = linkBasketballManager.IsMulti(linkBasketballManager)

	if self.IsWithoutBallDef(self) then
		self.bindData.stateCtrl = self.stateCtrlEnum.Defence
	elseif self.IsWithoutBallDefNoBall(self) then
		self.bindData.stateCtrl = self.stateCtrlEnum.DefenceNoBall
	elseif self.IsWithoutBallLocoMove(self) then
		self.bindData.stateCtrl = is3V3 and self.stateCtrlEnum.WithoutBallOffence3V3 or self.stateCtrlEnum.WithoutBallOffence1V1
	elseif self.IsWithoutBallFreeLocoMove(self) then
		self.bindData.stateCtrl = self.stateCtrlEnum.Free
	elseif self.IsWithBallOffense(self) then
		if linkBasketballManager.basketballStatus ~= LinkBasketballStatus.InMatch then
			self.bindData.stateCtrl = is3V3 and self.stateCtrlEnum.Offence3V3 or self.stateCtrlEnum.Offence1V1
		else
			self.bindData.stateCtrl = self.stateCtrlEnum.Normal
		end
	else
		if not gCS.LuaUtils.IsNonMobileAdaptive() and self.isLongPressRush then
			self.bindData.rushJoyStick:LuaSimulateEndDrag()
		end

		self.bindData.stateCtrl = self.stateCtrlEnum.None
	end

	self.UpdateSkillIcon(self)
end

M.UpdateSkillIcon = function(self)
	if self.bindData.stateCtrl == self.stateCtrlEnum.Offence1V1 and self.bindData.stateCtrl == self.stateCtrlEnum.Offence3V3 then
		self.bindData.showSkillCtrl = self.showSkillCtrlEnum._false

		return
	end

	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()
	local cfg = gLinkBasketballManager:GetBasketballSkillConfig(currentSpiritId)

	if self.gmForceShowSkillBtn then
		self.bindData.showSkillCtrl = self.showSkillCtrlEnum._true
	elseif not cfg or not cfg.IsUltimate then
		self.bindData.showSkillCtrl = self.showSkillCtrlEnum._false

		return
	end

	self.bindData.showSkillCtrl = self.showSkillCtrlEnum._true
	self.skillBtnStore.notifyWord = cfg.UltimateName
	self.skillBtnStore.iconId = cfg.UltimateIcon

	self.UpdateSkillChargeFill(self)

	self.skillBtnStore.interactable = self.CheckSkillBtnInteractable(self, currentSpiritId)
end

M.CheckSkillBtnInteractable = function(self, spiritId)
	local checker = SkillConditionCheckers[spiritId]

	if checker then
		return checker()
	end

	return true
end

M.UpdateSkillChargeFill = function(self)
	local linkBasketballManager = gCS.LinkBasketballManager.Instance
	local energy = linkBasketballManager.energy
	self.skillBtnStore.chargeFillAmount = Mathf.Clamp01(energy / linkBasketballManager.maxEnergy)
end

M.GMForceShowSkillBtn = function(self, enable)
	self.gmForceShowSkillBtn = enable

	self.bindData.skillBtn:SetActive(enable)
end
