local FactionConfig = LTConfig.FactionConfig
local SmallAreaConfig = LTConfig.FactionInfluenceAreaConfig
local string = string
local Color = Color
local MY_GANGSTER = FactionConfig.JiaMuFaction
local INIT_AREA = 1001
GangsterAreaRenderHandler = DefClass("GangsterAreaRenderHandler", GangsterAreaRenderHandler)
local M = GangsterAreaRenderHandler

function M:ctor(id, initAreas, pointRefs)
	self.isMyGangster = id == MY_GANGSTER
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

function M:TryRemoveArea(areaId)
	if self.smallAreas[areaId] then
		self.smallAreas[areaId] = nil

		self:Rebuild()
	end
end

function M:TryAddArea(areaId)
	if not self.smallAreas[areaId] then
		self.smallAreas[areaId] = {
			lineKeys = {}
		}

		self:Rebuild()
	end
end

function M:Rebuild()
	self.allLines = {}
	self.areaGroups = {}

	for id, _ in pairs(self.smallAreas) do
		local cfg = SmallAreaConfig.GetConfig(id)

		if cfg == nil then
			print_error("GangsterAreaRenderHandler:Rebuild: 帮派id=" .. self.id .. " 配置的区域Id=" .. id .. " 不存在")
		else
			for j = 1, #cfg.ContainPoints do
				if j == #cfg.ContainPoints then
					self:AddLine(id, cfg.ContainPoints[j], cfg.ContainPoints[1])
				else
					self:AddLine(id, cfg.ContainPoints[j], cfg.ContainPoints[j + 1])
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

			while #stack > 0 do
				local currentArea = table.remove(stack)

				if not visitedAreas[currentArea] then
					visitedAreas[currentArea] = true
					currentGroup.areas[currentArea] = true

					for lineKey, lineData in pairs(self.allLines) do
						if lineData.inAreas[currentArea] then
							currentGroup.lines[lineKey] = lineData

							for neighborAreaId, _ in pairs(lineData.inAreas) do
								if neighborAreaId ~= currentArea and not visitedAreas[neighborAreaId] then
									table.insert(stack, neighborAreaId)
								end
							end
						end
					end
				end
			end

			if table.count(currentGroup.areas) > 0 then
				self.areaGroups[groupId] = currentGroup
				groupId = groupId + 1
			end
		end
	end
end

function M:AddLine(areaId, p1, p2)
	if p2 < p1 then
		p2 = p1
		p1 = p2
	end

	local key = string.format("%d_%d", p1, p2)

	if not self.allLines[key] then
		self.allLines[key] = {
			num = 1,
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

function M:CombineLinesToSingleSplineData(lines, renderInfo)
	if not lines or next(lines) == nil then
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
		isOuter = true,
		points = {},
		isDouble = renderInfo.isDouble,
		needMaterial = renderInfo.needMaterial,
		color1 = renderInfo.color1,
		color2 = renderInfo.color2,
		width = renderInfo.width
	}
	local currentPoint = startPoint
	local prevPoint = nil
	local cnt = 0

	while cnt < 300 do
		table.insert(result.points, {
			x = self.pointRefs[currentPoint].x,
			z = self.pointRefs[currentPoint].y
		})

		local nextPoint = nil

		for _, neighbor in ipairs(adjacency[currentPoint]) do
			if neighbor ~= prevPoint then
				nextPoint = neighbor

				break
			end
		end

		if not nextPoint then
			break
		end

		if nextPoint == startPoint then
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

	if cnt >= 100 then
		print_error("GangsterAreaRenderHandler:RebuildOuterLineRenderDatas: 帮派id=" .. self.id .. " 计算外边线点集时出现死循环")
	end

	return result
end

function M:ConvertToSplineData(line, renderInfo, isOuter)
	local spline = {
		points = {},
		isOuter = isOuter,
		isDouble = renderInfo.isDouble,
		needMaterial = renderInfo.needMaterial,
		color1 = renderInfo.color1,
		color2 = renderInfo.color2,
		width = renderInfo.width
	}

	for _, p in ipairs(line) do
		table.insert(spline.points, {
			x = self.pointRefs[p].x,
			z = self.pointRefs[p].y
		})
	end

	return spline
end

function M:GetPolygonRenderData(areaId, color)
	local result = {
		points = {},
		color = color
	}
	local cfg = SmallAreaConfig.GetConfig(areaId)

	for j = 1, #cfg.ContainPoints do
		local p = self.pointRefs[cfg.ContainPoints[j]]

		table.insert(result.points, {
			x = p.x,
			z = p.y
		})
	end

	return result
end

