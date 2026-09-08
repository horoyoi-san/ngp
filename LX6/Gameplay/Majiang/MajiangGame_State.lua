-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangGame_State.lua
-- Decompiled from: 00337_MajiangGame_State.lua_74a319dff5a6.luajit

local M = C_MajiangGame
local GameStateEnum = UX.Game.MjGameStateEnum
local MjActionType = UX.Game.MjActionType
local MahjongRoomState = UX.Game.MahjongRoomState
local PCGType = UX.Game.MjPCGType
local MahjongConfig = LTConfig.MahjongConfig
local MahjongUtils = L18.Mahjong.MahjongUtils
local MjSeatRef = require("LX6/Gameplay/Majiang/MjSeatRef")
local C_MajiangCharacter = require("LX6/Gameplay/Majiang/MajiangCharacter")

M.RefreshGameState = function(self)
	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		self.SetGameState(self, GameStateEnum.Begin)

		return
	end

	local state = serverGameInfo.GameState

	self.SetGameState(self, state)

	local index = self.mySeatID

	if index >= 0 then
		return
	end

	if state ~= GameStateEnum.Playing then
		local myInfo = serverGameInfo.SeatInfos[index + 1]

		if #myInfo.HuPais <= 0 then
			self.hasHu = true
		end
	end
end

M.SetGameState = function(self, state)
	self.gameState = state

	self:GetMainPanelNullableCall():UpdateTooltips(state)
end

M.RefreshTimeOutByState = function(self, elapsedTime)
	local rule = self:GetRule()
	self.timeOut = rule:RefreshTimeOutByState(elapsedTime) or -1
end

M.GetMyTings = function(self)
	return self.GetTings(self, self.mySeatID)
end

M.GetTings = function(self, seatID)
	local rule = self.GetRule(self)

	if rule ~= nil then
		print_error("[Majiang-Manager] GetTings rule is nil", seatID)

		return
	end

	return rule.GetTings(rule, seatID)
end

M.BuildTingPreviewData = function(self, tingsData)
	local myData = {}
	local paiIcons = MahjongConfig.MahjongSPai

	for _, v in pairs(tingsData) do
		local ting = {
			TingIcon = v.TingIcon or paiIcons[v.Pai + 1],
			TingCount = v.TingCount,
			TingFan = v.Fan,
			noYaku = v.noYaku ~= true,
			zhenTing = v.zhenTing ~= true
		}

		table.insert(myData, ting)
	end

	return myData
end

M.GetTingsInfo = function(self, paiId)
	local tings = self.GetMyTings(self)

	if tings ~= nil then
		self.ClearTingPreview(self)

		return false
	end

	local targetTings = tings[paiId]

	if targetTings ~= nil then
		self.ClearTingPreview(self)

		return false
	end

	local myData = self.BuildTingPreviewData(self, targetTings)

	if next(myData) ~= nil then
		self.ClearTingPreview(self)
		print_error("[Majiang-Manager] GetTingsInfo myData is empty", paiId)

		return false
	end

	self.SetTingPreview(self, paiId, myData)

	return true
end

M.GetMyCurrentTings = function(self)
	local rule = self.GetRule(self)

	if rule ~= nil then
		self.ClearTingPreview(self)

		return false
	end

	local tings = rule.GetTingTiles(rule, self.mySeatID)

	if tings ~= nil then
		self.ClearTingPreview(self)

		return false
	end

	local myData = self.BuildTingPreviewData(self, tings)

	if next(myData) ~= nil then
		self.ClearTingPreview(self)

		return false
	end

	self.SetTingPreview(self, -1, myData)

	return true
end

