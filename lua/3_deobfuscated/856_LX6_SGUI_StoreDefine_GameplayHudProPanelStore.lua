local GameplayHudDescConfig = LTConfig.GameplayHudDescConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
local GameplayHudDescGroupConfig = LTConfig.GameplayHudDescGroupConfig
local GameplayHudDescCameraSetConfig = LTConfig.GameplayHudDescCameraSetConfig
local DisplayType = LTConfig.GameplayHudDescConfig.displayModeType
local CheckStateType = LTConfig.GameplayHudDescConfig.checkStateType
C_GameplayHudProPanelStore = DefClass("C_GameplayHudProPanelStore", C_GameplayHudProPanelStore, C_StoreGroup)
GroupName2Class.GameplayHudProPanelStore = C_GameplayHudProPanelStore
local M = C_GameplayHudProPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local UPDATE_MODE = {
	END_ANIME = 4,
	START_ANIME = 2,
	END_COUNTING = 3,
	START_COUNTING = 1,
	NONE = 0
}
local TYPE = {
	SWITCH = 1,
	BTN = 2
}

function M:ctor()
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
	self.checkAction = {}
	self.drawCount = 0
	self.btnList = {}
	self.switchList = {}
	self.curTypeStore = nil
	self.closeCb = nil
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.gamepadUpdateRotate = false
	self.gamepadMode = false
	self.cfg = nil
	self.mgr = gBehaviorInteractManager
	self.behaviorCheckAction = self:CreateAction("CheckInInteract", self.mgr)
end

function M:OnAwake()
	self.bindData.btnExit.luaClick = self:CreateAction("OnBtnExitClick")
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
	self.bindData.btnList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnBtnRenderItem, TYPE.BTN)
	self.bindData.btnList.onGetTIndex = self:CreateAction(self.OnGetTIndex)
	self.bindData.switchList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnBtnRenderItem, TYPE.SWITCH)
	self.bindData.rootTabRect.OnGenerateTab = self:CreateAction("OnTabGenerate")
	self.bindData.rootTabRect.OnRenderTab = self:CreateAction("OnRenderTab")
end

