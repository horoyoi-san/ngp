-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HomeBuildPanelStore.lua
-- Decompiled from: 01711_HomeBuildPanelStore.lua_32399a91e861.luajit

C_HomeBuildPanelStore = DefClass("C_HomeBuildPanelStore", C_HomeBuildPanelStore, C_StoreGroup)
GroupName2Class.HomeBuildPanelStore = C_HomeBuildPanelStore
local M = C_HomeBuildPanelStore

dofile("LX6/SGUI/StoreDefine/HomeBuildPanelStore_Handler")
dofile("LX6/SGUI/StoreDefine/HomeBuildPanelStore_FurnitureList")
dofile("LX6/SGUI/StoreDefine/HomeBuildPanelStore_EditCompView")
dofile("LX6/SGUI/StoreDefine/HomeBuildPanelStore_BuildMode")
dofile("LX6/SGUI/StoreDefine/HomeBuildPanelStore_PCInput")
dofile("LX6/SGUI/StoreDefine/HomeBuildPanelStore_Floor")
dofile("LX6/SGUI/StoreDefine/HomeBuildPanelStore_Capacity")

local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local HouseConfig = LTConfig.HouseConfig
local MessageConfig = LTConfig.MessageConfig
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local HomeBuildUIUtils = gHomeBuildUIUtils
local BuildMode = gHomeBuildUIUtils.BuildMode
local AdsorptionType = gFurnitureConst.AdsorptionType
local QualityAdaptionTrafficAndAetherUnitFactor = 0
local QualityAdaptionSceneFactor = 0.7
local QualityAdaptionEffectFactor = 0.5
local QualityAdaptionDynamicGoFactor = 0.3
local QualityAdaptionGoUnitFactor = 0.5
local FenestrationPreviewIntent = {
	["\\x8f\\xa3\\xacG1\\xe86"] = "GUmnq=",
	["pVǾ\\x8f8\\xb4\\xca\\xed"] = "\\x9c8)<s\\xa2Q\\xd56\\xa9\\xbc"
}

M.ctor = function(self)
	self.furnitureDataTabList = {}
	self.inEdit = false
	self.subTypeToHouseLimitField = {
		[HouseFurnitureConfig.SubTypeType.FashionShowCase] = "FashionShowcaseCount"
	}
end

M.DefineAllVariables = function(self)
	self.curMainType = gFurnitureConst.FurnitureMainType.Furniture
	self.curSubType = 0
	self.curSubTypeList = {}
	self.editCompStore = nil
	self.isReplaceMode = false
	self.replaceModePageCtrl = nil
	self.replaceModeShowDetailEditCtrl = nil
	self.editDomain = "furniture"
	self.wallPressPending = false
	self.wallPressCanceledByDrag = false
	self.wallPressPos = nil
	self.wallDragActive = false
	self.pendingEnterWallByUnifiedClick = false
	self.enteredWallByUnifiedClick = false
	self.wallTapThresholdSqr = 100
	self.wallSessionActive = false
	self.wallSessionStartBuildIndex = 0
	self.wallSessionSelectedEdgeA = nil
	self.wallSessionSelectedEdgeB = nil
	self.wallEditCompHiddenByDrag = false
	self.furnitureEditCompHiddenByRotate = false
	self.furnitureEditCompHiddenByNoSurface = false
	self.pendingWallTexID = 0
	self.pendingSurfaceTexID = 0
	self.pendingFenestrationPrefabID = 0
	self.pendingFenestrationType = 0
	self.pendingSurfaceType = nil
	self.rightButtonsHiddenByTool = false
	self.materialUICursorActive = false
	self.materialHardwareCursorHidden = false
	self.selectedFenestrationGo = nil
	self.selectedFenestrationEdgeA = nil
	self.selectedFenestrationEdgeB = nil
	self.selectedFenestrationRuntimeID = nil
	self.selectedFenestrationFurnitureID = nil
	self.selectedFenestrationWorldPos = nil
	self.fenestrationMovePending = false
	self.pendingFenestrationMoveStartCmd = nil
	self.pendingFenestrationMoveFinalCmd = nil
	self.fenestrationDragActive = false
	self.fenestrationDragStartScreenPos = nil
	self.fenestrationDragThresholdSqr = 64
	self.fenestrationPreviewActive = false
	self.fenestrationPreviewCanPlace = false
	self.fenestrationWaitingForWallTap = false
	self.fenestrationCursorPlaceMode = true
	self.fenestrationPreviewSourcePlaceCmd = nil
	self.tempFenestrationFromFurniture = false
	self.tempFenestrationPrevMode = nil
	self.furniturePressPending = false
	self.furniturePressPos = nil
	self.furniturePressTargetType = nil
	self.furnitureTapThresholdSqr = 100
	self.pcCameraRightDragLastPos = nil
	self.WallPaintScope = {
		["\\x8d\\xa4\t\\xa7]?\\xf2?"] = 3,
		["/A\\x9f\\x89\\x8fD"] = 1,
		["H-rV"] = 2
	}
	self.wallPaintScope = self.WallPaintScope.Room
	self.SurfacePaintScope = {
		["H-rV"] = 2,
		["/A\\x9f\\x89\\x8fD"] = 1
	}
	self.surfacePaintScope = self.SurfacePaintScope.Room
	self.currentBuildMode = BuildMode.Furniture
	self.editingBuildId = 0
	local subType = HouseFurnitureConfig.SubTypeType
	self.baseSubTypeToMode = {
		[subType.Wall] = BuildMode.Wall,
		[subType.Door] = BuildMode.Door,
		[subType.Window] = BuildMode.Window,
		[subType.WallMaterial] = BuildMode.WallMaterial,
		[subType.GroundMaterial] = BuildMode.GroundMaterial,
		[subType.CeilingMaterial] = BuildMode.CeilingMaterial
	}
	self.buildModeHandlers = {
		[BuildMode.Furniture] = self.CreateAction(self, "HandleBuildModeFurniture"),
		[BuildMode.Wall] = self.CreateAction(self, "HandleBuildModeWall"),
		[BuildMode.Door] = self.CreateAction(self, "HandleBuildModeDoor"),
		[BuildMode.Window] = self.CreateAction(self, "HandleBuildModeWindow"),
		[BuildMode.WallMaterial] = self.CreateAction(self, "HandleBuildModeWallMaterial"),
		[BuildMode.GroundMaterial] = self.CreateAction(self, "HandleBuildModeGroundMaterial"),
		[BuildMode.CeilingMaterial] = self.CreateAction(self, "HandleBuildModeCeilingMaterial")
	}
	self.isFurnitureModeEnabled = true
	self.isBaseModeEnabled = true
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.InitFurnitureDataTabList(self)
	self.RegisterWidget(self)

	self.msgEvents = {
		[gEventConstants.HOME_FURNITURE_ENTER_EDIT] = self.CreateActionWithArgs(self, "ChangeEditMode", true),
		[gEventConstants.HOME_FURNITURE_EXIT_EDIT] = self.CreateActionWithArgs(self, "ChangeEditMode", false),
		[gEventConstants.HOME_FURNITURE_OPERATION_CHANGED] = self.CreateAction(self, "OnFurnitureOperationChanged"),
		[gEventConstants.HOME_FURNITURE_CAN_PLACE_CHANGED] = self.CreateAction(self, "OnCanPlaceStateChanged"),
		[gEventConstants.HOME_FURNITURE_POSITION_CHANGED] = self.CreateAction(self, "OnFurniturePositionChanged"),
		[gEventConstants.HOME_FURNITURE_CAMERA_ENTER_INDOOR] = self.CreateActionWithArgs(self, "CameraEnterIndoor", true),
		[gEventConstants.HOME_FURNITURE_CAMERA_EXIT_INDOOR] = self.CreateActionWithArgs(self, "CameraEnterIndoor", false),
		[gEventConstants.HOME_FURNITURE_CAMERA_FLOOR_CHANGED] = self.CreateAction(self, "OnCameraFloorChanged"),
		[gEventConstants.HOME_FURNITURE_NUM_CHANGE] = self.CreateAction(self, "OnFurnitureNumChange"),
		[gEventConstants.HOME_FURNITURE_EXIT_HOUSE] = self.CreateAction(self, "OnPlayerExitedEditingIndoor"),
		[gEventConstants.FINISH_REST] = self.CreateAction(self, "OnTimeChanged"),
		[gEventConstants.TIME_END_REST] = self.CreateAction(self, "OnTimeChanged"),
		[gEventConstants.PLAYER_TIME_UPDATED] = self.CreateAction(self, "OnTimeChanged")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.RegisterWidget = function(self)
	self.bindData.mainTypeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderMainTypeListItem")
	self.bindData.mainTypeList.luaSimpleClick = self.CreateAction(self, "OnClickMainTypeList")
	self.bindData.mainTypeList.onGetTIndex = self.CreateAction(self, "OnGetMainTypeListTIndex")
	self.bindData.subTypeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSubTypeListItem")
	self.bindData.subTypeList.luaSimpleClick = self.CreateAction(self, "OnClickSubTypeList")
	self.bindData.subTypeList.onGetTIndex = self.CreateAction(self, "OnGetSubTypeListTIndex")
	self.bindData.furnitureList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderFurnitureListItem")
	self.bindData.furnitureList.luaSimpleClick = self.CreateAction(self, "OnClickFurnitureList")
	self.bindData.furnitureList.onGetTIndex = self.CreateAction(self, "OnGetFurnitureListTIndex")

	if self.bindData.thirdTabList then
		self.bindData.thirdTabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderThirdTabListItem")
		self.bindData.thirdTabList.luaSimpleClick = self.CreateAction(self, "OnClickThirdTabList")
	end

	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.undoBtn.luaClick = self.CreateAction(self, "OnClickUndoBtn")
	self.bindData.redoBtn.luaClick = self.CreateAction(self, "OnClickRedoBtn")
	self.bindData.saveBtn.luaClick = self.CreateAction(self, "OnClickSaveBtn")
	self.bindData.settingBtn.luaClick = self.CreateAction(self, "OnClickSettingBtn")
	self.bindData.foldBtn.luaClick = self.CreateAction(self, "OnClickFoldBtn")

	if self.bindData.shopBtn then
		self.bindData.shopBtn.luaClick = self.CreateAction(self, "OnClickShopBtn")
	end

	self.bindData.fullScreenBtn.luaPress = self.CreateAction(self, "OnFullScreenPress")
	self.bindData.fullScreenBtn.luaRelease = self.CreateAction(self, "OnFullScreenRelease")
	self.bindData.baseToggle.luaClick = self.CreateAction(self, "OnClickBaseToggle")
	self.bindData.furnitureToggle.luaClick = self.CreateAction(self, "OnClickFurnitureToggle")
	self.bindData.loadBtn.luaRenderTooltip = self.CreateAction(self, "OnRenderLoadTooltip")
	local fullScreenBtn = SGUI.EventSystems.DragEventListener.Get(self.bindData.fullScreenBtn.gameObject)
	fullScreenBtn.onBeginDrag = self.CreateAction(self, "onBeginDrag")
	fullScreenBtn.onDrag = self.CreateAction(self, "onDrag")
	fullScreenBtn.onEndDrag = self.CreateAction(self, "onEndDrag")
	self.bindData.cameraJoyStick.luaValueChanged = self.CreateAction(self, "OnCameraJoyStickMove")
	self.bindData.cameraJoyStick.autoResetHandle = true
	self.bindData.upBtn.luaBeginLongPress = self.CreateAction(self, "OnBeginPressUpBtn")
	self.bindData.upBtn.luaEndLongPress = self.CreateAction(self, "OnEndPressUpBtn")
	self.bindData.downBtn.luaBeginLongPress = self.CreateAction(self, "OnBeginPressDownBtn")
	self.bindData.downBtn.luaEndLongPress = self.CreateAction(self, "OnEndPressDownBtn")
	self.bindData.timeBtn.luaClick = self.CreateAction(self, "OnClickTimeBtn")
	self.bindData.viewBtn.luaClick = self.CreateAction(self, "OnClickViewBtn")

	if self.bindData.floorSelector then
		self.bindData.floorSelector.luaSelectedChanged = self.CreateAction(self, "OnFloorSelectorChanged")
	end

	self.bindData.helpLineBtn.luaClick = self.CreateAction(self, "OnClickHelpLineBtn")
	self.bindData.wallBtn.luaClick = self.CreateAction(self, "OnClickWallBtn")
	self.bindData.exitEditBtn.luaClick = self.CreateAction(self, "OnClickExitEditBtn")

	if self.bindData.mouseScrollRespond then
		self.bindData.mouseScrollRespond:GetComponent(typeof(SGUI.UCustomNavRespond)).luaGamePadInputChanged = self:CreateAction("OnPCRotateMouseScroll")
	end

	local gestureListener = self.bindData.fullScreenBtn.transform:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))
	gestureListener.onZoom = self:CreateAction("OnGestureZoom")

	if self.bindData.wBtn then
		self.bindData.wBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnWASDMove", {
			false,
			1
		})
		self.bindData.wBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnWASDMove", {
			false,
			0,
			true
		})
		self.bindData.sBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnWASDMove", {
			false,
			-1
		})
		self.bindData.sBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnWASDMove", {
			false,
			0,
			false
		})
		self.bindData.aBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnWASDMove", {
			true,
			-1
		})
		self.bindData.aBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnWASDMove", {
			true,
			0,
			false
		})
		self.bindData.dBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnWASDMove", {
			true,
			1
		})
		self.bindData.dBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnWASDMove", {
			true,
			0,
			true
		})
	end
