-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudDriveControlStore.lua
-- Decompiled from: 01491_CoreHudDriveControlStore.lua_748ced33b182.luajit

local VehicleConfig = LTConfig.VehicleConfig
local VehicleType = LTConfig.VehicleConfig.VehicleTypeType
local bit = require("bit")
C_CoreHudDriveControlStore = DefClass("C_CoreHudDriveControlStore", C_CoreHudDriveControlStore, C_StoreGroup)
GroupName2Class.CoreHudDriveControlStore = C_CoreHudDriveControlStore
local M = C_CoreHudDriveControlStore

M.ctor = function(self)
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

M.OnAwake = function(self)
	self.bindData.gameplayTabRect.OnRenderTab = self.CreateAction(self, "OnGameplayRenderTab")
	self.bindData.battleTabRect.OnRenderTab = self.CreateAction(self, "OnBattleRenderTab")
	self.bindData.driverTabRect.OnRenderTab = self.CreateAction(self, "OnDriverRenderTab")
	self.bindData.typeTabRect.OnRenderTab = self.CreateAction(self, "OnTypeRenderTab")
	self.started = false
	self.show = false
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide"),
		[gEventConstants.CAR_STATE_CHANGE] = self.CreateAction(self, "OnCarChaseStateChange"),
		[gEventConstants.ON_PLAYER_MOVE_TO_SEAT_ON_VEHICLE] = self.CreateAction(self, "OnSwitchControl"),
		[gEventConstants.ON_PLAYER_DIRECTLY_SHIFT_SEAT_ON_VEHICLE] = self.CreateAction(self, "OnSwitchControl")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	self.started = true

	if self.CheckReady(self) and self.currData then
		self.OnEnterVehicleFinish(self, self.currData)
	end
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.started = nil

	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.currData = data
	self.show = true

	if self.CheckReady(self) and self.currData then
		self.OnEnterVehicleFinish(self, self.currData)
	end

	if gBattleMgr.showVehicleShootUI then
		self.OpenVehicleBattle(self, 0)
	end
end

M.OnClose = function(self)
	if self.currData then
		self.OnExitVehicleStart(self, self.currData)

		self.currData = nil
	else
		print_warn("[CoreHudShootStore]OnClose: currVehicleId is null")
	end

	self.show = false
end

M.CheckReady = function(self)
	return self.show and self.started
end

M.OnEnterVehicleFinish = function(self, data)
	self.IsMainDrive = gDriveVehiclesManager:CheckPlayerMainDrive()
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()

	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.RideS) then
		self.OpenVehicleBattle(self, 1)
	elseif self.curTypeBattle <= -1 then
		self.OpenVehicleBattle(self, self.curTypeBattle)
	else
		self.StopVehicleBattle(self)
	end

	if gPoliceChaseManager.enterCarChase then
		self.StartVehicleGameplayByType(self, gVehicleGameplayType.CAR_CHASE)
	else
		self.StopVehicleActiveGameplay(self)
	end

	self.DriverControlIn(self, data)

	local cfg = VehicleConfig.GetConfig(gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle.cfgId)
	local typeConfig = LTConfig.VehicleTypeConfig.GetConfig(cfg.VehicleType)

	if typeConfig then
		gMainMenuMgr.vehicleDisplayLevel = typeConfig.DisplayLevel

		SGUI.UGamePadBar.globalBar:ChangeCurDisplayLevel(typeConfig.DisplayLevel)
	end
end

M.OnExitVehicleStart = function(self, data)
	self.StopVehicleBattle(self)
	self.StopVehicleActiveGameplay(self)
	self.DriverControlOut(self, data)

	gMainMenuMgr.vehicleDisplayLevel = 0
	self.IsMainDrive = false
end

M.OnPhoneAppShow = function(self)
	if not self.CheckReady(self) then
		return
	end

	self.EnterPhoneMode(self)
end

M.OnPhoneAppHide = function(self)
	if not self.CheckReady(self) then
		return
	end

	self.ExitPhoneMode(self)
end

M.EnterPhoneMode = function(self)
	self.IsPhoneMode = true

	if self.STATE_EnableOnce and self.curTypeGameplayStore and self.curTypeGameplayStore.EnterPhoneMode then
		self.curTypeGameplayStore:EnterPhoneMode()
	end
end

M.ExitPhoneMode = function(self)
	self.IsPhoneMode = false

	if self.STATE_EnableOnce and self.curTypeGameplayStore and self.curTypeGameplayStore.ExitPhoneMode then
		self.curTypeGameplayStore:ExitPhoneMode()
	end
end

M.HasFlag = function(self, tags, flag)
	if tags ~= nil then
		return false
	end

	return bit.band(tags, flag) ~= flag
end

M.StartVehicleGameplayByType = function(self, type, showData)
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

M.StopVehicleGameplayByType = function(self, type)
	if gVehicleGameplayHasPC[type] then
		type = type + 1
	end

	if type ~= self.curTypeGameplay then
		self.StopVehicleActiveGameplay(self)
	end
end

M.StopVehicleActiveGameplay = function(self)
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

M.OnGameplayRenderTab = function(self, index, widget)
	self.curTypeGameplayStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeGameplayStore then
		self.curTypeGameplayStore:OnShow(nil, self.curShowDataGameplay, widget, self.IsMainDrive, self.IsPhoneMode)
	end
end

