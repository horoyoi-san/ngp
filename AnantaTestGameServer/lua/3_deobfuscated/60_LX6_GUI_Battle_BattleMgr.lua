local DataSet = require("LX6/DataBind/DataSet")
local ClientEventConfig = LTConfig.ClientEventConfig
local SkillConfig = LTConfig.SkillConfig
local GameConfig = LTConfig.GameConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local SkillJumpConfig = LTConfig.SkillJumpConfig
local DestructibleConfig = LTConfig.DestructibleConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
local SoundEventConfig = LTConfig.SoundEventConfig
local SoundConfig = LTConfig.SoundConfig
local WeaponConfig = LTConfig.WeaponConfig
local BuffConfig = LTConfig.BuffConfig
local WeaponShootShootModeConfig = LTConfig.WeaponShootShootModeConfig
local SpiritSkillType = LX6.Engine.SpiritSkillType
local GameDevice = SGUI.GameDevice
local SkillType = LX6.Engine.SkillType
local SkillResourcesConfig = LTConfig.SkillResourcesConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
local ButtonInfoEnum = LX6.Units.Module.ButtonInfoEnum

if not gBattleMgr then
	local M = {
		canDodge = false,
		IsUseNewCombo = true,
		shootModeId = 0,
		shootId = 0,
		isBattleUI = false,
		jumpAttackHeight = 0,
		SummonInControl = false,
		EnemyVisibleMaxDistance = 40,
		battleWeaponTemplateId = 0,
		EnemyVisibleHeightDistance = 20,
		isPrivateWeapon = true,
		ShowBattleMsg = false,
		SkillBtnType = SkillType,
		skillData = {},
		comboSkillData = {},
		hideHpBarTimer = {},
		scheme = gCS.LuaUtils.GetActiveDevice(),
		dataSet = DataSet.New({
			showEnemyHp = true
		}),
		SummonAgentId = ulong.new(0, 0),
		enemyPoiseWeaponChangeInfo = {}
	}
end

M.WeaponType = {
	Shoot = 1,
	PrivateWeapon = 0,
	Battle = 2
}
M.CfgWeaponType2Index = {
	[WeaponConfig.WeaponTypeType.None] = M.WeaponType.Battle,
	[WeaponConfig.WeaponTypeType.PrivateWeapon] = M.WeaponType.PrivateWeapon
}
M.FightResHUDType = {
	OverHeatMale = 0,
	EnergyDot = 2,
	OverHeatFamale = 1
}
M.SaveActionType = {
	Dodge = 3,
	SkillType = 1,
	Jump = 2
}

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.ON_ACTIVE_DEVICE_CHANGED, function (eventId, scheme)
		self:OnControlScheme(scheme)
	end)
	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, function ()
		self:CheckShowWeaponResHUDByTemplateId()
	end)
	gMessageManager:AddMessageListener(gEventConstants.SKILL_JUMP_REPLACE_ICON, function (eventId, skillType)
		self:SkillJumpReplaceIconHandler(skillType)
	end)
	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, function (eventId, skillType)
		self:RefreshCurBattleFight()
	end)
end

function M:OnBeforeSwitchScene()
	if gCS.MyPlayerManager.PlayerUnit then
		gCS.SkillJumpManager.Instance:ClearAllHoldCastComboSkillDic(gCS.MyPlayerManager.PlayerUnit.Pid)
	end
end

function M:OnCameraUpdate()
	if self.refreshSkillBtnGrid and self.characterControlPanel and self.characterControlPanel.characterControlData.skillBtnGrid then
		self.characterControlPanel.characterControlData.skillBtnGrid:ForceRebuildLayoutImmediate()

		self.refreshSkillBtnGrid = false
	end
end

function M:IsBtnContainSkillId(btnSkillId, skillId)
	if btnSkillId == skillId then
		return true
	end

	local skillConfig = SkillConfig.GetConfig(btnSkillId)

	if skillConfig and skillConfig.HoldCastSkill ~= nil and (skillConfig.HoldCastSkill.holdCastSkillId == skillId or skillConfig.HoldCastSkill.clickCastSkillId == skillId) then
		return true
	end

	if skillConfig and skillConfig.SkillReplace ~= nil and #skillConfig.SkillReplace > 0 then
		for i = 1, #skillConfig.SkillReplace do
			local jumpCfg = SkillJumpConfig.GetConfig(skillConfig.SkillReplace[i])

			if jumpCfg and jumpCfg.Skillid == skillId then
				return true
			end
		end
	end

	return false
end

function M:GetShareCDSkillId(skillId)
	local skillConfig = SkillConfig.GetConfig(skillId)
	local fillAmount, labelTimeLeft, isHide, curCharges = gBattleMgr:CalculateSkillCDResult(skillId)
	local skillCD = isHide and 0 or labelTimeLeft
	local retSkillId = skillId
	local castHoldSkillId = 0
	local castHoldSkillCD = 0

	if skillConfig ~= nil and skillConfig.HoldCastSkill ~= nil and skillConfig.HoldCastSkill.holdCastSkillId > 0 and skillConfig.HoldCastSkill.clickCastSkillId > 0 then
		local holdSkillId = skillConfig.HoldCastSkill.holdCastSkillId
		local fillAmount, labelTimeLeft, isHide, curCharges = gBattleMgr:CalculateSkillCDResult(holdSkillId)
		local holdCD = isHide and 0 or labelTimeLeft
		local clickSkillId = skillConfig.HoldCastSkill.clickCastSkillId
		fillAmount, labelTimeLeft, isHide, curCharges = gBattleMgr:CalculateSkillCDResult(clickSkillId)
		local clickCD = isHide and 0 or labelTimeLeft
		castHoldSkillId = clickCD < holdCD and holdSkillId or clickSkillId
		castHoldSkillCD = clickCD < holdCD and holdCD or clickCD
		retSkillId = castHoldSkillCD < skillCD and skillId or castHoldSkillId
		skillCD = castHoldSkillCD < skillCD and skillCD or castHoldSkillCD
	end

	if skillConfig and skillConfig.SkillReplace ~= nil and #skillConfig.SkillReplace > 0 then
		for i = 1, #skillConfig.SkillReplace do
			local jumpCfg = SkillJumpConfig.GetConfig(skillConfig.SkillReplace[i])

			if jumpCfg then
				local skillId = jumpCfg.Skillid
				local fillAmount, labelTimeLeft, isHide, curCharges = gBattleMgr:CalculateSkillCDResult(skillId)
				local cd = isHide and 0 or labelTimeLeft

				if skillCD < cd then
					skillCD = cd
					retSkillId = skillId
				end
			end
		end
	end

	return retSkillId
end

