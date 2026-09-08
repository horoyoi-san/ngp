-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangPanelStore_XLCH_BattleUI.lua
-- Decompiled from: 01213_MajiangPanelStore_XLCH_BattleUI.lua_5a11114c923e.luajit

local MjActionType = UX.Game.MjActionType
local MahjongChatType = UX.Game.MahjongChatType
local MahjongConfig = LTConfig.MahjongConfig
local counter = 0
local M = C_MajiangPanelStore

M.GetMJType = function(self, paiInfo)
	return paiInfo.MType or 0
end

M.IsDingque = function(self, id)
	return self.game:IsDingque(id)
end

M.OnSyncMjEndCheck = function(self, seatList, action)
	self.endActCount = self.endActCount + 1

	self.PlayActionBySeats(self, seatList, self.ConvertMJActionType(self, action), true)
end

M.OnSyncMjTuiShui = function(self, seatList)
	self.OnSyncMjEndCheck(self, seatList, MjActionType.TuiShui)
end

M.OnSyncMjChaHuaZhu = function(self, seatList)
	self.OnSyncMjEndCheck(self, seatList, MjActionType.ChaHuaZhu)
end

M.OnSyncMjChaDaJiao = function(self, seatList)
	self.OnSyncMjEndCheck(self, seatList, MjActionType.ChaDaJiao)
end

M.LogGameOverHandMismatch = function(self, seatID, holds)
	if not self.mgr or self.mgr.debug == true then
		return
	end

	local resultMap = {}
	local currentMap = {}
	local cardMgrMap = {}

	local GetDiff = function(leftMap, rightMap)
		local diffMap = {}

		for instanceId in pairs(leftMap) do
			if rightMap[instanceId] == true then
				diffMap[instanceId] = instanceId
			end
		end

		local diff = table.keys(diffMap)

		table.sort(diff)

		return diff
	end

	slot7 = 1
	slot8 = holds or {}

	for i = slot7, #slot8 do
		local instanceId = holds[i] and holds[i].InstanceId or 0

		if instanceId <= 0 then
			resultMap[instanceId] = true
		end
	end

	local fsm = self.game and self.game:GetCharacterFSM(seatID)
	slot8 = 1
	slot9 = fsm and fsm.handCardInsts or {}

	for i = slot8, #slot9 do
		local cardEnt = fsm.handCardInsts[i]
		local instanceId = gClientUtils.NotNil(cardEnt) and (cardEnt.bindInstanceId or 0) or 0

		if instanceId <= 0 then
			currentMap[instanceId] = true
		end
	end

	local cardStates = self.game and self.game.cardMgr and self.game.cardMgr.cardStates or nil
	local handZone = gMaJiangConst.CardZone.Hand
	slot10 = pairs
	slot12 = cardStates or {}

	for instanceId, state in slot10(slot12) do
		if state and state.zone ~= handZone and state.ownerSeatID ~= seatID then
			cardMgrMap[instanceId] = true
		end
	end

	local resultOnlyCurrent = GetDiff(resultMap, currentMap)
	local currentOnly = GetDiff(currentMap, resultMap)
	local resultOnlyCardMgr = GetDiff(resultMap, cardMgrMap)
	local cardMgrOnly = GetDiff(cardMgrMap, resultMap)

	if #resultOnlyCurrent ~= 0 and #currentOnly ~= 0 and #resultOnlyCardMgr ~= 0 and #cardMgrOnly ~= 0 then
		return
	end

	local resultIds = table.keys(resultMap)
	local currentHandIds = table.keys(currentMap)
	local cardMgrHandIds = table.keys(cardMgrMap)

	table.sort(resultIds)
	table.sort(currentHandIds)
	table.sort(cardMgrHandIds)

	local localIndex = self.game and self.game:GetSeatIndex(seatID) or -1

	print_warn("[MajiangPanelStore_XLCH_BattleUI] GameOver hand mismatch", "seatID=", seatID, "localIndex=", localIndex, "resultIds=", table.concat(resultIds, ","), "currentHandIds=", table.concat(currentHandIds, ","), "cardMgrHandIds=", table.concat(cardMgrHandIds, ","), "resultOnlyCurrent=", table.concat(resultOnlyCurrent, ","), "currentOnly=", table.concat(currentOnly, ","), "resultOnlyCardMgr=", table.concat(resultOnlyCardMgr, ","), "cardMgrOnly=", table.concat(cardMgrOnly, ","))
end

