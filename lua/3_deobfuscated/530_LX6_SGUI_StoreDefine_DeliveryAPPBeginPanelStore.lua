C_DeliveryAPPBeginPanelStore = DefClass("C_DeliveryAPPBeginPanelStore", C_DeliveryAPPBeginPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryAPPBeginPanelStore = C_DeliveryAPPBeginPanelStore
local M = C_DeliveryAPPBeginPanelStore
local UberSimConfig = LTConfig.UberSimConfig

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.startButton.luaClick = self:CreateAction(self.OnStartClick)
	self.bindData.logoutButton.luaClick = self:CreateAction(self.OnLogoutClick)
	self.bindData.taskAcceptBtn.luaPress = self:CreateAction(self.OnTaskAcceptBtnClick)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.Promote_Control = {
		Promote = 1,
		Normal = 0
	}
	self.NewJob_Control = {
		NewJob = 1,
		None = 0
	}

	self:GetTruckSatisfactionAverage()
end

function M:GetMessageEvents()
	return {
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction(self.OnJobChange),
		[gEventConstants.PANEL_ON_SHOW] = self:CreateAction(self.OnPanelShow),
		[gEventConstants.DELIVERY_TEACHING_TASK_STATE_CHANGED] = self:CreateAction(self.RefreshTaskCtrl)
	}
end

function M:GetTruckSatisfactionAverage()
	local rootGo = self.rootGo

	gClientToGameDelegate:AskGetTruckSatisfactionAverage().Callback = function (errorId, truckSatisfactionAverage)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		if gClientUtils.IsNil(rootGo) then
			return
		end

		self.truckSatisfactionAverage = truckSatisfactionAverage
		self.bindData.score = ("%.1f"):format(self.truckSatisfactionAverage)
	end
end

function M:InitView(args)
	M.base.InitView(self, args)

	local avatarWidget = self.bindData.avatar
	self.bindData.score = self.truckSatisfactionAverage and ("%.1f"):format(self.truckSatisfactionAverage) or 0
	local avatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	avatarStore.headIcon = gSpiritJobManager.GetAvailableJobAvatarId(LTConfig.UrbanJobJobClassConfig.Delivery)
	self.bindData.guideCtrl = not args.eventSubmited and not args.eventDoing and 1 or 0

	self:RefreshPanelView()
	self:RefreshTaskCtrl()
end

function M:RefreshPanelView()
	self.bindData.roleName = self:GetSpiritName()

	self:RefreshJobTemplateView(self.bindData.jobTemplate)
end

function M:OnJobChange()
	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()

	if currentJobClassId == LTConfig.UrbanJobJobClassConfig.Delivery then
		self:RefreshPanelView()
	end
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

function M:RefreshJobTemplateView(btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Delivery)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
	store.name = self:GetSpiritName()
	store.jobName = urbanJobCfg.Name
	store.jobIconId = urbanJobCfg and urbanJobCfg.Icon or 0
	local targetJobInfo = gSpiritJobManager.GetCurSpiritJob(targetJobId)
	local registerTime = os.date("%Y.%m.%d", targetJobInfo.RegisterTime)
	store.time = LTConfig.TextScriptTextConfig.GetConfig(89901082).Text:format(registerTime)
	local headAvatarStore = gStoreManager:GetStoreGroup(store.avatar.Store):GetStoreByWidget(store.avatar)
	headAvatarStore.avatarId = gSpiritJobManager.GetAvailableJobAvatarId(LTConfig.UrbanJobJobClassConfig.Delivery)
	local spiritTid = gSpiritManager:GetCurFirstSpiritTid()
	local levelCfg = gSpiritJobManager:GetLevelData(urbanJobCfg, spiritTid)
	local progress = targetJobInfo.Exp / levelCfg.Exp

	store.progress:ProgressToValue(progress)

	store.progress.formatText = ("%d/%d"):format(targetJobInfo.Exp, levelCfg.Exp)
	store.newJobControl = self.NewJob_Control.None
	local level = levelCfg and levelCfg.Level or 1
	store.levelText = string.format("Lv%d", level or 1)
	local isNewJob = self:CheckIsNewJob(targetJobId)

	if gDeliveryTaskManager:CheckCanPromote(targetJobId) then
		store.promoteControl = self.Promote_Control.Promote
	else
		store.newJobControl = isNewJob and self.NewJob_Control.NewJob or self.NewJob_Control.None
		store.promoteControl = self.Promote_Control.Normal
	end

	self.bindData.startButton.gameObject:SetActive(store.newJobControl == self.NewJob_Control.None)

	store.promoteButton.luaClick = self:CreateActionWithArgs(self.OnPromoteClick, targetJobId)
	store.occupationEntranceButton.luaClick = self:CreateActionWithArgs(self.OnOccupationEntranceClick)

	function store.button.luaClick()
		if isNewJob then
			local prefKey = self:GetNewJobPrefKey(targetJobId)

			gClientUtils.SetBool(prefKey, true)

			store.newJobControl = self.NewJob_Control.None

			self.bindData.startButton.gameObject:SetActive(true)
		end
	end
end

function M:CheckIsNewJob(currentJobId)
	local jobIdListChain = gSpiritJobManager:GetJobData(currentJobId)
	local _, index = table.find(jobIdListChain, currentJobId)
	local prefKey = self:GetNewJobPrefKey(currentJobId)

	if index > 1 and not gClientUtils.GetBool(prefKey, false) then
		return true
	end
end

function M:GetNewJobPrefKey(currentJobId)
	return ("DeliveryAppNewJob:%d"):format(currentJobId)
end

function M:OnOccupationEntranceClick()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.OCCUPATION
	})
