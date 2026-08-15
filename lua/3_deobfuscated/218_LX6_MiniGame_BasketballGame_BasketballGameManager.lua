C_BasketballGameManager = DefClass("C_BasketballGameManager", C_BasketballGameManager, gBaseMiniGameManager)
local BasketballGameManager = C_BasketballGameManager

function BasketballGameManager:CreateGame(args)
	self.currentGame = gBasketballGame.new(args)
end

function BasketballGameManager:CreateGameCs(taskId, npcId, position, rotation, _)
	self:CreateGame({
		taskId = taskId,
		npcId = npcId,
		wayPointPosition = Vector3.New(position.x, position.y, position.z),
		wayPointRotation = Quaternion.New(rotation.x, rotation.y, rotation.z, rotation.w)
	})
end

function BasketballGameManager:ShowBasketballQteHint(enable)
	self.currentShowBasketballQteHint = enable

	gMessageManager:SendMessage(gEventConstants.GM_BASKETBALL_GAME_SHOW_QTE_HINT, enable)
end

gBasketballGameManager = gBasketballGameManager or C_BasketballGameManager.new()
