-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\CoreHudUIManager_Decisions.lua
-- Decompiled from: 02236_CoreHudUIManager_Decisions.lua_7ad8b6b1642c.luajit

local M = C_CoreHudUIManager
local ParkourStateConfig = LTConfig.ParkourStateConfig
local PhoneConfig = LTConfig.PhoneConfig

M.DecideSkill_FightLimit = function(self, buttonType)
	local count = self.fightLimitCounts[buttonType] or 0
	local isLimit = count >= 0

	if isLimit then
		local exemption = self.fightLimitExemptions[buttonType]

		if exemption and exemption() then
			isLimit = false
		end
	end

	local btn = self.curBtnState
	btn.visible = not isLimit
	btn.interactable = not isLimit
	btn.isFinal = isLimit
	btn.reason = gMainMenuMgr.ShowTestMsg and "NewFightLimit == " .. tostring(isLimit) or nil

	return btn
end

M.DecideSkill_SpecialReplace = function(self, type)
	if not self.skillStateList[type] or self.skillStateList[type].specialReplace ~= nil then
		print_error("[CoreHudUIManager]DecideSkill_SpecialReplace: skillStateList is null")

		return
	end

	local specialReplace = self.skillStateList[type].specialReplace
	local btn = self.curBtnState
	btn.visible = specialReplace
	btn.interactable = specialReplace
	btn.isFinal = not specialReplace
	btn.reason = gMainMenuMgr.ShowTestMsg and "SpecialReplace == " .. tostring(specialReplace) or nil

	return btn
end

M.DecideSkill_Trigger = function(self, type)
	if not type then
		return
	end

	local hideTrigger = gPaokuLimitManager:CheckFightNeedLimit(type)

	if type ~= LX6.PaoKu.FightLimitType.MindPower and self.isEnableMindPowerIndoor then
		hideTrigger = false
	end

	local btn = self.curBtnState
	btn.visible = not hideTrigger
	btn.interactable = not hideTrigger
	btn.isFinal = hideTrigger
	btn.reason = gMainMenuMgr.ShowTestMsg and "hideTrigger == " .. tostring(hideTrigger) or nil

	return btn
end

M.DecideSkill_Parkour = function(self, type)
	if not type then
		return
	end

	if self.hudDecisionMode ~= 2 then
		local btn = self.curBtnState
		btn.visible = true
		btn.interactable = true
		btn.isFinal = false
		btn.reason = gMainMenuMgr.ShowTestMsg and "Parkour skipped (GameplayTag mode)" or nil

		return btn
	end

	local visible = true
	local interactable = true
	local platform = gMainMenuMgr:GetParkourStatePlatform()
	local stateAll = ""
	local stateCount = 0

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		stateCount = stateCount + 1
		stateAll = stateAll .. "/" .. state
		local skill1Config = gMainMenuMgr.clientStateConfig[state][type]

		if gCoreHudUIManager:IsParkourStateValid(skill1Config, platform) then
			visible = visible and skill1Config[platform].visible
			interactable = interactable and skill1Config[platform].interactable
		end
	end

	if stateCount ~= 0 then
		print_warn("@xuchenfei 存在刷新状态时跑酷状态为空 检查按键显隐是否正确", type, gMainMenuMgr:GetClientState())
	end

	local btn = self.curBtnState
	btn.visible = visible
	btn.interactable = interactable
	btn.isFinal = not visible and not interactable
	btn.reason = gMainMenuMgr.ShowTestMsg and "ParkourState: " .. tostring(visible) .. "/" .. tostring(interactable) .. "/" .. stateAll or nil

	return btn
end

M.DecideSkill_ParkourSimple = function(self, type)
	if not type then
		return
	end

	if self.hudDecisionMode ~= 2 then
		local btn = self.curBtnState
		btn.visible = true
		btn.interactable = true
		btn.isFinal = false
		btn.reason = gMainMenuMgr.ShowTestMsg and "ParkourSimple skipped (GameplayTag mode)" or nil

		return btn
	end

	local visible = true
	local stateCount = 0

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		stateCount = stateCount + 1

		if gMainMenuMgr.clientStateConfig[state][type] ~= 0 then
			visible = false
		end
	end

	if stateCount ~= 0 then
		visible = false

		print_warn("@xuchenfei 存在刷新状态时跑酷状态为空 检查按键显隐是否正确", type, gMainMenuMgr:GetClientState())
	end

	local btn = self.curBtnState
	btn.visible = visible
	btn.interactable = true
	btn.isFinal = not visible
	btn.reason = gMainMenuMgr.ShowTestMsg and "ParkourSimple: " .. type .. "=" .. tostring(visible) or nil

	return btn