end

M.InitEditCompStore = function(self)
	self.editCompStore = gStoreManager:GetStoreGroup(self.bindData.editComp.Store):GetStoreByWidget(self.bindData.editComp)

	self.editCompStore.confirmBtn.gameObject:SetActive(true)

	self.editCompStore.cancelBtn.luaClick = self:CreateAction("OnClickCancelBtn")
	self.editCompStore.storageBtn.luaClick = self:CreateAction("OnClickStorageBtn")
	self.editCompStore.rotateBtn.luaClick = self:CreateAction("OnClickRotateBtn")
	self.editCompStore.confirmBtn.luaClick = self:CreateAction("OnClickConfirmBtn")
	self.editCompStore.copyBtn.luaClick = self:CreateAction("OnClickCopyBtn")
	self.editCompStore.replaceBtn.luaClick = self:CreateAction("OnClickReplaceBtn")
	self.editCompStore.demolishBtn.luaClick = self:CreateAction("OnClickStorageBtn")
	self.editCompStore.heightChangeBtn.luaClick = self:CreateAction("OnClickHeightChangeBtn")

	self:RefreshEditCompCtrlByDomain()
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	gFurnitureManager:SetEditPlacedFurnitureMode(false)
	gFurnitureManager:ClearSurfaceHintMesh()
	gWallEditManager:ClearFenestrationPreviewPrefab()
	self:ClearMaterialCursor()
	self:ClearMessageEvents()
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	local editorHouseId = gHouseManager:GetCurHouseId()

	gHouseSceneLayout:EnsureHouseRootGo(editorHouseId)
	gWallEditManager:AttachToHouse(editorHouseId)
	self.bindData.houseCamera.transform:SetParent(nil, false)
	self.bindData.houseCamera.gameObject:GetOrAddComponent(typeof(LX6.GUI.DestroyOnPlayModeExit))

	if editorHouseId and editorHouseId <= 0 then
		local houseCfg = LTConfig.HouseConfig.GetConfig(editorHouseId)
		local buildId = houseCfg and houseCfg.BuildId or 0
		self.bindData.houseCamera.houseId = buildId
		self.editingBuildId = buildId

		if buildId and buildId <= 0 then
			gHouseManager:ChangeFloorCeilingEnable(buildId, 0, true, false)
		end
	end

	self:InitEditCompStore()
	self:InitFloorSelector()

	self.bindData.showDetailEditCtrl = 1
	self.panelId = panelId
	self.isUp = false
	self.isDown = false
	self.isCameraJoyStickActive = false
	self.cameraJoyStickX = 0
	self.cameraJoyStickY = 0
	self.cameraJoyStickSize = 0
	self.saved = true
	self.editDomain = "furniture"
	self.isFurnitureModeEnabled = true
	self.isBaseModeEnabled = true

	self.bindData.baseToggle:SetSelected(true)
	self.bindData.furnitureToggle:SetSelected(true)

	self.bindData.foldCtrl = 0
	self.wallPaintScope = self.WallPaintScope.Room
	self.surfacePaintScope = self.SurfacePaintScope.Room
	self.bindData.showThirdTabCtrl = 1

	self:RefreshThirdTabList()

	self.isRotatingDrag = false
	self.wallPressPending = false
	self.wallPressCanceledByDrag = false
	self.wallPressPos = nil
	self.wallDragActive = false
	self.furniturePressPending = false
	self.furniturePressPos = nil
	self.furniturePressTargetType = nil
	self.pcCameraRightDragLastPos = nil
	self.wallSessionActive = false
	self.wallSessionStartBuildIndex = 0
	self.wallSessionSelectedEdgeA = nil
	self.wallSessionSelectedEdgeB = nil
	self.wallEditCompHiddenByDrag = false
	self.furnitureEditCompHiddenByRotate = false
	self.furnitureEditCompHiddenByNoSurface = false
	self.pendingFenestrationMoveStartCmd = nil
	self.pendingFenestrationMoveFinalCmd = nil
	self.fenestrationPreviewActive = false
	self.fenestrationPreviewCanPlace = false
	self.fenestrationWaitingForWallTap = false
	self.fenestrationPreviewSourcePlaceCmd = nil
	self.materialUICursorActive = false
	self.materialHardwareCursorHidden = false

	if self.bindData.cursorRT then
		self.bindData.cursorRT.gameObject:SetActive(false)
	end

	if self.bindData.cursorIconId == nil then
		self.bindData.cursorIconId = 0
	end

	self:RebuildVisibleMainTypeTabList()
	self.bindData.mainTypeList:SetSimpleList(#self.visibleMainTypeTabList)

	if #self.visibleMainTypeTabList <= 0 then
		self.bindData.mainTypeList:SelectItem(0, true)
		self:OnClickMainTypeList(nil, 0)
	else
		self.RefreshSubTypeList(self)
	end

	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("homeBuildPanel")

	cmRegister:EnableVCamera("FurnitureCamera", LX6.Cinemachine.EVcamPriority.Panel)
	LX6.Manager.GameInputManager.SetDisableInput(self.panelId, false, false, true)
	gCS.MyPlayerManager.SetTransparentAllByHouse(false)
	gCS.MyPlayerManager.EnableShadowModel(false)

	local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager

	CSFurnitureManager.SetBuildMode(true)
	CSFurnitureManager.SetQualityAdaptionEnabled(true, QualityAdaptionTrafficAndAetherUnitFactor, QualityAdaptionSceneFactor, QualityAdaptionEffectFactor, QualityAdaptionDynamicGoFactor, QualityAdaptionGoUnitFactor)
	self:UpdateTimeCtrl()
	self:ApplyCameraSensitivityFromServerConfig()

	self.bindData.houseCamera.viewMode = 0
	self.bindData.viewModeCtrl = 0
	self.bindData.helpLineModeCtrl = gFurnitureManager:GetGridModeEnabled() and 0 or 1
	self.bindData.wallDisplayModeCtrl = 0

	self:RefreshRightButtonsByEditState()
	self:UpdateUndoRedoButtonStates()
	self:RefreshSaveButtonState()
	self:CameraEnterIndoor(false)
	self:SyncCurrentBuildModeState()
	gFurnitureManager:SetGridModeEnabled(gFurnitureManager:GetGridModeEnabled())

	local houseId = gHouseManager:GetCurHouseId()

	gHouseManager:SetEditingHouseId(houseId)
	gHouseGadgetManager:EnterEditMode()

	if houseId and houseId <= 0 then
		gWallFurnitureBindingManager:ActivateForHouse(houseId)
		gWallFurnitureBindingManager:RebuildFromScene()
	end

	gFurnitureManager:SetHoverSuppressChecker(self:CreateAction("IsMouseOnHoverSuppressArea"))
	gFurnitureManager:SetHoverFurnitureFilter(self:CreateAction("IsHoverAllowedForFurniture"))
	self:RefreshLoadCtrl()
end

M.ApplyCameraSensitivityFromServerConfig = function(self)
	local houseId = gHouseManager:GetCurHouseId()

	if not houseId or houseId < 0 then
		return
	end

	local housesInfo = gPlayerManager.infoMinor.bindData.housesInfo

	if not housesInfo then
		return
	end

	local houseInfo = gHouseUtils:FindHouseInfoByHouseId(housesInfo, houseId)
	local configuration = houseInfo and houseInfo.BuildData and houseInfo.BuildData.Configuration
	local cameraConfig = configuration and configuration.Camera

	if not cameraConfig then
		return
	end

	if cameraConfig.MoveSpeed == nil then
		self.bindData.houseCamera.moveSensitivity = cameraConfig.MoveSpeed / 100
	end

	if cameraConfig.SpinSpeed == nil then
		self.bindData.houseCamera.spinSensitivity = cameraConfig.SpinSpeed / 100
	end

	if cameraConfig.ZoomSpeed == nil then
		self.bindData.houseCamera.zoomSensitivity = cameraConfig.ZoomSpeed / 100
	end
end

M.OnClose = function(self)
	if self.editingBuildId and self.editingBuildId <= 0 then
		gHouseManager:ChangeFloorCeilingEnable(self.editingBuildId, 0, true, true)

		self.editingBuildId = 0
	end

	gCS.MyPlayerManager.SetTransparentAllByHouse(true)
	gCS.MyPlayerManager.EnableShadowModel(true)
	gBuildOperationManager:ClearHistory()

	self.furnitureDataTabList = {}

	gFurnitureManager:CancelFurniturePreview()
	LX6.Manager.GameInputManager.SetEnableInput(self.panelId, false, false, true)
	self:CameraEnterIndoor(true)

	local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager

	CSFurnitureManager.SetBuildMode(false)
	CSFurnitureManager.SetQualityAdaptionEnabled(false, 1, 1, 1, 1, 1)
	gWallEditManager:ExitEditMode()
	gWallEditManager:ClearFenestrationPreviewPrefab()
	self:EndWallEditSession()
	self:ClearMaterialCursor()

	self.redoBtnStore = nil
	self.undoBtnStore = nil
	self.saveBtnStore = nil

	gHouseGadgetManager:ExitEditMode()
	gWallFurnitureBindingManager:Deactivate()
	gHouseManager:SetEditingHouseId(0)
	gFurnitureManager:SetHoverSuppressChecker(nil)
	gFurnitureManager:SetHoverFurnitureFilter(nil)

	if self.bindData and self.bindData.houseCamera and not gCS.LuaUtils.IsNull(self.bindData.houseCamera.gameObject) then
		GameObject.Destroy(self.bindData.houseCamera.gameObject)
	end
end

M.IsMouseOnHoverSuppressArea = function(self, screenPos)
	return HomeBuildUIUtils:IsScreenPosOnRayBox(self.bindData, screenPos)
end

M.IsHoverAllowedForFurniture = function(self, furnitureId)
	return self.IsEditModeAllowedForFurniture(self, furnitureId)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GetBuildInputScreenPos = function(self, eventData)
	local eventPos = eventData and eventData.position or nil

	if eventPos and eventPos.x > 0 and eventPos.y > 0 then
		return Vector3.New(eventPos.x, eventPos.y, 0)
	end

	local touchPos = gUtils:GetTouchPosition()

	if touchPos and touchPos.x > 0 and touchPos.y > 0 then
		return Vector3.New(touchPos.x, touchPos.y, 0)
	end

	local inputPos = SGUI.Utils.GetInputCenterPosition()

	if inputPos then
		return Vector3.New(inputPos.x, inputPos.y, 0)
	end

	return touchPos
end

M.OnLongPressFullScreenBtn = function(self, isPress)
	if not HomeBuildUIUtils:IsFurnitureBuildMode(self.currentBuildMode) then
		return
	end

	if isPress then
		local pos = self.GetBuildInputScreenPos(self)

		if self.TryHandlePressTargetBySingleRay(self, pos) then
			return
		end

		if gFurnitureManager.lastCanPlaceState then
			self.OnClickConfirmBtn(self)
		else
			self.OnClickCancelBtn(self)
		end

		return
	end

	gFurnitureManager:OnLongPressFullScreenBtn(false)
end

M.IsHitChildOf = function(self, hitGo, parentGo)
	if not hitGo or not parentGo or gCS.LuaUtils.IsNull(hitGo) or gCS.LuaUtils.IsNull(parentGo) then
		return false
	end

	return hitGo.transform:IsChildOf(parentGo.transform)
end

M.ResolvePressTargetBySingleRay = function(self, screenPos)
	if not screenPos then
		return nil
	end

	local camera = gCS.CameraDataMgr.MainCamera

	if not camera then
		return nil
	end

	if gFurnitureManager.isFollowing and gFurnitureManager.followingFurniture and not gCS.LuaUtils.IsNull(gFurnitureManager.followingFurniture) and gFurnitureManager:CheckMouseHitPreviewFurniture() then
		return {
			["G[ܺ\\x81\\x8c\\xd9\\xed"] = "r\\xe95\\xe2 #:\\xd1d\\xc5Y\\x89K\\xc3\\xf1"
		}
	end

	local furnitureRoot = gHouseSceneLayout:EnsureHouseNamespaceGo(gHouseManager:GetCurHouseId())
	local gridSystemProxy = gWallEditManager and gWallEditManager.gridSystemProxy or nil

	if gridSystemProxy and gCS.LuaUtils.IsNull(gridSystemProxy) then
		gridSystemProxy = nil
	end

	if furnitureRoot and not gCS.LuaUtils.IsNull(furnitureRoot) then
		gHouseCollisionUtils:EnableBoundsBoxByConfig()
	end

	if gridSystemProxy then
		gridSystemProxy.SetCeilingsCollidersEnabled(gridSystemProxy, false)
	end

	local ray = camera.ScreenPointToRay(camera, screenPos)
	local hitCount = CSFurnitureManager.RayCastNonAlloc(ray.origin, ray.direction, 100, nil, -1, true, 1)

	if furnitureRoot and not gCS.LuaUtils.IsNull(furnitureRoot) then
		CSFurnitureManager.EnableAllBoundsBox(furnitureRoot, false)
	end

	if gridSystemProxy then
		gridSystemProxy.SetCeilingsCollidersEnabled(gridSystemProxy, true)
	end

	if hitCount < 0 then
		return nil
	end

	local hasOccluder = false

	for i = 0, hitCount - 1 do
		local hitInfo = CSFurnitureManager.SortedRayCastList[i]

		if hitInfo and hitInfo.collider then
			local hitLayer, hitGoTag, hitGo, hitExtraTag = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if not hitGo then
				local wallTagIndex = gWallEditUtils:GetWallTagIndex(hitGoTag) or gWallEditUtils:GetWallTagIndex(hitExtraTag)

				if wallTagIndex then
					return nil
				end
			end

			if hitGo then
				if hitGo.name and string.sub(hitGo.name, 1, 5) ~= "Edge_" then
					local isExternal = hitGoTag ~= "HouseExternalWall" or hitExtraTag ~= "HouseExternalWall"

					if isExternal then
						return {
							["G[ܺ\\x81\\x8c\\xd9\\xed"] = "\\xfbK)\\xde\\xba~\\xb6W\\xbc\\xba",
							hitGo = hitGo
						}
					end

					return {
						["G[ܺ\\x81\\x8c\\xd9\\xed"] = "m#qW",
						hitGo = hitGo
					}
				end

				local fenestrationHitInfo = gWallEditManager:GetFenestrationHitInfo(hitGo)

				if fenestrationHitInfo and fenestrationHitInfo.nameGo then
					return {
						["G[ܺ\\x81\\x8c\\xd9\\xed"] = "is\\xa2r_\\xa6\\xe0F~sqB",
						fenestrationHitInfo = fenestrationHitInfo
					}
				end

				if gFurnitureManager.isFollowing and gFurnitureManager.followingFurniture and not gCS.LuaUtils.IsNull(gFurnitureManager.followingFurniture) then
					local rotationAxisMeshGo = gFurnitureManager.rotationAxisMeshGo

					if rotationAxisMeshGo and not gCS.LuaUtils.IsNull(rotationAxisMeshGo) and (hitGo ~= rotationAxisMeshGo or self.IsHitChildOf(self, hitGo, rotationAxisMeshGo)) then
						return {
							["G[ܺ\\x81\\x8c\\xd9\\xed"] = "&\\xdfM\\x82\\xec7\\xbc7V\\xef,#\\xf7R;\\xb6W\\x91bJ\\xbe\\xd5"
						}
					end

					local followingFurniture = gFurnitureManager.followingFurniture

					if hitGo ~= followingFurniture or self.IsHitChildOf(self, hitGo, followingFurniture) then
						return {
							["G[ܺ\\x81\\x8c\\xd9\\xed"] = "r\\xe95\\xe2 #:\\xd1d\\xc5Y\\x89K\\xc3\\xf1"
						}
					end

					if gFurnitureManager.baseMeshGo and not gCS.LuaUtils.IsNull(gFurnitureManager.baseMeshGo) and hitGo ~= gFurnitureManager.baseMeshGo then
						return {
							["G[ܺ\\x81\\x8c\\xd9\\xed"] = "r\\xe95\\xe2 #:\\xd1d\\xc5Y\\x89K\\xc3\\xf1"
						}
					end
				end

				local furnitureGo, furnitureId = gFurnitureManager:FindFurnitureRootFromHitObject(hitGo)

				if furnitureGo and furnitureId and not hasOccluder then
					return {
						["G[ܺ\\x81\\x8c\\xd9\\xed"] = "ER~gG\n =",
						furnitureGo = furnitureGo,
						furnitureId = furnitureId
					}
				end
			end

			if hitLayer ~= (LX6.Constants.LayerConstants.Floor or 8) or hitLayer ~= (LX6.Constants.LayerConstants.Wall or 16) or hitLayer ~= (LX6.Constants.LayerConstants._Ceiling or 27) then
				local skipOccluder = false

				if hitGo and not gCS.LuaUtils.IsNull(hitGo) then
					local parentTransform = hitGo.transform and hitGo.transform.parent or nil

					if parentTransform and not gCS.LuaUtils.IsNull(parentTransform) then
						local parentName = parentTransform.name

						if parentName and string.find(parentName, "sector_high") then
							skipOccluder = true
						end
					end
				end

				if not skipOccluder then
					hasOccluder = true
				end
			end
		end
	end

	return nil
end

M.TryHandleWallPressTarget = function(self, hitGo)
	if not hitGo then
		return false
	end

	if self.currentBuildMode == BuildMode.Wall then
		self.pendingEnterWallByUnifiedClick = true

		self.SwitchBuildMode(self, BuildMode.Wall)
	end

	if not gWallEditManager:SelectWallByObject(hitGo) then
		return false
	end

	self.BeginWallEditSession(self, gBuildOperationManager.currentIndex)
	self.SetWallEditCompVisible(self, true)

	return true
end

M.TryFinishFollowingFurniture = function(self)
	if not gFurnitureManager.isFollowing or not gFurnitureManager.followingFurniture or gCS.LuaUtils.IsNull(gFurnitureManager.followingFurniture) then
		return false
	end

	if gFurnitureManager.lastCanPlaceState then
		self.OnClickConfirmBtn(self)
	else
		self:ExitReplaceMode()
		gFurnitureManager:CancelFurniturePreview()
		self:ChangeEditMode(false)
	end

	return true
end

M.TryHandlePressTargetBySingleRay = function(self, screenPos)
	local target = self.ResolvePressTargetBySingleRay(self, screenPos)

	if not target then
		return false
	end

	local targetType = target.targetType

	if targetType ~= "external_wall" then
		if self.TryFinishFollowingFurniture(self) then
			return true
		end

		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseExternalWallCantSelect)

		return true
	end

	if targetType ~= "wall" then
		if self.TryFinishFollowingFurniture(self) then
			return true
		end

		return self.TryHandleWallPressTarget(self, target.hitGo)
	end

	if targetType ~= "fenestration" then
		if self.TryFinishFollowingFurniture(self) then
			return true
		end

		local success = self.TryEnterFenestrationPreviewByData(self, target.fenestrationHitInfo, screenPos)

		if not success then
			self.TryRestoreBuildModeAfterTempFenestration(self)
		end

		return success
	end

	if targetType ~= "furniture_rotation_axis" then
		gFurnitureManager:BeginRotationDrag()

		gFurnitureManager.isLongPressing = true

		return true
	end

	if targetType ~= "furniture_preview" then
		if screenPos then
			gFurnitureManager.dragStartScreenPos = Vector3.New(screenPos.x, screenPos.y, 0)
		end

		gFurnitureManager.isLongPressing = true

		return true
	end

	if targetType ~= "furniture" then
		if gFurnitureManager.isFollowing and gFurnitureManager.followingFurniture and not gCS.LuaUtils.IsNull(gFurnitureManager.followingFurniture) then
			if gFurnitureManager.lastCanPlaceState then
				self.OnClickConfirmBtn(self)
			else
				self:ExitReplaceMode()
				gFurnitureManager:CancelFurniturePreview()
				self:ChangeEditMode(false)
			end

			return true
		end

		if not self.IsEditModeAllowedForFurniture(self, target.furnitureId) then
			gDisplayMessageMgr:ShowMessage(65400629)

			return false
		end

		gFurnitureManager:StartEditingPlacedFurniture(target.furnitureGo, target.furnitureId)

		if gFurnitureManager.isFollowing then
			if screenPos then
				gFurnitureManager.dragStartScreenPos = Vector3.New(screenPos.x, screenPos.y, 0)
			end

			gFurnitureManager.isLongPressing = true

			return true
		end
	end

	return false
