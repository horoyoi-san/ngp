-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingCharacter.lua
-- Decompiled from: 00648_BowlingCharacter.lua_83b6542d1c82.luajit

local static_props = {
	Create_Async = function (args)
		local obj = gBowlingCharacter.new(args)

		return obj
	end
}
gBowlingCharacter = DefClass("BowlingCharacter", gBowlingCharacter, nil, static_props)
local CHARACTER_STATUS = {
	["W\rK~"] = 4,
	["\\xabFB"] = 6,
	["]S\\x8fRe\\x84\\xd7xH[R`"] = 2,
	["~\\x86\\x8d\\x80\\x82"] = 5,
	["SQ~"] = 1,
	["\\x8b\\x83\\x8b\\x8f"] = 3
}
static_props.CHARACTER_STATUS = CHARACTER_STATUS
local GAME_STATUS = {
	["}\\x8f\\x97\\x9c\\x93"] = 3,
	["\\xabFB"] = 4,
	["~\\x9a\\x83\\x9d\\x82"] = 2,
	["T\rS~"] = 1
}
static_props.GAME_STATUS = GAME_STATUS
local UnitModelManager = LX6.Units.UnitModelManager
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig")
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local TimelineScene = BowlingConstants.TimelineScene
local BowlingCharacter = gBowlingCharacter

BowlingCharacter.ctor = function(self, args)
	self.InitData(self, args)
	self.InitCharacter_Async(self)
end

BowlingCharacter.InitCharacter_Async = function(self)
	self.CharModelType = gClientUtils.ModelType.MiddleMale

	if self.npcUnit then
		self.OnUnitLoad(self, self.npcUnit)
	else
		if ulong.Greater(self.serverAgentInstanceId or 0, 0) then
			local unitLoadToken = gWaitToken.Create()

			local CheckAiAgent = function()
				if self.hasDestroy then
					self:ClearAIAgentLoadListener()

					return true
				end

				local unit = gCS.SceneDataMgr.GetUnit(self.serverAgentInstanceId)

				if not gCS.LuaUtils.IsBaseUnitValid(unit) or not unit.CanUseRes then
					return false
				end

				self:ClearAIAgentLoadListener()

				local gameMode = (self.game or {}).gameMode

				if gameMode then
					local linkInfo = self:GetLinkAIAgentInfo()
					gameMode.otherPlayerName = linkInfo.Nickname
				end

				self:OnUnitLoad(unit)
				unitLoadToken:SetResult(unit)

				return true
			end

			if not CheckAiAgent() then
				self.aiAgentLoadHandler = CheckAiAgent

				gMessageManager:AddMessageListener(gEventConstants.UNIT_LOAD_COMPLETE, self.aiAgentLoadHandler)
				coroutine.yield(unitLoadToken)
			end

			return
		end

		local gameMode = self.game.gameMode
		local player = gameMode.players[self.playerIndex]
		local playerId = player.playerId or gPlayerManager.infoLogin.bindData.pid

		if playerId ~= 0 then
			slot6 = gWaitToken.Create()

			coroutine.yield(slot6:WaitUntil(function ()
				playerId = player.playerId

				if gBowlingGameManager.debug then
					print_error("等待玩家数据")
				end

				return playerId == 0
			end))
		end

		local participantAgentUnit = nil

		if playerId ~= gPlayerManager.infoLogin.bindData.pid then
			participantAgentUnit = gCS.MyPlayerManager.PlayerUnit
		else
			local success, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(playerId, ulong.zero)
			participantAgentUnit = gCS.SceneDataMgr.GetUnit(unitId)
		end

		if participantAgentUnit ~= nil then
			print_error("找不到 unit", playerId)

			return
		end

		self.participantAgentUnit = participantAgentUnit

		self.OnUnitLoad(self, participantAgentUnit)
	end
end

BowlingCharacter.OnUnitLoad = function(self, baseUnit)
	self.baseUnit = baseUnit
	self.transform = baseUnit.ModelSlot.transform

	self:InitNodes()
	self.game.timelineManager:RegisterPlayerUnit(self.playerIndex, self.baseUnit)
	self:ResetTransform()
	UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(baseUnit, false)
end

BowlingCharacter.InitNodes = function(self)
	local playerNode = self.transform:Find("player")
	self.animator = playerNode:GetOrAddComponent(typeof(UnityEngine.Animator))
	self.handPoint = self.baseUnit.ModelSlot.handr
end

BowlingCharacter.InitData = function(self, args)
	self.game = args.game
	self.sceneNode = args.sceneNode
	self.playerPoint = args.playerPoint
	self.pinPoint = args.pinPoint
	self.virtualCamera = args.virtualCamera
	self.npcId = args.npcId
	self.agentId = args.agentId
	self.npcUnit = args.npcUnit
	self.needDestroyNpcUnit = args.needDestroyNpcUnit
	self.serverAgentInstanceId = args.serverAgentInstanceId
	self.playerIndex = args.playerIndex
	self.gameStatus = BowlingCharacter.GAME_STATUS.NONE
	self.characterStatus = BowlingCharacter.CHARACTER_STATUS.IDLE
	self.currentBallGo = nil
