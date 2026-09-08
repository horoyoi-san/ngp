-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MiniMapPanelStore.lua
-- Decompiled from: 00974_MiniMapPanelStore.lua_dd3fc19da041.luajit

C_MiniMapPanelStore = DefClass("C_MiniMapPanelStore", C_MiniMapPanelStore, C_StoreGroup)
GroupName2Class.MiniMapPanelStore = C_MiniMapPanelStore
local M = C_MiniMapPanelStore
local CallRecorderUtils = require("LX6/Utils/CallRecorderUtils")
local WidgetOpWrapperUtils = require("LX6/Utils/WidgetOpWrapperUtils")
local TaskMapPrefabResolver = require("LX6/Manager/Map/TaskMapPrefabResolver")

M.ctor = function(self)
	self._tVec2 = Vector2.New(0, 0)
	self._tempData = {}
	self.focusTexPosition = Vector2.New(0, 0)
end

M.OnAwake = function(self)
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

	slot1 = self.csMapContainer

	slot1:AddRootRT(self.bindData.traceLayer)
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
		[gEventConstants.GUN_SHOOT_MODE_CHANGED] = self:CreateAction("OnGunShootModeChanged"),
		[gEventConstants.ON_PROWL_STATE_CHANGE] = self:CreateAction("UpdateDetectRangeVisibility"),
		[gEventConstants.ON_UNIFIED_MAP_CHANGE] = self:CreateAction("OnUnifiedMapStateChange"),
		[gEventConstants.ON_ACTIVE_DANGER_AREA_CHANGE] = self:CreateAction("RefreshSafeAreas"),
		[gEventConstants.MINIMAP_ARREST_STATUS_UPDATE] = self:CreateAction("UpdateArrestMode"),
		[gEventConstants.ON_ENTER_OR_LEAVE_DANGER_AREA] = self:CreateAction("OnEnterOrLeaveDangerArea"),
		[gEventConstants.PLAYER_FIGHT_STATUS_CHANGE] = self:CreateAction("OnPlayerFightStatusChange"),
		[gEventConstants.SYNC_CURRENT_SPIRIT] = self:CreateAction("RefreshFilterSpiritId"),
		[gEventConstants.MAP_CHANGE_TO_INDOOR_MAP_EARLY] = self:CreateAction("OnAreaIdChange"),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("OnLinkModeChange"),
		[gEventConstants.ON_ENTER_BASKETBALL_LINK] = self:CreateAction("OnLinkModeChange"),
		[gEventConstants.ON_LEAVE_BASKETBALL_LINK] = self:CreateAction("OnLinkModeChange"),
		[gEventConstants.LINK_MEMBER_INFO_CHANGE] = self:CreateAction("RefreshMe"),
		[gEventConstants.TEAM_REFRESH_DATA] = self:CreateAction("RefreshMe"),
		[gEventConstants.TASK_STATE_CHANGED] = self:CreateAction("OnTaskMapPrefabChanged")
	}
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	LX6.GUI.UIOcclusionMgr.SetOcclusionRT(self.bindData.mainRectRT)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.areaId = 0

	LX6.GUI.UIOcclusionMgr.ClearOcclusionRT(self.bindData.mainRectRT)
	self.DisposeView(self)
end

M.OnGroupEnable = function(self)
	self.bindData.message:SetActive(false)

	self.areaId = 0
	self.baseMap = gBaseMapMgr:GetBaseMap(self.bindData.baseMap)

	self.baseMap:SetRetainSegmentedMapInstance(true)
	self.baseMap:SetFixedScaleLevel(3)
	self:RegisterMessageEvents(self.eventHandlers)
	self:RefreshMe()
end

M.OnGroupDisable = function(self)
	self:DisposeView()
	self.baseMap:Release()

	self.taskMiniMapPath = nil

	self:ClearMessageEvents()
end

M.CreateView = function(self)
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
	self:RefreshFilterSpiritId()
end

M.RefreshFilterSpiritId = function(self)
	if self.mapView and gSpiritManager and gSpiritManager:GetCurFirstSpiritTid() then
		self.mapView:SetFilterSpiritId(gSpiritManager:GetCurFirstSpiritTid())
	end
end

M.OnAreaIdChange = function(self)
	self.SetAreaId(self)
end

