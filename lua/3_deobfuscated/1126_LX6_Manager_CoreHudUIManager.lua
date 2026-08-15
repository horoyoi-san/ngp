local ParkourStateConfig = LTConfig.ParkourStateConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local MessageConfig = LTConfig.MessageConfig
local DataSet = require("LX6/DataBind/DataSet")
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local FightSkillConfig = LTConfig.FightSkillConfig
local SkillConfig = LTConfig.SkillConfig
local SkillResourcesConfig = LTConfig.SkillResourcesConfig
C_CoreHudUIManager = DefClass("C_CoreHudUIManager", C_CoreHudUIManager)
local M = C_CoreHudUIManager

function M:ctor()
	self.isNewRefresh = true
	self.skillType = {
		HeavyAttack = 5,
		JumpJump = 7,
		Basic = 2,
		ControlPower = 4,
		Dodge = 6,
		SwitchWeaponWheels = 15,
		Hold_E = 21,
		OffWall = 10,
		FightSpiritBigSkill = 3,
		Hold_Left = 20,
		Assassin = 9,
		Hold_R = 22,
		Normal = 1
	}
	self.skillEnableGroup = {
		[self.skillType.Dodge] = {
			interactable = false,
			visible = false
		}
	}
	self._MsgEvents = {}
	self.msgEvents = {
		[gEventConstants.UI_RESET] = self:CreateAction("OnResetUI"),
		[gEventConstants.PARKOUR_CLIENT_STATE_REFRESH] = self:CreateAction("OnClientStateRefresh"),
		[gEventConstants.SETTING_GAMEPAD_ADDED] = self:CreateAction("OnMobileControllerChange"),
		[gEventConstants.PAOKU_STATE_ADD_REMOVE] = self:CreateAction("OnParkourAddRemove"),
		[gEventConstants.NOTIFY_CHANGE_SKILL_RESOURCE] = self:CreateAction("OnSkillResourceChanged"),
		[gEventConstants.MIND_POWER_SWITCH_HOLD_MODE] = self:CreateAction("OnRefreshByMindPowerHold"),
		[gEventConstants.ON_TAFFY_MOTO] = self:CreateAction("OnRefreshMotoState")
	}
	self.activePlayerStates = {}
	self.isOnWall = false
	self.isInDive = false
	self.isInAir = false
	self.isHoldRangedWeapon = false
	self.isOnTaffyMoto = false
	self.canFeiSuoAttack = false
	self.canBackAssassin = false
	self.battlePanelEvent = {
		dodgeKeyDown = 9,
		skillPressUp = 5,
		skillKeyUp = 2,
		jumpKeyPress = 7,
		updateSkillState = 11,
		dodgeKeyUp = 10,
		skillKeyDown = 1,
		jumpKeyPressDown = 6,
		skillPress = 4,
		skillPressDown = 3,
		jumpKeyPressUp = 8
	}
	self.skill1State = {
		isCrouch = false,
		systemBattleUnlock = false,
		isTaFeiMoto = false,
		skillInCD = true,
		hasAssassinBuff = false,
		forbidAttack = true,
		canAssassin = false,
		isMonsterInteract = false,
		specialReplace = false,
		hasAssassinTarget = false,
		isGuideOpen = false,
		isForbidByNoSkillId = false
	}
	self.skill2State = {
		isNotHideInUnBattle = true,
		unitStateCfgNeedForbid = false,
		isEnergyEmpty = false,
		skillInCD = false,
		isHideByTipRefresh = false,
		isTestSkillSwitchOn = true,
		specialReplace = false,
		systemBattleUnlock = false,
		isGuideOpen = false,
		forbidAllBuff = false,
		isForbidByNoSkillId = false
	}
	self.skill3State = {
		isNotHideInUnBattle = false,
		isSkillFull = false,
		unitStateCfgNeedForbid = true,
		skillInCD = false,
		disableByBulletNum = false,
		isHideByTipRefresh = false,
		fightSpiritEpNotFull = true,
		unitStateCfgNeedForbidPrivateWeaponUltSkill = true,
		isTestSkillSwitchOn = true,
		specialReplace = false,
		systemBattleUnlock = false,
		isGuideOpen = false,
		forbidAllBuff = false,
		isForbidByNoSkillId = false
	}
	self.skill4State = {
		isNotHideInUnBattle = true,
		isNoMindPower = false,
		isStiffS = false,
		skillInCD = false,
		isTaFeiMoto = false,
		isHideByTipRefresh = false,
		isCrouchAssassin = false,
		isGamePadInteract = false,
		isMonsterInteract = true,
		specialReplace = false,
		systemBattleUnlock = false,
		isGuideOpen = false,
		isMindHold = false,
		isForbidByNoSkillId = false
	}
	self.heavyAttackState = {
		isGuideOpen = false,
		specialReplace = false,
		systemBattleUnlock = false,
		isTaFeiMoto = false,
		isForbidByNoSkillId = false
	}
	self.dodgeState = {
		isGuideOpen = false
	}
	self.jumpState = {
		eventForbidden = false,
		systemBattleUnlock = false,
		isGuideOpen = false,
		hideByRaidType = -1,
		hideJump = false
	}
	self.switchWeaponState = {
		isNotHideInUnBattle = true,
		unitStateCfgNeedForbid = false,
		systemBattleUnlock = false,
		isUnShow = false,
		isHandBag = false
	}
	self.holdEState = {
		isWeaponHasSkill = false,
		forbidAllBuff = false,
		isNotDiscard = false
	}
	self.holdRState = {
		isWeaponHasSkill = false
	}
	self.holdLeftState = {
		isWeaponHasSkill = false
	}
	self.skillStateList = {
		[self.skillType.Normal] = self.skill1State,
		[self.skillType.Basic] = self.skill2State,
		[self.skillType.FightSpiritBigSkill] = self.skill3State,
		[self.skillType.ControlPower] = self.skill4State,
		[self.skillType.HeavyAttack] = self.heavyAttackState,
		[self.skillType.Dodge] = self.dodgeState,
		[self.skillType.JumpJump] = self.jumpState,
		[self.skillType.SwitchWeaponWheels] = self.switchWeaponState,
		[self.skillType.Hold_Left] = self.holdLeftState,
		[self.skillType.Hold_R] = self.holdRState,
		[self.skillType.Hold_E] = self.holdEState
	}
	self.TRIGGER_TYPE = {
		DODGE = 1,
		ALL = 6,
		EQUIP = 9,
		ULTRA = 4,
		SPECIAL = 3,
		SWITCH = 7,
		NORMAL = 2,
		MIND_POWER = 5,
		HEAVY = 8
	}
	self.triggerDisableSkillVisible = {
		[self.TRIGGER_TYPE.DODGE] = false,
		[self.TRIGGER_TYPE.NORMAL] = false,
		[self.TRIGGER_TYPE.SPECIAL] = false,
		[self.TRIGGER_TYPE.ULTRA] = false,
		[self.TRIGGER_TYPE.MIND_POWER] = false,
		[self.TRIGGER_TYPE.ALL] = false,
		[self.TRIGGER_TYPE.SWITCH] = false,
		[self.TRIGGER_TYPE.HEAVY] = false,
		[self.TRIGGER_TYPE.EQUIP] = false
	}
	self.curVisible = true
	self.curInteractable = true
	self.dirtySkillTypes = {}
	self.skill1Decisions = {
		{
			func = "DecideSkill1_MonsterInteract"
		},
		{
			func = "DecideSkill1_Assassin"
		},
		{
			func = ""
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.normalAttack
		},
		{
			func = "DecideSkill1_SkillQTE"
		},
		{
			func = "DecideSkill_NoSkillId",
			type = self.skillType.Normal
		},
		{
			func = "DecideSkill_SpecialReplace2",
			type = self.skillType.Normal
		},
		{
			func = "DecideSkill1_ForbidAttack"
		},
		{
			func = "DecideSkill_SystemUnlock",
			type = self.skillType.Normal
		},
		{
			func = "DecideSkill_IsTaFeiMoto",
			type = self.skillType.Normal
		},
		{
			func = "DecideSkill_IsGuideOpen",
			type = self.skillType.Normal
		},
		{
			type = "NormalAttack",
			func = "DecideSkill_Parkour"
		},
		{
			func = "DecideSkill_SkillInCD",
			type = self.skillType.Normal
		},
		{
			func = "DecideSkill1_HidePC"
		},
		{
			func = "DecideSkill_IsMindHoldNpc"
		},
		{
			func = ""
		}
	}
	self.skill2Decisions = {
		{
			func = ""
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.basic
		},
		{
			func = "DecideSkill_SkillQTE"
		},
		{
			func = "DecideSkill_SpecialReplace2",
			type = self.skillType.Basic
		},
		{
			func = "DecideSkill_NoSkillId",
			type = self.skillType.Basic
		},
		{
			func = "DecideSkill_SystemUnlock",
			type = self.skillType.Basic
		},
		{
			func = "DecideSkill_TestSwitchOn",
			type = self.skillType.Basic
		},
		{
			func = "DecideSkill_IsGuideOpen",
			type = self.skillType.Basic
		},
		{
			func = "DecideSkill_ForbidBuff",
			type = self.skillType.Basic
		},
		{
			type = "Skill",
			func = "DecideSkill_Parkour"
		},
		{
			func = "DecideSkill_TipRefresh",
			type = self.skillType.Basic
		},
		{
			func = "DecideSkill_UnBattle",
			type = self.skillType.Basic
		},
		{
			func = "DecideSkill_UnitCfgForbid",
			type = self.skillType.Basic
		},
		{
			func = "DecideSkill_SkillInCD",
			type = self.skillType.Basic
		},
		{
			func = "DecideSkill2_EnergyEmpty"
		},
		{
			func = "DecideSkill_IsMindHoldNpc"
		},
		{
			func = ""
		}
	}
	self.skill3Decisions = {
		{
			func = ""
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.bigSkil
		},
		{
			func = "DecideSkill_SkillQTE"
		},
		{
			func = "DecideSkill_SpecialReplace2",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			func = "DecideSkill_NoSkillId",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			func = "DecideSkill_SystemUnlock",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			func = "DecideSkill_TestSwitchOn",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			func = "DecideSkill3_UnitStateUltSkill"
		},
		{
			func = "DecideSkill_IsGuideOpen",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			func = "DecideSkill_ForbidBuff",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			type = "UltSkill",
			func = "DecideSkill_Parkour"
		},
		{
			func = "DecideSkill_TipRefresh",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			func = "DecideSkill_UnBattle",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			func = "DecideSkill_UnitCfgForbid",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			func = "DecideSkill_SkillInCD",
			type = self.skillType.FightSpiritBigSkill
		},
		{
			func = "DecideSkill3_Full"
		},
		{
			func = "DecideSkill3_EpNotFull"
		},
		{
			func = "DecideSkill3_Bullet"
		},
		{
			func = ""
		}
	}
	self.skill4Decisions = {
		{
			func = ""
		},
		{
			func = "DecideSkill4_Parkour"
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.MindPower
		},
		{
			func = "DecideSkill1_SkillQTE"
		},
		{
			func = "DecideSkill4_MonsterInteract"
		},
		{
			func = "DecideSkill_SpecialReplace2",
			type = self.skillType.ControlPower
		},
		{
			func = "DecideSkill4_GamePad"
		},
		{
			func = "DecideSkill_SystemUnlock",
			type = self.skillType.ControlPower
		},
		{
			func = "DecideSkill_NoSkillId",
			type = self.skillType.ControlPower
		},
		{
			func = "DecideSkill_IsTaFeiMoto",
			type = self.skillType.ControlPower
		},
		{
			func = "DecideSkill_IsGuideOpen",
			type = self.skillType.ControlPower
		},
		{
			func = "DecideSkill_UnBattle",
			type = self.skillType.ControlPower
		},
		{
			func = "DecideSkill_TipRefresh",
			type = self.skillType.ControlPower
		},
		{
			func = "DecideSkill_SkillInCD",
			type = self.skillType.ControlPower
		},
		{
			func = "DecideSkill4_NoMindPower"
		},
		{
			func = "DecideSkill4_isStiffS"
		},
		{
			func = "DecideSkill4_isCrouchAssassin"
		},
		{
			func = "DecideSkill4_CanUseMind"
		},
		{
			func = "DecideSkill4_NeedShowByParkour"
		},
		{
			func = ""
		}
	}
	self.skill5Decisions = {
		{
			func = ""
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.HeavyAttack
		},
		{
			func = "DecideSkill_NoSkillId",
			type = self.skillType.HeavyAttack
		},
		{
			func = "DecideSkill_IsTaFeiMoto",
			type = self.skillType.HeavyAttack
		},
		{
			func = "DecideSkill_SpecialReplace2",
			type = self.skillType.HeavyAttack
		},
		{
			func = "DecideSkill_SystemUnlock",
			type = self.skillType.HeavyAttack
		},
		{
			func = "DecideSkill_IsGuideOpen",
			type = self.skillType.HeavyAttack
		},
		{
			type = "HeavyAttack",
			func = "DecideSkill_Parkour"
		},
		{
			func = "DecideSkill5_HidePC"
		},
		{
			func = ""
		}
	}
	self.skillDodgeDecisions = {
		{
			func = ""
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.dodge
		},
		{
			func = "DecideSkill_IsGuideOpen",
			type = self.skillType.Dodge
		},
		{
			type = "Dodge",
			func = "DecideSkill_Parkour"
		},
		{
			func = ""
		}
	}
	self.switchWeaponDecisions = {
		{
			func = ""
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.Weapon
		},
		{
			func = "DecideSkillSwitchWeapon_UnShow"
		},
		{
			func = "DecideSkillSwitchWeapon_UnitCfgForbid"
		},
		{
			func = "DecideSkill_SystemUnlock",
			type = self.skillType.SwitchWeaponWheels
		},
		{
			func = "DecideSkillSwitchWeapon_IsHandBag"
		},
		{
			type = "SwitchWeaponWheels",
			func = "DecideSkill_Parkour"
		},
		{
			func = "DecideSkill_UnBattle",
			type = self.skillType.SwitchWeaponWheels
		}
	}
	self.holdEDecisions = {
		{
			func = ""
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.basic
		},
		{
			type = "Hold_E",
			func = "DecideSkill_Parkour"
		},
		{
			func = "DecideSkill_WeaponHasSkill",
			type = self.skillType.Hold_E
		},
		{
			func = "DecideSkillHoldE_NotDiscard"
		},
		{
			func = "DecideSkill_ForbidBuff",
			type = self.skillType.Hold_E
		}
	}
	self.holdRDecisions = {
		{
			func = ""
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.bigSkil
		},
		{
			type = "Hold_R",
			func = "DecideSkill_Parkour"
		},
		{
			func = "DecideSkill_WeaponHasSkill",
			type = self.skillType.Hold_R
		}
	}
	self.holdLeftDecisions = {
		{
			func = ""
		},
		{
			type = "Hold_Left",
			func = "DecideSkill_Parkour"
		},
		{
			func = "DecideSkill_WeaponHasSkill",
			type = self.skillType.Hold_Left
		}
	}
	self.skillConfigs = {
		[self.skillType.Normal] = {
			decisions = self.skill1Decisions,
			state = self.skill1State
		},
		[self.skillType.Basic] = {
			decisions = self.skill2Decisions,
			state = self.skill2State
		},
		[self.skillType.FightSpiritBigSkill] = {
			decisions = self.skill3Decisions,
			state = self.skill3State
		},
		[self.skillType.ControlPower] = {
			decisions = self.skill4Decisions,
			state = self.skill4State
		},
		[self.skillType.HeavyAttack] = {
			decisions = self.skill5Decisions,
			state = self.heavyAttackState
		},
		[self.skillType.Dodge] = {
			decisions = self.skillDodgeDecisions,
			state = self.dodgeState
		},
		[self.skillType.SwitchWeaponWheels] = {
			decisions = self.switchWeaponDecisions,
			state = self.switchWeaponState
		},
		[self.skillType.Hold_E] = {
			decisions = self.holdEDecisions,
			state = self.holdEState
		},
		[self.skillType.Hold_R] = {
			decisions = self.holdRDecisions,
			state = self.holdRState
		},
		[self.skillType.Hold_Left] = {
			decisions = self.holdLeftDecisions,
			state = self.holdLeftState
		}
	}
	self.curBtnState = {
		interactable = false,
		isFinal = false,
		reason = "Default Button State",
		visible = false
	}
	self.buttonStateMonitor = DataSet.New({
		[self.skillType.Normal] = {
			false,
			false
		},
		[self.skillType.Basic] = {
			false,
			false
		},
		[self.skillType.FightSpiritBigSkill] = {
			false,
			false
		},
		[self.skillType.ControlPower] = {
			false,
			false
		},
		[self.skillType.HeavyAttack] = {
			false,
			false
		},
		[self.skillType.Dodge] = {
			false,
			false
		},
		[self.skillType.SwitchWeaponWheels] = {
			false,
			false
		},
		[self.skillType.Hold_Left] = {
			false,
			false
		},
		[self.skillType.Hold_E] = {
			false,
			false
		},
		[self.skillType.Hold_R] = {
			false,
			false
		}
	})
	self._DataSetEvents = C_DataEventSet.New()
	self.dataSetEvents = {
		{
			gPlayerManager.main.bindData,
			"banShootBthInHoldState",
			self:CreateAction("OnRefreshBanShoot")
		},
		{
			gPlayerManager.main.bindData,
			"isInSkillQTE",
			self:CreateAction("OnRefreshForSkillQTE")
		},
		{
			gPlayerManager.main.bindData,
			"canUseMindPower",
			self:CreateAction("OnRefreshMindPowerTip")
		}
	}
