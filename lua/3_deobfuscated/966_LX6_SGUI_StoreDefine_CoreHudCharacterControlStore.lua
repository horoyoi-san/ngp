local ProfileManager = LX6.Engine.ProfileManager
local GameConfig = LTConfig.GameConfig
local SkillConfig = LTConfig.SkillConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local ClientEventConfig = LTConfig.ClientEventConfig
local UnitOperateUtils = require("LX6/Utils/UnitOperateUtils")
local OperateType = UnitOperateUtils.OperateType
local DragEventListener = SGUI.EventSystems.DragEventListener
local HudDescConfig = LTConfig.HudDescConfig
local WeaponConfig = LTConfig.WeaponConfig
local DurabilityUIModeType = LTConfig.WeaponConfig.DurabilityUIModeType
local WeaponShootConfig = LTConfig.WeaponShootConfig
local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
local MindButtonTypeType = LTConfig.BattleMindPowerInteractConfig.MindButtonTypeType
local ABPCCCEventConfig = LTConfig.ABPCCCEventConfig
local InputCharacterContextConfig = LTConfig.InputCharacterContextConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
local battleMindPowerInteractConfig = LTConfig.BattleMindPowerInteractConfig
local DOTween = DOTween
local Ease = DG.Tweening.Ease
C_CoreHudCharacterControlStore = DefClass("C_CoreHudCharacterControlStore", C_CoreHudCharacterControlStore, C_StoreGroup)
GroupName2Class.CoreHudCharacterControlStore = C_CoreHudCharacterControlStore
local M = C_CoreHudCharacterControlStore
local WeaponNumType = {
	Gun = 0,
	FreeDurability = 2,
	Percent = 1,
	InfinitePercent = 4,
	InfiniteAmmo = 3
}
local BtnBattleMode = {
	Normal = 1,
	Battle = 0
}
local ChangeWeaponMode = {
	Down = 2,
	Up = 1,
	None = 0
}

function M:ctor()
	self.CfgDurabilityMode2Index = {
		[DurabilityUIModeType.Gun] = WeaponNumType.Gun,
		[DurabilityUIModeType.Percent] = WeaponNumType.Percent,
		[DurabilityUIModeType.Free] = WeaponNumType.FreeDurability,
		[DurabilityUIModeType.InfiniteAmmo] = WeaponNumType.InfiniteAmmo,
		[DurabilityUIModeType.InfinitePercent] = WeaponNumType.InfinitePercent
	}
	self.FRAME_TIME = 0.1
	self.countTime = 0.1
	self.rollerSwitchWeaponCd = 0
	self.isUpdateSkillBtns = {}
	self.isWaitforTweens = {}
	self.changeSkillCountDownData = {}
	self.goSkills = {}
	self.skillGo = {}
	self.skillNormalBtns = {}
	self.skillNormalBtnGos = {}
	self.skillBtnRootGos = {}
	self.aniControlDazhaos = {}
	self.isInAir = nil
	self.isInDive = nil
	self.isGamePadL2Down = false
	self.btnDownFanseAni = "s_vx_HudSkillbtn_fanse"
	self.btnUpFanseAni = "s_vx_HudSkillbtn_fanse_up"
	self.btnFanseAniList = {}
	self.mergeBtnDownCache = {}
	self.xuliBtnAniList = {}
	self.coreHudPanel = nil
	self.circleOpen = false
	self.needUpdateCamera = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.climbHighTip = 615
	self.baoShuaiAnimNameM = "s_vx_HudSkillBtn_click_red"
	self.bigSkillOpenAniNamePc = "s_vx_HudSkillBtn_dazhao_new"
	self.bigSkillCloseAniNamePc = "s_vx_HudSkillBtn_dazhao_new_close"
	self.bigSkillOpenAniNameM = "s_vx_HudSkillBtn_dazhao_M"
	self.bigSkillCloseAniNameM = "s_vx_HudSkillBtn_dazhao_M_close"
	self.btnDownFanseAniPc = "s_vx_HudSkillbtn_fanse_PC_new"
	self.btnUpFanseAniPc = "s_vx_HudSkillbtn_fanse_PC_up_new"
	self.xuliCdAniNamePc = "s_vx_HudSkillBtn_xuli_cd_new"
	self.blockOpenAnim = "S_Vx_CombatBlockNotify_Open"
	self.blockLoopAnim = "S_Vx_CombatBlockNotify_Loop"
	self.blockCloseAnim = "S_Vx_CombatBlockNotify_Disappear"
	self.needUpdateProfessionSkillBtnCD = false
	self.showAmmunition = false
	self.isUltSkill = false
	self.isClimbRun = false
	self.canWallPedalOut = false
	self.canWallPedalUp = false
	self.canWallNormalJumpOut = false
	self.canCounter = false
	self.isOxygenOnShow = false
	self.isBasicNoSkillId = false
	self.isHoldBlend = false
	self.isPressDodge = false
	self.isPressFightSpirit = false
	self.switchControlEnable = true
	self.weaponStateEnum = {
		Fill = 0,
		Broken = 1,
		None = 2
	}
	self.dragButtons = {
		"dodgeBtn",
		"normalAttackBtn",
		"mindPowerBtn",
		"ctrlButton",
		"heavyAttackBtn",
		"highSpeedBtn"
	}
	self.handBagActionType = 2002
	self.motoConditions = {
		[ParkourStateConfig.Moto] = false,
		[ParkourStateConfig.MotorbikeIdle] = false
	}
end

function M:OnAwake()
	self:InitOnAwake()

	gMainMenuMgr.isInitButtonInfo = false

	gMainMenuMgr:SetAwakeUI("awakeBattlePanel")
	gCoreHudUIManager:OnRefreshForAwakeUI()
end

function M:OnDestroy()
	gBattleMgr.characterControlPanel = nil

	self:ClearDataSetEvents()
	self:ClearMessageEvents()
end

function M:OnStart()
	self.coreHudPanel = gStoreManager:GetStoreGroup("CoreHudPanelStore")
	self.curActiveDevice = gCS.LuaUtils.GetActiveDevice()
	gBattleMgr.characterControlPanel = self

	self:BindDataByScheme(self.curActiveDevice)
	self:InitData()

	if gCoreHudTipManager.isEnable then
		gCoreHudTipManager:InitTipDefaultCache()
	else
		gMainMenuMgr:InitButtonInfo()
	end

	gBattleMgr:EnableGrappleSpaceBtn(false)
	self:OnControllerSettingChange(_, ProfileManager.gameProfile.isNewControllerSetting)
end

function M:OnUpdate()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	self:UpdateSkillBtns()
	self:UpdateGamepadCamera()
	self:RefreshProfessionSkillBtnCD()
	self:UpdateWeaponCircleControlSlider()

	self.countTime = self.countTime - Time.deltaTime

	if self.countTime > 0 then
		return
	end

	self.countTime = self.FRAME_TIME

	self:CheckBtnTips()
end

function M:OnLateUpdate()
	if self.curActiveDevice ~= SGUI.GameDevice.PlayStation then
		return
	end

	if self.isPressDodge and self.isPressFightSpirit then
		gMainMenuMgr:ClickSkillBtn(3, true)

		if not self:CheckSkillBtnIsEnable(3) then
			return
		end

		self:PlaySkillBtnDownFanseAni(self.goSkills[3])

		self.mergeBtnDownCache[3] = true

		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(3)
	elseif self.isPressDodge then
		gBattleMgr:OnDodgeBtnPressFunc()
	elseif self.isPressFightSpirit then
		gMainMenuMgr:ClickSkillBtn(3, true)

		if not self:CheckSkillBtnIsEnable(3) then
			return
		end

		self:PlaySkillBtnDownFanseAni(self.goSkills[3])

		self.mergeBtnDownCache[3] = true

		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(3)
	end

	self.isPressDodge = false
	self.isPressFightSpirit = false
end

function M:OnClose()
	gBattleMgr.characterControlPanel = nil

	self:ClearAllBtnFanseAni()
	gMainMenuMgr:SetAwakeUI("awakeBattlePanel")
	gCoreHudUIManager:OnRefreshForAwakeUI()
end

function M:ResetSomeDatas()
	self.aniControlDazhaos = {}
	self.showNomalAttackTips = nil
end

function M:InitData()
	self:GetBtnBindData()
	self:BindBtnEvent()
	self:ReplaceDodgeBtnToMindPower()
	self:InitSkillBtn()
	self:RegisterBtnAction()
	self:SyncRefreshBasicSkills()
	gBattleMgr:CheckShowJobSpecialBtn()
	gBattleMgr:CheckShowWeaponResHUDByTemplateId(gBattleMgr.battleWeaponTemplateId)
	self:ShowAmmunition(self.showAmmunition)
	self:RefreshSwitchToAndriodsBtnState()
	self:OtherInit()
	self:InitShowCostumeSkillState()
	gCS.WeaponMgr:RefreshCurrentAmmunitionInfo()
	gMainMenuMgr:SetAwakeUI("awakeBattlePanel")
	gCoreHudUIManager:OnRefreshForAwakeUI()
end

function M:OtherInit()
	self:UpdateBtnSpriteInAir(false, true)
	self:EnableSeeMobileButton(nil, false)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LuaUtils.SetInRushMode(gCS.MyPlayerManager.PlayerUnit, false)
	end
end

function M:BindDataByScheme(scheme)
	self.characterControlData = self.bindData
end

function M:GetInstRefByPath(path)
	local inst = self.characterControlData[path]

	if not inst then
		return nil
	end

	return inst
end

function M:BindBtnEvent()
	self.characterControlData.jumpSwingBtn.luaPress = self:CreateAction("OnJumpSwingBtnPress")
	self.characterControlData.jumpSwingBtn.luaRelease = self:CreateAction("OnJumpSwingBtnRelease")
	self.characterControlData.jumpSwingBtn.luaBeginLongPress = self:CreateAction("OnJumpSwingBtnLongPressBegin")
	self.characterControlData.jumpSwingBtn.luaLongPress = self:CreateAction("OnJumpSwingBtnLongPress")
	self.characterControlData.jumpSwingBtn.luaEndLongPress = self:CreateAction("OnJumpSwingBtnLongPressEnd")
	local jumpSwingBtnDrag = DragEventListener.Get(self.characterControlData.jumpSwingBtn.gameObject)
	jumpSwingBtnDrag.onDrag = self:CreateAction("OnJumpSwingBtnDrag")

	self:SetShowJumpSwingJoystick(false)

	self.characterControlData.highSpeedBtn.luaPress = self:CreateAction("OnHighSpeedBtnBtnPress")
	self.characterControlData.highSpeedBtn.luaRelease = self:CreateAction("OnHighSpeedBtnRelease")
	self.characterControlData.dodgeBtn.luaPress = self:CreateActionWithArgs("OnDodgeBtnPress", 1)
	self.characterControlData.dodgeBtn.luaRelease = self:CreateActionWithArgs("OnDodgeBtnRelease", 1)
	self.characterControlData.dodgeBtn.luaClick = self:CreateAction("OnDodgeBtnClick")
	self.characterControlData.dodgeBtn.luaBeginLongPress = self:CreateAction("OnDodgeBtnLongPressBegin")
	self.characterControlData.dodgeBtn.luaLongPress = self:CreateAction("OnDodgeBtnLongPress")
	self.characterControlData.dodgeBtn.luaEndLongPress = self:CreateAction("OnDodgeBtnLongPressEnd")
	self.characterControlData.normalAttackBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressBegin", 1)
	self.characterControlData.normalAttackBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 1)
	self.characterControlData.normalAttackBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 1)
	self.characterControlData.mindPowerBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressBegin", 4)
	self.characterControlData.mindPowerBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 4)
	self.characterControlData.mindPowerBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 4)
	self.specialBtnRoot.skillBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressBegin", 2)
	self.specialBtnRoot.skillBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 2)
	self.specialBtnRoot.skillBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 2)
	self.specialBtnRoot.normalBtn.luaBeginLongPress = self:CreateAction("OnEBtnBeginLongPress")
	self.specialBtnRoot.normalBtn.luaLongPress = self:CreateAction("OnEBtnLongPress")
	self.specialBtnRoot.normalBtn.luaEndLongPress = self:CreateAction("OnEBtnEndLongPress")
	self.ultBtnRoot.skillBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressBegin", 3)
	self.ultBtnRoot.skillBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 3)
	self.ultBtnRoot.skillBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 3)
	self.ultBtnRoot.normalBtn.luaBeginLongPress = self:CreateAction("OnRBtnBeginLongPress")
	self.ultBtnRoot.normalBtn.luaLongPress = self:CreateAction("OnRBtnLongPress")
	self.ultBtnRoot.normalBtn.luaEndLongPress = self:CreateAction("OnRBtnEndLongPress")
	self.characterControlData.heavyAttackBtn.luaBeginLongPress = self:CreateAction("OnHeavyAttackBtnLongPressBegin")
	self.characterControlData.heavyAttackBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 5)
	self.characterControlData.heavyAttackBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 5)
	self.characterControlData.dropBtn.luaBeginLongPress = self:CreateAction("OnDropBtnLongPressBegin")
	self.characterControlData.dropBtn.luaLongPress = self:CreateAction("OnDropBtnLongPress")
	self.characterControlData.dropBtn.luaEndLongPress = self:CreateAction("OnDropBtnLongPressEnd")
	self.characterControlData.magnetBtn.luaPress = self:CreateAction("OnMagnetBtnPress")
	self.characterControlData.magnetBtn.luaRelease = self:CreateAction("OnMagnetBtnRelease")
	self.characterControlData.putDownBtn.luaPress = self:CreateAction("OnPutDownBtnPress")
	self.characterControlData.putDownBtn.luaRelease = self:CreateAction("OnPutDownBtnRelease")
	self.characterControlData.putDownBtn.luaClick = self:CreateAction("OnPutDownBtnClick")
	self.characterControlData.costumeSkill.luaPress = self:CreateAction("OnCostumeSkillBtnPress")
	self.characterControlData.costumeSkill.luaRelease = self:CreateAction("OnCostumeSkillBtnRelease")
	self.characterControlData.costumeSkill.luaClick = self:CreateAction("OnCostumeSkillClick")
	self.characterControlData.seeMobileBtn.luaClick = self:CreateAction("SeeMobileButtonClick")

	if self.characterControlData.walkBtn then
		self.characterControlData.walkBtn.luaClick = self:CreateAction("OnWalkBtnClick")
	end

	self.characterControlData.ammunitionRoot.luaPress = self:CreateAction("OnWeaponCircleLongPressStart")
	self.characterControlData.ammunitionRoot.luaRelease = self:CreateAction("OnWeaponCircleLongPressEnd")
	local weaponBtnDrag = DragEventListener.Get(self.characterControlData.ammunitionRoot.gameObject)
	weaponBtnDrag.onBeginDrag = self:CreateAction("OnWeaponBtnDragBegin")
	weaponBtnDrag.onDrag = self:CreateAction("OnWeaponBtnDrag")
	weaponBtnDrag.onEndDrag = self:CreateAction("OnWeaponBtnDragEnd")

	if self.ammunitionRoot and self.ammunitionRoot.mouseScrollRespond then
		self.ammunitionRoot.mouseScrollRespond.luaGamePadInputChanged = self:CreateAction("OnWeaponMouseScroll")
	end

	if self.characterControlData.controllerWeaponSwitchCircle then
		self.characterControlData.controllerWeaponSwitchCircle.luaBeginLongPress = self:CreateAction("OnControllerWeaponSwitchCircleBegin")
		self.characterControlData.controllerWeaponSwitchCircle.luaLongPress = self:CreateAction("OnWeaponCircleLongPressStart")
		self.characterControlData.controllerWeaponSwitchCircle.luaEndLongPress = self:CreateAction("OnWeaponCircleLongPressEnd")
		self.characterControlData.controllerWeaponSwitchCircle.luaClick = self:CreateAction("OnWeaponCircleClick")
	end

	if self.characterControlData.controllerWeaponSwitch then
		self.characterControlData.controllerWeaponSwitch.luaClick = self:CreateAction("OnControllerWeaponSwitch")
	end

	if self.characterControlData.ctrlButton then
		self.characterControlData.ctrlButton.luaPress = self:CreateAction("OnCtrlButtonPress")
		self.characterControlData.ctrlButton.luaRelease = self:CreateAction("OnCtrlButtonRelease")
	end

	self.needUpdateCamera = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.characterControlData.rightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")

	if self.characterControlData.cameraResetBtn then
		self.characterControlData.cameraResetBtn.luaClick = self:CreateAction("OnCameraResetBtnClick")
	end

	if self.characterControlData.outOfRidingBtn then
		self.characterControlData.outOfRidingBtn.luaLongPress = self:CreateAction("OnOutOfRidingBtnClick")
	end

	if self.characterControlData.kickOffBtn then
		self.characterControlData.kickOffBtn.luaPress = self:CreateAction("OnKickOffBtnDown")
		self.characterControlData.kickOffBtn.luaRelease = self:CreateAction("OnKickOffBtnUp")
	end

	if self.characterControlData.spiderBotExitBtn then
		self.characterControlData.spiderBotExitBtn.luaBeginLongPress = self:CreateAction("OnSpiderBotExitBtnLongPressBegin")
		self.characterControlData.spiderBotExitBtn.luaLongPress = self:CreateAction("OnSpiderBotExitBtnLongPress")
		self.characterControlData.spiderBotExitBtn.luaEndLongPress = self:CreateAction("OnSpiderBotExitBtnLongPressEnd")
	end

	if self.characterControlData.professionSkillBtn then
		self.characterControlData.professionSkillBtn.luaPress = self:CreateAction("OnProfessionSkillBtnDown")
		self.characterControlData.professionSkillBtn.luaRelease = self:CreateAction("OnProfessionSkillBtnUp")
	end

	if self.characterControlData.handBagPutDownBtn then
		self.characterControlData.handBagPutDownBtn.luaPress = self:CreateAction("OnHandBagPutDownBtnDown")
		self.characterControlData.handBagPutDownBtn.luaRelease = self:CreateAction("OnHandBagPutDownBtnUp")
	end

	if self.characterControlData.grappleSpaceBtn then
		self.characterControlData.grappleSpaceBtn.luaPress = self:CreateAction("OnGrappleSpaceBtnDown")
		self.characterControlData.grappleSpaceBtn.luaRelease = self:CreateAction("OnGrappleSpaceBtnUp")
	end

	if self.characterControlData.controllerL3 then
		self.characterControlData.controllerL3.luaPress = self:CreateAction("OnControllerL3Down")
		self.characterControlData.controllerL3.luaRelease = self:CreateAction("OnControllerL3Up")
	end

	if self.characterControlData.controllerGunNorth then
		self.characterControlData.controllerGunNorth.luaBeginLongPress = self:CreateAction("OnControllerGunNorthBeginLongPress")
		self.characterControlData.controllerGunNorth.luaLongPress = self:CreateAction("OnControllerGunNorthLongPress")
		self.characterControlData.controllerGunNorth.luaEndLongPress = self:CreateAction("OnControllerGunNorthLongPressEnd")
	end

	if self.characterControlData.controllerGunWest then
		self.characterControlData.controllerGunWest.luaBeginLongPress = self:CreateAction("OnControllerGunWestBeginLongPress")
		self.characterControlData.controllerGunWest.luaLongPress = self:CreateAction("OnControllerGunWestLongPress")
		self.characterControlData.controllerGunWest.luaEndLongPress = self:CreateAction("OnControllerGunWestLongPressEnd")
	end

	if self.characterControlData.leftShootBtn then
		self.characterControlData.leftShootBtn.luaPress = self:CreateActionWithArgs("OnLeftShootBtnDown", 1)
		self.characterControlData.leftShootBtn.luaRelease = self:CreateActionWithArgs("OnLeftShootBtnUp", 1)
		self.characterControlData.leftShootBtn.luaClick = self:CreateActionWithArgs("OnLeftShootBtnClick", 1)
	end

	if self.characterControlData.controllerShot then
		self.characterControlData.controllerShot.luaBeginLongPress = self:CreateAction("OnControllerShootBeginLongPress")
		self.characterControlData.controllerShot.luaLongPress = self:CreateAction("OnControllerShootLongPress")
		self.characterControlData.controllerShot.luaEndLongPress = self:CreateAction("OnControllerShootLongPressEnd")
	end

	self.characterControlData.switchToAndriodsBtn.luaClick = self:CreateAction("OnSwitchToAndriodsBtnClick")

	if self.characterControlData.oxygenTab then
		self.characterControlData.oxygenTab.OnRenderTab = self:CreateAction("OnOxygenRenderTab")
	end

	if self.characterControlData.controllerGunAim then
		self.characterControlData.controllerGunAim.luaBeginLongPress = self:CreateAction("OnControllerAimBeginLongPress")
		self.characterControlData.controllerGunAim.luaLongPress = self:CreateAction("OnControllerAimLongPress")
		self.characterControlData.controllerGunAim.luaEndLongPress = self:CreateAction("OnControllerAimLongPressEnd")
	end

	if self.characterControlData.controllerBlock then
		self.characterControlData.controllerBlock.luaBeginLongPress = self:CreateAction("OnControllerBlockBeginLongPress")
		self.characterControlData.controllerBlock.luaLongPress = self:CreateAction("OnControllerBlockLongPress")
		self.characterControlData.controllerBlock.luaEndLongPress = self:CreateAction("OnControllerBlockLongPressEnd")
	end

	for _, btn in ipairs(self.dragButtons) do
		local btn = self.characterControlData[btn]

		if btn then
			local dragListener = DragEventListener.Get(btn.gameObject)
			dragListener.onDrag = self:CreateAction("OnDragBtnDraging")
		end
	end
