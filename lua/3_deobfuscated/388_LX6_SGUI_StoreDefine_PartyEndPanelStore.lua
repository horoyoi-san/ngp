C_PartyEndPanelStore = DefClass("C_PartyEndPanelStore", C_PartyEndPanelStore, C_StoreGroup)
GroupName2Class.PartyEndPanelStore = C_PartyEndPanelStore
local M = C_PartyEndPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.rewardButton.luaClick = self:CreateAction("OnClickRewardButton")
	self.bindData.exitButton.luaClick = self:CreateAction("OnClickExitButton")
	self.bindData.scoreList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderScoreListItem")
	self.bindData.rewardList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderRewardListItem")
	self.bindData.likeList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderLikeListItem")
	self.bindData.scoreList.luaSimpleClick = self:CreateAction("OnSimpleClickScoreList")
	self.bindData.rewardList.luaSimpleClick = self:CreateAction("OnSimpleClickRewardList")
	self.bindData.likeList.luaSimpleClick = self:CreateAction("OnSimpleClickLikeList")
end

function M:OnShow(_, data)
	self:InitModel(data)
	self:InitView()
end

function M:InitModel(data)
	self.settleData = data
	self.countdownTime = LTConfig.PartyConfig.CountdownTime
end

function M:InitView()
	self:RefreshPopularityLevelView()
	self:RefreshTitleView()
	self:RefreshScoreListView()
	self:StartCountdownView()
end

function M:StartCountdownView()
	self.startCountdownCo = coroutine.stop(self.startCountdownCo)
	self.startCountdownCo = coroutine.start(function ()
		while self.countdownTime > 0 do
			if self.bindData.pageControl == 0 then
				self.bindData.rewardCountdown = LTConfig.PartyConfig.RewardCountdownText:format(self.countdownTime)
			else
				self.bindData.exitCountdown = LTConfig.PartyConfig.ExitCountdownText:format(self.countdownTime)
			end

			coroutine.wait(1)

			self.countdownTime = self.countdownTime - 1
		end

		if self.bindData.pageControl == 0 then
			self:OnClickRewardButton()
		elseif self.bindData.pageControl == 1 then
			self:OnClickExitButton()
		end
	end)
end

function M:RefreshPopularityLevelView()
	self.bindData.pageControl = self:GetPopularityControlValue()
end

function M:GetPopularityControlValue()
	local popularity = self.settleData.Popularity
	local partyCfg = LTConfig.PartyConfig.GetConfig(self.settleData.PartyId)
	local popularityLevelList = partyCfg.PopularityLevel

	for i = #popularityLevelList, 1, -1 do
		if popularityLevelList[i] <= popularity then
			return #popularityLevelList - i
		end
	end

	return #popularityLevelList
end

function M:RefreshTitleView()
	local partyCfg = LTConfig.PartyConfig.GetConfig(self.settleData.PartyId)
	local partyTypeId = partyCfg.Type
	local partyTypeCfg = LTConfig.PartyPartyTypeConfig.GetConfig(partyTypeId)
	self.bindData.title = partyTypeCfg.Name
end

function M:RefreshScoreListView()
	self.scoreViewDataList = self:GetScoreViewDataList()

	function self.bindData.scoreList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.scoreViewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.scoreList:SetSimpleList(#self.scoreViewDataList)
end

function M:RefreshRewardListView()
	local dropId = self.settleData.Drop
	self.dropItemList = gCommonItemManager:GetSingleSortedListRenderData(dropId)

	self.bindData.rewardList:SetSimpleList(#self.dropItemList)
	self.bindData.likeList:SetSimpleList(self.settleData.LikeCount)
end

function M:GetScoreViewDataList()
	local viewDataList = {}

	table.insert(viewDataList, {
		tIndex = 0,
		text = LTConfig.PartyConfig.LiveSettlement
	})
	table.insert(viewDataList, {
		tIndex = 1,
		text = LTConfig.PartyConfig.AudienceCountText,
		count = self.settleData.AudienceCount
	})
	table.insert(viewDataList, {
		tIndex = 1,
		text = LTConfig.PartyConfig.CommentCountText,
		count = self.settleData.CommentCount
	})
	table.insert(viewDataList, {
		tIndex = 1,
		text = LTConfig.PartyConfig.LikeCountText,
		count = self.settleData.LikeCount
	})
	table.insert(viewDataList, {
		tIndex = 1,
		text = LTConfig.PartyConfig.GiftCountText,
		count = self.settleData.GiftCount
	})
	table.insert(viewDataList, {
		tIndex = 0,
		text = LTConfig.PartyConfig.GameplaySettlement
	})
	table.insert(viewDataList, {
		tIndex = 1,
		text = LTConfig.PartyConfig.WinGameCountText,
		count = self.settleData.WinGameCount
	})
	table.insert(viewDataList, {
		tIndex = 1,
		text = LTConfig.PartyConfig.TaskCountText,
		count = self.settleData.TaskCount
	})
	table.insert(viewDataList, {
		tIndex = 1,
		text = LTConfig.PartyConfig.InviteFriendCountText,
		count = self.settleData.InviteFriendCount
	})

	return viewDataList
end

function M:OnClickRewardButton()
	self.countdownTime = LTConfig.PartyConfig.CountdownTime

	self:StartCountdownView()

	self.bindData.pageControl = 1

	self:RefreshRewardListView()
end

function M:OnClickExitButton()
	gPanelManager:Close(self.m_Id)
end

function M:OnSimpleRenderScoreListItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.scoreViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.title = data.text

	if data.tIndex == 1 then
		store.score = data.count
	end
end

function M:OnSimpleClickScoreList(btn, index)
	return
end

function M:OnSimpleRenderRewardListItem(btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local data = self.dropItemList[luaIndex]

	gCommonItemManager:OnCommonItemRender(btn, nil, data)
end

function M:OnSimpleClickRewardList(btn, index)
	return
end

function M:OnSimpleRenderLikeListItem(btn, index)
	local npcId = self.settleData.InviteNPCList[index + 1]
	local cultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.iconId = cultivationCfg.HeadiconId
end

function M:OnSimpleClickLikeList(btn, index)
	return
end

function M:OnDestroy()
	self.startCountdownCo = coroutine.stop(self.startCountdownCo)

	self:ClearMessageEvents()
end
