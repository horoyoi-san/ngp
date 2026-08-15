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
local UXRandom = LTUtils.UXRandom
local DestructibleConfig = _LTConfigWrap.DestructibleConfig
local DestructibleMaterialConfig = _LTConfigWrap.DestructibleMaterialConfig
local HurtEffectConfig = _LTConfigWrap.HurtEffectConfig
local HurtEffectHittingTypeDestructibleConfig = _LTConfigWrap.HurtEffectHittingTypeDestructibleConfig
local TaxiNavigationConfig = _LTConfigWrap.TaxiNavigationConfig
local UberSimRandomGoodsConfig = _LTConfigWrap.UberSimRandomGoodsConfig
local FashionSuitConfig = _LTConfigWrap.FashionSuitConfig
local GenderType = _LTConfigWrap.FashionSuitConfig.GenderType
local FactionDispositionConfig = _LTConfigWrap.FactionDispositionConfig

function UXServerScriptAuto.Formula_cs:GetNpcFavorLevel(favor)
	local num = Math.Abs(favor)
	local num2 = 0
	local array = Array.New({
		888,
		2222,
		4000,
		6666,
		9778
	})

	if array[4] <= num then
		num2 = 5
	elseif array[3] <= num then
		num2 = 4
	elseif array[2] <= num then
		num2 = 3
	elseif array[1] <= num then
		num2 = 2
	elseif array[0] <= num then
		num2 = 1
	end

	if favor >= 0 then
		return num2
	end

	return -num2
end

function UXServerScriptAuto.Formula_cs:GetReduceRate(level, def)
	if def < 0 then
		def = 0
	end

	return def / (def + level * 100 + 100)
end

function UXServerScriptAuto.Formula_cs:CalcSuperHitPushData(hurtEffectId, radius, power, spreadTimes)
	repeat
		local _switch_var = hurtEffectId

		if _switch_var == 55001231 then
			radius = 4
			power = 999
			spreadTimes = 4

			return 3, radius, power, spreadTimes
		end

		if _switch_var == 55001235 then
			radius = 4
			power = 999
			spreadTimes = 3

			return 3, radius, power, spreadTimes
		end

		if _switch_var == 55001236 then
			radius = 4
			power = 999
			spreadTimes = 3

			return 3, radius, power, spreadTimes
		end

		if _switch_var == 55001237 then
			radius = 4
			power = 999
			spreadTimes = 5

			return 3, radius, power, spreadTimes
		end

		radius = 4
		power = 0
		spreadTimes = 0

		return 0, radius, power, spreadTimes
	until true
end

function UXServerScriptAuto.Formula_cs:CalcPlayerPopularityGeneratePoints(points, currentServerTime, outPoints)
	outPoints = DList.Default()
	local i = 0

	while i < points.Count do
		outPoints:Add(points[i])

		i = i + 1
	end

	return outPoints
end

function UXServerScriptAuto.Formula_cs:CalcSpreadPushCurve(spreadTimes, lastRadius, lastPower, pushForce, curveId, time, distance, radius, power)
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

function UXServerScriptAuto.Formula_cs:CalcHitOnWallPower(originalForce, actualDistance)
	local num = Math.Max(originalForce - actualDistance, 0)

	return num * num * num * 4e-05 - 0.0061 * num * num + 0.3321 * num + 1.3656
end

function UXServerScriptAuto.Formula_cs:CalcAlchemyResult(matriealList, sizeRate, Durability)
	sizeRate = 1
	Durability = 1

	return 1, sizeRate, Durability
end

function UXServerScriptAuto.Formula_cs:Dialog14AutoSkipTime(characterNum)
	return Math.Max(Math.Min((characterNum - 5) / 4 + 2, 8), 4)
end

function UXServerScriptAuto.Formula_cs:Random(min, max)
	return UXRandom.Range(min, max)
end

function UXServerScriptAuto.Formula_cs:CalBasketballNoteSensitivity(AttributeUrban)
	local num = UXRandom.Range(0, 1) * 0.6

	if AttributeUrban == nil then
		return num
	end

	local num2 = 0.4 * (1 - UXRandom.Range(0, 1) * (1 - AttributeUrban[3] * 0.01))
	local num3 = num + num2

	if num3 > 1 then
		num3 = 1
	end

	if num3 < 0.1 then
		num3 = 0.1
	end

	return num3
