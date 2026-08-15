local CrossHairConfig = LTConfig.CrossHairConfig
local CrossHairTypeConfig = LTConfig.CrossHairTypeConfig
C_CoreHudShootStore = DefClass("C_CoreHudShootStore", C_CoreHudShootStore, C_StoreGroup)
GroupName2Class.CoreHudShootStore = C_CoreHudShootStore
local M = C_CoreHudShootStore
local CrossHairType = {
	CommonIdle = 8,
	SaimoType1 = 11,
	Sniper = 1,
	HideShoot = 7,
	Cannon = 3,
	CannonSmall = 9,
	Grenade = 6,
	WashGunLarge = 17,
	Base = 18,
	Flamethrower = 2,
	_ = 4,
	SaimoType3 = 13,
	Normal = 5,
	WashGunSmall = 15,
	Kesi = 14,
	SaimoType2 = 12,
	WashGunMedium = 16,
	Strengthen = 10,
	None = 0
}
local CrossHairStatus = {
	Kill = 3,
	Hit = 1,
	Baotou = 2,
	FriendlyFire = 4,
	Normal = 0
}
local CrossHairPlatformCtrl = {
	PC = 1,
	PS = 2,
	Mobile = 0
}
local IsNoneBulletCtrl = {
	Hide = 0,
	Show = 1
}
local CrossHairTypeAniName = {
	"S_vx_CrossHairSniperPanel_",
	"S_vx_Crosshair_Flamethrower_",
	"S_vx_CrossHairCannonPanel_",
	"S_vx_CrossHairPanel_Base_",
	"S_vx_CrossHairPanel_Base_",
	"",
	"S_vx_CrossHairHide_",
	"",
	"S_vx_CrossHairPanel_linqin",
	"S_vx_CrossHairPanel_Base_"
}

function M:ctor()
	self.crossHairTypeCount = 8
	self.crossHair = nil
	self.crossHairModuleTypeIndex = 0
	self.crossHairModuleRefreshTimer = nil
	self.isFriendlyFire = false
	self.singleBullet = -1
	self.totalBullet = -1
	self.msgEvents = {
		[gEventConstants.SkillBtn_Click] = self:CreateAction("OnSkillBtnDown"),
		[gEventConstants.GUN_SHOOT_MODE_CHANGED] = self:CreateAction("UpdateIsNoneCtrl"),
		[gEventConstants.CAST_SKILL] = self:CreateAction("OnCastSkill"),
		[gEventConstants.AFTER_SKILL_END] = self:CreateAction("OnAfterSkillEnd")
	}
end

function M:OnAwake()
	self.coreHudPanel = gStoreManager:GetStoreGroup("CoreHudPanelStore")
	self.bindData.ammunitionTab.OnRenderTab = self:CreateAction("OnAmmunitionTabRender")
end

function M:OnStart()
	self:RegisterBtnAction()
	gCS.WeaponMgr:RefreshCurrentAmmunitionInfo()
end

function M:OnGroupEnable()
	self.bindData.tab.OnRenderTab = self:CreateAction("OnRenderTab")

	self:UpdateAmmunition(self.ammunitionFill or 1, 1)
end

function M:OnDestroy()
	return
end

function M:OnEnable()
	if self.crossHair == nil then
		self:RegisterCrossHairSlot(nil)
	else
		self:RegisterCrossHairSlot(self.crossHair.crossHairSlot)
	end
end

function M:OnDisable()
	self:RegisterCrossHairSlot(nil)

	if self.crossHairModuleRefreshTimer then
		self.crossHairModuleRefreshTimer:Stop()

		self.crossHairModuleRefreshTimer = nil
	end
end

function M:RegisterBtnAction()
	self:ClearMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnCastSkill(eventId, msg)
	if msg.isMySkill then
		self:UpdateAmmunitionActive()
	end
end

function M:OnAfterSkillEnd(eventId, msg)
	if msg.pid == gCS.MyPlayerManager.PlayerUnitId then
		self:UpdateAmmunitionActive()
	end
end

function M:NeedShowCrossHair()
	if gShootManager.spoonControlCrossHair then
		return gShootManager.spoonCrossHairTargetState
	end

	if self.crossHairModuleTypeIndex > 0 then
		return true
	end

	if gCS.MyPlayerManager.PlayerUnit and gCS.ShootModule.IsInShootMode(gCS.MyPlayerManager.PlayerUnit) then
		return true
	end

	if gCS.MindPowerMgr.showShootCrossHair then
		return true
	end

	return false
