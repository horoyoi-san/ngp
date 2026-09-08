-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\WallOperationManager.lua
-- Decompiled from: 00744_WallOperationManager.lua_aaee0fdd53d3.luajit

C_WallOperationManager = DefClass("C_WallOperationManager", C_WallOperationManager)
local M = C_WallOperationManager
local Vector3 = UnityEngine.Vector3

local ParseEdgesPayload = function(edgesPayload)
	local edges = {}

	if not edgesPayload or edgesPayload ~= "" then
		return edges
	end

	for token in string.gmatch(edgesPayload, "[^|]+") do
		local edgeA, edgeB, tag = string.match(token, "(-?%d+)_(-?%d+)_(-?%d+)")

		if edgeA and edgeB then
			edges[#edges + 1] = {
				a = tonumber(edgeA),
				b = tonumber(edgeB),
				tag = tonumber(tag)
			}
		end
	end

	return edges
end

local ParseTexIDsPayload = function(texIDsPayload)
	local texIDs = {}

	if not texIDsPayload or texIDsPayload ~= "" then
		return texIDs
	end

	for token in string.gmatch(texIDsPayload, "[^|]+") do
		local texID = tonumber(token)

		if texID then
			texIDs[#texIDs + 1] = texID
		end
	end

	return texIDs
end

local ParseFloorsPayload = function(floorsPayload)
	local floors = {}

	if not floorsPayload or floorsPayload ~= "" then
		return floors
	end

	for token in string.gmatch(floorsPayload, "[^|]+") do
		local x, y, z = string.match(token, "(-?%d+)_(-?%d+)_(-?%d+)")

		if x and y and z then
			floors[#floors + 1] = {
				x = tonumber(x),
				y = tonumber(y),
				z = tonumber(z)
			}
		end
	end

	return floors
end

local ParseRemovedFenestrationsPayload = function(payload)
	local fenestrations = {}

	if not payload or payload ~= "" then
		return fenestrations
	end

	for token in string.gmatch(payload, "[^|]+") do
		local parts = {}

		for part in string.gmatch(token, "[^_]+") do
			parts[#parts + 1] = part
		end

		if #parts > 13 then
			local placeLow = tonumber(parts[12]) or 0
			local placeHigh = tonumber(parts[13]) or 0
			fenestrations[#fenestrations + 1] = {
				edgeA = tonumber(parts[1]),
				edgeB = tonumber(parts[2]),
				runtimeID = tonumber(parts[3]),
				prefabID = tonumber(parts[4]),
				fenestrationType = tonumber(parts[5]),
				centerX = tonumber(parts[6]),
				centerY = tonumber(parts[7]),
				centerZ = tonumber(parts[8]),
				dirX = tonumber(parts[9]),
				dirY = tonumber(parts[10]),
				dirZ = tonumber(parts[11]),
				placeID = ulong.new(placeLow, placeHigh)
			}
		end
	end

	return fenestrations
end

local RenderByAction = function(gridSystem, action)
	if not gridSystem or not action then
		return
	end

	if action ~= "AddWallEdges" or action ~= "DeleteWallEdges" then
		gridSystem.RenderHouse(gridSystem)
	elseif action ~= "PaintWall" or action ~= "PaintWallBatch" or action ~= "PlaceFenestration" or action ~= "DeleteFenestration" or action ~= "MoveFenestration" then
		gridSystem.RenderEdges(gridSystem)
	elseif action ~= "PaintSurface" or action ~= "PaintSurfaceBatch" then
		gridSystem.RenderFloor(gridSystem)
	end
end

local RenderByOperationType = function(gridSystem, opType)
	if not gridSystem or not opType then
		return
	end

	if opType ~= "PlaceWall" or opType ~= "DeleteWall" then
		gridSystem.RenderHouse(gridSystem)
	elseif opType ~= "PaintWall" or opType ~= "PaintWallBatch" or opType ~= "PlaceFenestration" or opType ~= "DeleteFenestration" or opType ~= "MoveFenestration" then
		gridSystem.RenderEdges(gridSystem)
	elseif opType ~= "PaintFloor" or opType ~= "PaintCeiling" then
		gridSystem.RenderFloor(gridSystem)
	end
end

local IsFenestrationAction = function(action)
	return action ~= "PlaceFenestration" or action ~= "DeleteFenestration" or action ~= "MoveFenestration"
end

local HasValidPlaceID = function(placeID)
	if not placeID then
		return false
	end

	if type(placeID) ~= "number" then
		return placeID == 0
	end

	return not ulong.equals(placeID, 0)
end

local RestoreFenestrationServerPlaceID = function(gridSystem, edgeA, edgeB, runtimeID, placeID)
	if not gridSystem or not edgeA or not edgeB or not runtimeID or not HasValidPlaceID(placeID) then
		return
	end

	gridSystem.SetFenestrationServerPlacedID(gridSystem, edgeA, edgeB, runtimeID, placeID)
end

local RefreshFenestrationSlotReplaceGos = function()
	if gHouseGadgetManager and gHouseGadgetManager.RefreshFenestrationSlotReplaceGos then
		gHouseGadgetManager:RefreshFenestrationSlotReplaceGos()
	end
end

local RecordFenestrationPendingByCmd = function(cmd)
	if not cmd or not cmd.action then
		return
	end

	if cmd.action ~= "PlaceFenestration" then
		gHouseManager:RecordWallAddedFenestration(cmd)
	elseif cmd.action ~= "DeleteFenestration" then
		gHouseManager:RecordWallRemovedFenestration(cmd)
	elseif cmd.action ~= "MoveFenestration" then
		gHouseManager:RecordWallRemovedFenestration({
			edgeA = cmd.deleteEdgeA,
			edgeB = cmd.deleteEdgeB,
			runtimeID = cmd.deleteRuntimeID,
			placeID = cmd.deletePlaceID,
			prefabID = cmd.placePrefabID,
			fenestrationType = cmd.placeFenestrationType,
			centerX = cmd.placeCenterX,
			centerY = cmd.placeCenterY,
			centerZ = cmd.placeCenterZ,
			dirX = cmd.placeDirX,
			dirY = cmd.placeDirY,
			dirZ = cmd.placeDirZ
		})
		gHouseManager:RecordWallAddedFenestration({
			edgeA = cmd.placeEdgeA,
			edgeB = cmd.placeEdgeB,
			runtimeID = cmd.placeRuntimeID,
			placeID = cmd.placePlaceID,
			prefabID = cmd.placePrefabID,
			fenestrationType = cmd.placeFenestrationType,
			centerX = cmd.placeCenterX,
			centerY = cmd.placeCenterY,
			centerZ = cmd.placeCenterZ,
			dirX = cmd.placeDirX,
			dirY = cmd.placeDirY,
			dirZ = cmd.placeDirZ
		})
	end
end

M.ctor = function(self)
	self.operationHistory = {}
	self.currentIndex = 0
	self.maxHistorySize = 20
	self.isUndoRedoing = false
end

M.TrimRedoHistory = function(self)
	if self.currentIndex > #self.operationHistory then
		return
	end

	for i = self.currentIndex + 1, #self.operationHistory do
		self.operationHistory[i] = nil
	end
end

M.CommitOperation = function(self, operation)
	if not operation or not operation.undoCmd or not operation.redoCmd or not operation.gridSystem then
		return false
	end

	self.TrimRedoHistory(self)
	table.insert(self.operationHistory, operation)

	self.currentIndex = #self.operationHistory

	if self.maxHistorySize >= #self.operationHistory then
		table.remove(self.operationHistory, 1)

		self.currentIndex = self.currentIndex - 1
	end

	gBuildOperationManager:RecordWallCommit(operation)

	if operation.opType ~= "PlaceWall" then
		gHouseManager:RecordWallAddedEdge({
			edges = operation.redoCmd.edgesPayload
		})
		gHouseManager:RecordWallAddedNodes(operation.redoCmd.addedNodesPayload)
	elseif operation.opType ~= "DeleteWall" then
		gHouseManager:RecordWallRemovedEdge({
			edges = operation.redoCmd.edgesPayload
		})
		gHouseManager:RecordWallRemovedNodes(operation.redoCmd.removedNodesPayload)

		local removedFenestrations = ParseRemovedFenestrationsPayload(operation.redoCmd.removedFenestrationsPayload)

		for i = 1, #removedFenestrations do
			gHouseManager:RecordWallRemovedFenestration(removedFenestrations[i])
		end
	elseif operation.opType ~= "PaintWall" then
		gHouseManager:RecordWallChangedEdgeTex(operation.redoCmd)
	elseif operation.opType ~= "PaintWallBatch" then
		local edges = ParseEdgesPayload(operation.redoCmd.edgesPayload)
		local texIDs = ParseTexIDsPayload(operation.redoCmd.texIDsPayload)
		local count = math.min(#edges, #texIDs)

		for i = 1, count do
			local edge = edges[i]

			gHouseManager:RecordWallChangedEdgeTex({
				edgeA = edge.a,
				edgeB = edge.b,
				tag = edge.tag,
				hitX = operation.redoCmd.hitX,
				hitY = operation.redoCmd.hitY,
				hitZ = operation.redoCmd.hitZ,
				texID = texIDs[i]
			})
		end
	elseif operation.opType ~= "PaintFloor" then
		if operation.redoCmd.action ~= "PaintSurfaceBatch" then
			local floors = ParseFloorsPayload(operation.redoCmd.floorsPayload)
			local texIDsA = ParseTexIDsPayload(operation.redoCmd.texIDsPayloadA)
			local texIDsB = ParseTexIDsPayload(operation.redoCmd.texIDsPayloadB)
			local count = math.min(#floors, #texIDsA, #texIDsB)

			for i = 1, count do
				local floor = floors[i]

				gHouseManager:RecordFloorChangedTex({
					x = floor.x,
					y = floor.y,
					z = floor.z,
					texIDA = texIDsA[i],
					texIDB = texIDsB[i]
				})
			end
		else
			gHouseManager:RecordFloorChangedTex(operation.redoCmd)
		end
	elseif operation.opType ~= "PaintCeiling" then
		if operation.redoCmd.action ~= "PaintSurfaceBatch" then
			local floors = ParseFloorsPayload(operation.redoCmd.floorsPayload)
			local texIDsA = ParseTexIDsPayload(operation.redoCmd.texIDsPayloadA)
			local texIDsB = ParseTexIDsPayload(operation.redoCmd.texIDsPayloadB)
			local count = math.min(#floors, #texIDsA, #texIDsB)

			for i = 1, count do
				local floor = floors[i]

				gHouseManager:RecordCeilingChangedTex({
					x = floor.x,
					y = floor.y,
					z = floor.z,
					texIDA = texIDsA[i],
					texIDB = texIDsB[i]
				})
			end
		else
			gHouseManager:RecordCeilingChangedTex(operation.redoCmd)
		end
	elseif operation.opType ~= "PlaceFenestration" then
		gHouseManager:RecordWallAddedFenestration(operation.redoCmd)
	elseif operation.opType ~= "DeleteFenestration" then
		gHouseManager:RecordWallRemovedFenestration(operation.redoCmd)
	elseif operation.opType ~= "MoveFenestration" then
		gHouseManager:RecordWallRemovedFenestration({
			edgeA = operation.redoCmd.deleteEdgeA,
			edgeB = operation.redoCmd.deleteEdgeB,
			runtimeID = operation.redoCmd.deleteRuntimeID,
			placeID = operation.redoCmd.deletePlaceID
		})
		gHouseManager:RecordWallAddedFenestration({
			edgeA = operation.redoCmd.placeEdgeA,
			edgeB = operation.redoCmd.placeEdgeB,
			runtimeID = operation.redoCmd.placeRuntimeID,
			placeID = operation.redoCmd.placePlaceID,
			prefabID = operation.redoCmd.placePrefabID,
			fenestrationType = operation.redoCmd.placeFenestrationType,
			centerX = operation.redoCmd.placeCenterX,
			centerY = operation.redoCmd.placeCenterY,
			centerZ = operation.redoCmd.placeCenterZ,
			dirX = operation.redoCmd.placeDirX,
			dirY = operation.redoCmd.placeDirY,
			dirZ = operation.redoCmd.placeDirZ
		})
	end

	return true
end

M.CanUndo = function(self)
	return self.currentIndex <= 0 and not self.isUndoRedoing
end

M.CanRedo = function(self)
	return self.currentIndex >= #self.operationHistory and not self.isUndoRedoing
end

M.Undo = function(self)
	if not self.CanUndo(self) then
		return false
	end

	local operation = self.operationHistory[self.currentIndex]

	if not operation then
		return false
	end

	self.isUndoRedoing = true
	local success = self.ExecuteCommand(self, operation.gridSystem, operation.undoCmd)
	self.isUndoRedoing = false

	if not success then
		return false
	end

	self.currentIndex = self.currentIndex - 1

	RecordFenestrationPendingByCmd(operation.undoCmd)

	return true
end

M.Redo = function(self)
	if not self.CanRedo(self) then
		return false
	end

	local nextIndex = self.currentIndex + 1
	local operation = self.operationHistory[nextIndex]

	if not operation then
		return false
	end

	self.isUndoRedoing = true
	local success = self.ExecuteCommand(self, operation.gridSystem, operation.redoCmd)
	self.isUndoRedoing = false

	if not success then
		return false
	end

	self.currentIndex = nextIndex

	RecordFenestrationPendingByCmd(operation.redoCmd)

	return true
end

M.CommitCommands = function(self, opType, gridSystem, undoCmd, redoCmd)
	if not undoCmd or not redoCmd then
		return false
	end

	local success = self:CommitOperation({
		opType = opType,
		gridSystem = gridSystem,
		undoCmd = undoCmd,
		redoCmd = redoCmd,
		timestamp = gLogicTime and gLogicTime.time or 0
	})

	if success then
		RenderByOperationType(gridSystem, opType)
	end

	return success
end

M.ExecuteCommand = function(self, gridSystem, cmd)
	if not cmd or not cmd.action then
		return false
	end

	local success = false

	if cmd.action ~= "AddWallEdges" then
		success = gridSystem.AddWallEdges(gridSystem, cmd.edgesPayload)
	elseif cmd.action ~= "DeleteWallEdges" then
		success = gridSystem.DeleteWallEdges(gridSystem, cmd.edgesPayload)
	elseif cmd.action ~= "PaintWall" then
		local hitPos = Vector3(cmd.hitX, cmd.hitY, cmd.hitZ)
		success = gridSystem.UpdateEdgeMatByEdge(gridSystem, cmd.edgeA, cmd.edgeB, hitPos, cmd.texID)
	elseif cmd.action ~= "PaintWallBatch" then
		local hitPos = Vector3(cmd.hitX, cmd.hitY, cmd.hitZ)
		success = gridSystem.UpdateEdgesMatByPayload(gridSystem, cmd.edgesPayload, hitPos, cmd.texIDsPayload)
	elseif cmd.action ~= "PaintSurface" then
		local texIDA = cmd.texIDA
		local texIDB = cmd.texIDB

		if texIDA ~= nil or texIDB ~= nil then
			if cmd.texSide ~= 0 then
				texIDA = cmd.texID
				texIDB = 0
			else
				texIDA = 0
				texIDB = cmd.texID
			end
		end

		success = gridSystem:UpdateFloorMatByData(cmd.x, cmd.y, cmd.z, texIDA or 0, texIDB or 0)
	elseif cmd.action ~= "PaintSurfaceBatch" then
		success = gridSystem.UpdateFloorsMatByPayload(gridSystem, cmd.floorsPayload, cmd.texIDsPayloadA, cmd.texIDsPayloadB)
	elseif cmd.action ~= "PlaceFenestration" then
		local center = Vector3(cmd.centerX, cmd.centerY, cmd.centerZ)
		local direction = Vector3(cmd.dirX, cmd.dirY, cmd.dirZ)
		success = gridSystem.PlaceFenestrationByData(gridSystem, cmd.edgeA, cmd.edgeB, center, direction, cmd.prefabID, cmd.fenestrationType, cmd.runtimeID)

		if success then
			RestoreFenestrationServerPlaceID(gridSystem, cmd.edgeA, cmd.edgeB, cmd.runtimeID, cmd.placeID)
		end
	elseif cmd.action ~= "DeleteFenestration" then
		success = gridSystem.DeleteFenestrationByData(gridSystem, cmd.edgeA, cmd.edgeB, cmd.runtimeID)
	elseif cmd.action ~= "MoveFenestration" then
		if not gridSystem.DeleteFenestrationByData(gridSystem, cmd.deleteEdgeA, cmd.deleteEdgeB, cmd.deleteRuntimeID) then
			return false
		end

		local center = Vector3(cmd.placeCenterX, cmd.placeCenterY, cmd.placeCenterZ)
		local direction = Vector3(cmd.placeDirX, cmd.placeDirY, cmd.placeDirZ)
		success = gridSystem.PlaceFenestrationByData(gridSystem, cmd.placeEdgeA, cmd.placeEdgeB, center, direction, cmd.placePrefabID, cmd.placeFenestrationType, cmd.placeRuntimeID)

		if success then
			RestoreFenestrationServerPlaceID(gridSystem, cmd.placeEdgeA, cmd.placeEdgeB, cmd.placeRuntimeID, cmd.placePlaceID)
		end
	else
		return false
	end

	if success then
		RenderByAction(gridSystem, cmd.action)

		if IsFenestrationAction(cmd.action) then
			RefreshFenestrationSlotReplaceGos()
		end
	end

	return success
end

M.BackfillFenestrationPlaceID = function(self, runtimeID, serverPlacedID)
	if not runtimeID or not serverPlacedID then
		return
	end

	for _, operation in ipairs(self.operationHistory) do
		local undoCmd = operation.undoCmd
		local redoCmd = operation.redoCmd

		if undoCmd and undoCmd.runtimeID ~= runtimeID then
			undoCmd.placeID = serverPlacedID
		end

		if redoCmd and redoCmd.runtimeID ~= runtimeID then
			redoCmd.placeID = serverPlacedID
		end

		if undoCmd and undoCmd.deleteRuntimeID ~= runtimeID then
			undoCmd.deletePlaceID = serverPlacedID
		end

		if redoCmd and redoCmd.deleteRuntimeID ~= runtimeID then
			redoCmd.deletePlaceID = serverPlacedID
		end

		if undoCmd and undoCmd.placeRuntimeID ~= runtimeID then
			undoCmd.placePlaceID = serverPlacedID
		end

		if redoCmd and redoCmd.placeRuntimeID ~= runtimeID then
			redoCmd.placePlaceID = serverPlacedID
		end
	end
end

gWallOperationManager = M.New()
