-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineCommonTapPanelStore.lua
-- Decompiled from: 01350_TimelineCommonTapPanelStore.lua_c9a4eff2f53b.luajit

local InputSGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
C_TimelineCommonTapPanelStore = DefClass("C_TimelineCommonTapPanelStore", C_TimelineCommonTapPanelStore, C_StoreGroup)
GroupName2Class.TimelineCommonTapPanelStore = C_TimelineCommonTapPanelStore
local M = C_TimelineCommonTapPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.posType = 0
	self.targetPos = nil
	self.customPosOffset = nil
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
	self.clickAnimName = "S_Vx_TimelineClickTimeScalePanel_Click"
	self.finishAnimName = "S_Vx_TimelineClickTimeScalePanel_Finish"
	self.finishAnimName_combo = "S_Vx_TimelineClickTimeScalePanel_Finish_liandian"
	self.failAnimName = "S_Vx_TimelineClickTimeScalePanel_Fail"
	self.comboHintAnimName = "S_Vx_TimelineTapPanel_Liandian"
	self.openAnimTimer = nil
	self.currentState = 0
	self.clickState = {
		["\\xbc8)<s\\xbb@\\xd0;\\xaf\\xbd"] = 2,
		["Lz\\xa5tG\\x81\\xe7Di{H"] = 1,
		["."] = 0
	}
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.SetAdaptive = function(self, panelData)
	self.bindData.Adaptive = panelData.Adaptive
end

M.OnShow = function(self, panelId, data)
	if gTimelineManager.qteCloseTimer then
		gTimelineManager.qteCloseTimer:Stop()

		gTimelineManager.qteCloseTimer = nil
	end

	local store = self.GetBtnStore(self, self.bindData.btn)
	self.clickCounter = 0
	local panelData = data.ToTable(data)
	self.tapTimes = panelData.tapTimes

	self.SetPos(self, panelData)
	self.HideBtn(self, panelData)

	store.buttonSize = panelData.buttonSize
	self.clickSoundId = panelData.clickSoundId
	self.successSoundId = panelData.successSoundId
	self.failSoundId = panelData.failSoundId
	self.countdownSoundId = panelData.countdownSoundId
	self.countdownSoundPlaying = false

	self.SetProgressType(self, panelData)

	self.successState = false

	self.SetTapType(self)
	self.BindClickCb(self, panelData)

	self.openAnimLength = self.PlayOpenAnim(self)

	if not self.openAnimLength or self.openAnimLength ~= 0 then
		if store.ComboHintAnim and self.bindData.tapType ~= 1 then
			local clip = store.ComboHintAnim:GetClip(self.comboHintAnimName)

			if clip then
				store.ComboHintAnim:Play(self.comboHintAnimName)
			end
		end
	else
		self.openAnimTimer = Timer.New(function ()
			if store.ComboHintAnim and self.bindData.tapType ~= 1 then
				local clip = store.ComboHintAnim:GetClip(self.comboHintAnimName)

				if clip then
					store.ComboHintAnim:Play(self.comboHintAnimName)
				end
			end

			self.openAnimTimer = nil
		end, self.openAnimLength)

		self.openAnimTimer:Start()
	end

	self.SetAdaptive(self, panelData)
end