end

function M:OnRenderTab(index, widget)
	if widget == nil then
		return
	end

	local group = gStoreManager:GetStoreGroup(widget.Store)

	if group then
		self:DoSwitchCrossHair(group:GetStoreByWidget(widget))
	end

	self:CheckFindChildCrossHair()
	self:UpdateCrossHairData()
	self:UpdateAmmunitionActive()
end

function M:RefreshTabRect()
	if self.crossHairType <= 0 then
		self:DoSwitchCrossHair()
	end

	if self.bindData.tab then
		self.bindData.tab.selectedIndex = self.crossHairType - 1
	end

	self:UpdateCrossHairData()
	self:UpdateAmmunitionActive()
	self:UpdateIsNoneCtrl()
end

function M:DoSwitchCrossHair(newCrossHair)
	self.crossHair = newCrossHair

	self:ResetCrossHiarStatus()

	if self.crossHair == nil then
		self:RegisterCrossHairSlot(nil)
	else
		self:RegisterCrossHairSlot(self.crossHair.crossHairSlot)
	end
end

function M:RegisterCrossHairSlot(slot)
	gCS.CrossHairModule.SetCrossHair(slot)
end

function M:OnRefreshFire()
	local needShow = self:NeedShowCrossHair()

	gMessageManager:SendMessage(gEventConstants.CROSSHAIR_SHOW_WHEN_FIRE_REFRESH, needShow)

	if not needShow then
		self.crossHairType = -1

		self:RefreshTabRect()

		return
	end

	local crossHairType = self:GetCrossHairType()
	self.crossHairType = crossHairType
	gPlayerManager.main.bindData.curCrossHairType = crossHairType

	self:RefreshTabRect()
end

function M:OnCrossHairModuleChanged(crossHairCfgId)
	local tmpTypeIndex = 0

	if crossHairCfgId == 0 then
		tmpTypeIndex = 0
	else
		local crossHairCfg = CrossHairConfig.GetConfig(crossHairCfgId)

		if crossHairCfg == nil or crossHairCfg.TypeId == 0 then
			tmpTypeIndex = 0
		else
			local typeCfg = CrossHairTypeConfig.GetConfig(crossHairCfg.TypeId)
			tmpTypeIndex = typeCfg and typeCfg.Index or 0
		end
	end

	if tmpTypeIndex == self.crossHairModuleTypeIndex then
		return
	end

	self.crossHairModuleTypeIndex = tmpTypeIndex

	if self.crossHairModuleRefreshTimer then
		self.crossHairModuleRefreshTimer:Stop()
	end

	self.crossHairModuleRefreshTimer = Timer.New(function ()
		self:OnRefreshFire()
	end, 0):Start()
end

function M:GetCrossHairType()
	local crossHairType = -1
	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if self.crossHairModuleTypeIndex > 0 then
		crossHairType = self.crossHairModuleTypeIndex
	elseif gCS.MindPowerMgr.showShootCrossHair then
		crossHairType = CrossHairType.Base
	elseif gCS.ShootModule.GetIsInCannonShoot(csUnit) then
		crossHairType = CrossHairType.Cannon
	elseif gCS.ShootModule.IsEnableTelescopeMode(csUnit) then
		crossHairType = CrossHairType.Sniper
	end

	if crossHairType == CrossHairType._ then
		crossHairType = CrossHairType.HideShoot
	end

	return crossHairType
end

function M:CheckModifyCrossHairTypeByPlatform(crossHairType)
	local crossHairPlatformCtrl = CrossHairPlatformCtrl.Mobile

	if crossHairType == CrossHairType.Sniper then
		crossHairPlatformCtrl = gCS.LuaUtils.IsNonMobileAdaptive() and CrossHairPlatformCtrl.PC or CrossHairPlatformCtrl.Mobile
	end

	return crossHairPlatformCtrl
end

