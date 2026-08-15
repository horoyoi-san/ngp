local FactionConfig = LTConfig.FactionConfig
local actionHelper = require("LX6/Manager/Map/MapSubSystem/MapSubSystemActionHelper")
MapSubSystem_Faction = DefClass("MapSubSystem_Faction", MapSubSystem_Faction, MapSubSystemBase)
local M = MapSubSystem_Faction

function M:OnInit()
	self.eventHandlers = {
		[gEventConstants.FACTION_INFO_CHANGE] = function ()
			self:FlushData("Faction_Info_Change")
		end
	}
	self.curDisturbEventInfo = nil

	gMessageManager:RegisterEventHandlers(self.eventHandlers)

	self.disturbEventInfos = {}
end

function M:OnLoadData()
	if self.mapElements then
		for _, elements in pairs(self.mapElements) do
			for _, element in ipairs(elements) do
				if element then
					element:Dispose()
				end
			end
		end
	end

	self.mapElements = {}

	for i = 0, FactionConfig.count - 1 do
		local cfg = FactionConfig.LoadAt(i)

		if cfg.ShowInACDMap and cfg.Center then
			if #cfg.Center >= 1 then
				for centerIdx, center in ipairs(cfg.Center) do
					if not center.x or not center.y then
						break
					end

					local id = cfg.Id .. centerIdx
					local element = MapElement.CreateLegacy(EMapElementType.Faction, id, EMapSubSystemType.Faction, EMapViewMask.Faction, 23300888, 0)
					local elements = self.mapElements[cfg.Id]

					if not elements then
						elements = {}
						self.mapElements[cfg.Id] = elements
					end

					table.insert(elements, element)
					element:SetVisible(true)

					element.mData.lName = GpsLText.CreateCommonText(cfg, "name", cfg.name)
					element.bigMapData.showName = true
					element.fData.bigMapTIndex = 7
					element.bigMapData.customRenderFuncKey = "OnCustomRenderFactionIcon"
					element.mData.sIconId = cfg.imageId
					element.userdata = {
						dispositionLevel = 1,
						factionId = cfg.Id
					}
					local position = Vector3.New(center.x, 0, center.y)

					element:SetPosition(position)
				end
			end
		end
	end
end

function M:OnFlushData()
	if not self.mapElements then
		return
	end

	for id, elements in pairs(self.mapElements) do
		for _, element in ipairs(elements) do
			self:SetupIcon(id, element)
		end
	end
end

function M:SetupIcon(factionId, element)
	local factionInfo = gClientUtils.GetFactionInfo(factionId)

	if not factionInfo then
		return
	end

	local dispositionLevel = factionInfo.DispositionLevel

	if dispositionLevel == 0 then
		dispositionLevel = 1
	end

	local levelCfg = LTConfig.FactionDispositionConfig.GetConfig(dispositionLevel)

	if not levelCfg then
		return
	end

	element.userdata.dispositionLevel = dispositionLevel

	gMapSystem.container:MarkElementAsDirty(element.instanceId)
end

function M:GetFirstElement(factionId)
	local elements = self.mapElements[factionId]

	if not elements or #elements < 1 then
		return nil
	end

	return elements[1]
end

function M:SyncFactionHighLightEvents(eventIds)
	self:DisposeAllDisturbEventInfo()

	if eventIds and eventIds.Count > 0 then
		for i = 1, eventIds.Count do
			local eventId = eventIds[i]

			if eventId then
				self:CreateDisturbEventInfo(eventId)
			end
		end
	end
end

function M:CreateDisturbEventInfo(eventId)
	local eventCfg = LTConfig.TaskEventConfig.GetConfig(eventId)

	if not eventCfg or eventCfg.RandomClassify == 0 then
		return
	end

	local randomEventCfg = LTConfig.RandomEventClassifyConfig.GetConfig(eventCfg.RandomClassify)

	if not randomEventCfg or not eventCfg.CenterPos or #eventCfg.CenterPos < 3 then
		return
	end

	local worldPos = Vector3.New(eventCfg.CenterPos[1], eventCfg.CenterPos[2], eventCfg.CenterPos[3])
	self.disturbEventInfos[eventId] = {
		eventId = eventId,
		position = worldPos,
		areaId = gMapAreaMgr:GetAreaId(LTConfig.RaidConfig.WorldMap, 0),
		peopleEnum = randomEventCfg.FactionMapImageId
	}
end

function M:DisposeDisturbEventInfo(eventId)
	if not self.disturbEventInfos or not self.disturbEventInfos[eventId] then
		return
	end

	self.disturbEventInfos[eventId] = nil
end

function M:DisposeAllDisturbEventInfo()
	if not self.disturbEventInfos then
		return
	end

	self.disturbEventInfos = {}
end

function M:OnRemoveEvent(id)
	if not self.disturbEventInfos or not self.disturbEventInfos[id] then
		return
	end

	self:DisposeDisturbEventInfo(id)
end

function M:ExecuteAction(element, action, ctx)
	if (element and element.userdata and element.userdata.eventId) ~= nil then
		if action == gMapSystemElementAction.Trace then
			element:SetViewMask(EMapViewMask.HudGps + EMapViewMask.Faction + EMapViewMask.MiniMap)
		elseif action == gMapSystemElementAction.Untrace then
			element:SetViewMask(EMapViewMask.HudGps + EMapViewMask.Faction)
		end
	end

	actionHelper.TryExecuteTraceAction(element, action, ctx)
end

function M:SGetTooltipInfo(id, element)
	local tooltipInfo = {}
	local factionId = element and element.userdata and element.userdata.factionId

	if not factionId then
		print_error("MapSubSystem_Faction:SGetTooltipInfo factionId is nil, id:", id)

		return nil
	end

	local cfg = FactionConfig.GetConfig(factionId)
	tooltipInfo.type = EMapTooltipType.Faction
	tooltipInfo.header = {
		name = cfg.name,
		imageId = cfg.TooltipImageId
	}
	tooltipInfo.factionInfo = {
		factionId = factionId
	}

	return tooltipInfo
end

return M