end

function M:OnPromoteClick(currentJobId)
	local targetTaskId = gDeliveryTaskManager:GetPromoteTaskId(currentJobId)

	if targetTaskId then
		local taskState = gTaskManager:GetTaskState(targetTaskId)

		if taskState == UX.Game.TaskState.Accepted then
			gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
		else
			local rootGo = self.rootGo

			gClientToGameDelegate:AskAcceptTask(targetTaskId).Callback = function (errorId, data)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end

				if gClientUtils.IsNil(rootGo) then
					return
				end
			end
		end
	end
end

function M:GetUrbanJobAvatarConfig(spiritId)
	local count = LTConfig.UrbanJobAvatarConfig.count

	for i = 0, count - 1 do
		local urbanJobAvatarCfg = LTConfig.UrbanJobAvatarConfig.LoadAt(i)

		if urbanJobAvatarCfg.SpiritId == spiritId then
			return urbanJobAvatarCfg
		end
	end
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

function M:OnTaskAcceptBtnClick()
	local gpsId = gMapSubSystem_Task:GetGpsIdByTaskEventId(UberSimConfig.TeachEventId)

	if gpsId then
		gMapUtils:PlayerOpenBigMap({
			autoSelectGpsId = gpsId
		})
	end

	self:OnExit()
end

function M:OnStartClick()
	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()

	if currentJobClassId ~= LTConfig.UrbanJobJobClassConfig.Delivery then
		local rootGo = self.rootGo

		gClientToGameDelegate:AskStartJob(LTConfig.UrbanJobJobClassConfig.Delivery).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				if gClientUtils.IsNil(rootGo) then
					return
				end

				self:EnterOrderPanel()
			else
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end

		return
	end

	self:EnterOrderPanel()
end

function M:OnLogoutClick()
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextConfig.GetConfig(73970547).Text,
		onConfirmCallback = function ()
			local rootGo = self.rootGo

			gClientToGameDelegate:AskQuitJob(LTConfig.UrbanJobJobClassConfig.Delivery).Callback = function (errorId)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end

				if gClientUtils.IsNil(rootGo) then
					return
				end

				self:OnExit()
			end
		end
	})
end

function M:OnLogOut()
	self.truckSatisfactionAverage = nil
end

function M:EnterOrderPanel()
	gClientToGameDelegate:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		if gClientUtils.NotNil(self.rootGo) then
			gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
				secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.ORDER,
				clientTruckOrderView = clientTruckOrderView
			})
		end
	end
end

function M:OnPanelShow(_, panelId)
	if panelId == gPanelId.DRIVER_JOB_PANEL then
		self:EnterOrderPanel()
	end
end

function M:RefreshTaskCtrl()
	self.bindData.taskCtrl = gDeliveryTaskManager.isInTeachingTask and 1 or 0
end
