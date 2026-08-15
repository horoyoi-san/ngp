MapAreaCluster = {}
local M = MapAreaCluster
M.__index = M
M._instancePool = {}

function M.New(areaIds)
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

function M.Get(areaIds)
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

		if #inst.areaIdList == #areaIds then
			local match = true

			for j = 1, #areaIds do
				if inst.areaIdList[j] ~= areaIds[j] then
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

function M.Init()
	M.BigWorld = M.Get({
		gMapAreaMgr:RawGetAreaId(23300888, 0),
		gMapAreaMgr:RawGetAreaId(23300999, 0)
	})
end

function M:GetResolvedCoord(targetPos, targetAreaId)
	if self.areaIds[targetAreaId] then
		return targetAreaId, targetPos
	end

	local minStepCount = 1000000
	local startAreaId, pos = nil
	local targetRaidId, targetIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(targetAreaId)

	for i = 1, #self.areaIdList do
		local areaId = self.areaIdList[i]
		local startRaidId, startIndoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
		local hasPath, x, y, z, exitRaidId, exitIndoorId, stepCount = LX6.Gps.GpsAreaConnectMgr.LuaTryGetMapAreaExitInfoTo(startRaidId, startIndoorId, targetRaidId, targetIndoorId, nil, nil, nil, nil, nil, nil)

		if hasPath and stepCount < minStepCount then
			minStepCount = stepCount
			startAreaId = areaId
			pos = Vector3.New(x, y, z)
		end
	end

	return startAreaId, pos
end

function M:Contains(areaId)
	return self.areaIds[areaId]
end

function M:IsSingleArea()
	return #self.areaIdList == 1
end

function M:GetFirstAreaId()
	return self.areaIdList[1]
end

function M:ForEachArea(func)
	for i = 1, #self.areaIdList do
		func(self.areaIdList[i])
	end
end
