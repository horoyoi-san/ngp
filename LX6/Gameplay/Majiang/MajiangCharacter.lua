-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangCharacter.lua
-- Decompiled from: 00336_MajiangCharacter.lua_0d13de466468.luajit

local GameplaySignalInwardConfig = LTConfig.GameplaySignalInwardConfig
local PCGType = UX.Game.MjPCGType
local MahjongUtils = L18.Mahjong.MahjongUtils
local MjStateTypeNameMap = {}

if gCS.LuaUtils.IsDebug then
	for k, v in pairs(gMaJiangConst.MjStateType) do
		MjStateTypeNameMap[v] = k
	end
end

local MjTransitionTypeNameMap = {}

if gCS.LuaUtils.IsDebug then
	for k, v in pairs(gMaJiangConst.MjTransitionType) do
		MjTransitionTypeNameMap[v] = k
	end
end

local PENDING_ATTACH_TIMEOUT = 5

local print_debug = function(unit, ...)
	if unit ~= gCS.MyPlayerManager.PlayerUnit then
		_G.print_debug("unit", (unit.PlayerObj or {}).name, ...)
	end
end

C_MajiangCharacter = DefClass("C_MajiangCharacter", C_MajiangCharacter)
local M = C_MajiangCharacter

M.ctor = function(self, game, seatRef)
	self.game = game
	self.seatRef = seatRef
	self.seatID = seatRef.id
	self.machineIndex = seatRef.machineIndex
	self.playerInfo = nil
	self.playerType = nil
	self.unit = nil
	self.fsm = nil
	self.aiPlayerBindCo = nil
	self.seatLockCo = nil
	self.enterMahjongFrame = nil

	self.ResetFSMRuntimeData(self)
end

M.ResetFSMRuntimeData = function(self)
	self.discardTriggeredByUI = false
	self.attachData = {}
	self.pendingChiPongKong = {}
	self._pendingAttachTimers = {}
	self.handCards = {}
	self.handCardInsts = {}
	self.pengGangInsts = {}
	self.allHandCardInsts = {
		hand = self.handCardInsts,
		pengGang = self.pengGangInsts,
		pending = {}
	}
	self.handCardArea = nil
	self.openHandCardArea = nil
end

M.InitFSM = function(self)
	self:DisposeFSM()
	self:ResetFSMRuntimeData()

	self.unit = self:GetUnit()
	self.fsm = gFSMManager:GetFSM(self)

	self.fsm:AddStates(gMaJiangConst.MjStateType)
	self.fsm:AddTransitions(gMaJiangConst.MjStateType, gMaJiangConst.MjTransitionType)
	self.fsm:SetInitState(gMaJiangConst.MjStateType.GameStart)

	self.handCardInsts = (self.game.handEntList or {})[self.machineIndex] or {}
	self.pengGangInsts = (self.game.pengEntList or {})[self.machineIndex] or {}
	self.allHandCardInsts = {
		hand = self.handCardInsts,
		pengGang = self.pengGangInsts,
		pending = {}
	}
	local machine = self.game:GetMachine()
	self.handCardArea = machine.handCardArea[self.machineIndex]
	self.openHandCardArea = machine.openHandCardArea[self.machineIndex]
end

M.DisposeFSM = function(self)
	if self._pendingAttachTimers then
		for _, uuid in pairs(self._pendingAttachTimers) do
			if uuid and uuid == 0 then
				gLuaTimeMgrUtils.CancelUnitDelay(uuid)
			end
		end

		self._pendingAttachTimers = nil
	end

	if self.fsm then
		self.fsm:Dispose()

		self.fsm = nil
	end
end

M.Dispose = function(self)
	self.StopAIPlayerBindCo(self)
	self.StopSeatLock(self)
	self.DisposeFSM(self)

	self.playerInfo = nil
	self.playerType = nil
	self.unit = nil
end

M.SetUnit = function(self, unit)
	self.BindUnit(self, unit)
end

M.SetPlayerInfo = function(self, playerInfo)
	if self.playerInfo == nil and self.playerInfo == playerInfo then
		self.StopAIPlayerBindCo(self)
		self.StopSeatLock(self)

		self.enterMahjongFrame = nil
		self.unit = nil
	end

	self.playerInfo = playerInfo
	self.playerType = playerInfo and self.game:GetPlayerType(playerInfo) or nil
end

M.GetPlayerType = function(self)
	return self.playerType
end

M.IsRealPlayer = function(self)
	return self.playerType ~= gMaJiangConst.PlayerType.RealPlayer
end

M.IsNonRealPlayer = function(self)
	return self.playerType == nil and self.playerType == gMaJiangConst.PlayerType.RealPlayer
end

M.GetRealPlayerUnitPid = function(self)
	local playerInfo = self.playerInfo

	if playerInfo ~= nil then
		return nil
	end

	return self.game:GetUnitPidByPlayerPid(playerInfo.Pid)
end

M.GetAIPlayerUnitPid = function(self)
	local playerInfo = self.playerInfo

	if playerInfo ~= nil or not ulong.Greater(playerInfo.AgentInstanceId or 0, 0) then
		return nil
	end

	return playerInfo.AgentInstanceId
end

M.GetNpcUnitPid = function(self)
	if self.unit == nil and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(self.unit) then
		return self.unit.Pid
	end

	return self.game:GetNpcUnitPidBySeatID(self.seatID)
end

