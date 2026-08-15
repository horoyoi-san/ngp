C_PhotoPanelStore = DefClass("C_PhotoPanelStore", C_PhotoPanelStore, C_StoreGroup)
GroupName2Class.PhotoPanelStore = C_PhotoPanelStore
local M = C_PhotoPanelStore
local SoundEventConfig = LTConfig.SoundEventConfig
local SoundConfig = LTConfig.SoundConfig
local PhotoConfig = LTConfig.PhotoConfig
local PhotographTemplateConfig = LTConfig.PhotoPhotographTemplateConfig
local PhotoSpiritSelfieParamConfig = LTConfig.PhotoSpiritSelfieParamConfig
local PhotoSelfieActionConfig = LTConfig.PhotoSelfieActionConfig
local PhotoFiltersConfig = LTConfig.PhotoFiltersConfig
local FilterConfig = LTConfig.FilterConfig
local PhotoMode = gTakePhotoUtils.PhotoMode
local PhotoTaskTargetState = gTakePhotoUtils.PhotoTaskTargetState
local PhotoTemplate = gTakePhotoUtils.PhotoTemplate
local GameInputManager = LX6.Manager.GameInputManager
local MainViewUtils = LX6.Gps.MainViewUtils
local GuiMgr = LX6.GUI.GuiMgr
local PhotoUtils = LX6.Utils.PhotoUtils
local SubTypeConfig = PhotoConfig.FunctionsIcon
local HideUITextId = 104
local ShowUITextId = 126
local SelfieSubTabType = {
	photoFrames = 4,
	expression = 2,
	action = 1,
	filters = 3,
	watermark = 5
}
local UpdateHudPriority = {
	AcquisitionNpc = 3,
	Task = 2,
	MultipleTask = 1
}
local CustomTargetType2Priority = {
	[gTakePhotoUtils.PhotoCustomTargetType.Npc] = UpdateHudPriority.AcquisitionNpc
}
local CustomTargetType2TemplateType = {
	[gTakePhotoUtils.PhotoCustomTargetType.Npc] = "npc"
}
local PhotoCustomTargetType = gTakePhotoUtils.PhotoCustomTargetType

function M:ctor()
	self:GenMessageEvents()
end

function M:DefineAllVariables()
	self.isHideFocus = false
	self.photoMode = PhotoMode.FullView
	self.subTabType = SelfieSubTabType.action
	self.templateConfig = {}
	self.selfieTabList = {}
	self.selfieList = {}
	self.photoTemplate = PhotoTemplate.Default
	self.joystickVisible = false
	self.selectedSpirit = nil
	self.spiritsInfos = {}
	self.selectedAction = nil
	self.actionInfos = {}
	self.selectedExpression = nil
	self.defaultExpression = nil
	self.expressionInfos = {}
	self.photoFrameInfos = {}
	self.selectedFrame = 1
	self.selectedFrameIconId = 0
	self.watermarkInfos = {}
	self.watermarkCache = {}
	self.filtersInfos = {}
	self.selectedFilter = -1
	self.environmentInfos = {}
	self.photoTaskInfos = {}
	self.nowFocusTaskId = nil
	self.defaultFov = nil
	self.targetTrans = {}
	self.targetStatesRecord = {}
	self.templates = {}
	self.templatePool = {}
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.isFovBtnPressing = false
	self.FovChangeType = 0
	self.FovChangeTimeSignal = 0
	self.mouseScrollCallback = nil
	self.stopUpdateHud = false
	self.scrollSignal = false
	self.scrollSignalInterval = -1
	self.needHideBtn = {}
	self.isSwitching = false
	self.updateHudDataQueue = {}
	self.customTargetTrans = {}
	self.customTargetResultSet = {}
	self.taskTargetMatch = false
	self.isFocus = true
	self.defaultSelfiePosture = 1
	self.isLEndPress = true
	self.isREndPress = true
	self.isClosing = false
	self.handMoveBeginFun = nil
	self.handMoveEndFun = nil
end

function M:OnAwake()
	self:DefineAllVariables()

	self.photoTemplate = gTakePhotoUtils.GetPhotoTemplate()
	local config = PhotographTemplateConfig.GetConfig(self.photoTemplate)

	if not config then
		print_error("不存在的拍照模板配置:", self.photoTemplate)

		return
	end

	self:CacheConfig(config)

	self.minBlendPitch = PhotoConfig.PhotoCameraBlendAng[1]
	self.maxBlendPitch = PhotoConfig.PhotoCameraBlendAng[2]

	self:RegisterButtons()
	self:RegisterLists()
	self:RegisterSlider()
	self:RegisterJoyStick()
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, true)
	gTakePhotoUtils.CallOnPhotoPanelAwake()

	function self.handMoveBeginFun(eventData)
		if eventData.button ~= 1 then
			return
		end

		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HAND_MOVE, true)
		gCS.LuaUtils.ForceReadMouseMove(true)
	end

	function self.handMoveEndFun(eventData)
		if eventData.button ~= 1 then
			return
		end

		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HAND_MOVE, false)
		gCS.LuaUtils.ForceReadMouseMove(false)
	end

	if LX6.TouchNew.TouchProxy.onActiveBeginDrag then
		LX6.TouchNew.TouchProxy.onActiveBeginDrag = LX6.TouchNew.TouchProxy.onActiveBeginDrag + self.handMoveBeginFun
	else
		LX6.TouchNew.TouchProxy.onActiveBeginDrag = self.handMoveBeginFun
	end

	if LX6.TouchNew.TouchProxy.onActiveEndDrag then
		LX6.TouchNew.TouchProxy.onActiveEndDrag = LX6.TouchNew.TouchProxy.onActiveEndDrag + self.handMoveEndFun
	else
		LX6.TouchNew.TouchProxy.onActiveEndDrag = self.handMoveEndFun
	end
end

function M:OnEnable()
	if self.bindData.selfieMenuFold == nil or self.bindData.selfieMenuFold == 0 then
		GuiMgr.Instance:SetShowJoystick(true, gPanelId.S_PHOTO_PANEL)
	end
end

function M:OnDisable()
	GuiMgr.Instance:SetShowJoystick(false, gPanelId.S_PHOTO_PANEL)
	gTakePhotoUtils.CallOnPhotoPanelDisable()
end

function M:OnStart()
	return
end

function M:OnDestroy()
	gTakePhotoUtils.CallOnPhotoPanelDestroy()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end

	gCS.LuaUtils.ForceReadMouseMove(false)

	LX6.TouchNew.TouchProxy.onActiveBeginDrag = LX6.TouchNew.TouchProxy.onActiveBeginDrag - self.handMoveBeginFun
	LX6.TouchNew.TouchProxy.onActiveEndDrag = LX6.TouchNew.TouchProxy.onActiveEndDrag - self.handMoveEndFun
end

function M:OnShow(panelId, data)
	self.bindData.photoAnim:Play("S_Vx_PhotoPanel_open")

	self.isHideFocus = false

	gTakePhotoUtils.HideUid(true)

	self.selectedSpirit = gBattleSpiritMgr.currentSpiritTemplateId
	self.photoMode = data and data.isSelfIeMode and PhotoMode.Selfie or PhotoMode.FullView

	if self.photoMode == PhotoMode.Selfie then
		self.SubGroup.PhotoCircularSliderStore:SetActive(false)
	end

	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

	self:SetCurrentPhotoMode()
	gTakePhotoUtils.CallOnPhotoPanelShow()

	self.bindData.waterMarkUidText = "UID:" .. ulong.tostring(gPlayerManager.infoBase.bindData.Pid)

	if gTakePhotoUtils.isDebugForce then
		self.bindData.switchBtn:SetActive(false)
		self.SubGroup.PhotoCircularSliderStore:SetActive(false)

		return
	end

	self:HandleSpPhotoTemplate()

	local hideTime = 0

	if self.photoMode == PhotoMode.Selfie then
		hideTime = self.templateConfig.directlyEnterSelfieModeSec
	elseif self.photoMode == PhotoMode.FullView then
		hideTime = self.templateConfig.enterPhotoModeSec
	end

	self:HideTakePhoto(hideTime)
	self:BuildSelfieMenu()
	self.SubGroup.PhotoCircularSliderStore:SetRollingCallback(self.OnFOVChange, self)
	self.SubGroup.PhotoCircularSliderStore:SetToStart(true)
	self.bindData.bodyMoveBtn:SetOnlyShowPCKeyTipInfo(false)
	gTakePhotoUtils.SetPhotoIK(self.isFocus)
