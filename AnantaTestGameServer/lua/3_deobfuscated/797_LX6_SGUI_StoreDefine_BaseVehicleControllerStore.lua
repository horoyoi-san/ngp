C_BaseVehicleControllerStore = DefClass("C_BaseVehicleControllerStore", C_BaseVehicleControllerStore, C_StoreGroup)
GroupName2Class.BaseVehicleControllerStore = C_BaseVehicleControllerStore
local M = C_BaseVehicleControllerStore
local DriveManager = gCS.DriveManager

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.curTab = -1
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ENTER_VEHICLE_FINISH] = self:CreateAction("OnEnterBaseVehicleFinish"),
		[gEventConstants.EXIT_VEHICLE_START] = self:CreateAction("OnExitBaseVehicleStart"),
		[gEventConstants.ENTER_BASE_VEHICLE_FINISH] = self:CreateAction("OnEnterBaseVehicleFinish"),
		[gEventConstants.EXIT_BASE_VEHICLE_START] = self:CreateAction("OnExitBaseVehicleStart")
	}
end

function M:OnEnterBaseVehicleFinish(eventId, vehicleId)
	self.vehicleId = vehicleId
	self.vehicleCs = DriveManager:GetBaseVehicle(self.vehicleId)

	gCoreHudModeMgr:PushHudMode("BaseVehicle_" .. self.vehicleId, gCoreHudModeMgr.HUD_MODE.BASEVEHICLE)

	if self.vehicleCs and self.vehicleCs.IsAutomobile then
		self:StartVehicleGameplayByType(gHUDBaseVehicleType.DRIVE)
	elseif self.vehicleCs and self.vehicleCs.IsMotorcycle then
		self:StartVehicleGameplayByType(gHUDBaseVehicleType.MOTOR)
	elseif self.vehicleCs and self.vehicleCs.IsHelicopter then
		self:StartVehicleGameplayByType(gHUDBaseVehicleType.HELICOPTER)
	elseif self.vehicleCs and self.vehicleCs.IsBoat then
		self:StartVehicleGameplayByType(gHUDBaseVehicleType.BOAT)
	end
end

function M:OnExitBaseVehicleStart(eventId, vehicleId)
	self.vehicleId = self.vehicleId or vehicleId

	gCoreHudModeMgr:PopHudMode("BaseVehicle_" .. self.vehicleId, true)

	if self.vehicleCs and self.vehicleCs.IsAutomobile then
		self:StopVehicleGameplayByType(gHUDBaseVehicleType.DRIVE)
	elseif self.vehicleCs and self.vehicleCs.IsMotorcycle then
		self:StopVehicleGameplayByType(gHUDBaseVehicleType.MOTOR)
	elseif self.vehicleCs and self.vehicleCs.IsHelicopter then
		self:StopVehicleGameplayByType(gHUDBaseVehicleType.HELICOPTER)
	elseif self.vehicleCs and self.vehicleCs.IsBoat then
		self:StopVehicleGameplayByType(gHUDBaseVehicleType.BOAT)
	end

	self.vehicleId = nil
	self.vehicleCs = nil
end

function M:StartVehicleGameplayByType(vehicleType)
	if vehicleType == nil then
		return
	end

	self.curTab = vehicleType
	self.bindData.tabRect.selectedIndex = vehicleType
end

function M:StopVehicleGameplayByType(vehicleType)
	if vehicleType == self.curTab then
		self:StopVehicleActiveGameplay()
	end
end

function M:StopVehicleActiveGameplay()
	self.curTab = -1

	if self.curVehicleStore then
		self.curVehicleStore:OnClose()
	end

	self.curVehicleStore = nil
	self.bindData.tabRect.selectedIndex = self.curTab

	if self.popupId then
		gNewPopupManager:RemovePopup(self.popupId)

		self.popupId = nil
	end
end

function M:RegisterWidget()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnTabRectRender")
end

function M:OnTabRectRender(index, widget)
	self.curVehicleStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curVehicleStore then
		local cfg = LTConfig.VehicleConfig.GetConfig(self.vehicleCs.cfgId)

		if cfg and gDriveVehiclesManager:CheckCanPopup(cfg) then
			self.popupId = gNewPopupManager:PushPopup(LTConfig.PopupConfig.BaseVehicleInfo, cfg)
		end

		self.curVehicleStore:OnShow(nil, {
			vehicleId = self.vehicleId,
			vehicleCs = self.vehicleCs
		})
	end
end
