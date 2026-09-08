-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TradingPostRecycleWindowPanelStore.lua
-- Decompiled from: 01276_TradingPostRecycleWindowPanelStore.lua_6ac3985dd5e3.luajit

C_TradingPostRecycleWindowPanelStore = DefClass("C_TradingPostRecycleWindowPanelStore", C_TradingPostRecycleWindowPanelStore, C_StoreGroup)
GroupName2Class.TradingPostRecycleWindowPanelStore = C_TradingPostRecycleWindowPanelStore
local M = C_TradingPostRecycleWindowPanelStore
local ITEM_TYPE_FASHION = 1

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.boxId = nil
	self.recycleItems = {}
	self.currentItemId = nil
	self.selectedCount = 1
	self.lastBoxCount = 0
	self.refreshing = false
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

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.boxId = data and (data.boxId or data.tradeItemId or data.tradeId)
	self.currentItemId = nil
	self.selectedCount = 1
	self.lastBoxCount = 0

	self.SubGroup.MoneyTemplateStore:SetData({
		{
			Type = LTConfig.ConsumableConfig.RewardGold
		},
		{
			Type = LTConfig.ConsumableConfig.RewardBindingGold
		}
	})
	self:BuildRecycleItems()
	self:RefreshProgress()
	self:RefreshRecycleList()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_RECYCLE_PROGRESS_CHANGE] = self.CreateAction(self, "OnTradeRecycleProgressChange"),
		[gEventConstants.TRADE_PLAYER_INFO_CHANGE] = self.CreateAction(self, "OnTradePlayerInfoChange")
	}
end

M.OnTradeRecycleProgressChange = function(self)
	if self.STATE_EnableOnce then
		self.RefreshProgress(self)
		self.RefreshRecycleList(self)
	end
end

M.OnTradePlayerInfoChange = function(self)
	if self.STATE_EnableOnce then
		self.RefreshProgress(self)
		self.RefreshRecycleList(self)
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.tipBtn.luaClick = self.CreateAction(self, "OnClickTipBtn")
	self.bindData.recycleBtn.luaClick = self.CreateAction(self, "OnClickRecycleBtn")
	self.bindData.recycleList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRecycleListItem")
	self.bindData.recycleList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickRecycleList")
end

M.OnClickBackBtn = function(self)
	self.Close(self)
end

M.OnClickCloseBtn = function(self)
	self.Close(self)
end

M.OnClickTipBtn = function(self)
	self.mgr:ShowTradeExplain()
end