end

function UXServerScriptAuto.Formula_cs:CalDartsShakeAmpSensitivity(AttributeUrban)
	return 1.1 - 0.2 * AttributeUrban[3] * 0.01
end

function UXServerScriptAuto.Formula_cs:CalDartsShakeFreqSensitivity(AttributeUrban)
	return 1.1 - 0.2 * AttributeUrban[3] * 0.01
end

function UXServerScriptAuto.Formula_cs:CalDartsOkRangeSensitivity(AttributeUrban)
	return 0.8 + 0.2 * AttributeUrban[3] * 0.01
end

function UXServerScriptAuto.Formula_cs:CalDartsPerfectRangeSensitivity(AttributeUrban)
	return 0.8 + 0.2 * AttributeUrban[3] * 0.01
end

function UXServerScriptAuto.Formula_cs:CalLivehouseNoteSensitivity(AttributeUrban, BaseNoteSensitivity)
	if AttributeUrban == nil then
		return BaseNoteSensitivity
	end

	return BaseNoteSensitivity * (1 + 0.2 * AttributeUrban[1] * 0.01)
end

function UXServerScriptAuto.Formula_cs:CalNewSitup_InitialGreatRange(AttributeUrban, NewSitup_InitialGreatRange)
	if AttributeUrban == nil then
		return NewSitup_InitialGreatRange
	end

	return NewSitup_InitialGreatRange * (1 + 0.625 * (AttributeUrban[6] - 20) * 0.01)
end

function UXServerScriptAuto.Formula_cs:CalNewSitup_InitialGoodRange(AttributeUrban, NewSitup_InitialGoodRange)
	if AttributeUrban == nil then
		return NewSitup_InitialGoodRange
	end

	return NewSitup_InitialGoodRange * (1 + 0.625 * (AttributeUrban[6] - 20) * 0.01)
end

function UXServerScriptAuto.Formula_cs:CalSquat_InitialCount(AttributeUrban, Squat_InitialCount)
	if AttributeUrban == nil then
		return Squat_InitialCount
	end

	local num = AttributeUrban[4] < 60 and Squat_InitialCount or Squat_InitialCount - 1

	return num
end

function UXServerScriptAuto.Formula_cs:CalSwingDownAddGravity(AttributeUrban, SwingGravity)
	if AttributeUrban == nil then
		return SwingGravity
	end

	local num = 1
	local num2 = 40

	if AttributeUrban[3] <= num2 then
		num = 1 + 0.25 * (AttributeUrban[3] - num2) * 0.01

		if num < 0.1 then
			num = 0.1
		end

		return SwingGravity * num
	end

	return SwingGravity * (1 + 1 * (AttributeUrban[3] - num2) * 0.01)
end

function UXServerScriptAuto.Formula_cs:CalSwingUpReduceGravity(AttributeUrban, SwingGravity)
	if AttributeUrban == nil then
		return SwingGravity
	end

	local num = 40

	if AttributeUrban[3] <= num then
		return SwingGravity * (1 - 0.25 * (AttributeUrban[3] - num) * 0.01)
	end

	return SwingGravity * (1 - 0.3 * (AttributeUrban[3] - num) * 0.01)
end

function UXServerScriptAuto.Formula_cs:CalSwingAddMaxSpeed(AttributeUrban)
	if AttributeUrban == nil then
		return 0
	end

	local num = 0
	local num2 = 40

	if AttributeUrban[3] <= num2 then
		return (AttributeUrban[3] - num2) * 1 / num2
	end

	return (AttributeUrban[3] - num2) * 6 / (100 - num2)
end

function UXServerScriptAuto.Formula_cs:CalAirRushAddMaxSpeed(AttributeUrban)
	if AttributeUrban == nil then
		return 0
	end

	local num = 0
	local num2 = 40

	if AttributeUrban[3] <= num2 then
		return (AttributeUrban[3] - num2) * 1 / num2
	end

	return (AttributeUrban[3] - num2) * 10 / (100 - num2)
end

function UXServerScriptAuto.Formula_cs:CalVehicleSpeedUpgrade1(AttributeUrban, MaxSpeed, src)
	if AttributeUrban == nil then
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

