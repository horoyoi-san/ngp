gBowlingBallLauncher = DefClass("BowlingBallLauncher", gBowlingBallLauncher)
local BowlingBallLauncher = gBowlingBallLauncher
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig").Launcher
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local LaunchState = BowlingConstants.LaunchState
local GameState = BowlingConstants.GameState
local BowlingMessageManager = require("LX6/MiniGame/BowlingGame/BowlingMessageManager")

function BowlingBallLauncher:ctor()
	self:InitData()

	function self.gameLaunchHandler(param)
		local character = gBowlingGameManager.currentGame:GetCurrentCharacter()

		if (not gBowlingGameManager:IsOnlineGame() or gBowlingGameManager.currentGame.gameMode:IsLocalPlayerTurn()) and character then
			character:BallDoMoveByEvent(self:GetSpawnPoint())
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_BOWLING_LAUNCH, self.gameLaunchHandler)
end

function BowlingBallLauncher:InitData()
	self.LaunchState = LaunchState.ANIM
	self.CurBallIndex = math.ceil(#Config.prefabPaths.balls / 2)
	self.launchForward = -Vector3.forward
	self.minLaunchForce = Config.minLaunchForce
	self.maxLaunchForce = Config.maxLaunchForce
	self.launchForce = Config.minLaunchForce[self.CurBallIndex]
	self.minLaunchOffset = Config.minLaunchOffset
	self.maxLaunchOffset = Config.maxLaunchOffset
	self.launchOffset = 0
	self.minLaunchDir = Config.minLaunchDir
	self.maxLaunchDir = Config.maxLaunchDir
	self.launchDir = 0
	self.IsAutoDirRight = true
	self.minLaunchTor = Config.minLaunchTor
	self.maxLaunchTor = Config.maxLaunchTor
	self.launchTor = 0
	self.launchRotIndex = 0
	self.spawnZOffset = Config.spawnZOffset or 0
	self.isCharging = false
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
	self.isNPC = false
end

function BowlingBallLauncher:SetNPCMode(isNPC)
	self.isNPC = isNPC
end

function BowlingBallLauncher:SetSceneNode(node)
	if gClientUtils.NotNil(node) then
		self.sceneNode = node
		local BallSpawnPoint = self.sceneNode.transform:Find("PivotNode/BallSpawnPoint")

		self:SetSpawnPoint(BallSpawnPoint.localPosition)
	end
end

function BowlingBallLauncher:SetSpawnPoint(point)
	self.spawnPosition = point
end

function BowlingBallLauncher:LoadBallLightPoint()
	local PrefabPath = Config.prefabPaths.ballLight

	gResourceManager:LoadAssetWithCallBack(PrefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		self.ballLightPrefab = loadOp.asset
	end)
end

function BowlingBallLauncher:LoadArrowTips()
	local PrefabPath = Config.prefabPaths.arrowTips

	gResourceManager:LoadAssetWithCallBack(PrefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		self.arrowTipsPrefab = loadOp.asset
	end)
end

function BowlingBallLauncher:GetLauncherState()
	return self.LaunchState
end

function BowlingBallLauncher:LaunchKeyUp()
	if self.LaunchState == LaunchState.POS then
		self.LaunchState = LaunchState.DIR
		self.dirStartTime = Time.time

		if self.objBallLightPoint then
			self.objBallLightPoint:SetActive(false)
		end

		if self.objArrowTips == nil then
			self:CreateArrowTips()
		end

		if self.objArrowTips then
			self.objArrowTips:SetActive(true)
		end
	elseif self.LaunchState == LaunchState.DIR then
		self.LaunchState = LaunchState.POWER
		self.powerStartTime = Time.time
		self.dirStartTime = nil
	elseif self.LaunchState == LaunchState.POWER then
		self.LaunchState = LaunchState.ROT
		self.powerStartTime = nil

		BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
			state = self.LaunchState
		})

		return true
	end

	BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState
	})

	return false
end

function BowlingBallLauncher:CreateBallLightPoint()
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

function BowlingBallLauncher:CreateArrowTips()
	if not self.arrowTipsPrefab then
		return
	end

	local pos = Vector3.New(self.launchOffset, 0.01, self.spawnPosition.z - 0.05)
	local ArrowTipsGo = UnityEngine.GameObject.Instantiate(self.arrowTipsPrefab, self.sceneNode.transform)
	self.objArrowTips = ArrowTipsGo
	self.objArrowTips.transform.localPosition = pos
	self.objArrowTips.transform.localRotation = Quaternion.Euler(0, 0, 0)
