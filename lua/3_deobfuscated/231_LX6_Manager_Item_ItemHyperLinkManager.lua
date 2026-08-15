local MessageConfig = LTConfig.MessageConfig
local HyperLinkConfig = LTConfig.HyperLinkConfig
local HyperLinkTitleConfig = LTConfig.HyperLinkTitleConfig
local RaidConfig = LTConfig.RaidConfig
local IndoorMapFunctionPointConfig = LTConfig.IndoorMapFunctionPointConfig
local HyperLinkIncomeConfig = LTConfig.HyperLinkInComeConfig
local ConsumableConfig = LTConfig.ConsumableConfig
C_ItemHyperLinkManager = DefClass("C_ItemHyperLinkManager", C_ItemHyperLinkManager, nil)
local M = C_ItemHyperLinkManager

function M:GetItemHyperLink(templateId)
	local cfg = ConsumableConfig.GetConfig(templateId)

	if not cfg then
		return {}
	end

	local sources = {
		[HyperLinkTitleConfig.Default] = {}
	}

	if cfg.SourceLabels and #cfg.SourceLabels > 0 then
		for i, labelName in ipairs(cfg.SourceLabels) do
			table.insert(sources[HyperLinkTitleConfig.Default], {
				state = 0,
				tIndex = C_CommonItemManager.Template2Index.HYPER_LINK,
				text = labelName
			})
		end
	end

	if cfg.HyperLink and #cfg.HyperLink > 0 then
		for i, hyperLinkId in ipairs(cfg.HyperLink) do
			local ret, titleId = self:GetSourceBehaviorByHyperLink(hyperLinkId, templateId)

			if not table.isNilOrEmpty(ret) then
				if not sources[titleId] then
					sources[titleId] = {}
				end

				table.insert(sources[titleId], ret)
			end
		end
	end

	local ret = {}

	for i, source in pairs(sources) do
		local titleCfg = HyperLinkTitleConfig.GetConfig(i)

		if titleCfg and not table.isNilOrEmpty(source) then
			table.insert(ret, {
				tIndex = C_CommonItemManager.Template2Index.Title,
				text = titleCfg.Label
			})
			array.concat(ret, source)
		end
	end

	return ret
end

function M:GetSourceBehaviorByHyperLink(hyperLinkId, templateId)
	local linkCfg = hyperLinkId and HyperLinkConfig.GetConfig(hyperLinkId)

	if not linkCfg then
		return
	end

	local linkParam1 = linkCfg.TabIndex
	local labelName = linkCfg.SourceLabels
	local incomeId = linkCfg.IncomeId

	if incomeId == 9 then
		linkParam1 = gTriggerEnemyMgr:GetMapEnemyNearest()
	end

	local linkBehaviour = HyperLinkIncomeConfig.GetConfig(incomeId)

	if not linkBehaviour then
		return {
			state = 0,
			tIndex = C_CommonItemManager.Template2Index.HYPER_LINK,
			text = labelName
		}, linkCfg.titleId
	end

	local action = not string.is_null_or_empty(linkBehaviour.action) and self:CreateAction(linkBehaviour.action)
	local available = not string.is_null_or_empty(linkBehaviour.isParamAvailable) and self:CreateAction(linkBehaviour.isParamAvailable)

	if not action then
		return {
			state = 0,
			tIndex = C_CommonItemManager.Template2Index.HYPER_LINK,
			text = labelName
		}, linkCfg.titleId
	elseif linkBehaviour.dependSystem ~= 0 and not gSystemUnlockMgr:IsUnlock(linkBehaviour.dependSystem) or available and not available(linkParam1) then
		return {
			state = 1,
			tIndex = C_CommonItemManager.Template2Index.HYPER_LINK,
			text = labelName,
			callback = function ()
				if linkCfg.Message and linkCfg.Message > 0 then
					gDisplayMessageMgr:ShowMessage(linkCfg.Message)
				end
			end
		}, linkCfg.titleId
	else
		return {
			state = 2,
			tIndex = C_CommonItemManager.Template2Index.HYPER_LINK,
			text = labelName,
			callback = function ()
				self:ActionPrepare(templateId, linkParam1)

				if not action(templateId, linkParam1) then
					gDisplayMessageMgr:ShowMessage(linkCfg.Message)
				end
			end
		}, linkCfg.titleId
	end
