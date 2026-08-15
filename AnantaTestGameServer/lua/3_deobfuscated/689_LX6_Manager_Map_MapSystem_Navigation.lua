local MapNavigationMgr = LX6.Gps.MapNavigationMgr
local VoxelMgr = Voxel.VoxelMgr
gMapSystem = gMapSystem or {}
local M = gMapSystem

function M:CanShowWalkNavRoute()
	return not gDriveVehiclesManager.cs_manager.isDriveMode and gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle == nil and gMapAreaMgr:IsBigWorldAreaId(self.lastAreaId)
end

local WALK_CLOSE_THRESHOLD = 16

function M:TickWalkNavInfo()
	if L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	if not self:CanShowWalkNavRoute() then
		self:ClearCurWalkNavInfo()

		return
	end

	local maxPriority = -999
	local curInstanceId = nil
	local allNavigatableElems = gGpsTools.GetTable()

	gMapSystem.trace:FindTracingElement(function (element)
		if not element or not element.gpsData.showWalkNav or not element:VisibleOnMap() or not element:HasTraceEffect() then
			return false
		else
			return true
		end
	end, allNavigatableElems)

	for _, element in ipairs(allNavigatableElems) do
		local priority = element.gpsData.walkNavPriority or 0

		if maxPriority < priority then
			maxPriority = priority
			curInstanceId = element.instanceId
		end
	end

	gGpsTools.ReleaseTable(allNavigatableElems)

	if not curInstanceId then
		self:ClearCurWalkNavInfo()

		return
	end

	local areaId, startPos = MapAreaCluster.BigWorld:GetResolvedCoord(gCS.MyPlayerManager.PlayerUnit.LocalPosition, self.lastAreaId)

	if not areaId or not startPos then
		self:ClearCurWalkNavInfo()

		return
	end

	local element = curInstanceId and self:GetByInstanceId(curInstanceId)
	local endPos = element and element:GetObservedPosFrom(areaId)

	if not endPos then
		self:ClearCurWalkNavInfo()

		return
	end

	if not self._curWalkNavTargetInfo or self._curWalkNavTargetInfo.instanceId ~= curInstanceId then
		self._curWalkNavTargetInfo = self._curWalkNavTargetInfo or {}
		self._curWalkNavTargetInfo.instanceId = curInstanceId

		gGpsTools.TryTick("RefreshWalkNavLine", 2)
		self:RefreshWalkNavLine(startPos, endPos, "Init")
	end

	if curInstanceId and element and element.mData.rangeInfo and self:IsPlayerInRange(element) then
		self:ClearCurWalkLineNavInfo()

		return
	end

	if gGpsTools.TryTick("RefreshWalkNavLine", 2) then
		if WALK_CLOSE_THRESHOLD < Vector3.SqrDistance(startPos, endPos) then
			self:RefreshWalkNavLine(startPos, endPos, "Interval Refresh")
		else
			self:ClearCurWalkLineNavInfo()
		end
	else
		local path = self._curWalkNavLineInfo and self._curWalkNavLineInfo.path

		if path then
			path[1] = gCS.MyPlayerManager.PlayerUnit.LocalPosition

			if #path > 2 and Vector3.SqrDistance(startPos, path[2]) < WALK_CLOSE_THRESHOLD then
				table.remove(path, 2)
			end
		end
	end
end

function M:GetWalkNavLineInfo()
	if not self._curWalkNavLineInfo then
		return nil, nil
	else
		return self._curWalkNavLineInfo.type, self._curWalkNavLineInfo.path
	end
end

function M:ClearCurWalkNavInfo()
	self._curWalkNavTargetInfo = nil

	self:ClearCurWalkLineNavInfo()
end

function M:ClearCurWalkLineNavInfo()
	self._curWalkNavLineInfo = nil
end

function M:RefreshWalkNavLine(startPos, endPos, reason)
	startPos = Vector3.New(startPos.x, startPos.y + 0.25, startPos.z)
	endPos = Vector3.New(endPos.x, endPos.y + 0.25, endPos.z)
	local suc, data = VoxelMgr.Instance:FindPath(startPos, endPos, nil, 16)

	if suc then
		local path = {
			gCS.MyPlayerManager.PlayerUnit.LocalPosition
		}

		for i = 2, data.Length do
			local point = data[i - 1]
			local vec3 = Vector3.New(point.x, point.y, point.z)

			table.insert(path, vec3)
		end

		if #path > 2 and Vector3.SqrDistance(startPos, path[2]) < WALK_CLOSE_THRESHOLD then
			table.remove(path, 2)
		end

		self._curWalkNavLineInfo = {
			type = 0,
			path = path
		}
	else
		self:ClearCurWalkLineNavInfo()
		print("refresh walk nav line for reason:" .. reason .. ", but failed ")
	end
end

gMapSystem_Navigation = gMapSystem_Navigation or {}
local M = gMapSystem_Navigation

function M:Init()
	self._vehicleTargetData = {}
	self._vehiclePathData = {
		reqId = 0
	}
	self._vehicleRenderData = nil