end

function M:OnClose()
	gTakePhotoUtils.CallOnPhotoPanelClose()

	if gClientUtils.CheckMainPhoneIsShowing() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	gTakePhotoUtils.HideUid(false)
	table.clear(gLuaUIMgr.takePhotoFocusUnit)
	gTakePhotoUtils.DoSelfieActionEvent(MuGenStates.Logic.GameplayEvent.PhotoSelfieExit)
end

function M:OnCameraUpdate()
	if self.isClosing then
		return
	end

	self:UpdateTargetHud()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnUpdate()
	if self.isClosing then
		return
	end

	self:UpdateHudTargetData()
	self:UpdateGamepadCamera()
	self:UpdateFovByJoyStick()
	self:UpdateScrollStyle()
end

function M:RegisterButtons()
	self.bindData.selfieActionBtn.luaClick = self:CreateAction("OnMoreOperationClick")

	table.insert(self.needHideBtn, self.bindData.selfieActionBtn)

	self.bindData.hideBtn.luaClick = self:CreateAction("OnHideBtnClick")

	table.insert(self.needHideBtn, self.bindData.hideBtn)

	self.bindData.takePhotoBtnEnter.luaClick = self:CreateAction("OnTakePhotoBtnClick")

	table.insert(self.needHideBtn, self.bindData.takePhotoBtnEnter)

	self.bindData.resetBtn.luaClick = self:CreateAction("OnResetBtnClick")
	self.bindData.switchBtn.luaClick = self:CreateAction("OnSwitchBtnClick")

	if self.templateConfig.canSelfie then
		table.insert(self.needHideBtn, self.bindData.switchBtn)
	end

	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")

	table.insert(self.needHideBtn, self.bindData.closeBtn)

	self.bindData.tabHideBtn.luaClick = self:CreateAction("OnTabHideBtnClick")
	self.bindData.TabL1Btn.luaClick = self:CreateActionWithArgs("OnTabBtnClick", 1)
	self.bindData.TabR1Btn.luaClick = self:CreateActionWithArgs("OnTabBtnClick", -1)
	self.bindData.hideClickLeftBtn.luaClick = self:CreateAction("CancelHide")
	self.bindData.hideClickRightBtn.luaClick = self:CreateAction("CancelHide")
	self.bindData.albumBtn.luaClick = self:CreateAction("OnAlbumBtnClick")

	table.insert(self.needHideBtn, self.bindData.albumBtn)

	function self.bindData.handMoveBtn.luaBeginLongPress()
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HAND_MOVE, true)
		gCS.LuaUtils.ForceReadMouseMove(true)
	end

	function self.bindData.handMoveBtn.luaEndLongPress()
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HAND_MOVE, false)
		gCS.LuaUtils.ForceReadMouseMove(false)
	end

	function self.bindData.headMoveBtn.luaBeginLongPress()
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HEAD_MOVE, true)
		gCS.LuaUtils.ForceReadMouseMove(true)
	end

	function self.bindData.headMoveBtn.luaEndLongPress()
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HEAD_MOVE, false)
		gCS.LuaUtils.ForceReadMouseMove(false)
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.handMoveBtn.luaClick = self:CreateAction("OnHandMoveBtnClick")
		self.bindData.headMoveBtn.luaClick = self:CreateAction("OnHeadMoveBtnClick")
		self.bindData.headJoyCloseBtn.luaClick = self:CreateAction("OnHeadJoyCloseBtnClick")
		self.bindData.handJoyCloseBtn.luaClick = self:CreateAction("OnHandJoyCloseBtnClick")
		self.bindData.headJoyStick.luaValueChanged = self:CreateAction("OnHeadJoyStickMove")
		self.bindData.HandJoyStick.luaValueChanged = self:CreateAction("OnHandJoyStickMove")
	end

	self.bindData.UAVUpBtn.luaPress = self:CreateAction("OnUAVBtnUpPress")
	self.bindData.UAVUpBtn.luaRelease = self:CreateAction("OnUAVBtnUpRelease")
	self.bindData.UAVUpBtn.luaClick = self:CreateAction("OnUAVBtnUpClick")
	self.bindData.UAVDownBtn.luaPress = self:CreateAction("OnUAVBtnDownPress")
	self.bindData.UAVDownBtn.luaRelease = self:CreateAction("OnUAVBtnDownRelease")
	self.bindData.UAVDownBtn.luaClick = self:CreateAction("OnUAVBtnDownClick")
end

function M:OnMoreOperationClick()
	if not self.bindData.selfieMenuFold or self.bindData.selfieMenuFold == 0 then
		if self.isHideFocus then
			self:OnHideBtnClick()
		end

		self.bindData.selfieMenuFold = 1

		self.bindData.closeBtn:SetOnlyShowPCKeyTipInfo(false)
		self.bindData.bodyMoveBtn:SetOnlyShowPCKeyTipInfo(true)
		GuiMgr.Instance:SetShowJoystick(false, gPanelId.S_PHOTO_PANEL)

		local aniName = gCS.LuaUtils.IsNonMobileAdaptive() and "S_Vx_PhotoPanel_TabHideUnfoldopenPC" or "S_Vx_PhotoPanel_TabHideUnfoldopen"

		gCS.LuaUtils.PlayAnimationByName(self.bindData.tabAni, aniName)

		self.bindData.tabBanCtrl = 0

		if self.photoMode == PhotoMode.FullView then
			self.subTabType = SelfieSubTabType.filters

			self:BuildSelfieMenu()
			self.bindData.selfieTab:SelectItem(self.subTabType - 1)
			self:RefreshSelfieList(SelfieSubTabType.filters)
		else
			self.subTabType = SelfieSubTabType.action

			self:BuildSelfieMenu()
			self.bindData.selfieTab:SelectItem(self.subTabType - 1)
			self:RefreshSelfieList(SelfieSubTabType.action)
		end

		self.bindData.tabTitleText = SubTypeConfig[self.subTabType].name

		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, false)
	elseif self.bindData.selfieMenuFold == 1 then
		local aniName = gCS.LuaUtils.IsNonMobileAdaptive() and "S_Vx_PhotoPanel_TabHideUnfoldclosePC" or "S_Vx_PhotoPanel_TabHideUnfoldclose"

		gCS.LuaUtils.PlayAnimationByName(self.bindData.tabAni, aniName)
		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.selfieMenuFold = 0

			self.bindData.closeBtn:SetOnlyShowPCKeyTipInfo(true)
			self.bindData.bodyMoveBtn:SetOnlyShowPCKeyTipInfo(false)
			GuiMgr.Instance:SetShowJoystick(true, gPanelId.S_PHOTO_PANEL)

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				self.bindData.tabOutsideList:DeselectAll()
			end
		end, 0.2)
	end
end

function M:CancelHide()
	if self.isHideFocus == true then
		self:OnHideBtnClick()
	end
end

