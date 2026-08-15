if not gPoliceJobManager or not gPoliceJobManager.searchCarMgr then
	local PoliceSearchCarManager = {
		isInEnterOrSearchCarAnim = false,
		actionMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceGameplayActions"),
		exitSearchCarStateCallbacks = {}
	}
end

local this = PoliceSearchCarManager
local DriveUtils = LX6.Drive.DriveUtils
local PoliceJobUtils = L18.Gameplay.PoliceJobUtils
PoliceSearchCarManager.SearchVehicleType = {
	BeginR = 3,
	BeginL = 1,
	End = 2
}

function PoliceSearchCarManager:EnterSearchCarState(vehicleId)
	local vehicleControl = LX6.Drive.DriveUtils.GetVehicleInScene(vehicleId)

	if vehicleControl == nil then
		print_error("@liulijun04 EnterSearchCarState: 没找到车辆的实例!")

		return
	end

	self.vehicleControl = vehicleControl
	self.interactVehicleId = self.vehicleControl.uId
	self.isSearchCarState = true
end

function PoliceSearchCarManager:AddExitSearchCarStateCallback(cb)
	table.insert(self.exitSearchCarStateCallbacks, cb)
end

function PoliceSearchCarManager:ExitSearchCarState()
	self:OnExitSearchCarState()
	self:ClearSearchCarState()
end

function PoliceSearchCarManager:IsSearchCarState()
	return self.isSearchCarState
end

function PoliceSearchCarManager:CheckIsSearchCar(interactMenuState, vehicleId, seatIndex)
	if not self.isSearchCarState or vehicleId ~= self.interactVehicleId then
		return false
	end

	if seatIndex ~= 2 and seatIndex ~= 3 then
		return false
	end

	if interactMenuState < gVehicleInteractManager.InteractMenuState.Disable then
		local isGray = interactMenuState == gVehicleInteractManager.InteractMenuState.Gray
		self.interactVehicleSeatIndex = seatIndex
		local targetTrans = nil
		local vehicle = DriveUtils.GetVehicleInScene(vehicleId)

		if vehicle ~= nil and vehicle.seats ~= nil then
			targetTrans = vehicle.seats:GetInteractPoint(seatIndex)
		end

		local info = LX6.Interact.BaseBtnInfo.New(vehicleId, 3, targetTrans, 0, self.OnInteractMenuClick, nil, LTConfig.TextScriptTextConfig.SearchCar)
		info.isGray = isGray

		L50.L50App.L50Game.InteractBtnMgr:AddBtn(info)
	elseif interactMenuState == gVehicleInteractManager.InteractMenuState.Disable then
		L50.L50App.L50Game.InteractBtnMgr:RemoveBtnByType(self.interactVehicleId, 3)

		self.interactVehicleSeatIndex = 0
	end
end

function PoliceSearchCarManager:CheckPlayOpenOrCloseDoorAnim(cfg, isOpen)
	if self.isInEnterOrSearchCarAnim and self.interactionData then
		-- Nothing
	end
end

function PoliceSearchCarManager.OnInteractMenuClick()
	local self = this

	if self.interactVehicleId == nil or self.interactVehicleSeatIndex == nil then
		return
	end

	self:OnSearchCarInteractClick(self.interactVehicleSeatIndex)
end

function PoliceSearchCarManager:OnSearchCarInteractClick(seatIndex)
	self.isInEnterOrSearchCarAnim = true

	if seatIndex == 2 then
		gCS.TransitionMgr.policeSearchVehicleType = self.SearchVehicleType.BeginL
	else
		gCS.TransitionMgr.policeSearchVehicleType = self.SearchVehicleType.BeginR
	end

	local checkSwitchActionFail = false
	local interactionData = PoliceJobUtils.CreateVehicleInteractData(self.interactVehicleId, seatIndex, true)
	self.interactionData = interactionData

	local function StartActionCb()
		gCS.LuaUtils.CheckSwitchAction(true, true, false, 0)

		gCS.TransitionMgr.policeSearchVehicleType = 0
	end

	local function OnFinished(isSuccess)
		if not isSuccess and not checkSwitchActionFail then
			print_error_without_stack("#NoCreateIssue EnterVehicleTrans do CCTransition failed", gCS.MyPlayerManager.PlayerUnit.State.nowInteractiveAction, gCS.MyPlayerManager.PlayerUnit.State.ActionGroupId)
			self:ClearSearchCarInteractionState()
		end
	end

	PoliceJobUtils.SetCCTransitionTargetForCurrentPlayer(interactionData, StartActionCb, OnFinished)

	checkSwitchActionFail = not gCS.LuaUtils.CheckSwitchAction(true, true, false, 0)

	gCS.CCTransitionManager.ResetNextMoveTarget()
	self:HidePhone(true)

	if checkSwitchActionFail then
		print_error_without_stack("#NoCreateIssue EnterVehicleTrans CheckSwitchAction return false", gCS.MyPlayerManager.PlayerUnit.State.nowInteractiveAction, gCS.MyPlayerManager.PlayerUnit.State.ActionGroupId)
		self:ClearSearchCarInteractionState()
	end
end

function PoliceSearchCarManager.CloseCallback()
	local self = this
	gCS.TransitionMgr.policeSearchVehicleType = self.SearchVehicleType.End

	gCS.LuaUtils.CheckSwitchAction(true, true, false, 0)

	gCS.TransitionMgr.policeSearchVehicleType = 0

	self:ExitSearchCarState()
end

function PoliceSearchCarManager.SignalAction_SearchCarResult()
	local self = PoliceSearchCarManager
	local data = {
		closeCallback = self.CloseCallback
	}

	gPanelManager:CheckShow(gPanelId.POLICE_SEARCH_PANEL, data)
end

function PoliceSearchCarManager:ClearSearchCarState()
	self:ClearSearchCarInteractionState()

	self.isSearchCarState = false
	self.interactVehicleId = nil
	self.vehicleControl = nil
end

function PoliceSearchCarManager:ClearSearchCarInteractionState()
	self:HidePhone(false)

	self.isInEnterOrSearchCarAnim = false
	self.interactionData = nil
end

function PoliceSearchCarManager:OnExitSearchCarState()
	for _, cb in ipairs(self.exitSearchCarStateCallbacks) do
		cb()
	end

	self.exitSearchCarStateCallbacks = {}
end

function PoliceSearchCarManager:HidePhone(isHide)
	local store = gStoreManager:GetStoreGroup("PhoneAppHomePanelStore")
	local phone = store and store.rootWidget

	if gClientUtils.NotNil(phone) then
		phone:SetActive(not isHide)
	end
end

this.actionMgr.SignalTypeToAction[this.actionMgr.VMSignalType.SearchCarResult] = this.SignalAction_SearchCarResult

return PoliceSearchCarManager
