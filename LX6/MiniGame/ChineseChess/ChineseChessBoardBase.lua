-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessBoardBase.lua
-- Decompiled from: 02162_ChineseChessBoardBase.lua_bbe80f2aa08e.luajit

C_ChineseChessBoardBase = DefClass("C_ChineseChessBoardBase", C_ChineseChessBoardBase)
local M = C_ChineseChessBoardBase
local ChineseChessConfig = require("LX6/MiniGame/ChineseChess/ChineseChessConfig")

M.ctor = function(self)
	self.MovePointMap = {}
	self._chessYOriginMap = {}
	self.BlockedPointUUIDMap = {}
end

M.Init = function(self, boardGo, Chart, player1, player2, isReverse)
	if isReverse then
		self.RedPlayer = player2
		self.BlackPlayer = player1
	else
		self.RedPlayer = player1
		self.BlackPlayer = player2
	end

	self.CurrentPlayer = self.RedPlayer
	self.RoundStartTime = os.time()
	self.Chart = Chart
	self.BoardGo = boardGo
	self.PointsGo = boardGo.transform:Find("Colliders")
	self.ChesssGo = boardGo.transform:Find("Chesss")

	self:InitPointMarkers()
	self:InitChessBoard()
end

M.InitChessBoard = function(self)
end

M.InitPointMarkers = function(self)
	self.PointTransforms = {}

	for i = 3, 11 do
		for j = 3, 12 do
			local point = i * 16 + j
			local pointGo = self.PointsGo.transform:Find(point)

			if gChineseChessMgr.IsMirror then
				self.PointTransforms[239 - point] = pointGo
			else
				self.PointTransforms[point] = pointGo
			end
		end
	end
end

M.Start = function(self)
	self.RoundStartTime = os.time()

	self.Chart:Start()
end

M.Restart = function(self)
	self.RoundStartTime = os.time()

	self.Chart:Start()
	self:Clear()
	self:InitChessBoard()
end

M.ClickPoint = function(self, point)
	if not gChineseChessMgr:IsMyAction() then
		return
	end

	if gChineseChessMgr:IsPlayerAction() or gChineseChessMgr.IsWaitingServerMove then
		return
	end

	local chessId = self.Chart:GetChessByPoint(point)

	if self.BlockedPointUUIDMap[point] then
		gChineseChessMgr.EffectMgr:PlayBlockedPointAnimation(self.BlockedPointUUIDMap[point])
	elseif self.SelectedChessId ~= nil then
		if chessId and gChineseChessTools.IsRedChess(chessId) ~= self.Chart.IsRedPlayChess then
			self.SelectChess(self, chessId)
		end
	elseif chessId ~= self.SelectedChessId then
		self.DeselectChess(self)
	elseif chessId and gChineseChessTools.IsRedChess(chessId) ~= self.Chart.IsRedPlayChess then
		self.SelectChess(self, chessId)
	elseif self.Chart:IsValidMove(self.SelectedChessId, point) then
		gChineseChessMgr:MoveChess(self.SelectedChessId, point)
	end
end

M.MoveChessTo = function(self, chessId, point)
	if not gChineseChessMgr.IsPlaying then
		return
	end

	local toChessId = self.Chart:GetChessByPoint(point)
	local fromChessGo = self.ChessGoMap[chessId]
	local toChessGo = nil
	local selectedPoint = self.Chart:GetChessPoint(chessId)
	local isRed = gChineseChessTools.IsRedChess(chessId)
	local player = isRed and self.RedPlayer or self.BlackPlayer

	gChineseChessMgr:AddActionCompleteTask(function ()
		self:ShowLastPoint(selectedPoint)
	end)

	if toChessId then
		toChessGo = self.ChessGoMap[toChessId]

		self.RemoveChess(self, toChessId)
		player.KillChess(player, self.GetPointTransform(self, selectedPoint), self.GetPointTransform(self, point), fromChessGo, toChessGo)
	else
		local chessType = gChineseChessTools.GetChessType(chessId)

		if chessType ~= gChineseChessType.Xiang or chessType ~= gChineseChessType.Ma then
			player.MoveChess_Up(player, self.GetPointTransform(self, selectedPoint), self.GetPointTransform(self, point), fromChessGo)
		else
			player.MoveChess(player, self.GetPointTransform(self, selectedPoint), self.GetPointTransform(self, point), fromChessGo)
		end
	end

	self:RemoveAllMovePoint()
	self.Chart:MoveChess(chessId, point)
end

M.GetPointTransform = function(self, point)
	return self.PointTransforms[point]
end

M.SelectChess = function(self, chessId)
	self.DeselectChess(self)
	self.ShowChessMoviePoint(self, chessId)

	self.SelectedChessId = chessId

	self.PlaySelectChessAnimation(self, true)

	if gClientUtils.NotNil(self.ChessGoMap[chessId]) then
		gChineseChessMgr.EffectMgr:ShowChessSelectHighlight(self.ChessGoMap[chessId])
	end