function M:OnHideBtnClick()
	if self.photoMode == PhotoMode.FullView and not self.templateConfig.canUIHide then
		return
	end

	if self.photoMode == PhotoMode.Selfie and not self.templateConfig.canSelfieUIHide then
		return
	end

	self.bindData.hideFocus = self.isHideFocus and 0 or 1
	self.bindData.selfieMenuFold = 0

	GuiMgr.Instance:SetShowJoystick(true, gPanelId.S_PHOTO_PANEL)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabOutsideList:DeselectAll()
	end

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, true)

	self.isHideFocus = not self.isHideFocus

	if self.isHideFocus then
		self.bindData.navigation:SetButtonInfoTipNameId(ShowUITextId, 1)
		self.bindData.navigation:ChangeButtonShowTipByActionId(1, false)
		self.bindData.navigation:ChangeButtonShowTipByActionId(21, false)
		self.bindData.hideBtn:SetPCKeyInfoTipNameId(ShowUITextId)
		self.SubGroup.PhotoCircularSliderStore:SetLocalScale(0, 0, 1)

		if self.templateConfig.canSelfie then
			self.bindData.switchBtn:SetShowTipTotally(false)
		end

		self.bindData.resetBtn:SetOnlyShowPCKeyTipInfo(false)
		self.bindData.closeBtn:SetShowTipTotally(false)
		self.bindData.handMoveBtn:SetShowTipTotally(false)
		self.bindData.headMoveBtn:SetShowTipTotally(false)
		self.bindData.bodyMoveBtn:SetShowTipTotally(false)
		self.bindData.albumBtn:SetOnlyShowPCKeyTipInfo(false)
		self.bindData.hideBtn:SetOnlyShowPCKeyTipInfo(false)
	else
		self.bindData.navigation:SetButtonInfoTipNameId(HideUITextId, 1)
		self.bindData.navigation:ChangeButtonShowTipByActionId(1, true)
		self.bindData.navigation:ChangeButtonShowTipByActionId(21, true)
		self.bindData.hideBtn:SetPCKeyInfoTipNameId(HideUITextId)
		self.SubGroup.PhotoCircularSliderStore:SetLocalScale(1, 1, 1)
		self.bindData.hideBtn:SetOnlyShowPCKeyTipInfo(true)

		if self.templateConfig.canSelfie then
			self.bindData.switchBtn:SetShowTipTotally(true)
		end

		self.bindData.resetBtn:SetOnlyShowPCKeyTipInfo(true)
		self.bindData.closeBtn:SetShowTipTotally(true)
		self.bindData.handMoveBtn:SetShowTipTotally(true)
		self.bindData.headMoveBtn:SetShowTipTotally(true)
		self.bindData.albumBtn:SetOnlyShowPCKeyTipInfo(true)
	end

	if self.photoMode == PhotoMode.Selfie then
		self.SubGroup.PhotoCircularSliderStore:SetLocalScale(0, 0, 1)
	end

	local gridVisible = self.watermarkCache.grid and true or false

	if self.isHideFocus then
		gridVisible = false
	end

	self.bindData.ninePalaces.gameObject:SetActive(gridVisible)

	local logoVisible = self.watermarkCache.logo and true or false
	logoVisible = not self.isHideFocus and logoVisible

	self.bindData.waterMarkLogo.gameObject:SetActive(logoVisible)

	local uidVisible = self.watermarkCache.uid and true or false
	uidVisible = not self.isHideFocus and uidVisible

	self.bindData.waterMarkUid.gameObject:SetActive(uidVisible)
end

function M:OnTakePhotoBtnClick()
	self:DoTakePhoto()
end

function M:OnResetBtnClick()
	if self.defaultExpression then
		self.selectedExpression = self.defaultExpression

		gTakePhotoUtils.ChangeExpression(self.selectedExpression)
	end

	self.SubGroup.PhotoCircularSliderStore:SetToStart()

	self.isFocus = true

	gTakePhotoUtils.SetPhotoIK(self.isFocus)

	self.selectedAction = nil

	gTakePhotoUtils.DoSelfieActionEvent(MuGenStates.Logic.GameplayEvent.PhotoSelfieAction, MuGenStates.Logic.GameplayEventParam1.SelfieAction)

	self.selectedFilter = -1

	gTakePhotoUtils.ClearPhotoFilters()

	self.selectedFrame = 1
	self.selectedFrameIconId = 0

	self.bindData.imageFrame:SetActive(false)
end

function M:OnSwitchBtnClick()
	if self.isSwitching then
		return
	end

	if self.isHideFocus then
		self:OnHideBtnClick()
	end

	self.bindData.photoAnim:Play("S_Vx_PhotoPanel_change")

	if self.photoMode == PhotoMode.FullView then
		if not self.templateConfig.canSelfie then
			return
		end

		self:HideTakePhoto(self.templateConfig.enterSelfieModeSec)

		self.photoMode = PhotoMode.Selfie

		self.SubGroup.PhotoCircularSliderStore:SetActive(false)
	elseif self.photoMode == PhotoMode.Selfie then
		self:HideTakePhoto(self.templateConfig.backPhotoModeSec)

		self.photoMode = PhotoMode.FullView

		self.SubGroup.PhotoCircularSliderStore:SetActive(true)
		self.SubGroup.PhotoCircularSliderStore:SetToStart(true)
	end

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, true)

	self.bindData.selfieMenuFold = 0

	self.bindData.closeBtn:SetOnlyShowPCKeyTipInfo(true)
	self.bindData.bodyMoveBtn:SetOnlyShowPCKeyTipInfo(false)
	GuiMgr.Instance:SetShowJoystick(true, gPanelId.S_PHOTO_PANEL)
	self:BuildSelfieMenu()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabOutsideList:DeselectAll()
	end

	self.bindData.handCtrl = 0
	self.bindData.headCtrl = 0

	gLuaTimeMgrUtils.Delay(function ()
		if gPanelManager:IsPanelShowing(self.m_Id) then
			self:SetCurrentPhotoMode()
		end
	end, self.bindData.photoAnim:GetClip("S_Vx_PhotoPanel_change").length / 2)
end

function M:OnCloseBtnClick()
	if self.bindData.selfieMenuFold == 1 then
		self:OnTabHideBtnClick()

		return
	end

	self:ClosePanel()
end

function M:OnTabHideBtnClick()
	local aniName = gCS.LuaUtils.IsNonMobileAdaptive() and "S_Vx_PhotoPanel_TabHideUnfoldclosePC" or "S_Vx_PhotoPanel_TabHideUnfoldclose"

	gCS.LuaUtils.PlayAnimationByName(self.bindData.tabAni, aniName)
	gLuaTimeMgrUtils.Delay(function ()
		self.bindData.selfieMenuFold = 0

		self.bindData.closeBtn:SetOnlyShowPCKeyTipInfo(true)
		self.bindData.bodyMoveBtn:SetOnlyShowPCKeyTipInfo(false)
		GuiMgr.Instance:SetShowJoystick(true, gPanelId.S_PHOTO_PANEL)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.tabOutsideList:DeselectAll()
		end

		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, true)
	end, 0.2)
end

function M:OnTabBtnClick(op)
	local nowType = (self.subTabType - op - 1) % #self.selfieTabList + 1

	self.bindData.selfieTab:SelectItem(nowType - 1)

	if self.selfieTabList[nowType].isBan then
		self.bindData.tabBanCtrl = 1
		self.subTabType = nowType
	else
		self.bindData.tabBanCtrl = 0

		self:RefreshSelfieList(nowType)
	end
end

function M:OnAlbumBtnClick()
	return
end

function M:OnHandMoveBtnClick()
	self.bindData.handCtrl = 1 - (self.bindData.handCtrl or 0)

	gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_PHONE_HAND_MOVE_EVENT, self.bindData.handCtrl == 1)
end

function M:OnHeadMoveBtnClick()
	self.bindData.headCtrl = 1 - (self.bindData.headCtrl or 0)

	gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_PHONE_HEAD_MOVE_EVENT, self.bindData.headCtrl == 1)
end

function M:OnHeadJoyCloseBtnClick()
	self:CloseExtraCtrl()
end

function M:OnHandJoyCloseBtnClick()
	self:CloseExtraCtrl()
end

function M:CloseExtraCtrl()
	self.bindData.headCtrl = 0
	self.bindData.handCtrl = 0

	gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_PHONE_HAND_MOVE_EVENT, false)
	gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_PHONE_HEAD_MOVE_EVENT, false)
end

function M:OnUAVBtnUpPress()
	self:PlayUAVBtnDownAnime()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.UAVRisePress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnUpPress send3CEvent UAVRisePress")
	end
end

function M:OnUAVBtnUpRelease()
	self:PlayUAVBtnUpAnime()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.UAVRiseRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnUpRelease send3CEvent UAVRiseRelease")
	end
end

function M:OnUAVBtnDownPress()
	self:PlayUAVBtnDownAnime()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.UAVFallPress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDownPress send3CEvent UAVFallPress")
	end
end

function M:OnUAVBtnDownRelease()
	self:PlayUAVBtnUpAnime()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.UAVFallRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDownRelease send3CEvent UAVFallRelease")
	end
end

function M:OnUAVBtnDownClick()
	return
end

local UAV_BTN_ANIME = {
	UP = "s_vx_HudSkillbtn_fanse_up",
	DOWN = "s_vx_HudSkillbtn_fanse"
}

function M:PlayUAVBtnDownAnime()
	local store = gStoreManager:GetStoreGroup("RobotFlyerControlsStore"):GetStoreByWidget(self.bindData.UAVUpBtn)

	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, UAV_BTN_ANIME.DOWN)
end

function M:PlayUAVBtnUpAnime()
	local store = gStoreManager:GetStoreGroup("RobotFlyerControlsStore"):GetStoreByWidget(self.bindData.UAVUpBtn)

	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, UAV_BTN_ANIME.UP)
end

