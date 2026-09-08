-- Original chunk: @Lua\LuaFiles\LX6\Guide\NewGuideMgr_VehicleCollider.lua
-- Decompiled from: 00369_NewGuideMgr_VehicleCollider.lua_93b18cfcb0f6.luajit

local M = C_NewGuideMgr

M.StartPlayerVehicleColliderCheck = function(self, layerMask, checkInterval, collideCnt)
	self.EndPlayerVehicleColliderCheck(self)
	print_notice("[NewGuideMgr]:StartPlayerVehicleColliderCheck layerMask=", layerMask, " checkInterval=", checkInterval, " collideCnt=", collideCnt)

	self._vehColLayerMask = layerMask
	self._vehColCheckInterval = checkInterval
	self._vehColCollideCnt = collideCnt
	self._vehColTimerStartTime = nil
	self._vehColIsActive = true
	local vehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle

	if vehicle then
		vehicle.SetCollisionCountLayer(vehicle, layerMask)
		vehicle.StartCollisionCount(vehicle)

		self._vehColTrackedVehicle = vehicle
	end

	self._vehColEventHandler = {
		[gEventConstants.ENTER_BASE_VEHICLE_INTERIOR] = function ()
			self:_OnVehColEnterVehicle()
		end,
		[gEventConstants.EXIT_BASE_VEHICLE_INTERIOR] = function ()
			self:_OnVehColExitVehicle()
		end
	}

	gMessageManager:RegisterEventHandlers(self._vehColEventHandler)

	self._vehColUpdateHandle = UpdateBeat:CreateListener(self._TickVehicleColliderCheck, self)

	UpdateBeat:AddListener(self._vehColUpdateHandle)
end

M.EndPlayerVehicleColliderCheck = function(self)
	print_notice("[NewGuideMgr]:EndPlayerVehicleColliderCheck")

	if not self._vehColIsActive then
		return
	end

	self._vehColIsActive = false

	if self._vehColUpdateHandle then
		UpdateBeat:RemoveListener(self._vehColUpdateHandle)

		self._vehColUpdateHandle = nil
	end

	if self._vehColTrackedVehicle then
		local vehicle = self._vehColTrackedVehicle

		if vehicle and not gCS.LuaUtils.IsNull(vehicle.gameObject) then
			vehicle.StopCollisionCount(vehicle)
		end

		self._vehColTrackedVehicle = nil
	end

	if self._vehColEventHandler then
		gMessageManager:UnregisterEventHandlers(self._vehColEventHandler)

		self._vehColEventHandler = nil
	end

	self._vehColLayerMask = nil
	self._vehColCheckInterval = nil
	self._vehColCollideCnt = nil
	self._vehColTimerStartTime = nil
end

M._TickVehicleColliderCheck = function(self)
	local vehicle = self._vehColTrackedVehicle

	if not vehicle then
		return
	end

	if gCS.LuaUtils.IsNull(vehicle.gameObject) then
		self._vehColTrackedVehicle = nil
		self._vehColTimerStartTime = nil

		return
	end

	local curCount = vehicle.CollisionCount

	if not self._vehColTimerStartTime then
		if curCount <= 0 then
			print_notice("[NewGuideMgr]:_TickVehicleColliderCheck 首次碰撞，拉起 Timer, curCount=", curCount)

			self._vehColTimerStartTime = Time.time
		end
	elseif self._vehColCollideCnt < curCount then
		print_notice("[NewGuideMgr]:_TickVehicleColliderCheck 碰撞计数达标，上报服务端, curCount=", curCount)
		gReliableRpcManager:RegisterRPC(gClientToGameSceneDelegate.AskReportVehicleCollideCount)
		vehicle:StartCollisionCount()

		self._vehColTimerStartTime = nil
	elseif self._vehColCheckInterval < Time.time - self._vehColTimerStartTime then
		print_notice("[NewGuideMgr]:_TickVehicleColliderCheck 碰撞计数超时未达标，重置 Timer, curCount=", curCount)
		vehicle.StartCollisionCount(vehicle)

		self._vehColTimerStartTime = nil
	end
end

M._OnVehColEnterVehicle = function(self)
	local newVehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle

	if not newVehicle then
		return
	end

	if newVehicle ~= self._vehColTrackedVehicle then
		return
	end

	if self._vehColTrackedVehicle then
		local oldVehicle = self._vehColTrackedVehicle

		if oldVehicle and not gCS.LuaUtils.IsNull(oldVehicle.gameObject) then
			oldVehicle.StopCollisionCount(oldVehicle)
		end
	end

	self._vehColTrackedVehicle = newVehicle

	newVehicle.SetCollisionCountLayer(newVehicle, self._vehColLayerMask)
	newVehicle.StartCollisionCount(newVehicle)

	self._vehColTimerStartTime = nil
end

M._OnVehColExitVehicle = function(self)
	if self._vehColTrackedVehicle then
		local vehicle = self._vehColTrackedVehicle

		if vehicle and not gCS.LuaUtils.IsNull(vehicle.gameObject) then
			vehicle.StopCollisionCount(vehicle)
		end

		self._vehColTrackedVehicle = nil
		self._vehColTimerStartTime = nil
	end
end
