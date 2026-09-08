-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineMultipleTapPanelStore.lua
-- Decompiled from: 01358_TimelineMultipleTapPanelStore.lua_b63bf0d0029b.luajit

local InputSGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
C_TimelineMultipleTapPanelStore = DefClass("C_TimelineMultipleTapPanelStore", C_TimelineMultipleTapPanelStore, C_StoreGroup)
GroupName2Class.TimelineMultipleTapPanelStore = C_TimelineMultipleTapPanelStore
local M = C_TimelineMultipleTapPanelStore

M.OnAwake = function(self)
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
	self.btn1_store = nil
	self.btn1_posType = 0
	self.btn1_progressType = 0
	self.btn1_showProgress = false
	self.btn2_store = nil
	self.btn2_posType = 0
	self.btn2_progressType = 0
	self.btn2_showProgress = false
end

M.SetTapType = function(self, panelData)
	self.btn1_store.tapType = panelData.ShowComboHint1 and 1 or 0
	self.btn2_store.tapType = panelData.ShowComboHint2 and 1 or 0
end

M.SetAdaptive = function(self, panelData)
	self.bindData.Adaptive = panelData.Adaptive
end

M.OnShow = function(self, panelId, data)
	local panelData = data.ToTable(data)

	self.ShowGuildLine(self, panelData)

	self.btn1_store = self.GetBtnStore(self, self.bindData.btn1)

	self.Btn1_SetPos(self, panelData)
	self.Btn1_SetBtnMode(self, panelData)

	self.btn1_store.clickBtn.luaClick = self.CreateAction(self, "Btn1_OnBtnClick")
	self.btn1_store.clickSoundId = panelData.btn1_clickSoundId
	self.btn1_store.successSoundId = panelData.btn1_successSoundId
	self.btn1_store.failSoundId = panelData.btn1_failSoundId
	self.btn1_store.countdownSoundId = panelData.btn1_countdownSoundId
	self.btn2_store = self.GetBtnStore(self, self.bindData.btn2)

	self.Btn2_SetPos(self, panelData)
	self.Btn2_SetBtnMode(self, panelData)

	self.btn2_store.clickBtn.luaClick = self.CreateAction(self, "Btn2_OnBtnClick")
	self.btn2_passed = false
	self.btn2_store.clickSoundId = panelData.btn2_clickSoundId
	self.btn2_store.successSoundId = panelData.btn2_successSoundId
	self.btn2_store.failSoundId = panelData.btn2_failSoundId
	self.btn2_store.countdownSoundId = panelData.btn2_countdownSoundId

	self.SetProgressType(self, panelData)

	self.btn1_store.successState = false
	self.btn2_store.successState = false

	self.SetTapType(self, panelData)

	local openAnimLength = self.PlayOpenAnim(self, self.btn1_store)

	self.PlayOpenAnim(self, self.btn2_store)
	self.PlayOpenAnim(self, self.btn1_store)

	if not openAnimLength or openAnimLength ~= 0 then
		self.openAnimTimer = nil
	else
		self.openAnimTimer = Timer.New(function ()
			self.openAnimTimer = nil
		end, openAnimLength):Start()
	end

	self.HideBtn(self, panelData)
	self.SetAdaptive(self, panelData)
end

M.OnUpdate = function(self)
	self.Btn1_UpdatePos(self)
	self.Btn2_UpdatePos(self)
end

M.HideBtn = function(self, panelData)
	if panelData.hideBtn then
		self.bindData.btn1:SetActiveQuickly(false)
		self.bindData.btn2:SetActiveQuickly(false)
	end
end

