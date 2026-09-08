-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore.lua
-- Decompiled from: 00988_NewMapPanelStore.lua_76635ca025f9.luajit

local math = math
local MapBlockMgr = LX6.Gps.MapBlockMgr
local IndoorConfig = LTConfig.IndoorConfig
local BlockConfig = LTConfig.CollectionBlockConfig
local TaskMapPrefabResolver = require("LX6/Manager/Map/TaskMapPrefabResolver")
C_NewMapPanelStore = DefClass("C_NewMapPanelStore", C_NewMapPanelStore, C_StoreGroup)
GroupName2Class.NewMapPanelStore = C_NewMapPanelStore
local M = C_NewMapPanelStore

M.luaGamePadTouchChanged = function(self, data)
	if not self.enableController or self.controllerPointerHideMask == 0 then
		return
	end

	if data.touch1.x <= 0 and data.touch1.y <= 0 then
		self.GamePadTouchTwoFinger(self, data)
	else
		self.GamePadTouchSingleFinger(self, data)
	end
end

M.GamePadTouchSingleFinger = function(self, data)
	if not self.isGamePadTouchRunning then
		self.gamePadTouchOffset = Vector2.zero
		self.startPos = data.touch0
		self.isGamePadTouchRunning = true

		self.HideLeftHoverPanel(self)
		self.ResetControllerPointerAnim(self)
		self.ClearControllerDropdownCtx(self)
		self.SetSelected(self, nil)
	elseif self.lastPos and math.abs(data.touch0.x - self.lastPos.x) >= 2 or math.abs(self.lastPos.y - data.touch0.y) <= 2 then
		local dx = self.startPos.x - data.touch0.x
		local dy = self.startPos.y - data.touch0.y
		local dis = math.sqrt(dx * dx + dy * dy)
		local minSpeed = 0.01
		local maxSpeed = 1.5
		local speed = dis / 600

		if minSpeed <= speed then
			speed = minSpeed
		end

		if maxSpeed >= speed then
			speed = maxSpeed
		end

		self.gamePadTouchOffset = Vector2(data.touch0.x - self.lastPos.x, self.lastPos.y - data.touch0.y) * speed
	else
		self.gamePadTouchOffset = Vector2.zero
	end

	self.isGamePadTouchTrigger = true
	self.lastPos = data.touch0
end

M.GamePadTouchTwoFinger = function(self, data)
	self.currentDistance = (data.touch1 - data.touch0).magnitude

	if not self.isGamePadTouchTwoFingerRunning then
		self.lastDistance = 0
		self.gamePadTouchScale = 0
		self.isGamePadTouchTwoFingerRunning = true
	else
		local scaleFactor = self.currentDistance / self.lastDistance
		self.gamePadTouchScale = (scaleFactor - 1) * LTConfig.GameConfig.BigMapGamePadTouchGestureZoomSensitivity

		self.OnGestureZoom(self, self.gamePadTouchScale)
	end

	self.isGamePadTouchTwoFingerTrigger = true
	self.lastDistance = self.currentDistance
end

M.InitSubStores = function(self)
	self.debugPanel = gStoreManager:GetStoreGroup("BigMapStore_Debug"):GetStoreByWidget(self.bindData.debugRootWidget)
	self.elementListPanel = gStoreManager:GetStoreGroup("BigMapStore_ElementList"):GetStoreByWidget(self.bindData.elementListRootWidget)

	self.bindData.elementListRootWidget:SetActive(false)

	self.elementListPanel.onClose = self:CreateAction("HideElementList")
	self.elementListPanel.list.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderElementListItem")
	self.elementListPanel.list.luaSimpleClick = self:CreateAction("OnSimpleClickELementListItem")
	self.mapAreaListPanel = gStoreManager:GetStoreGroup("BigMapStore_MapAreaListPanel"):GetStoreByWidget(self.bindData.mapAreaListPanel)
end

M.InitAction = function(self)
	self.mapAreaListPanel.indoorSwitchBtn.luaClick = self.CreateAction(self, "OnClickIndoorSwitchBtn")
end

M.OnPreTick = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	local dt = UnityEngine.Time.deltaTime

	if self._showTimer then
		if self._showTimer >= dt then
			self._showTimer = nil

			self.bindData.rootWidget:SetActive(true)
			self.bindData.rootAnim:Play(self.OPEN_ANIM_NAME)
		else
			self._showTimer = self._showTimer - dt
		end
	end

	if self._showingAreaList then
		local store = gStoreManager:GetStoreGroup("NewMapPanelLeftPanelStore")

		if store.bActive then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = store.bindData.navArea
		end
	end

	self.PreTickController(self)
end

