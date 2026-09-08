-- Original chunk: @Lua\LuaFiles\LX6\Manager\HotCenter\HotCenterManager.lua
-- Decompiled from: 00361_HotCenterManager.lua_94643eaec287.luajit

C_HotCenterManager = DefClass("C_HotCenterManager", C_HotCenterManager)
local M = C_HotCenterManager
local LinkHubConfig = LTConfig.LinkHubConfig
local LinkHubGameplayConfig = LTConfig.LinkHubGameplayConfig
local LinkHubTagConfig = LTConfig.LinkHubTagConfig
local PublicEventConfig = LTConfig.PublicEventConfig
local CollectionCountryConfig = LTConfig.CollectionCountryConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local InspireHubGamePlayTypeConfig = LTConfig.InspireHubGamePlayTypeConfig
local InspireHubGamePlayConfig = LTConfig.InspireHubGamePlayConfig
local InspireHubConfig = LTConfig.InspireHubConfig
local HOT_CENTER_DYNAMIC_SYSTEM_UNLOCK_ID = SystemUnlockConfig.InspireHub
local POPULARITY_SETTLEMENT_ANIM_DURATION = 3

local GetPopularityGrowthCtrl = function(popularity)
	local popularityLevelList = LTConfig.GrowthConfig.PopularityLevel

	for i = #popularityLevelList, 1, -1 do
		if popularityLevelList[i] < popularity then
			return #popularityLevelList - i
		end
	end

	return #popularityLevelList
end

local BindTooltipCloseButton = function(closeBtn, ownerBtn)
	if closeBtn then
		closeBtn.luaClick = function()
			ownerBtn:CloseTooltip(true)
		end
	end
end

local OpenPopularityDataPanel = function()
	gPanelManager:CheckShow(gPanelId.S_HOT_CENTER_DATA_PANEL)
end

local GetTooltipBackButton = function(popIns)
	if not popIns or not popIns.transform then
		return
	end

	local trans = popIns.transform:Find("BackBtn")
	trans = trans or popIns.transform:Find("S_CommonRightWindow/BackBtn")

	if not trans then
		return
	end

	return trans:GetComponent("UButton")
end

local BindTooltipCloseButtons = function(ownerBtn, popIns, popStore)
	if not ownerBtn then
		return
	end

	BindTooltipCloseButton(popStore and popStore.exitBtn, ownerBtn)
	BindTooltipCloseButton(popStore and popStore.exitBtn2, ownerBtn)
	BindTooltipCloseButton(GetTooltipBackButton(popIns), ownerBtn)
end

local GetStoreByWidget = function(widget)
	if not widget then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(widget.Store)

	return storeGroup and storeGroup:GetStoreByWidget(widget)
end

local GetListCount = function(list)
	if not list then
		return 0
	end

	if list.Count == nil then
		return list.Count
	end

	return #list
end

local IsCurrentLogicDay = function(time)
	return time and UXCommon.Time.UXLogicTime.IsSameDay(time, gLuaDataManager.serverTime)
end

local IsYesterdayLogicDay = function(time)
	local dayTime = 86400

	return time and UXCommon.Time.UXLogicTime.IsSameDay(time, gLuaDataManager.serverTime - dayTime)
end