end

M.OnFullScreenPress = function(self)
	if self.editDomain ~= "wall" then
		local pos = self:GetBuildInputScreenPos()
		self.wallPressPending = true
		self.wallPressCanceledByDrag = false
		self.wallPressPos = pos and Vector3.New(pos.x, pos.y, 0) or nil

		return
	end

	if HomeBuildUIUtils:IsFurnitureBuildMode(self.currentBuildMode) and (not gFurnitureManager.isFollowing or not gFurnitureManager.followingFurniture or gCS.LuaUtils.IsNull(gFurnitureManager.followingFurniture)) then
		local pressPos = self.GetBuildInputScreenPos(self)
		local target = self.ResolvePressTargetBySingleRay(self, pressPos)
		self.furniturePressPending = false
		self.furniturePressPos = nil
		self.furniturePressTargetType = nil

		if target and (target.targetType ~= "furniture" or target.targetType ~= "wall" or target.targetType ~= "fenestration" or target.targetType ~= "external_wall") then
			self.furniturePressPending = true
			self.furniturePressPos = pressPos and Vector3.New(pressPos.x, pressPos.y, 0) or nil
			self.furniturePressTargetType = target.targetType
		end

		return
	end

	self.OnLongPressFullScreenBtn(self, true)
end

M.OnFullScreenRelease = function(self)
	if self.editDomain ~= "wall" then
		local pending = self.wallPressPending
		local canceledByDrag = self.wallPressCanceledByDrag
		local pressPos = self.wallPressPos
		self.wallPressPending = false
		self.wallPressCanceledByDrag = false
		self.wallPressPos = nil

		if not pending or canceledByDrag then
			return
		end

		local releasePos = self.GetBuildInputScreenPos(self)

		if pressPos and releasePos then
			local delta = releasePos - pressPos

			if self.wallTapThresholdSqr >= delta.sqrMagnitude then
				return
			end
		end

		local clickPos = releasePos or pressPos

		if self:TryFinishWallEditSessionByOutsideClick(clickPos) then
			return
		end

		if self.currentBuildMode ~= BuildMode.Wall then
			local selected, hitExternal = gWallEditManager:TrySelectWallAtScreenPos(clickPos)

			if selected then
				self.BeginWallEditSession(self, gBuildOperationManager.currentIndex)
				self.SetWallEditCompVisible(self, true)
			elseif hitExternal then
				gDisplayMessageMgr:ShowMessage(MessageConfig.HouseExternalWallCantSelect)
			end

			return
		end

		if self.currentBuildMode ~= BuildMode.WallMaterial then
			self.TryPaintWallMaterialAt(self, clickPos)

			return
		end

		if self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window then
			self.TryOperateFenestrationAt(self, clickPos)

			return
		end

		if self.currentBuildMode ~= BuildMode.GroundMaterial or self.currentBuildMode ~= BuildMode.CeilingMaterial then
			self.TryPaintSurfaceMaterialAt(self, clickPos)
		end

		return
	end

	if self.furniturePressPending then
		local pressPos = self.furniturePressPos
		local pressTargetType = self.furniturePressTargetType
		self.furniturePressPending = false
		self.furniturePressPos = nil
		self.furniturePressTargetType = nil
		local releasePos = self.GetBuildInputScreenPos(self)

		if pressPos and releasePos then
			local delta = releasePos - pressPos

			if delta.sqrMagnitude < self.furnitureTapThresholdSqr then
				local releaseTarget = self.ResolvePressTargetBySingleRay(self, releasePos)

				if releaseTarget and releaseTarget.targetType ~= pressTargetType then
					if releaseTarget.targetType ~= "furniture" and releaseTarget.furnitureGo and releaseTarget.furnitureId then
						if not self.IsEditModeAllowedForFurniture(self, releaseTarget.furnitureId) then
							gDisplayMessageMgr:ShowMessage(65400629)

							self.lastPos = nil

							return
						end

						gFurnitureManager:StartEditingPlacedFurniture(releaseTarget.furnitureGo, releaseTarget.furnitureId)

						self.lastPos = nil

						return
					end

					if releaseTarget.targetType ~= "wall" or releaseTarget.targetType ~= "fenestration" or releaseTarget.targetType ~= "external_wall" then
						self.TryHandlePressTargetBySingleRay(self, releasePos)

						self.lastPos = nil

						return
					end
				end
			end
		end
	end

	self.OnLongPressFullScreenBtn(self, false)