M.OnCarChaseStateChange = function(self, eventId, enter)
	if not self.STATE_EnableOnce or not self.show then
		return
	end

	if enter then
		self.StartVehicleGameplayByType(self, gVehicleGameplayType.CAR_CHASE, self.currData)
	else
		self.StopVehicleGameplayByType(self, gVehicleGameplayType.CAR_CHASE)
	end
end

M.OpenVehicleBattle = function(self, type, showData)
	self.curTypeBattle = type
	self.curShowDataBattle = showData

	if not self.STATE_EnableOnce then
		return
	end

	self.bindData.battleTabRect.selectedIndex = self.curTypeBattle
end

M.StopVehicleBattle = function(self)
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

M.OnBattleRenderTab = function(self, index, widget)
	self.curTypeBattleStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeBattleStore then
		self.curTypeBattleStore:OnShow(nil, self.curShowDataBattle, widget, self.IsMainDrive, self.IsPhoneMode)
	end
end

M.OpenVehicleDriver = function(self, type, showData)
	self.curTypeDriver = type
	self.curShowDataDriver = showData
	self.bindData.driverTabRect.selectedIndex = self.curTypeDriver
end

M.StopVehicleDriver = function(self)
	if self.curTypeDriverStore then
		self.curTypeDriverStore:OnClose()
	end

	self.curTypeDriver = -1
	self.curTypeDriverStore = nil
	self.curShowDataDriver = nil
	self.bindData.driverTabRect.selectedIndex = self.curTypeDriver
end

M.OnDriverRenderTab = function(self, index, widget)
	self.curTypeDriverStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeDriverStore then
		self.curTypeDriverStore:OnShow(nil, self.curShowDataDriver, widget, self.IsMainDrive, self.IsPhoneMode)
	end
end

M.DriverControlIn = function(self, data)
	local typeHandled = false
	local vehicle = LX6.Drive.DriveUtils.GetBaseVehicle(data.vehicleId)

	if vehicle then
		local cfg = VehicleConfig.GetConfig(vehicle.cfgId)

		if self.IsMainDrive then
			if cfg then
				if cfg.VehicleType ~= VehicleType.PoliceCar then
					self.StartVehicleTypeByType(self, gVehicleTypeType.POLICE_CAR, data)

					typeHandled = true
				elseif cfg.VehicleType ~= VehicleType.Trailer then
					self.StartVehicleTypeByType(self, gVehicleTypeType.TOWED_VEHICLE, data)

					typeHandled = true
				elseif cfg.VehicleType ~= VehicleType.FireFighter then
					self.StartVehicleTypeByType(self, gVehicleTypeType.FIRE_ENGINE, data)

					typeHandled = true
				elseif cfg.VehicleType ~= VehicleType.Excavator then
					self.StartVehicleTypeByType(self, gVehicleTypeType.EXCAVATOR, data)

					typeHandled = true
				end
			end
		elseif cfg and cfg.VehicleType ~= VehicleType.Taxi then
			self.StartVehicleTypeByType(self, gVehicleTypeType.TAXI, data)

			typeHandled = true
		end
	end

	if not typeHandled then
		self.StopVehicleActiveType(self)
	end

	if self.IsMainDrive then
		self.OpenVehicleDriver(self, 0, data)
	else
		self.OpenVehicleDriver(self, 1, data)
	end
end

M.DriverControlOut = function(self, data)
	local vehicle = LX6.Drive.DriveUtils.GetBaseVehicle(data.vehicleId)
	local typeHandled = false

	if vehicle then
		local cfg = VehicleConfig.GetConfig(vehicle.cfgId)

		if cfg then
			if self.IsMainDrive then
				if cfg.VehicleType ~= VehicleType.PoliceCar then
					self.StopVehicleTypeByType(self, gVehicleTypeType.POLICE_CAR)

					typeHandled = true
				elseif cfg.VehicleType ~= VehicleType.Trailer then
					self.StopVehicleTypeByType(self, gVehicleTypeType.TOWED_VEHICLE)

					typeHandled = true
				elseif cfg.VehicleType ~= VehicleType.FireFighter then
					self.StopVehicleTypeByType(self, gVehicleTypeType.FIRE_ENGINE)

					typeHandled = true
				elseif cfg.VehicleType ~= VehicleType.Excavator then
					self.StopVehicleTypeByType(self, gVehicleTypeType.EXCAVATOR)

					typeHandled = true
				end
			elseif cfg.VehicleType ~= VehicleType.Taxi then
				self.StopVehicleGameplayByType(self, gVehicleTypeType.TAXI)

				typeHandled = true
			end
		end
	end

	if not typeHandled then
		self.StopVehicleActiveType(self)
	end

	self.StopVehicleDriver(self)
end

M.OnSwitchControl = function(self)
	if not self.CheckReady(self) then
		return
	end

	local IsMainDrive = gDriveVehiclesManager:CheckPlayerMainDrive()

	if self.IsMainDrive ~= IsMainDrive then
		return
	end

	self.IsMainDrive = IsMainDrive

	self.DriverControlOut(self, self.currData)
	self.DriverControlIn(self, self.currData)
end

M.StartVehicleTypeByType = function(self, type, showData)
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

M.StopVehicleTypeByType = function(self, type)
	if gVehicleTypeHasPC[type] then
		type = type + 1
	end

	if type ~= self.curTypeType then
		self.StopVehicleActiveType(self)
	end
end

M.StopVehicleActiveType = function(self)
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

M.OnTypeRenderTab = function(self, index, widget)
	self.curTypeTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeTypeStore then
		self.curTypeTypeStore:OnShow(nil, self.curShowDataType, widget, self.IsMainDrive, self.IsPhoneMode)
	end
end
