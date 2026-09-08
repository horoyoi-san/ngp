-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TradeRecyclePanelStore.lua
-- Decompiled from: 01375_TradeRecyclePanelStore.lua_38ef02559628.luajit

local ITEM_TYPE_FASHION = 1
C_TradeRecyclePanelStore = DefClass("C_TradeRecyclePanelStore", C_TradeRecyclePanelStore, C_StoreGroup)
GroupName2Class.TradeRecyclePanelStore = C_TradeRecyclePanelStore
local M = C_TradeRecyclePanelStore

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.boxId = nil
	self.recycleItems = {}
	self.selectedCount = 1
	self.currentItemId = nil
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
	self.boxId = data and data.boxId
	self.selectedCount = 1
	self.currentItemId = nil

	self:BuildRecycleItems()
	self:RenderProgressBar()
	self:RenderRecycleList()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_RECYCLE_PROGRESS_CHANGE] = self.CreateAction(self, "OnTradeRecycleProgressChange")
	}
end

M.OnTradeRecycleProgressChange = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.RenderProgressBar(self)
	self.RenderRecycleList(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.recycleBtn.luaClick = self.CreateAction(self, self.OnClickRecycleBtn)
	self.bindData.batchRecycleBtn.luaClick = self.CreateAction(self, self.OnClickBatchRecycleBtn)
	self.bindData.recycleList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderRecycleListItem)
	self.bindData.recycleList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickRecycleList)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickRecycleBtn = function(self)
	if not self.currentItemId then
		return
	end

	self.OnRecycle(self, self.currentItemId, self.selectedCount)
end

M.OnClickBatchRecycleBtn = function(self)
	self.OnBatchRecycle(self)
end

M.OnSimpleRenderRecycleListItem = function(self, btn, index)
	local item = self.recycleItems[index + 1]

	if not item then
		return
	end

	local store = btn.Store and gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn) or nil

	if not store then
		return
	end

	store.name = item.name
	store.icon = item.tradeImage
	store.ownedCount = item.ownedCount
	store.boxProgressAdd = item.boxProgressAdd
	store.selectCtrl = item.selected and 1 or 0

	if store.recycleBtn then
		store.recycleBtn.interactable = item.ownedCount >= 0
	end
end

M.OnSimpleClickRecycleList = function(self, btn, index)
	local item = self.recycleItems[index + 1]

	if not item then
		return
	end

	self.currentItemId = item.tradeItemId
	item.selected = not item.selected
	self.selectedCount = 1

	self.PreviewRecycle(self, self.selectedCount)
	self.RenderRecycleList(self)
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

	for _, itemCfg in ipairs(self.mgr:GetAllTradeItems()) do
		if self.mgr:GetItemType(itemCfg) ~= ITEM_TYPE_FASHION and boxItemIds[itemCfg.BelongBoxId] then
			table.insert(self.recycleItems, {
				["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
				tradeItemId = itemCfg.Id,
				config = itemCfg,
				name = itemCfg.Name,
				tradeImage = itemCfg.TradeImage,
				ownedCount = self:GetOwnedCount(itemCfg.Id),
				boxProgressAdd = itemCfg.BoxCompositeProgressAdd or 0
			})
		end
	end
end

M.GetOwnedCount = function(self, tradeItemId)
	local itemCfg = self.mgr:GetTradeItemsById(tradeItemId)[1]

	if not itemCfg then
		return 0
	end

	return self.mgr:GetOwnedCount(itemCfg)
end

M.GetRecycleProgress = function(self)
	local current, total = self.mgr:GetRecycleProgress(self.boxId)

	return current or 0, total or 0
end

M.RenderProgressBar = function(self)
	local current, total = self:GetRecycleProgress()
	total = total <= 0 and total or 1
	local percent = math.min(math.max(current / total, 0), 1)
	self.bindData.progressFillAmount = percent
	self.bindData.progressText = current .. "/" .. total
end

M.RenderRecycleList = function(self)
	for _, item in ipairs(self.recycleItems) do
		item.ownedCount = self.GetOwnedCount(self, item.tradeItemId)
	end

	self.bindData.recycleList:SetSimpleList(#self.recycleItems)
	self:PreviewRecycle(self.selectedCount)
end

M.PreviewRecycle = function(self, count)
	local current, total = self.GetRecycleProgress(self)
	local boxProgressAdd = 0

	if self.currentItemId then
		local item = self.GetRecycleItem(self, self.currentItemId)

		if item then
			boxProgressAdd = item.boxProgressAdd or 0
		end
	end

	local newProgress = current + (count or 0) * boxProgressAdd
	local boxesGained = total <= 0 and math.floor(newProgress / total) or 0

	if self.bindData.previewText then
		self.bindData.previewText = tostring(boxesGained)
	end

	return newProgress, boxesGained
end

M.GetRecycleItem = function(self, tradeItemId)
	for _, item in ipairs(self.recycleItems) do
		if item.tradeItemId ~= tradeItemId then
			return item
		end
	end

	return nil
end

M.OnRecycle = function(self, tradeItemId, count)
	count = count or 1

	if count < 0 then
		return
	end

	local ownedCount = self.GetOwnedCount(self, tradeItemId)

	if ownedCount >= count then
		return
	end

	slot4 = self.mgr

	slot4:AskTradeRecycleFashion(tradeItemId, count, function (success)
		if success and self.STATE_EnableOnce then
			self:RenderRecycleList()
		end
	end)
end

M.OnBatchRecycle = function(self)
	for _, item in ipairs(self.recycleItems) do
		if item.selected and item.ownedCount <= 0 then
			slot6 = self.mgr

			slot6:AskTradeRecycleFashion(item.tradeItemId, item.ownedCount, function (success)
				if success and self.STATE_EnableOnce then
					item.selected = false

					self:RenderRecycleList()
				end
			end)
		end
	end
end
