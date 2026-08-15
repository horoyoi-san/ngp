local TaskTitleConfig = LTConfig.TaskTitleConfig
C_BigMapTooltip_Task = DefClass("C_BigMapTooltip_Task", C_BigMapTooltip_Task, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Task
local SHOW_REWARD = 0
local HIDE_REWARD = 1
local SHOW_TIME_LIMIT = 1
local HIDE_TIME_LIMIT = 0

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("taskInfo") then
		return
	end

	self:GetStore("MapTaskTooltipStore")

	local info = self.tooltipInfo.taskInfo

	self:SetUpHeader(self.store)
	self:SetUpLocation()
	self:SetUpSpecificSpirits(info)
	self:SetUpTitleIcon()

	local scrollStore = nil

	if info.specificSpirits and #info.specificSpirits > 0 then
		scrollStore = gStoreManager:GetStoreGroup("MapTaskScrollStore"):GetStoreByWidget(self.store.spiritScroll.content)
	else
		scrollStore = gStoreManager:GetStoreGroup("MapTaskScrollStore"):GetStoreByWidget(self.store.normalScroll.content)
	end

	if info.hideDropInfo or not info.simpleDropIds or #info.simpleDropIds == 0 then
		scrollStore.showReward = HIDE_REWARD
	else
		scrollStore.showReward = SHOW_REWARD

		self:SetUpDropsWithIds(info.simpleDropIds, scrollStore.rewardList)
	end

	scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)

	if info.timeLimitText then
		self.store.timeLimit = SHOW_TIME_LIMIT
		self.store.timeLimitText = info.timeLimitText
	else
		self.store.timeLimit = HIDE_TIME_LIMIT
		self.store.timeLimitText = ""
	end

	self.store.linkCharacter = 1

	if info.linkSpecificAgentId then
		local agentCfg = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(info.linkSpecificAgentId)

		if agentCfg then
			local profileId = agentCfg.ProfileId
			local profileCfg = LTConfig.ProfileAgentProfileConfig.GetConfig(profileId)

			if profileCfg then
				self.store.linkCharacter = 0
				self.store.headIconId = profileCfg.HeadIcon
				self.store.characterCanJoin = profileCfg.CanJoin and 0 or 1
			end
		end
	end

	self:SetUpDesc(scrollStore, info.desc)
end

function M:SetUpTitleIcon()
	local title = self.tooltipInfo.taskInfo.title

	if title then
		self.store.taskIconId = TaskTitleConfig.GetConfig(title).SQuestIcon
	end
end

function M:SetUpDesc(scrollStore, desc)
	scrollStore.desc = desc or ""
end

local SHOW_YANJIE = 1
local HIDE_YANJIE = 0

function M:SetUpActions(store, actions, blockReason)
	if not actions or #actions == 0 then
		store.showMainBtn = self.HIDE_BTN
		store.showYanjie = HIDE_YANJIE

		return
	end

	if blockReason then
		store.showMainBtn = self.SHOW_BTN
		store.mainBtnText = blockReason
		store.mainBtnInteractable = false
		store.showYanjie = HIDE_YANJIE

		return
	end

	store.showMainBtn = self.SHOW_BTN
	store.mainBtnInteractable = true
	store.clickMain = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[1], self)
	store.mainBtnText = gMapUIUtils.GetElementActionName(actions[1])

	if actions[2] == gMapSystemElementAction.Yanjie then
		store.showYanjie = SHOW_YANJIE
		store.clickYanjie = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[2], self)
	else
		store.showYanjie = HIDE_YANJIE
	end
end

function M:OnClickShowReward()
	local info = self.tooltipInfo.taskInfo

	self:ShowGamePadItemPanelWithIds(info.simpleDropIds)
end