function M:CalculateSkillCDResult(skillId)
	local fillAmount, labelTimeLeft, isFull, curCharges, maxCharges = nil
	fillAmount, labelTimeLeft, isFull, curCharges, maxCharges = gCS.BattleManager.CalculateSkillCdResultForUI(skillId, fillAmount, labelTimeLeft, isFull, curCharges, maxCharges)

	return fillAmount, labelTimeLeft, isFull, curCharges, maxCharges
end

function M:RefreshCurBattleFight()
	self:SyncRefreshFight(true)
	gCS.BattleManager.RefreshAllSkills(false, false)
	self:UpdateSkillBtns()
	self:OnRefreshFeiSuo()

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.SkillJumpManager.Instance:ForceClearSkillJumpData(gCS.MyPlayerManager.PlayerUnit.Pid)
	end

	gMessageManager:SendMessage(gEventConstants.CONTROLPOWER_REFRESH)
end

function M:RefreshAllSkillsByCSharp()
	self:SyncRefreshBasicSkills()
	self:CheckSkillComboData()
end

function M:GetHeavyAttackSkillId(templateId)
	local skillId = gCS.BattleManager.GetCurrentSpiritSkillId(SpiritSkillType.HeavyAttack)

	if skillId == 0 then
		skillId = gCS.BattleManager.GetCurrentSpiritSkillId(SpiritSkillType.PressinCommon)
	end

	return skillId
end

function M:GetJumpSkillId(templateId)
	if not gBattleSwitch.JumpAttackSwitch then
		return 0
	end

	local spiritTemplateId = templateId or gBattleSpiritMgr.currentSpiritTemplateId

	gCS.BattleManager.GetJumpSkillId(spiritTemplateId)
end

function M:OpenChangeSkillCountDown(countDown, skillType, time)
	if not self.characterControlPanel then
		return
	end

	if countDown then
		self.characterControlPanel:OpenChangeSkillCountDown(skillType, time)
	else
		self.characterControlPanel:CloseChangeSkillCountDown(skillType)
	end
end

function M:StickToTheGroundByDirection(pid, direction)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)

	if not cs_unit or not gBuffUtils.HasBuff(cs_unit.Pid, LTConfig.BuffConfig.EnemyIgnoreGravity) then
		self:ShowMessageTipsOnEditor("贴墙失败，这个怪物不是无视重力的怪物")

		return
	end

	if not cs_unit.ModelSlot or not cs_unit.ModelSlot.leftFoot then
		self:ShowMessageTipsOnEditor("贴墙失败，没有modelSlot或者没有LeftFoot")

		return
	end

	local hit, hitInfo = nil
	hit, hitInfo = gCS.LuaUtils.Raycast(cs_unit.ModelSlot.leftFoot.position, direction, 10, LX6.Constants.LayerConstants.colliderMoveLayer, hitInfo)

	if hit then
		self:ShowMessageTipsOnEditor("贴墙成功")

		cs_unit.LocalPosition = cs_unit.LocalPosition + hitInfo.point - cs_unit.ModelSlot.leftFoot.position
	else
		self:ShowMessageTipsOnEditor("贴墙失败，打射线没找到贴墙点")
	end
end

function M:IsSkillFightResourceEnough(unit, skillId)
	local skillConfig = SkillConfig.GetConfig(skillId)

	if skillConfig ~= nil and skillConfig.UseSkillRes ~= nil and #skillConfig.UseSkillRes > 0 then
		for i = 1, #skillConfig.UseSkillRes do
			if not gCS.BattleManager.CheckFightResourceEnough(unit, skillConfig.UseSkillRes[i].Id, skillConfig.UseSkillRes[i].Value, skillConfig.UseSkillRes[i].IsPercentage) then
				return false
			end
		end
	end

	return true
end

function M:CheckShowWeaponResHUD(show, type)
	gMainMenuMgr:SetWeaponFightResVisiable(show)

	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore")

	store:ChangeWeaponFightResHUD(type)
end

function M:ShowWeaponFightResHUD(show)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore")

	store:ShowWeaponFightResHUD(show)
end

function M:ShowCharEnergyUI(show)
	local store = gBattleMgr.characterPartPanel

	if store and store.characterPartData.charEnergy then
		store.characterPartData.charEnergy:SetLocalScaleX(show and 1 or 0)
	end
end

function M:CheckShowWeaponResHUDByTemplateId()
	local initWeaponId = 0
	local templateId = gBattleMgr.battleWeaponTemplateId

	if not templateId or templateId == 0 then
		local spiritCfg = FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)

		if spiritCfg and spiritCfg.PrivateWeapon > 0 then
			templateId = spiritCfg.PrivateWeapon
		end
	end

	local cfg = WeaponConfig.GetConfig(templateId)

	if cfg then
		local fightResHud = gCS.FightStyleManager.Instance:GetWeaponFightHudResId(cfg.Id)

		self:CheckShowWeaponResHUD(fightResHud > 0, fightResHud)
	else
		self:CheckShowWeaponResHUD(false, 0)
	end

	self:RefreshWeaponDurabilityUI(templateId)
	self:CheckShowLeftShootBtn(templateId)
end

function M:RefreshWeaponDurabilityUI(templateId)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	store:RefreshWeaponDurabilityUI(templateId)
end

function M:CheckShowLeftShootBtn(templateId)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	store:CheckShowLeftShootBtn(templateId)
end

function M:EnableEnergyDotRoot(enable)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	store:EnableEnergyDotRoot(enable)
end

function M:CheckPlayOverHeatAni()
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore")

	store:CheckPlayOverHeatAni()
end

function M:SyncRefreshFight()
	if self.characterPartPanel then
		self.characterPartPanel:SyncRefreshFight()
	end

	gMessageManager:SendMessage(gEventConstants.SYNC_REFRESH_FIGHT_SKILL)
end

function M:UpdateSkillBtns()
	gMessageManager:SendMessage(gEventConstants.ON_UPDATE_SKILL_BTN)
end

function M:UpdateBtnSpriteInAir(isInAir)
	if self.characterControlPanel then
		self.characterControlPanel:UpdateBtnSpriteInAir(isInAir)
	end
end

function M:SyncRefreshBasicSkills()
	gMessageManager:SendMessage(gEventConstants.SYNC_REFRESH_BASIC_SKILL)
end

function M:EnterOrLeaveVehicleShoot(enable)
	local store = gStoreManager:GetStoreGroup("CoreHudDriveControlStore")

	if enable then
		store:OpenVehicleBattle(0)
	else
		store:StopVehicleBattle()
	end
end

function M:EnterOrLeaveEnemyDriveShoot(enable)
	local store = gStoreManager:GetStoreGroup("CoreHudDriveControlStore")

	if enable then
		store:OpenVehicleBattle(1)
	else
		store:StopVehicleBattle()
	end
end

