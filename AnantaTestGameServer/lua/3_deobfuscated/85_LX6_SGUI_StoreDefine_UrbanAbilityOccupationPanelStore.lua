C_UrbanAbilityOccupationPanelStore = DefClass("C_UrbanAbilityOccupationPanelStore", C_UrbanAbilityOccupationPanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupationPanelStore = C_UrbanAbilityOccupationPanelStore
local M = C_UrbanAbilityOccupationPanelStore

function M:ctor()
	self.TypeCtrl = {
		Now = 1,
		Lock = 2,
		Unlock = 0,
		MissonLock = 3
	}
end

function M:OnAwake()
	self.isInitTipsStore = false
	self.JobStore = {}

	self.bindData.tips.gameObject:SetActive(false)

	self.bindData.list.luaRenderItem = self:CreateAction("OnRenderItem")
	local msgEvents = {
		[gEventConstants.On_SYNC_SPIRIT_JOBINFO] = self:CreateAction("SyncSpiritJobInfo")
	}
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")

	self:RegisterMessageEvents(msgEvents)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnEnable()
	self:SetJobData()
end

function M:OnDisable()
	self.bindData.tips.gameObject:SetActive(false)
end

function M:SyncSpiritJobInfo()
	self:SetJobData()
end

function M:OnRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanOccupationTemplateStore"):GetStoreByWidget(btn)
	store.list.luaRenderItem = self:CreateAction("OnRenderBadgeItem")
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.id)
	local serverData = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[data.id]
	store.name.text = cfg.Name
	store.text.text = ""

	if self.jobId == data.id then
		store.typeCtrl = self.TypeCtrl.Now

		if serverData then
			local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)
			store.text.text = LTConfig.TextCommonTextConfig.GetConfig(74003504).Text .. "(" .. serverData.Exp .. "/" .. levelCfg.Exp .. ")"
		end
	elseif self.jobId < data.id then
		store.typeCtrl = self.TypeCtrl.Lock
	elseif data.id < self.jobId then
		store.typeCtrl = self.TypeCtrl.Unlock
	end

	if self.firstId == data.id then
		store.arrows.gameObject:SetActive(false)
	else
		store.arrows.gameObject:SetActive(true)
	end

	if self.lastId == data.id then
		store.nextLevel.gameObject:SetActive(false)
	else
		store.nextLevel.gameObject:SetActive(true)
	end

	local list = {}
	local badgeList = gSpiritJobManager:GetBadgeList(data.id, self.spiritViewData.SpiritInfo)

	for i, v in pairs(badgeList) do
		local info = {
			id = v.Id,
			selected = false
		}

		table.insert(list, info)
	end

	store.list:SetList(list)

	self.JobStore[data.id] = store.list
end

function M:SetJobData()
	self.lastSelectJobId = 0
	self.jobId = gStoreManager:GetStoreGroup("UrbanAbilityOccupation1PanelStore").jobId
	local urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityPanelStore")
	self.spiritViewData = gSpiritManager:GetSpirit(urbanAbilityStore:GetCurSpiritTid())
	self.bindData.name.text = self.spiritViewData.Name
	self.spiritJobInfo = self.spiritViewData.SpiritInfo.SpiritJobInfo
	local cfg = LTConfig.UrbanJobConfig.GetConfig(self.jobId)

	if cfg then
		self.bindData.occupation.text = cfg.JobTypeName
	end

	local jobList = gSpiritJobManager:GetJobData(self.jobId)
	local list = {}

	for i, v in pairs(jobList) do
		local info = {
			id = v,
			selected = false
		}

		table.insert(list, info)
	end

	self.firstId = list[1].id
	self.lastId = list[#list].id

	self.bindData.list:SetList(list)
end

function M:OnRenderBadgeItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadge2TemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)
	store.icon = cfg.Image
	store.button.luaClick = self:CreateActionWithArgs("OnBadgeItemClick", cfg)
end

function M:SetBadgeTips(id)
	if not self.isInitTipsStore then
		self.tipsStore = gStoreManager:GetStoreGroup("UrbanAbilityTips2Store"):GetStoreByWidget(self.bindData.tips)
		self.tipsStore.closeBtn.luaClick = self:CreateActionWithArgs("ShowBadgeTips", false)
		self.isInitTipsStore = true
	end

	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(id)
	self.tipsStore.name.text = cfg.Name
	self.tipsStore.des.text = cfg.Description
	self.tipsStore.condition.text = ""
end

function M:ShowBadgeTips(isShow)
	self.bindData.tips.gameObject:SetActive(isShow)
end

function M:OnCloseBtnClick()
	gMessageManager:SendMessage(gEventConstants.ON_CHANGE_JOBTAB, 1)
end

function M:OnBadgeItemClick(cfg)
	self.bindData.tips.gameObject:SetActive(true)
	self:SetBadgeTips(cfg.Id)

	if self.lastSelectJobId ~= 0 and cfg.JobId ~= self.lastSelectJobId then
		local list = self.JobStore[self.lastSelectJobId]

		list:DeselectAll()
	end

	self.lastSelectJobId = cfg.JobId
end
