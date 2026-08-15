local TaxiConfig = LTConfig.TaxiNavigationConfig
local EffectConfig = LTConfig.EffectConfig
local formula_cs = require("LuaGen/AutoGen/Formula_cs")
local OrderStatus = {
	InProgress = 2,
	Waiting = 1,
	Skipping = 4,
	Finished = 3,
	None = 0
}
local DestinationStatus = {
	SuccessfullySelect = 2,
	TrySelect = 1,
	None = 0
}
local AetherVehicleStopReason = {
	EnteringVehicle = 4,
	ReachingVehicle = 2,
	BehaviorSet = 32,
	Block = 16,
	Set = 1,
	TaxiInteract = 64,
	BorrowAnim = 128,
	Paoku = 8
}
local M = {
	TaxiVehicleUid = -1,
	Accelerating = false,
	CurrentTaxiDistance = 0,
	ReachDestination = false,
	AccelerateCount = 0,
	LastSpeed = 0,
	ShowMap = false,
	ReachDestinationTimer = -1,
	CurrentTaxiCost = 0,
	PlayedAccelerateEffect = false,
	LastAccelerateTime = -1,
	OrderStatus = OrderStatus.None,
	DestinationStatus = DestinationStatus.None,
	LastPosition = Vector3.New(0, 0, 0)
}
local this = M

function M:UpdateTaxiDistance()
	if this.TaxiVehicle == nil then
		return
	end

	local currentPosition = this.TaxiVehicle.transform.position
	this.CurrentTaxiDistance = this.CurrentTaxiDistance + Vector3.Distance(currentPosition, this.LastPosition)
	this.LastPosition = currentPosition
end

function M:UpdateTaxiCost()
	this.CurrentTaxiCost = formula_cs:GetTaxiNormalCost(this.CurrentTaxiDistance)
end

function M:OnBeforeSwitchScene(switchType)
	this:ResetData()
end

function M:ResetData()
	gMessageManager:SendMessage(gEventConstants.TAXI_END)

	gDriveVehiclesManager.isTaxiMode = false

	this:SetJoyStickEnable(true)

	this.CurrentDestinationUid = nil
	this.Accelerating = false
	this.AccelerateCount = 0
	this.LastAccelerateTime = -1
	this.TaxiVehicle = nil
	this.TaxiVehicleUid = -1
	this.OrderStatus = OrderStatus.None
	this.DestinationStatus = DestinationStatus.None
	this.ShowMap = false
	this.PlayedAccelerateEffect = false
	this.LastSpeed = 0
	this.CurrentTaxiCost = 0
	this.CurrentTaxiDistance = 0
end

function M:PlayAccelerateEffect()
	local myPlayerUnitId = gCS.MyPlayerManager.PlayerUnitId

	gCS.EffectMgr:PlaySetAlphaEffect(myPlayerUnitId, EffectConfig.SwingCameraEffect, 1, 1)

	this.PlayedAccelerateEffect = true
end

function M:ShowTaxiMap()
	if this.ShowMap then
		return
	end

	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, this.OnCloseTaxiMap)

	this.ShowMap = true

	gMapUtils:CheckRaidCanOpenMap({
		taxiMode = true
	})
end

function M.OnCloseTaxiMap(eventId, panelId)
	if panelId ~= gPanelId.S_NEW_MAP_PANEL then
		return
	end

	if this.DestinationStatus == DestinationStatus.None and this.OrderStatus == OrderStatus.Waiting then
		gDialogManager:ShowGeneralDialog(TaxiConfig.TaxiTakingDialogue, gDialogSource.Taxi, nil, nil, function (dialogId, branchId, state)
			this:OnDialogEnd(dialogId, branchId, state)
		end)
	end

	gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_CLOSE, this.OnCloseTaxiMap)

	this.ShowMap = false
end

function M:ForceLeaveTaxi()
	gDriveVehiclesManager:OnEnterExitKeyDown()
end

function M:OnSetDestination(err, destInfo)
	if err ~= 0 then
		print_error("Ask Start Taxi Navigate Error: ", err)

		if this.OrderStatus == OrderStatus.Waiting then
			gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
			gDialogManager:ShowGeneralDialog(TaxiConfig.TaxiTakingDialogue, gDialogSource.Taxi, nil, nil, function (dialogId, branchId, state)
				this:OnDialogEnd(dialogId, branchId, state)
			end)
		end
	else
		this.CurrentDestinationUid = destInfo.id
		this.TaxiVehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle
		this.LastPosition = this.TaxiVehicle.transform.position
		this.DestinationStatus = DestinationStatus.SuccessfullySelect

		if this.OrderStatus == OrderStatus.Waiting then
			gDialogManager:ShowGeneralDialog(TaxiConfig.TaxiStartDialogue, gDialogSource.Taxi)
			this:OnFirstSetDestination()
			AetherAI.Systems.City.Instance:ResumeVehicleMove(this.TaxiVehicleUid, AetherVehicleStopReason.TaxiInteract)
		else
			gDialogManager:ShowGeneralDialog(TaxiConfig.TaxiNavChangeDialog, gDialogSource.Taxi)
		end
	end
