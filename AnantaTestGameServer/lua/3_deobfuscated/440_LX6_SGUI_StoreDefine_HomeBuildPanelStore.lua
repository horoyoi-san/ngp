C_HomeBuildPanelStore = DefClass("C_HomeBuildPanelStore", C_HomeBuildPanelStore, C_StoreGroup)
GroupName2Class.HomeBuildPanelStore = C_HomeBuildPanelStore
local M = C_HomeBuildPanelStore
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local HouseConfig = LTConfig.HouseConfig
local MessageConfig = LTConfig.MessageConfig

function M:ctor()
	self.furnitureDataTabList = {}
	self.inEdit = false
end

function M:DefineAllVariables()
	self.curMainType = gFurnitureConst.FurnitureMainType.Furniture
end

function M:OnAwake()
	self:DefineAllVariables()
	self:InitFurnitureDataTabList()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.msgEvents = {
		[gEventConstants.HOME_FURNITURE_ENTER_EDIT] = self:CreateActionWithArgs("ChangeEditMode", true),
		[gEventConstants.HOME_FURNITURE_EXIT_EDIT] = self:CreateActionWithArgs("ChangeEditMode", false),
		[gEventConstants.HOME_FURNITURE_OPERATION_CHANGED] = self:CreateAction("UpdateUndoRedoButtonStates"),
		[gEventConstants.HOME_FURNITURE_CAN_PLACE_CHANGED] = self:CreateAction("OnCanPlaceStateChanged"),
		[gEventConstants.HOME_FURNITURE_NUM_CHANGE] = self:CreateActionWithArgs("RefreshFurnitureList", false),
		[gEventConstants.HOME_FURNITURE_EXIT_HOUSE] = self:CreateAction("OnClickCancelBtn")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:RegisterWidget()
	self.bindData.mainTypeList.luaSimpleRenderItem = self:CreateAction("OnRenderMainTypeListItem")
	self.bindData.mainTypeList.luaSimpleClick = self:CreateAction("OnClickMainTypeList")
	self.bindData.mainTypeList.onGetTIndex = self:CreateAction("OnGetMainTypeListTIndex")
	self.bindData.furnitureList.luaSimpleRenderItem = self:CreateAction("OnRenderFurnitureListItem")
	self.bindData.furnitureList.luaSimpleClick = self:CreateAction("OnClickFurnitureList")
	self.bindData.furnitureList.onGetTIndex = self:CreateAction("OnGetFurnitureListTIndex")
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.cancelBtn.luaClick = self:CreateAction("OnClickCancelBtn")
	self.bindData.storageBtn.luaClick = self:CreateAction("OnClickStorageBtn")
	self.bindData.rotateBtn.luaClick = self:CreateAction("OnClickRotateBtn")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnClickConfirmBtn")
	self.bindData.undoBtn.luaClick = self:CreateAction("OnClickUndoBtn")
	self.bindData.redoBtn.luaClick = self:CreateAction("OnClickRedoBtn")
	self.bindData.saveBtn.luaClick = self:CreateAction("OnClickSaveBtn")
	self.bindData.settingBtn.luaClick = self:CreateAction("OnClickSettingBtn")
	self.bindData.fullScreenBtn.luaPress = self:CreateActionWithArgs("OnLongPressFullScreenBtn", true)
	self.bindData.fullScreenBtn.luaRelease = self:CreateActionWithArgs("OnLongPressFullScreenBtn", false)
	local fullScreenBtn = SGUI.EventSystems.DragEventListener.Get(self.bindData.fullScreenBtn.gameObject)
	fullScreenBtn.onBeginDrag = self:CreateAction("onBeginDrag")
	fullScreenBtn.onDrag = self:CreateAction("onDrag")
	fullScreenBtn.onEndDrag = self:CreateAction("onEndDrag")
	self.bindData.cameraJoyStick.luaValueChanged = self:CreateAction("OnCameraJoyStickMove")
	self.bindData.cameraJoyStick.autoResetHandle = true
	self.bindData.upBtn.luaBeginLongPress = self:CreateAction("OnBeginPressUpBtn")
	self.bindData.upBtn.luaEndLongPress = self:CreateAction("OnEndPressUpBtn")
	self.bindData.downBtn.luaBeginLongPress = self:CreateAction("OnBeginPressDownBtn")
	self.bindData.downBtn.luaEndLongPress = self:CreateAction("OnEndPressDownBtn")
	local gestureListener = self.bindData.fullScreenBtn.transform:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))
	gestureListener.onZoom = self:CreateAction("OnGestureZoom")

	if self.bindData.wBtn then
		self.bindData.wBtn.luaBeginLongPress = self:CreateActionWithArgs("OnWASDMove", {
			false,
			1
		})
		self.bindData.wBtn.luaEndLongPress = self:CreateActionWithArgs("OnWASDMove", {
			false,
			0,
			true
		})
		self.bindData.sBtn.luaBeginLongPress = self:CreateActionWithArgs("OnWASDMove", {
			false,
			-1
		})
		self.bindData.sBtn.luaEndLongPress = self:CreateActionWithArgs("OnWASDMove", {
			false,
			0,
			false
		})
		self.bindData.aBtn.luaBeginLongPress = self:CreateActionWithArgs("OnWASDMove", {
			true,
			-1
		})
		self.bindData.aBtn.luaEndLongPress = self:CreateActionWithArgs("OnWASDMove", {
			true,
			0,
			false
		})
		self.bindData.dBtn.luaBeginLongPress = self:CreateActionWithArgs("OnWASDMove", {
			true,
			1
		})
		self.bindData.dBtn.luaEndLongPress = self:CreateActionWithArgs("OnWASDMove", {
			true,
			0,
			true
		})
	end
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.isUp = false
	self.isDown = false
	self.isCameraJoyStickActive = false
	self.cameraJoyStickX = 0
	self.cameraJoyStickY = 0
	self.cameraJoyStickSize = 0
	self.saved = true

	self.bindData.mainTypeList:SetSimpleList(#self.mainTypeTabList)
	self:RefreshFurnitureList()
	gFurnitureManager:SetEditPlacedFurnitureMode(true)
	self:UpdateUndoRedoButtonStates()

	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("homeBuildPanel")

	cmRegister:EnableVCamera("FurnitureCamera", LX6.Cinemachine.EVcamPriority.Panel)
	LX6.Manager.GameInputManager.SetDisableInput(self.panelId, false, false, true)
	gCS.MyPlayerManager.PlayerUnit.PlayerObj.gameObject:SetActive(false)

	local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager

	CSFurnitureManager.SetBuildMode(true)
end

function M:OnClose()
	gCS.MyPlayerManager.PlayerUnit.PlayerObj.gameObject:SetActive(true)

	self.furnitureDataTabList = {}

	gFurnitureManager:CancelFurniturePreview()
	gFurnitureManager:SetEditPlacedFurnitureMode(false)
	LX6.Manager.GameInputManager.SetEnableInput(self.panelId, false, false, true)
	self:CameraEnterIndoor(true)

	local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager

	CSFurnitureManager.SetBuildMode(false)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:InitFurnitureDataTabList()
	self.furnitureDataTabList = {}

	if HouseFurnitureConfig and HouseFurnitureConfig.count then
		for i = 0, HouseFurnitureConfig.count - 1 do
			local furnitureCfg = HouseFurnitureConfig.LoadAt(i)

			if furnitureCfg and furnitureCfg.Id then
				local furnitureItemData = {
					mainType = furnitureCfg.MainType or 0,
					id = furnitureCfg.Id,
					name = furnitureCfg.Name or "",
					iconId = furnitureCfg.FurnitureIcon or 0,
					cfg = furnitureCfg
				}

				if not self.furnitureDataTabList[furnitureCfg.MainType] then
					self.furnitureDataTabList[furnitureCfg.MainType] = {}
				end

				table.insert(self.furnitureDataTabList[furnitureCfg.MainType], furnitureItemData)
			end
		end
	end

	self.mainTypeTabList = {
		{
			mainType = gFurnitureConst.FurnitureMainType.Furniture
		},
		{
			mainType = gFurnitureConst.FurnitureMainType.Appliance
		},
		{
			mainType = gFurnitureConst.FurnitureMainType.Decoration
		},
		{
			mainType = gFurnitureConst.FurnitureMainType.Hanging
		},
		{
			mainType = gFurnitureConst.FurnitureMainType.InteractiveItem
		}
	}
end

function M:RefreshFurnitureList()
	if not self.bindData or not self.bindData.furnitureList then
		return
	end

	local furnitureList = self.furnitureDataTabList[self.curMainType] or {}

	self.bindData.furnitureList:SetSimpleList(#furnitureList)
end

function M:OnLongPressFullScreenBtn(isPress)
	local hit = gFurnitureManager:OnLongPressFullScreenBtn(isPress)

	if hit == false and isPress then
		if gFurnitureManager.lastCanPlaceState then
			self:OnClickConfirmBtn()
		else
			self:OnClickCancelBtn()
		end
	end
end

function M:OnRenderMainTypeListItem(btn, index)
	local data = self.mainTypeTabList[index + 1]

	if not data then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	local mainTypeTitleList = HouseConfig.FurnitureMainType
	itemStore.title = mainTypeTitleList[data.mainType].Name or ""
end

function M:OnClickMainTypeList(btn, index)
	local data = self.mainTypeTabList[index + 1]

	if not data or not data.mainType then
		return
	end

	self.curMainType = data.mainType

	self:RefreshFurnitureList()
end

function M:OnGetMainTypeListTIndex(index)
	return 0
end

function M:OnRenderFurnitureListItem(btn, index)
	local data = self.furnitureDataTabList[self.curMainType] and self.furnitureDataTabList[self.curMainType][index + 1]

	if not data then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	itemStore.name = data.name or ""
	local num = gHouseManager:GetRealTimeAvailableCount(data.id)
	itemStore.numText = num
	itemStore.iconId = data.iconId or 0

	self:SetupFurnitureItemDrag(btn, data)
end

function M:SetupFurnitureItemDrag(btn, data)
	if not btn or not data then
		return
	end

	local dragListener = SGUI.EventSystems.DragEventListener.Get(btn.gameObject)

	if not dragListener then
		return
	end

	local buttonRect = btn:GetComponent("RectTransform")
	local isDraggedOutside = false
	local hasTriggeredClick = false
	local hasTriggeredLongPress = false

	function dragListener.onBeginDrag(eventData)
		isDraggedOutside = false
		hasTriggeredClick = false
		hasTriggeredLongPress = false
	end

	function dragListener.onDrag(eventData)
		if not buttonRect then
			return
		end

		local isInside = gCS.LuaUtils.RectangleContainsScreenPoint(buttonRect, eventData.position)

		if not isInside and not isDraggedOutside then
			isDraggedOutside = true

			if not hasTriggeredClick then
				hasTriggeredClick = true
				local availableCount = gHouseManager:GetRealTimeAvailableCount(data.id)

				if availableCount > 0 then
					gFurnitureManager:SpawnFurniture(data.id, false)
				else
					gDisplayMessageMgr:ShowMessageContentDebug("MessageConfig.HouseBuildFurnitureNotEnough")
				end
			end

			hasTriggeredLongPress = true
		end
	end

	function dragListener.onEndDrag(eventData)
		if hasTriggeredLongPress then
			self:OnLongPressFullScreenBtn(false)
		end

		isDraggedOutside = false
		hasTriggeredClick = false
		hasTriggeredLongPress = false
	end
end

function M:OnClickFurnitureList(btn, index)
	local data = self.furnitureDataTabList[self.curMainType] and self.furnitureDataTabList[self.curMainType][index + 1]

	if not data or not data.id then
		return
	end

	local availableCount = gHouseManager:GetRealTimeAvailableCount(data.id)

	if availableCount <= 0 then
		gDisplayMessageMgr:ShowMessageContentDebug("MessageConfig.HouseBuildFurnitureNotEnough")

		return
	end

	gFurnitureManager:SpawnFurniture(data.id, true)
end

function M:OnGetFurnitureListTIndex(index)
	return 0
end

function M:ChangeEditMode(isEdit)
	if isEdit == nil then
		isEdit = not self.inEdit
	end

	self.inEdit = isEdit
	self.bindData.pageCtrl = self.inEdit and 1 or 0

	self:UpdateUndoRedoButtonStates()
end

function M:MarkAsUnsaved()
	self.saved = false
end

function M:OnCanPlaceStateChanged(eventId, data)
	if not data or not self.bindData or not self.bindData.confirmBtn then
		return
	end

	local canPlace = data.canPlace or false

	self.bindData.confirmBtn.gameObject:SetActive(canPlace)
end

function M:OnClickBackBtn(btn, data)
	if self.saved then
		gPanelManager:Close(self.panelId)

		return
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildSaveReconfirm, function ()
		self:OnClickSaveBtn()
		gPanelManager:Close(self.panelId)
	end, function ()
		gHouseManager:ResetFurnitureToServerState()
		gPanelManager:Close(self.panelId)
	end)
end

function M:OnClickRotateBtn(btn, data)
	gFurnitureManager:RotateFollowingFurniture45()
end

function M:OnClickCancelBtn(btn, data)
	gFurnitureManager:CancelFurniturePreview()
	self:ChangeEditMode(false)
end

function M:DoStorage()
	local res = gFurnitureManager:StorageFurniture()

	if res == gFurnitureConst.StorageRes.Success then
		self:ChangeEditMode(false)
		self:MarkAsUnsaved()
	elseif res == gFurnitureConst.StorageRes.NoFollowingFurniture then
		-- Nothing
	elseif res == gFurnitureConst.StorageRes.NotInEdit then
		self:ChangeEditMode(false)
	end
end

function M:OnClickStorageBtn(btn, data)
	if gFurnitureManager:CheckStorageFurnitureHasAdsFurniture() then
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildStorageFurnitureReconfirm, function ()
			self:DoStorage()
		end, nil)
	else
		self:DoStorage()
	end
