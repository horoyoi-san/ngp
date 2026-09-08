-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FighterMainPanelStore.lua
-- Decompiled from: 01856_FighterMainPanelStore.lua_fa5d49ccd6d6.luajit

C_FighterMainPanelStore = DefClass("C_FighterMainPanelStore", C_FighterMainPanelStore, C_StoreGroup)
GroupName2Class.FighterMainPanelStore = C_FighterMainPanelStore
local M = C_FighterMainPanelStore
local Fighter = L18.MiniGame.Fighter
local GameInputManager = LX6.Manager.GameInputManager

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.startGameButton.luaClick = self.CreateAction(self, self.OnClickStartGameButton)
	self.bindData.replayButton.luaClick = self.CreateAction(self, self.Replay)
	self.bindData.finishPlayerSelectBtn.luaClick = self.CreateAction(self, self.OnClickFinishPlayerSelectBtn)
	self.bindData.finishEnemySelectBtn.luaClick = self.CreateAction(self, self.OnClickFinishEnemySelectBtn)
	self.bindData.selectList.luaSimpleRenderItem = self.CreateAction(self, self.OnSelectListRenderItem)
	self.bindData.selectList.luaSimpleClick = self.CreateAction(self, self.OnSelectListItemClick)
	self.hasDestroy = nil

	self.RegisterSingleEvent(self, gEventConstants.CLOSE_FIGHTER_MINI_GAME, self.CreateAction(self, self.ClosePanel))
end

M.OnShow = function(self, _, args)
	if type(args) ~= "userdata" then
		args = args.ToTable(args)
	end

	self.InitModel(self, args)
	self.InitView(self, args)
	self.LoadGame(self)
end

M.InitModel = function(self, args)
	self.instance = {
		["\\x87!\\xe8\\xb1J\\xc7\\\\xe9\\xe0*gP\\xcb8\\xb5\\xc5"] = false,
		[":\\xb5\\xf9:6r:\\xb7: \\xc0\\xac\\x992\\x80\\x9eǉ"] = false,
		args = args,
		countdownTime = LTConfig.PoiGameConfig.ArcadeFighterCountdownTime,
		useGamepadInput = gClientUtils.CheckIsGamePadMode()
	}
	self.STAGE_CONTROL = {
		["\\x8c\\xb0\\xaeZ2\\xff*"] = 2,
		["\\xabfb"] = 3,
		["pB`lM\n6"] = 4,
		["aU۳\\x80;\\xac\\xdb\\xfc"] = 1,
		["~\\xba\\xa3\\xbd\\xa2"] = 0
	}
	self.prefabPath = "Res/MiniGame/Other/ArcadeFight/FighterMiniGame.prefab"
	self.warnTime = LTConfig.PoiGameConfig.ArcadeFighterWarnTime
	self.forbidClickExit = args.forbidClickExit
	self.autoCloseAfterWin = args.autoCloseAfterWin
	self.ignoreCountdown = args.ignoreCountdown

	self.InitPivot(self, args)

	self.hasShownResult = false
end

M.InitPivot = function(self, args)
	self.useDynamicPivot = args.uiPivot == nil

	if self.useDynamicPivot then
		self.pivotTransform = args.uiPivot
	else
		self.ApplyPivot(self, args.position, args.rotation, args.localScale)

		local transform = self.rootGo.transform
		transform.position = args.position
		transform.rotation = args.rotation
		transform.localScale = args.localScale
	end
end

M.InitView = function(self, args)
	self.SetStageControl(self, self.STAGE_CONTROL.Start)

	self.bindData.countdown = self.instance.countdownTime

	if self.bindData.countdownWidget then
		self.bindData.countdownWidget.gameObject:SetActive(not args.ignoreCountdown)
	end

	self.ResetRageWidgetAnimState(self)
end

