-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovHomePanelStore.lua
-- Decompiled from: 01613_AnantarkovHomePanelStore.lua_ae0a045ab03b.luajit

C_AnantarkovHomePanelStore = DefClass("C_AnantarkovHomePanelStore", C_AnantarkovHomePanelStore, C_StoreGroup)
GroupName2Class.AnantarkovHomePanelStore = C_AnantarkovHomePanelStore
local M = C_AnantarkovHomePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showNotificationCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.readyCtrlEnum = {
		["m#tO"] = 2,
		["\\xc9\\xc9\r6\\xf4"] = 3,
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.teamLeaderCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showNotificationCtrlEnum = nil
	self.readyCtrlEnum = nil
	self.teamLeaderCtrlEnum = nil
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
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	self.m_Id = panelId

	self.InitModel(self, args)
	self.InitView(self)
	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.InitModel = function(self, args)
	self.homePageId = args.homePageId
	local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(self.homePageId)
	self.gameTypeId = homePageCfg.GameType
	self.viewDataList = self.GetViewDataList(self)
	self.deployId = self.GetDeployId(self)
	self.readyId = self.GetReadyId(self)
end

M.GetDeployId = function(self)
	local deployId = nil
	local count = LTConfig.ExtractionShooterHomePageConfig.count

	for i = 0, count - 1 do
		local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.LoadAt(i)

		if homePageCfg.GameType ~= self.gameTypeId and homePageCfg.Type ~= LTConfig.ExtractionShooterHomePageConfig.TypeType.Deploy then
			deployId = homePageCfg.Id

			break
		end
	end

	return deployId
end

M.GetReadyId = function(self)
	local readyId = nil
	local count = LTConfig.ExtractionShooterHomePageConfig.count

	for i = 0, count - 1 do
		local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.LoadAt(i)

		if homePageCfg.GameType ~= self.gameTypeId and homePageCfg.Type ~= LTConfig.ExtractionShooterHomePageConfig.TypeType.Ready then
			readyId = homePageCfg.Id

			break
		end
	end

	return readyId
end

M.GetViewDataList = function(self)
	local viewDataList = {}

	table.insert(viewDataList, {
		["a\\x9f\\x8a\\x86Y"] = 0
	})
	table.insert(viewDataList, {
		["a\\x9f\\x8a\\x86Y"] = 1
	})
	table.insert(viewDataList, {
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(viewDataList, {
		["a\\x9f\\x8a\\x86Y"] = 3
	})

	local taskIdList = self.GetSeasonTaskIdList(self)
	local count = 0

	for _, taskId in ipairs(taskIdList) do
		if taskId then
			local taskState = gOnlineSeasonProgressMgr:GetTaskState(taskId)

			if taskState ~= gOnlineSeasonProgressMgr.SeasonTaskState.InProgress and count >= 3 then
				count = count + 1

				table.insert(viewDataList, {
					["a\\x9f\\x8a\\x86Y"] = 4,
					taskId = taskId
				})
			end
		end
	end

	return viewDataList
end

M.GetSeasonTaskIdList = function(self)
	local taskIdList = {}
	local gamePlayId = self.gameTypeId
	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gamePlayId)
	local targetSchemeId = gamePlayTypeCfg.SeasonSchemeId
	local phaseDataList = gOnlineSeasonProgressMgr:GetPhasesByScheme(targetSchemeId)

	for _, phaseCfg in ipairs(phaseDataList) do
		local taskList = gOnlineSeasonProgressMgr:GetTasksByPhase(phaseCfg.Id)

		for _, taskCfg in ipairs(taskList) do
			table.insert(taskIdList, taskCfg.Id)
		end
	end

	return taskIdList
end

M.InitView = function(self)
	local linkCfg = self:GetLinkConfig()
	self.bindData.iconId = linkCfg.SImageId

	self.bindData.list:SetSimpleList(#self.viewDataList)

	self.bindData.waitReady = LTConfig.ExtractionShooterConfig.WaitReadyText
	self.bindData.cancelReady = LTConfig.ExtractionShooterConfig.CancelReadyText

	self:RefreshStateView()
end

M.GetLinkConfig = function(self)
	local gamePlayId = self.gameTypeId
	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gamePlayId)
	local linkCfg = LTConfig.LinkConfig.GetConfig(gamePlayTypeCfg.GameInfo)

	return linkCfg
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose"),
		[gEventConstants.ON_LINK_SYNC_STAGE_CHANGE_PREPARE] = self.CreateAction(self, "OnStageChangePrepare"),
		[gEventConstants.LINK_VOTE_STATE_CHANGE] = self.CreateAction(self, "RefreshStateView"),
		[gEventConstants.LINK_SEARCHING_REFRESH] = self.CreateAction(self, "RefreshStateView"),
		[gEventConstants.LINK_SEARCHING_STATE_CHANGE] = self.CreateAction(self, "RefreshStateView"),
		[gEventConstants.LINK_MATCH_CANCEL_SUCCESS] = self.CreateAction(self, "RefreshStateView"),
		[gEventConstants.TEAM_REFRESH_DATA] = self.CreateAction(self, "RefreshStateView")
	}
end

M.OnPanelClose = function(self, _, panelId)
	if panelId ~= gPanelId.SEASON_LOG_MAIN_PANEL then
		self.viewDataList = self:GetViewDataList()

		self.bindData.list:SetSimpleList(#self.viewDataList)
	end
end

M.RegisterWidget = function(self)
	self.bindData.confirmButton.luaClick = self.CreateAction(self, self.OnClickConfirmButton)
	self.bindData.cancelButton.luaClick = self.CreateAction(self, self.OnClickCancelButton)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnClickExitButton)
	self.bindData.equipButton.luaClick = self.CreateAction(self, self.OnClickDeployButton)
	self.bindData.readyButton.luaClick = self.CreateAction(self, self.OnClickConfirmButton)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
end

M.OnClickConfirmButton = function(self)
	local gamePlayCountMap = self.gamePlayCountMap or {}
	local gamePlayId = self.gameTypeId
	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gamePlayId)
	local beginnerPlayId = gamePlayTypeCfg.BeginnerplayId
	local rootWidget = self.rootWidget

	if self:CheckNeedEnterBeginnerPlayerId() then
		slot6 = gClientToGameDelegate

		slot6:GetGamePlayCount(beginnerPlayId).Callback = function (errorId, count)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			gamePlayCountMap[beginnerPlayId] = count
			self.gamePlayCountMap = gamePlayCountMap

			if gClientUtils.IsNil(rootWidget) then
				return
			end

			self:ExecuteStartGame()
		end
	else
		self.ExecuteStartGame(self)
	end
