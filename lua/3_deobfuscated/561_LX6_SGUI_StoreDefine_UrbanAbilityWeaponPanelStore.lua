C_UrbanAbilityWeaponPanelStore = DefClass("C_UrbanAbilityWeaponPanelStore", C_UrbanAbilityWeaponPanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityWeaponPanelStore = C_UrbanAbilityWeaponPanelStore
local M = C_UrbanAbilityWeaponPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityPanelStore")
	self.bindData.attributeList.luaRenderItem = self:CreateAction("OnRenderAttributeItem")
	self.bindData.freeList.luaRenderItem = self:CreateAction("OnRenderWeaponItem")

	function self.bindData.freeList.onGetTIndex(_)
		return 0
	end

	self.bindData.skillList.luaRenderItem = self:CreateAction("OnRenderSkillItem")
	local msgEvents = {
		[gEventConstants.ON_CHANGE_SPIRITVIEW_DATA] = self:CreateAction("ChangeSpiriViewData")
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnEnable()
	self.lastSelect = nil
	self.curSpiritId = self.urbanAbilityStore:GetCurSpiritTid()

	self:Refresh()
end

function M:SetAttrs()
	local data = gUrbanAbilityManager:GetUrbanPanelData(self.curSpiritId)
	local list = {}

	table.insert(list, {
		tIndex = 0,
		id = LTConfig.AttributeNameConfig.MaxHp,
		value = data.MaxHp
	})
	table.insert(list, {
		tIndex = 0,
		id = LTConfig.AttributeNameConfig.Dam,
		value = data.Dam
	})
	table.insert(list, {
		tIndex = 0,
		id = LTConfig.AttributeNameConfig.PhyDef,
		value = data.DefDeduct
	})
	self.bindData.attributeList:SetList(list)
end

function M:Refresh()
	self.curSpiritId = self.urbanAbilityStore:GetCurSpiritTid()
	local cfg = LTConfig.FightSpiritConfig.GetConfig(self.curSpiritId)
	self.bindData.avatarIcon = cfg.SHeadIconID
	self.bindData.bgColor = Color.NewByStr(cfg.CharListTemplateBgColor)
	self.weaponData = gSpiritManager:GetSpirit(self.curSpiritId).SpiritInfo.WeaponSlots

	self.bindData.freeList:SetList(8)
	self:SetAttrs()
end

function M:ChangeSpiriViewData(eventId, data)
	if not data.data.alreadyJoin then
		return
	end

	self:Refresh()
end

function M:OnRenderWeaponItem(btn, index)
	local store = gStoreManager:GetStoreGroup("WeaponItemTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if self.weaponData[index + 1] then
		local id = self.weaponData[index + 1].TemplateId
		local cfg = LTConfig.WeaponConfig.GetConfig(id)
		store.icon = cfg.SWeaponIconId
		store.quality = cfg.Quality
		local data = {
			btn = btn,
			id = id,
			cfg = cfg
		}
		store.button.interactable = true

		if index == 1 then
			self:OnWeaponClick(data)
		end

		store.button.luaClick = self:CreateActionWithArgs("OnWeaponClick", data)
	else
		store.icon = 0
		store.button.interactable = false
		store.quality = 0
	end
end

function M:OnRenderAttributeItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("AttributeTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.AttributeNameConfig.GetConfig(data.id)
	local showConfig = LTConfig.AttributeNameShowAttributeConfig.GetConfig(data.id)
	store.icon = showConfig.SIconId
	store.name = cfg.AttributeName
	store.value = math.ceil(data.value)
end

function M:OnWeaponClick(data)
	self.curWeaponData = data

	if self.lastSelect then
		self.lastSelect:SetSelected(false)
	end

	data.btn:SetSelected(true)

	self.lastSelect = data.btn

	self:SetRightData(data)
end

function M:SetRightData(data)
	local cfg = LTConfig.UrbanAttributeConfig.GetConfig(data.cfg.sixDimBonus)

	if cfg then
		self.bindData.tag = cfg.Name
	else
		self.bindData.tag = ""
	end

	if string.is_null_or_empty(data.cfg.Type) then
		self.bindData.type = ""
	else
		self.bindData.type = data.cfg.Type
	end

	self.bindData.name = data.cfg.Name
	self.bindData.atk = math.ceil(data.cfg.AttackPower)
	self.bindData.speed = math.ceil(data.cfg.AttackSpeed)
	self.bindData.weaponIcon = data.cfg.SWeaponIconId
	self.bindData.curSelectQuality = data.cfg.Quality

	self:SetSkillList(data.cfg)
end

function M:SetSkillList(cfg)
	local skillList = {}

	if cfg.CommonSkill then
		table.insert(skillList, {
			defaultIconId = 28004195,
			type = LTConfig.TextCommonTextConfig.GetConfig(74003511).Text,
			id = cfg.CommonSkill
		})
	end

	if cfg.HeavyCommonSkill then
		table.insert(skillList, {
			defaultIconId = 28000923,
			type = LTConfig.TextCommonTextConfig.GetConfig(74003512).Text,
			id = cfg.HeavyCommonSkill
		})
	end

	if cfg.ActiveSkill then
		table.insert(skillList, {
			defaultIconId = 28000889,
			type = LTConfig.TextCommonTextConfig.GetConfig(74003513).Text,
			id = cfg.ActiveSkill
		})
	end

	if cfg.UniqueSkill then
		table.insert(skillList, {
			defaultIconId = 28004193,
			type = LTConfig.TextCommonTextConfig.GetConfig(74003514).Text,
			id = cfg.UniqueSkill
		})
	end

	if cfg.DodgeSkill then
		table.insert(skillList, {
			defaultIconId = 28001009,
			type = LTConfig.TextCommonTextConfig.GetConfig(74003515).Text,
			id = cfg.DodgeSkill
		})
	end

	local list = {}

	table.insert(list, {
		id = 0,
		tIndex = 0
	})

	for i, v in pairs(skillList) do
		local info = {
			id = v.id,
			type = v.type,
			defaultIconId = v.defaultIconId,
			selected = false,
			tIndex = 1
		}

		table.insert(list, info)
	end

	self.bindData.skillList:SetList(list)
end

function M:OnRenderSkillItem(btn, index, data)
	if data.tIndex == 0 then
		local store = gStoreManager:GetStoreGroup("WeaponDesStore"):GetStoreByWidget(btn)
		store.des = ""

		return
	end

	local store = gStoreManager:GetStoreGroup("SkillTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.SkillConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	store.tag = data.type
	store.name = cfg.SkillName

	if string.is_null_or_empty(cfg.Explain[1]) then
		store.text = ""
	else
		store.text = cfg.Explain[1]
	end

	if cfg.SSkillImageId and cfg.SSkillImageId > 0 then
		store.icon = cfg.SSkillImageId
	else
		store.icon = data.defaultIconId
	end

	local args = {
		data = data,
		cfg = cfg
	}
	store.button.luaClick = self:CreateActionWithArgs("OnSkillClick", args)
end

function M:OnSkillClick(args)
	local store = gStoreManager:GetStoreGroup("SkillDetailTipsStore")

	if string.is_null_or_empty(args.cfg.Explain[1]) then
		gUrbanAbilityManager.SkillDetailTips = " "
	else
		gUrbanAbilityManager.SkillDetailTips = args.cfg.Explain[1]
	end

	store:SetData()
end
