-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BengdiGamePanelStore.lua
-- Decompiled from: 01675_BengdiGamePanelStore.lua_c9566c22980c.luajit

local TweenEaseType = DG.Tweening.Ease
C_BengdiGamePanelStore = DefClass("C_BengdiGamePanelStore", C_BengdiGamePanelStore, C_StoreGroup)
GroupName2Class.BengdiGamePanelStore = C_BengdiGamePanelStore
local M = C_BengdiGamePanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.normalDiscoButton.luaClick = self.CreateAction(self, "OnSwitchDanceStateClick")
	self.bindData.switchDiscoActionButton.luaClick = self.CreateAction(self, "OnSwitchDanceGroupClick")
	self.bindData.highDiscoButton.luaPress = self.CreateAction(self, "OnHighDiscoStart")
	self.bindData.highDiscoButton.luaRelease = self.CreateAction(self, "OnHighDiscoEnd")
	self.bindData.switchDiscoCameraButton.luaClick = self.CreateAction(self, "OnSwitchCameraButtonClick")
	self.bindData.openPanelButton.luaClick = self.CreateActionWithArgs(self, "SwitchFolderControl", 1)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnTabRenderItem")
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, "OnContentRenderItem")
	self.bindData.closePanelButton.luaClick = self.CreateActionWithArgs(self, "SwitchFolderControl", 0)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, "OnTabSelectedChange")
	self.bindData.contentList.luaSimpleClick = self.CreateAction(self, "OnContentItemClick")

	if self.bindData.switchMotionWButton then
		self.bindData.switchMotionWButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchMotionPress", "w")
		self.bindData.switchMotionWButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchMotionRelease", "w")
	end

	if self.bindData.switchMotionAButton then
		self.bindData.switchMotionAButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchMotionPress", "a")
		self.bindData.switchMotionAButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchMotionRelease", "a")
	end

	if self.bindData.switchMotionSButton then
		self.bindData.switchMotionSButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchMotionPress", "s")
		self.bindData.switchMotionSButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchMotionRelease", "s")
	end

	if self.bindData.switchMotionDButton then
		self.bindData.switchMotionDButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchMotionPress", "d")
		self.bindData.switchMotionDButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchMotionRelease", "d")
	end

	if self.bindData.leftButton then
		self.bindData.leftButton.luaClick = self.CreateActionWithArgs(self, "OnStep", -1)
	end

	if self.bindData.rightButton then
		self.bindData.rightButton.luaClick = self.CreateActionWithArgs(self, "OnStep", 1)
	end

	if self.bindData.joyStick then
		self.bindData.joyStick.luaValueChanged = self.CreateAction(self, "OnJoyStickValueChange")
		self.bindData.joyStick.luaEndDrag = self.CreateAction(self, "OnJoyStickEndDrag")
	end

	if self.bindData.uNavResponse then
		self.bindData.uNavResponse.luaGamePadInputChanged = self.CreateAction(self, "OnConsoleSwitchMotionResponse")
	end

	self.InitMessages(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() and SGUI.UNavigationMgrEx.Inst.GamepadMotionSupport then
		self.gamepadPitchInfoDeque = require("LX6/Utils/Deque").New(128)

		SGUI.UNavigationMgrEx.Inst:ResetCurrentPadOrientation()

		self.bindData.gamepadMotionControl = 1

		gNewGuideMgr:AskStartGuideByClient(13000132)
	end
end

M.InitMessages = function(self)
	self.RegisterMessageEvents(self, {
		[gEventConstants.DISCO_MUSIC_BEAT] = function (_, akMusicSyncCallbackInfo)
			if not self.hasInitDanceState then
				self.hasInitDanceState = true

				self:SetABPVarIntValue(LTConfig.ABPVarConfig.DanceState, 1)
			end

			self:ChangeUiAnimationSpeed(akMusicSyncCallbackInfo)
		end,
		[gEventConstants.DISCO_MUSIC_HIGH_STATUS_CHANGE] = function (_, highInfo)
			self:OnDiscoMusicHigh(highInfo)
		end
	})
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(self.m_Id, 1)
end

M.InitModel = function(self, args)
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
		["bc\\xbf~O\\x9c\\xfdSBsyD"] = 0,
		["y\\xe94\\xe5*&\\xc4i\\xda_\\xbcG\\xd5\\xf5"] = 1,
		["\\xea\\x8f\\xe59\\xef\\xe2\\xb8\\xff\\x873;"] = 2
	}
	self.DanceStateControllerCode = {
		1,
		2,
		3,
		4
	}
	self.soundId = args and args.soundId

	if args and type(args) ~= "string" then
		local array = string.split(args, "=", true)
		self.soundId = tonumber(array[2])
	end

	if not self.soundId then
		print_error("@linminghe --- 请传入合适的soundId，之后再可以进入蹦迪！")
	end

	self.uiAnimationBindNames = {
		"g\\xe8&\\xf8,&\\xe2o)\\xd8J\\x98Mȷ",
		"g\\xe8&\\xf8,&\\xe2o)\\xd8J\\x98Mȴ",
		"g\\xe8&\\xf8,&\\xe2o)\\xd8J\\x98Mȵ",
		"g\\xe8&\\xf8,&\\xe2o)\\xd8J\\x98MȲ"
	}
	self.uiAnimationLoopClipNames = {
		"0ٱ=/\\xecX,\\xb4\\x8cA\\xb0Z\\x8de.\\xbd<Á#@\\x9f",
		"0ٱ=/\\xecX,\\xb4\\x8cA\\xb0Z\\x8de.\\xbd<Á#@\\x9c",
		"0ٱ=/\\xecX,\\xb4\\x8cA\\xb0Z\\x8de.\\xbd<Á#@\\x9d",
		"0ٱ=/\\xecX,\\xb4\\x8cA\\xb0Z\\x8de.\\xbd<Á#@\\x9a"
	}
	self.TAB_GROUP_TYPE = {
		["G\\x88vB\\xb1\\xf7`xuk\\"] = 2,
		["w[\\xc0\\xbe\\x81/\\xaa\\xdc\\xf8"] = 1
	}

	self:InitTabContentDataList()

	self.npcUnit = gBengdiActionManager:GetInviteNpcUnit()
	self.danceNpcId = self.npcUnit and gBengdiActionManager:GetInviteDanceNpcId()
	self.lastNpcAnimationNormalized = 0
	self.playedDialogMap = {}
	self.playedHigDanceDialogMap = {}
	self.danceGroupSpeakChangeCount = 0
	self.isTiredFinish = nil
	self.npcInGuaranteedState = nil