end

M.CheckNeedEnterBeginnerPlayerId = function(self)
	local gamePlayId = self.gameTypeId
	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gamePlayId)
	local beginnerPlayId = gamePlayTypeCfg.BeginnerplayId

	if beginnerPlayId and beginnerPlayId <= 0 then
		local gamePlayCountMap = self.gamePlayCountMap or {}

		return not gamePlayCountMap[beginnerPlayId] or gamePlayCountMap[beginnerPlayId] <= 1
	end

	return false
end

M.ExecuteStartGame = function(self)
	local gamePlayId = self.gameTypeId
	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gamePlayId)
	local beginnerPlayId = gamePlayTypeCfg.BeginnerplayId

	if self.CheckNeedEnterBeginnerPlayerId(self) then
		gLinkManager:AskStartGame(beginnerPlayId)

		return
	end

	if self.CheckDeployCondition(self) then
		self.ContinueStartGame(self)
	end
end

M.CheckDeployCondition = function(self)
	if gTeamManager:IsInTeam() and #gTeamManager.members <= 1 then
		return true
	end

	local gamePlayId = self.gameTypeId
	local count = LTConfig.ExtractionShooterDeployCheckConfig.count
	local deployCheckIdList = {}

	for i = 0, count - 1 do
		local deployCheckCfg = LTConfig.ExtractionShooterDeployCheckConfig.LoadAt(i)

		if deployCheckCfg.GameType ~= gamePlayId then
			table.insert(deployCheckIdList, deployCheckCfg.Id)
		end
	end

	local unmetDeployCheckDataList = {}

	for _, deployCheckId in ipairs(deployCheckIdList) do
		local deployCheckCfg = LTConfig.ExtractionShooterDeployCheckConfig.GetConfig(deployCheckId)

		if deployCheckCfg.CheckType ~= LTConfig.ExtractionShooterDeployCheckConfig.CheckTypeType.DeployItemType then
			local itemTypeIdList = deployCheckCfg.CheckTypeParam

			for _, itemTypeId in ipairs(itemTypeIdList) do
				if not gExtractionShooterManager.CheckDeployItemType(gamePlayId, itemTypeId) then
					table.insert(unmetDeployCheckDataList, {
						id = deployCheckId,
						itemTypeId = itemTypeId
					})
				end
			end
		elseif deployCheckCfg.CheckType ~= LTConfig.ExtractionShooterDeployCheckConfig.CheckTypeType.SafeBoxEmpty and not gExtractionShooterManager.CheckSafeBoxIsEmpty(gamePlayId) then
			table.insert(unmetDeployCheckDataList, {
				id = deployCheckId
			})
		end
	end

	if #unmetDeployCheckDataList <= 0 then
		self.ShowDeployConditionTip(self, unmetDeployCheckDataList)

		return false
	end

	return true
