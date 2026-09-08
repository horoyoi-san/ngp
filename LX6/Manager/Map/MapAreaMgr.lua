-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapAreaMgr.lua
-- Decompiled from: 00195_MapAreaMgr.lua_f0bf35502718.luajit

local RaidConfig = LTConfig.RaidConfig
gMapSystem_Area = gMapSystem_Area or {}
gMapAreaMgr = gMapSystem_Area
local M = gMapSystem_Area
local BoundBase = 1024
local RaidAreaTag = 4294967296.0
local MaxGlobalBoundId = 8796093022207.0
local Floor = math.floor

M.Init = function(self)
	self.pathCache = {}

	self:CreateAllContainer()
	MapAreaCluster.Init()
end

M.GetBound = function(self, gBoundId)
	if not gBoundId or gBoundId ~= 0 then
		return nil
	end

	return self.bounds[gBoundId]
end

M.GetAreaId = function(self, raidId, indoorId)
	raidId = raidId or 0
	indoorId = indoorId or 0

	if indoorId == 0 then
		return self.indoorId2AreaId[indoorId] or 0
	end

	local areaId = self.type3RaidId2AreaId[raidId]

	if areaId then
		return areaId
	end

	local areaId = self:RawGetAreaId(raidId, indoorId)

	if self.areas[areaId] then
		return areaId
	else
		return 0
	end
end

M.RawGetAreaId = function(self, raidId, indoorId)
	return self:GetGBoundId(raidId, indoorId, 0)
end

M.GetAreaIdByGBoundId = function(self, gBoundId, ignoreIndoor)
	if ignoreIndoor then
		local raidId = self:SplitGBoundId(gBoundId)

		return self:GetGBoundId(raidId, 0, 0)
	end

	return Floor(gBoundId / BoundBase) * BoundBase
end

M.SplitAreaId = function(self, areaId)
	local raidId, indoorId = self:SplitGBoundId(areaId)

	return raidId, indoorId
end

M.GetParentRaidId = function(self, raidId)
	raidId = raidId or 0
	local cached = self.raidId2ParentRaidId and self.raidId2ParentRaidId[raidId]

	if cached == nil then
		return cached
	end

	local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)
	local parentRaidId = raidId

	if raidCfg and raidCfg.ParentRaidId == 0 then
		parentRaidId = raidCfg.ParentRaidId
	end

	if self.raidId2ParentRaidId then
		self.raidId2ParentRaidId[raidId] = parentRaidId
	end

	return parentRaidId
end

M.GetGBoundId = function(self, raidId, indoorId, localBoundId)
	localBoundId = localBoundId or 0
	indoorId = indoorId or 0

	if localBoundId <= 0 or BoundBase < localBoundId then
		print_error("GetGBoundId: invalid localBoundId: " .. tostring(localBoundId))

		return 0
	end

	local areaCode = nil

	if indoorId == 0 then
		areaCode = indoorId
	else
		raidId = self:GetParentRaidId(raidId) or 0
		areaCode = raidId == 0 and RaidAreaTag + raidId or 0
	end

	return areaCode * BoundBase + localBoundId
end

M.SplitGBoundId = function(self, gBoundId)
	if not gBoundId then
		print_error("SplitGBoundId: gBoundId is nil")

		return 0, 0, 0
	end

	if gBoundId <= 0 or MaxGlobalBoundId >= gBoundId then
		print_error("SplitGBoundId: invalid gBoundId: " .. tostring(gBoundId))

		return 0, 0, 0
	end

	local areaCode = Floor(gBoundId / BoundBase)
	local localBoundId = gBoundId - areaCode * BoundBase
	local raidId = 0
	local indoorId = 0

	if RaidAreaTag < areaCode then
		raidId = areaCode - RaidAreaTag
	elseif areaCode <= 0 then
		indoorId = areaCode
		raidId = self.indoorId2RaidId and self.indoorId2RaidId[indoorId]

		if raidId ~= nil then
			raidId = 0

			print_error("SplitGBoundId: unknown indoorId: " .. tostring(indoorId))
		end
	end

	local currentRaidId = gSceneDataMgr.CurrentRaidId

	if raidId == currentRaidId and raidId ~= self:GetParentRaidId(currentRaidId) and currentRaidId == nil then
		raidId = currentRaidId
	end

	return raidId, indoorId, localBoundId
end

