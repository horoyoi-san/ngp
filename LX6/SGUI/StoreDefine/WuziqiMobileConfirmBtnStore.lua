-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WuziqiMobileConfirmBtnStore.lua
-- Decompiled from: 01242_WuziqiMobileConfirmBtnStore.lua_28739c9200c7.luajit

C_WuziqiMobileConfirmBtnStore = DefClass("C_WuziqiMobileConfirmBtnStore", C_WuziqiMobileConfirmBtnStore, C_StoreGroup)
GroupName2Class.WuziqiMobileConfirmBtnStore = C_WuziqiMobileConfirmBtnStore
local M = C_WuziqiMobileConfirmBtnStore

M.ctor = function(self)
	self.openAnimationName = "S_Vx_GameplayRoundPanel_open"
	self.closeAnimationName = "S_Vx_GameplayRoundPanel_close"
	self.leftCDTimes = 0
	self.useSkill = false
end

M.DefineAllVariables = function(self)
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
	if self.skillFeedbackTimer then
		self.skillFeedbackTimer:Stop()

		self.skillFeedbackTimer = nil
	end

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.canUpdateCursor = false
	self.beginUseSkill = false
	self.canPreview = true
	self.bindData.showRoundPanel = 1
	self.bindData.showXianzhuo = 0

	if data then
		if data.ToTable then
			data = data.ToTable(data)
		end

		if data.useSkill then
			self.useSkill = true
			self.bindData.showSkillBtn = 1
		end

		if data.stepCount then
			self.OnGomokuStepCountChange(self, nil, data.stepCount)
		end
	end

	self.bindData.confirmBtn.gameObject:SetActive(false)

	if self.bindData.roundPanelAnimation then
		self.bindData.roundPanelAnimation:Play(self.openAnimationName)

		self.timer = Timer.New(function ()
			if self.bindData and self.bindData.roundPanelAnimation then
				self.bindData.roundPanelAnimation:Play(self.closeAnimationName)
			end
		end, 1):Start()
	end

	self.cursorIdleTime = 0

	SGUI.UCursorInput.SetCursorPos(Vector2.New(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2))

	self.canUpdateCursor = true

	if self.useSkill then
		local skillId = L50.L50App.Scene.GomokuManager:GetSelectedSkillId()

		if skillId then
			local skillConfig = LTConfig.PoiGameGomokuSkillConfig.GetConfig(skillId)

			if skillConfig then
				self.bindData.skillBtnName = skillConfig.Name
				self.bindData.skillBtnIcon = skillConfig.SkillButtonIcon
				self.bindData.skillBtnIconVx = skillConfig.SkillButtonIcon
			end
		end
	end

	self.leftCDTimes = 0
	self.bindData.showSkillFeedback = 0
end

M.OnClose = function(self)
	if self.skillFeedbackTimer then
		self.skillFeedbackTimer:Stop()

		self.skillFeedbackTimer = nil
	end

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	L50.L50App.Scene.GomokuManager:LeaveGomoku()
end

M.OnUpdate = function(self)
	if not self.cursorIsMoving then
		return
	end

	self.cursorIdleTime = self.cursorIdleTime + gLogicTime.deltaTime

	if self.cursorIdleTime > 0.3 then
		local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(L50.L50App.Scene.GomokuManager.PreviewPosition)
		self.canUpdateCursor = false

		SGUI.UCursorInput.SetCursorPos(screenPos)

		self.canUpdateCursor = true
		self.cursorIsMoving = false
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.GOMOKU_STEP_COUNT_CHANGE] = self.CreateAction(self, self.OnGomokuStepCountChange),
		[gEventConstants.GOMOKU_ROUND_TURN_CHANGE] = self.CreateAction(self, self.OnGomokuRoundTurnChange),
		[gEventConstants.GOMOKU_PREVIEW_CHANGE] = self.CreateAction(self, self.OnGomokuPreviewChange),
		[gEventConstants.GOMOKU_OPPONENT_USED_SKILL] = self.CreateAction(self, self.OnGomokuOpponentUsedSkill),
		[gEventConstants.GOMOKU_SKILL_PLAYER_CHOSEN] = self.CreateAction(self, self.OnGomokuSkillPlayerChosen)
	}
end