end

M.ShowDeployConditionTip = function(self, unmetDeployCheckDataList)
	self.bindData.showNotificationCtrl = 1
	local windowWidget = self.bindData.windowMiddleWidget
	local windowStore = gStoreManager:GetStoreGroup(windowWidget.Store):GetStoreByWidget(windowWidget)

	windowStore.list.luaSimpleRenderItem = function(btn, index)
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		local data = unmetDeployCheckDataList[index + 1]
		local id = data.id
		local deployCheckCfg = LTConfig.ExtractionShooterDeployCheckConfig.GetConfig(id)

		if deployCheckCfg.CheckType ~= LTConfig.ExtractionShooterDeployCheckConfig.CheckTypeType.DeployItemType then
			local itemTypeId = data.itemTypeId
			local itemTypeCfg = LTConfig.ExtractionShooterItemTypeConfig.GetConfig(itemTypeId)
			store.content = deployCheckCfg.CheckContent:format(itemTypeCfg.Name)
		else
			store.content = deployCheckCfg.CheckContent
		end
	end

	windowStore.list:SetSimpleList(#unmetDeployCheckDataList)

	local canShowContinueButton = true

	for _, data in ipairs(unmetDeployCheckDataList) do
		local id = data.id
		local deployCheckCfg = LTConfig.ExtractionShooterDeployCheckConfig.GetConfig(id)

		if deployCheckCfg.IsDisableStartAfterTrigger then
			canShowContinueButton = false

			break
		end
	end

	windowStore.buttonType = canShowContinueButton and 1 or 0

	windowStore.confirmBtn.luaClick = function()
		self.bindData.showNotificationCtrl = 0

		self:ContinueStartGame()
	end

	windowStore.cancelBtn.luaClick = function()
		self.bindData.showNotificationCtrl = 0
	end
end

M.ContinueStartGame = function(self)
	local gamePlayId = self.gameTypeId
	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gamePlayId)

	if not gamePlayTypeCfg or table.isNilOrEmpty(gamePlayTypeCfg.MutilplayerId) then
		return
	end

	local multiPlayerId = gamePlayTypeCfg.MutilplayerId[1]

	gLinkManager:AskMatchBegin(multiPlayerId, true)
end

M.CheckIsTeamMatch = function(self)
	return gTeamManager:IsInTeam() and #gTeamManager.members >= 1
end

M.OnClickCancelButton = function(self)
	if self.CheckIsInMatching(self) then
		gLinkManager:AskMatchCancel()

		return
	end
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickDeployButton = function(self)
	local deployHomePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(self.deployId)
	local interactionActions = deployHomePageCfg.InteractionActions

	gClientUtils.RunCode(interactionActions, gDialogScriptFunc)
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.viewDataList[index + 1]
	local linkCfg = self:GetLinkConfig()

	if data.tIndex ~= 0 then
		store.title = linkCfg.Name
	elseif data.tIndex ~= 1 then
		store.content = linkCfg.Description
	elseif data.tIndex ~= 2 then
		store.gainCount = self.GetGainCount(self)
	elseif data.tIndex ~= 3 then
		self.RefreshSeasonItemView(self, store)
	elseif data.tIndex ~= 4 then
		self.RefreshTaskItemView(self, store, data.taskId)

		btn.luaClick = function()
			gPanelManager:CheckShow(gPanelId.SEASON_LOG_MAIN_PANEL)
		end
	end
