-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RacingPanelStore.lua
-- Decompiled from: 00895_RacingPanelStore.lua_033b7111ca40.luajit

C_RacingPanelStore = DefClass("C_RacingPanelStore", C_RacingPanelStore, C_StoreGroup)
GroupName2Class.RacingPanelStore = C_RacingPanelStore
local M = C_RacingPanelStore
local MainCamera = gCS.CameraDataMgr.MainCamera
local ChallengeConfig = LTConfig.ChallengeConfig
local RacingDriverConfig = LTConfig.RacingDriverConfig

M.ctor = function(self)
	self.offset = 10
	self.storeList = {}
	self.msgEvents = {
		[gEventConstants.ON_ARROW_INFO_CHANGE] = self.CreateAction(self, self.ArrowInfoChange),
		[gEventConstants.ON_RACING_PANEL_ADD] = self.CreateAction(self, self.OnCareTipInfoChange)
	}
end

M.UpdatePanel = function(self, store, distance, rank, pos, zOffset, entity, name, transform)
	store.rankText = tostring(rank)
	store.rankTextS = tostring(rank)

	if self.CheckPlaneIsShow(self, distance, pos, entity) then
		store.rootComponent.renderOpacity = 1
	else
		store.rootComponent.renderOpacity = 0

		return
	end

	store.name = name
	local scaleDistance = Mathf.Clamp(distance, self.minDistance, self.maxDistance)
	local posZOffset = self.ZOffset
	local screenPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.panelTransform, transform and pos or pos + posZOffset)
	store.rootTransform.anchoredPosition = screenPos

	store.rootTransform:SetLocalPositionZ(zOffset)

	local scale = self.minScale + (self.maxScale - self.minScale) * (self.maxDistance - scaleDistance) / (self.maxDistance - self.minDistance)

	if self.isPCPlatform then
		scale = scale * self.pcPlaneScale
	end

	store.rootTransform:SetLocalScale(scale)
end

M.CheckPlaneIsShow = function(self, distance, pos, entity)
	if pos ~= nil then
		return false
	end

	if self.autoShowDistance < distance then
		return false
	end

	if not gCS.LuaUtils.IsInCameraView(MainCamera, pos) then
		return false
	end

	if entity ~= nil then
		return true
	end

	local hitDistance = gCS.LuaUtils.CalRaceCarDistance(MainCamera.transform.position, entity, self.autoShowDistance * 1.5)

	if hitDistance + self.offset >= Vector3.Distance(MainCamera.transform.position, pos) then
		return false
	end

	return true
end

M.InitConfig = function(self)
	self.autoShowDistance = ChallengeConfig.MaximumPanelSpacing
	self.maxDistance = ChallengeConfig.MaximumPanelSpacing
	self.minDistance = ChallengeConfig.MinPanelSpacing
	self.maxScale = ChallengeConfig.MaxPanelScale
	self.minScale = ChallengeConfig.MinPanelScale
	self.ZOffset = Vector3.New(0, ChallengeConfig.PanelAltitudeVechicle, 0)
	self.pcPlaneScale = ChallengeConfig.PCPlaneScale
	self.gpsShowDistance = LTConfig.RacingDriverConfig.FollowingVehicleDistance
	self.MaxZOffset = RacingDriverConfig.DirectionSignsHeight
	self.minArrowDistance = RacingDriverConfig.DirectionSignsDescend[1]
	self.ArrowDistanceRate = RacingDriverConfig.DirectionSignsDescend[2]
	self.MinZOffset = RacingDriverConfig.DirectionSignsDescend[3]
end

M.OnShow = function(self, panelId, data)
	if data ~= nil or self.isShow then
		return
	end

	self.isShow = true

	self.InitConfig(self)

	self.isCs = data.isCs
	self.isUgc = data.isUgc
	local carTipInfos = data.carTipInfos
	self.isPCPlatform = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive()
	self.storeList = {}

	for _, val in pairs(carTipInfos) do
		self.CreateCarTipInfo(self, val)
	end

	self.ArrowInfoChange(self, _, data.arrow)
end

M.OnCareTipInfoChange = function(self, _, data)
	self.CreateCarTipInfo(self, data)
end

