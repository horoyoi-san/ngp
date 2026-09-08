-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangGame_Action.lua
-- Decompiled from: 00341_MajiangGame_Action.lua_90f90ccf3798.luajit

local M = C_MajiangGame
local GameStateEnum = UX.Game.MjGameStateEnum
local ABPVarConfig = LTConfig.ABPVarConfig
local MjSeatRef = require("LX6/Gameplay/Majiang/MjSeatRef")

M.InitCharacterFSMs = function(self)
	if self.characterFSMs then
		self.DisposeCharacterFSMs(self)
	end

	self.characters = self.characters or {}
	self.characterFSMs = self.characters
	self.fsmDisposed = false

	for seatID = 0, 3 do
		local character = self.GetOrCreateCharacter(self, seatID)

		if character == nil then
			local playerInfo = self.GetRoomPlayerInfoBySeatID(self, seatID)

			character.SetPlayerInfo(character, playerInfo)
			character.EnsureUnit(character)
			character.InitFSM(character)
			self.RefreshHandArea(self, seatID, self.serverGameInfo.SeatInfos[seatID + 1].Holds, false)
		end
	end

	self.ResetNonRealPlayerUnitsToSeatTransforms(self)

	self.myFSM = self.characterFSMs[self.mySeatID]
end

M.ResetNonRealPlayerUnitsToSeatTransforms = function(self)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) then
		return
	end

	for seatID = 0, 3 do
		local character = self.GetCharacter(self, seatID)

		if character == nil and character.IsNonRealPlayer(character) then
			character.MoveToSeat(character)
		end
	end
end

M.DisposeCharacterFSMs = function(self)
	local characters = self.characters or self.characterFSMs

	if characters then
		for _, v in pairs(characters) do
			v.StopAIPlayerBindCo(v)
			v.StopSeatLock(v)
			v.DisposeFSM(v)
		end
	end

	self.characterFSMs = nil
	self.myFSM = nil
	self.fsmDisposed = true
end

M.GetCharacterFSM = function(self, seatID)
	return self.GetCharacter(self, seatID)
end

M.SendFSMSignal = function(self, seatID, transition)
	local fsm = self.GetCharacterFSM(self, seatID)

	fsm.SendSignal(fsm, transition)
end

M.SendFSMSignalImmediately = function(self, seatID, transition)
	local fsm = self.GetCharacterFSM(self, seatID)

	fsm.SendSignalImmediately(fsm, transition)
end

M.GetUnitBySeatID = function(self, seatID)
	local character = self.GetCharacter(self, seatID)

	if character == nil then
		local unit = character.GetUnit(character)

		if unit == nil then
			return unit
		end
	end

	local pid = self.GetUnitPidBySeatID(self, seatID)

	if pid ~= nil then
		return nil
	end

	return self.GetUnitByPid(self, pid)
end

M.IK_TryGetVMotionTarget = function(self, key, pid)
	local seatID = self.GetSeatIDByPid(self, pid)

	if seatID ~= nil then
		print_warn("[Majiang-Manager] IK_TryGetVMotionTarget seatID not found", pid)

		return nil
	end

	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) then
		return nil
	end

	local charFSM = self:GetCharacterFSM(seatID)
	local sd = charFSM and charFSM.stateData

	if sd ~= nil then
		return nil
	end

	if key == gMaJiangConst.IKTargetKey.MajiangCardPos and key == gMaJiangConst.IKTargetKey.MajiangHandCardAreaRightPos and key == gMaJiangConst.IKTargetKey.MajiangCardTargetPos then
		print_error("[Majiang-Manager] IK_TryGetVMotionTarget not supported key=", key)

		return nil
	end

	if self.ikInitialPos ~= nil then
		self.ikInitialPos = Vector3.zero
	end

	local initialPos = self.ikInitialPos

	if key ~= gMaJiangConst.IKTargetKey.MajiangCardPos then
		if sd.cardPosition ~= nil then
			return nil
		end

		initialPos = sd.cardPosition
	elseif key ~= gMaJiangConst.IKTargetKey.MajiangCardTargetPos then
		if sd.targetIkPos ~= nil then
			return nil
		end

		initialPos = sd.targetIkPos
	elseif key ~= gMaJiangConst.IKTargetKey.MajiangHandCardAreaRightPos and sd.handCardCount ~= nil then
		return nil
	end

	local debug = self:IsDebugEnabled()
	local ok, result = machine:SolveIKTarget(pid, key, seatID, initialPos, sd.handCardCount or 0, sd.discardIndex or 0, sd.wallDirection or 0, sd.wallPileIndex or 0, sd.drawSeatID or 0, sd.sourceDirection or 0, debug, nil)

	if not ok then
		return nil
	end

	if debug then
		local keyName = key ~= gMaJiangConst.IKTargetKey.MajiangCardPos and "MajiangCardPos" or key ~= gMaJiangConst.IKTargetKey.MajiangHandCardAreaRightPos and "MajiangHandCardAreaRightPos" or "MajiangCardTargetPos"

		print_debug("[Majiang-Manager] IK_TryGetVMotionTarget, key=", keyName, key, "pid", pid, "result", result)
	end

	self:DebugDrawSphere(result, Color.New(key ~= gMaJiangConst.IKTargetKey.MajiangCardPos and 1 or 0, key ~= gMaJiangConst.IKTargetKey.MajiangHandCardAreaRightPos and 1 or 0, key ~= gMaJiangConst.IKTargetKey.MajiangCardTargetPos and 1 or 0, 1), 0)

	return result
