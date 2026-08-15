EGpsBindTargetType = {
	Unit = 1,
	Destructible = 4,
	Vehicle = 3,
	SpoonVehicle = 5,
	Slot = 6,
	SpoonUnit = 2
}
gGpsBindingMgr = gGpsBindingMgr or {}
local M = gGpsBindingMgr

function M:Init()
	self.eventHandlers = {
		[gEventConstants.CHANGE_MY_UNIT2] = function (eventId, param)
			return
		end
	}
end

function M:OnLogin()
	self:Reset()

	self.mePid = nil
	self.meBindId = nil
end

function M:OnLogout()
	self:Reset()
end

function M:Reset()
	self._targetIdCounter = 1
	self.gps2BindTarget = {}
	self.binds = {}
	self.hudBindPids = {}
	self.target2Bind = {
		[EGpsBindTargetType.Unit] = {},
		[EGpsBindTargetType.SpoonUnit] = {},
		[EGpsBindTargetType.Vehicle] = {},
		[EGpsBindTargetType.SpoonVehicle] = {},
		[EGpsBindTargetType.Destructible] = {},
		[EGpsBindTargetType.Slot] = {}
	}
	self.vehicleDetectionData = {}
end

function M:IncRefGpsBindTarget(bindTargetType, targetId)
	local bindTarget = self:AddOrGetBindTarget(bindTargetType, targetId)
	bindTarget.otherRefCount = bindTarget.otherRefCount + 1

	return bindTarget.id
end

function M:DecRefGpsBindTarget(bindId)
	local bindTarget = self.binds[bindId]

	if not bindTarget then
		gGpsTools.Assert(gGpsModule.SafeAssert, "DecRefGpsBindTarget bindTarget is nil", bindId)

		return
	end

	bindTarget.otherRefCount = bindTarget.otherRefCount - 1

	if bindTarget.otherRefCount < 0 then
		gGpsTools.Assert(gGpsModule.SafeAssert, "DecRefGpsBindTarget ref count < 0", bindId)

		bindTarget.otherRefCount = 0
	end

	self:TryDisposeBindTarget(bindTarget)
end

function M:SetGpsBindTarget(instanceId, targetType, targetId)
	local oldBindTarget = self.gps2BindTarget[instanceId]

	if oldBindTarget and oldBindTarget.targetType == targetType and oldBindTarget.targetId == targetId then
		return
	end

	self:RemoveGpsInst(instanceId)

	local newBindTarget = self:AddOrGetBindTarget(targetType, targetId)
	self.gps2BindTarget[instanceId] = newBindTarget
	newBindTarget.instanceIds[instanceId] = true
end

function M:AddOrGetBindTarget(bindType, targetId)
	local tbl = self.target2Bind[bindType]

	if not tbl then
		tbl = {}
		self.target2Bind[bindType] = tbl
	end

	local bindInfo = tbl[targetId]

	if not bindInfo then
		bindInfo = {
			otherRefCount = 0,
			id = self._targetIdCounter,
			targetId = targetId,
			targetType = bindType,
			instanceIds = gGpsTools.GetTable(),
			childs = gGpsTools.GetTable(),
			props = gGpsTools.GetTable()
		}
		self.binds[bindInfo.id] = bindInfo
		tbl[targetId] = bindInfo
		self._targetIdCounter = self._targetIdCounter + 1
	end

	return bindInfo
end

function M:TryDisposeBindTarget(bindTarget)
	if not bindTarget then
		gGpsTools.Assert(gGpsModule.SafeAssert, "TryDisposeBindTarget bindTarget is nil")
	end

	if bindTarget.otherRefCount > 0 or next(bindTarget.instanceIds) or next(bindTarget.childs) then
		return
	end

	local parent = bindTarget.parent

	self:ClearParent(bindTarget)
	gGpsTools.ReleaseTable(bindTarget.instanceIds)
	gGpsTools.ReleaseTable(bindTarget.childs)
	gGpsTools.ReleaseTable(bindTarget.props)

	local tbl = self.target2Bind[bindTarget.targetType]
	tbl[bindTarget.targetId] = nil
	self.binds[bindTarget.id] = nil

	if parent then
		self:TryDisposeBindTarget(parent)
	end
end