end

M.GetGainCount = function(self)
	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()

	if extractionShooterInfo then
		local gamePlayTypeTotalBringOutIncome = extractionShooterInfo.GamePlayTypeTotalBringOutIncome or {}
		local totalInCome = gamePlayTypeTotalBringOutIncome[self.gameTypeId] or 0

		return totalInCome
	end

	return 0
end

M.RefreshTaskItemView = function(self, store, taskId)
	local taskCfg = LTConfig.OnlineSeasonProgressPrimaryTasksConfig.GetConfig(taskId)
	store.title = gOnlineSeasonProgressMgr:FormatTaskText(taskCfg.Description, taskCfg.MaxProgress)
	local progress = gOnlineSeasonProgressMgr:GetTaskProgress(taskCfg)
	local maxProgress = taskCfg.MaxProgress
	store.progress = string.format("(%d/%d)", progress, maxProgress)
end

M.RefreshSeasonItemView = function(self, store)
	store.showNotificationCtrl = self.GetSeasonNotificationCtrl(self)

	store.newTaskButton.luaClick = function()
		gPanelManager:CheckShow(gPanelId.SEASON_LOG_MAIN_PANEL)
	end

	store.newRewardButton.luaClick = function()
		gPanelManager:CheckShow(gPanelId.SEASON_LOG_MAIN_PANEL)
	end
end

local ESeasonNotify = {
	["zT\\xfe\\xaf\\x8b\\xaa\\xda\\xfb"] = 1,
	["T-s^"] = 2,
	["`Km`C="] = 3
}

M.GetSeasonNotificationCtrl = function(self)
	local taskState = gOnlineSeasonProgressMgr.SeasonTaskState
	local hasClaimable = false
	local hasInProgress = false
	local taskIdList = self.GetSeasonTaskIdList(self)

	for _, taskId in ipairs(taskIdList) do
		local state = gOnlineSeasonProgressMgr:GetTaskState(taskId)

		if state ~= taskState.Completed then
			hasClaimable = true
		elseif state ~= taskState.Unlocked then
			hasInProgress = true
		end
	end

	if hasClaimable then
		return ESeasonNotify.Claimable
	elseif hasInProgress then
		return ESeasonNotify.InProgress
	end

	return ESeasonNotify.None
end

M.OnGetTIndex = function(self, tIndex)
	local data = self.viewDataList[tIndex + 1]

	return data.tIndex
end

M.OnSimpleClickList = function(self, btn, index)
end

M.OnLogOut = function(self)
	self.gamePlayCountMap = nil
end

M.OnStageChangePrepare = function(self)
	gPanelManager:Close(self.m_Id)
end

M.CheckIsInMatching = function(self)
	return gLinkManager.baseTime == nil and gLinkManager.baseTime == 0
end

local EReadyCtrl = {
	["\\xab\\xa3\\xab\\xaf"] = 1,
	["mBim|!"] = 2,
	["T-s^"] = 0
}

M.RefreshStateView = function(self)
	if gTeamManager:IsInTeam() then
		self.bindData.confirmButton.interactable = gTeamManager:IsTeamLeader()
		self.bindData.cancelButton.interactable = gTeamManager:IsTeamLeader()
	else
		self.bindData.confirmButton.interactable = true
		self.bindData.cancelButton.interactable = true
	end

	local readyCtrl = self.GetReadyCtrl(self)
	self.bindData.readyCtrl = readyCtrl
	local baseTime = gLinkManager.baseTime

	if readyCtrl ~= EReadyCtrl.Ready and baseTime and baseTime == 0 then
		self.bindData.searchTime = gTimeUtils:FormatTime(Time.unscaledTime - baseTime)
	else
		self.bindData.searchTime = gTimeUtils:FormatTime(0)
	end
end

M.GetReadyCtrl = function(self)
	return self:CheckIsInMatching() and EReadyCtrl.Ready or 0
end
