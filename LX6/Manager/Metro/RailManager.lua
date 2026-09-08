-- Original chunk: @Lua\LuaFiles\LX6\Manager\Metro\RailManager.lua
-- Decompiled from: 00519_RailManager.lua_3f6ec2adc0e1.luajit

C_RailManager = DefClass("C_RailManager", C_RailManager)
local M = C_RailManager

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.METRO_BOARD_INFO_CHANGE, self.OnMetroBoardInfoChange)
end

M.OnMetroBoardInfoChange = function(eventId, metroId)
	gStoreManager:GetStoreGroup("RailwayLCDPanelStore"):OnMetroBoardInfoChange(metroId)
end

gRailManager = gRailManager or C_RailManager.new()
