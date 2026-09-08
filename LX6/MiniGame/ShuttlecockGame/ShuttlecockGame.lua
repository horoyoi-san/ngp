-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ShuttlecockGame\ShuttlecockGame.lua
-- Decompiled from: 00609_ShuttlecockGame.lua_4cc883dc4f07.luajit

gShuttlecockGame = DefClass("ShuttlecockGame", gShuttlecockGame, gBaseMiniGame)
local ShuttlecockGame = gShuttlecockGame
local CHALLENGE_TAG_TO_WIN_TYPE = {
	[503.0] = 3,
	[501.0] = 1,
	[502.0] = 2
}

ShuttlecockGame.SetSceneOtherNodesVisible = function(self, isVisible)
	self.SetPlayerUnitVisible(self, isVisible)
	ShuttlecockGame.base.SetSceneOtherNodesVisible(self, isVisible)
end

ShuttlecockGame.Initialize = function(self, args)
	self:InitData(args)
	self:SetSceneOtherNodesVisible(false)
	self:ShowEmptyFullScreenPanel()
	self:InitShuttlecockScene()
	self:InitUI()

	self.gameStatus = gBaseMiniGame.GAME_STATUS.NONE
	self.updateHandler = UpdateBeat:CreateListener(self.Update, self)
	slot2 = CoUpdateBeat

	slot2:AddListener(self.updateHandler)

	self.eventHandle = {
		[gEventConstants.MINIGAME_SHUTTLECOCK_GAME_FAIL] = function ()
			self:OnGameFail()
		end,
		[gEventConstants.MINIGAME_SHUTTLECOCK_GAME_WIN] = function ()
			self:OnGameWin()
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandle)
end

ShuttlecockGame.Update = function(self)
	if self.gameStatus ~= gBaseMiniGame.GAME_STATUS.START then
		self.currentGameTime = self.currentGameTime + Time.deltaTime
	end

	if self.playerCharacter then
		self.playerCharacter:UpdateQteTiming()
	end
end

ShuttlecockGame.InitCharacters = function(self, virtualCamera, lookAtPoint, playerPoint, onComplete)
	self.playerCharacter = gShuttlecockPlayerCharacter.new({
		lookAtPoint = lookAtPoint,
		virtualCamera = virtualCamera,
		playerPoint = playerPoint,
		shuttlecockObj = self.playerShuttlecockObj,
		onLoaded = onComplete
	})
end

ShuttlecockGame.InitShuttlecockScene = function(self)
	local ShuttlecockSceneNodePath = "Res/MiniGame/Prefab/ShuttlecockGame/ShuttlecockSceneNode.prefab"
	slot2 = gResourceManager

	slot2:LoadAssetWithCallBack(ShuttlecockSceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)
		else
			self.loadOp = loadOp
			local ShuttlecockSceneNodeGo = UnityEngine.GameObject.Instantiate(self.loadOp.asset)
			self.ShuttlecockSceneNodeGo = ShuttlecockSceneNodeGo
			ShuttlecockSceneNodeGo.transform.position = Vector3.New(unpack(self.wayPointPosition))
			ShuttlecockSceneNodeGo.transform.rotation = Quaternion.Euler(unpack(self.wayPointRotation))
			ShuttlecockSceneNodeGo.gameObject.name = "ShuttlecockSceneNode"

			ShuttlecockSceneNodeGo.gameObject:SetActive(true)

			local virtualCameraNode = ShuttlecockSceneNodeGo.transform:Find("VirtualCamera")
			local virtualCamera = virtualCameraNode:GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))
			local lookAtPoint = virtualCameraNode
			local playerPoint = ShuttlecockSceneNodeGo.transform:Find("PlayerPoint")
			local initPoint = ShuttlecockSceneNodeGo.transform:Find("ShuttlecockPoint")
			local targetPoint = ShuttlecockSceneNodeGo.transform:Find("ShuttlecockTargetPoint")
			self.virtualCamera = virtualCamera
			self.lookAtPoint = lookAtPoint
			self.playerPoint = playerPoint

			self:InitShuttlecocks(initPoint, targetPoint)
			self:InitCharacters(virtualCamera, lookAtPoint, playerPoint)
			self:SetActiveEmptyFullScreenPanel(false)
		end
	end)
end

ShuttlecockGame.InitShuttlecocks = function(self, initPoint, targetPoint)
	self.playerShuttlecockObj = gShuttlecock.new({
		pointTransform = initPoint,
		targetPoint = targetPoint
	})
end