end

function BowlingBallLauncher:NPCAutoLaunch(params)
	if not self.isNPC then
		return
	end

	local tempPos = params.offset or math.random(self.minLaunchOffset * 100, self.maxLaunchOffset * 100) / 100
	local tempPowerRatio = math.random(0, 100)
	local tempDir = params.dir or math.random(self.minLaunchDir * 100, self.maxLaunchDir * 100) / 100
	self.launchTor = params.rot or math.random(self.minLaunchTor, self.maxLaunchTor)
	self.LaunchState = LaunchState.POS

	self:BeginPos()

	self.coroutineNPCLaunch = coroutine.start(function ()
		local intermediatePoints = {}
		local numPoints = math.random(1, 4)

		for i = 1, numPoints do
			local tPos = math.random(self.minLaunchOffset * 100, self.maxLaunchOffset * 100) / 100

			table.insert(intermediatePoints, tPos)
		end

		table.insert(intermediatePoints, tempPos)

		for _, targetPoint in ipairs(intermediatePoints) do
			local startTime = Time.time
			local adjustmentTime = math.random(10, 100) / 100

			while self.LaunchState == LaunchState.POS do
				if adjustmentTime < Time.time - startTime then
					local diff = math.abs(targetPoint - self.launchOffset)
					local aDis = math.abs(self.minLaunchOffset - self.maxLaunchOffset)
					local posRatio = math.min(diff / aDis, 1)
					local td = UnityEngine.Mathf.Lerp(0, self.CTime, posRatio)

					self:UpdateChargingPosDOLocalMove(targetPoint, td)
					coroutine.wait(td)

					break
				else
					coroutine.wait(0.1)
				end
			end
		end

		coroutine.wait(1)
		self:LaunchKeyUp()

		while self.LaunchState == LaunchState.DIR do
			self:UpdateChargingDirAuto()

			if math.abs(tempDir - self.launchDir) < 0.5 then
				self:LaunchKeyUp()

				break
			end

			coroutine.wait(0.1)
		end

		local startTime = Time.time
		local waitTime = math.random(1, 2)

		while self.LaunchState == LaunchState.POWER do
			local powerRatio = self:UpdateChargingPowerAuto()

			if waitTime < Time.time - startTime and math.abs(powerRatio - tempPowerRatio / 100) < 0.1 then
				gBowlingGameManager.currentGame.gameState = GameState.THROWING

				self:LaunchKeyUp()

				break
			end

			coroutine.wait(0.1)
		end

		gBowlingGameManager.currentGame:OnEventLaunch()

		local rotCount = math.random(0, 2)

		if rotCount > 0 then
			for i = 1, rotCount do
				local isRight = 0

				if self.launchDir < 0 then
					isRight = 1
				end

				BowlingMessageManager:SendMessage(gEventConstants.BOWLING_NPC_ROT, {
					isRight = isRight
				})
				coroutine.wait(0.3)
			end
		end
	end)
end

function BowlingBallLauncher:LaunchBall(ball)
	self.LaunchState = LaunchState.ROLLING

	BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState
	})

	if self.objArrowTips then
		self.objArrowTips:SetActive(false)
	end

	if self.objBallLightPoint then
		self.objBallLightPoint:SetActive(false)
	end

	local pos = self:GetSpawnPoint()
	local ballGo = ball.gameObject

	if gClientUtils.IsNil(ballGo) then
		print_error("BowlingBallLauncher:LaunchBall() ballGo is nil")

		return
	end

	local ballConfig = Config.prefabPaths.balls[self.CurBallIndex]

	ball:EnablePhysics(true, ballConfig and ballConfig.mass)
	gBowlingGameManager.currentGame.pinSetter:WakeupAllPins()

	ballGo.transform.localPosition = pos
	ballGo.transform.localRotation = Quaternion.Euler(0, 0, 0)
	local force = self.launchForward * self.launchForce
	local rotation = Quaternion.Euler(0, self.launchDir, 0)
	local rotatedForce = rotation * force

	ball:AddForce(rotatedForce, UnityEngine.ForceMode.Impulse)

	if self.launchTor ~= 0 then
		local d = 1

		if self.launchTor < 0 then
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

