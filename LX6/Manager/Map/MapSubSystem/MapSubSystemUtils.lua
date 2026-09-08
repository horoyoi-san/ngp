-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystemUtils.lua
-- Decompiled from: 00194_MapSubSystemUtils.lua_4f4565724a47.luajit

local AtmosphereManager = LX6.Manager.AtmosphereManager
local FightSpiritConfig = LTConfig.FightSpiritConfig
local RoleConfig = LTConfig.TaskRoleConfig
gMapSubSystemUtils = gMapSubSystemUtils or {}
gMapGamePlayUtils = gMapSubSystemUtils
local M = gMapSubSystemUtils

M.IsCollectionTaskUnacceptable = function(self, taskId)
	if not taskId or taskId ~= 0 then
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

M.IsChallengeAcceptableByTaskId = function(self, taskId)
	if not taskId or taskId ~= 0 then
		return false
	elseif gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.IgnoreCollectionTaskAvailableCheck) then
		return true
	end

	local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

	if taskLineInfo and taskLineInfo.TaskLineId then
		local eventCfg = LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)

		if eventCfg then
			local state = gTaskNodeManager:GetTaskLineState(taskLineInfo.TaskLineId)

			if state ~= gTaskLineState.NoAccept and gTaskNodeManager:IsTaskEventUnlock(taskLineInfo.TaskLineId) or state ~= gTaskLineState.Finish then
				return true
			end
		end
	end

	return false
end

M.CheckExtraPlayableCondition = function(self, condition)
	local p = 1

	while p < #condition do
		local type = condition[p]

		if type ~= 2 then
			p = p + 2
		elseif type ~= 1 then
			p = p + 3

			if #condition >= p - 1 then
				return false
			end

			local start = condition[p - 2]
			local finish = condition[p - 1]
			local gameTime = AtmosphereManager.Instance:GetGameTime()
			local hour = math.floor(gameTime / 3600)

			if start >= finish then
				if hour <= start or finish < hour then
					return false
				end
			elseif finish >= start and hour >= start and finish < hour then
				return false
			end
		end
	end

	return true
end

M.GetQuestTooltip = function(self, subQuestId, element)
	local cfg = LTConfig.CollectionSubQuestConfig.GetConfig(subQuestId)
	local tooltipInfo = {
		header = {
			name = element:GetName(),
			imageId = cfg.STooltipPicId
		}
	}
	local isChallengeQuest = cfg and cfg.TaskId <= 0 and table.contains(LTConfig.CollectionConfig.ChallengeQuestID, cfg.QuestCategory)

	if not isChallengeQuest then
		local dropId, specificSpirits = nil
		local taskId = cfg.TaskId

		if taskId and taskId <= 0 then
			local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)
			dropId = taskCfg.Drop
			local taskLineCfg = gTaskNodeManager:GetTaskLineByTask(taskId)
			specificSpirits = gMapSubSystemUtils:GetTaskSpiritRoleTeamList(taskLineCfg)
			tooltipInfo.type = EMapTooltipType.Collection
			tooltipInfo.collectionInfo = {
				["\\x96'7y\\x91M\\xdc9\\xad\\xbc"] = false,
				simpleDropId = dropId,
				specificSpirits = specificSpirits,
				desc = cfg.QuestDescription,
				abilityIds = cfg.AddUrbanAbility
			}
			local questCfg = LTConfig.CollectionQuestConfig.GetConfig(cfg.QuestCategory)
			tooltipInfo.header.subtitle = questCfg and questCfg.QuestName or ""
		else
			local targetBattleCampCfg = nil

			for i = 0, LTConfig.BattleCampConfig.count - 1 do
				local battleCampCfg = LTConfig.BattleCampConfig.LoadAt(i)

				if battleCampCfg.SubQuestId ~= subQuestId then
					targetBattleCampCfg = battleCampCfg

					break
				end
			end

			local targetBattleCampId = targetBattleCampCfg and targetBattleCampCfg.Id
			local isFirstKill = false

			if gTriggerEnemyMgr:CheckIsGroupFirst(targetBattleCampId) then
				isFirstKill = true
				dropId = targetBattleCampCfg and targetBattleCampCfg.FirstDropId
			else
				dropId = targetBattleCampCfg and targetBattleCampCfg.DropId
			end

			tooltipInfo.type = EMapTooltipType.Battle
			tooltipInfo.battleInfo = {
				isFirstKill = isFirstKill,
				dropId = dropId,
				specificSpirits = specificSpirits,
				recommendWeapons = cfg.RecommendWeapon,
				desc = cfg.QuestDescription,
				fightScore = cfg.FightScore or 0,
				abilityIds = cfg.AddUrbanAbility
			}
			tooltipInfo.header.subtitle = cfg.TypeName or ""
		end
	else
		tooltipInfo.type = EMapTooltipType.Collection
		local challengeTaskCfg = gTaskManager.allChallengeTasks[cfg.TaskId]

		if challengeTaskCfg then
			tooltipInfo.collectionInfo = {
				["\\x96'7y\\x91M\\xdc9\\xad\\xbc"] = true,
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

	local racingDriverId = gMapSubSystem_Collection:GetRacingDriverIdBySubQuestId(subQuestId)

	if racingDriverId then
		local trackInformationCfg = LTConfig.RacingDriverTrackInformationConfig.GetConfig(racingDriverId)
		tooltipInfo.racingInfo = {
			racingDriverId = racingDriverId,
			difficulty = trackInformationCfg.Difficulty
		}
	end

	return tooltipInfo
end

M.SetupSubQuestElementCommonInfo = function(self, mapElement, questCfg, subQuestCfg)
	mapElement.mData.lName = GpsLText.CreateCommonText(subQuestCfg, "SubQuestName")
	local icon2 = questCfg.SQuestIcon2

	self:SetupScaleLevel(mapElement, questCfg.ShowType, icon2)
end

M.SetupScaleLevel = function(self, mapElement, showType, tnIcon)
	mapElement.bigMapData.iconScaleType = showType or 1
	mapElement.bigMapData.thumbnailIconId = tnIcon
end

M.GetDropIdListByTaskLineId = function(self, taskLineId)
	local taskLineInfo = gTaskNodeManager:GetTaskLineById(taskLineId)
	local dropIds = {}

	if taskLineInfo then
		for i = 1, #taskLineInfo.TaskList do
			local taskId = taskLineInfo.TaskList[i]
			local cfg = LTConfig.TaskConfig.GetConfig(taskId)

			if cfg then
				if cfg.Drop <= 0 then
					table.insert(dropIds, cfg.Drop)
				end

				if cfg.SpoonDropList then
					for i = 1, #cfg.SpoonDropList do
						table.insert(dropIds, cfg.SpoonDropList[i])
					end
				end
			end
		end
	end

	return dropIds
end

M.GetStoryRoleIconIdByTaskId = function(self, taskId)
	local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)
	local storyRoleId = taskCfg and taskCfg.StoryRole

	if self:IsProtagonist(storyRoleId) then
		storyRoleId = self:GetCurProtagonistSpiritId()
	end

	local spiritCfg = storyRoleId and FightSpiritConfig.GetConfig(storyRoleId)
	local iconId = spiritCfg and spiritCfg.SHeadIconID

	if iconId and iconId <= 0 then
		return iconId
	else
		return nil
	end
