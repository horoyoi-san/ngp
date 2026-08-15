C_MiniMapPanelStore = DefClass("C_MiniMapPanelStore", C_MiniMapPanelStore, C_StoreGroup)
GroupName2Class.MiniMapPanelStore = C_MiniMapPanelStore
local M = C_MiniMapPanelStore

function M:ctor()
	self._tVec2 = Vector2.New(0, 0)
end

function M:OnAwake()
	self.renderEulerZ = 0
	self.eulerZ = 0
	self.renderScale = 1
	self.originRenderTransparency = 1

	self:SetScale(0.5, true)
	self:RefreshMainRectSizeInfo()

	self.bindData.mainBtn.luaClick = self:CreateAction("OnMainBtnClick")
	self.csMapContainer = self.bindData.maskRT:GetComponent(typeof(LX6.Gps.UIMapContainer))

	self.csMapContainer:ClearRootRTs()
	self.csMapContainer:AddRootRT(self.bindData.mapRT)
	self.csMapContainer:AddRootRT(self.bindData.commonLayer)
	self.csMapContainer:AddRootRT(self.bindData.traceLayer)
	self:InitConstants()
	self:InitTraceData()
	self:InitElementContainer()
	self:InitRangeObject()
	self:InitDetectRangeInfo()
	self:InitCrime()

	self.eventHandlers = {
		[gEventConstants.MAP_SCALE_UPDATE_TO_MAP] = self:CreateAction("OnEventMapScaleUpdateToMap"),
		[gEventConstants.MAP_SHOW_MESSAGE] = self:CreateAction("ShowMessage"),
		[gEventConstants.SHOW_ESCAPE_CAR_TIPPANEL] = self:CreateAction("OnShowEscapeCarTipPanel"),
		[gEventConstants.MAP_IS_PV_FLAG_CHANGE] = self:CreateAction("UpdateIsPVState"),
		[gEventConstants.MINI_MAP_VIEW_MASK_CHANGE] = self:CreateAction("OnMiniMapViewMaskChange"),
		[gEventConstants.MINIMAP_CRIME_STATUS_UPDATE] = self:CreateAction("OnCrimeStatusUpdate"),
		[gEventConstants.GUN_SHOOT_MODE_CHANGED] = self:CreateAction("OnGunShootModeChanged"),
		[gEventConstants.ON_PROWL_STATE_CHANGE] = self:CreateAction("UpdateDetectRangeVisibility"),
		[gEventConstants.ON_UNIFIED_MAP_CHANGE] = self:CreateAction("OnUnifiedMapStateChange")
	}
end

function M:OnEnable()
	return
end

function M:OnStart()
	LX6.GUI.UIOcclusionMgr.SetOcclusionRT(self.bindData.mainRectRT)
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self.areaId = 0

	LX6.GUI.UIOcclusionMgr.ClearOcclusionRT(self.bindData.mainRectRT)
	self:DisposeView()
end

function M:OnGroupEnable()
	self.bindData.message:SetActive(false)

	self.areaId = 0
	self.baseMap = gBaseMapMgr:GetBaseMap(self.bindData.baseMap)

	self.baseMap:SetFixedScaleLevel(3)
	self:RegisterMessageEvents(self.eventHandlers)
end

function M:OnGroupDisable()
	self:DisposeView()
	self.baseMap:Release()
	self:ClearMessageEvents()
end

function M:CreateView()
	self:DisposeView()

	local mapViewCfg = MapView.GetDefaultConfig()
	mapViewCfg.viewMask = EMapViewMask.MiniMap
	mapViewCfg.useMiniMapSpiritFilter = true
	self.mapView = MapView.CreateView("miniMap", mapViewCfg)

	self.mapView:AddStage(self.mapView.defaultCullStage)
	self.mapView:AddStage(self.mapView.bindConflictStage)
	self.mapView:Commit()
	self.mapView:ConnectTraceSource()
	self.mapView:RegisterListener(function (instanceId)
		self:AddElement(instanceId)
	end, function (instanceId)
		self:RemoveElement(instanceId)
	end, function (instanceId)
		self:UpdateElement(instanceId)
	end)

	if gSpiritManager and gSpiritManager:GetCurFirstSpiritTid() then
		self.mapView:SetFilterSpiritId(gSpiritManager:GetCurFirstSpiritTid())
	end