end

M.DeselectChess = function(self)
	if self.SelectedChessId then
		self.PlaySelectChessAnimation(self, false)
	end

	self.SelectedChessId = nil

	self:RemoveAllMovePoint()
	gChineseChessMgr.EffectMgr:HideChessSelectHighlight()
end

M.ShowChessMoviePoint = function(self, chessId)
	if not gChineseChessMgr:IsMyAction() then
		return
	end

	local points = self.Chart:GetMovePoints(chessId)

	for _, v in pairs(points) do
		local isBlocked = self:IsCapturablePoint(chessId, v) or self:IsBlockedPoint(chessId, v)
		local pointType = isBlocked and gChineseChessMovePointType.Blocked or gChineseChessMovePointType.Movable
		local pointTf = self:GetPointTransform(v)
		local uuid = gChineseChessMgr.EffectMgr:PlayMovePointEffect(pointTf.position, pointType)
		self.MovePointMap[v] = uuid

		if isBlocked then
			self.BlockedPointUUIDMap[v] = uuid
		end
	end
end

M.IsCapturablePoint = function(self, chessId, toPoint)
	return false
end

M.IsBlockedPoint = function(self, chessId, toPoint)
	return false
end

M.RemoveAllMovePoint = function(self)
	gChineseChessMgr.EffectMgr:StopAllMovePoints(self.MovePointMap)

	self.MovePointMap = {}
	self.BlockedPointUUIDMap = {}
end

M.ShowLastPoint = function(self, point)
	local pointTf = self.GetPointTransform(self, point)

	if gClientUtils.IsNil(pointTf) then
		return
	end

	gChineseChessMgr.EffectMgr:PlayLastPointEffect(pointTf.position)
end

M.PlaySelectChessAnimation = function(self, selected, chessId)
	chessId = chessId or self.SelectedChessId

	if not chessId or gClientUtils.IsNil(self.ChessGoMap[chessId]) then
		return
	end

	local chessGo = self.ChessGoMap[chessId]
	local chessTransform = chessGo.transform

	chessTransform.DOKill(chessTransform)

	if selected then
		if not self._chessYOriginMap[chessId] then
			self._chessYOriginMap[chessId] = chessTransform.localPosition.y
		end

		local targetY = self._chessYOriginMap[chessId] + ChineseChessConfig.ChessSelectRaiseHeight

		chessTransform.DOLocalMoveY(chessTransform, targetY, ChineseChessConfig.ChessSelectAnimDuration)
	else
		local originalY = self._chessYOriginMap[chessId]

		chessTransform.DOLocalMoveY(chessTransform, originalY, ChineseChessConfig.ChessSelectAnimDuration)
	end
end

M.RemoveAllChess = function(self)
	slot1 = pairs
	slot3 = self.ChessGoMap or {}

	for _, v in slot1(slot3) do
		gClientUtils.DestroyUnityObject(v)
	end

	self.ChessGoMap = {}
	self._chessYOriginMap = {}
end

M.RemoveChess = function(self, chessId)
	self.ChessGoMap[chessId] = nil
	self._chessYOriginMap[chessId] = nil
end

M.ChangePlayer = function(self)
	self.RoundStartTime = os.time()

	self:DeselectChess()
	self.Chart:SetIsRedPlayChess(not self.Chart.IsRedPlayChess)

	self.CurrentPlayer = self.RedPlayer ~= self.CurrentPlayer and self.BlackPlayer or self.RedPlayer
	self.SelectedChessId = nil
end

M.Undo = function(self, undoStep)
	self:DeselectChess()

	local revivedChesses = self.Chart:Undo(undoStep)

	self.RedPlayer:RemoveRecycleChesses(revivedChesses)
	self.BlackPlayer:RemoveRecycleChesses(revivedChesses)
	self:InitChessBoard()
	self:UpdateLastPointAfterUndo()
end

M.UpdateLastPointAfterUndo = function(self)
	local moves = self.Chart.Moves

	if #moves ~= 0 then
		gChineseChessMgr.EffectMgr:HideLastPoint()

		return
	end

	local lastMove = moves[#moves]

	if lastMove ~= nil or #lastMove >= 4 then
		gChineseChessMgr.EffectMgr:HideLastPoint()

		return
	end

	local fromCol = string.sub(lastMove, 1, 1)
	local fromRow = string.sub(lastMove, 2, 2)
	local fromX = gChineseChessTools.UcciColToX(fromCol)
	local fromY = gChineseChessTools.UcciRowToY(fromRow)
	local fromPoint = gChineseChessTools.GetPointByPosition(fromX, fromY)

	self.ShowLastPoint(self, fromPoint)
end

M.Clear = function(self)
	self.DeselectChess(self)

	self.CurrentPlayer = self.RedPlayer

	self.RemoveAllMovePoint(self)
end

M.Destroy = function(self)
	self.RemoveAllChess(self)
	self.Clear(self)
end

return M