end

M.ChangeEditMode = function(self, isEdit)
	if isEdit ~= nil then
		isEdit = not self.inEdit
	end

	if not isEdit then
		self.ExitReplaceMode(self)
	end

	self.inEdit = isEdit

	self:RefreshPageCtrlByContext()

	self.bindData.stickPositionCtrl = self.inEdit and 1 or 0
	self.bindData.showDetailEditCtrl = self.inEdit and 0 or 1
	self.furnitureEditCompHiddenByRotate = false
	self.furnitureEditCompHiddenByNoSurface = false

	self:RefreshRightButtonsByEditState()
	self:UpdateUndoRedoButtonStates()

	if isEdit then
		self.UpdateEditButtonsState(self)
	end

	self.RefreshEditCompCtrlByDomain(self)
end

M.BeginWallEditSession = function(self, startIndex)
	self.wallSessionActive = true
	self.wallSessionStartBuildIndex = startIndex or gBuildOperationManager.currentIndex or 0

	if self.wallSessionStartBuildIndex >= 0 then
		self.wallSessionStartBuildIndex = 0
	end

	local wallData = gWallEditManager.selectedWallData
	local edges = wallData and wallData.edges
	local firstEdge = edges and edges[1]
	self.wallSessionSelectedEdgeA = firstEdge and firstEdge.a or nil
	self.wallSessionSelectedEdgeB = firstEdge and firstEdge.b or nil
end

M.EndWallEditSession = function(self)
	self.wallSessionActive = false
	self.wallSessionStartBuildIndex = 0
	self.wallSessionSelectedEdgeA = nil
	self.wallSessionSelectedEdgeB = nil
end

M.ClearSelectedFenestration = function(self)
	self.selectedFenestrationGo = nil
	self.selectedFenestrationEdgeA = nil
	self.selectedFenestrationEdgeB = nil
	self.selectedFenestrationRuntimeID = nil
	self.selectedFenestrationFurnitureID = nil
	self.selectedFenestrationWorldPos = nil
	self.fenestrationMovePending = false

	gFurnitureManager:ClearHoveredFurniture()
	self:UpdateEditButtonsState()
end

M.SetSelectedFenestrationFromPlaceCmd = function(self, placeCmd, furnitureId)
	if not placeCmd then
		return false
	end

	self.selectedFenestrationGo = nil
	self.selectedFenestrationEdgeA = tonumber(placeCmd.edgeA)
	self.selectedFenestrationEdgeB = tonumber(placeCmd.edgeB)
	self.selectedFenestrationRuntimeID = tonumber(placeCmd.runtimeID)
	self.selectedFenestrationFurnitureID = furnitureId or placeCmd.prefabID
	self.selectedFenestrationWorldPos = Vector3.New(placeCmd.centerX, placeCmd.centerY, placeCmd.centerZ)
	self.fenestrationMovePending = false

	return self.selectedFenestrationRuntimeID == nil
end