M.SetAreaId = function(self)
	local areaId = gMapManager:GetParentAreaId(gMapSystem.lastAreaId)

	if self.areaId == areaId then
		if self.areaId <= 0 then
			self.CloseMap(self)
		end

		self.areaId = areaId
		self.raidId, self.indoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)

		if areaId <= 0 then
			self.OpenMap(self)
		end
	end
end

M.DisposeView = function(self)
	if self.mapView == nil then
		self.mapView:Dispose()

		self.mapView = nil
	end
end

M.OnShow = function(self, panelId, data)
	self:UpdateIsPVState()
	self:RefreshModeCtrl()
	self:CreateView()
	self:CloseMap()
	self:SetAreaId()
	self:OnShowEscapeCarTipPanel()
	gMapSystem.ui:SetMiniMapActive(true)
	gMessageManager:SendMessage(gEventConstants.ON_MINIMAP_VISIBILITY_CHANGE, true)
	print_debug("MiniMapPanelStore OnShow")
end

M.OnClose = function(self)
	gMapSystem.ui:SetMiniMapActive(false)
	gMessageManager:SendMessage(gEventConstants.ON_MINIMAP_VISIBILITY_CHANGE, false)
	self:CloseMap()
	self:DisposeView()
	print_debug("MiniMapPanelStore OnClose")
end

M.OnLanguageChange = function(self, lang)
end

M.OnUpdate = function(self)
	if gLuaDataManager.gameStage == LX6.Scene.SwitchSceneManager.GameStage.GameScene then
		gPanelManager:Close(gPanelId.S_MINI_MAP_PANEL)
	end

	self.RefreshMainRectSizeInfo(self)

	self._lastUpdateFrameCount = UnityEngine.Time.frameCount

	if gGpsTools.TryTick("tmp_MiniMapArrest", 0.5) then
		self.UpdateArrestMode(self)
	end

	if not self.areaId or self.areaId ~= 0 then
		return
	end
end

M.StoreWidgetOperation = function(self, obj, method, ...)
	if not self.logicThreadRecorder then
		self.logicThreadRecorder = CallRecorderUtils.CallRecorder.new()
	end

	self.logicThreadRecorder:record(obj, method, ...)
end

M.InvokeWidgetOperation = function(self)
	if self.logicThreadRecorder then
		xpcall(self.logicThreadRecorder.replay_all, tolua.traceback, self.logicThreadRecorder)
		self.logicThreadRecorder:clear()
	end
end

M.PreUpdatePanel = function(self)
	self._tempData.shouldTickThisFrame = false

	if not self.areaId or self.areaId ~= 0 then
		return
	end

	if self._lastUpdateFrameCount == UnityEngine.Time.frameCount then
		return
	end

	self._tempData.shouldTickThisFrame = true

	if gMapSystem.curPlayerUnit then
		self._tempData.playerUnitValid = true
		local pos = gMapSystem:GetCurPlayerPosition()
		self._tempData.playerUnitPos = pos
		self._tempData.playerUnitLocalPos = gMapSystem:GetCurPlayerLocalPosition()
		self._tempData.playerUnitEulerY = gMapSystem:GetCurPlayerEulerY()
		pos = Vector3.New(pos.X, pos.Y, pos.Z)
		self._tempData.playerUnitMapPosX = pos.x
		self._tempData.playerUnitMapPosZ = pos.z
	else
		self._tempData.playerUnitValid = false
	end

	self._tempData.mapScale = self.bindData.mapRT and self.bindData.mapRT.localScale.x or 1
end

