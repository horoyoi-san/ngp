-- Original chunk: @Lua\LuaFiles\LX6\Manager\Drive\DriveVehiclesManager.lua
-- Decompiled from: 00685_DriveVehiclesManager.lua_b4e084b633a2.luajit

local VehicleTypeConfig = LTConfig.VehicleTypeConfig
local VehicleConfig = LTConfig.VehicleConfig
local DriveUtils = LX6.Drive.DriveUtils
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ScriptBattleUnit = require("LX6/Utils/FormulaScriptBattleUnit")
C_DriveVehiclesManager = DefClass("C_DriveVehiclesManager", C_DriveVehiclesManager)
local M = C_DriveVehiclesManager

M.ctor = function(self)
	self.cs_manager = LX6.Drive.DriveManager.Instance
	self.isDriveMode = false
	self.isShowDriveScore = false
	self.isTaxiMode = false
	self.enableDriveSpeed = true
	self.isShowDriveSpeed = true
	self.spoonHideReset = false
	self.popupRecordDict = {}
	self.banOperation = false
	self.isInOverrideMode = false
	self.isAutoDriving = false
	self.isAutoDrivingBlocked = false
	self.isImmersiveModeBlocked = false
	self.autoDrivingVehicleDict = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.TAXI_START, self:CreateAction("OnTaxiStart"))
	gMessageManager:AddMessageListener(gEventConstants.ON_PLAYER_MOVE_TO_SEAT_ON_VEHICLE_START, self:CreateAction("OnMoveSeatStart"))
	gMessageManager:AddMessageListener(gEventConstants.ON_PLAYER_MOVE_TO_SEAT_ON_VEHICLE, self:CreateAction("OnMoveSeatEnd"))
	gMessageManager:AddMessageListener(gEventConstants.EXIT_BASE_VEHICLE_START, self:CreateAction("OnMoveSeatEnd"))
	gMessageManager:AddMessageListener(gEventConstants.VEHICLE_RESET_HIDE_BY_SPOON, self:CreateAction("OnVehicleResetChange"))
	gMessageManager:AddMessageListener(gEventConstants.VEHICLE_AUTO_DRIVE_STATE_CHANGE, self:CreateAction("OnVehicleAutoDriveStateChange"))
	self:BuildVehicleTypeDict()
end

M.OnVehicleAutoDriveStateChange = function(self, eventId, vehicleEntityId, isStart)
	if vehicleEntityId ~= self.cs_manager.CurDriveVehicleUid then
		self.isAutoDriving = isStart
	end
end

M.BuildVehicleTypeDict = function(self)
	self.typeToCfg = {}

	for index = 0, VehicleTypeConfig.count - 1 do
		local typeCfg = VehicleTypeConfig.LoadAt(index)

		if typeCfg then
			self.typeToCfg[VehicleConfig.VehicleTypeType[typeCfg.TypeName]] = typeCfg
		end
	end
end

M.GetVehicleTypeConfig = function(self, type)
	return self.typeToCfg[type]
end

M.CheckCanPopup = function(self, cfg)
	if cfg.CanShowWindow and not self.popupRecordDict[cfg.Id] then
		self.popupRecordDict[cfg.Id] = true

		return true
	end

	return false
end

M.CheckVehicleTypeWithConfigId = function(self, configId, targetType)
	local config = VehicleConfig.GetConfig(configId)

	if config ~= nil then
		return false
	end

	return config.VehicleType ~= targetType
end

M.OnEnterExitKeyDown = function(self)
	gVehicleInteractManager.cs_manager:OnLeaveVehicleButtonClick()
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.blockedSlots = nil

		table.clear(self.popupRecordDict)

		self.spoonHideReset = false
	end

	self.banOperation = false
end

