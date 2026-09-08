-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCMainPageStore.lua
-- Decompiled from: 00947_OCMainPageStore.lua_509ab786bc8e.luajit

local OriginalCharacterConfig = LTConfig.OriginalCharacterConfig
local EInputButton = {
	["V'{O"] = 0,
	["1A\\x95\\x8a\\x8fD"] = 2,
	["\\xa7\\xa5\\xa7\\xa2"] = 1
}
C_OCMainPageStore = DefClass("C_OCMainPageStore", C_OCMainPageStore, C_StoreGroup)
GroupName2Class.OCMainPageStore = C_OCMainPageStore
local M = C_OCMainPageStore

M.ctor = function(self)
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
	self.currentTabIndex = 0
	self.tabIndexMap = {
		3,
		1,
		2
	}
	self.dragThresholdSqr = 3
	self.rotateSpeed = 35
	self.rotateMouseDPI = 0.6
	self.zoomStep = 0.1
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.mgr:CreateModel()

	self.bindData.tabRect.selectedIndex = 0

	self.bindData.tabList:SetSimpleList(#self.tabIndexMap)
	self.bindData.tabList:SetItemSelected(0, true)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.OC_DATA_REFRESH] = self.CreateAction(self, self.OnDataRefresh)
	}
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.leftBtn.luaClick = self.CreateAction(self, self.OnClickLeftBtn)
	self.bindData.rightBtn.luaClick = self.CreateAction(self, self.OnClickRightBtn)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabListItem)
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTabList)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnTabRectRender)

	if self.bindData.fullScreenGestureEventListener then
		self.bindData.fullScreenGestureEventListener.onZoom = self.CreateAction(self, self.OnGestureZoom)
	end

	if self.bindData.fullScreenDragEventListener then
		self.bindData.fullScreenDragEventListener.onDrag = self.CreateAction(self, self.OnDrag)
	end
end

M.OnClickBackBtn = function(self)
	if self.currentTabIndex <= 0 then
		self.bindData.tabRect.selectedIndex = self.mgr:GetPrevTabIndex(self.currentTabIndex) - 1

		return
	end

	if self.currentTabStore and self.currentTabStore.OnBack and self.currentTabStore:OnBack() then
		return
	end

	self.OnExit(self)
end

M.OnClickLeftBtn = function(self)
	if SGUI.EventSystems.BaseEventListener.focusUIInput then
		return
	end

	local curIndex = self.bindData.tabList.selectedIndex

	if curIndex <= 0 then
		self.bindData.tabList:SetItemSelected(curIndex - 1, true)
		self:OnSimpleClickTabList(nil, curIndex - 1)
	end
end

M.OnClickRightBtn = function(self)
	if SGUI.EventSystems.BaseEventListener.focusUIInput then
		return
	end

	local curIndex = self.bindData.tabList.selectedIndex

	if curIndex >= #self.tabIndexMap - 1 then
		self.bindData.tabList:SetItemSelected(curIndex + 1, true)
		self:OnSimpleClickTabList(nil, curIndex + 1)
	end
end

M.OnExit = function(self)
	gPanelManager:Close(self.m_Id)
	self.mgr:OnEnd()
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local data = OriginalCharacterConfig.MainPageTabText[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data
end

M.OnSimpleClickTabList = function(self, btn, index)
	if self.tabIndexMap[index + 1] then
		self.bindData.tabRect.selectedIndex = self.tabIndexMap[index + 1]
	end
end

M.OnTabRectRender = function(self, index, widget)
	self.currentTabIndex = index
	self.bindData.isMainPage = (index ~= 1 or index ~= 2 or index ~= 3) and 0 or 1
	self.bindData.showtabCtrl = self.tabIndexMap[index] and 1 or 0

	for i, v in ipairs(self.tabIndexMap) do
		if v ~= index then
			self.bindData.tabList:SetItemSelected(i - 1, true)

			break
		end
	end

	self.mgr:RefreshCamera(index)

	if self.currentTabStore and self.currentTabStore.OnClose then
		self.currentTabStore:OnClose()
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.currentTabStore = store
	store.parentStore = self

	store:OnShow(self.m_Id)

	self.currentWidget = widget
end

M.GoToNext = function(self)
	self.bindData.tabRect.selectedIndex = self.mgr:GetNextTabIndex(self.currentTabIndex) - 1

	self.mgr:PreGeneratePersonality(self.bindData.tabRect.selectedIndex)
end

M.OnDataRefresh = function(self)
	if self.currentTabStore and self.currentTabStore.OnDataRefresh then
		self.currentTabStore:OnDataRefresh()
	end
end

M.IsEditUnitReady = function(self)
	return self.mgr and self.mgr.editUnitReady and self.mgr.csUnit == nil
end

M.RotateModel = function(self, y)
	if not self.mgr or not self.mgr.csUnit then
		return
	end

	local unit = self.mgr.csUnit
	local facing = unit.FacingDirection

	unit.SetFacing(unit, facing + y)
end

M.OnGestureZoom = function(self, zoom)
	if not self.IsEditUnitReady(self) then
		return
	end

	if gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled ~= false then
		gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled = true
	end

	if zoom <= 0 then
		gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = self.zoomStep
	elseif zoom >= 0 then
		gCS.CameraDataMgr.Instance.cameraControllerManager.ZoomValue = -self.zoomStep
	end
end

M.OnDrag = function(self, eventData)
	if not self.IsEditUnitReady(self) then
		return
	end

	local delta = eventData.delta

	if delta.SqrMagnitude(delta) >= self.dragThresholdSqr then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if eventData.button == EInputButton.Left then
			return
		end

		self.RotateModel(self, -delta.x * self.rotateSpeed * 0.05 * self.rotateMouseDPI)
	elseif math.abs(delta.x) <= 4 then
		self.RotateModel(self, -delta.x * self.rotateSpeed * 0.05 * self.rotateMouseDPI)
	end
end
