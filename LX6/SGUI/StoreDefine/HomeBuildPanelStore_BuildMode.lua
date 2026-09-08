-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HomeBuildPanelStore_BuildMode.lua
-- Decompiled from: 01715_HomeBuildPanelStore_BuildMode.lua_13a4d6741b23.luajit

local M = C_HomeBuildPanelStore
local WallEditMode = gWallEditUtils.WallEditMode
local HomeBuildUIUtils = gHomeBuildUIUtils
local BuildMode = gHomeBuildUIUtils.BuildMode

M.EnterWallPaintBuildMode = function(self)
	if not gHouseManager:CanUseWallEditMode(WallEditMode.WALL_BRUSH) then
		return
	end

	self.EnterWallDomainWithMode(self, WallEditMode.WALL_BRUSH)
	self.ResetBuildToolSelection(self, false)
	self.SetWallEditCompVisible(self, false)
end

M.EnterSurfacePaintBuildMode = function(self, isCeiling)
	if not gHouseManager:CanUseWallEditMode(WallEditMode.SURFACE_BRUSH) then
		return
	end

	self:EnterWallDomainWithMode(WallEditMode.SURFACE_BRUSH)
	self:ResetBuildToolSelection(false)

	self.pendingSurfaceType = isCeiling and "ceiling" or "floor"

	self:SetWallEditCompVisible(false)
end

M.HandleBuildModeFurniture = function(self)
	gFurnitureManager:SetEditPlacedFurnitureMode(true)

	if self.editDomain ~= "furniture" then
		self.ResetBuildToolSelection(self, true)

		return
	end

	self.pendingEnterWallByUnifiedClick = false
	self.enteredWallByUnifiedClick = false
	self.editDomain = "furniture"

	gWallEditManager:ExitEditMode()
	gWallEditManager:ClearWallPreviewMesh()
	self:EndWallEditSession()

	self.wallEditCompHiddenByDrag = false
	self.bindData.showDetailEditCtrl = 1

	self:ResetBuildToolSelection(true)
	gMessageManager:SendMessage(gEventConstants.HOME_WALL_EDIT_EXIT)
end

M.HandleBuildModeWall = function(self)
	if not gHouseManager:CanUseWallEditMode(WallEditMode.BUILD) then
		return
	end

	local enteredByUnifiedClick = self.pendingEnterWallByUnifiedClick ~= true
	self.pendingEnterWallByUnifiedClick = false

	if self.editDomain == "wall" then
		self.enteredWallByUnifiedClick = enteredByUnifiedClick
		self.editDomain = "wall"

		gFurnitureManager:SetEditPlacedFurnitureMode(false)
		gFurnitureManager:CancelFurniturePreview()
		self:ChangeEditMode(false)
		self:EndWallEditSession()

		self.wallEditCompHiddenByDrag = false

		self:SetWallEditCompVisible(false)
		gWallEditManager:EnterEditMode()
		gMessageManager:SendMessage(gEventConstants.HOME_WALL_EDIT_ENTER)
	end

	gWallEditManager:SetMode(WallEditMode.BUILD)
	self:ResetBuildToolSelection(true)
	gWallEditManager:UpdateHoverPreview(self:GetBuildInputScreenPos())
end

M.HandleBuildModeDoor = function(self)
	self.EnterFenestrationBuildMode(self, 0)
end

M.HandleBuildModeWindow = function(self)
	self.EnterFenestrationBuildMode(self, 2)
end

M.HandleBuildModeWallMaterial = function(self)
	self.EnterWallPaintBuildMode(self)
end

M.HandleBuildModeGroundMaterial = function(self)
	self.EnterSurfacePaintBuildMode(self, false)
end

M.HandleBuildModeCeilingMaterial = function(self)
	self.EnterSurfacePaintBuildMode(self, true)
end

M.EnterWallDomainWithMode = function(self, wallMode)
	if self.editDomain == "wall" then
		self.editDomain = "wall"

		gFurnitureManager:SetEditPlacedFurnitureMode(false)
		gFurnitureManager:CancelFurniturePreview()
		self:ChangeEditMode(false)
		self:EndWallEditSession()

		self.wallEditCompHiddenByDrag = false

		self:SetWallEditCompVisible(false)
		gWallEditManager:EnterEditMode()
		gMessageManager:SendMessage(gEventConstants.HOME_WALL_EDIT_ENTER)
	end

	gWallEditManager:SetMode(wallMode)
