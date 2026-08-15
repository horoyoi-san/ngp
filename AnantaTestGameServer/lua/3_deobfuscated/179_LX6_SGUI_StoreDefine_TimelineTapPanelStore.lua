local InputSGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
C_TimelineTapPanelStore = DefClass("C_TimelineTapPanelStore", C_TimelineTapPanelStore, C_StoreGroup)
GroupName2Class.TimelineTapPanelStore = C_TimelineTapPanelStore
local M = C_TimelineTapPanelStore

function M:OnAwake()
	self.posType = 0
	self.targetPos = nil
	self.customPosOffset = nil
	self.subType = 0
	self.progressType = 0
	self.countDown_timer = 0
	self.countDown_duration = 0
	self.countDown_perfect = 0.2
	self.countDown_additive = 0.3
	self.openAnimLength = 0.1
	self.clickCounter = 0
	self.tapTimes = 5
	self.showProgress = false
	self.openAnimName = "S_Vx_TimelineTapPanel_Open"
	self.clickAnimName_mouse = "S_Vx_TimelineTapPanel_Mouse_Click"
	self.clickAnimName = "S_Vx_TimelineTapPanel_Click"
	self.finishAnimName = "S_Vx_TimelineTapPanel_Finish"
	self.finishAnimName_combo = "S_Vx_TimelineTapPanel_Finish_lianji"
	self.failAnimName = "S_Vx_TimelineTapPanel_Fail"
	self.comboHintAnimName = "S_Vx_TimelineTapPanel_Liandian"
	self.openAnimTimer = nil
	self.currentState = 0
	self.clickState = {
		ClickFailed = 2,
		ClickSucceed = 1,
		No = 0
	}
end

function M:OnShow(panelId, data)
	if gTimelineManager.qteCloseTimer then
		gTimelineManager.qteCloseTimer:Stop()

		gTimelineManager.qteCloseTimer = nil
	end

	self.clickCounter = 0
	local panelData = data:ToTable()
	self.tapTimes = panelData.tapTimes
	self.bindData.subType = panelData.subType

	self:SelectSubTypeBtn(panelData)
	self:SetPos(panelData)

	self.bindData.buttonSize = panelData.buttonSize
	self.clickSoundId = panelData.clickSoundId
	self.successSoundId = panelData.successSoundId
	self.failSoundId = panelData.failSoundId
	self.countdownSoundId = panelData.countdownSoundId
	self.countdownSoundPlaying = false

	self:SetProgressType(panelData)

	self.qteType = panelData.qteType
	self.mCallback = panelData.mCallback
	self.sCallback = panelData.sCallback
	self.fCallback = panelData.fCallback
	self.closePanel = self.qteType ~= 4 and self.qteType ~= 5
	self.successState = false

	self:SetTapType()
	self:BindClickCb(panelData)

	self.openAnimLength = self:PlayOpenAnim()

	if self.bindData.subType == 0 then
		if not self.openAnimLength or self.openAnimLength == 0 then
			local clip = self.bindData.ComboHintAnim:GetClip(self.comboHintAnimName)

			if clip then
				self.bindData.ComboHintAnim:Play(self.comboHintAnimName)
			end
		else
			self.openAnimTimer = Timer.New(function ()
				if self.bindData.animation then
					gCS.LuaUtils.SampleTargetAnimation(self.bindData.animation, self.openAnimName, self.openAnimLength)
				end

				if self.bindData.ComboHintAnim and self.bindData.tapType == 1 then
					local clip = self.bindData.ComboHintAnim:GetClip(self.comboHintAnimName)

					if clip then
						self.bindData.ComboHintAnim:Play(self.comboHintAnimName)
					end
				end

				self.openAnimTimer = nil
			end, self.openAnimLength)

			self.openAnimTimer:Start()
		end
	end
end

function M:BindClickCb(panelData)
	local store = self:GetSubBtnStore(self.subBtn)

	if not store then
		return
	end

	if store.pcBtn then
		store.pcBtn.luaClick = self:CreateAction("OnBtnClick")
	end

	if store.mobileBtn then
		store.mobileBtn.luaClick = self:CreateAction("OnBtnClick")
	end

	self:SetBtnMode(panelData)
end

function M:OnUpdate()
	self:UpdatePos()
	self:UpdateCountDown()
	self:PrintDebugInfo()
end

function M:SetTapType()
	if self.progressType == 1 then
		self.bindData.tapType = 0
	elseif self.qteType == 4 or self.qteType == 5 then
		self.bindData.tapType = 1
	else
		self.bindData.tapType = self.tapTimes > 1 and 1 or 0
	end
end

