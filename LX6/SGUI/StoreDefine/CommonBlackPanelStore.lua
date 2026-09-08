-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonBlackPanelStore.lua
-- Decompiled from: 01440_CommonBlackPanelStore.lua_ed3cb7b6074c.luajit

local GuiMgr = LX6.GUI.GuiMgr
local STATE = {
	["UXu"] = 1,
	["I\\b"] = 2,
	["n\\x82\\x8d\\x9c\\x93"] = 3,
	["\\xea\\xef53:\\xc8"] = 0
}
C_CommonBlackPanelStore = DefClass("C_CommonBlackPanelStore", C_CommonBlackPanelStore, C_StoreGroup)
GroupName2Class.CommonBlackPanelStore = C_CommonBlackPanelStore
local M = C_CommonBlackPanelStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

M.ctor = function(self)
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

M.OnAwake = function(self)
	gBlackScreenManager.blackPanel = self
end

M.OnDestroy = function(self)
	gBlackScreenManager.blackPanel = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.alpha = 1
	self.bindData.showBlack = BOOL2CTL[false]
	self.bindData.alphaTL = 1
	self.bindData.showBlackTL = BOOL2CTL[false]
	self.bindData.showBlackEdge = BOOL2CTL[false]
	self.bindData.showBlackLoading = BOOL2CTL[false]
end

M.OnClose = function(self)
	if self.banControl then
		self.Reset(self)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnLanguageChange = function(self, lang)
end

M.OnUpdate = function(self)
	if self.waitTime >= 0 then
		return
	end

	if self.state ~= STATE.OPEN then
		self.waitTime = self.waitTime - Time.deltaTime

		if self.waitTime >= 0 then
			self.state = STATE.STAY
			self.waitTime = self.stayTime
			self.bindData.alpha = 1

			if self.openCallback then
				local cb = self.openCallback
				self.openCallback = nil

				cb()
			end
		else
			self.bindData.alpha = self.openTime <= 0 and (self.openTime - self.waitTime) / self.openTime or 1
		end
	elseif self.state ~= STATE.STAY then
		self.waitTime = self.waitTime - Time.deltaTime

		if self.waitTime >= 0 then
			self.state = STATE.CLOSE
			self.waitTime = self.closeTime

			if self.stayCallback then
				local cb = self.stayCallback
				self.stayCallback = nil

				cb()
			end
		end
	elseif self.state ~= STATE.CLOSE then
		self.waitTime = self.waitTime - Time.deltaTime

		if self.waitTime >= 0 then
			if self.closeCallback then
				local cb = self.closeCallback
				self.closeCallback = nil

				cb()
			end

			self.Reset(self)
		else
			self.bindData.alpha = self.closeTime <= 0 and self.waitTime / self.closeTime or 0
		end
	end
end

M.SetTransitionState = function(self, state, openTime, stayTime, closeTime)
	self.state = state
	self.openTime = openTime or -1
	self.stayTime = stayTime or -1
	self.closeTime = closeTime or -1

	if state ~= STATE.OPEN then
		self.bindData.showBlack = BOOL2CTL[true]
		self.waitTime = self.openTime
	elseif state ~= STATE.STAY then
		self.bindData.showBlack = BOOL2CTL[true]
		self.waitTime = self.stayTime
	elseif state ~= STATE.CLOSE then
		self.bindData.showBlack = BOOL2CTL[true]
		self.waitTime = self.closeTime
	else
		self.waitTime = -1
	end
end

M.SetStateCallback = function(self, OpenEndCallback, StayEndCallback, CloseEndCallback)
	self.openCallback = OpenEndCallback
	self.stayCallback = StayEndCallback
	self.closeCallback = CloseEndCallback
end

M.ClearAndTriggerStateCallback = function(self)
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

M.SetStyle = function(self, isWhite)
	self.bindData.color = isWhite and 1 or 0
end

M.SetStyleTL = function(self, isWhite)
	self.bindData.colorTL = isWhite and 1 or 0
end

M.SetStyleEdge = function(self, isWhite)
	self.bindData.colorEdge = isWhite and 1 or 0
end

