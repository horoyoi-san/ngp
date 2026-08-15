C_WuziqiMobileConfirmBtnStore = DefClass("C_WuziqiMobileConfirmBtnStore", C_WuziqiMobileConfirmBtnStore, C_StoreGroup)
GroupName2Class.WuziqiMobileConfirmBtnStore = C_WuziqiMobileConfirmBtnStore
local M = C_WuziqiMobileConfirmBtnStore

function M:ctor()
	self.openAnimationName = "S_Vx_GameplayRoundPanel_open"
	self.closeAnimationName = "S_Vx_GameplayRoundPanel_close"
end

function M:DefineAllVariables()
	return
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
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.bindData.showRoundPanel = 1

	L50.L50App.Scene.GomokuManager:StartGomoke()
	self.bindData.confirmBtn.gameObject:SetActive(false)
	self.bindData.roundPanelAnimation:Play(self.openAnimationName)

	self.timer = Timer.New(function ()
		self.bindData.roundPanelAnimation:Play(self.closeAnimationName)
	end, 1):Start()
	self.cursorMove = false
	self.cursorIdleTime = 0
end

function M:OnClose()
	L50.L50App.Scene.GomokuManager:LeaveGomoku()
end

function M:OnUpdate()
	self.cursorIdleTime = self.cursorIdleTime + gLogicTime.deltaTime

	if self.cursorIdleTime >= 0.3 then
		self.cursorMove = false
		local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(L50.L50App.Scene.GomokuManager.PreviewPosition)

		SGUI.UCursorInput.SetCursorPos(screenPos)
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.GOMOKU_STEP_COUNT_CHANGE] = self:CreateAction(self.OnGomokuStepCountChange)
	}
end

function M:RegisterWidget()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.mouseMoveResponse.luaGamePadInputChanged = self:CreateAction(self.OnMouseMove)
		self.bindData.selectBtn.luaClick = self:CreateAction(self.OnClickConfirmBtn)
		SGUI.UCursorInput.onCursorPosChange = self:CreateAction(self.OnCursorPosChange)
		self.bindData.quitBtn.luaLongPress = self:CreateAction(self.OnQuitLongPress)
	else
		self.bindData.selectBtn.luaClick = self:CreateAction(self.MobileOnSelectBtn)
		self.bindData.confirmBtn.luaClick = self:CreateAction(self.OnClickConfirmBtn)
		self.bindData.quitBtn.luaEndLongPress = self:CreateAction(self.OnQuitLongPress)
	end
end

function M:OnClickConfirmBtn()
	L50.L50App.Scene.GomokuManager:PlaceGomokuPiece()
	self.bindData.confirmBtn.gameObject:SetActive(false)
end

function M:MobileOnSelectBtn()
	local inputPos = SGUI.Utils.GetInputCenterPosition()

	L50.L50App.Scene.GomokuManager:PreviewPlaceGomoku(Vector3.New(inputPos.x, inputPos.y, 0))

	local worldPos = L50.L50App.Scene.GomokuManager.PreviewPosition
	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(worldPos)
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.bindData.bindWidget.rectTransform, screenPos)

	self.bindData.confirmBtn.gameObject:SetActive(true)
	self.bindData.confirmBtn.rectTransform:SetLocalPositionXY(uiPos.x, uiPos.y + 70)
end

function M:OnMouseMove(context)
	local mousePosVector = UnityEngine.Input.mousePosition

	L50.L50App.Scene.GomokuManager:PreviewPlaceGomoku(mousePosVector)
end

function M:OnCursorPosChange(position)
	local currentCursorPos = SGUI.UCursorInput.GetCursorScreenPos()

	L50.L50App.Scene.GomokuManager:PreviewPlaceGomoku(currentCursorPos)

	self.cursorMove = true
	self.cursorIdleTime = 0
end

function M:OnQuitLongPress()
	gPanelManager:Close(gPanelId.WUZIQI_MOBILE_CONFIRM_BTN)
end

function M:OnGomokuStepCountChange(_, stepCount)
	self.bindData.showStep = 1
	self.bindData.stepCount = stepCount
end
