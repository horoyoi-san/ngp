-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameFishMgr.lua
-- Decompiled from: 00600_FishingGameFishMgr.lua_a9754e66dfac.luajit

C_FishingGameFishMgr = DefClass("C_FishingGameFishMgr", C_FishingGameFishMgr)
local M = C_FishingGameFishMgr
local GameObject = UnityEngine.GameObject

M.ctor = function(self)
	self.resPath = "Res/MiniGame/Prefab/FishingGame/%s.prefab"
	self.fishConfigMap = {}
	self.fishId = 1
	self.fishList = {}
	self.serverFishMap = {}
end

M.Init = function(self, system, container, spotId)
	self.system = system
	self.container = container
	self.spotId = spotId or 0

	self:InitFishConfig()

	local pool = self.spotId == 0 and gFishingGameManager:GetSpotPool(self.spotId) or nil

	if pool and pool.fishes then
		local hasAny = false

		for _, serverFish in pairs(pool.fishes) do
			self.AddFishFromServer(self, serverFish)

			hasAny = true
		end

		if not hasAny then
			self._LocalFallbackInit(self)
		end
	else
		self._LocalFallbackInit(self)
	end
end

M._LocalFallbackInit = function(self)
	for i = 1, 8 do
		self.AddFish(self, FishingGameConfig.FishConfig[1])
	end

	for i = 1, 2 do
		self.AddFish(self, FishingGameConfig.FishConfig[2])
	end
end

M.Update = function(self)
	self.CheckHitFish(self)
	self.CheckFish(self)
end

M.Clear = function(self)
	local len = #self.fishList

	for i = 1, len do
		self.fishList[i]:Clear()
	end
end

M.Destroy = function(self)
	self.Clear(self)

	local len = #self.fishList

	for i = 1, len do
		self.fishList[i]:Destroy()
	end

	self.fishList = {}
	self.serverFishMap = {}
end

M.AddHit = function(self, hit)
	local fish = nil
	local len = #self.fishList

	for i = 1, len do
		fish = self.fishList[i]

		if fish.isAttract then
			fish.data.hit = fish.data.hit + hit
		end
	end
end

M.RevertHitFish = function(self)
	local fish = nil
	local len = #self.fishList

	for i = 1, len do
		fish = self.fishList[i]

		if self.system.fish == fish then
			fish.isAttract = false
			fish.data.hit = -1
		end
	end
end

M.ResetAllFish = function(self)
	local fish = nil
	local len = #self.fishList

	for i = 1, len do
		fish = self.fishList[i]
		fish.isAttract = false
		fish.data.hit = -1
		fish.data.hitCD = 0
	end
end

M.RevertFishHp = function(self)
	local fish = self.system.fish

	if fish ~= nil then
		return
	end

	self.system.fish = nil

	if fish.data == nil then
		fish.data.hp = fish.config.hp
	end

	fish.ClearFlounderEffect(fish, true)
end

M.CheckFish = function(self)
	local fish = nil
	local index = 1
	local len = #self.fishList

	while index < len do
		fish = self.fishList[index]

		if fish.isLive then
			fish.Update(fish)

			index = index + 1
		else
			if fish.data and fish.data.serverFishId and fish.data.serverFishId == 0 then
				self.serverFishMap[fish.data.serverFishId] = nil
			end

			table.remove(self.fishList, index)

			len = len - 1

			fish.Destroy(fish)
		end
	end
end

