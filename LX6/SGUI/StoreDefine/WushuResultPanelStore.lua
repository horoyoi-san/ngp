-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WushuResultPanelStore.lua
-- Decompiled from: 01191_WushuResultPanelStore.lua_9c65ed95e39a.luajit

C_WushuResultPanelStore = DefClass("C_WushuResultPanelStore", C_WushuResultPanelStore, C_StoreGroup)
GroupName2Class.WushuResultPanelStore = C_WushuResultPanelStore
local M = C_WushuResultPanelStore

M.ctor = function(self)
	self.settlementInfo = nil
	self.starResults = nil
	self.roundCfg = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	self.settlementInfo = data.settlementInfo
	self.starResults = data.starResults
	self.roundCfg = data.roundCfg

	self.Refresh(self)
end

M.OnClose = function(self)
	gWushuTournamentManager:OnSettlePanelExit()
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.nextBtn.luaClick = self.CreateAction(self, self.OnClickNextBtn)
	self.bindData.againBtn.luaClick = self.CreateAction(self, self.OnClickAgainBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.goalList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderGoalListItem)
	self.bindData.starList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderStarListItem)
	self.bindData.goalList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickGoalList)
	self.bindData.starList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickStarList)
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderRewardItem)
end

M.OnClickNextBtn = function(self)
	local action = UX.Game.WushuTournamentPostSettlementAction.Next

	gWushuTournamentManager:RequestPostSettlement(self.settlementInfo.RoundId, action)
end

M.OnClickAgainBtn = function(self)
	local action = UX.Game.WushuTournamentPostSettlementAction.Retry

	gWushuTournamentManager:RequestPostSettlement(self.settlementInfo.RoundId, action)
end

M.OnClickBackBtn = function(self)
	local action = UX.Game.WushuTournamentPostSettlementAction.Exit

	gWushuTournamentManager:RequestPostSettlement(self.settlementInfo.RoundId, action)
end

M.OnSimpleRenderGoalListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local achieved = self.starResults and self.starResults[index + 1]
	store.isCheckCtrl = achieved and 1 or 0
	local target = self.roundCfg and self.roundCfg.ChallengeTargets[index + 1] or ""
	local value = self.roundCfg and self.roundCfg.CounterValues[index + 1] or 0
	store.goalText = string.gsub(target, "%%s", tostring(value))
end

M.OnSimpleRenderStarListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local achieved = self.starResults and self.starResults[index + 1]
	store.finishCtrl = achieved and 1 or 0
end

M.OnSimpleRenderRewardItem = function(self, btn, index)
	gCommonItemManager:OnCommonItemRender(btn, index, self.rewardRenderDataList and self.rewardRenderDataList[index + 1])
end

M.OnSimpleClickGoalList = function(self, btn, index)
end

M.OnSimpleClickStarList = function(self, btn, index)
end

M.Refresh = function(self)
	self.bindData.starList:SetSimpleList(3)

	local targetCount = self.roundCfg and #self.roundCfg.ChallengeTargets or 0

	self.bindData.goalList:SetSimpleList(targetCount)

	local dropDataList = {}

	for k, v in ipairs(self.settlementInfo.RewardList) do
		table.insert(dropDataList, {
			dropId = v
		})
	end

	local itemInfoList = gCommonItemManager:GetItemSortedListByDropList(dropDataList, true) or {}
	local itemRenderDataList = {}

	for i = 1, #itemInfoList do
		local item = itemInfoList[i]
		local renderData = gCommonItemManager:GetItemRenderData({
			itemId = item.Id,
			itemNum = item.Count
		})
		itemRenderDataList[i] = renderData
	end

	self.rewardRenderDataList = itemRenderDataList

	self.bindData.rewardList:SetSimpleList(#itemRenderDataList)
end
