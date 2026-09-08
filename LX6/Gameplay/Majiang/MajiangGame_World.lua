-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangGame_World.lua
-- Decompiled from: 00339_MajiangGame_World.lua_639bddb1c1bf.luajit

local M = C_MajiangGame
local MjSeatRef = require("LX6/Gameplay/Majiang/MjSeatRef")
local MahjongUtils = L18.Mahjong.MahjongUtils
local C_MajiangCharacter = require("LX6/Gameplay/Majiang/MajiangCharacter")

M.BeginMajiangGameAfterReceiveServerData = function(self)
	self.RegisterOutwardSignal(self)

	local machine = self.GetMachine(self)
	self.machineInfo = {
		cardBound = machine.cardBound,
		rotationRange = machine.rotationOffsetRange
	}

	if not machine.isWallPrepared then
		machine.ClearMachine(machine)
	end

	self.cardMgr:Clear()

	self.huEntList = {}
	self.discardEntList = {}
	self.handEntList = {}
	self.pengEntList = {}
	self.discardOffsets = {}

	if self.firstEffectId and self.firstEffectId == 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.firstEffectId)
	end

	self.firstEffectId = 0

	for i = 0, 3 do
		self.huEntList[i] = {}
		self.discardEntList[i] = {}
		self.handEntList[i] = {}
		self.pengEntList[i] = {}
		self.discardOffsets[i] = {}
	end

	self.lastEnt = nil
	machine.isInDesk = true
	local bankerSeatID = self.serverGameInfo.Banker

	machine:InitWall(self:GetTotalCards(), bankerSeatID)
	self:InitOpeningHandBindings()
	self:RefreshCharactersFromRoomInfo()
	self:InitCharacterFSMs()
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG)
end

M.InitOpeningHandBindings = function(self)
	if self.serverGameInfo ~= nil or self.serverGameInfo.SeatInfos ~= nil then
		print_error("[Majiang-Manager] InitOpeningHandBindings gameInfo is nil")

		return
	end

	for seatID = 0, 3 do
		local seatInfo = self.serverGameInfo.SeatInfos[seatID + 1]
		local holds = seatInfo and seatInfo.Holds or nil

		if holds == nil then
			for i = 1, #holds do
				local cardInfo = holds[i]
				local instanceId = cardInfo and cardInfo.InstanceId or 0

				if instanceId ~= nil or instanceId < 0 then
					print_error("[Majiang-Manager] InitOpeningHandBindings invalid instanceId", seatID, i, instanceId)

					return
				end

				if gClientUtils.IsNil(self.GetCardEntByInstanceId(self, instanceId)) then
					local cardEnt = self.TakeCardFromWall(self, instanceId, seatID, "InitOpeningHandBindings", true)

					if gClientUtils.IsNil(cardEnt) then
						print_error("[Majiang-Manager] InitOpeningHandBindings failed to bind cardEnt", seatID, i, instanceId)

						return
					end
				end
			end
		end
	end
end

M.Spoon_StopMahjongMachine = function(self)
	if self.manager.isInServerGame then
		print_warn("[Majiang-Manager] Spoon_StopMahjongMachine while in game")

		slot1 = self.manager

		slot1:DestroyGame("Spoon_StopMahjongMachine")

		slot1 = gClientToGameDelegate

		slot1:Exit().Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				print_warn("[Majiang-Manager] Exit after machine stopped failed, err=", gCS.Error.GetNameById(err))
			end
		end

		return
	end

	self.DoExitMachine(self)
end

M.DoExitMachine = function(self)
	self.machineInfo = nil
	local machine = self.GetMachine(self)

	if gClientUtils.NotNil(machine) then
		machine.isInDesk = false
	end

	if self.firstEffectId and self.firstEffectId == 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.firstEffectId)
	end

	self.FSM_EnterGameEnd(self)
	self.DisposeCharacterFSMs(self)
end

M.GetEmptyCard = function(self, transform)
	print_error("[Majiang-Manager] GetEmptyCard is forbidden, cards must come from wall")

	return nil
end