end

function M:DisposeView()
	if self.mapView ~= nil then
		self.mapView:Dispose()

		self.mapView = nil
	end
end

function M:OnShow(panelId, data)
	self:UpdateIsPVState()
	self:CreateView()
	self:CloseMap()
	print_debug("MiniMapPanelStore OnShow")
end

function M:OnClose()
	self:CloseMap()
	self:DisposeView()
	print_debug("MiniMapPanelStore OnClose")
end

function M:OnUpdate()
	if gLuaDataManager.gameStage ~= LX6.Scene.SwitchSceneManager.GameStage.GameScene then
		return
	end

	self:RefreshMainRectSizeInfo()

	self._lastUpdateFrameCount = UnityEngine.Time.frameCount
	local areaId = gMapSystem.lastAreaId

	if self.areaId ~= areaId then
		if self.areaId > 0 then
			self:CloseMap()
		end

		self.areaId = areaId
		self.raidId = gMapSystem.lastRaidId
		self.indoorId = gMapSystem.lastIndoorId

		if areaId > 0 then
			self:OpenMap()
		end
	end

	if not self.areaId or self.areaId == 0 then
		return
	end
end

function M:OnLateUpdate()
	if not self.areaId or self.areaId == 0 then
		return
	end

	if self._lastUpdateFrameCount ~= UnityEngine.Time.frameCount then
		return
	end

	local eulerZ = 0
	local isDriving = gDriveVehiclesManager.cs_manager.isDriveMode and gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle
	isDriving = not not isDriving
	local isMainDriver = isDriving and gDriveVehiclesManager.cs_manager.CurDriveSeatIndex and gDriveVehiclesManager.cs_manager.CurDriveSeatIndex == 0

	if isDriving then
		self.bindData.isDriveMode = 1
	else
		self.bindData.isDriveMode = 0
	end

	if isMainDriver then
		eulerZ = gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle.VehicleGameObject.transform.eulerAngles.y
	else
		eulerZ = 0
	end

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.MiniMapAlwaysRotate) then
		eulerZ = gCS.CameraDataMgr.cinemachineManager:GetCameraYaw()
	end

	self:SetEulerZ(eulerZ)
	self:TickTweenScaleAndEulerZ()
	self:TickScaleAndRotation()

	local meEulerZ = 0
	local playerUnit = gCS.MyPlayerManager.PlayerUnit

	if isDriving then
		meEulerZ = -gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle.VehicleGameObject.transform.eulerAngles.y
	elseif playerUnit then
		meEulerZ = -playerUnit.EulerY
	end

	if playerUnit then
		self.bindData.playerCameraRT:SetLocalEulerAnglesZ(-gCS.CameraDataMgr.cinemachineManager:GetCameraYaw() - meEulerZ)
	end

	self.bindData.me.rectTransform:SetLocalEulerAnglesZ(meEulerZ + self.renderEulerZ)

	if playerUnit then
		self.focusPosition = self.focusPosition or Vector3.zero
		local uxPos = playerUnit.Position

		self.focusPosition:Set(uxPos.X, uxPos.Y, uxPos.Z)

		if isMainDriver then
			local vehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle

			if vehicle then
				local forward = vehicle.VehicleGameObject.transform.forward
				self.focusPosition = self.focusPosition + forward * self.worldRadius * 0.6
			end
		end
	elseif not self.focusPosition then
		self.focusPosition = Vector3.zero
	end

	local cameraSpeed = 140
	local dt = UnityEngine.Time.deltaTime
	local cameraStep = cameraSpeed * dt

	if not self.renderFocusPosition then
		self.renderFocusPosition = self.focusPosition
	else
		local dx = self.focusPosition.x - self.renderFocusPosition.x
		local dz = self.focusPosition.z - self.renderFocusPosition.z
		local sqrXZDistance = dx * dx + dz * dz

		if sqrXZDistance < cameraStep * cameraStep or sqrXZDistance > 4 * cameraSpeed * cameraSpeed then
			local value = self.focusPosition

			self.renderFocusPosition:Set(value.x, value.y, value.z)
		else
			self.renderFocusPosition = self.renderFocusPosition + Vector3.Normalize(self.focusPosition - self.renderFocusPosition) * cameraStep
		end
	end

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.UseNewMiniMapComp) then
		self.bindData.mapRoot.enabled = true

		self.bindData.baseMap:SetActive(false)
		self.bindData.mapRoot:SetViewData(self.renderFocusPosition, self.renderEulerZ)

		if isDriving then
			self.bindData.mapRoot:SetAsPerspectiveCamera()
		else
			self.bindData.mapRoot:SetAsOrthogonalCamera(self:ScaleToWorldRadius(self.renderScale))
		end
	else
		self.bindData.mapRoot.enabled = false

		self.bindData.baseMap:SetActive(true)
	end

	local focusTexX, focusTexY = gMapTransformHelper:WorldPosXZ2TexPosXY(self.renderFocusPosition.x, self.renderFocusPosition.z, self.areaId)

	if self.mapView then
		self.mapView:SetCullData(self.renderFocusPosition.x, self.renderFocusPosition.z, self.worldRadius + 100)
	end

	if not self.focusTexPosition then
		self.focusTexPosition = Vector2.New(focusTexX, focusTexY)
	else
		self.focusTexPosition.x = focusTexX
		self.focusTexPosition.y = focusTexY
	end

	if playerUnit then
		local pos = playerUnit.Position
		pos = Vector3.New(pos.X, pos.Y, pos.Z)

		if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.UseNewMiniMapComp) then
			local gX, gY = self.bindData.mapRoot:LuaGetUIGlobalPosByWorldPos(pos, false, nil, nil)

			self.bindData.me.rectTransform:SetPositionXY(gX, gY)
		else
			local texPosX, texPosY = gMapTransformHelper:WorldPosXZ2TexPosXY(pos.x, pos.z, self.areaId)
			local x, y = self:TransformTex2UIXY(texPosX, texPosY)

			self.bindData.me.rectTransform:SetLocalPositionXY(x, y)
		end

		self.bindData.me:SetActive(true)
	else
		self.bindData.me:SetActive(false)
	end

	local offsetX, offsetY = self:TransformTex2UIXY(0, 0)

	self.csMapContainer:SetOffset(offsetX, offsetY)

	if not self:TrySafeCallAndProfiler(self.TickTraceEffect, "TickTrace") then
		return
	end

	if not self:TrySafeCallAndProfiler(self.TickPathObjects, "TickPathObjects") then
		return
	end

	if not self:TrySafeCallAndProfiler(self.TickElementAnim, "TickElementAnim") then
		return
	end

	if not self:TrySafeCallAndProfiler(self.TickDetectRanges, "TickDetectRanges") then
		return
	end
