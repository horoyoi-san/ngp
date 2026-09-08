-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudCharacterControlStore.lua
-- Decompiled from: 01487_CoreHudCharacterControlStore.lua_844646d01581.luajit

local ProfileManager = LX6.Engine.ProfileManager
local GameConfig = LTConfig.GameConfig
local SkillConfig = LTConfig.SkillConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local ClientEventConfig = LTConfig.ClientEventConfig
local UnitOperateUtils = require("LX6/Utils/UnitOperateUtils")
local OperateType = UnitOperateUtils.OperateType
local DragEventListener = SGUI.EventSystems.DragEventListener
local HudDescConfig = LTConfig.HudDescConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local DurabilityUIModeType = LTConfig.SceneitemConfig.DurabilityUIModeType
local WeaponShootConfig = LTConfig.WeaponShootConfig
local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
local MindButtonTypeType = LTConfig.BattleEnemyInteractConfig.MindButtonTypeType
local ABPCCCEventConfig = LTConfig.ABPCCCEventConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
local BattleEnemyInteractConfig = LTConfig.BattleEnemyInteractConfig
local CoreHudButtonConfig = LTConfig.CoreHudButtonConfig
local CoreHudModeShowModeConfig = LTConfig.CoreHudModeShowModeConfig
local GameplayTagQueryConfig = LTConfig.GameplayTagQueryConfig
local SceneItemInteractionUseFunctionConfig = LTConfig.SceneItemInteractionUseFunctionConfig
C_CoreHudCharacterControlStore = DefClass("C_CoreHudCharacterControlStore", C_CoreHudCharacterControlStore, C_StoreGroup)
GroupName2Class.CoreHudCharacterControlStore = C_CoreHudCharacterControlStore
local M = C_CoreHudCharacterControlStore
local WeaponNumType = {
	["\\xa9}h"] = 0,
	["\\xc1\\x88\\xe98\\xf4\\xe8\\x81\\xe1\\x8b41"] = 2,
	["\\xe9\\xde*\\xe5"] = 1,
	["\n$&\\xed}\\x91\\xe31\\x98*\\xf4\\xf1\\xe3z\\xef"] = 4,
	["Fx\\xaa~B\\xbb\\xe6BKwsC"] = 3,
	["zN˰\\xaa\\xb5\\xcc\\xfa"] = 5
}
local BtnBattleMode = {
	["2G\\x83\\x83\\x82M"] = 1,
	[">I\\x85\\x9a\\x8fD"] = 0
}
local ChangeWeaponMode = {
	["^-jU"] = 2,
	["5"] = 1,
	["T-s^"] = 0
}

M.ctor = function(self)
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
	self.mgr = gStoreButtonMgr
	self.isKeSiCharacter = false
	self.circleOpen = false
	self.needUpdateCamera = false
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
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
	self.isBasicNoSkillId = false
	self.isHoldBlend = false
	self.isOpenNightVision = false
	self.isPressDodge = false
	self.isPressFightSpirit = false
	self.switchControlEnable = true
	self.weaponStateEnum = {
		["\\+qW"] = 0,
		[">Z\\x9e\\x85\\x86O"] = 1,
		["T-s^"] = 2
	}
	self.curWeaponBulletId = 0
	self.curWeaponTid = 0
	self.cachedAppropriateBullets = nil
	self.BulletQuality2Ctrl = {
		[0] = 0,
		nil,
		nil,
		1
	}
	self.dragButtons = {
		"\\xaf\\xbe\\xaco\\xea=",
		"-%2\\xe9r\\x94\\xd6 \\xbc.\\xe5\\xf9\\xc4`\\xf5",
		"b\\xa2s|\\xbd\\xe5BxXjB",
		"PNܱ\\xa6\\xac\\xc6\\xe6",
		"\\xef\\x9f\\xfa0\\xf2\\xeb\\x8b\\xe6\\xa04&",
		"\\xe3\\x93\\xe9/\\xe3\\xee\\xbd\\xfd\\xa04&"
	}
	self.handBagActionType = 2002
	self.motoConditions = {
		[ParkourStateConfig.Moto] = false,
		[ParkourStateConfig.MotorbikeIdle] = false
	}
end

M.OnAwake = function(self)
	self:InitOnAwake()
	gMainMenuMgr:SetAwakeUI("awakeBattlePanel")

	slot1 = gCoreHudUIManager

	slot1:OnRefreshForAwakeUI()

	self.curActiveDevice = gCS.LuaUtils.GetActiveDevice()
	self.QTE_TIER_CONFIG = {
		[gCoreHudQteVisualMgr.Tier.MindPower] = {
			["\\xa9\\xa5\\x8dc;\\xf27"] = "b\\xa2s|\\xbd\\xe5BxXjB",
			["BW|eW8;"] = ".&\\xa4\\xec&6}-\\x9f7ٙ\\xa3:\\x8a\\x82Ȃ"
		},
		[gCoreHudQteVisualMgr.Tier.Block] = {
			["\\xa9\\xa5\\x8dc;\\xf27"] = "\\xef\\x9f\\xfa0\\xf2\\xeb\\x8b\\xe6\\xa04&",
			["BW|eW8;"] = "\\\\xa2=\\xee[\\xa2y*0#/G\\xa8\\xed0\\xd8\\xeb"
		},
		[gCoreHudQteVisualMgr.Tier.Dodge] = {
			["\\xa9\\xa5\\x8dc;\\xf27"] = "\\xaf\\xbe\\xaco\\xea=",
			["BW|eW8;"] = ".&\\xa4\\xec&6}-\\x9f7ٙ\\xa3:\\x8a\\x82Ȃ"
		},
		[gCoreHudQteVisualMgr.Tier.KickOff] = {
			["\\xa9\\xa5\\x8dc;\\xf27"] = "XSͶ\\xab\\xbe&\\xdd\\xe6",
			["BW|eW8;"] = ".&\\xa4\\xec&6}-\\x9f7ٙ\\xa3:\\x8a\\x82Ȃ"
		}
	}
end

M.OnDestroy = function(self)
	gBattleMgr.characterControlPanel = nil

	self.ClearDataSetEvents(self)
	self.ClearMessageEvents(self)
	self.ClearAllRef(self)

	gCoreHudTipManager.isInitCache = false
end

M.OnStart = function(self)
	gBattleMgr.characterControlPanel = self

	self:BindDataByScheme(self.curActiveDevice)
	self:InitData()
	gCoreHudUIManager:ApplyGameplayTagPlatform()
	self:UpdateByWeaponRefresh(true)
	self:OnControllerSettingChange(_, ProfileManager.gameProfile.isNewControllerSetting)
	self:RefreshControllerShotByUltR2()
	self:OnCharacterChange()
	self:UpdateMobileOnBattleCtrl()
end

M.UpdateMobileOnBattleCtrl = function(self)
	gCoreHudUIManager:ApplyMobileOnBattleCtrl(self.bindData)
end

M.OnShow = function(self)
	self.cachedShowShootCrossHair = gCS.MindPowerMgr.showShootCrossHair

	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.CHARACTER_CONTROLS, self.GetCameraConfigId(self))
end

M.OnUpdate = function(self)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	self.UpdateSkillBtns(self)
	self.UpdateGamepadCamera(self)
	self.RefreshProfessionSkillBtnCD(self)
	self.UpdateWeaponCircleControlSlider(self)

	self.countTime = self.countTime - Time.deltaTime

	if self.countTime <= 0 then
		return
	end

	self.countTime = self.FRAME_TIME

	self.CheckBtnTips(self)
end

M.OnLateUpdate = function(self)
	if self.curActiveDevice == SGUI.GameDevice.PlayStation then
		return
	end

	if self.isPressDodge and self.isPressFightSpirit then
		gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.FightSpiritBigSkill, true)

		if not self:CheckSkillBtnIsEnable(3) then
			return
		end

		self.PlaySkillBtnDownFanseAni(self, self.goSkills[3])

		self.mergeBtnDownCache[3] = true

		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(3)
	elseif self.isPressDodge then
		gBattleMgr:OnDodgeBtnPressFunc()
	elseif self.isPressFightSpirit then
		self.OnFightSpiritBigSkillPress(self)
	end

	self.isPressDodge = false
	self.isPressFightSpirit = false
end

M.OnFightSpiritBigSkillPress = function(self)
	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.FightSpiritBigSkill, true)

	if not self:CheckSkillBtnIsEnable(3) then
		return
	end

	self.PlaySkillBtnDownFanseAni(self, self.goSkills[3])

	self.mergeBtnDownCache[3] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(3)
end

M.OnClose = function(self)
	gBattleMgr.characterControlPanel = nil

	self:ClearAllBtnFanseAni()
	gMainMenuMgr:SetAwakeUI("awakeBattlePanel")
	gCoreHudUIManager:OnRefreshForAwakeUI()

	self.lowDurabilityPlayed = {}

	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.CHARACTER_CONTROLS)
end

M.ResetSomeDatas = function(self)
	self.aniControlDazhaos = {}
	self.showNomalAttackTips = nil
end

M.InitData = function(self)
	self:GetBtnBindData()
	self:BindBtnEvent()
	self:ReplaceDodgeBtnToMindPower()
	self:InitSkillBtn()
	self:RegisterBtnAction()
	gCoreHudTipManager:InitTipDefaultCache()
	self:SyncRefreshBasicSkills()
	gBattleMgr:CheckShowJobSpecialBtn()
	gBattleMgr:CheckShowWeaponResHUDByTemplateId(gBattleMgr.battleWeaponTemplateId)
	self:ShowAmmunition(self.showAmmunition)
	self:RefreshSwitchToAndriodsBtnState()
	self:OtherInit()
	self:InitShowCostumeSkillState()
	gCS.WeaponMgr.RefreshCurrentAmmunitionInfo()
	gMainMenuMgr:SetAwakeUI("awakeBattlePanel")
	gCoreHudUIManager:OnRefreshForAwakeUI()
end

M.OtherInit = function(self)
	self.UpdateBtnSpriteInAir(self, false, true)
	self.EnableSeeMobileButton(self, nil, false)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LuaUtils.SetInRushMode(gCS.MyPlayerManager.PlayerUnit, false)
	end
end

M.BindDataByScheme = function(self, scheme)
	self.characterControlData = self.bindData
end

M.GetInstRefByPath = function(self, path, childPath)
	if not self.characterControlData then
		return nil
	end

	local inst = self.characterControlData[path]

	if not inst then
		return nil
	end

	if string.is_null_or_empty(childPath) then
		return inst
	end

	local childInst = self.GetStoreByWidget(self, inst)[childPath]

	return childInst
end

M.BindBtnEvent = function(self)
	self.characterControlData.jumpSwingBtn.luaPress = self.CreateAction(self, "OnJumpSwingBtnPress")
	self.characterControlData.jumpSwingBtn.luaRelease = self.CreateAction(self, "OnJumpSwingBtnRelease")
	self.characterControlData.jumpSwingBtn.luaBeginLongPress = self.CreateAction(self, "OnJumpSwingBtnLongPressBegin")
	self.characterControlData.jumpSwingBtn.luaLongPress = self.CreateAction(self, "OnJumpSwingBtnLongPress")
	self.characterControlData.jumpSwingBtn.luaEndLongPress = self.CreateAction(self, "OnJumpSwingBtnLongPressEnd")
	local jumpSwingBtnDrag = DragEventListener.Get(self.characterControlData.jumpSwingBtn.gameObject)
	jumpSwingBtnDrag.onDrag = self.CreateAction(self, "OnJumpSwingBtnDrag")

	self.SetShowJumpSwingJoystick(self, false)

	self.characterControlData.dodgeBtn.luaPress = self.CreateActionWithArgs(self, "OnDodgeBtnPress", 1)
	self.characterControlData.dodgeBtn.luaRelease = self.CreateActionWithArgs(self, "OnDodgeBtnRelease", 1)
	self.characterControlData.dodgeBtn.luaClick = self.CreateAction(self, "OnDodgeBtnClick")
	self.characterControlData.dodgeBtn.luaBeginLongPress = self.CreateAction(self, "OnDodgeBtnLongPressBegin")
	self.characterControlData.dodgeBtn.luaLongPress = self.CreateAction(self, "OnDodgeBtnLongPress")
	self.characterControlData.dodgeBtn.luaEndLongPress = self.CreateAction(self, "OnDodgeBtnLongPressEnd")
	self.characterControlData.normalAttackBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressBegin", 1)
	self.characterControlData.normalAttackBtn.luaLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPress", 1)
	self.characterControlData.normalAttackBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressEnd", 1)
	self.characterControlData.mindPowerBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressBegin", 4)
	self.characterControlData.mindPowerBtn.luaLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPress", 4)
	self.characterControlData.mindPowerBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressEnd", 4)
	self.specialBtnRoot.skillBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressBegin", 2)
	self.specialBtnRoot.skillBtn.luaLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPress", 2)
	self.specialBtnRoot.skillBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressEnd", 2)
	self.specialBtnRoot.normalBtn.luaBeginLongPress = self.CreateAction(self, "OnEBtnBeginLongPress")
	self.specialBtnRoot.normalBtn.luaLongPress = self.CreateAction(self, "OnEBtnLongPress")
	self.specialBtnRoot.normalBtn.luaEndLongPress = self.CreateAction(self, "OnEBtnEndLongPress")
	self.ultBtnRoot.skillBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressBegin", 3)
	self.ultBtnRoot.skillBtn.luaLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPress", 3)
	self.ultBtnRoot.skillBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressEnd", 3)
	self.ultBtnRoot.normalBtn.luaBeginLongPress = self.CreateAction(self, "OnRBtnBeginLongPress")
	self.ultBtnRoot.normalBtn.luaLongPress = self.CreateAction(self, "OnRBtnLongPress")
	self.ultBtnRoot.normalBtn.luaEndLongPress = self.CreateAction(self, "OnRBtnEndLongPress")
	self.characterControlData.heavyAttackBtn.luaBeginLongPress = self.CreateAction(self, "OnHeavyAttackBtnLongPressBegin")
	self.characterControlData.heavyAttackBtn.luaLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPress", 5)
	self.characterControlData.heavyAttackBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressEnd", 5)
	self.characterControlData.dropBtn.luaBeginLongPress = self.CreateAction(self, "OnDropBtnLongPressBegin")
	self.characterControlData.dropBtn.luaLongPress = self.CreateAction(self, "OnDropBtnLongPress")
	self.characterControlData.dropBtn.luaEndLongPress = self.CreateAction(self, "OnDropBtnLongPressEnd")
	self.characterControlData.costumeSkill.luaPress = self.CreateAction(self, "OnCostumeSkillBtnPress")
	self.characterControlData.costumeSkill.luaRelease = self.CreateAction(self, "OnCostumeSkillBtnRelease")
	self.characterControlData.costumeSkill.luaClick = self.CreateAction(self, "OnCostumeSkillClick")
	self.characterControlData.costumeSkill.luaLongPress = self.CreateAction(self, "OnCostumeSkillClick")
	self.characterControlData.seeMobileBtn.luaClick = self.CreateAction(self, "SeeMobileButtonClick")

	if self.characterControlData.walkBtn then
		self.characterControlData.walkBtn.luaClick = self.CreateAction(self, "OnWalkBtnClick")
	end

	self.characterControlData.ammunitionRoot.luaPress = self.CreateAction(self, "OnWeaponCircleLongPressStart")
	self.characterControlData.ammunitionRoot.luaRelease = self.CreateAction(self, "OnWeaponCircleLongPressEnd")
	local weaponBtnDrag = DragEventListener.Get(self.characterControlData.ammunitionRoot.gameObject)
	weaponBtnDrag.onBeginDrag = self.CreateAction(self, "OnWeaponBtnDragBegin")
	weaponBtnDrag.onDrag = self.CreateAction(self, "OnWeaponBtnDrag")
	weaponBtnDrag.onEndDrag = self.CreateAction(self, "OnWeaponBtnDragEnd")

	if self.ammunitionRoot and self.ammunitionRoot.mouseScrollRespond then
		self.ammunitionRoot.mouseScrollRespond.luaGamePadInputChanged = self.CreateAction(self, "OnWeaponMouseScroll")
	end

	if self.characterControlData.controllerWeaponSwitchCircle then
		self.characterControlData.controllerWeaponSwitchCircle.luaBeginLongPress = self.CreateAction(self, "OnControllerWeaponSwitchCircleBegin")
		self.characterControlData.controllerWeaponSwitchCircle.luaLongPress = self.CreateAction(self, "OnWeaponCircleLongPressStart")
		self.characterControlData.controllerWeaponSwitchCircle.luaEndLongPress = self.CreateAction(self, "OnWeaponCircleLongPressEnd")
		self.characterControlData.controllerWeaponSwitchCircle.luaClick = self.CreateAction(self, "OnWeaponCircleClick")
	end

	if self.characterControlData.controllerWeaponSwitch then
		self.characterControlData.controllerWeaponSwitch.luaClick = self.CreateAction(self, "OnControllerWeaponSwitch")
	end

	if self.characterControlData.ctrlButton then
		self.characterControlData.ctrlButton.luaPress = self.CreateAction(self, "OnCtrlButtonPress")
		self.characterControlData.ctrlButton.luaRelease = self.CreateAction(self, "OnCtrlButtonRelease")
	end

	self.needUpdateCamera = false
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.lastCameraConfigId = nil
	self.cachedShowShootCrossHair = false
	self.characterControlData.rightStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")

	if self.characterControlData.cameraResetBtn then
		self.characterControlData.cameraResetBtn.luaClick = self.CreateAction(self, "OnCameraResetBtnClick")
	end

	if self.characterControlData.kickOffBtn then
		self.characterControlData.kickOffBtn.luaPress = self.CreateAction(self, "OnKickOffBtnDown")
		self.characterControlData.kickOffBtn.luaRelease = self.CreateAction(self, "OnKickOffBtnUp")
	end

	if self.characterControlData.professionSkillBtn then
		self.characterControlData.professionSkillBtn.luaPress = self.CreateAction(self, "OnProfessionSkillBtnDown")
		self.characterControlData.professionSkillBtn.luaRelease = self.CreateAction(self, "OnProfessionSkillBtnUp")
	end

	if self.characterControlData.controllerL3 then
		self.characterControlData.controllerL3.luaPress = self.CreateAction(self, "OnControllerL3Down")
		self.characterControlData.controllerL3.luaRelease = self.CreateAction(self, "OnControllerL3Up")
	end

	if self.characterControlData.controllerGunNorth then
		self.characterControlData.controllerGunNorth.luaBeginLongPress = self.CreateAction(self, "OnControllerGunNorthBeginLongPress")
		self.characterControlData.controllerGunNorth.luaLongPress = self.CreateAction(self, "OnControllerGunNorthLongPress")
		self.characterControlData.controllerGunNorth.luaEndLongPress = self.CreateAction(self, "OnControllerGunNorthLongPressEnd")
	end

	if self.characterControlData.controllerGunWest then
		self.characterControlData.controllerGunWest.luaBeginLongPress = self.CreateAction(self, "OnControllerGunWestBeginLongPress")
		self.characterControlData.controllerGunWest.luaLongPress = self.CreateAction(self, "OnControllerGunWestLongPress")
		self.characterControlData.controllerGunWest.luaEndLongPress = self.CreateAction(self, "OnControllerGunWestLongPressEnd")
	end

	if self.characterControlData.leftShootBtn then
		self.characterControlData.leftShootBtn.luaPress = self.CreateActionWithArgs(self, "OnLeftShootBtnDown", 1)
		self.characterControlData.leftShootBtn.luaRelease = self.CreateActionWithArgs(self, "OnLeftShootBtnUp", 1)
		self.characterControlData.leftShootBtn.luaClick = self.CreateActionWithArgs(self, "OnLeftShootBtnClick", 1)
	end

	if self.characterControlData.controllerShot then
		self.characterControlData.controllerShot.luaBeginLongPress = self.CreateAction(self, "OnControllerShootBeginLongPress")
		self.characterControlData.controllerShot.luaLongPress = self.CreateAction(self, "OnControllerShootLongPress")
		self.characterControlData.controllerShot.luaEndLongPress = self.CreateAction(self, "OnControllerShootLongPressEnd")
	end

	if self.characterControlData.controllerSwing then
		self.characterControlData.controllerSwing.luaPress = self.CreateAction(self, "OnControllerSwingPress")
		self.characterControlData.controllerSwing.luaRelease = self.CreateAction(self, "OnControllerSwingRelease")
	end

	self.characterControlData.switchToAndriodsBtn.luaClick = self.CreateAction(self, "OnSwitchToAndriodsBtnClick")

	if self.characterControlData.controllerGunAim then
		self.characterControlData.controllerGunAim.luaBeginLongPress = self.CreateAction(self, "OnControllerAimBeginLongPress")
		self.characterControlData.controllerGunAim.luaLongPress = self.CreateAction(self, "OnControllerAimLongPress")
		self.characterControlData.controllerGunAim.luaEndLongPress = self.CreateAction(self, "OnControllerAimLongPressEnd")
	end

	if self.characterControlData.controllerBlock then
		self.characterControlData.controllerBlock.luaBeginLongPress = self.CreateAction(self, "OnControllerBlockBeginLongPress")
		self.characterControlData.controllerBlock.luaLongPress = self.CreateAction(self, "OnControllerBlockLongPress")
		self.characterControlData.controllerBlock.luaEndLongPress = self.CreateAction(self, "OnControllerBlockLongPressEnd")
	end

	if self.characterControlData.skyDiveBtn then
		self.characterControlData.skyDiveBtn.luaClick = self.CreateAction(self, "OnSkyDiveBtnClick")
	end

	if self.characterControlData.diveSpeedUpBtn then
		self.characterControlData.diveSpeedUpBtn.luaBeginLongPress = self.CreateAction(self, "OnDiveSpeedUpBtnBeginLongPress")
		self.characterControlData.diveSpeedUpBtn.luaLongPress = self.CreateAction(self, "OnDiveSpeedUpBtnLongPress")
		self.characterControlData.diveSpeedUpBtn.luaEndLongPress = self.CreateAction(self, "OnDiveSpeedUpBtnLongPressEnd")
	end

	if self.characterControlData.resetVehicleBtn then
		self.characterControlData.resetVehicleBtn.luaClick = self.CreateAction(self, "OnResetVehicleBtnClick")
	end

	if self.characterControlData.umbrellaBtn then
		self.characterControlData.umbrellaBtn.luaClick = self.CreateAction(self, "OnUmbrellaBtnClick")
	end

	if self.characterControlData.diveUpBtn then
		self.characterControlData.diveUpBtn.luaPress = self.CreateAction(self, "OnDiveUpBtnPress")
		self.characterControlData.diveUpBtn.luaRelease = self.CreateAction(self, "OnDiveUpBtnRelease")
	end

	if self.characterControlData.debugAgentCircleBtn then
		self.characterControlData.debugAgentCircleBtn.luaPress = self:CreateAction("OnDebugAgentCircleBtnPress")
		self.characterControlData.debugAgentCircleBtn.luaRelease = self:CreateAction("OnDebugAgentCircleBtnRelease")

		self.characterControlData.debugAgentCircleBtn:SetActive(false)

		local summonStore = gStoreManager:GetStoreGroup("BackCircleJiaMuSummonStore")

		if summonStore then
			summonStore.DebugAgentCircleBtnGMEnabled = false
		end
	end

	if self.ammunitionRoot and self.ammunitionRoot.bulletBtn then
		self.ammunitionRoot.bulletBtn.luaClick = self.CreateAction(self, "OnBulletBtnClick")
	end

	if self.ammunitionRoot and self.ammunitionRoot.seedBulletBtn then
		self.ammunitionRoot.seedBulletBtn.luaClick = self.CreateAction(self, "OnSeedBulletBtnClick")
		self.ammunitionRoot.seedBulletBtn.luaPress = self.CreateAction(self, "OnSeedBulletBtnPress")
		self.ammunitionRoot.seedBulletBtn.luaRelease = self.CreateAction(self, "OnSeedBulletBtnRelease")
	end

	gCoreHudUIManager:SetupDragButtons(self.characterControlData, self.dragButtons)