end

M.InitTabContentDataList = function(self)
	self.tabContentDataMap = {}
	local npcCultivationId = gMainPhoneUtils.GetNpcCultivationId()
	local danceMainCount = LTConfig.DanceDanceMainConfig.count
	local targetDanceMainCfg = nil

	for i = 0, danceMainCount - 1 do
		local danceMainCfg = LTConfig.DanceDanceMainConfig.LoadAt(i)

		if danceMainCfg.Npcid ~= npcCultivationId then
			targetDanceMainCfg = danceMainCfg

			break
		end
	end

	local danceResourceCount = LTConfig.DanceDanceResourceConfig.count

	for i = 0, danceResourceCount - 1 do
		local danceResourceCfg = LTConfig.DanceDanceResourceConfig.LoadAt(i)
		local tabType = danceResourceCfg.DanceTabType
		local shouldAdd = true

		if tabType ~= self.TAB_GROUP_TYPE.DanceGroup and targetDanceMainCfg then
			shouldAdd = table.contains(targetDanceMainCfg.DanceGroupStateTree, danceResourceCfg.StateTreeSignal)
		end

		if shouldAdd then
			local dataList = self.tabContentDataMap[tabType]

			if not dataList then
				dataList = {}
				self.tabContentDataMap[tabType] = dataList
			end

			table.insert(dataList, danceResourceCfg.Id)
		end
	end
end

M.InitView = function(self, _)
	self.currX = 0
	self.currY = 0
	self.targetX = nil
	self.targetY = nil
	self.blendSpeed = LTConfig.DanceConfig.BlendSpeed

	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
	self:SetCharacterInitAnimation()
	gBengdiActionManager:OnDiscoStart(self.soundId)
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(32, 0.5, nil, 5)
	gCS.CameraDataMgr.cinemachineManager:EnableFollowBallDamping(LTConfig.DanceConfig.CameraDistanceEasingHorizontalRadius, 2, 1, 1)
	self:OnDanceStateChange(gBengdiActionManager.DanceState.Enter)

	self.bindData.discoHighStatus = self.DiscoHighStatusCode.musicNotHigh

	self.bindData.danceProgressBar:ProgressToValue(0, 0.01, 0, TweenEaseType.InSine)

	self.bindData.panelActivate = 1
	self.progressbarTimer = Timer.New(function ()
	end, 0.01, 0, false, false)

	self:RefreshTabListView()
end

