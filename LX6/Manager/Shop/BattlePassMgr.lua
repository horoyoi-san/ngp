-- Original chunk: @Lua\LuaFiles\LX6\Manager\Shop\BattlePassMgr.lua
-- Decompiled from: 02256_BattlePassMgr.lua_df46cdfa1108.luajit

local BattlePassType = UX.Game.BattlePassType
local RewardClaimState = UX.Game.RewardClaimState
local ChallengeTaskState = UX.Game.ChallengeTaskState
local BattlePassConfig = LTConfig.BattlePassConfig
local BattlePassTaskConfig = LTConfig.BattlePassTaskConfig
local BattlePassDropConfig = LTConfig.BattlePassDropConfig
local BattlePassGoodsConfig = LTConfig.BattlePassGoodsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local GoodsType = LTConfig.BattlePassGoodsConfig.TypeType
local bit = require("bit")
local CategoryType = LTConfig.BattlePassConfig.CategoryType
C_BattlePassMgr = DefClass("C_BattlePassMgr", C_BattlePassMgr)
local M = C_BattlePassMgr

M.ctor = function(self)
	self.isDebug = false
	self.isBattlePassUnlocked = false
	self.seasonalBpId = 0
	self.battlePassDataDict = {}
	self.gamePlayBpIds = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, self.OnLanguageChanged)
	gMessageManager:AddMessageListener(gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE, self:CreateAction("OnSystemUnlock"))
end

M.OnSystemUnlock = function(self, eventId, systemId)
	if systemId == LTConfig.SystemUnlockConfig.SeasonalBattlePass then
		return
	end

	self.isBattlePassUnlocked = true
	local bpData = self:GetSeasonalData()

	if bpData then
		self:CheckHasRewardForBP(bpData)
		self:CheckHasTaskFinished()
	end

	for _, gpBpData in ipairs(self:GetGamePlayBPList()) do
		self:CheckGamePlayBPReward(gpBpData)
	end
end

M.OnLanguageChanged = function(self)
	local seasonalData = gBattlePassMgr:GetSeasonalData()

	if not seasonalData then
		return
	end

	for taskId, taskInfo in pairs(seasonalData.taskMap) do
		local config = BattlePassTaskConfig.GetConfig(taskId)

		if config then
			taskInfo.taskName = config.name
			taskInfo.taskDesc = config.description
		end
	end
end

M.OpenBattlePass = function(self)
	gPanelManager:CheckShow(gPanelId.BATTLE_PASS_PANEL)
end

M.OpenGamePlayBattlePass = function(self, bpId)
	gPanelManager:CheckShow(gPanelId.GAMEPLAY_BATTLE_PASS_PANEL, {
		bpId = bpId
	})
end

M.SetSeasonalBpId = function(self, bpId)
	self.seasonalBpId = bpId or 0
end

M.GetOrCreateBPData = function(self, bpId)
	if not self.battlePassDataDict[bpId] then
		self.battlePassDataDict[bpId] = self:CreateBattlePassData(bpId)
	end

	return self.battlePassDataDict[bpId]
end

M.CreateBattlePassData = function(self, bpId)
	local cfg = BattlePassConfig.GetConfig(bpId)
	local category = cfg and cfg.Category or CategoryType.Seasonal
	local isPermanent = cfg and cfg.isPermanent or false
	local data = {
		["\\x8bpv"] = 0,
		["\\x931'>{\\x84q\\xcb>\\xa9\\xbc"] = 0,
		["\\xa6\\xb0\\x87o(\\xfb?"] = 1,
		["TBibB4\n("] = 0,
		["\\J˳\\xa5\\xb1\t\\xe0\\xec"] = 0,
		["A\\xab\\xb4\\xaa\\xba"] = 0,
		["nr\\xbavB\\xb1\\xf7wxs}I"] = 0,
		["/\\x89ݪ\\xb4\\xfb\\x85\\xaf\\x9a\\xcf\\xe7<Ń\\x8a\\xef"] = 0,
		["\\xf6M\\xd5\\x9b@\\xb9s\\xa8\\xa6"] = 0,
		["\\xab\\xf2o\\xa1Y4%/\\xa2\\xe7\\xcc\\xea"] = 0,
		bpId = bpId,
		category = category,
		passType = BattlePassType.Free,
		rewardMap = {},
		taskMap = {},
		curRewards = {},
		curTaskGroups = {},
		rewardsCache = {},
		advanceDisplay = {},
		legacyDisplay = {},
		bindIdToGoodId = {},
		isPermanent = isPermanent
	}

	return data