M.GetUnlockedVehicleInfo = function(self, callback)
	gClientToGameDelegate:AskGetUnlockedVehicles().Callback = function (errId, data)
		if errId == 0 then
			print_error("AskGetUnlockedVehicles Failed Error = ", gCS.Error.GetNameById(errId))

			if callback == nil then
				callback(nil)
			end

			return
		end

		local vehicleList = {}

		for i = 1, #data do
			local vehicle = data[i]

			if vehicle.Id <= 0 and vehicle.Id == VehicleConfig.MilkVehicle then
				local config = VehicleConfig.GetConfig(vehicle.Id)
				local info = {
					["\\xe6W%\t\\xdc\\x9fB\\xaeX\\x99\\xb2"] = 25600393,
					vehicleName = config.VehicleName,
					vehicleQuality = config.VehicleQuality,
					vehicleConfigID = vehicle.Id,
					IsPersistent = vehicle.IsPersistent
				}

				table.insert(vehicleList, info)
			end
		end

		if callback == nil then
			callback(vehicleList)
		end
	end
end

M.AddGpsOnVehicle = function(self, vehicleUid, iconId)
	gMapSubSystem_Vehicle:AddMilkCar(vehicleUid, gRaidDataManager.RaidId, iconId)
end

M.RemoveGpsOnVehicle = function(self, vehicleUid)
	gMapSubSystem_Vehicle:RemoveMilkCar(vehicleUid)
end

M.VehicleGpsAddDetectRange = function(self, vehicleUid)
	gMapSubSystem_Vehicle:AddVehicleDetectRange(vehicleUid)
end

M.VehicleGpsRemoveDetectRange = function(self, vehicleUid)
	gMapSubSystem_Vehicle:RemoveVehicleDetectRange(vehicleUid)
end

M.RefreshVehicleControlAttribute = function(self, vehicle)
	if not vehicle then
		return
	end

	vehicle:SwitchVehicleControlDynamicParameters(not gVehicleGamePlayManager.HasDriftBadgeBuff)

	if not gDriveVehiclesManager.cs_manager.EnableVehiclePlayerAttribute then
		return
	end

	local tid = gBattleSpiritMgr.currentSpiritTemplateId
	local attr = gSpiritManager:GetUrbanAttr(tid)
	local oriAttribute = vehicle.OriVehicleControlAttribute
	local curAttribute = vehicle.CurVehicleControlAttribute
	local unit = nil
	local myPlayerUnitId = gCS.MyPlayerManager.PlayerUnitId

	if not ulong.equals(myPlayerUnitId, ulong.zero) then
		unit = ScriptBattleUnit.New(myPlayerUnitId)
	end

	curAttribute.MaxSpeedForward = Formula_cs:CalVehicleSpeedUpgrade1(attr, oriAttribute.MaxSpeedForward, unit)
	curAttribute.IdleTorque = Formula_cs:CalVehicleSpeedUpgrade2(attr, oriAttribute.IdleTorque, unit)
	curAttribute.PeakTorque = Formula_cs:CalVehicleSpeedUpgrade3(attr, oriAttribute.PeakTorque, unit)
	curAttribute.MaxRPMTorque = Formula_cs:CalVehicleSpeedUpgrade4(attr, oriAttribute.MaxRPMTorque, unit)
	curAttribute.SteerLerpBackSpeed = Formula_cs:CalVehicleDriftUpgrade(attr, oriAttribute.SteerLerpBackSpeed, unit)

	vehicle:RefreshVehicleControlAttribute(false)
end

M.ResetVehicleControlAttribute = function(self, vehicle)
	if not vehicle then
		return
	end

	vehicle:SwitchVehicleControlDynamicParameters(not gVehicleGamePlayManager.HasDriftBadgeBuff)

	if not gDriveVehiclesManager.cs_manager.EnableVehiclePlayerAttribute then
		return
	end

	vehicle:ResetVehicleControlAttribute()
end

M.ShowVehicleHUD = function(self, vehicle_uid, enable)
	if enable then
		gHudMgr:CreateVehicle(vehicle_uid)
		gHudMgr:OnShowIdVehicle(vehicle_uid, true, "")
	else
		gHudMgr:OnRemoveIdVehicle(vehicle_uid)
	end
end

M.CheckPlayerMainDrive = function(self)
	return gDriveVehiclesManager.cs_manager.CurDriveSeatIndex ~= 0
