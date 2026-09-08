-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessFlipChart.lua
-- Decompiled from: 02165_ChineseChessFlipChart.lua_ecfe937daf44.luajit

C_ChineseChessFlipChart = DefClass("C_ChineseChessFlipChart", C_ChineseChessFlipChart, C_ChineseChessChartBase)
local M = C_ChineseChessFlipChart
local UndoData = {
	New = function ()
		local obj = {
			ChessPointMap = {},
			FaceDownMap = {},
			PlayerInfos = {},
			Moves = {}
		}

		return obj
	end
}
local UndoPlayerData = {
	New = function ()
		local obj = {
			["~\\xad\\xad\\xbd\\xb3"] = 0
		}

		return obj
	end
}

M.ctor = function(self)
	math.randomseed(os.time())
	self.InitChartBoard(self)
end

M.RandomRange = function(self, min, max)
	return math.floor(math.random() * (max - min + 1)) + min
end

M.ShuffleArray = function(self, arr)
	for i = #arr, 2, -1 do
		local j = self.RandomRange(self, 1, i)
		arr[j] = arr[i]
		arr[i] = arr[j]
	end

	return arr
end

M.OnCreate = function(self)
	self.ChessPointMap = {}
	self.PointChessMap = {}
	self.FaceDownMap = {}
end

M.InitChartBoard = function(self, chessIDs, flipChessIds)
	self.Clear(self)
	self.SetIsRedPlayChess(self, true)
	self.OnCreate(self)

	local allPositions = {}

	for x = 0, 7 do
		for y = 0, 3 do
			table.insert(allPositions, x * 4 + y)
		end
	end

	if chessIDs ~= nil then
		chessIDs = {}

		for i = 0, 31 do
			table.insert(chessIDs, i)
		end

		chessIDs = self.ShuffleArray(self, chessIDs)
	end

	self.SetChessIds(self, chessIDs, allPositions)

	if flipChessIds then
		self.FlipChesses(self, flipChessIds)
	else
		flipChessIds = {}

		for i = 0, 3 do
			table.insert(flipChessIds, self.RandomFlipChess(self, i * 8))
		end
	end

	self.FlipChesses(self, flipChessIds)
	self.ClearUndoData(self)
end

M.RandomFlipChess = function(self, beginIndex)
	local point = math.floor(math.random(beginIndex, beginIndex + 3))

	return self.GetChessByPoint(self, point)
end

M.SetChessIds = function(self, chessIDs, allPositions)
	for i = 1, 32 do
		self.SetChessPoint(self, chessIDs[i], allPositions[i])

		self.FaceDownMap[chessIDs[i]] = true
	end
end

M.IsFaceDown = function(self, chessID)
	if chessID ~= nil then
		return false
	end

	return self.FaceDownMap[chessID] ~= true
end

M.PointHasFaceDown = function(self, point)
	local chessID = self.PointChessMap[point]

	if chessID then
		return self.FaceDownMap[chessID] ~= true
	end

	return false
end

M.FlipChess = function(self, point, isInit)
	local chessID = self.PointChessMap[point]

	if chessID ~= nil then
		return nil
	end

	if not self.FaceDownMap[chessID] then
		return nil
	end

	self.FaceDownMap[chessID] = false

	if not isInit then
		self.AddUndoData(self, chessID)
	end

	return chessID
end

M.FlipChesses = function(self, chessIds)
	for _, chessID in ipairs(chessIds) do
		self.FlipChess(self, self.GetChessPoint(self, chessID), true)
	end
end

M.GetChessRank = function(self, chessID)
	local chessType = gChineseChessTools.GetChessType(chessID)

	return gChineseChessConst.ChessRank[chessType] or 0
end

M.CanCapture = function(self, attackerID, defenderID)
	if gChineseChessTools.GetChessType(attackerID) ~= gChineseChessType.Pao then
		return true
	end

	local attackerType = gChineseChessTools.GetChessType(attackerID)
	local defenderType = gChineseChessTools.GetChessType(defenderID)

	if attackerType ~= gChineseChessType.Jiang and defenderType ~= gChineseChessType.Bing then
		return false
	end

	local attackerRank = self.GetChessRank(self, attackerID)
	local defenderRank = self.GetChessRank(self, defenderID)

	if defenderRank < attackerRank then
		return true
	else
		if attackerRank ~= 1 and defenderRank ~= 7 then
			return true
		end

		return false
	end
end

