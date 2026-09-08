-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerProfileSceneEditPanelStore.lua
-- Decompiled from: 00775_PlayerProfileSceneEditPanelStore.lua_7037df535201.luajit

local ImageSceneiconConfig = LTConfig.ImageSceneiconConfig
local ImageSceneTabConfig = LTConfig.ImageSceneTabConfig
local FilterConfig = LTConfig.FilterConfig
local PhotoFiltersConfig = LTConfig.PhotoFiltersConfig
local ImageSceneExpressionConfig = LTConfig.ImageSceneExpressionConfig
local ImageSceneStickerConfig = LTConfig.ImageSceneStickerConfig
C_PlayerProfileSceneEditPanelStore = DefClass("C_PlayerProfileSceneEditPanelStore", C_PlayerProfileSceneEditPanelStore, C_StoreGroup)
GroupName2Class.PlayerProfileSceneEditPanelStore = C_PlayerProfileSceneEditPanelStore
local M = C_PlayerProfileSceneEditPanelStore
local TAB_TYPE = {
	["`Om{O*"] = 1,
	["~\\xad\\xa7\\xa1\\xb3"] = 3,
	["\\xef\\xde(\\xf4"] = 2,
	[":A\\x9d\\x9a\\x86S"] = 5,
	["\\xea\\xcf!\\xe3"] = 4
}
M.TabType = TAB_TYPE
local STICKER_RECT_SCREEN_MARGIN = 60
local STICKER_RECT_MIN_SIZE = 80
local STICKER_ROTATE_MIN_RADIUS = 16
local MODEL_DRAG_DEPTH_SENSITIVITY = 2
local MODEL_DRAG_LATERAL_MIN_DENOM = 0.05
local MODEL_DRAG_MIN_DEPTH = 0.5

local ClampScreenRange = function(rangeMin, rangeMax, limitMin, limitMax)
	if limitMax < limitMin then
		return nil
	end

	local minSize = STICKER_RECT_MIN_SIZE

	if minSize <= limitMax - limitMin then
		minSize = limitMax - limitMin
	end

	local minV = rangeMin >= limitMin and limitMin or rangeMin
	local maxV = limitMax >= rangeMax and limitMax or rangeMax

	if minSize <= maxV - minV then
		local center = nil

		if maxV < minV then
			center = (rangeMin + rangeMax) * 0.5

			if limitMin <= center then
				center = limitMin
			end

			if limitMax >= center then
				center = limitMax
			end
		else
			center = (minV + maxV) * 0.5
		end

		minV = center - minSize * 0.5
		maxV = center + minSize * 0.5

		if minV >= limitMin then
			minV = limitMin
			maxV = limitMin + minSize
		elseif limitMax >= maxV then
			maxV = limitMax
			minV = limitMax - minSize
		end
	end

	return minV, maxV
end

local TYPE_TO_TAB = {
	[ImageSceneTabConfig.TypeType.Character] = TAB_TYPE.Character,
	[ImageSceneTabConfig.TypeType.Cars] = TAB_TYPE.Vehicle,
	[ImageSceneTabConfig.TypeType.Scene] = TAB_TYPE.Scene,
	[ImageSceneTabConfig.TypeType.Sticker] = TAB_TYPE.Sticker,
	[ImageSceneTabConfig.TypeType.Filter] = TAB_TYPE.Filter
}

local BuildTabList = function()
	local list = {}

	for i = 0, ImageSceneTabConfig.count - 1 do
		local cfg = ImageSceneTabConfig.LoadAt(i)

		if cfg and cfg.TabIndex and cfg.TabIndex <= 0 then
			local tabType = TYPE_TO_TAB[cfg.Type]

			if tabType then
				table.insert(list, {
					tabIndex = cfg.TabIndex,
					name = cfg.TabName,
					iconId = cfg.Resource,
					tabType = tabType
				})
			end
		end
	end

	table.sort(list, function (a, b)
		return a.tabIndex <= b.tabIndex
	end)

	return list
end

