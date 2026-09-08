-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterDataPanelStore.lua
-- Decompiled from: 01723_HotCenterDataPanelStore.lua_a25b7568cfe3.luajit

C_HotCenterDataPanelStore = DefClass("C_HotCenterDataPanelStore", C_HotCenterDataPanelStore, C_StoreGroup)
GroupName2Class.HotCenterDataPanelStore = C_HotCenterDataPanelStore
local M = C_HotCenterDataPanelStore

local GetStoreByWidget = function(widget)
	if not widget or not widget.Store or widget.Store ~= "" then
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

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.moneyTierList = {}
	self.todayRewardMap = {}
	self.weeklyPopularityData = {}
	self.todayPopularitySourceList = {}
	self.hasClaimableReward = false
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
	if gHotCenterManager and gHotCenterManager.activePopularityDataPanelStore ~= self then
		gHotCenterManager.activePopularityDataPanelStore = nil
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	gHotCenterManager.activePopularityDataPanelStore = self

	self.RefreshData(self)
end

M.OnClose = function(self)
	if gHotCenterManager.activePopularityDataPanelStore ~= self then
		gHotCenterManager.activePopularityDataPanelStore = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.S_HOT_CENTER_DATA_PANEL)
end

M.RefreshData = function(self)
	self.RefreshMoneyData(self)
	self.RefreshWeeklyData(self)
	self.RefreshLogData(self)
end

M.RefreshMoneyData = function(self)
	local moneyStore = GetStoreByWidget(self.bindData.moneyWidget)

	if not moneyStore then
		return
	end

	self.todayRewardMap = {}
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local dayRewardList = popularityInfo and popularityInfo.DayRewardList

	for i = 1, GetListCount(dayRewardList) do
		local dayReward = dayRewardList[i]

		if IsCurrentLogicDay(dayReward.Time) then
			for j = 1, GetListCount(dayReward.RewardList) do
				local rewardInfo = dayReward.RewardList[j]
				self.todayRewardMap[rewardInfo.Id] = rewardInfo
			end
		end
	end

	self.moneyTierList = {}
	local rewardConfig = LTConfig.GrowthPopularityRewardConfig
	slot5 = 0
	slot6 = rewardConfig.count or 0

	for i = slot5, slot6 - 1 do
		local cfg = rewardConfig.LoadAt(i)

		if cfg then
			local rewardInfo = self.todayRewardMap[cfg.Id]
			local isReward = rewardInfo and rewardInfo.IsReward or false

			table.insert(self.moneyTierList, {
				cfg = cfg,
				rewardInfo = rewardInfo,
				rewardRenderDataList = {
					gCommonItemManager:GetItemRenderData({
						itemId = LTConfig.ConsumableConfig.RewardCoin,
						itemNum = rewardInfo and rewardInfo.CoinCount or cfg.money,
						IsOwned = isReward
					}),
					gCommonItemManager:GetItemRenderData({
						itemId = LTConfig.ConsumableConfig.RewardFan,
						itemNum = rewardInfo and rewardInfo.FanCount or cfg.fan,
						IsOwned = isReward
					})
				}
			})
		end
	end

	table.sort(self.moneyTierList, function (a, b)
		local aLevel = a.cfg.level or 0
		local bLevel = b.cfg.level or 0

		if aLevel ~= bLevel then
			return (a.cfg.Id or 0) <= (b.cfg.Id or 0)
		end

		return aLevel <= bLevel
	end)

	self.hasClaimableReward = false

	for _, tierInfo in ipairs(self.moneyTierList) do
		if tierInfo.rewardInfo and not tierInfo.rewardInfo.IsReward then
			self.hasClaimableReward = true

			break
		end
	end

	local scrollRect = moneyStore.rewardScrollRect

	if not scrollRect then
		return
	end

	scrollRect.luaInitContent = self.CreateAction(self, self.OnMoneyScrollInitContent)

	self.RefreshMoneyScroll(self, scrollRect.content)
end

M.OnMoneyScrollInitContent = function(self, content)
	self.RefreshMoneyScroll(self, content)
end

