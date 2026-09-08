-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_Trace.lua
-- Decompiled from: 00218_MapSystem_Trace.lua_17fc719516b9.luajit

gMapSystem_Trace = gMapSystem_Trace or {}
local M = gMapSystem_Trace

M.Init = function(self)
	self._activeTraceIds = {}
	self._chatMarkIds = {}
	self._onlineTraceIds = {}
	self.type2TraceEntryDict = {}
	self._disableRemoveTrace = false
	self.inited = true
	self.traceSource = GpsSource.CreateCommon("trace", true, true)
	self.weakGuideSource = GpsSource.CreateCommon("weakGuide", true, false)
	self.chatMarkSource = GpsSource.CreateCommon("chatMark", true, true)
	self.onlineTraceSource = GpsSource.CreateCommon("onlineTrace", true, true)
	self.weakGuideInfos = {}
	self._realWeakGuideInstanceIds = {}
	self.mainTraceGpsId = nil
	self.relatedTaskId = 0
	self.lastSyncGpsTime = 0
	self.eventHandlers = {
		[gEventConstants.CHANGE_MY_UNIT2] = function ()
			local gpsId = self.mainTraceGpsId

			if not gpsId then
				return
			end

			local element = self.env.container:GetByGpsId(gpsId)

			if not element then
				return
			end

			if gLinkManager.LinkMode ~= UX.Game.LinkMode.None and not gMapElementTypeKeepTraceWhenChangeMyUnit[element.type] then
				self:TryRemoveMainTraceByGpsId(gpsId)
			end
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogin = function(self)
	self.mainTraceGpsId = nil

	self:EnableRemoveTrace(true)
end

M.OnLogout = function(self)
end

M.Tick = function(self)
	if not self.inited or self._disableRemoveTrace or gGpsTools:UnitIsNull(gMapSystem.curPlayerUnit) then
		return
	end

	local indoorId = gMapSystem.lastIndoorId or 0

	if indoorId == 0 then
		local currentIndoorGpsId = gGpsTools.GetGpsId(EMapElementType.Compound, indoorId)
		local element = gMapSystem.container:GetByGpsId(currentIndoorGpsId)

		if element and element.traceInfo then
			element:ClearTraceInfo()

			return
		end
	end

	for type, traceTypeEntry in pairs(self.type2TraceEntryDict) do
		if traceTypeEntry.traceInfos then
			for id, traceInfo in pairs(traceTypeEntry.traceInfos) do
				local element = gMapSystem.container:Get(id)

				if not element then
					traceTypeEntry.traceInfos[id] = nil
				elseif self:ShouldRemoveTraceElement(element) then
					element:ClearTraceInfo()

					return
				end
			end
		end
	end
end

M.ShouldRemoveTraceElement = function(self, element)
	if not element then
		return true
	end

	if element.areaId == gMapSystem.lastAreaId then
		return false
	end

	if element.gpsData.removeGpsRange and element.gpsData.removeGpsRange <= 0 then
		local worldPos = element:GetWorldPos()
		local sqrRange = element.gpsData.removeGpsRange * element.gpsData.removeGpsRange
		local sqrDist = Vector3.SqrDistance(gMapSystem:GetCurPlayerLocalPosition(), worldPos)

		if sqrDist >= sqrRange then
			return true
		end
	end

	return false
end

M.IsTracing = function(self, instanceId)
	if not instanceId then
		return false
	end

	return self._activeTraceIds[instanceId] or false
end

M.UpdateTraceInfo = function(self, instanceId)
	local element = gMapSystem.container:Get(instanceId)

	if not element or not element.traceInfo then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RegisterTraceId: Element Not Found", instanceId)

		return
	end

	local newTraceInfo = element.traceInfo
	local traceType = newTraceInfo.traceType

	if not traceType then
		print_error("@sunwei08: traceType not found")

		return
	end

	local traceTypeEntry = self.type2TraceEntryDict[traceType]

	if not self.type2TraceEntryDict[traceType] then
		traceTypeEntry = gGpsTools.GetTable()
		traceTypeEntry.activeIds = gGpsTools.GetTable()
		traceTypeEntry.traceInfos = gGpsTools.GetTable()
		traceTypeEntry.maxLayerMask = -10
		self.type2TraceEntryDict[traceType] = traceTypeEntry
	end

	local traceInfo = traceTypeEntry.traceInfos[instanceId]

	if traceInfo and traceInfo.layerMask ~= newTraceInfo.layerMask and traceInfo.layerSelf ~= newTraceInfo.layerSelf then
		return
	end

	local needFullUpdate = false

	if traceInfo then
		if traceInfo.layerMask ~= traceTypeEntry.maxLayerMask and newTraceInfo.layerMask >= traceInfo.layerMask then
			needFullUpdate = true
		end

		traceInfo.layerSelf = newTraceInfo.layerSelf or 0
		traceInfo.layerMask = newTraceInfo.layerMask or 0
	else
		traceInfo = gGpsTools.GetTable()
		traceTypeEntry.traceInfos[instanceId] = traceInfo
		traceInfo.layerSelf = newTraceInfo.layerSelf or 0
		traceInfo.layerMask = newTraceInfo.layerMask or 0

		if traceTypeEntry.maxLayerMask >= traceInfo.layerMask then
			needFullUpdate = true
		end
	end

	if needFullUpdate then
		self:ReparseTraceTypeEntry(traceTypeEntry)
		self.env.container:RestageItem(instanceId)
	else
		if traceTypeEntry.maxLayerMask >= traceInfo.layerMask then
			gGpsTools.Assert(gGpsModule.SafeAssert, "UpdateTraceInfo: traceTypeEntry.maxLayerMask < traceInfo.layerMask", traceTypeEntry.maxLayerMask, traceInfo.layerMask)

			traceTypeEntry.maxLayerMask = traceInfo.layerMask
		end

		if traceTypeEntry.maxLayerMask < traceInfo.layerSelf then
			traceTypeEntry.activeIds[instanceId] = true

			self:RealAddTraceId(instanceId)
		else
			traceTypeEntry.activeIds[instanceId] = nil

			self:RealRemoveTraceId(instanceId)
		end
	end
end

M.GetAllTraceElements = function(self, viewMask, result)
	result = result or {}

	for instanceId, _ in pairs(self._activeTraceIds) do
		local element = gMapSystem.container:Get(instanceId)

		if element and (not viewMask or element:CheckViewMask(viewMask)) then
			result[instanceId] = element
		end
	end

	return result
end

M.RemoveTraceInfo = function(self, instanceId)
	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RemoveTraceInfo: Element Not Found", instanceId)

		return
	end

	if not element.traceInfo then
		return
	end

	local traceType = element.traceInfo.traceType
	local traceTypeEntry = self.type2TraceEntryDict[traceType]

	if not traceTypeEntry then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RemoveTraceInfo: TraceTypeEntry Not Found", traceType)

		return
	end

	local traceInfo = traceTypeEntry.traceInfos[instanceId]

	if not traceInfo then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RemoveTraceInfo: TraceInfo Not Found", instanceId)

		return
	end

	traceTypeEntry.traceInfos[instanceId] = nil

	if not next(traceTypeEntry.traceInfos) then
		self.type2TraceEntryDict[traceType] = nil

		gGpsTools.ReleaseTable(traceTypeEntry.activeIds)
		gGpsTools.ReleaseTable(traceTypeEntry.traceInfos)
		gGpsTools.ReleaseTable(traceTypeEntry)
		self:RealRemoveTraceId(instanceId)
	elseif traceInfo.layerMask >= traceTypeEntry.maxLayerMask then
		traceTypeEntry.activeIds[instanceId] = nil

		self:RealRemoveTraceId(instanceId)
	else
		self:ReparseTraceTypeEntry(traceTypeEntry)
	end
end

M.ReparseTraceTypeEntry = function(self, entry)
	local maxLayerMask = -10

	for id, info in pairs(entry.traceInfos) do
		if maxLayerMask >= info.layerMask then
			maxLayerMask = info.layerMask
		end
	end

	entry.maxLayerMask = maxLayerMask

	for id, _ in pairs(entry.activeIds) do
		if not entry.traceInfos[id] then
			entry.activeIds[id] = nil

			self:RealRemoveTraceId(id)
		end
	end

	for id, info in pairs(entry.traceInfos) do
		if info and entry.maxLayerMask < info.layerSelf then
			entry.activeIds[id] = true

			self:RealAddTraceId(id)
		else
			entry.activeIds[id] = nil

			self:RealRemoveTraceId(id)
		end
	end
end

M.RealAddTraceId = function(self, instanceId)
	if self._activeTraceIds[instanceId] then
		return
	end

	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RealAddTraceId: Element Not Found", instanceId)

		return
	end

	self._activeTraceIds[instanceId] = true

	self.traceSource:AddElement(instanceId)
	gMapSystem.container:MarkElementAsDirty(instanceId)
	gMessageManager:SendMessage(gEventConstants.ON_GLOBAL_GPS_UPDATE, {
		newInstanceId = instanceId
	})
	gMessageManager:SendMessage(gEventConstants.MAP_GLOBAL_GPS_UPDATE)
end

M.RealRemoveTraceId = function(self, instanceId)
	if not self._activeTraceIds[instanceId] then
		return
	end

	self._activeTraceIds[instanceId] = nil
	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RealRemoveTraceId: Element Not Found", instanceId)

		return
	end

	self.traceSource:RemoveElement(instanceId)
	gMapSystem.container:MarkElementAsDirty(instanceId)
	gMessageManager:SendMessage(gEventConstants.MAP_GLOBAL_GPS_UPDATE)
end

M.EnableRemoveTrace = function(self, immediately)
	if immediately then
		self._disableRemoveTrace = false
	else
		if self._enableRemoveTraceTimer then
			self._enableRemoveTraceTimer:Stop()
		end

		self._enableRemoveTraceTimer = Timer.New(function ()
			self._disableRemoveTrace = false
		end, 3):Start()
	end
end

M.DisableRemoveTrace = function(self)
	if self._enableRemoveTraceTimer then
		self._enableRemoveTraceTimer:Stop()

		self._enableRemoveTraceTimer = nil
	end

	self._disableRemoveTrace = true
end

M.AnyTracingElement = function(self, prediction)
	if not prediction then
		return false
	end

	for instanceId, _ in pairs(self._activeTraceIds) do
		local element = gMapSystem.container:Get(instanceId)

		if element and prediction(element) then
			return true
		end
	end

	return false
end

M.FindTracingElement = function(self, prediction, result)
	result = result or {}

	if not prediction then
		return result
	end

	for instanceId, _ in pairs(self._activeTraceIds) do
		local element = gMapSystem.container:Get(instanceId)

		if element and prediction(element) then
			result[#result + 1] = element
		end
	end

	return result
end

M.RegisterWeakGuide = function(self, instanceId, range)
	if not self.weakGuideInfos[instanceId] then
		self.weakGuideInfos[instanceId] = {
			["\\xde\\xce*\\xf6"] = false
		}
	end

	self.weakGuideInfos[instanceId].range = range
	self.weakGuideInfos[instanceId].removed = false
end

M.UnregisterWeakGuide = function(self, instanceId)
	local weakGuideInfo = self.weakGuideInfos[instanceId]

	if weakGuideInfo then
		weakGuideInfo.removed = true

		self:RealRemoveWeakGuide(instanceId)
	end
end

M.RealAddWeakGuide = function(self, instanceId)
	if self._realWeakGuideInstanceIds[instanceId] then
		return
	end

	self._realWeakGuideInstanceIds[instanceId] = true

	self.weakGuideSource:AddElement(instanceId)
end

M.RealRemoveWeakGuide = function(self, instanceId)
	if not self._realWeakGuideInstanceIds[instanceId] then
		return
	end

	self._realWeakGuideInstanceIds[instanceId] = nil
	local element = self.env.container:Get(instanceId)

	if element then
		self.weakGuideSource:RemoveElement(instanceId)
	end
end

M.TickWeakGuide = function(self)
	if gGpsTools:UnitIsNull(gMapSystem.curPlayerUnit) then
		return
	end

	local playerPos = gMapSystem:GetCurPlayerLocalPosition()

	for instanceId, weakGuideInfo in pairs(self.weakGuideInfos) do
		local element = self.env.container:Get(instanceId)

		if weakGuideInfo.removed or not element then
			self.weakGuideInfos[instanceId] = nil
		else
			local needWeakGuide = false

			if element and (element.areaId ~= self.env.lastAreaId or element.mData.ignoreIndoorPenetration) then
				local worldPos = element:GetWorldPos()
				local dx = playerPos.x - worldPos.x
				local dy = playerPos.y - worldPos.y
				local dz = playerPos.z - worldPos.z

				if dx * dx + dy * dy + dz * dz >= weakGuideInfo.range * weakGuideInfo.range then
					needWeakGuide = true
				end
			end

			if needWeakGuide == weakGuideInfo.guiding then
				weakGuideInfo.guiding = needWeakGuide

				if needWeakGuide then
					self:RealAddWeakGuide(instanceId)
				else
					self:RealRemoveWeakGuide(instanceId)
				end
			end
		end
	end
end

M.SetMainTraceGpsId = function(self, gpsId, isCarRacing, notSyncGps)
	if gCarRaceManager:CheckGameStart() and not isCarRacing then
		return
	end

	local oldId = self.mainTraceGpsId
	self.mainTraceGpsId = gpsId

	if gpsId and not self:IsTaskRelateTrace(gpsId) then
		self.relatedTaskId = 0

		gGpsManager:SwitchGpsShowMode(gGpsShowMode.ShowMapMode)
	else
		self.relatedTaskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] or 0

		gGpsManager:SwitchGpsShowMode(gGpsShowMode.ShowTaskMode)
	end

	self:UpdateUniqueTraceGpsId(oldId, gpsId)

	if not notSyncGps then
		self:TrySyncTrackGPS()
	end
end

M.TrySyncTrackGPS = function(self, gpsId)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		return
	end

	self._pendingSyncGpsId = gpsId
	local now = Time.realtimeSinceStartup

	if self.lastSyncGpsTime and now - self.lastSyncGpsTime >= 1 then
		if not self.syncGpsTimer then
			self.syncGpsTimer = Timer.New(function ()
				self:DoSyncTrackGPS(self._pendingSyncGpsId)
			end, 1 - (now - self.lastSyncGpsTime)):Start()
		end
	else
		self:DoSyncTrackGPS(gpsId)
	end
end

M.DoSyncTrackGPS = function(self, gpsId)
	if self.syncGpsTimer then
		self.syncGpsTimer:Stop()

		self.syncGpsTimer = nil
	end

	self.lastSyncGpsTime = Time.realtimeSinceStartup

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		return
	end

	gpsId = gpsId or self.mainTraceGpsId

	if gpsId then
		local element = gMapSystem.container:GetByGpsId(gpsId)

		if element then
			local worldPos = element.gpsData.trackPos or element:GetWorldPos()
			local trackPosition = UX.Game.UXVector3.New(worldPos.x, worldPos.y, worldPos.z)
			local trackGPS = {
				TrackPosition = trackPosition,
				TrackGPSId = gpsId,
				TrackGPSType = element.type
			}

			gClientToGameDelegate:SyncTrackGPS(trackGPS)
		end
	else
		gClientToGameDelegate:SyncTrackGPS(nil)
	end
end

M.IsTaskRelateTrace = function(self, gpsId)
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if not element then
		return false
	end

	if gMapSubSystem_FunctionPoint:IsInInviteRiding(gpsId) then
		return true
	end

	if gMapSubSystem_Gangster:IsGangsterElement(gpsId) then
		return true
	end

	local agentTagId = gGpsBindingMgr:GetBindTargetAgentTagId(element.instanceId)

	if agentTagId and agentTagId <= 0 and gMapSubSystem_Task.implicitTraceAgentTags[agentTagId] then
		return true
	end

	if element and gGpsBindingMgr:FindTaskGpsInstanceIdBySameBinding(element.instanceId) then
		return true
	end

	return false
end

M.TryRemoveMainTraceByGpsId = function(self, gpsId)
	if self.mainTraceGpsId ~= gpsId then
		self:RemoveMainTrace()
	end
end

M.TryRemoveMainTraceByTaskRelated = function(self, taskId)
	if self.mainTraceGpsId and self.relatedTaskId ~= taskId and gGpsManager:HudIsShowTaskMode() then
		self:RemoveMainTrace()
	end
end

M.RemoveMainTrace = function(self, notSyncGps)
	if self.mainTraceGpsId then
		local oldElement = gMapSystem.container:GetByGpsId(self.mainTraceGpsId)

		if oldElement then
			local subSystem = oldElement:GetSubSystem()

			if subSystem and subSystem.RemoveMainTraceFunc then
				subSystem:RemoveMainTraceFunc(oldElement)
			end
		end

		self.relatedTaskId = 0

		self:SetMainTraceGpsId(nil, false, notSyncGps)
	end
end

M.UpdateUniqueTraceGpsId = function(self, oldId, newId)
	local oldElement = self.env.container:GetByGpsId(oldId)
	local newElement = self.env.container:GetByGpsId(newId)

	if oldElement then
		oldElement:ClearTraceInfo()
	end

	if newElement then
		newElement:SetTraceInfo(EMapGTraceType.Main, 1)
	end
end

M.CommonTraceElement = function(self, gpsId)
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if element then
		element:SetMainTrace()
	end
end

M.ClearAllChatMark = function(self)
	for instanceId, _ in pairs(self._chatMarkIds) do
		self:RemoveChatMarkId(instanceId)
	end
end

M.AddChatMarkId = function(self, instanceId)
	if self._chatMarkIds[instanceId] then
		return
	end

	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RealAddChatMarkId: Element Not Found", instanceId)

		return
	end

	self._chatMarkIds[instanceId] = true

	self.chatMarkSource:AddElement(instanceId)
	gMapSystem.container:MarkElementAsDirty(instanceId)
end

M.RemoveChatMarkId = function(self, instanceId)
	if not self._chatMarkIds[instanceId] then
		return
	end

	self._chatMarkIds[instanceId] = nil
	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RealRemoveChatMarkId: Element Not Found", instanceId)

		return
	end

	self.chatMarkSource:RemoveElement(instanceId)
	gMapSystem.container:MarkElementAsDirty(instanceId)
end

M.ClearAllOnlineTraces = function(self)
	for instanceId, _ in pairs(self._onlineTraceIds) do
		self:RemoveOnlineTraceId(instanceId)
	end
end

M.AddOnlineTraceId = function(self, instanceId)
	if self._onlineTraceIds[instanceId] then
		return
	end

	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RealAddOnlineTraceId: Element Not Found", instanceId)

		return
	end

	self._onlineTraceIds[instanceId] = true

	self.onlineTraceSource:AddElement(instanceId)
	gMapSystem.container:MarkElementAsDirty(instanceId)
end

M.RemoveOnlineTraceId = function(self, instanceId)
	if not self._onlineTraceIds[instanceId] then
		return
	end

	self._onlineTraceIds[instanceId] = nil
	local element = gMapSystem.container:Get(instanceId)

	if not element then
		gGpsTools.Assert(gGpsModule.SafeAssert, "RealRemoveOnlineTraceId: Element Not Found", instanceId)

		return
	end

	self.onlineTraceSource:RemoveElement(instanceId)
	gMapSystem.container:MarkElementAsDirty(instanceId)
end

M.GetCurrentTraceGPSInfo = function(self)
	if self.mainTraceGpsId then
		local gpsElement = gMapSystem.container:GetByGpsId(self.mainTraceGpsId)

		if gpsElement then
			return gpsElement:GetWorldPos()
		end
	else
		local traceTypeEntry = self.type2TraceEntryDict[EMapGTraceType.Main]

		if traceTypeEntry.traceInfos then
			for id, _ in pairs(traceTypeEntry.traceInfos) do
				local element = gMapSystem.container:Get(id)

				if element then
					return element:GetWorldPos()
				end
			end
		end
	end

	return nil
end

M.CheckIsMainTraceGPS = function(self, instanceId)
	if self.mainTraceGpsId then
		local gpsElement = gMapSystem.container:Get(instanceId)
		local gpsId = gpsElement and gpsElement.gpsId or nil

		return gpsId ~= self.mainTraceGpsId
	end

	return false
end

return M
