C_BasketballGamePanelStore = DefClass("C_BasketballGamePanelStore", C_BasketballGamePanelStore, C_StoreGroup)
GroupName2Class.BasketballGamePanelStore = C_BasketballGamePanelStore
local M = C_BasketballGamePanelStore
local basketballShootType = gBasketballCharacter.SHOOT_TYPE
local QteStatusCtrl = {
	EarlyOrLate = 0,
	NotBad = 1,
	None = 3,
	Perfect = 2
}
local ShowScoreDescriptions = {
	[basketballShootType.ZERO_A] = 89900936,
	[basketballShootType.ZERO_B] = 89900935,
	[basketballShootType.ZERO_C] = 89900937,
	[basketballShootType.TWO_A] = 89900936,
	[basketballShootType.TWO_B] = 89900935,
	[basketballShootType.THREE] = 89900938
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.shootButton.luaPress = self:CreateAction(self.OnShootKeyDown)
	self.bindData.shootButton.luaRelease = self:CreateAction(self.OnShootKeyUp)

	self:InitMessageEvents()
end

function M:InitMessageEvents()
	local msgEvents = {
		[gEventConstants.BASKETBALL_GAME_REFRESH_PLAYER_VIEW] = self:CreateAction(self.RefreshPlayerView),
		[gEventConstants.BASKETBALL_GAME_REFRESH_NPC_VIEW] = self:CreateAction(self.RefreshNpcView),
		[gEventConstants.BASKETBALL_GAME_PLAYER_OVER] = self:CreateAction(self.OnPlayerGameOver),
		[gEventConstants.COMMON_MESSAGE_BOX_ESC_CLOSE] = self:CreateAction(self.OnMessageBoxClose),
		[gEventConstants.BASKETBALL_GAME_PLAYER_MAKE_PREFECT_SHOOT] = self:CreateAction(self.PlayDualSensePrefectShoot)
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnDestroy()
	self:ClearMessageEvents()

	self.qteStatusCoroutine = coroutine.stop(self.qteStatusCoroutine)
end

function M:OnShow(_, _)
	self:InitCommonHUD()
	self:InitModel()
	self:InitView()
end

function M:InitCommonHUD()
	self.gameplayHudPanelStore = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	self.gameplayHudPanelStore:SetBtnSwitchViewState(false)
end

function M:InitModel()
	self.isShootKeyDown = false
	self.qteProgressOffset = Vector3.Unpack(LTConfig.PoiGameConfig.Basket_Qte_Progress_Offset)
end

function M:InitView()
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

function M:OnShootKeyDown()
	if not self.isShootKeyDown then
		self.isShootKeyDown = true

		self:TryShoot()
	end
end

function M:OnShootKeyUp()
	self.bindData.longPressAnimation.gameObject:SetActive(true)

	self.isShootKeyDown = false
	local qteStatus = gBasketballGameManager.currentGame:ExecuteShootKeyUp()

	self:SetQteStatus(qteStatus)
end

function M:SetQtePosition()
	local player = gBasketballGameManager.currentGame.playerCharacter
	local baseUnit = player.baseUnit
	local mainCamera = gCS.CameraDataMgr.MainCamera
	local screenPosition = mainCamera:WorldToScreenPoint(baseUnit.ModelSlot.handr.position)
	local uiPosition = gUtils:ScreenToUIPosition(screenPosition)
	self.bindData.qteRectTransform.localPosition = uiPosition + self.qteProgressOffset
end

function M:OnUpdate()
	local currentGame = gBasketballGameManager.currentGame

	if currentGame then
		local playerHasShootFlag = gBasketballGameManager.currentGame.playerCharacter.hasShootFlag

		if self.isShootKeyDown and not playerHasShootFlag and not self.bindData.isShowQteProgress then
			self:TryShoot()
		end

		if self.isShootKeyDown then
			local qteProgress, qteStatus = gBasketballGameManager.currentGame:ExecuteShootKeyLongPress()
			self.bindData.qteProgress = qteProgress or 0

			self:SetQteStatus(qteStatus)
		end
	end
end

function M:TryShoot()
	self.bindData.longPressAnimation.gameObject:SetActive(false)

	local canShoot = gBasketballGameManager.currentGame:ExecuteShootKeyDown()
	self.bindData.isShowQteProgress = canShoot == true

	self:SetQtePosition()
	self:RefreshPerfectPercentView()

	self.bindData.qteProgress = 0
end

function M:RefreshPlayerView(_, args)
	self.bindData.playerScore = args.totalScore
	self.bindData.playerCountdown = gTimeUtils:FormatTime(args.countdown, true)
	local shootType = args.shootType

	if shootType then
		local hasGetScore = gBasketballGameUtils.CheckMakeAShootByType(shootType)
		local ballType = args.basketballType

		self:ResetBubbleView()

		local isShowPlusTime = hasGetScore and args.isValidTime and ballType == gBasketball.BASKETBALL_TYPE.TIME
		local addBonus = args.addBonus and args.addBonus or 1
		local isShowPlusScore = hasGetScore and addBonus > 1

		self.bindData.plusTimeNode.gameObject:SetActive(isShowPlusTime)
		self.bindData.plusScoreNode.gameObject:SetActive(isShowPlusScore)

		self.bindData.plusScore = addBonus
		local isClutchShot = args.isClutchShot
		local isBuzzerBeat = args.isBuzzerBeat
		local finalScore = args.currentScore
		self.bindData.score = finalScore == 0 and finalScore or ("%d"):format(finalScore)

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

		self.bindData.scoreDescription = self:GetScoreDescriptionText(args)

		self:PlayDualSenseByShootType(shootType)
	end
end

function M:ResetBubbleView()
	self.bindData.plusScoreNode.gameObject:SetActive(false)
	self.bindData.plusTimeNode.gameObject:SetActive(false)
	self.bindData.threePointNode.gameObject:SetActive(false)
	self.bindData.twoPointNode.gameObject:SetActive(false)
	self.bindData.zeroPointNode.gameObject:SetActive(false)
	self.bindData.specialPointNode.gameObject:SetActive(false)
end

function M:RefreshNpcView(_, args)
	self.bindData.npcScore = args.totalScore
	self.bindData.npcCountdown = gTimeUtils:FormatTime(args.countdown, true)
end

function M:OnPlayerGameOver()
	if not self.qteStatusCoroutine then
		self.bindData.isShowQteProgress = false
	end
end

function M:OnMessageBoxClose(_, args)
	local mid = args and args.mid

	if mid == LTConfig.MessageConfig.ChallengeGiveUp then
		gBasketballGameManager:ResumeGame()
	end
end

function M:RefreshPerfectPercentView()
	local player = gBasketballGameManager.currentGame.playerCharacter
	local perfectPercent = player.perfectPercent
	local tempRangePercent = player.earlyRangePercent
	tempRangePercent = tempRangePercent + player.soSoRangePercent
	tempRangePercent = tempRangePercent + player.goodRangePercent
	self.bindData.perfectPercent = 1 - tempRangePercent / perfectPercent
end

function M:SetQteStatus(qteStatus)
	if qteStatus then
		self.bindData.qteFillActive = false
		self.bindData.qteStatusCtrl = self:GetQteStatusCtrlValue(qteStatus)
		self.qteStatusCoroutine = coroutine.start(function ()
			coroutine.wait(0.5)

			self.bindData.qteFillActive = true
			self.bindData.qteStatusCtrl = QteStatusCtrl.None
			self.bindData.isShowQteProgress = false
		end)
	end
end

function M:GetQteStatusCtrlValue(qteStatus)
	if qteStatus == gBasketballPlayerCharacter.QTE_STATUS.PERFECT then
		return QteStatusCtrl.Perfect
	elseif qteStatus == gBasketballPlayerCharacter.QTE_STATUS.NOT_BAD then
		return QteStatusCtrl.NotBad
	elseif qteStatus == gBasketballPlayerCharacter.QTE_STATUS.EARLY_OR_LATE then
		return QteStatusCtrl.EarlyOrLate
	end
end

function M:GetScoreDescriptionText(args)
	local textId = args.isClutchShot and 89900940 or args.isBuzzerBeat and 89900939 or ShowScoreDescriptions[args.shootType]

	return LTConfig.TextScriptTextConfig.GetConfig(textId).Text
end

function M:PlayDualSenseByShootType(shootType)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if shootType == basketballShootType.THREE then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
	elseif shootType == basketballShootType.TWO_A or shootType == basketballShootType.TWO_B then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
	end
end

function M:PlayDualSensePrefectShoot()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
end