end

M.RemoveCardFromList = function(self, list, cardEnt)
	if list ~= nil or gClientUtils.IsNil(cardEnt) then
		return false
	end

	for i = #list, 1, -1 do
		if list[i] ~= cardEnt then
			table.remove(list, i)

			return true
		end
	end

	return false
end

M.HasCardInList = function(self, list, cardEnt)
	if list ~= nil or gClientUtils.IsNil(cardEnt) then
		return false
	end

	for i = 1, #list do
		if list[i] ~= cardEnt then
			return true
		end
	end

	return false
end

M.GetCardEntFromAttachData = function(self, data)
	local cardEnt = self:GetCardEntByInstanceId(data and data.instanceId)

	return gClientUtils.NotNil(cardEnt) and cardEnt or nil
end

M.FinishDrawCard = function(self, seatID, data)
	local charFSM = self.GetCharacterFSM(self, seatID)

	if not charFSM or data ~= nil then
		return
	end

	local instanceId = data.instanceId
	local tokenId = data.tokenId

	if tokenId ~= nil then
		print_error("[Majiang-Manager] FinishDrawCard tokenId is nil", seatID, instanceId)

		return
	end

	local cardEnt = self.GetCardEntFromAttachData(self, data)

	if gClientUtils.IsNil(cardEnt) then
		print_error("[Majiang-Manager] FinishDrawCard cardEnt is nil", seatID)

		return
	end

	if self.cardMgr:TryAdvance(instanceId, tokenId, gMaJiangConst.CardStage.Settled, gMaJiangConst.CardZone.Hand, {
		["\\xad\\xbd\n\\xbc^'\\xee6"] = "^0|L",
		cardEnt = cardEnt,
		ownerSeatID = seatID
	}) == true then
		return
	end

	local seatRef = MjSeatRef:FromId(seatID)
	local handList = charFSM.handCardInsts

	if handList ~= nil then
		handList = {}
		charFSM.handCardInsts = handList

		if self.handEntList == nil then
			self.handEntList[seatRef.machineIndex] = handList
		end
	end

	while self.RemoveCardFromList(self, handList, cardEnt) do
	end

	local targetIndex = #handList + 1

	table.insert(handList, cardEnt)

	local machine = self:GetMachine()
	local seatTransform = machine and machine.handCardArea and machine.handCardArea[seatRef.machineIndex]

	if gClientUtils.NotNil(seatTransform) then
		cardEnt.transform:SetParent(seatTransform)

		local posX = -1 * (targetIndex - 1) * (self.machineInfo.cardBound.x + LTConfig.MahjongConfig.normalCardInterval)

		self:SetLocalPosition(cardEnt.transform, Vector3.Fetch(posX, 0, 0))

		cardEnt.transform.localRotation = Quaternion.identity

		self:DebugSetCardState(cardEnt, "Normal", "Hand", "handEntList", seatID, seatRef.machineIndex, targetIndex, "DrawCard", -1, "FinishDrawCard")
	end

	self:RegisterCardEntity(instanceId, cardEnt, gMaJiangConst.CardZone.Hand, seatID, targetIndex)
	self.cardMgr:TryAdvance(instanceId, tokenId, gMaJiangConst.CardStage.Finalized, gMaJiangConst.CardZone.Hand, {
		["\\xad\\xbd\n\\xbc^'\\xee6"] = "^0|L",
		cardEnt = cardEnt,
		ownerSeatID = seatID,
		slotIndex = targetIndex
	})

	if data.cardInfo then
		local hasInfo = false

		for i = 1, #charFSM.handCards do
			local handCardInfo = charFSM.handCards[i]

			if handCardInfo ~= data.cardInfo or handCardInfo and handCardInfo.InstanceId ~= data.instanceId then
				hasInfo = true

				break
			end
		end

		if not hasInfo then
			table.insert(charFSM.handCards, data.cardInfo)
		end
	end

	self.RefreshHandArea(self, seatID, charFSM.handCards, false)

	if seatID ~= self.mySeatID then
		self:RefreshMyHandDisplayList(false)
		self:GetMainPanelNullableCall():RefreshHandCardsBySeatID(seatID)

		if self.pendingGangMoPai then
			self.pendingGangMoPai = false

			self:GetMainPanelNullableCall():TryShowTurnTips()
		end
	end
