-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HomeBuildPanelStore_Handler.lua
-- Decompiled from: 01712_HomeBuildPanelStore_Handler.lua_3a80e48da5ba.luajit

local M = C_HomeBuildPanelStore
local HouseConfig = LTConfig.HouseConfig
local MessageConfig = LTConfig.MessageConfig
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local GameInputManager = LX6.Manager.GameInputManager

M.OnClickExitEditBtn = function(self, btn, data)
	self.bindData.furnitureList:DeselectAll(false)
	self:OnClickCancelBtn(btn, data)
end

M.EnsureRightBtnStores = function(self)
	if not self.undoBtnStore then
		self.undoBtnStore = gStoreManager:GetStoreGroup(self.bindData.undoBtn.Store):GetStoreByWidget(self.bindData.undoBtn)
	end

	if not self.redoBtnStore then
		self.redoBtnStore = gStoreManager:GetStoreGroup(self.bindData.redoBtn.Store):GetStoreByWidget(self.bindData.redoBtn)
	end

	if not self.saveBtnStore then
		self.saveBtnStore = gStoreManager:GetStoreGroup(self.bindData.saveBtn.Store):GetStoreByWidget(self.bindData.saveBtn)
	end
end

M.RefreshSaveButtonState = function(self)
	self:EnsureRightBtnStores()

	self.saveBtnStore.activeCtrl = self.saved and 1 or 0
end

M.UpdateUndoRedoButtonStates = function(self)
	self:EnsureRightBtnStores()

	local canUndo = gBuildOperationManager:CanUndo()
	local canRedo = gBuildOperationManager:CanRedo()
	self.undoBtnStore.activeCtrl = canUndo and 0 or 1
	self.redoBtnStore.activeCtrl = canRedo and 0 or 1
end

M.OnClickUndoBtn = function(self, btn, data)
	self.EnsureRightBtnStores(self)

	if self.undoBtnStore.activeCtrl == 0 then
		return
	end

	local success = gBuildOperationManager:Undo()

	if success then
		self.UpdateUndoRedoButtonStates(self)
		self.MarkAsUnsaved(self)
	end
end

M.OnClickRedoBtn = function(self, btn, data)
	self.EnsureRightBtnStores(self)

	if self.redoBtnStore.activeCtrl == 0 then
		return
	end

	local success = gBuildOperationManager:Redo()

	if success then
		self.UpdateUndoRedoButtonStates(self)
		self.MarkAsUnsaved(self)
	end
end

M.OnClickWallBtn = function(self)
	local nextCtrl = ((self.bindData.wallDisplayModeCtrl or 0) + 1) % 3
	self.bindData.wallDisplayModeCtrl = nextCtrl
	local gridSystem = gWallEditManager and gWallEditManager.gridSystemProxy

	gWallEditUtils:ApplyWallDisplayMode(gridSystem, nextCtrl)

	if nextCtrl ~= 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildShowAllWall)
	elseif nextCtrl ~= 1 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildHidePartWall)
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildHideAllWall)
	end
end

M.OnClickHeightChangeBtn = function(self, btn, data)
	gDisplayMessageMgr:ShowMessageContentDebug("墙体高度调整调试按钮")
end

M.OnClickSettingBtn = function(self)
	gPanelManager:CheckShow(800)
end

M.OnClickFoldBtn = function(self)
	self.bindData.foldCtrl = self.bindData.foldCtrl ~= 0 and 1 or 0
end

M.CalculateTimeCtrl = function(self)
	local gameTime = gCS.AtmosphereManager.Instance:GetGameTime()
	local hour, minute = gTimeUtils:GetHourMinSecond(gameTime)
	local currentHourFloat = hour + minute / 60
	local timePointList = HouseConfig.HouseTimePointList
	local t0 = timePointList[1]
	local t1 = timePointList[2]
	local t2 = timePointList[3]
	local t3 = timePointList[4]

	if t3 > currentHourFloat or currentHourFloat >= t0 then
		return 0
	elseif t0 < currentHourFloat and currentHourFloat >= t1 then
		return 1
	elseif t1 < currentHourFloat and currentHourFloat >= t2 then
		return 2
	elseif t2 < currentHourFloat and currentHourFloat >= t3 then
		return 3
	end

	return 0