end

function M:ActionPrepare(templateId, param1)
	gPanelManager:Close(gPanelId.S_COMMON_REWARD_WINDOW)
end

function M:ShowWildEnemy(templateId, param1)
	local templateId = param1

	gClientToGameDelegate:AskGetRaidWildEnemyInfo(RaidConfig.WorldMap).Callback = function (err, enemyList)
		if err == MessageConfig.Ok and enemyList then
			for _, enemy in pairs(enemyList) do
				if enemy.TemplateId == templateId then
					gMapUtils:CheckRaidCanOpenMap({
						MapRaidId = RaidConfig.WorldMap,
						AutoSelectWildEnemyId = {
							templateId,
							enemy.SpoonId
						}
					})
				end
			end
		end
	end

	return true
end

function M:ShowMainPhoneApp(templateId, param1)
	local appId = param1

	if gMainPhoneUtils.CheckAppCanShow(appId) then
		gMainPhoneUtils.OnAppItemClick(appId)

		return true
	else
		return false
	end
end

function M:ShowMapFunction(templateId, param1)
	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = RaidConfig.WorldMap,
		autoSelectCompoundId = param1
	})

	return true
end

function M:ShowIndoor(templateId, param1)
	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = RaidConfig.WorldMap,
		autoSelectCompoundId = param1
	})

	return true
end

function M:ShowPanel(templateId, param1)
	gPanelManager:CheckShow(param1)

	return true
end

function M:ShowRandomEvent(templateId, param1)
	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = RaidConfig.WorldMap,
		autoPinWorldPos = gMapSubSystem_RangeEvent:GetNeareastRangeEventWorldPos()
	})

	return true
end

function M:ShowCampsite(templateId, param1)
	local wildEnemyData = gSpoonMgr:GetRaidGraph():GetWildEnemyData(param1)

	if wildEnemyData then
		gMapUtils:CheckRaidCanOpenMap({
			MapRaidId = RaidConfig.WorldMap,
			autoSelectGpsId = gGpsTools.GetGpsId(EMapElementType.Camp, wildEnemyData.subQuestId)
		})

		return true
	end

	gMapUtils:CheckRaidCanOpenMap()

	return false
end

function M:ShowChaosMasterCharacter(templateId, param1)
	gPanelManager:CheckShow(gPanelId.CHAOS_CULTIVATION_MAIN_PANEL, {
		showLast = true
	})

	return true
end

function M:ShowPopularityDropDetail()
	return
end

function M:ShowTaskEvent(templateId, param1)
	return gTaskNodeManager:OpenMapByEventId(param1)
end

function M:ShowChallenge(templateId, param1)
	return gChallengeManager:OpenMapByChallengeId(param1)
end

function M:ShowRandomTask(templateId, param1)
	return gTaskNodeManager:OpenMapByTaskType(param1)
end

function M:IsWildEnemyAvailable(param1)
	return false
end

function M:IsMapFunctionAvailable(param1)
	if not param1 then
		return false
	end

	local cfg = IndoorMapFunctionPointConfig.GetConfig(param1)

	if not cfg then
		return false
	elseif cfg.SystemUnlock and cfg.SystemUnlock > 0 then
		return gSystemUnlockMgr:IsUnlock(cfg.SystemUnlock)
	else
		return true
	end
end

function M:IsIndoorAvailable(param1)
	if not param1 then
		return false
	end

	local cfg = LTConfig.IndoorConfig.GetConfig(param1)

	if not cfg then
		return false
	elseif cfg.SystemUnlock and cfg.SystemUnlock > 0 then
		return gSystemUnlockMgr:IsUnlock(cfg.SystemUnlock)
	else
		return true
	end
end

function M:IsPanelAvailable(param1)
	return true
end

function M:IsRandomEventAvailable(param1)
	return gMapSubSystem_RangeEvent:GetNeareastRangeEventWorldPos() and true or false
end

function M:IsCampsiteAvailable(param1)
	return param1 ~= nil
end

function M:IsChaosMasterCharacterAvailable(param1)
	return true
end

gItemHyperLinkManager = gItemHyperLinkManager or C_ItemHyperLinkManager.new()
