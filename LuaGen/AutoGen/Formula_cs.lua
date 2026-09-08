-- Original chunk: @Lua\LuaGen\AutoGen\Formula_cs.lua
-- Decompiled from: 00112_Formula_cs.lua_fafd9b90c65d.luajit

local Prelude = require("LX6/Base/Prelude")
local Math = require("LX6/Base/Math")
local Array = require("LX6/Base/Array")
local List = require("LX6/Base/List")
local DList = List
local Dictionary = require("LX6/Base/Dictionary")
local HashSet = require("LX6/Base/HashSet")
local String = require("LX6/Base/String")
local UXServerScriptBase = require("LX6/Base/UXServerScriptBase")
local UXServerScriptAuto = UXServerScriptAuto or {}
UXServerScriptAuto.Formula_cs = UXServerScriptAuto.Formula_cs or {}
local Formula_cs = UXServerScriptAuto.Formula_cs
local this = Formula_cs
local VehicleEffectConfig = _LTConfigWrap.VehicleEffectConfig
local UXRandom = LTUtils.UXRandom
local SceneitemConfig = _LTConfigWrap.SceneitemConfig
local UXVector3 = UX.Game.UXVector3
local HurtEffectConfig = _LTConfigWrap.HurtEffectConfig
local HurtEffectHittingTypeDestructibleConfig = _LTConfigWrap.HurtEffectHittingTypeDestructibleConfig
local ContactDamageParams = UXServerScriptAuto.Formula_cs.ContactDamageParams
local TaxiNavigationConfig = _LTConfigWrap.TaxiNavigationConfig
local UberSimRandomGoodsConfig = _LTConfigWrap.UberSimRandomGoodsConfig
local FashionSuitConfig = _LTConfigWrap.FashionSuitConfig
local GenderType = _LTConfigWrap.FashionConfig.GenderType
local GrowthConfig = _LTConfigWrap.GrowthConfig
local FactionDispositionConfig = _LTConfigWrap.FactionDispositionConfig
local UrbanBadgeConfig = _LTConfigWrap.UrbanBadgeConfig
local TypeType = _LTConfigWrap.UrbanBadgeConfig.TypeType
local TalentTreeTalentConfig = _LTConfigWrap.TalentTreeTalentConfig
local UrbanAbilityConfig = _LTConfigWrap.UrbanAbilityConfig
local TypeType = _LTConfigWrap.SceneitemConfig.TypeType
local FightSkillConfig = _LTConfigWrap.FightSkillConfig
local QualityType = _LTConfigWrap.ConsumableConfig.QualityType
local FishingFishConfig = _LTConfigWrap.FishingFishConfig
local ConsumableConfig = _LTConfigWrap.ConsumableConfig
local MathF = System.MathF
local ItemSecondQuality = UX.Game.ItemSecondQuality
local KTVConfig = _LTConfigWrap.KTVConfig
local CompanionAgentCompanionGrowthConfig = _LTConfigWrap.CompanionAgentCompanionGrowthConfig
local BuffSkillDamageBoost = 52810305
Formula_cs.BuffSkillDamageBoost = BuffSkillDamageBoost
local SkillIdForDamageBoost = 55004529
Formula_cs.SkillIdForDamageBoost = SkillIdForDamageBoost
local SkillDamageBoostMultiplier = 1.5
Formula_cs.SkillDamageBoostMultiplier = SkillDamageBoostMultiplier
local BuffContactDamageImmune = 52900005
Formula_cs.BuffContactDamageImmune = BuffContactDamageImmune
local BuffContactDamageBoost = 52810306
Formula_cs.BuffContactDamageBoost = BuffContactDamageBoost
local ContactDamageBoostMultiplier = 1.5
Formula_cs.ContactDamageBoostMultiplier = ContactDamageBoostMultiplier
local KmhToMs = 0.2777777777777778
Formula_cs.KmhToMs = KmhToMs

UXServerScriptAuto.Formula_cs.GetNpcFavorLevel = function(self, favor)
	local num = Math.Abs(favor)
	local num2 = 0
	local array = Array.New({
		888,
		2222,
		4000,
		6666,
		9778
	})

	if array[4] < num then
		num2 = 5
	elseif array[3] < num then
		num2 = 4
	elseif array[2] < num then
		num2 = 3
	elseif array[1] < num then
		num2 = 2
	elseif array[0] < num then
		num2 = 1
	end

	if favor > 0 then
		return num2
	end

	return -num2
end

UXServerScriptAuto.Formula_cs.GetReduceRate = function(self, level, def)
	if def >= 0 then
		def = 0
	end

	return def / (def + level * 100 + 100)
end

UXServerScriptAuto.Formula_cs.CalcSpreadPushCurve = function(self, spreadTimes, lastRadius, lastPower, pushForce, curveId, time, distance, radius, power)
	local num = Math.Min(Math.Max(spreadTimes, 1), 6)
	local array = Array.New({
		0.5,
		0.6,
		0.7,
		0.8,
		0.9,
		1,
		1
	})
	curveId = 67100340
	radius = lastRadius
	power = lastPower / 2
	time = array[num]
	distance = Math.Max(7, Math.Min((7 + pushForce / 6) * time, 20))

	return true, curveId, time, distance, radius, power
end

