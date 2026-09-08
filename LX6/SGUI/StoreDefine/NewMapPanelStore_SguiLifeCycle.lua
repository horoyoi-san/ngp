-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_SguiLifeCycle.lua
-- Decompiled from: 00989_NewMapPanelStore_SguiLifeCycle.lua_a2e5dffd2061.luajit

local GameInputManager = LX6.Manager.GameInputManager
local M = C_NewMapPanelStore

M.ctor = function(self)
	self._stateProps = {}
end

M.OnAwake = function(self)
	self:InitConstants()
	self:InitPlatform()
	self:InitLayers()

	self.bindData.elementListBtn.luaClick = self:CreateAction("OnElementListBtnClick")
	self.bindData.onCloseBtn = self:CreateAction("OnBtnClose")
	self.bindData.onMCloseBtn = self:CreateAction("OnBtnClose")

	self:InitMainRectInteraction()

	slot1 = self.bindData.controllerPointer
	self.controllerPointerAnim = slot1:GetComponent(typeof(UnityEngine.Animation))
	self.bindData.controllerAttachList.luaSimpleRenderItem = self:CreateAction("OnRenderControllerAttachItem")
	self.bindData.controllerAttachList.luaSelectedChanged = self:CreateAction("OnControllerAttachListSelectedChanged")
	self.bindData.controllerL3List.luaSimpleRenderItem = self:CreateAction("OnRenderControllerAttachItem")
	self.bindData.controllerL3List.luaSelectedChanged = self:CreateAction("OnControllerAttachListSelectedChanged")
	self.bindData.controllerAttachSelectBtn.luaClick = self:CreateAction("OnClickControllerAttachSelect")
	self.bindData.controllerAttachActionBtn1.luaClick = self:CreateAction("OnClickControllerAttachAction1")
	self.bindData.controllerL3AttachSelectBtn.luaClick = self:CreateAction("OnClickControllerAttachSelect")
	self.bindData.controllerL3AttachActionBtn1.luaClick = self:CreateAction("OnClickControllerAttachAction1")
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
		[gEventConstants.REMOVE_GPS] = self:CreateAction("OnRemoveGps"),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("RefreshPlayerAndPlayerIndicatorColor"),
		[gEventConstants.LINK_MEMBER_INFO_CHANGE] = self:CreateAction("RefreshPlayerAndPlayerIndicatorColor"),
		[gEventConstants.TEAM_REFRESH_DATA] = self:CreateAction("RefreshPlayerAndPlayerIndicatorColor")
	}
end

M.OnStart = function(self)
	local matchStore = gStoreManager:GetStoreGroup("NewMapPanelStore_Match"):GetStoreByWidget(self.bindData.matchScrollRect.content)
	self.matchList = matchStore.list
	self.matchList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderCandidateItem")
	self.matchList.luaSimpleClick = self:CreateAction("OnSimpleClickCandidateItem")
	matchStore.escBtn.luaClick = self:CreateAction("HideCandidatePanel")

	self:RefreshPlayerAndPlayerIndicatorColor()
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.tickable = false
end

M.OnFirstShow = function(self)
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

	self.SetupHoverActionCtx(self, nil)

	if self.mapView then
		self.mapView:Dispose()

		self.mapView = nil

		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView should be disposed before creating a new one")
	end

	gMapSystem.ui.bigMapInterestSource:ClearAllElement()

	local viewCfg = gBigMapHelper:GetBigMapViewCfg(self:GetViewMask())
	self.mapView = MapView.CreateView("BigMap", viewCfg)

	self.mapView:AddStage(self.mapView.defaultFogStage)
	self.mapView:Commit()
	self.mapView:ConnectTraceSource()
	self.mapView:ConnectOnlineTraceSource()

	self.mapView.belongPanel = self
	local guideInterest = gMapSystem.ui:GetAllBigMapGuideInterest()

	if guideInterest then
		for _, instanceId in ipairs(guideInterest) do
			local element = gMapSystem.container:Get(instanceId)

			if element then
				gMapSystem.ui.bigMapInterestSource:AddElement(instanceId)
			end
		end
	end

	slot3 = self.mapView

	slot3:ConnectSource(gMapSystem.ui.bigMapInterestSource)

	slot3 = self.mapView

	slot3:RegisterListener(function (instanceId)
		self:AddElement(instanceId)
	end, function (instanceId)
		self:RemoveElement(instanceId)
	end, function (instanceId)
		self:UpdateElement(instanceId)
	end)

	self.bindData.bigWorldBg.OnSetElementColor = function(areaId, minY, maxY)
		self:OnFloorChange(areaId, minY, maxY)
	end