end

M.OnJumpSwingBtnPress = function(self, isLongPress)
	self.PlaySkillBtnDownFanseAni(self, self.jumpSwingBtn)

	if gBattleMgr.btnPaoKuBtnDown or gBattleMgr.btnPaoKuBtnDownFrame ~= Time.frameCount then
		return
	end

	self.pressJumpKeyDown = true

	if not self.characterControlData.jumpSwingBtn.interactable then
		return
	end

	if gCS.LuaUtils.CanSwing() then
		gCS.TransitionMgr.isPressingSwingDown = true
		gCS.TransitionMgr.pressingSwingDownTime = gLogicTime.time
	end

	UnitOperateUtils.DoOperateFunc(OperateType.KeyDown, gCS.MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpPress)
		gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.JumpPress)
	end

	gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.JumpButtonClick)
	gMessageManager:SendMessage(gEventConstants.ON_HUD_BUTTON_CLICK, gCoreHudUIManager.skillType.JumpJump)
end

M.OnJumpSwingBtnRelease = function(self, notPlayAni)
	if gBattleMgr.gmIgnoreJumpSwingBtnUp then
		return
	end

	self.PlaySkillBtnUpFanseAni(self, self.jumpSwingBtn, nil, notPlayAni)

	if not self.pressJumpKeyDown and not self.characterControlData.jumpSwingBtn.interactable then
		return
	end

	self.pressJumpKeyDown = false

	if not self.pressControllerSwingDown then
		gCS.TransitionMgr.isPressingSwingDown = false
		gCS.TransitionMgr.pressingSwingDownTime = 0
	end

	UnitOperateUtils.DoOperateFunc(OperateType.KeyUp, gCS.MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpRelease)
		gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.JumpRelease)
	end
end

M.OnJumpSwingBtnLongPressBegin = function(self)
	self.needShowSwingJoyStick = true

	if gCoreHudUIManager.isNonMobileAdaptive then
		self.OnJumpSwingBtnPress(self, true)
	end
end

M.OnJumpSwingBtnLongPress = function(self)
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

M.OnJumpSwingBtnLongPressEnd = function(self)
	self.needShowSwingJoyStick = false

	self.SetShowJumpSwingJoystick(self, false)

	if gCoreHudUIManager.isNonMobileAdaptive then
		self.OnJumpSwingBtnRelease(self)
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

M.OnJumpSwingBtnDrag = function(self, eventPointer)
	gMainMenuMgr:OnDragBtnDraging(nil, eventPointer)
	self:SetSwingHandlePos(eventPointer)
end

M.SetShowJumpSwingJoystick = function(self, isShow)
	if not self.characterControlData.jumpSwingHandle then
		return
	end

	self.isShowSwingJoyStick = isShow

	self.characterControlData.jumpSwingBottom:SetActive(isShow)
	self.characterControlData.jumpSwingHandle:SetActive(isShow)
	self.characterControlData.jumpSwingHandle:SetLocalPos(Vector3.zero)
end

M.SetSwingHandlePos = function(self, eventPointer)
	if not self.characterControlData.jumpSwingHandle then
		return
	end

	local uiPoint = gCS.LuaUtils.TransformScreenPointToUI(self.characterControlData.jumpSwingBtn.rectTransform, eventPointer.position)
	local center = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	local radius = LTConfig.GameConfig.JumpSwingBtnDragRadius
	local handlePos = self:GetPointInCircle(center, radius, uiPoint)

	self.characterControlData.jumpSwingHandle:SetLocalPos(handlePos)
end

M.GetPointInCircle = function(self, center, radius, point)
	local dx = point.x - center.x
	local dy = point.y - center.y
	local distance = math.sqrt(dx * dx + dy * dy)

	if distance < radius then
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

M.OnCtrlButtonPress = function(self)
	self.PlaySkillBtnDownFanseAni(self, self.GetStoreByWidget(self, self.characterControlData.ctrlButton))

	local inputModule = gCS.BaseUnitModuleUtils.GetOrAddInputControlModule(gCS.MyPlayerManager.PlayerUnit)
	inputModule.isControlButtonPress = true
end

M.OnCtrlButtonRelease = function(self)
	self.PlaySkillBtnUpFanseAni(self, self.GetStoreByWidget(self, self.characterControlData.ctrlButton))

	local inputModule = gCS.BaseUnitModuleUtils.GetOrAddInputControlModule(gCS.MyPlayerManager.PlayerUnit)
	inputModule.isControlButtonPress = false
end

M.OnDodgeBtnPress = function(self, data)
	if not self.characterControlData.dodgeBtn.interactable or data ~= 2 and not gBattleMgr:CheckIsInMotorState() then
		gBattleMgr:ShowMessageTipsOnEditor("colliderHighSpeed关闭")

		return
	end

	self.PlaySkillBtnDownFanseAni(self, self.dodgeBtn)

	if self.curActiveDevice ~= SGUI.GameDevice.PlayStation then
		self.isPressDodge = true
	else
		gBattleMgr:OnDodgeBtnPressFunc()
	end

	gMessageManager:SendMessage(gEventConstants.ON_HUD_BUTTON_CLICK, gCoreHudUIManager.skillType.Dodge)
end

M.OnDodgeBtnRelease = function(self)
	self:PlaySkillBtnUpFanseAni(self.dodgeBtn)
	gBattleMgr:OnDodgeBtnReleaseFunc()
end

M.OnDodgeBtnClick = function(self)
end

M.OnDodgeBtnLongPressBegin = function(self)
	if gCoreHudUIManager.isNonMobileAdaptive then
		self.OnDodgeBtnPress(self)
	end
end

M.OnDodgeBtnLongPress = function(self)
	if not gBattleMgr.canDodge then
		return
	end

	self.alreadyPressDodgeBtn = true
	local isOk = false

	if gBattleMgr.IsUseNewCombo then
		isOk = gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.DodgeButtonPressin)
	end
end

M.OnDodgeBtnLongPressEnd = function(self)
	if gCoreHudUIManager.isNonMobileAdaptive then
		self.OnDodgeBtnRelease(self)
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

M.OnDropBtnLongPressBegin = function(self)
	if not self.characterControlData.dropBtn.interactable then
		gBattleMgr:ShowMessageTipsOnEditor("跳下墙按钮的collider被关闭了")

		return
	end

	self.PlaySkillBtnDownFanseAni(self, self.dropBtn)

	if not gCoreHudUIManager.isOnWall then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.StockAttack)
	end

	gCS.TransitionMgr.wallJumpOffDown = true

	gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

	gCS.TransitionMgr.wallJumpOffDown = false

	gCS.LogicStateMachineManager.SendWall3CEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.WallCCCEvent.X_KEYCODE_LeaveWall)
end

M.OnDropBtnLongPress = function(self)
	if not gCoreHudUIManager.isOnWall then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.StockAttack)
	end
end

M.OnDropBtnLongPressEnd = function(self)
	self.PlaySkillBtnUpFanseAni(self, self.dropBtn)

	if not self.characterControlData.dropBtn.interactable then
		gBattleMgr:ShowMessageTipsOnEditor("跳下墙按钮的collider被关闭了")

		return
	end

	gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

	if not gCoreHudUIManager.isOnWall then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.StockAttack)
	end
end

local CostumeSkillKeyId = {
	["n\\xa2\\xad\\xbc\\xb3"] = 586,
	U2xU = 585
}

M.OnCostumeSkillClick = function(self)
	self.RefreshNightVision(self, not self.isOpenNightVision, true)
end

M.OnCostumeSkillBtnPress = function(self)
	self.PlaySkillBtnDownFanseAni(self, self.costumeSkill)
end

M.OnCostumeSkillBtnRelease = function(self)
	self.PlaySkillBtnUpFanseAni(self, self.costumeSkill)
end

M.InitShowCostumeSkillState = function(self)
	self.isOpenNightVision = false

	self.RefreshPlayerFashionData(self)
end

M.RefreshPlayerFashionData = function(self)
	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.FashionSlot then
		local fashionSlot = gCS.MyPlayerManager.PlayerUnit.FashionSlot
		local allPropIds = fashionSlot.GetAllFashionPropId(fashionSlot)

		self.CheckPlayerFashion(self, allPropIds)
	end
end

M.CheckPlayerFashion = function(self, allPropIds)
	local faraway = true
	local isOpenNightVision = false

	if allPropIds then
		for i = 0, allPropIds.Length - 1 do
			if allPropIds[i] ~= LTConfig.FashionConfig.OpenNightVision or allPropIds[i] ~= LTConfig.FashionConfig.CloseNightVision or allPropIds[i] ~= LTConfig.FashionConfig.NightVisionVariant then
				faraway = false
				isOpenNightVision = allPropIds[i] == LTConfig.FashionConfig.CloseNightVision
			end
		end
	end

	self:RefreshNightVision(isOpenNightVision)
	self.characterControlData.costumeSkill:SetWidgetFaraway(faraway)
end

M.RefreshNightVision = function(self, isOpenNightVision, isClick)
	if isOpenNightVision == self.isOpenNightVision and gPanelManager:VisibleModeHUD() then
		if isClick then
			if not self.isTryOn then
				self.SetNightVisionVariant(self, isOpenNightVision)
			else
				gClientToGameSceneDelegate:AskTriggerNightVision()
			end

			self.SetBtnInteractable(self, self.costumeSkill, false)
			coroutine.start(function ()
				coroutine.wait(1)
				self:SetBtnInteractable(self.costumeSkill, true)
			end)
		else
			self.isOpenNightVision = isOpenNightVision

			gCS.LuaUtils.SetFashionNightVision(isOpenNightVision)
		end
	end

	self.characterControlData.costumeSkill:SetPCKeyInfoTipNameId(self.isOpenNightVision and CostumeSkillKeyId.Close or CostumeSkillKeyId.Open)
end

M.OnNightVisionState = function(self, _, state)
	self.isTryOn = state
end

M.SetNightVisionVariant = function(self, isOpenNightVision)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()

	if spiritId then
		gDressManager:SetSpiritFashionVariant(spiritId, LTConfig.FashionConfig.CloseNightVision, isOpenNightVision and LTConfig.FashionConfig.NightVisionVariant or LTConfig.FashionConfig.CloseNightVision, true)
	end
end

M.OnUIVisibleModeChange = function(self)
	if not gPanelManager:VisibleModeHUD() then
		if self.isOpenNightVision then
			gCS.LuaUtils.SetFashionNightVision(false)
		end
	else
		self.InitShowCostumeSkillState(self)
	end
end

M.OnMergeBtnLongPressBegin = function(self, data, notFromBtnDown)
	if data ~= 3 and self.curActiveDevice ~= SGUI.GameDevice.PlayStation then
		self.isPressFightSpirit = true

		return
	end

	gCoreHudUIManager:SetBattleHudSkillActivity(data, true)

	if not self:CheckSkillBtnIsEnable(data) then
		return
	end

	self:PlaySkillBtnDownFanseAni(self.goSkills[data])

	self.mergeBtnDownCache[data] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(data)
	gMessageManager:SendMessage(gEventConstants.ON_HUD_BUTTON_CLICK, data)
end

