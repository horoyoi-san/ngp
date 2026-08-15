local static_props = {}
gBowlingCharacter = DefClass("BowlingCharacter", gBowlingCharacter, nil, static_props)
local CHARACTER_STATUS = {
	MOVE = 4,
	END = 6,
	RECEIVE_BALL = 2,
	SHOOT = 5,
	IDLE = 1,
	READY = 3
}
static_props.CHARACTER_STATUS = CHARACTER_STATUS
local GAME_STATUS = {
	PAUSE = 3,
	END = 4,
	START = 2,
	NONE = 1
}
static_props.GAME_STATUS = GAME_STATUS
local UnitModelManager = LX6.Units.UnitModelManager
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig")
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local TimelineScene = BowlingConstants.TimelineScene
local BowlingCharacter = gBowlingCharacter

function BowlingCharacter:ctor(args)
	self:InitData(args)
	self:InitCharacter()
end

function BowlingCharacter:InitCharacter()
	self.CharModelType = gClientUtils.ModelType.MiddleMale

	local function onLoad(baseUnit, _)
		if self.hasDestroy then
			if baseUnit then
				baseUnit:DestroyUnit(false)
			end

			return
		end

		baseUnit.PlayerObj.transform:SetParent(self.sceneNode.transform)
		baseUnit:SetDynamicBone(true, true)
		UnitModelManager.SetShadow(baseUnit, true)

		self.baseUnit = baseUnit
		self.transform = baseUnit.ModelSlot.transform

		self:InitNodes()

		local animatorTrackName = gBowlingGameManager.currentGame.timelineManager:GetPlayerAnimatorTrackName(self.playerIndex, self.CharModelType)
		local activationTrackName = gBowlingGameManager.currentGame.timelineManager:GetPlayerActivationTrackName(self.playerIndex)
		local tlplayerPath = gBowlingGameManager.currentGame.timelineManager:GetPlayerNodeTimelinePath(self.playerIndex)

		gBowlingGameManager.currentGame.timelineManager:ReplaceCharacterAndBindAnimator(self.baseUnit.ModelSlot.gameObject, tlplayerPath, self.animator, animatorTrackName, activationTrackName)
		self:ResetTransform(0, 0)
		UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(baseUnit, false)
	end

	if self.npcUnit then
		onLoad(self.npcUnit)
	elseif self.agentId and ulong.Greater(self.agentId, 0) then
		self.waitAgentInitCo = coroutine.start(function ()
			local unit = gCS.SceneDataMgr.GetUnit(self.agentId)

			if unit == nil then
				print_error("BowlingCharacter:InitCharacter() unit is nil, agentId=", self.agentId)

				return
			end

			while not unit.CanUseRes do
				coroutine.step()
			end

			onLoad(unit)
		end)
	elseif not gBowlingGameManager:IsOnlineGame() then
		local agentId = self:GetAgentId()
		local sexType = gPlayerManager.infoLogin.bindData.sexType

		gCS.UnitsManager:GetDialogModelByAgentId(onLoad, sexType, agentId, false, true, true, gBattleSpiritMgr.currentSpiritTemplateId)
	else
		local gameMode = gBowlingGameManager.currentGame.gameMode
		local player = gameMode.players[self.playerIndex]
		local playerId = player.playerId
		local success, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(playerId, ulong.zero)
		local participantAgentUnit = gCS.SceneDataMgr.GetUnit(unitId)

		if not success or participantAgentUnit == nil then
			print_error("找不到 unit", playerId)

			return
		end

		local isLocalPlayer = not gBowlingGameManager:IsOnlineGame() or self.playerIndex == gBowlingGameManager.currentGame.gameMode.localPlayerIndex

		if isLocalPlayer then
			local agentId = self:GetAgentId()
			local sexType = gPlayerManager.infoLogin.bindData.sexType

			gCS.UnitsManager:GetDialogModelByAgentId(onLoad, sexType, agentId, false, true, true, gBattleSpiritMgr.currentSpiritTemplateId)
		else
			local agentTemplateId = participantAgentUnit.TemplateId

			gCS.UnitsManager:GetDialogModelByAgentId(onLoad, UX.Game.SexType.UnKnow, agentTemplateId, false, true, true, participantAgentUnit.ClientData.cardId, participantAgentUnit)
		end

		self.participantAgentUnit = participantAgentUnit

		gCS.BaseUnitUtils.SetUnitLogicalHidden(participantAgentUnit, true, LX6.Units.LogicalHiddenCause.GamePlay)
	end