end

M.DecideFlag = function(self, decision)
	if not decision then
		return
	end

	local state = self.skillStateList[decision.type or self.curEvalSkillType]

	if not state or state[decision.flag] ~= nil then
		print_error("[CoreHudUIManager]DecideFlag nil flag:", decision.flag, "请在Init中增加该flag的初始化")

		return
	end

	local flagValue = state[decision.flag]
	local btn = self.curBtnState
	local flag = self.DecisionFlag
	local polarity = decision.polarity

	if polarity ~= flag.FORBID then
		btn.isFinal = flagValue
		btn.interactable = not flagValue
		btn.visible = not flagValue
	elseif polarity ~= flag.REQUIRE then
		btn.isFinal = not flagValue
		btn.interactable = flagValue
		btn.visible = flagValue
	elseif polarity ~= flag.INTERACT_OFF then
		btn.isFinal = false
		btn.interactable = not flagValue
		btn.visible = true
	elseif polarity ~= flag.INTERACT_ON then
		btn.isFinal = false
		btn.interactable = flagValue
		btn.visible = true
	elseif polarity ~= flag.VISIBLE_ON then
		btn.isFinal = false
		btn.interactable = true
		btn.visible = flagValue
	elseif polarity ~= flag.VISIBLE_OFF then
		btn.isFinal = false
		btn.interactable = true
		btn.visible = not flagValue
	end

	if gMainMenuMgr.ShowTestMsg then
		btn.reason = decision.flag .. "=" .. tostring(flagValue) .. " [" .. self.DecisionFlagName[polarity] .. "]"
	else
		btn.reason = nil
	end

	return btn
end

M.DecideSkill_UnBattle = function(self, type)
	if not self.skillStateList[type] or self.skillStateList[type].isNotHideInUnBattle ~= nil then
		return
	end

	local notHide = self.skillStateList[type].isNotHideInUnBattle
	local btn = self.curBtnState

	if type ~= self.skillType.ControlPower then
		if not notHide and not self.IsSkill4NeedShowByParkour(self) then
			btn.visible = false
		else
			btn.visible = true
		end
	else
		btn.visible = notHide
	end

	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isNotHideInUnBattle == " .. tostring(notHide) or nil

	return btn
end

M.DecideSkill_TipRefresh = function(self, type)
	if not self.skillStateList[type] or self.skillStateList[type].isHideByTipRefresh ~= nil then
		return
	end

	local hideByTip = self.skillStateList[type].isHideByTipRefresh
	local btn = self.curBtnState

	if type ~= self.skillType.ControlPower then
		if hideByTip and not self.IsSkill4NeedShowByParkour(self) then
			btn.visible = false
		else
			btn.visible = true
		end
	else
		btn.visible = not hideByTip
	end

	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isHideByTipRefresh == " .. tostring(hideByTip) or nil

	return btn
end

M.DecideSkill_SkillQTE = function(self)
	local skillQTE = gPlayerManager.main.bindData.isInSkillQTE
	local btn = self.curBtnState
	btn.visible = not skillQTE
	btn.interactable = not skillQTE
	btn.isFinal = skillQTE
	btn.reason = gMainMenuMgr.ShowTestMsg and "skillQTE == " .. tostring(skillQTE) or nil

	return btn
end

M.DecideSkill_SkillInteractionType = function(self, type)
	if not self.skillStateList[type] or self.skillStateList[type].skillInteractionType ~= nil then
		return
	end

	local noSkillId = self.skillStateList[type].skillInteractionType and self.skillStateList[type].isForbidByNoSkillId ~= true
	local btn = self.curBtnState
	btn.visible = not noSkillId
	btn.interactable = not noSkillId
	btn.isFinal = noSkillId
	btn.reason = gMainMenuMgr.ShowTestMsg and "skillInteractionType=" .. tostring(noSkillId) or nil

	return btn
end