M.TakeAreaCardEntity = function(self, instanceId, currentEnt, parent, usedCardEnts)
	if instanceId ~= nil or instanceId ~= 0 then
		if gClientUtils.NotNil(currentEnt) then
			print_error("[Majiang-Manager] TakeAreaCardEntity invalid instanceId", instanceId, currentEnt.bindInstanceId or 0)
		end

		return nil
	end

	local cardEnt = self.GetCardEntByInstanceId(self, instanceId)

	if gClientUtils.IsNil(cardEnt) then
		print_error("[Majiang-Manager] TakeAreaCardEntity missing bound cardEnt", instanceId, gClientUtils.NotNil(currentEnt) and (currentEnt.bindInstanceId or 0) or 0)

		return nil
	end

	usedCardEnts[cardEnt] = true

	return cardEnt
end

M.ClearMachine = function(self)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) then
		return
	end

	machine:ClearMachine()
	self.cardMgr:Clear()

	self.lastEnt = nil
	self.discardOffsets = {}

	for i = 0, 3 do
		if self.huEntList == nil then
			self.huEntList[i] = {}
		end

		if self.discardEntList == nil then
			self.discardEntList[i] = {}
		end

		if self.handEntList == nil then
			self.handEntList[i] = {}
		end

		if self.pengEntList == nil then
			self.pengEntList[i] = {}
		end

		self.discardOffsets[i] = {}
	end
end

M._IsProtectedDiscardCardEnt = function(self, cardEnt)
	if gClientUtils.IsNil(cardEnt) or self.characterFSMs ~= nil then
		return false
	end

	local chiPongKongType = gMaJiangConst.AttachType.ChiPongKong

	for _, fsm in pairs(self.characterFSMs) do
		if fsm == nil then
			local data = fsm.attachData and fsm.attachData[chiPongKongType]

			if data and data.cardEnt ~= cardEnt then
				return true
			end

			local cur = fsm.currentAttachData

			if cur and cur.attachType ~= chiPongKongType and cur.cardEnt ~= cardEnt then
				return true
			end

			local pending = fsm.pendingChiPongKong

			if pending == nil and #pending <= 0 then
				for i = 1, #pending do
					local item = pending[i]

					if item and item.cardEnt ~= cardEnt then
						return true
					end
				end
			end
		end
	end

	return false
end

M.RefreshDiscardArea = function(self, seat, paiInfos, disableSound)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) or seat <= 0 or seat > 4 then
		return
	end

	local seatTransform = machine.discardArea[seat]
	local lastSeatId = self.turnSeatId
	local usedCardEnts = {}
	local discardEntList = {}

	for i = 1, #paiInfos do
		local cardInfo = paiInfos[i]
		local currentEnt = self.discardEntList[seat][i]
		local cardEnt = self.TakeAreaCardEntity(self, cardInfo.InstanceId, currentEnt, seatTransform, usedCardEnts)

		if gClientUtils.IsNil(cardEnt) then
			print_error("[Majiang-Manager] RefreshDiscardArea cardEnt is nil", seat, i, cardInfo.InstanceId)

			return
		end

		discardEntList[i] = cardEnt

		cardEnt.transform:SetParent(seatTransform)
		machine:ShowCard(cardEnt.transform)
		self:ApplyDiscardSlotTransform(seat, i, cardEnt.transform)
		self:DebugSetCardState(cardEnt, "Normal", "Discard", "discardEntList", seat, seat, i, "DiscardCard", -1, "RefreshDiscardArea")

		local cardState = gMaJiangConst.MahjongState.None

		if cardInfo.isSelected then
			cardState = gMaJiangConst.MahjongState.SELECTED
		end

		if lastSeatId ~= seat and self.lastDiscardInstanceId <= 0 and cardInfo.InstanceId ~= self.lastDiscardInstanceId then
			cardState = gMaJiangConst.MahjongState.FIRST

			self.PlayLastCardFx(self, cardEnt)
		end

		local pai, mType, isRed = self:GetRule():GetCardDisplayInfo(cardInfo)
		cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(pai, mType, cardState, isRed)

		self:RegisterCardEntity(cardInfo.InstanceId, cardEnt, gMaJiangConst.CardZone.Discard, seat, i)
	end

	for i = #self.discardEntList[seat], #paiInfos + 1, -1 do
		local tailEnt = self.discardEntList[seat][i]

		if self._IsProtectedDiscardCardEnt(self, tailEnt) then
			self.DebugSetCardState(self, tailEnt, "PendingAttach", "ProtectedDiscard", "discardEntList", seat, seat, i, "ChiPongKong", -1, "RefreshDiscardAreaProtect")
		end
	end

	self.discardEntList[seat] = discardEntList
	local layout = self:GetRule():GetDiscardLayout(seat)

	if layout then
		for i = 1, #discardEntList do
			local adj = layout[i]
			local ent = discardEntList[i]

			if adj and gClientUtils.NotNil(ent) then
				if adj.rotDelta then
					ent.transform.localRotation = ent.transform.localRotation * adj.rotDelta
				end

				local dX = adj.posXDelta
				local dZ = adj.posZDelta

				if dX and dX == 0 or dZ and dZ == 0 then
					local pos = ent.transform.localPosition

					if dX and dX == 0 then
						pos.x = pos.x + dX
					end

					if dZ and dZ == 0 then
						pos.z = pos.z + dZ
					end

					ent.transform.localPosition = pos
				end
			end
		end
	end

	if disableSound == true then
		self.PlaySoundOut(self)
	end
