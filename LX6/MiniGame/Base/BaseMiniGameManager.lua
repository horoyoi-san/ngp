-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\Base\BaseMiniGameManager.lua
-- Decompiled from: 00583_BaseMiniGameManager.lua_8d7450244174.luajit

gBaseMiniGameManager = DefClass("BaseMiniGameManager", gBaseMiniGameManager)
local BaseMiniGameManager = gBaseMiniGameManager

BaseMiniGameManager.ctor = function(self)
	self.currentGame = nil
end

BaseMiniGameManager.CreateGame = function(self, _)
end

BaseMiniGameManager.IsPlayChallengeTaskById = function(self, taskId)
	return self.currentGame and self.currentGame.taskId ~= taskId
end

BaseMiniGameManager.IsPlayChallengeTask = function(self)
	return self.currentGame and self.currentGame.taskId == nil
end

BaseMiniGameManager.RetryPlay = function(self, taskId)
	self:DestroyGame()
	gTaskManager:SetCurrentTask(taskId)
end

BaseMiniGameManager.DestroyGame = function(self)
	if self.currentGame then
		self.currentGame:DestroyGame()

		self.currentGame = nil
	end
end

BaseMiniGameManager.PauseGame = function(self)
	if self.currentGame then
		self.currentGame:PauseGame()
	end
end

BaseMiniGameManager.ResumeGame = function(self)
	if self.currentGame then
		self.currentGame:ResumeGame()
	end
end

BaseMiniGameManager.FinishChallenge = function(self)
	if self.currentGame then
		self.currentGame:FinishChallenge()
	end
end
