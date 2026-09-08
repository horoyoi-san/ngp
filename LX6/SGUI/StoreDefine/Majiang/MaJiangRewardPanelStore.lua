-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MaJiangRewardPanelStore.lua
-- Decompiled from: 01220_MaJiangRewardPanelStore.lua_ea8a819b3b75.luajit

C_MaJiangRewardPanelStore = DefClass("C_MaJiangRewardPanelStore", C_MaJiangRewardPanelStore, C_StoreGroup)
GroupName2Class.MaJiangRewardPanelStore = C_MaJiangRewardPanelStore
local M = C_MaJiangRewardPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardItem)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.rewardListData = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.rewardListData = gMaJiangManager:GetRewardList()

	self.bindData.rewardList:SetSimpleList(#self.rewardListData)
end

M.OnClose = function(self)
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_MA_JIANG_REWARD_PANEL)
end

M.OnRenderRewardItem = function(self, btn, csIndex)
	local data = self.rewardListData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)
	store.rankName = data.rankingName
	store.rankScore = data.score
	store.rewardType = data.rewardState
	store.rewardIconId = data.icon

	gCommonItemManager:InitRenderList(store.awardList)

	local awardList = gCommonItemManager:GetSingleSortedListRenderData(data.dropId)

	store.awardList:SetSimpleList(#awardList)

	store.receiveBtn.luaClick = function()
		gMaJiangManager:AskGetMahjongRankReward(data.rank, function ()
			data.rewardState = 0
			store.rewardType = data.rewardState
		end)
	end

	store.showRewardBtn.luaClick = self:CreateActionWithArgs("OnShowItemList", awardList, gCommonItemManager)
end
