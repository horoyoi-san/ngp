-- Original chunk: @Lua\LuaFiles\LX6\Manager\Drive\VehicleGamePlayManager.lua
-- Decompiled from: 00686_VehicleGamePlayManager.lua_2cfac24e9d98.luajit

local bit = require("bit")
local DriveManager = gCS.DriveManager
local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
C_VehicleGamePlayManager = DefClass("C_VehicleGamePlayManager", C_VehicleGamePlayManager)
local M = C_VehicleGamePlayManager
local DriveUtils = LX6.Drive.DriveUtils

M.ctor = function(self)
	self.cs_manager = LX6.Drive.GamePlay.VehicleGamePlayManager.Instance
	self.isSummonMilkCar = false
end

M.OnInit = function(self)
	self.isCarRaceMode = false

	gMessageManager:AddMessageListener(gEventConstants.CAR_RACE_STATE_CHANGE, self:CreateAction("OnCarRaceStateChange"))

	self.hackVehicleId = nil
	self.hackVehicleViewId = 0

	gMessageManager:AddMessageListener(gEventConstants.ENTER_BASE_VEHICLE_INTERIOR, self:CreateAction("OnEnterBaseVehicleInterior"))
	gMessageManager:AddMessageListener(gEventConstants.EXIT_BASE_VEHICLE_INTERIOR, self:CreateAction("OnExitBaseVehicleInterior"))

	self.vehicleChaseInfos = {}
	self.vehicleChaseGroupCount = 0
	self.isVehicleChaseMode = false
	self.isVehicleChasePlayerHp = false

	gMessageManager:AddMessageListener(gEventConstants.VEHICLE_HP_CHANGE, self:CreateAction("OnChaseVehicleHpChange"))
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.KickToLogin < switchType then
		self.isCarRaceMode = false

		table.clear(self.vehicleChaseInfos)

		self.vehicleChaseGroupCount = 0
		self.isVehicleChaseMode = false
	end
end

M.ChaseVehicle_OnClose = function(self, vehicleId, amount)
	gGpsBindingMgr:SetVehicleDetection(vehicleId, amount)
end

M.ChaseVehicle_OnFar = function(self, timer)
	if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end

	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_COUNT_DOWN, {
		Param = {
			["\t\r"] = 0,
			["ZI糇\\xbd\\xda\\xed"] = false,
			time = timer,
			warningTime = timer
		}
	})

	if gPanelManager:IsPanelShowing(gPanelId.S_HUD_TIPS) then
		gPanelManager:Close(gPanelId.S_HUD_TIPS)
	end

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, {
		Param = {
			["\\xf0z?\t\\xd1\\xb3b\\xa0B\\xb3\\xbe"] = true,
			["\\xee\\x894\\xff\\xf6́\\xe3\\x8b3 "] = false,
			["*9\\xf7p\\x99\\xe71\\x81!\\xd5\\xfb\\xe1|\\xef"] = false,
			TipType = TaskTipsType.EscapeCar,
			EscapeCarCatchName = LTConfig.TextScriptTextConfig.GetConfig(89900974).Text
		}
	})
end

M.ChaseVehicle_CloseTaskTipPanel = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end
end

M.ChaseVehicle_SetGpsToNormal = function(self, vehicleId)
	gGpsBindingMgr:SetVehicleDetection(vehicleId, nil)
end

M.ChaseVehicle_CloseAllTipPanel = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.S_HUD_TIPS) then
		gPanelManager:Close(gPanelId.S_HUD_TIPS)
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end
end

M.OnMilkVehicleArrive = function(self)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnMilkCarStop)
end

M.OnPoliceCarApprehend = function(self, data, countDownTime, textId, showTimeText, enableBlink, showProgressBar)
	local open = data

	if open then
		if countDownTime ~= nil then
			countDownTime = 10
		end

		print_debug("警车抓捕倒计时面板打开!!!", countDownTime)

		local param = {
			["\\x96'0m\\x93U\\xfd8\\xbd\\xb7"] = true,
			["D\\xbd\\x90\\xaa\\xb2"] = true,
			countDownSecondNum = countDownTime,
			textId = textId,
			showTimeText = showTimeText,
			enableBlink = enableBlink,
			showProgressBar = showProgressBar
		}

		gMapSubSystem_Vehicle:TryShowVehicleCountdown(param)
	else
		print_debug("警车抓捕倒计时面板关闭!!!")
		gPanelManager:Close(gPanelId.VEHICLE_COUNTDOWN)
	end