function M:RegisterLists()
	self.bindData.selfieTab.luaSimpleRenderItem = self:CreateAction("OnRenderSelfieTab")
	self.bindData.selfieList.luaSimpleRenderItem = self:CreateAction("OnRenderSelfieList")

	function self.bindData.selfieList.luaLayoutSet()
		self.bindData.selfieList:SetNavSelectToSelect()
	end

	self.bindData.selfieList.onGetTIndex = self:CreateAction("OnGetTIndexSelfieList")
	self.bindData.selfieTab.luaSimpleClick = self:CreateAction("OnClickSelfieTab")
	self.bindData.selfieTab.luaSimpleInvalidClick = self:CreateAction("OnInvalidClickSelfieTab")
	self.bindData.selfieList.luaSimpleClick = self:CreateAction("OnClickSelfieList")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabOutsideList.luaSimpleRenderItem = self:CreateAction("OnRenderTabOutsideList")
		self.bindData.tabOutsideList.luaSimpleClick = self:CreateAction("OnClickTabOutsideList")
	end
end

function M:OnRenderSelfieTab(btn, index)
	local data = self.selfieTabList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("CommonShortTab_photo"):GetStoreById(id)

	if store and data.iconId then
		store.iconId = data.iconId
		store.lock = btn.interactable and 0 or 1
	end
end

function M:OnClickSelfieTab(btn, index)
	local data = self.selfieTabList[index + 1]
	self.bindData.tabTitleText = data.name

	if data.isBan then
		self.bindData.tabBanCtrl = 1

		return
	else
		self.bindData.tabBanCtrl = 0

		self:RefreshSelfieList(data.type)
	end
end

function M:OnInvalidClickSelfieTab(btn, index)
	gDisplayMessageMgr:ShowMessage(65400907)
end

function M:OnGetTIndexSelfieList(index)
	return self:FilterSelfieListData(index).tIndex
end

function M:FilterSelfieListData(index)
	if self.subTabType == SelfieSubTabType.action then
		return self.actionInfos[index + 1]
	elseif self.subTabType == SelfieSubTabType.expression then
		return self.expressionInfos[index + 1]
	elseif self.subTabType == SelfieSubTabType.photoFrames then
		return self.photoFrameInfos[index + 1]
	elseif self.subTabType == SelfieSubTabType.watermark then
		return self.watermarkInfos[index + 1]
	elseif self.subTabType == SelfieSubTabType.filters then
		return self.filtersInfos[index + 1]
	elseif self.subTabType == SelfieSubTabType.environment then
		return self.environmentInfos[index + 1]
	end
end

function M:OnRenderSelfieList(btn, index)
	local data = self:FilterSelfieListData(index)

	if self.subTabType == SelfieSubTabType.environment then
		local id = btn.gameObject:GetInstanceID()
		local store = gStoreManager:GetStoreGroup("PhotoWeatherTemplate"):GetStoreById(id)

		if store then
			self:RefreshEnvironmentTab(store)
		end

		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		if self.subTabType <= 2 then
			store.listIcon = data.Icon
		else
			store:EnableImmediatelyCommit(true)

			if self.subTabType == SelfieSubTabType.photoFrames then
				store.frameImg = data.iconId
			elseif self.subTabType == SelfieSubTabType.watermark then
				self.watermarkCache[data.name] = btn.isSelected
				store.watermarkText = data.description
			elseif self.subTabType == SelfieSubTabType.filters then
				store.frameImg = data.iconId
			end
		end
	end
end

function M:OnClickSelfieList(btn, index)
	local data = self:FilterSelfieListData(index)

	if self.subTabType ~= data.sType then
		return
	end

	if self.subTabType == SelfieSubTabType.action then
		if self.selectedAction == data.aId then
			return
		end

		self.selectedAction = data.aId

		gTakePhotoUtils.DoSelfieActionEvent(MuGenStates.Logic.GameplayEvent.PhotoSelfieAction, data.event)
	elseif self.subTabType == SelfieSubTabType.expression then
		if self.selectedExpression == data.ExpressionId then
			return
		end

		self.selectedExpression = data.ExpressionId or self.defaultExpression

		gTakePhotoUtils.ChangeExpression(self.selectedExpression)
	elseif self.subTabType == SelfieSubTabType.character then
		if self.selectedSpirit == data.RoleId or not data.RoleId then
			return
		end

		self.selectedExpression = nil
		self.selectedAction = nil
		self.selectedSpirit = data.RoleId

		gTakePhotoUtils.SwitchPlayerSpirit(self.selectedSpirit, function ()
			gTakePhotoUtils.PlayTakePhotoCamera(self.photoMode, self.photoTemplate, 1)
		end)
	elseif self.subTabType == SelfieSubTabType.photoFrames then
		if data.name == "defaultFrame" then
			self.bindData.imageFrame:SetActive(false)

			self.selectedFrameIconId = 0
		else
			self.bindData.imageFrame:SetActive(true)

			self.bindData.frameIconId = data.frameIconId
			self.selectedFrameIconId = data.frameIconId
		end

		self.selectedFrame = data.index
	elseif self.subTabType == SelfieSubTabType.watermark then
		self.watermarkCache[data.name] = btn.isSelected

		if data.name == "logo" then
			self.bindData.waterMarkLogo:SetActive(btn.isSelected)
		elseif data.name == "uid" then
			self.bindData.waterMarkUid:SetActive(btn.isSelected)
		elseif data.name == "grid" then
			self.bindData.ninePalaces.gameObject:SetActive(btn.isSelected)
		elseif data.name == "focus" then
			self.isFocus = btn.isSelected

			gTakePhotoUtils.SetPhotoIK(self.isFocus)
		end
	elseif self.subTabType == SelfieSubTabType.filters then
		if data.isDefault then
			gTakePhotoUtils.ClearPhotoFilters()
		else
			gTakePhotoUtils.SetPhotoFilters(data.filterId)
		end

		self.selectedFilter = data.filterId
	end
end

function M:RefreshEnvironmentTab(store)
	store.canChangeCtrl = 1
	store.timeSlider.luaValueChanged = self:CreateAction("OnTimeSliderChange")
end

function M:OnTimeSliderChange(value)
	return
end

function M:OnRenderTabOutsideList(btn, index)
	local data = self.selfieTabList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("CommonShortTab_photo"):GetStoreById(id)

	if store and data.iconId then
		store.iconId = data.iconId
	end
end

function M:OnClickTabOutsideList(btn, index)
	local data = self.selfieTabList[index + 1]
	self.subTabType = data.type
	self.bindData.selfieMenuFold = 1

	self.bindData.closeBtn:SetOnlyShowPCKeyTipInfo(false)
	self.bindData.bodyMoveBtn:SetOnlyShowPCKeyTipInfo(true)
	GuiMgr.Instance:SetShowJoystick(false, gPanelId.S_PHOTO_PANEL)

	local aniName = gCS.LuaUtils.IsNonMobileAdaptive() and "S_Vx_PhotoPanel_TabHideUnfoldopenPC" or "S_Vx_PhotoPanel_TabHideUnfoldopen"

	gCS.LuaUtils.PlayAnimationByName(self.bindData.tabAni, aniName)

	self.bindData.tabTitleText = SubTypeConfig[self.subTabType].name

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, false)
	self:BuildSelfieMenu()
	self.bindData.selfieTab:SelectItem(self.subTabType - 1)

	if data.isBan then
		self.bindData.tabBanCtrl = 1

		return
	else
		self.bindData.tabBanCtrl = 0
	end

	self:RefreshSelfieList(self.subTabType)
end

function M:RegisterSlider()
	self.mouseScrollCallback = self:CreateAction("OnMouseScroll")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end

	self.bindData.FOVUpBtn.luaBeginLongPress = self:CreateActionWithArgs("OnFOVPress", {
		isEndPress = false,
		op = 1
	})
	self.bindData.FovDownBtn.luaBeginLongPress = self:CreateActionWithArgs("OnFOVPress", {
		isEndPress = false,
		op = -1
	})
	self.bindData.FOVUpBtn.luaEndLongPress = self:CreateActionWithArgs("OnFOVPress", {
		isEndPress = true,
		op = 1
	})
	self.bindData.FovDownBtn.luaEndLongPress = self:CreateActionWithArgs("OnFOVPress", {
		isEndPress = true,
		op = -1
	})
end

function M:OnFOVChange(times, ignoreSound)
	if not ignoreSound then
		gSoundMgr:PlaySoundByTid(70601122)
	end

	local fov = self.templateConfig.FOV
	local minFov = fov.minValue
	local maxFov = fov.maxValue
	local defaultFov = self.defaultFov
	local perFov = (maxFov - minFov) / 1.5

	gTakePhotoUtils.SetPhotoCameraFOV(maxFov - (times - 0.5) * perFov)
