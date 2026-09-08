-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineLongPressPanelStore.lua
-- Decompiled from: 01354_TimelineLongPressPanelStore.lua_022b96bd72df.luajit

C_TimelineLongPressPanelStore = DefClass("C_TimelineLongPressPanelStore", C_TimelineLongPressPanelStore, C_StoreGroup)
GroupName2Class.TimelineLongPressPanelStore = C_TimelineLongPressPanelStore
local M = C_TimelineLongPressPanelStore

M.ctor = function(self)
end

M.GetBtnStore = function(self, widget)
	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end

M.DefineAllVariables = function(self)
	self.openAnimName = "S_Vx_TimelineClickTimeScalePanel_open"
	self.finishAnimName = "S_Vx_TimelineClickTimeScalePanel_Finish"
	self.clickAnimName_mouse = "S_Vx_TimelineMultipleTapPanel_Mouse_Click"
	self.failAnimName = "S_Vx_TimelineClickTimeScalePanel_Fail"
	self.trigger1 = false
	self.trigger2 = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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
	local paramTable = data.ToTable(data)
	self.useSingleBtn = paramTable.singleButton
	self.pcBtn_store = self.GetBtnStore(self, self.bindData.pcBtn)
	self.pcBtn_store.progressMode = paramTable.progressType

	self.SetPos(self, self.pcBtn_store, paramTable.btn1_pos, paramTable.btn1_customPos, paramTable.btn1_customPosOffset)
	self.SetPcBtnMode(self, self.pcBtn_store, paramTable.btn1_pcKey, paramTable.btn1_pcKeyIconIndex)
	self.PlayOpenAnim(self, self.pcBtn_store)

	if not self.useSingleBtn then
		self.pcBtn2_store = self.GetBtnStore(self, self.bindData.pcBtn2)
		self.pcBtn2_store.progressMode = paramTable.progressType

		self.SetPos(self, self.pcBtn2_store, paramTable.btn2_pos, paramTable.btn2_customPos, paramTable.btn2_customPosOffset)
		self.SetPcBtnMode(self, self.pcBtn2_store, paramTable.btn2_pcKey, paramTable.btn2_pcKeyIconIndex)
		self.PlayOpenAnim(self, self.pcBtn2_store)
	else
		self.bindData.pcBtn2:SetActive(false)
	end

	self.btn1_store = self.GetBtnStore(self, self.bindData.controllerBtn1)
	self.btn1_store.progressMode = paramTable.progressType

	self.SetPos(self, self.btn1_store, paramTable.btn1_pos, paramTable.btn1_customPos, paramTable.btn1_customPosOffset)
	self.SetControllerBtnMode(self, self.btn1_store, paramTable.btn1_controllerKey, paramTable.btn1_controllerStyle)
	self.PlayOpenAnim(self, self.btn1_store)

	if not self.useSingleBtn then
		self.btn2_store = self.GetBtnStore(self, self.bindData.controllerBtn2)
		self.btn2_store.progressMode = paramTable.progressType

		self.SetPos(self, self.btn2_store, paramTable.btn2_pos, paramTable.btn2_customPos, paramTable.btn2_customPosOffset)
		self.SetControllerBtnMode(self, self.btn2_store, paramTable.btn2_controllerKey, paramTable.btn2_controllerStyle)
		self.PlayOpenAnim(self, self.btn2_store)
	else
		self.bindData.controllerBtn2:SetActive(false)
	end

	self.mobileBtn1_store = self:GetBtnStore(self.bindData.mobileBtn1)
	self.mobileBtn1_store.progressMode = paramTable.progressType

	self:SetPos(self.mobileBtn1_store, paramTable.btn1_pos, paramTable.btn1_customPos, paramTable.btn1_customPosOffset, paramTable.btn1_mobilePos and paramTable.btn1_mobilePos or 1)
	self:PlayOpenAnim(self.mobileBtn1_store)
	self:SetMobileIcon(self.mobileBtn1_store, paramTable.mobileIconId)

	if not self.useSingleBtn then
		self.mobileBtn2_store = self:GetBtnStore(self.bindData.mobileBtn2)
		self.mobileBtn2_store.progressMode = paramTable.progressType

		self:SetPos(self.mobileBtn2_store, paramTable.btn2_pos, paramTable.btn2_customPos, paramTable.btn2_customPosOffset, paramTable.btn2_mobilePos and paramTable.btn2_mobilePos or 0)
		self:PlayOpenAnim(self.mobileBtn2_store)
		self:SetMobileIcon(self.mobileBtn2_store, paramTable.mobileIconId2)
	else
		self.bindData.mobileBtn2:SetActive(false)
	end

	self.SetBtnSize(self, paramTable)
	self.HideBtn(self, paramTable)
	self.SetAdaptive(self, paramTable)
	self.SetProgress0(self, 0)
	self.SetProgress1(self, 0)
