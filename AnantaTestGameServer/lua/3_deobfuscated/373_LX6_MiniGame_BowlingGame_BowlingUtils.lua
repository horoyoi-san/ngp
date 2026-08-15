local BowlingUtils = {
	maxFrameCount = 3
}

function BowlingUtils:CalculatePlayerScore(playerScoreData)
	local processedData = self:_preprocessInputData(playerScoreData)
	local frameResults = self:_initializeFrameResults(processedData)
	local frameScores = self:_calculateFrameScores(frameResults, processedData)
	local cumulativeScores = self:_calculateCumulativeScores(frameScores)

	return self:_mergeResults(frameResults, frameScores, cumulativeScores)
end

function BowlingUtils:_preprocessInputData(playerScoreData)
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

function BowlingUtils:_initializeFrameResults(processedData)
	local results = {}

	for frame = 1, self.maxFrameCount do
		results[frame] = self:_copyBasicThrowData(processedData, frame)
	end

	return results
end

function BowlingUtils:_createEmptyFrameResult()
	return {
		frameScore = 0,
		cumulativeScore = 0,
		isSplit = {},
		isSpare = {},
		isStrike = {},
		score = {}
	}
end

function BowlingUtils:_copyBasicThrowData(processedData, frameIndex)
	local frameScores = processedData.scores[frameIndex]
	local frameSplits = processedData.splits[frameIndex] or {}

	if table.isNilOrEmpty(frameScores) then
		return self:_createEmptyFrameResult()
	end

	local result = self:_createEmptyFrameResult()

	for i = 1, #frameScores do
		result.isSplit[i] = frameSplits[i] or false
		result.score[i] = frameScores[i]
		result.isSpare[i] = false
		result.isStrike[i] = frameScores[i] == 10
	end

	return result
end

function BowlingUtils:_calculateFrameScores(frameResults, processedData)
	local frameScores = {}

	for frame = self.maxFrameCount, 1, -1 do
		if table.isNilOrEmpty(processedData.scores[frame]) then
			frameScores[frame] = 0
		else
			frameScores[frame] = self:_calculateSingleFrameScore(frame, frameResults, processedData)
		end
	end

	return frameScores
end

function BowlingUtils:_calculateSingleFrameScore(frameIndex, frameResults, processedData)
	if frameIndex == self.maxFrameCount then
		return self:_calculateFinalFrameScore(frameIndex, frameResults, processedData)
	else
		return self:_calculateRegularFrameScore(frameIndex, frameResults, processedData)
	end
end

function BowlingUtils:_calculateFinalFrameScore(frameIndex, frameResults, processedData)
	local frameScores = processedData.scores[frameIndex]
	local throwCount = #frameScores
	local firstThrow = frameScores[1]
	local secondThrow = self:_getThrowScore(2, frameScores)

	if firstThrow == 10 then
		return self:_calculateFinalFrameStrike(frameIndex, frameResults, frameScores)
	elseif throwCount >= 2 and secondThrow ~= nil and firstThrow + secondThrow == 10 then
		return self:_calculateFinalFrameSpare(frameIndex, frameResults, frameScores)
	elseif secondThrow ~= nil then
		return firstThrow + secondThrow
	else
		return firstThrow
	end
end

function BowlingUtils:_calculateFinalFrameStrike(frameIndex, frameResults, frameScores)
	frameResults[frameIndex].isStrike[1] = true
	local total = frameScores[1]
	local secondScore = self:_getThrowScore(2, frameScores)
	local thirdScore = self:_getThrowScore(3, frameScores)

	if secondScore ~= nil then
		total = total + secondScore
	end

	if thirdScore ~= nil then
		total = total + thirdScore
	end

	return total
end

function BowlingUtils:_calculateFinalFrameSpare(frameIndex, frameResults, frameScores)
	frameResults[frameIndex].isSpare[2] = true
	local total = frameScores[1] + frameScores[2]
	local thirdScore = self:_getThrowScore(3, frameScores)

	if thirdScore ~= nil then
		total = total + thirdScore
	end

	return total
end

function BowlingUtils:_calculateRegularFrameScore(frameIndex, frameResults, processedData)
	local frameScores = processedData.scores[frameIndex]
	local firstThrow = frameScores[1]
	local secondThrow = self:_getThrowScore(2, frameScores)

	if firstThrow == 10 then
		return self:_calculateRegularFrameStrike(frameIndex, processedData)
	elseif secondThrow ~= nil and firstThrow + secondThrow == 10 then
		frameResults[frameIndex].isSpare[2] = true

		return self:_calculateRegularFrameSpare(frameIndex, processedData)
	elseif secondThrow ~= nil then
		return firstThrow + secondThrow
	else
		return firstThrow
	end
end

function BowlingUtils:_calculateRegularFrameStrike(frameIndex, processedData)
	local baseScore = 10
	local bonusScore = self:_getNextBalls(frameIndex, processedData.scores, 2)

	return baseScore + bonusScore
end

function BowlingUtils:_calculateRegularFrameSpare(frameIndex, processedData)
	local baseScore = 10
	local bonusScore = self:_getNextBalls(frameIndex, processedData.scores, 1)

	return baseScore + bonusScore
end

function BowlingUtils:_getNextBalls(currentFrame, scores, ballCount)
	local totalBalls = 0
	local ballsNeeded = ballCount

	for frame = currentFrame + 1, self.maxFrameCount do
		local frameScores = scores[frame]

		if not table.isNilOrEmpty(frameScores) then
			for i = 1, #frameScores do
				local throwScore = self:_getThrowScore(i, frameScores)

				if throwScore ~= nil then
					totalBalls = totalBalls + throwScore
					ballsNeeded = ballsNeeded - 1

					if ballsNeeded <= 0 then
						return totalBalls
					end
				end
			end
		end
	end

	return totalBalls
end

function BowlingUtils:_getThrowScore(throwIndex, frameScores)
	if frameScores ~= nil and frameScores[throwIndex] ~= nil then
		return frameScores[throwIndex]
	end

	return nil
end

function BowlingUtils:_calculateCumulativeScores(frameScores)
	local cumulativeScores = {}
	local cumulativeScore = 0

	for frame = 1, self.maxFrameCount do
		local frameScore = frameScores[frame]

		if frameScore ~= nil then
			cumulativeScore = cumulativeScore + frameScore
		end

		table.insert(cumulativeScores, cumulativeScore)
	end

	return cumulativeScores
end

function BowlingUtils:_mergeResults(frameResults, frameScores, cumulativeScores)
	local mergedResults = {}

	for frame = 1, self.maxFrameCount do
		mergedResults[frame] = {}

		if frameResults[frame] then
			for key, value in pairs(frameResults[frame]) do
				if type(value) == "table" then
					mergedResults[frame][key] = {}

					for k, v in pairs(value) do
						mergedResults[frame][key][k] = v
					end
				else
					mergedResults[frame][key] = value
				end
			end
		else
			mergedResults[frame] = self:_createEmptyFrameResult()
		end

		mergedResults[frame].frameScore = frameScores[frame] or 0

		if cumulativeScores[frame] ~= nil then
			mergedResults[frame].cumulativeScore = cumulativeScores[frame]
		else
			mergedResults[frame].cumulativeScore = mergedResults[frame - 1] and mergedResults[frame - 1].cumulativeScore or 0
		end
	end

	return mergedResults
end

return BowlingUtils
