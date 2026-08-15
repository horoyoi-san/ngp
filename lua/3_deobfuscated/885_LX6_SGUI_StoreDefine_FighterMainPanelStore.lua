C_FighterMainPanelStore = DefClass("C_FighterMainPanelStore", C_FighterMainPanelStore, C_StoreGroup)
GroupName2Class.FighterMainPanelStore = C_FighterMainPanelStore
local M = C_FighterMainPanelStore
local Fighter = L18.MiniGame.Fighter

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.startGameButton.luaClick = self:CreateAction(self.OnClickStartGameButton)
	self.bindData.replayButton.luaClick = self:CreateAction(self.Replay)
	self.bindData.finishPlayerSelectBtn.luaClick = self:CreateAction(self.OnClickFinishPlayerSelectBtn)
	self.bindData.finishEnemySelectBtn.luaClick = self:CreateAction(self.OnClickFinishEnemySelectBtn)
	self.bindData.selectList.luaSimpleRenderItem = self:CreateAction(self.OnSelectListRenderItem)
	self.bindData.selectList.luaSimpleClick = self:CreateAction(self.OnSelectListItemClick)
	self.hasDestroy = nil
end

function M:OnShow(_, args)
	if type(args) == "userdata" then
		args = args:ToTable()
	end

	self:InitModel(args)
	self:InitView(args)
	self:LoadGame()
end

function M:InitModel(args)
	self.instance = {
		args = args,
		countdownTime = LTConfig.PoiGameConfig.ArcadeFighterCountdownTime
	}
	self.STAGE_CONTROL = {
		GamePlay = 2,
		End = 3,
		Selection = 4,
		RoundStart = 1,
		Start = 0
	}
	self.prefabPath = "Res/MiniGame/Other/ArcadeFight/FighterMiniGame.prefab"
	self.warnTime = LTConfig.PoiGameConfig.ArcadeFighterWarnTime
	self.forbidClickExit = args.forbidClickExit
	self.autoCloseAfterWin = args.autoCloseAfterWin
	self.ignoreCountdown = args.ignoreCountdown
end

function M:InitView(args)
	self:SetStageControl(self.STAGE_CONTROL.Start)

	self.rootGo.transform.position = args.position
	self.rootGo.transform.rotation = args.rotation
	self.rootGo.transform.localScale = args.localScale
	self.bindData.countdown = self.instance.countdownTime

	if self.bindData.countdownWidget then
		self.bindData.countdownWidget.gameObject:SetActive(not args.ignoreCountdown)
	end
end

function M:LoadGame()
	local function onLoadComplete(loadOp)
		if self.hasDestroy then
			return
		end

		self.fighterGo = GameObject.Instantiate(loadOp.asset)
		self.fighterGo.name = "MiniGame"
		self.fighterGo.transform.position = Vector3.zero
		self.csGameInstance = Fighter.FighterMinigame.Instance
	end

	self.loadOp = gResourceManager:LoadAssetWithCallBack(self.prefabPath, typeof(GameObject), onLoadComplete)

	gPanelManager:CheckShow(gPanelId.FIGHTER_HUD_PANEL, {
		forbidClickExit = self.forbidClickExit,
		autoCloseAfterWin = self.autoCloseAfterWin,
		startGameCallback = self:CreateAction("OnClickStartGameButton"),
		mainStore = self
	})
end

function M:TriggerUltimateAttackQte()
	if self.instance.hasUltimateAttack or LTConfig.PoiGameConfig.ArcadeFighterEnemyHpTriggerSuperAttack < self.enemyHealth.currentHp then
		return
	end

	self.instance.hasUltimateAttack = true
	local waitPauseGameCo = nil

	if self.csGameInstance:CanPlayerTriggerUltimateAttack() then
		self.csGameInstance:PauseGame(true)
	else
		waitPauseGameCo = self:StartCoroutine(function ()
			while self.csGameInstance and gClientUtils.NotNil(self.csGameInstance.GameRoot) do
				if self.csGameInstance:CanPlayerTriggerUltimateAttack() then
					self.csGameInstance:PauseGame(true)

					return
				end

				coroutine.step()
			end
		end)
	end

	self:GetHudStore():SpecialMainLine_SwitchUltimateButtonState(2)
	self:GetHudStore():SetUltimateKeyDownCallbackOnce(function ()
		self:GetHudStore():SpecialMainLine_SwitchUltimateButtonState(0)
		coroutine.stop(waitPauseGameCo)
		self.csGameInstance:PauseGame(false)
		gPanelManager:Close(gPanelId.FIGHTER_HUD_PANEL)
		self.csGameInstance:TriggerUltimateAttackForce()

		local enemyHealth = self.enemyHealth
		local timer = Timer.New(function ()
			if gClientUtils.NotNil(enemyHealth) then
				enemyHealth.currentHp = 0
			end
		end, 4)

		timer:Start()
	end)