function M:CheckShowJobSpecialBtn(buffId, enable)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local pid = gCS.MyPlayerManager.PlayerUnit.Pid

	if enable ~= nil then
		if buffId == LTConfig.BuffConfig.TimeScaleBadgeBuff then
			enable = enable and gBuffUtils.HasBuff(pid, LTConfig.BuffConfig.Moto)
		elseif buffId == LTConfig.BuffConfig.Moto then
			enable = enable and gBuffUtils.HasBuff(pid, LTConfig.BuffConfig.TimeScaleBadgeBuff)
		end

		gMainMenuMgr:SetProfessionalSkillBtnVisiable(enable)

		return
	end

	if gBuffUtils.HasBuff(pid, LTConfig.BuffConfig.TimeScaleBadgeBuff) and gBuffUtils.HasBuff(pid, LTConfig.BuffConfig.Moto) then
		gMainMenuMgr:SetProfessionalSkillBtnVisiable(true)
	else
		gMainMenuMgr:SetProfessionalSkillBtnVisiable(false)
	end
end

function M:GetBattlePanel()
	return self.characterControlPanel
end

function M:GetBattlePanelRoot()
	local store = gStoreManager:GetStoreGroup("CoreHudPanelStore")

	if store then
		return store.bindData.battleRoot
	end

	return nil
end

function M:GetBattlePanelGo()
	local store = gStoreManager:GetStoreGroup("CoreHudPanelStore")

	if store then
		return store.bindData.battleRoot
	end

	return nil
end

function M:SetBattlePanelGoActive(active)
	local battle = gBattleMgr:GetBattlePanelGo()

	if battle then
		gUIUtils:SetGoActive(gBattleMgr:GetBattlePanelGo(), active)
	end
end

function M:CheckSkillBtnIsInteractable(skillType)
	if self.characterControlPanel then
		return self.characterControlPanel.goSkills[skillType].interactable
	end

	return false
end

M.parkourStateShowFeiSuo = true

function M:OnRefreshFeiSuo()
	local show = true
	local platform = gCS.LuaUtils.IsNonMobileAdaptive() and gBattleMgr.scheme == SGUI.GameDevice.KeyboardMouse and 1 or 2

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		local grappleConfig = gMainMenuMgr.clientStateConfig[state].Grapple

		if type(grappleConfig) == "table" and grappleConfig[platform] and not grappleConfig[platform].visible and not grappleConfig[platform].interactable then
			show = false

			gMainMenuMgr:ShowMainMenuMgrMessageTipsOnEditor("飞索被跑酷状态隐藏了 状态:" .. state)
		end
	end

	if self.parkourStateShowFeiSuo ~= show then
		self.parkourStateShowFeiSuo = show

		gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.ParkourStateShowFeiSuo, self.parkourStateShowFeiSuo ~= true)
	end
end

function M:ReplaceDodgeBtnToMindPower()
	if self.characterControlPanel then
		self.characterControlPanel:ReplaceDodgeBtnToMindPower()
	end
end

function M:SetMindBtnPCKeyId(btnType)
	if self.characterControlPanel then
		local id = 25

		if btnType == 1 then
			id = 10
		end

		self.characterControlPanel:SetMindBtnPCKeyId(id)
	end
end

function M:EnableSpiderExitBtn(enable)
	local store = gBattleMgr.characterControlPanel

	if store then
		self:SetBtnFaraway(store.characterControlData.spiderBotExitBtn, enable, false)
	end
end

function M:EnableAirDashBtn(enable)
	local store = gBattleMgr.uniqueSkillProtagonistPanel

	if store then
		self:SetBtnFaraway(store.bindData.airDashBtn, enable, false)
	end
end

function M:EnableProfessionalSkillBtn(enable)
	local store = gBattleMgr.characterControlPanel

	if store then
		store.professionSkillBtn.btnHideCtrl = enable and 0 or 1

		self:SetBtnFaraway(store.characterControlData.professionSkillBtn, enable, false)
	end
end

function M:EnableHandBagPutDownBtn(enable)
	local store = gBattleMgr.characterControlPanel

	if store then
		self:SetBtnFaraway(store.characterControlData.handBagPutDownBtn, enable, false)
	end
end

function M:EnableGrappleSpaceBtn(enable)
	local store = gBattleMgr.characterControlPanel

	if store then
		self:SetBtnFaraway(store.characterControlData.grappleSpaceBtn, enable, false)
	end
end

function M:EnableDiveControlBtn(enable)
	local store = gBattleMgr.characterControlPanel

	if store then
		self:SetBtnFaraway(store.characterControlData.ctrlButton, enable, false)
	end
end

function M:EnableMotoBtn(enable)
	local store = gBattleMgr.uniqueSkillTaFeiPanel

	if store then
		self:SetBtnFaraway(store.bindData.motoBtn, enable, false)
	end
end

function M:SetBattlePanelActive(isActive, isInScreen)
	gMainMenuMgr:ShowMainMenuMgrMessageTipsOnEditor("战斗面板隐藏: isActive:", isActive, "isInScreen", isInScreen)

	if self.characterControlPanel then
		local battleRoot = self:GetBattlePanelRoot()

		if battleRoot then
			battleRoot:SetWidgetFaraway(not isActive)

			self.hideBattleUIFlag = not isActive
		end
	end
end

function M:SetMagnetBtnActive(isActive, isInScreen, colliderEnable)
	if self.characterControlPanel then
		local btn = gBattleMgr.characterControlPanel.magnetBtn
		btn.interactable = colliderEnable
		btn.btnHideCtrl = isActive and isInScreen and 0 or 1
		btn.ignoreLayout = true

		self:SetBtnFaraway(gBattleMgr.characterControlPanel.characterControlData.magnetBtn, isActive, true)
		self:PlayBtnFanseAni(btn, nil, isActive and isInScreen and colliderEnable)
	end
end

function M:SetJumpBtnAlphaAndColliderEnable(isFullAlpha, colliderEnable)
	if self.characterControlPanel then
		local btn = gBattleMgr.characterControlPanel.jumpSwingBtn
		btn.interactable = colliderEnable

		self:PlayBtnFanseAni(btn, nil, colliderEnable)
	end
end

function M:SetJumpBtnActive(isActive, isInScreen)
	if self.characterControlPanel then
		local btn = gBattleMgr.characterControlPanel.jumpSwingBtn
		btn.btnHideCtrl = isInScreen and 0 or 1

		self:SetBtnFaraway(self.characterControlPanel.characterControlData.jumpSwingBtn, isActive)
	end
end

function M:SetHighSpeedActive(isInScreen, colliderEnable)
	if self.characterControlPanel then
		local btn = gBattleMgr.characterControlPanel.highSpeedBtn
		btn.btnHideCtrl = isInScreen and 0 or 1
		btn.interactable = colliderEnable

		self:PlayBtnFanseAni(btn, nil, colliderEnable)
	end
end

