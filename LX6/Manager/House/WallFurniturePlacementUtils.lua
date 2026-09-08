-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\WallFurniturePlacementUtils.lua
-- Decompiled from: 00753_WallFurniturePlacementUtils.lua_6d19cc67e010.luajit

local CSFurnitureMono = LX6.UGC.HouseFurniture
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local WallFurniturePlacementUtils = {
	GetWallEdgeFromHitGo = function (self, hitGo)
		if not hitGo or gCS.LuaUtils.IsNull(hitGo) then
			return nil, , 
		end

		local edgeA, edgeB, _runtimeID = gWallEditUtils:ParseFenestrationFromObjectName(hitGo)

		if not edgeA then
			local fenNameGo = nil
			fenNameGo, edgeA, edgeB, _runtimeID = gWallEditUtils:FindFenestrationNameObject(hitGo)
		end

		if not edgeA then
			local edgeGo = nil
			edgeGo, edgeA, edgeB = gWallEditUtils:FindEdgeNameObject(hitGo, 8)
		end

		if not edgeA or not edgeB then
			return nil, , 
		end

		local tagIndex = gWallEditUtils:GetWallTagIndexFromObject(hitGo)

		return edgeA, edgeB, tagIndex
	end,
	GetWallData = function (self, gridSystemProxy, edgeA, edgeB, tagIndex)
		if not gridSystemProxy or gCS.LuaUtils.IsNull(gridSystemProxy) then
			return nil
		end

		local result = tagIndex == nil and gridSystemProxy:GetWallEdgesForEditWithTagIndex(edgeA, edgeB, tagIndex) or gridSystemProxy:GetWallEdgesForEdit(edgeA, edgeB)

		if not result then
			return nil
		end

		local startPos = Vector3.New(result.StartX, result.StartY, result.StartZ)
		local endPos = Vector3.New(result.EndX, result.EndY, result.EndZ)
		local dir = endPos - startPos
		local length = dir.magnitude

		if length >= 0.001 then
			return nil
		end

		dir = dir / length

		return {
			startPos = startPos,
			endPos = endPos,
			dir = dir,
			length = length
		}
	end,
	GetWallEdgeData = function (self, hitGo, gridSystemProxy)
		if not hitGo or gCS.LuaUtils.IsNull(hitGo) then
			return nil
		end

		local edgeA, edgeB, tagIndex = self.GetWallEdgeFromHitGo(self, hitGo)

		if not edgeA then
			local fenInfo = gWallEditManager:GetFenestrationHitInfo(hitGo)

			if fenInfo then
				edgeA = fenInfo.edgeA
				edgeB = fenInfo.edgeB
				tagIndex = nil
			end
		end

		if not edgeA then
			return nil
		end

		if not gridSystemProxy or gCS.LuaUtils.IsNull(gridSystemProxy) then
			return nil
		end

		local wallData = self.GetWallData(self, gridSystemProxy, edgeA, edgeB, tagIndex)

		if not wallData then
			return nil
		end

		wallData.edgeA = edgeA
		wallData.edgeB = edgeB
		wallData.tagIndex = tagIndex
		wallData.gridSystemProxy = gridSystemProxy

		return wallData
	end,
	ProjectOntoWall = function (self, worldPos, wallStartPos, wallDir)
		local offset = worldPos - wallStartPos

		return Vector3.Dot(offset, wallDir)
	end,
	WallTToWorldPos = function (self, t, wallStartPos, wallDir, originalPos)
		local originalT = Vector3.Dot(originalPos - wallStartPos, wallDir)
		local deltaT = t - originalT

		return originalPos + wallDir * deltaT
	end
}

