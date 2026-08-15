MapArea = DefClass("MapArea", MapArea)
local M = MapArea

function M:ctor(raidId, indoorId)
	self.raidId = raidId or 0
	self.indoorId = indoorId or 0
	self.id = gMapSystem.area:RawGetAreaId(self.raidId, self.indoorId)
	self._subBounds = {}
end
