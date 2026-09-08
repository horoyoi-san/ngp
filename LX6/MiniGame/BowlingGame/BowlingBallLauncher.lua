-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingBallLauncher.lua
-- Decompiled from: 00641_BowlingBallLauncher.lua_6be93fdfe841.luajit

gBowlingBallLauncher = DefClass("BowlingBallLauncher", gBowlingBallLauncher)
local BowlingBallLauncher = gBowlingBallLauncher
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig").Launcher
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local LaunchState = BowlingConstants.LaunchState
local GameState = BowlingConstants.GameState

BowlingBallLauncher.ctor = function(self, game)
	self.InitData(self, game)
end

BowlingBallLauncher.InitData = function(self, game)
	self.game = game
	self.LaunchState = LaunchState.ANIM
	self.CurBallIndex = math.ceil(#Config.prefabPaths.balls / 2)
	self.launchForward = -Vector3.forward
	self.minLaunchForce = Config.minLaunchForce
	self.maxLaunchForce = Config.maxLaunchForce
	self.launchForce = Config.minLaunchForce[self.CurBallIndex]
	self.minLaunchOffset = Config.minLaunchOffset
	self.maxLaunchOffset = Config.maxLaunchOffset
	self.launchOffset = 0
	self.dirCompensationFactor = 2
	self.minLaunchDir = Config.minLaunchDir
	self.maxLaunchDir = Config.maxLaunchDir
	self.launchDir = 0
	self.IsAutoDirRight = true
	self.minLaunchTor = Config.minLaunchTor
	self.maxLaunchTor = Config.maxLaunchTor
	self.launchTor = 0
	self.launchRotIndex = 0
	self.spawnZOffset = Config.spawnZOffset or 0
	self.chargePower = 0
	self.currentBall = nil
	self.CTime = Config.chargeTime[self.CurBallIndex]
	self.CTimePower = Config.chargeTimePower[self.CurBallIndex]

	self:ResetLastCTime()

	self.ballLightPrefab = nil

	self:LoadBallLightPoint()

	self.objBallLightPoint = nil
	self.arrowTipsPrefab = nil

	self:LoadArrowTips()

	self.objArrowTips = nil

	self.onGameOverHandler = function()
		if gClientUtils.NotNil(self.objArrowTips) then
			self.objArrowTips:SetActive(false)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.BOWLING_GAME_OVER, self.onGameOverHandler)

	self.swingReduceMaxByWeight = {
		0.3,
		0.4,
		0.5,
		0.6,
		0.7
	}

	if not gUrbanAbilityManager.SpiritPanelData then
		gUrbanAbilityManager:GetAllSpiritPanelData()
	end
end

BowlingBallLauncher.SetSceneNode = function(self, node)
	if gClientUtils.NotNil(node) then
		self.sceneNode = node
		local BallSpawnPoint = self.sceneNode.transform:Find("PivotNode/BallSpawnPoint")

		self:SetSpawnPoint(BallSpawnPoint.localPosition)
	end
end

BowlingBallLauncher.SetSpawnPoint = function(self, point)
	self.spawnPosition = point
end

BowlingBallLauncher.LoadBallLightPoint = function(self)
	local PrefabPath = Config.prefabPaths.ballLight
	slot2 = gResourceManager

	slot2:LoadAssetWithCallBack(PrefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		self.ballLightPrefab = loadOp.asset
	end)
end

BowlingBallLauncher.LoadArrowTips = function(self)
	local PrefabPath = Config.prefabPaths.arrowTips
	slot2 = gResourceManager

	slot2:LoadAssetWithCallBack(PrefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		self.arrowTipsPrefab = loadOp.asset
	end)
end

BowlingBallLauncher.ConfirmAimPosition = function(self)
	self.LaunchState = LaunchState.DIR
	self.dirStartTime = Time.time

	if self.objBallLightPoint then
		self.objBallLightPoint:SetActive(false)
	end

	if self.objArrowTips ~= nil then
		self.CreateArrowTips(self)
	end

	if self.objArrowTips then
		self.objArrowTips:SetActive(true)
	end

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState
	})