function M:OnRenderTab(index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(nil, self.showData)
	end
end

function M:OnTabGenerate()
	return
end

function M:OnGetTIndex(index)
	return self.btnList[index + 1].tIndex
end

function M:OnBtnRenderItem(type, btn, index)
	local data = type == TYPE.SWITCH and self.switchList[index + 1] or self.btnList[index + 1]
	local store = self:GetStoreByWidget(btn)
	local btnId = data.btnId
	local btnCfg = GameplayHudDescConfig.GetConfig(btnId)

	if not btnCfg then
		return
	end

	local nameId = btnCfg.name

	if store then
		local nameCfg = InputButtonNameConfig.GetConfig(nameId)
		store.iconId = btnCfg.icon
		store.nameLabel = nameCfg and nameCfg.Name
	end

	local actionTaget = string.is_null_or_empty(btnCfg.actionTarget) and self or _G[btnCfg.actionTarget]
	local checkAction = nil

	if btnCfg.checkAction then
		checkAction = self:CreateAction(btnCfg.checkAction, actionTaget)
	elseif btnCfg.behaviorSignal > 0 then
		if btnCfg.checkBehaviorSignal > 0 then
			checkAction = self:CreateActionWithArgs("CheckBehaviorInteract", btnCfg.checkBehaviorSignal, self.mgr)
		else
			checkAction = self.behaviorCheckAction
		end
	end

	if checkAction then
		self.checkAction[btnId] = function ()
			if not btn then
				return
			end

			local state = checkAction()

			if btnCfg.checkState == CheckStateType.Active then
				btn:SetActive(state)
			elseif btnCfg.checkState == CheckStateType.Interactable then
				btn.interactable = state
			end
		end

		self.checkAction[btnId]()
	end

	local registerAction = false

	if not string.is_null_or_empty(btnCfg.action) then
		btn.luaClick = self:CreateAction(btnCfg.action, actionTaget)
		registerAction = true
	elseif not string.is_null_or_empty(btnCfg.pressAction) then
		btn.luaBeginLongPress = self:CreateAction(btnCfg.pressAction, actionTaget)
		btn.luaEndLongPress = self:CreateAction(btnCfg.releaseAction, actionTaget)
		registerAction = true
	elseif btnCfg.behaviorSignal > 0 then
		btn.luaClick = self:CreateActionWithArgs("SetSignalByIndex", btnCfg.behaviorSignal, self.mgr)
		registerAction = true
	end

	if registerAction then
		if btnCfg.pcKeyAction >= 0 then
			btn:SetPCKeyInfoWithIndex(btnCfg.pcKeyAction, nameId)
		else
			btn:SetPCKeyTipShowTip(false)
		end

		if btnCfg.gamePadAction >= 0 then
			self.bindData.navigationArea:AddClickBindToNavAreaWithIndex(btnCfg.gamePadAction, btn, nameId)
		else
			self.bindData.navigationArea:SetButtonInfoTipShowTip(false)
		end
	end

	self.drawCount = self.drawCount + 1

	if self.drawCount == #self.btnList + #self.switchList then
		self.bindData.navigationArea:RefreshGamePadBar()
	end
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnShow(panelId, data)
	if not table.isNilOrEmpty(data) then
		self.showData = data.params
		self.backBtnCb = data.backCallback
		self.switchViewBtnCb = data.switchViewCallback
		self.isfromBehvior = data.fromBehvior
		self.closeCb = data.closeCallback
	end

	self.bindData.VCam.gameObject:SetActive(false)

	local groupId = data and data.groupId or 0
	local groupCfg = GameplayHudDescGroupConfig.GetConfig(groupId)

	if groupCfg then
		self.cfg = groupCfg
		local groupList = groupCfg.btnList
		self.drawCount = 0
		self.btnList = {}
		self.switchList = {}

		for i = 1, #groupList do
			local ele = {
				tIndex = 0,
				btnId = groupList[i]
			}
			local btnCfg = GameplayHudDescConfig.GetConfig(groupList[i])

			if btnCfg.displayMode == DisplayType.Top then
				table.insert(self.switchList, ele)
			elseif btnCfg.displayMode == DisplayType.Bottom then
				table.insert(self.btnList, ele)
			else
				ele.tIndex = 1

				table.insert(self.btnList, ele)
			end
		end

		table.sort(self.btnList, function (a, b)
			return a.tIndex < b.tIndex
		end)
		self.bindData.switchList:SetSimpleList(#self.switchList)
		self.bindData.btnList:SetSimpleList(#self.btnList)

		local tabIndex = gCS.LuaUtils.IsNonMobileAdaptive() and groupCfg.pcTabIndex or groupCfg.tabIndex

		if self.curTypeStore and self.bindData.rootTabRect.selectedIndex and self.bindData.rootTabRect.selectedIndex ~= tabIndex then
			self.curTypeStore:OnClose()
		end

		self.bindData.rootTabRect.selectedIndex = tabIndex

		gCS.GuiUtils.SetPanelHideCursor(self.m_Id, groupCfg.hideCursor)

		if groupCfg.exitBtnTip ~= 0 then
			self.bindData.btnExit:SetPCKeyInfoTipNameId(groupCfg.exitBtnTip)
			self.bindData.navigationArea:ChangeButtonNameByActionId(21, groupCfg.exitBtnTip)
		end
	else
		if self.curTypeStore then
			self.curTypeStore:OnClose()
		end

		self.bindData.rootTabRect.selectedIndex = -1
	end

	if data and data.showCallback then
		data.showCallback()
	end

	if self.isfromBehvior then
		self:SetBtnBackState(self.mgr.cs_mgr.signal == 0)
	end
end

function M:OnClose()
	if self.curTypeStore then
		self.curTypeStore:OnClose()

		self.curTypeStore = nil
	end

	if self.closeCb then
		self.closeCb()

		self.closeCb = nil
	end

	self.showData = nil
	self.backBtnCb = nil
	self.switchViewBtnCb = nil
	self.checkAction = {}
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
				if self.bindData.showLabelCtrl ~= BOOL2CTL[true] then
					self.bindData.showLabelCtrl = BOOL2CTL[true]
				end
			else
				self.bindData.startCountDownTime = self:GetStartTime(self.timeCountDownStart - self.startLabelShowTime)
			end

			self.timeCountDownStart = self.timeCountDownStart - Time.deltaTime
		else
			self.bindData.showStartCountDownCtrl = BOOL2CTL[false]
			self.bindData.showLabelCtrl = BOOL2CTL[false]

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
			self.bindData.showStartAnimeCtrl = BOOL2CTL[false]

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
				self.bindData.countDownWarningCtrl = BOOL2CTL[true]
			end

			self.timeCountDownEnd = self.timeCountDownEnd - Time.deltaTime
		else
			self.bindData.showEndCountDownCtrl = BOOL2CTL[false]

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
			self.bindData.showEndAnimeCtrl = BOOL2CTL[false]

			if self.endAnimeCb then
				self.endAnimeCb()

				self.endAnimeCb = nil
			end

			self.updateMode = UPDATE_MODE.NONE
		end
	end
end

function M:OnBtnExitClick()
	if self.isfromBehvior then
		self.mgr:OnExit()

		return
	end

	if self.backBtnCb then
		self.backBtnCb()

		return
	end

	gPanelManager:Close(self.m_Id)
end

function M:OnBtnSwitchViewClick()
	if self.switchViewBtnCb then
		self.switchViewBtnCb(self.bindData.VCam)
	else
		self:OnSwitchCameraView(self.cameraSetId)
	end
end

function M:OnSwitchCameraView(cameraId)
	self.cameraSetId = cameraId
	local cfg = GameplayHudDescCameraSetConfig.GetConfig(self.cameraSetId)

	if cfg == nil then
		self.bindData.VCam.gameObject:SetActive(false)

		self.cameraSetId = self.cfg and self.cfg.startCamera or 0

		return
	end

	self.bindData.VCam.gameObject:SetActive(true)
	gUtils:SetCameraView(gCS.MyPlayerManager.PlayerUnit, cfg, self.bindData.VCam.gameObject)

	self.cameraSetId = cfg.NextCamera
end

function M:ClosePanel()
	gPanelManager:Close(self.m_Id)
end

function M:RegisterBtnBackCallback(backCallback)
	self.backBtnCb = backCallback
end

function M:SetBtnBackState(isShow)
	self.bindData.showExitBtnCtrl = BOOL2CTL[isShow]
end

function M:OpenStartCountDown(timeSecond, callback)
	self:ClearState()

	self.startCountDownCb = callback
	self.timeCountDownStart = timeSecond + self.startLabelShowTime
	self.updateMode = UPDATE_MODE.START_COUNTING
	self.bindData.showStartCountDownCtrl = BOOL2CTL[true]
	self.bindData.showLabelCtrl = BOOL2CTL[false]
	self.bindData.startCountDownTime = self:GetStartTime(timeSecond)
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
	self.bindData.showEndCountDownCtrl = BOOL2CTL[true]
	self.bindData.countDownWarningCtrl = BOOL2CTL[false]
	self.bindData.countDownFillAmount = 1
	self.bindData.endCountDownTime = self:GetEndTime(timeSecond)
end

function M:OpenStartAnime(callback, text, iconId)
	self:ClearState()

	self.startAnimeCb = callback
	self.timeAnimeStart = self.bindData.beginAnim.clip.length
	self.updateMode = UPDATE_MODE.START_ANIME
	self.bindData.showStartAnimeCtrl = BOOL2CTL[true]
	self.bindData.beginText = text
	self.bindData.beginIconId = iconId
end

function M:OpenEndAnime(callback, text, iconId)
	self:ClearState()

	self.endAnimeCb = callback
	self.timeAnimeEnd = 1
	self.updateMode = UPDATE_MODE.END_ANIME
	self.bindData.showEndAnimeCtrl = BOOL2CTL[true]
	self.bindData.endText = text
	self.bindData.endIconId = iconId
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
	self.bindData.showLabelCtrl = BOOL2CTL[false]
	self.bindData.showStartAnimeCtrl = BOOL2CTL[false]
	self.bindData.showStartCountDownCtrl = BOOL2CTL[false]
	self.bindData.showEndAnimeCtrl = BOOL2CTL[false]
	self.bindData.showEndCountDownCtrl = BOOL2CTL[false]
	self.bindData.countDownWarningCtrl = BOOL2CTL[false]
	self.bindData.countDownFillAmount = 1
end

function M:RefreshBtnState()
	for k, action in pairs(self.checkAction) do
		if action then
			action()
		end
	end
end

function M:SetEnable(enable)
	self.bindData.isEnable = BOOL2CTL[enable]
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
	self.bindData.showLabelCtrl = BOOL2CTL[false]
	self.bindData.showStartAnimeCtrl = BOOL2CTL[false]
	self.bindData.showStartCountDownCtrl = BOOL2CTL[false]
	self.bindData.showEndAnimeCtrl = BOOL2CTL[false]
	self.bindData.showEndCountDownCtrl = BOOL2CTL[false]
	self.bindData.countDownWarningCtrl = BOOL2CTL[false]
	self.bindData.countDownFillAmount = 1
	self.pause = false
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
