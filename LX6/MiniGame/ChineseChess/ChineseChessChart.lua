-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessChart.lua
-- Decompiled from: 02164_ChineseChessChart.lua_3c75045e28d3.luajit

C_ChineseChessChart = DefClass("C_ChineseChessChart", C_ChineseChessChart, C_ChineseChessChartBase)
local bit = require("bit")
local M = C_ChineseChessChart
local UndoChessInfo = {
	__index = UndoChessInfo
}

UndoChessInfo.New = function(chessId)
	local obj = {
		chessID = chessId,
		InRangeChess = {}
	}

	setmetatable(obj, UndoChessInfo)

	return obj
end

local UndoData = {
	New = function ()
		local obj = {
			["`Om{Z60"] = "",
			["\\xf0\\xc87'\\xfa"] = false,
			["\\x82\\xa21\\xa3x;\\xff'"] = false,
			ChessPointMap = {},
			Moves = {},
			ChessInfo = {}
		}

		return obj
	end
}

M.OnCreate = function(self)
	self.ChessPointMap = {}
	self.PointChessMap = {}
	self.UndoDataMap = {}
end

M.RemoveChess = function(self, chessID)
	local point = self.ChessPointMap[chessID]

	if point and point == -1 then
		self.PointChessMap[point] = nil
	end

	self.ChessPointMap[chessID] = -1
end

M.MoveChess = function(self, chessID, toPoint)
	local fromPoint = self.ChessPointMap[chessID]

	if fromPoint then
		self.PointChessMap[fromPoint] = nil
	end

	local targetChess = self.PointChessMap[toPoint]

	if targetChess then
		self.ChessPointMap[targetChess] = -1
	end

	self.ChessPointMap[chessID] = toPoint
	self.PointChessMap[toPoint] = chessID

	self.AddMove(self, fromPoint, toPoint)
	self.AddUndoData(self, chessID, targetChess)

	return targetChess
end

M.GetBoardHash = function(self)
	local parts = {}

	for i = 0, 31 do
		local point = self.ChessPointMap[i]
		parts[i + 1] = tostring(point or -1)
	end

	parts[33] = self.IsRedPlayChess and "1" or "0"

	return table.concat(parts, ",")
end

M.GetSameSideSteps = function(self, isRed)
	local steps = {}

	for i = 1, #self.UndoDataMap do
		local undoData = self.UndoDataMap[i]

		if undoData and undoData.ChessInfo and undoData.ChessInfo.chessID then
			local stepIsRed = gChineseChessTools.IsRedChess(undoData.ChessInfo.chessID)

			if stepIsRed ~= isRed then
				table.insert(steps, i)
			end
		end
	end

	return steps
end

M.GetUndoDataChasedChess = function(self, undoData)
	local chased = {}

	if undoData ~= nil or undoData.InRangeChess ~= nil then
		return chased
	end

	for i = 1, #undoData.InRangeChess do
		local targetID = undoData.InRangeChess[i]

		if targetID == 0 and targetID == 16 then
			table.insert(chased, targetID)
		end
	end

	return chased
end

M.CheckPerpetualCheck = function(self, chessID, checkCount)
	checkCount = checkCount or 3
	local isRed = gChineseChessTools.IsRedChess(chessID)
	local checkHashes = {}
	local idx = #self.UndoDataMap

	while idx > 1 do
		local undoData = self.UndoDataMap[idx]

		if undoData and undoData.ChessInfo and undoData.ChessInfo.chessID then
			local stepIsRed = gChineseChessTools.IsRedChess(undoData.ChessInfo.chessID)

			if stepIsRed ~= isRed then
				if undoData.IsCheck then
					table.insert(checkHashes, 1, undoData.ChartHash)
				else
					break
				end
			end
		end

		idx = idx - 1
	end

	if checkCount <= #checkHashes then
		return false
	end

	local hashCount = {}

	for i = 1, #checkHashes do
		hashCount[checkHashes[i]] = (hashCount[checkHashes[i]] or 0) + 1

		if checkCount < hashCount[checkHashes[i]] then
			return true
		end
	end

	return false
end

