C_CleanerOccupationPanelStore = DefClass("C_CleanerOccupationPanelStore", C_CleanerOccupationPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerOccupationPanelStore = C_CleanerOccupationPanelStore
local M = C_CleanerOccupationPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.talentTreeButton.luaClick = self:CreateAction(self.OnTalentTreeClick)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
end

function M:InitModel(args)
	M.base.InitModel(args)

	self.targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)
end

function M:InitView(args)
	M.base.InitView(args)
	gWasherManager.RefreshWasherAvatarView(self.bindData.avatarWidget, true)

	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(self.targetJobId)
	self.bindData.jobName = urbanJobCfg.Name

	self:RefreshJobExpView()
	self:RefreshJobListView()
end

function M:RefreshJobExpView()
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(self.targetJobId)
	local jobInfo = gSpiritJobManager.GetCurSpiritJob(self.targetJobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(urbanJobCfg)
	local progress = jobInfo.Exp / levelCfg.Exp

	self.bindData.progressBar:ProgressToValue(progress)

	self.bindData.progressText = ("%d/%d"):format(jobInfo.Exp, levelCfg.Exp)
end

function M:RefreshJobListView()
	local jobIdList = gSpiritJobManager:GetJobData(self.targetJobId)
	self.jobViewDataList = {}

	for _, jobId in pairs(jobIdList) do
		table.insert(self.jobViewDataList, {
			id = jobId
		})
	end

	self.bindData.list:SetSimpleList(#self.jobViewDataList)
end

function M:OnTalentTreeClick()
	gMainPageManager:TalentTreeOpenTrigger()
end

function M:OnRenderItem(btn, csIndex)
	local data = self.jobViewDataList[csIndex + 1]

	gSpiritJobManager:OnRenderJobPathItem(btn, csIndex, data)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end