M.RegisterWidget = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.mouseMoveResponse.luaGamePadInputChanged = self.CreateAction(self, self.OnMouseMove)
		self.bindData.selectBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
		SGUI.UCursorInput.onCursorPosChange = self.CreateAction(self, self.OnCursorPosChange)
		self.bindData.quitBtn.luaLongPress = self.CreateAction(self, self.OnQuitLongPress)
	else
		self.bindData.selectBtn.luaClick = self.CreateAction(self, self.MobileOnSelectBtn)
		self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
		self.bindData.quitBtn.luaEndLongPress = self.CreateAction(self, self.OnQuitLongPress)
	end

	self.bindData.skillBtn.luaClick = self.CreateAction(self, self.OnClickSkillBtn)
end

M.OnClickConfirmBtn = function(self)
	self.bindData.confirmBtn.gameObject:SetActive(false)

	self.bindData.showSkillTip = 0

	if self.beginUseSkill then
		if L50.L50App.Scene.GomokuManager.IsOpponentPlacing then
			self.ShowSkillFeedback(self, 89901411)

			return
		end

		local result = L50.L50App.Scene.GomokuManager:UseSkill()

		if result then
			self.beginUseSkill = false
		end

		local skillId = L50.L50App.Scene.GomokuManager:GetSelectedSkillId()
		local skillConfig = LTConfig.PoiGameGomokuSkillConfig.GetConfig(skillId)

		if skillConfig then
			self.bindData.skillBtnName = skillConfig.Name
		end

		return
	end

	L50.L50App.Scene.GomokuManager:PlaceGomokuPiece()
end

M.MobileOnSelectBtn = function(self)
	local inputPos = SGUI.Utils.GetInputCenterPosition()
	local screenPos = Vector3.New(inputPos.x, inputPos.y, 0)

	if self.beginUseSkill then
		L50.L50App.Scene.GomokuManager:PreviewSpawnSkill(screenPos)
	else
		L50.L50App.Scene.GomokuManager:PreviewPlaceGomoku(screenPos)
	end

	local worldPos = L50.L50App.Scene.GomokuManager.PreviewPosition
	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(worldPos)
	local uiPos = gCS.LuaUtils.ScreenPointUI(self.bindData.bindWidget.rectTransform, screenPos)

	if self.canPreview then
		self.bindData.confirmBtn.gameObject:SetActive(true)
	else
		self:ShowSkillFeedback(89901411)
		self.bindData.confirmBtn.gameObject:SetActive(false)
	end

	self.bindData.confirmBtn.rectTransform:SetLocalPositionXY(uiPos.x, uiPos.y + 70)
end

M.OnMouseMove = function(self, context)
	local mousePosVector = UnityEngine.Input.mousePosition

	if self.beginUseSkill then
		L50.L50App.Scene.GomokuManager:PreviewSpawnSkill(mousePosVector)
	else
		L50.L50App.Scene.GomokuManager:PreviewPlaceGomoku(mousePosVector)
	end
end

M.OnCursorPosChange = function(self, position)
	local currentCursorPos = SGUI.UCursorInput.GetCursorScreenPos()

	if not self.canUpdateCursor then
		return
	end

	if self.beginUseSkill then
		L50.L50App.Scene.GomokuManager:PreviewSpawnSkill(currentCursorPos)
	else
		L50.L50App.Scene.GomokuManager:PreviewPlaceGomoku(currentCursorPos)
	end

	self.cursorIdleTime = 0
	self.cursorIsMoving = true
end

M.OnQuitLongPress = function(self)
	L50.L50App.Scene.GomokuManager:LeaveGomoku(true)
end

M.OnGomokuStepCountChange = function(self, _, stepCount)
	self.bindData.showStep = 1
	self.bindData.stepCount = stepCount
end

M.OnGomokuRoundTurnChange = function(self, _, data)
	if data and data.ToTable then
		data = data.ToTable(data)
		self.currentRound = data.currentRound
		self.currentTurn = data.currentTurn
	end

	local mySeatIndex = L50.L50App.Scene.GomokuManager.MySeatIndex

	if mySeatIndex == self.currentTurn then
		self.bindData.skillBtn.enabled = false
	end

	local skillId = L50.L50App.Scene.GomokuManager:GetSelectedSkillId()
	local skillConfig = LTConfig.PoiGameGomokuSkillConfig.GetConfig(skillId)
	local currentRound = self.currentRound or 0
	local lastestCastRound = L50.L50App.Scene.GomokuManager.LastestCastRound or 0

	if lastestCastRound > 0 or currentRound < 0 then
		self.leftCDTimes = 0
		self.bindData.skillBtn.enabled = true
		self.bindData.inCD = 0

		return
	end

	local passedRounds = currentRound - lastestCastRound

	if passedRounds >= 0 then
		passedRounds = 0
	end

	if passedRounds > skillConfig.CD + 1 then
		if mySeatIndex ~= self.currentTurn then
			self.bindData.skillBtn.enabled = true
		end

		self.leftCDTimes = 0
		self.bindData.inCD = 0
	else
		self.leftCDTimes = skillConfig.CD + 1 - passedRounds
		self.bindData.cdTime = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901396).Text, self.leftCDTimes)
		self.bindData.inCD = 1
		self.bindData.skillBtn.enabled = false
	end