M.OnRenderTick = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.Tmp_TickArea(self)
	self.TickOnScaleChange(self)

	if self.enableController then
		self.AlignMapPos(self, self.controllerTexPos)

		self.bindData.controllerPointerParent.localPosition = self.controllerTexPos
	elseif not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.TickFinger(self)
	elseif self._stateProps.dragging then
		self.AlignMapPos(self, self._stateProps.dragTexPos, self.GetPointerUIPos(self))
	end

	self.TickOperation(self)
	self.TickHover(self)
	self.TickIndicatorAndPlayer(self)
	self.TickPathObjects(self)
	self.TickExtractionPathObjects(self)
	self.TickElement(self)
	self.DoComponentsOnUpdate(self)
	self.TryTickFogPoints(self)
	self.TickNavAreaChange(self)
	self.RefreshPinBtnState(self)
	self.TickDebug(self)
end

M.InitMapAreaListData = function(self)
	self.UpdateAreaListDropMenu(self)
end

M.UpdateAreaListDropMenu = function(self)
	local raidId, indoorId = gMapSystem:GetPlayerRaidIdAndIndoorId()
	local forbidIndoorSwitch = LX6.Gps.MapSystem.Instance:GetForbidIndoorSwitchState()
	local showAllArea = gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.ShowAllMapArea)

	if forbidIndoorSwitch and not showAllArea then
		self.mapAreaListPanel.isPlayerIndoor = 2
	elseif showAllArea or raidId == 0 and indoorId ~= 0 then
		self.mapAreaListPanel.isPlayerIndoor = 0
	else
		self.mapAreaListPanel.isPlayerIndoor = 1
	end
end

M.Tmp_TickArea = function(self)
	if self.areaCluster ~= MapAreaCluster.BigWorld then
		local x, y = self:TransformUIToTexXY(0, 0)
		local newRaidId = self.bindData.bigWorldBg:GetClosedRaidId(x, y)
		local newAreaId = gMapAreaMgr:GetAreaId(newRaidId, 0)

		if self.areaId == newAreaId then
			self.areaId = newAreaId

			self.UpdateAreaListDropMenu(self)
		end
	end
end

M.OnClickIndoorSwitchBtn = function(self)
	self.HideCandidatePanel(self)
	self.SetSelected(self, nil)

	if self.indoorId <= 0 then
		local indoorCfg = IndoorConfig.GetConfig(self.indoorId)

		if indoorCfg then
			self:ActiveArea(gMapAreaMgr.raidId2AreaId[indoorCfg.ParentRaid] or self.XinQiAreaId)
		else
			self.ActiveArea(self, self.XinQiAreaId)
		end
	else
		self.ActiveArea(self, gMapSystem.lastAreaId)
	end
end

M.CloseMap = function(self, areaId)
	if self.areaId == areaId then
		return
	end

	local empty = gGpsTools.GetTable()

	self.mapView:SetupBoundsByAreaId(empty)
	self.bindData.bigWorldBg:ClearAll()
	gGpsTools.ReleaseTable(empty)
	gMapSubSystem_Pin:ClearTempPin()

	if not self:IsSpecialView() and self.indoorId ~= 0 then
		gMapUtils:SaveData(self.raidId, "mapScale", self.scale)
	end
end

M.ActiveArea = function(self, areaId)
	areaId = gMapManager:GetParentAreaId(areaId)

	if self.areaId ~= areaId then
		return
	end

	self.ClearControllerDropdownCtx(self)
	self.ResetControllerPointerAnim(self)

	if self.areaId then
		self.CloseMap(self, self.areaId)
	end

	self.areaId = areaId
	local raidId, indoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
	self.raidId = raidId
	self.indoorId = indoorId

	if self.indoorId and self.indoorId <= 0 then
		self.OnIndoorStateChange(self, true)
	else
		self.OnIndoorStateChange(self, false)
	end

	self:UpdateGamePadBar()

	local areaIds = gGpsTools.GetTable()
	self.needFogPoint = nil
	local fsmSignal = nil
	local bigMapType = LTConfig.RaidConfig.GetConfig(self.raidId).BigMapType or 0

	if gMapAreaMgr:IsBigWorldAreaId(areaId) then
		MapAreaCluster.UpdateBigWorld()

		self.areaCluster = MapAreaCluster.BigWorld

		for _, id in ipairs(self.areaCluster.areaIdList) do
			table.insert(areaIds, id)
		end

		fsmSignal = EBigMapFSMSignal.EnterBigWorld

		if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.FogMap) then
			self.mapView:SetFogEnable(true)

			self.needFogPoint = true
		else
			self.mapView:SetFogEnable(nil)
		end
	elseif self.indoorId == 0 then
		areaIds[1] = areaId
		self.areaCluster = MapAreaCluster.Get({
			areaId
		})
		fsmSignal = EBigMapFSMSignal.EnterIndoor

		self.mapView:SetFogEnable(nil)

		bigMapType = 0
	else
		areaIds[1] = areaId
		self.areaCluster = MapAreaCluster.Get({
			areaId
		})
		fsmSignal = EBigMapFSMSignal.EnterOtherRaid

		self.mapView:SetFogEnable(nil)
	end

	local bigMapGroupIndex = bigMapType - 1
	local _, bigMapPath = TaskMapPrefabResolver.Resolve(self.raidId, self.indoorId)

	if bigMapPath == "" then
		self.bindData.bigWorldBg:LuaReloadAreasWithOverride(self.areaCluster.areaIdList, bigMapGroupIndex, self.areaId, bigMapPath)
	else
		self.bindData.bigWorldBg:LuaLoadAreas(self.areaCluster.areaIdList, bigMapGroupIndex)
	end

	self:RefreshIndoorFloorTab()
	self.mapView:SetupBoundsByAreaId(areaIds)
	gGpsTools.ReleaseArray(areaIds)
	self:RefreshPinBtnState()
	self:UpdateAreaListDropMenu()
	self:ClearPathInfo()
	self:RefreshCloseBtnState()
	self:InitMapConfigData()
	self:SetupBlockNames()
	self:ClearControllerDropdownCtx()
	self:ResetAlignment()

	if fsmSignal then
		self.SendFSMSignal(self, fsmSignal)
	end

	if self.indoorId <= 0 then
		local cfg = LTConfig.IndoorConfig.GetConfig(self.indoorId)

		self.SetScale(self, cfg.MapDefaultRate, true)
	elseif self.params.initScale then
		self.SetScale(self, self.params.initScale, true)

		self.params.initScale = nil
	else
		self:SetScale(gMapUtils:GetSavedDataByType(self.raidId, "mapScale"), true)
	end

	self.HideCandidatePanel(self)
	self.RefreshIndicator(self)
