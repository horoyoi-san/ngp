local SkillConfig = LTConfig.SkillConfig
local GameConfig = LTConfig.GameConfig
local DragEventListener = SGUI.EventSystems.DragEventListener
C_KeSiControlsStore = DefClass("C_KeSiControlsStore", C_KeSiControlsStore, C_StoreGroup)
GroupName2Class.KeSiControlsStore = C_KeSiControlsStore
local M = C_KeSiControlsStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.btnStore = {}
	self.isUpdateSkillBtns = {}
	self.aniControlDazhaos = {}
	self.changeSkillCountDownData = {}
	self.isUltSkill = false
	self.isWaitforTweens = {}
	self.xuliBtnAniList = {}
	self.bigSkillOpenAniNamePc = "s_vx_HudSkillBtn_dazhao_new"
	self.bigSkillCloseAniNamePc = "s_vx_HudSkillBtn_dazhao_new_close"
	self.bigSkillOpenAniNameM = "s_vx_HudSkillBtn_dazhao_M"
	self.bigSkillCloseAniNameM = "s_vx_HudSkillBtn_dazhao_M_close"
	self.btnDownFanseAniPc = "s_vx_HudSkillbtn_fanse_PC_new"
	self.btnUpFanseAniPc = "s_vx_HudSkillbtn_fanse_PC_up_new"
	self.xuliCdAniNamePc = "s_vx_HudSkillBtn_xuli_cd_new"
	self.dragButtons = {
		"dodgeBtn",
		"normalAttackBtn"
	}
end

function M:DefineAllEnumsAutoGen()
	self.energyCtrlEnum = {
		Charge = 1,
		normal = 0
	}
	self.btnInCDCtrlEnum = {
		_false = 0,
		_true = 1
	}
	self.btnHideCtrlEnum = {
		_false = 0,
		_true = 1
	}
	self.skillTypeCtrlEnum = {
		MultiCharge = 2,
		MultiPhase = 1,
		Normal = 0
	}
	self.multiChrageCDCtrlEnum = {
		Ready = 1,
		InCd = 2,
		None = 0
	}
	self.wordsCtrlEnum = {
		False = 0,
		True = 1
	}
	self.buttonCtrlEnum = {
		s_highlight = 7,
		s_pressed = 6,
		highlight = 2,
		s_focus = 8,
		s_normal = 5,
		disabled = 4,
		pressed = 1,
		focus = 3,
		normal = 0
	}
	self.qteVxCtrlEnum = {
		default2 = 2,
		_false = 0,
		show = 1
	}
end

function M:ClearAllEnumsAutoGen()
	self.energyCtrlEnum = nil
	self.btnInCDCtrlEnum = nil
	self.btnHideCtrlEnum = nil
	self.skillTypeCtrlEnum = nil
	self.multiChrageCDCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.buttonCtrlEnum = nil
	self.qteVxCtrlEnum = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)

	self.normalAttackBtn = self:GetStoreByWidget(self.bindData.normalAttackBtn)
	self.basicSkillBtn = self:GetStoreByWidget(self.bindData.basicSkillBtn)
	self.ultSkillBtn = self:GetStoreByWidget(self.bindData.ultSkillBtn)
	self.blockBtn = self:GetStoreByWidget(self.bindData.blockBtn)
	self.dodgeBtn = self:GetStoreByWidget(self.bindData.dodgeBtn)
	self.btnStore[gBattleMgr.SkillBtnType.Normal] = self.normalAttackBtn
	self.btnStore[gBattleMgr.SkillBtnType.Basic] = self.basicSkillBtn
	self.btnStore[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = self.ultSkillBtn
	self.btnStore[gBattleMgr.SkillBtnType.HeavyAttack] = self.blockBtn
end

function M:OnGroupDisable()
	self:ClearMessageEvents()

	self.normalAttackBtn = nil
	self.basicSkillBtn = nil
	self.ultSkillBtn = nil
	self.blockBtn = nil
	self.dodgeBtn = nil
	self.btnStore = nil
end

function M:OnShow(panelId, data)
	self:SyncRefreshBasicSkills()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.SYNC_REFRESH_BASIC_SKILL] = self:CreateAction("SyncRefreshBasicSkills"),
		[gEventConstants.ON_UPDATE_SKILL_BTN] = self:CreateAction("UpdateSkillBtns"),
		[gEventConstants.SYNC_REFRESH_FIGHT_SKILL] = self:CreateAction("UpdateFightSpiritBigSkill"),
		[gEventConstants.ON_UPDATE_SKILL_CD] = self:CreateAction("UpdateSkillCD"),
		[gEventConstants.ON_REFRESH_ULT_EP] = self:CreateAction("UpdateCdAndEp")
	}
