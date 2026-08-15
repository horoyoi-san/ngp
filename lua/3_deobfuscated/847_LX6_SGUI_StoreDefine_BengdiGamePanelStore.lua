local TweenEaseType = DG.Tweening.Ease
local HighActionFinishSignal = 1500
C_BengdiGamePanelStore = DefClass("C_BengdiGamePanelStore", C_BengdiGamePanelStore, C_StoreGroup)
GroupName2Class.BengdiGamePanelStore = C_BengdiGamePanelStore
local M = C_BengdiGamePanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.normalDiscoButton.luaClick = self:CreateAction("OnSwitchDanceStateClick")
	self.bindData.switchDiscoActionButton.luaClick = self:CreateAction("OnSwitchDanceGroupClick")
	self.bindData.switchStyleButton.luaClick = self:CreateAction("OnSwitchStyleClick")
	self.bindData.highDiscoButton.luaClick = self:CreateAction("OnHighDiscoClick")
	self.bindData.switchDiscoCameraButton.luaClick = self:CreateAction("OnSwitchCameraButtonClick")
	self.bindData.openPanelButton.luaClick = self:CreateActionWithArgs("SwitchFolderControl", 1)
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnTabRenderItem")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentRenderItem")
	self.bindData.closePanelButton.luaClick = self:CreateActionWithArgs("SwitchFolderControl", 0)
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnTabSelectedChange")
	self.bindData.contentList.luaSimpleClick = self:CreateAction("OnContentItemClick")
	self.bindData.styleList.luaSimpleRenderItem = self:CreateAction("OnStyleRenderItem")
	self.bindData.styleList.luaSimpleClick = self:CreateAction("OnStyleItemClick")
	self.bindData.switchUpperBodyActionButton.luaClick = self:CreateAction("OnSwitchUpperBodyActionClick")

	if self.bindData.InputRespond then
		self.bindData.InputRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
	end

	if self.bindData.leftButton then
		self.bindData.leftButton.luaClick = self:CreateActionWithArgs("OnStep", -1)
	end

	if self.bindData.rightButton then
		self.bindData.rightButton.luaClick = self:CreateActionWithArgs("OnStep", 1)
	end

	self:InitMessages()

	if gCS.LuaUtils.IsNonMobileAdaptive() and SGUI.UNavigationMgrEx.Inst.GamepadMotionSupport then
		self.gamepadPitchInfoDeque = require("LX6/Utils/Deque").New(128)

		SGUI.UNavigationMgrEx.Inst:ResetCurrentPadOrientation()

		self.bindData.gamepadMotionControl = 1

		gGFManager:ActiveGuide(13000132, 1)
	end
end

