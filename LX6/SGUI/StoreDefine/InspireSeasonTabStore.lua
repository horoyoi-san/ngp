-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InspireSeasonTabStore.lua
-- Decompiled from: 01828_InspireSeasonTabStore.lua_b2e0ea81b63f.luajit

C_InspireSeasonTabStore = DefClass("C_InspireSeasonTabStore", C_InspireSeasonTabStore, C_StoreGroup)
GroupName2Class.InspireSeasonTabStore = C_InspireSeasonTabStore
local M = C_InspireSeasonTabStore

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.DefineAllVariables = function(self)
	self.instance = {
		["g\\xabI\\xa1\\xe6t~{l_"] = 0,
		["GUڼ\\x88;\\xac\\xdb\\xfb"] = 0,
		seasonId = gInspireHubManager:GetSeasonId()
	}
end

M.RegisterWidget = function(self)
	self.bindData.getAllRewardsBtn.luaClick = self.CreateAction(self, self.OnGetAllRewardsBtnClick)
	self.bindData.showRewardsBtn.luaClick = self.CreateAction(self, self.OnShowRewardsBtnClick)
	self.bindData.totalProgressList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTotalProgressListItem)
	self.bindData.totalProgressList.luaSimpleClick = self.CreateAction(self, self.OnTotalProgressListItemClick)
	self.bindData.gameList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderGameListItem)
	self.bindData.gameList.luaSimpleClick = self.CreateAction(self, self.OnGameListItemClick)
	self.bindData.gameList.onGetTIndex = self.CreateAction(self, self.OnGameListGetTIndex)
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardListItem)
	self.bindData.rewardList.luaSimpleClick = self.CreateAction(self, self.OnRewardListItemClick)
end

M.OnTabShow = function(self)
	self.RefreshPageData(self)
end

