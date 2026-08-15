local M = {
	safeDriveScore = 0
}

function M:OnInit()
	self.toiletNpcRecord = {}
	self.safeDriveScore = 0
end

function M:GetSafeDriveScore()
	return self.safeDriveScore
end

function M:AddCurrentToiletGameScore(npcPid, points)
	if not self.toiletNpcRecord[npcPid] then
		self.toiletNpcRecord[npcPid] = {
			points = 0
		}
	end

	self.toiletNpcRecord[npcPid].points = self.toiletNpcRecord[npcPid].points + points
end

function M:DecreaseCurrentToiletGameScore(npcPid, points)
	if not self.toiletNpcRecord[npcPid] then
		self.toiletNpcRecord[npcPid] = {
			points = 0
		}
	end

	self.toiletNpcRecord[npcPid].points = self.toiletNpcRecord[npcPid].points - points
end

function M:SetToiletNpcResult(npcPid, result)
	if not self.toiletNpcRecord[npcPid] then
		self.toiletNpcRecord[npcPid] = {
			result = false
		}
	end

	self.toiletNpcRecord[npcPid].result = result
end

function M:GetToiletNpcPoints(npcPid)
	if self.toiletNpcRecord[npcPid] == nil then
		return -99999
	end

	return self.toiletNpcRecord[npcPid].points or -99999
end

function M:GetToiletNpcResult(npcPid)
	if self.toiletNpcRecord[npcPid] == nil then
		return false
	end

	return self.toiletNpcRecord[npcPid].result or false
end

M.SimulatorEventType = {
	OnEndDrag = 3,
	OnDrag = 2,
	OnClick = 0,
	OnBeginDrag = 1
}
M.SimulatorGameType = {
	FryTea = 0,
	PackTea = 1,
	SeedTea = 1,
	CutTea = 1,
	None = -1
}

function M:ExitSimulatorGame()
	gPanelManager:Close(gPanelId.S_FARM_PANEL)

	if self and self.currentSimulatorGame then
		self.currentSimulatorGame:CleanGame()

		self.currentSimulatorGame = nil
	end
end

function M:StartSimulatorGame(gameType, data)
	gPanelManager:CheckShow(gPanelId.S_FARM_PANEL, {
		params = {
			gameplayType = gameType,
			data = data
		}
	})
end

function M:AddPlayerSingleScore(playerId, singleScore)
	gMessageManager:SendMessage(gEventConstants.SEND_BBQ_PLAYER_SINGLE_SCORE, {
		playerId = playerId,
		singleScore = singleScore
	})
end

gMiniGameDataManager = M