end

M.GetVehicleUid = function(self, vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	return vehicleId
end

M.TryGetBaseVehicleWithCallback = function(self, vehicleId, callback)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	LX6.Drive.DriveUtils.TryGetBaseVehicleWithCallback(vehicleId, callback)
end

M.GetVehicleInScene = function(self, vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	return LX6.Drive.DriveManager.GetBaseVehicle(vehicleId)
end

M.GetVehicleSpeed = function(self, vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	local vehicle = LX6.Drive.DriveUtils.GetBaseVehicle(vehicleId)

	if vehicle ~= nil then
		return 0
	end

	return vehicle.Speed
end

M.GetBaseVehicle = function(self, vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	local vehicle = LX6.Drive.DriveUtils.GetBaseVehicle(vehicleId)

	return vehicle
end

M.IsVehicleLoaded = function(self, vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	return self.cs_manager:IsVehicleLoaded(vehicleId)
end

M.OnTaxiStart = function(self)
	if self.isShowDriveScore then
		self.isShowDriveScore = false

		gStoreManager:GetStoreGroup("DriveControlDriverStore"):ShowDriveScore(false)
	end
end

M.OnMoveSeatStart = function(self)
	self.banOperation = true
end

M.OnMoveSeatEnd = function(self)
	self.banOperation = false
end

M.OnVehicleResetChange = function(self, eventId, spoonHide)
	self.spoonHideReset = spoonHide
end

M.SyncBlockedVehicleSummonSlots = function(self, blockedSlots)
	self.blockedSlots = blockedSlots
end

M.CheckVehicleBlock = function(self, id)
	if table.isNilOrEmpty(self.blockedSlots) then
		return
	end

	local vehicleSlotType = self:GetVehicleSlotType(id)

	for _, blockedSlot in ipairs(self.blockedSlots) do
		if vehicleSlotType ~= blockedSlot then
			return true
		end
	end

	return false
end

M.GetVehicleSlotType = function(self, id)
	if id ~= LTConfig.VehicleConfig.MilkVehicle then
		return UX.Game.VehicleSummonSlotType.Milk
	elseif id ~= LTConfig.VehicleConfig.HackerVehicle then
		return UX.Game.VehicleSummonSlotType.Hacker
	end

	return UX.Game.VehicleSummonSlotType.Normal
end

M.SyncPlayerAutonomousDrivingState = function(self, isInOverrideMode, isAutoDrivingBlocked, isImmersiveModeBlocked)
	self.isInOverrideMode = isInOverrideMode
	self.isAutoDrivingBlocked = isAutoDrivingBlocked
	self.isImmersiveModeBlocked = isImmersiveModeBlocked
end

M.GetPlayerAutonomousDrivingState = function(self)
	return self.isInOverrideMode, self.isAutoDrivingBlocked, self.isImmersiveModeBlocked
end

M.ChangeVehicleView = function(self)
	local val = LX6.Cinemachine.NPDVehicleCameraState.GetArmLengthPreference()
	val = val + 1

	if val <= 4 then
		val = 1
	end

	if val ~= 4 then
		SGUI.UOffScreenRendering.EnableOffScreenWithIdentifier("CarDashBoard", true)
	else
		SGUI.UOffScreenRendering.EnableOffScreenWithIdentifier("CarDashBoard", false)
	end

	LX6.Cinemachine.NPDVehicleCameraState.SetArmLengthPreference(val, true)
end

M.SyncVehicleAutonomousDrivingState = function(self, vehicleEntityId, isStart)
	if isStart then
		self.autoDrivingVehicleDict[vehicleEntityId] = true
	else
		self.autoDrivingVehicleDict[vehicleEntityId] = nil
	end

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.VEHICLE_AUTO_DRIVE_STATE_CHANGE, vehicleEntityId, isStart)
end

M.GetVehicleInAutonomousDriving = function(self, vehicleEntityId)
	return self.autoDrivingVehicleDict[vehicleEntityId] or false
end

gDriveVehiclesManager = gDriveVehiclesManager or C_DriveVehiclesManager.new()
