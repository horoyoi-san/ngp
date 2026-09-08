-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_Container.lua
-- Decompiled from: 02296_MapSystem_Container.lua_3536d3d7afe0.luajit

local M = {}

M.Init = function(self)
	self.views = {}
	self._dirtyInstanceIds = {}
	self._boundsDirtySwap = {}
	self._allElements = {}
	self._gpsId2Element = {}
	self._toCommitElements = {}
	self._toRecycleElements = {}
	self.unmanagedElems = {}
end

M.RegisterViewer = function(self, id, view)
	self.views[id] = view
end

M.UnregisterViewer = function(self, id, view)
	if self.views[id] ~= view then
		self.views[id] = nil
	end
end

M.MarkElementAsDirty = function(self, instanceId)
	self._dirtyInstanceIds[instanceId] = true
end

M.AddElement = function(self, element)
	self._allElements[element.instanceId] = element
	self._gpsId2Element[element.gpsId] = element

	gCS.GpsContainer.SetRaidId(element.instanceId, element.raidId)
end

M.Get = function(self, instanceId)
	return self._allElements[instanceId]
end

M.GetByGpsId = function(self, gpsId)
	return self._gpsId2Element[gpsId]
end

M.GetInstanceIdByGpsId = function(self, gpsId)
	local element = self._gpsId2Element[gpsId]

	if element then
		return element.instanceId
	else
		return nil
	end
end

M.RemoveElement = function(self, element)
	local instanceId = element.instanceId
	self._toRecycleElements[instanceId] = element
	self._allElements[instanceId] = nil
	self._gpsId2Element[element.gpsId] = nil

	gCS.GpsContainer.RemoveGpsData(instanceId)
end

M.ClearCoordDirty = function(self)
	local _boundDirtyData = self._boundsDirtySwap

	array.clear(_boundDirtyData)
	gCS.GpsContainer.SyncCoordDirty()

	if #_boundDirtyData <= 0 then
		for i = 3, #_boundDirtyData, 3 do
			local instanceId = _boundDirtyData[i - 2]
			local indoorId = _boundDirtyData[i - 1]
			local boundId = _boundDirtyData[i]
			local element = self.Get(self, instanceId)

			if element then
				element.SetBoundInfo(element, indoorId, boundId)
			end
		end
	end
end

local _swapArray = {}

M.TickView = function(self)
	if not self.views then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("Calc Player Bounds")
	end

	self.playerConnectedBounds = self.playerConnectedBounds or {}

	table.clear(self.playerConnectedBounds)

	local gBoundId = gMapSystem.lastGBoundId
	local bound = gMapSystem.area:GetBound(gBoundId)

	if bound then
		table.clear(_swapArray)
		LX6.Gps.AreaMgr.graph:LuaGetCombinedGBoundIdList(gBoundId, _swapArray)

		if #_swapArray ~= 0 then
			self.playerConnectedBounds[gBoundId] = bound
		else
			for _, id in ipairs(_swapArray) do
				local groupedBound = gMapSystem.area:GetBound(id)

				if groupedBound then
					self.playerConnectedBounds[id] = groupedBound
				end
			end
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end

	for _, view in pairs(self.views) do
		view.Update(view, self.playerConnectedBounds, self._dirtyInstanceIds)
	end

	table.clear(self._dirtyInstanceIds)
end

M.TickViewNotify = function(self)
	if not self.views then
		return
	end

	for _, view in pairs(self.views) do
		view.TickViewNotify(view)
	end
end

M.TickRecycle = function(self)
	for instanceId, element in pairs(self._toRecycleElements) do
		if element then
			self._toRecycleElements[instanceId] = nil

			element._Recycle(element)
		end
	end
end

M.RestageItem = function(self, instanceId)
	for _, view in pairs(self.views) do
		view.RestageItem(view, instanceId)
	end
end

M.RefreshViewStage = function(self, stage)
	for _, view in pairs(self.views) do
		view.RefreshStage(view, stage)
	end
end

M.OnLinkModeChange = function(self)
	for _, view in pairs(self.views) do
		view.RefreshStage(view, EMapViewStage.LinkMode)
	end
end

M.OnSpiritChange = function(self, spiritId)
	for _, view in pairs(self.views) do
		view.SetFilterSpiritId(view, spiritId)
	end
end

M.OnUrbanBadgeInfoChange = function(self)
	for _, view in pairs(self.views) do
		view.RefreshStage(view, EMapViewStage.SpiritAndBadge)
	end
end

return M
