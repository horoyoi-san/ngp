-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FighterHudPanelStore.lua
-- Decompiled from: 01905_FighterHudPanelStore.lua_d0778780c08c.luajit

C_FighterHudPanelStore = DefClass("C_FighterHudPanelStore", C_FighterHudPanelStore, C_StoreGroup)
GroupName2Class.FighterHudPanelStore = C_FighterHudPanelStore
local M = C_FighterHudPanelStore
local Fighter = L18.MiniGame.Fighter

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.leftButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchLeftButtonPressState", true)
	self.bindData.leftButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchLeftButtonPressState", false)
	self.bindData.rightButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchRightButtonPressState", true)
	self.bindData.rightButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchRightButtonPressState", false)
	self.bindData.spaceButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchJumpButtonPressState", true)
	self.bindData.spaceButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchJumpButtonPressState", false)
	self.bindData.jumpButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchJumpButtonPressState", true)
	self.bindData.jumpButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchJumpButtonPressState", false)
	self.bindData.defendButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchDefendButtonPressState", true)
	self.bindData.defendButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchDefendButtonPressState", false)
	self.bindData.kickButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchKickButtonPressState", true)
	self.bindData.kickButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchKickButtonPressState", false)
	self.bindData.punchButton.luaPress = self.CreateActionWithArgs(self, "OnSwitchPunchButtonPressState", true)
	self.bindData.punchButton.luaRelease = self.CreateActionWithArgs(self, "OnSwitchPunchButtonPressState", false)
	self.bindData.superAttack.luaPress = self.CreateActionWithArgs(self, "OnSwitchSuperAttackButtonPressState", true)
	self.bindData.superAttack.luaRelease = self.CreateActionWithArgs(self, "OnSwitchSuperAttackButtonPressState", false)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnClickExitButton")
	self.bindData.startGameButton.luaClick = self.CreateAction(self, "OnStartGameClick")
	self.bindData.moveNavRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMoveGamePadInputChanged")
	self.bindData.selectionListNavProxy.luaSimpleRenderItem = self.CreateAction(self, "OnSelectionListRenderItem")

	self.InitMessages(self)
end

M.InitMessages = function(self)
	self.RegisterMessageEvents(self, {
		[gEventConstants.ON_MINI_GAME_FIGHTER_STAGE_CHANGE] = self.CreateAction(self, "OnStageChange")
	})
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.csGameInstance = nil
	self.moveVector2 = nil
	self.forbidClickExit = nil
	self.autoCloseAfterWin = nil
	self.startGameCallback = nil
	self.moveGamePadCallback = nil
	self.mainStore = nil
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.moveVector2 = Vector2.New(0, 0)
	self.forbidClickExit = args.forbidClickExit
	self.autoCloseAfterWin = args.autoCloseAfterWin
	self.startGameCallback = args.startGameCallback
	self.moveGamePadCallback = args.moveGamePadCallback
	self.mainStore = args.mainStore
	self.csGameInstance = L18.MiniGame.Fighter.FighterMinigame.Instance
end

M.InitView = function(self)
	self.bindData.stageControl = 0

	self.bindData.exitButton.gameObject:SetActive(not self.forbidClickExit)

	if self:CheckIsSpecialMainLineMode() then
		self.SpecialMainLine_SwitchUltimateButtonState(self, 1)
	end
end

M.CheckIsSpecialMainLineMode = function(self)
	return self.forbidClickExit and self.autoCloseAfterWin < 0
end

M.OnSwitchLeftButtonPressState = function(self, isPress)
	self.isLeftButtonPress = isPress

	if self.moveVector2.x ~= 1 then
		return
	end

	self.moveVector2.x = isPress and -1 or 0
	Fighter.FighterMinigame.Instance.InputManager.InputVector = self.moveVector2

	if not isPress and self.isRightButtonPress then
		self.OnSwitchRightButtonPressState(self, true)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.leftButton:SetSelected(isPress)
	end
end

M.OnSwitchRightButtonPressState = function(self, isPress)
	self.isRightButtonPress = isPress

	if self.moveVector2.x ~= -1 then
		return
	end

	self.moveVector2.x = isPress and 1 or 0
	Fighter.FighterMinigame.Instance.InputManager.InputVector = self.moveVector2

	if not isPress and self.isLeftButtonPress then
		self.OnSwitchLeftButtonPressState(self, true)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.rightButton:SetSelected(isPress)
	end
end

M.OnSwitchJumpButtonPressState = function(self, isPress)
	Fighter.FighterMinigame.Instance.InputManager.IsJumpKeyDown = isPress

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.jumpButton:SetSelected(isPress)
	end
end

M.OnSwitchDefendButtonPressState = function(self, isPress)
	Fighter.FighterMinigame.Instance.InputManager.IsDefendKeyDown = isPress

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.defendButton:SetSelected(isPress)
	end
end

M.OnSwitchKickButtonPressState = function(self, isPress)
	Fighter.FighterMinigame.Instance.InputManager.IsKickKeyDown = isPress

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.kickButton:SetSelected(isPress)
	end
end

M.OnSwitchPunchButtonPressState = function(self, isPress)
	Fighter.FighterMinigame.Instance.InputManager.IsPunchKeyDown = isPress

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.punchButton:SetSelected(isPress)
	end
end

