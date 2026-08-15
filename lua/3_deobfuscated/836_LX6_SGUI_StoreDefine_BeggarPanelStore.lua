local BeggarConfig = LTConfig.BeggarConfig
local BeggarBeggarPointConfig = LTConfig.BeggarBeggarPointConfig
C_BeggarPanelStore = DefClass("C_BeggarPanelStore", C_BeggarPanelStore, C_StoreGroup)
GroupName2Class.BeggarPanelStore = C_BeggarPanelStore
local M = C_BeggarPanelStore
local GameplayEvent = MuGenStates.Logic.GameplayEvent
local MyPlayerManager = gCS.MyPlayerManager

function M:ctor()
	self.gamepadMode = false
	self.gamepadUpdateRotate = false
	self.rotateCameraContext = 1
	self.rightStickValue = {
		x = 0,
		y = 0
	}
end

function M:OnAwake()
	self.STAGE_TYPE = {
		WAIT_END_ANIM_END = 2,
		WAIT_BEGGING = 0,
		BEGGING = 1,
		WAIT_ENTER_ANIM_END = 3
	}
	self.BEG_ACTION = {
		HAND = 1,
		PLAY_ERHU = 4,
		KOWTOW = 2,
		DANCE = 5,
		LIE_DOWN = 3
	}
	self.PANEL_STAGE = {
		Finish = 1,
		Begging = 0
	}
	self.NPC_DIALOG_STAGE = {
		IN_DIALOG = 1,
		WAIT_START = 0,
		WAIT_NEXT = 2
	}
	self.msgEvents = {
		[gEventConstants.DIALOG_END] = function (eventId, FirstDialogId)
			if FirstDialogId == self.currentWaitDialog then
				self:OnWaitDialogEnd()
			end
		end
	}

	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.btnHand.luaClick = self:CreateAction("OnBtnHandClick")
	self.bindData.btnKowtow.luaClick = self:CreateAction("OnBtnKowtowClick")
	self.bindData.btnLieDown.luaClick = self:CreateAction("OnBtnLieDownClick")
	self.bindData.btnPlayErhu.luaClick = self:CreateAction("OnBtnPlayErhuClick")
	self.bindData.btnDance.luaClick = self:CreateAction("OnBtnPlayDanceClick")
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self:CreateAction("OnGamepadStickControl")
	self.beggingActionUnlockState = {
		[self.BEG_ACTION.HAND] = {
			unLock = false,
			btn = self.bindData.btnHand
		},
		[self.BEG_ACTION.KOWTOW] = {
			unLock = false,
			btn = self.bindData.btnKowtow
		},
		[self.BEG_ACTION.LIE_DOWN] = {
			unLock = false,
			btn = self.bindData.btnLieDown
		},
		[self.BEG_ACTION.PLAY_ERHU] = {
			unLock = false,
			btn = self.bindData.btnPlayErhu
		},
		[self.BEG_ACTION.DANCE] = {
			unLock = false,
			btn = self.bindData.btnDance
		}
	}
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
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
	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	gBeggarManager:OnInit()
	gBeggarManager:SetPanelShown(true)

	self.gameplayHud = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if self.gameplayHud then
		self.gameplayHud:RegisterBtnBackCallback(function ()
			local beggarPanel = gStoreManager:GetStoreGroup("BeggarPanelStore")

			if beggarPanel then
				beggarPanel:OnBtnBackCallback()
			end
		end)
	end

	self:InitBeggar(data)
	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.BeggarWait)
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(BeggarConfig.FreeLockActionStatusId, BeggarConfig.FreeLockActionSwitchTime, nil, 5)
end

