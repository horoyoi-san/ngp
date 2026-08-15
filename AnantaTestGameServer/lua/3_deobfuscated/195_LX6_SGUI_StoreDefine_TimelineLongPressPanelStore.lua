C_TimelineLongPressPanelStore = DefClass("C_TimelineLongPressPanelStore", C_TimelineLongPressPanelStore, C_StoreGroup)
GroupName2Class.TimelineLongPressPanelStore = C_TimelineLongPressPanelStore
local M = C_TimelineLongPressPanelStore

function M:ctor()
	return
end

function M:GetBtnStore(widget)
	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end

function M:DefineAllVariables()
	self.openAnimName = "S_Vx_TimelineClickTimeScalePanel_open"
	self.finishAnimName = "S_Vx_TimelineClickTimeScalePanel_Finish"
	self.clickAnimName_mouse = "S_Vx_TimelineMultipleTapPanel_Mouse_Click"
	self.failAnimName = "S_Vx_TimelineClickTimeScalePanel_Fail"
	self.trigger1 = false
	self.trigger2 = false
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	local paramTable = data:ToTable()
	self.useSingleControllerBtn = paramTable.singleButton
	self.pcBtn_store = self:GetBtnStore(self.bindData.pcBtn)
	self.pcBtn_store.progressMode = paramTable.progressType

	self:SetPos(self.pcBtn_store, paramTable.btn1_pos, paramTable.btn1_customPos, paramTable.btn1_customPosOffset)
	self:SetPcBtnMode(self.pcBtn_store, paramTable.pcKey, paramTable.pcKeyIconIndex)
	self:PlayOpenAnim(self.pcBtn_store)

	self.btn1_store = self:GetBtnStore(self.bindData.controllerBtn1)
	self.btn1_store.progressMode = paramTable.btn1_progressType

	self:SetPos(self.btn1_store, paramTable.btn1_pos, paramTable.btn1_customPos, paramTable.btn1_customPosOffset)
	self:SetControllerBtnMode(self.btn1_store, paramTable.btn1_controllerKey, paramTable.btn1_controllerStyle)
	self:PlayOpenAnim(self.btn1_store)

	if not self.useSingleControllerBtn then
		self.btn2_store = self:GetBtnStore(self.bindData.controllerBtn2)
		self.btn2_store.progressMode = paramTable.btn1_progressType

		self:SetPos(self.btn2_store, paramTable.btn2_pos, paramTable.btn2_customPos, paramTable.btn2_customPosOffset)
		self:SetControllerBtnMode(self.btn2_store, paramTable.btn2_controllerKey, paramTable.btn2_controllerStyle)
		self:PlayOpenAnim(self.btn2_store)
	else
		self.bindData.controllerBtn2:SetActive(false)
	end

	self.mobileBtn1_store = self:GetBtnStore(self.bindData.mobileBtn1)
	self.mobileBtn1_store.progressMode = paramTable.btn1_progressType

	self:SetPos(self.mobileBtn1_store, paramTable.btn1_pos, paramTable.btn1_customPos, paramTable.btn1_customPosOffset)
	self:PlayOpenAnim(self.mobileBtn1_store)

	self.mobileBtn2_store = self:GetBtnStore(self.bindData.mobileBtn2)
	self.mobileBtn2_store.progressMode = paramTable.btn1_progressType

	self:SetPos(self.mobileBtn2_store, paramTable.btn2_pos, paramTable.btn2_customPos, paramTable.btn2_customPosOffset)
	self:PlayOpenAnim(self.mobileBtn2_store)
	self:SetBtnSize(paramTable)
end

function M:SetPos(store, posType, customPos, customPosOffset)
	store.posType = posType

	if store.posType == "Custom" then
		store.targetPos = customPos
		store.customPosOffset = customPosOffset
	else
		store.targetPos = self.bindData[posType]
	end

	if store.targetPos then
		if posType == "Custom" then
			local uiPos = gCS.LuaUtils.CalcPositionInScreen(store.buttonRT.parent, store.targetPos.position)
			store.buttonRT.anchoredPosition = uiPos + store.customPosOffset
		else
			store.buttonRT.anchoredPosition = store.targetPos.anchoredPosition
		end
	end
end

function M:UpdatePos(store)
	if not store then
		return
	end

	if store.posType == "Custom" and store.targetPos then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(store.buttonRT.parent, store.targetPos.position)
		store.buttonRT.anchoredPosition = uiPos + store.customPosOffset
	end
end

function M:SetBtnSize(panelData)
	self.bindData.buttonSize = panelData.buttonSize == "Small" and 1 or 0
end