local TAB_LIST = BuildTabList()
local CHANGE_MODE_NAMES = {
	[1.0] = "Lw\\xa1r^\\xb3\\xbaSown",
	[2.0] = "\\xb2;$:t\\xd5U\\xdc:\\xba\\xf0"
}
local CHANGE_MODE = {
	["`\\xa1\\xa6\\xaa\\xba"] = 2,
	["?I\\x9c\\x8b\\x91@"] = 1
}
M.ChangeMode = CHANGE_MODE
local CHARACTER_SUB_TAB_TYPE = {
	["vBޯ\\x81\\xab\r\\xc6\\xe6"] = 3,
	["=K\\x85\\x87\\x8cO"] = 1,
	["\\xbb&%,k\\xadS\\xdc$\\xaf\\xad"] = 2
}
M.CharacterSubTabType = CHARACTER_SUB_TAB_TYPE
local CHARACTER_SUB_TAB_NAMES = {
	LTConfig.ImageConfig.ScenarioTextCharacterAction or "action",
	LTConfig.ImageConfig.ScenarioTextCharacterDress or "dress",
	LTConfig.ImageConfig.ScenarioTextCharacterExpression or "expression"
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.currentTab = self.TabType.Character
	self.currentChangeMode = self.ChangeMode.Camera
	self.directionPressed = {
		["~-jU"] = false,
		[""] = false,
		["v'{O"] = false,
		["_\\xa7\\xa5\\xa7\\xa2"] = false
	}
	self.rotatePressed = {
		["v'{O"] = false,
		["_\\xa7\\xa5\\xa7\\xa2"] = false
	}
	self.cameraMoveSpeed = 2
	self.modelMoveSpeed = 2
	self.rotateSpeed = 90
	self.vehicleList = {}
	self.sceneList = {}
	self.characterSpiritIds = {}
	self.selectedItemIndex = 0
	self.isDraggingModel = false
	self.lastDragScreenPos = nil
	self.currentCharacterSubTab = 0
	self.characterActionList = {}
	self.characterDressPresetList = {}
	self.characterExpressionList = {}
	self.currentEditSlot = 0
	self.isSwitchCharacterOpen = false
	self.pcCameraRightDragLastPos = nil
	self.cameraRotateSensitivity = 0.2
	self.filterList = {}
	self.currentFilterId = 0
	self.currentFilterStrength = 100
	self.stickerList = {}
	self.stickerDistPressed = {
		["~-jU"] = false,
		[""] = false
	}
	self.stickerDistSpeed = 5
	self.stickerDragging = false
	self.stickerDragLastScreenPos = nil
	self.stickerScaleDragging = false
	self.stickerScaleDragStartVec = nil
	self.stickerScaleDragStartScale = 1
	self.stickerRotateDragging = false
	self.stickerRotateDragLastAngle = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.isCharacterCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.hideUICtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isTabCtrlEnum = {
		["\\xf1\\xda*%\\xf3"] = 0,
		["c\\xa1\\x96\\xae\\xb4"] = 1
	}
	self.editCtrlEnum = {
		["\\xba0)+\\\\x98U\\xd8>\\xa6\\xaa"] = 1,
		["Jr\\xa5ca\\xb3\\xfbIGpY"] = 0
	}
	self.filterCtrlEnum = {
		["Fe\\x9cC\\xa6\\xfdakhsI"] = 0,
		["ɕ\\xc5,\\xe9\\xe5\\xae\\xec\\x90--"] = 1
	}
	self.isStickerEditCtrlEnum = {
		["ɕ\\xdf\\xe5\\xef\\x9aȆ)<"] = 0,
		["\\xac )<s\\x98S\\xfc3\\xa3\\xad"] = 1
	}
	self.lineCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isCharacterCtrlEnum = nil
	self.hideUICtrlEnum = nil
	self.isTabCtrlEnum = nil
	self.editCtrlEnum = nil
	self.filterCtrlEnum = nil
	self.isStickerEditCtrlEnum = nil
	self.lineCtrlEnum = nil
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.stickerEditStore = nil
end

M.InitStickerEditStore = function(self)
	self.stickerEditStore = gStoreManager:GetStoreGroup(self.bindData.stickerEdit.Store):GetStoreByWidget(self.bindData.stickerEdit)
	local se = self.stickerEditStore

	if se then
		local bindDrag = function(btn, name, onBegin, onDrag, onEnd)
			if not btn or gCS.LuaUtils.IsNull(btn.gameObject) then
				print_error("[SceneEdit] stickerEdit 缺少控件：" .. name)

				return
			end

			local listener = SGUI.EventSystems.DragEventListener.Get(btn.gameObject)
			listener.onBeginDrag = onBegin
			listener.onDrag = onDrag
			listener.onEndDrag = onEnd
		end

		if se.upBtn then
			se.upBtn.luaBeginLongPress = self:CreateAction(self.OnStickerBeginPressUp)
			se.upBtn.luaEndLongPress = self:CreateAction(self.OnStickerEndPressUp)
		else
			print_error("[SceneEdit] stickerEdit 缺少控件：upBtn")
		end

		if se.downBtn then
			se.downBtn.luaBeginLongPress = self:CreateAction(self.OnStickerBeginPressDown)
			se.downBtn.luaEndLongPress = self:CreateAction(self.OnStickerEndPressDown)
		else
			print_error("[SceneEdit] stickerEdit 缺少控件：downBtn")
		end

		if se.changeBtn then
			se.changeBtn.luaClick = self:CreateAction(self.OnClickStickerChangeBtn)
		else
			print_error("[SceneEdit] stickerEdit 缺少控件：changeBtn")
		end

		bindDrag(se.rectBtn, "rectBtn", self:CreateAction(self.OnStickerRectBeginDrag), self:CreateAction(self.OnStickerRectDrag), self:CreateAction(self.OnStickerRectEndDrag))
		bindDrag(se.scaleBtn, "scaleBtn", self:CreateAction(self.OnStickerScaleBeginDrag), self:CreateAction(self.OnStickerScaleDrag), self:CreateAction(self.OnStickerScaleEndDrag))
		bindDrag(se.rotateBtn, "rotateBtn", self:CreateAction(self.OnStickerRotateBeginDrag), self:CreateAction(self.OnStickerRotateDrag), self:CreateAction(self.OnStickerRotateEndDrag))
	end
end

M.OnGroupDisable = function(self)
	self:ClearMessageEvents()
end

M.OnShow = function(self, panelId, data)
	self.currentTab = self.TabType.Character
	self.currentChangeMode = self.ChangeMode.Camera
	self.characterSpiritIds = {}
	self.selectedItemIndex = 0

	self:InitStickerEditStore()

	if data and data.editSlot and data.editSlot <= 0 then
		self.currentEditSlot = data.editSlot
	else
		local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
		slot4 = showInfos and showInfos.CurSlot and showInfos.CurSlot <= 0 and showInfos.CurSlot or 1
		self.currentEditSlot = slot4
	end

	self.bindData.leftRotateBtn.gameObject:SetActive(false)
	self.bindData.rightRotateBtn.gameObject:SetActive(false)

	self.bindData.lineCtrl = self.lineCtrlEnum.hide

	gPlayerProfileSceneEditManager:SetOnModelListChanged(function ()
		self:SyncStateFromEditManager()

		local mgr = gPlayerProfileSceneEditManager

		if mgr.selectedVehicleIndex >= 0 or mgr.selectedCharacterIndex >= 0 or mgr.selectedStickerIndex <= 0 then
			self:SetChangeMode(self.ChangeMode.Model)
		end

		if mgr.selectedCharacterIndex <= 0 and self.currentTab ~= self.TabType.Character then
			local entry = mgr.characterModels[mgr.selectedCharacterIndex]

			if entry then
				self:InitCharacterSubTabs(entry.spiritId)
			end
		end

		self:UpdateUndoRedoButtonStates()
		self:RefreshTabNum()
		self:RefreshEditButtons()
	end)

	gPlayerProfileSceneOperationManager.onHistoryChanged = function()
		self:UpdateUndoRedoButtonStates()
	end

	self:InitSceneList()
	self:InitFilterList()
	self:InitStickerList()

	self.bindData.filterSlider.minValue = 0
	self.bindData.filterSlider.maxValue = 100
	self.bindData.filterSlider.value = self.currentFilterStrength

	self:RefreshMainTabList()
	self:RefreshChangeList()
	self:OnTabChanged(self.TabType.Character)
	self:LoadVehicleList()
	gPlayerProfileSceneManager:ClearScenarioModels()

	gPlayerProfileSceneManager.cameraPos = gPlayerProfileSceneManager:GetCameraPosition()

	self:_RestoreFromSlotData()
	self:UpdateUndoRedoButtonStates()
	self:RefreshEditButtons()
end

M.OnClose = function(self)
	self:FlushPendingScrollOperations()

	if self._thumbnailCo then
		coroutine.stop(self._thumbnailCo)

		self._thumbnailCo = nil
	end

	self.pcCameraRightDragLastPos = nil
	self.stickerDistPressed = {
		["~-jU"] = false,
		[""] = false
	}
	self.stickerDragging = false
	self.stickerDragLastScreenPos = nil
	self.stickerScaleDragging = false
	self.stickerScaleDragStartVec = nil
	self.stickerRotateDragging = false
	self.stickerRotateDragLastAngle = nil

	gPlayerProfileSceneEditManager:SetOnModelListChanged(nil)

	gPlayerProfileSceneOperationManager.onHistoryChanged = nil

	gPlayerProfileSceneEditManager:ClearAll()
	gPlayerProfileSceneOperationManager:Clear()
	gPlayerProfileSceneManager:ApplySceneCamera()
	self:ClearFilter()

	self.vehicleList = {}
	self.sceneList = {}
	self.filterList = {}
	self.stickerList = {}
	self.characterSpiritIds = {}
end

M.OnUpdate = function(self)
	local dx = 0
	local dyz = 0
	local dt = Time.deltaTime
	local isPC = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive()
	local isCameraMode = isPC or self.currentChangeMode ~= self.ChangeMode.Camera
	local speed = isCameraMode and self.cameraMoveSpeed or self.modelMoveSpeed

	if self.directionPressed.left then
		dx = dx - speed * dt
	end

	if self.directionPressed.right then
		dx = dx + speed * dt
	end

	if self.directionPressed.up then
		dyz = dyz + speed * dt
	end

	if self.directionPressed.down then
		dyz = dyz - speed * dt
	end

	if dx == 0 or dyz == 0 then
		if isCameraMode then
			gPlayerProfileSceneManager:OffsetCameraPosition(dx, dyz)
		else
			gPlayerProfileSceneEditManager:OffsetSelectedModelPosition(-dx, -dyz)
		end
	end

	local rot = 0

	if self.rotatePressed.left then
		rot = rot - self.rotateSpeed * dt
	end

	if self.rotatePressed.right then
		rot = rot + self.rotateSpeed * dt
	end

	if rot == 0 then
		gPlayerProfileSceneEditManager:RotateSelectedModel(rot)
	end

	self:UpdateStickerDistance(dt)
	self:HandlePCCameraRightDrag()
end

M.OnLateUpdate = function(self)
	self:UpdateStickerEditRect()
end

M.OnCameraUpdate = function(self)
	self:UpdateStickerEditRect()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.InitSceneList = function(self)
	self.sceneList = {}

	for i = 0, ImageSceneiconConfig.count - 1 do
		local cfg = ImageSceneiconConfig.LoadAt(i)

		if cfg then
			table.insert(self.sceneList, {
				id = cfg.Id,
				name = cfg.Name,
				iconId = cfg.Resource
			})
		end
	end
end

M.InitStickerList = function(self)
	self.stickerList = {}

	for i = 0, ImageSceneStickerConfig.count - 1 do
		local cfg = ImageSceneStickerConfig.LoadAt(i)

		if cfg then
			table.insert(self.stickerList, {
				id = cfg.Id,
				name = cfg.TabName,
				iconId = cfg.Resource,
				meshPath = cfg.MeshPath
			})
		end
	end
end

M.IsRankingSlot = function(self)
	return self.currentEditSlot ~= gPlayerProfileSceneEditManager.RANKING_SLOT
end

M.LoadVehicleList = function(self)
	self.vehicleList = {}

	gDriveVehiclesManager:GetUnlockedVehicleInfo(function (list)
		if not list then
			return
		end

		local persistentList = {}

		for i = 1, #list do
			local v = list[i]

			if v and v.IsPersistent then
				table.insert(persistentList, v)
			end
		end

		self.vehicleList = persistentList

		if self.currentTab ~= self.TabType.Vehicle then
			self:RefreshItemList()
		end
	end)
end

M.RegisterWidget = function(self)
	self.bindData.showUIBtn.luaClick = self:CreateAction(self.OnClickShowUIBtn)
	self.bindData.characterAddBtn.luaClick = self:CreateAction(self.OnClickCharacterAddBtn)
	self.bindData.hideUIBtn.luaClick = self:CreateAction(self.OnClickHideUIBtn)
	self.bindData.redoBtn.luaClick = self:CreateAction(self.OnClickRedoBtn)
	self.bindData.undoBtn.luaClick = self:CreateAction(self.OnClickUndoBtn)
	self.bindData.saveBtn.luaClick = self:CreateAction(self.OnClickSaveBtn)
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnClickBackBtn)
	self.bindData.editConfirmBtn.luaClick = self:CreateAction(self.OnClickExitEditBtn)
	self.bindData.editAddBtn.luaClick = self:CreateAction(self.OnClickEditAddBtn)
	self.bindData.editDeleteBtn.luaClick = self:CreateAction(self.OnClickEditDeleteBtn)
	self.bindData.deleteAllBtn.luaClick = self:CreateAction(self.OnClickRevertAllBtn)

	if self.bindData.exitEditBtn then
		self.bindData.exitEditBtn.luaClick = self:CreateAction(self.OnClickExitEditBtn)
	end

	if self.bindData.showLineBtn then
		self.bindData.showLineBtn.luaClick = self:CreateAction(self.OnClickShowLineBtn)
	end

	self.bindData.upBtn.luaBeginLongPress = self:CreateAction(self.OnBeginPressUp)
	self.bindData.upBtn.luaEndLongPress = self:CreateAction(self.OnEndPressUp)
	self.bindData.downBtn.luaBeginLongPress = self:CreateAction(self.OnBeginPressDown)
	self.bindData.downBtn.luaEndLongPress = self:CreateAction(self.OnEndPressDown)
	self.bindData.leftBtn.luaBeginLongPress = self:CreateAction(self.OnBeginPressLeft)
	self.bindData.leftBtn.luaEndLongPress = self:CreateAction(self.OnEndPressLeft)
	self.bindData.rightBtn.luaBeginLongPress = self:CreateAction(self.OnBeginPressRight)
	self.bindData.rightBtn.luaEndLongPress = self:CreateAction(self.OnEndPressRight)

	if self.bindData.upBtn2 then
		self.bindData.upBtn2.luaBeginLongPress = self:CreateAction(self.OnBeginPressUp)
		self.bindData.upBtn2.luaEndLongPress = self:CreateAction(self.OnEndPressUp)
	end

	if self.bindData.downBtn2 then
		self.bindData.downBtn2.luaBeginLongPress = self:CreateAction(self.OnBeginPressDown)
		self.bindData.downBtn2.luaEndLongPress = self:CreateAction(self.OnEndPressDown)
	end

	if self.bindData.leftBtn2 then
		self.bindData.leftBtn2.luaBeginLongPress = self:CreateAction(self.OnBeginPressLeft)
		self.bindData.leftBtn2.luaEndLongPress = self:CreateAction(self.OnEndPressLeft)
	end

	if self.bindData.rightBtn2 then
		self.bindData.rightBtn2.luaBeginLongPress = self:CreateAction(self.OnBeginPressRight)
		self.bindData.rightBtn2.luaEndLongPress = self:CreateAction(self.OnEndPressRight)
	end

	self.bindData.leftRotateBtn.luaBeginLongPress = self:CreateAction(self.OnBeginPressLeftRotate)
	self.bindData.leftRotateBtn.luaEndLongPress = self:CreateAction(self.OnEndPressLeftRotate)
	self.bindData.rightRotateBtn.luaBeginLongPress = self:CreateAction(self.OnBeginPressRightRotate)
	self.bindData.rightRotateBtn.luaEndLongPress = self:CreateAction(self.OnEndPressRightRotate)
	self.bindData.characterList.luaSimpleRenderItem = self:CreateAction(self.OnRenderCharacterListItem)
	self.bindData.mainTabList.luaSimpleRenderItem = self:CreateAction(self.OnRenderMainTabListItem)
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction(self.OnRenderItemListItem)
	self.bindData.itemList.luaSimpleDynamicRenderItem = self:CreateAction(self.OnRenderItemListItem)
	self.bindData.itemList.onGetTIndex = self:CreateAction(self.OnGetItemListTIndex)
	self.bindData.changeList.luaSimpleRenderItem = self:CreateAction(self.OnRenderChangeListItem)
	self.bindData.characterList.luaSimpleClick = self:CreateAction(self.OnClickCharacterList)
	self.bindData.mainTabList.luaSimpleClick = self:CreateAction(self.OnClickMainTabList)
	self.bindData.itemList.luaSimpleClick = self:CreateAction(self.OnClickItemList)
	self.bindData.changeList.luaSimpleClick = self:CreateAction(self.OnClickChangeList)
	self.bindData.filterSlider.luaValueChanged = self:CreateAction(self.OnFilterSliderChanged)
	self.bindData.fullscreenBtn.luaPress = self:CreateAction(self.OnFullScreenPress)
	local gestureListener = self.bindData.fullscreenBtn.transform:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))

	if gestureListener then
		gestureListener.onZoom = self:CreateAction(self.OnGestureZoom)
	end

	local dragListener = SGUI.EventSystems.DragEventListener.Get(self.bindData.fullscreenBtn.gameObject)
	dragListener.onBeginDrag = self:CreateAction(self.OnBeginDrag)
	dragListener.onDrag = self:CreateAction(self.OnDrag)
	dragListener.onEndDrag = self:CreateAction(self.OnEndDrag)

	if self.bindData.rotate then
		self.bindData.rotate.luaGamePadInputChanged = self:CreateAction(self.OnRotateInput)
	end