local RenderPopularityInfoScroll = function(popStore)
	local scrollRect = popStore and popStore.popularityInfoScrollRect
	local scrollStore = GetStoreByWidget(scrollRect and scrollRect.content)

	if not scrollStore then
		return
	end

	local moneyStore = GetStoreByWidget(scrollStore.money)

	if moneyStore then
		moneyStore.expectedEarnings = tostring(gHotCenterManager:GetExpectedPopularityEarnings())
		moneyStore.todayMaxValue = tostring(gHotCenterManager:GetTodayMaxPopularity())
	end

	local chartStore = GetStoreByWidget(scrollStore.popularityChart)

	if not chartStore then
		return
	end

	local currentPopularity = gSocialNetworkUtils.GetCurrentPopularityValue()
	local popularityData = gHotCenterManager.GetSevenDaysPopularityData()
	local sourceData = gHotCenterManager:GetTodayPopularitySourceList()
	local maxPopularity = LTConfig.GameConfig.MaxPopularity
	chartStore.popularity = tostring(currentPopularity)
	chartStore.gainSpeedCtrl = gHotCenterManager:GetPopularityGainSpeedCtrl()
	local currentTime = gCS.TimeManager.ServerUnixTime
	local dayTime = 86400

	for i = 1, 7 do
		local date = os.date("*t", currentTime - 14400 - dayTime * (7 - i))
		chartStore["xAxisLabel" .. tostring(i)] = string.format("%d.%d", date.month, date.day)
	end

	if chartStore.popularityList then
		chartStore.popularityList.luaSimpleRenderItem = function(btn, index)
			local info = popularityData[index + 1]

			if not info or maxPopularity < 0 then
				return
			end

			local uGradient = btn:GetComponentInChildren(typeof(SGUI.Effect.UGradient))

			if not uGradient then
				return
			end

			local scale = math.max(info.popularity or 0, 0) / maxPopularity

			gInspireHubUtils.SetUGradientScaleY(uGradient, math.min(scale, 0.999999))
		end

		chartStore.popularityList:SetSimpleList(#popularityData)
	end

	if chartStore.sourceList then
		chartStore.sourceList.luaSimpleRenderItem = function(btn, index)
			local info = sourceData[index + 1]
			local itemStore = GetStoreByWidget(btn)

			if not info or not itemStore then
				return
			end

			itemStore.title = gHotCenterManager:GetPopularitySourceTitle(info.DropId)
			itemStore.value = string.format("%+d", info.Popularity or 0)
		end

		chartStore.sourceList:SetSimpleList(#sourceData)
	end

	if chartStore.switchBtn then
		local showSource = chartStore.contentTypeCtrl ~= 1
		chartStore.contentTypeCtrl = showSource and 1 or 0

		chartStore.switchBtn.luaClick = function()
			showSource = not showSource
			chartStore.contentTypeCtrl = showSource and 1 or 0
		end
	end
end

local RenderPopularityTooltip = function(button, popIns)
	local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

	if not popStore then
		return
	end

	popStore.moneyDesc = LinkHubConfig.PopularityMoneyDes or ""
	popStore.title = LinkHubConfig.PopularityTipTitle or ""
	gHotCenterManager.activePopularityInfoStore = popStore

	RenderPopularityInfoScroll(popStore)
	BindTooltipCloseButtons(button, popIns, popStore)

	button.luaTooltipPopup = function(_, isOpen)
		if not isOpen and gHotCenterManager.activePopularityInfoStore ~= popStore then
			gHotCenterManager.activePopularityInfoStore = nil
		end
	end
end

M.ctor = function(self)
	self.SUB_PANEL_LIST_TEMPLATE_TYPE = {
		["|t┪-\\x87&\\xe0\\xcf"] = 4,
		["\\x86\\x90,\\x85U\\xd7"] = 0,
		["-\\xcds$\\xf5#\\x9bh\\x85r\\x9c\\x93"] = 3,
		["\\x86\\x90,\\x85U\\xd1"] = 5,
		["~{瓻;\\x95%\\xe5\\xc4"] = 1,
		["@X\\x80^b\\x97\\xcdtG[R`"] = 2
	}
	self.GAMEPLAY_TYPE_TO_TEMPLATE_TYPE = {
		self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_BIG,
		self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_SMALL,
		self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_JOB,
		[44000300] = self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_SMALL,
		[44000003] = self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_BIG,
		[44000005] = self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_BIG
	}
	self.JOB_STATUS = {
		["0g\\xb2\\xa5\\xa6e"] = 2,
		["tuCGi!;="] = 3,
		["ZX\\x88^\\x91\\xddqOH[h"] = 0,
		["dhᓣ7\\x8a+\\xe5\\xcd"] = 1,
		["2g\\xa3\\xa3\\xa2m"] = 4
	}
	self.homeDailyRecommendPoolMap = {}
	self.homeRankDisplayMap = {}
	self.hasRequestedPopularityUIOpened = false
	self.popularitySettlementAnimPlayedTime = nil
	self.isPopularitySettlementAnimPlaying = false
	self.popularitySettlementAnimStores = {}
	self.popularitySettlementAnimTimer = nil
	self.hasRequestedPopularityPhoneFirstOpened = false
	self.phonePopularitySettlementAnimPlayedTime = nil
	self.isPhonePopularitySettlementAnimPlaying = false
	self.phonePopularitySettlementAnimStores = {}
	self.phonePopularitySettlementAnimTimer = nil
	self.yesterdayPopularityEarnings = nil
	self.yesterdayPopularityEarningsTime = nil
	self.todayHighestPopularity = nil
	self.todayHighestPopularityTime = nil
	self.activePopularityDataPanelStore = nil
end

M.RenderFansData = function(content)
	if not content then
		return
	end

	local store = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	if not store then
		return
	end

	store.fansNum = gClientUtils.FormatWithThousandsSeparator(gPlayerManager.infoMinor.bindData.fan123)
	local fansIncrease = gPlayerManager.infoMinor.bindData.fan123 - (gPlayerManager.infoMinor.bindData.yesterdayFan or 0)
	store.fansAddNum = gClientUtils.FormatWithThousandsSeparator(fansIncrease)
	store.fansIncreaseCtrl = fansIncrease <= 0 and 1 or 0
	local hasReward = gClientUtils.CheckHasLevelReward()
	local redDotKey = "InspireHub.TakeFanReward"
	content.redKey = redDotKey

	SGUI.RedDotMgr.LuaSetRedDot(hasReward, "InspireHub/" .. redDotKey)

	if store.fansShowMoreBtn then
		store.fansShowMoreBtn.luaClick = function()
			gPanelManager:CheckShow(gPanelId.YANJIE_MEMBER_CENTER_PANEL)
		end
	end
end

M.RenderSeasonData = function(self, content)
	if not content then
		return
	end

	local store = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	if not store then
		return
	end

	local hasSeason = gOnlineSeasonProgressMgr:HasActiveSeason()

	content:SetActive(hasSeason)

	if not hasSeason then
		return
	end

	local info = gOnlineSeasonProgressMgr:GetCurrentLevelProgressInfo()
	store.seasonNum = tostring(info.level)
end

M.RenderPopularitySettlementAnim = function(self, store)
	if not store then
		return
	end

	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local serverTime = gLuaDataManager.serverTime
	local hasPlayedToday = self.popularitySettlementAnimPlayedTime and UXCommon.Time.UXLogicTime.IsSameDay(self.popularitySettlementAnimPlayedTime, serverTime)
	local shouldStartSettlementAnim = popularityInfo and not popularityInfo.IsFirstTriggered and self.hasRequestedPopularityUIOpened and not hasPlayedToday

	if self.isPopularitySettlementAnimPlaying or shouldStartSettlementAnim then
		store.showAnimCtrl = 1
		store.upCtrl = 0
		self.popularitySettlementAnimStores[store] = true

		if shouldStartSettlementAnim then
			self.popularitySettlementAnimPlayedTime = serverTime
			self.isPopularitySettlementAnimPlaying = true
			self.popularitySettlementAnimTimer = Timer.New(function ()
				self.popularitySettlementAnimTimer = nil
				self.isPopularitySettlementAnimPlaying = false

				for animStore in pairs(self.popularitySettlementAnimStores) do
					animStore.showAnimCtrl = 0
					animStore.upCtrl = self:GetPopularityGainSpeedCtrl()
				end

				self.popularitySettlementAnimStores = {}
			end, POPULARITY_SETTLEMENT_ANIM_DURATION):Start()
		end
	else
		store.showAnimCtrl = 0
	end
end

M.RenderPhonePopularitySettlementAnim = function(self, store, canPlay, popularityStore)
	if not store then
		return
	end

	if not canPlay then
		store.showAnimCtrl = 0

		return
	end

	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local serverTime = gLuaDataManager.serverTime
	local hasPlayedToday = self.phonePopularitySettlementAnimPlayedTime and UXCommon.Time.UXLogicTime.IsSameDay(self.phonePopularitySettlementAnimPlayedTime, serverTime)
	local shouldStartSettlementAnim = popularityInfo and not popularityInfo.IsFirstPhoneOpened and self.hasRequestedPopularityPhoneFirstOpened and self:GetYesterdayPopularityEarnings() > 0 and not hasPlayedToday and not self.isPhonePopularitySettlementAnimPlaying

	if self.isPhonePopularitySettlementAnimPlaying or shouldStartSettlementAnim then
		store.showAnimCtrl = 1
		popularityStore.upCtrl = 0
		self.phonePopularitySettlementAnimStores[store] = popularityStore

		if shouldStartSettlementAnim then
			self.phonePopularitySettlementAnimPlayedTime = serverTime
			self.isPhonePopularitySettlementAnimPlaying = true
			self.phonePopularitySettlementAnimTimer = Timer.New(function ()
				self.phonePopularitySettlementAnimTimer = nil
				self.isPhonePopularitySettlementAnimPlaying = false

				for animStore, animPopularityStore in pairs(self.phonePopularitySettlementAnimStores) do
					animStore.showAnimCtrl = 0
					animPopularityStore.upCtrl = self:GetPopularityGainSpeedCtrl()
				end

				self.phonePopularitySettlementAnimStores = {}
			end, POPULARITY_SETTLEMENT_ANIM_DURATION):Start()
		end
	else
		store.showAnimCtrl = 0
	end
end

M.RenderPopularityData = function(self, content)
	if not content then
		return
	end

	local store = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	if not store then
		return
	end

	local currentPopularity = gSocialNetworkUtils.GetCurrentPopularityValue()
	store.popularityNum = tostring(currentPopularity)
	store.oldPopularityNum = tostring(self:GetYesterdayPopularityEarnings())
	store.upCtrl = GetPopularityGrowthCtrl(currentPopularity)

	self:RenderPopularitySettlementAnim(store)

	store.button.enabledTooltip = false
	store.button.luaRenderTooltip = nil
	store.button.luaClick = OpenPopularityDataPanel
end

M.RenderRewardData = function(content)
	if not content then
		return
	end

	local store = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	if not store then
		return
	end

	local progress = gPlayerManager.infoMinor.bindData.popularityInfo.FanBoxDropInfo.AwardScore / LTConfig.GameConfig.FanRewardBoxCumulativeScore
	local limit = LTConfig.GameConfig.FanRewardBoxWeekLimit > gPlayerManager.infoMinor.bindData.popularityInfo.FanBoxDropInfo.WeekDropCount
	local hasReward = gPlayerManager.infoMinor.bindData.popularityInfo.FanBoxDropInfo.DropCount >= 0
	store.dailyLimitCtrl = limit and 1 or 0
	store.rewardProgress.value = progress
	local btn = store.button
	local redDotKey = "InspireHub.HotCenterReward"
	store.button.redKey = redDotKey

	SGUI.RedDotMgr.LuaSetRedDot(hasReward, "InspireHub/" .. redDotKey)

	store.button.luaClick = function()
		if gPlayerManager.infoMinor.bindData.popularityInfo.FanBoxDropInfo.DropCount <= 0 then
			if btn then
				btn:CloseTooltip(true)
			end

			gClientToGameDelegate:AskTakePopularityFanBoxReward().Callback = function (errorId)
				if errorId == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end

				gHotCenterManager.RenderRewardData(content)
			end
		elseif btn then
			btn:OpenTooltip()
		end
	end

	store.button.luaRenderTooltip = function(button, popIns, index)
		local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

		if not popStore then
			return
		end

		local explainCfg = LTConfig.MessageExplainConfig.GetConfig(LinkHubConfig.InspireWeeklyRewardExplainId)
		popStore.title = explainCfg.Title or ""
		popStore.content = explainCfg.Content

		BindTooltipCloseButtons(button, popIns, popStore)
	end
end

local RenderSevenDaysPopularitySpline = function(spline, useLeftOrigin)
	if not spline then
		return
	end

	if useLeftOrigin ~= nil then
		local rectTransform = spline.rectTransform
		local pivot = rectTransform and rectTransform.pivot
		useLeftOrigin = pivot and pivot.x == nil and pivot.x > 0.1 or false
	end

	spline:ClearPoint()

	local size = spline.rectTransform.rect.size
	local data, maxPopularity = gHotCenterManager.GetSevenDaysPopularityData()

	if maxPopularity < 0 then
		if useLeftOrigin then
			spline:AddPoint(0, 0, 5, true, 0, 0)
			spline:AddPoint(size.x, 0, 5, true, 0, 0)
		else
			spline:AddPoint(-0.5 * size.x, 0, 5, true, 0, 0)
			spline:AddPoint(0.5 * size.x, 0, 5, true, 0, 0)
		end
	else
		local maxPercent = 0.8
		local deltaX = size.x / 6

		for i = 1, #data do
			local info = data[i]
			local posX = nil

			if useLeftOrigin then
				posX = (info.day - 1) * deltaX
			else
				posX = (info.day - 4) * deltaX
			end

			local posY = maxPercent * info.popularity / maxPopularity * size.y

			spline:AddPoint(posX, posY, 5, true, 0, 0)
		end
	end

	spline:RefreshSpline()
end

M.RenderMainPhoneSevenDaysPopularityData = function(self, content)
	if not content then
		return
	end

	local store = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	if not store then
		return
	end

	local popularityStore = nil

	if store.popularityWidget then
		popularityStore = gStoreManager:GetStoreGroup(store.popularityWidget.Store):GetStoreByWidget(store.popularityWidget)
	end

	local chartWidget = popularityStore and popularityStore.popularityWidget
	local spline = chartWidget and chartWidget.spline or store.popularityWidget and store.popularityWidget.spline or popularityStore and popularityStore.spline or store.spline

	if not spline then
		return
	end

	RenderSevenDaysPopularitySpline(spline)
end

M.RenderSevenDaysPopularityData = function(self, content, enableTooltip)
	if not content then
		return
	end

	local store = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	if not store then
		return
	end

	local currentPopularity = gSocialNetworkUtils.GetCurrentPopularityValue()
	store.popularityNum = tostring(currentPopularity)
	store.oldPopularityNum = tostring(self:GetYesterdayPopularityEarnings())
	store.upCtrl = GetPopularityGrowthCtrl(currentPopularity)

	RenderSevenDaysPopularitySpline(store.spline)

	store.button.enabledTooltip = false
	store.button.luaRenderTooltip = nil

	if enableTooltip then
		store.button.luaClick = OpenPopularityDataPanel
	else
		store.button.luaClick = nil
	end
end

M.GetSevenDaysPopularityData = function()
	local data = {}
	local currentTime = gCS.TimeManager.ServerUnixTime
	local dayTime = 86400

	for i = 1, 7 do
		table.insert(data, {
			day = i,
			time = currentTime - dayTime * (7 - i)
		})
	end

	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local currentPopularity = popularityInfo and popularityInfo.Popularity or 0
	local list = popularityInfo and popularityInfo.PastDaysHighestPopularityList

	for i = 1, GetListCount(list) do
		local info = list[i]

		for j = 1, #data do
			if UXCommon.Time.UXLogicTime.IsSameDay(info.Time, data[j].time) then
				data[j].popularity = math.max(data[j].popularity or 0, info.Value or 0)

				break
			end
		end
	end

	data[7].popularity = math.max(data[7].popularity or 0, currentPopularity)

	if gHotCenterManager.todayHighestPopularityTime and UXCommon.Time.UXLogicTime.IsSameDay(gHotCenterManager.todayHighestPopularityTime, currentTime) then
		data[7].popularity = math.max(data[7].popularity, gHotCenterManager.todayHighestPopularity or 0)
	end

	local maxPopularity = 0
	local lastValue = 0

	for i = 1, #data do
		local info = data[i]

		if info.popularity ~= nil then
			info.popularity = lastValue
		else
			lastValue = info.popularity
		end

		if maxPopularity >= info.popularity then
			maxPopularity = info.popularity
		end
	end

	return data, maxPopularity
end

M.GetExpectedPopularityEarnings = function(self)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local dayRewardList = popularityInfo and popularityInfo.DayRewardList
	local totalCoin = 0

	for i = 1, GetListCount(dayRewardList) do
		local dayReward = dayRewardList[i]

		if IsCurrentLogicDay(dayReward.Time) then
			for j = 1, GetListCount(dayReward.RewardList) do
				local rewardInfo = dayReward.RewardList[j]

				if not rewardInfo.IsReward then
					totalCoin = totalCoin + (rewardInfo.CoinCount or 0)
				end
			end
		end
	end

	return totalCoin
end

M.UpdateYesterdayPopularityEarnings = function(self, dayRewardList)
	local totalCoin = 0

	for i = 1, GetListCount(dayRewardList) do
		local dayReward = dayRewardList[i]

		if IsYesterdayLogicDay(dayReward.Time) then
			for j = 1, GetListCount(dayReward.RewardList) do
				totalCoin = totalCoin + (dayReward.RewardList[j].CoinCount or 0)
			end
		end
	end

	self.yesterdayPopularityEarnings = totalCoin
	self.yesterdayPopularityEarningsTime = gLuaDataManager.serverTime
end

M.GetYesterdayPopularityEarnings = function(self)
	local serverTime = gLuaDataManager.serverTime

	if not self.yesterdayPopularityEarningsTime or not UXCommon.Time.UXLogicTime.IsSameDay(self.yesterdayPopularityEarningsTime, serverTime) then
		local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

		self:UpdateYesterdayPopularityEarnings(popularityInfo and popularityInfo.DayRewardList)
	end

	return self.yesterdayPopularityEarnings or 0
end

M.GetTodayMaxPopularity = function(self)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local maxPopularity = popularityInfo and popularityInfo.Popularity or 0
	local list = popularityInfo and popularityInfo.PastDaysHighestPopularityList

	for i = 1, GetListCount(list) do
		local info = list[i]

		if IsCurrentLogicDay(info.Time) then
			maxPopularity = math.max(maxPopularity, info.Value or 0)
		end
	end

	if self.todayHighestPopularityTime and UXCommon.Time.UXLogicTime.IsSameDay(self.todayHighestPopularityTime, gLuaDataManager.serverTime) then
		maxPopularity = math.max(maxPopularity, self.todayHighestPopularity or 0)
	end

	return math.floor(maxPopularity)
end

M.GetPopularityGainSpeedCtrl = function(self)
	return GetPopularityGrowthCtrl(gSocialNetworkUtils.GetCurrentPopularityValue())
end

M.GetTodayPopularitySourceList = function(self)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local recordList = popularityInfo and popularityInfo.DropRecordList
	local data = {}

	for i = 1, GetListCount(recordList) do
		local info = recordList[i]

		if IsCurrentLogicDay(info.Time) then
			table.insert(data, info)
		end
	end

	table.sort(data, function (a, b)
		return (a.Time or 0) >= (b.Time or 0)
	end)

	return data
end

M.GetPopularitySourceTitle = function(self, dropId)
	local dropCfg = dropId and LTConfig.DropConfig.GetConfig(dropId)

	if dropCfg and dropCfg.ReasonText and dropCfg.ReasonText <= 0 then
		local textCfg = LTConfig.TextConfig.GetConfig(dropCfg.ReasonText)

		if textCfg then
			return textCfg.Text or ""
		end
	end

	for i = 0, LTConfig.InspireHubHotGainConfig.count - 1 do
		local cfg = LTConfig.InspireHubHotGainConfig.LoadAt(i)

		if cfg.DropId ~= dropId then
			return cfg.Description or ""
		end
	end

	return ""
end

M.RecordTodayHighestPopularity = function(self, popularity)
	local currentTime = gCS.TimeManager.ServerUnixTime

	if not self.todayHighestPopularityTime or not UXCommon.Time.UXLogicTime.IsSameDay(self.todayHighestPopularityTime, currentTime) then
		self.todayHighestPopularity = 0
	end

	self.todayHighestPopularityTime = currentTime
	self.todayHighestPopularity = math.max(self.todayHighestPopularity or 0, popularity or 0)
end

M.RefreshPopularityInfoScroll = function(self)
	if self.activePopularityInfoStore then
		RenderPopularityInfoScroll(self.activePopularityInfoStore)
	end

	if self.activePopularityDataPanelStore then
		self.activePopularityDataPanelStore:RefreshData()
	end
end

M.ClearPopularityInfoScroll = function(self)
	self.activePopularityInfoStore = nil
end

M.ResetPopularityFirstOpenState = function(self)
	self.hasRequestedPopularityUIOpened = false
	self.popularitySettlementAnimPlayedTime = nil
	self.isPopularitySettlementAnimPlaying = false

	if self.popularitySettlementAnimTimer then
		self.popularitySettlementAnimTimer:Stop()

		self.popularitySettlementAnimTimer = nil
	end

	for animStore in pairs(self.popularitySettlementAnimStores) do
		animStore.showAnimCtrl = 0
		animStore.upCtrl = self:GetPopularityGainSpeedCtrl()
	end

	self.popularitySettlementAnimStores = {}
	self.hasRequestedPopularityPhoneFirstOpened = false
	self.phonePopularitySettlementAnimPlayedTime = nil
	self.isPhonePopularitySettlementAnimPlaying = false

	if self.phonePopularitySettlementAnimTimer then
		self.phonePopularitySettlementAnimTimer:Stop()

		self.phonePopularitySettlementAnimTimer = nil
	end

	for animStore, animPopularityStore in pairs(self.phonePopularitySettlementAnimStores) do
		animStore.showAnimCtrl = 0
		animPopularityStore.upCtrl = self:GetPopularityGainSpeedCtrl()
	end

	self.phonePopularitySettlementAnimStores = {}
	self.todayHighestPopularity = nil
	self.todayHighestPopularityTime = nil
end

M.TryNotifyPopularityUIOpened = function(self)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if self.hasRequestedPopularityUIOpened or not popularityInfo or popularityInfo.IsFirstTriggered then
		return
	end

	self.hasRequestedPopularityUIOpened = true

	gClientToGameDelegate:AskPopularityUIOpened().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			self.hasRequestedPopularityUIOpened = false

			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end
end

M.TryNotifyPopularityPhoneFirstOpened = function(self)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if self.hasRequestedPopularityPhoneFirstOpened or not popularityInfo or popularityInfo.IsFirstPhoneOpened then
		return
	end

	self.hasRequestedPopularityPhoneFirstOpened = true

	gClientToGameDelegate:AskPopularityPhoneFirstOpened().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			self.hasRequestedPopularityPhoneFirstOpened = false

			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end
end

M.IsHomeCountryUnlocked = function(self, countryId)
	local cfg = countryId and CollectionCountryConfig.GetConfig(countryId)

	if not cfg then
		return false
	end

	return gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.PopularityCountryUnlock, "InspireHubUnlockProgress")
end

M.GetCurrentHomeCountryId = function(self)
	local currentCountryCfg = gRaidDataManager and gRaidDataManager.GetCurrentCountry and gRaidDataManager:GetCurrentCountry()
	local currentCountryId = currentCountryCfg and currentCountryCfg.Id

	if currentCountryId and self:IsHomeCountryUnlocked(currentCountryId) then
		return currentCountryId
	end
end

M.GetDefaultHomeCountryId = function(self)
	local currentCountryId = self:GetCurrentHomeCountryId()

	if currentCountryId then
		return currentCountryId
	end

	for index = 0, CollectionCountryConfig.count - 1 do
		local cfg = CollectionCountryConfig.LoadAt(index)

		if cfg and self:IsHomeCountryUnlocked(cfg.Id) then
			return cfg.Id
		end
	end
end

M.GetHomeCountryList = function(self)
	local result = {}

	for index = 0, CollectionCountryConfig.count - 1 do
		local cfg = CollectionCountryConfig.LoadAt(index)

		if cfg then
			table.insert(result, {
				id = cfg.Id,
				name = cfg.Name or "",
				desc = cfg.InspireHubDes or "",
				unlocked = self:IsHomeCountryUnlocked(cfg.Id)
			})
		end
	end

	return result
end

M.IsHomeDynamicDataUnlock = function(self)
	return gSystemUnlockMgr:IsUnlock(HOT_CENTER_DYNAMIC_SYSTEM_UNLOCK_ID)
end

M.CheckInspireHubGamePlayShowUnlock = function(cfg)
	return gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.InspireHubGamePlayShowUnlock, "ShowMaxProgress")