M.GetUnitPid = function(self)
	if self.playerType ~= gMaJiangConst.PlayerType.RealPlayer then
		return self.GetRealPlayerUnitPid(self)
	elseif self.playerType ~= gMaJiangConst.PlayerType.AIPlayer then
		return self.GetAIPlayerUnitPid(self)
	elseif self.playerType ~= gMaJiangConst.PlayerType.NPC then
		return self.GetNpcUnitPid(self)
	end

	return nil
end

M.GetUnit = function(self)
	if self.unit == nil and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(self.unit) then
		return self.unit
	end

	local pid = self.GetUnitPid(self)

	if pid ~= nil then
		return nil
	end

	local unit = self.game:GetUnitByPid(pid)

	if unit == nil then
		self.unit = unit
	end

	return unit
end

M.EnsureUnit = function(self)
	if self.playerInfo ~= nil then
		return
	end

	if self.playerType ~= gMaJiangConst.PlayerType.RealPlayer then
		local unit = self.GetUnit(self)

		if unit == nil then
			self.BindUnit(self, unit)
		end
	elseif self.playerType ~= gMaJiangConst.PlayerType.NPC then
		self.EnsureNpcUnit(self)
	elseif self.playerType ~= gMaJiangConst.PlayerType.AIPlayer then
		self.EnsureAIPlayerUnit(self)
	end
end

M.EnsureNpcUnit = function(self)
	local unit = self.GetUnit(self)

	if unit == nil then
		self.BindUnit(self, unit)
		self.MoveToSeat(self)

		return
	end

	local playerInfo = self.playerInfo

	if playerInfo ~= nil or (playerInfo.NpcMahjongId or 0) ~= 0 then
		return
	end

	local machine = self.game:GetMachine()

	if gClientUtils.IsNil(machine) then
		return
	end

	local playerTransforms = machine.playerTransforms

	if playerTransforms ~= nil then
		return
	end

	local tf = playerTransforms[self.seatID]

	if gClientUtils.IsNil(tf) then
		return
	end

	slot6 = self.game.manager
	local agentId = slot6:GetAgentIdByNpcId(playerInfo.NpcMahjongId)
	slot7 = self.game.manager
	local csUnit = slot7:CreateNpcInMaJiang(agentId, tf, 0, function (loadedUnit)
		self:BindUnit(loadedUnit)
		self:MoveToSeat()
		self:MarkEnterMahjongFrame()
		self:StartSeatLock()
	end)

	if csUnit == nil then
		self.BindUnit(self, csUnit)
		self.MoveToSeat(self)
	end
end

M.EnsureAIPlayerUnit = function(self)
	local playerInfo = self.playerInfo

	if playerInfo ~= nil then
		return
	end

	local agentInstanceId = playerInfo.AgentInstanceId

	if not ulong.Greater(agentInstanceId or 0, 0) then
		return
	end

	local unit = gCS.SceneDataMgr.GetUnit(agentInstanceId)

	if gCS.LuaUtils.IsBaseUnitValid(unit) then
		self.SetupAIPlayerUnit(self, unit)

		return
	end

	if self.aiPlayerBindCo == nil then
		return
	end

	self.aiPlayerBindCo = coroutine.start(function ()
		if self.playerInfo == nil then
			slot0 = ulong.equals
			slot2 = self.playerInfo.AgentInstanceId or 0

			while self.playerInfo == nil and slot0(slot2, agentInstanceId) do
				unit = gCS.SceneDataMgr.GetUnit(agentInstanceId)

				if gCS.LuaUtils.IsBaseUnitValid(unit) then
					self.aiPlayerBindCo = nil

					self:SetupAIPlayerUnit(unit)

					return
				end

				coroutine.step()
			end
		end

		self.aiPlayerBindCo = nil
	end)
end

M.SetupAIPlayerUnit = function(self, unit)
	if not gCS.LuaUtils.IsBaseUnitValid(unit) then
		return
	end

	self:BindUnit(unit)
	self:MoveToSeat()

	unit.ValidCulling = false

	unit:RefreshCullingStatus()

	unit.forbidAetherAI = true

	self.game:OnAIUnitLoaded(unit)
	self:SendEnterMahjongSignal()
end

M.BindUnit = function(self, unit)
	if not gCS.LuaUtils.IsBaseUnitValid(unit) then
		return
	end

	self.unit = unit
	self.game.seatUnitPids = self.game.seatUnitPids or {}
	self.game.seatUnitPids[self.seatID] = unit.Pid
	self.game.manager.pidToUnit = self.game.manager.pidToUnit or {}
	self.game.manager.pidToUnit[unit.Pid] = unit
end

M.MoveToSeat = function(self)
	local unit = self:GetUnit()
	local machine = self.game:GetMachine()

	if unit ~= nil or gClientUtils.IsNil(machine) or self.IsRealPlayer(self) then
		return
	end

	local playerTransforms = machine.playerTransforms

	if playerTransforms ~= nil then
		return
	end

	local seatTransform = playerTransforms[self.seatID]
	local playerObj = unit.PlayerObj
	local playerTransform = playerObj and (playerObj.transform or playerObj)

	if gClientUtils.NotNil(seatTransform) and gClientUtils.NotNil(playerTransform) then
		self.game:SetPosition(playerTransform, seatTransform.position)

		playerTransform.rotation = seatTransform.rotation
	end
end

M.SendEnterMahjongSignal = function(self)
	local unit = self.GetUnit(self)

	if unit ~= nil then
		return
	end

	self.enterMahjongFrame = nil

	self.StartSeatLock(self)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, GameplaySignalInwardConfig.MahjongGameStart, 1)
	self.MarkEnterMahjongFrame(self)