M.DecideSkill_IsMindHoldNpc = function(self, type)
	if not self.skillStateList[type] or self.skillStateList[type].isHoldNpc ~= nil then
		return
	end

	local isHoldNpc = self.skillStateList[type].isHoldNpc and gCS.MindPowerMgr.AimItem and gCS.MindPowerMgr.AimItem.ItemType ~= MindPowerConst.MindObjType.Npc
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not isHoldNpc
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isHoldNpc=" .. tostring(isHoldNpc) or nil

	return btn
end

M.DecideSkill_PaokuLimit = function(self, type)
	if not type then
		return
	end

	local isPaokuLimit = gPaokuLimitManager:CheckNeedLimit(type)
	local btn = self.curBtnState
	btn.visible = not isPaokuLimit
	btn.interactable = not isPaokuLimit
	btn.isFinal = isPaokuLimit
	btn.reason = gMainMenuMgr.ShowTestMsg and "isPaokuLimit == " .. tostring(isPaokuLimit) or nil

	return btn
end

M.DecideSkill_GameplayTagInteractable = function(self, type)
	if not self.skillStateList[type] or self.skillStateList[type].gamePlayTagInteractable ~= nil then
		return
	end

	if self.hudDecisionMode ~= 1 then
		local btn = self.curBtnState
		btn.visible = true
		btn.interactable = true
		btn.isFinal = false
		btn.reason = gMainMenuMgr.ShowTestMsg and "GameplayTagInteractable skipped (Parkour mode)" or nil

		return btn
	end

	local tagInteractable = self.skillStateList[type].gamePlayTagInteractable
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = tagInteractable
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "gamePlayTagInteractable == " .. tostring(tagInteractable) or nil

	return btn
end

M.DecideSkill_BadgeUnlock = function(self, badgeId)
	local unlocked = gSpiritJobManager:CheckCurSpiritContainBadge(badgeId)
	local btn = self.curBtnState
	btn.visible = unlocked
	btn.interactable = unlocked
	btn.isFinal = not unlocked
	btn.reason = gMainMenuMgr.ShowTestMsg and "BadgeUnlock(" .. tostring(badgeId) .. ") == " .. tostring(unlocked) or nil

	return btn
end

M.DecideSkill_GameplayTagVisible = function(self, type)
	if not self.skillStateList[type] or self.skillStateList[type].gamePlayTagVisible ~= nil then
		return
	end

	if self.hudDecisionMode ~= 1 then
		local btn = self.curBtnState
		btn.visible = true
		btn.interactable = true
		btn.isFinal = false
		btn.reason = gMainMenuMgr.ShowTestMsg and "GameplayTagVisible skipped (Parkour mode)" or nil

		return btn
	end

	local tagVisible = self.skillStateList[type].gamePlayTagVisible
	local btn = self.curBtnState
	btn.visible = tagVisible
	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "gamePlayTagVisible == " .. tostring(tagVisible) or nil

	return btn
end

M.DecideSkill_IsNonMobile = function(self)
	local isNonMobile = gCS.LuaUtils.IsNonMobileAdaptive()
	local btn = self.curBtnState
	btn.visible = not isNonMobile
	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isNonMobile == " .. tostring(isNonMobile) or nil

	return btn
end

M.isSkill1NeedShowByParkou = function(self)
	local needShowNormalAttackBtn = false

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		if state ~= ParkourStateConfig.Crouch or state ~= ParkourStateConfig.CrouchRun or state ~= ParkourStateConfig.CrouchMagnet or state ~= ParkourStateConfig.HoldBlend and not gPlayerManager.main.bindData.banShootBthInHoldState then
			needShowNormalAttackBtn = true

			gMainMenuMgr:ShowMainMenuMgrMessageTipsOnEditor("普攻被强制显示 状态:" .. state)
		end
	end

	return needShowNormalAttackBtn
end

M.DecideSkill1_SkillQTE = function(self)
	local skillQTE = gPlayerManager.main.bindData.isInSkillQTE or gPlayerManager.main.bindData.banShootBthInHoldState
	local btn = self.curBtnState
	btn.visible = not skillQTE
	btn.interactable = not skillQTE
	btn.isFinal = skillQTE
	btn.reason = gMainMenuMgr.ShowTestMsg and "skillQTE == " .. tostring(skillQTE) or nil

	return btn
