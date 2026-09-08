-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineControlsStore.lua
-- Decompiled from: 01103_OnlineControlsStore.lua_9a591d2ff2e6.luajit

C_OnlineControlsStore = DefClass("C_OnlineControlsStore", C_OnlineControlsStore, C_StoreGroup)
GroupName2Class.OnlineControlsStore = C_OnlineControlsStore
local M = C_OnlineControlsStore
local ParkourStateConfig = LTConfig.ParkourStateConfig
local DragEventListener = SGUI.EventSystems.DragEventListener

M.DefineAllVariables = function(self)
	self.curCanRescueTarget = nil
	self.rescuingTarget = nil
	self.curMultiType = 0
	self.canUseShortChatWheel = false
	self.MAX_SLOT_COUNT = 8
	self.stopDelayTimer = nil
	self.pendingStopTarget = nil
	self.isStartTucao = false
	self.lastTucaoTime = 0
	self.tucaoContinuousTime = 0.5
	self.tucaoCount = 0
	self.phoneOpen = false
	self.ignorePinAndCirtleClick = false
	self.signalCircleHasDrag = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.pinBtnStateCtrlEnum = {
		["\\xebP;)\\xd1\\xb5D\\xadf\\xb9\\xb8"] = 2,
		["\\xca\\xd3\n.-\\xff"] = 1,
		["r+y^"] = 0
	}
	self.PinBtnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.CancelPinBtnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.FallDownCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showTestSuggestEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showWatchingBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.mapValidCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.teamValidCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.topLeftSelectCtrlEnum = {
		["N'|V"] = 1,
		["\\xa3iv"] = 0
	}
	self.showSwitchSystemCtrlEnum = {
		["R+y^"] = 0,
		["I*rL"] = 1
	}
	self.btnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.wordsCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.qteVxCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.pinBtnStateCtrlEnum = nil
	self.PinBtnHideCtrlEnum = nil
	self.CancelPinBtnHideCtrlEnum = nil
	self.FallDownCtrlEnum = nil
	self.showTestSuggestEnum = nil
	self.showWatchingBtnCtrlEnum = nil
	self.mapValidCtrlEnum = nil
	self.teamValidCtrlEnum = nil
	self.topLeftSelectCtrlEnum = nil
	self.showSwitchSystemCtrlEnum = nil
	self.btnHideCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.qteVxCtrlEnum = nil
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:UpdatePinBtnState(gLinkManager:GetCurMultiType())
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	self.rescueBtn = self.GetStoreByWidget(self, self.bindData.RescueBtn)

	self.RefreshRescueBtnState(self)
	self.RefreshRescueTipState(self)
	self.RefreshShortChatWheelBtnState(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
	self.CancelStopDebounce(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.showTestSuggest = gGameSwitch.EnableLinkTest and 1 or 0
	self.phoneOpen = gClientUtils.CheckMainPhoneIsShowing()

	self:OnWatchStateChange()
	self:RefreshShortChatWheelBtnState()
	self:RefreshPinBtnStateCtrl()
	self:SyncFallingDownState()
	self:RefreshTopLeftSwitch()
end

M.ShouldHideWatchBtn = function(self)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore:GetNowGameplayType() ~= gHUDGameplayType.InGameWatching then
		return true
	end

	if gVehicleGamePlayManager:IsCarRaceMode() then
		return true
	end

	if gPartyManager.isInParty then
		return true
	end

	if not gLinkManager.watchState then
		return true
	end

	return false
end

M.OnWatchStateChange = function(self)
	if self.ShouldHideWatchBtn(self) then
		self.bindData.showWatchingBtnCtrl = 0

		return
	end

	local OnGround = not gCoreHudUIManager.activePlayerStates[gParkourPlayerStateType.AIR]

	if not OnGround then
		self.bindData.showWatchingBtnCtrl = 1

		return
	end

	local clientStates = gMainMenuMgr:GetClientState()
	local visible = true
	local cfgIdx = gCS.LuaUtils.IsNonMobileAdaptive() and 1 or 2

	for _, key in pairs(clientStates) do
		local cfg = ParkourStateConfig.GetConfig(key)

		if cfg and cfg.Observe and #cfg.Observe > 2 then
			local observeCfg = cfg.Observe[cfgIdx]

			if not observeCfg.visible or observeCfg.visible ~= 0 then
				visible = false
			end
		end
	end

	self.bindData.showWatchingBtnCtrl = visible and 1 or 0
end

M.OnClose = function(self)
end

M.OnCameraUpdate = function(self)
	self.RefreshPinBtnStateCtrl(self)

	if self.curCanRescueTarget and self.curCanRescueTarget == 0 then
		self.UpdateRescueBtnState(self)
	end

	self.RefreshTucaoCount(self)
	self.RefreshTopLeftSwitch(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.FALLING_DOWN_STATE] = self.CreateAction(self, "OnPlayerFallingDownChanged"),
		[gEventConstants.REVIVE_TARGET_CHANGED] = self.CreateAction(self, "OnReviveTargetChanged"),
		[gEventConstants.RESCUER_START_RESCUE] = self.CreateAction(self, "OnRescuerStartRescue"),
		[gEventConstants.RESCUER_STOP_RESCUE] = self.CreateAction(self, "OnRescuerStopRescue"),
		[gEventConstants.RESCUE_STATE] = self.CreateAction(self, "OnRescueStateChanged"),
		[gEventConstants.ON_EVENT_STATE_CHANGE] = self.CreateAction(self, "EventStateChange"),
		[gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE] = self.CreateAction(self, "OnWatchStateChange"),
		[gEventConstants.ON_PLAYER_STATE_CHANGE] = self.CreateAction(self, "OnWatchStateChange"),
		[gEventConstants.PAOKU_STATE_CHANGE] = self.CreateAction(self, "OnWatchStateChange"),
		[gEventConstants.CAR_RACE_STATE_CHANGE] = self.CreateAction(self, "OnWatchStateChange"),
		[gEventConstants.LINK_ONLINE_SIGNAL_CIRCLE_STATE_CHANGE] = self.CreateAction(self, "RefreshShortChatWheelBtnState"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide"),
		[gEventConstants.MOBILE_ADAPTIVE_MODE_CHANGE] = self.CreateAction(self, "RefreshTopLeftSwitch")
	}
end

M.RegisterWidget = function(self)
	self.bindData.PinBtn.luaClick = self.CreateAction(self, self.OnClickPinBtn)
	self.bindData.CancelPinBtn.luaClick = self.CreateAction(self, self.OnClickCancelPinBtn)
	self.bindData.SignalCircleBtn.luaPress = self.CreateAction(self, self.OnBeginLongPressSignalCircleBtn)
	self.bindData.SignalCircleBtn.luaRelease = self.CreateAction(self, self.OnEndLongPressSignalCircleBtn)
	local signalCircleBtnDrag = DragEventListener.Get(self.bindData.SignalCircleBtn.gameObject)
	signalCircleBtnDrag.onBeginDrag = self.CreateAction(self, "OnSignalCircleBtnDragBegin")
	signalCircleBtnDrag.onDrag = self.CreateAction(self, "OnSignalCircleBtnDrag")
	signalCircleBtnDrag.onEndDrag = self.CreateAction(self, "OnSignalCircleBtnDragEnd")

	if self.bindData.pinAndCirtleBtn then
		self.bindData.pinAndCirtleBtn.luaClick = self.CreateAction(self, self.OnClickPinAndCirtleBtn)
		self.bindData.pinAndCirtleBtn.luaLongPress = self.CreateAction(self, self.OnBeginLongPressPinAndCirtleBtn)
		self.bindData.pinAndCirtleBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPressSignalCircleBtn)
		local pinAndCirtleBtnDrag = DragEventListener.Get(self.bindData.pinAndCirtleBtn.gameObject)
		pinAndCirtleBtnDrag.onBeginDrag = self.CreateAction(self, "OnSignalCircleBtnDragBegin")
		pinAndCirtleBtnDrag.onDrag = self.CreateAction(self, "OnSignalCircleBtnDrag")
		pinAndCirtleBtnDrag.onEndDrag = self.CreateAction(self, "OnSignalCircleBtnDragEnd")
	end

	self.bindData.GiveUpBtn.luaLongPress = self.CreateAction(self, self.OnClickGiveUpBtn)
	self.bindData.AssistBtn.luaClick = self.CreateAction(self, self.OnClickAssistBtn)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.RescueBtn.luaPress = self.CreateAction(self, self.OnPressRescueBtn)
		self.bindData.RescueBtn.luaRelease = self.CreateAction(self, self.OnReleaseRescueBtn)
	else
		self.bindData.RescueBtn.luaClick = self.CreateAction(self, self.OnClickRescueBtn)
	end

	self.bindData.watchBtn.luaClick = self.CreateAction(self, "OnWatchOnlinePlayer", gLinkManager)
	self.bindData.tuCaoBtn.luaClick = self.CreateAction(self, self.OnClickTucaoBtn)
	self.bindData.suggestBtn.luaClick = self.CreateAction(self, self.OnClickSuggestBtn)

	print_notice("czy test1", self.bindData.switchToMapBtn, self.bindData.switchToTeamBtn)

	if self.bindData.switchToMapBtn then
		self.bindData.switchToMapBtn.luaClick = self.CreateAction(self, self.OnClickSwitchToMapBtn)
		self.bindData.switchToMapBtn.luaInvalidClick = self.CreateAction(self, function ()
			print_notice("[TopLeftSwitch] Map luaInvalidClick 触发(射线到达按钮，但按钮不可交互)")
		end)
	end

	if self.bindData.switchToTeamBtn then
		self.bindData.switchToTeamBtn.luaClick = self.CreateAction(self, self.OnClickSwitchToTeamBtn)
		self.bindData.switchToTeamBtn.luaInvalidClick = self.CreateAction(self, function ()
			print_notice("[TopLeftSwitch] Team luaInvalidClick 触发(射线到达按钮，但按钮不可交互)")
		end)
	end
end

M.RefreshPinBtnStateCtrl = function(self)
	if not self.canUseShortChatWheel then
		self.bindData.pinBtnStateCtrl = self.pinBtnStateCtrlEnum.hide
	elseif gMapSubSystem_ChatMark:CheckCanCancelPin() then
		self.bindData.pinBtnStateCtrl = self.pinBtnStateCtrlEnum.showCancelPin
	else
		self.bindData.pinBtnStateCtrl = self.pinBtnStateCtrlEnum.showPin
	end
end

M.UpdatePinBtnState = function(self, curMultiType)
	self.curMultiType = curMultiType
	local gameTypeCfg = LTConfig.LinkMultiTypeConfig.GetConfig(self.curMultiType)

	if gameTypeCfg and next(gameTypeCfg.ShortChatWheel) and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.QuickCommunicate) then
		self.canUseShortChatWheel = true
		self.bindData.PinBtnHideCtrl = 0
		self.bindData.CancelPinBtnHideCtrl = 0

		self.RefreshShortChatWheelBtnState(self)
	else
		self.canUseShortChatWheel = false
		self.bindData.PinBtnHideCtrl = 1
		self.bindData.CancelPinBtnHideCtrl = 1

		self.RefreshShortChatWheelBtnState(self)
	end