end

function M:UpdateUndoRedoButtonStates()
	local canUndo = gFurnitureOperationManager:CanUndo()
	local canRedo = gFurnitureOperationManager:CanRedo()
	self.bindData.undoBtn.interactable = canUndo
	self.bindData.redoBtn.interactable = canRedo
end

function M:OnClickConfirmBtn(btn, data)
	if gFurnitureManager:FinalizeFurniture() then
		self:MarkAsUnsaved()
	end

	self:ChangeEditMode(false)
end

function M:OnClickUndoBtn(btn, data)
	local success = gFurnitureOperationManager:Undo()

	if success then
		self:UpdateUndoRedoButtonStates()
		self:MarkAsUnsaved()
	end
end

function M:OnClickRedoBtn(btn, data)
	local success = gFurnitureOperationManager:Redo()

	if success then
		self:UpdateUndoRedoButtonStates()
		self:MarkAsUnsaved()
	end
end

function M:OnClickSaveBtn(btn, data)
	local hasChanges = gHouseManager:SyncAllChangesToServer()

	if hasChanges then
		gHouseManager:ClearPendingChanges()

		self.saved = true

		gDisplayMessageMgr:ShowMessageContentDebug("家具数据已保存到服务器")
	else
		self.saved = true

		gDisplayMessageMgr:ShowMessageContentDebug("没有需要保存的变化")
	end