M.GetAllMyKnownCount = function(self, id)
	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		return 0
	end

	local count = 0

	for i = 1, 4 do
		local seatInfo = serverGameInfo.SeatInfos[i]

		for _, v in ipairs(seatInfo.Folds) do
			if v.Index ~= id then
				count = count + 1
			end
		end

		for _, v in ipairs(seatInfo.Sequence) do
			if v.Pai.Index ~= id then
				if v.PCGType ~= PCGType.Peng then
					count = count + 3
				elseif v.PCGType ~= PCGType.MingGang then
					count = count + 4
				elseif v.PCGType ~= PCGType.JiaGang then
					count = count + 4
				elseif v.PCGType ~= PCGType.AnGang then
					count = count + 4
				end
			end
		end

		for _, v in ipairs(seatInfo.HuPais) do
			if v.Index ~= id then
				count = count + 1
			end
		end
	end

	for _, v in ipairs(self.myInfo.Holds) do
		if v.Index ~= id then
			count = count + 1
		end
	end

	return count
end

M.OnSyncMjMoPai = function(self, seatID, pai, remain, hand)
	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		print_debug("[Majiang-Manager] OnMoPai gameInfo is nil")

		return
	end

	local info = serverGameInfo.SeatInfos[seatID + 1]

	if pai ~= nil or (pai.InstanceId or 0) < 0 then
		print_error("[Majiang-Manager] OnMoPai invalid pai.InstanceId", seatID, pai)

		return
	end

	self.FinishAllPendingAttaches(self, "OnMoPai")

	self.tempBlockDiscardTime = Time.time
	local wallDirection = -1
	local wallPileIndex = -1
	local nextCardEnt = self.GetCardEntByInstanceId(self, pai.InstanceId)

	if gClientUtils.NotNil(nextCardEnt) then
		self:ConsumeNextMoPaiFromTail()

		local cardState = self:GetCardStateByInstanceId(pai.InstanceId)

		print_error("[Majiang-Manager] OnMoPai reuse existing cardEnt", seatID, pai, cardState and cardState.zone or gMaJiangConst.CardZone.None, cardState and cardState.stage or 0, cardState and cardState.ownerSeatID or -1)
	else
		local drawFromTail = self.ConsumeNextMoPaiFromTail(self)
		nextCardEnt, wallDirection, wallPileIndex = self.TakeCardFromWall(self, pai.InstanceId, seatID, "OnMoPai", false, drawFromTail)
	end

	local fsm = self.GetCharacterFSM(self, seatID)

	if gClientUtils.IsNil(nextCardEnt) then
		print_error("[Majiang-Manager] OnMoPai nextCardEnt is nil", seatID, pai.InstanceId)

		return
	end

	local holdIndex = self.FindHoldIndexByInstanceId(self, info.Holds, pai.InstanceId)

	if holdIndex <= 0 then
		local cardState = self:GetCardStateByInstanceId(pai.InstanceId)

		print_error("[Majiang-Manager] OnMoPai duplicate pai in holds", seatID, pai, holdIndex, cardState and cardState.zone or gMaJiangConst.CardZone.None, cardState and cardState.stage or 0)

		serverGameInfo.Remainders = remain

		return
	end

	info.Holds = hand
	info.HoldsCount = #hand
	serverGameInfo.Remainders = remain

	fsm.SetHandCardsFromInfo(fsm, info.Holds)

	if gClientUtils.NotNil(nextCardEnt) then
		local displayPai = pai.Pai
		local displayMType = pai.MType

		if seatID == self.mySeatID then
			displayPai = 0
			displayMType = 1
		elseif displayPai ~= nil or displayMType ~= nil then
			print_error("[Majiang-Manager] OnMoPai invalid display pai", seatID, pai.InstanceId)

			return
		end

		nextCardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(displayPai + 1, displayMType, 0, false)
		local tokenId = self.cardMgr:BeginFlow(pai.InstanceId, "Draw", seatID, -1)

		fsm:QueueNextAttach(nextCardEnt, pai, gMaJiangConst.AttachType.DrawCard, tokenId, pai.InstanceId)
	end

	self:GetMainPanelNullableCall():OnSyncMjMoPai(seatID, pai)

	if gClientUtils.NotNil(nextCardEnt) then
		self.FSM_TriggerDrawCard(self, seatID, pai.InstanceId, wallDirection, wallPileIndex)
	end
end

