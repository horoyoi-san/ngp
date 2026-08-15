gMapSystem_Trace = gMapSystem_Trace or {}
local M = gMapSystem_Trace

function M:Init()
	self._activeTraceIds = {}
	self.type2TraceEntryDict = {}
	self._disableRemoveTrace = false
	self.inited = true
	self.traceSource = GpsSource.CreateCommon("trace", true)
	self.weakGuideSource = GpsSource.CreateCommon("weakGuide", true)
	self.weakGuideInfos = {}
	self._realWeakGuideInstanceIds = {}
	self.mainTraceGpsId = nil
end

function M:OnLogin()
	self.mainTraceGpsId = nil

	self:EnableRemoveTrace(true)
end

function M:OnLogout()
	return
end

function M:Tick()
	if not self.inited or self._disableRemoveTrace or L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	local indoorId = gMapSystem.lastIndoorId or 0

	if indoorId ~= 0 then
		local currentIndoorGpsId = gGpsTools.GetGpsId(EMapElementType.Compound, indoorId)
		local element = gMapSystem.container:GetByGpsId(currentIndoorGpsId)

		if element then
			element:ClearTraceInfo()

			return
		end
	end

	for type, traceTypeEntry in pairs(self.type2TraceEntryDict) do
		if traceTypeEntry.traceInfos then
			for id, traceInfo in pairs(traceTypeEntry.traceInfos) do
				local element = gMapSystem.container:Get(id)

				if not element then
					print_error("Trace Element Not Found", id)
				elseif self:ShouldRemoveTraceElement(element) then
					element:ClearTraceInfo()

					return
				end
			end
		end
	end
end

function M:ShouldRemoveTraceElement(element)
	if not element then
		return true
	end

	if element.areaId ~= gMapSystem.lastAreaId then
		return false
	end

	if element.gpsData.removeGpsRange and element.gpsData.removeGpsRange > 0 then
		local worldPos = element:GetWorldPos()
		local sqrRange = element.gpsData.removeGpsRange * element.gpsData.removeGpsRange
		local sqrDist = Vector3.SqrDistance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, worldPos)

		if sqrDist < sqrRange then
			return true
		end
	end

	return false
end

function M:IsTracing(instanceId)
	if not instanceId then
		return false
	end

	return self._activeTraceIds[instanceId] or false
end

function M:UpdateTraceInfo(instanceId)
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

	if traceInfo and traceInfo.layerMask == newTraceInfo.layerMask and traceInfo.layerSelf == newTraceInfo.layerSelf then
		return
	end

	local needFullUpdate = false

	if traceInfo then
		if traceInfo.layerMask == traceTypeEntry.maxLayerMask and newTraceInfo.layerMask < traceInfo.layerMask then
			needFullUpdate = true
		end

		traceInfo.layerSelf = newTraceInfo.layerSelf or 0
		traceInfo.layerMask = newTraceInfo.layerMask or 0
	else
		traceInfo = gGpsTools.GetTable()
		traceTypeEntry.traceInfos[instanceId] = traceInfo
		traceInfo.layerSelf = newTraceInfo.layerSelf or 0
		traceInfo.layerMask = newTraceInfo.layerMask or 0

		if traceTypeEntry.maxLayerMask < traceInfo.layerMask then
			needFullUpdate = true
		end
	end

	if needFullUpdate then
		self:ReparseTraceTypeEntry(traceTypeEntry)
	else
		if traceTypeEntry.maxLayerMask < traceInfo.layerMask then
			gGpsTools.Assert(gGpsModule.SafeAssert, "UpdateTraceInfo: traceTypeEntry.maxLayerMask < traceInfo.layerMask", traceTypeEntry.maxLayerMask, traceInfo.layerMask)

			traceTypeEntry.maxLayerMask = traceInfo.layerMask
		end

		if traceTypeEntry.maxLayerMask <= traceInfo.layerSelf then
			traceTypeEntry.activeIds[instanceId] = true

			self:RealAddTraceId(instanceId)
		else
			traceTypeEntry.activeIds[instanceId] = nil

			self:RealRemoveTraceId(instanceId)
		end
	end
end

function M:GetAllTraceElements(viewMask, result)
	result = result or {}

	for instanceId, _ in pairs(self._activeTraceIds) do
		local element = gMapSystem.container:Get(instanceId)

		if element and (not viewMask or element:CheckViewMask(viewMask)) then
			result[instanceId] = element
		end
	end

	return result
end

function M:Tmp_HasAnyTraceTarget()
	local targets = gGpsTools.GetTable()

	self:GetAllTraceElements(EMapViewMask.BigMap, targets)

	local ret = next(targets) ~= nil

	gGpsTools.ReleaseTable(targets)

	return ret
end

function M:RemoveTraceInfo(instanceId)
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
	elseif traceInfo.layerMask < traceTypeEntry.maxLayerMask then
		traceTypeEntry.activeIds[instanceId] = nil

		self:RealRemoveTraceId(instanceId)
	else
		self:ReparseTraceTypeEntry(traceTypeEntry)
	end