function M:OnUpdate()
	self:UpdatePos(self.pcBtn_store)
	self:UpdatePos(self.btn1_store)
	self:UpdatePos(self.btn2_store)
	self:UpdatePos(self.mobileBtn1_store)
	self:UpdatePos(self.mobileBtn2_store)
	self:SendTriggerStatus()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.controllerBtn1.luaPress = self:CreateAction("OnPressBtn1")
	self.bindData.controllerBtn2.luaPress = self:CreateAction("OnPressBtn2")
	self.bindData.mobileBtn1.luaPress = self:CreateAction("OnPressBtn1")
	self.bindData.mobileBtn2.luaPress = self:CreateAction("OnPressBtn2")
	self.bindData.pcBtn.luaPress = self:CreateAction("OnPressPcBtn")
	self.bindData.controllerBtn1.luaRelease = self:CreateAction("OnReleaseBtn1")
	self.bindData.controllerBtn2.luaRelease = self:CreateAction("OnReleaseBtn2")
	self.bindData.mobileBtn1.luaRelease = self:CreateAction("OnReleaseBtn1")
	self.bindData.mobileBtn2.luaRelease = self:CreateAction("OnReleaseBtn2")
	self.bindData.pcBtn.luaRelease = self:CreateAction("OnReleasePcBtn")
end

function M:SetPcBtnMode(store, pcKey, pcKeyIconIndex)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if pcKey then
		store.clickBtn:SetPCKeyInfoWithOutTip(pcKey)

		if pcKey == 8 then
			store.pcKeyMode = 0
		elseif pcKey == 9 then
			store.pcKeyMode = 1
		else
			local cfg = LTConfig.InputSGUIPCKeyConfig.GetConfig(pcKey)

			if cfg and pcKeyIconIndex < #cfg.ButtonIcon then
				store.pcKeyMode = 2
				store.btnIcon = cfg.ButtonIcon[pcKeyIconIndex + 1]
			else
				store.pcKeyMode = 3
				store.btnText = cfg.ButtonName
			end
		end
	end
end

function M:SetControllerBtnMode(store, controllerKey, controllerStyle)
	if not controllerKey or not controllerStyle then
		return
	end

	self.bindData.navArea:ChangeActionIdByResponse(store.clickBtn, controllerKey)
	store.controllerImg:ChangeImageAction(controllerKey, 0, store.clickBtn, 0, controllerStyle)
	store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", controllerKey, controllerStyle)
end

function M:SendTriggerStatus()
	local data = 0

	if self.trigger1 then
		data = data + 1
	end

	if self.trigger2 then
		data = data + 2
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, data)
end

function M:OnPressBtn1()
	self.trigger1 = true
end

function M:OnPressBtn2()
	self.trigger2 = true
end

function M:OnPressPcBtn()
	self.trigger1 = true
end

function M:OnReleaseBtn1()
	self.trigger1 = false
end

function M:OnReleaseBtn2()
	self.trigger2 = false
end

function M:OnReleasePcBtn()
	self.trigger1 = false
end

function M:PlayOpenAnim(store)
	if not store or not store.animation then
		return
	end

	local clip = store.animation:GetClip(self.openAnimName)

	if clip then
		self.openAnimLength = clip.length

		store:Play(self.openAnimName)
	end
end

function M:PlayEndAnim(store)
	if self.closeTimer then
		return
	end

	if not store or not store.animation then
		return
	end

	gCS.LuaUtils.PlayAnimationByName(store.animation, self.finishAnimName)

	local duration = gCS.LuaUtils.GetAnimationTime(store.animation, self.finishAnimName)

	return duration
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

	if self.mobileBtn1_store.countdownProgressImage then
		self.mobileBtn1_store.countdownProgressImage.fillAmount = progress
	end

	if self.mobileBtn1_store.progressImage then
		self.mobileBtn1_store.progressImage.value = progress
	end

	if self.pcBtn_store.countdownProgressImage then
		self.pcBtn_store.countdownProgressImage.fillAmount = progress
	end

	if self.pcBtn_store.progressImage then
		self.pcBtn_store.progressImage.fillAmount = progress
	end
end

function M:SetProgress1(progress)
	if self.btn2_store then
		if self.btn2_store.countdownProgressImage then
			self.btn2_store.countdownProgressImage.fillAmount = progress
		end

		if self.btn2_store.progressImage then
			self.btn2_store.progressImage.fillAmount = progress
		end
	end

	if self.mobileBtn2_store then
		if self.mobileBtn2_store.countdownProgressImage then
			self.mobileBtn2_store.countdownProgressImage.fillAmount = progress
		end

		if self.mobileBtn2_store.progressImage then
			self.mobileBtn2_store.progressImage.value = progress
		end
	end
end

function M:PlayClickAnimByCS(btn2)
	return
end

function M:PlaySuccessEndAnim()
	local duration = 0
	duration = math.max(duration, self:PlayEndAnim(self.btn1_store))
	duration = math.max(duration, self:PlayEndAnim(self.mobileBtn1_store))
	duration = math.max(duration, self:PlayEndAnim(self.pcBtn_store))

	return duration
end

function M:PlaySuccessEndAnim2()
	local duration = 0
	duration = math.max(duration, self:PlayEndAnim(self.btn2_store))
	duration = math.max(duration, self:PlayEndAnim(self.mobileBtn2_store))

	return duration
end

function M:ClosePanelFailed()
	return 0
end
