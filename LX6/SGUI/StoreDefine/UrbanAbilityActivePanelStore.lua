-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityActivePanelStore.lua
-- Decompiled from: 01198_UrbanAbilityActivePanelStore.lua_a31ffb03f864.luajit

C_UrbanAbilityActivePanelStore = DefClass("C_UrbanAbilityActivePanelStore", C_UrbanAbilityActivePanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityActivePanelStore = C_UrbanAbilityActivePanelStore
local M = C_UrbanAbilityActivePanelStore

M.OnAwake = function(self)
	self.isInitTipsStore = false

	self.bindData.tips.gameObject:SetActive(false)
	self.bindData.progress:ProgressToValue(0)

	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
end

M.OnEnable = function(self)
	self.SetJobData(self)
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex

	self.InitView(self)
end

M.InitView = function(self)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		gPanelManager:Close(self.panelId)
	end)
end

M.OnClose = function(self)
end

M.SetJobData = function(self)
	self.jobId = gSpiritJobManager:GetCurJobId()
	self.spiritViewData = gSpiritManager:GetSpirit(gSpiritManager:GetCurFirstSpiritTid())
	local serverdata = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[self.jobId]
	local cfg = LTConfig.UrbanJobConfig.GetConfig(self.jobId)
	local levelCfg = nil

	if self.jobId ~= LTConfig.UrbanJobConfig.Jobless then
		levelCfg = LTConfig.UrbanJobLevelConfig.GetConfig(1)
	else
		levelCfg = gSpiritJobManager:GetLevelConfig(cfg)
	end

	if not levelCfg then
		print_error("@linminghe --- 角色界面,levelCfg is nil", self.jobId)
	end

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

	self._listData = list

	self.bindData.list:SetSimpleList(#list)
end

M.OnRenderItem = function(self, btn, index)
	local data = self._listData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadge2TemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)
	store.icon = cfg.Image
	store.button.luaClick = self:CreateActionWithArgs("OnItemClick", data)
end

M.OnItemClick = function(self, data)
	self.bindData.tips.gameObject:SetActive(true)
	self:SetBadgeTips(data.id)
end

M.ShowBadgeTips = function(self, isShow)
	self.bindData.tips.gameObject:SetActive(isShow)
end

M.SetBadgeTips = function(self, id)
	if not self.isInitTipsStore then
		self.tipsStore = gStoreManager:GetStoreGroup("UrbanAbilityTips2Store"):GetStoreByWidget(self.bindData.tips)
		self.tipsStore.closeBtn.luaClick = self:CreateActionWithArgs("ShowBadgeTips", false)
		self.isInitTipsStore = true
	end

	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(id)
	self.tipsStore.name.text = cfg.Name
	self.tipsStore.des.text = cfg.Description
end
