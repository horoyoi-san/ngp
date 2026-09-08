-- Original chunk: @Lua\LuaFiles\LX6\Manager\RoadSignManager.lua
-- Decompiled from: 00556_RoadSignManager.lua_9816b4e9dc53.luajit

C_RoadSignManager = DefClass("C_RoadSignManager", C_RoadSignManager, nil)
local M = C_RoadSignManager
local RoadSign = LX6.RoadSign.RoadSign

M.ctor = function(self)
	self.DbUrl = "http://10.220.31.20:8013/roadsign"
	self.UsermanagerUrl = "http://10.220.31.20:8003/usermanager"
end

M.OpenRoadSignPanel = function(self, id)
	print_debug("OpenRoadSignPanel")
	gPanelManager:CheckShow(gPanelId.S_ROADSGIN_PANEL, id)
end

M.PickImage = function(self, callback)
	LX6.RoadSign.RoadSignManager.PickImage(callback)
end

gRoadSignManager = gRoadSignManager or C_RoadSignManager.new()