end

function M:OnJumpSwingBtnPress(isLongPress)
	self:PlaySkillBtnDownFanseAni(self.jumpSwingBtn)

	if gBattleMgr.btnPaoKuBtnDown or gBattleMgr.btnPaoKuBtnDownFrame == Time.frameCount then
		return
	end

	self.pressJumpKeyDown = true

	if not self.characterControlData.jumpSwingBtn.interactable then
		return
	end

	if gCS.LuaUtils.CanSwing() and self.curActiveDevice <= SGUI.GameDevice.KeyboardMouse then
		gCS.TransitionMgr.isPressingSwingDown = true
	end

	UnitOperateUtils.DoOperateFunc(OperateType.KeyDown, gCS.MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpPress)
	end

	gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.JumpButtonClick)
end

function M:OnCtrlButtonPress()
	self:PlaySkillBtnDownFanseAni(self:GetStoreByWidget(self.characterControlData.ctrlButton))

	local inputModule = gCS.BaseUnitModuleUtils.GetOrAddInputControlModule(gCS.MyPlayerManager.PlayerUnit)
	inputModule.isControlButtonPress = true
end

function M:OnCtrlButtonRelease()
	self:PlaySkillBtnUpFanseAni(self:GetStoreByWidget(self.characterControlData.ctrlButton))

	local inputModule = gCS.BaseUnitModuleUtils.GetOrAddInputControlModule(gCS.MyPlayerManager.PlayerUnit)
	inputModule.isControlButtonPress = false
end

function M:OnJumpSwingBtnRelease(notPlayAni)
	if gBattleMgr.gmIgnoreJumpSwingBtnUp then
		return
	end

	self:PlaySkillBtnUpFanseAni(self.jumpSwingBtn, nil, notPlayAni)

	if not self.pressJumpKeyDown and not self.characterControlData.jumpSwingBtn.interactable then
		return
	end

	self.pressJumpKeyDown = false

	if gCS.LuaUtils.CanSwing() and self.curActiveDevice <= SGUI.GameDevice.KeyboardMouse then
		gCS.TransitionMgr.isPressingSwingDown = false
	end

	UnitOperateUtils.DoOperateFunc(OperateType.KeyUp, gCS.MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpRelease)
	end
end

function M:OnJumpSwingBtnLongPressBegin()
	self.needShowSwingJoyStick = true

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:OnJumpSwingBtnPress(true)
	end
end

function M:OnJumpSwingBtnLongPress()
	if not self.characterControlData.jumpSwingBtn.interactable then
		return
	end

	self.alreadyPressJumpSwingBtn = true

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpShortHold)
	end

	if gBattleMgr.isBattleUI then
		local isOk = false

		if gBattleMgr.IsUseNewCombo then
			isOk = gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.JumpButtonPressin)
		end

		if isOk then
			return
		end
	end
end

function M:OnJumpSwingBtnLongPressEnd()
	self.needShowSwingJoyStick = false

	self:SetShowJumpSwingJoystick(false)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:OnJumpSwingBtnRelease()
	end

	if self.alreadyPressJumpSwingBtn or not self.characterControlData.jumpSwingBtn.interactable then
		return
	end

	self.alreadyPressJumpSwingBtn = false

	if gBattleMgr.isBattleUI then
		local isOk = false

		if gBattleMgr.IsUseNewCombo then
			isOk = gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.JumpButtonPressout)
		end

		if isOk then
			return
		end
	end
end

function M:OnJumpSwingBtnDrag(eventPointer)
	self:OnDragBtnDraging(eventPointer)
	self:SetSwingHandlePos(eventPointer)
end

function M:SetShowJumpSwingJoystick(isShow)
	if not self.characterControlData.jumpSwingHandle then
		return
	end

	self.isShowSwingJoyStick = isShow

	self.characterControlData.jumpSwingBottom:SetActive(isShow)
	self.characterControlData.jumpSwingHandle:SetActive(isShow)
	self.characterControlData.jumpSwingHandle:SetLocalPos(Vector3.zero)
end

function M:SetSwingHandlePos(eventPointer)
	if not self.characterControlData.jumpSwingHandle then
		return
	end

	local uiPoint = gCS.LuaUtils.TransformScreenPointToUI(self.characterControlData.jumpSwingBtn.rectTransform, eventPointer.position)
	local center = {
		x = 0,
		y = 0
	}
	local radius = LTConfig.GameConfig.JumpSwingBtnDragRadius
	local handlePos = self:GetPointInCircle(center, radius, uiPoint)

	self.characterControlData.jumpSwingHandle:SetLocalPos(handlePos)
end

function M:GetPointInCircle(center, radius, point)
	local dx = point.x - center.x
	local dy = point.y - center.y
	local distance = math.sqrt(dx * dx + dy * dy)

	if distance <= radius then
		return point
	else
		local unitVector = {
			x = dx / distance,
			y = dy / distance
		}
		local edgePoint = {
			x = center.x + unitVector.x * radius,
			y = center.y + unitVector.y * radius
		}

		return edgePoint
	end
end

function M:OnHighSpeedBtnBtnPress()
	if not self.characterControlData.highSpeedBtn.interactable then
		gBattleMgr:ShowMessageTipsOnEditor("colliderHighSpeed关闭")

		return
	end

	self:PlaySkillBtnDownFanseAni(self.highSpeedBtn)

	self.characterControlData.showSwingJoystick = true

	gBattleMgr:ShowMessageTipsOnEditor("触发BtnHightSpeedDown")

	if not self.isHightSpeedDown then
		self:HighSpeedDown()
	else
		self:HighSpeedUp()
	end
end

function M:HighSpeedDown()
	self.isHightSpeedDown = true
	self.isHightSpeedDownNow = true
	gCS.TransitionMgr.isHightSpeedDown = true
	gCS.TransitionMgr.isHightSpeedDownNow = true

	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.NoMoveTime == 0 then
		gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashPress)

	self.isHightSpeedDownNow = false
	gCS.TransitionMgr.isHightSpeedDownNow = false
end

function M:HighSpeedUp()
	self.isHightSpeedDown = false
	gCS.TransitionMgr.isHightSpeedDown = false

	if gCS.MyPlayerManager.PlayerUnit.NoMoveTime == 0 then
		self.isHightSpeedUp = true
		gCS.TransitionMgr.isHightSpeedUp = true

		gCS.LuaUtils.CheckSwitchAction(true, false, false, 0)

		self.isHightSpeedUp = false
		gCS.TransitionMgr.isHightSpeedUp = false
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashRelease)
end

function M:OnHighSpeedBtnRelease()
	self:PlaySkillBtnUpFanseAni(self.highSpeedBtn)
end

function M:OnDodgeBtnPress(data)
	if not self.characterControlData.dodgeBtn.interactable or data == 2 and not gBattleMgr:CheckIsInMotorState() then
		gBattleMgr:ShowMessageTipsOnEditor("colliderHighSpeed关闭")

		return
	end

	self:PlaySkillBtnDownFanseAni(self.dodgeBtn)

	if self.curActiveDevice == SGUI.GameDevice.PlayStation then
		self.isPressDodge = true
	else
		gBattleMgr:OnDodgeBtnPressFunc()
	end
end

function M:OnDodgeBtnRelease()
	self:PlaySkillBtnUpFanseAni(self.dodgeBtn)
	gBattleMgr:OnDodgeBtnReleaseFunc()
end

function M:OnDodgeBtnClick()
	return
end

function M:OnDodgeBtnLongPressBegin()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:OnDodgeBtnPress()
	end
end

function M:OnDodgeBtnLongPress()
	if not gBattleMgr.canDodge then
		return
	end

	self.alreadyPressDodgeBtn = true
	local isOk = false

	if gBattleMgr.IsUseNewCombo then
		isOk = gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.DodgeButtonPressin)
	end

	if isOk then
		return
	end

	local skillId = 0

	if skillId > 0 then
		gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, skillId, -1, ClientEventConfig.DodgeButtonPressin)
	end
end

function M:OnDodgeBtnLongPressEnd()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:OnDodgeBtnRelease()
	end

	if not self.alreadyPressDodgeBtn then
		return
	end

	self.alreadyPressDodgeBtn = false

	if not gBattleMgr.canDodge then
		return
	end

	local isOk = false

	if gBattleMgr.IsUseNewCombo then
		isOk = gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.DodgeButtonPressout)
	end

	if isOk then
		return
	end
end

function M:OnDropBtnLongPressBegin()
	if not self.characterControlData.dropBtn.interactable then
		gBattleMgr:ShowMessageTipsOnEditor("跳下墙按钮的collider被关闭了")

		return
	end

	self:PlaySkillBtnDownFanseAni(self.dropBtn)

	if not gCoreHudUIManager.isOnWall then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.StockAttack)
	end

	gCS.TransitionMgr.wallJumpOffDown = true

	gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

	gCS.TransitionMgr.wallJumpOffDown = false

	gCS.LogicStateMachineManager.SendWall3CEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.WallCCCEvent.X_KEYCODE_LeaveWall)
end

function M:OnDropBtnLongPress()
	if not gCoreHudUIManager.isOnWall then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.StockAttack)
	end
end

function M:OnDropBtnLongPressEnd()
	self:PlaySkillBtnUpFanseAni(self.dropBtn)

	if not self.characterControlData.dropBtn.interactable then
		gBattleMgr:ShowMessageTipsOnEditor("跳下墙按钮的collider被关闭了")

		return
	end

	gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

	if not gCoreHudUIManager.isOnWall then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.StockAttack)
	end
end

function M:OnMagnetBtnPress()
	if not self.characterControlData.magnetBtn.interactable then
		gBattleMgr:ShowMessageTipsOnEditor("磁力按钮的collider被关闭了")

		return
	end

	self:PlaySkillBtnDownFanseAni(self.magnetBtn)

	local inHoldMode = false
	inHoldMode = gCS.MindPowerMgr.inHoldMode

	if not inHoldMode then
		gBattleMgr:ShowMessageTipsOnEditor("不在hold模式 无法进入磁力")
	end

	gBattleMgr:CheckEnterMagnet(true)
end

function M:OnMagnetBtnRelease()
	self:PlaySkillBtnUpFanseAni(self.magnetBtn)

	if not self.characterControlData.magnetBtn.interactable then
		gBattleMgr:ShowMessageTipsOnEditor("磁力按钮的collider被关闭了")

		return
	end
end

function M:OnPutDownBtnPress()
	self:PlaySkillBtnDownFanseAni(self.putDownBtn)
	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.ControlPower, true)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.ControlPower)
end

function M:OnPutDownBtnRelease()
	self:PlaySkillBtnUpFanseAni(self.putDownBtn)
	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.ControlPower, false)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.ControlPower)
end

function M:OnPutDownBtnClick()
	return
end

local CostumeSkillKeyId = {
	Close = 586,
	Open = 585
}