M.DisableControl = function(self, force)
	if not self.banControl or force then
		GuiMgr.Instance:SetShowScenePanel(true, gPanelId.COMMON_BLACK_TRANSITION)
		gPanelManager:SetVisibleMode(LX6.Manager.VisibleControlType.CommonBlack, LX6.Manager.VisibleMode.Front)
		LX6.Manager.GameInputManager.SetDisableInput(gPanelId.COMMON_BLACK_TRANSITION)

		self.banControl = true
	end
end

M.EnableControl = function(self)
	if self.banControl then
		GuiMgr.Instance:SetShowScenePanel(false, gPanelId.COMMON_BLACK_TRANSITION)
		gPanelManager:RemoveVisibleMode(LX6.Manager.VisibleControlType.CommonBlack)
		LX6.Manager.GameInputManager.SetEnableInput(gPanelId.COMMON_BLACK_TRANSITION)

		self.banControl = false
	end
end

M.Reset = function(self)
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

M.SetTransition = function(self, text, isWhite, openTime, stayTime, closeTime, openCb, stayCb, closeCb)
	self.ClearAndTriggerStateCallback(self)
	self.DisableControl(self)
	self.SetStyle(self, isWhite)
	self.SetTransitionState(self, STATE.OPEN, openTime, stayTime, closeTime)
	self.SetStateCallback(self, openCb, stayCb, closeCb)

	self.bindData.alpha = 1

	if openTime ~= 0 then
		self.OnUpdate(self)
	elseif openTime <= 0 then
		self.bindData.alpha = 0
	end

	gStoreManager:RegisterDynamicOnUpdate(self)
end

M.CloseTransition = function(self)
	if self.openCallback then
		self.openCallback()

		self.openCallback = nil
	end

	if self.stayCallback then
		self.stayCallback()

		self.stayCallback = nil
	end

	self.SetTransitionState(self, STATE.CLOSE, -1, -1, self.closeTime)

	self.bindData.alpha = 0

	if self.closeTime ~= 0 then
		self.OnUpdate(self)
	end
end

M.UpdateTransitionClose = function(self, closeTime, stayCb, closeCb)
	self.closeTime = closeTime or self.closeTime
	self.stayCallback = stayCb or self.stayCallback
	self.closeCallback = closeCb or self.closeCallback
end

M.OpenBlackTL = function(self, isWhite)
	self.SetStyleTL(self, isWhite)

	self.bindData.showBlackTL = BOOL2CTL[true]
	self.bindData.alphaTL = 0
end

M.UpdateBlackTL = function(self, isWhite, alpha)
	self:SetStyleTL(isWhite)

	self.bindData.alphaTL = alpha or 0
end

M.CloseBlackTL = function(self)
	self.bindData.showBlackTL = BOOL2CTL[false]
	self.bindData.alphaTL = 1
end

M.OpenBlackLoading = function(self)
	self.bindData.showBlackLoading = BOOL2CTL[true]
end

M.CloseBlackLoading = function(self)
	self.bindData.showBlackLoading = BOOL2CTL[false]
end

M.OpenBlackEdge = function(self, isWhite)
	self.SetStyleEdge(self, isWhite)

	self.bindData.showBlackEdge = BOOL2CTL[true]

	if self.bindData.rectEdgeR and self.bindData.rectEdgeL then
		self.bindData.rectEdgeR.sizeDelta = Vector2(0, 0)
		self.bindData.rectEdgeL.sizeDelta = Vector2(0, 0)
	end
end

M.UpdateBlackEdge = function(self, isWhite, designW, designH, ScreenW, ScreenH, lerpValue)
	self:SetStyleEdge(isWhite)

	local refY = SGUI.UWidget.canvasScaler.referenceResolution.y
	local scaleFactor = ScreenH / refY
	local designRatio = designW / designH
	local width = (ScreenW - ScreenH * designRatio) / 2
	local value = lerpValue or 1

	if self.bindData.rectEdgeR and self.bindData.rectEdgeL then
		self.bindData.rectEdgeR.sizeDelta = Vector2(width / scaleFactor * value, 0)
		self.bindData.rectEdgeL.sizeDelta = Vector2(width / scaleFactor * value, 0)
	end
end

M.CloseBlackEdge = function(self)
	self.bindData.showBlackEdge = BOOL2CTL[false]

	if self.bindData.rectEdgeR and self.bindData.rectEdgeL then
		self.bindData.rectEdgeR.sizeDelta = Vector2(0, 0)
		self.bindData.rectEdgeL.sizeDelta = Vector2(0, 0)
	end
end