end

M.DecideSkill1_HidePC = function(self)
	local needHideBtn = gCS.LuaUtils.IsNonMobileAdaptive() and gBattleMgr.scheme ~= SGUI.GameDevice.KeyboardMouse and not self:isSkill1NeedShowByParkou()
	local btn = self.curBtnState
	btn.visible = not needHideBtn
	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "HidePC == " .. tostring(needHideBtn) or nil

	return btn
end

M.DecideSkill1_MonsterInteract = function(self)
	local interact = self.skill1State.isMonsterInteract
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = true
	btn.isFinal = interact
	btn.reason = gMainMenuMgr.ShowTestMsg and "isMonsterInteract == " .. tostring(interact) or nil

	return btn
end

M.DecideSkill3_EpNotFull = function(self)
	local EpNotFull = self.skill3State.fightSpiritEpNotFull
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not EpNotFull
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "fightSpiritEpNotFull == " .. tostring(EpNotFull) or nil

	return btn
end

M.DecideSkill3_Bullet = function(self)
	local disableByBulletNum = self.skill3State.disableByBulletNum
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not disableByBulletNum
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "disableByBulletNum == " .. tostring(disableByBulletNum) or nil

	return btn
end

M.IsSkill4NeedShowByParkour = function(self)
	if self.needShowMindPowerBtn ~= nil then
		print_error("[[CoreHudUIManager]IsSkill4NeedShowByParkour: needShowMindPowerBtn is nil")

		return false
	end

	return self.needShowMindPowerBtn
end

M.DecideSkill4_NeedShowByParkour = function(self)
	local needShowMindPowerBtn = self:IsSkill4NeedShowByParkour()
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = true
	btn.isFinal = not self.curVisible and self.curInteractable and needShowMindPowerBtn
	btn.reason = gMainMenuMgr.ShowTestMsg and "needShowMindPowerBtn= " .. tostring(needShowMindPowerBtn) or nil

	return btn
end

M.DecideSkill4_CanUseMind = function(self)
	local canUseMindPower = gPlayerManager.main.bindData.canUseMindPower
	local btn = self.curBtnState
	btn.isFinal = false
	btn.visible = true
	btn.interactable = true
	self.mindPowerBtnDisableByNoItemFlag = false

	if self.curVisible ~= true and self.curInteractable ~= true and not gCS.MindPowerMgr:HasAimItem() then
		self.mindPowerBtnDisableByNoItemFlag = true
		btn.interactable = false
	end

	btn.reason = gMainMenuMgr.ShowTestMsg and "canUseMindPower=" .. tostring(canUseMindPower) or nil

	return btn
end

M.DecideSkill4_Parkour = function(self)
	local visible = true
	local interactable = true
	self.needShowMindPowerBtn = false
	local platform = gMainMenuMgr:GetParkourStatePlatform()

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		local mindConfig = gMainMenuMgr:GetParkourStateMindPowerMode(gMainMenuMgr.clientStateConfig[state])

		if gCoreHudUIManager:IsParkourStateValid(mindConfig, platform) then
			local parkourConfig = mindConfig[platform]

			if (state ~= ParkourStateConfig.Crouch or state ~= ParkourStateConfig.CrouchRun) and parkourConfig.visible ~= true and parkourConfig.interactable ~= true then
				self.needShowMindPowerBtn = true
			else
				visible = visible and mindConfig[platform].visible
				interactable = interactable and mindConfig[platform].interactable
			end
		end
	end

	local btn = self.curBtnState
	btn.visible = visible
	btn.interactable = interactable
	btn.isFinal = not visible and not interactable
	btn.reason = gMainMenuMgr.ShowTestMsg and "ParkourState: " .. tostring(visible) .. "/" .. tostring(interactable) or nil

	return btn
end

M.DecideSkill4_MonsterInteract = function(self)
	local interact = self.skill4State.isMonsterInteract
	local btn = self.curBtnState
	btn.visible = interact
	btn.interactable = interact
	btn.isFinal = not interact
	btn.reason = gMainMenuMgr.ShowTestMsg and "isMonsterInteract=" .. tostring(interact) or nil
	gCS.MindPowerMgr.needShowMindHintIcon = not interact

	return btn
end