M.OnSyncMjGameOver = function(self, result)
	local bindData = self.bindData

	self:DisableTuoGuan()

	self.showCountDown = false
	bindData.canStartGame = false
	bindData.matchEND = gMaJiangConst.BOOL2CTL[true]

	bindData.handCardProxyList:SetList(0)

	for seatID = 0, 3 do
		local info = result.MjPlayerResultList[seatID + 1]

		self:LogGameOverHandMismatch(seatID, info and info.Holds or nil)

		local delta = self.game:GetSeatIndex(seatID)

		self:RefreshUnfolds(info.Holds, delta)
	end

	self.aniCo = coroutine.start(self.DelayShowEnd, self, result)
end

M.OnSyncMjGang = function(self, seatID, pai, type)
	self.waitingGang = false

	self.PlayActionBySeats(self, {
		seatID
	}, gMaJiangConst.OpEffectAction.Gang, false)
	self.ClearSelection(self, seatID)

	if self.bindData.canHu ~= gMaJiangConst.BOOL2CTL[true] then
		self.RefreshShowOp(self, false)
	end
end

M.OnSyncMjGuo = function(self)
	self.RefreshShowOp(self, false)

	if self.waitingGang then
		self.waitingGang = false

		self.RefreshMyHandCards(self, self.game.myInfo)
	end
end

M.OnSyncMjHu = function(self, seatIDs, isSelf, lastSeatID, isQiangGang, isGangShangKaiHua)
	local action = gMaJiangConst.OpEffectAction.Hu

	if isSelf then
		action = gMaJiangConst.OpEffectAction.ZiMo

		if isGangShangKaiHua then
			action = gMaJiangConst.OpEffectAction.GangShangKaiHua
		end

		if self.game.serverGameInfo.Remainders ~= 0 then
			action = gMaJiangConst.OpEffectAction.HaiDiLaoYue
		end
	end

	self.PlayActionBySeats(self, seatIDs, action, false)

	if isSelf then
		self.PlayZiMoAni(self, seatIDs[1])
	else
		self.PlayFangPaoAni(self, seatIDs, lastSeatID, isQiangGang)
	end

	for i = 1, #seatIDs do
		self.ClearSelection(self, seatIDs[i])
	end

	if self.showOp then
		self.RefreshShowOp(self, false)
	end
end

M.OnSyncMjMaoZhuanYu = function(self, seatID)
	self.PlayActionBySeats(self, {
		seatID
	}, gMaJiangConst.OpEffectAction.HuJiaoZhuanYi, true)
end

M.OnMyFirstHu = function(self)
	for i = 1, #self.handCard do
		self.handCard[i].mask = true
	end

	self.RefreshHandCardList(self)
end

M.OnNewGame = function(self)
	local bindData = self.bindData

	self.game:RefreshIsShow(gMaJiangConst.BOOL2CTL[false])

	bindData.matchEND = gMaJiangConst.BOOL2CTL[false]
	self.handCard = {}

	self:RefreshHandCardList()
	self:RefreshPlayers(self.game.serverRoomInfo)

	self.showCountDown = false

	self:ClearLastGame()

	self.game.isNewGame = false
end

M.OnSyncMjPeng = function(self, seatID)
	self.PlayActionBySeats(self, {
		seatID
	}, gMaJiangConst.OpEffectAction.Peng, false)
	self.ClearSelection(self, seatID)

	if self.bindData.canHu ~= gMaJiangConst.BOOL2CTL[true] then
		self.RefreshShowOp(self, false)
	end
end

M.OnSyncMahjongNpcChat = function(self, seatIndex, npcChatType, dialogId)
	self.game:PlayDialogVoice(seatIndex, dialogId)
end

M.OnSyncMahjongChat = function(self, chatType, seatIndex, msgId)
	if chatType ~= MahjongChatType.SystemText then
		self.ShowQuickTextMsg(self, seatIndex, msgId)
	end
end

M.OnSyncMjScoreChange = function(self, seatId, score, change)
	local mask = bit.lshift(1, seatId)
	local busy = bit.band(self.scoreFlag, mask) == 0
	local duration = 3

	if not busy then
		counter = counter + 1
		self.cos[counter] = coroutine.start(self.DelayRefreshScoreChange, self, seatId, score, change, counter, duration)
		self.scoreFlag = bit.bor(self.scoreFlag, mask)
	else
		local que = self.scoreQue[seatId + 1]
		que[#que + 1] = {
			score,
			change,
			duration * 2
		}
	end

	local roomInfo = self.game.serverRoomInfo

	if roomInfo and roomInfo.PlayerInfos then
		local scores = {}

		for seatID = 0, 3 do
			local playerInfo = roomInfo.PlayerInfos[seatID + 1]
			scores[seatID + 1] = playerInfo and playerInfo.Score or 0
		end

		self.game:RefreshSeatScore(scores)
	end