function M:GetSubBtnStore(widget)
	if not widget then
		return nil
	end

	return gStoreManager:GetStoreGroup("SubBtnStore"):GetStoreByWidget(widget)
end

function M:SelectSubTypeBtn(panelData)
	self.bindData.subType = panelData.subType

	if self.bindData.subType == 0 then
		self.subBtn = self.bindData.SubBtn_Click
	elseif self.bindData.subType == 1 then
		self.subBtn = self.bindData.SubBtn_FeisuoC
	elseif self.bindData.subType == 2 then
		self.subBtn = self.bindData.SubBtn_EnvironmentalKill
	elseif self.bindData.subType == 3 then
		self.subBtn = self.bindData.SubBtn_Interaction
		local store = self:GetSubBtnStore(self.subBtn)

		if store then
			store.buttonTip.text = self:GetTextById(panelData.textId)
			store.mobileTip.text = self:GetTextById(panelData.textId)
		end
	end
end

function M:GetTextById(textId)
	if not textId or textId == 0 then
		return nil
	end

	local cfg = LTConfig.TextConfig.GetConfig(textId)

	if not cfg then
		return nil
	end

	return cfg.Text
end

function M:SetPos(panelData)
	local store = self:GetSubBtnStore(self.subBtn)

	if not store or not store.BtnOffset then
		return
	end

	self.posType = panelData.pos

	if self.posType == "Custom" then
		self.targetPos = panelData.customPos
		self.customPosOffset = panelData.customPosOffset
	else
		self.targetPos = self.bindData[self.posType]
	end

	if self.targetPos then
		if self.posType == "Custom" then
			local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRTParent, self.targetPos.position)
			store.BtnOffset.anchoredPosition = uiPos + self.customPosOffset
		else
			store.BtnOffset.anchoredPosition = self.targetPos.anchoredPosition
		end
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.showLeftGuide = panelData.showGuide and 1 or 0
		self.bindData.guideType = panelData.guideType
	end
end

function M:UpdatePos()
	if self.closeState then
		return
	end

	local store = self:GetSubBtnStore(self.subBtn)

	if self.posType ~= "Custom" or gClientUtils.IsNil(self.targetPos) or not store or not store.BtnOffset then
		return
	end

	local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRTParent, self.targetPos.position)

	if self.customPosOffset then
		store.BtnOffset.anchoredPosition = uiPos + self.customPosOffset
	else
		store.BtnOffset.anchoredPosition = uiPos
	end
end

function M:SetProgressType(panelData)
	self.progressType = panelData.progressType

	if self.progressType == 1 then
		self.bindData.progressMode = 1
		self.countDown_duration = panelData.duration
		self.countDown_perfect = panelData.perfectTime
		self.countDown_additive = panelData.additiveTime
		self.countDown_timer = 0
		self.currentState = self.clickState.ClickSucceed
	elseif self.progressType == 2 then
		self.bindData.progressMode = 2
		self.showProgress = true
		self.currentState = self.clickState.ClickSucceed
	elseif self.progressType == 3 then
		self.bindData.progressMode = 2
		self.showProgress = false
		self.currentState = self.clickState.ClickSucceed
	elseif self.progressType == 4 then
		self.bindData.progressMode = 3
		self.showProgress = false
		self.currentState = self.clickState.ClickSucceed
	else
		self.bindData.progressMode = 0
		self.currentState = self.clickState.ClickSucceed
	end
end

function M:PrintDebugInfo()
	self.bindData.debugMode = gTimelineManager.debugQTE and 1 or 0

	if gTimelineManager.debugQTE then
		if self.progressType ~= 1 then
			self.bindData.debugLabel = ""

			return
		end

		if self.currentState == self.clickState.No then
			self.bindData.debugLabel = "Wait"
		elseif self.currentState == self.clickState.ClickFailed then
			self.bindData.debugLabel = "Fail"
		elseif self.currentState == self.clickState.ClickSucceed then
			self.bindData.debugLabel = "Success"
		else
			self.bindData.debugLabel = ""
		end
	end
end