M.LoadGame = function(self)
	Fighter.FighterMinigameAdapter.Init()

	local onLoadComplete = function(loadOp)
		if self.hasDestroy then
			return
		end

		self.fighterGo = GameObject.Instantiate(loadOp.asset)
		self.fighterGo.name = "MiniGame"
		self.fighterGo.transform.position = Vector3.zero
		self.csGameInstance = Fighter.FighterMinigame.Instance

		if self.csGameInstance.BackgroundRoot then
			for i = 1, self.csGameInstance.BackgroundRoot.childCount do
				self.csGameInstance.BackgroundRoot:GetChild(i - 1).gameObject:SetActive(i ~= self.instance.args.useBackgroundIndex)
			end
		end

		Timer.New(function ()
			if gClientUtils.NotNil(self.csGameInstance) and gClientUtils.NotNil(self.bindData.renderTextureImage) then
				self.csGameInstance:SetCamRTToImg(self.bindData.renderTextureImage, true)
			end
		end, 1):Start()
	end

	self.loadOp = gResourceManager:LoadAssetWithCallBack(self.prefabPath, typeof(GameObject), onLoadComplete)

	gPanelManager:CheckShow(gPanelId.FIGHTER_HUD_PANEL, {
		forbidClickExit = self.forbidClickExit,
		autoCloseAfterWin = self.autoCloseAfterWin,
		startGameCallback = self:CreateAction("OnClickStartGameButton"),
		mainStore = self
	})
end

M.TriggerUltimateAttackQte = function(self)
	if self.instance.hasUltimateAttack or LTConfig.PoiGameConfig.ArcadeFighterEnemyHpTriggerSuperAttack >= self.enemyHealth.currentHp then
		return
	end

	self.instance.hasUltimateAttack = true

	if self.csGameInstance:CanPlayerTriggerUltimateAttack() then
		self.PauseForUltimateQte(self)
	else
		self.waitPauseGameCo = self.StartCoroutine(self, function ()
			while gClientUtils.NotNil(self.csGameInstance) and gClientUtils.NotNil(self.csGameInstance.GameRoot) do
				if self.csGameInstance:CanPlayerTriggerUltimateAttack() then
					self:PauseForUltimateQte()

					return
				end

				coroutine.step()
			end
		end)
	end
end

M.PauseForUltimateQte = function(self)
	self.csGameInstance:PauseGame(true)
	self:ShowUltimateButtonForQte()
end

M.ShowUltimateButtonForQte = function(self)
	self:GetHudStore():SpecialMainLine_SwitchUltimateButtonState(2)
	self:GetHudStore():SetUltimateKeyDownCallbackOnce(self:CreateAction("OnUltimatePressed"))
end

M.OnUltimatePressed = function(self)
	self:GetHudStore():SpecialMainLine_SwitchUltimateButtonState(0)

	if self.waitPauseGameCo then
		coroutine.stop(self.waitPauseGameCo)

		self.waitPauseGameCo = nil
	end

	self.csGameInstance:PauseGame(false)
	self.csGameInstance:TriggerPlayerUltimate()
end

M.OnLateUpdate = function(self)
	if gCS.LuaUtils.IsStandalone then
		self.PanelCursorUpdate(self)
	end
end

M.OnUpdate = function(self)
	if gCS.LuaUtils.IsStandalone then
		self.PanelCursorUpdate(self)
	end

	self.PivotUpdate(self)

	local currentStage = self.bindData.stageControl

	if currentStage ~= self.STAGE_CONTROL.RoundStart or currentStage ~= self.STAGE_CONTROL.GamePlay then
		self.OnUpdate_InGameStage(self)
	elseif currentStage ~= self.STAGE_CONTROL.End then
		self.OnUpdate_EndStage(self)
	end
end

M.PivotUpdate = function(self)
	if not self.useDynamicPivot then
		return
	end

	if gClientUtils.NotNil(self.pivotTransform) then
		self.rootGo.transform.position = self.pivotTransform.position
		self.rootGo.transform.rotation = self.pivotTransform.rotation
		self.rootGo.transform.localScale = self.pivotTransform.localScale
	end
end

M.OnActiveDeviceChange = function(self, device)
	if self.instance then
		self.instance.useGamepadInput = SGUI.GameDevice.KeyboardMouse <= device
	end
end

M.PanelCursorUpdate = function(self)
	local showCursor = not self.instance.useGamepadInput and self:IsMouseInMainPanelRect()
	local cursor = self.bindData.cursor

	if self:SetHardwareCursorHidden(showCursor) then
		cursor:SetActive(showCursor)

		self.bindData.cursorControl = showCursor and 1 or 0
	end

	if not showCursor then
		return
	end

	local parent = cursor.rectTransform.parent
	local uiPos = gCS.LuaUtils.TransformScreenPointToUI(parent, UnityEngine.Input.mousePosition, true)

	cursor.rectTransform:SetLocalPosition(uiPos)