end

M.OnBeginPressUp = function(self)
	print_debug("[SceneEdit] BeginPressUp")

	self.directionPressed.up = true

	self:TryBeginTransform()
end

M.OnEndPressUp = function(self)
	self.directionPressed.up = false

	self:TryEndTransform()
end

M.OnBeginPressDown = function(self)
	print_debug("[SceneEdit] BeginPressDown")

	self.directionPressed.down = true

	self:TryBeginTransform()
end

M.OnEndPressDown = function(self)
	self.directionPressed.down = false

	self:TryEndTransform()
end

M.OnBeginPressLeft = function(self)
	print_debug("[SceneEdit] BeginPressLeft")

	self.directionPressed.left = true

	self:TryBeginTransform()
end

M.OnEndPressLeft = function(self)
	self.directionPressed.left = false

	self:TryEndTransform()
end

M.OnBeginPressRight = function(self)
	print_debug("[SceneEdit] BeginPressRight")

	self.directionPressed.right = true

	self:TryBeginTransform()
end

M.OnEndPressRight = function(self)
	self.directionPressed.right = false

	self:TryEndTransform()
end

M.OnBeginPressLeftRotate = function(self)
	self.rotatePressed.left = true

	self:TryBeginTransform()
end

M.OnEndPressLeftRotate = function(self)
	self.rotatePressed.left = false

	self:TryEndTransform()
end

M.OnBeginPressRightRotate = function(self)
	self.rotatePressed.right = true

	self:TryBeginTransform()
end

M.OnEndPressRightRotate = function(self)
	self.rotatePressed.right = false

	self:TryEndTransform()
end

M.TryBeginTransform = function(self)
	self:FlushPendingScrollOperations()

	local isPC = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive()

	if not isPC and self.currentChangeMode ~= self.ChangeMode.Model then
		gPlayerProfileSceneEditManager:BeginTransform()
	else
		gPlayerProfileSceneEditManager:BeginCameraTransform()
	end

	self:UpdateUndoRedoButtonStates()
end

M.TryEndTransform = function(self)
	if self.directionPressed.up or self.directionPressed.down or self.directionPressed.left or self.directionPressed.right or self.rotatePressed.left or self.rotatePressed.right or self.isDraggingModel then
		return
	end

	local isPC = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive()

	if not isPC and self.currentChangeMode ~= self.ChangeMode.Model then
		gPlayerProfileSceneEditManager:EndTransform()
	else
		gPlayerProfileSceneEditManager:EndCameraTransform()
	end

	self:UpdateUndoRedoButtonStates()
end

M.FlushPendingScrollOperations = function(self)
	if self._zoomEndTimer then
		self._zoomEndTimer:Stop()

		self._zoomEndTimer = nil
	end

	if self._zoomTransformActive then
		gPlayerProfileSceneEditManager:EndCameraTransform()

		self._zoomTransformActive = false
	end

	if self._rotateInputEndTimer then
		self._rotateInputEndTimer:Stop()

		self._rotateInputEndTimer = nil
	end

	if self._rotateInputActive then
		gPlayerProfileSceneEditManager:EndTransform()

		self._rotateInputActive = false
	end
end