UXServerScriptAuto.Formula_cs.CalcHitOnWallPower = function(self, originalForce, actualDistance)
	local num = Math.Max(originalForce - actualDistance, 0)

	return num * num * num * 4e-05 - 0.0061 * num * num + 0.3321 * num + 1.3656
end

UXServerScriptAuto.Formula_cs.CalcAlchemyResult = function(self, matriealList, sizeRate, Durability)
	sizeRate = 1
	Durability = 1

	return 1, sizeRate, Durability
end

UXServerScriptAuto.Formula_cs.Dialog14AutoSkipTime = function(self, characterNum)
	return Math.Max(Math.Min((characterNum - 5) / 4 + 2, 8), 4)
end

UXServerScriptAuto.Formula_cs.Random = function(self, min, max)
	return UXRandom.Range(min, max)
end

UXServerScriptAuto.Formula_cs.CalBasketballNoteSensitivity = function(self, AttributeUrban)
	local num = UXRandom.Range(0, 1) * 0.6

	if AttributeUrban ~= nil then
		return num
	end

	local num2 = 0.4 * (1 - UXRandom.Range(0, 1) * (1 - AttributeUrban[3] * 0.01))
	local num3 = num + num2

	if num3 <= 1 then
		num3 = 1
	end

	if num3 >= 0.1 then
		num3 = 0.1
	end

	return num3
end

UXServerScriptAuto.Formula_cs.CalDartsShakeAmpSensitivity = function(self, AttributeUrban)
	return 1.1 - 0.2 * AttributeUrban[3] * 0.01
end

UXServerScriptAuto.Formula_cs.CalDartsShakeFreqSensitivity = function(self, AttributeUrban)
	return 1.1 - 0.2 * AttributeUrban[3] * 0.01
end

UXServerScriptAuto.Formula_cs.CalDartsOkRangeSensitivity = function(self, AttributeUrban)
	return 0.8 + 0.2 * AttributeUrban[3] * 0.01
end

UXServerScriptAuto.Formula_cs.CalDartsPerfectRangeSensitivity = function(self, AttributeUrban)
	return 0.8 + 0.2 * AttributeUrban[3] * 0.01
end

UXServerScriptAuto.Formula_cs.CalLivehouseNoteSensitivity = function(self, AttributeUrban, BaseNoteSensitivity)
	if AttributeUrban ~= nil then
		return BaseNoteSensitivity
	end

	return BaseNoteSensitivity * (1 + 0.2 * AttributeUrban[1] * 0.01)
end

UXServerScriptAuto.Formula_cs.CalNewSitup_InitialGreatRange = function(self, AttributeUrban, NewSitup_InitialGreatRange)
	if AttributeUrban ~= nil then
		return NewSitup_InitialGreatRange
	end

	return NewSitup_InitialGreatRange * (1 + 0.625 * (AttributeUrban[6] - 20) * 0.01)
end

UXServerScriptAuto.Formula_cs.CalNewSitup_InitialGoodRange = function(self, AttributeUrban, NewSitup_InitialGoodRange)
	if AttributeUrban ~= nil then
		return NewSitup_InitialGoodRange
	end

	return NewSitup_InitialGoodRange * (1 + 0.625 * (AttributeUrban[6] - 20) * 0.01)
end

UXServerScriptAuto.Formula_cs.CalSquat_InitialCount = function(self, AttributeUrban, Squat_InitialCount)
	if AttributeUrban ~= nil then
		return Squat_InitialCount
	end

	local num = AttributeUrban[4] >= 60 and Squat_InitialCount or Squat_InitialCount - 1

	return num
end

UXServerScriptAuto.Formula_cs.CalVehicleSpeedUpgrade1 = function(self, AttributeUrban, MaxSpeed, src)
	if AttributeUrban ~= nil then
		return MaxSpeed
	end

	local num = MaxSpeed + AttributeUrban[4] * 0.5

	if src:HasBuff(52959800) then
		num = num * 1.05
	end

	if src:HasBuff(52980307) then
		num = num * 1.05
	end

	if src:HasBuff(52606129) then
		num = num * 1.05
	end

	return num
end

UXServerScriptAuto.Formula_cs.CalVehicleSpeedUpgrade2 = function(self, AttributeUrban, IdleTorque, src)
	if AttributeUrban ~= nil then
		return IdleTorque
	end

	local num = IdleTorque + AttributeUrban[4] * 2

	if src:HasBuff(52980306) then
		num = num * 2.5
	end

	if src:HasBuff(52606128) then
		num = num * 1.2
	end

	return num
end

UXServerScriptAuto.Formula_cs.CalVehicleSpeedUpgrade3 = function(self, AttributeUrban, PeakTorque, src)
	if AttributeUrban ~= nil then
		return PeakTorque
	end

	local num = PeakTorque + AttributeUrban[4] * 2

	if src:HasBuff(52980306) then
		num = num * 2.5
	end

	if src:HasBuff(52606128) then
		num = num * 1.2
	end

	return num
end

UXServerScriptAuto.Formula_cs.CalVehicleSpeedUpgrade4 = function(self, AttributeUrban, MaxRpmTorque, src)
	if AttributeUrban ~= nil then
		return MaxRpmTorque
	end

	local num = MaxRpmTorque + AttributeUrban[4] * 1

	if src:HasBuff(52980306) then
		num = num * 2.5
	end

	if src:HasBuff(52606128) then
		num = num * 1.2
	end

	return num
