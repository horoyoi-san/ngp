C_UrbanAbilityOccupationConentStore = DefClass("C_UrbanAbilityOccupationConentStore", C_UrbanAbilityOccupationConentStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupationConentStore = C_UrbanAbilityOccupationConentStore
local M = C_UrbanAbilityOccupationConentStore

function M:ctor()
	return
end

function M:OnAwake()
	self.parentJobStore = gStoreManager:GetStoreGroup("UrbanAbilityOccupation1PanelStore")
	self.parentJobPathStore = gStoreManager:GetStoreGroup("UrbanAbilityOccupationPanelStore")
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityPanelStore")
	self.bindData.list.luaRenderItem = self:CreateAction("OnRenderItem")

	if self.bindData.pathBtn then
		self.bindData.pathBtn.luaClick = self:CreateAction("OnPathBtnClick")
	end
end

function M:OnDestroy()
	self.spiritViewData = nil
end

function M:OnEnable()
	self:DefaultSelect()
end

function M:DefaultSelect()
	self:SetJobData(self.urbanAbilityStore:GetCurSpiritTid())
end

function M:SetJobData(tid, jobId)
	self.jobId = jobId
	self.spiritViewData = gSpiritManager:GetSpirit(tid)

	if not self.jobId then
		self.jobId = self.parentJobStore.jobId
	end

	local serverdata = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[self.jobId]
	local cfg = LTConfig.UrbanJobConfig.GetConfig(self.jobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)

	if cfg and serverdata then
		local progress = serverdata.Exp / levelCfg.Exp

		if progress and progress > 0 then
			self.bindData.progress:ProgressToValue(progress)
		else
			self.bindData.progress:ProgressToValue(0)
		end

		self.bindData.progessText.text = "(" .. serverdata.Exp .. "/" .. levelCfg.Exp .. ")"
	end

	local abilityList = gSpiritJobManager:GetActivateBadgeListByJobPath(self.jobId, self.spiritViewData.SpiritInfo)
	local list = {}

	for i, v in pairs(abilityList) do
		local info = {
			id = v.Id,
			selected = false
		}

		table.insert(list, info)
	end

	self.bindData.list:SetList(list)
end

function M:OnRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadge2TemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)
	store.icon = cfg.Image

	if self.spiritViewData.SpiritInfo.InfoBadge.Badges[data.id].Active then
		store.active = 0
	else
		store.active = 1
	end

	store.button.luaClick = self:CreateActionWithArgs("OnItemClick", data)
end

function M:OnItemClick(data)
	self.jobId = data.id

	self.parentJobStore:ShowBadgeTips(true)
	self.parentJobStore:SetBadgeTips(data.id)
end

function M:OnPathBtnClick()
	if self.parentJobStore.jobId and self.parentJobStore.jobId ~= LTConfig.UrbanJobConfig.Jobless then
		gMessageManager:SendMessage(gEventConstants.ON_CHANGE_JOBTAB, 3)
	end
end