end

function M:OnInit()
	self:RegisterDataSetEvents(self.dataSetEvents)
	self:RegisterMessageEvents(self.msgEvents)
end

function M:InitBindData()
	local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit
	local stateForbidAttack = gMainMenuMgr:HasUnitState(UnitStateConfig.ForbidAttack)
	self.skill1State.forbidAttack = stateForbidAttack == 1 and true or false
	self.skill1State.specialReplace = false
	self.skill1State.skillInCD = false
	self.skill1State.isForbidByNoSkillId = false
	self.skill1State.isCrouch = false
	self.skill1State.canAssassin = false
	self.skill1State.hasAssassinTarget = false
	self.skill1State.hasAssassinBuff = myPlayerCSUnit and gBuffUtils.HasBuff(myPlayerCSUnit.Pid, LTConfig.BuffConfig.CanCiSha)
	self.skill1State.isTaFeiMoto = false
	local stateForbidSkill1 = gMainMenuMgr:HasUnitState(UnitStateConfig.ForbidSkill1)
	self.skill2State.unitStateCfgNeedForbid = stateForbidSkill1 == 1 and true or false
	self.skill2State.skillInCD = false
	self.skill2State.specialReplace = false
	self.skill2State.isNotHideInUnBattle = true
	self.skill2State.isTestSkillSwitchOn = gBattleSwitch.BasicAttackSwitch
	self.skill2State.isForbidByNoSkillId = false
	self.skill2State.isHideByTipRefresh = false
	self.skill2State.isEnergyEmpty = false
	local stateForbidUnique = gMainMenuMgr:HasUnitState(UnitStateConfig.ForbidSpiritUnique)
	local stateForbidPrivateWeaponUlt = gMainMenuMgr:HasUnitState(UnitStateConfig.ForbidPrivateWeaponUltSkill)
	self.skill3State.unitStateCfgNeedForbid = stateForbidUnique == 1 and true or false
	self.skill3State.unitStateCfgNeedForbidPrivateWeaponUltSkill = stateForbidPrivateWeaponUlt == 1 and true or false
	self.skill3State.skillInCD = false
	self.skill3State.isSkillFull = false
	self.skill3State.specialReplace = false
	self.skill3State.systemBattleUnlock = false
	self.skill3State.isNotHideInUnBattle = true
	self.skill3State.isTestSkillSwitchOn = gBattleSwitch.FightSpiritBigSkillSwitch
	self.skill3State.isForbidByNoSkillId = false
	self.skill3State.isHideByTipRefresh = false
	self.skill3State.fightSpiritEpNotFull = true
	self.skill3State.disableByBulletNum = false
	self.skill4State.skillInCD = false
	self.skill4State.specialReplace = false
	self.skill4State.isNoMindPower = false
	self.skill4State.isGamePadInteract = false
	self.skill4State.isNotHideInUnBattle = true
	self.skill4State.isMindHold = false
	self.skill4State.isStiffS = false
	self.skill4State.isForbidByNoSkillId = false
	self.skill4State.isMonsterInteract = true
	self.skill4State.isHideByTipRefresh = false
	self.skill4State.isCrouchAssassin = false
	self.skill4State.isTaFeiMoto = false
	self.heavyAttackState.isForbidByNoSkillId = false
	self.heavyAttackState.specialReplace = false
	self.heavyAttackState.isTaFeiMoto = false
	self.dodgeState.specialReplace = true
	self.switchWeaponState.isUnShow = false
	self.switchWeaponState.isNotHideInUnBattle = false
	self.switchWeaponState.systemBattleUnlock = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.WeaponWheel)
	self.switchWeaponState.unitStateCfgNeedForbid = gCS.UnitStateMgr:HasState(myPlayerCSUnit, UnitStateConfig.ForbidChangeWeapon)

	self:OnRefreshForComboSkill(self.skillType.Normal)
	self:OnRefreshForComboSkill(self.skillType.Basic)
	self:OnRefreshForComboSkill(self.skillType.FightSpiritBigSkill)
	self:OnRefreshForComboSkill(self.skillType.ControlPower)

	self.triggerDisableSkillVisible[self.TRIGGER_TYPE.DODGE] = gPaokuLimitManager:CheckFightNeedLimit(1)
	self.triggerDisableSkillVisible[self.TRIGGER_TYPE.NORMAL] = gPaokuLimitManager:CheckFightNeedLimit(2)
	self.triggerDisableSkillVisible[self.TRIGGER_TYPE.SPECIAL] = gPaokuLimitManager:CheckFightNeedLimit(3)
	self.triggerDisableSkillVisible[self.TRIGGER_TYPE.ULTRA] = gPaokuLimitManager:CheckFightNeedLimit(4)
	self.triggerDisableSkillVisible[self.TRIGGER_TYPE.MIND_POWER] = gPaokuLimitManager:CheckFightNeedLimit(5)
	self.triggerDisableSkillVisible[self.TRIGGER_TYPE.ALL] = gPaokuLimitManager:CheckFightNeedLimit(6)
	self.triggerDisableSkillVisible[self.TRIGGER_TYPE.SWITCH] = gPaokuLimitManager:CheckFightNeedLimit(7)
	self.triggerDisableSkillVisible[self.TRIGGER_TYPE.HEAVY] = gPaokuLimitManager:CheckFightNeedLimit(8)
	self.triggerDisableSkillVisible[self.TRIGGER_TYPE.EQUIP] = gPaokuLimitManager:CheckFightNeedLimit(9)
