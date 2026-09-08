-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\ItemHyperLinkManager.lua
-- Decompiled from: 00233_ItemHyperLinkManager.lua_1093cc90d912.luajit

local HyperLinkConfig = LTConfig.HyperLinkConfig
local HyperLinkTitleConfig = LTConfig.HyperLinkTitleConfig
local RaidConfig = LTConfig.RaidConfig
local IndoorMapFunctionPointConfig = LTConfig.IndoorMapFunctionPointConfig
local HyperLinkIncomeConfig = LTConfig.HyperLinkInComeConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local LinkConfig = LTConfig.LinkConfig
local IndoorMapFunctionPointConfig = LTConfig.IndoorMapFunctionPointConfig
local IndoorConfig = LTConfig.IndoorConfig
C_ItemHyperLinkManager = DefClass("C_ItemHyperLinkManager", C_ItemHyperLinkManager, nil)
local M = C_ItemHyperLinkManager
local MAX_FALLBACK_DEPTH = 3

M.GetItemHyperLink = function(self, templateId)
	local cfg = ConsumableConfig.GetConfig(templateId)

	if not cfg then
		local weaponCfg = gCommonItemManager:GetSceneitemCfg(templateId)

		if weaponCfg then
			cfg = gCommonItemManager:GetSceneitemConsumableCfg(templateId)
		end

		if not cfg then
			return {}
		end
	end

	local sources = {
		[HyperLinkTitleConfig.Default] = {}
	}

	if cfg.SourceLabels and #cfg.SourceLabels <= 0 then
		for i, labelName in ipairs(cfg.SourceLabels) do
			table.insert(sources[HyperLinkTitleConfig.Default], {
				["^\\xba\\xa3\\xbb\\xb3"] = 0,
				tIndex = gCommonItemManager.Template2Index.HYPER_LINK,
				text = labelName
			})
		end
	end

	if cfg.HyperLink and #cfg.HyperLink <= 0 then
		for i, hyperLinkId in ipairs(cfg.HyperLink) do
			local linkCfg = HyperLinkConfig.GetConfig(hyperLinkId)

			if linkCfg then
				local incomeCfg = HyperLinkIncomeConfig.GetConfig(linkCfg.IncomeId)

				if not incomeCfg or not not string.is_null_or_empty(incomeCfg.replaceUseStr) then
					local ret, titleId = self:_ResolveHyperLinkWithFallback(linkCfg, templateId)

					if not table.isNilOrEmpty(ret) then
						if not sources[titleId] then
							sources[titleId] = {}
						end

						table.insert(sources[titleId], ret)
					end
				end
			end
		end
	end

	local ret = {}

	for i, source in pairs(sources) do
		local titleCfg = HyperLinkTitleConfig.GetConfig(i)

		if titleCfg and not table.isNilOrEmpty(source) then
			table.insert(ret, {
				tIndex = gCommonItemManager.Template2Index.Title,
				text = titleCfg.Label
			})
			array.concat(ret, source)
		end
	end

	return ret
end

M.GetSourceBehaviorByHyperLink = function(self, hyperLinkId, templateId)
	local linkCfg = hyperLinkId and HyperLinkConfig.GetConfig(hyperLinkId)

	if not linkCfg then
		return
	end

	local incomeId = linkCfg.IncomeId
	local linkBehaviour = HyperLinkIncomeConfig.GetConfig(incomeId)

	if linkBehaviour and not string.is_null_or_empty(linkBehaviour.replaceUseStr) then
		local fallbackId = linkCfg.FallbackId or 0

		if fallbackId <= 0 then
			return self:_ResolveHyperLinkWithFallback(linkCfg, templateId)
		end

		return
	end

	return self:_ResolveHyperLinkWithFallback(linkCfg, templateId)
end