M.RefreshMoneyScroll = function(self, content)
	local moneyStore = GetStoreByWidget(self.bindData.moneyWidget)
	local scrollContent = content or moneyStore and moneyStore.rewardScrollRect and moneyStore.rewardScrollRect.content
	local scrollStore = GetStoreByWidget(scrollContent)

	if not scrollStore then
		return
	end

	local maxLevel = 0

	if #self.moneyTierList <= 0 then
		maxLevel = self.moneyTierList[#self.moneyTierList].cfg.level or 0
	end

	if scrollStore.progress then
		local todayMaxPopularity = gHotCenterManager:GetTodayMaxPopularity()
		scrollStore.progress.value = maxLevel <= 0 and math.min(math.max(todayMaxPopularity / maxLevel, 0), 1) or 0
	end

	if scrollStore.rewardList then
		scrollStore.rewardList.luaSimpleRenderItem = self:CreateAction(self.OnRenderMoneyTier)

		scrollStore.rewardList:SetSimpleList(#self.moneyTierList)
	end
end

M.OnRenderMoneyTier = function(self, btn, index)
	local tierInfo = self.moneyTierList[index + 1]
	local itemStore = GetStoreByWidget(btn)

	if not tierInfo or not itemStore then
		return
	end

	local canClaim = tierInfo.rewardInfo and not tierInfo.rewardInfo.IsReward
	local claimAction = canClaim and self:CreateAction(self.OnClickClaimBtn) or nil
	btn.interactable = canClaim and true or false
	btn.luaClick = claimAction
	itemStore.levelText = tostring(tierInfo.cfg.level or 0)
	itemStore.achieveCtrl = tierInfo.rewardInfo and 0 or 1

	if itemStore.rewardList then
		local rewardRenderDataList = tierInfo.rewardRenderDataList

		itemStore.rewardList.luaSimpleRenderItem = function(rewardBtn, rewardIndex)
			local renderData = rewardRenderDataList[rewardIndex + 1]

			if renderData then
				gCommonItemManager:OnCommonItemRender(rewardBtn, rewardIndex, renderData)

				rewardBtn.enabledTooltip = not canClaim
				rewardBtn.luaClick = claimAction
			end
		end

		itemStore.rewardList:SetSimpleList(#rewardRenderDataList)
	end
end

M.OnClickClaimBtn = function(self)
	if not self.hasClaimableReward then
		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskTakePopularityReward(0).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end
end

M.RefreshWeeklyData = function(self)
	local weeklyStore = GetStoreByWidget(self.bindData.weeklyWidget)

	if not weeklyStore then
		return
	end

	weeklyStore.contentTypeCtrl = 0
	self.weeklyPopularityData = gHotCenterManager.GetSevenDaysPopularityData()
	local currentTime = gCS.TimeManager.ServerUnixTime
	local dayTime = 86400

	for i = 1, 7 do
		local date = os.date("*t", currentTime - 14400 - dayTime * (7 - i))
		weeklyStore["xAxisLabel" .. tostring(i)] = string.format("%d.%d", date.month, date.day)
	end

	if weeklyStore.popularityList then
		weeklyStore.popularityList.luaSimpleRenderItem = self:CreateAction(self.OnRenderWeeklyPopularity)

		weeklyStore.popularityList:SetSimpleList(#self.weeklyPopularityData)
	end
end

M.OnRenderWeeklyPopularity = function(self, btn, index)
	local info = self.weeklyPopularityData[index + 1]
	local maxPopularity = LTConfig.GameConfig.MaxPopularity or 0

	if not info or maxPopularity < 0 then
		return
	end

	local gradient = btn.GetComponentInChildren(btn, typeof(SGUI.Effect.UGradient))

	if not gradient then
		return
	end

	local scale = math.max(info.popularity or 0, 0) / maxPopularity

	gInspireHubUtils.SetUGradientScaleY(gradient, math.min(scale, 0.999999))
end

M.RefreshLogData = function(self)
	local logStore = GetStoreByWidget(self.bindData.logWidget)

	if not logStore then
		return
	end

	local currentPopularity = gSocialNetworkUtils.GetCurrentPopularityValue()
	logStore.popularity = tostring(currentPopularity)
	logStore.totalPopularity = tostring(currentPopularity)
	logStore.gainSpeedCtrl = gHotCenterManager:GetPopularityGainSpeedCtrl()
	logStore.contentTypeCtrl = 1
	self.todayPopularitySourceList = gHotCenterManager:GetTodayPopularitySourceList()

	if logStore.logList then
		logStore.logList.luaSimpleRenderItem = self:CreateAction(self.OnRenderPopularityLog)

		logStore.logList:SetSimpleList(#self.todayPopularitySourceList)
	end
end

M.OnRenderPopularityLog = function(self, btn, index)
	local info = self.todayPopularitySourceList[index + 1]
	local itemStore = GetStoreByWidget(btn)

	if not info or not itemStore then
		return
	end

	itemStore.title = gHotCenterManager:GetPopularitySourceTitle(info.DropId)
	itemStore.value = string.format("%+d", info.Popularity or 0)
end
