local BowlingMessageManager = {}
local MessageStructure = {
	[gEventConstants.BOWLING_GAME_REFRESH_SCORE] = {
		currentFrame = "number",
		knockedPins = "number",
		currentThrow = "number",
		currentPlayerIndex = "number",
		playerCount = "number",
		frameCompleted = "table",
		frameScores = "table",
		frameSpare = "table",
		isSplit = "boolean",
		totalScore = "number"
	},
	[gEventConstants.BOWLING_GAME_LANUCH_STATE] = {
		state = "number"
	},
	[gEventConstants.BOWLING_GAME_PINSTATE] = "table",
	[gEventConstants.BOWLING_TECH_SUCCICON_HIDE] = false,
	[gEventConstants.BOWLING_NPC_ROT] = {
		isRight = "number"
	},
	[gEventConstants.BOWLING_GAME_SCORE_ARROW] = {
		currentFrame = "number",
		currentPlayerIndex = "number",
		currentThrow = "number",
		preFrameSpare = "number"
	},
	[gEventConstants.BOWLING_GAME_FRAME_DESC] = {
		frame = "number",
		playerIndex = "number",
		isSwitch = "boolean"
	}
}

local function ValidateMessageData(messageType, data)
	local structure = MessageStructure[messageType]

	if structure == nil then
		print_debug("Warning: Unknown message type: " .. messageType)

		return true
	end

	if structure == false then
		return true
	end

	if type(structure) == "string" then
		if type(data) ~= structure then
			print_debug(string.format("Error: Data should be %s, got %s", structure, type(data)))

			return false
		end

		return true
	end

	for field, expectedType in pairs(structure) do
		local value = data[field]

		if value == nil then
			print_debug("Error: Missing required field: " .. field)

			return false
		end

		if type(value) ~= expectedType then
			print_debug(string.format("Error: Field %s should be %s, got %s", field, expectedType, type(value)))

			return false
		end
	end

	return true
end

function BowlingMessageManager:SendMessage(messageType, data)
	if ValidateMessageData(messageType, data) then
		gMessageManager:SendMessage(messageType, data)
	end
end

function BowlingMessageManager:BuildScoreMessage(player, gameMode)
	return {
		totalScore = player.totalScore or 0,
		currentFrame = player.currentFrame or 1,
		currentThrow = player.currentThrow or 1,
		knockedPins = player.knockedPins or 0,
		isSplit = player.isSplit or false,
		frameScores = player.frameScores or {},
		frameSpare = player.frameSpare or {},
		frameCompleted = player.frameCompleted or {},
		currentPlayerIndex = gameMode.currentPlayerIndex or 1,
		playerCount = gameMode.config.playerCount or 1
	}
end

return BowlingMessageManager
