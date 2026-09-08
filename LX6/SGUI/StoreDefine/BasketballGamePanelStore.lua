-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BasketballGamePanelStore.lua
-- Decompiled from: 01656_BasketballGamePanelStore.lua_5104d3f68e6b.luajit

C_BasketballGamePanelStore = DefClass("C_BasketballGamePanelStore", C_BasketballGamePanelStore, C_StoreGroup)
GroupName2Class.BasketballGamePanelStore = C_BasketballGamePanelStore
local M = C_BasketballGamePanelStore
local basketballShootType = gBasketballCharacter.SHOOT_TYPE
local QteStatusCtrl = {
	["\\xba523a\\xb2S\\xf56\\xbe\\xbc"] = 0,
	["2G\\x85\\xac\\x82E"] = 1,
	["T-s^"] = 3,
	["\\xe9\\xde'\\xe5"] = 2
}
local ShowScoreDescriptions = {
	[basketballShootType.ZERO_A] = 89900936,
	[basketballShootType.ZERO_B] = 89900935,
	[basketballShootType.ZERO_C] = 89900937,
	[basketballShootType.TWO_A] = 89900936,
	[basketballShootType.TWO_B] = 89900935,
	[basketballShootType.THREE] = 89900938
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.shootButton.luaPress = self.CreateAction(self, self.OnShootKeyDown)
	self.bindData.shootButton.luaRelease = self.CreateAction(self, self.OnShootKeyUp)

	self.InitMessageEvents(self)
end

M.InitMessageEvents = function(self)
	local msgEvents = {
		[gEventConstants.BASKETBALL_GAME_REFRESH_PLAYER_VIEW] = self.CreateAction(self, self.RefreshPlayerView),
		[gEventConstants.BASKETBALL_GAME_REFRESH_NPC_VIEW] = self.CreateAction(self, self.RefreshNpcView),
		[gEventConstants.BASKETBALL_GAME_PLAYER_OVER] = self.CreateAction(self, self.OnPlayerGameOver),
		[gEventConstants.COMMON_MESSAGE_BOX_ESC_CLOSE] = self.CreateAction(self, self.OnMessageBoxClose),
		[gEventConstants.BASKETBALL_GAME_PLAYER_MAKE_PREFECT_SHOOT] = self.CreateAction(self, self.PlayDualSensePrefectShoot)
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.qteStatusCoroutine = coroutine.stop(self.qteStatusCoroutine)
end

M.OnShow = function(self, _, _)
	self.InitCommonHUD(self)
	self.InitModel(self)
	self.InitView(self)
end

M.InitCommonHUD = function(self)
	self.gameplayHudPanelStore = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	self.gameplayHudPanelStore:SetBtnSwitchViewState(false)
end

M.InitModel = function(self)
	self.isShootKeyDown = false
	self.qteProgressOffset = Vector3.Unpack(LTConfig.PoiGameConfig.Basket_Qte_Progress_Offset)
end

M.InitView = function(self)
	self.bindData.playerCountdown = gTimeUtils:FormatTime(LTConfig.PoiGameConfig.Basket_Time, true)
	self.bindData.npcCountdown = gTimeUtils:FormatTime(LTConfig.PoiGameConfig.Basket_Time, true)
	self.bindData.playerScore = 0
	self.bindData.npcScore = 0
	local npcId = gBasketballGameManager.currentGame.npcId
	local npcCfg = LTConfig.AgentConfig.GetConfig(npcId)
	local npcName = npcCfg.Name
	self.bindData.playerName = LTConfig.TextScriptTextConfig.GetConfig(89901050).Text
	self.bindData.npcName = npcName
	self.bindData.isShowQteProgress = false

	self:ResetBubbleView()
	self:RefreshPerfectPercentView()
end

M.OnShootKeyDown = function(self)
	if not self.isShootKeyDown then
		self.isShootKeyDown = true

		self.TryShoot(self)
	end
end

M.OnShootKeyUp = function(self)
	self.bindData.longPressAnimation.gameObject:SetActive(true)

	self.isShootKeyDown = false
	local qteStatus = gBasketballGameManager.currentGame:ExecuteShootKeyUp()

	self:SetQteStatus(qteStatus)
end

M.SetQtePosition = function(self)
	local player = gBasketballGameManager.currentGame.playerCharacter
	local baseUnit = player.baseUnit
	local mainCamera = gCS.CameraDataMgr.MainCamera
	local screenPosition = mainCamera:WorldToScreenPoint(baseUnit.ModelSlot.handr.position)
	local uiPosition = gUtils:ScreenToUIPosition(screenPosition)
	self.bindData.qteRectTransform.localPosition = uiPosition + self.qteProgressOffset
end

M.OnUpdate = function(self)
	local currentGame = gBasketballGameManager.currentGame

	if currentGame then
		local playerHasShootFlag = gBasketballGameManager.currentGame.playerCharacter.hasShootFlag

		if self.isShootKeyDown and not playerHasShootFlag and not self.bindData.isShowQteProgress then
			self.TryShoot(self)
		end

		if self.isShootKeyDown then
			local qteProgress, qteStatus = gBasketballGameManager.currentGame:ExecuteShootKeyLongPress()
			self.bindData.qteProgress = qteProgress or 0

			self:SetQteStatus(qteStatus)
		end
	end
end

M.TryShoot = function(self)
	self.bindData.longPressAnimation.gameObject:SetActive(false)

	local canShoot = gBasketballGameManager.currentGame:ExecuteShootKeyDown()
	self.bindData.isShowQteProgress = canShoot ~= true

	self:SetQtePosition()
	self:RefreshPerfectPercentView()

	self.bindData.qteProgress = 0
end

M.RefreshPlayerView = function(self, _, args)
	self.bindData.playerScore = args.totalScore
	self.bindData.playerCountdown = gTimeUtils:FormatTime(args.countdown, true)
	local shootType = args.shootType

	if shootType then
		local hasGetScore = gBasketballGameUtils.CheckMakeAShootByType(shootType)
		local ballType = args.basketballType

		self:ResetBubbleView()

		local isShowPlusTime = hasGetScore and args.isValidTime and ballType ~= gBasketball.BASKETBALL_TYPE.TIME
		local addBonus = args.addBonus and args.addBonus or 1
		local isShowPlusScore = hasGetScore and addBonus >= 1

		self.bindData.plusTimeNode.gameObject:SetActive(isShowPlusTime)
		self.bindData.plusScoreNode.gameObject:SetActive(isShowPlusScore)

		self.bindData.plusScore = addBonus
		local isClutchShot = args.isClutchShot
		local isBuzzerBeat = args.isBuzzerBeat
		local finalScore = args.currentScore
		self.bindData.score = finalScore ~= 0 and finalScore or ("%d"):format(finalScore)

		if isClutchShot or isBuzzerBeat then
			self.bindData.specialPointNode.gameObject:SetActive(true)
		else
			local isThreePoint = gBasketballGameUtils.CheckThreePointShoot(shootType)
			local isTwoPoint = gBasketballGameUtils.CheckTwoPointShoot(shootType)
			local isZeroPoint = gBasketballGameUtils.CheckZeroPointShoot(shootType)

			self.bindData.threePointNode.gameObject:SetActive(isThreePoint)
			self.bindData.twoPointNode.gameObject:SetActive(isTwoPoint)
			self.bindData.zeroPointNode.gameObject:SetActive(isZeroPoint)
		end

		self.bindData.scoreDescription = self.GetScoreDescriptionText(self, args)

		self.PlayDualSenseByShootType(self, shootType)
	end
end

M.ResetBubbleView = function(self)
	self.bindData.plusScoreNode.gameObject:SetActive(false)
	self.bindData.plusTimeNode.gameObject:SetActive(false)
	self.bindData.threePointNode.gameObject:SetActive(false)
	self.bindData.twoPointNode.gameObject:SetActive(false)
	self.bindData.zeroPointNode.gameObject:SetActive(false)
	self.bindData.specialPointNode.gameObject:SetActive(false)
end

M.RefreshNpcView = function(self, _, args)
	self.bindData.npcScore = args.totalScore
	self.bindData.npcCountdown = gTimeUtils:FormatTime(args.countdown, true)
end

M.OnPlayerGameOver = function(self)
	if not self.qteStatusCoroutine then
		self.bindData.isShowQteProgress = false
	end
end

M.OnMessageBoxClose = function(self, _, args)
	local mid = args and args.mid

	if mid ~= LTConfig.MessageConfig.ChallengeGiveUp then
		gBasketballGameManager:ResumeGame()
	end
end

M.RefreshPerfectPercentView = function(self)
	local player = gBasketballGameManager.currentGame.playerCharacter
	local perfectPercent = player.perfectPercent
	local tempRangePercent = player.earlyRangePercent
	tempRangePercent = tempRangePercent + player.soSoRangePercent
	tempRangePercent = tempRangePercent + player.goodRangePercent
	self.bindData.perfectPercent = 1 - tempRangePercent / perfectPercent
end

M.SetQteStatus = function(self, qteStatus)
	if qteStatus then
		self.bindData.qteFillActive = false
		self.bindData.qteStatusCtrl = self.GetQteStatusCtrlValue(self, qteStatus)
		self.qteStatusCoroutine = coroutine.start(function ()
			coroutine.wait(0.5)

			self.bindData.qteFillActive = true
			self.bindData.qteStatusCtrl = QteStatusCtrl.None
			self.bindData.isShowQteProgress = false
		end)
	end
end

M.GetQteStatusCtrlValue = function(self, qteStatus)
	if qteStatus ~= gBasketballPlayerCharacter.QTE_STATUS.PERFECT then
		return QteStatusCtrl.Perfect
	elseif qteStatus ~= gBasketballPlayerCharacter.QTE_STATUS.NOT_BAD then
		return QteStatusCtrl.NotBad
	elseif qteStatus ~= gBasketballPlayerCharacter.QTE_STATUS.EARLY_OR_LATE then
		return QteStatusCtrl.EarlyOrLate
	end
end

M.GetScoreDescriptionText = function(self, args)
	local textId = args.isClutchShot and 89900940 or args.isBuzzerBeat and 89900939 or ShowScoreDescriptions[args.shootType]

	return LTConfig.TextScriptTextConfig.GetConfig(textId).Text
end

M.PlayDualSenseByShootType = function(self, shootType)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if shootType ~= basketballShootType.THREE then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
	elseif shootType ~= basketballShootType.TWO_A or shootType ~= basketballShootType.TWO_B then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
	end
end

M.PlayDualSensePrefectShoot = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
end