function M:RemoveGpsInst(instanceId)
	local bindInfo = self.gps2BindTarget[instanceId]
	self.gps2BindTarget[instanceId] = nil

	if bindInfo and bindInfo.instanceIds[instanceId] then
		bindInfo.instanceIds[instanceId] = nil
	end
end

function M:ClearParent(bindTarget)
	local parent = bindTarget.parent

	if parent then
		parent.childs[bindTarget.targetId] = nil
		bindTarget.parent = nil

		self:TryDisposeBindTarget(parent)
	end
end

function M:ReCalcTreeProps(bindTarget)
	return
end

function M:SetParent(bindTarget, parentTarget)
	if bindTarget.parent == parentTarget then
		return
	end

	self:ClearParent(bindTarget)

	bindTarget.parent = parentTarget
	parentTarget.childs[bindTarget.targetId] = bindTarget
end

function M:Tick()
	local playerPid = gCS.MyPlayerManager.PlayerUnitId

	if self.mePid ~= playerPid then
		if self.mePid then
			self:DecRefGpsBindTarget(self.meBindId)

			self.mePid = nil
			self.meBindId = nil
		end

		if playerPid then
			self.mePid = playerPid
			self.meBindId = self:IncRefGpsBindTarget(EGpsBindTargetType.Unit, playerPid)
		end

		gMapSystem.container:RefreshViewStage(EMapViewStage.MeConflict)
	end

	local spoonVehicleTbl = self.target2Bind[EGpsBindTargetType.SpoonVehicle]

	for spoonId, bindInfo in pairs(spoonVehicleTbl) do
		local vehicleId = gDriveVehiclesManager:GetVehicleUid(spoonId)

		if vehicleId and vehicleId ~= ulong.zero then
			local vehicleTarget = self:AddOrGetBindTarget(EGpsBindTargetType.Vehicle, vehicleId)

			self:SetParent(bindInfo, vehicleTarget)
		else
			self:ClearParent(bindInfo)
		end
	end

	for spoonId, bindInfo in pairs(self.target2Bind[EGpsBindTargetType.SpoonUnit]) do
		local spawnInfo = gCS.SpoonAgentMgr:GetSpawnBySpoonId(spoonId)

		if spawnInfo and spawnInfo.pid then
			local unitTarget = self:AddOrGetBindTarget(EGpsBindTargetType.Unit, spawnInfo.pid)

			self:SetParent(bindInfo, unitTarget)
		else
			self:ClearParent(bindInfo)
		end
	end
end

function M:AddSlotBinding(gpsInstanceId, slotPid)
	self:SetGpsBindTarget(gpsInstanceId, EGpsBindTargetType.Slot, slotPid)
end

function M:AddUnitBinding(gpsInstanceId, unitPid)
	self:SetGpsBindTarget(gpsInstanceId, EGpsBindTargetType.Unit, unitPid)
end

function M:AddSpoonUnitBinding(gpsInstanceId, spoonId)
	self:SetGpsBindTarget(gpsInstanceId, EGpsBindTargetType.SpoonUnit, spoonId)
end

function M:AddDestructibleBinding(gpsInstanceId, destructibleId)
	self:SetGpsBindTarget(gpsInstanceId, EGpsBindTargetType.Destructible, destructibleId)
end

function M:AddVehicleBinding(gpsInstanceId, vehiclePid)
	self:SetGpsBindTarget(gpsInstanceId, EGpsBindTargetType.Vehicle, vehiclePid)
end

function M:AddSpoonVehicleBinding(gpsInstanceId, vehicleSpoonId)
	self:SetGpsBindTarget(gpsInstanceId, EGpsBindTargetType.SpoonVehicle, vehicleSpoonId)
end

function M:SetVehicleDetection(vehiclePid, normValue)
	self.vehicleDetectionData[vehiclePid] = normValue
end

function M:GetAlertNormValue(gpsInstanceId)
	local bindTarget = self.gps2BindTarget[gpsInstanceId]

	if not bindTarget then
		return nil
	end

	if bindTarget.targetType == EGpsBindTargetType.Vehicle then
		local vehiclePid = bindTarget.targetId

		return self.vehicleDetectionData[vehiclePid]
	elseif bindTarget.targetType == EGpsBindTargetType.SpoonVehicle then
		local vehicleSpoonId = bindTarget.targetId
		local vehiclePid = gDriveVehiclesManager:GetVehicleUid(vehicleSpoonId)

		return self.vehicleDetectionData[vehiclePid]
	end

	return nil