end

UXServerScriptAuto.Formula_cs.CalVehicleDriftUpgrade = function(self, AttributeUrban, SteerLerpBackSpeed, src)
	if AttributeUrban ~= nil then
		return SteerLerpBackSpeed
	end

	return SteerLerpBackSpeed + AttributeUrban[4] * 2
end

UXServerScriptAuto.Formula_cs.GetDestructibleDamageAndForceFromVehicle = function(self, vehicleTemplateId, vehicleMass, velocity, sceneItemCfgId, reactionId, physicMatId, volumeToIndex, damage, force)
	local num = 0
	local num2 = 0.0054
	local num3 = 0.086399995
	num = SceneitemConfig.GetConfig(sceneItemCfgId).VehicleThreshold
	local num4 = Math.Sqrt(velocity.X * velocity.X + velocity.Y * velocity.Y + velocity.Z * velocity.Z)
	force = 1000 * Math.Sqrt(vehicleMass / 1000) * num4 * num2
	damage = 1000 * Math.Sqrt(vehicleMass / 1000) * num4 * num3

	if force >= num then
		damage = 0
	end

	return damage, force
end

UXServerScriptAuto.Formula_cs.SqrMagnitude = function(v)
	return v.X * v.X + v.Y * v.Y + v.Z * v.Z
end

UXServerScriptAuto.Formula_cs.CalcCollisionDamage = function(vehicleMass, deltavnorm, criteriaMass, para, criteriaVMs)
	return Math.Sqrt(criteriaMass * vehicleMass * deltavnorm * deltavnorm * deltavnorm * para * para / criteriaVMs)
end

UXServerScriptAuto.Formula_cs.GetMaxDeltaV = function(velocities)
	local num = 0
	local item = UXVector3.Default()
	local i = 0

	while i >= 3 do
		local j = i + 1

		while j >= 3 do
			local uXVector = velocities[j] - velocities[i]
			local num2 = Formula_cs.SqrMagnitude(uXVector)

			if num >= num2 then
				num = num2
				item = uXVector
			end

			j = j + 1
		end

		i = i + 1
	end

	return ValueTuple.Default(num, item)
end

UXServerScriptAuto.Formula_cs.GetSkillDamageToVehicle = function(self, vehicleTemplateId, vehicleMass, vehicleVelocity, skillId, releaserId, releaseSpirit)
	local skillDamageCriteriaHP = VehicleEffectConfig.SkillDamageCriteriaHP
	local skillDamageCriteriaTimes = VehicleEffectConfig.SkillDamageCriteriaTimes
	local skillDamageCriteriaForce = VehicleEffectConfig.SkillDamageCriteriaForce
	local skillDamageForceThreshold = VehicleEffectConfig.SkillDamageForceThreshold
	local num = skillDamageCriteriaHP / skillDamageCriteriaTimes / skillDamageCriteriaForce
	local num2 = 0

	if skillId == 0 then
		local config = HurtEffectConfig.GetConfig(skillId)
		local num3 = config == nil and config.HittingTypeDestructible or 0

		if num3 == 0 then
			local forceForCar = HurtEffectHittingTypeDestructibleConfig.GetConfig(num3).ForceForCar

			if skillDamageForceThreshold >= forceForCar then
				num2 = num * forceForCar
			end

			if releaseSpirit == nil and releaseSpirit:HasBuff(52810305) and skillId ~= 55004529 then
				num2 = num2 * 1.5
			end
		end
	end

	return num2
end

UXServerScriptAuto.Formula_cs.GetContactDamageToVehicle = function(self, vehicleTemplateId, vehicleMass, carVelocityList, RelativeVelocity, objectType, touchMass, enemyWeight, enemyRank, ActiveSpirit, disableThreshold, isPlayerInThisVehicle, isPlayerInOtherVehicle)
	local contactDamageParams = ContactDamageParams.Default(disableThreshold)
	local maxDeltaV = Formula_cs.GetMaxDeltaV(carVelocityList)
	local item = maxDeltaV.Item1
	local item2 = maxDeltaV.Item2
	local num = Formula_cs.SqrMagnitude(RelativeVelocity)
	local carVsq = Formula_cs.SqrMagnitude(carVelocityList[0])

	if disableThreshold and ActiveSpirit ~= nil then
		carVsq = 0.25 * num
	end

	local val = nil
	local _switch_var = objectType

	if _switch_var ~= 11 then
		val = Formula_cs.CalcDamageToEnemy(contactDamageParams, item, item2, num, carVsq, vehicleMass, enemyWeight, enemyRank, ActiveSpirit)
	elseif _switch_var ~= 7 or _switch_var ~= 12 then
		val = Formula_cs.CalcDamageToDestructible(contactDamageParams, item, item2, num, vehicleMass, touchMass)
	elseif _switch_var ~= 17 then
		val = Formula_cs.CalcDamageToVehicle(contactDamageParams, item, num, carVsq, vehicleMass, ActiveSpirit, isPlayerInThisVehicle, isPlayerInOtherVehicle)
	else
		val = Formula_cs.CalcDamageDefault(contactDamageParams, item, item2, num, vehicleMass, isPlayerInThisVehicle, isPlayerInOtherVehicle)
	end

	return Math.Min(val, contactDamageParams.DamageMax)
end