function M:OnCostumeSkillClick()
	if not self.isOpenNightVision then
		gCS.LuaUtils.SetTaskGIRendPass(true, true)
		self.characterControlData.costumeSkill:SetPCKeyInfoTipNameId(CostumeSkillKeyId.Close)

		self.isOpenNightVision = true
	else
		gCS.LuaUtils.SetTaskGIRendPass(false, false)
		self.characterControlData.costumeSkill:SetPCKeyInfoTipNameId(CostumeSkillKeyId.Open)

		self.isOpenNightVision = false
	end
end

function M:OnCostumeSkillBtnPress()
	self:PlaySkillBtnDownFanseAni(self.costumeSkill)
end

function M:OnCostumeSkillBtnRelease()
	self:PlaySkillBtnUpFanseAni(self.costumeSkill)
end

function M:InitShowCostumeSkillState()
	self:RefreshPlayerFashionData()
end

function M:RefreshPlayerFashionData()
	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.FashionSlot then
		local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot
		local allPropIds = fashionSlot:GetAllFashionPropId()

		self:CheckPlayerFashion(allPropIds)
	end
end

function M:CheckPlayerFashion(allPropIds)
	local faraway = true

	if allPropIds then
		for i = 0, allPropIds.Length - 1 do
			if allPropIds[i] == LTConfig.FashionConfig.OpenNightVision or allPropIds[i] == LTConfig.FashionConfig.CloseNightVision then
				faraway = false
			end
		end
	end

	if not faraway and self.isOpenNightVision then
		self:OnCostumeSkillClick()
	end

	self.characterControlData.costumeSkill:SetWidgetFaraway(faraway)
end

function M:OnMergeBtnLongPressBegin(data, notFromBtnDown)
	if data == 3 and self.curActiveDevice == SGUI.GameDevice.PlayStation then
		self.isPressFightSpirit = true

		return
	end

	gMainMenuMgr:ClickSkillBtn(data, true)

	if not self:CheckSkillBtnIsEnable(data) then
		return
	end

	self:PlaySkillBtnDownFanseAni(self.goSkills[data])

	self.mergeBtnDownCache[data] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(data)
end