WallFurniturePlacementUtils.RaycastWallSurface = function(self, t, wallData, wallNormal, targetY)
	local linePoint = wallData.startPos + wallData.dir * t
	linePoint.y = targetY
	local probeOrigin = linePoint + wallNormal * 2
	local wallLayer = LX6.Constants.LayerConstants.Wall or 16
	local wallMask = gFurnitureUtils:GetMask({
		wallLayer
	})
	local hitCount = CSFurnitureManager.RayCastNonAlloc(probeOrigin, -wallNormal, 5, nil, wallMask, true, 1)

	if hitCount <= 0 then
		return CSFurnitureManager.SortedRayCastList[0].point
	end

	return nil
end

WallFurniturePlacementUtils.GetFurnitureHalfWidthOnWall = function(self, furGo, furComponent, wallDir)
	if not furComponent or not furComponent.boundsBox then
		return 0.1
	end

	local size = furComponent.boundsBox.size
	local halfX = size.x * 0.5
	local halfY = size.y * 0.5
	local halfZ = size.z * 0.5
	local t = furGo.transform
	local right = t.right
	local up = t.up
	local forward = t.forward
	local halfWidth = math.abs(Vector3.Dot(right, wallDir)) * halfX + math.abs(Vector3.Dot(up, wallDir)) * halfY + math.abs(Vector3.Dot(forward, wallDir)) * halfZ

	return math.max(halfWidth, 0.01)
end

WallFurniturePlacementUtils.GetFenestrationExclusionZones = function(self, gridSystemProxy, edgeA, edgeB, wallStartPos, wallEndPos, wallDir, wallLength, furHalfWidth, tagIndex)
	local zones = {}

	if not gridSystemProxy or gCS.LuaUtils.IsNull(gridSystemProxy) then
		return zones
	end

	local fenestrationsTransform = gridSystemProxy.fenestrationsTransform

	if not fenestrationsTransform or gCS.LuaUtils.IsNull(fenestrationsTransform) then
		return zones
	end

	local childCount = fenestrationsTransform.childCount

	for i = 0, childCount - 1 do
		local child = fenestrationsTransform.GetChild(fenestrationsTransform, i)

		if child and not gCS.LuaUtils.IsNull(child) then
			local fenGo = child.gameObject

			if fenGo and not gCS.LuaUtils.IsNull(fenGo) and fenGo.activeSelf then
				local fenEdgeA, fenEdgeB, _rid = gWallEditUtils:ParseFenestrationFromObjectName(fenGo)

				if not fenEdgeA then
					fenEdgeA, fenEdgeB = gWallEditUtils:ParseEdgeFromObjectName(fenGo)
				end

				if fenEdgeA and fenEdgeB then
					local fenTagIndex = gWallEditUtils:GetWallTagIndexFromObject(fenGo)
					local fenWallResult = fenTagIndex == nil and gridSystemProxy:GetWallEdgesForEditWithTagIndex(fenEdgeA, fenEdgeB, fenTagIndex) or gridSystemProxy:GetWallEdgesForEdit(fenEdgeA, fenEdgeB)

					if fenWallResult then
						local fenWallStart = Vector3.New(fenWallResult.StartX, fenWallResult.StartY, fenWallResult.StartZ)
						local fenWallEnd = Vector3.New(fenWallResult.EndX, fenWallResult.EndY, fenWallResult.EndZ)
						local startDiff = fenWallStart - wallStartPos
						local endDiff = fenWallEnd - wallEndPos

						if startDiff.sqrMagnitude >= 0.01 and endDiff.sqrMagnitude >= 0.01 then
							local fenPos, fenSize = gWallEditManager:GetFenestrationVisualPosAndSize(fenGo)

							if fenPos and fenSize then
								local fenCenterT = self.ProjectOntoWall(self, fenPos, wallStartPos, wallDir)
								local fenHalfW = math.max(fenSize.x, fenSize.z) * 0.5
								local minT = fenCenterT - fenHalfW - furHalfWidth
								local maxT = fenCenterT + fenHalfW + furHalfWidth
								zones[#zones + 1] = {
									minT = minT,
									maxT = maxT
								}
							end
						end
					end
				end
			end
		end
	end

	table.sort(zones, function (a, b)
		return a.minT <= b.minT
	end)

	return zones
