-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TradeFashionDetailPanelStore.lua
-- Decompiled from: 01372_TradeFashionDetailPanelStore.lua_62533da0deae.luajit

C_TradeFashionDetailPanelStore = DefClass("C_TradeFashionDetailPanelStore", C_TradeFashionDetailPanelStore, C_StoreGroup)
GroupName2Class.TradeFashionDetailPanelStore = C_TradeFashionDetailPanelStore
local M = C_TradeFashionDetailPanelStore
local DIRECTION_FIRST = 0
local DIRECTION_NEXT = 1
local DIRECTION_PREV = 2

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.tradeItemId = nil
	self.orderList = {}
	self.selectedOrder = nil
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
	self.tradeItemId = data and data.tradeItemId
	self.orderList = {}
	self.selectedOrder = nil

	if not self.tradeItemId then
		return
	end

	self.mgr:AskTradeGetOrderList(self.tradeItemId, DIRECTION_FIRST)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_ORDER_LIST_CHANGE] = self.CreateAction(self, "OnTradeOrderListChange"),
		[gEventConstants.TRADE_MARKET_LIST_CHANGE] = self.CreateAction(self, "OnTradeMarketListChange")
	}
end

M.OnTradeOrderListChange = function(self, _, tradeItemId)
	if tradeItemId and self.tradeItemId == tradeItemId then
		return
	end

	local cache = self.mgr:GetOrderListCache(self.tradeItemId)
	self.orderList = {}
	local count = self:GetListCount(cache)

	for i = 1, count do
		local order = self.GetListItem(self, cache, i)

		if order then
			table.insert(self.orderList, order)
		end
	end

	self.SortByListTimeDesc(self)

	self.selectedOrder = nil

	self.RenderOrderList(self)
end

M.OnTradeMarketListChange = function(self, _, tradeItemId)
	if tradeItemId and self.tradeItemId == tradeItemId then
		return
	end

	self.RenderOrderList(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.buyBtn.luaClick = self.CreateAction(self, self.OnBuyOrder)
	self.bindData.nextPageBtn.luaClick = self.CreateAction(self, self.OnNextPage)
	self.bindData.prevPageBtn.luaClick = self.CreateAction(self, self.OnPrevPage)
	self.bindData.orderList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderOrderListItem)
	self.bindData.orderList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickOrderList)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.RenderOrderList = function(self)
	self.bindData.orderList:SetSimpleList(#self.orderList)
	self:RefreshBuyBtn()
end

M.OnSimpleRenderOrderListItem = function(self, btn, index)
	local order = self.orderList[index + 1]

	if not order then
		return
	end

	local store = btn.Store and gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn) or nil

	if not store then
		return
	end

	store.priceLabel = tostring(order.Price or 0)
	store.sellerIdLabel = tostring(order.SellerId or 0)
	store.listTimeLabel = self:FormatListTime(order.ListTime)

	if self:IsInPublicityPeriod(order) then
		store.publicityCountdownLabel = self.FormatPublicityCountdown(self, order)
		store.publicityCtrl = 1
	else
		store.publicityCtrl = 0
	end
end

M.OnSimpleClickOrderList = function(self, btn, index)
	local order = self.orderList[index + 1]

	if not order then
		return
	end

	self.OnSelectOrder(self, order.OrderId)
end

M.OnSelectOrder = function(self, orderId)
	self.selectedOrder = nil

	for _, order in ipairs(self.orderList) do
		if order.OrderId ~= orderId then
			self.selectedOrder = order

			break
		end
	end

	self.RefreshBuyBtn(self)
end

M.RefreshBuyBtn = function(self)
	if not self.bindData.buyBtn then
		return
	end

	local canBuy = self.selectedOrder == nil and not self:IsInPublicityPeriod(self.selectedOrder)
	self.bindData.buyBtn.interactable = canBuy
end

M.OnBuyOrder = function(self)
	if not self.selectedOrder then
		return
	end

	if self.IsInPublicityPeriod(self, self.selectedOrder) then
		return
	end

	local orderId = self.selectedOrder.OrderId
	slot2 = self.mgr

	slot2:AskTradeBuyOrder(orderId, function (success)
		if success and self.STATE_EnableOnce then
			-- Nothing
		end
	end, self.tradeItemId)
end

M.OnNextPage = function(self)
	if not self.tradeItemId then
		return
	end

	self.mgr:AskTradeGetOrderList(self.tradeItemId, DIRECTION_NEXT)
end

M.OnPrevPage = function(self)
	if not self.tradeItemId then
		return
	end

	self.mgr:AskTradeGetOrderList(self.tradeItemId, DIRECTION_PREV)
end

M.IsInPublicityPeriod = function(self, orderDetail)
	if not orderDetail then
		return false
	end

	local extra = orderDetail.ItemExtraData
	local visibleAfterTime = extra and extra.VisibleAfterTime or orderDetail.VisibleAfterTime or 0

	if visibleAfterTime ~= 0 then
		return false
	end

	return self.mgr:GetServerUnixTime() <= visibleAfterTime
end

M.FormatListTime = function(self, listTime)
	if not listTime or listTime < 0 then
		return ""
	end

	return gTimeUtils:TransFormatTimeWithSec(listTime)
end

M.FormatPublicityCountdown = function(self, orderDetail)
	if not orderDetail then
		return ""
	end

	local extra = orderDetail.ItemExtraData
	local visibleAfterTime = extra and extra.VisibleAfterTime or orderDetail.VisibleAfterTime or 0
	local remain = visibleAfterTime - self.mgr:GetServerUnixTime()

	if remain < 0 then
		return ""
	end

	return gTimeUtils:FormatTime(remain, true)
end

M.SortByListTimeDesc = function(self)
	table.sort(self.orderList, function (left, right)
		return (left.ListTime or 0) >= (right.ListTime or 0)
	end)
end

M.GetListCount = function(self, list)
	if not list then
		return 0
	end

	return list.Count or #list
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