M.RefreshMainTabList = function(self)
	self.bindData.mainTabList:SetSimpleList(#TAB_LIST)
end

M.OnRenderMainTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local entry = TAB_LIST[index + 1]

	if store and entry then
		store.title = entry.name or ""
		store.icon = entry.iconId or 0
	end

	local tabType = entry and entry.tabType or 0
	btn.isSelected = tabType ~= self.currentTab
end

M.OnClickMainTabList = function(self, btn, index)
	local entry = TAB_LIST[index + 1]

	if not entry then
		return
	end

	if entry.tabType ~= self.currentTab then
		return
	end

	self:OnTabChanged(entry.tabType)
end

M.OnTabChanged = function(self, tabType)
	gPlayerProfileSceneEditManager:CommitPendingFilterStrength()

	self.currentTab = tabType
	self.selectedItemIndex = 0
	local tabName = ""

	for _, entry in ipairs(TAB_LIST) do
		if entry.tabType ~= tabType then
			tabName = entry.name

			break
		end
	end

	self.bindData.tabTitle = tabName

	self.bindData.itemList:DeselectAll()
	gPlayerProfileSceneEditManager:ClearSelection()

	self.currentChangeMode = self.ChangeMode.Camera

	self:ClearCharacterSubTabs()
	self:RefreshChangeList()

	if tabType ~= self.TabType.Character then
		self.bindData.isCharacterCtrl = 1
	else
		self.bindData.isCharacterCtrl = 0
	end

	if tabType ~= self.TabType.Filter then
		self.bindData.filterCtrl = 0
	else
		self.bindData.filterCtrl = 1
	end

	if tabType ~= self.TabType.Scene then
		self.selectedItemIndex = self:_FindCurrentSceneItemIndex() or 0
	elseif tabType ~= self.TabType.Filter then
		self.selectedItemIndex = self:_FindCurrentFilterItemIndex() or 0
	end

	self:RefreshItemList()
	self:RefreshMainTabList()
	self:RefreshTabNum()
	self:RefreshEditButtons()
end

M.RefreshTabNum = function(self)
	local mgr = gPlayerProfileSceneEditManager

	if self.currentTab ~= self.TabType.Character then
		local maxCount = LTConfig.ImageConfig.ScenarioMaxRoleCount or 10
		self.bindData.tabNum = tostring(#mgr.characterModels) .. "/" .. tostring(maxCount)
	elseif self.currentTab ~= self.TabType.Vehicle then
		local maxCount = LTConfig.ImageConfig.ScenarioMaxCarCount or 1
		self.bindData.tabNum = tostring(#mgr.vehicleModels) .. "/" .. tostring(maxCount)
	else
		self.bindData.tabNum = ""
	end
end

M.RefreshItemList = function(self)
	local count = 0

	if self.currentTab ~= self.TabType.Character then
		if self.currentCharacterSubTab ~= self.CharacterSubTabType.Action then
			count = #self.characterActionList
		elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.DressPreset then
			count = #self.characterDressPresetList
		elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.Expression then
			count = #self.characterExpressionList
		end
	elseif self.currentTab ~= self.TabType.Vehicle then
		count = #self.vehicleList
	elseif self.currentTab ~= self.TabType.Scene then
		count = #self.sceneList
	elseif self.currentTab ~= self.TabType.Filter then
		count = #self.filterList
	elseif self.currentTab ~= self.TabType.Sticker then
		count = #self.stickerList
	end

	self.bindData.itemList:SetSimpleList(count)
	self.bindData.itemList.gameObject:SetActive(count >= 0)
end

M.OnRenderItemListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local idx = index + 1
	local data = self:GetItemData(idx)

	if not data then
		return
	end

	btn.enabledTooltip = false
	store.itemType = 0

	if self.currentTab ~= self.TabType.Character then
		if self.currentCharacterSubTab ~= self.CharacterSubTabType.Action then
			store.count = data.name or ""
			store.iconId = data.iconId or 0
			btn.isSelected = self.selectedItemIndex ~= idx
		elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.DressPreset then
			store.count = data.name or ""
			store.iconId = data.iconId or 0
			store.itemType = 3
			btn.isSelected = self.selectedItemIndex ~= idx
		elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.Expression then
			store.count = data.name or ""
			store.iconId = data.iconId or 0
			btn.isSelected = self.selectedItemIndex ~= idx
		end
	elseif self.currentTab ~= self.TabType.Vehicle then
		local renderData = gCommonItemManager:GetItemRenderData({
			itemId = data.vehicleConfigID or 0
		})

		gCommonItemManager:OnCommonItemRender(btn, index, renderData)

		btn.isSelected = self.selectedItemIndex ~= idx
	elseif self.currentTab ~= self.TabType.Scene then
		store.count = data.name or ""
		store.iconId = data.iconId or 0
		btn.isSelected = self.selectedItemIndex ~= idx
	elseif self.currentTab ~= self.TabType.Filter then
		store.frameImg = data.iconId or 0
		btn.isSelected = self.selectedItemIndex ~= idx
	elseif self.currentTab ~= self.TabType.Sticker then
		store.count = data.name or ""
		store.iconId = data.iconId or 0
		btn.isSelected = self.selectedItemIndex ~= idx
	end
end

M.OnClickItemList = function(self, btn, index)
	gPlayerProfileSceneEditManager:CommitPendingFilterStrength()
	self:FlushPendingScrollOperations()

	local idx = index + 1
	local data = self:GetItemData(idx)

	if not data then
		return
	end

	if self.currentTab ~= self.TabType.Character then
		self.selectedItemIndex = idx

		if self.currentCharacterSubTab ~= self.CharacterSubTabType.Action then
			local mgr = gPlayerProfileSceneEditManager

			if mgr.selectedCharacterIndex <= 0 then
				mgr:ChangeCharacterAction(mgr.selectedCharacterIndex, data.id, data.actionGroup)
			end
		elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.DressPreset then
			local mgr = gPlayerProfileSceneEditManager

			if mgr.selectedCharacterIndex <= 0 then
				mgr:ChangeCharacterDressPreset(mgr.selectedCharacterIndex, data)
			end
		elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.Expression then
			local mgr = gPlayerProfileSceneEditManager

			if mgr.selectedCharacterIndex <= 0 then
				mgr:ChangeCharacterExpression(mgr.selectedCharacterIndex, data.id)
			end
		end

		self:RefreshItemList()
	elseif self.currentTab ~= self.TabType.Vehicle then
		self.selectedItemIndex = idx
		local mgr = gPlayerProfileSceneEditManager

		mgr:SelectOrLoadVehicle(data.vehicleConfigID)

		if mgr.selectedVehicleIndex <= 0 then
			self:SetChangeMode(self.ChangeMode.Model)
		end

		self:RefreshItemList()
	elseif self.currentTab ~= self.TabType.Scene then
		self.selectedItemIndex = idx

		self:OnChangeScene(data.id)
		self:RefreshItemList()
	elseif self.currentTab ~= self.TabType.Filter then
		self.selectedItemIndex = idx

		self:ApplyFilter(data.filterId)
		self:RefreshItemList()
	elseif self.currentTab ~= self.TabType.Sticker then
		self.selectedItemIndex = idx
		local existIndex = gPlayerProfileSceneEditManager:FindStickerIndexByConfigId(data.id)

		if existIndex <= 0 then
			gPlayerProfileSceneEditManager:SelectSticker(existIndex)
			self:SetChangeMode(self.ChangeMode.Model)
		end

		self:RefreshItemList()
	end

	self:UpdateUndoRedoButtonStates()
	self:RefreshEditButtons()
end

M.GetItemData = function(self, idx)
	if self.currentTab ~= self.TabType.Character then
		if self.currentCharacterSubTab ~= self.CharacterSubTabType.Action then
			return self.characterActionList[idx]
		elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.DressPreset then
			return self.characterDressPresetList[idx]
		elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.Expression then
			return self.characterExpressionList[idx]
		end

		return nil
	elseif self.currentTab ~= self.TabType.Vehicle then
		return self.vehicleList[idx]
	elseif self.currentTab ~= self.TabType.Scene then
		return self.sceneList[idx]
	elseif self.currentTab ~= self.TabType.Filter then
		return self.filterList[idx]
	elseif self.currentTab ~= self.TabType.Sticker then
		return self.stickerList[idx]
	end

	return nil
end

M.OnChangeScene = function(self, sceneId)
	if not sceneId or sceneId ~= 0 then
		return
	end

	gPlayerProfileSceneEditManager:ChangeScene(sceneId)
end

M.InitFilterList = function(self)
	self.filterList = {}

	table.insert(self.filterList, {
		["K\\x9e\\x80\\xaaE"] = 0,
		["\\xad\\xb8\t\\xbfo,\\xd77"] = 0,
		["JTHlH,"] = true
	})

	for i = 0, PhotoFiltersConfig.count - 1 do
		local cfg = PhotoFiltersConfig.LoadAt(i)

		if cfg then
			local filterCfg = FilterConfig.GetConfig(cfg.FilterId)

			if filterCfg then
				table.insert(self.filterList, {
					["JTHlH,"] = false,
					filterId = cfg.FilterId,
					iconId = filterCfg.Icon
				})
			end
		end
	end
end

M.OnGetItemListTIndex = function(self, index)
	if self.currentTab ~= self.TabType.Filter then
		return 2
	end

	return 0
end

M.ApplyFilter = function(self, filterId)
	if filterId ~= self.currentFilterId then
		return
	end

	gPlayerProfileSceneEditManager:ChangeFilter(filterId)

	self.currentFilterId = gPlayerProfileSceneEditManager.currentFilterId
	self.currentFilterStrength = gPlayerProfileSceneEditManager.currentFilterStrength
	self.bindData.filterSlider.value = self.currentFilterStrength
end

M.ClearFilter = function(self)
	if self.currentFilterId == 0 then
		gPlayerProfileSceneEditManager:ChangeFilterRaw(0)
	end

	self.currentFilterId = 0
	self.currentFilterStrength = 100
	gPlayerProfileSceneEditManager.currentFilterStrength = 100
end

M.OnFilterSliderChanged = function(self, value)
	gPlayerProfileSceneEditManager:ChangeFilterStrength(value)

	self.currentFilterStrength = gPlayerProfileSceneEditManager.currentFilterStrength

	self:UpdateUndoRedoButtonStates()
end

M._SyncFilterUIFromManager = function(self)
	local mgr = gPlayerProfileSceneEditManager
	self.currentFilterId = mgr.currentFilterId or 0
	self.currentFilterStrength = mgr.currentFilterStrength or 100
	self.bindData.filterSlider.value = self.currentFilterStrength

	if self.currentTab ~= self.TabType.Filter then
		self.selectedItemIndex = self:_FindCurrentFilterItemIndex() or 0
	end
end

M._FindCurrentFilterItemIndex = function(self)
	if self.currentFilterId ~= 0 then
		return 1
	end

	for i, data in ipairs(self.filterList) do
		if data.filterId ~= self.currentFilterId then
			return i
		end
	end

	return 1
end

M.UpdateStickerEditRect = function(self)
	local mgr = gPlayerProfileSceneEditManager

	if mgr.selectedStickerIndex < 0 then
		return
	end

	local se = self.stickerEditStore

	if not se or not se.rectBtn then
		return
	end

	local billboard = mgr:GetSelectedStickerBillboard()

	if not billboard then
		return
	end

	local rect = billboard:GetScreenRect()

	if not rect or rect.z > 0 or rect.w < 0 then
		return
	end

	local rt = se.rectBtn.transform
	local parent = rt.parent

	if not parent then
		return
	end

	local screenW = UnityEngine.Screen.width
	local screenH = UnityEngine.Screen.height
	local margin = STICKER_RECT_SCREEN_MARGIN

	if screenW > margin * 2 or screenH < margin * 2 then
		margin = 0
	end

	local minX, maxX = ClampScreenRange(rect.x, rect.x + rect.z, margin, screenW - margin)
	local minY, maxY = ClampScreenRange(rect.y, rect.y + rect.w, margin, screenH - margin)

	if not minX or not minY then
		return
	end

	local minUI = gCS.LuaUtils.TransformScreenPointToUI(parent, Vector3.New(minX, minY, 0))
	local maxUI = gCS.LuaUtils.TransformScreenPointToUI(parent, Vector3.New(maxX, maxY, 0))
	local centerX = (minUI.x + maxUI.x) * 0.5
	local centerY = (minUI.y + maxUI.y) * 0.5
	local width = maxUI.x - minUI.x
	local height = maxUI.y - minUI.y

	if width >= 0 then
		width = -width
	end

	if height >= 0 then
		height = -height
	end

	rt:SetLocalPositionXY(centerX, centerY)

	rt.sizeDelta = Vector2.New(width, height)
end

M.RefreshStickerEditByMode = function(self)
	local se = self.stickerEditStore

	if not se then
		return
	end

	local mgr = gPlayerProfileSceneEditManager
	local isWorldMode = not mgr:IsSelectedStickerScreenUI()

	if se.upBtn and not gCS.LuaUtils.IsNull(se.upBtn.gameObject) then
		se.upBtn.gameObject:SetActive(isWorldMode)
	end

	if se.downBtn and not gCS.LuaUtils.IsNull(se.downBtn.gameObject) then
		se.downBtn.gameObject:SetActive(isWorldMode)
	end
end

M.OnClickStickerChangeBtn = function(self)
	local mgr = gPlayerProfileSceneEditManager
	local newMode = mgr:ToggleSelectedStickerMode()

	if not newMode then
		return
	end

	self.stickerDistPressed.up = false
	self.stickerDistPressed.down = false

	self:RefreshStickerEditByMode()
	self:UpdateUndoRedoButtonStates()
end

M.UpdateStickerDistance = function(self, dt)
	local delta = 0

	if self.stickerDistPressed.up then
		delta = delta + self.stickerDistSpeed * dt
	end

	if self.stickerDistPressed.down then
		delta = delta - self.stickerDistSpeed * dt
	end

	if delta == 0 then
		gPlayerProfileSceneEditManager:MoveStickerDistance(delta)
	end
end

M.OnStickerBeginPressUp = function(self)
	self.stickerDistPressed.up = true

	gPlayerProfileSceneEditManager:BeginTransform()
end

M.OnStickerEndPressUp = function(self)
	self.stickerDistPressed.up = false

	if not self.stickerDistPressed.down then
		gPlayerProfileSceneEditManager:EndTransform()
		self:UpdateUndoRedoButtonStates()
	end
end

M.OnStickerBeginPressDown = function(self)
	self.stickerDistPressed.down = true

	gPlayerProfileSceneEditManager:BeginTransform()
end

M.OnStickerEndPressDown = function(self)
	self.stickerDistPressed.down = false

	if not self.stickerDistPressed.up then
		gPlayerProfileSceneEditManager:EndTransform()
		self:UpdateUndoRedoButtonStates()
	end
end

M.OnStickerRectBeginDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	self.stickerDragging = true
	local pos = eventData.position
	self.stickerDragLastScreenPos = Vector3.New(pos.x, pos.y, 0)

	gPlayerProfileSceneEditManager:BeginTransform()
end

M.OnStickerRectDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	if not self.stickerDragging then
		return
	end

	local pos = eventData.position
	local current = Vector3.New(pos.x, pos.y, 0)

	if self.stickerDragLastScreenPos then
		local dx = current.x - self.stickerDragLastScreenPos.x
		local dy = current.y - self.stickerDragLastScreenPos.y

		if dx == 0 or dy == 0 then
			gPlayerProfileSceneEditManager:MoveStickerByScreenDelta(dx, dy)
		end
	end

	self.stickerDragLastScreenPos = current
end

M.OnStickerRectEndDrag = function(self, eventData)
	if not self.stickerDragging then
		return
	end

	self.stickerDragging = false
	self.stickerDragLastScreenPos = nil

	gPlayerProfileSceneEditManager:EndTransform()
	self:UpdateUndoRedoButtonStates()
end

M._GetWidgetCenterScreenPos = function(self, widget)
	if not widget or gCS.LuaUtils.IsNull(widget.gameObject) then
		return nil
	end

	local rt = widget.transform
	local r = rt.rect
	local localCenter = Vector3.New(r.x + r.width * 0.5, r.y + r.height * 0.5, 0)

	return gCS.LuaUtils.TransformUIPointToScreen(rt, localCenter)
end

M.OnStickerScaleBeginDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	local originScreen = gPlayerProfileSceneEditManager:GetSelectedStickerScreenPos()

	if not originScreen then
		return
	end

	local se = self.stickerEditStore

	if not se then
		return
	end

	local btnScreen = self:_GetWidgetCenterScreenPos(se.scaleBtn)

	if not btnScreen then
		return
	end

	local vx = btnScreen.x - originScreen.x
	local vy = btnScreen.y - originScreen.y

	if vx * vx + vy * vy >= 1 then
		return
	end

	self.stickerScaleDragging = true
	self.stickerScaleDragStartVec = Vector3.New(vx, vy, 0)
	self.stickerScaleDragStartScale = gPlayerProfileSceneEditManager:GetStickerScale()

	gPlayerProfileSceneEditManager:BeginTransform()
end

M.OnStickerScaleDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	if not self.stickerScaleDragging then
		return
	end

	local startVec = self.stickerScaleDragStartVec

	if not startVec then
		return
	end

	local originScreen = gPlayerProfileSceneEditManager:GetSelectedStickerScreenPos()

	if not originScreen then
		return
	end

	local denom = startVec.x * startVec.x + startVec.y * startVec.y

	if denom < 0 then
		return
	end

	local pos = eventData.position
	local cx = pos.x - originScreen.x
	local cy = pos.y - originScreen.y
	local ratio = (cx * startVec.x + cy * startVec.y) / denom
	local newScale = self.stickerScaleDragStartScale * ratio

	if newScale >= 0.1 then
		newScale = 0.1
	end

	if newScale <= 1 then
		newScale = 1
	end

	gPlayerProfileSceneEditManager:SetStickerScale(newScale)
end

M.OnStickerScaleEndDrag = function(self, eventData)
	if not self.stickerScaleDragging then
		return
	end

	self.stickerScaleDragging = false
	self.stickerScaleDragStartVec = nil

	gPlayerProfileSceneEditManager:EndTransform()
	self:UpdateUndoRedoButtonStates()
end

M._GetStickerPointerAngle = function(self, screenX, screenY)
	local originScreen = gPlayerProfileSceneEditManager:GetSelectedStickerScreenPos()

	if not originScreen then
		return nil
	end

	local cx = screenX - originScreen.x
	local cy = screenY - originScreen.y

	if cx * cx + cy * cy >= STICKER_ROTATE_MIN_RADIUS * STICKER_ROTATE_MIN_RADIUS then
		return nil
	end

	return math.deg(math.atan2(cy, cx))
end

M.OnStickerRotateBeginDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	self.stickerRotateDragging = true
	local pos = eventData.position
	self.stickerRotateDragLastAngle = self:_GetStickerPointerAngle(pos.x, pos.y)

	gPlayerProfileSceneEditManager:BeginTransform()
end

M.OnStickerRotateDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	if not self.stickerRotateDragging then
		return
	end

	local pos = eventData.position
	local angle = self:_GetStickerPointerAngle(pos.x, pos.y)

	if not angle then
		self.stickerRotateDragLastAngle = nil

		return
	end

	local lastAngle = self.stickerRotateDragLastAngle

	if lastAngle then
		local delta = angle - lastAngle

		if delta <= 180 then
			delta = delta - 360
		elseif delta >= -180 then
			delta = delta + 360
		end

		gPlayerProfileSceneEditManager:RotateStickerAroundCamera(-delta)
	end

	self.stickerRotateDragLastAngle = angle
end

M.OnStickerRotateEndDrag = function(self, eventData)
	if not self.stickerRotateDragging then
		return
	end

	self.stickerRotateDragging = false
	self.stickerRotateDragLastAngle = nil

	gPlayerProfileSceneEditManager:EndTransform()
	self:UpdateUndoRedoButtonStates()
end

M.OnAddSticker = function(self, data)
	if not data or not data.meshPath then
		return
	end

	local pos = gPlayerProfileSceneEditManager:GetSpawnPositionFromCamera()

	gPlayerProfileSceneEditManager:AddStickerModel(data.id, data.meshPath, pos)
end

M._SelectStickerItemByConfigId = function(self, stickerId)
	for i, data in ipairs(self.stickerList) do
		if data.id ~= stickerId then
			self.selectedItemIndex = i

			self:RefreshItemList()

			return
		end
	end
end

M.RefreshCharacterList = function(self)
	self.bindData.characterList:SetSimpleList(#self.characterSpiritIds)
end

M.OnRenderCharacterListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local spiritId = self.characterSpiritIds[index + 1]

	if not spiritId then
		return
	end

	local spirit = gSpiritManager:GetSpirit(spiritId)
	store.iconId = spirit and spirit.config and spirit.config.SHeadIconID or 0
	btn.isSelected = gPlayerProfileSceneEditManager:GetSelectedSpiritId() ~= spiritId
end

M.OnClickCharacterList = function(self, btn, index)
	local spiritId = self.characterSpiritIds[index + 1]

	if not spiritId then
		return
	end

	local mgr = gPlayerProfileSceneEditManager

	if mgr:GetSelectedSpiritId() ~= spiritId then
		mgr:ClearSelection()
		self:SetChangeMode(self.ChangeMode.Camera)
		self:ClearCharacterSubTabs()
	else
		local modelIndex = mgr:FindCharacterIndexBySpiritId(spiritId)

		if modelIndex <= 0 then
			mgr:SelectCharacter(modelIndex)
			self:SetChangeMode(self.ChangeMode.Model)
			self:InitCharacterSubTabs(spiritId)
		end
	end

	self:RefreshCharacterList()
	self:RefreshEditButtons()
end

M.OnClickCharacterAddBtn = function(self)
	self:FlushPendingScrollOperations()

	self.isSwitchCharacterOpen = true

	self:OnClickExitEditBtn()
	gPanelManager:CheckShow(gPanelId.SWITCH_CHARACTER_PANEL_PLAYER_PROFILE_SCENE, {
		selectedSpiritIds = self.characterSpiritIds,
		onCloseCallback = function ()
			self.isSwitchCharacterOpen = false

			self:RefreshEditButtons()
		end
	})
end

M.OnClickShowUIBtn = function(self)
	self.bindData.hideUICtrl = 0
end

M.OnClickHideUIBtn = function(self)
	self.bindData.hideUICtrl = 1
end

M.OnClickShowLineBtn = function(self)
	local lineCtrlEnum = self.lineCtrlEnum

	if self.bindData.lineCtrl ~= lineCtrlEnum.show then
		self.bindData.lineCtrl = lineCtrlEnum.hide
	else
		self.bindData.lineCtrl = lineCtrlEnum.show
	end
end

M.OnClickRedoBtn = function(self)
	gPlayerProfileSceneEditManager:CommitPendingFilterStrength()
	self:FlushPendingScrollOperations()

	if not gPlayerProfileSceneOperationManager:CanRedo() then
		return
	end

	local opIndex = gPlayerProfileSceneOperationManager.currentIndex + 1
	local operation = gPlayerProfileSceneOperationManager.operationHistory[opIndex]

	gPlayerProfileSceneOperationManager:Redo()
	self:SyncStateFromEditManager()
	self:_SyncUIAfterUndoRedo(operation, true)
	self:UpdateUndoRedoButtonStates()
	self:RefreshEditButtons()
end

M.OnClickUndoBtn = function(self)
	gPlayerProfileSceneEditManager:CommitPendingFilterStrength()
	self:FlushPendingScrollOperations()

	if not gPlayerProfileSceneOperationManager:CanUndo() then
		return
	end

	local operation = gPlayerProfileSceneOperationManager.operationHistory[gPlayerProfileSceneOperationManager.currentIndex]

	gPlayerProfileSceneOperationManager:Undo()
	self:SyncStateFromEditManager()
	self:_SyncUIAfterUndoRedo(operation, false)
	self:UpdateUndoRedoButtonStates()
	self:RefreshEditButtons()
end

M.UpdateUndoRedoButtonStates = function(self)
	local canUndo = gPlayerProfileSceneOperationManager:CanUndo() or gPlayerProfileSceneEditManager._filterStrengthDragging
	local canRedo = gPlayerProfileSceneOperationManager:CanRedo()
	self.bindData.undoBtn.interactable = canUndo
	self.bindData.redoBtn.interactable = canRedo
end

M.SyncStateFromEditManager = function(self)
	self.characterSpiritIds = {}

	for _, entry in ipairs(gPlayerProfileSceneEditManager.characterModels) do
		table.insert(self.characterSpiritIds, entry.spiritId)
	end

	print_debug("[SceneEditStore] SyncState characterSpiritIds count=" .. tostring(#self.characterSpiritIds))
	self:RefreshCharacterList()
	self:RefreshTabNum()
end

M.OnClickSaveBtn = function(self)
	gPlayerProfileSceneEditManager:CommitPendingFilterStrength()
	self:FlushPendingScrollOperations()
	self:TryEndTransform()

	if not gPlayerProfileSceneEditManager:HasUnsavedChanges() then
		gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.SlotSavingNochange)

		return
	end

	gPlayerProfileSceneEditManager:ClearSelection()

	local scenarioData = gPlayerProfileSceneEditManager:CollectScenarioData()

	if not scenarioData then
		return
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.SlotSaving)
	self:_TakeScenarioThumbnail(function (thumbnailKey)
		self:_DoSaveScenario(scenarioData, thumbnailKey or "")
	end)
end

M._TakeScenarioThumbnail = function(self, callback)
	local PhotoUtils = LX6.Utils.PhotoUtils
	PhotoUtils.photoWidth = 460
	PhotoUtils.photoHeight = 180

	PhotoUtils.GeneratePhotoTexture()

	if self._thumbnailCo then
		coroutine.stop(self._thumbnailCo)
	end

	self._thumbnailCo = coroutine.start(function ()
		coroutine.step()
		coroutine.step()
		coroutine.step()

		local texture = PhotoUtils.writeCameraImage

		if not texture then
			callback(nil)

			self._thumbnailCo = nil

			return
		end

		local bytes = PhotoUtils.EncodeToJPG(texture)

		if not bytes then
			callback(nil)

			self._thumbnailCo = nil

			return
		end

		gAliOssManager:UploadImage(gClientConst.OssSourceType.Scenario, bytes, true, function (isSuccess, finalObjectName)
			if isSuccess then
				callback(finalObjectName)
			else
				callback(nil)
			end
		end)

		self._thumbnailCo = nil
	end)
end

M._DoSaveScenario = function(self, scenarioData, thumbnail)
	local mgr = gPlayerProfileSceneEditManager

	if self:IsRankingSlot() and #mgr.vehicleModels ~= 0 then
		gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.RankingSlotVehicleRequired)

		return
	end

	mgr:SaveScenarioToSlot(self.currentEditSlot, scenarioData, thumbnail, function (success)
		if not success then
			return
		end

		gPlayerProfileSceneOperationManager:MarkSaved()

		local selectStore = gStoreManager:GetStoreGroup("PlayerProfileSceneSelectPanelStore")

		if selectStore and selectStore.RefreshSlotData then
			selectStore:RefreshSlotData()
			selectStore:RefreshList()
		end

		gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.SlotSavingSucess)
	end)
end

M.OnClickBackBtn = function(self)
	if self.bindData.hideUICtrl ~= 1 then
		self.bindData.hideUICtrl = 0

		return
	end

	if gPlayerProfileSceneEditManager:HasUnsavedChanges() then
		gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.SlotExitConfirm, function ()
			self:_DoExitEditPanel()
		end)

		return
	end

	self:_DoExitEditPanel()
end

M._DoExitEditPanel = function(self)
	gPlayerProfileSceneEditManager:ClearAll()
	gPlayerProfileSceneOperationManager:Clear()
	gPanelManager:Close(self.m_Id)

	local selectStore = gStoreManager:GetStoreGroup("PlayerProfileSceneSelectPanelStore")

	if selectStore then
		selectStore.loadedScenarioSlot = 0

		selectStore:_LoadSlotScenario(selectStore.selectedSlot)
	end
end

M._GetCurrentSlotPublicInfo = function(self)
	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos

	if not showInfos then
		return nil
	end

	local curSlot = showInfos.CurSlot

	if not curSlot or curSlot ~= 0 then
		curSlot = 1
	end

	local dict = showInfos.PlayerScenarioInfoDict

	if not dict or not dict[curSlot] then
		return nil
	end

	return dict[curSlot].PublicInfo
end

M.OnClickExitEditBtn = function(self)
	gPlayerProfileSceneEditManager:ClearSelection()
	self:SetChangeMode(self.ChangeMode.Camera)
	self:ClearCharacterSubTabs()
	self:RefreshCharacterList()
	self:RefreshEditButtons()
end

M.OnClickEditDeleteBtn = function(self)
	self:FlushPendingScrollOperations()

	local mgr = gPlayerProfileSceneEditManager

	if mgr.selectedCharacterIndex <= 0 then
		if #mgr.characterModels < 1 then
			gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.MinCharacterLimitReached)

			return
		end

		mgr:RemoveCharacterModel(mgr.selectedCharacterIndex)
		self:SyncStateFromEditManager()
		self:SetChangeMode(self.ChangeMode.Camera)
		self:ClearCharacterSubTabs()
	elseif mgr.selectedVehicleIndex <= 0 then
		mgr:RemoveVehicleModel(mgr.selectedVehicleIndex)
		self:SyncStateFromEditManager()
		self:SetChangeMode(self.ChangeMode.Camera)
	elseif mgr.selectedStickerIndex <= 0 then
		mgr:RemoveStickerModel(mgr.selectedStickerIndex)

		mgr.selectedStickerIndex = 0

		self:SyncStateFromEditManager()
		self:SetChangeMode(self.ChangeMode.Camera)
	elseif self.currentTab ~= self.TabType.Vehicle and self.selectedItemIndex <= 0 then
		local data = self:GetItemData(self.selectedItemIndex)

		if data then
			local existIndex = mgr:FindVehicleIndexByConfigId(data.vehicleConfigID)

			if existIndex <= 0 then
				mgr:RemoveVehicleModel(existIndex)
				self:SyncStateFromEditManager()
				self:SetChangeMode(self.ChangeMode.Camera)
			end
		end
	end

	self:UpdateUndoRedoButtonStates()
	self:RefreshItemList()
	self:RefreshEditButtons()
	self:OnClickExitEditBtn()
