-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangPanelStore_Reach.lua
-- Decompiled from: 01215_MajiangPanelStore_Reach.lua_d9b9c099cfd9.luajit

local M = C_MajiangPanelStore
local MahjongConfig = LTConfig.MahjongConfig
local MahjongRoomState = UX.Game.MahjongRoomState
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")

M.GetReachState = function(self)
	return self.game and self.game.reachGameState
end

M.IsReach = function(self)
	return self.game and self.game:IsReach()
end

M.GetReachPlayerIndex = function(self)
	local state = self:GetReachState()
	local round = state and state.CurrentRound

	return round and round.MyPlayerIndex or 0
end

M.GetReachRemainTime = function(self)
	local state = self:GetReachState()
	local round = state and state.CurrentRound

	return round and round.CurrentRemainTime or 0
end

M.ForEachReachSeat = function(self, func)
	local state = self.GetReachState(self)

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local round = state.CurrentRound
	local my = round.MyPlayerIndex
	local total = state.TotalPlayer

	for i = 1, total do
		local seatID = (my + i - 1) % total

		func(i, round.Seats[seatID + 1], seatID)
	end
end

M.ReachDiscardTile = function(self, tile, isRichiing, isDiscardingLastDraw)
	local info = {
		PlayerIndex = self:GetReachPlayerIndex(),
		IsRichiing = isRichiing ~= true,
		DiscardingLastDraw = isDiscardingLastDraw ~= true,
		Tile = tile,
		RemainTurnTime = self:GetReachRemainTime()
	}

	gClientToGameDelegate:DiscardTile(info)
	self:RefreshShowOp(false)
end

M.ReachInTurnOp = function(self, opIndex)
	gClientToGameDelegate:InTurnOperationEvent(self:GetReachPlayerIndex(), opIndex, self:GetReachRemainTime())
	self:RefreshShowOp(false)
end

M.ReachOutTurnOp = function(self, opIndex)
	gClientToGameDelegate:OutTurnOperationEvent(self:GetReachPlayerIndex(), opIndex, self:GetReachRemainTime())
	self:RefreshShowOp(false)
end

M.ReachResponseOK = function(self)
	gClientToGameDelegate:ResponseOKEvent(self:GetReachPlayerIndex())
end

M.OnSyncReachOperations = function(self)
	self.showOpBeforeChi = nil

	self.ShowReachChiSelector(self, false)

	local state = self.GetReachState(self)

	if state ~= nil or state.CurrentRound ~= nil or self.game ~= nil then
		return
	end

	local rule = self.game:GetRule()

	rule:EndRichiDeclaration()

	local viewData = rule:BuildOperationViewData({
		Operations = state.CurrentRound.CurrentOperations,
		OpKind = state.CurrentRound.CurrentOpKind
	})
	self.reachOpViewData = viewData
	local bindData = self.bindData
	bindData.canHu = gMaJiangConst.BOOL2CTL[viewData.canTsumo or viewData.canRong]
	bindData.canGang = gMaJiangConst.BOOL2CTL[viewData.canKong]
	bindData.canPeng = gMaJiangConst.BOOL2CTL[viewData.canPong]
	bindData.canGuo = gMaJiangConst.BOOL2CTL[viewData.canSkip or viewData.canClientSkip]

	bindData.richiBtn:SetActive(viewData.canReach)
	bindData.chiBtn:SetActive(viewData.canChow)
	bindData.roundDrawBtn:SetActive(viewData.canRoundDraw)

	self.canHu = viewData.canTsumo or viewData.canRong
	self.canGang = viewData.canKong
	self.canPeng = viewData.canPong
	self.canReach = viewData.canReach
	self.canChow = viewData.canChow
	self.canRoundDraw = viewData.canRoundDraw

	if viewData.opKind == gReachMahjongConst.OpKind.InTurn and viewData.canSkip and not viewData.canChow and not viewData.canPong and not viewData.canKong and not viewData.canRong and not viewData.canRoundDraw then
		self.ReachOutTurnOp(self, viewData.opIndexMap.skip)

		return
	end

	if viewData.opKind ~= gReachMahjongConst.OpKind.InTurn and viewData.canDiscard and not viewData.canReach and not viewData.canTsumo and not viewData.canKong and not viewData.canRoundDraw and not viewData.canBei then
		local round = state.CurrentRound
		local me = round.Seats[round.MyPlayerIndex + 1]

		if me.IsRichi and round.LastDraw then
			local tile = round.LastDraw
			self.instance.richiAutoDiscardPending = true
			self.instance.richiAutoDiscardTimer = Timer.New(function ()
				self.instance.richiAutoDiscardPending = false
				self.instance.richiAutoDiscardTimer = nil

				self:ReachDiscardTile(tile, false, true)
			end, 1.7):Start()

			return
		end
	end

	self.RefreshShowOp(self, viewData.hasOp)