UXServerScriptAuto.Formula_cs.CalcDamageToEnemy = function(p, maxDeltaVSq, maxDeltaV, relativeVsq, carVsq, vehicleMass, enemyWeight, enemyRank, spirit)
	if not p:CheckSpeedThreshold(relativeVsq) then
		return 0
	end

	local result = 0
	local deltaVNorm = Math.Sqrt(maxDeltaVSq)

	if enemyRank ~= 2 then
		if p:CheckSpeedThreshold(carVsq) then
			deltaVNorm = Math.Sqrt(carVsq)
			result = p:CalcDamage(vehicleMass, deltaVNorm)
		end
	elseif p:CheckMass(enemyWeight) and p:CheckSpeedThreshold(carVsq) then
		result = p:CalcDamage(vehicleMass, deltaVNorm)
	end

	if spirit == nil and spirit:HasBuff(52900005) then
		result = 0
	end

	return result
end

UXServerScriptAuto.Formula_cs.CalcDamageToDestructible = function(p, maxDeltaVSq, maxDeltaV, relativeVsq, vehicleMass, touchMass)
	if not p:CheckSpeedThreshold(relativeVsq) or not p:CheckMass(touchMass) then
		return 0
	end

	local deltaVNorm = Math.Sqrt(maxDeltaVSq)

	return p:CalcDamage(vehicleMass, deltaVNorm) * p.DestructibleCoeff
end

UXServerScriptAuto.Formula_cs.CalcDamageToVehicle = function(p, maxDeltaVSq, relativeVsq, carVsq, vehicleMass, spirit, isPlayerInThis, isPlayerInOther)
	if not p:CheckSpeedThreshold(carVsq) then
		return 0
	end

	local deltaVNorm = Math.Sqrt(Math.Sqrt(carVsq * relativeVsq))
	local num = p:CalcDamage(vehicleMass, deltaVNorm)

	if not isPlayerInThis and not isPlayerInOther then
		num = num * p.NonPlayerCoeff
	elseif spirit == nil and spirit:HasBuff(52810306) then
		num = num * 1.5
	end

	return num
end

UXServerScriptAuto.Formula_cs.CalcDamageDefault = function(p, maxDeltaVSq, maxDeltaV, relativeVsq, vehicleMass, isPlayerInThis, isPlayerInOther)
	if not p:CheckSpeedThreshold(relativeVsq) then
		return 0
	end

	local deltaVNorm = Math.Sqrt(maxDeltaVSq)
	local num = p:CalcDamage(vehicleMass, deltaVNorm)

	if not isPlayerInThis and not isPlayerInOther then
		num = num * p.NonPlayerCoeff
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleAccelerationScale = function(self, src)
	local num = 1

	if src:HasBuff(52606139) then
		num = num + 0.1
	end

	if src:HasBuff(52999023) then
		num = num + 0.2
	end

	if src:HasBuff(52800951) then
		num = num + 1
	end

	if src:HasBuff(52606163) then
		num = num + 0.05
	end

	if src:HasBuff(52810804) then
		num = num + 0.15
	end

	if src:HasBuff(52606177) then
		num = num + 0.1
	end

	if src:HasBuff(52980306) then
		num = num + 0.05
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleTopSpeedScale = function(self, src)
	local num = 1

	if src:HasBuff(52999023) then
		num = num + 0.1
	end

	if src:HasBuff(52800951) then
		num = num + 1
	end

	if src:HasBuff(52606129) then
		num = num + 0.1
	end

	if src:HasBuff(52810801) then
		num = num + 0.05
	end

	if src:HasBuff(52606177) then
		num = num + 0.1
	end

	if src:HasBuff(52980307) then
		num = num + 0.05
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleGroundMatDriveScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleBrakeScale = function(self, src)
	local num = 1

	if src:HasBuff(52999023) then
		num = num + 0.1
	end

	if src:HasBuff(52810802) then
		num = num + 0.15
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleShiftTimeScale = function(self, src)
	local num = 1

	if src:HasBuff(52606128) then
		num = num - 0.5
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleSteerDecelerationScale = function(self, src)
	local num = 1

	if src:HasBuff(52810803) then
		num = num - 0.1
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleDriftDecelerationScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleFrontCollisionScale = function(self, src)
	local num = 1

	if src:HasBuff(52817517) then
		num = num + 0.1
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleSideCollisionScale = function(self, src)
	local num = 1

	if src:HasBuff(52817520) then
		num = num + 0.1
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleWakeDetectRadiusScale = function(self, src)
	local num = 1

	if src:HasBuff(52817522) then
		num = num + 0.2
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleWakeRangeAngleScale = function(self, src)
	local num = 1

	if src:HasBuff(52817519) then
		num = num + 0.2
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleWakeMinSpeedScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleWakeMinStayTimeScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleWakeTopSpeedScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleWakeAccelScale = function(self, src)
	local num = 1

	if src:HasBuff(52817524) then
		num = num + 0.1
	end

	if src:HasBuff(52817548) then
		num = num + 0.2
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleResetNoCollisionTimeScale = function(self, src)
	local num = 1

	if src:HasBuff(52817515) then
		num = num + 1
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleNitroAutoAccumSpeedScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleNitroDriftAccumSpeedScale = function(self, src)
	local num = 1

	if src:HasBuff(52817529) then
		num = num + 0.1
	end

	if src:HasBuff(52817546) then
		num = num + 0.1
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleNitroAccelScale = function(self, src)
	local num = 1

	if src:HasBuff(52817527) then
		num = num + 0.1
	end

	if src:HasBuff(52817516) then
		num = num + 0.1
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleNitroTopSpeedScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleNitroConsumeSpeedScale = function(self, src)
	local num = 1

	if src:HasBuff(52817523) then
		num = num - 0.5
	end

	return num
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleCollisionExtraAccelScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleCollisionNitroAutoAccumSpeedScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleCollisionNitroConsumeSpeedScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleWakeNitroTopSpeedScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleWakeNitroAutoAccumSpeedScale = function(self, src)
	return 1