end

M.MarkEnterMahjongFrame = function(self)
	self.enterMahjongFrame = Time.frameCount
end

M.StartSeatLock = function(self)
	if self.seatLockCo == nil then
		return
	end

	self.seatLockCo = coroutine.start(function ()
		while self:IsNonRealPlayer() and self:GetUnit() == nil do
			self:MoveToSeat()

			if self.enterMahjongFrame == nil and Time.frameCount <= self.enterMahjongFrame + 1 then
				break
			end

			coroutine.step()
		end

		self.seatLockCo = nil
	end)
end

M.StopSeatLock = function(self)
	if self.seatLockCo == nil then
		coroutine.stop(self.seatLockCo)

		self.seatLockCo = nil
	end
end

M.StopAIPlayerBindCo = function(self)
	if self.aiPlayerBindCo == nil then
		coroutine.stop(self.aiPlayerBindCo)

		self.aiPlayerBindCo = nil
	end
end

M.OnGameStartEnter = function(self)
	if self.IsNonRealPlayer(self) then
		self.SendEnterMahjongSignal(self)

		return
	end

	self.SendGameplayInwardSignal(self, GameplaySignalInwardConfig.MahjongGameStart, 1)
end

M.OnGameStartExit = function(self)
end

M.OnDingQueEnter = function(self)
end

M.OnDingQueExit = function(self)
end

M.OnIdleEnter = function(self)
	self.DoPendingTask(self)
end

M.OnIdleExit = function(self)
end

M.DoDrawCard = function(self, cardTransform, direction, drawSeatID, wallDirection, wallPileIndex)
	self:SendSignal(gMaJiangConst.MjTransitionType.Idle_DrawCard)

	local blendX = self.game:GetDrawCardBlend(drawSeatID, wallDirection, wallPileIndex)
	self.stateData = {
		cardTransform = cardTransform,
		cardPosition = cardTransform.position,
		direction = direction,
		drawSeatID = drawSeatID,
		wallDirection = wallDirection,
		wallPileIndex = wallPileIndex,
		handCardCount = #self.handCardInsts + 1,
		blendX = blendX
	}
end

M.OnDrawCardEnter = function(self)
	local dir = self.stateData and self.stateData.direction or 1

	self:SendGameplayInwardSignal(GameplaySignalInwardConfig.MahjongDrawCard, dir)
end

M.OnDrawCardExit = function(self)
	self.stateData = nil
end

M.DoDiscardCard = function(self, cardEnt, cardInfo, handCardIndex, fromUI, tokenId)
	if fromUI ~= true and cardEnt then
		self.discardTriggeredByUI = true
	end

	if gClientUtils.IsNil(cardEnt) then
		return
	end

	if cardInfo ~= nil then
		print_error("[Majiang-Character] DoDiscardCard cardInfo is nil", self.seatID)

		return
	end

	if tokenId ~= nil then
		print_error("[Majiang-Character] DoDiscardCard tokenId is nil", self.seatID, cardInfo.InstanceId)

		return
	end

	local instanceId = cardInfo.InstanceId
	self.deferDiscard3D = true
	self.pendingDiscardCardEnt = cardEnt
	self.pendingDiscardInstanceId = instanceId
	self.pendingDiscardTokenId = tokenId

	if cardInfo == nil then
		self.QueueNextAttach(self, cardEnt, cardInfo, gMaJiangConst.AttachType.DiscardCard, tokenId, instanceId)
	end

	local index = handCardIndex
	local targetPos, targetLocalRotation, targetIkPos, discardIndex = self.game:GetNextDiscardPose(self.seatID)
	local blendX = self.game:GetHandCardBlendX(self.seatID, index, cardEnt.transform)

	self:SendSignal(gMaJiangConst.MjTransitionType.Idle_DiscardCard)

	local cardPosition = cardEnt.IKReferencePoint.position
	self.stateData = {
		cardTransform = cardEnt.transform,
		cardPosition = cardPosition,
		targetLocalRotation = targetLocalRotation or Quaternion.identity,
		targetPos = targetPos,
		targetIkPos = targetIkPos,
		discardIndex = discardIndex,
		blendX = blendX
	}
end

M.OnDiscardCardEnter = function(self)
	self.SendGameplayInwardSignal(self, GameplaySignalInwardConfig.MahjongDiscardCard)
end

M.OnDiscardCardExit = function(self)
	self.stateData = nil
end

M.DoChiPongKong = function(self, cardTransform, isFromOutCard, sourceSeatID, cardPosition, signalActionType)
	self:SendSignal(gMaJiangConst.MjTransitionType.Idle_ChiPongKong)

	local validCardTransform = gClientUtils.NotNil(cardTransform) and cardTransform or nil
	local finalCardPosition = cardPosition or validCardTransform and validCardTransform.position or nil
	local sourceDirection = 1

	if isFromOutCard then
		local sourceSeat = sourceSeatID

		if sourceSeat ~= nil then
			sourceSeat = self.game.turnSeatId
		end

		sourceDirection = self.GetDirectionToSeat(self, sourceSeat)
	end

	self.stateData = {
		cardTransform = validCardTransform,
		cardPosition = finalCardPosition,
		isFromOutCard = isFromOutCard,
		sourceSeatID = sourceSeatID,
		sourceDirection = sourceDirection,
		signalActionType = signalActionType
	}
end

