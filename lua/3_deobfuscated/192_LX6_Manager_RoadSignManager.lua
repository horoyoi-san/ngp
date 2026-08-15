C_RoadSignManager = DefClass("C_RoadSignManager", C_RoadSignManager, nil)
local M = C_RoadSignManager
local RoadSign = LX6.RoadSign.RoadSign

function M:ctor()
	self.DbUrl = "http://10.220.31.20:8013/roadsign"
	self.UsermanagerUrl = "http://10.220.31.20:8003/usermanager"
end

function M:OpenRoadSignPanel(id)
	print_debug("OpenRoadSignPanel")
	gPanelManager:CheckShow(gPanelId.S_ROADSGIN_PANEL, id)
end

function M:PickImage(callback)
	LX6.RoadSign.RoadSignManager.PickImage(callback)
end

gRoadSignManager = gRoadSignManager or C_RoadSignManager.new()
