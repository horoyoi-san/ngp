local MobileMenuCircleMenuConfig = LTConfig.MobileMenuCircleMenuConfig
local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
local UrbanAttributeConfig = LTConfig.UrbanAttributeConfig
local AtmosphereManager = LX6.Manager.AtmosphereManager
local TaskShortCutConfig = LTConfig.TaskShortCutConfig
local WeaponConfig = LTConfig.WeaponConfig
local CategoryType = LTConfig.WeaponConfig.CategoryType
local UXTime = LTUtils.UXTime
local PanelRedDotConfig = LTConfig.PanelRedDotConfig
C_CoreHudCircleStore = DefClass("C_CoreHudCircleStore", C_CoreHudCircleStore, C_StoreGroup)
GroupName2Class.CoreHudCircleStore = C_CoreHudCircleStore
local M = C_CoreHudCircleStore

function M:ctor()
	self.DEFINE_DynamicOnUpdate = true
	self.CIRCLE_MODE = {
		SUMMON = 3,
		SYSTEM = 2,
		HIDE = 0,
		WEAPON = 1
	}
	self.SELECT_MODE = {
		FALSE = 0,
		TRUE = 1
	}
	self.LEFT_MODE = {
		NORMAL = 0,
		EXTRA = 1
	}
	self.WARN_TEXT = {
		EMPTY = 0,
		LOW_DURABILITY = 2,
		BROKEN = 3,
		NO_DROP = 1
	}
	self.msgEvents = {
		[gEventConstants.TASK_SHORTCUT_CHANGE] = self:CreateAction("OnTaskShortcutChange"),
		[gEventConstants.GANG_MEMBER_INFO_CHANGE] = self:CreateAction("OnGangMemberInfoChange"),
		[gEventConstants.CURRENT_WEAPON_OPERATORFLAGS_CHANGED] = self:CreateAction("OnWeaponOperatorFlagsChange")
	}
	self.LOCAL_CIRCLE_INFO_PATH = "LocalCircleInfo"
end

function M:OnAwake()
	self:DefineCommonData()
	self:DefineSysData()
	self:DefineWeaponData()
	self:DefineSummonData()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:DefineCommonData()
	self.localCircleInfo = gUIUtils:LoadJsonToLuaTableWithPid(self.LOCAL_CIRCLE_INFO_PATH) or {}
	self.circleOpen = false
	self.circleOpenTime = 0
	self.needSave = false
	self.pressTime = 0
	self.targetMode = self.CIRCLE_MODE.HIDE
	self.currentMode = self.CIRCLE_MODE.HIDE
	self.pauseUUID = nil
	self.updateSelect = false
	self.isDragMove = false
	self.moveVector = Vector2.New(0, 1)
	self.accumulateMoveVector = Vector2.New(0, 0)
	self.PcThreshHold = 1
	self.PadThreshHold = 0.01
	self.MaxVectorLength = 40000
	self.MinVectorLength = 20
	self.ShowCircleLimit = 0
	self.CIRCLE_OPEN_ANIME_TIME = 0
	self.SMOOTH_TIME = 0.1
	self.smoothStartTime = 0
	self.smoothStartVector = Vector2.New(0, 0)
	self.smoothEndVector = Vector2.New(0, 0)
end

function M:DefineSysData()
	self.needNotifySystemControls = false
	self.sysReady = false
	self.sysFirstSelect = false
	self.sysTimeLastUpdate = 0
	self.SysTimeUpdateInterval = 30
	self.sysSelectIndex = 0
	self.sysRight = {}
	self.sysLeft = {}
	self.sysLeftExtra = {}
	self.sysItemMap = {}
	self.sysTaskConfigId = nil
	self.sysTaskAction = nil
	self.sysTaskIndex = 0
	self.leftExtraMode = false

	function self.sysCmpFunc(a, b)
		return a.cfg.Rank < b.cfg.Rank
	end

	self.RightNumIndex = 7
	self.LeftNumIndex = 9
	self.LeftExtraNumIndex = 10
	self.sysInitVector = Vector2.New(0, 1)
	self.sysEachAngle = 30
	self.SYS_RIGHT_ID = 30
	self.SYS_LEFT_ID = 50
end

function M:DefineWeaponData()
	self.weaponReady = false
	self.WeaponSwitchAnimeDown = "S_vx_CircleWeaponPanel_cut_d"
	self.WeaponSwitchAnimeUp = "S_vx_CircleWeaponPanel_cut_u"
	self.weaponItemMap = {}
	self.weaponTabList = {}
	self.weaponItemStore = {}
	self.privateWeaponMinIndex = 0
	self.MAX_SLOT_COUNT = 8
	self.WeaponCircleState = {
		TempMode = false
	}
	self.weaponGuideIndex = -1
	self.weaponGuideIsTask = false
	self.weaponGuideID = nil
	self.weaponShowToolTip = self.localCircleInfo.SHOW_WEAPON_CIRCLE_TOOLTIP or false
	self.weaponInitVector = Vector2.New(-math.sin(math.pi / 4), -math.cos(math.pi / 4))
	self.weaponEachAngle = 45
	self.weaponSelectIndex = 0
end

function M:DefineSummonData()
	self.SUMMON_STATE = {
		Disbandable = 1,
		Full = 4,
		Recovering = 3,
		Summonable = 0,
		Lock = 2
	}
	self.SUMMON_SHOW = {
		Detail = 1,
		Exit = 2,
		Empty = 0
	}
	self.summonReady = false
	self.MAX_SUMMON_COUNT = 7
	self.summonItemMap = {}
	self.summonItemStore = {}
	self.summonInitVector = Vector2.New(-math.sin(math.pi / 8), -math.cos(math.pi / 8))
	self.summonEachAngle = 45
	self.summonSelectIndex = 0
	self.needUpdateSummonSelectRecover = false
	self.summonSelectInterval = 0.5
	self.summonSelectLastUpdateTime = 0
	self.recoverFullTime = 0
	self.needUpdateSummonCircleRecover = false
	self.summonCircleInterval = 3
	self.summonCircleLastUpdateTime = 0
	self.summonNumCurrent = 0

	function self.summonCb(err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	function self.disbandCb(err)
		if err == LTConfig.MessageConfig.Ok then
			self:CloseCircleNoEvent()
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	self.HpColorRange = LTConfig.GameConfig.JiaMuSummonPartnerHealth
end

function M:OnGroupEnable()
	self.sysCircle = self:GetStoreByWidget(self.bindData.sysRoot)
	self.sysCircle.sysCloseBtnPC.luaClick = self:CreateAction("CloseCircleNoEvent")
	self.sysCircle.sysCloseBtnPad.luaClick = self:CreateAction("CloseCircleNoEvent")
	self.sysCircle.sysConfirmBtnPC.luaClick = self:CreateAction("CloseCircle")
	self.sysCircle.sysConfirmBtnPad.luaClick = self:CreateAction("CloseCircle")
	self.sysCircle.sysMouseMoveRespond.luaGamePadInputChanged = self:CreateAction("OnMouseMove")
	self.sysCircle.sysRightStickRespond.luaGamePadInputChanged = self:CreateAction("OnStickMove")
	self.sysCircle.sysFeedbackBtn.luaClick = self:CreateAction("OnFeedbackBtnClick")
	self.sysCircle.sysSurveyBtn.luaClick = self:CreateAction("OnSurveyBtnClick")

	self:InitSystemMenu()

	self.weaponCircle = self:GetStoreByWidget(self.bindData.weaponRoot)
	self.weaponCircle.weaponDropBtnPC.luaClick = self:CreateAction("WeaponDropCurrentSelect")
	self.weaponCircle.weaponDropBtnPad.luaClick = self:CreateAction("WeaponDropCurrentSelect")
	self.weaponCircle.weaponDropBtnMobile.luaClick = self:CreateAction("WeaponDropCurrentSelect")
	self.weaponCircle.weaponCloseBtnPC.luaClick = self:CreateAction("CloseCircleNoEvent")
	self.weaponCircle.weaponCloseBtnPad.luaClick = self:CreateAction("CloseCircleNoEvent")
	self.weaponCircle.weaponConfirmBtnPC.luaClick = self:CreateAction("CloseCircle")
	self.weaponCircle.weaponConfirmBtnPad.luaClick = self:CreateAction("CloseCircle")
	self.weaponCircle.mouseScrollRespond.luaGamePadInputChanged = self:CreateAction("OnWeaponMouseScroll")
	self.weaponCircle.weaponMouseMoveRespond.luaGamePadInputChanged = self:CreateAction("OnMouseMove")
	self.weaponCircle.weaponRightStickRespond.luaGamePadInputChanged = self:CreateAction("OnStickMove")
	self.weaponCircle.switchBtnPad.luaClick = self:CreateAction("SwitchWeaponTypeLoop")
	self.weaponCircle.weaponTagList.luaSimpleRenderItem = self:CreateAction("OnWeaponTagListRenderItem")
	self.weaponCircle.weaponTabList.luaSimpleRenderItem = self:CreateAction("OnWeaponTabListRenderItem")
	self.weaponCircle.weaponTabList.luaSelectedChanged = self:CreateAction("OnSwitchWeaponPage")
	self.weaponCircle.detailsBtn.luaClick = self:CreateAction("OnDetailsBtnClick")

	self.weaponCircle.detailsBtn:SetSelected(self.weaponShowToolTip)
	self.weaponCircle.tooltipDescBtnPc:SetSelected(self.weaponShowToolTip)
	self.weaponCircle.tooltipDescBtnPad:SetSelected(self.weaponShowToolTip)

	self.toolTipStore = self:GetStoreByWidget(self.weaponCircle.weaponTooltipRoot)
	self.toolTipStore.tipTagList.luaSimpleRenderItem = self:CreateAction("OnWeaponTagListRenderItem")

	table.clear(self.weaponItemStore)
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.weaponCircle.weaponItem1))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.weaponCircle.weaponItem2))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.weaponCircle.weaponItem3))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.weaponCircle.weaponItem4))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.weaponCircle.weaponItem5))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.weaponCircle.weaponItem6))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.weaponCircle.weaponItem7))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.weaponCircle.weaponItem8))

	self.summonCircle = self:GetStoreByWidget(self.bindData.summonRoot)
	self.summonCircle.summonMouseMoveRespond.luaGamePadInputChanged = self:CreateAction("OnMouseMove")
	self.summonCircle.summonRightStickRespond.luaGamePadInputChanged = self:CreateAction("OnStickMove")
	self.summonCircle.summonDisbandBtn.luaClick = self:CreateAction("DisbandMember")
	self.summonCircle.summonDisbandBtnPc.luaClick = self:CreateAction("DisbandMember")
	self.summonCircle.summonDisbandBtnPad.luaClick = self:CreateAction("DisbandMember")
	self.summonCircle.summonCloseBtnPc.luaClick = self:CreateAction("CloseCircleNoEvent")
	self.summonCircle.summonCloseBtnPad.luaClick = self:CreateAction("CloseCircleNoEvent")

	table.clear(self.summonItemStore)
	table.insert(self.summonItemStore, self:GetStoreByWidget(self.summonCircle.summonItem1))
	table.insert(self.summonItemStore, self:GetStoreByWidget(self.summonCircle.summonItem2))
	table.insert(self.summonItemStore, self:GetStoreByWidget(self.summonCircle.summonItem3))
	table.insert(self.summonItemStore, self:GetStoreByWidget(self.summonCircle.summonItem4))
	table.insert(self.summonItemStore, self:GetStoreByWidget(self.summonCircle.summonItem5))
	table.insert(self.summonItemStore, self:GetStoreByWidget(self.summonCircle.summonItem6))
	table.insert(self.summonItemStore, self:GetStoreByWidget(self.summonCircle.summonItem7))
	table.insert(self.summonItemStore, self:GetStoreByWidget(self.summonCircle.summonItem8))
