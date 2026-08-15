local BatteryUtils = LX6.Engine.BatteryUtils
local RedDotMgr = SGUI.RedDotMgr
local GameConfig = LTConfig.GameConfig
local HudDescConfig = LTConfig.HudDescConfig
local MessageConfig = LTConfig.MessageConfig
local AtmosphereManager = LX6.Manager.AtmosphereManager
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local DragEventListener = SGUI.EventSystems.DragEventListener
local EInvokeTime = SGUI.EInvokeTime
C_CoreHudSystemControlStore = DefClass("C_CoreHudSystemControlStore", C_CoreHudSystemControlStore, C_StoreGroup)
GroupName2Class.CoreHudSystemControlStore = C_CoreHudSystemControlStore
local M = C_CoreHudSystemControlStore

function M:GetInstRefByPath(path)
	local inst = self.bindData[path]

	if not inst then
		return nil
	end

	return inst
end

function M:ctor()
	self.CIRCLE_MODE = {
		System = 2,
		Medicine = 1,
		None = 0
	}
	self.SIGNAL_STATE = {
		Weak = 0,
		Middle = 2,
		Low = 1,
		Strong = 3
	}
	self.PHONE_OPEN = {
		False = 0,
		True = 1
	}
end

function M:OnAwake()
	self.bindData.testBtn.luaClick = self:CreateAction("OnTestBtnClick")
	self.bindData.teamBtn.luaClick = self:CreateAction("OnTeamBtnClick")
	self.bindData.backPackBtn.luaClick = self:CreateAction("OnBackPackBtnClick")
	self.bindData.dailyTaskBtn.luaClick = self:CreateAction("OnDailyTaskBtnClick")
	self.bindData.phoneBtn.luaClick = self:CreateAction("OnPhoneBtnClick")
	self.bindData.babaBtn.luaClick = self:CreateAction("OnBabaBtnClick")
	self.bindData.scanBtn.luaClick = self:CreateAction("OnScanBtnClick")
	self.bindData.dungeonDataBtn.luaClick = self:CreateAction("OnDungeonDataBtnClick")
	self.bindData.dungeonChallengeBtn.luaClick = self:CreateAction("OnDungeonChallengeBtnClick")
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnClick")
	self.bindData.characterSwitchBtn.luaPress = self:CreateAction("OnCharacterSwitchBtnPress")
	self.bindData.characterSwitchBtn.luaRelease = self:CreateAction("OnCharacterSwitchBtnRelease")
	self.bindData.characterSwitchBtn.luaInvalidClick = self:CreateAction("OnCharacterSwitchInvalidBtnPress")
	self.bindData.sysCircleBtn.luaPress = self:CreateAction("OnSysCircleBtnPress")
	self.bindData.sysCircleBtn.luaRelease = self:CreateAction("OnSysCircleBtnRelease")
	self.bindData.motionActionBtn.luaClick = self:CreateAction("OnMotionActionClick")
	self.bindData.radioBtn.luaClick = self:CreateAction("OnRadioBtnClick")
	self.bindData.radioSwitchBtnPad.luaClick = self:CreateAction("OnRadioSwitchBtnClick")
	self.bindData.radioSwitchCustomPC.luaGamePadInputChanged = self:CreateAction("OnMouseScroll")
	self.bindData.radioSwitchCustomPS.luaGamePadInputChanged = self:CreateAction("OnTouchPadTouch")
	self.bindData.radioNameScroll.luaInitContent = self:CreateAction("OnRadioNameInit")
	self.bindData.LinkEntranceBtn.luaClick = self:CreateAction("OnLinkEntranceBtnClick")
	self.bindData.feedbackBtn.luaBeginLongPress = self:CreateAction("OnFeedbackBtnClick")
	self.bindData.dlcDownLoadBtn.luaClick = self:CreateAction("OnDlcDownLoadBtnClick")
	self.bindData.talentTreeBtn.luaClick = self:CreateAction("OnTalentTreeBtnClick")
	self.bindData.carSummonBtn.luaClick = self:CreateAction("OnCarSummonBtnClick")
	self.bindData.milkVehicleBtn.luaClick = self:CreateAction("OnMilkBtnClick")
	self.bindData.homeBuildBtn.luaClick = self:CreateAction("OnHomeBuildBtnClick")
	self.bindData.surveyBtn.luaClick = self:CreateAction("OnSurveyBtnClick")
	self.radioName = ""
	self.radioLocatorIndex = -1
	local radioBtnDrag = DragEventListener.Get(self.bindData.radioBtn.gameObject)
	radioBtnDrag.onBeginDrag = self:CreateAction("OnRadioBtnDragBegin")
	radioBtnDrag.onEndDrag = self:CreateAction("OnRadioBtnDragEnd")
	self.redDotCb = self:CreateAction("OnRenderRedDot")
	RedDotMgr.onRenderRedDot = RedDotMgr.onRenderRedDot and RedDotMgr.onRenderRedDot + self.redDotCb or self.redDotCb
	self.CircleMode = self.CIRCLE_MODE.None
	self.needShowDungeon = false
	self.needShowBaba = true
	self.needShowHomeBuild = false
	self.dataSetEvents = {
		{
			gUIFunctionStateManager.StateMonitor,
			"packageEnable",
			self:CreateAction("RefreshBackPackBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"teamEnable",
			self:CreateAction("RefreshTeamBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"exitEnable",
			self:CreateAction("RefreshExitBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"babaEnable",
			self:CreateAction("RefreshBabaBtnStateFull")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"testEnable",
			self:CreateAction("RefreshTestBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"phoneEnable",
			self:CreateAction("RefreshPhoneBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"mainPageEnable",
			self:CreateAction("RefreshSysCircleBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"scanEnable",
			self:CreateAction("RefreshScanBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"xuWeiEnable",
			self:CreateAction("RefreshXuWeiBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"characterSwitchEnable",
			self:CreateAction("RefreshCharacterSwitchBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"radioEnable",
			self:CreateAction("RefreshRadioBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"motionActionEnable",
			self:CreateAction("RefreshMotionActionBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"linkEnable",
			self:CreateAction("RefreshLinkEntranceBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"quickPhoneCallCommonEnable",
			self:CreateAction("RefreshQuickPhoneCallCommonButtonState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"quickPhoneCallMilkEnable",
			self:CreateAction("RefreshQuickPhoneCallMilkButtonState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"feedbackEnable",
			self:CreateAction("RefreshFeedbackBtnState")
		},
		{
			gUIFunctionStateManager.StateMonitor,
			"surveyEnable",
			self:CreateAction("RefreshSurveyBtnState")
		}
	}

	self:RegisterDataSetEvents(self.dataSetEvents)

	self.msgEvents = {
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self:CreateAction("RefreshBabaBtnStateSimple"),
		[gEventConstants.UPDATE_PM_UNREAD_MSG_TIPS] = self:CreateAction("RefreshBabaBtnStateSimple"),
		[gEventConstants.SETTLEMENT_WIN] = self:CreateActionWithArgs("OnDungeonBtnStateChange", true),
		[gEventConstants.SETTLEMENT_RESET] = self:CreateActionWithArgs("OnDungeonBtnStateChange", false),
		[gEventConstants.UPDATE_NOTICE_RED_POT] = self:CreateAction("RefreshRedDotPhone"),
		[gEventConstants.BAIKE_RED_INFO_CHANGE] = self:CreateAction("RefreshRedDotPhone"),
		[gEventConstants.RED_POINT_PANEL_UPDATE] = self:CreateAction("OnRefreshRedDotPanel"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneAppHide"),
		[gEventConstants.ENTER_BASE_VEHICLE_FINISH] = self:CreateAction("OnEnterBaseVehicleFinish"),
		[gEventConstants.EXIT_BASE_VEHICLE_START] = self:CreateAction("OnExitBaseVehicleStart"),
		[gEventConstants.ENTER_VEHICLE_FINISH] = self:CreateAction("OnEnterBaseVehicleFinish"),
		[gEventConstants.EXIT_VEHICLE_START] = self:CreateAction("OnExitBaseVehicleStart"),
		[gEventConstants.MOTOR_RIDER_STATE_CHANGE] = self:CreateAction("OnMotorRiderChange"),
		[gEventConstants.RADIO_STATE_CHANGE] = self:CreateAction("RefreshRadioNameAndState"),
		[gEventConstants.WEAPON_CHANGED] = self:CreateAction("OnWeaponChange"),
		[gEventConstants.ON_SET_PLAYER_ON_METRO] = self:CreateAction("OnSetPlayerOnMetro"),
		[gEventConstants.SWITCH_BASKETBALL_SHOOTING_ENTER] = self:CreateAction("OnBasketballStart"),
		[gEventConstants.SWITCH_BASKETBALL_SHOOTING_EXIT] = self:CreateAction("OnBasketballExit"),
		[gEventConstants.LING_GROUP_CHANGED] = self:CreateAction("OnLingGroupChange"),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("OnLinkModeChange"),
		[gEventConstants.ANDROID_CONTROL_SWITCH] = self:CreateAction("OnAndroidControlSwitch"),
		[gEventConstants.HOME_FURNITURE_ENTER_HOUSE] = self:CreateActionWithArgs("OnHomeBuildBtnStateChange", true),
		[gEventConstants.HOME_FURNITURE_EXIT_HOUSE] = self:CreateActionWithArgs("OnHomeBuildBtnStateChange", false),
		[gEventConstants.SUMMON_STATE_SWITCH] = self:CreateAction("OnSummonStateSwitch"),
		[gEventConstants.TASK_ROLE_TIP_REFRESH] = self:CreateAction("OnTaskSwitchTipRefresh"),
		[gEventConstants.POLICE_SWITCH_POLICE_INFO] = self:CreateAction("OnPoliceStateSwitch")
	}

	self:RegisterMessageEvents(self.msgEvents)

	self.lastUpdateFrame = 0
	self.lastUpdateTime = 0
	self.teamBtnEnable = false
	self.babaBtnEnable = false
	self.phoneBtnEnable = false
	self.backPackBtnEnable = false
	self.xuWeiBtnEnable = false
	self.phoneOpen = false
	self.inBasketball = false
	self.vehicleMode = false
	self.soundDirty = false
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.showRadio = false
	self.DebugRadio = false
	self.RadioOpen = "S_Vx_RadioButton_toUnfold"
	self.RadioClose = "S_Vx_RadioButton_toFold"
	self.RadioTrans = "S_Vx_RadioButton_UnfoldCut"
	self.psTouchStart = false
	self.psTouchStartX = 0
	self.RADIO_CONTROL = {
		ROAR = false,
		VEHICLE = false
	}
	self.RADIO_TIP_STATE = {
		ShowSwitch = 1,
		ShowRadioOpen = 2,
		None = 0
	}
	self.ROAR_TEMPLATE = LTConfig.WeaponConfig.radioSquirrel
	self.isAndroidControl = gUIFunctionStateManager.isAndroidControl
	self.IsRadioOpened = false
	self.radioDragStartX = 0
	self.isRadioDrag = false
	self.DragSwitchThreshold = 15
	self.canSummonVehicle = gVehicleGamePlayManager.cs_manager:CheckAskSummonCondition()
end

function M:OnGroupEnable()
	self.teamBtnStore = self:GetStoreByWidget(self.bindData.teamBtn)
	self.teamBtnStore.btnId = HudDescConfig.SYSTEM_TEAM_BTN
	self.backPackBtnStore = self:GetStoreByWidget(self.bindData.backPackBtn)
	self.backPackBtnStore.btnId = HudDescConfig.SYSTEM_PACK_BTN
	self.phoneBtnStore = self:GetStoreByWidget(self.bindData.phoneBtn)
	self.phoneBtnStore.btnId = HudDescConfig.SYSTEM_PHONE_BTN
	self.babaBtnStore = self:GetStoreByWidget(self.bindData.babaBtn)
	self.babaBtnStore.btnId = HudDescConfig.SYSTEM_BABA_BTN
	self.scanBtnStore = self:GetStoreByWidget(self.bindData.scanBtn)
	self.scanBtnStore.btnId = HudDescConfig.SYSTEM_SCAN_BTN
	self.exitBtnStore = self:GetStoreByWidget(self.bindData.exitBtn)
	self.exitBtnStore.btnId = HudDescConfig.SYSTEM_EXIT_BTN
	self.testBtnStore = self:GetStoreByWidget(self.bindData.testBtn)
	self.testBtnStore.btnId = HudDescConfig.SYSTEM_TEST_BTN
	self.linkEntranceBtnStore = self:GetStoreByWidget(self.bindData.LinkEntranceBtn)
	self.linkEntranceBtnStore.btnId = HudDescConfig.LINK_ENTRANCE_BTN
	self.dlcDownLoadBtnStore = self:GetStoreByWidget(self.bindData.dlcDownLoadBtn)
	self.dlcDownLoadBtnStore.btnId = HudDescConfig.DLC_DOWN_LOAD_BTN
	self.feedbackBtnStore = self:GetStoreByWidget(self.bindData.feedbackBtn)
	self.feedbackBtnStore.btnId = HudDescConfig.FEEDBACK_BTN
	self.characterSwitchBtnStore = self:GetStoreByWidget(self.bindData.characterSwitchBtn)
	self.sysCircleBtnStore = self:GetStoreByWidget(self.bindData.sysCircleBtn)
	self.motionActionBtnStore = self:GetStoreByWidget(self.bindData.motionActionBtn)
	self.radioBtnStore = self:GetStoreByWidget(self.bindData.radioBtn)
	self.surveyBtnStore = self:GetStoreByWidget(self.bindData.surveyBtn)
	self.surveyBtnStore.btnId = HudDescConfig.SURVEY_BTN

	gStoreButtonMgr:SetButtonEnterBarBsae(self.scanBtnStore, false)
end

function M:OnStart()
	self.phoneOpen = gClientUtils.CheckMainPhoneIsShowing()

	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.bindData.phoneOpenCtrl = self.phoneOpen and self.PHONE_OPEN.True or self.PHONE_OPEN.False

	self:RefreshAllBtnState()
	self:RefreshSignalAndBattery()
	self:RefreshRedDotAll()

	self.isPlayerOnMetro = MassAI.Metro.MetroManager.Instance:CheckPlayerOnMetro()

	self:OnLinkModeChange()
end

function M:OnDestroy()
	self.checkTopRightViewCo = coroutine.stop(self.checkTopRightCo)

	self:ClearDataSetEvents()
	self:ClearMessageEvents()

	RedDotMgr.onRenderRedDot = RedDotMgr.onRenderRedDot and RedDotMgr.onRenderRedDot - self.redDotCb
	self.redDotCb = nil
end

function M:OnUpdate()
	if Time.frameCount - self.lastUpdateFrame > 2000 then
		self.lastUpdateFrame = Time.frameCount

		self:RefreshBabaBtnStateSimple()
	end

	if Time.time - self.lastUpdateTime > 1 then
		self.lastUpdateTime = Time.time

		self:UpdateSignal()
		self:UpdateBattery()
		self:UpdateSystemTime()
	end
end

function M:CheckTopRightViwCanVisible()
	if gClientUtils.CheckMainPhoneIsShowing() then
		return false
	end

	local conflictPanelIdList = {
		gPanelId.S_PHONE_CALL_IN_PANEL
	}

	for _, panelId in ipairs(conflictPanelIdList) do
		if gPanelManager:IsPanelShowing(panelId) then
			return false
		end
	end

	return true
end

function M:OnTestBtnClick()
	gPanelManager:CheckShow(gPanelId.S_TEST_MAIN_PANEL)
end

function M:OnTeamBtnClick()
	gUIFunctionStateManager:OpenTeam()
end

function M:OnBackPackBtnClick()
	gUIFunctionStateManager:OpenPackage()
end

function M:OnPhoneBtnClick()
	gUIFunctionStateManager:OpenPhone()
end

function M:OnBabaBtnClick()
	if not gUIFunctionStateManager.blockBaba then
		gUIFunctionStateManager:OpenBaba()
	end
end

function M:OnScanBtnClick()
	gUIFunctionStateManager:Scan()
end

function M:OnDungeonDataBtnClick()
	gSettlementMgr:ShowBattleDataPanel()
end

function M:OnDungeonChallengeBtnClick()
	return
end

function M:OnExitBtnClick()
	gUIFunctionStateManager:OpenExit()
end

function M:OnCharacterSwitchBtnPress()
	gUIFunctionStateManager:OpenCharacterSwitch()
end

function M:OnCharacterSwitchBtnRelease()
	gUIFunctionStateManager:ReleaseCloseCharacterSwitch()
end

function M:OnCharacterSwitchInvalidBtnPress()
	gDisplayMessageMgr:ShowMessage(MessageConfig.SwitchCharacterBanedNotify)
end

function M:OnSysCircleBtnPress()
	gStoreManager:GetStoreGroup("CoreHudCircleStore"):OpenSystemCircle()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.feedbackBtnStore.sysCircleOpenCtrl = 1
		self.surveyBtnStore.sysCircleOpenCtrl = 1

		self:RefreshHighlightAnimeState()
	else
		self.feedbackBtnStore.sysCircleOpenCtrl = 0
		self.feedbackBtnStore.highlightAnimeCtrl = 0
		self.surveyBtnStore.sysCircleOpenCtrl = 0
	end
end

function M:RefreshHighlightAnimeState()
	if not self.STATE_EnableOnce then
		return
	end

	local info = gUIUtils:LoadJsonToLuaTableWithPid("LocalCircleInfo") or {}
	local feedbackShow = info.FeedbackShowOnce or false

	self.feedbackBtnStore:Commit("highlightAnimeCtrl", feedbackShow and 0 or 1)
end

function M:OnSysCircleBtnRelease()
	gStoreManager:GetStoreGroup("CoreHudCircleStore"):CloseCircle()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.feedbackBtnStore.sysCircleOpenCtrl = 0
		self.feedbackBtnStore.highlightAnimeCtrl = 0
		self.surveyBtnStore.sysCircleOpenCtrl = 0
	end
end

function M:OnMotionActionClick()
	gMainPhoneFunctionAction.OpenCharMotionPanel()
end

function M:OnRadioBtnClick()
	if self.isRadioDrag then
		return
	end

	if self.RADIO_CONTROL.VEHICLE then
		gPanelManager:CheckShow(gPanelId.S_RADIO_PLAYER_PANEL)
	elseif self.RADIO_CONTROL.ROAR then
		gPanelManager:CheckShow(gPanelId.S_ROAR_PANEL)
	end
end

function M:OnRadioSwitchBtnClick()
	if not self.isRadioPlaying or not self:IsRadioMode() or not self.showRadio or gDialogManager.isShowBranch or not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self:DoRadioSwitch(1)
	self:RadioSwitchOpen()
end

function M:OnMouseScroll(context)
	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue CoreHudSystemControlStore OnMouseScroll In", context.phase, self.isRadioPlaying, self:IsRadioMode(), self.showRadio, gCS.LuaUtils.IsNonMobileAdaptive())
	end

	if not self.isRadioPlaying or not self:IsRadioMode() or not self.showRadio or gDialogManager.isShowBranch or not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if context.performed then
		local zoom = context:ReadValueVector2().y

		if zoom > 0 then
			self:DoRadioSwitch(-1)
			self:RadioSwitchOpen()
		elseif zoom < 0 then
			self:DoRadioSwitch(1)
			self:RadioSwitchOpen()
		end
	end
end

function M:OnTouchPadTouch(context)
	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue CoreHudSystemControlStore OnTouchPadTouch In", context.phase, self.isRadioPlaying, self:IsRadioMode(), self.showRadio, gCS.LuaUtils.IsNonMobileAdaptive())
	end

	if not self.isRadioPlaying or not self:IsRadioMode() or not self.showRadio or gDialogManager.isShowBranch or not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if context.started then
		local touchData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadTouchData()
		self.psTouchStart = true
		self.psTouchStartX = touchData.touch0.x
	end

	if context.canceled and self.psTouchStart then
		local touchData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadTouchData()
		self.psTouchStart = false
		local change = touchData.touch0.x - self.psTouchStartX
		self.psTouchStartX = 0

		if change > 0 then
			self:DoRadioSwitch(1)
			self:RadioSwitchOpen()
		elseif change < 0 then
			self:DoRadioSwitch(-1)
			self:RadioSwitchOpen()
		end
	end
end

function M:OnRadioBtnDragBegin(eventPointer)
	self.isRadioDrag = true
	self.radioDragStartX = eventPointer.position.x
end

function M:OnRadioBtnDragEnd(eventPointer)
	self.isRadioDrag = false
	local dragDis = eventPointer.position.x - self.radioDragStartX

	if self.DragSwitchThreshold < dragDis then
		self:DoRadioSwitch(1)
		self:RadioSwitchOpen()
	elseif dragDis < -self.DragSwitchThreshold then
		self:DoRadioSwitch(-1)
		self:RadioSwitchOpen()
	end
end

function M:DoRadioSwitch(value)
	if self.RADIO_CONTROL.VEHICLE then
		if gStoreManager.DEBUG_UI_INPUT then
			print_error("#NoCreateIssue CoreHudSystemControlStore DoRadioSwitchVehicle", value)
		end

		gRadioPlayerManager:SwitchRadio(gRadioPlayerManager.curDriveVehicleId, value)
	elseif self.RADIO_CONTROL.ROAR then
		if gStoreManager.DEBUG_UI_INPUT then
			print_error("#NoCreateIssue CoreHudSystemControlStore DoRadioSwitchRoar", value)
		end

		gRoarPlayerManager:SwitchRadio(self.RADIO_CONTROL.ROAR, value)
	end
end

function M:SetBtnVisible(btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

function M:SetBtnInteractable(btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

function M:SetBtnControl(btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end

function M:SetBtnActive(btn, active)
	btn:SetActive(active)
end

function M:RefreshAllBtnState()
	self:RefreshTeamBtnState()
	self:RefreshBabaBtnStateFull()
	self:RefreshBackPackBtnState()
	self:RefreshTestBtnState()
	self:RefreshDLCDownLoadBtnState()
	self:RefreshFeedbackBtnState()
	self:RefreshDungeonBtnState()
	self:RefreshPhoneBtnState()
	self:RefreshScanBtnState()
	self:RefreshExitBtnState()
	self:RefreshXuWeiBtnState()
	self:RefreshCharacterSwitchBtnState()
	self:RefreshSysCircleBtnState()
	self:RefreshRadioBtnState()
	self:RefreshMotionActionBtnState()
	self:RefreshHomeBuildBtnState()
	self:RefreshSurveyBtnState()
end

function M:RefreshTeamBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetTeamEnable()

	self:SetBtnControl(self.teamBtnStore, state[1], state[2])
	self:SetBtnActive(self.bindData.teamBtn, state[2])
end

function M:RefreshBackPackBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetPackageEnable()

	self:SetBtnControl(self.backPackBtnStore, state[1], state[2])
	self:SetBtnActive(self.bindData.backPackBtn, state[2])
end

function M:RefreshTestBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetTestEnable()

	self:SetBtnControl(self.testBtnStore, state[1], state[2])
	self:SetBtnActive(self.bindData.testBtn, state[2])
end

function M:RefreshDLCDownLoadBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gDlcDownLoadMgr.hasDLC

	self:SetBtnControl(self.dlcDownLoadBtnStore, state, state)
	self:SetBtnActive(self.bindData.dlcDownLoadBtn, state)
end

function M:RefreshActivityBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gAwardActivityManager:CheckHasActivity()

	self:SetBtnControl(self.activityBtnStore, state, state)
	self:SetBtnActive(self.bindData.activityBtn, state)
end

function M:RefreshFeedbackBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetFeedbackEnable()[1]

	self:SetBtnControl(self.feedbackBtnStore, state, state)
	self:SetBtnActive(self.bindData.feedbackBtn, state)
end

function M:RefreshPhoneBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetPhoneEnable()

	self:SetBtnControl(self.phoneBtnStore, state[1], state[2])
	self:SetBtnActive(self.bindData.phoneBtn, state[2])
end

function M:RefreshCharacterSwitchBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetCharacterSwitchEnable()

	self:SetBtnControl(self.characterSwitchBtnStore, state[1], state[2])
	self:SetBtnActive(self.bindData.characterSwitchBtn, state[1])
end

function M:RefreshSysCircleBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetMainPageEnable()[2]
	local isActive = state and not self.isPlayerOnMetro and not self.isAndroidControl

	self:SetBtnControl(self.sysCircleBtnStore, isActive, isActive)
	self:SetBtnActive(self.bindData.sysCircleBtn, isActive)
end

function M:RefreshRadioBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	self.showRadio = true

	if not self:IsRadioMode() or self.phoneOpen then
		self.showRadio = false
	else
		local state = gUIFunctionStateManager:GetRadioEnable()
		self.showRadio = state[1]
	end

	if self.DebugRadio then
		print_notice("SystemControls_RefreshRadioBtn", self.showRadio, "RadioMode=", self:IsRadioMode(), "XSRaid=", gUIFunctionStateManager.RadioControl.XSRaid, "SysUnlock=", gUIFunctionStateManager.RadioControl.SystemUnlock, "SpoonHide=", gUIFunctionStateManager.RadioControl.SpoonHide, "PhoneOpen=", self.phoneOpen, Time.frameCount)
	end

	self:SetBtnControl(self.radioBtnStore, self.showRadio, self.showRadio)
	self:SetBtnActive(self.bindData.radioBtn, self.showRadio)

	if self.showRadio then
		self:RefreshRadioNameAndState()

		self.soundDirty = true
	end
end

function M:RefreshMotionActionBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetMotionActionEnable()

	self:SetBtnControl(self.motionActionBtnStore, state[1], state[2])
	self:SetBtnActive(self.bindData.motionActionBtn, state[2])
end

function M:IsRadioMode()
	return (self.RADIO_CONTROL.VEHICLE or self.RADIO_CONTROL.ROAR) and true or false
end

function M:RefreshBabaBtnStateFull()
	local state = gUIFunctionStateManager:GetBabaEnable()
	self.needShowBaba = state[2]

	self:RefreshBabaBtnStateSimple()
end

function M:RefreshBabaBtnStateSimple()
	if not self.STATE_EnableOnce then
		return
	end

	local unreadNum = gChatManager:GetTotalUnreadCount()
	local state = self.needShowBaba and unreadNum > 0

	self:SetBtnControl(self.babaBtnStore, state, state)
	self:SetBtnActive(self.bindData.babaBtn, state)
	self:RefreshRedDotBaba()
end

function M:RefreshScanBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetScanEnable()

	gHackManager:SetShowHackBtn(state[1])
	self:SetBtnControl(self.scanBtnStore, state[1], state[2])
	self:SetBtnActive(self.bindData.scanBtn, state[2])
end

function M:RefreshExitBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetExitEnable()

	self:SetBtnControl(self.exitBtnStore, state[1], state[2])
	self:SetBtnActive(self.bindData.exitBtn, state[2])
end

function M:RefreshXuWeiBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetXuWeiEnable()
end

function M:RefreshDungeonBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	self.bindData.showDungeonBtns = self.needShowDungeon
end

function M:OnDungeonBtnStateChange(needShow)
	self.needShowDungeon = needShow

	self:RefreshDungeonBtnState()
end

function M:RefreshHomeBuildBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	self.bindData.showHomeBuildBtn = self.needShowHomeBuild
end

function M:OnHomeBuildBtnStateChange(needShow)
	self.needShowHomeBuild = needShow

	self:RefreshHomeBuildBtnState()
end

function M:OnHomeBuildBtnClick()
	gPanelManager:CheckShow(gPanelId.HOME_BUILD_PANEL)
end

function M:RefreshSurveyBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.Survey)

	self:SetBtnControl(self.surveyBtnStore, state, state)
	self.bindData.surveyBtn.gameObject:SetActive(state)
end

function M:OnSurveyBtnClick()
	gNewMailsMgr:OpenSurvey()
end

function M:RefreshSignalAndBattery()
	local showSignal = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() or gCS.LuaUtils.IsOnPS5 or not gCS.LuaUtils.IsNonMobileAdaptive()
	local showBattery = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.bindData.showSignal = showSignal
	self.bindData.showBattery = showBattery

	self:UpdateSignal()
	self:UpdateBattery()
end

function M:UpdateSignal()
	if not self.bindData.showSignal then
		return
	end

	local state = self.SIGNAL_STATE.Weak

	if gCS.NetworkManager.IsNormalConnected then
		local ping = gCS.TimeManager.DelayTime * 1000

		if ping >= 200 then
			state = self.SIGNAL_STATE.Low
		elseif ping >= 100 and ping < 200 then
			state = self.SIGNAL_STATE.Middle
		else
			state = self.SIGNAL_STATE.Strong
		end
	end

	self.bindData.signalStateCtrl = state
end

function M:UpdateBattery()
	if not self.bindData.showBattery then
		return
	end

	local level = BatteryUtils.BatteryLevel
	self.bindData.showLighting = BatteryUtils.IsBatteryCharge
	self.bindData.batteryFillAmount = level

	if level > 0.2 then
		if self.bindData.showLighting then
			self.bindData.batteryColor = "0DFF00"
		else
			self.bindData.batteryColor = "FFFFFF"
		end
	elseif level <= 0.2 then
		self.bindData.batteryColor = "FF000E"
	end
end

function M:UpdateSystemTime()
	if not self.isMobile then
		return
	end

	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local min = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / 3600)
	self.bindData.currentTimeMobile = gString.Format("%02d:%02d", hour, min)
end

function M:RefreshRedDotAll()
	self:RefreshRedDotBackPack()
	self:RefreshRedDotBaba()
	self:RefreshRedDotPhone()
end

function M:RefreshRedDotBackPack()
	RedDotMgr.LuaSetRedDot(gRedPointMgr:IsPanelHasRedPoint(gPanelId.S_INVENTORY_PANEL), "CoreHudSystemControlStore.Backpack")
end

function M:RefreshRedDotBaba()
	RedDotMgr.LuaSetRedDot(gChatManager:GetTotalUnreadCount() > 0, "CoreHudSystemControlStore.Baba", true)
end

function M:RefreshRedDotPhone()
	if gNetworkState.Reconnect <= gCS.NetworkManager.Instance.currentState then
		return
	end

	gMainPhoneUtils.CheckMainPhoneHasRedDot(function (hasRed)
		RedDotMgr.LuaSetRedDot(hasRed, "CoreHudSystemControlStore.Phone")
	end)
end

function M:OnRefreshRedDotPanel(eventId, panelId)
	if panelId == gPanelId.S_INVENTORY_PANEL then
		self:RefreshRedDotBackPack()
	end
end

function M:OnPhoneAppShow()
	self.phoneOpen = true

	if not self.STATE_EnableOnce then
		return
	end

	self.bindData.phoneOpenCtrl = self.PHONE_OPEN.True

	self:RefreshRadioBtnState()
end

function M:OnPhoneAppHide()
	if not self.STATE_EnableOnce then
		return
	end

	self.phoneOpen = false
	self.bindData.phoneOpenCtrl = self.PHONE_OPEN.False

	self:RefreshRadioBtnState()
	self:RadioSwitchOpen()
end

function M:OnRenderRedDot(redKey, templateKey, redDot)
	if templateKey == "Number" and redKey == "CoreHudSystemControlStore.Baba" then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(redDot)

		if not store then
			return
		end

		local count = gChatManager:GetTotalUnreadCount()

		if GameConfig.ChatMaxRed < count then
			count = GameConfig.ChatMaxRed or count
		end

		store.num = count
	end
end

function M:OnEnterBaseVehicleFinish(eventId, vehicleId)
	self.vehicleMode = true

	if not self.STATE_EnableOnce then
		return
	end

	self:OpenRadioByVehicle(vehicleId)
	self:RefreshTipShowVehicle()
end

function M:OnExitBaseVehicleStart(eventId, vehicleId)
	self.vehicleMode = false

	if not self.STATE_EnableOnce then
		return
	end

	self:CloseRadioByVehicle()
	self:RefreshTipShowVehicle()
end

function M:OnMotorRiderChange(eventId, isInMotor)
	if isInMotor then
		self:OnEnterBaseVehicleFinish(eventId, gRadioPlayerManager.MotorRiderId)
	else
		self:OnExitBaseVehicleStart(eventId, gRadioPlayerManager.MotorRiderId)
	end
end

function M:OnRadioOpen()
	self.isRadioPlaying = false
	self.currRadioIndex = -1

	if self.switchTimer then
		self.switchTimer:Stop()

		self.switchTimer = nil
	end

	if self.radioCloseTimer then
		self.radioCloseTimer:Stop()

		self.radioCloseTimer = nil
	end

	self:RefreshRadioBtnState()
	self:RadioSwitchOpen()
end

function M:OnRadioClose()
	if self.switchTimer then
		self.switchTimer:Stop()

		self.switchTimer = nil
	end

	self.IsRadioOpened = false
	self.radioLocatorIndex = -1
	self.radioName = ""

	self.bindData.radioBtn:InvokeCallback(EInvokeTime.User6)

	if self.radioCloseTimer then
		self.radioCloseTimer:Stop()

		self.radioCloseTimer = nil
	end

	self.radioCloseTimer = Timer.New(function ()
		self:RefreshRadioBtnState()
	end, 0.1):Start()
end

function M:OpenRadioByVehicle(vehicleId)
	self.RADIO_CONTROL.VEHICLE = true

	if self.RADIO_CONTROL.ROAR then
		self:DoCloseByRoar(self.RADIO_CONTROL.ROAR)
	end

	self:DoOpenByVehicle(vehicleId)
	self:OnRadioOpen()
end

function M:DoOpenByVehicle(vehicleId)
	self.currVehicleId = vehicleId

	if gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.CarRadio) then
		gRadioPlayerManager.curDriveVehicleId = vehicleId

		gRadioPlayerManager:RefreshRadioChannel()
		gRadioPlayerManager:PlayRadio(vehicleId)
	end
end

function M:CloseRadioByVehicle()
	self.RADIO_CONTROL.VEHICLE = false

	self:DoCloseByVehicle()

	if self.RADIO_CONTROL.ROAR then
		self:DoOpenByRoar(self.RADIO_CONTROL.ROAR)
		self:OnRadioOpen()
	else
		self:OnRadioClose()
	end
end

function M:DoCloseByVehicle()
	gRadioPlayerManager:StopRadio(gRadioPlayerManager.curDriveVehicleId)

	gRadioPlayerManager.curDriveVehicleId = nil
	self.radioLocatorInitVehicle = false
end

function M:OnWeaponChange(eventId, data)
	if ulong.equals(data.pid, gCS.MyPlayerManager.PlayerUnitId) then
		if data.templateId == self.ROAR_TEMPLATE then
			self:OpenRadioByRoar(data.weaponInstanceId)
		elseif self.RADIO_CONTROL.ROAR then
			self:CloseRadioByRoar()
		end
	end
end

function M:OnSetPlayerOnMetro(_, isPlayerOnMetro)
	self.isPlayerOnMetro = isPlayerOnMetro

	self:RefreshSysCircleBtnState()
end

function M:OnAndroidControlSwitch(eventId, data)
	self.isAndroidControl = data.enterOrLeave

	self:RefreshSysCircleBtnState()
end

function M:OpenRadioByRoar(instanceId)
	if self.RADIO_CONTROL.ROAR and instanceId ~= self.RADIO_CONTROL.ROAR then
		self:DoCloseByRoar(self.RADIO_CONTROL.ROAR)
	end

	self.RADIO_CONTROL.ROAR = instanceId

	if self.RADIO_CONTROL.VEHICLE then
		return
	end

	self:DoOpenByRoar(instanceId)
	self:OnRadioOpen()
end

function M:DoOpenByRoar(instanceId)
	gRoarPlayerManager.curHandWeaponId = instanceId

	if not gCS.WeaponMgr:DoPlaySwitchRadioAgentToWeapon(instanceId) then
		gRoarPlayerManager:PlayRadio(instanceId, gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.PlayerObj.gameObject)
	end
end

function M:CloseRadioByRoar()
	self:DoCloseByRoar(self.RADIO_CONTROL.ROAR)

	self.RADIO_CONTROL.ROAR = false

	if self.RADIO_CONTROL.VEHICLE then
		return
	else
		self:OnRadioClose()
	end
end

function M:DoCloseByRoar(instanceId)
	gRoarPlayerManager.curHandWeaponId = nil

	gRoarPlayerManager:StopRadio(instanceId)

	self.radioLocatorInitRoar = false
end

function M:RadioSwitchOpen()
	if not self:IsRadioMode() then
		return
	end

	if self.showRadio then
		self.bindData.radioTipStateCtrl = self.RADIO_TIP_STATE.ShowSwitch

		if not self.IsRadioOpened then
			self.IsRadioOpened = true

			self.bindData.radioBtn:InvokeCallback(EInvokeTime.User1)
		end
	end
end

function M:OnRadioNameInit(widget)
	widget.text = self.radioName
end

function M:RefreshRadioNameAndState(eventId)
	if not self:IsRadioMode() or not self.showRadio or self.phoneOpen then
		return
	end

	local preRadioState = self.isRadioPlaying

	if self.RADIO_CONTROL.VEHICLE then
		local radioInfo = gRadioPlayerManager:GetRadioInfoByVehicleId(gRadioPlayerManager.curDriveVehicleId)

		if radioInfo then
			self:InitRadioLocatorVehicle()

			self.isRadioPlaying = not gRadioPlayerManager.isPause
			local radioName, radioNumber, icon = gRadioPlayerManager:GetRadioNameNumberAndIconById(radioInfo.curRadioId)

			if not icon then
				print_error("车载电台名称不规范！请策划检查配表！！！,radioId :", radioInfo.curRadioId)
				self:SetRadioName("")
			else
				self:SetLocatorIndex(radioInfo.curRadioIndex - 1)
				self:SetRadioName(radioName .. " " .. radioNumber)
			end

			if not eventId then
				self.bindData.radioCoverIcon = icon or 0
			elseif self.currRadioIndex ~= radioInfo.curRadioIndex then
				self:PlayRadioSwitchAnime(icon or 0)
			end

			self.currRadioIndex = radioInfo.curRadioIndex
		end
	elseif self.RADIO_CONTROL.ROAR then
		self:InitRadioLocatorRoar()

		self.isRadioPlaying = true
		local radioPair, icon = gRoarPlayerManager:GetRadioNameAndIconHudByIndex(gRoarPlayerManager.curRadioIndex)

		if #radioPair ~= 2 then
			print_error("咆哮电台名称不规范！请策划检查配表！！！", radioPair)
			self:SetRadioName("")
		else
			self:SetLocatorIndex(gRoarPlayerManager.curRadioIndex - 1)
			self:SetRadioName(radioPair[1] .. " " .. radioPair[2])
		end

		self.bindData.radioCoverIcon = icon or 0

		if not eventId then
			self.bindData.radioCoverIcon = icon or 0
		elseif self.currRadioIndex ~= gRoarPlayerManager.curRadioIndex then
			self:PlayRadioSwitchAnime(icon or 0)
		end

		self.currRadioIndex = gRoarPlayerManager.curRadioIndex
	end

	if preRadioState ~= self.isRadioPlaying or self.soundDirty then
		self:RefreshRadioPlayState()
	end
end

function M:SetRadioName(name)
	if self.radioName ~= name then
		self.radioName = name

		if self.STATE_EnableOnce then
			self.bindData.radioNameScroll:SetContentDirty()
		end
	end
end

function M:SetLocatorIndex(index)
	if self.radioLocatorIndex ~= index and index >= 0 then
		self.radioLocatorIndex = index

		self.bindData.radioLocatorList:SelectItem(self.radioLocatorIndex, false)
	end
end

function M:InitRadioLocatorVehicle()
	if self.radioLocatorInitVehicle then
		return
	end

	self.radioLocatorInitVehicle = true
	local totalCount = gRadioPlayerManager:GetTotalRadioCount(gRadioPlayerManager.curDriveVehicleId)

	self.bindData.radioLocatorList:SetSimpleList(totalCount)
end

function M:InitRadioLocatorRoar()
	if self.radioLocatorInitRoar then
		return
	end

	self.radioLocatorInitRoar = true
	local totalCount = gRoarPlayerManager:GetTotalRadioCount()

	self.bindData.radioLocatorList:SetSimpleList(totalCount)
end

function M:RefreshRadioPlayState()
	if not self.STATE_EnableOnce then
		return
	end

	self.soundDirty = false

	if self.isRadioPlaying then
		self.bindData.radioBtn:InvokeCallback(EInvokeTime.User3)
	else
		self.bindData.radioBtn:InvokeCallback(EInvokeTime.User4)
	end
end

function M:PlayRadioSwitchAnime(switchIconId)
	self.bindData.radioBtn:InvokeCallback(EInvokeTime.User5)

	if self.switchTimer then
		self.switchTimer:Stop()

		self.switchTimer = nil
	end

	self.switchTimer = Timer.New(function ()
		if not self.STATE_EnableOnce then
			return
		end

		self.bindData.radioCoverIcon = switchIconId
	end, 0.15):Start()
end

function M:RefreshTipShowVehicle()
	local showTip = not self.vehicleMode

	self.bindData.naveArea:ChangeButtonShowTipByRespond(self.bindData.characterSwitchBtn, showTip)
	self.bindData.naveArea:ChangeButtonShowTipByRespond(self.bindData.sysCircleBtn, showTip)
	self.bindData.characterSwitchBtn:SetPCKeyTipShowTip(showTip)
end

function M:RefreshTipShowBasket()
	local showTip = not self.inBasketball

	self.bindData.naveArea:ChangeButtonShowTipByRespond(self.bindData.sysCircleBtn, showTip)
end

function M:OnBasketballStart()
	self.inBasketball = true

	self:RefreshTipShowBasket()
end

function M:OnBasketballExit()
	self.inBasketball = false

	self:RefreshTipShowBasket()
end

function M:OnLinkModeChange()
	self.bindData.onlineMode = gLinkManager.LinkMode

	self:RefreshMotionActionBtnState()
end

function M:OnLinkEntranceBtnClick()
	gLinkManager:ShowLinkPanel()
end

function M:RefreshLinkEntranceBtnState()
	if not self.STATE_EnableOnce then
		return
	end

	local state = gUIFunctionStateManager:GetLinkEnable()

	self:SetBtnControl(self.linkEntranceBtnStore, state[1], state[2])
	self:SetBtnActive(self.bindData.LinkEntranceBtn, state[2])
end

function M:RefreshQuickPhoneCallCommonButtonState()
	local state = gUIFunctionStateManager:GetQuickPhoneCallCommonStateEnable()[1]

	self:SetBtnActive(self.bindData.carSummonBtn, state)
end

function M:RefreshQuickPhoneCallMilkButtonState()
	local state = gUIFunctionStateManager:GetQuickPhoneCallMilkStateEnable()[1]

	self:SetBtnActive(self.bindData.milkVehicleBtn, state)
end

function M:OnTaskSwitchTipRefresh(_, enable)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.switchGuideNode:SetActive(enable)
	end
end

function M:OnLingGroupChange()
	self:RefreshBabaBtnStateFull()
end

function M:OnActivityBtnClick()
	gAwardActivityManager:OpenActivity()
end

function M:OnFeedbackBtnClick()
	gMainPhoneFunctionAction.OpenFeedback()
end

function M:OnDlcDownLoadBtnClick()
	gPanelManager:CheckShow(gPanelId.DLC_DOWNLOAD_PANEL)
end

function M:OnTalentTreeBtnClick()
	if not gMainPageManager:TalentTreeCheckCanShow() then
		return
	end

	gMainPageManager:TalentTreeOpenTrigger()
end

function M:OnCarSummonBtnClick()
	gCallPhoneUtils.OnCarSummonBtnClick()
end

function M:OnMilkBtnClick()
	gCallPhoneUtils.OnMilkCarSummonBtnClick()
end

function M:OnSummonStateSwitch()
	self.bindData.droneState = self:CheckHasDroneAgent() and 1 or 0
end

function M:CheckHasDroneAgent()
	local agentId = gBattleMgr.SummonAgentId
	local unit = gCS.SceneDataMgr.GetUnit(agentId)

	if unit and unit.ClientData and unit.ClientData.AgentId then
		local agentCfg = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)

		return agentCfg.SummonTag == LTConfig.SummonConfig.UAV and gDeliveryTaskManager.isDeliveryJob
	end

	return false
end

function M:OnPoliceStateSwitch()
	self.bindData.policeState = gPoliceJobManager:CheckNeedPoliceInfo() and 1 or 0
end