M.OnMergeBtnLongPressEnd = function(self, data)
	gCoreHudUIManager:SetBattleHudSkillActivity(data, false)

	if not self.mergeBtnDownCache[data] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[data] = false

	self.PlaySkillBtnUpFanseAni(self, self.goSkills[data], data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(data)
end

M.OnMergeBtnClick = function(self, data)
end

M.OnMergeBtnLongPress = function(self, data)
	if not self.CheckSkillBtnIsEnable(self, data) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(data)
end

M.OnEBtnBeginLongPress = function(self)
	if self.isHoldBlend then
		gCS.MindPowerMgr:TryLaunchCurMindItem()
	else
		self.OnMergeBtnLongPressBegin(self, 2)
	end
end

M.OnEBtnLongPress = function(self)
	if self.isHoldBlend then
		return
	end

	self.OnMergeBtnLongPress(self, 2)
end

M.OnEBtnEndLongPress = function(self)
	if self.isHoldBlend then
		return
	end

	self.OnMergeBtnLongPressEnd(self, 2)
end

M.OnRBtnBeginLongPress = function(self)
end

M.OnRBtnLongPress = function(self)
end

M.OnRBtnEndLongPress = function(self)
end

M.OnLeftShootBtnDown = function(self)
	local data = 1

	if not self.CheckSkillBtnIsEnable(self, data) then
		return
	end

	self.PlaySkillBtnDownFanseAni(self, self.leftShootBtn)

	self.mergeBtnDownCache[data] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(data)
end

M.OnLeftShootBtnUp = function(self)
	local data = 1

	if not self.mergeBtnDownCache[data] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[data] = false

	self.PlaySkillBtnUpFanseAni(self, self.leftShootBtn, data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(data)
end

M.OnLeftShootBtnClick = function(self)
end

M.UpdateMindPowerBtn = function(self)
	self.UpdateControlPowerSkill(self, true)
end

M.RegisterOperation = function(self, operation)
	return self.mgr:RegisterOperation(operation)
end

M.UnRegisterOperation = function(self, instanceId)
	return self.mgr:UnRegisterOperation(instanceId)
end

M.SetButtonVisibleBase = function(self, btnStore, visible)
	return self.mgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetButtonInteractableBase = function(self, btnStore, interactable)
	return self.mgr:SetButtonInteractableBase(btnStore, interactable)
end

M.SetButtonControlBase = function(self, btnStore, visible, interactable)
	return self.mgr:SetButtonControlBase(btnStore, visible, interactable)
end

M.OnPhoneAppShow = function(self)
	gCS.ParkourStateModule.SetClientState(ParkourStateConfig.OpenPhone, true)
	gCS.CoreHudModeManager:SwitchToModeShow(CoreHudModeShowModeConfig.PHONE)
end

M.OnPhoneAppHide = function(self)
	gCS.ParkourStateModule.SetClientState(ParkourStateConfig.OpenPhone, false)
	gCS.CoreHudModeManager:SwitchToModeShow(CoreHudModeShowModeConfig.DEFAULT)
end

M.PlayHudFadeInEffect = function(self)
	if self.bindData.fadeInEffectAni then
		gBattleMgr:CommonPlayAniTool(self.bindData.fadeInEffectAni, "S_vx_CoreHudPanel_open", 0, 1)
	end
end

M.OnCharacterChange = function(self)
	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	local clientData = playerUnit and playerUnit.ClientData
	local isKeSiCharacter = clientData and clientData.cardId ~= 15022030 or false

	if self.isKeSiCharacter ~= isKeSiCharacter then
		return
	end

	self.isKeSiCharacter = isKeSiCharacter

	if isKeSiCharacter then
		gCoreHudModeMgr:PushHudMode("KeSi", gCoreHudModeMgr.HUD_MODE.KESI)
		gPanelManager:CheckShow(gPanelId.KESI_CONTROLS)
	else
		gPanelManager:Close(gPanelId.KESI_CONTROLS)
		gCoreHudModeMgr:PopHudMode("KeSi")
	end
end

M.InitOnAwake = function(self)
	self.mgr:OnInit()
end

M.OnBeforeSwitchScene = function(self)
	self.ClearAllBtnFanseAni(self)
	self.SetPCKeyLongPressTime(self, self.basicSkillBtnGo, 0.2)
end

M.GetBtnBindData = function(self)
	self.jumpSwingBtn = self:GetStoreByWidget(self.characterControlData.jumpSwingBtn)
	self.jumpSwingBtn.btnId = HudDescConfig.JUMP_SWING_BTN

	gStoreButtonMgr:SetButtonEnterBarBsae(self.jumpSwingBtn, false)

	self.dodgeBtn = self:GetStoreByWidget(self.characterControlData.dodgeBtn)
	self.dodgeBtn.btnId = HudDescConfig.DODGE_BTN

	gStoreButtonMgr:SetButtonEnterBarBsae(self.dodgeBtn, false)

	self.normalSkillBtn = self:GetStoreByWidget(self.characterControlData.normalAttackBtn)
	self.normalSkillBtn.btnId = HudDescConfig.NORMAL_ATTACK_BTN
	self.specialBtnRoot = self:GetStoreByWidget(self.characterControlData.specialBtnRoot)
	self.basicSkillBtn = self:GetStoreByWidget(self.specialBtnRoot.skillBtn)
	self.basicSkillBtn.btnId = HudDescConfig.SPECIAL_BTN
	self.basicNormalBtn = self:GetStoreByWidget(self.specialBtnRoot.normalBtn)
	self.basicNormalBtn.btnId = HudDescConfig.SPECIAL_OTHER_BTN
	self.ultBtnRoot = self:GetStoreByWidget(self.characterControlData.ultBtnRoot)
	self.bigSkillBtn = self:GetStoreByWidget(self.ultBtnRoot.skillBtn)
	self.bigSkillBtn.btnId = HudDescConfig.ULT_BTN
	self.ultNormalBtn = self:GetStoreByWidget(self.ultBtnRoot.normalBtn)
	self.ultNormalBtn.btnId = HudDescConfig.ULT_OTHER_BTN
	self.mindPowerBtn = self:GetStoreByWidget(self.characterControlData.mindPowerBtn)
	self.mindPowerBtn.btnId = HudDescConfig.MIND_POWER_BTN
	self.heavyAttackBtn = self:GetStoreByWidget(self.characterControlData.heavyAttackBtn)
	self.heavyAttackBtn.btnId = HudDescConfig.BLOCK_BTN

	gStoreButtonMgr:SetButtonEnterBarBsae(self.heavyAttackBtn, false)

	self.dropBtn = self:GetStoreByWidget(self.characterControlData.dropBtn)
	self.dropBtn.btnId = HudDescConfig.DROP_BTN
	self.costumeSkill = self:GetStoreByWidget(self.characterControlData.costumeSkill)
	self.seeMobileBtn = self:GetStoreByWidget(self.characterControlData.seeMobileBtn)
	self.kickOffBtn = self:GetStoreByWidget(self.characterControlData.kickOffBtn)
	self.kickOffBtn.btnId = HudDescConfig.KICK_OFF_BTN
	self.ammunitionRoot = self:GetStoreByWidget(self.characterControlData.ammunitionRoot)
	self.ammunitionRoot.btnId = HudDescConfig.PROPSHEELS_BTN
	self.professionSkillBtn = self:GetStoreByWidget(self.characterControlData.professionSkillBtn)
	self.professionSkillBtn.btnId = HudDescConfig.CHAR_PROFESSION_SKILL_BTN
	self.switchToAndriodsBtn = self:GetStoreByWidget(self.characterControlData.switchToAndriodsBtn)
	self.ctrlBtn = self:GetStoreByWidget(self.characterControlData.ctrlButton)
	self.ctrlBtn.btnId = HudDescConfig.DIVE_BTN

	if self.characterControlData.leftShootBtn then
		self.leftShootBtn = self.GetStoreByWidget(self, self.characterControlData.leftShootBtn)
		self.leftShootBtn.btnId = HudDescConfig.NORMAL_ATTACK_LEFTBTN
	end

	if self.characterControlData.holdLeftBtn then
		self.holdLeftBtn = self.GetStoreByWidget(self, self.characterControlData.holdLeftBtn)
	end

	if self.characterControlData.holdQBtn then
		self.holdQBtn = self.GetStoreByWidget(self, self.characterControlData.holdQBtn)
	end

	if self.characterControlData.holdRBtn then
		self.holdRBtn = self.GetStoreByWidget(self, self.characterControlData.holdRBtn)
	end

	if self.characterControlData.resetVehicleBtn then
		self.resetVehicleBtn = self.GetStoreByWidget(self, self.characterControlData.resetVehicleBtn)
	end

	if self.characterControlData.umbrellaBtn then
		self.umbrellaBtn = self.GetStoreByWidget(self, self.characterControlData.umbrellaBtn)
		self.umbrellaBtn.btnId = HudDescConfig.UMBRELLA_BTN
	end

	if self.characterControlData.skyDiveBtn then
		self.skyDiveBtn = self.GetStoreByWidget(self, self.characterControlData.skyDiveBtn)
	end

	if self.characterControlData.diveUpBtn then
		self.diveUpBtn = self.GetStoreByWidget(self, self.characterControlData.diveUpBtn)
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
	self.dodgeBtn.multiBtn.luaPress = self.CreateActionWithArgs(self, "OnDodgeBtnPress", 2)
	self.dodgeBtn.multiBtn.luaRelease = self.CreateActionWithArgs(self, "OnDodgeBtnRelease", 2)

	if self.characterControlData.diveSpeedUpBtn then
		self.diveSpeedUpBtn = self.GetStoreByWidget(self, self.characterControlData.diveSpeedUpBtn)
	end
end

M.InitSkillBtn = function(self)
	self.goSkills[gBattleMgr.SkillBtnType.Normal] = self.normalSkillBtn
	self.goSkills[gBattleMgr.SkillBtnType.Basic] = self.basicSkillBtn
	self.goSkills[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = self.bigSkillBtn
	self.goSkills[gBattleMgr.SkillBtnType.ControlPower] = self.mindPowerBtn
	self.goSkills[gBattleMgr.SkillBtnType.HeavyAttack] = self.heavyAttackBtn
	self.skillNormalBtns[gBattleMgr.SkillBtnType.Basic] = self.basicNormalBtn
	self.skillNormalBtns[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = self.ultNormalBtn

	self.characterControlData.dodgeBtn.gameObject:SetActive(true)
end

M.RegisterBtnAction = function(self)
	self.msgEvents = {
		[gEventConstants.CONTROLPOWER_REFRESH] = self.CreateAction(self, "UpdateControlPowerSkill"),
		[gEventConstants.MIND_POWER_CHANGE] = self.CreateAction(self, "UpdateMindPowerBtn"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self.CreateAction(self, "SystemUnlockStateChange"),
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = self.CreateAction(self, "OnBeforeSwitchScene"),
		[gEventConstants.CAST_SKILL] = self.CreateAction(self, "CastSkillAction"),
		[gEventConstants.ENABLE_SEE_MOBILE_BUTTON] = self.CreateAction(self, "EnableSeeMobileButton"),
		[gEventConstants.MIND_POWER_CHANGE] = self.CreateActionWithArgs(self, "OnInteractChange", true),
		[gEventConstants.ENEMY_INTERACT_CHANGE] = self.CreateActionWithArgs(self, "OnInteractChange", false),
		[gEventConstants.PAOKU_STATE_CHANGE] = self.CreateAction(self, "OnParkourStateChange"),
		[gEventConstants.UPDATE_BTN_SPRITE_IN_AIR] = self.CreateAction(self, "OnUpdateBtnSpriteInAir"),
		[gEventConstants.NOTIFY_CHANGE_SKILL_RESOURCE] = self.CreateAction(self, "OnSkillResourceChanged"),
		[gEventConstants.CHANGE_MY_UNIT] = self.CreateAction(self, "OnSpiritChange"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide"),
		[gEventConstants.WEAPON_CHANGED] = self.CreateAction(self, "OnWeaponChange"),
		[gEventConstants.ON_BATTLE_BTN_EVENT] = self.CreateAction(self, "OnBattlePanelBtnEvent"),
		[gEventConstants.ON_UPDATE_BASIC_SKILL] = self.CreateActionWithArgs(self, "UpdateBasicSkills", 1),
		[gEventConstants.SUMMON_STATE_SWITCH] = self.CreateAction(self, "RefreshSwitchToAndriodsBtnState"),
		[gEventConstants.NOTIFY_CAN_BE_COUNTER] = self.CreateAction(self, "OnPerfectBlockEvent"),
		[gEventConstants.ON_RANGED_WEAPON] = self.CreateAction(self, "OnChangeWeaponType"),
		[gEventConstants.UNIT_CHANGE_FASHION] = self.CreateAction(self, "RefreshPlayerFashionData"),
		[gEventConstants.ON_HIGH_OBSTACLE] = self.CreateAction(self, "OnHighObstacle"),
		[gEventConstants.WEAPON_DURABILITY_CHANGE] = self.CreateAction(self, "CheckWeaponDurability"),
		[gEventConstants.CURRENT_SPIRIT_WEAPON_CHANGE] = self.CreateAction(self, "OnCurrentWeaponChange"),
		[gEventConstants.SETTING_CONTROLLER_TYPE_CHANGE] = self.CreateAction(self, "OnControllerSettingChange"),
		[gEventConstants.MIND_COUNTER_ATTACK_ENABLE_CHANGED] = self.CreateAction(self, "OnMindCounterAttack"),
		[gEventConstants.QTE_VISUAL_TIER_CHANGE] = self.CreateAction(self, "OnQteVisualTierChange"),
		[gEventConstants.TASK_WORKACTION_MOBILE_VX] = self.CreateAction(self, "OnWorkActionVxChange"),
		[gEventConstants.SYNC_REFRESH_BASIC_SKILL] = self.CreateAction(self, "SyncRefreshBasicSkills"),
		[gEventConstants.ON_UPDATE_SKILL_BTN] = self.CreateAction(self, "UpdateSkillBtns"),
		[gEventConstants.SYNC_REFRESH_FIGHT_SKILL] = self.CreateAction(self, "UpdateFightSpiritBigSkill"),
		[gEventConstants.ON_UPDATE_SKILL_CD] = self.CreateAction(self, "UpdateSkillCD"),
		[gEventConstants.ON_REFRESH_ULT_EP] = self.CreateAction(self, "UpdateUltCdAndEp"),
		[gEventConstants.HACK_SUMMON_QUERY_CHANGED] = self.CreateAction(self, "OnSwitchControlChanged"),
		[gEventConstants.SPIRIT_INFO_CHANGED] = self.CreateAction(self, "OnSpiritInfoChanged"),
		[gEventConstants.ON_YINGLONG_BARRIER] = self.CreateAction(self, "OnYingLongBarrier"),
		[gEventConstants.ENTER_HIDE_AND_SEEK] = self.CreateAction(self, "OnEnterHideAndSeek"),
		[gEventConstants.ON_SHOW_UI_EFFECT] = self.CreateAction(self, "OnShowUIEffect"),
		[gEventConstants.UI_VISIBLE_MODE_CHANGE] = self.CreateAction(self, "OnUIVisibleModeChange"),
		[gEventConstants.BULLET_ITEM_CHANGED] = self.CreateAction(self, "OnBulletItemChanged"),
		[gEventConstants.CROSSHAIR_SHOW_WHEN_FIRE_REFRESH] = self.CreateAction(self, "OnCrosshairShowWhenFireRefresh"),
		[gEventConstants.ON_NIGHT_VISION_STATE] = self.CreateAction(self, "OnNightVisionState"),
		[gEventConstants.ON_GAMEPLAY_TAG_UI_REFRESH] = self.CreateAction(self, "OnGameplayTagUIRefresh"),
		[gEventConstants.COMBAT_ART_NOTIFY] = self.CreateAction(self, "OnCombatArtNotifyChanged"),
		[gEventConstants.ON_INTERACTION_TYPE_CHANGE] = self.CreateAction(self, "OnInteractionTypeChange"),
		[gEventConstants.SETTING_ULT_BUTTON_TO_R2_CHANGE] = self.CreateAction(self, "RefreshControllerShotByUltR2")
	}
	self.dataSetEvents = {
		{
			gPlayerManager.main.bindData,
			"\\xee\\x89<\\xe5\\xd6\\xfd\\x8d\\xff\\xa3)%",
			self.CreateAction(self, "UpdateMindPowerBtn")
		},
		{
			gPlayerManager.main.bindData,
			"\\xee\\x89<\\xe5\\xd6\\xfd\\x8d\\xff\\xa3)%",
			self.CreateActionWithArgs(self, "UpdateBasicSkills", 1)
		},
		{
			gCoreHudUIManager.battleHudAutoHideState,
			"5\\x92䧢Ǩ\\x98\\x89\\xc9\\xf6>ù4\\x8d\\xee",
			self.CreateAction(self, "UpdateMobileOnBattleCtrl")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Normal,
			self.CreateAction(self, "UpdatePCAndGamepadBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Basic,
			self.CreateAction(self, "UpdatePCAndGamepadBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.UltSkill,
			self.CreateAction(self, "UpdatePCAndGamepadBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.ControlPower,
			self.CreateAction(self, "UpdateSkillBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.HeavyAttack,
			self.CreateAction(self, "UpdatePCAndGamepadBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.SwitchWeaponWheels,
			self.CreateAction(self, "UpdateSwitchWeaponWheelsState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Hold_Q,
			self.CreateAction(self, "UpdateBtnHoldState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Hold_R,
			self.CreateAction(self, "UpdateBtnHoldState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Hold_Left,
			self.CreateAction(self, "UpdateBtnHoldState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Dodge,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.JumpJump,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.OffWall,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Dive,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.DiveDash,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.DiveUp,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.KickOff,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.RightBottom,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.BattleUI,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.BulletChange,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.ProfessionalSkill,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.ResetVehicle,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Umbrella,
			self.CreateAction(self, "UpdateBtnDataSetState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.SkyDiving,
			self.CreateAction(self, "UpdateBtnDataSetState")
		}
	}

	self.ClearDataSetEvents(self)
	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.SyncRefreshBasicSkills = function(self, eventId, index)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("CoreHudCharacterControlStore.SyncRefreshBasicSkills")
	end

	self.UpdateBasicSkills(self, index)
	self.UpdateControlPowerSkill(self)
	self.UpdateHeavyAttackBtn(self)
	self.UpdateFightSpiritBigSkill(self)

	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.Normal] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.Basic] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.ControlPower] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.HeavyAttack] = true

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.UpdateBasicSkills = function(self, index)
	local templateId = 0
	local normalSkillId, basicSkillId = gCS.BattleManager.GetNormalAndBasicSkill(0, 0)

	for i = 1, 2 do
		local notExcute = index == nil and index == i

		if not notExcute then
			local skillId = i ~= 1 and normalSkillId or basicSkillId
			local cfgSkill = SkillConfig.GetConfig(skillId)
			local cfgImageId = gBattleMgr:GetNormalSkillImg(cfgSkill)

			if i ~= 1 then
				self:UpdateNormalText(cfgImageId)

				if not gBattleMgr:UsePCBattleHUD() then
					if gBattleMgr.showBaoShuaiHint or gBattleMgr.showCombatArtHint then
						if gBattleMgr.showBaoShuaiHint then
							cfgImageId = gCoreHudImgManager.imgBaoShuaiId or cfgImageId
						end

						local ani = self.goSkills[i].clickRedAni

						if not ani then
							return
						end

						ani.gameObject:SetActive(true)
					else
						local ani = self.goSkills[i].clickRedAni

						if not ani then
							return
						end

						ani.gameObject:SetActive(false)
					end
				end
			end

			if i ~= 2 then
				cfgImageId = gBattleMgr:GetBasicSkillImg(cfgSkill)
				self.isBasicNoSkillId = skillId ~= 0

				self:CheckChangeBtnMode()
			end

			gCoreHudTipManager:UpdateBtnIconState(i, gCoreHudTipManager.conditionType.Default, cfgImageId)

			if i ~= gBattleMgr.SkillBtnType.Normal then
				local flag, textId, higtLight = nil
				flag, textId, higtLight = gCoreHudUIManager:GetNormalSkillText()
				self.normalSkillBtn.qteVxCtrl = higtLight and 1 or 0
			end

			gBattleMgr:SetSkillData(i, skillId, cfgImageId, false)
			gBattleMgr:SetComboSkill(i, templateId, skillId)
			gMainMenuMgr:ForbidSkillBtnByNoSkillId(i, skillId ~= 0)
		end
	end
end

M.UpdateNormalText = function(self, cfgImageId)
	local finalText = -1

	if cfgImageId ~= gCoreHudImgManager.imgAssIconId then
		finalText = 247
	elseif cfgImageId ~= gCoreHudImgManager.imgFeiSuoAttackId then
		finalText = 662
	end

	gCoreHudTipManager:UpdateBtnTextSpecial(gCoreHudTipManager.btnInfoEnum.NormalAttack, gCoreHudTipManager.conditionType.Special, finalText)
end

M.UpdateControlPowerSkill = function(self, force)
	if not gCS.MyPlayerManager.PlayerUnit then
		print_error("[CoreHudCharacterControlStore] UpdateControlPowerSkill PlayerUnit is nil")

		return
	end

	gMainMenuMgr:CheckNoPowerState()
	gMainMenuMgr:CheckInCrouchAssassination()

	local skillId = gCS.MindPowerMgr:GetBattleFightControlPowerSkill()

	if not force and gBattleMgr.skillData[gBattleMgr.SkillBtnType.ControlPower] == nil and gBattleMgr.skillData[gBattleMgr.SkillBtnType.ControlPower].skillId ~= skillId then
		return
	end

	local cfgSkill = SkillConfig.GetConfig(skillId)
	local cfgImageId = gBattleMgr:GetMindPowerImg(cfgSkill)

	gCoreHudTipManager:UpdateBtnIconState(gCoreHudUIManager.skillType.ControlPower, gCoreHudTipManager.conditionType.Default, cfgImageId)
	gBattleMgr:SetSkillData(gBattleMgr.SkillBtnType.ControlPower, skillId, cfgImageId, false)
	gBattleMgr:SetComboSkill(gBattleMgr.SkillBtnType.ControlPower, 0, skillId)
end

M.UpdateFightSpiritBigSkill = function(self)
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
	self.isUltSkill = cfgSkill and cfgSkill.SkillCastTypeTag ~= SkillConfig.SkillCastTypeTagType.Unique or false

	gCoreHudTipManager:UpdateBtnIconState(3, gCoreHudTipManager.conditionType.Default, cfgImageId)
	gBattleMgr:SetSkillData(gBattleMgr.SkillBtnType.FightSpiritBigSkill, skillId, cfgImageId, false)
	gBattleMgr:SetComboSkill(gBattleMgr.SkillBtnType.FightSpiritBigSkill, 0, skillId)

	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = true

	gMainMenuMgr:ForbidSkillBtnByNoSkillId(gBattleMgr.SkillBtnType.FightSpiritBigSkill, skillId ~= 0)

	local canUseBigSkill = gBattleMgr:CheckCanShowUniqueSkillInfo(skillId)
	self.bigSkillBtn.energyCtrl = canUseBigSkill and 1 or 0

	gBattleMgr:RefreshFightSpiritUniqueSkillEnergy()

	if isFull and canUseBigSkill then
		local isCDFinished = gCS.BattleManager.IsCDFinished(skillId)
		self.aniControlDazhaos[index] = isCDFinished

		self.SwitchFightSpiritEpFull(self, false, isCDFinished)
	else
		self.aniControlDazhaos[index] = false

		self.SwitchFightSpiritEpNoFull(self)
	end

	self.isWaitforTweens = {}
end

M.CheckIsClimbRun = function(self)
	self.isClimbRun = gCS.PaoKuManager.ParkourStateLua ~= ActionTransitionRuleTypesConfig.ParkourStateType.ClimbRun

	self:CheckShowDropDownBtnTips()
end

M.SetCanPedalOut = function(self, enable)
	self.canWallPedalOut = enable

	self.CheckShowDropDownBtnTips(self)
end

M.SetCanPedalUp = function(self, enable)
	self.canWallPedalUp = enable

	self.CheckShowDropDownBtnTips(self)
end

M.SetCanPedalJumpOut = function(self, enable)
	self.canWallNormalJumpOut = enable

	self.CheckShowDropDownBtnTips(self)
end

M.CheckShowDropDownBtnTips = function(self)
	if not self.characterControlData then
		return
	end

	local enable = false
	local nameIdX = self.dropDownBtnNameId or 0
	local jumpBtnEnable = false
	local nameId = self.jumpBtnNameId or 0

	if gPlayerManager.main.bindData.isFreeClimbing then
		enable = gPlayerManager.main.bindData.isFreeClimbing
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

	if self.jumpBtnEnable == jumpBtnEnable or self.jumpBtnNameId == nameId then
		self.jumpBtnEnable = jumpBtnEnable
		self.jumpBtnNameId = nameId

		gBattleMgr:CheckShowBtnTips(self.characterControlData.jumpSwingBtn, jumpBtnEnable, nameId)

		if self.bindData.gamePadArea then
			self.bindData.gamePadArea:SetButtonInfoTipNameId(nameId, 1)
			self.bindData.gamePadArea:SetButtonInfoTipShowTip(jumpBtnEnable, 1)
		end
	end
end

M.UpdateFightSpiritBigSkillEnergy = function(self, fill)
	self.bigSkillBtn.energyBg = fill
	self.bigSkillBtn.energyRing = fill
end

M.SwitchFightSpiritEpFull = function(self, playOpenAni, isCDFinished)
	gMainMenuMgr:SetFightSpiritEpFull(true)
	gBattleMgr:SetColorToSImage(self.bigSkillBtn.ultColorCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filled))
	gBattleMgr:SetColorToSImage(self.bigSkillBtn.ultRingCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filled))

	if not isCDFinished then
		return
	end

	if playOpenAni then
		self.PlayBigSkillColorAni(self)
	else
		self.PlayEndBigSkillColorAni(self)
	end
end

M.SwitchFightSpiritEpNoFull = function(self)
	gMainMenuMgr:SetFightSpiritEpFull(not self.isUltSkill)
	gBattleMgr:SetColorToSImage(self.bigSkillBtn.ultColorCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filling))
	gBattleMgr:SetColorToSImage(self.bigSkillBtn.ultRingCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filling))
	self:CloseBigSkillColorAni()

	if not gBattleMgr:UsePCBattleHUD() and self.bigSkillBtn.bigSkillLoopAni then
		self.bigSkillBtn.bigSkillLoopAni.gameObject:SetActive(false)
	end
end

M.UpdateFightEp = function(self, templateId, currentEp, maxEp)
	local fillValue = currentEp / maxEp
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

	self.UpdateFightSpiritBigSkillEnergy(self, fillValue)

	if fillValue > 1 and not self.aniControlDazhaos[index] then
		local isCDFinished = gCS.BattleManager.IsCDFinished(skillId)
		self.aniControlDazhaos[index] = isCDFinished

		if canUseBigSkill then
			if self.bigSkillBtn then
				self.bigSkillBtn.energyCtrl = 2
			end

			self.SwitchFightSpiritEpFull(self, true, isCDFinished)
		end
	elseif fillValue >= 1 and self.aniControlDazhaos[index] then
		if self.bigSkillBtn then
			self.bigSkillBtn.energyCtrl = canUseBigSkill and 1 or 0
		end

		self.aniControlDazhaos[index] = false

		self.SwitchFightSpiritEpNoFull(self)
	end
end

M.UpdateHeavyAttackBtn = function(self)
	local templateId = 0
	local skillId = gBattleMgr:GetHeavyAttackSkillId()
	local skillType = gBattleMgr.SkillBtnType.HeavyAttack
	local cfgSkill = SkillConfig.GetConfig(skillId)
	local cfgImageId = gBattleMgr:GetHeavyAttackImg(cfgSkill)

	gCoreHudTipManager:UpdateBtnIconState(skillType, gCoreHudTipManager.conditionType.Default, cfgImageId)
	gBattleMgr:SetSkillData(skillType, skillId, cfgImageId, false)
	gBattleMgr:SetComboSkill(skillType, templateId, skillId)
	gMainMenuMgr:ForbidSkillBtnByNoSkillId(gBattleMgr.SkillBtnType.HeavyAttack, skillId ~= 0)
end

M.OnUpdateBtnSpriteInAir = function(self, eventId, isInAir)
	self.UpdateBtnSpriteInAir(self, isInAir)
end

M.UpdateBtnSpriteInAir = function(self, isInAir, force)
	local canSwing = gCoreHudUIManager.airDashState.hasBuff and gCoreHudUIManager.airDashState.systemBattleUnlock
	local isInFeisuo = gPlayerManager.main.bindData.isInFeisuo
	local canCurFeisuoShow = not gFeisuoUIUpdateMgr.HideUI or gGadgetManager.FeiSuoTarget and not gCoreHudUIManager.dodgeState.isGuideOpen

	if gCS.MyPlayerManager.PlayerUnit then
		canCurFeisuoShow = canCurFeisuoShow and gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.GadgetFeiSuo)
	end

	local isSwing = isInAir and canSwing and not isInFeisuo and canCurFeisuoShow
	local jumpSpriteName = isSwing and gCoreHudImgManager.imgSwingInAirId or gCoreHudImgManager.imgJumpOnGroundId

	if self.jumpSpriteName == jumpSpriteName then
		gCoreHudTipManager:UpdateBtnIconState(gCoreHudTipManager.btnInfoEnum.JumpJump, gCoreHudTipManager.conditionType.Environment, jumpSpriteName)
		gCoreHudTipManager:UpdateBtnTextSpecial(gCoreHudTipManager.btnInfoEnum.JumpJump, gCoreHudTipManager.conditionType.Environment, isSwing and 658 or -1)

		self.jumpSpriteName = jumpSpriteName
	end

	local newShowSwingJoystick = jumpSpriteName ~= gCoreHudImgManager.imgSwingInAirId and self.needShowSwingJoyStick

	if self.isShowSwingJoyStick == newShowSwingJoystick then
		self.SetShowJumpSwingJoystick(self, newShowSwingJoystick)
	end

	if self.isInAir == isInAir or force then
		self:UpdateNormalSkillImage()
		gMainMenuMgr:SetAirDashVisiable(isInAir)

		self.isInAir = isInAir

		self:UpdateAdaptiveTrigger(gPlayerManager.infoSpirit.bindData.currentWeapon)
	end
end

M.UpdateSkillCD = function(self, eventId, skillId)
	for i = gBattleMgr.SkillBtnType.Normal, gBattleMgr.SkillBtnType.HeavyAttack do
		local skillData = gBattleMgr.skillData[i]

		if skillData and skillData.skillId == 0 and gBattleMgr:IsBtnContainSkillId(skillData.skillId, skillId) then
			self.isUpdateSkillBtns[i] = true
		end
	end

	local fightList = gBattleSpiritMgr:GetBattleSpiritList()

	if fightList then
		for i, spiritData in pairs(fightList) do
			local uniqueSkill = gCS.BattleManager.GetUniqueSkillId(spiritData.pid)

			if uniqueSkill ~= skillId then
				self.isUpdateSpirit = true
			end
		end
	end
end

M.UpdateUltCdAndEp = function(self, eventId, data)
	if gCS.MyPlayerManager.PlayerUnit.ClientData.cardId ~= 15022030 or not data or not data.skillId or not data.curValue or not data.maxValue then
		return
	end

	self.UpdateSkillCD(self, _, data.skillId)
	self.UpdateFightEp(self, gBattleSpiritMgr.currentSpiritTemplateId, data.curValue, data.maxValue)
end

M.UpdateSkillBtns = function(self)
	for i = 1, #self.goSkills do
		if self.isUpdateSkillBtns[i] then
			self.UpdateSkill(self, i)
		end
	end
end

M.UpdateSkill = function(self, index)
	if index ~= gBattleMgr.SkillBtnType.Normal then
		return
	end

	if self.CheckUpdateChangeSkillCountDownTime(self, index) then
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
	local isShowCD = not isHide and labelTimeLeft >= 0

	self:UpdateSkill_MultiUseSkill(index, objs, comboData, isShowCD, maxCharges, curCharges, fillAmount, labelTimeLeft)

	if maxCharges < 1 then
		if comboData.check then
			self.UpdateSkill_MultiPhase(self, index, objs, cdData, comboData)
		else
			self.UpdateSkill_Normal(self, index, objs, cdData, isShowCD, fillAmount, labelTimeLeft)
		end
	end
end

M.UpdateSkill_MultiUseSkill = function(self, index, objs, comboData, isShowCD, maxCharges, curCharges, fillAmount, labelTimeLeft)
	if maxCharges <= 1 then
		objs.skillTypeCtrl = 2
		local cdActive = isShowCD

		if cdActive then
			if curCharges ~= 0 then
				self:SetBtnInCd(index, objs, 1)

				objs.multiChrageCDCtrl = 0
				objs.cdTime = labelTimeLeft > 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
				objs.cdCover = gBattleMgr.useV1hud and gCoreHudUIManager.isNonMobileAdaptive and fillAmount or 1 - fillAmount
			else
				self.SetBtnInCd(self, index, objs, 0)

				objs.multiChrageCDCtrl = 2
				objs.multiChargeCounts = curCharges
				objs.multiChargeCd = 1 - fillAmount
			end
		else
			self.SetBtnInCd(self, index, objs, 0)

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

	gMainMenuMgr:SetBattleSkillBtnIsInCd(index, objs.btnInCDCtrl ~= 1)
end

M.UpdateSkill_MultiPhase = function(self, index, objs, cdData, comboData)
	objs.skillTypeCtrl = 1

	if not cdData.isUseLianzhaoIamge then
		cdData.isUseLianzhaoIamge = true

		gCoreHudTipManager:UpdateBtnIconState(index, gCoreHudTipManager.conditionType.MultiPhase, comboData.shortImageId)
	end

	if gLogicTime.time >= comboData.t3 then
		local fill = (comboData.t3 - gLogicTime.time) / (comboData.t3 - comboData.t0)
		objs.multiPhaseRing = fill
	end

	self.isUpdateSkillBtns[index] = true
end

M.UpdateSkill_Normal = function(self, index, objs, cdData, isShowCD, fillAmount, labelTimeLeft)
	objs.skillTypeCtrl = 0

	if cdData.isUseLianzhaoIamge then
		cdData.isUseLianzhaoIamge = false

		gCoreHudTipManager:UpdateBtnIconState(index, gCoreHudTipManager.conditionType.MultiPhase, cdData.normalImage)
	end

	if isShowCD then
		objs.cdCover = gBattleMgr.useV1hud and gCoreHudUIManager.isNonMobileAdaptive and fillAmount or 1 - fillAmount
		objs.cdTime = labelTimeLeft > 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
		self.isUpdateSkillBtns[index] = true
		self.isWaitforTweens[index] = true
	elseif self.isWaitforTweens[index] then
		self.isWaitforTweens[index] = false

		if index ~= gBattleMgr.SkillBtnType.FightSpiritBigSkill then
			local fightSpiritIndex = 1
			local skillId = gCS.BattleManager.GetUniqueSkillId()

			if gBattleMgr:IsSkillFightResourceEnough(gCS.MyPlayerManager.PlayerUnit, skillId) then
				self.aniControlDazhaos[fightSpiritIndex] = true

				self.PlayBigSkillColorAni(self)
			end
		elseif index == gBattleMgr.SkillBtnType.ControlPower then
			self:PlaySkillXuliAni(objs, index)

			if gBattleMgr:CheckBtnIsShow(objs.btnHideCtrl) then
				gSoundMgr:PlaySoundByTid(70601150)
			end
		end
	end
end

M.OpenChangeSkillCountDown = function(self, btnIndex, time)
	local data = {
		startTime = gLogicTime.time,
		duration = time
	}
	self.changeSkillCountDownData[btnIndex] = data
	self.isUpdateSkillBtns[btnIndex] = true
end

M.CloseChangeSkillCountDown = function(self, btnIndex)
	local obj = self.goSkills[btnIndex]
	obj.skillTypeCtrl = 0
	self.changeSkillCountDownData[btnIndex] = nil
	self.isUpdateSkillBtns[btnIndex] = true
end

M.CheckUpdateChangeSkillCountDownTime = function(self, index)
	local data = self.changeSkillCountDownData[index]

	if self.changeSkillCountDownData[index] then
		local endTime = data.startTime + data.duration
		local obj = self.goSkills[index]

		if gLogicTime.time >= endTime then
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

M.UpdateBtn_MultiUseBtn = function(self, btn, isShowCD, curCharges, maxCharges, fillAmount, labelTimeLeft)
	if maxCharges <= 1 then
		btn.skillTypeCtrl = 2
		local cdActive = isShowCD

		if cdActive then
			if curCharges ~= 0 then
				self:SetBtnInCd(0, btn, 1)

				btn.multiChrageCDCtrl = 0
				btn.cdTime = labelTimeLeft > 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
				btn.cdCover = gBattleMgr.useV1hud and gCoreHudUIManager.isNonMobileAdaptive and fillAmount or 1 - fillAmount
			else
				self.SetBtnInCd(self, 0, btn, 0)

				btn.multiChrageCDCtrl = 2
				btn.multiChargeCounts = curCharges
				btn.multiChargeCd = 1 - fillAmount
			end
		else
			self.SetBtnInCd(self, 0, btn, 0)

			btn.multiChrageCDCtrl = 1
			btn.multiChargeCounts = curCharges
			btn.multiChargeReaCounts = curCharges
			btn.multiChargeCd = 1 - fillAmount
		end
	else
		btn.skillTypeCtrl = 0

		self:SetBtnInCd(0, btn, isShowCD and 1 or 0)

		btn.cdTime = labelTimeLeft > 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
		btn.cdCover = gBattleMgr.useV1hud and gCoreHudUIManager.isNonMobileAdaptive and fillAmount or 1 - fillAmount
	end
end

M.SystemUnlockStateChange = function(self, eventId, data)
	local isUnlock = gSystemUnlockMgr:IsUnlock(data)

	if SystemUnlockConfig.TaFeiBattleUnlock ~= data then
		gMainMenuMgr:ShowSkillBtn(isUnlock)
	elseif SystemUnlockConfig.SummonSpiritWheel ~= data then
		gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.JiaMuSummon, "systemBattleUnlock", isUnlock)
	elseif SystemUnlockConfig.CharEnergyBar ~= data then
		gMainMenuMgr:SetWeaponFightResBySystemUnlock(isUnlock)
	end
end

M.OnRefreshFeiSuo = function(self)
end

M.OnWeaponChange = function(self, eventId, data)
	if ulong.equals(data.pid, gCS.MyPlayerManager.PlayerUnitId) then
		self.UpdateByWeaponRefresh(self)
	end
end

M.RefreshBtnTipStatus = function(self)
	gCoreHudTipManager:UpdateBtnTipAllWeaponState()

	if not gCoreHudUIManager.isNonMobileAdaptive then
		return
	end

	if not self.characterControlData.holdLeftBtn or not self.characterControlData.holdQBtn or not self.characterControlData.holdRBtn then
		return
	end

	local holdLeftVisible = false
	local holdQVisible = false
	local holdRVisible = false
	local fightStyleId = gCS.FightStyleManager.Instance:GetCurrentWeaponFightStyleId()

	if fightStyleId then
		local fightSkillConfig = LTConfig.FightSkillConfig.GetConfig(fightStyleId)

		if fightSkillConfig then
			holdQVisible = fightSkillConfig.LongPressQSkill >= 0
			local pressinSkilltype = fightSkillConfig.PressinSkilltype

			for i = 1, #pressinSkilltype do
				local value = pressinSkilltype[i]

				if value ~= LTConfig.FightSkillConfig.PressinSkilltypeType.CommonAttack then
					holdLeftVisible = true
				elseif value ~= LTConfig.FightSkillConfig.PressinSkilltypeType.Unique then
					holdRVisible = true
				end
			end
		end
	end

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Hold_Q, "isWeaponHasSkill", holdQVisible)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Hold_R, "isWeaponHasSkill", holdRVisible)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Hold_Left, "isWeaponHasSkill", holdLeftVisible)
end

M.EnableSeeMobileButton = function(self, eventId, message)
	self.seeMobileBtn.wordsCtrl = 1

	gBattleMgr:SetBtnFaraway(self.characterControlData.seeMobileBtn, message)

	self.seeMobileBtn.ignoreLayout = not message
end

M.SeeMobileButtonClick = function(self)
	local item = gCS.MindPowerMgr:GetAimItem()

	if item then
		item.TryEnterLookAtMobileFromMagnet(item)
	end
end

M.OnWalkBtnClick = function(self)
	if gUIUtils:IsInXinShouRaid() then
		return
	end

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.MotionFlagManager.ToggleIsOnWaling(gCS.MyPlayerManager.PlayerUnit)
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.WalkPress)
	end
end

M.OnControllerWeaponSwitchCircleBegin = function(self)
	if not gMainMenuMgr:CheckCanUseWeaponCircle() then
		return
	end

	self.weaponSliderTime = Time.time
end

M.OnWeaponCircleLongPressStart = function(self)
	if not gMainMenuMgr:CheckCanUseWeaponCircle() then
		return
	end

	gCoreHudUIManager:SetBattleHudWeaponWheelActivity(true)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):OpenCircle(gCircleType.WEAPON)
end

M.OnWeaponCircleLongPressEnd = function(self)
	gCoreHudUIManager:SetBattleHudWeaponWheelActivity(false)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):CloseCircle()
	self:ResetWeaponCircleControlSlider()