end

M.FinishDiscardCard = function(self, seatID, data, force, reason)
	local charFSM = self.GetCharacterFSM(self, seatID)

	if not charFSM or data ~= nil then
		return
	end

	if force == true and charFSM.deferDiscard3D == true then
		return
	end

	local instanceId = data.instanceId
	local tokenId = data.tokenId

	if tokenId ~= nil then
		print_error("[Majiang-Manager] FinishDiscardCard tokenId is nil", seatID, instanceId)
		charFSM.ClearPendingDiscard(charFSM, instanceId)

		return
	end

	local cardEnt = self:GetCardEntFromAttachData(data) or charFSM.pendingDiscardCardEnt

	if gClientUtils.IsNil(cardEnt) then
		return
	end

	if self.cardMgr:TryAdvance(instanceId, tokenId, gMaJiangConst.CardStage.Settled, gMaJiangConst.CardZone.Discard, {
		["\\xad\\xbd\n\\xbc^'\\xee6"] = "\\xfd\\xd26\\xf5",
		cardEnt = cardEnt,
		ownerSeatID = seatID
	}) == true then
		if charFSM.pendingDiscardTokenId ~= tokenId and charFSM.pendingDiscardInstanceId ~= instanceId then
			charFSM.ClearPendingDiscard(charFSM, instanceId)
		end

		return
	end

	local seatRef = MjSeatRef:FromId(seatID)
	local handList = self.handEntList and self.handEntList[seatRef.machineIndex]

	self:RemoveCardFromList(handList, cardEnt)

	local discardEntList = self.discardEntList and self.discardEntList[seatRef.machineIndex]

	if discardEntList then
		local discardIndex = #discardEntList + 1

		if discardEntList[discardIndex] and discardEntList[discardIndex] == cardEnt then
			print_error("[Majiang-Manager] FinishDiscardCard discard slot occupied by another cardEnt", seatID, discardIndex, instanceId)
		end

		discardEntList[discardIndex] = cardEnt
		local machine = self:GetMachine()
		local discardArea = machine and machine.discardArea and machine.discardArea[seatRef.machineIndex]

		if gClientUtils.NotNil(discardArea) then
			cardEnt.transform:SetParent(discardArea)

			if gClientUtils.NotNil(machine) then
				machine.ShowCard(machine, cardEnt.transform)
			end

			self:ApplyDiscardSlotTransform(seatRef.machineIndex, discardIndex, cardEnt.transform)
			self:DebugSetCardState(cardEnt, "Normal", "Discard", "discardEntList", seatID, seatRef.machineIndex, discardIndex, "DiscardCard", -1, reason or "FinishDiscardCard")
			self:RegisterCardEntity(instanceId, cardEnt, gMaJiangConst.CardZone.Discard, seatID, discardIndex)
			self.cardMgr:TryAdvance(instanceId, tokenId, gMaJiangConst.CardStage.Finalized, gMaJiangConst.CardZone.Discard, {
				["\\xad\\xbd\n\\xbc^'\\xee6"] = "\\xfd\\xd26\\xf5",
				cardEnt = cardEnt,
				ownerSeatID = seatID,
				slotIndex = discardIndex
			})
		end
	end

	if charFSM.pendingDiscardTokenId ~= tokenId and charFSM.pendingDiscardInstanceId ~= instanceId then
		charFSM.ClearPendingDiscard(charFSM, instanceId)
	end

	self:GetMainPanelNullableCall():RefreshOutCardsBySeatID(seatID)
end

M.FinishAttach = function(self, attachType, seatID, data, force, reason)
	if force then
		print_debug("[Majiang-Manager] force FinishAttach ", attachType, " reason", reason)
	end

	if attachType ~= gMaJiangConst.AttachType.DrawCard then
		self.FinishDrawCard(self, seatID, data)
	elseif attachType ~= gMaJiangConst.AttachType.DiscardCard then
		self.FinishDiscardCard(self, seatID, data, force, reason)
	elseif attachType ~= gMaJiangConst.AttachType.ChiPongKong then
		self.FinishChiPongKong(self, seatID, data)
	end

	if force then
		local charFSM = self.GetCharacterFSM(self, seatID)

		if charFSM then
			charFSM.TransitToIdle(charFSM)
		end
	end