end

function M:OnDestroy()
	self:ClearMessageEvents()
	self:CloseCircleNoEvent()

	self.localCircleInfo = nil
	self.sysItemMap = nil
	self.sysRight = nil
	self.sysLeft = nil
	self.sysLeftExtra = nil
	self.weaponItemMap = nil
	self.weaponTabList = nil
	self.summonItemMap = nil
	self.sysCircle = nil
	self.weaponCircle = nil
	self.weaponItemStore = nil
	self.summonCircle = nil
	self.summonItemStore = nil
	self.toolTipStore = nil
	self.HpColorRange = nil
end

function M:OnUpdate()
	if self.targetMode == self.CIRCLE_MODE.HIDE then
		return
	end

	if self.currentMode == self.CIRCLE_MODE.HIDE then
		if self.ShowCircleLimit <= Time.time - self.pressTime then
			self.currentMode = self.targetMode

			self:OnCircleOpen()
		end
	elseif self.currentMode == self.CIRCLE_MODE.WEAPON then
		self:UpdateWeaponArrowSelect()
	elseif self.currentMode == self.CIRCLE_MODE.SYSTEM then
		self:UpdateSystemArrowSelect()
		self:UpdateSystemTime()
	elseif self.currentMode == self.CIRCLE_MODE.SUMMON then
		self:UpdateSummonArrowSelect()

		local now = UXTime.GetNowUnixTime()

		self:UpdateSelectRecoverCountDown(now)
		self:UpdateCircleRecoverCountDown(now)
	end
end

function M:OpenWeaponCircle()
	if not self.STATE_EnableOnce then
		return
	end

	self.circleOpen = true
	self.ShowCircleLimit = 0
	self.pressTime = Time.time
	self.targetMode = self.CIRCLE_MODE.WEAPON
	self.targetPageIndex = 1
	local weapons = gWeaponManager:GetCurrentWeapons()

	for i = 1, weapons.Length do
		local detail = weapons[i]

		if detail and gPlayerManager.infoSpirit.bindData.currentWeapon and detail.InstanceId == gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId then
			if i > 8 then
				self.targetPageIndex = 2
			end

			break
		end
	end

	self.MAEnable = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FightSkill)
	self.toolTipStore.MAEnableCtrl = self.MAEnable and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
	self.toolTipStore.MASwitchEnableCtrl = self.SELECT_MODE.FALSE

	gStoreManager:RegisterDynamicOnUpdate(self)
end

function M:UpdateWeaponCircleState()
	self.WeaponCircleState.TempMode = gWeaponManager.TempWeaponMode
end

function M:OpenSummonCircle()
	if not self.STATE_EnableOnce then
		return
	end

	self.circleOpen = true
	self.ShowCircleLimit = 0
	self.pressTime = Time.time
	self.targetMode = self.CIRCLE_MODE.SUMMON

	gStoreManager:RegisterDynamicOnUpdate(self)
end

function M:OpenSystemCircle()
	if not self.STATE_EnableOnce then
		return
	end

	self.circleOpen = true
	self.sysFirstSelect = false
	self.ShowCircleLimit = 0
	self.pressTime = Time.time
	self.targetMode = self.CIRCLE_MODE.SYSTEM

	gStoreManager:RegisterDynamicOnUpdate(self)
end

function M:CloseCircle()
	if not self.STATE_EnableOnce then
		return
	end

	if not self.circleOpen then
		return
	end

	gStoreManager:UnregisterDynamicOnUpdate(self)

	self.circleOpen = false

	if self.targetMode == self.CIRCLE_MODE.WEAPON and self.currentMode == self.CIRCLE_MODE.WEAPON then
		self:SwitchWeapon()
	end

	if self.targetMode == self.CIRCLE_MODE.SYSTEM and self.currentMode == self.CIRCLE_MODE.SYSTEM then
		self:OpenSystem()
	end

	if self.targetMode == self.CIRCLE_MODE.SUMMON and self.currentMode == self.CIRCLE_MODE.SUMMON then
		self:SummonMember()
	end

	self.targetMode = self.CIRCLE_MODE.HIDE

	if self.currentMode ~= self.CIRCLE_MODE.HIDE then
		self:OnCircleClose()

		self.currentMode = self.CIRCLE_MODE.HIDE
	end

	self.sysReady = false
	self.weaponReady = false
	self.sysFirstSelect = false
	self.summonReady = false
end

function M:OnCircleOpen()
	gStoreManager:GetStoreGroup("HintInfosHudStore"):EnableFromInteraction(false)
	gStoreManager:GetStoreGroup("CoreHudCharacterControlStore"):SetCircleOpen(true)
	gDialogManager:ProcessDialogBranch(true)

	if self.currentMode == self.CIRCLE_MODE.WEAPON or self.currentMode == self.CIRCLE_MODE.SUMMON then
		if not gLinkManager:CheckInLinkMode() then
			gCS.PauseManager.Instance:AddFakePausePannel(68)
		end

		LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gPanelId.S_CORE_HUD_PANEL - 10000)
		gSoundMgr:PlaySoundByTid(LTConfig.SoundConfig.PauseTimeStart)
	elseif self.currentMode == self.CIRCLE_MODE.SYSTEM then
		self:UpdateSystemTime(true)
		self:RefreshSystemStuntState()
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	self:SwitchToCurrentCircle()
	gPopupPauseManager:PausePopup(gPopupPauseManager.PAUSE_REASON.CIRCLE_OPEN)
	gNewPopupManager:CloseAllActivePopup()

	self.circleOpenTime = Time.unscaledTime
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	self.needSave = false
	self.needNotifySystemControls = false
end

function M:OnCircleClose()
	gStoreManager:GetStoreGroup("HintInfosHudStore"):EnableFromInteraction(true)
	gStoreManager:GetStoreGroup("CoreHudCharacterControlStore"):SetCircleOpen(false)
	gDialogManager:ProcessDialogBranch(false)

	if self.currentMode == self.CIRCLE_MODE.WEAPON or self.currentMode == self.CIRCLE_MODE.SUMMON then
		if not gLinkManager:CheckInLinkMode() then
			gCS.PauseManager.Instance:RemoveFakePausePannel(68)
		end

		LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gPanelId.S_CORE_HUD_PANEL - 10000)
		gSoundMgr:PlaySoundByTid(LTConfig.SoundConfig.PauseTimeEnd)

		if self.currentMode == self.CIRCLE_MODE.WEAPON then
			self:SetWeaponSelect(0)
			table.clear(self.weaponItemMap)
			table.clear(self.weaponTabList)
		elseif self.currentMode == self.CIRCLE_MODE.SUMMON then
			self:SetSummonSelect(0)
			table.clear(self.summonItemMap)
		end
	elseif self.currentMode == self.CIRCLE_MODE.SYSTEM then
		table.clear(self.sysItemMap)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end

	self.bindData.circleModeCtrl = self.CIRCLE_MODE.HIDE

	gPopupPauseManager:ResumePopup(gPopupPauseManager.PAUSE_REASON.CIRCLE_OPEN)

	if self.needSave then
		self.needSave = false

		gUIUtils:SaveLuaTableToJsonWithPid(self.LOCAL_CIRCLE_INFO_PATH, self.localCircleInfo)
	end

	if self.needNotifySystemControls then
		self.needNotifySystemControls = false

		gStoreManager:GetStoreGroup("CoreHudSystemControlStore"):RefreshHighlightAnimeState()
	end