M.OnUpdate = function(self)
	self.UpdatePos(self)
	self.PrintDebugInfo(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.HideBtn = function(self, panelData)
	if panelData.hideBtn then
		self.bindData.btn:SetActiveQuickly(false)
	end
end

M.GenMessageEvents = function(self)
end

M.GetBtnStore = function(self, widget)
	if not widget then
		return nil
	end

	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end

M.SetPos = function(self, panelData)
	local store = self.GetBtnStore(self, self.bindData.btn)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if not store or not store.buttonRT then
			return
		end

		self.posType = panelData.btn1_pos

		if self.posType ~= "Custom" then
			self.targetPos = panelData.btn1_customPos
			self.customPosOffset = panelData.btn1_customPosOffset
		else
			self.targetPos = self.bindData[self.posType]
		end

		if self.posType ~= "Custom" then
			if self.targetPos then
				local uiPos = gCS.LuaUtils.CalcPositionInScreen(store.buttonRTParent, self.targetPos.position)
				store.buttonRT.anchoredPosition = uiPos + self.customPosOffset
			else
				store.buttonRT.anchoredPosition = self.customPosOffset
			end
		elseif self.targetPos then
			store.buttonRT.anchoredPosition = self.targetPos.anchoredPosition
		end
	else
		gTimelineManager:SetMobilePos(store, panelData.btn1_mobilePos)
	end
end

M.UpdatePos = function(self)
	if self.closeState then
		return
	end

	local store = self.GetBtnStore(self, self.bindData.btn)

	if self.posType == "Custom" or gClientUtils.IsNil(self.targetPos) or not store or not store.buttonRT then
		return
	end

	local uiPos = gCS.LuaUtils.CalcPositionInScreen(store.buttonRTParent, self.targetPos.position)

	if self.customPosOffset then
		store.buttonRT.anchoredPosition = uiPos + self.customPosOffset
	else
		store.buttonRT.anchoredPosition = uiPos
	end
end

M.SetProgressType = function(self, panelData)
	local store = self.GetBtnStore(self, self.bindData.btn)
	self.progressType = panelData.progressType

	if self.progressType ~= 1 then
		store.progressType = 1
		self.currentState = self.clickState.ClickSucceed
	elseif self.progressType ~= 2 then
		store.progressType = 2
		self.showProgress = true
		self.currentState = self.clickState.ClickSucceed
	elseif self.progressType ~= 3 then
		store.progressType = 2
		self.showProgress = false
		self.currentState = self.clickState.ClickSucceed
	elseif self.progressType ~= 4 then
		store.progressType = 3
		self.showProgress = false
		self.currentState = self.clickState.ClickSucceed
	else
		store.progressType = 0
		self.currentState = self.clickState.ClickSucceed
	end

	if self.initProgress then
		self.SetProgress0(self, self.initProgress)

		self.initProgress = nil
	end
end

M.PrintDebugInfo = function(self)
	self.bindData.debugMode = gTimelineManager.debugQTE and 1 or 0

	if gTimelineManager.debugQTE then
		if self.progressType == 1 then
			self.bindData.debugLabel = ""

			return
		end

		if self.currentState ~= self.clickState.No then
			self.bindData.debugLabel = "Wait"
		elseif self.currentState ~= self.clickState.ClickFailed then
			self.bindData.debugLabel = "Fail"
		elseif self.currentState ~= self.clickState.ClickSucceed then
			self.bindData.debugLabel = "Success"
		else
			self.bindData.debugLabel = ""
		end
	end
end

M.SetTapType = function(self)
	local store = self:GetBtnStore(self.bindData.btn)
	store.tapType = self.tapTimes <= 1 and 1 or 0
end

M.BindClickCb = function(self, panelData)
	local store = self.GetBtnStore(self, self.bindData.btn)

	if not store then
		return
	end

	if store.clickBtn then
		store.clickBtn.luaClick = self.CreateAction(self, "OnBtnClick")
	end

	self.SetBtnMode(self, panelData)
end

M.OnBtnClick = function(self)
	if self.currentState ~= self.clickState.No or self.closeState then
		return
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)
end

M.SetPCKeyIcon = function(self, panelData)
	local store = self.GetBtnStore(self, self.bindData.btn)
	local pcKey = panelData.pcKey

	if pcKey then
		if pcKey ~= 8 then
			store.pcKeyMode = 0
		elseif pcKey ~= 9 then
			store.pcKeyMode = 1
		else
			local pcKeyIconIndex = panelData.pcKeyIconIndex
			local cfg = InputSGUIPCKeyConfig.GetConfig(pcKey)

			if cfg and pcKeyIconIndex >= #cfg.ButtonIcon then
				store.pcKeyMode = 2
				store.btnIcon = cfg.ButtonIcon[pcKeyIconIndex + 1]
			else
				store.pcKeyMode = 3
				store.btnText = cfg.ButtonName
			end
		end
	end
end

