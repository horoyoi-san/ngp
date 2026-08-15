C_DeliveryAccountPanelStore = DefClass("C_DeliveryAccountPanelStore", C_DeliveryAccountPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryAccountPanelStore = C_DeliveryAccountPanelStore
local M = C_DeliveryAccountPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.finishJobButton.luaClick = self:CreateAction("OnFinishJobClick")
	self.bindData.scrollRect.luaInitContent = self:CreateAction("OnInitContent")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction("RefreshRedDotView")
	}
end

function M:InitModel(args)
	M.base.InitModel(args)

	self.clientTruckOrderView = args.clientTruckOrderView
end

function M:InitView(args)
	M.base.InitView(args)

	self.redDotKey = "DeliveryHomePagePanelAvatarRedDot"
	local avatarWidget = self.bindData.avatarWidget
	local avatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	avatarStore.headIcon = gSpiritJobManager.GetAvailableJobAvatarId(LTConfig.UrbanJobJobClassConfig.Delivery)

	self.bindData.scrollRect.gameObject:SetActive(true)

	self.hasInitContent = true

	self:OnInitContent(self.bindData.scrollRect.content)
end

function M:OnInitContent(widget)
	if not self.hasInitContent then
		return
	end

	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local jobTemplateWidget = store.jobTemplate
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Delivery)
	local levelUpControlValue = gDeliveryTaskManager:CheckCanPromote(targetJobId) and 1 or 0
	store.levelUpControl = levelUpControlValue
	store.orderEntranceButton.luaClick = self:CreateAction("OnOrderEntranceClick")
	store.levelUpButton.luaClick = self:CreateAction("OnLevelUpClick")
	store.levelUpButton.redKey = self.redDotKey
	local hasRedDot = gDeliveryTaskManager:CheckCanPromote(targetJobId)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, self.redDotKey)

	if store.controlL3 then
		store.controlL3.gameObject:SetActive(true)
	end

	if store.controlR3 then
		store.controlR3.gameObject:SetActive(true)
	end

	store.score = self.clientTruckOrderView and self.clientTruckOrderView.TotalIncome or 0
	local targetJobInfo = gSpiritJobManager.GetCurSpiritJob(targetJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
	store.jobIconId = urbanJobCfg and urbanJobCfg.Icon or 0
	local levelCfg = gSpiritJobManager:GetLevelData(urbanJobCfg, gSpiritManager:GetCurFirstSpiritTid())
	local level = levelCfg and levelCfg.Level or 1
	store.levelText = string.format("Lv%d", level or 1)
	local progress = targetJobInfo.Exp / levelCfg.Exp

	store.progress:ProgressToValue(progress)

	store.progress.formatText = ("%d/%d"):format(targetJobInfo.Exp, levelCfg.Exp)

	self:RefreshJobTemplateView(targetJobId, jobTemplateWidget)

	store.occupationEntranceButton.luaClick = self:CreateAction("OnOccupationEntranceClick")
	store.talentTreeButton.luaClick = self:CreateAction("OnTalentTreeClick")
	store.jobName = urbanJobCfg.Name
	self.currentActiveContentCo = coroutine.start(function ()
		coroutine.step()

		if hasRedDot then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = store.levelUpButton
		else
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = store.occupationEntranceButton
		end
	end)
end

function M:RefreshRedDotView()
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Delivery)
	local hasRedDot = gDeliveryTaskManager:CheckCanPromote(targetJobId)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, self.redDotKey)
end

function M:OnLevelUpClick()
	local currentJobId = gSpiritJobManager.GetCurSpiritJobId()
	local targetTaskId = gDeliveryTaskManager:GetPromoteTaskId(currentJobId)

	if targetTaskId then
		local taskState = gTaskManager:GetTaskState(targetTaskId)

		if taskState == UX.Game.TaskState.Accepted then
			gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
		else
			gClientToGameDelegate:AskAcceptTask(targetTaskId).Callback = function (errorId)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end
			end
		end
	end
end

function M:OnOrderEntranceClick()
	local rootGo = self.rootGo

	gClientToGameDelegate:AskGetFinishedOrderWraps().Callback = function (errorId, clientFinishedTruckOrderView)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		if gClientUtils.IsNil(rootGo) then
			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
			secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.COMPLETE,
			clientFinishedTruckOrderView = clientFinishedTruckOrderView
		})
	end
end

function M:RefreshJobTemplateView(targetJobId, jobTemplateWidget)
	local store = gStoreManager:GetStoreGroup(jobTemplateWidget.Store):GetStoreByWidget(jobTemplateWidget)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
	store.name = self:GetSpiritName()
	store.jobName = urbanJobCfg.Name
	local targetJobInfo = gSpiritJobManager.GetCurSpiritJob(targetJobId)
	local registerTime = os.date("%Y.%m.%d", targetJobInfo.RegisterTime)
	store.time = LTConfig.TextScriptTextConfig.GetConfig(89901082).Text:format(registerTime)
	local headAvatarStore = gStoreManager:GetStoreGroup(store.avatar.Store):GetStoreByWidget(store.avatar)
	headAvatarStore.avatarId = gSpiritJobManager.GetAvailableJobAvatarId(LTConfig.UrbanJobJobClassConfig.Delivery)
	local levelCfg = gSpiritJobManager:GetLevelData(urbanJobCfg, gSpiritManager:GetCurFirstSpiritTid())
	local progress = targetJobInfo.Exp / levelCfg.Exp

	store.progress:ProgressToValue(progress)

	store.progressText = ("%d/%d"):format(targetJobInfo.Exp, levelCfg.Exp)
	store.logoutButton.luaClick = self:CreateAction("OnLogoutClick")
end

function M:OnLogoutClick()
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextConfig.GetConfig(73970547).Text,
		onConfirmCallback = function ()
			gClientToGameDelegate:AskQuitJob(LTConfig.UrbanJobJobClassConfig.Delivery).Callback = function (errorId)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end
			end
		end
	})
end

function M:OnOccupationEntranceClick()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.OCCUPATION
	})
end

function M:GetSpiritName()
	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	if currentSpiritId == LTConfig.FightSpiritConfig.DefaultMale or currentSpiritId == LTConfig.FightSpiritConfig.DefaultFemale then
		return gPlayerManager.infoLogin.bindData.name
	else
		local fightSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(currentSpiritId)

		return fightSpiritCfg.Name
	end
end

function M:OnFinishJobClick()
	gClientToGameDelegate:AskFinishJob().Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

function M:OnTalentTreeClick()
	gDeliveryTaskManager:OpenTalentTree()
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

function M:ClearData()
	self.currentActiveContentCo = coroutine.stop(self.currentActiveContentCo)
	self.hasInitContent = nil
end