end

M.UpdateWeaponCircleControlSlider = function(self)
	if self.curActiveDevice > SGUI.GameDevice.KeyboardMouse or not self.ammunitionRoot or not self.ammunitionRoot.controlerSlider or not self.ammunitionRoot.controlerSlider.fill or not self.weaponSliderTime then
		return
	end

	local fill = Time.time - self.weaponSliderTime
	fill = fill * 5
	self.ammunitionRoot.controlerSlider.fill.fillAmount = fill
end

M.ResetWeaponCircleControlSlider = function(self)
	if self.curActiveDevice > SGUI.GameDevice.KeyboardMouse or not self.ammunitionRoot or not self.ammunitionRoot.controlerSlider or not self.ammunitionRoot.controlerSlider.fill then
		return
	end

	self.weaponSliderTime = nil
	self.ammunitionRoot.controlerSlider.fill.fillAmount = 0
end

M.OnWeaponBtnDragBegin = function(self, eventPointer)
	gStoreManager:GetStoreGroup("BackCircleWeaponStore"):OnDragMoveStart(eventPointer)
end

M.OnWeaponBtnDrag = function(self, eventPointer)
	gStoreManager:GetStoreGroup("BackCircleWeaponStore"):OnDragMove(eventPointer)
end

M.OnWeaponBtnDragEnd = function(self, eventPointer)
	gStoreManager:GetStoreGroup("BackCircleWeaponStore"):OnDragMoveEnd(eventPointer)
