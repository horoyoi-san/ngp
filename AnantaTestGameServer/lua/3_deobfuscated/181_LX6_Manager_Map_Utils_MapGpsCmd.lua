gMapGpsCmd = gMapGpsCmd or {}
local M = gMapGpsCmd

function M:TryOpenBigMapAndFocusSelectFavorNpc(activityId)
	local gpsId = gGpsTools.GetGpsId(EMapElementType.SpiritAcquisition, activityId)
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if not element then
		return false
	end

	gMapUtils:PlayerOpenBigMap({
		autoSelectGpsId = gpsId
	})

	return true
end

function M:TryTraceFavorNpcByActivityId(activityId)
	local gpsId = gGpsTools.GetGpsId(EMapElementType.SpiritAcquisition, activityId)
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if not element then
		return false
	end

	gMapSystem.trace:CommonTraceElement(gpsId)

	return true
end
