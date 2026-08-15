local PoiGameDiceBadgetConfig = LTConfig.PoiGameDiceBadgetConfig
local PoiGameConfig = LTConfig.PoiGameConfig
local DragEventListener = SGUI.EventSystems.DragEventListener
local DiceState = L50.Gameplay.DiceGame.DiceGameManager.DiceState
local DiceGameManager = L50.Gameplay.DiceGame.DiceGameManager
local DiceFindDir = L50.Gameplay.DiceGame.DiceGameManager.DiceFindDir
local GameInputManager = LX6.Manager.GameInputManager
local gamePanelStage = {
	settle = 4,
	waitSettle = 3,
	waitOpen = 1,
	empty = 2,
	waitStart = 0
}
local hoverScaleValue = 1.05
local pressScaleValue = 0.95
C_BarGamePlayPanelStore = DefClass("C_BarGamePlayPanelStore", C_BarGamePlayPanelStore, C_StoreGroup)
GroupName2Class.BarGamePlayPanelStore = C_BarGamePlayPanelStore
local M = C_BarGamePlayPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.diceGame = nil
	self.slotEntity = nil
	self.gameState = nil
	self.isClose = false
	self.inShake = false
	self.skills = nil
	self.skillBtnStore = {}
	self.enemySkills = {}
	self.enemySkillBtnStore = {}
	self.skill107Timer = nil
	self.drag = nil
	self.mouseAction = nil
	self.lastTouch = nil
	self.lastTouchX = nil
	self.lastTouchY = nil
	self.mouseScrollCallback = nil
	self.needUpdateJoyStick = false
	self.rightStickValueX = 0
	self.rightStickValueY = 0
	local pcShakeCfg = PoiGameConfig.Dice_InputRate_PC
	local mobileShakeCfg = PoiGameConfig.Dice_InputRate_Mobile
	local consoleShakeCfg = PoiGameConfig.Dice_InputRate_Console
	self.pcShakeSensitivity = pcShakeCfg[1]
	self.pcShakeDeadZone = pcShakeCfg[2]
	self.pcShakeThreshold = pcShakeCfg[3]
	self.mobileShakeSensitivity = mobileShakeCfg[1]
	self.mobileShakeDeadZone = mobileShakeCfg[2]
	self.mobileShakeThreshold = mobileShakeCfg[3]
	self.consoleShakeSensitivity = consoleShakeCfg[1]
	self.consoleShakeDeadZone = consoleShakeCfg[2]
	self.consoleShakeThreshold = consoleShakeCfg[3]
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
	self.diceGame = data.diceGame
	self.slotEntity = data.slot
	self.skills = data.skills
	self.gameState = nil
	self.isMyRound = false
	self.gameState = self.diceGame:DiceGameGetNowState()

	self:InitGameSkills()
	self:InitShakePart()

	self.bindData.gameStageCtrl = gamePanelStage.empty
	self.bindData.myTotalScoreText = 0
	self.bindData.enemyTotalScoreText = 0
	self.bindData.myProgress = 0
	self.bindData.rivalProgress = 0
	self.bindData.myTargetScoreText = self.diceGame:DiceGameGetTotalScore()
end

function M:OnUpdate()
	self:UpdateJoyStickMove()
	self:UpdateDualSenseShake()
end

function M:OnClose()
	if self.mouseAction then
		gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.mouseAction)
	end
end

function M:OnDestroy()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end
end

function M:OnActiveDeviceChange(scheme)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.mainNavi
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.DICE_GAME_STATE_CHANGE] = function (eventId, data)
			print_debug("进入状态", data)

			self.gameState = data

			self:RefreshCurrentState()
		end,
		[gEventConstants.DICE_GAME_NOW_ROUND_PLAYER_CHANGE] = function (eventId, data)
			print_debug("确定本回合玩家，是否是本人", data)

			self.isMyRound = data

			self:RefreshNowRoundPlayer()
			self:CheckEnemyAllSkillStates(true)
		end,
		[gEventConstants.DICE_GAME_SPECIAL_SKILL_USE] = function (eventId, data)
			if data == 107 then
				self:HandleSkill107()
			end
		end,
		[gEventConstants.DICE_GAME_ALL_PLAYER_INIT_FINISH] = function (eventId)
			self:RefreshEnemySkill()
		end,
		[gEventConstants.DICE_GAME_ENEMY_USE_SKILL] = function (eventId, badgeId)
			self:CheckEnemyAllSkillStates()
			self:ShowEnemySkillUse(badgeId)
		end
	}