end

function M:ReparseTraceTypeEntry(entry)
	local maxLayerMask = -10

	for id, info in pairs(entry.traceInfos) do
		if maxLayerMask < info.layerMask then
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
		if info and entry.maxLayerMask <= info.layerSelf then
			entry.activeIds[id] = true

			self:RealAddTraceId(id)
		else
			entry.activeIds[id] = nil

			self:RealRemoveTraceId(id)
		end
	end
end

function M:RealAddTraceId(instanceId)
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

function M:RealRemoveTraceId(instanceId)
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

function M:EnableRemoveTrace(immediately)
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

function M:DisableRemoveTrace()
	if self._enableRemoveTraceTimer then
		self._enableRemoveTraceTimer:Stop()

		self._enableRemoveTraceTimer = nil
	end

	self._disableRemoveTrace = true
end

function M:FindFirstTracingElement(prediction)
	if not prediction then
		return nil
	end

	for instanceId, _ in pairs(self._activeTraceIds) do
		local element = gMapSystem.container:Get(instanceId)

		if element and prediction(element) then
			return element
		end
	end

	return nil
end

function M:AnyTracingElement(prediction)
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

function M:FindTracingElement(prediction, result)
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

function M:RegisterWeakGuide(instanceId, range)
	if not self.weakGuideInfos[instanceId] then
		self.weakGuideInfos[instanceId] = {
			guiding = false
		}
	end

	self.weakGuideInfos[instanceId].range = range
	self.weakGuideInfos[instanceId].removed = false
end

function M:UnregisterWeakGuide(instanceId)
	local weakGuideInfo = self.weakGuideInfos[instanceId]

	if weakGuideInfo then
		weakGuideInfo.removed = true

		self:RealRemoveWeakGuide(instanceId)
	end
end

function M:RealAddWeakGuide(instanceId)
	if self._realWeakGuideInstanceIds[instanceId] then
		return
	end

	self._realWeakGuideInstanceIds[instanceId] = true

	self.weakGuideSource:AddElement(instanceId)
end

function M:RealRemoveWeakGuide(instanceId)
	if not self._realWeakGuideInstanceIds[instanceId] then
		return
	end

	self._realWeakGuideInstanceIds[instanceId] = nil
	local element = self.env.container:Get(instanceId)

	if element then
		self.weakGuideSource:RemoveElement(instanceId)
	end
end

function M:TickWeakGuide()
	if L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

	for instanceId, weakGuideInfo in pairs(self.weakGuideInfos) do
		local element = self.env.container:Get(instanceId)

		if weakGuideInfo.removed or not element then
			self.weakGuideInfos[instanceId] = nil
		else
			local needWeakGuide = false

			if element and element.areaId == self.env.lastAreaId then
				local worldPos = element:GetWorldPos()
				local dx = playerPos.x - worldPos.x
				local dy = playerPos.y - worldPos.y
				local dz = playerPos.z - worldPos.z

				if dx * dx + dy * dy + dz * dz < weakGuideInfo.range * weakGuideInfo.range then
					needWeakGuide = true
				end
			end

			if needWeakGuide ~= weakGuideInfo.guiding then
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

function M:SetMainTraceGpsId(gpsId)
	local oldId = self.mainTraceGpsId
	self.mainTraceGpsId = gpsId
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if gpsId and not gMapSubSystem_FunctionPoint:IsInInviteRiding() and not gMapSubSystem_Gangster:IsGangsterElement(gpsId) and (not element or not gGpsBindingMgr:FindTaskGpsInstanceIdBySameBinding(element.instanceId)) then
		gGpsManager:SwitchGpsShowMode(gGpsShowMode.ShowMapMode)
	else
		gGpsManager:SwitchGpsShowMode(gGpsShowMode.ShowTaskMode)
	end

	self:UpdateUniqueTraceGpsId(oldId, gpsId)
end

function M:TryRemoveMainTraceByGpsId(gpsId)
	if self.mainTraceGpsId == gpsId then
		self:RemoveMainTrace()
	end
end

function M:RemoveMainTrace()
	if self.mainTraceGpsId then
		gGpsManager:RemoveGPSById(self.mainTraceGpsId, gTaskGpsType.Trace)
	end
end

function M:UpdateUniqueTraceGpsId(oldId, newId)
	local oldElement = self.env.container:GetByGpsId(oldId)
	local newElement = self.env.container:GetByGpsId(newId)

	if oldElement then
		oldElement:ClearTraceInfo()
	end

	if newElement then
		newElement:SetTraceInfo(EMapGTraceType.Main, 1)
	end
end

function M:Deprecated_AddGps(data)
	return
end

function M:CommonTraceElement(gpsId)
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if element then
		gMapSubSystemActionHelper.Trace(element)
	end
end

return M
