-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_NpcCultivation.lua
-- Decompiled from: 02336_MapSubSystem_NpcCultivation.lua_f56a67264799.luajit

local HangOutCfg = LTConfig.NpcCultivationHangOutConfig
local HangOutMapCfg = LTConfig.NpcCultivationHangOutMapConfig
local IndoorCfg = LTConfig.IndoorConfig
local FunctionPointCfg = LTConfig.IndoorMapFunctionPointConfig
local GAMEPLAY_HIGHLIGHT_ID_PREFIX = "Gameplay_"
MapSubSystem_NpcCultivation = DefClass("MapSubSystem_NpcCultivation", MapSubSystem_NpcCultivation, MapSubSystemBase)
local M = MapSubSystem_NpcCultivation

M.OnInit = function(self)
	self._hangOutElements = {}
	self._hiddenIndoorInfos = {}
	self._hiddenFpInfos = {}
	self._npcIdToHangOutRow = {}
	self._eventIdToMapRows = {}
	self._gameplayTypeIdToMapRows = {}
	self._gameplayHangOutElements = {}
	self._gameplayHiddenIndoorInfos = {}
	self._gameplayHiddenFpInfos = {}
	self._enabled = false
	self._npcCultivationId = 0
	self._gameplayTypeId = 0
	self._inviteRideNpcInterestInstanceId = nil
	self._inviteRideNpcInterestOwned = false
	self._inviteRideNpcInterestElement = nil
end

M.OnLogout = function(self)
	self.ClearAll(self)
	self.ClearGameplayHighlight(self)
end

M.OnLoadData = function(self)
	self._BuildCache(self)
end