M.CheckPerpetualThreat = function(self, chessID, threatCount)
	threatCount = threatCount or 3
	local isRed = gChineseChessTools.IsRedChess(chessID)
	local steps = self:GetSameSideSteps(isRed)

	if threatCount <= #steps then
		return false
	end

	local recentThreatSteps = {}
	local idx = #steps

	while idx > 1 and threatCount <= #recentThreatSteps do
		local undoData = self.UndoDataMap[steps[idx]]

		if undoData.IsThreat then
			table.insert(recentThreatSteps, 1, undoData)
		else
			break
		end

		idx = idx - 1
	end

	if threatCount <= #recentThreatSteps then
		return false
	end

	local hashCount = {}

	for i = 1, #recentThreatSteps do
		local h = recentThreatSteps[i].ChartHash
		hashCount[h] = (hashCount[h] or 0) + 1

		if threatCount < hashCount[h] then
			return true
		end
	end

	return false
end

M.CheckPerpetualChase = function(self, chessID, chaseCount)
	chaseCount = chaseCount or 3
	local isRed = gChineseChessTools.IsRedChess(chessID)
	local steps = self:GetSameSideSteps(isRed)

	if chaseCount <= #steps then
		return false
	end

	local recentChaseSteps = {}
	local idx = #steps

	while idx > 1 do
		local undoData = self.UndoDataMap[steps[idx]]
		local chased = self.GetUndoDataChasedChess(self, undoData)

		if #chased <= 0 then
			local chasedSet = {}

			for j = 1, #chased do
				chasedSet[chased[j]] = true
			end

			table.insert(recentChaseSteps, 1, {
				hash = undoData.ChartHash,
				chasedSet = chasedSet
			})
		else
			break
		end

		idx = idx - 1
	end

	if chaseCount <= #recentChaseSteps then
		return false
	end

	local commonChased = nil

	for i = 1, #recentChaseSteps do
		if commonChased ~= nil then
			commonChased = {}

			for k, _ in pairs(recentChaseSteps[i].chasedSet) do
				commonChased[k] = true
			end
		else
			local newCommon = {}

			for k, _ in pairs(commonChased) do
				if recentChaseSteps[i].chasedSet[k] then
					newCommon[k] = true
				end
			end

			commonChased = newCommon
		end
	end

	local hasCommonChased = false

	if commonChased then
		for _ in pairs(commonChased) do
			hasCommonChased = true

			break
		end
	end

	if not hasCommonChased then
		return false
	end

	local hashCount = {}

	for i = 1, #recentChaseSteps do
		local h = recentChaseSteps[i].hash
		hashCount[h] = (hashCount[h] or 0) + 1

		if chaseCount < hashCount[h] then
			return true
		end
	end

	return false
end

M.GetLineChessCount = function(self, point1, point2)
	local pos1 = gChineseChessTools.PointToPosition(point1)
	local pos2 = gChineseChessTools.PointToPosition(point2)
	local count = 0

	if pos1.x ~= pos2.x then
		local minY = math.min(pos1.y, pos2.y)
		local maxY = math.max(pos1.y, pos2.y)

		for y = minY + 1, maxY - 1 do
			local point = gChineseChessTools.GetPointByPosition(pos1.x, y)

			if self.PointHasChess(self, point) then
				count = count + 1
			end
		end
	elseif pos1.y ~= pos2.y then
		local minX = math.min(pos1.x, pos2.x)
		local maxX = math.max(pos1.x, pos2.x)

		for x = minX + 1, maxX - 1 do
			local point = gChineseChessTools.GetPointByPosition(x, pos1.y)

			if self.PointHasChess(self, point) then
				count = count + 1
			end
		end
	end

	return count
end

M.LineHasChess = function(self, point1, point2)
	return self:GetLineChessCount(point1, point2) >= 0
end

M.GetMovePoints = function(self, chessID)
	local result = {}
	local chessType = gChineseChessTools.GetChessType(chessID)
	local pointKey = self.GetChessPoint(self, chessID)

	if pointKey ~= -1 then
		return result
	end

	if chessType ~= gChineseChessType.Jiang then
		result = self.GetMovePoints_Shuai(self, chessID)
	elseif chessType ~= gChineseChessType.Shi then
		result = self.GetMovePoints_Shi(self, chessID)
	elseif chessType ~= gChineseChessType.Xiang then
		result = self.GetMovePoints_Xiang(self, chessID)
	elseif chessType ~= gChineseChessType.Ma then
		result = self.GetMovePoints_Ma(self, chessID)
	elseif chessType ~= gChineseChessType.Che then
		result = self.GetMovePoints_Che(self, chessID)
	elseif chessType ~= gChineseChessType.Pao then
		result = self.GetMovePoints_Pao(self, chessID)
	elseif chessType ~= gChineseChessType.Bing then
		result = self.GetMovePoints_Bing(self, chessID)
	end

	return result