end

M.RefreshDiscardAreaSelection = function(self, seat, paiInfos)
	if gClientUtils.IsNil(self.GetMachine(self)) or seat <= 0 or seat > 4 then
		return
	end

	local discardList = self.discardEntList and self.discardEntList[seat]

	if discardList ~= nil or #discardList ~= 0 then
		return
	end

	local lastSeatId = self.turnSeatId
	local count = math.min(#paiInfos, #discardList)

	for i = 1, count do
		local cardEnt = discardList[i]
		local cardInfo = paiInfos[i]

		if gClientUtils.NotNil(cardEnt) then
			self:ResetCardDisplayState(cardEnt)

			cardEnt.isFirst = lastSeatId ~= seat and self.lastDiscardInstanceId <= 0 and cardInfo.InstanceId ~= self.lastDiscardInstanceId
		end
	end
end

M.RefreshLastCard = function(self, seat)
	if gClientUtils.IsNil(self.GetMachine(self)) or seat <= 0 or seat > 4 then
		return
	end

	local cardEnt = self.discardEntList[seat][#self.discardEntList[seat]]
	local cardInfo = nil

	if self.lastEnt and self.lastEnt.isCached ~= false then
		cardInfo = self.lastEnt.cardInfo
		cardInfo.State = gMaJiangConst.MahjongState.None
		self.lastEnt.cardInfo = cardInfo
	end

	if cardEnt then
		self.lastEnt = cardEnt
		cardInfo = cardEnt.cardInfo
		cardInfo.State = gMaJiangConst.MahjongState.FIRST
		cardEnt.cardInfo = cardInfo

		self.PlayLastCardFx(self, cardEnt)
	end
end

M.RefreshHuArea = function(self, seat, paiInfos)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) or seat <= 0 or seat > 4 then
		return
	end

	local seatTransform = machine.huArea[seat]
	local lastEnt = nil
	local usedCardEnts = {}
	local huEntList = {}

	for i = 1, #paiInfos do
		local cardInfo = paiInfos[i]
		local currentEnt = self.huEntList[seat][i]
		local cardEnt = self.TakeAreaCardEntity(self, cardInfo.InstanceId, currentEnt, seatTransform, usedCardEnts)

		if gClientUtils.IsNil(cardEnt) then
			print_error("[Majiang-Manager] RefreshHuArea cardEnt is nil", seat, i, cardInfo.InstanceId)

			return
		end

		huEntList[i] = cardEnt

		cardEnt.transform:SetParent(seatTransform)

		local localPosition = Vector3.zero
		localPosition.x = -1 * (i - 1) * (self.machineInfo.cardBound.x + LTConfig.MahjongConfig.normalCardInterval)

		self:SetLocalPosition(cardEnt.transform, localPosition)

		cardEnt.transform.localRotation = Quaternion.identity
		local pai, mType = self:GetRule():GetCardDisplayInfo(cardInfo)
		cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(pai, mType, 0, false)

		self:RegisterCardEntity(cardInfo.InstanceId, cardEnt, gMaJiangConst.CardZone.Hu, seat, i)

		lastEnt = cardEnt
	end

	self.huEntList[seat] = huEntList

	self.PlayHuCardFx(self, lastEnt)
	self.PlaySoundOut(self)
end

M.RefreshPengGangArea = function(self, seat, paiInfos)
	local fsm = self.GetCharacterFSM(self, seat)

	if fsm then
		fsm.RefreshPengGangArea(fsm, paiInfos)
	end
end

M.GetMyHandCard3D = function(self, index)
	local fsm = self.myFSM or self:GetCharacterFSM(self.mySeatID)

	return fsm and fsm:GetHandCardInst(index)
end

M.RefreshHandArea = function(self, seatId, paiInfos, open)
	local fsm = self.GetCharacterFSM(self, seatId)

	if fsm then
		fsm.RefreshHandArea(fsm, paiInfos, open)
	end
end

M._GetMahjongOutCardPos = function(self, index)
	local localPosition = Vector3.zero
	local id = index - 1
	local outCardCount = self:GetRule():GetOutCardCount()
	local outCardRowInterval = LTConfig.MahjongConfig.outCardRowInterval
	local outCardColInterval = LTConfig.MahjongConfig.outCardColInterval
	localPosition.x = -1 * (id % outCardCount) * (self.machineInfo.cardBound.x + outCardRowInterval)
	localPosition.z = math.floor(id / outCardCount) * (self.machineInfo.cardBound.y + outCardColInterval)

	return localPosition
end

M._GetOrCreateDiscardOffset = function(self, seatIndex, discardIndex)
	if not self.discardOffsets then
		self.discardOffsets = {}
	end

	if not self.discardOffsets[seatIndex] then
		self.discardOffsets[seatIndex] = {}
	end

	local offset = self.discardOffsets[seatIndex][discardIndex]

	if not offset then
		local deltaR = 0

		if self.machineInfo and self.machineInfo.rotationRange then
			deltaR = math.random(self.machineInfo.rotationRange.x, self.machineInfo.rotationRange.y)
		end

		offset = {
			x = math.random(-1, 1) / 1000,
			z = math.random(-1, 1) / 1000,
			r = deltaR
		}
		self.discardOffsets[seatIndex][discardIndex] = offset
	end

	return offset
end

M.GetDiscardSlotLocalTransform = function(self, seatIndex, discardIndex)
	local localPosition = self._GetMahjongOutCardPos(self, discardIndex)
	local offset = self._GetOrCreateDiscardOffset(self, seatIndex, discardIndex)
	localPosition.x = localPosition.x + offset.x
	localPosition.z = localPosition.z + offset.z
	local localRotation = Quaternion.Euler(-90, offset.r, 0)

	return localPosition, localRotation
end

M.ApplyDiscardSlotTransform = function(self, seatIndex, discardIndex, transform)
	local localPosition, localRotation = self.GetDiscardSlotLocalTransform(self, seatIndex, discardIndex)

	self.SetLocalPosition(self, transform, localPosition)

	transform.localRotation = localRotation
end

M.TakeCardFromWall = function(self, instanceId, ownerSeatID, reason, hideOnTake, drawFromTail)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) then
		return nil
	end

	if instanceId ~= nil or instanceId < 0 then
		print_error("[Majiang-Manager] TakeCardFromWall invalid instanceId", instanceId, ownerSeatID, reason)

		return nil
	end

	local wallDirection = -1
	local wallPileIndex = -1
	local cardEnt = nil
	local drawInfo = machine:GetWallCardDrawInfo(drawFromTail ~= true)

	if drawInfo == nil then
		wallDirection = drawInfo.x or -1
		wallPileIndex = drawInfo.y or -1
	end

	if drawFromTail ~= true then
		cardEnt = machine.GetTailCardInWall(machine)
	else
		cardEnt = machine.GetNextCardInWall(machine)
	end

	if gClientUtils.IsNil(cardEnt) then
		print_error("[Majiang-Manager] TakeCardFromWall no wall card", instanceId, ownerSeatID, reason)

		return nil
	end

	if self.RegisterCardEntity(self, instanceId, cardEnt, gMaJiangConst.CardZone.Wall, ownerSeatID) ~= nil then
		print_error("[Majiang-Manager] TakeCardFromWall failed to bind cardEnt", instanceId, ownerSeatID, reason)

		return nil
	end

	if drawFromTail ~= true then
		machine.RemoveOneFromWallTail(machine)
	else
		machine.RemoveOneFromWall(machine)
	end

	if hideOnTake ~= true then
		cardEnt.gameObject:SetActive(false)
	end

	self:DebugSetCardState(cardEnt, hideOnTake ~= true and "Hidden" or "Normal", "Wall", "wallArea", ownerSeatID or -1, -1, -1, "", -1, reason or "TakeCardFromWall")

	return cardEnt, wallDirection, wallPileIndex