end

function M:TickVehicleNavInfo()
	local ok, err = xpcall(self._RealUpdateNavInfo, tolua.traceback, self)

	if not ok then
		print_error(err)
	end
end

function M:_RealUpdateNavInfo()
	if L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	local tickTargetAndRender = gGpsTools.TryTick("VehicleTargetAndRender", 1)

	if tickTargetAndRender then
		self:UpdateVehicleNavTarget()
		MapNavigationMgr.RequestPath()
	end

	MapNavigationMgr.UpdateCurrentPath()
	self:ReattachVehicleNavElement()

	if tickTargetAndRender then
		MapNavigationMgr.UpdateRenderInfo()
	end
end

function M:CanShowVehicleNavRoute()
	if gRaidDataManager.RaidId ~= LTConfig.RaidConfig.WorldMap and gRaidDataManager.RaidId ~= LTConfig.RaidConfig.Chongxiao or self.env.lastIndoorId and self.env.lastIndoorId > 0 then
		return false
	end

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.AlwaysUseVehicleNav) then
		return true
	end

	if gCarRaceManager.gameStart then
		return false
	end

	if self:IsTaffyOnBike() then
		return true
	end

	if gDriveVehiclesManager.isTaxiMode then
		return false
	end

	local isDriveMode = LX6.Gps.MapNavigationMgr.IsPlayerOnCar() and (gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle == nil or not not gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle.showNavigationLine)

	if isDriveMode then
		return true
	else
		return false
	end
end

function M:IsTaffyOnBike()
	return gCS.PaoKuManager.ParkourStateLua == LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.MotorbikeIdle or gCS.PaoKuManager.ParkourStateLua == LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Moto
end

function M:ClearVehicleNavTarget()
	if not self._vehicleTargetData.instanceId then
		return
	end

	self._vehiclePathData.pathInstanceId = nil
	local element = self.env.container:Get(self._vehicleTargetData.instanceId)

	if element then
		element:SetRelocatedPosition(nil)
	end

	self._vehicleTargetData.instanceId = nil
	self._vehicleTargetData.endPos = nil

	MapNavigationMgr.ClearVehicleNavTarget()
end

function M:SetVehicleNavTarget(instanceId, endPos)
	if self._vehicleTargetData.instanceId and self._vehicleTargetData.instanceId ~= instanceId then
		local oldElement = self.env.container:Get(self._vehiclePathData.instanceId)

		if oldElement then
			oldElement:SetRelocatedPosition(nil)
		end
	end

	self._vehicleTargetData.instanceId = instanceId
	local element = self.env.container:Get(instanceId)
	local hideGround = nil

	if element.gpsData.vehicleNavHideGroundEffect then
		hideGround = true
	else
		hideGround = false
	end

	self._vehicleTargetData.resType = element.gpsData.vehicleNavResType or 0
	self._vehicleTargetData.endPos = endPos

	MapNavigationMgr.SetVehicleNavTarget(instanceId, endPos, hideGround)
end

function M:FindVehicleNavTarget()
	local curInstanceId = nil
	local maxPriority = -999
	local allNavigatableElems = gGpsTools.GetTable()

	gMapSystem.trace:FindTracingElement(function (element)
		if not element or element.gpsData.disableVehicleNav or not element:VisibleOnMap() or not element:HasTraceEffect() then
			return false
		else
			return true
		end
	end, allNavigatableElems)

	for _, element in ipairs(allNavigatableElems) do
		local priority = element.gpsData.vehicleNavPriority or 0

		if maxPriority < priority then
			maxPriority = priority
			curInstanceId = element.instanceId
		end
	end

	gGpsTools.ReleaseTable(allNavigatableElems)

	return curInstanceId
end

function M:UpdateVehicleNavTarget()
	if not self:CanShowVehicleNavRoute() then
		self:ClearVehicleNavTarget()

		return
	end

	local curInstanceId = self:FindVehicleNavTarget()

	if not curInstanceId then
		self:ClearVehicleNavTarget()

		return
	end

	local element = curInstanceId and self.env.container:Get(curInstanceId)

	if not element then
		self:ClearVehicleNavTarget()

		return
	end

	local endPos = nil

	if element.gBoundId == self.env.lastGBoundId then
		endPos = element:GetWorldPos()
	else
		local suc, x, y, z, _, _ = LX6.Gps.GpsAreaConnectMgr.LuaTryGetBoundExitInfoTo(self.env.lastGBoundId, element.gBoundId, nil, nil, nil, nil, nil, nil)

		if suc then
			endPos = Vector3.New(x, y, z)
		end
	end

	if not endPos then
		self:ClearVehicleNavTarget()

		return
	end

	self:SetVehicleNavTarget(curInstanceId, endPos)
end

function M:ReattachVehicleNavElement()
	local targetElement = self.env.container:Get(self._vehicleTargetData.instanceId)

	if targetElement and targetElement.gpsData.relocatePosByNav then
		targetElement:SetRelocatedPosition(self._vehicleTargetData.endPos)
	end
end

return M