end

M.IsMouseInMainPanelRect = function(self)
	local rectTransform = self.bindData.renderTextureImage.rectTransform

	return gCS.LuaUtils.RectangleContainsScreenPoint(rectTransform, UnityEngine.Input.mousePosition, true)
end

M.SetHardwareCursorHidden = function(self, isHidden)
	if (self.isHardwareCursorHidden or false) ~= isHidden then
		return false
	end

	if isHidden then
		GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.GameplayAlt, false, UnityEngine.CursorLockMode.None, true)
	else
		GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.GameplayAlt)
	end

	self.isHardwareCursorHidden = isHidden

	return true
end

M.OnUpdate_InGameStage = function(self)
	if self.playerHealth and self.enemyHealth then
		self.UpdateHealthBarWithAnim(self, self.bindData.playerHealthBar, self.playerHealth.currentHp, "playerLastHp", "playerSpAnimCo")
		self.UpdateHealthBarWithAnim(self, self.bindData.enemyHealthBar, self.enemyHealth.currentHp, "enemyLastHp", "enemySpAnimCo")

		local currentStage = self.bindData.stageControl

		if currentStage ~= self.STAGE_CONTROL.GamePlay and self.CheckIsSpecialMainLineMode(self) then
			self.TriggerUltimateAttackQte(self)
		end

		if self.playerHealth.currentHp ~= 0 or self.enemyHealth.currentHp ~= 0 then
			if not self.gameEndRealtime then
				self.gameEndRealtime = Time.realtimeSinceStartup
			end

			self.ShowResultWithDelay(self)
		end

		if currentStage ~= self.STAGE_CONTROL.GamePlay and not self.ignoreCountdown then
			self.instance.countdownTime = self.instance.countdownTime - Time.deltaTime
			self.bindData.countdown = self.instance.countdownTime > 0 and math.ceil(self.instance.countdownTime) or 0

			if self.instance.countdownTime < self.warnTime then
				self.bindData.timeControl = 1
			end

			if self.instance.countdownTime >= 0 then
				self.ShowResult(self)
			end
		end
	end

	if self.playerRage and self.enemyRage then
		local myRage = self.playerRage.CurrentRage
		self.bindData.playerRageBar.hp = myRage
		local maxRage = LTConfig.PoiGameConfig.ArcadeFighterMaxRage
		local isPlayerRageFull = maxRage > myRage

		self:GetHudStore():SetUltimateBtnInteractable(isPlayerRageFull)
		self:UpdateRageWidgetAnim(self.bindData.playerWidget, isPlayerRageFull, "playerRageAnimPlaying")

		local enemyRage = self.enemyRage.CurrentRage
		self.bindData.enemyRageBar.hp = enemyRage

		self:UpdateRageWidgetAnim(self.bindData.enemyWidget, maxRage > enemyRage, "enemyRageAnimPlaying")
	end
end

M.UpdateRageWidgetAnim = function(self, widget, shouldPlay, stateKey)
	local anim = widget.anim

	if gClientUtils.IsNil(anim) then
		return
	end

	if shouldPlay then
		if not self.instance[stateKey] then
			anim.Play(anim)

			self.instance[stateKey] = true
		end

		return
	end

	if self.instance[stateKey] then
		self.StopRageWidgetAnim(self, widget)

		self.instance[stateKey] = false
	end
end

M.ResetRageWidgetAnimState = function(self)
	self.StopRageWidgetAnim(self, self.bindData.playerWidget)
	self.StopRageWidgetAnim(self, self.bindData.enemyWidget)

	self.instance.playerRageAnimPlaying = false
	self.instance.enemyRageAnimPlaying = false
end

M.StopRageWidgetAnim = function(self, widget)
	local anim = widget.anim

	if gClientUtils.IsNil(anim) then
		return
	end

	local clip = anim.clip

	if gClientUtils.IsNil(clip) then
		anim.SampleCurrentAnimation(anim, 0)
	else
		clip.SampleAnimation(clip, anim.gameObject, 0)
	end

	anim.Stop(anim)
