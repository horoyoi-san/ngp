local bit = require("bit")
local DriveManager = gCS.DriveManager
C_CoreHudGameplayControlStore = DefClass("C_CoreHudGameplayControlStore", C_CoreHudGameplayControlStore, C_StoreGroup)
GroupName2Class.CoreHudGameplayControlStore = C_CoreHudGameplayControlStore
local M = C_CoreHudGameplayControlStore

function M:ctor()
	self.TypeIdMap = {
		Ferris = gHUDGameplayType.FERRIS,
		DiaoChe = gHUDGameplayType.DIAO_CHE,
		HackInteract = gHUDGameplayType.HACK_INTERACT,
		PoliceEscort = gHUDGameplayType.POLICE_ESCORT
	}
	self.HasPC = {}
	self.curType = -1
	self.curTypeStore = nil
	self.curShowData = nil
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.msgEvents = {
		[gEventConstants.PLAYGROUNDSWING_END] = self:CreateAction("OnGameplaySwingChange"),
		[gEventConstants.ENTER_BASE_VEHICLE_INTERIOR] = self:CreateAction("OnEnterBaseVehicleInterior"),
		[gEventConstants.EXIT_BASE_VEHICLE_INTERIOR] = self:CreateAction("OnExitBaseVehicleInterior")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnDestroy()
	self:ClearMessageEvents()
	self:StopActiveGameplay()
end

function M:OnStart()
	if self.curType > -1 then
		self.bindData.tabRect.selectedIndex = self.curType
	end
end

function M:StartGameplayByName(name, showData)
	local type = self.TypeIdMap[name]

	self:StartGameplayByType(type, showData)
end

function M:StartGameplayByType(type, showData)
	self.curType = type

	if self.HasPC[self.curType] then
		self.curType = self.curType + 1
	end

	self.curShowData = showData

	gCoreHudModeMgr:PushHudMode("CoreHudGameplay_" .. type, gCoreHudModeMgr.HUD_MODE.GAMEPLAY)

	if self.STATE_EnableOnce then
		self.bindData.tabRect.selectedIndex = self.curType
	end
end

function M:StopGameplayByName(name)
	local type = self.TypeIdMap[name]

	self:StopGameplayByType(type)
end

function M:StopGameplayByType(type)
	if self.HasPC[type] then
		type = type + 1
	end

	if type == self.curType then
		self:StopActiveGameplay()
	end
end

function M:GetNowGameplayType()
	return self.curType
end

function M:StopActiveGameplay()
	gCoreHudModeMgr:PopHudMode("CoreHudGameplay_" .. self.curType, true)

	self.curType = -1
	self.curShowData = nil

	if self.curTypeStore then
		self.curTypeStore:OnClose()

		self.curTypeStore = nil
	end

	if self.STATE_EnableOnce then
		self.bindData.tabRect.selectedIndex = self.curType
	end
end

function M:OnRenderTab(index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(nil, self.curShowData)
	end
end

function M:OnGameplaySwingChange(eventId, isEnd)
	if not isEnd then
		self:StartGameplayByType(gHUDGameplayType.SWING)
	else
		self:StopGameplayByType(gHUDGameplayType.SWING)
	end
end

function M:OnEnterBaseVehicleInterior(eventId, vehicleId)
	local vehicleCs = DriveManager:GetBaseVehicle(vehicleId)
	local cfg = LTConfig.VehicleConfig.GetConfig(vehicleCs.cfgId)

	print_notice("OnEnterBaseVehicleInterior", vehicleId)

	if bit.band(cfg.VehicleFlag, LTConfig.VehicleConfig.VehicleFlagType.AutoDrive) == LTConfig.VehicleConfig.VehicleFlagType.AutoDrive then
		self.autoVehicleId = vehicleId

		self:StartGameplayByType(gHUDGameplayType.HackAutoDriving)
	end
end

function M:OnExitBaseVehicleInterior(eventId, vehicleId)
	print_notice("OnExitBaseVehicleInterior", vehicleId)

	if self.autoVehicleId == vehicleId then
		self:StopGameplayByType(gHUDGameplayType.HackAutoDriving)

		self.autoVehicleId = nil
	end
end

function M:OnStackHide()
	if self.curTypeStore and self.curTypeStore.OnStackHide then
		self.curTypeStore:OnStackHide()
	end
end

function M:OnStackShow()
	if self.curTypeStore and self.curTypeStore.OnStackShow then
		self.curTypeStore:OnStackShow()
	end
end
