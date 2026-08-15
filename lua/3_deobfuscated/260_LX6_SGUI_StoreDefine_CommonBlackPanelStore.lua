local GuiMgr = LX6.GUI.GuiMgr
local STATE = {
	OPEN = 1,
	STAY = 2,
	CLOSE = 3,
	STANDBY = 0
}
C_CommonBlackPanelStore = DefClass("C_CommonBlackPanelStore", C_CommonBlackPanelStore, C_StoreGroup)
GroupName2Class.CommonBlackPanelStore = C_CommonBlackPanelStore
local M = C_CommonBlackPanelStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

function M:ctor()
	self.DEFINE_DynamicOnUpdate = true
	self.openTime = 0
	self.stayTime = 0
	self.closeTime = 0
	self.waitTime = -1
	self.state = STATE.STANDBY
	self.defaultOpenTime = 1
	self.defaultStayTime = 0
	self.defaultCloseTime = 1
	self.banControl = false
	self.openCallback = nil
	self.stayCallback = nil
	self.closeCallback = nil
end

function M:OnAwake()
	gBlackScreenManager.blackPanel = self
end

function M:OnDestroy()
	gBlackScreenManager.blackPanel = nil
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.bindData.alpha = 1
	self.bindData.showBlack = BOOL2CTL[false]
end

function M:OnClose()
	if self.banControl then
		self:Reset()
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnUpdate()
	if self.waitTime < 0 then
		return
	end

	if self.state == STATE.OPEN then
		self.waitTime = self.waitTime - Time.deltaTime

		if self.waitTime < 0 then
			self.state = STATE.STAY
			self.waitTime = self.stayTime
			self.bindData.alpha = 1

			if self.openCallback then
				local cb = self.openCallback
				self.openCallback = nil

				cb()
			end
		else
			self.bindData.alpha = self.openTime > 0 and (self.openTime - self.waitTime) / self.openTime or 1
		end
	elseif self.state == STATE.STAY then
		self.waitTime = self.waitTime - Time.deltaTime

		if self.waitTime < 0 then
			self.state = STATE.CLOSE
			self.waitTime = self.closeTime

			if self.stayCallback then
				local cb = self.stayCallback
				self.stayCallback = nil

				cb()
			end
		end
	elseif self.state == STATE.CLOSE then
		self.waitTime = self.waitTime - Time.deltaTime

		if self.waitTime < 0 then
			if self.closeCallback then
				local cb = self.closeCallback
				self.closeCallback = nil

				cb()
			end

			self:Reset()
		else
			self.bindData.alpha = self.closeTime > 0 and self.waitTime / self.closeTime or 0
		end
	end
end

function M:SetTransitionState(state, openTime, stayTime, closeTime)
	self.state = state
	self.openTime = openTime or -1
	self.stayTime = stayTime or -1
	self.closeTime = closeTime or -1

	if state == STATE.OPEN then
		self.bindData.showBlack = BOOL2CTL[true]
		self.waitTime = self.openTime
	elseif state == STATE.STAY then
		self.bindData.showBlack = BOOL2CTL[true]
		self.waitTime = self.stayTime
	elseif state == STATE.CLOSE then
		self.bindData.showBlack = BOOL2CTL[true]
		self.waitTime = self.closeTime
	else
		self.waitTime = -1
	end
end

function M:SetStateCallback(OpenEndCallback, StayEndCallback, CloseEndCallback)
	self.openCallback = OpenEndCallback
	self.stayCallback = StayEndCallback
	self.closeCallback = CloseEndCallback
end

function M:ClearAndTriggerStateCallback()
	if self.openCallback then
		self.openCallback()

		self.openCallback = nil
	end

	if self.stayCallback then
		self.stayCallback()

		self.stayCallback = nil
	end

	if self.closeCallback then
		self.closeCallback()

		self.closeCallback = nil
	end
end

function M:SetStyle(isWhite)
	self.bindData.color = isWhite and 1 or 0
end

function M:DisableControl(force)
	if not self.banControl or force then
		GuiMgr.Instance:SetShowScenePanel(true, gPanelId.COMMON_BLACK_TRANSITION)
		gPanelManager:SetVisibleMode(LX6.Manager.VisibleControlType.CommonBlack, LX6.Manager.VisibleMode.Front)
		LX6.Manager.GameInputManager.SetDisableInput(gPanelId.COMMON_BLACK_TRANSITION)

		self.banControl = true
	end
end

function M:EnableControl()
	if self.banControl then
		GuiMgr.Instance:SetShowScenePanel(false, gPanelId.COMMON_BLACK_TRANSITION)
		gPanelManager:RemoveVisibleMode(LX6.Manager.VisibleControlType.CommonBlack)
		LX6.Manager.GameInputManager.SetEnableInput(gPanelId.COMMON_BLACK_TRANSITION)

		self.banControl = false
	end
end

function M:Reset()
	self:SetTransitionState(STATE.STANDBY)
	self:SetStyle(false)
	self:EnableControl()

	self.bindData.alpha = 1
	self.bindData.showBlack = BOOL2CTL[false]
	self.openCallback = nil
	self.stayCallback = nil
	self.closeCallback = nil

	gBlackScreenManager:OnTransitionEnd()
	gNpcChatManager:OnPanelClose()
	gStoreManager:UnregisterDynamicOnUpdate(self)
end

function M:SetTransition(text, isWhite, openTime, stayTime, closeTime, openCb, stayCb, closeCb)
	self:ClearAndTriggerStateCallback()
	self:DisableControl()
	self:SetStyle(isWhite)
	self:SetTransitionState(STATE.OPEN, openTime, stayTime, closeTime)
	self:SetStateCallback(openCb, stayCb, closeCb)

	self.bindData.alpha = 1

	if openTime == 0 then
		self:OnUpdate()
	elseif openTime > 0 then
		self.bindData.alpha = 0
	end

	gStoreManager:RegisterDynamicOnUpdate(self)
end

function M:CloseTransition()
	if self.openCallback then
		self.openCallback()

		self.openCallback = nil
	end

	if self.stayCallback then
		self.stayCallback()

		self.stayCallback = nil
	end

	self:SetTransitionState(STATE.CLOSE, -1, -1, self.closeTime)

	self.bindData.alpha = 0

	if self.closeTime == 0 then
		self:OnUpdate()
	end
end

function M:UpdateTransitionClose(closeTime, stayCb, closeCb)
	self.closeTime = closeTime or self.closeTime
	self.stayCallback = stayCb or self.stayCallback
	self.closeCallback = closeCb or self.closeCallback
end
