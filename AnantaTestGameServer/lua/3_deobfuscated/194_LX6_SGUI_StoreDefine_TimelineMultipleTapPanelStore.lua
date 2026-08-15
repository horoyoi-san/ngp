local InputSGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
C_TimelineMultipleTapPanelStore = DefClass("C_TimelineMultipleTapPanelStore", C_TimelineMultipleTapPanelStore, C_StoreGroup)
GroupName2Class.TimelineMultipleTapPanelStore = C_TimelineMultipleTapPanelStore
local M = C_TimelineMultipleTapPanelStore

function M:OnAwake()
	self.clickState = {
		ClickFailed = 2,
		ClickSucceed = 1,
		No = 0
	}
	self.circleAnimName = "S_Vx_TimelineTapPanel_ClickOffset"
	self.openAnimName = "S_Vx_TimelineClickTimeScalePanel_open"
	self.clickAnimName_mouse = "S_Vx_TimelineMultipleTapPanel_Mouse_Click"
	self.clickAnimName = "S_Vx_TimelineClickTimeScalePanel_Click"
	self.finishAnimName = "S_Vx_TimelineClickTimeScalePanel_Finish"
	self.failAnimName = "S_Vx_TimelineClickTimeScalePanel_Fail"
	self.comboHintAnimName = "S_Vx_TimelineTapPanel_Liandian"
	self.finishAnimName_combo = "S_Vx_TimelineTapPanel_Finish_lianji"
	self.lineOpenAnimName = "S_Vx_TimelineMultipleTapPanel_LineOpen"
	self.lineCloseAnimName = "S_Vx_TimelineMultipleTapPanel_LineClose"
	self.jumpTarget = nil
	self.remainBtn = 0
	self.branches = {}
	self.branchDatas = {}
	self.btn1_store = nil
	self.btn1_posType = 0
	self.btn1_progressType = 0
	self.btn1_countDown_timer = 0
	self.btn1_countDown_duration = 0
	self.btn1_countDown_perfect = 0.2
	self.countDown_additive = 0.3
	self.btn1_countDown_anim = 0.2
	self.btn1_clickCounter = 0
	self.btn1_tapTimes = 5
	self.btn1_showProgress = false
	self.btn1_currentState = self.clickState.No
	self.btn1_passed = false
	self.btn2_store = nil
	self.btn2_posType = 0
	self.btn2_progressType = 0
	self.btn2_countDown_timer = 0
	self.btn2_countDown_duration = 0
	self.btn2_countDown_perfect = 0.2
	self.btn2_countDown_anim = 0.2
	self.btn2_clickCounter = 0
	self.btn2_tapTimes = 5
	self.btn2_showProgress = false
	self.btn2_currentState = self.clickState.No
	self.btn2_passed = false
	self.finishCondition = nil
	self.customCount = 0
	self.callback = nil
end

function M:SetTapType(panelData)
	self.btn1_store.tapType = panelData.ShowComboHint1 and 1 or 0
	self.btn2_store.tapType = panelData.ShowComboHint2 and 1 or 0
end

