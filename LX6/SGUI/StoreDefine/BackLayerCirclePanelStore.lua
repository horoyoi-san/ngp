-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BackLayerCirclePanelStore.lua
-- Decompiled from: 01560_BackLayerCirclePanelStore.lua_d19bf9292d8a.luajit

C_BackLayerCirclePanelStore = DefClass("C_BackLayerCirclePanelStore", C_BackLayerCirclePanelStore, C_StoreGroup)
GroupName2Class.BackLayerCirclePanelStore = C_BackLayerCirclePanelStore
local M = C_BackLayerCirclePanelStore

M.ctor = function(self)
	self.DEFINE_DynamicOnUpdate = true
end

M.DefineAllVariables = function(self)
	self.LOCAL_CIRCLE_INFO_PATH = "LocalCircleInfo"
	self.localCircleInfo = gUIUtils:LoadJsonToLuaTableWithPid(self.LOCAL_CIRCLE_INFO_PATH) or {}
	self.circleOpen = false
	self.needSave = false
	self.pressTime = 0
	self.targetMode = gCircleType.HIDE
	self.currentMode = gCircleType.HIDE
	self.circleOpenState = false
	self.pauseUUID = nil
	self.ShowCircleLimit = 0
	self.SELECT_MODE = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.linkCircleEnable = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.showSwitchCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.switchStateCtrlEnum = {
		["Q\\x82\\x9a\\x86L"] = 0,
		["A\\x96\\x80\\x82M"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showSwitchCtrlEnum = nil
	self.switchStateCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnDestroy = function(self)
	self.CloseCircleNoEvent(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.linkCircleEnable = gLinkManager:NeedShortChatWheel()

	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device

	self:RefreshSwitchShow()
end

M.OnLanguageChange = function(self, lang)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LINK_CIRCLE_STATE_CHANGE] = self.CreateAction(self, "OnLinkCircleStateChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
	self.bindData.switchBtnPad.luaClick = self.CreateAction(self, "OnSwitchBtnPadClick")
end

M.OnTabRectRender = function(self, index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnCircleOpen({
			localInfo = self.localCircleInfo
		})
	end
end

M.OnSwitchBtnPadClick = function(self)
	if self.currentMode ~= gCircleType.SYSTEM then
		self.CloseCircleNoEvent(self)
		self.OpenCircle(self, gCircleType.ONLINE_SIGNAL)
	elseif self.currentMode ~= gCircleType.ONLINE_SIGNAL then
		self.CloseCircleNoEvent(self)
		self.OpenCircle(self, gCircleType.SYSTEM)
	end
end

M.OpenCircle = function(self, circleType)
	if not self.STATE_EnableOnce then
		return
	end

	self.circleOpen = true
	self.pressTime = Time.time
	self.targetMode = circleType

	gStoreManager:RegisterDynamicOnUpdate(self)
end

M.SwitchCircleType = function(self, circleType)
	if self.currentMode ~= circleType then
		return
	end

	self.CloseCircleNoEvent(self)
	self.OpenCircle(self, circleType)
end

M.OnUpdate = function(self)
	if self.targetMode ~= gCircleType.HIDE then
		return
	end

	if self.currentMode ~= gCircleType.HIDE then
		if self.ShowCircleLimit < Time.time - self.pressTime then
			self.currentMode = self.targetMode
			self.bindData.tabRect.selectedIndex = self.currentMode

			self.OnCircleOpen(self)
		end
	elseif self.curTypeStore then
		self.curTypeStore:DoUpdate()
	end
end

M.OnCircleOpen = function(self)
	self.circleOpenState = true

	gStoreManager:GetStoreGroup("HintInfosHudStore"):EnableFromInteraction(false)
	gStoreManager:GetStoreGroup("CoreHudCharacterControlStore"):SetCircleOpen(true)
	gDialogManager:ProcessDialogBranch(true)

	if self.currentMode ~= gCircleType.WEAPON or self.currentMode ~= gCircleType.SUMMON or self.currentMode ~= gCircleType.POLICE_SUMMON or self.currentMode ~= gCircleType.AGENT_WEAPON then
		if not gLinkManager:CheckInLinkMode() then
			gCS.PauseManager.Instance:AddFakePausePannel(68)
		end

		LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gPanelId.BACK_LAYER_CIRCLE_PANEL)
		gSoundMgr:PlaySoundByTid(LTConfig.SoundConfig.PauseTimeStart)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	if self.currentMode ~= gCircleType.SYSTEM then
		self.bindData.switchStateCtrl = self.switchStateCtrlEnum.system
	elseif self.currentMode ~= gCircleType.ONLINE_SIGNAL then
		self.bindData.switchStateCtrl = self.switchStateCtrlEnum.signal
	end

	self:RefreshSwitchShow()
	gPopupPauseManager:PausePopup(gPopupPauseManager.PAUSE_REASON.CIRCLE_OPEN)
	gNewPopupManager:CloseAllActivePopup()
	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.CIRCLE_STATE_CHANGED, self.currentMode, true)
end

M.OnCircleClose = function(self)
	self.circleOpenState = false

	gStoreManager:GetStoreGroup("HintInfosHudStore"):EnableFromInteraction(true)
	gStoreManager:GetStoreGroup("CoreHudCharacterControlStore"):SetCircleOpen(false)
	gDialogManager:ProcessDialogBranch(false)

	if self.currentMode ~= gCircleType.WEAPON or self.currentMode ~= gCircleType.SUMMON or self.currentMode ~= gCircleType.POLICE_SUMMON or self.currentMode ~= gCircleType.AGENT_WEAPON then
		if not gLinkManager:CheckInLinkMode() then
			gCS.PauseManager.Instance:RemoveFakePausePannel(68)
		end

		LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gPanelId.BACK_LAYER_CIRCLE_PANEL)
		gSoundMgr:PlaySoundByTid(LTConfig.SoundConfig.PauseTimeEnd)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end

	self:RefreshSwitchShow()
	gPopupPauseManager:ResumePopup(gPopupPauseManager.PAUSE_REASON.CIRCLE_OPEN)
	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.CIRCLE_STATE_CHANGED, self.currentMode, false)