function UXServerScriptAuto.Formula_cs:CalVehicleSpeedUpgrade2(AttributeUrban, IdleTorque, src)
	if AttributeUrban == nil then
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

function UXServerScriptAuto.Formula_cs:CalVehicleSpeedUpgrade3(AttributeUrban, PeakTorque, src)
	if AttributeUrban == nil then
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

function UXServerScriptAuto.Formula_cs:CalVehicleSpeedUpgrade4(AttributeUrban, MaxRpmTorque, src)
	if AttributeUrban == nil then
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

function UXServerScriptAuto.Formula_cs:CalVehicleDriftUpgrade(AttributeUrban, SteerLerpBackSpeed, src)
	if AttributeUrban == nil then
		return SteerLerpBackSpeed
	end

	return SteerLerpBackSpeed + AttributeUrban[4] * 2
end

function UXServerScriptAuto.Formula_cs:GetDestructibleDamageAndForceFromVehicle(vehicleTemplateId, vehicleMass, velocity, destructibleTemplateId, reactionId, physicMatId, volumeToIndex, damage, force)
	local num = 0
	local num2 = 0.0054
	local num3 = 0.086399995

	if destructibleTemplateId ~= 1 then
		num = DestructibleConfig.GetConfig(destructibleTemplateId).VehicleThreshold
	end

	if destructibleTemplateId == 1 then
		num = DestructibleMaterialConfig.GetConfig(physicMatId).VehicleThreshold[volumeToIndex]
	end

	local num4 = Math.Sqrt(velocity.X * velocity.X + velocity.Y * velocity.Y + velocity.Z * velocity.Z)
	force = 1000 * Math.Sqrt(vehicleMass / 1000) * num4 * num2
	damage = 1000 * Math.Sqrt(vehicleMass / 1000) * num4 * num3

	if force < num then
		damage = 0
	end

	return damage, force
end

function UXServerScriptAuto.Formula_cs:GetSkillDamageToVehicle(vehicleTemplateId, vehicleMass, vehicleVelocity, skillId, releaserId, releaseSpirit)
	local num = 300000
	local num2 = 5
	local num3 = 146.6
	local num4 = 9
	local num5 = 0

	if skillId ~= 0 then
		local config = HurtEffectConfig.GetConfig(skillId)
		local num6 = 0

		if config ~= nil then
			num6 = config.HittingTypeDestructible
		end

		if num6 ~= 0 then
			local forceForCar = HurtEffectHittingTypeDestructibleConfig.GetConfig(num6).ForceForCar
			local num7 = num / num2 / num3

			if num4 < forceForCar then
				num5 = num7 * forceForCar
			end

			if releaseSpirit ~= nil and releaseSpirit:HasBuff(52810305) and skillId == 55004529 then
				num5 = num5 * 1.5
			end
		end
	end

	return num5
end

