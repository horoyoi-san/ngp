-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_Collection.lua
-- Decompiled from: 01013_BigMapTooltip_Collection.lua_205d8de81dc4.luajit

C_BigMapTooltip_Collection = DefClass("C_BigMapTooltip_Collection", C_BigMapTooltip_Collection, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Collection
local CHALLENGE_LIST = 0
local NORMAL_LIST = 1
local SHOW_SCORE = 0
local HIDE_SCORE = 1
local SCORE_S = 0
local SCORE_A = 1
local SCORE_B = 2

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "collectionInfo") then
		return
	end

	self.gamepadSingleRewardList = nil
	self.gamepadMultiRewardList = nil

	self.GetStore(self, "MapCollectionTooltipStore")

	local info = self.tooltipInfo.collectionInfo

	self.SetUpHeader(self)
	self.SetUpSpecificSpirits(self, info)

	local scrollStore = nil

	if info.specificSpirits and #info.specificSpirits <= 0 then
		self.store.spiritScroll:GoToPos(Vector2.zero, true)

		scrollStore = gStoreManager:GetStoreGroup("MapCollectionScrollStore"):GetStoreByWidget(self.store.spiritScroll.content)
	else
		self.store.normalScroll:GoToPos(Vector2.zero, true)

		scrollStore = gStoreManager:GetStoreGroup("MapCollectionScrollStore"):GetStoreByWidget(self.store.normalScroll.content)
	end

	self.SetUpScrollLocation(self, scrollStore)

	if info.abilityIds and #info.abilityIds <= 0 then
		scrollStore.addAbility = 1

		self.SetUpAbilityList(self, scrollStore.AbilityList, info.abilityIds)
	else
		scrollStore.addAbility = 0
	end

	local levelToScore = {
		[0] = SCORE_B,
		SCORE_A,
		SCORE_S
	}

	if self.tooltipInfo.racingInfo then
		local bestScore, bestLevel = self.bigMap.compRefs.Racer:GetBestScore(self.tooltipInfo.racingInfo.racingDriverId)
		scrollStore.difficultyCtrl = 0

		scrollStore.difficultyList.luaSimpleRenderItem = function(btn, index)
		end

		scrollStore.difficultyList:SetSimpleList(self.tooltipInfo.racingInfo.difficulty)

		if bestScore then
			scrollStore.scoreText = bestScore
			scrollStore.scoreCtrl = SHOW_SCORE
			scrollStore.scoreTypeCtrl = levelToScore[bestLevel] or SCORE_B
		else
			scrollStore.scoreCtrl = HIDE_SCORE
		end
	else
		scrollStore.difficultyCtrl = 1
		scrollStore.scoreCtrl = HIDE_SCORE
	end

	self.SetUpScroll(self, scrollStore, info)
end

local SHOW_REWARD = 0
local HIDE_REWARD = 1

M.SetUpScroll = function(self, scrollStore, info)
	scrollStore.desc = info.desc or ""

	if info.isChallenge then
		self.SetUpChallengeTooltip(self, scrollStore, info)
	elseif not info.simpleDropId or info.simpleDropId ~= 0 then
		scrollStore.showReward = HIDE_REWARD
	else
		scrollStore.showReward = SHOW_REWARD

		self.SetUpNotChallengeTooltip(self, scrollStore, info)
	end

	scrollStore.clickShowReward = self.bigMap:CreateAction("OnClickShowReward", self)
end

local SINGLE_DROP = 1
local MULTI_DROP = 2

M.SetUpChallengeTooltip = function(self, scrollStore, info)
	local challengeId = info.challengeId
	scrollStore.rewardMode = MULTI_DROP
	scrollStore.showReward = HIDE_REWARD
	slot4 = gClientToGameDelegate

	slot4:AskNewChallengeRecord(challengeId).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok and self.container:CheckTooltipHandlerActive(self) and self.tooltipInfo.collectionInfo.challengeId ~= challengeId then
			self:SetupChallengeListInfo(scrollStore, data)
		end
	end
end