end

function M:OnUpdate()
	local currentStage = self.bindData.stageControl

	if currentStage == self.STAGE_CONTROL.RoundStart or currentStage == self.STAGE_CONTROL.GamePlay then
		self:OnUpdate_InGameStage()
	elseif currentStage == self.STAGE_CONTROL.End then
		self:OnUpdate_EndStage()
	end
end

function M:OnUpdate_InGameStage()
	if gClientUtils.NotNil(self.playerRage) and gClientUtils.NotNil(self.enemyRage) then
		self.bindData.playerRageBar.hp = self.playerRage.CurrentRage
		self.bindData.enemyRageBar.hp = self.enemyRage.CurrentRage
	end

	if gClientUtils.IsNil(self.playerHealth) or gClientUtils.IsNil(self.enemyHealth) then
		return
	end

	self.bindData.playerHealthBar.hp = self.playerHealth.currentHp
	self.bindData.enemyHealthBar.hp = self.enemyHealth.currentHp
	local currentStage = self.bindData.stageControl

	if currentStage == self.STAGE_CONTROL.GamePlay and not self.ignoreCountdown then
		self.instance.countdownTime = self.instance.countdownTime - Time.deltaTime
		self.bindData.countdown = self.instance.countdownTime >= 0 and math.ceil(self.instance.countdownTime) or 0

		if self.instance.countdownTime <= self.warnTime then
			self.bindData.timeControl = 1
		end

		if self.instance.countdownTime < 0 then
			self:ShowResult()
		end
	end

	if self.instance.gameSettled then
		return
	end

	if self.playerHealth.currentHp == 0 or self.enemyHealth.currentHp == 0 then
		self.instance.gameSettled = true

		self:ShowResultWithDelay()
	end

	if currentStage == self.STAGE_CONTROL.GamePlay and self:CheckIsSpecialMainLineMode() then
		self:TriggerUltimateAttackQte()
	end
end

function M:OnUpdate_EndStage()
	return
end

function M:SetStageControl(stage, instant)
	if instant then
		self.rootWidget:TryChangePage("Stage", stage, true)
	else
		self.bindData.stageControl = stage
	end

	gMessageManager:SendMessage(gEventConstants.ON_MINI_GAME_FIGHTER_STAGE_CHANGE, stage)
end

function M:StartCountDownCo()
	self:StartCoroutine(function ()
		while self.instance.countdownTime > 0 do
			coroutine.wait(1)
		end

		self:ShowResult()
	end)
end

function M:ShowResultWithDelay()
	local timer = Timer.New(function ()
		if gClientUtils.NotNil((self.csGameInstance or {}).GameRoot) and self.STATE_EnableOnce then
			self:ShowResult()
		end
	end, 3)

	timer:Start()
end

function M:ShowResult()
	self:SetStageControl(self.STAGE_CONTROL.End)

	local animComp = self.rootWidget.rectTransform:Find("EndWidget"):GetComponent(typeof(UnityEngine.Animation))
	animComp.enabled = true
	local clip = animComp:GetClip("S_Vx_FighterMainPanel_end")

	clip:SampleAnimation(animComp.gameObject, 1000)

	animComp.enabled = false

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local camera = gCS.CameraDataMgr.MainCamera
		local transform = self.bindData.exitButtonControllerSlot
		local screenPos = camera:WorldToScreenPoint(transform.position)

		self:GetHudStore():SetExitButtonControllerPos(screenPos)
	end

	local isPlayerWin = self.enemyHealth.currentHp <= self.playerHealth.currentHp
	self.bindData.winnerName = isPlayerWin and self.bindData.playerName or self.bindData.enemyName
	self.csGameInstance.GameStarted = false
	self.bindData.resultControl = isPlayerWin and 0 or 1

	if self.autoCloseAfterWin >= 0 then
		self:StartCoroutine(function ()
			coroutine.wait(self.autoCloseAfterWin)
			self:ClosePanel()
		end)
	end
end

