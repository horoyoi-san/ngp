local static_props = {
	SoundId = {
		Play_basketball_extra_ball_ui = 15000404,
		Play_basketball_shoot = 15000405,
		Play_basketball_rim = 15000409,
		Play_music_basketball = 15000403,
		Play_basketball_common_ui = 15000410,
		Play_Backboard_hit_weak = 15000408,
		Play_basketball_amb = 15000418,
		Play_basketball_net = 15000413,
		Play_basketball_catch = 15000412,
		Play_backboard_hit = 15000411,
		Play_basketball_huaqiu_ui = 15000406
	}
}
gBasketballGame = DefClass("BasketballGame", gBasketballGame, gBaseMiniGame, static_props)
local BasketballGame = gBasketballGame

function BasketballGame:Initialize(args)
	self:InitData(args)
	BasketballGame.base.SetSceneOtherNodesVisible(self, false)
	self:InitBasketballScene()
	self:InitUI()
	self:RegisterEvents()
	self:PlaySound()
end

function BasketballGame:PlaySound()
	gSoundMgr:PlaySoundByTid(BasketballGame.SoundId.Play_basketball_amb)
	gSoundMgr:PlaySoundByTid(BasketballGame.SoundId.Play_music_basketball)
end

function BasketballGame:RegisterEvents()
	self.mEventHandlers = {
		[gEventConstants.PLAY_BASKET_GET_THE_BASKET_EFFECT] = function (_, effectId)
			if effectId then
				self.playGetTheScoreEffect = gCS.EffectMgr:PlayEffectsOnTransform(effectId, self.lanWangCenterTransform, self.lanWangCenterTransform.position)
			end
		end,
		[gEventConstants.BASKETBALL_GAME_PLAYER_MAKE_PREFECT_SHOOT] = function ()
			self.prefectShootCount = self.prefectShootCount + 1
		end
	}

	gMessageManager:RegisterEventHandlers(self.mEventHandlers)
end

function BasketballGame:InitCharacters(virtualCamera, lanWangCenterPoint, stimMgr)
	self.playerCharacter = gBasketballPlayerCharacter.new({
		basketballRackList = self.playerBasketballRackList,
		lanWangCenterPoint = lanWangCenterPoint,
		virtualCamera = virtualCamera,
		stimMgr = stimMgr
	})
	self.npcCharacter = gBasketballNpcCharacter.new({
		id = self.npcId,
		pid = self.npcPid,
		basketballRackList = self.npcBasketballRackList,
		lanWangCenterPoint = lanWangCenterPoint,
		stimMgr = stimMgr
	})
end

function BasketballGame:InitBasketballScene()
	local basketballSceneNodePath = LTConfig.PoiGameConfig.Basket_BallStand
	self.loadOp = gResourceManager:LoadAssetWithCallBack(basketballSceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		if not self.hasDestroy then
			local basketballSceneNodeGo = GameObject.Instantiate(loadOp.asset)
			self.basketballSceneNodeGo = basketballSceneNodeGo
			basketballSceneNodeGo.transform.position = self.wayPointPosition
			basketballSceneNodeGo.transform.rotation = self.wayPointRotation
			basketballSceneNodeGo.gameObject.name = "BasketballSceneNode"

			basketballSceneNodeGo.gameObject:SetActive(true)

			local lanWangCenterPoint = basketballSceneNodeGo.transform:Find("PivotNode/LanWangCenterPoint")
			local lanBanCenterPoint = basketballSceneNodeGo.transform:Find("PivotNode/LanBanCenterPoint")
			local basketballSceneNode = basketballSceneNodeGo.transform
			local virtualCameraNode = basketballSceneNodeGo.transform:Find("VirtualCamera")
			local cameraLookAtPoint = basketballSceneNodeGo.transform:Find("PivotNode/CameraLookAtPoint")
			local virtualCamera = virtualCameraNode:GetComponent(typeof(LX6.Cinemachine.CinemachineFixCamera))
			virtualCamera.LookAt = cameraLookAtPoint

			virtualCamera.gameObject:SetActive(false)

			self.lanWangCenterTransform = lanWangCenterPoint
			self.stimMgr = gBasketballGameStim.new()

			self:InitBasketballs(basketballSceneNode, lanWangCenterPoint, lanBanCenterPoint)
			self:InitCharacters(virtualCamera, lanWangCenterPoint, self.stimMgr)
		end
	end)