end

function M:SetProgressState(progressId, normValue, finish)
	if not self._progressId2Progress then
		self._progressId2Progress = {}
	end

	if not self._progressId2Progress[progressId] then
		self._progressId2Progress[progressId] = {
			finish = false,
			normValue = 0
		}
	end

	self._progressId2Progress[progressId].normValue = normValue
	self._progressId2Progress[progressId].finish = finish
end

function M:GetProgressState(progressId)
	return self._progressId2Progress and self._progressId2Progress[progressId] or nil
end

function M:IsConflictWithInteract(gpsInstanceId)
	local bindTarget = self.gps2BindTarget[gpsInstanceId]

	if not bindTarget then
		return false
	end

	if bindTarget.targetType == EGpsBindTargetType.SpoonUnit then
		local spawnInfo = gCS.SpoonAgentMgr:GetSpawnBySpoonId(bindTarget.targetId)

		if spawnInfo and spawnInfo.pid then
			return gInteractionManager:CheckIsEnterInteractionRange(spawnInfo.pid)
		else
			return false
		end
	elseif bindTarget.targetType == EGpsBindTargetType.SpoonVehicle then
		local vehicleId = gDriveVehiclesManager:GetVehicleUid(bindTarget.targetId)

		return gInteractionManager:CheckIsEnterInteractionRange(vehicleId)
	else
		return gInteractionManager:CheckIsEnterInteractionRange(bindTarget.targetId)
	end
end

function M:ClearHudBindingPids()
	table.clear(self.hudBindPids)
end

function M:MarkHudBindingPid(gpsInstanceId)
	local bindTarget = self.gps2BindTarget[gpsInstanceId]

	if not bindTarget then
		return
	end

	if bindTarget.targetType == EGpsBindTargetType.Slot then
		self.hudBindPids[bindTarget.targetId] = true
	end
end

function M:PidHasHudGps(pid)
	return self.hudBindPids[pid]
end

function M:TryGetBindingInfo(gpsInstanceId)
	if not gpsInstanceId then
		return nil
	end

	local bindTarget = self.gps2BindTarget[gpsInstanceId]

	if not bindTarget then
		return nil
	end

	return bindTarget.targetType, bindTarget.targetId
end

function M:GetBindRootIdByGpsInstanceId(instanceId)
	local bindTarget = self.gps2BindTarget[instanceId]

	if not bindTarget then
		return nil
	end

	local currentBindTarget = bindTarget

	while currentBindTarget.parent do
		currentBindTarget = currentBindTarget.parent
	end

	return currentBindTarget.id
end

function M:FindTaskGpsInstanceIdBySameBinding(gpsInstanceId)
	local bindTarget = self.gps2BindTarget[gpsInstanceId]

	if not bindTarget then
		return nil
	end

	while bindTarget.parent do
		bindTarget = bindTarget.parent
	end

	return self:_RecurFindTask(bindTarget)
end

function M:_RecurFindTask(bindTarget)
	for instanceId, _ in pairs(bindTarget.instanceIds) do
		local mapElement = gMapSystem.container:Get(instanceId)

		if mapElement and mapElement.type == EMapElementType.Task then
			return instanceId
		end
	end

	for _, childBindTarget in pairs(bindTarget.childs) do
		local taskGpsId = self:_RecurFindTask(childBindTarget)

		if taskGpsId then
			return taskGpsId
		end
	end
end

function M:GetAllInstanceIdsWithSameBinding(gpsInstanceId)
	local result = {}
	local bindTarget = self.gps2BindTarget[gpsInstanceId]

	if not bindTarget then
		return result
	end

	while bindTarget.parent do
		bindTarget = bindTarget.parent
	end

	self:_RecurCollectInstanceIds(bindTarget, result)

	return result
end

function M:_RecurCollectInstanceIds(bindTarget, result)
	for instanceId, _ in pairs(bindTarget.instanceIds) do
		table.insert(result, instanceId)
	end

	for _, childBindTarget in pairs(bindTarget.childs) do
		self:_RecurCollectInstanceIds(childBindTarget, result)
	end
end