end

M.InitMapConfigData = function(self)
	self.mapCfg = gMapUIUtils.GetMapConfig(self.raidId, self.indoorId)
	local clampTexXMin, clampTexYMin, clampTexXMax, clampTexYMax = self.bindData.bigWorldBg:GetTexClampRange(nil, , , )
	self.clampTexMin = Vector2.New(clampTexXMin, clampTexYMin)
	self.clampTexMax = Vector2.New(clampTexXMax, clampTexYMax)
	self.areaRangeData = self.bindData.bigWorldBg:GetAllAreaRangeData()
end

M.OnIndoorStateChange = function(self, isIndoor)
	self.bindData.isMapIndoor = isIndoor and 1 or 0

	if isIndoor then
		self.SetIndoorName(self)
	end
end

M.UpdateGamePadBar = function(self)
	local src, dst = nil

	if self.bindData.isMapIndoor or self.raidId ~= LTConfig.RaidConfig.ExtractionShooter then
		self.bindData.whiteGameTips.gameObject:SetActive(true)
		self.bindData.gameTips.gameObject:SetActive(false)

		dst = self.bindData.whiteGameTips
		src = self.bindData.gameTips
	else
		self.bindData.whiteGameTips.gameObject:SetActive(false)
		self.bindData.gameTips.gameObject:SetActive(true)

		dst = self.bindData.gameTips
		src = self.bindData.whiteGameTips
	end

	gCS.LuaUtils.CopyGamePadBar(self.bindData.mainNavArea.transform, src, dst)
	self.bindData.mainNavArea:RegisterGamePadBar()
end

M.SetIndoorName = function(self)
	local indoorCfg = IndoorConfig.GetConfig(self.indoorId)

	if not indoorCfg then
		print_error("IndoorConfig not found for id:", self.indoorId)

		return
	end

	self.bindData.indoorName = indoorCfg.Name
	local blockPos = indoorCfg.Coordinate

	if table.isNilOrEmpty(blockPos) then
		print_error("#NoCreateIssue:IndoorCfg Coordinate is nil or empty, id=", self.indoorId)

		self.bindData.blockName = ""

		return
	end

	local blockId = MapBlockMgr.GetBlockIdXZ(indoorCfg.ParentRaid, blockPos[1], blockPos[3])

	if blockId and blockId <= 0 then
		local blockCfg = BlockConfig.GetConfig(blockId)

		if not blockCfg then
			print_error("BlockConfig not found for id:", blockId, " Coordinate x:" .. blockPos[1] .. " z:" .. blockPos[3])

			self.bindData.blockName = ""

			return
		end

		self.bindData.blockName = blockCfg.BlockName
	else
		print_error("#NoCreateIssue:BlockId not found for raidId:", indoorCfg.ParentRaid, " Coordinate x:" .. blockPos[1] .. " z:" .. blockPos[3])

		self.bindData.blockName = ""
	end
end

M.OnActiveDeviceChange = function(self, device)
	self:SetEnableController(SGUI.GameDevice.KeyboardMouse <= device)
	self:DoComponentsOnDeviceChange(device)
end

M.IsBigWorld = function(self)
	return self.areaCluster ~= MapAreaCluster.BigWorld
end

M.CanPin = function(self)
	return self:FilterAllowPin() and not self:IsSpecialView() and self:IsBigWorld() and not self:GetComp(EBigMapComponentType.Tooltip).actived
end

M.RefreshPinBtnState = function(self)
	if self.CanPin(self) then
		self.bindData.controllerPin:SetActive(true)
		self.bindData.pinBtn:SetActive(true)
	else
		self.bindData.controllerPin:SetActive(false)
		self.bindData.pinBtn:SetActive(false)
	end