end

M.GetInRangeChess = function(self, chessID, isRedChess)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)

	if pointKey ~= -1 then
		return result
	end

	local chessType = gChineseChessTools.GetChessType(chessID)

	if chessType ~= gChineseChessType.Jiang then
		result = self.GetInRangeChess_Shuai(self, chessID, isRedChess)
	elseif chessType ~= gChineseChessType.Shi then
		result = self.GetInRangeChess_Shi(self, chessID, isRedChess)
	elseif chessType ~= gChineseChessType.Xiang then
		result = self.GetInRangeChess_Xiang(self, chessID, isRedChess)
	elseif chessType ~= gChineseChessType.Ma then
		result = self.GetInRangeChess_Ma(self, chessID, isRedChess)
	elseif chessType ~= gChineseChessType.Che then
		result = self.GetInRangeChess_Che(self, chessID, isRedChess)
	elseif chessType ~= gChineseChessType.Pao then
		result = self.GetInRangeChess_Pao(self, chessID, isRedChess)
	elseif chessType ~= gChineseChessType.Bing then
		result = self.GetInRangeChess_Bing(self, chessID, isRedChess)
	end

	return result
end

M.GetMovePoints_Shuai = function(self, chessID)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]

		if self.PointHasChess(self, newPoint) then
			local targetChess = self.PointChessMap[newPoint]

			if gChineseChessTools.IsRedChess(chessID) ~= gChineseChessTools.IsRedChess(targetChess) then
				-- Nothing
			end
		else
			table.insert(result, newPoint)
		end
	end

	local enemyShuaiPoint = self.GetChessPoint(self, bit.bxor(chessID, 16))

	if enemyShuaiPoint == -1 then
		local pos1 = gChineseChessTools.PointToPosition(pointKey)
		local pos2 = gChineseChessTools.PointToPosition(enemyShuaiPoint)

		if pos1.x ~= pos2.x and self.GetLineChessCount(self, pointKey, enemyShuaiPoint) < 0 then
			table.insert(result, enemyShuaiPoint)
		end
	end

	return result
end

M.GetInRangeChess_Shuai = function(self, chessID, isRedChess)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]
		local tempChessID = self.PointChessMap[newPoint]

		if tempChessID ~= nil then
			-- Nothing
		elseif isRedChess ~= gChineseChessTools.IsRedChess(tempChessID) then
			table.insert(result, tempChessID)
		end
	end

	local enemyShuaiPoint = self.GetChessPoint(self, bit.bxor(chessID, 16))

	if enemyShuaiPoint == -1 then
		local pos1 = gChineseChessTools.PointToPosition(pointKey)
		local pos2 = gChineseChessTools.PointToPosition(enemyShuaiPoint)

		if pos1.x ~= pos2.x and self.GetLineChessCount(self, pointKey, enemyShuaiPoint) < 0 then
			table.insert(result, self.GetChessByPoint(self, enemyShuaiPoint))
		end
	end

	return result
end

M.GetMovePoints_Shi = function(self, chessID)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]

		if self.PointHasChess(self, newPoint) then
			local targetChess = self.PointChessMap[newPoint]

			if gChineseChessTools.IsRedChess(chessID) ~= gChineseChessTools.IsRedChess(targetChess) then
				-- Nothing
			end
		else
			table.insert(result, newPoint)
		end
	end

	return result
end

M.GetInRangeChess_Shi = function(self, chessID, isRedChess)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]
		local tempChessID = self.PointChessMap[newPoint]

		if tempChessID ~= nil then
			-- Nothing
		elseif isRedChess ~= gChineseChessTools.IsRedChess(tempChessID) then
			table.insert(result, tempChessID)
		end
	end

	return result
end