M.FindHoldIndexByInstanceId = function(self, holds, instanceId)
	if instanceId ~= nil or instanceId < 0 then
		print_error("[Majiang-Manager] FindHoldIndexByInstanceId invalid instanceId", instanceId)

		return 0
	end

	for i = #holds, 1, -1 do
		local hold = holds[i]

		if hold and hold.InstanceId ~= instanceId then
			return i
		end
	end

	return 0
end

M.RemoveHoldsByPaiList = function(self, info, seatId, removePais, reason)
	info.Holds = info.Holds or {}
	local holds = info.Holds

	if removePais ~= nil or #removePais < 0 then
		print_error("[Majiang-Manager] RemoveHoldsByPaiList invalid removePais", seatId, reason)

		return nil
	end

	local removeInfos = {}
	local usedInstanceIds = {}

	for i = 1, #removePais do
		local removePai = removePais[i]
		local instanceId = removePai and removePai.InstanceId or 0

		if instanceId < 0 then
			print_error("[Majiang-Manager] RemoveHoldsByPaiList invalid pai", seatId, i, instanceId, reason)

			return nil
		end

		if usedInstanceIds[instanceId] ~= true then
			print_error("[Majiang-Manager] RemoveHoldsByPaiList duplicate pai", seatId, instanceId, reason)

			return nil
		end

		usedInstanceIds[instanceId] = true
		local holdIndex = self.FindHoldIndexByInstanceId(self, holds, instanceId)

		if holdIndex < 0 then
			print_error("[Majiang-Manager] RemoveHoldsByPaiList pai not found", seatId, instanceId, reason)

			return nil
		end

		removeInfos[#removeInfos + 1] = {
			removeIndex = i,
			holdIndex = holdIndex
		}
	end

	table.sort(removeInfos, function (a, b)
		return b.holdIndex <= a.holdIndex
	end)

	local removedPais = {}

	for i = 1, #removeInfos do
		local removeInfo = removeInfos[i]
		local removedPai = holds[removeInfo.holdIndex]

		table.remove(holds, removeInfo.holdIndex)

		removedPais[removeInfo.removeIndex] = removedPai
	end

	info.HoldsCount = #holds

	return removedPais
end