end

M.OnRichiBtnClick = function(self)
	local viewData = self.reachOpViewData

	if viewData ~= nil or viewData.opIndexMap.richi ~= nil then
		return
	end

	self:RefreshShowOp(false)

	local richiOp = viewData.operations[viewData.opIndexMap.richi + 1]
	local availableTiles = richiOp and richiOp.RichiAvailableTiles or {}
	local rule = self.game:GetRule()

	rule:BeginRichiDeclaration(availableTiles)

	local firstValid = nil

	for i = 1, #self.handCard do
		self.handCard[i].selected = false

		if not firstValid and rule.IsRichiDiscardable(rule, self.handCard[i].tile) then
			firstValid = i
		end
	end

	if firstValid then
		self.handCard[firstValid].selected = true
		self.selectedHandCardIndex = firstValid
	end

	self.RefreshHandCardList(self)
	self.RefreshMyHandCardSelectionEffect(self)
end

M.OnChiBtnClick = function(self)
	local viewData = self.reachOpViewData

	if viewData ~= nil or viewData.opIndexMap.chow ~= nil then
		return
	end

	local chowIndices = viewData.opIndexMap.chow

	if #chowIndices ~= 1 then
		self.ReachOutTurnOp(self, chowIndices[1])
	else
		self.ShowReachChiList(self, viewData.operations, chowIndices)
	end
end

M.OnRoundDrawBtnClick = function(self)
	local viewData = self.reachOpViewData

	if viewData ~= nil or viewData.opIndexMap.roundDraw ~= nil then
		return
	end

	if viewData.opKind ~= gReachMahjongConst.OpKind.InTurn then
		self.ReachInTurnOp(self, viewData.opIndexMap.roundDraw)
	else
		self.ReachOutTurnOp(self, viewData.opIndexMap.roundDraw)
	end
end

M.OnHuBtnClickReach = function(self)
	local viewData = self.reachOpViewData

	if viewData ~= nil then
		return
	end

	if viewData.opKind ~= gReachMahjongConst.OpKind.InTurn and viewData.opIndexMap.tsumo == nil then
		self.ReachInTurnOp(self, viewData.opIndexMap.tsumo)
	elseif viewData.opIndexMap.rong == nil then
		self.ReachOutTurnOp(self, viewData.opIndexMap.rong)
	end
end

M.OnGangBtnClickReach = function(self)
	local viewData = self.reachOpViewData

	if viewData ~= nil or viewData.opIndexMap.kong ~= nil then
		return
	end

	if viewData.opKind ~= gReachMahjongConst.OpKind.InTurn then
		self.ReachInTurnOp(self, viewData.opIndexMap.kong)
	else
		self.ReachOutTurnOp(self, viewData.opIndexMap.kong)
	end
end

M.OnPengBtnClickReach = function(self)
	local viewData = self.reachOpViewData

	if viewData ~= nil or viewData.opIndexMap.pong ~= nil then
		return
	end

	self.ReachOutTurnOp(self, viewData.opIndexMap.pong)
end

M.OnGuoBtnClickReach = function(self)
	local viewData = self.reachOpViewData

	if viewData ~= nil then
		return
	end

	if viewData.opIndexMap.skip == nil then
		self.ReachOutTurnOp(self, viewData.opIndexMap.skip)
	elseif viewData.canClientSkip then
		self.RefreshShowOp(self, false)
	end
end

M.OutCardReach = function(self, index, data)
	if self.instance.richiAutoDiscardPending then
		return
	end

	local tile = data and data.tile

	if tile ~= nil then
		return
	end

	local rule = self.game:GetRule()

	if rule.awaitingRichiDiscard and not rule.IsRichiDiscardable(rule, tile) then
		return
	end

	local isRichiing = rule.awaitingRichiDiscard

	rule:EndRichiDeclaration()
	self:SetHandCardSelected(index, false)

	local lastDraw = self:GetReachState().CurrentRound.LastDraw
	local isDiscardingLastDraw = lastDraw == nil and tile.InstanceId ~= lastDraw.InstanceId

	self:ReachDiscardTile(tile, isRichiing, isDiscardingLastDraw)
