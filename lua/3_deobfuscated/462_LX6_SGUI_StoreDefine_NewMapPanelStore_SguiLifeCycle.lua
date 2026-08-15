local GameInputManager = LX6.Manager.GameInputManager
local M = C_NewMapPanelStore

function M:ctor()
	self._stateProps = {}
end

function M:OnAwake()
	self:InitConstants()
	self:InitPlatform()
	self:InitLayers()

	self.bindData.elementListBtn.luaClick = self:CreateAction("OnElementListBtnClick")
	self.bindData.onCloseBtn = self:CreateAction("OnBtnClose")

	self:InitMainRectInteraction()

	self.controllerPointerAnim = self.bindData.controllerPointer:GetComponent(typeof(UnityEngine.Animation))
	self.bindData.controllerAttachList.luaSimpleRenderItem = self:CreateAction("OnRenderControllerAttachItem")

	function self.bindData.controllerAttachList.luaSelectedChanged(list)
		if not self.controllerAttachCtx then
			return
		end

		local oldId = self.controllerAttachCtx.ids[self.controllerAttachCtx.curIdx]
		self.controllerAttachCtx.curIdx = list.selectedIndex + 1
		local newId = self.controllerAttachCtx.ids[self.controllerAttachCtx.curIdx]

		self:ClearShowMask(oldId, EBigMapElementShowMask.ControllerAttach)
		self:SetShowMask(newId, EBigMapElementShowMask.ControllerAttach)
		self:PlayQueueControllerPointerAnim()
	end

	self.bindData.controllerAttachSelectBtn.luaClick = self:CreateAction("OnClickControllerAttachSelect")
	self.bindData.controllerAttachActionBtn1.luaClick = self:CreateAction("OnClickControllerAttachAction1")
	self.bindData.meIndicatorRoot.luaClick = self:CreateAction("OnClickMeIndicator")
	self.bindData.blockList.onGetTIndex = self:CreateAction("OnGetTIndex0")
	self.bindData.blockList.luaRenderItem = self:CreateAction("OnRenderBlockNameItem")
	self.inputActions = {
		[gInputActionId.UIBIGMAP_SCALE] = function (ctx)
			self:OnScroll(ctx)
		end,
		[gInputActionId.UIBIGMAP_FASTACTION_1] = function (ctx)
			self:OnHoverFastActionBtn(ctx)
		end
	}
	self.eventHandlers = {
		[gEventConstants.BIG_MAP_FILTER_UPDATE] = self:CreateAction("OnFilterSettingsChanged"),
		[gEventConstants.REMOVE_GPS] = self:CreateAction("OnRemoveGps")
	}
end

function M:OnStart()
	local matchStore = gStoreManager:GetStoreGroup("NewMapPanelStore_Match"):GetStoreByWidget(self.bindData.matchScrollRect.content)
	self.matchList = matchStore.list
	self.matchList.luaRenderItem = self:CreateAction("OnRenderCandidateItem")
	self.matchList.luaClick = self:CreateAction("OnClickCandidateItem")
	matchStore.escBtn.luaClick = self:CreateAction("HideCandidatePanel")
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	self.tickable = false
end

