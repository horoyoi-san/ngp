local bit = require("bit")
EMapViewerItemCoordType = {
	Unreachable = 3,
	AttachGate = 2,
	Normal = 1
}
EMapViewShowMask = {}
EMapViewHideMask = {
	LowPriorityGateItem = 256
}
MapView = MapView or {}
local M = MapView
M.__index = M

function M.GetDefaultConfig()
	local params = gGpsTools.GetTable()
	params.viewMask = EMapViewMask.None
	params.openAllGateBetweenBigMaps = false
	params.delayAddAndRemove = true
	params.needBoundSource = true
	params.useMiniMapSpiritFilter = false
	params.useBigMapSpiritFilter = false
	params.skipImportantTaskSpiritFilter = false
	params.ignoreInterestInGateStage = false

	return params
end

function M.CreateView(id, cfg)
	local view = setmetatable({}, M)
	view.id = id
	view.cfg = cfg or M.GetDefaultConfig()

	view:Init()
	gMapSystem.container:RegisterViewer(id, view)

	return view
end

function M:Init()
	self.items = {}
	self._newItem = {}
	self.sourceLayers = {}
	self.limitAreaInfos = {
		raidId = 0,
		type = 0,
		areaIds = {}
	}
	self._viewMap = {
		currentIds = {},
		toAdd = {},
		toRemove = {}
	}
	self.playerBounds = {}
	self.traceSpace = {
		bounds = {},
		connectCache = {}
	}
	self.areaSpace = {
		bounds = {},
		connectCache = {}
	}

	self:InitCull()

	self.activeSources = {}

	self:InitStages()
	self:InitDefaultStages()
	self:AddNecessaryStages()
end

function M:ConnectTraceSource()
	self:ConnectSource(gMapSystem.trace.traceSource)
	self:ConnectSource(gMapSystem.trace.weakGuideSource)
end

function M:Dispose()
	for _, source in pairs(self.activeSources) do
		self:DisconnectSource(source)
	end

	if self._onRemoveCb then
		for instanceId, _ in pairs(self._viewMap.currentIds) do
			self._onRemoveCb(instanceId)
		end
	end

	self:ClearListener()
	gMapSystem.container:UnregisterViewer(self.id, self)
end

function M:SetViewMask(viewMask)
	self.cfg.viewMask = viewMask

	self:ReloadAllItem()
end

function M:ReloadAllItem()
	self:ReloadAllSourceItems()
end

function M:ReloadAllSourceItems()
	for sourceId, source in pairs(self.activeSources) do
		local items = gGpsTools.GetTable()

		source:GetAllElements(self.cfg.viewMask, items)
		self:SetLayerData(sourceId, items)
		gGpsTools.ReleaseTable(items)
	end
end

function M:AddBySource(instanceId, sourceId)
	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:AddFromBound: Element not found for instanceId", instanceId)

		return
	end

	if not element:CheckViewMask(self.cfg.viewMask) then
		return
	end

	local layerData = self.sourceLayers[sourceId]

	if not layerData then
		layerData = gGpsTools.GetTable()
		self.sourceLayers[sourceId] = layerData
	end

	if layerData[instanceId] then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:AddFromBound: Element already exists in source layer", gGpsTools.GetGpsDebugDesc(instanceId), sourceId)

		return
	end

	layerData[instanceId] = true
	local source = self.activeSources[sourceId]
	local item = self.items[instanceId]

	if not item then
		item = gGpsTools.GetTable()
		item.instanceId = instanceId
		item.visible = false
		item.step = 0
		item.sourceMap = gGpsTools.GetTable()
		item.sourceMap[sourceId] = true
		item.mapElement = element
		item.coordType = EMapViewerItemCoordType.Unreachable
		item.showMask = 0
		item.hideMask = 0
		item.stageIdx = 0
		item.interestSourceCount = source.interest and 1 or 0
		self.items[instanceId] = item
		self._newItem[instanceId] = item

		self:AfterRealAddBySource(item)
	else
		item.sourceMap[sourceId] = true

		if source.interest then
			item.interestSourceCount = item.interestSourceCount + 1

			if item.interestSourceCount == 1 then
				self:RestageItem(instanceId)
			end
		end
	end

	self:RefreshItemCullable(instanceId)
end

