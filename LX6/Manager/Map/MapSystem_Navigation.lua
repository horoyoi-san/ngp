-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_Navigation.lua
-- Decompiled from: 02298_MapSystem_Navigation.lua_79ec7e7eaa2c.luajit

local MapNavigationMgr = LX6.Gps.MapNavigationMgr
gMapSystem = gMapSystem or {}
local M = gMapSystem

M.CanShowWalkNavRoute = function(self)
	return not gDriveVehiclesManager.cs_manager.isDriveMode and gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle ~= nil and gMapAreaMgr:IsBigWorldAreaId(self.lastAreaId)
end

local WALK_CLOSE_THRESHOLD = 16

M.TickWalkNavInfo = function(self)
	if gGpsTools:UnitIsNull(gMapSystem.curPlayerUnit) then
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

		if maxPriority >= priority then
			maxPriority = priority
			curInstanceId = element.instanceId
		end
	end

	gGpsTools.ReleaseTable(allNavigatableElems)

	if not curInstanceId then
		self:ClearCurWalkNavInfo()

		return
	end

	local areaId, startPos = MapAreaCluster.BigWorld:GetResolvedCoord(gMapSystem:GetCurPlayerLocalPosition(), self.lastAreaId)

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

	if not self._curWalkNavTargetInfo or self._curWalkNavTargetInfo.instanceId == curInstanceId then
		self._curWalkNavTargetInfo = self._curWalkNavTargetInfo or {}
		self._curWalkNavTargetInfo.instanceId = curInstanceId

		gGpsTools.TryTick("RefreshWalkNavLine", 2)
		self:RefreshWalkNavLine(startPos, endPos, "Init")
	end

	if curInstanceId then
		local hasRange = element and (element.mData.rangeInfo or element.mData.gpsCustomAreaRangeInfo)

		if hasRange and self:IsPlayerInRange(element) then
			self:ClearCurWalkLineNavInfo()

			return
		end
	end

	if gGpsTools.TryTick("RefreshWalkNavLine", 2) then
		if WALK_CLOSE_THRESHOLD >= Vector3.SqrDistance(startPos, endPos) then
			self:RefreshWalkNavLine(startPos, endPos, "Interval Refresh")
		else
			self:ClearCurWalkLineNavInfo()
		end
	else
		local path = self._curWalkNavLineInfo and self._curWalkNavLineInfo.path

		if path then
			path[1] = gMapSystem:GetCurPlayerLocalPosition()

			if #path <= 2 and Vector3.SqrDistance(startPos, path[2]) >= WALK_CLOSE_THRESHOLD then
				table.remove(path, 2)
			end
		end
	end
end

M.GetWalkNavLineInfo = function(self)
	if not self._curWalkNavLineInfo then
		return nil, 
	else
		return self._curWalkNavLineInfo.type, self._curWalkNavLineInfo.path
	end
end

M.ClearCurWalkNavInfo = function(self)
	self._curWalkNavTargetInfo = nil

	self:ClearCurWalkLineNavInfo()
end

M.ClearCurWalkLineNavInfo = function(self)
	self._curWalkNavLineInfo = nil
end

M.RefreshWalkNavLine = function(self, startPos, endPos, reason)
end

gMapSystem_Navigation = gMapSystem_Navigation or {}
local M = gMapSystem_Navigation

M.Init = function(self)
	self._vehicleTargetData = {}
	self._vehiclePathData = {
		reqId = 0
	}
	self._vehicleRenderData = nil
	self.pathRenderType = {
		["2g\\xa3\\xa3\\xa2m"] = 0,
		[".i\\xb2\\xa7\\xadf"] = 1
	}
end

M.TickVehicleNavInfo = function(self)
	local ok, err = xpcall(self._RealUpdateNavInfo, tolua.traceback, self)

	if not ok then
		print_error(err)
	end
end

