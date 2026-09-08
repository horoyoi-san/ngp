-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityOccupationPanelStore.lua
-- Decompiled from: 01165_UrbanAbilityOccupationPanelStore.lua_3c4604d16f11.luajit

C_UrbanAbilityOccupationPanelStore = DefClass("C_UrbanAbilityOccupationPanelStore", C_UrbanAbilityOccupationPanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupationPanelStore = C_UrbanAbilityOccupationPanelStore
local M = C_UrbanAbilityOccupationPanelStore

M.ctor = function(self)
	self.TypeCtrl = {
		["\\xa0gq"] = 1,
		["V-~P"] = 2,
		[")F\\x9d\\x81\\x80J"] = 0,
		["~Sݮ\\x8b\\x94\\xca\\xe3"] = 3
	}
end

M.OnAwake = function(self)
	self.isInitTipsStore = false
	self.JobStore = {}

	self.bindData.tips.gameObject:SetActive(false)

	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	local msgEvents = {
		[gEventConstants.On_SYNC_SPIRIT_JOBINFO] = self:CreateAction("SyncSpiritJobInfo")
	}
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")

	self:RegisterMessageEvents(msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnEnable = function(self)
	self.SetJobData(self)
end

M.OnDisable = function(self)
	self.bindData.tips.gameObject:SetActive(false)
end

M.SyncSpiritJobInfo = function(self)
	self.SetJobData(self)
end

M.OnRenderItem = function(self, btn, index)
	local data = self._listData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanOccupationTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.id)
	local serverData = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[data.id]
	store.name.text = cfg.Name
	store.text.text = ""

	if self.jobId ~= data.id then
		store.typeCtrl = self.TypeCtrl.Now

		if serverData then
			local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)
			store.text.text = LTConfig.TextCommonTextConfig.GetConfig(74003504).Text .. "(" .. serverData.Exp .. "/" .. levelCfg.Exp .. ")"
		end
	elseif self.jobId >= data.id then
		store.typeCtrl = self.TypeCtrl.Lock
	elseif data.id >= self.jobId then
		store.typeCtrl = self.TypeCtrl.Unlock
	end

	if self.firstId ~= data.id then
		store.arrows.gameObject:SetActive(false)
	else
		store.arrows.gameObject:SetActive(true)
	end

	if self.lastId ~= data.id then
		store.nextLevel.gameObject:SetActive(false)
	else
		store.nextLevel.gameObject:SetActive(true)
	end

	local badgeList = gSpiritJobManager:GetBadgeList(data.id, self.spiritViewData.SpiritInfo)
	local list = {}

	for i, v in pairs(badgeList) do
		local info = {
			id = v.Id,
			selected = false
		}

		table.insert(list, info)
	end

	store.list.luaSimpleRenderItem = function(badgeBtn, badgeIndex)
		local badgeData = list[badgeIndex + 1]
		local badgeStore = gStoreManager:GetStoreGroup("UrbanAbilityBadge2TemplateStore"):GetStoreByWidget(badgeBtn)
		local cfg = LTConfig.UrbanBadgeConfig.GetConfig(badgeData.id)
		badgeStore.icon = cfg.Image
		badgeStore.button.luaClick = self:CreateActionWithArgs("OnBadgeItemClick", cfg)
	end

	store.list:SetSimpleList(#list)

	self.JobStore[data.id] = store.list
end

M.SetJobData = function(self)
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
	self._listData = list

	self.bindData.list:SetSimpleList(#list)
end

M.OnRenderBadgeItem = function(self, btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadge2TemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)
	store.icon = cfg.Image
	store.button.luaClick = self:CreateActionWithArgs("OnBadgeItemClick", cfg)
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
	self.tipsStore.condition.text = ""
end

M.ShowBadgeTips = function(self, isShow)
	self.bindData.tips.gameObject:SetActive(isShow)
end

M.OnCloseBtnClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_CHANGE_JOBTAB, 1)
end

M.OnBadgeItemClick = function(self, cfg)
	self.bindData.tips.gameObject:SetActive(true)
	self:SetBadgeTips(cfg.Id)

	if self.lastSelectJobId == 0 and cfg.JobId == self.lastSelectJobId then
		local list = self.JobStore[self.lastSelectJobId]

		list.DeselectAll(list)
	end

	self.lastSelectJobId = cfg.JobId
end