end

M.OnControllerWeaponSwitch = function(self)
	if not gMainMenuMgr:CheckCanUseWeaponCircle() then
		return
	end

	if self.rollerSwitchWeaponCd >= gLogicTime.time then
		self.rollerSwitchWeaponCd = gLogicTime.time + SceneitemConfig.WeaponMouseScrollCD

		self:PlayWeaponMouseScrollAni(false)

		local isSame, nextWeaponIndex = gWeaponManager:GetNextCircleWeapon(true)

		if not isSame then
			self:AskSwitchWeapon(nextWeaponIndex)
			gCoreHudUIManager:SetBattleHudWeaponWheelActivity(true)
			gCoreHudUIManager:SetBattleHudWeaponWheelActivity(false)
		end
	end
end

M.OnWeaponMouseScroll = function(self, context)
	if not gMainMenuMgr:CheckCanUseWeaponCircle() or not self.characterControlData.ammunitionRoot.interactable then
		return
	end

	if context.performed then
		local zoom = context.ReadValueVector2(context).y

		if self.rollerSwitchWeaponCd >= gLogicTime.time then
			self:PlayWeaponMouseScrollAni(zoom >= 0)

			self.rollerSwitchWeaponCd = gLogicTime.time + SceneitemConfig.WeaponMouseScrollCD
			local isSame, nextWeaponIndex = gWeaponManager:GetNextCircleWeapon(zoom <= 0)

			if not isSame then
				self:AskSwitchWeapon(nextWeaponIndex)
				gCoreHudUIManager:SetBattleHudWeaponWheelActivity(true)
				gCoreHudUIManager:SetBattleHudWeaponWheelActivity(false)
			end
		end
	end
end

M.PlayWeaponMouseScrollAni = function(self, isUp)
	if not gCoreHudUIManager.isNonMobileAdaptive then
		return
	end

	self.changeWeaponMode = isUp and ChangeWeaponMode.Up or ChangeWeaponMode.Down

	gSoundMgr:PlaySoundByTid(70650127)

	if isUp then
		local name = "S_Weapon_up_pc"
		slot3 = gBattleMgr

		slot3:CommonPlayAniTool(self.ammunitionRoot.scrollAni, name, 0, 1, true, function ()
			self.ammunitionRoot:Commit("weaponIconDown", self.ammunitionRoot.weaponIcon, COMMIT_IMMEDIATELY)

			self.changeWeaponMode = ChangeWeaponMode.None
		end)
	else
		local name = "S_Weapon_down_pc"
		slot3 = gBattleMgr

		slot3:CommonPlayAniTool(self.ammunitionRoot.scrollAni, name, 0, 1, true, function ()
			self.ammunitionRoot:Commit("weaponIcon", self.ammunitionRoot.weaponIconDown, COMMIT_IMMEDIATELY)

			self.changeWeaponMode = ChangeWeaponMode.None
		end)
	end
end

M.AskSwitchWeapon = function(self, index)
	gClientToGameSceneDelegate:AskSwitchWeapon(index)
end

M.OnKickOffBtnDown = function(self)
	self.PlaySkillBtnDownFanseAni(self, self.kickOffBtn)
	self.OnMergeBtnLongPressBegin(self, gBattleMgr.SkillBtnType.ControlPower)
end

M.OnKickOffBtnUp = function(self)
	self.PlaySkillBtnUpFanseAni(self, self.kickOffBtn)
	self.OnMergeBtnLongPressEnd(self, gBattleMgr.SkillBtnType.ControlPower)
end

M.OnProfessionSkillBtnDown = function(self)
	self:PlaySkillBtnDownFanseAni(self.professionSkillBtn)
	gBattleMgr:ClickProfessionSkill()
end

M.OnProfessionSkillBtnUp = function(self)
	self.PlaySkillBtnUpFanseAni(self, self.professionSkillBtn)
end

M.RefreshProfessionSkillBtnCD = function(self)
	if not self.needUpdateProfessionSkillBtnCD or self.professionSkillBtn.btnHideCtrl and self.professionSkillBtn.btnHideCtrl ~= 1 then
		return
	end

	local isShowCD = self.professionSkillBtnTimes <= self.maxProfessionSkillBtnTimes

	self:EnableProfessionSkillBtn(self.professionSkillBtnTimes < 1)

	local curCharge = math.floor(self.professionSkillBtnTimes)
	local cfg = LTConfig.SkillResourcesConfig.GetConfig(LTConfig.SkillResourcesConfig.DriveTimeScaleEnergy)
	local fill = 1 - self.professionSkillBtnTimes % 1
	local labelTimeLeft = fill * cfg.Interval

	self:UpdateBtn_MultiUseBtn(self.professionSkillBtn, isShowCD, curCharge, self.maxProfessionSkillBtnTimes, fill, labelTimeLeft)

	if self.professionSkillBtnTimes ~= self.maxProfessionSkillBtnTimes then
		self.needUpdateProfessionSkillBtnCD = false
	end
end

M.EnableProfessionSkillBtn = function(self, enable)
	if self.professionSkillBtn.interactable == enable then
		self.professionSkillBtn.interactable = enable

		gBattleMgr:PlayBtnFanseAni(self.professionSkillBtn, nil, enable)
	end
end

M.OnControllerL3Down = function(self)
	if not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.Dodge][2] or gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.IsProwlArea) then
		return
	end

	gCS.MotionFlagManager.SetTempMotionFlag(gCS.MyPlayerManager.PlayerUnit, 9)
end

M.OnControllerL3Up = function(self)
	if not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.Dodge][2] or gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.IsProwlArea) then
		return
	end

	gCS.MotionFlagManager.ClearTempMotionFlag(gCS.MyPlayerManager.PlayerUnit)
end

M.OnControllerGunNorthBeginLongPress = function(self)
	if not gCoreHudUIManager:GetBattleSkillInteractable(gCoreHudUIManager.skillType.UltSkill) then
		return
	end

	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.FightSpiritBigSkill, true)
	self:PlaySkillBtnDownFanseAni(self.goSkills[gBattleMgr.SkillBtnType.FightSpiritBigSkill])

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.FightSpiritBigSkill)
end

M.OnControllerGunNorthLongPress = function(self)
	if not self.CheckSkillBtnIsEnable(self, gBattleMgr.SkillBtnType.Basic) then
		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Basic] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.Basic)
end

M.OnControllerGunNorthLongPressEnd = function(self)
	self.OnMergeBtnLongPressEnd(self, gBattleMgr.SkillBtnType.Basic)
	self.OnMergeBtnLongPressEnd(self, gBattleMgr.SkillBtnType.FightSpiritBigSkill)
end

M.OnControllerGunWestBeginLongPress = function(self)
	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.Basic, true)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.Basic) then
		return
	end

	self.PlaySkillBtnDownFanseAni(self, self.goSkills[gBattleMgr.SkillBtnType.Basic])

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Basic] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Basic)
end

M.OnControllerGunWestLongPress = function(self)
end

M.OnControllerGunWestLongPressEnd = function(self)
	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.Basic, false)

	if not self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Basic] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Basic] = false

	self.PlaySkillBtnUpFanseAni(self, self.goSkills[gBattleMgr.SkillBtnType.Basic], gBattleMgr.SkillBtnType.Basic)

	if not self.CheckSkillBtnIsEnable(self, gBattleMgr.SkillBtnType.Basic) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Basic)
end

M.OnControllerShootBeginLongPress = function(self)
	if not gCoreHudUIManager.isHoldRangedWeapon or self.normalSkillBtn and not self.normalSkillBtn.interactable then
		return
	end

	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.Normal, true)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.Normal) then
		return
	end

	self.PlaySkillBtnDownFanseAni(self, self.goSkills[gBattleMgr.SkillBtnType.Normal])

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Normal] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
end

M.OnControllerShootLongPress = function(self)
	if not self.CheckSkillBtnIsEnable(self, gBattleMgr.SkillBtnType.Normal) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.Normal)
end

M.OnControllerShootLongPressEnd = function(self)
	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.Normal, false)

	if not gCoreHudUIManager.isHoldRangedWeapon then
		return
	end

	if not self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Normal] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.Normal] = false

	self.PlaySkillBtnUpFanseAni(self, self.goSkills[gBattleMgr.SkillBtnType.Normal], gBattleMgr.SkillBtnType.Normal)

	if not self.CheckSkillBtnIsEnable(self, gBattleMgr.SkillBtnType.Normal) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Normal)
end

M.OnControllerSwingPress = function(self)
	self.pressControllerSwingDown = true

	if gCS.LuaUtils.CanSwing() then
		gCS.TransitionMgr.isPressingSwingDown = true
		gCS.TransitionMgr.pressingSwingDownTime = gLogicTime.time
	end
end

M.OnControllerSwingRelease = function(self)
	self.pressControllerSwingDown = false

	if not self.pressJumpKeyDown then
		gCS.TransitionMgr.isPressingSwingDown = false
		gCS.TransitionMgr.pressingSwingDownTime = 0
	end
end

M.OnSwitchToAndriodsBtnClick = function(self)
	if gBattleMgr.SummonAgentId and ulong.Greater(gBattleMgr.SummonAgentId, 0) and self.switchControlEnable then
		gClientToGameSceneDelegate:AskControlAgent(gBattleMgr.SummonAgentId, UX.Game.SwitchControlReason.Client)
	end
end

M.RefreshSwitchToAndriodsBtnState = function(self, eventId, queryRes)
	local queryRes = queryRes ~= nil and gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.CanSwitchDogBot) or queryRes
	local needFaraway = ulong.LessEqual(gBattleMgr.SummonAgentId, 0) or not queryRes

	self.bindData.switchToAndriodsBtn:SetWidgetFaraway(needFaraway)
end

M.OnControllerAimBeginLongPress = function(self)
	if not gCoreHudUIManager.isHoldRangedWeapon or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.HeavyAttack, true)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Aim)
end

M.OnControllerAimLongPress = function(self)
	if not gCoreHudUIManager.isHoldRangedWeapon or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	if not self.CheckSkillBtnIsEnable(self, gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.Aim)
end

M.OnControllerAimLongPressEnd = function(self)
	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.HeavyAttack, false)

	if not gCoreHudUIManager.isHoldRangedWeapon or not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	if not self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] = false

	self.PlaySkillBtnUpFanseAni(self, self.goSkills[gBattleMgr.SkillBtnType.HeavyAttack], gBattleMgr.SkillBtnType.HeavyAttack)

	if not self.CheckSkillBtnIsEnable(self, gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Aim)
end

M.OnControllerBlockBeginLongPress = function(self)
	if not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] or gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.DisDefense) then
		return
	end

	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.HeavyAttack, true)

	if not self:CheckSkillBtnIsEnable(gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.HeavyAttack)
end

M.OnControllerBlockLongPress = function(self)
	if not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	if not self.CheckSkillBtnIsEnable(self, gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.HeavyAttack)
end

M.OnControllerBlockLongPressEnd = function(self)
	gCoreHudUIManager:SetBattleHudSkillActivity(gBattleMgr.SkillBtnType.HeavyAttack, false)

	if not gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.HeavyAttack][2] then
		return
	end

	if not self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮已经触发过up了，可能是由于按钮禁用触发的，就不再触发up了")

		return
	end

	self.mergeBtnDownCache[gBattleMgr.SkillBtnType.HeavyAttack] = false

	self.PlaySkillBtnUpFanseAni(self, self.goSkills[gBattleMgr.SkillBtnType.HeavyAttack], gBattleMgr.SkillBtnType.HeavyAttack)

	if not self.CheckSkillBtnIsEnable(self, gBattleMgr.SkillBtnType.HeavyAttack) then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.HeavyAttack)
end

M.OnInteractChange = function(self, isMindPower, eventId, mindInteractCfgId)
	local mindInteractCfg = BattleEnemyInteractConfig.GetConfig(mindInteractCfgId)

	if mindInteractCfg then
		self.SetMindBtnPCKeyId(self, mindInteractCfg.MindButtonType, isMindPower)
	else
		self.SetMindBtnPCKeyId(self, 0, isMindPower)
	end

	self.mindInteractCfgId = mindInteractCfgId

	if not isMindPower then
		local skillTextId = mindInteractCfg and mindInteractCfg.SkillText or -1

		gCoreHudTipManager:UpdateBtnTextSpecial(gCoreHudTipManager.btnInfoEnum.KickOff, gCoreHudTipManager.conditionType.Environment, skillTextId)
	end
end

M.SetMindBtnPCKeyId = function(self, id, isMindPower)
	local keyId = 25
	local text = "Q"
	local isExecute = false

	if id ~= MindButtonTypeType.InteractBtn then
		keyId = 10
		text = "F"
	elseif id ~= MindButtonTypeType.NormalSkillBtn then
		keyId = 8
		text = ""
	elseif id ~= MindButtonTypeType.ExecuteBtn then
		isExecute = true
		keyId = 10
		text = "F"
	elseif id ~= MindButtonTypeType.EBtn then
		keyId = 26
		text = "E"
	elseif id ~= MindButtonTypeType.MouseRight then
		keyId = 9
		text = ""
	end

	if gMainMenuMgr.ShowTestMsg then
		print_debug("SetMindBtnPCKeyId id:", id, " keyId:", keyId, " text:", text, " isExecute:", isExecute, " isMindPower:", isMindPower)
	end

	local lastKeyId = isMindPower and self.mindPowerKeyId_Mind or self.mindPowerKeyId_Enemy
	local lastIsExecute = isMindPower and self.isExecute_Mind or self.isExecute_Enemy

	if lastKeyId == keyId or lastIsExecute == isExecute then
		if self.mergeBtnDownCache[gBattleMgr.SkillBtnType.ControlPower] then
			self.OnMergeBtnLongPressEnd(self, gBattleMgr.SkillBtnType.ControlPower)
		end

		local hintStore = gStoreManager:GetStoreGroup("HintInfosHudStore")

		if isMindPower then
			hintStore.SetClickPCText(hintStore, text)
			hintStore.SetMindIcon(hintStore, id)
		else
			self:UpdateKickOffBtn(id)
			gMainMenuMgr:RefreshEnemyMindInteractBtn(id)

			slot9 = gMainMenuMgr
			slot11 = slot9
			slot9 = slot9.SetKickOffBtnVisiable
			slot12 = id ~= MindButtonTypeType.InteractBtn or id ~= MindButtonTypeType.ExecuteBtn

			slot9(slot11, slot12)
			hintStore.RefreshClickPCText(hintStore, text)
			hintStore.RefreshMindIcon(hintStore, id)
			hintStore.ShowOrHideExecuteHint(hintStore, isExecute)
		end
	end

	if isMindPower then
		self.isExecute_Mind = isExecute
		self.mindPowerKeyId_Mind = keyId
		self.mindBtnType = id
	else
		self.isExecute_Enemy = isExecute
		self.mindPowerKeyId_Enemy = keyId
		self.mindBtnType_Interact = id
		self.isExecute = isExecute
	end