M.BuildRecycleItems = function(self)
	self.recycleItems = {}

	if not self.boxId then
		return
	end

	local boxItemIds = {
		[self.boxId] = true
	}

	for _, box in ipairs(self.mgr:GetTradeItemsById(self.boxId)) do
		if box.Id then
			boxItemIds[box.Id] = true
		end
	end

	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict

	for _, itemCfg in ipairs(self.mgr:GetAllTradeItems()) do
		if self.mgr:GetItemType(itemCfg) ~= ITEM_TYPE_FASHION and boxItemIds[itemCfg.BelongBoxId] then
			local fashionInfo = fashionInfoDict[itemCfg.FashionId]

			if fashionInfo and fashionInfo.OwnedCount <= 0 then
				table.insert(self.recycleItems, {
					["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
					["N\\xa1\\xb7\\xa1\\xa2"] = 1,
					tradeItemId = itemCfg.Id,
					fashionId = itemCfg.FashionId,
					instance = fashionInfo,
					config = itemCfg,
					name = self.mgr:GetTradeItemName(itemCfg),
					icon = self.mgr:GetTradeItemIcon(itemCfg),
					ownedCount = fashionInfo.OwnedCount,
					boxProgressAdd = itemCfg.BoxCompositeProgressAdd or 0
				})
			end
		end
	end
end

M.RefreshProgress = function(self)
	local current, total = self.mgr:GetRecycleProgress(self.boxId)
	total = total or 0
	self.bindData.progress.minValue = 0
	self.bindData.progress.maxValue = math.max(1, total)
	self.bindData.progress.value = math.min(current or 0, self.bindData.progress.maxValue)
	local boxCount = total <= 0 and math.floor((current or 0) / total) or 0
	self.lastBoxCount = boxCount
end

M.RefreshRecycleList = function(self)
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict

	for _, item in ipairs(self.recycleItems) do
		item.instance = fashionInfoDict[item.fashionId]
		item.ownedCount = item.instance and item.instance.OwnedCount or 0
		item.count = math.max(1, math.min(item.count or 1, math.max(1, item.ownedCount)))
	end

	self.bindData.recycleList:SetSimpleList(#self.recycleItems)

	self.bindData.recycleList.checkMax = #self.recycleItems

	self:RefreshPreview()

	self.bindData.recycleBtn.interactable = self:HasSelectedItem()
end

M.HasSelectedItem = function(self)
	for _, item in ipairs(self.recycleItems) do
		if item.selected and item.ownedCount <= 0 then
			return true
		end
	end

	return false
end

M.GetRecycleItem = function(self, index)
	return self.recycleItems[index + 1]
end

M.OnSimpleRenderRecycleListItem = function(self, btn, index)
	local item = self:GetRecycleItem(index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.itemName = item.name
	store.itemNum = tostring(item.ownedCount)
	store.ownedCount = item.ownedCount
	store.boxProgressAdd = item.boxProgressAdd
	store.selected = item.selected and 1 or 0
	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = self.mgr:GetTradeItemConsumableId(item.config),
		itemNum = item.ownedCount
	})
	renderData.name = item.name

	gCommonItemManager:OnCommonItemRender(store.itemView, 0, renderData)

	store.numselector.luaValueChanged = self:CreateActionWithArgs("OnItemCountChanged", item.tradeItemId)
	store.numselector.minValue = 1
	store.numselector.maxValue = math.max(1, item.ownedCount)
	store.numselector.value = math.max(1, math.min(item.count or 1, store.numselector.maxValue))
end

M.OnSimpleClickRecycleList = function(self, btn, index)
	local item = self.GetRecycleItem(self, index)

	if item.ownedCount < 0 then
		return
	end

	item.selected = not item.selected

	self.bindData.recycleList:SetItemSelected(index, item.selected)

	self.currentItemId = item.selected and item.tradeItemId or self.currentItemId
	self.bindData.recycleBtn.interactable = self:HasSelectedItem()
end

M.OnItemCountChanged = function(self, tradeItemId, value)
	local item = self:FindItem(tradeItemId)
	item.count = math.max(1, math.min(math.floor(value or 1), item.ownedCount))
	item.selected = true
	self.currentItemId = tradeItemId

	self:RefreshPreview()
end

M.FindItem = function(self, tradeItemId)
	for _, item in ipairs(self.recycleItems) do
		if item.tradeItemId ~= tradeItemId then
			return item
		end
	end

	return nil
end

M.RefreshPreview = function(self)
	local current, total = self.mgr:GetRecycleProgress(self.boxId)
	local addProgress = 0

	for _, item in ipairs(self.recycleItems) do
		if item.selected then
			addProgress = addProgress + (item.count or 1) * (item.boxProgressAdd or 0)
		end
	end

	local target = (current or 0) + addProgress
	local boxes = total and total <= 0 and math.floor(target / total) or 0
	self.bindData.previewText = tostring(target) .. "/" .. tostring(total or 0)
	self.bindData.previewRewardText = boxes <= 0 and "获得箱子 x" .. tostring(boxes) or ""

	return target, boxes
end

M.OnClickRecycleBtn = function(self)
	for _, item in ipairs(self.recycleItems) do
		if item.selected then
			local count = math.max(1, math.min(item.count or 1, item.ownedCount))

			if item.ownedCount >= count then
				self.ShowInsufficientMessage(self)

				return
			end
		end
	end

	for _, item in ipairs(self.recycleItems) do
		if item.selected and item.ownedCount <= 0 then
			slot6 = self.mgr

			slot6:AskTradeRecycleFashion(item.tradeItemId, item.count or 1, function (success)
				if success and self.STATE_EnableOnce then
					item.selected = false
					item.count = 1

					self:RefreshRecycleList()
				end
			end)
		end
	end
end

M.ShowInsufficientMessage = function(self)
	gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TradeFashionSellableInsufficient)
end

M.Close = function(self)
	gPanelManager:Close(self.m_Id)
end