function UXServerScriptAuto.Formula_cs:GetContactDamageToVehicle(vehicleTemplateId, vehicleMass, carVelocityList, RelativeVelocity, objectType, touchMass, enemyWeight, enemyRank, ActiveSpirit, disableThreshold, isPlayerInThisVehicle, isPlayerInOtherVehicle)
	local num = 1000
	local num2 = 100
	local num3 = 5
	local num4 = 8
	local num5 = 101

	if disableThreshold then
		num4 = 0
		num5 = 0
	end

	local num6 = 300000 / num3 / (num * num2 / 3.6)
	local num7 = 0
	local uXVector = carVelocityList[0]
	local uXVector2 = carVelocityList[1] - uXVector
	local num8 = uXVector2.X * uXVector2.X + uXVector2.Y * uXVector2.Y + uXVector2.Z * uXVector2.Z
	local num10 = nil
	local i = 0

	while i < 3 do
		local j = i + 1

		while j < 3 do
			local uXVector3 = carVelocityList[j] - carVelocityList[i]
			local num9 = uXVector3.X * uXVector3.X + uXVector3.Y * uXVector3.Y + uXVector3.Z * uXVector3.Z

			if num8 < num9 then
				num8 = num9
			end

			j = j + 1
		end

		i = i + 1
	end

	num10 = Math.Sqrt(num8)
	local num11 = RelativeVelocity.X * RelativeVelocity.X + RelativeVelocity.Y * RelativeVelocity.Y + RelativeVelocity.Z * RelativeVelocity.Z
	local num12 = uXVector.X * uXVector.X + uXVector.Y * uXVector.Y + uXVector.Z * uXVector.Z

	if disableThreshold and ActiveSpirit == nil then
		num12 = 0.25 * num11
	end

	if num11 >= num4 * num4 then
		if objectType == 11 then
			if enemyRank == 5 then
				if num12 >= num4 * num4 then
					num10 = Math.Sqrt(num12)
					num7 = Math.Sqrt(num * vehicleMass * num10 * num10 * num10 * num6 * num6 / (num2 / 3.6))
				end
			elseif num5 <= enemyWeight and num12 >= num4 * num4 then
				num7 = Math.Sqrt(num * vehicleMass * num10 * num10 * num10 * num6 * num6 / (num2 / 3.6))
			end

			if ActiveSpirit ~= nil and ActiveSpirit:HasBuff(52900005) then
				num7 = 0
			end
		end

		if objectType == 12 or objectType == 7 then
			if num5 <= touchMass then
				num7 = Math.Sqrt(num * vehicleMass * num10 * num10 * num10 * num6 * num6 / (num2 / 3.6)) * 0.25
			end
		else
			num7 = Math.Sqrt(num * vehicleMass * num10 * num10 * num10 * num6 * num6 / (num2 / 3.6))

			if not isPlayerInThisVehicle and not isPlayerInOtherVehicle then
				num7 = 0.1 * num7
			end
		end
	end

	if objectType == 17 and num12 >= num4 * num4 then
		num10 = Math.Sqrt(Math.Sqrt(num12 * num11))
		num7 = Math.Sqrt(num * vehicleMass * num10 * num10 * num10 * num6 * num6 / (num2 / 3.6))

		if not isPlayerInThisVehicle and not isPlayerInOtherVehicle then
			num7 = 0.1 * num7
		elseif ActiveSpirit ~= nil and ActiveSpirit:HasBuff(52810306) then
			num7 = num7 * 1.5
		end
	end

	return Math.Min(num7, 50000)
end

function UXServerScriptAuto.Formula_cs:GetPlayerVehicleAccelerationScale(src)
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

	return num
end

function UXServerScriptAuto.Formula_cs:GetPlayerVehicleTopSpeedScale(src)
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

	return num
end

function UXServerScriptAuto.Formula_cs:GetPlayerVehicleGroundMatDriveScale(src)
	return 1
end

function UXServerScriptAuto.Formula_cs:GetPlayerVehicleBrakeScale(src)
	local num = 1

	if src:HasBuff(52999023) then
		num = num + 0.1
	end

	if src:HasBuff(52810802) then
		num = num + 0.15
	end

	return num
end

function UXServerScriptAuto.Formula_cs:GetPlayerVehicleShiftTimeScale(src)
	local num = 1

	if src:HasBuff(52606128) then
		num = num - 0.5
	end

	return num
end

function UXServerScriptAuto.Formula_cs:GetPlayerVehicleSteerDecelerationScale(src)
	local num = 1

	if src:HasBuff(52810803) then
		num = num - 0.1
	end

	return num
end

function UXServerScriptAuto.Formula_cs:GetPlayerVehicleDriftDecelerationScale(src)
	return 1
end

function UXServerScriptAuto.Formula_cs:GetTaxiNormalCost(dis)
	if dis < 200 then
		return Math.Ceiling(TaxiNavigationConfig.TaxiNormalCost)
	end

	return Math.Ceiling(TaxiNavigationConfig.TaxiNormalCost + (dis - 200) * TaxiNavigationConfig.TaxiExtraCost * 0.005)
end

function UXServerScriptAuto.Formula_cs:GetTaxiFinalCost(baseCost, curCost, teleport)
	return baseCost + curCost + (teleport and TaxiNavigationConfig.TaxiCostRandom.max or UXRandom.Range(TaxiNavigationConfig.TaxiCostRandom.min, TaxiNavigationConfig.TaxiCostRandom.max))
end