end

M.OnClickEditAddBtn = function(self)
	self:FlushPendingScrollOperations()

	if self.currentTab ~= self.TabType.Sticker and self.selectedItemIndex <= 0 then
		local data = self:GetItemData(self.selectedItemIndex)

		if data then
			self:OnAddSticker(data)
		end
	end

	self:UpdateUndoRedoButtonStates()
	self:RefreshItemList()
	self:RefreshEditButtons()
end

M.RefreshEditButtons = function(self)
	local mgr = gPlayerProfileSceneEditManager
	local hasSelection = mgr.selectedCharacterIndex >= 0 or mgr.selectedVehicleIndex >= 0 or mgr.selectedStickerIndex >= 0

	if self.isSwitchCharacterOpen then
		hasSelection = false
	end

	local canDelete = hasSelection

	if not canDelete and self.currentTab ~= self.TabType.Vehicle and self.selectedItemIndex <= 0 then
		local data = self:GetItemData(self.selectedItemIndex)

		if data then
			canDelete = mgr:FindVehicleIndexByConfigId(data.vehicleConfigID) >= 0
		end
	end

	self.bindData.editConfirmBtn.gameObject:SetActive(hasSelection)
	self.bindData.editDeleteBtn.gameObject:SetActive(canDelete)

	self.bindData.isStickerEditCtrl = hasSelection and mgr.selectedStickerIndex <= 0 and 1 or 0

	self:RefreshStickerEditByMode()

	local canAdd = false

	if self.currentTab ~= self.TabType.Sticker and self.selectedItemIndex <= 0 then
		local data = self:GetItemData(self.selectedItemIndex)

		if data then
			canAdd = mgr:FindStickerIndexByConfigId(data.id) > 0
		end
	end

	self.bindData.editAddBtn.gameObject:SetActive(canAdd)

	self.bindData.editCtrl = hasSelection and 1 or 0