M.UpdatePanel = function(self)
	if not self._tempData.shouldTickThisFrame then
		return
	end

	local eulerZ = 0
	local isDriving = gMapSystem.curVehicle
	isDriving = not not isDriving
	local isMainDriver = isDriving and gDriveVehiclesManager.cs_manager.CurDriveSeatIndex ~= 0
	local driveVehicle = gMapSystem.curVehicle and gMapSystem.curVehicle.gameObject

	if isDriving and isMainDriver and driveVehicle and not gCS.LuaUtils.IsNull(driveVehicle) then
		eulerZ = driveVehicle.transform:GetEulerAnglesNoSync().y
	end

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.MiniMapAlwaysRotate) then
		eulerZ = gCS.CameraDataMgr.cinemachineManager:GetCameraYaw()
	end

	self.SetEulerZ(self, eulerZ)
	self.CalcTickTweenScaleAndEulerZ(self)

	self._tempData.meEulerZ = 0

	if isDriving and driveVehicle and not gCS.LuaUtils.IsNull(driveVehicle) then
		self._tempData.meEulerZ = -driveVehicle.transform:GetEulerAnglesNoSync().y
	elseif self._tempData.playerUnitValid then
		self._tempData.meEulerZ = -self._tempData.playerUnitEulerY
	end

	self._tempData.meRootEulerZ = self._tempData.meEulerZ + self.renderEulerZ

	if self._tempData.playerUnitValid then
		self.focusPosition = self.focusPosition or Vector3.zero
		local uxPos = self._tempData.playerUnitPos

		self.focusPosition:Set(uxPos.X, uxPos.Y, uxPos.Z)

		if isMainDriver and driveVehicle and not gCS.LuaUtils.IsNull(driveVehicle) then
			local forward = driveVehicle.transform:GetForwardNoSync()
			self.focusPosition = self.focusPosition + forward * self.worldRadius * 0.6
		end
	elseif not self.focusPosition then
		self.focusPosition = Vector3.zero
	end

	local cameraSpeed = 140
	local dt = gLogicTime.deltaTime
	local cameraStep = cameraSpeed * dt

	if not self.renderFocusPosition then
		self.renderFocusPosition = self.focusPosition
	else
		local dx = self.focusPosition.x - self.renderFocusPosition.x
		local dz = self.focusPosition.z - self.renderFocusPosition.z
		local sqrXZDistance = dx * dx + dz * dz

		if sqrXZDistance <= cameraStep * cameraStep or sqrXZDistance <= 4 * cameraSpeed * cameraSpeed then
			local value = self.focusPosition

			self.renderFocusPosition:Set(value.x, value.y, value.z)
		else
			self.renderFocusPosition = self.renderFocusPosition + Vector3.Normalize(self.focusPosition - self.renderFocusPosition) * cameraStep
		end
	end

	if not self.TrySafeCallAndProfiler(self, self.TickElementCountDown, "TickElementCountDown", false) then
		return
	end

	self.UpdatePanel2(self, isDriving)
end

M.UpdatePanel2 = function(self, isDriving)
	self.ApplyTickTweenScaleAndEulerZ(self, true)
	self.TickScaleAndRotation(self, true)

	local playerUnit = gMapSystem.curPlayerUnit

	if isDriving then
		self.bindData.isDriveMode = 1
	else
		self.bindData.isDriveMode = 0
	end

	local summonConfig = nil

	if self._tempData.playerUnitValid and playerUnit then
		self:StoreWidgetOperation(self.playerCameraRT, self.playerCameraRT.SetLocalEulerAnglesZ, -gCS.CameraDataMgr.cinemachineManager:GetCameraYaw() - self._tempData.meEulerZ)

		local agentConfig = LTConfig.AgentConfig.GetConfig(playerUnit.TemplateId)

		if agentConfig and agentConfig.SummonTag and agentConfig.SummonTag == 0 then
			summonConfig = LTConfig.SummonConfig.GetConfig(agentConfig.SummonTag)
		end
	end

	if summonConfig then
		self.bindData.meCtrl = 1
		self.summonIconId = summonConfig.MiniMapIconId

		if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
			self.bindData:Commit("summonIconId", summonConfig.MiniMapIconId, COMMIT_FORCE)
		else
			self.bindData:Commit("onlineSummonIconId", summonConfig.MiniMapIconId, COMMIT_FORCE)
		end

		self.StoreWidgetOperation(self, self.summonImg.rectTransform, self.summonImg.rectTransform.SetLocalEulerAnglesZ, -self._tempData.meRootEulerZ)
	else
		self.bindData.meCtrl = 0

		self.StoreWidgetOperation(self, self.meImg.rectTransform, self.meImg.rectTransform.SetLocalEulerAnglesZ, 0)
	end

	self:StoreWidgetOperation(self.me.rectTransform, self.me.rectTransform.SetLocalEulerAnglesZ, self._tempData.meRootEulerZ)
	self:StoreWidgetOperation(self.bindData.baseMap, self.bindData.baseMap.SetActive, true)

	local focusTexX, focusTexY = gMapTransformHelper:WorldPosXZ2TexPosXY(self.renderFocusPosition.x, self.renderFocusPosition.z, self.areaId)

	if self.mapView then
		self.StoreWidgetOperation(self, self.mapView, self.mapView.SetCullData, self.renderFocusPosition.x, self.renderFocusPosition.z, self.worldRadius + 100)
	end

	self.focusTexPosition.x = focusTexX
	self.focusTexPosition.y = focusTexY

	if self._tempData.playerUnitValid then
		local texPosX, texPosY = gMapTransformHelper:WorldPosXZ2TexPosXY(self._tempData.playerUnitMapPosX, self._tempData.playerUnitMapPosZ, self.areaId)
		local x, y = self:TransformTex2UIXY(texPosX, texPosY)

		self:StoreWidgetOperation(self.me.rectTransform, self.me.rectTransform.SetLocalPositionXY, x, y)
		self:StoreWidgetOperation(self.me, self.me.SetActive, true)
	else
		self.StoreWidgetOperation(self, self.me, self.me.SetActive, false)
	end

	local offsetX, offsetY = self.TransformTex2UIXY(self, 0, 0)

	self.StoreWidgetOperation(self, self.csMapContainer, self.csMapContainer.SetOffset, offsetX, offsetY)

	if not self.TrySafeCallAndProfiler(self, self.TickTraceEffect, "TickTrace", true) then
		return
	end

	if not self.TrySafeCallAndProfiler(self, self.TickPathObjects, "TickPathObjects", true) then
		return
	end

	if not self.TrySafeCallAndProfiler(self, self.TickElementAnim, "TickElementAnim", true) then
		return
	end

	if not self.TrySafeCallAndProfiler(self, self.TickDetectRanges, "TickDetectRanges", true) then
		return
	end

	if not self.TrySafeCallAndProfiler(self, self.TickSafeAreaActive, "TickSafeAreaActive", true) then
		return
	end