M.TrySetSelectedFenestrationByData = function(self, hitGo, rootGo, edgeA, edgeB, runtimeID, furnitureId)
	if not hitGo or gCS.LuaUtils.IsNull(hitGo) or not hitGo.name then
		return false
	end

	local parsedEdgeA = edgeA
	local parsedEdgeB = edgeB
	local parsedRuntimeID = runtimeID

	if not parsedEdgeA or not parsedEdgeB or not parsedRuntimeID then
		local _, parsedA, parsedB, parsedRuntime = string.match(hitGo.name, "^%[(%w+)%]_(-?%d+)_(-?%d+)_(%d+)$")

		if not parsedA or not parsedB or not parsedRuntime then
			return false
		end

		parsedEdgeA = tonumber(parsedA)
		parsedEdgeB = tonumber(parsedB)
		parsedRuntimeID = tonumber(parsedRuntime)
	end

	self.selectedFenestrationGo = rootGo or hitGo
	self.selectedFenestrationEdgeA = tonumber(parsedEdgeA)
	self.selectedFenestrationEdgeB = tonumber(parsedEdgeB)
	self.selectedFenestrationRuntimeID = tonumber(parsedRuntimeID)
	self.selectedFenestrationFurnitureID = furnitureId

	if rootGo and not gCS.LuaUtils.IsNull(rootGo) then
		self.selectedFenestrationWorldPos = rootGo.transform.position
	elseif hitGo and not gCS.LuaUtils.IsNull(hitGo) then
		self.selectedFenestrationWorldPos = hitGo.transform.position
	end

	self.fenestrationMovePending = false

	self.UpdateEditButtonsState(self)

	return true
end

M.ClearWallEditVisualState = function(self)
	self:StopFenestrationPreviewSession(false)

	self.wallEditCompHiddenByDrag = false

	self:SetWallEditCompVisible(false)
	gWallEditManager:ClearWallPreviewMesh()
	gWallEditManager:ClearSelectedWallState()
	self:ClearSelectedFenestration()
	self:EndWallEditSession()
end

M.FinalizeWallEditToolState = function(self, shouldSwitchToFurniture)
	self.ClearWallEditVisualState(self)
	self.ResetBuildToolSelection(self, true)
	self.TryRestoreBuildModeAfterTempFenestration(self)

	if shouldSwitchToFurniture then
		self.SwitchBuildMode(self, BuildMode.Furniture)
	end
end

M.IsWallSessionEditValid = function(self)
	return true
end

M.TryFinishWallEditSessionByOutsideClick = function(self, screenPos)
	if self.fenestrationPreviewActive then
		return false
	end

	if not self.wallSessionActive then
		return false
	end

	if HomeBuildUIUtils:IsScreenPosOnEditComp(self.bindData, screenPos) then
		return false
	end

	if gWallEditUtils:IsScreenPosOnCurrentSelectedWall(gWallEditManager, screenPos) then
		return false
	end

	if self.IsWallSessionEditValid(self) then
		self.OnClickConfirmBtn(self)
	else
		self.OnClickCancelBtn(self)
	end

	return true
end

M.OnBuildToolApplySuccess = function(self)
	self:MarkAsUnsaved()
	self:UpdateUndoRedoButtonStates()

	if HomeBuildUIUtils:IsMaterialBuildMode(self.currentBuildMode) then
		return
	end

	self.ResetBuildToolSelection(self, true)
end

M.OnWallSessionOperationApplied = function(self)
	self.UpdateUndoRedoButtonStates(self)

	if not self.wallSessionActive then
		self:BeginWallEditSession(math.max(0, (gBuildOperationManager.currentIndex or 0) - 1))
	end
end

M.HasPendingFenestrationMove = function(self)
	return self.pendingFenestrationMoveStartCmd == nil and self.pendingFenestrationMoveFinalCmd == nil
end

M.CommitPendingFenestrationMoveIfNeeded = function(self)
	if not self.HasPendingFenestrationMove(self) then
		return false
	end

	local startCmd = self.pendingFenestrationMoveStartCmd
	local finalCmd = self.pendingFenestrationMoveFinalCmd

	if startCmd.edgeA ~= finalCmd.edgeA and startCmd.edgeB ~= finalCmd.edgeB and startCmd.runtimeID ~= finalCmd.runtimeID then
		self.pendingFenestrationMoveStartCmd = nil
		self.pendingFenestrationMoveFinalCmd = nil

		return false
	end

	if not gWallEditManager:CommitFenestrationMove(startCmd, finalCmd) then
		return false
	end

	self.pendingFenestrationMoveStartCmd = nil
	self.pendingFenestrationMoveFinalCmd = nil

	return true
end

M.RevertPendingFenestrationMoveIfNeeded = function(self)
	if not self.HasPendingFenestrationMove(self) then
		return false
	end

	local startCmd = self.pendingFenestrationMoveStartCmd
	local finalCmd = self.pendingFenestrationMoveFinalCmd

	if finalCmd then
		gWallEditManager:ApplyFenestrationDeleteCmdNoHistory({
			edgeA = finalCmd.edgeA,
			edgeB = finalCmd.edgeB,
			runtimeID = finalCmd.runtimeID
		})
	end

	local reverted = gWallEditManager:ApplyFenestrationPlaceCmdNoHistory(startCmd)
	self.pendingFenestrationMoveStartCmd = nil
	self.pendingFenestrationMoveFinalCmd = nil

	return reverted
end

M.StopFenestrationPreviewSession = function(self, restoreSource)
	local shouldRestore = restoreSource ~= true and self.fenestrationPreviewSourcePlaceCmd == nil
	local sourceCmd = self.fenestrationPreviewSourcePlaceCmd
	self.fenestrationPreviewActive = false
	self.fenestrationPreviewCanPlace = false
	self.fenestrationWaitingForWallTap = false
	self.fenestrationPreviewSourcePlaceCmd = nil

	self:ClearMaterialCursor()
	gWallEditManager:ClearFenestrationPreviewPrefab()
	gWallEditManager:ClearWallPreviewMesh()

	if shouldRestore and sourceCmd then
		gWallEditManager:ApplyFenestrationPlaceCmdNoHistory(sourceCmd)
	end

	self.RefreshEditCompCtrlByDomain(self)
	self.UpdateEditButtonsState(self)
end

M.UpdateFenestrationPreviewAt = function(self, screenPos, keepWhenNoWall, previewIntent)
	if not self.fenestrationPreviewActive then
		return false
	end

	if not screenPos then
		if keepWhenNoWall then
			self.fenestrationPreviewCanPlace = false

			self.UpdateEditButtonsState(self)

			return true
		end

		return false
	end

	local intent = previewIntent or FenestrationPreviewIntent.ClickPlace
	local canPlace, hitPoint = gWallEditManager:UpdateFenestrationDragPreview(screenPos, false, intent)
	self.fenestrationPreviewCanPlace = canPlace ~= true and hitPoint == nil

	self:UpdateEditButtonsState()

	if not canPlace and not keepWhenNoWall then
		return false
	end

	return true
end

M.BeginFenestrationPreviewSession = function(self, prefabID, fenestrationType, screenPos, sourcePlaceCmd, keepWhenNoWall)
	if not prefabID or prefabID < 0 then
		return false
	end

	self:StopFenestrationPreviewSession(false)

	self.pendingFenestrationPrefabID = prefabID
	self.pendingFenestrationType = fenestrationType or self.pendingFenestrationType
	self.fenestrationPreviewSourcePlaceCmd = sourcePlaceCmd

	if sourcePlaceCmd then
		self.SetSelectedFenestrationFromPlaceCmd(self, sourcePlaceCmd, prefabID)
	else
		self.ClearSelectedFenestration(self)
	end

	self.fenestrationWaitingForWallTap = false
	self.fenestrationMovePending = false

	gWallEditManager:SetFenestrationParams(self.pendingFenestrationPrefabID, self.pendingFenestrationType)

	local spawnPos = nil

	if sourcePlaceCmd then
		spawnPos = HomeBuildUIUtils:GetFenestrationPreviewPosFromPlaceCmd(sourcePlaceCmd)
		gWallEditManager.wallPreviewFenestrationPos = spawnPos
		gWallEditManager.wallPreviewFenestrationCanPlace = true
		local dirX = sourcePlaceCmd.dirX
		local dirZ = sourcePlaceCmd.dirZ

		if dirX and dirZ and dirX * dirX + dirZ * dirZ <= 1e-06 then
			gWallEditManager.wallPreviewFenestrationYaw = math.deg(math.atan2(dirX, dirZ))
		end
	end

	if not gWallEditManager:CreateFenestrationPreviewPrefab(self.pendingFenestrationPrefabID, self.pendingFenestrationType, spawnPos, nil) then
		self.fenestrationPreviewSourcePlaceCmd = nil

		self.UpdateEditButtonsState(self)

		return false
	end

	gWallEditManager:ClearWallPreviewMesh()

	self.fenestrationPreviewActive = true

	self:SetRightButtonsVisible(false)

	self.rightButtonsHiddenByTool = true
	local initialPreviewIntent = sourcePlaceCmd and FenestrationPreviewIntent.DragMove or FenestrationPreviewIntent.ClickPlace
	local keepPreviewWithoutWall = keepWhenNoWall ~= true and sourcePlaceCmd ~= nil

	if not self:UpdateFenestrationPreviewAt(screenPos, keepPreviewWithoutWall, initialPreviewIntent) then
		self:StopFenestrationPreviewSession(sourcePlaceCmd == nil)

		return false
	end

	if not self.wallSessionActive then
		self:BeginWallEditSession(gBuildOperationManager.currentIndex or 0)
	end

	self.RefreshEditCompCtrlByDomain(self)
	self.SetWallEditCompVisible(self, true)
	self.UpdateEditButtonsState(self)

	return true
end