end

BowlingCharacter.PlayAnimationByTriggerName = function(self, triggerName)
	if gClientUtils.NotNil(self.animator) then
		self.animator:SetTrigger(triggerName)
	end
end

BowlingCharacter.Destroy = function(self)
	if self.currentBall then
		gCS.LuaUtils.DetachSceneItemFromBone(self.currentBall.sceneItemId)

		if gClientUtils.NotNil(self.currentBall.transform) then
			self.currentBall.transform:SetParent(nil)
		end
	end

	self.SetCharacterUpdateMode(self, false)

	if gCS.LuaUtils.IsBaseUnitValid(self.participantAgentUnit) then
		gCS.BaseUnitUtils.SetUnitLogicalHidden(self.participantAgentUnit, false, LX6.Units.LogicalHiddenCause.GamePlay)
	end

	if gClientUtils.NotNil(self.virtualCamera) then
		if gClientUtils.NotNil(self.virtualCamera.transform) then
			self.virtualCamera.transform:DOKill(true)
		end

		self.virtualCamera = nil
	end

	if self.needDestroyNpcUnit and gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
		self.npcUnit = self.npcUnit:DestroyUnit(true)
	end

	if self.needDestroyNpcUnit ~= false and gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
		UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(self.npcUnit, true)
	end

	if gClientUtils.NotNil(self.gameObject) then
		gBowlingGameManager:Destroy(self.gameObject)
	end

	if gClientUtils.NotNil(self.currentBallGo) then
		self.currentBallGo.transform:DOKill(false)
	end

	self.TryReturnCurrentBallGo(self)
	self.ClearCoroutines(self)
	self.ClearAIAgentLoadListener(self)
	self.ClearTimelineCallbackListeners(self)

	self.transform = nil
	self.animator = nil
	self.handPoint = nil
	self.hasDestroy = true
end

BowlingCharacter.ClearAIAgentLoadListener = function(self)
	if self.aiAgentLoadHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.UNIT_LOAD_COMPLETE, self.aiAgentLoadHandler)

		self.aiAgentLoadHandler = nil
	end
end

BowlingCharacter.ClearTimelineCallbackListeners = function(self)
	if self.timelineCallback then
		gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_BOWLING_BACK_END, self.timelineCallback)
		gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_BOWLING_WAIT_LAUNCH, self.timelineCallback)
		gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_BOWLING_BEGIN_LOOP, self.timelineCallback)
		gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_BOWLING_CATCH_BALL, self.timelineCallback)

		self.timelineCallback = nil
	end
end

BowlingCharacter.ClearCoroutines = function(self)
	if self.bowlingAnimation then
		gCoroutineManager:CancelCoroutine(self.bowlingAnimation)

		self.bowlingAnimation = nil
	end
end

BowlingCharacter.GameOver = function(self)
	self.gameStatus = BowlingCharacter.GAME_STATUS.END

	self.ClearCoroutines(self)
end

BowlingCharacter.SetActive = function(self, active)
	if self.baseUnit and self.baseUnit.ModelSlot then
		self.baseUnit.ModelSlot.gameObject:SetActive(active)
	end
end

BowlingCharacter.ResetTransform = function(self)
	self.transform.localPosition = Vector3.zero
	self.transform.localRotation = Quaternion.identity
end

BowlingCharacter.PlayBallLaunchAnim = function(self, spawnPoint, onComplete)
	if self.hasDestroy or gClientUtils.IsNil(self.currentBallGo) or gClientUtils.IsNil(self.transform) or gClientUtils.IsNil(self.sceneNode) then
		return
	end

	local ballTransform = self.currentBallGo.transform

	ballTransform:DOKill(false)
	gCS.LuaUtils.DetachSceneItemFromBone(self.currentBall.sceneItemId)
	ballTransform:SetParent(self.sceneNode.transform)

	local tSpin = Config.Launcher.forwardSpinTime or 0.15
	local forwardSpinSpeed = Config.Launcher.forwardSpinSpeed or 15
	local rotationAngle = forwardSpinSpeed * tSpin * 360 / (2 * math.pi)

	local onTweenComplete = function()
		if self.hasDestroy or gClientUtils.IsNil(self.currentBallGo) then
			return
		end

		self.game.timelineManager:ControlCameraPriority(false)

		if onComplete then
			onComplete()
		end
	end

	ballTransform.localPosition = Mathf.Lerp(ballTransform.localPosition, spawnPoint, 0.2)

	ballTransform:DOLocalMove(spawnPoint, tSpin):SetEase(DG.Tweening.Ease.OutQuart):OnComplete(onTweenComplete)
	ballTransform:DOLocalRotate(Vector3(rotationAngle, 0, 0), tSpin, DG.Tweening.RotateMode.LocalAxisAdd):SetEase(DG.Tweening.Ease.Linear)
