C_UrbanAbilityOccupationTipsStore = DefClass("C_UrbanAbilityOccupationTipsStore", C_UrbanAbilityOccupationTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupationTipsStore = C_UrbanAbilityOccupationTipsStore
local M = C_UrbanAbilityOccupationTipsStore

function M:ctor()
	self.State = {
		YingPin = 0,
		ShengJi = 1
	}
	self.aniNameShengji = "S_Vx_UrbanAbilityOccupationTips_open_shengji"
	self.aniNameYingPin = "S_Vx_UrbanAbilityOccupationTips_open_yingpin"
end

function M:OnAwake()
	self.bindData.list.luaRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.button.luaClick = self:CreateAction("OnBtnClick")
end

function M:OnShow(panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex
	self.jobId = args.jobId
	self.lastJobId = args.lastJobId
	self.isHistoryJob = args.isHistoryJob
	gSpiritManager.occupationTips_JobId = nil
	gSpiritManager.occupationTips_PopUpId = nil

	self:InitView()
	self:SetData()
end

function M:OnClose()
	return
end

function M:SetData()
	local cfg = LTConfig.UrbanJobConfig.GetConfig(self.jobId)

	if not cfg then
		return
	end

	local aniName = ""

	if not self.isHistoryJob and cfg.PreJob > 0 then
		aniName = self.aniNameShengji
		local lastCfg = LTConfig.UrbanJobConfig.GetConfig(cfg.PreJob)
		self.bindData.title1.text = lastCfg.Name
		self.bindData.title2.text = cfg.Name
	else
		aniName = self.aniNameYingPin
		self.bindData.state = self.State.YingPin
		self.bindData.title.text = cfg.Name
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, aniName)

	local list = {}

	for i, v in pairs(cfg.BriefDescription) do
		local info = {
			id = v.Id,
			selected = false,
			des = v
		}

		table.insert(list, info)
	end

	self.bindData.list:SetList(list)

	local fsCfg = LTConfig.FightSpiritConfig.GetConfig(gSpiritManager:GetCurFirstSpiritTid())

	if not fsCfg then
		return
	end

	local head = gStoreManager:GetStoreGroup("HeadAvatarStore"):GetStoreByWidget(self.bindData.head)
	head.headIcon = fsCfg.SHeadIconID
	head.bgColor = Color.NewByStr(fsCfg.CharListTemplateBgColor)
end

function M:InitView()
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		gPanelManager:Close(self.panelId)
	end)
end

function M:OnRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationTemplateStore"):GetStoreByWidget(btn)
	store.text.text = data.des.description
end

function M:OnBtnClick()
	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL, {
		tab = 2
	})
end