M.TryEnterFenestrationPreviewByData = function(self, fenestrationHitInfo, screenPos)
	if not fenestrationHitInfo or not fenestrationHitInfo.edgeA or not fenestrationHitInfo.edgeB or not fenestrationHitInfo.runtimeID then
		return false
	end

	local furnitureId = fenestrationHitInfo.furnitureId

	if not furnitureId then
		return false
	end

	local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if not cfg then
		return false
	end

	local subType = HouseFurnitureConfig.SubTypeType
	local mode = nil

	if cfg.SubType ~= subType.Door then
		mode = BuildMode.Door
	elseif cfg.SubType ~= subType.Window then
		mode = BuildMode.Window
	else
		return false
	end

	if self.currentBuildMode == mode then
		self.MarkTempFenestrationContext(self, self.currentBuildMode)
		self.SwitchBuildMode(self, mode)
	end

	self.pendingFenestrationPrefabID = furnitureId
	self.pendingFenestrationType = mode ~= BuildMode.Door and 0 or 2

	gWallEditManager:SetFenestrationParams(self.pendingFenestrationPrefabID, self.pendingFenestrationType)

	local visualPos = nil
	local sourceGo = fenestrationHitInfo.rootGo or fenestrationHitInfo.nameGo

	if sourceGo then
		visualPos = gWallEditManager:GetFenestrationVisualPosAndSize(sourceGo)
	end

	local sourceCmd = gWallEditManager:TakeFenestrationForPreview(fenestrationHitInfo.edgeA, fenestrationHitInfo.edgeB, fenestrationHitInfo.runtimeID)

	if not sourceCmd then
		return false
	end

	if visualPos then
		sourceCmd.visualX = visualPos.x
		sourceCmd.visualY = visualPos.y
		sourceCmd.visualZ = visualPos.z
	end

	local targetPos = HomeBuildUIUtils:GetFenestrationPreviewPosFromPlaceCmd(sourceCmd)

	if not targetPos then
		return false
	end

	local mainCamera = gCS.CameraDataMgr.MainCamera
	local targetScreenPos = HomeBuildUIUtils:GetScreenCenterPos()

	if mainCamera then
		local screenPoint = mainCamera.WorldToScreenPoint(mainCamera, targetPos)
		targetScreenPos = Vector3.New(screenPoint.x, screenPoint.y, 0)
	elseif screenPos then
		targetScreenPos = screenPos
	end

	if not self:BeginFenestrationPreviewSession(sourceCmd.prefabID or furnitureId, sourceCmd.fenestrationType or self.pendingFenestrationType, targetScreenPos, sourceCmd, true) then
		gWallEditManager:ApplyFenestrationPlaceCmdNoHistory(sourceCmd)

		return false
	end

	return true
end

M.TryOperateFenestrationAt = function(self, screenPos)
	if HomeBuildUIUtils:IsScreenPosOnEditComp(self.bindData, screenPos) then
		return false
	end

	if self.fenestrationWaitingForWallTap and self.pendingFenestrationPrefabID <= 0 then
		local savedPrefabID = self.pendingFenestrationPrefabID
		local savedType = self.pendingFenestrationType
		local hadCursor = self.materialUICursorActive
		local savedCursorIconId = self.bindData.cursorIconId

		if self.BeginFenestrationPreviewSession(self, savedPrefabID, savedType, screenPos, nil, false) then
			self.fenestrationWaitingForWallTap = false

			self.ClearMaterialCursor(self)

			return true
		end

		self.pendingFenestrationPrefabID = savedPrefabID
		self.pendingFenestrationType = savedType
		self.fenestrationWaitingForWallTap = true

		if hadCursor and savedCursorIconId and savedCursorIconId <= 0 then
			self.SetMaterialCursor(self, savedCursorIconId)
		end

		if gWallEditManager:IsScreenPosOnExternalWall(screenPos) then
			gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildFurnitureNotAllowed)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildOnlyAllowWall)
		end

		return true
	end

	if self.fenestrationPreviewActive then
		local clickOnCurrentFenestration = false

		if self.selectedFenestrationRuntimeID == nil then
			local hitInfo = gWallEditManager:RaycastFenestrationTarget(screenPos)

			if hitInfo and hitInfo.runtimeID ~= self.selectedFenestrationRuntimeID then
				clickOnCurrentFenestration = true
			end
		end

		if not clickOnCurrentFenestration then
			if self.fenestrationPreviewCanPlace then
				self.OnClickConfirmBtn(self)
			else
				self.OnClickCancelBtn(self)
			end

			return true
		end

		self.UpdateFenestrationPreviewAt(self, screenPos, true, FenestrationPreviewIntent.DragMove)
		self.SetWallEditCompVisible(self, true)

		return true
	end

	local fenestrationHitInfo = gWallEditManager:RaycastFenestrationTarget(screenPos)

	if fenestrationHitInfo and fenestrationHitInfo.nameGo then
		return self.TryEnterFenestrationPreviewByData(self, fenestrationHitInfo, screenPos)
	end

	if self.pendingFenestrationPrefabID < 0 then
		return false
	end

	return self.BeginFenestrationPreviewSession(self, self.pendingFenestrationPrefabID, self.pendingFenestrationType, screenPos, nil, false)
end

M.UpdateFenestrationHover = function(self, screenPos)
	if not screenPos then
		gFurnitureManager:ClearHoveredFurniture()

		return
	end

	if not self.isBaseModeEnabled then
		gFurnitureManager:ClearHoveredFurniture()

		return
	end

	local fenestrationHitInfo = gWallEditManager:RaycastFenestrationTarget(screenPos)

	if not fenestrationHitInfo or not fenestrationHitInfo.rootGo or not fenestrationHitInfo.uid then
		gFurnitureManager:ClearHoveredFurniture()

		return
	end

	gFurnitureManager:SetHoveredFurniture(fenestrationHitInfo.rootGo, fenestrationHitInfo.uid)
end

M.MarkAsUnsaved = function(self)
	self.saved = false

	self.RefreshSaveButtonState(self)
end

M.OnLateUpdate = function(self)
	if self.materialUICursorActive then
		self.HandleMaterialCursor(self)
	end
end

M.OnCameraUpdate = function(self)
	self.HandleMaterialCursor(self)
	self.HandlePCWallDragRelease(self)
	self.HandlePCCameraRightDrag(self)

	if self.inEdit and gFurnitureManager.followingFurniture and not gCS.LuaUtils.IsNull(gFurnitureManager.followingFurniture) then
		self.UpdateEditCompPositionFromWorldPos(self)
	end

	if self.editDomain ~= "wall" then
		local touchPos = self.GetBuildInputScreenPos(self)

		if self.currentBuildMode ~= BuildMode.Wall then
			gWallEditManager:UpdateHoverPreview(touchPos)
			gFurnitureManager:ClearHoveredFurniture()
		elseif self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window then
			if self.fenestrationPreviewActive then
				gFurnitureManager:ClearHoveredFurniture()
			elseif not self.fenestrationDragActive then
				self.UpdateFenestrationHover(self, touchPos)
			end
		else
			gFurnitureManager:ClearHoveredFurniture()
		end

		if self.bindData.showDetailEditCtrl ~= 0 and not self.wallEditCompHiddenByDrag then
			self.UpdateEditCompPositionForWall(self)
		end
	end
end

M.OnFurnitureOperationChanged = function(self)
	self.UpdateUndoRedoButtonStates(self)
	self.RefreshLimitCtrl(self)
	self.RefreshLoadCtrl(self)
end

M.OnClickBackBtn = function(self, btn, data)
	if self.saved then
		gPanelManager:Close(self.panelId)

		return
	end

	slot3 = gDisplayMessageMgr

	slot3:ShowMessageTriple(MessageConfig.HouseBuildSaveReconfirm, function ()
		self:OnClickSaveBtn()
		gPanelManager:Close(self.panelId)
	end, function ()
		gHouseGadgetManager:ExitEditMode()
		gHouseManager:ResetFurnitureToServerState()
		gPanelManager:Close(self.panelId)
	end, function ()
	end)
end

M.OnClickShopBtn = function(self, btn, data)
	gPanelManager:CheckShow(gPanelId.HOUSE_STORE)
end

M.OnClickBaseToggle = function(self)
	self.isBaseModeEnabled = not self.isBaseModeEnabled

	self.bindData.baseToggle:SetSelected(self.isBaseModeEnabled)

	if not self.isBaseModeEnabled and self.editDomain ~= "wall" then
		self.SwitchBuildMode(self, BuildMode.Furniture)
	end
end

M.OnClickFurnitureToggle = function(self)
	self.isFurnitureModeEnabled = not self.isFurnitureModeEnabled

	self.bindData.furnitureToggle:SetSelected(self.isFurnitureModeEnabled)

	if not self.isFurnitureModeEnabled then
		gFurnitureManager:ClearHoveredFurniture()
	end
end

M.IsEditModeAllowedForFurniture = function(self, furnitureId)
	local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if not cfg then
		return true
	end

	if cfg.MainType ~= HouseFurnitureConfig.MainTypeType.Base then
		return self.isBaseModeEnabled
	end

	return self.isFurnitureModeEnabled
end

M.OnClickCancelBtn = function(self, btn, data)
	if self.editDomain ~= "wall" then
		local shouldSwitchToFurniture = HomeBuildUIUtils:IsEditExitBuildMode(self.currentBuildMode) or HomeBuildUIUtils:IsFenestrationBuildMode(self.currentBuildMode)

		if self.fenestrationPreviewActive then
			self.StopFenestrationPreviewSession(self, true)
			self.FinalizeWallEditToolState(self, shouldSwitchToFurniture)

			return
		end

		if self.HasPendingFenestrationMove(self) then
			self.RevertPendingFenestrationMoveIfNeeded(self)
		end

		if not self.wallSessionActive then
			self.FinalizeWallEditToolState(self, shouldSwitchToFurniture)

			return
		end

		local currentIndex = gBuildOperationManager.currentIndex or 0
		local startIndex = self.wallSessionStartBuildIndex

		if startIndex ~= nil then
			startIndex = math.max(0, currentIndex - 1)
		end

		while startIndex >= currentIndex do
			if not gBuildOperationManager:Undo() then
				break
			end

			currentIndex = gBuildOperationManager.currentIndex or 0
		end

		self.UpdateUndoRedoButtonStates(self)
		self.FinalizeWallEditToolState(self, shouldSwitchToFurniture)

		return
	end

	self:ExitReplaceMode()
	gFurnitureManager:CancelFurniturePreview()
	self:ChangeEditMode(false)
end

M.DoStorage = function(self)
	local res = gFurnitureManager:StorageFurniture()

	if res ~= gFurnitureConst.StorageRes.Success then
		self.ChangeEditMode(self, false)
		self.MarkAsUnsaved(self)
	elseif res ~= gFurnitureConst.StorageRes.NoFollowingFurniture then
		-- Nothing
	elseif res ~= gFurnitureConst.StorageRes.NotInEdit then
		self.ChangeEditMode(self, false)
	end
end

