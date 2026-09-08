-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessPlayer.lua
-- Decompiled from: 02169_ChineseChessPlayer.lua_b67928b6ad52.luajit

local ChineseChessConfig = require("LX6/MiniGame/ChineseChess/ChineseChessConfig")
local DOTween = DG.Tweening.DOTween
C_ChineseChessPlayer = DefClass("C_ChineseChessPlayer", C_ChineseChessPlayer)
local M = C_ChineseChessPlayer

M.ctor = function(self, seatGo, handGo, handGo_c, recycleGo, modelInfo, playerSize)
	self.HandGo = handGo
	self.HandGo_C = handGo_c
	self.RecycleGo = recycleGo
	self.RecycleIndex = 0
	self._listeners = {}
	self.PlayerSize = playerSize
	self.ModelInfo = modelInfo or {}
	self.LoadCo = gCoroutineManager:StartCoroutine(function ()
		self:LoadCharacter_Async(seatGo)
	end)

	self:Reset()

	self._captureAnimLoadOp = gResourceManager:LoadAssetWithCallBack("Assets/Res/MiniGame/Prefab/ChineseChess/Chess/capture_anim.prefab", typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			return
		end

		self.CaptureAnimPrefab = loadOp.asset
	end)

	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_READY_END, function (eventId, animator)
		gChineseChessMgr:ProcessMoveQueue()
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_BACK_HAND_BEGIN, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:BackHand()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_BACK_HAND_END, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:BackHandEnd()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_MOVE_CHESS_BEGIN, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:MoveToToChess()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_MOVE_CHESS_END, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:MoveToToChessEnd()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_RECYCLE_CHESS_BEGIN, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:MoveToRecycle()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_RECYCLE_CHESS_END, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:MoveToRecycleEnd()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_TAKE_CHESS_BEGIN, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:MoveToFromChess()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_TAKE_CHESS_END, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:MoveToFromChessEnd()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_FLIP_BEGIN, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:BeginFlipChess()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_FLIP_END, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:FlipChessEnd()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_ON_PIECE, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:OnPiece()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_CAPTURE_BEGIN, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:CaptureChessBegin()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_CAPTURE_END, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:CaptureChessEnd()
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_RESULT_END, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:SetIsAction(false)

			self.IsResultAction = false

			self.PlayerController:SetHandWeight(1, 0)

			self.CurrentSlot = gChineseChessPlayerSlot.Capturer

			self.PlayerController:SetArmHand(gChineseChessPlayerSlot.Capturer)
		end

		if self._resultToken then
			self._resultToken:SetResult(true)

			self._resultToken = nil
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_READY_BEGIN, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self.PlayerController:SetTarget(self.HandGo, self.HandGo)

			self.CurrentSlot = gChineseChessPlayerSlot.Capturer

			self.PlayerController:SetArmHand(gChineseChessPlayerSlot.Capturer)
			self.PlayerController:SetHandWeight(1, 2)
		end
	end)
	self:_addListener(gEventConstants.CHINESE_CHESS_ANIMATOR_READY_END, function (eventId, animator)
		if self.IsAction and self.Animator ~= animator then
			self:Reset()
			self.PlayerController:SetTarget(self.HandGo, self.HandGo)

			self.CurrentSlot = gChineseChessPlayerSlot.Capturer

			self.PlayerController:SetArmHand(gChineseChessPlayerSlot.Capturer)
			self.PlayerController:SetHandWeight(1, 0)
		end
	end)
end

M.SetIsAction = function(self, value)
	self.IsAction = value
end

local CHESS_CONTROLLER_PATH = "Assets/Res/MiniGame/Other/ChineseChess/Animator/ChessPlayerController.controller"

M.LoadCharacter_Async = function(self, seatGo)
	local controllerPath = self.PlayerSize and gChineseChessPlayerControllerPaths[self.PlayerSize] or CHESS_CONTROLLER_PATH
	local ctrlToken = gWaitToken.Create()
	self._animControllerLoadOp = gResourceManager:LoadAssetWithCallBack(controllerPath, typeof(UnityEngine.RuntimeAnimatorController), function (loadOp)
		if self.hasDestroy then
			return
		end

		self.AnimatorController = loadOp.asset

		if gClientUtils.IsNil(self.AnimatorController) then
			print_error("[ChineseChess] 未取到象棋 AnimatorController，角色动画将不可用")
		end

		ctrlToken:SetResult(true)
	end)

	coroutine.yield(ctrlToken)

	if self.hasDestroy then
		return
	end

	local baseUnit = self.AcquireBaseUnit_Async(self, seatGo)

	if self.hasDestroy or baseUnit ~= nil then
		return
	end

	self.OnCharacterLoadCompleted(self, baseUnit, seatGo)
