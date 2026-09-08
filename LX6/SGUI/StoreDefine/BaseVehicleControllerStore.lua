-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaseVehicleControllerStore.lua
-- Decompiled from: 01654_BaseVehicleControllerStore.lua_849add990d0c.luajit

local VehicleType = LTConfig.VehicleConfig.VehicleTypeType
local VehicleSeatState = LX6.Drive.VehicleSeatState
local DriveManager = gCS.DriveManager
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local EVehicleTrafficLightState = LX6.Drive.EVehicleTrafficLightState
local HudDescConfig = LTConfig.HudDescConfig
C_BaseVehicleControllerStore = DefClass("C_BaseVehicleControllerStore", C_BaseVehicleControllerStore, C_StoreGroup)
GroupName2Class.BaseVehicleControllerStore = C_BaseVehicleControllerStore
local M = C_BaseVehicleControllerStore

M.ctor = function(self)
	self.DEFINE_DynamicOnUpdate = true
end

M.DefineAllVariables = function(self)
	self.curTab = -1
	self.curVehicleStore = nil
	self.CONTROL = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.OCCUPY = {
		["h\\x83\\x92\\x9b\\x8f"] = 0,
		[",d\\xb0\\xb7\\xa6s"] = 1,
		["@B\\x84R~\\x8d\\xc2kKC[~"] = 2,
		["\\xa0XE"] = 3
	}
	self.seats = {}
	self.curTypeGameplay = -1
	self.curTypeGameplayStore = nil
	self.curShowDataGameplay = nil
	self.raceMode = false
	self.AutoDrive = {
		["+\\xf0~9\\xdf8\\xa4H\\xb7_\\xbe\\xb1"] = false,
		["[w\\xbepI\\xa6\\xd7IkxrI"] = false,
		["\\xf8\\xc8*-\\xe5"] = false,
		TargetPos = Vector3.New(0, 0, 0)
	}
	self.anyBtnTriggerCb = self.CreateAction(self, "OnAnyBtnTrigger")
	self.immersiveCheckTime = -1
	self.immersiveMode = false
	self.immersiveModeIgnoreFrame = 0
	self.immersiveCloseTime = 0
	self.isInOverrideMode = false
	self.isAutoDrivingBlocked = false
	self.isImmersiveModeBlocked = false
	self.BTN_VALID = {
		["R^p"] = false,
		["ro\\xfa\\x92\\xbb,\\x8a-\\xff\\xcd"] = false,
		["\\xac\t[\\xb5~\\xea\\x8b\\x8d"] = true,
		["LXl"] = true,
		["ȯ%\\xd337\\xd9-Ϡġ\r"] = true,
		["\\x8b\\x91\\x8a\\x82"] = false
	}
	self.vehicleReady = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.outOfVehicleBtnStore = self:GetStoreByWidget(self.bindData.outOfVehicleBtn)
	self.outOfVehicleBtnStore.btnId = HudDescConfig.BASE_OUT_OF_VEHICLE_BTN
	self.viewBtnStore = self:GetStoreByWidget(self.bindData.viewBtn)
	self.viewBtnStore.btnId = HudDescConfig.BASE_VIEW_BTN
	self.resetBtnStore = self:GetStoreByWidget(self.bindData.resetBtn)
	self.resetBtnStore.btnId = HudDescConfig.BASE_RESET_BTN
	self.autoDriveBtnStore = self:GetStoreByWidget(self.bindData.autoDriveBtn)
	self.autoDriveBtnStore.btnId = HudDescConfig.BASE_AUTODRIVE_BTN
	self.switchSeatBtnStore = self:GetStoreByWidget(self.bindData.switchSeatBtn)
	self.switchSeatBtnStore.btnId = HudDescConfig.BASE_SWITCH_SEAT_BTN

	gStoreButtonMgr:SetButtonEnterBarBsae(self.resetBtnStore, false)
	gCS.LuaUtils.RegisterAnyInputTrigger(self.anyBtnTriggerCb)
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.msgEvents = nil

	gCS.LuaUtils.UnRegisterAnyInputTrigger(self.anyBtnTriggerCb)

	self.outOfVehicleBtnStore = nil
	self.viewBtnStore = nil
	self.resetBtnStore = nil
	self.autoDriveBtnStore = nil
	self.switchSeatBtnStore = nil
end

