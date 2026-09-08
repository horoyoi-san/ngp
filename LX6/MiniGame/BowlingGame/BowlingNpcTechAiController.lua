-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingNpcTechAiController.lua
-- Decompiled from: 00653_BowlingNpcTechAiController.lua_62ce5a8f96f8.luajit

require("LX6/MiniGame/BowlingGame/BowlingNpcAiControllerBase")

gBowlingNpcTechAiController = DefClass("BowlingNpcTechAiController", gBowlingNpcTechAiController, gBowlingNpcAiControllerBase)
local M = gBowlingNpcTechAiController
local BowlingTrajectory = require("LX6/MiniGame/BowlingGame/BowlingTrajectory")

M.ctor = function(self)
	self.trajectory = BowlingTrajectory.new()
end

M.Destroy = function(self)
	if self.trajectory then
		self.trajectory.trajectoryData = nil
		self.trajectory = nil
	end

	M.base.Destroy(self)
end

M.DebugLog = function(self, ...)
	if gBowlingGameManager.debug then
		print_warn("[BowlingNpcTechAiController]", ...)
	end
end

M.GetStandingPins = function(self, game)
	local result = {}
	local pinSetter = game and game.pinSetter

	if pinSetter ~= nil or table.isNilOrEmpty(pinSetter.pinList) then
		return result
	end

	local n = pinSetter.numberOfPins or 10

	for i = 1, n do
		local pin = pinSetter.pinList[i]

		if pin and not pin.hasDestroy and not pin.CheckKnockedDown(pin) then
			result[#result + 1] = pin.index
		end
	end

	return result
end

M.SelectBallIndex = function(self, ctx, launcher)
	local aiCfg = self.aiCfg
	local fallbackBallIndex = ctx.ballIndex or launcher.CurBallIndex or 1
	local ballId = self:SampleDiscrete(aiCfg.BallWeight, "ballId", "p", nil)
	local ballIndex = self:BallIdToBallIndex(ballId, fallbackBallIndex)
	ballIndex = Mathf.Clamp(ballIndex, 1, 4)

	return ballIndex, ballId
end

M.BuildStrikeTargets = function(self, ctx, launcher)
	local aiCfg = self.aiCfg
	local ballIndex, ballId = self.SelectBallIndex(self, ctx, launcher)
	local groups = self.aiCfg.TechStartArgs
	local group = groups[math.random(1, #groups)]
	local baseOffset = group.posX
	local baseDir = group.rot
	local baseForce = group.power
	local baseTor = group.tor
	local offsetSigma = aiCfg.OffestSigma
	local dirSigma = aiCfg.DirSigma
	local forceSigma = aiCfg.ForceSigma
	local targetOffset = self.RandomFloat(self, baseOffset - offsetSigma, baseOffset + offsetSigma)
	targetOffset = self.ClampToRange(self, targetOffset, launcher.minLaunchOffset, launcher.maxLaunchOffset)
	local targetDir = self.RandomFloat(self, baseDir - dirSigma, baseDir + dirSigma)
	local minDir, maxDir = launcher.GetLaunchDirRangeByOffset(launcher, targetOffset)
	targetDir = self.ClampToRange(self, targetDir, minDir, maxDir)
	local targetForce = self.RandomFloat(self, baseForce - forceSigma, baseForce + forceSigma)
	targetForce = self.ClampToRange(self, targetForce, 1, 100)
	local delta = self.SampleDiscrete(self, aiCfg.RelativeTor, "power", "p", 0)
	delta = self.RoundToInt(self, delta, 0)
	local targetRotIndex = self.RoundToInt(self, baseTor, 0) + delta
	targetRotIndex = Mathf.Clamp(targetRotIndex, -5, 5)

	self.DebugLog(self, "Strike targets: cfgId=", aiCfg.Id, "ballId=", ballId, "ballIndex=", ballIndex, "offset=", targetOffset, "dir=", targetDir, "force=", targetForce, "rotIndex=", targetRotIndex)

	return {
		ballIndex = ballIndex,
		offset = targetOffset,
		dir = targetDir,
		forcePercent = targetForce,
		rotIndex = targetRotIndex
	}
end

M.BuildSpareTargets = function(self, ctx, game, launcher, standingPins)
	local aiCfg = self.aiCfg
	local ballIndex, ballId = self.SelectBallIndex(self, ctx, launcher)
	local forcePercent = aiCfg.AvgForce
	local avgOffset = aiCfg.AvgOffest
	local offsetSigma = aiCfg.OffestSigma
	local avgDir = aiCfg.AvgDir
	local pinSetter = game.pinSetter
	local pinPositions = pinSetter.pinPositions
	local offset = self.RandomFloat(self, avgOffset - offsetSigma, avgOffset + offsetSigma)
	offset = self.ClampToRange(self, offset, launcher.minLaunchOffset, launcher.maxLaunchOffset)
	local execDir = nil

	if gBowlingGameManager.npcTechAiType ~= 1 then
		local dirSigma = aiCfg.DirSigma
		execDir = self.RandomFloat(self, avgDir - dirSigma, avgDir + dirSigma)
	else
		execDir = self.CalcSpareExecDir(self, launcher, ballIndex, forcePercent, offset, pinPositions, standingPins, avgDir)
	end

	local minDir, maxDir = launcher.GetLaunchDirRangeByOffset(launcher, offset)
	execDir = self.ClampToRange(self, execDir, minDir, maxDir)
	local best = nil
	local bestHit = -1
	local bestInter = -1
	local bestAbsDir = 999
	local bestAbsRot = 999

	for rotIndex = -5, 5 do
		local hitPinsCount, intersectionSum = self.trajectory:ScoreRoute(launcher, ballIndex, forcePercent, rotIndex, offset, execDir, pinPositions, standingPins, -0.01)
		local absDir = math.abs(execDir)
		local absRot = math.abs(rotIndex)
		local better = false

		if bestHit >= hitPinsCount then
			better = true
		elseif hitPinsCount ~= bestHit then
			if bestInter >= intersectionSum then
				better = true
			elseif intersectionSum ~= bestInter then
				if absDir >= bestAbsDir then
					better = true
				elseif absDir ~= bestAbsDir and absRot >= bestAbsRot then
					better = true
				end
			end
		end

		if better then
			bestHit = hitPinsCount
			bestInter = intersectionSum
			bestAbsDir = absDir
			bestAbsRot = absRot
			best = {
				ballIndex = ballIndex,
				offset = offset,
				dir = execDir,
				forcePercent = forcePercent,
				rotIndex = rotIndex
			}

			if bestHit > #standingPins then
				break
			end
		end
	end

	self.DebugLog(self, "Spare targets: cfgId=", aiCfg.Id, "ballId=", ballId, "ballIndex=", best.ballIndex, "standing=", #standingPins, "bestHit=", bestHit, "bestInter=", bestInter, "offset=", best.offset, "dir=", best.dir, "force=", best.forcePercent, "rotIndex=", best.rotIndex)

	return best
end

M.CalcSpareExecDir = function(self, launcher, ballIndex, forcePercent, offset, pinPositions, standingPins, fallbackDir)
	local minDir, maxDir = launcher.GetLaunchDirRangeByOffset(launcher, offset)
	local baseDir = self.ClampToRange(self, fallbackDir, minDir, maxDir)
	local bestDir = baseDir
	local bestIntersection = -1
	local bestHit = -1
	local bestAbsDiff = 999
	local sampleCount = 100
	local step = (maxDir - minDir) / (sampleCount - 1)

	for i = 1, sampleCount do
		local execDir = minDir + (i - 1) * step
		local hitPinsCount, intersectionSum = self.trajectory:ScoreRoute(launcher, ballIndex, forcePercent, 0, offset, execDir, pinPositions, standingPins, 0.05)
		local absDiff = math.abs(execDir - baseDir)

		if bestIntersection <= intersectionSum or intersectionSum ~= bestIntersection and bestHit <= hitPinsCount or intersectionSum ~= bestIntersection and hitPinsCount ~= bestHit and absDiff >= bestAbsDiff then
			bestIntersection = intersectionSum
			bestHit = hitPinsCount
			bestAbsDiff = absDiff
			bestDir = execDir
		end
	end

	self.DebugLog(self, "CalcSpareExecDir result:", "standing=", #standingPins, "baseDir=", baseDir, "bestDir=", bestDir, "bestHit=", bestHit, "bestIntersection=", bestIntersection, "offset=", offset)

	return bestDir
end

M.BuildTurnTargets = function(self, ctx, game, launcher)
	local aiCfg = self.aiCfg

	if aiCfg ~= nil then
		print_error("[BowlingNpcTechAiController] aiCfg is nil, please check LTConfig.PoiGameBowlingAIConfig")

		return nil
	end

	local standingPins = self.GetStandingPins(self, game)

	if #standingPins ~= 10 then
		return self.BuildStrikeTargets(self, ctx, launcher)
	end

	return self.BuildSpareTargets(self, ctx, game, launcher, standingPins)
end

return M