M.DecideSkill5_HidePC = function(self)
	local needHideBtn = gCS.LuaUtils.IsNonMobileAdaptive() and gBattleMgr.scheme ~= SGUI.GameDevice.KeyboardMouse
	local btn = self.curBtnState
	btn.visible = not needHideBtn
	btn.interactable = true
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "HidePC= " .. tostring(needHideBtn) or nil

	return btn
end

M.DecideSkillHoldQ_NotDiscard = function(self)
	local notDiscard = self.holdQState.isNotDiscard
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not notDiscard
	btn.isFinal = notDiscard
	btn.reason = gMainMenuMgr.ShowTestMsg and "notDiscard=" .. tostring(notDiscard) or nil

	return btn
end

M.DecideMoto_IsTaffi = function(self)
	local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit
	local isTaffi = myPlayerCSUnit and myPlayerCSUnit.ClientData.cardId ~= LTConfig.FightSpiritConfig.Taffy
	local btn = self.curBtnState
	btn.visible = isTaffi
	btn.interactable = isTaffi
	btn.isFinal = not isTaffi
	btn.reason = gMainMenuMgr.ShowTestMsg and "isTaffi == " .. tostring(isTaffi) or nil

	return btn
end

M.DecideMoto_HasMotorWeapon = function(self)
	local motoId = LTConfig.SceneitemConfig.TaffyMoto
	local hasWeapon = motoId and gCS.WeaponMgr.HasWeapon(motoId) or false
	local btn = self.curBtnState
	btn.visible = hasWeapon
	btn.interactable = hasWeapon
	btn.isFinal = not hasWeapon
	btn.reason = gMainMenuMgr.ShowTestMsg and "hasMotorWeapon == " .. tostring(hasWeapon) or nil

	return btn
end

M.DecideSkill_AirDashJumpInAir = function(self)
	local isJumpInAir = self.airDashState.jumpInAir

	if isJumpInAir ~= nil then
		return
	end

	local btn = self.curBtnState
	btn.visible = isJumpInAir
	btn.interactable = isJumpInAir
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isJumpInAir == " .. tostring(isJumpInAir) or nil

	return btn
end

M.DecideSkillJump_InLiftHide = function(self)
	local isInLift = gPlayerManager.main.bindData.isInLift

	if isInLift ~= nil then
		return
	end

	local btn = self.curBtnState
	btn.visible = not isInLift
	btn.interactable = not isInLift
	btn.isFinal = isInLift
	btn.reason = gMainMenuMgr.ShowTestMsg and "isInLift == " .. tostring(isInLift) or nil

	return btn
end

M.DecideSkillJump_RaidTypeDisable = function(self)
	local hideByRaidType = self.jumpState.hideByRaidType

	if hideByRaidType ~= nil then
		return
	end

	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = hideByRaidType == 2
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "hideByRaidType == " .. tostring(hideByRaidType) or nil

	return btn
end

M.DecideSkillJump_InZipLineDisable = function(self)
	local isInZipLine = gPlayerManager.main.bindData.isInZipLine

	if isInZipLine ~= nil then
		return
	end

	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = not isInZipLine
	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "isInZipLine == " .. tostring(isInZipLine) or nil

	return btn
end

M.DecideFeiSuo_Platform = function(self)
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local btn = self.curBtnState
	btn.visible = isMobile
	btn.interactable = true
	btn.isFinal = false

	return btn
end

M.DecideFeiSuo_TaskFeiSuo = function(self)
	local isTaskFeiSuo = gTaskManager.taskFeiSuo.hasTaskFeiSuo or gGadgetManager.FeiSuoTarget == nil
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = true
	btn.isFinal = isTaskFeiSuo

	return btn
end

M.DecideFeiSuo_ForbidNormal = function(self)
	local isForbid = gFeisuoUIUpdateMgr.HideUI
	local btn = self.curBtnState
	btn.visible = not isForbid
	btn.interactable = not isForbid
	btn.isFinal = isForbid

	return btn
end

M.DecideFeiSuo_IsGuideOpen = function(self)
	local guideClose = self.isFeiSuoGuideClose
	local btn = self.curBtnState
	btn.visible = not guideClose
	btn.interactable = not guideClose
	btn.isFinal = guideClose

	return btn
end