end

M.PostUpdatePanel = function(self)
	self.InvokeWidgetOperation(self)
end

M.OnLateUpdate = function(self)
	if LX6.Gps.MapSystem.Instance:GetMiniMapLogicThreadSwitchState() then
		return
	end

	if not self.areaId or self.areaId ~= 0 then
		return
	end

	if self._lastUpdateFrameCount == UnityEngine.Time.frameCount then
		return
	end

	local eulerZ = 0
	local cs_manager = gDriveVehiclesManager.cs_manager
	local curVehicle = cs_manager.CurrentPlayerBaseVehicle
	local isDriving = cs_manager.isDriveMode and curVehicle
	isDriving = not not isDriving
	local isMainDriver = isDriving and cs_manager.CurDriveSeatIndex and cs_manager.CurDriveSeatIndex ~= 0

	if isDriving then
		self.bindData.isDriveMode = 1
	else
		self.bindData.isDriveMode = 0
	end

	if isMainDriver and curVehicle.gameObject and not gCS.LuaUtils.IsNull(curVehicle.gameObject) and curVehicle.gameObject.transform then
		eulerZ = curVehicle.gameObject.transform.eulerAngles.y
	else
		eulerZ = 0
	end

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.MiniMapAlwaysRotate) then
		eulerZ = gCS.CameraDataMgr.cinemachineManager:GetCameraYaw()
	end

	self:SetEulerZ(eulerZ)
	self:TickTweenScaleAndEulerZ()
	self:TickScaleAndRotation()

	local meEulerZ = gMapSystem:GetCurPlayerEulerY()
	local playerUnit = gMapSystem.curPlayerUnit
	local summonConfig = nil

	if playerUnit then
		self.playerCameraRT:SetLocalEulerAnglesZ(-gCS.CameraDataMgr.cinemachineManager:GetCameraYaw() - meEulerZ)

		local agentConfig = LTConfig.AgentConfig.GetConfig(playerUnit.TemplateId)

		if agentConfig and agentConfig.SummonTag and agentConfig.SummonTag == 0 then
			summonConfig = LTConfig.SummonConfig.GetConfig(agentConfig.SummonTag)
		end
	end

	local meRootEulerZ = meEulerZ + self.renderEulerZ

	if summonConfig then
		self.bindData.meCtrl = 1
		self.summonIconId = summonConfig.MiniMapIconId

		self.summonImg.rectTransform:SetLocalEulerAnglesZ(-meRootEulerZ)
	else
		self.bindData.meCtrl = 0

		self.meImg.rectTransform:SetLocalEulerAnglesZ(0)
	end

	self.me.rectTransform:SetLocalEulerAnglesZ(meRootEulerZ)

	if playerUnit then
		self.focusPosition = self.focusPosition or Vector3.zero
		local uxPos = gMapSystem:GetCurPlayerPosition()

		self.focusPosition:Set(uxPos.X, uxPos.Y, uxPos.Z)

		if isMainDriver then
			local vehicle = curVehicle

			if vehicle and vehicle.gameObject and not gCS.LuaUtils.IsNull(vehicle.gameObject) and vehicle.gameObject.transform then
				local forward = vehicle.gameObject.transform.forward
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

		if sqrXZDistance <= cameraStep * cameraStep or sqrXZDistance <= 4 * cameraSpeed * cameraSpeed then
			local value = self.focusPosition

			self.renderFocusPosition:Set(value.x, value.y, value.z)
		else
			self.renderFocusPosition = self.renderFocusPosition + Vector3.Normalize(self.focusPosition - self.renderFocusPosition) * cameraStep
		end
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
		local pos = gMapSystem:GetCurPlayerPosition()
		pos = Vector3.New(pos.X, pos.Y, pos.Z)
		local texPosX, texPosY = gMapTransformHelper:WorldPosXZ2TexPosXY(pos.x, pos.z, self.areaId)
		local x, y = self:TransformTex2UIXY(texPosX, texPosY)

		self.me.rectTransform:SetLocalPositionXY(x, y)
		self.me:SetActive(true)
	else
		self.me:SetActive(false)
	end

	local offsetX, offsetY = self:TransformTex2UIXY(0, 0)

	self.csMapContainer:SetOffset(offsetX, offsetY)

	if not self:TrySafeCallAndProfiler(self.TickTraceEffect, "TickTrace") then
		return
	end

	if not self.TrySafeCallAndProfiler(self, self.TickPathObjects, "TickPathObjects") then
		return
	end

	if not self.TrySafeCallAndProfiler(self, self.TickElementAnim, "TickElementAnim") then
		return
	end

	if not self.TrySafeCallAndProfiler(self, self.TickDetectRanges, "TickDetectRanges") then
		return
	end

	if not self.TrySafeCallAndProfiler(self, self.TickSafeAreaActive, "TickSafeAreaActive") then
		return
	end
