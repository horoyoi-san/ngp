C_MaJiangRewardPanelStore = DefClass("C_MaJiangRewardPanelStore", C_MaJiangRewardPanelStore, C_StoreGroup)
GroupName2Class.MaJiangRewardPanelStore = C_MaJiangRewardPanelStore
local M = C_MaJiangRewardPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.rewardList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRewardItem)
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.rewardListData = gMaJiangManager:GetRewardList()

	self.bindData.rewardList:SetSimpleList(#self.rewardListData)
end

function M:OnClose()
	return
end

function M:OnCloseBtnClick()
	gPanelManager:Close(gPanelId.S_MA_JIANG_REWARD_PANEL)
end

function M:OnRenderRewardItem(btn, csIndex)
	local data = self.rewardListData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.rankName = data.rankingName
	store.rankScore = data.score
	store.rewardType = data.rewardState
	store.rewardIconId = data.icon

	gCommonItemManager:InitRenderList(store.awardList)

	local awardList = gCommonItemManager:GetSingleSortedListRenderData(data.dropId)

	store.awardList:SetList(awardList)

	function store.receiveBtn.luaClick()
		gMaJiangManager:AskGetMahjongRankReward(data.rank, function ()
			data.rewardState = 0
			store.rewardType = data.rewardState
		end)
	end

	store.showRewardBtn.luaClick = self:CreateActionWithArgs("OnShowItemList", awardList, gCommonItemManager)
end