function M:SetWallJumpOffActive(isActive, colliderEnable)
	if self.characterControlPanel then
		local btn = gBattleMgr.characterControlPanel.dropBtn
		btn.btnHideCtrl = isActive and 0 or 1
		btn.interactable = colliderEnable

		self:SetBtnFaraway(self.characterControlPanel.characterControlData.dropBtn, isActive)
		self:PlayBtnFanseAni(btn, nil, isActive and colliderEnable)
	end
end

function M:SetMagnetPutDownActive(isActive, colliderEnable)
	if self.characterControlPanel then
		local btn = gBattleMgr.characterControlPanel.putDownBtn
		btn.btnHideCtrl = isActive and 0 or 1
		btn.interactable = colliderEnable
		btn.ignoreLayout = true

		self:SetBtnFaraway(self.characterControlPanel.characterControlData.putDownBtn, isActive, true)
		self:PlayBtnFanseAni(btn, nil, isActive and colliderEnable)
	end
end

function M:ShowKickOffBtn(isActive)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	if store.characterControlData and store.characterControlData.kickOffBtn then
		store.kickOffBtn.qteVxCtrl = isActive and 1 or 0

		gBattleMgr:SetBtnFaraway(store.characterControlData.kickOffBtn, isActive)
	end
end

function M:SetGoBottomRightActive(isActive, isInScreen)
	if self.characterControlPanel and self.characterControlPanel.bindData.battleBtnRoot then
		self.characterControlPanel.characterControlData.battleBtnRoot:SetActive(isActive)

		local oldPos = self.characterControlPanel.characterControlData.battleBtnRoot.localPosition
		self.characterControlPanel.characterControlData.battleBtnRoot.localPosition = Vector3.New(oldPos.x, oldPos.y, isInScreen and 0 or gCS.GuiUtils.UI_TRANS_OUT_RANGE)
	end
end

function M:SetCharacterWheelsVisiable(isActive)
	gUIFunctionStateManager:ParkourStateSetCharacterSwitch(isActive)
end

function M:SetCharacterHpActive(isActive)
	if self.characterPartPanel then
		self.playerHpBarActive = isActive

		self.characterPartPanel.characterPartData.playerHpBar:SetActiveFastest(isActive)
	end
end

function M:UpdateSkillCd(skillId)
	gMessageManager:SendMessage(gEventConstants.ON_UPDATE_SKILL_CD, skillId)
end

function M:BtnSkillKeyDown(index)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.skillKeyDown,
		index
	})
end

function M:BtnSkillKeyUp(index)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.skillKeyUp,
		index
	})
end

function M:BtnSkillPressDown(index)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.skillPressDown,
		index
	})
end

function M:BtnSkillPress(index)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.skillPress,
		index
	})
end

function M:BtnSkillPressUp(index)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.skillPressUp,
		index
	})
end

function M:BtnJumpKeyPressDown()
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.jumpKeyPressDown
	})
end

function M:BtnJumpKeyPress()
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.jumpKeyPress
	})
end

function M:BtnJumpKeyPressUp()
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.jumpKeyPressUp
	})
end

function M:BtnDodgeKeyDown()
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.dodgeKeyDown
	})
end

function M:BtnDodgeKeyUp()
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.dodgeKeyUp
	})
end

function M:ShanbiKeyDownFunc()
	if gPlayerManager.main.bindData.isFeiSuoCrouch then
		gCS.MotionFlagManager.SetIsInRush(gCS.MyPlayerManager.PlayerUnit, true)

		return
	end

	self.isXuliKeyPress = true
	gCS.TransitionMgr.isXuliKeyPress = true

	if not gPlayerManager.main.bindData.isInSlideRail and not gPlayerManager.main.bindData.isFreeClimbing then
		local isOk = false

		if gBattleMgr.IsUseNewCombo then
			isOk = gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.DodgeButtonClick)
		end

		if not isOk and not self:CheckIsBanFunGun() then
			isOk = gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, gCS.BattleManager.GetDodgeSkillID(), -1, ClientEventConfig.DodgeButtonClick)
		end

		if isOk then
			return
		end
	end

	gBattleMgr:XuliKeyDown()
end

function M:ShanbiKeyUpFunc()
	if self.isPressXuliDown then
		return
	end

	if not self.isXuliKeyPress then
		return
	end

	self.isXuliKeyPress = false
	gCS.TransitionMgr.isXuliKeyPress = false

	if not gPlayerManager.main.bindData.isInSlideRail and not gPlayerManager.main.bindData.isFreeClimbing then
		local isOk = false

		if gBattleMgr.IsUseNewCombo then
			isOk = gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.DodgeButtonUp)
		end

		if isOk then
			return
		end
	end

	self:XuliKeyUp()
end

function M:SetUpdateSkillBtn(skillType)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		gCoreHudUIManager.battlePanelEvent.updateSkillState,
		skillType
	})
end

function M:PlayBasicBattleSoundFromCSharp(pid, btnType)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	self:PlayBasicBattleSound(unit, btnType)
end

function M:PlayBasicBattleSound(unit, btnType)
	if btnType == M.SkillBtnType.Normal then
		self:PlayBattleSound(SoundConfig.PuGong1, unit)
	elseif btnType == M.SkillBtnType.Basic then
		self:PlayBattleSound(SoundConfig.Eskill, unit)
	elseif btnType == M.SkillBtnType.ControlPower then
		-- Nothing
	elseif btnType == M.SkillBtnType.FightSpiritBigSkill then
		self:PlayBattleSound(SoundConfig.Rskill, unit)
	end
end

function M:PlayBattleMindPowerAssinate()
	self:PlayBattleSound(SoundConfig.NianDongWu, gCS.MyPlayerManager.PlayerUnit)
end

