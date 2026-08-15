local VehicleTypeConfig = LTConfig.VehicleTypeConfig
local VehicleConfig = LTConfig.VehicleConfig
local DriveUtils = LX6.Drive.DriveUtils
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ScriptBattleUnit = require("LX6/Utils/FormulaScriptBattleUnit")
C_DriveVehiclesManager = DefClass("C_DriveVehiclesManager", C_DriveVehiclesManager)
local M = C_DriveVehiclesManager

function M:ctor()
	self.cs_manager = LX6.Drive.DriveManager.Instance
	self.isDriveMode = false
	self.isShowDriveScore = false
	self.isTaxiMode = false
	self.enableDriveSpeed = true
	self.isShowDriveSpeed = true

	gMessageManager:AddMessageListener(gEventConstants.TAXI_START, function ()
		if self.isShowDriveScore then
			self.isShowDriveScore = false

			gStoreManager:GetStoreGroup("DriveControlDriverStore"):ShowDriveScore(false)
		end
	end)

	self.popupRecordDict = {}
end

function M:OnInit()
	self:BuildVehicleTypeDict()
end

function M:BuildVehicleTypeDict()
	self.typeToCfg = {}

	for index = 0, VehicleTypeConfig.count - 1 do
		local typeCfg = VehicleTypeConfig.LoadAt(index)

		if typeCfg then
			self.typeToCfg[VehicleConfig.VehicleTypeType[typeCfg.TypeName]] = typeCfg
		end
	end
end

function M:GetVehicleTypeConfig(type)
	return self.typeToCfg[type]
end

function M:CheckCanPopup(cfg)
	if cfg.CanShowWindow and not self.popupRecordDict[cfg.Id] then
		self.popupRecordDict[cfg.Id] = true

		return true
	end

	return false
end

function M:CheckVehicleTypeWithConfigId(configId, targetType)
	local config = VehicleConfig.GetConfig(configId)

	if config == nil then
		return false
	end

	return config.VehicleType == targetType
end

function M:OnEnterExitKeyDown()
	gVehicleInteractManager.cs_manager:OnLeaveVehicleButtonClick()
end

function M:ExitCarState()
	gDriveVehiclesManager.cs_manager:ExitDriveModeState()

	self.isDriveMode = self.cs_manager.isDriveMode
	self.isShowDriveScore = false
	gVehicleInteractManager.cs_manager.isInteracting = false
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		table.clear(self.popupRecordDict)
	end
end

function M:GetUnlockedVehicleInfo(callback)
	gClientToGameDelegate:AskGetUnlockedVehicles().Callback = function (errId, data)
		if errId ~= 0 then
			print_error("AskGetUnlockedVehicles Failed Error = ", gCS.Error.GetNameById(errId))

			if callback ~= nil then
				callback(nil)
			end

			return
		end

		local vehicleList = {}

		for i = 1, #data do
			local vehicle = data[i]

			if vehicle.Id > 0 and vehicle.Id ~= VehicleConfig.MilkVehicle then
				local config = VehicleConfig.GetConfig(vehicle.Id)
				local info = {
					vehicleIconId = 25600393,
					vehicleName = config.VehicleName,
					vehicleQuality = config.VehicleQuality,
					vehicleConfigID = vehicle.Id
				}

				table.insert(vehicleList, info)
			end
		end

		if callback ~= nil then
			callback(vehicleList)
		end
	end
end

function M:AddGpsOnVehicle(vehicleUid, iconId)
	gMapSubSystem_Vehicle:AddMilkCar(vehicleUid, gRaidDataManager.RaidId, iconId)
end

function M:RemoveGpsOnVehicle(vehicleUid)
	gMapSubSystem_Vehicle:RemoveMilkCar(vehicleUid)
end

function M:VehicleGpsAddDetectRange(vehicleUid)
	gMapSubSystem_Vehicle:AddVehicleDetectRange(vehicleUid)
end

function M:VehicleGpsRemoveDetectRange(vehicleUid)
	gMapSubSystem_Vehicle:RemoveVehicleDetectRange(vehicleUid)
end

function M:CheckSummonVehicle()
	return not self.isInEnterOrLeaveCarAnim and not self.isDriveMode and gCS.PaoKuManager.ParkourStateLua == LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.OpenPhone
end

function M:RefreshVehicleControlAttribute(vehicle)
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

function M:ResetVehicleControlAttribute(vehicle)
	if not vehicle then
		return
	end

	vehicle:SwitchVehicleControlDynamicParameters(not gVehicleGamePlayManager.HasDriftBadgeBuff)

	if not gDriveVehiclesManager.cs_manager.EnableVehiclePlayerAttribute then
		return
	end

	vehicle:ResetVehicleControlAttribute()
end

function M:ShowVehicleHUD(vehicle_uid, enable)
	if enable then
		gHudMgr:CreateVehicle(vehicle_uid)
		gHudMgr:OnShowIdVehicle(vehicle_uid, true, "")
	else
		gHudMgr:OnRemoveIdVehicle(vehicle_uid)
	end
end

function M:CheckPlayerMainDrive()
	return gDriveVehiclesManager.cs_manager.CurDriveSeatIndex == 0
end

function M:GetVehicleUid(vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	return vehicleId
end

function M:TryGetVehicleWithCallback(vehicleId, callback)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	LX6.Drive.DriveUtils.TryGetVehicleWithCallback(vehicleId, callback)
end

function M:TryGetBaseVehicleWithCallback(vehicleId, callback)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	LX6.Drive.DriveUtils.TryGetBaseVehicleWithCallback(vehicleId, callback)
end

function M:GetVehicleInScene(vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	return LX6.Drive.DriveUtils.GetVehicleInScene(vehicleId)
end

function M:GetVehicleSpeed(vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	local vehicle = LX6.Drive.DriveUtils.GetBaseVehicle(vehicleId)

	if vehicle == nil then
		return 0
	end

	return vehicle.Speed
end

function M:GetBaseVehicle(vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	local vehicle = LX6.Drive.DriveUtils.GetBaseVehicle(vehicleId)

	return vehicle
end

function M:IsVehicleLoaded(vehicleId)
	if not ulong.check(vehicleId) then
		vehicleId = LX6.Drive.DriveUtils.GetVehicleInstanceIdBySpoonId(vehicleId)
	end

	return self.cs_manager:IsVehicleLoaded(vehicleId)
end

gDriveVehiclesManager = gDriveVehiclesManager or C_DriveVehiclesManager.new()