function M:OnMergeBtnLongPressEnd(data)
	gMainMenuMgr:ClickSkillBtn(data, false)

	if not self.mergeBtnDownCache[data] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[data] = false

	self:PlaySkillBtnUpFanseAni(self.goSkills[data], data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(data)
end

function M:OnMergeBtnClick(data)
	return
end

function M:OnMergeBtnLongPress(data)
	if not self:CheckSkillBtnIsEnable(data) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(data)
end

function M:OnMergeBtnDragBegin(index, eventPointer)
	return
end

function M:OnMergeBtnDrag(index, eventPointer)
	self:OnDragBtnDraging(eventPointer)
end

function M:OnMergeBtnDragEnd(index, eventPointer)
	return
end

function M:OnEBtnBeginLongPress()
	if self.isHoldBlend then
		gCS.MindPowerMgr:TryLaunchCurMindItem()
	else
		self:OnMergeBtnLongPressBegin(2)
	end
end

function M:OnEBtnLongPress()
	if self.isHoldBlend then
		return
	end

	self:OnMergeBtnLongPress(2)
end

function M:OnEBtnEndLongPress()
	if self.isHoldBlend then
		return
	end

	self:OnMergeBtnLongPressEnd(2)
end

function M:OnRBtnBeginLongPress()
	return
end

function M:OnRBtnLongPress()
	return
end

function M:OnRBtnEndLongPress()
	return
end

function M:OnLeftShootBtnDown()
	local data = 1

	if not self:CheckSkillBtnIsEnable(data) then
		return
	end

	self:PlaySkillBtnDownFanseAni(self.leftShootBtn)

	self.mergeBtnDownCache[data] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(data)
end

function M:OnLeftShootBtnUp()
	local data = 1

	if not self.mergeBtnDownCache[data] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[data] = false

	self:PlaySkillBtnUpFanseAni(self.leftShootBtn, data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(data)
end

function M:OnLeftShootBtnClick()
	return
end

function M:GetSensitivity(isHoriZontal)
	local sensitivity = isHoriZontal and ProfileManager.gameProfile.swingCameraRotateXLevel or ProfileManager.gameProfile.swingCameraRotateYLevel

	if sensitivity < 1 then
		sensitivity = isHoriZontal and GameConfig.FreeLookRotateXDefaultSensitivity or GameConfig.FreeLookRotateYDefaultSensitivity

		if isHoriZontal then
			ProfileManager.gameProfile.swingCameraRotateXLevel = sensitivity
		else
			ProfileManager.gameProfile.swingCameraRotateYLevel = sensitivity
		end

		ProfileManager.SaveGameProperty()
	end

	return sensitivity
end

function M:UpdateMindPowerBtn()
	self:UpdateControlPowerSkill(true)
end

function M:XuliKeyDown()
	gCS.TransitionMgr.isXuliKeyDown = true
	local ok = gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
	gCS.TransitionMgr.isXuliKeyDown = false

	if not ok then
		gCS.SaveActionManager.Instance:CheckSaveAction(gCS.MyPlayerManager.PlayerUnit, gBattleMgr.SaveActionType.Dodge)
	end
end

function M:InitOnAwake()
	return
end

function M:OnBeforeSwitchScene()
	self.energyDotActive = nil

	self:EnableEnergyDotRoot(false)
	self:ClearAllBtnFanseAni()
end

function M:GetBtnBindData()
	self.jumpSwingBtn = self:GetStoreByWidget(self.characterControlData.jumpSwingBtn)
	self.jumpSwingBtn.btnId = HudDescConfig.JUMP_SWING_BTN
	self.highSpeedBtn = self:GetStoreByWidget(self.characterControlData.highSpeedBtn)
	self.highSpeedBtn.btnId = HudDescConfig.HIGH_SPEED_BTN
	self.dodgeBtn = self:GetStoreByWidget(self.characterControlData.dodgeBtn)
	self.dodgeBtn.btnId = HudDescConfig.DODGE_BTN
	self.normalSkillBtn = self:GetStoreByWidget(self.characterControlData.normalAttackBtn)
	self.normalSkillBtn.btnId = HudDescConfig.NORMAL_ATTACK_BTN
	self.specialBtnRoot = self:GetStoreByWidget(self.characterControlData.specialBtnRoot)
	self.basicSkillBtn = self:GetStoreByWidget(self.specialBtnRoot.skillBtn)
	self.basicSkillBtn.btnId = HudDescConfig.SPECIAL_BTN
	self.basicNormalBtn = self:GetStoreByWidget(self.specialBtnRoot.normalBtn)
	self.ultBtnRoot = self:GetStoreByWidget(self.characterControlData.ultBtnRoot)
	self.bigSkillBtn = self:GetStoreByWidget(self.ultBtnRoot.skillBtn)
	self.bigSkillBtn.btnId = HudDescConfig.ULT_BTN
	self.ultNormalBtn = self:GetStoreByWidget(self.ultBtnRoot.normalBtn)
	self.mindPowerBtn = self:GetStoreByWidget(self.characterControlData.mindPowerBtn)
	self.mindPowerBtn.btnId = HudDescConfig.MIND_POWER_BTN
	self.heavyAttackBtn = self:GetStoreByWidget(self.characterControlData.heavyAttackBtn)
	self.mindPowerBtn.btnId = HudDescConfig.MIND_POWER_BTN
	self.dropBtn = self:GetStoreByWidget(self.characterControlData.dropBtn)
	self.dropBtn.btnId = HudDescConfig.DROP_BTN
	self.magnetBtn = self:GetStoreByWidget(self.characterControlData.magnetBtn)
	self.magnetBtn.btnId = HudDescConfig.MAGNET_BTN
	self.putDownBtn = self:GetStoreByWidget(self.characterControlData.putDownBtn)
	self.putDownBtn.btnId = HudDescConfig.PUT_DOWN_BTN
	self.costumeSkill = self:GetStoreByWidget(self.characterControlData.costumeSkill)
	self.seeMobileBtn = self:GetStoreByWidget(self.characterControlData.seeMobileBtn)
	self.medicineBtn = self:GetStoreByWidget(self.characterControlData.medicineBtn)
	self.kickOffBtn = self:GetStoreByWidget(self.characterControlData.kickOffBtn)
	self.ammunitionRoot = self:GetStoreByWidget(self.characterControlData.ammunitionRoot)
	self.professionSkillBtn = self:GetStoreByWidget(self.characterControlData.professionSkillBtn)
	self.spiderBotExitBtn = self:GetStoreByWidget(self.characterControlData.spiderBotExitBtn)
	self.handBagPutDownBtn = self:GetStoreByWidget(self.characterControlData.handBagPutDownBtn)
	self.grappleSpaceBtn = self:GetStoreByWidget(self.characterControlData.grappleSpaceBtn)
	self.switchToAndriodsBtn = self:GetStoreByWidget(self.characterControlData.switchToAndriodsBtn)
	self.ctrlBtn = self:GetStoreByWidget(self.characterControlData.ctrlButton)

	if self.bigSkillBtn then
		self.energyDot = self:GetStoreByWidget(self.bigSkillBtn.energyDot)
	end

	if self.characterControlData.leftShootBtn then
		self.leftShootBtn = self:GetStoreByWidget(self.characterControlData.leftShootBtn)
	end

	if self.characterControlData.holdLeftBtn then
		self.holdLeftBtn = self:GetStoreByWidget(self.characterControlData.holdLeftBtn)
	end

	if self.characterControlData.holdEBtn then
		self.holdEBtn = self:GetStoreByWidget(self.characterControlData.holdEBtn)
	end

	if self.characterControlData.holdRBtn then
		self.holdRBtn = self:GetStoreByWidget(self.characterControlData.holdRBtn)
	end

	self.skillGo[gBattleMgr.SkillBtnType.Normal] = self.characterControlData.normalAttackBtn
	self.skillGo[gBattleMgr.SkillBtnType.Basic] = self.specialBtnRoot.skillBtn
	self.skillGo[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = self.ultBtnRoot.skillBtn
	self.skillGo[gBattleMgr.SkillBtnType.ControlPower] = self.characterControlData.mindPowerBtn
	self.skillGo[gBattleMgr.SkillBtnType.HeavyAttack] = self.characterControlData.heavyAttackBtn
	self.skillNormalBtnGos[gBattleMgr.SkillBtnType.Basic] = self.specialBtnRoot.normalBtn
	self.skillNormalBtnGos[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = self.ultBtnRoot.normalBtn
	self.skillBtnRootGos[gBattleMgr.SkillBtnType.Basic] = self.specialBtnRoot.bindWidget
	self.skillBtnRootGos[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = self.ultBtnRoot.bindWidget
	self.basicSkillBtnGo = self.specialBtnRoot.skillBtn
	self.basicNormalBtnGo = self.specialBtnRoot.normalBtn
	self.ultSkillBtnGo = self.ultBtnRoot.skillBtn
	self.ultNormalBtnGo = self.ultBtnRoot.normalBtn
	self.dodgeBtn.multiBtn.luaPress = self:CreateActionWithArgs("OnDodgeBtnPress", 2)
	self.dodgeBtn.multiBtn.luaRelease = self:CreateActionWithArgs("OnDodgeBtnRelease", 2)
	self.highSpeedBtn.multiBtn.luaPress = self:CreateAction("OnHighSpeedBtnBtnPress")
	self.highSpeedBtn.multiBtn.luaRelease = self:CreateAction("OnHighSpeedBtnRelease")
	self.highSpeedBtn.multiBtn.luaClick = self:CreateAction("OnHighSpeedBtnClick")
end

function M:InitSkillBtn()
	self.goSkills[gBattleMgr.SkillBtnType.Normal] = self.normalSkillBtn
	self.goSkills[gBattleMgr.SkillBtnType.Basic] = self.basicSkillBtn
	self.goSkills[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = self.bigSkillBtn
	self.goSkills[gBattleMgr.SkillBtnType.ControlPower] = self.mindPowerBtn
	self.goSkills[gBattleMgr.SkillBtnType.HeavyAttack] = self.heavyAttackBtn
	self.skillNormalBtns[gBattleMgr.SkillBtnType.Basic] = self.basicNormalBtn
	self.skillNormalBtns[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = self.ultNormalBtn

	self.characterControlData.dodgeBtn.gameObject:SetActive(true)
	self.characterControlData.highSpeedBtn.gameObject:SetActive(false)
end

function M:RegisterBtnAction()
	self.msgEvents = {
		[gEventConstants.CONTROLPOWER_REFRESH] = self:CreateAction("UpdateControlPowerSkill"),
		[gEventConstants.MIND_POWER_CHANGE] = self:CreateAction("UpdateMindPowerBtn"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("SystemUnlockStateChange"),
		[gEventConstants.BEFORE_SWITCH_SCENE] = self:CreateAction("OnBeforeSwitchScene"),
		[gEventConstants.CAST_SKILL] = self:CreateAction("CastSkillAction"),
		[gEventConstants.ENABLE_SEE_MOBILE_BUTTON] = self:CreateAction("EnableSeeMobileButton"),
		[gEventConstants.MIND_POWER_CHANGE] = self:CreateAction("OnMindAimItemChange"),
		[gEventConstants.MIND_INTERACT_CHANGE] = self:CreateAction("OnMindAimItemChange"),
		[gEventConstants.PAOKU_STATE_CHANGE] = self:CreateAction("OnParkourStateChange"),
		[gEventConstants.NOTIFY_CHANGE_SKILL_RESOURCE] = self:CreateAction("OnSkillResourceChanged"),
		[gEventConstants.CHANGE_MY_UNIT] = self:CreateAction("OnSpiritChange"),
		[gEventConstants.WEAPON_CHANGED] = self:CreateAction("OnWeaponChange"),
		[gEventConstants.ON_SKILL_BTN_REFRESH] = self:CreateAction("UpdateBtnState"),
		[gEventConstants.ON_BATTLE_BTN_EVENT] = self:CreateAction("OnBattlePanelBtnEvent"),
		[gEventConstants.ON_UPDATE_BASIC_SKILL] = self:CreateActionWithArgs("UpdateBasicSkills", 1),
		[gEventConstants.SUMMON_STATE_SWITCH] = self:CreateAction("RefreshSwitchToAndriodsBtnState"),
		[gEventConstants.NOTIFY_CAN_BE_COUNTER] = self:CreateAction("OnPerfectBlockEvent"),
		[gEventConstants.ON_RANGED_WEAPON] = self:CreateAction("OnChangeWeaponType"),
		[gEventConstants.UNIT_CHANGE_FASHION] = self:CreateAction("RefreshPlayerFashionData"),
		[gEventConstants.ON_HIGH_OBSTACLE] = self:CreateAction("OnHighObstacle"),
		[gEventConstants.ON_WING_SUIT_DRESSED] = self:CreateAction("SetWingSuitDressed"),
		[gEventConstants.WEAPON_DURABILITY_CHANGE] = self:CreateAction("CheckWeaponDurability"),
		[gEventConstants.CURRENT_SPIRIT_WEAPON_CHANGE] = self:CreateAction("OnCurrentWeaponChange"),
		[gEventConstants.ON_OXYGEN_UPDATE] = self:CreateAction("UpdateOxygenUI"),
		[gEventConstants.ON_OXYGEN_OPEN] = self:CreateAction("CheckOxygenShow"),
		[gEventConstants.ON_CORE_HUD_DIVE] = self:CreateAction("UpdateBtnSpriteDive"),
		[gEventConstants.SETTING_CONTROLLER_TYPE_CHANGE] = self:CreateAction("OnControllerSettingChange"),
		[gEventConstants.ON_WINGSUIT_CHANGE] = self:CreateAction("UpdateDodgeBtnSprite"),
		[gEventConstants.PAOKU_STATE_ADD_REMOVE] = self:CreateAction("OnParkourAddRemove"),
		[gEventConstants.MIND_COUNTER_ATTACK_ENABLE_CHANGED] = self:CreateAction("OnMindCounterAttack"),
		[gEventConstants.TASK_WORKACTION_MOBILE_VX] = self:CreateAction("OnWorkActionVxChange"),
		[gEventConstants.SYNC_REFRESH_BASIC_SKILL] = self:CreateAction("SyncRefreshBasicSkills"),
		[gEventConstants.ON_UPDATE_SKILL_BTN] = self:CreateAction("UpdateSkillBtns"),
		[gEventConstants.SYNC_REFRESH_FIGHT_SKILL] = self:CreateAction("UpdateFightSpiritBigSkill"),
		[gEventConstants.ON_UPDATE_SKILL_CD] = self:CreateAction("UpdateSkillCD"),
		[gEventConstants.ON_REFRESH_ULT_EP] = self:CreateAction("UpdateUltCdAndEp"),
		[gEventConstants.ON_TAFFY_MOTO] = self:CreateAction("OnRefreshMotoState"),
		[gEventConstants.HACK_SUMMON_QUERY_CHANGED] = self:CreateAction("OnSwitchControlChanged"),
		[gEventConstants.SPIRIT_INFO_CHANGED] = self:CreateAction("OnSpiritInfoChanged")
	}
	self.dataSetEvents = {
		{
			gPlayerManager.main.bindData,
			"isMindPowerAim",
			self:CreateAction("UpdateMindPowerBtn")
		},
		{
			gPlayerManager.main.bindData,
			"isMindPowerAim",
			self:CreateActionWithArgs("UpdateBasicSkills", 1)
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Normal,
			self:CreateAction("UpdatePCAndGamepadBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Basic,
			self:CreateAction("UpdatePCAndGamepadBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.FightSpiritBigSkill,
			self:CreateAction("UpdatePCAndGamepadBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.ControlPower,
			self:CreateAction("UpdateSkillBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.HeavyAttack,
			self:CreateAction("UpdatePCAndGamepadBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.SwitchWeaponWheels,
			self:CreateAction("UpdateSwitchWeaponWheelsState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Hold_E,
			self:CreateAction("UpdateBtnHoldState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Hold_R,
			self:CreateAction("UpdateBtnHoldState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Hold_Left,
			self:CreateAction("UpdateBtnHoldState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Dodge,
			self:CreateAction("UpdateBtnDataSetState")
		}
	}

	self:ClearDataSetEvents()
	self:ClearMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterDataSetEvents(self.dataSetEvents)
end

function M:SyncRefreshBasicSkills(eventId, index)
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("CoreHudCharacterControlStore.SyncRefreshBasicSkills")
	end

	self:UpdateBasicSkills(index)
	self:UpdateControlPowerSkill()
	self:UpdateHeavyAttackBtn()
	self:UpdateFightSpiritBigSkill()

	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.Normal] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.Basic] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.ControlPower] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.HeavyAttack] = true

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:UpdateBasicSkills(index)
	local templateId = 0
	local normalSkillId, basicSkillId = gCS.BattleManager.GetNormalAndBasicSkill(0, 0)

	for i = 1, 2 do
		local notExcute = index ~= nil and index ~= i

		if not notExcute then
			local skillId = i == 1 and normalSkillId or basicSkillId
			local cfgSkill = SkillConfig.GetConfig(skillId)
			local cfgImageId = gBattleMgr:GetNormalSkillImg(cfgSkill)

			if i == 1 and not gBattleMgr:UsePCBattleHUD() then
				if gBattleMgr.showBaoShuaiHint then
					cfgImageId = gCoreHudImgManager.imgBaoShuaiId
					local ani = self.goSkills[i].clickRedAni

					if not ani then
						return
					end

					ani.gameObject:SetActive(true)
					gBattleMgr:CommonPlayAniTool(ani, self.baoShuaiAnimNameM, 0, 1, false)
				else
					local ani = self.goSkills[i].clickRedAni

					if not ani then
						return
					end

					gBattleMgr:CommonStopAniTool(ani, self.baoShuaiAnimNameM)
					ani.gameObject:SetActive(false)
				end
			end

			if i == 2 then
				cfgImageId = gBattleMgr:GetBasicSkillImg(cfgSkill)
				self.isBasicNoSkillId = skillId == 0

				self:CheckChangeBtnMode()
			end

			gCoreHudTipManager:UpdateBtnIconState(i, gCoreHudTipManager.conditionType.Default, cfgImageId)

			if i == gBattleMgr.SkillBtnType.Normal then
				local flag, textId, higtLight = nil
				flag, textId, higtLight = gCoreHudUIManager:GetNormalSkillText()
				self.normalSkillBtn.wordsCtrl = flag and 1 or 0
				self.normalSkillBtn.notifyWord = LTConfig.TextScriptTextConfig.GetConfig(textId).Text
				self.normalSkillBtn.qteVxCtrl = higtLight and 1 or 0
			end

			gBattleMgr:SetSkillData(i, skillId, cfgImageId, false)
			gBattleMgr:SetComboSkill(i, templateId, skillId)
			gMainMenuMgr:ForbidSkillBtnByNoSkillId(i, skillId == 0)
		end
	end
end

function M:UpdateControlPowerSkill(force)
	gMainMenuMgr:CheckNoPowerState()
	gMainMenuMgr:CheckInCrouchAssassination()

	local skillId = gCS.MindPowerMgr:GetBattleFightControlPowerSkill()

	if not force and gBattleMgr.skillData[gBattleMgr.SkillBtnType.ControlPower] ~= nil and gBattleMgr.skillData[gBattleMgr.SkillBtnType.ControlPower].skillId == skillId then
		return
	end

	local cfgSkill = SkillConfig.GetConfig(skillId)
	local cfgImageId = gBattleMgr:GetMindPowerImg(cfgSkill)
	local text = gPlayerManager.main.bindData.isMindPowerAim and LTConfig.TextScriptTextConfig.GetConfig(89901016).Text or ""
	self.mindPowerBtn.wordsCtrl = gPlayerManager.main.bindData.isMindPowerAim and 1 or 0
	self.mindPowerBtn.tipText = text

	self:SetBtnIcon(self.goSkills[gBattleMgr.SkillBtnType.ControlPower], cfgImageId)
	gBattleMgr:SetSkillData(gBattleMgr.SkillBtnType.ControlPower, skillId, cfgImageId, false)
	gBattleMgr:SetComboSkill(gBattleMgr.SkillBtnType.ControlPower, 0, skillId)
end

function M:UpdateFightSpiritBigSkill()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local index = 1
	local skillId = gCS.BattleManager.GetUniqueSkillId()
	local unit = gCS.MyPlayerManager.PlayerUnit
	local isFull = false

	if unit then
		isFull = gBattleMgr:IsSkillFightResourceEnough(unit, skillId)
	end

	local cfgSkill = SkillConfig.GetConfig(skillId)
	local cfgImageId = gBattleMgr:GetBigSkillImg(cfgSkill)
	self.isUltSkill = cfgSkill and cfgSkill.SkillCastTypeTag == SkillConfig.SkillCastTypeTagType.Unique or false

	if gCoreHudTipManager.isEnable then
		gCoreHudTipManager:UpdateBtnIconState(3, gCoreHudTipManager.conditionType.Default, cfgImageId)
	else
		self:SetBtnIcon(self.goSkills[gBattleMgr.SkillBtnType.FightSpiritBigSkill], cfgImageId)
	end

	gBattleMgr:SetSkillData(gBattleMgr.SkillBtnType.FightSpiritBigSkill, skillId, cfgImageId, false)
	gBattleMgr:SetComboSkill(gBattleMgr.SkillBtnType.FightSpiritBigSkill, 0, skillId)

	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = true

	gMainMenuMgr:ForbidSkillBtnByNoSkillId(gBattleMgr.SkillBtnType.FightSpiritBigSkill, skillId == 0)

	local canUseBigSkill = gBattleMgr:CheckCanShowUniqueSkillInfo(skillId)
	self.bigSkillBtn.energyCtrl = canUseBigSkill and 1 or 0

	gBattleMgr:RefreshFightSpiritUniqueSkillEnergy()

	if isFull and self.bigSkillBtn.energyCtrl == 1 then
		local isCDFinished = gCS.BattleManager.IsCDFinished(skillId)
		self.aniControlDazhaos[index] = isCDFinished

		self:SwitchFightSpiritEpFull(false, isCDFinished)
	else
		self.aniControlDazhaos[index] = false

		self:SwitchFightSpiritEpNoFull()
	end

	self.isWaitforTweens = {}
end

function M:CheckIsClimbRun()
	self.isClimbRun = gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbRun

	self:CheckShowDropDownBtnTips()
end

function M:SetCanPedalOut(enable)
	self.canWallPedalOut = enable

	self:CheckShowDropDownBtnTips()
end

function M:SetCanPedalUp(enable)
	self.canWallPedalUp = enable

	self:CheckShowDropDownBtnTips()
end

function M:SetCanPedalJumpOut(enable)
	self.canWallNormalJumpOut = enable

	self:CheckShowDropDownBtnTips()
end

function M:CheckShowDropDownBtnTips()
	if not self.characterControlData then
		return
	end

	local enable = false
	local templateId = self.dropDownBtnTemplateId or 0
	local nameIdX = self.dropDownBtnNameId or 0
	local jumpBtnEnable = false
	local nameId = self.jumpBtnNameId or 0

	if gPlayerManager.main.bindData.isFreeClimbing then
		enable = gPlayerManager.main.bindData.isFreeClimbing
		templateId = SGUI.GameDevice.KeyboardMouse < self.curActiveDevice and 8 or 4
		nameIdX = self.isClimbRun and not self.canWallPedalUp and 339 or 235
		jumpBtnEnable = self.canWallPedalOut or self.canWallPedalUp

		if self.canWallPedalOut then
			nameId = 346
		elseif self.canWallPedalUp then
			nameId = 338
		else
			nameId = 339
		end
	end

	if self.dropDownBtnEnable ~= enable or self.dropDownBtnTemplateId ~= templateId or self.dropDownBtnNameId ~= nameIdX then
		self.dropDownBtnEnable = enable
		self.dropDownBtnTemplateId = templateId
		self.dropDownBtnNameId = nameIdX

		gBattleMgr:CheckShowBtnTips(self.characterControlData.dropBtn, 2, enable, nameIdX)
	end

	if self.jumpBtnEnable ~= jumpBtnEnable or self.jumpBtnNameId ~= nameId then
		self.jumpBtnEnable = jumpBtnEnable
		self.jumpBtnNameId = nameId

		gBattleMgr:CheckShowBtnTips(self.characterControlData.jumpSwingBtn, templateId, jumpBtnEnable, nameId)

		if self.coreHudPanel.bindData.gamePadArea then
			self.coreHudPanel.bindData.gamePadArea:SetButtonInfoTipNameId(nameId, 2)
			self.coreHudPanel.bindData.gamePadArea:ChangeButtonTipInfoByActionId(3, templateId, 2, 0, jumpBtnEnable)
		end
	end
end

function M:UpdateFightSpiritBigSkillEnergy(fill)
	self.bigSkillBtn.energyBg = fill
	self.bigSkillBtn.energyRing = fill
end

function M:SwitchFightSpiritEpFull(playOpenAni, isCDFinished)
	gMainMenuMgr:SetFightSpiritEpFull(true)
	self.bigSkillBtn.iconUltCom:SetActive(true)
	gBattleMgr:SetColorToSImage(self.bigSkillBtn.ultColorCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filled))
	gBattleMgr:SetColorToSImage(self.bigSkillBtn.ultRingCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filled))

	if not isCDFinished then
		return
	end

	if playOpenAni then
		self:PlayBigSkillColorAni()
	else
		self:PlayEndBigSkillColorAni()
	end
end

function M:SwitchFightSpiritEpNoFull()
	gMainMenuMgr:SetFightSpiritEpFull(not self.isUltSkill)
	self.bigSkillBtn.iconUltCom:SetActive(false)
	gBattleMgr:SetColorToSImage(self.bigSkillBtn.ultColorCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filling))
	gBattleMgr:SetColorToSImage(self.bigSkillBtn.ultRingCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filling))
	self:CloseBigSkillColorAni()

	if not gBattleMgr:UsePCBattleHUD() and self.bigSkillBtn.bigSkillLoopAni then
		self.bigSkillBtn.bigSkillLoopAni.gameObject:SetActive(false)
	end
end

function M:UpdateFightEp(templateId, currentEp, maxEp)
	local fillValue = currentEp / (self.energyDotActive and 100 or maxEp)
	local index = 1
	local skillId = gCS.BattleManager.GetUniqueSkillId(gCS.MyPlayerManager.PlayerUnit.Pid)
	local canUseBigSkill = gBattleMgr:CheckCanShowUniqueSkillInfo(skillId)
	local isFull = gBattleMgr:IsSkillFightResourceEnough(gCS.MyPlayerManager.PlayerUnit, skillId)

	if isFull then
		fillValue = 1
	end

	if not canUseBigSkill then
		fillValue = 0
	end

	self:UpdateFightSpiritBigSkillEnergy(fillValue)
	self:RefreshExecutionEnergyList(currentEp, maxEp)

	if fillValue >= 1 and not self.aniControlDazhaos[index] then
		local isCDFinished = gCS.BattleManager.IsCDFinished(skillId)
		self.aniControlDazhaos[index] = isCDFinished

		if canUseBigSkill then
			self:SwitchFightSpiritEpFull(true, isCDFinished)
		end
	elseif fillValue < 1 and self.aniControlDazhaos[index] then
		self.aniControlDazhaos[index] = false

		self:SwitchFightSpiritEpNoFull()
	end
end

function M:EnableEnergyDotRoot(enable)
	if not self.energyDot or self.energyDotActive == enable then
		return
	end

	self.energyDotActive = false

	self:RefreshEnergyDotActive()
end

function M:RefreshEnergyDotActive()
	local enable = self.energyDotActive and gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.UltDot)

	self.bigSkillBtn.energyDot:SetActiveFastest(enable)
end

function M:RefreshExecutionEnergyList(curValue, maxValue)
	if not self.energyDotActive then
		return
	end

	local showNum = math.floor(curValue / 100)
	self.energyDot.colorCtrl = showNum
end

function M:UpdateHeavyAttackBtn()
	local templateId = 0
	local skillId = gBattleMgr:GetHeavyAttackSkillId()
	local skillType = gBattleMgr.SkillBtnType.HeavyAttack
	local cfgSkill = SkillConfig.GetConfig(skillId)
	local cfgImageId = gBattleMgr:GetHeavyAttackImg(cfgSkill)

	if gCoreHudTipManager.isEnable then
		gCoreHudTipManager:UpdateBtnIconState(skillType, gCoreHudTipManager.conditionType.Default, cfgImageId)
	else
		self:SetBtnIcon(self.goSkills[skillType], cfgImageId)
	end

	gBattleMgr:SetSkillData(skillType, skillId, cfgImageId, false)
	gBattleMgr:SetComboSkill(skillType, templateId, skillId)
	gMainMenuMgr:ForbidSkillBtnByNoSkillId(gBattleMgr.SkillBtnType.HeavyAttack, skillId == 0)
end

function M:UpdateBtnSpriteInAir(isInAir, force)
	local canSwing = gMainMenuMgr.airDashVisiable[2] == 1 and gMainMenuMgr.airDashVisiable[3] == 1
	local isInFeisuo = gPlayerManager.main.bindData.isInFeisuo
	local canCurFeisuoShow = not gFeisuoUIUpdateMgr.HideUI or gGadgetManager.FeiSuoTarget and not gCoreHudUIManager.dodgeState.isGuideOpen

	if gCS.MyPlayerManager.PlayerUnit then
		canCurFeisuoShow = canCurFeisuoShow and gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.BuffConfig.CanFeiSuo)
	end

	local jumpSpriteName = isInAir and canSwing and not isInFeisuo and canCurFeisuoShow and gCoreHudImgManager.imgSwingInAirId or gCoreHudImgManager.imgJumpOnGroundId

	self:UpdateDodgeBtnSprite()

	if self.jumpSpriteName ~= jumpSpriteName then
		self:SetBtnIcon(self.jumpSwingBtn, jumpSpriteName)

		self.jumpSpriteName = jumpSpriteName
	end

	local newShowSwingJoystick = jumpSpriteName == gCoreHudImgManager.imgSwingInAirId and self.needShowSwingJoyStick

	if self.isShowSwingJoyStick ~= newShowSwingJoystick then
		self:SetShowJumpSwingJoystick(newShowSwingJoystick)
	end

	if self.isInAir ~= isInAir or force then
		self:UpdateNormalSkillImage()
		gMainMenuMgr:SetAirDashVisiable(isInAir)

		self.isInAir = isInAir
	end
end

function M:UpdateDodgeBtnSprite()
	local dodgeSpriteName = nil

	if self.isInWingFly then
		dodgeSpriteName = gCoreHudImgManager.imgWingSuitRushId
	elseif gCoreHudUIManager.isOnTaffyMoto then
		dodgeSpriteName = gCoreHudImgManager.imgTafeiRushId
	else
		dodgeSpriteName = gCoreHudImgManager.imgDodgeOnGroundId
	end

	if self.dodgeSpriteName ~= dodgeSpriteName then
		self:SetBtnIcon(self.dodgeBtn, dodgeSpriteName)

		self.dodgeSpriteName = dodgeSpriteName
	end
end

function M:UpdateBtnSpriteDive(eventId, isInDive)
	if self.isInDive == isInDive then
		return
	end

	self.isInDive = isInDive

	if self.isInDive == true then
		self:SetBtnIcon(self.jumpSwingBtn, gCoreHudImgManager.imgUpDiveId)
	else
		self:SetBtnIcon(self.jumpSwingBtn, gCoreHudImgManager.imgJumpOnGroundId)
	end
end

function M:UpdateSkillCD(eventId, skillId)
	for i = gBattleMgr.SkillBtnType.Normal, gBattleMgr.SkillBtnType.HeavyAttack do
		local skillData = gBattleMgr.skillData[i]

		if skillData and skillData.skillId ~= 0 and gBattleMgr:IsBtnContainSkillId(skillData.skillId, skillId) then
			self.isUpdateSkillBtns[i] = true
		end
	end

	local fightList = gBattleSpiritMgr:GetBattleSpiritList()

	if fightList then
		for i, spiritData in pairs(fightList) do
			local uniqueSkill = gCS.BattleManager.GetUniqueSkillId(spiritData.pid)

			if uniqueSkill == skillId then
				self.isUpdateSpirit = true
			end
		end
	end
end

function M:UpdateUltCdAndEp(eventId, data)
	if gCS.MyPlayerManager.PlayerUnit.ClientData.cardId == 15022030 or not data or not data.skillId or not data.curValue or not data.maxValue then
		return
	end

	self:UpdateSkillCD(_, data.skillId)
	self:UpdateFightEp(gBattleSpiritMgr.currentSpiritTemplateId, data.curValue, data.maxValue)
end

function M:UpdateSkillBtns()
	for i = 1, #self.goSkills do
		if self.isUpdateSkillBtns[i] then
			self:UpdateSkill(i)
		end
	end
end

function M:UpdateSkill(index)
	if index == gBattleMgr.SkillBtnType.Normal then
		return
	end

	if self:CheckUpdateChangeSkillCountDownTime(index) then
		return
	end

	self.isUpdateSkillBtns[index] = false
	local cdData = gBattleMgr.skillData[index]
	local comboData = gBattleMgr.comboSkillData[index]

	if not cdData or not comboData then
		return
	end

	local objs = self.goSkills[index]
	local calCDSkillId = gBattleMgr:GetShareCDSkillId(cdData.skillId)
	local fillAmount, labelTimeLeft, isHide, curCharges, maxCharges = gBattleMgr:CalculateSkillCDResult(calCDSkillId)
	local isShowCD = not isHide and labelTimeLeft > 0

	self:UpdateSkill_MultiUseSkill(index, objs, comboData, isShowCD, maxCharges, curCharges, fillAmount, labelTimeLeft)

	if maxCharges <= 1 then
		if comboData.check then
			self:UpdateSkill_MultiPhase(index, objs, cdData, comboData)
		else
			self:UpdateSkill_Normal(index, objs, cdData, isShowCD, fillAmount, labelTimeLeft)
		end
	end
end

function M:UpdateSkill_MultiUseSkill(index, objs, comboData, isShowCD, maxCharges, curCharges, fillAmount, labelTimeLeft)
	if maxCharges > 1 then
		objs.skillTypeCtrl = 2
		local cdActive = isShowCD

		if cdActive then
			if curCharges == 0 then
				self:SetBtnInCd(index, objs, 1)

				objs.multiChrageCDCtrl = 0
				objs.cdTime = labelTimeLeft >= 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
				objs.cdCover = gBattleMgr.useV1hud and gCS.LuaUtils.IsNonMobileAdaptive() and fillAmount or 1 - fillAmount
			else
				self:SetBtnInCd(index, objs, 0)

				objs.multiChrageCDCtrl = 2
				objs.multiChargeCounts = curCharges
				objs.multiChargeCd = 1 - fillAmount
			end
		else
			self:SetBtnInCd(index, objs, 0)

			objs.multiChrageCDCtrl = 1
			objs.multiChargeCounts = curCharges
			objs.multiChargeReaCounts = curCharges
			objs.multiChargeCd = 1 - fillAmount
		end
	else
		local baseActive = not comboData.check and isShowCD
		objs.skillTypeCtrl = 0

		self:SetBtnInCd(index, objs, baseActive and 1 or 0)
	end

	self.isUpdateSkillBtns[index] = isShowCD

	gMainMenuMgr:SetBattleSkillBtnIsInCd(index, objs.btnInCDCtrl == 1)
end

function M:UpdateSkill_MultiPhase(index, objs, cdData, comboData)
	objs.skillTypeCtrl = 1

	if not cdData.isUseLianzhaoIamge then
		cdData.isUseLianzhaoIamge = true

		if gCoreHudTipManager.isEnable then
			gCoreHudTipManager:UpdateBtnIconState(index, gCoreHudTipManager.conditionType.MultiPhase, comboData.shortImageId)
		else
			self:SetBtnIcon(objs, comboData.shortImageId)
		end
	end

	if gLogicTime.time < comboData.t3 then
		local fill = (comboData.t3 - gLogicTime.time) / (comboData.t3 - comboData.t0)
		objs.multiPhaseRing = fill
	end

	self.isUpdateSkillBtns[index] = true
end

function M:UpdateSkill_Normal(index, objs, cdData, isShowCD, fillAmount, labelTimeLeft)
	objs.skillTypeCtrl = 0

	if cdData.isUseLianzhaoIamge then
		cdData.isUseLianzhaoIamge = false

		if gCoreHudTipManager.isEnable then
			gCoreHudTipManager:UpdateBtnIconState(index, gCoreHudTipManager.conditionType.MultiPhase, cdData.normalImage)
		else
			self:SetBtnIcon(objs, cdData.normalImage)
		end
	end

	if isShowCD then
		objs.cdCover = gBattleMgr.useV1hud and gCS.LuaUtils.IsNonMobileAdaptive() and fillAmount or 1 - fillAmount
		objs.cdTime = labelTimeLeft >= 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
		self.isUpdateSkillBtns[index] = true
		self.isWaitforTweens[index] = true
	elseif self.isWaitforTweens[index] then
		self.isWaitforTweens[index] = false

		if index == gBattleMgr.SkillBtnType.FightSpiritBigSkill then
			local fightSpiritIndex = 1
			local skillId = gCS.BattleManager.GetUniqueSkillId()

			if gBattleMgr:IsSkillFightResourceEnough(gCS.MyPlayerManager.PlayerUnit, skillId) then
				self.aniControlDazhaos[fightSpiritIndex] = true

				self:PlayBigSkillColorAni()
			end
		elseif index ~= gBattleMgr.SkillBtnType.ControlPower then
			self:PlaySkillXuliAni(objs, index)

			if gBattleMgr:CheckBtnIsShow(objs.btnHideCtrl) then
				gSoundMgr:PlaySoundByTid(70601150)
			end
		end
	end
end

function M:OpenChangeSkillCountDown(btnIndex, time)
	local data = {
		startTime = gLogicTime.time,
		duration = time
	}
	self.changeSkillCountDownData[btnIndex] = data
	self.isUpdateSkillBtns[btnIndex] = true
end

function M:CloseChangeSkillCountDown(btnIndex)
	local obj = self.goSkills[btnIndex]
	obj.skillTypeCtrl = 0
	self.changeSkillCountDownData[btnIndex] = nil
	self.isUpdateSkillBtns[btnIndex] = true
end

function M:CheckUpdateChangeSkillCountDownTime(index)
	local data = self.changeSkillCountDownData[index]

	if self.changeSkillCountDownData[index] then
		local endTime = data.startTime + data.duration
		local obj = self.goSkills[index]

		if gLogicTime.time < endTime then
			obj.skillTypeCtrl = 1
			obj.multiPhaseRing = (endTime - gLogicTime.time) / data.duration
			self.isUpdateSkillBtns[index] = true
		else
			obj.skillTypeCtrl = 0
		end

		return true
	end

	return false
end

function M:UpdateBtn_MultiUseBtn(btn, isShowCD, curCharges, maxCharges, fillAmount, labelTimeLeft)
	if maxCharges > 1 then
		btn.skillTypeCtrl = 2
		local cdActive = isShowCD

		if cdActive then
			if curCharges == 0 then
				self:SetBtnInCd(0, btn, 1)

				btn.multiChrageCDCtrl = 0
				btn.cdTime = labelTimeLeft >= 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
				btn.cdCover = gBattleMgr.useV1hud and gCS.LuaUtils.IsNonMobileAdaptive() and fillAmount or 1 - fillAmount
			else
				self:SetBtnInCd(0, btn, 0)

				btn.multiChrageCDCtrl = 2
				btn.multiChargeCounts = curCharges
				btn.multiChargeCd = 1 - fillAmount
			end
		else
			self:SetBtnInCd(0, btn, 0)

			btn.multiChrageCDCtrl = 1
			btn.multiChargeCounts = curCharges
			btn.multiChargeReaCounts = curCharges
			btn.multiChargeCd = 1 - fillAmount
		end
	else
		btn.skillTypeCtrl = 0

		self:SetBtnInCd(0, btn, isShowCD and 1 or 0)

		btn.cdTime = labelTimeLeft >= 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
		btn.cdCover = gBattleMgr.useV1hud and gCS.LuaUtils.IsNonMobileAdaptive() and fillAmount or 1 - fillAmount
	end
end

function M:SystemUnlockStateChange(eventId, data)
	local isUnlock = gSystemUnlockMgr:IsUnlock(data)

	if SystemUnlockConfig.TaFeiBattleUnlock == data then
		gMainMenuMgr:ShowSkillBtn(isUnlock)
	elseif SystemUnlockConfig.Jump == data then
		gMainMenuMgr:ShowJumpBtnBySystemUnlock(isUnlock)
	elseif SystemUnlockConfig.Drop == data then
		gMainMenuMgr:SetWallJumpStateBySystemUnlock(isUnlock)
	elseif SystemUnlockConfig.WeaponWheel == data then
		gMainMenuMgr:SetAmmunitionStateBySystemUnlock(isUnlock)
	elseif SystemUnlockConfig.AirCrush == data then
		gMainMenuMgr:SetAirdashStateBySystemUnlock(isUnlock)
	elseif SystemUnlockConfig.UltDot == data then
		self:RefreshEnergyDotActive()
	elseif SystemUnlockConfig.CharEnergyBar == data then
		gMainMenuMgr:SetWeaponFightResBySystemUnlock(isUnlock)
	end
end

function M:OnRefreshFeiSuo()
	return
end

function M:OnWeaponChange(eventId, data)
	if ulong.equals(data.pid, gCS.MyPlayerManager.PlayerUnitId) then
		self:UpdateByWeaponRefresh()
	end
end

function M:RefreshBtnTipStatus()
	gCoreHudTipManager:UpdateBtnTipAllWeaponState()

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not self.characterControlData.holdLeftBtn or not self.characterControlData.holdEBtn or not self.characterControlData.holdRBtn then
		return
	end

	local holdLeftVisible = false
	local holdEVisible = false
	local holdRVisible = false
	local fightStyleId = gCS.FightStyleManager.Instance:GetCurrentWeaponFightStyleId()

	if fightStyleId then
		local fightSkillConfig = LTConfig.FightSkillConfig.GetConfig(fightStyleId)

		if fightSkillConfig then
			local pressinSkilltype = fightSkillConfig.PressinSkilltype

			for i = 1, #pressinSkilltype do
				local value = pressinSkilltype[i]

				if value == LTConfig.FightSkillConfig.PressinSkilltypeType.CommonAttack then
					holdLeftVisible = true
				elseif value == LTConfig.FightSkillConfig.PressinSkilltypeType.Active then
					holdEVisible = true
				elseif value == LTConfig.FightSkillConfig.PressinSkilltypeType.Unique then
					holdRVisible = true
				end
			end
		end
	end

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Hold_E, "isWeaponHasSkill", holdEVisible)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Hold_R, "isWeaponHasSkill", holdRVisible)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Hold_Left, "isWeaponHasSkill", holdLeftVisible)
end

function M:OnDragBtnDraging(eventPointer)
	if not eventPointer.delta then
		return
	end

	self:OnDragButton(eventPointer.delta)
end

function M:OnDragButton(delta)
	local camRotateX = GameConfig.FreeLookRotateXDefaultSensitivity
	local camRotateY = GameConfig.FreeLookRotateYDefaultSensitivity
	local deltaX = delta.x * (1 + (camRotateX - 1) / 8 * 6) * 0.5
	local deltaY = delta.y * (1 + (camRotateY - 1) / 8 * 6) * 0.5
	local minDeltaInput = GameConfig.SwingJoystickMinInput

	if Mathf.Abs(deltaX) < minDeltaInput.X then
		deltaX = 0
	end

	if Mathf.Abs(deltaY) < minDeltaInput.Y then
		deltaY = 0
	end

	if deltaX ~= 0 or deltaY ~= 0 then
		local dir = Vector2.New(deltaX, deltaY)

		gCS.CameraDataMgr.cameraControllerManager:OnControlCameraAngle(dir)
	end
end

function M:EnableSeeMobileButton(eventId, message)
	self.seeMobileBtn.wordsCtrl = 1

	gBattleMgr:SetBtnFaraway(self.characterControlData.seeMobileBtn, message)

	self.seeMobileBtn.ignoreLayout = not message
end

function M:SeeMobileButtonClick()
	local item = gCS.MindPowerMgr:GetAimItem()

	if item then
		item:TryEnterLookAtMobileFromMagnet()
	end
end

function M:OnWalkBtnClick()
	if gUIUtils:IsInXinShouRaid() then
		return
	end

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.MotionFlagManager.ToggleIsOnWaling(gCS.MyPlayerManager.PlayerUnit)
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.WalkPress)
	end
end

function M:OnControllerWeaponSwitchCircleBegin()
	if not gMainMenuMgr:CheckCanUseWeaponCircle() then
		return
	end

	self.weaponSliderTime = Time.time
end

function M:OnWeaponCircleLongPressStart()
	if not gMainMenuMgr:CheckCanUseWeaponCircle() then
		return
	end

	gMainMenuMgr:ClickWeaponCircle(true)
	gStoreManager:GetStoreGroup("CoreHudCircleStore"):OpenWeaponCircle()
end

function M:OnWeaponCircleLongPressEnd()
	gMainMenuMgr:ClickWeaponCircle(false)
	gStoreManager:GetStoreGroup("CoreHudCircleStore"):CloseCircle()
	self:ResetWeaponCircleControlSlider()
end

function M:UpdateWeaponCircleControlSlider()
	if self.curActiveDevice <= SGUI.GameDevice.KeyboardMouse or not self.ammunitionRoot or not self.ammunitionRoot.controlerSlider or not self.weaponSliderTime then
		return
	end

	local fill = Time.time - self.weaponSliderTime
	fill = fill * 5
	self.ammunitionRoot.controlerSlider.fill.fillAmount = fill
end

function M:ResetWeaponCircleControlSlider()
	if self.curActiveDevice <= SGUI.GameDevice.KeyboardMouse or not self.ammunitionRoot or not self.ammunitionRoot.controlerSlider then
		return
	end

	self.weaponSliderTime = nil
	self.ammunitionRoot.controlerSlider.fill.fillAmount = 0
end

function M:OnWeaponBtnDragBegin(eventPointer)
	gStoreManager:GetStoreGroup("CoreHudCircleStore"):OnDragMoveStart(eventPointer)
end

function M:OnWeaponBtnDrag(eventPointer)
	gStoreManager:GetStoreGroup("CoreHudCircleStore"):OnDragMove(eventPointer)
end

function M:OnWeaponBtnDragEnd(eventPointer)
	gStoreManager:GetStoreGroup("CoreHudCircleStore"):OnDragMoveEnd(eventPointer)
end

function M:OnControllerWeaponSwitch()
	if not gMainMenuMgr:CheckCanUseWeaponCircle() then
		return
	end

	if self.rollerSwitchWeaponCd < gLogicTime.time then
		self.rollerSwitchWeaponCd = gLogicTime.time + WeaponConfig.WeaponMouseScrollCD

		self:PlayWeaponMouseScrollAni(false)

		local isSame, nextWeaponIndex = self:GetNextCircleWeapon(true)

		if not isSame then
			self:AskSwitchWeapon(nextWeaponIndex)
			gMainMenuMgr:ClickWeaponCircle(true)
			gMainMenuMgr:ClickWeaponCircle(false)
		end
	end
end

function M:OnWeaponMouseScroll(context)
	if not gMainMenuMgr:CheckCanUseWeaponCircle() or not self.characterControlData.ammunitionRoot.interactable then
		return
	end

	if context.performed then
		local zoom = context:ReadValueVector2().y

		self:PlayWeaponMouseScrollAni(zoom > 0)

		if self.rollerSwitchWeaponCd < gLogicTime.time then
			self.rollerSwitchWeaponCd = gLogicTime.time + WeaponConfig.WeaponMouseScrollCD
			local isSame, nextWeaponIndex = self:GetNextCircleWeapon(zoom < 0)

			if not isSame then
				self:AskSwitchWeapon(nextWeaponIndex)
				gMainMenuMgr:ClickWeaponCircle(true)
				gMainMenuMgr:ClickWeaponCircle(false)
			end
		end
	end
end

function M:PlayWeaponMouseScrollAni(isUp)
	local suffix = gCS.LuaUtils.IsNonMobileAdaptive() and "_pc" or ""
	self.changeWeaponMode = isUp and ChangeWeaponMode.Up or ChangeWeaponMode.Down

	gSoundMgr:PlaySoundByTid(70650127)

	if isUp then
		local name = "S_Weapon_up" .. suffix

		gBattleMgr:CommonPlayAniTool(self.ammunitionRoot.scrollAni, name, 0, 1, true, function ()
			self.ammunitionRoot.weaponIconDown = self.ammunitionRoot.weaponIcon
			self.changeWeaponMode = ChangeWeaponMode.None
		end)
	else
		local name = "S_Weapon_down" .. suffix

		gBattleMgr:CommonPlayAniTool(self.ammunitionRoot.scrollAni, name, 0, 1, true, function ()
			self.ammunitionRoot.weaponIcon = self.ammunitionRoot.weaponIconDown
			self.changeWeaponMode = ChangeWeaponMode.None
		end)
	end
end

function M:GetNextCircleWeapon(isNext)
	local offset = isNext and 1 or -1
	local startIdx = 0
	local endIdx = 16
	local nowWeaponIndex = 2 - offset
	local weapons = gWeaponManager:GetCurrentWeapons()

	if not weapons then
		print_warn("GetNextCircleWeapon weapon List is nil")

		return
	end

	for i = startIdx, endIdx do
		local detail = weapons[i]

		if detail and gPlayerManager.infoSpirit.bindData.currentWeapon and detail.InstanceId == gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId then
			nowWeaponIndex = i
		end
	end

	local cnt = 0
	local nextIndex = nowWeaponIndex + offset

	while nextIndex ~= nowWeaponIndex and cnt < endIdx do
		cnt = cnt + 1
		local detail = weapons[nextIndex]

		if detail then
			break
		end

		nextIndex = nextIndex + offset

		if isNext then
			if endIdx < nextIndex then
				nextIndex = startIdx
			end
		elseif nextIndex < startIdx then
			nextIndex = endIdx
		end
	end

	return nowWeaponIndex == nextIndex, nextIndex - 1
end

function M:AskSwitchWeapon(index)
	gClientToGameSceneDelegate:AskSwitchWeapon(index)
end

function M:OnOutOfRidingBtnClick()
	return
end

function M:OnKickOffBtnDown()
	self:PlaySkillBtnDownFanseAni(self.kickOffBtn)
	self:OnMergeBtnLongPressBegin(gBattleMgr.SkillBtnType.ControlPower)
end

function M:OnKickOffBtnUp()
	self:PlaySkillBtnUpFanseAni(self.kickOffBtn)
	self:OnMergeBtnLongPressEnd(gBattleMgr.SkillBtnType.ControlPower)
end

function M:OnSpiderBotExitBtnLongPressBegin()
	self:PlaySkillBtnDownFanseAni(self.spiderBotExitBtn)
end

function M:OnSpiderBotExitBtnLongPress()
	gClientToGameSceneDelegate:AskStopControlAgent(true)
end

function M:OnSpiderBotExitBtnLongPressEnd()
	self:PlaySkillBtnUpFanseAni(self.spiderBotExitBtn)
end

function M:OnProfessionSkillBtnDown()
	self:PlaySkillBtnDownFanseAni(self.professionSkillBtn)
	gBattleMgr:ClickProfessionSkill()
end

function M:OnProfessionSkillBtnUp()
	self:PlaySkillBtnUpFanseAni(self.professionSkillBtn)
end

function M:RefreshProfessionSkillBtnCD()
	if not self.needUpdateProfessionSkillBtnCD or self.professionSkillBtn.btnHideCtrl and self.professionSkillBtn.btnHideCtrl == 1 then
		return
	end

	local isShowCD = self.professionSkillBtnTimes < self.maxProfessionSkillBtnTimes

	self:EnableProfessionSkillBtn(self.professionSkillBtnTimes >= 1)

	local curCharge = math.floor(self.professionSkillBtnTimes)
	local cfg = LTConfig.SkillResourcesConfig.GetConfig(LTConfig.SkillResourcesConfig.DriveTimeScaleEnergy)
	local fill = 1 - self.professionSkillBtnTimes % 1
	local labelTimeLeft = fill * cfg.Interval

	self:UpdateBtn_MultiUseBtn(self.professionSkillBtn, isShowCD, curCharge, self.maxProfessionSkillBtnTimes, fill, labelTimeLeft)

	if self.professionSkillBtnTimes == self.maxProfessionSkillBtnTimes then
		self.needUpdateProfessionSkillBtnCD = false
	end
end

function M:EnableProfessionSkillBtn(enable)
	if self.professionSkillBtn.interactable ~= enable then
		self.professionSkillBtn.interactable = enable

		gBattleMgr:PlayBtnFanseAni(self.professionSkillBtn, nil, enable)
	end
end

function M:OnHandBagPutDownBtnDown()
	self:PlaySkillBtnDownFanseAni(self.handBagPutDownBtn)
	gCS.MindPowerMgr:TryThrowEarPhone()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.Land)
end

function M:OnHandBagPutDownBtnUp()
	self:PlaySkillBtnUpFanseAni(self.handBagPutDownBtn)
end

function M:OnGrappleSpaceBtnDown()
	self:PlaySkillBtnDownFanseAni(self.grappleSpaceBtn)
	print_warn("OnGrappleSpaceBtnDown")
	gGadgetManager:OnTrySpaceThrow()
end

function M:OnGrappleSpaceBtnUp()
	self:PlaySkillBtnUpFanseAni(self.grappleSpaceBtn)
end

function M:OnControllerL3Down()
	if gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.OpenPhone) or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.Dodge][2] then
		return
	end

	gCS.LuaUtils.SetInRushMode(gCS.MyPlayerManager.PlayerUnit, true)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashPress)