M.RemoveChess = function(self, chessID)
	local point = self.ChessPointMap[chessID]

	if point and point == -1 then
		self.PointChessMap[point] = nil
	end

	self.ChessPointMap[chessID] = -1
	self.FaceDownMap[chessID] = nil
end

M.MoveChess = function(self, chessID, toPoint)
	local fromPoint = self.ChessPointMap[chessID]
	local isPao = gChineseChessTools.GetChessType(chessID) ~= gChineseChessType.Pao
	local isSelfDamage = false
	local targetChess = self.PointChessMap[toPoint]

	if targetChess then
		if isPao and self.IsFaceDown(self, targetChess) then
			self.FaceDownMap[targetChess] = false
			isSelfDamage = gChineseChessTools.IsRedChess(chessID) ~= gChineseChessTools.IsRedChess(targetChess)
		elseif not self.CanCapture(self, chessID, targetChess) then
			return nil, false, false
		end

		self.ChessPointMap[targetChess] = -1
		self.FaceDownMap[targetChess] = nil
	end

	if fromPoint then
		self.PointChessMap[fromPoint] = nil
	end

	self.ChessPointMap[chessID] = toPoint

	if toPoint == -1 then
		self.PointChessMap[toPoint] = chessID
	end

	self.AddMove(self, fromPoint, toPoint)
	self.AddUndoData(self, chessID)

	return targetChess, true, isSelfDamage
end

M.GetLineChessCount = function(self, point1, point2)
	return 0
end

M.LineHasChess = function(self, point1, point2)
	return false
end

M.GetMovePoints = function(self, chessID)
	if self.IsFaceDown(self, chessID) then
		return {}
	end

	local result = {}
	local pointKey = self:GetChessPoint(chessID)
	local isPao = gChineseChessTools.GetChessType(chessID) ~= gChineseChessType.Pao

	if pointKey ~= -1 or self.IsFaceDown(self, chessID) then
		return result
	end

	local pos = gChineseChessTools.GetFlipPointToPosition(pointKey)
	local directions = {
		{
			["\\xd5"] = 0,
			["\\xd4"] = 1
		},
		{
			["\\xd5"] = 0,
			["\\xd4"] = -1
		},
		{
			["\\xd5"] = 1,
			["\\xd4"] = 0
		},
		{
			["\\xd5"] = -1,
			["\\xd4"] = 0
		}
	}

	for i = 1, #directions do
		local dir = directions[i]
		local newX = pos.x + dir.x
		local newY = pos.y + dir.y
		local newPoint = gChineseChessTools.GetFlipPointByPosition(newX, newY)

		if gChineseChessTools.IsInFlipBoard(newX, newY) then
			if not isPao and not self.PointHasChess(self, newPoint) then
				table.insert(result, newPoint)
			end

			if isPao then
				local hasMount = false
				local scanX = pos.x + dir.x
				local scanY = pos.y + dir.y

				while gChineseChessTools.IsInFlipBoard(scanX, scanY) do
					local scanPoint = gChineseChessTools.GetFlipPointByPosition(scanX, scanY)

					if self.PointHasChess(self, scanPoint) then
						if not hasMount then
							hasMount = true
						else
							local targetChess = self.PointChessMap[scanPoint]

							if self.IsFaceDown(self, targetChess) then
								table.insert(result, scanPoint)

								break
							end

							if gChineseChessTools.IsRedChess(chessID) == gChineseChessTools.IsRedChess(targetChess) then
								table.insert(result, scanPoint)
							end

							break
						end
					end

					scanX = scanX + dir.x
					scanY = scanY + dir.y
				end
			elseif self.PointHasChess(self, newPoint) then
				local targetChess = self.PointChessMap[newPoint]

				if self.IsFaceDown(self, targetChess) then
					-- Nothing
				elseif gChineseChessTools.IsRedChess(chessID) ~= gChineseChessTools.IsRedChess(targetChess) then
					-- Nothing
				elseif self.CanCapture(self, chessID, targetChess) then
					table.insert(result, newPoint)
				end
			end
		end
	end

	return result
end