function M:OnShow(panelId, data)
	if gTimelineManager.mulQteCloseTimer then
		gTimelineManager.mulQteCloseTimer:Stop()

		gTimelineManager.mulQteCloseTimer = nil
	end

	local panelData = data:ToTable()
	self.btn1_store = self:GetBtnStore(self.bindData.btn1)

	self:Btn1_SetProgressType(panelData)
	self:Btn1_SetPos(panelData)
	self:Btn1_SetBtnMode(panelData)

	self.btn1_store.clickBtn.luaClick = self:CreateAction("Btn1_OnBtnClick")
	self.btn1_passed = false
	self.btn1_store.clickSoundId = panelData.btn1_clickSoundId
	self.btn1_store.successSoundId = panelData.btn1_successSoundId
	self.btn1_store.failSoundId = panelData.btn1_failSoundId
	self.btn1_store.countdownSoundId = panelData.btn1_countdownSoundId
	self.btn2_store = self:GetBtnStore(self.bindData.btn2)

	self:Btn2_SetProgressType(panelData)
	self:Btn2_SetPos(panelData)
	self:Btn2_SetBtnMode(panelData)

	self.btn2_store.clickBtn.luaClick = self:CreateAction("Btn2_OnBtnClick")
	self.btn2_passed = false
	self.btn2_store.clickSoundId = panelData.btn2_clickSoundId
	self.btn2_store.successSoundId = panelData.btn2_successSoundId
	self.btn2_store.failSoundId = panelData.btn2_failSoundId
	self.btn2_store.countdownSoundId = panelData.btn2_countdownSoundId

	if panelData.btn1_pos == "pos3" and panelData.btn2_pos == "pos4" then
		self.bindData.showLines = 1

		self:PlayLineAnim(true)
	else
		self.bindData.showLines = 0
	end

	self:SetProgressType(panelData)

	self.finishCondition = panelData.finishCondition
	self.customCount = panelData.customCount
	self.qteType = panelData.qteType
	self.mCallback = panelData.mCallback
	self.sCallback = panelData.sCallback
	self.fCallback = panelData.fCallback
	self.allFinishCb = panelData.allFinishCb
	self.closePanel = self.qteType == 4 or self.qteType == 5
	self.btn1_store.successState = false
	self.btn2_store.successState = false

	self:SetTapType(panelData)

	local openAnimLength = self:PlayOpenAnim(self.btn1_store)

	self:PlayOpenAnim(self.btn2_store)
	self:PlayOpenAnim(self.btn1_store)

	if not openAnimLength or openAnimLength == 0 then
		self.openAnimTimer = nil
	else
		self.openAnimTimer = Timer.New(function ()
			self.openAnimTimer = nil
		end, openAnimLength):Start()
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.showLeftGuide = panelData.showGuide and 1 or 0
	end
end

function M:OnUpdate()
	self:Btn1_UpdatePos()
	self:Btn2_UpdatePos()
	self:Btn1_UpdateCountDown()
	self:Btn2_UpdateCountDown()
end

function M:Btn1_SetProgressType(panelData)
	self.btn1_progressType = panelData.btn1_progressType

	if self.btn1_progressType == 1 then
		self.btn1_store.progressType = 1
		self.btn1_countDown_duration = panelData.duration
		self.btn1_countDown_perfect = panelData.btn1_perfectTime
		local clip = self.btn1_store.circleShowAnim:GetClip(self.circleAnimName)

		if clip then
			self.btn1_countDown_anim = clip.length
		else
			self.btn1_countDown_anim = 0.1
		end

		self.btn1_countDown_timer = 0
		self.btn1_currentState = self.clickState.No
	elseif self.btn1_progressType == 2 then
		self.btn1_store.progressType = 2
		self.btn1_showProgress = true
		self.btn1_currentState = self.clickState.ClickSucceed
	elseif self.btn1_progressType == 3 then
		self.btn1_store.progressType = 2
		self.btn1_showProgress = false
		self.btn1_currentState = self.clickState.ClickSucceed
	else
		self.btn1_store.progressType = 0
		self.btn1_currentState = self.clickState.ClickSucceed
	end
end

function M:SetProgressType(panelData)
	if panelData.progressType then
		self.btn2_progressType = panelData.progressType
		self.btn1_progressType = panelData.progressType

		if self.btn2_progressType == 1 then
			self.btn1_store.progressType = 1
			self.btn1_currentState = self.clickState.ClickSucceed
			self.btn2_store.progressType = 1
			self.btn2_currentState = self.clickState.ClickSucceed
		elseif self.btn2_progressType == 2 then
			self.btn1_store.progressType = 2
			self.btn1_showProgress = true
			self.btn1_currentState = self.clickState.ClickSucceed
			self.btn2_store.progressType = 2
			self.btn2_showProgress = true
			self.btn2_currentState = self.clickState.ClickSucceed
		elseif self.btn2_progressType == 3 then
			self.btn1_store.progressType = 2
			self.btn1_showProgress = false
			self.btn1_currentState = self.clickState.ClickSucceed
			self.btn2_store.progressType = 2
			self.btn2_showProgress = false
			self.btn2_currentState = self.clickState.ClickSucceed
		elseif self.btn2_progressType == 4 then
			self.btn1_store.progressType = 3
			self.btn1_showProgress = false
			self.btn1_currentState = self.clickState.ClickSucceed
			self.btn2_store.progressType = 3
			self.btn2_showProgress = false
			self.btn2_currentState = self.clickState.ClickSucceed
		else
			self.btn1_store.progressType = 0
			self.btn1_currentState = self.clickState.ClickSucceed
			self.btn2_store.progressType = 0
			self.btn2_currentState = self.clickState.ClickSucceed
		end
	end