end

function M:SwitchToCurrentCircle()
	if self.currentMode == self.CIRCLE_MODE.WEAPON then
		self.weaponSelectIndex = 0

		self:RefreshWeaponCircle()
		self:RebuildWeaponPageView()
		self:RebuildWeaponCircleView()

		local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)

		for i = startIdx + 1, endIdx do
			if self.weaponItemMap[i] and self.weaponItemMap[i].Using then
				self.weaponSelectIndex = i - startIdx

				break
			end
		end

		self:SetWeaponSelect(self.weaponSelectIndex, true)

		self.weaponCircle.weaponStartSelect = self.SELECT_MODE.FALSE

		self.weaponCircle.weaponTabList:SelectItem(self.targetPageIndex - 1, false)

		if self.weaponSelectIndex == 0 then
			self.moveVector.x = 0
			self.moveVector.y = 1
			self.accumulateMoveVector.x = 0
			self.accumulateMoveVector.y = 0
		else
			local angle = self.weaponEachAngle * (self.weaponSelectIndex + 0.5)
			self.moveVector.x = -math.sin(angle / 180 * math.pi)
			self.moveVector.y = -math.cos(angle / 180 * math.pi)
			self.accumulateMoveVector.x = 0
			self.accumulateMoveVector.y = 0
		end

		self.weaponCircle.weaponLockIcon:SetActive(self.targetPageIndex == 1)
	elseif self.currentMode == self.CIRCLE_MODE.SYSTEM then
		self.sysSelectIndex = 0

		self:RefreshSystemCircle()

		self.sysCircle.sysSelectMode = self.sysSelectIndex
		self.sysCircle.sysStartSelect = self.SELECT_MODE.FALSE
		self.sysCircle.sysFirstSelectCtrl = self.sysFirstSelect and 0 or 1
		self.sysCircle.sysTitle = ""
		self.sysCircle.sysTextInfo = ""
		self.moveVector.x = 0
		self.moveVector.y = 1
		self.accumulateMoveVector.x = 0
		self.accumulateMoveVector.y = 0
	elseif self.currentMode == self.CIRCLE_MODE.SUMMON then
		self.summonSelectIndex = 0

		self:SetSummonSelect(self.weaponSelectIndex, true)
		self:RefreshSummonCircle()
		self:RebuildSummonCircleView()

		self.summonCircle.summonStartSelectCtrl = self.SELECT_MODE.FALSE
		self.moveVector.x = 0
		self.moveVector.y = 1
		self.accumulateMoveVector.x = 0
		self.accumulateMoveVector.y = 0
	end

	self.bindData.circleModeCtrl = self.currentMode

	self:ClearSmoothMove()
end

function M:RefreshWeaponCircle()
	if self.weaponReady then
		return
	end

	table.clear(self.weaponItemMap)

	local weapons = gWeaponManager:GetCurrentWeapons()
	self.weaponGuideIndex = -1
	self.weaponGuideIsTask = false
	self.weaponGuideID = nil
	local taskId = gTaskNodeManager:GetNowDoingTask()
	local lowPoint = WeaponConfig.WeaponDurabilityLow * 100

	for i = 1, weapons.Length do
		local detail = weapons[i]

		if detail then
			local item = {
				TemplateId = detail.TemplateId,
				InstanceId = detail.InstanceId,
				IsTask = gWeaponManager:GetFlag(detail.OperatorFlags, 2) == 1,
				CantDiscard = gWeaponManager:GetFlag(detail.OperatorFlags, 1) == 1
			}
			item.Cfg = WeaponConfig.GetConfig(item.TemplateId)
			item.RedDot = detail.WeaponFlags.ShowRedDot and 1 or 0

			if item.RedDot > 0 then
				SGUI.RedDotMgr.LuaSetRedDot(true, "weapon." .. item.InstanceId)
			end

			item.Index = i - 1
			item.guideID = ""
			item.AttackFill = 0
			item.PoiseFill = 0
			item.MaxDurability = 0
			item.BrokenState = 0

			if item.Cfg then
				if i <= 2 then
					item.IsPrivate = true
					item.DurablePercent = ""
					item.DurablePercentValue = 100
				else
					gWeaponManager:GetWeaponDurability(item, detail)
				end

				item.tags = {}

				for j = 1, #item.Cfg.Tags do
					table.insert(item.tags, {
						TagType = item.Cfg.Tags[j]
					})
				end

				local cfg = UrbanAttributeConfig.GetConfig(item.Cfg.sixDimBonus)
				item.SixDimName = cfg and cfg.Name or ""
				item.SixDimIcon = cfg and cfg.SIcon or 0
				item.AttackFill = Mathf.Clamp01((item.Cfg.AttackPower or 0) / WeaponConfig.MaxWeaponAttackPower) * 100
				item.PoiseFill = Mathf.Clamp01((item.Cfg.PoiseAbility or 0) / WeaponConfig.MaxWeaponPoiseAbility) * 100
				item.Using = gPlayerManager.infoSpirit.bindData.currentWeapon and item.InstanceId == gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId or false
				item.MaxDurability = item.Cfg.Durability
				local taskCanUse = gWeaponManager:CheckWheelTaskGuide(taskId, item.Cfg)

				if taskCanUse and (self.weaponGuideIndex < 0 or not self.weaponGuideIsTask and item.IsTask) then
					self.weaponGuideIndex = i
					self.weaponGuideIsTask = item.IsTask
					self.weaponGuideID = item.Cfg.GuideId
				end

				item.CategoryType = item.Cfg and item.Cfg.Category or CategoryType.Weapon

				if item.CategoryType == CategoryType.Weapon then
					if item.DurablePercentValue == 0 then
						item.BrokenState = 2
					elseif item.DurablePercentValue <= lowPoint then
						item.BrokenState = 1
					end
				end

				table.insert(self.weaponItemMap, item)
			else
				table.insert(self.weaponItemMap, false)
				print_error("Weapon配表找不到配置,TemplateId=", item.TemplateId, "InstanceId=", item.InstanceId)
			end
		else
			table.insert(self.weaponItemMap, false)
		end
	end

	if self.weaponGuideIndex > 0 then
		self.weaponItemMap[self.weaponGuideIndex].guideID = self.weaponGuideID
	end

	table.clear(self.weaponTabList)

	for i = 1, 2 do
		table.insert(self.weaponTabList, i)
	end

	self.weaponReady = true
end

function M:RefreshSystemCircle()
	if self.sysReady then
		return
	end

	self.sysItemMap = {}
	self.sysTaskIndex = 0
	self.leftExtraMode = false
	local curRight = {}
	local checkTask = false

	if self.sysTaskConfigId and self.sysRight[self.sysTaskConfigId] then
		checkTask = true
	end

	for id, cfg in pairs(self.sysRight) do
		if not self[cfg.Circle .. "CheckEnable"] then
			print_error(cfg.Circle, "功能还没实现，请找策划解决@shaoyunsa")
		else
			table.insert(curRight, {
				cfg = cfg,
				enable = self[cfg.Circle .. "CheckEnable"](self, cfg),
				glowed = self.localCircleInfo["SysCircle." .. cfg.Circle .. ".Glowed"]
			})
		end
	end

	table.sort(curRight, self.sysCmpFunc)

	for i = #curRight, 8, -1 do
		table.remove(curRight, i)
	end

	if checkTask then
		for i = 1, #curRight do
			if curRight[i].cfg.Id == self.sysTaskConfigId then
				self.sysTaskIndex = i

				break
			end
		end
	end

	checkTask = false

	if self.sysTaskConfigId and self.sysLeft[self.sysTaskConfigId] then
		checkTask = true
	end

	local curLeft = {}

	for id, cfg in pairs(self.sysLeft) do
		if not self[cfg.Circle .. "CheckEnable"] then
			print_error(cfg.Circle, "功能还没实现，请找策划解决@shaoyunsa")
		else
			table.insert(curLeft, {
				cfg = cfg,
				enable = self[cfg.Circle .. "CheckEnable"](self, cfg),
				glowed = self.localCircleInfo["SysCircle." .. cfg.Circle .. ".Glowed"]
			})
		end
	end

	table.sort(curLeft, self.sysCmpFunc)

	for i = #curLeft, 3, -1 do
		table.remove(curLeft, i)
	end

	if checkTask then
		for i = 1, #curLeft do
			if curLeft[i].cfg.Id == self.sysTaskConfigId then
				self.sysTaskIndex = self.RightNumIndex + i

				break
			end
		end
	end

	checkTask = false

	for i = 1, self.RightNumIndex do
		table.insert(self.sysItemMap, curRight[i] or false)
	end

	for i = self.RightNumIndex + 1, self.LeftNumIndex do
		table.insert(self.sysItemMap, curLeft[i - self.RightNumIndex] or false)
	end

	if self.sysTaskConfigId and self.sysLeftExtra[self.sysTaskConfigId] then
		checkTask = true
	end

	if checkTask then
		local cfg = self.sysLeftExtra[self.sysTaskConfigId]

		table.insert(self.sysItemMap, {
			cfg = cfg,
			enable = self[cfg.Circle .. "CheckEnable"](self, cfg),
			glowed = self.localCircleInfo["SysCircle." .. cfg.Circle .. ".Glowed"]
		})

		self.leftExtraMode = true
		self.sysTaskIndex = self.LeftExtraNumIndex
	else
		table.insert(self.sysItemMap, false)
	end

	for i = 1, #self.sysItemMap do
		local item = self.sysItemMap[i]

		self:OnRenderSysCircleItem(i, item)
	end

	self.sysCircle.sysLeftMode = self.leftExtraMode and self.LEFT_MODE.EXTRA or self.LEFT_MODE.NORMAL
	self.sysCircle.sysTaskCtrl = self.sysTaskIndex

	if self.sysTaskIndex > 0 then
		local taskIconId = 0
		local cfg = LTConfig.TaskConfig.GetConfig(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])

		if cfg then
			taskIconId = gTaskManager.TaskSIconId[cfg.Title]
		end

		self.sysCircle["sysTaskIcon" .. self.sysTaskIndex] = taskIconId
	end

	self.sysReady = true