end

M.SetPos = function(self, store, posType, customPos, customPosOffset, mobilePos)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		store.posType = posType

		if store.posType ~= "Custom" then
			store.targetPos = customPos
			store.customPosOffset = customPosOffset
		else
			store.targetPos = self.bindData[posType]
		end

		if posType ~= "Custom" then
			if store.targetPos then
				local uiPos = gCS.LuaUtils.CalcPositionInScreen(store.buttonRT.parent, store.targetPos.position)
				store.buttonRT.anchoredPosition = uiPos + store.customPosOffset
			else
				store.buttonRT.anchoredPosition = store.customPosOffset
			end
		elseif store.targetPos then
			store.buttonRT.anchoredPosition = store.targetPos.anchoredPosition
		end
	else
		gTimelineManager:SetMobilePos(store, mobilePos)
	end
end

M.HideBtn = function(self, panelData)
	if panelData.hideBtn then
		self.bindData.controllerBtn1:SetActiveQuickly(false)
		self.bindData.controllerBtn2:SetActiveQuickly(false)
		self.bindData.pcBtn:SetActiveQuickly(false)
		self.bindData.pcBtn2:SetActiveQuickly(false)
		self.bindData.mobileBtn1:SetActiveQuickly(false)
		self.bindData.mobileBtn2:SetActiveQuickly(false)
	end
end

M.UpdatePos = function(self, store)
	if not store then
		return
	end

	if store.posType ~= "Custom" and store.targetPos then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(store.buttonRT.parent, store.targetPos.position)
		store.buttonRT.anchoredPosition = uiPos + store.customPosOffset
	end
end

M.SetBtnSize = function(self, panelData)
	self.bindData.buttonSize = panelData.buttonSize ~= "Small" and 1 or 0
end

M.OnUpdate = function(self)
	self.UpdatePos(self, self.pcBtn_store)
	self.UpdatePos(self, self.btn1_store)
	self.UpdatePos(self, self.btn2_store)
	self.UpdatePos(self, self.mobileBtn1_store)
	self.UpdatePos(self, self.mobileBtn2_store)
	self.SendTriggerStatus(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.controllerBtn1.luaPress = self.CreateAction(self, "OnPressBtn1")
	self.bindData.controllerBtn2.luaPress = self.CreateAction(self, "OnPressBtn2")
	self.bindData.mobileBtn1.luaPress = self.CreateAction(self, "OnPressBtn1")
	self.bindData.mobileBtn2.luaPress = self.CreateAction(self, "OnPressBtn2")
	self.bindData.pcBtn.luaPress = self.CreateAction(self, "OnPressBtn1")
	self.bindData.pcBtn2.luaPress = self.CreateAction(self, "OnPressBtn2")
	self.bindData.controllerBtn1.luaRelease = self.CreateAction(self, "OnReleaseBtn1")
	self.bindData.controllerBtn2.luaRelease = self.CreateAction(self, "OnReleaseBtn2")
	self.bindData.mobileBtn1.luaRelease = self.CreateAction(self, "OnReleaseBtn1")
	self.bindData.mobileBtn2.luaRelease = self.CreateAction(self, "OnReleaseBtn2")
	self.bindData.pcBtn.luaRelease = self.CreateAction(self, "OnReleaseBtn1")
	self.bindData.pcBtn2.luaRelease = self.CreateAction(self, "OnReleaseBtn2")
end

M.SetMobileIcon = function(self, store, iconId)
	if iconId and iconId == 0 then
		store.mobileIcon = iconId

		return
	end
end

M.SetPcBtnMode = function(self, store, pcKey, pcKeyIconIndex)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if pcKey then
		store.clickBtn:SetPCKeyInfoWithOutTip(pcKey)

		if pcKey ~= 8 then
			store.pcKeyMode = 0
		elseif pcKey ~= 9 then
			store.pcKeyMode = 1
		else
			local cfg = LTConfig.InputSGUIPCKeyConfig.GetConfig(pcKey)

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

M.SetControllerBtnMode = function(self, store, controllerKey, controllerStyle)
	if not controllerKey or not controllerStyle then
		return
	end

	self.bindData.navArea:ChangeActionIdByResponse(store.clickBtn, controllerKey)
	store.controllerImg:ChangeImageAction(controllerKey, 0, store.clickBtn, 0, controllerStyle)
	store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", controllerKey, controllerStyle)
end

M.SendTriggerStatus = function(self)
	local data = 0

	if self.trigger1 then
		data = data + 1
	end

	if self.trigger2 then
		data = data + 2
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, data)
end