end

M.OnClickPinBtn = function(self)
	if self.canUseShortChatWheel and self.bindData.PinBtnHideCtrl ~= 0 then
		gMapSubSystem_ChatMark:SetMyPin()
	end
end

M.OnClickCancelPinBtn = function(self)
	if self.canUseShortChatWheel and self.bindData.CancelPinBtnHideCtrl ~= 0 then
		gMapSubSystem_ChatMark:CancelMyPin()
	end
end

M.OnClickPinAndCirtleBtn = function(self)
	if self.ignorePinAndCirtleClick then
		self.ignorePinAndCirtleClick = false

		return
	end

	if not self.canUseShortChatWheel then
		return
	end

	if gMapSubSystem_ChatMark:CheckCanCancelPin() then
		gMapSubSystem_ChatMark:CancelMyPin()
	else
		gMapSubSystem_ChatMark:SetMyPin()
	end
end

M.OnEndLongPressPinBtn = function(self)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):CloseCircle()
end

M.OnBeginLongPressSignalCircleBtn = function(self)
	if self.CheckCanUseSignalCircle(self) then
		gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):OpenCircle(gCircleType.ONLINE_SIGNAL)
	end
end

M.OnBeginLongPressPinAndCirtleBtn = function(self)
	if self.CheckCanUseSignalCircle(self) then
		self.ignorePinAndCirtleClick = true

		gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):OpenCircle(gCircleType.ONLINE_SIGNAL)
	end