end

M.FinishChiPongKong = function(self, seatID, data)
	local charFSM = self.GetCharacterFSM(self, seatID)

	if not charFSM or data ~= nil then
		return
	end

	local instanceId = data.instanceId
	local tokenId = data.tokenId

	if tokenId ~= nil then
		print_error("[Majiang-Manager] FinishChiPongKong tokenId is nil", seatID, instanceId)

		return
	end

	local cardEnt = self:GetCardEntFromAttachData(data)

	if self.cardMgr:TryAdvance(instanceId, tokenId, gMaJiangConst.CardStage.Settled, gMaJiangConst.CardZone.PengGang, {
		["\\xad\\xbd\n\\xbc^'\\xee6"] = "\\xbc<)w\\x93F\\xf28\\xa4\\xbe",
		cardEnt = cardEnt,
		ownerSeatID = seatID,
		sourceSeatID = data.sourceSeatID
	}) == true then
		return
	end

	if gClientUtils.NotNil(cardEnt) then
		local seatRef = MjSeatRef:FromId(seatID)
		local handList = self.handEntList and self.handEntList[seatRef.machineIndex]

		self:RemoveCardFromList(handList, cardEnt)

		if self.discardEntList then
			for i = 0, 3 do
				local discardEntList = self.discardEntList[i]

				if self.RemoveCardFromList(self, discardEntList, cardEnt) then
					break
				end
			end
		end

		local pengList = self.pengEntList and self.pengEntList[seatRef.machineIndex]

		if pengList and not self.HasCardInList(self, pengList, cardEnt) then
			local insertIndex = 1

			while pengList[insertIndex] == nil do
				insertIndex = insertIndex + 1
			end

			pengList[insertIndex] = cardEnt
		end
	end

	local info = self.serverGameInfo and self.serverGameInfo.SeatInfos and self.serverGameInfo.SeatInfos[seatID + 1]

	if info then
		self.RefreshPengGangArea(self, seatID, info.Sequence)
	end

	local seatRef = MjSeatRef:FromId(seatID)
	local machineIndex = seatRef and seatRef.machineIndex or -1
	local insertIndex = 1
	local pengList = self.pengEntList and self.pengEntList[machineIndex]

	if pengList and gClientUtils.NotNil(cardEnt) then
		for i = 1, #pengList do
			if pengList[i] ~= cardEnt then
				insertIndex = i

				break
			end
		end
	end

	if pengList and insertIndex ~= 1 and pengList[insertIndex] == cardEnt then
		while pengList[insertIndex] == nil do
			insertIndex = insertIndex + 1
		end
	end

	if gClientUtils.NotNil(cardEnt) then
		self:DebugSetCardState(cardEnt, "Normal", "PengGang", "pengEntList", seatID, machineIndex, insertIndex, "ChiPongKong", -1, "FinishChiPongKong")
		self:RegisterCardEntity(instanceId, cardEnt, gMaJiangConst.CardZone.PengGang, seatID, insertIndex)
		self.cardMgr:TryAdvance(instanceId, tokenId, gMaJiangConst.CardStage.Finalized, gMaJiangConst.CardZone.PengGang, {
			["\\xad\\xbd\n\\xbc^'\\xee6"] = "\\xbc<)w\\x93F\\xf28\\xa4\\xbe",
			cardEnt = cardEnt,
			ownerSeatID = seatID,
			slotIndex = insertIndex
		})
	end

	self.RefreshHandArea(self, seatID, charFSM.handCards, false)
end

M.FinishAllPendingAttaches = function(self, reason)
	for seatID = 0, 3 do
		local charFSM = self.GetCharacterFSM(self, seatID)

		if charFSM and charFSM.attachData then
			for attachType, data in pairs(charFSM.attachData) do
				charFSM.attachData[attachType] = nil

				charFSM._CancelPendingAttachTimer(charFSM, attachType)
				charFSM._RemoveFromPendingList(charFSM, data.cardEnt)
				self.FinishAttach(self, attachType, seatID, data, true, reason)
			end
		end
	end
end

M.GetAttachTaskContext = function(self, pid, taskName, attachType)
	local unit = self:GetUnitByPid(pid)
	local seatID = self:GetSeatIDByPid(pid)
	local playerInfo = seatID and self:GetRoomPlayerInfoBySeatID(seatID)
	local playerName = playerInfo and playerInfo.Name

	if not unit then
		print_error(("[Majiang-Manager] %s unit not found"):format(taskName), pid)

		return
	end

	local charFSM = seatID and self:GetCharacterFSM(seatID)

	if self:IsDebugEnabled() then
		print_debug(("[Majiang-Manager] DebugAttach %s"):format(taskName), pid, playerName, attachType)
	end

	if attachType and attachType ~= 0 then
		print_error(("[Majiang-Manager] %s attachType is invalid"):format(taskName), pid, playerName)

		return
	end

	return unit, seatID, charFSM