function M:InitMessages()
	self:RegisterMessageEvents({
		[gEventConstants.DISCO_MUSIC_BEAT] = function (_, akMusicSyncCallbackInfo)
			if not self.hasInitDanceState then
				self.hasInitDanceState = true

				self:SetABPVarValue(LTConfig.ABPVarConfig.DanceState, 1)
			end

			self:ChangeUiAnimationSpeed(akMusicSyncCallbackInfo)
		end,
		[gEventConstants.DISCO_MUSIC_HIGH_STATUS_CHANGE] = function (_, highInfo)
			self:OnDiscoMusicHigh(highInfo)
		end,
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = function (_, data)
			local signalId = data:GetCfgId()

			if signalId == HighActionFinishSignal then
				self:FinishHighAction()
			end
		end
	})
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	gBengdiActionManager.isPlaying = true
	gBengdiActionManager.discoUp = false
	gBengdiActionManager.discoDown = false
	gBengdiActionManager.discoHigh = false
	gBengdiActionManager.discoStopHigh = false
	gBengdiActionManager.musicHigh = false
	gBengdiActionManager.isLongPress = false
	gBengdiActionManager.isInLongPressEndCheck = false
	gBengdiActionManager.timeBetweenBeats = 0.6
	gBengdiActionManager.clickTime = -1
	gBengdiActionManager.beatTime = 0
	gBengdiActionManager.curDiscoTime = 0
	gBengdiActionManager.lostBeat = true
	gBengdiActionManager.lostPressLargeBeat = -1
	gBengdiActionManager.lostBeatChecked = false
	gBengdiActionManager.curBeatNum = 0
	gBengdiActionManager.noBeatChecked = false
	gBengdiActionManager.closePanelChecked = false
	gBengdiActionManager.timeRadiusFront = LTConfig.DanceConfig.HitMsDeviation.hitmstBefore / 1000
	gBengdiActionManager.timeRadiusBelow = LTConfig.DanceConfig.HitMsDeviation.hitmsBehind / 1000
	self.tweenTimeRatio = LTConfig.DanceConfig.tweenTimeRatio
	self.discoGameEnd = false
	self.curDanceProgress = 0
	self.cameraSetId = args and args.cameraSetId or 1
	self.curCameraIndex = 0
	self.firstPerson = false
	self.DiscoHighStatusCode = {
		musicNotHigh = 0,
		musicHighNotPress = 1
	}
	self.DanceStateControllerCode = {
		1,
		2,
		3,
		4
	}
	self.soundId = args and args.soundId

	if args and type(args) == "string" then
		local array = string.split(args, "=", true)
		self.soundId = tonumber(array[2])
	end

	if not self.soundId then
		print_error("@linminghe --- 请传入合适的soundId，之后再可以进入蹦迪！")
	end

	self.uiAnimationBindNames = {
		"stateUiAnimation1",
		"stateUiAnimation2",
		"stateUiAnimation3",
		"stateUiAnimation4"
	}
	self.uiAnimationLoopClipNames = {
		"S_Vx_BengdiGamePanel_Eff01",
		"S_Vx_BengdiGamePanel_Eff02",
		"S_Vx_BengdiGamePanel_Eff03",
		"S_Vx_BengdiGamePanel_Eff04"
	}
	self.TAB_GROUP_TYPE = {
		DanceStyle = 2,
		UpperBodyAction = 3,
		DanceGroup = 1
	}

	self:InitTabContentDataList()
end

function M:InitTabContentDataList()
	self.tabContentDataMap = {}
	local count = LTConfig.DanceDanceResourceConfig.count

	for i = 0, count - 1 do
		local danceGroupCfg = LTConfig.DanceDanceResourceConfig.LoadAt(i)
		local dataList = self.tabContentDataMap[danceGroupCfg.DanceTabType] or {}

		table.insert(dataList, danceGroupCfg.Id)

		self.tabContentDataMap[danceGroupCfg.DanceTabType] = dataList
	end
end

function M:InitView(_)
	self:SetCharacterInitAnimation()
	gBengdiActionManager:OnDiscoStart(self.soundId)
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(32, 0.5, nil, 5)
	gCS.CameraDataMgr.cinemachineManager:EnableFollowBallDamping(2, 2, 1, 1)
	self:OnDanceStateChange(gBengdiActionManager.DanceState.Enter)

	self.bindData.discoHighStatus = self.DiscoHighStatusCode.musicNotHigh

	self.bindData.danceProgressBar:ProgressToValue(0, 0.01, 0, TweenEaseType.InSine)

	self.bindData.panelActivate = 1
	self.progressbarTimer = Timer.New(function ()
		return
	end, 0.01, 0, false, false)

	self:RefreshTabListView()
end

function M:SetCharacterInitAnimation()
	local initDanceStyle = 1

	if not gClientUtils.CheckCurrentIsDefaultSpirit() then
		local npcCultivationId = gClientUtils.GetNpcCultivationId()
		local npcId = gBengdiActionManager.GetDanceNpcId(npcCultivationId)
		local npcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(npcId)

		if npcCfg then
			initDanceStyle = npcCfg.Personality
		end
	end

	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceStyle, initDanceStyle)
	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceGroup, LTConfig.DanceConfig.DefaultDanceType)
	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceUpperLayer, 0)
	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceState, 0)
	self:SetNpcDanceStyle()
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.StartBengDi)

	local npcUnit = self:GetInviteNpcUnit()
	local _ = npcUnit and gCS.LogicStateMachineManager.SendGameplayInwardSignal(npcUnit, LTConfig.GameplaySignalInwardConfig.StartBengDi)
end