end

M.UpdateTimeCtrl = function(self)
	self.bindData.timeCtrl = self.CalculateTimeCtrl(self)
end

M.OnClickTimeBtn = function(self)
	if gTimeAppUtils.CheckIsTaskForbiddenChangeTime() then
		gDisplayMessageMgr:ShowMessage(MessageConfig.NotUseXiuxi)

		return
	end

	local timePointList = HouseConfig.HouseTimePointList
	local nextTimeCtrl = self:CalculateTimeCtrl() % 4
	local nextHour = timePointList[nextTimeCtrl + 1]
	slot4 = gClientToGameDelegate

	slot4:AskPassingTime(nextHour, 0).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnTimeChanged = function(self)
	self.UpdateTimeCtrl(self)
end

local VIEW_MODE_CYCLE = {
	[0] = 2,
	0,
	1
}
local VIEW_MODE_MESSAGES = {
	[0] = function ()
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildCameraTopViewMode)
	end,
	function ()
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildCameraFreeMode)
	end,
	function ()
		gDisplayMessageMgr:ShowMessageContentDebug("45°俯视角")
	end
}

M.OnClickViewBtn = function(self)
	local currentMode = self.bindData.houseCamera.viewMode
	local newMode = VIEW_MODE_CYCLE[currentMode] or 0
	self.bindData.houseCamera.viewMode = newMode
	self.bindData.viewModeCtrl = newMode
	local showMsg = VIEW_MODE_MESSAGES[newMode]

	if showMsg then
		showMsg()
	end
end

M.OnClickHelpLineBtn = function(self)
	local enabled = not gFurnitureManager:GetGridModeEnabled()

	gFurnitureManager:SetGridModeEnabled(enabled)

	self.bindData.helpLineModeCtrl = enabled and 0 or 1

	if enabled then
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildShowGrid)
	else
		gDisplayMessageMgr:ShowMessageContentDebug("网格辅助已关闭（debug)")
	end
end

M.HandleMaterialCursor = function(self)
	local cursorRT = self.bindData.cursorRT

	if not cursorRT or gCS.LuaUtils.IsNull(cursorRT) then
		return
	end

	local mousePos = UnityEngine.Input.mousePosition
	local inFoldParentRect = false
	local foldParent = self.bindData.foldBtn.transform.parent
	inFoldParentRect = gCS.LuaUtils.RectangleContainsScreenPoint(foldParent, mousePos)
	local showMaterialCursor = self.materialUICursorActive and not inFoldParentRect

	if cursorRT.gameObject.activeSelf == showMaterialCursor then
		cursorRT.gameObject:SetActive(showMaterialCursor)
	end

	if showMaterialCursor then
		if not self.materialHardwareCursorHidden then
			GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.GameplayAlt, false, UnityEngine.CursorLockMode.None)

			self.materialHardwareCursorHidden = true
		end
	else
		if self.materialHardwareCursorHidden then
			GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.GameplayAlt)

			self.materialHardwareCursorHidden = false
		end

		return
	end

	local parent = cursorRT.parent

	if not parent then
		return
	end

	local uiPos = gCS.LuaUtils.TransformScreenPointToUI(parent, mousePos)

	cursorRT.transform:SetLocalPosition(uiPos)
end

M.SetMaterialCursor = function(self, iconId)
	local cursorRT = self.bindData.cursorRT

	if not cursorRT or gCS.LuaUtils.IsNull(cursorRT) then
		return
	end

	self.materialUICursorActive = true
	self.bindData.cursorIconId = iconId

	self.HandleMaterialCursor(self)
end