end

function M:RegisterWidget()
	self.bindData.normalAttackBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressBegin", 1)
	self.bindData.normalAttackBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 1)
	self.bindData.normalAttackBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 1)
	self.bindData.basicSkillBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressBegin", 2)
	self.bindData.basicSkillBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 2)
	self.bindData.basicSkillBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 2)
	self.bindData.ultSkillBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressBegin", 3)
	self.bindData.ultSkillBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 3)
	self.bindData.ultSkillBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 3)
	self.bindData.blockBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressBegin", 5)
	self.bindData.blockBtn.luaLongPress = self:CreateActionWithArgs("OnMergeBtnLongPress", 5)
	self.bindData.blockBtn.luaEndLongPress = self:CreateActionWithArgs("OnMergeBtnLongPressEnd", 5)
	self.bindData.dodgeBtn.luaBeginLongPress = self:CreateAction("OnDodgeBtnLongPressBegin")
	self.bindData.dodgeBtn.luaLongPress = self:CreateAction("OnDodgeBtnLongPress")
	self.bindData.dodgeBtn.luaEndLongPress = self:CreateAction("OnDodgeBtnLongPressEnd")

	if self.bindData.rightStickRespond then
		self.needUpdateCamera = false
		self.rightStickValue = {
			x = 0,
			y = 0
		}
		self.bindData.rightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
	end

	for _, btn in ipairs(self.dragButtons) do
		local btn = self.bindData[btn]

		if btn then
			local dragListener = DragEventListener.Get(btn.gameObject)
			dragListener.onDrag = self:CreateAction("OnDragBtnDraging")
		end
	end
end

function M:SyncRefreshBasicSkills(eventId, index)
	self:UpdateBasicSkills(index)
	self:UpdateHeavyAttackBtn()
	self:UpdateFightSpiritBigSkill()

	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.Normal] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.Basic] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = true
	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.HeavyAttack] = true
end

function M:OnUpdate()
	self:UpdateSkillBtns()
	self:UpdateGamepadCamera()
end

function M:UpdateSkillCD(eventId, skillId)
	for i = gBattleMgr.SkillBtnType.Normal, gBattleMgr.SkillBtnType.HeavyAttack do
		local skillData = gBattleMgr.skillData[i]

		if skillData and skillData.skillId ~= 0 and gBattleMgr:IsBtnContainSkillId(skillData.skillId, skillId) then
			self.isUpdateSkillBtns[i] = true
		end
	end

	local fightList = gBattleSpiritMgr:GetBattleSpiritList()

	if fightList then
		for i, spiritData in pairs(fightList) do
			local uniqueSkill = gCS.BattleManager.GetUniqueSkillId(spiritData.pid)

			if uniqueSkill == skillId then
				self.isUpdateSpirit = true
			end
		end
	end
end

function M:UpdateSkillBtns()
	for i = 1, #self.btnStore do
		if self.isUpdateSkillBtns[i] then
			self:UpdateSkill(i)
		end
	end
end