end

M.AcquireBaseUnit_Async = function(self, seatGo)
	if self.ModelInfo.isSelf then
		gMiniGameUtils.SetPlayerUnitVisible(false)
		gCS.LuaUtils.SetModelTransparent(gCS.MyPlayerManager.PlayerUnit, 9, 128)

		local token = gWaitToken.Create()
		local sexType = gPlayerManager.infoLogin.bindData.sexType
		local agentId = self.ModelInfo.agentId or gCS.MyPlayerManager.PlayerUnit.ClientData.AgentId

		gCS.UnitsManager:GetDialogModelByAgentId(function (baseUnit, _)
			token:SetResult(baseUnit)
		end, sexType, agentId, false, true, true, gBattleSpiritMgr.currentSpiritTemplateId)
		coroutine.yield(token)

		return token.result
	end

	slot2 = gWaitToken.Create()
	local token = slot2:SetTimeout(10)

	local CheckAiAgent = function()
		if self.hasDestroy then
			self:ClearAIAgentLoadListener()

			return true
		end

		local instanceId = gChineseChessMgr.OpponentAgentInstanceId

		if not instanceId or not ulong.Greater(instanceId, 0) then
			return false
		end

		local unit = gCS.SceneDataMgr.TryGetOrConvertToUnit(instanceId, 256)

		if not gCS.LuaUtils.IsBaseUnitValid(unit) or not unit.CanUseRes then
			return false
		end

		self:ClearAIAgentLoadListener()
		token:SetResult(unit)

		return true
	end

	if not gChineseChessMgr.OpponentAgentInstanceId or not ulong.Greater(gChineseChessMgr.OpponentAgentInstanceId, 0) then
		coroutine.yield(gChineseChessMgr.WaitOpponentAgentInstanceIdToken)
	end

	if not CheckAiAgent() then
		self.aiAgentLoadHandler = CheckAiAgent

		gMessageManager:AddMessageListener(gEventConstants.UNIT_LOAD_COMPLETE, self.aiAgentLoadHandler)
		coroutine.yield(token)
	end

	if token.isTimeout then
		print_error("[ChineseChess] 等待服务器对手 NPC 单位超时")
	end

	return token.result
end

M.ClearAIAgentLoadListener = function(self)
	if self.aiAgentLoadHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.UNIT_LOAD_COMPLETE, self.aiAgentLoadHandler)

		self.aiAgentLoadHandler = nil
	end
end

M.OnCharacterLoadCompleted = function(self, baseUnit, seatGo)
	if self.hasDestroy then
		if self.ModelInfo.isSelf and baseUnit then
			baseUnit.DestroyUnit(baseUnit, true)
		end

		return
	end

	self.BaseUnit = baseUnit

	baseUnit:ForceSetSetippleAlpha(1, true)

	baseUnit.ValidCulling = false

	baseUnit:RefreshCullingStatus()

	baseUnit.forbidAetherAI = true
	local AlwaysAnimate = 0
	baseUnit.animator.cullingMode = AlwaysAnimate
	local renderers = baseUnit.PlayerObj:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))

	for i = 0, renderers.Length - 1 do
		local renderer = renderers[i]
		renderer.updateWhenOffscreen = true
	end

	local animancer = baseUnit.PlayerObj:GetComponentInChildren(typeof(Animancer.AnimancerComponent))
	self.Animancer = animancer
	local modelTransform = baseUnit.ModelSlot.transform
	self.PlayerGo = modelTransform.gameObject
	self._originalModelParent = modelTransform.parent

	modelTransform:SetParent(seatGo, false)

	modelTransform.localPosition = Vector3.zero
	modelTransform.localRotation = Quaternion.identity

	baseUnit:SetDynamicBone(true, true)
	LX6.Units.UnitModelManager.SetShadow(baseUnit, true)
	self:InitNodes(modelTransform)
	self:SetReady(true)
	self:RegisterUpdate()

	self.IsModelLoaded = true

	gCS.LuaUtils.SetModelTransparent(baseUnit, 9, 128)