M.GetMovePoints_Xiang = function(self, chessID)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]

		if self.PointHasChess(self, newPoint) then
			local targetChess = self.PointChessMap[newPoint]

			if gChineseChessTools.IsRedChess(chessID) ~= gChineseChessTools.IsRedChess(targetChess) then
				-- Nothing
			end
		else
			local eyePoint = bit.rshift(pointKey + newPoint, 1)

			if not self.PointHasChess(self, eyePoint) then
				table.insert(result, newPoint)
			end
		end
	end

	return result
end

M.GetInRangeChess_Xiang = function(self, chessID, isRedChess)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]
		local eyePoint = bit.rshift(pointKey + newPoint, 1)

		if self.PointHasChess(self, eyePoint) then
			-- Nothing
		else
			local tempChessID = self.PointChessMap[newPoint]

			if tempChessID ~= nil then
				-- Nothing
			elseif isRedChess ~= gChineseChessTools.IsRedChess(tempChessID) then
				table.insert(result, tempChessID)
			end
		end
	end

	return result
end

M.GetMovePoints_Ma = function(self, chessID)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]

		if self.PointHasChess(self, newPoint) then
			local targetChess = self.PointChessMap[newPoint]

			if gChineseChessTools.IsRedChess(chessID) ~= gChineseChessTools.IsRedChess(targetChess) then
				-- Nothing
			end
		else
			local footPoint = gChineseChessTools.GetMaFootPoint(pointKey, newPoint)

			if not self.PointHasChess(self, footPoint) then
				table.insert(result, newPoint)
			end
		end
	end

	return result
end

M.GetInRangeChess_Ma = function(self, chessID, isRedChess)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]
		local footPoint = gChineseChessTools.GetMaFootPoint(pointKey, newPoint)

		if self.PointHasChess(self, footPoint) then
			-- Nothing
		else
			local tempChessID = self.PointChessMap[newPoint]

			if tempChessID ~= nil then
				-- Nothing
			elseif isRedChess ~= gChineseChessTools.IsRedChess(tempChessID) then
				table.insert(result, tempChessID)
			end
		end
	end

	return result
end

M.GetMovePoints_Che = function(self, chessID)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]

		if self.PointHasChess(self, newPoint) then
			local targetChess = self.PointChessMap[newPoint]

			if gChineseChessTools.IsRedChess(chessID) ~= gChineseChessTools.IsRedChess(targetChess) then
				-- Nothing
			end
		elseif not self.LineHasChess(self, pointKey, newPoint) then
			table.insert(result, newPoint)
		end
	end

	return result
end

M.GetInRangeChess_Che = function(self, chessID, isRedChess)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]

		if self.LineHasChess(self, pointKey, newPoint) then
			-- Nothing
		else
			local tempChessID = self.PointChessMap[newPoint]

			if tempChessID ~= nil then
				-- Nothing
			elseif isRedChess ~= gChineseChessTools.IsRedChess(tempChessID) then
				table.insert(result, tempChessID)
			end
		end
	end

	return result
end

M.GetMovePoints_Pao = function(self, chessID)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]
		local lineChessCount = self.GetLineChessCount(self, pointKey, newPoint)

		if lineChessCount <= 1 then
			-- Nothing
		elseif lineChessCount ~= 1 then
			if not self.PointHasChess(self, newPoint) then
				-- Nothing
			else
				local targetChess = self.PointChessMap[newPoint]

				if gChineseChessTools.IsRedChess(chessID) ~= gChineseChessTools.IsRedChess(targetChess) then
					-- Nothing
				end
			end
		elseif lineChessCount == 0 or not self.PointHasChess(self, newPoint) then
			table.insert(result, newPoint)
		end
	end

	return result
end

M.GetInRangeChess_Pao = function(self, chessID, isRedChess)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]
		local lineChessCount = self.GetLineChessCount(self, pointKey, newPoint)

		if lineChessCount == 1 then
			-- Nothing
		else
			local tempChessID = self.PointChessMap[newPoint]

			if tempChessID ~= nil then
				-- Nothing
			elseif isRedChess ~= gChineseChessTools.IsRedChess(tempChessID) then
				table.insert(result, tempChessID)
			end
		end
	end

	return result
end

M.GetMovePoints_Bing = function(self, chessID)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]

		if self.PointHasChess(self, newPoint) then
			local targetChess = self.PointChessMap[newPoint]

			if gChineseChessTools.IsRedChess(chessID) ~= gChineseChessTools.IsRedChess(targetChess) then
				-- Nothing
			end
		else
			table.insert(result, newPoint)
		end
	end

	return result