end

M.OnEndLongPressSignalCircleBtn = function(self)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):CloseCircle()

	self.ignorePinAndCirtleClick = false
end

M.OnSignalCircleBtnDragBegin = function(self, eventPointer)
	self.signalCircleHasDrag = false

	gStoreManager:GetStoreGroup("BackCircleOnlineSignalStore"):OnDragMoveStart(eventPointer)
end

M.OnSignalCircleBtnDrag = function(self, eventPointer)
	self.signalCircleHasDrag = true

	gStoreManager:GetStoreGroup("BackCircleOnlineSignalStore"):OnDragMove(eventPointer)
end

M.OnSignalCircleBtnDragEnd = function(self, eventPointer)
	local signalStore = gStoreManager:GetStoreGroup("BackCircleOnlineSignalStore")

	signalStore:OnDragMoveEnd(eventPointer)
end

M.CheckCanUseSignalCircle = function(self)
	if not self.canUseShortChatWheel then
		return false
	end

	local items = gLinkManager:GetCurShortChatWheelItems()

	if not items or not next(items) then
		return false
	end

	return true
end

M.RefreshShortChatWheelBtnState = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	local state = self:CheckCanUseSignalCircle() and not self.phoneOpen

	self.bindData.SignalCircleBtn:SetActive(state)

	if self.bindData.pinAndCirtleBtn then
		self.bindData.pinAndCirtleBtn:SetActive(state)
	end