end

M.ShowReachChiSelector = function(self, isShow)
	self.bindData.showChiSelectorCtrl = gMaJiangConst.BOOL2CTL[isShow ~= true]

	if isShow then
		self.showOpBeforeChi = self.showOp

		self.RefreshShowOp(self, false)
	elseif self.showOpBeforeChi then
		self.RefreshShowOp(self, true)

		self.showOpBeforeChi = nil
	end
end

M.ShowReachChiList = function(self, operations, chowIndices)
	local chowOps = {}

	for i = 1, #chowIndices do
		chowOps[i] = {
			opIndex = chowIndices[i],
			operation = operations[chowIndices[i] + 1]
		}
	end

	gMaJiangUtils:GetChiSelectorStore():SetData(chowOps)
	self:ShowReachChiSelector(true)
end

M.OnReachChiSelected = function(self, opIndex)
	self.showOpBeforeChi = nil

	self.ShowReachChiSelector(self, false)
	self.ReachOutTurnOp(self, opIndex)
end

M.OnSyncReachRoundStart = function(self)
	self.bindData.roundDrawCtrl = gMaJiangConst.BOOL2CTL[false]

	self.RefreshReachGame(self)
end

M.OnSyncReachDrawTile = function(self)
	self.RefreshReachTings(self)
	self.OnSyncReachOperations(self)
	self.RefreshMyHandCards(self, self.game.myInfo)
	self.RefreshReachTurn(self)
end

M.RefreshReachTings = function(self)
	local state = self.GetReachState(self)

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	self.RefreshTingButtonState(self)
end

M.OnSyncReachDiscardOperation = function(self)
	self.SetTips(self, gMaJiangConst.TipsType.notips)
	self.RefreshRichiStatus(self)
	self.OnSyncReachOperations(self)
	self.RefreshReachDora(self)
	self.RefreshMyHandCards(self, self.game.myInfo)
end

M.OnSyncReachTurnEnd = function(self)
	self.RefreshReachScore(self)
	self.RefreshRichiStatus(self)
	self.RefreshReachDora(self)
end

M.RefreshReachTurn = function(self)
	local state = self:GetReachState()
	local round = state and state.CurrentRound
	self.turn = round and round.CurrentPlayerIndex or self.turn

	self.game:RefreshSeat(self.turn)

	if self.turn ~= self.game.mySeatID and not self.instance.richiAutoDiscardPending then
		self.TryShowTurnTips(self)
	end

	self.RefreshTingButtonState(self)
end

M.OnSyncReachOperationPerform = function(self)
	self.showOpBeforeChi = nil

	self.ShowReachChiSelector(self, false)
	self.RefreshReachScore(self)
	self.RefreshRichiStatus(self)
	self.RefreshReachDora(self)
	self.RefreshReachTurn(self)
	self.RefreshMyHandCards(self, self.game.myInfo)
end

M.OnSyncReachKongInfo = function(self)
	self.OnSyncReachOperations(self)
	self.RefreshReachDora(self)
end

M.OnSyncReachBeiDora = function(self)
	self.OnSyncReachOperations(self)
end

M.OnSyncReachTsumo = function(self)
	self:SetTips(gMaJiangConst.TipsType.notips)

	local state = self:GetReachState()
	local tsumoInfo = state and state.Result and state.Result.TsumoInfo
	local tsumoSeat = tsumoInfo and tsumoInfo.TsumoPlayerIndex

	self:PlayActionBySeats({
		tsumoSeat
	}, gMaJiangConst.OpEffectAction.ZiMo, false)
	self:RefreshReachScore()
	self:RefreshReachDora()
	self:RefreshMyHandCards(self.game.myInfo)
	self:ReachResponseOK()

	self.game.rimaPending = true

	gPanelManager:CheckShow(gPanelId.MAJIANG_RIMA_FINAL_PANEL)
end