end

M.GetInRangeChess_Bing = function(self, chessID, isRedChess)
	local result = {}
	local pointKey = self.GetChessPoint(self, chessID)
	local movePoints = gChineseChessTools.GetMovePoints(chessID, pointKey)

	for i = 1, #movePoints do
		local newPoint = movePoints[i]
		local tempChessID = self.PointChessMap[newPoint]

		if tempChessID ~= nil then
			-- Nothing
		elseif isRedChess ~= gChineseChessTools.IsRedChess(tempChessID) then
			table.insert(result, tempChessID)
		end
	end

	return result
end

M.InitChartBoard = function(self)
	self.Clear(self)
	self.SetIsRedPlayChess(self, true)
	self.SetChessPoint(self, 0, gChineseChessTools.GetPointByPosition(7, 3))
	self.SetChessPoint(self, 1, gChineseChessTools.GetPointByPosition(6, 3))
	self.SetChessPoint(self, 2, gChineseChessTools.GetPointByPosition(8, 3))
	self.SetChessPoint(self, 3, gChineseChessTools.GetPointByPosition(5, 3))
	self.SetChessPoint(self, 4, gChineseChessTools.GetPointByPosition(9, 3))
	self.SetChessPoint(self, 5, gChineseChessTools.GetPointByPosition(4, 3))
	self.SetChessPoint(self, 6, gChineseChessTools.GetPointByPosition(10, 3))
	self.SetChessPoint(self, 7, gChineseChessTools.GetPointByPosition(3, 3))
	self.SetChessPoint(self, 8, gChineseChessTools.GetPointByPosition(11, 3))
	self.SetChessPoint(self, 9, gChineseChessTools.GetPointByPosition(4, 5))
	self.SetChessPoint(self, 10, gChineseChessTools.GetPointByPosition(10, 5))
	self.SetChessPoint(self, 11, gChineseChessTools.GetPointByPosition(3, 6))
	self.SetChessPoint(self, 12, gChineseChessTools.GetPointByPosition(5, 6))
	self.SetChessPoint(self, 13, gChineseChessTools.GetPointByPosition(7, 6))
	self.SetChessPoint(self, 14, gChineseChessTools.GetPointByPosition(9, 6))
	self.SetChessPoint(self, 15, gChineseChessTools.GetPointByPosition(11, 6))
	self.SetChessPoint(self, 16, gChineseChessTools.GetPointByPosition(7, 12))
	self.SetChessPoint(self, 17, gChineseChessTools.GetPointByPosition(6, 12))
	self.SetChessPoint(self, 18, gChineseChessTools.GetPointByPosition(8, 12))
	self.SetChessPoint(self, 19, gChineseChessTools.GetPointByPosition(5, 12))
	self.SetChessPoint(self, 20, gChineseChessTools.GetPointByPosition(9, 12))
	self.SetChessPoint(self, 21, gChineseChessTools.GetPointByPosition(4, 12))
	self.SetChessPoint(self, 22, gChineseChessTools.GetPointByPosition(10, 12))
	self.SetChessPoint(self, 23, gChineseChessTools.GetPointByPosition(3, 12))
	self.SetChessPoint(self, 24, gChineseChessTools.GetPointByPosition(11, 12))
	self.SetChessPoint(self, 25, gChineseChessTools.GetPointByPosition(4, 10))
	self.SetChessPoint(self, 26, gChineseChessTools.GetPointByPosition(10, 10))
	self.SetChessPoint(self, 27, gChineseChessTools.GetPointByPosition(3, 9))
	self.SetChessPoint(self, 28, gChineseChessTools.GetPointByPosition(5, 9))
	self.SetChessPoint(self, 29, gChineseChessTools.GetPointByPosition(7, 9))
	self.SetChessPoint(self, 30, gChineseChessTools.GetPointByPosition(9, 9))
	self.SetChessPoint(self, 31, gChineseChessTools.GetPointByPosition(11, 9))
end

