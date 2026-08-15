local CSGpsContainer = LX6.Gps.GpsContainer
local bit = require("bit")

if false then
	require("LX6/Manager/Map/MapElementDef")
end

gMapSystem_Element_State = {
	Tracing = 2,
	Normal = 1
}
MapElement = MapElement or {}
local M = MapElement
M.__index = M
M._static_instanceIdCount = 1
M._static_ePool = {}

local function GenModelMetatable()
	local meta = {
		__index = function (t, k)
			local v = rawget(t, k)

			if v ~= nil then
				return v
			end

			local bindData = rawget(t, "__data")

			return rawget(bindData, k)
		end,
		__newindex = function (t, k, v)
			local bindData = rawget(t, "__data")

			if rawget(bindData, k) == v then
				return
			end

			rawset(bindData, k, v)

			local elem = rawget(t, "__elem")

			elem:_SetDirty()
		end
	}

	return meta
end

M.__mDataMT = GenModelMetatable()

function M.CreateLegacy(type, id, subSystemType, viewMask, raidId)
	local gpsId = gGpsTools.GetGpsId(type, id)
	local instanceId = M._static_instanceIdCount
	M._static_instanceIdCount = instanceId + 1
	local e = nil
	local poolSize = #M._static_ePool

	if poolSize > 0 then
		e = M._static_ePool[poolSize]
		M._static_ePool[poolSize] = nil
	else
		e = setmetatable({}, M)
		e.gpsData = {}
		e.fData = {}
		e._mRawData = {
			_visible = false
		}
		e.mData = setmetatable({
			__elem = e,
			__data = e._mRawData
		}, M.__mDataMT)
		e.bigMapData = setmetatable({
			__elem = e,
			__data = {}
		}, M.__mDataMT)
		e.miniMapData = setmetatable({
			__elem = e,
			__data = {}
		}, M.__mDataMT)
		e._belongSources = gGpsTools.GetTable()
		e._hasResolvedPos = false
		e._resolvedPos = {
			z = 0,
			x = 0,
			y = 0
		}
	end

	e.instanceId = instanceId
	e.id = id
	e.type = type
	e.gpsId = gpsId
	e.subSystemType = subSystemType
	e._viewMask = viewMask
	e.isDestroyed = false

	e:SetViewMask(viewMask)

	e.areaId = 0
	e.raidId = raidId
	e.indoorId = 0
	e.localBoundId = 0
	e.gBoundId = 0
	e._viewCounter = 0

	CSGpsContainer.AddGpsData(instanceId, e)
	gMapSystem.container:AddElement(e)

	return e
end

function M:Dispose()
	self:ClearTraceInfo()
	gGpsManager:TryRemoveMapGuideById(self.gpsId)
	self:CbtClearWeakGuideInfo()
	self:TransportByGBoundId(0)

	for _, source in pairs(self._belongSources) do
		source:RemoveElement(self.instanceId)
	end

	gMapSystem.container:RemoveElement(self)

	self.isDestroyed = true

	self:ClearBinding()

	self.isDestroyed = true
end