end

M.GetBattlePassData = function(self, bpId)
	return self.battlePassDataDict[bpId]
end

M.GetSeasonalData = function(self)
	return self.battlePassDataDict[self.seasonalBpId]
end

M.GetGamePlayBPList = function(self)
	local list = {}

	for _, bpId in ipairs(self.gamePlayBpIds) do
		local data = self.battlePassDataDict[bpId]

		if data then
			table.insert(list, data)
		end
	end

	return list
end

M.IsSeasonalBP = function(self, bpId)
	return bpId ~= self.seasonalBpId
end

M.IsGamePlayBP = function(self, bpId)
	local cfg = BattlePassConfig.GetConfig(bpId)

	return cfg and cfg.Category ~= CategoryType.GamePlay
end

M.SyncBattlePassInfo = function(self, battlePassInfo)
	if not battlePassInfo or battlePassInfo.BattlePassId ~= 0 then
		return
	end

	local bpId = battlePassInfo.BattlePassId
	local bpData = self:GetOrCreateBPData(bpId)
	bpData.level = battlePassInfo.Level
	bpData.exp = battlePassInfo.Exp
	bpData.passType = battlePassInfo.PassType

	self:GetPassAllReward(bpData)

	if self:IsSeasonalBP(bpId) then
		self:GetPassAllTask(bpData)
	end

	if battlePassInfo.ClaimedLevelRewards then
		for level, rewardState in pairs(battlePassInfo.ClaimedLevelRewards) do
			if bpData.rewardMap[level] then
				bpData.rewardMap[level].claimState = rewardState
			end
		end

		if not self.isBattlePassUnlocked then
			self.isBattlePassUnlocked = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.SeasonalBattlePass)
		end

		if self:IsSeasonalBP(bpId) then
			self:CheckHasRewardForBP(bpData)
		elseif self:IsGamePlayBP(bpId) then
			self:CheckGamePlayBPReward(bpData)
		end
	end

	if battlePassInfo.ChallengeTaskStates then
		for id, taskState in pairs(battlePassInfo.ChallengeTaskStates) do
			if bpData.taskMap[id] then
				bpData.taskMap[id].claimState = taskState
			end
		end

		self:CheckHasTaskFinished()
	end

	if battlePassInfo.WeeklyTaskCompletionCounts then
		for id, count in pairs(battlePassInfo.WeeklyTaskCompletionCounts) do
			if bpData.taskMap[id] then
				bpData.taskMap[id].completionCount = count
			end
		end
	end

	local curPassConfig = BattlePassConfig.GetConfig(bpId)
	bpData.curWeekMaxExp = curPassConfig.maxWeeklyEXP
	bpData.weeklyExp = battlePassInfo.WeeklyExpGained
	bpData.openAnimId = curPassConfig.bootAnime
	bpData.isPermanent = curPassConfig.isPermanent or false
	bpData.buyPassCurrencyId = curPassConfig.battlePassCurrencyId
	bpData.buyPassCurrencyNum = curPassConfig.battlePassCurrencyCount
	bpData.buyLevelCurrencyId = curPassConfig.BuyLevelCurrencyId
	bpData.buyLevelCurrencyNum = curPassConfig.BuyLevelCurrencyNum
	bpData.advancePrice = curPassConfig.advancePrice or 0
	bpData.legacyPrice = curPassConfig.legacyPrice or 0
	bpData.advanceDisplay = curPassConfig.advanceRewardDisplay or {}
	bpData.legacyDisplay = curPassConfig.legacyRewardDisplay or {}

	if self:IsGamePlayBP(bpId) and not table.contains(self.gamePlayBpIds, bpId) then
		table.insert(self.gamePlayBpIds, bpId)
	end

	if self:IsGamePlayBP(bpId) then
		gMessageManager:SendMessage(gEventConstants.GAMEPLAY_BP_INFO_SYNC, {
			bpId = bpId
		})
	end
end