function M:CheckFindChildCrossHair()
	if self.crossHair ~= nil and self.crossHairType == CrossHairType.Sniper then
		local crossHairPlatformCtrl = self:CheckModifyCrossHairTypeByPlatform(self.crossHairType)
		self.crossHair.crossHairPlatformCtrl = crossHairPlatformCtrl

		if crossHairPlatformCtrl == CrossHairPlatformCtrl.PC then
			self:DoSwitchCrossHair(gStoreManager:GetStoreGroup("ShootTab"):GetStoreByWidget(self.crossHair.pc))
		elseif crossHairPlatformCtrl == CrossHairPlatformCtrl.Mobile then
			self:DoSwitchCrossHair(gStoreManager:GetStoreGroup("ShootTab"):GetStoreByWidget(self.crossHair.mobile))
		end
	end
end

function M:UpdateCrossHairData()
	self:CheckShowHUDUI()
end

function M:CheckShowHUDUI()
	local show = self.crossHairType ~= CrossHairType.Sniper

	if self.coreHudPanel then
		self.coreHudPanel:SwitchMainPhoneModeCtrlToShoot(not show)
	end

	gMainMenuMgr:HideMiniMapByShootMode(show)
	gMessageManager:SendMessage(gEventConstants.CHANGE_ANTIDINIC_MODE, not self.crossHairType == CrossHairType.None)
end

function M:PlayCrossHairHit(killed, isWeak)
	if self.crossHairType == CrossHairType.None or self.crossHair == nil then
		return
	end

	killed = killed ~= nil and killed or false

	if killed then
		self.crossHair.statusCtrl = CrossHairStatus.Kill
	elseif isWeak then
		if self.crossHair.statusCtrl == CrossHairStatus.Kill then
			return
		end

		self.crossHair.statusCtrl = CrossHairStatus.Baotou
	else
		if self.crossHair.statusCtrl == CrossHairStatus.Kill then
			return
		end

		self.crossHair.statusCtrl = CrossHairStatus.Hit
	end

	self:ClearCrossHairAnim()

	local delay = self:PlayCrossHairHitAni(self.crossHair.statusCtrl)
	self.crossHairHitAnimTimer = Timer.New(function ()
		self:ResetCrossHiarStatus()
	end, delay):Start()
end

function M:ResetCrossHiarStatus()
	if self.crossHair then
		self.crossHair.statusCtrl = self.isFriendlyFire and CrossHairStatus.FriendlyFire or CrossHairStatus.Normal
	end
end

function M:ResetCrossHairFriendlyFireStatus(isFriendlyFire)
	self.isFriendlyFire = isFriendlyFire

	if self.crossHair and (self.crossHair.statusCtrl == CrossHairStatus.Normal or self.crossHair.statusCtrl == CrossHairStatus.FriendlyFire) then
		self:ResetCrossHiarStatus()
	end
end

function M:ClearCrossHairAnim()
	if self.crossHairHitAnimTimer then
		self.crossHairHitAnimTimer:Stop()

		self.crossHairHitAnimTimer = nil
	end
end

function M:PlayCrossHairFireAni(isOp)
	if not self.crossHair or not self.crossHair.fireAni or self.crossHairType == CrossHairType.None then
		return
	end

	local aniName = self:GetCrossHairAniName()

	if string.is_null_or_empty(aniName) then
		return
	end

	if isOp then
		gBattleMgr:CommonPlayAniTool2(self.crossHair.fireAni, aniName, 0, 1)
	else
		gBattleMgr:CommonPlayAniTool(self.crossHair.fireAni, aniName, 0, 1)
	end
end

function M:PlayCrossHairHitAni(hitType)
	if self.crossHair and self.crossHair.hitAni then
		local aniName = CrossHairTypeAniName[self.crossHairType] .. "02"
		aniName = self:GetCrossHairHitAniName(hitType, aniName)
		local clip = self.crossHair.hitAni:GetClip(aniName)

		if clip then
			self.crossHair.hitAni:Stop()
			self.crossHair.hitAni:Play(aniName)

			return clip.length
		end
	end

	return 0.1
end

function M:GetCrossHairHitAniName(hitType, aniName)
	if self.crossHairType == CrossHairType.Grenade or self.crossHairType == CrossHairType.CommonIdle then
		return
	end

	if hitType == CrossHairStatus.Hit then
		return CrossHairTypeAniName[self.crossHairType] .. "mingzhong"
	elseif hitType == CrossHairStatus.Baotou then
		return CrossHairTypeAniName[self.crossHairType] .. "baotou"
	elseif hitType == CrossHairStatus.Kill then
		return CrossHairTypeAniName[self.crossHairType] .. "jisha"
	end

	return aniName