end

function M:OnClickSettingBtn()
	gPanelManager:CheckShow(800)
end

function M:OnCameraJoyStickMove(x, y, size)
	self.cameraJoyStickX = x
	self.cameraJoyStickY = y
	self.cameraJoyStickSize = size

	if size ~= 0 then
		if not self.isCameraJoyStickActive then
			self.isCameraJoyStickActive = true

			self:OnCameraJoyStickTick()
		end
	else
		self.isCameraJoyStickActive = false
	end
end

function M:OnBeginPressUpBtn(btn, data)
	self.isUp = true

	self:OnUpBtnTick()
end

function M:OnEndPressUpBtn(btn, data)
	self.isUp = false
end

function M:OnUpBtnTick()
	if not self.isUp then
		return
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_POS_CHANGE, Vector3.New(0, 0, 1))
	Timer.New(self:CreateAction("OnUpBtnTick"), 0.1):Start()
end

function M:OnBeginPressDownBtn(btn, data)
	self.isDown = true

	self:OnDownBtnTick()
end

function M:OnEndPressDownBtn(btn, data)
	self.isDown = false
end

function M:OnDownBtnTick()
	if not self.isDown then
		return
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_POS_CHANGE, Vector3.New(0, 0, -1))
	Timer.New(self:CreateAction("OnDownBtnTick"), 0.1):Start()
