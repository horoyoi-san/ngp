C_NewMapPanelLeftPanelStore = DefClass("C_NewMapPanelLeftPanelStore", C_NewMapPanelLeftPanelStore, C_StoreGroup)
GroupName2Class.NewMapPanelLeftPanelStore = C_NewMapPanelLeftPanelStore
local M = C_NewMapPanelLeftPanelStore

function M:ctor()
	self.ModeType = {
		MapArea = 0,
		Taxi = 1
	}
end

function M:OnAwake()
	self.mainStore = gStoreManager:GetStoreGroup("NewMapPanelStore")
	self.bindData.onClose = self:CreateAction("ClosePanel")
	self.eventHandlers = {
		[gEventConstants.MAP_GLOBAL_GPS_UPDATE] = self:CreateAction("OnTraceElementUpdate")
	}
end

function M:OnEnable()
	self:InitMapListData()

	self.bindData.navArea.enabled = false
	self.bindData.navArea.enabled = true
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navArea
	self.bindData.mapAreaList.luaRenderItem = self:CreateAction("OnRenderMapAreaItem")
	self.bindData.mapAreaList.luaClick = self:CreateAction("OnClickMapAreaItem")
	self.bindData.mapAreaList.luaSelectedChanged = self:CreateAction("OnSelectMapAreaItem")

	self.bindData.mapAreaList:SetList(self.mapAreaList)

	if self.curSelectedIdx then
		self.bindData.mapAreaList:SelectItem(self.curSelectedIdx - 1)
	end

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:OnStart()
	return
end

function M:OnDisable()
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	self.bindData.mapAreaList.luaRenderItem = nil
	self.bindData.mapAreaList.luaClick = nil
	self.bindData.mapAreaList.luaSelectedChanged = nil
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.mainStore.bindData.attachCtxNavArea
	self.bindData.navArea.enabled = false
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:OnTraceElementUpdate()
	self.bindData.mapAreaList:SetList(self.mapAreaList)
end

function M:OnRenderMapAreaItem(btn, csIndex, data)
	local store = gStoreManager:GetStoreGroup("NewMapPanelLeftPanelStore_MapAreaItem"):GetStoreByWidget(btn)
	local tracingIds = gGpsTools.GetTable()

	gMapSystem.trace:GetAllTraceElements(self.mainStore:GetViewMask(), tracingIds)

	if csIndex + 1 == self.curSelectedIdx then
		btn:Navigate(btn)
	end

	local iconIdSet = {}
	local iconIds = {}

	for _, element in pairs(tracingIds) do
		if data.areaId == element:GetAreaId() or data.areaId == 23300888 and element.subSystemType == EMapSubSystemType.Boss then
			local iconId = element.mData.sIconId

			if not iconIdSet[iconId] then
				iconIdSet[iconId] = true

				table.insert(iconIds, iconId)
			end
		end
	end

	if #iconIds == 0 then
		store.icon1:SetActive(false)
		store.icon2:SetActive(false)
	elseif #iconIds == 1 then
		store.icon1:SetActive(true)

		store.iconId1 = iconIds[1]

		store.icon2:SetActive(false)
	else
		store.icon1:SetActive(true)

		store.iconId1 = iconIds[1]

		store.icon2:SetActive(true)

		store.iconId2 = iconIds[2]
	end

	store.text = data.name
	store.indoorState = data.indoorId > 0 and 1 or 0
end

function M:OnClickMapAreaItem(btn, data)
	local mainMapSG = gStoreManager:GetStoreGroup("NewMapPanelStore")

	if mainMapSG then
		mainMapSG:ActiveArea(gMapAreaMgr:GetAreaId(data.raidId, data.indoorId))
	end
end

function M:OnSelectMapAreaItem()
	return
end

function M:InitMapListData()
	local mapAreaList = {}

	for index = 0, LTConfig.RaidAreaListConfig.count - 1 do
		local cfg = LTConfig.RaidAreaListConfig.LoadAt(index)

		if cfg and (gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.ShowAllMapArea) or cfg.IsAlwaysShow or gMapManager.IndoorId == cfg.IndoorId) then
			local view = {
				name = cfg.Name,
				raidId = cfg.RaidId == 0 and LTConfig.RaidConfig.WorldMap or cfg.RaidId,
				indoorId = cfg.IndoorId or 0,
				positionTo = cfg.PositionTo
			}
			view.areaId = gMapAreaMgr:GetAreaId(view.raidId, view.indoorId)

			table.insert(mapAreaList, view)

			if view.raidId == self.mainStore.raidId and view.indoorId == self.mainStore.indoorId then
				self.curSelectedIdx = #mapAreaList
			end
		end
	end

	self.mapAreaList = mapAreaList
end

function M:RefreshData()
	return
end

function M:ClosePanel()
	self.mainStore:HideLeftHoverPanel()
end
