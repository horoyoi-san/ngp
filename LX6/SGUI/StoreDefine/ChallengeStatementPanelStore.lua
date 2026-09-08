-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChallengeStatementPanelStore.lua
-- Decompiled from: 01452_ChallengeStatementPanelStore.lua_f057d5bfb8ec.luajit

local ChallengeType = LTConfig.ChallengeConfig.ChallengeTypeType
local ChallengeConfig = LTConfig.ChallengeConfig
C_ChallengeStatementPanelStore = DefClass("C_ChallengeStatementPanelStore", C_ChallengeStatementPanelStore, C_StoreGroup)
GroupName2Class.ChallengeStatementPanelStore = C_ChallengeStatementPanelStore
local M = C_ChallengeStatementPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local MAX_GOAL = 3
local DESC_TEMPLATE = {
	[".m\\xa6\\xaf\\xb1e"] = 4,
	["y\\x87\\x96\\x83\\x93"] = 0,
	["gb_Jq9#3"] = 2,
	["pb\\H|?%=\n"] = 3,
	["]\r\\w"] = 5,
	["^Nx"] = 1
}

M.ctor = function(self)
	self.mgr = gChallengeManager
end

M.OnAwake = function(self)
	self.openAniName = "S_Vx_ChallengeStatementPanel_open"
	self.closeAniName = "S_Vx_ChallengeStatementPanel_close"
	self.taskId = -1
	self.bindData.descList.onGetTIndex = self.CreateAction(self, self.OnGetDescIndex)
	self.bindData.descList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderDescListItem)
	self.bindData.descList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleDynRenderDescListItem)
	self.bindData.startChallengeButton.luaClick = self.CreateAction(self, "OnStartChallengeButtonClick")
	self.bindData.BGCloseBtn.luaClick = self.CreateAction(self, "OnBGCloseBtnClick")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnBGCloseBtnClick")
	self.contentList = {}
	self.rewardListData = {}
end

M.OnGetDescIndex = function(self, index)
	local data = self.contentList[index + 1]

	if not data then
		return 0
	end

	return data.tIndex
end

M.OnSimpleRenderDescListItem = function(self, btn, index)
	local data = self.contentList[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= DESC_TEMPLATE.TITLE or data.tIndex ~= DESC_TEMPLATE.DESC then
		self.bindData.descList:SetItemLabel(index, data.text)
	elseif data.tIndex ~= DESC_TEMPLATE.GOAL then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if store then
			store.isCheck = BOOL2CTL[data.isCheck]
			store.checkText = data.text
		end
	elseif data.tIndex ~= DESC_TEMPLATE.REWARD then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if store then
			store.list.luaSimpleRenderItem = self:CreateAction(self.OnRewardItemRender)

			store.list:SetSimpleList(#self.rewardListData)
		end
	end
end

M.OnSimpleDynRenderDescListItem = function(self, btn, index)
	local data = self.contentList[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= DESC_TEMPLATE.TITLE or data.tIndex ~= DESC_TEMPLATE.DESC then
		self.bindData.descList:SetItemLabel(index, data.text)
	end
end

M.OnRewardItemRender = function(self, btn, index)
	local award = self.rewardListData[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, award)
end

M.OnShow = function(self, panelId, data)
	if data and data.taskId then
		self.taskId = tonumber(data.taskId)
		self.isSubmit = data.isSubmit

		self.RefreshChallengeInfoShown(self, self.taskId)
	else
		print_warn("ChallengeStatement页面未传入taskId！")
	end
end

M.OnClose = function(self)
	self.taskId = nil
	self.isSubmit = nil
end

M.OnGroupDisable = function(self)
	gUIUtils:SetShowJoystick(false, self.rootGo)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", false)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", false)
	L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gBanId.COMMON_HALF, false)
end

M.OnGroupEnable = function(self)
	gUIUtils:SetShowJoystick(true, self.rootGo)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", true)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", true)
	L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gBanId.COMMON_HALF, true)
end

M.OnStartChallengeButtonClick = function(self)
	if self.taskId then
		if self.isSubmit then
			gTaskManager:ToSubmitTask(self.taskId)
			self:OnBGCloseBtnClick()
		else
			if self.challengeCfgData and self.challengeCfgData.ChallengeType ~= ChallengeType.Racing then
				gRacerManager:TrySetCompetitionVehicle(self:GetTrackIdByTaskId(self.taskId))
			end

			gTaskManager:SetCurrentTask(self.taskId, self:CreateAction("OnBGCloseBtnClick"))
		end
	else
		print_error("taskId 为空")
		self.OnBGCloseBtnClick(self)
	end