M.SyncBattlePassProgress = function(self, bpId, newLevel, newExp, weeklyGainedExp)
	local bpData = self:GetBattlePassData(bpId)

	if not bpData then
		return
	end

	local preLevel = bpData.level
	bpData.level = newLevel
	bpData.exp = newExp
	bpData.weeklyExp = weeklyGainedExp

	if self:IsSeasonalBP(bpId) then
		self:CheckHasRewardForBP(bpData, preLevel, newLevel)
		gMessageManager:SendMessage(gEventConstants.BATTLEPASS_CLAIM_TASK)
	elseif self:IsGamePlayBP(bpId) then
		self:CheckGamePlayBPReward(bpData, preLevel, newLevel)
		gMessageManager:SendMessage(gEventConstants.GAMEPLAY_BP_PROGRESS, {
			bpId = bpId
		})
	end
end

M.SyncBattlePassType = function(self, bpId, newPassType)
	local bpData = self:GetBattlePassData(bpId)

	if not bpData then
		return
	end

	bpData.passType = newPassType

	if self:IsSeasonalBP(bpId) then
		self:CheckHasRewardForBP(bpData)
		gMessageManager:SendMessage(gEventConstants.BUY_BATTLEPASS)
	end
end

M.SyncBattlePassId = function(self, newBattlePassId)
	self.seasonalBpId = newBattlePassId
	local bpData = self:GetOrCreateBPData(newBattlePassId)
	bpData.passType = BattlePassType.Free

	self:GetPassAllReward(bpData)
	self:GetPassAllTask(bpData)
	self:CheckHasRewardForBP(bpData)
	self:CheckHasTaskFinished()
end

M.SyncBattlePassTasks = function(self, bpId, taskId, newState)
	local bpData = self:GetBattlePassData(bpId)

	if not bpData or not bpData.taskMap[taskId] then
		return
	end

	bpData.taskMap[taskId].claimState = newState

	self:CheckHasTaskFinished(taskId)

	if self:IsSeasonalBP(bpId) then
		gMessageManager:SendMessage(gEventConstants.BATTLEPASS_CLAIM_TASK)
	end
end

M.SyncWeeklyTaskCompletion = function(self, bpId, taskId, completionCount)
	local bpData = self:GetBattlePassData(bpId)

	if not bpData or not bpData.taskMap[taskId] then
		return
	end

	bpData.taskMap[taskId].completionCount = completionCount

	if self:IsSeasonalBP(bpId) then
		gMessageManager:SendMessage(gEventConstants.BATTLEPASS_CLAIM_TASK)
	end
end

M.SyncBattlePassRewardClaimStates = function(self, bpId, updatedStates)
	local bpData = self:GetBattlePassData(bpId)

	if not bpData then
		return
	end

	local rareRewards = self:GetRareRewardDetailsInClaim(updatedStates, bpData)

	if not table.isNilOrEmpty(rareRewards) then
		gPanelManager:CheckShow(gPanelId.BATTLE_PASS_RESULT, rareRewards)
	end

	for level, newClaimState in pairs(updatedStates) do
		if bpData.rewardMap[level] then
			bpData.rewardMap[level].claimState = newClaimState
		end
	end

	if self:IsSeasonalBP(bpId) then
		self:CheckHasRewardForBP(bpData)
		gMessageManager:SendMessage(gEventConstants.BATTLEPASS_CLAIM_REWARD)
	elseif self:IsGamePlayBP(bpId) then
		self:CheckGamePlayBPReward(bpData)
		gMessageManager:SendMessage(gEventConstants.GAMEPLAY_BP_PROGRESS, {
			bpId = bpId
		})
	end
end