function M:OnClose()
	self.gameplayHud.bindData.btnExit.interactable = true
	self.gameplayHud = nil
	local needSendMessage = gBeggarManager.isPanelShown

	gBeggarManager:SetPanelShown(false)

	self.beggingActionUnlockState = nil

	if self.currentStage == self.STAGE_TYPE.WAIT_BEGGING then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.BeggarEnd)
	elseif self.currentStage == self.STAGE_TYPE.BEGGING then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.BeggarSwitch)
	end

	local gameplayHud = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if gameplayHud then
		gameplayHud:RegisterBtnBackCallback(nil)
	end

	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(BeggarConfig.FreeLockActionSwitchTime, nil, 5)

	if needSendMessage then
		gMessageManager:SendMessage(gEventConstants.BEGGAR_END, self.spot or 1)
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnUpdate()
	if self.currentStage ~= self.STAGE_TYPE.WAIT_BEGGING or not self.isFinished then
		if self.startTime and not self.isFinished then
			local deltaTime = os.time() - self.startTime
			self.bindData.countDownTime = self:GetTimeString(deltaTime)
		end

		if self.lastDialogEndTime and not self.isFinished then
			if self.npcDialogStage == self.NPC_DIALOG_STAGE.WAIT_NEXT then
				local deltaTime = os.time() - self.lastDialogEndTime

				if self.dialogCD < deltaTime then
					self.lastDialogEndTime = nil

					self:ShowNextDialog()
				end
			else
				self.lastDialogEndTime = nil
			end
		end
	end

	if self.finishTime then
		local deltaTime = os.time() - self.finishTime

		if self.closeTime < deltaTime then
			self.finishTime = nil

			gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
		end
	end

	if self.gamepadMode then
		self:UpdateCameraRotateGamePad()
	end
end

function M:InitBeggar(data)
	self.spot = data or 1
	local spotCfg = BeggarBeggarPointConfig.GetConfig(self.spot)
	self.spotPos = spotCfg and spotCfg.Position

	if self.spotPos then
		self.spotPos = Vector3.New(self.spotPos[1], self.spotPos[2], self.spotPos[3])
	end

	local playerPos = MyPlayerManager.PlayerUnit.Position
	self.selfPos = Vector3.New(playerPos.X, playerPos.Y, playerPos.Z)
	self.selfDir = Vector3.Normalize(self.spotPos - self.selfPos)
	self.selfRot = Quaternion.LookRotation(self.selfDir)
	self.currentStage = self.STAGE_TYPE.WAIT_BEGGING
	self.finishPanelShown = nil
	self.targetBeggingAction = nil
	self.currentBeggingAction = nil
	self.startTime = nil
	self.lastDialogEndTime = nil
	self.currentDialogTypeId = nil
	self.currentWaitDialog = nil
	self.targetDialogTypeId = nil
	self.stopBegTime = nil
	self.exp = 0
	self.totalReward = 0
	self.isBegged = false
	self.isFinished = false
	self.closeTime = BeggarConfig.CloseTime or 1
	self.dialogCD = BeggarConfig.DialogCD or 3
	self.npcDialogStage = self.NPC_DIALOG_STAGE.WAIT_START
	self.finishTime = nil
	self.debugSyncData = false

	for _, value in pairs(self.BEG_ACTION) do
		local cfg = BeggarConfig.GetConfig(value)

		if cfg then
			local enableState = false

			if cfg.BadgeId and cfg.BadgeId > 0 then
				enableState = gSpiritJobManager:CheckCurSpiritContainBadge(cfg.BadgeId)
			else
				enableState = true
			end

			self.beggingActionUnlockState[value].unLock = enableState
			self.beggingActionUnlockState[value].btn.interactable = enableState
		end
	end

	self.bindData.countDownTime = "00:00"
	self.bindData.stage = self.PANEL_STAGE.Begging

	if not self.randomDialogMgr then
		self.randomDialogMgr = C_RandomDialogManager.new(LTConfig.BeggarRandomSelectionConfig, "BeggarRandomSelectionConfig")
	end

	self.bindData.ScrollGroup:SetToStartNum()
end

function M:RefreshBtnState()
	for _, value in pairs(self.beggingActionUnlockState) do
		value.btn.interactable = value.unLock
	end

	self.gameplayHud.bindData.btnExit.interactable = true
end

function M:OnStateTreeEnterWaitLoop()
	self.currentStage = self.STAGE_TYPE.WAIT_BEGGING

	if self.isFinished then
		self:OnFinishBegging()
	elseif self.targetBeggingAction then
		self:SwitchBeggingAction()
		self:RequestBegAction(UX.Game.BegBehaviorType.SwitchPose)
	else
		self:RefreshBtnState()
	end
