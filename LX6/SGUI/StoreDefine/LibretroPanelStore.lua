-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LibretroPanelStore.lua
-- Decompiled from: 01780_LibretroPanelStore.lua_9fe8e40150c9.luajit

C_LibretroPanelStore = DefClass("C_LibretroPanelStore", C_LibretroPanelStore, C_StoreGroup)
GroupName2Class.LibretroPanelStore = C_LibretroPanelStore
local M = C_LibretroPanelStore
local MessageConfig = LTConfig.MessageConfig
local COIN_MODE = {
	["/A\\x9f\\x89\\x8fD"] = 1,
	["`\\xbb\\xae\\xbb\\xbf"] = 0
}
local CLEAR_STAGE = {
	[0] = 4,
	nil,
	8,
	7,
	8
}
local COIN_CAP = {
	[0] = 9,
	nil,
	99,
	99,
	9
}
local PC_KEY_BUTTON_NAME = {
	P7pK = 430,
	["X-pY"] = 886,
	["zN˰\\xb7\r\\xb4\\xca\\xfc"] = 922,
	["#\\xf7K-\t\\xdb?\\xb9O\\xa7_\\xa2\\xbb"] = 965,
	["\\xf0\\xcf+7\\xf4"] = 966,
	["\\~\\xa3xX\\x91\\xfdIlslA"] = 967
}

M.OnAwake = function(self)
	self.moveVector2 = Vector2.New(0, 0)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.hResponse.luaGamePadInputChanged = self.CreateAction(self, "OnHResponse")
	self.bindData.jResponse.luaGamePadInputChanged = self.CreateAction(self, "OnJResponse")
	self.bindData.kResponse.luaGamePadInputChanged = self.CreateAction(self, "OnKResponse")
	self.bindData.lResponse.luaGamePadInputChanged = self.CreateAction(self, "OnLResponse")
	self.bindData.insertResponse.luaGamePadInputChanged = self.CreateAction(self, "OnInsertResponse")
	self.bindData.startResponse.luaGamePadInputChanged = self.CreateAction(self, "OnStartResponse")
	self.bindData.moveWRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMoveWResponse")
	self.bindData.moveARespond.luaGamePadInputChanged = self.CreateAction(self, "OnMoveAResponse")
	self.bindData.moveSRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMoveSResponse")
	self.bindData.moveDRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMoveDResponse")
	self.bindData.moveJoyStick.luaValueChanged = self.CreateAction(self, "OnMoveJoyStickValueChanged")
	self.bindData.InsertBtn.luaPress = self.CreateActionWithArgs(self, "OnSelectButton", true)
	self.bindData.InsertBtn.luaRelease = self.CreateActionWithArgs(self, "OnSelectButton", false)
	self.bindData.startBtn.luaPress = self.CreateActionWithArgs(self, "OnStartButton", true)
	self.bindData.startBtn.luaRelease = self.CreateActionWithArgs(self, "OnStartButton", false)
	self.bindData.hBtn.luaPress = self.CreateActionWithArgs(self, "OnHButton", true)
	self.bindData.hBtn.luaRelease = self.CreateActionWithArgs(self, "OnHButton", false)
	self.bindData.jBtn.luaPress = self.CreateActionWithArgs(self, "OnJButton", true)
	self.bindData.jBtn.luaRelease = self.CreateActionWithArgs(self, "OnJButton", false)
	self.bindData.kBtn.luaPress = self.CreateActionWithArgs(self, "OnKButton", true)
	self.bindData.kBtn.luaRelease = self.CreateActionWithArgs(self, "OnKButton", false)
	self.bindData.lBtn.luaPress = self.CreateActionWithArgs(self, "OnLButton", true)
	self.bindData.lBtn.luaRelease = self.CreateActionWithArgs(self, "OnLButton", false)
	self.bindData.eBtn.luaPress = self.CreateActionWithArgs(self, "OnEButton", true)
	self.bindData.eBtn.luaRelease = self.CreateActionWithArgs(self, "OnEButton", false)
	self.bindData.fBtn.luaPress = self.CreateActionWithArgs(self, "OnFButton", true)
	self.bindData.fBtn.luaRelease = self.CreateActionWithArgs(self, "OnFButton", false)
	self.bindData.moveWBtn.luaPress = self.CreateActionWithArgs(self, "OnWButton", true)
	self.bindData.moveWBtn.luaRelease = self.CreateActionWithArgs(self, "OnWButton", false)
	self.bindData.moveABtn.luaPress = self.CreateActionWithArgs(self, "OnAButton", true)
	self.bindData.moveABtn.luaRelease = self.CreateActionWithArgs(self, "OnAButton", false)
	self.bindData.moveSBtn.luaPress = self.CreateActionWithArgs(self, "OnSButton", true)
	self.bindData.moveSBtn.luaRelease = self.CreateActionWithArgs(self, "OnSButton", false)
	self.bindData.moveDBtn.luaPress = self.CreateActionWithArgs(self, "OnDButton", true)
	self.bindData.moveDBtn.luaRelease = self.CreateActionWithArgs(self, "OnDButton", false)
	self.bindData.leftStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftStickInput")
	self.bindData.ArcadeMachine.OnStageChanged = self.CreateAction(self, "OnStageChanged")
