-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NiRenFighterMainPanelStore.lua
-- Decompiled from: 00931_NiRenFighterMainPanelStore.lua_9b262f8e487d.luajit

C_NiRenFighterMainPanelStore = DefClass("C_NiRenFighterMainPanelStore", C_NiRenFighterMainPanelStore, C_StoreGroup)
GroupName2Class.NiRenFighterMainPanelStore = C_NiRenFighterMainPanelStore
local M = C_NiRenFighterMainPanelStore
local Fighter = L18.MiniGame.Fighter

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.platformCtrlEnum = {
		["G\\x93\\x87\\x8fD"] = 0,
		["\\xda\\xd4(\\xf4"] = 2,
		["@Nϳ\\x80\t\\xb4\\xc7\\xed"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.platformCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterSingleEvent(self, gEventConstants.CLOSE_FIGHTER_MINI_GAME, self.CreateAction(self, self.ClosePanel))

	self.hasDestroy = nil
end

M.OnShow = function(self, _, args)
	if type(args) ~= "userdata" then
		args = args.ToTable(args)
	end

	self.hasDestroy = nil

	self:SetPlayerMoveBanned(true)
	self:InitModel(args)
	self:LoadGame()
	self:UpdatePlatformCtrl()

	self.registerOperationId = gStoreButtonMgr:RegisterOperation({
		["\\xca\\xcf\t\r\\xf5"] = 5,
		["O\\xba\\xac\\x86\\xb2"] = 0,
		["\\xbb\\xa3\\xa4x7\\xea*"] = 1,
		groupId = LTConfig.HudDescGroupConfig.HACKERCAMERA
	})
end

M.UpdatePlatformCtrl = function(self)
	if gCS.LuaUtils.IsOnPS5 then
		self.bindData.platformCtrl = self.platformCtrlEnum.console
	elseif gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.platformCtrl = self.platformCtrlEnum.standalone
	else
		self.bindData.platformCtrl = self.platformCtrlEnum.mobile
	end
end

M.OnClose = function(self)
	self.SetPlayerMoveBanned(self, false)
	self.CleanupGame(self)

	if self.registerOperationId then
		gStoreButtonMgr:UnRegisterOperation(self.registerOperationId)

		self.registerOperationId = nil
	end
end

M.SetPlayerMoveBanned = function(self, banned)
	if banned then
		LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gBanId.NIREN_FIGHTER)
	else
		LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gBanId.NIREN_FIGHTER)
	end

	LX6.GUI.GuiMgr.Instance:SetDisableJoystick(banned, gBanId.NIREN_FIGHTER)
end

M.OnDestroy = function(self)
	self.CleanupGame(self)
	self.ClearMessageEvents(self)

	if self.registerOperationId then
		gStoreButtonMgr:UnRegisterOperation(self.registerOperationId)

		self.registerOperationId = nil
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
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
end

M.InitModel = function(self, args)
	self.instance = {
		args = args
	}
	self.prefabPath = "Res/MiniGame/Other/ArcadeFight/NiRenFighterMiniGame.prefab"
	self.forbidClickExit = args.forbidClickExit
	self.playerCharacterId = args.playerCharacterId or 1
	self.enemyCharacterId = args.enemyCharacterId or 2
	self.pivotTransform = args.pivot or {
		position = args.position,
		rotation = args.rotation,
		localScale = args.localScale
	}
	self.moveVector2 = Vector2.New(0, 0)
	self.hasShownResult = false
end

M.LoadGame = function(self)
	Fighter.FighterMinigameAdapter.Init()

	local onLoadComplete = function(loadOp)
		if self.hasDestroy then
			return
		end

		self.fighterGo = GameObject.Instantiate(loadOp.asset)
		self.fighterGo.name = "MiniGame_NiRen"
		self.csGameInstance = Fighter.FighterMinigame.Instance

		self:DisableRenderTextureCamera()
		self:HideAllBackground()
		self:CreateVisualRoot()
		self:ApplyPivotTransform()
		self:CreateUnits()
		self:StartGame()
	end

	self.loadOp = gResourceManager:LoadAssetWithCallBack(self.prefabPath, typeof(GameObject), onLoadComplete)