end

function BasketballGame:InitBasketballs(basketballSceneNode, lanWangCenterPoint, lanBanCenterPoint)
	local args = {
		basketballSceneNode = basketballSceneNode,
		lanWangCenterPoint = lanWangCenterPoint,
		lanBanCenterPoint = lanBanCenterPoint
	}
	self.playerBasketballRackList = self:GetBasketballRackList(args, "Left", "LeftPoint", {
		1,
		2,
		3,
		4,
		5
	})
	self.npcBasketballRackList = self:GetBasketballRackList(args, "Right", "RightPoint", {
		5,
		4,
		3,
		2,
		1
	})
end

function BasketballGame:GetBasketballRackList(args, slotName, pointName, racksList)
	local basketballSceneNode = args.basketballSceneNode
	local lanWangCenterPoint = args.lanWangCenterPoint
	local lanBanCenterPoint = args.lanBanCenterPoint
	local pointCount = 5
	local basketballRackInfoList = {}

	for _, rackIndex in ipairs(racksList) do
		local childBasketballRackName = ("BasketballRack%d"):format(rackIndex)
		local childBasketballRack = basketballSceneNode:Find(childBasketballRackName)
		local pointNode = childBasketballRack:Find("PointNode")
		local slot = childBasketballRack:Find("PositionNode/" .. slotName)
		local basketballList = {}

		for pointIndex = 1, pointCount do
			local childPointName = pointName .. pointIndex
			local pointTransform = pointNode.transform:Find(childPointName)
			local basketballType = self.basketballDataList[rackIndex][pointIndex]
			local basketballEntity = gBasketball.new({
				basketballType = basketballType,
				pointTransform = pointTransform,
				lanWangCenterPoint = lanWangCenterPoint,
				lanBanCenterPoint = lanBanCenterPoint,
				lanQiuJiaPoint = self.wayPointPosition
			})

			table.insert(basketballList, basketballEntity)
		end

		table.insert(basketballRackInfoList, {
			slotPosition = slot.position,
			transform = childBasketballRack,
			basketballList = basketballList
		})
	end

	return basketballRackInfoList
end

function BasketballGame:InitData(args)
	self.taskId = args.taskId
	self.npcId = args.npcId
	self.npcPid = args.npcPid
	self.wayPointPosition = args.wayPointPosition
	self.wayPointRotation = args.wayPointRotation
	local count = LTConfig.PoiGameBasketballConfig.count
	local targetConfig = nil

	for index = 0, count - 1 do
		local config = LTConfig.PoiGameBasketballConfig.LoadAt(index)

		if config.TaskId == self.taskId then
			targetConfig = config

			break
		end
	end

	targetConfig = targetConfig or LTConfig.PoiGameBasketballConfig.GetConfig(LTConfig.PoiGameBasketballConfig.Default)
	self.basketballDataList = {
		targetConfig.BallId1,
		targetConfig.BallId2,
		targetConfig.BallId3,
		targetConfig.BallId4,
		targetConfig.BallId5
	}
	self.prefectShootCount = 0
end

function BasketballGame:InitUI()
	self:ShowEmptyFullScreenPanel()

	self.checkLoadCompletedCo = coroutine.start(function ()
		while not self:CheckAllModelsLoaded() do
			coroutine.step()
		end

		self:SetActiveEmptyFullScreenPanel(false)
		gPanelManager:CheckShow(gPanelId.S_CHALLENGE_START_PANEL, {
			callBack = function ()
				if self.hasDestroy then
					return
				end

				self:StartGame()
			end
		})
	end)