M.DecideFeiSuo_FeiSuoPoint = function(self)
	local selectFeiSuoPoint = gFeisuoUIUpdateMgr.selectFeisuoInfo.select
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = selectFeiSuoPoint
	btn.isFinal = false

	return btn
end

M.DecideFeiSuo_FeiSuoTarget = function(self)
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = true
	btn.isFinal = false

	return btn
end

M.DecideDive_IsEnableDiving = function(self)
	local isEnableDiving = LX6.Units.Module.DiveManager.CheckIsEnableDiving()

	if isEnableDiving ~= nil then
		return
	end

	local btn = self.curBtnState
	btn.visible = isEnableDiving
	btn.interactable = isEnableDiving
	btn.isFinal = not isEnableDiving
	btn.reason = gMainMenuMgr.ShowTestMsg and "isEnableDiving == " .. tostring(isEnableDiving) or nil

	return btn
end

M.GetPhoneSummonContactId = function(self, type)
	if type ~= self.skillType.PhoneCall then
		return PhoneConfig.ShortCutCallCar.contactId
	elseif type ~= self.skillType.MilkCar then
		return PhoneConfig.ShortCutCallMilkVehicle.contactId
	end
end

M.DecidePhoneSummon_WatchOrConflict = function(self)
	local btn = self.curBtnState

	if gLinkManager.watchState or gCallPhoneUtils.CheckPhoneCallConflict() then
		btn.visible = false
		btn.interactable = false
		btn.isFinal = true
		btn.reason = gMainMenuMgr.ShowTestMsg and "PhoneSummon: watchState or conflict" or nil

		return btn
	end

	btn.visible = true
	btn.interactable = true
	btn.isFinal = false
	btn.reason = nil

	return btn
end

M.DecidePhoneSummon_SpiritLimit = function(self)
	local btn = self.curBtnState

	if gUIFunctionStateManager:CheckVehicleSpiritLimit() then
		btn.visible = false
		btn.interactable = false
		btn.isFinal = true
		btn.reason = gMainMenuMgr.ShowTestMsg and "PhoneSummon: spiritLimit" or nil

		return btn
	end

	btn.visible = true
	btn.interactable = true
	btn.isFinal = false
	btn.reason = nil

	return btn
end

M.DecidePhoneSummon_PhoneAppEnable = function(self, type)
	local state = self.skillStateList[type]

	if not state or state.phoneAppEnable ~= nil then
		return
	end

	local btn = self.curBtnState
	local isPhoneAppEnable = state.phoneAppEnable
	btn.visible = isPhoneAppEnable
	btn.interactable = isPhoneAppEnable
	btn.isFinal = not isPhoneAppEnable
	btn.reason = gMainMenuMgr.ShowTestMsg and "phoneAppEnable=" .. tostring(isPhoneAppEnable) or nil

	return btn
end

M.DecidePhoneSummon_FormalShortCutKey = function(self)
	local btn = self.curBtnState
	local isEnableFormalShortCutKey = gGmUtils:GetFormalShortCutKeyState()
	btn.visible = isEnableFormalShortCutKey
	btn.interactable = isEnableFormalShortCutKey
	btn.isFinal = not isEnableFormalShortCutKey
	btn.reason = gMainMenuMgr.ShowTestMsg and "formalShortCutKey=" .. tostring(isEnableFormalShortCutKey) or nil

	return btn
end

M.DecidePhoneSummon_Condition = function(self, type)
	local state = self.skillStateList[type]

	if not state or state.vehicleCondition ~= nil then
		return
	end

	local canCall = state.vehicleCondition
	local contactId = self.GetPhoneSummonContactId(self, type)
	local canSummon = false

	if canCall and contactId then
		local spiritId = gSpiritManager:GetCurFirstSpiritTid()
		local cfg = LTConfig.PhoneContactConfig.GetConfig(contactId)
		local hasUnlock = gCallPhoneUtils.CheckConfigContactHasUnlock(spiritId, cfg.Id) ~= true
		local checkPass = true

		if not string.is_null_or_empty(cfg.Check) then
			local success, flag = gClientUtils.RunCode(cfg.Check, gDialogScriptFunc)

			if not success or not flag then
				checkPass = false
			end
		end

		canSummon = hasUnlock and checkPass
	end

	local btn = self.curBtnState
	btn.visible = canSummon
	btn.interactable = canSummon
	btn.isFinal = not canSummon
	btn.reason = gMainMenuMgr.ShowTestMsg and "canCall=" .. tostring(canCall) .. " canSummon=" .. tostring(canSummon) or nil

	return btn