end

function M:RegisterWidget()
	self.bindData.skill1Btn.luaClick = self:CreateAction("OnClickSkill1Btn")
	self.bindData.skill2Btn.luaClick = self:CreateAction("OnClickSkill2Btn")
	self.bindData.skill3Btn.luaClick = self:CreateAction("OnClickSkill3Btn")
	self.bindData.skill1Btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTipsSelf", 1)
	self.bindData.skill2Btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTipsSelf", 2)
	self.bindData.skill3Btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTipsSelf", 3)
	self.bindData.enemySkill1Btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTipsEnemy", 1)
	self.bindData.enemySkill2Btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTipsEnemy", 2)
	self.bindData.enemySkill3Btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTipsEnemy", 3)
	self.bindData.startBtn.luaClick = self:CreateAction("OnClickStartBtn")
	self.bindData.openBoxBtn.luaClick = self:CreateAction("OnClickOpenBoxBtn")
	self.bindData.rethrowBtn.luaClick = self:CreateAction("OnClickRethrowBtn")
	self.bindData.skipBtn.luaClick = self:CreateAction("OnClickSkipBtn")
	self.bindData.selectBtn.luaClick = self:CreateAction("OnClickSelectBtn")
	self.bindData.exitBtn.luaClick = self:CreateAction("OnClickExitBtn")
	self.bindData.wBtn.luaClick = self:CreateActionWithArgs("OnClickFocusMoveBtn", DiceFindDir.up)
	self.bindData.aBtn.luaClick = self:CreateActionWithArgs("OnClickFocusMoveBtn", DiceFindDir.left)
	self.bindData.sBtn.luaClick = self:CreateActionWithArgs("OnClickFocusMoveBtn", DiceFindDir.down)
	self.bindData.dBtn.luaClick = self:CreateActionWithArgs("OnClickFocusMoveBtn", DiceFindDir.right)
	self.bindData.skill107CancelBtn.luaClick = self:CreateAction("OnClickSkill107CancelBtn")
	self.bindData.skill107RethrowBtn.luaClick = self:CreateAction("OnClickSkill107RethrowBtn")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		function self.bindData.ruleBtn.luaPress()
			self.bindData.ruleCtrl = 1

			gCS.GuiUtils.SetPanelHideCursor(self.m_Id, false)
		end

		function self.bindData.ruleBtn.luaRelease()
			self.bindData.ruleCtrl = 0

			gCS.GuiUtils.SetPanelHideCursor(self.m_Id, true)
		end
	else
		function self.bindData.ruleBtn.luaClick()
			self.bindData.ruleCtrl = 1
		end
	end

	function self.bindData.infoCloseBtn.luaClick()
		self.bindData.ruleCtrl = 0

		gCS.GuiUtils.SetPanelHideCursor(self.m_Id, true)
	end

	self.mouseScrollCallback = self:CreateAction("OnMouseScroll")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end

	self.bindData.joyStick.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
	self.bindData.joyStickShake.luaGamePadInputChanged = self:CreateAction("OnRightStickShakeControl")
end

function M:OnClickSkill1Btn()
	if self.skillBtnStore[1].passiveCtrl == 1 then
		return
	end

	self.diceGame:DoActiveSkillCurrent(self.skills[1].id)
	self:CheckAllSkillStates()
end

function M:OnClickSkill2Btn()
	if self.skillBtnStore[2].passiveCtrl == 1 then
		return
	end

	self.diceGame:DoActiveSkillCurrent(self.skills[2].id)
	self:CheckAllSkillStates()
end

function M:OnClickSkill3Btn()
	if self.skillBtnStore[3].passiveCtrl == 1 then
		return
	end

	self.diceGame:DoActiveSkillCurrent(self.skills[3].id)
	self:CheckAllSkillStates()