function M:OnClickStartGameButton()
	if self.bindData.stageControl ~= self.STAGE_CONTROL.Start then
		return
	end

	if self:CheckIsSpecialMainLineMode() then
		self.selectionInfo = {
			currentSelectIndex = 2,
			selectList = {},
			selections = {
				{
					index = 1,
					cfg = LTConfig.PoiGameFighterConfig.GetConfig(1)
				},
				{
					index = 2,
					cfg = LTConfig.PoiGameFighterConfig.GetConfig(2)
				}
			}
		}

		self:CreateUnits()
		self:StartGame()
	else
		self:ShowSelectionPage()
	end
end

function M:ShowSelectionPage()
	if self.selectionInfo then
		coroutine.stop(self.selectionInfo.playerSpriteAnimCo)
		coroutine.stop(self.selectionInfo.enemySpriteAnimCo)
	end

	self:SetStageControl(self.STAGE_CONTROL.Selection, true)

	local selectList = {}

	for i = 0, LTConfig.PoiGameFighterConfig.count - 1 do
		local cfg = LTConfig.PoiGameFighterConfig.LoadAt(i)

		if cfg.CanSelect then
			table.insert(selectList, cfg)
		end
	end

	local playerDefaultSelect = selectList[1]
	self.selectionInfo = {
		currentSelectIndex = 1,
		selectList = {},
		selections = {
			{
				index = 1,
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

function M:GamepadSelect(csIndex)
	local success, btn = self.bindData.selectList:TryGetChildAt(csIndex, nil)

	if success then
		self:OnSelectListItemClick(btn, csIndex)
	end
end

function M:OnClickFinishPlayerSelectBtn()
	self.selectionInfo.currentSelectIndex = 2
	self.bindData.playerSelectionStatusCtrl = 2
	self.bindData.enemySelectionStatusCtrl = 0
	local currentSelectIndex = self.selectionInfo.selections[1].index
	local nextSelectIndex = currentSelectIndex % #self.selectionInfo.selectList + 1

	self:GetHudStore():SetSelectListSelectItem(nextSelectIndex)
end

function M:UpdateUnitBaseInfo(updatePlayer, updateEnemy)
	if updatePlayer then
		self.selectionInfo.playerSpriteAnimCo = coroutine.stop(self.selectionInfo.playerSpriteAnimCo)
	end

	if updateEnemy then
		self.selectionInfo.enemySpriteAnimCo = coroutine.stop(self.selectionInfo.enemySpriteAnimCo)
	end

	local playerSelection = self.selectionInfo.selections[1]
	local playerSelectionCfg = (playerSelection or {}).cfg or {}
	self.bindData.playerName = playerSelectionCfg.Name or ""
	self.bindData.playerIcon = playerSelectionCfg.Avatar or 0

	if updatePlayer then
		self.bindData.playerPreviewImg.sprite = nil
		self.selectionInfo.playerSpriteAnimCo = self:PlayPreviewSpriteAnim(playerSelectionCfg.Id, self.bindData.playerPreviewImg)
	end

	local enemySelection = self.selectionInfo.selections[2]
	local enemySelectionCfg = (enemySelection or {}).cfg or {}
	self.bindData.enemyName = enemySelectionCfg.Name or ""
	self.bindData.enemyIcon = enemySelectionCfg.Avatar or 0

	if updateEnemy then
		self.bindData.enemyPreviewImg.sprite = nil
		self.selectionInfo.enemySpriteAnimCo = self:PlayPreviewSpriteAnim(enemySelectionCfg.Id, self.bindData.enemyPreviewImg)
	end
end

function M:PlayPreviewSpriteAnim(id, img)
	if id == nil then
		return nil
	end

	local success, sprites, speed = self.csGameInstance:GetSpriteInfo(id, nil, nil)

	if not success then
		return nil
	end

	sprites = sprites:ToTable()
	img.sprite = sprites[1]

	return self:StartCoroutine(function ()
		local cnt = 1

		while true do
			img.sprite = sprites[cnt]

			coroutine.wait(speed)

			cnt = cnt % #sprites + 1
		end
	end)
end

function M:OnClickFinishEnemySelectBtn()
	local enemySelection = self.selectionInfo.selections[2]

	if enemySelection == nil or enemySelection.cfg == nil then
		return
	end

	self:CreateUnits()
	self:StartGame()
end

function M:CreateUnits()
	local typeOfHealthComponent = typeof(Fighter.HealthComponent)
	local typeOfRageComponent = typeof(Fighter.RageComponent)
	local maxRage = LTConfig.PoiGameConfig.ArcadeFighterMaxRage
	local playerSelection = self.selectionInfo.selections[1]
	local playerCfg = playerSelection.cfg
	local player = self.csGameInstance:CreatePlayer(playerCfg.Id)
	self.playerHealth = player:GetComponent(typeOfHealthComponent)
	self.playerRage = player:GetComponent(typeOfRageComponent)
	self.playerStateMachine = player:GetComponent(typeof(Fighter.StateMachine))
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

function M:StartGame()
	self:SetStageControl(self.STAGE_CONTROL.RoundStart)

	self.instance.gameSettled = false

	self:StartCoroutine(function ()
		coroutine.wait(3)
		self:SetStageControl(self.STAGE_CONTROL.GamePlay)

		self.csGameInstance.GameStarted = true

		self:StartCountDownCo()
	end)
end

function M:Replay()
	if self:CheckIsSpecialMainLineMode() then
		return
	end

	if self.bindData.stageControl == self.STAGE_CONTROL.GamePlay then
		return
	end

	self:ClearCoroutine()

	self.csGameInstance.GameStarted = false

	self.csGameInstance:DestroyAllUnits()
	self:InitModel(self.instance.args)
	self:InitView(self.instance.args)
	self:ShowSelectionPage()
end

function M:StartCoroutine(func)
	local co = coroutine.start(func)
	self.coroutines = self.coroutines or {}

	table.insert(self.coroutines, co)

	return co
end

function M:ClearCoroutine()
	for _, co in ipairs(self.coroutines or {}) do
		coroutine.stop(co)
	end
end

function M:ClosePanel()
	gPanelManager:Close(self.m_Id)
end

function M:CheckIsSpecialMainLineMode()
	return self.forbidClickExit and self.autoCloseAfterWin >= 0
end

function M:OnSelectListRenderItem(btn, csIndex)
	local index = csIndex + 1
	local data = self.selectionInfo.selectList[index]
	local store = self:GetStoreByWidget(btn)
	store.icon = data.Avatar

	if self.selectionInfo.selections[1] and index == self.selectionInfo.selections[1].index then
		btn:SetSelected(true)

		store.playerCtrl = 1
	elseif self.selectionInfo.selections[2] and index == self.selectionInfo.selections[2].index then
		btn:SetSelected(true)

		store.playerCtrl = 2
	else
		btn:SetSelected(false)

		store.playerCtrl = 0
	end
end

function M:OnSelectListItemClick(btn, csIndex)
	local index = csIndex + 1

	for i = 1, 2 do
		if self.selectionInfo.selections[i] and index == self.selectionInfo.selections[i].index then
			return
		end
	end

	local currentSelection = self.selectionInfo.selections[self.selectionInfo.currentSelectIndex]
	local lastSelectIndex = currentSelection and currentSelection.index

	if lastSelectIndex then
		local success, prevBtn = self.bindData.selectList:TryGetChildAt(lastSelectIndex - 1, nil)

		if success then
			prevBtn:SetSelected(false)

			local prevBtnStore = self:GetStoreByWidget(prevBtn)
			prevBtnStore.playerCtrl = 0
		end
	end

	self.selectionInfo.selections[self.selectionInfo.currentSelectIndex] = {
		index = index,
		cfg = self.selectionInfo.selectList[index]
	}

	btn:SetSelected(true)

	local store = self:GetStoreByWidget(btn)
	store.playerCtrl = self.selectionInfo.currentSelectIndex

	if self.selectionInfo.currentSelectIndex == 1 then
		self:UpdateUnitBaseInfo(true, false)
	else
		self:UpdateUnitBaseInfo(false, true)
	end
end

function M:GetHudStore()
	return gStoreManager:GetStoreGroup("FighterHudPanelStore")
end

function M:CleanupGame()
	self:ClearCoroutine()

	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)
	self.playerHealth = nil
	self.enemyHealth = nil
	self.playerRage = nil
	self.enemyRage = nil
	self.selectionInfo = nil
	self.fighterGo = gClientUtils.NotNil(self.fighterGo) and UnityEngine.GameObject.Destroy(self.fighterGo)
	self.csGameInstance = nil
	self.instance = nil
	self.hasDestroy = true
end

function M:OnDestroy()
	self:CleanupGame()
	gPanelManager:Close(gPanelId.FIGHTER_HUD_PANEL)
end