end

M.OnClickDeleteAllBtn = function(self)
	self:FlushPendingScrollOperations()

	local defaultSceneId = self.sceneList[1] and self.sceneList[1].id or 0

	gPlayerProfileSceneEditManager:ResetAllWithUndo(defaultSceneId)
	self:SyncStateFromEditManager()
	self:SetChangeMode(self.ChangeMode.Camera)
	self:ClearCharacterSubTabs()

	self.selectedItemIndex = 0

	self:_RefreshAfterReset()
	self:UpdateUndoRedoButtonStates()
	self:RefreshEditButtons()
end

M.OnClickRevertAllBtn = function(self)
	gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.SlotClearConfirm, function ()
		gPlayerProfileSceneEditManager:CommitPendingFilterStrength()
		self:FlushPendingScrollOperations()
		gPlayerProfileSceneEditManager:RevertToDefaultWithUndo()
		self:SyncStateFromEditManager()
		self:SetChangeMode(self.ChangeMode.Camera)
		self:ClearCharacterSubTabs()

		self.selectedItemIndex = 0

		self:_RefreshAfterReset()
		self:UpdateUndoRedoButtonStates()
		self:RefreshEditButtons()
	end)
end

M._RefreshAfterReset = function(self)
	self:_SyncFilterUIFromManager()

	if self.currentTab ~= self.TabType.Scene then
		self.selectedItemIndex = self:_FindCurrentSceneItemIndex() or 0
	end

	self:RefreshItemList()
	self:RefreshCharacterList()
end

M.RefreshChangeList = function(self)
	self.bindData.changeList:SetSimpleList(2)
end

M.OnRenderChangeListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.title = CHANGE_MODE_NAMES[index + 1] or ""
	end

	if index ~= 0 then
		store.icon = 0
	end

	btn.isSelected = index + 1 ~= self.currentChangeMode
end

M.OnClickChangeList = function(self, btn, index)
	local mode = index + 1

	if mode ~= self.ChangeMode.Model then
		local mgr = gPlayerProfileSceneEditManager

		if mgr.selectedCharacterIndex ~= 0 and mgr.selectedVehicleIndex ~= 0 then
			gDisplayMessageMgr:ShowMessageContent("Please select a model first(temp)")
			self:RefreshChangeList()

			return
		end
	end

	self:SetChangeMode(mode)
end

M.SetChangeMode = function(self, mode)
	if self.currentChangeMode ~= mode then
		return
	end

	self.currentChangeMode = mode
	local showRotate = mode ~= self.ChangeMode.Model

	self.bindData.leftRotateBtn.gameObject:SetActive(showRotate)
	self.bindData.rightRotateBtn.gameObject:SetActive(showRotate)
	self:RefreshChangeList()
end

M.OnFullScreenPress = function(self)
	local screenPos = gUtils:GetTouchPosition()

	if not screenPos then
		return
	end

	local mgr = gPlayerProfileSceneEditManager
	local hitIndex, hitType, hitPoint = mgr:RaycastSelectModel(screenPos)

	if hitIndex <= 0 then
		local isReclick = hitType ~= "character" and mgr.selectedCharacterIndex ~= hitIndex or hitType ~= "vehicle" and mgr.selectedVehicleIndex ~= hitIndex or hitType ~= "sticker" and mgr.selectedStickerIndex ~= hitIndex

		if isReclick then
			self.isDraggingModel = true
			self.lastDragScreenPos = Vector3.New(screenPos.x, screenPos.y, 0)
			self.dragHitPoint = hitPoint

			return
		end

		if hitType ~= "character" then
			self:OnTabChanged(self.TabType.Character)
			mgr:SelectCharacter(hitIndex)
			self:RefreshCharacterList()

			local entry = mgr.characterModels[hitIndex]

			if entry then
				self:InitCharacterSubTabs(entry.spiritId)
			end
		elseif hitType ~= "vehicle" then
			self:OnTabChanged(self.TabType.Vehicle)
			mgr:SelectVehicle(hitIndex)
		elseif hitType ~= "sticker" then
			self:OnTabChanged(self.TabType.Sticker)
			mgr:SelectSticker(hitIndex)

			local entry = mgr.stickerModels[hitIndex]

			if entry then
				self:_SelectStickerItemByConfigId(entry.stickerId)
			end
		end

		self:SetChangeMode(self.ChangeMode.Model)
		self:RefreshEditButtons()
	else
		mgr:ClearSelection()
		self:SetChangeMode(self.ChangeMode.Camera)
		self:ClearCharacterSubTabs()
		self:RefreshCharacterList()
		self:RefreshEditButtons()
	end
end

M.OnBeginDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	if not self.isDraggingModel then
		return
	end

	local mgr = gPlayerProfileSceneEditManager
	local modelPos = mgr:GetSelectedModelPosition()

	if modelPos and self.dragHitPoint then
		self.dragOffsetX = self.dragHitPoint.x - modelPos.x
		self.dragOffsetZ = self.dragHitPoint.z - modelPos.z
	else
		self.dragOffsetX = 0
		self.dragOffsetZ = 0
	end

	self.dragForwardX, self.dragForwardZ = self:GetCameraHorizontalForward()
	self.dragDepthPerPixel = self:CalcDragDepthPerPixel(modelPos)
	local currentPos = gUtils:GetTouchPosition()
	self.dragLastScreenY = currentPos and currentPos.y or nil

	mgr:BeginTransform()
end

