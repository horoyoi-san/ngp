C_UrbanAbilityEXPTipsStore = DefClass("C_UrbanAbilityEXPTipsStore", C_UrbanAbilityEXPTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityEXPTipsStore = C_UrbanAbilityEXPTipsStore
local M = C_UrbanAbilityEXPTipsStore

function M:ctor()
	return
end

function M:OnShow(panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex
	self.jobExpInfo = args.JobExpInfo

	self:InitView()
	self:SetData()
end

function M:SetData()
	local jobClassId = 0
	local exp = 0

	for k, v in pairs(self.jobExpInfo) do
		jobClassId = k
		exp = v
	end

	local curJob, cfg = gSpiritJobManager:GetAvailableJobByClass(jobClassId)

	if not curJob then
		print_error("[UrbanAbilityEXPTips] not curJob jobClassId=", jobClassId)

		return
	end

	self.bindData.titleLabel = cfg.Name
	self.bindData.addexp = "+" .. exp
	local curExp = curJob.Exp
	local maxExp = cfg.Exp
	self.bindData.progress.maxValue = maxExp

	self.bindData.progress:ProgressToValue(curExp)
end

function M:InitView()
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		gPanelManager:Close(self.panelId)
	end)
end

function M:OnClose()
	return
end