function BowlingBallLauncher:SelectBall(ballIndex)
	local currentOffset = self.launchOffset
	local currentPosRatio = self.lastCTimePos / self.CTime
	self.CurBallIndex = ballIndex
	self.launchForce = Config.minLaunchForce[self.CurBallIndex]
	self.CTime = Config.chargeTime[self.CurBallIndex]
	self.CTimePower = Config.chargeTimePower[self.CurBallIndex]
	self.lastCTimePos = currentPosRatio * self.CTime
	self.launchOffset = currentOffset
end

function BowlingBallLauncher:ClearBall()
	if self.currentBall then
		self.currentBall:Destroy()

		self.currentBall = nil
	end

	self:ResetLastCTime()
	self:ResetLaunchParam()
	self:ResetLaunchObj(self.launchOffset, self.launchDir, false)
end

function BowlingBallLauncher:GetSpawnPoint()
	return Vector3.New(self.launchOffset, self.spawnPosition.y, self.spawnPosition.z + self.spawnZOffset)
end

function BowlingBallLauncher:GetLaunchOffset()
	return self.launchOffset
end

function BowlingBallLauncher:GetLaunchDir()
	return self.launchDir
end

function BowlingBallLauncher:GetBall()
	return self.currentBall
end

function BowlingBallLauncher:GetBallIndex()
	return self.CurBallIndex
end

function BowlingBallLauncher:GetSyncLaunchStateData()
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

function BowlingBallLauncher:Destroy()
	self.coroutineNPCLaunch = coroutine.stop(self.coroutineNPCLaunch)

	gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_BOWLING_LAUNCH, self.gameLaunchHandler)

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

function BowlingBallLauncher:StartCharging()
	self.isCharging = true
	self.chargePower = 0

	return true
end

function BowlingBallLauncher:UpdateChargingPowerAuto()
	if self.LaunchState ~= LaunchState.POWER then
		return 0
	end

	if not self.powerStartTime then
		self.powerStartTime = Time.time
	end

	local elapsedTime = Time.time - self.powerStartTime
	local cycleTime = self.CTimePower * 2
	local normalizedTime = elapsedTime % cycleTime / cycleTime
	local triangleWave = nil

	if normalizedTime <= 0.5 then
		triangleWave = normalizedTime * 2
	else
		triangleWave = 2 - normalizedTime * 2
	end

	self.chargePower = triangleWave * 2
	local powerRatio = math.min(self.chargePower / 2, 1)
	self.launchForce = UnityEngine.Mathf.Lerp(self.minLaunchForce[self.CurBallIndex], self.maxLaunchForce[self.CurBallIndex], powerRatio)

	return powerRatio
end

function BowlingBallLauncher:ResetLastCTime()
	self.lastCTimeRot = self.CTime / 2
	self.lastCTimePos = self.CTime / 2
	self.lastCTimeDir = self.CTime / 2
end

function BowlingBallLauncher:ResetLaunchParam()
	self.launchOffset = 0
	self.launchDir = 0
	self.launchTor = 0
	self.chargePower = 0
	self.powerStartTime = nil
	self.dirStartTime = nil
end

function BowlingBallLauncher:ResetLaunchObj(launchOffset, launchDir, fromSync)
	if not fromSync and gBowlingGameManager:IsOnlineGame() then
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

function BowlingBallLauncher:UpdateChargingPos(IsRight)
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
		self.leftArrow.gameObject:SetActive(posRatio ~= 0)
		self.rightArrow.gameObject:SetActive(posRatio ~= 1)

		self.objBallLightPoint.transform.localPosition = Vector3.New(self.launchOffset, self.objBallLightPoint.transform.localPosition.y, self.objBallLightPoint.transform.localPosition.z)
	end

	if self.objArrowTips then
		self.objArrowTips.transform.localPosition = Vector3.New(self.launchOffset, self.objArrowTips.transform.localPosition.y, self.objArrowTips.transform.localPosition.z)
	end

	return posRatio
end

function BowlingBallLauncher:SetChargingPos(launchOffset, posRatio)
	self.launchOffset = launchOffset

	if self.objBallLightPoint then
		self.objBallLightPoint:SetActive(true)
		self.leftArrow.gameObject:SetActive(posRatio ~= 0)
		self.rightArrow.gameObject:SetActive(posRatio ~= 1)

		self.objBallLightPoint.transform.localPosition = Vector3.New(self.launchOffset, self.objBallLightPoint.transform.localPosition.y, self.objBallLightPoint.transform.localPosition.z)
	end

	if self.objArrowTips then
		self.objArrowTips.transform.localPosition = Vector3.New(self.launchOffset, self.objArrowTips.transform.localPosition.y, self.objArrowTips.transform.localPosition.z)
	end

	return posRatio