function M:PlayBattleSoundByPid(soundId, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit then
		self:PlayBattleSound(soundId, unit)
	end
end

function M:PlayBattleSound(soundId, unit)
	unit = unit or gCS.MyPlayerManager.PlayerUnit
	local modelId = unit.ModelCfg.Id

	gSoundMgr:PlaySoundByTid(soundId, unit.LocalPosition, nil, nil, nil, function (C_data)
		local generalModelCfg = GeneralModelConfig.GetConfig(modelId)
		local modelName = generalModelCfg.ModelSwitch
		local modelGroup = generalModelCfg.ModelSwitchGroup

		if modelGroup and modelName then
			C_data:SetSwitchValue(modelGroup, modelName)
		end
	end)
end

function M:ClickProfessionSkill()
	gClientToGameSceneDelegate:AskAddClientBuff(gCS.MyPlayerManager.PlayerUnit.Pid, 52959496)
end

function M:OnControlScheme(scheme)
	gBattleMgr.scheme = scheme

	if self.characterControlPanel then
		self.characterControlPanel:ResetSomeDatas()
	end

	self:SyncRefreshFight()
	gCS.BattleManager.CheckAddControllerGumWeaponState()
	gMainMenuMgr:SetAwakeUI("awakeBattlePanel")
end

function M:CommonPlayAniTool(ani, clipName, time, speed, sampleToEnd, delayFunc)
	if ani == nil or gCS.LuaUtils.IsNull(ani) then
		return
	end

	local clip = ani:GetClip(clipName)

	if clipName == nil then
		clip = ani.clip
		clipName = clip.name
	end

	if clip then
		clip:SampleAnimation(ani.gameObject, time)
		ani:Play(clipName)

		local timer = nil
		timer = gLuaTimeMgrUtils.NotDestroyDelay(function ()
			if sampleToEnd and ani then
				self:CommonStopAniTool(ani, clipName)
			end

			if delayFunc then
				delayFunc()
			end
		end, clip.length)

		return timer, clip.length
	end
end

function M:CommonPlayAniTool2(ani, clipName, time, speed, sampleToEnd, delayFunc)
	local length = gCS.LuaUtils.PlayAnimationByName2(ani, clipName, time)

	if length > 0 then
		local timer = nil
		timer = gLuaTimeMgrUtils.NotDestroyDelay(function ()
			if sampleToEnd and ani then
				self:CommonStopAniTool(ani, clipName)
			end

			if delayFunc then
				delayFunc()
			end
		end, length)

		return timer
	end
end

function M:CommonStopAniTool(ani, clipName)
	if ani == nil or gCS.LuaUtils.IsNull(ani) then
		return
	end

	local clip = ani:GetClip(clipName)

	if clipName == nil then
		clip = ani.clip
	end

	if clip and ani.gameObject.activeInHierarchy then
		clip:SampleAnimation(ani.gameObject, clip.length)
		ani:Stop()
	end
end

function M:CommonSampleAnimation(ani, clipName, length)
	local clip = ani:GetClip(clipName)

	if clip and ani.gameObject.activeInHierarchy then
		clip:SampleAnimation(ani.gameObject, length)
		ani:Stop()
	end
end

function M:SetColorToSImage(field, color, useOldAlpha)
	if field == nil or color == nil then
		return
	end

	local oldColorAlpha = field.color.a
	local newColor = color

	if useOldAlpha then
		newColor.a = oldColorAlpha
	end

	field.color = newColor
end

function M:SetBtnFaraway(btnGo, active, refreshGrid)
	if not btnGo then
		return
	end

	btnGo:SetWidgetFaraway(not active)

	if not active then
		btnGo:InstantClearState()
	end

	self.refreshSkillBtnGrid = self.refreshSkillBtnGrid or refreshGrid
end

function M:PlayBtnFanseAni(btn, index, active)
	if not active then
		self.characterControlPanel:ClearBtnFanseAni(btn, index)
		self.characterControlPanel:ClearSkillXuliAni(btn, index)
	end
end

function M:DoSthWhenSkillBtnClose()
	local forbidSkillBtnFlag = false
	forbidSkillBtnFlag = gCoreHudUIManager:OnTriggerSkillBtnClose()
end

function M:CheckShowBtnTips(btn, template, show, nameId)
	if not gCS.LuaUtils.IsNonMobileAdaptive() or GameDevice.KeyboardMouse < self.scheme then
		return
	end

	if btn then
		btn:SetPCKeyTipShowTip(show)
		btn:SetPCKeyInfoTipNameId(nameId)
	end
end

function M:UsePCBattleHUD()
	return gCS.LuaUtils.IsNonMobileAdaptive()
end

function M:GetSkillIconImg(skillType, cfgSkill)
	local imgId = 0

	if skillType == self.SkillBtnType.Normal then
		imgId = self:GetNormalSkillImg(cfgSkill)
	elseif skillType == self.SkillBtnType.Basic then
		imgId = self:GetBasicSkillImg(cfgSkill)
	elseif skillType == self.SkillBtnType.FightSpiritBigSkill then
		imgId = self:GetBigSkillImg(cfgSkill)
	elseif skillType == self.SkillBtnType.ControlPower then
		imgId = self:GetMindPowerImg(cfgSkill)
	end

	return imgId
end

function M:GetNormalSkillImg(cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.Normal) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.Normal)
	end

	local cfgImageId = nil
	local shootModeId = gCS.GunModule.GetRawSwitchFireModeIgnoreUsingGun(self.SkillBtnType.Normal)

	if shootModeId > 0 then
		cfgImageId = self:GetShootModeImageId(shootModeId)
	end

	if cfgSkill then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	if gCoreHudUIManager.skill1State.canAssassin or gCoreHudUIManager.canBackAssassin then
		cfgImageId = gCoreHudImgManager.imgAssIconId
	elseif gCoreHudUIManager.canFeiSuoAttack then
		cfgImageId = gCoreHudImgManager.imgFeiSuoAttackId
	end

	if gPlayerManager.main.bindData.isMindPowerAim then
		cfgImageId = gCoreHudImgManager.imgThrowId
	end

	if gMainMenuMgr.isInAirOnlyHeight then
		cfgImageId = 0
	end

	if not cfgImageId or cfgImageId == 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconCommonAttack.pc or GameConfig.CommonBattleSkillIconCommonAttack.mobile
	end

	return cfgImageId
end

function M:GetBasicSkillImg(cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.Basic) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.Basic)
	end

	local cfgImageId = nil

	if cfgSkill then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	local shootModeId = gCS.GunModule.GetRawSwitchFireModeIgnoreUsingGun(self.SkillBtnType.Basic)

	if shootModeId > 0 then
		cfgImageId = self:GetShootModeImageId(shootModeId)
	end

	if not cfgImageId or cfgImageId == 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconActive.pc or GameConfig.CommonBattleSkillIconActive.mobile
	end

	return cfgImageId
end

function M:GetBigSkillImg(cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.FightSpiritBigSkill) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.FightSpiritBigSkill)
	end

	local cfgImageId = nil

	if cfgSkill then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	if not cfgImageId or cfgImageId == 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconUlt.pc or GameConfig.CommonBattleSkillIconUlt.mobile
	end

	return cfgImageId
end

function M:GetMindPowerImg(cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.ControlPower) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.ControlPower)
	end

	local cfgImageId = nil

	if cfgSkill then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	if gPlayerManager.main.bindData.isMindPowerAim then
		cfgImageId = gCoreHudImgManager.imgThrowId
	end

	if not cfgImageId or cfgImageId == 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconMind.pc or GameConfig.CommonBattleSkillIconMind.mobile
	end

	return cfgImageId
end

function M:GetHeavyAttackImg(cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.HeavyAttack) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.HeavyAttack)
	end

	local cfgImageId = nil

	if cfgSkill then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	local shootModeId = gCS.GunModule.GetRawSwitchFireModeIgnoreUsingGun(self.SkillBtnType.HeavyAttack)

	if shootModeId > 0 and shootModeId > 0 then
		cfgImageId = self:GetShootModeImageId(shootModeId)
	end

	if not cfgImageId or cfgImageId == 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconHeavyAttack.pc or GameConfig.CommonBattleSkillIconHeavyAttack.mobile
	end

	return cfgImageId
