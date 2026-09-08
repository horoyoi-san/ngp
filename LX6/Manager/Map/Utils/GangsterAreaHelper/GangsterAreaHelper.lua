-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\GangsterAreaHelper\GangsterAreaHelper.lua
-- Decompiled from: 02331_GangsterAreaHelper.lua_9959d488c81d.luajit

require("LX6/Manager/Map/Utils/GangsterAreaHelper/GangsterAreaRenderHandler")

local GangsterAreaTopology = require("LX6/Manager/Map/Utils/GangsterAreaHelper/GangsterAreaTopology")
local FactionConfig = LTConfig.FactionConfig
local PointConfig = LTConfig.FactionAreaPointConfig
local SmallAreaConfig = LTConfig.FactionInfluenceAreaConfig
local Vector2 = Vector2
local MY_GANGSTER = FactionConfig.JiaMuFaction
local UNASSIGNED_FILL_TARGET_OWNER = 0
GangsterAreaHelper = DefClass("GangsterAreaHelper", GangsterAreaHelper)
local M = GangsterAreaHelper

M.ctor = function(self)
	self.points = {}
	self.gangsterElements = {}
	self.ownerByArea = {}
	self.fillTargetAreaIds = {}
	self.fillTargetAreaSet = {}
	self.colorCacheBuilt = false
end

M.OnLogin = function(self, factionInfluenceClientState)
	self.LoadPoints(self)
	self.BuildTopology(self)
	self.InitGangsters(self, factionInfluenceClientState)
	self.RecreateGangsterElements(self)
end

M.Clear = function(self)
	for _, element in pairs(self.gangsterElements) do
		element.Dispose(element)
	end

	table.clear(self.gangsterElements)

	self.colorCacheBuilt = false
end

M.LoadPoints = function(self)
	table.clear(self.points)

	for i = 0, PointConfig.count - 1 do
		local cfg = PointConfig.LoadAt(i)
		local pos = cfg.PosXZ
		self.points[cfg.Id] = Vector2.New(pos.x, pos.y)
	end
end