end

function M:OnControllerL3Up()
	gCS.LuaUtils.SetInRushMode(gCS.MyPlayerManager.PlayerUnit, false)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashRelease)
end

function M:OnControllerGunNorthBeginLongPress()
	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.FightSpiritBigSkill, true)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.FightSpiritBigSkill) then
		return
	end

	self:PlaySkillBtnDownFanseAni(self.goSkills[gBattleMgr.SkillBtnType.FightSpiritBigSkill])

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.FightSpiritBigSkill)
end

function M:OnControllerGunNorthLongPress()
	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.Basic) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.Basic)
end

function M:OnControllerGunNorthLongPressEnd()
	self:OnMergeBtnLongPressEnd(gBattleMgr.SkillBtnType.Basic)
	self:OnMergeBtnLongPressEnd(gBattleMgr.SkillBtnType.FightSpiritBigSkill)
end

function M:OnControllerGunWestBeginLongPress()
	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.Basic, true)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.Basic) then
		return
	end

	self:PlaySkillBtnDownFanseAni(self.goSkills[gBattleMgr.SkillBtnType.Basic])

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Basic] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Basic)
end

function M:OnControllerGunWestLongPress()
	return
end

function M:OnControllerGunWestLongPressEnd()
	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.Basic, false)

	if not self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Basic] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Basic] = false

	self:PlaySkillBtnUpFanseAni(self.goSkills[gBattleMgr.SkillBtnType.Basic], gBattleMgr.SkillBtnType.Basic)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.Basic) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Basic)
