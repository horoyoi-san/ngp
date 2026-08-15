local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
C_FurnitureOperationManager = DefClass("C_FurnitureOperationManager", C_FurnitureOperationManager)
local M = C_FurnitureOperationManager

function M:ctor()
	self.operationHistory = {}
	self.currentIndex = 0
	self.maxHistorySize = 10
	self.currentOperation = nil
	self.isUndoRedoing = false
	self.OperationType = {
		STORAGE = 3,
		EDIT = 2,
		STORAGE_ALL = 4,
		SPAWN = 1
	}
	self.ActionType = {
		Undo = 1,
		Redo = 2
	}
end

function M:OnInit()
	return
end

function M:CreateOperation(operationType, furnitureId, uniqueId, beforeState)
	return {
		operationType = operationType,
		furnitureId = furnitureId,
		uniqueId = uniqueId,
		timestamp = gLogicTime.time,
		beforeState = beforeState or {
			existed = false
		},
		afterState = {}
	}
end

function M:BeginSpawnOperation(furnitureId, uniqueId)
	if self.isUndoRedoing then
		return false
	end

	local beforeState = {
		existed = false
	}
	self.currentOperation = self:CreateOperation(self.OperationType.SPAWN, furnitureId, uniqueId, beforeState)

	return true
end

function M:BeginEditOperation(furnitureId, originalGo, uniqueId, carrySurfaceUID)
	if self.isUndoRedoing then
		return false
	end

	local beforeState = {
		existed = true,
		position = originalGo.transform.position,
		rotation = originalGo.transform.rotation,
		carrySurfaceUID = carrySurfaceUID
	}
	self.currentOperation = self:CreateOperation(self.OperationType.EDIT, furnitureId, uniqueId, beforeState)

	return true
end

function M:ChangeToStorageOperation(carryUid2GoInfoDict)
	self.currentOperation.operationType = self.OperationType.STORAGE
	self.currentOperation.beforeState.carryUid2GoInfoDict = carryUid2GoInfoDict or {}
end

function M:BeginStorageOperation(furnitureId, originalGo, uniqueId, carrySurfaceUID)
	if self.isUndoRedoing then
		return false
	end

	local beforeState = {
		existed = true,
		position = originalGo.transform.position,
		rotation = originalGo.transform.rotation,
		carrySurfaceUID = carrySurfaceUID
	}
	self.currentOperation = self:CreateOperation(self.OperationType.STORAGE, furnitureId, uniqueId, beforeState)

	return true
end

function M:BeginStorageAllOperation(allFurnitureStates)
	if self.isUndoRedoing then
		return false
	end

	local beforeState = {
		furnitureCount = 0,
		existed = true,
		allFurnitureStates = allFurnitureStates or {}
	}

	for _ in pairs(beforeState.allFurnitureStates) do
		beforeState.furnitureCount = beforeState.furnitureCount + 1
	end

	self.currentOperation = self:CreateOperation(self.OperationType.STORAGE_ALL, 0, "storage_all_" .. gLogicTime.time, beforeState)

	return true
end

function M:EndOperation(finalGo, carrySurfaceUID)
	if self.isUndoRedoing or not self.currentOperation then
		return
	end

	self.currentOperation.afterState = {
		existed = true,
		position = finalGo.transform.position,
		rotation = finalGo.transform.rotation,
		carrySurfaceUID = carrySurfaceUID
	}

	self:CommitOperation(self.currentOperation)

	self.currentOperation = nil
end

function M:EndStorageOperation()
	if self.isUndoRedoing or not self.currentOperation or self.currentOperation.operationType ~= self.OperationType.STORAGE then
		return
	end

	self.currentOperation.afterState = {
		existed = false
	}

	self:CommitOperation(self.currentOperation)

	self.currentOperation = nil
end

function M:EndStorageAllOperation()
	if self.isUndoRedoing or not self.currentOperation or self.currentOperation.operationType ~= self.OperationType.STORAGE_ALL then
		return
	end

	self.currentOperation.afterState = {
		existed = false,
		allFurnitureStates = {}
	}

	self:CommitOperation(self.currentOperation)

	self.currentOperation = nil
end