function M:UpdateSkill(index)
	if index == gBattleMgr.SkillBtnType.Normal then
		return
	end

	self.isUpdateSkillBtns[index] = false
	local cdData = gBattleMgr.skillData[index]
	local comboData = gBattleMgr.comboSkillData[index]

	if not cdData or not comboData then
		return
	end

	local objs = self.btnStore[index]
	local calCDSkillId = gBattleMgr:GetShareCDSkillId(cdData.skillId)
	local fillAmount, labelTimeLeft, isHide, curCharges, maxCharges = gBattleMgr:CalculateSkillCDResult(calCDSkillId)
	local isShowCD = not isHide and labelTimeLeft > 0

	self:UpdateSkill_MultiUseSkill(index, objs, comboData, isShowCD, maxCharges, curCharges, fillAmount, labelTimeLeft)

	if maxCharges <= 1 then
		if not comboData.check then
			self:UpdateSkill_Normal(index, objs, cdData, isShowCD, fillAmount, labelTimeLeft)
		end
	end
end

function M:CheckUpdateChangeSkillCountDownTime(index)
	local data = self.changeSkillCountDownData[index]

	if self.changeSkillCountDownData[index] then
		local endTime = data.startTime + data.duration
		local obj = self.btnStore[index]

		if gLogicTime.time < endTime then
			obj.skillTypeCtrl = 1
			obj.multiPhaseRing = (endTime - gLogicTime.time) / data.duration
			self.isUpdateSkillBtns[index] = true
		else
			obj.skillTypeCtrl = 0
		end

		return true
	end

	return false
end

function M:UpdateSkill_MultiUseSkill(index, objs, comboData, isShowCD, maxCharges, curCharges, fillAmount, labelTimeLeft)
	if maxCharges > 1 then
		objs.skillTypeCtrl = 2
		local cdActive = isShowCD

		if cdActive then
			if curCharges == 0 then
				self:SetBtnInCd(index, objs, 1)

				objs.multiChrageCDCtrl = 0
				objs.cdTime = labelTimeLeft >= 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
				objs.cdCover = gBattleMgr.useV1hud and gCS.LuaUtils.IsNonMobileAdaptive() and fillAmount or 1 - fillAmount
			else
				self:SetBtnInCd(index, objs, 0)

				objs.multiChrageCDCtrl = 2
				objs.multiChargeCounts = curCharges
				objs.multiChargeCd = 1 - fillAmount
			end
		else
			self:SetBtnInCd(index, objs, 0)

			objs.multiChrageCDCtrl = 1
			objs.multiChargeCounts = curCharges
			objs.multiChargeReaCounts = curCharges
			objs.multiChargeCd = 1 - fillAmount
		end
	else
		local baseActive = not comboData.check and isShowCD
		objs.skillTypeCtrl = 0

		self:SetBtnInCd(index, objs, baseActive and 1 or 0)
	end

	self.isUpdateSkillBtns[index] = isShowCD

	gMainMenuMgr:SetBattleSkillBtnIsInCd(index, objs.btnInCDCtrl == 1)
end

function M:UpdateSkill_Normal(index, objs, cdData, isShowCD, fillAmount, labelTimeLeft)
	objs.skillTypeCtrl = 0

	if cdData.isUseLianzhaoIamge then
		cdData.isUseLianzhaoIamge = false
	end

	if isShowCD then
		objs.cdCover = gBattleMgr.useV1hud and gCS.LuaUtils.IsNonMobileAdaptive() and fillAmount or 1 - fillAmount
		objs.cdTime = labelTimeLeft >= 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
		self.isUpdateSkillBtns[index] = true
		self.isWaitforTweens[index] = true
	elseif self.isWaitforTweens[index] then
		self.isWaitforTweens[index] = false

		if index == gBattleMgr.SkillBtnType.FightSpiritBigSkill then
			local fightSpiritIndex = 1
			local skillId = gCS.BattleManager.GetUniqueSkillId()

			if gBattleMgr:IsSkillFightResourceEnough(gCS.MyPlayerManager.PlayerUnit, skillId) then
				self.aniControlDazhaos[fightSpiritIndex] = true

				self:PlayBigSkillColorAni()
			end
		elseif index ~= gBattleMgr.SkillBtnType.ControlPower then
			self:PlaySkillXuliAni(objs, index)

			if gBattleMgr:CheckBtnIsShow(objs.btnHideCtrl) then
				gSoundMgr:PlaySoundByTid(70601150)
			end
		end
	end