end

M.UpdateMoveVector = function(self)
	self.moveVector2.x = 0

	if self.activeHorizontalKey ~= "A" then
		self.moveVector2.x = -1
	elseif self.activeHorizontalKey ~= "D" then
		self.moveVector2.x = 1
	end

	self.moveVector2.y = 0

	if self.activeVerticalKey ~= "W" then
		self.moveVector2.y = 1
	elseif self.activeVerticalKey ~= "S" then
		self.moveVector2.y = -1
	end

	self.OnExecuteMove(self)
end

M.OnMoveAResponse = function(self, context)
	self.OnAButton(self, context.performed)
end

M.OnAButton = function(self, pressed)
	if pressed then
		self.activeHorizontalKey = "A"

		self.UpdateMoveVector(self)
	elseif self.activeHorizontalKey ~= "A" then
		self.activeHorizontalKey = nil

		self.UpdateMoveVector(self)
	end
end

M.OnMoveDResponse = function(self, context)
	self.OnDButton(self, context.performed)
end

M.OnDButton = function(self, pressed)
	if pressed then
		self.activeHorizontalKey = "D"

		self.UpdateMoveVector(self)
	elseif self.activeHorizontalKey ~= "D" then
		self.activeHorizontalKey = nil

		self.UpdateMoveVector(self)
	end
end

M.OnMoveWResponse = function(self, context)
	self.OnWButton(self, context.performed)
end

M.OnWButton = function(self, pressed)
	if pressed then
		self.activeVerticalKey = "W"

		self.UpdateMoveVector(self)
	elseif self.activeVerticalKey ~= "W" then
		self.activeVerticalKey = nil

		self.UpdateMoveVector(self)
	end
end

M.OnMoveSResponse = function(self, context)
	self.OnSButton(self, context.performed)
end

M.OnSButton = function(self, pressed)
	if pressed then
		self.activeVerticalKey = "S"

		self.UpdateMoveVector(self)
	elseif self.activeVerticalKey ~= "S" then
		self.activeVerticalKey = nil

		self.UpdateMoveVector(self)
	end
end

M.OnExecuteMove = function(self)
	self.bindData.unityInputProcessorComponent0:OnJoypadDirections(self.moveVector2)
end

M.OnMoveJoyStickValueChanged = function(self, x, y, _)
	if not self.moveVector2 then
		return
	end

	self.moveVector2.x = x
	self.moveVector2.y = y

	self.OnExecuteMove(self)
end

M.OnLeftStickInput = function(self, context)
	if context.canceled then
		self.moveVector2.x = 0
		self.moveVector2.y = 0
	else
		local vec2 = context.ReadValueVector2(context)
		self.moveVector2.x = vec2.x
		self.moveVector2.y = vec2.y
	end

	self.OnExecuteMove(self)
end

M.OnHResponse = function(self, context)
	self.OnHButton(self, context.performed)
end

M.OnHButton = function(self, pressed)
	self.bindData.unityInputProcessorComponent0:OnJoypadXButton(pressed)
end

M.OnJResponse = function(self, context)
	self.OnJButton(self, context.performed)
end

M.OnJButton = function(self, pressed)
	self.bindData.unityInputProcessorComponent0:OnJoypadBButton(pressed)
end