M.OnChiPongKongEnter = function(self)
	local dir = 1

	if self.stateData and self.stateData.isFromOutCard then
		local sourceSeat = self.stateData.sourceSeatID

		if sourceSeat ~= nil then
			sourceSeat = self.game.turnSeatId
		end

		dir = self.GetDirectionToSeat(self, sourceSeat)
	end

	local signal = GameplaySignalInwardConfig.MahjongChiPongKong

	if self.stateData and self.stateData.signalActionType ~= UX.Game.MjActionType.AnGang then
		signal = GameplaySignalInwardConfig.MahjongAnGang
	end

	self.SendGameplayInwardSignal(self, signal, dir)
end

M.OnChiPongKongExit = function(self)
	self.stateData = nil
end

M.OnHuIdleEnter = function(self)
end

M.OnHuIdleExit = function(self)
end

M.ConfirmHu = function(self)
	self.SendSignal(self, gMaJiangConst.MjTransitionType.HuIdle_Hu)
end

M.CancelHu = function(self)
	self.SendSignal(self, gMaJiangConst.MjTransitionType.HuIdle_Idle)
end

M.OnHuEnter = function(self)
end

M.OnHuExit = function(self)
end

M.OnGameEndEnter = function(self)
	self.SendGameplayInwardSignal(self, GameplaySignalInwardConfig.MahjongGameEnd)
end

M.OnGameEndExit = function(self)
end

M.GetHandCardInst = function(self, index)
	return self.handCardInsts and self.handCardInsts[index]
end

M.SetHandCardsFromInfo = function(self, paiInfos)
	self.handCards = {}
	paiInfos = paiInfos or {}

	for i, v in ipairs(paiInfos) do
		self.handCards[i] = v
	end
end

M._RemoveFromPendingList = function(self, cardEnt)
	local pending = self.allHandCardInsts and self.allHandCardInsts.pending

	if pending ~= nil or gClientUtils.IsNil(cardEnt) then
		return
	end

	for i = #pending, 1, -1 do
		if pending[i] ~= cardEnt then
			table.remove(pending, i)
		end
	end
end

M._CancelPendingAttachTimer = function(self, attachType)
	if not self._pendingAttachTimers then
		return
	end

	local uuid = self._pendingAttachTimers[attachType]

	if uuid and uuid == 0 then
		gLuaTimeMgrUtils.CancelUnitDelay(uuid)
	end

	self._pendingAttachTimers[attachType] = nil
end

M._SchedulePendingAttachTimer = function(self, attachType)
	self._CancelPendingAttachTimer(self, attachType)

	local seatID = self.seatID
	self._pendingAttachTimers[attachType] = gLuaTimeMgrUtils.Delay(function ()
		local data = self.attachData and self.attachData[attachType]

		if not data or not self.game then
			return
		end

		local nowTime = Time.time
		local createTime = data.createTime

		if nowTime - createTime >= PENDING_ATTACH_TIMEOUT - 0.1 then
			return
		end

		self.attachData[attachType] = nil

		self:_RemoveFromPendingList(data.cardEnt)

		local handInstanceIds = {}

		for i = 1, #self.handCards do
			local handCardInfo = self.handCards[i]
			handInstanceIds[i] = tostring(handCardInfo and handCardInfo.InstanceId or 0)
		end

		if self.game.manager.debug then
			print_error("#NoCreateIssue [Majiang-Character] PendingAttachTimeout force finish", seatID, attachType, data.instanceId or 0, data.tokenId or 0, table.concat(handInstanceIds, ","))
		else
			print_warn("[Majiang-Character] PendingAttachTimeout force finish", seatID, attachType, data.instanceId or 0, data.tokenId or 0, table.concat(handInstanceIds, ","))
		end

		self.game:FinishAttach(attachType, seatID, data, true, "PendingAttachTimeout")

		if self.game and self.game.debug then
			print_debug(self.unit, "DebugAttach PendingAttachTimeout", seatID, attachType, data)
		end
	end, PENDING_ATTACH_TIMEOUT, 1, nil, true)
end

M.QueueNextAttach = function(self, cardEnt, cardInfo, attachType, tokenId, instanceId)
	local nowTime = Time.time

	self.game:FinishAllPendingAttaches("PreserveSingleActiveAttach")

	if tokenId ~= nil or instanceId ~= nil then
		print_error("[Majiang-Character] QueueNextAttach invalid flow data", self.seatID, attachType, tokenId, instanceId)

		return
	end

	local data = {
		cardEnt = cardEnt,
		instanceId = instanceId,
		tokenId = tokenId,
		cardInfo = cardInfo,
		attachType = attachType,
		createTime = nowTime
	}
	self.attachData[attachType] = data

	if self.allHandCardInsts and self.allHandCardInsts.pending then
		table.insert(self.allHandCardInsts.pending, cardEnt)
	end

	if attachType ~= gMaJiangConst.AttachType.ChiPongKong and self.pendingChiPongKong then
		table.insert(self.pendingChiPongKong, {
			cardEnt = cardEnt,
			instanceId = instanceId,
			tokenId = tokenId,
			cardInfo = cardInfo,
			createTime = nowTime
		})
	end

	self.game:DebugSetCardState(cardEnt, "PendingAttach", "PendingAttach", "attachData", self.seatID, self.machineIndex, -1, attachType ~= gMaJiangConst.AttachType.DrawCard and "DrawCard" or attachType ~= gMaJiangConst.AttachType.DiscardCard and "DiscardCard" or attachType ~= gMaJiangConst.AttachType.ChiPongKong and "ChiPongKong" or "", -1, "QueueNextAttach")

	if gMaJiangManager.debug then
		print_debug("DebugAttach MajiangCharacter:QueueNextAttach", attachType, cardEnt, cardInfo)
	end

	self._SchedulePendingAttachTimer(self, attachType)