M.OnClickStorageBtn = function(self, btn, data)
	if self.editDomain ~= "wall" then
		local shouldSwitchToFurniture = HomeBuildUIUtils:IsEditExitBuildMode(self.currentBuildMode) or HomeBuildUIUtils:IsFenestrationBuildMode(self.currentBuildMode)

		if self.fenestrationPreviewActive then
			local sourcePlaceCmd = self.fenestrationPreviewSourcePlaceCmd
			local hadSourceFenestration = sourcePlaceCmd == nil
			self.fenestrationPreviewSourcePlaceCmd = nil

			self:StopFenestrationPreviewSession(false)
			self:FinalizeWallEditToolState(false)

			if hadSourceFenestration then
				if gWallEditManager:CommitFenestrationDeleteByPlaceCmd(sourcePlaceCmd) then
					self.MarkAsUnsaved(self)
					self.UpdateUndoRedoButtonStates(self)
				else
					gWallEditManager:ApplyFenestrationPlaceCmdNoHistory(sourcePlaceCmd)
				end
			end

			if shouldSwitchToFurniture then
				self.SwitchBuildMode(self, BuildMode.Furniture)
			end

			return
		end

		if gWallEditManager:DeleteSelectedWall() then
			self.MarkAsUnsaved(self)
			self.UpdateUndoRedoButtonStates(self)
			self.SetWallEditCompVisible(self, false)

			if shouldSwitchToFurniture then
				self.SwitchBuildMode(self, BuildMode.Furniture)
			end
		end

		return
	end

	if gFurnitureManager:CheckStorageFurnitureHasAdsFurniture() then
		slot3 = gDisplayMessageMgr

		slot3:ShowMessage(MessageConfig.HouseBuildStorageFurnitureReconfirm, function ()
			self:DoStorage()
		end, nil)
	else
		self.DoStorage(self)
	end
end

M.OnClickConfirmBtn = function(self, btn, data)
	if self.editDomain ~= "wall" then
		local shouldSwitchToFurniture = HomeBuildUIUtils:IsFenestrationBuildMode(self.currentBuildMode) or self.enteredWallByUnifiedClick ~= true

		if self.fenestrationPreviewActive then
			local hitPoint = gWallEditManager.wallPreviewFenestrationHitPoint

			if not self.fenestrationPreviewCanPlace or not hitPoint then
				return
			end

			local rayDir = gWallEditManager.wallPreviewFenestrationRayDirection
			local edgeA = gWallEditManager.wallPreviewFenestrationEdgeA
			local edgeB = gWallEditManager.wallPreviewFenestrationEdgeB
			local edge = edgeA and edgeB and {
				edgeA,
				edgeB
			} or nil
			local sourcePlaceCmd = self.fenestrationPreviewSourcePlaceCmd

			if sourcePlaceCmd then
				local finalPlaceCmd = gWallEditManager:PlaceFenestrationNoHistory(hitPoint, self.pendingFenestrationPrefabID, self.pendingFenestrationType, rayDir, edge)

				if not finalPlaceCmd then
					return
				end

				if not gWallEditManager:CommitFenestrationMove(sourcePlaceCmd, finalPlaceCmd) then
					gWallEditManager:ApplyFenestrationDeleteCmdNoHistory({
						edgeA = finalPlaceCmd.edgeA,
						edgeB = finalPlaceCmd.edgeB,
						runtimeID = finalPlaceCmd.runtimeID
					})
					gWallEditManager:ApplyFenestrationPlaceCmdNoHistory(sourcePlaceCmd)

					return
				end
			elseif not gWallEditManager:PlaceFenestrationAt(hitPoint, self.pendingFenestrationPrefabID, self.pendingFenestrationType, rayDir, edge) then
				return
			end

			self.OnWallSessionOperationApplied(self)
			self.MarkAsUnsaved(self)
			self.StopFenestrationPreviewSession(self, false)
			self.FinalizeWallEditToolState(self, shouldSwitchToFurniture)

			return
		end

		local committedFenestrationMove = self.CommitPendingFenestrationMoveIfNeeded(self)

		if self.HasPendingFenestrationMove(self) then
			return
		end

		local startBaseIndex = self.wallSessionStartBuildIndex

		if startBaseIndex ~= nil then
			startBaseIndex = math.max(0, (gBuildOperationManager.currentIndex or 0) - 1)
		end

		local endIndex = gBuildOperationManager.currentIndex or 0
		local hasSessionChanges = committedFenestrationMove or startBaseIndex <= endIndex
		local collapseAvailable = gBuildOperationManager.CollapseHistoryRangeToBatch == nil

		if collapseAvailable then
			local startIndex = startBaseIndex + 1

			if endIndex > startIndex then
				gBuildOperationManager:CollapseHistoryRangeToBatch(startIndex, endIndex, "wall_session")
			end
		end

		if hasSessionChanges then
			self.MarkAsUnsaved(self)
		end

		self.UpdateUndoRedoButtonStates(self)
		self.FinalizeWallEditToolState(self, shouldSwitchToFurniture)

		return
	end

	if gFurnitureManager:FinalizeFurniture() then
		self.MarkAsUnsaved(self)
	end

	self:ChangeEditMode(false)
	gFurnitureManager:ClearSurfaceHintMesh()
end

M.OnClickSaveBtn = function(self, btn, data)
	self.EnsureRightBtnStores(self)

	if self.saveBtnStore.activeCtrl == 0 then
		return
	end

	local hasChanges = gHouseManager:SyncAllChangesToServer()

	if hasChanges then
		self.saved = true

		gDisplayMessageMgr:ShowMessageContentDebug("家具数据已保存到服务器")
	else
		self.saved = true

		gDisplayMessageMgr:ShowMessageContentDebug("没有需要保存的变化")
	end

	self.RefreshSaveButtonState(self)
end

M.OnPlayerExitedEditingIndoor = function(self)
	if not self.saved then
		self.OnClickSaveBtn(self)
	end

	gPanelManager:Close(self.panelId)
end

M.OnClickCopyBtn = function(self, btn, data)
	if self.editDomain ~= "wall" and (self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window) then
		if not self.selectedFenestrationRuntimeID then
			return
		end

		self.fenestrationMovePending = true

		self:SetWallEditCompVisible(false)
		gDisplayMessageMgr:ShowMessageContentDebug("请选择目标墙体位置")

		return
	end

	if not self.inEdit or not gFurnitureManager.isFollowing or not gFurnitureManager.followingFurniture then
		return
	end

	local uiCamera = SGUI.UWidget.uiCamera

	if not uiCamera or not self.bindData.editComp or not self.bindData.editComp.rectTransform then
		return
	end

	local screenPos = uiCamera:WorldToScreenPoint(self.bindData.editComp.rectTransform.position)
	local screenWidth = UnityEngine.Screen.width
	local isLeftHalf = screenPos.x <= screenWidth / 2
	local targetScreenX = isLeftHalf and screenWidth * 0.75 or screenWidth * 0.25
	local targetScreenY = UnityEngine.Screen.height * 0.5
	local targetScreenPos = Vector3.New(targetScreenX, targetScreenY, 0)

	gFurnitureManager:CopyFurniture(targetScreenPos)
end

M.OnClickReplaceBtn = function(self, btn, data)
	if self.editDomain ~= "wall" and (self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window) then
		if not self.selectedFenestrationRuntimeID or self.pendingFenestrationPrefabID < 0 then
			return
		end

		local visualPos = nil

		if self.selectedFenestrationGo and not gCS.LuaUtils.IsNull(self.selectedFenestrationGo) then
			visualPos = gWallEditManager:GetFenestrationVisualPosAndSize(self.selectedFenestrationGo)
		end

		local sourceCmd = gWallEditManager:TakeFenestrationForPreview(self.selectedFenestrationEdgeA, self.selectedFenestrationEdgeB, self.selectedFenestrationRuntimeID)

		if not sourceCmd then
			return
		end

		if visualPos then
			sourceCmd.visualX = visualPos.x
			sourceCmd.visualY = visualPos.y
			sourceCmd.visualZ = visualPos.z
		end

		local targetPos = HomeBuildUIUtils:GetFenestrationPreviewPosFromPlaceCmd(sourceCmd)

		if not targetPos then
			return
		end

		local mainCamera = gCS.CameraDataMgr.MainCamera
		local targetScreenPos = HomeBuildUIUtils:GetScreenCenterPos()

		if mainCamera then
			local screenPoint = mainCamera.WorldToScreenPoint(mainCamera, targetPos)
			targetScreenPos = Vector3.New(screenPoint.x, screenPoint.y, 0)
		end

		if not self.BeginFenestrationPreviewSession(self, self.pendingFenestrationPrefabID, self.pendingFenestrationType, targetScreenPos, sourceCmd, true) then
			gWallEditManager:ApplyFenestrationPlaceCmdNoHistory(sourceCmd)

			return
		end

		return
	end

	if not self.inEdit or not gFurnitureManager.isFollowing or not gFurnitureManager.followingFurniture then
		return
	end

	local furnitureCfg = HouseFurnitureConfig.GetConfig(gFurnitureManager.followingFurnitureId)
	self.isReplaceMode = true
	self.replaceModePageCtrl = self.bindData.pageCtrl
	self.replaceModeShowDetailEditCtrl = self.bindData.showDetailEditCtrl
	self.bindData.pageCtrl = 0
	self.bindData.showDetailEditCtrl = 1
	slot4 = ipairs
	slot6 = self.visibleMainTypeTabList or self.mainTypeTabList

	for i, v in slot4(slot6) do
		if v.mainType ~= furnitureCfg.MainType then
			self.bindData.mainTypeList:SelectItem(i - 1, true)
			self:OnClickMainTypeList(nil, i - 1)

			break
		end
	end

	for i, st in ipairs(self.curSubTypeList) do
		if st ~= furnitureCfg.SubType then
			self.bindData.subTypeList:SelectItem(i - 1, true)
			self:OnClickSubTypeList(nil, i - 1)

			break
		end
	end
end

M.ExitReplaceMode = function(self)
	if not self.isReplaceMode then
		return
	end

	if self.replaceModePageCtrl == nil then
		self.bindData.pageCtrl = self.replaceModePageCtrl
	end

	if self.replaceModeShowDetailEditCtrl == nil then
		self.bindData.showDetailEditCtrl = self.replaceModeShowDetailEditCtrl
	end

	self.isReplaceMode = false
	self.replaceModePageCtrl = nil
	self.replaceModeShowDetailEditCtrl = nil
end

