C_UrbanAbilityActivePanelStore = DefClass("C_UrbanAbilityActivePanelStore", C_UrbanAbilityActivePanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityActivePanelStore = C_UrbanAbilityActivePanelStore
local M = C_UrbanAbilityActivePanelStore

function M:OnAwake()
	self.isInitTipsStore = false

	self.bindData.tips.gameObject:SetActive(false)
	self.bindData.progress:ProgressToValue(0)

	self.bindData.list.luaRenderItem = self:CreateAction("OnRenderItem")
end

function M:OnEnable()
	self:SetJobData()
end

function M:OnShow(panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex

	self:InitView()
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

function M:SetJobData()
	self.jobId = gSpiritJobManager:GetCurJobId()
	self.spiritViewData = gSpiritManager:GetSpirit(gSpiritManager:GetCurFirstSpiritTid())
	local serverdata = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[self.jobId]
	local cfg = LTConfig.UrbanJobConfig.GetConfig(self.jobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)

	if cfg and serverdata then
		self.bindData.title.text = cfg.Name

		self.bindData.progress:ProgressToValue(serverdata.Exp / levelCfg.Exp)

		self.bindData.progressText.text = "(" .. serverdata.Exp .. "/" .. levelCfg.Exp .. ")"
	end

	local abilityList = gSpiritJobManager:GetBadgeList(self.jobId, self.spiritViewData.SpiritInfo)
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
	store.button.luaClick = self:CreateActionWithArgs("OnItemClick", data)
end

function M:OnItemClick(data)
	self.bindData.tips.gameObject:SetActive(true)
	self:SetBadgeTips(data.id)
end

function M:ShowBadgeTips(isShow)
	self.bindData.tips.gameObject:SetActive(isShow)
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
end