end

function M:PlaySkillXuliAni(btn, index)
	btn.btnXuliAni.gameObject:SetActive(true)

	self.xuliBtnAniList[index] = true
	local aniName = gBattleMgr:UsePCBattleHUD() and self.xuliCdAniNamePc or "s_vx_HudSkillBtn_xuli_cd"

	gBattleMgr:CommonPlayAniTool(btn.btnXuliAni, aniName, 0, 1, true, function ()
		self.xuliBtnAniList[index] = false
	end)
end

function M:SetBtnInCd(index, btn, isInCD)
	if btn.btnInCDCtrl ~= isInCD then
		btn.btnInCDCtrl = isInCD
	end
end

function M:UpdateHeavyAttackBtn()
	local templateId = 0
	local skillId = gBattleMgr:GetHeavyAttackSkillId()
	local skillType = gBattleMgr.SkillBtnType.HeavyAttack
	local cfgSkill = SkillConfig.GetConfig(skillId)
	local isLianzhao = false

	if cfgSkill then
		isLianzhao = #cfgSkill.ComboSkillId > 0 or #cfgSkill.SkillJumpId > 0
	end

	gBattleMgr:SetComboSkill(skillType, templateId, skillId)
	gMainMenuMgr:ForbidSkillBtnByNoSkillId(gBattleMgr.SkillBtnType.HeavyAttack, skillId == 0)
end

function M:UpdateFightSpiritBigSkill()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local index = 1
	local skillId = gCS.BattleManager.GetUniqueSkillId()
	local unit = gCS.MyPlayerManager.PlayerUnit
	local isFull = false

	if unit then
		isFull = gBattleMgr:IsSkillFightResourceEnough(unit, skillId)
	end

	local cfgSkill = SkillConfig.GetConfig(skillId)
	self.isUltSkill = cfgSkill and cfgSkill.SkillCastTypeTag == SkillConfig.SkillCastTypeTagType.Unique or false

	gBattleMgr:SetComboSkill(gBattleMgr.SkillBtnType.FightSpiritBigSkill, 0, skillId)

	self.isUpdateSkillBtns[gBattleMgr.SkillBtnType.FightSpiritBigSkill] = true

	gMainMenuMgr:ForbidSkillBtnByNoSkillId(gBattleMgr.SkillBtnType.FightSpiritBigSkill, skillId == 0)

	local canUseBigSkill = gBattleMgr:CheckCanShowUniqueSkillInfo(skillId)
	self.ultSkillBtn.energyCtrl = canUseBigSkill and 1 or 0

	gBattleMgr:RefreshFightSpiritUniqueSkillEnergy()

	if isFull and self.ultSkillBtn.energyCtrl == 1 then
		local isCDFinished = gCS.BattleManager.IsCDFinished(skillId)
		self.aniControlDazhaos[index] = isCDFinished

		self:SwitchFightSpiritEpFull(false, isCDFinished)
	else
		self.aniControlDazhaos[index] = false

		self:SwitchFightSpiritEpNoFull()
	end

	self.isWaitforTweens = {}
end

function M:SwitchFightSpiritEpNoFull()
	self.bindData.ultSkillBtn.interactable = not self.isUltSkill

	self.ultSkillBtn.iconUltCom:SetActive(false)
	gBattleMgr:SetColorToSImage(self.ultSkillBtn.ultColorCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filling))
	gBattleMgr:SetColorToSImage(self.ultSkillBtn.ultRingCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filling))
	self:CloseBigSkillColorAni()

	if not gBattleMgr:UsePCBattleHUD() and self.ultSkillBtn.bigSkillLoopAni then
		self.ultSkillBtn.bigSkillLoopAni.gameObject:SetActive(false)
	end