M.IsCheck = function(self, isRed)
	local shuaiID = isRed and 0 or 16
	local shuaiPoint = self:GetChessPoint(shuaiID)

	if shuaiPoint ~= -1 then
		return false
	end

	local fromId, toId = nil

	if isRed then
		toId = 31
		fromId = 16
	else
		toId = 15
		fromId = 0
	end

	for chessID = fromId, toId do
		local point = self.GetChessPoint(self, chessID)

		if point == -1 then
			local attackRange = self.GetInRangeChess(self, chessID, isRed)

			for i = 1, #attackRange do
				if attackRange[i] ~= shuaiID then
					return true
				end
			end
		end
	end

	return false
end

M.CheckMoveCheck = function(self, chessID, newPoint)
	local point = self.GetChessPoint(self, chessID)
	local isRed = gChineseChessTools.IsRedChess(chessID)

	if point == -1 then
		local savedPoint = self.ChessPointMap[chessID]
		local targetChess = self.PointChessMap[newPoint]
		self.ChessPointMap[chessID] = newPoint
		self.PointChessMap[point] = nil
		self.PointChessMap[newPoint] = chessID

		if targetChess then
			self.ChessPointMap[targetChess] = -1
		end

		local stillCheck = self.IsCheck(self, isRed)
		self.ChessPointMap[chessID] = savedPoint
		self.PointChessMap[newPoint] = targetChess
		self.PointChessMap[point] = chessID

		if targetChess then
			self.ChessPointMap[targetChess] = newPoint
		end

		return stillCheck
	end

	return false
end

M.IsBlockedMove = function(self, chessID, toPoint)
	local fromPoint = self.GetChessPoint(self, chessID)

	if fromPoint ~= -1 then
		return false
	end

	local savedChessAtPoint = self.ChessPointMap[chessID]
	local targetChess = self.PointChessMap[toPoint]
	self.PointChessMap[fromPoint] = nil
	self.PointChessMap[toPoint] = chessID
	self.ChessPointMap[chessID] = toPoint

	if targetChess then
		self.ChessPointMap[targetChess] = -1
	end

	local isRed = gChineseChessTools.IsRedChess(chessID)
	local tempUndoData = UndoData.New()
	tempUndoData.ChessInfo = UndoChessInfo.New(chessID)
	tempUndoData.ChartHash = self:GetBoardHash()
	tempUndoData.IsCheck = self:IsCheck(not isRed)
	tempUndoData.TargetChess = targetChess
	tempUndoData.InRangeChess = self:GetInRangeChess(chessID, not isRed)

	table.insert(self.UndoDataMap, tempUndoData)

	local isBlocked = self:CheckPerpetualCheck(chessID) or self:CheckPerpetualThreat(chessID) or self:CheckPerpetualChase(chessID)

	table.remove(self.UndoDataMap)

	self.ChessPointMap[chessID] = savedChessAtPoint
	self.PointChessMap[toPoint] = targetChess
	self.PointChessMap[fromPoint] = chessID

	if targetChess then
		self.ChessPointMap[targetChess] = toPoint
	end

	return isBlocked
end

M.IsWin = function(self, playerInfo)
	local kingID = not playerInfo.IsRed and 0 or 16
	local kingPoint = self:GetChessPoint(kingID)

	if kingPoint ~= -1 then
		return true, playerInfo
	end

	if self.IsCheckmate(self, not playerInfo.IsRed) then
		return true, playerInfo
	end

	if self.IsDraw(self) then
		return true, nil
	end

	return false, nil
end

M.IsDraw = function(self)
	local count = #self.UndoDataMap
	local drawLimit = gChineseChessMgr.GameModeConfig.DrawMoveLimit

	if drawLimit <= count - 1 then
		return false
	end

	local IsDraw = true
	local endIndex = count - drawLimit

	for i = count, endIndex, -1 do
		local data = self.UndoDataMap[i]

		if data.TargetChess then
			IsDraw = false
		end
	end

	if IsDraw then
		return true
	end

	local drawTypes = {
		gChineseChessType.Che,
		gChineseChessType.Ma,
		gChineseChessType.Pao
	}

	for i = 0, 31 do
		local point = self.GetChessPoint(self, i)

		if point == -1 then
			local type = gChineseChessTools.GetChessType(i)

			if table.contains(drawTypes, type) then
				IsDraw = false
			end
		end
	end

	if IsDraw then
		return true
	end
end