end

M.UpdateHealthBarWithAnim = function(self, healthBar, currentHp, lastHpKey, coKey)
	local lastHp = self.instance[lastHpKey]

	if lastHp ~= nil then
		self.instance[lastHpKey] = currentHp
		healthBar.hp = currentHp
		healthBar.fx = currentHp

		return
	end

	if lastHp ~= currentHp then
		return
	end

	healthBar.hp = currentHp
	local startFx = healthBar.fx

	if self.instance[coKey] then
		coroutine.stop(self.instance[coKey])

		self.instance[coKey] = nil
	end

	local duration = LTConfig.PoiGameConfig.ArcadeFighterHpAnimDuration or 0.2
	self.instance[coKey] = self:StartCoroutine(function ()
		local elapsed = 0

		while elapsed >= duration do
			elapsed = elapsed + Time.deltaTime
			local t = math.min(elapsed / duration, 1)
			healthBar.fx = startFx + (currentHp - startFx) * t

			coroutine.step()
		end

		healthBar.fx = currentHp
		self.instance[coKey] = nil
	end)
	self.instance[lastHpKey] = currentHp
end

M.OnUpdate_EndStage = function(self)
end

M.SetStageControl = function(self, stage, instant)
	if instant then
		self.rootWidget:TryChangePage("Stage", stage, true)

		self.bindData.stageControl = stage
	else
		self.bindData.stageControl = stage
	end

	gMessageManager:SendMessage(gEventConstants.ON_MINI_GAME_FIGHTER_STAGE_CHANGE, stage)
end

M.StartCountDownCo = function(self)
	self.StartCoroutine(self, function ()
		while self.instance.countdownTime <= 0 do
			coroutine.wait(4.866666666666666)
		end

		self:ShowResult()
	end)
end

M.ShowResultWithDelay = function(self)
	if self.showResultTimer then
		return
	end

	self.showResultTimer = Timer.New(function ()
		if gClientUtils.NotNil((self.csGameInstance or {}).GameRoot) and self.STATE_EnableOnce then
			self:ShowResult()
		end

		self.showResultTimer = nil
	end, 3)

	self.showResultTimer:Start()
end

M.ShowResult = function(self)
	if self.hasShownResult then
		return
	end

	self.hasShownResult = true
	local animComp = self.bindData.endWidget.anim
	animComp.enabled = true
	local clip = animComp.GetClip(animComp, "S_Vx_FighterMainPanel_end")

	clip.SampleAnimation(clip, animComp.gameObject, 0)
	self.SetStageControl(self, self.STAGE_CONTROL.End)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local camera = gCS.CameraDataMgr.MainCamera
		local transform = self.bindData.exitButtonControllerSlot
		local screenPos = camera:WorldToScreenPoint(transform.position)

		self:GetHudStore():SetExitButtonControllerPos(screenPos)
	end

	local isPlayerWin = self.enemyHealth.currentHp > self.playerHealth.currentHp
	self.bindData.winnerName = isPlayerWin and self.bindData.playerName or self.bindData.enemyName
	self.csGameInstance.GameStarted = false
	self.bindData.resultControl = isPlayerWin and 0 or 1

	self:ReportGameResult(isPlayerWin)

	if self.autoCloseAfterWin > 0 then
		self.StartCoroutine(self, function ()
			coroutine.wait(self.autoCloseAfterWin)
			self:ClosePanel()
		end)
	end
end

M.ReportGameResult = function(self, isPlayerWin)
	if self.CheckIsSpecialMainLineMode(self) then
		return
	end

	local gameEndRealtime = self.gameEndRealtime or Time.realtimeSinceStartup
	local gameTimeMs = math.floor((gameEndRealtime - self.gameStartRealtime) * 1000)
	local gameResult = {
		Character = self.selectionInfo.selections[1].cfg.Id,
		Win = isPlayerWin,
		GameTimeMs = gameTimeMs
	}

	gClientToGameDelegate:AskReportArcadeGameResultMUGEN(gameResult).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("[Fighter] 上报失败 err=", gCS.Error.GetNameById(err))
		end
	end
