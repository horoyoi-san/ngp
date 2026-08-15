local GpsConfig = LTConfig.GpsConfig
local MainViewUtils = LX6.Gps.MainViewUtils
C_HudGpsPanelStore = DefClass("C_HudGpsPanelStore", C_HudGpsPanelStore, C_StoreGroup)
GroupName2Class.HudGpsPanelStore = C_HudGpsPanelStore
local M = C_HudGpsPanelStore
local LuaUtils = gCS.LuaUtils

function M:ctor()
	self.eventListener = {
		[gEventConstants.MINIMAP_ICON_SWITCH_SUBSCRIPT_CHANGE] = self:CreateAction("UpdateSwitchSubscript"),
		[gEventConstants.GAMERULE_TARGET_DISTANCE_WARNNING] = self:CreateAction("OnTargetDistanceWarning")
	}
end

function M:OnAwake()
	return
end

function M:OnEnable()
	LX6.Gps.MainViewUtils.AdjustRTForHudGps(self.bindData.ellipseRT)
end

function M:OnStart()
	return
end

function M:OnDisable()
	self.tickable = false
end

function M:OnDestroy()
	self.tickable = false
end

function M:OnGroupEnable()
	gMapSystem.ui.hudEllipseRT = self.bindData.ellipseRT

	gMapSystem.ui:TryAddUI("HudGps", self)
	self:RegisterMessageEvents(self.eventListener)

	self._elementInfos = {}
	local viewerCfg = MapView.GetDefaultConfig()
	viewerCfg.viewMask = EMapViewMask.HudGps + EMapViewMask.NearBy
	viewerCfg.delayAddAndRemove = false
	viewerCfg.needBoundSource = false
	viewerCfg.ignoreInterestInGateStage = true
	self.view = MapView.CreateView("HudGps", viewerCfg)

	self.view:Commit()
	self.view:ConnectTraceSource()
	self.view:RegisterListener(function (instanceId)
		self:AddElement(instanceId)
	end, function (instanceId)
		self:RemoveElement(instanceId)
	end, function (instanceId)
		return
	end)

	self.tickable = true
end

function M:OnGroupDisable()
	if self.view then
		self.view:Dispose()
	end

	gMapSystem.ui.hudEllipseRT = nil

	gMapSystem.ui:TryRemoveUI("HudGps")
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.tickable = true
end

function M:OnClose()
	self.tickable = false
end

function M:RemoveElement(id)
	if not self._elementInfos[id] then
		return
	end

	local info = self._elementInfos[id]

	self:TryHideEffect(info)
	self.bindData.gpsWidgetPool:DeleteItem(info.widget)

	self._elementInfos[id] = nil
end

function M:AddElement(id)
	local info = self._elementInfos[id]

	if info then
		return
	end

	local element = gMapSystem:GetByInstanceId(id)

	if not element then
		return
	end

	local isHudBounceIcon = array.contains(GpsConfig.HudBounceIconIds, element.mData.sIconId)

	if isHudBounceIcon then
		element.fData.hudTIndex = 7
	end

	local tIndex = element.fData.hudTIndex or 0
	local widget = self.bindData.gpsWidgetPool:CreateItem(tIndex)
	info = {}

	if widget.gameObject then
		widget.gameObject.name = "Item_" .. element.gpsId
	end

	info.mapElement = element
	info.widget = widget
	info.store = gStoreManager:GetStoreGroup("HudGpsCommonStore"):GetStoreByWidget(widget)
	info.tIndex = tIndex
	info.animTimer = 0

	if element.gpsData.sceneEffectInfo then
		info.tmp_SceneEffectInfo = {
			effectId = element.gpsData.sceneEffectInfo.effectId,
			showDistance = element.gpsData.sceneEffectInfo.showDistance
		}
	end

	local anim = info.store.loopBounceAnim

	if anim and isHudBounceIcon then
		anim:Play()
	end

	info.store:Commit("iconId", 0, COMMIT_IMMEDIATELY_WITH_CHECK)
	info.store:Commit("iconId", element.mData.sIconId, COMMIT_IMMEDIATELY_WITH_CHECK)

	if info.tIndex == 0 then
		local elementTindex = info.mapElement.miniMapData.miniMapTIndex or 0
		local switch = self:IsCurSpiritNotMatch(elementTindex)
		switch = switch and 1 or 0
		info.store.switch = switch
	end

	self._elementInfos[id] = info
end

function M:UpdateSwitchSubscript(eventId, id)
	local info = self._elementInfos[id]

	if not info then
		return
	end

	if info.tIndex ~= 0 then
		return
	end

	local store = info.store

	if store == nil or store.switch == nil then
		return
	end

	local elementTindex = info.mapElement.miniMapData.miniMapTIndex or 0
	local switch = self:IsCurSpiritNotMatch(elementTindex)
	switch = switch and 1 or 0
	store.switch = switch
end

function M:OnTargetDistanceWarning(eventId, data)
	for instanceId, info in pairs(self._elementInfos) do
		local targetType, targetId = gGpsBindingMgr:TryGetBindingInfo(instanceId)

		if targetId == data.targetId then
			info.showDistWanrning = not data.isOver

			self:UpdateTargetDistanceWarning(instanceId, info)
		end
	end