end

function M:Btn2_SetProgressType(panelData)
	self.btn2_progressType = panelData.btn2_progressType

	if self.btn2_progressType == 1 then
		self.btn2_store.progressType = 1
		self.btn2_countDown_duration = panelData.duration
		self.btn2_countDown_perfect = panelData.btn2_perfectTime
		local clip = self.btn2_store.circleShowAnim:GetClip(self.circleAnimName)

		if clip then
			self.btn2_countDown_anim = clip.length
		else
			self.btn2_countDown_anim = 0.1
		end

		self.btn2_countDown_timer = 0
		self.btn2_currentState = self.clickState.No
	elseif self.btn2_progressType == 2 then
		self.btn2_store.progressType = 2
		self.btn2_showProgress = true
		self.btn2_currentState = self.clickState.ClickSucceed
	elseif self.btn2_progressType == 3 then
		self.btn2_store.progressType = 2
		self.btn2_showProgress = false
		self.btn2_currentState = self.clickState.ClickSucceed
	else
		self.btn2_store.progressType = 0
		self.btn2_currentState = self.clickState.ClickSucceed
	end
end

function M:Btn1_SetProgress(progress)
	if self.btn1_progressType == 4 then
		self.btn1_store.countdownProgressImage.fillAmount = progress
	else
		self.btn1_store.progressImage.fillAmount = progress
	end
end

function M:Btn2_SetProgress(progress)
	if self.btn2_progressType == 4 then
		self.btn2_store.countdownProgressImage.fillAmount = progress
	else
		self.btn2_store.progressImage.fillAmount = progress
	end
end

function M:Btn1_UpdateCountDown()
	if self.btn1_progressType == 1 then
		local startTime = 0.23333333333333334

		if startTime < self.btn1_countDown_timer and self.btn1_countDown_timer < self.btn1_countDown_duration - self.btn1_countDown_perfect then
			if not self.btn1_store.countdownSoundPlaying then
				if self.btn1_store.countdownSoundId and self.btn1_store.btn1_countdownSoundId ~= 0 then
					LX6.Audio.AudioManager.Instance.Instance:PlaySound(self.btn1_store.btn1_countdownSoundId)
				end

				self.btn1_store.countdownSoundPlaying = true
			end

			local outerWidth = self.btn1_store.outCircleRT.rect.width
			local innerWidth = self.btn1_store.innerCircleRT.rect.width
			local weight = (self.btn1_countDown_timer - startTime) / (self.btn1_countDown_duration - self.btn1_countDown_perfect - startTime)
			self.btn1_store.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1), weight)
		elseif self.btn1_countDown_timer >= self.btn1_countDown_duration - self.btn1_countDown_perfect then
			-- Nothing
		end

		if self.btn1_countDown_timer <= startTime then
			self.btn1_currentState = self.clickState.No
		elseif self.btn1_countDown_timer < self.btn1_countDown_duration - self.btn1_countDown_perfect - self.countDown_additive then
			self.btn1_currentState = self.clickState.ClickFailed
		else
			self.btn1_currentState = self.clickState.ClickSucceed
		end

		self.btn1_countDown_timer = self.btn1_countDown_timer + gLogicTime.deltaTime
	end
end

function M:Btn2_UpdateCountDown()
	if self.btn2_progressType == 1 then
		local startTime = 0.23333333333333334

		if startTime < self.btn2_countDown_timer and self.btn2_countDown_timer < self.btn2_countDown_duration - self.btn2_countDown_perfect then
			local outerWidth = self.btn2_store.outCircleRT.rect.width
			local innerWidth = self.btn2_store.innerCircleRT.rect.width
			local weight = (self.btn2_countDown_timer - startTime) / (self.btn2_countDown_duration - self.btn2_countDown_perfect - startTime)
			self.btn2_store.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1), weight)
		end

		if self.btn2_countDown_timer <= self.countDown_anim then
			self.btn2_currentState = self.clickState.No
		elseif self.btn2_countDown_timer < self.btn2_countDown_duration - self.btn2_countDown_perfect - self.countDown_additive then
			self.btn2_currentState = self.clickState.ClickFailed
		else
			self.btn2_currentState = self.clickState.ClickSucceed
		end

		self.btn2_countDown_timer = self.btn2_countDown_timer + gLogicTime.deltaTime
	end