M.OnSyncReachRong = function(self)
	self:SetTips(gMaJiangConst.TipsType.notips)

	local state = self:GetReachState()
	local rongInfo = state and state.Result and state.Result.RongInfo
	local seats = rongInfo and rongInfo.RongPlayerIndices or {}

	self:PlayActionBySeats(seats, gMaJiangConst.OpEffectAction.Hu, false)
	self:RefreshReachScore()
	self:RefreshReachDora()
	self:RefreshMyHandCards(self.game.myInfo)
	self:ReachResponseOK()

	self.game.rimaPending = true

	gPanelManager:CheckShow(gPanelId.MAJIANG_RIMA_FINAL_PANEL)
end

M.OnSyncReachPointTransfer = function(self)
	self.RefreshReachScore(self)
end

M.OnSyncReachRoundDraw = function(self, info)
	self.SetTips(self, gMaJiangConst.TipsType.notips)
	self.ShowReachRoundDraw(self, info)
end

M.OnSyncReachGameEnd = function(self)
	self:SetTips(gMaJiangConst.TipsType.notips)

	local state = self:GetReachState()
	local gameEndInfo = state and state.Result and state.Result.GameEndInfo
	self.game.serverRoomInfo.State = MahjongRoomState.GameOver

	self:RefreshRoomState()

	if self.game.rimaPending then
		self.game.pendingGameEndInfo = gameEndInfo
	else
		self.game:OpenFinal(gameEndInfo)
	end
end

M.RefreshReachGame = function(self)
	local state = self.GetReachState(self)

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local names = MahjongConfig.SeatNames
	local nameList = {}

	self:ForEachReachSeat(function (i, seat)
		nameList[i] = seat and seat.PlayerName or names[i] or ""
	end)
	self.game:RefreshSeatName(nameList)
	self.game:RefreshIsShow(gMaJiangConst.BOOL2CTL[true])

	self.bindData.reachModeCtrl = gMaJiangConst.BOOL2CTL[true]
	self.showCountDown = true

	self.game:RefreshReachSeatDealer(state.CurrentRound.OyaPlayerIndex)
	self.game:RefreshSeat(state.CurrentRound.CurrentPlayerIndex)
	self:RefreshReachScore()
	self:RefreshRichiStatus()
	self:RefreshReachDora()
	self:RefreshShowOp(false)

	self.game.serverRoomInfo.State = MahjongRoomState.Begin

	self:RefreshRoomState()
	self:RefreshMyHandCards(self.game.myInfo)
end

M.RefreshReachScore = function(self)
	local scores = {}

	self:ForEachReachSeat(function (i, seat)
		scores[i] = seat and seat.Points or 0
	end)
	self.game:RefreshSeatScore(scores)
end

M.RefreshRichiStatus = function(self)
	local state = self.GetReachState(self)

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local round = state.CurrentRound
	local middleStore = gMaJiangUtils:GetMiddleStore()

	self:ForEachReachSeat(function (i, seat)
		middleStore:RefreshRichiMark(i - 1, seat and seat.IsRichi or false)
	end)

	local me = round.Seats[round.MyPlayerIndex + 1]
	self.bindData.zhentingCtrl = gMaJiangConst.BOOL2CTL[me and me.IsZhenting or false]
end

M.RefreshReachDora = function(self)
	local state = self.GetReachState(self)

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local round = state.CurrentRound

	gMaJiangUtils:GetReachStatusStore():SetReachGameStatusData(round.DoraIndicators, round.RichiSticks, round.Extra, round.OyaPlayerIndex)
end

M.ShowReachRoundDraw = function(self, info)
	local state = self:GetReachState()
	local roundDrawType = info and info.RoundDrawType
	local waitingData = info and info.WaitingData
	local tingData = {}

	if waitingData == nil and state == nil and state.CurrentRound == nil then
		local round = state.CurrentRound
		local my = round.MyPlayerIndex
		local total = state.TotalPlayer
		local wdList = waitingData

		for i = 1, total do
			local seatID = (my + i - 1) % total
			local wd = wdList[seatID + 1]
			local icons = {}

			if wd == nil and wd.WaitingTiles == nil then
				local tiles = wd.WaitingTiles

				for t = 1, #tiles do
					icons[#icons + 1] = {
						TingIcon = ReachTile.GetIconId(tiles[t])
					}
				end
			end

			tingData[i] = icons
		end
	end

	gMaJiangUtils:GetRoundDrawStore():SetReachRoundDrawData(roundDrawType, tingData)

	self.bindData.roundDrawCtrl = gMaJiangConst.BOOL2CTL[true]
end