function M:_Recycle()
	self._bindingPos = nil
	self._relocatedPos = nil
	self.userdata = nil
	self.actions = nil
	self.traceInfo = nil
	self.overrideIndoorId = nil
	self.overrideLocalBoundId = nil
	self._viewCounter = 0

	for k in next, self.fData, nil do
		self.fData[k] = nil
	end

	for k in next, self.gpsData, nil do
		self.gpsData[k] = nil
	end

	local mData = rawget(self.mData, "__data")

	for k in next, mData, nil do
		mData[k] = nil
	end

	mData._visible = false
	local bigMapData = rawget(self.bigMapData, "__data")

	for k in next, bigMapData, nil do
		bigMapData[k] = nil
	end

	local miniMapData = rawget(self.miniMapData, "__data")

	for k in next, miniMapData, nil do
		miniMapData[k] = nil
	end

	array.clear(self._belongSources)

	M._static_ePool[#M._static_ePool + 1] = self
end

function M:SetPositionXYZ(x, y, z)
	CSGpsContainer.SetBasePosition(self.instanceId, x, y, z)
end

function M:SetPosition(worldPos)
	if not worldPos then
		return
	end

	CSGpsContainer.SetBasePosition(self.instanceId, worldPos.x, worldPos.y, worldPos.z)
end

function M:SetRelocatedPosition(relocatedPos)
	self._relocatedPos = relocatedPos

	self:_SetDirty()
end

function M:HasRelocatedPosition()
	return self._relocatedPos ~= nil
end

function M:SetBindingPos(bindingPos)
	return
end

function M:SetRaidId(raidId)
	if self.raidId == raidId then
		return
	end

	self.raidId = raidId

	gCS.GpsContainer.SetRaidId(self.instanceId, raidId)
end

function M:SetOverrideBoundInfo(indoorId, localBoundId)
	self.overrideIndoorId = indoorId
	self.overrideLocalBoundId = localBoundId
	self.indoorId = indoorId or 0
	self.localBoundId = localBoundId or 0

	self:UpdateGBoundId()
end

function M:SetBoundInfo(indoorId, localBoundId)
	self.indoorId = self.overrideIndoorId or indoorId
	self.localBoundId = self.overrideLocalBoundId or localBoundId

	self:UpdateGBoundId()
end

function M:UpdateGBoundId()
	local indoorId = self.indoorId or 0
	local localBoundId = self.localBoundId or 0
	local newGBoundId = gMapAreaMgr:GetGBoundId(self.raidId, indoorId, localBoundId)

	self:TransportByGBoundId(newGBoundId)
end

function M:IncViewCount()
	self._viewCounter = self._viewCounter + 1

	if self._viewCounter == 1 then
		-- Nothing
	end
end

function M:DecViewCount()
	if self._viewCounter > 0 then
		self._viewCounter = self._viewCounter - 1

		if self._viewCounter == 0 then
			-- Nothing
		end
	end
end

function M:TransportByGBoundId(newGBoundId)
	if self.gBoundId == newGBoundId then
		return
	end

	local mainNewBound = gMapSystem.area:GetBound(newGBoundId)

	if not mainNewBound then
		newGBoundId = 0
	end

	local oldGBoundId = self.gBoundId
	local mainOldBound = gMapSystem.area:GetBound(oldGBoundId)
	self.gBoundId = newGBoundId
	self.areaId = gMapAreaMgr:GetAreaIdByGBoundId(newGBoundId)

	if self.fData.interestOnly then
		return
	end

	if self.fData.showInBigWorld then
		local _emptyTbl = gGpsTools.GetTable()
		local oldGBoundIds = mainOldBound and mainOldBound.extendedGBoundIds or _emptyTbl
		local newGBoundIds = mainNewBound and mainNewBound.extendedGBoundIds or _emptyTbl

		for oldGBoundId, _ in pairs(oldGBoundIds) do
			if not newGBoundIds[oldGBoundId] then
				local oldBound = gMapSystem.area:GetBound(oldGBoundId)

				if oldBound then
					oldBound:RemoveElement(self.instanceId)
				end
			end
		end

		for newGBoundId, _ in pairs(newGBoundIds) do
			if not oldGBoundIds[newGBoundId] then
				local newBound = gMapSystem.area:GetBound(newGBoundId)

				if newBound then
					newBound:AddElement(self.instanceId)
				end
			end
		end
	else
		if mainOldBound then
			mainOldBound:RemoveElement(self.instanceId)
		end

		if mainNewBound then
			mainNewBound:AddElement(self.instanceId)
		end
	end
end

function M:BindAgentTag(agentTag)
	CSGpsContainer.BindAgentTag(self.instanceId, agentTag)
end

function M:BindUnit(unitId, useFeisuoPoint)
	if not unitId then
		return
	end

	if ulong.check(unitId) then
		CSGpsContainer.BindUnit(self.instanceId, false, 0, unitId, useFeisuoPoint)
		gGpsBindingMgr:AddUnitBinding(self.instanceId, unitId)
	else
		CSGpsContainer.BindUnit(self.instanceId, true, unitId, 0, useFeisuoPoint)
		gGpsBindingMgr:AddSpoonUnitBinding(self.instanceId, unitId)
	end
end

function M:BindDestructible(destructibleInstanceId)
	CSGpsContainer.BindDestructible(self.instanceId, destructibleInstanceId)
	gGpsBindingMgr:AddDestructibleBinding(self.instanceId, destructibleInstanceId)
end

function M:BindVehicle(vehicleId, vehiclePartNodeName, gpsOffsetY, needEuler, isSpoonId)
	if not ulong.check(vehicleId) then
		CSGpsContainer.BindVehicle(self.instanceId, true, vehicleId, 0, vehiclePartNodeName, needEuler)
		gGpsBindingMgr:AddSpoonVehicleBinding(self.instanceId, vehicleId)
	else
		CSGpsContainer.BindVehicle(self.instanceId, false, 0, vehicleId, vehiclePartNodeName, needEuler)
		gGpsBindingMgr:AddVehicleBinding(self.instanceId, vehicleId)
	end
end

function M:BindSlotInfo(slotPid, slotRefId, slotRefName)
	CSGpsContainer.BindSlot(self.instanceId, slotPid, slotRefId or 0, slotRefName)
	gGpsBindingMgr:AddSlotBinding(self.instanceId, slotPid, slotRefId, slotRefName)
end

function M:ClearBinding()
	CSGpsContainer.Unbind(self.instanceId)
	gGpsBindingMgr:RemoveGpsInst(self.instanceId)
end

function M:GetName()
	local overrideName = self.mData.name

	if overrideName then
		return overrideName
	end

	local lName = self.mData.lName

	return lName and lName:GetText() or ""
end

function M:_SetDirty()
	gMapSystem.container:MarkElementAsDirty(self.instanceId)
end

function M:SyncViewMaskChange(oldViewMask, newViewMask)
	return
end

function M:SetViewMask(viewMask)
	if viewMask == nil then
		print_warn("[MapElement]: SetViewMask nil")

		return
	end

	if self._viewMask == viewMask then
		return
	end

	local oldViewMask = self._viewMask
	self._viewMask = viewMask

	for _, source in pairs(self._belongSources) do
		source:ElementViewMaskChanged(self, oldViewMask, viewMask)
	end
end

function M:AddViewMask(viewmask)
	self:SetViewMask(bit.bor(self._viewMask, viewmask))
end

function M:RemoveViewMask(viewMask)
	self:SetViewMask(self._viewMask - bit.band(self._viewMask, viewMask))
end

function M:CheckViewMask(viewMask)
	return bit.band(self._viewMask, viewMask) ~= 0
end

function M:GetWorldPos(result)
	if self._relocatedPos then
		if not result then
			result = Vector3.New(self._relocatedPos.x, self._relocatedPos.y, self._relocatedPos.z)
		else
			result.x = self._relocatedPos.x
			result.y = self._relocatedPos.y
			result.z = self._relocatedPos.z
		end

		return result
	else
		return self:GetOriginWorldPos(result)
	end
end

function M:GetOriginWorldPos(result)
	if not result then
		result = Vector3.New(self._resolvedPos.x, self._resolvedPos.y, self._resolvedPos.z)
	else
		result.x = self._resolvedPos.x
		result.y = self._resolvedPos.y
		result.z = self._resolvedPos.z
	end

	return result
end

function M:GetObservedPosFrom(areaId, useOriginPos)
	if not self.areaId then
		print_warn("@sunwei08: SubSystemType: " .. (self.subSystemType or "nil"), "InstanceId: " .. self.instanceId, "Id: " .. (self.id or "nil"), "Has not AreaId", "Area Info", self.areaId, self.raidId, self.indoorId)

		return nil
	end

	if self.areaId == areaId then
		if useOriginPos then
			return self:GetOriginWorldPos()
		else
			return self:GetWorldPos()
		end
	end

	local obRaidId, obIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
	local success, x, y, z = LX6.Gps.GpsAreaConnectMgr.LuaTryGetMapAreaExitPosTo(obRaidId, obIndoorId, self.raidId, self.indoorId, nil, nil, nil)

	if not success then
		return nil
	end

	return Vector3.New(x, y, z)
end

function M:GetObservedGpsAreaPosFrom(areaId, localBoundId)
	if not self.areaId then
		print_error("@sunwei08", self.id, "Has not AreaId", "Area Info", self.areaId, self.raidId, self.indoorId)
	end

	if self.areaId == areaId and self.localBoundId == localBoundId then
		return self:GetWorldPos()
	end

	local obRaidId, obIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
	local success, x, y, z = LX6.Gps.GpsAreaConnectMgr.LuaTryGetGpsAreaExitPosTo(obRaidId, obIndoorId, localBoundId, self.raidId, self.indoorId, self.localBoundId, nil, nil, nil)

	if not success then
		return nil
	end

	return Vector3.New(x, y, z)
end

function M:CbtClearWeakGuideInfo()
	gMapSystem.trace:UnregisterWeakGuide(self.instanceId)
end

function M:CbtSetWeakGuideInfo(range)
	gMapSystem.trace:RegisterWeakGuide(self.instanceId, range)
end

function M:ClearTraceInfo()
	if self.traceInfo then
		self:_SetDirty()
		gMapSystem.trace:RemoveTraceInfo(self.instanceId)

		self.traceInfo = nil
	end
end

function M:SetTraceInfo(traceType, layer, hideTraceEffect)
	self:SetTraceInfoV2(traceType, layer, layer, hideTraceEffect)
end

function M:SetTraceInfoV2(traceType, layerSelf, layerMask, hideTraceEffect)
	local layerSelf = layerSelf or 0
	local layerMask = layerMask or 0

	if not self.traceInfo then
		self.traceInfo = {
			traceType = traceType,
			layerSelf = layerSelf,
			layerMask = layerMask,
			hideTraceEffect = hideTraceEffect
		}
	else
		self.traceInfo.traceType = traceType
		self.traceInfo.layerSelf = layerSelf
		self.traceInfo.layerMask = layerMask
		self.traceInfo.hideTraceEffect = hideTraceEffect
	end

	gMapSystem.trace:UpdateTraceInfo(self.instanceId)
	self:_SetDirty()
end

function M:IsTracing()
	if self.traceInfo and gMapSystem.trace:IsTracing(self.instanceId) then
		return true
	else
		return false
	end
end

function M:HasTraceEffect()
	if not self.traceInfo or self.traceInfo.hideTraceEffect then
		return false
	else
		return self:IsTracing()
	end
end

function M:VisibleOnMap()
	return self:CheckViewMask(EMapViewMask.MiniMap + EMapViewMask.BigMap)
end

function M:IsVisible()
	return self._mRawData._visible
end

function M:SetVisible(visible)
	visible = not not visible

	if not self.mData._visible == not visible then
		return
	end

	self.mData._visible = visible

	for _, source in pairs(self._belongSources) do
		source:ElementVisibleChanged(self, visible)
	end
end

function M:GetAreaId()
	return self.areaId
end

function M:VisibleOn(observer)
	if not self._mRawData._visible then
		return false
	end

	return bit.band(self._viewMask, observer) > 0
end

function M:GetSubSystem()
	return gMapSystem.subSystems[self.subSystemType]
end

function M:SetActions(actions, blockReason)
	self.actions = actions
	self.actionsBlockReason = blockReason
end

function M:GetActionInfos()
	local actions, actionsBlockReason = self:GetSubSystem():GetActionInfo(self)

	if actions or actionsBlockReason then
		return actions, actionsBlockReason
	end

	return self:GetRawActions(), self.actionsBlockReason
end

function M:GetRawActions()
	if not self.actions then
		return {}
	end

	local state = self.traceInfo and gMapSystem_Element_State.Tracing or gMapSystem_Element_State.Normal

	if not self.actions[state] then
		return {}
	end

	return self.actions[state]
end

function M:OverrideMiniMapStartAnimNoAnim(tIndex)
	self:CheckMiniMapOverrideAnimTable(tIndex)

	self.fData.miniMapOverrideAnimInfo[tIndex].start = {
		noAnim = true
	}
end

function M:OverrideMiniMapLoopAnimNoAnim(tIndex)
	self:CheckMiniMapOverrideAnimTable(tIndex)

	self.fData.miniMapOverrideAnimInfo[tIndex].loop = {
		noAnim = true
	}
end

function M:OverrideMiniMapStartAnim(tIndex, name, timeBeforeLoopAnim)
	self:CheckMiniMapOverrideAnimTable(tIndex)

	self.fData.miniMapOverrideAnimInfo[tIndex].start = {
		noAnim = false,
		name = name,
		timeBeforeLoopAnim = timeBeforeLoopAnim or 5
	}
end

function M:OverrideMiniMapLoopAnim(tIndex, name, loopClip, playInterval)
	self:CheckMiniMapOverrideAnimTable(tIndex)

	self.fData.miniMapOverrideAnimInfo[tIndex].loop = {
		noAnim = false,
		name = name,
		loopClip = loopClip or false,
		playInterval = playInterval or 5
	}
end

function M:CheckMiniMapOverrideAnimTable(tIndex)
	if not self.fData.miniMapOverrideAnimInfo then
		self.fData.miniMapOverrideAnimInfo = {}
	end

	if not self.fData.miniMapOverrideAnimInfo[tIndex] then
		self.fData.miniMapOverrideAnimInfo[tIndex] = {}
	end
end

local ENEMY_VISION_RANGE_TINDEX = 3

function M:AddDetectRangeInfo(radius, angle, csUnit)
	self.miniMapData.miniMapTIndex = ENEMY_VISION_RANGE_TINDEX
	self.miniMapData.detectRangeInfo = {
		type = 0,
		radius = radius,
		angle = angle,
		unit = csUnit
	}
end

function M:AddDetectRangeVehicleInfo(csVehicle)
	self.miniMapData.miniMapTIndex = ENEMY_VISION_RANGE_TINDEX
	self.miniMapData.detectRangeInfo = {
		radius = 10,
		angle = 80,
		type = 1,
		vehicle = csVehicle
	}
end

function M:SetPreferredGateInfo(gBoundId, localGateId)
	self.gpsData.preferredGateInfo = {
		gBoundId = gBoundId,
		localGateId = localGateId
	}
end

function M:GetElementFilterId()
	if self.bigMapData.elementFilterId then
		return self.bigMapData.elementFilterId:GetFilterId()
	end

	print_error(self:GetName() .. " 未实现 ElementFilterId,返回默认值")

	return self.instanceId + 1000
end