end

function M:OnResetUI()
	self:InitBindData()
	self:RegisterUI()
end

function M:RegisterUI()
	self:OnRefreshSkillBtn(self.skillType.Normal)
	self:OnRefreshSkillBtn(self.skillType.Basic)
	self:OnRefreshSkillBtn(self.skillType.FightSpiritBigSkill)
	self:OnRefreshSkillBtn(self.skillType.ControlPower)
	self:OnRefreshSkillBtn(self.skillType.HeavyAttack)
	self:OnRefreshSkillBtn(self.skillType.Dodge)
end

function M:RegisterDataSetEvents(eventHandlers)
	if #eventHandlers == 0 then
		return
	end

	for i = 1, #eventHandlers do
		local handler = eventHandlers[i]

		self._DataSetEvents:BindHandler(unpack(handler))
	end
end

function M:ClearDataSetEvents()
	if self._DataSetEvents then
		self._DataSetEvents:Clear()
	end
end

function M:RegisterSingleEvent(enentId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

function M:RegisterMessageEvents(eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

function M:ClearMessageEvents()
	for i, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

function M:CreateAction(action, target)
	return function (...)
		target = target or self

		if type(action) == "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

function M:CreateActionWithArgs(action, args, target)
	return function (...)
		target = target or self

		if type(action) == "string" then
			if target[action] then
				return target[action](target, args, ...)
			end
		else
			return action(target, args, ...)
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.Reconnect or switchType == gSwitchSceneType.KickToLogin then
		self:OnResetUI()
	end
end

function M:IsDodgeParkourHide()
	local visible = true
	local interactable = true
	local platform = gMainMenuMgr:GetParkourStatePlatform()

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		local dodgeConfig = gMainMenuMgr.clientStateConfig[state].Dodge

		if gCoreHudUIManager:IsParkourStateValid(dodgeConfig, platform) then
			visible = visible and dodgeConfig[platform].visible
			interactable = interactable and dodgeConfig[platform].interactable
		end
	end

	return visible, interactable
end

function M:IsJumpParkourHide()
	local visible = true
	local interactable = true
	local platform = gMainMenuMgr:GetParkourStatePlatform()

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		local jumpConfig = gMainMenuMgr.clientStateConfig[state].JumpJump

		if gCoreHudUIManager:IsParkourStateValid(jumpConfig, platform) then
			visible = visible and jumpConfig[platform].visible
			interactable = interactable and jumpConfig[platform].interactable
		end
	end

	return visible, interactable
end

function M:IsShiftHideForTrigger()
	return gPaokuLimitManager:CheckFightNeedLimit(LX6.PaoKu.FightLimitType.dodge)
end

function M:DecideSkill_SkillInCD(type)
	if not self.skillStateList[type] or self.skillStateList[type].skillInCD == nil then
		print_error("[CoreHudUIManager]DecideSkill_SkillInCD: skillStateList is null")

		return
	end

	local skillInCD = self.skillStateList[type].skillInCD
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not skillInCD
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "skillInCD == " .. tostring(skillInCD) or nil

	return btn
end

function M:DecideSkill_SystemUnlock(type)
	if not self.skillStateList[type] or self.skillStateList[type].systemBattleUnlock == nil then
		print_error("[CoreHudUIManager]DecideSkill_SystemUnlock: skillStateList is null")

		return
	end

	local systemUnlock = self.skillStateList[type].systemBattleUnlock
	local btn = self.curBtnState
	btn.visible = systemUnlock
	btn.interactable = systemUnlock
	btn.isFinal = not systemUnlock
	btn.reason = gMainMenuMgr.ShowTestMsg and "systemUnlock == " .. tostring(systemUnlock) or nil

	return btn
end

function M:DecideSkill_SpecialReplace(type)
	if not self.skillStateList[type] or self.skillStateList[type].specialReplace == nil then
		print_error("[CoreHudUIManager]DecideSkill_SpecialReplace: skillStateList is null")

		return
	end

	local specialReplace = self.skillStateList[type].specialReplace
	local btn = self.curBtnState
	btn.visible = specialReplace
	btn.interactable = specialReplace
	btn.isFinal = not specialReplace
	btn.reason = gMainMenuMgr.ShowTestMsg and "SpecialReplace == " .. tostring(specialReplace) or nil

	return btn
end

function M:DecideSkill_SpecialReplace2(type)
	if not self.skillStateList[type] or self.skillStateList[type].specialReplace == nil then
		print_error("[CoreHudUIManager]DecideSkill_SpecialReplace2: skillStateList is null")

		return
	end

	local specialReplace = self.skillStateList[type].specialReplace
	local btn = self.curBtnState
	btn.visible = not specialReplace
	btn.interactable = not specialReplace
	btn.isFinal = specialReplace
	btn.reason = gMainMenuMgr.ShowTestMsg and "SpecialReplace2 == " .. tostring(specialReplace) or nil

	return btn
end

function M:DecideSkill_NoSkillId(type)
	if not self.skillStateList[type] or self.skillStateList[type].isForbidByNoSkillId == nil then
		print_error("[CoreHudUIManager]DecideSkill_NoSkillId: skillStateList is null")

		return
	end

	local noSkillId = self.skillStateList[type].isForbidByNoSkillId
	local btn = self.curBtnState
	btn.visible = not noSkillId
	btn.interactable = not noSkillId
	btn.isFinal = noSkillId
	btn.reason = gMainMenuMgr.ShowTestMsg and "noSkillId == " .. tostring(noSkillId) or nil

	return btn
end

function M:DecideSkill_Trigger(type)
	if not type then
		return
	end

	local hideTrigger = gPaokuLimitManager:CheckFightNeedLimit(type)

	if type == LX6.PaoKu.FightLimitType.MindPower and self.isEnableMindPowerIndoor then
		hideTrigger = false
	end

	local btn = self.curBtnState
	btn.visible = not hideTrigger
	btn.interactable = not hideTrigger
	btn.isFinal = hideTrigger
	btn.reason = gMainMenuMgr.ShowTestMsg and "hideTrigger == " .. tostring(hideTrigger) or nil

	return btn
end

function M:DecideSkill_Parkour(type)
	if not type then
		return
	end

	local visible = true
	local interactable = true
	local platform = gMainMenuMgr:GetParkourStatePlatform()
	local stateAll = ""
	local stateCount = 0

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		stateCount = stateCount + 1
		stateAll = stateAll .. "/" .. state
		local skill1Config = gMainMenuMgr.clientStateConfig[state][type]

		if gCoreHudUIManager:IsParkourStateValid(skill1Config, platform) then
			visible = visible and skill1Config[platform].visible
			interactable = interactable and skill1Config[platform].interactable
		end
	end

	if stateCount == 0 then
		print_warn("@xuchenfei 存在刷新状态时跑酷状态为空 检查按键显隐是否正确", type, gMainMenuMgr:GetClientState())
	end

	local btn = self.curBtnState
	btn.visible = visible
	btn.interactable = interactable
	btn.isFinal = not visible and not interactable
	btn.reason = gMainMenuMgr.ShowTestMsg and "ParkourState: " .. tostring(visible) .. "/" .. tostring(interactable) .. "/" .. stateAll or nil

	return btn
end

function M:DecideSkill_UnBattle(type)
	if not self.skillStateList[type] or self.skillStateList[type].isNotHideInUnBattle == nil then
		return
	end

	local notHide = self.skillStateList[type].isNotHideInUnBattle
	local btn = self.curBtnState

	if type == self.skillType.ControlPower then
		if not notHide and not self:IsSkill4NeedShowByParkour() then
			btn.visible = false
		else
			btn.visible = true
		end
	else
		btn.visible = notHide
	end

	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isNotHideInUnBattle == " .. tostring(notHide) or nil

	return btn
end

function M:DecideSkill_TipRefresh(type)
	if not self.skillStateList[type] or self.skillStateList[type].isHideByTipRefresh == nil then
		return
	end

	local hideByTip = self.skillStateList[type].isHideByTipRefresh
	local btn = self.curBtnState

	if type == self.skillType.ControlPower then
		if hideByTip and not self:IsSkill4NeedShowByParkour() then
			btn.visible = false
		else
			btn.visible = true
		end
	else
		btn.visible = not hideByTip
	end

	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isHideByTipRefresh == " .. tostring(hideByTip) or nil

	return btn
end

function M:DecideSkill_TestSwitchOn(type)
	if not self.skillStateList[type] or self.skillStateList[type].isTestSkillSwitchOn == nil then
		return
	end

	local testSwitchOn = self.skillStateList[type].isTestSkillSwitchOn
	local btn = self.curBtnState
	btn.visible = testSwitchOn
	btn.interactable = testSwitchOn
	btn.isFinal = not testSwitchOn
	btn.reason = gMainMenuMgr.ShowTestMsg and "isTestSkillSwitchOn == " .. tostring(testSwitchOn) or nil

	return btn
end

function M:DecideSkill_UnitCfgForbid(type)
	if not self.skillStateList[type] or self.skillStateList[type].unitStateCfgNeedForbid == nil then
		return
	end

	local unitCfgForbid = self.skillStateList[type].unitStateCfgNeedForbid
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not unitCfgForbid
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "unitStateCfgNeedForbid == " .. tostring(unitCfgForbid) or nil

	return btn
end

function M:DecideSkill_WeaponHasSkill(type)
	if not self.skillStateList[type] or self.skillStateList[type].isWeaponHasSkill == nil then
		return
	end

	local isWeaponHasSkill = self.skillStateList[type].isWeaponHasSkill
	local btn = self.curBtnState
	btn.visible = isWeaponHasSkill
	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isWeaponHasSkill == " .. tostring(isWeaponHasSkill) or nil

	return btn
end

function M:DecideSkill_ForbidBuff(type)
	if not self.skillStateList[type] or self.skillStateList[type].forbidAllBuff == nil then
		print_error("[CoreHudUIManager]DecideSkill_ForbidBuff: skillStateList is null")

		return
	end

	local forbidAllBuff = self.skillStateList[type].forbidAllBuff
	local btn = self.curBtnState
	btn.visible = not forbidAllBuff
	btn.interactable = not forbidAllBuff
	btn.isFinal = forbidAllBuff
	btn.reason = gMainMenuMgr.ShowTestMsg and "ForforbidAllBuffbidAllBuff == " .. tostring(forbidAllBuff) or nil

	return btn
end

function M:DecideSkill_SkillQTE()
	local skillQTE = gPlayerManager.main.bindData.isInSkillQTE
	local btn = self.curBtnState
	btn.visible = not skillQTE
	btn.interactable = not skillQTE
	btn.isFinal = skillQTE
	btn.reason = gMainMenuMgr.ShowTestMsg and "skillQTE == " .. tostring(skillQTE) or nil

	return btn
end

function M:DecideSkill1_ForbidAttack()
	local forbidAttack = self.skill1State.forbidAttack
	local btn = self.curBtnState
	btn.visible = not forbidAttack
	btn.interactable = not forbidAttack
	btn.isFinal = forbidAttack
	btn.reason = gMainMenuMgr.ShowTestMsg and "forbidAttack == " .. tostring(forbidAttack) or nil

	return btn
end

function M:DecideSkill1_SkillQTE()
	local skillQTE = gPlayerManager.main.bindData.isInSkillQTE or gPlayerManager.main.bindData.banShootBthInHoldState
	local btn = self.curBtnState
	btn.visible = not skillQTE
	btn.interactable = not skillQTE
	btn.isFinal = skillQTE
	btn.reason = gMainMenuMgr.ShowTestMsg and "skillQTE == " .. tostring(skillQTE) or nil

	return btn
end

function M:isSkill1NeedShowByParkou()
	local needShowNormalAttackBtn = false

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		if state == ParkourStateConfig.Crouch or state == ParkourStateConfig.CrouchRun or state == ParkourStateConfig.CrouchMagnet or state == ParkourStateConfig.HoldBlend and not gPlayerManager.main.bindData.banShootBthInHoldState then
			needShowNormalAttackBtn = true

			gMainMenuMgr:ShowMainMenuMgrMessageTipsOnEditor("普攻被强制显示 状态:" .. state)
		end
	end

	return needShowNormalAttackBtn
end

function M:DecideSkill1_HidePC()
	local needHideBtn = gCS.LuaUtils.IsNonMobileAdaptive() and gBattleMgr.scheme == SGUI.GameDevice.KeyboardMouse and not self:isSkill1NeedShowByParkou()
	local btn = self.curBtnState
	btn.visible = not needHideBtn
	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "HidePC == " .. tostring(needHideBtn) or nil

	return btn
end

function M:DecideSkill1_Assassin()
	local btn = self.curBtnState

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.Crouch) or gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.CrouchRun) then
		if not self.skill1State.hasAssassinBuff then
			btn.visible = false
			btn.interactable = false
			btn.isFinal = true
			btn.reason = gMainMenuMgr.ShowTestMsg and "hasAssassinBuff == " .. tostring(self.skill1State.hasAssassinBuff) or nil
		elseif not self.skill1State.hasAssassinTarget or not self.skill1State.canAssassin then
			btn.visible = true
			btn.interactable = false
			btn.isFinal = false
			btn.reason = gMainMenuMgr.ShowTestMsg and "hasAssassinTarget == " .. tostring(self.skill1State.hasAssassinTarget) .. " canAssassin:" .. tostring(self.skill1State.canAssassin) or nil
		else
			btn.visible = true
			btn.interactable = true
			btn.isFinal = true
			btn.reason = gMainMenuMgr.ShowTestMsg and "revive by Assassin" or nil
		end
	else
		btn.visible = true
		btn.interactable = true
		btn.isFinal = false
		btn.reason = gMainMenuMgr.ShowTestMsg and "No Assassin ParkouState" or nil
	end

	return btn