end

M.UpdateKickOffBtn = function(self, id)
	local iconId = GameConfig.KickOffBtnIcon

	if id ~= MindButtonTypeType.ExecuteBtn then
		iconId = GameConfig.ExecuteBtnIcon
	end

	self.kickOffBtn.vxIconId = iconId
	self.kickOffBtn.iconId = iconId
end

M.CheckNeedPlayFanseAni = function(self, btn)
	if btn and (not btn.btnInCDCtrl or btn.btnInCDCtrl ~= 0) then
		return true
	end

	return false
end

M.PlaySkillBtnDownFanseAni = function(self, btn)
	if not self.CheckNeedPlayFanseAni(self, btn) then
		return
	end

	table.insert(self.btnFanseAniList, btn)

	local aniName = gBattleMgr:UsePCBattleHUD() and self.btnDownFanseAniPc or self.btnDownFanseAni

	gBattleMgr:CommonPlayAniTool(btn.btnFanseAni, aniName, 0, 1)
end

M.PlaySkillBtnUpFanseAni = function(self, btn, index, notPlayAni)
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

M.ClearBtnFanseAni = function(self, btn, index)
	if not table.contains(self.btnFanseAniList, btn) then
		return
	end

	table.removeEx(self.btnFanseAniList, btn)

	local aniName = gBattleMgr:UsePCBattleHUD() and self.btnUpFanseAniPc or self.btnUpFanseAni

	gBattleMgr:CommonStopAniTool(btn.btnFanseAni, aniName)
end

M.ClearAllBtnFanseAni = function(self)
	for i = #self.btnFanseAniList, 1, -1 do
		self.ClearBtnFanseAni(self, self.btnFanseAniList[i], 0)
	end
end

M.PlaySkillClickAni = function(self, index, btn)
	local ani = btn.specialBtnClickAni

	if not ani or index == gBattleMgr.SkillBtnType.Basic and index == gBattleMgr.SkillBtnType.FightSpiritBigSkill or gBattleMgr:UsePCBattleHUD() then
		return
	end

	local clpName = index ~= gBattleMgr.SkillBtnType.ControlPower and "s_vx_HudSkillBtn_click02" or "s_vx_HudSkillBtn_click"

	ani.gameObject:SetActive(true)
	gBattleMgr:CommonPlayAniTool(ani, clpName, 0, 1, true)
end

M.PlaySkillXuliAni = function(self, btn, index)
	btn.btnXuliAni.gameObject:SetActive(true)

	self.xuliBtnAniList[index] = true
	local aniName = gBattleMgr:UsePCBattleHUD() and self.xuliCdAniNamePc or "s_vx_HudSkillBtn_xuli_cd"

	gBattleMgr:CommonPlayAniTool(btn.btnXuliAni, aniName, 0, 1, true, function ()
		self.xuliBtnAniList[index] = false
	end)
end

M.ClearSkillXuliAni = function(self, btn, index)
	if not btn.btnXuliAni or self.xuliBtnAniList[index] then
		return
	end

	local aniName = gBattleMgr:UsePCBattleHUD() and self.xuliCdAniNamePc or "s_vx_HudSkillBtn_xuli_cd"

	gBattleMgr:CommonStopAniTool(btn.btnXuliAni, aniName)
end

M.PlayBigSkillColorAni = function(self)
	if gBattleMgr:UsePCBattleHUD() then
		gBattleMgr:CommonPlayAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNamePc, 0, 1)
	else
		gBattleMgr:CommonPlayAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNameM, 0, 1)
	end
end

M.PlayEndBigSkillColorAni = function(self)
	if gBattleMgr:UsePCBattleHUD() then
		gBattleMgr:CommonStopAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNamePc)
	else
		gBattleMgr:CommonStopAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNameM)
	end
end

M.CloseBigSkillColorAni = function(self)
	self:PlayEndBigSkillColorAni()

	if gBattleMgr:UsePCBattleHUD() then
		gBattleMgr:CommonPlayAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillCloseAniNamePc, 0, 1)
	else
		gBattleMgr:CommonPlayAniTool(self.bigSkillBtn.bigSkillColorAni, self.bigSkillCloseAniNameM, 0, 1)
	end
end

M.CheckSkillBtnIsEnable = function(self, data)
	if data ~= gBattleMgr.SkillBtnType.Basic and not self.goSkills[data].interactable then
		gBattleMgr:ShowMessageTipsOnEditor("技能按钮的collider被关闭了" .. data)

		return false
	end

	if data ~= gBattleMgr.SkillBtnType.ControlPower then
		local mindBtnType = self.mindBtnType
		local mindBtnType_Interact = self.mindBtnType_Interact

		if mindBtnType == 0 or mindBtnType_Interact == 0 then
			local flag = false

			if mindBtnType ~= MindButtonTypeType.NormalSkillBtn then
				flag = true

				if not self.goSkills[gBattleMgr.SkillBtnType.Normal].interactable then
					gBattleMgr:ShowMessageTipsOnEditor("技能按钮的collider被关闭了" .. gBattleMgr.SkillBtnType.Normal)

					return false
				end
			end

			if mindBtnType_Interact ~= MindButtonTypeType.InteractBtn or mindBtnType_Interact ~= MindButtonTypeType.ExecuteBtn then
				flag = true

				if self.kickOffBtn.interactable then
					gBattleMgr:ShowMessageTipsOnEditor("技能按钮的collider被关闭了" .. data)

					return false
				end
			end

			if not flag and not self.goSkills[data].interactable then
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

M.SetBtnInCd = function(self, index, btn, isInCD)
	if btn.btnInCDCtrl == isInCD then
		if btn.btnInCDCtrl ~= 0 then
			-- Nothing
		end

		btn.btnInCDCtrl = isInCD
	end
end

M.CastSkillAction = function(self, eventId, message)
	if not message.isMySkill or gBattleMgr.SummonInControl then
		return
	end

	local skillId = message.skillId
	local btnIndex = message.type

	if skillId ~= nil or btnIndex ~= nil or skillId > 0 or btnIndex < 0 then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("PlaySkillClickAni")
	end

	if gBattleMgr.skillData[btnIndex] and skillId ~= gBattleMgr.skillData[btnIndex].skillId then
		self.PlaySkillClickAni(self, btnIndex, self.goSkills[btnIndex])
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("OnCastSkillForDropWeapon")
	end

	if message and message.isDropWeaponSkill then
		self.suppressDropWeapon = true
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.ReplaceDodgeBtnToMindPower = function(self)
	local multiBtn = self.dodgeBtn.multiBtn

	if gBattleSwitch.ReplaceDodgeBtnToMindPower then
		multiBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressBegin", 4)
		multiBtn.luaLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPress", 4)
		multiBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnMergeBtnLongPressEnd", 4)
	else
		if self.heavyAttackBtn then
			return
		end

		multiBtn.luaPress = self.CreateActionWithArgs(self, "OnDodgeBtnPress", 2)
		multiBtn.luaRelease = self.CreateActionWithArgs(self, "OnDodgeBtnRelease", 2)
		multiBtn.luaClick = nil
		multiBtn.luaBeginLongPress = nil
		multiBtn.luaLongPress = nil
		multiBtn.luaEndLongPress = nil
	end
end

M.SetBtnVisible = function(self, btnStore, visible)
	self.mgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnInteractable = function(self, btnStore, interactable)
	self.mgr:SetButtonInteractableBase(btnStore, interactable)
end

M.SetBtnControl = function(self, btnStore, visible, interactable)
	self.mgr:SetButtonControlBase(btnStore, visible, interactable)
end

M.OnRightStickControl = function(self, context)
	if self.circleOpen then
		return
	end

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

M.OnCrosshairShowWhenFireRefresh = function(self)
	self.cachedShowShootCrossHair = gCS.MindPowerMgr.showShootCrossHair

	self.UpdateGamepadCamera(self)
end

M.UpdateGamepadCamera = function(self)
	local cameraConfigId = self.GetCameraConfigId(self)

	if self.lastCameraConfigId == cameraConfigId then
		self.lastCameraConfigId = cameraConfigId

		LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.CHARACTER_CONTROLS, cameraConfigId)
	end

	if self.needUpdateCamera and not self.circleOpen then
		if not gPanelManager:VisibleModeAll() then
			self.ClearGamepadCameraRotate(self)

			return
		end

		local cameraConfigId = self:GetCameraConfigId()

		gCameraUtils:DoRotateCameraByGamePad(cameraConfigId, self.rightStickValue.x, self.rightStickValue.y)
	end
end

M.GetCameraConfigId = function(self)
	if gCS.GunModule.IsMeInShoulderFire and not self.cachedShowShootCrossHair then
		return 2
	elseif self.cachedShowShootCrossHair then
		return 3
	else
		return 1
	end
end

M.OnCameraResetBtnClick = function(self)
	gCS.CameraDataMgr.cinemachineManager:GamePadResetCameraDirAndDis(GameConfig.ResetCameraDirectionAndDistanceBlendTime)
end

M.SetCircleOpen = function(self, open)
	self.circleOpen = open

	if open then
		self.ClearGamepadCameraRotate(self)
	end
end

M.ClearGamepadCameraRotate = function(self)
	self.needUpdateCamera = false
	self.rightStickValue.x = 0
	self.rightStickValue.y = 0

	gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
end

M.CheckBtnTips = function(self)
	if not gCoreHudUIManager.isNonMobileAdaptive or not self.bindData.gamePadArea then
		return
	end

	local show = gBattleSpiritMgr.currentSpiritTemplateId ~= 15022020 and SGUI.GameDevice.KeyboardMouse <= self.curActiveDevice

	if self.showNomalAttackTips == show then
		self.showNomalAttackTips = show
		local respond = self.normalSkillBtn.multiBtn
		local targetRespond = self.specialBtnRoot.skillBtn

		self.bindData.gamePadArea:ChangeButtonTipInfoByActionIdAndRespondType(4, respond, 8, 2, 0, show, true)

		if show then
			self.bindData.gamePadArea:ChangeButtonTipInfoByActionIdAndRespondType(7, respond, 8, 2, 0, show, true)
			self.bindData.gamePadArea:ChangeRespondByActionIdAndRespondType(7, respond, targetRespond)
		else
			self.bindData.gamePadArea:ChangeButtonTipInfoByActionIdAndRespondType(7, targetRespond, 8, 2, 0, show, true)
			self.bindData.gamePadArea:ChangeRespondByActionIdAndRespondType(7, targetRespond, respond)
		end
	end
end

M.ShowAmmunition = function(self, visible, interactable)
	self.showAmmunition = visible

	if self.characterControlData and self.characterControlData.ammunitionRoot then
		self.characterControlData.ammunitionRoot.interactable = interactable

		self.characterControlData.ammunitionRoot:SetActiveQuickly(visible)
		self:UpdateSkillGridPos(visible)
	end
end

M.UpdateSkillGridPos = function(self, showWeaponCircle)
	if self.characterControlData.skillBtnGrid then
		local store = self.GetStoreByWidget(self, self.characterControlData.skillBtnGrid)

		if store then
			store.gridPosCtrl = showWeaponCircle and 0 or 1
		end
	end
end

local GetDisplayDurabilityPercent = function(rawPercent, totalForGm)
	if rawPercent < 0 then
		if totalForGm and totalForGm ~= -1 then
			return 100
		else
			return 0
		end
	end

	if rawPercent > 100 then
		return 100
	end

	if rawPercent >= 1 then
		return 1
	end

	return math.floor(rawPercent)
end

M.UpdateAmmunition = function(self, cur, single, total, configTotal, bulletId)
	if not self.STATE_EnableOnce or not self.ammunitionRoot then
		return
	end

	local useBullet = self.IsCurrentWeaponUseBullet(self)

	if self.IsCurrentWeaponSeedGun(self) then
		local consumableId = gCS.FarmFunctionUtils.GetCurrentSowConsumableId()
		local count = consumableId <= 0 and gCommonItemManager:GetPackItemNum(consumableId) or 0
		self.ammunitionRoot.remainAmmunition = count
		self.ammunitionRoot.exchangeBulletCtrl = 0
		self.ammunitionRoot.showSeedBulletCtrl = 0

		if self.ammunitionRoot.bulletTip then
			self.ammunitionRoot.bulletTip:SetActive(false)
		end

		return
	else
		self.ammunitionRoot.showSeedBulletCtrl = 1
	end

	if not useBullet then
		self.curWeaponBulletId = 0
		self.ammunitionRoot.curAmmunition = cur
		self.ammunitionRoot.infiniteCurNum = cur

		if total <= 0 then
			self.ammunitionRoot.remainAmmunition = math.max(total - cur, 0)
		elseif total >= 0 then
			self.ammunitionRoot.remainAmmunition = "-"
		else
			self.ammunitionRoot.remainAmmunition = 0
		end

		self.ammunitionRoot.durabilityPercent = GetDisplayDurabilityPercent(total / configTotal * 100, total)
		self.ammunitionRoot.infiniteCurPercent = GetDisplayDurabilityPercent(cur / single * 100) .. "%"
		self.ammunitionRoot.itemNum = total

		self.RefreshBulletChangeCtrl(self, 0)

		return
	end

	self.curWeaponBulletId = bulletId or 0

	if self.curWeaponBulletId < 0 then
		self.ammunitionRoot.curAmmunition = 0
		self.ammunitionRoot.infiniteCurNum = 0
		self.ammunitionRoot.remainAmmunition = 0
		self.ammunitionRoot.durabilityPercent = 0
		self.ammunitionRoot.infiniteCurPercent = "0%"
		self.ammunitionRoot.itemNum = 0

		self.RefreshBulletChangeCtrl(self, 0)

		return
	end

	self.ammunitionRoot.curAmmunition = cur
	self.ammunitionRoot.infiniteCurNum = cur
	self.ammunitionRoot.remainAmmunition = math.max(total - cur, 0)
	self.ammunitionRoot.durabilityPercent = math.floor(cur / single * 100)
	self.ammunitionRoot.infiniteCurPercent = math.floor(cur / single * 100) .. "%"
	self.ammunitionRoot.itemNum = total

	self.RefreshBulletChangeCtrl(self, self.curWeaponBulletId)
end

M.RefreshWeaponDurabilityUI = function(self, templateId)
	if not self.ammunitionRoot then
		return
	end

	local cfg = SceneitemConfig.GetConfig(templateId)

	if cfg then
		if self.changeWeaponMode ~= ChangeWeaponMode.Up then
			self.ammunitionRoot:Commit("weaponIcon", cfg.SWeaponIconId, COMMIT_IMMEDIATELY)
		elseif self.changeWeaponMode ~= ChangeWeaponMode.Down then
			self.ammunitionRoot:Commit("weaponIconDown", cfg.SWeaponIconId, COMMIT_IMMEDIATELY)
		else
			self.ammunitionRoot:Commit("weaponIcon", cfg.SWeaponIconId, COMMIT_IMMEDIATELY)
			self.ammunitionRoot:Commit("weaponIconDown", cfg.SWeaponIconId, COMMIT_IMMEDIATELY)
		end
	end

	self.ammunitionRoot.weaponType = self.GetWeaponDurabilityType(self)
end

M.GetWeaponDurabilityType = function(self)
	local weaponId = gBattleMgr.battleWeaponTemplateId
	local cfg = SceneitemConfig.GetConfig(weaponId)

	if cfg then
		local cfgIndex = self.CfgDurabilityMode2Index[cfg.DurabilityUIMode]

		if cfgIndex then
			return cfgIndex
		end

		local totalDurability = cfg.Durability

		if cfg.ShootId <= 0 then
			local shootCfg = WeaponShootConfig.GetConfig(cfg.ShootId)
			local bulletNum = cfg.BulletNum

			if bulletNum and bulletNum ~= totalDurability then
				return WeaponNumType.Percent
			end

			if totalDurability >= 0 then
				if bulletNum and bulletNum <= 0 then
					return WeaponNumType.InfiniteAmmo
				end

				return WeaponNumType.FreeDurability
			end

			return WeaponNumType.Gun
		end

		if totalDurability >= 0 then
			return WeaponNumType.FreeDurability
		end

		if cfg.WeaponStackMaxCount == 0 then
			return WeaponNumType.ItemNumber
		end
	end

	return WeaponNumType.Percent
end

M.CheckShowLeftShootBtn = function(self, templateId)
	local isShootWeapon = gCS.GunModule.CheckShowMobileShootBtn()
	local isActive = isShootWeapon and not gCoreHudUIManager.isNonMobileAdaptive

	if self.characterControlData then
		gBattleMgr:SetBtnFaraway(self.characterControlData.leftShootBtn, isActive)
	end
end

M.OnParkourStateChange = function(self)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("CoreHudCharacterControlStore.CheckShowDropDownBtnTips")
	end

	self.CheckShowDropDownBtnTips(self)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
		gGameManager:BeginSample("CoreHudCharacterControlStore.CheckShowJobSpecialBtn")
	end

	gBattleMgr:CheckShowJobSpecialBtn()

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
		gGameManager:BeginSample("CoreHudCharacterControlStore.CheckChangeBtnMode")
	end

	self.CheckChangeBtnMode(self)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
		gGameManager:BeginSample("CoreHudCharacterControlStore.CheckIsClimbRun")
	end

	self.CheckIsClimbRun(self)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.UpdateNormalSkillImage = function(self)
	local cfgImageId = gBattleMgr:GetNormalSkillImg()

	gCoreHudTipManager:UpdateBtnIconState(1, gCoreHudTipManager.conditionType.Default, cfgImageId)
end