end

M.StateTreeTask_MahjongAddCardToHandTask = function(self, pid, attachType)
	local unit, seatID, charFSM = self.GetAttachTaskContext(self, pid, "AddCardToHandTask", attachType)

	if not unit then
		return
	end

	local data = charFSM and charFSM:ConsumeNextAttach(attachType)

	if not data then
		local cardTransformFallback = charFSM and charFSM.stateData and charFSM.stateData.cardTransform
		local machine = self:GetMachine()
		local cardPath = cardTransformFallback and gUtils.GetFindPath(cardTransformFallback, machine) or "nil"

		print_warn("[Majiang-Manager] MahjongAddCardToHandTask ConsumeNextAttach not found", pid, attachType, cardPath)

		return
	end

	local instanceId = data.instanceId
	local tokenId = data.tokenId

	if tokenId ~= nil then
		print_error("[Majiang-Manager] MahjongAddCardToHandTask tokenId is nil", pid, instanceId, attachType)

		if charFSM and charFSM.currentAttachData ~= data then
			charFSM.SetCurrentAttachData(charFSM, nil)
		end

		return
	end

	local cardEnt = self:GetCardEntFromAttachData(data)

	if self.cardMgr:TryAdvance(instanceId, tokenId, gMaJiangConst.CardStage.Action, gMaJiangConst.CardZone.HandR, {
		cardEnt = cardEnt,
		ownerSeatID = seatID,
		flowType = attachType ~= gMaJiangConst.AttachType.DrawCard and "Draw" or attachType ~= gMaJiangConst.AttachType.DiscardCard and "Discard" or "ChiPongKong"
	}) == true then
		if charFSM and charFSM.currentAttachData ~= data then
			charFSM.SetCurrentAttachData(charFSM, nil)
		end

		return
	end

	data.cardEnt = cardEnt
	local cardTransform = gClientUtils.NotNil(cardEnt) and cardEnt.transform or charFSM and charFSM.stateData and charFSM.stateData.cardTransform

	if gClientUtils.IsNil(cardTransform) then
		print_error("[Majiang-Manager] MahjongAddCardToHandTask cardTransform is nil", pid, attachType)

		return
	end

	if self.IsDebugEnabled(self) and (charFSM ~= nil or charFSM.stateData ~= nil or gClientUtils.IsNil(charFSM.stateData.cardTransform)) and gClientUtils.NotNil(cardEnt) then
		print_debug("[Majiang-Manager] DebugAttach AddCardToHandTask fallback to currentAttachData.cardEnt.transform", pid, attachType)
	end

	local handR = unit.ModelSlot and unit.ModelSlot.handr

	if gClientUtils.IsNil(handR) then
		return
	end

	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) then
		return
	end

	cardTransform:SetParent(handR)

	local posOffset, rotOffset = machine:GetAttachConfig(pid, nil, )

	self:SetLocalPosition(cardTransform, posOffset)

	cardTransform.localRotation = rotOffset
	local seatRef = seatID and MjSeatRef:FromId(seatID)
	local machineIndex = seatRef and seatRef.machineIndex or -1
	local attachTypeName = attachType ~= gMaJiangConst.AttachType.DrawCard and "DrawCard" or attachType ~= gMaJiangConst.AttachType.DiscardCard and "DiscardCard" or attachType ~= gMaJiangConst.AttachType.ChiPongKong and "ChiPongKong" or "NotDefined"

	if gClientUtils.NotNil(cardTransform) then
		self:DebugSetCardState(cardTransform:GetComponent(typeof(L18.Mahjong.MahjongCard)), "CurrentAttach", "HandR", "currentAttachData", seatID or -1, machineIndex, -1, attachTypeName, -1, "MahjongAddCardToHandTask")
	end

	self.DebugDrawSphere(self, cardTransform.position, Color.yellow, 0.2)

	if data.attachType ~= gMaJiangConst.AttachType.DrawCard then
		machine.ShowCard(machine, cardTransform)

		return
	end

	if charFSM and charFSM.pendingChiPongKong and #charFSM.pendingChiPongKong <= 0 then
		charFSM.pendingChiPongKong = {}
	end
end

M.StateTreeTask_MahjongStartMeldTask = function(self, pid)
	local unit, seatID, charFSM = self.GetAttachTaskContext(self, pid, "StateTreeTask_MahjongStartMeldTask")

	if charFSM then
		charFSM.ConsumeNextAttach(charFSM, gMaJiangConst.AttachType.ChiPongKong)
	end