end

function M:DecideSkill1_MonsterInteract()
	local interact = self.skill1State.isMonsterInteract
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = true
	btn.isFinal = interact
	btn.reason = gMainMenuMgr.ShowTestMsg and "isMonsterInteract == " .. tostring(interact) or nil

	return btn
end

function M:DecideSkill3_Full()
	local skillFull = self.skill3State.isSkillFull
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not skillFull
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isSkillFull == " .. tostring(skillFull) or nil

	return btn
end

function M:DecideSkill3_EpNotFull()
	local EpNotFull = self.skill3State.fightSpiritEpNotFull
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not EpNotFull
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "fightSpiritEpNotFull == " .. tostring(EpNotFull) or nil

	return btn
end

function M:DecideSkill3_Bullet()
	local disableByBulletNum = self.skill3State.disableByBulletNum
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not disableByBulletNum
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "disableByBulletNum == " .. tostring(disableByBulletNum) or nil

	return btn
end

function M:DecideSkill3_UnitStateUltSkill()
	local UltSkill = self.skill3State.unitStateCfgNeedForbidPrivateWeaponUltSkill
	local btn = self.curBtnState
	btn.visible = not UltSkill
	btn.interactable = not UltSkill
	btn.isFinal = UltSkill
	btn.reason = gMainMenuMgr.ShowTestMsg and "unitStateCfgNeedForbidPrivateWeaponUltSkill=" .. tostring(UltSkill) or nil

	return btn