function M:OnFirstShow()
	print_debug("[NewMapPanelStore]: OnFirstShow")

	self._pressTime = os.clock()
	self.scale = 1
	self.mapPos = Vector2.zero
	self.curScaleLevel = 4
	self.dynamicScaleLevel = self.curScaleLevel
	self.raidId = nil
	self.indoorId = nil
	self.areaId = nil
	self.selectedGpsId = nil
	self._scrollConflictAreas = {}

	self:ResetControllerInput()
	self.bindData.tmp_onceSelectEffectRoot:SetActive(false)
	self.bindData.chooseAnimRoot:SetActive(false)
	self:InitTracing()
	self:InitMapElement()
	self:InitOperation()
	self:InitRangeObject()
	self:InitInteraction()
	self:InitFilter()
	self:InitControllerKeyConflict()
	self:InitComponents()
	self:InitFSM()
	self:PostInitFilter()

	self.isRunning = false
	self.isTrigger = false
	SGUI.UNavigationMgrEx.Inst.luaGamePadTouchChanged = self:CreateAction("luaGamePadTouchChanged")

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.ShowMainPageCtrl = 0
		self.bindData.MobileShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_NEW_MAP_PANEL) and 1 or 0
	else
		self.bindData.MobileShowMainPageCtrl = 0
		self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_NEW_MAP_PANEL) and 1 or 0
	end

	gMapSystem.ui:TryAddUI("BigMap", self)
	gMapSystem.trace:DisableRemoveTrace()
	self:InitSubStores()
	self:InitAction()
	self:RegisterMessageEvents(self.eventHandlers)

	for inputActionId, func in pairs(self.inputActions) do
		GameInputManager.RegisterInputCallback(inputActionId, func)
	end

	self:SetupHoverActionCtx(nil)

	if self.mapView then
		self.mapView:Dispose()

		self.mapView = nil

		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView should be disposed before creating a new one")
	end

	gMapSystem.ui.bigMapInterestSource:ClearAllElement()

	local viewCfg = MapView.GetDefaultConfig()
	viewCfg.viewMask = self:GetViewMask()
	viewCfg.openAllGateBetweenBigMaps = true
	viewCfg.skipImportantTaskSpiritFilter = true
	viewCfg.useBigMapSpiritFilter = true
	self.mapView = MapView.CreateView("BigMap", viewCfg)

	self.mapView:AddStage(self.mapView.defaultFogStage)
	self.mapView:Commit()
	self.mapView:ConnectTraceSource()

	local guideInterest = gMapSystem.ui:GetAllBigMapGuideInterest()

	if guideInterest then
		for _, instanceId in ipairs(guideInterest) do
			local element = gMapSystem.container:Get(instanceId)

			if element then
				gMapSystem.ui.bigMapInterestSource:AddElement(instanceId)
			end
		end
	end

	self.mapView:ConnectSource(gMapSystem.ui.bigMapInterestSource)
	self.mapView:RegisterListener(function (instanceId)
		self:AddElement(instanceId)
	end, function (instanceId)
		self:RemoveElement(instanceId)
	end, function (instanceId)
		self:UpdateElement(instanceId)
	end)
	self:SetFilterSpiritTid(gSpiritManager:GetCurFirstSpiritTid())
end

function M:OnShow(panelId, data)
	if not self.STATE_OnShowOnce then
		self:OnFirstShow()
	end

	self.showContext = {}

	gMapSystem.ui:OnBigMapOpen()
	gPanelManager:Close(gPanelId.S_ITEM_INFO_PANEL)

	if data and data.fromMainPageSwitch then
		self.bindData.rootAnim:Play(self.OPEN_ANIM_NAME_FOR_JH_SWITCH)
	elseif self.bindData.ShowMainPageCtrl == 1 then
		self.bindData.rootAnim:Play(self.OPEN_ANIM_NAME_FOR_MAIN_PAGE)
	else
		self.bindData.rootAnim:Play(self.OPEN_ANIM_NAME)
	end

	self:SetEnableController(SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice())

	self._onCloseCbs = {}
	self._closeByBtn = false

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.BigMapUseAllView) then
		self:SetOverrideViewMask(EMapViewMask.DebugAll)
	elseif gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.BigMapUseRangeEventView) then
		self:SetOverrideViewMask(EMapViewMask.RangeEvent)
	end

	self:PreHandleParams(data)
	self:InitMapAreaListData()
	self:HandleAutoSelect()

	local raidId = self.params.raidId or LTConfig.RaidConfig.WorldMap
	local indoorId = self.params.indoorId or 0
	local areaId = gMapAreaMgr:GetAreaId(raidId, indoorId)

	self:ActiveArea(areaId)
	self:RecoverSpiritList()

	self.tickable = true
	self.bindData.MetroModeCtrl = self:CheckCanTeleport() and data and data.metroMode and self.compRefs and self.compRefs.MetroView.actived and (not self.showContext.currentEnteringMetroId or self.showContext.currentEnteringMetroId == 0) and 1 or 0
end

function M:OnClose()
	self.tickable = false
	self.activeFilterGroup = nil
	self.filterCharacterTid = nil

	table.clear(self._stateProps)

	if self.areaId then
		self:CloseMap(self.areaId)
	end

	self:SetViewMask(0)
	print_debug("[NewMapPanelStore]: OnClose]")

	if self._onCloseCbs then
		for _, cb in ipairs(self._onCloseCbs) do
			cb()
		end
	end

	gMapSystem.ui:TryRemoveUI("BigMap")
	gMapSystem.ui.bigMapInterestSource:ClearAllElement()

	if self.mapView then
		self.mapView:Dispose()

		self.mapView = nil
	end

	SGUI.UNavigationMgrEx.Inst.luaGamePadTouchChanged = nil

	self:DestroyComponents()
	self:ClearFSM()
	self:CancelChooseAnim()
	gMapSystem.trace:EnableRemoveTrace()
	self:ClearMessageEvents()

	for inputActionId, func in pairs(self.inputActions) do
		GameInputManager.UnregisterInputCallback(inputActionId, func)
	end
end

function M:OnDestroy()
	self.tickable = false
end

function M:CheckCanTeleport()
	if gDriveVehiclesManager.cs_manager.isDriveMode then
		return false
	end

	return true
end
