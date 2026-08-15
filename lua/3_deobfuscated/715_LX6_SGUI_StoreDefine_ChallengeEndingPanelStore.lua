C_ChallengeEndingPanelStore = DefClass("C_ChallengeEndingPanelStore", C_ChallengeEndingPanelStore, C_StoreGroup)
GroupName2Class.ChallengeEndingPanelStore = C_ChallengeEndingPanelStore
local M = C_ChallengeEndingPanelStore
local CHECK_SERVER = {
	Time = 1,
	TaskCounter = 0
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.taskId = -1
end

function M:OnGroupEnable()
	gMainPhoneUtils.SetSGUIGlobalBarVisible(false)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_SHOW)
end

function M:OnGroupDisable()
	gMainPhoneUtils.SetSGUIGlobalBarVisible(true)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_HIDE)
end

function M:OnAwake()
	self.bindData.retryButton.luaClick = self:CreateAction("OnRetryButtonClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitButtonClick")
	self.bindData.rankBtn.luaClick = self:CreateActionWithArgs("OpenFinalRankPanel", false, gChallengeManager)
	self.challengeCfgData = {}
end

function M:OnShow(panelId, data)
	if not gChallengeManager.preTaskId or gChallengeManager.preTaskId == -1 then
		print_error("[ChallengeEndingPanelStore]挑战任务结束面板显示失败，当前没有挑战任务")
		self:OnExitButtonClick()

		return
	end

	self.bindData.showRank = BOOL2CTL[data.showRank or false]
	self.bindData.job = gChallengeManager:GetChallengeJobType(gChallengeManager.preTaskId)
	self.taskId = gChallengeManager.preTaskId
	local challengeCfgData = gChallengeManager:GetChallengeConfigByTaskId(self.taskId)

	if challengeCfgData == nil then
		print_error("刷新页面失败，没有找到对应的挑战任务数据 , taskId = " .. self.taskId)

		return
	end

	gChallengeManager:AskFinishNewChallenge(challengeCfgData.Id, function (challengeResult)
		self:RefreshPanelInfo(challengeResult)
	end)
end

function M:OnClose()
	return
end

function M:OnRetryButtonClick()
	gTaskManager:SetCurrentTask(self.taskId, function ()
		self:OnExitButtonClick()
	end)
end

function M:OnExitButtonClick()
	gPanelManager:Close(gPanelId.S_CHALLENGE_ENDING_PANEL)
end

function M:RefreshPanelInfo(challengeResult)
	self.challengeCfgData = gChallengeManager:GetChallengeConfigByTaskId(self.taskId)

	if self.challengeCfgData == nil then
		print_error("刷新页面失败，没有找到对应的挑战任务数据 , taskId = " .. self.taskId)

		return
	end

	local _, _, counterResult = gChallengeManager:GetChallengeData()
	local goalNum = 0

	for i = 1, 3 do
		if self:RefreshGoal(i, counterResult[i] or false) then
			goalNum = goalNum + 1
		end
	end

	self.bindData.goalNum = goalNum
	local mdalCtrl = challengeResult.CurrentRewardLevel

	Timer.New(function ()
		self.bindData:Commit("medalCtrl", mdalCtrl, COMMIT_IMMEDIATELY)
	end, 3):Start()
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
