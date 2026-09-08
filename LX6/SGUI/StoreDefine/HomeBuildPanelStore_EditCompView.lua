-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HomeBuildPanelStore_EditCompView.lua
-- Decompiled from: 01714_HomeBuildPanelStore_EditCompView.lua_c1a3f9a5838a.luajit

local M = C_HomeBuildPanelStore
local HouseConfig = LTConfig.HouseConfig
local HomeBuildUIUtils = gHomeBuildUIUtils
local BuildMode = gHomeBuildUIUtils.BuildMode

M.RefreshPageCtrlByContext = function(self)
	if self.isReplaceMode then
		return
	end

	local hideTabList = self.inEdit or HomeBuildUIUtils:IsFenestrationBuildMode(self.currentBuildMode)
	self.bindData.pageCtrl = hideTabList and 1 or 0
end

M.RefreshEditCompCtrlByDomain = function(self)
	if not self.editCompStore then
		return
	end

	local isWall = self.editDomain ~= "wall"
	local isFenestrationMode = self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window
	local isFenestrationPreview = self.fenestrationPreviewActive ~= true
	self.editCompStore.storageCtrl = isWall and not isFenestrationPreview and 1 or 0
	self.editCompStore.copyCtrl = isWall and 1 or 0
	self.editCompStore.replaceCtrl = isWall and not isFenestrationPreview and 1 or 0
	self.editCompStore.rotateCtrl = isWall and 1 or 0
	self.editCompStore.demolishCtrl = isWall and not isFenestrationMode and 0 or 1
	self.editCompStore.heightChangeCtrl = isWall and not isFenestrationMode and 0 or 1
end

M.SetRightButtonsVisible = function(self, isVisible)
	self.bindData.showRightBtnCtrl = isVisible and 0 or 1
end

M.RefreshRightButtonsByEditState = function(self)
	local isEditing = self.bindData.showDetailEditCtrl ~= 0 or self.wallEditCompHiddenByDrag or self.furnitureEditCompHiddenByRotate

	self:SetRightButtonsVisible(not isEditing)
end

M.RefreshEditExitCtrl = function(self, mode)
	self.bindData.showEditExitCtrl = HomeBuildUIUtils:IsEditExitBuildMode(mode) and 0 or 1
end

M.UpdateEditCompPositionForWall = function(self)
	if self.fenestrationPreviewActive then
		local previewGo = gWallEditManager.fenestrationPreviewGo

		if previewGo and not gCS.LuaUtils.IsNull(previewGo) then
			local targetWorldPos = previewGo.transform.position + Vector3.New(0, 1.2, 0)

			HomeBuildUIUtils:TrySetEditCompPositionByWorldPos(self.bindData, targetWorldPos)

			return
		end
	end

	if self.selectedFenestrationGo and not gCS.LuaUtils.IsNull(self.selectedFenestrationGo) then
		local targetWorldPos = self.selectedFenestrationGo.transform.position + Vector3.New(0, 1.2, 0)

		HomeBuildUIUtils:TrySetEditCompPositionByWorldPos(self.bindData, targetWorldPos)

		return
	end

	if self.selectedFenestrationRuntimeID and self.selectedFenestrationWorldPos then
		local targetWorldPos = self.selectedFenestrationWorldPos + Vector3.New(0, 1.2, 0)

		HomeBuildUIUtils:TrySetEditCompPositionByWorldPos(self.bindData, targetWorldPos)

		return
	end

	local wallData = gWallEditManager.selectedWallData

	if not wallData or not wallData.startPos or not wallData.endPos then
		return
	end

	local center = (wallData.startPos + wallData.endPos) * 0.5
	local gridSystem = gWallEditManager.gridSystemProxy
	local wallHeight = gridSystem and gridSystem._floorHeight or 4
	local targetWorldPos = center + Vector3.New(0, wallHeight * 0.5 + 0.4, 0)

	HomeBuildUIUtils:TrySetEditCompPositionByWorldPos(self.bindData, targetWorldPos)
end

M.SetWallEditCompVisible = function(self, isVisible)
	if self.editDomain == "wall" then
		return
	end

	local hasFenestrationPreview = self.fenestrationPreviewActive ~= true
	local hasSelectedFenestration = self.selectedFenestrationGo and not gCS.LuaUtils.IsNull(self.selectedFenestrationGo) or self.selectedFenestrationRuntimeID == nil and self.selectedFenestrationWorldPos == nil
	local hasSelectedWall = gWallEditManager.selectedWallData == nil

	if not isVisible or not hasFenestrationPreview and not hasSelectedFenestration and not hasSelectedWall then
		self.bindData.showDetailEditCtrl = 1

		self.RefreshRightButtonsByEditState(self)

		return
	end

	self.bindData.showDetailEditCtrl = 0

	self.RefreshRightButtonsByEditState(self)
	self.UpdateEditCompPositionForWall(self)
end