end

function M:UpdateBasicSkills(index)
	local templateId = 0
	local normalSkillId, basicSkillId = gCS.BattleManager.GetNormalAndBasicSkill(0, 0)

	for i = 1, 2 do
		local notExcute = index ~= nil and index ~= i

		if not notExcute then
			local skillId = i == 1 and normalSkillId or basicSkillId
			local cfgSkill = SkillConfig.GetConfig(skillId)
			local isLianzhao = false

			if cfgSkill then
				isLianzhao = #cfgSkill.ComboSkillId > 0 or #cfgSkill.SkillJumpId > 0
			end

			local pressInSkillId = 0

			if i == gBattleMgr.SkillBtnType.Normal then
				pressInSkillId = gCS.BattleManager.GetNormalPressInSkillId()
				local flag, textId, higtLight = nil
				flag, textId, higtLight = gCoreHudUIManager:GetNormalSkillText()
				self.normalAttackBtn.wordsCtrl = flag and 1 or 0
				self.normalAttackBtn.notifyWord = LTConfig.TextScriptTextConfig.GetConfig(textId).Text
				self.normalAttackBtn.qteVxCtrl = higtLight and 1 or 0
			end

			gBattleMgr:SetComboSkill(i, templateId, skillId)
			gMainMenuMgr:ForbidSkillBtnByNoSkillId(i, skillId == 0)
		end
	end
end

function M:UpdateFightEp(templateId, currentEp, maxEp)
	local fillValue = currentEp / (self.energyDotActive and 100 or maxEp)
	local index = 1
	local skillId = gCS.BattleManager.GetUniqueSkillId(gCS.MyPlayerManager.PlayerUnit.Pid)
	local canUseBigSkill = gBattleMgr:CheckCanShowUniqueSkillInfo(skillId)
	local isFull = gBattleMgr:IsSkillFightResourceEnough(gCS.MyPlayerManager.PlayerUnit, skillId)

	if isFull then
		fillValue = 1
	end

	if not canUseBigSkill then
		fillValue = 0
	end

	self:UpdateFightSpiritBigSkillEnergy(fillValue)

	if fillValue >= 1 and not self.aniControlDazhaos[index] then
		local isCDFinished = gCS.BattleManager.IsCDFinished(skillId)
		self.aniControlDazhaos[index] = isCDFinished

		if canUseBigSkill then
			self:SwitchFightSpiritEpFull(true, isCDFinished)
		end
	elseif fillValue < 1 and self.aniControlDazhaos[index] then
		self.aniControlDazhaos[index] = false

		self:SwitchFightSpiritEpNoFull()
	end
end

function M:UpdateFightSpiritBigSkillEnergy(fill)
	self.ultSkillBtn.energyBg = fill
	self.ultSkillBtn.energyRing = fill
end

function M:SwitchFightSpiritEpFull(playOpenAni, isCDFinished)
	self.bindData.ultSkillBtn.interactable = true

	self.ultSkillBtn.iconUltCom:SetActive(true)
	gBattleMgr:SetColorToSImage(self.ultSkillBtn.ultColorCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filled))
	gBattleMgr:SetColorToSImage(self.ultSkillBtn.ultRingCom, gUtils:HexToColor(GameConfig.HudUltBtnFillColor_Filled))

	if not isCDFinished then
		return
	end

	if playOpenAni then
		self:PlayBigSkillColorAni()
	else
		self:PlayEndBigSkillColorAni()
	end
end

function M:PlayBigSkillColorAni()
	if gBattleMgr:UsePCBattleHUD() then
		gBattleMgr:CommonPlayAniTool(self.ultSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNamePc, 0, 1)
	else
		gBattleMgr:CommonPlayAniTool(self.ultSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNameM, 0, 1)
	end
