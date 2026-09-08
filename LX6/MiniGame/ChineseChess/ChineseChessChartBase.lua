-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessChartBase.lua
-- Decompiled from: 02161_ChineseChessChartBase.lua_fd39ee605a28.luajit

C_ChineseChessChartBase = DefClass("C_ChineseChessChartBase", C_ChineseChessChartBase)
local M = C_ChineseChessChartBase

M.ctor = function(self)
	self.Id = tostring(os.time()) .. tostring(math.random(100000, 999999))
	self._maxUndoCount = 3
	self._usedUndoCount = 0
end

M.GetChessPoint = function(self, chessID)
	return self.ChessPointMap[chessID] or -1
end

M.SetChessPoint = function(self, chessID, point)
	local oldPoint = self.ChessPointMap[chessID]

	if oldPoint and oldPoint == -1 then
		self.PointChessMap[oldPoint] = nil
	end

	self.ChessPointMap[chessID] = point

	if point == -1 then
		self.PointChessMap[point] = chessID
	end
end

M.GetChessByPoint = function(self, point)
	return self.PointChessMap[point]
end

M.PointHasChess = function(self, point)
	return self.PointChessMap[point] == nil
end

ChineseChessStep = {
	__index = ChineseChessStep,
	New = function ()
		local obj = {
			["\\x8c1!-{\\x95e\\xdc'\\xbe\\xb1"] = 0,
			["]\\xa1\\xab\\xa1\\xa2"] = 0,
			["\\xda\\xd3\r\r\\xd5"] = 0,
			mostScore = MIN_VALUE
		}

		setmetatable(obj, ChineseChessStep)

		return obj
	end,
	SetValue = function (self, _chessID, _point, _searchDepth, _mostScore)
		self.chessID = _chessID
		self.point = _point
		self.searchDepth = _searchDepth
		self.mostScore = _mostScore
	end
}

M.AddMove = function(self, from, to)
	local bestMove = gChineseChessTools:StepToBestMove(from, to, "%s%s%s%s")

	table.insert(self.Moves, bestMove)
end

M.IsValidMove = function(self, chessID, newPoint)
	local movePoints = self.GetMovePoints(self, chessID)

	for i = 1, #movePoints do
		if movePoints[i] ~= newPoint then
			return true
		end
	end

	return false
end

M.GetMovePoints = function(self, chessID)
end

M.InitChartBoard = function(self, chessIDs)
end

M.Start = function(self)
	self.ClearUndoData(self)
	self.AddUndoData(self)
end

M.InitAI = function(self, isRedAI, isBlackAI)
end

M.SetChessIds = function(self, chessIds)
end

M.GetRoundTime = function(self)
	return gChineseChessMgr.GameModeConfig.TurnTime
end

M.Clear = function(self)
end

M.AddUndoData = function(self, chessId)
end

M.GetMoveStepCount = function(self)
	return #self.UndoDataMap - 1
end

M.InitUndoLimit = function(self, maxCount)
	self._maxUndoCount = maxCount
end

M.OnServerUndoSync = function(self, usedCount)
	self._usedUndoCount = usedCount or 0
end

M.GetUndoRemainCount = function(self)
	return self._maxUndoCount - self._usedUndoCount
end

M.CanUndo = function(self)
	return #self.UndoDataMap <= 2 and self:GetUndoRemainCount() >= 0
end

M.Undo = function(self, undoStep)
end

M.IsCheck = function(self, isRed)
	return false
end

M.IsWin = function(self, isRed)
	return false
end

M.Destroy = function(self)
end

M.SetIsRedPlayChess = function(self, value)
	self.IsRedPlayChess = value
end

return M
