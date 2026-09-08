-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Rowboat.lua
-- Decompiled from: 02314_MapSubSystem_Rowboat.lua_977274f12cb2.luajit

local MapSubSystem_Rowboat = DefClass("MapSubSystem_Rowboat", MapSubSystem_Rowboat, MapSubSystemBase)
local M = MapSubSystem_Rowboat

M.OnInit = function(self)
	self.items = {}
end

M.OnLogin = function(self)
end

M.OnLogout = function(self)
	self.ClearAll(self)
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

M.RemoveRowboatPoint = function(self, id)
	if self.items[id] then
		self.items[id]:Dispose()

		self.items[id] = nil
	end
end

M.StartRowBoat = function(self, posList)
	self.ClearAll(self)

	for id, hasPlayed in pairs(posList) do
		if hasPlayed then
			-- Nothing
		else
			local cfg = LTConfig.RowboatSightConfig.GetConfig(id)

			if cfg then
				local element = MapElement.CreateLegacy(EMapElementType.Rowboat, id, EMapSubSystemType.Rowboat, EMapViewMask.MiniMap + EMapViewMask.HudGps, gMapSystem.lastRaidId)
				element.miniMapData.iconId = cfg.SMiniMapIconId or 0
				element.gpsData.tmp_HudAutoShowDistance = cfg.PhotoDistance or 10
				local pos = Vector3.New(cfg.SightPosition.X, cfg.SightPosition.Y, cfg.SightPosition.Z)

				element:SetPosition(pos)
				element:SetVisible(true)

				self.items[id] = element
			end
		end
	end
end

M.EndRowBoat = function(self)
	self.ClearAll(self)
end

M.SetRowBoatDone = function(self, id)
	self.RemoveRowboatPoint(self, id)
end

return M
