-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapArea.lua
-- Decompiled from: 00190_MapArea.lua_13a17dc3f66b.luajit

MapArea = DefClass("MapArea", MapArea)
local M = MapArea

M.ctor = function(self, raidId, indoorId)
	self.raidId = raidId or 0
	self.indoorId = indoorId or 0
	self.id = gMapSystem.area:RawGetAreaId(self.raidId, self.indoorId)
	self._subBounds = {}
end