end

function BowlingCharacter:InitNodes()
	local playerNode = self.transform:Find("player")
	self.animator = playerNode:GetOrAddComponent(typeof(UnityEngine.Animator))
	local rootMotionController = playerNode:GetComponent(typeof(LX6.Action.RootMotionController))

	if rootMotionController then
		gBowlingGameManager:DestroyImmediate(rootMotionController)
	end

	self.handPoint = self.baseUnit.ModelSlot.handr
	self.animationEvents = playerNode.gameObject:GetOrAddComponent(typeof(L18.MiniGame.AnimationEventLuaReceiver))
end

function BowlingCharacter:InitData(args)
	self.sceneNode = args.sceneNode
	self.playerPoint = args.playerPoint
	self.pinPoint = args.pinPoint
	self.virtualCamera = args.virtualCamera
	self.npcId = args.npcId
	self.agentId = args.agentId
	self.npcUnit = args.npcUnit
	self.playerIndex = args.playerIndex
	self.gameStatus = BowlingCharacter.GAME_STATUS.NONE
	self.characterStatus = BowlingCharacter.CHARACTER_STATUS.IDLE
	self.currentBallGo = nil
end

function BowlingCharacter:PlayAnimationByTriggerName(triggerName)
	if gClientUtils.NotNil(self.animator) then
		self.animator:SetTrigger(triggerName)
	end
end

function BowlingCharacter:Destroy()
	self:SetCharacterUpdateMode(false)

	if self.participantAgentUnit then
		gCS.BaseUnitUtils.SetUnitLogicalHidden(self.participantAgentUnit, false, LX6.Units.LogicalHiddenCause.GamePlay)
	end

	if self.virtualCamera then
		if gClientUtils.NotNil(self.virtualCamera.transform) then
			self.virtualCamera.transform:DOKill(true)
		end

		self.virtualCamera = nil
	end

	self:ClearCoroutines()

	self.transform = nil
	self.animator = nil
	self.handPoint = nil
	self.animationEvents = gBowlingGameManager:Destroy(self.animationEvents)
	self.rootMotion = gBowlingGameManager:Destroy(self.rootMotion)

	if self.baseUnit and not self.baseUnit.IsDestroyed then
		self.baseUnit = self.baseUnit:DestroyUnit(true)
	end

	if gClientUtils.NotNil(self.gameObject) then
		gBowlingGameManager:Destroy(self.gameObject)
	end

	if self.currentBallGo and self.currentBallGo.transform then
		self.currentBallGo.transform:DOKill(false)
	end

	self:TryReturnCurrentBallGo()

	self.hasDestroy = true
end

function BowlingCharacter:ClearCoroutines()
	self.bowlingAnimation = coroutine.stop(self.bowlingAnimation)
	self.waitAgentInitCo = coroutine.stop(self.waitAgentInitCo)
end

function BowlingCharacter:GameOver()
	self.gameStatus = BowlingCharacter.GAME_STATUS.END

	self:ClearCoroutines()
end

function BowlingCharacter:IsGameOver()
	return self.gameStatus == BowlingCharacter.GAME_STATUS.END
end

function BowlingCharacter:Reset()
	self.characterStatus = BowlingCharacter.CHARACTER_STATUS.IDLE
	self.gameStatus = BowlingCharacter.GAME_STATUS.NONE

	if self.rootMotion then
		self.rootMotion.enabled = false
	end
end

function BowlingCharacter:Pause()
	if self.gameStatus == BowlingCharacter.GAME_STATUS.START then
		self.gameStatus = BowlingCharacter.GAME_STATUS.PAUSE
	end
end

function BowlingCharacter:Resume()
	if self.gameStatus == BowlingCharacter.GAME_STATUS.PAUSE then
		self.gameStatus = BowlingCharacter.GAME_STATUS.START
	end
end

function BowlingCharacter:GetAgentId()
	return gCS.MyPlayerManager.PlayerUnit.TemplateId
end

function BowlingCharacter:SetActive(active)
	if self.baseUnit and self.baseUnit.ModelSlot then
		self.baseUnit.ModelSlot.gameObject:SetActive(active)
	end
end