M.BuildTopology = function(self)
	local areaDefs = {}

	table.clear(self.fillTargetAreaIds)
	table.clear(self.fillTargetAreaSet)

	for i = 0, SmallAreaConfig.count - 1 do
		local cfg = SmallAreaConfig.LoadAt(i)
		local pointIds = {}

		for _, pointId in ipairs(cfg.ContainPoints) do
			pointIds[#pointIds + 1] = pointId
		end

		areaDefs[cfg.Id] = {
			pointIds = pointIds
		}

		if cfg.FactionId ~= 0 then
			self.fillTargetAreaSet[cfg.Id] = true
			self.fillTargetAreaIds[#self.fillTargetAreaIds + 1] = cfg.Id
		end
	end

	table.sort(self.fillTargetAreaIds)

	self.edgeIndex, self.sharedEdges, self.topologyDiagnostics = GangsterAreaTopology.BuildEdgeIndex(areaDefs, self.points)
end

M.InitGangsters = function(self, factionInfluenceClientState)
	self.gangsters = {}
	local gangsterAreaMap = {}

	table.clear(self.ownerByArea)

	for i = 0, SmallAreaConfig.count - 1 do
		local cfg = SmallAreaConfig.LoadAt(i)
		local ownerFactionId = factionInfluenceClientState and factionInfluenceClientState:GetAreaOwner(cfg.Id) or cfg.FactionId

		if ownerFactionId ~= UNASSIGNED_FILL_TARGET_OWNER or FactionConfig.GetConfig(ownerFactionId) then
			gangsterAreaMap[ownerFactionId] = gangsterAreaMap[ownerFactionId] or {}
			gangsterAreaMap[ownerFactionId][cfg.Id] = true
			self.ownerByArea[cfg.Id] = ownerFactionId
		else
			print_error("GangsterAreaHelper: InitGangsters: invalid factionId=" .. tostring(ownerFactionId) .. ", areaId=" .. tostring(cfg.Id))
		end
	end

	for factionId, initAreas in pairs(gangsterAreaMap) do
		self.gangsters[factionId] = GangsterAreaRenderHandler.new(factionId, initAreas, self.points, factionId ~= UNASSIGNED_FILL_TARGET_OWNER)
	end
end

M.EnsureRenderHandler = function(self, factionId)
	local handler = self.gangsters[factionId]

	if handler then
		return handler
	end

	if factionId == UNASSIGNED_FILL_TARGET_OWNER and not FactionConfig.GetConfig(factionId) then
		print_error("GangsterAreaHelper: EnsureRenderHandler: faction config not found, factionId=" .. tostring(factionId))

		return nil
	end

	handler = GangsterAreaRenderHandler.new(factionId, {}, self.points, factionId ~= UNASSIGNED_FILL_TARGET_OWNER)
	self.gangsters[factionId] = handler

	if self.colorCacheBuilt then
		handler.BuildColorWidthCache(handler)
	end

	return handler
end

M.SetAreaOwner = function(self, areaId, ownerFactionId, deferRecreateElements)
	local cfg = SmallAreaConfig.GetConfig(areaId)

	if not cfg then
		print_error("GangsterAreaHelper: SetAreaOwner: area config not found, areaId=" .. tostring(areaId))

		return false
	end

	if not ownerFactionId then
		print_error("GangsterAreaHelper: SetAreaOwner: ownerFactionId is nil, areaId=" .. tostring(areaId))

		return false
	end

	local oldOwnerFactionId = self.ownerByArea[areaId] or cfg.FactionId

	if oldOwnerFactionId ~= ownerFactionId then
		return false
	end

	local oldHandler = self.EnsureRenderHandler(self, oldOwnerFactionId)
	local newHandler = self.EnsureRenderHandler(self, ownerFactionId)

	if not oldHandler or not newHandler then
		return false
	end

	oldHandler.TryRemoveArea(oldHandler, areaId)
	newHandler.TryAddArea(newHandler, areaId)

	self.ownerByArea[areaId] = ownerFactionId

	if not deferRecreateElements then
		self.RecreateGangsterElements(self)
	end

	return true
end

M.GetRenderHandler = function(self, gangsterId)
	return self.gangsters[gangsterId]
end

M.GetAllRenderHandlers = function(self)
	return self.gangsters
end

M.GetSmallAreaBelongGangster = function(self, areaId)
	return self.ownerByArea[areaId]
end

M.GetAreaOwner = function(self, areaId)
	return self.ownerByArea[areaId]
end

M.FindDirectedSharedBoundaryCenter = function(self, attackerFactionId, defenderFactionId)
	if not attackerFactionId or not defenderFactionId or attackerFactionId ~= defenderFactionId then
		return nil, "invalid_faction_pair"
	end

	return GangsterAreaTopology.FindDirectedSharedBoundaryCenter(self.sharedEdges, self.ownerByArea, self.points, attackerFactionId, defenderFactionId)
end

M.IsFillTargetArea = function(self, areaId)
	return self.fillTargetAreaSet[areaId] ~= true
end

M.FillTargetArea = function(self, areaId)
	if not self.IsFillTargetArea(self, areaId) then
		print_error("GangsterAreaHelper: FillTargetArea: invalid areaId=" .. tostring(areaId))

		return false
	end

	return self.SetAreaOwner(self, areaId, MY_GANGSTER)
end

M.GetUnassignedFillTargetOwner = function(self)
	return UNASSIGNED_FILL_TARGET_OWNER
end

M.GetFillTargetAreaIds = function(self)
	local result = {}

	for _, areaId in ipairs(self.fillTargetAreaIds) do
		result[#result + 1] = areaId
	end

	return result
end

M.RecreateGangsterElements = function(self)
	for _, element in pairs(self.gangsterElements) do
		element.Dispose(element)
	end

	table.clear(self.gangsterElements)

	for gangsterId, handler in pairs(self.gangsters) do
		local elemIndex = 0
		local gangsterCfg = FactionConfig.GetConfig(gangsterId)

		if gangsterCfg then
			for _, areaGroup in pairs(handler.areaGroups) do
				if gangsterId ~= MY_GANGSTER and not handler.IsMyInitAreaGroup(handler, areaGroup) then
					-- Nothing
				else
					local pos = handler.GetMidOfAreaGroup(handler, areaGroup)

					if not pos then
						print_error("GangsterAreaHelper: RecreateGangsterElements: gangsterId=" .. gangsterId .. " failed to calculate area center")
					else
						elemIndex = elemIndex + 1
						local element = MapElement.CreateLegacy(EMapElementType.Gangster, "GangsterCenter_" .. gangsterId .. elemIndex, EMapSubSystemType.Gangster, EMapViewMask.Gangster + EMapViewMask.HudGps, 23300888)
						element.fData.ignoreFog = false
						element.fData.bigMapTIndex = 6
						element.mData.sIconId = gangsterCfg.imageId
						element.userdata = {
							["\\xa2\\xa2&\\xaed*\\xfb!"] = true,
							gangsterId = gangsterId
						}

						element:SetPosition(pos)
						element:SetVisible(true)

						element.bigMapData.customRenderFuncKey = "OnCustomRenderGangsterIcon"
						element.bigMapData.customAddElemFuncKey = "OnCustomAddGangsterIcon"
						element.mData.lName = GpsLText.CreateCommonText(gangsterCfg, "name", gangsterCfg.name)

						gMapSubSystemUtils:SetupScaleLevel(element, 2, nil)
						table.insert(self.gangsterElements, element)
					end
				end
			end
		end
	end
end

M.BuildColorWidthCache = function(self)
	self.colorCacheBuilt = true

	for _, handler in pairs(self.gangsters) do
		handler.BuildColorWidthCache(handler)
	end
end

M.ClearColorWidthCache = function(self)
	self.colorCacheBuilt = false

	for _, handler in pairs(self.gangsters) do
		handler.ClearColorWidthCache(handler)
	end
end
