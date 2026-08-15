MapSubSystem_CommonGps = DefClass("MapSubSystem_CommonGps", MapSubSystem_CommonGps, MapSubSystemBase)
local M = MapSubSystem_CommonGps

function M:OnInit()
	self._staticGps = {}
	self._commonGps = {}
end

function M:OnLoadData()
	self:ClearData()
end

function M:OnLogin()
	self:ClearData()
end

function M:OnLogout()
	self:ClearData()
end

function M:ClearData()
	for _, element in pairs(self._staticGps) do
		element:Dispose()
	end

	table.clear(self._staticGps)

	for _, element in pairs(self._commonGps) do
		element:Dispose()
	end

	table.clear(self._commonGps)
end

function M:AddStaticGps(id, raidId, worldPos, viewMask, iconInfo, visible, isTrace, disableVehicleNav)
	disableVehicleNav = disableVehicleNav or false
	local element = self._staticGps[id]

	if not element then
		element = MapElement.CreateLegacy(EMapElementType.CommonGps, id, EMapSubSystemType.CommonGps, viewMask, raidId)
		self._staticGps[id] = element
	end

	element:SetPosition(worldPos)
	element:SetVisible(visible)

	if isTrace then
		element:SetTraceInfo(EMapGTraceType.Other, 0)
	else
		element:ClearTraceInfo()
	end

	element.mData.name = iconInfo.name
	element.mData.sIconId = iconInfo.sIconId
	element.gpsData.disableVehicleNav = disableVehicleNav
end

function M:RemoveStaticGps(id)
	local element = self._staticGps[id]

	if element then
		element:Dispose()

		self._staticGps[id] = nil
	end
end

function M:TryAddCommonHudGps(id, raidId, worldPos, iconId)
	if not id or not raidId or not worldPos or not iconId then
		return false, nil
	end

	if self._commonGps[id] then
		return false, nil
	end

	local element = MapElement.CreateLegacy(EMapElementType.CommonGps, id, EMapSubSystemType.CommonGps, EMapViewMask.HudGps, raidId)

	element:SetPosition(worldPos)
	element:SetTraceInfo(EMapGTraceType.Other, 0)

	element.mData.sIconId = iconId

	element:SetVisible(true)

	self._commonGps[id] = element

	return true, element
end

function M:TryAddCommonHudGpsByAgentPid(id, raidId, iconId, agentPid)
	if not id or not raidId or not iconId then
		return false, nil
	end

	if self._commonGps[id] then
		return false, nil
	end

	local element = MapElement.CreateLegacy(EMapElementType.CommonGps, id, EMapSubSystemType.CommonGps, EMapViewMask.HudGps, raidId)

	element:BindUnit(agentPid)
	element:SetTraceInfo(EMapGTraceType.Other, 0)

	element.mData.sIconId = iconId

	element:SetVisible(true)

	self._commonGps[id] = element

	return true, element
end

function M:TryAddCommonHudGpsByVehiclePid(id, raidId, iconId, vehiclePid)
	if not id or not raidId or not iconId then
		return false, nil
	end

	if self._commonGps[id] then
		return false, nil
	end

	local element = MapElement.CreateLegacy(EMapElementType.CommonGps, id, EMapSubSystemType.CommonGps, EMapViewMask.HudGps, raidId)

	element:BindVehicle(vehiclePid)
	element:SetTraceInfo(EMapGTraceType.Other, 0)

	element.mData.sIconId = iconId

	element:SetVisible(true)

	self._commonGps[id] = element

	return true, element
end

function M:RemoveCommonGps(id)
	if not id then
		return
	end

	local element = self._commonGps[id]

	if element then
		element:Dispose()

		self._commonGps[id] = nil
	end
end

function M:CreateOrGetRawGps(gpsId, raidId)
	if self._commonGps[gpsId] then
		local element = self._commonGps[gpsId]

		if element.raidId ~= raidId then
			element:SetRaidId(raidId)
		end

		return element
	end

	local element = MapElement.CreateLegacy(EMapElementType.CommonGps, gpsId, EMapSubSystemType.CommonGps, EMapViewMask.HudGps, raidId)
	self._commonGps[gpsId] = element

	element:SetVisible(true)
	element:SetTraceInfo(EMapGTraceType.Other, 0)

	return element
end

return M