function M:RefreshTabListView()
	self.bindData.tabList:SetSimpleList(#LTConfig.DanceConfig.DanceIconTab)
	self.bindData.tabList:SelectItem(0, true)

	local dataList = self.tabContentDataMap[self.TAB_GROUP_TYPE.DanceStyle]

	self.bindData.styleList:SetSimpleList(#dataList)
	self.bindData.styleList:SelectItem(0, true)
end

function M:RefreshTabContentListView()
	local dataList = self:GetCurrentTabContentList()
	local count = #dataList

	self.bindData.contentList:SetSimpleList(count)
end

function M:OnSwitchDanceStateClick()
	if gBengdiActionManager.DanceState.Max <= gBengdiActionManager.MyDanceState then
		print_debug("Disco-正在长按”high起来“按钮，此时不响应正常按钮")

		return
	end

	print_debug("Disco-监听到强度点击")

	if gBengdiActionManager:OnPlayerClick() then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommonHeavy1", LX6.Audio.ExternalSourceType.Motion_2D)
		self:OnCircleProgressTweenChange(self.curDanceProgress + gBengdiActionManager.fitBeatAddPoint)
	else
		self:OnCircleProgressTweenChange(self.curDanceProgress - 0.0625)
	end
end

function M:OnSwitchCameraButtonClick()
	print_debug("Disco-切换相机视角")

	local danceCameraSetCfg = LTConfig.DanceCameraSetConfig.GetConfig(self.cameraSetId)

	if danceCameraSetCfg == nil then
		return
	end

	if self.firstPerson then
		self.firstPerson = false

		gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(false, false)
	end

	self.maxCameraIndex = #danceCameraSetCfg.Camera_DanceAlone
	self.curCameraIndex = self.curCameraIndex + 1

	if self.maxCameraIndex < self.curCameraIndex then
		self.bindData.VCam.gameObject:SetActive(false)

		self.curCameraIndex = 0
	else
		if self.curCameraIndex == 1 then
			self.bindData.VCam.gameObject:SetActive(true)
		end

		if danceCameraSetCfg.Camera_DanceAlone[self.curCameraIndex] and danceCameraSetCfg.Camera_DanceAlone[self.curCameraIndex] == 99 then
			self.firstPerson = true

			gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(true, false, true)
		end

		local danceCameraCfg = LTConfig.DanceCameraConfig.GetConfig(danceCameraSetCfg.Camera_DanceAlone[self.curCameraIndex])

		if danceCameraCfg then
			gUtils:SetCameraView(gCS.MyPlayerManager.PlayerUnit, danceCameraCfg, self.bindData.VCam.gameObject)
		end
	end
end

function M:OnDanceStateChange(newState)
	if gBengdiActionManager.DanceState.Enter <= newState and newState <= gBengdiActionManager.DanceState.Max and newState ~= gBengdiActionManager.MyDanceState then
		print_debug("Disco-改变蹦迪强度状态：" .. tostring(newState))

		if gBengdiActionManager.MyDanceState < newState and gBengdiActionManager.DanceState.Enter <= gBengdiActionManager.MyDanceState then
			self:PlayDanceStateChangeDialog(newState)
		end

		gBengdiActionManager.MyDanceState = newState

		self:SetABPVarValue(LTConfig.ABPVarConfig.DanceState, newState)

		if newState == gBengdiActionManager.DanceState.Max then
			self.bindData.isHighPressing = 1
		elseif newState ~= gBengdiActionManager.DanceState.Max and gBengdiActionManager.musicHigh then
			self.bindData.danceStateController = self.DanceStateControllerCode[newState]
			self.bindData.isHighPressing = 0
		else
			self.bindData.danceStateController = self.DanceStateControllerCode[newState]
			self.bindData.discoHighStatus = self.DiscoHighStatusCode.musicNotHigh

			if self.bindData.isHideHighLongPressAnim == 1 or self.bindData.isHideHighLongPressAnim == nil then
				self.bindData.longPressAnim:Play("S_Vx_LongpressTips")

				self.bindData.isHideHighLongPressAnim = 0
			end
		end

		self:RefreshDiscoHighStatus()
	end
end

function M:PlayDanceStateChangeDialog(newState)
	if not self:GetInviteNpcUnit() then
		return
	end

	local probability = LTConfig.DanceConfig.DanceSpeakProbability

	if math.random() <= probability then
		local danceNpcId = self:GetInviteDanceNpcId()
		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(danceNpcId)
		local dialogIdList = nil

		if newState == 4 then
			dialogIdList = danceNpcCfg and danceNpcCfg.Dialog_HiDacne
		else
			dialogIdList = danceNpcCfg and danceNpcCfg.Dialog_DanceChange
		end

		if dialogIdList and #dialogIdList > 0 then
			local dialogIdIndex = math.random(1, #dialogIdList)
			local dialogId = dialogIdList[dialogIdIndex]

			gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.BengDi, nil, nil)
		end
	end
end

function M:GetInviteDanceNpcId()
	local npcUnit = self:GetInviteNpcUnit()

	if npcUnit then
		return gBengdiActionManager:GetInviteDanceNpcId()
	end
end

local addProgressTime = 0

function M:OnCircleProgressTweenChange(newProgress)
	if self.discoGameEnd then
		return
	end

	local isAddCircle = self.curDanceProgress < newProgress
	self.curDanceProgress = newProgress

	print_debug("Disco-  myState = " .. gBengdiActionManager.MyDanceState)

	local tweenTime = gBengdiActionManager.timeBetweenBeats * self.tweenTimeRatio

	if self.curDanceProgress >= 1 then
		self.bindData.danceProgressBar:ProgressToValue(1, isAddCircle and addProgressTime or tweenTime / 5, 0, TweenEaseType.InSine)
		self.progressbarTimer:Reset(function ()
			if gBengdiActionManager.MyDanceState < gBengdiActionManager.DanceState.Hot then
				self.bindData.danceProgressBar:ProgressToValue(0, 0, 0, TweenEaseType.InSine)

				self.curDanceProgress = self.curDanceProgress - 1

				self:OnDanceStateChange(gBengdiActionManager.MyDanceState + 1)

				gBengdiActionManager.discoUp = true
			else
				self.curDanceProgress = 1
			end

			self.bindData.danceProgressBar:ProgressToValue(self.curDanceProgress, isAddCircle and addProgressTime or tweenTime / 3, 0, TweenEaseType.InSine)
		end, tweenTime / 5, 0, false)
		self.progressbarTimer:Start(false)
	elseif self.curDanceProgress < 1 and self.curDanceProgress >= 0 then
		self.bindData.danceProgressBar:ProgressToValue(self.curDanceProgress, isAddCircle and addProgressTime or tweenTime, 0, TweenEaseType.InSine)
	else
		self.bindData.danceProgressBar:ProgressToValue(0, isAddCircle and addProgressTime or tweenTime / 5, 0, TweenEaseType.InSine)

		if gBengdiActionManager.MyDanceState <= gBengdiActionManager.DanceState.Enter then
			self.curDanceProgress = 0
		end

		self.progressbarTimer:Reset(function ()
			local isWaitHighDisco = gBengdiActionManager.MyDanceState == gBengdiActionManager.DanceState.Hot and gBengdiActionManager.musicHigh

			if gBengdiActionManager.DanceState.Enter < gBengdiActionManager.MyDanceState and not isWaitHighDisco then
				self:OnDanceStateChange(gBengdiActionManager.MyDanceState - 1)
				self.bindData.danceProgressBar:ProgressToValue(1, 0, 0, TweenEaseType.InSine)

				self.curDanceProgress = self.curDanceProgress + 1
				gBengdiActionManager.discoDown = true
			else
				self.curDanceProgress = 0
			end

			if self.bindData.danceProgressBar then
				self.bindData.danceProgressBar:ProgressToValue(self.curDanceProgress, isAddCircle and addProgressTime or tweenTime / 3, 0, TweenEaseType.InSine)
			end
		end, tweenTime / 5, 0, false)
		self.progressbarTimer:Start(false)
	end

	self.bindData.hidePoint = self.curDanceProgress == 0 and 1 or 0
end

function M:OnRightStickControl(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		gCameraUtils:DoRotateCameraByGamePad(1, value.x, value.y)
	end

	if context.canceled then
		gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
	end
end

function M:OnDualSenseMotionUpdate()
	local deque = self.gamepadPitchInfoDeque

	if deque == nil or not gClientUtils.IsControllerMode() then
		return
	end

	if not self.triggerDualSenseGuideOnce then
		self.triggerDualSenseGuideOnce = true
	end

	local threshold = 10
	local maxTime = 2
	local motionData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadMotionData()

	if self.gamepadWaitForRotateUp then
		if motionData.angularVelocity.x < 0.1 then
			return
		else
			self.gamepadWaitForRotateUp = false
		end
	end

	local orientationX = SGUI.UNavigationMgrEx.Inst:GetCurrentPadOrientationX()
	local time = Time.unscaledTime

	deque:PushBack({
		time = time,
		orientationX = orientationX
	})

	while deque.Count > 0 and maxTime < time - deque:Front().time do
		deque:PopFront()
	end

	if deque.Count < 2 then
		return
	end

	local maxVal = deque:Front().orientationX

	for i = 2, deque.Count do
		local sample = deque:TryGetAt(i).orientationX

		if threshold < maxVal - sample then
			self:OnDualSenseGamepadDip()
			deque:Clear()

			self.gamepadWaitForRotateUp = true

			break
		end

		if maxVal < sample then
			maxVal = sample
		end
	end
end

function M:OnDualSenseGamepadDip()
	gNewGuideMgr:NotifySignal(EGuideSignal.BengDiDualSense)
	self:OnSwitchDanceStateClick()
end

function M:OnHighDiscoClick()
	gBengdiActionManager.discoHigh = true
	gBengdiActionManager.MyDanceState = gBengdiActionManager.DanceState.Max

	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceState, gBengdiActionManager.DanceState.Max)

	self.bindData.panelActivate = 0
end

function M:OnDiscoMusicHigh(musicHighInfo)
	print_debug("Disco-音乐副歌消息下发", musicHighInfo.userCueName)

	if musicHighInfo.userCueName == "ClimaxStart" then
		gBengdiActionManager.musicHigh = true

		self:RefreshDiscoHighStatus()
	elseif musicHighInfo.userCueName == "ClimaxEnd" then
		gBengdiActionManager.musicHigh = false

		self:RefreshDiscoHighStatus()
	end
end

function M:RefreshDiscoHighStatus()
	if gBengdiActionManager.musicHigh then
		if gBengdiActionManager.MyDanceState == gBengdiActionManager.DanceState.Hot then
			self.bindData.discoHighStatus = self.DiscoHighStatusCode.musicHighNotPress
		end
	else
		self.bindData.discoHighStatus = self.DiscoHighStatusCode.musicNotHigh
	end
end

function M:OnUpdate()
	self:OnDiscoUpdate(Time.deltaTime)
	self:OnDualSenseMotionUpdate()
end

function M:OnDiscoUpdate(dt)
	gBengdiActionManager.curDiscoTime = gBengdiActionManager.curDiscoTime + dt

	if gBengdiActionManager.curDiscoTime > 99999999 then
		gBengdiActionManager.curDiscoTime = 0
	end

	if gBengdiActionManager.beatTime + gBengdiActionManager.timeRadiusBelow <= gBengdiActionManager.curDiscoTime and not gBengdiActionManager.lostBeatChecked then
		gBengdiActionManager.lostBeatChecked = true

		if gBengdiActionManager.lostBeat and not gBengdiActionManager.discoHigh then
			self:OnCircleProgressTweenChange(self.curDanceProgress - gBengdiActionManager.lostBeatSubtractPoint)
		end

		gBengdiActionManager.lostBeat = true
	end

	if gBengdiActionManager.curDiscoTime - gBengdiActionManager.beatTime >= 6 and not gBengdiActionManager.noBeatChecked then
		gBengdiActionManager.noBeatChecked = true
		gBengdiActionManager.MyDanceState = gBengdiActionManager.DanceState.Enter

		gBengdiActionManager:OnDiscoEnd()
	end
end

function M:OnSwitchDanceGroupClick()
	local result, currentDanceGroupValue = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceGroup, nil)

	if result then
		local danceGroupCount = #self.tabContentDataMap[self.TAB_GROUP_TYPE.DanceGroup]
		currentDanceGroupValue = currentDanceGroupValue % danceGroupCount + 1

		self:SetABPVarValue(LTConfig.ABPVarConfig.DanceGroup, currentDanceGroupValue)
	end

	self:PlayDanceGroupChangeDialog()
end

function M:PlayDanceGroupChangeDialog()
	if not self:GetInviteNpcUnit() then
		return
	end

	local probability = LTConfig.DanceConfig.DanceSpeakProbability

	if math.random() <= probability then
		local danceNpcId = self:GetInviteDanceNpcId()
		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(danceNpcId)
		local dialogIdList = danceNpcCfg and danceNpcCfg.Dialog_DanceTypeChange

		if dialogIdList and #dialogIdList > 0 then
			local dialogIdIndex = math.random(1, #dialogIdList)
			local dialogId = dialogIdList[dialogIdIndex]

			gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.BengDi, nil, nil)
		end
	end
end

function M:ChangeUiAnimationSpeed(musicBeatInfo)
	local clip = self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]]:GetClip(self.uiAnimationLoopClipNames[gBengdiActionManager.MyDanceState])

	self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]]:Stop()
	clip:SampleAnimation(self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]].gameObject, 0)

	self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]]:get_Item(self.uiAnimationLoopClipNames[gBengdiActionManager.MyDanceState]).speed = clip.length / musicBeatInfo.segmentInfo_fBeatDuration

	self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]]:Play(self.uiAnimationLoopClipNames[gBengdiActionManager.MyDanceState])