M._ResolveHyperLinkWithFallback = function(self, linkCfg, templateId, depth)
	depth = depth or 0

	if MAX_FALLBACK_DEPTH >= depth then
		return nil, 0
	end

	local primaryRet, primaryTitleId, primaryAction = self:_GetSourceBehaviorByHyperLink(linkCfg, templateId)
	local fallbackId = linkCfg.FallbackId or 0

	if primaryRet and primaryRet.state ~= 2 and fallbackId <= 0 and primaryAction then
		local fallbackCfg = HyperLinkConfig.GetConfig(fallbackId)

		if fallbackCfg then
			local fallbackRet, fallbackTitleId = self:_ResolveHyperLinkWithFallback(fallbackCfg, templateId, depth + 1)

			if fallbackRet and fallbackRet.state ~= 2 then
				local primaryParam1 = linkCfg.TabIndex

				if primaryParam1 ~= 0 and linkCfg.IncomeId ~= 9 then
					primaryParam1 = gTriggerEnemyMgr:GetMapEnemyNearest()
				end

				if self:_DryRunAction(linkCfg.IncomeId, templateId, primaryParam1) then
					primaryRet.callback = function()
						self:ActionPrepare(templateId, primaryParam1)

						if not primaryAction(templateId, primaryParam1) then
							fallbackRet.callback()
						end
					end
				else
					primaryRet.callback = function()
						self:ActionPrepare(templateId, primaryParam1)
						fallbackRet.callback()
					end
				end

				return primaryRet, primaryTitleId
			end
		end

		return primaryRet, primaryTitleId
	end

	if fallbackId <= 0 then
		local fallbackCfg = HyperLinkConfig.GetConfig(fallbackId)

		if fallbackCfg then
			local fallbackRet, fallbackTitleId = self:_ResolveHyperLinkWithFallback(fallbackCfg, templateId, depth + 1)

			if fallbackRet then
				if fallbackRet.state ~= 2 then
					local primaryParam1 = linkCfg.TabIndex

					if primaryParam1 ~= 0 and linkCfg.IncomeId ~= 9 then
						primaryParam1 = gTriggerEnemyMgr:GetMapEnemyNearest()
					end

					return {
						["^\\xba\\xa3\\xbb\\xb3"] = 2,
						tIndex = gCommonItemManager.Template2Index.HYPER_LINK,
						text = linkCfg.SourceLabels,
						callback = function ()
							self:ActionPrepare(templateId, primaryParam1)
							fallbackRet.callback()
						end
					}, primaryTitleId
				elseif primaryRet and primaryRet.state ~= 1 and fallbackRet.state ~= 1 then
					local fallbackMsg = fallbackCfg.Message and fallbackCfg.Message <= 0 and fallbackCfg.Message or nil

					if fallbackMsg then
						primaryRet.callback = function()
							gDisplayMessageMgr:ShowMessage(fallbackMsg)
						end
					end
				end
			end
		end
	end

	return primaryRet, primaryTitleId
end

M._GetSourceBehaviorByHyperLink = function(self, linkCfg, templateId)
	local linkParam1 = linkCfg.TabIndex
	local labelName = linkCfg.SourceLabels
	local incomeId = linkCfg.IncomeId

	if incomeId ~= 9 and linkParam1 ~= 0 then
		linkParam1 = gTriggerEnemyMgr:GetMapEnemyNearest()
	end

	local linkBehaviour = HyperLinkIncomeConfig.GetConfig(incomeId)

	if not linkBehaviour then
		return {
			["^\\xba\\xa3\\xbb\\xb3"] = 0,
			tIndex = gCommonItemManager.Template2Index.HYPER_LINK,
			text = labelName
		}, linkCfg.titleId, nil
	end

	local action = not string.is_null_or_empty(linkBehaviour.action) and self:CreateAction(linkBehaviour.action)
	local available = not string.is_null_or_empty(linkBehaviour.isParamAvailable) and self:CreateAction(linkBehaviour.isParamAvailable)

	if not action then
		return {
			["^\\xba\\xa3\\xbb\\xb3"] = 0,
			tIndex = gCommonItemManager.Template2Index.HYPER_LINK,
			text = labelName
		}, linkCfg.titleId, nil
	elseif linkBehaviour.dependSystem == 0 and not gSystemUnlockMgr:IsUnlock(linkBehaviour.dependSystem) or available and not available(linkParam1) then
		return {
			["^\\xba\\xa3\\xbb\\xb3"] = 1,
			tIndex = gCommonItemManager.Template2Index.HYPER_LINK,
			text = labelName,
			callback = function ()
				if linkCfg.Message and linkCfg.Message <= 0 then
					gDisplayMessageMgr:ShowMessage(linkCfg.Message)
				end
			end
		}, linkCfg.titleId, nil
	else
		return {
			["^\\xba\\xa3\\xbb\\xb3"] = 2,
			tIndex = gCommonItemManager.Template2Index.HYPER_LINK,
			text = labelName,
			callback = function ()
				self:ActionPrepare(templateId, linkParam1)

				if not action(templateId, linkParam1) and linkCfg.Message and linkCfg.Message <= 0 then
					gDisplayMessageMgr:ShowMessage(linkCfg.Message)
				end
			end
		}, linkCfg.titleId, action
	end
