-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BasketballGame\BasketballGameManager.lua
-- Decompiled from: 00585_BasketballGameManager.lua_581b75bd1180.luajit

C_BasketballGameManager = DefClass("C_BasketballGameManager", C_BasketballGameManager, gBaseMiniGameManager)
local BasketballGameManager = C_BasketballGameManager

BasketballGameManager.CreateGame = function(self, args)
	self.currentGame = gBasketballGame.new(args)
end

BasketballGameManager.CreateGameCs = function(self, taskId, npcId, position, rotation, _)
	self:CreateGame({
		taskId = taskId,
		npcId = npcId,
		wayPointPosition = Vector3.New(position.x, position.y, position.z),
		wayPointRotation = Quaternion.New(rotation.x, rotation.y, rotation.z, rotation.w)
	})
end

BasketballGameManager.ShowBasketballQteHint = function(self, enable)
	self.currentShowBasketballQteHint = enable

	gMessageManager:SendMessage(gEventConstants.GM_BASKETBALL_GAME_SHOW_QTE_HINT, enable)
end

gBasketballGameManager = gBasketballGameManager or C_BasketballGameManager.new()
