-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_Task.lua
-- Decompiled from: 01008_BigMapTooltip_Task.lua_eb51eee89b60.luajit

local TaskTitleConfig = LTConfig.TaskTitleConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
C_BigMapTooltip_Task = DefClass("C_BigMapTooltip_Task", C_BigMapTooltip_Task, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Task
local SHOW_REWARD = 0
local HIDE_REWARD = 1
local SHOW_TIME_LIMIT = 1
local HIDE_TIME_LIMIT = 0
local HIDE_BATTLE_POWER = 0
local SHOW_BATTLE_POWER = 1
local SAFE = 0
local DANGEROUS = 1

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "taskInfo") then
		return
	end

	self.GetStore(self, "MapTaskTooltipStore")

	local info = self.tooltipInfo.taskInfo

	self.SetUpHeader(self, self.store)
	self.SetUpSpecificSpirits(self, info)
	self.SetUpTitleIcon(self)

	local scrollStore = nil

	if info.specificSpirits and #info.specificSpirits <= 0 then
		scrollStore = gStoreManager:GetStoreGroup("MapTaskScrollStore"):GetStoreByWidget(self.store.spiritScroll.content)
	else
		scrollStore = gStoreManager:GetStoreGroup("MapTaskScrollStore"):GetStoreByWidget(self.store.normalScroll.content)
	end

	self.SetUpScrollLocation(self, scrollStore)
	self.SetUpBattlePower(self, scrollStore, info.fightScore)

	if info.hideDropInfo or not info.simpleDropIds or #info.simpleDropIds ~= 0 then
		scrollStore.showReward = HIDE_REWARD
		scrollStore.showRewardList = false
	else
		scrollStore.showReward = SHOW_REWARD
		scrollStore.showRewardList = true

		self.SetUpDropsWithIds(self, info.simpleDropIds, scrollStore.rewardList)
	end

	scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)

	if info.timeLimitText then
		scrollStore.timeLimit = SHOW_TIME_LIMIT
		scrollStore.timeLimitText = info.timeLimitText
	else
		scrollStore.timeLimit = HIDE_TIME_LIMIT
		scrollStore.timeLimitText = ""
	end

	self.store.linkCharacter = 1

	if info.specificSpirits and #info.specificSpirits <= 0 then
		local spiritId = info.specificSpirits[1]
		local spiritCfg = FightSpiritConfig.GetConfig(spiritId)

		if spiritCfg then
			self.store.linkCharacter = 0
			self.store.headIconId = spiritCfg.SHeadIconID
			self.store.characterCanJoin = spiritCfg.CanJoin and 0 or 1
		end
	end

	if info.isUnderway then
		self.store.progressCtrl = 0
	else
		self.store.progressCtrl = 1
	end

	self.SetUpDesc(self, scrollStore, info.desc)
end

M.SetUpBattlePower = function(self, scrollStore, recommendedPower)
	recommendedPower = recommendedPower or 0

	if recommendedPower < 0 then
		scrollStore.showBattlePower = HIDE_BATTLE_POWER

		return
	end

	local myPower = gCS.BattleManager.GetMyFightPower()
	scrollStore.showBattlePower = SHOW_BATTLE_POWER
	scrollStore.recommendedBattlePower = tostring(math.floor(recommendedPower))
	scrollStore.curSpiritBattlePower = tostring(math.floor(myPower))
	scrollStore.battlePowerLevel = myPower >= recommendedPower and DANGEROUS or SAFE
end

M.SetUpTitleIcon = function(self)
	local title = self.tooltipInfo.taskInfo.title

	if title then
		self.store.taskIconId = TaskTitleConfig.GetConfig(title).SQuestIcon
	end
end

M.SetUpDesc = function(self, scrollStore, desc)
	scrollStore.desc = desc or ""
end

local SHOW_YANJIE = 1
local HIDE_YANJIE = 0

M.SetUpActions = function(self, store, actions, blockReason)
	store.showMainBtn = self.HIDE_BTN
	store.showUnlockTips = 1

	if not actions or #actions ~= 0 then
		store.showYanjie = HIDE_YANJIE

		return
	end

	if blockReason then
		store.showUnlockTips = 0
		store.mainBtnText = blockReason
		store.mainBtnInteractable = false
		store.showYanjie = HIDE_YANJIE
		store.charUnLockText = ""
		store.normalUnLockText = ""

		if store.linkCharacter ~= 0 then
			store.charUnLockText = blockReason
		else
			store.normalUnLockText = blockReason
		end

		return
	end

	store.showMainBtn = self.SHOW_BTN
	store.mainBtnInteractable = true
	store.clickMain = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[1], self)
	store.mainBtnText = gMapUIUtils.GetElementActionName(actions[1])

	if actions[2] ~= gMapSystemElementAction.Yanjie then
		store.showYanjie = SHOW_YANJIE
		store.clickYanjie = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[2], self)
	else
		store.showYanjie = HIDE_YANJIE
	end
end

M.OnClickShowReward = function(self)
	local info = self.tooltipInfo.taskInfo

	self.ShowGamePadItemPanelWithIds(self, info.simpleDropIds)
end