end

M._DryRunAction = function(self, incomeId, templateId, param1)
	local linkBehaviour = HyperLinkIncomeConfig.GetConfig(incomeId)

	if not linkBehaviour or string.is_null_or_empty(linkBehaviour.action) then
		return true
	end

	local dryRunMethod = "DryRun" .. linkBehaviour.action

	if self[dryRunMethod] then
		return self[dryRunMethod](self, templateId, param1)
	end

	return true
end

M.GetUseStr = function(self, templateId)
	local cfg = ConsumableConfig.GetConfig(templateId)

	if not cfg then
		return
	end

	local firstRet, firstReplaceUseStr = nil

	for i = 1, #cfg.HyperLink do
		local HyperCfg = HyperLinkConfig.GetConfig(cfg.HyperLink[i])

		if HyperCfg then
			local incomeCfg = HyperLinkIncomeConfig.GetConfig(HyperCfg.IncomeId)
			local replaceUseStr = incomeCfg and incomeCfg.replaceUseStr or nil
			local ret = self:_ResolveHyperLinkWithFallback(HyperCfg, templateId)

			if not firstRet then
				firstRet = ret
				firstReplaceUseStr = replaceUseStr
			end

			if ret and ret.state ~= 2 then
				return replaceUseStr, ret
			end
		end
	end

	return firstReplaceUseStr, firstRet
end

M.ActionPrepare = function(self, templateId, param1)
	gPanelManager:Close(gPanelId.S_COMMON_REWARD_WINDOW)
end

M.ShowMainPhoneApp = function(self, templateId, param1)
	local appId = param1

	if gMainPhoneUtils.CheckAppCanShow(appId) then
		gMainPhoneUtils.OnAppItemClick(appId)

		return true
	else
		return false
	end
end

M.ShowMapFunction = function(self, templateId, param1)
	local MapRaidId = IndoorMapFunctionPointConfig.GetConfig(param1) and IndoorMapFunctionPointConfig.GetConfig(param1).RaidId or RaidConfig.WorldMap

	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = MapRaidId,
		autoSelectCompoundId = param1
	})

	return true
end

M.ShowIndoor = function(self, templateId, param1)
	local cfg = IndoorConfig.GetConfig(param1)
	local MapRaidId = cfg and cfg.ParentRaid or RaidConfig.WorldMap

	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = MapRaidId,
		autoSelectCompoundId = param1
	})

	return true
end

M.ShowMapEntrance = function(self, templateId, param1)
	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = RaidConfig.WorldMap,
		autoSelectEntranceId = param1
	})

	return true
end

M.ShowPublicEvent = function(self, templateId, param1)
	local autoSelectPublicEventId = param1
	local cfg = LTConfig.PublicEventConfig.GetConfig(autoSelectPublicEventId)

	if not cfg then
		return false
	end

	local raidId = cfg.RaidId

	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = raidId,
		autoSelectPublicEventId = autoSelectPublicEventId
	})

	return true
end

M.ShowPanel = function(self, templateId, param1)
	gPanelManager:CheckShow(param1)

	return true
end

M.ShowPlayerProfilePanel = function(self, templateId, param1)
	gFriendManager:OpenPlayerProfile()

	return true