M.SetupChallengeListInfo = function(self, scrollStore, data)
	local subQuestId = self.tooltipInfo.collectionInfo.subQuestId
	local subQuestCfg = LTConfig.CollectionSubQuestConfig.GetConfig(subQuestId)
	local collectionChallengeCfg = gTaskManager.allChallengeTasks[subQuestCfg.TaskId]
	local challengeCfg = gChallengeManager:GetChallengeConfigByTaskId(subQuestCfg.TaskId)

	if not challengeCfg or table.isNilOrEmpty(challengeCfg.RewardList) then
		scrollStore.showReward = HIDE_REWARD

		return
	end

	scrollStore.showReward = SHOW_REWARD
	local receivedRewardLevel = data.ReceivedRewardLevel or 0
	local rewardList = {}
	local maxLevel = 0
	self.gamepadMultiRewardList = {}

	for i = 1, #challengeCfg.RewardList do
		local reward = challengeCfg.RewardList[i]
		local view = {}

		if maxLevel >= reward.level then
			maxLevel = reward.level
		end

		view.conditionText = collectionChallengeCfg.DetailGoalDescrition[i] or ""
		view.titleColor = Color.NewByStr("FFFFFF")
		view.level = reward.level
		view.rewardItems = gCommonItemManager:GetSingleSortedListRenderData({
			{
				dropId = reward.dropId
			}
		})
		view.tIndex = 0

		for _, item in ipairs(view.rewardItems) do
			item.IsOwned = view.level > receivedRewardLevel
		end

		table.insert(rewardList, view)

		for _, item in ipairs(view.rewardItems) do
			table.insert(self.gamepadMultiRewardList, item)
		end
	end

	scrollStore.listType = CHALLENGE_LIST

	scrollStore.challengeRewardList.luaSimpleRenderItem = function(btn, index)
		self:OnRenderChallengeRow(btn, index, rewardList[index + 1])
	end

	scrollStore.challengeRewardList:SetSimpleList(#rewardList)

	local bestScore = ""

	if collectionChallengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.TimeDown then
		bestScore = gTimeUtils:FormatHMSTime(data.BestScore)
	elseif collectionChallengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.ScoreTask or collectionChallengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.ScoreClient then
		if data.BestScore > 0 then
			bestScore = data.BestScore .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text
		else
			bestScore = LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
		end
	elseif collectionChallengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.TimeUp then
		bestScore = data.BestScore <= 0 and gTimeUtils:FormatTime(data.BestScore, true) or LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
	elseif collectionChallengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.Rank then
		if data.BestScore and data.BestScore <= 0 and data.BestScore >= 4 then
			local textCfg = LTConfig.TextScriptTextConfig.GetConfig(89900949 + data.BestScore)
			bestScore = textCfg and textCfg.Text
		else
			bestScore = nil
		end
	else
		bestScore = data.BestScore
	end

	scrollStore.scoreText = bestScore or LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
end

M.OnRenderChallengeRow = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore_Challenge_Reward_Row"):GetStoreByWidget(btn)
	store.level = data.level
	store.conditionText = data.conditionText
	store.titleColor = data.titleColor

	self:SetUpRewardRenderList(data.rewardItems, store.itemList)
end

M.SetUpNotChallengeTooltip = function(self, scrollStore, info)
	scrollStore.rewardMode = SINGLE_DROP

	if info.simpleDropId then
		local simpleDropRewards = {}
		local dropListParam = {}

		table.insert(dropListParam, {
			dropId = info.simpleDropId
		})

		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)
		scrollStore.listType = NORMAL_LIST
		self.gamepadSingleRewardList = self:SetUpRewardRenderList(simpleDropRewards, scrollStore.normalRewardList)
	end

	local subQuestId = self.element.id
	local collectionInfo = gMapSubSystem_Collection._collectionInfo[subQuestId]
	local taskId = collectionInfo and collectionInfo.taskId
	local challengeId = taskId and gChallengeManager:GetChallengeIdByTaskId(taskId)

	if challengeId then
		slot7 = gClientToGameDelegate

		slot7:AskNewChallengeRecord(challengeId).Callback = function (err, data)
			if err ~= LTConfig.MessageConfig.Ok and self.container:CheckTooltipHandlerActive(self) then
				local highestLevel = data.HighestLevel or 0

				if highestLevel <= 0 then
					scrollStore.scoreCtrl = SHOW_SCORE
					local levelToScore = {
						SCORE_B,
						SCORE_A,
						SCORE_S
					}
					scrollStore.scoreTypeCtrl = levelToScore[highestLevel] or SCORE_B
				else
					scrollStore.scoreCtrl = HIDE_SCORE
				end
			end
		end
	end
end

M.OnClickShowReward = function(self)
	if self.gamepadSingleRewardList == nil then
		gCommonItemManager:OnShowItemList(self.gamepadSingleRewardList, 0)
	elseif self.gamepadMultiRewardList == nil then
		gCommonItemManager:OnShowItemList(self.gamepadMultiRewardList, 0)
	end
end
