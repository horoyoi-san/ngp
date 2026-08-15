local AtmosphereManager = LX6.Manager.AtmosphereManager
local FightSpiritConfig = LTConfig.FightSpiritConfig
local RoleConfig = LTConfig.TaskRoleConfig
gMapSubSystemUtils = gMapSubSystemUtils or {}
gMapGamePlayUtils = gMapSubSystemUtils
local M = gMapSubSystemUtils

function M:IsCollectionTaskUnacceptable(taskId)
	if not taskId or taskId == 0 then
		return false
	elseif gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.IgnoreCollectionTaskAvailableCheck) then
		return false
	end

	local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

	if taskLineInfo and taskLineInfo.TaskLineId then
		local eventCfg = LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)

		if eventCfg then
			local isSpoonEventAcceptable = gTaskManager:IsSpoonEventAcceptable(taskLineInfo.TaskLineId)

			if isSpoonEventAcceptable then
				return false
			end
		end
	end

	return true
end

function M:IsChallengeAcceptableByTaskId(taskId)
	if not taskId or taskId == 0 then
		return false
	elseif gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.IgnoreCollectionTaskAvailableCheck) then
		return true
	end

	local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

	if taskLineInfo and taskLineInfo.TaskLineId then
		local eventCfg = LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)

		if eventCfg then
			local state = gTaskNodeManager:GetTaskLineState(taskLineInfo.TaskLineId)

			if state == gTaskLineState.NoAccept and gTaskNodeManager:IsTaskEventUnlock(taskLineInfo.TaskLineId) or state == gTaskLineState.Finish then
				return true
			end
		end
	end

	return false
end

function M:CheckExtraPlayableCondition(condition)
	local p = 1

	while p <= #condition do
		local type = condition[p]

		if type == 2 then
			p = p + 2
		elseif type == 1 then
			p = p + 3

			if #condition < p - 1 then
				return false
			end

			local start = condition[p - 2]
			local finish = condition[p - 1]
			local gameTime = AtmosphereManager.Instance:GetGameTime()
			local hour = math.floor(gameTime / 3600)

			if start < finish then
				if hour < start or finish <= hour then
					return false
				end
			elseif finish < start and hour < start and finish <= hour then
				return false
			end
		end
	end

	return true
end

function M:GetQuestTooltip(subQuestId, element)
	local cfg = LTConfig.CollectionSubQuestConfig.GetConfig(subQuestId)
	local tooltipInfo = {
		header = {
			name = element:GetName(),
			imageId = cfg.STooltipPicId
		}
	}
	local isChallengeQuest = cfg and cfg.TaskId > 0 and table.contains(LTConfig.CollectionConfig.ChallengeQuestID, cfg.QuestCategory)

	if not isChallengeQuest then
		local dropId, specificSpirits = nil
		local taskId = cfg.TaskId

		if taskId and taskId > 0 then
			local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)
			dropId = taskCfg.Drop
			local taskLineCfg = gTaskNodeManager:GetTaskLineByTask(taskId)
			specificSpirits = gMapSubSystemUtils:GetSingleTaskSpiritList(taskLineCfg)
			tooltipInfo.type = EMapTooltipType.Collection
			tooltipInfo.collectionInfo = {
				isChallenge = false,
				simpleDropId = dropId,
				specificSpirits = specificSpirits,
				desc = cfg.QuestDescription,
				abilityIds = cfg.AddUrbanAbility
			}
			local questCfg = LTConfig.CollectionQuestConfig.GetConfig(cfg.QuestCategory)
			tooltipInfo.header.subtitle = questCfg and questCfg.QuestName or ""
		else
			dropId = cfg.DropId
			tooltipInfo.type = EMapTooltipType.Battle
			tooltipInfo.battleInfo = {
				dropId = dropId,
				specificSpirits = specificSpirits,
				recommendWeapons = cfg.RecommendWeapon,
				desc = cfg.QuestDescription,
				difficulty = cfg.BattleDifficulty or 0,
				abilityIds = cfg.AddUrbanAbility
			}
			tooltipInfo.header.subtitle = cfg.TypeName or ""
		end
	else
		tooltipInfo.type = EMapTooltipType.Collection
		local challengeTaskCfg = gTaskManager.allChallengeTasks[cfg.TaskId]

		if challengeTaskCfg then
			tooltipInfo.collectionInfo = {
				isChallenge = true,
				challengeId = challengeTaskCfg.Id,
				subQuestId = cfg.Id,
				desc = cfg.QuestDescription,
				abilityIds = cfg.AddUrbanAbility
			}
			local questCfg = LTConfig.CollectionQuestConfig.GetConfig(cfg.QuestCategory)
			tooltipInfo.header.subtitle = questCfg and questCfg.QuestName or ""
		else
			print_error("@chencheng1 配表任务不在服务器下发的挑战任务列表，没接到任务，taskId=" .. cfg.TaskId)

			return nil
		end
	end

	return tooltipInfo