M.OnDestroy = function(self)
	self:StopVehicleActiveController()
	self:StopBaseVehicleActiveGameplay()

	self.vehicleId = nil
	self.vehicleCs = nil
	self.vehicleCfg = nil
	self.seats = nil
	self.curTypeGameplay = -1
	self.curTypeGameplayStore = nil
	self.curShowDataGameplay = nil

	self:SetImmersiveModeEnable(false)
	gStoreManager:UnregisterDynamicOnUpdate(self)
end

M.OnUpdate = function(self)
	if self.vehicleReady and self.BTN_VALID.AUTO_DRIVE and self.AutoDrive.IsAutoDriving and self.curTab == gHUDBaseVehicleType.HACK_INTERIOR then
		self.UpdateImmersiveMode(self)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ENTER_BASE_VEHICLE_FINISH] = self.CreateAction(self, "OnEnterBaseVehicleFinish"),
		[gEventConstants.EXIT_BASE_VEHICLE_START] = self.CreateAction(self, "OnExitBaseVehicleStart"),
		[gEventConstants.ON_UNIT_GET_IN_VEHICLE] = self.CreateAction(self, "OnSeatInfoChange"),
		[gEventConstants.ON_UNIT_GET_OUT_VEHICLE] = self.CreateAction(self, "OnSeatInfoChange"),
		[gEventConstants.ON_PLAYER_DIRECTLY_SHIFT_SEAT_ON_VEHICLE] = self.CreateAction(self, "OnSeatInfoChange"),
		[gEventConstants.CAR_PRESS_BAR_STATE_CHANGE] = self.CreateAction(self, "OnCommonPressStateChange"),
		[gEventConstants.CAR_RACE_STATE_CHANGE] = self.CreateAction(self, "OnCarRaceStateChange"),
		[gEventConstants.VEHICLE_RESET_STATE_CHANGED] = self.CreateAction(self, "OnResetStateChange"),
		[gEventConstants.VEHICLE_RESET_HIDE_BY_SPOON] = self.CreateAction(self, "OnVehicleResetChangeBySpoon"),
		[gEventConstants.PLAYER_AUTO_DRIVE_STATE_CHANGE] = self.CreateAction(self, "OnPlayerAutonomousDrivingStateChange"),
		[gEventConstants.VEHICLE_AUTO_DRIVE_STATE_CHANGE] = self.CreateAction(self, "OnVehicleAutoDriveStateChange"),
		[gEventConstants.VEHICLE_TRAFFIC_LIGHT_STATE_CHANGE] = self.CreateAction(self, "OnTrafficLightStateChange"),
		[gEventConstants.VEHICLE_NAV_TARGET_STATE_CHANGE] = self.CreateAction(self, "OnVehicleNavTargetChange"),
		[gEventConstants.CHALLENGE_GOAL_START] = self.CreateAction(self, "OnChallengeGoalStart"),
		[gEventConstants.CHALLENGE_GOAL_END] = self.CreateAction(self, "OnChallengeGoalEnd"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self.CreateAction(self, "OnSystemUnlock"),
		[gEventConstants.LOCK_DRIVE_MODE] = self.CreateAction(self, "OnLockDriveModeChange"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide"),
		[gEventConstants.ON_PLAYER_MOVE_TO_SEAT_ON_VEHICLE] = self.CreateAction(self, "OnSwitchControl"),
		[gEventConstants.ON_PLAYER_DIRECTLY_SHIFT_SEAT_ON_VEHICLE] = self.CreateAction(self, "OnSwitchControl")
	}
end

M.OnEnterBaseVehicleFinish = function(self, eventId, vehicleId)
	self.vehicleId = vehicleId
	self.vehicleCs = DriveManager:GetBaseVehicle(self.vehicleId)
	self.vehicleCfg = self.vehicleCs and LTConfig.VehicleConfig.GetConfig(self.vehicleCs.cfgId)

	gCoreHudModeMgr:PushHudMode("BaseVehicle_" .. self.vehicleId, gCoreHudModeMgr.HUD_MODE.BASEVEHICLE)

	if self.vehicleCs and self.vehicleCs.IsAutomobile then
		self.StartVehicleControllerByType(self, gHUDBaseVehicleType.DRIVE)
	elseif self.vehicleCs and self.vehicleCs.IsMotorcycle then
		if self.vehicleCfg and self.vehicleCfg.VehicleType ~= VehicleType.Bicycle then
			self.StartVehicleControllerByType(self, gHUDBaseVehicleType.BICYCLE)
		else
			self.StartVehicleControllerByType(self, gHUDBaseVehicleType.MOTOR)
		end
	elseif self.vehicleCs and self.vehicleCs.IsHelicopter then
		self.StartVehicleControllerByType(self, gHUDBaseVehicleType.HELICOPTER)
	elseif self.vehicleCs and self.vehicleCs.IsBoat then
		if self.vehicleCfg and self.vehicleCfg.VehicleType ~= VehicleType.HandPoweredBoat then
			self.StartVehicleControllerByType(self, gHUDBaseVehicleType.HAND_BOAT)
		else
			self.StartVehicleControllerByType(self, gHUDBaseVehicleType.BOAT)
		end
	end

	self.StopBaseVehicleActiveGameplay(self)
end

M.OnExitBaseVehicleStart = function(self, eventId, vehicleId)
	if self.vehicleId == vehicleId then
		print_warn("OnExitBaseVehicleStart Warn, vehicle Id not equal. self.vehicleId=", self.vehicleId, "vehicleId=", vehicleId)
	end

	gCoreHudModeMgr:PopHudMode("BaseVehicle_" .. vehicleId, true)

	if self.vehicleCs and self.vehicleCs.IsAutomobile then
		self.StopVehicleControllerByType(self, gHUDBaseVehicleType.DRIVE)
	elseif self.vehicleCs and self.vehicleCs.IsMotorcycle then
		if self.vehicleCfg and self.vehicleCfg.VehicleType ~= VehicleType.Bicycle then
			self.StopVehicleControllerByType(self, gHUDBaseVehicleType.BICYCLE)
		else
			self.StopVehicleControllerByType(self, gHUDBaseVehicleType.MOTOR)
		end
	elseif self.vehicleCs and self.vehicleCs.IsHelicopter then
		self.StopVehicleControllerByType(self, gHUDBaseVehicleType.HELICOPTER)
	elseif self.vehicleCs and self.vehicleCs.IsBoat then
		if self.vehicleCfg and self.vehicleCfg.VehicleType ~= VehicleType.HandPoweredBoat then
			self.StopVehicleControllerByType(self, gHUDBaseVehicleType.HAND_BOAT)
		else
			self.StopVehicleControllerByType(self, gHUDBaseVehicleType.BOAT)
		end
	end

	self.vehicleId = nil
	self.vehicleCs = nil
	self.vehicleCfg = nil

	self.StopBaseVehicleActiveGameplay(self)
end

M.StartVehicleControllerByType = function(self, vehicleType)
	if vehicleType ~= nil then
		return
	end

	self.curTab = vehicleType
	self.bindData.tabRect.selectedIndex = vehicleType
end

M.StopVehicleControllerByType = function(self, vehicleType)
	if vehicleType ~= self.curTab then
		self.StopVehicleActiveController(self)
	end
end

M.StopVehicleActiveController = function(self)
	self.curTab = -1

	if self.curVehicleStore then
		if self.BTN_VALID.AUTO_DRIVE then
			self:SetAutoDriving(false)
			self:SetImmersiveModeEnable(false)
			gStoreManager:UnregisterDynamicOnUpdate(self)
		end

		self.curVehicleStore:OnClose()
	end

	self.curVehicleStore = nil
	self.bindData.tabRect.selectedIndex = self.curTab

	if self.popupId then
		gNewPopupManager:RemovePopup(self.popupId)

		self.popupId = nil
	end

	self.vehicleReady = false
	self.bindData.enterVehicleCtrl = self.CONTROL.FALSE
end

M.OnEnterBaseVehicleInterior = function(self, eventId, vehicleId)
	self.vehicleId = vehicleId
	self.vehicleCs = DriveManager:GetBaseVehicle(self.vehicleId)
	self.vehicleCfg = self.vehicleCs and LTConfig.VehicleConfig.GetConfig(self.vehicleCs.cfgId)

	gCoreHudModeMgr:PushHudMode("BaseVehicle_" .. self.vehicleId, gCoreHudModeMgr.HUD_MODE.HACK_VEHICLE_INTERIOR)
	self:StartVehicleControllerByType(gHUDBaseVehicleType.HACK_INTERIOR)
	self:StopBaseVehicleActiveGameplay()
end

M.OnExitBaseVehicleInterior = function(self, eventId, vehicleId)
	if self.vehicleId == vehicleId then
		print_warn("OnExitBaseVehicleStart Warn, vehicle Id not equal. self.vehicleId=", self.vehicleId, "vehicleId=", vehicleId)
	end

	gCoreHudModeMgr:PopHudMode("BaseVehicle_" .. vehicleId, true)
	self:StopVehicleControllerByType(gHUDBaseVehicleType.HACK_INTERIOR)

	self.vehicleId = nil
	self.vehicleCs = nil
	self.vehicleCfg = nil

	self:StopBaseVehicleActiveGameplay()
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
	self.bindData.gameplayTabRect.OnRenderTab = self.CreateAction(self, "OnGameplayRenderTab")
	self.bindData.seatList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSeatListItem")
	self.bindData.switchSeatBtn.luaClick = self.CreateAction(self, "OnSwitchSeatBtnClick")
	self.bindData.outOfVehicleBtn.luaClick = self.CreateAction(self, "OnOutOfVehicleBtnClick")
	self.bindData.outOfVehicleBtn.luaLongPress = self.CreateAction(self, "OnOutOfVehicleBtnClick")
	self.bindData.viewBtn.luaClick = self.CreateAction(self, "OnViewBtnClick")
	self.bindData.resetBtn.luaClick = self.CreateAction(self, "OnResetBtnClick")
	self.bindData.autoDriveBtn.luaClick = self.CreateAction(self, "OnAutoDriveBtnClick")
	self.bindData.autoDriveBtn.luaLongPress = self.CreateAction(self, "OnAutoDriveBtnClick")
end

M.OnTabRectRender = function(self, index, widget)
	self.curVehicleStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curVehicleStore then
		local cfg = LTConfig.VehicleConfig.GetConfig(self.vehicleCs.cfgId)

		if cfg and gDriveVehiclesManager:CheckCanPopup(cfg) then
			self.popupId = gNewPopupManager:PushPopup(LTConfig.PopupConfig.BaseVehicleInfo, cfg)
		end

		self.raceMode = gVehicleGamePlayManager.isCarRaceMode
		self.phoneOpen = gClientUtils.CheckMainPhoneIsShowing()
		self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
		self.isMobilePlatform = gCS.LuaUtils.IsMobilePlatform()
		self.resetValid = self.vehicleCs.IsResetValid
		self.isMainDrive = gDriveVehiclesManager:CheckPlayerMainDrive()
		self.spoonHideReset = gDriveVehiclesManager.spoonHideReset
		self.bindData.phoneOpenCtrl = self.phoneOpen and self.CONTROL.TRUE or self.CONTROL.FALSE

		self:InitButtonValidCheck()

		self.vehicleReady = true

		if self.BTN_VALID.RESET then
			self.bindData.resetBtn:SetShowTipTotally(self.raceMode)
			self:RefreshResetBtnState()
		end

		if self.BTN_VALID.AUTO_DRIVE then
			self.AutoDrive.TargetEnable, self.AutoDrive.TargetPos = LX6.Gps.MapSystem.Instance:TryGetVehicleNavTargetPosition(self.AutoDrive.TargetPos)
			self.isInOverrideMode, self.isAutoDrivingBlocked, self.isImmersiveModeBlocked = gDriveVehiclesManager:GetPlayerAutonomousDrivingState()

			self:SetAutoDriving(gDriveVehiclesManager:GetVehicleInAutonomousDriving(self.vehicleId))
			self:SetImmersiveModeEnable(false)
			self:RefreshPlayerAutonomousDrivingState()
			self:RefreshTrafficLightState()
		end

		self.RefreshViewBtnState(self)

		if self.BTN_VALID.OUT_OF_VEHICLE then
			self.RefreshOutOfVehicleBtnState(self)
		end

		if self.BTN_VALID.SWITCH_SEAT then
			self.RefreshSwitchSeatBtnState(self)
		end

		self.curVehicleStore:OnShow(nil, {
			vehicleId = self.vehicleId,
			vehicleCs = self.vehicleCs
		})

		self.bindData.enterVehicleCtrl = self.CONTROL.TRUE
	end
end

M.StartBaseVehicleGameplayByType = function(self, type, showData)
	self.curTypeGameplay = type

	if not self.STATE_EnableOnce then
		return
	end

	self.curShowDataGameplay = showData
	self.bindData.gameplayTabRect.selectedIndex = self.curTypeGameplay
end

M.StopBaseVehicleGameplayByType = function(self, type)
	if type ~= self.curTypeGameplay then
		self.StopBaseVehicleActiveGameplay(self)
	end
end

M.StopBaseVehicleActiveGameplay = function(self)
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
		self.curTypeGameplayStore:OnShow(nil, {
			vehicleId = self.vehicleId,
			vehicleCs = self.vehicleCs,
			showData = self.curShowDataGameplay
		})
	end
end

M.OnCommonPressStateChange = function(self, eventId, params)
	if not self.STATE_EnableOnce then
		return
	end

	if params.openPanel then
		self.StartBaseVehicleGameplayByType(self, gBaseVehicleGameplayType.PRESS_BAR, params)
	else
		self.StopBaseVehicleGameplayByType(self, gBaseVehicleGameplayType.PRESS_BAR)
	end
end

M.OnOutOfVehicleBtnClick = function(self)
	if gDriveVehiclesManager.banOperation then
		return
	end

	gDriveVehiclesManager:OnEnterExitKeyDown()
end

M.OnViewBtnClick = function(self)
	if self.curTab ~= gHUDBaseVehicleType.HACK_INTERIOR then
		gVehicleGamePlayManager:HackAutoDriveSwitchView()
	else
		gDriveVehiclesManager:ChangeVehicleView()
	end
end

M.OnResetBtnClick = function(self)
	if gDriveVehiclesManager.banOperation then
		return
	end

	gDriveVehiclesManager.cs_manager:ResetMyVehicle()
end

M.OnAutoDriveBtnClick = function(self)
	if self.AutoDrive.IsAutoDriving then
		slot1 = gClientToGameSceneDelegate

		slot1:AskVehicleStopAutonomousDriving().Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	elseif not self.AutoDrive.AskWait then
		self.AutoDrive.AskWait = true
		slot1 = gClientToGameSceneDelegate

		slot1:AskVehicleStartAutonomousDriving(self.AutoDrive.TargetEnable, UX.Game.UXVector3.New(self.AutoDrive.TargetPos.x, self.AutoDrive.TargetPos.y, self.AutoDrive.TargetPos.z)).Callback = function (err)
			self.AutoDrive.AskWait = false

			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
				gDisplayMessageMgr:ShowMessageContentDebug("Temp Debug Message:AutoDrive not Available")
			end
		end
	end
end

M.OnSwitchSeatBtnClick = function(self)
	if gDriveVehiclesManager.banOperation then
		return
	end

	gVehicleInteractManager.cs_manager:PlayerDirectlyShiftSeatOnVehicle()
end

M.OnCarRaceStateChange = function(self, eventId, state)
	if not self.STATE_EnableOnce or not self.vehicleReady then
		return
	end

	self.raceMode = state

	if self.BTN_VALID.RESET then
		self.bindData.resetBtn:SetShowTipTotally(state)
		self:RefreshResetBtnState()
	end

	if self.BTN_VALID.SWITCH_SEAT then
		self.RefreshSwitchSeatBtnState(self)
	end
end

M.OnSystemUnlock = function(self, eventId, id)
	if not self.STATE_EnableOnce or not self.vehicleReady then
		return
	end

	if id ~= SystemUnlockConfig.BaseVehicleControllerView then
		self.RefreshViewBtnState(self)
	elseif id ~= SystemUnlockConfig.DriveControlsAutopilot then
		self.InitAutoDriveValidCheck(self)
	end
end

M.OnPlayerAutonomousDrivingStateChange = function(self)
	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.AUTO_DRIVE then
		return
	end

	self.RefreshPlayerAutonomousDrivingState(self)
end

M.OnLockDriveModeChange = function(self, eventId, lock)
	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.OUT_OF_VEHICLE then
		return
	end

	self.RefreshOutOfVehicleBtnState(self)
end

M.OnSeatInfoChange = function(self)
	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.SWITCH_SEAT then
		return
	end

	self.RefreshSwitchSeatBtnState(self)
end

M.OnPhoneAppShow = function(self)
	if not self.STATE_EnableOnce or not self.vehicleReady then
		return
	end

	self.phoneOpen = true
	self.bindData.phoneOpenCtrl = self.CONTROL.TRUE

	if self.BTN_VALID.OUT_OF_VEHICLE then
		self.RefreshOutOfVehicleBtnState(self)
	end
end

M.OnPhoneAppHide = function(self)
	if not self.STATE_EnableOnce or not self.vehicleReady then
		return
	end

	self.phoneOpen = false
	self.bindData.phoneOpenCtrl = self.CONTROL.FALSE

	if self.BTN_VALID.OUT_OF_VEHICLE then
		self.RefreshOutOfVehicleBtnState(self)
	end
end

M.OnSwitchControl = function(self)
	if not self.STATE_EnableOnce or not self.vehicleReady then
		return
	end

	local isMainDrive = gDriveVehiclesManager:CheckPlayerMainDrive()

	if self.isMainDrive ~= isMainDrive then
		return
	end

	self.isMainDrive = isMainDrive

	self.InitButtonValidCheck(self)

	if self.BTN_VALID.RESET then
		self.bindData.resetBtn:SetShowTipTotally(self.raceMode)
		self:RefreshResetBtnState()
	end

	if self.BTN_VALID.AUTO_DRIVE then
		self.AutoDrive.TargetEnable, self.AutoDrive.TargetPos = LX6.Gps.MapSystem.Instance:TryGetVehicleNavTargetPosition(self.AutoDrive.TargetPos)
		self.isInOverrideMode, self.isAutoDrivingBlocked, self.isImmersiveModeBlocked = gDriveVehiclesManager:GetPlayerAutonomousDrivingState()

		self:SetAutoDriving(gDriveVehiclesManager:GetVehicleInAutonomousDriving(self.vehicleId))
		self:SetImmersiveModeEnable(false)
		self:RefreshPlayerAutonomousDrivingState()
		self:RefreshTrafficLightState()
	end
end

M.OnChallengeGoalStart = function(self)
	self.isChallenging = true

	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.AUTO_DRIVE then
		return
	end

	self.RefreshAutoDriveBtnState(self)
end

M.OnChallengeGoalEnd = function(self)
	self.isChallenging = false

	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.AUTO_DRIVE then
		return
	end

	self.RefreshAutoDriveBtnState(self)
end

M.OnVehicleNavTargetChange = function(self, eventId, isDelete)
	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.AUTO_DRIVE then
		return
	end

	self.AutoDrive.TargetEnable, self.AutoDrive.TargetPos = LX6.Gps.MapSystem.Instance:TryGetVehicleNavTargetPosition(self.AutoDrive.TargetPos)

	if self.AutoDrive.IsAutoDriving then
		if not isDelete and self.AutoDrive.TargetEnable then
			slot3 = gClientToGameSceneDelegate

			slot3:AskVehicleChangeAutonomousDrivingTarget(UX.Game.UXVector3.New(self.AutoDrive.TargetPos.x, self.AutoDrive.TargetPos.y, self.AutoDrive.TargetPos.z)).Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		elseif isDelete then
			slot3 = gClientToGameSceneDelegate

			slot3:AskVehicleCancelAutonomousDrivingTarget().Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end

				if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.AUTO_DRIVE then
					return
				end

				self:RefreshAutoDriveInteractable()
			end
		end
	end

	self.RefreshAutoDriveInteractable(self)
end

M.OnAnyBtnTrigger = function(self)
	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.AUTO_DRIVE then
		return
	end

	if Time.frameCount < self.immersiveModeIgnoreFrame then
		return
	end

	if self.immersiveMode then
		self.TryStopImmersiveMode(self)
	else
		self.immersiveCheckTime = 3
	end
end

M.OnVehicleAutoDriveStateChange = function(self, eventId, vehicleEntityId, isStart)
	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.AUTO_DRIVE then
		return
	end

	if self.vehicleId ~= vehicleEntityId then
		self.SetAutoDriving(self, isStart)

		if not isStart then
			self.TryStopImmersiveMode(self)
		end
	end
end

M.OnTrafficLightStateChange = function(self)
	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.AUTO_DRIVE then
		return
	end

	self.RefreshTrafficLightState(self)
end

M.OnVehicleResetChangeBySpoon = function(self, eventId, spoonHide)
	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.RESET then
		return
	end

	self.spoonHideReset = spoonHide

	self.RefreshResetBtnState(self)
	print_notice("[Reset]DriveControlDriverStore OnSpoonHideReset", spoonHide)
end

M.OnResetStateChange = function(self, eventId, data)
	if not self.STATE_EnableOnce or not self.vehicleReady or not self.BTN_VALID.RESET then
		return
	end

	self.resetValid = data

	print_notice("[Reset]DriveControlDriverStore OnResetStateChange", data)
	self.RefreshResetBtnState(self)
end

M.InitButtonValidCheck = function(self)
	local notHackInterior = self.curTab == gHUDBaseVehicleType.HACK_INTERIOR

	self:InitAutoDriveValidCheck()

	self.BTN_VALID.RESET = self.isMainDrive and self.curTab > 0 and self.curTab == gHUDBaseVehicleType.HELICOPTER and notHackInterior
	self.BTN_VALID.OUT_OF_VEHICLE = notHackInterior
	self.BTN_VALID.SWITCH_SEAT = notHackInterior
	self.BTN_VALID.HACK = notHackInterior
	self.bindData.resetValidCtrl = self.BTN_VALID.RESET and self.CONTROL.TRUE or self.CONTROL.FALSE

	self:SetBtnActive(self.bindData.hackBtn, notHackInterior)

	if not self.BTN_VALID.OUT_OF_VEHICLE then
		self.SetBtnActive(self, self.bindData.outOfVehicleBtn, false)
	end

	if not self.BTN_VALID.SWITCH_SEAT then
		self.SetBtnActive(self, self.bindData.switchSeatBtn, false)
	end
end

M.InitAutoDriveValidCheck = function(self)
	self.BTN_VALID.AUTO_DRIVE = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.DriveControlsAutopilot) and (self.isMainDrive and self.curTab ~= gHUDBaseVehicleType.DRIVE or self.curTab ~= gHUDBaseVehicleType.HACK_INTERIOR)

	if not self.BTN_VALID.AUTO_DRIVE then
		self:SetAutoDriving(false)
		self:SetImmersiveModeEnable(false)
		self:SetBtnActive(self.bindData.autoDriveBtn, false)
		gStoreManager:UnregisterDynamicOnUpdate(self)
	else
		gStoreManager:RegisterDynamicOnUpdate(self)
	end