end

M.DelayRefreshScoreChange = function(self, seatId, score, change, coID, duration)
	coroutine.wait(duration)

	local index = self.game:MapIndex(seatId)
	self.avatarStore[index].scoreLabel = score
	local changeStr = nil
	local op = 0

	if change <= 0 then
		op = 1
		changeStr = gString.Format("+%d", change)
	else
		op = 2
		changeStr = tostring(change)
	end

	self.cos[coID] = nil
	local que = self.scoreQue[seatId + 1]

	if #que ~= 0 then
		local mask = bit.lshift(1, 4) - 1 - bit.lshift(1, seatId)
		self.scoreFlag = bit.band(self.scoreFlag, mask)
	else
		local data = que[1]
		counter = counter + 1
		self.cos[counter] = coroutine.start(self.DelayRefreshScoreChange, self, seatId, data[1], data[2], counter, data[3])

		table.remove(que, 1)
	end
end

M.DelayShowEnd = function(self, result)
	local delay = 0

	if self.endActCount <= 0 then
		delay = 1
	end

	self.mgr.inExit = true

	coroutine.wait(MahjongConfig.MahjongEndTime + delay)

	self.mgr.inExit = false

	self.game:OpenFinal({
		result,
		self.pveCompleteNum
	})

	self.aniCo = nil
end

M.OnSelectDingQue = function(self, data)
	local selectedType = data or self.instance.dqType or 1

	self:RefreshDingQueBtnSelected(selectedType)

	gClientToGameDelegate:DingQue(selectedType).Callback = function (errID)
		if errID <= 0 then
			print_error("DingQue failed, error =", gCS.Error.GetNameById(errID), "type =", selectedType)

			return
		end

		self.bindData:Commit("showDingQue", gMaJiangConst.BOOL2CTL[false], COMMIT_IMMEDIATELY)
		self:RefreshDingQueBtnSelected(nil)

		local _, firstBtn = self.bindData.handCardProxyList:TryGetChildAt(0, nil)
		self.bindData.navigationArea.CurrentActiveContent = firstBtn
	end
end

M.OnDingQueItemFocus = function(self, data)
	self.RefreshDingQueBtnSelected(self, data)
end

M.PlayFangPaoAni = function(self, seatIDs, lastSeatID, isQiangGang)
	if lastSeatID > 0 and not isQiangGang then
		self.RefreshOutCardsBySeatID(self, lastSeatID)
	end

	for i = 1, #seatIDs do
		self.RefreshHusBySeatID(self, seatIDs[i])
	end
end

M.PlayZiMoAni = function(self, seatID)
	self.RefreshHandCardsBySeatID(self, seatID)
	self.RefreshHusBySeatID(self, seatID)
end

M.RefreshCards = function(self, seatInfos, addition)
	local seatID = (self.game.mySeatID + addition) % 4
	local info = seatInfos[seatID + 1]
	local index = self.game:GetSeatIndex(seatID)

	if info ~= nil then
		return
	end

	self.RefreshDingque(self, index + 1, info.Que)
	self.RefreshOutCards(self, info, index)
	self.RefreshHus(self, info, index)

	if addition ~= 0 then
		self:RefreshMyHandCards(info)

		local myHandDisplayList = self.game:GetMyHandDisplayList()

		self.game:RefreshHandArea(seatID, self.game:GetRule():ExtractHandCardsFromDisplayList(myHandDisplayList), false)
	else
		self.RefreshHandCards(self, info, index)
	end
end

M.RefreshDingque = function(self, index, que)
	local view = self.avatarStore[index]

	if view then
		view.queType = que
	end
end

M.RefreshFriendPrepare = function(self, state)
end

M.RefreshHandCards = function(self, info, index)
	local seatID = self.game:GetSeatID(index)
	local renderHolds = self.game:GetSeatHoldsForRender(seatID, nil, "RefreshHandCards")

	if renderHolds == nil then
		self.game:RefreshHandArea(seatID, renderHolds)
	end
end