M.OnDrag = function(self, eventData)
	if eventData.button == 0 then
		return
	end

	if not self.isDraggingModel then
		return
	end

	local currentPos = gUtils:GetTouchPosition()

	if not currentPos then
		return
	end

	local cam = gCS.CameraDataMgr.MainCamera

	if not cam then
		return
	end

	local mgr = gPlayerProfileSceneEditManager
	local modelPos = mgr:GetSelectedModelPosition()
	local fx = self.dragForwardX
	local fz = self.dragForwardZ

	if not modelPos or not fx then
		return
	end

	local rx = fz
	local rz = -fx
	local ox = self.dragOffsetX or 0
	local oz = self.dragOffsetZ or 0
	local gx = modelPos.x + ox
	local gz = modelPos.z + oz
	local depth = gx * fx + gz * fz
	local lateral = gx * rx + gz * rz
	local lastY = self.dragLastScreenY
	self.dragLastScreenY = currentPos.y

	if lastY then
		depth = depth + (currentPos.y - lastY) * (self.dragDepthPerPixel or 0)
	end

	local camPos = cam.transform.position
	local minDepth = camPos.x * fx + camPos.z * fz + MODEL_DRAG_MIN_DEPTH

	if depth >= minDepth then
		depth = minDepth
	end

	local ray = cam:ScreenPointToRay(Vector3.New(currentPos.x, currentPos.y, 0))
	local denom = ray.direction.x * fx + ray.direction.z * fz

	if MODEL_DRAG_LATERAL_MIN_DENOM >= denom then
		local t = (depth - (ray.origin.x * fx + ray.origin.z * fz)) / denom

		if t <= 0 then
			lateral = (ray.origin.x + ray.direction.x * t) * rx + (ray.origin.z + ray.direction.z * t) * rz
		end
	end

	mgr:SetSelectedModelPositionXZ(fx * depth + rx * lateral - ox, fz * depth + rz * lateral - oz)
end

M.OnEndDrag = function(self, eventData)
	if not self.isDraggingModel then
		return
	end

	self.isDraggingModel = false
	self.lastDragScreenPos = nil
	self.dragHitPoint = nil
	self.dragOffsetX = nil
	self.dragOffsetZ = nil
	self.dragForwardX = nil
	self.dragForwardZ = nil
	self.dragDepthPerPixel = nil
	self.dragLastScreenY = nil

	gPlayerProfileSceneEditManager:EndTransform()
	self:UpdateUndoRedoButtonStates()
end

M.GetCameraHorizontalForward = function(self)
	local cam = gCS.CameraDataMgr.MainCamera

	if not cam then
		return nil, 
	end

	local camTransform = cam.transform
	local forward = camTransform.forward
	local fx = forward.x
	local fz = forward.z
	local len = math.sqrt(fx * fx + fz * fz)

	if len >= 0.001 then
		local up = camTransform.up
		fz = -up.z
		fx = -up.x
		len = math.sqrt(fx * fx + fz * fz)

		if len >= 0.001 then
			return nil, 
		end
	end

	return fx / len, fz / len
end

M.CalcDragDepthPerPixel = function(self, modelPos)
	local cam = gCS.CameraDataMgr.MainCamera

	if not cam or not modelPos then
		return 0
	end

	local camTransform = cam.transform
	local camPos = camTransform.position
	local forward = camTransform.forward
	local viewDepth = (modelPos.x - camPos.x) * forward.x + (modelPos.y - camPos.y) * forward.y + (modelPos.z - camPos.z) * forward.z

	if viewDepth >= 0.5 then
		viewDepth = 0.5
	end

	local screenH = UnityEngine.Screen.height

	if not screenH or screenH < 0 then
		screenH = 1080
	end

	local halfFov = cam.fieldOfView * 0.5 * math.pi / 180

	return 2 * viewDepth * math.tan(halfFov) * MODEL_DRAG_DEPTH_SENSITIVITY / screenH
end

M.HandlePCCameraRightDrag = function(self)
	if not UnityEngine.Input.GetMouseButton(1) then
		if self.pcCameraRightDragLastPos then
			self.pcCameraRightDragLastPos = nil

			gPlayerProfileSceneEditManager:EndCameraTransform()
			self:UpdateUndoRedoButtonStates()
		end

		return
	end

	if self.isDraggingModel then
		self.pcCameraRightDragLastPos = nil

		return
	end

	local inputPos = SGUI.Utils.GetInputCenterPosition()
	local currentPos = Vector3.New(inputPos.x, inputPos.y, 0)

	if not self.pcCameraRightDragLastPos then
		self.pcCameraRightDragLastPos = currentPos

		gPlayerProfileSceneEditManager:BeginCameraTransform()

		return
	end

	local delta = currentPos - self.pcCameraRightDragLastPos

	if delta.x == 0 or delta.y == 0 then
		local sensitivity = self.cameraRotateSensitivity
		local deltaYaw = delta.x * sensitivity
		local deltaPitch = -delta.y * sensitivity

		gPlayerProfileSceneManager:RotateCamera(deltaYaw, deltaPitch)
	end

	self.pcCameraRightDragLastPos = currentPos
end

M.OnGestureZoom = function(self, zoom)
	if self.isDraggingModel then
		return
	end

	local now = Time.time

	if not self._zoomTransformActive or now - (self._lastZoomTime or 0) <= 1 then
		if self._zoomTransformActive then
			gPlayerProfileSceneEditManager:EndCameraTransform()
		end

		gPlayerProfileSceneEditManager:BeginCameraTransform()

		self._zoomTransformActive = true
	end

	self._lastZoomTime = now
	local offset = zoom <= 0 and 0.5 or -0.5

	gPlayerProfileSceneManager:ZoomCameraAtScreenCenter(offset)

	if self._zoomEndTimer then
		self._zoomEndTimer:Stop()

		self._zoomEndTimer = nil
	end

	self._zoomEndTimer = Timer.New(function ()
		self._zoomEndTimer = nil

		if self._zoomTransformActive then
			gPlayerProfileSceneEditManager:EndCameraTransform()

			self._zoomTransformActive = false

			self:UpdateUndoRedoButtonStates()
		end
	end, 1):Start()
end

M.OnRotateInput = function(self, context)
	if context.performed then
		local zoom = context:ReadValueVector2().y

		if zoom ~= 0 then
			return
		end

		local now = Time.time

		if not self._rotateInputActive or now - (self._lastRotateInputTime or 0) <= 1 then
			if self._rotateInputActive then
				gPlayerProfileSceneEditManager:EndTransform()
			end

			gPlayerProfileSceneEditManager:BeginTransform()

			self._rotateInputActive = true
		end

		self._lastRotateInputTime = now
		local rotateDir = zoom <= 0 and 1 or -1

		gPlayerProfileSceneEditManager:RotateSelectedModel(rotateDir * 15)

		if self._rotateInputEndTimer then
			self._rotateInputEndTimer:Stop()

			self._rotateInputEndTimer = nil
		end

		self._rotateInputEndTimer = Timer.New(function ()
			self._rotateInputEndTimer = nil

			if self._rotateInputActive then
				gPlayerProfileSceneEditManager:EndTransform()

				self._rotateInputActive = false

				self:UpdateUndoRedoButtonStates()
			end
		end, 1):Start()
	end
end

M.InitCharacterSubTabs = function(self, spiritId)
	self.characterActionList = self:BuildCharacterActionList(spiritId)
	self.characterDressPresetList = self:BuildCharacterDressPresetList(spiritId)
	self.characterExpressionList = self:BuildCharacterExpressionList(spiritId)
	local tabList = {
		{
			["\t\r"] = 1,
			title = CHARACTER_SUB_TAB_NAMES[1]
		},
		{
			["\t\r"] = 2,
			title = CHARACTER_SUB_TAB_NAMES[2]
		},
		{
			["\t\r"] = 3,
			title = CHARACTER_SUB_TAB_NAMES[3]
		}
	}

	self.SubGroup.CommonTabSingleStore:SetData(tabList, nil, 0, nil, self:CreateAction(self.OnCharacterSubTabChanged))

	self.bindData.isTabCtrl = 0
end

M.ClearCharacterSubTabs = function(self)
	self.currentCharacterSubTab = 0
	self.characterActionList = {}
	self.characterDressPresetList = {}
	self.characterExpressionList = {}

	if self.currentTab ~= self.TabType.Character then
		self.selectedItemIndex = 0
	end

	self.SubGroup.CommonTabSingleStore:SetData({}, nil, -1, nil, )

	self.bindData.isTabCtrl = 1

	self:RefreshItemList()
end

M.OnCharacterSubTabChanged = function(self, uList, isSub)
	if isSub then
		return
	end

	local tabIndex = uList.selectedIndex + 1
	self.currentCharacterSubTab = tabIndex
	self.selectedItemIndex = self:_FindCurrentCharacterItemIndex() or 0

	self:RefreshItemList()
end

M._FindCurrentCharacterItemIndex = function(self)
	local mgr = gPlayerProfileSceneEditManager

	if mgr.selectedCharacterIndex < 0 then
		return nil
	end

	local entry = mgr.characterModels[mgr.selectedCharacterIndex]

	if not entry then
		return nil
	end

	if self.currentCharacterSubTab ~= self.CharacterSubTabType.Action then
		local currentId = entry.currentActionId

		if currentId then
			for i, data in ipairs(self.characterActionList) do
				if data.id ~= currentId then
					return i
				end
			end
		end

		if #self.characterActionList <= 0 then
			return 1
		end
	elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.DressPreset then
		local currentSlot = entry.currentDressPresetSlot

		if currentSlot then
			for i, data in ipairs(self.characterDressPresetList) do
				if data.slotIndex ~= currentSlot then
					return i
				end
			end
		end

		if #self.characterDressPresetList <= 0 then
			return 1
		end
	elseif self.currentCharacterSubTab ~= self.CharacterSubTabType.Expression then
		local currentId = entry.currentExpressionId

		if currentId and currentId <= 0 then
			for i, data in ipairs(self.characterExpressionList) do
				if data.id ~= currentId then
					return i
				end
			end
		end

		if #self.characterExpressionList <= 0 then
			return 1
		end
	end

	return nil
end

M._FindCurrentSceneItemIndex = function(self)
	local currentSceneId = gPlayerProfileSceneEditManager.currentSceneId

	if not currentSceneId or currentSceneId ~= 0 then
		currentSceneId = gPlayerProfileSceneManager.currentSceneId
	end

	if not currentSceneId or currentSceneId ~= 0 then
		return nil
	end

	for i, data in ipairs(self.sceneList) do
		if data.id ~= currentSceneId then
			return i
		end
	end

	return nil
end