end

M.OnPoliceCarEscape = function(self, data, countDownTime, textId, showTimeText, enableBlink, showProgressBar)
	local open = data

	if open then
		if countDownTime ~= nil then
			countDownTime = 10
		end

		print_debug("玩家逃脱倒计时面板打开!!!", countDownTime)

		local param = {
			["\\x96'0m\\x93U\\xfd8\\xbd\\xb7"] = true,
			["D\\xbd\\x90\\xaa\\xb2"] = false,
			countDownSecondNum = countDownTime,
			textId = textId,
			showTimeText = showTimeText,
			enableBlink = enableBlink,
			showProgressBar = showProgressBar
		}

		gMapSubSystem_Vehicle:TryShowVehicleCountdown(param)
	else
		print_debug("玩家逃脱倒计时面板关闭!!!")
		gPanelManager:Close(gPanelId.VEHICLE_COUNTDOWN)
	end
end

M.EscapeCarState = {
	[":A\\x9f\\x87\\x90I"] = 0,
	["\\xf0\\xd5',\\xe5"] = 2,
	["\\#tW"] = 3,
	["n\\xaf\\xb6\\xac\\xbe"] = 1
}

M.ShowEscapeCarTipPanel = function(self, data)
	if data ~= self.EscapeCarState.Fail then
		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_HUD_TIPS) then
		gPanelManager:Close(gPanelId.S_HUD_TIPS)
	end

	local id = data

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, {
		Param = {
			TipType = TaskTipsType.EscapeCar,
			isEscapeFinish = id ~= self.EscapeCarState.Finish,
			isEscapeCatch = id ~= self.EscapeCarState.Catch,
			isEscapeInSight = id ~= self.EscapeCarState.InSight,
			EscapeCarCatchName = LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.EscapeCarCatchTip).Text
		}
	})
end

M.AddPoliceVehicleGPS = function(self, vehicleId)
	local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

	if vehicle ~= nil then
		return
	end

	gMapSubSystem_Vehicle:AddPoliceCar(vehicleId, gRaidDataManager.RaidId)
end

M.RemovePoliceVehicleGPS = function(self, vehicleId)
	gMapSubSystem_Vehicle:RemovePoliceCar(vehicleId)
end

M.OnCarRaceStateChange = function(self, eventId, state)
	self.isCarRaceMode = state
end

M.IsCarRaceMode = function(self)
	return self.isCarRaceMode
end

M.OnEnterBaseVehicleInterior = function(self, eventId, vehicleId)
	local vehicleCs = DriveManager:GetBaseVehicle(vehicleId)
	local cfg = LTConfig.VehicleConfig.GetConfig(vehicleCs.cfgId)

	print_notice("OnEnterBaseVehicleInterior", vehicleId)

	if bit.band(cfg.VehicleFlag, LTConfig.VehicleConfig.VehicleFlagType.AutoDrive) ~= LTConfig.VehicleConfig.VehicleFlagType.AutoDrive then
		self.hackVehicleId = vehicleId
		self.hackVehicleViewId = 0

		gStoreManager:GetStoreGroup("BaseVehicleControllerStore"):OnEnterBaseVehicleInterior(eventId, vehicleId)
	end
end

M.OnExitBaseVehicleInterior = function(self, eventId, vehicleId)
	print_notice("OnExitBaseVehicleInterior", vehicleId)

	if self.hackVehicleId ~= vehicleId then
		gStoreManager:GetStoreGroup("BaseVehicleControllerStore"):OnExitBaseVehicleInterior(eventId, vehicleId)

		self.hackVehicleId = nil

		if self.hackVehicleViewId <= 0 then
			gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.NPDVehicle)
			L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gBanId.HACK_AUTO_DRIVE, false)
			LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, gBanId.HACK_AUTO_DRIVE)
		end
	end
end