end

function M:OnClickStartBtn()
	self.diceGame:ChangeToShakeState()
	self.bindData.startBtn:SetActive(false)
end

function M:OnClickOpenBoxBtn()
	self.inShake = false

	self.diceGame:ChangeToAfterShakeState()

	self.bindData.gameStageCtrl = 2
end

function M:OnClickRethrowBtn()
	self.diceGame:Rethrow()

	self.bindData.gameStageCtrl = gamePanelStage.empty
end

function M:OnClickSkipBtn()
	self.diceGame:SkipToSettle()

	self.bindData.gameStageCtrl = gamePanelStage.empty
end

function M:OnClickSelectBtn()
	self.diceGame:SelectDice()

	if self.diceGame:GetIfHasSelectDice() then
		self.bindData.rethrowBtn.interactable = true
	else
		self.bindData.rethrowBtn.interactable = false
	end
end

function M:OnClickExitBtn()
	self.diceGame:ForceExitCurrentGame()

	self.isClose = true

	gPanelManager:Close(self.m_Id)
end

function M:OnClickFocusMoveBtn(dir)
	self.diceGame:MoveDiceFocus(dir)
end

function M:OnClickSkill107CancelBtn()
	gLuaTimeMgrUtils.CancelUnitDelay(self.skill107Timer)

	self.bindData.bustSkill107Ctrl = 0

	self.diceGame:UseSkill107CancelRethrow()
end

function M:OnClickSkill107RethrowBtn()
	gLuaTimeMgrUtils.CancelUnitDelay(self.skill107Timer)

	self.bindData.bustSkill107Ctrl = 0

	self.diceGame:UseSkill107Rethrow()
end

function M:OnRenderToolTipsSelf(index, btn, widget, btnIndex)
	local store = gStoreManager:GetStoreGroup("DiceBadgeToolTipTemplate"):GetStoreByWidget(widget)
	local badgeId = self.skills[index].id
	store.badgeNameText = PoiGameDiceBadgetConfig.GetConfig(badgeId).Name
	store.badgeDescText = PoiGameDiceBadgetConfig.GetConfig(badgeId).Des
end

function M:OnRenderToolTipsEnemy(index, btn, widget, btnIndex)
	local store = gStoreManager:GetStoreGroup("DiceBadgeToolTipTemplate"):GetStoreByWidget(widget)
	local badgeId = self.enemySkills[index]
	store.badgeNameText = PoiGameDiceBadgetConfig.GetConfig(badgeId).Name
	store.badgeDescText = PoiGameDiceBadgetConfig.GetConfig(badgeId).Des
end

function M:OnMouseScroll(context)
	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
		return
	end

	if context.performed then
		local zoom = context:ReadValueVector2().y

		if zoom > 0 then
			self.diceGame:CircleSelectDice(false)
		else
			self.diceGame:CircleSelectDice(true)
		end
	end
end

function M:InitGameSkills()
	self.bindData.skillCtrl = 0

	self.diceGame:InitSkill(self.skills[1] and self.skills[1].id or 0, self.skills[2] and self.skills[2].id or 0, self.skills[3] and self.skills[3].id or 0)

	for i, _ in ipairs(self.skills) do
		local store = gStoreManager:GetStoreGroup("DiceGameSkillBtnTemplate"):GetStoreByWidget(self.bindData[string.format("skill%dBtn", i)])
		self.skillBtnStore[i] = store
	end

	self.bindData.enemySkillStateCtrl = 0

	self.bindData.startBtn:SetActive(false)
end

