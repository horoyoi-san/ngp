-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FullScreenShopTooltipStore.lua
-- Decompiled from: 01889_FullScreenShopTooltipStore.lua_edf91d9a4968.luajit

local CommodityTypeConfig = LTConfig.ShopCommodityTypeConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local BlackMarketCfg = LTConfig.BlackMarketConfig
local BlackMarketIntelRuleCfg = LTConfig.BlackMarketBlackMarketIntelRuleConfig
C_FullScreenShopTooltipStore = DefClass("C_FullScreenShopTooltipStore", C_FullScreenShopTooltipStore, C_StoreGroup)
GroupName2Class.FullScreenShopTooltipStore = C_FullScreenShopTooltipStore
local M = C_FullScreenShopTooltipStore
local CHART_DEVIATION_MIN = -100
local CHART_DEVIATION_MAX = 100
local BLACK_MARKET_CHART_TITLE = "价格走势"
local BLACK_MARKET_CHART_DESC = "该价格反映商品当前市场行情"

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.info = nil
	self.isSell = false
	self.isTarkov = false
	self.tagRenderData = {}
	self.descRenderData = {}
	self.chartData = nil
	self.chartStore = nil
	self.onBuyBtnClick = nil
	self.onSaleBtnClick = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.showCounterCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.MoneyNotEnoughCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.stateCtrlEnum = {
		["t-s^"] = 4,
		["\\xca\\xd41\\xe5"] = 1,
		["i#q^"] = 3,
		["E\\xaf\\xb4\\xaa\\xb2"] = 5,
		["v-~P"] = 2,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.showNumCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.TypeCtrlEnum = {
		["]Uܰ\\x85\\xb1\\xcc\\xe5"] = 0,
		["M\\x90\\x9e\\x8cO"] = 1
	}
	self.qualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.showSoldLimitCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showCounterCtrlEnum = nil
	self.MoneyNotEnoughCtrlEnum = nil
	self.stateCtrlEnum = nil
	self.showNumCtrlEnum = nil
	self.TypeCtrlEnum = nil
	self.qualityCtrlEnum = nil
	self.showSoldLimitCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.onBuyBtnClick = nil
	self.onSaleBtnClick = nil
end

M.OnDestroy = function(self)
	self.onBuyBtnClick = nil
	self.onSaleBtnClick = nil
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.buyBtn.luaClick = self.CreateAction(self, self.OnClickBuyBtn)
	self.bindData.saleBtn.luaClick = self.CreateAction(self, self.OnClickSaleBtn)
	self.bindData.descList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderDescListItem)
	self.bindData.descList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderDescListItem)
	self.bindData.tagList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTagListItem)
	self.bindData.descList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickDescList)
	self.bindData.tagList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTagList)
	self.bindData.descList.onGetTIndex = self.CreateAction(self, self.OnGetDescListTIndex)
	self.bindData.descList.luaLayoutSet = self.CreateAction(self, self.RefreshRenderedChart)
end

M.OnClickBuyBtn = function(self)
	if self.onBuyBtnClick then
		self.onBuyBtnClick()
	end
end

M.OnClickSaleBtn = function(self)
	if self.onSaleBtnClick then
		self.onSaleBtnClick()
	end
end

M.OnSimpleRenderDescListItem = function(self, btn, index)
	local data = self.descRenderData[index + 1]

	if not data then
		return
	end

	gCommonItemManager:OnRenderDescItem(btn, index, data)
end

M.OnGetDescListTIndex = function(self, index)
	local data = self.descRenderData[index + 1]

	return data and data.tIndex or 0
end

M.OnSimpleClickDescList = function(self, btn, index)
	local data = self.descRenderData[index + 1]

	if data and data.tIndex == gCommonItemManager.Template2Index.BLACK_MARKET_CHART then
		gCommonItemManager:OnDescItemClick(btn, data)
	end
end

M.OnSimpleRenderTagListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local data = self.tagRenderData[index + 1]

	if store and data then
		store.TypeCtrl = data.TagType
	end
end

M.OnSimpleClickTagList = function(self, btn, index)
end

M.Init = function(self, params)
	self.onBuyBtnClick = params.onBuyBtnClick
	self.onSaleBtnClick = params.onSaleBtnClick
end