end

function M:OnSwitchStyleClick()
	local result, currentDanceStyleValue = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceStyle, nil)

	if result then
		currentDanceStyleValue = currentDanceStyleValue % 3 + 1

		self:SetABPVarValue(LTConfig.ABPVarConfig.DanceStyle, currentDanceStyleValue)
	end
end

function M:SwitchFolderControl(value)
	self.bindData.foldControl = value

	if self.bindData.foldControl == 1 then
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, false)
		self.bindData.contentList:RefreshList()
	else
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, true)
	end
end

function M:OnTabRenderItem(btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local data = LTConfig.DanceConfig.DanceIconTab[luaIndex]
	store.iconId = data.DanceTabID
	store.name = data.DanceTabName
end

function M:OnContentRenderItem(btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local dataList = self:GetCurrentTabContentList()
	local id = dataList[luaIndex]
	local resourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(id)
	store.iconId = resourceCfg.DanceSImage
	store.name = resourceCfg.DanceTabChildName
	btn.isSelected = self:CheckDanceItemHasSelected(id)
end

function M:CheckDanceItemHasSelected(id)
	local danceResourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(id)

	if danceResourceCfg.DanceTabType == self.TAB_GROUP_TYPE.DanceGroup then
		local result, currentDanceGroup = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceGroup, nil)

		return result and currentDanceGroup == danceResourceCfg.StateTreeSignal
	elseif danceResourceCfg.DanceTabType == self.TAB_GROUP_TYPE.DanceStyle then
		local result, currentDanceStyle = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceStyle, nil)

		return result and currentDanceStyle == danceResourceCfg.StateTreeSignal
	elseif danceResourceCfg.DanceTabType == self.TAB_GROUP_TYPE.UpperBodyAction then
		local result, currentDanceUpperLayer = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceUpperLayer, nil)

		return result and currentDanceUpperLayer == danceResourceCfg.StateTreeSignal
	end