end

function M:GetNormalSkillText()
	local flag = false
	local textId = 89901016
	local highLight = false

	if gPlayerManager.main.bindData.isMindPowerAim then
		flag = true
		textId = 89901016
	end

	if gMainMenuMgr.btnAssassinateVisiable[1] == 1 then
		flag = true
		textId = 89901128
	end

	if gMainMenuMgr.btnAssassinateVisiable[3] == 1 then
		highLight = true
	end

	if self.showPlayerHint then
		highLight = true
	end

	return flag, textId, highLight
end

function M:GetShootModeImageId(shootModeId)
	local shootMode = WeaponShootShootModeConfig.GetConfig(shootModeId)
	local imageId = shootMode.ImageId

	if gCS.GunModule.IsMeInShoulderFire then
		imageId = shootMode.ExitImageId == 0 and shootMode.ImageId or shootMode.ExitImageId
	end

	return imageId
end

function M:HasBattleBottomUIShow()
	return not self.hideBattleUIFlag and self.playerHpBarActive and self.characterPartPanel and self.characterPartPanel.characterPartData.playerHpBar.isVisible and gPanelManager:VisibleModeAll()
end

function M:CheckBtnIsShow(btnHideCtrl)
	return not btnHideCtrl or btnHideCtrl == 0
end

function M:ShowFlyLockEffectUI(pid, show, uuid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	uuid = tostring(uuid)

	gHudMgr:RefreshMissileAttackMarker(pid, uuid, show)
end

function M:PlayFlyLockEffectLockAni(pid, show, uuid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	uuid = tostring(uuid)

	gHudMgr:PlayLockStateAni(pid, uuid, show)
end

function M:PlayFlyLockEffectAttackAni(pid, show, uuid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	uuid = tostring(uuid)

	gHudMgr:PlayAttackStateAni(pid, uuid, show)
end

function M:GetBattlePrototypeCommonUI_Slider()
	return self.characterPartPanel:GetBattlePrototypeCommonUI_Slider()
end

function M:GetBattlePrototypeCommonUIStore_Slider()
	return self.characterPartPanel:GetBattlePrototypeCommonUIStore_Slider()
end

function M:ShowBattlePrototypeCommonUI_Slider(enable)
	local go = self:GetBattlePrototypeCommonUI_Slider()

	go.gameObject:SetActive(enable)
end

function M:BattlePrototypeCommonUIStore_Slider_SetMaxValue(value)
	self.characterPartPanel:BattlePrototypeCommonUIStore_Slider_SetMaxValue(value)
	self:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
end

function M:BattlePrototypeCommonUIStore_Slider_SetCurValue(value)
	self.characterPartPanel:BattlePrototypeCommonUIStore_Slider_SetCurValue(value)
	self:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
end

function M:BattlePrototypeCommonUIStore_Slider_AddValue(value)
	self.characterPartPanel:BattlePrototypeCommonUIStore_Slider_AddValue(value)
	self:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
end

function M:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
	self.characterPartPanel:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
end

function M:BattlePrototypeCommonUIStore_Slider_Length(length)
	local store = gBattleMgr:GetBattlePrototypeCommonUIStore_Slider()

	store.sliderTr:SetLocalScaleX(length)
	store.sliderBgTr:SetLocalScaleX(length)
end

function M:BattlePrototypeCommonUIStore_Slider_Height(height)
	local store = gBattleMgr:GetBattlePrototypeCommonUIStore_Slider()

	store.sliderTr:SetLocalScaleY(height)
	store.sliderBgTr:SetLocalScaleY(height)
end

function M:BattlePrototypeCommonUIStore_Slider_Color(r1, g1, b1, a1, r2, g2, b2, a2)
	local store = gBattleMgr:GetBattlePrototypeCommonUIStore_Slider()
	store.sliderColor = Color.New(r1, g1, b1, a1)
	store.sliderBgColor = Color.New(r2, g2, b2, a2)
end

function M:BattlePrototypeCommonUIStore_Slider_Position(x, y, z)
	local go = gBattleMgr:GetBattlePrototypeCommonUI_Slider()

	go.gameObject:SetLocalPosition(x, y, z)
end

function M:ShowMessageTipsOnEditor(content, show)
	if show == nil then
		show = true
	end

	if gBattleMgr.ShowBattleMsg and show then
		print_warn("纯编辑器测试：" .. content)
		gDisplayMessageMgr:ShowMessageContentDebug("纯编辑器测试：" .. content)
	end
end

function M:SetBattleWeaponTemplateIdByCSharp(weaponTemplateId, shootModeId, shootId, weaponCantDiscard)
	self.battleWeaponTemplateId = weaponTemplateId
	self.shootModeId = shootModeId or 0
	self.shootId = shootId or 0
	self.weaponCantDiscard = weaponCantDiscard

	self:CheckIsPrivateWeapon(weaponTemplateId)
	self:CheckShowWeaponResHUDByTemplateId(weaponTemplateId)
	self:UpdateAmmunitionActive()
end

function M:CheckIsPrivateWeapon(weaponTemaplteId)
	local cfg = LTConfig.WeaponConfig.GetConfig(weaponTemaplteId)
	self.isPrivateWeapon = cfg and cfg.WeaponType == LTConfig.WeaponConfig.WeaponTypeType.PrivateWeapon or false
	local hasState = gMainMenuMgr:HasUnitState(UnitStateConfig.ForbidPrivateWeaponUltSkill)

	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "unitStateCfgNeedForbidPrivateWeaponUltSkill", hasState == 1 and self.isPrivateWeapon)
end

function M:RefreshFightSpiritUniqueSkillID(templateId, _curValue, _maxValue)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local skillId = gCS.BattleManager.GetUniqueSkillId()
	local skillConfig = SkillConfig.GetConfig(skillId)

	if skillConfig and skillConfig.UseSkillRes ~= nil and #skillConfig.UseSkillRes > 0 then
		for i = 1, #skillConfig.UseSkillRes do
			if skillConfig.UseSkillRes[i].Id == templateId then
				gMessageManager:SendMessage(gEventConstants.ON_REFRESH_ULT_EP, {
					skillId = skillId,
					curValue = _curValue,
					maxValue = _maxValue
				})
			end
		end
	end
end

function M:RefreshFightSpiritUniqueSkillEnergy()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local skillId = gCS.BattleManager.GetUniqueSkillId()
	local skillConfig = SkillConfig.GetConfig(skillId)

	if skillConfig and skillConfig.UseSkillRes ~= nil and #skillConfig.UseSkillRes > 0 then
		for i = 1, #skillConfig.UseSkillRes do
			local id = skillConfig.UseSkillRes[i].Id
			local cfg = SkillResourcesConfig.GetConfig(id)
			local flag, curValue, isFull, isFree = nil
			flag, curValue, isFull, isFree = gCS.BattleManager.GetFightResource(gCS.MyPlayerManager.PlayerUnit, id, 0, false, false)

			if flag and cfg then
				gMessageManager:SendMessage(gEventConstants.ON_REFRESH_ULT_EP, {
					skillId = skillId,
					curValue = curValue,
					maxValue = cfg.Max
				})
			end
		end
	end
end

function M:RefreshAmmunitionInfo(active, cur, single, total, configTotal, isByUsing)
	local characterControlStore = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	if characterControlStore then
		characterControlStore:UpdateAmmunition(cur, single, total, configTotal)
	end

	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore:UpdateAmmunition(cur, single, total, isByUsing)
	end

	gMainMenuMgr:SetAmmunitionVisiable(active)
end

function M:ShowAmmunitionInfo(visible, interactable)
	local characterControlStore = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	if characterControlStore then
		characterControlStore:ShowAmmunition(visible, interactable)
	end

	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore:ShowAmmunition(visible, interactable)
	end
end

function M:UpdateAmmunitionActive()
	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore:UpdateAmmunitionActive()
	end
end

function M:ShowOrHidePlayerHint(enable, isSucc, hintType)
	self.showPlayerHint = enable

	if hintType == 0 then
		self.showBaoShuaiHint = enable
	end

	if hintType == 1 then
		self.showWASDHint = enable

		gMessageManager:SendMessage(gEventConstants.ON_JOYSTICK_ANIM, enable)
	end

	local store = gStoreManager:GetStoreGroup("HintInfosHudStore")

	store:ShowOrHidePlayerHint(enable, isSucc, hintType)

	if self.characterControlPanel then
		self.characterControlPanel:UpdateBasicSkills(gBattleMgr.SkillBtnType.Normal)
	end
end

function M:ShowOrHideExecuteHint(enable)
	local store = gStoreManager:GetStoreGroup("HintInfosHudStore")

	store:ShowEnemyExecuteHint(enable)
end

function M:CreateAction(action)
	return function (...)
		if type(action) == "string" then
			if self[action] then
				return self[action](self, ...)
			end
		else
			return action(self, ...)
		end
	end
end

function M:CheckIsInMotorState()
	return gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.Moto) or gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.MotorbikeIdle)
