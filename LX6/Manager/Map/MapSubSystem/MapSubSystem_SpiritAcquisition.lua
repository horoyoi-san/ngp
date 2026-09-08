-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_SpiritAcquisition.lua
-- Decompiled from: 02324_MapSubSystem_SpiritAcquisition.lua_a97a708315e7.luajit

local AgentAgentSpecificTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local GpsConfig = LTConfig.GpsConfig
local AtmosphereManager = LX6.Manager.AtmosphereManager
local FightSpiritConfig = LTConfig.FightSpiritConfig
MapSubSystem_SpiritAcquisition = DefClass("MapSubSystem_SpiritAcquisition", MapSubSystem_SpiritAcquisition, MapSubSystemBase)
local M = MapSubSystem_SpiritAcquisition

M.OnInit = function(self)
	self.spiritNpcs = {}
	self.system2Npc = {}
	self.eventHandlers = {
		[gEventConstants.NPC_TIME_TABLE_UPDATE] = function (agentTag)
			self:FlushData()
		end
	}
end

M.OnLogin = function(self)
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
	self:FlushData()
end

M.OnLogout = function(self)
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	for npcTag, mapElement in pairs(self.spiritNpcs) do
		mapElement.Dispose(mapElement)
	end

	table.clear(self.spiritNpcs)
end

M.SGetTooltipInfo = function(self, id, element)
	local tooltipInfo = {
		type = EMapTooltipType.Character,
		characterInfo = {
			agenActivityId = element.userdata.agentActivityId
		}
	}

	return tooltipInfo
end

M.ExecuteAction = function(self, element, action, ctx)
	gMapSubSystemActionHelper.TryExecuteTraceAction(element, action, ctx)
end

M.OnFlushData = function(self)
	local isMainCharacter = gSpiritManager:CheckIsMainCharacter()
	local viewMask = isMainCharacter and EMapViewMask.AllSgui or EMapViewMask.HudGps + EMapViewMask.BigMap

	for npcTag, element in pairs(self.spiritNpcs) do
		if not gNpcDaliyManager.NpcTimeTableInfos[npcTag] then
			element.SetVisible(element, false)
		end
	end

	for npcTag, npcTimeTable in pairs(gNpcDaliyManager.NpcTimeTableInfos) do
		local schedule = gNpcDaliyManager:GetCurrentSchedule(npcTag)

		if not schedule then
			-- Nothing
		else
			local activityId = schedule and schedule.ActivityId or 0
			local activityCfg = LTConfig.AgentDataSetsActivityConfig.GetConfig(activityId)

			if not activityCfg then
				-- Nothing
			else
				local agentTagCfg = AgentAgentSpecificTypeConfig.GetConfig(npcTag)

				if agentTagCfg then
					local raidId = schedule.RaidId

					if npcTimeTable.CurrentSpoonAgentId == 0 then
						raidId = gMapSystem.lastRaidId
					end

					local element = self.spiritNpcs[npcTag]

					if not element then
						if not activityCfg then
							-- Nothing
						else
							local agentId = gMapSystem.dataUtils:GetAgentIdByAgentTag(npcTag)
							local agentCfg = LTConfig.AgentConfig.GetConfig(agentId)

							if agentCfg then
								element = MapElement.CreateLegacy(EMapElementType.SpiritAcquisition, npcTag, EMapSubSystemType.SpiritAcquisition, viewMask, raidId)
								element.mData.sIconId = agentTagCfg.QImageId
								local showType = LTConfig.GpsConfig.ShowTypeOfAcquisitionNPC[1]
								local thumbnailIconId = LTConfig.GpsConfig.ShowTypeOfAcquisitionNPC[2]

								gMapSubSystemUtils:SetupScaleLevel(element, showType, thumbnailIconId)

								local lName = GpsLText.CreateCommonText(agentCfg, "Name", agentCfg.Name)
								element.fData.filterLName = lName
								element.fData.bindConflictPriority = -1
								element.mData.lName = lName

								element:SetVisible(true)
								self:CommonSetupElement(element)
								self:SetupElementActivity(element, activityCfg, agentTagCfg, npcTag)
								element:BindAgentTag(npcTag)

								self.spiritNpcs[npcTag] = element
							end
						end
					else
						if element.raidId == raidId then
							element.SetRaidId(element, raidId)
						end

						element.SetVisible(element, true)
						self.SetupElementActivity(self, element, activityCfg, agentTagCfg, npcTag)
						element.SetViewMask(element, viewMask)
					end
				end
			end
		end
	end
end

M.CommonSetupElement = function(self, element)
	element.SetActions(element, self.NormalTraceableActions)

	element.fData.bigMapTIndex = 2
	element.fData.showInBigWorld = true

	if GpsConfig.AcquisitionNPCIsAboveFog then
		element.fData.ignoreFog = true
	end

	element.gpsData.removeGpsRange = LTConfig.GameConfig.SpiritAcquisitionRemoveGpsRange
	element.fData.bigMapLimitSpirits = {
		FightSpiritConfig.DefaultFemale,
		FightSpiritConfig.DefaultMale
	}
	element.fData.miniMapLimitSpirits = {
		FightSpiritConfig.DefaultFemale,
		FightSpiritConfig.DefaultMale
	}
end

M.SetupElementActivity = function(self, element, cfg, agentTagCfg, npcTag)
	local hasCultivation = cfg.NpccultivationId == 0
	local hasFightTask = agentTagCfg.HasFightTask
	local isBusy = gNpcDaliyManager.NpcBusyInfo[npcTag] == nil
	local canFight = hasFightTask and not isBusy
	local isInitialSetup = element.userdata ~= nil
	element.fData.interestOnly = not hasCultivation and not hasFightTask
	element.bigMapData.filterTag = nil
	element.bigMapData.tmp_filterTag2 = nil
	element.bigMapData.elementFilterId = nil
	element.bigMapData.addToFilterMenuCondKey = nil

	if hasCultivation then
		element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Npc
		element.bigMapData.tmp_filterTag2 = canFight and LTConfig.GpsFilterTagConfig.Fight or nil
		element.bigMapData.elementFilterId = ElementFilterId.CreateFilterIdByCfg(cfg, "AgentTag", 1000, cfg.AgentTag)
		element.bigMapData.addToFilterMenuCondKey = "Condition_SpiritAcquisition"
	elseif canFight then
		element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Fight
	end

	element.userdata = element.userdata or {}
	element.userdata.agentActivityId = cfg.Id

	print_notice("[SpiritAcquisition][SetupElementActivity]", "initial=", isInitialSetup, "instanceId=", element.instanceId, "npcTag=", npcTag, "activityId=", cfg.Id, "activityAgentTag=", cfg.AgentTag, "npccultivationId=", cfg.NpccultivationId, "hasFightTask=", hasFightTask, "isBusy=", isBusy, "canFight=", canFight, "interestOnly=", element.fData.interestOnly, "filterTag=", element.bigMapData.filterTag, "tmpFilterTag2=", element.bigMapData.tmp_filterTag2, "hasElementFilterId=", element.bigMapData.elementFilterId == nil, "filterCondKey=", element.bigMapData.addToFilterMenuCondKey, "visible=", element:IsVisible(), "raidId=", element.raidId, "gBoundId=", element.gBoundId, "sourceCount=", table.count(element._belongSources))
end

return M
