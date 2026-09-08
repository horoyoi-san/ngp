-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosInfoTooltipStore.lua
-- Decompiled from: 01468_ChaosInfoTooltipStore.lua_85d06681d320.luajit

C_ChaosInfoTooltipStore = DefClass("C_ChaosInfoTooltipStore", C_ChaosInfoTooltipStore, C_StoreGroup)
GroupName2Class.ChaosInfoTooltipStore = C_ChaosInfoTooltipStore
local M = C_ChaosInfoTooltipStore
local EquipType = {
	["+M\\x90\\x9e\\x8cO"] = 3,
	["X-yB"] = 1,
	["Y#pK"] = 2,
	["(I\\x9d\\x8b\\x8dU"] = 4
}

M.ctor = function(self)
	self.curChaosData = nil
	self.lastSelectedSkill = nil
	self.lastSelected = nil
	self.EquipType = EquipType
	self.parentPanel = nil
	self.tabListData = {}
	self.attributeListData = {}
	self.bodySizeBtnListData = {}
	self.campBtnListData = {}
	self.weaponBtnListData = {}
	self.equipListData = {}
end

M.OnAwake = function(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.curChaosData = nil
	self.lastSelectedSkill = nil
	self.lastSelected = nil
	self.tabData = nil
	self.parentPanel = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.SetParentPanel = function(self, parentPanel)
	self.parentPanel = parentPanel
end

M.RegisterWidget = function(self)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderChaosInfoTab")
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, "OnChaosInfoTabChanged")
	self.bindData.tabList.onGetTIndex = self.CreateAction(self, "OnGetTabListTIndex")
	self.bindData.attributeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderChaosAttributeItem")
	self.bindData.attributeList.onGetTIndex = self.CreateAction(self, "OnGetAttributeListTIndex")

	self.bindData.bodySizeBtnList.luaSimpleRenderItem = function(item, index)
		self:OnRenderSkillItem(item, index, "bodySizeBtnList")
	end

	self.bindData.bodySizeBtnList.luaSimpleClick = function(item, index)
		self:OnClickSkillItem(item, index, "bodySizeBtnList")
	end

	self.bindData.bodySizeBtnList.onGetTIndex = self.CreateAction(self, "OnGetBodySizeBtnListTIndex")

	self.bindData.CampBtnList.luaSimpleRenderItem = function(item, index)
		self:OnRenderSkillItem(item, index, "campBtnList")
	end

	self.bindData.CampBtnList.luaSimpleClick = function(item, index)
		self:OnClickSkillItem(item, index, "campBtnList")
	end

	self.bindData.CampBtnList.onGetTIndex = self.CreateAction(self, "OnGetCampBtnListTIndex")

	self.bindData.weaponBtnList.luaSimpleRenderItem = function(item, index)
		self:OnRenderSkillItem(item, index, "weaponBtnList")
	end

	self.bindData.weaponBtnList.luaSimpleClick = function(item, index)
		self:OnClickSkillItem(item, index, "weaponBtnList")
	end

	self.bindData.weaponBtnList.onGetTIndex = self.CreateAction(self, "OnGetWeaponBtnListTIndex")

	if self.bindData.closeTipBtn then
		self.bindData.closeTipBtn.luaClick = self.CreateAction(self, "OnClickCloseSkillTipBtn")
	end

	self.bindData.talentSkillBtn.luaClick = self.CreateAction(self, "OnClickTalentSkillItem")
	self.bindData.talentSkillBtn.luaInvalidClick = self.CreateAction(self, "OnClickTalentSkillItem")
	self.bindData.lockBtn.luaClick = self.CreateAction(self, "OnClickLockBtn")

	if self.bindData.gamePadSwitchBtn then
		self.bindData.gamePadSwitchBtn.luaClick = self.CreateAction(self, "OnChaosInfoTabChangedByGamePad")
	end
end