end

M.TrySafeCallAndProfiler = function(self, func, entryName, inLogicThread)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample(entryName)
	end

	local ok, err = xpcall(func, tolua.traceback, self, inLogicThread)

	if not ok then
		print_error(entryName .. " error: ", err)
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end

	return ok
end

M.OpenMap = function(self)
	self:ClearPathInfo()

	local miniMapPath = TaskMapPrefabResolver.Resolve(self.raidId, self.indoorId)
	self.taskMiniMapPath = miniMapPath

	self.baseMap:SetMapInfo(self.areaId, 2, true, miniMapPath)

	self.mapCfg = gMapUIUtils.GetMapConfig(self.raidId, self.indoorId)
	self.miniMapAreaCfg = self:GetMiniMapAreaConfig(self.raidId, self.indoorId)

	if self.mapView then
		self.mapView:SetupBoundsByAreaId({
			self.areaId
		})
	end

	self.UpdateScale(self)
	self.RefreshSafeAreas(self)
	self.UpdateShowInBigWorldElements(self)

	self.renderFocusPosition = nil
end

M.OnTaskMapPrefabChanged = function(self)
	if self.areaId > 0 or self.taskMiniMapPath ~= nil then
		return
	end

	local miniMapPath = TaskMapPrefabResolver.Resolve(self.raidId, self.indoorId)

	if self.taskMiniMapPath ~= miniMapPath then
		return
	end

	self.taskMiniMapPath = miniMapPath

	self.baseMap:SetMapInfo(self.areaId, 2, true, miniMapPath)
end

M.GetMiniMapAreaConfig = function(self, raidId, indoorId)
	local worldRadius = 100

	if indoorId and indoorId <= 0 then
		local indoorCfg = LTConfig.IndoorConfig.GetConfig(indoorId)

		if indoorCfg and indoorCfg.MiniMapRange <= 0 then
			worldRadius = indoorCfg.MiniMapRange
		end
	else
		local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

		if raidCfg ~= nil then
			raidCfg = LTConfig.RaidConfig.GetConfig(LTConfig.RaidConfig.WorldMap)
		end

		local sceneCfg = LTConfig.SceneConfig.GetConfig(raidCfg.SceneId)

		if sceneCfg and sceneCfg.MiniMapRange <= 0 then
			worldRadius = sceneCfg.MiniMapRange
		end
	end

	return {
		worldRadius = worldRadius
	}
