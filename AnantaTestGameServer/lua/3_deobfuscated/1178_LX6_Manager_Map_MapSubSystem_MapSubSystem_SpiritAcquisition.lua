local AgentAgentSpecificTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local GpsConfig = LTConfig.GpsConfig
local AtmosphereManager = LX6.Manager.AtmosphereManager
local FightSpiritConfig = LTConfig.FightSpiritConfig
MapSubSystem_SpiritAcquisition = DefClass("MapSubSystem_SpiritAcquisition", MapSubSystem_SpiritAcquisition, MapSubSystemBase)
local M = MapSubSystem_SpiritAcquisition

function M:OnInit()
	self.spiritNpcs = {}
	self.system2Npc = {}
	self.eventHandlers = {
		[gEventConstants.CHANGE_MY_UNIT2] = function ()
			for _, mapElement in pairs(self.spiritNpcs) do
				gMapSubSystemActionHelper.Untrace(mapElement)
			end
		end
	}
end

function M:OnLogin()
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:OnLogout()
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	for _, mapElement in pairs(self.spiritNpcs) do
		mapElement:Dispose()
	end

	table.clear(self.spiritNpcs)
end

function M:SGetTooltipInfo(id, element)
	local tooltipInfo = {
		type = EMapTooltipType.Character,
		characterInfo = {
			agenActivityId = element.userdata.agentActivityId
		}
	}

	return tooltipInfo
end

function M:ExecuteAction(element, action, ctx)
	gMapSubSystemActionHelper.TryExecuteTraceAction(element, action, ctx)
end

local scheduleKeys = {
	"Schedule0",
	"Schedule1",
	"Schedule2",
	"Schedule3",
	"Schedule4"
}

function M:Tick()
	if not gGpsTools.TryTick("npcAcquisition", 1) then
		return
	end

	local cTime = AtmosphereManager.Instance:GetGameTime()
	local newPositions = gGpsTools.GetTable()
	local newSpoonIds = gGpsTools.GetTable()

	for npcTag, npcTimeTable in pairs(gNpcDaliyManager.NpcTimeTableInfos) do
		local schedule = gNpcDaliyManager:GetCurrentSchedule(npcTag)

		if schedule and schedule.RaidId and schedule.RaidId ~= 0 and (schedule.EndDaySecond < schedule.StartDaySecond and (schedule.StartDaySecond <= cTime or cTime <= schedule.EndDaySecond) or schedule.StartDaySecond <= cTime and cTime <= schedule.EndDaySecond) then
			local activityId = schedule.ActivityId

			if activityId and activityId ~= 0 then
				if npcTimeTable.CurrentSpoonAgentId ~= 0 then
					newPositions[activityId] = npcTimeTable.SpoonPosition
					newSpoonIds[activityId] = npcTimeTable.CurrentSpoonAgentId
				else
					newPositions[activityId] = schedule.Position
					newSpoonIds[activityId] = schedule.SpoonAgentId
				end
			end
		end
	end

	for activityId, element in pairs(self.spiritNpcs) do
		local pos = newPositions[activityId]

		if not pos then
			element:Dispose()

			self.spiritNpcs[activityId] = nil
		else
			element:SetPositionXYZ(pos.X, pos.Y, pos.Z)
			element:BindUnit(newSpoonIds[activityId])
		end
	end

	for activityId, pos in pairs(newPositions) do
		if not self.spiritNpcs[activityId] then
			local cfg = LTConfig.AgentDataSetsActivityConfig.GetConfig(activityId)

			if not cfg then
				-- Nothing
			else
				local agentTagCfg = AgentAgentSpecificTypeConfig.GetConfig(cfg.AgentTag)

				if not agentTagCfg then
					-- Nothing
				else
					local agentId = gMapSystem.dataUtils:GetAgentIdByAgentTag(cfg.AgentTag)
					local agentCfg = LTConfig.AgentConfig.GetConfig(agentId)

					if agentCfg then
						local element = MapElement.CreateLegacy(EMapElementType.SpiritAcquisition, activityId, EMapSubSystemType.SpiritAcquisition, EMapViewMask.AllSgui, cfg.Raid)

						element:SetPositionXYZ(pos.X, pos.Y, pos.Z)
						element:BindUnit(newSpoonIds[activityId])

						element.mData.sIconId = agentTagCfg.QImageId
						local showType = LTConfig.GpsConfig.ShowTypeOfAcquisitionNPC[1]
						local thumbnailIconId = LTConfig.GpsConfig.ShowTypeOfAcquisitionNPC[2]

						gMapSubSystemUtils:SetupScaleLevel(element, showType, thumbnailIconId)

						local lName = GpsLText.CreateCommonText(agentCfg, "Name", agentCfg.Name)
						element.fData.filterLName = lName
						element.fData.bindConflictPriority = -1
						element.mData.lName = lName

						self:CommonSetupElement(element, cfg)

						self.spiritNpcs[activityId] = element
					end
				end
			end
		end
	end

	gGpsTools.ReleaseTable(newPositions)
	gGpsTools.ReleaseTable(newSpoonIds)
end

function M:CommonSetupElement(element, cfg)
	element:SetActions(self.NormalTraceableActions)

	element.fData.bigMapTIndex = 2
	element.fData.showInBigWorld = true

	if GpsConfig.AcquisitionNPCIsAboveFog then
		element.fData.ignoreFog = true
	end

	if cfg.NpccultivationId ~= 0 then
		element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Npc
		element.bigMapData.elementFilterId = ElementFilterId.CreateFilterIdByCfg(cfg, "AgentTag", 1000, cfg.AgentTag)
		element.bigMapData.addToFilterMenuCondKey = "Condition_SpiritAcquisition"
	else
		element.fData.interestOnly = true
	end

	element:SetVisible(true)

	element.gpsData.removeGpsRange = LTConfig.GameConfig.SpiritAcquisitionRemoveGpsRange
	element.userdata = {
		agentActivityId = cfg.Id
	}
	element.fData.bigMapLimitSpirits = {
		FightSpiritConfig.DefaultFemale,
		FightSpiritConfig.DefaultMale
	}
	element.fData.miniMapLimitSpirits = {
		FightSpiritConfig.DefaultFemale,
		FightSpiritConfig.DefaultMale
	}
end

return M