M.OnRenderEquipItem = function(self, btn, index)
	local data = self.equipListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosEquipItem"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = nil

	if data.belong ~= self.EquipType.Body then
		cfg = LTConfig.ChaosMasterBodyConfig.GetConfig(self.curChaosData.Body)
	elseif data.belong ~= self.EquipType.Camp then
		cfg = LTConfig.ChaosMasterCampConfig.GetConfig(self.curChaosData.Camp)
	elseif data.belong ~= self.EquipType.Weapon then
		cfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(self.curChaosData.Weapon)
	end

	if not cfg then
		store.isEmptyCtrl = 0

		return
	end

	store.isEmptyCtrl = 1
	store.quality = (cfg.Quality or 3) - 3
	store.iconId = cfg.IconID or 0
	local typeText = ""

	if data.belong ~= self.EquipType.Body then
		typeText = LTConfig.TextScriptTextConfig.GetConfig(89901214).Text
	elseif data.belong ~= self.EquipType.Camp then
		typeText = LTConfig.TextScriptTextConfig.GetConfig(89901215).Text
	elseif data.belong ~= self.EquipType.Weapon then
		typeText = LTConfig.TextScriptTextConfig.GetConfig(89901201).Text
	end

	store.typeText = typeText
	store.equipType = data.belong
	btn.luaRenderTooltip = self.CreateAction(self, "OnChaosPartItemRenderTooltip")
end

