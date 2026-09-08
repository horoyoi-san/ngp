-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryAccountPanelStore.lua
-- Decompiled from: 01951_DeliveryAccountPanelStore.lua_21362a74f999.luajit

C_DeliveryAccountPanelStore = DefClass("C_DeliveryAccountPanelStore", C_DeliveryAccountPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryAccountPanelStore = C_DeliveryAccountPanelStore
local M = C_DeliveryAccountPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.finishJobButton.luaClick = self.CreateAction(self, "OnFinishJobClick")
	self.bindData.scrollRect.luaInitContent = self.CreateAction(self, "OnInitContent")
end

M.GetMessageEvents = function(self)
	return {}
end

M.InitModel = function(self, args)
	M.base.InitModel(args)

	self.clientTruckOrderView = args.clientTruckOrderView
end

M.InitView = function(self, args)
	M.base.InitView(args)

	local avatarWidget = self.bindData.avatarWidget
	local avatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	avatarStore.headIcon = gSpiritJobManager.GetAvailableJobAvatarId(LTConfig.UrbanJobJobClassConfig.Delivery)

	self.bindData.scrollRect.gameObject:SetActive(true)

	self.hasInitContent = true

	self:OnInitContent(self.bindData.scrollRect.content)
end

M.OnInitContent = function(self, widget)
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

M.OnLevelUpClick = function(self)
	local currentJobId = gSpiritJobManager.GetCurSpiritJobId()
	local targetTaskId = gDeliveryTaskManager:GetPromoteTaskId(currentJobId)

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

M.OnOrderEntranceClick = function(self)
	local rootGo = self.rootGo
	slot2 = gClientToGameDelegate

	slot2:AskGetFinishedOrderWraps().Callback = function (errorId, clientFinishedTruckOrderView)
		if errorId == LTConfig.MessageConfig.Ok then
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

M.RefreshJobTemplateView = function(self, targetJobId, jobTemplateWidget)
	local store = gStoreManager:GetStoreGroup(jobTemplateWidget.Store):GetStoreByWidget(jobTemplateWidget)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
	store.name = gClientUtils.GetCurrentSpiritDisplayName()
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

M.OnLogoutClick = function(self)
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextConfig.GetConfig(73970547).Text,
		onConfirmCallback = function ()
			slot0 = gClientToGameDelegate

			slot0:AskQuitJob(LTConfig.UrbanJobJobClassConfig.Delivery).Callback = function (errorId)
				if errorId == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end
			end
		end
	})
end

M.OnOccupationEntranceClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.OCCUPATION
	})
end

M.OnFinishJobClick = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskFinishJob().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.OnTalentTreeClick = function(self)
	gDeliveryTaskManager:OpenTalentTree()
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

M.ClearData = function(self)
	self.currentActiveContentCo = coroutine.stop(self.currentActiveContentCo)
	self.hasInitContent = nil
end