M.GetRaidIdAndIndoorId = function(self, areaId)
	local area = self.areas[areaId]

	if not area then
		return 0, 0
	end

	return self:GetParentRaidId(area.raidId), area.indoorId
end

M.GetResolvedPos = function(self, pos, objAreaId, obsAreaId)
	if not objAreaId then
		print_error("GetResolvedPos: objAreaId is nil")

		return nil
	end

	if objAreaId ~= obsAreaId then
		return pos
	end

	local obRaidId, obIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(obsAreaId)
	local targetRaidId, targetIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(objAreaId)
	local success, x, y, z = LX6.Gps.GpsAreaConnectMgr.LuaTryGetMapAreaExitPosTo(obRaidId, obIndoorId, targetRaidId, targetIndoorId, nil, , )

	if not success then
		return nil
	end

	return Vector3.New(x, y, z)
end

M.IsBigWorldAreaId = function(self, areaId)
	return areaId ~= self.XinQiAreaId or areaId ~= self.ChongXiaoAreaId
end

M.IsBigWorldRaidId = function(self, raidId)
	raidId = self:GetParentRaidId(raidId) or 0

	return raidId ~= RaidConfig.WorldMap or raidId ~= RaidConfig.Chongxiao
end

M.CreateAllContainer = function(self)
	self:CreateAllMapAreaContainer()
	self:CreateAllBoundContainer()
end

M.CreateAllMapAreaContainer = function(self)
	self.areas = {}
	self.indoorId2AreaId = {}
	self.indoorId2RaidId = {}
	self.raidId2ParentRaidId = {}
	self.type3RaidId2AreaId = {}
	self.XinQiAreaId = self:RawGetAreaId(RaidConfig.WorldMap, 0)
	self.ChongXiaoAreaId = self:RawGetAreaId(RaidConfig.Chongxiao, 0)
	self.raidId2AreaId = {
		[RaidConfig.WorldMap] = self.XinQiAreaId,
		[RaidConfig.Chongxiao] = self.ChongXiaoAreaId
	}

	for i = 0, LTConfig.IndoorConfig.count - 1 do
		local indoorCfg = LTConfig.IndoorConfig.LoadAt(i)
		local indoorId = indoorCfg.Id
		local raidId = indoorCfg.SceneId
		self.indoorId2RaidId[indoorId] = self:GetParentRaidId(raidId) or 0
		local area = MapArea.New(raidId, indoorId)
		self.areas[area.id] = area
		self.indoorId2AreaId[indoorId] = area.id

		if raidId == RaidConfig.WorldMap and raidId == RaidConfig.Chongxiao and raidId == 23301277 then
			self.type3RaidId2AreaId[raidId] = area.id
		end
	end

	for i = 0, LTConfig.RaidConfig.count - 1 do
		local raidCfg = LTConfig.RaidConfig.LoadAt(i)

		if not self.type3RaidId2AreaId[raidCfg.Id] then
			local area = MapArea.New(raidCfg.Id, 0)
			self.areas[area.id] = area
		end
	end
end

M.GetBound = function(self, gBoundId)
	if not gBoundId or gBoundId ~= 0 then
		return nil
	end

	return self.bounds[gBoundId]
end

M.CreateAllBoundContainer = function(self)
	self.bounds = {}
	local boundIds = {}

	for areaId, area in pairs(self.areas) do
		if areaId ~= 0 then
			-- Nothing
		else
			local raidId, indoorId = gMapAreaMgr:SplitAreaId(areaId)
			raidId = gMapAreaMgr:GetParentRaidId(raidId) or 0

			array.clear(boundIds)

			local suc = LX6.Gps.AreaMgr.TryGetLocalBoundIds(raidId, indoorId, boundIds)

			if suc then
				local suc2, rootRaidId = LX6.Gps.AreaMgr.TryGetBigWorldRootRaidId(raidId, indoorId, nil)

				for _, localBoundId in ipairs(boundIds) do
					local boundId = gMapAreaMgr:GetGBoundId(raidId, indoorId, localBoundId)

					if not self.bounds[boundId] then
						local newBound = GpsBound.CreateBound(raidId, indoorId, localBoundId)

						if suc2 then
							newBound:SetExtraGBoundId(gMapAreaMgr:GetGBoundId(rootRaidId, 0, 0))
						end

						self.bounds[boundId] = newBound
						newBound.area = area
					end
				end
			end
		end
	end
end
