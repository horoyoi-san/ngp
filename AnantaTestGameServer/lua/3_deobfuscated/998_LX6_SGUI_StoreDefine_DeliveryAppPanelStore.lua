C_DeliveryAppPanelStore = DefClass("C_DeliveryAppPanelStore", C_DeliveryAppPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryAppPanelStore = C_DeliveryAppPanelStore
local M = C_DeliveryAppPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.takeJobButton.luaClick = self:CreateAction(self.OnTakeJobClick)
	self.bindData.finishJobButton.luaClick = self:CreateAction(self.OnFinishJobClick)
end

function M:InitModel()
	M.base.InitModel(self)

	self.TakeJobControl = {
		Hide = 1,
		Show = 0
	}
	self.CurrentJobControl = {
		Hide = 0,
		Show = 1
	}
	self.currentJobId = gSpiritJobManager.GetCurSpiritJobId()
	self.spiritJobIdList = self:GetCurSpiritJobIdList()
end

function M:GetCurSpiritJobIdList()
	local jobIdList = gSpiritJobManager.GetCurSpiritAvailableJobIdList()

	table.sort(jobIdList, function (jobId1, jobId2)
		if jobId1 == self.currentJobId then
			return true
		end

		local spiritJob1 = gSpiritJobManager.GetCurSpiritJob(jobId1)
		local spiritJob2 = gSpiritJobManager.GetCurSpiritJob(jobId2)

		if spiritJob1.UnregisterTime ~= spiritJob2.UnregisterTime then
			return spiritJob2.UnregisterTime < spiritJob1.UnregisterTime
		end

		return jobId1 < jobId2
	end)

	return jobIdList
end

function M:InitView()
	M.base.InitView(self)

	local store = gStoreManager:GetStoreGroup("BubbleCommonAvatar"):GetStoreByWidget(self.bindData.avatar)
	store.headIcon = gStoreStaticMethod:GetHeadIcon(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	self.bindData.roleName = gPlayerManager.infoLogin.bindData.name
	self.viewDataList = {}

	for _, spiritJobId in ipairs(self.spiritJobIdList) do
		table.insert(self.viewDataList, {
			spiritJobId = spiritJobId
		})
	end

	self.selectedJobId = self.viewDataList[1] and self.viewDataList[1].spiritJobId

	self.bindData.list:SetSimpleList(#self.viewDataList)
	self:RefreshTakeJobButtonView()
end

function M:RefreshPanelView()
	self.currentJobId = gSpiritJobManager.GetCurSpiritJobId()

	self.bindData.list:RefreshList()
	self:RefreshTakeJobButtonView()
end

function M:RefreshTakeJobButtonView()
	self.bindData.takeJobControl = self.selectedJobId == self.currentJobId and self.TakeJobControl.Hide or self.TakeJobControl.Show
end

function M:OnRenderItem(btn, index)
	local data = self.viewDataList[index + 1]

	if not data then
		return
	end

	local storeName = btn.Store
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(btn)
	local spiritJobId = data.spiritJobId
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(spiritJobId)
	local currentSpiritTid = gSpiritManager:GetCurFirstSpiritTid()
	local fightSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(currentSpiritTid)
	store.name = fightSpiritCfg.Name
	store.jobName = urbanJobCfg.Name
	local spiritJob = gSpiritJobManager.GetCurSpiritJob(spiritJobId)
	local registerTime = os.date("%Y.%m.%d", spiritJob.RegisterTime)
	store.time = LTConfig.TextScriptTextConfig.GetConfig(89901082).Text:format(registerTime)
	store.currentJobControl = self.currentJobId == spiritJobId and self.CurrentJobControl.Show or self.CurrentJobControl.Hide
	store.button.isSelected = self.selectedJobId == spiritJobId

	function store.button.luaClick()
		self.selectedJobId = spiritJobId

		self:RefreshPanelView()
	end

	local headAvatarStore = gStoreManager:GetStoreGroup("HeadAvatarSquareBtnStore"):GetStoreByWidget(store.avatar)
	local urbanJobAvatarCfg = self:GetUrbanJobAvatarConfig(currentSpiritTid)
	local avatarKey = ("Avatar%d"):format(spiritJobId)
	headAvatarStore.avatarId = urbanJobAvatarCfg and urbanJobAvatarCfg[avatarKey]
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

function M:OnTakeJobClick()
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(self.selectedJobId)

	gClientToGameDelegate:AskStartJob(urbanJobCfg.JobClass).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if self.hasDestroy then
			return
		end

		self:RefreshPanelView()
	end
end

function M:OnFinishJobClick()
	gClientToGameDelegate:AskFinishJob().Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if self.hasDestroy then
			return
		end

		self:RefreshPanelView()
	end
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
