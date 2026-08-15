C_ItemRewardCommonListStore = DefClass("C_ItemRewardCommonListStore", C_ItemRewardCommonListStore, C_StoreGroup)
GroupName2Class.ItemRewardCommonListStore = C_ItemRewardCommonListStore
local M = C_ItemRewardCommonListStore

function M:ctor()
	self.btnCallback = nil
end

function M:OnAwake()
	self.showList = {}
	self.bindData.rewardList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRewardItem)
	self.bindData.randomList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRandomItem)
	self.bindData.rewardBtn.luaClick = self:CreateAction("OnRewardBtnClick")
	self.bindData.randomBtn.luaClick = self:CreateAction("OnRewardBtnClick")
	self.bindData.stickBtn.luaClick = self:CreateAction("OnStickBtnClick")
	self.rewardList = {}
	self.randomList = {}
end

local STATE_CTL = {
	HIDE = 3,
	REWARD = 2,
	RANDOM = 1,
	BOTH = 0
}

function M:OnRenderRewardItem(btn, index)
	local data = self.rewardList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

function M:OnRenderRandomItem(btn, index)
	local data = self.randomList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

function M:OnRewardBtnClick()
	if self.btnCallback then
		self.btnCallback()
	end
end

function M:OnStickBtnClick()
	gCommonItemManager:OnShowItemList(self.showList)
end

function M:OnInit(data)
	self.btnCallback = data.btnCallback
	self.bindData.hasBtn = data.btnCallback ~= nil and 0 or 1
	local rewardList, randomList = gCommonItemManager:GetItemSortedListByDropList(data.data)
	self.randomList = {}
	self.rewardList = {}

	for i = 1, #rewardList do
		local view = {
			itemId = rewardList[i].Id,
			itemNum = rewardList[i].Count,
			countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP,
			spiritId = rewardList[i].spiritId,
			isFirstKill = rewardList[i].isFirstKill
		}

		table.insert(self.rewardList, gCommonItemManager:GetItemRenderData(view))
	end

	for i = 1, #randomList do
		local view = {
			itemId = randomList[i].Id,
			itemNum = randomList[i].Count,
			countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP,
			spiritId = randomList[i].spiritId,
			isFirstKill = randomList[i].isFirstKill
		}

		table.insert(self.randomList, gCommonItemManager:GetItemRenderData(view))
	end

	local hideShowRandom = table.isNilOrEmpty(self.randomList)
	local hideShowReward = table.isNilOrEmpty(self.rewardList)

	if hideShowRandom and hideShowReward then
		self.bindData.showType = STATE_CTL.HIDE
	elseif hideShowReward then
		self.bindData.showType = STATE_CTL.RANDOM
	elseif hideShowRandom then
		self.bindData.showType = STATE_CTL.REWARD
	else
		self.bindData.showType = STATE_CTL.BOTH
	end

	self.bindData.randomList:SetSimpleList(#self.randomList)
	self.bindData.rewardList:SetSimpleList(#self.rewardList)

	self.showList = array.concat(self.rewardList, self.randomList)
end
