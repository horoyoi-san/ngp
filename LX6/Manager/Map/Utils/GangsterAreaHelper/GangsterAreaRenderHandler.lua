-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\GangsterAreaHelper\GangsterAreaRenderHandler.lua
-- Decompiled from: 02332_GangsterAreaRenderHandler.lua_e27dd1dcf7db.luajit

local FactionConfig = LTConfig.FactionConfig
local SmallAreaConfig = LTConfig.FactionInfluenceAreaConfig
local string = string
local math = math
local Color = Color
local MY_GANGSTER = FactionConfig.JiaMuFaction
local INIT_AREA = 1001
local LABEL_CENTER_SCANLINE_COUNT = 7
local LABEL_CENTER_EPSILON = 1e-06

local GetPointZ = function(point)
	return point.z or point.y
end

local GetSquaredDistanceToSegment = function(x, z, p1, p2)
	local p1Z = GetPointZ(p1)
	local p2Z = GetPointZ(p2)
	local dx = p2.x - p1.x
	local dz = p2Z - p1Z
	local closestX = p1.x
	local closestZ = p1Z
	local lengthSq = dx * dx + dz * dz

	if lengthSq <= 0 then
		local ratio = ((x - p1.x) * dx + (z - p1Z) * dz) / lengthSq

		if ratio <= 1 then
			closestX = p2.x
			closestZ = p2Z
		elseif ratio <= 0 then
			closestX = closestX + dx * ratio
			closestZ = closestZ + dz * ratio
		end
	end

	dx = x - closestX
	dz = z - closestZ

	return dx * dx + dz * dz
end

local IsPointInPolygon = function(x, z, pointIds, pointRefs)
	if not pointIds or #pointIds >= 3 then
		return false
	end

	local inside = false
	local previousIndex = #pointIds
	local epsilonSq = LABEL_CENTER_EPSILON * LABEL_CENTER_EPSILON

	for index = 1, #pointIds do
		local point = pointRefs[pointIds[index]]
		local previousPoint = pointRefs[pointIds[previousIndex]]

		if not point or not previousPoint then
			return false
		end

		if GetSquaredDistanceToSegment(x, z, previousPoint, point) < epsilonSq then
			return true
		end

		local pointZ = GetPointZ(point)
		local previousPointZ = GetPointZ(previousPoint)

		if z <= pointZ == (z <= previousPointZ) then
			local intersectX = (previousPoint.x - point.x) * (z - pointZ) / (previousPointZ - pointZ) + point.x

			if x >= intersectX then
				inside = not inside
			end
		end

		previousIndex = index
	end

	return inside
end

local IsPointInAreaGroup = function(x, z, areaGroup, pointRefs)
	for areaId in pairs(areaGroup.areas) do
		local config = SmallAreaConfig.GetConfig(areaId)

		if config and IsPointInPolygon(x, z, config.ContainPoints, pointRefs) then
			return true
		end
	end

	return false
end

local BuildOuterBoundary = function(areaGroup, pointRefs)
	local boundarySegments = {}
	local minX = math.huge
	local minZ = math.huge
	local maxX = -math.huge
	local maxZ = -math.huge

	for _, line in pairs(areaGroup.lines) do
		if line.num ~= 1 then
			local p1 = pointRefs[line.p1]
			local p2 = pointRefs[line.p2]

			if not p1 or not p2 then
				return nil
			end

			local p1Z = GetPointZ(p1)
			local p2Z = GetPointZ(p2)
			local dx = p2.x - p1.x
			local dz = p2Z - p1Z
			boundarySegments[#boundarySegments + 1] = {
				p1X = p1.x,
				p1Z = p1Z,
				dx = dx,
				dz = dz,
				lengthSq = dx * dx + dz * dz,
				minZ = math.min(p1Z, p2Z),
				maxZ = math.max(p1Z, p2Z),
				xPerZ = dz == 0 and dx / dz or 0
			}
			minX = math.min(minX, p1.x, p2.x)
			minZ = math.min(minZ, p1Z, p2Z)
			maxX = math.max(maxX, p1.x, p2.x)
			maxZ = math.max(maxZ, p1Z, p2Z)
		end
	end

	if #boundarySegments ~= 0 then
		return nil
	end

	return boundarySegments, minX, minZ, maxX, maxZ