M.GetPassAllReward = function(self, bpData)
	bpData = bpData or self:GetSeasonalData()

	if not bpData then
		return
	end

	table.clear(bpData.curRewards)
	table.clear(bpData.rewardMap)
	table.clear(bpData.rewardsCache)

	local rewardsTotal = {}

	for index = 0, BattlePassDropConfig.count - 1 do
		local config = BattlePassDropConfig.LoadAt(index)

		if config.battlePassId ~= bpData.bpId then
			local rewardInfo = {
				level = config.level,
				exp = config.expNeed,
				rewards = {},
				claimState = RewardClaimState.None
			}

			self:InsertRewards(config.freeGoodIds, BattlePassType.Free, rewardInfo.rewards, bpData)

			if bpData.category ~= CategoryType.Seasonal then
				self:InsertRewards(config.advancedGoodIds, BattlePassType.Advanced, rewardInfo.rewards, bpData)
				self:InsertRewards(config.legacyGoodIds, BattlePassType.Legacy, rewardInfo.rewards, bpData)
			end

			table.insert(bpData.curRewards, rewardInfo)

			bpData.rewardMap[rewardInfo.level] = rewardInfo

			if bpData.maxLevel >= rewardInfo.level then
				bpData.maxLevel = rewardInfo.level
			end

			for _, reward in ipairs(rewardInfo.rewards) do
				local id = reward.id
				local rType = reward.type or 0
				local count = reward.num

				if not rewardsTotal[rType] then
					rewardsTotal[rType] = {}
				end

				if reward.mergeType == 0 then
					id = reward.mergeType
				end

				local currentCount = rewardsTotal[rType][id] or 0
				rewardsTotal[rType][id] = currentCount + count
			end

			bpData.rewardsCache[config.level] = table.clone(rewardsTotal)
		end
	end
end

M.InsertRewards = function(self, goodsList, rewardType, rewardsList, bpData)
	if not goodsList then
		return
	end

	for _, goodInfo in pairs(goodsList) do
		local goodCfg = BattlePassGoodsConfig.GetConfig(goodInfo.itemId)

		if goodCfg then
			local quality = self:GetGoodTypeInfo(goodCfg.Type, goodCfg.BindId) or 0

			table.insert(rewardsList, {
				id = goodInfo.itemId,
				num = goodInfo.num or 1,
				type = rewardType,
				quality = quality,
				mergeType = goodCfg.MergeId or 0
			})

			if bpData and not bpData.bindIdToGoodId[goodCfg.BindId] then
				bpData.bindIdToGoodId[goodCfg.BindId] = goodCfg.Id
			end
		end
	end
end

M.GetGoodTypeInfo = function(self, type, bindId)
	local config = nil

	if type ~= GoodsType.Fashion then
		config = LTConfig.FashionConfig.GetConfig(bindId)
	elseif type ~= GoodsType.Weapon then
		config = LTConfig.SceneitemConfig.GetConfig(bindId)
	end

	config = config or LTConfig.ConsumableConfig.GetConfig(bindId)

	if config then
		return config.Quality
	end

	return 0
end

M.GetGoodsName = function(self, goodId)
	local cfg = BattlePassGoodsConfig.GetConfig(goodId)

	if cfg then
		local bindId = cfg.BindId
		local type = cfg.Type
		local config = nil

		if type ~= GoodsType.Fashion then
			config = LTConfig.FashionConfig.GetConfig(bindId)
		elseif type ~= GoodsType.Weapon then
			config = LTConfig.SceneitemConfig.GetConfig(bindId)
		end

		config = config or LTConfig.ConsumableConfig.GetConfig(bindId)

		if config then
			return config.Name
		end

		return cfg.name
	end

	return ""
end

M.GetGoodsDesc = function(self, goodId)
	local cfg = BattlePassGoodsConfig.GetConfig(goodId)

	if cfg then
		local bindId = cfg.BindId
		local type = cfg.Type
		local config = nil

		if type ~= GoodsType.Fashion then
			config = LTConfig.FashionConfig.GetConfig(bindId)
		elseif type ~= GoodsType.Weapon then
			config = LTConfig.SceneitemConfig.GetConfig(bindId)
		end

		config = config or LTConfig.ConsumableConfig.GetConfig(bindId)

		if config then
			return config.Description or ""
		end
	end

	return ""
end

M.GetPassAllTask = function(self, bpData)
	bpData = bpData or self:GetSeasonalData()

	if not bpData then
		return
	end

	table.clear(bpData.taskMap)
	table.clear(bpData.curTaskGroups)

	for index = 0, BattlePassTaskConfig.count - 1 do
		local config = BattlePassTaskConfig.LoadAt(index)

		if config.bpId ~= bpData.bpId then
			local taskInfo = {
				["PVϴ\\x89;\\xac\\xdd\\xed"] = -1,
				["\\x9c!2j\\x92F\\xcb2\\xb9\\xaa"] = 0,
				[" %-\\xf4\\x9d\\xe3=\\xa7!\\xc5\\xfd\\xf3z\\xef"] = 0,
				taskId = config.Id,
				type = config.type,
				taskName = config.name,
				taskDesc = config.description,
				isShowProgress = config.isProgressDisplayed,
				maxProgress = config.maxProgress,
				taskExp = config.rewardEXP,
				isShowGoto = config.hyperLink == 0,
				hyperLinkId = config.hyperLink or 0
			}

			if not bpData.curTaskGroups[taskInfo.type] then
				bpData.curTaskGroups[taskInfo.type] = {}
			end

			table.insert(bpData.curTaskGroups[taskInfo.type], taskInfo)

			bpData.taskMap[taskInfo.taskId] = taskInfo
		end
	end