end

M.CreateVisualRoot = function(self)
	if gClientUtils.IsNil(self.csGameInstance) then
		return
	end

	self.visualRoot = GameObject("MiniGame_NiRen_VisualRoot")
	self.effectRoot = GameObject("MiniGame_NiRen_EffectRoot")

	self.effectRoot.transform:SetParent(self.visualRoot.transform, false)
	self.csGameInstance:SetVisualRoot(self.visualRoot.transform, self.effectRoot.transform)
end

M.DisableRenderTextureCamera = function(self)
	if gClientUtils.IsNil(self.csGameInstance) or gClientUtils.IsNil(self.csGameInstance.GameCamera) then
		return
	end

	self.csGameInstance.GameCamera.gameObject:SetActive(false)
end

M.HideAllBackground = function(self)
	if gClientUtils.IsNil(self.csGameInstance) or gClientUtils.IsNil(self.csGameInstance.BackgroundRoot) then
		return
	end

	local bg = self.csGameInstance.BackgroundRoot

	for i = 1, bg.childCount do
		bg:GetChild(i - 1).gameObject:SetActive(false)
	end
end

M.ApplyPivotTransform = function(self)
	if self.pivotTransform ~= nil then
		return
	end

	if gClientUtils.NotNil(self.fighterGo) then
		local rootTr = self.fighterGo.transform

		if self.pivotTransform.position then
			rootTr.position = self.pivotTransform.position
		end

		rootTr.rotation = Quaternion.identity
		rootTr.localScale = Vector3.one
	end

	if gClientUtils.NotNil(self.visualRoot) then
		local vt = self.visualRoot.transform

		if self.pivotTransform.position then
			vt.position = self.pivotTransform.position
		end

		if self.pivotTransform.rotation then
			vt.rotation = self.pivotTransform.rotation
		end

		vt.localScale = Vector3.one
	end

	self.UpdateInputSign(self)
end

M.UpdateInputSign = function(self)
	local sign = 1

	if gClientUtils.NotNil(self.csGameInstance) then
		sign = self.csGameInstance:GetMoveInputSign()
	end

	if sign == self.inputSignX then
		self.inputSignX = sign

		self.UpdateMoveInput(self)
	end
end

M.CreateUnits = function(self)
	local typeOfHealthComponent = typeof(Fighter.HealthComponent)
	local player = self.csGameInstance:CreatePlayer(self.playerCharacterId)
	self.playerHealth = player and player:GetComponent(typeOfHealthComponent) or nil

	self:SetIgnoreRageCost(player)
	self:ApplyNiRenParts(player)

	local enemy = self.csGameInstance:CreateEnemy(self.enemyCharacterId)
	self.enemyHealth = enemy and enemy:GetComponent(typeOfHealthComponent) or nil
end

M.SetIgnoreRageCost = function(self, unit)
	if gClientUtils.IsNil(unit) then
		return
	end

	local rage = unit.GetComponent(unit, typeof(Fighter.RageComponent))

	if gClientUtils.NotNil(rage) then
		rage.IgnoreRageCost = true
	end
end

M.ApplyNiRenParts = function(self, unit)
	if gClientUtils.IsNil(unit) then
		return
	end

	local facing = unit.GetComponentInChildren(unit, typeof(Fighter.Fighter3DFacing))

	if gClientUtils.IsNil(facing) then
		return
	end

	local result = gMiniGameDataManager:GetNiRenGameResult()
	local parts = result and result.parts

	if parts ~= nil then
		return
	end

	local bodyType = result.winnerBodyType or 0

	facing:ApplyParts(bodyType, parts[0], parts[1], parts[2], parts[3])
end

M.StartGame = function(self)
	self.csGameInstance:TryTriggerGameStartSignal()

	self.csGameInstance.GameStarted = true
