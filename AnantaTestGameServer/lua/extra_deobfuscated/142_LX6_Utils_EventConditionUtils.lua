local M = {}

function M.CheckHasUnlocked(config, module, maxProgressFieldName, spiritId)
	maxProgressFieldName = maxProgressFieldName or M.GetDefaultMaxProgressName()

	if M.CheckHasUnlockedCondition(config, maxProgressFieldName) then
		local moduleFinishedTemplateIdList = M.GetModuleFinishTemplateIdList(module)

		if moduleFinishedTemplateIdList then
			for _, finishedTemplateId in ipairs(moduleFinishedTemplateIdList) do
				if finishedTemplateId == config.Id then
					return true
				end
			end
		end

		if not spiritId or spiritId ~= 0 then
			spiritId = spiritId or gSpiritManager:GetCurFirstSpiritTid()
			moduleFinishedTemplateIdList = M.GetModuleFinishTemplateIdList(module, spiritId)

			if moduleFinishedTemplateIdList then
				for _, finishedTemplateId in ipairs(moduleFinishedTemplateIdList) do
					if finishedTemplateId == config.Id then
						return true
					end
				end
			end
		end

		return false
	end

	return true
end

function M.GetDefaultMaxProgressName()
	return "MaxProgress"
end

function M.CheckHasUnlockedCondition(config, maxProgressFieldName)
	maxProgressFieldName = maxProgressFieldName or M.GetDefaultMaxProgressName()
	local maxProgress = config[maxProgressFieldName]

	return maxProgress and maxProgress > 0
end

function M.GetEventInfoProgress(module, configId, spiritId)
	local eventProgressInfo = M.GetEventProgressInfo(module, configId, spiritId)

	return eventProgressInfo and eventProgressInfo.Value or 0
end

function M.GetModuleFinishTemplateIdList(module, spiritId)
	spiritId = spiritId or 0
	local moduleEventProgressInfo = M.GetModuleEventProgressInfo(module, spiritId)

	return moduleEventProgressInfo and moduleEventProgressInfo.FinishedTemplateIdList
end

function M.GetModuleEventProgressInfo(module, spiritId)
	spiritId = spiritId or 0
	local moduleEventProgressInfoDict = gPlayerManager.infoMinor.bindData.ModuleEventProgressInfoDict
	local moduleEventProgressInfo = moduleEventProgressInfoDict and moduleEventProgressInfoDict[module]

	return moduleEventProgressInfo and moduleEventProgressInfo.ProgressInfoDict[spiritId]
end

function M.GetEventProgressInfo(module, configId, spiritId)
	local moduleEventProgressInfo = M.GetModuleEventProgressInfo(module, spiritId)
	local eventProgressInfoDict = moduleEventProgressInfo and moduleEventProgressInfo.EventProgressInfoDict

	return eventProgressInfoDict and eventProgressInfoDict[configId]
end

function M.GetConditionProgress(module, configId, index)
	local eventProgressInfo = M.GetEventProgressInfo(module, configId)
	local eventProgressList = eventProgressInfo and eventProgressInfo.EventProgressList
	local eventProgress = eventProgressList and eventProgressList[index]

	return eventProgress and eventProgress.Value or 0
end

function M.NotifyModuleUnlocked(moduleEnum, incrementFinishTemplateIdList)
	local eventConditionImplModule = UX.Game.EventConditionImplModule

	if moduleEnum == eventConditionImplModule.PhoneContact then
		gCallPhoneUtils.SyncPhoneUnlockContactIdList(incrementFinishTemplateIdList)
	elseif moduleEnum == eventConditionImplModule.PhoneContactOption then
		-- Nothing
	elseif moduleEnum == eventConditionImplModule.CityPedia then
		gBaiKeArchiveManager.SyncCityPediaUnlocked(incrementFinishTemplateIdList)
	elseif moduleEnum == eventConditionImplModule.Achievement then
		gMessageManager:SendMessage(gEventConstants.GAIN_ACHIEVEMENT)
	elseif moduleEnum == eventConditionImplModule.CompetitionSeasonChallenge then
		gInspireHubManager:SyncCompetitionSeasonChallengeUnlock(incrementFinishTemplateIdList)
	elseif moduleEnum == eventConditionImplModule.CompetitionSeasonGameplay then
		gInspireHubManager:SyncCompetitionSeasonGameplayUnlock(incrementFinishTemplateIdList)
	elseif moduleEnum == eventConditionImplModule.InspireHubGameplay then
		gInspireHubManager:SyncInspireHubGameplayUnlock(incrementFinishTemplateIdList)
	end
end

gEventConditionUtils = M