M.SetProgressType = function(self, panelData)
	if panelData.progressType then
		self.btn2_progressType = panelData.progressType
		self.btn1_progressType = panelData.progressType

		if self.btn2_progressType ~= 1 then
			self.btn1_store.progressType = 1
			self.btn2_store.progressType = 1
		elseif self.btn2_progressType ~= 2 then
			self.btn1_store.progressType = 2
			self.btn1_showProgress = true
			self.btn2_store.progressType = 2
			self.btn2_showProgress = true
		elseif self.btn2_progressType ~= 3 then
			self.btn1_store.progressType = 2
			self.btn1_showProgress = false
			self.btn2_store.progressType = 2
			self.btn2_showProgress = false
		elseif self.btn2_progressType ~= 4 then
			self.btn1_store.progressType = 3
			self.btn1_showProgress = false
			self.btn2_store.progressType = 3
			self.btn2_showProgress = false
		else
			self.btn1_store.progressType = 0
			self.btn2_store.progressType = 0
		end
	else
		self.btn1_store.progressType = 0
		self.btn2_store.progressType = 0
	end
end

M.ShowGuildLine = function(self, panelData)
	if panelData.showLine then
		self.bindData.showLines = 1

		self.PlayLineAnim(self, true)

		panelData.btn1_pos = "Custom"
		panelData.btn1_customPosOffset = Vector2.New(-508, 195)
		panelData.btn2_pos = "Custom"
		panelData.btn2_customPosOffset = Vector2.New(-511, -248)
		panelData.btn1_mobilePos = 99
		panelData.btn2_mobilePos = 100
	else
		self.bindData.showLines = 0
	end
end

M.Btn1_SetPos = function(self, panelData)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.btn1_posType = panelData.btn1_pos

		if self.btn1_posType ~= "Custom" then
			self.btn1_targetPos = panelData.btn1_customPos
			self.btn1_customPosOffset = panelData.btn1_customPosOffset

			if self.btn1_targetPos then
				local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.btn1_store.buttonRTParent, self.btn1_targetPos.position)
				self.btn1_store.buttonRT.anchoredPosition = uiPos + self.btn1_customPosOffset
			else
				self.btn1_store.buttonRT.anchoredPosition = self.btn1_customPosOffset
			end
		elseif self.bindData[self.btn1_posType] then
			self.btn1_targetPos = self.bindData[self.btn1_posType]
			self.btn1_store.buttonRT.anchoredPosition = self.btn1_targetPos.anchoredPosition
		end
	else
		gTimelineManager:SetMobilePos(self.btn1_store, panelData.btn1_mobilePos and panelData.btn1_mobilePos or 1)
	end
end

M.Btn2_SetPos = function(self, panelData)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.btn2_posType = panelData.btn2_pos

		if self.btn2_posType ~= "Custom" then
			self.btn2_targetPos = panelData.btn2_customPos
			self.btn2_customPosOffset = panelData.btn2_customPosOffset

			if self.btn2_targetPos then
				local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.btn2_store.buttonRTParent, self.btn2_targetPos.position)
				self.btn2_store.buttonRT.anchoredPosition = uiPos + self.btn2_customPosOffset
			else
				self.btn2_store.buttonRT.anchoredPosition = self.btn2_customPosOffset
			end
		elseif self.bindData[self.btn2_posType] then
			self.btn2_targetPos = self.bindData[self.btn2_posType]
			self.btn2_store.buttonRT.anchoredPosition = self.btn2_targetPos.anchoredPosition
		end
	else
		gTimelineManager:SetMobilePos(self.btn2_store, panelData.btn2_mobilePos and panelData.btn2_mobilePos or 0)
	end
end

M.Btn1_UpdatePos = function(self)
	if self.btn1_posType ~= "Custom" and self.btn1_targetPos and self.btn1_store.buttonRTParent then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.btn1_store.buttonRTParent, self.btn1_targetPos.position)
		self.btn1_store.buttonRT.anchoredPosition = uiPos + self.btn1_customPosOffset
	end
end

M.Btn2_UpdatePos = function(self)
	if self.btn2_posType ~= "Custom" and self.btn2_targetPos and self.btn2_store.buttonRTParent then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.btn2_store.buttonRTParent, self.btn2_targetPos.position)
		self.btn2_store.buttonRT.anchoredPosition = uiPos + self.btn2_customPosOffset
	end
end

M.Btn1_SetMobileIcon = function(self, panelData)
	local iconId = panelData.mobileIconId

	if iconId and iconId == 0 then
		self.btn1_store.mobileIcon = iconId

		return
	end
