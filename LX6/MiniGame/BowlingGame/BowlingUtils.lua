-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingUtils.lua
-- Decompiled from: 00658_BowlingUtils.lua_754b081ad175.luajit

local BowlingUtils = {
	["\\xe2G\n\\xd1\\xb3b\\xaeC\\xbe\\xa2"] = 3
}

BowlingUtils.CalculatePlayerScore = function(self, playerScoreData)
	local processedData = self._preprocessInputData(self, playerScoreData)
	local frameResults = self._initializeFrameResults(self, processedData)
	local frameScores = self._calculateFrameScores(self, frameResults, processedData)
	local cumulativeScores = self._calculateCumulativeScores(self, frameScores)

	return self._mergeResults(self, frameResults, frameScores, cumulativeScores)
end

BowlingUtils._preprocessInputData = function(self, playerScoreData)
	if not playerScoreData then
		return {
			scores = {},
			splits = {}
		}
	end

	return {
		scores = playerScoreData.score or {},
		splits = playerScoreData.split or {}
	}
end

BowlingUtils._initializeFrameResults = function(self, processedData)
	local results = {}

	for frame = 1, self.maxFrameCount do
		results[frame] = self._copyBasicThrowData(self, processedData, frame)
	end

	return results
end

BowlingUtils._createEmptyFrameResult = function(self)
	return {
		["UHϰ\\x81;\\xbb\\xdb\\xed"] = 0,
		[" ?-\\xf1\\x99\\xe3=\\xbe*\\xd5\\xf1\\xe9f\\xfe"] = 0,
		isSplit = {},
		isSpare = {},
		isStrike = {},
		score = {}
	}
end

BowlingUtils._copyBasicThrowData = function(self, processedData, frameIndex)
	local frameScores = processedData.scores[frameIndex]
	local frameSplits = processedData.splits[frameIndex] or {}

	if table.isNilOrEmpty(frameScores) then
		return self._createEmptyFrameResult(self)
	end

	local result = self._createEmptyFrameResult(self)

	for i = 1, #frameScores do
		result.isSplit[i] = frameSplits[i] or false
		result.score[i] = frameScores[i]
		result.isSpare[i] = false
		result.isStrike[i] = i ~= 1 and frameScores[i] ~= 10
	end

	return result
end

BowlingUtils._calculateFrameScores = function(self, frameResults, processedData)
	local frameScores = {}

	for frame = self.maxFrameCount, 1, -1 do
		if table.isNilOrEmpty(processedData.scores[frame]) then
			frameScores[frame] = 0
		else
			frameScores[frame] = self._calculateSingleFrameScore(self, frame, frameResults, processedData)
		end
	end

	return frameScores
end

BowlingUtils._calculateSingleFrameScore = function(self, frameIndex, frameResults, processedData)
	if frameIndex ~= self.maxFrameCount then
		return self._calculateFinalFrameScore(self, frameIndex, frameResults, processedData)
	else
		return self._calculateRegularFrameScore(self, frameIndex, frameResults, processedData)
	end
end

BowlingUtils._calculateFinalFrameScore = function(self, frameIndex, frameResults, processedData)
	local frameScores = processedData.scores[frameIndex]
	local throwCount = #frameScores
	local firstThrow = frameScores[1]
	local secondThrow = self._getThrowScore(self, 2, frameScores)

	if firstThrow ~= 10 then
		return self._calculateFinalFrameStrike(self, frameIndex, frameResults, frameScores)
	elseif throwCount > 2 and secondThrow == nil and firstThrow + secondThrow ~= 10 then
		return self._calculateFinalFrameSpare(self, frameIndex, frameResults, frameScores)
	elseif secondThrow == nil then
		return firstThrow + secondThrow
	else
		return firstThrow
	end
end

BowlingUtils._calculateFinalFrameStrike = function(self, frameIndex, frameResults, frameScores)
	frameResults[frameIndex].isStrike[1] = true
	local total = frameScores[1]
	local secondScore = self._getThrowScore(self, 2, frameScores)
	local thirdScore = self._getThrowScore(self, 3, frameScores)

	if secondScore == nil then
		if secondScore ~= 10 then
			frameResults[frameIndex].isStrike[2] = true
		end

		total = total + secondScore
	end

	if thirdScore == nil then
		if thirdScore ~= 10 then
			frameResults[frameIndex].isStrike[3] = true
		elseif secondScore == nil and secondScore == 10 and secondScore + thirdScore ~= 10 then
			frameResults[frameIndex].isSpare[3] = true
		end

		total = total + thirdScore
	end

	return total