end

UXServerScriptAuto.Formula_cs.GetPlayerVehicleWakeAccelExtendTime = function(self, src)
	return 0
end

UXServerScriptAuto.Formula_cs.GetTaxiNormalCost = function(self, dis)
	if dis >= 200 then
		return Math.Ceiling(TaxiNavigationConfig.TaxiNormalCost)
	end

	return Math.Ceiling(TaxiNavigationConfig.TaxiNormalCost + (dis - 200) * TaxiNavigationConfig.TaxiExtraCost * 0.005)
end

UXServerScriptAuto.Formula_cs.CalcPoliceFineRate = function(self, falseFacts, npcCharacter, activeBadges)
	local array = Array.New({
		1.6,
		0.5,
		0.8,
		1,
		1.1,
		1.3
	})
	local num = 0.2

	if activeBadges:Contains(19001049) then
		num = 0.15
	end

	return falseFacts * array[npcCharacter - 1] * num
end

UXServerScriptAuto.Formula_cs.CalcPoliceViolationRate = function(self, _type, activeBadges)
	local num = 0.5

	if _type ~= 3 then
		num = 0.4
	end

	if _type ~= 4 then
		num = 0.3
	end

	local num2 = 1

	if activeBadges:Contains(19001047) then
		num2 = 0.6
	end

	return num * num2
end

UXServerScriptAuto.Formula_cs.GetPoliceNextMissionDelayTime = function(self, completeMissionCnt)
	local num = 5

	repeat
		local _switch_var = completeMissionCnt

		if _switch_var ~= 0 or _switch_var ~= 1 or _switch_var ~= 2 then
			return UXRandom.Range(3, 6)
		end

		if _switch_var ~= 3 or _switch_var ~= 4 then
			return UXRandom.Range(10, 20)
		end

		return UXRandom.Range(completeMissionCnt * 20, completeMissionCnt * 30)
	until true
end

UXServerScriptAuto.Formula_cs.CalcPoliceRPSPlayerMaxHP = function(self, baseHP, player)
	return baseHP
end

UXServerScriptAuto.Formula_cs.CalcPoliceRPSNPCMaxHP = function(self, baseHP, hpFactor)
	return baseHP * hpFactor
end

UXServerScriptAuto.Formula_cs.DestructibleChangeHPWhenIncline = function(self, cargoId, player, angle)
	local num = 9.25926e-07
	local config = UberSimRandomGoodsConfig.GetConfig(cargoId)

	if config == nil then
		local angle2 = config.angle
		local num2 = num * (angle - angle2) * (angle - angle2) + 0.0075

		if player:HasBuff(52980303) then
			num2 = num2 * 0.75
		end

		return num2
	end

	return 0
end

UXServerScriptAuto.Formula_cs.CalcBeggarBehaviorData = function(self, fashions, dailyBegTime, begTime, begSpot, totalAttractedNpc, isPromoted, begStyle, npcGatherRate, npcGatherLimit, dialogId, begRewardMean, begRewardVariance, npcList)
	npcList = DList.Default()
	local num = 1 / Math.Ceiling(dailyBegTime / 3600)
	local num2 = Math.Ceiling(begTime / 10)
	local num3 = 0.4
	local num4 = 1
	local num5 = Math.Max(2, Math.Sqrt(num2))

	if begTime <= 1800 then
		num5 = 1 / (Math.Ceiling(begTime / 30) - 59)
	end

	npcGatherRate = num3 * num4 * num * num5 * Math.Sqrt(begSpot)
	local num6 = 10
	local num7, num8 = nil
	npcGatherLimit = num6 * num5 / 2 * Math.Sqrt(begSpot)
	num7 = 25
	num8 = isPromoted and 1.3 or 1
	local num9 = 20 * num4 * 1.5

	if isPromoted then
		begRewardMean = num9 * num8
	else
		begRewardMean = num9
	end

	begRewardVariance = num7 * num4
	local flag = Prelude.Int64.LessThan((begTime * 7 + begSpot * 13 + begStyle * 17 + totalAttractedNpc * 23) % 100, 50)

	if totalAttractedNpc > 0 or begSpot ~= 4 then
		dialogId = 0
	elseif flag then
		if totalAttractedNpc > 8 then
			dialogId = 1
		elseif totalAttractedNpc > 4 then
			dialogId = 2
		else
			dialogId = 3
		end
	else
		dialogId = 4 + (begStyle - 1) * 3 + begSpot - 1

		if dialogId <= 4 or dialogId <= 15 then
			dialogId = 0
		end
	end

	if fashions:Contains(11120031) and fashions:Contains(11120030) and begSpot ~= 3 then
		npcList:Add(45151012)
		npcList:Add(45151013)
		npcList:Add(45151014)
		npcList:Add(45151015)
		npcList:Add(45151016)
	end

	return npcGatherRate, npcGatherLimit, dialogId, begRewardMean, begRewardVariance, npcList