M.ClearMaterialCursor = function(self)
	self.materialUICursorActive = false
	local cursorRT = self.bindData.cursorRT

	if cursorRT and not gCS.LuaUtils.IsNull(cursorRT) then
		cursorRT.gameObject:SetActive(false)
	end

	if self.bindData.cursorIconId == nil then
		self.bindData.cursorIconId = 0
	end

	if self.materialHardwareCursorHidden then
		GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.GameplayAlt)

		self.materialHardwareCursorHidden = false
	end
end

M.TryPaintWallMaterialAt = function(self, screenPos)
	if self.pendingWallTexID < 0 then
		return false
	end

	local hitGo, hitType, hitPoint = gWallEditManager:RaycastWallEditTarget(screenPos)

	if hitType == "edge" or not hitGo or not hitPoint then
		return false
	end

	local normalizedHitPoint = hitPoint
	local gridSystem = gWallEditManager and gWallEditManager.gridSystemProxy

	if gridSystem and not gCS.LuaUtils.IsNull(gridSystem) and gridSystem.transform then
		local baseY = gridSystem.transform.position.y
		normalizedHitPoint = Vector3.New(hitPoint.x, baseY, hitPoint.z)
	end

	local success = false
	local edgeA, edgeB = gWallEditUtils:ParseEdgeFromObjectName(hitGo)
	local tagIndex = gWallEditUtils:GetWallTagIndexFromObject(hitGo)

	if self.wallPaintScope ~= self.WallPaintScope.Single then
		if not edgeA or not edgeB then
			return false
		end

		success = gWallEditManager:PaintWallByWall(edgeA, edgeB, normalizedHitPoint, self.pendingWallTexID)
	elseif self.wallPaintScope ~= self.WallPaintScope.FullWall then
		if not edgeA or not edgeB then
			return false
		end

		success = gWallEditManager:PaintWallByFullWall(edgeA, edgeB, normalizedHitPoint, self.pendingWallTexID, tagIndex)
	else
		success = gWallEditManager:PaintWallByRoomWithResult(normalizedHitPoint, self.pendingWallTexID, edgeA, edgeB, tagIndex)
	end

	if not success then
		return false
	end

	self.OnBuildToolApplySuccess(self)

	return true
end

M.RaycastSurfaceAtScreenPos = function(self, screenPos, surfaceType)
	local camera = gCS.CameraDataMgr.MainCamera

	if not camera then
		return nil, 
	end

	local ray = camera.ScreenPointToRay(camera, screenPos)
	local hitCount = CSFurnitureManager.RayCastNonAlloc(ray.origin, ray.direction, 100, nil, -1, true, 1)

	if hitCount < 0 then
		return nil, 
	end

	for i = 0, hitCount - 1 do
		local hitInfo = CSFurnitureManager.SortedRayCastList[i]

		if hitInfo and hitInfo.collider then
			local _, _, hitGo = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if hitGo and hitGo.name then
				local isFloor = string.sub(hitGo.name, 1, 6) ~= "Floor_"
				local isCeiling = string.sub(hitGo.name, 1, 8) ~= "Ceiling_"

				if surfaceType ~= "floor" and isFloor then
					return hitGo, hitInfo.point
				end

				if surfaceType ~= "ceiling" and isCeiling then
					return hitGo, hitInfo.point
				end

				if surfaceType == "floor" and surfaceType == "ceiling" and (isFloor or isCeiling) then
					return hitGo, hitInfo.point
				end
			end
		end
	end

	return nil, 
end

