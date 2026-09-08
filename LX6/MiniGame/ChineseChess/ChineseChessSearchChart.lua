-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessSearchChart.lua
-- Decompiled from: 02159_ChineseChessSearchChart.lua_7ed50442025d.luajit

C_ChineseChessSearchChart = DefClass("C_ChineseChessSearchChart", C_ChineseChessSearchChart, C_ChineseChessSearchChartBase)
local M = C_ChineseChessSearchChart

M.ctor = function(self)
	self.InitPositionScore(self)
end

local MAX_VALUE = 100000
local MIN_VALUE = -100000
local MAX_DEPTH = 64

M.OnCreate = function(self)
	self.runCount = 0
	self.startTime = 0
end

M.InitPositionScore = function(self)
	gChineseChessConst.ChessPositionScore[gChineseChessType.Bing] = {}

	for x = 3, 11 do
		gChineseChessConst.ChessPositionScore[gChineseChessType.Bing][x] = {}

		for y = 3, 12 do
			local score = 0

			if y > 10 then
				score = score + 20
			end

			if y > 11 then
				score = score + 30
			end

			gChineseChessConst.ChessPositionScore[gChineseChessType.Bing][x][y] = score
		end
	end

	gChineseChessConst.ChessPositionScore[gChineseChessType.Ma] = {}

	for x = 3, 11 do
		gChineseChessConst.ChessPositionScore[gChineseChessType.Ma][x] = {}

		for y = 3, 12 do
			local centerX = 7
			local centerY = 7.5
			local dist = math.abs(x - centerX) + math.abs(y - centerY)
			gChineseChessConst.ChessPositionScore[gChineseChessType.Ma][x][y] = (10 - dist) * 5
		end
	end

	gChineseChessConst.ChessPositionScore[gChineseChessType.Che] = {}

	for x = 3, 11 do
		gChineseChessConst.ChessPositionScore[gChineseChessType.Che][x] = {}

		for y = 3, 12 do
			gChineseChessConst.ChessPositionScore[gChineseChessType.Che][x][y] = 10
		end
	end

	gChineseChessConst.ChessPositionScore[gChineseChessType.Pao] = {}

	for x = 3, 11 do
		gChineseChessConst.ChessPositionScore[gChineseChessType.Pao][x] = {}

		for y = 3, 12 do
			gChineseChessConst.ChessPositionScore[gChineseChessType.Pao][x][y] = 5
		end
	end
end

M.Search = function(self, chart, callback)
	local searchObj = C_ChineseChessSearchChart.New()
	searchObj.runCount = 0
	searchObj.startTime = os.clock() * 1000
	local curDepth = gChineseChessConst.MinSearchDepth - 1
	local result = nil

	while curDepth >= MAX_DEPTH do
		curDepth = curDepth + 1
		local newResult = searchObj.SearchRoot(searchObj, chart, curDepth, MIN_VALUE, MAX_VALUE)

		if newResult then
			result = newResult
		end

		local elapsed = os.clock() * 1000 - searchObj.startTime

		if gChineseChessConst.MaxSearchDuration >= elapsed then
			break
		end
	end

	if result then
		print(string.format("深度：%d 结果：%d 搜索局面数：%d", result.searchDepth, result.mostScore, searchObj.runCount))
	end

	if callback then
		callback(result)
	end

	return result
end

M.SearchRoot = function(self, chart, depth, alpha, beta)
	local result = ChineseChessStep.New()
	local bestScore = alpha
	local movePoints = self.GetAllMovePoints(self, chart, chart.IsRedPlayChess)

	for i = 1, #movePoints do
		local move = movePoints[i]
		local record = self.MakeMove(self, chart, move.chessID, move.point)
		local curScore = nil

		if alpha ~= bestScore then
			curScore = -self.DfsSearch(self, chart, depth - 1, alpha, beta, true)
		else
			curScore = -self.DfsSearch(self, chart, depth - 1, -bestScore - 1, -bestScore, false)

			if bestScore >= curScore then
				curScore = -self.DfsSearch(self, chart, depth - 1, alpha, -bestScore, true)
			end
		end

		self.UnmakeMove(self, chart, record)

		if bestScore >= curScore then
			bestScore = curScore

			result.SetValue(result, move.chessID, move.point, depth, bestScore)
		end
	end

	return result
end