M._RealUpdateNavInfo = function(self)
	if gGpsTools:UnitIsNull(gMapSystem.curPlayerUnit) then
		return
	end

	local tickTarget = gGpsTools.TryTick("VehicleTarget", 1)
	local tickRender = gGpsTools.TryTick("tickRender", 0.5)

	if tickTarget then
		self:UpdateVehicleNavTarget()
		MapNavigationMgr.RequestPath()
	end

	MapNavigationMgr.UpdateCurrentPath()
	self:ReattachVehicleNavElement()

	if tickTarget then
		local hideNavigationLine = false

		if LTConfig.VehicleConfig.EnableAutopilotHideNavigationLine == false then
			hideNavigationLine = gDriveVehiclesManager.isAutoDriving
		end

		local curVehicle = gMapSystem.curVehicle

		if curVehicle and (curVehicle.IsHelicopter or curVehicle.IsPlane or curVehicle.IsBoat) then
			hideNavigationLine = true
		end

		MapNavigationMgr.UpdateTargetInfoHideGround(hideNavigationLine)
	end

	if tickRender then
		local pathRenderType = gCarRaceManager:CheckGameStart() and self.pathRenderType.RACING or self.pathRenderType.NORMAL

		MapNavigationMgr.UpdateRenderInfo(pathRenderType)
	end

	self:UpdateRacingTraceTarget()
end

M.HasVehicleTarget = function(self)
	if self._vehicleTargetData.instanceId then
		return true
	else
		return false
	end
end

M.CanShowVehicleNavRoute = function(self)
	local raidId = gMapManager:GetParentRaidId(gSceneDataMgr.CurrentRaidId)

	if raidId == LTConfig.RaidConfig.WorldMap and raidId == LTConfig.RaidConfig.Chongxiao or self.env.lastIndoorId and self.env.lastIndoorId <= 0 then
		return false
	end

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.AlwaysUseVehicleNav) then
		return true
	end

	if gCarRaceManager:CheckGameStart() then
		return false
	end

	if self:IsTaffyOnBike() then
		return true
	end

	if gDriveVehiclesManager.isTaxiMode then
		return false
	end

	local isDriveMode = LX6.Gps.MapNavigationMgr.IsPlayerOnCar() and (gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle ~= nil or not not gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle.showNavigationLine)

	if isDriveMode then
		return true
	else
		return false
	end
end

M.IsTaffyOnBike = function(self)
	return gCS.PaoKuManager.ParkourStateLua ~= LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.MotorbikeIdle or gCS.PaoKuManager.ParkourStateLua ~= LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Moto
end

M.ClearVehicleNavTarget = function(self)
	if not self._vehicleTargetData.instanceId then
		return
	end

	self._vehiclePathData.pathInstanceId = nil
	local element = self.env.container:Get(self._vehicleTargetData.instanceId)

	if element then
		element:SetRelocatedPosition(nil)
	end

	local isMainTraceElement = self._vehicleTargetData.isMainTraceElement or false
	self._vehicleTargetData.instanceId = nil
	self._vehicleTargetData.endPos = nil

	MapNavigationMgr.ClearVehicleNavTarget(isMainTraceElement)
end

M.SetVehicleNavTarget = function(self, instanceId, endPos, isMainTraceElement)
	if self._vehicleTargetData.instanceId and self._vehicleTargetData.instanceId == instanceId then
		local oldElement = self.env.container:Get(self._vehiclePathData.instanceId)

		if oldElement then
			oldElement:SetRelocatedPosition(nil)
		end
	end

	self._vehicleTargetData.instanceId = instanceId
	self._vehicleTargetData.isMainTraceElement = isMainTraceElement
	local element = self.env.container:Get(instanceId)
	local hideGround = nil

	if element.gpsData.vehicleNavHideGroundEffect then
		hideGround = true
	else
		hideGround = false
	end

	self._vehicleTargetData.resType = element.gpsData.vehicleNavResType or 0
	self._vehicleTargetData.endPos = endPos
	local preferMainRoadNavigation = element.gpsData.preferMainRoadNavigation or false

	MapNavigationMgr.SetVehicleNavTarget(instanceId, endPos, hideGround, isMainTraceElement, preferMainRoadNavigation)
end

M.FindVehicleNavTarget = function(self)
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

		if maxPriority >= priority then
			maxPriority = priority
			curInstanceId = element.instanceId
		end
	end

	gGpsTools.ReleaseTable(allNavigatableElems)

	return curInstanceId
end