end

function M:TrySafeCallAndProfiler(func, entryName)
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample(entryName)
	end

	local ok, err = xpcall(func, tolua.traceback, self)

	if not ok then
		print_error(entryName .. " error: ", err)
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end

	return ok
end

function M:OpenMap()
	self:ClearPathInfo()
	self.baseMap:SetMapInfo(self.areaId, 2, true)

	self.mapCfg = gMapUIUtils.GetMapConfig(self.raidId, self.indoorId)
	self.miniMapAreaCfg = self:GetMiniMapAreaConfig(self.raidId, self.indoorId)

	if self.mapView then
		self.mapView:SetupBoundsByAreaId({
			self.areaId
		})
	end

	self:UpdateScale()
	self:RefreshSafeAreas()
end

function M:GetMiniMapAreaConfig(raidId, indoorId)
	local worldRadius = 100

	if indoorId and indoorId > 0 then
		local indoorCfg = LTConfig.IndoorConfig.GetConfig(indoorId)

		if indoorCfg and indoorCfg.MiniMapRange > 0 then
			worldRadius = indoorCfg.MiniMapRange
		end
	else
		local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

		if raidCfg == nil then
			raidCfg = LTConfig.RaidConfig.GetConfig(LTConfig.RaidConfig.WorldMap)
		end

		local sceneCfg = LTConfig.SceneConfig.GetConfig(raidCfg.SceneId)

		if sceneCfg and sceneCfg.MiniMapRange > 0 then
			worldRadius = sceneCfg.MiniMapRange
		end
	end

	return {
		worldRadius = worldRadius
	}