function M:UpdateCountDown()
	if self.progressType == 1 and self.countDown_duration then
		local startTime = 0.23333333333333334

		if startTime <= self.countDown_timer and self.countDown_timer < self.countDown_duration - self.countDown_perfect then
			if not self.countdownSoundPlaying then
				if self.countdownSoundId and self.countdownSoundId ~= 0 then
					LX6.Audio.AudioManager.Instance.Instance:PlaySound(self.countdownSoundId)
				end

				self.countdownSoundPlaying = true
			end

			local outerWidth = self.bindData.outCircleRT.rect.width
			local innerWidth = self.bindData.innerCircleRT.rect.width
			local weight = (self.countDown_timer - startTime) / (self.countDown_duration - self.countDown_perfect - startTime)
			self.bindData.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1), weight)
		elseif self.countDown_timer >= self.countDown_duration - self.countDown_perfect then
			if self.countdownSoundPlaying then
				if self.countdownSoundId and self.countdownSoundId ~= 0 then
					LX6.Audio.AudioManager.Instance.Instance:StopSound(self.countdownSoundId)
				end

				self.countdownSoundPlaying = false
			end

			local outerWidth = self.bindData.outCircleRT.rect.width
			local innerWidth = self.bindData.innerCircleRT.rect.width
			self.bindData.outCircleRT.localScale = Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1)
		end

		if self.countDown_timer < startTime then
			self.currentState = self.clickState.No
		elseif self.countDown_timer < self.countDown_duration - self.countDown_perfect - self.countDown_additive then
			self.currentState = self.clickState.ClickFailed
		else
			self.currentState = self.clickState.ClickSucceed
		end

		self.countDown_timer = self.countDown_timer + gLogicTime.deltaTime
	end
end

function M:SetProgress(progress)
	if self.progressType == 4 then
		if self.bindData.countdownProgressImage then
			self.bindData.countdownProgressImage.fillAmount = progress
		end
	elseif self.bindData.progressImage then
		self.bindData.progressImage.fillAmount = progress
	end
end

function M:SetBtnMode(panelData)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local pcKey = panelData.pcKey

	if pcKey then
		self.bindData.clickBtn:SetPCKeyInfoWithOutTip(pcKey)

		if pcKey == 8 then
			self.bindData.pcKeyMode = 0
		elseif pcKey == 9 then
			self.bindData.pcKeyMode = 1
		else
			local pcKeyIconIndex = panelData.pcKeyIconIndex
			local cfg = InputSGUIPCKeyConfig.GetConfig(pcKey)

			if cfg and pcKeyIconIndex < #cfg.ButtonIcon then
				self.bindData.pcKeyMode = 2
				self.bindData.btnIcon = cfg.ButtonIcon[pcKeyIconIndex + 1]
			else
				self.bindData.pcKeyMode = 3
				self.bindData.btnText.text = cfg.ButtonName
			end
		end
	end

	local controllerKey = panelData.controllerKey
	local controllerStyle = panelData.controllerStyle

	if controllerKey then
		self.bindData.navArea:ChangeActionIdByResponse(self.bindData.clickBtn, controllerKey)

		if self.bindData.controllerImg then
			self.bindData.controllerImg:ChangeImageAction(controllerKey, 0, self.bindData.clickBtn, 0, controllerStyle)
		end

		if self.bindData.deviceIconSwitch then
			self.bindData.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", controllerKey, controllerStyle)
		end
	end
end

function M:OnBtnClick()
	if self.currentState == self.clickState.No or self.closeState then
		return
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)

	if not self.fCallback then
		return
	end

	if self.openAnimTimer then
		self.openAnimTimer:Stop()
	end

	self.clickCounter = self.clickCounter + 1

	if self.showProgress then
		self.bindData.progressImage.fillAmount = self.clickCounter / self.tapTimes
	end

	if self.tapTimes <= self.clickCounter then
		if self.currentState == self.clickState.ClickSucceed then
			self.successState = true

			if self.sCallback then
				if type(self.sCallback) == "function" then
					self.sCallback()
				elseif type(self.sCallback) == "userdata" then
					self.sCallback:DynamicInvoke()
				end
			end
		elseif self.fCallback then
			if type(self.fCallback) == "function" then
				self.fCallback()
			elseif type(self.fCallback) == "userdata" then
				self.fCallback:DynamicInvoke()
			end
		end

		self.clickCounter = 0

		if self.closePanel then
			self:ClosePanelWithAnim()

			self.currentState = self.clickState.No

			if self.progressType == 1 then
				self.progressType = -1
			end
		else
			self:PlayClickAnim()
		end
	else
		self:PlayClickAnim()

		if (self.qteType == 4 or self.qteType == 5) and self.mCallback then
			if type(self.mCallback) == "function" then
				self.mCallback()
			elseif type(self.mCallback) == "userdata" then
				self.mCallback:DynamicInvoke()
			end
		end
	end
end

function M:PlayOpenAnim()
	self.closeState = false
	local clip = self.bindData.animation:GetClip(self.openAnimName)

	if not clip then
		return 0
	end

	self.bindData.animation:Play(self.openAnimName)

	return clip.length
end