M._BuildCache = function(self)
	self._npcIdToHangOutRow = {}

	for i = 0, HangOutCfg.count - 1 do
		local cfg = HangOutCfg.LoadAt(i)

		if cfg and cfg.NpcCultivationId and cfg.NpcCultivationId == 0 then
			self._npcIdToHangOutRow[cfg.NpcCultivationId] = cfg
		end
	end

	self._eventIdToMapRows = {}
	self._gameplayTypeIdToMapRows = {}

	for i = 0, HangOutMapCfg.count - 1 do
		local cfg = HangOutMapCfg.LoadAt(i)

		if cfg and cfg.EventId and cfg.EventId == 0 then
			local rows = self._eventIdToMapRows[cfg.EventId]

			if not rows then
				rows = {}
				self._eventIdToMapRows[cfg.EventId] = rows
			end

			rows[#rows + 1] = cfg
		end

		if cfg then
			self.CacheGameplayMapRow(self, cfg)
		end
	end
end

M.CacheGameplayMapRow = function(self, mapCfg)
	local seenGameplayIds = {}
	local hasRefGameplayList = false

	if mapCfg.IndoorId and mapCfg.IndoorId == 0 then
		local indoorCfg = IndoorCfg.GetConfig(mapCfg.IndoorId)
		hasRefGameplayList = self:AddGameplayMapRowsFromList(indoorCfg and indoorCfg.GameplayList, mapCfg, seenGameplayIds) or hasRefGameplayList
	end

	if mapCfg.MapFunctionPointId and mapCfg.MapFunctionPointId == 0 then
		local fpCfg = FunctionPointCfg.GetConfig(mapCfg.MapFunctionPointId)
		hasRefGameplayList = self:AddGameplayMapRowsFromList(fpCfg and fpCfg.GameplayList, mapCfg, seenGameplayIds) or hasRefGameplayList
	end

	if not hasRefGameplayList and (not mapCfg.IndoorId or mapCfg.IndoorId ~= 0) and (not mapCfg.MapFunctionPointId or mapCfg.MapFunctionPointId ~= 0) then
		self.AddGameplayMapRowsFromList(self, mapCfg.GameplayList, mapCfg, seenGameplayIds)
	end
end

M.AddGameplayMapRowsFromList = function(self, gameplayList, mapCfg, seenGameplayIds)
	if type(gameplayList) == "table" then
		return false
	end

	local hasGameplayId = false

	for i = 1, #gameplayList do
		local gameplayTypeId = gameplayList[i]

		if gameplayTypeId and gameplayTypeId == 0 then
			self.AddGameplayMapRow(self, gameplayTypeId, mapCfg, seenGameplayIds)

			hasGameplayId = true
		end
	end

	return hasGameplayId
end

M.AddGameplayMapRow = function(self, gameplayTypeId, mapCfg, seenGameplayIds)
	if seenGameplayIds then
		if seenGameplayIds[gameplayTypeId] then
			return
		end

		seenGameplayIds[gameplayTypeId] = true
	end

	local rows = self._gameplayTypeIdToMapRows[gameplayTypeId]

	if not rows then
		rows = {}
		self._gameplayTypeIdToMapRows[gameplayTypeId] = rows
	end

	rows[#rows + 1] = mapCfg
end

M.EnableInviteRideHighlight = function(self, enable, npcCultivationId)
	if enable and npcCultivationId and npcCultivationId == 0 then
		if self._enabled and self._npcCultivationId ~= npcCultivationId then
			return
		end

		self.ShowHighlight(self, npcCultivationId)
	else
		self.ClearAll(self)
	end
end

M.OnBigMapOpen = function(self)
	self.SyncInviteRideNpcMapInterest(self)
end

M.GetInviteRideNpcAgentTag = function(self, npcCultivationId)
	if not npcCultivationId or npcCultivationId ~= 0 then
		return nil
	end

	for i = 0, LTConfig.AgentDataSetsActivityConfig.count - 1 do
		local cfg = LTConfig.AgentDataSetsActivityConfig.LoadAt(i)

		if cfg and cfg.NpccultivationId ~= npcCultivationId then
			return cfg.AgentTag
		end
	end

	return nil
end

M.GetInviteRideNpcMapElement = function(self, npcCultivationId)
	local agentTag = self.GetInviteRideNpcAgentTag(self, npcCultivationId)

	if not agentTag then
		return nil
	end

	local spiritSubSystem = gMapSubSystem_SpiritAcquisition

	return spiritSubSystem and spiritSubSystem.spiritNpcs and spiritSubSystem.spiritNpcs[agentTag] or nil
end

M.RefreshInviteRideNpcMapInterestFilter = function(self, instanceId)
	local bigMapStore = gStoreManager and gStoreManager:GetStoreGroup("NewMapPanelStore")

	if bigMapStore and bigMapStore.mapView and bigMapStore.CheckElementFilter then
		bigMapStore.CheckElementFilter(bigMapStore, instanceId)
	end
end

M.SyncInviteRideNpcMapInterest = function(self)
	if not self._enabled or self._npcCultivationId ~= 0 then
		self.ClearInviteRideNpcMapInterest(self)

		return false
	end

	local source = gMapSystem and gMapSystem.ui and gMapSystem.ui.bigMapInterestSource

	if not source then
		return false
	end

	local element = self.GetInviteRideNpcMapElement(self, self._npcCultivationId)

	if not element or element.isDestroyed or not element.instanceId then
		return false
	end

	local instanceId = element.instanceId

	if self._inviteRideNpcInterestInstanceId ~= instanceId and source.elems and source.elems[instanceId] then
		self.RefreshInviteRideNpcMapInterestFilter(self, instanceId)

		return true
	end

	if self._inviteRideNpcInterestInstanceId == instanceId then
		self.ClearInviteRideNpcMapInterest(self)
	end

	if not source.elems or not source.elems[instanceId] then
		source.AddElement(source, instanceId)

		self._inviteRideNpcInterestOwned = true
	end

	self._inviteRideNpcInterestInstanceId = instanceId

	if self._inviteRideNpcInterestOwned then
		element.bigMapData.inviteRideRespectFriendFilter = true
		self._inviteRideNpcInterestElement = element
	end

	self.RefreshInviteRideNpcMapInterestFilter(self, instanceId)

	return true
end

M.ClearInviteRideNpcMapInterest = function(self)
	local instanceId = self._inviteRideNpcInterestInstanceId

	if not instanceId then
		self._inviteRideNpcInterestOwned = false
		self._inviteRideNpcInterestElement = nil

		return
	end

	local source = gMapSystem and gMapSystem.ui and gMapSystem.ui.bigMapInterestSource

	if self._inviteRideNpcInterestElement and self._inviteRideNpcInterestElement.bigMapData then
		self._inviteRideNpcInterestElement.bigMapData.inviteRideRespectFriendFilter = nil
	end

	if self._inviteRideNpcInterestOwned and source and source.elems and source.elems[instanceId] then
		source.RemoveElement(source, instanceId)
		self.RefreshInviteRideNpcMapInterestFilter(self, instanceId)
	end

	self._inviteRideNpcInterestInstanceId = nil
	self._inviteRideNpcInterestOwned = false
	self._inviteRideNpcInterestElement = nil
end

M.ShowHighlight = function(self, npcCultivationId)
	self.ClearAll(self)

	local hangOutRow = self._npcIdToHangOutRow[npcCultivationId]

	if not hangOutRow then
		print_error("[NpcCultivation] HangOut not found NpcCultivationId=" .. tostring(npcCultivationId))

		return
	end

	self._enabled = true
	self._npcCultivationId = npcCultivationId

	self.SyncInviteRideNpcMapInterest(self)

	local allEventIds = {}
	local seen = {}

	self.CollectEventIds(self, hangOutRow.GameplayEventId, allEventIds, seen)
	self.CollectEventIds(self, hangOutRow.CommonPOIEventId, allEventIds, seen)
	self.CollectEventIds(self, hangOutRow.ExclusivePOIEventId, allEventIds, seen)

	for _, eventId in ipairs(allEventIds) do
		local rows = self._eventIdToMapRows[eventId]

		if rows then
			for _, mapCfg in ipairs(rows) do
				self.ProcessHangOutMapRow(self, mapCfg)
			end
		end
	end
end

M.CollectEventIds = function(self, eventIdArray, outList, seen)
	if not eventIdArray then
		return
	end

	for i = 1, #eventIdArray do
		local eid = eventIdArray[i]

		if eid and eid == 0 and not seen[eid] then
			seen[eid] = true
			outList[#outList + 1] = eid
		end
	end
end

M.ProcessHangOutMapRow = function(self, mapCfg)
	self.ProcessHangOutMapRowTo(self, mapCfg, self._hangOutElements, self._hiddenIndoorInfos, self._hiddenFpInfos)
end

M.OpenGameplayHighlight = function(self, gameplayTypeId)
	if not self.ShowGameplayHighlight(self, gameplayTypeId) then
		return false
	end

	local params = {
		OnClose = function ()
			self:ClearGameplayHighlight(true)
		end
	}
	local currentCountryElements = {}
	local currentCountryId = gMapSystem and gMapSystem.GetCurCountryId and gMapSystem:GetCurCountryId()

	for _, info in pairs(self._gameplayHangOutElements) do
		local element = info.element

		if element and not element.isDestroyed then
			local parentRaidId = gMapManager and gMapManager.GetParentRaidId and gMapManager:GetParentRaidId(element.raidId) or element.raidId
			local raidCfg = LTConfig.RaidConfig.GetConfig(parentRaidId)

			if raidCfg and raidCfg.CountryId ~= currentCountryId then
				currentCountryElements[#currentCountryElements + 1] = element
			end
		end
	end

	params.unhighlightedIconScaleStateLimit = EBigMapIconScaleState.Thumbnail

	if #currentCountryElements <= 0 then
		params.autoSelectGpsId = currentCountryElements[math.random(1, #currentCountryElements)].gpsId
	end

	if not gMapUtils or not gMapUtils.CheckRaidCanOpenMap then
		self.ClearGameplayHighlight(self)

		return false
	end

	local opened = gMapUtils:CheckRaidCanOpenMap(params)

	if not opened then
		self.ClearGameplayHighlight(self)
	end

	return opened
end

M.ShowGameplayHighlight = function(self, gameplayTypeId)
	self.ClearGameplayHighlight(self)

	if not gameplayTypeId or gameplayTypeId ~= 0 then
		return false
	end

	local rows = self._gameplayTypeIdToMapRows[gameplayTypeId]

	if not rows then
		return false
	end

	self._gameplayTypeId = gameplayTypeId

	for _, mapCfg in ipairs(rows) do
		self.ProcessGameplayMapRow(self, mapCfg)
	end

	return next(self._gameplayHangOutElements) == nil
end

M.ProcessGameplayMapRow = function(self, mapCfg)
	self.ProcessHangOutMapRowTo(self, mapCfg, self._gameplayHangOutElements, self._gameplayHiddenIndoorInfos, self._gameplayHiddenFpInfos, GAMEPLAY_HIGHLIGHT_ID_PREFIX .. mapCfg.Id)
end

M.ProcessHangOutMapRowTo = function(self, mapCfg, hangOutElements, hiddenIndoorInfos, hiddenFpInfos, elementId)
	if not mapCfg.Coordinate or #mapCfg.Coordinate >= 3 then
		print_error("MapSubSystem_NpcCultivation: HangOutMap Id=" .. tostring(mapCfg.Id) .. " Coordinate invalid")

		return
	end

	self.HideOldIconTo(self, mapCfg.IndoorId, mapCfg.MapFunctionPointId, hiddenIndoorInfos, hiddenFpInfos)

	local element = self.CreateHangOutElement(self, mapCfg, elementId)

	if element then
		hangOutElements[element.gpsId] = {
			element = element,
			hangOutMapId = mapCfg.Id
		}
	end
end

M.HideOldIcon = function(self, indoorId, mapFunctionPointId)
	self.HideOldIconTo(self, indoorId, mapFunctionPointId, self._hiddenIndoorInfos, self._hiddenFpInfos)
end

M.HideOldIconTo = function(self, indoorId, mapFunctionPointId, hiddenIndoorInfos, hiddenFpInfos)
	local fpSubSystem = gMapSubSystem_FunctionPoint

	if not fpSubSystem then
		print_error("[NpcCultivation] gMapSubSystem_FunctionPoint is nil, cannot hide old icons")

		return
	end

	if indoorId and indoorId == 0 then
		local info = fpSubSystem.indoorInfos and fpSubSystem.indoorInfos[indoorId]

		if info and info.mapElement then
			info.mapElement:SetVisible(false)

			hiddenIndoorInfos[indoorId] = info
			fpSubSystem.indoorInfos[indoorId] = nil
		end
	end

	if mapFunctionPointId and mapFunctionPointId == 0 then
		local info = fpSubSystem.functionPointInfos and fpSubSystem.functionPointInfos[mapFunctionPointId]

		if info and info.mapElement then
			info.mapElement:SetVisible(false)

			hiddenFpInfos[mapFunctionPointId] = info
			fpSubSystem.functionPointInfos[mapFunctionPointId] = nil
		end
	end
end

M.CreateHangOutElement = function(self, mapCfg, elementId)
	local coord = mapCfg.Coordinate
	local worldPos = Vector3.New(coord[1], coord[2], coord[3])
	local raidId = self:ResolveHangOutMapRaidId(mapCfg)
	local element = MapElement.CreateLegacy(EMapElementType.InviteRide, elementId or mapCfg.Id, EMapSubSystemType.NpcCultivation, EMapViewMask.AllSgui, raidId)

	if not element then
		print_error("[NpcCultivation] CreateLegacy failed, HangOutMapId=" .. tostring(mapCfg.Id))

		return nil
	end

	if mapCfg.IndoorId and mapCfg.IndoorId == 0 then
		element.SetOverrideBoundInfo(element, 0, 0)

		if element.fData then
			element.fData.representGBoundId = gMapSystem.area:GetGBoundId(raidId, mapCfg.IndoorId, 0)
		end
	end

	element.SetPosition(element, worldPos)

	element.gpsData.removeGpsRange = LTConfig.NpcCultivationConfig.HangOutPointAutoRemoveGpsRange

	element.SetVisible(element, true)
	element.SetActions(element, self.NormalTraceableActions)

	element.mData.sIconId = mapCfg.InviteRideHighlightIconId
	element.bigMapData.iconScaleType = 1
	element.bigMapData.isIconHighlight = true
	local highlightScale = LTConfig.GpsConfig.InviteRideHighlightIconScale

	if highlightScale and highlightScale <= 0 then
		element.mData.scaleFactor = highlightScale
	end

	element.mData.lName = self.GetElementName(self, mapCfg)
	element.userdata = {
		["n;m^"] = "{[\\xc0\\xba\\xab\\xac)\\xc8\\xf8",
		hangOutMapId = mapCfg.Id,
		indoorId = mapCfg.IndoorId,
		mapFunctionPointId = mapCfg.MapFunctionPointId
	}

	return element
end

M.ResolveHangOutMapRaidId = function(self, mapCfg)
	if mapCfg.IndoorId and mapCfg.IndoorId == 0 then
		local indoorCfg = IndoorCfg.GetConfig(mapCfg.IndoorId)

		if indoorCfg and indoorCfg.ParentRaid and indoorCfg.ParentRaid <= 0 then
			return indoorCfg.ParentRaid
		end
	end

	if mapCfg.MapFunctionPointId and mapCfg.MapFunctionPointId == 0 then
		local fpCfg = FunctionPointCfg.GetConfig(mapCfg.MapFunctionPointId)

		if fpCfg and fpCfg.RaidId and fpCfg.RaidId <= 0 then
			return fpCfg.RaidId
		end
	end

	if mapCfg.raidId and mapCfg.raidId <= 0 then
		return mapCfg.raidId
	end

	return LTConfig.RaidConfig.WorldMap
end

M.GetElementName = function(self, mapCfg)
	if mapCfg.IndoorId and mapCfg.IndoorId == 0 then
		local indoorCfg = IndoorCfg.GetConfig(mapCfg.IndoorId)

		if indoorCfg then
			return GpsLText.CreateCommonText(indoorCfg, "Name")
		end
	end

	if mapCfg.MapFunctionPointId and mapCfg.MapFunctionPointId == 0 then
		local fpCfg = FunctionPointCfg.GetConfig(mapCfg.MapFunctionPointId)

		if fpCfg then
			return GpsLText.CreateCommonText(fpCfg, "Name")
		end
	end

	return GpsLText.CreateCommonText(mapCfg, "Name")
end

M.ClearAll = function(self)
	self.ClearInviteRideNpcMapInterest(self)

	self._enabled = false
	self._npcCultivationId = 0

	self.DisposeHangOutElements(self, self._hangOutElements)
	self.RestoreHiddenIcons(self, self._hiddenIndoorInfos, self._hiddenFpInfos)
end

M.ClearGameplayHighlight = function(self, preserveTracing)
	self._gameplayTypeId = 0
	local gpsIds = {}

	for gpsId, _ in pairs(self._gameplayHangOutElements) do
		gpsIds[#gpsIds + 1] = gpsId
	end

	for _, gpsId in ipairs(gpsIds) do
		local info = self._gameplayHangOutElements[gpsId]

		if info then
			if preserveTracing and self.IsGameplayHighlightTracing(self, info) then
				info.preservedAfterClose = true
			else
				self.ClearGameplayHangOutElement(self, gpsId, info, true)
			end
		end
	end

	if not preserveTracing or not next(self._gameplayHangOutElements) then
		self.RestoreHiddenIcons(self, self._gameplayHiddenIndoorInfos, self._gameplayHiddenFpInfos)
	end
end

M.IsGameplayHighlightTracing = function(self, info)
	local element = info and info.element

	if not element then
		return false
	end

	if element.traceInfo then
		return true
	end

	return gMapSystem and gMapSystem.trace and gMapSystem.trace.mainTraceGpsId ~= element.gpsId
end

M.ClearGameplayHangOutElement = function(self, gpsId, info, restoreHiddenIcon)
	if self._gameplayHangOutElements[gpsId] ~= info then
		self._gameplayHangOutElements[gpsId] = nil
	end

	local element = info and info.element

	if restoreHiddenIcon then
		self.RestoreHiddenIconForGameplayElement(self, gpsId, element)
	end

	if element then
		element.Dispose(element)
	end
end

M.RestoreHiddenIconForGameplayElement = function(self, gpsId, element)
	local userdata = element and element.userdata

	if not userdata then
		return
	end

	local indoorId = userdata.indoorId

	if indoorId and indoorId == 0 and not self.HasOtherGameplayElementUsingIndoor(self, gpsId, indoorId) then
		self.RestoreHiddenIndoorIcon(self, indoorId, self._gameplayHiddenIndoorInfos)
	end

	local fpId = userdata.mapFunctionPointId

	if fpId and fpId == 0 and not self.HasOtherGameplayElementUsingFunctionPoint(self, gpsId, fpId) then
		self.RestoreHiddenFunctionPointIcon(self, fpId, self._gameplayHiddenFpInfos)
	end
end

M.HasOtherGameplayElementUsingIndoor = function(self, gpsId, indoorId)
	for otherGpsId, info in pairs(self._gameplayHangOutElements) do
		local userdata = info.element and info.element.userdata

		if otherGpsId == gpsId and userdata and userdata.indoorId ~= indoorId then
			return true
		end
	end

	return false
end

M.HasOtherGameplayElementUsingFunctionPoint = function(self, gpsId, fpId)
	for otherGpsId, info in pairs(self._gameplayHangOutElements) do
		local userdata = info.element and info.element.userdata

		if otherGpsId == gpsId and userdata and userdata.mapFunctionPointId ~= fpId then
			return true
		end
	end

	return false
end

M.DisposeHangOutElements = function(self, hangOutElements)
	for _, info in pairs(hangOutElements) do
		if info.element then
			info.element:Dispose()
		end
	end

	table.clear(hangOutElements)
end

M.RestoreHiddenIndoorIcon = function(self, indoorId, hiddenIndoorInfos)
	local info = hiddenIndoorInfos[indoorId]

	if not info then
		return
	end

	if info.mapElement and not info.mapElement.isDestroyed then
		info.mapElement:SetVisible(true)

		local fpSubSystem = gMapSubSystem_FunctionPoint

		if fpSubSystem and fpSubSystem.indoorInfos then
			fpSubSystem.indoorInfos[indoorId] = info
		end
	end

	hiddenIndoorInfos[indoorId] = nil
end

M.RestoreHiddenFunctionPointIcon = function(self, fpId, hiddenFpInfos)
	local info = hiddenFpInfos[fpId]

	if not info then
		return
	end

	if info.mapElement and not info.mapElement.isDestroyed then
		info.mapElement:SetVisible(true)

		local fpSubSystem = gMapSubSystem_FunctionPoint

		if fpSubSystem and fpSubSystem.functionPointInfos then
			fpSubSystem.functionPointInfos[fpId] = info
		end
	end

	hiddenFpInfos[fpId] = nil
end

M.RestoreHiddenIcons = function(self, hiddenIndoorInfos, hiddenFpInfos)
	local indoorIds = {}

	for indoorId, _ in pairs(hiddenIndoorInfos) do
		indoorIds[#indoorIds + 1] = indoorId
	end

	for _, indoorId in ipairs(indoorIds) do
		self.RestoreHiddenIndoorIcon(self, indoorId, hiddenIndoorInfos)
	end

	local fpIds = {}

	for fpId, _ in pairs(hiddenFpInfos) do
		fpIds[#fpIds + 1] = fpId
	end

	for _, fpId in ipairs(fpIds) do
		self.RestoreHiddenFunctionPointIcon(self, fpId, hiddenFpInfos)
	end
end

M.SGetTooltipInfo = function(self, id, element)
	if not element or not element.userdata or element.userdata.type == "HangOutMap" then
		return nil
	end

	local ud = element.userdata

	if ud.indoorId and ud.indoorId == 0 then
		local indoorCfg = IndoorCfg.GetConfig(ud.indoorId)

		if indoorCfg then
			local shopTypeCfg = nil

			if indoorCfg.ShopType and indoorCfg.ShopType <= 0 then
				shopTypeCfg = LTConfig.IndoorShopTypeConfig.GetConfig(indoorCfg.ShopType)
			end

			local subtitle = shopTypeCfg and shopTypeCfg.TypeName or ""

			return {
				type = EMapTooltipType.Indoor,
				header = {
					name = indoorCfg.Name,
					imageId = indoorCfg.SImageId,
					subtitle = subtitle
				},
				indoorInfo = {
					["ZTʲ\\x8b\\x8c\\xd9\\xed"] = 0,
					id = indoorCfg.Id,
					factionId = indoorCfg.FactionId and indoorCfg.FactionId <= 0 and indoorCfg.FactionId or nil
				}
			}
		end
	end

	if ud.mapFunctionPointId and ud.mapFunctionPointId == 0 then
		local fpCfg = FunctionPointCfg.GetConfig(ud.mapFunctionPointId)

		if fpCfg then
			return {
				type = EMapTooltipType.Indoor,
				header = {
					name = fpCfg.Name,
					imageId = fpCfg.SImageId
				},
				indoorInfo = {
					["ZTʲ\\x8b\\x8c\\xd9\\xed"] = 1,
					id = fpCfg.Id
				}
			}
		end
	end

	local mapCfg = HangOutMapCfg.GetConfig(ud.hangOutMapId)

	if mapCfg then
		return {
			type = EMapTooltipType.Common,
			header = {
				name = mapCfg.Name,
				imageId = mapCfg.SImageId or 0
			},
			commonInfo = {
				desc = mapCfg.Information or ""
			}
		}
	end

	return {
		type = EMapTooltipType.Common,
		header = {
			["\\xd0\\xd6\r\\xf5"] = 0,
			name = element:GetName() or ""
		},
		commonInfo = {
			["~'nX"] = ""
		}
	}
end

M.ExecuteAction = function(self, element, action)
	local actionHelper = require("LX6/Manager/Map/MapSubSystem/MapSubSystemActionHelper")

	actionHelper.TryExecuteTraceAction(element, action)
end

M.OnClearTrace = function(self, element)
	if not element or not element.gpsId then
		return
	end

	local info = self._gameplayHangOutElements[element.gpsId]

	if info and info.preservedAfterClose then
		self.ClearGameplayHangOutElement(self, element.gpsId, info, true)
	end
end

return M
