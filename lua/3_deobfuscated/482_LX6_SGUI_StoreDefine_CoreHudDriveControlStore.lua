local VehicleConfig = LTConfig.VehicleConfig
local VehicleType = LTConfig.VehicleConfig.VehicleTypeType
local bit = require("bit")
C_CoreHudDriveControlStore = DefClass("C_CoreHudDriveControlStore", C_CoreHudDriveControlStore, C_StoreGroup)
GroupName2Class.CoreHudDriveControlStore = C_CoreHudDriveControlStore
local M = C_CoreHudDriveControlStore

function M:ctor()
	self.curTypeGameplay = -1
	self.curTypeGameplayStore = nil
	self.curShowDataGameplay = nil
	self.curTypeBattle = -1
	self.curTypeBattleStore = nil
	self.curShowDataBattle = nil
	self.curTypeDriver = -1
	self.curTypeDriverStore = nil
	self.curShowDataDriver = nil
	self.curTypeType = -1
	self.curTypeTypeStore = nil
	self.curShowDataType = nil
end

function M:OnAwake()
	self.bindData.gameplayTabRect.OnRenderTab = self:CreateAction("OnGameplayRenderTab")
	self.bindData.battleTabRect.OnRenderTab = self:CreateAction("OnBattleRenderTab")
	self.bindData.driverTabRect.OnRenderTab = self:CreateAction("OnDriverRenderTab")
	self.bindData.typeTabRect.OnRenderTab = self:CreateAction("OnTypeRenderTab")
	self.started = false
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneAppHide"),
		[gEventConstants.CAR_STATE_CHANGE] = self:CreateAction("OnCarChaseStateChange"),
		[gEventConstants.ON_PLAYER_MOVE_TO_SEAT_ON_VEHICLE] = self:CreateAction("OnSwitchControl")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnEnable()
	return
end

function M:OnStart()
	self.started = true

	self:OnEnterVehicleFinish(self.currData)
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self.started = nil

	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.currData = data

	if self.started and self.currData then
		self:OnEnterVehicleFinish(self.currData)
	end
end

function M:OnClose()
	if self.currData then
		self:OnExitVehicleStart(self.currData)

		self.currData = nil
	else
		print_warn("[CoreHudShootStore]OnClose: currVehicleId is null")
	end
end

function M:OnEnterVehicleFinish(data)
	self.IsMainDrive = gDriveVehiclesManager:CheckPlayerMainDrive()
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()

	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.RideS) then
		self:OpenVehicleBattle(1)
	elseif self.curTypeBattle > -1 then
		self:OpenVehicleBattle(self.curTypeBattle)
	else
		self:StopVehicleBattle()
	end

	if gPoliceChaseManager.enterCarChase then
		self:StartVehicleGameplayByType(gVehicleGameplayType.CAR_CHASE)
	else
		self:StopVehicleActiveGameplay()
	end

	self:DriverControlIn(data)

	local cfg = VehicleConfig.GetConfig(gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle.typeId)
	local typeConfig = LTConfig.VehicleTypeConfig.GetConfig(cfg.VehicleType)

	if typeConfig then
		gMainMenuMgr.vehicleDisplayLevel = typeConfig.DisplayLevel

		SGUI.UGamePadBar.globalBar:ChangeCurDisplayLevel(typeConfig.DisplayLevel)
	end
end

function M:OnExitVehicleStart(data)
	self:StopVehicleBattle()
	self:StopVehicleActiveGameplay()
	self:DriverControlOut(data)

	gMainMenuMgr.vehicleDisplayLevel = 0
	self.IsMainDrive = false
end

function M:OnPhoneAppShow()
	self:EnterPhoneMode()
end

function M:OnPhoneAppHide()
	self:ExitPhoneMode()
end

function M:EnterPhoneMode()
	self.IsPhoneMode = true

	if self.STATE_EnableOnce and self.curTypeGameplayStore and self.curTypeGameplayStore.EnterPhoneMode then
		self.curTypeGameplayStore:EnterPhoneMode()
	end