end

M.Btn2_SetMobileIcon = function(self, panelData)
	local iconId = panelData.mobileIconId2

	if iconId and iconId == 0 then
		self.btn2_store.mobileIcon = iconId

		return
	end
end

M.Btn1_SetBtnMode = function(self, panelData)
	self.btn1_store.progress.value = 0

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.Btn1_SetMobileIcon(self, panelData)

		return
	end

	local pcKey = panelData.btn1_pcKey
	local controllerKey = panelData.btn1_controllerKey
	local controllerStyle = panelData.btn1_controllerStyle

	if pcKey then
		self.btn1_store.clickBtn:SetPCKeyInfoWithOutTip(pcKey)

		if pcKey ~= 8 then
			self.btn1_store.pcKeyMode = 0
		elseif pcKey ~= 9 then
			self.btn1_store.pcKeyMode = 1
		else
			local cfg = InputSGUIPCKeyConfig.GetConfig(pcKey)
			local pcKeyIconIndex = panelData.btn1_pcKeyIconIndex

			if cfg and pcKeyIconIndex >= #cfg.ButtonIcon then
				self.btn1_store.pcKeyMode = 2
				self.btn1_store.btnIcon = cfg.ButtonIcon[pcKeyIconIndex + 1]
			else
				self.btn1_store.pcKeyMode = 3
				self.btn1_store.btnText = cfg.ButtonName
			end
		end
	end

	if controllerKey then
		self.bindData.navArea:ChangeActionIdByResponse(self.btn1_store.clickBtn, controllerKey)

		if self.btn1_store.controllerImg then
			self.btn1_store.controllerImg:ChangeImageAction(controllerKey, 0, self.btn1_store.clickBtn, 0, controllerStyle)
		end

		if self.btn1_store.deviceIconSwitch then
			self.btn1_store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", controllerKey, controllerStyle)
		end
	end
end

M.Btn2_SetBtnMode = function(self, panelData)
	self.btn2_store.progress.value = 0

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.Btn2_SetMobileIcon(self, panelData)

		return
	end

	local pcKey = panelData.btn2_pcKey
	local controllerKey = panelData.btn2_controllerKey
	local controllerStyle = panelData.btn2_controllerStyle

	if pcKey then
		self.btn2_store.clickBtn:SetPCKeyInfoWithOutTip(pcKey)

		if pcKey ~= 8 then
			self.btn2_store.pcKeyMode = 0
		elseif pcKey ~= 9 then
			self.btn2_store.pcKeyMode = 1
		else
			local cfg = InputSGUIPCKeyConfig.GetConfig(pcKey)
			local pcKeyIconIndex = panelData.btn2_pcKeyIconIndex

			if cfg and pcKeyIconIndex >= #cfg.ButtonIcon then
				self.btn2_store.pcKeyMode = 2
				self.btn2_store.btnIcon = cfg.ButtonIcon[pcKeyIconIndex + 1]
			else
				self.btn2_store.pcKeyMode = 3
				self.btn2_store.btnText = cfg.ButtonName
			end
		end
	end

	if controllerKey then
		self.bindData.navArea:ChangeActionIdByResponse(self.btn2_store.clickBtn, controllerKey)

		if self.btn2_store.controllerImg then
			self.btn2_store.controllerImg:ChangeImageAction(controllerKey, 0, self.btn2_store.clickBtn, 0, controllerStyle)
		end

		if self.btn2_store.deviceIconSwitch then
			self.btn2_store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", controllerKey, controllerStyle)
		end
	end
end

M.Btn1_OnBtnClick = function(self)
	if self.btn1_store.successState then
		return
	end

	if self.openAnimTimer then
		self.openAnimTimer:Stop()
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)
end

M.Btn2_OnBtnClick = function(self)
	if self.btn2_store.successState then
		return
	end

	if self.openAnimTimer then
		self.openAnimTimer:Stop()
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 2)
end

M.PlayOpenAnim = function(self, store)
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