M.OnKResponse = function(self, context)
	self.OnKButton(self, context.performed)
end

M.OnKButton = function(self, pressed)
	self.bindData.unityInputProcessorComponent0:OnJoypadAButton(pressed)
end

M.OnLResponse = function(self, context)
	self.OnLButton(self, context.performed)
end

M.OnLButton = function(self, pressed)
	self.bindData.unityInputProcessorComponent0:OnJoypadYButton(pressed)
end

M.OnEButton = function(self, pressed)
	if self.currentGameType == self.gameType.OrientalLegend and self.currentGameType == self.gameType.KnightsOfValourSuperHeroes then
		return
	end

	self.OnJButton(self, pressed)
	self.OnKButton(self, pressed)
end

M.OnFButton = function(self, pressed)
	if self.currentGameType == self.gameType.OrientalLegend and self.currentGameType == self.gameType.KnightsOfValourSuperHeroes then
		return
	end

	self.OnJButton(self, pressed)
	self.OnKButton(self, pressed)
	self.OnLButton(self, pressed)
end

M.OnInsertResponse = function(self, context)
	self.OnSelectButton(self, context.performed)
end

M.OnSelectButton = function(self, pressed)
	if pressed and self.coinLocked then
		return
	end

	self.bindData.unityInputProcessorComponent0:OnJoypadSelectButton(pressed)

	if pressed then
		self.bindData.pageCtrl = 0
	end
end

M.OnStartResponse = function(self, context)
	self.OnStartButton(self, context.performed)
end

M.OnStartButton = function(self, pressed)
	self.bindData.unityInputProcessorComponent0:OnJoypadStartButton(pressed)

	if pressed then
		self.bindData.pageCtrl = 1
		self.started = true
	end
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self)
end

M.InitModel = function(self, args)
	self.activeHorizontalKey = nil
	self.activeVerticalKey = nil
	self.gameType = {
		["\\xea\\x8aMIK-\\xf8"] = 4,
		["\\xeb\\xda*\\xa3"] = 0,
		["Ȉ\\xe9\\xe7ƍ\\xea\\x87.,"] = 2,
		["(\\xe8\\x8e\"\\xdaN\r\\x86\\x84(O\\xa8M\\x8eq0\\xbd+\\xe3\\x95*\\xdd"] = 3
	}
	self.gameCtrlIndex = {
		[0] = 0,
		nil,
		2,
		3,
		1
	}
	self.moveVector2 = Vector2.New(0, 0)
	self.currentGameType = args and args.gameType or self.gameType.Raiden2
	self.coinMode = args and args.mode or COIN_MODE.Multi
	self.sessionMaxScore = 0
	self.sessionMaxStage = 0
	self.coinInsertCount = 0
	self.coinConsumedCount = 0
	self.lastCredits = nil
	self.coinLocked = false
	self.cleared = false
	self.gameTimeMs = 0
	self.started = false
	self.reported = false

	self.bindData.ArcadeMachine:SetGameType(self.currentGameType)
end

M.SetDebugHudEnabled = function(self, enabled)
	local dbgNode = self.rootGo and self.rootGo.transform:Find("DebugUI")

	if dbgNode then
		dbgNode.gameObject:SetActive(enabled)

		self.dbgHud = enabled and dbgNode:GetComponent(typeof(SGUI.USDFText)) or nil

		if self.dbgHud then
			self.dbgHud.text = ""
		end
	end
end

M.RefreshPCKeyButtonNames = function(self)
	local isShooter = self.currentGameType ~= self.gameType.Raiden2 or self.currentGameType ~= self.gameType.S1945ii

	if isShooter then
		self.bindData.jBtn:SetPCKeyInfoTipNameId(PC_KEY_BUTTON_NAME.ShootConfirm)
		self.bindData.kBtn:SetPCKeyInfoTipNameId(PC_KEY_BUTTON_NAME.Bomb)

		return
	end

	self.bindData.jBtn:SetPCKeyInfoTipNameId(PC_KEY_BUTTON_NAME.AttackConfirm)
	self.bindData.kBtn:SetPCKeyInfoTipNameId(PC_KEY_BUTTON_NAME.Jump)
	self.bindData.lBtn:SetPCKeyInfoTipNameId(PC_KEY_BUTTON_NAME.ItemSelect)
	self.bindData.hBtn:SetPCKeyInfoTipNameId(PC_KEY_BUTTON_NAME.ItemUse)