function M:RemoveBySource(instanceId, sourceId)
	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:RemoveFromBound: Element not found for instanceId", instanceId)
	end

	local item = self.items[instanceId]

	if not item then
		return
	end

	local layerData = self.sourceLayers[sourceId]

	if not layerData then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:RemoveFromBound: Layer data not found for source", instanceId, sourceId)

		return
	end

	layerData[instanceId] = nil

	if not next(layerData) then
		self.sourceLayers[sourceId] = nil

		gGpsTools.ReleaseTable(layerData)
	end

	if not item.sourceMap[sourceId] then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:RemoveFromBound: Source not found in item", instanceId, sourceId)

		return
	end

	local source = self.activeSources[sourceId]
	item.sourceMap[sourceId] = nil

	if not next(item.sourceMap) then
		self:BeforeRealRemoveBySource(item)
		self.firstStage:DropItem(instanceId)

		self.items[item.instanceId] = nil

		gGpsTools.ReleaseTable(item.sourceMap)
		gGpsTools.ReleaseTable(item)
	elseif source.interest then
		item.interestSourceCount = item.interestSourceCount - 1

		if item.interestSourceCount == 0 then
			self:RestageItem(instanceId)
		end
	else
		self:RefreshItemCullable(instanceId)
	end
end

function M:SetLayerData(layerName, ids)
	local layerData = self.sourceLayers[layerName]

	if not layerData then
		layerData = gGpsTools.GetTable()
		self.sourceLayers[layerName] = layerData
	end

	for instanceId, _ in pairs(layerData) do
		if not ids[instanceId] then
			self:RemoveBySource(instanceId, layerName)
		end
	end

	for instanceId, _ in pairs(ids) do
		if not layerData[instanceId] then
			self:AddBySource(instanceId, layerName)
		end
	end
end

function M:AfterRealAddBySource(item)
	item.mapElement:IncViewCount()

	if item.mapElement.fData.representGBoundId then
		item.representGBoundId = item.mapElement.fData.representGBoundId
	end
end

function M:BeforeRealRemoveBySource(item)
	item.mapElement:DecViewCount()
end

function M:QueryEntryInfo(targetGBoundId, useTraceSpace, preferredGateInfo)
	local space = useTraceSpace and self.traceSpace or self.areaSpace
	local activeGBoundIds = space.bounds
	local founded = false
	local minDist = math.huge
	local minStepCount = math.huge
	local startGBoundId, nextGBoundId, exitPos = nil

	for gBoundId, _ in pairs(activeGBoundIds) do
		if preferredGateInfo then
			local suc, x, y, z, exitGBoundId, stepCount, exitDist = LX6.Gps.GpsAreaConnectMgr.LuaTryGetBoundExitInfoV2(gBoundId, targetGBoundId, preferredGateInfo.gBoundId, preferredGateInfo.localGateId, nil, nil, nil, nil, nil, nil)

			if suc and (not founded or stepCount < minStepCount or stepCount == minStepCount and exitDist < minDist) then
				founded = true
				minDist = exitDist
				minStepCount = stepCount
				startGBoundId = gBoundId
				nextGBoundId = exitGBoundId
				exitPos = Vector3.New(x, y, z)
			end
		else
			local suc, x, y, z, exitGBoundId, stepCount, exitDist = LX6.Gps.GpsAreaConnectMgr.LuaTryGetBoundExitInfoTo(gBoundId, targetGBoundId, nil, nil, nil, nil, nil, nil)

			if suc and (not founded or stepCount < minStepCount or stepCount == minStepCount and exitDist < minDist) then
				founded = true
				minDist = exitDist
				minStepCount = stepCount
				startGBoundId = gBoundId
				nextGBoundId = exitGBoundId
				exitPos = Vector3.New(x, y, z)
			end
		end
	end

	return founded, minStepCount, startGBoundId, nextGBoundId, exitPos
end

function M:SetItemAsNormalCoord(item)
	item.coordType = EMapViewerItemCoordType.Normal
	item.step = 0

	if item.attachedGBoundId then
		item.attachedGBoundId = nil

		self:RecheckItemStage(item.instanceId, EMapViewStage.Gate)
	end

	item.resolvedWorldPos = item.mapElement:GetWorldPos()
	item.resolvedGBoundId = item.mapElement.gBoundId

	self:RecheckItemStage(item.instanceId, EMapViewStage.Reachable)
end