end

function M:Btn1_SetPos(panelData)
	self.btn1_posType = panelData.btn1_pos

	if self.btn1_posType == "Custom" then
		self.btn1_targetPos = panelData.btn1_customPos
		self.btn1_customPosOffset = panelData.btn1_customPosOffset
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.btn1_store.buttonRTParent, self.btn1_targetPos.position)
		self.btn1_store.buttonRT.anchoredPosition = uiPos + self.btn1_customPosOffset
	elseif self.bindData[self.btn1_posType] then
		self.btn1_targetPos = self.bindData[self.btn1_posType]
		self.btn1_store.buttonRT.anchoredPosition = self.btn1_targetPos.anchoredPosition
	end
end

function M:Btn2_SetPos(panelData)
	self.btn2_posType = panelData.btn2_pos

	if self.btn2_posType == "Custom" then
		self.btn2_targetPos = panelData.btn2_customPos
		self.btn2_customPosOffset = panelData.btn2_customPosOffset
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.btn2_store.buttonRTParent, self.btn2_targetPos.position)
		self.btn2_store.buttonRT.anchoredPosition = uiPos + self.btn2_customPosOffset
	elseif self.bindData[self.btn2_posType] then
		self.btn2_targetPos = self.bindData[self.btn2_posType]
		self.btn2_store.buttonRT.anchoredPosition = self.btn2_targetPos.anchoredPosition
	end
end

function M:Btn1_UpdatePos()
	if self.btn1_posType == "Custom" and self.btn1_targetPos and self.btn1_store.buttonRTParent then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.btn1_store.buttonRTParent, self.btn1_targetPos.position)
		self.btn1_store.buttonRT.anchoredPosition = uiPos + self.btn1_customPosOffset
	end
end

function M:Btn2_UpdatePos()
	if self.btn2_posType == "Custom" and self.btn2_targetPos and self.btn2_store.buttonRTParent then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.btn2_store.buttonRTParent, self.btn2_targetPos.position)
		self.btn2_store.buttonRT.anchoredPosition = uiPos + self.btn2_customPosOffset
	end
end

function M:Btn1_SetBtnMode(panelData)
	self.btn1_clickCounter = 0
	self.btn1_tapTimes = panelData.btn1_tapTimes
	self.btn1_store.progressImage.fillAmount = 0

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local pcKey = panelData.btn1_pcKey
	local controllerKey = panelData.btn1_controllerKey
	local controllerStyle = panelData.btn1_controllerStyle

	if pcKey then
		self.btn1_store.clickBtn:SetPCKeyInfoWithOutTip(pcKey)

		if pcKey == 8 then
			self.btn1_store.pcKeyMode = 0
		elseif pcKey == 9 then
			self.btn1_store.pcKeyMode = 1
		else
			local cfg = InputSGUIPCKeyConfig.GetConfig(pcKey)
			local pcKeyIconIndex = panelData.btn1_pcKeyIconIndex

			if cfg and pcKeyIconIndex < #cfg.ButtonIcon then
				self.btn1_store.pcKeyMode = 2
				self.btn1_store.btnIcon = cfg.ButtonIcon[pcKeyIconIndex + 1]
			else
				self.btn1_store.pcKeyMode = 3
				self.btn1_store.btnText = cfg.ButtonName
			end
		end
	end

	self.bindData.navArea:ChangeActionIdByResponse(self.btn1_store.clickBtn, controllerKey)

	if self.btn1_store.controllerImg then
		self.btn1_store.controllerImg:ChangeImageAction(controllerKey, 0, self.btn1_store.clickBtn, 0, controllerStyle)
	end

	if self.btn1_store.deviceIconSwitch then
		self.btn1_store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", controllerKey, controllerStyle)
	end
end

