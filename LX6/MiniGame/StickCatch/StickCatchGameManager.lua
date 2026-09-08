-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\StickCatch\StickCatchGameManager.lua
-- Decompiled from: 00619_StickCatchGameManager.lua_c8c4d5442375.luajit

C_StickCatchGameManager = DefClass("C_StickCatchGameManager", C_StickCatchGameManager)
local StickCatchGameManager = C_StickCatchGameManager

StickCatchGameManager.CreateGame = function(self, args)
	self.currentGame = gStickCatchGame.new(args)
end

StickCatchGameManager.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
end

StickCatchGameManager.OnBeforeSwitchScene = function(self, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType < gSwitchSceneType.Reconnect then
		return
	end

	if gStickCatchGameManager.currentGame then
		gStickCatchGameManager.currentGame:ForceExit()

		gStickCatchGameManager.currentGame = nil
	end
end

StickCatchGameManager.CreateGameCs = function(self, taskId, npcId, position, rotation, _)
	self:CreateGame({
		taskId = taskId,
		npcId = npcId,
		wayPointPosition = position,
		wayPointRotation = rotation
	})
end

StickCatchGameManager.ExitGameCs = function(self)
	if self.currentGame then
		self.currentGame:ForceExit()
	end

	self.currentGame = nil
end

gStickCatchGameManager = gStickCatchGameManager or C_StickCatchGameManager.new()