function UXServerScriptAuto.Formula_cs:CalcChallengeParamScore(challengeId, challengeParamId, value)
	if challengeId == 1 then
		repeat
			local _switch_var = challengeParamId

			if _switch_var == 1 then
				if value > 6 then
					return 10000
				end

				return 0
			end

			if _switch_var == 4 then
				if value >= 5 then
					return 10000
				end

				return 0
			end

			if _switch_var == 3 then
				if value >= 6 then
					return 10000
				end

				return 0
			end
		until true
	end

	if challengeId == 2 then
		repeat
			local _switch_var = challengeParamId

			if _switch_var == 7 then
				return 10000
			end

			if _switch_var == 2 then
				if value >= 5 then
					return 10000
				end

				return 0
			end

			if _switch_var == 6 then
				if value >= 10 then
					return 10000
				end

				return 0
			end
		until true
	end

	local _switch_var = 6666

	return _switch_var
end

function UXServerScriptAuto.Formula_cs:CalcChallengeParamTimeScore(challengeId, challengeParamId, value)
	return 10000
end

function UXServerScriptAuto.Formula_cs:CalcChallengeScore(challengeId, paramDatas)
	repeat
		local _switch_var = challengeId

		if _switch_var == 1 then
			local num2 = 0
			local enumerator = paramDatas.Values:GetEnumerator()

			while enumerator:MoveNext() do
				local current2 = enumerator.Current
				num2 = num2 + current2
			end

			return num2
		end

		if _switch_var == 2 then
			local num = 0
			local enumerator = paramDatas.Values:GetEnumerator()

			while enumerator:MoveNext() do
				local current = enumerator.Current
				num = num + current
			end

			return num
		end

		return 6666
	until true
end

function UXServerScriptAuto.Formula_cs:CalcPoliceFineRate(falseFacts, npcCharacter, activeBadges)
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

function UXServerScriptAuto.Formula_cs:CalcPoliceViolationRate(_type, activeBadges)
	local num = 0.5

	if _type == 3 then
		num = 0.4
	end

	if _type == 4 then
		num = 0.3
	end

	local num2 = 1

	if activeBadges:Contains(19001047) then
		num2 = 0.6
	end

	return num * num2
end

function UXServerScriptAuto.Formula_cs:CalcPoliceChargingProgressIncrease(player, passTime)
	return passTime
end

function UXServerScriptAuto.Formula_cs:GetPoliceNextMissionDelayTime(completeMissionCnt)
	local num = 5

	repeat
		local _switch_var = completeMissionCnt

		if _switch_var == 0 or _switch_var == 1 or _switch_var == 2 then
			return UXRandom.Range(3, 6)
		end

		if _switch_var == 3 or _switch_var == 4 then
			return UXRandom.Range(10, 20)
		end

		return UXRandom.Range(completeMissionCnt * 20, completeMissionCnt * 30)
	until true
end

function UXServerScriptAuto.Formula_cs:DestructibleChangeHPWhenIncline(cargoId, player, angle)
	local num = 9.25926e-07
	local config = UberSimRandomGoodsConfig.GetConfig(cargoId)

	if config ~= nil then
		local angle2 = config.angle
		local num2 = num * (angle - angle2) * (angle - angle2) + 0.0075

		if player:HasBuff(52980303) then
			num2 = num2 * 0.75
		end

		return num2
	end

	return 0
end