M.IsCheckmate = function(self, isRed)
	for chessID = 0, 31 do
		if gChineseChessTools.IsRedChess(chessID) ~= isRed then
			local point = self.GetChessPoint(self, chessID)

			if point == -1 then
				local movePoints = self.GetMovePoints(self, chessID)

				for i = 1, #movePoints do
					local newPoint = movePoints[i]
					local savedPoint = self.ChessPointMap[chessID]
					local targetChess = self.PointChessMap[newPoint]
					self.ChessPointMap[chessID] = newPoint
					self.PointChessMap[point] = nil
					self.PointChessMap[newPoint] = chessID

					if targetChess then
						self.ChessPointMap[targetChess] = -1
					end

					local stillCheck = self.IsCheck(self, isRed)
					self.ChessPointMap[chessID] = savedPoint
					self.PointChessMap[newPoint] = targetChess
					self.PointChessMap[point] = chessID

					if targetChess then
						self.ChessPointMap[targetChess] = newPoint
					end

					if not stillCheck then
						return false
					end
				end
			end
		end
	end

	return true
end

M.Clone = function(self)
	local chart = C_ChineseChessChart.New()
	chart.Id = self.Id

	chart.SetIsRedPlayChess(chart, self.IsRedPlayChess)

	chart.Moves = table.shallow_clone(self.Moves)
	chart.ChessPointMap = table.shallow_clone(self.ChessPointMap)
	chart.PointChessMap = table.shallow_clone(self.PointChessMap)
	chart.UndoDataMap = table.clone(self.UndoDataMap)

	return chart
end

M.Clear = function(self)
	self.UndoDataMap = {}
	self.PointChessMap = {}
	self.ChessPointMap = {}
	self.Moves = {}
end

M.ClearUndoData = function(self)
	self.UndoDataMap = {}
end

M.AddUndoData = function(self, chessID, targetChess)
	local undoData = UndoData.New()
	undoData.ChessPointMap = table.shallow_clone(self.ChessPointMap)
	undoData.Moves = table.shallow_clone(self.Moves)

	if chessID then
		local isRed = chessID and gChineseChessTools.IsRedChess(chessID)
		local chessInfo = UndoChessInfo.New(chessID)
		undoData.ChessInfo = chessInfo
		undoData.InRangeChess = self:GetInRangeChess(chessID, not isRed)
		undoData.ChartHash = self:GetBoardHash()
		undoData.IsCheck = self:IsCheck(not isRed)
		undoData.TargetChess = targetChess
		undoData.IsThreat = self:IsThreat(chessID, not isRed)

		print("IsThreat", chessID, targetChess, undoData.IsThreat, undoData.IsCheck, undoData.ChartHash)
	end

	table.insert(self.UndoDataMap, undoData)
end

M.IsThreat = function(self, chessID, isRed)
	local point = self.GetChessPoint(self, chessID)

	if point == -1 then
		local movePoints = self.GetMovePoints(self, chessID)

		for i = 1, #movePoints do
			local newPoint = movePoints[i]
			local savedPoint = self.ChessPointMap[chessID]
			local targetChess = self.PointChessMap[newPoint]
			self.ChessPointMap[chessID] = newPoint
			self.PointChessMap[point] = nil
			self.PointChessMap[newPoint] = chessID

			if targetChess then
				self.ChessPointMap[targetChess] = -1
			end

			local stillCheck = self.IsCheckmate(self, isRed)
			self.ChessPointMap[chessID] = savedPoint
			self.PointChessMap[newPoint] = targetChess
			self.PointChessMap[point] = chessID

			if targetChess then
				self.ChessPointMap[targetChess] = newPoint
			end

			if stillCheck then
				return true
			end
		end
	end

	return false
end

M.Undo = function(self, undoStep)
	if undoStep <= #self.UndoDataMap then
		return {}
	end

	local revivedChesses = {}

	for i = 1, undoStep do
		if #self.UndoDataMap <= 1 then
			local removedData = table.remove(self.UndoDataMap, #self.UndoDataMap)

			if removedData.TargetChess then
				table.insert(revivedChesses, removedData.TargetChess)
			end
		end
	end

	local undoData = self.UndoDataMap[#self.UndoDataMap]
	self.Moves = table.shallow_clone(undoData.Moves)
	local c2p = undoData.ChessPointMap
	self.ChessPointMap = {}
	self.PointChessMap = {}

	for i, v in pairs(c2p) do
		self.SetChessPoint(self, i, v)
	end

	return revivedChesses
end

return M