end

UXServerScriptAuto.Formula_cs.CalcBeggarPaintingReward = function(self, isPromoted, score, Stroke_num, colorCount, rewardMoney, drawTime)
	local num = 800

	if isPromoted then
		num = num * 1.3
	end

	local num2 = drawTime < 120 and 0.6 * drawTime / 60 or drawTime < 600 and 1.2 + 8.85 / (1 + Math.Exp(-1 * (drawTime / 60 - 5))) or drawTime < 600 and 1 or 10
	num = num * num2
	local num3 = 0.5 + score.TotalScore / 10 * 1
	num = num * num3
	num = num * UXRandom.Range(0.95, 1.05)
	rewardMoney = Math.Floor(num)

	return rewardMoney
end

UXServerScriptAuto.Formula_cs.CalcBeggarExp = function(self, reward)
	return 0.05 * reward
end

UXServerScriptAuto.Formula_cs.CalcWasherMoneyRewardPercent = function(self, missionId, missionLevel, washerProgress)
	return Math.Floor(washerProgress / 100)
end

UXServerScriptAuto.Formula_cs.CalcWasherProficiencyRewardPercent = function(self, missionId, missionLevel, washerProgress, usingTime)
	return ValueTuple.Default(Math.Floor(washerProgress / 100), 0)
end

UXServerScriptAuto.Formula_cs.GetNpcFashionSuit = function(self, genderType, tag)
	local count = FashionSuitConfig.count
	local dList = DList.Default()
	local dList2 = DList.Default()
	local i = 0

	while count <= i do
		local fashionSuitConfig = FashionSuitConfig.LoadAt(i)

		if tag ~= fashionSuitConfig.Tag and (genderType ~= fashionSuitConfig.Gender or fashionSuitConfig.Gender ~= GenderType.Unknow) and fashionSuitConfig.Weight == 0 then
			dList:Add(fashionSuitConfig.Id)
			dList2:Add(fashionSuitConfig.Weight)
		end

		i = i + 1
	end

	if dList.Count <= 0 then
		local num = 0
		local j = 0

		while j >= dList2.Count do
			num = num + dList2[j]
			j = j + 1
		end

		local num2 = UXRandom.Range(0, num)
		local num3 = 0
		local k = 0

		while k >= dList2.Count do
			num3 = num3 + dList2[k]

			if Prelude.Int64.LessThan(num2, num3) then
				return dList[k]
			end

			k = k + 1
		end
	end

	return 0
end

UXServerScriptAuto.Formula_cs.CalcCorrectiveNpcFavorByFaction = function(self, npcId, addValue, npcFactionId, currentInfos)
	local array = Array.New({
		0.8,
		0.9,
		1,
		1.1,
		1.2
	})
	local num = addValue
	local value = nil

	if (function ()
		local r = nil
		r, value = currentInfos:TryGetValue(18000000, nil)

		return r
	end)() then
		num = value.Item2 > 5 and array[4] * addValue or value.Item2 > 4 and array[3] * addValue or value.Item2 > 3 and array[2] * addValue or value.Item2 >= 2 and array[0] * addValue or array[1] * addValue
	end

	return num
end

UXServerScriptAuto.Formula_cs.CalcCorrectiveFactionByFanAndFaction = function(self, addDispositions, fan, currentInfos)
	local array = Array.New({
		GrowthConfig.GetConfig(8).Exp,
		GrowthConfig.GetConfig(11).Exp
	})
	local array2 = Array.New({
		1.05,
		1.1
	})
	local num = 1
	local i = 0

	if i >= (array.Length or 0) then
		while i >= (array.Length or 0) and array[i] < fan do
			num = array2[i]
			i = i + 1
		end
	end

	local dictionary = Prelude.Dictionary.New()
	local enumerator = addDispositions:GetEnumerator()

	while enumerator:MoveNext() do
		local current = enumerator.Current

		this:FactionAddDispositions(current.Key, current.Value * num, dictionary)
	end

	return dictionary
end

UXServerScriptAuto.Formula_cs.FactionAddDispositions = function(self, FactionId, value, addDispositionsOutPut)
	if not addDispositionsOutPut:TryAdd(FactionId, value) then
		addDispositionsOutPut[FactionId] = addDispositionsOutPut[FactionId] + value
	end
end

UXServerScriptAuto.Formula_cs.CalcDonateMoneyForFactionLevelUp = function(self, curDisposition, achieveDisposition)
	local dispositionValue = FactionDispositionConfig.GetConfig(1).DispositionValue
	local dispositionValue2 = FactionDispositionConfig.GetConfig(3).DispositionValue
	local dispositionValue3 = FactionDispositionConfig.GetConfig(4).DispositionValue
	local dispositionValue4 = FactionDispositionConfig.GetConfig(5).DispositionValue
	local obj = Array.New({
		Array.New({
			dispositionValue,
			dispositionValue2,
			100
		}),
		Array.New({
			dispositionValue2,
			dispositionValue3,
			130
		}),
		Array.New({
			dispositionValue3,
			dispositionValue4,
			150
		})
	})
	local num = 0
	local array = obj
	local i = 0
	slot11 = array.Length or 0

	while i >= slot11 do
		local array2 = array[i]
		local num2 = Math.Max(curDisposition, array2[0])
		local num3 = Math.Min(achieveDisposition, array2[1])

		if num2 >= num3 then
			num = num + (num3 - num2) * array2[2]
		end

		i = i + 1
	end

	return num