end

M.InitView = function(self)
	self.bindData.unityInputProcessorManager:AddPlayer(0, self.bindData.player0.gameObject)

	self.bindData.pageCtrl = 2
	self.bindData.gameCtrl = self.gameCtrlIndex[self.currentGameType] or 0

	self.bindData.InsertBtn:SetActive(true)
	self:RefreshPCKeyButtonNames()
	self:SetDebugHudEnabled(gGmUtils.arcadeDebugHudEnabled ~= true)
end

M.OnExitClick = function(self)
	self:ReportResult()
	gPanelManager:Close(self.m_Id)
end

M.OnStageChanged = function(self)
	local am = self.bindData.ArcadeMachine
	local s = am.GetStage(am)
	self.sessionMaxStage = math.max(self.sessionMaxStage, s)
	self.sessionMaxScore = math.max(self.sessionMaxScore, am.GetScore(am))

	if not self.cleared and self.started then
		local target = CLEAR_STAGE[self.currentGameType]

		if target and target < s then
			self.cleared = true
		end
	end

	if self.cleared then
		if self.currentGameType ~= self.gameType.Raiden2 and s ~= 4 then
			gPanelManager:CheckShow(gPanelId.S_RAIDEN_FINAL_PANEL)
		end

		self:ReportResult()
		gPanelManager:Close(self.m_Id)
	end
end

M.OnUpdate = function(self)
	local am = self.bindData.ArcadeMachine

	if not am then
		return
	end

	local cur = am.GetCredits(am)

	if self.lastCredits == nil then
		if self.lastCredits >= cur then
			self.coinInsertCount = self.coinInsertCount + cur - self.lastCredits
		elseif self.started and cur >= self.lastCredits then
			self.coinConsumedCount = self.coinConsumedCount + 1
		end
	end

	self.lastCredits = cur

	if self.coinMode ~= COIN_MODE.Single then
		if not self.coinLocked and self.coinInsertCount > 1 then
			self.coinLocked = true

			self.bindData.InsertBtn:SetActive(false)
		end
	else
		self.coinLocked = cur < (COIN_CAP[self.currentGameType] or 9)
	end

	self.sessionMaxScore = math.max(self.sessionMaxScore, am.GetScore(am))
	self.sessionMaxStage = math.max(self.sessionMaxStage, am.GetStage(am))
	local fcStr = uint64.tostring(am.GetFrameCount(am))
	local rate = am.GetFrameRate(am)

	if rate and rate <= 0 then
		self.gameTimeMs = math.floor((tonumber(fcStr) or 0) / rate * 1000)
	end

	if self.dbgHud then
		self.dbgHud.text = string.format("关卡:%d  分数:%d  投币:%d\n帧数:%s  帧率:%.2f\n模式:%s  投币计数:%d  消耗:%d  锁:%s  通关:%s  用时:%dms", am:GetStage(), am:GetScore(), am:GetCredits(), fcStr, rate, self.coinMode ~= COIN_MODE.Single and "单币" or "多币", self.coinInsertCount, self.coinConsumedCount, tostring(self.coinLocked), tostring(self.cleared), self.gameTimeMs)
	end
end

M.BuildGameResult = function(self)
	return {
		Id = self.currentGameType + 1,
		Score = self.sessionMaxScore,
		Stage = self.sessionMaxStage,
		Cleared = self.cleared,
		OneCoinMode = self.coinMode ~= COIN_MODE.Single,
		CoinCount = self.coinConsumedCount,
		GameTimeMs = self.gameTimeMs
	}
end

M.ReportResult = function(self)
	if self.reported then
		return
	end

	self.reported = true

	if not self.started then
		print_notice("[Arcade] 未开局(未按Start), 跳过上报")

		return
	end

	local r = self:BuildGameResult()
	slot2 = gClientToGameDelegate

	slot2:AskReportArcadeGameResult(r).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("[Arcade] 上报失败 err=", gCS.Error.GetNameById(err))
		end
	end
end

M.OnDestroy = function(self)
	self:ReportResult()
	self:ClearMessageEvents()
	self.bindData.unityInputProcessorManager:RemovePlayer(0)
end