end

M.GetStandaloneGameplayTemplateType = function(self, gameplayTypeCfg)
	if not gameplayTypeCfg then
		return self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_BIG
	end

	return self.GAMEPLAY_TYPE_TO_TEMPLATE_TYPE[gameplayTypeCfg.GamePlayType] or self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_BIG
end

M.GetStandaloneCategoryList = function(self, countryId, includeUnlocked)
	local result = {}
	local count = InspireHubConfig.count

	for i = 0, count - 1 do
		local cfg = InspireHubConfig.LoadAt(i)

		if cfg and cfg.Country ~= countryId then
			local unlocked = gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.InspireHub)

			if includeUnlocked or unlocked then
				local label = unlocked and cfg.Name or cfg.UnlockConditionsDes

				table.insert(result, {
					id = cfg.Id,
					tIndex = cfg.DisplayType - 1,
					unlocked = unlocked,
					label = label,
					Weight = cfg.Weight,
					title = cfg.Name
				})
			end
		end
	end

	table.sort(result, function (a, b)
		if a.Weight == b.Weight then
			return b.Weight <= a.Weight
		end

		return a.tIndex <= b.tIndex
	end)

	return result
end

M.SetHomeDailyRecommendPoolData = function(self, countryId, data)
	if not countryId then
		return
	end

	self.homeDailyRecommendPoolMap[countryId] = self:_DeduplicateHomeDailyRecommendPoolData(data)