M.RefreshChaosInfo = function(self, chaosId, bodyCallBack)
	if not self.bindData then
		return
	end

	if self.lastSelectedSkill then
		self.lastSelectedSkill.isSelected = false
		self.lastSelectedSkill = nil
		self.lastSelected = nil
	end

	self.curChaosData = gBattlePetsMgr:GetPetDataById(chaosId)

	if not self.curChaosData then
		return
	end

	local limboChaConfig = LTConfig.ChaosMasterLimboChaConfig.GetConfig(self.curChaosData.LimboChaId)

	if not limboChaConfig then
		return
	end

	local bodyCfg = LTConfig.ChaosMasterBodyConfig.GetConfig(self.curChaosData.Body)
	local campCfg = LTConfig.ChaosMasterCampConfig.GetConfig(self.curChaosData.Camp)
	local weaponCfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(self.curChaosData.Weapon)
	self.bindData.tabCtrl = self.bindData.tabCtrl or 0
	self.bindData.showSkillTooltipCtrl = 1
	self.bindData.nameText = limboChaConfig.Name
	self.bindData.codeText = bodyCfg.BodyCode .. "-" .. campCfg.BodyCode .. "-" .. weaponCfg.BodyCode
	local roleName = gBattlePetsMgr:GetChaosRoleName(limboChaConfig)
	self.bindData.roleText = roleName
	self.bindData.lockStateCtrl = not self.curChaosData.IsLocked and 1 or 0
	self.tabData = {
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 0,
			text = LTConfig.TextScriptTextConfig.GetConfig(89901202).Text
		},
		{
			["D\\xa0\\xa6\\xaa\\xae"] = 1,
			text = LTConfig.TextScriptTextConfig.GetConfig(89901203).Text
		}
	}
	self.tabListData = self.tabData

	self.bindData.tabList:SetSimpleList(#self.tabData)

	local attrs = gBattlePetsMgr:GetChaosAttributes(self.curChaosData)
	local attrsData = gBattlePetsMgr:GetChaosAttributeList(attrs)
	self.attributeListData = attrsData

	self.bindData.attributeList:SetSimpleList(#attrsData)

	local skillCfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(limboChaConfig.TalentBuff[1] or 1)

	self:OnRenderSkillItem(self.bindData.talentSkillBtn, 0, {
		cfg = skillCfg,
		belong = self.EquipType.Talent
	})

	local bodySizeData = {}

	if bodyCfg and bodyCfg.PassiveSkill then
		for k, v in ipairs(bodyCfg.PassiveSkill) do
			local bodySkillCfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(v)

			if bodySkillCfg then
				table.insert(bodySizeData, {
					cfg = bodySkillCfg,
					belong = self.EquipType.Body
				})
			end
		end
	end

	self.bodySizeBtnListData = bodySizeData

	self.bindData.bodySizeBtnList:SetSimpleList(#bodySizeData)

	local campData = {}

	if campCfg and campCfg.PassiveSkill then
		for k, v in ipairs(campCfg.PassiveSkill) do
			local campSkillCfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(v)

			if campSkillCfg then
				table.insert(campData, {
					cfg = campSkillCfg,
					belong = self.EquipType.Camp
				})
			end
		end
	end

	self.campBtnListData = campData

	self.bindData.CampBtnList:SetSimpleList(#campData)

	local weaponData = {}

	if limboChaConfig and limboChaConfig.SkillId then
		for k, v in ipairs(limboChaConfig.SkillId) do
			local weaponSkillCfg = LTConfig.ChaosMasterSkillConfig.GetConfig(v)

			if weaponSkillCfg then
				table.insert(weaponData, {
					cfg = weaponSkillCfg,
					belong = self.EquipType.Weapon
				})
			end
		end
	end

	self.weaponBtnListData = weaponData

	self.bindData.weaponBtnList:SetSimpleList(#weaponData)

	if bodyCallBack and self.bindData.bodyDetailBtn then
		self.bindData.bodyDetailBtn.luaClick = bodyCallBack
	end
end

M.OnRenderChaosAttributeItem = function(self, item, index)
	local data = self.attributeListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosAttributeTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	gBattlePetsMgr:RefreshAttributeListItem(store, data)
end

M.OnRenderChaosInfoTab = function(self, item, index)
	local data = self.tabListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosMasterDpsTabTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.name = data.text
	item.isSelected = data.index ~= self.bindData.tabCtrl
end

M.OnRenderSkillItem = function(self, item, index, listType)
	local data = nil

	if listType ~= "bodySizeBtnList" then
		data = self.bodySizeBtnListData[index + 1]
	elseif listType ~= "campBtnList" then
		data = self.campBtnListData[index + 1]
	elseif listType ~= "weaponBtnList" then
		data = self.weaponBtnListData[index + 1]
	end

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosSkillBtn"):GetStoreByWidget(item)

	if not store then
		return
	end

	local skillCfg = nil

	if data.belong ~= self.EquipType.Weapon then
		skillCfg = data.cfg
	else
		skillCfg = data.cfg
	end

	store.iconId = skillCfg.Icon
	store.tagText = skillCfg.Name
end

M.OnChaosInfoTabChanged = function(self, item, index)
	local data = self.tabListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosMasterDpsTabTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	self.bindData.tabCtrl = data.index
	self.tabListData = self.tabData

	self.bindData.tabList:SetSimpleList(#self.tabData)
end

M.OnChaosInfoTabChangedByGamePad = function(self, item)
	self.bindData.tabCtrl = self.bindData.tabCtrl ~= 0 and 1 or 0
	self.tabListData = self.tabData

	self.bindData.tabList:SetSimpleList(#self.tabData)

	local switchBtn = gStoreManager:GetStoreGroup("ChaosGamePadSwitchTemplate"):GetStoreByWidget(self.bindData.gamePadSwitchBtn)
	switchBtn.ArrowTypeCtrl = self.bindData.tabCtrl
end

M.OnClickTalentSkillItem = function(self)
	if not self.curChaosData then
		return
	end

	local limboChaConfig = LTConfig.ChaosMasterLimboChaConfig.GetConfig(self.curChaosData.LimboChaId)

	if not limboChaConfig or not limboChaConfig.TalentBuff or #limboChaConfig.TalentBuff ~= 0 then
		return
	end

	local skillCfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(limboChaConfig.TalentBuff[1])

	if skillCfg then
		local item = self.bindData.talentSkillBtn
		local data = {
			cfg = skillCfg,
			belong = self.EquipType.Talent
		}

		if self.lastSelectedSkill and self.lastSelectedSkill ~= item then
			item.isSelected = not self.lastSelected
			self.lastSelected = item.isSelected
		end

		if item.isSelected ~= true then
			if self.lastSelectedSkill and self.lastSelectedSkill == item then
				self.lastSelectedSkill.isSelected = false
			end

			self.lastSelectedSkill = item
			self.lastSelected = item.isSelected
			self.bindData.showSkillTooltipCtrl = 0

			self.RefreshTooltip(self, data)
		else
			self.bindData.showSkillTooltipCtrl = 1
		end
	end
end

M.OnClickSkillItem = function(self, item, index, listType)
	local data = nil

	if listType ~= "bodySizeBtnList" then
		data = self.bodySizeBtnListData[index + 1]
	elseif listType ~= "campBtnList" then
		data = self.campBtnListData[index + 1]
	elseif listType ~= "weaponBtnList" then
		data = self.weaponBtnListData[index + 1]
	end

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosSkillBtn"):GetStoreByWidget(item)

	if not store then
		return
	end

	item.isSelected = not item.isSelected

	if item.isSelected ~= true then
		if self.lastSelectedSkill and self.lastSelectedSkill == item then
			self.lastSelectedSkill.isSelected = false
		end

		self.lastSelectedSkill = item
		self.lastSelected = item.isSelected
		self.bindData.showSkillTooltipCtrl = 0

		self.RefreshTooltip(self, data)
	else
		self.bindData.showSkillTooltipCtrl = 1
	end
end

M.OnGetTabListTIndex = function(self, index)
	return 0
end

M.OnGetAttributeListTIndex = function(self, index)
	return 0
end

M.OnGetBodySizeBtnListTIndex = function(self, index)
	return 0
end

M.OnGetCampBtnListTIndex = function(self, index)
	return 0
end

M.OnGetWeaponBtnListTIndex = function(self, index)
	return 0
end

M.OnGetEquipListTIndex = function(self, index)
	return 0
end

M.OnClickLockBtn = function(self, btn, data)
	self.bindData.lockStateCtrl = self.bindData.lockStateCtrl ~= 0 and 1 or 0

	gClientToGameDelegate:AskSetPokemonLockState(self.curChaosData.Id, self.bindData.lockStateCtrl ~= 0).Callback = function (e)
		if e == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(e)
		end
	end
end

M.OnClickCloseSkillTipBtn = function(self)
	self.bindData.showSkillTooltipCtrl = 1

	if self.lastSelectedSkill then
		self.lastSelectedSkill.isSelected = false
		self.lastSelectedSkill = nil
		self.lastSelected = nil
	end
end

M.RefreshTooltip = function(self, data)
	local store = gStoreManager:GetStoreGroup("ChaosSkillTooltipStore"):GetStoreByWidget(self.bindData.skillToolTip)

	if not store then
		return
	end

	local cfg = data.cfg
	local belongType = data.belong
	local belongText = ""

	if belongType ~= self.EquipType.Body then
		belongText = LTConfig.TextScriptTextConfig.GetConfig(89901204).Text
	elseif belongType ~= self.EquipType.Camp then
		belongText = LTConfig.TextScriptTextConfig.GetConfig(89901205).Text
	elseif belongType ~= self.EquipType.Weapon then
		belongText = LTConfig.TextScriptTextConfig.GetConfig(89901206).Text
	elseif belongType ~= self.EquipType.Talent then
		belongText = LTConfig.TextScriptTextConfig.GetConfig(89901207).Text
	end

	store.belongText = belongText
	store.isTalentActiveCtrl = 1
	local storeTip = gStoreManager:GetStoreGroup("ChaosEquipSkill"):GetStoreByWidget(store.chaosEquipSkillBtn)

	if not storeTip then
		return
	end

	storeTip.skillName = cfg.Name
	storeTip.skillTypeName = cfg.Description and LTConfig.TextScriptTextConfig.GetConfig(89901197).Text or LTConfig.TextScriptTextConfig.GetConfig(89901196).Text
	storeTip.skillDetail = cfg.Description or cfg.Effect
end

M.OnChaosPartItemRenderTooltip = function(self, btn, popup, index)
	if self.itemToolTipRefBtn then
		self.itemToolTipRefBtn:CloseTooltip(true)
	end

	self.itemToolTipRefBtn = btn
	local store = gStoreManager:GetStoreGroup("ChaosEquipItem"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local equipType = store.equipType or self.EquipType.Body
	local equipId = 0

	if equipType ~= self.EquipType.Body then
		equipId = self.curChaosData.Body
	elseif equipType ~= self.EquipType.Camp then
		equipId = self.curChaosData.Camp
	elseif equipType ~= self.EquipType.Weapon then
		equipId = self.curChaosData.Weapon
	end

	local tooltipStore = gStoreManager:GetStoreGroup("ChaosEquipToolTip")

	if tooltipStore then
		tooltipStore.SetChaosEquipTooltip(tooltipStore, popup, equipType, equipId, self.curChaosData)
	end
end
