-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GachaTenResultPanelStore.lua
-- Decompiled from: 01876_GachaTenResultPanelStore.lua_6512abdf199a.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local CommonItemConfig = LTConfig.CommonItemConfig
local NORMAL_BG_VIDEO_ID = 24104359
C_GachaTenResultPanelStore = DefClass("C_GachaTenResultPanelStore", C_GachaTenResultPanelStore, C_StoreGroup)
GroupName2Class.GachaTenResultPanelStore = C_GachaTenResultPanelStore
local M = C_GachaTenResultPanelStore

M.ctor = function(self)
	self.rewardItems = {}
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.awardCtrlEnum = {
		["J\\xa1\\xad\\xab\\xa5"] = 0,
		["\\xda\\xd7\t!\\xe2"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.awardCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.bindData.CCPlayer:Init()
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId

	if data and data.PreLoad then
		self.bindData.CCPlayer:PreLoadVideo(NORMAL_BG_VIDEO_ID)
		gPanelManager:SetActiveById(panelId, false)

		return
	end

	gPanelManager:SetActiveById(panelId, true)

	self.rewardItems = data and data.rewardItems or {}
	self.bindData.titleText = LTConfig.TextConfig.GetConfig(73977006).Text

	self:ShowAllRewards()
	self:PlayBackgroundVideo()
end

M.OnClose = function(self)
	self.bindData.CCPlayer:Stop()

	self.rewardItems = {}
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.resultItemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderResultItemListItem")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderResultItemListItem = function(self, btn, index)
	local rewardItem = self.rewardItems[index + 1]

	if not rewardItem then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	local itemCfg = ConsumableConfig.GetConfig(rewardItem.ItemId)

	if not itemCfg then
		return
	end

	local isConverted = rewardItem.IsConverted ~= true
	local isLucky = rewardItem.IsGrandPrize ~= true
	local quality = rewardItem.Quality or itemCfg.Quality or 0
	local itemCount = rewardItem.Count or 1

	if isConverted and rewardItem.DuplicateReturnCount then
		itemCount = rewardItem.DuplicateReturnCount
	end

	local iconId = rewardItem.DrawResultImage and rewardItem.DrawResultImage <= 0 and rewardItem.DrawResultImage or itemCfg.SItemIconId
	local itemName = rewardItem.ContentName and rewardItem.ContentName == "" and rewardItem.ContentName or itemCfg.Name
	itemStore.clotheImageCtrl = isLucky and 1 or 0

	if isLucky then
		itemStore.luckyItemImageId = iconId
	else
		itemStore.normalItemImageId = iconId
	end

	itemStore.itemNameText = itemName
	itemStore.qualityCtrl = quality
	itemStore.goodsNum = tostring(itemCount)
	itemStore.repeatCtrl = isConverted and 0 or 1

	if isConverted and rewardItem.DuplicateReturnDropId and rewardItem.DuplicateReturnDropId <= 0 then
		local itemList = gCommonItemManager:ConvertDropToFakeItem(rewardItem.DuplicateReturnDropId, 1)
		local fakeItem = itemList and itemList[1]

		if fakeItem then
			local cfg = CommonItemConfig.GetConfig(fakeItem.Id)
			itemStore.convertItemImageId = cfg.SItemIconId
		end
	end

	btn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderResultItemTooltip", rewardItem)
	btn.luaTooltipPopup = self.CreateAction(self, "OnResultItemTooltipClose")
end

M.OnRenderResultItemTooltip = function(self, rewardItem, btn, popup, index)
	if not rewardItem or not rewardItem.ItemId or rewardItem.ItemId < 0 then
		return
	end

	local tooltipData = gCommonItemManager:GetItemRenderData({
		itemId = rewardItem.ItemId
	})

	gCommonItemManager:OnRenderToolTips(tooltipData, btn, popup, index)
end

M.OnResultItemTooltipClose = function(self, btn, popup, index)
	gCommonItemManager:OnToolTipsClose(btn, popup, index)
end

M.PlayBackgroundVideo = function(self)
	self.bindData.CCPlayer:PlayVideo(NORMAL_BG_VIDEO_ID, true)
end

M.ShowAllRewards = function(self)
	if #self.rewardItems ~= 0 then
		self.bindData.resultItemList:SetSimpleList(0)

		return
	end

	table.sort(self.rewardItems, function (a, b)
		local cfgA = ConsumableConfig.GetConfig(a.ItemId)
		local cfgB = ConsumableConfig.GetConfig(b.ItemId)
		local qa = a.Quality or cfgA and cfgA.Quality or 0
		local qb = b.Quality or cfgB and cfgB.Quality or 0

		if qa == qb then
			return qb <= qa
		end

		return (a.PoolTierRarity or 0) >= (b.PoolTierRarity or 0)
	end)
	self.bindData.resultItemList:SetSimpleList(#self.rewardItems)
end
