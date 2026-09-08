-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerAccountPanelStore.lua
-- Decompiled from: 02041_CleanerAccountPanelStore.lua_9e3188f4a114.luajit

C_CleanerAccountPanelStore = DefClass("C_CleanerAccountPanelStore", C_CleanerAccountPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerAccountPanelStore = C_CleanerAccountPanelStore
local M = C_CleanerAccountPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.goOrderButton.luaClick = self.CreateAction(self, self.OnGoToOrderClick)
	self.bindData.scrollRect.luaInitContent = self.CreateAction(self, self.OnInitContent)
	self.washerJobInfo = nil
end

M.InitModel = function(self, args)
	M.base.InitModel(args)
end

M.InitView = function(self, args)
	M.base.InitView(args)

	local avatarWidget = self.bindData.avatarWidget

	gWasherManager.RefreshWasherAvatarView(avatarWidget, false)
	self.bindData.scrollRect.gameObject:SetActive(true)

	self.washerJobInfo = args.washerJobInfo

	self:OnInitContent(self.bindData.scrollRect.content)
end

M.OnInitContent = function(self, widget)
	if not self.washerJobInfo then
		return
	end

	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local historyInfo = gWasherManager:GetCurrentHistoryInfo()
	store.orderCount = historyInfo and historyInfo.HistoryMissionCnt or 0
	store.money = historyInfo and historyInfo.HistoryMissionMoneys or 0
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)
	local levelUpControlValue = self:CheckCanPromote(targetJobId) and 1 or 0
	store.levelUpControl = levelUpControlValue
	store.orderEntranceButton.luaClick = self:CreateAction(self.OnOrderEntranceClick)
	store.orderEntranceButton1.luaClick = self:CreateAction(self.OnOrderEntranceClick)
	store.levelUpButton.luaClick = self:CreateAction(self.OnLevelUpClick)
	store.logoutButton.luaClick = self:CreateAction(self.OnLogoutClick)
	store.occupationEntranceButton.luaClick = self:CreateAction(self.OnOccupationEntranceClick)

	self:RefreshJobInfo(targetJobId, store)
end

M.OnLevelUpClick = function(self)
	local currentJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)

	if currentJobId then
		local targetTaskId = self.GetPromoteTaskId(self, currentJobId)

		if targetTaskId then
			local taskState = gTaskManager:GetTaskState(targetTaskId)

			if taskState ~= UX.Game.TaskState.Accepted then
				gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
			else
				slot4 = gClientToGameDelegate

				slot4:AskAcceptTask(targetTaskId).Callback = function (errorId)
					if errorId == LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(errorId)

						return
					end
				end
			end
		end
	end
end

M.GetPromoteTaskId = function(self, currentJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(currentJobId)

	return urbanJobCfg and urbanJobCfg.PromoteTask <= 0 and urbanJobCfg.PromoteTask
end

M.OnOrderEntranceClick = function(self)
	gWasherManager:SwitchAppTab(gClientConst.WASHER_APP_SHOW_TYPE.COMPLETE, true)
end

M.RefreshJobInfo = function(self, targetJobId, store)
	local targetJobInfo = gSpiritJobManager.GetCurSpiritJob(targetJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(urbanJobCfg)

	if urbanJobCfg and levelCfg then
		store.jobNameText = urbanJobCfg.Name
		store.jobLevelText = string.format("Lv.%d", targetJobInfo.Level)
		local progressValue = targetJobInfo.Exp / levelCfg.Exp

		store.progress:ProgressToValue(progressValue)

		store.progressText = ("%d/%d"):format(targetJobInfo.Exp, levelCfg.Exp)
	end
end

M.OnLogoutClick = function(self)
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextConfig.GetConfig(73970547).Text,
		onConfirmCallback = function ()
			slot0 = gClientToGameDelegate

			slot0:AskQuitJob(LTConfig.UrbanJobJobClassConfig.Washer).Callback = function (errorId)
				if errorId == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end
			end
		end
	})
end

M.OnOccupationEntranceClick = function(self)
	gWasherManager:SwitchAppTab(gClientConst.WASHER_APP_SHOW_TYPE.OCCUPATION)
end

M.CheckCanPromote = function(self, currentJobId)
	local currentJobInfo = gSpiritJobManager.GetCurSpiritJob(currentJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(currentJobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(urbanJobCfg)

	if currentJobInfo and levelCfg and levelCfg.Exp < currentJobInfo.Exp then
		local targetTaskId = self.GetPromoteTaskId(self, currentJobId)

		if targetTaskId then
			local jobIdListChain = gSpiritJobManager:GetJobData(currentJobId)
			local _, index = table.find(jobIdListChain, currentJobId)

			return index <= table.count(jobIdListChain)
		end
	end
end

M.OnGoToOrderClick = function(self)
	if gClientUtils.NotNil(self.rootGo) then
		gWasherManager:SwitchAppTab(gClientConst.WASHER_APP_SHOW_TYPE.ORDER, true)
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end