end

local GetAreaGroupLabelGeometry = function(areaGroup, pointRefs)
	if areaGroup.labelGeometryBuilt then
		return areaGroup.labelBoundarySegments, areaGroup.labelMinX, areaGroup.labelMinZ, areaGroup.labelMaxX, areaGroup.labelMaxZ
	end

	local boundarySegments, minX, minZ, maxX, maxZ = BuildOuterBoundary(areaGroup, pointRefs)
	areaGroup.labelGeometryBuilt = true
	areaGroup.labelBoundarySegments = boundarySegments
	areaGroup.labelMinX = minX
	areaGroup.labelMinZ = minZ
	areaGroup.labelMaxX = maxX
	areaGroup.labelMaxZ = maxZ

	return boundarySegments, minX, minZ, maxX, maxZ
end

local GetSquaredDistanceToBoundary = function(x, z, boundarySegments)
	local minDistanceSq = math.huge

	for _, segment in ipairs(boundarySegments) do
		local closestX = segment.p1X
		local closestZ = segment.p1Z

		if segment.lengthSq <= 0 then
			local ratio = ((x - closestX) * segment.dx + (z - closestZ) * segment.dz) / segment.lengthSq
			ratio = math.max(0, math.min(1, ratio))
			closestX = closestX + segment.dx * ratio
			closestZ = closestZ + segment.dz * ratio
		end

		local dx = x - closestX
		local dz = z - closestZ
		minDistanceSq = math.min(minDistanceSq, dx * dx + dz * dz)
	end

	return minDistanceSq
end