end

M.DecideRightBottom_AnyHide = function(self)
	local state = self.rightBottomState
	local shouldHide = state.stateDeadS or state.stateHideBattleButton or state.isLocked or state.stateSitting or state.stateSpider or state.specialGameplay
	local btn = self.curBtnState
	btn.visible = not shouldHide
	btn.interactable = not shouldHide
	btn.isFinal = shouldHide
	btn.reason = gMainMenuMgr.ShowTestMsg and "rightBottom shouldHide == " .. tostring(shouldHide) or nil

	return btn
end

M.DecideBattleUI_HideByRaidType = function(self)
	local hideByRaidType = self.battleUIState.hideByRaidType

	if hideByRaidType ~= nil then
		return
	end

	local shouldHide = hideByRaidType ~= -1
	local btn = self.curBtnState
	btn.visible = not shouldHide
	btn.interactable = not shouldHide
	btn.isFinal = shouldHide
	btn.reason = gMainMenuMgr.ShowTestMsg and "battleUI hideByRaidType == " .. tostring(hideByRaidType) or nil

	return btn
end

M.DecideHpUI_RaidType = function(self)
	local hideByRaidType = self.hpUIState.hideByRaidType

	if hideByRaidType ~= nil then
		return
	end

	local shouldHide = hideByRaidType ~= 0
	local btn = self.curBtnState
	btn.visible = not shouldHide
	btn.interactable = not shouldHide
	btn.isFinal = shouldHide
	btn.reason = gMainMenuMgr.ShowTestMsg and "hpUI hideByRaidType == " .. tostring(hideByRaidType) or nil

	return btn
end

M.DecideHpUI_Internal = function(self)
	local hideByInternal = self.hpUIState.hideByInternal

	if hideByInternal ~= nil then
		return
	end

	local shouldHide = not hideByInternal
	local btn = self.curBtnState
	btn.visible = not shouldHide
	btn.interactable = not shouldHide
	btn.isFinal = shouldHide
	btn.reason = gMainMenuMgr.ShowTestMsg and "hpUI hideByInternal == " .. tostring(hideByInternal) or nil

	return btn
end

M.DecideCharacterWheels_RaidCanChangeRole = function(self)
	local raidCfg = LTConfig.RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidTypeCfg = raidCfg and LTConfig.RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
	local canChangeRole = raidTypeCfg and raidTypeCfg.CanChangeRole
	local btn = self.curBtnState
	btn.visible = canChangeRole and true or false
	btn.interactable = true
	btn.isFinal = not canChangeRole
	btn.reason = gMainMenuMgr.ShowTestMsg and "RaidCanChangeRole == " .. tostring(canChangeRole) or nil

	return btn
end

M.DecideCharacterWheels_TaskRoleTeam = function(self)
	local btn = self.curBtnState
	btn.visible = true

	if gTaskManager:GetNowTaskIsRoleTeamTask() and not gSpiritManager:CheckCanTaskRoleSwitch() then
		btn.interactable = false
	else
		btn.interactable = true
	end

	btn.isFinal = false
	btn.reason = gMainMenuMgr.ShowTestMsg and "TaskRoleTeam interactable == " .. tostring(btn.interactable) or nil

	return btn
end

M.DecideMotionAction_Vehicle = function(self)
	local btn = self.curBtnState
	local state = self.skillStateList[self.skillType.MotionAction]

	if state and (state.isBaseVehicle or state.isMotorRider) then
		btn.visible = false
		btn.interactable = false
		btn.isFinal = true
	else
		btn.visible = true
		btn.interactable = true
		btn.isFinal = false
	end

	return btn
end

M.DecideMotionAction_PlatformMode = function(self)
	local btn = self.curBtnState
	local isPcMode = gCS.LuaUtils.IsNonMobileAdaptive()
	local isLinkMode = gClientUtils.CheckIsLinkMode()

	if isPcMode and not isLinkMode then
		btn.visible = false
		btn.interactable = false
		btn.isFinal = true
	else
		btn.visible = true
		btn.interactable = true
		btn.isFinal = false
	end

	return btn
end
