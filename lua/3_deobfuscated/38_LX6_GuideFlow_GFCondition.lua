local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
gLegacyCondition = {
	DoingFeisuo = 4,
	DoingClimbStay = 11,
	DoingRun = 13,
	DoingClimbSlowStay = 12,
	FightPowerFill = 20,
	DoingHoldBlend = 23,
	False = 11111,
	DoingIdle = 5,
	HasMindPowerTarget = 18,
	DoingAirRush = 8,
	CanTerrainKilling = 26,
	CanUseSkill2 = 25,
	IsPSController = 32,
	CanSwing = 1,
	IsAutoDelivery = 34,
	CanPickUpWeapon = 29,
	DoingFall = 16,
	isVehicleJoystickMode = 35,
	IsSelectWeaponArmoryWeapon = 38,
	CanAirRush = 17,
	IsDelivery = 37,
	CanTaskFeiSuo = 30,
	FeisuoBattle = 15,
	IsSelectWeaponArmoryMA = 39,
	DoingMagnet = 24,
	DoingRush = 14,
	CanFeisuo = 3,
	None = 0,
	IsDriving = 33,
	DoingJump = 7,
	IsControllerMode = 22,
	CanAssassin = 36,
	IsOutDoor = 19,
	CanWeakExecute = 31,
	IsMobile = 21,
	CanDodgeState = 27,
	CanBlockState = 28,
	DoingSwing = 2,
	DoingClimbSlow = 9,
	FightSpiritBigSkill = 6,
	True = 9999,
	DoingClimbRun = 10
}
local ConditionMap = {
	[gLegacyCondition.None] = function ()
		return false
	end,
	[gLegacyCondition.True] = function ()
		return true
	end,
	[gLegacyCondition.False] = function ()
		return false
	end,
	[gLegacyCondition.CanSwing] = function ()
		return false
	end,
	[gLegacyCondition.DoingSwing] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Swing
	end,
	[gLegacyCondition.CanFeisuo] = function ()
		return gFeisuoUIUpdateMgr.hasAddGps
	end,
	[gLegacyCondition.DoingFeisuo] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Feisuo
	end,
	[gLegacyCondition.DoingIdle] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Idle
	end,
	[gLegacyCondition.FightSpiritBigSkill] = function ()
		return gCS.BattleManager.CheckCanUseSkill(gCS.MyPlayerManager.PlayerUnit, gCS.BattleManager.GetUniqueSkillId())
	end,
	[gLegacyCondition.DoingJump] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Jump
	end,
	[gLegacyCondition.DoingAirRush] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.AirRush
	end,
	[gLegacyCondition.DoingClimbSlow] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbSlow
	end,
	[gLegacyCondition.DoingClimbRun] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbRun
	end,
	[gLegacyCondition.DoingClimbStay] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbStay
	end,
	[gLegacyCondition.DoingClimbSlowStay] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbSlowStay
	end,
	[gLegacyCondition.DoingRun] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Run
	end,
	[gLegacyCondition.DoingRush] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Rush
	end,
	[gLegacyCondition.FeisuoBattle] = function ()
		return gFeisuoAssassMgr:IsFeiSuoBattleCrouch() and not gCS.BattleManager.IsAnyEnemyLockMe()
	end,
	[gLegacyCondition.DoingFall] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Fall
	end,
	[gLegacyCondition.CanAirRush] = function ()
		local find = gCS.ClimbBuildManager.FindAirRushPos(nil, false, 0)

		return find
	end,
	[gLegacyCondition.HasMindPowerTarget] = function ()
		return gPlayerManager.main.bindData.hasMindPowerTarget
	end,
	[gLegacyCondition.IsOutDoor] = function ()
		return gMapManager.IndoorId == 0
	end,
	[gLegacyCondition.IsMobile] = function ()
		return not gCS.LuaUtils.IsNonMobileAdaptive()
	end,
	[gLegacyCondition.IsControllerMode] = function ()
		return SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	end,
	[gLegacyCondition.DoingHoldBlend] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.HoldBlend
	end,
	[gLegacyCondition.DoingMagnet] = function ()
		return gCS.PaoKuManager.ParkourStateLua == ActionTransitionRuleTypesConfig.ParkourStateType.Magnet
	end,
	[gLegacyCondition.CanUseSkill2] = function ()
		return gBattleMgr:CheckSkillBtnIsInteractable(gBattleMgr.SkillBtnType.Basic)
	end,
	[gLegacyCondition.CanTerrainKilling] = function ()
		local characterControlStore = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

		if characterControlStore then
			return gCS.BattleManager.IsMindInteractCfgTerrainKilling(characterControlStore.mindInteractCfgId or 0)
		end

		return false
	end,
	[gLegacyCondition.CanDodgeState] = function ()
		return gCS.DodgeCounterMgr.canDodgeState
	end,
	[gLegacyCondition.CanBlockState] = function ()
		return gCS.DodgeCounterMgr.canBlockState
	end,
	[gLegacyCondition.CanPickUpWeapon] = function ()
		local res = false
		res = gCS.MindPowerMgr:IsAimPickUpWeapon()

		return res
	end,
	[gLegacyCondition.CanTaskFeiSuo] = function ()
		return gMapSubSystem_NearByMisc:IsTaskFeiSuoVisible()
	end,
	[gLegacyCondition.CanWeakExecute] = function ()
		local characterControlStore = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

		if characterControlStore then
			return gCS.BattleManager.IsMindInteractCfgWeakExecute(characterControlStore.mindInteractCfgId or 0)
		end

		return false
	end,
	[gLegacyCondition.IsPSController] = function ()
		return gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.PlayStation
	end,
	[gLegacyCondition.IsDriving] = function ()
		local isDriveMode = gDriveVehiclesManager.isDriveMode and gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle ~= nil
		local isTaffyOnBike = gCS.PaoKuManager.ParkourStateLua == LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.MotorbikeIdle or gCS.PaoKuManager.ParkourStateLua == LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Moto

		return isDriveMode or isTaffyOnBike
	end,
	[gLegacyCondition.IsAutoDelivery] = function ()
		return gDeliveryTaskManager:CheckIsAuto()
	end,
	[gLegacyCondition.isVehicleJoystickMode] = function ()
		return LX6.Engine.ProfileManager.gameProfile.isVehicleJoystickMode == true
	end,
	[gLegacyCondition.CanAssassin] = function ()
		return gFeisuoAssassMgr.canAssassin
	end,
	[gLegacyCondition.IsDelivery] = function ()
		return gSpiritJobManager.GetCurSpiritJobClassId() == LTConfig.UrbanJobJobClassConfig.Delivery
	end,
	[gLegacyCondition.IsSelectWeaponArmoryWeapon] = function ()
		return gGFCondition.isSelectWeaponArmoryWeapon
	end,
	[gLegacyCondition.IsSelectWeaponArmoryMA] = function ()
		return gGFCondition.isSelectWeaponArmoryMA
	end
}
local M = {
	isSelectWeaponArmoryWeapon = false,
	isSelectWeaponArmoryMA = false,
	CheckCondition = function (self, conditionType)
		conditionType = conditionType or gLegacyCondition.None

		if ConditionMap[conditionType] then
			return ConditionMap[conditionType]()
		end

		self._errors = self._errors or {}

		if not self._errors[conditionType] then
			self._errors[conditionType] = true

			print("@sunwei08: Condition not found: " .. conditionType)
		end

		return false
	end
}
gGFCondition = M