M.SetUltimateKeyDownCallbackOnce = function(self, callback)
	self.ultimateKeyDownCallbackOnce = callback
end

M.OnSwitchSuperAttackButtonPressState = function(self, isPress)
	if self.bindData.ultimateButtonStateControl ~= 2 then
		if isPress and self.ultimateKeyDownCallbackOnce then
			self.ultimateKeyDownCallbackOnce()

			self.ultimateKeyDownCallbackOnce = nil
		end
	else
		Fighter.FighterMinigame.Instance.InputManager.IsUltimateKeyDown = isPress
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.superAttack:SetSelected(isPress)
	end
end

M.OnClickExitButton = function(self)
	if self.forbidClickExit then
		return
	end

	gPanelManager:Close(gPanelId.FIGHTER_MAIN_PANEL)
end

M.OnStageChange = function(self, _, stage)
	self.bindData.stageControl = stage
end

M.OnStartGameClick = function(self)
	if self.startGameCallback then
		self.startGameCallback()
	end
end

M.OnMoveGamePadInputChanged = function(self, context)
	if self.bindData.stageControl ~= self.mainStore.STAGE_CONTROL.GamePlay then
		self.ProcessMoveGamePadInput_GamePlayStage(self, context)
	else
		self.OnSwitchLeftButtonPressState(self, false)
		self.OnSwitchRightButtonPressState(self, false)
	end
end

M.ProcessMoveGamePadInput_GamePlayStage = function(self, context)
	local valueX = nil
	local valueY = 0
	local actionName = context.action.name

	if actionName ~= "DpadX" then
		valueX = context.ReadValueFloat(context)
	elseif actionName ~= "LeftStick" or actionName ~= "LeftStickX" then
		local value = context.ReadValueVector2(context)
		valueX = value.x
		valueY = value.y
	else
		print_error("FighterHudPanelStore UCustomNavRespond 绑定的事件不对！", actionName)

		return
	end

	if math.abs(valueY) < math.abs(valueX) then
		self:ProcessMoveGamePadInput_GamePlayStage_XAxis(context.started or context.performed, valueX)
		self:ProcessMoveGamePadInput_GamePlayStage_YAxis(false, valueY)
	else
		self:ProcessMoveGamePadInput_GamePlayStage_XAxis(false, valueX)
		self:ProcessMoveGamePadInput_GamePlayStage_YAxis(context.started or context.performed, valueY)
	end
end

M.ProcessMoveGamePadInput_GamePlayStage_XAxis = function(self, isPressDown, valueX)
	if isPressDown then
		if valueX >= 0 then
			self.OnSwitchRightButtonPressState(self, false)
			self.OnSwitchLeftButtonPressState(self, true)
		elseif valueX <= 0 then
			self.OnSwitchLeftButtonPressState(self, false)
			self.OnSwitchRightButtonPressState(self, true)
		end
	else
		self.OnSwitchLeftButtonPressState(self, false)
		self.OnSwitchRightButtonPressState(self, false)
	end
end

M.ProcessMoveGamePadInput_GamePlayStage_YAxis = function(self, isPressDown, valueY)
	local isJump = valueY >= 0

	self:OnSwitchJumpButtonPressState(isJump and isPressDown)
	self:OnSwitchDefendButtonPressState(not isJump and isPressDown)
end

M.SetSelectionListNavProxy = function(self, itemCount)
	self.bindData.selectionListNavProxy:SetSimpleList(itemCount)
end

M.SetExitButtonControllerPos = function(self, screenPos)
end

M.SetExitButtonControllerActive = function(self, isActive)
end

M.OnSelectionListRenderItem = function(self, btn, csIndex)
	if csIndex ~= 0 then
		self.bindData.navArea.CurrentActiveContent = btn
	end

	btn.name = "SelectionListNavProxy_Item" .. tostring(csIndex)

	btn.luaFocus = function()
		self.mainStore:GamepadSelect(csIndex)
	end
end

M.SetItemNavigationEnable = function(self, index, enable)
	local csIndex = index - 1
	local success, btn = self.bindData.selectionListNavProxy:TryGetChildAt(csIndex, nil)

	if success then
		local navigation = btn.navigation
		navigation.mode = enable and 3 or 0
		btn.navigation = navigation
	end
end

M.SetSelectListSelectItem = function(self, index)
	local csIndex = index - 1
	local success, btn = self.bindData.selectionListNavProxy:TryGetChildAt(csIndex, nil)

	if success then
		self.bindData.navArea.CurrentActiveContent = btn

		self.mainStore:GamepadSelect(csIndex)
	end
end

M.SpecialMainLine_SwitchUltimateButtonState = function(self, pageIndex)
	self.bindData.ultimateButtonStateControl = pageIndex

	if pageIndex ~= 2 then
		self.bindData.ultimateAttackAnim.enabled = true

		self.bindData.ultimateAttackAnim:Play("S_Vx_LBtnTemplate_01_loop")
		self.bindData.ultimateAttackAnim:SampleCurrentAnimation()
	elseif pageIndex ~= 0 then
		self.bindData.ultimateAttackAnim:Play("S_Vx_LBtnTemplate_02")
		self.bindData.ultimateAttackAnim:SampleCurrentAnimation()
	end
end

M.SetUltimateBtnInteractable = function(self, interactable)
	self.bindData.superAttack.interactable = interactable
end