M.TryPaintSurfaceMaterialAt = function(self, screenPos)
	if self.pendingSurfaceTexID < 0 then
		return false
	end

	local hitGo, hitPoint = self.RaycastSurfaceAtScreenPos(self, screenPos, self.pendingSurfaceType)

	if not hitGo or not hitPoint then
		return false
	end

	if self.pendingSurfaceType ~= "floor" and string.sub(hitGo.name, 1, 6) == "Floor_" then
		return false
	end

	if self.pendingSurfaceType ~= "ceiling" and string.sub(hitGo.name, 1, 8) == "Ceiling_" then
		return false
	end

	local success = false
	success = (self.surfacePaintScope == self.SurfacePaintScope.Single or gWallEditManager:PaintSurfaceByObject(hitGo, hitPoint, self.pendingSurfaceTexID)) and gWallEditManager:PaintSurfaceRoomByHit(hitPoint, self.pendingSurfaceTexID, nil, self.pendingSurfaceType ~= "ceiling")

	if not success then
		return false
	end

	self.OnBuildToolApplySuccess(self)

	return true
end

M.OnCameraJoyStickMove = function(self, x, y, size)
	self.cameraJoyStickX = x
	self.cameraJoyStickY = y
	self.cameraJoyStickSize = size

	if size == 0 then
		if not self.isCameraJoyStickActive then
			self.isCameraJoyStickActive = true

			self.OnCameraJoyStickTick(self)
		end
	else
		self.isCameraJoyStickActive = false
	end
end

M.OnBeginPressUpBtn = function(self, btn, data)
	self.isUp = true

	self.OnUpBtnTick(self)
end

M.OnEndPressUpBtn = function(self, btn, data)
	self.isUp = false
end

M.OnUpBtnTick = function(self)
	if not self.isUp then
		return
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_POS_CHANGE, Vector3.New(0, 0, 1))
	Timer.New(self:CreateAction("OnUpBtnTick"), 0.1):Start()
end

M.OnBeginPressDownBtn = function(self, btn, data)
	self.isDown = true

	self.OnDownBtnTick(self)
end

M.OnEndPressDownBtn = function(self, btn, data)
	self.isDown = false
end

M.OnDownBtnTick = function(self)
	if not self.isDown then
		return
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_POS_CHANGE, Vector3.New(0, 0, -1))
	Timer.New(self:CreateAction("OnDownBtnTick"), 0.1):Start()
end

M.OnCameraJoyStickTick = function(self)
	if not self.isCameraJoyStickActive then
		return
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_POS_CHANGE, Vector3.New(self.cameraJoyStickX * self.cameraJoyStickSize, self.cameraJoyStickY * self.cameraJoyStickSize, 0))
	Timer.New(self:CreateAction("OnCameraJoyStickTick"), 0.1):Start()
end

M.OnGestureZoom = function(self, zoom)
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_GESTURE, zoom)
end

M.HandlePCCameraRightDrag = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.pcCameraRightDragLastPos = nil

		return
	end

	if self.editDomain ~= "furniture" and gFurnitureManager:IsRealFollowing() then
		self.pcCameraRightDragLastPos = nil

		return
	end

	if self.editDomain ~= "wall" and self.wallDragActive then
		self.pcCameraRightDragLastPos = nil

		return
	end

	if not UnityEngine.Input.GetMouseButton(1) then
		self.pcCameraRightDragLastPos = nil

		return
	end

	local inputPos = SGUI.Utils.GetInputCenterPosition()
	local currentPos = Vector3.New(inputPos.x, inputPos.y, 0)

	if not self.pcCameraRightDragLastPos then
		self.pcCameraRightDragLastPos = currentPos

		return
	end

	local delta = currentPos - self.pcCameraRightDragLastPos

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_DRAG, UnityEngine.Vector2.New(delta.x, delta.y))

	self.pcCameraRightDragLastPos = currentPos
end

M.HandleCameraDragByLastPos = function(self, currentPos, blockWhenFollowing)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.lastPos = currentPos

		return
	end

	if not self.lastPos then
		self.lastPos = currentPos

		return
	end

	if blockWhenFollowing and gFurnitureManager:IsRealFollowing() then
		return
	end

	local delta = currentPos - self.lastPos

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAMERA_DRAG, UnityEngine.Vector2.New(delta.x, delta.y))

	self.lastPos = currentPos
end