M.SetCharacterInitAnimation = function(self)
	local danceResourceList = self.tabContentDataMap[self.TAB_GROUP_TYPE.DanceGroup]
	local danceResourceId = danceResourceList[1]
	local danceResourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(danceResourceId)

	self.SetABPVarIntValue(self, LTConfig.ABPVarConfig.DanceGroup, danceResourceCfg.StateTreeSignal)
	self.SetABPVarIntValue(self, LTConfig.ABPVarConfig.DanceState, 0)
	self.SetABPVarIntValue(self, LTConfig.ABPVarConfig.HiDanceGroup, 1)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.StartBengDi)

	if self.npcUnit then
		local _ = gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.npcUnit, LTConfig.GameplaySignalInwardConfig.StartBengDi)
		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)

		MuGenStates.Logic.ABPVarManager.SetInt(self.npcUnit, LTConfig.ABPVarConfig.DanceNPCGroup, danceNpcCfg.DanceNpcGroup)
		MuGenStates.Logic.ABPVarManager.SetInt(self.npcUnit, LTConfig.ABPVarConfig.DanceState, 1)

		local danceGroupStateTreeList = danceNpcCfg.DanceGroupStateTree
		local randomDanceGroup = math.random(1, #danceGroupStateTreeList)

		MuGenStates.Logic.ABPVarManager.SetInt(self.npcUnit, LTConfig.ABPVarConfig.DanceGroup, randomDanceGroup)
		self.StartGuaranteedState2Change(self)
		self.StartGuaranteedState3Change(self)
		self.StartSlowDownTime(self)
		self.StartTiredTime(self)
	end
end

M.StartTiredTime = function(self)
	local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
	self.startTiredTimeCo = coroutine.start(function ()
		coroutine.wait(danceNpcCfg.TiredTime)
		print_notice("Disco Npc Behavior --疲劳状态")

		self.isTiredFinish = true

		gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	end)
end

M.StartSlowDownTime = function(self)
	local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
	self.startSlowDownTimeCo = coroutine.start(function ()
		local waitTime = danceNpcCfg.SlowDownTime

		coroutine.wait(waitTime)

		self.npcInGuaranteedState = 1

		print_notice("Disco Npc Behavior --衰减状态")

		self.startSlowDownTimeCo = nil
	end)
end

M.StartGuaranteedState2Change = function(self)
	self.guaranteedState2ChangeCo = coroutine.start(function ()
		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
		local waitTime = danceNpcCfg.StateGuaranteedTime_2

		coroutine.wait(waitTime)
		print_notice("Disco Npc Behavior 保底2强度状态")

		self.npcInGuaranteedState = 2
		self.guaranteedState2ChangeCo = nil
	end)
end

M.StartGuaranteedState3Change = function(self)
	self.guaranteedState3ChangeCo = coroutine.start(function ()
		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
		local waitTime = danceNpcCfg.StateGuaranteedTime_3

		coroutine.wait(waitTime)

		self.npcInGuaranteedState = 3

		print_notice("Disco Npc Behavior 保底3强度状态")

		self.guaranteedState3ChangeCo = nil
	end)
end

M.RefreshTabListView = function(self)
	self.bindData.tabList:SetSimpleList(#LTConfig.DanceConfig.DanceIconTab)
	self.bindData.tabList:SelectItem(0, true)
end

M.RefreshTabContentListView = function(self)
	local dataList = self:GetCurrentTabContentList()
	local count = #dataList
	local tabType = self:GetCurrentTabType()

	self.bindData.contentList.onGetTIndex = function()
		if tabType ~= self.TAB_GROUP_TYPE.HiDanceGroup then
			return 1
		end

		return 0
	end

	self.bindData.contentList:SetSimpleList(count)

	if tabType ~= self.TAB_GROUP_TYPE.HiDanceGroup then
		local result, currentHigDanceGroup = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.HiDanceGroup, nil)
		local targetIndex = 0

		if result then
			for index, id in ipairs(dataList) do
				local resourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(id)

				if resourceCfg.StateTreeSignal ~= currentHigDanceGroup then
					targetIndex = index

					break
				end
			end
		end

		self.bindData.contentList:SelectItem(0, true)
	end
end

M.GetCurrentTabType = function(self)
	return self.bindData.tabList.selectedIndex + 1
end

M.OnSwitchDanceStateClick = function(self)
	if gBengdiActionManager.DanceState.Max < gBengdiActionManager.MyDanceState then
		print_debug("Disco-正在长按”high起来“按钮，此时不响应正常按钮")

		return
	end

	print_debug("Disco-监听到强度点击")

	if gBengdiActionManager:OnPlayerClick() then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommonHeavy1", LX6.Audio.ExternalSourceType.Motion_2D)
		self:OnCircleProgressTweenChange(self.curDanceProgress + gBengdiActionManager.fitBeatAddPoint)
	else
		self.OnCircleProgressTweenChange(self, self.curDanceProgress - 0.0625)
	end
end

M.OnSwitchCameraButtonClick = function(self)
	print_debug("Disco-切换相机视角")

	local danceCameraSetCfg = LTConfig.DanceCameraSetConfig.GetConfig(self.cameraSetId)

	if danceCameraSetCfg ~= nil then
		return
	end

	if self.firstPerson then
		self.firstPerson = false

		gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(false, false)
		gCS.MyPlayerManager.PlayerUnit:ForceSetSetippleAlpha(0, false)
	end

	self.maxCameraIndex = #danceCameraSetCfg.Camera_DanceAlone
	self.curCameraIndex = self.curCameraIndex + 1

	if self.maxCameraIndex >= self.curCameraIndex then
		self.bindData.VCam.gameObject:SetActive(false)

		self.curCameraIndex = 0
	else
		if self.curCameraIndex ~= 1 then
			self.bindData.VCam.gameObject:SetActive(true)
		end

		if danceCameraSetCfg.Camera_DanceAlone[self.curCameraIndex] and danceCameraSetCfg.Camera_DanceAlone[self.curCameraIndex] ~= 99 then
			self.firstPerson = true

			gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(true, false, true)
			gCS.MyPlayerManager.PlayerUnit:ForceSetSetippleAlpha(1, true)
		end

		local danceCameraCfg = LTConfig.DanceCameraConfig.GetConfig(danceCameraSetCfg.Camera_DanceAlone[self.curCameraIndex])

		if danceCameraCfg then
			gUtils:SetCameraView(gCS.MyPlayerManager.PlayerUnit, danceCameraCfg, self.bindData.VCam.gameObject)
		end
	end
end

M.OnDanceStateChange = function(self, newState)
	if gBengdiActionManager.DanceState.Enter < newState and newState < gBengdiActionManager.DanceState.Max and newState == gBengdiActionManager.MyDanceState then
		self.highDanceSpeakCheckCo = coroutine.stop(self.highDanceSpeakCheckCo)

		print_debug("Disco-改变蹦迪强度状态：" .. tostring(newState))

		if gBengdiActionManager.MyDanceState <= 0 then
			self.SyncNpcDanceStateChange(self, newState - gBengdiActionManager.MyDanceState)
		end

		if gBengdiActionManager.MyDanceState < newState and gBengdiActionManager.DanceState.Enter < gBengdiActionManager.MyDanceState then
			self.CheckDanceStateChangeDialog(self, newState)
		end

		gBengdiActionManager.MyDanceState = newState

		self.SetABPVarIntValue(self, LTConfig.ABPVarConfig.DanceState, newState)

		if newState ~= gBengdiActionManager.DanceState.Max then
			self.bindData.isHighPressing = 1
		elseif newState == gBengdiActionManager.DanceState.Max and gBengdiActionManager.musicHigh then
			self.bindData.danceStateController = self.DanceStateControllerCode[newState]
		else
			self.bindData.danceStateController = self.DanceStateControllerCode[newState]
		end

		self.RefreshDiscoHighStatus(self)
	end
end

M.SyncNpcDanceStateChange = function(self, increase)
	if not self.npcUnit then
		return
	end

	self.danceStateCheckCo = coroutine.stop(self.danceStateCheckCo)
	self.npcGainUp = 0
	local waitTime = increase <= 0 and LTConfig.DanceConfig.DanceUpKeep or LTConfig.DanceConfig.DanceDownKeep
	self.danceStateCheckCo = coroutine.start(function ()
		coroutine.wait(waitTime)

		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
		self.npcGainUp = increase <= 0 and danceNpcCfg.GainUp or -1 * danceNpcCfg.AttenuationUP

		print_notice("Disco Npc Behavior --主角强度变化增加增益", self.npcGainUp)
	end)
end

M.CheckDanceStateChangeDialog = function(self, newState)
	if not self.npcUnit or self.danceStateChangeCdCo then
		return
	end

	self.highDanceSpeakCheckCo = coroutine.stop(self.highDanceSpeakCheckCo)
	local hitProbability = math.random() > LTConfig.DanceConfig.DanceSpeakProbability

	if newState >= 4 then
		if hitProbability then
			self.PlayDanceStateChangeDialog(self)
		end
	elseif newState ~= 4 then
		if hitProbability then
			self.PlayHighDanceDialog(self)
		else
			self.highDanceSpeakCheckCo = coroutine.start(function ()
				while true do
					coroutine.wait(LTConfig.DanceConfig.HiDanceSpeakCheckTime)

					if math.random() < LTConfig.DanceConfig.DanceSpeakProbability then
						self:PlayHighDanceDialog()

						break
					end
				end
			end)
		end
	end
end

M.PlayDanceStateChangeDialog = function(self)
	local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
	local dialogIdList = danceNpcCfg.Dialog_DanceChange
	local unPlayedList = {}

	for _, dialogId in ipairs(dialogIdList) do
		if not self.playedDialogMap[dialogId] then
			table.insert(unPlayedList, dialogId)
		end
	end

	local dialogId = nil

	if #unPlayedList <= 0 then
		local index = math.random(1, #unPlayedList)
		dialogId = unPlayedList[index]
	else
		self.playedDialogMap = {}
		local index = math.random(1, #dialogIdList)
		dialogId = dialogIdList[index]
	end

	self.playedDialogMap = self.playedDialogMap or {}
	self.playedDialogMap[dialogId] = true

	gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.BengDi, nil, )
	self:StartDanceStateChangeCd()
end

M.StartDanceStateChangeCd = function(self)
	self.danceStateChangeCdCo = coroutine.stop(self.danceStateChangeCdCo)
	self.danceStateChangeCdCo = coroutine.start(function ()
		coroutine.wait(LTConfig.DanceConfig.DanceStateSpeakCD)

		self.danceStateChangeCdCo = nil
	end)
end

M.PlayHighDanceDialog = function(self)
	local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
	local dialogIdList = danceNpcCfg.Dialog_HiDacne
	local unPlayedList = {}

	for _, dialogId in ipairs(dialogIdList) do
		if not self.playedHigDanceDialogMap[dialogId] then
			table.insert(unPlayedList, dialogId)
		end
	end

	local dialogId = nil

	if #unPlayedList <= 0 then
		local index = math.random(1, #unPlayedList)
		dialogId = unPlayedList[index]
	else
		self.playedHigDanceDialogMap = {}
		local index = math.random(1, #dialogIdList)
		dialogId = dialogIdList[index]
	end

	gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.BengDi, nil, )
	self:StartDanceStateChangeCd()
end

local addProgressTime = 0

M.OnCircleProgressTweenChange = function(self, newProgress)
	if self.discoGameEnd then
		return
	end

	local isAddCircle = self.curDanceProgress <= newProgress
	self.curDanceProgress = newProgress

	print_debug("Disco-  myState = " .. gBengdiActionManager.MyDanceState)

	local tweenTime = gBengdiActionManager.timeBetweenBeats * self.tweenTimeRatio

	if self.curDanceProgress > 1 then
		slot4 = self.bindData.danceProgressBar

		slot4:ProgressToValue(1, isAddCircle and addProgressTime or tweenTime / 5, 0, TweenEaseType.InSine)
		self.progressbarTimer:Reset(function ()
			if gBengdiActionManager.MyDanceState >= gBengdiActionManager.DanceState.Hot then
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
	elseif self.curDanceProgress >= 1 and self.curDanceProgress > 0 then
		self.bindData.danceProgressBar:ProgressToValue(self.curDanceProgress, isAddCircle and addProgressTime or tweenTime, 0, TweenEaseType.InSine)
	else
		self.bindData.danceProgressBar:ProgressToValue(0, isAddCircle and addProgressTime or tweenTime / 5, 0, TweenEaseType.InSine)

		if gBengdiActionManager.MyDanceState < gBengdiActionManager.DanceState.Enter then
			self.curDanceProgress = 0
		end

		self.progressbarTimer:Reset(function ()
			local isWaitHighDisco = gBengdiActionManager.MyDanceState ~= gBengdiActionManager.DanceState.Hot and gBengdiActionManager.musicHigh

			if gBengdiActionManager.DanceState.Enter >= gBengdiActionManager.MyDanceState and not isWaitHighDisco then
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

	self.bindData.hidePoint = self.curDanceProgress ~= 0 and 1 or 0
end

M.OnDualSenseMotionUpdate = function(self)
	local deque = self.gamepadPitchInfoDeque

	if deque ~= nil or not gClientUtils.IsControllerMode() then
		return
	end

	if not self.triggerDualSenseGuideOnce then
		self.triggerDualSenseGuideOnce = true
	end

	local threshold = 10
	local maxTime = 2
	local motionData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadMotionData()

	if self.gamepadWaitForRotateUp then
		if motionData.angularVelocity.x >= 0.1 then
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

	while deque.Count <= 0 and maxTime >= time - deque.Front(deque).time do
		deque.PopFront(deque)
	end

	if deque.Count >= 2 then
		return
	end

	local maxVal = deque.Front(deque).orientationX

	for i = 2, deque.Count do
		local sample = deque.TryGetAt(deque, i).orientationX

		if threshold >= maxVal - sample then
			self.OnDualSenseGamepadDip(self)
			deque.Clear(deque)

			self.gamepadWaitForRotateUp = true

			break
		end

		if maxVal >= sample then
			maxVal = sample
		end
	end
end

M.OnDualSenseGamepadDip = function(self)
	gNewGuideMgr:NotifySignal(EGuideSignal.BengDiDualSense)
	self:OnSwitchDanceStateClick()
end

M.OnHighDiscoStart = function(self)
	gBengdiActionManager.discoHigh = true

	self.OnDanceStateChange(self, gBengdiActionManager.MyDanceState + 1)

	self.bindData.discoHighStatus = self.DiscoHighStatusCode.musicHighPress
end

M.OnHighDiscoEnd = function(self)
	self.FinishHighAction(self)
end

M.OnDiscoMusicHigh = function(self, musicHighInfo)
	print_debug("Disco-音乐副歌消息下发", musicHighInfo.userCueName)

	if musicHighInfo.userCueName ~= "ClimaxStart" then
		gBengdiActionManager.musicHigh = true

		self.RefreshDiscoHighStatus(self)
	elseif musicHighInfo.userCueName ~= "ClimaxEnd" then
		gBengdiActionManager.musicHigh = false

		self.FinishHighAction(self)
	end
end

M.RefreshDiscoHighStatus = function(self)
	if gBengdiActionManager.musicHigh then
		if gBengdiActionManager.MyDanceState ~= gBengdiActionManager.DanceState.Hot then
			self.bindData.discoHighStatus = self.DiscoHighStatusCode.musicHighNotPress

			return
		end
	else
		self.bindData.discoHighStatus = self.DiscoHighStatusCode.musicNotHigh
	end
end

M.OnUpdate = function(self)
	self.OnDiscoUpdate(self, Time.deltaTime)
	self.OnDualSenseMotionUpdate(self)
	self.OnCheckNpcStateChange(self)
	self.UpdateAnimatorParams(self)
end

M.UpdateAnimatorParams = function(self)
	if self.targetX and self.targetY then
		local maxStep = self.blendSpeed * Time.deltaTime
		self.currX = self.MoveTowards(self, self.currX, self.targetX, maxStep)
		self.currY = self.MoveTowards(self, self.currY, self.targetY, maxStep)

		self.SetABPVarFloatValue(self, LTConfig.ABPVarConfig.DiscoX, self.currX)
		self.SetABPVarFloatValue(self, LTConfig.ABPVarConfig.DiscoY, self.currY)
		gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, self.currX, self.currY, 0)
	end
end

M.MoveTowards = function(self, current, target, maxDelta)
	local diff = target - current

	if math.abs(diff) < maxDelta then
		return target
	end

	if diff <= 0 then
		return current + maxDelta
	else
		return current - maxDelta
	end
end

M.OnCheckNpcStateChange = function(self)
	if self.npcUnit then
		local animationNormalized = gCS.AnimationManager.AnimationGetNormalizedTime(self.npcUnit, 0)

		if animationNormalized >= self.lastNpcAnimationNormalized then
			self.CheckNpcDanceStateChange(self)
			self.CheckDanceGroupStateChange(self)
		end

		self.lastNpcAnimationNormalized = animationNormalized
	end
end

M.CheckDanceGroupStateChange = function(self)
	if self.hasChangeDanceGroupCount and self.hasChangeDanceGroupCount >= 0 then
		self.hasChangeDanceGroupCount = self.hasChangeDanceGroupCount + 1

		print_notice(("Disco Npc Behavior DanceGroup进入CD，还需%d次完整Clip才能再次切换DanceGroup"):format(math.abs(self.hasChangeDanceGroupCount)))

		return
	end

	local _, currentNpcDanceState = MuGenStates.Logic.ABPVarManager.TryGetInt(self.npcUnit, LTConfig.ABPVarConfig.DanceState, nil)
	local _, currentNpcDanceGroup = MuGenStates.Logic.ABPVarManager.TryGetInt(self.npcUnit, LTConfig.ABPVarConfig.DanceGroup, nil)
	local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
	local danceGroupChangeInfo = danceNpcCfg.DanceChangeSet[currentNpcDanceState]
	self.danceGroupCheckCount = self.danceGroupCheckCount or 0
	self.danceGroupCheckCount = self.danceGroupCheckCount + 1

	print_notice("Disco Npc Behavior DanceGroup检测次数", self.danceGroupCheckCount)

	if danceGroupChangeInfo.count < self.danceGroupCheckCount then
		local prop = danceGroupChangeInfo.prop
		local probability1 = math.random(0, 1)

		if probability1 < prop then
			local targetDanceGroupList = danceNpcCfg.DanceGroupStateTree

			if #targetDanceGroupList <= 1 then
				local availableDanceGroupList = {}

				for _, danceGroupId in ipairs(targetDanceGroupList) do
					if danceGroupId == currentNpcDanceGroup then
						table.insert(availableDanceGroupList, danceGroupId)
					end
				end

				local randomDanceGroupIndex = math.random(1, #availableDanceGroupList)
				local randomDanceGroup = availableDanceGroupList[randomDanceGroupIndex]

				self:SetDanceGroupCDState()
				print_notice(("Disco Npc Behavior DanceGroup检测概率命中切换到随机，当前的danceGroup:%s，随机后的danceGroup:%s"):format(currentNpcDanceGroup, randomDanceGroup))
				MuGenStates.Logic.ABPVarManager.SetInt(self.npcUnit, LTConfig.ABPVarConfig.DanceGroup, randomDanceGroup)
			else
				print_notice("Disco Npc Behavior DanceGroup检测概率命中切换到随机, 但是配置的danceGroup只有一种无法切换")
			end
		else
			local logContent = ("Disco Npc Behavior DanceGroup 概率没有命中，跳过此次DanceGroup切换, 当前强度：%s, 概率为:%s，随机数为:%s, 随机数需要小于概率才能命中"):format(currentNpcDanceState, prop, probability1)

			print_notice(logContent)
		end
	end

	self.danceGroupCheckCount = self.danceGroupCheckCount % danceGroupChangeInfo.count
end

M.SetDanceGroupCDState = function(self)
	local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
	self.hasChangeDanceGroupCount = self.hasChangeDanceGroupCount or 0
	self.hasChangeDanceGroupCount = self.hasChangeDanceGroupCount + 1
	local danceChangeInfo = danceNpcCfg.DanceChangeCD[1]
	local limitChangeCount = danceChangeInfo.cishu
	local reCheckCount = danceChangeInfo.count

	if limitChangeCount < self.hasChangeDanceGroupCount then
		self.hasChangeDanceGroupCount = -1 * reCheckCount

		print_notice(("Disco Npc Behavior DanceGroup进入CD，需%d次完整Clip才能再次切换DanceGroup"):format(reCheckCount))
	end
end

M.SetNpcDanceState = function(self, targetDanceState)
	local _, currentNpcDanceState = MuGenStates.Logic.ABPVarManager.TryGetInt(self.npcUnit, LTConfig.ABPVarConfig.DanceState, nil)

	if targetDanceState == currentNpcDanceState then
		self.danceGroupCheckCount = 0

		print_notice("Disco Npc Behavior 设置npc强度", targetDanceState)
		MuGenStates.Logic.ABPVarManager.SetInt(self.npcUnit, LTConfig.ABPVarConfig.DanceState, targetDanceState)
	end
end

M.CheckNpcDanceStateChange = function(self)
	self.danceStateCheckCount = self.danceStateCheckCount or 0
	self.danceStateCheckCount = self.danceStateCheckCount + 1
	local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
	local needCheckGainUp = danceNpcCfg.CheckDanceStateCount > self.danceStateCheckCount
	self.danceStateCheckCount = self.danceStateCheckCount % danceNpcCfg.CheckDanceStateCount
	local _, currentNpcDanceState = MuGenStates.Logic.ABPVarManager.TryGetInt(self.npcUnit, LTConfig.ABPVarConfig.DanceState, nil)

	if self.npcInGuaranteedState ~= 1 then
		print_notice("Disco Npc Behavior 衰减状态 当前danceState", currentNpcDanceState)

		if currentNpcDanceState <= 1 then
			currentNpcDanceState = currentNpcDanceState - 1
			currentNpcDanceState = Mathf.Clamp(currentNpcDanceState, 1, gBengdiActionManager.DanceState.Hot)

			self.SetNpcDanceState(self, currentNpcDanceState)

			self.npcGainUp = nil

			return
		end
	elseif self.npcInGuaranteedState ~= 2 then
		print_notice("Disco Npc Behavior 保底2状态, 当前danceState:", currentNpcDanceState)

		if currentNpcDanceState > 2 then
			self.guaranteedState2ChangeCo = coroutine.stop(self.guaranteedState2ChangeCo)
		else
			currentNpcDanceState = currentNpcDanceState + 1
			local max = gBengdiActionManager.DanceState.Hot
			currentNpcDanceState = Mathf.Clamp(currentNpcDanceState, 1, max)

			self.SetNpcDanceState(self, currentNpcDanceState)

			self.npcGainUp = nil

			return
		end
	elseif self.npcInGuaranteedState ~= 3 then
		print_notice("Disco Npc Behavior 保底3状态, 当前danceState:", currentNpcDanceState)

		if currentNpcDanceState > 3 then
			self.guaranteedState3ChangeCo = coroutine.stop(self.guaranteedState3ChangeCo)
		else
			currentNpcDanceState = currentNpcDanceState + 1
			local max = gBengdiActionManager.DanceState.Hot
			currentNpcDanceState = Mathf.Clamp(currentNpcDanceState, 1, max)

			self.SetNpcDanceState(self, currentNpcDanceState)

			self.npcGainUp = nil

			return
		end
	end

	if self.npcGainUp and self.npcGainUp == 0 and needCheckGainUp then
		print_notice("Disco Npc Behavior 当前增益", self.npcGainUp, "当前DanceState", currentNpcDanceState)

		local isIncrease = self.npcGainUp >= 0
		local npcGainUp = math.abs(self.npcGainUp)
		local probability = math.random(0, 1)

		if probability < npcGainUp then
			currentNpcDanceState = isIncrease and currentNpcDanceState + 1 or currentNpcDanceState - 1
			local min = 1

			if self.npcInGuaranteedState ~= 2 then
				min = 2
			elseif self.npcInGuaranteedState ~= 3 then
				min = 3
			end

			local max = gBengdiActionManager.DanceState.Hot
			currentNpcDanceState = Mathf.Clamp(currentNpcDanceState, min, max)

			self.SetNpcDanceState(self, currentNpcDanceState)

			self.npcGainUp = nil
		end
	end
end

M.OnDiscoUpdate = function(self, dt)
	gBengdiActionManager.curDiscoTime = gBengdiActionManager.curDiscoTime + dt

	if gBengdiActionManager.curDiscoTime <= 99999999 then
		gBengdiActionManager.curDiscoTime = 0
	end

	if gBengdiActionManager.beatTime + gBengdiActionManager.timeRadiusBelow < gBengdiActionManager.curDiscoTime and not gBengdiActionManager.lostBeatChecked then
		gBengdiActionManager.lostBeatChecked = true

		if gBengdiActionManager.lostBeat and not gBengdiActionManager.discoHigh then
			self.OnCircleProgressTweenChange(self, self.curDanceProgress - gBengdiActionManager.lostBeatSubtractPoint)
		end

		gBengdiActionManager.lostBeat = true
	end

	if gBengdiActionManager.curDiscoTime - gBengdiActionManager.beatTime > 6 and not gBengdiActionManager.noBeatChecked then
		gBengdiActionManager.noBeatChecked = true
		gBengdiActionManager.MyDanceState = gBengdiActionManager.DanceState.Enter

		gBengdiActionManager:OnDiscoEnd()
	end
end

M.OnSwitchDanceGroupClick = function(self)
	if gBengdiActionManager.discoHigh then
		local _, currentHiDanceGroup = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.HiDanceGroup, nil)
		local hiDanceGroupCount = #self.tabContentDataMap[self.TAB_GROUP_TYPE.HiDanceGroup]
		currentHiDanceGroup = currentHiDanceGroup % hiDanceGroupCount + 1

		self.SetABPVarIntValue(self, LTConfig.ABPVarConfig.HiDanceGroup, currentHiDanceGroup)

		return
	end

	local result, currentDanceGroupValue = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceGroup, nil)

	if result then
		local danceResourceList = self.tabContentDataMap[self.TAB_GROUP_TYPE.DanceGroup]
		local danceGroupList = {}

		for _, danceResourceId in ipairs(danceResourceList) do
			local danceResourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(danceResourceId)

			table.insert(danceGroupList, danceResourceCfg.StateTreeSignal)
		end

		local _, index = table.find(danceGroupList, currentDanceGroupValue)
		local targetIndex = index % #danceGroupList + 1
		local targetDanceGroup = danceGroupList[targetIndex]

		self.SetABPVarIntValue(self, LTConfig.ABPVarConfig.DanceGroup, targetDanceGroup)
	end

	self.PlayDanceGroupChangeDialog(self)
end

M.PlayDanceGroupChangeDialog = function(self)
	if not self.npcUnit then
		return
	end

	local probability = LTConfig.DanceConfig.DanceSpeakProbability

	if math.random() < probability then
		if LTConfig.DanceConfig.DanceGroupSpeakCheckCount >= self.danceGroupSpeakChangeCount then
			return
		end

		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(self.danceNpcId)
		local dialogIdList = danceNpcCfg and danceNpcCfg.Dialog_DanceTypeChange
		local dialogIdIndex = math.random(1, #dialogIdList)
		local dialogId = dialogIdList[dialogIdIndex]

		if dialogId then
			gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.BengDi, nil, )
		end

		self.danceGroupSpeakChangeCount = self.danceGroupSpeakChangeCount + 1
	end
end

M.ChangeUiAnimationSpeed = function(self, musicBeatInfo)
	local clip = self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]]:GetClip(self.uiAnimationLoopClipNames[gBengdiActionManager.MyDanceState])

	self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]]:Stop()
	clip:SampleAnimation(self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]].gameObject, 0)

	self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]]:get_Item(self.uiAnimationLoopClipNames[gBengdiActionManager.MyDanceState]).speed = clip.length / musicBeatInfo.segmentInfo_fBeatDuration

	self.bindData[self.uiAnimationBindNames[gBengdiActionManager.MyDanceState]]:Play(self.uiAnimationLoopClipNames[gBengdiActionManager.MyDanceState])