function M:CancelCurrentOperation()
	if self.isUndoRedoing then
		return
	end

	if self.currentOperation then
		if self.currentOperation.operationType == self.OperationType.EDIT and self.currentOperation.beforeState.existed then
			local existingFurniture = gFurnitureManager:FindFurnitureByUniqueId(self.currentOperation.uniqueId)

			if existingFurniture and not gCS.LuaUtils.IsNull(existingFurniture) and existingFurniture.activeSelf then
				existingFurniture.transform.position = self.currentOperation.beforeState.position
				existingFurniture.transform.rotation = self.currentOperation.beforeState.rotation
			else
				self:CreateFurnitureAtState(self.currentOperation.furnitureId, self.currentOperation.uniqueId, self.currentOperation.beforeState)
			end
		end

		self.currentOperation = nil
	end
end

function M:CommitOperation(operation)
	if self.currentIndex < #self.operationHistory then
		for i = self.currentIndex + 1, #self.operationHistory do
			self.operationHistory[i] = nil
		end
	end

	table.insert(self.operationHistory, operation)

	self.currentIndex = #self.operationHistory

	if self.maxHistorySize < #self.operationHistory then
		table.remove(self.operationHistory, 1)

		self.currentIndex = self.currentIndex - 1
	end
end

function M:Undo()
	if not self:CanUndo() then
		return false
	end

	self.isUndoRedoing = true
	local operation = self.operationHistory[self.currentIndex]

	self:RevertOperation(operation)

	self.currentIndex = self.currentIndex - 1
	self.isUndoRedoing = false

	return true
end

function M:Redo()
	if not self:CanRedo() then
		return false
	end

	self.isUndoRedoing = true
	self.currentIndex = self.currentIndex + 1
	local operation = self.operationHistory[self.currentIndex]

	self:ApplyOperation(operation)

	self.isUndoRedoing = false

	return true
end

function M:ApplyOperation(operation)
	self:HandleFurnitureState(operation, operation.afterState, self.ActionType.Redo)
end

function M:RevertOperation(operation)
	self:HandleFurnitureState(operation, operation.beforeState, self.ActionType.Undo)
end

function M:CreateFurnitureAtState(furnitureId, uniqueId, state, carrySurfaceUID)
	local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)

	gResourceManager:LoadAssetWithCallBack(furnitureCfg.ModelName, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local furnitureGo = GameObject.Instantiate(loadOp.asset)
			furnitureGo.transform.position = state.position
			furnitureGo.transform.rotation = state.rotation
			furnitureGo.name = gFurnitureUtils:BuildFurnitureName(furnitureId, furnitureCfg.Name, uniqueId, true)

			gFurnitureManager:SetHouseFurnitureFields(furnitureGo, uniqueId, furnitureId)

			local furnitureRoot, _ = gFurnitureManager:UpdateFurnitureAdsorptionRelation(furnitureGo, uniqueId, carrySurfaceUID, false)

			furnitureGo.transform:SetParent(furnitureRoot.transform, true)
			gHouseManager:RecordAddedFurniture(uniqueId, furnitureId, state.position, state.rotation, carrySurfaceUID)
		else
			print_error(string.format("FurnitureOperationManager: 加载家具失败，ID: %d", furnitureId))
		end
	end)
end

function M:HandleFurnitureState(operation, targetState, actionType)
	if operation.operationType == self.OperationType.STORAGE_ALL then
		self:HandleStorageAllFurnitureState(targetState, actionType)
	elseif targetState.existed then
		local existingGo = gFurnitureManager:FindFurnitureByUniqueId(operation.uniqueId)

		if existingGo then
			existingGo.transform.position = targetState.position
			existingGo.transform.rotation = targetState.rotation
			local furnitureRoot, _ = gFurnitureManager:UpdateFurnitureAdsorptionRelation(existingGo, operation.uniqueId, targetState.carrySurfaceUID, false)

			existingGo.transform:SetParent(furnitureRoot.transform, true)
		else
			self:CreateFurnitureAtState(operation.furnitureId, operation.uniqueId, targetState, targetState.carrySurfaceUID)

			if targetState.carryUid2GoInfoDict then
				for carryUid, info in pairs(targetState.carryUid2GoInfoDict) do
					local state = {
						position = info.position,
						rotation = info.rotation
					}

					self:CreateFurnitureAtState(info.furnitureId, carryUid, state, operation.uniqueId)
				end
			end
		end
	else
		self:RemoveFurnitureByUniqueId(operation.uniqueId)
	end