end

function M:CloseMap()
	self.areaId = 0
end

function M:UpdateScale()
	self:RefreshMainRectSizeInfo()

	local curScale = gMapManager:GetCurrentMiniMapScale()
	self.worldRadius = self.miniMapAreaCfg.worldRadius / curScale
	local scaleWorld2UI = self.rectHalfShortSide / self.worldRadius
	local scale = self.mapCfg.scaleTex2World.y * scaleWorld2UI

	self:SetScale(scale)
end

function M:SetScale(scale, immediately)
	if scale <= 0 then
		return
	end

	self.scale = scale

	if immediately then
		self:ApplyRenderScale(scale)
	end
end

function M:ScaleToWorldRadius(scale)
	return self.mapCfg.scaleTex2World.y / scale * self.rectHalfShortSide
end

function M:SetEulerZ(eulerZ, immediately)
	self.eulerZ = eulerZ

	if immediately then
		self:ApplyRenderEulerZ(eulerZ)
	end
end

function M:TickTweenScaleAndEulerZ()
	if self.scale ~= self.renderScale then
		local logRenderScale = math.log(self.renderScale)
		local logScale = math.log(self.scale)
		local ds = UnityEngine.Time.deltaTime * 1
		local sign = logRenderScale < logScale and 1 or -1

		if ds > sign * (logScale - logRenderScale) then
			logRenderScale = logScale
		else
			logRenderScale = logRenderScale + sign * ds
		end

		self:ApplyRenderScale(math.exp(logRenderScale))
	end

	local renderEulerZ = self.renderEulerZ

	while self.eulerZ >= 360 do
		self.eulerZ = self.eulerZ - 360
	end

	while self.eulerZ < 0 do
		self.eulerZ = self.eulerZ + 360
	end

	while renderEulerZ >= 360 do
		renderEulerZ = renderEulerZ - 360
	end

	while renderEulerZ < 0 do
		renderEulerZ = renderEulerZ + 360
	end

	if self.eulerZ ~= renderEulerZ then
		local dt = UnityEngine.Time.deltaTime * 300
		local absDiff = math.abs(self.eulerZ - renderEulerZ)
		local absDiff2 = 360 - self.eulerZ + renderEulerZ
		local absDiff3 = 360 - renderEulerZ + self.eulerZ

		if absDiff < dt or absDiff2 < dt or absDiff3 < dt then
			renderEulerZ = self.eulerZ
		elseif absDiff > 180 then
			if renderEulerZ < self.eulerZ then
				renderEulerZ = renderEulerZ - dt
			else
				renderEulerZ = renderEulerZ + dt
			end
		elseif renderEulerZ < self.eulerZ then
			renderEulerZ = renderEulerZ + dt
		else
			renderEulerZ = renderEulerZ - dt
		end
	end

	self:ApplyRenderEulerZ(renderEulerZ)
end

function M:ApplyRenderScale(renderScale)
	if self.renderScale ~= renderScale then
		self.renderScale = renderScale
		self._scaleDirty = true
	end
end

function M:ApplyRenderEulerZ(renderEulerZ)
	if self.renderEulerZ ~= renderEulerZ then
		self.renderRadZ = renderEulerZ * math.pi / 180
		self.renderEulerZ = renderEulerZ
		self._eulerZDirty = true
	end
end

function M:RefreshMainRectSizeInfo()
	self.mainRectSize = gCS.LuaUtils.GetRectTransformSize(self.bindData.mainRectRT)
	self.rectHalfShortSide = (math.min(self.mainRectSize.y, self.mainRectSize.x) - 20) * 0.5