M.UpdateFurnitureEditButtonsState = function(self)
	if not self.editCompStore then
		return
	end

	local canPlace, isSpawnOperation, canCopy = HomeBuildUIUtils:GetOperationState()

	if self.editCompStore.confirmBtn then
		self.editCompStore.confirmBtn.interactable = canPlace
	end

	if self.editCompStore.copyBtn then
		local hideByLimit = self:IsCurrentFurnitureSubTypeAtLimit()

		self.editCompStore.copyBtn.gameObject:SetActive(not hideByLimit)

		self.editCompStore.copyBtn.interactable = canPlace and canCopy
	end

	if self.editCompStore.replaceBtn then
		self.editCompStore.replaceBtn.interactable = canPlace
	end
end

M.UpdateFenestrationEditButtonsState = function(self)
	if not self.editCompStore then
		return
	end

	local canConfirm, canCopy, canReplace = HomeBuildUIUtils:GetFenestrationOperationState(self.fenestrationPreviewActive, self.fenestrationPreviewCanPlace, self.selectedFenestrationRuntimeID, self.pendingFenestrationPrefabID)

	if self.editCompStore.confirmBtn then
		self.editCompStore.confirmBtn.interactable = canConfirm
	end

	if self.editCompStore.copyBtn then
		self.editCompStore.copyBtn.interactable = canCopy
	end

	if self.editCompStore.replaceBtn then
		self.editCompStore.replaceBtn.interactable = canReplace
	end
end

M.UpdateEditButtonsState = function(self)
	if self.editDomain ~= "wall" and HomeBuildUIUtils:IsFenestrationBuildMode(self.currentBuildMode) then
		self.UpdateFenestrationEditButtonsState(self)

		return
	end

	self.UpdateFurnitureEditButtonsState(self)
end

M.OnCanPlaceStateChanged = function(self, eventId, data)
	if self.editDomain == "furniture" then
		return
	end

	if not data or not self.editCompStore then
		return
	end

	local canPlace = data.canPlace or false
	gFurnitureManager.lastCanPlaceState = canPlace

	self:UpdateFurnitureEditButtonsState()
end

M.UpdateEditCompPositionFromWorldPos = function(self, worldPos)
	if not self.inEdit or not self.bindData or not self.bindData.editComp then
		return
	end

	local furnitureGo = gFurnitureManager.followingFurniture

	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	local furnitureComponent = gFurnitureManager.followingFurnitureComponent

	if not furnitureComponent or not furnitureComponent.meshObject or gCS.LuaUtils.IsNull(furnitureComponent.meshObject) then
		return
	end

	local meshRenderers = furnitureComponent.meshObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)

	if not meshRenderers or meshRenderers.Length < 0 then
		return
	end

	local meshBounds = meshRenderers[0].bounds

	for i = 1, meshRenderers.Length - 1 do
		local rendererBounds = meshRenderers[i].bounds

		meshBounds.Encapsulate(meshBounds, rendererBounds.min)
		meshBounds.Encapsulate(meshBounds, rendererBounds.max)
	end

	local topWorldPos = Vector3.New(meshBounds.center.x, meshBounds.max.y, meshBounds.center.z)
	local mainCamera = gCS.CameraDataMgr.MainCamera

	if not mainCamera then
		return
	end

	local isPC = gCS.LuaUtils.IsNonMobileAdaptive()
	local toolbarOffset = 0

	if isPC then
		toolbarOffset = HouseConfig.PCToolbarOffset or 0.1
	else
		toolbarOffset = HouseConfig.PhoneToolbarOffset or 0
	end

	local cameraUpDirection = mainCamera.transform.up
	local offsetWorldDirection = cameraUpDirection * toolbarOffset
	local finalWorldPos = topWorldPos + offsetWorldDirection * 3
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(finalWorldPos, mainCamera, 0, 0, 0)

	if z >= 0 then
		return
	end

	local rectTransform = self.bindData.editComp.rectTransform

	if not rectTransform then
		return
	end

	local parent = rectTransform.parent

	if not parent then
		return
	end

	local uiPosition = gCS.LuaUtils.TransformScreenPointToUI(parent, Vector3.New(x, y, 0))

	rectTransform.SetLocalPositionXY(rectTransform, uiPosition.x, uiPosition.y)
end

M.OnFurniturePositionChanged = function(self, eventId, data)
	if not data or not self.inEdit or not self.bindData or not self.bindData.editComp then
		return
	end

	if data.valid ~= false then
		if not self.furnitureEditCompHiddenByNoSurface then
			self.furnitureEditCompHiddenByNoSurface = true
			self.bindData.showDetailEditCtrl = 1

			self.RefreshRightButtonsByEditState(self)
		end

		return
	end

	if not data.position then
		return
	end

	if self.furnitureEditCompHiddenByNoSurface then
		self.furnitureEditCompHiddenByNoSurface = false
		self.bindData.showDetailEditCtrl = 0

		self.RefreshRightButtonsByEditState(self)
	end

	self.UpdateEditCompPositionFromWorldPos(self, data.position)
end
