-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_CarRace.lua
-- Decompiled from: 02341_MapSubSystem_CarRace.lua_4ec84781852f.luajit

MapSubSystem_Race = DefClass("MapSubSystem_Race", MapSubSystem_Race, MapSubSystemBase)
local M = MapSubSystem_Race

M.OnInit = function(self)
	self.items = {}
end

M.OnSceneInit = function(self)
	self.ClearAll(self)
end

M.OnSceneDestroy = function(self)
	self.ClearAll(self)
end

M.ClearAll = function(self)
	for _, item in pairs(self.items) do
		item.Dispose(item)
	end

	table.clear(self.items)
end

M.OnCarRaceStart = function(self)
	self:ClearAll()

	local vehicleAIIds = L50.Spoon.CarRaceManager.Instance:GetAllVehicleAIIds()

	if vehicleAIIds and vehicleAIIds.Length then
		for i = 0, vehicleAIIds.Length - 1 do
			local vehicleId = vehicleAIIds[i]
			local idStr = ulong.tostring(vehicleId)
			local element = MapElement.CreateLegacy(EMapElementType.CarRace, idStr, EMapSubSystemType.CarRace, EMapViewMask.MiniMap, gMapSystem.lastRaidId or 0)
			element.miniMapData.miniMapTIndex = 4
			element.mData.playerNumber = ""
			element.mData.tintColor = "5967FF"

			element:SetVisible(true)
			element:BindVehicle(vehicleId)

			self.items[idStr] = element
		end
	end
end

M.OnCarRaceEnd = function(self)
	self.ClearAll(self)
end

M.ExecuteAction = function(self, element, action, ctx)
	gMapSubSystemActionHelper.TryExecuteTraceAction(element, action)
end

return M
