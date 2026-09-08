-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingNpcRandomAiController.lua
-- Decompiled from: 00651_BowlingNpcRandomAiController.lua_b8e4b7f874c6.luajit

require("LX6/MiniGame/BowlingGame/BowlingNpcAiControllerBase")

gBowlingNpcRandomAiController = DefClass("BowlingNpcRandomAiController", gBowlingNpcRandomAiController, gBowlingNpcAiControllerBase)
local M = gBowlingNpcRandomAiController

M.DebugLog = function(self, ...)
	if gBowlingGameManager.debug then
		print_warn("[BowlingNpcRandomAiController]", ...)
	end
end

M.BuildTurnTargets = function(self, ctx, _, launcher)
	local aiCfg = self.aiCfg

	if aiCfg ~= nil then
		print_error("[BowlingNpcRandomAiController] aiCfg is nil, please check LTConfig.PoiGameBowlingAIConfig")

		return nil
	end

	local ballId = self:SampleDiscrete(aiCfg.BallWeight, "ballId", "p", nil)
	local ballIndex = self:BallIdToBallIndex(ballId) or ctx.ballIndex or launcher.CurBallIndex or 1
	ballIndex = Mathf.Clamp(ballIndex, 1, 4)
	local avgOffset = aiCfg.AvgOffest
	local offsetSigma = aiCfg.OffestSigma
	local avgDir = aiCfg.AvgDir
	local dirSigma = aiCfg.DirSigma
	local avgForce = aiCfg.AvgForce
	local forceSigma = aiCfg.ForceSigma
	local targetOffset = self:RandomFloat(avgOffset - offsetSigma, avgOffset + offsetSigma)
	targetOffset = self:ClampToRange(targetOffset, launcher.minLaunchOffset, launcher.maxLaunchOffset)
	local targetDir = self:RandomFloat(avgDir - dirSigma, avgDir + dirSigma)
	local minDir, maxDir = launcher:GetLaunchDirRangeByOffset(targetOffset)
	targetDir = self:ClampToRange(targetDir, minDir, maxDir)
	local targetForce = self:RandomFloat(avgForce - forceSigma, avgForce + forceSigma)
	targetForce = self:ClampToRange(targetForce, 1, 100)
	local targetRotIndexRaw = self:SampleDiscrete(aiCfg.RelativeTor, "power", "p", 0)
	local targetRotIndex = self:RoundToInt(targetRotIndexRaw, 0)
	targetRotIndex = Mathf.Clamp(targetRotIndex, -5, 5)

	self:DebugLog("agentTemplateId=", self.agentTemplateId, "cfgId=", aiCfg.Id, "ballId=", ballId, "ballIndex=", ballIndex, "offset=", targetOffset, "dir=", targetDir, "force=", targetForce, "rotIndex=", targetRotIndex)

	return {
		ballIndex = ballIndex,
		offset = targetOffset,
		dir = targetDir,
		forcePercent = targetForce,
		rotIndex = targetRotIndex
	}
end

return M