end

M.StateTreeTask_MahjongDetachCardFromHandTask = function(self, pid, attachType)
	local unit, seatID, charFSM = self.GetAttachTaskContext(self, pid, "DetachCardFromHandTask", attachType)

	if not unit then
		return
	end

	local data = charFSM and charFSM.currentAttachData
	local cardEnt = self:GetCardEntFromAttachData(data)
	local cardTransform = gClientUtils.NotNil(cardEnt) and cardEnt.transform or charFSM and charFSM.stateData and charFSM.stateData.cardTransform

	if gClientUtils.IsNil(cardTransform) then
		print_warn("[Majiang-Manager] MahjongDetachCardFromHandTask cardTransform is nil", pid, attachType)

		return
	end

	if self.IsDebugEnabled(self) and data and gClientUtils.NotNil(cardEnt) and (charFSM ~= nil or charFSM.stateData ~= nil or gClientUtils.IsNil(charFSM.stateData.cardTransform)) then
		print_debug("[Majiang-Manager] DebugAttach DetachCardFromHandTask fallback to currentAttachData.cardEnt.transform", pid, attachType)
	end

	self.DebugDrawSphere(self, cardTransform.position, Color.yellow, 0.2)

	if data ~= nil or attachType == data.attachType then
		local machine = self:GetMachine()
		local cardPath = cardTransform and gUtils.GetFindPath(cardTransform, machine) or "nil"

		print_warn("[Majiang-Manager] MahjongDetachCardFromHandTask currentAttachData is nil", pid, cardPath)

		return
	end

	self.FinishAttach(self, attachType, seatID, data)
	charFSM.SetCurrentAttachData(charFSM, nil)
end

M.StateTreeTask_MahjongHideHandCardsTask = function(self, pid)
	local seatID = self:GetSeatIDByPid(pid)
	local charFSM = self:GetCharacterFSM(seatID)
	local currentAttachData = charFSM and charFSM.currentAttachData
	local currentEnt = self:GetCardEntFromAttachData(currentAttachData)

	if gClientUtils.IsNil(currentEnt) then
		return
	end

	self:DebugSetCardState(currentEnt, "Hidden", "Hidden", "currentAttachData", seatID or -1, charFSM and charFSM.machineIndex or -1, -1, currentAttachData and currentAttachData.attachType or "", -1, "HideHandCardsTask")
	currentEnt.gameObject:SetActive(false)
end

M.StateTreeTask_MahjongShowHandCardsTask = function(self, pid)
	local seatID = self:GetSeatIDByPid(pid)
	local charFSM = self:GetCharacterFSM(seatID)
	local currentAttachData = charFSM and charFSM.currentAttachData
	local currentEnt = self:GetCardEntFromAttachData(currentAttachData)

	if gClientUtils.IsNil(currentEnt) then
		return
	end

	self:DebugSetCardState(currentEnt, "CurrentAttach", "HandR", "currentAttachData", seatID or -1, charFSM and charFSM.machineIndex or -1, -1, currentAttachData and currentAttachData.attachType or "", -1, "ShowHandCardsTask")
	currentEnt.gameObject:SetActive(true)
end

M.StateTreeTask_MahjongMoveActionCardsTask = function(self, pid)
	self.StateTreeTask_MahjongShowHandCardsTask(self, pid)
	self.StateTreeTask_MahjongDetachCardFromHandTask(self, pid, gMaJiangConst.AttachType.ChiPongKong)
end

M.StateTreeTask_MahjongSortHandCardTask = function(self, pid)
	if self.gameState ~= GameStateEnum.Over then
		return
	end

	local unit = self.GetUnitByPid(self, pid)
	local seatID = self.GetSeatIDByPid(self, pid)

	if unit ~= nil or seatID ~= nil then
		return
	end

	local gameInfo = self.serverGameInfo

	if gameInfo then
		local info = gameInfo.SeatInfos[seatID + 1]

		if info then
			local fsm = self:GetCharacterFSM(seatID)
			local handData = fsm and #fsm.handCards <= 0 and fsm.handCards or info.Holds

			self:RefreshHandArea(seatID, handData, false)
		end
	end

	if seatID ~= self.mySeatID then
		self:RefreshMyHandDisplayList(true)
		self:GetMainPanelNullableCall():RefreshHandCardsBySeatID(seatID)
	end
end