end

function M:SetSkillData(skillType, skillId, normalImage, isUseLianzhaoIamge)
	self.skillData[skillType] = {
		skillId = skillId,
		normalImage = normalImage,
		isUseLianzhaoIamge = isUseLianzhaoIamge
	}
end

function M:CheckEnterMagnet(needEnter)
	if self.keyDownMagnetFrame == Time.frameCount then
		return true
	end

	local inHoldMode = false
	inHoldMode = gCS.MindPowerMgr.inHoldMode

	if (inHoldMode or needEnter and gCS.MagnetManager.isInMagnetMode) and not gCS.BattleManager.IsAnyEnemyLockMe() then
		if needEnter then
			gUnitOperateManager.isMagnetKeyDown = true
			gCS.TransitionMgr.isMagnetKeyDown = true

			if needEnter and gCS.MyPlayerManager.PlayerUnit.NoMoveTime == 0 then
				gCS.MindPowerMgr:TryDriveCurAimToMagnetStage()
			end

			gUnitOperateManager.isMagnetKeyDown = false
			gCS.TransitionMgr.isMagnetKeyDown = false
			self.keyDownMagnetFrame = Time.frameCount
		end

		return true
	end

	return false
end

function M:DownHandlerMotoBtn()
	if not gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.CanMoTo) then
		return
	end

	local hasBuff = gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, BuffConfig.Moto)
	local skillId = hasBuff and WeaponConfig.TaffeiMotoGetOffSkill or WeaponConfig.TaffeiMotoGetOnSkill
	local cs_unit = gCS.SceneDataMgr.GetUnit(gBattleSpiritMgr.currentSpiritPid)
	local ok = false
	local isTaffy = gBattleSpiritMgr.currentSpiritTemplateId == FightSpiritConfig.Taffy

	if cs_unit ~= nil and isTaffy then
		if gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, skillId) then
			ok = true
		else
			gBattleMgr:ShowMessageTipsOnEditor("塔菲上下车校验不通过" .. skillId)
		end
	end
end

function M:UpHandlerMotoBtn()
	return
end

function M:SetComboSkill(index, templateId, skillId)
	self.comboSkillData[index] = {
		t3 = 0,
		checkHoldTime = 0,
		autoSkillTime = 0,
		t2 = 0,
		check = false,
		startDownTime = 0,
		needCastInUp = false,
		down = false,
		t1 = 0,
		chargeAutoCloseTime = 0,
		t0 = 0,
		isNormal = index == gBattleMgr.SkillBtnType.Normal,
		templateId = templateId,
		skillId = skillId,
		defaultSKillId = skillId
	}

	gCoreHudUIManager:OnRefreshForComboSkill(index)
end

function M:SkillJumpReplaceIconHandler(skillType)
	M:UpdateSkillButtonIcon(skillType)
end

function M:UpdateSkillButtonIcon(skillType)
	if self.characterControlPanel then
		if skillType == SkillType.Normal or skillType == SkillType.Basic then
			self.characterControlPanel:UpdateBasicSkills(skillType)
		elseif skillType == SkillType.HeavyAttack then
			self.characterControlPanel:UpdateHeavyAttackBtn()
		elseif skillType == SkillType.ControlPower then
			self.characterControlPanel:UpdateMindPowerBtn()
		elseif skillType == SkillType.FightSpiritBigSkill then
			self.characterControlPanel:UpdateFightSpiritBigSkill()
		end

		self.characterControlPanel.isUpdateSkillBtns[skillType] = true
	end
end

function M:CheckSkillComboData()
	local cs_unit = gBattleSpiritMgr:GetBattleSpiritUnitByTid(gBattleSpiritMgr.currentSpiritTemplateId)

	if not cs_unit then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("CheckSkillComboData")
	end

	for i = 1, #self.comboSkillData do
		if i == 2 then
			local combo = self.comboSkillData[i]

			if combo then
				local isHaveCombo = gCS.SkillJumpManager.Instance:IsHaveComboSkill(cs_unit.Pid, combo.defaultSKillId)

				if isHaveCombo then
					local comboSkill = gCS.SkillJumpManager.Instance:GetComboSkill(cs_unit.Pid, combo.defaultSKillId)
					combo.check = true
					combo.skillId = combo.defaultSKillId
					combo.t0 = comboSkill.SkillTime
					combo.t1 = comboSkill.SkillTime + comboSkill.StartTime
					combo.t2 = comboSkill.SkillTime + comboSkill.TriggerTime
					combo.t3 = comboSkill.SkillTime + comboSkill.StopTime
					local cfgSkill = SkillConfig.GetConfig(comboSkill.NextSkillId)

					if cfgSkill then
						local cfgImageId = gBattleMgr:GetSkillIconImg(i, cfgSkill)

						if cfgImageId then
							combo.shortImageId = cfgImageId
						end
					end
				else
					combo.check = false
				end

				self:SetUpdateSkillBtn(i)
			end
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:IsDodgeDisable(state)
	if state == ParkourStateConfig.WingsuitFly or state == ParkourStateConfig.WalkPhone or state == ParkourStateConfig.Dive or state == ParkourStateConfig.HasEarphone then
		return true
	end

	return false