function M:Btn2_SetBtnMode(panelData)
	self.btn2_clickCounter = 0
	self.btn2_tapTimes = panelData.btn2_tapTimes
	self.btn2_store.progressImage.fillAmount = 0

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local pcKey = panelData.btn2_pcKey
	local controllerKey = panelData.btn2_controllerKey
	local controllerStyle = panelData.btn2_controllerStyle

	if pcKey then
		self.btn2_store.clickBtn:SetPCKeyInfoWithOutTip(pcKey)

		if pcKey == 8 then
			self.btn2_store.pcKeyMode = 0
		elseif pcKey == 9 then
			self.btn2_store.pcKeyMode = 1
		else
			local cfg = InputSGUIPCKeyConfig.GetConfig(pcKey)
			local pcKeyIconIndex = panelData.btn2_pcKeyIconIndex

			if cfg and pcKeyIconIndex < #cfg.ButtonIcon then
				self.btn2_store.pcKeyMode = 2
				self.btn2_store.btnIcon = cfg.ButtonIcon[pcKeyIconIndex + 1]
			else
				self.btn2_store.pcKeyMode = 3
				self.btn2_store.btnText = cfg.ButtonName
			end
		end
	end

	self.bindData.navArea:ChangeActionIdByResponse(self.btn2_store.clickBtn, controllerKey)

	if self.btn2_store.controllerImg then
		self.btn2_store.controllerImg:ChangeImageAction(controllerKey, 0, self.btn2_store.clickBtn, 0, controllerStyle)
	end

	if self.btn2_store.deviceIconSwitch then
		self.btn2_store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", controllerKey, controllerStyle)
	end
end

function M:Btn1_OnBtnClick()
	if self.btn1_currentState == self.clickState.No then
		return
	end

	if self.openAnimTimer then
		self.openAnimTimer:Stop()
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)
end

function M:Btn2_OnBtnClick()
	if self.btn2_currentState == self.clickState.No then
		return
	end

	if self.openAnimTimer then
		self.openAnimTimer:Stop()
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 2)
end

function M:OnQTEFinished_S()
	if self.sCallback then
		if type(self.sCallback) == "function" then
			self.sCallback()
		elseif type(self.sCallback) == "userdata" then
			self.sCallback:DynamicInvoke()
		end

		self.sCallback = nil
	end
end

function M:OnQTEFinished_F()
	if self.fCallback then
		if type(self.fCallback) == "function" then
			self.fCallback()
		elseif type(self.fCallback) == "userdata" then
			self.fCallback:DynamicInvoke()
		end

		self.fCallback = nil
	end
end

function M:PlayOpenAnim(store)
	local clip = store.animation:GetClip(self.openAnimName)

	if clip then
		store.animation:Play(self.openAnimName)
		Timer.New(function ()
			if store.animation then
				gCS.LuaUtils.SampleTargetAnimation(store.animation, self.openAnimName, clip.length)
			end
		end, clip.length):Start()
	else
		return 0
	end
end

function M:PlayHintAnim(store, flag)
	if store and flag then
		store.ComboHintAnim:SetActive(true)
	end
end

function M:PlayClickAnim(store)
	if not store then
		return
	end

	local clip = store.animation:GetClip(self.openAnimName)

	gCS.LuaUtils.SampleTargetAnimation(store.animation, self.openAnimName, clip.length)

	local clickAnimName = self.clickAnimName

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and gCS.LuaUtils.GetActiveDevice() <= SGUI.GameDevice.KeyboardMouse then
		clickAnimName = self.clickAnimName_mouse
	end

	local clip = store.animation:GetClip(clickAnimName)

	if clip then
		store.animation:Stop()
		store.animation:Play(clickAnimName)
	end

	if store.clickSoundId and store.clickSoundId ~= 0 then
		LX6.Audio.AudioManager.Instance.Instance:PlaySound(store.clickSoundId)
	end
end

function M:PlayLineAnim(enable)
	if enable then
		self.bindData.animation:Play(self.lineOpenAnimName)
	else
		self.bindData.animation:Play(self.lineCloseAnimName)
	end
end

function M:PlaySuccessAnim(store)
	if not store or store.successState then
		return
	end

	store.successState = true
	local finishName = self.bindData.tapType == 1 and self.finishAnimName_combo or self.finishAnimName
	local clip = store.animation:GetClip(finishName)

	if clip then
		store.animation:Play(finishName)
	end

	if store.successSoundId and store.successSoundId ~= 0 then
		LX6.Audio.AudioManager.Instance.Instance:PlaySound(store.successSoundId)
	end