function M:RefreshCurrentState()
	if self.gameState == DiceState.prepareState then
		self.bindData.gameStageCtrl = gamePanelStage.empty
	end

	if self.gameState == DiceState.beforeShakeState then
		self:RefreshTotalScore()
	end

	if self.gameState == DiceState.shakeState then
		self.inShake = true
		self.bindData.gameStageCtrl = 2
	end

	if self.isMyRound then
		if self.gameState == DiceState.shakeState then
			self.bindData.gameStageCtrl = gamePanelStage.waitOpen
			self.bindData.openBoxBtn.interactable = false
		elseif self.gameState == DiceState.afterShakeState then
			self.bindData.gameStageCtrl = gamePanelStage.waitSettle
			self.bindData.rethrowBtn.interactable = false
		elseif self.gameState == DiceState.bustState then
			self.bindData.gameStageCtrl = gamePanelStage.empty
		end
	else
		self:CheckEnemyAllSkillStates()
	end

	if self.gameState == DiceState.roundSettleState then
		self.bindData.gameStageCtrl = gamePanelStage.settle

		self:RefreshRoundSettle()
	end

	if self.gameState == DiceState.settleState then
		self:DoGameSettle()
	end

	if self.gameState ~= DiceState.beforeShakeState then
		self.bindData.startBtn:SetActive(false)
	end

	self:CheckAllSkillStates()
end

function M:RefreshNowRoundPlayer()
	if not self.isMyRound then
		self.bindData.gameStageCtrl = gamePanelStage.empty
	else
		self.bindData.gameStageCtrl = gamePanelStage.waitStart

		self.bindData.startBtn:SetActive(self:CheckHasBeforeShakeSkill())
	end

	self:CheckAllSkillStates()
end

function M:RefreshRoundSettle()
	self.bindData.targetScoreText = self.diceGame:DiceGameGetTotalScore()
	self.bindData.pointText = self.diceGame:GetTotalLiteral()
	self.bindData.timesText = self.diceGame:GetTotalTimes()
	self.bindData.roundScoreText = self.diceGame:GetNowRoundScore()
	self.bindData.totalScoreText = self.diceGame:GetTotalRoundScore()
end

function M:RefreshTotalScore()
	local myScore = self.diceGame:GetPlayerTotalRoundScore(true)
	local rivalScore = self.diceGame:GetPlayerTotalRoundScore(false)
	local totalScore = self.diceGame:DiceGameGetTotalScore()
	self.bindData.myTotalScoreText = myScore
	self.bindData.enemyTotalScoreText = rivalScore
	self.bindData.myTargetScoreText = totalScore
	self.bindData.myProgress = myScore / totalScore
	self.bindData.rivalProgress = rivalScore / totalScore
end

function M:RefreshEnemySkill()
	local enemyBadges = self.diceGame:GetEnemyBadgesSkills()
	local skillNum = enemyBadges.Count

	if skillNum > 0 then
		self.bindData.enemySkillStateCtrl = 1
	else
		self.bindData.enemySkillStateCtrl = 0
	end

	self.bindData.enemySkillNumCtrl = skillNum

	for i = 1, skillNum do
		local store = gStoreManager:GetStoreGroup("DiceGameSkillBtnTemplate"):GetStoreByWidget(self.bindData[string.format("enemySkill%dBtn", i)])
		self.enemySkillBtnStore[i] = store
		self.enemySkills[i] = enemyBadges[i - 1]
	end
end

function M:DoGameSettle()
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(self.m_Id)
	end, 3)
end

function M:CheckAllSkillStates()
	if not self.isMyRound then
		return
	end

	for i, badge in ipairs(self.skills) do
		local canUse, useTimes = self.diceGame:CheckSkillCanUseWithTimes(badge.id, nil)
		local btn = self.bindData[string.format("skill%dBtn", i)]
		local btnStore = self.skillBtnStore[i]

		self:SetButtonLookLikeDisable(false, btn, btnStore, false)

		if canUse then
			self:SetButtonLookLikeDisable(false, btn, btnStore)
		else
			self:SetButtonLookLikeDisable(true, btn, btnStore)
		end

		if useTimes >= 0 then
			self.skillBtnStore[i].timesCtrl = 1
			self.skillBtnStore[i].timesText = useTimes
			self.skillBtnStore[i].skillText = PoiGameDiceBadgetConfig.GetConfig(badge.id).Name
			self.skillBtnStore[i].skillIcon = PoiGameDiceBadgetConfig.GetConfig(badge.id).IconId
		else
			self.skillBtnStore[i].timesCtrl = 0
			self.skillBtnStore[i].skillText = PoiGameDiceBadgetConfig.GetConfig(badge.id).Name
			self.skillBtnStore[i].skillIcon = PoiGameDiceBadgetConfig.GetConfig(badge.id).IconId
		end
	end

	self.bindData.skillCtrl = #self.skills