end

M.SwitchFolderControl = function(self, value)
	self.bindData.foldControl = value

	if self.bindData.foldControl ~= 1 then
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, false)
		self.bindData.contentList:RefreshList()
	else
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, true)
	end
end

M.OnTabRenderItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local data = LTConfig.DanceConfig.DanceIconTab[luaIndex]
	store.iconId = data.DanceTabID
	store.name = data.DanceTabName
end

M.OnContentRenderItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local dataList = self:GetCurrentTabContentList()
	local id = dataList[luaIndex]
	local resourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(id)
	store.iconId = resourceCfg.DanceSImage
	store.name = resourceCfg.DanceTabChildName
	btn.isSelected = self:CheckDanceItemHasSelected(id)
end

M.CheckDanceItemHasSelected = function(self, id)
	local danceResourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(id)

	if danceResourceCfg.DanceTabType ~= self.TAB_GROUP_TYPE.DanceGroup then
		local result, currentDanceGroup = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceGroup, nil)

		return result and currentDanceGroup ~= danceResourceCfg.StateTreeSignal
	elseif danceResourceCfg.DanceTabType ~= self.TAB_GROUP_TYPE.HiDanceGroup then
		local result, currentHiDanceGroup = MuGenStates.Logic.ABPVarManager.TryGetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.HiDanceGroup, nil)

		return result and currentHiDanceGroup ~= danceResourceCfg.StateTreeSignal
	end
