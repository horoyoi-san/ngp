C_InspireSeasonTabStore = DefClass("C_InspireSeasonTabStore", C_InspireSeasonTabStore, C_StoreGroup)
GroupName2Class.InspireSeasonTabStore = C_InspireSeasonTabStore
local M = C_InspireSeasonTabStore

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
end

function M:DefineAllVariables()
	self.instance = {
		highestStars = 0,
		totalStars = 0,
		seasonId = gInspireHubManager:GetSeasonId()
	}
end

function M:RegisterWidget()
	self.bindData.getAllRewardsBtn.luaClick = self:CreateAction(self.OnGetAllRewardsBtnClick)
	self.bindData.showRewardsBtn.luaClick = self:CreateAction(self.OnShowRewardsBtnClick)
	self.bindData.totalProgressList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTotalProgressListItem)
	self.bindData.totalProgressList.luaSimpleClick = self:CreateAction(self.OnTotalProgressListItemClick)
	self.bindData.gameList.luaSimpleRenderItem = self:CreateAction(self.OnRenderGameListItem)
	self.bindData.gameList.luaSimpleClick = self:CreateAction(self.OnGameListItemClick)
	self.bindData.gameList.onGetTIndex = self:CreateAction(self.OnGameListGetTIndex)
	self.bindData.rewardList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRewardListItem)
	self.bindData.rewardList.luaSimpleClick = self:CreateAction(self.OnRewardListItemClick)
end

function M:OnTabShow()
	self:RefreshPageData()
end