end

function M:OnStateTreeEnterBeggingLoop()
	self.currentStage = self.STAGE_TYPE.BEGGING

	if self.isFinished then
		self:OnFinishBegging()
	elseif not self.targetBeggingAction then
		self:RefreshBtnState()
	end
end

function M:OnBtnHandClick()
	self:OnSwitchBeggingActionClick(self.BEG_ACTION.HAND)
end

function M:OnBtnKowtowClick()
	self:OnSwitchBeggingActionClick(self.BEG_ACTION.KOWTOW)
end

function M:OnBtnLieDownClick()
	self:OnSwitchBeggingActionClick(self.BEG_ACTION.LIE_DOWN)
end

function M:OnBtnPlayErhuClick()
	self:OnSwitchBeggingActionClick(self.BEG_ACTION.PLAY_ERHU)
end

function M:OnBtnPlayDanceClick()
	self:OnSwitchBeggingActionClick(self.BEG_ACTION.DANCE)
end

function M:OnSwitchBeggingActionClick(targetAction)
	local actionState = self.beggingActionUnlockState[targetAction]

	if actionState and actionState.unLock then
		if self.currentBeggingAction ~= targetAction and not self.targetBeggingAction then
			for _, value in pairs(self.beggingActionUnlockState) do
				value.btn.interactable = false
			end

			self.gameplayHud.bindData.btnExit.interactable = false

			if self.currentStage == self.STAGE_TYPE.WAIT_BEGGING or self.currentStage == self.STAGE_TYPE.BEGGING then
				if self.currentBeggingAction then
					self.targetBeggingAction = targetAction
					self.currentStage = self.STAGE_TYPE.WAIT_END_ANIM_END

					gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.BeggarSwitch)
				else
					self.targetBeggingAction = targetAction

					self:SwitchBeggingAction()
					self:RequestBegAction(UX.Game.BegBehaviorType.Start)

					self.startTime = os.time()
					self.isBegged = true

					self.bindData.countDown.anim:Play()
					gBeggarManager:ActivateRelatedAP(self.spot)
				end
			elseif self.currentStage == self.STAGE_TYPE.WAIT_BEGGING and self.currentBeggingAction and self.targetBeggingAction and self.currentBeggingAction ~= self.targetBeggingAction then
				gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.BeggarSwitch)
			end
		end
	else
		print_error("乞讨动作未解锁，按钮点击调用异常", targetAction)
	end
end

function M:SwitchBeggingAction()
	if self.targetBeggingAction then
		self.currentStage = self.STAGE_TYPE.WAIT_ENTER_ANIM_END
		local target = GameplayEvent.BeggarHand - 1 + self.targetBeggingAction
		self.currentBeggingAction = self.targetBeggingAction
		local id = self.targetBeggingAction
		self.targetBeggingAction = nil
		local relativePos = 1 - BeggarConfig.GetConfig(id).Pos
		local targetPos = self.selfDir * relativePos + self.selfPos
		local rotation = self.selfRot

		FrameTimer.New(function ()
			LX6.PaoKu.EntrySystemManager.SetDestAndSendGameplayEvent(MyPlayerManager.PlayerUnit, target, nil, targetPos, rotation)
		end, 1):Start()
	end
end

function M:RequestBegAction(behaviorType)
	if self.currentBeggingAction and self.spot then
		gClientToGameDelegate:AskBegBehavior(self.currentBeggingAction, self.spot, behaviorType).Callback = function (err, data)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end
	end
end

function M:OnSyncData(data)
	local newTotalReward = data.TotalReward + data.TotalRewardFromPlayer

	if not self.isFinished then
		self:ChangeDialog(data.DialogId)
		self:ChangeReward(newTotalReward)
		gBeggarManager:OnSpotDataChange(self.spot, data.NpcGatherLimit, data.NpcGatherRate, data.NpcIds)
	else
		self.totalReward = newTotalReward
	end

	self.exp = data.Exp

	if self.debugSyncData then
		local deltaTime = data.LastUpdateTime - data.StartTime

		print_notice("乞丐同步数据，持续时间： ", deltaTime, ",奖励：", newTotalReward, ",exp=", self.exp)
	end