end

BowlingUtils._calculateFinalFrameSpare = function(self, frameIndex, frameResults, frameScores)
	frameResults[frameIndex].isSpare[2] = true
	local total = frameScores[1] + frameScores[2]
	local thirdScore = self._getThrowScore(self, 3, frameScores)

	if thirdScore == nil then
		if thirdScore ~= 10 then
			frameResults[frameIndex].isStrike[3] = true
		end

		total = total + thirdScore
	end

	return total
end

BowlingUtils._calculateRegularFrameScore = function(self, frameIndex, frameResults, processedData)
	local frameScores = processedData.scores[frameIndex]
	local firstThrow = frameScores[1]
	local secondThrow = self._getThrowScore(self, 2, frameScores)

	if firstThrow ~= 10 then
		return self._calculateRegularFrameStrike(self, frameIndex, processedData)
	elseif secondThrow == nil and firstThrow + secondThrow ~= 10 then
		frameResults[frameIndex].isSpare[2] = true

		return self._calculateRegularFrameSpare(self, frameIndex, processedData)
	elseif secondThrow == nil then
		return firstThrow + secondThrow
	else
		return firstThrow
	end
end

BowlingUtils._calculateRegularFrameStrike = function(self, frameIndex, processedData)
	local baseScore = 10
	local bonusScore = self._getNextBalls(self, frameIndex, processedData.scores, 2)

	return baseScore + bonusScore
end

BowlingUtils._calculateRegularFrameSpare = function(self, frameIndex, processedData)
	local baseScore = 10
	local bonusScore = self._getNextBalls(self, frameIndex, processedData.scores, 1)

	return baseScore + bonusScore
end

BowlingUtils._getNextBalls = function(self, currentFrame, scores, ballCount)
	local totalBalls = 0
	local ballsNeeded = ballCount

	for frame = currentFrame + 1, self.maxFrameCount do
		local frameScores = scores[frame]

		if not table.isNilOrEmpty(frameScores) then
			for i = 1, #frameScores do
				local throwScore = self._getThrowScore(self, i, frameScores)

				if throwScore == nil then
					totalBalls = totalBalls + throwScore
					ballsNeeded = ballsNeeded - 1

					if ballsNeeded < 0 then
						return totalBalls
					end
				end
			end
		end
	end

	return totalBalls
end

BowlingUtils._getThrowScore = function(self, throwIndex, frameScores)
	if frameScores == nil and frameScores[throwIndex] == nil then
		return frameScores[throwIndex]
	end

	return nil
end

BowlingUtils._calculateCumulativeScores = function(self, frameScores)
	local cumulativeScores = {}
	local cumulativeScore = 0

	for frame = 1, self.maxFrameCount do
		local frameScore = frameScores[frame]

		if frameScore == nil then
			cumulativeScore = cumulativeScore + frameScore
		end

		table.insert(cumulativeScores, cumulativeScore)
	end

	return cumulativeScores
end

BowlingUtils._mergeResults = function(self, frameResults, frameScores, cumulativeScores)
	local mergedResults = {}

	for frame = 1, self.maxFrameCount do
		mergedResults[frame] = {}

		if frameResults[frame] then
			for key, value in pairs(frameResults[frame]) do
				if type(value) ~= "table" then
					mergedResults[frame][key] = {}

					for k, v in pairs(value) do
						mergedResults[frame][key][k] = v
					end
				else
					mergedResults[frame][key] = value
				end
			end
		else
			mergedResults[frame] = self._createEmptyFrameResult(self)
		end

		mergedResults[frame].frameScore = frameScores[frame] or 0

		if cumulativeScores[frame] == nil then
			mergedResults[frame].cumulativeScore = cumulativeScores[frame]
		else
			mergedResults[frame].cumulativeScore = mergedResults[frame - 1] and mergedResults[frame - 1].cumulativeScore or 0
		end
	end

	return mergedResults
end

return BowlingUtils