end

function BasketballGame:CheckAllModelsLoaded()
	return self.playerCharacter and self.playerCharacter.baseUnit and self.npcCharacter and self.npcCharacter.baseUnit
end

function BasketballGame:StartGame()
	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
		gameplayType = "BasketballGame",
		backCallback = function ()
			if self.hasDestroy then
				return
			end

			gBasketballGameManager.currentGame:GiveUp()
		end
	})
	self.playerCharacter:StartGame()
	self.npcCharacter:StartGame()
end

function BasketballGame:ExecuteGameResult()
	if self.hasPlayGameEndPerform then
		return
	end

	self.hasPlayGameEndPerform = true

	self.stimMgr:GameEnd()
	self:PlayGameResultPerform()

	self.setChallengeResultCoroutine = coroutine.start(function ()
		coroutine.wait(0.2)
		gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
		self:SetActiveEmptyFullScreenPanel(true)
		self:ShowResultPanel()
		coroutine.wait(LTConfig.PoiGameConfig.Basket_Wait_Result_Time - 0.2)
		self:FinishChallenge()
	end)
end

function BasketballGame:GiveUp()
	self.isGiveUp = true

	self.stimMgr:GameEnd()
	self.playerCharacter:GameEnd()
	self.npcCharacter:GameEnd()
end

function BasketballGame:PauseGame()
	BasketballGame.base.PauseGame(self)
	self.playerCharacter:Pause()
	self.npcCharacter:Pause()
end

function BasketballGame:ResumeGame()
	BasketballGame.base.ResumeGame(self)
	self.playerCharacter:Resume()
	self.npcCharacter:Resume()
end

function BasketballGame:FinishChallenge()
	self.destroyGameCo = coroutine.start(function ()
		coroutine.wait(5)
		gBasketballGameManager:DestroyGame()
	end)
	local result = self:GetResult()
	local playerScore = self.playerCharacter.score
	local achievements = self:GetAchievements()
	gClientToGameDelegate:SetChallengeStatisticalData(self.taskId, playerScore, nil).Callback = self.CheckRpcCallback
	gClientToGameDelegate:SetChallengeResult(self.taskId, playerScore, result, achievements).Callback = self.CheckRpcCallback
end

function BasketballGame:GetResult()
	local playerScore = self.playerCharacter.score
	local npcScore = self.npcCharacter.score
	local result = not self.isGiveUp and npcScore <= playerScore and 1 or 0

	return result
end

function BasketballGame:CheckResultIsSuccess()
	local result = self:GetResult()

	return result == 1
end

function BasketballGame:GetAchievements()
	local achievements = {}
	local totalBallCount = 0

	for _, info in ipairs(self.basketballDataList) do
		totalBallCount = totalBallCount + #info
	end

	local allPrefect = self.prefectShootCount == totalBallCount

	if allPrefect then
		table.insert(achievements, UX.Game.SpecialAchievementType.Kongxin)
	end

	return achievements
end

function BasketballGame.CheckRpcCallback(errorId)
	if errorId ~= LTConfig.MessageConfig.Ok then
		gDisplayMessageMgr:DisplayServerMessageId(errorId)
	end
end

function BasketballGame:IsGameOver()
	return self.playerCharacter:IsGameOver() and self.npcCharacter:IsGameOver()
end

function BasketballGame:PlayGameResultPerform()
	local isPlayerWin, isNpcWin = nil

	if self.isGiveUp then
		isPlayerWin = false
		isNpcWin = true
	else
		local playerScore = self.playerCharacter.score
		local npcScore = self.npcCharacter.score
		isPlayerWin = npcScore <= playerScore and playerScore > 0
		isNpcWin = playerScore <= npcScore
	end

	self.playerCharacter:PlayResultAnimation(isPlayerWin)
	self.npcCharacter:PlayResultAnimation(isNpcWin)
	gMessageManager:SendMessage(gEventConstants.BASKETBALL_GAME_OVER, {
		isPlayerWin = isPlayerWin,
		isNpcWin = isNpcWin
	})