end

M.RefreshSeatInfo = function(self)
	if not self.vehicleId or not gLinkManager:CheckInLinkMode() then
		return false
	end

	table.clear(self.seats)

	local seatInfos = gCS.LuaUtils.GetVehicleSeatInfo(self.vehicleCs)
	local totalNum = seatInfos.Length
	local occupyNum = 0

	for i = 0, seatInfos.Length - 1 do
		table.insert(self.seats, seatInfos[i])

		if seatInfos[i].state == VehicleSeatState.Empty then
			occupyNum = occupyNum + 1
		end
	end

	if occupyNum ~= totalNum then
		return true
	end

	self.bindData.seatList:SetSimpleList(#self.seats)

	return false
end

M.OnRenderSeatListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local data = self.seats[index + 1]

	if store and data then
		store.isDriverCtrl = index ~= 0 and self.CONTROL.TRUE or self.CONTROL.FALSE
		local occupy = self.OCCUPY.EMPTY
		local playerNumber = ""

		if data.state ~= VehicleSeatState.OccupiedByPlayer then
			occupy = self.OCCUPY.PLAYER
			local pid = data.person.unitPid
			local number = gLinkManager:GetLinkIndex(pid)

			if number then
				playerNumber = string.format("%dP", number) or playerNumber
			end
		elseif data.state ~= VehicleSeatState.OccupiedByOtherPlayer then
			occupy = self.OCCUPY.OTHER_PLAYER
			local pid = data.person.unitPid
			local number = gLinkManager:GetLinkIndex(pid)

			if number then
				playerNumber = string.format("%dP", number) or playerNumber
			end
		elseif data.state == VehicleSeatState.Empty then
			occupy = self.OCCUPY.NPC
		end

		store.occupiedCtrl = occupy
		store.playerNumber = playerNumber
	end
end

M.RefreshSwitchSeatBtnState = function(self)
	if gLinkManager:CheckInLinkMode() then
		local isFull = self:RefreshSeatInfo()

		self:SetBtnActive(self.bindData.switchSeatBtn, not self.raceMode and not isFull)
	else
		self.SetBtnActive(self, self.bindData.switchSeatBtn, false)
	end
end

M.RefreshResetBtnState = function(self)
	self:SetBtnVisible(self.resetBtnStore, self.isMobile and (self.resetValid or self.raceMode))
	self:SetBtnActive(self.bindData.resetBtn, not self.spoonHideReset and (self.resetValid or self.raceMode))
	self:SetBtnActive(self.bindData.resetTip, not self.spoonHideReset and self.resetValid and not self.raceMode)
end

M.RefreshAutoDriveBtnState = function(self)
	local active = not self.isChallenging and not self.isAutoDrivingBlocked

	self:SetBtnVisible(self.autoDriveBtnStore, active)
	self:SetBtnActive(self.bindData.autoDriveBtn, active)
end

M.RefreshPlayerAutonomousDrivingState = function(self)
	self.isInOverrideMode, self.isAutoDrivingBlocked, self.isImmersiveModeBlocked = gDriveVehiclesManager:GetPlayerAutonomousDrivingState()

	self:RefreshAutoDriveInteractable()
	self:RefreshAutoDriveBtnState()

	if self.isImmersiveModeBlocked then
		self.SetImmersiveModeEnable(self, false)
	end
end

M.RefreshAutoDriveInteractable = function(self)
	local interactable = self.GetAutoDriveInteractable(self)

	self.SetBtnInteractable(self, self.autoDriveBtnStore, interactable)
end

M.GetAutoDriveInteractable = function(self)
	local interactable = true
	interactable = (not self.isInOverrideMode or not self.isAutoDrivingBlocked) and not self.isAutoDrivingBlocked and (self.AutoDrive.IsAutoDriving or self.AutoDrive.TargetEnable)

	return interactable
end

M.SetAutoDriving = function(self, driving)
	self.AutoDrive.IsAutoDriving = driving
	self.AutoDrive.AskWait = false
	self.bindData.autoDrivingCtrl = driving and self.CONTROL.TRUE or self.CONTROL.FALSE

	self.bindData.autoDriveBtn:SetSelected(driving)
	self.bindData.autoDriveBtn:SetTipNameTotally(driving and 576 or 575)

	if self.curVehicleStore and self.curVehicleStore.OnAutoDriveStateChange then
		self.curVehicleStore:OnAutoDriveStateChange(driving)
	end
end

M.UpdateImmersiveMode = function(self)
	if not self.isImmersiveModeBlocked and not self.immersiveMode and self.immersiveCheckTime <= 0 and gPanelManager:VisibleModeHUD() then
		self.immersiveCheckTime = self.immersiveCheckTime - gLogicTime.deltaTime

		if self.immersiveCheckTime < 0 then
			self.SetImmersiveModeEnable(self, true)
		end
	end
end

M.TryStopImmersiveMode = function(self)
	if self.immersiveMode then
		self.SetImmersiveModeEnable(self, false)

		self.immersiveCheckTime = 3
	end
end

M.SetImmersiveModeEnable = function(self, enable)
	self.immersiveMode = enable

	if enable then
		self.immersiveModeIgnoreFrame = Time.frameCount + 2

		gPanelManager:CheckShowSync(gPanelId.DRIVE_IMMERSIVE_PANEL)
	else
		gPanelManager:Close(gPanelId.DRIVE_IMMERSIVE_PANEL)
	end
end

M.RefreshTrafficLightState = function(self)
	local waitRed = false
	local vehicle = self.vehicleCs

	if vehicle then
		local type = vehicle.TrafficLightState
		waitRed = type ~= EVehicleTrafficLightState.Red
	end

	self.bindData.autoDrivingStateCtrl = waitRed and self.CONTROL.True or self.CONTROL.False
end

M.RefreshViewBtnState = function(self)
	local unlock = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BaseVehicleControllerView)

	self:SetBtnActive(self.bindData.viewBtn, unlock)
end

M.RefreshOutOfVehicleBtnState = function(self)
	self.bindData.outOfVehicleBtn:SetShowTipTotally(not self.phoneOpen)
	self:SetBtnVisible(self.outOfVehicleBtnStore, not self.phoneOpen and self.isMobile)

	local vehicle = self.vehicleCs

	if vehicle then
		self.SetBtnActive(self, self.bindData.outOfVehicleBtn, not vehicle.IsSeatLockLeave(vehicle, gDriveVehiclesManager.cs_manager.CurDriveSeatIndex))
	end
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnInteractable = function(self, btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

M.SetBtnActive = function(self, btn, active)
	btn.SetActive(btn, active)
end