end

M.EnterFenestrationBuildMode = function(self, fenestrationType)
	if not gHouseManager:CanUseWallEditMode(WallEditMode.FENESTRATION) then
		return
	end

	self:EnterWallDomainWithMode(WallEditMode.FENESTRATION)
	self:ResetBuildToolSelection(false)

	self.pendingFenestrationType = fenestrationType

	gWallEditManager:SetFenestrationParams(self.pendingFenestrationPrefabID, self.pendingFenestrationType)
	self:SetWallEditCompVisible(false)
end

M.ResetBuildToolSelection = function(self, restoreRightButtons)
	self.pendingWallTexID = 0
	self.pendingSurfaceTexID = 0
	self.pendingFenestrationPrefabID = 0
	self.pendingFenestrationType = 0
	self.pendingSurfaceType = nil

	self.ClearMaterialCursor(self)
	self.StopFenestrationPreviewSession(self, true)
	self.ClearSelectedFenestration(self)

	self.pendingFenestrationMoveStartCmd = nil
	self.pendingFenestrationMoveFinalCmd = nil

	if restoreRightButtons and self.rightButtonsHiddenByTool then
		self.rightButtonsHiddenByTool = false
	end

	if restoreRightButtons then
		self.RefreshRightButtonsByEditState(self)
	end
end

M.RefreshThirdTabCtrlBySelection = function(self)
	local selectedMode = HomeBuildUIUtils:ResolveBuildMode(self.curMainType, self.curSubType, self.baseSubTypeToMode)
	local isMaterial = selectedMode ~= BuildMode.WallMaterial or selectedMode ~= BuildMode.GroundMaterial or selectedMode ~= BuildMode.CeilingMaterial
	self.bindData.showThirdTabCtrl = isMaterial and 0 or 1

	if isMaterial then
		self.RefreshThirdTabList(self)
	end
end

M.MarkTempFenestrationContext = function(self, prevMode)
	self.tempFenestrationFromFurniture = true
	self.tempFenestrationPrevMode = prevMode or BuildMode.Furniture
end

M.ClearTempFenestrationContext = function(self)
	self.tempFenestrationFromFurniture = false
	self.tempFenestrationPrevMode = nil
end

M.TryRestoreBuildModeAfterTempFenestration = function(self)
	if not self.tempFenestrationFromFurniture then
		return false
	end

	local targetMode = self.tempFenestrationPrevMode or BuildMode.Furniture

	self:ClearTempFenestrationContext()
	self:SwitchBuildMode(targetMode)

	return true
end

M.SwitchBuildMode = function(self, mode)
	local targetMode = mode or BuildMode.Furniture

	if not HomeBuildUIUtils:CanUseBuildMode(targetMode) then
		targetMode = BuildMode.Furniture
	end

	if self.currentBuildMode ~= targetMode then
		return
	end

	local handler = self.buildModeHandlers[targetMode] or self.buildModeHandlers[BuildMode.Furniture]

	handler(targetMode)

	self.currentBuildMode = targetMode

	self:RefreshThirdTabCtrlBySelection()
	self:RefreshEditExitCtrl(targetMode)
	self:RefreshPageCtrlByContext()
	HomeBuildUIUtils:ShowBuildModeDebugMessage(targetMode)
	self:RefreshEditCompCtrlByDomain()
	self:UpdateUndoRedoButtonStates()
end

M.UpdateBuildModeBySelection = function(self, mainType, subType)
	local mode = HomeBuildUIUtils:ResolveBuildMode(mainType, subType, self.baseSubTypeToMode)

	self:SwitchBuildMode(mode)
end

M.SyncCurrentBuildModeState = function(self)
	local mode = self.currentBuildMode or BuildMode.Furniture
	local handler = self.buildModeHandlers[mode] or self.buildModeHandlers[BuildMode.Furniture]

	handler(mode)

	self.currentBuildMode = mode

	self:RefreshThirdTabCtrlBySelection()
	self:RefreshEditExitCtrl(mode)
	self:RefreshPageCtrlByContext()
	HomeBuildUIUtils:ShowBuildModeDebugMessage(mode)
	self:RefreshEditCompCtrlByDomain()
	self:UpdateUndoRedoButtonStates()
end