end

function M:HandleStorageAllFurnitureState(targetState, actionType)
	if targetState.existed and targetState.allFurnitureStates then
		local carryFurnitureStates = {}
		local independentFurnitureStates = {}

		for uid, furnitureState in pairs(targetState.allFurnitureStates) do
			if furnitureState.carrySurfaceUID and furnitureState.carrySurfaceUID ~= 0 then
				if not carryFurnitureStates[furnitureState.carrySurfaceUID] then
					carryFurnitureStates[furnitureState.carrySurfaceUID] = {}
				end

				table.insert(carryFurnitureStates[furnitureState.carrySurfaceUID], {
					uid = uid,
					state = furnitureState
				})
			else
				independentFurnitureStates[uid] = furnitureState
			end
		end

		for uid, furnitureState in pairs(independentFurnitureStates) do
			if furnitureState.furnitureId then
				self:CreateFurnitureAtState(furnitureState.furnitureId, uid, furnitureState, furnitureState.carrySurfaceUID)
			end
		end

		for carrySurfaceUID, adsorbedFurnitures in pairs(carryFurnitureStates) do
			for _, furnitureInfo in ipairs(adsorbedFurnitures) do
				self:CreateFurnitureAtState(furnitureInfo.state.furnitureId, furnitureInfo.uid, furnitureInfo.state, carrySurfaceUID)
			end
		end
	else
		self:RedoStorageAllFurniture()
	end
end

function M:RedoStorageAllFurniture()
	local furnitureManager = gFurnitureManager

	if not next(furnitureManager.uid2FurnitureGoDict) then
		return
	end

	local allFurnitureUIDs = {}

	for uid, _ in pairs(furnitureManager.uid2FurnitureGoDict) do
		table.insert(allFurnitureUIDs, uid)
	end

	local carryFurnitureUIDs = {}
	local independentFurnitureUIDs = {}

	for _, uid in ipairs(allFurnitureUIDs) do
		if furnitureManager.carryUid2AdsUidListDict[uid] and #furnitureManager.carryUid2AdsUidListDict[uid] > 0 then
			table.insert(carryFurnitureUIDs, uid)
		else
			local isAdsorbed = false

			for carryUID, adsorbedList in pairs(furnitureManager.carryUid2AdsUidListDict) do
				for _, adsorbedUID in ipairs(adsorbedList) do
					if adsorbedUID == uid then
						isAdsorbed = true

						break
					end
				end

				if isAdsorbed then
					break
				end
			end

			if not isAdsorbed then
				table.insert(independentFurnitureUIDs, uid)
			end
		end
	end

	for _, carryUID in ipairs(carryFurnitureUIDs) do
		if furnitureManager.uid2FurnitureGoDict[carryUID] then
			local adsorbedUIDs = furnitureManager.carryUid2AdsUidListDict[carryUID] or {}

			gHouseManager:RecordRemovedFurniture(carryUID)

			for _, adsorbedUID in ipairs(adsorbedUIDs) do
				if furnitureManager.uid2FurnitureGoDict[adsorbedUID] then
					gHouseManager:RecordRemovedFurniture(adsorbedUID)
				end
			end

			self:RemoveFurnitureByUniqueId(carryUID)
		end
	end

	for _, uid in ipairs(independentFurnitureUIDs) do
		if furnitureManager.uid2FurnitureGoDict[uid] then
			gHouseManager:RecordRemovedFurniture(uid)
			self:RemoveFurnitureByUniqueId(uid)
		end
	end

	furnitureManager.carryUid2AdsUidListDict = {}

	for uid, furnitureGo in pairs(furnitureManager.uid2FurnitureGoDict) do
		if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
			GameObject.Destroy(furnitureGo)
		end
	end

	furnitureManager.uid2FurnitureGoDict = {}
end

function M:RemoveFurnitureByUniqueId(uniqueId)
	return gFurnitureManager:RemoveExistFurniture(uniqueId)
end

function M:CanUndo()
	return self.currentIndex > 0 and not self.isUndoRedoing
end

function M:CanRedo()
	return self.currentIndex < #self.operationHistory and not self.isUndoRedoing
end

gFurnitureOperationManager = M.New()
