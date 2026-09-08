-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieWithdrawCashStore.lua
-- Decompiled from: 01257_YanjieWithdrawCashStore.lua_255628feecc1.luajit

C_YanjieWithdrawCashStore = DefClass("C_YanjieWithdrawCashStore", C_YanjieWithdrawCashStore, C_StoreGroup)
GroupName2Class.YanjieWithdrawCashStore = C_YanjieWithdrawCashStore
local M = C_YanjieWithdrawCashStore

M.OnAwake = function(self)
	self.bindData.cancelButton.luaClick = self.CreateAction(self, "OnCancelClick")
	self.bindData.confirmButton.luaClick = self.CreateAction(self, "OnConfirmClick")
end

M.OnGroupEnable = function(self)
	self.msgEvents = {
		[gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE] = self.CreateAction(self, "RefreshPanelView")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, _)
	self.targetCount = 0

	gCommonItemManager:CloseItemToolTips()
end

M.InitView = function(self, _)
	local eyeCoinConsumableId = LTConfig.TuiteConfig.EyeCoinConsumableId
	local eyeCoinConsumableCfg = LTConfig.ConsumableConfig.GetConfig(eyeCoinConsumableId)
	self.bindData.eyeCoin = eyeCoinConsumableCfg.Name
	self.bindData.eyeCoinIconId = eyeCoinConsumableCfg.SItemIconId
	local rewardCoinConsumableId = LTConfig.ConsumableConfig.RewardMoney
	local rewardCoinConsumableCfg = LTConfig.ConsumableConfig.GetConfig(rewardCoinConsumableId)
	self.bindData.rewardCoin = rewardCoinConsumableCfg.Name
	self.bindData.rewardCoinIconId = rewardCoinConsumableCfg.SItemIconId

	self.RefreshPanelView(self)
end

M.RefreshPanelView = function(self)
	self.targetCount = 0
	local totalLeftMoney = gSocialNetworkUtils.GetTotalLeftMoney()
	local canRewardPopularity = totalLeftMoney
	self.bindData.totalPopularity = totalLeftMoney
	local counterStore = self.SubGroup.CommonCounterStore

	counterStore.SetData(counterStore, {
		valChangeCallback = function (value)
			self.targetCount = value
			self.bindData.confirmButton.interactable = self.targetCount >= 0
			self.bindData.popularity = value
		end,
		range = {
			canRewardPopularity,
			canRewardPopularity
		},
		targetValue = canRewardPopularity
	})
end

M.AskTakePopularityReward = function(self)
	if self.targetCount ~= 0 then
		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskTakePopularityReward(0).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end
end

M.OnCancelClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnConfirmClick = function(self)
	self.AskTakePopularityReward(self)
end
