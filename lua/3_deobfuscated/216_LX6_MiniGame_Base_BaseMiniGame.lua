local LogicalHiddenCause = LX6.Units.LogicalHiddenCause
local static_props = {
	GAME_STATUS = {
		PAUSE = 3,
		END = 3,
		START = 2,
		NONE = 1
	}
}
gBaseMiniGame = DefClass("BaseMiniGame", gBaseMiniGame, nil, static_props)
local BaseMiniGame = gBaseMiniGame

function BaseMiniGame:ctor(args)
	self:CreateGame(args)
end

function BaseMiniGame:CreateGame(args)
	self.gameStatus = gBaseMiniGame.GAME_STATUS.START

	self:BeforeInitialize()
	self:Initialize(args)
end

function BaseMiniGame:StartGame()
	return
end

function BaseMiniGame:BeforeInitialize()
	gCS.MindPowerMgr.Instance:EnterOrLeaveMiniGameBlockMind(true)
end

function BaseMiniGame:SetSceneOtherNodesVisible(isVisible)
	if gCS.MyPlayerManager.PlayerUnit and not gCS.MyPlayerManager.PlayerUnit.IsDestroyed then
		gCS.MyPlayerManager.PlayerUnit.PlayerObj.gameObject:SetActive(isVisible)
	end

	if not self.npcId then
		return
	end

	self.hideNpcCo = coroutine.stop(self.hideNpcCo)
	local csUnit = gCS.NpcMgr:GetNpcByTemplateId(self.npcId)
	local npcUnit = csUnit and gCS.SceneDataMgr.GetUnit(csUnit.Pid)

	if npcUnit then
		local hidden = not isVisible

		gCS.BaseUnitUtils.SetUnitLogicalHidden(csUnit, hidden, LogicalHiddenCause.TaskLogic)
	elseif isVisible == false then
		self.hideNpcCo = coroutine.start(function ()
			while true do
				csUnit = csUnit or gCS.NpcMgr:GetNpcByTemplateId(self.npcId)

				if csUnit then
					npcUnit = npcUnit or gCS.SceneDataMgr.GetUnit(csUnit.Pid)

					if npcUnit then
						gCS.BaseUnitUtils.SetUnitLogicalHidden(csUnit, true, LogicalHiddenCause.TaskLogic)

						break
					elseif npcUnit.IsDestroyed then
						break
					end
				end

				coroutine.step()
			end

			self.hideNpcCo = coroutine.stop(self.hideNpcCo)
		end)
	end

	gMessageManager:SendMessage(gEventConstants.TASK_INSTRUCTION_GPS_ACTIVE, isVisible)
end

function BaseMiniGame:Initialize(_)
	return
end

function BaseMiniGame:PauseGame()
	self.gameStatus = gBaseMiniGame.GAME_STATUS.PAUSE
end

function BaseMiniGame:ResumeGame()
	self.gameStatus = gBaseMiniGame.GAME_STATUS.START
end

function BaseMiniGame:BeforeDestroyGame()
	gCS.MindPowerMgr.Instance:EnterOrLeaveMiniGameBlockMind(false)
end

function BaseMiniGame:DestroyGame()
	self.hasDestroy = true
	self.gameStatus = gBaseMiniGame.GAME_STATUS.END

	self:BeforeDestroyGame()
	self:CleanGame()
end

function BaseMiniGame:FinishChallenge()
	return
end

function BaseMiniGame:CleanGame()
	return
end

function BaseMiniGame:GetResult()
	return self.isSuccess
end

function BaseMiniGame:RetryGame()
	local args = self.args

	self:CleanUI()
	self:DestroyGame()
	self:CreateGame(args)
end

function BaseMiniGame:ShowResultPanel()
	local isSuccess = self:CheckResultIsSuccess()

	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = isSuccess
	})
end

function BaseMiniGame:ShowEmptyFullScreenPanel()
	gPanelManager:CheckShow(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)
end

function BaseMiniGame:SetActiveEmptyFullScreenPanel(isVisible)
	gPanelManager:SetActiveById(gPanelId.S_EMPTY_FULL_SCREEN_PANEL, isVisible)
end

function BaseMiniGame:CheckAllModelsLoaded()
	return
end