M.OnSkillResourceChanged = function(self, eventId, templateId, curValue, maxValue)
	if templateId ~= LTConfig.SkillResourcesConfig.DriveTimeScaleEnergy then
		self.professionSkillBtnTimes = curValue
		self.maxProfessionSkillBtnTimes = maxValue
		self.needUpdateProfessionSkillBtnCD = true

		self.RefreshProfessionSkillBtnCD(self)
	end
end

M.CheckChangeBtnMode = function(self)
	self.isHoldBlend = gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.HoldBlend)
	local Emode = not self.isHoldBlend and not self.isBasicNoSkillId
	local Rmode = true

	self:ChangeSpecialBtnMode(Emode)
	self:ChangeUltBtnMode(Rmode)
end

M.ChangeSpecialBtnMode = function(self, battleMode)
	self.ChangeBtnMode(self, self.specialBtnRoot, 2, battleMode)
end

M.ChangeUltBtnMode = function(self, battleMode)
	self.ChangeBtnMode(self, self.ultBtnRoot, 3, battleMode)
end

M.ChangeBtnMode = function(self, rootStore, index, battleMode)
	local ctrlValue = battleMode and BtnBattleMode.Battle or BtnBattleMode.Normal

	if rootStore.ctrlMode ~= ctrlValue then
		return
	end

	rootStore.ctrlMode = ctrlValue

	if battleMode then
		self.UpdateSkill(self, index)
	else
		self.UpdateNomalBtn(self, rootStore)
	end
end

M.UpdateNomalBtn = function(self, rootStore)
	local btn = rootStore.normalBtn
end

M.UpdatePCAndGamepadBtnState = function(self, data)
	self.UpdateSkillBtnDataSetState(self, data)
	self.UpdateControllerBtnState(self, data)
end

M.UpdateSkillBtnDataSetState = function(self, data)
	if not self.characterControlData or not data or not data.key or not data.value then
		return
	end

	local skillType = data.key
	local state = data.value
	self.goSkills[skillType].ignoreLayout = skillType ~= gBattleMgr.SkillBtnType.Normal or not state[1]

	if self.skillBtnRootGos[skillType] then
		self.skillBtnRootGos[skillType].ignoreLayout = not state[1]
	end

	if skillType ~= gBattleMgr.SkillBtnType.ControlPower and gCoreHudUIManager.isNonMobileAdaptive then
		self.skillGo[skillType]:SetPCKeyTipShowTip(state[1])

		if self.bindData.gamePadArea then
			self.bindData.gamePadArea:SetButtonInfoTipShowTip(state[1], 23)
		end
	end

	if not state[1] or not state[2] then
		self.ClearBtnFanseAni(self, self.goSkills[skillType], skillType)
		self.ClearSkillXuliAni(self, self.goSkills[skillType], skillType)
	end

	self.SetBtnState(self, self.goSkills[skillType], state[1], state[2])

	if self.skillNormalBtns and self.skillNormalBtns[skillType] then
		self.SetBtnState(self, self.skillNormalBtns[skillType], state[1], state[2])
	end

	if self.characterControlData.leftShootBtn and self.leftShootBtn and skillType ~= gCoreHudUIManager.skillType.Normal then
		self.SetBtnState(self, self.leftShootBtn, state[1], state[2])
	end
end

M.UpdateSwitchWeaponWheelsState = function(self)
	local property = gCoreHudUIManager.buttonStateMonitor[gCoreHudUIManager.skillType.SwitchWeaponWheels]

	self:ShowAmmunition(property[1], property[2])

	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore.ShowAmmunition(shootStore, property[1], property[2])
	end
end

M.UpdateBtnHoldState = function(self, data)
	local skillType = data.key
	local state = data.value
	local btnGoName = nil

	if skillType ~= gCoreHudUIManager.skillType.Hold_Left then
		btnGoName = "holdLeftBtn"
	elseif skillType ~= gCoreHudUIManager.skillType.Hold_Q then
		btnGoName = "holdQBtn"
	elseif skillType ~= gCoreHudUIManager.skillType.Hold_R then
		btnGoName = "holdRBtn"
	end

	if not btnGoName or not self[btnGoName] or not self.characterControlData[btnGoName] then
		return
	end

	self:SetBtnVisible(self[btnGoName], state[1])
	self.characterControlData[btnGoName]:SetActive(state[2])
end

M.UpdateBtnDataSetState = function(self, data)
	if not self.characterControlData or not data or not data.key or not data.value then
		return
	end

	local skillType = data.key
	local state = data.value
	local btnStore, btnGo = nil

	if skillType ~= gCoreHudUIManager.skillType.Dodge then
		btnStore = self.dodgeBtn
	elseif skillType ~= gCoreHudUIManager.skillType.JumpJump then
		btnStore = self.jumpSwingBtn
	elseif skillType ~= gCoreHudUIManager.skillType.OffWall then
		btnStore = self.dropBtn
		btnGo = self.characterControlData.dropBtn
	elseif skillType ~= CoreHudButtonConfig.Dive then
		btnStore = self.ctrlBtn
		btnGo = self.characterControlData.ctrlButton
	elseif skillType ~= gCoreHudUIManager.skillType.DiveDash then
		btnStore = self.diveSpeedUpBtn
		btnGo = self.characterControlData.diveSpeedUpBtn
	elseif skillType ~= gCoreHudUIManager.skillType.DiveUp then
		btnStore = self.diveUpBtn
		btnGo = self.characterControlData.diveUpBtn
	elseif skillType ~= gCoreHudUIManager.skillType.KickOff then
		if self.characterControlData and self.kickOffBtn and self.characterControlData.kickOffBtn then
			gBattleMgr:SetBtnFaraway(self.characterControlData.kickOffBtn, state[1])
			gCoreHudQteVisualMgr:RequestQteVisual(gCoreHudQteVisualMgr.Tier.KickOff, state[1])
		end

		return
	elseif skillType ~= gCoreHudUIManager.skillType.ProfessionalSkill then
		if self.characterControlData and self.professionSkillBtn and self.characterControlData.professionSkillBtn then
			self.professionSkillBtn.btnHideCtrl = state[1] and 0 or 1

			gBattleMgr:SetBtnFaraway(self.characterControlData.professionSkillBtn, state[1], false)
		end

		return
	elseif skillType ~= gCoreHudUIManager.skillType.RightBottom then
		if self.characterControlData and self.bindData.battleBtnRoot then
			self.characterControlData.battleBtnRoot:SetActive(state[1])

			local oldPos = self.characterControlData.battleBtnRoot.localPosition
			self.characterControlData.battleBtnRoot.localPosition = Vector3.New(oldPos.x, oldPos.y, state[1] and 0 or gCS.GuiUtils.UI_TRANS_OUT_RANGE)
		end

		return
	elseif skillType ~= gCoreHudUIManager.skillType.BulletChange then
		self.RefreshBulletChangeCtrl(self, self.curWeaponBulletId)

		return
	elseif skillType ~= gCoreHudUIManager.skillType.ResetVehicle then
		self.characterControlData.resetVehicleBtn:SetActive(state[1])

		return
	elseif skillType ~= gCoreHudUIManager.skillType.Umbrella then
		btnStore = self.umbrellaBtn
		btnGo = self.characterControlData.umbrellaBtn
	elseif skillType ~= gCoreHudUIManager.skillType.SkyDiving then
		btnStore = self.skyDiveBtn
		btnGo = self.characterControlData.skyDiveBtn
	end

	if not btnStore then
		return
	end

	self.SetBtnState(self, btnStore, state[1], state[2])

	if btnGo then
		btnGo.SetWidgetFaraway(btnGo, not state[1])
	end

	self.UpdateBtnAni(self, btnStore, nil, state[2])

	if skillType ~= gCoreHudUIManager.skillType.JumpJump then
		self.RefreshObstacleTip(self)
	end
end

M.UpdateControllerBtnState = function(self, data)
	if not self.characterControlData or not data or not data.key or not data.value or self.curActiveDevice >= SGUI.GameDevice.PlayStation then
		return
	end

	local skillType = data.key
	local state = data.value
	local isShootingMode = self.characterControlData.controllerState ~= 1
	local shouldShow = isShootingMode and state[2]

	if skillType ~= gBattleMgr.SkillBtnType.FightSpiritBigSkill and self.characterControlData.controllerGunNorth then
		self.characterControlData.controllerGunNorth:SetActive(isShootingMode)
	elseif skillType ~= gBattleMgr.SkillBtnType.Basic and self.characterControlData.controllerGunWest then
		self.characterControlData.controllerGunWest:SetActive(isShootingMode)

		self.characterControlData.controllerGunWest.interactable = shouldShow
	elseif skillType ~= gCoreHudUIManager.skillType.HeavyAttack and self.characterControlData.controllerGunAim and self.characterControlData.controllerBlock then
		self.characterControlData.controllerGunAim:SetActive(isShootingMode)

		self.characterControlData.controllerGunAim.interactable = shouldShow

		self.characterControlData.controllerBlock:SetActive(isShootingMode)

		self.characterControlData.controllerBlock.interactable = shouldShow
	end

	if self.characterControlData.controllerGunWest and self.characterControlData.controllerShot then
		self.Log(self, "[Controller] 切换状态: ", "按键：", skillType, "当前controllerGunWest激活性：", self.characterControlData.controllerGunWest.activation, "当前controllerShot激活性：", self.characterControlData.controllerShot.activation, " 技能可用：", state[2], " 射击下是否显示：", shouldShow, "能否摆荡:", gCS.LuaUtils.CanSwing())
	end
end

M.UpdateBtnAni = function(self, btn, index, active)
	if not active then
		self.ClearBtnFanseAni(self, btn, index)
		self.ClearSkillXuliAni(self, btn, index)
	end
end

M.SetBtnState = function(self, btnStore, targetVisible, targetInteractable)
	if targetVisible ~= nil or targetInteractable ~= nil or not btnStore then
		return
	end

	local targetHideCtrl = targetVisible and 0 or 1

	if targetHideCtrl == btnStore.btnHideCtrl then
		self.SetBtnVisible(self, btnStore, targetVisible)
	end

	if targetInteractable == btnStore.interactable then
		self.SetBtnInteractable(self, btnStore, targetInteractable)
	end
end

M.OnBattlePanelBtnEvent = function(self, eventId, para)
	local eventIndex = para[1]
	local skillButtonIndex = para[2]

	if eventIndex ~= gBattleMgr.battlePanelEvent.skillKeyDown then
		self.OnMergeBtnLongPressBegin(self, skillButtonIndex, true)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.skillKeyUp then
		self.OnMergeBtnLongPressEnd(self, skillButtonIndex)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.skillPressDown then
		self.OnMergeBtnLongPressBegin(self, skillButtonIndex)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.skillPress then
		self.OnMergeBtnLongPress(self, skillButtonIndex)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.skillPressUp then
		self.OnMergeBtnLongPressEnd(self, skillButtonIndex)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.jumpKeyPressDown then
		self.OnJumpSwingBtnLongPressBegin(self)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.jumpKeyPress then
		self.OnJumpSwingBtnLongPress(self)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.jumpKeyPressUp then
		self.OnJumpSwingBtnLongPressEnd(self)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.dodgeKeyDown then
		self.OnDodgeBtnPress(self)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.dodgeKeyUp then
		self.OnDodgeBtnRelease(self)
	elseif eventIndex ~= gBattleMgr.battlePanelEvent.updateSkillState then
		self.isUpdateSkillBtns[skillButtonIndex] = true
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.curActiveDevice = device

	if SGUI.GameDevice.KeyboardMouse >= self.curActiveDevice then
		self.UpdateControllerState(self)
	end

	gCoreHudUIManager:OnRefreshForAwakeUI()
end

M.OnLanguageChange = function(self, lang)
end

M.OnPerfectBlockEvent = function(self, eventId, data)
	gBattleMgr.canCounter = data.canCounter
	gBattleMgr.threatLevel = data.threatLevel

	if not self.heavyAttackBtn or gCoreHudUIManager.isNonMobileAdaptive then
		return
	end

	local BeCounterType = LX6.SlateData.HState_BeCounterType

	if data.type ~= BeCounterType.BlockCounterAttack then
		local isOnPerfectBlock = data.canCounter

		if isOnPerfectBlock ~= self.canPerfectBlock then
			return
		end

		self.canPerfectBlock = isOnPerfectBlock

		gCoreHudQteVisualMgr:RequestQteVisual(gCoreHudQteVisualMgr.Tier.Block, isOnPerfectBlock)
	elseif data.type ~= BeCounterType.DoegeCounterAttack then
		local isOnPerfectDodge = data.canCounter and data.threatLevel ~= LX6.SlateData.HState_ThreatLevelEnum.Red and data.isPureRed

		if isOnPerfectDodge ~= self.canPerfectDodge then
			return
		end

		self.canPerfectDodge = isOnPerfectDodge

		gCoreHudQteVisualMgr:RequestQteVisual(gCoreHudQteVisualMgr.Tier.Dodge, isOnPerfectDodge)
	end
end

M.OnHeavyAttackBtnLongPressBegin = function(self)
	self.OnMergeBtnLongPressBegin(self, 5)

	if self.canPerfectBlock and self.heavyAttackBtn then
		slot1 = gBattleMgr

		slot1:CommonPlayAniTool(self.heavyAttackBtn.btnBlockAnim, self.blockCloseAnim, 0, 1, true, function ()
			gCoreHudQteVisualMgr:RequestQteVisual(gCoreHudQteVisualMgr.Tier.Block, false)

			self.canPerfectBlock = nil
		end)
	end
end

M.OnChangeWeaponType = function(self, eventId, isHoldRangedWeapon)
	gCoreHudUIManager.isHoldRangedWeapon = isHoldRangedWeapon

	if SGUI.GameDevice.KeyboardMouse >= self.curActiveDevice then
		self.UpdateControllerState(self)
	end

	self.RefreshControllerShotByUltR2(self)

	local currentWeapon = gPlayerManager.infoSpirit.bindData.currentWeapon

	self.UpdateAdaptiveTrigger(self, currentWeapon)
end

M.UpdateControllerState = function(self)
	if gCoreHudUIManager.isHoldRangedWeapon then
		self.characterControlData:Commit("controllerState", 1, COMMIT_IMMEDIATELY)
	else
		self.characterControlData:Commit("controllerState", 0, COMMIT_IMMEDIATELY)
	end

	for i = 1, 5 do
		local data = {
			key = i,
			value = gCoreHudUIManager.buttonStateMonitor[i]
		}

		self.UpdateControllerBtnState(self, data)
	end
end

M.OnControllerSettingChange = function(self, eventId, isNewSetting)
	self.bindData.ControllerSettingCtrl = isNewSetting and 0 or 1
end

M.RefreshObstacleTip = function(self)
end

M.OnHighObstacle = function(self, eventId, needShowWallUI)
	self.needShowObstacleTip = needShowWallUI

	self.RefreshObstacleTip(self)
end

M.CheckWeaponDurability = function(self, eventId, data)
	if not data then
		return
	end

	if self.suppressDropWeapon then
		if self.suppressDropWeapon ~= true then
			self.suppressDropWeapon = data.weaponId
		end

		if self.suppressDropWeapon ~= data.weaponId then
			return
		end

		self.suppressDropWeapon = nil
	end

	local weapon = gPlayerManager.infoSpirit.bindData.currentWeapon

	if not weapon or weapon.InstanceId == data.weaponId then
		return
	end

	self:SetAmmnitionBrokenState(weapon)

	if gWeaponManager:IsWeaponPileUp(weapon.TemplateId) or gWeaponManager:IsWeaponUseBulletById(weapon.TemplateId) then
		return
	end

	local cfg = SceneitemConfig.GetConfig(weapon.TemplateId)

	if cfg and cfg.NoDestroyUI then
		return
	end

	if data.isToLowLimit then
		local platform = gCoreHudUIManager.isNonMobileAdaptive and "_PC" or ""

		gBattleMgr:CommonPlayAniTool(self.ammunitionRoot.scrollAni, "S_Vx_CharacterControls_AmmunitionNum_NearlyBroken" .. platform, 0, 1, true)
	elseif data.durability ~= 0 then
		local platform = gCoreHudUIManager.isNonMobileAdaptive and "_PC" or ""

		gBattleMgr:CommonPlayAniTool(self.ammunitionRoot.scrollAni, "S_Vx_CharacterControls_AmmunitionNum_Broken" .. platform, 0, 1, true)
	end
end

M.OnCurrentWeaponChange = function(self, eventId, weaponInfo)
	if not weaponInfo then
		return
	end

	self.SetAmmnitionBrokenState(self, weaponInfo)
end

M.SetAmmnitionBrokenState = function(self, weaponInfo)
	if not weaponInfo or not weaponInfo.TemplateId or not weaponInfo.Durability then
		return
	end

	local cfg = SceneitemConfig.GetConfig(weaponInfo.TemplateId)

	if not cfg then
		print_warn("[CoreHudCharacterControl][SetAmmnitionBrokenState] 请勿使用旧配置武器id！找不到武器配置, weaponInfo = ", weaponInfo)

		return
	end

	local allDurability = cfg.Durability

	if allDurability ~= -1 or cfg.NoDestroyUI or not weaponInfo.Durability or gWeaponManager:IsWeaponPileUp(weaponInfo.TemplateId) or gWeaponManager:IsWeaponUseBulletById(weaponInfo.TemplateId) then
		self.ammunitionRoot.brokenCtrl = self.weaponStateEnum.Fill

		return
	end

	local lowLimit = SceneitemConfig.WeaponDurabilityLow * allDurability

	if weaponInfo.Durability ~= 0 then
		self.ammunitionRoot.brokenCtrl = self.weaponStateEnum.None
	elseif weaponInfo.Durability < lowLimit then
		self.ammunitionRoot.brokenCtrl = self.weaponStateEnum.Broken
	else
		self.ammunitionRoot.brokenCtrl = self.weaponStateEnum.Fill
	end
end

M.ApplyGenericQteVisual = function(self, btn, show)
	if not btn then
		return
	end

	btn.qteVxCtrl = show and 1 or 0
end