end

function BowlingBallLauncher:UpdateChargingPosDOLocalMove(targetPoint, tDuration)
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

function BowlingBallLauncher:UpdateRotIndex(RotIndex)
	self.launchRotIndex = math.max(-5, math.min(5, RotIndex))
	local ratio = (self.launchRotIndex + 5) / 10
	self.launchTor = UnityEngine.Mathf.Lerp(self.minLaunchTor, self.maxLaunchTor, ratio)

	return ratio
end

function BowlingBallLauncher:UpdateChargingDir(IsRight)
	if self.dirStartTime then
		local elapsedTime = Time.time - self.dirStartTime
		local cycleTime = self.CTime * 2
		local normalizedTime = elapsedTime % cycleTime / cycleTime
		local triangleWave = nil

		if normalizedTime <= 0.5 then
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
	local positionCompensation = 0

	if self.launchOffset ~= 0 then
		local maxOffset = math.abs(self.minLaunchOffset - self.maxLaunchOffset) / 2
		local offsetRatio = self.launchOffset / maxOffset
		local compensationFactor = 2
		positionCompensation = offsetRatio * compensationFactor
	end

	self.launchDir = self.launchDir + positionCompensation

	if self.objArrowTips == nil then
		self:CreateArrowTips()
	end

	if self.objArrowTips then
		self.objArrowTips:SetActive(true)

		self.objArrowTips.transform.localRotation = Quaternion.Euler(0, self.launchDir, 0)
	end

	return dirRatio
end

function BowlingBallLauncher:UpdateChargingDirAuto()
	if self.LaunchState ~= LaunchState.DIR then
		return
	end

	if self.dirStartTime then
		self:UpdateChargingDir(true)
	else
		self:UpdateChargingDir(self.IsAutoDirRight)

		if self.launchDir <= self.minLaunchDir or self.maxLaunchDir <= self.launchDir then
			self.IsAutoDirRight = not self.IsAutoDirRight
		end
	end
end

function BowlingBallLauncher:BeginAnim()
	self.LaunchState = LaunchState.ANIM

	BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState
	})
end

function BowlingBallLauncher:BeginPos(ballIndex)
	self.LaunchState = LaunchState.POS

	self:CreateBallLightPoint()
	self.objBallLightPoint:SetActive(true)
	self.leftArrow.gameObject:SetActive(true)
	self.rightArrow.gameObject:SetActive(true)
	BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_LANUCH_STATE, {
		state = self.LaunchState,
		ballIndex = ballIndex
	})
end

function BowlingBallLauncher:CreateAnimBall()
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

function BowlingBallLauncher:OnSyncLaunchState(launchStateData)
	if not launchStateData then
		return
	end

	self:CreateBallLightPoint()

	if gClientUtils.IsNil(self.objArrowTips) then
		self:CreateArrowTips()
	end

	launchStateData.ballLightPointPos = Vector3.New(unpack(launchStateData.ballLightPointPos))
	launchStateData.arrowTipsPos = Vector3.New(unpack(launchStateData.arrowTipsPos))
	launchStateData.arrowTipsRot = Vector3.New(unpack(launchStateData.arrowTipsRot))

	if launchStateData.launchOffset ~= nil then
		self.launchOffset = launchStateData.launchOffset
	end

	if launchStateData.launchDir ~= nil then
		self.launchDir = launchStateData.launchDir
	end

	if launchStateData.launchRotIndex ~= nil then
		self.launchRotIndex = launchStateData.launchRotIndex

		self:UpdateRotIndex(self.launchRotIndex)
	end

	if launchStateData.ballLightPointActive ~= nil and self.objBallLightPoint then
		self.objBallLightPoint:SetActive(launchStateData.ballLightPointActive)
	end

	if launchStateData.arrowTipsActive ~= nil and self.objArrowTips then
		self.objArrowTips:SetActive(launchStateData.arrowTipsActive)
	end

	if launchStateData.ballLightPointPos ~= nil and self.objBallLightPoint then
		self.objBallLightPoint.transform.localPosition = launchStateData.ballLightPointPos
	end

	if launchStateData.arrowTipsPos ~= nil and self.objArrowTips then
		self.objArrowTips.transform.localPosition = launchStateData.arrowTipsPos
	end

	if launchStateData.arrowTipsRot ~= nil and self.objArrowTips then
		self.objArrowTips.transform.localRotation = Quaternion.Euler(launchStateData.arrowTipsRot)
	end
end