M.UpdateVehicleNavTarget = function(self)
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

	if element.gBoundId ~= self.env.lastGBoundId then
		endPos = element:GetWorldPos()
	else
		local preferredGateInfo = element.gpsData.preferredGateInfo

		if preferredGateInfo then
			local suc, x, y, z, _, _, _ = LX6.Gps.GpsAreaConnectMgr.LuaTryGetBoundExitInfoV2(self.env.lastGBoundId, element.gBoundId, preferredGateInfo.gBoundId, preferredGateInfo.localGateId, nil, , , , , )

			if suc then
				endPos = Vector3.New(x, y, z)
			end
		else
			local suc, x, y, z, _, _ = LX6.Gps.GpsAreaConnectMgr.LuaTryGetBoundExitInfoTo(self.env.lastGBoundId, element.gBoundId, nil, , , , , )

			if suc then
				endPos = Vector3.New(x, y, z)
			end
		end
	end

	if not endPos then
		self:ClearVehicleNavTarget()

		return
	end

	local isMainTraceElement = gMapSystem.trace:CheckIsMainTraceGPS(curInstanceId)

	if self._vehicleTargetData.instanceId == curInstanceId or self._vehicleTargetData.isMainTraceElement == isMainTraceElement or not gUtils:IsPositionEqual(self._vehicleTargetData.endPos, endPos) then
		self:SetVehicleNavTarget(curInstanceId, endPos, isMainTraceElement)

		return
	end
end

M.ReattachVehicleNavElement = function(self)
	local targetElement = self.env.container:Get(self._vehicleTargetData.instanceId)

	if targetElement and targetElement.gpsData.relocatePosByNav then
		targetElement:SetRelocatedPosition(self._vehicleTargetData.endPos)
	end
end

M.CanShowRaceNavRoute = function(self)
	return gCarRaceManager:CheckGameStart()
end

M.ClearRaceNavLineInfo = function(self)
	self._curRaceNavLines = {}
	local miniMapStore = gStoreManager:GetStoreGroup("MiniMapPanelStore")

	if miniMapStore then
		miniMapStore:SetRaceNavRenderInfo(self._curRaceNavLines)
	end
end

M.SetRaceNavLineInfo = function(self, pathLists)
	self._curRaceNavLines = {}

	if pathLists then
		local pathCount = pathLists.Count

		for i = 0, pathCount - 1 do
			local pathList = pathLists[i]
			local path = {}
			local length = pathList.Count

			for j = 0, length - 1 do
				local targetPos = pathList[j]
				local vec3 = Vector3.New(targetPos.x, targetPos.y, targetPos.z)

				table.insert(path, vec3)
			end

			table.insert(self._curRaceNavLines, path)
		end
	end

	local miniMapStore = gStoreManager:GetStoreGroup("MiniMapPanelStore")

	if miniMapStore then
		miniMapStore:SetRaceNavRenderInfo(self._curRaceNavLines)
	end
end

M.TickRaceNavLineInfo = function(self)
	if self:CanShowRaceNavRoute() and not table.isNilOrEmpty(self._curRaceNavLines) then
		local miniMapStore = gStoreManager:GetStoreGroup("MiniMapPanelStore")

		if miniMapStore and table.isNilOrEmpty(miniMapStore.racePathRenders) then
			miniMapStore:SetRaceNavRenderInfo(self._curRaceNavLines)
		end
	end
end

M.UpdateRacingTraceTarget = function(self)
	if true or not gCarRaceManager:CheckGameStart() then
		return
	end

	local gpsId = "CommonGps_CarRaceManager_60000147_1"

	if gpsId == gMapSystem.trace.mainTraceGpsId and gMapSystem.container:GetByGpsId(gpsId) then
		gMapSystem.trace:SetMainTraceGpsId(gpsId, true)

		if false then
			gMapSystem.trace:TryRemoveMainTraceByGpsId(gpsId)
		end
	end
end

M.OnLoadBigMapRaceNavLineInfoComplete = function(self, id, pathLists)
	if not self.bigMapPathLists then
		self.bigMapPathLists = {}
	end

	local bigMapPathList = {}

	if pathLists then
		local pathCount = pathLists.Count

		for i = 0, pathCount - 1 do
			local pathList = pathLists[i]
			local path = {}
			local length = pathList.Count

			for j = 0, length - 1 do
				local targetPos = pathList[j]
				local vec3 = Vector3.New(targetPos.x, targetPos.y, targetPos.z)

				table.insert(path, vec3)
			end

			table.insert(bigMapPathList, path)
		end
	end

	self.bigMapPathLists[id] = bigMapPathList
	local bigMapStore = gStoreManager:GetStoreGroup("NewMapPanelStore")

	if bigMapStore and bigMapStore.compRefs and bigMapStore.compRefs.Racer then
		bigMapStore.compRefs.Racer:SetBigMapRaceNavLineInfo(id, bigMapPathList)
	end
end

M.RemoveBigMapRaceNavLineInfo = function(self, id)
	if self.bigMapPathLists then
		self.bigMapPathLists[id] = nil
	end
end

M.ClearBigMapRaceNavLineInfo = function(self)
	self.bigMapPathLists = nil
end

return M