end

local CHASING_GPS_TINDEX = 1

function M:UpdateTargetDistanceWarning(instanceId, info)
	if info.tIndex ~= CHASING_GPS_TINDEX then
		return
	end

	local anim = info.store.chasingAnim

	if not anim then
		return
	end

	local animName = "S_Vx_ChasinglGPS_MissTips"

	if info.showDistWanrning then
		if info.store.startAnim and info.store.startAnim.isPlaying then
			info.store.startAnim:Stop()
		end

		anim:Play(animName)
	else
		anim:Stop()

		if info.store.startAnim then
			info.store.startAnim:Play("S_Vx_ChasinglGPS_open")
		end
	end
end

function M:OnPreTick()
	if self.view then
		self.view:SetupBoundsByRaidId(gMapSystem.lastRaidId)
	end
end

function M:OnRenderTick()
	self:TickGpsPosition()
end

local _visibleElements = {}
local _cachedWorldPos = {}

function M:TickGpsPosition()
	if not self.bActive then
		return
	end

	if L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local dt = UnityEngine.Time.fixedDeltaTime

	table.clear(_visibleElements)
	table.clear(_cachedWorldPos)

	for instanceId, info in pairs(self._elementInfos) do
		if not gMapSystem.ui:IsHudGpsEnabled() then
			_visibleElements[instanceId] = nil
		else
			local elem = info.mapElement
			local item = self.view:GetItemInfo(instanceId)
			local worldPos = item.resolvedWorldPos

			if not worldPos then
				_visibleElements[instanceId] = nil
			else
				_cachedWorldPos[instanceId] = worldPos
				local autoHideDist = elem.gpsData.tmp_HudAutoHideDistance
				local autoShowDist = elem.gpsData.tmp_HudAutoShowDistance
				local sqrDist = nil
			end
		end
	end

	gGpsBindingMgr:ClearHudBindingPids()

	for instanceId, info in pairs(self._elementInfos) do
		local elem = info.mapElement
		local targetType, targetId = gGpsBindingMgr:TryGetBindingInfo(instanceId)
		local offsetUiPosY = 0
		local visible = _visibleElements[instanceId]
		local worldPos = _cachedWorldPos[instanceId]
		local clamped, uiWorldPos, arrowEulerZ = MainViewUtils.TryEllipseClampWorldPos2UIWorldPos(worldPos, self.bindData.ellipseRT, nil, nil)

		if clamped and elem.gpsData.tmp_HideIfClamped then
			visible = false
		end

		if elem.gpsData.taskFeisuoId and gMapSubSystem_NearByMisc:CheckHasTaskFeisuo(elem.gpsData.taskFeisuoId) then
			visible = false
		end

		visible = visible or false

		if info.widget.gameObjectActive ~= visible then
			info.widget.gameObjectActive = visible

			if not visible and not elem.gpsData.tmp_IsHudDisableHintAnim and info.store.loopAnim then
				gCS.LuaUtils.SetToLastFrame(info.store.loopAnim)
			end
		end
	end
end

function M:TryShowAndUpdateEffect(info)
	if not info.tmp_SceneEffectInfo then
		return
	end

	local item = self.view:GetItemInfo(info.mapElement.instanceId)
	local oriWorldPos = nil

	if item.coordType == EMapViewerItemCoordType.AttachGate and not info.mapElement.gpsData.ignoreIndoorPenetration then
		local _, indoorId, _ = gMapSystem.area:SplitGBoundId(info.mapElement.gBoundId)

		if indoorId ~= 0 then
			oriWorldPos = item.resolvedWorldPos
		else
			oriWorldPos = info.mapElement:GetWorldPos()
		end
	else
		oriWorldPos = info.mapElement:GetWorldPos()
	end

	if not info.effectUUId or info.effectUUId == 0 then
		info.effectUUId = gCS.EffectMgr:PlayEffects(info.tmp_SceneEffectInfo.effectId or gMapSystem.DefaultGpsSceneEffect.effectId, oriWorldPos)

		gCS.EffectMgr:GetFxGoByUUId(info.effectUUId, function (go)
			self:TrySetScaleWithDistanceComp(go)
		end)
	else
		gCS.EffectMgr:SetLocalPositionByUUId(info.effectUUId, oriWorldPos)
	end
end

function M:TryHideEffect(info)
	if not info.tmp_SceneEffectInfo then
		return
	end

	if info.effectUUId and info.effectUUId ~= 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(info.effectUUId)

		info.effectUUId = nil
	end
end

function M:TrySetScaleWithDistanceComp(go)
	if LuaUtils.IsNull(go) then
		return
	end

	local comp = go:GetComponent(typeof(L18.Effect.ScaleWithDistance))

	if comp then
		comp.near = LTConfig.GameConfig.TraceLightDisappearRange
	end
end

function M:IsCurSpiritNotMatch(tIndex)
	return tIndex == 2
end

local AIR_PORT_ICON_ID = 28000806

function M:SetAirportPenertrateIcon(info)
	if gMapUtils:IsViewItemAttachingAirPort(info.mapElement.instanceId, self.view, gMapSystem.lastAreaId) then
		info.airportIcon = AIR_PORT_ICON_ID
	else
		info.airportIcon = nil
	end
end