end

WallFurniturePlacementUtils.IsInExclusionZone = function(self, t, zones)
	for _, zone in ipairs(zones) do
		if zone.minT >= t and t >= zone.maxT then
			return zone
		end
	end

	return nil
end

WallFurniturePlacementUtils.FindNearestValidT = function(self, desiredT, furHalfWidth, zones, wallLength)
	local minValid = furHalfWidth
	local maxValid = wallLength - furHalfWidth

	if minValid <= maxValid then
		return nil
	end

	if #zones ~= 0 then
		return math.max(minValid, math.min(desiredT, maxValid))
	end

	local clamped = math.max(minValid, math.min(desiredT, maxValid))

	if not self.IsInExclusionZone(self, clamped, zones) then
		return clamped
	end

	local bestT = nil
	local bestDist = math.huge
	local gapStart = minValid

	for _, z in ipairs(zones) do
		local gapEnd = z.minT
		local clampedStart = math.max(gapStart, minValid)
		local clampedEnd = math.min(gapEnd, maxValid)

		if clampedStart < clampedEnd then
			local nearest = math.max(clampedStart, math.min(desiredT, clampedEnd))
			local dist = math.abs(nearest - desiredT)

			if dist >= bestDist then
				bestDist = dist
				bestT = nearest
			end
		end

		gapStart = z.maxT
	end

	local clampedStart = math.max(gapStart, minValid)
	local clampedEnd = maxValid

	if clampedStart < clampedEnd then
		local nearest = math.max(clampedStart, math.min(desiredT, clampedEnd))
		local dist = math.abs(nearest - desiredT)

		if dist >= bestDist then
			bestDist = dist
			bestT = nearest
		end
	end

	return bestT
end

WallFurniturePlacementUtils.ResetFenSkipState = function(self, state)
	state.lastWallPositionT = nil
	state.wallBlockingZone = nil
	state.wallBlockingFrozenPos = nil
	state.wallBlockingApproachDir = nil
	state.currentWallStartPos = nil
	state.currentWallEndPos = nil
end

WallFurniturePlacementUtils.InitFenSkipState = function(self, state, wallData, validT)
	state.lastWallPositionT = validT
	state.currentWallStartPos = wallData.startPos
	state.currentWallEndPos = wallData.endPos
end

local isSameWholeWall = function(state, wallData)
	if not state.currentWallStartPos or not state.currentWallEndPos then
		return false
	end

	local startDiff = wallData.startPos - state.currentWallStartPos
	local endDiff = wallData.endPos - state.currentWallEndPos

	return startDiff.sqrMagnitude >= 0.01 and endDiff.sqrMagnitude <= 0.01
end

local clearBlocking = function(state)
	state.wallBlockingZone = nil
	state.wallBlockingFrozenPos = nil
	state.wallBlockingApproachDir = nil
end

