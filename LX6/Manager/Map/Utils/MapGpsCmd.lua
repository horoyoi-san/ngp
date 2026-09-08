-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\MapGpsCmd.lua
-- Decompiled from: 00183_MapGpsCmd.lua_840a43c9804f.luajit

gMapGpsCmd = gMapGpsCmd or {}
local M = gMapGpsCmd

M.TryOpenBigMapAndFocusSelectFavorNpc = function(self, agentTag)
	local gpsId = gGpsTools.GetGpsId(EMapElementType.SpiritAcquisition, agentTag)
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if not element then
		return false
	end

	gMapUtils:PlayerOpenBigMap({
		autoSelectGpsId = gpsId
	})

	return true
end

M.TryTraceFavorNpcByActivityId = function(self, agentTag)
	local gpsId = gGpsTools.GetGpsId(EMapElementType.SpiritAcquisition, agentTag)
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if not element then
		return false
	end

	gMapSystem.trace:CommonTraceElement(gpsId)

	return true
end

M.CanFocusBigMapTask = function(self, taskId)
	local instanceId = gMapSubSystem_Task and gMapSubSystem_Task:GetGpsInstanceIdByTaskId(taskId)

	if not instanceId then
		return false, EMapViewStage.NotInStage
	end

	return gBigMapHelper:CanFocusBigMapElement(instanceId)
end
