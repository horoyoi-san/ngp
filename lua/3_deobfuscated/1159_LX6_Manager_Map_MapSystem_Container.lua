local M = {}

function M:Init()
	self.views = {}
	self._dirtyInstanceIds = {}
	self._boundsDirtySwap = {}
	self._allElements = {}
	self._gpsId2Element = {}
	self._toCommitElements = {}
	self._toRecycleElements = {}
	self.unmanagedElems = {}
end

function M:RegisterViewer(id, view)
	self.views[id] = view
end

function M:UnregisterViewer(id, view)
	if self.views[id] == view then
		self.views[id] = nil
	end
end

function M:MarkElementAsDirty(instanceId)
	self._dirtyInstanceIds[instanceId] = true
end

function M:AddElement(element)
	self._allElements[element.instanceId] = element
	self._gpsId2Element[element.gpsId] = element

	gCS.GpsContainer.SetRaidId(element.instanceId, element.raidId)
end

function M:Get(instanceId)
	return self._allElements[instanceId]
end

function M:GetByGpsId(gpsId)
	return self._gpsId2Element[gpsId]
end

function M:GetInstanceIdByGpsId(gpsId)
	local element = self._gpsId2Element[gpsId]

	if element then
		return element.instanceId
	else
		return nil
	end
end

function M:RemoveElement(element)
	local instanceId = element.instanceId
	self._toRecycleElements[instanceId] = element
	self._allElements[instanceId] = nil
	self._gpsId2Element[element.gpsId] = nil

	gCS.GpsContainer.RemoveGpsData(instanceId)
end

function M:ClearCoordDirty()
	local _boundDirtyData = self._boundsDirtySwap

	array.clear(_boundDirtyData)
	gCS.GpsContainer.SyncCoordDirty()

	if #_boundDirtyData > 0 then
		for i = 3, #_boundDirtyData, 3 do
			local instanceId = _boundDirtyData[i - 2]
			local indoorId = _boundDirtyData[i - 1]
			local boundId = _boundDirtyData[i]
			local element = self:Get(instanceId)

			if element then
				element:SetBoundInfo(indoorId, boundId)
			end
		end
	end
end

local _swapArray = {}

function M:TickView()
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("Calc Player Bounds")
	end

	local _nextActiveBounds = gGpsTools.GetTable()
	local gBoundId = gMapSystem.lastGBoundId
	local bound = gMapSystem.area:GetBound(gBoundId)

	if bound then
		table.clear(_swapArray)
		LX6.Gps.AreaMgr.graph:LuaGetCombinedGBoundIdList(gBoundId, _swapArray)

		if #_swapArray == 0 then
			_nextActiveBounds[gBoundId] = bound
		else
			for _, id in ipairs(_swapArray) do
				local groupedBound = gMapSystem.area:GetBound(id)

				if groupedBound then
					_nextActiveBounds[id] = groupedBound
				end
			end
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end

	for _, view in pairs(self.views) do
		gMapSystem:CallWithProfiler("View: TickPlayerBounds", view.TickPlayerBounds, view, _nextActiveBounds)
		gMapSystem:CallWithProfiler("View: TickNewItemCoord", view.TickNewItemCoord, view)

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.BeginSample("View: TickUpdateItemCoord")
		end

		for instanceId, _ in pairs(self._dirtyInstanceIds) do
			view:TryUpdateItemCoord(instanceId)
		end

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.EndSample()
		end

		gMapSystem:CallWithProfiler("View: TickCull", view.TickCull, view)
	end

	table.clear(self._dirtyInstanceIds)
	gGpsTools.ReleaseTable(_nextActiveBounds)
end

function M:TickViewNotify()
	for _, view in pairs(self.views) do
		view:TickViewNotify()
	end
end

function M:TickRecycle()
	for instanceId, element in pairs(self._toRecycleElements) do
		if element then
			self._toRecycleElements[instanceId] = nil

			element:_Recycle()
		end
	end
end

function M:RestageItem(instanceId)
	for _, view in pairs(self.views) do
		view:RestageItem(instanceId)
	end
end

function M:RefreshViewStage(stage)
	for _, view in pairs(self.views) do
		view:RefreshStage(stage)
	end
end

function M:OnLinkModeChange()
	for _, view in pairs(self.views) do
		view:RefreshStage(EMapViewStage.LinkMode)
	end
end

function M:OnSpiritChange(spiritId)
	for _, view in pairs(self.views) do
		view:SetFilterSpiritId(spiritId)
	end
end

function M:OnUrbanBadgeInfoChange()
	for _, view in pairs(self.views) do
		view:RefreshStage(EMapViewStage.SpiritAndBadge)
	end
end

return M