end

function M:IsSkill4NeedShowByParkour()
	if self.needShowMindPowerBtn == nil then
		print_error("[[CoreHudUIManager]IsSkill4NeedShowByParkour: needShowMindPowerBtn is nil")

		return false
	end

	return self.needShowMindPowerBtn
end

function M:DecideSkill4_NeedShowByParkour()
	local needShowMindPowerBtn = self:IsSkill4NeedShowByParkour()
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = true
	btn.isFinal = not self.curVisible and self.curInteractable and needShowMindPowerBtn
	btn.reason = gMainMenuMgr.ShowTestMsg and "needShowMindPowerBtn= " .. tostring(needShowMindPowerBtn) or nil

	return btn
end

function M:DecideSkill4_CanUseMind()
	local canUseMindPower = gPlayerManager.main.bindData.canUseMindPower
	local btn = self.curBtnState
	btn.isFinal = false
	btn.visible = true
	btn.interactable = true
	local isFromHasMindPowerTarget = false

	if self.curVisible == true and self.curInteractable == true and not canUseMindPower then
		isFromHasMindPowerTarget = true
		btn.interactable = false
	end

	gCS.MindPowerMgr.mindPowerBtnDisableByNoItem = isFromHasMindPowerTarget
	btn.reason = gMainMenuMgr.ShowTestMsg and "canUseMindPower=" .. tostring(canUseMindPower) or nil

	return btn
end

function M:DecideSkill4_Parkour()
	local visible = true
	local interactable = true
	self.needShowMindPowerBtn = false
	local platform = gMainMenuMgr:GetParkourStatePlatform()

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		local mindConfig = gMainMenuMgr:GetParkourStateMindPowerMode(gMainMenuMgr.clientStateConfig[state])

		if gCoreHudUIManager:IsParkourStateValid(mindConfig, platform) then
			local parkourConfig = mindConfig[platform]

			if (state == ParkourStateConfig.Crouch or state == ParkourStateConfig.CrouchRun) and parkourConfig.visible == true and parkourConfig.interactable == true then
				self.needShowMindPowerBtn = true
			else
				visible = visible and mindConfig[platform].visible
				interactable = interactable and mindConfig[platform].interactable
			end
		end
	end

	local btn = self.curBtnState
	btn.visible = visible
	btn.interactable = interactable
	btn.isFinal = not visible and not interactable
	btn.reason = gMainMenuMgr.ShowTestMsg and "ParkourState: " .. tostring(visible) .. "/" .. tostring(interactable) or nil

	return btn
end

function M:DecideSkill4_GamePad()
	local gamePadInteract = self.skill4State.isGamePadInteract
	local btn = self.curBtnState
	btn.visible = not gamePadInteract
	btn.interactable = not gamePadInteract
	btn.isFinal = gamePadInteract
	btn.reason = gMainMenuMgr.ShowTestMsg and "isGamePadInteract=" .. tostring(gamePadInteract) or nil

	return btn
end