end

M.CloseMap = function(self)
	self.areaId = 0
end

M.UpdateScale = function(self)
	self:RefreshMainRectSizeInfo()

	local curScale = gMapManager:GetCurrentMiniMapScale()
	self.worldRadius = self.miniMapAreaCfg.worldRadius / curScale
	local scaleWorld2UI = self.rectHalfShortSide / self.worldRadius
	local scale = self.mapCfg.scaleTex2World.y * scaleWorld2UI

	self:SetScale(scale)
end

M.SetScale = function(self, scale, immediately)
	if scale < 0 then
		return
	end

	self.scale = scale

	if immediately then
		self.ApplyRenderScale(self, scale)
	end
end

M.ScaleToWorldRadius = function(self, scale)
	return self.mapCfg.scaleTex2World.y / scale * self.rectHalfShortSide
end

M.SetEulerZ = function(self, eulerZ, immediately)
	self.eulerZ = eulerZ

	if immediately then
		self.ApplyRenderEulerZ(self, eulerZ)
	end
end

M.CalcTickTweenScaleAndEulerZ = function(self)
	if self.scale == self.renderScale then
		local logRenderScale = math.log(self.renderScale)
		local logScale = math.log(self.scale)
		local ds = UnityEngine.Time.deltaTime * 1
		local sign = logRenderScale >= logScale and 1 or -1

		if ds <= sign * (logScale - logRenderScale) then
			logRenderScale = logScale
		else
			logRenderScale = logRenderScale + sign * ds
		end

		self._tempData.logRenderScale = math.exp(logRenderScale)
	end

	local renderEulerZ = self.renderEulerZ

	while self.eulerZ > 360 do
		self.eulerZ = self.eulerZ - 360
	end

	while self.eulerZ >= 0 do
		self.eulerZ = self.eulerZ + 360
	end

	while renderEulerZ > 360 do
		renderEulerZ = renderEulerZ - 360
	end

	while renderEulerZ >= 0 do
		renderEulerZ = renderEulerZ + 360
	end

	if self.eulerZ == renderEulerZ then
		local dt = UnityEngine.Time.deltaTime * 300
		local absDiff = math.abs(self.eulerZ - renderEulerZ)
		local absDiff2 = 360 - self.eulerZ + renderEulerZ
		local absDiff3 = 360 - renderEulerZ + self.eulerZ

		if absDiff <= dt or absDiff2 <= dt or absDiff3 >= dt then
			renderEulerZ = self.eulerZ
		elseif absDiff <= 180 then
			if renderEulerZ >= self.eulerZ then
				renderEulerZ = renderEulerZ - dt
			else
				renderEulerZ = renderEulerZ + dt
			end
		elseif renderEulerZ >= self.eulerZ then
			renderEulerZ = renderEulerZ + dt
		else
			renderEulerZ = renderEulerZ - dt
		end
	end

	self._tempData.renderEulerZ = renderEulerZ
end

M.ApplyTickTweenScaleAndEulerZ = function(self, inLogicThread)
	if self.scale == self.renderScale then
		self.ApplyRenderScale(self, self._tempData.logRenderScale, inLogicThread)
	end

	self.ApplyRenderEulerZ(self, self._tempData.renderEulerZ)
end