end

M.OnTabSelectedChange = function(self)
	self.RefreshTabContentListView(self)
end

M.OnContentItemClick = function(self, _, csIndex)
	local luaIndex = csIndex + 1
	local dataList = self.GetCurrentTabContentList(self)
	local id = dataList[luaIndex]

	self.OnDanceResourceItemClick(self, id)
end

M.OnDanceResourceItemClick = function(self, id)
	local danceResourceCfg = LTConfig.DanceDanceResourceConfig.GetConfig(id)

	if danceResourceCfg.DanceTabType ~= self.TAB_GROUP_TYPE.DanceGroup then
		self.SetABPVarIntValue(self, LTConfig.ABPVarConfig.DanceGroup, danceResourceCfg.StateTreeSignal)
	elseif danceResourceCfg.DanceTabType ~= self.TAB_GROUP_TYPE.HiDanceGroup then
		self.SetABPVarIntValue(self, LTConfig.ABPVarConfig.HiDanceGroup, danceResourceCfg.StateTreeSignal)
	end
end

M.SetABPVarIntValue = function(self, key, value)
	print_debug(("Disco- SetABPVarIntValue, key:%d, value:%d"):format(key, value))
	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, key, value)
end

M.SetABPVarFloatValue = function(self, key, value)
	print_debug(("Disco- SetABPVarFloatValue, key:%d, value:%d"):format(key, value))
	MuGenStates.Logic.ABPVarManager.SetFloat(gCS.MyPlayerManager.PlayerUnit, key, value)