end

M.InitLayers = function(self)
	self._rangeLayer = self.bindData.mapElementRoot:Find("Range")
	self._normalIconLayer = self.bindData.mapElementRoot:Find("NormalIcon")
	self._traceFxLayer = self.bindData.mapElementRoot:Find("TraceFx")
	self._traceIconLayer = self.bindData.mapElementRoot:Find("TraceIcon")
	self._selectedIconLayer = self.bindData.mapElementRoot:Find("SelectIcon")
	self._hoverIconLayer = self.bindData.mapElementRoot:Find("HoverIcon")
end

M.SetEnableController = function(self, enable)
	self.enableController = enable
	self.bindData.enableController = enable and 1 or 0

	self:HideCandidatePanel()
	self:ClearControllerDropdownCtx()
end

M.ResetControllerInput = function(self)
	self.ctrlerInput = {
		zoomInTrigger = 0,
		zoomOutTrigger = 0,
		zoomDir = 0
	}
end

M.GetRootSize = function(self)
	if not self.bindData.rootRT then
		return Vector2.New(1000, 1000)
	else
		return gCS.LuaUtils.GetRectTransformSize(self.bindData.rootRT)
	end
end

M.GetViewRangeSize = function(self)
	if not self.bindData.viewRangeRT then
		return Vector2.New(1000, 1000)
	else
		return gCS.LuaUtils.GetRectTransformSize(self.bindData.viewRangeRT)
	end
end

