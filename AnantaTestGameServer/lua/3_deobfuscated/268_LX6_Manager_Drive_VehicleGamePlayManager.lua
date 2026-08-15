C_VehicleGamePlayManager = DefClass("C_VehicleGamePlayManager", C_VehicleGamePlayManager)
local M = C_VehicleGamePlayManager
local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
local DriveUtils = LX6.Drive.DriveUtils

function M:ctor()
	self.cs_manager = LX6.Drive.GamePlay.VehicleGamePlayManager.Instance
	self.isSummonMilkCar = false
end

function M:ChaseVehicle_OnClose(vehicleId, amount)
	gGpsBindingMgr:SetVehicleDetection(vehicleId, amount)
end

function M:ChaseVehicle_OnFar(timer)
	if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end

	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_COUNT_DOWN, {
		Param = {
			id = 0,
			isIncrease = false,
			time = timer,
			warningTime = timer
		}
	})

	if gPanelManager:IsPanelShowing(gPanelId.S_HUD_TIPS) then
		gPanelManager:Close(gPanelId.S_HUD_TIPS)
	end

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, {
		Param = {
			isEscapeCatch = true,
			isEscapeFinish = false,
			isEscapeInSight = false,
			TipType = TaskTipsType.EscapeCar,
			EscapeCarCatchName = LTConfig.TextScriptTextConfig.GetConfig(89900974).Text
		}
	})
end

function M:ChaseVehicle_CloseTaskTipPanel()
	if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end
end

function M:ChaseVehicle_SetGpsToNormal(vehicleId)
	gGpsBindingMgr:SetVehicleDetection(vehicleId, nil)
end

function M:ChaseVehicle_CloseAllTipPanel()
	if gPanelManager:IsPanelShowing(gPanelId.S_HUD_TIPS) then
		gPanelManager:Close(gPanelId.S_HUD_TIPS)
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end
end

function M:OnMilkVehicleArrive()
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnMilkCarStop)
end

function M:OnPoliceCarApprehend(data, countDownTime, textId, showTimeText, enableBlink, showProgressBar)
	local open = data

	if open then
		if countDownTime == nil then
			countDownTime = 10
		end

		print_debug("警车抓捕倒计时面板打开!!!", countDownTime)
		gPanelManager:CheckShow(gPanelId.VEHICLE_COUNTDOWN, {
			isCountDown = true,
			isRed = true,
			countDownSecondNum = countDownTime,
			textId = textId,
			showTimeText = showTimeText,
			enableBlink = enableBlink,
			showProgressBar = showProgressBar
		})
	else
		print_debug("警车抓捕倒计时面板关闭!!!")
		gPanelManager:Close(gPanelId.VEHICLE_COUNTDOWN)
	end
end

function M:OnPoliceCarEscape(data, countDownTime, textId, showTimeText, enableBlink, showProgressBar)
	local open = data

	if open then
		if countDownTime == nil then
			countDownTime = 10
		end

		print_debug("玩家逃脱倒计时面板打开!!!", countDownTime)
		gPanelManager:CheckShow(gPanelId.VEHICLE_COUNTDOWN, {
			isCountDown = true,
			isRed = false,
			countDownSecondNum = countDownTime,
			textId = textId,
			showTimeText = showTimeText,
			enableBlink = enableBlink,
			showProgressBar = showProgressBar
		})
	else
		print_debug("玩家逃脱倒计时面板关闭!!!")
		gPanelManager:Close(gPanelId.VEHICLE_COUNTDOWN)
	end
end

M.EscapeCarState = {
	Finish = 0,
	InSight = 2,
	Fail = 3,
	Catch = 1
}

function M:ShowEscapeCarTipPanel(data)
	if data == self.EscapeCarState.Fail then
		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_HUD_TIPS) then
		gPanelManager:Close(gPanelId.S_HUD_TIPS)
	end

	local id = data

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, {
		Param = {
			TipType = TaskTipsType.EscapeCar,
			isEscapeFinish = id == self.EscapeCarState.Finish,
			isEscapeCatch = id == self.EscapeCarState.Catch,
			isEscapeInSight = id == self.EscapeCarState.InSight,
			EscapeCarCatchName = LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.EscapeCarCatchTip).Text
		}
	})
end

function M:AddPoliceVehicleGPS(vehicleId)
	local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

	if vehicle == nil then
		return
	end

	gMapSubSystem_Vehicle:AddPoliceCar(vehicleId, gRaidDataManager.RaidId)
end

function M:RemovePoliceVehicleGPS(vehicleId)
	gMapSubSystem_Vehicle:RemovePoliceCar(vehicleId)
end

gVehicleGamePlayManager = gVehicleGamePlayManager or C_VehicleGamePlayManager.new()