end

function M:OnRenderSysCircleItem(index, item)
	if item and item.cfg then
		local redCfg = nil
		local redDotKey = ""
		local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(item.cfg.AppId)

		if mobileMenuSGuiCfg then
			redCfg = PanelRedDotConfig.GetConfig(mobileMenuSGuiCfg.RedDotId)
		end

		if redCfg then
			self.sysCircle["sysRedId" .. index] = mobileMenuSGuiCfg.RedDotId or 0
		else
			if item.cfg.AppId > 0 then
				redDotKey = ("PhoneAppItemRedDot:%d"):format(item.cfg.AppId)
			end

			self.sysCircle["sysRedKey" .. index] = redDotKey
		end

		self.sysCircle["sysIcon" .. index] = item.cfg.Icon
		self.sysCircle["sysGlow" .. index] = item.enable and not item.glowed and item.cfg.IsShowGuide
		self.sysCircle["sysGuide" .. index] = item.cfg.GuideId or ""

		if self.leftExtraMode then
			if index == 8 or index == 9 then
				self.sysCircle["sysBtnEx" .. index].interactable = item.enable
			else
				self.sysCircle["sysBtn" .. index].interactable = item.enable
			end
		else
			self.sysCircle["sysBtn" .. index].interactable = item.enable
		end
	else
		self.sysCircle["sysIcon" .. index] = 0
		self.sysCircle["sysRedKey" .. index] = ""
		self.sysCircle["sysGlow" .. index] = false
		self.sysCircle["sysGuide" .. index] = ""

		if self.leftExtraMode then
			if index == 8 or index == 9 then
				self.sysCircle["sysBtnEx" .. index].interactable = false
			else
				self.sysCircle["sysBtn" .. index].interactable = false
			end
		else
			self.sysCircle["sysBtn" .. index].interactable = false
		end
	end
end

function M:InitSystemMenu()
	for i = 0, MobileMenuCircleMenuConfig.count - 1 do
		local cfg = MobileMenuCircleMenuConfig.LoadAt(i)

		if cfg.Id < self.SYS_RIGHT_ID then
			if cfg.IsShow then
				self.sysRight[cfg.Id] = cfg
			end
		elseif cfg.Id < self.SYS_LEFT_ID then
			if cfg.IsShow then
				self.sysLeft[cfg.Id] = cfg
			end
		elseif cfg.IsShow then
			self.sysLeftExtra[cfg.Id] = {
				enable = false,
				cfg = cfg
			}
		end
	end
end

function M:RefreshSummonCircle()
	if self.summonReady then
		return
	end

	local summonDict = gGangMemberManager:GetGangMemberInfoAll()

	table.clear(self.summonItemMap)

	self.needUpdateSummonCircleRecover = false
	self.summonNumCurrent = 0

	for i = 0, self.MAX_SUMMON_COUNT - 1 do
		local cfg = LTConfig.FactionFactionAgentDisplayConfig.LoadAt(i)
		local item = {
			Cfg = cfg
		}
		local agentConfig = LTConfig.AgentConfig.GetConfig(cfg.AgentQuoteId)
		item.AgentCfg = agentConfig
		local info = summonDict[cfg.Id]

		self:UpdateSummonInfo(item, info)
		table.insert(self.summonItemMap, item)

		if item.Status == self.SUMMON_STATE.Recovering then
			self.needUpdateSummonCircleRecover = true
		end

		if item.Status == self.SUMMON_STATE.Disbandable then
			self.summonNumCurrent = self.summonNumCurrent + 1
		end
	end

	self.summonReady = true
end

function M:UpdateSummonInfo(item, info)
	if info then
		item.IsEmpty = false
		item.NextReviveTimeStamp = info.NextReviveTimeStamp
		item.InstanceId = info.InstanceId
		item.TemplateId = info.TemplateId
		item.HpFill = 1
		item.HpColor = 0
		item.RecoverCd = 0

		if info.NextReviveTimeStamp >= 0 then
			item.Status = self.SUMMON_STATE.Recovering
			item.RecoverCd = item.Cfg and item.Cfg.CoolDown * 60 or 0
		elseif not info.IsUnlock then
			item.Status = self.SUMMON_STATE.Lock
		elseif not ulong.equals(info.InstanceId, 0) then
			item.Status = self.SUMMON_STATE.Disbandable
			local unit = gCS.SceneDataMgr.GetUnit(item.InstanceId)
			local clientData = unit and unit.ClientData
			local hpFill = clientData and Mathf.Clamp01(unit.ClientData.Hp / unit.ClientData.MaxHp)
			hpFill = hpFill or info.HpPercent or 1
			item.HpFill = hpFill
			item.HpColor = self:CalHpColor(hpFill)
		else
			item.Status = self.SUMMON_STATE.Summonable
			local hpFill = info.HpPercent or 1
			item.HpFill = hpFill
			item.HpColor = self:CalHpColor(hpFill)
		end

		item.StatusCurrent = item.Status
	else
		item.IsEmpty = false
		item.InstanceId = 0
		item.TemplateId = item.Cfg.Id
		item.Status = self.SUMMON_STATE.Lock
		item.StatusCurrent = item.Status
		item.HpFill = 1
		item.HpColor = 0
		item.RecoverCd = 0
	end
end

function M:CalHpColor(fill)
	local color = 0

	if fill <= self.HpColorRange[2] then
		color = 2
	elseif fill <= self.HpColorRange[1] then
		color = 1
	end

	return color
end

function M:RebuildSummonCircleView()
	for i = 1, self.MAX_SUMMON_COUNT do
		self:OnRenderSummonCircleItem(i, self.summonItemMap[i])
	end

	self.summonCircle.summonNumMax = gGangMemberManager.limit
	self.summonCircle.summonNumCurrent = self.summonNumCurrent
end

function M:OnRenderSummonCircleItem(index, item)
	local store = self.summonItemStore[index]

	if item and not item.IsEmpty then
		if item.Status == self.SUMMON_STATE.Lock then
			store.headIcon = item.Cfg and item.Cfg.AgentPicDisable or 0
		else
			store.headIcon = item.AgentCfg and item.AgentCfg.HeadIcon or 0
		end

		store.IsEmptyCtrl = self.SELECT_MODE.FALSE
		store.StatusCtrl = item.Status
		store.hpFillAmount = item.HpFill
		store.HpColorCtrl = item.HpColor
	else
		store.IsEmptyCtrl = self.SELECT_MODE.TRUE
	end
end

function M:TeamCheckEnable()
	return gUIFunctionStateManager:GetTeamEnable()[2]
end

function M:RoleCheckEnable()
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.LingListId)
end

function M:TaskCheckEnable()
	return gUIFunctionStateManager:GetTaskListEnable()[2]
end

function M:MapCheckEnable()
	return gUIFunctionStateManager:GetMapEnable()[2]
end

function M:BagCheckEnable()
	return gUIFunctionStateManager:GetPackageEnable()[2]
end

function M:YanjieCheckEnable()
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.SocialNetworkId)
end

function M:PhoneCheckEnable()
	return gUIFunctionStateManager:GetPhoneEnable()[2] and gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.CallPhoneId) and gMainPhoneUtils.CheckAppCanInteractable(MobileMenuSGuiConfig.CallPhoneId)
end

function M:MessageCheckEnable()
	return gUIFunctionStateManager:GetBabaEnable()[2]
end

function M:CameraCheckEnable()
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TakePhotoId)
end

function M:PhotoCheckEnable()
	return true
end

function M:MilkVehicleCheckEnable()
	return gCallPhoneUtils.CheckMilkCarHasUnlocked() and not gLinkManager:CheckInMatchMode() and not gUIFunctionStateManager:CheckVehicleSpiritLimit()
end

function M:CallCarCheckEnable()
	return gCallPhoneUtils.CheckPhoneCallCarHasUnlocked() and not gUIFunctionStateManager:CheckVehicleSpiritLimit()
