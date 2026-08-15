gBaseMiniGameManager = DefClass("BaseMiniGameManager", gBaseMiniGameManager)
local BaseMiniGameManager = gBaseMiniGameManager

function BaseMiniGameManager:ctor()
	self.currentGame = nil
end

function BaseMiniGameManager:CreateGame(_)
	return
end

function BaseMiniGameManager:IsPlayChallengeTaskById(taskId)
	return self.currentGame and self.currentGame.taskId == taskId
end

function BaseMiniGameManager:IsPlayChallengeTask()
	return self.currentGame and self.currentGame.taskId ~= nil
end

function BaseMiniGameManager:RetryPlay(taskId)
	self:DestroyGame()
	gTaskManager:SetCurrentTask(taskId)
end

function BaseMiniGameManager:DestroyGame()
	if self.currentGame then
		self.currentGame:DestroyGame()

		self.currentGame = nil
	end
end

function BaseMiniGameManager:PauseGame()
	if self.currentGame then
		self.currentGame:PauseGame()
	end
end

function BaseMiniGameManager:ResumeGame()
	if self.currentGame then
		self.currentGame:ResumeGame()
	end
end

function BaseMiniGameManager:FinishChallenge()
	if self.currentGame then
		self.currentGame:FinishChallenge()
	end
end
