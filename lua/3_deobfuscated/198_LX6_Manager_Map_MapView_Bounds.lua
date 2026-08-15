local M = MapView

function M:InitBound()
	return
end

function M:TrySetBoundsTable(src, target)
	local changed = false

	for gBoundId, bound in pairs(target) do
		if not src[gBoundId] then
			changed = true
			target[gBoundId] = nil
		end
	end

	for gBoundId, bound in pairs(src) do
		if not target[gBoundId] then
			changed = true
			target[gBoundId] = bound
		end
	end

	return changed
end

function M:SetupBoundsByAreaId(areaIds)
	local sortedAreaIds = gGpsTools.GetCopiedArray(areaIds)

	table.sort(sortedAreaIds)

	local changed = gGpsTools.TrySetValueArrays(self.limitAreaInfos.areaIds, sortedAreaIds)

	gGpsTools.ReleaseArray(sortedAreaIds)

	if self.limitAreaInfos.type == 0 and not changed then
		return
	end

	self.limitAreaInfos.raidId = 0
	self.limitAreaInfos.type = 0

	self:RefreshLimitBounds()
end

function M:SetupBoundsByRaidId(raidId)
	if self.limitAreaInfos.type == 1 and self.limitAreaInfos.raidId == raidId then
		return
	end

	self.limitAreaInfos.raidId = raidId
	self.limitAreaInfos.type = 1

	table.clear(self.limitAreaInfos.areaIds)
	self:RefreshLimitBounds()
end

function M:RefreshLimitBounds()
	local allBoundIds = gGpsTools.GetTable()

	if self.limitAreaInfos.type == 0 then
		local localBoundIds = gGpsTools.GetTable()

		for _, areaId in ipairs(self.limitAreaInfos.areaIds) do
			local raidId, indoorId = gMapSystem.area:SplitAreaId(areaId)

			array.clear(localBoundIds)

			local suc = LX6.Gps.AreaMgr.LuaTryGetBoundIdsByArea(raidId, indoorId, localBoundIds)

			if suc then
				for _, gBoundId in ipairs(localBoundIds) do
					local bound = gMapSystem.area:GetBound(gBoundId)

					if bound then
						allBoundIds[gBoundId] = bound
					else
						gGpsTools.Assert(gGpsModule.SafeAssert, "MapView Logic Error: Bound not found for gBoundId: " .. gBoundId)
					end
				end
			else
				gGpsTools.Assert(gGpsModule.SafeAssert, "MapView Logic Error")
			end
		end

		gGpsTools.ReleaseTable(localBoundIds)
	elseif self.limitAreaInfos.type == 1 then
		local gBoundIdsCache = gGpsTools.GetTable()
		local raidId = self.limitAreaInfos.raidId
		local suc = LX6.Gps.AreaMgr.LuaTryGetBoundIdsByRaidId(raidId, gBoundIdsCache)

		if suc then
			for _, gBoundId in ipairs(gBoundIdsCache) do
				local bound = gMapSystem.area:GetBound(gBoundId)

				if bound then
					allBoundIds[gBoundId] = bound
				else
					gGpsTools.Assert(gGpsModule.SafeAssert, "MapView Logic Error: Bound not found for gBoundId: " .. gBoundId)
				end
			end

			gGpsTools.ReleaseTable(gBoundIdsCache)
		else
			gGpsTools.Assert(gGpsModule.SafeAssert, "MapView Logic Error: raidId: " .. (raidId or "nil"))
		end
	else
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView Logic Error: Invalid limitAreaInfos type: " .. tostring(self.limitAreaInfos.type))
	end

	local changed = false
	local target = self.areaSpace.bounds

	for gBoundId, bound in pairs(allBoundIds) do
		if not target[gBoundId] then
			changed = true
			target[gBoundId] = bound

			if self.cfg.needBoundSource then
				self:ConnectSource(bound)
			end
		end
	end

	for gBoundId, bound in pairs(target) do
		if not allBoundIds[gBoundId] then
			changed = true
			target[gBoundId] = nil

			if self.cfg.needBoundSource then
				self:DisconnectSource(bound)
			end
		end
	end

	gGpsTools.ReleaseArray(allBoundIds)

	if changed then
		table.clear(self.areaSpace.connectCache)
		self:RefreshTraceBounds()
		self:RefreshStage(EMapViewStage.Gate)

		for instanceId, _ in pairs(self.items) do
			self:TryUpdateItemCoord(instanceId)
		end
	end
end

function M:TickPlayerBounds(playerBounds)
	local changed = self:TrySetBoundsTable(playerBounds, self.playerBounds)

	if not changed then
		return
	end

	self:RefreshTraceBounds()
end

function M:RefreshTraceBounds()
	local newTraceBounds = gGpsTools.GetTable()
	local areaBounds = self.areaSpace.bounds

	for gBoundId, bound in pairs(self.playerBounds) do
		if areaBounds[gBoundId] then
			newTraceBounds[gBoundId] = bound
		end
	end

	if not next(newTraceBounds) then
		for gBoundId, bound in pairs(areaBounds) do
			newTraceBounds[gBoundId] = bound
		end
	end

	local changed = self:TrySetBoundsTable(newTraceBounds, self.traceSpace.bounds)

	if changed then
		table.clear(self.traceSpace.connectCache)

		if self.sourceLayers.trace then
			for instanceId, _ in pairs(self.sourceLayers.trace) do
				self:TryUpdateItemCoord(instanceId)
			end
		end
	end
end
