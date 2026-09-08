-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityPopUpStore.lua
-- Decompiled from: 01135_UrbanAbilityPopUpStore.lua_4a27de9a2bff.luajit

C_UrbanAbilityPopUpStore = DefClass("C_UrbanAbilityPopUpStore", C_UrbanAbilityPopUpStore, C_StoreGroup)
GroupName2Class.UrbanAbilityPopUpStore = C_UrbanAbilityPopUpStore
local M = C_UrbanAbilityPopUpStore

M.ctor = function(self)
	self.Type = {
		["\\xf8\\xf9=17\\xc8"] = 0,
		["o\\x8f\\x86\\x88\\x93"] = 2,
		["|y툴)\\x8c-\\xe6\\xc6"] = 1
	}
end

M.OnAwake = function(self)
	self.bindData.badge:SetActive(false)
	self.bindData.abilityHome:SetActive(false)
	self.bindData.occupation:SetActive(false)

	local msgEvents = {
		[gEventConstants.ON_URBAN_ABILITY_POPUP] = self:CreateAction("OnUrbanAbilityPopup")
	}

	self:RegisterMessageEvents(msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnUrbanAbilityPopup = function(self, eventId, data)
	if data.type ~= self.Type.ABILITY then
		self.bindData.abilityHome:SetActive(true)
		self:SetAbilityHomeData(data)
	elseif data.type ~= self.Type.BADGE then
		self.bindData.badge:SetActive(true)
		self:SetBadgeData(data)
	elseif data.type ~= self.Type.OCCUPATION then
		self.bindData.occupation:SetActive(true)
		self:SetOccupationData(data)
	end
end

M.SetOccupationData = function(self, data)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.info.Job)

	if not cfg or cfg.PreJob ~= 0 then
		self.bindData.occupation:SetActive(false)

		return
	end

	self.bindData.curJob.text = cfg.Name
	self.bindData.job.text = LTConfig.UrbanJobConfig.GetConfig(cfg.PreJob).Name

	self.HidePopup(self, self.Type.OCCUPATION)
end

M.SetBadgeData = function(self, data)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.info.TemplateId)

	if not cfg then
		return
	end

	self.bindData.badgeName.text = cfg.Name
	self.bindData.badgeIcon = cfg.Image

	self.HidePopup(self, self.Type.BADGE)
end

M.SetAbilityHomeData = function(self, data)
	local store = gStoreManager:GetStoreGroup("AbilityHomeTipsStore"):GetStoreByWidget(self.bindData.abilityHome)
	local aCfg = LTConfig.UrbanAbilityConfig.GetConfig(data.info.TemplateId)

	if aCfg then
		store.name = aCfg.Name .. "提升至"
	end

	store.score = data.info.Level .. "级"
	local fsCfg = LTConfig.FightSpiritConfig.GetConfig(data.spiritId)

	if fsCfg then
		store.avatarIconId = fsCfg.SBattleHeadIcon
	end

	self.HidePopup(self, self.Type.ABILITY)
end

M.HidePopup = function(self, type)
	coroutine.start(function ()
		coroutine.wait(5)

		if type ~= self.Type.BADGE and self.bindData.badge then
			self.bindData.badge:SetActive(false)
		elseif type ~= self.Type.OCCUPATION and self.bindData.occupation then
			self.bindData.occupation:SetActive(false)
		elseif type ~= self.Type.ABILITY and self.bindData.abilityHome then
			self.bindData.abilityHome:SetActive(false)
		end
	end)
end