local FindWidestInteriorSegment = function(z, boundarySegments, intersections)
	table.clear(intersections)

	for _, segment in ipairs(boundarySegments) do
		if segment.minZ < z and z >= segment.maxZ then
			intersections[#intersections + 1] = segment.p1X + (z - segment.p1Z) * segment.xPerZ
		end
	end

	if #intersections >= 2 then
		return nil
	end

	table.sort(intersections)

	local bestX = nil
	local bestWidth = 0

	for index = 1, #intersections - 1, 2 do
		local leftX = intersections[index]
		local rightX = intersections[index + 1]
		local width = rightX - leftX

		if width <= bestWidth + LABEL_CENTER_EPSILON then
			bestX = (leftX + rightX) / 2
			bestWidth = width
		end
	end

	return bestX, bestWidth
end

local IsBetterVisualCenter = function(x, z, distanceSq, width, bestX, bestZ, bestDistanceSq, bestWidth, boxCenterX, boxCenterZ)
	if not bestX or distanceSq <= bestDistanceSq + LABEL_CENTER_EPSILON then
		return true
	end

	if LABEL_CENTER_EPSILON >= math.abs(distanceSq - bestDistanceSq) then
		return false
	end

	if width <= bestWidth + LABEL_CENTER_EPSILON then
		return true
	end

	if LABEL_CENTER_EPSILON >= math.abs(width - bestWidth) then
		return false
	end

	local centerDistanceSq = (x - boxCenterX) * (x - boxCenterX) + (z - boxCenterZ) * (z - boxCenterZ)
	local bestCenterDistanceSq = (bestX - boxCenterX) * (bestX - boxCenterX) + (bestZ - boxCenterZ) * (bestZ - boxCenterZ)

	if LABEL_CENTER_EPSILON >= math.abs(centerDistanceSq - bestCenterDistanceSq) then
		return centerDistanceSq <= bestCenterDistanceSq
	end

	if LABEL_CENTER_EPSILON >= math.abs(x - bestX) then
		return x <= bestX
	end

	return z <= bestZ - LABEL_CENTER_EPSILON
end

local FindAreaGroupVisualCenter = function(areaGroup, pointRefs)
	local boundarySegments, minX, minZ, maxX, maxZ = GetAreaGroupLabelGeometry(areaGroup, pointRefs)

	if not boundarySegments then
		return nil
	end

	local height = maxZ - minZ

	if height < LABEL_CENTER_EPSILON then
		return nil
	end

	local boxCenterX = (minX + maxX) / 2
	local boxCenterZ = (minZ + maxZ) / 2
	local bestX, bestZ, bestDistanceSq, bestWidth = nil
	local intersections = {}

	for index = 1, LABEL_CENTER_SCANLINE_COUNT do
		local z = minZ + height * index / (LABEL_CENTER_SCANLINE_COUNT + 1)
		local x, width = FindWidestInteriorSegment(z, boundarySegments, intersections)

		if x then
			local distanceSq = GetSquaredDistanceToBoundary(x, z, boundarySegments)

			if IsBetterVisualCenter(x, z, distanceSq, width, bestX, bestZ, bestDistanceSq, bestWidth, boxCenterX, boxCenterZ) then
				bestX = x
				bestZ = z
				bestDistanceSq = distanceSq
				bestWidth = width
			end
		end
	end

	if not bestX or not IsPointInAreaGroup(bestX, bestZ, areaGroup, pointRefs) then
		return nil
	end

	return bestX, bestZ
end

GangsterAreaRenderHandler = DefClass("GangsterAreaRenderHandler", GangsterAreaRenderHandler)
local M = GangsterAreaRenderHandler

M.ctor = function(self, id, initAreas, pointRefs, isUnassignedFillTarget)
	self.isMyGangster = id ~= MY_GANGSTER
	self.isUnassignedFillTarget = isUnassignedFillTarget ~= true
	self.id = id
	self.smallAreas = {}

	if initAreas then
		for areaId, _ in pairs(initAreas) do
			self.smallAreas[areaId] = {
				lineKeys = {}
			}
		end
	end

	self.pointRefs = pointRefs or {}

	self:Rebuild()
end

M.TryRemoveArea = function(self, areaId)
	if self.smallAreas[areaId] then
		self.smallAreas[areaId] = nil

		self.Rebuild(self)
	end
end

M.TryAddArea = function(self, areaId)
	if not self.smallAreas[areaId] then
		self.smallAreas[areaId] = {
			lineKeys = {}
		}

		self.Rebuild(self)
	end
end

M.Rebuild = function(self)
	self.allLines = {}
	self.areaGroups = {}

	for id, _ in pairs(self.smallAreas) do
		local cfg = SmallAreaConfig.GetConfig(id)

		if cfg ~= nil then
			print_error("GangsterAreaRenderHandler:Rebuild: 帮派id=" .. self.id .. " 配置的区域Id=" .. id .. " 不存在")
		else
			self.smallAreas[id].isFillTargetArea = cfg.FactionId ~= 0

			for j = 1, #cfg.ContainPoints do
				if j ~= #cfg.ContainPoints then
					self.AddLine(self, id, cfg.ContainPoints[j], cfg.ContainPoints[1])
				else
					self.AddLine(self, id, cfg.ContainPoints[j], cfg.ContainPoints[j + 1])
				end
			end
		end
	end

	local visitedAreas = {}
	local groupId = 1

	for areaId, _ in pairs(self.smallAreas) do
		if not visitedAreas[areaId] then
			local currentGroup = {
				areas = {},
				lines = {}
			}
			local stack = {
				areaId
			}

			while #stack <= 0 do
				local currentArea = table.remove(stack)

				if not visitedAreas[currentArea] then
					visitedAreas[currentArea] = true
					currentGroup.areas[currentArea] = true

					if self.smallAreas[currentArea].isFillTargetArea then
						currentGroup.hasFillTargetArea = true
					end

					for lineKey, lineData in pairs(self.allLines) do
						if lineData.inAreas[currentArea] then
							currentGroup.lines[lineKey] = lineData

							for neighborAreaId, _ in pairs(lineData.inAreas) do
								if neighborAreaId == currentArea and not visitedAreas[neighborAreaId] then
									table.insert(stack, neighborAreaId)
								end
							end
						end
					end
				end
			end

			if table.count(currentGroup.areas) <= 0 then
				GetAreaGroupLabelGeometry(currentGroup, self.pointRefs)

				self.areaGroups[groupId] = currentGroup
				groupId = groupId + 1
			end
		end
	end
end

M.AddLine = function(self, areaId, p1, p2)
	if p2 >= p1 then
		p2 = p1
		p1 = p2
	end

	local key = string.format("%d_%d", p1, p2)

	if not self.allLines[key] then
		self.allLines[key] = {
			["\\x80}k"] = 1,
			p1 = p1,
			p2 = p2,
			inAreas = {}
		}
	else
		self.allLines[key].num = self.allLines[key].num + 1
	end

	local smallArea = self.smallAreas[areaId]

	table.insert(smallArea.lineKeys, key)

	self.allLines[key].inAreas[areaId] = true
end

M.CombineLinesToSingleSplineData = function(self, lines, renderInfo)
	if not lines or next(lines) ~= nil then
		return {}
	end

	local adjacency = {}

	for k, line in pairs(lines) do
		local p1 = line.p1
		local p2 = line.p2

		if not adjacency[p1] then
			adjacency[p1] = {}
		end

		if not adjacency[p2] then
			adjacency[p2] = {}
		end

		table.insert(adjacency[p1], p2)
		table.insert(adjacency[p2], p1)
	end

	local startPoint = next(adjacency)
	local result = {
		["\\xd0\\xc8;\n!\\xe3"] = true,
		points = {},
		isDouble = renderInfo.isDouble,
		needMaterial = renderInfo.needMaterial,
		color1 = renderInfo.color1,
		color2 = renderInfo.color2,
		width = renderInfo.width,
		isMy = renderInfo.isMy
	}
	local currentPoint = startPoint
	local prevPoint = nil
	local cnt = 0

	while cnt >= 300 do
		table.insert(result.points, {
			x = self.pointRefs[currentPoint].x,
			z = self.pointRefs[currentPoint].y
		})

		local nextPoint = nil

		for _, neighbor in ipairs(adjacency[currentPoint]) do
			if neighbor == prevPoint then
				nextPoint = neighbor

				break
			end
		end

		if not nextPoint then
			break
		end

		if nextPoint ~= startPoint then
			table.insert(result.points, {
				x = self.pointRefs[startPoint].x,
				z = self.pointRefs[startPoint].y
			})

			break
		end

		prevPoint = currentPoint
		currentPoint = nextPoint
		cnt = cnt + 1
	end

	if cnt > 100 then
		print_error("GangsterAreaRenderHandler:RebuildOuterLineRenderDatas: 帮派id=" .. self.id .. " 计算外边线点集时出现死循环")
	end

	return result
end

M.ConvertToSplineData = function(self, line, renderInfo, isOuter)
	local spline = {
		points = {},
		isOuter = isOuter,
		isDouble = renderInfo.isDouble,
		needMaterial = renderInfo.needMaterial,
		color1 = renderInfo.color1,
		color2 = renderInfo.color2,
		width = renderInfo.width,
		isMy = renderInfo.isMy
	}

	for _, p in ipairs(line) do
		table.insert(spline.points, {
			x = self.pointRefs[p].x,
			z = self.pointRefs[p].y
		})
	end

	return spline
end

M.GetPolygonRenderData = function(self, areaId, color)
	local result = {
		areaId = areaId,
		ownerFactionId = self.id,
		points = {},
		color = color,
		normalColor = self.PolygonColor
	}
	local cfg = SmallAreaConfig.GetConfig(areaId)

	if not cfg then
		print_error("GangsterAreaRenderHandler:GetPolygonRenderData: area config not found, areaId=" .. tostring(areaId))

		return result
	end

	for j = 1, #cfg.ContainPoints do
		local p = self.pointRefs[cfg.ContainPoints[j]]

		if p then
			table.insert(result.points, {
				x = p.x,
				z = p.y
			})
		else
			print_error("GangsterAreaRenderHandler:GetPolygonRenderData: point config not found, areaId=" .. tostring(areaId) .. ", pointId=" .. tostring(cfg.ContainPoints[j]))
		end
	end

	return result
end

M.GetAreaRenderData = function(self)
	local rd = {
		polygonRds = {},
		splineRds = {}
	}

	for _, areaGroup in pairs(self.areaGroups) do
		local outerLines = {}

		for lineKey, line in pairs(areaGroup.lines) do
			if line.num ~= 1 then
				outerLines[lineKey] = line
			else
				table.insert(rd.splineRds, self.ConvertToSplineData(self, {
					line.p1,
					line.p2
				}, self.GetInnerLineRenderInfo(self, areaGroup), false))
			end
		end

		local outlineSplineData = self.CombineLinesToSingleSplineData(self, outerLines, self.GetOuterLineRenderInfo(self, areaGroup))

		if self.isUnassignedFillTarget or self.isMyGangster and areaGroup.areas[INIT_AREA] then
			outlineSplineData.shouldTop = true
		end

		table.insert(rd.splineRds, outlineSplineData)

		for areaId, _ in pairs(areaGroup.areas) do
			table.insert(rd.polygonRds, self.GetPolygonRenderData(self, areaId, self.GetPolygonColor(self, areaGroup)))
		end
	end

	return rd
end

M.GetSelectSmallAreaHighlighter = function(self, smallAreaId)
	if not self.smallAreas[smallAreaId] then
		return nil
	end

	local smallArea = self.smallAreas[smallAreaId]
	local outerLines = {}

	for _, lineKey in ipairs(smallArea.lineKeys) do
		local lineData = self.allLines[lineKey]

		if lineData then
			outerLines[lineKey] = lineData
		end
	end

	local inAreaGroup = nil

	for _, areaGroup in pairs(self.areaGroups) do
		if areaGroup.areas[smallAreaId] then
			inAreaGroup = areaGroup

			break
		end
	end

	if not inAreaGroup then
		print_error("GangsterAreaRenderHandler:GetSelectSmallAreaHighlighter: 帮派id=" .. self.id .. " 小区域Id=" .. smallAreaId .. " 未找到所属区域群")

		return
	end

	local result = self.CombineLinesToSingleSplineData(self, outerLines, self.GetHighlightRenderInfo(self, inAreaGroup))
	result.shouldTop = true
	result.isOuter = true
	result.isHighlight = true

	return result
end

M.GetSelectGangsterAreaHighlighter = function(self)
	local result = {}

	for _, areaGroup in pairs(self.areaGroups) do
		local outerLines = {}

		for lineKey, line in pairs(areaGroup.lines) do
			if line.num ~= 1 then
				outerLines[lineKey] = line
			end
		end

		local highlightSpline = self.CombineLinesToSingleSplineData(self, outerLines, self.GetHighlightRenderInfo(self, areaGroup))
		highlightSpline.shouldTop = true
		highlightSpline.isOuter = true
		highlightSpline.isHighlight = true

		if #highlightSpline.points <= 0 then
			table.insert(result, highlightSpline)
		end
	end

	return result
end

local _emptyTbl = {}

M.IsNeutralAreaGroup = function(self, areaGroup)
	return self.isMyGangster and areaGroup.areas[INIT_AREA] ~= nil and not areaGroup.hasFillTargetArea
end

M.BuildColorWidthCache = function(self)
	self.NeturalPolygonColor = Color.NewByStr(FactionConfig.NeturalPolygonColor)
	self.NeturalOuterLineColor = Color.NewByStr(FactionConfig.NeturalOuterLineColor)
	self.NeturalHighlightColor = Color.NewByStr(FactionConfig.NeturalHighlightColor)
	self.NeturalInnerLineColor = Color.NewByStr(FactionConfig.NeturalInnerLineColor)

	if self.isUnassignedFillTarget then
		self.OuterLineColors = {
			self.NeturalOuterLineColor,
			self.NeturalOuterLineColor
		}
		self.InnerLineColor = self.NeturalInnerLineColor
		self.HighLighterColors = {
			self.NeturalHighlightColor,
			self.NeturalHighlightColor
		}
		self.PolygonColor = self.NeturalPolygonColor
	else
		local cfg = FactionConfig.GetConfig(self.id)
		self.OuterLineColors = {
			Color.NewByStr(cfg.OuterLineColors.normalColor1),
			Color.NewByStr(cfg.OuterLineColors.normalColor2)
		}
		self.InnerLineColor = Color.NewByStr(cfg.InnerLineColor)
		self.HighLighterColors = {
			Color.NewByStr(cfg.HighlightLineColors.color1),
			Color.NewByStr(cfg.HighlightLineColors.color2)
		}
		self.PolygonColor = Color.NewByStr(cfg.PolygonColor)
	end

	self.InnerLineWidth = FactionConfig.InnerLineWidth
	self.OuterLineWidth = FactionConfig.OuterLineWidth
	self.HighlighterWidth = FactionConfig.HighlighterWidth
end

M.ClearColorWidthCache = function(self)
	self.OuterLineColors = nil
	self.InnerLineColor = nil
	self.HighLighterColors = nil
	self.PolygonColor = nil
	self.NeturalPolygonColor = nil
	self.NeturalOuterLineColor = nil
	self.NeturalHighlightColor = nil
	self.NeturalInnerLineColor = nil
	self.InnerLineWidth = nil
	self.OuterLineWidth = nil
	self.HighlighterWidth = nil
end

M.GetHighlightRenderInfo = function(self, areaGroup)
	table.clear(_emptyTbl)

	local isMy = self.isMyGangster
	local isNeutral = self:IsNeutralAreaGroup(areaGroup)
	_emptyTbl.isMy = isMy and not isNeutral

	if isNeutral then
		_emptyTbl.isDouble = false
		_emptyTbl.needMaterial = false
		_emptyTbl.color1 = self.NeturalHighlightColor
	else
		_emptyTbl.isDouble = true
		_emptyTbl.needMaterial = true
		_emptyTbl.color1 = self.HighLighterColors[1]
		_emptyTbl.color2 = self.HighLighterColors[2]
	end

	_emptyTbl.width = self.HighlighterWidth

	return _emptyTbl
end

M.GetOuterLineRenderInfo = function(self, areaGroup)
	table.clear(_emptyTbl)

	local isMy = self.isMyGangster
	local isNeutral = self:IsNeutralAreaGroup(areaGroup)
	_emptyTbl.isMy = isMy and not isNeutral

	if isNeutral then
		_emptyTbl.isDouble = false
		_emptyTbl.needMaterial = false
		_emptyTbl.color1 = self.NeturalOuterLineColor
	else
		_emptyTbl.isDouble = true
		_emptyTbl.needMaterial = true
		_emptyTbl.color1 = self.OuterLineColors[1]
		_emptyTbl.color2 = self.OuterLineColors[2]
	end

	_emptyTbl.width = self.OuterLineWidth

	return _emptyTbl
end

M.GetInnerLineRenderInfo = function(self, areaGroup)
	table.clear(_emptyTbl)

	local isMy = self.isMyGangster
	local isNeutral = self:IsNeutralAreaGroup(areaGroup)
	_emptyTbl.isDouble = false
	_emptyTbl.needMaterial = false
	_emptyTbl.color1 = isNeutral and self.NeturalInnerLineColor or self.InnerLineColor
	_emptyTbl.width = self.InnerLineWidth
	_emptyTbl.isMy = isMy and not isNeutral

	return _emptyTbl
end

M.GetPolygonColor = function(self, areaGroup)
	local isNeutral = self:IsNeutralAreaGroup(areaGroup)

	return isNeutral and self.NeturalPolygonColor or self.PolygonColor
end

M.GetMidOfAreaGroup = function(self, areaGroup)
	if areaGroup.labelCenterX == nil then
		return Vector3.New(areaGroup.labelCenterX, 0, areaGroup.labelCenterZ)
	end

	local centerX, centerZ = FindAreaGroupVisualCenter(areaGroup, self.pointRefs)

	if not centerX then
		return nil
	end

	areaGroup.labelCenterX = centerX
	areaGroup.labelCenterZ = centerZ

	return Vector3.New(centerX, 0, centerZ)
end

M.IsMyInitAreaGroup = function(self, areaGroup)
	return areaGroup.areas[INIT_AREA] == nil
end