M.OnPressBtn1 = function(self)
	self.trigger1 = true
end

M.OnPressBtn2 = function(self)
	self.trigger2 = true
end

M.OnReleaseBtn1 = function(self)
	self.trigger1 = false
end

M.OnReleaseBtn2 = function(self)
	self.trigger2 = false
end

M.PlayOpenAnim = function(self, store)
	if not store or not store.animation then
		return
	end

	local clip = store.animation:GetClip(self.openAnimName)

	if clip then
		self.openAnimLength = clip.length

		store.Play(store, self.openAnimName)
	end
end

M.PlayEndAnim = function(self, store)
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

	if self.mobileBtn1_store.countdownProgressImage then
		self.mobileBtn1_store.countdownProgressImage.fillAmount = progress
	end

	if self.mobileBtn1_store.progress then
		self.mobileBtn1_store.progress.value = progress
	end

	if self.pcBtn_store.countdownProgressImage then
		self.pcBtn_store.countdownProgressImage.fillAmount = progress
	end

	if self.pcBtn_store.progress then
		self.pcBtn_store.progress.value = progress
	end
end

M.SetProgress1 = function(self, progress)
	if self.btn2_store then
		if self.btn2_store.countdownProgressImage then
			self.btn2_store.countdownProgressImage.fillAmount = progress
		end

		if self.btn2_store.progress then
			self.btn2_store.progress.value = progress
		end
	end

	if self.mobileBtn2_store then
		if self.mobileBtn2_store.countdownProgressImage then
			self.mobileBtn2_store.countdownProgressImage.fillAmount = progress
		end

		if self.mobileBtn2_store.progress then
			self.mobileBtn2_store.progress.value = progress
		end
	end
end

M.PlayClickAnimByCS = function(self, btn2)
end

M.HideButtonByCS = function(self, mask)
	self.bindData.pcBtn:SetActiveQuickly(false)
	self.bindData.pcBtn2:SetActiveQuickly(false)
	self.bindData.controllerBtn1:SetActiveQuickly(false)
	self.bindData.controllerBtn2:SetActiveQuickly(false)
	self.bindData.mobileBtn1:SetActiveQuickly(false)
	self.bindData.mobileBtn2:SetActiveQuickly(false)
end

M.PlaySuccessEndAnim = function(self)
	local duration = 0
	duration = math.max(duration, self.PlayEndAnim(self, self.btn1_store))
	duration = math.max(duration, self.PlayEndAnim(self, self.mobileBtn1_store))
	duration = math.max(duration, self.PlayEndAnim(self, self.pcBtn_store))

	return duration
end

M.PlaySuccessEndAnim2 = function(self)
	local duration = 0
	duration = math.max(duration, self.PlayEndAnim(self, self.btn2_store))
	duration = math.max(duration, self.PlayEndAnim(self, self.mobileBtn2_store))

	return duration
end

M.ClosePanelFailed = function(self)
	return 0
end