M.SetupBlockNames = function(self)
	local unlockBlocks = nil

	if self.indoorId ~= 0 then
		local enabledAreaList = self.areaCluster.areaIdList

		for _, areaId in pairs(enabledAreaList) do
			local raidId, indoorId, boundId = gMapSystem.area:SplitGBoundId(areaId)
			raidId = gMapManager:GetParentRaidId(raidId)
			local hasInfo, curUnlockBlocks = gBlockMgr:TryGetUnlockedBlocks(raidId)

			if hasInfo then
				if not unlockBlocks then
					unlockBlocks = curUnlockBlocks
				else
					for _, block in ipairs(curUnlockBlocks) do
						table.insert(unlockBlocks, block)
					end
				end
			end
		end
	end

	if unlockBlocks and #unlockBlocks <= 0 then
		self._local_blockNames = {}

		for _, block in ipairs(unlockBlocks) do
			local raidCfg = LTConfig.RaidConfig.GetConfig(block.raidId)

			if not raidCfg then
				-- Nothing
			else
				local sceneId = raidCfg.SceneId

				if not gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.FogMap) or not LX6.Gps.MapFogDataMgr.IsInFog(sceneId, block.worldPos.x, block.worldPos.z) then
					slot13 = gMapSystem.area
					local texPos = self:TransformWorldToTex(block.worldPos, slot13:GetAreaId(block.raidId, 0))

					table.insert(self._local_blockNames, {
						name = block.name,
						texPos = texPos
					})
				end
			end
		end

		self.bindData.blockList:SetList(#self._local_blockNames)
	else
		self._local_blockNames = nil

		self.bindData.blockList:SetList(0)
	end
end

M.OnRenderBlockNameItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local store = gStoreManager:GetStoreGroup("MapSimpleLabelStore"):GetStoreByWidget(btn)
	store.text = self._local_blockNames[index].name
	btn.localPosition = self._local_blockNames[index].texPos
end

M.TickOnScaleChangeMapLabels = function(self, uniformScale)
	if self.curScaleLevel < 1 then
		self.bindData.blockList:SetActive(false)
		self.bindData.zoneList:SetActive(true)

		for i = 0, self.bindData.zoneList.dataCount - 1 do
			local hasWidget, widget = self.bindData.zoneList:TryGetChildAt(i, nil)

			if hasWidget then
				local rt = widget.rectTransform

				rt.SetLocalScaleXY(rt, uniformScale, uniformScale)
			end
		end
	else
		for i = 0, self.bindData.blockList.dataCount - 1 do
			local hasWidget, widget = self.bindData.blockList:TryGetChildAt(i, nil)

			if hasWidget then
				local rt = widget.rectTransform

				rt.SetLocalScaleXY(rt, uniformScale, uniformScale)
			end
		end

		self.bindData.blockList:SetActive(true)
		self.bindData.zoneList:SetActive(false)
	end
end

M.ShowMapAreaList = function(self)
	self._showingAreaList = true
end

M.HideLeftHoverPanel = function(self)
	self._showingAreaList = false
end

M.InitConstants = function(self)
	self.OPEN_ANIM_NAME = "s_vx_newmap_open"
	self.OPEN_ANIM_NAME_FOR_MAIN_PAGE = "s_vx_newmap_open02"
	self.OPEN_ANIM_NAME_FOR_JH_SWITCH = "s_vx_newmap_jh_cut"
	self.CLOSE_ANIM_NAME = "s_vx_newmap_close"
	self.HOVER_FOCUS = "S_vx_newmap_Selected_open"
	self.HOVER_LOOP = "S_vx_newmap_Selected_loop"
	self.ONLY_ONCE_SELECT_ANIM_NAME = "s_vx_Selected_circle_open"
	self.CONTROLLER_POINTER_OPEN = "s_vx_Controller_mouse_open"
	self.CONTROLLER_POINTER_LOOP = "s_vx_Controller_mouse_loop"
	self.CONTROLLER_ATTACH_ICON_OPEN = "S_vx_MapIcon_Controller_open"
	self.CONTROLLER_ATTACH_ICON_CLOSE = "S_vx_MapIcon_Controller_close"
	self.MAGIC_HOVER_RADIUS = 50
	self.CONTROLLER_ATTACH_RANGE = 100
	self.DELAY_TIME = 0
	self.SCROLL_SCALE = 0.001
	self.CONTROLLER_ZOOM_SCALE = 1
	self.CONTROLLER_POINTER_SENSITIVITY = LTConfig.GameConfig.BigMapControllerPointerSensitivity
	self.CONTROLLER_POINTER_DEAD_ZONE = LTConfig.GameConfig.BigMapControllerPointerDeadZone
	self.CONTROLLER_POINTER_ATTACH_SPEED = 500
	self.DEFAULT_SCALE_LEVEL = {}
end

M.InitPlatform = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.platformMask = EBigMapPlatformMask.Mobile
	elseif gCS.LuaUtils.IsPCPlatformOrEditorAdaptive then
		self.platformMask = EBigMapPlatformMask.PC
	elseif gCS.LuaUtils.IsPSPlatform() then
		self.platformMask = EBigMapPlatformMask.PS
	else
		print_error("Unknown platform for big map")
	end
end

M.OnBtnClose = function(self)
	if self.compRefs.MetroView.actived then
		if self.showContext.currentEnteringMetroId and self.showContext.currentEnteringMetroId <= 0 then
			self:DoBtnClose()
			gMapSubSystem_Entrance:TryTeleport(self.showContext.currentEnteringMetroId)
		elseif not self.CheckCanTeleport(self) then
			self.DoBtnClose(self)
		end

		return
	end

	self.DoBtnClose(self)
end

M.DoBtnClose = function(self)
	gMapSubSystem_Pin:ClearAllFreshState()

	SGUI.UNavigationMgrEx.Inst.luaGamePadTouchChanged = nil

	if self.bindData.ShowMainPageCtrl ~= 1 then
		gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
	else
		self.bindData.rootAnim:Play(self.CLOSE_ANIM_NAME)

		local clip = self.bindData.rootAnim:GetClip(self.CLOSE_ANIM_NAME)
		self._closeTimer = Timer.New(function ()
			clip:SampleAnimation(self.bindData.rootAnim.gameObject, 0)
			self.bindData.rootAnim:Stop(self.CLOSE_ANIM_NAME)
			gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
		end, clip.length):Start()
	end

	self.ClearOutOfStuckDelay(self)
end

M.RestoreBindData = function(self)
	self.bindData.controllerAttachIndicator:SetActive(true)
end

M.TickDebug = function(self)
	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.ShowDebugInfo) then
		self.bindData.debugRootWidget:SetActive(true)

		local uiPos = self:GetPointerUIPos()
		local texPos = self:TransformUIToTex(uiPos)
		local areaId, worldPos = self:TryTransformTexToWorld(texPos)
		local blockIdText = ""

		if gMapAreaMgr:IsBigWorldAreaId(areaId) and worldPos then
			local newBlockId = MapBlockMgr.GetBlockId(self.raidId, worldPos)
			blockIdText = ", BlockId: " .. newBlockId
			local blockUnlocked = not not gBlockMgr:IsBlockUnlocked(newBlockId)
			blockIdText = blockIdText .. ", Unlocked: " .. tostring(blockUnlocked)
		end

		worldPos = worldPos or Vector3.zero
		areaId = areaId or 0
		local debugPointerText = string.format([[
Tex Position: (%.2f, %.2f)
World Position: (%.2f, %.2f)
AreaId: %d%s
]], texPos.x, texPos.y, worldPos.x, worldPos.z, areaId, blockIdText)
		self.debugPanel.pointer.localPosition = uiPos
		self.debugPanel.pointerText = debugPointerText
	else
		self.bindData.debugRootWidget:SetActive(false)
	end
end

