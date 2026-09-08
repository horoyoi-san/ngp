-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CenterCharacterInfoStore.lua
-- Decompiled from: 01645_CenterCharacterInfoStore.lua_5f658ec33d4c.luajit

C_CenterCharacterInfoStore = DefClass("C_CenterCharacterInfoStore", C_CenterCharacterInfoStore, C_StoreGroup)
GroupName2Class.CenterCharacterInfoStore = C_CenterCharacterInfoStore
local M = C_CenterCharacterInfoStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.curType = -1
	self.prevType = -1
	self.curTypeStore = nil
	self.tabGenerated = {}
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.OnSpiritChange(self)
	self.OnWeaponDurabilityChange(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnLanguageChange = function(self, lang)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self.CreateAction(self, "OnSpiritChange"),
		[gEventConstants.WEAPON_DURABILITY_CHANGE] = self.CreateAction(self, "OnWeaponDurabilityChange"),
		[gEventConstants.CURRENT_SPIRIT_WEAPON_CHANGE] = self.CreateAction(self, "OnCurrentWeaponChange"),
		[gEventConstants.CAST_SKILL] = self.CreateAction(self, "OnCastSkillForDropWeapon")
	}
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnGenerateTab = self.CreateAction(self, "OnGenerateTab")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
end

M.OnGenerateTab = function(self, index, widget)
	if widget.Store and not string.is_null_or_empty(widget.Store) then
		self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	end

	self.tabGenerated[index] = true

	self.PlayDurabilityAnim(self, index)
end

M.OnTabRectRender = function(self, index, widget)
	if widget.Store and not string.is_null_or_empty(widget.Store) then
		self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	end
end

M.PlayDurabilityAnim = function(self, curType)
	if not self.curTypeStore or not self.curTypeStore.anim then
		return
	end

	self.curTypeStore.anim:Stop()

	if curType ~= 1 then
		gBattleMgr:CommonPlayAniTool(self.curTypeStore.anim, "S_vx_weapon_broken", 0, 1, true)
	elseif curType ~= 2 then
		gBattleMgr:CommonPlayAniTool(self.curTypeStore.anim, "S_vx_weapon_destroy", 0, 1, true)
	end
end

M.OnSpiritChange = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	if self.curTypeStore then
		self.curTypeStore.showCtrl = 0
		self.curTypeStore = nil
	end

	self.tabGenerated = {}
	self.curType = -1
	local cardId = nil

	if gCS.MyPlayerManager.PlayerUnit then
		cardId = gSpiritManager:GetCurFirstSpiritTid()

		if cardId ~= 15021040 then
			self.curType = 0
		end
	end

	self.bindData.tabRect.selectedIndex = self.curType
end

M.OnCastSkillForDropWeapon = function(self, eventId, data)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("OnCastSkillForDropWeapon")
	end

	if data and data.isDropWeaponSkill then
		self.suppressDropWeapon = true
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.OnWeaponDurabilityChange = function(self, eventId, data)
	if not self.STATE_EnableOnce then
		return
	end

	if not data then
		return
	end

	if self.suppressDropWeapon then
		if self.suppressDropWeapon ~= true then
			self.suppressDropWeapon = data.weaponId
		end

		if self.suppressDropWeapon ~= data.weaponId then
			return
		end

		self.suppressDropWeapon = nil
	end

	local weapon = gPlayerManager.infoSpirit.bindData.currentWeapon

	if not weapon or weapon.InstanceId == data.weaponId then
		return
	end

	local newType = self.CalcDurabilityType(self, weapon.TemplateId, data.durability)

	self.ApplyDurabilityType(self, newType, self.curType)
end

M.OnCurrentWeaponChange = function(self, eventId, weaponInfo)
	if not self.STATE_EnableOnce then
		return
	end

	if not weaponInfo or not weaponInfo.TemplateId or not weaponInfo.Durability then
		return
	end

	local newType = self.CalcDurabilityType(self, weaponInfo.TemplateId, weaponInfo.Durability)

	self.ApplyDurabilityType(self, newType, -1)
end

M.CalcDurabilityType = function(self, templateId, durability)
	if gWeaponManager:IsWeaponPileUp(templateId) or gWeaponManager:IsWeaponUseBulletById(templateId) then
		return -1
	end

	local cfg = LTConfig.SceneitemConfig.GetConfig(templateId)

	if cfg and cfg.NoDestroyUI then
		return -1
	end

	local allDurability = cfg and cfg.Durability

	if not allDurability or allDurability ~= -1 then
		return -1
	end

	if durability ~= 0 then
		return 2
	end

	local lowLimit = LTConfig.SceneitemConfig.WeaponDurabilityLow * allDurability

	if durability < lowLimit then
		return 1
	end

	return -1
end

M.ApplyDurabilityType = function(self, newType, compareType)
	self.curType = newType

	if self.bindData and self.bindData.tabRect then
		self.bindData.tabRect.selectedIndex = newType
	end

	if newType == compareType and newType == -1 and self.tabGenerated[newType] then
		self.PlayDurabilityAnim(self, newType)
	end
end
