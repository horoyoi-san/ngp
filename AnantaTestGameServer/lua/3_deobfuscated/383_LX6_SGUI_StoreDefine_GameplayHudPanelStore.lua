C_GameplayHudPanelStore = DefClass("C_GameplayHudPanelStore", C_GameplayHudPanelStore, C_StoreGroup)
GroupName2Class.GameplayHudPanelStore = C_GameplayHudPanelStore
local M = C_GameplayHudPanelStore
local ShowType = {
	FALSE = 0,
	TRUE = 1
}
local UPDATE_MODE = {
	END_ANIME = 4,
	START_ANIME = 2,
	END_COUNTING = 3,
	START_COUNTING = 1,
	NONE = 0
}

function M:ctor()
	self.TypeIdMap = {
		HackInteract = gGameplayType.HACK_INTERACT,
		DiaoChe = gGameplayType.DIAO_CHE,
		Darts = gGameplayType.DARTS,
		SandDraw = gGameplayType.SAND_DRAW,
		Fitness = gGameplayType.FITNESS,
		RestaurantOrder = gGameplayType.RESTAURANT_ORDER,
		RestaurantInteraction = gGameplayType.RESTAURANT_INTERACTION,
		BasketballGame = gGameplayType.BASKETBALL_GAME,
		BengDi = gGameplayType.BENG_DI,
		AnimalInteraction = gGameplayType.ANIMAL_INTERACTION,
		Beggar = gGameplayType.BEGGAR_PANEL,
		ChengGanTiao = gGameplayType.CHENG_GAN_TIAO_PANEL,
		StepOnBamboo = gGameplayType.STEP_ON_BAMBOO_PANEL,
		GaoQiao = gGameplayType.GAO_QIAO_PANEL,
		CommonPressBar = gGameplayType.COMMON_PRESS_BAR
	}
	self.HasPC = {
		[gGameplayType.FITNESS] = true,
		[gGameplayType.BENG_DI] = true
	}
	self.startCountDownTime = -1
	self.countDownTime = -1
	self.backBtnCb = nil
	self.switchViewBtnCb = nil
	self.startCountDownCb = nil
	self.timeCountDownStart = -1
	self.startLabelShowTime = 0.5
	self.startAnimeCb = nil
	self.timeAnimeStart = -1
	self.endCountDownCb = nil
	self.timeCountDownEnd = -1
	self.timeCountDownEndFull = -1
	self.timeCountDownWarning = -1
	self.endAnimeCb = nil
	self.timeAnimeEnd = -1
	self.updateMode = UPDATE_MODE.NONE
	self.pause = false
	self.showData = nil
	self.playType = -1
	self.firstShow = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.gamepadUpdateRotate = false
	self.gamepadMode = false
end

function M:OnAwake()
	self.bindData.btnExit.luaClick = self:CreateAction("OnBtnExitClick")
	self.bindData.btnSwitchView.luaClick = self:CreateAction("OnBtnSwitchViewClick")
	self.bindData.rootTabRect.OnGenerateTab = self:CreateAction("OnTabGenerate")
	self.bindData.rootTabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnShow(panelId, data)
	self.playType = -1

	if data then
		if data.gameplayType then
			self.playType = self.TypeIdMap[data.gameplayType] or -1
		end

		if data.gamePlayTypeId then
			self.playType = data.gamePlayTypeId or -1
		end
	end

	self.showData = data.params

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.HasPC[self.playType] then
		self.playType = self.playType + 1
	end

	self.backBtnCb = data and data.backCallback

	if self.curTypeStore and self.bindData.rootTabRect.selectedIndex and self.bindData.rootTabRect.selectedIndex ~= self.playType then
		self.curTypeStore:OnClose()
	end

	self.bindData.rootTabRect.selectedIndex = self.playType
	self.firstShow = true

	self:SetHideNodeScale(false)
end

function M:OnClose()
	self.showData = nil

	if self.curTypeStore then
		self.curTypeStore:OnClose()

		self.curTypeStore = nil
	end

	self.backBtnCb = nil
	self.switchViewBtnCb = nil
	self.firstShow = false
	self.playType = -1
end