end

BowlingBallLauncher.ConfirmAimDirection = function(self)
	self.LaunchState = LaunchState.POWER
	self.powerStartTime = Time.time
	self.dirStartTime = nil

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState
	})
end

BowlingBallLauncher.ConfirmAimPower = function(self)
	self.LaunchState = LaunchState.ROT
	self.powerStartTime = nil

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState
	})
end

BowlingBallLauncher.HandleAimConfirm = function(self)
	local game = self.game

	if game.gameState == GameState.READY then
		return
	end

	if self.LaunchState ~= LaunchState.POS then
		self.ConfirmAimPosition(self)
	elseif self.LaunchState ~= LaunchState.DIR then
		self.ConfirmAimDirection(self)
	elseif self.LaunchState ~= LaunchState.POWER then
		self.ConfirmAimPower(self)
		self.StartShotSequence(self)
	end
end

BowlingBallLauncher.StartShotSequence = function(self)
	local game = self.game

	game:SetGameState(GameState.THROWING)

	if gBowlingGameManager:IsMatchGame() then
		local gameMode = game.gameMode
		local player = gameMode.players[gameMode.currentPlayerIndex]
		local throwIndex = nil

		if player.throwScoresClient then
			throwIndex = #player.throwScoresClient[player.currentFrame] + 1
		else
			local frame = player.currentFrame
			local history = player.knockedPinsHistory[frame]
			throwIndex = (history and #history or 0) + 1

			if player.maxFrames >= frame then
				for f = player.maxFrames, frame - 1 do
					local h = player.knockedPinsHistory[f]

					if h then
						throwIndex = throwIndex + #h
					end
				end
			end
		end

		local agentInstanceId = game.characters[gameMode.currentPlayerIndex].serverAgentInstanceId

		if ulong.Greater(agentInstanceId or 0, 0) then
			gBowlingGameManager:AskAgentBowlingRelease(agentInstanceId, throwIndex)
		elseif gameMode.IsLocalPlayerTurn(gameMode) or gameMode.IsAiControlledTurn(gameMode) then
			gBowlingGameManager:AskBowlingRelease(throwIndex)
		else
			print_error("BowlingBallLauncher:StartShotSequence - Unknown turn type, currentPlayerIndex", gameMode.currentPlayerIndex)
		end
	end

	self.launchHandler = function()
		gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_BOWLING_LAUNCH, self.launchHandler)

		self.launchHandler = nil

		self:OnTimelineLaunchEvent()
	end

	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_BOWLING_LAUNCH, self.launchHandler)
	game:PlayLaunchTimeline()
end

BowlingBallLauncher.OnTimelineLaunchEvent = function(self)
	local game = self.game
	local character = game:GetCurrentCharacter()

	if (not gBowlingGameManager:IsOnlineGame() or game.gameMode:IsAuthorityTurn()) and character then
		character.PlayBallLaunchAnim(character, self.GetSpawnPoint(self), function ()
			self:ExecutePhysicsLaunch(character.currentBall)
		end)
	end
end

BowlingBallLauncher.ExecutePhysicsLaunch = function(self, ball)
	local game = self.game

	self:ApplyPhysicsLaunch(ball)
	game:SetCurrentBall(ball)
	game.pinSetter:RegisterPinsUpdate()

	if gClientUtils.NotNil(ball.rigidbody) then
		ball.rigidbody.interpolation = UnityEngine.RigidbodyInterpolation.Interpolate
	end

	game.SetGameState(game, GameState.ROLLING)

	local ballSceneItemId = ball.sceneItemId
	local forcePercentage = game.GetCurrentLaunchForcePercentage(game)
	game.ballRollSound = game.StartBallLaunchEffects(game, ballSceneItemId, forcePercentage, ball, function ()
		if game.currentBall ~= ball and not ball.hasDestroy and not ball.settled then
			return true
		end

		return false
	end)

	game.BroadcastRemoteBallObserveStart(game, ballSceneItemId, forcePercentage)
	game.SetIsLaunchEnd(game, true)
