-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_CommonGps.lua
-- Decompiled from: 02308_MapSubSystem_CommonGps.lua_e0a20fd4af7e.luajit

MapSubSystem_CommonGps = DefClass("MapSubSystem_CommonGps", MapSubSystem_CommonGps, MapSubSystemBase)
local M = MapSubSystem_CommonGps

M.OnInit = function(self)
	self._staticGps = {}
	self._commonGps = {}
end

M.OnLoadData = function(self)
	self.ClearData(self)
end

M.OnLogin = function(self)
	self.ClearData(self)
end

M.OnLogout = function(self)
	self.ClearData(self)
end

M.ClearData = function(self)
	for _, element in pairs(self._staticGps) do
		element.Dispose(element)
	end

	table.clear(self._staticGps)

	for _, element in pairs(self._commonGps) do
		element.Dispose(element)
	end

	table.clear(self._commonGps)
end

M.AddStaticGps = function(self, id, raidId, worldPos, viewMask, iconInfo, visible, isTrace, disableVehicleNav)
	disableVehicleNav = disableVehicleNav or false
	local element = self._staticGps[id]

	if not element then
		element = MapElement.CreateLegacy(EMapElementType.CommonGps, id, EMapSubSystemType.CommonGps, viewMask, raidId)
		self._staticGps[id] = element
	end

	element.SetPosition(element, worldPos)
	element.SetVisible(element, visible)

	if isTrace then
		element.SetTraceInfo(element, EMapGTraceType.Other, 0)
	else
		element.ClearTraceInfo(element)
	end

	element.mData.name = iconInfo.name
	element.mData.sIconId = iconInfo.sIconId
	element.gpsData.disableVehicleNav = disableVehicleNav
end

M.RemoveStaticGps = function(self, id)
	local element = self._staticGps[id]

	if element then
		element.Dispose(element)

		self._staticGps[id] = nil
	end
end

M.TryAddCommonHudGps = function(self, id, raidId, worldPos, iconId)
	if not id or not raidId or not worldPos or not iconId then
		return false, nil
	end

	if self._commonGps[id] then
		return false, nil
	end

	local element = MapElement.CreateLegacy(EMapElementType.CommonGps, id, EMapSubSystemType.CommonGps, EMapViewMask.HudGps, raidId)

	element.SetPosition(element, worldPos)
	element.SetTraceInfo(element, EMapGTraceType.Other, 0)

	element.mData.sIconId = iconId

	element.SetVisible(element, true)

	self._commonGps[id] = element

	return true, element
end

M.TryAddCommonHudGpsByAgentPid = function(self, id, raidId, iconId, agentPid)
	if not id or not raidId or not iconId then
		return false, nil
	end

	if self._commonGps[id] then
		return false, nil
	end

	local element = MapElement.CreateLegacy(EMapElementType.CommonGps, id, EMapSubSystemType.CommonGps, EMapViewMask.HudGps, raidId)

	element.BindUnit(element, agentPid)
	element.SetTraceInfo(element, EMapGTraceType.Other, 0)

	element.mData.sIconId = iconId

	element.SetVisible(element, true)

	self._commonGps[id] = element

	return true, element
end

M.TryAddCommonHudGpsByVehiclePid = function(self, id, raidId, iconId, vehiclePid)
	if not id or not raidId or not iconId then
		return false, nil
	end

	if self._commonGps[id] then
		return false, nil
	end

	local element = MapElement.CreateLegacy(EMapElementType.CommonGps, id, EMapSubSystemType.CommonGps, EMapViewMask.HudGps, raidId)

	element.BindVehicle(element, vehiclePid)
	element.SetTraceInfo(element, EMapGTraceType.Other, 0)

	element.mData.sIconId = iconId

	element.SetVisible(element, true)

	self._commonGps[id] = element

	return true, element
end

M.RemoveCommonGps = function(self, id)
	if not id then
		return
	end

	local element = self._commonGps[id]

	if element then
		element.Dispose(element)

		self._commonGps[id] = nil
	end
end

M.CreateOrGetRawGps = function(self, gpsId, raidId)
	if self._commonGps[gpsId] then
		local element = self._commonGps[gpsId]

		if element.raidId == raidId then
			element.SetRaidId(element, raidId)
		end

		return element
	end

	local element = MapElement.CreateLegacy(EMapElementType.CommonGps, gpsId, EMapSubSystemType.CommonGps, EMapViewMask.HudGps, raidId)
	self._commonGps[gpsId] = element

	element.SetVisible(element, true)
	element.SetTraceInfo(element, EMapGTraceType.Other, 0)

	return element
end

return M