end

function M:CheckEnemyAllSkillStates(force)
	if self.isMyRound and not force then
		return
	end

	for i, badge in ipairs(self.enemySkills) do
		local canUse, useTimes = self.diceGame:CheckSkillCanUseWithTimes(badge, nil)
		local btn = self.bindData[string.format("enemySkill%dBtn", i)]
		local btnStore = self.enemySkillBtnStore[i]

		self:SetButtonLookLikeDisable(false, btn, btnStore, true)

		if useTimes >= 0 then
			self.enemySkillBtnStore[i].timesCtrl = 1
			self.enemySkillBtnStore[i].timesText = useTimes
			self.enemySkillBtnStore[i].skillText = PoiGameDiceBadgetConfig.GetConfig(badge).Name
			self.enemySkillBtnStore[i].skillIcon = PoiGameDiceBadgetConfig.GetConfig(badge).IconId
		else
			self.enemySkillBtnStore[i].timesCtrl = 0
			self.enemySkillBtnStore[i].skillText = PoiGameDiceBadgetConfig.GetConfig(badge).Name
			self.enemySkillBtnStore[i].skillIcon = PoiGameDiceBadgetConfig.GetConfig(badge).IconId
		end
	end
end

function M:ShowEnemySkillUse(badgeId)
	self.bindData.enemySkillStateCtrl = 2
	self.bindData.enemySkillText = PoiGameDiceBadgetConfig.GetConfig(badgeId).Name

	gLuaTimeMgrUtils.Delay(function ()
		if gPanelManager:IsPanelShowing(self.m_Id) then
			self.bindData.enemySkillStateCtrl = 1
		end
	end, 0.9)
end

function M:SetButtonLookLikeDisable(disable, btn, btnStore, force)
	if disable or force then
		btnStore.passiveCtrl = 1
		btn.hoverScaleValue = 1
		btn.pressScaleValue = 1
	else
		btnStore.passiveCtrl = 0
		btn.hoverScaleValue = hoverScaleValue
		btn.pressScaleValue = pressScaleValue
	end
end

function M:HandleSkill107()
	self.bindData.bustSkill107Ctrl = 1
	self.bindData.skill107Progress.value = 1

	self.bindData.skill107Progress:ProgressToValue(0, 3, 0)

	self.skill107Timer = gLuaTimeMgrUtils.Delay(function ()
		if gPanelManager:IsPanelShowing(self.m_Id) then
			self.bindData.bustSkill107Ctrl = 0

			self.diceGame:UseSkill107CancelRethrow()
		end
	end, 3)
end

function M:CheckHasBeforeShakeSkill()
	for _, skill in ipairs(self.skills) do
		local cfg = PoiGameDiceBadgetConfig.GetConfig(skill.id)

		if cfg then
			local phase = cfg.UsePhase

			if phase == PoiGameDiceBadgetConfig.UsePhaseType.before then
				return true
			end
		end
	end

	return false
end

function M:InitShakePart()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.mouseAction = self:CreateAction("UpdateShakeBoxMove")

		gMessageManager:AddMessageListener(gEventConstants.MOUSE_MOVE, self.mouseAction)
	else
		self.drag = DragEventListener.Get(self.bindData.drag.gameObject)
		self.drag.onDrag = self:CreateAction("DragToShake")

		function self.drag.onBeginDrag()
			self.lastTouch = gUtils:GetTouchPosition()
		end

		function self.drag.onEndDrag()
			self.lastTouch = nil
		end
	end
end