end

function M:OnFirstSetDestination()
	gMessageManager:SendMessage(gEventConstants.TAXI_START)

	this.Accelerating = false
	this.AccelerateCount = 0
	this.LastAccelerateTime = -1
	this.PlayedAccelerateEffect = false
	this.OrderStatus = OrderStatus.InProgress

	AetherAI.Systems.City.Instance:SetAetherVehicleControl(this.TaxiVehicle.uId, true)
end

function M:FinishTakingTaxi(skipped)
	gClientToGameSceneDelegate:AskEndTaxiNavigate(false, skipped, this.CurrentTaxiDistance).Callback = function (err)
		if err ~= 0 then
			print_error("Ask End Taxi Navigate Error: ", err)
		end
	end

	this:ClearRunningData()
end

function M:ClearRunningData()
	this.CurrentDestinationUid = nil
	this.Accelerating = false
	this.AccelerateCount = 0
	this.LastAccelerateTime = -1
	this.PlayedAccelerateEffect = false
	this.TaxiVehicle = nil
	this.CurrentTaxiDistance = 0

	this:UpdateTaxiCost()

	this.OrderStatus = OrderStatus.None
	this.DestinationStatus = DestinationStatus.None
end

function M:Accelerate()
	if gLogicTime.time - this.LastAccelerateTime < TaxiConfig.TaxiFasterCD then
		return
	end

	this.LastAccelerateTime = gLogicTime.time
	this.Accelerating = true
	this.AccelerateCount = this.AccelerateCount + 1
	this.PlayedAccelerateEffect = false
	local dialogList = TaxiConfig.TaxiFasterDialogue

	for i = 1, #dialogList do
		if dialogList[i].count == this.AccelerateCount then
			gDialogManager:ShowGeneralDialog(dialogList[i].dialogID, gDialogSource.Taxi)

			return
		end
	end
end

function M.OnTaxiSkipFinish()
	gMessageManager:RemoveMessageListener(gEventConstants.ON_END_PORTAL, this.OnTaxiSkipFinish)
	this:ForceLeaveTaxi()

	gClientToGameSceneDelegate:AskEndTaxiTeleport().Callback = function (err)
		if err ~= 0 then
			print_error("Ask End Taxi Teleport Error: ", err)
		end
	end
end

function M.OnBeginPortal()
	this.isTeleporting = true

	gMessageManager:RemoveMessageListener(gEventConstants.ON_BEGIN_PORTAL, this.OnBeginPortal)
end

function M.OnEndPortal()
	this.isTeleporting = false

	gMessageManager:RemoveMessageListener(gEventConstants.ON_END_PORTAL, this.OnEndPortal)
end

function M:Skip()
	this.OrderStatus = OrderStatus.Skipping
	this.Accelerating = false
	this.AccelerateCount = 0
	this.LastAccelerateTime = -1

	gMessageManager:AddMessageListener(gEventConstants.ON_BEGIN_PORTAL, this.OnBeginPortal)
	gMessageManager:AddMessageListener(gEventConstants.ON_END_PORTAL, this.OnEndPortal)

	gClientToGameSceneDelegate:AskEndTaxiNavigate(true, false, this.CurrentTaxiDistance).Callback = function (err)
		if err ~= 0 then
			print_error("Ask End Taxi Navigate Error: ", err)
		elseif this.isTeleporting then
			gMessageManager:AddMessageListener(gEventConstants.ON_END_PORTAL, this.OnTaxiSkipFinish)
		else
			this.OnTaxiSkipFinish()
		end
	end
end

function M:ChangeDestination()
	if this.ShowMap or this.OrderStatus ~= OrderStatus.InProgress then
		return
	end

	this:ShowTaxiMap()
end

function M:ChooseDestination(destInfo)
	if this.DestinationStatus == DestinationStatus.TrySelect then
		return
	end

	this.DestinationStatus = DestinationStatus.TrySelect

	gClientToGameSceneDelegate:AskStartTaxiNavigate(destInfo.id).Callback = function (err)
		this:OnSetDestination(err, destInfo)
	end
end

function M:OnEnterTaxiStart(vehicleId)
	this.TaxiVehicleUid = vehicleId
	gDriveVehiclesManager.isTaxiMode = true

	this:SetJoyStickEnable(false)
	AetherAI.Systems.City.Instance:StopVehicleMove(vehicleId, AetherVehicleStopReason.TaxiInteract, -1)
end

function M:OnEnterTaxiCancel(vehicleId)
	this.TaxiVehicleUid = -1
	gDriveVehiclesManager.isTaxiMode = false

	this:SetJoyStickEnable(true)
	AetherAI.Systems.City.Instance:ResumeVehicleMove(vehicleId, AetherVehicleStopReason.TaxiInteract)
