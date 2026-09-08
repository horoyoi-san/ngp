-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapElement.lua
-- Decompiled from: 00188_MapElement.lua_5a56ac2698d4.luajit

local CSGpsContainer = LX6.Gps.GpsContainer
local bit = require("bit")

if false then
	require("LX6/Manager/Map/MapElementDef")
end

gMapSystem_Element_State = {
	["\\xed\\xc9*\\xf6"] = 2,
	["2G\\x83\\x83\\x82M"] = 1
}
MapElement = MapElement or {}
local M = MapElement
M.__index = M
M._static_instanceIdCount = 1
M._static_ePool = {}

M.CreateLegacy = function(type, id, subSystemType, viewMask, raidId)
	local gpsId = gGpsTools.GetGpsId(type, id)
	local instanceId = M._static_instanceIdCount
	M._static_instanceIdCount = instanceId + 1
	local e = nil
	local poolSize = #M._static_ePool

	if poolSize <= 0 then
		e = M._static_ePool[poolSize]
		M._static_ePool[poolSize] = nil
	else
		e = setmetatable({}, M)
		e.gpsData = {}
		e.fData = {}
		e._mRawData = {
			["\\x94\\xa7\\xb8c<\\xf26"] = false
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
			["\\xd7"] = 0,
			["\\xd5"] = 0,
			["\\xd4"] = 0
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

M.Dispose = function(self)
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

M._Recycle = function(self)
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

M.SetPositionXYZ = function(self, x, y, z)
	if self.isDestroyed then
		print_warn("[MapElement] [xuqiang05] SetPositionXYZ when MapElement is destroyed! gpsId=", self.gpsId)

		return
	end

	CSGpsContainer.SetBasePosition(self.instanceId, x, y, z)
end

M.SetPosition = function(self, worldPos)
	if not worldPos then
		return
	end

	if self.isDestroyed then
		print_warn("[MapElement] [xuqiang05] SetPosition when MapElement is destroyed! gpsId=", self.gpsId)

		return
	end

	CSGpsContainer.SetBasePosition(self.instanceId, worldPos.x, worldPos.y, worldPos.z)
end

M.SetSyncTrackPos = function(self, worldPos)
	if not worldPos then
		return
	end

	self.gpsData.trackPos = worldPos
end

M.SetRelocatedPosition = function(self, relocatedPos)
	self._relocatedPos = relocatedPos

	self:_SetDirty()
end

M.HasRelocatedPosition = function(self)
	return self._relocatedPos == nil
end

M.SetBindingPos = function(self, bindingPos)
end

M.SetRaidId = function(self, raidId)
	if self.raidId ~= raidId then
		return
	end

	self.raidId = raidId

	gCS.GpsContainer.SetRaidId(self.instanceId, raidId)
end

M.SetOverrideBoundInfo = function(self, indoorId, localBoundId)
	self.overrideIndoorId = indoorId
	self.overrideLocalBoundId = localBoundId
	self.indoorId = indoorId or 0
	self.localBoundId = localBoundId or 0

	self:UpdateGBoundId()
end

M.SetBoundInfo = function(self, indoorId, localBoundId)
	self.indoorId = self.overrideIndoorId or indoorId
	self.localBoundId = self.overrideLocalBoundId or localBoundId

	self:UpdateGBoundId()

	if self.onBoundChanged then
		self.onBoundChanged(indoorId, localBoundId)
	end
end

M.UpdateGBoundId = function(self)
	local indoorId = self.indoorId or 0
	local localBoundId = self.localBoundId or 0
	local newGBoundId = gMapAreaMgr:GetGBoundId(self.raidId, indoorId, localBoundId)

	self:TransportByGBoundId(newGBoundId)
end

M.IncViewCount = function(self)
	self._viewCounter = self._viewCounter + 1

	if self._viewCounter ~= 1 then
		-- Nothing
	end
end

M.DecViewCount = function(self)
	if self._viewCounter <= 0 then
		self._viewCounter = self._viewCounter - 1

		if self._viewCounter ~= 0 then
			-- Nothing
		end
	end
end

M.TransportByGBoundId = function(self, newGBoundId)
	if self.gBoundId ~= newGBoundId then
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

M.BindAgentTag = function(self, agentTag)
	CSGpsContainer.BindAgentTag(self.instanceId, agentTag)
	gGpsBindingMgr:AddAgentTagBinding(self.instanceId, agentTag)
end

M.BindUnit = function(self, unitId, useFeisuoPoint, onlyBindGpsMgr)
	if not unitId or unitId ~= 0 then
		return
	end

	if ulong.check(unitId) then
		if onlyBindGpsMgr then
			gGpsBindingMgr:AddUnitBinding(self.instanceId, unitId)

			return
		end

		CSGpsContainer.BindUnit(self.instanceId, false, 0, unitId, useFeisuoPoint)
		gGpsBindingMgr:AddUnitBinding(self.instanceId, unitId)
	else
		if onlyBindGpsMgr then
			gGpsBindingMgr:AddSpoonUnitBinding(self.instanceId, unitId)

			return
		end

		CSGpsContainer.BindUnit(self.instanceId, true, unitId, 0, useFeisuoPoint)
		gGpsBindingMgr:AddSpoonUnitBinding(self.instanceId, unitId)
	end
end

M.BindDestructible = function(self, destructibleInstanceId)
	CSGpsContainer.BindDestructible(self.instanceId, destructibleInstanceId)
	gGpsBindingMgr:AddDestructibleBinding(self.instanceId, destructibleInstanceId)
end

M.BindVehicle = function(self, vehicleId, vehiclePartNodeName, gpsOffsetY, needEuler, isSpoonId)
	if not ulong.check(vehicleId) then
		CSGpsContainer.BindVehicle(self.instanceId, true, vehicleId, 0, vehiclePartNodeName, needEuler)
		gGpsBindingMgr:AddSpoonVehicleBinding(self.instanceId, vehicleId)
	else
		CSGpsContainer.BindVehicle(self.instanceId, false, 0, vehicleId, vehiclePartNodeName, needEuler)
		gGpsBindingMgr:AddVehicleBinding(self.instanceId, vehicleId)
	end
end

M.BindSlotInfo = function(self, slotPid, slotRefId, slotRefName)
	CSGpsContainer.BindSlot(self.instanceId, slotPid, slotRefId or 0, slotRefName)
	gGpsBindingMgr:AddSlotBinding(self.instanceId, slotPid, slotRefId, slotRefName)
end

M.ClearBinding = function(self)
	CSGpsContainer.Unbind(self.instanceId)
	gGpsBindingMgr:RemoveGpsInst(self.instanceId)
end

M.GetName = function(self)
	local overrideName = self.mData.name

	if overrideName then
		return overrideName
	end

	local lName = self.mData.lName

	return lName and lName:GetText() or ""
end

M._SetDirty = function(self)
	gMapSystem.container:MarkElementAsDirty(self.instanceId)
end

M.SyncViewMaskChange = function(self, oldViewMask, newViewMask)
end

M.SetViewMask = function(self, viewMask)
	if viewMask ~= nil then
		print_warn("[MapElement]: SetViewMask nil")

		return
	end

	if self._viewMask ~= viewMask then
		return
	end

	local oldViewMask = self._viewMask
	self._viewMask = viewMask

	for _, source in pairs(self._belongSources) do
		source:ElementViewMaskChanged(self, oldViewMask, viewMask)
	end
end

M.AddViewMask = function(self, viewmask)
	self:SetViewMask(bit.bor(self._viewMask, viewmask))
end

M.RemoveViewMask = function(self, viewMask)
	self:SetViewMask(self._viewMask - bit.band(self._viewMask, viewMask))
end

M.CheckViewMask = function(self, viewMask)
	return bit.band(self._viewMask, viewMask) == 0
end

M.GetWorldPos = function(self, result)
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

M.GetOriginWorldPos = function(self, result)
	if not result then
		result = Vector3.New(self._resolvedPos.x, self._resolvedPos.y, self._resolvedPos.z)
	else
		result.x = self._resolvedPos.x
		result.y = self._resolvedPos.y
		result.z = self._resolvedPos.z
	end

	return result
end

M.GetObservedPosFrom = function(self, areaId, useOriginPos)
	if not self.areaId then
		print_warn("@sunwei08: SubSystemType: " .. (self.subSystemType or "nil"), "InstanceId: " .. self.instanceId, "Id: " .. (self.id or "nil"), "Has not AreaId", "Area Info", self.areaId, self.raidId, self.indoorId)

		return nil
	end

	if self.areaId ~= areaId then
		if useOriginPos then
			return self:GetOriginWorldPos()
		else
			return self:GetWorldPos()
		end
	end

	local obRaidId, obIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
	local success, x, y, z = LX6.Gps.GpsAreaConnectMgr.LuaTryGetMapAreaExitPosTo(obRaidId, obIndoorId, self.raidId, self.indoorId, nil, , )

	if not success then
		return nil
	end

	return Vector3.New(x, y, z)
end

M.GetObservedGpsAreaPosFrom = function(self, areaId, localBoundId)
	if not self.areaId then
		print_error("@sunwei08", self.id, "Has not AreaId", "Area Info", self.areaId, self.raidId, self.indoorId)
	end

	if self.areaId ~= areaId and self.localBoundId ~= localBoundId then
		return self:GetWorldPos()
	end

	local obRaidId, obIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
	local success, x, y, z = LX6.Gps.GpsAreaConnectMgr.LuaTryGetGpsAreaExitPosTo(obRaidId, obIndoorId, localBoundId, self.raidId, self.indoorId, self.localBoundId, nil, , )

	if not success then
		return nil
	end

	return Vector3.New(x, y, z)
end

M.CbtClearWeakGuideInfo = function(self)
	gMapSystem.trace:UnregisterWeakGuide(self.instanceId)
end

M.CbtSetWeakGuideInfo = function(self, range)
	gMapSystem.trace:RegisterWeakGuide(self.instanceId, range)
end

M.ClearTraceInfo = function(self)
	if self.traceInfo then
		self:_SetDirty()
		gMapSystem.trace:RemoveTraceInfo(self.instanceId)

		self.traceInfo = nil
		local subSystem = gMapSystem.subSystems[self.subSystemType]

		subSystem:OnClearTrace(self)
	end
end

M.SetTraceInfo = function(self, traceType, layer, hideTraceEffect)
	self:SetTraceInfoV2(traceType, layer, layer, hideTraceEffect)
end

M.SetTraceInfoV2 = function(self, traceType, layerSelf, layerMask, hideTraceEffect)
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

M.SetMainTrace = function(self)
	if gAgentTrustManager.openMapFromAgentProfile then
		gAgentTrustManager.openMapFromAgentProfile = false

		gPanelManager:Close(gPanelId.NEW_AGENT_PROFILE_PANEL)
	end

	gMapSystem.trace:RemoveMainTrace(true)
	gMapSystem.trace:SetMainTraceGpsId(self.gpsId)
	self:AskStartGuide()
end

M.ClearMainTrace = function(self)
	if gMapSystem.trace.mainTraceGpsId ~= self.gpsId then
		gMapSystem.trace:RemoveMainTrace()
	end
end

M.AskStartGuide = function(self)
	local tagType, value = nil

	if self.type ~= EMapElementType.Compound then
		tagType = LTConfig.GuideGuideGroupConfig.TagType.IndoorGps
		value = self.id
	elseif self.type ~= EMapElementType.LinkGameplay then
		tagType = LTConfig.GuideGuideGroupConfig.TagType.LinkGps
		value = self.id
	end

	if tagType then
		gClientToGameDelegate:AskStartGuideByCondition(tagType, value, 0).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				print_notice("[GpsTraceGuide] xuqiang05 AskStartGuideByCondition failed error number:", err)

				return
			end
		end
	end
end

M.SetOnlineTrace = function(self, pid)
	if not self.mData.onlineTrace then
		self.mData.onlineTrace = {
			pid
		}
	else
		for _, tracePId in pairs(self.mData.onlineTrace) do
			if tracePId ~= pid then
				return
			end
		end

		table.insert(self.mData.onlineTrace, pid)
	end

	self:_SetDirty()
end

M.RemoveOnlineTrace = function(self, pid)
	if self.mData.onlineTrace then
		for i, tracePId in pairs(self.mData.onlineTrace) do
			if tracePId ~= pid then
				table.remove(self.mData.onlineTrace, i)

				return
			end
		end
	end
end

M.IsTracing = function(self)
	if self.traceInfo and gMapSystem.trace:IsTracing(self.instanceId) then
		return true
	else
		return false
	end
end

M.HasTraceEffect = function(self)
	if not self.traceInfo or self.traceInfo.hideTraceEffect then
		return false
	else
		return self:IsTracing()
	end
end

M.VisibleOnMap = function(self)
	return self:CheckViewMask(EMapViewMask.MiniMap + EMapViewMask.BigMap)
end

M.IsVisible = function(self)
	return self._mRawData._visible
end

M.SetVisible = function(self, visible)
	visible = not not visible

	if not self.mData._visible ~= not visible then
		return
	end

	self.mData._visible = visible

	for _, source in pairs(self._belongSources) do
		source:ElementVisibleChanged(self, visible)
	end
end

M.GetAreaId = function(self)
	return self.areaId
end

M.VisibleOn = function(self, observer)
	if not self._mRawData._visible then
		return false
	end

	return bit.band(self._viewMask, observer) >= 0
end

M.GetSubSystem = function(self)
	return gMapSystem.subSystems[self.subSystemType]
end

M.SetActions = function(self, actions, blockReason)
	self.actions = actions
	self.actionsBlockReason = blockReason
end

M.GetActionInfos = function(self)
	local actions, actionsBlockReason = self:GetSubSystem():GetActionInfo(self)

	if actions or actionsBlockReason then
		return actions, actionsBlockReason
	end

	return self:GetRawActions(), self.actionsBlockReason
end

M.GetRawActions = function(self)
	if not self.actions then
		return {}
	end

	local state = self.traceInfo and gMapSystem_Element_State.Tracing or gMapSystem_Element_State.Normal

	if not self.actions[state] then
		return {}
	end

	return self.actions[state]
end

M.OverrideMiniMapStartAnimNoAnim = function(self, tIndex)
	self:CheckMiniMapOverrideAnimTable(tIndex)

	self.fData.miniMapOverrideAnimInfo[tIndex].start = {
		["G\\xb0\\x80\\x8aL"] = true
	}
end

M.OverrideMiniMapLoopAnimNoAnim = function(self, tIndex)
	self:CheckMiniMapOverrideAnimTable(tIndex)

	self.fData.miniMapOverrideAnimInfo[tIndex].loop = {
		["G\\xb0\\x80\\x8aL"] = true
	}
end

M.OverrideMiniMapStartAnim = function(self, tIndex, name, timeBeforeLoopAnim)
	self:CheckMiniMapOverrideAnimTable(tIndex)

	self.fData.miniMapOverrideAnimInfo[tIndex].start = {
		["G\\xb0\\x80\\x8aL"] = false,
		name = name,
		timeBeforeLoopAnim = timeBeforeLoopAnim or 5
	}
end

M.OverrideMiniMapLoopAnim = function(self, tIndex, name, loopClip, playInterval)
	self:CheckMiniMapOverrideAnimTable(tIndex)

	self.fData.miniMapOverrideAnimInfo[tIndex].loop = {
		["G\\xb0\\x80\\x8aL"] = false,
		name = name,
		loopClip = loopClip or false,
		playInterval = playInterval or 5
	}
end

M.CheckMiniMapOverrideAnimTable = function(self, tIndex)
	if not self.fData.miniMapOverrideAnimInfo then
		self.fData.miniMapOverrideAnimInfo = {}
	end

	if not self.fData.miniMapOverrideAnimInfo[tIndex] then
		self.fData.miniMapOverrideAnimInfo[tIndex] = {}
	end
end

local ENEMY_VISION_RANGE_TINDEX = 3

M.AddDetectRangeInfo = function(self, radius, angle, pid)
	self.miniMapData.miniMapTIndex = ENEMY_VISION_RANGE_TINDEX
	self.miniMapData.detectRangeInfo = {
		["n;m^"] = 0,
		radius = radius,
		angle = angle,
		pid = pid
	}
end

M.AddDetectRangeVehicleInfo = function(self, csVehicle)
	self.miniMapData.miniMapTIndex = ENEMY_VISION_RANGE_TINDEX
	self.miniMapData.detectRangeInfo = {
		["I\\x95\\x87\\x96R"] = 10,
		["L\\xa0\\xa5\\xa3\\xb3"] = 80,
		["n;m^"] = 1,
		vehicle = csVehicle
	}
end

M.SetPreferredGateInfo = function(self, gBoundId, localGateId)
	self.gpsData.preferredGateInfo = {
		gBoundId = gBoundId,
		localGateId = localGateId
	}
end

M.GetElementFilterId = function(self)
	if self.bigMapData.elementFilterId then
		return self.bigMapData.elementFilterId:GetFilterId()
	end

	print_error(self:GetName() .. " 未实现 ElementFilterId,返回默认值")

	return self.instanceId + 1000
end

dofile("LX6/Manager/Map/MapElement_Property")