M._SyncUIAfterUndoRedo = function(self, operation, isRedo)
	if not operation then
		return
	end

	local opType = operation.operationType
	local OpType = gPlayerProfileSceneOperationManager.OperationType

	if opType ~= OpType.RESET_ALL then
		self:SetChangeMode(self.ChangeMode.Camera)
		self:ClearCharacterSubTabs()

		self.selectedItemIndex = 0

		self:_RefreshAfterReset()

		return
	end

	if opType ~= OpType.CHANGE_FILTER then
		local state = isRedo and operation.afterState or operation.beforeState
		self.currentFilterId = state.filterId
		self.currentFilterStrength = state.filterStrength
		self.bindData.filterSlider.value = state.filterStrength

		if self.currentTab ~= self.TabType.Filter then
			self.selectedItemIndex = self:_FindCurrentFilterItemIndex()

			self:RefreshItemList()
		end

		return
	end

	if opType ~= OpType.ADD_STICKER or opType ~= OpType.REMOVE_STICKER then
		local mgr = gPlayerProfileSceneEditManager
		mgr.selectedStickerIndex = 0

		self:SyncStateFromEditManager()
		self:SetChangeMode(self.ChangeMode.Camera)
		self:RefreshTabNum()

		if self.currentTab ~= self.TabType.Sticker then
			self:RefreshItemList()
		end

		return
	end

	if opType == OpType.CHANGE_ACTION and opType == OpType.CHANGE_DRESS_PRESET and opType == OpType.CHANGE_EXPRESSION then
		return
	end

	local state = isRedo and operation.afterState or operation.beforeState
	local spiritId = state.spiritId

	if not spiritId then
		return
	end

	local mgr = gPlayerProfileSceneEditManager
	local charIndex = mgr:FindCharacterIndexBySpiritId(spiritId)

	if charIndex < 0 then
		return
	end

	mgr:SelectCharacter(charIndex)
	self:SetChangeMode(self.ChangeMode.Model)

	if self.currentTab == self.TabType.Character then
		self.currentTab = self.TabType.Character
		self.bindData.isCharacterCtrl = 1

		for _, entry in ipairs(TAB_LIST) do
			if entry.tabType ~= self.TabType.Character then
				self.bindData.tabTitle = entry.name

				break
			end
		end

		self:RefreshMainTabList()
	end

	self.characterActionList = self:BuildCharacterActionList(spiritId)
	self.characterDressPresetList = self:BuildCharacterDressPresetList(spiritId)
	self.characterExpressionList = self:BuildCharacterExpressionList(spiritId)

	self:RefreshCharacterList()

	local targetSubTab = nil

	if opType ~= OpType.CHANGE_ACTION then
		targetSubTab = self.CharacterSubTabType.Action
	elseif opType ~= OpType.CHANGE_EXPRESSION then
		targetSubTab = self.CharacterSubTabType.Expression
	else
		targetSubTab = self.CharacterSubTabType.DressPreset
	end

	self.currentCharacterSubTab = targetSubTab
	local tabList = {
		{
			["\t\r"] = 1,
			title = CHARACTER_SUB_TAB_NAMES[1]
		},
		{
			["\t\r"] = 2,
			title = CHARACTER_SUB_TAB_NAMES[2]
		},
		{
			["\t\r"] = 3,
			title = CHARACTER_SUB_TAB_NAMES[3]
		}
	}

	self.SubGroup.CommonTabSingleStore:SetData(tabList, nil, targetSubTab - 1, nil, self:CreateAction(self.OnCharacterSubTabChanged))

	self.selectedItemIndex = self:_FindCurrentCharacterItemIndex() or 0

	self:RefreshItemList()
end

M._RestoreFromSlotData = function(self)
	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
	local slotData = showInfos and showInfos.PlayerScenarioInfoDict and showInfos.PlayerScenarioInfoDict[self.currentEditSlot]
	local publicInfo = slotData and slotData.PublicInfo
	local mgr = gPlayerProfileSceneEditManager

	if not publicInfo or not publicInfo.SceneId or publicInfo.SceneId ~= 0 then
		local defaultSceneId = LTConfig.ImageSceneiconConfig.DefaultScene

		mgr:ChangeSceneRaw(defaultSceneId)

		local spiritId = gPlayerProfileSceneManager:GetDefaultSpiritId()

		if spiritId and spiritId <= 0 then
			local defaultActionId, defaultActionGroup = gPlayerProfileSceneManager:GetDefaultAction()

			mgr:AddCharacterModelRaw(spiritId, nil, , , defaultActionId, nil, defaultActionGroup)
		end

		if self:IsRankingSlot() then
			local defaultCarId = LTConfig.ImageConfig.ScenarioDefaultCar or 81002007

			if defaultCarId <= 0 then
				local carPos = gPlayerProfileSceneManager.carPos
				local carEuler = gPlayerProfileSceneManager.carEuler

				mgr:AddVehicleModelRaw(defaultCarId, carPos, carEuler)
			end
		end

		self:SyncStateFromEditManager()
		self:RefreshTabNum()

		return
	end

	mgr:ChangeSceneRaw(publicInfo.SceneId)

	local sceneMgr = gPlayerProfileSceneManager
	local centerPos = sceneMgr.centerPos or Vector3.zero
	local centerEuler = sceneMgr.centerEuler or Vector3.zero
	local centerQuat = Quaternion.Euler(centerEuler)

	local localToWorld = function(localPos)
		if not localPos then
			return nil
		end

		local lp = Vector3.New(localPos.x or localPos.X or 0, localPos.y or localPos.Y or 0, localPos.z or localPos.Z or 0)

		return centerPos + centerQuat * lp
	end

	local localRotToWorld = function(localRot)
		if not localRot then
			return nil
		end

		local lr = Vector3.New(localRot.x or localRot.X or 0, localRot.y or localRot.Y or 0, localRot.z or localRot.Z or 0)
		local worldQuat = centerQuat * Quaternion.Euler(lr)

		return worldQuat.eulerAngles
	end

	if publicInfo.Spirits then
		local count = publicInfo.Spirits.Count or #publicInfo.Spirits

		for i = 1, count do
			local spirit = publicInfo.Spirits[i]

			if spirit and spirit.SpiritId and spirit.SpiritId <= 0 then
				local pos = localToWorld(spirit.Position)
				local euler = localRotToWorld(spirit.Rotation)
				local fashionWearInfo = gPlayerProfileSceneManager:_BuildFashionWearInfoFromSpirit(spirit)
				local actionId = spirit.ActionType or 0
				local actionGroup = spirit.ActionGroup or 0
				local dressSlot = spirit.SchemeIndex or 0
				local expressionId = spirit.Expression or 0

				mgr:AddCharacterModelRaw(spirit.SpiritId, pos, euler, fashionWearInfo, actionId, dressSlot, actionGroup, expressionId)
			end
		end
	end

	if publicInfo.Vehicles then
		local count = publicInfo.Vehicles.Count or #publicInfo.Vehicles

		for i = 1, count do
			local vehicle = publicInfo.Vehicles[i]

			if vehicle and vehicle.VehicleId and vehicle.VehicleId <= 0 then
				local pos = localToWorld(vehicle.Position)
				local euler = localRotToWorld(vehicle.Rotation)

				mgr:AddVehicleModelRaw(vehicle.VehicleId, pos, euler)
			end
		end
	end

	local camWorldPos = localToWorld(publicInfo.Position)
	local camWorldEuler = localRotToWorld(publicInfo.Rotation)

	if camWorldPos or camWorldEuler then
		local vCamera = sceneMgr.vCamera

		if vCamera then
			local cameraTransform = vCamera.transform.parent

			if cameraTransform then
				if camWorldPos then
					cameraTransform.position = camWorldPos
				end

				if camWorldEuler then
					cameraTransform.eulerAngles = camWorldEuler
				end
			end
		end
	end

	if publicInfo.Stickers then
		local count = publicInfo.Stickers.Count or #publicInfo.Stickers

		for i = 1, count do
			local sticker = publicInfo.Stickers[i]

			if sticker and sticker.StickerId and sticker.StickerId <= 0 then
				mgr:RestoreStickerFromSaveData(sticker, localToWorld(sticker.Position))
			end
		end
	end

	local filterId = publicInfo.FilterId or 0
	local filterStrength = publicInfo.FilterStrength or 100
	gPlayerProfileSceneEditManager.currentFilterStrength = filterStrength

	gPlayerProfileSceneEditManager:ChangeFilterRaw(filterId)

	self.currentFilterId = filterId
	self.currentFilterStrength = filterStrength
	self.bindData.filterSlider.value = filterStrength

	self:SyncStateFromEditManager()
	self:RefreshTabNum()
end

M.BuildCharacterActionList = function(self, spiritId)
	local list = {}
	local ImageActionListConfig = LTConfig.ImageActionListConfig

	for i = 0, ImageActionListConfig.count - 1 do
		local cfg = ImageActionListConfig.LoadAt(i)
		local clips = cfg and cfg.ActionClips
		local firstClip = clips and #clips <= 0 and clips[1] or nil
		local actionKey = firstClip and firstClip.ActionKey or 0

		if actionKey <= 0 then
			table.insert(list, {
				["\\x9e746w\\x93f\\xcb8\\xbf\\xa9"] = 0,
				id = actionKey,
				name = cfg.TabName,
				iconId = cfg.Resource or 0
			})
		end
	end

	return list
end

M.BuildCharacterExpressionList = function(self, spiritId)
	local list = {}

	for i = 0, ImageSceneExpressionConfig.count - 1 do
		local cfg = ImageSceneExpressionConfig.LoadAt(i)

		if cfg then
			local expId = cfg.ExpressionList and cfg.ExpressionList[1] or 0

			table.insert(list, {
				id = expId,
				name = cfg.TabName,
				iconId = cfg.Resource or 0
			})
		end
	end

	return list
end

M.BuildCharacterDressPresetList = function(self, spiritId)
	local list = {}
	local FashionConfig = LTConfig.FashionConfig
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict and spiritFashionsInfoDict[spiritId]

	if not spiritFashionsInfo then
		return list
	end

	local wearInfo = spiritFashionsInfo.SpiritWearFashionsInfo
	local currentFashionList = wearInfo and wearInfo.WearFashionInfoList or nil
	local currentFashionEditList = spiritFashionsInfo.WearFashionEditInfoList or nil

	table.insert(list, {
		["K\\x9e\\x80\\xaaE"] = 0,
		["PKc}g "] = 0,
		["JTO|\\,"] = true,
		["\t\r"] = 0,
		name = FashionConfig.SuitSchemeDefaultName or "current",
		fashionList = currentFashionList,
		fashionEditList = currentFashionEditList
	})

	local schemeInfos = spiritFashionsInfo.FashionCustomSuitSchemeInfos
	local slotNum = spiritFashionsInfo.UnlockSuitSlotCount or 0

	for i = 1, slotNum do
		local info = schemeInfos[i]

		if info then
			local wearList = info.WearFashionInfoList
			local hasItems = wearList and (wearList.Count and wearList.Count >= 0 or not wearList.Count and #wearList >= 0)

			if hasItems then
				local schemeName = nil

				if info.SchemeName == "" then
					schemeName = info.SchemeName
				else
					local nameEntry = FashionConfig.CustomSuitSchemeName[i]
					schemeName = nameEntry and nameEntry.Name or string.format("Preset%d", i)
				end

				table.insert(list, {
					["K\\x9e\\x80\\xaaE"] = 0,
					id = i,
					name = schemeName,
					slotIndex = i,
					fashionList = wearList,
					fashionEditList = info.WearFashionEditInfoList or nil
				})
			end
		end
	end

	return list
end