end

function M:InteractionCheckEnable()
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.HUDPlayerMotionEntrance)
end

function M:ScanCheckEnable()
	return gUIFunctionStateManager:GetScanEnable()[2]
end

function M:TalentTreeCheckEnable()
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TalentTreeId)
end

function M:GuideCheckEnable()
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TeachingId)
end

function M:BubbleCheckEnable()
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.SocialMediaId)
end

function M:ChatCheckEnable()
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.ChatId)
end

function M:OnlineCheckEnable(cfg)
	return gMainPhoneUtils.CheckAppCanShow(cfg.AppId)
end

function M:TeamCircleTrigger()
	gUIFunctionStateManager:OpenTeam()
end

function M:RoleCircleTrigger()
	gUIFunctionStateManager:OpenXuWei()
end

function M:TaskCircleTrigger()
	gUIFunctionStateManager:OpenTaskList()
end

function M:MapCircleTrigger()
	gUIFunctionStateManager:OpenMap()
end

function M:BagCircleTrigger()
	gUIFunctionStateManager:OpenPackage()
end

function M:YanjieCircleTrigger()
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.SocialNetworkId)
end

function M:PhoneCircleTrigger()
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.CallPhoneId)
end

function M:CameraCircleTrigger()
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.TakePhotoId)
end

function M:PhotoCircleTrigger()
	gUIUtils:CommonShowPhoto({
		imageId = 0
	})
end

function M:MilkVehicleCircleTrigger()
	gCallPhoneUtils.OnMilkCarSummonBtnClick()
end

function M:CallCarCircleTrigger()
	gCallPhoneUtils.OnCarSummonBtnClick()
end

function M:InteractionCircleTrigger()
	return gMainPhoneFunctionAction.OpenCharMotionPanel()
end

function M:ScanCircleTrigger()
	gUIFunctionStateManager:Scan()
end

function M:TalentTreeCircleTrigger()
	return gMainPageManager:TalentTreeOpenTrigger()
end

function M:GuideCircleTrigger()
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.TeachingId)
end

function M:BubbleCircleTrigger()
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.SocialMediaId)
end

function M:MessageCircleTrigger()
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.MessageId)
end

function M:ChatCircleTrigger()
	return gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.ChatId)
end

function M:OnlineCircleTrigger(cfg)
	return gMainPhoneUtils.OnAppItemClick(cfg.AppId)
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:SwitchWeapon()
	if self.weaponSelectIndex > 0 then
		local idx = gWeaponManager:ConvertSelectIndex(self.weaponSelectIndex, self.targetPageIndex)
		local item = self.weaponItemMap[idx]

		self.weaponItemStore[self.weaponSelectIndex].btn:LuaSimulateClick()

		if item then
			if item.Using then
				return
			end

			gClientToGameSceneDelegate:AskSwitchWeapon(item.Index)
		end
	end
end

function M:OpenSystem()
	local item = self.sysItemMap[self.sysSelectIndex]

	if item and item.cfg and item.enable then
		if self.leftExtraMode then
			if self.sysSelectIndex == 8 or self.sysSelectIndex == 9 then
				self.sysCircle["sysBtnEx" .. self.sysSelectIndex]:LuaSimulateClick()
			else
				self.sysCircle["sysBtn" .. self.sysSelectIndex]:LuaSimulateClick()
			end
		else
			self.sysCircle["sysBtn" .. self.sysSelectIndex]:LuaSimulateClick()
		end

		if self.sysSelectIndex == self.sysTaskIndex and self.sysTaskAction then
			gDialogAction:RunCodeByTask(self.sysTaskAction)
		else
			self[item.cfg.Circle .. "CircleTrigger"](self, item.cfg)
		end
	end
end

function M:SummonMember()
	local item = self.summonItemMap[self.summonSelectIndex]

	if item and not item.IsEmpty and item.StatusCurrent == self.SUMMON_STATE.Summonable then
		gClientToGameDelegate:AskSummonGangMember(item.TemplateId).Callback = self.summonCb
	end
end

function M:DisbandMember()
	local item = self.summonItemMap[self.summonSelectIndex]

	if item and not item.IsEmpty and item.StatusCurrent == self.SUMMON_STATE.Disbandable then
		gClientToGameDelegate:AskDestroyGangMember(item.TemplateId).Callback = self.disbandCb
	end
end

function M:UpdateWeaponArrowSelect()
	if self.updateSelect then
		self:UpdateSmoothMoveVector()

		local index, angle = self:GetWeaponSelect(self.moveVector)
		self.weaponCircle.weaponStartSelect = self.SELECT_MODE.TRUE

		self:SetWeaponSelect(index)

		self.weaponCircle.weaponArrowAngle = -angle
	end
end

function M:GetWeaponSelect(moveVector)
	local angle = self:CalculateAngle(self.weaponInitVector, moveVector)

	if angle < 0 then
		angle = angle + 360
	end

	local index = math.floor(angle / self.weaponEachAngle) + 1

	return index, angle
end

function M:SetWeaponSelect(index, force)
	if self.weaponSelectIndex ~= index or force then
		if self.weaponSelectIndex > 0 then
			self.weaponItemStore[self.weaponSelectIndex].SelectingActiveCtrl = self.SELECT_MODE.FALSE
		end

		self.weaponSelectIndex = index

		if self.weaponSelectIndex > 0 then
			self.weaponItemStore[self.weaponSelectIndex].SelectingActiveCtrl = self.SELECT_MODE.TRUE
		end

		self:SetWeaponDetailInfo(self.weaponSelectIndex)
	end
end

