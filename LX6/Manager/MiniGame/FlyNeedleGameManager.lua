-- Original chunk: @Lua\LuaFiles\LX6\Manager\MiniGame\FlyNeedleGameManager.lua
-- Decompiled from: 00622_FlyNeedleGameManager.lua_93291e55de07.luajit

C_FlyNeedleGameManager = DefClass("C_FlyNeedleGameManager", C_FlyNeedleGameManager)
local FlyNeedleGameManager = C_FlyNeedleGameManager

FlyNeedleGameManager.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.DO_CREATE_FLY_NEEDLE, self.DoCreateNeedle)
	gMessageManager:AddMessageListener(gEventConstants.ON_START_FLY_NEEDLE, self.DoStartFly)
	gMessageManager:AddMessageListener(gEventConstants.DO_RELOAD_FLY_NEEDLE, self.DoReload)
	gMessageManager:AddMessageListener(gEventConstants.DO_SHOOT_FLY_NEEDLE, self.DoShoot)

	self.currentGame = nil
end

FlyNeedleGameManager.CreateGame = function(self, args)
	gFlyNeedleLog.Log(gFlyNeedleLog.Cat.Init, "Manager:CreateGame", "hasCurrentGame=" .. tostring(gFlyNeedleGameManager.currentGame == nil))
	self:DestroyGame()

	gFlyNeedleGameManager.currentGame = gFlyNeedleGame.new(args)

	return gFlyNeedleGameManager.currentGame
end

FlyNeedleGameManager.DestroyGame = function(self)
	if self.currentGame == nil then
		local game = self.currentGame
		self.currentGame = nil

		game:DestroyGame()
	end
end

FlyNeedleGameManager.OnBeforeSwitchScene = function(self, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType < gSwitchSceneType.Reconnect then
		return
	end

	if gFlyNeedleGameManager.currentGame then
		gFlyNeedleGameManager.currentGame:DestroyGame()

		gFlyNeedleGameManager.currentGame = nil
	end
end

FlyNeedleGameManager.DoStartFly = function(self)
	gFlyNeedleLog.Log(gFlyNeedleLog.Cat.Timeline, "cue ON_START_FLY_NEEDLE -> DoStartFly", "hasGame=" .. tostring(gFlyNeedleGameManager.currentGame == nil))

	if gFlyNeedleGameManager.currentGame then
		gFlyNeedleGameManager.currentGame:OnStartFlyNeedleTimeline()
	end
end

FlyNeedleGameManager.DoCreateNeedle = function(self)
	gFlyNeedleLog.Log(gFlyNeedleLog.Cat.Timeline, "cue DO_CREATE_FLY_NEEDLE -> DoCreateNeedle", "hasGame=" .. tostring(gFlyNeedleGameManager.currentGame == nil))

	if gFlyNeedleGameManager.currentGame then
		gFlyNeedleGameManager.currentGame:CreateAllNeedlesInHand()
	end
end

FlyNeedleGameManager.DoReload = function(self)
	gFlyNeedleLog.Log(gFlyNeedleLog.Cat.Timeline, "cue DO_RELOAD_FLY_NEEDLE -> DoReload", "hasGame=" .. tostring(gFlyNeedleGameManager.currentGame == nil))

	if gFlyNeedleGameManager.currentGame then
		gFlyNeedleGameManager.currentGame:ReloadOneNeedleInHand()
	end
end

FlyNeedleGameManager.DoShoot = function(self)
	gFlyNeedleLog.Log(gFlyNeedleLog.Cat.Timeline, "cue DO_SHOOT_FLY_NEEDLE -> DoShoot", "hasGame=" .. tostring(gFlyNeedleGameManager.currentGame == nil))

	if gFlyNeedleGameManager.currentGame then
		gFlyNeedleGameManager.currentGame:DoShootEventTimeline()
	end
end

gFlyNeedleGameManager = gFlyNeedleGameManager or C_FlyNeedleGameManager.new()