M.SetScale = function(self, scale, useScreenCenter, dontAlign)
	local centerUIPos, texPointerPos = nil

	if not dontAlign then
		centerUIPos = useScreenCenter and Vector2.zero or self:GetPointerUIPos()
		texPointerPos = self:TransformUIToTex(centerUIPos)
	end

	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.IgnoreScaleClamp) then
		-- Nothing
	elseif self.IsBigWorld(self) then
		local minScale, maxScale = gBigMapHelper:GetScaleRange()

		if maxScale >= scale then
			scale = maxScale
		elseif scale >= minScale then
			scale = minScale
		end
	elseif self.mapCfg.scaleData.maxScale >= scale then
		scale = self.mapCfg.scaleData.maxScale
	elseif scale >= self.mapCfg.scaleData.minScale then
		scale = self.mapCfg.scaleData.minScale
	end

	local oldScale = self.scale
	self.scale = scale

	if self.IsBigWorld(self) then
		local scaleLevel, bgScaleLevel = gBigMapHelper:GetScaleLevel(scale)
		self.curScaleLevel = scaleLevel
		self.bgScaleLevel = bgScaleLevel

		if self:IsJiaMuViewEnabled() and not self.IsSpecialView(self) then
			self.bgScaleLevel = 1
		end
	else
		self.curScaleLevel = 5
		self.bgScaleLevel = 3
	end

	self.dynamicScaleLevel = self.curScaleLevel

	self.bindData.bigWorldBg:SetScaleLevel(self.bgScaleLevel)

	if self.STATE_OnShowOnce and self.scale == oldScale then
		gSoundMgr:PlaySoundByTid(70650190)
	end

	local scaleVec = Vector3.New(scale, scale, 1)
	self.bindData.mainMapRS.localScale = scaleVec

	if not dontAlign then
		self.AlignMapPos(self, texPointerPos, centerUIPos)
	end
end

M.TryTickFogPoints = function(self)
	if not self.needFogPoint or not self.mapView then
		return
	end

	local areaFogPoints = {}

	for id, info in pairs(self._id2ElementInfo) do
		if info.showMask <= 0 and info.hideMask < info.showMask then
			local item = self.mapView:GetItemInfo(id)

			if item and not item.mapElement.fData.dontClearFog and item.resolvedWorldPos and item.resolvedGBoundId then
				local areaId = item.resolvedGBoundId
				local fogPoints = areaFogPoints[areaId]

				if not fogPoints then
					fogPoints = {}
					areaFogPoints[areaId] = fogPoints
				end

				table.insert(fogPoints, Vector2.New(item.resolvedWorldPos.x, item.resolvedWorldPos.z))
			end
		end
	end

	for areaId, points in pairs(areaFogPoints) do
		self.bindData.bigWorldBg:LuaSetFogCleanerPoints(areaId, points)
	end
end

M.TickOnScaleChange = function(self)
	local uniformScale = 1 / self.scale
	local uniformScaleVec = Vector3.New(uniformScale, uniformScale, 1)
	local uniformIconScale = LTConfig.GameConfig.MapIconDefaultRate * uniformScale
	self.bindData.selectEffect.originLocalScale = uniformScaleVec

	self.bindData.playerRT:SetLocalScaleXY(uniformScale, uniformScale)
	self.bindData.controllerPointerParent:SetLocalScaleXY(uniformScale, uniformScale)
	self:TickOnScaleChangeMapLabels(uniformScale)

	for _, info in pairs(self._id2ElementInfo) do
		self.UpdateIconScale(self, info, uniformIconScale)
	end
end

local _zeroVec2 = Vector2.zero

M.AlignMapPos = function(self, texPos, uiPos)
	uiPos = uiPos or _zeroVec2
	texPos = texPos or _zeroVec2
	local newMapPos = -texPos * self.scale + uiPos
	local newTexCenterPos = -newMapPos / self.scale
	local clampTexMin = self.clampTexMin
	local clampTexMax = self.clampTexMax

	if self:IsBigWorld() then
		local rootRTTexHalfSize = self.GetRootSize(self) / self.scale * 0.5
		clampTexMin = clampTexMin + rootRTTexHalfSize
		clampTexMax = clampTexMax - rootRTTexHalfSize
	end

	self.ClampTexPos(self, newTexCenterPos, clampTexMin, clampTexMax)

	local newMapPos = -newTexCenterPos * self.scale
	local ds = math.abs(self.mapPos.x - newMapPos.x) + math.abs(self.mapPos.y - newMapPos.y)
	self.mapPos = newMapPos
	self.bindData.mainMap.localPosition = Vector3.New(self.mapPos.x, self.mapPos.y, 0)

	if ds <= 1 then
		self.bindData.mapImageCullingMgr:LuaForceRefresh()
	end

	return ds >= 1
end

M.AlignMapPos2Finger = function(self, texPos1, uiPos1, texPos2, uiPos2)
	local newTexPos1 = self.TransformUIToTex(self, uiPos1)
	local newTexPos2 = self.TransformUIToTex(self, uiPos2)
	local d1 = newTexPos1 - texPos1
	local d2 = newTexPos2 - texPos2
	local magnitudeD1 = Vector2.Magnitude(d1)
	local magnitudeD2 = Vector2.Magnitude(d2)
	local sum = magnitudeD1 + magnitudeD2
	local t = 0.5

	if sum == 0 then
		t = magnitudeD1 / sum
	end

	local oldDist = Vector2.Magnitude(texPos1 - texPos2)
	local newDist = Vector2.Magnitude(newTexPos1 - newTexPos2)
	oldDist = math.max(oldDist, 1)
	newDist = math.max(newDist, 1)
	local sensitivity = LTConfig.GpsConfig.MobileMapScaleSensitivity

	if not sensitivity or sensitivity ~= 0 then
		sensitivity = 1
	end

	local scaleMulti = newDist / oldDist
	scaleMulti = math.exp(math.log(scaleMulti) * sensitivity)
	local scale = self.scale * scaleMulti

	self.SetScale(self, scale, true, true)

	local uiPosCenter = uiPos1 * (1 - t) + uiPos2 * t
	local oldTexCenter = texPos1 * (1 - t) + texPos2 * t

	self.AlignMapPos(self, oldTexCenter, uiPosCenter)