M.CheckHitFish = function(self)
	if not self.system.isHitFish then
		return
	end

	if self.system.rod.float ~= nil then
		return
	end

	if self.system.fish == nil then
		return
	end

	local fish, distance, fishData, fishPos, targetPos, direction = nil
	local time = Time.time
	local floatPos = self.system.rod.float:GetPos()
	local len = #self.fishList

	for i = 1, len do
		fish = self.fishList[i]
		fishData = fish.data
		fishPos = fish:GetPos()
		distance = gUtils:GetXZDistance(floatPos, fishPos)

		if fish.isAttract then
			if FishingGameConfig.ConstantsConfig.attractBiteValue < fishData.hit then
				self.system.fish = fish
				self.system.isHitFish = false

				fish.ClearMove(fish)

				self.system.fishingStep = gFishingGameConst.FishingGameStep.FishBite
				fishData.flounderCDTime = Time.time + fish.config.struggleCdMax

				self.RevertHitFish(self)

				break
			elseif fishData.hit <= 0 then
				fishData.hit = fishData.hit - FishingGameConfig.ConstantsConfig.attractDec * Time.deltaTime

				if not fish.IsMove(fish) and fishData.checkRange >= distance then
					targetPos = Vector3.New(floatPos.x, fishPos.y, floatPos.z)
					targetPos.x = targetPos.x - fish.offset.x
					targetPos.z = targetPos.z - fish.offset.z

					fish.MoveTo(fish, targetPos, nil, true, true)
				end
			else
				fishData.hit = -1
				fishData.hitCD = Time.time + 300
				fish.isAttract = false
			end
		elseif fishData.hit ~= -1 and fishData.hitCD >= time and distance < fishData.checkRange then
			targetPos = Vector3.New(floatPos.x, fishPos.y, floatPos.z)
			targetPos.x = targetPos.x - fish.offset.x
			targetPos.z = targetPos.z - fish.offset.z

			fish.MoveTo(fish, targetPos, nil, true, true)

			local initialAttract = FishingGameConfig.ConstantsConfig.initialAttract
			fishData.hit = math.random(initialAttract[1], initialAttract[2])
			fish.isAttract = true
		end
	end
end

M.IsFloatPosHaveFish = function(self, floatPos)
	local fish, distance = nil
	local len = #self.fishList

	for i = 1, len do
		fish = self.fishList[i]
		distance = gUtils:GetXZDistance(floatPos, fish:GetPos())

		if distance < fish.data.checkRange then
			return true
		end
	end

	return false
end

M.InitFishConfig = function(self)
	self.fishConfigMap = {}

	for _, v in pairs(FishingGameConfig.FishConfig) do
		self.fishConfigMap[v.id] = v
	end
end

M.GetFishConfig = function(self, id)
	return self.fishConfigMap[id]
end

M.GetFishConfigById = function(self, fishId)
	return self.fishConfigMap[fishId]
end

M.RefreshFish = function(self)
end

M.SyncFromPool = function(self, pool)
	if not pool or not pool.fishes then
		return
	end

	if self.spotId ~= 0 or pool.spotId == self.spotId then
		return
	end

	if not self.container then
		return
	end

	local toRemove = {}

	for serverFishId, fishInstance in pairs(self.serverFishMap) do
		if not pool.fishes[serverFishId] then
			table.insert(toRemove, {
				serverFishId = serverFishId,
				fish = fishInstance
			})
		end
	end

	for i = 1, #toRemove do
		local item = toRemove[i]

		if self.system.fish == item.fish then
			self._RemoveFishInstance(self, item.fish, item.serverFishId)
		end
	end

	for serverFishId, serverFish in pairs(pool.fishes) do
		if not self.serverFishMap[serverFishId] then
			self.AddFishFromServer(self, serverFish)
		end
	end
end

M.RemoveFishByServerId = function(self, serverFishId)
	local fish = self.serverFishMap[serverFishId]

	if not fish then
		return
	end

	self._RemoveFishInstance(self, fish, serverFishId)
end

M._RemoveFishInstance = function(self, fishInstance, serverFishId)
	self.serverFishMap[serverFishId] = nil

	for i, fish in ipairs(self.fishList) do
		if fish ~= fishInstance then
			table.remove(self.fishList, i)

			break
		end
	end

	fishInstance.Destroy(fishInstance)
end