end

function M:OnFOVPress(args)
	if self.photoMode == PhotoMode.Selfie then
		return
	end

	if self.bindData.selfieMenuFold == 1 then
		return
	end

	local op = args.op

	if op == 1 then
		self.isLEndPress = args.isEndPress
	else
		self.isREndPress = args.isEndPress
	end

	local isEndPress = self.isLEndPress and self.isREndPress

	if not isEndPress then
		self.SubGroup.PhotoCircularSliderStore:SetPressCtrl(true)

		self.isFovBtnPressing = true

		if not self.isLEndPress and not self.isREndPress then
			if op > 0 then
				self.FovChangeType = 1
			else
				self.FovChangeType = -1
			end
		elseif self.isREndPress then
			self.FovChangeType = 1
		else
			self.FovChangeType = -1
		end
	else
		self.SubGroup.PhotoCircularSliderStore:SetPressCtrl(false)

		self.isFovBtnPressing = false
		self.FovChangeType = 0
	end
end

function M:OnMouseScroll(context)
	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() or self.photoMode == PhotoMode.Selfie or self.isSwitching or gTakePhotoUtils.PhotoTemplate.Default < self.photoTemplate and self.photoTemplate < gTakePhotoUtils.PhotoTemplate.RobDog then
		return
	end

	if self.bindData.selfieMenuFold == 1 then
		return
	end

	if context.performed then
		local zoom = context:ReadValueVector2().y
		self.scrollSignal = true

		if zoom > 0 then
			self:UpdateFovByMouseScroll(-1)
		else
			self:UpdateFovByMouseScroll(1)
		end
	end
end

function M:RegisterJoyStick()
	self.bindData.JoyStickCtrl.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
	self.bindData.JoyStickCtrlHead.luaGamePadInputChanged = self:CreateAction("OnRightStickHeadControl")
	self.bindData.JoyStickCtrlHand.luaGamePadInputChanged = self:CreateAction("OnRightStickHandControl")
end

function M:OnRightStickControl(context)
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

		gCameraUtils:DoRotateCameraByGamePad(5, 0, 0)
	end
end

function M:OnRightStickHeadControl(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HEAD_MOVE, true)
		gCS.LuaUtils.SetSelfieHeadMove(value.x, value.y)
	end

	if context.canceled then
		gCS.LuaUtils.SetSelfieHeadMove(0, 0)
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HEAD_MOVE, false)
	end
end

function M:OnRightStickHandControl(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HAND_MOVE, true)
		gCS.LuaUtils.SetSelfieHandMove(value.x, value.y)
	end

	if context.canceled then
		gCS.LuaUtils.SetSelfieHandMove(0, 0)
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HAND_MOVE, false)
	end
end

function M:UpdateGamepadCamera()
	if self.needUpdateCamera then
		gCameraUtils:DoRotateCameraByGamePad(5, self.rightStickValue.x, self.rightStickValue.y)
	end
end

function M:OnHeadJoyStickMove(x, y, size)
	if size ~= 0 then
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HEAD_MOVE, true)
		gCS.LuaUtils.SetSelfieHeadMove(x * size, y * size)
	else
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HEAD_MOVE, false)
	end
end

function M:OnHandJoyStickMove(x, y, size)
	if size ~= 0 then
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HAND_MOVE, true)
		gCS.LuaUtils.SetSelfieHandMove(x * size, y * size)
	else
		gMessageManager:SendMessage(gEventConstants.PHOTO_SELFIE_HAND_MOVE, false)
	end
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PHOTO_TASK_TARGET] = function (eventId, data)
			self.updateHudDataQueue[UpdateHudPriority.Task] = data

			self:UpdateHudTargetData()
		end,
		[gEventConstants.PHOTO_TASK_MULTI_TARGET] = function (eventId, data)
			self.updateHudDataQueue[UpdateHudPriority.MultipleTask] = data
		end,
		[gEventConstants.PHOTO_CUSTOM_TARGET] = function (eventId, data)
			if not CustomTargetType2Priority[data.Type] then
				return
			end

			self.updateHudDataQueue[CustomTargetType2Priority[data.Type]] = data
		end,
		[gEventConstants.HIT_UNIT] = function (eventId, data)
			data = data:ToTable()
			local hitPid = data.HitPid

			if hitPid == gCS.MyPlayerManager.PlayerUnit.Pid then
				self:ClosePanel()

				if gPanelManager:IsPanelShowing(gPanelId.S_HUD_TIPS) then
					gPanelManager:Close(gPanelId.S_HUD_TIPS)
				end

				gClientUtils.CloseMainPhonePanel()
			end
		end,
		[gEventConstants.MESSAGE_TAKEPHOTO2] = function ()
			self:OnTakePhotoSuccess()
		end,
		[gEventConstants.SELFIE_SWITCH_ROLE] = function ()
			return
		end,
		[gEventConstants.AFTER_SWITCH_SCENE] = function (eventId, switchType)
			if switchType ~= gSwitchSceneType.Reconnect then
				return
			end

			if not gPanelManager:IsPanelShowing(self.m_Id) then
				return
			end

			gTakePhotoUtils.PlayTakePhotoCamera(self.photoMode, self.photoTemplate, 1)
		end,
		[gEventConstants.BEFORE_SWITCH_SCENE] = function (eventId, switchType)
			if switchType ~= gSwitchSceneType.Reconnect then
				self:ClosePanel()
			end
		end,
		[gEventConstants.CLOSE_PHOTO_PANEL] = function (eventId)
			self:ClosePanel()
		end,
		[gEventConstants.CHANGE_SELFIE_COMPOSITION] = function (eventId, postureSignal)
			local postureSignals = PhotoConfig.SelfiePostureSignal
			local beforeSignal = postureSignals[self.defaultSelfiePosture]
			self.defaultSelfiePosture = postureSignal
			local afterSignal = postureSignals[self.defaultSelfiePosture]

			gTakePhotoUtils.DoActionWhenSwitchComposition(beforeSignal, afterSignal)
		end
	}
end

function M:OnTakePhotoSuccess()
	if self.nowFocusTaskId and table.count(gLuaUIMgr.takePhotoFocusUnit[self.nowFocusTaskId]) > 0 and self.taskTargetMatch then
		gMessageManager:SendMessage(gEventConstants.TAKE_PHOTO, {
			TaskId = self.nowFocusTaskId
		})
	end
end

function M:UpdateHudTargetData()
	if self.isSwitching then
		return
	end

	if self.updateHudDataQueue[UpdateHudPriority.MultipleTask] then
		self:UpdateTaskMultiTarget(self.updateHudDataQueue[UpdateHudPriority.MultipleTask])
		self:ClearUpdateHudDataQueue()

		return
	end

	if self.updateHudDataQueue[UpdateHudPriority.Task] then
		self:UpdateTaskTarget(self.updateHudDataQueue[UpdateHudPriority.Task])
		self:ClearUpdateHudDataQueue()

		return
	end

	if self.updateHudDataQueue[UpdateHudPriority.AcquisitionNpc] then
		self:UpdateCustomTarget(self.updateHudDataQueue[UpdateHudPriority.AcquisitionNpc], PhotoCustomTargetType.Npc)
		self:ClearUpdateHudDataQueue()

		return
	end
end

function M:SetCurrentPhotoMode()
	if self.photoMode == PhotoMode.FullView then
		self.bindData.selfieSwitch = 0

		gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.NormalTakePhoto)
		gTakePhotoUtils.DoSelfieActionEvent(MuGenStates.Logic.GameplayEvent.PhotoSelfieExit)
	elseif self.photoMode == PhotoMode.Selfie then
		self.bindData.selfieSwitch = 1

		gCS.ClimbManager.SetLayerActionStateAndCheckTransition(gCS.MyPlayerManager.PlayerUnit, true, 42)
		MuGenStates.Logic.ABPVarManager.SetBool(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.PhoneSelfie, true)
		gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.SelfTakePhoto)
		gTakePhotoUtils.DoSelfieActionEvent(MuGenStates.Logic.GameplayEvent.PhotoFrontalSelfie)
		gTakePhotoUtils.DoSelfieActionEvent(MuGenStates.Logic.GameplayEvent.PhotoSelfieAction, MuGenStates.Logic.GameplayEventParam1.SelfieAction)

		self.defaultSelfiePosture = 1
		self.selectedAction = nil

		self:BuildSelfieExpressionData(true)
	end

	gMessageManager:SendMessage(gEventConstants.PHOTO_SWITCH_MODE, self.photoMode)
	gTakePhotoUtils.PlayTakePhotoCamera(self.photoMode, self.photoTemplate, 1)