end

M.InitNodes = function(self, modelTransform)
	self.Animator = modelTransform.GetComponentInChildren(modelTransform, typeof(UnityEngine.Animator))

	if gClientUtils.NotNil(self.Animator) and gClientUtils.NotNil(self.AnimatorController) then
		self.Animator.runtimeAnimatorController = self.AnimatorController
	end

	self.PlayerController = self.Animancer.gameObject:AddComponent(typeof(MiniGame.ChineseChess.ChineseChessPlayerController))

	self.PlayerController:Load(self.PlayerSize)

	self.PlayerController.animator = self.Animator

	self.PlayerController:ResetAnimator()
	self.PlayerController.target:SetParent(gChineseChessMgr.DeskGo.transform)

	if gClientUtils.NotNil(gChineseChessMgr.BoardGo) then
		self.PlayerController.boardTransform = gChineseChessMgr.BoardGo.transform
	end

	self.PlayerController:SetTargetPosition(self.HandGo.position)
end

M.MoveChess = function(self, fromPoint, toPoint, fromChessGo)
	if not gChineseChessMgr.IsPlaying then
		return
	end

	self.PlayerController:SetHandWeight(1, 0.5)

	self.FromPoint = fromPoint
	self.ToPoint = toPoint
	self.FromChessGo = fromChessGo

	self.Animator:SetTrigger(gChessPlayerAction.move)
	gChineseChessMgr:SetCameraClipNear(self.PlayerSize, gChessPlayerAction.move)
	self:SetIsAction(true)

	self.IsMoveUp = false

	self.PlayerController:SetArmHand(gChineseChessPlayerSlot.Move, 0.05)

	self.CurrentSlot = gChineseChessPlayerSlot.Move
end

M.MoveChess_Up = function(self, fromPoint, toPoint, fromChessGo)
	if not gChineseChessMgr.IsPlaying then
		return
	end

	self.PlayerController:SetHandWeight(1, 0.5)

	self.FromPoint = fromPoint
	self.ToPoint = toPoint
	self.FromChessGo = fromChessGo

	self.Animator:SetTrigger(gChessPlayerAction.take)
	gChineseChessMgr:SetCameraClipNear(self.PlayerSize, gChessPlayerAction.take)
	self:SetIsAction(true)

	self.IsMoveUp = true

	self.PlayerController:SetArmHand(gChineseChessPlayerSlot.Move_Up)

	self.CurrentSlot = gChineseChessPlayerSlot.Move_Up
end

M.KillChess = function(self, fromPoint, toPoint, fromChessGo, toChessGo)
	if not gChineseChessMgr.IsPlaying then
		return
	end

	self.PlayerController:SetHandWeight(1, 0.5)

	self.FromPoint = fromPoint
	self.ToPoint = toPoint
	self.FromChessGo = fromChessGo
	self.ToChessGo = toChessGo

	self.Animator:SetTrigger(gChessPlayerAction.kill)
	gChineseChessMgr:SetCameraClipNear(self.PlayerSize, gChessPlayerAction.kill)
	self:SetIsAction(true)
	self.PlayerController:SetArmHand(gChineseChessPlayerSlot.CaptureTarget)

	self.CurrentSlot = gChineseChessPlayerSlot.CaptureTarget
end

M.FlipChess = function(self, fromPoint, fromChessGo)
	if not gChineseChessMgr.IsPlaying then
		return
	end

	self.PlayerController:SetHandWeight(1, 0.5)

	self.FromPoint = fromPoint
	self.FromChessGo = fromChessGo
	fromChessGo.transform.localRotation = Quaternion.Euler(180, 180, 0)

	self.Animator:SetTrigger(gChessPlayerAction.flip)
	gChineseChessMgr:SetCameraClipNear(self.PlayerSize, gChessPlayerAction.flip)
	self:SetIsAction(true)
	self.PlayerController:SetArmHand(gChineseChessPlayerSlot.Flip)

	self.CurrentSlot = gChineseChessPlayerSlot.Flip
	self.IsFlip = true