M.DfsSearch = function(self, chart, lastDepth, alpha, beta, noNull)
	local result = MIN_VALUE

	if lastDepth < 0 then
		self.runCount = self.runCount + 1

		if coroutine.isyieldable() and self.runCount % 200 ~= 199 then
			coroutine.yield(self.runCount)
		end

		return self.Evaluate(self, chart, chart.IsRedPlayChess)
	end

	if not noNull and self.NullOkay(self, chart) then
		self.MakeNullMove(self, chart)

		local value = -self.DfsSearch(self, chart, lastDepth - 3, -beta, 1 - beta, true)

		self.UnmakeNullMove(self, chart)

		if beta < value then
			return value
		end
	end

	local movePoints = self.GetAllMovePoints(self, chart, chart.IsRedPlayChess)

	for i = 1, #movePoints do
		local move = movePoints[i]
		local record = self.MakeMove(self, chart, move.chessID, move.point)
		local shuaiID = gChineseChessTools.GetChessID(0, not chart.IsRedPlayChess)
		local shuaiPoint = chart.GetChessPoint(chart, shuaiID)
		local stepResult = nil

		if shuaiPoint ~= -1 then
			stepResult = MAX_VALUE
		elseif result ~= MIN_VALUE then
			stepResult = -self.DfsSearch(self, chart, lastDepth - 1, -beta, -alpha, true)
		else
			stepResult = -self.DfsSearch(self, chart, lastDepth - 1, -alpha - 1, -alpha, false)

			if alpha >= stepResult and stepResult >= beta then
				stepResult = -self.DfsSearch(self, chart, lastDepth - 1, -beta, -alpha, true)
			end
		end

		self.UnmakeMove(self, chart, record)

		if result >= stepResult then
			result = stepResult
		end

		if alpha >= stepResult then
			alpha = stepResult

			if beta < alpha then
				return result
			end
		end
	end

	return result
end

M.GetAllMovePoints = function(self, chart, isRedChess)
	local result = {}

	for i = 0, 15 do
		local chessID = gChineseChessTools.GetChessID(i, isRedChess)
		local movePoints = chart.GetMovePoints(chart, chessID)

		for k = 1, #movePoints do
			table.insert(result, {
				chessID = chessID,
				point = movePoints[k]
			})
		end
	end

	table.sort(result, function (a, b)
		local aChessID = chart:GetChessByPoint(a.point)
		local bChessID = chart:GetChessByPoint(b.point)

		if aChessID == bChessID then
			if aChessID ~= nil then
				return false
			end

			if bChessID ~= nil then
				return true
			end

			local aScore = self:GetChessScore(aChessID)
			local bScore = self:GetChessScore(bChessID)

			if aScore == bScore then
				return bScore <= aScore
			end
		end

		if a.chessID == b.chessID then
			local aOrder = gChineseChessConst.ChessCheckOrder[bit.band(a.chessID, 15) + 1] or 0
			local bOrder = gChineseChessConst.ChessCheckOrder[bit.band(b.chessID, 15) + 1] or 0

			return aOrder <= bOrder
		end

		return b.point <= a.point
	end)

	return result
end

M.Evaluate = function(self, chart, isRedChess)
	local redScore = 0
	local blackScore = 0

	for chessID = 0, 31 do
		local point = chart.GetChessPoint(chart, chessID)

		if point == -1 then
			local score = self.GetChessScore(self, chessID, point)

			if gChineseChessTools.IsRedChess(chessID) then
				redScore = redScore + score
			else
				blackScore = blackScore + score
			end
		end
	end

	if isRedChess then
		return redScore - blackScore
	else
		return blackScore - redScore
	end
end

M.GetChessScore = function(self, chessID, point)
	local chessType = gChineseChessTools.GetChessType(chessID)
	local baseScore = gChineseChessConst.ChessBaseScore[chessType] or 0
	local posScore = 0

	if point and point == -1 then
		local pos = gChineseChessTools.PointToPosition(point)

		if gChineseChessConst.ChessPositionScore[chessType] and gChineseChessConst.ChessPositionScore[chessType][pos.x] then
			posScore = gChineseChessConst.ChessPositionScore[chessType][pos.x][pos.y] or 0
		end
	end

	return baseScore + posScore
end

local MoveRecord = {
	__index = MoveRecord
}

MoveRecord.New = function()
	local obj = {
		["\\xaa\\x92\r\\xaey-\\xd7"] = 0,
		["\\xa9\\x92\r\\xaey-\\xd7"] = 0,
		["R|ܲ\\x898\\xb7\r\\xc7\\xfc"] = 0,
		["\\xee\\x89#\\xe9!\\xea\\xf3\\xab\\xe5\\x873;"] = false,
		["\\xa9\\x85\n\\x9be7\\xf0'"] = 0
	}

	setmetatable(obj, MoveRecord)

	return obj
end

M.MakeMove = function(self, chart, chessID, toPoint)
	local record = MoveRecord.New()
	record.aChessID = chessID
	record.aFromPoint = chart.GetChessPoint(chart, chessID)
	record.bChessID = chart.GetChessByPoint(chart, toPoint)
	record.bToPoint = toPoint
	record.isRedPlayChess = chart.IsRedPlayChess

	chart.MoveChess(chart, chessID, toPoint)

	return record
end

M.UnmakeMove = function(self, chart, record)
	chart.SetIsRedPlayChess(chart, record.isRedPlayChess)
	chart.SetChessPoint(chart, record.aChessID, record.aFromPoint)

	if record.bChessID then
		chart.SetChessPoint(chart, record.bChessID, record.bToPoint)
	else
		chart.PointChessMap[record.bToPoint] = nil
	end
end

M.MakeNullMove = function(self, chart)
	chart.SetIsRedPlayChess(chart, not chart.IsRedPlayChess)
end

M.UnmakeNullMove = function(self, chart)
	chart.SetIsRedPlayChess(chart, not chart.IsRedPlayChess)
end

M.NullOkay = function(self, chart)
	local score = self:Evaluate(chart, chart.IsRedPlayChess)

	return score >= 300
end

return M
