C_BigMapTooltip_Collection = DefClass("C_BigMapTooltip_Collection", C_BigMapTooltip_Collection, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Collection
local CHALLENGE_LIST = 0
local NORMAL_LIST = 1

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("collectionInfo") then
		return
	end

	self.gamepadSingleRewardList = nil
	self.gamepadMultiRewardList = nil

	self:GetStore("MapCollectionTooltipStore")

	local info = self.tooltipInfo.collectionInfo

	self:SetUpHeader()
	self:SetUpLocation()
	self:SetUpSpecificSpirits(info)

	if info.abilityIds and #info.abilityIds > 0 then
		self.store.addAbility = 1

		self:SetUpAbilityList(self.store.normalAbilityList, info.abilityIds)
		self:SetUpAbilityList(self.store.characterAbilityList, info.abilityIds)
	else
		self.store.addAbility = 0
	end

	local scrollStore = nil

	if info.specificSpirits and #info.specificSpirits > 0 then
		self.store.spiritScroll:GoToPos(Vector2.zero, true)

		scrollStore = gStoreManager:GetStoreGroup("MapCollectionScrollStore"):GetStoreByWidget(self.store.spiritScroll.content)
	else
		self.store.normalScroll:GoToPos(Vector2.zero, true)

		scrollStore = gStoreManager:GetStoreGroup("MapCollectionScrollStore"):GetStoreByWidget(self.store.normalScroll.content)
	end

	self:SetUpScroll(scrollStore, info)
end

function M:SetUpScroll(scrollStore, info)
	scrollStore.desc = info.desc or ""

	if info.isChallenge then
		self:SetUpChallengeTooltip(scrollStore, info)
	else
		self:SetUpNotChallengeTooltip(scrollStore, info)
	end

	scrollStore.clickShowReward = self.bigMap:CreateAction("OnClickShowReward", self)
end

function M:SetUpLocation()
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(self.element.raidId, self.element:GetWorldPos().x, self.element:GetWorldPos().z)

	if blockId then
		local cfg = LTConfig.CollectionBlockConfig.GetConfig(blockId)
		self.store.spiritLocation = cfg and cfg.BlockName or ""
		self.store.normalLocation = cfg and cfg.BlockName or ""
	end
end

local SINGLE_DROP = 1
local MULTI_DROP = 2

function M:SetUpChallengeTooltip(scrollStore, info)
	local challengeId = info.challengeId
	scrollStore.rewardMode = MULTI_DROP

	gClientToGameDelegate:AskNewChallengeRecord(challengeId).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok and self.container:CheckTooltipHandlerActive(self) and self.tooltipInfo.collectionInfo.challengeId == challengeId then
			self:SetupChallengeListInfo(scrollStore, data)
		end
	end
end

function M:SetupChallengeListInfo(scrollStore, data)
	local store = self.store
	local subQuestId = self.tooltipInfo.collectionInfo.subQuestId
	local subQuestCfg = LTConfig.CollectionSubQuestConfig.GetConfig(subQuestId)
	local challengeCfg = gTaskManager.allChallengeTasks[subQuestCfg.TaskId]
	local receivedRewardLevel = data.ReceivedRewardLevel or 0
	local rewardList = {}
	local maxLevel = 0
	self.gamepadMultiRewardList = {}

	for i = 1, #challengeCfg.RewardList do
		local reward = challengeCfg.RewardList[i]
		local view = {}

		if maxLevel < reward.level then
			maxLevel = reward.level
		end

		view.conditionText = challengeCfg.DetailGoalDescrition[i] or ""
		view.titleColor = Color.NewByStr("FFFFFF")
		view.level = reward.level
		view.rewardItems = gCommonItemManager:GetSingleSortedListRenderData({
			{
				dropId = reward.dropId
			}
		})
		view.tIndex = 0

		for _, item in ipairs(view.rewardItems) do
			item.IsOwned = view.level <= receivedRewardLevel
		end

		table.insert(rewardList, view)

		for _, item in ipairs(view.rewardItems) do
			table.insert(self.gamepadMultiRewardList, item)
		end
	end

	scrollStore.listType = CHALLENGE_LIST

	function scrollStore.challengeRewardList.luaSimpleRenderItem(btn, index)
		self:OnRenderChallengeRow(btn, index, rewardList[index + 1])
	end

	scrollStore.challengeRewardList:SetSimpleList(#rewardList)

	local bestScore = ""

	if challengeCfg.TargetSource == gTaskManager.ChallengeTargetType.TimeDown then
		bestScore = gTimeUtils:FormatHMSTime(data.BestScore)
	elseif challengeCfg.TargetSource == gTaskManager.ChallengeTargetType.ScoreTask or challengeCfg.TargetSource == gTaskManager.ChallengeTargetType.ScoreClient then
		if data.BestScore >= 0 then
			bestScore = data.BestScore .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text
		else
			bestScore = LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
		end
	elseif challengeCfg.TargetSource == gTaskManager.ChallengeTargetType.TimeUp then
		bestScore = data.BestScore > 0 and gTimeUtils:FormatTime(data.BestScore, true) or LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
	elseif challengeCfg.TargetSource == gTaskManager.ChallengeTargetType.Rank then
		if data.BestScore and data.BestScore > 0 and data.BestScore < 4 then
			local textCfg = LTConfig.TextScriptTextConfig.GetConfig(89900949 + data.BestScore)
			bestScore = textCfg and textCfg.Text
		else
			bestScore = nil
		end
	else
		bestScore = data.BestScore
	end

	self.store.normalScoreText = bestScore or LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
	self.store.spiritScoreText = bestScore or LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
end

function M:OnRenderChallengeRow(btn, index, data)
	local store = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore_Challenge_Reward_Row"):GetStoreByWidget(btn)
	store.level = data.level
	store.conditionText = data.conditionText
	store.titleColor = data.titleColor

	function store.itemList.luaSimpleRenderItem(itemBtn, itemIndex)
		gCommonItemManager:OnCommonItemRender(itemBtn, itemIndex, data.rewardItems[itemIndex + 1])
	end

	store.itemList:SetSimpleList(#data.rewardItems)
end

function M:SetUpNotChallengeTooltip(scrollStore, info)
	scrollStore.rewardMode = SINGLE_DROP

	if info.simpleDropId then
		local simpleDropRewards = {}
		local dropListParam = {}

		table.insert(dropListParam, {
			dropId = info.simpleDropId
		})

		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)
		scrollStore.listType = NORMAL_LIST

		function scrollStore.normalRewardList.luaSimpleRenderItem(itemBtn, itemIndex)
			gCommonItemManager:OnCommonItemRender(itemBtn, itemIndex, simpleDropRewards[itemIndex + 1])
		end

		scrollStore.normalRewardList:SetSimpleList(#simpleDropRewards)

		self.gamepadSingleRewardList = simpleDropRewards
	end
end

function M:OnClickShowReward()
	if self.gamepadSingleRewardList ~= nil then
		gCommonItemManager:OnShowItemList(self.gamepadSingleRewardList, 0)
	elseif self.gamepadMultiRewardList ~= nil then
		gCommonItemManager:OnShowItemList(self.gamepadMultiRewardList, 0)
	end
end