function UXServerScriptAuto.Formula_cs:CalcBeggarBehaviorData(fashions, fashionQuality, begPose, dailyBegTime, begTime, begSpot, poseBegTime, totalAttractedNpc, isPromoted, npcGatherRate, npcGatherLimit, dialogId, begRewardMean, begRewardVariance, npcList)
	npcList = DList.Default()
	local num = 1 / Math.Ceiling(dailyBegTime / 3600)
	local num2 = Math.Ceiling(begTime / 10)
	local num3 = 1 / Math.Ceiling(poseBegTime / 120)
	local num4 = 0.4
	local num5 = 1
	local num6 = Math.Max(2, Math.Sqrt(num2))
	local num7 = Math.Max(1, Math.Sqrt(Math.Max(fashionQuality - 3, 0)))

	if begPose > 3 then
		num5 = 1.2
	end

	if begTime > 1800 then
		num6 = 1 / (Math.Ceiling(begTime / 30) - 59)
	end

	npcGatherRate = num4 * num5 * num * num6 * num3 * Math.Sqrt(begSpot)
	local num8 = 10
	local num9, num10 = nil
	npcGatherLimit = num8 * num6 / 2 * Math.Sqrt(begSpot)
	num9 = 20
	num10 = 25

	if begPose > 3 then
		num5 = 1.5
	end

	begRewardMean = num9 * num5 * 1.5 / num7
	begRewardVariance = num10 * num5 * num7
	dialogId = 0

	if totalAttractedNpc > 1 and totalAttractedNpc <= 5 then
		if fashionQuality > 9 then
			if begPose > 3 then
				dialogId = 12
			end

			if begPose <= 3 then
				dialogId = 10
			end
		end

		if fashionQuality <= 9 then
			if begPose > 3 then
				dialogId = 11
			end

			if begPose <= 3 then
				dialogId = 9
			end
		end
	end

	if totalAttractedNpc > 5 and totalAttractedNpc <= 15 then
		if fashionQuality > 9 then
			if begPose > 3 then
				dialogId = 8
			end

			if begPose <= 3 then
				dialogId = 6
			end
		end

		if fashionQuality <= 9 then
			if begPose > 3 then
				dialogId = 7
			end

			if begPose <= 3 then
				dialogId = 5
			end
		end
	end

	if totalAttractedNpc > 15 then
		if fashionQuality > 9 then
			if begPose > 3 then
				dialogId = 4
			end

			if begPose <= 3 then
				dialogId = 2
			end
		end

		if fashionQuality <= 9 then
			if begPose > 3 then
				dialogId = 3
			end

			if begPose <= 3 then
				dialogId = 1
			end
		end
	end

	if fashions:Contains(11120031) and fashions:Contains(11120030) and fashionQuality < 10 and begSpot == 3 then
		npcList:Add(45151012)
		npcList:Add(45151013)
		npcList:Add(45151014)
		npcList:Add(45151015)
		npcList:Add(45151016)
	end

	return npcGatherRate, npcGatherLimit, dialogId, begRewardMean, begRewardVariance, npcList
end

function UXServerScriptAuto.Formula_cs:CalcBeggarExp(reward)
	return 0.05 * reward
end

function UXServerScriptAuto.Formula_cs:CalcWasherMoneyRewardPercent(missionId, missionLevel, washerProgress)
	return washerProgress / 100
end

function UXServerScriptAuto.Formula_cs:CalcWasherProficiencyRewardPercent(missionId, missionLevel, washerProgress, usingTime)
	return ValueTuple.Default(washerProgress / 100, 0)
end

function UXServerScriptAuto.Formula_cs:GetNpcFashionSuit(genderType, tag)
	local count = FashionSuitConfig.count
	local dList = DList.Default()
	local dList2 = DList.Default()
	local i = 0

	while count > i do
		local fashionSuitConfig = FashionSuitConfig.LoadAt(i)

		if tag == fashionSuitConfig.Tag and (genderType == fashionSuitConfig.Gender or fashionSuitConfig.Gender == GenderType.Unknow) and fashionSuitConfig.Weight ~= 0 then
			dList:Add(fashionSuitConfig.Id)
			dList2:Add(fashionSuitConfig.Weight)
		end

		i = i + 1
	end

	if dList.Count > 0 then
		local num = 0
		local j = 0

		while j < dList2.Count do
			num = num + dList2[j]
			j = j + 1
		end

		local num2 = UXRandom.Range(0, num)
		local num3 = 0
		local k = 0

		while k < dList2.Count do
			num3 = num3 + dList2[k]

			if Prelude.Int64.LessThan(num2, num3) then
				return dList[k]
			end

			k = k + 1
		end
	end

	return 0
end

function UXServerScriptAuto.Formula_cs:CalcCorrectiveNpcFavorByFaction(npcId, addValue, npcFactionId, currentInfos)
	local array = Array.New({
		0.8,
		0.9,
		1,
		1.1,
		1.2
	})
	local num = addValue
	local value = nil

	if function ()
		local r = nil
		r, value = currentInfos:TryGetValue(18000000, nil)

		return r
	end() then
		num = value.Item2 >= 5 and array[4] * addValue or value.Item2 >= 4 and array[3] * addValue or value.Item2 >= 3 and array[2] * addValue or value.Item2 < 2 and array[0] * addValue or array[1] * addValue
	end

	return num
end

