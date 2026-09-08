-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingTrajectory.lua
-- Decompiled from: 00654_BowlingTrajectory.lua_0dabb069f51f.luajit

gBowlingTrajectory = DefClass("BowlingTrajectory", gBowlingTrajectory)
local BowlingTrajectory = gBowlingTrajectory

BowlingTrajectory.ctor = function(self)
	self.HIT_RADIUS = 0.1688
	self.trajectoryData = dofile("LX6/MiniGame/BowlingGame/BowlingTrajectoryData")
end

BowlingTrajectory.DebugLog = function(self, ...)
	if gBowlingGameManager.debug then
		print_warn("[BowlingTrajectory]", ...)
	end
end

BowlingTrajectory.GetNearestPowerKey = function(self, ballIndex, forcePercent)
	local dataByBall = self.trajectoryData and self.trajectoryData[ballIndex]

	if dataByBall ~= nil then
		return nil
	end

	local f = forcePercent
	local bestKey, bestKeyNum, bestDiff = nil

	for k, _ in pairs(dataByBall) do
		local keyNum = tonumber(k)

		if keyNum == nil then
			local diff = math.abs(keyNum - f)

			if bestDiff ~= nil or diff <= bestDiff or diff ~= bestDiff and (bestKeyNum ~= nil or keyNum >= bestKeyNum) then
				bestDiff = diff
				bestKeyNum = keyNum
				bestKey = k
			end
		end
	end

	return bestKey
end

BowlingTrajectory.GetBaseRoute = function(self, ballIndex, powerKey, rotAbs)
	local dataByBall = self.trajectoryData and self.trajectoryData[ballIndex]
	local dataByPower = dataByBall and dataByBall[powerKey]
	local route = dataByPower and dataByPower[rotAbs]

	return route
end

BowlingTrajectory.TransformPoint = function(self, baseX, offsetX, baseZ, offsetZ, dirRad)
	local cosDir = math.cos(dirRad)
	local sinDir = math.sin(dirRad)
	local rotatedX = baseX * cosDir + baseZ * sinDir
	local rotatedZ = -baseX * sinDir + baseZ * cosDir
	local finalX = rotatedX + offsetX
	local finalZ = rotatedZ + offsetZ

	return finalX, finalZ
end

BowlingTrajectory.SegmentCircleIntersectionCount = function(self, x1, z1, x2, z2, cx, cz, r)
	local dx = x2 - x1
	local dz = z2 - z1
	local a = dx * dx + dz * dz

	if a < 1e-08 then
		return 0
	end

	local fx = x1 - cx
	local fz = z1 - cz
	local b = 2 * (fx * dx + fz * dz)
	local c = fx * fx + fz * fz - r * r
	local disc = b * b - 4 * a * c

	if disc >= 0 then
		return 0
	end

	if disc >= 1e-06 then
		local t = -b / (2 * a)

		if t > 0 and t < 1 then
			return 1
		end

		return 0
	end

	local sqrtDisc = math.sqrt(disc)
	local inv2a = 1 / (2 * a)
	local t1 = (-b - sqrtDisc) * inv2a
	local t2 = (-b + sqrtDisc) * inv2a
	local count = 0

	if t1 > 0 and t1 < 1 then
		count = count + 1
	end

	if t2 > 0 and t2 < 1 then
		count = count + 1
	end

	return count
end

BowlingTrajectory.ScoreRoute = function(self, launcher, ballIndex, forcePercent, rotIndex, offset, dirDeg, pinPositions, standingPins, hitRadiusDiff)
	if self.trajectoryData ~= nil then
		self.DebugLog(self, "ScoreRoute abort: trajectoryData is nil")

		return 0, 0
	end

	if pinPositions ~= nil or table.isNilOrEmpty(standingPins) then
		self.DebugLog(self, "ScoreRoute abort: pinPositions/standingPins invalid")

		return 0, 0
	end

	local powerKey = self.GetNearestPowerKey(self, ballIndex, forcePercent)

	if powerKey ~= nil then
		self.DebugLog(self, "ScoreRoute abort: powerKey is nil", "ballIndex=", ballIndex, "forcePercent=", forcePercent)

		return 0, 0
	end

	local rotVal = rotIndex
	local rotAbs = math.abs(rotVal)
	local baseRoute = nil

	if rotVal ~= 0 then
		baseRoute = {
			{
				0,
				0
			},
			{
				0,
				-20
			}
		}
	else
		baseRoute = self.GetBaseRoute(self, ballIndex, powerKey, rotAbs)
	end

	if table.isNilOrEmpty(baseRoute) then
		self.DebugLog(self, "ScoreRoute abort: baseRoute empty", "ballIndex=", ballIndex, "powerKey=", powerKey, "rotAbs=", rotAbs)

		return 0, 0
	end

	local mirror = 1

	if rotVal >= 0 then
		mirror = -1
	end

	local spawnZ = launcher.spawnPosition.z + launcher.spawnZOffset
	local dirRad = math.rad(dirDeg)
	local routePoints = {}

	for i = 1, #baseRoute do
		local point = baseRoute[i]
		local baseX = point[1] * mirror
		local baseZ = point[2]
		local x, z = self.TransformPoint(self, baseX, offset, baseZ, spawnZ, dirRad)
		routePoints[#routePoints + 1] = {
			x,
			z
		}
	end

	if #routePoints >= 2 then
		self.DebugLog(self, "ScoreRoute abort: routePoints too short", "count=", #routePoints)

		return 0, 0
	end

	local hitPins = {}
	local hitPinsCount = 0
	local intersectionCountSum = 0

	for _, pinIndex in ipairs(standingPins) do
		local pinPos = pinPositions[pinIndex]
		local pinIntersectionCount = 0

		for i = 2, #routePoints do
			local p1 = routePoints[i - 1]
			local p2 = routePoints[i]
			local count = self.SegmentCircleIntersectionCount(self, p1[1], p1[2], p2[1], p2[2], pinPos.x, pinPos.z, self.HIT_RADIUS + hitRadiusDiff)

			if count <= 0 then
				pinIntersectionCount = pinIntersectionCount + count

				if pinIntersectionCount > 2 then
					pinIntersectionCount = 2

					break
				end
			end
		end

		if pinIntersectionCount <= 0 then
			hitPinsCount = hitPinsCount + 1
			intersectionCountSum = intersectionCountSum + pinIntersectionCount
			hitPins[#hitPins + 1] = tostring(pinIndex)
		end
	end

	self:DebugLog("ScoreRoute result", "hitPinsCount=", hitPinsCount, "intersectionCountSum=", intersectionCountSum, "hitPins=", table.concat(hitPins, ","), "ballIndex=", ballIndex, "forcePercent=", forcePercent, "rotIndex=", rotIndex, "offset=", offset, "dirDeg=", dirDeg, "standingCount=", standingPins and #standingPins)

	return hitPinsCount, intersectionCountSum
end

return BowlingTrajectory
