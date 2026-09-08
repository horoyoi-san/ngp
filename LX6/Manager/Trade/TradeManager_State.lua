-- Original chunk: @Lua\LuaFiles\LX6\Manager\Trade\TradeManager_State.lua
-- Decompiled from: 00766_TradeManager_State.lua_1d90204e2873.luajit

local TradeConfig = LTConfig.TradeConfig
local TradeTabConfig = LTConfig.TradeTabConfig
local TradeItemConfig = LTConfig.TradeItemConfig
local ITEM_TYPE_BOX = 0
local M = C_TradeManager

M.IsTradeBanned = function(self)
	if not self.playerTradeInfo then
		return false
	end

	local banExpireTime = self.playerTradeInfo.TradeBanExpireTime or 0

	if banExpireTime ~= 0 then
		return false
	end

	return self:GetServerUnixTime() <= banExpireTime
end

M.IsTradeEnabled = function(self)
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Trade) and gGameSwitch.EnableTrade == false
end

M.IsFashionTradeEnabled = function(self)
	return not gGameSwitch or gGameSwitch.EnableFashionTrade == false
end

M.GetTradeBanRemainingSeconds = function(self)
	if not self.playerTradeInfo then
		return 0
	end

	local banExpireTime = self.playerTradeInfo.TradeBanExpireTime or 0

	if banExpireTime ~= 0 then
		return 0
	end

	local remain = banExpireTime - self:GetServerUnixTime()

	return remain <= 0 and remain or 0
end

M.GetActiveOrderCount = function(self)
	if not self.playerTradeInfo or not self.playerTradeInfo.ActiveOrders then
		return 0
	end

	return self.playerTradeInfo.ActiveOrders.Count
end

M.GetEstimatedTransactionFee = function(self, total)
	return total * self.GetTradeSetting(self, "TradeTransactionFeeRate", 0)
end

M.GetTradeSetting = function(self, name, default)
	local value = TradeConfig[name]

	if value == nil then
		return value
	end

	return default
end

M.OpenPanel = function(self)
	if not self.IsTradeEnabled(self) then
		return
	end

	local panelId = gPanelId.NEW_TRADING_POST_PANEL or gPanelId.TRADING_POST_PANEL

	if panelId then
		gPanelManager:CheckShow(panelId)
	end
end

M.OpenDetailPanel = function(self, tradeItemId, isBuy)
	if not self.IsTradeEnabled(self) then
		return
	end

	local items = self.GetTradeItemsById(self, tradeItemId)

	if #items <= 1 then
		local multiItemPanelId = gPanelId.NEW_TRADING_POST_SELLING_LIST_PANEL

		if multiItemPanelId then
			gPanelManager:CheckShow(multiItemPanelId, {
				tradeId = tradeItemId,
				isBuy = isBuy
			})

			return
		end
	end

	local actualTradeItemId = items[1] and items[1].Id or tradeItemId
	local panelId = isBuy and gPanelId.TRADING_POST_PURCHASE_WINDOW or gPanelId.TRADING_POST_SELL_WINDOW

	gPanelManager:CheckShow(panelId, {
		tradeItemId = actualTradeItemId,
		isBuy = isBuy
	})
end

M.GetTradeTabList = function(self)
	local itemDict = {}
	local mainConfigs = self.GetTradeConfigList(self)

	local is_entry_tradable = function(resolved)
		local itemType = self:GetItemType(resolved)

		return self:IsFashionTradeEnabled() or itemType ~= ITEM_TYPE_BOX
	end

	if #mainConfigs <= 0 then
		for _, tradeCfg in ipairs(mainConfigs) do
			if tradeCfg.Tab == nil then
				for _, itemId in ipairs(self.GetTradeItemIds(self, tradeCfg)) do
					local itemCfg = self.GetTradeItemConfig(self, itemId)

					if itemCfg then
						local resolved = self.BuildTradeItem(self, tradeCfg, itemCfg)

						if is_entry_tradable(resolved) then
							itemDict[tradeCfg.Tab] = itemDict[tradeCfg.Tab] or {}

							table.insert(itemDict[tradeCfg.Tab], resolved)

							break
						end
					end
				end
			end
		end
	else
		slot4 = 0
		slot5 = TradeItemConfig.count or 0

		for i = slot4, slot5 - 1 do
			local itemCfg = TradeItemConfig.LoadAt(i)

			if itemCfg and itemCfg.Tab == nil then
				local resolved = self.BuildTradeItem(self, nil, itemCfg)

				if is_entry_tradable(resolved) then
					itemDict[itemCfg.Tab] = itemDict[itemCfg.Tab] or {}

					table.insert(itemDict[itemCfg.Tab], resolved)
				end
			end
		end
	end

	local tabList = {}
	slot5 = 0
	slot6 = TradeTabConfig.count or 0

	for i = slot5, slot6 - 1 do
		local tabCfg = TradeTabConfig.LoadAt(i)

		if tabCfg then
			table.insert(tabList, {
				tab = tabCfg,
				items = itemDict[tabCfg.Id] or {}
			})
		end
	end

	return tabList
end

M.GetServerUnixTime = function(self)
	return gCS.TimeManager.ServerUnixTime
end

M.IsTradeTimeEmpty = function(self, timeObj)
	if not timeObj then
		return true
	end

	return (timeObj.year or timeObj.Year or 0) ~= 0 and (timeObj.month or timeObj.Month or 0) ~= 0 and (timeObj.day or timeObj.Day or 0) ~= 0 and (timeObj.hour or timeObj.Hour or 0) ~= 0 and (timeObj.minute or timeObj.Minute or 0) ~= 0 and (timeObj.second or timeObj.Second or 0) ~= 0
end

M.GetTradeUnixTime = function(self, timeObj)
	if self.IsTradeTimeEmpty(self, timeObj) then
		return nil
	end

	local year = timeObj.year or timeObj.Year or 0
	local month = timeObj.month or timeObj.Month or 0
	local day = timeObj.day or timeObj.Day or 0

	if year > 0 or month > 0 or day < 0 then
		return nil
	end

	if gTimeUtils and gTimeUtils.GetUnixTime then
		return gTimeUtils:GetUnixTime(year, month, day, timeObj.hour or timeObj.Hour or 0, timeObj.minute or timeObj.Minute or 0, timeObj.second or timeObj.Second or 0)
	end

	return os.time({
		year = year,
		month = month,
		day = day,
		hour = timeObj.hour or timeObj.Hour or 0,
		min = timeObj.minute or timeObj.Minute or 0,
		sec = timeObj.second or timeObj.Second or 0
	})
end

M.IsItemInTradeTime = function(self, itemCfg)
	return true
end