end

M.OnBGCloseBtnClick = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.openAndCloseAnimation, self.closeAniName, gPanelId.S_CHALLENGE_STATEMENT_PANEL)
end

M.RefreshChallengeInfoShown = function(self, challengeTaskId)
	self.challengeCfgData = self.mgr:GetChallengeConfigByTaskId(challengeTaskId)

	if not self.challengeCfgData then
		print_error("ChallengeStatement页面-找不到任务对应的挑战ID！ taskId=", challengeTaskId)

		return
	end

	slot3 = self.mgr
	self.bindData.job = slot3:GetChallengeJobType(self.taskId)
	self.bindData.challengeNameText = self.challengeCfgData.Name
	self.bindData.backGround = self.challengeCfgData.Image
	slot2 = self.mgr

	slot2:AskNewChallengeRecord(self.challengeCfgData.Id, function (challengeRecord)
		if not challengeRecord then
			return
		end

		if not self.bindData or not self.bindData.descList then
			return
		end

		local paramData = challengeRecord.ParamData or {}
		local rewardList = self.challengeCfgData.RewardList or {}
		self.contentList = {}

		if not string.is_null_or_empty(self.challengeCfgData.Desc) then
			table.insert(self.contentList, {
				tIndex = DESC_TEMPLATE.DESC,
				text = self.challengeCfgData.Desc
			})
		end

		table.insert(self.contentList, {
			tIndex = DESC_TEMPLATE.TITLE,
			text = ChallengeConfig.GoalTitle
		})

		local goalNum = 0

		for i = 1, MAX_GOAL do
			local desc = self.challengeCfgData.CountersDescription[i]

			if not string.is_null_or_empty(desc) then
				goalNum = goalNum + 1

				table.insert(self.contentList, {
					tIndex = DESC_TEMPLATE.GOAL,
					isCheck = paramData[i - 1] or false,
					text = desc
				})
			end
		end

		self.bindData.goalNum = goalNum

		table.insert(self.contentList, {
			tIndex = DESC_TEMPLATE.SEPARATOR
		})
		table.insert(self.contentList, {
			tIndex = DESC_TEMPLATE.TITLE,
			text = ChallengeConfig.RewardTitle
		})

		self.bindData.medalCtrl = challengeRecord.HighestLevel
		local drops = {}

		for i = 1, #rewardList do
			local reward = rewardList[i]

			if challengeRecord.ReceivedRewardLevel >= reward.level then
				table.insert(drops, {
					["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
					["N\\xa1\\xb7\\xa1\\xa2"] = 0,
					dropId = reward.dropId
				})
			end
		end

		if self.challengeCfgData.RepeatReward == 0 then
			table.insert(drops, {
				["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
				["N\\xa1\\xb7\\xa1\\xa2"] = 0,
				dropId = self.challengeCfgData.RepeatReward
			})
		end

		local awardList = gCommonItemManager:GetItemSortedListByDropList(drops, true)

		for i = 1, #awardList do
			awardList[i] = gCommonItemManager:GetItemRenderData({
				itemId = awardList[i].Id
			})
		end

		self.rewardListData = awardList

		table.insert(self.contentList, {
			tIndex = DESC_TEMPLATE.REWARD
		})
		self.bindData.descList:SetSimpleList(#self.contentList)
	end)
end

M.GetTrackIdByTaskId = function(self, taskId)
	local eventId = 0

	for i = 0, LTConfig.TaskEventConfig.count - 1 do
		local cfg = LTConfig.TaskEventConfig.LoadAt(i)

		if cfg and cfg.StartTask ~= taskId then
			eventId = cfg.Id

			break
		end
	end

	if eventId ~= 0 then
		return 0
	end

	for j = 0, LTConfig.RacingDriverCompetitionGroupConfig.count - 1 do
		local gCfg = LTConfig.RacingDriverCompetitionGroupConfig.LoadAt(j)

		if gCfg and gCfg.ContestGroup then
			for _, entry in ipairs(gCfg.ContestGroup) do
				if entry.EventId ~= eventId then
					return entry.TrackId
				end
			end
		end
	end

	return 0
end
