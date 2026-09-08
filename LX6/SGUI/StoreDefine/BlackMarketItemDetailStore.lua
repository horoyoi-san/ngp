-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BlackMarketItemDetailStore.lua
-- Decompiled from: 01678_BlackMarketItemDetailStore.lua_fc07dafdc87f.luajit

C_BlackMarketItemDetailStore = DefClass("C_BlackMarketItemDetailStore", C_BlackMarketItemDetailStore, C_StoreGroup)
GroupName2Class.BlackMarketItemDetailStore = C_BlackMarketItemDetailStore
local M = C_BlackMarketItemDetailStore
local SHOW = {
	["k\\x8f\\x8e\\x9c\\x93"] = 0,
	["NH~"] = 1
}
local STATE_CTRL = {
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["\\x98\\x9e)\\x8fU\\xcb"] = 1,
	["IQ~"] = 3,
	["V\r^p"] = 2,
	["T\rS~"] = 4
}
local TYPE_CTRL = {
	["+m\\xb0\\xbe\\xaco"] = 1,
	["\\xb1Y\\xb1~\\xf0\\x8f\\x94"] = 0
}
local CHART_DEVIATION_MIN = -100
local CHART_DEVIATION_MAX = 100
local BLACK_MARKET_CHART_TITLE = "价格走势"
local BLACK_MARKET_CHART_DESC = "该价格反映商品当前市场行情"
local CommodityTypeConfig = LTConfig.ShopCommodityTypeConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local BlackMarketCfg = LTConfig.BlackMarketConfig
local BlackMarketIntelRuleCfg = LTConfig.BlackMarketBlackMarketIntelRuleConfig

M.ctor = function(self)
	self.info = nil
	self.isSell = false
	self.owned = 0
	self.isTarkov = false
	self.tagRenderData = {}
	self.descRenderData = {}
	self.chartData = nil
	self.chartStore = nil
	self.view = nil
end

M.BindView = function(self, view)
	if not view then
		return
	end

	self.view = view
	view.tagList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTagListItem")
	view.descList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderDescListItem")
	view.descList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnRenderDescListItem")
	view.descList.luaSimpleClick = self.CreateAction(self, "OnDescListItemClick")
	view.descList.onGetTIndex = self.CreateAction(self, "OnGetDescListTIndex")
	view.descList.luaLayoutSet = self.CreateAction(self, "RefreshRenderedChart")
end

M.ClearData = function(self)
	self.info = nil
	self.chartData = nil
	self.chartStore = nil

	table.clear(self.tagRenderData)
	table.clear(self.descRenderData)
end

M.SetCommodity = function(self, info, isSell, owned, isTarkov, chartData)
	if not self.view then
		return
	end

	self.info = info
	self.isSell = isSell ~= true
	self.owned = owned or 0
	self.isTarkov = isTarkov ~= true
	self.chartData = chartData
	self.chartStore = nil

	self:RefreshBasicInfo()
	self:RefreshWeaponInfo()
	self:RefreshDescList()
end

M.SetChartData = function(self, chartData)
	self.chartData = chartData
	self.chartStore = nil

	if self.view and self.info then
		self.RefreshDescList(self)
	end
end

M.RefreshBasicInfo = function(self)
	local info = self.info

	if not info then
		return
	end

	local itemData = self:GetItemData(info)
	self.view.name = info.Name or ""
	self.view.typeQuality = gCommonItemManager:GetItemQualityLabel(itemData)
	self.view.qualityCtrl = info.Quality or 0
	self.view.unlockDescription = info.UnlockDesc or ""
	local showNum = self.isSell or info.ShowNum
	self.view.showNumCtrl = showNum and SHOW.TRUE or SHOW.FALSE
	self.view.haveNum = showNum and tostring(self.owned) or ""
	self.view.showCounterCtrl = info.ShowCount and SHOW.TRUE or SHOW.FALSE

	if self.isSell then
		if self.owned <= 0 and info.RemainNum and info.RemainNum < 0 then
			self.view.stateCtrl = STATE_CTRL.SOLD_OUT
		elseif self.owned <= 0 then
			self.view.stateCtrl = STATE_CTRL.SALE
		else
			self.view.stateCtrl = STATE_CTRL.NONE
		end
	else
		self.view.stateCtrl = info.State or STATE_CTRL.LOCK
	end