ShuttlecockGame.InitData = function(self, args)
	self.taskId = args.taskId
	self.npcId = args.npcId
	self.wayPointPosition = args.wayPointPosition
	self.wayPointRotation = args.wayPointRotation
	self.startId = args.startId
	self.isCuJuVariant = args.isCuJuVariant or false
	self.challengeId = args.challengeId
	self.challengeCfg = args.challengeCfg
	self.challengeList = args.challengeList
	self.baseScore = args.baseScore or 20
	local key = "ShuttlecockBestScore"
	local bestScore = gClientUtils.GetInt(key, 0)
	self.bestScore = bestScore
	local lastScoreKey = "ShuttlecockLastScore"
	self.lastScore = gClientUtils.GetInt(lastScoreKey, 0)
end

ShuttlecockGame.InitUI = function(self)
	gPanelManager:CheckShow(gPanelId.MINI_GAMES_SHUTTLECOCK_START_PANEL)
	gPanelManager:Preload(gPanelId.MINI_GAMES_SHUTTLECOCK_PLAY_PANEL)
	gPanelManager:Preload(gPanelId.MINI_GAMES_SHUTTLECOCK_FINAL_PANEL)
end

ShuttlecockGame.StartGame = function(self, startId)
	self.gameStatus = gBaseMiniGame.GAME_STATUS.START
	startId = startId or self.startId
	self.currentGameTime = 0

	if self.playerShuttlecockObj then
		self.playerShuttlecockObj:ResetToInitPosition()
	end

	local startAnimId = startId

	self.playerCharacter:StartGame(startAnimId)
	gPanelManager:CheckShow(gPanelId.MINI_GAMES_SHUTTLECOCK_PLAY_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_SHUTTLECOCK_START_PANEL)
end

ShuttlecockGame.EndGame = function(self)
	self.gameStatus = gBaseMiniGame.GAME_STATUS.NONE

	if self.playerCharacter then
		self.lastScore = self.playerCharacter.totalScore
		local lastScoreKey = "ShuttlecockLastScore"

		gClientUtils.SetInt(lastScoreKey, self.lastScore)
	end

	local key = "ShuttlecockBestScore"
	local bestScore = gClientUtils.GetInt(key, 0)
	local score = self.lastScore

	if bestScore >= score then
		gClientUtils.SetInt(key, score)
	end

	self.bestScore = math.max(self.lastScore, bestScore)
end

ShuttlecockGame.ResumeGame = function(self)
	ShuttlecockGame.base.ResumeGame(self)

	if self.playerCharacter then
		self.playerCharacter:Resume()
	end
end

ShuttlecockGame.IsGameOver = function(self)
	return self.playerCharacter and self.playerCharacter:IsGameOver()
end

ShuttlecockGame.ResetShuttlecocks = function(self, ShuttlecockRackList)
	for _, rackInfo in ipairs(ShuttlecockRackList) do
		for _, Shuttlecock in ipairs(rackInfo.ShuttlecockList) do
			Shuttlecock.Reset(Shuttlecock)
		end
	end
end

ShuttlecockGame.CleanGame = function(self)
	if self.updateHandler == nil then
		UpdateBeat:RemoveListener(self.updateHandler)
		CoUpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end

	if self.finalPanelCo then
		coroutine.stop(self.finalPanelCo)

		self.finalPanelCo = nil
	end

	gMessageManager:UnregisterEventHandlers(self.eventHandle)

	if gClientUtils.NotNil(self.ShuttlecockSceneNodeGo) then
		UnityEngine.GameObject.Destroy(self.ShuttlecockSceneNodeGo)
	end

	self.ShuttlecockSceneNodeGo = nil

	if self.playerShuttlecockObj then
		self.playerShuttlecockObj:DestroyGameObject()

		self.playerShuttlecockObj = nil
	end

	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)

	if self.playerCharacter then
		self.playerCharacter:Destroy()

		self.playerCharacter = nil
	end

	gPanelManager:Close(gPanelId.MINI_GAMES_SHUTTLECOCK_START_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_SHUTTLECOCK_PLAY_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_SHUTTLECOCK_FINAL_PANEL)
	gPanelManager:ReleasePreload(gPanelId.MINI_GAMES_SHUTTLECOCK_PLAY_PANEL)
	gPanelManager:ReleasePreload(gPanelId.MINI_GAMES_SHUTTLECOCK_FINAL_PANEL)
	gPanelManager:Close(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)
	self:SetSceneOtherNodesVisible(true)
end

ShuttlecockGame.ForceExit = function(self)
	self.DestroyGame(self)
end