end

function M:OnTabSelectedChange()
	self:RefreshTabContentListView()
end

function M:OnContentItemClick(_, csIndex)
	local luaIndex = csIndex + 1
	local dataList = self:GetCurrentTabContentList()
	local id = dataList[luaIndex]

	self:OnDanceResourceItemClick(id)
end

function M:OnDanceResourceItemClick(id)
	local danceResourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(id)

	if danceResourceCfg.DanceTabType == self.TAB_GROUP_TYPE.DanceGroup then
		self:SetABPVarValue(LTConfig.ABPVarConfig.DanceGroup, danceResourceCfg.StateTreeSignal)
	elseif danceResourceCfg.DanceTabType == self.TAB_GROUP_TYPE.DanceStyle then
		self:SetABPVarValue(LTConfig.ABPVarConfig.DanceStyle, danceResourceCfg.StateTreeSignal)
	elseif danceResourceCfg.DanceTabType == self.TAB_GROUP_TYPE.UpperBodyAction then
		self:SetABPVarValue(LTConfig.ABPVarConfig.DanceUpperLayer, danceResourceCfg.StateTreeSignal)
	end
end

function M:SetABPVarValue(key, value, isForce)
	print_debug(("Disco- SetABPVarValue, key:%d, value:%d"):format(key, value))

	local npcUnit = self:GetInviteNpcUnit()

	if npcUnit and key == LTConfig.ABPVarConfig.DanceState and value == gBengdiActionManager.DanceState.Max then
		value = 5
	end

	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, key, value)

	if npcUnit and (key == LTConfig.ABPVarConfig.DanceGroup or key == LTConfig.ABPVarConfig.DanceState or isForce) then
		MuGenStates.Logic.ABPVarManager.SetInt(npcUnit, key, value)
	end