function M:DragToShake(eventData)
	if self.gameState ~= DiceState.shakeState or self.isClose then
		return
	end

	if not self.inShake then
		return
	end

	local offset = eventData.delta
	local xDir = -offset.x * self.mobileShakeSensitivity
	local yDir = offset.y * self.mobileShakeSensitivity
	xDir = Mathf.Clamp(xDir, -self.mobileShakeThreshold, self.mobileShakeThreshold)
	yDir = Mathf.Clamp(yDir, -self.mobileShakeThreshold, self.mobileShakeThreshold)

	if math.abs(offset.x) < self.mobileShakeDeadZone then
		xDir = 0
	end

	if math.abs(offset.y) < self.mobileShakeDeadZone then
		yDir = 0
	end

	if self.bindData.openBoxBtn.interactable == false and (xDir ~= 0 or yDir ~= 0) then
		self.bindData.openBoxBtn.interactable = true
	end

	self.diceGame:PlayerShakeDiceBox(xDir, yDir)
end

function M:UpdateShakeBoxMove(eventId, data)
	if not self.gameState or self.gameState ~= DiceState.shakeState then
		return
	end

	if not self.inShake then
		return
	end

	local offsetX = -data.x * self.pcShakeSensitivity
	local offsetY = data.y * self.pcShakeSensitivity
	local xDir = Mathf.Clamp(offsetX, -self.pcShakeThreshold, self.pcShakeThreshold)
	local yDir = Mathf.Clamp(offsetY, -self.pcShakeThreshold, self.pcShakeThreshold)

	if math.abs(offsetX) < self.pcShakeDeadZone then
		xDir = 0
	end

	if math.abs(offsetY) < self.pcShakeDeadZone then
		yDir = 0
	end

	if self.bindData.openBoxBtn.interactable == false and (xDir ~= 0 or yDir ~= 0) then
		self.bindData.openBoxBtn.interactable = true
	end

	self.diceGame:PlayerShakeDiceBox(xDir, yDir)
end

function M:OnRightStickControl(context)
	if self.gameState ~= DiceState.shakeState then
		return
	end

	if not self.inShake then
		return
	end

	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.needUpdateJoyStick = true
		local xDir = -value.x * self.consoleShakeSensitivity
		local yDir = value.y * self.consoleShakeSensitivity
		xDir = Mathf.Clamp(xDir, -self.consoleShakeThreshold, self.consoleShakeThreshold)
		yDir = Mathf.Clamp(yDir, -self.consoleShakeThreshold, self.consoleShakeThreshold)

		if math.abs(value.x) < self.consoleShakeDeadZone then
			xDir = 0
		end

		if math.abs(value.y) < self.consoleShakeDeadZone then
			yDir = 0
		end

		if self.bindData.openBoxBtn.interactable == false and (xDir ~= 0 or yDir ~= 0) then
			self.bindData.openBoxBtn.interactable = true
		end

		self.rightStickValueX = xDir
		self.rightStickValueY = yDir
	end

	if context.canceled then
		self.needUpdateJoyStick = false
		self.rightStickValueX = 0
		self.rightStickValueY = 0

		self.diceGame:PlayerShakeDiceBox(self.rightStickValueX, self.rightStickValueY)
	end
end

function M:UpdateJoyStickMove()
	if self.gameState ~= DiceState.shakeState or not self.needUpdateJoyStick then
		return
	end

	if self.bindData.ruleCtrl == 1 then
		return
	end

	if not self.inShake then
		return
	end

	self.diceGame:PlayerShakeDiceBox(self.rightStickValueX, self.rightStickValueY)
end

function M:UpdateDualSenseShake()
	if self.gameState ~= DiceState.shakeState then
		return
	end

	if gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.PlayStation then
		return
	end

	if not self.allowShake then
		return
	end

	if not self.inShake then
		return
	end

	local motionData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadMotionData()
	local angularVelocity = motionData.angularVelocity
	local x = math.abs(angularVelocity.x) < 0.1 and 0 or angularVelocity.x
	local z = math.abs(angularVelocity.z) < 0.1 and 0 or angularVelocity.z

	if self.bindData.openBoxBtn.interactable == false and (x ~= 0 or z ~= 0) then
		self.bindData.openBoxBtn.interactable = true
	end

	self.diceGame:HandleDualSenseShake(x, z)
end

function M:OnRightStickShakeControl(context)
	if self.gameState ~= DiceState.shakeState then
		return
	end

	if context.started or context.performed then
		self.allowShake = true
	end

	if context.canceled then
		self.allowShake = false
	end
end