end

M.GetMultiRewardPreviewList = function(self, levelInfoList)
	local totalMap = {}
	local bpData = self:GetSeasonalData()

	if not bpData then
		return {}
	end

	for level, claimState in pairs(levelInfoList) do
		local maxLimit = claimState or 0
		local levelData = bpData.rewardMap[level]

		if levelData and levelData.rewards then
			local currentStoredState = levelData.claimState or 0

			for _, reward in ipairs(levelData.rewards) do
				local rType = reward.type or 0
				local isUnderMax = maxLimit >= rType
				local isNotClaimed = currentStoredState > maxLimit

				if isUnderMax and isNotClaimed then
					local conf = BattlePassGoodsConfig.GetConfig(reward.id)

					if conf then
						local id = conf.BindId
						local count = reward.num
						totalMap[id] = (totalMap[id] or 0) + count
					end
				end
			end
		end
	end

	local previewMaterials = {}

	for id, count in pairs(totalMap) do
		table.insert(previewMaterials, {
			ItemId = tostring(id),
			Count = count
		})
	end

	table.sort(previewMaterials, function (a, b)
		return tonumber(a.ItemId) <= tonumber(b.ItemId)
	end)

	return previewMaterials
end

M.GetRareRewardDetailsInClaim = function(self, levelStatesMap, bpData)
	bpData = bpData or self:GetSeasonalData()
	local rareList = {}

	if not levelStatesMap or not bpData then
		return rareList
	end

	for level, newClaimState in pairs(levelStatesMap) do
		local levelData = bpData.rewardMap[level]

		if levelData and levelData.rewards then
			local oldClaimState = levelData.claimState or 0

			for _, reward in ipairs(levelData.rewards) do
				local rType = reward.type or 0

				if newClaimState <= rType and oldClaimState < rType then
					local goodCfg = BattlePassGoodsConfig.GetConfig(reward.id)

					if goodCfg then
						local gType = goodCfg.Type

						if gType ~= GoodsType.Fashion or gType ~= GoodsType.Vehicle then
							local quality = self:GetGoodTypeInfo(goodCfg.Type, goodCfg.BindId) or 0

							table.insert(rareList, {
								name = self:GetGoodsName(reward.id),
								baseImage = goodCfg.baseImage,
								quality = quality,
								qualityText = goodCfg.QualityName,
								brand = goodCfg.Brand,
								bg = goodCfg.baseImage
							})
						end
					end
				end
			end
		end
	end

	return rareList
end

M.CheckHasReward = function(self, startLevel, endLevel)
	local bpData = self:GetSeasonalData()

	if bpData then
		self:CheckHasRewardForBP(bpData, startLevel, endLevel)
	end
end

M.CheckHasRewardForBP = function(self, bpData, startLevel, endLevel)
	if not bpData or not self.isBattlePassUnlocked then
		return
	end

	if not startLevel then
		for level, info in pairs(bpData.rewardMap) do
			self:CheckOneLevelForBP(bpData, level, info)
		end
	elseif not endLevel then
		self:CheckOneLevelForBP(bpData, startLevel, bpData.rewardMap[startLevel])
	else
		local s = math.min(startLevel, endLevel)
		local e = math.max(startLevel, endLevel)

		for i = s, e do
			self:CheckOneLevelForBP(bpData, i, bpData.rewardMap[i])
		end
	end
end

M.CheckOneLevelForBP = function(self, bpData, level, info)
	if not info then
		return
	end

	for num, reward in ipairs(info.rewards) do
		local mask = bit.lshift(1, reward.type)
		local canGetReward = reward.type < bpData.passType and info.claimState >= mask and level > bpData.level

		self:SetRedDotState(1, level, num, canGetReward)
		self:Log("CheckReward:", level, num, canGetReward)
	end