end

M.OnGomokuPreviewChange = function(self, _, enable)
	self.bindData.skillBtn.enabled = enable
	self.canPreview = enable
end

M.OnClickSkillBtn = function(self)
	if L50.L50App.Scene.GomokuManager.IsOpponentPlacing then
		self.ShowSkillFeedback(self, 89901411)

		return
	end

	L50.L50App.Scene.GomokuManager:ClearPreviewUuid()

	local skillId = L50.L50App.Scene.GomokuManager:GetSelectedSkillId()

	if self.leftCDTimes <= 0 then
		return
	end

	if self.beginUseSkill then
		local skillConfig = LTConfig.PoiGameGomokuSkillConfig.GetConfig(skillId)

		if skillConfig then
			self.bindData.skillBtnName = skillConfig.Name
		end

		self.beginUseSkill = false

		L50.L50App.Scene.GomokuManager:ClearSkillPreview()

		self.bindData.showSkillTip = 0

		return
	end

	if skillId ~= LTConfig.PoiGameGomokuSkillConfig.StarFall or skillId ~= LTConfig.PoiGameGomokuSkillConfig.Earthquake or skillId ~= LTConfig.PoiGameGomokuSkillConfig.Capture then
		local result = L50.L50App.Scene.GomokuManager:UseSkill()

		if not result then
			self.ShowSkillFeedback(self, 89901405)
		end

		return
	elseif skillId ~= LTConfig.PoiGameGomokuSkillConfig.Flick then
		local result = L50.L50App.Scene.GomokuManager:CanPreviewSkill()

		if not result then
			self.ShowSkillFeedback(self, 89901405)

			return
		end
	end

	self.bindData.confirmBtn.gameObject:SetActive(false)

	self.bindData.showSkillTip = 1

	if skillId ~= LTConfig.PoiGameGomokuSkillConfig.Flick then
		self.bindData.skillTip = LTConfig.TextScriptTextConfig.GetConfig(89901409).Text
	end

	self.beginUseSkill = true
	self.bindData.skillBtnName = LTConfig.TextScriptTextConfig.GetConfig(89900590).Text
end

M.ShowSkillFeedback = function(self, textId, tip)
	tip = tip or ""
	local cfg = LTConfig.TextScriptTextConfig.GetConfig(textId)
	self.bindData.skillFeedbackMessage = gString.Format(cfg and cfg.Text or "", tip)
	self.bindData.showSkillFeedback = 1

	if self.skillFeedbackTimer then
		self.skillFeedbackTimer:Stop()

		self.skillFeedbackTimer = nil
	end

	self.skillFeedbackTimer = Timer.New(function ()
		self.bindData.showSkillFeedback = 0
		self.skillFeedbackTimer = nil
	end, 1):Start()
end

M.OnGomokuOpponentUsedSkill = function(self, _, data)
	if data and data.ToTable then
		data = data.ToTable(data)
	end

	local skillId = data.skillId
	local skillConfig = LTConfig.PoiGameGomokuSkillConfig.GetConfig(skillId)

	if skillConfig then
		self.ShowSkillFeedback(self, 89901408, skillConfig.Name)
	end
end

M.OnGomokuSkillPlayerChosen = function(self, _, skillId)
	if not self.useSkill then
		return
	end

	local skillConfig = LTConfig.PoiGameGomokuSkillConfig.GetConfig(skillId)

	if skillConfig then
		self.bindData.skillBtnName = skillConfig.Name
		self.bindData.skillBtnIcon = skillConfig.SkillButtonIcon
		self.bindData.skillBtnIconVx = skillConfig.SkillButtonIcon
	end
end