function M:SetItemAsUnreachable(item)
	item.coordType = EMapViewerItemCoordType.Unreachable
	item.step = 0

	if item.attachedGBoundId then
		item.attachedGBoundId = nil

		self:RecheckItemStage(item.instanceId, EMapViewStage.Gate)
	end

	item.resolvedWorldPos = Vector3.zero
	item.resolvedGBoundId = 0

	self:RecheckItemStage(item.instanceId, EMapViewStage.Reachable)
end

function M:SetItemAsGateCoord(item, startGBoundId, nextGBoundId, step, pos)
	item.coordType = EMapViewerItemCoordType.AttachGate
	item.step = step

	if item.attachedGBoundId ~= nextGBoundId then
		item.attachedGBoundId = nextGBoundId

		self:RecheckItemStage(item.instanceId, EMapViewStage.Gate)
	end

	item.resolvedWorldPos = pos
	item.resolvedGBoundId = startGBoundId

	self:RecheckItemStage(item.instanceId, EMapViewStage.Reachable)
end

function M:TickNewItemCoord()
	for instanceId, item in pairs(self.items) do
		if self._newItem[instanceId] then
			self._newItem[instanceId] = nil

			self:TryUpdateItemCoord(instanceId)
			self.firstStage:PushItem(instanceId)
		elseif item.interestSourceCount > 0 then
			self:TryUpdateItemCoord(instanceId)
		end
	end
end

function M:TryUpdateItemCoord(instanceId)
	local item = self.items[instanceId]

	if not item then
		return
	end

	local element = gMapSystem.container:Get(instanceId)

	if not element then
		return
	end

	if element:HasRelocatedPosition() then
		self:SetItemAsNormalCoord(item)
	elseif not element.gpsData.ignoreIndoorPenetration and (item.sourceMap.trace or item.sourceMap.weakGuide) then
		if self.traceSpace.bounds[element.gBoundId] then
			self:SetItemAsNormalCoord(item)
		else
			local suc, step, startGBoundId, nextGBoundId, pos = self:QueryEntryInfo(element.gBoundId, true, element.gpsData.preferredGateInfo)

			if suc then
				self:SetItemAsGateCoord(item, startGBoundId, nextGBoundId, step, pos)
			else
				self:SetItemAsUnreachable(item)
			end
		end
	elseif self.areaSpace.bounds[element.gBoundId] then
		self:SetItemAsNormalCoord(item)
	else
		local suc, step, startGBoundId, nextGBoundId, pos = self:QueryEntryInfo(element.gBoundId, false, element.gpsData.preferredGateInfo)

		if suc then
			self:SetItemAsGateCoord(item, startGBoundId, nextGBoundId, step, pos)
		else
			self:SetItemAsUnreachable(item)
		end
	end

	if self._onUpdateCb and self._viewMap.currentIds[instanceId] then
		self._onUpdateCb(instanceId)
	end
end

function M:TickViewNotify()
	for instanceId, _ in pairs(self._viewMap.toRemove) do
		self._viewMap.currentIds[instanceId] = nil
		self._viewMap.toRemove[instanceId] = nil

		if self._onRemoveCb then
			self._onRemoveCb(instanceId)
		end
	end

	for instanceId, _ in pairs(self._viewMap.toAdd) do
		local item = self.items[instanceId]
		self._viewMap.toAdd[instanceId] = nil
		self._viewMap.currentIds[instanceId] = true

		if item then
			if self._onAddCb then
				self._onAddCb(instanceId)
			end
		else
			gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:TickViewNotify: Item not found for instanceId", instanceId)
		end
	end
end

function M:ConnectSource(source)
	self.activeSources[source.gId] = source

	source:AddListener(self)
end

function M:DisconnectSource(source)
	source:RemoveListener(self)

	self.activeSources[source.gId] = nil
end

function M:RegisterListener(onAdd, onRemove, onUpdate)
	self._onAddCb = onAdd
	self._onRemoveCb = onRemove
	self._onUpdateCb = onUpdate
end

function M:ClearListener()
	self._onAddCb = nil
	self._onRemoveCb = nil
	self._onUpdateCb = nil
end

function M:GetItemInfo(instanceId)
	return self.items[instanceId]
end

require("LX6/Manager/Map/MapView_Bounds")
require("LX6/Manager/Map/MapView_Cull")
require("LX6/Manager/Map/MapView_Fog")
require("LX6/Manager/Map/MapView_Stage")
require("LX6/Manager/Map/MapView_Filter")
require("LX6/Manager/Map/MapView_Gate")
require("LX6/Manager/Map/MapView_Conflict")
require("LX6/Manager/Map/MapViewStageHandler")