end

M.GetTuCaoText = function(self)
	if not self.tuCaoText then
		local config = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.TuCaoText)
		self.tuCaoText = config and config.Text or "%d"
	end

	return self.tuCaoText
end

M.OnClickTucaoBtn = function(self)
	self.lastTucaoTime = gLogicTime.time
	self.isStartTucao = true
	self.tucaoCount = self.tucaoCount + 1
	self.bindData.tucaoCount = string.format(self.GetTuCaoText(self), self.tucaoCount)
end

M.RefreshTucaoCount = function(self)
	if self.isStartTucao and self.tucaoContinuousTime >= gLogicTime.time - self.lastTucaoTime then
		gClientToGameDelegate:AskPlayerComplain(self.tucaoCount)

		self.tucaoCount = 0
		self.bindData.tucaoCount = string.format(self:GetTuCaoText(), 1)
		self.isStartTucao = false
	end
end

M.OnClickSuggestBtn = function(self)
	gPanelManager:CheckShow(gPanelId.FEEDBACK_PANEL)
end

M.SyncFallingDownState = function(self)
	local reviveMgr = L50.L50App.L50Game.ReviveBtnMgr

	if not reviveMgr or not reviveMgr.IsLocalPlayerDowned then
		return
	end

	local targetPid = reviveMgr.GetCurrentTargetPid(reviveMgr)

	self.OnReviveTargetChanged(self, gEventConstants.REVIVE_TARGET_CHANGED, targetPid)

	local rescueTarget = reviveMgr.GetLocalRescueTargetPid(reviveMgr)

	if rescueTarget and not ulong.equals(rescueTarget, 0) then
		self.OnRescuerStartRescue(self, gEventConstants.RESCUER_START_RESCUE, rescueTarget)
	elseif self.isRescuing then
		self.OnRescuerStopRescue(self, gEventConstants.RESCUER_STOP_RESCUE, 0, false)
	end

	if reviveMgr.IsLocalPlayerBeingRescued(reviveMgr) then
		self.OnRescueStateChanged(self, gEventConstants.RESCUE_STATE, true)
	elseif reviveMgr.IsLocalPlayerDowned(reviveMgr) then
		self.OnPlayerFallingDownChanged(self, gEventConstants.FALLING_DOWN_STATE, true, 0, 0)
	else
		self.OnPlayerFallingDownChanged(self, gEventConstants.FALLING_DOWN_STATE, false, 0, 0)
	end
end