function M:DecideSkill4_NoMindPower()
	local noMindPower = self.skill4State.isNoMindPower
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not noMindPower
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isNoMindPower=" .. tostring(noMindPower) or nil

	return btn
end

function M:DecideSkill4_isStiffS()
	local isStiffS = self.skill4State.isStiffS
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not isStiffS
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isStiffS=" .. tostring(isStiffS) or nil

	return btn
end

function M:DecideSkill4_isCrouchAssassin()
	local crouchAss = self.skill4State.isCrouchAssassin
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not crouchAss
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isCrouchAssassin=" .. tostring(crouchAss) or nil

	return btn
end

function M:DecideSkill4_MonsterInteract()
	local interact = self.skill4State.isMonsterInteract
	local btn = self.curBtnState
	btn.visible = interact
	btn.interactable = interact
	btn.isFinal = not interact
	btn.reason = gMainMenuMgr.ShowTestMsg and "isMonsterInteract=" .. tostring(interact) or nil
	gCS.MindPowerMgr.needShowMindHintIcon = not interact

	return btn
end

function M:DecideSkill_IsTaFeiMoto(type)
	if not self.skillStateList[type] or self.skillStateList[type].isTaFeiMoto == nil then
		return
	end

	local isTaFeiMoto = self.skillStateList[type].isTaFeiMoto
	local btn = self.curBtnState
	btn.visible = not isTaFeiMoto
	btn.interactable = not isTaFeiMoto
	btn.isFinal = isTaFeiMoto
	btn.reason = gMainMenuMgr.ShowTestMsg and "isTaFeiMoto=" .. tostring(isTaFeiMoto) or nil

	return btn
end

function M:DecideSkill_IsGuideOpen(type)
	if not self.skillStateList[type] or self.skillStateList[type].isGuideOpen == nil then
		return
	end

	local isGuideOpen = self.skillStateList[type].isGuideOpen
	local btn = self.curBtnState
	btn.visible = not isGuideOpen
	btn.interactable = not isGuideOpen
	btn.isFinal = isGuideOpen
	btn.reason = gMainMenuMgr.ShowTestMsg and "isGuideOpen=" .. tostring(isGuideOpen) or nil

	return btn
end

function M:DecideSkill5_HidePC()
	local needHideBtn = gCS.LuaUtils.IsNonMobileAdaptive() and gBattleMgr.scheme == SGUI.GameDevice.KeyboardMouse
	local btn = self.curBtnState
	btn.visible = not needHideBtn
	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "HidePC= " .. tostring(needHideBtn) or nil

	return btn
end

function M:DecideSkillSwitchWeapon_UnitCfgForbid()
	local unitStateCfgNeedForbid = self.switchWeaponState.unitStateCfgNeedForbid
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not unitStateCfgNeedForbid
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "UnitCfgForbid=" .. tostring(unitStateCfgNeedForbid) or nil

	return btn
end

function M:DecideSkillSwitchWeapon_UnShow()
	local unShow = self.switchWeaponState.isUnShow
	local btn = self.curBtnState
	btn.visible = unShow
	btn.interactable = unShow
	btn.isFinal = not unShow
	btn.reason = gMainMenuMgr.ShowTestMsg and "unShow=" .. tostring(unShow) or nil

	return btn
end

function M:DecideSkillSwitchWeapon_IsHandBag()
	local isHandBag = self.switchWeaponState.isHandBag
	local btn = self.curBtnState
	btn.visible = not isHandBag
	btn.interactable = not isHandBag
	btn.isFinal = isHandBag
	btn.reason = gMainMenuMgr.ShowTestMsg and "isHandBag=" .. tostring(isHandBag) or nil

	return btn
end

function M:DecideSkill2_EnergyEmpty()
	local emptyEnergy = self.skill2State.isEnergyEmpty
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not emptyEnergy
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "emptyEnergy=" .. tostring(emptyEnergy) or nil

	return btn
end

function M:DecideSkill_IsMindHoldNpc()
	local isHoldNpc = gCS.MindPowerMgr.AimItem and gCS.MindPowerMgr.AimItem.ItemType == MindPowerConst.MindObjType.Npc
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not isHoldNpc
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isHoldNpc=" .. tostring(isHoldNpc) or nil

	return btn
end

function M:DecideSkillHoldE_NotDiscard()
	local notDiscard = self.holdEState.isNotDiscard
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not notDiscard
	btn.isFinal = notDiscard
	btn.reason = gMainMenuMgr.ShowTestMsg and "notDiscard=" .. tostring(notDiscard) or nil

	return btn
end

function M:OnSetSkillBtnState(skillType, requireName, requireSatisfied, needRefreshNow)
	local config = self.skillConfigs[skillType]

	if not config or not config.state then
		print_error("[CoreHudUIManager]OnRefreshSkillBtn:Invalid skill index", skillType)

		return
	end

	local state = config.state

	if requireName and requireSatisfied ~= nil then
		if state[requireName] == requireSatisfied then
			return
		end

		state[requireName] = requireSatisfied

		if skillType == self.skillType.Normal and (requireName == "hasAssassinTarget" or requireName == "canAssassin") then
			gMessageManager:SendMessage(gEventConstants.ON_UPDATE_BASIC_SKILL)
		end
	end

	if needRefreshNow then
		self:OnRefreshSkillBtn(skillType)
	elseif not table.contains(self.dirtySkillTypes, skillType) then
		table.insert(self.dirtySkillTypes, skillType)
	end
end

function M:OnRefreshSkillBtn(skillType, isForce)
	local config = self.skillConfigs[skillType]

	if not config or not config.state or not config.decisions then
		print_error("[CoreHudUIManager]OnRefreshSkillBtn:Invalid skill index", skillType)

		return
	end

	local decisions = config.decisions
	self.curVisible = true
	self.curInteractable = true
	local log = " [decisions]:"

	for i = 1, #decisions do
		if decisions[i] and decisions[i].func then
			if self[decisions[i].func] then
				local result = nil

				if decisions[i].type then
					result = self[decisions[i].func](self, decisions[i].type)
				else
					result = self[decisions[i].func](self)
				end

				if not result or result.visible == nil or result.interactable == nil then
					print_error("[CoreHudUIManager]OnRefreshSkillBtn:Decision Func Wrong:", i, "skillType:", skillType)

					return
				end

				if result.isFinal then
					self.curVisible = result.visible
					self.curInteractable = result.interactable

					if gMainMenuMgr.ShowTestMsg then
						log = log .. string.format(" %s->%s/%s %s|| ", result.reason, self.curVisible, self.curInteractable, result.isFinal and "final" or "")
					end

					break
				end

				if not result.visible then
					self.curVisible = false
				end

				if not result.interactable then
					self.curInteractable = false
				end

				if gMainMenuMgr.ShowTestMsg then
					log = log .. string.format(" %s->%s/%s %s|| ", result.reason, self.curVisible, self.curInteractable, result.isFinal and "final" or "")
				end
			end
		end
	end

	if skillType == self.skillType.ControlPower then
		gCS.MindPowerMgr.mindPowerBtnIsAble = self.curInteractable
	end

	if gMainMenuMgr.ShowTestMsg then
		log = string.format("[ButtonState] %s: visible=%s, interactable=%s | ", skillType, tostring(self.curVisible), tostring(self.curInteractable)) .. log

		gMainMenuMgr:ShowMainMenuMgrMessageTipsOnEditor(log)
	end

	if self.buttonStateMonitor[skillType][1] ~= self.curVisible or self.buttonStateMonitor[skillType][2] ~= self.curInteractable or isForce then
		self.buttonStateMonitor[skillType][1] = self.curVisible
		self.buttonStateMonitor[skillType][2] = self.curInteractable

		self.buttonStateMonitor.SendBindEvent(self.buttonStateMonitor, skillType, self.buttonStateMonitor[skillType])
	end
end

function M:OnLateUpdate()
	if #self.dirtySkillTypes > 0 then
		for i = 1, #self.dirtySkillTypes do
			self:OnRefreshSkillBtn(self.dirtySkillTypes[i])
		end

		table.clear(self.dirtySkillTypes)
	end

	if self.isPlayerStateDirty then
		gMessageManager:SendMessage(gEventConstants.ON_PLAYER_STATE_CHANGE, self.activePlayerStates)

		self.isPlayerStateDirty = false
	end
end

