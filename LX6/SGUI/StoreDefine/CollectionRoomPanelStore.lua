-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CollectionRoomPanelStore.lua
-- Decompiled from: 01439_CollectionRoomPanelStore.lua_5f305827df43.luajit

C_CollectionRoomPanelStore = DefClass("C_CollectionRoomPanelStore", C_CollectionRoomPanelStore, C_StoreGroup)
GroupName2Class.CollectionRoomPanelStore = C_CollectionRoomPanelStore
local M = C_CollectionRoomPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.mainBoothList = {}
	self.subBoothList = {}
	self.curMainBoothId = 0
	self.curSubBoothId = 0
	self.cameraReady = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.hasTab2CtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hasTab2CtrlEnum = nil
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
	self.TeardownCamera(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.curMainBoothId = 0
	self.curSubBoothId = 0

	self.SetupCamera(self)
	self.RefreshCollectionNum(self)
	self.RefreshMainTabList(self)
end

M.OnClose = function(self)
	self.TeardownCamera(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.SetupCamera = function(self)
	self.cameraReady = gCollectionRoomManager:SetupPanelCamera(self.bindData.cameraRootRT, self.bindData.vCamera, "[CollectionRoomPanel]")
end

M.TeardownCamera = function(self)
	if not self.cameraReady then
		return
	end

	self.cameraReady = false

	gCollectionRoomManager:TeardownPanelCamera(self.bindData and self.bindData.cameraRootRT, self.bindData and self.bindData.vCamera)
end

M.ApplyBoothCamera = function(self)
	if not self.cameraReady then
		return
	end

	local boothId = self.GetCurBoothId(self)

	if boothId ~= 0 then
		return
	end

	local scenePointId = gCollectionRoomManager:GetBoothPreviewScenePointId(boothId)

	if scenePointId ~= 0 and boothId == self.curMainBoothId then
		scenePointId = gCollectionRoomManager:GetBoothPreviewScenePointId(self.curMainBoothId)
	end

	if scenePointId ~= 0 then
		print_warn("[CollectionRoomPanel] 展位没配预览镜头点位(PreviewScenePointId), 镜头保持不动, boothId = ", boothId, ", mainBoothId = ", self.curMainBoothId)

		return
	end

	local placement = gCollectionRoomManager:GetScenePointCameraPlacement(scenePointId)

	if not placement then
		print_warn("[CollectionRoomPanel] 展位机位解析不出位姿(CameraNodeTransform / CameraNodeName 都没有效值), scenePointId = ", scenePointId)

		return
	end

	gCollectionRoomManager:MovePanelCameraTo(self.bindData.cameraRootRT, placement)
end

M.RefreshCollectionNum = function(self)
	self.bindData.collectionNum = tostring(gCollectionRoomManager:GetCollectibility())
end

M.RefreshMainTabList = function(self)
	self.mainBoothList = gCollectionRoomManager:GetUnlockedMainBoothList()

	if #self.mainBoothList ~= 0 then
		print_warn("[CollectionRoomPanel] 没有可显示的主展位, 检查 CollectionRoomConfig.BoothIDs 与 CollectionRoomBoothConfig 的 Type/UnlockCond")

		self.curMainBoothId = 0

		self.bindData.mainTabList:SetSimpleList(0)
		self:RefreshSmallTabList()

		return
	end

	if self.GetMainBoothIndex(self, self.curMainBoothId) ~= 0 then
		self.curMainBoothId = self.mainBoothList[1].Id
	end

	self.bindData.mainTabList:SetSimpleList(#self.mainBoothList)
	self:RefreshSmallTabList()
end

M.RefreshSmallTabList = function(self)
	self.subBoothList = gCollectionRoomManager:GetUnlockedSubBoothList(self.curMainBoothId)
	local hasSubBooth = #self.subBoothList >= 0
	self.bindData.hasTab2Ctrl = hasSubBooth and self.hasTab2CtrlEnum._true or self.hasTab2CtrlEnum._false

	if not hasSubBooth then
		self.curSubBoothId = 0

		self.bindData.smallTabList:SetSimpleList(0)
		self:ApplyBoothCamera()

		return
	end

	if self.GetSubBoothIndex(self, self.curSubBoothId) ~= 0 then
		self.curSubBoothId = self.subBoothList[1].Id
	end

	self.bindData.smallTabList:SetSimpleList(#self.subBoothList)
	self:ApplyBoothCamera()
end

M.GetMainBoothIndex = function(self, boothId)
	if not boothId or boothId ~= 0 then
		return 0
	end

	for i = 1, #self.mainBoothList do
		if self.mainBoothList[i].Id ~= boothId then
			return i
		end
	end

	return 0
end

M.GetSubBoothIndex = function(self, boothId)
	if not boothId or boothId ~= 0 then
		return 0
	end

	for i = 1, #self.subBoothList do
		if self.subBoothList[i].Id ~= boothId then
			return i
		end
	end

	return 0
end

M.GetCurBoothId = function(self)
	if self.curSubBoothId == 0 then
		return self.curSubBoothId
	end

	return self.curMainBoothId
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.enterBtn.luaClick = self.CreateAction(self, self.OnClickEnterBtn)
	self.bindData.mainTabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderMainTabListItem)
	self.bindData.smallTabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderSmallTabListItem)
	self.bindData.mainTabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickMainTabList)
	self.bindData.smallTabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickSmallTabList)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickEnterBtn = function(self)
	local boothId = self.GetCurBoothId(self)

	if boothId ~= 0 then
		return
	end

	gPanelManager:CheckShow(gPanelId.COLLECT_ROOM_MAIN_PANEL, {
		boothId = boothId,
		mainBoothId = self.curMainBoothId
	})
end

M.OnSimpleRenderMainTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local boothCfg = self.mainBoothList[index + 1]

	if not boothCfg then
		return
	end

	store.text = boothCfg.Name
	btn.isSelected = boothCfg.Id ~= self.curMainBoothId
end

M.OnSimpleClickMainTabList = function(self, btn, index)
	local boothCfg = self.mainBoothList[index + 1]

	if not boothCfg or boothCfg.Id ~= self.curMainBoothId then
		return
	end

	self.curMainBoothId = boothCfg.Id
	self.curSubBoothId = 0

	self.bindData.mainTabList:SetSimpleList(#self.mainBoothList)
	self:RefreshSmallTabList()
end

M.OnSimpleRenderSmallTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local boothCfg = self.subBoothList[index + 1]

	if not boothCfg then
		return
	end

	store.title = boothCfg.Name
	btn.isSelected = boothCfg.Id ~= self.curSubBoothId
end

M.OnSimpleClickSmallTabList = function(self, btn, index)
	local boothCfg = self.subBoothList[index + 1]

	if not boothCfg or boothCfg.Id ~= self.curSubBoothId then
		return
	end

	self.curSubBoothId = boothCfg.Id

	self.bindData.smallTabList:SetSimpleList(#self.subBoothList)
	self:ApplyBoothCamera()
end