M.PlayClickAnim = function(self, store)
	if not store then
		return
	end

	local clip = store.animation:GetClip(self.openAnimName)

	gCS.LuaUtils.SampleTargetAnimation(store.animation, self.openAnimName, clip.length)

	local clickAnimName = self.clickAnimName

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse and (store.pcKeyMode ~= 0 or store.pcKeyMode ~= 1) then
		clickAnimName = self.clickAnimName_mouse
	end

	local clip = store.animation:GetClip(clickAnimName)

	if clip then
		store.animation:Stop()
		store.animation:Play(clickAnimName)
	end

	if store.clickSoundId and store.clickSoundId == 0 then
		LX6.Audio.AudioManager.Instance.Instance:PlaySound(store.clickSoundId)
	end
end

M.PlayLineAnim = function(self, enable)
	if enable then
		self.bindData.animation:Play(self.lineOpenAnimName)
	else
		self.bindData.animation:Play(self.lineCloseAnimName)
	end
end

M.PlaySuccessAnim = function(self, store)
	if not store or store.successState then
		return
	end

	store.successState = true
	local finishName = self.bindData.tapType ~= 1 and self.finishAnimName_combo or self.finishAnimName
	local clip = store.animation:GetClip(finishName)

	if clip then
		store.animation:Play(finishName)
	end

	if store.successSoundId and store.successSoundId == 0 then
		LX6.Audio.AudioManager.Instance.Instance:PlaySound(store.successSoundId)
	end
end

M.PlaySuccessAnimInternal = function(self, store)
	if not store or store.successState then
		return
	end

	store.successState = true

	if store.successSoundId and store.successSoundId == 0 then
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

M.GetBtnStore = function(self, widget)
	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end

M.PlaySuccessEndAnim = function(self)
	local result = self.PlaySuccessAnimInternal(self, self.btn1_store)

	if self.bindData.showLines ~= 1 then
		self:PlayLineAnim(false)

		self.btn2_store.successState = true

		self.btn2_store.buttonRT.gameObject:SetActive(false)
	end

	return result
end

M.PlaySuccessEndAnim2 = function(self)
	local result = self.PlaySuccessAnimInternal(self, self.btn2_store)

	if self.bindData.showLines ~= 1 then
		self.bindData.showLines = 0
		self.btn1_store.successState = true

		self.btn1_store.buttonRT.gameObject:SetActive(false)
	end

	return result
end

M.PlayClickAnimByCS = function(self, btn2)
	if not btn2 then
		self.PlayClickAnim(self, self.btn1_store)
	else
		self.PlayClickAnim(self, self.btn2_store)
	end
end

M.HideButtonByCS = function(self, mask)
	if bit.band(mask, 1) == 0 then
		self.bindData.btn1:SetActiveQuickly(false)
	end

	if bit.band(mask, 2) == 0 then
		self.bindData.btn2:SetActiveQuickly(false)
	end
end

M.ClosePanelFailed = function(self)
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

M.SetProgress0 = function(self, progress)
	if not self.btn1_store then
		return
	end

	if self.btn1_store.countdownProgressImage then
		self.btn1_store.countdownProgressImage.fillAmount = progress
	end

	if self.btn1_store.progress then
		self.btn1_store.progress.value = progress
	end

	if self.btn1_store.outCircleRT then
		local outerWidth = self.btn1_store.outCircleRT.rect.width
		local innerWidth = self.btn1_store.innerCircleRT.rect.width
		self.btn1_store.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1), progress)
	end
end

M.SetProgress1 = function(self, progress)
	if not self.btn2_store then
		return
	end

	if self.btn2_store.countdownProgressImage then
		self.btn2_store.countdownProgressImage.fillAmount = progress
	end

	if self.btn2_store.progress then
		self.btn2_store.progress.value = progress
	end

	if self.btn2_store.outCircleRT then
		local outerWidth = self.btn2_store.outCircleRT.rect.width
		local innerWidth = self.btn2_store.innerCircleRT.rect.width
		self.btn2_store.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(innerWidth / outerWidth, innerWidth / outerWidth, 1), progress)
	end
end