end

M.GetNextDiscardPosition = function(self, seatID)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) then
		return nil
	end

	local seatRef = MjSeatRef:FromId(seatID)
	local anchorTransform = machine.discardArea[seatRef.machineIndex]

	if gClientUtils.IsNil(anchorTransform) then
		return nil
	end

	local nextDiscardIndex = #(self.discardEntList[seatRef.machineIndex] or {}) + 1
	local localPosition = self:GetDiscardSlotLocalTransform(seatRef.machineIndex, nextDiscardIndex)

	return anchorTransform:TransformPoint(localPosition)
end

M.GetNextDiscardPose = function(self, seatID)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) then
		return nil, Quaternion.identity, nil, 
	end

	local seatRef = MjSeatRef:FromId(seatID)
	local anchorTransform = machine.discardArea[seatRef.machineIndex]

	if gClientUtils.IsNil(anchorTransform) then
		return nil, Quaternion.identity, nil, 
	end

	local nextDiscardIndex = #(self.discardEntList[seatRef.machineIndex] or {}) + 1
	local localPosition, localRotation = self:GetDiscardSlotLocalTransform(seatRef.machineIndex, nextDiscardIndex)
	local targetPos = anchorTransform:TransformPoint(localPosition)
	local targetLocalRotation = localRotation
	local targetIkPos = anchorTransform:TransformPoint(localPosition)

	return targetPos, targetLocalRotation, targetIkPos, nextDiscardIndex