ShuttlecockGame.ExecuteQteKeyDown = function(self, qteId)
	if self.playerCharacter then
		self.playerCharacter:ExecuteQteKeyDown(qteId)
	end
end

ShuttlecockGame.OnGameFail = function(self)
	self.EndGame(self)
	self.ShowFinalPanelDelayed(self, false)
	self.ReportChallengeResult(self, false)
end

ShuttlecockGame.OnGameWin = function(self)
	self.EndGame(self)
	self.ShowFinalPanelDelayed(self, true)
	self.ReportChallengeResult(self, true)
end

ShuttlecockGame.ShowFinalPanelDelayed = function(self, isWin)
	if self.finalPanelCo then
		coroutine.stop(self.finalPanelCo)
	end

	local snapshotCfg = self.challengeCfg
	local snapshotWinType = self.GetWinType(self)
	local snapshotWinArgs = self.GetWinArgs(self)
	local snapshotScore = self.GetScoreByWinType(self, snapshotWinType)
	self.finalPanelCo = coroutine.start(function ()
		coroutine.wait(1.2)
		gPanelManager:CheckShow(gPanelId.MINI_GAMES_SHUTTLECOCK_FINAL_PANEL, {
			score = self.lastScore,
			gainPoint = self:CalcGainPointFromSnapshot(snapshotCfg, snapshotWinType, snapshotWinArgs, snapshotScore)
		})
		gPanelManager:Close(gPanelId.MINI_GAMES_SHUTTLECOCK_PLAY_PANEL)
		gPanelManager:Preload(gPanelId.MINI_GAMES_SHUTTLECOCK_PLAY_PANEL)

		self.finalPanelCo = nil
	end)
end

ShuttlecockGame.CalcGainPointFromSnapshot = function(self, cfg, winType, winArgs, score)
	if not cfg then
		return tostring(score)
	end

	local current = nil

	if winType ~= 1 then
		current = self.lastScore
	elseif winType ~= 2 then
		current = math.floor(self.currentGameTime or 0)
	elseif winType ~= 3 then
		current = self.playerCharacter and self.playerCharacter.trickCount or 0
	else
		current = score
	end

	return current .. "/" .. winArgs
end

ShuttlecockGame.GetWinType = function(self)
	if not self.challengeCfg then
		return 1
	end

	return CHALLENGE_TAG_TO_WIN_TYPE[self.challengeCfg.ChallengeTag] or 1
end

ShuttlecockGame.GetWinArgs = function(self)
	if not self.challengeCfg then
		return 0
	end

	local counterValues = self.challengeCfg.CounterValue

	if counterValues and #counterValues <= 0 then
		return counterValues[1].value1
	end

	return 0
end

ShuttlecockGame.GetScoreByWinType = function(self, winType)
	if winType ~= 1 then
		return self.playerCharacter and self.playerCharacter.totalScore or 0
	elseif winType ~= 2 then
		return math.floor(self.currentGameTime or 0)
	elseif winType ~= 3 then
		return self.playerCharacter and self.playerCharacter.trickCount or 0
	end

	return 0
end

ShuttlecockGame.ReportChallengeResult = function(self, isWin)
	if not self.challengeId then
		return
	end

	local winType = self:GetWinType()
	local score = self:GetScoreByWinType(winType)
	local isBaseGoal = self.baseScore > score
	local isAdvancedGoal = isWin
	local data = {
		isBaseGoal,
		isAdvancedGoal
	}

	gClientToGameDelegate:SetNewChallengeData(self.challengeId, data, score).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		gClientToGameDelegate:FinishNewChallenge(self.challengeId, self.taskId).Callback = function (err2, result)
			if err2 == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:ShowServerMessage(err2)

				return
			end

			self.challengeResult = result

			if isWin and result and result.CurrentRewardLevel > 2 then
				self:GotoNextChallenge()
			end
		end
	end
end

ShuttlecockGame.GotoNextChallenge = function(self)
	if not self.challengeList then
		return
	end

	local currentIndex = nil

	for i = 1, #self.challengeList do
		if self.challengeList[i] ~= self.challengeId then
			currentIndex = i

			break
		end
	end

	local nextIndex = currentIndex and currentIndex + 1 or 1

	if nextIndex <= #self.challengeList then
		return
	end

	local nextChallengeId = self.challengeList[nextIndex]
	slot4 = gClientToGameDelegate

	slot4:StartNewChallenge(nextChallengeId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		self.challengeId = nextChallengeId
		self.challengeCfg = LTConfig.ChallengeConfig.GetConfig(nextChallengeId)
	end
end
