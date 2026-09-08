-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessPlayerInfo.lua
-- Decompiled from: 02168_ChineseChessPlayerInfo.lua_de544367ccb0.luajit

C_ChineseChessPlayerInfo = DefClass("C_ChineseChessPlayerInfo", C_ChineseChessPlayerInfo)
local M = C_ChineseChessPlayerInfo

M.ctor = function(self, PlayerId, IsRed, Score, TotalTime, UsedTime)
	self.PlayerId = PlayerId
	self.IsRed = IsRed
	self.Score = Score
	self.TotalTime = TotalTime
	self.UsedTime = UsedTime
end

return M