function M:OnUpdate()
	if self.gamepadMode then
		self:UpdateCameraRotateGamePad()
	end

	if self.updateMode <= UPDATE_MODE.NONE or self.pause then
		return
	end

	if self.updateMode == UPDATE_MODE.START_COUNTING then
		if self.timeCountDownStart > 0 then
			if self.timeCountDownStart < self.startLabelShowTime then
				if self.bindData.showLabelCtrl ~= ShowType.TRUE then
					self.bindData.showLabelCtrl = ShowType.TRUE
				end
			else
				self.bindData.startCountDownTime = self:GetStartTime(self.timeCountDownStart - self.startLabelShowTime)
			end

			self.timeCountDownStart = self.timeCountDownStart - Time.deltaTime
		else
			self.bindData.showStartCountDownCtrl = ShowType.FALSE
			self.bindData.showLabelCtrl = ShowType.FALSE

			self:SetHideNodeState(true)

			if self.startCountDownCb then
				self.startCountDownCb()

				self.startCountDownCb = nil
			end

			self.updateMode = UPDATE_MODE.NONE
		end
	end

	if self.updateMode == UPDATE_MODE.START_ANIME then
		if self.timeAnimeStart > 0 then
			self.timeAnimeStart = self.timeAnimeStart - Time.deltaTime
		else
			self.bindData.showStartAnimeCtrl = ShowType.FALSE

			self:SetHideNodeState(true)

			if self.startAnimeCb then
				self.startAnimeCb()

				self.startAnimeCb = nil
			end

			self.updateMode = UPDATE_MODE.NONE
		end
	end

	if self.updateMode == UPDATE_MODE.END_COUNTING then
		if self.timeCountDownEnd > 0 then
			self.bindData.endCountDownTime = self:GetEndTime(self.timeCountDownEnd)
			local percent = self.timeCountDownEnd / self.timeCountDownEndFull
			self.bindData.countDownFillAmount = percent

			if self.timeCountDownEnd <= self.timeCountDownWarning then
				self.bindData.countDownWarningCtrl = ShowType.TRUE
			end

			self.timeCountDownEnd = self.timeCountDownEnd - Time.deltaTime
		else
			self.bindData.showEndCountDownCtrl = ShowType.FALSE

			if self.endCountDownCb then
				self.endCountDownCb()

				self.endCountDownCb = nil
			end

			self.updateMode = UPDATE_MODE.NONE
		end
	end

	if self.updateMode == UPDATE_MODE.END_ANIME then
		if self.timeAnimeEnd > 0 then
			self.timeAnimeEnd = self.timeAnimeEnd - Time.deltaTime
		else
			self.bindData.showEndAnimeCtrl = ShowType.FALSE

			self:SetHideNodeState(true)

			if self.endAnimeCb then
				self.endAnimeCb()

				self.endAnimeCb = nil
			end

			self.updateMode = UPDATE_MODE.NONE
		end
	end
end

function M:OnBtnExitClick()
	if self.backBtnCb then
		self.backBtnCb()
	else
		gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	end
end

function M:OnBtnSwitchViewClick()
	if self.switchViewBtnCb then
		self.switchViewBtnCb()
	end
end

function M:ClosePanel()
	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
end

function M:RegisterBtnBackCallback(backCallback)
	self.backBtnCb = backCallback
end

function M:RegisterBtnSwitchViewCallback(callback)
	self.switchViewBtnCb = callback
end

function M:SetBtnSwitchViewState(isShow)
	self.bindData.showSwitchViewBtnCtrl = isShow and 1 or 0
end

function M:SetBtnBackState(isShow)
	self.bindData.showExitBtnCtrl = isShow and 1 or 0
end

function M:SetHideNodeState(isShow)
	self.bindData.hideNode.gameObject:SetActive(isShow)
end

function M:SetHideNodeScale(isShow)
	self.bindData.hideNode.localScale = isShow and Vector3.one or Vector3.zero
end

function M:SetRayBoxState(isShow)
	self.bindData.showRayBox = isShow and 1 or 0
end

function M:OpenStartCountDown(timeSecond, callback)
	self:ClearState()

	self.startCountDownCb = callback
	self.timeCountDownStart = timeSecond + self.startLabelShowTime
	self.updateMode = UPDATE_MODE.START_COUNTING
	self.bindData.showStartCountDownCtrl = ShowType.TRUE
	self.bindData.showLabelCtrl = ShowType.FALSE
	self.bindData.startCountDownTime = self:GetStartTime(timeSecond)

	self:SetHideNodeState(false)
end

