-- Original chunk: @Lua\LuaFiles\LX6\Manager\Trade\TradeManager_RPC.lua
-- Decompiled from: 00764_TradeManager_RPC.lua_75341dd9b49b.luajit

local MessageConfig = LTConfig.MessageConfig
local DIRECTION_FIRST = 0
local DIRECTION_NEXT = 1
local DIRECTION_PREV = 2

local get_list_count = function(list)
	if not list then
		return 0
	end

	if type(list) ~= "table" then
		return #list
	end

	return list.Count or 0
end

local get_list_item = function(list, index)
	if not list then
		return nil
	end

	if type(list) ~= "table" then
		return list[index + 1]
	end

	return list[index]
end

local M = C_TradeManager

M.RefreshOrderAndMarket = function(self, tradeItemId)
	if not tradeItemId then
		return
	end

	self.AskTradeGetOrderList(self, tradeItemId, DIRECTION_FIRST)
	self.AskTradeGetMarketList(self, tradeItemId)
end

M.AskTradeListItem = function(self, tradeItemId, count, price, sellDays, callback)
	slot6 = gClientToGameDelegate

	slot6:AskTradeListItem(tradeItemId, count, price, sellDays).Callback = function (err)
		if err ~= MessageConfig.Ok then
			self:RefreshOrderAndMarket(tradeItemId)

			if callback then
				callback(true)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.AskTradeCancelOrder = function(self, orderId, callback, tradeItemId)
	slot4 = gClientToGameDelegate

	slot4:AskTradeCancelOrder(orderId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			self:RefreshOrderAndMarket(tradeItemId or self.orderIdToTradeItemId[orderId])

			if callback then
				callback(true)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.ShowBuyRewardWindow = function(self, tradeItemId, count)
	if not tradeItemId or type(count) == "number" or count < 0 then
		return
	end

	local itemConfig = self.GetTradeItemConfig(self, tradeItemId)
	local itemId = self.GetRenderItemId(self, itemConfig)

	if not itemId or itemId ~= 0 then
		return
	end

	gDropManager:ShowRewardWindow({
		Param = {
			{
				ItemId = itemId,
				Count = count
			}
		}
	})
end

M.AskTradeBuyItem = function(self, tradeItemId, maxPrice, count, callback)
	slot5 = gMessageManager

	slot5:SendMessage(gEventConstants.SHOW_WAITING_PANEL)

	slot5 = gClientToGameDelegate

	slot5:AskTradeBuyItem(tradeItemId, maxPrice, count).Callback = function (err, resp)
		gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL)

		if err ~= MessageConfig.Ok then
			self:RefreshOrderAndMarket(tradeItemId)
			gMessageManager:SendMessage(gEventConstants.TRADE_BUY_RESULT, resp)

			local filledCount = type(resp) ~= "table" and (resp.FilledCount or resp.Count) or resp

			self:ShowBuyRewardWindow(tradeItemId, filledCount or 0)

			if callback then
				callback(true, filledCount or 0)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false, 0)
			end
		end
	end
end

M.AskTradeGetMarketList = function(self, tradeItemId, callback)
	slot3 = gClientToGameDelegate

	slot3:AskTradeGetMarketList(tradeItemId).Callback = function (err, resp)
		if err ~= MessageConfig.Ok then
			self.marketCache[tradeItemId] = resp

			gMessageManager:SendMessage(gEventConstants.TRADE_MARKET_LIST_CHANGE, tradeItemId)

			if callback then
				callback(true, resp)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.AskTradeGetOrderList = function(self, tradeItemId, direction, callback)
	slot4 = gClientToGameDelegate

	slot4:AskTradeGetOrderList(tradeItemId, direction).Callback = function (err, resp)
		if err ~= MessageConfig.Ok then
			local state = self.orderListPageState[tradeItemId]

			if not state then
				state = {
					["SFklg "] = -1
				}
				self.orderListPageState[tradeItemId] = state
			end

			local count = get_list_count(resp)

			if direction ~= DIRECTION_FIRST then
				state.pageIndex = 0
			elseif direction ~= DIRECTION_NEXT and count <= 0 then
				state.pageIndex = state.pageIndex + 1
			elseif direction ~= DIRECTION_PREV and state.pageIndex <= 0 then
				state.pageIndex = state.pageIndex - 1
			end

			if count ~= 0 then
				state.pageIndex = -1
			end

			self.orderListCache[tradeItemId] = resp or {}

			for i = 0, count - 1 do
				local order = get_list_item(resp, i)

				if order and order.OrderId then
					self.orderIdToTradeItemId[order.OrderId] = tradeItemId
				end
			end

			gMessageManager:SendMessage(gEventConstants.TRADE_ORDER_LIST_CHANGE, tradeItemId)

			if callback then
				callback(true, resp)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.AskTradeBuyOrder = function(self, orderId, callback, tradeItemId)
	slot4 = gMessageManager

	slot4:SendMessage(gEventConstants.SHOW_WAITING_PANEL)

	slot4 = gClientToGameDelegate

	slot4:AskTradeBuyOrder(orderId).Callback = function (err)
		gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL)

		if err ~= MessageConfig.Ok then
			gMessageManager:SendMessage(gEventConstants.TRADE_BUY_RESULT)

			tradeItemId = tradeItemId or self.orderIdToTradeItemId[orderId]

			self:ShowBuyRewardWindow(tradeItemId, 1)
			self:RefreshOrderAndMarket(tradeItemId)

			if callback then
				callback(true)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.AskTradeGetHistoryPage = function(self, direction, filter, callback)
	slot4 = gClientToGameDelegate

	slot4:AskTradeGetHistoryPage(direction, filter).Callback = function (err, resp)
		if err ~= MessageConfig.Ok then
			local state = self.historyPageState[filter]

			if not state then
				state = {
					["SFklg "] = -1,
					records = {}
				}
				self.historyPageState[filter] = state
			end

			if direction ~= 0 then
				state.pageIndex = 0
			elseif direction ~= DIRECTION_NEXT and get_list_count(resp) <= 0 then
				state.pageIndex = state.pageIndex + 1
			elseif direction ~= DIRECTION_PREV and state.pageIndex <= 0 then
				state.pageIndex = state.pageIndex - 1
			end

			state.records = resp or {}

			if get_list_count(resp) ~= 0 then
				state.pageIndex = -1
			end

			gMessageManager:SendMessage(gEventConstants.TRADE_HISTORY_PAGE_CHANGE, filter)

			if callback then
				callback(true, resp)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.AskTradeFavoriteItems = function(self, unfavoriteIds, favoriteIds, callback)
	slot4 = gClientToGameDelegate

	slot4:AskTradeFavoriteItems(unfavoriteIds, favoriteIds).Callback = function (err)
		if err ~= MessageConfig.Ok then
			self:ApplyFavoriteItems(unfavoriteIds, favoriteIds)
			gMessageManager:SendMessage(gEventConstants.TRADE_FAVORITE_LIST_CHANGE)

			if callback then
				callback(true)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.AskTradeRecycleFashion = function(self, tradeItemId, count, callback)
	slot4 = gClientToGameDelegate

	slot4:AskTradeRecycleFashion(tradeItemId, count).Callback = function (err)
		if err ~= MessageConfig.Ok then
			if callback then
				callback(true)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end