end

function M:GetCrossHairAniName()
	local head = CrossHairTypeAniName[self.crossHairType]

	if head == nil then
		return nil
	end

	return head .. "01"
end

function M:OnAmmunitionTabRender(index, widget)
	self.ammunitionTabStore = gStoreManager:GetStoreGroup("RemainAmmunitionStore"):GetStoreByWidget(widget)
end

function M:ShowAmmunition(visible, interactable)
	self.ammunitionActive = visible

	self:UpdateAmmunitionActive()
end

function M:UpdateAmmunitionType()
	local cfg = LTConfig.WeaponShootConfig.GetConfig(gBattleMgr.shootId)
	local type = LTConfig.CrossHairRemainAmmunitionTypeConfig.Type1

	if cfg then
		type = cfg.RemainAmmunition
	end

	self.bindData.ammunitionTab.selectedIndex = type - 1
end

function M:UpdateAmmunition(cur, single, total, isByUsing)
	local fill = cur / single
	self.ammunitionFill = fill
	self.singleBullet = single
	self.totalBullet = total

	if not self.STATE_EnableOnce then
		return
	end

	local duration = 1

	if self.ammunitionTabStore and self.ammunitionTabStore.fillCom then
		if isByUsing then
			self.ammunitionTabStore.fillCom:ProgressToValue(fill, duration)
		else
			self.ammunitionTabStore.fillCom:ProgressToValue(fill, 0)
		end
	end

	self:UpdateIsNoneCtrl()
end

function M:UpdateAmmunitionActive()
	self:UpdateAmmunitionType()

	local show = self:CheckAmmunitionActive()
	self.bindData.ammunitionActive = show and 1 or 0
end

function M:CheckAmmunitionActive()
	if self.crossHairType == CrossHairType.None or self.singleBullet < 0 then
		return false
	end

	if self:CheckAmmunitionNeedActive() then
		return true
	end

	if gCS.MyPlayerManager.isInMindPowerAim then
		return false
	end

	if self.crossHairModuleTypeIndex <= 0 then
		return false
	end

	if not gCS.GunModule.IsMeInAimMode then
		return false
	end

	return self.ammunitionActive
end

function M:CheckAmmunitionNeedActive()
	if not gCS.MyPlayerManager.PlayerUnit then
		return false
	end

	local skillData = gCS.BattleManager.GetSkillData(gCS.MyPlayerManager.PlayerUnit)

	if skillData then
		local skillId = skillData.skillId
		local skillConfig = LTConfig.SkillConfig.GetConfig(skillId)

		if skillConfig and skillConfig.SkillCastTypeTag == LTConfig.SkillConfig.SkillCastTypeTagType.Reload then
			return true
		end
	end
end

function M:ShowCameraArea(enable, width, height)
	self.bindData.showDebugImage = enable
	self.bindData.debugImage.sizeDelta = Vector2.New(width, height)
end

function M:DebugLog(...)
	if not self.debug then
		return
	end

	print_warn("[CoreHudShootStore] ", ...)
end

function M:RefreshCamZoomActive(enable)
	self.bindData.camZoomMouseScrollActive = enable and 1 or 0
end

function M:UpdateIsNoneCtrl()
	local canShow = gCS.GunModule.IsMeInShoulderFire or self.canShowIsNoneBulletByModeChanged
	local show = canShow and self.totalBullet and self.totalBullet == 0

	if self.bindData.tab and self.bindData.tab.selectedIndex == -1 then
		show = false
	end

	self.bindData.isNoneCtrl = show and IsNoneBulletCtrl.Show or IsNoneBulletCtrl.Hide
end

function M:OnSkillBtnDown(eventId, msg)
	if msg == gBattleMgr.SkillBtnType.Normal then
		self.canShowIsNoneBulletByModeChanged = true

		self:UpdateIsNoneCtrl()

		if self.canShowIsNoneBulletByModeChangedTimer then
			gLuaTimeMgrUtils.CancelUnitDelay(self.canShowIsNoneBulletByModeChangedTimer)
		end

		self.canShowIsNoneBulletByModeChangedTimer = gLuaTimeMgrUtils.Delay(function ()
			self.canShowIsNoneBulletByModeChanged = false

			self:UpdateIsNoneCtrl()
		end, 2, false, false, true)
	end
end
