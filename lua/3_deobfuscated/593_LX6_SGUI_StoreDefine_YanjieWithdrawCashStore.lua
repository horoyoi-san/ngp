C_YanjieWithdrawCashStore = DefClass("C_YanjieWithdrawCashStore", C_YanjieWithdrawCashStore, C_StoreGroup)
GroupName2Class.YanjieWithdrawCashStore = C_YanjieWithdrawCashStore
local M = C_YanjieWithdrawCashStore

function M:OnAwake()
	self.bindData.cancelButton.luaClick = self:CreateAction("OnCancelClick")
	self.bindData.confirmButton.luaClick = self:CreateAction("OnConfirmClick")
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(_)
	self.targetCount = 0

	gCommonItemManager:CloseItemToolTips()
end

function M:InitView(_)
	local eyeCoinConsumableId = LTConfig.TuiteConfig.EyeCoinConsumableId
	local eyeCoinConsumableCfg = LTConfig.ConsumableConfig.GetConfig(eyeCoinConsumableId)
	self.bindData.eyeCoin = eyeCoinConsumableCfg.Name
	self.bindData.eyeCoinIconId = eyeCoinConsumableCfg.SItemIconId
	local rewardCoinConsumableId = LTConfig.ConsumableConfig.RewardMoney
	local rewardCoinConsumableCfg = LTConfig.ConsumableConfig.GetConfig(rewardCoinConsumableId)
	self.bindData.rewardCoin = rewardCoinConsumableCfg.Name
	self.bindData.rewardCoinIconId = rewardCoinConsumableCfg.SItemIconId

	self:RefreshPanelView()
end

function M:RefreshPanelView()
	self.targetCount = 0
	local totalLeftMoney = gSocialNetworkUtils.GetTotalLeftMoney()
	local canRewardPopularity = totalLeftMoney
	self.bindData.totalPopularity = totalLeftMoney
	local counterStore = self.SubGroup.CommonCounterStore

	counterStore:SetData({
		valChangeCallback = function (value)
			self.targetCount = value
			self.bindData.confirmButton.interactable = self.targetCount > 0
			self.bindData.popularity = value
		end,
		range = {
			0,
			canRewardPopularity
		},
		targetValue = canRewardPopularity
	})
end

function M:AskTakePopularityReward()
	if self.targetCount == 0 then
		return
	end

	local rootGo = self.rootGo

	gClientToGameDelegate:AskTakePopularityReward(self.targetCount).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
		popularityInfo.TotalLeftMoney = popularityInfo.TotalLeftMoney - self.targetCount

		gMessageManager:SendMessage(gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE)

		if gClientUtils.NotNil(rootGo) then
			self:RefreshPanelView()
		end
	end
end

function M:OnCancelClick()
	gPanelManager:Close(self.m_Id)
end

function M:OnConfirmClick()
	self:AskTakePopularityReward()
end