function M:PlayClickAnim()
	gCS.LuaUtils.SampleTargetAnimation(self.bindData.animation, self.openAnimName, self.openAnimLength)

	local clickAnimName = self.clickAnimName

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and gCS.LuaUtils.GetActiveDevice() <= SGUI.GameDevice.KeyboardMouse then
		clickAnimName = self.clickAnimName_mouse
	end

	local clip = self.bindData.animation:GetClip(clickAnimName)

	if clip then
		self.bindData.animation:Stop()
		self.bindData.animation:Play(clickAnimName)
	end

	if self.clickSoundId and self.clickSoundId ~= 0 then
		LX6.Audio.AudioManager.Instance.Instance:PlaySound(self.clickSoundId)
	end
end

function M:StopClickAnim()
	local clickAnimName = self.clickAnimName

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and gCS.LuaUtils.GetActiveDevice() <= SGUI.GameDevice.KeyboardMouse then
		clickAnimName = self.clickAnimName_mouse
	end

	local clip = self.bindData.animation:GetClip(clickAnimName)

	if clip then
		self.bindData.animation:Stop()
		gCS.LuaUtils.SampleTargetAnimation(self.bindData.animation, clickAnimName, clip.length)
	end
end

function M:GetFinishAnimName()
	if self.successState then
		return self.bindData.tapType == 1 and self.finishAnimName_combo or self.finishAnimName
	else
		if self.qteType ~= 3 and self.qteType ~= 4 and self.qteType ~= 6 then
			return nil
		end

		return self.failAnimName
	end
end

function M:GetFinishSoundId()
	if self.successState then
		return self.successSoundId
	else
		if self.qteType ~= 3 and self.qteType ~= 4 and self.qteType ~= 6 then
			return 0
		end

		return self.failSoundId
	end
end

function M:PlayEndAnim()
	self.closeState = true
	local finishAnimName = self:GetFinishAnimName()

	if finishAnimName then
		local clip = self.bindData.animation:GetClip(finishAnimName)

		if clip then
			self:StopClickAnim()
			self.bindData.animation:Play(finishAnimName)

			local soundId = self:GetFinishSoundId()

			if soundId and soundId ~= 0 then
				LX6.Audio.AudioManager.Instance.Instance:PlaySound(soundId)
			end

			return clip.length
		end
	end

	return 0
end

function M:ClosePanelWithAnim()
	if self.closeState then
		return
	end

	local endTime = self:PlayEndAnim()

	if endTime == 0 then
		gPanelManager:Close(gPanelId.TIMELINE_TAP_PANEL)
	else
		gTimelineManager.qteCloseTimer = Timer.New(function ()
			gPanelManager:Close(gPanelId.TIMELINE_TAP_PANEL)

			gTimelineManager.qteCloseTimer = nil
		end, endTime)

		gTimelineManager.qteCloseTimer:Start()
	end
end

function M:PlayClickAnimByCS(btn2)
	if not btn2 then
		self:PlayClickAnim()
	end
end

function M:PlaySuccessEndAnim()
	if self.closeState then
		return 0
	end

	self.closeState = true
	local finishAnimName = self.finishAnimName

	if self.bindData.subType == 0 and finishAnimName then
		local clip = self.bindData.animation:GetClip(finishAnimName)

		if clip then
			self:StopClickAnim()
			self.bindData.animation:Play(finishAnimName)

			local soundId = self:GetFinishSoundId()

			if soundId and soundId ~= 0 then
				LX6.Audio.AudioManager.Instance.Instance:PlaySound(soundId)
			end

			return clip.length
		end
	end

	return 0
end

function M:PlaySuccessEndAnim2()
	return 0
end

function M:ClosePanelFailed()
	local finishAnimName = self.failAnimName

	if finishAnimName and self.bindData.animation then
		local clip = self.bindData.animation:GetClip(finishAnimName)

		if clip then
			self:StopClickAnim()
			self.bindData.animation:Play(finishAnimName)

			local soundId = self:GetFinishSoundId()

			if soundId and soundId ~= 0 then
				LX6.Audio.AudioManager.Instance.Instance:PlaySound(soundId)
			end

			return clip.length
		end
	end

	return 0
end

function M:SetProgress0(progress)
	if self.bindData.countdownProgressImage then
		self.bindData.countdownProgressImage.fillAmount = progress
	end

	if self.bindData.progressImage then
		self.bindData.progressImage.fillAmount = progress
	end

	if self.bindData.outCircleRT then
		local outerWidth = self.bindData.outCircleRT.rect.width
		local innerWidth = self.bindData.innerCircleRT.rect.width
		self.bindData.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1), progress)
	end
end

function M:SetProgress1(progress)
	return
end