M.onBeginDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	if self.editDomain ~= "wall" then
		local pos = self.GetBuildInputScreenPos(self, eventData)
		local pressPos = self.wallPressPos
		self.wallPressCanceledByDrag = true
		self.wallPressPending = false
		self.wallPressPos = nil

		if self.currentBuildMode == BuildMode.Wall then
			if (self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window) and self.fenestrationPreviewActive then
				self.UpdateFenestrationPreviewAt(self, pos, true, FenestrationPreviewIntent.DragMove)

				self.lastPos = nil

				return
			end

			if (self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window) and self.selectedFenestrationRuntimeID then
				local fenestrationHitInfo = gWallEditManager:RaycastFenestrationTarget(pos)

				if fenestrationHitInfo and fenestrationHitInfo.runtimeID ~= self.selectedFenestrationRuntimeID then
					local dragSourceGo = self.selectedFenestrationGo

					if (not dragSourceGo or gCS.LuaUtils.IsNull(dragSourceGo)) and fenestrationHitInfo.rootGo then
						dragSourceGo = fenestrationHitInfo.rootGo
						self.selectedFenestrationGo = fenestrationHitInfo.rootGo
					end

					if gWallEditManager:BeginFenestrationDragPreview(dragSourceGo, self.selectedFenestrationEdgeA, self.selectedFenestrationEdgeB) then
						self.fenestrationDragActive = true
						self.fenestrationDragStartScreenPos = Vector3.New(pos.x, pos.y, 0)
						self.wallEditCompHiddenByDrag = true

						self:SetWallEditCompVisible(false)
						gFurnitureManager:ClearHoveredFurniture()

						return
					end
				end
			end

			self.lastPos = pos

			return
		end

		local dragStartPos = pressPos or pos

		if self.wallSessionActive and not gWallEditUtils:IsScreenPosOnCurrentSelectedWall(gWallEditManager, dragStartPos) then
			self.EndWallEditSession(self)
		end

		if self.bindData.showDetailEditCtrl ~= 0 then
			self.wallEditCompHiddenByDrag = true

			self.SetWallEditCompVisible(self, false)
		end

		self.wallDragActive = true

		gWallEditManager:OnBeginDrag(dragStartPos)

		return
	end

	if gFurnitureManager.isRotatingDrag then
		self.lastPos = self.GetBuildInputScreenPos(self, eventData)

		return
	end

	if gFurnitureManager.isFollowing and gFurnitureManager.isLongPressing and not gFurnitureManager.canFollow then
		local touchPos = self.GetBuildInputScreenPos(self, eventData)

		if touchPos and not gFurnitureManager.dragStartScreenPos then
			gFurnitureManager.dragStartScreenPos = Vector3.New(touchPos.x, touchPos.y, 0)
		end
	end

	self.lastPos = self.GetBuildInputScreenPos(self, eventData)
end

M.onDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	if self.editDomain ~= "wall" then
		local pos = self.GetBuildInputScreenPos(self, eventData)

		if self.currentBuildMode == BuildMode.Wall then
			local currentPos = pos

			if (self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window) and self.fenestrationPreviewActive then
				self.UpdateFenestrationPreviewAt(self, currentPos, true, FenestrationPreviewIntent.DragMove)

				return
			end

			if (self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window) and self.fenestrationDragActive then
				gWallEditManager:UpdateFenestrationDragPreview(currentPos, nil, FenestrationPreviewIntent.DragMove)

				return
			end

			self.HandleCameraDragByLastPos(self, currentPos, false)

			return
		end

		gWallEditManager:OnDrag(pos)

		return
	end

	if gFurnitureManager.isRotatingDrag then
		if self.inEdit and self.editDomain ~= "furniture" and self.bindData.showDetailEditCtrl ~= 0 then
			self.bindData.showDetailEditCtrl = 1
			self.furnitureEditCompHiddenByRotate = true

			self.RefreshRightButtonsByEditState(self)
		end

		if not self.lastPos then
			self.lastPos = self.GetBuildInputScreenPos(self, eventData)

			return
		end

		local currentPos = self:GetBuildInputScreenPos(eventData)
		local delta = currentPos - self.lastPos
		local furnitureGo = gFurnitureManager.followingFurniture
		local furnitureComp = gFurnitureManager.followingFurnitureComponent
		local mainCamera = gCS.CameraDataMgr.MainCamera
		local boundsCenter = furnitureComp.boundsBox.center
		local boundsSize = furnitureComp.boundsBox.size
		local bottomCenter = furnitureGo.transform:TransformPoint(boundsCenter - Vector3.New(0, boundsSize.y * 0.5, 0))
		local sx, sy = gCS.LuaUtils.WorldToScreenPointProjected(bottomCenter, mainCamera, 0, 0, 0)
		local editCompScreenX = sx
		local editCompScreenY = sy
		local xDelta = delta.x

		if currentPos.y >= editCompScreenY then
			xDelta = -xDelta
		end

		local yDelta = delta.y

		if editCompScreenX >= currentPos.x then
			yDelta = -yDelta
		end

		gFurnitureManager:UpdateFurnitureRotationByDrag(Vector3.New(xDelta + yDelta, 0, 0))

		self.lastPos = currentPos

		return
	end

	local currentPos = self.GetBuildInputScreenPos(self, eventData)

	if gFurnitureManager.isFollowing and gFurnitureManager.isLongPressing and not gFurnitureManager.canFollow and gFurnitureManager.dragStartScreenPos then
		local delta = currentPos - gFurnitureManager.dragStartScreenPos
		local dragDistance = math.sqrt(delta.x * delta.x + delta.y * delta.y)

		if gFurnitureManager.dragThreshold >= dragDistance then
			gFurnitureManager.canFollow = true
		else
			return
		end
	end

	self.HandleCameraDragByLastPos(self, currentPos, true)
end

M.FinishWallDrag = function(self, pos)
	self.wallDragActive = false
	local success = gWallEditManager:OnEndDrag(pos)

	if success then
		self.MarkAsUnsaved(self)
		self.UpdateUndoRedoButtonStates(self)

		if gCS.LuaUtils.IsNonMobileAdaptive() and gWallEditManager.lastDragPlacedNewWall then
			self.ClearWallEditVisualState(self)

			self.lastPos = nil

			return
		end

		if not self.wallSessionActive then
			self:BeginWallEditSession(math.max(0, (gBuildOperationManager.currentIndex or 0) - 1))
		end
	end

	if gWallEditManager.selectedWallData then
		if not self.wallSessionActive then
			self.BeginWallEditSession(self, gBuildOperationManager.currentIndex)
		end

		self.wallEditCompHiddenByDrag = false

		self.SetWallEditCompVisible(self, true)
	else
		self.EndWallEditSession(self)

		self.wallEditCompHiddenByDrag = false

		self.SetWallEditCompVisible(self, false)
	end

	self.lastPos = nil
end

M.HandlePCWallDragRelease = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if self.editDomain == "wall" or self.currentBuildMode == BuildMode.Wall or not self.wallDragActive then
		return
	end

	if UnityEngine.Input.GetMouseButton(0) then
		return
	end

	local inputPos = SGUI.Utils.GetInputCenterPosition()
	local pos = Vector3.New(inputPos.x, inputPos.y, 0)

	self.FinishWallDrag(self, pos)
end

M.onEndDrag = function(self, eventData)
	if eventData.button ~= 0 then
		local pos = self.GetBuildInputScreenPos(self, eventData)

		if self.editDomain ~= "wall" then
			if self.currentBuildMode == BuildMode.Wall then
				if (self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window) and self.fenestrationPreviewActive then
					self.UpdateFenestrationPreviewAt(self, pos, true, FenestrationPreviewIntent.DragMove)

					self.lastPos = nil

					return
				end

				if (self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window) and self.fenestrationDragActive then
					local canDrop, hitPoint = gWallEditManager:UpdateFenestrationDragPreview(pos, nil, FenestrationPreviewIntent.DragMove)
					local moved = false

					if canDrop and hitPoint and self.fenestrationDragStartScreenPos then
						local delta = pos - self.fenestrationDragStartScreenPos

						if self.fenestrationDragThresholdSqr >= delta.sqrMagnitude then
							local placePrefabID = self.selectedFenestrationFurnitureID or self.pendingFenestrationPrefabID

							if placePrefabID and placePrefabID <= 0 and self.selectedFenestrationRuntimeID then
								local startCmd, finalCmd = gWallEditManager:MoveFenestrationNoHistory(self.selectedFenestrationEdgeA, self.selectedFenestrationEdgeB, self.selectedFenestrationRuntimeID, hitPoint, placePrefabID, self.pendingFenestrationType)

								if startCmd and finalCmd then
									moved = true

									if not self.pendingFenestrationMoveStartCmd then
										self.pendingFenestrationMoveStartCmd = startCmd
									end

									self.pendingFenestrationMoveFinalCmd = finalCmd
									self.selectedFenestrationEdgeA = finalCmd.edgeA
									self.selectedFenestrationEdgeB = finalCmd.edgeB
									self.selectedFenestrationRuntimeID = finalCmd.runtimeID
									self.selectedFenestrationFurnitureID = finalCmd.prefabID
									self.selectedFenestrationWorldPos = Vector3.New(finalCmd.centerX, finalCmd.centerY, finalCmd.centerZ)
								end
							end
						end
					end

					gWallEditManager:ClearWallPreviewMesh()

					self.fenestrationDragActive = false
					self.fenestrationDragStartScreenPos = nil
					self.wallEditCompHiddenByDrag = false

					if moved then
						if not self.wallSessionActive then
							self:BeginWallEditSession(gBuildOperationManager.currentIndex or 0)
						end

						local hitInfo = gWallEditManager:RaycastFenestrationTarget(pos)

						if hitInfo and hitInfo.nameGo then
							self.TrySetSelectedFenestrationByData(self, hitInfo.nameGo, hitInfo.rootGo, hitInfo.edgeA, hitInfo.edgeB, hitInfo.runtimeID, hitInfo.furnitureId)
						end

						self.SetWallEditCompVisible(self, true)
					else
						self.SetWallEditCompVisible(self, true)
					end

					self.lastPos = nil

					return
				end

				self.lastPos = nil

				return
			end

			self.FinishWallDrag(self, pos)

			return
		end

		if gFurnitureManager.isRotatingDrag then
			gFurnitureManager:EndRotationDrag()
		end

		if self.furnitureEditCompHiddenByRotate and self.inEdit and self.editDomain ~= "furniture" then
			self.furnitureEditCompHiddenByRotate = false
			self.bindData.showDetailEditCtrl = 0

			self.RefreshRightButtonsByEditState(self)
			self.UpdateEditCompPositionFromWorldPos(self)
		end

		self.lastPos = nil
	end
end

M.CameraEnterIndoor = function(self, isEnter)
	local gridSystem = gWallEditManager.gridSystemProxy

	if gridSystem then
		gridSystem.SetCeilingVisibility(gridSystem, isEnter)
	end

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		["PNkgO:!"] = "jt\\xe5K\\xcd\\xed\\xe7}9\\xd7iH\\xfe\\xe2y\\xd8|{\\xc2\\xf9\\xf1ٓ\\xfdv"
	})
end