end

function M:UpdateTaskTarget(data)
	if not data or not data.Pid or self.stopUpdateHud then
		return
	end

	self.photoTaskInfos = self.photoTaskInfos or {}
	self.photoTaskInfos[data.TaskId] = self.photoTaskInfos[data.TaskId] or {}
	local pid = data.Pid
	local taskInfoTbl = self.photoTaskInfos[data.TaskId][pid] or {}
	taskInfoTbl.Pid = pid

	if not taskInfoTbl.Finish then
		taskInfoTbl.Finish = data.Finish
		taskInfoTbl.MeetDis = data.MeetDis
		taskInfoTbl.InCam = data.InCam
		self.photoTaskInfos[data.TaskId][pid] = taskInfoTbl
	else
		taskInfoTbl.MeetDis = nil
		taskInfoTbl.InCam = nil
	end

	gLuaUIMgr.takePhotoFocusUnit[data.TaskId] = gLuaUIMgr.takePhotoFocusUnit[data.TaskId] or {}
	self.nowFocusTaskId = nil
	local IsSelfieTask = data.IsSelfieTask
	local isCurrentModeValid = not IsSelfieTask or IsSelfieTask and self.photoMode == PhotoMode.Selfie

	for taskId, taskInfoList in pairs(self.photoTaskInfos) do
		for _, taskInfo in pairs(taskInfoList) do
			if taskInfo.MeetDis and isCurrentModeValid then
				self.nowFocusTaskId = data.TaskId
				local taskPhotoState = gTakePhotoUtils.GetTaskPositionState(taskInfo.MeetDis, self.bindData.frameWidget, self.bindData.centerTrans)
				gLuaUIMgr.takePhotoFocusUnit[taskId][taskInfo.Pid] = taskPhotoState == PhotoTaskTargetState.IN_VIEW and data.InCam and taskInfo.MeetDis or nil
				self.targetStatesRecord[taskInfo.Pid] = self.targetStatesRecord[taskInfo.Pid] or {}

				if taskPhotoState == PhotoTaskTargetState.IN_VIEW and data.InCam then
					if self.targetStatesRecord[taskInfo.Pid].targetMatch ~= 0 then
						gSoundMgr:PlaySoundByTid(15001390)
						gCS.LuaUtils.PlayAnimationByName(self.bindData.taskAni, "S_Vx_PhotoPanel_TaskNodeOpen")
					end

					self.bindData.targetMatch = 0
					self.targetStatesRecord[taskInfo.Pid].targetMatch = 0
				elseif taskPhotoState == PhotoTaskTargetState.OUT_VIEW and data.InCam then
					if self.targetStatesRecord[taskInfo.Pid].targetMatch ~= 1 then
						gSoundMgr:PlaySoundByTid(15001391)
						gCS.LuaUtils.PlayAnimationByName(self.bindData.taskAni, "S_Vx_PhotoPanel_TaskNodeRtoG")
					end

					self.targetStatesRecord[taskInfo.Pid].targetMatch = 1
					self.bindData.targetMatch = 1
				elseif taskPhotoState == PhotoTaskTargetState.OUT_SCREEN or not data.InCam then
					self.targetStatesRecord[taskInfo.Pid].targetMatch = 1
					self.bindData.targetMatch = 1
				end

				if taskPhotoState and taskPhotoState ~= PhotoTaskTargetState.OUT_SCREEN and data.InCam then
					self.bindData.taskState = 1
					self.bindData.gpsCtrl = 0
				else
					if not gClientUtils.IsNil(self.templates[taskInfo.Pid]) then
						self.templates[taskInfo.Pid].gameObject:SetActive(false)
						table.insert(self.templatePool, self.templates[taskInfo.Pid])

						self.templates[taskInfo.Pid] = nil
					end

					self.bindData.taskState = 1
					self.bindData.gpsCtrl = 1
				end

				self.targetTrans[taskInfo.Pid] = taskInfo.MeetDis
			else
				self.bindData.taskState = 0
				gLuaUIMgr.takePhotoFocusUnit[taskId][taskInfo.Pid] = nil
			end
		end
	end

	self.taskTargetMatch = self.bindData.targetMatch == 0
	local disableAutoClose = data.DisableAutoClose

	if data.Finish then
		if disableAutoClose then
			local scale = SGUI.UIConfig.instance:GetCurrentAdaptationScale()
			self.rootGo.transform.localScale = Vector3.New(scale, scale, 1)

			return
		end

		gLuaUIMgr.takePhotoFocusUnit[data.TaskId][pid] = nil
		self.targetStatesRecord[pid] = nil

		self:ClosePanel()
		gClientUtils.CloseMainPhonePanel()
	end
end

function M:UpdateTaskMultiTarget(data)
	return
end

function M:UpdateCustomTarget(data, targetType)
	if not data or not data.MeetDis or not next(data.MeetDis) or self.stopUpdateHud then
		return
	end

	local units = data.MeetDis
	local isAllMatch = true
	local isAllOutScreen = true

	for pid, unit in pairs(units) do
		if unit then
			local photoState = gTakePhotoUtils.GetTaskUnitState(unit, self.bindData.frameWidget, self.bindData.centerTrans)
			self.targetStatesRecord[pid] = self.targetStatesRecord[pid] or {}

			if photoState == PhotoTaskTargetState.IN_VIEW then
				if self.targetStatesRecord[pid].targetMatch ~= 0 then
					gCS.LuaUtils.PlayAnimationByName(self.bindData.taskAni, "S_Vx_PhotoPanel_TaskNodeOpen")
				end

				isAllOutScreen = false
				self.targetStatesRecord[pid].targetMatch = 0
				self.customTargetResultSet[targetType] = self.customTargetResultSet[targetType] or {}
				self.customTargetResultSet[targetType][pid] = true
			else
				self.targetStatesRecord[pid].targetMatch = 2

				if self.customTargetResultSet[targetType] then
					self.customTargetResultSet[targetType][pid] = false
				end

				isAllOutScreen = false
				isAllMatch = false
			end

			if photoState and photoState == PhotoTaskTargetState.IN_VIEW then
				local target = unit.ModelSlot.upbodySlot
				self.customTargetTrans[targetType] = self.customTargetTrans[targetType] or {}
				self.customTargetTrans[targetType][pid] = target
			else
				if self.customTargetTrans[targetType] then
					self.customTargetTrans[targetType][pid] = nil
				end

				if not gClientUtils.IsNil(self.templates[pid]) then
					self.templates[pid].gameObject:SetActive(false)
					table.insert(self.templatePool, self.templates[pid])

					self.templates[pid] = nil
				end
			end
		end
	end

	self:HandleCustomDisplayRule(targetType, isAllMatch, isAllOutScreen)
end

function M:UpdateTargetHud()
	if not next(self.targetTrans) and not next(self.customTargetTrans) then
		return
	end

	local priorityBreak = false

	for pid, trans in pairs(self.targetTrans) do
		if trans then
			priorityBreak = true

			self:UpdateTargetHudOnce(pid, trans, "task")
		end
	end

	if priorityBreak then
		return
	end

	for targetType, targetTrans in pairs(self.customTargetTrans) do
		for pid, trans in pairs(targetTrans) do
			if trans then
				self:UpdateTargetHudOnce(pid, trans, CustomTargetType2TemplateType[targetType])
			end
		end
	end
end

local tmpVec = Vector2.zero

