local static_props = {
	GAME_STATUS = {
		THROWING = 5,
		ROLLING = 6,
		GAMEOVER = 9,
		ANIM = 3,
		READY = 4,
		SCORING = 7,
		RESETTING = 8,
		INIT = 2,
		NONE = 1
	}
}
gBowlingModeBase = DefClass("BowlingModeBase", gBowlingModeBase, nil, static_props)
local BowlingModeBase = gBowlingModeBase

function BowlingModeBase:ctor(game, config)
	self.config = config or {}

	self:Initialize(game)
end

function BowlingModeBase:Initialize(game)
	self.game = game

	self:InitData()
end

function BowlingModeBase:InitData()
	self.gameState = BowlingModeBase.GAME_STATUS.NONE
end

function BowlingModeBase:SetCurrentPlayerBallIndex(ballIndex)
	return
end

function BowlingModeBase:ProcessGameState()
	return
end

function BowlingModeBase:PrepareNextThrow()
	return
end

function BowlingModeBase:CheckGameOver()
	return false
end

function BowlingModeBase:OnGameOver()
	return
end

function BowlingModeBase:NextFrame()
	return
end

function BowlingModeBase:GetCurrentPlayer()
	return
end

function BowlingModeBase:SwitchToNextPlayer()
	return
end

function BowlingModeBase:OnEventAnimBackEnd()
	return
end

function BowlingModeBase:GetOtherPlayerName()
	local agentCfg = LTConfig.AgentConfig.GetConfig(self.game.args.agentTemplateId)

	return agentCfg.Name
end

function BowlingModeBase:ExecuteLaunchTimeline(playerIndex, offsetX, fromSync)
	local character = self.game.characters[playerIndex]

	character:ExecuteLaunchTimeline(offsetX, fromSync)
end

local function EmptyFunction()
	return
end

BowlingModeBase.OnSyncZonePlayerInfo = EmptyFunction
BowlingModeBase.OnSyncTurnChange = EmptyFunction
BowlingModeBase.OnSyncScoreInfo = EmptyFunction
BowlingModeBase.OnSyncClientInfo = EmptyFunction
