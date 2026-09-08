-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Faction.lua
-- Decompiled from: 02319_MapSubSystem_Faction.lua_4b3ef901a1bc.luajit

local FactionConfig = LTConfig.FactionConfig
local CollectionCountryConfig = LTConfig.CollectionCountryConfig
local actionHelper = require("LX6/Manager/Map/MapSubSystem/MapSubSystemActionHelper")
MapSubSystem_Faction = DefClass("MapSubSystem_Faction", MapSubSystem_Faction, MapSubSystemBase)
local M = MapSubSystem_Faction

M.OnInit = function(self)
	self.eventHandlers = {
		[gEventConstants.FACTION_INFO_CHANGE] = function ()
			self:FlushData("Faction_Info_Change")
		end
	}
	self.curDisturbEventInfo = nil

	gMessageManager:RegisterEventHandlers(self.eventHandlers)

	self.disturbEventInfos = {}
end

M.OnLoadData = function(self)
	if self.mapElements then
		for _, elements in pairs(self.mapElements) do
			for _, element in ipairs(elements) do
				if element then
					element.Dispose(element)
				end
			end
		end
	end

	self.mapElements = {}

	for i = 0, FactionConfig.count - 1 do
		local cfg = FactionConfig.LoadAt(i)

		if cfg.ShowInACDMap and cfg.Center then
			if #cfg.Center >= 1 then
				-- Nothing
			else
				local countryId = cfg.CountryId
				local countryCfg = countryId and countryId <= 0 and CollectionCountryConfig.GetConfig(countryId)
				local raidId = countryCfg and countryCfg.RaidId

				if not raidId or raidId < 0 then
					print_error("MapSubSystem_Faction:OnLoadData invalid country config, factionId:", cfg.Id, "countryId:", countryId)
				else
					for centerIdx, center in ipairs(cfg.Center) do
						if not center.x or not center.y then
							break
						end

						local id = cfg.Id .. centerIdx
						local element = MapElement.CreateLegacy(EMapElementType.Faction, id, EMapSubSystemType.Faction, EMapViewMask.Faction, raidId, 0)
						local elements = self.mapElements[cfg.Id]

						if not elements then
							elements = {}
							self.mapElements[cfg.Id] = elements
						end

						table.insert(elements, element)
						element.SetVisible(element, true)

						element.mData.lName = GpsLText.CreateCommonText(cfg, "name", cfg.name)
						element.bigMapData.showName = true
						element.fData.bigMapTIndex = 7
						element.bigMapData.customRenderFuncKey = "OnCustomRenderFactionIcon"
						element.mData.sIconId = cfg.imageId
						element.userdata = {
							["c\\x89\\x80\\xb0Ϲ\\xd12\\xa61!\\xb73"] = 1,
							factionId = cfg.Id
						}
						local position = Vector3.New(center.x, 0, center.y)

						element.SetPosition(element, position)
					end
				end
			end
		end
	end
end

M.OnFlushData = function(self)
	if not self.mapElements then
		return
	end

	for id, elements in pairs(self.mapElements) do
		for _, element in ipairs(elements) do
			self.SetupIcon(self, id, element)
		end
	end
end

M.SetupIcon = function(self, factionId, element)
	local factionInfo = gClientUtils.GetFactionInfo(factionId)

	if not factionInfo then
		return
	end

	local dispositionLevel = factionInfo.DispositionLevel

	if dispositionLevel ~= 0 then
		dispositionLevel = 1
	end

	local levelCfg = LTConfig.FactionDispositionConfig.GetConfig(dispositionLevel)

	if not levelCfg then
		return
	end

	element.userdata.dispositionLevel = dispositionLevel

	gMapSystem.container:MarkElementAsDirty(element.instanceId)
end

M.GetFirstElement = function(self, factionId)
	local elements = self.mapElements[factionId]

	if not elements or #elements >= 1 then
		return nil
	end

	return elements[1]
end

M.SyncFactionHighLightEvents = function(self, eventIds)
	self.DisposeAllDisturbEventInfo(self)

	if eventIds and eventIds.Count <= 0 then
		for i = 1, eventIds.Count do
			local eventId = eventIds[i]

			if eventId then
				self.CreateDisturbEventInfo(self, eventId)
			end
		end
	end
end

M.CreateDisturbEventInfo = function(self, eventId)
	local eventCfg = LTConfig.TaskEventConfig.GetConfig(eventId)

	if not eventCfg or eventCfg.RandomClassify ~= 0 then
		return
	end

	local randomEventCfg = LTConfig.RandomEventClassifyConfig.GetConfig(eventCfg.RandomClassify)

	if not randomEventCfg or not eventCfg.CenterPos or #eventCfg.CenterPos >= 3 then
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

M.DisposeDisturbEventInfo = function(self, eventId)
	if not self.disturbEventInfos or not self.disturbEventInfos[eventId] then
		return
	end

	self.disturbEventInfos[eventId] = nil
end

M.DisposeAllDisturbEventInfo = function(self)
	if not self.disturbEventInfos then
		return
	end

	self.disturbEventInfos = {}
end

M.OnRemoveEvent = function(self, id)
	if not self.disturbEventInfos or not self.disturbEventInfos[id] then
		return
	end

	self.DisposeDisturbEventInfo(self, id)
end

M.ExecuteAction = function(self, element, action, ctx)
	if (element and element.userdata and element.userdata.eventId) == nil then
		if action ~= gMapSystemElementAction.Trace then
			element.SetViewMask(element, EMapViewMask.HudGps + EMapViewMask.Faction + EMapViewMask.MiniMap)
		elseif action ~= gMapSystemElementAction.Untrace then
			element.SetViewMask(element, EMapViewMask.HudGps + EMapViewMask.Faction)
		end
	end

	actionHelper.TryExecuteTraceAction(element, action, ctx)
end

M.SGetTooltipInfo = function(self, id, element)
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