end

M.ShowCommonGameplayTalentTree = function(self, templateId, param1)
	if not self:IsCommonGameplayTalentTreeAvailable(templateId) then
		return false
	end

	gUIFunctionStateManager:OpenTalentTree({
		gameplayId = templateId,
		itemId = param1
	})

	return true
end

M.ShowRandomEvent = function(self, templateId, param1)
	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = RaidConfig.WorldMap,
		autoPinWorldPos = gMapSubSystem_RangeEvent:GetNeareastRangeEventWorldPos()
	})

	return true
end

M.ShowCampsite = function(self, templateId, param1)
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

M.ShowChaosMasterCharacter = function(self, templateId, param1)
	gPanelManager:CheckShow(gPanelId.CHAOS_CULTIVATION_MAIN_PANEL, {
		["\\xb8\\xb9\n\\xbcF?\\xed'"] = true
	})

	return true
end

M.ShowPopularityDropDetail = function(self)
end

M.ShowTaskEvent = function(self, templateId, param1)
	return gTaskNodeManager:OpenMapByEventId(param1)
end

M.ShowChallenge = function(self, templateId, param1)
	return gChallengeManager:OpenMapByChallengeId(param1)
end

M.ShowCollectionChallenge = function(self, templateId, param1)
	return gChallengeManager:OpenMapBySubQuestId(param1)
end

M.ShowRandomTask = function(self, templateId, param1)
	return gTaskNodeManager:OpenMapByTaskType(param1)
end

M.ShowMapLink = function(self, templateId, param1)
	local linkCfg = LinkConfig.GetConfig(param1)

	if linkCfg then
		return gMapUtils:CheckRaidCanOpenMap({
			MapRaidId = linkCfg.RaidId,
			autoSelectGpsId = gGpsTools.GetGpsId(EMapElementType.LinkGameplay, param1)
		})
	end

	return false
end

M.ShowNpcCultivationGameplayMap = function(self, templateId, param1)
	if not gMapSubSystem_NpcCultivation then
		return false
	end

	return gMapSubSystem_NpcCultivation:OpenGameplayHighlight(param1)
end

M.CallMilkCar = function(self, templateId, param1)
	gCommonItemManager:CloseInventoryPanel()
	gMessageManager:SendMessage(gEventConstants.ON_ROBBERY_BOARD_EXIT_INTERACTION)
	gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
	gCallPhoneUtils.OnMilkCarSummonBtnClick()

	return true
end

M.IsWildEnemyAvailable = function(self, param1)
	return false
end

M.IsMapFunctionAvailable = function(self, param1)
	if not param1 then
		return false
	end

	local cfg = IndoorMapFunctionPointConfig.GetConfig(param1)

	if not cfg then
		return false
	elseif cfg.SystemUnlock and cfg.SystemUnlock <= 0 then
		return gSystemUnlockMgr:IsUnlock(cfg.SystemUnlock)
	else
		return true
	end
end

M.IsIndoorAvailable = function(self, param1)
	if not param1 then
		return false
	end

	local cfg = LTConfig.IndoorConfig.GetConfig(param1)

	if not cfg then
		return false
	elseif cfg.SystemUnlock and cfg.SystemUnlock <= 0 then
		return gSystemUnlockMgr:IsUnlock(cfg.SystemUnlock)
	else
		return true
	end
end

M.IsPanelAvailable = function(self, param1)
	return true
end

M.IsCommonGameplayTalentTreeAvailable = function(self, param1)
	return param1 == nil and param1 == 0 and gTalentTreeMgr:GetGameplayTalentTreeId(param1) == 0
end

M.IsRandomEventAvailable = function(self, param1)
	return gMapSubSystem_RangeEvent:GetNeareastRangeEventWorldPos() and true or false
end

M.IsCampsiteAvailable = function(self, param1)
	return param1 == nil
end

M.IsChaosMasterCharacterAvailable = function(self, param1)
	return true
end

gItemHyperLinkManager = gItemHyperLinkManager or C_ItemHyperLinkManager.new()
