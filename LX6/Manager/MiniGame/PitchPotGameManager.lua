-- Original chunk: @Lua\LuaFiles\LX6\Manager\MiniGame\PitchPotGameManager.lua
-- Decompiled from: 00624_PitchPotGameManager.lua_4e9c4135bbc1.luajit

C_PitchPotGameManager = DefClass("C_PitchPotGameManager", C_PitchPotGameManager)
local PitchPotGameManager = C_PitchPotGameManager

PitchPotGameManager.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.DO_CREATE_PITCH_POT, self.DoCreateNeedle)
	gMessageManager:AddMessageListener(gEventConstants.ON_START_PITCH_POT, self.DoStartFly)
	gMessageManager:AddMessageListener(gEventConstants.DO_RELOAD_PITCH_POT, self.DoReload)
	gMessageManager:AddMessageListener(gEventConstants.DO_SHOOT_PITCH_POT, self.DoShoot)

	self.currentGame = nil
end

PitchPotGameManager.CreateGame = function(self, args)
	print_debug("PitchPot: Manager:CreateGame", "hasCurrentGame", gPitchPotGameManager.currentGame == nil, "args", args)

	if gPitchPotGameManager.currentGame == nil then
		return gPitchPotGameManager.currentGame
	end

	gPitchPotGameManager.currentGame = gPitchPotGame.new(args)

	return gPitchPotGameManager.currentGame
end

PitchPotGameManager.DestroyGame = function(self)
	if self.currentGame == nil then
		local game = self.currentGame
		self.currentGame = nil

		game:DestroyGame()
	end
end

PitchPotGameManager.OnBeforeSwitchScene = function(self, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType < gSwitchSceneType.Reconnect then
		return
	end

	if gPitchPotGameManager.currentGame then
		gPitchPotGameManager.currentGame:DestroyGame()

		gPitchPotGameManager.currentGame = nil
	end
end

PitchPotGameManager.DoStartFly = function(self)
	print_debug("PitchPot: Manager:DoStartFly (cue ON_START_PITCH_POT)", "currentGame", gPitchPotGameManager.currentGame)

	if gPitchPotGameManager.currentGame then
		gPitchPotGameManager.currentGame:OnStartPitchPotTimeline()
	end
end

PitchPotGameManager.DoCreateNeedle = function(self)
	print_debug("PitchPot: Manager:DoCreateNeedle (cue DO_CREATE_PITCH_POT)", "currentGame", gPitchPotGameManager.currentGame)

	if gPitchPotGameManager.currentGame then
		gPitchPotGameManager.currentGame:CreateAllNeedlesInHand()
	end
end

PitchPotGameManager.DoReload = function(self)
	print_debug("PitchPot: Manager:DoReload (cue DO_RELOAD_PITCH_POT)", "currentGame", gPitchPotGameManager.currentGame)

	if gPitchPotGameManager.currentGame then
		gPitchPotGameManager.currentGame:ReloadOneNeedleInHand()
	end
end

PitchPotGameManager.DoShoot = function(self)
	print_debug("PitchPot: Manager:DoShoot (cue DO_SHOOT_PITCH_POT)", "currentGame", gPitchPotGameManager.currentGame)

	if gPitchPotGameManager.currentGame then
		gPitchPotGameManager.currentGame:DoShootEventTimeline()
	end
end

gPitchPotGameManager = gPitchPotGameManager or C_PitchPotGameManager.new()