end

function M:GetInviteNpcUnit()
	return gBengdiActionManager:GetInviteNpcUnit()
end

function M:SetNpcDanceStyle()
	local npcUnit = self:GetInviteNpcUnit()

	if npcUnit then
		local danceNpcId = self:GetInviteDanceNpcId()
		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(danceNpcId)
		local danceStyleValue = danceNpcCfg and danceNpcCfg.Personality or 1

		MuGenStates.Logic.ABPVarManager.SetInt(npcUnit, LTConfig.ABPVarConfig.DanceStyle, danceStyleValue)
	end
end

function M:OnStyleRenderItem(btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local dataList = self.tabContentDataMap[self.TAB_GROUP_TYPE.DanceStyle]
	local id = dataList[luaIndex]
	local danceResourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(id)
	store.title = danceResourceCfg.DanceTabChildName
	btn.isSelected = self:CheckDanceItemHasSelected(id)
end

function M:OnStyleItemClick(_, csIndex)
	local luaIndex = csIndex + 1
	local dataList = self.tabContentDataMap[self.TAB_GROUP_TYPE.DanceStyle]
	local id = dataList[luaIndex]

	self:OnDanceResourceItemClick(id)
end

function M:GetCurrentTabContentList()
	local tabLuaIndex = self.bindData.tabList.selectedIndex + 1
	local tabData = LTConfig.DanceConfig.DanceIconTab[tabLuaIndex]

	return self.tabContentDataMap[tabData.DanceGroupId]
end

function M:FinishHighAction()
	self.bindData.discoHighStatus = self.DiscoHighStatusCode.musicNotHigh
	self.bindData.panelActivate = 1
	gBengdiActionManager.discoHigh = nil

	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceState, gBengdiActionManager.MyDanceState - 1)