M.ApplyBlockQteVisual = function(self, btn, show)
	if not btn then
		return
	end

	btn.btnBlockAnim:Stop()

	btn.blockCtrl = show and 1 or 0
	self.characterControlData.blockScaleCtrl = show and 1 or 0
	local skillType = gBattleMgr.SkillBtnType.HeavyAttack

	if show then
		btn.btnBlockAnim:Play(self.blockOpenAnim)
		gCoreHudTipManager:UpdateBtnIconState(skillType, gCoreHudTipManager.conditionType.Special, gCoreHudImgManager.imgShootBlockId)
		gCoreHudTipManager:UpdateBtnTextSpecial(skillType, gCoreHudTipManager.conditionType.Special, 646)
	else
		gCoreHudTipManager:UpdateBtnIconState(skillType, gCoreHudTipManager.conditionType.Special, 0)
		gCoreHudTipManager:UpdateBtnTextSpecial(skillType, gCoreHudTipManager.conditionType.Special, -1)
	end
end

M.OnQteVisualTierChange = function(self, eventId, newActiveTier, oldActiveTier)
	if oldActiveTier and oldActiveTier == newActiveTier then
		local oldCfg = self.QTE_TIER_CONFIG[oldActiveTier]

		if oldCfg then
			self[oldCfg.applyFunc](self, self[oldCfg.btnField], false)
		end
	end

	if newActiveTier then
		local newCfg = self.QTE_TIER_CONFIG[newActiveTier]

		if newCfg then
			self[newCfg.applyFunc](self, self[newCfg.btnField], true)
		end
	end
end

M.OnMindCounterAttack = function(self, eventId, isShowMindCounter)
	gCoreHudQteVisualMgr:RequestQteVisual(gCoreHudQteVisualMgr.Tier.MindPower, isShowMindCounter)
end

M.OnWorkActionVxChange = function(self, eventId, table)
	if not table or not table.MobileImage or not table.MobileBtnName then
		return
	end

	if not self.characterControlData or not self[table.MobileBtnName] then
		print_error("[CoreHudCharacterControl][OnWorkActionVxChange]CombatTraining 表格配置错误, 不存在指定按键", table.MobileBtnName)

		return
	end

	gCoreHudTipManager:UpdateBtnIconState(self[table.MobileBtnName], gCoreHudTipManager.conditionType.Special, table.MobileImage)

	self[table.MobileBtnName].qteVxCtrl = table.isActive and 1 or 0
end

M.OnSwitchControlChanged = function(self, eventId, enable)
	self.switchControlEnable = enable
end

M.OnSpiritChange = function(self)
	self.OnCharacterChange(self)
	self.UpdateByWeaponRefresh(self, true)
end

M.UpdateByWeaponRefresh = function(self, needRefreshAmmunition)
	self.CheckWeaponDurability(self)
	self.RefreshBtnTipStatus(self)

	if needRefreshAmmunition then
		gCS.WeaponMgr.RefreshCurrentAmmunitionInfo()
		self.RefreshWeaponDurabilityUI(self, gCS.WeaponMgr.GetCurrentWeaponTid())
	end

	local currentWeapon = gPlayerManager.infoSpirit.bindData.currentWeapon

	if currentWeapon then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Hold_Q, "isNotDiscard", gWeaponManager:GetFlag(currentWeapon.OperatorFlags, 1) ~= 1)
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchWeaponWheels, "isHandBag", gCS.WeaponMgr.GetCurrentWeaponActiveType() ~= self.handBagActionType)
	end

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BulletChange, "isBulletWeapon", self:IsCurrentWeaponUseBullet() and self:HasCurrentWeaponBulletTypeConfig())
	self:UpdateAdaptiveTrigger(currentWeapon)
end

M.UpdateAdaptiveTrigger = function(self, currentWeapon)
	if not gCoreHudUIManager.isNonMobileAdaptive then
		return
	end

	if not self.bindData.gamePadArea then
		return
	end

	local dualSenseId = ""

	if self.isInAir then
		if gCS.LuaUtils.CanSwing() then
			dualSenseId = "swing"
		end
	elseif gCoreHudUIManager.isHoldRangedWeapon and currentWeapon then
		local weaponTemplateId = currentWeapon.TemplateId or 0

		if weaponTemplateId <= 0 then
			local cfg = SceneitemConfig.GetConfig(weaponTemplateId)

			if cfg and cfg.ShootAdaptiveTrigger and cfg.ShootAdaptiveTrigger == "" then
				dualSenseId = cfg.ShootAdaptiveTrigger
			end
		end
	end

	self.bindData.gamePadArea:ChangeDualSenseByActionId(8, dualSenseId)
end

M.OnSpiritInfoChanged = function(self, eventId, spiritTid)
	self.SyncRefreshBasicSkills(self)
end

M.OnYingLongBarrier = function(self, eventId, shouldShowEffect)
	self.jumpSwingBtn.qteVxCtrl = shouldShowEffect and 1 or 0
end

M.OnEnterHideAndSeek = function(self)
	self.SetPCKeyLongPressTime(self, self.basicSkillBtnGo, 1)
end

M.OnInteractionTypeChange = function(self, eventId, interactionId, btnId)
	local interactConfig = SceneItemInteractionUseFunctionConfig.GetConfig(interactionId)
	local isNonMobile = gCS.LuaUtils.IsNonMobileAdaptive()

	if interactConfig then
		if not isNonMobile then
			gCoreHudTipManager:UpdateBtnIconState(btnId, gCoreHudTipManager.conditionType.Environment, interactConfig.MobileIcon)
		else
			gCoreHudTipManager:UpdateBtnTipSpecial(btnId, gCoreHudTipManager.conditionType.Environment, interactConfig.ShowPCKeyTips, interactConfig.PCKeyTipsText)
		end

		if interactionId ~= SceneItemInteractionUseFunctionConfig.NormalDrop or interactionId ~= SceneItemInteractionUseFunctionConfig.SkillThrow then
			self.SetPCKeyLongPressTime(self, self.basicSkillBtnGo, 1)
		else
			self.SetPCKeyLongPressTime(self, self.basicSkillBtnGo, 0.2)
		end
	else
		self.SetPCKeyLongPressTime(self, self.basicSkillBtnGo, 0.2)
	end
end

M.SetPCKeyLongPressTime = function(self, btn, time)
	if not btn then
		return
	end

	btn.SetPCKeyLongPressTime(btn, time)
end

M.OnShowUIEffect = function(self, eventId, notifyParam)
	if notifyParam then
		if notifyParam.OperatorType ~= 1 then
			if self.bigSkillBtn and self.bigSkillBtn.loseEnergyAnim then
				gCS.LuaUtils.PlayAnimationByName(self.bigSkillBtn.loseEnergyAnim, "S_Vx_CombatEnergyLose")
			end
		elseif notifyParam.OperatorType ~= 2 and notifyParam.uParam1 then
			gDisplayMessageMgr:ShowMessage(notifyParam.uParam1)
		end
	end
end

M.GetCurrentWeaponShootConfig = function(self)
	local weaponTemplateId = gCS.WeaponMgr.GetCurrentWeaponTid(false) or 0

	if not weaponTemplateId or weaponTemplateId < 0 then
		return nil
	end

	local weaponCfg = SceneitemConfig.GetConfig(weaponTemplateId)

	if not weaponCfg or not weaponCfg.ShootId or weaponCfg.ShootId < 0 then
		return nil
	end

	return WeaponShootConfig.GetConfig(weaponCfg.ShootId)
end

M.GetCurrentWeaponAppropriateBullets = function(self)
	local shootCfg = self.GetCurrentWeaponShootConfig(self)

	if not shootCfg then
		return nil
	end

	local appropriateBullets = shootCfg.AppropriateBullets

	if not appropriateBullets or #appropriateBullets < 0 then
		return nil
	end

	return appropriateBullets
end

M.GetCurrentWeaponAppropriateBulletsCached = function(self)
	local curWeaponTid = gBattleMgr.battleWeaponTemplateId or 0

	if self.curWeaponTid ~= curWeaponTid and self.cachedAppropriateBullets then
		return self.cachedAppropriateBullets
	end

	local bullets = self.GetCurrentWeaponAppropriateBullets(self)
	self.curWeaponTid = curWeaponTid
	self.cachedAppropriateBullets = bullets

	return bullets
end

M.IsCurrentWeaponSeedGun = function(self)
	local tid = gBattleMgr and gBattleMgr.battleWeaponTemplateId or 0

	return gCS.FarmFunctionUtils.IsSowWeapon(tid)
end

M.IsCurrentWeaponUseBullet = function(self)
	local shootCfg = self.GetCurrentWeaponShootConfig(self)

	if not shootCfg then
		return false
	end

	return shootCfg.SeparateBullets ~= true
end

M.HasCurrentWeaponBulletTypeConfig = function(self)
	local appropriateBullets = self:GetCurrentWeaponAppropriateBullets()

	return appropriateBullets == nil and #appropriateBullets >= 0
end

M.GetBulletTypeCtrlByBulletId = function(self, bulletId)
	if not bulletId or bulletId < 0 then
		return 0
	end

	local bulletCfg = LTConfig.ConsumableConfig.GetConfig(bulletId)

	if not bulletCfg or not bulletCfg.Quality then
		return 0
	end

	return self.BulletQuality2Ctrl[bulletCfg.Quality] or 0
end

M.HasOtherAvailableBullet = function(self, currentBulletId)
	local appropriateBullets = self.GetCurrentWeaponAppropriateBullets(self)

	if not appropriateBullets then
		return false
	end

	for i = 1, #appropriateBullets do
		local bulletTemplateId = appropriateBullets[i]

		if bulletTemplateId == currentBulletId and gCommonItemManager:GetPackItemNum(bulletTemplateId) <= 0 then
			return true
		end
	end

	return false
end

M.RefreshBulletTypeCtrl = function(self, bulletId)
	if not self.HasCurrentWeaponBulletTypeConfig(self) then
		self.ammunitionRoot.bulletTypeCtrl = 0

		return
	end

	self.ammunitionRoot.bulletTypeCtrl = self.GetBulletTypeCtrlByBulletId(self, bulletId)
end

M.RefreshBulletChangeCtrl = function(self, bulletId)
	if not self.ammunitionRoot then
		return
	end

	local bulletInteractable = gCoreHudUIManager:GetBattleSkillInteractable(gCoreHudUIManager.skillType.BulletChange)
	local hasOtherBullet = self:HasOtherAvailableBullet(bulletId)

	self:RefreshBulletTypeCtrl(bulletId)

	self.ammunitionRoot.exchangeBulletCtrl = bulletInteractable and 1 or 0

	if not gCoreHudUIManager.isNonMobileAdaptive then
		self.ammunitionRoot.bulletBtn.interactable = hasOtherBullet
	end

	if self.ammunitionRoot.bulletTip then
		self.ammunitionRoot.bulletTip:SetActive(bulletInteractable and hasOtherBullet)
	end
end

M.RefreshEquippedBulletCount = function(self)
	if not self.ammunitionRoot then
		return
	end

	if self.curWeaponBulletId and self.curWeaponBulletId <= 0 and self.IsCurrentWeaponUseBullet(self) then
		local totalOwned = gCommonItemManager:GetPackItemNum(self.curWeaponBulletId)
		self.ammunitionRoot.remainAmmunition = math.max(totalOwned, 0)
		self.ammunitionRoot.itemNum = totalOwned
	end
end

M.IsBulletRelevantToCurrentWeapon = function(self, bulletId)
	if not bulletId or bulletId < 0 then
		return false
	end

	if bulletId ~= self.curWeaponBulletId then
		return true
	end

	local appropriateBullets = self.GetCurrentWeaponAppropriateBullets(self)

	if not appropriateBullets then
		return false
	end

	for i = 1, #appropriateBullets do
		if appropriateBullets[i] ~= bulletId then
			return true
		end
	end

	return false
end

M.OnBulletItemChanged = function(self, eventId, itemId)
	if not self.IsCurrentWeaponUseBullet(self) then
		return
	end

	if not self.IsBulletRelevantToCurrentWeapon(self, itemId) then
		return
	end

	if itemId ~= self.curWeaponBulletId then
		self.RefreshEquippedBulletCount(self)
	end

	self:RefreshBulletChangeCtrl(self.curWeaponBulletId or 0)
end

M.OnBulletBtnClick = function(self)
	local appropriateBullets = self.GetCurrentWeaponAppropriateBulletsCached(self)

	if not appropriateBullets or #appropriateBullets < 1 then
		return
	end

	local currentBulletId = self.curWeaponBulletId or 0
	local currentIndex = 0

	for i = 1, #appropriateBullets do
		if appropriateBullets[i] ~= currentBulletId then
			currentIndex = i

			break
		end
	end

	if currentIndex ~= 0 then
		return
	end

	local count = #appropriateBullets

	for offset = 1, count - 1 do
		local nextIndex = (currentIndex - 1 + offset) % count + 1
		local nextBulletId = appropriateBullets[nextIndex]

		if gCommonItemManager:GetPackItemNum(nextBulletId) <= 0 then
			slot11 = gClientToGameSceneDelegate

			slot11:AskWeaponEquipBullets(gCS.WeaponMgr.GetCurrentWeaponInstanceId(), nextBulletId).Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err, nextBulletId)
				end
			end

			return
		end
	end
end

M.OnSeedBulletBtnClick = function(self)
	if not self.IsCurrentWeaponSeedGun(self) then
		print_error("[CoreHudCharacterControl][OnSeedBulletBtnClick] 当前武器不是种子枪，无法显示种子枪专用界面")

		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	gPanelManager:CheckShow(gPanelId.SWITCH_SEED_PANEL)
end

M.OnSeedBulletBtnPress = function(self)
	if not self.IsCurrentWeaponSeedGun(self) then
		print_error("[CoreHudCharacterControl][OnSeedBulletBtnPress] 当前武器不是种子枪，无法显示种子枪专用界面")

		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	gPanelManager:CheckShow(gPanelId.SWITCH_SEED_PANEL)
end

M.OnSeedBulletBtnRelease = function(self)
	if not self.IsCurrentWeaponSeedGun(self) then
		print_error("[CoreHudCharacterControl][OnSeedBulletBtnRelease] 当前武器不是种子枪，无法显示种子枪专用界面")

		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not gPanelManager:IsPanelShowing(gPanelId.SWITCH_SEED_PANEL) then
		return
	end

	gPanelManager:Close(gPanelId.SWITCH_SEED_PANEL)
end

M.OnSkyDiveBtnClick = function(self)
	if gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.ShowTipsParachuteCut) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.CutoffParachute)
	else
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.OpenParachute)
	end
end

M.OnDiveSpeedUpBtnBeginLongPress = function(self)
	if not self.characterControlData.diveSpeedUpBtn or not self.characterControlData.diveSpeedUpBtn.interactable then
		return
	end

	gBattleMgr:OnDodgeBtnPressFunc()
end

M.OnDiveSpeedUpBtnLongPress = function(self)
end

M.OnDiveSpeedUpBtnLongPressEnd = function(self)
	gBattleMgr:OnDodgeBtnReleaseFunc()
end

M.OnGameplayTagUIRefresh = function(self, eventId, queryId, stateRes)
	if queryId ~= GameplayTagQueryConfig.CanSwitchDogBot then
		self.RefreshSwitchToAndriodsBtnState(self, stateRes)
	end
end

M.OnCombatArtNotifyChanged = function(self, eventId, isShow, pid)
	gBattleMgr.showCombatArtHint = isShow

	self.UpdateBasicSkills(self, gBattleMgr.SkillBtnType.Normal)
end

M.RefreshControllerShotByUltR2 = function(self)
	if not self.characterControlData or not self.characterControlData.controllerShot then
		return
	end

	local enable = not ProfileManager.gameProfile.isUltButtonToR2 or gCoreHudUIManager.isHoldRangedWeapon

	self.characterControlData.controllerShot:SetActive(enable)

	self.bigSkillBtn.controllerRebindCtrl = enable and 0 or 1
end

M.OnResetVehicleBtnClick = function(self)
	gVehicleInteractManager.cs_manager:OnResetVehicleInteractButtonClick()
end

M.OnUmbrellaBtnClick = function(self)
	if gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.ShowTipsUmbrellaBtnClose) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.Umbrella_Close)
	else
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.Umbrella_Open)
	end
end

M.OnDiveUpBtnPress = function(self, isLongPress)
	UnitOperateUtils.DoOperateFunc(OperateType.KeyDown, gCS.MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpPress)
	end

	gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.JumpButtonClick)
end

M.OnDiveUpBtnRelease = function(self, notPlayAni)
	UnitOperateUtils.DoOperateFunc(OperateType.KeyUp, gCS.MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpRelease)
	end
end

M.OnDebugAgentCircleBtn = function(self, eventId, enable)
	if not self.characterControlData.debugAgentCircleBtn then
		return
	end

	if enable then
		self.characterControlData.debugAgentCircleBtn:SetActive(gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.SummonSpiritWheel))
	else
		self.characterControlData.debugAgentCircleBtn:SetActive(false)
	end
end

M.OnDebugAgentCircleBtnPress = function(self)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):OpenCircle(gCircleType.SUMMON)
end

M.OnDebugAgentCircleBtnRelease = function(self)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):CloseCircle()
end

M.Log = function(self, ...)
	if gMainMenuMgr.ShowTestMsg then
		print_warn("[CoreHudCharacterControlStore]", ...)
	end
end

M.ClearAllRef = function(self)
	self.jumpSwingBtn = nil
	self.dodgeBtn = nil
	self.normalSkillBtn = nil
	self.specialBtnRoot = nil
	self.basicSkillBtn = nil
	self.basicNormalBtn = nil
	self.ultBtnRoot = nil
	self.bigSkillBtn = nil
	self.ultNormalBtn = nil
	self.mindPowerBtn = nil
	self.heavyAttackBtn = nil
	self.dropBtn = nil
	self.costumeSkill = nil
	self.seeMobileBtn = nil
	self.kickOffBtn = nil
	self.ammunitionRoot = nil
	self.professionSkillBtn = nil
	self.switchToAndriodsBtn = nil
	self.ctrlBtn = nil
	self.skyDiveBtn = nil
	self.leftShootBtn = nil
	self.holdLeftBtn = nil
	self.holdQBtn = nil
	self.holdRBtn = nil
	self.basicSkillBtnGo = nil
	self.basicNormalBtnGo = nil
	self.ultSkillBtnGo = nil
	self.ultNormalBtnGo = nil
	self.ultSkillBtnGo = nil
	self.curWeaponBulletId = 0
	self.curWeaponTid = 0
	self.cachedAppropriateBullets = nil
	self.hasOpenParachute = nil
	self._canOpenParachute = nil
	self._canCutParachute = nil

	table.clear(self.skillGo)
	table.clear(self.skillNormalBtnGos)
	table.clear(self.skillBtnRootGos)
	table.clear(self.goSkills)
	table.clear(self.skillNormalBtns)
end
