C_RailManager = DefClass("C_RailManager", C_RailManager)
local M = C_RailManager

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.METRO_BOARD_INFO_CHANGE, self.OnMetroBoardInfoChange)
end

function M.OnMetroBoardInfoChange(eventId, metroId)
	gStoreManager:GetStoreGroup("RailwayLCDPanelStore"):OnMetroBoardInfoChange(metroId)
end

gRailManager = gRailManager or C_RailManager.new()