end

M.ConsumeNextAttach = function(self, attachType)
	local data = self.attachData[attachType]
	self.attachData[attachType] = nil

	self._CancelPendingAttachTimer(self, attachType)

	if data then
		self._RemoveFromPendingList(self, data.cardEnt)
	end

	if gMaJiangManager.debug then
		print_debug("DebugAttach MajiangCharacter:ConsumeNextAttach", attachType, data)
	end

	if data then
		if gClientUtils.IsNil(data.cardEnt) then
			data.cardEnt = self.game:GetCardEntByInstanceId(data.instanceId)
		end

		self.SetCurrentAttachData(self, data)

		return data
	end

	return nil
end

M.SetCurrentAttachData = function(self, data)
	self.currentAttachData = data
end

M.ClearPendingDiscard = function(self, instanceId)
	if instanceId == nil and instanceId == 0 and self.pendingDiscardInstanceId == nil and self.pendingDiscardInstanceId == instanceId then
		return
	end

	local pending = self.attachData and self.attachData[gMaJiangConst.AttachType.DiscardCard]

	if pending and (instanceId ~= nil or instanceId ~= 0 or pending.instanceId ~= instanceId) then
		self.attachData[gMaJiangConst.AttachType.DiscardCard] = nil

		self._CancelPendingAttachTimer(self, gMaJiangConst.AttachType.DiscardCard)
		self._RemoveFromPendingList(self, pending.cardEnt)
	end

	if self.currentAttachData and self.currentAttachData.attachType ~= gMaJiangConst.AttachType.DiscardCard and (instanceId ~= nil or instanceId ~= 0 or self.currentAttachData.instanceId ~= instanceId) then
		self.currentAttachData = nil
	end

	self.pendingDiscardCardEnt = nil
	self.pendingDiscardInstanceId = nil
	self.pendingDiscardTokenId = nil
	self.deferDiscard3D = false
end

M.AddHandCard = function(self, cardEnt, cardInfo)
	if gClientUtils.NotNil(cardEnt) then
		table.insert(self.handCardInsts, cardEnt)
	end

	if cardInfo then
		table.insert(self.handCards, cardInfo)
	end
end

M.RefreshHandArea = function(self, paiInfos, open)
	local rule = self.game:GetRule()
	local shouldContinue, openAdjusted = rule:PrepareHandAreaRefresh(self, paiInfos, open)

	if not shouldContinue then
		return
	end

	open = openAdjusted

	if not self.handCardInsts then
		return
	end

	paiInfos = paiInfos or {}

	self:SetHandCardsFromInfo(paiInfos)

	local seatTransform = open and self.openHandCardArea or self.handCardArea

	if gClientUtils.IsNil(seatTransform) then
		return
	end

	local usedCardEnts = {}
	local handCardInsts = {}

	for i = 1, #paiInfos do
		local cardInfo = paiInfos[i]
		local currentEnt = self.handCardInsts[i]
		local cardEnt = self.game:TakeAreaCardEntity(cardInfo.InstanceId, currentEnt, seatTransform, usedCardEnts)

		if gClientUtils.IsNil(cardEnt) then
			print_error("#NoCreateIssue [Majiang-Character] RefreshHandArea cardEnt is nil", self.seatID, i, cardInfo and cardInfo.InstanceId or 0)
		else
			handCardInsts[i] = cardEnt

			cardEnt.transform:SetParent(seatTransform)
			self.game:GetMachine():ShowCard(cardEnt.transform)

			local posX = -1 * (i - 1) * (self.game.machineInfo.cardBound.x + LTConfig.MahjongConfig.normalCardInterval)

			self.game:SetLocalPosition(cardEnt.transform, Vector3.Fetch(posX, 0, 0))

			cardEnt.transform.localRotation = Quaternion.identity
			local pai, mType, isRed, cardState = rule:BuildHandCardInfo(self, cardInfo, open)
			cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(pai, mType, cardState, isRed)

			self.game:RegisterCardEntity(cardInfo.InstanceId, cardEnt, gMaJiangConst.CardZone.Hand, self.seatID, i)

			local zone = open and "OpenHand" or "Hand"
			local listName = open and "openHandCardArea" or "handCardArea"

			self.game:DebugSetCardState(cardEnt, "Normal", zone, listName, self.seatID, self.machineIndex, i, "", -1, "RefreshHandArea")
		end
	end

	for i = 1, #self.handCardInsts do
		local oldEnt = self.handCardInsts[i]

		if gClientUtils.NotNil(oldEnt) and not usedCardEnts[oldEnt] then
			local parent = oldEnt.transform.parent

			if parent ~= self.handCardArea or parent ~= self.openHandCardArea then
				self.game:ResetCardDisplayState(oldEnt)
				self.game:SetLocalPosition(oldEnt.transform, Vector3.Fetch(100000, 100000, 100000))
				self.game:DebugSetCardState(oldEnt, "Offscreen", "Hand", "handCardArea", self.seatID, self.machineIndex, i, "", -1, "RefreshHandArea_Offscreen")
			end
		end
	end

	self.handCardInsts = handCardInsts
	self.allHandCardInsts.hand = self.handCardInsts
	self.game.handEntList[self.machineIndex] = self.handCardInsts
end