end

function M:OnSwitchUpperBodyActionClick()
	local result, currentDanceUpperBodyActionValue = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceUpperLayer, nil)

	if result then
		currentDanceUpperBodyActionValue = currentDanceUpperBodyActionValue + 1
		local danceUpperBodyCount = #self.tabContentDataMap[self.TAB_GROUP_TYPE.UpperBodyAction]
		currentDanceUpperBodyActionValue = currentDanceUpperBodyActionValue % (danceUpperBodyCount + 1)

		self:SetABPVarValue(LTConfig.ABPVarConfig.DanceUpperLayer, currentDanceUpperBodyActionValue)
	end
end

function M:OnStep(step)
	self.preTime = gLogicTime.unscaledTime
	local index = self.bindData.tabList.selectedIndex + step
	local itemCount = #LTConfig.DanceConfig.DanceIconTab

	if index < 0 then
		index = itemCount - 1
	elseif itemCount <= index then
		index = 0
	end

	self.bindData.tabList:SelectItem(index)
end

function M:OnDestroy()
	gBengdiActionManager:PlayFinishDialog()

	if not gBengdiActionManager.inviteNpcPid then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "DiscoDanceSingleFinish"
		})
	end

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, true)
	self:ClearMessageEvents()
	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceStyle, 0, true)
	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceGroup, 0, true)
	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceState, 0, true)
	self:SetABPVarValue(LTConfig.ABPVarConfig.DanceUpperLayer, 0, true)

	self.discoGameEnd = true
	gBengdiActionManager.inviteNpcPid = nil
	self.gamepadPitchInfoDeque = nil
	self.gamepadWaitForRotateUp = nil
	self.triggerDualSenseGuideOnce = nil

	gGFManager:StopCurrentGuide()

	self.bindData.panelActivate = 0

	gBengdiActionManager:OnDiscoEnd()

	if self.firstPerson then
		self.firstPerson = true

		gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(false, false)
	end

	self.hasInitDanceState = nil
end