end

M.CloseCircle = function(self)
	self.curType = -1

	if not self.STATE_EnableOnce then
		return
	end

	if not self.circleOpen then
		return
	end

	gStoreManager:UnregisterDynamicOnUpdate(self)

	if self.curTypeStore then
		self.curTypeStore:CloseTrigger()
		self.curTypeStore:OnCircleClose()

		self.curTypeStore = nil
	end

	self.bindData.tabRect.selectedIndex = self.curType
	self.circleOpen = false
	self.targetMode = gCircleType.HIDE

	if self.currentMode == gCircleType.HIDE then
		self.OnCircleClose(self)

		self.currentMode = gCircleType.HIDE
	end
end

M.CloseCircleNoEvent = function(self)
	self.curType = -1

	if not self.STATE_EnableOnce then
		return
	end

	if not self.circleOpen then
		return
	end

	if self.curTypeStore then
		self.curTypeStore:OnCircleClose()

		self.curTypeStore = nil
	end

	self.bindData.tabRect.selectedIndex = self.curType
	self.circleOpen = false
	self.targetMode = gCircleType.HIDE

	if self.currentMode == gCircleType.HIDE then
		self.OnCircleClose(self)

		self.currentMode = gCircleType.HIDE
	end
end

M.OnLinkCircleStateChange = function(self)
	self.linkCircleEnable = gLinkManager:NeedShortChatWheel()

	if self.STATE_OnShowOnce then
		self.RefreshSwitchShow(self)
	end
end

M.RefreshSwitchShow = function(self)
	local show = self.circleOpenState and (self.currentMode ~= gCircleType.SYSTEM or self.currentMode ~= gCircleType.ONLINE_SIGNAL) and self.gamepadMode and self.linkCircleEnable
	self.bindData.showSwitchCtrl = show and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
end