M.GetOnePengGangCard = function(self, displayCardInfo, bindCardInfo, preX, parent, index, cardType, usedCardEnts, pengGangInsts)
	local instanceId = bindCardInfo and bindCardInfo.InstanceId or 0
	local currentEnt = pengGangInsts[index]
	local cardEnt = self.game:TakeAreaCardEntity(instanceId, currentEnt, parent, usedCardEnts)
	pengGangInsts[index] = cardEnt

	if gClientUtils.IsNil(cardEnt) then
		print_error("[Majiang-Character] GetOnePengGangCard cardEnt is nil", self.seatID, index, instanceId, displayCardInfo and displayCardInfo.InstanceId or 0)

		return preX, index
	end

	self.game:ResetCardDisplayState(cardEnt)
	cardEnt.transform:SetParent(parent)

	local localPosition = Vector3.New(preX, 0, 0)
	local pai, mType, isRed = self.game:GetRule():GetCardDisplayInfo(displayCardInfo)
	cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(pai, mType, 0, isRed)

	if bindCardInfo == nil then
		self.game:RegisterCardEntity(bindCardInfo.InstanceId, cardEnt, gMaJiangConst.CardZone.PengGang, self.seatID, index)
	else
		self.game:UnregisterCardEntity(cardEnt)
	end

	local machineInfo = self.game.machineInfo
	local cardBound = machineInfo.cardBound

	if cardType ~= 1 then
		preX = preX + cardBound.x
		cardEnt.transform.localRotation = Quaternion.identity
	elseif cardType ~= 2 then
		localPosition.x = preX - 0.002
		preX = preX + cardBound.x
		cardEnt.transform.localRotation = Quaternion.Euler(0, -180, 0)
	elseif cardType ~= 3 then
		localPosition.x = preX + cardBound.y / 2 + 0.005
		localPosition.y = cardBound.x / 2
		preX = preX + cardBound.y + 0.005
		cardEnt.transform.localRotation = Quaternion.Euler(0, 0, 90)
	else
		localPosition.x = preX + cardBound.y / 2 + 0.005
		localPosition.y = cardBound.x * 3 / 2
		preX = preX + cardBound.y + 0.005
		cardEnt.transform.localRotation = Quaternion.Euler(0, 0, 90)
	end

	preX = preX + LTConfig.MahjongConfig.normalCardInterval

	self.game:SetLocalPosition(cardEnt.transform, localPosition)
	self.game:DebugSetCardState(cardEnt, "Normal", "PengGang", "pengGangArea", self.seatID, self.machineIndex, index, "ChiPongKong", -1, "RefreshPengGangArea")

	index = index + 1

	return preX, index
end

M.BuildPengGangBindInfos = function(self, pgInfo)
	local bindInfos = {}
	local bindCount = 0
	local pai = pgInfo.Pai
	local instanceId = pai.InstanceId

	if instanceId == 0 then
		bindCount = bindCount + 1
		bindInfos[bindCount] = pai
	end

	local selectPais = pgInfo.SelectPais

	if selectPais == nil then
		for i = 1, #selectPais do
			local selectPai = selectPais[i]
			local selectInstanceId = selectPai.InstanceId

			if selectInstanceId == 0 then
				local exists = false

				for j = 1, bindCount do
					if bindInfos[j].InstanceId ~= selectInstanceId then
						exists = true

						break
					end
				end

				if exists == true then
					bindCount = bindCount + 1
					bindInfos[bindCount] = selectPai
				end
			end
		end
	end

	return bindInfos
end