end

M.MoveToFromChess = function(self)
	gChineseChessMgr.Board:PlaySelectChessAnimation(false)

	self.TargetPoint = self.FromPoint
	local target = self.HandGo

	if self.CurrentSlot ~= gChineseChessPlayerSlot.Capturer then
		target = self.HandGo_C
	end

	self.PlayerController:SetArcTarget(target, self.TargetPoint, 0.05)
end

M.MoveToFromChessEnd = function(self)
	if self.IsFlip then
		return
	end

	self.FromChessGo.transform:DOKill()
	self.FromChessGo.transform:SetParent(self.PlayerController.target, true)

	self.FromChessGo.transform.localPosition = Vector3.New(0.5, self.FromChessGo.transform.localPosition.y, 0)
end

M.BeginFlipChess = function(self)
	local my, enemy = gChineseChessMgr:GetPlayerInfo2()
	local flipAnimName = self.PlayerInfo ~= my and "Flip_2" or "Flip"

	self.FromChessGo:GetComponent("Animator"):Play(flipAnimName)

	if self.FlipHandSequence then
		self.FlipHandSequence:Kill()
	end

	local target = self.PlayerController.target
	local originalPos = target.position
	local liftedPos = Vector3.New(originalPos.x, originalPos.y + 0.03, originalPos.z)
	slot7 = target:DOMove(liftedPos, 0.3)
	local tweenUp = slot7:SetEase(DG.Tweening.Ease.OutCubic)
	slot8 = target:DOMove(originalPos, 0.2)
	local tweenDown = slot8:SetEase(DG.Tweening.Ease.InCubic)
	self.FlipHandSequence = DOTween.Sequence()
	slot9 = self.FlipHandSequence

	slot9:Append(tweenUp)

	slot9 = self.FlipHandSequence

	slot9:Append(tweenDown)

	slot9 = self.FlipHandSequence

	slot9:OnComplete(function ()
		self.FlipHandSequence = nil
	end)
end

M.FlipChessEnd = function(self)
	self.FromChessGo.transform.localRotation = Quaternion.Euler(0, 180, 0)
end

local captureAnim = nil

M.CaptureChessBegin = function(self)
	self.PlayerController:SetArmHand(gChineseChessPlayerSlot.Capturer)

	self.CurrentSlot = gChineseChessPlayerSlot.Capturer
	captureAnim = UnityEngine.GameObject.Instantiate(self.CaptureAnimPrefab)
	captureAnim.transform.position = self.ToPoint.transform.position

	if self.PlayerInfo.PlayerId == gChineseChessMgr.PlayerId then
		captureAnim.transform.localRotation = Quaternion.Euler(0, 180, 0)
	end

	captureAnim:GetComponent("Animator"):Play("qizi_chi")
	self.FromChessGo.transform:SetParent(captureAnim.transform:GetChild(0))

	self.FromChessGo.transform.localPosition = Vector3.zero

	self.ToChessGo.transform:SetParent(captureAnim.transform:GetChild(1))

	self.ToChessGo.transform.localPosition = Vector3.zero
	local anim = self.ToChessGo:GetComponent("Animator")

	if anim then
		UnityEngine.GameObject.Destroy(anim)
	end

	gLuaTimeMgrUtils.Delay(function ()
		self.FromChessGo.transform.localPosition = Vector3.zero
		self.ToChessGo.transform.localPosition = Vector3.zero

		if self.PlayerInfo.PlayerId == gChineseChessMgr.PlayerId then
			self.FromChessGo.transform.localRotation = Quaternion.Euler(90, 0, 0)
			self.ToChessGo.transform.localRotation = Quaternion.Euler(90, 0, 0)
		else
			self.FromChessGo.transform.localRotation = Quaternion.Euler(-90, 180, 0)
			self.ToChessGo.transform.localRotation = Quaternion.Euler(-90, 180, 0)
		end
	end, 0.01)
	gLuaTimeMgrUtils.Delay(function ()
		if not self.ToChessGo then
			return
		end

		slot0 = self.PlayerController
		local slot = slot0:GetSlotPoint(gChineseChessPlayerSlot.Place)
		slot1 = self.ToChessGo.transform

		slot1:SetParent(slot, true)

		local oldRot = self.ToChessGo.transform.rotation.eulerAngles
		local oldPos = self.ToChessGo.transform.localPosition

		DOTween.To(function ()
			return 0
		end, function (v)
			self.ToChessGo.transform.localPosition = Vector3.Lerp(oldPos, Vector3.zero, v)
			self.ToChessGo.transform.rotation = Quaternion.Lerp(Quaternion.Euler(oldRot.x, oldRot.y, oldRot.z), Quaternion.Euler(0, 180, 0), v)
		end, 1, 0.2)
	end, 0.1)