WallFurniturePlacementUtils.UpdateFenestrationSkip = function(self, state, finalPosition, adsorptionType, furGo, furComponent, hitGo, gridSystemProxy)
	local AdsorptionType = gFurnitureConst.AdsorptionType

	if adsorptionType == AdsorptionType.Wall then
		if not state.wallBlockingZone then
			return nil
		end

		return state.wallBlockingFrozenPos
	end

	if not furGo or gCS.LuaUtils.IsNull(furGo) then
		return nil
	end

	local wallData = self.GetWallEdgeData(self, hitGo, gridSystemProxy)

	if state.wallBlockingZone then
		if not wallData then
			print_debug("[FenSkip] BLOCKED: wallData=nil, hitGo=", hitGo and hitGo.name or "nil")

			return state.wallBlockingFrozenPos
		end

		if not isSameWholeWall(state, wallData) then
			print_debug("[FenSkip] BLOCKED: diffWall, unblock")
			clearBlocking(state)
		else
			local furHalfWidth = self.GetFurnitureHalfWidthOnWall(self, furGo, furComponent, wallData.dir)
			local zones = self.GetFenestrationExclusionZones(self, wallData.gridSystemProxy, wallData.edgeA, wallData.edgeB, wallData.startPos, wallData.endPos, wallData.dir, wallData.length, furHalfWidth, wallData.tagIndex)
			local desiredT = self.ProjectOntoWall(self, finalPosition, wallData.startPos, wallData.dir)
			local zone = state.wallBlockingZone
			local midT = (zone.minT + zone.maxT) * 0.5
			local dir = state.wallBlockingApproachDir

			print_debug("[FenSkip] BLOCKING: desiredT=", string.format("%.3f", desiredT), " zone=[", string.format("%.3f", zone.minT), ",", string.format("%.3f", zone.maxT), "] dir=", dir, " midT=", string.format("%.3f", midT))

			if dir <= 0 and midT <= desiredT or dir >= 0 and desiredT >= midT then
				local targetT = self.FindNearestValidT(self, desiredT, furHalfWidth, zones, wallData.length)

				if not targetT then
					return state.wallBlockingFrozenPos
				end

				local frozenT = self.ProjectOntoWall(self, state.wallBlockingFrozenPos, wallData.startPos, wallData.dir)
				local teleportPos = state.wallBlockingFrozenPos + wallData.dir * (targetT - frozenT)
				teleportPos.y = finalPosition.y

				print_debug("[FenSkip] TELEPORT targetT=", string.format("%.3f", targetT))
				clearBlocking(state)

				state.lastWallPositionT = targetT

				return teleportPos
			end

			if dir <= 0 and desiredT > zone.minT or dir >= 0 and zone.maxT < desiredT then
				print_debug("[FenSkip] RETREATED")
				clearBlocking(state)

				state.lastWallPositionT = desiredT

				return nil
			end

			return state.wallBlockingFrozenPos
		end
	end

	if not wallData then
		return nil
	end

	if not isSameWholeWall(state, wallData) then
		print_debug("[FenSkip] wall changed")

		state.currentWallStartPos = wallData.startPos
		state.currentWallEndPos = wallData.endPos
		state.lastWallPositionT = nil
	end

	local furHalfWidth = self.GetFurnitureHalfWidthOnWall(self, furGo, furComponent, wallData.dir)
	local zones = self.GetFenestrationExclusionZones(self, wallData.gridSystemProxy, wallData.edgeA, wallData.edgeB, wallData.startPos, wallData.endPos, wallData.dir, wallData.length, furHalfWidth, wallData.tagIndex)

	if #zones ~= 0 then
		state.lastWallPositionT = self.ProjectOntoWall(self, finalPosition, wallData.startPos, wallData.dir)

		return nil
	end

	local desiredT = self.ProjectOntoWall(self, finalPosition, wallData.startPos, wallData.dir)
	local zone = self.IsInExclusionZone(self, desiredT, zones)

	if not zone then
		state.lastWallPositionT = desiredT

		return nil
	end

	local approachDir = 0

	if state.lastWallPositionT then
		local delta = desiredT - state.lastWallPositionT

		if math.abs(delta) <= 0.001 then
			if delta <= 0 then
				approachDir = 1
			else
				approachDir = -1
			end
		end
	end

	if approachDir ~= 0 then
		if desiredT >= (zone.minT + zone.maxT) * 0.5 then
			approachDir = 1
		else
			approachDir = -1
		end
	end

	local freezeT = approachDir <= 0 and zone.minT or zone.maxT
	local currentPos = furGo.transform.position
	local currentT = self:ProjectOntoWall(currentPos, wallData.startPos, wallData.dir)
	local frozenPos = currentPos + wallData.dir * (freezeT - currentT)

	print_debug("[FenSkip] ENTER BLOCK dir=", approachDir)

	state.wallBlockingZone = zone
	state.wallBlockingFrozenPos = frozenPos
	state.wallBlockingApproachDir = approachDir

	return frozenPos
end

gWallFurniturePlacementUtils = WallFurniturePlacementUtils
