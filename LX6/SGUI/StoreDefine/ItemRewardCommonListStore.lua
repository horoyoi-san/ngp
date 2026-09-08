-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ItemRewardCommonListStore.lua
-- Decompiled from: 01767_ItemRewardCommonListStore.lua_8cc0cccbad39.luajit

C_ItemRewardCommonListStore = DefClass("C_ItemRewardCommonListStore", C_ItemRewardCommonListStore, C_StoreGroup)
GroupName2Class.ItemRewardCommonListStore = C_ItemRewardCommonListStore
local M = C_ItemRewardCommonListStore

M.ctor = function(self)
	self.btnCallback = nil
end

M.OnAwake = function(self)
	self.showList = {}
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardItem)
	self.bindData.randomList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRandomItem)
	self.bindData.rewardBtn.luaClick = self.CreateAction(self, "OnRewardBtnClick")
	self.bindData.randomBtn.luaClick = self.CreateAction(self, "OnRewardBtnClick")
	self.bindData.stickBtn.luaClick = self.CreateAction(self, "OnStickBtnClick")
	self.rewardList = {}
	self.randomList = {}
end

local STATE_CTL = {
	["RY~"] = 3,
	[".m\\xa6\\xaf\\xb1e"] = 2,
	[".i\\xbf\\xaa\\xacl"] = 1,
	["X\rIs"] = 0
}

M.OnRenderRewardItem = function(self, btn, index)
	local data = self.rewardList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

M.OnRenderRandomItem = function(self, btn, index)
	local data = self.randomList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

M.OnRewardBtnClick = function(self)
	if self.btnCallback then
		self.btnCallback()
	end
end

M.OnStickBtnClick = function(self)
	gCommonItemManager:OnShowItemList(self.showList)
end

M.OnInit = function(self, data)
	self.btnCallback = data.btnCallback
	self.bindData.hasBtn = data.btnCallback == nil and 0 or 1
	local rewardList, randomList = gCommonItemManager:GetItemSortedListByDropList(data.data)
	self.randomList = {}
	self.rewardList = {}

	for i = 1, #rewardList do
		local view = {
			itemId = rewardList[i].Id,
			itemNum = rewardList[i].Count,
			spiritId = rewardList[i].spiritId,
			isFirstKill = rewardList[i].isFirstKill
		}

		table.insert(self.rewardList, gCommonItemManager:GetItemRenderData(view))
	end

	for i = 1, #randomList do
		local view = {
			itemId = randomList[i].Id,
			itemNum = randomList[i].Count,
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