function BowlingCharacter:ResetTransform(offsetX, offsetZ)
	self.transform.localPosition = Vector3.zero
	self.transform.localRotation = Quaternion.identity
end

function BowlingCharacter:ExecuteReset()
	self:PlayAnimationByTriggerName("Reset")
end

function BowlingCharacter:BallDoMoveByEvent(spawnPoint)
	if self.hasDestroy or gClientUtils.IsNil(self.transform) or gClientUtils.IsNil(self.sceneNode) then
		return
	end

	self.currentBallGo.transform:DOKill(false)
	self.currentBallGo.transform:SetParent(self.sceneNode.transform)

	local tSpin = Config.Launcher.forwardSpinTime or 0.15
	local forwardSpinSpeed = Config.Launcher.forwardSpinSpeed or 15
	local rotationAngle = forwardSpinSpeed * tSpin * 360 / (2 * math.pi)

	self.currentBallGo.transform:DOLocalMove(spawnPoint, tSpin):SetEase(DG.Tweening.Ease.OutQuad):OnComplete(function ()
		if self.hasDestroy then
			return
		end

		if gClientUtils.NotNil(self.currentBallGo) then
			gBowlingGameManager.currentGame:OnEventAnimLaunchEnd(self.currentBall)
			gBowlingGameManager.currentGame.timelineManager:ControlCameraPriority(false)
		end
	end)
	self.currentBallGo.transform:DOLocalRotate(Vector3(rotationAngle, 0, 0), tSpin, DG.Tweening.RotateMode.LocalAxisAdd):SetEase(DG.Tweening.Ease.Linear)
end

function BowlingCharacter:ExecuteLaunchTimeline(offsetX, fromSync)
	self:ExecuteTimeLine(TimelineScene.LAUNCH, nil, Vector3(offsetX, 0, 0))

	if not fromSync then
		self:SetParentBallTimeline()
	end
end

function BowlingCharacter:ExecuteTimeLine(index, callBack, offset)
	if self.hasDestroy then
		return
	end

	gBowlingGameManager.currentGame.timelineManager:ResetTimelinePosition()
	self:SetAllCharacterUpdateMode(true)

	local function wrappedCallback()
		self:SetAllCharacterUpdateMode(false)

		if callBack then
			callBack()
		end
	end

	gBowlingGameManager.currentGame.timelineManager:PlayClip(index, wrappedCallback, offset, self.playerIndex, self.CharModelType)
end

function BowlingCharacter:SetParentBallTimeline()
	local handr = self.handPoint

	if gClientUtils.NotNil(handr) then
		self:CreateShowBall()

		if gClientUtils.NotNil(self.currentBallGo) then
			self.currentBallGo.transform:SetParent(handr)

			self.currentBallGo.transform.localPosition = Vector3.zero

			self.currentBall.sceneItemHold:SyncPositionAndRotation(handr.position, handr.rotation)
		else
			print_error("[BowlingCharacter] SetParentBallTimeline: self.currentBallGo is nil")
		end
	end
end

function BowlingCharacter:TryReturnCurrentBallGo()
	if self.currentBall then
		self.currentBall:Destroy()
	end
end

function BowlingCharacter:CreateShowBall()
	self:TryReturnCurrentBallGo()

	local ballLauncher = gBowlingGameManager.currentGame.ballLauncher
	self.ballType = ballLauncher.CurBallIndex
	local currentBallGo, sceneItemId = ballLauncher:CreateAnimBall()

	if gClientUtils.IsNil(currentBallGo) then
		return
	end

	self.currentBallGo = currentBallGo
	local args = {
		gameObject = currentBallGo,
		ballType = self.ballType,
		sceneItemId = sceneItemId
	}
	self.currentBall = gBowlingBall.new(args)

	self.currentBall:EnablePhysics(false)
end

function BowlingCharacter:SetCharacterUpdateMode(forceUpdate)
	local transform = ((self.baseUnit or {}).ModelSlot or {}).transform

	if gClientUtils.IsNil(transform) then
		return
	end

	local renderers = transform:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))

	for i = 0, renderers.Length - 1 do
		local renderer = renderers[i]
		renderer.updateWhenOffscreen = forceUpdate
	end
end

function BowlingCharacter:SetAllCharacterUpdateMode(forceUpdate)
	for k, v in ipairs(gBowlingGameManager.currentGame.characters) do
		v:SetCharacterUpdateMode(forceUpdate)
	end
end