end

function M:SetupSubQuestElementCommonInfo(mapElement, questCfg, subQuestCfg)
	mapElement.mData.lName = GpsLText.CreateCommonText(subQuestCfg, "SubQuestName")
	local icon2 = questCfg.SQuestIcon2

	self:SetupScaleLevel(mapElement, questCfg.ShowType, icon2)
end

function M:SetupScaleLevel(mapElement, showType, tnIcon)
	mapElement.bigMapData.iconScaleType = showType or 1
	mapElement.bigMapData.thumbnailIconId = tnIcon
end

function M:GetDropIdListByTaskLineId(taskLineId)
	local taskLineInfo = gTaskNodeManager:GetTaskLineById(taskLineId)
	local dropIds = {}

	if taskLineInfo then
		for i = 1, #taskLineInfo.TaskList do
			local taskId = taskLineInfo.TaskList[i]
			local cfg = LTConfig.TaskConfig.GetConfig(taskId)

			if cfg and cfg.Drop > 0 then
				table.insert(dropIds, cfg.Drop)
			end
		end
	end

	return dropIds
end

function M:GetStoryRoleIconIdByTaskId(taskId)
	local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)
	local storyRoleId = taskCfg and taskCfg.StoryRole

	if self:IsProtagonist(storyRoleId) then
		storyRoleId = self:GetCurProtagonistSpiritId()
	end

	local spiritCfg = storyRoleId and FightSpiritConfig.GetConfig(storyRoleId)
	local iconId = spiritCfg and spiritCfg.SHeadIconID

	if iconId and iconId > 0 then
		return iconId
	else
		return nil
	end
end

function M:GetLegalSpiritList(list)
	local ret = {}

	if not list then
		return ret
	end

	local hasProtagonist = false

	for i = 1, #list do
		local storyRoleId = list[i]

		if self:IsProtagonist(storyRoleId) then
			if not hasProtagonist then
				hasProtagonist = true
				ret[#ret + 1] = self:GetCurProtagonistSpiritId()
			end
		else
			ret[#ret + 1] = storyRoleId
		end
	end

	return ret
end

function M:GetSingleTaskSpiritList(taskLineCfg)
	local id = self:GetSingleTaskSpirit(taskLineCfg)

	return id and {
		id
	} or {}
end

function M:GetSingleTaskSpirit(taskLineCfg)
	if not taskLineCfg or not taskLineCfg.PlayRoleTeam or #taskLineCfg.PlayRoleTeam == 0 then
		return nil
	end

	return self:GetSpiritIdOfRole(taskLineCfg.PlayRoleTeam[1])
end

function M:GetAllTaskRoles(taskLineCfg)
	if not taskLineCfg or not taskLineCfg.PlayRoleTeam or #taskLineCfg.PlayRoleTeam == 0 then
		return {}
	end

	local ret = {}

	for i = 1, #taskLineCfg.PlayRoleTeam do
		local roleId = taskLineCfg.PlayRoleTeam[i]
		local spiritId = self:GetSpiritIdOfRole(roleId)

		if spiritId then
			table.insert(ret, spiritId)
		end
	end

	return ret
end

function M:GetSpiritIdOfRole(roleId)
	local cfg = RoleConfig.GetConfig(roleId)

	if not cfg then
		print_error("Map:获取TaskRoleConfig失败，roleId=" .. tostring(roleId))

		return nil
	end

	if cfg.IsDefault then
		return self:GetCurProtagonistSpiritId()
	end

	return cfg.FightSpiritId
end

function M:IsProtagonist(storyRoleId)
	return storyRoleId == FightSpiritConfig.DefaultMale or storyRoleId == FightSpiritConfig.DefaultFemale
end

function M:GetCurProtagonistSpiritId()
	if gPlayerManager.infoLogin.bindData.sexType == UX.Game.SexType.Female then
		return FightSpiritConfig.DefaultFemale
	else
		return FightSpiritConfig.DefaultMale
	end
end

function M:GetSpecificAgentIdByProfileId(profileId)
	local profileCfg = LTConfig.ProfileAgentProfileConfig.GetConfig(profileId)

	if profileCfg then
		local quoteId = profileCfg.AgentId
		local agentQuoteCfg = LTConfig.AgentQuoteConfig.GetConfig(quoteId)

		if agentQuoteCfg then
			local agentId = agentQuoteCfg.QuoteId
			local agentCfg = LTConfig.AgentConfig.GetConfig(agentId)

			if agentCfg and agentCfg.AgentSpecificType ~= 0 then
				return agentCfg.AgentSpecificType
			else
				print_error("MapSubSystemUtils:找不到AgentConfig或者AgentSpecificType为0, agentId=" .. tostring(agentId))

				return nil
			end
		else
			print_error("MapSubSystemUtils:找不到AgentQuoteConfig, quoteId=" .. tostring(quoteId))

			return nil
		end
	end

	return nil
end