M.GetInRangeChess = function(self, chessID, isRedChess)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)

	if pointKey ~= -1 or self.IsFaceDown(self, chessID) then
		return result
	end

	local pos = gChineseChessTools.GetFlipPointToPosition(pointKey)
	local directions = {
		{
			["\\xd5"] = 0,
			["\\xd4"] = 1
		},
		{
			["\\xd5"] = 0,
			["\\xd4"] = -1
		},
		{
			["\\xd5"] = 1,
			["\\xd4"] = 0
		},
		{
			["\\xd5"] = -1,
			["\\xd4"] = 0
		}
	}

	for i = 1, #directions do
		local dir = directions[i]
		local newX = pos.x + dir.x
		local newY = pos.y + dir.y
		local newPoint = gChineseChessTools.GetFlipPointByPosition(newX, newY)

		if gChineseChessTools.IsInFlipBoard(newPoint) then
			local tempChessID = self.PointChessMap[newPoint]

			if tempChessID and not self.IsFaceDown(self, tempChessID) and isRedChess ~= gChineseChessTools.IsRedChess(tempChessID) then
				table.insert(result, tempChessID)
			end
		end
	end

	return result
end

M.IsGameEnd = function(self)
	local redCount = 0
	local blackCount = 0

	for chessID = 0, 31 do
		local point = self.ChessPointMap[chessID]

		if point and point == -1 then
			if gChineseChessTools.IsRedChess(chessID) then
				redCount = redCount + 1
			else
				blackCount = blackCount + 1
			end
		end
	end

	if redCount ~= 0 then
		return true, false
	end

	if blackCount ~= 0 then
		return true, true
	end

	return false, nil
end

M.Clear = function(self)
	self.UndoDataMap = {}
	self.FaceDownMap = {}
	self.PointChessMap = {}
	self.ChessPointMap = {}
	self.Moves = {}
end

M.AddUndoData = function(self)
	local undoData = UndoData.New()
	undoData.ChessPointMap = table.shallow_clone(self.ChessPointMap)
	undoData.FaceDownMap = table.shallow_clone(self.FaceDownMap)
	undoData.Moves = table.shallow_clone(self.Moves)
	local redPlayerData = UndoPlayerData.New()
	redPlayerData.IsRed = true
	redPlayerData.Score = gChineseChessMgr:GetPlayerInfo(true).Score
	local blackPlayerData = UndoPlayerData.New()
	blackPlayerData.IsRed = false
	blackPlayerData.Score = gChineseChessMgr:GetPlayerInfo(false).Score
	undoData.PlayerInfos[0] = redPlayerData
	undoData.PlayerInfos[1] = blackPlayerData

	table.insert(self.UndoDataMap, undoData)
end

M.ClearUndoData = function(self)
	self.UndoDataMap = {}
end

M.Undo = function(self, undoStep)
	if undoStep <= #self.UndoDataMap then
		return {}
	end

	for i = 1, undoStep do
		if #self.UndoDataMap <= 1 then
			table.remove(self.UndoDataMap, #self.UndoDataMap)
		end
	end

	local undoData = self.UndoDataMap[#self.UndoDataMap]
	local revivedChesses = {}

	for chessId, savedPoint in pairs(undoData.ChessPointMap) do
		local currentPoint = self.ChessPointMap[chessId]

		if savedPoint == -1 and (currentPoint ~= nil or currentPoint ~= -1) then
			table.insert(revivedChesses, chessId)
		end
	end

	self.Moves = table.shallow_clone(undoData.Moves)
	local c2p = undoData.ChessPointMap
	local f2p = undoData.FaceDownMap
	self.ChessPointMap = {}
	self.PointChessMap = {}

	for i, v in pairs(c2p) do
		self.SetChessPoint(self, i, v)
	end

	self.FaceDownMap = table.shallow_clone(f2p)
	local redPlayer = gChineseChessMgr:GetPlayerInfo(true)
	local blackPlayer = gChineseChessMgr:GetPlayerInfo(false)
	redPlayer.Score = undoData.PlayerInfos[0].Score
	blackPlayer.Score = undoData.PlayerInfos[1].Score

	return revivedChesses
end

M.IsWin = function(self, playerInfo)
	local moveLimit = gChineseChessMgr.GameModeConfig.DrawMoveLimit

	if moveLimit < self.GetMoveStepCount(self) then
		return true, nil
	end

	local redPlayer = gChineseChessMgr:GetPlayerInfo(true)
	local blackPlayer = gChineseChessMgr:GetPlayerInfo(false)

	if redPlayer.Score < 0 then
		return true, blackPlayer
	end

	if blackPlayer.Score < 0 then
		return true, redPlayer
	end

	return false, nil
end

M.Destroy = function(self)
end

return M
