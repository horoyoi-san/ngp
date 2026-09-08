-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessEntry.lua
-- Decompiled from: 02154_ChineseChessEntry.lua_e093120a2a78.luajit

local require = require

if gChineseChessTools and gChineseChessTools.hotfixFunc then
	require = gChineseChessTools.hotfixFunc
end

require("LX6/MiniGame/ChineseChess/ChineseChessEnum")
require("LX6/MiniGame/ChineseChess/ChineseChessPlayerSlotEnum")
require("LX6/MiniGame/ChineseChess/ChineseChessConfig")
require("LX6/MiniGame/ChineseChess/ChineseChessSearchChartBase")
require("LX6/MiniGame/ChineseChess/ChineseChessSearchChart")
require("LX6/MiniGame/ChineseChess/ChineseChessSearchChartFlip")
require("LX6/MiniGame/ChineseChess/ChineseChessChartBase")
require("LX6/MiniGame/ChineseChess/ChineseChessBoardBase")
require("LX6/MiniGame/ChineseChess/ChineseChessBoard")
require("LX6/MiniGame/ChineseChess/ChineseChessChart")
require("LX6/MiniGame/ChineseChess/ChineseChessFlipChart")
require("LX6/MiniGame/ChineseChess/ChineseChessFlipBoard")
require("LX6/MiniGame/ChineseChess/ChineseChessTools")
require("LX6/MiniGame/ChineseChess/ChineseChessPlayerInfo")
require("LX6/MiniGame/ChineseChess/ChineseChessPlayer")
require("LX6/MiniGame/ChineseChess/ChineseChessEffectMgr")
require("LX6/MiniGame/ChineseChess/ChineseChessMgr")