function M:SetWeaponDetailInfo(index)
	local idx = gWeaponManager:ConvertSelectIndex(index, self.targetPageIndex)
	local item = self.weaponItemMap[idx]

	if item then
		self.weaponCircle.ShowWeaponDetailCtrl = item.Cfg.Category + 1
		self.weaponCircle.weaponName = item.Cfg.Name or ""
		self.weaponCircle.weaponAttackLevel = gWeaponManager:GetWeaponAttrRank(item.AttackFill)
		self.weaponCircle.weaponPoiseLevel = gWeaponManager:GetWeaponAttrRank(item.PoiseFill)
		self.weaponCircle.QualityCtrl = item.Cfg.Quality
		self.weaponCircle.weaponDescription = item.Cfg.Description or ""
		local warn = self.WARN_TEXT.EMPTY

		if item.CantDiscard or item.IsPrivate then
			warn = self.WARN_TEXT.NO_DROP
			self.weaponCircle.weaponDropBtnMobile.interactable = false

			self.weaponCircle.weaponDropBtnPC:SetActive(false)
			self.weaponCircle.weaponDropBtnPad:SetActive(false)
		else
			self.weaponCircle.weaponDropBtnMobile.interactable = true

			self.weaponCircle.weaponDropBtnPC:SetActive(true)
			self.weaponCircle.weaponDropBtnPad:SetActive(true)

			if item.CategoryType == CategoryType.Weapon and item.BrokenState > 0 then
				warn = item.BrokenState + 1
			end
		end

		self.weaponCircle.WarningTextCtrl = warn

		if #item.tags > 0 then
			self.weaponCircle.weaponHasElemtensCtrl = self.SELECT_MODE.TRUE

			self.weaponCircle.weaponTagList:SetSimpleList(#item.tags)
		else
			self.weaponCircle.weaponHasElemtensCtrl = self.SELECT_MODE.FALSE
		end

		if item.RedDot > 0 then
			self:ClearWeaponRedDot(item)
		end
	else
		self.weaponCircle.ShowWeaponDetailCtrl = self.SELECT_MODE.FALSE
		self.weaponCircle.weaponDropBtnMobile.interactable = false

		self.weaponCircle.weaponDropBtnPC:SetActive(false)
		self.weaponCircle.weaponDropBtnPad:SetActive(false)
	end

	self:SetWeaponToolTipInfo(item)
end

function M:SetWeaponToolTipInfo(item)
	if item and self.weaponShowToolTip then
		self.weaponCircle.ShowTooltipCtrl = self.SELECT_MODE.TRUE
		self.toolTipStore.tipWeaponName = item.Cfg.Name or ""
		self.toolTipStore.tipSixDimName = item.SixDimName or ""
		self.toolTipStore.tipSixDimIcon = item.SixDimIcon or 0

		self.toolTipStore.tipTagList:SetSimpleList(#item.tags)

		self.toolTipStore.tipQualityCtrl = item.Cfg.Quality

		if item.CategoryType == CategoryType.Weapon then
			self.toolTipStore.tipShowModeCtrl = 0

			self:SetSkillAndRadarChartInfo(item)

			local ma = ""
			local maIcon = 0
			local currentSpiritId = gBattleSpiritMgr.currentSpiritTemplateId

			if currentSpiritId then
				local skillId = gCS.FightStyleManager.Instance:GetFightStyleByTemplateAndFightStyleCat(currentSpiritId, item.Cfg.FightSkillType)

				if skillId and skillId > 0 then
					local SkillConfig = LTConfig.FightSkillConfig.GetConfig(skillId)

					if SkillConfig then
						ma = SkillConfig.Name or ma
						maIcon = SkillConfig.IconId or 0
					end
				end
			end

			self.toolTipStore.tipMAName = ma
			self.toolTipStore.tipMAIcon = maIcon
			self.toolTipStore.tipDescription = item.Cfg.WeaponBuffDescription or ""
		else
			self.toolTipStore.tipShowModeCtrl = 1
			self.toolTipStore.tipDescription = item.Cfg.Description or ""
		end
	else
		self.weaponCircle.ShowTooltipCtrl = self.SELECT_MODE.FALSE
	end
end

function M:SetSkillAndRadarChartInfo(item)
	local cfg = item.Cfg
	local fill = 0
	local text = ""
	fill = item.AttackFill
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(0, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(0, text)

	fill = Mathf.Clamp01((cfg.AttackRange or 0) / WeaponConfig.MaxWeaponAttackRange) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(1, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(1, text)

	fill = Mathf.Clamp01(cfg.AttackSpeed / WeaponConfig.MaxWeaponAttackSpeed) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(2, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(2, text)

	fill = item.PoiseFill
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(3, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(3, text)

	fill = Mathf.Clamp01(cfg.ImpactForce / WeaponConfig.MaxWeaponImpactForce) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(4, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(4, text)

	if cfg.Durability <= 0 then
		fill = 100
	elseif cfg.ShootId and cfg.ShootId > 0 then
		fill = Mathf.Clamp01(cfg.Durability / WeaponConfig.MaxGunDurability) * 100
	else
		fill = Mathf.Clamp01(cfg.Durability / WeaponConfig.MaxWeaponDurability) * 100
	end

	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(5, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(5, text)
end

function M:ClearWeaponRedDot(item)
	item.RedDot = 0

	SGUI.RedDotMgr.LuaSetRedDot(false, "weapon." .. item.InstanceId)

	local weapons = gWeaponManager:GetCurrentWeapons()

	for i = 1, weapons.Length do
		if weapons[i] and weapons[i].InstanceId == item.InstanceId then
			weapons[i].WeaponFlags.ShowRedDot = false

			break
		end
	end

	gWeaponManager:ClearWeaponRedDot(item.InstanceId)
end

function M:OnWeaponTagListRenderItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local item = self.weaponItemMap[self.weaponSelectIndex]

	if item and item.tags then
		local data = item.tags[index + 1]

		if data and store then
			store.TypeCtrl = data.TagType
		end
	end
end

function M:OnWeaponTabListRenderItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local item = self.weaponTabList[index + 1]

	if item and store then
		store.text = item
	end
end

function M:UpdateSystemArrowSelect()
	if self.CIRCLE_OPEN_ANIME_TIME < Time.unscaledTime - self.circleOpenTime and self.updateSelect then
		self:UpdateSmoothMoveVector()

		local index, angle = self:GetSystemSelect(self.moveVector)

		if (self.sysCircle.sysStartSelect == nil or self.sysCircle.sysStartSelect == self.SELECT_MODE.FALSE) and not self.sysFirstSelect then
			self.sysFirstSelect = true
			self.sysCircle.sysFirstSelectCtrl = 0
		end

		self.sysCircle.sysStartSelect = self.SELECT_MODE.TRUE
		self.sysCircle.sysSelectMode = index
		self.sysCircle.sysArrowAngle = -angle
		self.sysSelectIndex = index
		local item = self.sysItemMap[index]

		if item then
			self.sysCircle.sysTitle = item.cfg.Name
			self.sysCircle.sysTextInfo = item.cfg.Description

			if item.enable and not item.glowed and item.cfg.IsShowGuide then
				item.glowed = true
				self.sysCircle["sysGlow" .. index] = false
				self.localCircleInfo["SysCircle." .. item.cfg.Circle .. ".Glowed"] = true
				self.needSave = true
			end
		else
			self.sysCircle.sysTitle = ""
			self.sysCircle.sysTextInfo = ""
		end
	end
end

function M:GetSystemSelect(moveVector)
	local angle = self:CalculateAngle(self.sysInitVector, moveVector)
	local calAngle = angle + self.sysEachAngle / 2

	if angle < 0 then
		angle = angle + 360
	end

	if calAngle < 0 then
		calAngle = calAngle + 360
	end

	local index = math.floor(calAngle / self.sysEachAngle) + 1

	if index < 8 then
		return index, angle
	end

	if self.leftExtraMode then
		if index > 8 and index < 12 then
			return 19 - index, angle
		end
	else
		calAngle = calAngle - self.sysEachAngle / 2
		index = math.floor(calAngle / self.sysEachAngle) + 1

		if index > 8 and index < 11 then
			return 18 - index, angle
		end
	end

	return 0, angle
end

function M:ForceSetSystemSelect(index)
	if not self.sysReady then
		return
	end

	self.sysCircle.sysSelectMode = index
	self.sysSelectIndex = index
	local item = self.sysItemMap[index]

	if item and item.cfg then
		self.sysCircle.sysTitle = item.cfg.Name
		self.sysCircle.sysTextInfo = item.cfg.Description
	else
		self.sysCircle.sysTitle = ""
		self.sysCircle.sysTextInfo = ""
	end
end

function M:RefreshSystemStuntState()
	local state = gUIFunctionStateManager:GetFeedbackEnable()[1]

	self.sysCircle.sysFeedbackBtn:SetActive(state)

	state = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Survey)

	self.sysCircle.sysSurveyBtn:SetActive(state)
end

function M:OnFeedbackBtnClick()
	if not self.localCircleInfo.FeedbackShowOnce then
		self.localCircleInfo.FeedbackShowOnce = true
		self.needSave = true
		self.needNotifySystemControls = true
	end

	gMainPhoneFunctionAction.OpenFeedback()
end

function M:OnSurveyBtnClick()
	gNewMailsMgr:OpenSurvey()
end

function M:UpdateSummonArrowSelect()
	if self.updateSelect then
		self:UpdateSmoothMoveVector()

		local index, angle = self:GetSummonSelect(self.moveVector)
		self.summonCircle.summonStartSelectCtrl = self.SELECT_MODE.TRUE

		self:SetSummonSelect(index)

		self.summonCircle.summonArrowAngle = -angle
	end
end

function M:GetSummonSelect(moveVector)
	local angle = self:CalculateAngle(self.summonInitVector, moveVector)

	if angle < 0 then
		angle = angle + 360
	end

	local index = math.floor(angle / self.summonEachAngle) + 1

	return index, angle
end

function M:SetSummonSelect(index, force)
	if self.summonSelectIndex ~= index or force then
		if self.summonSelectIndex > 0 then
			self.summonItemStore[self.summonSelectIndex].SelectingActiveCtrl = self.SELECT_MODE.FALSE
		end

		self.summonSelectIndex = index

		if self.summonSelectIndex > 0 then
			self.summonItemStore[self.summonSelectIndex].SelectingActiveCtrl = self.SELECT_MODE.TRUE
		end

		self:SetSummonDetailInfo(self.summonSelectIndex)
	end
end

function M:SetSummonDetailInfo(index)
	if index == 8 then
		self.summonCircle.summonShowCompanionDetailsCtrl = self.SUMMON_SHOW.Exit
		self.summonCircle.summonShowDisbandCtrl = self.SELECT_MODE.FALSE

		return
	end

	local item = self.summonItemMap[index]

	if item and not item.IsEmpty then
		self.summonCircle.summonShowCompanionDetailsCtrl = self.SUMMON_SHOW.Detail
		self.summonCircle.summonAgentName = item.AgentCfg and item.AgentCfg.Name or ""
		self.summonCircle.summonAgentType = item.Cfg and item.Cfg.AgentType or ""

		if item.Status == self.SUMMON_STATE.Summonable and gGangMemberManager.limit <= self.summonNumCurrent then
			item.StatusCurrent = self.SUMMON_STATE.Full
		else
			item.StatusCurrent = item.Status
		end

		self.summonCircle.summonStatusTextCtrl = item.StatusCurrent

		if item.StatusCurrent == self.SUMMON_STATE.Lock then
			self.summonCircle.summonAgentDesc = item.Cfg and item.Cfg.UnlockConditionsDescription or ""
		else
			self.summonCircle.summonAgentDesc = item.Cfg and item.Cfg.AgentTypeDescription or ""
		end

		if item.Status == self.SUMMON_STATE.Recovering then
			self.needUpdateSummonSelectRecover = true
			self.recoverFullTime = item.NextReviveTimeStamp
		else
			self.needUpdateSummonSelectRecover = false
		end

		self.summonCircle.summonShowDisbandCtrl = item.StatusCurrent == self.SUMMON_STATE.Disbandable and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
	else
		self.summonCircle.summonShowCompanionDetailsCtrl = self.SUMMON_SHOW.Empty
		self.needUpdateSummonSelectRecover = false
		self.summonCircle.summonShowDisbandCtrl = self.SELECT_MODE.FALSE
	end
end

function M:UpdateSelectRecoverCountDown(nowTime)
	if self.needUpdateSummonSelectRecover and self.summonSelectInterval <= nowTime - self.summonSelectLastUpdateTime then
		self.summonSelectLastUpdateTime = nowTime
		self.summonCircle.summonRecoverTime = gShopManager:FormatLeftTime(self.recoverFullTime, nowTime)
	end
end

function M:UpdateCircleRecoverCountDown(nowTime)
	if self.needUpdateSummonCircleRecover and self.summonCircleInterval < nowTime - self.summonCircleLastUpdateTime then
		self.summonCircleLastUpdateTime = nowTime

		for i = 1, #self.summonItemMap do
			local item = self.summonItemMap[i]

			if item.Status == self.SUMMON_STATE.Recovering then
				local fill = 1

				if item.RecoverCd > 0 then
					fill = item.NextReviveTimeStamp - nowTime

					if fill < 0 then
						fill = 0
					end

					fill = Mathf.Clamp01(fill / item.RecoverCd)
				end

				self.summonItemStore[i].recoverFillAmount = fill
			end
		end
	end
end

function M:CalculateAngle(initVec, endVec)
	local angle = Vector2.SignedAngle(endVec, initVec)

	return angle
end

function M:OnMouseMove(context)
	if self.isDragMove then
		return
	end

	if context.performed then
		self.accumulateMoveVector:Add(context:ReadValueVector2())
		self:SetVectorLength(self.accumulateMoveVector, self.MaxVectorLength)

		if self.MinVectorLength <= self.accumulateMoveVector.sqrMagnitude then
			self:SetSmoothMove(self.accumulateMoveVector)
		else
			self:ClearSmoothMove()
		end
	end
end

function M:OnStickMove(context)
	local value = context:ReadValueVector2()

	if context.performed then
		self:UpdateSmoothMoveVector()
		self:SetSmoothMove(value)
	elseif context.canceled then
		self:ClearSmoothMove()
	end
end

function M:OnDragMoveStart(eventPointer)
	self.isDragMove = true
end

function M:OnDragMoveEnd(eventPointer)
	self.isDragMove = false
end

function M:OnDragMove(eventPointer)
	if not self.STATE_EnableOnce then
		return
	end

	self.accumulateMoveVector:Add(eventPointer.delta * 5)
	self:SetVectorLength(self.accumulateMoveVector, self.MaxVectorLength)

	if self.MinVectorLength <= self.accumulateMoveVector.sqrMagnitude then
		self:SetSmoothMove(self.accumulateMoveVector)
	else
		self:ClearSmoothMove()
	end
end

function M:SetVectorLength(vec, maxLength)
	local length = vec.sqrMagnitude

	if maxLength < length then
		vec:Mul(maxLength / length)
	end
end

function M:SetSmoothMove(moveVector)
	self.updateSelect = true
	self.smoothStartVector.x = self.moveVector.x
	self.smoothStartVector.y = self.moveVector.y
	self.smoothStartTime = Time.unscaledTime
	self.smoothEndVector.x = moveVector.x
	self.smoothEndVector.y = moveVector.y
end

function M:UpdateSmoothMoveVector()
	if not self.updateSelect then
		return
	end

	if self.gamepadMode then
		local x, y = gCS.LuaUtils.Vector3Slerp(self.smoothStartVector.x, self.smoothStartVector.y, 0, self.smoothEndVector.x, self.smoothEndVector.y, 0, (Time.unscaledTime - self.smoothStartTime) / self.SMOOTH_TIME)
		self.moveVector.x = x
		self.moveVector.y = y

		if self.SMOOTH_TIME < Time.unscaledTime - self.smoothStartTime then
			self:ClearSmoothMove()
		end
	else
		self.moveVector.x = self.smoothEndVector.x
		self.moveVector.y = self.smoothEndVector.y

		self:ClearSmoothMove()
	end
end

function M:ClearSmoothMove()
	self.updateSelect = false
end

function M:CloseCircleNoEvent()
	if not self.STATE_EnableOnce then
		return
	end

	if not self.circleOpen then
		return
	end

	self.circleOpen = false
	self.targetMode = self.CIRCLE_MODE.HIDE

	if self.currentMode ~= self.CIRCLE_MODE.HIDE then
		self:OnCircleClose()

		self.currentMode = self.CIRCLE_MODE.HIDE
	end

	self.sysReady = false
	self.weaponReady = false
	self.summonReady = false
end

function M:OnDetailsBtnClick()
	self.weaponShowToolTip = not self.weaponShowToolTip

	self.weaponCircle.detailsBtn:SetSelected(self.weaponShowToolTip)
	self.weaponCircle.tooltipDescBtnPc:SetSelected(self.weaponShowToolTip)
	self.weaponCircle.tooltipDescBtnPad:SetSelected(self.weaponShowToolTip)

	self.localCircleInfo.SHOW_WEAPON_CIRCLE_TOOLTIP = self.weaponShowToolTip
	self.needSave = true
	local idx = gWeaponManager:ConvertSelectIndex(self.weaponSelectIndex, self.targetPageIndex)
	local item = self.weaponItemMap[idx]

	self:SetWeaponToolTipInfo(item)
end

function M:UpdateSystemTime(force)
	if self.sysFirstSelect then
		return
	end

	if force or self.SysTimeUpdateInterval < Time.time - self.sysTimeLastUpdate then
		self.sysTimeLastUpdate = Time.time
		local gameTime = AtmosphereManager.Instance:GetGameTime()
		local min = math.floor(gameTime / 60 % 60)
		local hour = math.floor(gameTime / 3600)
		self.sysCircle.sysTimeHour = gString.Format("%02d", hour)
		self.sysCircle.sysTimeMinute = gString.Format("%02d", min)
		self.sysCircle.sysTimePeriod = hour < 12 and "am" or "pm"
	end
end

function M:OnTaskShortcutChange(eventId, data)
	local isShow = data.isShow or false
	local preCfgId = self.sysTaskConfigId

	if isShow then
		local NewValue = data.NewValue
		local cfgId = data.cfgId

		if not NewValue then
			if data.pcKeyId == 164 then
				cfgId = 1
			elseif data.pcKeyId == 8 then
				cfgId = 2
			elseif data.pcKeyId == 165 then
				cfgId = 3
			elseif data.pcKeyId == 168 then
				cfgId = 4
			else
				cfgId = 1
			end
		end

		local inputCfg = TaskShortCutConfig.GetConfig(cfgId)

		if not inputCfg then
			self.sysTaskConfigId = nil
			self.sysTaskAction = nil
		else
			self.sysTaskConfigId = inputCfg.CircleId
			self.sysTaskAction = inputCfg.Action
		end
	else
		self.sysTaskConfigId = nil
		self.sysTaskAction = nil
	end

	self.sysReady = self.sysReady and preCfgId == self.sysTaskConfigId

	if self.STATE_EnableOnce and self.currentMode == self.CIRCLE_MODE.SYSTEM and not self.sysReady then
		self:RefreshSystemCircle()
		self:SwitchToCurrentCircle()
	end
end

function M:OnGangMemberInfoChange(eventId, templateId)
	if self.STATE_EnableOnce and self.currentMode == self.CIRCLE_MODE.SUMMON and self.summonReady then
		local needRefreshCircleRecoverState = false
		local needRefreshSummonNum = false
		local updateIndex = -1

		for i = 1, #self.summonItemMap do
			local item = self.summonItemMap[i]

			if item.TemplateId == templateId then
				updateIndex = i
				local info = gGangMemberManager:GetGangMemberInfoByTemplateId(templateId)
				local preStatus = item.Status

				self:UpdateSummonInfo(item, info)
				self:OnRenderSummonCircleItem(i, item)

				if item.Status == self.SUMMON_STATE.Recovering then
					self.needUpdateSummonCircleRecover = true
				elseif preStatus == self.SUMMON_STATE.Recovering then
					needRefreshCircleRecoverState = true
				end

				if preStatus == self.SUMMON_STATE.Disbandable and item.Status == self.SUMMON_STATE.Summonable or preStatus == self.SUMMON_STATE.Disbandable and item.Status == self.SUMMON_STATE.Recovering or preStatus == self.SUMMON_STATE.Summonable and item.Status == self.SUMMON_STATE.Disbandable then
					needRefreshSummonNum = true
				end

				break
			end
		end

		if needRefreshCircleRecoverState then
			self.needUpdateSummonCircleRecover = false

			for i = 1, #self.summonItemMap do
				if self.summonItemMap[i].Status == self.SUMMON_STATE.Recovering then
					self.needUpdateSummonCircleRecover = true

					break
				end
			end
		end

		if needRefreshSummonNum then
			self.summonNumCurrent = 0

			for i = 1, #self.summonItemMap do
				if self.summonItemMap[i].Status == self.SUMMON_STATE.Disbandable then
					self.summonNumCurrent = self.summonNumCurrent + 1
				end
			end

			self.summonCircle.summonNumCurrent = self.summonNumCurrent
		end

		if updateIndex == self.summonSelectIndex then
			self:SetSummonSelect(self.summonSelectIndex, true)
		end
	end
end

function M:OnWeaponOperatorFlagsChange(eventId, data)
	if self.STATE_EnableOnce and self.currentMode == self.CIRCLE_MODE.WEAPON and self.weaponReady then
		for i = 1, #self.weaponItemMap do
			local item = self.weaponItemMap[i]

			if item and item.InstanceId == data.weaponId then
				item.IsTask = gWeaponManager:GetFlag(data.operatorFlags, 2) == 1
				item.CantDiscard = gWeaponManager:GetFlag(data.operatorFlags, 1) == 1
				local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)
				local idx = i - startIdx

				if startIdx < i and i <= endIdx and idx > 0 and idx <= self.MAX_SLOT_COUNT then
					self:OnRenderWeaponCircleItem(idx, item)
				end

				if self.weaponSelectIndex == idx then
					self:SetWeaponSelect(self.weaponSelectIndex, true)
				end

				break
			end
		end
	end
end

function M:WeaponDropCurrentSelect()
	local idx = gWeaponManager:ConvertSelectIndex(self.weaponSelectIndex, self.targetPageIndex)
	local item = self.weaponItemMap[idx]

	if item then
		if item.IsPrivate or item.CantDiscard then
			return
		end

		gClientToGameSceneDelegate:AskDiscardWeapon(item.Index)
	end
end

function M:OnWeaponMouseScroll(context)
	if context.performed then
		local zoom = context:ReadValueVector2().y

		if zoom > 0 then
			self:ScrollWeaponType(true)
		elseif zoom < 0 then
			self:ScrollWeaponType(false)
		end
	end
end

function M:ScrollWeaponType(up)
	if up then
		if self.targetPageIndex <= 1 then
			return
		end

		self.targetPageIndex = self.targetPageIndex - 1

		self:SwitchToCurrentCircle()
		self:PlaySwitchAnime(true)
	else
		if self.targetPageIndex >= #self.weaponTabList then
			return
		end

		self.targetPageIndex = self.targetPageIndex + 1

		self:SwitchToCurrentCircle()
		self:PlaySwitchAnime(false)
	end
end

function M:OnSwitchWeaponPage()
	local index = self.weaponCircle.weaponTabList.selectedIndex + 1
	local up = index < self.targetPageIndex
	self.targetPageIndex = index

	self:SwitchToCurrentCircle()
	self:PlaySwitchAnime(up)
end

function M:PlaySwitchAnime(up)
	gCS.LuaUtils.PlayAnimationByName(self.weaponCircle.anime, up and self.WeaponSwitchAnimeUp or self.WeaponSwitchAnimeDown)
end

function M:SwitchWeaponTypeLoop()
	local to = self.targetPageIndex + 1

	if to > #self.weaponTabList then
		to = 1
	end

	local up = to < self.targetPageIndex
	self.targetPageIndex = to

	self:SwitchToCurrentCircle()
	self:PlaySwitchAnime(up)
end

function M:RebuildWeaponCircleView()
	local startIndex, endIndex = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)

	for i = 1, self.MAX_SLOT_COUNT do
		local idx = i + startIndex

		if endIndex >= idx then
			local item = self.weaponItemMap[idx]

			self:OnRenderWeaponCircleItem(i, item)
		else
			self:OnRenderWeaponCircleItem(i)
		end
	end
end

function M:OnRenderWeaponCircleItem(index, item)
	local store = self.weaponItemStore[index]

	if item then
		store.weaponIcon = item.Cfg.SWeaponWheelsIconId
		store.durability = item.DurablePercent
		store.QualityCtrl = item.Cfg.Quality
		store.UsingCtrl = item.Using and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.IsEmptyCtrl = self.SELECT_MODE.FALSE
		store.TypeCtrl = item.IsTask and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.ShowBgCtrl = item.IsPrivate and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.DropStateCtrl = self.SELECT_MODE.FALSE
		store.guideID = item.guideID
		store.redKey = item.RedDot > 0 and "weapon." .. item.InstanceId or ""
		store.BrokenCtrl = item.BrokenState
	else
		store.IsEmptyCtrl = self.SELECT_MODE.TRUE
		store.QualityCtrl = 0
		store.ShowBgCtrl = self.SELECT_MODE.FALSE
		store.DropStateCtrl = self.SELECT_MODE.FALSE
		store.guideID = ""
		store.redKey = ""
	end
end

function M:RebuildWeaponPageView()
	self.weaponCircle.weaponTabList:SetSimpleList(#self.weaponTabList)

	self.weaponCircle.WheelTypeCtrl = gWeaponManager.TempWeaponMode and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
end

function M:RemoveWeaponSlot(index)
	if self.STATE_EnableOnce and self.currentMode == self.CIRCLE_MODE.WEAPON then
		self.weaponItemMap[index] = false
		local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)
		local idx = index - startIdx

		if startIdx < index and index <= endIdx and idx > 0 and idx <= self.MAX_SLOT_COUNT then
			self.weaponItemStore[idx].IsEmptyCtrl = self.SELECT_MODE.TRUE
			self.weaponItemStore[idx].DropStateCtrl = self.SELECT_MODE.TRUE
			self.weaponItemStore[idx].QualityCtrl = 0
			self.weaponItemStore[idx].guideID = ""
			self.weaponItemStore[idx].redKey = ""

			if idx == self.weaponSelectIndex then
				self.weaponCircle.ShowWeaponDetailCtrl = self.SELECT_MODE.FALSE
				self.weaponCircle.ShowTooltipCtrl = self.SELECT_MODE.FALSE
			end
		end
	end
end

function M:AddWeaponSlot(index, weapon)
	if self.STATE_EnableOnce and self.currentMode == self.CIRCLE_MODE.WEAPON then
		local item = {
			TemplateId = weapon.TemplateId,
			InstanceId = weapon.InstanceId,
			IsTask = weapon.EventId > 0 and gWeaponManager:GetFlag(weapon.OperatorFlags, 2) == 1,
			CantDiscard = gWeaponManager:GetFlag(weapon.OperatorFlags, 1) == 1
		}
		item.Cfg = WeaponConfig.GetConfig(item.TemplateId)
		item.Index = index - 1

		if false then
			slot4 = 1
		else
			slot4 = 0
		end

		item.RedDot = slot4

		if item.RedDot > 0 then
			SGUI.RedDotMgr.LuaSetRedDot(true, "weapon." .. item.InstanceId)
		end

		if item.Cfg then
			if index <= 2 then
				item.IsPrivate = true
				item.DurablePercent = ""
			else
				gWeaponManager:GetWeaponDurability(item, weapon)
			end

			item.tags = {}

			for j = 1, #item.Cfg.Tags do
				table.insert(item.tags, {
					TagType = item.Cfg.Tags[j]
				})
			end

			local cfg = UrbanAttributeConfig.GetConfig(item.Cfg.sixDimBonus)
			item.SixDimName = cfg and cfg.Name or ""
			item.AttackFill = Mathf.Clamp01(Mathf.Round(item.Cfg.AttackPower / WeaponConfig.MaxWeaponAttackPower * 10) / 10)
			item.SpeedFill = Mathf.Clamp01(Mathf.Round(item.Cfg.AttackSpeed / WeaponConfig.MaxWeaponAttackSpeed * 10) / 10)
			item.Using = gPlayerManager.infoSpirit.bindData.currentWeapon and item.InstanceId == gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId or false
			item.guideID = ""
			self.weaponItemMap[index] = item
			local preIndex = -1
			local taskCanUse = gWeaponManager:CheckWheelTaskGuide(gTaskNodeManager:GetNowDoingTask(), item.Cfg)

			if taskCanUse and (self.weaponGuideIndex < 0 or not self.weaponGuideIsTask and item.IsTask) then
				preIndex = self.weaponGuideIndex
				self.weaponGuideIndex = index
				self.weaponGuideIsTask = item.IsTask
				self.weaponGuideID = item.Cfg.GuideId
			end

			local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)
			local idx = index - startIdx

			if startIdx < index and index <= endIdx and idx > 0 and idx <= self.MAX_SLOT_COUNT then
				self.weaponItemStore[idx].weaponIcon = item.Cfg.SWeaponWheelsIconId
				self.weaponItemStore[idx].durability = item.DurablePercent
				self.weaponItemStore[idx].QualityCtrl = item.Cfg.Quality
				self.weaponItemStore[idx].UsingCtrl = item.Using and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
				self.weaponItemStore[idx].IsEmptyCtrl = self.SELECT_MODE.FALSE
				self.weaponItemStore[idx].TypeCtrl = item.IsTask and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
				self.weaponItemStore[idx].ShowBgCtrl = item.IsPrivate and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
				self.weaponItemStore[idx].DropStateCtrl = self.SELECT_MODE.FALSE
				self.weaponItemStore[idx].redKey = item.RedDot > 0 and "weapon." .. item.InstanceId or ""

				if idx == self.weaponSelectIndex then
					self:SetWeaponDetailInfo(idx)
				end
			end

			if preIndex > 0 then
				self.weaponItemMap[preIndex].guideID = ""
				idx = preIndex - startIdx

				if startIdx < preIndex and preIndex <= endIdx and idx > 0 and idx <= self.MAX_SLOT_COUNT then
					self.weaponItemStore[idx].guideID = ""
				end
			end
		else
			self.weaponItemMap[index] = false

			print_error("Weapon配表找不到配置,TemplateId=", item.TemplateId, "InstanceId=", item.InstanceId)
		end
	end
end

function M:OnCurrentWeaponChange()
	if self.STATE_EnableOnce and self.currentMode == self.CIRCLE_MODE.WEAPON then
		local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)

		for i = 1, #self.weaponItemMap do
			local item = self.weaponItemMap[i]

			if item then
				item.Using = gPlayerManager.infoSpirit.bindData.currentWeapon and item.InstanceId == gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId or false
				local idx = i - startIdx

				if startIdx < i and i <= endIdx and idx > 0 and idx <= self.MAX_SLOT_COUNT then
					self.weaponItemStore[idx].UsingCtrl = item.Using and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
				end
			end
		end
	end
end