end

M.ResetAlignment = function(self)
	local texPos = nil

	if self.indoorId <= 0 then
		texPos = Vector2.zero
	else
		local lastAreaId = gMapManager:GetParentAreaId(gMapSystem.lastAreaId)
		local mePos = gMapAreaMgr:GetResolvedPos(gMapSystem:GetCurPlayerLocalPosition(), lastAreaId, self.areaId)

		if mePos then
			texPos = self.TransformWorldToTex(self, mePos, self.areaId)
		else
			texPos = Vector2.zero
		end
	end

	self.controllerTexPos = texPos

	self.AlignMapPos(self, texPos)
end

local _pointerUIPos = Vector2.zero
local _pointerUIPosFrameCount = 0

M.GetPointerUIPos = function(self)
	if _pointerUIPosFrameCount ~= UnityEngine.Time.frameCount then
		return _pointerUIPos
	end

	_pointerUIPosFrameCount = UnityEngine.Time.frameCount

	if self.enableController then
		_pointerUIPos = self.TransformTexToUI(self, self.controllerTexPos)
	elseif not gCS.LuaUtils.IsNonMobileAdaptive() then
		_pointerUIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRT, self.lastTouchPosition)
	else
		_pointerUIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRT, self.lastMousePosition)
	end

	if not _pointerUIPos then
		if not gGpsTools:UnitIsNull(gMapSystem.curPlayerUnit) then
			local lastAreaId = gMapManager:GetParentAreaId(gMapSystem.lastAreaId)
			local mePos = gMapAreaMgr:GetResolvedPos(gMapSystem:GetCurPlayerLocalPosition(), lastAreaId, self.areaId)
			local texPos = self:TransformWorldToTex(mePos, lastAreaId)
			_pointerUIPos = self:TransformTexToUI(texPos)
		else
			_pointerUIPos = Vector2.zero
		end
	end

	return _pointerUIPos
end

M.TryTransformTexToWorld = function(self, texPos)
	local suc, areaId, worldX, worldZ = self.bindData.bigWorldBg:LuaTryGetWorldPos(texPos.x, texPos.y, nil, , )

	if suc then
		return areaId, Vector3.New(worldX, 0, worldZ)
	else
		return nil
	end
end

M.Tmp_PinTransform = function(self, texPos)
	local suc, areaId, worldX, worldZ = self.bindData.bigWorldBg:LuaTryGetWorldPos(texPos.x, texPos.y, nil, , )

	if suc then
		return areaId, Vector3.New(worldX, 0, worldZ)
	else
		return nil
	end
end

M.TransformWorldToTex = function(self, worldPos, areaId, result)
	local suc, texX, texY = self.bindData.bigWorldBg:LuaTryGetTexPos(areaId, worldPos.x, worldPos.z, nil, )

	if not suc then
		texX = 0
		texY = 0
	end

	if not result then
		result = Vector2.New(texX, texY)
	else
		result.x = texX
		result.y = texY
	end

	return result
end

M.TransformWorldXZToTexXY = function(self, worldX, worldZ, areaId)
	local suc, texX, texY = self.bindData.bigWorldBg:LuaTryGetTexPos(areaId, worldX, worldZ, nil, )

	if suc then
		return texX, texY, true
	else
		return 0, 0, false
	end
end

M.TransformTexToUI = function(self, v)
	if not v then
		return Vector2.zero
	end

	return Vector2.New(v.x * self.scale + self.mapPos.x, v.y * self.scale + self.mapPos.y)
end

M.TransformTexToUIXY = function(self, x, y)
	return x * self.scale + self.mapPos.x, y * self.scale + self.mapPos.y
end

M.TransformUIToTex = function(self, v)
	if not v then
		return Vector2.zero
	end

	return Vector2.New((v.x - self.mapPos.x) / self.scale, (v.y - self.mapPos.y) / self.scale)
end

M.TransformUIToTexXY = function(self, x, y)
	return (x - self.mapPos.x) / self.scale, (y - self.mapPos.y) / self.scale
end

M.ClampTexPos = function(self, texPos, minTexPos, maxTexPos)
	if not texPos then
		return
	end

	if maxTexPos.x >= texPos.x then
		texPos.x = maxTexPos.x
	elseif texPos.x >= minTexPos.x then
		texPos.x = minTexPos.x
	end

	if maxTexPos.y >= texPos.y then
		texPos.y = maxTexPos.y
	elseif texPos.y >= minTexPos.y then
		texPos.y = minTexPos.y
	end