M.TickTweenScaleAndEulerZ = function(self, inLogicThread)
	if self.scale == self.renderScale then
		local logRenderScale = math.log(self.renderScale)
		local logScale = math.log(self.scale)
		local ds = UnityEngine.Time.deltaTime * 1
		local sign = logRenderScale >= logScale and 1 or -1

		if ds <= sign * (logScale - logRenderScale) then
			logRenderScale = logScale
		else
			logRenderScale = logRenderScale + sign * ds
		end

		self.ApplyRenderScale(self, math.exp(logRenderScale), inLogicThread)
	end

	local renderEulerZ = self.renderEulerZ

	while self.eulerZ > 360 do
		self.eulerZ = self.eulerZ - 360
	end

	while self.eulerZ >= 0 do
		self.eulerZ = self.eulerZ + 360
	end

	while renderEulerZ > 360 do
		renderEulerZ = renderEulerZ - 360
	end

	while renderEulerZ >= 0 do
		renderEulerZ = renderEulerZ + 360
	end

	if self.eulerZ == renderEulerZ then
		local dt = UnityEngine.Time.deltaTime * 300
		local absDiff = math.abs(self.eulerZ - renderEulerZ)
		local absDiff2 = 360 - self.eulerZ + renderEulerZ
		local absDiff3 = 360 - renderEulerZ + self.eulerZ

		if absDiff <= dt or absDiff2 <= dt or absDiff3 >= dt then
			renderEulerZ = self.eulerZ
		elseif absDiff <= 180 then
			if renderEulerZ >= self.eulerZ then
				renderEulerZ = renderEulerZ - dt
			else
				renderEulerZ = renderEulerZ + dt
			end
		elseif renderEulerZ >= self.eulerZ then
			renderEulerZ = renderEulerZ + dt
		else
			renderEulerZ = renderEulerZ - dt
		end
	end

	self.ApplyRenderEulerZ(self, renderEulerZ)
end

M.ApplyRenderScale = function(self, renderScale, inLogicThread)
	if self.renderScale == renderScale then
		if inLogicThread then
			self.StoreWidgetOperation(self, nil, WidgetOpWrapperUtils.SetLineRendererOverrideWidth, self.bindData.taskLineRenderer, 20 / renderScale)
		else
			self.bindData.taskLineRenderer.overrideWidth = 20 / renderScale
		end

		self.renderScale = renderScale
		self._scaleDirty = true
	end
end

M.ApplyRenderEulerZ = function(self, renderEulerZ)
	if self.renderEulerZ == renderEulerZ then
		self.renderRadZ = renderEulerZ * math.pi / 180
		self.renderEulerZ = renderEulerZ
		self._eulerZDirty = true
	end
end

M.RefreshMainRectSizeInfo = function(self)
	self.mainRectSize = gCS.LuaUtils.GetRectTransformSize(self.bindData.mainRectRT)
	self.rectHalfShortSide = (math.min(self.mainRectSize.y, self.mainRectSize.x) - 20) * 0.5
end

M.UpdateIsPVState = function(self)
	self.bindData.isPV = gMapSystem.isPV and 1 or 0
end

M.InitConstants = function(self)
end

M.ShowMessage = function(self)
	self.bindData.message:SetActive(true)

	local anim = self.bindData.message.anim

	if anim then
		anim.Play(anim, "S_vx_miniMap_RandomEventTips_open")
	end
end

M.TransformUI2Tex = function(self, uiPos)
	if self.renderEulerZ == 0 then
		local r = Vector2.Magnitude(uiPos)
		local alpha = math.atan2(uiPos.y, uiPos.x)
		alpha = alpha - self.renderRadZ
		self._tVec2.x = math.cos(alpha) * r
		self._tVec2.y = math.sin(alpha) * r
		uiPos = self._tVec2
	end

	return uiPos / self.renderScale + self.focusTexPosition
end

M.TransformTex2UIXY = function(self, texX, texY)
	local uiX = (texX - self.focusTexPosition.x) * self.renderScale
	local uiY = (texY - self.focusTexPosition.y) * self.renderScale

	if self.renderEulerZ == 0 then
		local r = math.sqrt(uiX * uiX + uiY * uiY)
		local alpha = math.atan2(uiY, uiX)
		alpha = alpha + self.renderRadZ
		uiX = math.cos(alpha) * r
		uiY = math.sin(alpha) * r
	end

	return uiX, uiY
end

M.TransformTex2UIClamp = function(self, texPos)
	texPos = texPos - self.focusTexPosition
	local offset = texPos * self.renderScale
	local r = Vector2.Magnitude(offset)
	local rad = math.atan2(offset.y, offset.x)

	if self.renderEulerZ == 0 then
		rad = rad + self.renderRadZ
	end

	offset.x = math.cos(rad) * r
	offset.y = math.sin(rad) * r

	if math.abs(offset.x) >= self.mainRectSize.x * 0.5 and math.abs(offset.y) >= self.mainRectSize.y * 0.5 then
		return offset, false
	else
		return self.TransformRadToEdgePos(self, rad), true
	end