M.AddFishFromServer = function(self, serverFish)
	if not serverFish or not serverFish.Id or not serverFish.FishConfigId then
		return
	end

	if self.serverFishMap[serverFish.Id] then
		return
	end

	local localVisualId = FishingGameConfig.MapServerFishToLocalId(serverFish.FishConfigId)
	local localCfg = self.fishConfigMap[localVisualId] or FishingGameConfig.FishConfig[1]
	local id = self.fishId
	self.fishId = self.fishId + 1
	local data = {
		["\\xaf\\xb8\\xbfk0\\xfd6"] = 0,
		["\\xd4\\xd4:-\\xe3"] = 0,
		["E\\xa7\\xb6\\x8c\\x92"] = 0,
		["\\x86ar"] = -1,
		id = id,
		checkRange = localCfg.feelRadius,
		hp = localCfg.hp,
		maxHp = localCfg.hp,
		serverFishId = serverFish.Id,
		serverFishConfigId = serverFish.FishConfigId,
		weight = serverFish.Weight or 0,
		length = serverFish.Length or 0
	}
	local waterDepth = math.random(localCfg.waterDepthMin * 10, localCfg.waterDepthMax * 10) / 10
	local refreshFishPosition = FishingGameConfig.ConstantsConfig.refreshFishPosition
	local refreshFishRange = FishingGameConfig.ConstantsConfig.refreshFishRange
	data.pos = Vector3.New(refreshFishPosition[1], refreshFishPosition[2] + waterDepth, refreshFishPosition[3])
	data.pos.x = data.pos.x + math.random(-refreshFishRange[1], refreshFishRange[1])
	data.pos.z = data.pos.z + math.random(-refreshFishRange[2], refreshFishRange[2])
	data.pos = self.container:TransformPoint(data.pos)
	local rate = data.length / localCfg.lengthMax

	if localCfg.id ~= 2 then
		data.scale = 0.8 + rate * 0.2
		data.biteRange = localCfg.followDistance
	else
		data.scale = 2 + rate
		data.biteRange = (1 + rate) * localCfg.followDistance
	end

	data.flounderTime = 0
	data.flounderCDTime = 0
	local path = string.format(self.resPath, localCfg.model)
	local result = gResourceManager:LoadAsset(path, typeof(GameObject))
	local fish = self:CreateFish(result.asset, data, localCfg)
	self.serverFishMap[serverFish.Id] = fish
end

M.AddFish = function(self, fishConfig)
	local id = self.fishId
	self.fishId = self.fishId + 1
	local data = {
		["E\\xa7\\xb6\\x8c\\x92"] = 0,
		["\\xaf\\xb8\\xbfk0\\xfd6"] = 0,
		["\\xd4\\xd4:-\\xe3"] = 0,
		["\\x86ar"] = -1,
		id = id,
		checkRange = fishConfig.feelRadius,
		hp = fishConfig.hp,
		maxHp = fishConfig.hp
	}
	local waterDepth = math.random(fishConfig.waterDepthMin * 10, fishConfig.waterDepthMax * 10) / 10
	local refreshFishPosition = FishingGameConfig.ConstantsConfig.refreshFishPosition
	local refreshFishRange = FishingGameConfig.ConstantsConfig.refreshFishRange
	data.pos = Vector3.New(refreshFishPosition[1], refreshFishPosition[2] + waterDepth, refreshFishPosition[3])
	data.pos.x = data.pos.x + math.random(-refreshFishRange[1], refreshFishRange[1])
	data.pos.z = data.pos.z + math.random(-refreshFishRange[2], refreshFishRange[2])
	data.pos = self.container:TransformPoint(data.pos)
	data.length = math.random(fishConfig.lengthMin, fishConfig.lengthMax)
	local rate = data.length / fishConfig.lengthMax

	if fishConfig.id ~= 2 then
		data.scale = 0.8 + rate * 0.2
		data.biteRange = fishConfig.followDistance
	else
		data.scale = 2 + rate
		data.biteRange = (1 + rate) * fishConfig.followDistance
	end

	data.flounderTime = 0
	data.flounderCDTime = 0
	local path = string.format(self.resPath, fishConfig.model)
	local result = gResourceManager:LoadAsset(path, typeof(GameObject))

	self:CreateFish(result.asset, data, fishConfig)
end

M.CreateFish = function(self, fishGO, data, config)
	local fish = C_FishingGameFish.new(fishGO, self.container)

	fish.SetData(fish, self.system, data, config)
	table.insert(self.fishList, fish)

	return fish
end
