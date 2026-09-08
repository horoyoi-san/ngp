-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameManager.lua
-- Decompiled from: 00603_FishingGameManager.lua_5816903fa03d.luajit

C_FishingGameManager = DefClass("C_FishingGameManager", C_FishingGameManager, gBaseMiniGameManager)
local FishingGameManager = C_FishingGameManager
local MessageConfig = LTConfig.MessageConfig
local POLLING_INTERVAL_SECONDS = 60

FishingGameManager.ctor = function(self)
	self.spotPools = {}
	self.pollingSpotId = 0
	self.pollingTimer = nil
end

FishingGameManager.CreateGame = function(self, args)
	self.currentGame = gFishingGame.new(args)
end

FishingGameManager.CreateGameCs = function(self, taskId, npcId, position, rotation, fishConfigId)
	self:CreateGame({
		taskId = taskId,
		npcId = npcId,
		wayPointPosition = Vector3.New(position.x, position.y, position.z),
		wayPointRotation = Quaternion.New(rotation.x, rotation.y, rotation.z, rotation.w),
		spotId = fishConfigId or 0
	})
end

FishingGameManager.CreateQuestGameCs = function(self, taskId, npcId, position, rotation, fishConfigId, entityInstanceId, maxFailCount)
	self:CreateGame({
		["\\x96'*}\\x8eU\\xf48\\xae\\xbc"] = true,
		taskId = taskId,
		npcId = npcId,
		wayPointPosition = Vector3.New(position.x, position.y, position.z),
		wayPointRotation = Quaternion.New(rotation.x, rotation.y, rotation.z, rotation.w),
		spotId = fishConfigId or 0,
		entityInstanceId = entityInstanceId or 0,
		maxFailCount = maxFailCount or 0
	})
end

FishingGameManager.ExitGameCs = function(self)
	if self.currentGame then
		self.currentGame:ForceExit()
	end
end

FishingGameManager.GetSpotPool = function(self, spotId)
	return self.spotPools[spotId]
end

FishingGameManager.RequestSpotFullSync = function(self, spotId, onComplete)
	if not spotId or spotId ~= 0 then
		if onComplete then
			onComplete(MessageConfig.InvalidPara, nil)
		end

		return
	end

	gClientToGameDelegate:AskFishingSpotFullSync(spotId).Callback = function (err, info)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if onComplete then
				onComplete(err, nil)
			end

			return
		end

		local pool = self:BuildSpotPoolFromInfo(info)
		self.spotPools[spotId] = pool

		self:NotifyFishMgrSyncFromPool(spotId, pool)

		if onComplete then
			onComplete(MessageConfig.Ok, pool)
		end
	end
end

FishingGameManager.NotifyFishingSuccessToServer = function(self, spotId, fishId, fishConfigId)
	if not spotId or spotId ~= 0 or not fishId or fishId ~= 0 then
		return
	end

	gClientToGameDelegate:AskFishingSuccess(spotId, fishId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

FishingGameManager.OnSyncFishingSpotFull = function(self, info)
	if not info or not info.FishGroupId then
		return
	end

	local pool = self:BuildSpotPoolFromInfo(info)
	self.spotPools[info.FishGroupId] = pool

	self:NotifyFishMgrSyncFromPool(info.FishGroupId, pool)
end

FishingGameManager.OnSyncFishingSpotFishAdd = function(self, spotId, addedFishes, poolCount)
	local pool = self.spotPools[spotId]

	if not pool then
		return
	end

	if addedFishes then
		for i = 1, #addedFishes do
			local fish = addedFishes[i]

			if fish and fish.Id then
				pool.fishes[fish.Id] = fish
			end
		end
	end

	pool.poolCount = poolCount

	self:NotifyFishMgrSyncFromPool(spotId, pool)
end

FishingGameManager.OnSyncFishingSpotFishRemove = function(self, spotId, fishId, poolCount)
	local pool = self.spotPools[spotId]

	if not pool then
		return
	end

	pool.fishes[fishId] = nil
	pool.poolCount = poolCount

	self:NotifyFishMgrSyncFromPool(spotId, pool)
end

FishingGameManager.RemoveFishFromLocal = function(self, spotId, fishId)
	local pool = self.spotPools[spotId]

	if not pool then
		return
	end

	if pool.fishes[fishId] then
		pool.fishes[fishId] = nil
		pool.poolCount = math.max(0, (pool.poolCount or 0) - 1)
	end
end

FishingGameManager.BuildSpotPoolFromInfo = function(self, info)
	local pool = {
		["SHcem,"] = 0,
		spotId = info.FishGroupId,
		fishes = {},
		maxCount = info.MaxCount or 0,
		lastRefreshTime = info.LastRefreshTime or 0,
		lastResetTime = info.LastResetTime or 0
	}

	if info.Fishes then
		for i = 1, #info.Fishes do
			local fish = info.Fishes[i]

			if fish and fish.Id then
				pool.fishes[fish.Id] = fish
				pool.poolCount = pool.poolCount + 1
			end
		end
	end

	return pool
end

FishingGameManager.NotifyFishMgrSyncFromPool = function(self, spotId, pool)
	if not self.currentGame then
		return
	end

	if (self.currentGame.spotId or 0) == spotId then
		return
	end

	local mainStoreGroup = gStoreManager:GetStoreGroup("FishingGameMainPanelStore")

	if not mainStoreGroup or not mainStoreGroup.system then
		return
	end

	local fishMgr = mainStoreGroup.system.fishMgr

	if fishMgr and fishMgr.SyncFromPool then
		fishMgr:SyncFromPool(pool)
	end
end

FishingGameManager.StartPolling = function(self, spotId)
	if not spotId or spotId ~= 0 then
		return
	end

	self:StopPolling()

	self.pollingSpotId = spotId
	self.pollingTimer = Timer.New(function ()
		if self.pollingSpotId ~= 0 then
			return
		end

		self:RequestSpotFullSync(self.pollingSpotId)
	end, POLLING_INTERVAL_SECONDS, -1)

	self.pollingTimer:Start()
end

FishingGameManager.StopPolling = function(self)
	if self.pollingTimer then
		self.pollingTimer:Stop()

		self.pollingTimer = nil
	end

	self.pollingSpotId = 0
end

gFishingGameManager = gFishingGameManager or C_FishingGameManager.new()