M.StateTreeTask_ProcessOutwardSignal = function(self, data)
	if self.fsmDisposed then
		return
	end

	local pid = data.GetPid(data)
	local seatID = self.GetSeatIDByPid(self, pid)

	if seatID ~= nil then
		print_debug("[Majiang-Manager] ProcessOutwardSignal unit not found", pid)

		return
	end

	local fsm = self.GetCharacterFSM(self, seatID)
	local signal = data.GetCfgId(data)

	if signal ~= LTConfig.GameplaySignalOutwardConfig.MahjongIdle then
		if fsm then
			fsm.TransitToIdle(fsm)
		else
			print_error("#NoCreateIssue [Majiang-Manager] ProcessOutwardSignal MahjongIdle fsm not found")
		end
	elseif signal ~= LTConfig.GameplaySignalOutwardConfig.MahjongHuChoice then
		if fsm then
			fsm.TransitToHuIdle(fsm)
		else
			print_error("#NoCreateIssue [Majiang-Manager] ProcessOutwardSignal MahjongHuChoice fsm not found")
		end
	elseif signal ~= LTConfig.GameplaySignalOutwardConfig.MahjongEnterDiscardCard then
		local unit = fsm and fsm.unit

		if unit and fsm.stateData and fsm.stateData.blendX then
			gCS.AnimationManager.SetAnimatorParams(unit, fsm.stateData.blendX)
		else
			print_warn("[Majiang-Manager] ProcessOutwardSignal MahjongEnterDiscardCard fsm stateData not found", fsm and fsm.stateData)
		end
	elseif signal ~= LTConfig.GameplaySignalOutwardConfig.MahjongEnterDrawCard then
		local unit = fsm and fsm.unit

		if unit and fsm.stateData and fsm.stateData.blendX then
			gCS.AnimationManager.SetAnimatorParams(unit, fsm.stateData.blendX)
		else
			print_warn("[Majiang-Manager] ProcessOutwardSignal MahjongEnterDrawCard fsm stateData not found", fsm and fsm.stateData)
		end
	elseif signal == LTConfig.GameplaySignalOutwardConfig.MahjongReadyStartDone then
		if signal == LTConfig.GameplaySignalOutwardConfig.MahjongReadyEndDone then
			print_error("[Majiang-Manager] ProcessOutwardSignal not supported signal=", signal)
		end
	end
end

M.SetActionIsHu = function(self, pid, value)
	local unit = self.GetUnitByPid(self, pid)

	if unit then
		MuGenStates.Logic.ABPVarManager.SetBool(unit, ABPVarConfig.IsMahjongHu, value)
	else
		print_error("[Majiang-Manager] unit not found", pid)
	end
end

M.FSM_TriggerDrawCard = function(self, seatID, instanceId, wallDirection, wallPileIndex)
	local fsm = self.GetCharacterFSM(self, seatID)
	local nextCard = self.GetCardEntByInstanceId(self, instanceId)

	if gClientUtils.IsNil(nextCard) and fsm and fsm.attachData then
		local pending = fsm.attachData[gMaJiangConst.AttachType.DrawCard]
		nextCard = pending and (self.GetCardEntByInstanceId(self, pending.instanceId) or pending.cardEnt)
	end

	if gClientUtils.IsNil(nextCard) then
		print_error("[Majiang-Manager] FSM_TriggerDrawCard no pending.cardEnt")

		return
	end

	local cardTransform = nextCard.transform
	local absoluteDirection = wallDirection or -1

	if absoluteDirection < 0 then
		local machine = self.GetMachine(self)
		absoluteDirection = gClientUtils.NotNil(machine) and machine.GetNextCardInWallDirection(machine) or -1
	end

	local direction = 1

	if absoluteDirection <= 0 then
		direction = fsm.GetDirectionToSeat(fsm, absoluteDirection - 1)
	end

	fsm.DoDrawCard(fsm, cardTransform, direction, seatID, absoluteDirection, wallPileIndex)
end