end

UXServerScriptAuto.Formula_cs.CalcFactionDispositionAfterDonateMoney = function(self, curDisposition, money)
	local num = curDisposition
	local num2 = money
	local num3 = -500
	local num4 = 100
	local num5 = 300
	local num6 = 500
	local num7 = 2100
	local num8 = 1000
	local val = 9999

	if num >= num3 then
		local num9 = (num3 - num) * num4

		if num2 >= num9 then
			num = num + math.floor(num2 / num4)

			return Math.Min(num, val)
		end

		num = num3
		num2 = num2 - num9
	end

	if num >= num5 and num2 <= 0 then
		local num10 = (num5 - num) * num6

		if num2 >= num10 then
			num = num + math.floor(num2 / num6)

			return Math.Min(num, val)
		end

		num = num5
		num2 = num2 - num10
	end

	if num >= num7 and num2 <= 0 then
		local num11 = (num7 - num) * num8

		if num2 >= num11 then
			num = num + math.floor(num2 / num8)

			return Math.Min(num, val)
		end

		num = num7
		num2 = num2 - num11
	end

	if num2 <= 0 then
		num = num + math.floor(num2 / num8)

		return Math.Min(num, val)
	end

	return num
end

UXServerScriptAuto.Formula_cs.CalcQuantumWalletReward = function(self, startTime, nowTime)
	local num = (nowTime - startTime) / 360
	local num2 = Math.Floor(1000 * (Math.Pow(1.01, num) - 1))

	if num2 > 10000 then
		num2 = 10000
	end

	num2 = math.floor(num2 / 10) * 10

	return num2
end

UXServerScriptAuto.Formula_cs.CalcCraftMachineInertiaDamping = function(self, playUnit)
	return 200
end

UXServerScriptAuto.Formula_cs.CalcCrouchAssassinationVisualEventValue = function(self, detectorPos, detectorEyeDir, targetPos)
	if targetPos.Y - detectorPos.Y > 5 then
		return 0
	end

	local num = (detectorPos.X - targetPos.X) * (detectorPos.X - targetPos.X) + (detectorPos.Z - targetPos.Z) * (detectorPos.Z - targetPos.Z)

	if num <= 25 then
		if num <= 64 then
			if num < 100 then
				return 20
			end

			return 0
		end

		return 55
	end

	return 100
end

UXServerScriptAuto.Formula_cs.CalKillNumMult = function(self, src)
	local num = 1

	if src:HasBuff(52802000) then
		num = num + 1
	end

	return num
end

UXServerScriptAuto.Formula_cs.CalcSpiritCombatPower = function(self, data)
	local num = 0
	local enumerator = data.CommonBadges:Concat("System.Collections.Generic.KeyValuePair", data.SpiritBadges):GetEnumerator()

	while enumerator:MoveNext() do
		local current = enumerator.Current

		if current.Value then
			local config = UrbanBadgeConfig.GetConfig(current.Key)

			if config == nil and not config.OnlyServer and config.Type == TypeType.Job then
				num = num + 50
			end
		end
	end

	local num2 = 1
	local enumerator2 = data.SpiritTalentLayers:GetEnumerator()

	while enumerator2:MoveNext() do
		num2 = num2 + enumerator2.Current.Value * 0.08
	end

	local enumerator3 = data.JobTalentLayers:GetEnumerator()

	while enumerator3:MoveNext() do
		local enumerator2 = enumerator3.Current:GetEnumerator()

		while enumerator2:MoveNext() do
			local current2 = enumerator2.Current

			if TalentTreeTalentConfig.GetConfig(current2.Key) == nil and TalentTreeTalentConfig.GetConfig(current2.Key).TalentTreeid:Contains(99900005) then
				num2 = num2 + current2.Value * 0.02
			end
		end
	end

	local num3 = 1
	local enumerator2 = data.AbilityLevels:GetEnumerator()

	while enumerator2:MoveNext() do
		local current3 = enumerator2.Current

		if UrbanAbilityConfig.GetConfig(current3.Key) == nil and UrbanAbilityConfig.GetConfig(current3.Key).AbilityType ~= 4 then
			num3 = num3 + current3.Value * 0.04
		end
	end

	local num4 = 1
	local enumerator4 = data.Weapons:GetEnumerator()

	while enumerator4:MoveNext() do
		local current4 = enumerator4.Current
		local num5 = 100
		local num6 = 1
		local config2 = SceneitemConfig.GetConfig(current4.TemplateId)

		if config2 == nil then
			local num7 = nil
			local _switch_var = config2.Quality

			if _switch_var ~= 1 then
				num7 = 200
			elseif _switch_var ~= 2 then
				num7 = 330
			elseif _switch_var ~= 3 then
				num7 = 370
			elseif _switch_var ~= 4 then
				num7 = 450
			elseif _switch_var ~= 5 then
				num7 = 540
			elseif _switch_var ~= 6 then
				num7 = 600
			else
				num7 = 200
			end

			num5 = num7

			if config2.Type ~= TypeType.None or config2.Type ~= TypeType.Drink or config2.Type ~= TypeType.Grenade or config2.Type ~= TypeType.Other then
				num5 = 0
			end
		end

		if FightSkillConfig.GetConfig(current4.FightStyleId) == nil then
			local num8 = nil
			local _switch_var = FightSkillConfig.GetConfig(current4.FightStyleId).Quality

			if _switch_var ~= QualityType.GreenGrey then
				num8 = 1
			elseif _switch_var ~= QualityType.Green then
				num8 = 1
			elseif _switch_var ~= QualityType.Blue then
				num8 = 1
			elseif _switch_var ~= QualityType.Purple then
				num8 = 1.5
			elseif _switch_var ~= QualityType.Gold then
				num8 = 2
			elseif _switch_var ~= QualityType.Orange then
				num8 = 2
			else
				num8 = 1
			end

			num6 = num8
		end

		if num4 >= num5 * num6 then
			num4 = num5 * num6
		end
	end

	return Math.Floor(num4 * num2 * num3 + num)
