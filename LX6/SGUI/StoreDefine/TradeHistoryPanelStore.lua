-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TradeHistoryPanelStore.lua
-- Decompiled from: 01374_TradeHistoryPanelStore.lua_890c7f8d9db9.luajit

local DIRECTION_FIRST = 0
local DIRECTION_NEXT = 1
local DIRECTION_PREV = 2
local FILTER_ALL = 0
local FILTER_BUY = 1
local FILTER_SELL = 2
local DIRECTION_TEXT = {
	[FILTER_BUY] = "买入",
	[FILTER_SELL] = "卖出"
}
C_TradeHistoryPanelStore = DefClass("C_TradeHistoryPanelStore", C_TradeHistoryPanelStore, C_StoreGroup)
GroupName2Class.TradeHistoryPanelStore = C_TradeHistoryPanelStore
local M = C_TradeHistoryPanelStore

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.currentFilter = FILTER_ALL
	self.historyRecords = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = {
		["H\\xa3\\xb2\\xbb\\xaf"] = 1,
		["\\xa5\\xbe\\x8eg.\\xea*"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = nil
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
	self.currentFilter = FILTER_ALL
	self.historyRecords = {}

	self.AskFirstPage(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_HISTORY_PAGE_CHANGE] = self.CreateAction(self, "OnTradeHistoryPageChange")
	}
end

M.OnTradeHistoryPageChange = function(self, _, filter)
	if filter == self.currentFilter then
		return
	end

	self.UpdateHistoryRecords(self)
	self.RenderHistoryList(self)
end

M.RegisterWidget = function(self)
	self.bindData.filterAllBtn.luaClick = self.CreateActionWithArgs(self, self.OnFilterChanged, FILTER_ALL)
	self.bindData.filterBuyBtn.luaClick = self.CreateActionWithArgs(self, self.OnFilterChanged, FILTER_BUY)
	self.bindData.filterSellBtn.luaClick = self.CreateActionWithArgs(self, self.OnFilterChanged, FILTER_SELL)
	self.bindData.nextPageBtn.luaClick = self.CreateAction(self, self.OnNextPage)
	self.bindData.prevPageBtn.luaClick = self.CreateAction(self, self.OnPrevPage)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.historyList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderHistoryItem)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnFilterChanged = function(self, filter)
	if self.currentFilter ~= filter then
		return
	end

	self.currentFilter = filter
	self.historyRecords = {}

	self.AskFirstPage(self)
end

M.OnNextPage = function(self)
	self.mgr:AskTradeGetHistoryPage(DIRECTION_NEXT, self.currentFilter)
end

M.OnPrevPage = function(self)
	self.mgr:AskTradeGetHistoryPage(DIRECTION_PREV, self.currentFilter)
end

M.AskFirstPage = function(self)
	self.mgr:AskTradeGetHistoryPage(DIRECTION_FIRST, self.currentFilter)
end

M.UpdateHistoryRecords = function(self)
	local state = self.mgr.historyPageState and self.mgr.historyPageState[self.currentFilter]
	self.historyRecords = state and state.records or {}
end

M.RenderHistoryList = function(self)
	local count = self:GetListCount(self.historyRecords)

	self.bindData.historyList:SetSimpleList(count)

	if count ~= 0 then
		self.bindData.isEmptyCtrl = self.isEmptyCtrlEnum.empty
		self.bindData.emptyText = "无更多记录"
	else
		self.bindData.isEmptyCtrl = self.isEmptyCtrlEnum.notEmpty
	end
end

M.OnSimpleRenderHistoryItem = function(self, btn, index)
	local record = self.GetListItem(self, self.historyRecords, index)

	if not record then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local itemCfg = self.mgr:GetTradeItemsById(record.TradeItemId)[1]
	store.itemName = itemCfg and itemCfg.Name or tostring(record.TradeItemId)
	store.direction = DIRECTION_TEXT[record.Direction] or ""
	store.count = record.Count or 0
	store.price = record.Price or 0
	store.createTime = self:FormatCreateTime(record.CreateTime)
	store.counterpartyPid = tostring(record.CounterpartyPid or 0)
	local isSell = record.Direction ~= FILTER_SELL

	if store.cancelOrderBtn then
		store.cancelOrderBtn:SetActive(isSell)

		if isSell and record.OrderId then
			store.cancelOrderBtn.luaClick = function()
				self:OnClickCancelOrder(record.OrderId, record.TradeItemId)
			end
		end
	end
end

M.OnClickCancelOrder = function(self, orderId, tradeItemId)
	self.mgr:AskTradeCancelOrder(orderId, nil, tradeItemId)
end

M.FormatCreateTime = function(self, unixSec)
	if not unixSec or unixSec < 0 then
		return ""
	end

	local date = LTUtils.UXTime.UnixTimeToDateTime(unixSec)

	return string.format("%04d/%02d/%02d %02d:%02d", date.Year or 0, date.Month or 0, date.Day or 0, date.Hour or 0, date.Minute or 0)
end

M.GetListCount = function(self, list)
	return list and (list.Count or #list) or 0
end

M.GetListItem = function(self, list, index)
	if not list then
		return nil
	end

	if list[0] == nil then
		return list[index]
	end

	return list[index + 1]
end