end

function M:HasDodgeDisableState()
	local disableState = false

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		disableState = disableState or self:IsDodgeDisable(state)
	end

	return disableState
end

function M:XuliKeyDown()
	gCS.TransitionMgr.isXuliKeyDown = true
	local ok = gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
	gCS.TransitionMgr.isXuliKeyDown = false

	if not ok then
		gCS.SaveActionManager.Instance:CheckSaveAction(gCS.MyPlayerManager.PlayerUnit, self.SaveActionType.Dodge)
	end
end

function M:XuliKeyUp()
	self.isXuliKeyUp = true

	if gCS.MyPlayerManager.PlayerUnit.NoMoveTime == 0 then
		gCS.LuaUtils.CheckSwitchAction(true, false, false, 0)
	end

	self.isXuliKeyUp = false
end

function M:CheckIsBanFunGun()
	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.Moto) then
		return true
	end

	return false
end

function M:OnDodgeBtnPressFunc()
	self.isPressXuliDown = true

	if self.characterControlPanel then
		self.characterControlPanel:HighSpeedDown()
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashPress)

	if not gBattleMgr.canDodge then
		gBattleMgr:ShowMessageTipsOnEditor("not self.canDodge")

		return
	end

	gBattleMgr:ShanbiKeyDownFunc()
end

function M:OnDodgeBtnReleaseFunc()
	self.isPressXuliDown = false

	if self.characterControlPanel then
		self.characterControlPanel:HighSpeedUp()
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashRelease)

	if not self.isXuliKeyPress and not gBattleMgr.canDodge then
		gBattleMgr:ShowMessageTipsOnEditor("not self.canDodge")

		return
	end

	gBattleMgr:ShanbiKeyUpFunc()
end

function M:CheckShowHandBagDropBtn()
	local show = false

	if gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.HasEarphone) then
		show = true
	end

	gMainMenuMgr:SetHandBagPutDownBtnVisiable(show)
end

function M:CheckCanShowUniqueSkillInfo(skillId)
	local cfg = SkillConfig.GetConfig(skillId)

	if not cfg then
		return false
	end

	if cfg.SkillCastTypeTag ~= SkillConfig.SkillCastTypeTagType.Unique then
		return false
	end

	return true
end

function M:HighSpeedDown()
	if self.characterControlPanel then
		self.characterControlPanel:HighSpeedDown()
	end
end

function M:HighSpeedUp()
	if self.characterControlPanel then
		self.characterControlPanel:HighSpeedUp()
	end
end

function M:ForEach(cb)
	local allUnits = gCS.SceneDataMgr.UnitsManager:GetAllUnits()

	for i = 1, allUnits.Count do
		local unit = allUnits[i - 1]

		cb(unit)
	end
end

function M:StiffTransitionConfig(transitionCondition, pid)
	return gHurtStiffManager:DoCheckConfig(transitionCondition)
end

function M:OnBVBAttackSpeedChange(pid, value)
	if gBattlePetsMgr and gBattlePetsMgr.bInBVBGame and gBattlePetsMgr.bInBVBGame == true then
		gCS.PauseManager.Instance:OnBVBAttackSpeedChange(pid, value)
	end
end

function M:UpdateStaminaBarUseEfficiency()
	if self.characterPartPanel then
		self.characterPartPanel:InitStaminaBar()
	end
end

function M:SetEnemyPoiseWeaponChangeInfo(pid, values)
	self.enemyPoiseWeaponChangeInfo[pid] = values
end

function M:GetEnemyPoiseWeaponChangeInfo(pid, weaponInstanceId)
	if self.enemyPoiseWeaponChangeInfo[pid] and self.enemyPoiseWeaponChangeInfo[pid][weaponInstanceId] then
		return self.enemyPoiseWeaponChangeInfo[pid][weaponInstanceId]
	end

	return 0
end

function M:GetRecoverTime(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return 0
	end

	local agentId = unit.ClientData.AgentId > 0 and unit.ClientData.AgentId or unit.ClientData.SubType
	local cfg = LTConfig.AgentConfig.GetConfig(agentId)
	local growthCfg = LTConfig.EnemyGrowthSchemeConfig.GetConfig(cfg.AttributeSchemeId)

	if growthCfg and growthCfg.WeakPoiseDecreaseSpeed > 0 then
		return math.max(5, (growthCfg.MaxPoiseValue - growthCfg.GetUpPoise) / growthCfg.WeakPoiseDecreaseSpeed)
	end

	return 0
end

function M:CalcEnemyDangerValue(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return false
	end

	local weapons = gWeaponManager:GetCurrentWeapons()

	if weapons == nil then
		return false
	end

	local weaponPara = 0

	for index, weapon in ipairs(weapons) do
		local cfg = WeaponConfig.GetConfig(weapon.TemplateId)
		local curWeaponPara = cfg.WeaponFightingPara

		if weaponPara < curWeaponPara then
			weaponPara = curWeaponPara
		end
	end

	local spiritActiveTalentCnt = gTalentTreeMgr:GetSpiritActiveTalent(nil, 0)
	local talentPara = WeaponConfig.TalentPointPara * spiritActiveTalentCnt
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)
	local spiritPara = 0

	if spirit then
		local allBadges = gSpiritManager:GetSpirit(tid).SpiritInfo.InfoBadge.Badges

		if allBadges then
			for k, v in pairs(allBadges) do
				if v.Active then
					local cfg = LTConfig.UrbanBadgeConfig.GetConfig(v.TemplateId)

					if cfg then
						spiritPara = spiritPara + cfg.BattlePara
					end
				end
			end
		end
	end

	local enemyFightingPara = 0
	local agentId = unit.ClientData.AgentId > 0 and unit.ClientData.AgentId or unit.ClientData.SubType
	local cfg = LTConfig.AgentConfig.GetConfig(agentId)
	local growthCfg = LTConfig.EnemyGrowthSchemeConfig.GetConfig(cfg.AttributeSchemeId)
	enemyFightingPara = growthCfg.EnemyFightingPara

	return WeaponConfig.DangerThreshold <= enemyFightingPara - (weaponPara + talentPara + spiritPara)
end

gBattleMgr = M
