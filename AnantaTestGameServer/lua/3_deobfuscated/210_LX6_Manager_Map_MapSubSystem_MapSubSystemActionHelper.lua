gMapSubSystemActionHelper = {}
local M = gMapSubSystemActionHelper

function M.TryExecuteTraceAction(element, action)
	if action == gMapSystemElementAction.Trace then
		M.Trace(element)

		return true
	elseif action == gMapSystemElementAction.Untrace then
		M.Untrace(element)

		return true
	else
		return false
	end
end

function M.Trace(element)
	if gAgentTrustManager.openMapFromAgentProfile then
		gAgentTrustManager.openMapFromAgentProfile = false

		gPanelManager:Close(gPanelId.NEW_AGENT_PROFILE_PANEL)
	end

	gMapSystem.trace:RemoveMainTrace()
	gMapSystem.trace:SetMainTraceGpsId(element.gpsId)
	gGpsManager:AddGPS({
		HasTargetEffect = true,
		GpsType = gTaskGpsType.Trace,
		InstanceId = element.gpsId,
		TargetPos = element:GetWorldPos(),
		IndoorId = element.indoorId,
		AutoRemoveGpsInDistance = element.gpsData.removeGpsRange,
		AutoHideDistance = element.gpsData.hideGpsRange,
		RaidId = element.raidId,
		IconId = element.mData.iconId,
		IsBossTrace = element.type == EMapElementType.Boss,
		EffectId = element.gpsData.effectId or 53610322,
		EffectShowDistance = LTConfig.GameConfig.TraceLightDisappearRange,
		traceEffectType = gGpsTools.GetEffectType(element.type)
	})
end

function M.Untrace(element)
	if gMapSystem.trace.mainTraceGpsId == element.gpsId then
		gMapSystem.trace:RemoveMainTrace()

		gClientToGameDelegate:AskRemoveTraceGps().Callback = function (err, data)
			if err == LTConfig.MessageConfig.Ok then
				-- Nothing
			end
		end
	end
end

return M