function M:RefreshPageData()
	local seasonCfg = LTConfig.InspireHubSeasonConfig.GetConfig(self.instance.seasonId)
	self.bindData.gameName = seasonCfg.SeasonName
	self.bindData.gameDescription = seasonCfg.SeasonDes
	self.bindData.gameTimeCountdown = gInspireHubManager:GetTimeCountDownStr()
	local totalStars = 0
	local highestStars = 0
	local gameListData = {}

	for i = 0, LTConfig.InspireHubSeasonGamePlayConfig.count - 1 do
		local cfg = LTConfig.InspireHubSeasonGamePlayConfig.LoadAt(i)
		local unlocked = gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.CompetitionSeasonGameplay)

		if not gInspireHubManager:GetGamePlayInfo(cfg.Id) then
			local info = {
				Stars = 0,
				GamePlayCfgId = cfg.Id,
				ChallengeDict = {}
			}
		end

		local item = {
			tIndex = 1,
			cfg = cfg,
			unlocked = unlocked,
			info = info
		}
		totalStars = totalStars + info.Stars
		highestStars = math.max(highestStars, info.Stars)

		table.insert(gameListData, item)
	end

	self.instance.totalStars = totalStars
	self.instance.highestStars = highestStars

	table.sort(gameListData, function (a, b)
		if a.unlocked and b.unlocked then
			if a.info.Stars == b.info.Stars then
				return b.cfg.Weight < a.cfg.Weight
			else
				return b.info.Stars < a.info.Stars
			end
		elseif a.unlocked then
			return true
		elseif b.unlocked then
			return false
		else
			return a.cfg.Id < b.cfg.Id
		end
	end)

	gameListData[1].tIndex = 0
	self.bindData.highestStarGameName = gameListData[1].cfg.Name
	local canGetRewardList = {}
	local totalProgressListData = table.createFixedArray(LTConfig.InspireHubOverallRankRewardConfig.count)

	for i = 0, LTConfig.InspireHubOverallRankRewardConfig.count - 1 do
		local cfg = LTConfig.InspireHubOverallRankRewardConfig.LoadAt(i)

		if cfg.Season == self.instance.seasonId then
			table.insert(totalProgressListData, cfg)

			if cfg.OverallStar <= self.instance.totalStars and not gInspireHubManager:HasTakenReward(cfg.Id) then
				self:MergeRewardItemsList(canGetRewardList, self:GetRewardItemsList(cfg.RewardId))
			end
		end
	end

	local rewardListData = table.createFixedArray(LTConfig.InspireHubHighestGameplayRankRewardConfig.count)

	for i = 0, LTConfig.InspireHubHighestGameplayRankRewardConfig.count - 1 do
		local cfg = LTConfig.InspireHubHighestGameplayRankRewardConfig.LoadAt(i)

		if cfg.Season == self.instance.seasonId then
			table.insert(rewardListData, cfg)

			if cfg.OverallStar <= self.instance.highestStars and not gInspireHubManager:HasTakenReward(cfg.Id) then
				self:MergeRewardItemsList(canGetRewardList, self:GetRewardItemsList(cfg.RewardId))
			end
		end
	end

	self.bindData.progress.maxValue = totalProgressListData[#totalProgressListData].OverallStar
	self.bindData.progress.value = totalStars
	self.instance.canGetRewardList = canGetRewardList
	self.bindData.canGetRewardCtrl = #canGetRewardList > 0 and 0 or 1
	self.instance.totalProgressListData = totalProgressListData
	self.instance.gameListData = gameListData
	self.instance.rewardListData = rewardListData

	self.bindData.totalProgressList:SetSimpleList(#totalProgressListData)
	self.bindData.gameList:SetSimpleList(#gameListData)
	self.bindData.rewardList:SetSimpleList(#rewardListData)
end

function M:OnGetAllRewardsBtnClick()
	gInspireHubManager:TakeAllRewards(function ()
		self.bindData.canGetRewardCtrl = 1

		self:RefreshPageData()
	end)
end

function M:MergeRewardItemsList(list1, list2)
	for k, v in ipairs(list2) do
		local findV, findK = array.find_if(list1, function (item)
			return item.itemId == v.itemId
		end)

		if findV then
			if findV.itemNum ~= "" then
				findV.itemNum = tostring(tonumber(findV.itemNum) + tonumber(v.itemNum))
			end

			if type(findV.count) == "number" then
				findV.count = findV.count + v.count
			end
		else
			table.insert(list1, v)
		end
	end
end

function M:GetRewardItemsList(dropId)
	local result = {}
	local items = gCommonItemManager:GetRewardList(dropId)

	for k, v in ipairs(items) do
		local viewItem = gCommonItemManager:GetItemRenderData(v)
		viewItem.itemNum = viewItem.count

		table.insert(result, viewItem)
	end

	return result
end

function M:OnShowRewardsBtnClick()
	local allRewards = {}

	for k, v in ipairs(self.instance.totalProgressListData) do
		self:MergeRewardItemsList(allRewards, self:GetRewardItemsList(v.RewardId))
	end

	for k, v in ipairs(self.instance.rewardListData) do
		self:MergeRewardItemsList(allRewards, self:GetRewardItemsList(v.RewardId))
	end

	gDisplayMessageMgr:ShowRewardList(allRewards)
end

function M:OnRenderTotalProgressListItem(btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.totalProgressListData[index]
	local store = self:GetStoreByWidget(btn)
	store.title = data.OverallStar
	local canNotGet = self.instance.totalStars < data.OverallStar

	if canNotGet then
		store.stateCtrl = 0
	elseif gInspireHubManager:HasTakenReward(data.Id) then
		store.stateCtrl = 1
	else
		store.stateCtrl = 2
	end
end

function M:OnTotalProgressListItemClick(btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.totalProgressListData[index]
	local store = self:GetStoreByWidget(btn)

	if store.stateCtrl ~= 2 then
		gDisplayMessageMgr:ShowRewardList(self:GetRewardItemsList(data.RewardId))

		return
	end

	gInspireHubManager:TakeCompetitionSeasonOverallRankReward(data.Id, function ()
		store.stateCtrl = 1

		self:RefreshPageData()
	end)
end

function M:OnRenderGameListItem(btn, csIndex)
	local index = csIndex + 1
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.instance.gameListData[index]
	store.name = data.cfg.Name
	store.star = data.info.Stars
	store.icon = data.cfg.IconId

	if data.tIndex == 0 then
		if data.unlocked then
			function store.btn.luaClick()
				local seasonGamePlayId = data.cfg.Id
				local gamePlayId = nil

				for i = 0, LTConfig.InspireHubGamePlayConfig.count - 1 do
					local cfg = LTConfig.InspireHubGamePlayConfig.LoadAt(i)

					if cfg.SeasonGamePlayId == seasonGamePlayId then
						gamePlayId = cfg.Id

						break
					end
				end

				if gamePlayId == nil then
					print_error("not found gamePlayId!", seasonGamePlayId)

					return
				end

				local params = {
					seasonId = self.instance.seasonId,
					gamePlayId = gamePlayId
				}

				gPanelManager:CheckShow(gPanelId.TRIAL_PANEL, params)
			end
		end
	elseif data.tIndex == 1 then
		store.state = data.unlocked and 0 or 1
	else
		print_error("not support tIndex!", btn.name, csIndex, btn.Store)
	end
end

function M:OnGameListItemClick(btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.gameListData[index]

	if data.tIndex == 1 and data.unlocked then
		self:JumpTo(data)
	end
end

function M:JumpTo(data)
	local hyperLinkId = data.cfg.HyperLinkId
	local hyperLinkInfo, title = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

	if hyperLinkInfo and hyperLinkInfo.callback then
		hyperLinkInfo.callback()
	end
end

function M:OnGameListGetTIndex(csIndex)
	local index = csIndex + 1
	local data = self.instance.gameListData[index]

	return data.tIndex
end

function M:OnRenderRewardListItem(btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.rewardListData[index]
	local store = self:GetStoreByWidget(btn)
	store.title = data.OverallStar
	local rewardId = data.RewardId
	local itemList = self:GetRewardItemsList(rewardId)

	function store.list.luaSimpleRenderItem(subBtn, subCsIndex)
		local subItemData = itemList[subCsIndex + 1]
		subItemData.itemNum = subItemData.count

		gCommonItemManager:OnCommonItemRender(subBtn, subCsIndex, subItemData)
	end

	store.list:SetSimpleList(#itemList)

	local levelSatisfied = data.OverallStar <= self.instance.highestStars
	local canTakeReward = levelSatisfied and not gInspireHubManager:HasTakenReward(data.Id)
	local isCurrentLevel = levelSatisfied and (index == #self.instance.rewardListData or self.instance.highestStars < self.instance.rewardListData[index + 1].OverallStar)
	store.canTakeRewardCtrl = canTakeReward and 0 or 1
	store.levelCtrl = levelSatisfied and 0 or 1
	store.currentCtrl = isCurrentLevel and 0 or 1
end

function M:OnRewardListItemClick(btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.rewardListData[index]
	local store = self:GetStoreByWidget(btn)

	if store.canTakeRewardCtrl ~= 0 then
		return
	end

	gInspireHubManager:TakeCompetitionSeasonHighestRankReward(data.Id, function ()
		store.canTakeRewardCtrl = gInspireHubManager:HasTakenReward(data.Id) and 1 or 0

		self:RefreshPageData()
	end)
end