end

function M:ExitPhoneMode()
	self.IsPhoneMode = false

	if self.STATE_EnableOnce and self.curTypeGameplayStore and self.curTypeGameplayStore.ExitPhoneMode then
		self.curTypeGameplayStore:ExitPhoneMode()
	end
end

function M:HasFlag(tags, flag)
	if tags == nil then
		return false
	end

	return bit.band(tags, flag) == flag
end

function M:StartVehicleGameplayByType(type, showData)
	self.curTypeGameplay = type

	if not self.STATE_EnableOnce then
		return
	end

	if gVehicleGameplayHasPC[self.curTypeGameplay] then
		self.curTypeGameplay = self.curTypeGameplay + 1
	end

	self.curShowDataGameplay = showData
	self.bindData.gameplayTabRect.selectedIndex = self.curTypeGameplay
end

function M:StopVehicleGameplayByType(type)
	if gVehicleGameplayHasPC[type] then
		type = type + 1
	end

	if type == self.curTypeGameplay then
		self:StopVehicleActiveGameplay()
	end
end

function M:StopVehicleActiveGameplay()
	self.curTypeGameplay = -1

	if not self.STATE_EnableOnce then
		return
	end

	if self.curTypeGameplayStore then
		self.curTypeGameplayStore:OnClose()
	end

	self.curTypeGameplayStore = nil
	self.curShowDataGameplay = nil
	self.bindData.gameplayTabRect.selectedIndex = self.curTypeGameplay
end

function M:OnGameplayRenderTab(index, widget)
	self.curTypeGameplayStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeGameplayStore then
		self.curTypeGameplayStore:OnShow(nil, self.curShowDataGameplay, widget, self.IsMainDrive, self.IsPhoneMode)
	end
end

function M:OnCarChaseStateChange(eventId, enter)
	if not self.STATE_EnableOnce then
		return
	end

	if enter then
		self:StartVehicleGameplayByType(gVehicleGameplayType.CAR_CHASE, self.currData)
	else
		self:StopVehicleGameplayByType(gVehicleGameplayType.CAR_CHASE)
	end
end

function M:OpenVehicleBattle(type, showData)
	self.curTypeBattle = type
	self.curShowDataBattle = showData

	if not self.STATE_EnableOnce then
		return
	end

	self.bindData.battleTabRect.selectedIndex = self.curTypeBattle
end

function M:StopVehicleBattle()
	if self.curTypeBattleStore then
		self.curTypeBattleStore:OnClose()
	end

	self.curTypeBattle = -1
	self.curTypeBattleStore = nil
	self.curShowDataBattle = nil

	if self.bindData.battleTabRect then
		self.bindData.battleTabRect.selectedIndex = self.curTypeBattle
	end
end

function M:OnBattleRenderTab(index, widget)
	self.curTypeBattleStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeBattleStore then
		self.curTypeBattleStore:OnShow(nil, self.curShowDataBattle, widget, self.IsMainDrive, self.IsPhoneMode)
	end
end

function M:OpenVehicleDriver(type, showData)
	self.curTypeDriver = type
	self.curShowDataDriver = showData
	self.bindData.driverTabRect.selectedIndex = self.curTypeDriver
end

function M:StopVehicleDriver()
	if self.curTypeDriverStore then
		self.curTypeDriverStore:OnClose()
	end

	self.curTypeDriver = -1
	self.curTypeDriverStore = nil
	self.curShowDataDriver = nil
	self.bindData.driverTabRect.selectedIndex = self.curTypeDriver
end

function M:OnDriverRenderTab(index, widget)
	self.curTypeDriverStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeDriverStore then
		self.curTypeDriverStore:OnShow(nil, self.curShowDataDriver, widget, self.IsMainDrive, self.IsPhoneMode)
	end
end