end

M.SetHomeRankDisplayData = function(self, countryId, data)
	if not countryId then
		return
	end

	self.homeRankDisplayMap[countryId] = data
end

M._CanShowHomeRecommend = function(self, cfg, countryId)
	return cfg and cfg.Country ~= countryId and cfg.EnableDailyRecommend
end

M._BuildLocalHomeDailyRecommendPoolData = function(self, countryId)
	local result = {}

	for index = 0, InspireHubGamePlayConfig.count - 1 do
		local cfg = InspireHubGamePlayConfig.LoadAt(index)

		if self:_CanShowHomeRecommend(cfg, countryId) then
			table.insert(result, {
				id = cfg.Id,
				weight = cfg.Weight or 0
			})
		end
	end

	self:_SortHomeDailyRecommendPoolData(result)

	return self:_DeduplicateHomeDailyRecommendPoolData(result)
end

M._BuildServerHomeDailyRecommendPoolMap = function(self, data)
	local result = {}
	local countryList = self:GetHomeCountryList()

	for _, countryInfo in ipairs(countryList) do
		result[countryInfo.id] = {}
	end

	local countryDict = data and data.CountryRecommendDataDict or nil

	if countryDict then
		for countryId, recommendData in pairs(countryDict) do
			if result[countryId] then
				local gamePlayList = recommendData and recommendData.GamePlayList or nil
				local count = gamePlayList and (gamePlayList.Count or #gamePlayList) or 0

				for index = 1, count do
					local info = gamePlayList[index]
					local cfg = info and InspireHubGamePlayConfig.GetConfig(info.CfgId)

					if cfg then
						table.insert(result[countryId], {
							id = cfg.Id,
							weight = info.Weight or cfg.Weight or 0
						})
					end
				end
			end
		end
	end

	for countryId, poolData in pairs(result) do
		self:_SortHomeDailyRecommendPoolData(poolData)

		result[countryId] = self:_DeduplicateHomeDailyRecommendPoolData(poolData)
	end

	return result
end

M._SortHomeDailyRecommendPoolData = function(self, poolData)
	table.sort(poolData, function (a, b)
		if a.weight == b.weight then
			return b.weight <= a.weight
		end

		return a.id <= b.id
	end)
end

M._DeduplicateHomeDailyRecommendPoolData = function(self, poolData)
	if not poolData or #poolData < 0 then
		return {}
	end

	local result = {}
	local idSet = {}

	for _, data in ipairs(poolData) do
		local id = data and data.id

		if id and not idSet[id] then
			idSet[id] = true

			table.insert(result, data)
		end
	end

	return result
end

M.GetHomeDailyRecommendPoolData = function(self, countryId)
	if not countryId then
		return {}
	end

	local cachedData = self.homeDailyRecommendPoolMap[countryId]

	if cachedData == nil then
		return cachedData
	end

	return self:_BuildLocalHomeDailyRecommendPoolData(countryId)
end

M._BuildServerHomeRankDisplayMap = function(self, data)
	local countryList = self:GetHomeCountryList()
	local countryCategoryMap = {}

	for _, countryInfo in ipairs(countryList) do
		countryCategoryMap[countryInfo.id] = {
			{},
			{},
			{}
		}
	end

	local countryDict = data and data.CountryRankDataDict or nil

	if countryDict then
		for countryId, rankData in pairs(countryDict) do
			local categoryMap = countryCategoryMap[countryId]

			if categoryMap then
				local rankListDict = rankData and rankData.GamePlayRankListDict or nil

				if rankListDict then
					for rankType, rankListInfo in pairs(rankListDict) do
						local category = rankListInfo and rankListInfo.RankType or rankType

						if category and category > 1 and category < 3 then
							local rankList = rankListInfo and rankListInfo.RankList or nil
							local count = rankList and (rankList.Count or #rankList) or 0

							for index = 1, count do
								local rankInfo = rankList[index]
								local cfg = rankInfo and InspireHubGamePlayConfig.GetConfig(rankInfo.CfgId)

								if cfg then
									table.insert(categoryMap[category], {
										cfg = cfg,
										score = rankInfo.Score or 0,
										baseScore = rankInfo.BaseScore or 0
									})
								end
							end
						end
					end
				end
			end
		end
	end

	local rankDisplayCount = InspireHubConfig.RankDisplayCount or 0
	local result = {}

	for _, countryInfo in ipairs(countryList) do
		local categoryMap = countryCategoryMap[countryInfo.id]
		local columnList = {}

		for category = 1, 3 do
			local list = categoryMap[category] or {}

			table.sort(list, function (a, b)
				if a.score == b.score then
					return b.score <= a.score
				end

				if a.baseScore == b.baseScore then
					return b.baseScore <= a.baseScore
				end

				return a.cfg.Id <= b.cfg.Id
			end)

			local rankList = {}
			local maxCount = rankDisplayCount <= 0 and math.min(rankDisplayCount, #list) or #list

			for rank = 1, maxCount do
				local entry = list[rank]
				rankList[rank] = {
					id = entry.cfg.Id,
					rank = rank,
					rankCategory = category,
					isUp = rank > 10,
					score = entry.score,
					baseScore = entry.baseScore
				}
			end

			columnList[#columnList + 1] = {
				category = category,
				rankList = rankList
			}
		end

		result[countryInfo.id] = columnList
	end

	return result
end

M.NotifyHomeDynamicDataRefresh = function(self, countryId, dataType)
	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_HOME_DYNAMIC_DATA_REFRESH, {
		countryId = countryId,
		dataType = dataType
	})
end

M.ApplyHomeDailyRecommendServerData = function(self, data)
	local poolMap = self:_BuildServerHomeDailyRecommendPoolMap(data)

	for _, countryInfo in ipairs(self:GetHomeCountryList()) do
		self:SetHomeDailyRecommendPoolData(countryInfo.id, poolMap[countryInfo.id] or {})
	end

	self:NotifyHomeDynamicDataRefresh(nil, "recommend")
end

M.ApplyHomeRankServerData = function(self, data)
	local rankMap = self:_BuildServerHomeRankDisplayMap(data)

	for _, countryInfo in ipairs(self:GetHomeCountryList()) do
		self:SetHomeRankDisplayData(countryInfo.id, rankMap[countryInfo.id] or {
			{
				["\\xa8\\xb0\\xaem1\\xec*"] = 1,
				rankList = {}
			},
			{
				["\\xa8\\xb0\\xaem1\\xec*"] = 2,
				rankList = {}
			},
			{
				["\\xa8\\xb0\\xaem1\\xec*"] = 3,
				rankList = {}
			}
		})
	end

	self:NotifyHomeDynamicDataRefresh(nil, "rank")
end

M.RequestHomeDailyRecommendDisplayData = function(self)
	if not self:IsHomeDynamicDataUnlock() then
		return
	end

	gClientToGameDelegate:AskQueryInspireHubAllGamePlayRecommendData().Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		self:ApplyHomeDailyRecommendServerData(data)
	end
end

M.RequestHomeRankDisplayData = function(self)
	if not self:IsHomeDynamicDataUnlock() then
		return
	end

	gClientToGameDelegate:AskQueryInspireHubAllGamePlayRankData().Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		self:ApplyHomeRankServerData(data)
	end
end

M.RequestHomeDynamicDisplayData = function(self)
	if not self:IsHomeDynamicDataUnlock() then
		return false
	end

	self:RequestHomeDailyRecommendDisplayData()
	self:RequestHomeRankDisplayData()

	return true
end

M.GetHomeRankDisplayData = function(self, countryId)
	if not countryId then
		return {}
	end

	return self.homeRankDisplayMap[countryId] or {}
end

M.GetStandaloneGameplayTypes = function(self, inspireHubId)
	local result = {}
	local count = InspireHubGamePlayTypeConfig.count

	for i = 0, count - 1 do
		local cfg = InspireHubGamePlayTypeConfig.LoadAt(i)

		if cfg and cfg.InspireHub ~= inspireHubId then
			table.insert(result, {
				Id = cfg.Id,
				Order = cfg.Order
			})
		end
	end

	if #result <= 1 then
		table.sort(result, function (a, b)
			return b.Order <= a.Order
		end)
	end

	if #result <= 0 then
		return result
	end

	return nil
end

M._CheckStandaloneGameplayCanShow = function(self, cfg, tIndex)
	if tIndex ~= self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_JOB then
		return true
	end

	if not gHotCenterManager.CheckInspireHubGamePlayShowUnlock(cfg) then
		return false
	end

	return true
end

M._EvaluateJobStatus = function(self, cfg, unlocked)
	if not gHotCenterManager.CheckInspireHubGamePlayShowUnlock(cfg) then
		return self.JOB_STATUS.UNDISCOVERED, InspireHubConfig.CareerExplorationPrompt
	end

	if not unlocked then
		return self.JOB_STATUS.LOCKED, cfg.UnlockConditionsDes or ""
	end

	if cfg.NpcCultivationId ~= 1 then
		if not gSpiritManager:CheckIsMainCharacter() then
			local name = gPlayerManager.infoLogin.bindData.name

			return self.JOB_STATUS.WRONG_ROLE, InspireHubConfig.JobRoleSwitchingPrompt:format(name)
		end
	elseif cfg.NpcCultivationId <= 0 then
		local tid = gSpiritManager:GetCurFirstSpiritTid()
		local spirit = LTConfig.FightSpiritConfig.GetConfig(tid)

		if spirit.NpcCultivationRelatedId == cfg.NpcCultivationId then
			local name = LTConfig.NpcCultivationConfig.GetConfig(cfg.NpcCultivationId).Name

			return self.JOB_STATUS.WRONG_ROLE, InspireHubConfig.JobRoleSwitchingPrompt:format(name)
		end
	end

	if gSpiritJobManager:GetAvailableJobByClass(cfg.JobId) ~= nil then
		return self.JOB_STATUS.WRONG_JOB, InspireHubConfig.JobUntakePrompt:format(cfg.Name)
	end

	return self.JOB_STATUS.NORMAL, ""
end

M._GetBattleConfig = function(self, cfg)
	if cfg.BattleCampId <= 0 then
		return LTConfig.BattleCampConfig.GetConfig(cfg.BattleCampId)
	end
end

M._CheckFinished = function(self, battleCfg)
	if not battleCfg then
		return false
	end

	return gPlayerManager.infoAchievement.bindData.CompletedSubQuestCnt[battleCfg.SubQuestId] == nil
end

M._GetDropId = function(self, cfg, battleCfg)
	if battleCfg then
		return battleCfg.DropId
	end

	return cfg.RewardPreviewDrop
end

M._BuildStandaloneGameplayValue = function(self, cfg, tIndex)
	local battleCfg = self:_GetBattleConfig(cfg)
	local unlocked = gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.InspireHubGameplay)
	local jobStatus, tips = nil

	if tIndex ~= self.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_JOB then
		jobStatus, tips = self:_EvaluateJobStatus(cfg, unlocked, tIndex)
	elseif not unlocked then
		tips = cfg.UnlockConditionsDes
	end

	return {
		Id = cfg.Id,
		weight = cfg.Weight,
		tIndex = tIndex,
		finished = self:_CheckFinished(battleCfg),
		unlocked = unlocked,
		jobStatus = jobStatus,
		tips = tips,
		items = self:_GetStandaloneGameplayItems(cfg.ShopID, self:_GetDropId(cfg, battleCfg))
	}
end

M.GetStandaloneGameplayGuideText = function(self, cfg, data)
	if not cfg then
		return ""
	end

	local jobStatus = data and data.jobStatus or nil

	if jobStatus ~= self.JOB_STATUS.WRONG_ROLE then
		return cfg.NavigationHintSwitchChar or data.tips or ""
	end

	if jobStatus ~= self.JOB_STATUS.WRONG_JOB then
		return cfg.NavigationHintNoJob or data.tips or ""
	end

	if jobStatus ~= self.JOB_STATUS.UNDISCOVERED then
		return cfg.NavigationHintLocked or data.tips or ""
	end

	if data and not data.unlocked then
		return cfg.NavigationHintLocked or data.tips or cfg.UnlockConditionsDes or ""
	end

	return cfg.NavigationHint or data and data.tips or ""
end

M.GetStandaloneGameplayDetailData = function(self, data)
	if not data or not data.Id then
		return {
			["~'nX"] = "",
			["Y\\xa7\\xb6\\xa3\\xb3"] = ""
		}
	end

	local cfg = InspireHubGamePlayConfig.GetConfig(data.Id)

	if not cfg then
		return {
			["~'nX"] = "",
			["Y\\xa7\\xb6\\xa3\\xb3"] = ""
		}
	end

	local description = cfg.Description or cfg.ShortDes or ""
	local guideText = self:GetStandaloneGameplayGuideText(cfg, data)

	if not string.is_null_or_empty(guideText) then
		if not string.is_null_or_empty(description) then
			description = string.format("%s\n%s", description, guideText)
		else
			description = guideText
		end
	end

	return {
		title = cfg.Name or "",
		desc = description,
		guideText = guideText
	}
end

M.GetStandaloneGameplayByType = function(self, gameplayTypeId)
	local gamePlayTypeConfig = LTConfig.InspireHubGamePlayTypeConfig.GetConfig(gameplayTypeId)
	local tIndex = gHotCenterManager:GetStandaloneGameplayTemplateType(gamePlayTypeConfig)
	local res = {}
	local hasUndiscovered = false
	local count = InspireHubGamePlayConfig.count

	for i = 0, count - 1 do
		local cfg = InspireHubGamePlayConfig.LoadAt(i)

		if cfg and cfg.GamePlayType ~= gameplayTypeId and self:_CheckStandaloneGameplayCanShow(cfg, tIndex) then
			local value = self:_BuildStandaloneGameplayValue(cfg, tIndex)

			if value.jobStatus ~= self.JOB_STATUS.UNDISCOVERED then
				if not hasUndiscovered then
					hasUndiscovered = true

					table.insert(res, value)
				end
			else
				table.insert(res, value)
			end
		end
	end

	if #res <= 0 then
		local jobNormal = self.JOB_STATUS.NORMAL

		table.sort(res, function (a, b)
			if a.unlocked == b.unlocked then
				return a.unlocked
			end

			local aJob = a.jobStatus or jobNormal
			local bJob = b.jobStatus or jobNormal

			if aJob == bJob then
				return bJob <= aJob
			end

			return b.weight <= a.weight
		end)
	end

	return res
end

M.RenderStandaloneListWidget = function(self, btn, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local gameplayId = data.Id
	local cfg = InspireHubGamePlayConfig.GetConfig(gameplayId)
	local gamePlayTypeConfig = LTConfig.InspireHubGamePlayTypeConfig.GetConfig(cfg.GamePlayType)
	local tIndex = gHotCenterManager:GetStandaloneGameplayTemplateType(gamePlayTypeConfig)
	local desc = cfg.ShortDes or cfg.Description or ""

	if tIndex ~= gHotCenterManager.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_JOB or tIndex ~= gHotCenterManager.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_BIG then
		desc = cfg.Description or cfg.ShortDes or ""
	end

	store.title = cfg.Name or ""
	store.bg = cfg.IconId

	if store.popularityList then
		store.popularityList:SetSimpleList(cfg.HeatGainSpeedStar or 0)
	end

	store.desc = desc
	store.tips = self:GetStandaloneGameplayGuideText(cfg, data)

	if tIndex ~= gHotCenterManager.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_JOB then
		if data.jobStatus ~= self.JOB_STATUS.UNDISCOVERED then
			store.lockDesc = data.tips
			store.lockCtrl = 0
		elseif data.jobStatus ~= self.JOB_STATUS.LOCKED then
			store.lockCtrl = 2
		else
			store.lockCtrl = 1
		end
	else
		store.lockCtrl = data.unlocked and 1 or 0

		if tIndex ~= gHotCenterManager.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_BIG then
			if store.finishCtrl == nil then
				store.finishCtrl = 0
			end

			self:RenderStandaloneAwardList(store.awardList, nil)
		elseif tIndex ~= gHotCenterManager.SUB_PANEL_LIST_TEMPLATE_TYPE.ONLINE_SMALL then
			store.dateCtrl = cfg.SeasonGamePlayId and cfg.SeasonGamePlayId <= 0 and 1 or 0
		end
	end
end

M.RenderStandaloneAwardList = function(self, awardList, items)
	if not awardList then
		return
	end

	if table.isNilOrEmpty(items) then
		awardList:SetSimpleList(0)

		return
	end

	awardList.luaSimpleRenderItem = function(item, index)
		gCommonItemManager:OnCommonItemRender(item, index, items[index + 1])
	end

	awardList:SetSimpleList(#items)
end

M._GetStandaloneGameplayItems = function(self, shopId, dropId)
	if shopId and shopId <= 0 then
		return self:_GetShopItems(shopId)
	end

	if dropId then
		return gCommonItemManager:GetSingleSortedListRenderData({
			{
				dropId = dropId
			}
		})
	end

	return nil
end

M._GetShopItems = function(self, shopId)
	local shopCfg = LTConfig.ShopConfig.GetConfig(shopId)

	if not shopCfg then
		return nil
	end

	local commodityIds = {}

	if shopCfg.CommodityGroupIdList and #shopCfg.CommodityGroupIdList <= 0 then
		for _, groupId in ipairs(shopCfg.CommodityGroupIdList) do
			local groupCfg = LTConfig.ShopCommodityGroupConfig.GetConfig(groupId)

			if groupCfg then
				for _, commodityId in ipairs(groupCfg.CommodityIDList) do
					local item = gShopManager:GenCommodityItem(commodityId)

					if item then
						table.insert(commodityIds, commodityId)
					end
				end
			end
		end
	elseif shopCfg.SellBrands and #shopCfg.SellBrands <= 0 then
		for _, brandId in ipairs(shopCfg.SellBrands) do
			local list = gShopManager.brandMap[brandId]

			if list then
				for _, commodityId in ipairs(list) do
					local item = gShopManager:GenCommodityItem(commodityId)

					if item then
						table.insert(commodityIds, commodityId)
					end
				end
			end
		end
	end

	local dataList = {}

	for _, commodityId in ipairs(commodityIds) do
		local commodityCfg = LTConfig.ShopCommodityConfig.GetConfig(commodityId)
		local consumableCfg = commodityCfg and LTConfig.ConsumableConfig.GetConfig(commodityCfg.ConsumableID)

		if consumableCfg then
			table.insert(dataList, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				iconId = consumableCfg.SItemIconId,
				quality = consumableCfg.Quality,
				displayWeight = commodityCfg.DisplayWeight,
				sortOrder = #dataList,
				itemId = commodityCfg.ConsumableID
			})
		end
	end

	table.sort(dataList, function (a, b)
		if a.displayWeight == b.displayWeight then
			return b.displayWeight <= a.displayWeight
		end

		if a.quality == b.quality then
			return b.quality <= a.quality
		end

		return a.sortOrder <= b.sortOrder
	end)

	for i = 1, #dataList do
		dataList[i] = gCommonItemManager:GetItemRenderData(dataList[i])
	end

	return dataList
end

M.RenderOnlineListWidget = function(btn, gameplayId)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if gameplayId <= 0 then
		local cfg = LinkHubGameplayConfig.GetConfig(gameplayId)
		store.name = cfg and cfg.Name or ""
		store.desc = cfg and cfg.ShortDes or ""
		local tagId = 0

		if cfg.IsSeason then
			tagId = LinkHubConfig.SeasonTag
		elseif cfg.IsHot then
			tagId = LinkHubConfig.HotTag
		end

		if tagId <= 0 then
			store.showBadgeCtrl = 1
			local tagCfg = LinkHubTagConfig.GetConfig(tagId)
			store.badgeText = tagCfg.Name
			store.quality = tagCfg.Quality
		else
			store.showBadgeCtrl = 0
		end

		store.icon = cfg.SmallImage or 0

		if store.popularityList then
			store.popularityList:SetSimpleList(cfg.HeatGainSpeedStar or 0)
		end
	end
end

M.OnGoGameplayHyperLink = function(gameplayId, unlock)
	local cfg = LinkHubGameplayConfig.GetConfig(gameplayId)
	local hyperLinkId = nil

	if cfg then
		if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
			local name = cfg.Name or ""
			local content = string.format(LTConfig.TextConfig.GetConfig(73971400).Text, name)

			gDisplayMessageMgr:ShowMessageContent(content, gDisplayMessageId.SELECT, nil, function ()
				gLinkManager:EnterLink(UX.Game.LinkMode.Public)
			end, nil, LTConfig.TextConfig.GetConfig(73971401).Text, LTConfig.TextCommonTextConfig.GetConfig(74009093).Text)

			return
		end

		hyperLinkId = unlock and cfg.HyperLinkId or cfg.LockedHyperLinkId
	end

	if hyperLinkId and hyperLinkId <= 0 then
		local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

		if hyperLinkInfo and hyperLinkInfo.callback then
			hyperLinkInfo.callback()
		end
	end
end

M.OnGoOnlineHyperLink = function(name, hyperLinkId)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		local content = string.format(LTConfig.TextConfig.GetConfig(73971400).Text, name)

		gDisplayMessageMgr:ShowMessageContent(content, gDisplayMessageId.SELECT, nil, function ()
			gLinkManager:EnterLink(UX.Game.LinkMode.Public)
		end, nil, LTConfig.TextConfig.GetConfig(73971401).Text, LTConfig.TextCommonTextConfig.GetConfig(74009093).Text)

		return
	end

	if hyperLinkId and hyperLinkId <= 0 then
		local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

		if hyperLinkInfo and hyperLinkInfo.callback then
			hyperLinkInfo.callback()
		end
	end
end

M.GetCurrentPublicEventInfo = function(self)
	self:CheckInitPublicEventData()

	for eventId, publicEvent in pairs(self.taskEventToPublicEvent) do
		local info = gTaskManager:GetPublicEventInfo(publicEvent)

		if info and gCS.TimeManager.ServerUnixTime >= info.EndTime then
			return {
				publicEvent = publicEvent,
				eventId = eventId,
				endTime = info.EndTime
			}
		end
	end

	return nil
end

M.CheckInitPublicEventData = function(self)
	if not self.publicEventToTaskEvent then
		local count = PublicEventConfig.count
		self.taskEventToPublicEvent = {}
		self.publicEventToTaskEvent = {}

		for i = 0, count - 1 do
			local config = PublicEventConfig.LoadAt(i)

			if config.EventId and config.EventId <= 0 then
				self.taskEventToPublicEvent[config.EventId] = config.Id
				self.publicEventToTaskEvent[config.Id] = config.EventId
			end
		end
	end
end

M.RefreshPlayerState = function(self)
	self.isPlayerInOnlineGame = false

	if gLinkManager.LinkMode == UX.Game.LinkMode.None then
		gFriendManager:GetSimplePlayerInfo(gPlayerManager.infoBase.bindData.Pid, function (info)
			self.isPlayerInOnlineGame = info.InMatch
		end, true, true)
	end
end

gHotCenterManager = gHotCenterManager or C_HotCenterManager.new()
