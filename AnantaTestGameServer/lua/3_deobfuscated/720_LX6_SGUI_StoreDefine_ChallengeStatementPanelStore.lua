C_ChallengeStatementPanelStore = DefClass("C_ChallengeStatementPanelStore", C_ChallengeStatementPanelStore, C_StoreGroup)
GroupName2Class.ChallengeStatementPanelStore = C_ChallengeStatementPanelStore
local M = C_ChallengeStatementPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local MAX_GOAL = 3

function M:ctor()
	self.mgr = gChallengeManager
end

function M:OnAwake()
	self.openAniName = "S_Vx_ChallengeStatementPanel_open"
	self.closeAniName = "S_Vx_ChallengeStatementPanel_close"
	self.taskId = -1
	self.bindData.awardList.luaSimpleRenderItem = self:CreateAction(self.OnCommmonItemRender)
	self.bindData.startChallengeButton.luaClick = self:CreateAction("OnStartChallengeButtonClick")
	self.bindData.BGCloseBtn.luaClick = self:CreateAction("OnBGCloseBtnClick")
	self.bindData.awardBtn.luaClick = self:CreateActionWithArgs("OnCommonItemClick", self.bindData.awardList, gCommonItemManager)
	self.awardList = {}
end

function M:OnCommmonItemRender(btn, index)
	local award = self.awardList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, award)
end

function M:OnShow(panelId, data)
	if data.taskId then
		self.taskId = tonumber(data.taskId)

		self:RefreshChallengeInfoShown(self.taskId)
	else
		print_error("ChallengeStatement页面未传入taskId！")
	end
end

function M:OnClose()
	self.taskId = nil
end

function M:OnGroupEnable()
	gMainPhoneUtils.SetSGUIGlobalBarVisible(false)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_SHOW)
end

function M:OnGroupDisable()
	gMainPhoneUtils.SetSGUIGlobalBarVisible(true)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_HIDE)
end

function M:OnStartChallengeButtonClick()
	if self.taskId then
		gTaskManager:SetCurrentTask(self.taskId, self:CreateAction("OnBGCloseBtnClick"))
	else
		print_error("taskId 为空")
		self:OnBGCloseBtnClick()
	end
end

function M:OnBGCloseBtnClick()
	gUIUtils:PlayAniClosePanel(self.bindData.openAndCloseAnimation, self.closeAniName, gPanelId.S_CHALLENGE_STATEMENT_PANEL)
end

function M:RefreshChallengeInfoShown(challengeTaskId)
	self.challengeCfgData = self.mgr:GetChallengeConfigByTaskId(challengeTaskId)

	if not self.challengeCfgData then
		print_error("ChallengeStatement页面-找不到任务对应的挑战ID！ taskId=", challengeTaskId)

		return
	end

	self.bindData.job = self.mgr:GetChallengeJobType(self.taskId)
	self.bindData.challengeNameText = self.challengeCfgData.Name

	self.mgr:AskNewChallengeRecord(self.challengeCfgData.Id, function (challengeRecord)
		local goalNum = 0

		for i = 1, MAX_GOAL do
			if self:RefreshGoal(i, challengeRecord.ParamData[i - 1] or false) then
				goalNum = goalNum + 1
			end
		end

		self.bindData.goalNum = goalNum
		self.bindData.medalCtrl = challengeRecord.HighestLevel
		local drops = {}

		for i = 1, #self.challengeCfgData.RewardList do
			local reward = self.challengeCfgData.RewardList[i]

			if challengeRecord.ReceivedRewardLevel < reward.level then
				table.insert(drops, {
					isFirstKill = false,
					count = 0,
					dropId = reward.dropId
				})
			end
		end

		if self.challengeCfgData.RepeatReward ~= 0 then
			table.insert(drops, {
				isFirstKill = false,
				count = 0,
				dropId = self.challengeCfgData.RepeatReward
			})
		end

		self.awardList = gCommonItemManager:GetItemSortedListByDropList(drops, true)
		self.bindData.hasAward = #self.awardList > 0 and 0 or 1

		for i = 1, #self.awardList do
			self.awardList[i] = gCommonItemManager:GetItemRenderData({
				itemId = self.awardList[i].Id
			})
			self.awardList[i].quality = C_CommonItemManager.HIDE_QUALITY
		end

		self.bindData.awardList:SetSimpleList(#self.awardList)
	end)
end

function M:RefreshGoal(index, isCheck)
	if string.is_null_or_empty(self.challengeCfgData.CountersDescription[index]) then
		return false
	end

	local btn = self.bindData["goal" .. index]

	if not btn then
		return false
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return false
	end

	store.isCheck = BOOL2CTL[isCheck]
	store.checkText = self.challengeCfgData.CountersDescription[index]

	return true
end