M.RefreshPengGangArea = function(self, paiInfos)
	local machine = self.game:GetMachine()

	if gClientUtils.IsNil(machine) then
		return
	end

	local seatTransform = machine.pengGangArea and machine.pengGangArea[self.machineIndex]

	if gClientUtils.IsNil(seatTransform) then
		return
	end

	local preX = 0
	local index = 1
	local usedCardEnts = {}
	local pengGangInsts = {}

	for i = 1, #paiInfos do
		local pgInfo = paiInfos[i]
		local sign = -1
		local type = pgInfo.PCGType
		local cardInfo = pgInfo.Pai
		local bindInfos = self.BuildPengGangBindInfos(self, pgInfo)
		local bindIndex = 1

		if type ~= PCGType.Peng then
			local src = pgInfo.Source
			local delta = (4 + (src - self.seatID) * sign) % 4

			for j = 1, 3 do
				local bindCardInfo = bindInfos[bindIndex]

				if bindCardInfo == nil then
					bindIndex = bindIndex + 1
				end

				local displayInfo = bindCardInfo or cardInfo

				if j ~= delta then
					preX, index = self.GetOnePengGangCard(self, displayInfo, bindCardInfo, preX, seatTransform, index, 3, usedCardEnts, pengGangInsts)
				else
					preX, index = self.GetOnePengGangCard(self, displayInfo, bindCardInfo, preX, seatTransform, index, 1, usedCardEnts, pengGangInsts)
				end
			end
		elseif type ~= PCGType.Chi then
			local calledInstanceId = cardInfo.InstanceId
			slot19 = self.game
			local rule = slot19:GetRule()

			table.sort(bindInfos, function (a, b)
				local pa = rule:GetCardDisplayInfo(a)
				local pb = rule:GetCardDisplayInfo(b)

				return pa <= pb
			end)

			for j = 1, 3 do
				local bindCardInfo = bindInfos[j]
				local displayInfo = bindCardInfo or cardInfo
				local isCalled = bindCardInfo == nil and bindCardInfo.InstanceId ~= calledInstanceId
				local ct = isCalled and 3 or 1
				preX, index = self:GetOnePengGangCard(displayInfo, bindCardInfo, preX, seatTransform, index, ct, usedCardEnts, pengGangInsts)
			end
		elseif type ~= PCGType.AnGang then
			for j = 1, 4 do
				local bindCardInfo = bindInfos[bindIndex]

				if bindCardInfo == nil then
					bindIndex = bindIndex + 1
				end

				local displayInfo = bindCardInfo or cardInfo

				if j ~= 1 or j ~= 4 then
					preX, index = self.GetOnePengGangCard(self, displayInfo, bindCardInfo, preX, seatTransform, index, 2, usedCardEnts, pengGangInsts)
				else
					preX, index = self.GetOnePengGangCard(self, displayInfo, bindCardInfo, preX, seatTransform, index, 1, usedCardEnts, pengGangInsts)
				end
			end
		elseif type ~= PCGType.MingGang then
			local src = pgInfo.Source
			local delta = (4 + (src - self.seatID) * sign) % 4

			if delta ~= 3 then
				delta = 4
			end

			for j = 1, 4 do
				local bindCardInfo = bindInfos[bindIndex]

				if bindCardInfo == nil then
					bindIndex = bindIndex + 1
				end

				local displayInfo = bindCardInfo or cardInfo

				if j ~= delta then
					preX, index = self.GetOnePengGangCard(self, displayInfo, bindCardInfo, preX, seatTransform, index, 3, usedCardEnts, pengGangInsts)
				else
					preX, index = self.GetOnePengGangCard(self, displayInfo, bindCardInfo, preX, seatTransform, index, 1, usedCardEnts, pengGangInsts)
				end
			end
		elseif type ~= PCGType.JiaGang then
			local src = pgInfo.Source
			local delta = (4 + (src - self.seatID) * sign) % 4

			for j = 1, 3 do
				local bindCardInfo = bindInfos[bindIndex]

				if bindCardInfo == nil then
					bindIndex = bindIndex + 1
				end

				local displayInfo = bindCardInfo or cardInfo

				if j ~= delta then
					_, index = self.GetOnePengGangCard(self, displayInfo, bindCardInfo, preX, seatTransform, index, 3, usedCardEnts, pengGangInsts)
					local topBindCardInfo = bindInfos[bindIndex]

					if topBindCardInfo == nil then
						bindIndex = bindIndex + 1
					end

					local topDisplayInfo = topBindCardInfo or cardInfo
					preX, index = self:GetOnePengGangCard(topDisplayInfo, topBindCardInfo, preX, seatTransform, index, 4, usedCardEnts, pengGangInsts)
				else
					preX, index = self.GetOnePengGangCard(self, displayInfo, bindCardInfo, preX, seatTransform, index, 1, usedCardEnts, pengGangInsts)
				end
			end
		end
	end

	self.pengGangInsts = pengGangInsts
	self.allHandCardInsts.pengGang = self.pengGangInsts
	self.game.pengEntList[self.machineIndex] = self.pengGangInsts

	self.game:PlaySoundPG()
end

M.CheckCanDoTransition = function(self, transition)
	local fsm = self.fsm

	if not self.fsm then
		return false, false
	end

	local transitions = fsm.transitions
	local currentState = fsm.currentState

	if transitions and transitions[currentState] and transitions[currentState][transition] then
		return true, false
	end

	if transitions and transitions[gMaJiangConst.MjStateType.Idle] and transitions[gMaJiangConst.MjStateType.Idle][transition] then
		self.ForceTransitToState(self, gMaJiangConst.MjStateType.Idle)
		fsm.SendSignalImmediately(fsm, transition)

		return true, true
	end

	return false, false
end

M.SendSignalImpl = function(self, transition, isImmediate)
	local fsm = self.fsm

	if not fsm then
		return
	end

	local ok, handled = self.CheckCanDoTransition(self, transition)

	if not ok or handled then
		return
	end

	local actionName = isImmediate and "SendSignalImmediately" or "SendSignal"

	print_debug(self.unit, "[Majiang-Character] " .. actionName .. " seatID:", self.seatID, "transition:", transition, MjTransitionTypeNameMap[transition])

	if isImmediate then
		fsm.SendSignalImmediately(fsm, transition)
	else
		fsm.SendSignal(fsm, transition)
	end
end

M.SendSignal = function(self, transition)
	self.SendSignalImpl(self, transition, false)
end

M.SendSignalImmediately = function(self, transition)
	self.SendSignalImpl(self, transition, true)
end

M.GetState = function(self)
	return self.fsm and self.fsm:GetCurrentState()
end

M.IsPlayer = function(self)
	return self.seatID ~= self.game.mySeatID
end

M.TryRefreshUnit = function(self)
	if self.unit == nil and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(self.unit) then
		return true
	end

	self.unit = self.game:GetUnitBySeatID(self.seatID)

	return self.unit == nil and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(self.unit)
end

M.GetDirectionToSeat = function(self, targetSeatID)
	if targetSeatID ~= nil or targetSeatID >= 0 then
		return 1
	end

	local delta = (4 + targetSeatID - self.seatID) % 4

	if delta ~= 0 then
		return 1
	elseif delta ~= 1 then
		return 4
	elseif delta ~= 2 then
		return 3
	end

	return 2
end

