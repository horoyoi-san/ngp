-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCMKMainStore.lua
-- Decompiled from: 00949_OCMKMainStore.lua_236d1db64bd7.luajit

C_OCMKMainStore = DefClass("C_OCMKMainStore", C_OCMKMainStore, C_StoreGroup)
GroupName2Class.OCMKMainStore = C_OCMKMainStore
local M = C_OCMKMainStore
local TAB = {
	["\\xea\\xfe )7\n\\xd6"] = 4,
	["k\\x87\\x90\\x9c\\x82"] = 1,
	["Y\n\\o"] = 0,
	["1m\\xbc\\xa1\\xb1x"] = 3,
	["_To"] = 2
}

M.ctor = function(self)
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
	self.currentTabStore = nil
	self.currentTabIndex = -1
	self.validTabs = {
		[TAB.CHAT] = true,
		[TAB.EDIT] = true,
		[TAB.MEMORY] = true,
		[TAB.SETTING] = true,
		[TAB.FIRST] = true
	}
	self.q2EnabledTabs = {
		[TAB.CHAT] = true,
		[TAB.FIRST] = true
	}
	self.tabEnabledMap = self.validTabs
	self.tabStack = {}
	self.isNavigatingBack = false
	self.pendingProgrammaticTab = nil
	self.npcUnit = nil
	self.cameraActionStatusId = LTConfig.MeccaGrandpaRobotConfig.CameraActionStatusId or 41
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	if data and data.npcPid then
		self.npcUnit = gCS.SceneDataMgr.GetUnit(data.npcPid)

		self.SetCameraGaze(self, false)
	end

	self:LoadModel()
	self:ApplyTabEnabled()

	self.isFirst = true
	local intent = self.mgr.grandpaEntryIntent or "chat"

	if intent ~= "create" then
		self.pendingProgrammaticTab = TAB.EDIT
		self.bindData.tabRect.selectedIndex = TAB.EDIT
	elseif intent ~= "memory" and self.mgr:HasGrandpa() then
		self.pendingProgrammaticTab = TAB.MEMORY
		self.bindData.tabRect.selectedIndex = TAB.MEMORY
	else
		self.bindData.tabRect.selectedIndex = TAB.CHAT
	end

	self.mgr.grandpaEntryIntent = nil
end

M.OnClose = function(self)
	self.SetCameraGaze(self, true)

	self.npcUnit = nil
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
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnTabRectRender)
end

M.OnClickBackBtn = function(self)
	if self.currentTabStore and self.currentTabStore.OnExit and self.currentTabStore:OnExit() then
		return
	end

	if #self.tabStack < 1 then
		self.OnExit(self)

		return
	end

	table.remove(self.tabStack)

	local prevTab = self.tabStack[#self.tabStack]
	self.isNavigatingBack = true
	self.bindData.tabRect.selectedIndex = prevTab
	self.isNavigatingBack = false
end

M.OnExit = function(self)
	if self.currentTabStore and self.currentTabStore.OnClose then
		self.currentTabStore:OnClose()
	end

	self.currentTabStore = nil
	self.mgr.pendingGrandpaProfile = nil

	gPanelManager:Close(self.m_Id)
end

M.LoadModel = function(self)
end

M.ApplyTabEnabled = function(self)
	self.tabEnabledMap = self.mgr:GetCurrentStage() ~= 0 and self.q2EnabledTabs or self.validTabs
end

M.IsTabEnabled = function(self, index)
	return self.tabEnabledMap and self.tabEnabledMap[index] ~= true
end

M.OnTabRectRender = function(self, index, widget)
	if not self.validTabs[index] then
		print_warn("[OC] OnTabRectRender invalid tab index=", index)

		return
	end

	local isEnable = self:IsTabEnabled(index)
	local isProgrammatic = self.pendingProgrammaticTab ~= index

	if isProgrammatic then
		self.pendingProgrammaticTab = nil
	end

	if not isEnable and not isProgrammatic then
		print_warn("[OC] OnTabRectRender disabled tab index=", index, "currentTabIndex=", self.currentTabIndex)

		return
	end

	self.currentTabIndex = index

	if self.currentTabStore and self.currentTabStore.OnClose then
		self.currentTabStore:OnClose()
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)

	if not store then
		print_warn("[OC] OnTabRectRender store NOT found for index=", index, "storeName=", widget.Store)

		return
	end

	store.parentStore = self

	self.SetCameraGaze(self, false)
	store.OnShow(store, self.m_Id)

	self.currentTabStore = store

	if not self.isNavigatingBack then
		table.insert(self.tabStack, index)
	end
end

M.OnChat = function(self, isFirst)
	self.bindData.tabRect.selectedIndex = isFirst and TAB.FIRST or TAB.CHAT
end

M.OnDataRefresh = function(self)
	if self.currentTabStore and self.currentTabStore.OnDataRefresh then
		self.currentTabStore:OnDataRefresh()
	end
end

M.ConfirmCurrent = function(self)
	self.bindData.tabRect.selectedIndex = TAB.EDIT
end

M.EnterMemory = function(self)
	self.bindData.tabRect.selectedIndex = TAB.MEMORY
end

M.OnSetting = function(self)
	self.bindData.tabRect.selectedIndex = TAB.SETTING
end

M.GetCameraActionStatusId = function(self, index)
	if not index or index >= 0 then
		return self.cameraActionStatusId
	end

	local TabCameraConfig = LTConfig.MeccaGrandpaRobotTabCameraConfig
	local cfg = TabCameraConfig and TabCameraConfig.GetConfig(index + 1)

	if cfg and cfg.CameraActionStatusId and cfg.CameraActionStatusId <= 0 then
		return cfg.CameraActionStatusId
	end

	return self.cameraActionStatusId
end

M.SetCameraGaze = function(self, isExit)
	if isExit then
		gCS.CameraDataMgr.cinemachineManager:DisableCustomFreeLook(1)

		return
	end

	if not self.npcUnit or not self.npcUnit.ModelSlot then
		return
	end

	local pos = self.npcUnit.ModelSlot.cameraSlot.position
	local actionId = self:GetCameraActionStatusId(self.currentTabIndex)

	gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(pos, actionId, 1)
end

M.SetCameraGazeByActionId = function(self, actionId)
	if not actionId or actionId < 0 then
		return
	end

	if not self.npcUnit or not self.npcUnit.ModelSlot then
		return
	end

	local pos = self.npcUnit.ModelSlot.cameraSlot.position

	gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(pos, actionId, 1)
end