end

function M:CloseBigSkillColorAni()
	self:PlayEndBigSkillColorAni()

	if gBattleMgr:UsePCBattleHUD() then
		gBattleMgr:CommonPlayAniTool(self.ultSkillBtn.bigSkillColorAni, self.bigSkillCloseAniNamePc, 0, 1)
	else
		gBattleMgr:CommonPlayAniTool(self.ultSkillBtn.bigSkillColorAni, self.bigSkillCloseAniNameM, 0, 1)
	end
end

function M:PlayEndBigSkillColorAni()
	if gBattleMgr:UsePCBattleHUD() then
		gBattleMgr:CommonStopAniTool(self.ultSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNamePc)
	else
		gBattleMgr:CommonStopAniTool(self.ultSkillBtn.bigSkillColorAni, self.bigSkillOpenAniNameM)
	end
end

function M:UpdateCdAndEp(eventId, data)
	if gCS.MyPlayerManager.PlayerUnit.ClientData.cardId ~= 15022030 or not data or not data.skillId or not data.curValue or not data.maxValue then
		return
	end

	self:UpdateSkillCD(_, data.skillId)
	self:UpdateFightEp(gBattleSpiritMgr.currentSpiritTemplateId, data.curValue, data.maxValue)
end

function M:OnMergeBtnLongPressBegin(data)
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.btnStore[data])
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(data)
end

function M:OnMergeBtnLongPressEnd(data)
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.btnStore[data], data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(data)
end

function M:OnMergeBtnLongPress(data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(data)
end

function M:OnDodgeBtnLongPressBegin()
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.dodgeBtn)
	gBattleMgr:OnDodgeBtnPressFunc()
end

function M:OnDodgeBtnLongPress()
	return
end

function M:OnDodgeBtnLongPressEnd()
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.dodgeBtn)
	gBattleMgr:OnDodgeBtnReleaseFunc()
end

function M:OnRightStickControl(context)
	if self.circleOpen then
		return
	end

	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.needUpdateCamera = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.needUpdateCamera = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
	end
end

function M:UpdateGamepadCamera()
	if self.needUpdateCamera and not self.circleOpen then
		if not gPanelManager:VisibleModeAll() then
			self:ClearGamepadCameraRotate()

			return
		end

		local cameraConfigId = self:GetCameraConfigId()

		gCameraUtils:DoRotateCameraByGamePad(cameraConfigId, self.rightStickValue.x, self.rightStickValue.y)
	end
end

function M:GetCameraConfigId()
	local showShootCrossHair = false
	showShootCrossHair = gCS.MindPowerMgr.showShootCrossHair

	if gCS.ShootModule.IsInShootMode(gCS.MyPlayerManager.PlayerUnit) and not showShootCrossHair then
		return 2
	elseif showShootCrossHair then
		return 3
	else
		return 1
	end
end

function M:OnDragBtnDraging(eventPointer)
	if not eventPointer.delta then
		return
	end

	self:OnDragButton(eventPointer.delta)
end

function M:OnDragButton(delta)
	local camRotateX = GameConfig.FreeLookRotateXDefaultSensitivity
	local camRotateY = GameConfig.FreeLookRotateYDefaultSensitivity
	local deltaX = delta.x * (1 + (camRotateX - 1) / 8 * 6) * 0.5
	local deltaY = delta.y * (1 + (camRotateY - 1) / 8 * 6) * 0.5
	local minDeltaInput = GameConfig.SwingJoystickMinInput

	if Mathf.Abs(deltaX) < minDeltaInput.X then
		deltaX = 0
	end

	if Mathf.Abs(deltaY) < minDeltaInput.Y then
		deltaY = 0
	end

	if deltaX ~= 0 or deltaY ~= 0 then
		local dir = Vector2.New(deltaX, deltaY)

		gCS.CameraDataMgr.cameraControllerManager:OnControlCameraAngle(dir)
	end
end