end

function M:OnEnterTaxiFinish()
	gDialogManager:ShowGeneralDialog(TaxiConfig.TaxiTakingDialogue, gDialogSource.Taxi, nil, nil, function (dialogId, branchId, state)
		this:OnDialogEnd(dialogId, branchId, state)
	end)
end

function M:OnDialogEnd(dialogId, branchId, state)
	if dialogId == TaxiConfig.TaxiTakingDialogue and state == 0 then
		if branchId == 1 then
			this:ShowTaxiMap()

			this.OrderStatus = OrderStatus.Waiting

			gLuaClient:RegisterDynamicUpdate("TaxiManager", this)
		else
			this:ForceLeaveTaxi()
		end
	end
end

function M:OnExitTaxiStart(vehicleUid)
	local shouldDelay = this.OrderStatus == OrderStatus.InProgress and this.TaxiVehicle ~= nil and this.TaxiVehicle.baseVehicle.Speed > 1

	if this.TaxiVehicleUid ~= vehicleUid then
		return
	end

	if this.OrderStatus ~= OrderStatus.None and this.OrderStatus ~= OrderStatus.Skipping and this.OrderStatus ~= OrderStatus.Waiting then
		this.OrderStatus = OrderStatus.Finished
	end

	gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
	gPanelManager:Close(gPanelId.S_RADIO_PLAYER_PANEL)
	gMessageManager:SendMessage(gEventConstants.TAXI_END)
	AetherAI.Systems.City.Instance:StopVehicleMove(vehicleUid, AetherVehicleStopReason.TaxiInteract, -1)
	Timer.New(function ()
		return
	end, shouldDelay and 1 or 0):Start()
end

function M:OnExitTaxiStartNew(vehicleUid)
	if this.TaxiVehicleUid ~= vehicleUid then
		return
	end

	if this.OrderStatus ~= OrderStatus.None and this.OrderStatus ~= OrderStatus.Skipping and this.OrderStatus ~= OrderStatus.Waiting then
		this.OrderStatus = OrderStatus.Finished
	end

	gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
	gPanelManager:Close(gPanelId.S_RADIO_PLAYER_PANEL)
	gMessageManager:SendMessage(gEventConstants.TAXI_END)
end

function M:OnExitTaxiFinish(vehicleUid)
	if this.TaxiVehicleUid ~= vehicleUid then
		return
	end

	gLuaClient:UnregisterDynamicUpdate("TaxiManager")

	this.TaxiVehicleUid = -1
	this.TaxiVehicle = nil
	this.CurrentDestinationUid = nil

	if this.OrderStatus ~= OrderStatus.None and this.OrderStatus ~= OrderStatus.Waiting then
		gDialogManager:ShowGeneralDialog(TaxiConfig.TaxiNavEndDialog, gDialogSource.Taxi)

		if this.OrderStatus ~= OrderStatus.Skipping then
			this:FinishTakingTaxi(false)
		else
			this:FinishTakingTaxi(true)
		end
	end

	this:ClearRunningData()

	this.OrderStatus = OrderStatus.None
	gDriveVehiclesManager.isTaxiMode = false

	this:SetJoyStickEnable(true)
	AetherAI.Systems.City.Instance:ResumeVehicleMove(vehicleUid, AetherVehicleStopReason.TaxiInteract)
end

function M:OnUpdate()
	if this.OrderStatus == OrderStatus.None then
		gLuaClient:UnregisterDynamicUpdate("TaxiManager")

		return
	end

	if this.OrderStatus ~= OrderStatus.InProgress then
		return
	end

	this:UpdateTaxiDistance()
	this:UpdateTaxiCost()

	local dt = gLogicTime.deltaTime

	if this.ReachDestination and this.ReachDestinationTimer < 3 then
		this.ReachDestinationTimer = this.ReachDestinationTimer + dt

		if this.ReachDestinationTimer >= 3 then
			this:ForceLeaveTaxi()

			this.ReachDestination = false
		end
	end

	if this.PlayedAccelerateEffect or not this.Accelerating then
		return
	end

	if dt == 0 then
		return
	end

	local currentSpeed = this.TaxiVehicle.baseVehicle.Speed
	local a = (currentSpeed - this.LastSpeed) / dt

	if TaxiConfig.TaxiFasterFxPlaySpeed <= a then
		this:PlayAccelerateEffect()
	end
end

function M:SetJoyStickEnable(enable)
	if JoystickMgr.Instance.isSGUI then
		if gLuaDataManager.guiMgr.sguiJoystick ~= nil then
			gLuaDataManager.guiMgr.sguiJoystick.gameObject:SetActive(enable)
		end
	elseif gLuaDataManager.guiMgr.nguiJoystick ~= nil then
		gLuaDataManager.guiMgr.nguiJoystick.gameObject:SetActive(enable)
	end
end

gTaxiManager = M
