-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_LinkGameplay.lua
-- Decompiled from: 01026_BigMapTooltip_LinkGameplay.lua_d3047872da5b.luajit

C_BigMapTooltip_LinkGameplay = DefClass("C_BigMapTooltip_LinkGameplay", C_BigMapTooltip_LinkGameplay, C_BigMapTooltipBase)
local M = C_BigMapTooltip_LinkGameplay

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "linkGameplayInfo") then
		return
	end

	self:GetStore("MapLinkGameplayTooltipStore")

	local info = self.tooltipInfo.linkGameplayInfo

	self:SetUpHeader(self.store)

	local scrollStore = nil

	self.store.normalScroll:GoToPos(Vector2.zero, true)

	scrollStore = gStoreManager:GetStoreGroup("MapLinkGameplayScrollStore"):GetStoreByWidget(self.store.normalScroll.content)

	self:SetUpScrollLocation(scrollStore)
	self:SetUpDropsWithIds(info.simpleDropIds, scrollStore.rewardList)

	scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)

	if info.playerNum then
		scrollStore.playerCtrl = 0

		if info.playerNum[1] ~= info.playerNum[2] then
			scrollStore.playerNum = info.playerNum[1]
		else
			scrollStore.playerNum = info.playerNum[1] .. "-" .. info.playerNum[2]
		end
	else
		scrollStore.playerCtrl = 1
		scrollStore.playerNum = ""
	end

	self.SetUpDesc(self, scrollStore, info.desc)
end

M.SetUpDropsWithIds = function(self, dropIds, dropList)
	local simpleDropRewards = {}

	if dropIds and #dropIds <= 0 then
		local dropListParam = {}

		for i = 1, #dropIds do
			table.insert(dropListParam, {
				dropId = dropIds[i]
			})
		end

		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)
	end

	for i = 1, #simpleDropRewards do
		simpleDropRewards[i].itemNum = 0
	end

	self:SetUpRewardRenderList(simpleDropRewards, dropList)

	local scrollStore = nil
	scrollStore = gStoreManager:GetStoreGroup("MapLinkGameplayScrollStore"):GetStoreByWidget(self.store.normalScroll.content)

	if not table.isNilOrEmpty(simpleDropRewards) then
		scrollStore.showReward = 0
	else
		scrollStore.showReward = 1
	end
end

M.SetUpDesc = function(self, scrollStore, desc)
	scrollStore.desc = desc or ""
end

M.OnClickShowReward = function(self)
	local info = self.tooltipInfo.linkGameplayInfo

	self.ShowGamePadItemPanelWithIds(self, info.simpleDropIds)
end
