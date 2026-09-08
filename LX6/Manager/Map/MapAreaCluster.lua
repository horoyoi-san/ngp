-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapAreaCluster.lua
-- Decompiled from: 00199_MapAreaCluster.lua_311f827fc820.luajit

MapAreaCluster = {}
local M = MapAreaCluster
M.__index = M
M._instancePool = {}

M.New = function(areaIds)
	local inst = {
		areaIds = {},
		areaIdList = {}
	}

	for i = 1, #areaIds do
		inst.areaIds[areaIds[i]] = true
		inst.areaIdList[i] = areaIds[i]
	end

	table.sort(inst.areaIdList)

	return setmetatable(inst, M)
end

M.Get = function(areaIds)
	local hash = 0

	for i = 1, #areaIds do
		hash = (hash + areaIds[i] * 31) % 1000000007
	end

	local bucket = M._instancePool[hash]

	if not bucket then
		bucket = {}
		M._instancePool[hash] = bucket
	end

	table.sort(areaIds)

	for i = 1, #bucket do
		local inst = bucket[i]

		if #inst.areaIdList ~= #areaIds then
			local match = true

			for j = 1, #areaIds do
				if inst.areaIdList[j] == areaIds[j] then
					match = false

					break
				end
			end

			if match then
				return inst
			end
		end
	end

	local inst = M.New(areaIds)

	table.insert(bucket, inst)

	return inst
end

M.Init = function()
	M.UpdateBigWorld()
end

M.UpdateBigWorld = function()
	local areaIds = {}

	for i = 0, LTConfig.CollectionCountryConfig.count - 1 do
		local cfg = LTConfig.CollectionCountryConfig.LoadAt(i)

		if cfg.RaidId then
			local areaId = gMapAreaMgr:RawGetAreaId(cfg.RaidId, 0)

			if cfg.SystemUnlockId ~= 0 or gSystemUnlockMgr:IsUnlock(cfg.SystemUnlockId) then
				table.insert(areaIds, areaId)
			end
		end
	end

	M.BigWorld = M.Get(areaIds)
end

M.GetResolvedCoord = function(self, targetPos, targetAreaId)
	if self.areaIds[targetAreaId] then
		return targetAreaId, targetPos
	end

	local minStepCount = 1000000
	local startAreaId, pos = nil
	local targetRaidId, targetIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(targetAreaId)

	for i = 1, #self.areaIdList do
		local areaId = self.areaIdList[i]
		local startRaidId, startIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
		local hasPath, x, y, z, exitRaidId, exitIndoorId, stepCount = LX6.Gps.GpsAreaConnectMgr.LuaTryGetMapAreaExitInfoTo(startRaidId, startIndoorId, targetRaidId, targetIndoorId, nil, , , , , )

		if hasPath and stepCount >= minStepCount then
			minStepCount = stepCount
			startAreaId = areaId
			pos = Vector3.New(x, y, z)
		end
	end

	return startAreaId, pos
end

M.Contains = function(self, areaId)
	return self.areaIds[areaId]
end