end

function M:UpdateIsPVState()
	self.bindData.isPV = gMapSystem.isPV and 1 or 0
end

function M:InitConstants()
	return
end

function M:ShowMessage()
	self.bindData.message:SetActive(true)

	local anim = self.bindData.message.anim

	if anim then
		anim:Play("S_vx_miniMap_RandomEventTips_open")
	end
end

function M:TransformUI2Tex(uiPos)
	if self.renderEulerZ ~= 0 then
		local r = Vector2.Magnitude(uiPos)
		local alpha = math.atan2(uiPos.y, uiPos.x)
		alpha = alpha - self.renderRadZ
		self._tVec2.x = math.cos(alpha) * r
		self._tVec2.y = math.sin(alpha) * r
		uiPos = self._tVec2
	end

	return uiPos / self.renderScale + self.focusTexPosition
end

function M:TransformTex2UIXY(texX, texY)
	local uiX = (texX - self.focusTexPosition.x) * self.renderScale
	local uiY = (texY - self.focusTexPosition.y) * self.renderScale

	if self.renderEulerZ ~= 0 then
		local r = math.sqrt(uiX * uiX + uiY * uiY)
		local alpha = math.atan2(uiY, uiX)
		alpha = alpha + self.renderRadZ
		uiX = math.cos(alpha) * r
		uiY = math.sin(alpha) * r
	end

	return uiX, uiY
end

function M:TransformTex2UIClamp(texPos)
	texPos = texPos - self.focusTexPosition
	local offset = texPos * self.renderScale
	local r = Vector2.Magnitude(offset)
	local rad = math.atan2(offset.y, offset.x)

	if self.renderEulerZ ~= 0 then
		rad = rad + self.renderRadZ
	end

	offset.x = math.cos(rad) * r
	offset.y = math.sin(rad) * r

	if math.abs(offset.x) < self.mainRectSize.x * 0.5 and math.abs(offset.y) < self.mainRectSize.y * 0.5 then
		return offset, false
	else
		return self:TransformRadToEdgePos(rad), true
	end
end

function M:TransformRadToEdgePos(rad)
	local sin = math.sin(rad)
	local cos = math.cos(rad)
	local lenSin = sin == 0 and self.mainRectSize.y or math.abs(self.mainRectSize.y / sin)
	local lenCos = cos == 0 and self.mainRectSize.x or math.abs(self.mainRectSize.x / cos)
	local len = lenCos < lenSin and lenCos or lenSin
	len = len * 0.5

	return Vector2.New(cos * len, sin * len)
end

function M:OnEventMapScaleUpdateToMap()
	if not self.areaId or self.areaId == 0 or not self.mapCfg then
		return
	end

	self:UpdateScale()
end

function M:OnMiniMapViewMaskChange()
	if not self.areaId or self.areaId == 0 or not self.mapCfg then
		return
	end

	self.mapView:SetViewMask(gMapSystem.ui:GetMiniMapViewMask())
end

function M:OnShowEscapeCarTipPanel(eventId, id)
	if id == gVehicleGamePlayManager.EscapeCarState.Catch or id == gVehicleGamePlayManager.EscapeCarState.InSight then
		self.bindData.hasChaseCarAlert = 1
	end

	if id == gVehicleGamePlayManager.EscapeCarState.Finish or id == gVehicleGamePlayManager.EscapeCarState.Fail then
		self.bindData.hasChaseCarAlert = 0
	end
end

function M:OnMainBtnClick()
	gMapUtils:PlayerOpenBigMap()
end

function M:OnGunShootModeChanged(eventId, data)
	if gCS.GunModule.IsMiniMapDark then
		self.baseMap:ChangeBuildingVisibility(false)
		self.baseMap:ChangeMapBgTransparency(LTConfig.GpsConfig.MiniMapAimTransparency)
	else
		self.baseMap:ChangeBuildingVisibility(true)
		self.baseMap:ChangeMapBgTransparency(self.originRenderTransparency)
	end
end

dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Element")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Trace")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Range")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_DetectRange")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Path")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Crime")