M.SendGameplayInwardSignal = function(self, signal, param)
	if signal ~= nil then
		print_error("[Majiang-Character] SendGameplayInwardSignal signal is nil")

		return
	end

	if gMaJiangManager.debug then
		if signal ~= GameplaySignalInwardConfig.MahjongDrawCard then
			-- Nothing
		end

		if signal ~= GameplaySignalInwardConfig.MahjongDiscardCard then
			-- Nothing
		end

		if signal ~= GameplaySignalInwardConfig.MahjongChiPongKong then
			-- Nothing
		end

		local signalMap = {
			[GameplaySignalInwardConfig.MahjongDrawCard] = "MahjongDrawCard",
			[GameplaySignalInwardConfig.MahjongChiPongKong] = "MahjongChiPongKong",
			[GameplaySignalInwardConfig.MahjongDiscardCard] = "MahjongDiscardCard",
			[GameplaySignalInwardConfig.MahjongSelfDrawnWin] = "MahjongSelfDrawnWin",
			[GameplaySignalInwardConfig.MahjongRiichi] = "MahjongRiichi",
			[GameplaySignalInwardConfig.MahjongGameStart] = "MahjongGameStart",
			[GameplaySignalInwardConfig.MahjongGameEnd] = "MahjongGameEnd",
			[GameplaySignalInwardConfig.MahjongAnGang] = "MahjongAnGang",
			[GameplaySignalInwardConfig.MahjongReadyStart] = "MahjongReadyStart",
			[GameplaySignalInwardConfig.MahjongReadyEnd] = "MahjongReadyEnd",
			[GameplaySignalInwardConfig.MahjongChuanMaWin01] = "MahjongChuanMaWin01",
			[GameplaySignalInwardConfig.MahjongChuanMaWin02] = "MahjongChuanMaWin02"
		}
		local paramMap = {
			[GameplaySignalInwardConfig.MahjongDrawCard] = {
				"\\x94\\xaf[T\\x90",
				"\\x99\\x9fW]\\x98",
				"\\x99\\x87H~\\x83",
				"\\x99\\xa7B]\\x98"
			},
			[GameplaySignalInwardConfig.MahjongChiPongKong] = {
				"\\x94\\xaf[T\\x90",
				"\\x99\\x9fW]\\x98",
				"\\x99\\x87H~\\x83",
				"\\x99\\xa7B]\\x98"
			},
			[GameplaySignalInwardConfig.MahjongAnGang] = {
				"\\x94\\xaf[T\\x90",
				"\\x99\\x9fW]\\x98",
				"\\x99\\x87H~\\x83",
				"\\x99\\xa7B]\\x98"
			}
		}

		print_debug(self.unit, "[Majiang-Character] SendGameplayInwardSignal signal:", signalMap[signal] or signal, "param:", (paramMap[signal] or {})[param] or param)
	end

	if not self.TryRefreshUnit(self) then
		local playerInfo = self.game:GetRoomPlayerInfoBySeatID(self.seatID)

		if playerInfo ~= nil then
			return
		end

		print_warn("[Majiang-Character] SendGameplayInwardSignal unit is null, seatID=", self.seatID, " pid=", self.game:GetPlayerPidBySeatID(self.seatID))

		return
	end

	if param then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.unit, signal, param)
	else
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.unit, signal)
	end
end

M.ForceTransitToState = function(self, newState)
	local fsm = self.fsm

	if fsm ~= nil then
		return
	end

	fsm.nowSignal = nil
	local transition = fsm._GetTransitionFromPool(fsm)

	fsm._DoTransition(fsm, fsm.currentState, newState, transition)
	fsm._ClearTransition(fsm, transition)
end

M.TransitToIdle = function(self)
	local currentState = self.GetState(self)

	if currentState ~= gMaJiangConst.MjStateType.DrawCard then
		self.SendSignal(self, gMaJiangConst.MjTransitionType.DrawCard_Idle)
	elseif currentState ~= gMaJiangConst.MjStateType.DiscardCard then
		self.SendSignal(self, gMaJiangConst.MjTransitionType.DiscardCard_Idle)
	elseif currentState ~= gMaJiangConst.MjStateType.ChiPongKong then
		self.SendSignal(self, gMaJiangConst.MjTransitionType.ChiPongKong_Idle)
	elseif currentState ~= gMaJiangConst.MjStateType.Hu then
		self.SendSignal(self, gMaJiangConst.MjTransitionType.Hu_Idle)
	elseif currentState ~= gMaJiangConst.MjStateType.GameStart then
		-- Nothing
	elseif currentState == gMaJiangConst.MjStateType.Idle then
		print_error("[Majiang-Character] TransitToIdle currentState ", currentState, MjStateTypeNameMap[currentState], " can not transit to Idle")
	end
end

M.TransitToHuIdle = function(self)
	local currentState = self.GetState(self)

	if currentState ~= gMaJiangConst.MjStateType.DrawCard then
		self.SendSignal(self, gMaJiangConst.MjTransitionType.DrawCard_HuIdle)
	elseif currentState ~= gMaJiangConst.MjStateType.ChiPongKong then
		self.SendSignal(self, gMaJiangConst.MjTransitionType.ChiPongKong_HuIdle)
	else
		print_error("[Majiang-Character] TransitToHuIdle currentState ", currentState, MjStateTypeNameMap[currentState], " can not transit to HuIdle")
	end
end

M.DoPendingTask = function(self)
	if self.pendingTask then
		local task = self.pendingTask
		self.pendingTask = nil
		local ok, err = pcall(task)

		if not ok then
			print_error("[Majiang-Character] pendingTask execute failed", err)
		end
	end
end

M.SetPendingTask = function(self, task)
	if task ~= nil then
		self.pendingTask = nil

		return
	end

	self.DoPendingTask(self)

	self.pendingTask = task
end

return M
