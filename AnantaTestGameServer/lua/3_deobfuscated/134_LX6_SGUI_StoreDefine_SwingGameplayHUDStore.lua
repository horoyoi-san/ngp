local PlaygroundSwingManager = LX6.Units.Module.CCMove.PlaygroundSwingManager
local PlaygroundSwingState = LX6.Units.Module.CCMove.PlaygroundSwingState
C_SwingGameplayHUDStore = DefClass("C_SwingGameplayHUDStore", C_SwingGameplayHUDStore, C_StoreGroup)
GroupName2Class.SwingGameplayHUDStore = C_SwingGameplayHUDStore
local M = C_SwingGameplayHUDStore

function M:ctor()
	self.BTN_ANIME = {
		UP = "s_vx_HudSkillbtn_fanse_up",
		DOWN = "s_vx_HudSkillbtn_fanse"
	}
	self.BTN_SWING_ANIME = {
		CLICKED = "fx_ui_S_GamePlaySwingNotify_Success"
	}
end

function M:DefineAllVariables()
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.gamepadUpdateRotate = false
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
	self.swingBtnStore = self:GetStoreByWidget(self.bindData.swingBtn)
	self.exitBtnStore = self:GetStoreByWidget(self.bindData.exitBtn)
end

function M:OnGroupDisable()
	self.swingBtnStore = nil
	self.exitBtnStore = nil
end

function M:OnShow(panelId, data)
	self.bindData.HideAllCtrl = 0
	self.state = PlaygroundSwingState.None

	LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gPanelId.S_CORE_HUD_PANEL)
end

function M:OnUpdate()
	if gCS.MyPlayerManager.PlayerUnit then
		local state = PlaygroundSwingManager.GetCurrentState(gCS.MyPlayerManager.PlayerUnit)

		self:SwitchState(state)
	end

	self:UpdateCameraRotateGamePad()
end

function M:OnClose()
	LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gPanelId.S_CORE_HUD_PANEL)
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.swingBtn.luaPress = self:CreateAction("OnSwingBtnPress")
	self.bindData.swingBtn.luaRelease = self:CreateAction("OnSwingBtnRelease")
	self.bindData.exitBtn.luaPress = self:CreateAction("OnExitBtnPress")
	self.bindData.leftStickRespond.luaGamePadInputChanged = self:CreateAction("OnLeftStickControl")
	self.bindData.rightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
end

function M:OnSwingBtnPress()
	gCS.LuaUtils.PlayAnimationByName(self.swingBtnStore.btnFanseAni, self.BTN_ANIME.DOWN)

	if not self.clicked and (self.state == PlaygroundSwingState.ForwardPeekTurn or self.state == PlaygroundSwingState.BackwardPeekTurn or self.state == PlaygroundSwingState.Idle) then
		self.clicked = true

		gCS.LuaUtils.PlayAnimationByName(self.swingBtnStore.btnSwingAni, self.BTN_SWING_ANIME.CLICKED)
	end

	if gCS.MyPlayerManager.PlayerUnit then
		print_notice("SwingGameplayHUDStore OnPressBtnSwing send3CEvent PlaygroundSwingPress")
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.PlaygroundSwingPress)
	else
		print_error("#NoCreateIssue gCS.MyPlayerManager.PlayerUnit is nil")
	end
end

function M:OnSwingBtnRelease()
	gCS.LuaUtils.PlayAnimationByName(self.swingBtnStore.btnFanseAni, self.BTN_ANIME.UP)
end

function M:OnExitBtnPress()
	if gCS.MyPlayerManager.PlayerUnit then
		self.bindData.HideAllCtrl = 1

		print_notice("SwingGameplayHUDStore OnExitBtnPress AskForLeave")
		PlaygroundSwingManager.AskForLeave(gCS.MyPlayerManager.PlayerUnit)
	end
end

function M:OnLeftStickControl(context)
	if context.started or context.performed then
		self:OnExitBtnPress()
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

		gCameraUtils:DoRotateCameraByGamePad(4, 0, 0)
	end
end

function M:SwitchState(state)
	if self.state ~= state then
		if state == PlaygroundSwingState.ForwardPeekTurn or state == PlaygroundSwingState.BackwardPeekTurn or state == PlaygroundSwingState.Idle then
			self.clicked = false
			self.swingBtnStore.ClickableCtrl = 1
		else
			self.swingBtnStore.ClickableCtrl = 0
		end

		self.state = state
	end
end

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end