end

M.OnUpdate = function(self)
	self.PivotUpdate(self)
	self.CheckFightEnd(self)
end

M.PivotUpdate = function(self)
	self.ApplyPivotTransform(self)
end

M.CheckFightEnd = function(self)
	if self.hasShownResult or not self.playerHealth or not self.enemyHealth then
		return
	end

	if self.playerHealth.currentHp ~= 0 or self.enemyHealth.currentHp ~= 0 then
		self:OnFightFinished(self.enemyHealth.currentHp ~= 0)
	end
end

M.OnFightFinished = function(self, playerWin)
	if self.hasShownResult then
		return
	end

	self.hasShownResult = true

	if gClientUtils.NotNil(self.csGameInstance) then
		self.csGameInstance.GameStarted = false
	end

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.ON_NIREN_FIGHTER_END, {
		playerWin = playerWin
	})
	self:ClosePanel()
end

M.OnSwitchLeftButtonPressState = function(self, isPress)
	self.isLeftButtonPress = isPress

	self.UpdateMoveInput(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.leftButton:SetSelected(isPress)
	end
end

M.OnSwitchRightButtonPressState = function(self, isPress)
	self.isRightButtonPress = isPress

	self.UpdateMoveInput(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.rightButton:SetSelected(isPress)
	end
end

M.UpdateMoveInput = function(self)
	local x = 0

	if self.isLeftButtonPress and not self.isRightButtonPress then
		x = -1
	elseif self.isRightButtonPress and not self.isLeftButtonPress then
		x = 1
	end

	self.moveVector2.x = x * (self.inputSignX or 1)

	self:WriteInputVector()
end

M.OnSwitchJumpButtonPressState = function(self, isPress)
	local mgr = self.GetInputManager(self)

	if mgr then
		mgr.IsJumpKeyDown = isPress
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.jumpButton:SetSelected(isPress)
	end
end

M.OnSwitchDefendButtonPressState = function(self, isPress)
	local mgr = self.GetInputManager(self)

	if mgr then
		mgr.IsDefendKeyDown = isPress
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.defendButton:SetSelected(isPress)
	end
end

M.OnSwitchKickButtonPressState = function(self, isPress)
	local mgr = self.GetInputManager(self)

	if mgr then
		mgr.IsKickKeyDown = isPress
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.kickButton:SetSelected(isPress)
	end
end

M.OnSwitchPunchButtonPressState = function(self, isPress)
	local mgr = self.GetInputManager(self)

	if mgr then
		mgr.IsPunchKeyDown = isPress
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.punchButton:SetSelected(isPress)
	end
end

M.OnSwitchSuperAttackButtonPressState = function(self, isPress)
	local mgr = self.GetInputManager(self)

	if mgr then
		mgr.IsUltimateKeyDown = isPress
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.superAttack:SetSelected(isPress)
	end
end

M.GetInputManager = function(self)
	if gClientUtils.IsNil(self.csGameInstance) then
		return nil
	end

	return self.csGameInstance.InputManager
end

M.WriteInputVector = function(self)
	local mgr = self.GetInputManager(self)

	if mgr then
		mgr.InputVector = self.moveVector2
	end
end

M.ClosePanel = function(self)
	gMiniGameDataManager:StopNiRenFighter()
end

M.CleanupGame = function(self)
	if self.loadOp then
		self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)
	end

	self.playerHealth = nil
	self.enemyHealth = nil

	if gClientUtils.NotNil(self.visualRoot) then
		UnityEngine.GameObject.Destroy(self.visualRoot)
	end

	self.visualRoot = nil
	self.effectRoot = nil

	if gClientUtils.NotNil(self.fighterGo) then
		UnityEngine.GameObject.Destroy(self.fighterGo)
	end

	self.fighterGo = nil
	self.csGameInstance = nil
	self.instance = nil
	self.moveVector2 = nil
	self.hasDestroy = true
end