end

BowlingBallLauncher.CreateBallLightPoint = function(self)
	if gClientUtils.NotNil(self.objBallLightPoint) then
		return
	end

	if not self.ballLightPrefab then
		return
	end

	local pos = Vector3.New(0, 0.01, self.spawnPosition.z - 0.05)
	local balllight = UnityEngine.GameObject.Instantiate(self.ballLightPrefab, self.sceneNode.transform)
	self.objBallLightPoint = balllight
	self.objBallLightPoint.transform.localPosition = pos
	self.objBallLightPoint.transform.localRotation = Quaternion.Euler(90, 0, 0)
	self.leftArrow = self.objBallLightPoint.transform:Find("Icon_Ball_ArrowTip02")
	self.rightArrow = self.objBallLightPoint.transform:Find("Icon_Ball_ArrowTip02 (1)")
end

BowlingBallLauncher.CreateArrowTips = function(self)
	if not self.arrowTipsPrefab then
		return
	end

	local pos = Vector3.New(self.launchOffset, 0.01, self.spawnPosition.z - 0.05)

	if gClientUtils.NotNil(self.objArrowTips) then
		self.objArrowTips.transform.localPosition = pos
		self.objArrowTips.transform.localRotation = Quaternion.Euler(0, self.launchDir, 0)

		return
	end

	local ArrowTipsGo = UnityEngine.GameObject.Instantiate(self.arrowTipsPrefab, self.sceneNode.transform)
	self.objArrowTips = ArrowTipsGo
	self.objArrowTips.transform.localPosition = pos
	self.objArrowTips.transform.localRotation = Quaternion.Euler(0, self.launchDir, 0)
end

BowlingBallLauncher.ApplyPhysicsLaunch = function(self, ball)
	self.LaunchState = LaunchState.ROLLING

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState
	})

	if self.objArrowTips then
		self.objArrowTips:SetActive(false)
	end

	if self.objBallLightPoint then
		self.objBallLightPoint:SetActive(false)
	end

	local pos = self.GetSpawnPoint(self)
	local ballGo = ball.gameObject

	if gClientUtils.IsNil(ballGo) then
		print_error("BowlingBallLauncher:ApplyPhysicsLaunch() ballGo is nil")

		return
	end

	local ballConfig = Config.prefabPaths.balls[self.CurBallIndex]

	ball:EnablePhysics(true, ballConfig and ballConfig.mass)
	self.game.pinSetter:WakeupAllPins()
	ball.sceneItemHold:SyncPositionAndRotation(self.sceneNode.transform:TransformPoint(pos), self.sceneNode.transform.rotation)

	local force = self.launchForward * self.launchForce
	local rotation = Quaternion.Euler(0, self.launchDir, 0)
	local rotatedForce = rotation * force

	ball:AddForce(rotatedForce, UnityEngine.ForceMode.Impulse)

	if self.launchTor == 0 then
		local d = 1

		if self.launchTor >= 0 then
			d = -1
		end

		local tParam = Config.LaunchTorParam[math.abs(self.launchTor)]
		local localForward = self.sceneNode.transform:TransformDirection(Vector3.forward)

		ball:SetAngularVelocityDirect(localForward * tParam.rot * d)
		ball:SetSideForce(tParam.force * d, tParam.slip)
	end

	local forwardSpinSpeed = Config.forwardSpinSpeed or 15
	local localLeft = self.sceneNode.transform:TransformDirection(Vector3.left)
	local forwardSpin = localLeft * forwardSpinSpeed

	ball:SetAngularVelocity(forwardSpin)

	self.currentBall = ball

	return self.currentBall
end

BowlingBallLauncher.SelectBall = function(self, ballIndex)
	local currentOffset = self.launchOffset
	local currentPosRatio = self.lastCTimePos / self.CTime
	self.CurBallIndex = ballIndex
	self.launchForce = Config.minLaunchForce[self.CurBallIndex]
	self.CTime = Config.chargeTime[self.CurBallIndex]
	self.CTimePower = Config.chargeTimePower[self.CurBallIndex]
	self.lastCTimePos = currentPosRatio * self.CTime
	self.launchOffset = currentOffset