function M:UpdateTargetHudOnce(pid, trans, type)
	if self.bindData.gpsCtrl == 0 then
		local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(trans, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

		tmpVec:Set(x, y)
		self:TryGenTargetTemplate(pid, type)

		local store = self:GetStoreById(self.templates[pid].gameObject:GetInstanceID())

		if store.targetMatch ~= 0 and self.targetStatesRecord[pid].targetMatch == 0 then
			gCS.LuaUtils.PlayAnimationByName(store.targetAni, "S_Vx_PhotoPanel_TaskNodeSuccessOpen")
		end

		store.targetMatch = self.targetStatesRecord[pid].targetMatch or 2
		self.templates[pid].localPosition = gCS.LuaUtils.ScreenPointUI(self.bindData.centerTrans, tmpVec)
	else
		local clamped, uiWorldPos, arrowEulerZ = MainViewUtils.TryEllipseClampWorldPos2UIWorldPos(trans, self.bindData.ellipseRT, nil, nil)
		self.bindData.gpsRT.position = uiWorldPos
		local eulerZ = clamped and arrowEulerZ - 90 or 0

		self.bindData.arrowRT:SetLocalEulerAnglesZ(eulerZ)
	end
end

function M:TryGenTargetTemplate(pid, type)
	if gClientUtils.IsNil(self.templates[pid]) then
		if next(self.templatePool) then
			self.templates[pid] = table.remove(self.templatePool)

			self.templates[pid].gameObject:SetActive(true)
		else
			local template = UnityEngine.GameObject.Instantiate(self.bindData.targetTrans.gameObject)

			template:SetActive(true)
			template:SetParent(self.bindData.centerTrans)
			template:SetLocalScale(1, 1, 1)

			self.templates[pid] = template:GetComponent(typeof(UnityEngine.RectTransform))
		end

		local store = self:GetStoreById(self.templates[pid].gameObject:GetInstanceID())

		for _, cfg in ipairs(PhotoConfig.ShootingTargetIcon) do
			if cfg.name == type then
				store.activeTargetIcon = cfg.activeIconId
				store.inactiveTargetIcon = cfg.inactiveIconId

				break
			end
		end
	end
end

local INTERVAL = 0.1

function M:UpdateFovByJoyStick()
	if not self.isFovBtnPressing then
		return
	end

	self.FovChangeTimeSignal = self.FovChangeTimeSignal + Time.deltaTime

	if self.FovChangeTimeSignal < INTERVAL then
		return
	end

	self.FovChangeTimeSignal = 0

	self.SubGroup.PhotoCircularSliderStore:DoOneStepRolling(self.FovChangeType)
end

function M:UpdateFovByMouseScroll(op)
	if not self.bActive then
		return
	end

	self.SubGroup.PhotoCircularSliderStore:DoOneStepRolling(op)
end

local SCROLLINTERVAL = 0.5

function M:UpdateScrollStyle()
	if self.scrollSignal then
		self.scrollSignalInterval = 0
		self.scrollSignal = false
	end

	if self.scrollSignalInterval < 0 then
		return
	end

	self.scrollSignalInterval = self.scrollSignalInterval + Time.deltaTime

	if SCROLLINTERVAL < self.scrollSignalInterval then
		self.SubGroup.PhotoCircularSliderStore:SetPressCtrl(false)

		self.scrollSignalInterval = -1

		return
	end

	self.SubGroup.PhotoCircularSliderStore:SetPressCtrl(true)
end

function M:DoTakePhoto()
	self.bindData.photoVx:Play("S_Vx_PhotoPanel_Light")

	self.stopUpdateHud = true
	local inTask = self.nowFocusTaskId and table.count(gLuaUIMgr.takePhotoFocusUnit[self.nowFocusTaskId]) > 0 and self.taskTargetMatch

	if not inTask then
		gMessageManager:SendMessage(gEventConstants.MESSAGE_CLEAR)
		gUIUtils:SetUITouchEnable(false)

		if gPanelManager:IsPanelShowing(gPanelId.S_HUD_TIPS) then
			gPanelManager:Close(gPanelId.S_HUD_TIPS)
		end

		GuiMgr.Instance:SetShowJoystick(false, gPanelId.S_PHOTO_PANEL)
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, false)
	end

	local customPhotoTargetType = nil

	for tType, set in pairs(self.customTargetResultSet) do
		if next(set) then
			customPhotoTargetType = tType

			break
		end
	end

	local delayTime = 0.15
	self.EndDelay = gLuaTimeMgrUtils.Delay(function ()
		if inTask then
			if gClientUtils.NotNil(self.rootGo) then
				self.rootGo.transform.localScale = Vector3.zero
			end

			LX6.Utils.PhotoUtils.TakePhoto()

			self.stopUpdateHud = false

			return
		end

		if gCS.LuaUtils.IsNull(self.rootGo) then
			return
		end

		gUIUtils:SetUITouchEnable(true)
		gPanelManager:CheckShow(gPanelId.S_PHOTO_POST_PROCESS_PANEL, {
			ShowTask = false,
			watermarkInfo = self.watermarkCache,
			selectedFrame = self.selectedFrame,
			selectedFrameIconId = self.selectedFrameIconId,
			TaskId = self.nowFocusTaskId,
			IsSelfIeMode = self.photoMode == PhotoMode.Selfie,
			customTargetType = customPhotoTargetType,
			customTargetData = table.clone(self.customTargetResultSet[customPhotoTargetType]),
			ShareCallback = function (result)
				if not result then
					local hideControl = self.bindData.selfieMenuFold ~= 1

					GuiMgr.Instance:SetShowJoystick(hideControl, gPanelId.S_PHOTO_PANEL)
					gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, hideControl)
					gTakePhotoUtils.HideUid(true)

					self.stopUpdateHud = false
				end
			end
		})

		self.EndDelay = nil
	end, delayTime)

	gLuaTimeMgrUtils.Delay(function ()
		gSoundMgr:PlayCharacterCombineExternalVoice(SoundConfig.Char_CAM)
	end, 1)
end

function M:HideTakePhoto(time)
	for _, btn in ipairs(self.needHideBtn) do
		btn:SetActive(false)
		self.bindData.resetBtn:SetActive(false)
		self.bindData.handMoveBtn:SetActive(false)
		self.bindData.headMoveBtn:SetActive(false)
	end

	self.isSwitching = true
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false

	gLuaTimeMgrUtils.Delay(function ()
		if gPanelManager:IsPanelShowing(gPanelId.S_PHOTO_PANEL) then
			for _, btn in ipairs(self.needHideBtn) do
				btn:SetActive(true)

				if self.photoMode == PhotoMode.Selfie then
					self.bindData.resetBtn:SetActive(true)
					self.bindData.handMoveBtn:SetActive(true)
					self.bindData.headMoveBtn:SetActive(true)
				end
			end
		end

		self.isSwitching = false
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end, time)
end

function M:HandleSpPhotoTemplate()
	local template = gTakePhotoUtils.OncePhotoTemplate
	self.bindData.summonCtrl = 0

	if template == gTakePhotoUtils.PhotoTemplate.Climb then
		self.bindData.switchBtn:SetActive(false)
		self.SubGroup.PhotoCircularSliderStore:SetActive(false)
	elseif template == gTakePhotoUtils.PhotoTemplate.RobDog then
		self.bindData.summonCtrl = 2
	elseif template == gTakePhotoUtils.PhotoTemplate.UAV then
		self.bindData.summonCtrl = 1
	elseif template == gTakePhotoUtils.PhotoTemplate.Spider then
		self.bindData.summonCtrl = 3
	end

	if not self.templateConfig.canSelfie then
		self.bindData.switchBtn:SetActive(false)
	end
end

function M:HandleCustomDisplayRule(targetType, isAllMatch, isAllOutScreen)
	if targetType == gTakePhotoUtils.PhotoCustomTargetType.Npc then
		if self.customTargetTrans[targetType] then
			for pid, _ in pairs(self.customTargetTrans[targetType]) do
				local hasSingle, hasGroup = gSpiritAcquisitionManager:GetNpcPhotoState(pid)

				if self.photoMode == PhotoMode.FullView and hasSingle then
					self.customTargetTrans[targetType][pid] = nil
					self.customTargetResultSet[targetType][pid] = nil
					self.targetStatesRecord[pid].targetMatch = 2
					isAllMatch = false
				end

				if self.photoMode == PhotoMode.Selfie and hasGroup then
					self.customTargetTrans[targetType][pid] = nil
					self.customTargetResultSet[targetType][pid] = nil
					self.targetStatesRecord[pid].targetMatch = 2
					isAllMatch = false
				end
			end
		end

		if isAllMatch then
			if self.bindData.taskState ~= 1 then
				gSoundMgr:PlaySoundByTid(15001390)
			end

			self.bindData.taskState = 1
			self.bindData.targetMatch = 0
		else
			self.bindData.taskState = 0
			self.bindData.targetMatch = 2
		end
	end
end

function M:UpdateSelfieBlend()
	if self.photoMode ~= PhotoMode.Selfie then
		return
	end

	local pitch = gCS.CameraDataMgr.Instance.MainCamera.transform.eulerAngles.x

	if pitch > 90 then
		pitch = pitch - 360
	end

	pitch = Mathf.Clamp(pitch, self.minBlendPitch, self.maxBlendPitch)
	local blend = (pitch - self.minBlendPitch) / (self.maxBlendPitch - self.minBlendPitch)

	gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, blend, 2)
end