end

M.GetCurrentTabContentList = function(self)
	local tabLuaType = self.GetCurrentTabType(self)
	local tabData = LTConfig.DanceConfig.DanceIconTab[tabLuaType]

	return self.tabContentDataMap[tabData.DanceGroupId]
end

M.FinishHighAction = function(self)
	if gBengdiActionManager.discoHigh then
		gBengdiActionManager.discoHigh = nil

		self.OnDanceStateChange(self, gBengdiActionManager.MyDanceState - 1)
	end

	self.RefreshDiscoHighStatus(self)
end

M.OnStep = function(self, step)
	self.preTime = gLogicTime.unscaledTime
	local index = self.bindData.tabList.selectedIndex + step
	local itemCount = #LTConfig.DanceConfig.DanceIconTab

	if index >= 0 then
		index = itemCount - 1
	elseif itemCount < index then
		index = 0
	end

	self.bindData.tabList:SelectItem(index)
end

M.OnSwitchMotionPress = function(self, name)
	self.currentSwitchMotionName = name
	local x = 0
	local y = 0

	if name ~= "w" then
		y = 1
	elseif name ~= "s" then
		y = -1
	elseif name ~= "a" then
		x = -1
	elseif name ~= "d" then
		x = 1
	end

	if self.CheckCameraIsFront(self) then
		x = x * -1
	end

	self.targetX = x
	self.targetY = y