end

function M:OnControllerShootBeginLongPress()
	if gCS.LuaUtils.CanSwing() then
		gCS.TransitionMgr.isPressingSwingDown = true
	end

	if not gCoreHudUIManager.isHoldRangedWeapon or self.normalSkillBtn and not self.normalSkillBtn.interactable then
		return
	end

	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.Normal, true)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.Normal) then
		return
	end

	self:PlaySkillBtnDownFanseAni(self.goSkills[gBattleMgr.SkillBtnType.Normal])

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Normal] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
end

function M:OnControllerShootLongPress()
	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.Normal) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.Normal)
end

function M:OnControllerShootLongPressEnd()
	if gCS.LuaUtils.CanSwing() then
		gCS.TransitionMgr.isPressingSwingDown = false
	end

	if not gCoreHudUIManager.isHoldRangedWeapon then
		return
	end

	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.Normal, false)

	if not self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Normal] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Normal] = false

	self:PlaySkillBtnUpFanseAni(self.goSkills[gBattleMgr.SkillBtnType.Normal], gBattleMgr.SkillBtnType.Normal)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.Normal) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Normal)
end

function M:OnSwitchToAndriodsBtnClick()
	if gBattleMgr.SummonAgentId and ulong.Greater(gBattleMgr.SummonAgentId, 0) and self.switchControlEnable then
		gClientToGameSceneDelegate:AskControlAgent(gBattleMgr.SummonAgentId, UX.Game.SwitchControlReason.Client)
	end
end

function M:RefreshSwitchToAndriodsBtnState()
	self.bindData.switchToAndriodsBtn:SetWidgetFaraway(ulong.LessEqual(gBattleMgr.SummonAgentId, 0))
end

function M:OnControllerAimBeginLongPress()
	if not gCoreHudUIManager.isHoldRangedWeapon or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.HeavyAttack, true)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.HeavyAttack)
end

function M:OnControllerAimLongPress()
	if not gCoreHudUIManager.isHoldRangedWeapon or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.HeavyAttack)
end

function M:OnControllerAimLongPressEnd()
	if not gCoreHudUIManager.isHoldRangedWeapon or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.HeavyAttack, false)

	if not self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] = false

	self:PlaySkillBtnUpFanseAni(self.goSkills[gBattleMgr.SkillBtnType.HeavyAttack], gBattleMgr.SkillBtnType.HeavyAttack)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.HeavyAttack)
end

function M:OnControllerBlockBeginLongPress()
	if gCoreHudUIManager.isHoldRangedWeapon or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.HeavyAttack, true)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.HeavyAttack)
end

function M:OnControllerBlockLongPress()
	if gCoreHudUIManager.isHoldRangedWeapon or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.HeavyAttack)
end

function M:OnControllerBlockLongPressEnd()
	if gCoreHudUIManager.isHoldRangedWeapon or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	gMainMenuMgr:ClickSkillBtn(gBattleMgr.SkillBtnType.HeavyAttack, false)

	if not self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] = false

	self:PlaySkillBtnUpFanseAni(self.goSkills[gBattleMgr.SkillBtnType.HeavyAttack], gBattleMgr.SkillBtnType.HeavyAttack)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.HeavyAttack)
end

function M:SetBtnIcon(btn, iconId)
	btn:Commit("btnIcon", iconId, COMMIT_FORCE)
	btn:Commit("xuliIcon", iconId, COMMIT_FORCE)
	btn:Commit("btnIconvx", iconId, COMMIT_FORCE)
	btn:Commit("iconUlt", iconId, COMMIT_FORCE)
end

function M:OnMindAimItemChange(eventId)
	local cfgId = 0
	local item = gCS.MindPowerMgr:GetAimItem()

	if not item then
		self:SetMindBtnPCKeyId(0)
	elseif item.ItemType == MindPowerConst.MindObjType.Enemy then
		local mindInteractCfgId = gCS.MindPowerMgr:GetBattleMindPowerInteractConfig()
		local mindInteractCfg = battleMindPowerInteractConfig.GetConfig(mindInteractCfgId)

		if mindInteractCfg then
			self:SetMindBtnPCKeyId(mindInteractCfg.MindButtonType)

			cfgId = mindInteractCfg.Id
		else
			self:SetMindBtnPCKeyId(0)
		end
	else
		self:SetMindBtnPCKeyId(0)
	end

	self.mindInteractCfgId = cfgId
	local curBackAssassin = self.mindInteractCfgId == battleMindPowerInteractConfig.BackAssassin

	if curBackAssassin ~= gCoreHudUIManager.canBackAssassin then
		gCoreHudUIManager.canBackAssassin = curBackAssassin

		self:UpdateBasicSkills(1)
	end
end

function M:SetMindBtnPCKeyId(id)
	local keyId = 25
	local text = "Q"
	local isExecute = false

	if id == MindButtonTypeType.InteractBtn then
		keyId = 10
		text = "F"
	elseif id == MindButtonTypeType.NormalSkillBtn then
		keyId = 8
		text = ""
	elseif id == MindButtonTypeType.ExecuteBtn then
		isExecute = true
		keyId = 10
		text = "F"
	elseif id == MindButtonTypeType.EBtn then
		keyId = 26
		text = "E"
	elseif id == MindButtonTypeType.MouseRight then
		keyId = 9
		text = ""
	end

	if self.mindPowerKeyId ~= keyId or self.isExecute ~= isExecute then
		self:UpdateKickOffBtn(id)
		gMainMenuMgr:RefreshEnemyMindInteractBtn(id)
		gMainMenuMgr:SetKickOffBtnVisiable(id == MindButtonTypeType.InteractBtn or id == MindButtonTypeType.ExecuteBtn)

		if self.mergeBtnDownCache[gBattleMgr.SkillBtnType.ControlPower] then
			self:OnMergeBtnLongPressEnd(gBattleMgr.SkillBtnType.ControlPower)
		end

		gStoreManager:GetStoreGroup("HintInfosHudStore"):SetClickPCText(text)
		gStoreManager:GetStoreGroup("HintInfosHudStore"):SetMindIcon(id)
		gStoreManager:GetStoreGroup("HintInfosHudStore"):ShowOrHideExecuteHint(isExecute)
	end

	self.isExecute = isExecute
	self.mindBtnType = id
	self.mindPowerKeyId = keyId
end

function M:UpdateKickOffBtn(id)
	local iconId = GameConfig.KickOffBtnIcon

	if id == MindButtonTypeType.ExecuteBtn then
		iconId = GameConfig.ExecuteBtnIcon
	end

	self.kickOffBtn.vxIconId = iconId
	self.kickOffBtn.iconId = iconId
end

function M:CheckNeedPlayFanseAni(btn)
	if not btn.btnInCDCtrl or btn.btnInCDCtrl == 0 then
		return true
	end

	return false
end

function M:PlaySkillBtnDownFanseAni(btn)
	if not self:CheckNeedPlayFanseAni(btn) then
		return
	end

	table.insert(self.btnFanseAniList, btn)

	local aniName = gBattleMgr:UsePCBattleHUD() and self.btnDownFanseAniPc or self.btnDownFanseAni

	gBattleMgr:CommonPlayAniTool(btn.btnFanseAni, aniName, 0, 1)
end

function M:PlaySkillBtnUpFanseAni(btn, index, notPlayAni)
	if notPlayAni then
		return
	end

	index = index or 0

	if table.contains(self.btnFanseAniList, btn) then
		local aniName = gBattleMgr:UsePCBattleHUD() and self.btnUpFanseAniPc or self.btnUpFanseAni

		gBattleMgr:CommonPlayAniTool(btn.btnFanseAni, aniName, 0, 1)
	end

	table.removeEx(self.btnFanseAniList, btn)