function M:ClosePanel()
	self.isClosing = true

	self.bindData.photoAnim:Play("S_Vx_PhotoPanel_close")
	gLuaTimeMgrUtils.Delay(function ()
		gTakePhotoUtils.ClearPhotoFilters()
		gTakePhotoUtils.PlayTakePhotoCamera(PhotoMode.None, self.photoTemplate, 1)
		gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.Clear)
		gCS.ClimbManager.DoClearLayerActionState(42, -1)
		gCS.CameraDataMgr.cinemachineManager:SetFov(50, 0, 0, false)
	end, self.bindData.photoAnim:GetClip("S_Vx_PhotoPanel_close").length / 2)
	gLuaTimeMgrUtils.Delay(function ()
		if gPanelManager:IsPanelShowing(self.m_Id) then
			gPanelManager:Close(self.m_Id)
		end
	end, self.bindData.photoAnim:GetClip("S_Vx_PhotoPanel_close").length)
end

function M:CacheConfig(config)
	self.templateConfig.FOV = config.FOV
	self.defaultFov = config.FOV.defaultValue
	self.templateConfig.canUIHide = config.canUIHide
	self.templateConfig.canSelfie = config.canSelfie
	self.templateConfig.canSelfieUIHide = config.canSelfieUIHide
	self.templateConfig.canFocus = config.canFocus
	self.templateConfig.canSwitchMember = config.canSwitchMember
	self.templateConfig.enterPhotoModeSec = config.enterPhotoModeSec
	self.templateConfig.enterSelfieModeSec = config.enterSelfieModeSec
	self.templateConfig.backPhotoModeSec = config.backPhotoModeSec
	self.templateConfig.directlyEnterSelfieModeSec = config.directlyEnterSelfieModeSec
end

function M:BuildSelfieMenu()
	self.selfieTabList = {}

	for i, setting in ipairs(SubTypeConfig) do
		local data = {
			name = setting.name,
			type = i,
			iconId = setting.iconId,
			isBan = self.photoMode == PhotoMode.FullView and i < 3
		}

		table.insert(self.selfieTabList, data)
	end

	self.bindData.selfieTab:SetSimpleList(#self.selfieTabList)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabOutsideList:SetSimpleList(#self.selfieTabList)
	end
end

function M:BuildSelfieSpiritList()
	return
end

function M:BuildSelfieActionList()
	self.actionInfos = {
		selectedSpirit = self.selectedSpirit
	}

	for i = 0, PhotoSpiritSelfieParamConfig.count - 1 do
		local params = PhotoSpiritSelfieParamConfig.LoadAt(i)
		local actions = params["SelfieAction" .. self.photoTemplate]

		if params.FightSpirit == self.selectedSpirit then
			if self.selectedAction == nil then
				self.selectedAction = actions[1]
			end

			for j = 1, #actions do
				local action = {}
				local config = PhotoSelfieActionConfig.GetConfig(actions[j])
				action.Icon = config.SIconId
				action.selected = self.selectedAction == actions[j]
				action.tIndex = 1
				action.event = config.actionType
				action.aId = config.Id
				action.sType = SelfieSubTabType.action

				table.insert(self.actionInfos, action)
			end

			break
		end
	end

	self.bindData.selfieList.groupType = 1
end

function M:BuildSelfieExpressionData(isInit)
	self.expressionInfos = {
		selectedSpirit = self.selectedSpirit
	}

	for i = 0, PhotoSpiritSelfieParamConfig.count - 1 do
		local params = PhotoSpiritSelfieParamConfig.LoadAt(i)
		local exps = params["Expression" .. self.photoTemplate]

		if params.FightSpirit == self.selectedSpirit then
			if self.selectedExpression == nil or isInit then
				self.selectedExpression = exps[1].ExpressionId
				self.defaultExpression = exps[1].ExpressionId

				gTakePhotoUtils.ChangeExpression(self.selectedExpression)
			end

			for j = 1, #exps do
				local exp = {
					Icon = exps[j].ImageId,
					FuncName = "",
					ExpressionId = exps[j].ExpressionId,
					selected = self.selectedExpression == exps[j].ExpressionId,
					tIndex = 2,
					sType = SelfieSubTabType.expression
				}

				table.insert(self.expressionInfos, exp)
			end

			break
		end
	end
end

function M:BuildSelfieExpressionList()
	self:BuildSelfieExpressionData()

	self.bindData.selfieList.groupType = 1
end

function M:BuildPhotoFrameList()
	self.photoFrameInfos = {}
	local configs = PhotoConfig.PhotoFramesSetting

	for i, config in ipairs(configs) do
		local data = {
			iconId = config.iconId,
			frameIconId = config.frameIconId,
			name = config.name,
			index = i,
			selected = self.selectedFrame == i,
			tIndex = 3,
			photoWidth = config.photoWidth,
			photoHeight = config.photoHeight,
			photoAspect = config.photoAspect,
			sType = SelfieSubTabType.photoFrames
		}

		table.insert(self.photoFrameInfos, data)
	end

	self.bindData.selfieList.groupType = 1
end

function M:BuildWatermarkList()
	self.watermarkInfos = {}
	local configs = PhotoConfig.WatermarkSetting

	for _, config in ipairs(configs) do
		local data = {
			name = config.name,
			tIndex = 4,
			description = config.description,
			selected = self.watermarkCache[config.name] or config.settingDefault ~= 0,
			sType = SelfieSubTabType.watermark
		}

		table.insert(self.watermarkInfos, data)
	end

	self.bindData.selfieList.groupType = 2
end

function M:BuildFiltersList()
	self.filtersInfos = {}
	local configs = PhotoFiltersConfig
	local data = {
		tIndex = 3,
		iconId = PhotoConfig.EmptyFilterIcon,
		isDefault = true,
		selected = self.selectedFilter == -1,
		filterId = -1,
		sType = SelfieSubTabType.filters
	}

	table.insert(self.filtersInfos, data)

	for i = 0, configs.count - 1 do
		local cfg = configs.LoadAt(i)
		local data = {
			tIndex = 3,
			iconId = FilterConfig.GetConfig(cfg.FilterId).Icon,
			isDefault = false,
			filterId = cfg.FilterId,
			selected = self.selectedFilter == cfg.FilterId,
			sType = SelfieSubTabType.filters
		}

		table.insert(self.filtersInfos, data)
	end

	self.bindData.selfieList.groupType = 1
end

function M:BuildEnvironment()
	local data = {
		tIndex = 5,
		sType = SelfieSubTabType.environment
	}
	self.environmentInfos = {}

	table.insert(self.environmentInfos, data)
end

function M:RefreshSelfieList(tabType)
	self.subTabType = tabType

	if self.bindData.selfieList.enabled then
		self.bindData.selfieList:PlayStartOffsetAnim(0)
	end

	if tabType == SelfieSubTabType.action then
		self:BuildSelfieActionList()
		self.bindData.selfieList:SetSimpleList(#self.actionInfos)
		self:SetListSelected(self.actionInfos, self.bindData.selfieList)
	elseif tabType == SelfieSubTabType.expression then
		self:BuildSelfieExpressionList()
		self.bindData.selfieList:SetSimpleList(#self.expressionInfos)
		self:SetListSelected(self.expressionInfos, self.bindData.selfieList)
	elseif tabType == SelfieSubTabType.photoFrames then
		self:BuildPhotoFrameList()
		self.bindData.selfieList:SetSimpleList(#self.photoFrameInfos)
		self:SetListSelected(self.photoFrameInfos, self.bindData.selfieList)
	elseif tabType == SelfieSubTabType.watermark then
		self:BuildWatermarkList()
		self.bindData.selfieList:SetSimpleList(#self.watermarkInfos)
		self:SetListSelected(self.watermarkInfos, self.bindData.selfieList)
	elseif tabType == SelfieSubTabType.filters then
		self:BuildFiltersList()
		self.bindData.selfieList:SetSimpleList(#self.filtersInfos)
		self:SetListSelected(self.filtersInfos, self.bindData.selfieList)
	elseif tabType == SelfieSubTabType.environment then
		self:BuildEnvironment()
		self.bindData.selfieList:SetSimpleList(#self.environmentInfos)
		self:SetListSelected(self.environmentInfos, self.bindData.selfieList)
	end
end

function M:SetListSelected(datas, list)
	for i = 1, #datas do
		local index = i - 1

		if datas[i].selected then
			list:SetItemSelected(index, true)
		end
	end
end

function M:ClearUpdateHudDataQueue()
	for _, i in pairs(UpdateHudPriority) do
		self.updateHudDataQueue[i] = nil
	end
end
