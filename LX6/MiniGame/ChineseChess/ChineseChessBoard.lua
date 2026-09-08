-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessBoard.lua
-- Decompiled from: 02163_ChineseChessBoard.lua_d2b62f7fa4dc.luajit

C_ChineseChessBoard = DefClass("C_ChineseChessBoard", C_ChineseChessBoard, C_ChineseChessBoardBase)
local M = C_ChineseChessBoard

M.ctor = function(self)
end

M.InitChessBoard = function(self)
	self.RemoveAllChess(self)

	self.ChessList = self.Chart.ChessPointMap

	for chessId, v in pairs(self.ChessList) do
		if v == -1 and v then
			local chessGo = self.ChessGoMap[chessId]

			if gClientUtils.IsNil(chessGo) then
				chessGo = gChineseChessTools.InstantiateChess(chessId, self.ChesssGo)
				self.ChessGoMap[chessId] = chessGo
			end

			local point = self.Chart:GetChessPoint(chessId)
			local pointTf = self:GetPointTransform(point)

			chessGo.transform:SetParent(self.ChesssGo)
			chessGo.transform:SetPosition(pointTf.position)
			chessGo:SetActive(true)
		end
	end
end

M.MoveChessTo = function(self, chessId, point)
	C_ChineseChessBoard.base.MoveChessTo(self, chessId, point)
end

M.IsCapturablePoint = function(self, chessId, toPoint)
	return self.Chart:CheckMoveCheck(chessId, toPoint)
end

M.IsBlockedPoint = function(self, chessId, toPoint)
	return self.Chart:IsBlockedMove(chessId, toPoint)
end

return M