function M:OpenEndCountDown(timeSecond, callback, timeWarning)
	self:ClearState()

	self.endCountDownCb = callback
	self.timeCountDownEnd = timeSecond
	self.timeCountDownEndFull = timeSecond
	self.timeCountDownWarning = timeWarning or -1

	if self.timeCountDownEnd <= self.timeCountDownWarning then
		self.timeCountDownWarning = -1
	end

	self.updateMode = UPDATE_MODE.END_COUNTING
	self.bindData.showEndCountDownCtrl = ShowType.TRUE
	self.bindData.countDownWarningCtrl = ShowType.FALSE
	self.bindData.countDownFillAmount = 1
	self.bindData.endCountDownTime = self:GetEndTime(timeSecond)
end

function M:OpenStartAnime(callback, text, iconId)
	self:ClearState()

	self.startAnimeCb = callback
	self.timeAnimeStart = self.bindData.beginAnim.clip.length
	self.updateMode = UPDATE_MODE.START_ANIME
	self.bindData.showStartAnimeCtrl = ShowType.TRUE
	self.bindData.beginText = text
	self.bindData.beginIconId = iconId

	self:SetHideNodeState(false)
end

function M:OpenEndAnime(callback, text, iconId)
	self:ClearState()

	self.endAnimeCb = callback
	self.timeAnimeEnd = 1
	self.updateMode = UPDATE_MODE.END_ANIME
	self.bindData.showEndAnimeCtrl = ShowType.TRUE
	self.bindData.endText = text
	self.bindData.endIconId = iconId

	self:SetHideNodeState(false)
end

function M:Pause()
	self.pause = true
end

function M:Resume()
	self.pause = false
end

function M:Reset()
	self.startCountDownTime = -1
	self.countDownTime = -1
	self.backBtnCb = nil
	self.switchViewBtnCb = nil
	self.startCountDownCb = nil
	self.timeCountDownStart = -1
	self.startLabelShowTime = 0.5
	self.startAnimeCb = nil
	self.timeAnimeStart = -1
	self.endCountDownCb = nil
	self.timeCountDownEnd = -1
	self.timeCountDownEndFull = -1
	self.timeCountDownWarning = -1
	self.endAnimeCb = nil
	self.timeAnimeEnd = -1
	self.updateMode = UPDATE_MODE.NONE
	self.bindData.showLabelCtrl = ShowType.FALSE
	self.bindData.showStartAnimeCtrl = ShowType.FALSE
	self.bindData.showStartCountDownCtrl = ShowType.FALSE
	self.bindData.showEndAnimeCtrl = ShowType.FALSE
	self.bindData.showEndCountDownCtrl = ShowType.FALSE
	self.bindData.countDownWarningCtrl = ShowType.FALSE
	self.bindData.countDownFillAmount = 1

	self:SetHideNodeState(true)
end

function M:GetStartTime(time)
	return time <= 0 and 0 or math.ceil(time)
end

function M:GetEndTime(time)
	local rawMin = time <= 0 and 0 or math.floor(time / 60)
	local rawSec = time <= 0 and 0 or math.ceil(time - rawMin * 60)

	return gString.Format("%02d:%02d", rawMin, rawSec)
end

function M:ClearState()
	self.startCountDownTime = -1
	self.countDownTime = -1
	self.startCountDownCb = nil
	self.timeCountDownStart = -1
	self.startLabelShowTime = 0.5
	self.startAnimeCb = nil
	self.timeAnimeStart = -1
	self.endCountDownCb = nil
	self.timeCountDownEnd = -1
	self.timeCountDownWarning = -1
	self.timeCountDownEndFull = -1
	self.endAnimeCb = nil
	self.timeAnimeEnd = -1
	self.updateMode = UPDATE_MODE.NONE
	self.bindData.showLabelCtrl = ShowType.FALSE
	self.bindData.showStartAnimeCtrl = ShowType.FALSE
	self.bindData.showStartCountDownCtrl = ShowType.FALSE
	self.bindData.showEndAnimeCtrl = ShowType.FALSE
	self.bindData.showEndCountDownCtrl = ShowType.FALSE
	self.bindData.countDownWarningCtrl = ShowType.FALSE
	self.bindData.countDownFillAmount = 1
	self.pause = false
end

function M:OnTabGenerate()
	if self.firstShow then
		self.firstShow = false

		self:SetHideNodeScale(true)
	end
end

function M:OnRenderTab(index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(nil, self.showData)
	end
end

function M:OnRightStickControl(context)
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
	end
end

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if gCS.ShootModule.GetIsInVehicleShootState(csUnit) or gCS.ShootModule.GetIsInVehicleForwardShootState(csUnit) then
		gCameraUtils:DoRotateCameraByGamePad(6, self.rightStickValue.x, self.rightStickValue.y)
	else
		gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
	end
end