end

function M:ChangeReward(newTotalReward)
	local delta = newTotalReward - self.totalReward

	if delta > 0 then
		self.bindData.moneyText = tostring(delta)
		local scrollNum = self.bindData.ScrollGroup
		scrollNum.startNum = self.totalReward
		scrollNum.targetNum = newTotalReward
		self.totalReward = newTotalReward

		scrollNum:SetToStartNum()
		scrollNum:Play()
		self.bindData.plus.anim:Stop()
		self.bindData.plus.anim:Play()
	end
end

function M:ChangeDialog(newDialogId)
	self.currentDialogTypeId = newDialogId

	if self.npcDialogStage == self.NPC_DIALOG_STAGE.WAIT_START then
		self.currentWaitDialog = self.randomDialogMgr:ShowDialog(self.currentDialogTypeId, gDialogSource.Beggar)

		if self.currentWaitDialog then
			self.npcDialogStage = self.NPC_DIALOG_STAGE.IN_DIALOG
		end
	end
end

function M:OnWaitDialogEnd()
	if self.npcDialogStage == self.NPC_DIALOG_STAGE.IN_DIALOG and not self.isFinished then
		self.lastDialogEndTime = os.time()
		self.npcDialogStage = self.NPC_DIALOG_STAGE.WAIT_NEXT
	end
end

function M:ShowNextDialog()
	self.currentWaitDialog = self.randomDialogMgr:ShowDialog(self.currentDialogTypeId, gDialogSource.Beggar)

	if self.currentWaitDialog then
		self.npcDialogStage = self.NPC_DIALOG_STAGE.IN_DIALOG
	else
		self.npcDialogStage = self.NPC_DIALOG_STAGE.WAIT_START
	end
end

function M:OnStopBegging()
	self.targetBeggingAction = nil
	self.isFinished = true
	self.stopBegTime = os.time()

	for _, value in pairs(self.beggingActionUnlockState) do
		value.btn.interactable = false
	end

	self.gameplayHud.bindData.btnExit.interactable = false
end

function M:OnFinishBegging()
	self.gameplayHud.bindData.btnExit.interactable = true
	self.finishPanelShown = true
	self.finishTime = os.time()
	self.bindData.stage = self.PANEL_STAGE.Finish
	local stopBegTime = self.stopBegTime or os.time()
	self.bindData.finishTime = self.startTime and self:GetTimeString(stopBegTime - self.startTime) or "00:00"
	local spotCfg = BeggarBeggarPointConfig.GetConfig(self.spot or 1)
	self.bindData.spotLocation = spotCfg and spotCfg.Name or "invalid"
	self.bindData.finishReward = self.totalReward and tostring(self.totalReward) or "0"
	self.bindData.exeText = string.format(BeggarConfig.ExeFormatText, self.exp or 0)
end

function M:GetTimeString(deltaTime)
	local hour = math.floor(deltaTime / 3600)
	local min = math.floor((deltaTime - hour * 3600) / 60)
	local second = math.floor(deltaTime % 60)

	if hour > 0 then
		return string.format("%02d:%02d:%02d", hour, min, second)
	else
		return string.format("%02d:%02d", min, second)
	end
end

function M:IsEndBegging()
	return self.isFinished
end

function M:OnBtnBackCallback()
	if self.currentStage == self.STAGE_TYPE.BEGGING then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.BeggarSwitch)
	end

	if not self.isFinished then
		self:OnStopBegging()

		if self.isBegged then
			self:RequestBegAction(UX.Game.BegBehaviorType.Stop)
			self.bindData.countDown.anim:Stop()
			gBeggarManager:InactivateRelatedAP(self.spot)
		else
			self.gameplayHud.bindData.btnExit.interactable = true

			self:OnFinishBegging()
		end
	elseif self.finishPanelShown then
		gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	end
end

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(self.rotateCameraContext, self.rightStickValue.x, self.rightStickValue.y)
end

function M:OnGamepadStickControl(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.gamepadUpdateRotate = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.gamepadUpdateRotate = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(self.rotateCameraContext, 0, 0)
	end
end
