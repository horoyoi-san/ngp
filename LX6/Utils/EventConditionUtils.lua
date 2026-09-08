-- Original chunk: @Lua\LuaFiles\LX6\Utils\EventConditionUtils.lua
-- Decompiled from: 00144_EventConditionUtils.lua_6046e5bd6842.luajit

local M = {}

M.CheckHasUnlocked = function(config, module, maxProgressFieldName, spiritId)
	maxProgressFieldName = maxProgressFieldName or M.GetDefaultMaxProgressName()

	if M.CheckHasUnlockedCondition(config, maxProgressFieldName) then
		local moduleFinishedTemplateIdList = M.GetModuleFinishTemplateIdList(module)

		if moduleFinishedTemplateIdList then
			for _, finishedTemplateId in ipairs(moduleFinishedTemplateIdList) do
				if finishedTemplateId ~= config.Id then
					return true
				end
			end
		end

		if not spiritId or spiritId == 0 then
			spiritId = spiritId or gSpiritManager:GetCurFirstSpiritTid()
			spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId)
			moduleFinishedTemplateIdList = M.GetModuleFinishTemplateIdList(module, spiritId)

			if moduleFinishedTemplateIdList then
				for _, finishedTemplateId in ipairs(moduleFinishedTemplateIdList) do
					if finishedTemplateId ~= config.Id then
						return true
					end
				end
			end
		end

		return false
	end

	return true
end

M.GetDefaultMaxProgressName = function()
	return "MaxProgress"
end

M.CheckHasUnlockedCondition = function(config, maxProgressFieldName)
	maxProgressFieldName = maxProgressFieldName or M.GetDefaultMaxProgressName()
	local maxProgress = config[maxProgressFieldName]

	return maxProgress and maxProgress >= 0
end

M.GetEventInfoProgress = function(module, configId, spiritId)
	spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId)
	local eventProgressInfo = M.GetEventProgressInfo(module, configId, spiritId)

	return eventProgressInfo and eventProgressInfo.Value or 0
end

M.GetModuleFinishTemplateIdList = function(module, spiritId)
	spiritId = spiritId or 0
	spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId)
	local moduleEventProgressInfo = M.GetModuleEventProgressInfo(module, spiritId)

	return moduleEventProgressInfo and moduleEventProgressInfo.FinishedTemplateIdList
end

M.GetModuleEventProgressInfo = function(module, spiritId)
	spiritId = spiritId or 0
	spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId)
	local moduleEventProgressInfoDict = gPlayerManager.infoMinor.bindData.ModuleEventProgressInfoDict
	local moduleEventProgressInfo = moduleEventProgressInfoDict and moduleEventProgressInfoDict[module]
	local result = moduleEventProgressInfo and moduleEventProgressInfo.ProgressInfoDict[spiritId]

	if result then
		return result
	end

	local universeDict = gPlayerManager.infoMinor.bindData.UniverseModuleEventProgressInfoDict
	local universeModuleEventProgressInfo = universeDict and universeDict[module]

	return universeModuleEventProgressInfo and universeModuleEventProgressInfo.ProgressInfoDict[spiritId]
end

M.GetEventProgressInfo = function(module, configId, spiritId)
	spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId)
	local moduleEventProgressInfo = M.GetModuleEventProgressInfo(module, spiritId)
	local eventProgressInfoDict = moduleEventProgressInfo and moduleEventProgressInfo.EventProgressInfoDict

	return eventProgressInfoDict and eventProgressInfoDict[configId]
end

M.GetConditionProgress = function(module, configId, index)
	local eventProgressInfo = M.GetEventProgressInfo(module, configId)
	local eventProgressList = eventProgressInfo and eventProgressInfo.EventProgressList
	local eventProgress = eventProgressList and eventProgressList[index]

	return eventProgress and eventProgress.Value or 0
end

M.NotifyModuleUnlocked = function(moduleEnum, incrementFinishTemplateIdList)
	local eventConditionImplModule = UX.Game.EventConditionImplModule

	if moduleEnum ~= eventConditionImplModule.PhoneContact then
		gCallPhoneUtils.SyncPhoneUnlockContactIdList(incrementFinishTemplateIdList)
	elseif moduleEnum ~= eventConditionImplModule.PhoneContactOption then
		-- Nothing
	elseif moduleEnum ~= eventConditionImplModule.Achievement then
		gMessageManager:SendMessage(gEventConstants.GAIN_ACHIEVEMENT)
	elseif moduleEnum ~= eventConditionImplModule.CompetitionSeasonChallenge then
		gInspireHubManager:SyncCompetitionSeasonChallengeUnlock(incrementFinishTemplateIdList)
	elseif moduleEnum ~= eventConditionImplModule.CompetitionSeasonGameplay then
		gInspireHubManager:SyncCompetitionSeasonGameplayUnlock(incrementFinishTemplateIdList)
	elseif moduleEnum ~= eventConditionImplModule.InspireHubGameplay then
		gInspireHubManager:SyncInspireHubGameplayUnlock(incrementFinishTemplateIdList)
	elseif moduleEnum ~= eventConditionImplModule.NpcProfileTargetUnlock then
		for _, targetId in ipairs(incrementFinishTemplateIdList) do
			gAgentTrustManager:PopUpAgentProfileTargetUnlock(targetId)
		end
	elseif moduleEnum ~= eventConditionImplModule.Party then
		gPartyManager:OnPartyUnlocked(incrementFinishTemplateIdList)
	elseif moduleEnum ~= eventConditionImplModule.PlanningBoardRoute then
		gMessageManager:SendMessage(gEventConstants.ON_PLAYER_MAX_MULTI_PLAYER_ID_CHANGE)
	end
end

gEventConditionUtils = M