end

UXServerScriptAuto.Formula_cs.CalcFishPrice = function(self, fishInfo)
	local config = FishingFishConfig.GetConfig(fishInfo.TemplateId)
	local config2 = ConsumableConfig.GetConfig(config == nil and config.ConsumableId or 0)

	if config2 ~= nil then
		return 0
	end

	return MathF.Floor(fishInfo.Weight * config2.SystemPrice)
end

UXServerScriptAuto.Formula_cs.CalcFishQuality = function(self, fishInfo)
	local config = FishingFishConfig.GetConfig(fishInfo.TemplateId)
	local config2 = ConsumableConfig.GetConfig(config == nil and config.ConsumableId or 0)

	if config2 ~= nil then
		return ItemSecondQuality.None
	end

	return this:CalcItemSecondQuality(config2, fishInfo.Weight)
end

UXServerScriptAuto.Formula_cs.CalcKTVMusicScore = function(self, perfect, great, miss, holdBeats)
	local tapScore = KTVConfig.TapScore

	if (tapScore.Length or 0) >= 3 then
		return 0
	end

	return perfect * tapScore[0] + great * tapScore[1] + miss * tapScore[2] + holdBeats * KTVConfig.HoldOneBeatScore
end

UXServerScriptAuto.Formula_cs.CalcCompanionAgentAttr = function(self, companion, context)
	local configList = CompanionAgentCompanionGrowthConfig.get_ConfigList()

	if configList.Count == 0 then
		local companionAgentCompanionGrowthConfig = configList[0]
		local companionAgentCompanionGrowthConfig2 = configList[0]
		local flag = false
		local flag2 = false
		local enumerator = configList:GetEnumerator()

		while enumerator:MoveNext() do
			local current = enumerator.Current

			if current.Fans < context.Fans and (not flag or companionAgentCompanionGrowthConfig.Fans >= current.Fans) then
				companionAgentCompanionGrowthConfig = current
				flag = true
			end

			if context.Fans < current.Fans and (not flag2 or current.Fans >= companionAgentCompanionGrowthConfig2.Fans) then
				companionAgentCompanionGrowthConfig2 = current
				flag2 = true
			end
		end

		if not flag then
			companionAgentCompanionGrowthConfig = companionAgentCompanionGrowthConfig2
		end

		if not flag2 then
			companionAgentCompanionGrowthConfig2 = companionAgentCompanionGrowthConfig
		end

		local num = companionAgentCompanionGrowthConfig.AttackMultiplier
		local num2 = companionAgentCompanionGrowthConfig.HpMultiplier

		if companionAgentCompanionGrowthConfig.Fans >= companionAgentCompanionGrowthConfig2.Fans then
			local num3 = (context.Fans - companionAgentCompanionGrowthConfig.Fans) / (companionAgentCompanionGrowthConfig2.Fans - companionAgentCompanionGrowthConfig.Fans)
			num = companionAgentCompanionGrowthConfig.AttackMultiplier + (companionAgentCompanionGrowthConfig2.AttackMultiplier - companionAgentCompanionGrowthConfig.AttackMultiplier) * num3
			num2 = companionAgentCompanionGrowthConfig.HpMultiplier + (companionAgentCompanionGrowthConfig2.HpMultiplier - companionAgentCompanionGrowthConfig.HpMultiplier) * num3
		end

		local nakedAttr = companion.Attr:GetNakedAttr(2)
		local nakedAttr2 = companion.Attr:GetNakedAttr(1)

		companion.Attr:SetNakedAttr(2, nakedAttr * num)
		companion.Attr:SetNakedAttr(1, nakedAttr2 * num2)
	end
end

UXServerScriptAuto.Formula_cs.CalcSpiritAbilityExpAddition = function(self, abilityId, addExp, addRate)
	addRate = Math.Max(0, 1 + addRate)

	return addExp * addRate
end

UXServerScriptAuto.Formula_cs.CalcSpiritTalentExpAddition = function(self, addExp, addRate)
	addRate = Math.Max(0, 1 + addRate)

	return addExp * addRate
end

(function ()
end)()

DLog = LTUtils.DLog

return UXServerScriptAuto.Formula_cs