M.FSM_TriggerChiPongKong = function(self, seatID, isFromOutCard, instanceId, sourceSeatID, cardPosition, signalActionType)
	local cardEnt = self.GetCardEntByInstanceId(self, instanceId)

	if isFromOutCard then
		if not cardEnt then
			local fromSeatID = sourceSeatID == nil and sourceSeatID > 0 and sourceSeatID or self.turnSeatId

			if fromSeatID == nil and fromSeatID > 0 then
				local fromRef = MjSeatRef:FromId(fromSeatID)
				cardEnt = self.discardEntList and self.discardEntList[fromRef.machineIndex] and self.discardEntList[fromRef.machineIndex][#self.discardEntList[fromRef.machineIndex]]
			end
		end
	else
		local seatRef = MjSeatRef:FromId(seatID)
		cardEnt = self.handEntList and self.handEntList[seatRef.machineIndex] and self.handEntList[seatRef.machineIndex][#self.handEntList[seatRef.machineIndex]]
	end

	local finalCardPosition = cardPosition
	local state = self.GetCardStateByInstanceId(self, instanceId)

	if finalCardPosition ~= nil and state and state.plannedWorldPos == nil then
		finalCardPosition = state.plannedWorldPos
	end

	if finalCardPosition ~= nil and gClientUtils.NotNil(cardEnt) then
		finalCardPosition = cardEnt.transform.position
	end

	self:GetCharacterFSM(seatID):DoChiPongKong(cardEnt and cardEnt.transform, isFromOutCard, sourceSeatID, finalCardPosition, signalActionType)
end

M.FSM_TriggerDiscardCard = function(self, seatID, handCardIndex, instanceId, fromUI, cardInfo, tokenId)
	local charFSM = self.GetCharacterFSM(self, seatID)

	if not charFSM then
		return
	end

	if tokenId ~= nil then
		print_error("[Majiang-Manager] FSM_TriggerDiscardCard tokenId is nil", seatID, instanceId)

		return
	end

	local cardEnt = self.GetCardEntByInstanceId(self, instanceId)

	if gClientUtils.IsNil(cardEnt) then
		return
	end

	local targetPos = self:GetNextDiscardPosition(seatID)

	self.cardMgr:TryAdvance(instanceId, tokenId, nil, , {
		["\\xad\\xbd\n\\xbc^'\\xee6"] = "\\xfd\\xd26\\xf5",
		cardEnt = cardEnt,
		ownerSeatID = seatID,
		plannedWorldPos = targetPos
	})
	charFSM:DoDiscardCard(cardEnt, cardInfo, handCardIndex, fromUI, tokenId)
end

M.GetDrawCardWallBlendValue = function(self, wallPileIndex)
	local clampedIndex = wallPileIndex or 1

	if clampedIndex >= 1 then
		clampedIndex = 1
	elseif clampedIndex <= 14 then
		clampedIndex = 14
	end

	return (clampedIndex - 1) / 13 * 2 - 1
end

M.GetDrawCardBlend = function(self, drawSeatID, wallDirection, wallPileIndex)
	if wallDirection ~= nil or wallDirection > 0 or wallPileIndex ~= nil or wallPileIndex < 0 then
		return 0
	end

	local t = self.GetDrawCardWallBlendValue(self, wallPileIndex)
	local delta = self.GetDrawCardDirectionDelta(self, drawSeatID, wallDirection)

	if delta ~= 0 then
		return t
	elseif delta ~= 1 then
		return t
	elseif delta ~= 2 then
		return -t
	elseif delta ~= 3 then
		return -t
	end

	return 0
end

M.GetDrawCardDirectionDelta = function(self, drawSeatID, wallDirection)
	return (wallDirection - 1 - drawSeatID + 4) % 4
end

M.GetHandCardBlendX = function(self, seatID, handCardIndex, cardTransform)
	if not cardTransform or gClientUtils.IsNil(self.GetMachine(self)) then
		return 0
	end

	local seatRef = MjSeatRef:FromId(seatID)
	local handList = self.handEntList and self.handEntList[seatRef.machineIndex]

	if not handList then
		return 0
	end

	local totalCards = 14
	local halfWidth = (totalCards - 1) / 2

	return (handCardIndex - 1 - halfWidth) / halfWidth
end

M.FSM_EnterDingQue = function(self)
	self:GetCharacterFSM(self.mySeatID):SendSignal(gMaJiangConst.MjTransitionType.GameStart_DingQue)
end

M.FSM_ExitDingQue = function(self)
	self:GetCharacterFSM(self.mySeatID):SendSignal(gMaJiangConst.MjTransitionType.DingQue_Idle)
end

M.FSM_EnterHuIdle = function(self)
	self:GetCharacterFSM(self.mySeatID):SendSignal(gMaJiangConst.MjTransitionType.DrawCard_HuIdle)
end

M.FSM_ExitHuIdle = function(self)
	self:GetCharacterFSM(self.mySeatID):SendSignal(gMaJiangConst.MjTransitionType.Idle_ChiPongKong)
end

M.FSM_ConfirmHu = function(self)
	self:GetCharacterFSM(self.mySeatID):ConfirmHu()
end

M.FSM_CancelHu = function(self)
	self:GetCharacterFSM(self.mySeatID):CancelHu()
end

M.FSM_EnterHu = function(self)
	self:GetCharacterFSM(self.mySeatID):SendSignal(gMaJiangConst.MjTransitionType.HuIdle_Hu)
end

M.FSM_EnterGameEnd = function(self)
	local charFSM = self.GetCharacterFSM(self, self.mySeatID)

	if charFSM then
		charFSM.ForceTransitToState(charFSM, gMaJiangConst.MjStateType.GameEnd)
	end
end