function M:OnRefreshDodge(requireName, requireSatisfied)
	local visible = true
	local interactable = true

	if requireName and requireSatisfied ~= nil then
		if self.dodgeState[requireName] == requireSatisfied then
			return
		else
			self.dodgeState[requireName] = requireSatisfied
		end
	end

	if self:IsShiftHideForTrigger() then
		visible = false
		interactable = false
	elseif self.dodgeState.isGuideOpen or not self.dodgeState.specialReplace then
		visible = false
		interactable = false
	else
		visible, interactable = self:IsDodgeParkourHide()
	end

	self.skillEnableGroup[self.skillType.Dodge].visible = visible
	self.skillEnableGroup[self.skillType.Dodge].interactable = interactable

	gMessageManager:SendMessage(gEventConstants.ON_SKILL_BTN_REFRESH, self.skillType.Dodge)
end

function M:OnRefreshJump(requireName, requireSatisfied)
	local visible = true
	local interactable = true

	if requireName and requireSatisfied ~= nil then
		if self.jumpState[requireName] == requireSatisfied then
			return
		else
			self.jumpState[requireName] = requireSatisfied
		end
	end

	if not self.jumpState.systemBattleUnlock or gPlayerManager.main.bindData.isInLift or gPaokuLimitManager:CheckInDisableJump() then
		visible = false
		interactable = false

		gMainMenuMgr:ShowMainMenuMgrMessageTipsOnEditor("跳跃禁用 isInLift")
	elseif self.jumpState.hideByRaidType == 2 or self.jumpState.eventForbidden or gPlayerManager.main.bindData.isInZipLine or self.jumpState.hideJump then
		interactable = false

		gMainMenuMgr:ShowMainMenuMgrMessageTipsOnEditor("跳跃显示不可用")
	else
		visible, interactable = self:IsJumpParkourHide()
	end

	self.skillEnableGroup[self.skillType.JumpJump].visible = visible
	self.skillEnableGroup[self.skillType.JumpJump].interactable = interactable

	gMessageManager:SendMessage(gEventConstants.ON_SKILL_BTN_REFRESH, self.skillType.JumpJump)
end

function M:GetBattleSkillEnable(skillType)
	return self.skillEnableGroup[skillType]
end

function M:GetBattleSkillInteractable(skillType)
	return self.buttonStateMonitor[skillType] and self.buttonStateMonitor[skillType][2] or false
end

function M:OnRefreshForAwakeUI()
	self:OnRefreshSkillBtn(self.skillType.Normal, true)
	self:OnRefreshSkillBtn(self.skillType.Basic, true)
	self:OnRefreshSkillBtn(self.skillType.FightSpiritBigSkill, true)
	self:OnRefreshSkillBtn(self.skillType.ControlPower, true)
	self:OnRefreshSkillBtn(self.skillType.HeavyAttack, true)
	self:OnRefreshSkillBtn(self.skillType.Dodge, true)
	self:OnRefreshSkillBtn(self.skillType.SwitchWeaponWheels, true)
	self:OnRefreshSkillBtn(self.skillType.Hold_E, true)
	self:OnRefreshSkillBtn(self.skillType.Hold_R, true)
	self:OnRefreshSkillBtn(self.skillType.Hold_Left, true)
end

function M:OnRefreshForSkillQTE()
	self:OnRefreshSkillBtn(self.skillType.Normal)
	self:OnRefreshSkillBtn(self.skillType.Basic)
	self:OnRefreshSkillBtn(self.skillType.FightSpiritBigSkill)
	self:OnRefreshSkillBtn(self.skillType.ControlPower)
	self:OnRefreshSkillBtn(self.skillType.HeavyAttack)
end

function M:OnRefreshForComboSkill(index)
	if index == self.skillType.Basic then
		self:OnRefreshSkillBtn(index)
	elseif index == self.skillType.Normal then
		self:OnRefreshSkillBtn(index)
	elseif index == self.skillType.FightSpiritBigSkill then
		self:OnRefreshSkillBtn(index)
	elseif index == self.skillType.ControlPower then
		self:OnRefreshSkillBtn(self.skillType.ControlPower)
	elseif index == self.skillType.HeavyAttack then
		self:OnRefreshSkillBtn(self.skillType.HeavyAttack)
	end
end

function M:OnRefreshTriggerDisable(triggerIndex, triggerState)
	if self.triggerDisableSkillVisible[triggerIndex] ~= triggerState then
		self.triggerDisableSkillVisible[triggerIndex] = triggerState

		if triggerIndex == self.TRIGGER_TYPE.DODGE then
			self:OnRefreshSkillBtn(self.skillType.Dodge)
		elseif triggerIndex == self.TRIGGER_TYPE.NORMAL then
			self:OnRefreshSkillBtn(self.skillType.Normal)
		elseif triggerIndex == self.TRIGGER_TYPE.SPECIAL then
			self:OnRefreshSkillBtn(self.skillType.Basic)
			self:OnRefreshSkillBtn(self.skillType.Hold_E)
		elseif triggerIndex == self.TRIGGER_TYPE.ULTRA then
			self:OnRefreshSkillBtn(self.skillType.FightSpiritBigSkill)
			self:OnRefreshSkillBtn(self.skillType.Hold_R)
		elseif triggerIndex == self.TRIGGER_TYPE.MIND_POWER then
			self:OnRefreshSkillBtn(self.skillType.ControlPower)
		elseif triggerIndex == self.TRIGGER_TYPE.HEAVY then
			self:OnRefreshSkillBtn(self.skillType.HeavyAttack)
		elseif triggerIndex == self.TRIGGER_TYPE.EQUIP then
			self:OnRefreshSkillBtn(self.skillType.SwitchWeaponWheels)
		elseif triggerIndex == self.TRIGGER_TYPE.ALL then
			self:OnRefreshSkillBtn(self.skillType.Normal)
			self:OnRefreshSkillBtn(self.skillType.Basic)
			self:OnRefreshSkillBtn(self.skillType.Hold_E)
			self:OnRefreshSkillBtn(self.skillType.Hold_R)
			self:OnRefreshSkillBtn(self.skillType.FightSpiritBigSkill)
			self:OnRefreshSkillBtn(self.skillType.ControlPower)
			self:OnRefreshSkillBtn(self.skillType.HeavyAttack)
			self:OnRefreshSkillBtn(self.skillType.Dodge)
			self:OnRefreshSkillBtn(self.skillType.SwitchWeaponWheels)
			gMessageManager:SendMessage(gEventConstants.ON_TAFFY_FIGHT_LIMIT)
		end
	end

	if triggerState == true then
		self:OnTriggerSkillBtnClose()
	end
end

function M:OnRefreshTriggerDisableFromDic(battleDic)
	for i = 1, self.triggerDisableSkillVisible.Count do
		if not battleDic or not battleDic[i] then
			self:OnRefreshTriggerDisable(i, false)
		else
			self:OnRefreshTriggerDisable(i, battleDic[i] == 1 and true or false)

			if battleDic[i] == 1 then
				gBattleMgr:DoSthWhenSkillBtnClose()
			end
		end
	end
end

function M:OnTriggerSkillBtnClose()
	local forbidSkillBtnFlag = false

	if self.triggerDisableSkillVisible[self.TRIGGER_TYPE.ALL] == true then
		gBattleMgr:BtnSkillPressUp(self.skillType.Normal)
		gBattleMgr:BtnSkillPressUp(self.skillType.Basic)
		gBattleMgr:BtnSkillPressUp(self.skillType.FightSpiritBigSkill)
		gBattleMgr:BtnSkillPressUp(self.skillType.ControlPower)

		return true
	end

	if self.triggerDisableSkillVisible[self.TRIGGER_TYPE.NORMAL] == true then
		gBattleMgr:BtnSkillPressUp(self.skillType.Normal)

		forbidSkillBtnFlag = true
	end

	if self.triggerDisableSkillVisible[self.TRIGGER_TYPE.SPECIAL] == true then
		gBattleMgr:BtnSkillPressUp(self.skillType.Basic)

		forbidSkillBtnFlag = true
	end

	if self.triggerDisableSkillVisible[self.TRIGGER_TYPE.ULTRA] == true then
		gBattleMgr:BtnSkillPressUp(self.skillType.FightSpiritBigSkill)

		forbidSkillBtnFlag = true
	end

	if self.triggerDisableSkillVisible[self.TRIGGER_TYPE.MIND_POWER] == true then
		gBattleMgr:BtnSkillPressUp(self.skillType.ControlPower)

		forbidSkillBtnFlag = true
	end

	return forbidSkillBtnFlag