end

M.CaptureChessEnd = function(self)
	if captureAnim then
		captureAnim:Destroy()

		captureAnim = nil
	end

	slot1 = self.FromChessGo.transform

	slot1:SetParent(self.ChesssGo)

	self.FromChessGo.transform.position = self.ToPoint.position
	self.FromChessGo.transform.rotation = Quaternion.Euler(0, 180, 0)

	gLuaTimeMgrUtils.Delay(function ()
		if not self.FromChessGo then
			return
		end

		self.FromChessGo.transform.position = self.ToPoint.position
		self.FromChessGo.transform.rotation = Quaternion.Euler(0, 180, 0)
	end, 0.01)
end

M.OnPiece = function(self)
end

M.MoveToToChess = function(self)
	if self.ToChessGo then
		self.PlayerController:ArcToAboveTarget(self.ToPoint, 0.07)
	elseif self.IsMoveUp then
		self.PlayerController:SetArcTarget(self.TargetPoint, self.ToPoint, 0.05)
	else
		self.PlayerController:SetTarget(self.TargetPoint, self.ToPoint)

		if gClientUtils.IsNil(self.ToChessGo) then
			gSoundMgr:PlaySoundByTid(ChineseChessConfig.SoundId.MovePiece)

			if self.ModelInfo.isSelf then
				self._pushSoundId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)
			end
		end
	end

	self.TargetPoint = self.ToPoint
end

M.MoveToToChessEnd = function(self)
	local targetWorldPos = self.ToPoint.position
	local fromChessGo = self.FromChessGo
	local toChessGo = self.ToChessGo

	fromChessGo.transform:SetParent(self.ChesssGo, true)
	fromChessGo.transform:SetPosition(targetWorldPos)

	fromChessGo.transform.localRotation = Quaternion.Euler(0, 180, 0)

	if self.ModelInfo.isSelf then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
	end

	if self.IsMoveUp or gClientUtils.NotNil(toChessGo) then
		gSoundMgr:PlaySoundByTid(ChineseChessConfig.SoundId.PlacePiece)
	end

	if gClientUtils.NotNil(toChessGo) then
		gSoundMgr:PlaySoundByTid(ChineseChessConfig.SoundId.CapturePiece)
	end

	if self._pushSoundId then
		gSoundMgr:StopSoundByNid(self._pushSoundId)

		self._pushSoundId = nil
	end

	FrameTimer.New(function ()
		if gClientUtils.NotNil(fromChessGo) then
			fromChessGo.transform:SetPosition(targetWorldPos)

			fromChessGo.transform.localRotation = Quaternion.Euler(0, 180, 0)
		end
	end, 1):Start()
	gChineseChessMgr.Board:DeselectChess()
end

M.MoveToRecycle = function(self)
	local nextTarget = self:NextRecyclePoint(self.ChessId)

	self.PlayerController:SetArmHand(gChineseChessPlayerSlot.CaptureTarget)
	self.PlayerController:SetArcTarget(self.TargetPoint, nextTarget, 0.1)

	self.TargetPoint = nextTarget
end

M.MoveToRecycleEnd = function(self)
	if gClientUtils.NotNil(self.ToChessGo) then
		self.ToChessGo.transform:SetParent(self.TargetPoint, true)
	end
end

