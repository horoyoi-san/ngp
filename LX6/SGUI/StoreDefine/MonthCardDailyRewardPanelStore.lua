-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MonthCardDailyRewardPanelStore.lua
-- Decompiled from: 01053_MonthCardDailyRewardPanelStore.lua_e95c5b25b1a3.luajit

local TextConfig = LTConfig.TextConfig
local MallMonthlyPassConfig = LTConfig.MallMonthlyPassConfig
C_MonthCardDailyRewardPanelStore = DefClass("C_MonthCardDailyRewardPanelStore", C_MonthCardDailyRewardPanelStore, C_StoreGroup)
GroupName2Class.MonthCardDailyRewardPanelStore = C_MonthCardDailyRewardPanelStore
local M = C_MonthCardDailyRewardPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local delayCreateItemTime = 0.12
local delayAnimationPlayTime = 0.8

M.ctor = function(self)
	self.rewardInfo = nil
	self.rewardListData = {}
	self.rewardItems = {}
	self.monthlyPassId = 1
	self.chargeId = 1
	self.currentItemCount = 0
	self.currentList = {}
	self.rewardCreateTimer = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showBuyBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showBuyBtnCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.dicHasPlayAnimation = {}
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.rewardInfo = data

	self.RefreshUI(self)

	self.dicHasPlayAnimation = {}

	if #self.rewardListData ~= 0 then
		return
	end

	self.currentItemCount = 1
	self.currentList = self.bindData.rewardList

	self.currentList:SetSimpleList(self.currentItemCount)

	if #self.rewardListData <= 1 then
		self.rewardCreateTimer = Timer.New(function ()
			self.currentItemCount = self.currentItemCount + 1

			self.currentList:SetSimpleList(self.currentItemCount)
		end, delayCreateItemTime, #self.rewardListData - 1)

		self.rewardCreateTimer:Start()
	end

	self.currentList:SetNavSelectToTop()
end

M.OnClose = function(self)
	if self.rewardCreateTimer then
		self.rewardCreateTimer:Stop()

		self.rewardCreateTimer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRewardListItem")
	self.bindData.rewardList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickRewardList")
	self.bindData.buyBtn.luaClick = self.CreateAction(self, self.OnClickBuyBtn)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.MONTH_CARD_DAILY_REWARD_PANEL)
end

M.OnSimpleRenderRewardListItem = function(self, btn, index)
	if self.dicHasPlayAnimation[index] ~= true then
		return
	end

	self.dicHasPlayAnimation[index] = true
	local itemData = self.rewardListData[index + 1]

	if not itemData then
		return
	end

	local store = gCommonItemManager:OnCommonItemRender(btn, index, itemData)
	local DEFAULT_ANIMATION = "S_Vx_CommonItem156_open"

	if itemData.quality > 5 then
		DEFAULT_ANIMATION = "S_Vx_CommonItem156_open_Golden"
	end

	btn.visibility = SGUI.EVisibility.Hidden

	if store.animation then
		gLuaTimeMgrUtils.Delay(function ()
			if store and btn then
				btn.visibility = SGUI.EVisibility.Visible

				if store.animation then
					store.animation:Play(DEFAULT_ANIMATION)
				end
			end
		end, delayAnimationPlayTime)
	end
end

M.OnSimpleClickRewardList = function(self, btn, index)
end