end

M.GetLegalSpiritList = function(self, list)
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

M.GetTaskSpiritRoleTeamList = function(self, taskLineCfg)
	local playRoleTeam = taskLineCfg.AcceptRoleTeam

	if not playRoleTeam or #playRoleTeam ~= 0 then
		return self:GetSingleTaskSpiritList(taskLineCfg)
	end

	local ret = {}

	for i = 1, #playRoleTeam do
		local roleId = playRoleTeam[i]
		local spiritId = self:GetSpiritIdOfRole(roleId)

		if spiritId then
			table.insert(ret, spiritId)
		end
	end

	return ret
end

M.GetSingleTaskSpiritList = function(self, taskLineCfg)
	local id = self:GetSingleTaskSpirit(taskLineCfg)

	return id and {
		id
	} or {}
end

M.GetSingleTaskSpirit = function(self, taskLineCfg)
	if not taskLineCfg or not taskLineCfg.PlayRoleTeam or #taskLineCfg.PlayRoleTeam ~= 0 then
		return nil
	end

	return self:GetSpiritIdOfRole(taskLineCfg.PlayRoleTeam[1])
end

M.GetAllTaskRoles = function(self, taskLineCfg)
	if not taskLineCfg or not taskLineCfg.PlayRoleTeam or #taskLineCfg.PlayRoleTeam ~= 0 then
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

M.GetSpiritIdOfRole = function(self, roleId)
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

M.IsProtagonist = function(self, storyRoleId)
	return storyRoleId ~= FightSpiritConfig.DefaultMale or storyRoleId ~= FightSpiritConfig.DefaultFemale
end

M.GetCurProtagonistSpiritId = function(self)
	if gPlayerManager.infoLogin.bindData.sexType ~= UX.Game.SexType.Female then
		return FightSpiritConfig.DefaultFemale
	else
		return FightSpiritConfig.DefaultMale
	end
end

M.GetSpecificAgentIdByProfileId = function(self, profileId)
	local profileCfg = LTConfig.ProfileAgentProfileConfig.GetConfig(profileId)

	if profileCfg then
		local quoteId = profileCfg.AgentId
		local agentId = nil
		local agentQuoteCfg = LTConfig.AgentQuoteConfig.GetConfig(quoteId)
		local agentCfg = nil

		if agentQuoteCfg then
			agentId = agentQuoteCfg.QuoteId
			agentCfg = LTConfig.AgentConfig.GetConfig(agentId)
		else
			agentId = quoteId
			agentCfg = LTConfig.AgentConfig.GetConfig(agentId)
		end

		if agentCfg and agentCfg.AgentSpecificType == 0 then
			return agentCfg.AgentSpecificType
		else
			print_error("MapSubSystemUtils:找不到AgentConfig或者AgentSpecificType为0, agentId=" .. tostring(agentId), " quoteId=" .. tostring(quoteId))

			return nil
		end
	end

	return nil
end