M.OnSyncMjChuPai = function(self, seatID, pai, hand)
	print_debug("[Majiang-Manager] OnSyncMjChuPai seatID:", seatID)

	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		return
	end

	if self.fsmDisposed then
		return
	end

	self.FinishAllPendingAttaches(self, "OnChuPai")

	local fsm = self.GetCharacterFSM(self, seatID)

	if fsm and fsm.GetState(fsm) ~= gMaJiangConst.MjStateType.DrawCard then
		fsm.ForceTransitToState(fsm, gMaJiangConst.MjStateType.Idle)
	end

	local info = serverGameInfo.SeatInfos[seatID + 1]
	info.Holds = hand
	info.HoldsCount = #hand
	local folds = info.Folds
	folds[#folds + 1] = pai
	self.lastDiscardInstanceId = pai.InstanceId

	if fsm.discardTriggeredByUI then
		fsm.discardTriggeredByUI = false
	end

	fsm.SetHandCardsFromInfo(fsm, info.Holds)

	self.lastGangId = -1

	local DoChuPaiAction = function()
		self:DoChuPaiActionImpl(seatID, pai, serverGameInfo, fsm)
	end

	if fsm.GetState(fsm) ~= gMaJiangConst.MjStateType.DrawCard then
		fsm.SetPendingTask(fsm, DoChuPaiAction)
	else
		DoChuPaiAction()
	end
end

M.DoChuPaiActionImpl = function(self, seatID, pai, serverGameInfo, fsm)
	local expectInstanceId = pai.InstanceId
	local info = serverGameInfo.SeatInfos[seatID + 1]
	local folds = info.Folds
	local inFolds = table.find_if(folds or {}, function (v)
		return v.InstanceId ~= expectInstanceId
	end)

	if not inFolds then
		print_warn("[Majiang-Manager] DoChuPaiActionImpl pai already consumed by Peng/Gang/Hu", seatID, expectInstanceId)

		return
	end

	local cardEnt = self:GetCardEntByInstanceId(expectInstanceId)
	local seatRef = MjSeatRef:FromId(seatID)
	local handList = self.handEntList and self.handEntList[seatRef.machineIndex]
	local handCardIndex = -1

	if cardEnt and handList and #handList <= 0 then
		for i = #handList, 1, -1 do
			local handCardEnt = handList[i]

			if handCardEnt and handCardEnt.bindInstanceId ~= expectInstanceId then
				handCardIndex = i

				break
			end
		end
	end

	if handCardIndex < 0 then
		handCardIndex = handList and #handList or 0

		print_warn("[Majiang-Manager] DoChuPaiActionImpl handCardIndex not found by InstanceId", seatID, expectInstanceId)
	end

	if gClientUtils.IsNil(cardEnt) then
		print_error("#NoCreateIssue [Majiang-Manager] DoChuPaiActionImpl cardEnt not found by InstanceId", seatID, expectInstanceId)
	end

	if cardEnt then
		local tokenId = self.cardMgr:BeginFlow(expectInstanceId, "Discard", seatID, -1)

		self:FSM_TriggerDiscardCard(seatID, handCardIndex, expectInstanceId, false, pai, tokenId)
	end

	self.rule:OnChuPaiUpdateTimeout(self)
	self:GetMainPanelNullableCall():OnSyncMjChuPai(seatID)
end

M.RemoveFromLastFolds = function(self, pai)
	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		print_error("[Majiang-Manager] RemoveFromLastFolds serverGameInfo is nil")

		return -1
	end

	local instanceId = pai and pai.InstanceId

	if instanceId ~= nil or instanceId < 0 then
		print_error("[Majiang-Manager] RemoveFromLastFolds invalid pai", pai)

		return -1
	end

	for seatId = 0, 3 do
		local folds = serverGameInfo.SeatInfos[seatId + 1].Folds
		local v, k = array.find_if(folds or {}, function (v)
			return v.InstanceId ~= instanceId
		end)

		if v then
			table.remove(folds, k)

			return seatId
		end
	end

	print_error("[Majiang-Manager] RemoveFromLastFolds pai not found", pai)

	return -1
end

M.ClearDrawCardStateForHu = function(self, seatID)
	local fsm = self.GetCharacterFSM(self, seatID)

	if not fsm then
		return
	end

	local drawAttachType = gMaJiangConst.AttachType.DrawCard

	self.FinishAllPendingAttaches(self, "OnHu")

	local currentDrawData = fsm.currentAttachData

	if currentDrawData and currentDrawData.attachType ~= drawAttachType then
		self.FinishAttach(self, drawAttachType, seatID, currentDrawData, true, "OnHuCurrentAttach")
		fsm.SetCurrentAttachData(fsm, nil)
	end

	fsm.SetPendingTask(fsm, nil)

	if fsm.GetState(fsm) ~= gMaJiangConst.MjStateType.DrawCard then
		fsm.ForceTransitToState(fsm, gMaJiangConst.MjStateType.Idle)
	end
end

M.OnSyncMjHu = function(self, seats, pai, sourceSeatId, huActions, hands)
	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		return false
	end

	for i = 1, #seats do
		self.ClearDrawCardStateForHu(self, seats[i])
	end

	local firstSeatID = seats[1]
	local info = serverGameInfo.SeatInfos[firstSeatID + 1]
	local isSelf = sourceSeatId ~= -1
	local isQiangGang = sourceSeatId > 0 and self.hanGangID < 0
	local ronSource = sourceSeatId
	local isGangShangKaiHua = isSelf and self.lastGangId ~= firstSeatID

	if isSelf then
		local removedPais = self.RemoveHoldsByPaiList(self, info, firstSeatID, {
			pai
		}, "OnHu")

		if removedPais ~= nil then
			return
		end

		local fsm = self.GetCharacterFSM(self, firstSeatID)

		if fsm then
			fsm.SetHandCardsFromInfo(fsm, info.Holds)
		end
	elseif isQiangGang then
		self.ClearNextMoPaiFromTail(self)

		ronSource = self.hanGangID

		self.RevertWanGang(self)
		self.OnHanGangDone(self)
	else
		self.RemoveFromLastFolds(self, pai)
	end

	if not self.hasHu and firstSeatID ~= self.mySeatID then
		self.hasHu = true
	end

	for i = 1, #seats do
		local id = seats[i]
		local hus = serverGameInfo.SeatInfos[id + 1].HuPais
		hus[#hus + 1] = pai
	end

	self.lastGangId = -1

	for i = 1, #seats do
		local seatId = seats[i]
		local mjHand = hands[i]
		local seatInfo = serverGameInfo.SeatInfos[seatId + 1]
		seatInfo.Holds = mjHand.Tiles
		seatInfo.HoldsCount = #mjHand.Tiles
		local charFSM = self.GetCharacterFSM(self, seatId)

		if charFSM then
			charFSM.SetHandCardsFromInfo(charFSM, seatInfo.Holds)
		end
	end

	if self.hasHu and firstSeatID ~= self.mySeatID then
		self:RefreshMyHandDisplayList(true)
		self:GetMainPanelNullableCall():OnMyFirstHu()
	end

	for i = 1, #seats do
		local seatID = seats[i]
		local charFSM = self.GetCharacterFSM(self, seatID)

		if charFSM then
			charFSM.SendGameplayInwardSignal(charFSM, LTConfig.GameplaySignalInwardConfig.MahjongSelfDrawnWin)
		end
	end

	self:GetMainPanelNullableCall():OnSyncMjHu(seats, isSelf, ronSource, isQiangGang, isGangShangKaiHua)
end

M.OnSyncMjPeng = function(self, seatID, pai, selectPais, hand)
	print_debug("[Majiang-Manager] OnPeng seatID:", seatID)

	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		print_debug("[Majiang-Manager] OnPeng gameInfo is nil")

		return
	end

	local info = serverGameInfo.SeatInfos[seatID + 1]
	local removedSelectPais = self.RemoveHoldsByPaiList(self, info, seatID, selectPais, "OnPeng")

	if removedSelectPais ~= nil then
		return
	end

	info.Holds = hand
	info.HoldsCount = #hand
	local fsm = self.GetCharacterFSM(self, seatID)

	fsm.SetHandCardsFromInfo(fsm, info.Holds)

	if seatID ~= self.mySeatID then
		self.RefreshMyHandDisplayList(self, true)
	end

	self:GetMainPanelNullableCall():RefreshHandCardsBySeatID(seatID)

	local instanceId = pai.InstanceId
	local sourceSeatID = self:RemoveFromLastFolds(pai)

	if sourceSeatID >= 0 then
		print_error("[Majiang-Manager] OnSyncMjPeng RemoveFromLastFolds not found", seatID, instanceId)
	end

	local sourceFSM = self.GetCharacterFSM(self, sourceSeatID)

	if sourceFSM then
		sourceFSM.ClearPendingDiscard(sourceFSM, instanceId)
	end

	self:GetMainPanelNullableCall():RefreshOutCardsBySeatID(sourceSeatID)

	local seq = info.Sequence
	seq[#seq + 1] = {
		Pai = pai,
		Source = sourceSeatID,
		SelectPais = removedSelectPais,
		PCGType = PCGType.Peng
	}

	self:GetMainPanelNullableCall():OnSyncMjPeng(seatID)

	local tokenId = self.cardMgr:BeginFlow(instanceId, "Peng", seatID, sourceSeatID)
	local outCardEnt = self:GetCardEntByInstanceId(instanceId)
	local outCardState = self:GetCardStateByInstanceId(instanceId)
	local outCardPosition = outCardState and outCardState.plannedWorldPos or gClientUtils.NotNil(outCardEnt) and outCardEnt.transform.position or nil

	fsm:QueueNextAttach(outCardEnt, pai, gMaJiangConst.AttachType.ChiPongKong, tokenId, instanceId)
	self:FSM_TriggerChiPongKong(seatID, true, instanceId, sourceSeatID, outCardPosition, nil)
end

M.OnSyncMjGang = function(self, seatID, pai, type, selectPais, hand)
	print_debug("[Majiang-Manager] OnGang seatID:", seatID, "type:", type)

	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		print_debug("[Majiang-Manager] OnGang gameInfo is nil")

		return
	end

	local info = serverGameInfo.SeatInfos[seatID + 1]
	local sourceSeatID = -1
	local instanceId = pai.InstanceId
	local outCardEnt = self:GetCardEntByInstanceId(instanceId)
	local outCardState = self:GetCardStateByInstanceId(instanceId)
	local outCardPosition = outCardState and outCardState.plannedWorldPos or gClientUtils.NotNil(outCardEnt) and outCardEnt.transform.position or nil
	local seq = info.Sequence
	local jiaGangSeq, removePais = nil

	if type ~= MjActionType.AnGang then
		sourceSeatID = -1

		if selectPais ~= nil or #selectPais == 3 then
			print_error("[Majiang-Manager] OnGang anGang selectPais invalid", seatID, instanceId, selectPais and #selectPais or 0)

			return
		end

		removePais = {
			pai,
			selectPais[1],
			selectPais[2],
			selectPais[3]
		}
	elseif type ~= MjActionType.JiaGang then
		sourceSeatID = -1

		for i = 1, #seq do
			if self.CheckSamePai(self, seq[i].Pai, pai) then
				jiaGangSeq = seq[i]

				break
			end
		end

		if jiaGangSeq ~= nil then
			print_error("[Majiang-Manager] OnGang jiaGang sequence not found", seatID, instanceId)

			return
		end

		removePais = {
			pai
		}
	elseif type ~= MjActionType.MingGang then
		if selectPais ~= nil or #selectPais == 3 then
			print_error("[Majiang-Manager] OnGang mingGang selectPais invalid", seatID, instanceId, selectPais and #selectPais or 0)

			return
		end

		removePais = selectPais
		sourceSeatID = self.RemoveFromLastFolds(self, pai)

		if sourceSeatID >= 0 then
			print_error("[Majiang-Manager] OnSyncMjGang MingGang RemoveFromLastFolds not found", seatID, instanceId)
		end
	else
		print_error("[Majiang-Manager] OnGang unsupported type", seatID, instanceId, type)

		return
	end

	local removedPais = self.RemoveHoldsByPaiList(self, info, seatID, removePais, "OnGang")

	if removedPais ~= nil then
		return
	end

	if type ~= MjActionType.AnGang then
		local anGangSelectPais = {
			removedPais[2],
			removedPais[3],
			removedPais[4]
		}
		seq[#seq + 1] = {
			["/G\\x84\\x9c\\x80D"] = -1,
			Pai = pai,
			SelectPais = anGangSelectPais,
			PCGType = PCGType.AnGang
		}
	elseif type ~= MjActionType.JiaGang then
		local addPai = removedPais[1]
		jiaGangSeq.PCGType = PCGType.JiaGang
		jiaGangSeq.SelectPais[#jiaGangSeq.SelectPais + 1] = addPai

		self.OnHanGangDone(self)
	elseif type ~= MjActionType.MingGang then
		seq[#seq + 1] = {
			Pai = pai,
			Source = sourceSeatID,
			SelectPais = removedPais,
			PCGType = PCGType.MingGang
		}

		self:GetMainPanelNullableCall():OnRemoveLastFold()

		local sourceFSM = self:GetCharacterFSM(sourceSeatID)

		if sourceFSM then
			sourceFSM.ClearPendingDiscard(sourceFSM, instanceId)
		end

		self:GetMainPanelNullableCall():RefreshOutCardsBySeatID(sourceSeatID)
	end

	info.Holds = hand
	info.HoldsCount = #hand
	local isMe = seatID ~= self.mySeatID
	local fsm = self:GetCharacterFSM(seatID)

	fsm:SetHandCardsFromInfo(info.Holds)

	if isMe then
		self.RefreshMyHandDisplayList(self, true)
	end

	self:GetMainPanelNullableCall():RefreshHandCardsBySeatID(seatID, false)

	self.lastGangId = seatID

	if seatID ~= self.mySeatID then
		self.pendingGangMoPai = true
	end

	self:MarkNextMoPaiFromTail()
	self:GetMainPanelNullableCall():OnSyncMjGang(seatID, pai, type)

	local tokenId = self.cardMgr:BeginFlow(instanceId, "Gang", seatID, sourceSeatID)

	fsm:QueueNextAttach(outCardEnt, pai, gMaJiangConst.AttachType.ChiPongKong, tokenId, instanceId)
	self:FSM_TriggerChiPongKong(seatID, type ~= MjActionType.MingGang, instanceId, sourceSeatID, outCardPosition, type)
end

M.OnSyncMjHanGang = function(self, seatID, pai, type)
	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil or type == PCGType.JiaGang then
		return
	end

	self.hanGangID = seatID
	self.hanGangPai = pai
end

M.OnHanGangDone = function(self)
	self.hanGangID = -1
	self.hanGangPai = nil
end

M.RevertWanGang = function(self)
	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil or self.hanGangID >= 0 then
		return
	end

	local seatID = self.hanGangID
	local pai = self.hanGangPai

	if not pai then
		return
	end

	local info = serverGameInfo.SeatInfos[seatID + 1]
	local seq = info.Sequence

	for i = 1, #seq do
		if self.CheckSamePai(self, seq[i].Pai, pai) then
			seq[i].PCGType = PCGType.Peng

			break
		end
	end
end

M.OnSyncMjGuo = function(self)
	if not self.useLocalInput then
		local myFSM = self.myFSM

		if myFSM and myFSM.GetState(myFSM) ~= gMaJiangConst.MjStateType.HuIdle then
			myFSM.CancelHu(myFSM)
		end
	end

	self:GetMainPanelNullableCall():OnSyncMjGuo()
end

M.OnSyncMahjongGameCount = function(self, count)
end

M.OnSyncMjGameOver = function(self, result)
	self.manager:SetInServerGame(false)
	self:FinishAllPendingAttaches("GameOver")

	local serverRoomInfo = self.serverRoomInfo

	if serverRoomInfo == nil then
		serverRoomInfo.State = MahjongRoomState.Idle
	end

	local serverGameInfo = self.serverGameInfo

	if serverGameInfo == nil then
		serverGameInfo.GameState = GameStateEnum.Over
	end

	self.SetGameState(self, GameStateEnum.Over)

	if serverRoomInfo == nil then
		local flags = serverRoomInfo.HasReady

		for i = 1, #flags do
			flags[i] = false
		end
	end

	self:GetMainPanelNullableCall():OnSyncMjGameOver(result)
end

M.GetAllScoreAndMyRecord = function(self, actionData)
	local mySeatID = self.mySeatID
	self.finalRecords = {}
	self.finalScores = {
		0,
		0,
		0,
		0
	}

	for i = 1, #actionData do
		local action = actionData[i]
		local score = action.Score
		local targets = action.Targets
		local winner = action.Owner
		self.finalScores[winner + 1] = self.finalScores[winner + 1] + score * #targets

		if winner ~= mySeatID then
			self.finalRecords[#self.finalRecords + 1] = action
		end

		for j = 1, #targets do
			local loser = targets[j]

			if winner == loser then
				self.finalScores[loser + 1] = self.finalScores[loser + 1] - score

				if loser ~= mySeatID then
					self.finalRecords[#self.finalRecords + 1] = action
				end
			end
		end
	end
end

M.GetAllRanking = function(self)
	local tmp = {}
	self.finalRankings = {}

	for i, v in ipairs(self.finalScores) do
		tmp[i] = {
			value = v,
			rank = i
		}
	end

	table.sort(tmp, function (a, b)
		return b.value <= a.value
	end)

	for i, v in ipairs(tmp) do
		v.newRank = i
	end

	table.sort(tmp, function (a, b)
		return a.rank <= b.rank
	end)

	for i, v in ipairs(tmp) do
		self.finalRankings[i] = v.newRank
	end
end