end

BowlingBallLauncher.ClearBall = function(self)
	if self.currentBall then
		self.currentBall:Destroy()

		self.currentBall = nil
	end

	self.ResetLastCTime(self)
	self.ResetLaunchParam(self)
	self.ResetLaunchObj(self, self.launchOffset, self.launchDir, false)
end

BowlingBallLauncher.GetSpawnPoint = function(self)
	return Vector3.New(self.launchOffset, self.spawnPosition.y, self.spawnPosition.z + self.spawnZOffset)
end

BowlingBallLauncher.GetLaunchOffset = function(self)
	return self.launchOffset
end

BowlingBallLauncher.GetBall = function(self)
	return self.currentBall
end

BowlingBallLauncher.GetSyncLaunchStateData = function(self)
	local result = {
		launchOffset = self.launchOffset,
		launchDir = self.launchDir,
		launchRotIndex = self.launchRotIndex,
		ballLightPointActive = self.objBallLightPoint and self.objBallLightPoint.activeSelf or false,
		arrowTipsActive = self.objArrowTips and self.objArrowTips.activeSelf or false,
		ballLightPointPos = self.objBallLightPoint and self.objBallLightPoint.transform.localPosition or Vector3.zero,
		arrowTipsPos = self.objArrowTips and self.objArrowTips.transform.localPosition or Vector3.zero,
		arrowTipsRot = self.objArrowTips and self.objArrowTips.transform.localRotation.eulerAngles or Vector3.zero
	}
	result.ballLightPointPos = {
		result.ballLightPointPos.x,
		result.ballLightPointPos.y,
		result.ballLightPointPos.z
	}
	result.arrowTipsPos = {
		result.arrowTipsPos.x,
		result.arrowTipsPos.y,
		result.arrowTipsPos.z
	}
	result.arrowTipsRot = {
		result.arrowTipsRot.x,
		result.arrowTipsRot.y,
		result.arrowTipsRot.z
	}

	return result
end

BowlingBallLauncher.Destroy = function(self)
	if self.launchHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_BOWLING_LAUNCH, self.launchHandler)

		self.launchHandler = nil
	end

	if self.onGameOverHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.BOWLING_GAME_OVER, self.onGameOverHandler)

		self.onGameOverHandler = nil
	end

	if self.currentBall then
		self.currentBall:Destroy()
	end

	if self.ballLightTween then
		self.ballLightTween:Kill()

		self.ballLightTween = nil
	end

	if self.objBallLightPoint then
		gBowlingGameManager:Destroy(self.objBallLightPoint)

		self.objBallLightPoint = nil
	end

	if self.objArrowTips then
		gBowlingGameManager:Destroy(self.objArrowTips)

		self.objArrowTips = nil
	end

	self.ballLightPrefab = nil
	self.arrowTipsPrefab = nil
	self.sceneNode = nil
	self.hasDestroy = true
end

BowlingBallLauncher.StartCharging = function(self)
	self.chargePower = 0

	return true
end

BowlingBallLauncher.UpdateChargingPowerAuto = function(self)
	if self.LaunchState == LaunchState.POWER then
		return 0
	end

	if not self.powerStartTime then
		self.powerStartTime = Time.time
	end

	local elapsedTime = Time.time - self.powerStartTime
	local cycleTime = self.CTimePower * 2
	local normalizedTime = elapsedTime % cycleTime / cycleTime
	local triangleWave = nil

	if normalizedTime < 0.5 then
		triangleWave = normalizedTime * 2
	else
		triangleWave = 2 - normalizedTime * 2
	end

	self.chargePower = triangleWave * 2
	local powerRatio = math.min(self.chargePower / 2, 1)
	self.launchForce = UnityEngine.Mathf.Lerp(self.minLaunchForce[self.CurBallIndex], self.maxLaunchForce[self.CurBallIndex], powerRatio)

	return powerRatio
end