M.BackHand = function(self)
	if gClientUtils.NotNil(self.ToChessGo) then
		self.ToChessGo.transform:SetParent(self.TargetPoint, true)

		self.ToChessGo.transform.localRotation = Quaternion.Euler(0, 180, 0)
		self.ToChessGo.transform.localPosition = Vector3.zero
	end

	local target = self.HandGo

	if self.CurrentSlot ~= gChineseChessPlayerSlot.Move then
		target = self.HandGo_C
	end

	self.PlayerController:MoveToHome(target)
	self.PlayerController:SetArmHand(gChineseChessPlayerSlot.Capturer)

	self.CurrentSlot = gChineseChessPlayerSlot.Capturer

	self.PlayerController:SetHandWeight(1, 2)
end

M.BackHandEnd = function(self)
	self.ActionComplete(self)
end

M.NextRecyclePoint = function(self, chessId)
	local point = nil

	if gChineseChessMgr.IsFlipChart and chessId then
		local chessColor = gChineseChessTools.IsRedChess(chessId)
		local player = gChineseChessMgr:GetPlayer(chessColor)
		local type = gChineseChessTools.GetChessType(chessId)
		local points = player.RecyclePoints[type]
		local index = table.remove(points, 1)

		print("NextRecyclePoint", chessId, chessColor, index, player.RecycleIndex)

		point = player.RecycleGo:GetChild(index)
		player.RecycleIndex = player.RecycleIndex + 1
	else
		local index = nil

		if self.RecycleFreePoints and #self.RecycleFreePoints <= 0 then
			index = table.remove(self.RecycleFreePoints)
		else
			index = self.RecycleIndex
			self.RecycleIndex = self.RecycleIndex + 1
		end

		point = self.RecycleGo:GetChild(index)
	end

	return point
end

M.RemoveRecycleChesses = function(self, chessIds)
	if gClientUtils.IsNil(self.RecycleGo) or #chessIds ~= 0 then
		return
	end

	local targetSet = {}

	for _, id in ipairs(chessIds) do
		targetSet[tostring(id)] = true
	end

	for i = 0, self.RecycleGo.childCount - 1 do
		local slot = self.RecycleGo:GetChild(i)

		for j = slot.childCount - 1, 0, -1 do
			local child = slot.GetChild(slot, j)

			if targetSet[child.name] then
				gClientUtils.DestroyUnityObject(child.gameObject)

				if gChineseChessMgr.IsFlipChart then
					local chessId = tonumber(child.name)

					if chessId then
						local chessType = gChineseChessTools.GetChessType(chessId)
						local points = self.RecyclePoints[chessType]

						if points then
							table.insert(points, 1, i)
						end
					end
				else
					self.RecycleFreePoints = self.RecycleFreePoints or {}

					table.insert(self.RecycleFreePoints, i)
				end
			end
		end
	end
end

M.ActionComplete = function(self)
	gChineseChessMgr:PlayerActionComplete(self.PlayerInfo)
	gChineseChessMgr:FlushActionCompleteTasks(self, self.PlayerInfo)
	self:ResetAction()
	gChineseChessMgr:ProcessMoveQueue()

	if self.IsReady then
		self.IsReady = false
	end
end

M.Win = function(self, token)
	self.IsResultAction = true

	self:SetIsAction(true)

	self._resultToken = token

	self.PlayerController:SetHandWeight(0, 1)
	self.Animator:SetTrigger(gChessPlayerAction.win)
	self.Animator:ResetTrigger(gChessPlayerAction.take)

	self.Animator.speed = 1

	gChineseChessMgr:SetCameraClipNear(self.PlayerSize, gChessPlayerAction.win)
end

M.Lose = function(self, token)
	self.IsResultAction = true

	self:SetIsAction(true)

	self._resultToken = token

	self.PlayerController:SetHandWeight(0, 1)
	self.Animator:SetTrigger(gChessPlayerAction.lose)
	self.Animator:ResetTrigger(gChessPlayerAction.take)
	gChineseChessMgr:SetCameraClipNear(self.PlayerSize, gChessPlayerAction.lose)

	self.Animator.speed = 1
end

M.ResetAction = function(self)
	self.ChessId = nil
	self.IsFlip = false

	self.SetIsAction(self, false)

	self.FromPoint = nil
	self.ToPoint = nil
	self.FromChessGo = nil
	self.ToChessGo = nil

	if self.FlipHandSequence then
		self.FlipHandSequence:Kill()

		self.FlipHandSequence = nil
	end
end

