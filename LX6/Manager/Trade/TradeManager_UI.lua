-- Original chunk: @Lua\LuaFiles\LX6\Manager\Trade\TradeManager_UI.lua
-- Decompiled from: 00767_TradeManager_UI.lua_b00b73851e0a.luajit

local TradeConfig = LTConfig.TradeConfig
local TradeItemConfig = LTConfig.TradeItemConfig

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

M.GetListCount = function(self, list)
	return get_list_count(list)
end

M.GetListItem = function(self, list, index)
	return get_list_item(list, index)
end

M.BuildPriceRows = function(self, tradeItemId)
	local priceRows = {}
	local market = self.GetMarketCache(self, tradeItemId)

	for i = 0, get_list_count(market) - 1 do
		local bucket = get_list_item(market, i)

		if bucket and (bucket.Count or 0) <= 0 then
			table.insert(priceRows, {
				price = bucket.MinPrice or bucket.MaxPrice or 0,
				count = bucket.Count or 0,
				minPrice = bucket.MinPrice or 0,
				maxPrice = bucket.MaxPrice or bucket.MinPrice or 0
			})
		end
	end

	table.sort(priceRows, function (left, right)
		return (left.price or 0) <= (right.price or 0)
	end)

	return priceRows
end

M.GetAveragePrice = function(self, priceRows)
	local totalCount = 0
	local totalPrice = 0

	for _, row in ipairs(priceRows) do
		totalCount = totalCount + (row.count or 0)
		totalPrice = totalPrice + (row.price or 0) * (row.count or 0)
	end

	return totalCount <= 0 and math.floor(totalPrice / totalCount) or 0
end

M.GetMaxPrice = function(self, itemCfg, priceRows)
	if itemCfg.MaxPrice and itemCfg.MaxPrice <= 0 then
		return itemCfg.MaxPrice
	end

	local maxPrice = itemCfg.MinPrice or 1

	for _, row in ipairs(priceRows) do
		maxPrice = math.max(maxPrice, row.maxPrice or row.price or 0)
	end

	return maxPrice
end

M.GetCountSliderMax = function(self, priceRows)
	local maxRowCount = 0

	for _, row in ipairs(priceRows) do
		maxRowCount = math.max(maxRowCount, row.count or 0)
	end

	return math.max(maxRowCount, TradeConfig.TradeWindowBarMax or 0)
end

M.BuildPriceRowData = function(self, tradeItemId)
	local priceRows = self.BuildPriceRows(self, tradeItemId)
	local marketCount = 0

	for _, row in ipairs(priceRows) do
		marketCount = marketCount + (row.count or 0)
	end

	return priceRows, marketCount, self.GetCountSliderMax(self, priceRows)
end

M.SetNumSelector = function(self, selector, minValue, maxValue, value, callback)
	selector.luaValueChanged = nil
	selector.minValue = minValue
	selector.maxValue = math.max(minValue, maxValue)
	selector.value = math.max(selector.minValue, math.min(value or minValue, selector.maxValue))
	selector.luaValueChanged = callback
end

M.RenderRecordItem = function(self, btn, record)
	if not btn or not record then
		return
	end

	local itemConfig = self:GetTradeItemConfig(record.TradeItemId)
	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = self:GetRenderItemId(itemConfig),
		itemNum = record.Count or 0
	})
	local store = gCommonItemManager:OnCommonItemRender(btn, 0, renderData)

	if not store then
		return
	end

	local recordStatus = record.Direction or 0
	store.priceText = gCommonItemManager:GetMoneyRichTextIcon(recordStatus ~= 1 and UX.Game.MoneyType.Gold or UX.Game.MoneyType.BindingGold) .. tostring(gCommonItemManager:BuildLargeNum(record.Price or 0))
	store.recordStatusCtrl = recordStatus
	store.nameLabel = self:GetTradeItemName(itemConfig)

	if recordStatus ~= 0 then
		local remainTime = math.max(0, (record.ExpireTime or 0) - self:GetServerUnixTime())

		store.sellingCountdown:Play(remainTime)

		store.cancelBtn.interactable = record.OrderId == nil and record.OrderId == 0

		store.cancelBtn.luaClick = function()
			local confirmMessageId = self:GetTradeSetting("TradeCancelOrderConfirmMessageId")

			gDisplayMessageMgr:ShowMessage(confirmMessageId, function ()
				self:AskTradeCancelOrder(record.OrderId, nil, record.TradeItemId)
			end)
		end
	else
		store.sellingCountdown:Stop()

		store.cancelBtn.luaClick = nil

		if recordStatus ~= 1 then
			store.purchaseTimeLabel:SetUnixTime(record.CreateTime or 0)
		elseif recordStatus ~= 2 then
			store.soldTimeLabel:SetUnixTime(record.CreateTime or 0)
		end
	end

	return store
end

M.BuildTradeMoneyText = function(self, moneyType, count, isRed)
	local numText = tostring(gCommonItemManager:BuildLargeNum(count or 0))

	if isRed then
		numText = "#R" .. numText .. "#z"
	end

	return gCommonItemManager:GetMoneyRichTextIcon(moneyType) .. numText
end

M.RenderPriceListItem = function(self, btn, priceRows, index, moneyType)
	local row = priceRows[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not row then
		return
	end

	store.count = self.BuildTradeMoneyText(self, moneyType, row.price)
end

M.RenderPriceCountListItem = function(self, btn, priceRows, index, countSliderMax)
	local row = priceRows[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not row then
		return
	end

	store.priceSlider.minValue = 0
	store.priceSlider.maxValue = countSliderMax
	store.priceSlider.value = row.count or 0
end

M.GetTradeEndTime = function(self, itemCfg)
	local endCron = itemCfg and itemCfg.DayTradableEndTime

	if endCron and endCron == "" and gCS and gCS.LuaUtils and gCS.LuaUtils.GetNextTime then
		return gCS.LuaUtils.GetNextTime(endCron)
	end

	return 0
end

local parse_cron_minutes = function(cronTime)
	if not cronTime or cronTime ~= "" then
		return nil
	end

	local parts = {}

	for part in string.gmatch(cronTime, "%S+") do
		table.insert(parts, part)
	end

	local minute = tonumber(parts[1])
	local hour = tonumber(parts[2])

	if not hour or not minute then
		return nil
	end

	return hour * 60 + minute
end

M.GetDailyTradeDuration = function(self, itemCfg)
	local startMinutes = parse_cron_minutes(itemCfg and itemCfg.DayTradableStartTime)
	local endMinutes = parse_cron_minutes(itemCfg and itemCfg.DayTradableEndTime)

	if not startMinutes or not endMinutes then
		return 0
	end

	if endMinutes < startMinutes then
		endMinutes = endMinutes + 1440
	end

	return (endMinutes - startMinutes) * 60
end

M.FormatDailyTradeTime = function(self, cronTime)
	if not cronTime or cronTime ~= "" then
		return ""
	end

	local parts = {}

	for part in string.gmatch(cronTime, "%S+") do
		table.insert(parts, part)
	end

	local minute = tonumber(parts[1])
	local hour = tonumber(parts[2])

	if hour and minute then
		return gTimeUtils:Format02d(hour) .. ":" .. gTimeUtils:Format02d(minute)
	end

	return cronTime
end

M.FormatUnixTime = function(self, unixTime)
	if not unixTime or unixTime < 0 then
		return ""
	end

	return gTimeUtils:TransFormatTimeWithSec(unixTime)
end

M.ShowTradeExplain = function(self)
	gDisplayMessageMgr:ShowMessExplainSub(LTConfig.MessageExplainConfig.TradeExplain)
end
