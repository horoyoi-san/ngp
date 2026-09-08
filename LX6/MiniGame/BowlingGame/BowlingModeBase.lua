-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingModeBase.lua
-- Decompiled from: 00649_BowlingModeBase.lua_3b90c18c089c.luajit

local static_props = {
	GAME_STATUS = {
		["\\x9f\\x997\\x84]\\xd0"] = 5,
		["\\xeb\\xf4817\n\\xd6"] = 6,
		["\\x8c\\x90(\\x8eE\\xdb"] = 9,
		["[Tv"] = 3,
		["\\x8b\\x83\\x8b\\x8f"] = 4,
		["\\xea\\xf8;/7\n\\xd6"] = 7,
		["qb_Lz*8<"] = 8,
		["STo"] = 2,
		["T\rS~"] = 1
	}
}
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameState = BowlingConstants.GameState
gBowlingModeBase = DefClass("BowlingModeBase", gBowlingModeBase, nil, static_props)
local BowlingModeBase = gBowlingModeBase

BowlingModeBase.ctor = function(self, game, config)
	self.config = config or {}

	self:Initialize(game)
end

BowlingModeBase.Initialize = function(self, game)
	self.game = game

	self.InitData(self)
end

BowlingModeBase.SetCurrentPlayerBallIndex = function(self, ballIndex)
end

BowlingModeBase.ProcessGameState = function(self)
end

BowlingModeBase.PrepareNextThrow = function(self)
end

BowlingModeBase.CheckGameOver = function(self)
	return false
end

BowlingModeBase.OnGameOver = function(self)
end

BowlingModeBase.NextFrame = function(self)
end

BowlingModeBase.GetCurrentPlayer = function(self)
end

BowlingModeBase.SwitchToNextPlayer = function(self)
end

BowlingModeBase.OnReturnTimelineEnd = function(self)
end

BowlingModeBase.IsAuthorityTurn = function(self)
	return true
end

BowlingModeBase.AcceptInput = function(self)
	return not self.GetCurrentPlayer(self).isNPC
end

BowlingModeBase.IsRemotePlayerTurn = function(self)
	return false
end

BowlingModeBase.ShouldBroadcastClientInfo = function(self)
	return false
end

BowlingModeBase.IsAiControlledTurn = function(self)
	return self.GetCurrentPlayer(self).isNPC
end

BowlingModeBase.GetOtherPlayerName = function(self)
	if not string.is_null_or_empty(self.otherPlayerName) then
		return self.otherPlayerName
	end

	local agentCfg = LTConfig.AgentConfig.GetConfig(self.game.args.agentTemplateId)
	self.otherPlayerName = agentCfg.Name

	return self.otherPlayerName
end

BowlingModeBase.ExecuteLaunchTimeline = function(self, playerIndex, offsetX, fromSync)
	local character = self.game.characters[playerIndex]

	character.ExecuteLaunchTimeline(character, offsetX, fromSync)
end

BowlingModeBase.ProcessStateRollingCommon = function(self, clearBall)
	if not self.game.currentBall or not self.game.currentBall:UpdateAndCheckSettle() then
		return false
	end

	local currentTime = Time.time
	self.game.gameState = GameState.SCORING
	self.game.scoringEndTime = currentTime + 3

	self.game.camera:StopFollow()

	if clearBall and self.game.ballLauncher then
		self.game.ballLauncher:ClearBall()
	end

	return true
end

local EmptyFunction = function()
end

BowlingModeBase.InitData = EmptyFunction
BowlingModeBase.OnSyncZonePlayerInfo = EmptyFunction
BowlingModeBase.OnSyncTurnChange_Async = EmptyFunction
BowlingModeBase.OnSyncScoreInfo = EmptyFunction
BowlingModeBase.OnSyncClientInfo = EmptyFunction
BowlingModeBase.Destroy = EmptyFunction