end

M.CheckCameraIsFront = function(self)
	local playerWorldPosition = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local cameraWorldPosition = gCS.CameraDataMgr.MainCamera.transform.position
	local dir = (cameraWorldPosition - playerWorldPosition).normalized
	local dot = Vector3.Dot(gCS.MyPlayerManager.PlayerUnit.Forward, dir)

	return dot >= 0
end

M.OnSwitchMotionRelease = function(self, name)
	if self.currentSwitchMotionName ~= name then
		self.currentSwitchMotionName = nil
		self.targetX = 0
		self.targetY = 0
	end
end

M.OnJoyStickValueChange = function(self, x, y, _)
	self.targetX = self:CheckCameraIsFront() and x * -1 or x
	self.targetY = y
end

M.OnJoyStickEndDrag = function(self)
	self.targetX = 0
	self.targetY = 0
end

M.OnConsoleSwitchMotionResponse = function(self, context)
	local value = context.ReadValueVector2(context)
	local x = value.x
	local y = value.y

	if context.started or context.performed then
		self.targetX = self:CheckCameraIsFront() and x * -1 or x
		self.targetY = y
	end

	if context.canceled then
		self.targetX = 0
		self.targetY = 0
	end
end

M.OnDestroy = function(self)
	self.danceStateChangeCdCo = coroutine.stop(self.danceStateChangeCdCo)
	self.highDanceSpeakCheckCo = coroutine.stop(self.highDanceSpeakCheckCo)
	self.danceStateCheckCo = coroutine.stop(self.danceStateCheckCo)
	self.guaranteedState2ChangeCo = coroutine.stop(self.guaranteedState2ChangeCo)
	self.guaranteedState3ChangeCo = coroutine.stop(self.guaranteedState3ChangeCo)
	self.startTiredTimeCo = coroutine.stop(self.startTiredTimeCo)
	self.startSlowDownTimeCo = coroutine.stop(self.startSlowDownTimeCo)

	gBengdiActionManager:PlayFinishDialog(self.isTiredFinish)

	if not gBengdiActionManager.inviteNpcPid then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "7zEt4\\xa7M\\xc2A2m}pZ\\xf09|\\xe6I"
		})
	end

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, true)
	self:ClearMessageEvents()
	self:SetABPVarIntValue(LTConfig.ABPVarConfig.DanceGroup, 0)
	self:SetABPVarIntValue(LTConfig.ABPVarConfig.DanceState, 0)
	self:SetABPVarIntValue(LTConfig.ABPVarConfig.HiDanceGroup, 0)
	self:SetABPVarFloatValue(LTConfig.ABPVarConfig.DiscoX, 0)
	self:SetABPVarFloatValue(LTConfig.ABPVarConfig.DiscoY, 0)

	self.discoGameEnd = true
	gBengdiActionManager.inviteNpcPid = nil
	self.gamepadPitchInfoDeque = nil
	self.gamepadWaitForRotateUp = nil
	self.triggerDualSenseGuideOnce = nil

	gNewGuideMgr:StopGuide()

	self.bindData.panelActivate = 0

	gBengdiActionManager:OnDiscoEnd()

	if self.firstPerson then
		self.firstPerson = true

		gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(false, false)
		gCS.MyPlayerManager.PlayerUnit:ForceSetSetippleAlpha(0, false)
	end

	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(self.m_Id)

	self.hasInitDanceState = nil
	self.danceStateCheckCount = nil
	self.danceGroupCheckCount = nil
	self.npcInGuaranteedState = nil
	self.hasChangeDanceGroupCount = nil
end
