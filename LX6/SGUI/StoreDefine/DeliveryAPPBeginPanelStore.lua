-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryAPPBeginPanelStore.lua
-- Decompiled from: 01969_DeliveryAPPBeginPanelStore.lua_ae20543a35c0.luajit

C_DeliveryAPPBeginPanelStore = DefClass("C_DeliveryAPPBeginPanelStore", C_DeliveryAPPBeginPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryAPPBeginPanelStore = C_DeliveryAPPBeginPanelStore
local M = C_DeliveryAPPBeginPanelStore
local UberSimConfig = LTConfig.UberSimConfig

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.startButton.luaClick = self.CreateAction(self, self.OnStartClick)
	self.bindData.logoutButton.luaClick = self.CreateAction(self, self.OnLogoutClick)
	self.bindData.taskAcceptBtn.luaPress = self.CreateAction(self, self.OnTaskAcceptBtnClick)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.Promote_Control = {
		["\\xe9\\xc90\\xf4"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.NewJob_Control = {
		["2M\\x86\\xa4\\x8cC"] = 1,
		["T-s^"] = 0
	}

	self.GetTruckSatisfactionAverage(self)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, self.OnJobChange),
		[gEventConstants.PANEL_ON_SHOW] = self.CreateAction(self, self.OnPanelShow),
		[gEventConstants.DELIVERY_TEACHING_TASK_STATE_CHANGED] = self.CreateAction(self, self.RefreshTaskCtrl)
	}
end

M.GetTruckSatisfactionAverage = function(self)
	local rootGo = self.rootGo
	slot2 = gClientToGameDelegate

	slot2:AskGetTruckSatisfactionAverage().Callback = function (errorId, truckSatisfactionAverage)
		if errorId == LTConfig.MessageConfig.Ok then
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

M.InitView = function(self, args)
	M.base.InitView(self, args)

	local avatarWidget = self.bindData.avatar
	self.bindData.score = self.truckSatisfactionAverage and ("%.1f"):format(self.truckSatisfactionAverage) or 0
	local avatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	avatarStore.headIcon = gSpiritJobManager.GetAvailableJobAvatarId(LTConfig.UrbanJobJobClassConfig.Delivery)
	self.bindData.guideCtrl = not args.eventSubmited and not args.eventDoing and 1 or 0

	self:RefreshPanelView()
	self:RefreshTaskCtrl()
end

M.RefreshPanelView = function(self)
	self.bindData.roleName = gClientUtils.GetCurrentSpiritDisplayName()

	self.RefreshJobTemplateView(self, self.bindData.jobTemplate)
end

M.OnJobChange = function(self)
	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()

	if currentJobClassId ~= LTConfig.UrbanJobJobClassConfig.Delivery then
		self.RefreshPanelView(self)
	end
end

M.RefreshJobTemplateView = function(self, btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Delivery)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
	store.name = gClientUtils.GetCurrentSpiritDisplayName()
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

	slot13 = self.bindData.startButton.gameObject

	slot13:SetActive(store.newJobControl ~= self.NewJob_Control.None)

	store.promoteButton.luaClick = self:CreateActionWithArgs(self.OnPromoteClick, targetJobId)
	store.occupationEntranceButton.luaClick = self:CreateActionWithArgs(self.OnOccupationEntranceClick)

	store.button.luaClick = function()
		if isNewJob then
			local prefKey = self:GetNewJobPrefKey(targetJobId)

			gClientUtils.SetBool(prefKey, true)

			store.newJobControl = self.NewJob_Control.None

			self.bindData.startButton.gameObject:SetActive(true)
		end
	end
end

M.CheckIsNewJob = function(self, currentJobId)
	local jobIdListChain = gSpiritJobManager:GetJobData(currentJobId)
	local _, index = table.find(jobIdListChain, currentJobId)
	local prefKey = self:GetNewJobPrefKey(currentJobId)

	if index <= 1 and not gClientUtils.GetBool(prefKey, false) then
		return true
	end
end

M.GetNewJobPrefKey = function(self, currentJobId)
	return ("DeliveryAppNewJob:%d"):format(currentJobId)
end

M.OnOccupationEntranceClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.OCCUPATION
	})
end

M.OnPromoteClick = function(self, currentJobId)
	local targetTaskId = gDeliveryTaskManager:GetPromoteTaskId(currentJobId)

	if targetTaskId then
		local taskState = gTaskManager:GetTaskState(targetTaskId)

		if taskState ~= UX.Game.TaskState.Accepted then
			gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
		else
			local rootGo = self.rootGo
			slot5 = gClientToGameDelegate

			slot5:AskAcceptTask(targetTaskId).Callback = function (errorId, data)
				if errorId == LTConfig.MessageConfig.Ok then
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

M.GetUrbanJobAvatarConfig = function(self, spiritId)
	local count = LTConfig.UrbanJobAvatarConfig.count

	for i = 0, count - 1 do
		local urbanJobAvatarCfg = LTConfig.UrbanJobAvatarConfig.LoadAt(i)

		if urbanJobAvatarCfg.SpiritId ~= spiritId then
			return urbanJobAvatarCfg
		end
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

M.OnTaskAcceptBtnClick = function(self)
	local gpsId = gMapSubSystem_Task:GetGpsIdByTaskEventId(UberSimConfig.TeachEventId)

	if gpsId then
		gMapUtils:PlayerOpenBigMap({
			autoSelectGpsId = gpsId
		})
	end

	self.OnExit(self)
end

M.OnStartClick = function(self)
	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()

	if currentJobClassId == LTConfig.UrbanJobJobClassConfig.Delivery then
		local rootGo = self.rootGo
		slot3 = gClientToGameDelegate

		slot3:AskStartJob(LTConfig.UrbanJobJobClassConfig.Delivery).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
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

	self.EnterOrderPanel(self)
end

M.OnLogoutClick = function(self)
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextConfig.GetConfig(73970547).Text,
		onConfirmCallback = function ()
			local rootGo = self.rootGo
			slot1 = gClientToGameDelegate

			slot1:AskQuitJob(LTConfig.UrbanJobJobClassConfig.Delivery).Callback = function (errorId)
				if errorId == LTConfig.MessageConfig.Ok then
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

M.OnLogOut = function(self)
	self.truckSatisfactionAverage = nil
end

M.EnterOrderPanel = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskGetTruckJobOrders().Callback = function (errorId, clientTruckOrderView)
		if errorId == LTConfig.MessageConfig.Ok then
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

M.OnPanelShow = function(self, _, panelId)
	if panelId ~= gPanelId.DRIVER_JOB_PANEL then
		self.EnterOrderPanel(self)
	end
end

M.RefreshTaskCtrl = function(self)
	self.bindData.taskCtrl = gDeliveryTaskManager.isInTeachingTask and 1 or 0
end