M.RefreshUI = function(self)
	if not self.rewardInfo then
		return
	end

	self.UpdateRemainText(self)

	if self.rewardInfo.DailyRewardInfo then
		local textCfg = TextConfig.GetConfig(73970806)

		self:ParseAndShowReward(textCfg.Text)

		slot2 = gClientToGameDelegate

		slot2:AskMonthlyPassDoDailyRewardPopUp(self.monthlyPassId).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				local mallInfo = gPlayerManager.infoMinor.bindData.MallInfo
				local monthlyPassInfo = mallInfo.PlayerMonthlyPassInfo.MonthlyPassInfos[self.monthlyPassId]

				if monthlyPassInfo then
					monthlyPassInfo.IsAutoPopup = true
				end
			end
		end
	elseif self.rewardInfo.dropId then
		local textCfg = TextConfig.GetConfig(73970806)

		self:ParseAndShowReward(textCfg.Text)

		slot2 = gClientToGameDelegate

		slot2:AskMonthlyPassDoDailyRewardPopUp(self.monthlyPassId).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				local mallInfo = gPlayerManager.infoMinor.bindData.MallInfo
				local monthlyPassInfo = mallInfo.PlayerMonthlyPassInfo.MonthlyPassInfos[self.monthlyPassId]

				if monthlyPassInfo then
					monthlyPassInfo.IsAutoPopup = true
				end
			end
		end
	end
end

M.UpdateRemainText = function(self)
	local playerMonthCardData = self.GetPlayerMonthCardData(self)

	if not playerMonthCardData or not playerMonthCardData.ExpiredTime then
		return
	end

	local days = self:RemainDays()
	local currentState = gMallManager:GetMonthCardState(self.monthlyPassId)

	if currentState ~= 1 then
		local monthlyPassCfg = MallMonthlyPassConfig.GetConfig(self.monthlyPassId)
		local warnDuration = monthlyPassCfg and monthlyPassCfg.RemainWarnDuration or 0
		local textId = days < warnDuration and 73970814 or 73970802
		local textCfg = TextConfig.GetConfig(textId)

		if textCfg then
			self.bindData.remainText = string.format(textCfg.Text, days)
		end

		self.bindData.showBuyBtnCtrl = BOOL2CTL[days < warnDuration and gMallManager:CanBuyMonthCard(self.monthlyPassId)]
	elseif currentState ~= 2 then
		local textCfg = TextConfig.GetConfig(73970813)
		self.bindData.remainText = textCfg.Text
	end
end

M.GetPlayerMonthCardData = function(self)
	return gMallManager:GetPlayerMonthCardData(self.monthlyPassId)
end

M.RemainDays = function(self)
	return gMallManager:GetMonthCardRemainDays(self.monthlyPassId)
end

M.ParseAndShowReward = function(self, title)
	local allRenderData = {}
	self.rewardItems = {}

	if self.rewardInfo and self.rewardInfo.DailyRewardInfo then
		local popupParam = gItemUtils:ConvertRewardDetail(self.rewardInfo.DailyRewardInfo)

		for _, item in ipairs(popupParam.Rewards) do
			local itemId = item.Id or item.ItemId
			local itemNum = item.Count
			local renderData = gCommonItemManager:GetItemRenderData({
				itemId = itemId,
				itemNum = itemNum
			})

			table.insert(allRenderData, renderData)
			table.insert(self.rewardItems, {
				ItemId = itemId,
				Count = itemNum
			})
		end
	elseif self.rewardInfo and self.rewardInfo.dropId then
		local fakeItems = gCommonItemManager:ConvertDropToFakeItem(self.rewardInfo.dropId, 1)

		if fakeItems then
			for _, item in ipairs(fakeItems) do
				local itemId = item.Id
				local itemNum = item.Count
				local renderData = gCommonItemManager:GetItemRenderData({
					itemId = itemId,
					itemNum = itemNum
				})

				table.insert(allRenderData, 1, renderData)
				table.insert(self.rewardItems, {
					ItemId = itemId,
					Count = itemNum
				})
			end
		end
	end

	self.rewardListData = allRenderData
	self.bindData.titleText = title
end

M.OnClickBuyBtn = function(self)
	if gMallManager:IsMonthCardBuyRequesting() then
		return
	end

	if not gMallManager:CanBuyMonthCard(self.monthlyPassId) then
		return
	end

	gMallManager:LockMonthCardBuy()
	gMallManager:CheckOrder(self.chargeId, 1, "")
end