BowlingBallLauncher.ResetLastCTime = function(self)
	self.lastCTimePos = self.CTime / 2
	self.lastCTimeDir = self.CTime / 2
end

BowlingBallLauncher.ResetLaunchParam = function(self)
	self.launchOffset = 0
	self.launchDir = 0
	self.launchTor = 0
	self.chargePower = 0
	self.powerStartTime = nil
	self.dirStartTime = nil
end

BowlingBallLauncher.ResetLaunchObj = function(self, launchOffset, launchDir, fromSync)
	if not fromSync and gBowlingGameManager:IsOnlineGame() and gBowlingGameManager.currentGame.gameMode:ShouldBroadcastClientInfo() then
		gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.ResetLaunchObj)
	end

	if self.objBallLightPoint then
		self.objBallLightPoint.transform.localPosition = Vector3.New(launchOffset, self.objBallLightPoint.transform.localPosition.y, self.objBallLightPoint.transform.localPosition.z)

		if not fromSync then
			self.objBallLightPoint:SetActive(false)
		end
	end

	if self.objArrowTips then
		self.objArrowTips.transform.localPosition = Vector3.New(launchOffset, self.objArrowTips.transform.localPosition.y, self.objArrowTips.transform.localPosition.z)
	end

	if self.objArrowTips then
		self.objArrowTips.transform.localRotation = Quaternion.Euler(0, launchDir, 0)
	end
end

BowlingBallLauncher.UpdateChargingPos = function(self, IsRight)
	if IsRight then
		self.lastCTimePos = self.lastCTimePos + Time.deltaTime
	else
		self.lastCTimePos = self.lastCTimePos - Time.deltaTime
	end

	self.lastCTimePos = math.min(self.lastCTimePos, self.CTime)
	self.lastCTimePos = math.max(self.lastCTimePos, 0)
	local posRatio = math.min(self.lastCTimePos / self.CTime, 1)
	self.launchOffset = UnityEngine.Mathf.Lerp(self.minLaunchOffset, self.maxLaunchOffset, posRatio)

	if self.objBallLightPoint then
		self.objBallLightPoint:SetActive(true)
		self.leftArrow.gameObject:SetActive(posRatio == 0)
		self.rightArrow.gameObject:SetActive(posRatio == 1)

		self.objBallLightPoint.transform.localPosition = Vector3.New(self.launchOffset, self.objBallLightPoint.transform.localPosition.y, self.objBallLightPoint.transform.localPosition.z)
	end

	if self.objArrowTips then
		self.objArrowTips.transform.localPosition = Vector3.New(self.launchOffset, self.objArrowTips.transform.localPosition.y, self.objArrowTips.transform.localPosition.z)
	end

	return posRatio
end

BowlingBallLauncher.SetChargingPos = function(self, launchOffset, posRatio)
	self.launchOffset = launchOffset

	if self.objBallLightPoint then
		self.objBallLightPoint:SetActive(true)
		self.leftArrow.gameObject:SetActive(posRatio == 0)
		self.rightArrow.gameObject:SetActive(posRatio == 1)

		self.objBallLightPoint.transform.localPosition = Vector3.New(self.launchOffset, self.objBallLightPoint.transform.localPosition.y, self.objBallLightPoint.transform.localPosition.z)
	end

	if self.objArrowTips then
		self.objArrowTips.transform.localPosition = Vector3.New(self.launchOffset, self.objArrowTips.transform.localPosition.y, self.objArrowTips.transform.localPosition.z)
	end

	return posRatio
end

BowlingBallLauncher.UpdateChargingPosDOLocalMove = function(self, targetPoint, tDuration)
	self.launchOffset = targetPoint

	if self.objBallLightPoint and gClientUtils.NotNil(self.objBallLightPoint) and gClientUtils.NotNil(self.objBallLightPoint.transform) then
		local newPos = Vector3.New(self.launchOffset, self.objBallLightPoint.transform.localPosition.y, self.objBallLightPoint.transform.localPosition.z)

		if self.ballLightTween then
			self.ballLightTween:Kill()
		end

		self.ballLightTween = self.objBallLightPoint.transform:DOLocalMove(newPos, tDuration)
	end

	if self.objArrowTips and gClientUtils.NotNil(self.objArrowTips) and gClientUtils.NotNil(self.objArrowTips.transform) then
		self.objArrowTips.transform.localPosition = Vector3.New(self.launchOffset, self.objArrowTips.transform.localPosition.y, self.objArrowTips.transform.localPosition.z)
	end
