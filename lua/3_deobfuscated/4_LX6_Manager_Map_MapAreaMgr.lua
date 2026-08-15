local RaidConfig = LTConfig.RaidConfig
gMapSystem_Area = gMapSystem_Area or {}
gMapAreaMgr = gMapSystem_Area
local M = gMapSystem_Area
local BoundDecDigitCount = 3
local IndoorDecDigitCount = 5
local RaidMin = 23000000
local IndoorBase = 10^BoundDecDigitCount
local RaidBase = 10^(BoundDecDigitCount + IndoorDecDigitCount)

function M:Init()
	self.pathCache = {}

	self:CreateAllContainer()
	MapAreaCluster.Init()
end

function M:GetBound(gBoundId)
	if not gBoundId or gBoundId == 0 then
		return nil
	end

	return self.bounds[gBoundId]
end

function M:GetAreaId(raidId, indoorId)
	raidId = raidId or 0
	indoorId = indoorId or 0

	if indoorId ~= 0 then
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

function M:RawGetAreaId(raidId, indoorId)
	return self:GetGBoundId(raidId, indoorId, 0)
end

function M:GetAreaIdByGBoundId(gBoundId)
	return math.floor(gBoundId / IndoorBase) * IndoorBase
end

function M:SplitAreaId(areaId)
	local raidId, indoorId = self:SplitGBoundId(areaId)

	return raidId, indoorId
end

function M:GetGBoundId(raidId, indoorId, localBoundId)
	localBoundId = localBoundId or 0
	raidId = raidId or 0
	indoorId = indoorId or 0
	raidId = raidId < RaidMin and 0 or raidId - RaidMin
	local id = raidId * RaidBase + indoorId * IndoorBase + localBoundId

	return id
end

function M:SplitGBoundId(gBoundId)
	if not gBoundId then
		print_error("SplitGBoundId: gBoundId is nil")

		return 0, 0, 0
	end

	local localBoundId = gBoundId % IndoorBase
	local indoorId = math.floor(gBoundId % RaidBase / IndoorBase)
	local raidId = math.floor(gBoundId / RaidBase)

	if raidId > 0 then
		raidId = raidId + RaidMin
	else
		raidId = 0
	end

	return raidId, indoorId, localBoundId
end

function M:GetRaidIdAndIndoorId(areaId)
	local area = self.areas[areaId]

	if not area then
		return 0, 0
	end

	return area.raidId, area.indoorId
end

function M:GetResolvedPos(pos, objAreaId, obsAreaId)
	if not objAreaId then
		print_error("GetResolvedPos: objAreaId is nil")

		return nil
	end

	if objAreaId == obsAreaId then
		return pos
	end

	local obRaidId, obIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(obsAreaId)
	local targetRaidId, targetIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(objAreaId)
	local success, x, y, z = LX6.Gps.GpsAreaConnectMgr.LuaTryGetMapAreaExitPosTo(obRaidId, obIndoorId, targetRaidId, targetIndoorId, nil, nil, nil)

	if not success then
		return nil
	end

	return Vector3.New(x, y, z)
end

function M:IsBigWorldAreaId(areaId)
	return areaId == self.XinQiAreaId or areaId == self.ChongXiaoAreaId
end

function M:IsBigWorldRaidId(raidId)
	return raidId == RaidConfig.WorldMap or raidId == RaidConfig.Chongxiao
end

function M:CreateAllContainer()
	self:CreateAllMapAreaContainer()
	self:CreateAllBoundContainer()
end

function M:CreateAllMapAreaContainer()
	self.areas = {}
	self.indoorId2AreaId = {}
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
		local area = MapArea.New(raidId, indoorId)
		self.areas[area.id] = area
		self.indoorId2AreaId[indoorId] = area.id

		if raidId ~= RaidConfig.WorldMap and raidId ~= RaidConfig.Chongxiao then
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

function M:GetBound(gBoundId)
	if not gBoundId or gBoundId == 0 then
		return nil
	end

	return self.bounds[gBoundId]
end

function M:CreateAllBoundContainer()
	self.bounds = {}
	local boundIds = {}

	for areaId, area in pairs(self.areas) do
		if areaId == 0 then
			-- Nothing
		else
			local raidId, indoorId = gMapAreaMgr:SplitAreaId(areaId)

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