end

function M:ClearBtnFanseAni(btn, index)
	if not table.contains(self.btnFanseAniList, btn) then
		return
	end

	table.removeEx(self.btnFanseAniList, btn)

	local aniName = gBattleMgr:UsePCBattleHUD() and self.btnUpFanseAniPc or self.btnUpFanseAni

	gBattleMgr:CommonStopAniTool(btn.btnFanseAni, aniName)
end

function M:ClearAllBtnFanseAni()
	for i = #self.btnFanseAniList, 1, -1 do
		self:ClearBtnFanseAni(self.btnFanseAniList[i], 0)
	end
end

function M:PlaySkillClickAni(index, btn)
	local ani = btn.specialBtnClickAni

	if not ani or index ~= gBattleMgr.SkillBtnType.Basic and index ~= gBattleMgr.SkillBtnType.FightSpiritBigSkill or gBattleMgr:UsePCBattleHUD() then
		return
	end

	local clpName = index == gBattleMgr.SkillBtnType.ControlPower and "s_vx_HudSkillBtn_click02" or "s_vx_HudSkillBtn_click"

	ani.gameObject:SetActive(true)
	gBattleMgr:CommonPlayAniTool(ani, clpName, 0, 1, true)
end

function M:PlaySkillXuliAni(btn, index)
	btn.btnXuliAni.gameObject:SetActive(true)

	self.xuliBtnAniList[index] = true
	local aniName = gBattleMgr:UsePCBattleHUD() and self.xuliCdAniNamePc or "s_vx_HudSkillBtn_xuli_cd"

	gBattleMgr:CommonPlayAniTool(btn.btnXuliAni, aniName, 0, 1, true, function ()
		self.xuliBtnAniList[index] = false
	end)
end

function M:ClearSkillXuliAni(btn, index)
	if not btn.btnXuliAni or self.xuliBtnAniList[index] then
		return
	end

	local aniName = gBattleMgr:UsePCBattleHUD() and self.xuliCdAniNamePc or "s_vx_HudSkillBtn_xuli_cd"

	gBattleMgr:CommonStopAniTool(btn.btnXuliAni, aniName)
end

function M:PlayBigSkillColorAni()
	if gBattleMgr:UsePCBattleHUD() then
		gBattleMgr:CommonPlayAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNamePc, 0, 1)
	else
		gBattleMgr:CommonPlayAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNameM, 0, 1)
	end
end

function M:PlayEndBigSkillColorAni()
	if gBattleMgr:UsePCBattleHUD() then
		gBattleMgr:CommonStopAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNamePc)
	else
		gBattleMgr:CommonStopAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNameM)
	end
end

function M:CloseBigSkillColorAni()
	self:PlayEndBigSkillColorAni()

	if gBattleMgr:UsePCBattleHUD() then
		gBattleMgr:CommonPlayAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillCloseAniNamePc, 0, 1)
	else
		gBattleMgr:CommonPlayAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillCloseAniNameM, 0, 1)
	end
end

function M:CheckSkillBtnIsEnable(data)
	if data == gBattleMgr.SkillBtnType.Basic and not self.goSkills[data].interactable then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮的collider被关闭了" .. data)

		return false
	end

	if data == gBattleMgr.SkillBtnType.ControlPower then
		local mindBtnType = self.mindBtnType

		if mindBtnType ~= 0 then
			if mindBtnType == MindButtonTypeType.NormalSkillBtn then
				if not self.goSkills[gBattleMgr.SkillBtnType.Normal].interactable then
					gBattleMgr:ShowMessageTipsOnEditor("技能按钮的collider被关闭了" .. gBattleMgr.SkillBtnType.Normal)

					return false
				end
			elseif mindBtnType == MindButtonTypeType.InteractBtn or mindBtnType == MindButtonTypeType.ExecuteBtn then
				if self.kickOffBtn.interactable then
					gBattleMgr:ShowMessageTipsOnEditor("技能按钮的collider被关闭了" .. data)

					return false
				end
			elseif not self.goSkills[data].interactable then
				gBattleMgr:ShowMessageTipsOnEditor("技能按钮的collider被关闭了" .. data)

				return false
			end
		elseif not self.goSkills[data].interactable then
			gBattleMgr:ShowMessageTipsOnEditor("技能按钮的collider被关闭了" .. data)

			return false
		end
	end

	return true
end

function M:SetBtnInCd(index, btn, isInCD)
	if btn.btnInCDCtrl ~= isInCD then
		if btn.btnInCDCtrl == 0 then
			-- Nothing
		end

		btn.btnInCDCtrl = isInCD
	end
end

function M:CastSkillAction(eventId, message)
	if not message.isMySkill then
		return
	end

	local skillId = message.skillId
	local btnIndex = message.type

	if skillId == nil or btnIndex == nil or skillId <= 0 or btnIndex <= 0 then
		return
	end

	if gBattleMgr.skillData[btnIndex] and skillId == gBattleMgr.skillData[btnIndex].skillId then
		self:PlaySkillClickAni(btnIndex, self.goSkills[btnIndex])
	end
end

function M:ReplaceDodgeBtnToMindPower()
	if gBattleSwitch.ReplaceDodgeBtnToMindPower then
		self.dodgeBtn.multiBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressBegin", 4)
		self.dodgeBtn.multiBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 4)
		self.dodgeBtn.multiBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 4)
	else
		if self.heavyAttackBtn then
			return
		end

		self.dodgeBtn.multiBtn.luaPress = self:CreateActionWithArgs("OnDodgeBtnPress", 2)
		self.dodgeBtn.multiBtn.luaRelease = self:CreateActionWithArgs("OnDodgeBtnRelease", 2)
		self.dodgeBtn.multiBtn.luaClick = nil
		self.dodgeBtn.multiBtn.luaBeginLongPress = nil
		self.dodgeBtn.multiBtn.luaLongPress = nil
		self.dodgeBtn.multiBtn.luaEndLongPress = nil
	end
end

function M:SetBtnVisible(btnStore, visible)
	self.coreHudPanel:SetButtonVisibleBase(btnStore, visible)
end

function M:SetBtnInteractable(btnStore, interactable)
	self.coreHudPanel:SetButtonInteractableBase(btnStore, interactable)
end

function M:SetBtnControl(btnStore, visible, interactable)
	self.coreHudPanel:SetButtonControlBase(btnStore, visible, interactable)
end

function M:OnRightStickControl(context)
	if self.circleOpen then
		return
	end

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
	if self.needUpdateCamera and not self.circleOpen then
		if not gPanelManager:VisibleModeAll() then
			self:ClearGamepadCameraRotate()

			return
		end

		local cameraConfigId = self:GetCameraConfigId()

		gCameraUtils:DoRotateCameraByGamePad(cameraConfigId, self.rightStickValue.x, self.rightStickValue.y)
	end
end

function M:GetCameraConfigId()
	local showShootCrossHair = false
	showShootCrossHair = gCS.MindPowerMgr.showShootCrossHair

	if gCS.ShootModule.IsInShootMode(gCS.MyPlayerManager.PlayerUnit) and not showShootCrossHair then
		return 2
	elseif showShootCrossHair then
		return 3
	else
		return 1
	end
end

function M:OnCameraResetBtnClick()
	gCS.CameraDataMgr.cinemachineManager:GamePadResetCameraDirAndDis(GameConfig.ResetCameraDirectionAndDistanceBlendTime)
end

function M:SetCircleOpen(open)
	self.circleOpen = open

	if open then
		self:ClearGamepadCameraRotate()
	end
end

function M:ClearGamepadCameraRotate()
	self.needUpdateCamera = false
	self.rightStickValue.x = 0
	self.rightStickValue.y = 0

	gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
end

function M:CheckBtnTips()
	if not gCS.LuaUtils.IsNonMobileAdaptive() or not self.coreHudPanel.bindData.gamePadArea then
		return
	end

	local show = gBattleSpiritMgr.currentSpiritTemplateId == 15022020 and SGUI.GameDevice.KeyboardMouse < self.curActiveDevice

	if self.showNomalAttackTips ~= show then
		self.showNomalAttackTips = show
		local respond = self.normalSkillBtn.multiBtn
		local targetRespond = self.specialBtnRoot.skillBtn

		self.coreHudPanel.bindData.gamePadArea:ChangeButtonTipInfoByActionIdAndRespondType(4, respond, 8, 2, 0, show, true)

		if show then
			self.coreHudPanel.bindData.gamePadArea:ChangeButtonTipInfoByActionIdAndRespondType(7, respond, 8, 2, 0, show, true)
			self.coreHudPanel.bindData.gamePadArea:ChangeRespondByActionIdAndRespondType(7, respond, targetRespond)
		else
			self.coreHudPanel.bindData.gamePadArea:ChangeButtonTipInfoByActionIdAndRespondType(7, targetRespond, 8, 2, 0, show, true)
			self.coreHudPanel.bindData.gamePadArea:ChangeRespondByActionIdAndRespondType(7, targetRespond, respond)
		end
	end
end

function M:ShowAmmunition(visible, interactable)
	self.showAmmunition = visible

	if self.characterControlData and self.characterControlData.ammunitionRoot then
		self.characterControlData.ammunitionRoot.interactable = interactable

		self.characterControlData.ammunitionRoot:SetActiveQuickly(visible)
		self:UpdateSkillGridPos(visible)
	end
end

function M:UpdateSkillGridPos(showWeaponCircle)
	if self.characterControlData.skillBtnGrid then
		local store = self:GetStoreByWidget(self.characterControlData.skillBtnGrid)

		if store then
			store.gridPosCtrl = showWeaponCircle and 0 or 1
		end
	end
end

function M:UpdateAmmunition(cur, single, total, configTotal)
	if not self.STATE_EnableOnce then
		return
	end

	self.ammunitionRoot.curAmmunition = cur
	self.ammunitionRoot.infiniteCurNum = cur

	if total > 0 then
		self.ammunitionRoot.remainAmmunition = math.max(total - cur, 0)
	elseif total < 0 then
		self.ammunitionRoot.remainAmmunition = "-"
	else
		self.ammunitionRoot.remainAmmunition = 0
	end

	self.ammunitionRoot.durabilityPercent = math.floor(total / configTotal * 100)
	self.ammunitionRoot.infiniteCurPercent = math.floor(cur / single * 100) .. "%"
end

function M:RefreshWeaponDurabilityUI(templateId)
	if not self.ammunitionRoot then
		return
	end

	local cfg = WeaponConfig.GetConfig(templateId)

	if cfg then
		if self.changeWeaponMode == ChangeWeaponMode.Up then
			self.ammunitionRoot.weaponIcon = cfg.SWeaponIconId
		elseif self.changeWeaponMode == ChangeWeaponMode.Down then
			self.ammunitionRoot.weaponIconDown = cfg.SWeaponIconId
		else
			self.ammunitionRoot.weaponIcon = cfg.SWeaponIconId
			self.ammunitionRoot.weaponIconDown = cfg.SWeaponIconId
		end
	end

	self.ammunitionRoot.weaponType = self:GetWeaponDurabilityType()
end

function M:GetWeaponDurabilityType()
	local weaponId = gBattleMgr.battleWeaponTemplateId
	local cfg = WeaponConfig.GetConfig(weaponId)

	if cfg then
		local cfgIndex = self.CfgDurabilityMode2Index[cfg.DurabilityUIMode]

		if cfgIndex then
			return cfgIndex
		end

		local totalDurability = cfg.Durability

		if cfg.ShootId > 0 then
			local shootCfg = WeaponShootConfig.GetConfig(cfg.ShootId)

			if shootCfg and shootCfg.BulletNum == totalDurability then
				return WeaponNumType.Percent
			end

			if totalDurability < 0 then
				if shootCfg and shootCfg.BulletNum > 0 then
					return WeaponNumType.InfiniteAmmo
				end

				return WeaponNumType.FreeDurability
			end

			return WeaponNumType.Gun
		end

		if totalDurability < 0 then
			return WeaponNumType.FreeDurability
		end
	end

	return WeaponNumType.Percent
end

function M:CheckShowLeftShootBtn(templateId)
	local isShootWeapon = gCS.GunModule.CheckShowMobileShootBtn()
	local isActive = isShootWeapon and not gCS.LuaUtils.IsNonMobileAdaptive()

	if self.characterControlData then
		gBattleMgr:SetBtnFaraway(self.characterControlData.leftShootBtn, isActive)
	end
end

function M:OnParkourStateChange()
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("CoreHudCharacterControlStore.CheckShowDropDownBtnTips")
	end

	self:CheckShowDropDownBtnTips()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
		gCS.LuaUtils.BeginSample("CoreHudCharacterControlStore.CheckShowHandBagDropBtn")
	end

	gBattleMgr:CheckShowHandBagDropBtn()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
		gCS.LuaUtils.BeginSample("CoreHudCharacterControlStore.CheckShowJobSpecialBtn")
	end

	gBattleMgr:CheckShowJobSpecialBtn()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
		gCS.LuaUtils.BeginSample("CoreHudCharacterControlStore.CheckChangeBtnMode")
	end

	self:CheckChangeBtnMode()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
		gCS.LuaUtils.BeginSample("CoreHudCharacterControlStore.CheckIsClimbRun")
	end

	self:CheckIsClimbRun()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:UpdateNormalSkillImage()
	local cfgImageId = gBattleMgr:GetNormalSkillImg()

	gCoreHudTipManager:UpdateBtnIconState(1, gCoreHudTipManager.conditionType.Default, cfgImageId)
end

function M:OnSkillResourceChanged(eventId, msg)
	local table = msg
	local templateId = table[0]

	if templateId == LTConfig.SkillResourcesConfig.DriveTimeScaleEnergy then
		self.professionSkillBtnTimes = table[1]
		self.maxProfessionSkillBtnTimes = table[2]
		self.needUpdateProfessionSkillBtnCD = true

		self:RefreshProfessionSkillBtnCD()
	end
end

function M:CheckChangeBtnMode()
	self.isHoldBlend = gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.HoldBlend)
	local Emode = not self.isHoldBlend and not self.isBasicNoSkillId
	local Rmode = true

	self:ChangeSpecialBtnMode(Emode)
	self:ChangeUltBtnMode(Rmode)
end

function M:ChangeSpecialBtnMode(battleMode)
	self:ChangeBtnMode(self.specialBtnRoot, 2, battleMode)
end

function M:ChangeUltBtnMode(battleMode)
	self:ChangeBtnMode(self.ultBtnRoot, 3, battleMode)
end

function M:ChangeBtnMode(rootStore, index, battleMode)
	local ctrlValue = battleMode and BtnBattleMode.Battle or BtnBattleMode.Normal

	if rootStore.ctrlMode == ctrlValue then
		return
	end

	rootStore.ctrlMode = ctrlValue

	if battleMode then
		self:UpdateSkill(index)
	else
		self:UpdateNomalBtn(rootStore)
	end
end

function M:UpdateNomalBtn(rootStore)
	local btn = rootStore.normalBtn
end

function M:UpdatePCAndGamepadBtnState(data)
	self:UpdateSkillBtnDataSetState(data)
	self:UpdateControllerBtnState(data)
end

function M:UpdateSkillBtnDataSetState(data)
	if not self.characterControlData or not data or not data.key or not data.value then
		return
	end

	local skillType = data.key
	local state = data.value
	self.goSkills[skillType].ignoreLayout = skillType == gBattleMgr.SkillBtnType.Normal or not state[1]

	if self.skillBtnRootGos[skillType] then
		self.skillBtnRootGos[skillType].ignoreLayout = not state[1]
	end

	if skillType == gBattleMgr.SkillBtnType.ControlPower and gCS.LuaUtils.IsNonMobileAdaptive() then
		self.skillGo[skillType]:SetPCKeyTipShowTip(state[1])

		local coreHud = gStoreManager:GetStoreGroup("CoreHudPanelStore")

		if coreHud and coreHud.bindData.gamePadArea then
			coreHud.bindData.gamePadArea:SetButtonInfoTipShowTip(state[1], 23)
		end
	end

	if not state[1] or not state[2] then
		self:ClearBtnFanseAni(self.goSkills[skillType], skillType)
		self:ClearSkillXuliAni(self.goSkills[skillType], skillType)
	end

	self:SetBtnState(self.goSkills[skillType], state[1], state[2])

	if self.skillNormalBtns and self.skillNormalBtns[skillType] then
		self:SetBtnState(self.skillNormalBtns[skillType], state[1], state[2])
	end

	if self.characterControlData.leftShootBtn and self.leftShootBtn and skillType == gCoreHudUIManager.skillType.Normal then
		self.leftShootBtn.btnHideCtrl = state[1] and 0 or 1
		self.leftShootBtn.interactable = state[2]
	end