end

function M:OnCameraJoyStickTick()
	if not self.isCameraJoyStickActive then
		return
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_POS_CHANGE, Vector3.New(self.cameraJoyStickX * self.cameraJoyStickSize, self.cameraJoyStickY * self.cameraJoyStickSize, 0))
	Timer.New(self:CreateAction("OnCameraJoyStickTick"), 0.1):Start()
end

function M:OnGestureZoom(zoom)
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_GESTURE, zoom)
end

function M:onBeginDrag(eventData)
	if eventData.button ~= 0 then
		return
	end

	self.lastPos = gUtils:GetTouchPosition()
end

function M:onDrag(eventData)
	if eventData.button ~= 0 then
		return
	end

	if not self.lastPos then
		return
	elseif not gFurnitureManager:IsRealFollowing() then
		local currentPos = gUtils:GetTouchPosition()
		local delta = currentPos - self.lastPos

		gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_DRAG, delta)

		self.lastPos = currentPos
	end
end

function M:onEndDrag(eventData)
	if eventData.button == 0 then
		self.lastPos = nil
	end
end

function M:CameraEnterIndoor(isEnter)
	gFurnitureManager.showCeiling = isEnter

	if isEnter then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "FurnitureCameraEnterIndoor"
		})
	else
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "FurnitureCameraExitIndoor"
		})
	end
end

function M:OnWASDMove(params)
	local isX = params[1]
	local size = params[2]
	local isPositive = params[3]

	if size == 0 then
		if isX then
			if isPositive and self.cameraJoyStickX > 0 then
				self.cameraJoyStickX = 0
			elseif not isPositive and self.cameraJoyStickX < 0 then
				self.cameraJoyStickX = 0
			end
		elseif isPositive and self.cameraJoyStickY > 0 then
			self.cameraJoyStickY = 0
		elseif not isPositive and self.cameraJoyStickY < 0 then
			self.cameraJoyStickY = 0
		end
	elseif isX then
		self.cameraJoyStickX = size
	else
		self.cameraJoyStickY = size
	end

	if self.cameraJoyStickX == 0 and self.cameraJoyStickY == 0 then
		self.cameraJoyStickSize = 0
	else
		self.cameraJoyStickSize = math.sqrt(self.cameraJoyStickX * self.cameraJoyStickX + self.cameraJoyStickY * self.cameraJoyStickY)
	end

	if self.cameraJoyStickSize ~= 0 then
		if not self.isCameraJoyStickActive then
			self.isCameraJoyStickActive = true

			self:OnCameraJoyStickTick()
		end
	else
		self.isCameraJoyStickActive = false
	end
end