function M:GetAreaRenderData()
	local rd = {
		polygonRds = {},
		splineRds = {}
	}

	for _, areaGroup in pairs(self.areaGroups) do
		local outerLines = {}

		for lineKey, line in pairs(areaGroup.lines) do
			if line.num == 1 then
				outerLines[lineKey] = line
			else
				table.insert(rd.splineRds, self:ConvertToSplineData({
					line.p1,
					line.p2
				}, self:GetInnerLineRenderInfo(areaGroup), false))
			end
		end

		local outlineSplineData = self:CombineLinesToSingleSplineData(outerLines, self:GetOuterLineRenderInfo(areaGroup))

		if self.isMyGangster and areaGroup.areas[INIT_AREA] then
			outlineSplineData.shouldTop = true
		end

		table.insert(rd.splineRds, outlineSplineData)

		for areaId, _ in pairs(areaGroup.areas) do
			table.insert(rd.polygonRds, self:GetPolygonRenderData(areaId, self:GetPolygonColor(areaGroup)))
		end
	end

	return rd
end

function M:GetSelectSmallAreaHighlighter(smallAreaId)
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

	local result = self:CombineLinesToSingleSplineData(outerLines, self:GetHighlightRenderInfo(inAreaGroup))
	result.shouldTop = true
	result.isOuter = true
	result.isHighlight = true

	return result
end

function M:GetSelectGangsterAreaHighlighter()
	local result = {}

	for _, areaGroup in pairs(self.areaGroups) do
		local outerLines = {}

		for lineKey, line in pairs(areaGroup.lines) do
			if line.num == 1 then
				outerLines[lineKey] = line
			end
		end

		local highlightSpline = self:CombineLinesToSingleSplineData(outerLines, self:GetHighlightRenderInfo(areaGroup))
		highlightSpline.shouldTop = true
		highlightSpline.isOuter = true
		highlightSpline.isHighlight = true

		if #highlightSpline.points > 0 then
			table.insert(result, highlightSpline)
		end
	end

	return result
end

local _emptyTbl = {}

function M:BuildColorWidthCache()
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
	self.NeturalPolygonColor = Color.NewByStr(FactionConfig.NeturalPolygonColor)
	self.NeturalOuterLineColor = Color.NewByStr(FactionConfig.NeturalOuterLineColor)
	self.NeturalHighlightColor = Color.NewByStr(FactionConfig.NeturalHighlightColor)
	self.NeturalInnerLineColor = Color.NewByStr(FactionConfig.NeturalInnerLineColor)
	self.InnerLineWidth = FactionConfig.InnerLineWidth
	self.OuterLineWidth = FactionConfig.OuterLineWidth
	self.HighlighterWidth = FactionConfig.HighlighterWidth
end

function M:ClearColorWidthCache()
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

function M:GetHighlightRenderInfo(areaGroup)
	table.clear(_emptyTbl)

	local isMy = self.isMyGangster
	local isNeutral = isMy and areaGroup.areas[INIT_AREA] == nil and true or false

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

function M:GetOuterLineRenderInfo(areaGroup)
	table.clear(_emptyTbl)

	local isMy = self.isMyGangster
	local isNeutral = isMy and areaGroup.areas[INIT_AREA] == nil and true or false

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

function M:GetInnerLineRenderInfo(areaGroup)
	table.clear(_emptyTbl)

	local isMy = self.isMyGangster
	local isNeutral = isMy and areaGroup.areas[INIT_AREA] == nil and true or false
	_emptyTbl.isDouble = false
	_emptyTbl.needMaterial = false
	_emptyTbl.color1 = isNeutral and self.NeturalInnerLineColor or self.InnerLineColor
	_emptyTbl.width = self.InnerLineWidth

	return _emptyTbl
end

function M:GetPolygonColor(areaGroup)
	local isMy = self.isMyGangster
	local isNeutral = isMy and areaGroup.areas[INIT_AREA] == nil and true or false

	return isNeutral and self.NeturalPolygonColor or self.PolygonColor
end

function M:GetMidOfAreaGroup(areaGroup)
	local outerLines = {}

	for lineKey, line in pairs(areaGroup.lines) do
		if line.num == 1 then
			outerLines[lineKey] = line
		end
	end

	if next(outerLines) == nil then
		return nil
	end

	local points = gGpsTools.GetTable()
	local pointSet = gGpsTools.GetTable()

	for _, line in pairs(outerLines) do
		if not pointSet[line.p1] then
			pointSet[line.p1] = true
			local p = self.pointRefs[line.p1]

			if p then
				table.insert(points, {
					x = p.x,
					z = p.y
				})
			end
		end

		if not pointSet[line.p2] then
			pointSet[line.p2] = true
			local p = self.pointRefs[line.p2]

			if p then
				table.insert(points, {
					x = p.x,
					z = p.y
				})
			end
		end
	end

	if #points == 0 then
		return nil
	end

	local sumX = 0
	local sumZ = 0

	for _, point in ipairs(points) do
		sumX = sumX + point.x
		sumZ = sumZ + point.z
	end

	local retX = sumX / #points
	local retZ = sumZ / #points

	gGpsTools.ReleaseTable(points)
	gGpsTools.ReleaseTable(pointSet)

	return Vector3.New(retX, 0, retZ)
end

function M:IsMyInitAreaGroup(areaGroup)
	return areaGroup.areas[INIT_AREA] ~= nil
end
