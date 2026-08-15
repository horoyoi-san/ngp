C_FighterHudPanelStore = DefClass("C_FighterHudPanelStore", C_FighterHudPanelStore, C_StoreGroup)
GroupName2Class.FighterHudPanelStore = C_FighterHudPanelStore
local M = C_FighterHudPanelStore
local Fighter = L18.MiniGame.Fighter

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.leftButton.luaPress = self:CreateActionWithArgs("OnSwitchLeftButtonPressState", true)
	self.bindData.leftButton.luaRelease = self:CreateActionWithArgs("OnSwitchLeftButtonPressState", false)
	self.bindData.rightButton.luaPress = self:CreateActionWithArgs("OnSwitchRightButtonPressState", true)
	self.bindData.rightButton.luaRelease = self:CreateActionWithArgs("OnSwitchRightButtonPressState", false)
	self.bindData.spaceButton.luaPress = self:CreateActionWithArgs("OnSwitchJumpButtonPressState", true)
	self.bindData.spaceButton.luaRelease = self:CreateActionWithArgs("OnSwitchJumpButtonPressState", false)
	self.bindData.jumpButton.luaPress = self:CreateActionWithArgs("OnSwitchJumpButtonPressState", true)
	self.bindData.jumpButton.luaRelease = self:CreateActionWithArgs("OnSwitchJumpButtonPressState", false)
	self.bindData.defendButton.luaPress = self:CreateActionWithArgs("OnSwitchDefendButtonPressState", true)
	self.bindData.defendButton.luaRelease = self:CreateActionWithArgs("OnSwitchDefendButtonPressState", false)
	self.bindData.kickButton.luaPress = self:CreateActionWithArgs("OnSwitchKickButtonPressState", true)
	self.bindData.kickButton.luaRelease = self:CreateActionWithArgs("OnSwitchKickButtonPressState", false)
	self.bindData.punchButton.luaPress = self:CreateActionWithArgs("OnSwitchPunchButtonPressState", true)
	self.bindData.punchButton.luaRelease = self:CreateActionWithArgs("OnSwitchPunchButtonPressState", false)
	self.bindData.superAttack.luaPress = self:CreateActionWithArgs("OnSwitchSuperAttackButtonPressState", true)
	self.bindData.superAttack.luaRelease = self:CreateActionWithArgs("OnSwitchSuperAttackButtonPressState", false)
	self.bindData.exitButton.luaClick = self:CreateAction("OnClickExitButton")
	self.bindData.startGameButton.luaClick = self:CreateAction("OnStartGameClick")
	self.bindData.moveNavRespond.luaGamePadInputChanged = self:CreateAction("OnMoveGamePadInputChanged")
	self.bindData.selectionListNavProxy.luaSimpleRenderItem = self:CreateAction("OnSelectionListRenderItem")

	self:InitMessages()
end

function M:InitMessages()
	self:RegisterMessageEvents({
		[gEventConstants.ON_MINI_GAME_FIGHTER_STAGE_CHANGE] = self:CreateAction("OnStageChange")
	})
end

function M:OnDestroy()
	self:ClearMessageEvents()

	self.csGameInstance = nil
	self.moveVector2 = nil
	self.forbidClickExit = nil
	self.autoCloseAfterWin = nil
	self.startGameCallback = nil
	self.moveGamePadCallback = nil
	self.mainStore = nil
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.moveVector2 = Vector2.New(0, 0)
	self.forbidClickExit = args.forbidClickExit
	self.autoCloseAfterWin = args.autoCloseAfterWin
	self.startGameCallback = args.startGameCallback
	self.moveGamePadCallback = args.moveGamePadCallback
	self.mainStore = args.mainStore
	self.csGameInstance = L18.MiniGame.Fighter.FighterMinigame.Instance
end

function M:InitView()
	self.bindData.stageControl = 0

	self.bindData.exitButton.gameObject:SetActive(not self.forbidClickExit)

	if self:CheckIsSpecialMainLineMode() then
		self:SpecialMainLine_SwitchUltimateButtonState(1)
	end
end

function M:CheckIsSpecialMainLineMode()
	return self.forbidClickExit and self.autoCloseAfterWin >= 0
end

function M:OnSwitchLeftButtonPressState(isPress)
	self.isLeftButtonPress = isPress

	if self.moveVector2.x == 1 then
		return
	end

	self.moveVector2.x = isPress and -1 or 0
	Fighter.ArcadeFighterInputManager.Instance.InputVector = self.moveVector2

	if not isPress and self.isRightButtonPress then
		self:OnSwitchRightButtonPressState(true)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.leftButton:SetSelected(isPress)
	end
end

function M:OnSwitchRightButtonPressState(isPress)
	self.isRightButtonPress = isPress

	if self.moveVector2.x == -1 then
		return
	end

	self.moveVector2.x = isPress and 1 or 0
	Fighter.ArcadeFighterInputManager.Instance.InputVector = self.moveVector2

	if not isPress and self.isLeftButtonPress then
		self:OnSwitchLeftButtonPressState(true)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.rightButton:SetSelected(isPress)
	end
end

function M:OnSwitchJumpButtonPressState(isPress)
	Fighter.ArcadeFighterInputManager.Instance.IsJumpKeyDown = isPress

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.jumpButton:SetSelected(isPress)
	end
end

