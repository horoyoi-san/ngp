C_UrbanAbilityPopUpStore = DefClass("C_UrbanAbilityPopUpStore", C_UrbanAbilityPopUpStore, C_StoreGroup)
GroupName2Class.UrbanAbilityPopUpStore = C_UrbanAbilityPopUpStore
local M = C_UrbanAbilityPopUpStore

function M:ctor()
	self.Type = {
		ABILITY = 0,
		BADGE = 2,
		OCCUPATION = 1
	}
end

function M:OnAwake()
	self.bindData.badge:SetActive(false)
	self.bindData.abilityHome:SetActive(false)
	self.bindData.occupation:SetActive(false)

	local msgEvents = {
		[gEventConstants.ON_URBAN_ABILITY_POPUP] = self:CreateAction("OnUrbanAbilityPopup")
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnUrbanAbilityPopup(eventId, data)
	if data.type == self.Type.ABILITY then
		self.bindData.abilityHome:SetActive(true)
		self:SetAbilityHomeData(data)
	elseif data.type == self.Type.BADGE then
		self.bindData.badge:SetActive(true)
		self:SetBadgeData(data)
	elseif data.type == self.Type.OCCUPATION then
		self.bindData.occupation:SetActive(true)
		self:SetOccupationData(data)
	end
end

function M:SetOccupationData(data)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.info.Job)

	if not cfg or cfg.PreJob == 0 then
		self.bindData.occupation:SetActive(false)

		return
	end

	self.bindData.curJob.text = cfg.Name
	self.bindData.job.text = LTConfig.UrbanJobConfig.GetConfig(cfg.PreJob).Name

	self:HidePopup(self.Type.OCCUPATION)
end

function M:SetBadgeData(data)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.info.TemplateId)

	if not cfg then
		return
	end

	self.bindData.badgeName.text = cfg.Name
	self.bindData.badgeIcon = cfg.Image

	self:HidePopup(self.Type.BADGE)
end

function M:SetAbilityHomeData(data)
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

	self:HidePopup(self.Type.ABILITY)
end

function M:HidePopup(type)
	coroutine.start(function ()
		coroutine.wait(5)

		if type == self.Type.BADGE and self.bindData.badge then
			self.bindData.badge:SetActive(false)
		elseif type == self.Type.OCCUPATION and self.bindData.occupation then
			self.bindData.occupation:SetActive(false)
		elseif type == self.Type.ABILITY and self.bindData.abilityHome then
			self.bindData.abilityHome:SetActive(false)
		end
	end)
end
