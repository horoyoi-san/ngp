C_RacingPanelStore = DefClass("C_RacingPanelStore", C_RacingPanelStore, C_StoreGroup)
GroupName2Class.RacingPanelStore = C_RacingPanelStore
local M = C_RacingPanelStore
local MainCamera = gCS.CameraDataMgr.MainCamera
local ChallengeConfig = LTConfig.ChallengeConfig

function M:ctor()
	self.offset = 10
	self.storeList = {}
end

function M:UpdatePanel(store, distance, rank, pos, zOffset, entity)
	store.rankText = tostring(rank)
	store.rankTextS = tostring(rank)

	if self:CheckPlaneIsShow(distance, pos, entity) then
		store.rootComponent.renderOpacity = 1
	else
		store.rootComponent.renderOpacity = 0

		return
	end

	local scaleDistance = Mathf.Clamp(distance, self.minDistance, self.maxDistance)
	local posZOffset = self.ZOffset
	local screenPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.panelTransform, pos + posZOffset)
	store.rootTransform.anchoredPosition = screenPos

	store.rootTransform:SetLocalPositionZ(zOffset)

	local scale = self.minScale + (self.maxScale - self.minScale) * (self.maxDistance - scaleDistance) / (self.maxDistance - self.minDistance)

	if self.isPCPlatform then
		scale = scale * self.pcPlaneScale
	end

	store.rootTransform:SetLocalScale(scale)
end

function M:CheckPlaneIsShow(distance, pos, entity)
	if pos == nil then
		return false
	end

	if self.autoShowDistance <= distance then
		return false
	end

	if not gCS.LuaUtils.IsInCameraView(MainCamera, pos) then
		return false
	end

	local hitDistance = gCS.LuaUtils.CalRaceCarDistance(MainCamera.transform.position, entity, self.autoShowDistance * 1.5)

	if hitDistance + self.offset < Vector3.Distance(MainCamera.transform.position, pos) then
		return false
	end

	return true
end

function M:InitConfig()
	self.autoShowDistance = ChallengeConfig.MaximumPanelSpacing
	self.maxDistance = ChallengeConfig.MaximumPanelSpacing
	self.minDistance = ChallengeConfig.MinPanelSpacing
	self.maxScale = ChallengeConfig.MaxPanelScale
	self.minScale = ChallengeConfig.MinPanelScale
	self.ZOffset = Vector3.New(0, ChallengeConfig.PanelAltitudeVechicle, 0)
	self.pcPlaneScale = ChallengeConfig.PCPlaneScale
end

function M:OnShow(panelId, data)
	if data == nil then
		return
	end

	self:InitConfig()

	self.isCs = data.isCs
	local carTipInfos = data.carTipInfos
	self.isPCPlatform = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive()
	self.storeList = {}

	for _, val in pairs(carTipInfos) do
		local instanceId = gCS.LuaUtils.GenerateRacingTemplate(self.bindData.panelRoot.gameObject)

		if instanceId ~= -1 then
			local store = self:GetStoreById(instanceId)
			store.rank = 4
			store.name = val.name
			self.storeList[val.id] = store
		end
	end
end

function M:OnCameraUpdate()
	local carTipInfos = self.isCs and L50.Spoon.CarRaceManager:GetAllVehicleData() or gCarRaceManager:GetAllCarInfo()

	for _, info in pairs(carTipInfos) do
		local store = self.storeList[info.vehicleId]

		if store then
			self:UpdatePanel(store, info.distance, info.rank, info.pos, info.zOffset, info.entity)
		end
	end
end

function M:OnClose()
	self.storeList = {}
end