end

M.PlayDialogVoice = function(self, seatIndex, voiceId)
	local npcPidList = self:GetNpcPidList()
	local agentId = npcPidList and npcPidList[seatIndex]

	if agentId and voiceId == 0 then
		gDialogManager:PlayDialogVoice(voiceId, agentId)
	end
end

M.PlaySoundPG = function(self)
	gUIUtils:PlaySound(LTConfig.MahjongConfig.pengGangSound)
end

M.PlaySoundOut = function(self)
	gUIUtils:PlaySound(LTConfig.MahjongConfig.outCardSound)
end

M.PlayLastCardFx = function(self, cardEnt)
	local offset = LTConfig.MahjongConfig.MahjongLatestCardEffectOffset

	if self.firstEffectId and self.firstEffectId == 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.firstEffectId)
	end

	local localOffset = Vector3.New(offset[1], offset[2], offset[3])
	local localEuler = Vector3.New(90, 0, 0)
	self.firstEffectId = gCS.EffectMgr:PlayEffectsOnTransform(LTConfig.MahjongConfig.MahjongLatestCardEffect, LX6.Effect.EffectPlayTag.Gameplay, cardEnt.transform, Vector3.zero, 0, 0, localOffset, localEuler)
end

M.PlayHuCardFx = function(self, cardEnt)
	if not cardEnt then
		return
	end

	local effectId = LTConfig.MahjongConfig.MahjongHuCardEffect
	local offset = LTConfig.MahjongConfig.MahjongHuCardEffectOffset

	if self.firstEffectId and self.firstEffectId == 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.firstEffectId)
	end

	local localOffset = Vector3.New(offset[1], offset[2], offset[3])
	local localEuler = Vector3.New(90, 0, 0)

	gCS.EffectMgr:PlayEffectsOnTransform(effectId, LX6.Effect.EffectPlayTag.Gameplay, cardEnt.transform, Vector3.zero, 0, 0, localOffset, localEuler)
end