M.RefreshRescueBtnState = function(self)
	local hasTarget = self.curCanRescueTarget and not ulong.equals(self.curCanRescueTarget, 0)

	self.bindData.RescueBtn:SetActive(hasTarget or self.isRescuing)

	if self.rescueBtn then
		local hideOnRescue = gCS.LuaUtils.IsNonMobileAdaptive()
		self.rescueBtn.btnHideCtrl = self.isRescuing and hideOnRescue and self.btnHideCtrlEnum._true or self.btnHideCtrlEnum._false
	end
end

M.RefreshRescueTipState = function(self)
	if not self.bindData.RescueTip then
		return
	end

	local hasTarget = self.curCanRescueTarget and not ulong.equals(self.curCanRescueTarget, 0)

	self.bindData.RescueTip:SetActive(hasTarget and not self.isRescuing and gCS.LuaUtils.IsNonMobileAdaptive())
end

M.OnRescuerStartRescue = function(self, eventId, targetPid)
	self.isRescuing = true
	self.rescuingTarget = targetPid

	self.RefreshRescueBtnState(self)
	self.RefreshRescueTipState(self)
end

M.OnRescuerStopRescue = function(self, eventId, targetPid, isTargetExit)
	self.isRescuing = false
	self.rescuingTarget = nil

	self.CancelStopDebounce(self)

	if isTargetExit then
		self.curCanRescueTarget = 0
	end

	self.RefreshRescueBtnState(self)
	self.RefreshRescueTipState(self)
end

M.OnPlayerFallingDownChanged = function(self, eventId, isFallingDown, rescuerPlayerPid, rescuerUnitId)
	self.bindData.FallDownCtrl = isFallingDown and 1 or 0

	gPanelManager:SetActiveById(gPanelId.SYSTEM_CONTROLS, not isFallingDown)

	if isFallingDown ~= false and rescuerPlayerPid and not ulong.equals(rescuerPlayerPid, 0) then
		self.inviteePid = rescuerPlayerPid
		self.inviteeUnitID = rescuerUnitId
	end
end

M.OnRescueStateChanged = function(self, eventId, isBeingRescued)
	if isBeingRescued then
		self.bindData.FallDownCtrl = 0
	else
		self.bindData.FallDownCtrl = 1
	end
end

M.OnClickGiveUpBtn = function(self)
	slot1 = gClientToGameSceneDelegate

	slot1:AskExitFallingDownToDeath().Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnClickAssistBtn = function(self)
end

M.OnReviveTargetChanged = function(self, eventId, newTarget)
	if self.isRescuing and not ulong.equals(newTarget, 0) then
		return
	end

	self.curCanRescueTarget = newTarget

	self.RefreshRescueBtnState(self)
	self.RefreshRescueTipState(self)
end

M.UpdateRescueBtnState = function(self)
	local unit = gCS.SceneDataMgr.GetUnit(self.curCanRescueTarget)

	if not unit or unit.IsDead then
		self.curCanRescueTarget = 0

		return
	end

	local pos = unit.UpBodyPosition
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

	if self.bindData.RescueTip then
		z = self.bindData.RescueTip.rectTransform.localPosition.z
		local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.RescueTip.transform.parent, Vector3.New(x, y, 0))

		self.bindData.RescueTip.rectTransform:SetLocalPosition(UIPos.x, UIPos.y, z)
	end
end

M.OnPressRescueBtn = function(self)
	if not self.curCanRescueTarget or ulong.equals(self.curCanRescueTarget, 0) then
		return
	end

	if self.stopDelayTimer and self.pendingStopTarget and ulong.equals(self.pendingStopTarget, self.curCanRescueTarget) then
		self.CancelStopDebounce(self)

		return
	end

	if self.stopDelayTimer then
		self.DoConfirmedStop(self)
	end

	slot1 = gClientToGameSceneDelegate

	slot1:AskStartRescueFallingDownPlayer(self.curCanRescueTarget).Callback = function (errorId)
		if errorId and errorId == 0 then
			return
		end
	end
end