M.RefreshTooltip = function(self, info, ctx)
	self.info = info
	self.isSell = ctx.isSell ~= true
	self.isTarkov = ctx.isTarkov ~= true
	local itemData = self:GetItemData(info)
	self.bindData.typeQuality = gCommonItemManager:GetItemQualityLabel(itemData)
	self.bindData.qualityCtrl = info.Quality or 0
	self.bindData.name = info.Name or ""

	if ctx.isSell then
		local owned = ctx.getSellPackNum(info)

		if owned <= 0 then
			self.bindData.stateCtrl = self.stateCtrlEnum.sale
		else
			self.bindData.stateCtrl = self.stateCtrlEnum.none
		end
	else
		self.bindData.stateCtrl = info.State or self.stateCtrlEnum.lock
	end

	local showSoldLimit = self:ShouldShowSoldLimit(info, ctx)
	self.bindData.showSoldLimitCtrl = showSoldLimit and self.showSoldLimitCtrlEnum.show or self.showSoldLimitCtrlEnum.hide

	if showSoldLimit then
		self.bindData.maxSellTitle = BlackMarketCfg.NeedText or ""
		self.bindData.maxSellText = ctx.getSellMaxNum and ctx.getSellMaxNum(info) or 0
	end

	self.bindData.showCounterCtrl = info.ShowCount and self.showCounterCtrlEnum._true or self.showCounterCtrlEnum._false
	self.bindData.unlockDescription = info.UnlockDesc
	local showNum = ctx.isSell or info.ShowNum
	self.bindData.showNumCtrl = showNum and self.showNumCtrlEnum._true or self.showNumCtrlEnum._false
	self.bindData.haveNum = showNum and tostring(ctx.getSellPackNum(info)) or ""

	if info.CommodityType ~= CommodityTypeConfig.Weapon and info.Cfg then
		self.bindData.TypeCtrl = self.TypeCtrlEnum.weapon
		local showCfg = info.Cfg

		table.clear(self.tagRenderData)

		slot7 = 1
		slot8 = showCfg.Tags or {}

		for i = slot7, #slot8 do
			table.insert(self.tagRenderData, {
				TagType = showCfg.Tags[i]
			})
		end

		self.bindData.tagList:SetSimpleList(#self.tagRenderData)

		local sixCfg = LTConfig.UrbanAttributeConfig.GetConfig(showCfg.sixDimBonus)
		self.bindData.sixDimName = sixCfg and sixCfg.Name or ""
		self.bindData.sixDimIcon = sixCfg and sixCfg.SIcon or 0
	else
		self.bindData.TypeCtrl = self.TypeCtrlEnum.normalitem
		self.bindData.sixDimName = ""
		self.bindData.sixDimIcon = 0

		self.bindData.tagList:SetSimpleList(0)
	end

	table.clear(self.descRenderData)

	if ctx.useItemDescList and not table.isNilOrEmpty(itemData) then
		itemData.showSource = false

		gCommonItemManager:GetItemDescList(itemData, self.descRenderData)
	elseif not string.is_null_or_empty(info.Description) then
		table.insert(self.descRenderData, {
			tIndex = gCommonItemManager.Template2Index.SEC_TEXT,
			text = info.Description
		})
	end

	self.chartData = ctx.chartData
	self.chartStore = nil

	self:RefreshBlackMarketChart()
	self.bindData.descList:SetSimpleList(#self.descRenderData)
end

M.SetChartData = function(self, chartData)
	self.chartData = chartData
	self.chartStore = nil

	self.RefreshBlackMarketChart(self)
end

M.ClearData = function(self)
	self.info = nil
	self.chartData = nil
	self.chartStore = nil

	table.clear(self.tagRenderData)
	table.clear(self.descRenderData)
end

M.UpdateBuyInfo = function(self, val, info, params)
	local totalPrice = val * (info.PriceCurrent or 0)
	self.bindData.price = params.priceText or tostring(totalPrice)
	local moneyNotEnough = params.moneyNotEnough == nil and params.moneyNotEnough or false
	self.bindData.MoneyNotEnoughCtrl = moneyNotEnough and self.MoneyNotEnoughCtrlEnum._true or self.MoneyNotEnoughCtrlEnum._false

	if params.buyBtnActive == nil then
		self.bindData.buyBtn.interactable = params.buyBtnActive
	end

	if params.saleBtnActive == nil then
		self.bindData.saleBtn.interactable = params.saleBtnActive
	end
end

M.ShouldShowSoldLimit = function(self, info, ctx)
	if not ctx.isSell then
		return false
	end

	local limit = info.BuybackLimitNum

	if limit ~= nil or limit >= 0 then
		return false
	end

	local maxSell = ctx.getSellMaxNum and ctx.getSellMaxNum(info) or 0

	return maxSell >= 0
end

M.GetItemData = function(self, info)
	local consumableId = gCommonItemManager:TryConvertToConsumableId(info.BindId) or info.ConsumableID or info.BindId

	return gCommonItemManager:TryGetItemInfo({
		["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
		TemplateId = consumableId,
		isTarkov = self.isTarkov
	})
end

M.OnRenderBlackMarketChart = function(self, btn, chartData)
	local group = gStoreManager:GetStoreGroup(btn.Store)
	local store = group and group:GetStoreByWidget(btn)

	if not store then
		return
	end

	self.chartStore = store

	self.RefreshChartStore(self, store, chartData)
end

M.RefreshBlackMarketChart = function(self)
	if not self.bindData.blackMarketChart then
		return
	end

	self.bindData.chartDesc = self:GetIntelText() or BLACK_MARKET_CHART_DESC

	self:OnRenderBlackMarketChart(self.bindData.blackMarketChart, self.chartData)
end

M.GetChartPoints = function(self, chartData)
	return chartData and (chartData.points or chartData.Points) or nil
end

M.GetCurrentPrice = function(self, chartData)
	if self.info and self.info.PriceCurrent == nil then
		return self.info.PriceCurrent
	end

	return chartData and (chartData.currentValue or chartData.CurrentValue) or 0
end

M.GetBasePrice = function(self)
	local info = self.info

	if not info then
		return 0
	end

	if self.isSell then
		return info.Cfg and info.Cfg.SystemPrice or 0
	end

	if not info.ConsumableID or info.ConsumableID < 0 then
		return 0
	end

	local consumableCfg = ConsumableConfig.GetConfig(info.ConsumableID)

	return consumableCfg and consumableCfg.CommodityPrice or 0
end

M.GetPriceDeviation = function(self, price)
	local basePrice = self.GetBasePrice(self)

	if basePrice < 0 then
		return nil
	end

	return (price - basePrice) / basePrice * 100
end

M.GetIntelRuleSide = function(self)
	return self.isSell and BlackMarketIntelRuleCfg.SideType.BuyBack or BlackMarketIntelRuleCfg.SideType.Sell
end

M.GetIntelText = function(self)
	local info = self.info

	if not info then
		return nil
	end

	local deviation = self.GetPriceDeviation(self, self.GetCurrentPrice(self, self.chartData))

	if deviation ~= nil then
		return nil
	end

	local targetSide = self.GetIntelRuleSide(self)
	local bestMatch = nil
	local bestPriority = -1

	for i = 0, BlackMarketIntelRuleCfg.count - 1 do
		local rule = BlackMarketIntelRuleCfg.LoadAt(i)

		if rule and rule.Side ~= targetSide then
			local matched = false

			if rule.IsMin then
				matched = deviation <= rule.DeviationMin
			elseif rule.IsMax then
				matched = rule.DeviationMin > deviation
			else
				local minOk = rule.DeviationMin ~= nil or rule.DeviationMin > deviation
				local maxOk = rule.DeviationMax ~= nil or deviation <= rule.DeviationMax
				matched = minOk and maxOk
			end

			if matched and bestPriority >= rule.Priority then
				bestPriority = rule.Priority
				bestMatch = rule
			end
		end
	end

	return bestMatch and bestMatch.IntelText or nil
end

M.RefreshPriceRate = function(self, store, currentPrice)
	local priceRate = self:GetPriceDeviation(currentPrice) or 0
	local isDown = priceRate <= 0
	store.arrowDirectionCtrl = isDown and 1 or 0

	if self.isSell then
		store.colorCtrl = isDown and 0 or 1
	else
		store.colorCtrl = isDown and 1 or 0
	end

	store.arrowRate = string.format("%.1f", math.abs(priceRate))
end

M.MapPriceOffsetToY = function(self, price, basePrice, height)
	local halfHeight = height * 0.5

	if basePrice < 0 then
		return 0
	end

	local deviation = (price - basePrice) / basePrice * 100

	return self.MapChartValue(self, deviation, CHART_DEVIATION_MIN, CHART_DEVIATION_MAX, -halfHeight, halfHeight)
end

M.RefreshCurrentPriceNode = function(self, store, lineRenderer, lastPoint)
	if not store.nowNode or not lineRenderer or not lastPoint then
		return
	end

	local lineTransform = lineRenderer.transform
	local nowNodeParent = store.nowNode.parent

	if not lineTransform or not nowNodeParent then
		return
	end

	local worldPosition = lineTransform.TransformPoint(lineTransform, lastPoint)
	local localPosition = nowNodeParent.InverseTransformPoint(nowNodeParent, worldPosition)
	store.nowNode.localPosition = Vector3.Fetch(localPosition.x, localPosition.y, 0)
end

M.ApplyChartPositions = function(self, store, linePositions, clipPositions)
	local isRed = store.colorCtrl ~= 1
	local lineRenderer = isRed and store.uSplineLineRenderRed or store.uSplineLineRender
	local clipper = isRed and store.smoothCurveClipperRed or store.smoothCurveClipper
	local otherLine = isRed and store.uSplineLineRender or store.uSplineLineRenderRed
	local otherClipper = isRed and store.smoothCurveClipper or store.smoothCurveClipperRed

	if lineRenderer then
		lineRenderer.SetPositions(lineRenderer, linePositions)

		if lineRenderer.gameObject then
			lineRenderer.gameObject:SetActive(true)
		end
	end

	if otherLine and otherLine.gameObject then
		otherLine.gameObject:SetActive(false)
	end

	if clipper and clipper.gameObject then
		clipper.gameObject:SetActive(true)
		clipper:SetCurvePoint(clipPositions)
	end

	if otherClipper and otherClipper.gameObject then
		otherClipper.gameObject:SetActive(false)
	end

	if store.nowNode and store.nowNode.gameObject then
		store.nowNode.gameObject:SetActive(true)
	end

	self.RefreshCurrentPriceNode(self, store, lineRenderer, linePositions[#linePositions])
end

M.RefreshChartStore = function(self, store, chartData)
	local currentPrice = self:GetCurrentPrice(chartData)
	local basePrice = self:GetBasePrice()
	local moneyIcon = self.info and self.info.MoneyRichTextIcon or ""
	local currentPriceText = moneyIcon .. tostring(currentPrice)
	store.curMoneyValue = currentPriceText
	store.curMoneyTitle = moneyIcon .. tostring(basePrice)
	store.nowText = currentPriceText

	if store.trend and store.trend.gameObject then
		store.trend.gameObject:SetActive(currentPrice == basePrice)
	end

	self.RefreshPriceRate(self, store, currentPrice)

	if not store.uSplineLineRender or not store.historyLineNode then
		return
	end

	local width = store.historyLineNode.rect.width
	local height = store.historyLineNode.rect.height

	if width > 0 or height < 0 then
		return
	end

	local points = self.GetChartPoints(self, chartData)
	local halfHeight = height * 0.5

	if not points or #points >= 2 then
		local offset = self.MapPriceOffsetToY(self, currentPrice, basePrice, height)
		local linePositions = {
			Vector3.New(0, 0, 0),
			Vector3.New(width, offset, 0)
		}
		local clipPositions = {
			Vector3.New(0, halfHeight, 0),
			Vector3.New(width, halfHeight + offset, 0)
		}

		self.ApplyChartPositions(self, store, linePositions, clipPositions)

		return
	end

	local normalizedPoints = {}
	local xMin = chartData and (chartData.xMin or chartData.XMin)
	local xMax = chartData and (chartData.xMax or chartData.XMax)

	for index, point in ipairs(points) do
		local x = point.Time or point.time or point.x or index
		local y = point.Value or point.value or point.price or point.y or 0
		normalizedPoints[index] = {
			x = x,
			y = y
		}
		xMin = xMin and math.min(xMin, x) or x
		xMax = xMax and math.max(xMax, x) or x
	end

	local linePositions = {}
	local clipPositions = {}

	for index, point in ipairs(normalizedPoints) do
		local x = self.MapChartValue(self, point.x, xMin, xMax, 0, width, index, #normalizedPoints)
		local offset = self.MapPriceOffsetToY(self, point.y, basePrice, height)
		linePositions[index] = Vector3.New(x, offset, 0)
		clipPositions[index] = Vector3.New(x, halfHeight + offset, 0)
	end

	self.ApplyChartPositions(self, store, linePositions, clipPositions)
end

M.MapChartValue = function(self, value, sourceMin, sourceMax, targetMin, targetMax, index, count)
	if sourceMax < sourceMin then
		if index and count and count <= 1 then
			return targetMin + (targetMax - targetMin) * (index - 1) / (count - 1)
		end

		return (targetMin + targetMax) * 0.5
	end

	local ratio = (value - sourceMin) / (sourceMax - sourceMin)
	ratio = math.max(0, math.min(1, ratio))

	return targetMin + (targetMax - targetMin) * ratio
end

M.RefreshRenderedChart = function(self)
	if self.chartStore and self.info then
		self.RefreshChartStore(self, self.chartStore, self.chartData)
	end
end