end

M.OnShow = function(self, panelId, data)
	if not self.STATE_OnShowOnce then
		self.OnFirstShow(self)
	end

	gSoundMgr:PlaySoundByTid(70600298)

	self.showContext = {}

	gMapSystem.ui:OnBigMapOpen()
	gPanelManager:Close(gPanelId.S_ITEM_INFO_PANEL)

	if data and data.fromMainPageSwitch then
		self.bindData.rootAnim:Play(self.OPEN_ANIM_NAME_FOR_JH_SWITCH)
	elseif self.bindData.ShowMainPageCtrl ~= 1 then
		self.bindData.rootAnim:Play(self.OPEN_ANIM_NAME_FOR_MAIN_PAGE)
	else
		self.bindData.rootAnim:Play(self.OPEN_ANIM_NAME)
	end

	self:SetEnableController(SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice())

	self._onCloseCbs = {}
	self._closeByBtn = false

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.ShowDebugInfo) then
		self.showDebugInfo = true
	else
		self.showDebugInfo = nil
	end

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.BigMapUseAllView) then
		self.SetOverrideViewMask(self, EMapViewMask.DebugAll)
	elseif gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.BigMapUseRangeEventView) then
		self.SetOverrideViewMask(self, EMapViewMask.RangeEvent)
	end

	self:PreHandleParams(data)
	self:InitMapAreaListData()
	self:HandleAutoSelect()

	local raidId = self.params.raidId or LTConfig.RaidConfig.WorldMap
	local indoorId = self.params.indoorId or 0
	local areaId = gMapAreaMgr:GetAreaId(raidId, indoorId)

	self:ActiveArea(areaId)
	self:SetFilterSpiritTid(gSpiritManager:GetCurFirstSpiritTid())

	if self.params.jiamuMode then
		self:EnableJiaMuView(true)
		self:FocusFactionInfluenceAreas(self.params.focusAreaIds or self.params.focusAreaId)
	end

	self:RecoverSpiritList()

	self.tickable = true
	self.bindData.MetroModeCtrl = data and data.metroMode and self.compRefs and self.compRefs.MetroView.actived and (not self.showContext.currentEnteringMetroId or self.showContext.currentEnteringMetroId ~= 0) and self:CheckCanTeleport() and 1 or 0

	if data and data.metroMode and self.compRefs and self.compRefs.MetroView.actived and (not self.showContext.currentEnteringMetroId or self.showContext.currentEnteringMetroId ~= 0) and not self.CheckCanTeleport(self) then
		self.outOfStuckDelay = gLuaTimeMgrUtils.Delay(function ()
			self:DoOutOfStuck()
		end, LTConfig.MapentranceConfig.FakeMetroOutOfStuckDelay)
	end

	self.bindData.mA14Ctrl = 0
end

M.OnClose = function(self)
	self.tickable = false
	self.activeFilterGroup = nil
	self.filterCharacterTid = nil

	table.clear(self._stateProps)

	if self.areaId then
		self.CloseMap(self, self.areaId)
	end

	self.SetViewMask(self, 0)
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
	self:RestoreBindData()

	for inputActionId, func in pairs(self.inputActions) do
		GameInputManager.UnregisterInputCallback(inputActionId, func)
	end

	gMapSystem.notShowMainPageTabPanel = nil
end

M.OnDestroy = function(self)
	self.tickable = false
end

M.CheckCanTeleport = function(self)
	if not gMapSubSystem_Entrance:IsAnyEntraceAvaliable() then
		return false
	end

	return true
end

M.ClearOutOfStuckDelay = function(self)
	if self.outOfStuckDelay then
		gLuaTimeMgrUtils.CancelUnitDelay(self.outOfStuckDelay)

		self.outOfStuckDelay = nil
	end
end

M.DoOutOfStuck = function(self)
	self:ClearOutOfStuckDelay()
	self:DoBtnClose()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
	gClientToGameSceneDelegate:AskPlayerOutOfStuck()
end