end

M.OnClickStartGameButton = function(self)
	if self.bindData.stageControl == self.STAGE_CONTROL.Start then
		return
	end

	if self.CheckIsSpecialMainLineMode(self) then
		self.selectionInfo = {
			["/\\x82\\xff\\xae\\xa9\\xfc\\x95\\xbf\\x84\\xd8\\xe1&\\xef\\x94$\\x9a\\xfa"] = 2,
			selectList = {},
			selections = {
				{
					["D\\xa0\\xa6\\xaa\\xae"] = 1,
					cfg = LTConfig.PoiGameFighterConfig.GetConfig(1)
				},
				{
					["D\\xa0\\xa6\\xaa\\xae"] = 2,
					cfg = LTConfig.PoiGameFighterConfig.GetConfig(2)
				}
			}
		}

		self.CreateUnits(self)
		self.StartGame(self)
	else
		self.ShowSelectionPage(self)
	end
end

M.ShowSelectionPage = function(self)
	if self.selectionInfo then
		coroutine.stop(self.selectionInfo.playerSpriteAnimCo)
		coroutine.stop(self.selectionInfo.enemySpriteAnimCo)

		local currentSelectIndex = self.selectionInfo.selections[1].index

		self:GetHudStore():SetItemNavigationEnable(currentSelectIndex, true)
	end

	self.SetStageControl(self, self.STAGE_CONTROL.Selection, true)

	local selectList = {}

	for i = 0, LTConfig.PoiGameFighterConfig.count - 1 do
		local cfg = LTConfig.PoiGameFighterConfig.LoadAt(i)

		if cfg.CanSelect then
			table.insert(selectList, cfg)
		end
	end

	local playerDefaultSelect = selectList[1]
	self.selectionInfo = {
		["/\\x82\\xff\\xae\\xa9\\xfc\\x95\\xbf\\x84\\xd8\\xe1&\\xef\\x94$\\x9a\\xfa"] = 1,
		selectList = {},
		selections = {
			{
				["D\\xa0\\xa6\\xaa\\xae"] = 1,
				cfg = playerDefaultSelect
			}
		},
		selectList = selectList
	}

	self.bindData.selectList:SetSimpleList(#selectList)
	self.GetHudStore():SetSelectionListNavProxy(#selectList)
	self:UpdateUnitBaseInfo(true, true)

	self.bindData.playerSelectionStatusCtrl = 0
	self.bindData.enemySelectionStatusCtrl = 1
end

M.GamepadSelect = function(self, csIndex)
	local success, btn = self.bindData.selectList:TryGetChildAt(csIndex, nil)

	if success then
		self.OnSelectListItemClick(self, btn, csIndex)
	end
end

M.StopSelectionAnim = function(self, selectionIndex, btn)
	if btn ~= nil then
		local selection = self.selectionInfo.selections[selectionIndex]

		if selection then
			local success = nil
			success, btn = self.bindData.selectList:TryGetChildAt(selection.index - 1, nil)
		end
	end

	if gClientUtils.NotNil(btn) then
		local store = self:GetStoreByWidget(btn)

		store.anim1p:SampleCurrentAnimation(0)
		store.anim1p:Stop()
		store.anim2p:SampleCurrentAnimation(0)
		store.anim2p:Stop()
	end
end

M.OnClickFinishPlayerSelectBtn = function(self)
	self:StopSelectionAnim(1)

	self.selectionInfo.currentSelectIndex = 2
	self.bindData.playerSelectionStatusCtrl = 2
	self.bindData.enemySelectionStatusCtrl = 0
	local currentSelectIndex = self.selectionInfo.selections[1].index

	self:GetHudStore():SetItemNavigationEnable(currentSelectIndex, false)

	local nextSelectIndex = currentSelectIndex % #self.selectionInfo.selectList + 1

	self:GetHudStore():SetSelectListSelectItem(nextSelectIndex)
end

M.UpdateUnitBaseInfo = function(self, updatePlayer, updateEnemy)
	if updatePlayer then
		self.selectionInfo.playerSpriteAnimCo = coroutine.stop(self.selectionInfo.playerSpriteAnimCo)
	end

	if updateEnemy then
		self.selectionInfo.enemySpriteAnimCo = coroutine.stop(self.selectionInfo.enemySpriteAnimCo)
	end

	local playerSelection = self.selectionInfo.selections[1]
	local playerSelectionCfg = (playerSelection or {}).cfg or {}
	self.bindData.playerName = playerSelectionCfg.Name or ""
	self.bindData.playerIcon = playerSelectionCfg.Avatar3D or 0

	if updatePlayer then
		self.bindData.playerPreviewImg.sprite = nil
		self.selectionInfo.playerSpriteAnimCo = self.PlayPreviewSpriteAnim(self, playerSelectionCfg.Id, self.bindData.playerPreviewImg)
	end

	local enemySelection = self.selectionInfo.selections[2]
	local enemySelectionCfg = (enemySelection or {}).cfg or {}
	self.bindData.enemyName = enemySelectionCfg.Name or ""
	self.bindData.enemyIcon = enemySelectionCfg.Avatar3D or 0

	if updateEnemy then
		self.bindData.enemyPreviewImg.sprite = nil
		self.selectionInfo.enemySpriteAnimCo = self.PlayPreviewSpriteAnim(self, enemySelectionCfg.Id, self.bindData.enemyPreviewImg)
	end
end

M.PlayPreviewSpriteAnim = function(self, id, img)
	if id ~= nil then
		return nil
	end

	local success, sprites, speed = self.csGameInstance:GetSpriteInfo(id, nil, )

	if not success then
		return nil
	end

	sprites = sprites.ToTable(sprites)
	img.sprite = sprites[1]

	return self.StartCoroutine(self, function ()
		local cnt = 1

		while true do
			img.sprite = sprites[cnt]

			coroutine.wait(speed)

			cnt = cnt % #sprites + 1
		end
	end)
end

M.OnClickFinishEnemySelectBtn = function(self)
	local enemySelection = self.selectionInfo.selections[2]

	if enemySelection ~= nil or enemySelection.cfg ~= nil then
		return
	end

	self.StopSelectionAnim(self, 2)
	self.CreateUnits(self)
	self.StartGame(self)
end

M.CreateUnits = function(self)
	local typeOfHealthComponent = typeof(Fighter.HealthComponent)
	local typeOfRageComponent = typeof(Fighter.RageComponent)
	local maxRage = LTConfig.PoiGameConfig.ArcadeFighterMaxRage
	local playerSelection = self.selectionInfo.selections[1]
	local playerCfg = playerSelection.cfg
	local player = self.csGameInstance:CreatePlayer(playerCfg.Id)
	self.playerHealth = player:GetComponent(typeOfHealthComponent)
	self.playerRage = player:GetComponent(typeOfRageComponent)
	local maxHp = self.playerHealth.maxHp
	self.bindData.playerHealthBar.maxHp = maxHp
	self.bindData.playerRageBar.maxHp = maxRage
	local enemySelection = self.selectionInfo.selections[2]
	local enemyCfg = enemySelection.cfg
	local enemy = self.csGameInstance:CreateEnemy(enemyCfg.Id)
	self.enemyHealth = enemy:GetComponent(typeOfHealthComponent)
	self.enemyRage = enemy:GetComponent(typeOfRageComponent)
	self.bindData.enemyHealthBar.maxHp = self.enemyHealth.maxHp
	self.bindData.enemyRageBar.maxHp = maxRage

	self:UpdateUnitBaseInfo(true, true)
end

M.StartGame = function(self)
	slot1 = self.csGameInstance

	slot1:TryTriggerGameStartSignal()
	self:SetStageControl(self.STAGE_CONTROL.RoundStart)
	self:StartCoroutine(function ()
		coroutine.wait(3)
		self:SetStageControl(self.STAGE_CONTROL.GamePlay)

		self.csGameInstance.GameStarted = true
		self.gameStartRealtime = Time.realtimeSinceStartup
		self.gameEndRealtime = nil

		self:StartCountDownCo()
	end)
end

M.Replay = function(self)
	if self.CheckIsSpecialMainLineMode(self) then
		return
	end

	if self.bindData.stageControl ~= self.STAGE_CONTROL.GamePlay then
		return
	end

	self:ClearCoroutine()

	self.csGameInstance.GameStarted = false

	self.csGameInstance:DestroyAllUnits()
	self:InitModel(self.instance.args)
	self:InitView(self.instance.args)
	self:ShowSelectionPage()
end

M.StartCoroutine = function(self, func)
	local co = coroutine.start(func)
	self.coroutines = self.coroutines or {}

	table.insert(self.coroutines, co)

	return co
end

M.ClearCoroutine = function(self)
	slot1 = ipairs
	slot3 = self.coroutines or {}

	for _, co in slot1(slot3) do
		coroutine.stop(co)
	end
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end

M.CheckIsSpecialMainLineMode = function(self)
	return self.forbidClickExit and self.autoCloseAfterWin < 0
end

M.OnSelectListRenderItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local data = self.selectionInfo.selectList[index]
	local store = self.GetStoreByWidget(self, btn)
	store.icon = data.Avatar3D

	if self.selectionInfo.selections[1] and index ~= self.selectionInfo.selections[1].index then
		btn.SetSelected(btn, true)

		store.playerCtrl = 1
	elseif self.selectionInfo.selections[2] and index ~= self.selectionInfo.selections[2].index then
		btn.SetSelected(btn, true)

		store.playerCtrl = 2
	else
		btn.SetSelected(btn, false)

		store.playerCtrl = 0
	end
end

M.OnSelectListItemClick = function(self, btn, csIndex)
	local index = csIndex + 1

	for i = 1, 2 do
		if self.selectionInfo.selections[i] and index ~= self.selectionInfo.selections[i].index then
			return
		end
	end

	local currentSelection = self.selectionInfo.selections[self.selectionInfo.currentSelectIndex]
	local lastSelectIndex = currentSelection and currentSelection.index

	if lastSelectIndex then
		local success, prevBtn = self.bindData.selectList:TryGetChildAt(lastSelectIndex - 1, nil)

		if success then
			prevBtn.SetSelected(prevBtn, false)

			local prevBtnStore = self.GetStoreByWidget(self, prevBtn)
			prevBtnStore.playerCtrl = 0

			self.StopSelectionAnim(self, nil, prevBtn)
		end
	end

	self.selectionInfo.selections[self.selectionInfo.currentSelectIndex] = {
		index = index,
		cfg = self.selectionInfo.selectList[index]
	}

	btn.SetSelected(btn, true)

	local store = self.GetStoreByWidget(self, btn)
	store.playerCtrl = self.selectionInfo.currentSelectIndex

	if self.selectionInfo.currentSelectIndex ~= 1 then
		store.anim1p:Play()
	elseif self.selectionInfo.currentSelectIndex ~= 2 then
		store.anim2p:Play()
	end

	if self.selectionInfo.currentSelectIndex ~= 1 then
		self.UpdateUnitBaseInfo(self, true, false)
	else
		self.UpdateUnitBaseInfo(self, false, true)
	end
end

M.GetHudStore = function(self)
	return gStoreManager:GetStoreGroup("FighterHudPanelStore")
end

M.CleanupGame = function(self)
	self.ClearCoroutine(self)

	if self.instance then
		if self.instance.playerSpAnimCo then
			coroutine.stop(self.instance.playerSpAnimCo)
		end

		if self.instance.enemySpAnimCo then
			coroutine.stop(self.instance.enemySpAnimCo)
		end
	end

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	if self.showResultTimer then
		self.showResultTimer:Stop()

		self.showResultTimer = nil
	end

	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)
	self.playerHealth = nil
	self.enemyHealth = nil
	self.playerRage = nil
	self.enemyRage = nil
	self.selectionInfo = nil
	self.fighterGo = gClientUtils.NotNil(self.fighterGo) and UnityEngine.GameObject.Destroy(self.fighterGo)
	self.csGameInstance = nil
	self.pivotTransform = nil
	self.useDynamicPivot = nil
	self.instance = nil
	self.hasDestroy = true
end

M.OnClose = function(self)
	self.SetHardwareCursorHidden(self, false)
end

M.OnDestroy = function(self)
	self:SetHardwareCursorHidden(false)
	self:CleanupGame()
	gPanelManager:Close(gPanelId.FIGHTER_HUD_PANEL)
	self:ClearMessageEvents()
end