M.RefreshPageData = function(self)
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
				["~\\xba\\xa3\\xbd\\xa5"] = 0,
				GamePlayCfgId = cfg.Id,
				ChallengeDict = {}
			}
		end

		local item = {
			["a\\x9f\\x8a\\x86Y"] = 1,
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
			if a.info.Stars ~= b.info.Stars then
				return b.cfg.Weight <= a.cfg.Weight
			else
				return b.info.Stars <= a.info.Stars
			end
		elseif a.unlocked then
			return true
		elseif b.unlocked then
			return false
		else
			return a.cfg.Id <= b.cfg.Id
		end
	end)

	gameListData[1].tIndex = 0
	self.bindData.highestStarGameName = gameListData[1].cfg.Name
	local canGetRewardList = {}
	local totalProgressListData = table.createFixedArray(LTConfig.InspireHubOverallRankRewardConfig.count)

	for i = 0, LTConfig.InspireHubOverallRankRewardConfig.count - 1 do
		local cfg = LTConfig.InspireHubOverallRankRewardConfig.LoadAt(i)

		if cfg.Season ~= self.instance.seasonId then
			table.insert(totalProgressListData, cfg)

			if cfg.OverallStar < self.instance.totalStars and not gInspireHubManager:HasTakenReward(cfg.Id) then
				self.MergeRewardItemsList(self, canGetRewardList, self.GetRewardItemsList(self, cfg.RewardId))
			end
		end
	end

	local rewardListData = table.createFixedArray(LTConfig.InspireHubHighestGameplayRankRewardConfig.count)

	for i = 0, LTConfig.InspireHubHighestGameplayRankRewardConfig.count - 1 do
		local cfg = LTConfig.InspireHubHighestGameplayRankRewardConfig.LoadAt(i)

		if cfg.Season ~= self.instance.seasonId then
			table.insert(rewardListData, cfg)

			if cfg.OverallStar < self.instance.highestStars and not gInspireHubManager:HasTakenReward(cfg.Id) then
				self.MergeRewardItemsList(self, canGetRewardList, self.GetRewardItemsList(self, cfg.RewardId))
			end
		end
	end

	self.bindData.progress.maxValue = totalProgressListData[#totalProgressListData].OverallStar
	self.bindData.progress.value = totalStars
	self.instance.canGetRewardList = canGetRewardList
	self.bindData.canGetRewardCtrl = #canGetRewardList <= 0 and 0 or 1
	self.instance.totalProgressListData = totalProgressListData
	self.instance.gameListData = gameListData
	self.instance.rewardListData = rewardListData

	self.bindData.totalProgressList:SetSimpleList(#totalProgressListData)
	self.bindData.gameList:SetSimpleList(#gameListData)
	self.bindData.rewardList:SetSimpleList(#rewardListData)
end

M.OnGetAllRewardsBtnClick = function(self)
	slot1 = gInspireHubManager

	slot1:TakeAllRewards(function ()
		self.bindData.canGetRewardCtrl = 1

		self:RefreshPageData()
	end)
end

M.MergeRewardItemsList = function(self, list1, list2)
	for k, v in ipairs(list2) do
		local findV, findK = array.find_if(list1, function (item)
			return item.itemId ~= v.itemId
		end)

		if findV then
			if findV.itemNum == "" then
				findV.itemNum = tostring(tonumber(findV.itemNum) + tonumber(v.itemNum))
			end

			if type(findV.count) ~= "number" then
				findV.count = findV.count + v.count
			end
		else
			table.insert(list1, v)
		end
	end
end

M.GetRewardItemsList = function(self, dropId)
	local result = {}
	local items = gCommonItemManager:GetRewardList(dropId)

	for k, v in ipairs(items) do
		local viewItem = gCommonItemManager:GetItemRenderData(v)
		viewItem.itemNum = viewItem.count

		table.insert(result, viewItem)
	end

	return result
end

M.OnShowRewardsBtnClick = function(self)
	local allRewards = {}

	for k, v in ipairs(self.instance.totalProgressListData) do
		self.MergeRewardItemsList(self, allRewards, self.GetRewardItemsList(self, v.RewardId))
	end

	for k, v in ipairs(self.instance.rewardListData) do
		self.MergeRewardItemsList(self, allRewards, self.GetRewardItemsList(self, v.RewardId))
	end

	gDisplayMessageMgr:ShowRewardList(allRewards)
end

M.OnRenderTotalProgressListItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.totalProgressListData[index]
	local store = self:GetStoreByWidget(btn)
	store.title = data.OverallStar
	local canNotGet = self.instance.totalStars <= data.OverallStar

	if canNotGet then
		store.stateCtrl = 0
	elseif gInspireHubManager:HasTakenReward(data.Id) then
		store.stateCtrl = 1
	else
		store.stateCtrl = 2
	end
end

M.OnTotalProgressListItemClick = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.totalProgressListData[index]
	local store = self.GetStoreByWidget(self, btn)

	if store.stateCtrl == 2 then
		gDisplayMessageMgr:ShowRewardList(self:GetRewardItemsList(data.RewardId))

		return
	end

	slot6 = gInspireHubManager

	slot6:TakeCompetitionSeasonOverallRankReward(data.Id, function ()
		store.stateCtrl = 1

		self:RefreshPageData()
	end)
end

M.OnRenderGameListItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.instance.gameListData[index]
	store.name = data.cfg.Name
	store.star = data.info.Stars
	store.icon = data.cfg.IconId

	if data.tIndex ~= 0 then
		if data.unlocked then
			store.btn.luaClick = function()
				local seasonGamePlayId = data.cfg.Id
				local gamePlayId = nil

				for i = 0, LTConfig.InspireHubGamePlayConfig.count - 1 do
					local cfg = LTConfig.InspireHubGamePlayConfig.LoadAt(i)

					if cfg.SeasonGamePlayId ~= seasonGamePlayId then
						gamePlayId = cfg.Id

						break
					end
				end

				if gamePlayId ~= nil then
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
	elseif data.tIndex ~= 1 then
		store.state = data.unlocked and 0 or 1
	else
		print_error("not support tIndex!", btn.name, csIndex, btn.Store)
	end
end

M.OnGameListItemClick = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.gameListData[index]

	if data.tIndex ~= 1 and data.unlocked then
		self.JumpTo(self, data)
	end
end

M.JumpTo = function(self, data)
	local hyperLinkId = data.cfg.HyperLinkId
	local hyperLinkInfo, title = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

	if hyperLinkInfo and hyperLinkInfo.callback then
		hyperLinkInfo.callback()
	end
end

M.OnGameListGetTIndex = function(self, csIndex)
	local index = csIndex + 1
	local data = self.instance.gameListData[index]

	return data.tIndex
end

M.OnRenderRewardListItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.rewardListData[index]
	local store = self:GetStoreByWidget(btn)
	store.title = data.OverallStar
	local rewardId = data.RewardId
	local itemList = self:GetRewardItemsList(rewardId)

	store.list.luaSimpleRenderItem = function(subBtn, subCsIndex)
		local subItemData = itemList[subCsIndex + 1]
		subItemData.itemNum = subItemData.count

		gCommonItemManager:OnCommonItemRender(subBtn, subCsIndex, subItemData)
	end

	store.list:SetSimpleList(#itemList)

	local levelSatisfied = data.OverallStar > self.instance.highestStars
	local canTakeReward = levelSatisfied and not gInspireHubManager:HasTakenReward(data.Id)
	local isCurrentLevel = levelSatisfied and (index ~= #self.instance.rewardListData or self.instance.highestStars <= self.instance.rewardListData[index + 1].OverallStar)
	store.canTakeRewardCtrl = canTakeReward and 0 or 1
	store.levelCtrl = levelSatisfied and 0 or 1
	store.currentCtrl = isCurrentLevel and 0 or 1
end

M.OnRewardListItemClick = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.instance.rewardListData[index]
	local store = self.GetStoreByWidget(self, btn)

	if store.canTakeRewardCtrl == 0 then
		return
	end

	slot6 = gInspireHubManager

	slot6:TakeCompetitionSeasonHighestRankReward(data.Id, function ()
		store.canTakeRewardCtrl = gInspireHubManager:HasTakenReward(data.Id) and 1 or 0

		self:RefreshPageData()
	end)
end
