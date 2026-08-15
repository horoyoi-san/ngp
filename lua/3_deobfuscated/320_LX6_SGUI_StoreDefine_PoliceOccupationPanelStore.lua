C_PoliceOccupationPanelStore = DefClass("C_PoliceOccupationPanelStore", C_PoliceOccupationPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceOccupationPanelStore = C_PoliceOccupationPanelStore
local M = C_PoliceOccupationPanelStore

function M:ctor()
	self.mgr = gPoliceJobManager.panelMgr
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitClick")
	self.bindData.talentTreeBtn.luaClick = self:CreateAction("OpenTalentTree")
	self.bindData.jobList.luaSimpleRenderItem = self:CreateAction("RenderJobPathItem")
end

function M:InitView(data)
	self.mgr:RenderCurrentSpirit(self.bindData.avatar)
end

function M:OnExecuteExitAction()
	self.mgr:CloseCurrentPanel()
end

function M:ClearData()
	self.jobList = nil
end

function M:OpenTalentTree()
	gMainPageManager:TalentTreeOpenTrigger({
		jobClassId = LTConfig.UrbanJobJobClassConfig.Police
	})
end

function M:RefreshPage()
	local currentJob, jobCfg = gSpiritJobManager:GetAvailableJobByClass(LTConfig.UrbanJobJobClassConfig.Police)
	self.bindData.jobNameLabel = jobCfg.Name
	local spiritTid = gSpiritManager:GetCurFirstSpiritTid()
	local levelCfg = gSpiritJobManager:GetLevelData(jobCfg, spiritTid)
	local level = levelCfg and levelCfg.Level or 1
	self.bindData.levelText = string.format("Lv%d", level or 1)
	self.bindData.jobProgress.maxValue = levelCfg.Exp

	self.bindData.jobProgress:ProgressToValue(currentJob.Exp, 0)

	self.bindData.showTalent = self:CanShowTalentTree() and 1 or 0
	self.jobList = self:GetJobListByClassId(LTConfig.UrbanJobJobClassConfig.Police)

	self.bindData.jobList:SetSimpleList(#self.jobList)
end

function M:CanShowTalentTree()
	local systemUnlockId = LTConfig.SystemUnlockConfig.PoliceTalent

	if systemUnlockId > 0 then
		return gSystemUnlockMgr:IsUnlock(systemUnlockId) and gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.TalentTreeId)
	else
		return gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.TalentTreeId)
	end
end

function M:GetJobListByClassId(classId)
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Police)
	local jobList = {}

	for i = 0, LTConfig.UrbanJobConfig.count - 1 do
		local cfg = LTConfig.UrbanJobConfig.LoadAt(i)

		if cfg.JobClass == classId then
			local ele = {
				id = cfg.Id,
				isNow = cfg.Id <= (targetJobId or 0)
			}

			table.insert(jobList, ele)
		end
	end

	return jobList
end

function M:RenderJobPathItem(btn, index)
	local data = self.jobList[index + 1]

	if data then
		gSpiritJobManager:OnRenderJobPathItem(btn, index, data)
	end
end