end

function M:ClearTriggerDisableSkill()
	for i = 1, #self.triggerDisableSkillVisible do
		self:OnRefreshTriggerDisable(i, false)
	end
end

function M:OnRefreshBanShoot(data)
	self:OnRefreshSkillBtn(self.skillType.Normal)
	self:OnRefreshSkillBtn(self.skillType.ControlPower)
end

function M:OnRefreshMindPowerTip(data)
	self:OnRefreshSkillBtn(self.skillType.ControlPower)
end

function M:OnClientStateRefresh(eventId, msg)
	local btnType = msg.state
	local visible = msg.visible
	local interactable = msg.interactable

	if btnType == self.skillType.Normal or btnType == self.skillType.Basic or btnType == self.skillType.FightSpiritBigSkill or btnType == self.skillType.ControlPower or btnType == self.skillType.HeavyAttack or btnType == self.skillType.SwitchWeaponWheels or btnType == self.skillType.Hold_E or btnType == self.skillType.Hold_R or btnType == self.skillType.Hold_Left or btnType == self.skillType.Dodge then
		if not table.contains(self.dirtySkillTypes, btnType) then
			table.insert(self.dirtySkillTypes, btnType)
		end
	elseif btnType == self.skillType.Assassin then
		self:OnRefreshSkillBtn(self.skillType.Normal)
	end
end

function M:IsParkourStateValid(stateConfig, platform)
	if type(stateConfig) ~= "table" or not stateConfig[platform] or stateConfig[platform].visible == nil or stateConfig[platform].interactable == nil then
		print_error("[CoreHudUIManager]IsParkourStateValid: Wrong StateConfig")
	end

	return type(stateConfig) == "table" and stateConfig[platform] and stateConfig[platform].visible ~= nil and stateConfig[platform].interactable ~= nil
end

function M:GetNormalSkillText()
	local flag = false
	local textId = 89901016
	local highLight = false

	if gPlayerManager.main.bindData.isMindPowerAim then
		flag = true
		textId = 89901016
	end

	if self.skill1State.isCrouch then
		flag = true
		textId = 89901128
	end

	if self.skill1State.canAssassin or self.canBackAssassin then
		highLight = true
	end

	if gBattleMgr.showPlayerHint and not gBattleMgr.showBaoShuaiHint and not gBattleMgr.showWASDHint then
		highLight = true
	end

	return flag, textId, highLight
end

function M:SetCanPedalOut(enable)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	store:SetCanPedalOut(enable)
end

function M:SetCanPedalUp(enable)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	store:SetCanPedalUp(enable)
end

function M:SetCanPedalJumpOut(enable)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	store:SetCanPedalJumpOut(enable)
end

function M:OnParkourAddRemove(eventId, data)
	if not data then
		return
	end

	local isAdd = data.isAdd
	local parkourStateId = data.parkourStateId

	if not isAdd and (parkourStateId == ParkourStateConfig.Crouch or parkourStateId == ParkourStateConfig.CrouchRun or parkourStateId == ParkourStateConfig.CrouchMagnet) then
		self:OnRefreshSkillBtn(self.skillType.Normal)
	end
end

function M:SetParkourPlayerState(stateKey, isActive)
	if self.activePlayerStates[stateKey] ~= isActive then
		if isActive then
			self.activePlayerStates[stateKey] = true
		else
			self.activePlayerStates[stateKey] = false
		end

		self.isPlayerStateDirty = true
	end
end

function M:SetOnWall(onWallState)
	self:SetParkourPlayerState(gParkourPlayerStateType.WALL, onWallState)
end

function M:SetInAir(inAirState)
	self:SetParkourPlayerState(gParkourPlayerStateType.AIR, inAirState)
end

function M:SetInWater(inWaterState)
	self:SetParkourPlayerState(gParkourPlayerStateType.WATER, inWaterState)
end

function M:SetInDive(inDiveState, O2Max, O2LowThreshold)
	self.isInDive = inDiveState
	self.O2Max = O2Max
	self.O2LowThreshold = O2LowThreshold

	if self.isInDive then
		gClientToGameSceneDelegate:AskPlayerEnterWater().Callback = function (err)
			if err ~= MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	else
		gClientToGameSceneDelegate:AskPlayerLeaveWater().Callback = function (err)
			if err ~= MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_CORE_HUD_DIVE, self.isInDive)
end

function M:SetIndoorEnableButton(isEnable)
	self.isEnableMindPowerIndoor = isEnable

	self:OnRefreshSkillBtn(self.skillType.ControlPower)
end

function M:SetForbidAllBuff(skillType, isForbid)
	self:OnSetSkillBtnState(skillType, "forbidAllBuff", isForbid)

	if skillType == self.skillType.Basic then
		self:OnSetSkillBtnState(self.skillType.Hold_E, "forbidAllBuff", isForbid)
	end
end

function M:SetCanFeiSuoAttack(canFeiSuoAttack)
	if self.canFeiSuoAttack ~= canFeiSuoAttack then
		self.canFeiSuoAttack = canFeiSuoAttack

		gMessageManager:SendMessage(gEventConstants.ON_UPDATE_BASIC_SKILL)
	end
end

function M:SetCanBackAssassin(canBackAssassin)
	if self.canBackAssassin ~= canBackAssassin then
		self.canBackAssassin = canBackAssassin

		gMessageManager:SendMessage(gEventConstants.ON_UPDATE_BASIC_SKILL)
	end
end

function M:SetFeisuoInfo(visible, interactable)
	self.feisuoVisibleRecord = visible
	self.feisuoInteractableRecord = interactable
end

function M:GetFeisuoVisible()
	return "" .. tostring(self.feisuoVisibleRecord) or "false"
end

function M:GetFeisuoInteractable()
	return "" .. tostring(self.feisuoInteractableRecord) or "false"
end

function M:OnSkillResourceChanged(eventId, data)
	if not data or not data[0] or data[0] ~= SkillResourcesConfig.StaminaBar then
		return
	end

	local fightSkill = gCS.BattleManager.GetBasicSkillId()
	local unit = gCS.MyPlayerManager.PlayerUnit
	local isFull = false

	if unit then
		isFull = gBattleMgr:IsSkillFightResourceEnough(unit, fightSkill)
	end

	self:OnSetSkillBtnState(self.skillType.Basic, "isEnergyEmpty", not isFull)
end

function M:OnRefreshMotoState(eventId, isOnMoto)
	self.isOnTaffyMoto = isOnMoto
end

function M:OnRefreshByMindPowerHold(eventId, data)
	self:OnRefreshSkillBtn(self.skillType.Normal)
	self:OnRefreshSkillBtn(self.skillType.Basic)
end

function M:OnMobileControllerChange(eventId, data)
	self.isEnterController = data

	if gameProfile.mobileControlMode and not self.isEnterController then
		SGUI.InputActionBind.fixedGameDevice = SGUI.GameDevice.KeyboardMouse

		self:MobileControllerReconnect()
	end
end

function M:CheckIsMobileControllerOn()
	if gCoreHudUIManager.isEnterController then
		SGUI.InputActionBind.fixedGameDevice = SGUI.GameDevice.PlayStation
	else
		self:MobileControllerReconnect()
	end
end

function M:KickToMobileLayout()
	gameProfile.mobileControlMode = false

	ProfileManager.SaveGameProperty()
	SGUI.UIConfig.instance:SetAdaptationPlatform(SGUI.EPlatform.Mobile)

	gCS.PanelManager.Instance.IsMobileMode = true

	if LX6.GUI.GuiMgr.Instance.sguiJoystick == nil then
		LX6.GUI.GuiMgr.Instance.sguiJoystick:ShowJoystickUI(true)
	end

	SGUI.InputActionBind.fixedGameDevice = SGUI.GameDevice.KeyboardMouse

	gLoginManager:DoKickToLogin(nil, nil, true)
end

function M:MobileControllerReconnect()
	gDisplayMessageMgr:ShowMessage(MessageConfig.MobileControllerMode, function ()
		self:KickToMobileLayout()
	end, function ()
		self:CheckIsMobileControllerOn()
	end)
end

gCoreHudUIManager = gCoreHudUIManager or C_CoreHudUIManager.new()