end

BowlingCharacter.ExecuteLaunchTimeline = function(self, offsetX, fromSync)
	local ballInstanceId = 0
	local ballLauncher = self.game.ballLauncher

	if not fromSync and ballLauncher == nil then
		ballInstanceId = ballLauncher.PeekAnimBallId(ballLauncher) or 0
	end

	self:ExecuteTimeLine(TimelineScene.LAUNCH, nil, Vector3(offsetX, 0, 0), ballInstanceId, fromSync)

	if not fromSync then
		self.AttachBallToHandr(self)
	end
end

BowlingCharacter.ExecuteTimeLine = function(self, index, callBack, offset, ballInstanceId, fromSync)
	if self.hasDestroy then
		return
	end

	self.game.timelineManager:ResetTimelinePosition()
	self:SetAllCharacterUpdateMode(true)
	self:ClearTimelineCallbackListeners()

	self.timelineCallback = function(_)
		self:SetAllCharacterUpdateMode(false)
		self:ClearTimelineCallbackListeners()

		if callBack then
			callBack()
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_BOWLING_BACK_END, self.timelineCallback)
	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_BOWLING_WAIT_LAUNCH, self.timelineCallback)
	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_BOWLING_BEGIN_LOOP, self.timelineCallback)
	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_BOWLING_CATCH_BALL, self.timelineCallback)
	self.game.timelineManager:PlayClip(index, self.timelineCallback, offset, self.playerIndex, self.CharModelType, ballInstanceId, fromSync)
end

BowlingCharacter.AttachBallToHandr = function(self)
	local handr = self.handPoint

	if gClientUtils.IsNil(handr) then
		print_error("[BowlingCharacter] AttachBallToHandr: self.handPoint is nil, baseUnit=", self.baseUnit)

		return
	end

	self.CreateShowBall(self)

	if gClientUtils.NotNil(self.currentBallGo) then
		if not self.IsLocalNpc(self) then
			gCS.LuaUtils.AttachSceneItemToUnitBone(self.currentBall.sceneItemId, self.baseUnit, 11)
		else
			self.currentBallGo.transform:SetParent(handr)

			self.currentBallGo.transform.localPosition = Vector3.zero

			self.currentBall.sceneItemHold:SyncPositionAndRotation(handr.position, handr.rotation)
		end
	else
		print_error("[BowlingCharacter] AttachBallToHandr: self.currentBallGo is nil")
	end
end

BowlingCharacter.TryReturnCurrentBallGo = function(self)
	if self.currentBall then
		self.currentBall:Destroy()
	end
end

BowlingCharacter.CreateShowBall = function(self)
	self.TryReturnCurrentBallGo(self)

	local ballLauncher = self.game.ballLauncher
	self.ballType = ballLauncher.CurBallIndex
	local currentBallGo, sceneItemId = ballLauncher.CreateAnimBall(ballLauncher)

	if gClientUtils.IsNil(currentBallGo) then
		return
	end

	self.currentBallGo = currentBallGo
	local args = {
		gameObject = currentBallGo,
		ballType = self.ballType,
		sceneItemId = sceneItemId,
		game = self.game
	}
	self.currentBall = gBowlingBall.new(args)

	self.currentBall:EnablePhysics(false)
end

BowlingCharacter.SetCharacterUpdateMode = function(self, forceUpdate)
	local transform = ((gCS.LuaUtils.NeqNull(self.baseUnit) and self.baseUnit or {}).ModelSlot or {}).transform

	if gClientUtils.IsNil(transform) then
		return
	end

	local renderers = transform.GetComponentsInChildren(transform, typeof(UnityEngine.SkinnedMeshRenderer))

	for i = 0, renderers.Length - 1 do
		local renderer = renderers[i]
		renderer.updateWhenOffscreen = forceUpdate
	end
end

BowlingCharacter.SetAllCharacterUpdateMode = function(self, forceUpdate)
	for _, v in ipairs(self.game.characters) do
		v.SetCharacterUpdateMode(v, forceUpdate)
	end
end

BowlingCharacter.IsLocalNpc = function(self)
	return self.npcId and self.npcId >= 0
end

BowlingCharacter.GetLinkAIAgentInfo = function(self)
	local unit = self.baseUnit or gCS.SceneDataMgr.GetUnit(self.serverAgentInstanceId)

	return unit and unit.ClientData.AIAgentInfo or gBowlingGameManager.gameInstance and gBowlingGameManager.gameInstance.npcAIAgentInfo
end