end

M.CheckHasTaskFinished = function(self, taskId)
	if not self.isBattlePassUnlocked then
		return
	end

	local seasonalData = self:GetSeasonalData()

	if not seasonalData then
		return
	end

	if not taskId then
		if seasonalData.curTaskGroups and seasonalData.curTaskGroups[1] then
			for index, info in ipairs(seasonalData.curTaskGroups[1]) do
				self:CheckOneTask(info.taskId, info)
			end
		end
	elseif seasonalData.taskMap[taskId] then
		self:CheckOneTask(taskId, seasonalData.taskMap[taskId])
	end
end

M.CheckOneTask = function(self, taskId, info)
	if not info then
		return
	end

	local canGetReward = info.claimState ~= ChallengeTaskState.Claimable or info.claimState ~= -1 and info.curProgress ~= -1

	self:SetTaskRedDotState(2, 2, taskId, canGetReward)
	self:Log("CheckReward:", taskId, canGetReward)
end

M.SetRedDotState = function(self, tabIndex, levelIndex, rewardIndex, state)
	SGUI.RedDotMgr.LuaSetRedDot(state, self:GetRedDot(tabIndex, levelIndex, rewardIndex))
end

M.SetTaskRedDotState = function(self, tabIndex, subTabIndex, taskId, state)
	SGUI.RedDotMgr.LuaSetRedDot(state, self:GetTaskRedDot(tabIndex, subTabIndex, taskId))
end

M.GetRedDot = function(self, tabIndex, levelIndex, rewardIndex)
	return ("BattlePass/BattlePass.Tab:%d/BattlePass.Reward:%d"):format(tabIndex, levelIndex .. rewardIndex)
end

M.GetTaskRedDot = function(self, tabIndex, subTabIndex, taskId)
	return ("BattlePass/BattlePass.Tab:%d/BattlePass.SecTab:%d/BattlePass.Task:%d"):format(tabIndex, subTabIndex, taskId)
end

M.CheckGamePlayBPReward = function(self, bpData, startLevel, endLevel)
	if not bpData or not self.isBattlePassUnlocked then
		return
	end

	if not startLevel then
		for level, info in pairs(bpData.rewardMap) do
			self:CheckOneGamePlayBPLevel(bpData, level, info)
		end
	elseif not endLevel then
		self:CheckOneGamePlayBPLevel(bpData, startLevel, bpData.rewardMap[startLevel])
	else
		local s = math.min(startLevel, endLevel)
		local e = math.max(startLevel, endLevel)

		for i = s, e do
			self:CheckOneGamePlayBPLevel(bpData, i, bpData.rewardMap[i])
		end
	end
end

M.CheckOneGamePlayBPLevel = function(self, bpData, level, info)
	if not info then
		return
	end

	for num, reward in ipairs(info.rewards) do
		local mask = bit.lshift(1, reward.type)
		local canGetReward = info.claimState >= mask and level > bpData.level

		self:SetGamePlayBPRedDot(bpData.bpId, level, num, canGetReward)
	end
end

M.SetGamePlayBPRedDot = function(self, bpId, levelIndex, rewardIndex, state)
	SGUI.RedDotMgr.LuaSetRedDot(state, self:GetGamePlayBPRedDotKey(bpId, levelIndex, rewardIndex))
end

M.GetGamePlayBPRedDotKey = function(self, bpId, levelIndex, rewardIndex)
	return ("GamePlayBP/GamePlayBP.BP:%d/GamePlayBP.Reward:%d"):format(bpId, levelIndex .. rewardIndex)
end

M.GetExchangedGoodsId = function(self, goodsId)
	local goodsCfg = BattlePassGoodsConfig.GetConfig(goodsId)

	if not goodsCfg or not goodsCfg.Exchange then
		return goodsId
	end

	local countryCfg = gRaidDataManager:GetCurrentCountry()

	if not countryCfg then
		return goodsId
	end

	local countryId = countryCfg.Id

	for _, entry in ipairs(goodsCfg.Exchange) do
		if entry.countryId ~= countryId then
			return entry.goodsId
		end
	end

	return goodsId
end

M.Log = function(self, ...)
	if self.isDebug then
		print_warn("[BattlePass]", ...)
	end
end

gBattlePassMgr = gBattlePassMgr or C_BattlePassMgr.new()