M.Reset = function(self, notResetAnimator)
	if gClientUtils.NotNil(self.Animator) then
		if not notResetAnimator then
			self.Animator:SetTrigger(gChessPlayerAction.reset)
		end

		gChineseChessMgr:SetCameraClipNear(self.PlayerSize, gChessPlayerAction.reset)

		self.Animator.speed = 1

		self:BackHand()
	end

	self.ResetAction(self)

	self.RecycleIndex = 0
	self.RecycleFreePoints = nil
	self.TargetPoint = nil

	if gClientUtils.NotNil(self.RecycleGo) then
		for i = 0, self.RecycleGo.childCount - 1 do
			local slot = self.RecycleGo:GetChild(i)

			for j = slot.childCount - 1, 0, -1 do
				gClientUtils.DestroyUnityObject(slot.GetChild(slot, j).gameObject)
			end
		end
	end

	self.RecyclePoints = {
		[gChineseChessType.Jiang] = {
			0
		},
		[gChineseChessType.Shi] = {
			1,
			2
		},
		[gChineseChessType.Xiang] = {
			3,
			4
		},
		[gChineseChessType.Ma] = {
			5,
			6
		},
		[gChineseChessType.Che] = {
			7,
			8
		},
		[gChineseChessType.Pao] = {
			9,
			10
		},
		[gChineseChessType.Bing] = {
			11,
			12,
			13,
			14,
			15
		}
	}
end

M._addListener = function(self, eventId, handler)
	gMessageManager:AddMessageListener(eventId, handler)
	table.insert(self._listeners, {
		eventId = eventId,
		handler = handler
	})
end

M.SetReady = function(self, isReady)
	self:SetIsAction(true)

	self.IsReady = isReady
	self.Animator.speed = 1

	self.PlayerController:SetHandWeight(1, 0.7)
	self.Animator:SetBool(gChessPlayerAction.ready, isReady)
	gChineseChessMgr:SetCameraClipNear(self.PlayerSize, gChessPlayerAction.ready)
end

M.Destroy = function(self)
	self.UnRegisterUpdate(self)

	if self._listeners then
		for _, entry in ipairs(self._listeners) do
			gMessageManager:RemoveMessageListener(entry.eventId, entry.handler)
		end

		self._listeners = nil
	end

	self.hasDestroy = true

	if self.LoadCo then
		gCoroutineManager:CancelCoroutine(self.LoadCo)

		self.LoadCo = nil
	end

	self.ClearAIAgentLoadListener(self)

	if self._captureAnimLoadOp then
		gResourceManager:UnloadAssetLoadOp(self._captureAnimLoadOp)

		self._captureAnimLoadOp = nil
	end

	if self._animControllerLoadOp then
		gResourceManager:UnloadAssetLoadOp(self._animControllerLoadOp)

		self._animControllerLoadOp = nil
	end

	if self.ModelInfo.isSelf then
		if gCS.LuaUtils.IsBaseUnitValid(self.BaseUnit) then
			self.BaseUnit:DestroyUnit(true)
		end
	elseif gCS.LuaUtils.IsBaseUnitValid(self.BaseUnit) then
		gCS.LuaUtils.RevertModelTransparent(self.BaseUnit, 9)

		if self.BaseUnit.ModelSlot then
			self.BaseUnit.ModelSlot.transform:SetParent(self._originalModelParent, false)
		end

		local animancer = self.Animancer

		if gClientUtils.NotNil(animancer) then
			LX6.Utils.LuaUtils.SetAnimancerGraphPlaying(animancer, true)
		end

		gClientUtils.DestroyUnityObject(self.PlayerController)
	end

	self.BaseUnit = nil
	self.PlayerGo = nil
	self._originalModelParent = nil
end

M.RegisterUpdate = function(self)
	self.updateHandler = UpdateBeat:CreateListener(self.OnUpdate, self)

	UpdateBeat:AddListener(self.updateHandler)
end

M.UnRegisterUpdate = function(self)
	if self.updateHandler then
		UpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end
end

M.OnUpdate = function(self)
	local animancer = self.Animancer

	if gClientUtils.NotNil(animancer) then
		LX6.Utils.LuaUtils.SetAnimancerGraphPlaying(animancer, false)
	end
end

return M