end

M.GetItemData = function(self, info)
	local consumableId = gCommonItemManager:TryConvertToConsumableId(info.BindId) or info.ConsumableID or info.BindId

	return gCommonItemManager:TryGetItemInfo({
		["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
		TemplateId = consumableId,
		isTarkov = self.isTarkov
	})
end

M.RefreshWeaponInfo = function(self)
	local info = self.info
	local isWeapon = info and info.CommodityType ~= CommodityTypeConfig.Weapon and info.Cfg

	table.clear(self.tagRenderData)

	if not isWeapon then
		self.view.TypeCtrl = TYPE_CTRL.NORMAL_ITEM
		self.view.sixDimName = ""
		self.view.sixDimIcon = 0

		self.view.tagList:SetSimpleList(0)

		return
	end

	self.view.TypeCtrl = TYPE_CTRL.WEAPON
	slot3 = ipairs
	slot5 = info.Cfg.Tags or {}

	for _, tagType in slot3(slot5) do
		table.insert(self.tagRenderData, {
			TagType = tagType
		})
	end

	self.view.tagList:SetSimpleList(#self.tagRenderData)

	local sixDimId = info.Cfg.sixDimBonus
	local sixCfg = sixDimId and LTConfig.UrbanAttributeConfig.GetConfig(sixDimId)
	self.view.sixDimName = sixCfg and sixCfg.Name or ""
	self.view.sixDimIcon = sixCfg and sixCfg.SIcon or 0
end

M.RefreshDescList = function(self)
	local info = self.info

	table.clear(self.descRenderData)

	if not info then
		self.view.descList:SetSimpleList(0)

		return
	end

	local itemData = self.GetItemData(self, info)

	if not table.isNilOrEmpty(itemData) then
		itemData.showSource = false

		gCommonItemManager:GetItemDescList(itemData, self.descRenderData)
	elseif not string.is_null_or_empty(info.Description) then
		table.insert(self.descRenderData, {
			tIndex = gCommonItemManager.Template2Index.SEC_TEXT,
			text = info.Description
		})
	end

	self:RefreshBlackMarketChart()
	self.view.descList:SetSimpleList(#self.descRenderData)
end

M.RefreshBlackMarketChart = function(self)
	self.bindData.chartDesc = self:GetIntelText() or BLACK_MARKET_CHART_DESC

	self:OnRenderBlackMarketChart(self.bindData.blackMarketChart, self.chartData)
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

M.GetChartPoints = function(self, chartData)
	return chartData and (chartData.points or chartData.Points) or nil
end

M.OnRenderTagListItem = function(self, btn, index)
	local group = gStoreManager:GetStoreGroup(btn.Store)
	local store = group and group:GetStoreByWidget(btn)
	local data = self.tagRenderData[index + 1]

	if store and data then
		store.TypeCtrl = data.TagType
	end
end

M.OnRenderDescListItem = function(self, btn, index)
	local data = self.descRenderData[index + 1]

	if not data then
		return
	end

	gCommonItemManager:OnRenderDescItem(btn, index, data)
end

M.OnDescListItemClick = function(self, btn, index)
	local data = self.descRenderData[index + 1]

	if data and data.tIndex == gCommonItemManager.Template2Index.BLACK_MARKET_CHART then
		gCommonItemManager:OnDescItemClick(btn, data)
	end
end

M.OnGetDescListTIndex = function(self, index)
	local data = self.descRenderData[index + 1]

	return data and data.tIndex or 0
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

M.RefreshRenderedChart = function(self)
	if self.chartStore and self.info then
		self.RefreshChartStore(self, self.chartStore, self.chartData)
	end
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

M.RefreshPrice = function(self, totalPrice, moneyNotEnough, canConfirm)
	if not self.info then
		return
	end

	self.view.price = (self.info.MoneyRichTextIcon or "") .. tostring(totalPrice)
	self.view.MoneyNotEnoughCtrl = moneyNotEnough and SHOW.TRUE or SHOW.FALSE
	self.view.buyBtn.interactable = not self.isSell and canConfirm
	self.view.saleBtn.interactable = self.isSell and canConfirm
end