function UXServerScriptAuto.Formula_cs:CalcCorrectiveFactionByFanAndFaction(addDispositions, fan, currentInfos)
	local array = Array.New({
		83000,
		383000
	})
	local array2 = Array.New({
		1.05,
		1.1
	})
	local num = 1
	local i = 0

	if i < (array.Length or 0) then
		while i < (array.Length or 0) and array[i] <= fan do
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

function UXServerScriptAuto.Formula_cs:FactionAddDispositions(FactionId, value, addDispositionsOutPut)
	if not addDispositionsOutPut:TryAdd(FactionId, value) then
		addDispositionsOutPut[FactionId] = addDispositionsOutPut[FactionId] + value
	end
end

function UXServerScriptAuto.Formula_cs:CalcDonateMoneyForFactionLevelUp(curDisposition, achieveDisposition)
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

	while i < (array.Length or 0) do
		local array2 = array[i]
		local num2 = Math.Max(curDisposition, array2[0])
		local num3 = Math.Min(achieveDisposition, array2[1])

		if num2 < num3 then
			num = num + (num3 - num2) * array2[2]
		end

		i = i + 1
	end

	return num
end

function UXServerScriptAuto.Formula_cs:CalcFactionDispositionAfterDonateMoney(curDisposition, money)
	local num = curDisposition
	local num2 = money
	local num3 = -500
	local num4 = 100
	local num5 = 300
	local num6 = 500
	local num7 = 2100
	local num8 = 1000
	local val = 9999

	if num < num3 then
		local num9 = (num3 - num) * num4

		if num2 < num9 then
			num = num + math.floor(num2 / num4)

			return Math.Min(num, val)
		end

		num = num3
		num2 = num2 - num9
	end

	if num < num5 and num2 > 0 then
		local num10 = (num5 - num) * num6

		if num2 < num10 then
			num = num + math.floor(num2 / num6)

			return Math.Min(num, val)
		end

		num = num5
		num2 = num2 - num10
	end

	if num < num7 and num2 > 0 then
		local num11 = (num7 - num) * num8

		if num2 < num11 then
			num = num + math.floor(num2 / num8)

			return Math.Min(num, val)
		end

		num = num7
		num2 = num2 - num11
	end

	if num2 > 0 then
		num = num + math.floor(num2 / num8)

		return Math.Min(num, val)
	end

	return num
end

function UXServerScriptAuto.Formula_cs:CalcCorrectiveNpcFilterWeight(factionId, factionValue, originalWeight, influenceType)
	if influenceType == 1 then
		local num = 1

		if factionValue >= 80 then
			num = 1
		elseif factionValue >= 60 then
			num = 0.7
		elseif factionValue < 30 then
			num = 0
		else
			num = 0.4
		end

		return num * originalWeight
	end

	if factionValue <= 20 then
		return 0.08
	end

	return 0
end

function UXServerScriptAuto.Formula_cs:CalcQuantumWalletReward(startTime, nowTime)
	local num = (nowTime - startTime) / 360
	local num2 = Math.Floor(1000 * (Math.Pow(1.01, num) - 1))

	if num2 >= 10000 then
		num2 = 10000
	end

	num2 = math.floor(num2 / 10) * 10

	return num2
end

function UXServerScriptAuto.Formula_cs:CalcCraftMachineInertiaDamping(playUnit)
	return 200
end

function UXServerScriptAuto.Formula_cs:CalcCrouchAssassinationVisualEventValue(detectorPos, detectorEyeDir, targetPos)
	local num = (detectorPos.X - targetPos.X) * (detectorPos.X - detectorPos.X) + (detectorPos.Z - targetPos.Z) * (detectorPos.Z - targetPos.Z)
	local num2 = targetPos.Y - detectorPos.Y

	Math.Abs(num2)

	local result = 0

	if num2 >= 5 then
		return 0
	end

	if num <= 25 then
		result = 100
	elseif num > 25 and num <= 64 then
		result = 55
	elseif num > 64 and num <= 100 then
		result = 20
	end

	return result
end

function UXServerScriptAuto.Formula_cs:CalBeHitNumMult(src)
	return 1
end

function UXServerScriptAuto.Formula_cs:CalKillNumMult(src)
	local num = 1

	if src:HasBuff(52802000) then
		num = num + 1
	end

	return num
end

DLog = LTUtils.DLog

return UXServerScriptAuto.Formula_cs