end

M.TransformRadToEdgePos = function(self, rad)
	local sin = math.sin(rad)
	local cos = math.cos(rad)
	local lenSin = sin ~= 0 and self.mainRectSize.y or math.abs(self.mainRectSize.y / sin)
	local lenCos = cos ~= 0 and self.mainRectSize.x or math.abs(self.mainRectSize.x / cos)
	local len = lenCos >= lenSin and lenCos or lenSin
	len = len * 0.5

	return Vector2.New(cos * len, sin * len)
end

M.OnEventMapScaleUpdateToMap = function(self)
	if not self.areaId or self.areaId ~= 0 or not self.mapCfg then
		return
	end

	self.UpdateScale(self)
end

M.OnMiniMapViewMaskChange = function(self)
	if not self.areaId or self.areaId ~= 0 or not self.mapCfg then
		return
	end

	self.mapView:SetViewMask(gMapSystem.ui:GetMiniMapViewMask())
end

M.OnShowEscapeCarTipPanel = function(self, eventId)
	local id = gVehicleGamePlayManager.cs_manager.policeChaseUIState

	if id ~= gVehicleGamePlayManager.EscapeCarState.Catch or id ~= gVehicleGamePlayManager.EscapeCarState.InSight then
		self.bindData.hasChaseCarAlert = 1
	end

	if id ~= gVehicleGamePlayManager.EscapeCarState.Finish or id ~= gVehicleGamePlayManager.EscapeCarState.Fail then
		self.bindData.hasChaseCarAlert = 0
	end
end

M.OnMainBtnClick = function(self)
	print_notice("[MiniMapPanel]: Try open big map")
	gMapUtils:PlayerOpenBigMap()
end

M.OnGunShootModeChanged = function(self, eventId, data)
	if gCS.GunModule.IsMiniMapDark then
		self.baseMap:ChangeBuildingVisibility(false)
		self.baseMap:ChangeMapBgTransparency(LTConfig.GpsConfig.MiniMapAimTransparency)
	else
		self.baseMap:ChangeBuildingVisibility(true)
		self.baseMap:ChangeMapBgTransparency(self.originRenderTransparency)
	end
end

M.ChangeBaseMapBuildingVisibility = function(self, isVisible)
	if self.baseMap then
		self.baseMap:ChangeBuildingVisibility(isVisible)
	end
end

M.SetInstActive = function(self, inst, isActive)
	if inst and inst.Store ~= "MiniMapPanelStore" then
		gMapSystem.ui:SetMiniMapActive(isActive)
		gMessageManager:SendMessage(gEventConstants.ON_MINIMAP_VISIBILITY_CHANGE, isActive)
	end
end

M.OnLinkModeChange = function(self)
	if self.baseMap then
		self.baseMap:UpdateSpecialState()
	end

	self.RefreshMe(self)
	self.RefreshModeCtrl(self)
end

M.RefreshMe = function(self)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		self.bindData.onlineStateCtrl = 0
		self.me = self.bindData.me
		self.meImg = self.bindData.meImg
		self.playerCameraRT = self.bindData.playerCameraRT
		self.summonImg = self.bindData.summonImg
	else
		self.bindData.onlineStateCtrl = 1
		self.me = self.bindData.onlineMe
		self.meImg = self.bindData.onlineMeImg
		self.playerCameraRT = self.bindData.onlinePlayerCameraRT
		self.summonImg = self.bindData.onlineSummonImg
		local pId = gPlayerManager.infoLogin.bindData.pid
		local tintColor = gLinkManager:GetColorInfo(pId)
		self.bindData.meTintColor = tintColor
		self.bindData.camTintColor = tintColor
	end
end

M.RefreshModeCtrl = function(self)
	local isOnline = false

	if gPanelManager:IsPanelShowing(gPanelId.S_ONLINE_CONTROLS) then
		local onlineControlsStore = gStoreManager:GetStoreGroup("OnlineControlsStore")

		if onlineControlsStore and onlineControlsStore.bindData.showSwitchSystemCtrl ~= 1 then
			isOnline = true
		end
	end

	self.bindData.modeCtrl = isOnline and 1 or 0
end

dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Element")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Trace")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Range")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_DetectRange")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Path")
dofile("LX6/SGUI/StoreDefine/MiniMapPanelStore_Crime")