end

M.OnRenderControllerAttachItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup("NewMapPanelCandidateItemStore"):GetStoreByWidget(btn)
	local info = self.controllerAttachListRenderData[csIndex + 1]
	store.iconId = info.iconId
	store.name = info.name

	if csIndex + 1 ~= self.controllerAttachCtx.curIdx then
		self.bindData.mainNavArea.CurrentActiveContent = btn
	end
end

M.OnRenderControllerL3AttachItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup("NewMapPanelCandidateItemStore"):GetStoreByWidget(btn)
	local info = self.controllerL3AttachListRenderData[csIndex + 1]
	store.iconId = info.iconId
	store.name = info.name

	if csIndex + 1 ~= self.controllerL3AttachCtx.curIdx then
		self.bindData.mainNavArea.CurrentActiveContent = btn
	end
end

M.OnSimpleRenderCandidateItem = function(self, btn, csIndex)
	local info = self.candidateInfos and self.candidateInfos[csIndex + 1] or {}
	local store = gStoreManager:GetStoreGroup("NewMapPanelCandidateItemStore"):GetStoreByWidget(btn)
	store.iconId = info.iconId
	store.name = info.name
end

M.OnSimpleClickCandidateItem = function(self, btn, index)
	local info = self.candidateInfos and self.candidateInfos[index + 1] or {}

	self:SetSelected(info.gpsId, EBigMapSelectSource.CandidatePanel)
	self:HideCandidatePanel()
end

M.OnGetTIndex0 = function(self, csIndex)
	if self.raidId ~= LTConfig.RaidConfig.ExtractionShooter then
		return 1
	else
		return 0
	end
end

M.SetFilterSpiritTid = function(self, tid)
	self.filterCharacterTid = tid

	self.mapView:SetFilterSpiritId(tid)
	gMapSubSystem_Task:UpdateAllElementsFilterTag(tid)

	for id, info in pairs(self._id2ElementInfo) do
		self.CheckTaskElementShowSwitch(self, info)
	end

	self.NotifyCompsOnFilterSpiritChange(self, tid)

	if self._filterCore then
		self._filterCore:ApplyAutoActiveGroups()
	end
end

M.RecoverSpiritList = function(self)
	if self.compRefs and self.compRefs.SwitchBigMapSpirit then
		self.compRefs.SwitchBigMapSpirit:RecoverList()
	end
end

local luaUtils = gCS.LuaUtils
local UnityInput = UnityEngine.Input

M.RegisterScrollConflictArea = function(self, key, areaGetter)
	self._scrollConflictAreas[key] = areaGetter
end

M.UnregisterScrollConflictArea = function(self, key)
	self._scrollConflictAreas[key] = nil
end

M.CheckMouseScrollConflict = function(self)
	if self.enableController or not luaUtils.IsNonMobileAdaptive() then
		return false
	end

	for _, areaGetter in pairs(self._scrollConflictAreas) do
		local rect = areaGetter()

		if rect and luaUtils.RectangleContainsScreenPoint(rect, UnityInput.mousePosition) then
			return true
		end
	end

	return false
end

local CHOOSE_ANIM_NAME = "s_vx_Tracking_tips"

M.RequestChooseAnim = function(self, id)
	local info = self._id2ElementInfo[id]

	if not info then
		return
	end

	if self.DeactiveChooseAnimDelay then
		gLuaTimeMgrUtils.CancelUnitDelay(self.DeactiveChooseAnimDelay)
	end

	self._chooseAnimTargetId = id
	slot3 = self.bindData.chooseElementAnim
	local clip = slot3:GetClip(CHOOSE_ANIM_NAME)
	slot4 = self.bindData.chooseAnimRoot

	slot4:SetActive(true)

	slot4 = self.bindData.chooseElementAnim

	slot4:Stop()

	slot4 = self.bindData.chooseElementAnim

	slot4:Play(CHOOSE_ANIM_NAME)

	slot4 = self.bindData.chooseElementAnim

	slot4:Sample()

	self.DeactiveChooseAnimDelay = gLuaTimeMgrUtils.Delay(function ()
		self:CancelChooseAnim()
	end, clip.length)
	self.bindData.chooseAnimRoot.localPosition = info.texPos
end

M.CancelChooseAnim = function(self)
	if self.DeactiveChooseAnimDelay then
		gLuaTimeMgrUtils.CancelUnitDelay(self.DeactiveChooseAnimDelay)

		self.DeactiveChooseAnimDelay = nil
	end

	self._chooseAnimTargetId = nil

	self.bindData.chooseAnimRoot:SetActive(false)
end

dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_SguiLifeCycle")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_IndoorFloor")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_Element")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_Interaction")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_Trace")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_Params")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_Range")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_Path")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_ElementList")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_Filter")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_TouchInteraction")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_FSM")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_JiaMuView")
dofile("LX6/SGUI/StoreDefine/NewMapPanelStore_CustomElementRender")