end

function BasketballGame:ExecuteShootKeyDown()
	return self.playerCharacter:ExecuteShootKeyDown()
end

function BasketballGame:ExecuteShootKeyLongPress()
	return self.playerCharacter:ExecuteShootKeyLongPress()
end

function BasketballGame:ExecuteShootKeyUp()
	return self.playerCharacter:ExecuteShootKeyUp()
end

function BasketballGame:RetryPlay()
	self.playerCharacter:Reset()
	self.npcCharacter:Reset()
	self:ResetBasketballs(self.playerBasketballRackList)
	self:ResetBasketballs(self.npcBasketballRackList)
	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
end

function BasketballGame:ResetBasketballs(basketballRackList)
	for _, rackInfo in ipairs(basketballRackList) do
		for _, basketball in ipairs(rackInfo.basketballList) do
			basketball:Reset()
		end
	end
end

function BasketballGame:UnRegisterEvents()
	gMessageManager:UnregisterEventHandlers(self.mEventHandlers)
end

function BasketballGame:GetNpcCharacter()
	return self.npcCharacter
end

function BasketballGame:StopSound()
	gSoundMgr:StopSoundByTid(BasketballGame.SoundId.Play_basketball_amb)
	gSoundMgr:StopSoundByTid(BasketballGame.SoundId.Play_music_basketball)
end

function BasketballGame:StopCoroutine()
	self.setChallengeResultCoroutine = coroutine.stop(self.setChallengeResultCoroutine)
	self.showBeginPanelCoroutine = coroutine.stop(self.showBeginPanelCoroutine)
	self.checkLoadCompletedCo = coroutine.stop(self.checkLoadCompletedCo)
	self.destroyGameCo = coroutine.stop(self.destroyGameCo)
	self.hideNpcCo = coroutine.stop(self.hideNpcCo)
end

function BasketballGame:CleanSceneObjects()
	self.lanWangCenterTransform = nil

	if self.playGetTheScoreEffect then
		self.playGetTheScoreEffect = gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.playGetTheScoreEffect)
	end

	self.playerCharacter = self.playerCharacter and self.playerCharacter:Destroy()
	self.npcCharacter = self.npcCharacter and self.npcCharacter:Destroy()
	self.playerBasketballRackList = self.playerBasketballRackList and self:DestroyBasketballs(self.playerBasketballRackList)
	self.npcBasketballRackList = self.npcBasketballRackList and self:DestroyBasketballs(self.npcBasketballRackList)
	local _ = gClientUtils.NotNil(self.basketballSceneNodeGo) and GameObject.Destroy(self.basketballSceneNodeGo)
	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)
	self.basketballSceneNodeGo = nil
end

function BasketballGame:ClosePanels()
	local panelIdList = {
		gPanelId.S_GAMEPLAY_HUD_PANEL,
		gPanelId.S_EMPTY_FULL_SCREEN_PANEL
	}

	for _, panelId in ipairs(panelIdList) do
		gPanelManager:Close(panelId)
	end
end

function BasketballGame:CleanGame()
	self:StopSound()
	self:UnRegisterEvents()
	self:StopCoroutine()
	BasketballGame.base.SetSceneOtherNodesVisible(self, true)
	self:CleanSceneObjects()
	self:ClosePanels()
end

function BasketballGame:CheckShootTimeConflict(isPlayer)
	local shootTime = isPlayer and self.npcCharacter.shootTime or self.playerCharacter.shootTime

	return shootTime and Time.time - shootTime < LTConfig.PoiGameConfig.Shoot_Conflict_Time
end

function BasketballGame:DestroyBasketballs(basketballRackList)
	for _, rackInfo in ipairs(basketballRackList) do
		for _, basketball in ipairs(rackInfo.basketballList) do
			basketball:Destroy()
		end
	end
end