M.OnReleaseRescueBtn = function(self)
	local stopTarget = self.rescuingTarget or self.curCanRescueTarget

	if not stopTarget or ulong.equals(stopTarget, 0) then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.pendingStopTarget = stopTarget
		self.stopDelayTimer = Timer.New(function ()
			self:DoConfirmedStop()
		end, 0.1):Start()
	end
end

M.OnClickRescueBtn = function(self)
	if self.isRescuing then
		local stopTarget = self.rescuingTarget or self.curCanRescueTarget

		if stopTarget and not ulong.equals(stopTarget, 0) then
			slot2 = gClientToGameSceneDelegate

			slot2:AskStopRescueFallingDownPlayer(stopTarget).Callback = function (errorId)
			end
		end

		return
	end

	if not self.curCanRescueTarget or ulong.equals(self.curCanRescueTarget, 0) then
		return
	end

	slot1 = gClientToGameSceneDelegate

	slot1:AskStartRescueFallingDownPlayer(self.curCanRescueTarget).Callback = function (errorId)
		if errorId and errorId == 0 then
			return
		end
	end
end

M.CancelStopDebounce = function(self)
	if self.stopDelayTimer then
		self.stopDelayTimer:Stop()

		self.stopDelayTimer = nil
	end

	self.pendingStopTarget = nil
end

M.DoConfirmedStop = function(self)
	local target = self.pendingStopTarget

	self:CancelStopDebounce()

	local downPlayerUnit = gCS.SceneDataMgr.GetUnit(target)

	if not gCS.UnitStateMgr:HasState(downPlayerUnit, LTConfig.UnitStateConfig.Savable) then
		return
	end

	if target and not ulong.equals(target, 0) then
		slot3 = gClientToGameSceneDelegate

		slot3:AskStopRescueFallingDownPlayer(target).Callback = function (errorId)
		end
	end
end

M.EventStateChange = function(self, _, data)
end

M.OnPhoneAppShow = function(self)
	self.phoneOpen = true

	if self.STATE_OnShowOnce then
		self.RefreshShortChatWheelBtnState(self)
	end
end

M.OnPhoneAppHide = function(self)
	self.phoneOpen = false

	if self.STATE_OnShowOnce then
		self.RefreshShortChatWheelBtnState(self)
	end
end

M.RefreshTopLeftSwitch = function(self)
	if not self.bindData.switchToMapBtn and not self.bindData.switchToTeamBtn then
		return
	end

	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local mapValid = isMobile and gLinkManager:CheckMiniMapValid()
	local teamValid = isMobile and gLinkManager:CheckTeamMainValid()
	self.bindData.mapValidCtrl = mapValid and self.mapValidCtrlEnum._true or self.mapValidCtrlEnum._false
	self.bindData.teamValidCtrl = teamValid and self.teamValidCtrlEnum._true or self.teamValidCtrlEnum._false
	self.bindData.showSwitchSystemCtrl = (mapValid or teamValid) and self.showSwitchSystemCtrlEnum.Show or self.showSwitchSystemCtrlEnum.Hide
	local sel = gLinkManager:ResolvePhoneTopLeftSelect()
	self.bindData.topLeftSelectCtrl = sel

	print_notice(string.format("[TopLeftSwitch] Refresh isMobile=%s mapValid=%s teamValid=%s pref=%s sel=%s", tostring(isMobile), tostring(mapValid), tostring(teamValid), tostring(gLinkManager.phoneTopLeftSelectPref), tostring(sel)))

	local sig = (isMobile and 1 or 0) * 10 + sel

	if self._lastTopLeftSig == sig then
		self._lastTopLeftSig = sig

		gTeamManager:RefreshHudUIState()
	end
end

M.OnClickSwitchToMapBtn = function(self)
	print_notice("[TopLeftSwitch] OnClickSwitchToMapBtn 点击到达 Lua")
	gLinkManager:SetPhoneTopLeftSelect(gLinkManager.PHONE_TOPLEFT.Map)
	self:RefreshTopLeftSwitch()
end

M.OnClickSwitchToTeamBtn = function(self)
	print_notice("[TopLeftSwitch] OnClickSwitchToTeamBtn 点击到达 Lua")
	gLinkManager:SetPhoneTopLeftSelect(gLinkManager.PHONE_TOPLEFT.Team)
	self:RefreshTopLeftSwitch()
end