end

function M:PlaySuccessAnimInternal(store)
	if not store or store.successState then
		return
	end

	store.successState = true

	if store.successSoundId and store.successSoundId ~= 0 then
		LX6.Audio.AudioManager.Instance.Instance:PlaySound(store.successSoundId)
	end

	local finishName = self.finishAnimName
	local clip = store.animation:GetClip(finishName)

	if clip then
		store.animation:Play(finishName)

		return clip.length
	else
		return 0
	end
end

function M:GetBtnStore(widget)
	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end

function M:ClosePanelWithAnim()
	if gTimelineManager.mulQteCloseTimer then
		return
	end

	if not self.btn1_store.successState or not self.btn2_store.successState then
		local finishAnimName = self.failAnimName
		local clip = self.btn1_store.animation:GetClip(finishAnimName)

		if clip then
			if not self.btn1_store.successState then
				self.btn1_store.animation:Play(finishAnimName)
			end

			if not self.btn2_store.successState then
				self.btn2_store.animation:Play(finishAnimName)
			end

			gTimelineManager.mulQteCloseTimer = Timer.New(function ()
				gPanelManager:Close(gPanelId.TIMELINE_MULTIPLE_TAP_PANEL)

				gTimelineManager.mulQteCloseTimer = nil
			end, clip.length)

			gTimelineManager.mulQteCloseTimer:Start()

			return
		end
	end

	gPanelManager:Close(gPanelId.TIMELINE_MULTIPLE_TAP_PANEL)
end

function M:PlaySuccessEndAnim()
	local result = self:PlaySuccessAnimInternal(self.btn1_store)

	if self.bindData.showLines == 1 then
		self:PlayLineAnim(false)

		self.btn2_store.successState = true

		self.btn2_store.buttonRT.gameObject:SetActive(false)
	end

	return result
end

function M:PlaySuccessEndAnim2()
	local result = self:PlaySuccessAnimInternal(self.btn2_store)

	if self.bindData.showLines == 1 then
		self.bindData.showLines = 0
		self.btn1_store.successState = true

		self.btn1_store.buttonRT.gameObject:SetActive(false)
	end

	return result
end

function M:PlayClickAnimByCS(btn2)
	if not btn2 then
		self:PlayClickAnim(self.btn1_store)
	else
		self:PlayClickAnim(self.btn2_store)
	end
end

function M:ClosePanelFailed()
	if not self.btn1_store or not self.btn2_store then
		return 0
	end

	if not self.btn1_store.successState or not self.btn2_store.successState then
		local finishAnimName = self.failAnimName
		local clip = self.btn1_store.animation:GetClip(finishAnimName)

		if clip then
			if self.btn1_store and not self.btn1_store.successState then
				self.btn1_store.animation:Play(finishAnimName)
			end

			if self.btn2_store and not self.btn2_store.successState then
				self.btn2_store.animation:Play(finishAnimName)
			end

			return clip.length
		end
	end

	return 0
end

function M:SetProgress0(progress)
	if not self.btn1_store then
		return
	end

	if self.btn1_store.countdownProgressImage then
		self.btn1_store.countdownProgressImage.fillAmount = progress
	end

	if self.btn1_store.progressImage then
		self.btn1_store.progressImage.fillAmount = progress
	end

	if self.btn1_store.outCircleRT then
		local outerWidth = self.btn1_store.outCircleRT.rect.width
		local innerWidth = self.btn1_store.innerCircleRT.rect.width
		self.btn1_store.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1), progress)
	end
end

function M:SetProgress1(progress)
	if not self.btn2_store then
		return
	end

	if self.btn2_store.countdownProgressImage then
		self.btn2_store.countdownProgressImage.fillAmount = progress
	end

	if self.btn2_store.progressImage then
		self.btn2_store.progressImage.fillAmount = progress
	end

	if self.btn2_store.outCircleRT then
		local outerWidth = self.btn2_store.outCircleRT.rect.width
		local innerWidth = self.btn2_store.innerCircleRT.rect.width
		self.btn2_store.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1), progress)
	end
end