M.RefreshHandCardsBySeatID = function(self, seatID, playEffect)
	local info = self.game.serverGameInfo.SeatInfos[seatID + 1]
	local delta = self.game:GetSeatIndex(seatID)

	if seatID ~= self.game.mySeatID then
		self:RefreshMyHandCards(info, playEffect)

		local myHandDisplayList = self.game:GetMyHandDisplayList()

		self.game:RefreshHandArea(seatID, self.game:GetRule():ExtractHandCardsFromDisplayList(myHandDisplayList), false)
		self:RefreshMyHandCardSelectionEffect()
	else
		self.RefreshHandCards(self, info, delta)
	end
end

M.RefreshHus = function(self, info, index)
	local seatID = self.game:GetSeatID(index)

	self.game:RefreshHuArea(seatID, info.HuPais)
end

M.RefreshHusBySeatID = function(self, seatID)
	local info = self.game.serverGameInfo.SeatInfos[seatID + 1]
	local delta = self.game:GetSeatIndex(seatID)

	self:RefreshHus(info, delta)
end

M.OnSyncMjOperations = function(self, action)
	local bindData = self.bindData
	local rule = self.game:GetRule()
	local viewData = rule and rule:BuildOperationViewData(action) or {}
	self.canHu = viewData.canHu ~= true
	self.canPeng = viewData.canPeng ~= true
	self.canGang = viewData.canGang ~= true
	self.canReach = viewData.canReach ~= true
	bindData.canHu = gMaJiangConst.BOOL2CTL[self.canHu]
	bindData.canPeng = gMaJiangConst.BOOL2CTL[self.canPeng]
	bindData.canGang = gMaJiangConst.BOOL2CTL[self.canGang]
	bindData.canReach = gMaJiangConst.BOOL2CTL[false]
	local hasOp = viewData.hasOp ~= true

	self:RefreshShowOp(hasOp)

	if viewData.enterHuIdle then
		self.game:FSM_EnterHuIdle()
	end

	if hasOp then
		self.gangActionInfo = viewData.gangActionInfo
	end
end

M.RefreshOutCards = function(self, info, index, skip3D)
	if not info then
		return
	end

	local seatID = self.game:GetSeatID(index)
	local renderList = self.game:GetRule():GetDiscardRenderList(seatID)

	if table.isNilOrEmpty(renderList) then
		return
	end

	local views = {}

	for i = 1, #renderList do
		local card = renderList[i]
		local ele = {
			["ZI\\xfd\\xb8\\x88\r\\xbb\\xcc\\xec"] = false
		}

		for k, v in pairs(card) do
			ele[k] = v
		end

		views[i] = ele
	end

	self.discardCardInfo[index] = views

	if not skip3D then
		self.game:RefreshDiscardArea(seatID, views)
	end
end

M.RefreshOutCardsBySeatID = function(self, seatID)
	local info = self.game.serverGameInfo.SeatInfos[seatID + 1]
	local delta = self.game:GetSeatIndex(seatID)
	local fsm = self.game:GetCharacterFSM(seatID)
	local defer3D = fsm and fsm.deferDiscard3D

	self:RefreshOutCards(info, delta, defer3D)

	if not defer3D then
		self.game:RefreshLastCard(seatID)
	end
end

M.OnSyncMahjongPlayerPveGameNumInfo = function(self, completeNum)
	self.pveCompleteNum = completeNum
end

M.OnSyncMjTurn = function(self, seatID)
	self.turn = seatID

	self.game:RefreshSeat(seatID)

	if self.game.mySeatID ~= seatID then
		self.SetTipsForce(self, gMaJiangConst.TipsType.notips)
		self.TryShowTurnTips(self)
	end

	self.RefreshTingButtonState(self)
end

M.RefreshUnfolds = function(self, holds, index)
	local views = {}

	for i = 1, #holds do
		local instanceId = holds[i].InstanceId or 0

		if instanceId < 0 then
			print_error("[MajiangPanelStore_XLCH_BattleUI] RefreshUnfolds invalid instanceId", index, i, instanceId)

			return
		end

		local id = holds[i].Index
		views[i] = {
			["ZI\\xfd\\xb8\\x88\r\\xbb\\xcc\\xec"] = false,
			id = id,
			InstanceId = instanceId,
			Pai = holds[i].Pai,
			MType = holds[i].MType
		}
	end

	table.sort(views, self:CreateAction("SortUnfolds"))

	local seatID = self.game:GetSeatID(index)

	self.game:RefreshHandArea(seatID, views, true)
end

M.SortUnfolds = function(self, a, b)
	return a.id <= b.id
end