M.HackAutoDriveSwitchView = function(self)
	self.hackVehicleViewId = self.hackVehicleViewId + 1

	if self.hackVehicleViewId ~= 4 then
		self.hackVehicleViewId = 0

		gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.NPDVehicle)
		L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gBanId.HACK_AUTO_DRIVE, false)
		LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, gBanId.HACK_AUTO_DRIVE)
	elseif self.hackVehicleViewId <= 0 then
		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.NPDVehicle)
		LX6.Cinemachine.NPDVehicleCameraState.SetArmLengthPreference(self.hackVehicleViewId, false)
		L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gBanId.HACK_AUTO_DRIVE, true)
		LX6.GUI.GuiMgr.Instance:SetDisableJoystick(true, gBanId.HACK_AUTO_DRIVE)
	end
end

M.OnSyncVehicleChaseStart = function(self, groupId, configId)
	local sendMsg = false

	if not self.vehicleChaseInfos[groupId] then
		self.vehicleChaseInfos[groupId] = {}
		self.vehicleChaseGroupCount = self.vehicleChaseGroupCount + 1

		if self.vehicleChaseGroupCount ~= 1 then
			self.isVehicleChaseMode = true
			sendMsg = true
		end
	end

	self.vehicleChaseInfos[groupId].configId = configId

	self:RefreshShowPlayerHp()

	if sendMsg then
		gMessageManager:SendMessage(gEventConstants.VEHICLE_CHASE_STATE_CHANGE)
	end

	gMessageManager:SendMessage(gEventConstants.VEHICLE_CHASE_INFO_CHANGE)
end

M.RefreshShowPlayerHp = function(self)
	local showHp = false

	for _, vehicleChaseInfo in pairs(self.vehicleChaseInfos) do
		local configId = vehicleChaseInfo.configId
		local chaseConfig = LTConfig.VehicleChaseConfig.GetConfig(configId)

		if chaseConfig then
			showHp = chaseConfig.ShowPlayerVehicleHP or showHp
		end
	end

	self.isVehicleChasePlayerHp = showHp
end

M.OnSyncVehicleChaseEnd = function(self, groupId, result)
	local sendMsg = false

	if self.vehicleChaseInfos[groupId] then
		self.vehicleChaseInfos[groupId] = nil
		self.vehicleChaseGroupCount = self.vehicleChaseGroupCount - 1

		if self.vehicleChaseGroupCount ~= 0 then
			self.isVehicleChaseMode = false
			sendMsg = true
		end
	end

	self:RefreshShowPlayerHp()

	if sendMsg then
		gMessageManager:SendMessage(gEventConstants.VEHICLE_CHASE_STATE_CHANGE)
	end

	gMessageManager:SendMessage(gEventConstants.VEHICLE_CHASE_INFO_CHANGE)
end

M.OnSyncVehicleChaseMode = function(self, groupId, vehicleUId, mode)
	local info = self.vehicleChaseInfos[groupId]

	if not info then
		return
	end

	if not info.vehicles then
		info.vehicles = {}
	end

	info.vehicles[vehicleUId] = mode

	if mode == UX.Game.VehicleChaseMode.None then
		local chaseConfigId = info.configId
		local chaseConfig = chaseConfigId and LTConfig.VehicleChaseConfig.GetConfig(chaseConfigId)
		local showAiVehicleHP = chaseConfig and chaseConfig.ShowAiVehicleHP

		if showAiVehicleHP then
			gDriveVehiclesManager:TryGetBaseVehicleWithCallback(vehicleUId, function ()
				gHudMgr:CreateVehicle(vehicleUId)
				gHudMgr:VehicleAddHp(vehicleUId)
			end)
		end
	end

	gMessageManager:SendMessage(gEventConstants.VEHICLE_CHASE_INFO_CHANGE)
end

M.OnChaseVehicleHpChange = function(self, eventId, vehicleUId, hpPercent)
	if hpPercent and hpPercent <= 0 then
		gHudMgr:VehicleHpChanged(vehicleUId, hpPercent)
	else
		gHudMgr:VehicleDead(vehicleUId)
	end
end

gVehicleGamePlayManager = gVehicleGamePlayManager or C_VehicleGamePlayManager.new()