M.SetMobileIcon = function(self, panelData)
	local iconId = panelData.mobileIconId

	if iconId and iconId == 0 then
		local store = self.GetBtnStore(self, self.bindData.btn)
		store.mobileIcon = iconId

		return
	end
end

M.SetBtnMode = function(self, panelData)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.SetMobileIcon(self, panelData)

		return
	end

	local store = self.GetBtnStore(self, self.bindData.btn)
	local pcKey = panelData.pcKey

	if pcKey then
		store.clickBtn:SetPCKeyInfoWithOutTip(pcKey)
	end

	self.SetPCKeyIcon(self, panelData)

	local controllerKey = panelData.controllerKey
	local controllerStyle = panelData.controllerStyle

	if controllerKey then
		self.bindData.navArea:ChangeActionIdByResponse(store.clickBtn, controllerKey)

		if store.controllerImg then
			store.controllerImg:ChangeImageAction(controllerKey, 0, store.clickBtn, 0, controllerStyle)
		end

		if store.deviceIconSwitch then
			store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", controllerKey, controllerStyle)
		end
	end
end

M.PlayOpenAnim = function(self)
	self.closeState = false

	return 0
end

M.PlayClickAnim = function(self)
	local store = self.GetBtnStore(self, self.bindData.btn)
	local clickAnimName = self.clickAnimName

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse then
		clickAnimName = self.clickAnimName_mouse
	end

	local clip = store.animation:GetClip(clickAnimName)

	if clip then
		store.animation:Stop()
		store.animation:Play(clickAnimName)
	end

	if self.clickSoundId and self.clickSoundId == 0 then
		LX6.Audio.AudioManager.Instance.Instance:PlaySound(self.clickSoundId)
	end
end

M.StopClickAnim = function(self)
	local store = self.GetBtnStore(self, self.bindData.btn)
	local clickAnimName = self.clickAnimName

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse then
		clickAnimName = self.clickAnimName_mouse
	end

	local clip = store.animation:GetClip(clickAnimName)

	if clip then
		store.animation:Stop()
		gCS.LuaUtils.SampleTargetAnimation(store.animation, clickAnimName, clip.length)
	end
end

M.PlayClickAnimByCS = function(self, btn2)
	if not btn2 then
		self.PlayClickAnim(self)
	end
end

M.HideButtonByCS = function(self, mask)
	self.bindData.btn:SetActiveQuickly(false)
end

M.PlaySuccessEndAnim = function(self)
	if self.closeState then
		return 0
	end

	local store = self.GetBtnStore(self, self.bindData.btn)
	self.closeState = true
	local finishAnimName = self.finishAnimName

	if finishAnimName then
		local clip = store.animation:GetClip(finishAnimName)

		if clip then
			self:StopClickAnim()
			store.animation:Play(finishAnimName)

			if self.successSoundId and self.successSoundId == 0 then
				LX6.Audio.AudioManager.Instance.Instance:PlaySound(self.successSoundId)
			end

			return clip.length
		end
	end

	return 0
end

M.PlaySuccessEndAnim2 = function(self)
	return 0
end

M.ClosePanelFailed = function(self)
	local store = self.GetBtnStore(self, self.bindData.btn)
	local finishAnimName = self.failAnimName

	if finishAnimName and store.animation then
		local clip = store.animation:GetClip(finishAnimName)

		if clip then
			self:StopClickAnim()
			store.animation:Play(finishAnimName)

			if self.failSoundId and self.failSoundId == 0 then
				LX6.Audio.AudioManager.Instance.Instance:PlaySound(self.failSoundId)
			end

			return clip.length
		end
	end

	return 0
end

M.SetProgress0 = function(self, progress)
	local store = self.GetBtnStore(self, self.bindData.btn)

	if not store then
		self.initProgress = progress

		return
	end

	if store.countdownProgressImage then
		store.countdownProgressImage.fillAmount = progress
	end

	if store.progress then
		store.progress.value = progress
	end

	if store.outCircleRT then
		local outerWidth = store.outCircleRT.rect.width
		local innerWidth = store.innerCircleRT.rect.width
		store.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1), progress)
	end
end

M.SetProgress1 = function(self, progress)
end