function M:OnSwitchDefendButtonPressState(isPress)
	Fighter.ArcadeFighterInputManager.Instance.IsDefendKeyDown = isPress

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.defendButton:SetSelected(isPress)
	end
end

function M:OnSwitchKickButtonPressState(isPress)
	Fighter.ArcadeFighterInputManager.Instance.IsKickKeyDown = isPress

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.kickButton:SetSelected(isPress)
	end
end

function M:OnSwitchPunchButtonPressState(isPress)
	Fighter.ArcadeFighterInputManager.Instance.IsPunchKeyDown = isPress

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.punchButton:SetSelected(isPress)
	end
end

function M:SetUltimateKeyDownCallbackOnce(callback)
	self.ultimateKeyDownCallbackOnce = callback
end

function M:OnSwitchSuperAttackButtonPressState(isPress)
	Fighter.ArcadeFighterInputManager.Instance.IsUltimateKeyDown = isPress

	if isPress and self.bindData.ultimateButtonStateControl == 2 and self.ultimateKeyDownCallbackOnce then
		self.ultimateKeyDownCallbackOnce()

		self.ultimateKeyDownCallbackOnce = nil
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.superAttack:SetSelected(isPress)
	end
end

function M:OnClickExitButton()
	if self.forbidClickExit then
		return
	end

	gPanelManager:Close(gPanelId.FIGHTER_MAIN_PANEL)
end

function M:OnStageChange(_, stage)
	self.bindData.stageControl = stage
end

function M:OnStartGameClick()
	if self.startGameCallback then
		self.startGameCallback()
	end
end

function M:OnMoveGamePadInputChanged(context)
	if self.bindData.stageControl == self.mainStore.STAGE_CONTROL.GamePlay then
		self:ProcessMoveGamePadInput_GamePlayStage(context)
	else
		self:OnSwitchLeftButtonPressState(false)
		self:OnSwitchRightButtonPressState(false)
	end
end

function M:ProcessMoveGamePadInput_GamePlayStage(context)
	local valueX = nil
	local valueY = 0
	local actionName = context.action.name

	if actionName == "DpadX" then
		valueX = context:ReadValueFloat()
	elseif actionName == "LeftStick" or actionName == "LeftStickX" then
		local value = context:ReadValueVector2()
		valueX = value.x
		valueY = value.y
	else
		print_error("FighterHudPanelStore UCustomNavRespond 绑定的事件不对！", actionName)

		return
	end

	if math.abs(valueY) <= math.abs(valueX) then
		self:ProcessMoveGamePadInput_GamePlayStage_XAxis(context.started or context.performed, valueX)
		self:ProcessMoveGamePadInput_GamePlayStage_YAxis(false, valueY)
	else
		self:ProcessMoveGamePadInput_GamePlayStage_XAxis(false, valueX)
		self:ProcessMoveGamePadInput_GamePlayStage_YAxis(context.started or context.performed, valueY)
	end
end

function M:ProcessMoveGamePadInput_GamePlayStage_XAxis(isPressDown, valueX)
	if isPressDown then
		if valueX < 0 then
			self:OnSwitchRightButtonPressState(false)
			self:OnSwitchLeftButtonPressState(true)
		elseif valueX > 0 then
			self:OnSwitchLeftButtonPressState(false)
			self:OnSwitchRightButtonPressState(true)
		end
	else
		self:OnSwitchLeftButtonPressState(false)
		self:OnSwitchRightButtonPressState(false)
	end
end

function M:ProcessMoveGamePadInput_GamePlayStage_YAxis(isPressDown, valueY)
	local isJump = valueY > 0

	self:OnSwitchJumpButtonPressState(isJump and isPressDown)
	self:OnSwitchDefendButtonPressState(not isJump and isPressDown)
end

function M:SetSelectionListNavProxy(itemCount)
	self.bindData.selectionListNavProxy:SetSimpleList(itemCount)
end

function M:SetExitButtonControllerPos(screenPos)
	return
end

function M:SetExitButtonControllerActive(isActive)
	return
end

function M:OnSelectionListRenderItem(btn, csIndex)
	if csIndex == 0 then
		self.bindData.navArea.CurrentActiveContent = btn
	end

	btn.name = "SelectionListNavProxy_Item" .. tostring(csIndex)

	function btn.luaFocus()
		self.mainStore:GamepadSelect(csIndex)
	end
end

function M:SetSelectListSelectItem(index)
	local csIndex = index - 1
	local success, btn = self.bindData.selectionListNavProxy:TryGetChildAt(csIndex, nil)

	if success then
		self.bindData.navArea.CurrentActiveContent = btn

		self.mainStore:GamepadSelect(csIndex)
	end
end

function M:SpecialMainLine_SwitchUltimateButtonState(pageIndex)
	self.bindData.ultimateButtonStateControl = pageIndex

	if pageIndex == 2 then
		self.bindData.ultimateAttackAnim.enabled = true

		self.bindData.ultimateAttackAnim:Play("S_Vx_LBtnTemplate_01_loop")
		self.bindData.ultimateAttackAnim:SampleCurrentAnimation()
	elseif pageIndex == 0 then
		self.bindData.ultimateAttackAnim:Play("S_Vx_LBtnTemplate_02")
		self.bindData.ultimateAttackAnim:SampleCurrentAnimation()
	end
end
