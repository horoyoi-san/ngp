C_DeliveryOccupationPanelStore = DefClass("C_DeliveryOccupationPanelStore", C_DeliveryOccupationPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryOccupationPanelStore = C_DeliveryOccupationPanelStore
local M = C_DeliveryOccupationPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.talentTreeButton.luaClick = self:CreateAction("OnTalentTreeClick")
end

function M:InitModel(args)
	M.base.InitModel(args)

	self.targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Delivery)
end

function M:InitView(args)
	M.base.InitView(args)
	gDeliveryTaskManager.RefreshDeliveryAvatarView(self.bindData.avatarWidget, self.rootGo)

	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(self.targetJobId)
	self.bindData.jobName = urbanJobCfg.Name

	self:RefreshJobExpView()
	self:RefreshJobListView()
end

function M:RefreshJobExpView()
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(self.targetJobId)
	local jobInfo = gSpiritJobManager.GetCurSpiritJob(self.targetJobId)
	local levelCfg = gSpiritJobManager:GetLevelData(urbanJobCfg, gSpiritManager:GetCurFirstSpiritTid())
	local progress = jobInfo.Exp / levelCfg.Exp

	self.bindData.progressBar:ProgressToValue(progress)

	self.bindData.progressText = ("%d/%d"):format(jobInfo.Exp, levelCfg.Exp)
end

function M:RefreshJobListView()
	local jobIdList = gSpiritJobManager:GetJobData(self.targetJobId)
	self.viewDataList = {}

	for _, jobId in pairs(jobIdList) do
		table.insert(self.viewDataList, {
			id = jobId,
			isNow = jobId <= self.targetJobId
		})
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

function M:OnRenderItem(btn, csIndex)
	local data = self.viewDataList[csIndex + 1]

	gSpiritJobManager:OnRenderJobPathItem(btn, csIndex, data)
end

function M:OnTalentTreeClick()
	gDeliveryTaskManager:OpenTalentTree()
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

function M:ClearData()
	self.viewDataList = nil
end