end

function M:UpdateSwitchWeaponWheelsState()
	local property = gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.SwitchWeaponWheels]

	self:ShowAmmunition(property[1], property[2])

	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore:ShowAmmunition(property[1], property[2])
	end

	self.characterControlData.ultPosCtrl = property[1] and 0 or 1
end

function M:UpdateBtnHoldState(data)
	local skillType = data.key
	local state = data.value
	local btnGoName = nil

	if skillType == gCoreHudUIManager.skillType.Hold_Left then
		btnGoName = "holdLeftBtn"
	elseif skillType == gCoreHudUIManager.skillType.Hold_E then
		btnGoName = "holdEBtn"
	elseif skillType == gCoreHudUIManager.skillType.Hold_R then
		btnGoName = "holdRBtn"
	end

	if not btnGoName or not self[btnGoName] or not self.characterControlData[btnGoName] then
		return
	end

	self:SetBtnVisible(self[btnGoName], state[1])
	self.characterControlData[btnGoName]:SetActive(state[2])
end

function M:UpdateBtnDataSetState(data)
	local skillType = data.key
	local state = data.value
	local btnStore = nil

	if skillType == gCoreHudUIManager.skillType.Dodge then
		btnStore = self.dodgeBtn
	end

	if not btnStore then
		return
	end

	self:SetBtnState(btnStore, state[1], state[2])
end

function M:UpdateControllerBtnState(data)
	if not self.characterControlData or not data or not data.key or not data.value or self.curActiveDevice < SGUI.GameDevice.PlayStation or self.characterControlData.controllerState ~= 1 then
		return
	end

	local skillType = data.key
	local state = data.value

	if skillType == gBattleMgr.SkillBtnType.FightSpiritBigSkill and self.characterControlData.controllerGunNorth then
		self.characterControlData.controllerGunNorth:SetActive(state[2])
	elseif skillType == gBattleMgr.SkillBtnType.Basic and self.characterControlData.controllerGunWest then
		self.characterControlData.controllerGunWest:SetActive(state[2])
	elseif skillType == gCoreHudUIManager.skillType.HeavyAttack and self.characterControlData.controllerGunAim then
		self.characterControlData.controllerGunAim:SetActive(state[2])
	elseif skillType == gCoreHudUIManager.skillType.Normal and self.characterControlData.controllerShot then
		self.characterControlData.controllerShot:SetActive(state[2])
	end
end

function M:UpdateBtnState(eventId, skillType)
	if not self.characterControlData then
		return
	end

	if skillType == gCoreHudUIManager.skillType.Dodge then
		self:UpdateHUDBtnState(self.dodgeBtn, skillType)
	elseif skillType == gCoreHudUIManager.skillType.JumpJump then
		self:UpdateHUDBtnState(self.jumpSwingBtn, skillType, self.characterControlData.jumpSwingBtn)
	end
end

function M:UpdateHUDBtnState(btnStore, skillType, btnGo)
	if not btnStore then
		return
	end

	local state = gCoreHudUIManager:GetBattleSkillEnable(skillType)

	self:SetBtnState(btnStore, state.visible, state.interactable)

	if btnGo then
		self:UpdateBtnAni(btnGo, nil, state.interactable)
	end
end

function M:UpdateBtnAni(btn, index, active)
	if not active then
		self:ClearBtnFanseAni(btn, index)
		self:ClearSkillXuliAni(btn, index)
	end
end

function M:SetBtnState(btnStore, targetVisible, targetInteractable)
	if targetVisible == nil or targetInteractable == nil or not btnStore then
		return
	end

	local targetHideCtrl = targetVisible and 0 or 1

	if targetHideCtrl ~= btnStore.btnHideCtrl then
		self:SetBtnVisible(btnStore, targetVisible)
	end

	if targetInteractable ~= btnStore.interactable then
		self:SetBtnInteractable(btnStore, targetInteractable)
	end
end

function M:OnBattlePanelBtnEvent(eventId, para)
	local eventIndex = para[1]
	local skillButtonIndex = para[2]

	if eventIndex == gCoreHudUIManager.battlePanelEvent.skillKeyDown then
		self:OnMergeBtnLongPressBegin(skillButtonIndex, true)
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.skillKeyUp then
		self:OnMergeBtnLongPressEnd(skillButtonIndex)
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.skillPressDown then
		self:OnMergeBtnLongPressBegin(skillButtonIndex)
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.skillPress then
		self:OnMergeBtnLongPress(skillButtonIndex)
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.skillPressUp then
		self:OnMergeBtnLongPressEnd(skillButtonIndex)
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.jumpKeyPressDown then
		self:OnJumpSwingBtnLongPressBegin()
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.jumpKeyPress then
		self:OnJumpSwingBtnLongPress()
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.jumpKeyPressUp then
		self:OnJumpSwingBtnLongPressEnd()
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.dodgeKeyDown then
		self:OnDodgeBtnPress()
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.dodgeKeyUp then
		self:OnDodgeBtnRelease()
	elseif eventIndex == gCoreHudUIManager.battlePanelEvent.updateSkillState then
		self.isUpdateSkillBtns[skillButtonIndex] = true
	end
end

function M:OnActiveDeviceChange(device)
	self.curActiveDevice = device

	if SGUI.GameDevice.KeyboardMouse < self.curActiveDevice then
		self:UpdateControllerState()
	end

	gCoreHudUIManager:OnRefreshForAwakeUI()
	self:RefreshDressTab()
end

function M:OnPerfectBlockEvent(eventId, data)
	if not self.heavyAttackBtn or gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if data.type ~= LX6.SlateData.HState.BeCounterType.BlockCounterAttack then
		return
	end

	local isOnPerfectBlock = data.canCounter

	if isOnPerfectBlock == self.canCounter then
		return
	end

	self.canCounter = isOnPerfectBlock

	self.heavyAttackBtn.btnBlockAnim:Stop()

	self.heavyAttackBtn.blockCtrl = isOnPerfectBlock and 1 or 0
	self.characterControlData.blockScaleCtrl = isOnPerfectBlock and 1 or 0
	self.canPerfectBlock = isOnPerfectBlock

	if isOnPerfectBlock then
		self.heavyAttackBtn.btnBlockAnim:Play(self.blockOpenAnim)
		gCoreHudTipManager:UpdateBtnIconState(gBattleMgr.SkillBtnType.HeavyAttack, gCoreHudTipManager.conditionType.Environment, gCoreHudImgManager.imgShootBlockId)
	else
		local skillId = gBattleMgr:GetHeavyAttackSkillId()
		local skillType = gBattleMgr.SkillBtnType.HeavyAttack
		local cfgSkill = SkillConfig.GetConfig(skillId)
		local cfgImageId = gBattleMgr:GetHeavyAttackImg(cfgSkill)

		gCoreHudTipManager:UpdateBtnIconState(skillType, gCoreHudTipManager.conditionType.Environment, 0)
	end
end

function M:OnHeavyAttackBtnLongPressBegin()
	self:OnMergeBtnLongPressBegin(5)

	if self.canPerfectBlock and self.heavyAttackBtn then
		gBattleMgr:CommonPlayAniTool(self.heavyAttackBtn.btnBlockAnim, self.blockCloseAnim, 0, 1, true, function ()
			self.heavyAttackBtn.blockCtrl = 0
		end)

		self.canPerfectBlock = nil
	end
end

function M:OnChangeWeaponType(eventId, isHoldRangedWeapon)
	gCoreHudUIManager.isHoldRangedWeapon = isHoldRangedWeapon

	if SGUI.GameDevice.KeyboardMouse < self.curActiveDevice then
		self:UpdateControllerState()
	end
end

function M:UpdateControllerState()
	if gCoreHudUIManager.isHoldRangedWeapon then
		self.characterControlData:Commit("controllerState", 1, COMMIT_IMMEDIATELY)
	else
		self.characterControlData:Commit("controllerState", 0, COMMIT_IMMEDIATELY)
	end

	for i = 1, 3 do
		local data = {
			key = i,
			value = gCoreHudUIManager.buttonStateMonitor[i]
		}

		self:UpdateControllerBtnState(data)
	end
end

function M:OnControllerSettingChange(eventId, isNewSetting)
	self.bindData.ControllerSettingCtrl = isNewSetting and 0 or 1
end

function M:CheckOxygenShow(eventId, isOpen)
	if isOpen then
		self.isOxygenSystemOn = true
	else
		self.isOxygenSystemOn = false
		self.isOxygenOnShow = false
		self.characterControlData.oxygenTab.selectedIndex = -1
		self.preOxygen = nil
	end
end

function M:UpdateOxygenUI(eventId, oxygenValue)
	if not self.isOxygenSystemOn then
		return
	end

	if not self.isOxygenOnShow then
		self.preOxygen = oxygenValue

		if self.isInDive then
			self.characterControlData.oxygenTab.selectedIndex = 0
			self.isOxygenOnShow = true
		end

		return
	end

	if self.preOxygen and self.preOxygen - oxygenValue >= 5 then
		local oxygenTween = DOTween.To(function ()
			return self.preOxygen / gCoreHudUIManager.O2Max
		end, function (value)
			self.curOxygenTabStore.flashBar.fillAmount = value
		end, oxygenValue / gCoreHudUIManager.O2Max, 0.3):SetEase(Ease.Linear):OnKill(function ()
			self.preOxygen = oxygenValue
			self.oxygenTween = nil
		end)
		self.oxygenTween = oxygenTween
	end

	self.curOxygenTabStore.hpBar.fillAmount = oxygenValue / gCoreHudUIManager.O2Max

	if oxygenValue <= gCoreHudUIManager.O2LowThreshold then
		self.curOxygenTabStore.colorCtrl = 1
	else
		self.curOxygenTabStore.colorCtrl = 0
	end

	gMainMenuMgr:RefreshFullScreenLowHpAni(oxygenValue / gCoreHudUIManager.O2Max, true)

	if oxygenValue == gCoreHudUIManager.O2Max or oxygenValue == 0 then
		self.isOxygenOnShow = false
		self.characterControlData.oxygenTab.selectedIndex = -1
		self.preOxygen = nil
	end

	if not self.isInDive then
		self.preOxygen = oxygenValue
	end
end

function M:OnOxygenRenderTab(index, widget)
	self.curOxygenTabStore = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	self.curOxygenTabStore.hpBar.fillAmount = 1
end

function M:OnHighObstacle(eventId, needShowWallUI)
	self.characterControlData.jumpSwingBtn:SetPCKeyTipShowTip(needShowWallUI)
	self.characterControlData.jumpSwingBtn:SetPCKeyInfoTipNameId(self.climbHighTip)

	if self.coreHudPanel.bindData.gamePadArea then
		self.coreHudPanel.bindData.gamePadArea:SetButtonInfoTipShowTip(needShowWallUI, 1)
		self.coreHudPanel.bindData.gamePadArea:SetButtonInfoTipNameId(self.climbHighTip, 1)
	end
end

function M:SetWingSuitDressed(eventId, isDressed)
	self.isWingSuitDressed = isDressed

	self:RefreshDressTab()
end

function M:RefreshDressTab()
	if not self.characterControlData.costumSkillTab then
		return
	end

	if self.isWingSuitDressed then
		self.characterControlData.costumSkillTab.selectedIndex = 0
	else
		self.characterControlData.costumSkillTab.selectedIndex = -1
	end
end

function M:CheckWeaponDurability(eventId, data)
	local weapon = gPlayerManager.infoSpirit.bindData.currentWeapon

	if not weapon or not data or data and weapon.InstanceId ~= data.weaponId then
		return
	end

	self:SetAmmnitionBrokenState(weapon)

	if data.isToLowLimit then
		local platform = gCS.LuaUtils.IsNonMobileAdaptive() and "_PC" or ""

		gBattleMgr:CommonPlayAniTool(self.ammunitionRoot.scrollAni, "S_CoreHudPanel" .. platform .. "_miss_red01", 0, 1, true)
	elseif data.durability == 0 then
		local platform = gCS.LuaUtils.IsNonMobileAdaptive() and "_PC" or ""

		gBattleMgr:CommonPlayAniTool(self.ammunitionRoot.scrollAni, "S_CoreHudPanel" .. platform .. "_miss_red02", 0, 1, true)
	end
end

function M:OnCurrentWeaponChange(eventId, weaponInfo)
	if not weaponInfo then
		return
	end

	self:SetAmmnitionBrokenState(weaponInfo)
end

function M:SetAmmnitionBrokenState(weaponInfo)
	if not weaponInfo or not weaponInfo.TemplateId or not weaponInfo.Durability then
		return
	end

	local allDurability = WeaponConfig.GetConfig(weaponInfo.TemplateId).Durability

	if allDurability == -1 or not weaponInfo.Durability then
		self.ammunitionRoot.brokenCtrl = self.weaponStateEnum.Fill

		return
	end

	local lowLimit = WeaponConfig.WeaponDurabilityLow * allDurability

	if weaponInfo.Durability == 0 then
		self.ammunitionRoot.brokenCtrl = self.weaponStateEnum.None
	elseif weaponInfo.Durability <= lowLimit then
		self.ammunitionRoot.brokenCtrl = self.weaponStateEnum.Broken
	else
		self.ammunitionRoot.brokenCtrl = self.weaponStateEnum.Fill
	end
end

function M:OnParkourAddRemove(eventId, data)
	if not data then
		return
	end

	if data.parkourStateId == ParkourStateConfig.WingsuitFly01 or data.parkourStateId == ParkourStateConfig.WingsuitFly then
		self.isInWingFly = data.isAdd

		self:UpdateDodgeBtnSprite()
	end
end

function M:OnMindCounterAttack(eventId, isShowMindCounter)
	self.mindPowerBtn.qteVxCtrl = isShowMindCounter and 1 or 0
end

function M:OnWorkActionVxChange(eventId, table)
	if not table or not table.MobileImage or not table.MobileBtnName then
		return
	end

	if not self.characterControlData or not self[table.MobileBtnName] then
		print_error("[CoreHudCharacterControl][OnWorkActionVxChange]CombatTraining 表格配置错误, 不存在指定按键", table.MobileBtnName)

		return
	end

	self:SetBtnIcon(self[table.MobileBtnName], table.MobileImage)

	self[table.MobileBtnName].qteVxCtrl = table.isActive and 1 or 0
end

function M:OnRefreshMotoState(eventId, isOnMoto)
	if self.dodgeBtn then
		self.dodgeBtn.taffySpeedUpCtrl = isOnMoto and 1 or 0
	end
end

function M:OnSwitchControlChanged(eventId, enable)
	self.switchControlEnable = enable
end

function M:OnSpiritChange()
	self:UpdateByWeaponRefresh(true)
end

function M:UpdateByWeaponRefresh(needRefreshAmmunition)
	self:CheckWeaponDurability()
	self:RefreshBtnTipStatus()

	if needRefreshAmmunition then
		gCS.WeaponMgr:RefreshCurrentAmmunitionInfo()
		self:RefreshWeaponDurabilityUI(gCS.WeaponMgr:GetCurrentWeaponTid())
	end

	local currentWeapon = gPlayerManager.infoSpirit.bindData.currentWeapon

	if currentWeapon then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Hold_E, "isNotDiscard", gWeaponManager:GetFlag(currentWeapon.OperatorFlags, 1) == 1)
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchWeaponWheels, "isHandBag", gCS.WeaponMgr:GetCurrentWeaponActiveType() == self.handBagActionType)
	end
end

function M:OnSpiritInfoChanged(eventId, spiritTid)
	self:UpdateFightSpiritBigSkill()
	self:UpdateSkillCD(_, spiritTid)
end

function M:Log(...)
	if gMainMenuMgr.ShowTestMsg then
		print_warn("[CoreHudCharacterControlStore]", ...)
	end
end
