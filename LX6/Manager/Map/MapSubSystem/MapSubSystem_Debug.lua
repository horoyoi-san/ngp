-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Debug.lua
-- Decompiled from: 02310_MapSubSystem_Debug.lua_3c331347ebc3.luajit

MapSubSystem_Debug = DefClass("MapSubSystem_Debug", MapSubSystem_Debug, MapSubSystemBase)
local M = MapSubSystem_Debug

M.OnInit = function(self)
	self.icons = {
		28000036,
		28000037,
		28000038,
		28000039,
		28000040,
		28000041,
		28000042,
		28000043
	}
	self.debugElements = {}
	self.idCounter = {}
end

M.AddElement = function(self, id, raidId, worldPos)
	if self.debugElements[id] then
		self.debugElements[id]:Dispose()

		self.debugElements[id] = nil
	end

	worldPos.y = 1

	print_debug("Debug Add Gps Point ", worldPos.x, worldPos.y, worldPos.z)

	local element = MapElement.CreateLegacy(EMapElementType.Debug, id, EMapSubSystemType.Debug, EMapViewMask.AllSgui, raidId, 0)

	element.SetPosition(element, worldPos)

	element.mData.sIconId = self.PopulateIcon(self)
	element.mData.name = element.gpsId

	element.SetVisible(element, true)
	element.SetTraceInfo(element, EMapGTraceType.Debug)

	self.debugElements[id] = element

	return element
end

M.Get = function(self, id)
	return self.debugElements[id]
end

M.RemoveAll = function(self)
	for _, element in pairs(self.debugElements) do
		element.Dispose(element)
	end

	self.debugElements = {}
end

M.PopulateIcon = function(self)
	local iconId = self.icons[math.random(1, #self.icons)]

	return iconId
end

M.SGetTooltipInfo = function(self, id, element)
	return nil
end

return M