function M:DriverControlIn(data)
	local typeHandled = false
	local cfg = VehicleConfig.GetConfig(gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle.typeId)

	if self.IsMainDrive then
		if cfg then
			if cfg.VehicleType == VehicleType.PoliceCar then
				self:StartVehicleTypeByType(gVehicleTypeType.POLICE_CAR, data)

				typeHandled = true
			elseif cfg.VehicleType == VehicleType.Trailer then
				self:StartVehicleTypeByType(gVehicleTypeType.TOWED_VEHICLE, data)

				typeHandled = true
			elseif cfg.VehicleType == VehicleType.FireFighter then
				self:StartVehicleTypeByType(gVehicleTypeType.FIRE_ENGINE, data)

				typeHandled = true
			end
		end
	elseif cfg and cfg.VehicleType == VehicleType.Taxi then
		self:StartVehicleTypeByType(gVehicleTypeType.TAXI, data)

		typeHandled = true
	end

	if not typeHandled then
		self:StopVehicleActiveType()
	end

	if self.IsMainDrive then
		self:OpenVehicleDriver(0, data)
	else
		self:OpenVehicleDriver(1, data)
	end
end

function M:DriverControlOut(data)
	local vehicle = LX6.Drive.DriveUtils.GetVehicleInScene(data.vehicleId)
	local typeHandled = false

	if vehicle and not gCS.LuaUtils.IsNull(vehicle) then
		local cfg = VehicleConfig.GetConfig(vehicle.typeId)

		if cfg then
			if self.IsMainDrive then
				if cfg.VehicleType == VehicleType.PoliceCar then
					self:StopVehicleTypeByType(gVehicleTypeType.POLICE_CAR)

					typeHandled = true
				elseif cfg.VehicleType == VehicleType.Trailer then
					self:StopVehicleTypeByType(gVehicleTypeType.TOWED_VEHICLE)

					typeHandled = true
				elseif cfg.VehicleType == VehicleType.FireFighter then
					self:StopVehicleTypeByType(gVehicleTypeType.FIRE_ENGINE)

					typeHandled = true
				end
			elseif cfg.VehicleType == VehicleType.Taxi then
				self:StopVehicleGameplayByType(gVehicleTypeType.TAXI)

				typeHandled = true
			end
		end
	end

	if not typeHandled then
		self:StopVehicleActiveType()
	end

	self:StopVehicleDriver()
end

function M:OnSwitchControl()
	local IsMainDrive = gDriveVehiclesManager:CheckPlayerMainDrive()

	if self.IsMainDrive == IsMainDrive then
		return
	end

	self.IsMainDrive = IsMainDrive

	self:DriverControlOut(self.currData)
	self:DriverControlIn(self.currData)
end

function M:StartVehicleTypeByType(type, showData)
	self.curTypeType = type

	if not self.STATE_EnableOnce then
		return
	end

	if gVehicleTypeHasPC[self.curTypeType] then
		self.curTypeType = self.curTypeType + 1
	end

	self.curShowDataType = showData
	self.bindData.typeTabRect.selectedIndex = self.curTypeType
end

function M:StopVehicleTypeByType(type)
	if gVehicleTypeHasPC[type] then
		type = type + 1
	end

	if type == self.curTypeType then
		self:StopVehicleActiveType()
	end
end

function M:StopVehicleActiveType()
	self.curTypeType = -1

	if not self.STATE_EnableOnce then
		return
	end

	if self.curTypeTypeStore then
		self.curTypeTypeStore:OnClose()
	end

	self.curTypeTypeStore = nil
	self.curShowDataType = nil
	self.bindData.typeTabRect.selectedIndex = self.curTypeType
end

function M:OnTypeRenderTab(index, widget)
	self.curTypeTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeTypeStore then
		self.curTypeTypeStore:OnShow(nil, self.curShowDataType, widget, self.IsMainDrive, self.IsPhoneMode)
	end
end