end

BowlingBallLauncher.UpdateRotIndex = function(self, RotIndex)
	self.launchRotIndex = Mathf.Clamp(RotIndex, -5, 5)
	local ratio = (self.launchRotIndex + 5) / 10
	self.launchTor = UnityEngine.Mathf.Lerp(self.minLaunchTor, self.maxLaunchTor, ratio)

	return ratio
end

BowlingBallLauncher.GetDirCompensationByOffset = function(self, launchOffset)
	launchOffset = launchOffset or 0

	if launchOffset ~= 0 then
		return 0
	end

	local maxOffset = math.abs(self.minLaunchOffset - self.maxLaunchOffset) / 2

	if maxOffset < 1e-06 then
		return 0
	end

	local offsetRatio = launchOffset / maxOffset

	return offsetRatio * (self.dirCompensationFactor or 0)
end

BowlingBallLauncher.GetLaunchDirRangeByOffset = function(self, launchOffset)
	local compensation = self.GetDirCompensationByOffset(self, launchOffset)

	return self.minLaunchDir + compensation, self.maxLaunchDir + compensation
end

BowlingBallLauncher.GetBowlingProficiency = function(self)
	if self.game and self.game.gameMode and self.game.gameMode:IsAiControlledTurn() then
		return 0
	end

	local tid = gBattleSpiritMgr.currentSpiritTemplateId

	if not tid or tid ~= 0 then
		return 0
	end

	local panelData = gUrbanAbilityManager:GetUrbanPanelData(tid)

	if not panelData or not panelData.Attrs then
		return 0
	end

	return panelData.Attrs[LTConfig.AttributeNameConfig.BowlingProficiency] or 0
end

BowlingBallLauncher.UpdateChargingDir = function(self, IsRight)
	if self.dirStartTime then
		local elapsedTime = Time.time - self.dirStartTime

		if gBowlingGameManager.enableProficiency then
			local proficiency = self.GetBowlingProficiency(self)
			local maxReduce = self.swingReduceMaxByWeight[self.CurBallIndex]
			local swingSpeedMultiplier = 1 - proficiency * maxReduce
			elapsedTime = (Time.time - self.dirStartTime) * swingSpeedMultiplier
		end

		local cycleTime = self.CTime * 2
		local normalizedTime = elapsedTime % cycleTime / cycleTime
		local triangleWave = nil

		if normalizedTime < 0.5 then
			triangleWave = normalizedTime * 2
		else
			triangleWave = 2 - normalizedTime * 2
		end

		self.lastCTimeDir = triangleWave * self.CTime
	else
		if IsRight then
			self.lastCTimeDir = self.lastCTimeDir + Time.deltaTime
		else
			self.lastCTimeDir = self.lastCTimeDir - Time.deltaTime
		end

		self.lastCTimeDir = math.min(self.lastCTimeDir, self.CTime)
		self.lastCTimeDir = math.max(self.lastCTimeDir, 0)
	end

	local dirRatio = math.min(self.lastCTimeDir / self.CTime, 1)
	self.launchDir = UnityEngine.Mathf.Lerp(self.minLaunchDir, self.maxLaunchDir, dirRatio)
	self.launchDir = self.launchDir + self.GetDirCompensationByOffset(self, self.launchOffset)

	if self.objArrowTips ~= nil then
		self.CreateArrowTips(self)
	end

	if self.objArrowTips then
		self.objArrowTips:SetActive(true)

		self.objArrowTips.transform.localRotation = Quaternion.Euler(0, self.launchDir, 0)
	end

	return dirRatio
end