M.CreateCarTipInfo = function(self, val)
	if val ~= nil or val.id ~= nil or self.storeList[val.id] == nil then
		return
	end

	local instanceId = gCS.LuaUtils.GenerateRacingTemplate(self.bindData.panelRoot.gameObject)

	if instanceId == -1 then
		local store = self:GetStoreById(instanceId)
		store.rank = 1
		store.name = val.name
		local widget = self.bindData.gpsWidgetPool:CreateItem(0)
		local gpsStore = gStoreManager:GetStoreGroup("HudGpsCommonStore"):GetStoreByWidget(widget)
		gpsStore.isShowDistance = 0
		gpsStore.isOutside = 1
		widget.gameObjectActive = false
		local gpsInfo = {
			store = gpsStore,
			widget = widget
		}
		local hudInfo = {
			store = store
		}
		self.storeList[val.id] = {
			gpsInfo = gpsInfo,
			hudInfo = hudInfo
		}
	end
end

M.OnCameraUpdate = function(self)
	local carTipInfos = nil

	if self.isCs then
		local mgr = self.isUgc and L50.Spoon.UgcRaceManager.Instance or L50.Spoon.CarRaceManager.Instance

		if not mgr then
			return
		end

		carTipInfos = mgr.GetAllVehicleData(mgr)
	else
		carTipInfos = gCarRaceManager:GetAllCarInfo()
	end

	self.UpdateArrowPosition(self)

	for _, info in pairs(carTipInfos) do
		local storeInfo = self.storeList[info.vehicleId]

		if storeInfo then
			local hudInfo = storeInfo.hudInfo

			if hudInfo then
				self.UpdatePanel(self, hudInfo.store, info.distance, info.rank, info.pos, info.zOffset, info.entity, info.name, info.transform)
			end

			local gpsInfo = storeInfo.gpsInfo

			if gpsInfo then
				self.OnGpsIconUpdate(self, gpsInfo.store, gpsInfo.widget, info.distance, info.isBack, info.pos)
			end
		end
	end
end

M.OnGpsIconUpdate = function(self, store, widget, distance, isBack, worldPos)
	local visible = isBack and distance <= self.gpsShowDistance

	if widget.gameObjectActive == visible then
		widget.gameObjectActive = visible
	end

	if visible then
		local clamped, uiWorldPos, arrowEulerZ = LX6.Gps.MainViewUtils.TryEllipseClampWorldPos2UIWorldPos(worldPos, self.bindData.ellipseRT, nil, )
		widget.rectTransform.position = uiWorldPos
		local eulerZ = clamped and arrowEulerZ - 90 or 180

		store.eulerRoot.rectTransform:SetLocalEulerAnglesZ(eulerZ)

		if store.antiEulerRoot then
			store.antiEulerRoot.rectTransform:SetLocalEulerAnglesZ(-eulerZ)
		end
	end
end

M.ArrowInfoChange = function(self, _, data)
	if data then
		self.arrowPos = Vector3.New(data.arrowPos.x, data.arrowPos.y, data.arrowPos.z)
		self.arrowRot = Vector3.New(data.arrowRot.x, data.arrowRot.y, data.arrowRot.z)
		self.bindData.iconUrl = gUIUtils:GetSguiImagePath(data.imageId)
		self.arrowActive = data.active
	end

	self.bindData.showHints = self.arrowActive and 1 or 0

	self:UpdateArrowPosition()
end

M.RefreshPlayerDistance = function(self)
	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local distance = Vector3.XZDistance(playerPos, self.arrowPos)
	local zOffset = self.minArrowDistance >= distance and self.MaxZOffset or Mathf.Clamp(self.MaxZOffset - (self.minArrowDistance - distance) * self.ArrowDistanceRate, self.MinZOffset, self.MaxZOffset)
	self.bindData.distanceText = string.format("%.0f", distance) .. "m"

	return Vector3.New(0, zOffset, 0)
end

M.UpdateArrowPosition = function(self)
	if self.arrowActive then
		local posZOffset = self:RefreshPlayerDistance()
		local rot = Quaternion.Euler(self.arrowRot)
		local uiPos = self.arrowPos + rot * posZOffset
		local isShow = gCS.LuaUtils.IsInCameraView(MainCamera, uiPos)
		self.bindData.showHints = isShow and 1 or 0

		if isShow then
			local screenPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.panelTransform, uiPos)
			self.bindData.imageTransform.anchoredPosition = screenPos
		end
	end
end

M.OnClose = function(self)
	self.storeList = {}
	self.isShow = false
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end