BowlingBallLauncher.UpdateChargingDirAuto = function(self)
	if self.LaunchState == LaunchState.DIR then
		return
	end

	if self.dirStartTime then
		self.UpdateChargingDir(self, true)
	else
		self.UpdateChargingDir(self, self.IsAutoDirRight)

		local minDir, maxDir = self.GetLaunchDirRangeByOffset(self, self.launchOffset)

		if self.launchDir > minDir or maxDir < self.launchDir then
			self.IsAutoDirRight = not self.IsAutoDirRight
		end
	end
end

BowlingBallLauncher.BeginAnim = function(self)
	self.LaunchState = LaunchState.ANIM

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState
	})
end

BowlingBallLauncher.BeginPos = function(self, ballIndex)
	self.LaunchState = LaunchState.POS

	self:CreateBallLightPoint()
	self.objBallLightPoint:SetActive(true)
	self.leftArrow.gameObject:SetActive(true)
	self.rightArrow.gameObject:SetActive(true)
	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState,
		ballIndex = ballIndex
	})
end

BowlingBallLauncher.CreateAnimBall = function(self)
	local go, sceneItemId = gBowlingGameManager:Rent(self.CurBallIndex, self.sceneNode.transform)

	if gClientUtils.NotNil(go) then
		return go, sceneItemId
	end

	for i = gBowlingGameManager.sceneItemType.Ball, gBowlingGameManager.sceneItemType.BallMax do
		go, sceneItemId = gBowlingGameManager:Rent(i, self.sceneNode.transform)

		if gClientUtils.NotNil(go) then
			return go, sceneItemId
		end
	end

	return nil
end

BowlingBallLauncher.PeekAnimBallId = function(self)
	local mgr = gBowlingGameManager

	if mgr.gameInstance ~= nil or mgr.gameInstance.sceneItemBallList ~= nil then
		return nil
	end

	local ballList = mgr.gameInstance.sceneItemBallList
	local item = ballList[self.CurBallIndex]

	if item == nil and gClientUtils.NotNil(item.go) then
		return item.id
	end

	for i = mgr.sceneItemType.Ball, mgr.sceneItemType.BallMax do
		item = ballList[i]

		if item == nil and gClientUtils.NotNil(item.go) then
			return item.id
		end
	end

	return nil
end

BowlingBallLauncher.OnSyncLaunchState = function(self, launchStateData)
	if not launchStateData then
		return
	end

	self.CreateBallLightPoint(self)

	if gClientUtils.IsNil(self.objArrowTips) then
		self.CreateArrowTips(self)
	end

	launchStateData.ballLightPointPos = Vector3.New(unpack(launchStateData.ballLightPointPos))
	launchStateData.arrowTipsPos = Vector3.New(unpack(launchStateData.arrowTipsPos))
	launchStateData.arrowTipsRot = Vector3.New(unpack(launchStateData.arrowTipsRot))

	if launchStateData.launchOffset == nil then
		self.launchOffset = launchStateData.launchOffset
	end

	if launchStateData.launchDir == nil then
		self.launchDir = launchStateData.launchDir
	end

	if launchStateData.launchRotIndex == nil then
		self.launchRotIndex = launchStateData.launchRotIndex

		self.UpdateRotIndex(self, self.launchRotIndex)
	end

	if launchStateData.ballLightPointActive == nil and self.objBallLightPoint then
		self.objBallLightPoint:SetActive(launchStateData.ballLightPointActive)
	end

	if launchStateData.arrowTipsActive == nil and self.objArrowTips then
		self.objArrowTips:SetActive(launchStateData.arrowTipsActive)
	end

	if launchStateData.ballLightPointPos == nil and self.objBallLightPoint then
		self.objBallLightPoint.transform.localPosition = launchStateData.ballLightPointPos
	end

	if launchStateData.arrowTipsPos == nil and self.objArrowTips then
		self.objArrowTips.transform.localPosition = launchStateData.arrowTipsPos
	end

	if launchStateData.arrowTipsRot == nil and self.objArrowTips then
		self.objArrowTips.transform.localRotation = Quaternion.Euler(launchStateData.arrowTipsRot)
	end
end
