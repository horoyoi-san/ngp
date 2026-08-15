local DivinerCardEventConfig = LTConfig.DivinerCardEventConfig
local DivinerDivinationCardConfig = LTConfig.DivinerDivinationCardConfig
local DivinerCustomerNeedConfig = LTConfig.DivinerCustomerNeedConfig
local DivinerCardSpreadConfig = LTConfig.DivinerCardSpreadConfig
local DivinerCustomerTypeConfig = LTConfig.DivinerCustomerTypeConfig
local DivinerCustomerMoodConfig = LTConfig.DivinerCustomerMoodConfig
local DivinerConfig = LTConfig.DivinerConfig
local DivinerDivinationRewardConfig = LTConfig.DivinerDivinationRewardConfig
local DivinerCameraConfig = LTConfig.DivinerCameraConfig
C_DivinationPanelStore = DefClass("C_DivinationPanelStore", C_DivinationPanelStore, C_StoreGroup)
GroupName2Class.DivinationPanelStore = C_DivinationPanelStore
local M = C_DivinationPanelStore
local GameplayEvent = MuGenStates.Logic.GameplayEvent
local GameplayEventParam1 = MuGenStates.Logic.GameplayEventParam1
local MyPlayerManager = gCS.MyPlayerManager

function M:ctor()
	return
end

function M:OnAwake()
	self.DEBUG = false
	self.CONTROL_TYPE = {
		FALSE = 0,
		TRUE = 1
	}
	self.STAGE = {
		DIALOG = 1,
		OPTIONS = 0
	}
	self.CAMERA_TYPE = {
		FREE_LOOK = 0,
		FIX_CAMERA = 1
	}
	self.bindData.handCardList.luaRenderItem = self:CreateAction("OnPersuadeOptionRender")
	self.bindData.handCardList.luaClick = self:CreateAction("OnPersuadeOptionClick")
	self.bindData.btnBack.luaClick = self:CreateAction("OnBtnBack")
	self.bindData.switchCameraBtn.luaClick = self:CreateAction("OnSwitchCameraBtnClick")
	self.ScrollWheel = self:CreateAction("OnMouseScrollWheel")
	self.scaleMax = 1
	self.zoomFactor = 15
end

function M:OnEnable()
	self:BindListener()
end

function M:OnStart()
	return
end

function M:OnDisable()
	self:UnbindListener()
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.isShow = true
	self.closeCallback = data.closeCallback

	self:InitPersuade(data.persuadeId)

	self.currentFixCameraIndex = 0
	self.currentFixCameraDataIndex = 0

	self:SwitchToFreeLook()
end

function M:OnClose()
	if not self.success then
		gDivinerManager:SyncPersuadeLevelToServer(0)
	end

	if self.closeCallback then
		self.closeCallback({
			success = self.success
		})

		self.closeCallback = nil
	end

	self.isShow = false

	self:SwitchToNormalFreeLook()
	gDivinerManager:EndPersuade()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:ShufflePlayerCards()
	self:Shuffle(self.playerCards)

	self.playerCardIndex = 0
end

function M:ShufflePlayerAuras()
	self:Shuffle(self.playerAuras)

	self.playerAuraIndex = 0
end

function M:Shuffle(array)
	math.randomseed(os.time())

	for i = #array, 1, -1 do
		local randIdx = math.random(i)
		array[randIdx] = array[i]
		array[i] = array[randIdx]
	end

	return array
end

function M:InitGame()
	math.randomseed(os.time())
	self:InitPlayer()
	self:InitNpc()
	self:InitCardSpread()
	self:ShufflePlayerCards()
	self:ShufflePlayerAuras()

	self.handCards = self.handCards or {}

	self:DiscardCards()

	self.bindData.handCardNum = #self.handCards
	self.gameEffectDict = {}

	for i = 1, self.GAME_EFFECT_TYPE.COUNT do
		self.gameEffectDict[i] = {}
	end

	self:SetRoundValue(0)
	self:SetTurnValue(0)

	self.auraIndex = 0
	self.putAuraIndex = 0

	self:SetPatienceValue(self:CalInitPatience())
	self:SetShieldValue(self:CalInitShield())
	self:SetTrustLevel(1)
	self:SetTrustValue(self:CalInitTrust())
	self:SetStage(self.GAME_STAGE.NONE)

	self.bindData.StageCtrl = self.STAGE.WAIT
	self.bindData.ShowSolicitCtrl = self.CONTROL_TYPE.TRUE

	self:InitDialogAndAnimWaitState()
	self:InitPlayerAction()
	self:HideAllCardIns()
	self:InitPopup()
end

function M:InitPlayer()
	self:InitPlayerLevel()
	self:InitPlayerCards()
end

function M:InitPlayerLevel()
	self.playerLevel = nil
	local idx = math.random(DivinerConfig.count)
	local divinerCfg = DivinerConfig.LoadAt(idx - 1)
	self.playerLevel = divinerCfg

	if not divinerCfg then
		print_error("占卜师级别初始化失败")
	end
end

function M:InitPlayerCards()
	self.playerCards = {}
	self.playerAuras = {}

	for i = 0, DivinerDivinationCardConfig.count - 1 do
		local cardCfg = DivinerDivinationCardConfig.LoadAt(i)

		if cardCfg then
			if cardCfg.CardType == DivinerDivinationCardConfig.CardTypeType.Interpretation then
				for j = 1, cardCfg.Num do
					table.insert(self.playerCards, cardCfg)
				end
			elseif cardCfg.CardType == DivinerDivinationCardConfig.CardTypeType.Tarot then
				for j = 1, cardCfg.Num do
					table.insert(self.playerAuras, cardCfg)
				end
			end
		end
	end
end

function M:InitNpc()
	self:InitNpcData()
	self:InitNpcCard()
end

function M:InitNpcData()
	self.npcType = nil
	self.npcMood = nil
	self.npcNeed = nil
	self.needDialogIndex = 0

	if self.playerLevel then
		local customerPool = self.playerLevel.CustomerPool
		local idx = math.random(#customerPool)
		local typeCfg = DivinerCustomerTypeConfig.GetConfig(customerPool[idx])
		self.npcType = typeCfg

		if self.npcType then
			local moodPool = self.npcType.MoodPool
			idx = math.random(#moodPool)
			local moodCfg = DivinerCustomerMoodConfig.GetConfig(moodPool[idx])
			self.npcMood = moodCfg

			if not moodCfg then
				print_error("DivinerCustomerMoodConfig is nil, cfgId=", moodPool[idx])
			end

			local needPool = self.npcType.NeedPool
			idx = math.random(#needPool)
			local needCfg = DivinerCustomerNeedConfig.GetConfig(needPool[idx])
			self.npcNeed = needCfg

			if self.npcNeed then
				self.needDialogIndex = self.npcNeed.DialogIndex
			else
				print_error("DivinerCustomerNeedConfig is nil, cfgId=", needPool[idx])
			end
		else
			print_error("DivinerCustomerTypeConfig is nil, cfgId=", customerPool[idx])
		end
	end

	self.bindData.npcHeadIcon = self.npcType and self.npcType.HeadIcon or 0

	self:AskCreateNpc()
end

function M:AskCreateNpc()
	return
end

function M:InitNpcCard()
	self.npcCard = nil

	if self.npcType then
		self.npcCard = DivinerDivinationCardConfig.GetConfig(self.npcType.CustomerSkill)
	end

	self:RefreshNpcDebugInfo()
end

function M:InitCardSpread()
	self.cardSpreadList = self.cardSpreadList or {}

	table.clear(self.cardSpreadList)

	for i = 0, DivinerCardSpreadConfig.count - 1 do
		local spreadCfg = DivinerCardSpreadConfig.LoadAt(i)

		if spreadCfg then
			table.insert(self.cardSpreadList, spreadCfg)
		end
	end
end

function M:RefreshNpcDebugInfo()
	if self.DEBUG and self.npcCard then
		local event1 = DivinerCardEventConfig.GetConfig(self.npcCard.Event1)
		local event2 = DivinerCardEventConfig.GetConfig(self.npcCard.Event2)
		local str = string.format("%s,%s,\ne1:%s,%s,%s,\ne2:%s,%s,%s", self.npcCard.Id, self.npcCard.name, event1 and event1.Description or "empty", event1 and event1.Parameter1, event1 and event1.Parameter2, event2 and event2.Description or "empty", event2 and event2.Parameter1, event2 and event2.Parameter2)
		self.bindData.npcCardInfo = str
	end
end

function M:PlayNpcCard()
	local trigger = false

	if self.npcCard then
		trigger = self:HandleEventById(self.npcCard.Event1, true) or trigger
		trigger = self:HandleEventById(self.npcCard.Event2, true) or trigger
	end

	return trigger
end

function M:GameFinish()
	gDisplayMessageMgr:ShowMessageContentDebug("游戏结束！")
end

function M:NextRound()
	self:OnRoundStart()
end

function M:OnRoundStart()
	self:SetTurnValue(0)
	self:IncreaseRound()

	if self:HitBreakCondition() then
		return
	end

	self:ShufflePlayerCards()

	for i = 1, self.GAME_EFFECT_TYPE.COUNT do
		table.clear(self.gameEffectDict[i])
	end

	self:MarkBuffEffectDirty(true)
	self:MarkBuffEffectDirty(false)

	self.drawNum = DivinerConfig.InitialCardsNum

	self:SetDrawIndexValue(0)
	self:DiscardCards()
	self:SwitchStageByDialog(self.GAME_STAGE.ROUND_START_DIALOG, self:GetRoundDialogID(true))
end

function M:PlayAuraCard()
	local trigger = false
	self.auraIndex = self.auraIndex + 1

	if self.auraIndex > #self.playerAuras then
		self:RefreshAuraCardInfo()

		return trigger
	end

	local cardInfo = self.playerAuras[self.auraIndex]

	if cardInfo then
		trigger = self:HandleEventById(cardInfo.Event1, false) or trigger
		trigger = self:HandleEventById(cardInfo.Event2, false) or trigger
	end

	self:RefreshAuraCardInfo(cardInfo)
	self:RefreshAuraDebugInfo()

	return trigger, cardInfo
end

function M:RefreshAuraCardInfo(cardInfo)
	self.bindData.tarotCardName = cardInfo.name or ""
	self.bindData.tarotCardDesc = cardInfo.Description or ""
	self.bindData.tarotCardIconId = cardInfo.img or ""
	self.bindData.tarotCardPosition = cardInfo.IsPositive and DivinerConfig.PositiveText or DivinerConfig.NegativeText
	self.bindData.tarotCardPositionStatus = cardInfo.IsPositive and self.CARD_CONTROL_TYPE.POSITIVE or self.CARD_CONTROL_TYPE.NEGATIVE
end

function M:RefreshAuraDebugInfo()
	local cardInfo = self.playerAuras[self.auraIndex]

	if self.DEBUG and cardInfo then
		local event1 = DivinerCardEventConfig.GetConfig(cardInfo.Event1)
		local event2 = DivinerCardEventConfig.GetConfig(cardInfo.Event2)
		local str = string.format("%s,%s,\ne1:%s,%s,%s,\ne2:%s,%s,%s", cardInfo.Id, cardInfo.name, event1 and event1.Description or "empty", event1 and event1.Parameter1, event1 and event1.Parameter2, event2 and event2.Description or "empty", event2 and event2.Parameter1, event2 and event2.Parameter2)
		self.bindData.auraInfo = str
	end
end

function M:DrawCard(drawNum)
	local pre = self.drawIndex

	self:IncreaseDrawIndex(drawNum)

	for i = pre + 1, self.drawIndex do
		local cardCfg = self.playerCards[i]
		local handCard = C_HandCardInfo.new(cardCfg)

		self:BuffCard(handCard)
		table.insert(self.handCards, handCard)
	end

	self.bindData.handCardNum = #self.handCards

	self:MarkHandCardDirty()
end

function M:DrawSpecialCard(num, id)
	local cardCfg = DivinerDivinationCardConfig.GetConfig(id)

	for i = 1, num do
		local handCard = C_HandCardInfo.new(cardCfg)

		self:BuffCard(handCard)
		table.insert(self.handCards, handCard)
	end

	self.bindData.handCardNum = #self.handCards

	self:MarkHandCardDirty()
end

function M:BuffCard(handCard)
	handCard:ClearBuff()

	local gameBuffs = self.gameEffectDict[self.GAME_EFFECT_TYPE.GAME_BUFF]

	for i = 1, #gameBuffs do
		handCard:TryAddBuff(gameBuffs[i], false, i)
	end
end

function M:PlayCard(handCard)
	local cost = handCard:GetCost()

	if self.patienceValue < cost then
		print_notice("费用不足")

		return
	end

	print_notice("PlayCard ", table.tostring(handCard))
	self:IncreaseTurn()

	for i = #self.handCards, 1, -1 do
		if self.handCards[i] == handCard then
			table.remove(self.handCards, i)

			break
		end
	end

	self.bindData.handCardNum = #self.handCards

	self:ChangePatience(-cost)
	self:HandleHandCard(handCard)
	handCard:Dispose()
	self:MarkHandCardDirty()
end

function M:HandleHandCard(handCard)
	local cardInfo = handCard.cfg

	if cardInfo then
		self:HandleEventByCardInfo(cardInfo.Event1, handCard.e1P1, handCard.e1P1Extra, handCard.e1P2, handCard.e1P2Extra)
		self:HandleEventByCardInfo(cardInfo.Event2, handCard.e2P1, handCard.e2P1Extra, handCard.e2P2, handCard.e2P2Extra)
		self:MinusBuffCountDown(handCard)
		self:SwitchStageByDialog(self.GAME_STAGE.PLAY_CARD_DIALOG, cardInfo.Dialogs[self.needDialogIndex])
	end
end

function M:MinusBuffCountDown(handCard)
	local buffList = self.gameEffectDict[self.GAME_EFFECT_TYPE.GAME_BUFF]

	for i = #handCard.gameBuffList, 1, -1 do
		local index = handCard.gameBuffList[i]
		local effectInfo = buffList[index]
		effectInfo.triggerNum = effectInfo.triggerNum + 1

		if effectInfo.countDown > 0 then
			effectInfo.countDown = effectInfo.countDown - 1

			if effectInfo.countDown == 0 then
				table.remove(buffList, index)
				self:MarkBuffEffectDirty(effectInfo.isNPC)
			end
		end
	end

	if self.buffEffectDirty ~= self.GAME_EFFECT_DIRTY_TYPE.NO_DIRTY then
		self:SyncCardBuffs()
	end

	self.gameEffectInfoDirty = true
end

function M:OnRoundEnd()
	self:ClearGameEffect()

	self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.FALSE
	self.bindData.ShowNextCtrl = self.CONTROL_TYPE.FALSE

	self:SetStage(self.GAME_STAGE.NONE)
end

function M:ClearGameEffect()
	for i = 1, self.GAME_EFFECT_TYPE.COUNT do
		local effectList = self.gameEffectDict[i]

		for j = #effectList, 1, -1 do
			self:RemoveGameEffect(i, j)
		end
	end

	self.bindData.auraInfo = ""
end

function M:HandleEventById(eventId, isNPC)
	if self.DEBUG then
		print_notice("HandleEventById-Aura/Npc, ", eventId)
	end

	local event = DivinerCardEventConfig.GetConfig(eventId)

	if event then
		if event.SettlementType == DivinerCardEventConfig.SettlementTypeType.Immediately then
			if self.turnNum == 0 and false then
				return self:TriggerEvent(event.EventType, event.Parameter1, event.Parameter2, 1, self.turnNum, self.roundNum)
			else
				return self:TriggerEvent(event.EventType, event.Parameter1, event.Parameter2, 1, self.turnNum, self.roundNum)
			end
		elseif event.SettlementType == DivinerCardEventConfig.SettlementTypeType.GameEffect then
			return self:AddGameEffect(eventId, event.EventType, event.Parameter1, event.Parameter2, isNPC)
		end
	end

	return false
end

function M:HandleEventByCardInfo(eventId, param1, param1Extra, param2, param2Extra)
	if self.DEBUG then
		print_notice("HandleEventByCardInfo-HandCard ", eventId, param1, param1Extra, param2, param2Extra)
	end

	local event = DivinerCardEventConfig.GetConfig(eventId)

	if event then
		if event.SettlementType == DivinerCardEventConfig.SettlementTypeType.Immediately then
			if self.turnNum == 1 and false then
				self:TriggerEvent(event.EventType, math.max(0, param1 + param1Extra), param2 + param2Extra, 1, self.turnNum, self.roundNum)
			else
				self:TriggerEvent(event.EventType, math.max(0, param1 + param1Extra), param2 + param2Extra, 1, self.turnNum, self.roundNum)
			end
		elseif event.SettlementType == DivinerCardEventConfig.SettlementTypeType.GameEffect then
			self:AddGameEffect(eventId, event.EventType, event.Parameter1, event.Parameter2, false)
		end
	end
end

function M:AddGameEffect(eventId, effectType, param1, param2, isNPC)
	local effectInfo, triggerTime = nil

	if DivinerCardEventConfig.EventTypeType.AddTrustValueBuff <= effectType and effectType <= DivinerCardEventConfig.EventTypeType.RemovePatienceValueBuff then
		effectInfo = C_CardEffectInfo.new(eventId, effectType, param1, param2, param2, 0, isNPC)
		triggerTime = self.GAME_EFFECT_TYPE.GAME_BUFF

		table.insert(self.gameEffectDict[triggerTime], effectInfo)
		self:SyncCardBuffs()

		self.gameEffectInfoDirty = true

		self:MarkBuffEffectDirty(isNPC)
	end

	return true
end

function M:RefreshGameEffectInfo()
	local info = ""

	for i = 1, self.GAME_EFFECT_TYPE.COUNT do
		local effectList = self.gameEffectDict[i]

		for j = 1, #effectList do
			local effect = effectList[j]
			local str = string.format("%s,%s,%s,%s,%s\n", self.eventType2Name[effect.effectType], effect.param1, effect.param2, effect.countDown, effect.triggerNum)
			info = info .. str
		end
	end

	self.bindData.gameEffects = info
end

function M:RemoveGameEffect(effectType, index)
	local effectList = self.gameEffectDict[effectType]
	local effectInfo = effectList[index]

	table.remove(effectList, index)

	if DivinerCardEventConfig.EventTypeType.AddTrustValueBuff <= effectInfo.effectType and effectInfo.effectType <= DivinerCardEventConfig.EventTypeType.RemovePatienceValueBuff then
		self:SyncCardBuffs()

		self.gameEffectInfoDirty = true
	end

	if effectType == self.GAME_EFFECT_TYPE.GAME_BUFF then
		self:MarkBuffEffectDirty(effectInfo.isNPC)
	end

	effectInfo:Dispose()
end

function M:TriggerEvent(eventType, param1, param2, triggerNum, turnNum, roundNum)
	if eventType == DivinerCardEventConfig.EventTypeType.AddTrustValue then
		if self.shieldValue > 0 then
			self:ChangeShield(-1)
		else
			self:ChangeTrust(param1)
		end
	elseif eventType == DivinerCardEventConfig.EventTypeType.RemoveTrustValue then
		self:ChangeTrust(-param1)
	elseif eventType == DivinerCardEventConfig.EventTypeType.AddShieldValue then
		self:ChangeShield(param1)
	elseif eventType == DivinerCardEventConfig.EventTypeType.RemoveShieldValue then
		self:ChangeShield(-param1)
	elseif eventType == DivinerCardEventConfig.EventTypeType.AddPatienceValue then
		self:ChangePatience(param1)
	elseif eventType == DivinerCardEventConfig.EventTypeType.RemovePatienceValue then
		self:ChangePatience(-param1)
	elseif eventType == DivinerCardEventConfig.EventTypeType.DrawCard then
		self:DrawCard(param1)
	elseif eventType == DivinerCardEventConfig.EventTypeType.Shuffle then
		local num = self:DiscardCards() + 1

		self:DrawCard(num)
	elseif eventType == DivinerCardEventConfig.EventTypeType.Shrink then
		math.randomseed(os.time())

		if math.random(100) <= param2 then
			self:ChangeDrawNum(-param1)

			return true
		end

		return false
	elseif eventType == DivinerCardEventConfig.EventTypeType.DrawSpecialCard then
		self:DrawSpecialCard(param1, param2)
	end

	return true
end

function M:CheckResult()
	if self.MAX_ROUND < self.roundNum then
		return self.trustCfg.IsSuccess and self.RESULT_TYPE.GAME_SUCCESS or self.RESULT_TYPE.GAME_END
	end

	if self.patienceValue <= 0 then
		return self.RESULT_TYPE.GAME_END
	end

	if #self.handCards == 0 then
		return self.RESULT_TYPE.HAND_CARD_EMPTY
	end

	return self.RESULT_TYPE.UNKNOWN
end

function M:DiscardCards()
	local num = #self.handCards

	for i = #self.handCards, 1, -1 do
		self.handCards[i]:Dispose()

		self.handCards[i] = nil
	end

	self.bindData.handCardNum = #self.handCards

	self:MarkHandCardDirty()

	return num
end

function M:MarkHandCardDirty()
	self.handCardDirty = true
end

function M:SyncCardBuffs()
	for i = 1, #self.handCards do
		self:BuffCard(self.handCards[i])
	end

	self:MarkHandCardDirty()
end

function M:SwitchStageByDialog(stage, dialogId)
	if self.DEBUG then
		print_notice("SwitchStageByDialog Stage:", stage, "DialogId:", dialogId)
	end

	self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.FALSE
	self.bindData.ShowNextCtrl = self.CONTROL_TYPE.FALSE

	gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Diviner)

	self.currentWaitDialog = dialogId

	self:SetStage(stage)
end

function M:OnWaitDialogEnd()
	local stage = self.currentStage
	self.currentWaitDialog = nil

	if stage == self.GAME_STAGE.NEED_DIALOG then
		self.bindData.StageCtrl = self.STAGE.CARD_SPREAD

		self.bindData.cardSpreadList:SetList(self.cardSpreadList)
		self:SetStage(self.GAME_STAGE.CARD_SPREAD_CHOOSE)
	elseif stage == self.GAME_STAGE.CARD_SPREAD_DIALOG then
		self:SwitchStageByDialog(self.GAME_STAGE.PREPARE_CARDS, DivinerConfig.CardDrawingDialogID)
	elseif stage == self.GAME_STAGE.PREPARE_CARDS then
		self.bindData.ShowInfoCtrl = self.CONTROL_TYPE.TRUE
		self.putAuraIndex = 0

		if self:CancelWaitDialog(self.STAGE_WAIT_ACTION.WAIT_PREPARE_CARDS) then
			self:OnRoundStart()
		end
	elseif stage == self.GAME_STAGE.ROUND_START_DIALOG then
		if self:PlayAuraCard() then
			local cardInfo = self.playerAuras[self.auraIndex]

			self:SwitchStageByDialog(self.GAME_STAGE.TAROT_DIALOG, cardInfo.Dialogs[self.needDialogIndex])
		elseif self:PlayNpcCard() then
			self:SwitchStageByDialog(self.GAME_STAGE.CUSTOMER_DIALOG, self.npcCard.Dialogs[self.needDialogIndex])
		else
			self:DrawCard(self.drawNum)

			self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.TRUE
			self.bindData.ShowNextCtrl = self.CONTROL_TYPE.TRUE

			self:SetStage(self.GAME_STAGE.CHOOSE_CARD)
		end
	elseif stage == self.GAME_STAGE.TAROT_DIALOG then
		if self:HitBreakCondition() then
			return
		end

		if self:PlayNpcCard() then
			self:SwitchStageByDialog(self.GAME_STAGE.CUSTOMER_DIALOG, self.npcCard.Dialogs[self.needDialogIndex])
		else
			self:DrawCard(self.drawNum)

			self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.TRUE
			self.bindData.ShowNextCtrl = self.CONTROL_TYPE.TRUE

			self:SetStage(self.GAME_STAGE.CHOOSE_CARD)
		end
	elseif stage == self.GAME_STAGE.CUSTOMER_DIALOG then
		if self:HitBreakCondition() then
			return
		end

		self:DrawCard(self.drawNum)

		self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.TRUE
		self.bindData.ShowNextCtrl = self.CONTROL_TYPE.TRUE

		self:SetStage(self.GAME_STAGE.CHOOSE_CARD)
	elseif stage == self.GAME_STAGE.PLAY_CARD_DIALOG then
		local hit, result = self:HitBreakCondition()

		if hit then
			return
		end

		if result == self.RESULT_TYPE.HAND_CARD_EMPTY then
			self:SetStage(self.GAME_STAGE.WAIT_NEXT_ROUND)

			self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.TRUE
			self.bindData.ShowNextCtrl = self.CONTROL_TYPE.TRUE
		else
			self:SetStage(self.GAME_STAGE.CHOOSE_CARD)

			self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.TRUE
			self.bindData.ShowNextCtrl = self.CONTROL_TYPE.TRUE
		end
	elseif stage == self.GAME_STAGE.ROUND_END_DIALOG then
		if self:CancelWaitDialog(self.STAGE_WAIT_ACTION.WAIT_PUT_CARD) then
			self:NextRound()
		end
	elseif stage == self.GAME_STAGE.GAME_SUCCESS_DIALOG then
		self.bindData.StageCtrl = self.STAGE.END

		self:SetStage(self.GAME_STAGE.NONE)
		gDisplayMessageMgr:ShowMessageContentDebug("游戏成功结束！")
	elseif stage == self.GAME_STAGE.GAME_END_DIALOG then
		self.bindData.StageCtrl = self.STAGE.END

		self:SetStage(self.GAME_STAGE.NONE)
		gDisplayMessageMgr:ShowMessageContentDebug("游戏失败结束！")
	end
end

function M:HitBreakCondition()
	local result = self:CheckResult()
	local hit = false

	if result == self.RESULT_TYPE.GAME_SUCCESS then
		self:OnRoundEnd()

		local dialogID = self:GetGameSuccessDialogID()

		self:SwitchStageByDialog(self.GAME_STAGE.GAME_SUCCESS_DIALOG, dialogID)

		hit = true
	elseif result == self.RESULT_TYPE.GAME_END then
		hit = true

		self:OnRoundEnd()
		self:SwitchStageByDialog(self.GAME_STAGE.GAME_END_DIALOG, self.npcNeed.GameFailDialog)
	end

	return hit, result
end

function M:GetGameSuccessDialogID()
	if self.trustLevel > 0 and self.trustLevel < 6 then
		local str = string.format("TrustSettlementDialog%d", self.trustLevel)

		return self.npcNeed[str] or self.npcNeed.TrustSettlementDialog1
	else
		print_error("Trust level is out of range in getting game success dialog id func!")

		return self.npcNeed.TrustSettlementDialog1
	end
end

function M:CalInitPatience()
	if self.DEBUG then
		print_notice("CalInitPatience")
	end

	local value = 0

	if self.npcMood then
		value = value + self.npcMood.MoodBasicPatience

		if self.DEBUG then
			print_notice("CalInitPatience add npcMood", self.npcMood.MoodBasicPatience)
		end
	end

	if self.playerLevel then
		value = value + self.playerLevel.BasicPatience

		if self.DEBUG then
			print_notice("CalInitPatience add playerLevel", self.playerLevel.BasicPatience)
		end
	end

	if self.npcNeed then
		value = value + self.npcNeed.BasicPatience

		if self.DEBUG then
			print_notice("CalInitPatience add npcNeed", self.npcNeed.BasicPatience)
		end
	end

	if self.npcType then
		value = value + self.npcType.CustomerBasicPatience

		if self.DEBUG then
			print_notice("CalInitPatience add npcType", self.npcType.CustomerBasicPatience)
		end
	end

	return value
end

function M:SetPatienceValue(value)
	self.patienceValue = value
	self.bindData.patienceValue = self.patienceValue
end

function M:ChangePatience(value)
	local pre = self.patienceValue
	local now = self.patienceValue + value
	now = math.max(0, now)
	local delta = now - pre

	if delta ~= 0 then
		self:ShowPatienceChangePopup(delta)
	end

	self:SetPatienceValue(now)

	if self.DEBUG then
		print_notice("ChangePatience pre:", pre, "delta:", value, "now:", self.patienceValue)
	end
end

function M:InitPopup()
	if self.PatienceChangeTipTimer then
		self.PatienceChangeTipTimer:Stop()

		self.PatienceChangeTipTimer = nil
	end

	self:HidePatienceChangePopup()

	if self.TrustChangeTipTimer then
		self.TrustChangeTipTimer:Stop()

		self.TrustChangeTipTimer = nil
	end

	self:HideTrustChangePopup()
end

function M:GetDeltaValueText(delta)
	if delta > 0 then
		return string.format("+%d", delta)
	else
		return string.format("-%d", -delta)
	end
end

function M:ShowPatienceChangePopup(delta)
	if self.PatienceChangeTipTimer then
		self.PatienceChangeTipTimer:Stop()

		self.PatienceChangeTipTimer = nil
	end

	self.bindData.patienceChangeValue = self:GetDeltaValueText(delta)

	self.bindData.patiencePopup:SetActive(true)

	self.PatienceChangeTipTimer = Timer.New(function ()
		self.PatienceChangeTipTimer = nil

		self:HidePatienceChangePopup()
	end, DivinerConfig.DisplayPopupTime):Start()
end

function M:HidePatienceChangePopup()
	self.bindData.patiencePopup:SetActive(false)
end

function M:CalInitShield()
	return 0
end

function M:SetShieldValue(value)
	self.shieldValue = value
	self.bindData.shieldValue = self.shieldValue

	if self.shieldValue > 0 then
		if self.npcBuffList and #self.npcBuffList > 0 and self.npcBuffList[1].effectIndex < 0 then
			self.bindData.npcBuffList:RefreshElement(0)
		else
			self:MarkBuffEffectDirty(true)
		end
	elseif self.npcBuffList and #self.npcBuffList > 0 and self.npcBuffList[1].effectIndex < 0 then
		self:MarkBuffEffectDirty(true)
	end
end

function M:ChangeShield(value)
	local pre = self.shieldValue
	local now = self.shieldValue + value
	now = math.max(0, now)

	self:SetShieldValue(now)
	print_notice("ChangeShield pre:", pre, "delta:", value, "now:", self.shieldValue)
end

function M:CalInitTrust()
	return 0
end

function M:SetTrustValue(value)
	if self.trustCfg.Value <= value then
		value = self:UpdateTrustLevel(value)
	end

	local base = self.trustCfg.Value
	self.trustValue = math.min(value, 99)
	self.bindData.TrustFillAmount = self.trustValue / base
	self.bindData.trustValue = string.format(self.TRUST_VALUE_TEMPLATE, self.trustValue, base)
end

function M:UpdateTrustLevel(value)
	if self.trustLevel == DivinerDivinationRewardConfig.count then
		return value
	end

	local level = DivinerDivinationRewardConfig.count
	local val = self.trustCfg.Value

	for i = self.trustLevel + 1, DivinerDivinationRewardConfig.count do
		local cfg = DivinerDivinationRewardConfig.GetConfig(i)

		if value < val + cfg.Value then
			level = i

			break
		elseif i < DivinerDivinationRewardConfig.count then
			val = val + cfg.Value
		end
	end

	self:SetTrustLevel(level)

	return value - val
end

function M:ChangeTrust(value)
	local pre = self.trustValue
	local now = self.trustValue + value
	now = math.max(0, now)
	local delta = now - pre

	if delta ~= 0 then
		self:ShowTrustChangePopup(delta)
	end

	self:SetTrustValue(now)
	print_notice("ChangeTrust pre:", pre, "delta:", value, "now:", self.trustValue)
end

function M:SetTrustLevel(value)
	self.trustLevel = value
	self.bindData.TrustLevelCtrl = self.trustLevel - 1
	self.trustCfg = DivinerDivinationRewardConfig.GetConfig(self.trustLevel)

	if not self.trustCfg then
		print_error("DivinerDivinationRewardConfig is nil, id=", self.trustLevel)
	end

	self.bindData.TrustDesc = self.trustCfg.Name
end

function M:ShowTrustChangePopup(delta)
	if self.TrustChangeTipTimer then
		self.TrustChangeTipTimer:Stop()

		self.TrustChangeTipTimer = nil
	end

	self.bindData.trustChangeValue = self:GetDeltaValueText(delta)

	self.bindData.trustPopup:SetActive(true)

	self.TrustChangeTipTimer = Timer.New(function ()
		self.TrustChangeTipTimer = nil

		self:HideTrustChangePopup()
	end, DivinerConfig.DisplayPopupTime):Start()
end

function M:HideTrustChangePopup()
	self.bindData.trustPopup:SetActive(false)
end

function M:ChangeDrawNum(value)
	local pre = self.drawNum
	self.drawNum = self.drawNum + value
	self.drawNum = math.max(0, self.drawNum)

	print_notice("ChangeDrawNum pre:", pre, "delta:", value, "now:", self.drawNum)
end

function M:SetTurnValue(value)
	self.turnNum = value
	self.bindData.turn = self.turnNum
end

function M:IncreaseTurn()
	self.turnNum = self.turnNum + 1
	self.bindData.turn = self.turnNum
end

function M:SetRoundValue(value)
	self.roundNum = value

	self:UpdateRoundText()
end

function M:IncreaseRound()
	self.roundNum = self.roundNum + 1

	self:UpdateRoundText()
end

function M:UpdateRoundText()
	if self.roundNum and self.MAX_ROUND and self.roundNum <= self.MAX_ROUND then
		self.bindData.round = string.format("#F(36)%d#z/%d", self.roundNum > 0 and self.roundNum or 1, self.MAX_ROUND)
	end
end

function M:SetDrawIndexValue(value)
	self.drawIndex = value
	self.bindData.cardInfo = self.drawIndex .. "/" .. #self.playerCards
end

function M:IncreaseDrawIndex(num)
	self.drawIndex = math.min(self.drawIndex + num, #self.playerCards)
	self.bindData.cardInfo = self.drawIndex .. "/" .. #self.playerCards
end

function M:SetStage(stage)
	self:ChangePlayerAction(self.currentStage, stage)

	self.currentStage = stage

	if self.DEBUG then
		for k, v in pairs(self.GAME_STAGE) do
			if v == stage then
				self.bindData.stage = k
			end
		end
	end
end

function M:OnBtnNext()
	self:OnRoundEnd()
	self:SwitchStageByDialog(self.GAME_STAGE.ROUND_END_DIALOG, self:GetRoundDialogID(false))
	self:StartWaitDialogAndAnim(self.STAGE_WAIT_ACTION.WAIT_PUT_CARD)
end

function M:OnBtnDebug()
	if self.DEBUG then
		self.DEBUG = false
	else
		self.DEBUG = true
	end

	self.bindData.DebugCtrl = self.DEBUG and self.CONTROL_TYPE.TRUE or self.CONTROL_TYPE.FALSE

	if self.DEBUG then
		self:RefreshNpcDebugInfo()
		self:RefreshAuraDebugInfo()

		for k, v in pairs(self.GAME_STAGE) do
			if v == self.currentStage then
				self.bindData.stage = k
			end
		end
	end

	self.bindData.handCardList:RefreshList()
end

function M:OnBtnReset()
	if self.currentWaitStage ~= self.GAME_STAGE.NONE then
		return
	end

	gTaskManager:RemoveCurrentTask(self.taskId)
	gTaskManager:SetCurrentTask(self.taskId)
	self:InitGame()

	self.gameEffectInfoDirty = true
end

function M:ShowCardSpread()
	if not self.STATE_EnableOnce then
		print_error("占卜界面还未打开，调用时序异常")

		return
	end

	self.bindData.ShowSolicitCtrl = self.CONTROL_TYPE.FALSE

	self:SwitchStageByDialog(self.GAME_STAGE.NEED_DIALOG, self.npcNeed.NeedDialogID)
end

function M:OnBtnSolicit()
	local idx = math.random(#DivinerConfig.HawkingDialogID)

	gDialogManager:ShowGeneralDialog(DivinerConfig.HawkingDialogID[idx], gDialogSource.Diviner)
end

function M:OnHandCardItemRender(btn, index, data)
	local store = self:GetStoreByWidget(btn)

	if store then
		store.cardName = data.cfg.name
		local desc = ""

		if self.DEBUG then
			desc = string.format("e1:%s,%s,%s,%s,%s\ne2:%s,%s,%s,%s,%s,c:%s,cEx:%s", self.eventType2Name[data.event1Cfg and data.event1Cfg.EventType or -1], data.e1P1, data.e1P2, data.e1P1Extra, data.e1P2Extra, self.eventType2Name[data.event2Cfg and data.event2Cfg.EventType or -1], data.e2P1, data.e2P2, data.e2P1Extra, data.e2P2Extra, data.cost, data.costExtra)
		else
			if data.event1Cfg then
				local color1 = self.VALUE_COLOR.DEFAULT

				if data.e1P1Extra > 0 then
					color1 = self.VALUE_COLOR.GREEN
				elseif data.e1P1Extra < 0 then
					color1 = self.VALUE_COLOR.RED
				end

				local color2 = self.VALUE_COLOR.DEFAULT
				desc = string.format(data.event1Cfg.Description, string.format(color1, data.e1P1 + data.e1P1Extra), string.format(color2, data.e1P2 + data.e1P2Extra))
			end

			if data.event2Cfg then
				local color1 = self.VALUE_COLOR.DEFAULT

				if data.e2P1Extra > 0 then
					color1 = self.VALUE_COLOR.GREEN
				elseif data.e2P1Extra < 0 then
					color1 = self.VALUE_COLOR.RED
				end

				local color2 = self.VALUE_COLOR.DEFAULT
				desc = desc .. ", " .. string.format(data.event2Cfg.Description, string.format(color1, data.e2P1 + data.e2P1Extra), string.format(color2, data.e2P2 + data.e2P2Extra))
			end
		end

		store.effectDesc = desc
		local cost = data:GetCost()
		local color = self.COST_COLOR.DEFAULT

		if data.costExtra < 0 then
			color = self.COST_COLOR.GREEN
		elseif data.costExtra > 0 then
			color = self.COST_COLOR.RED
		end

		store.cardCost = cost > 0 and -cost or cost
		store.costColorCtrl = color
		store.btnPC.luaClick = self:CreateActionWithArgs("OnHandCardClick", data)
	end
end

function M:OnHandCardListClick(btn, data)
	self:PlayCard(data)
end

function M:OnHandCardClick(data)
	self:PlayCard(data)
end

function M:OnCardSpreadItemRender(btn, index, data)
	local store = self:GetStoreByWidget(btn)

	if store then
		store.iconId = data.Img
		store.name = data.Name
		store.description = data.Description
	end
end

function M:OnCardSpreadListClick(btn, data)
	self.bindData.StageCtrl = self.STAGE.PLAY
	self.bindData.ShowInfoCtrl = self.CONTROL_TYPE.FALSE
	self.MAX_ROUND = data.CardsNum
	self.currentCardSpread = data
	self.putAuraIndex = 0

	self:StartWaitDialogAndAnim(self.STAGE_WAIT_ACTION.WAIT_PREPARE_CARDS)
	self:SwitchStageByDialog(self.GAME_STAGE.CARD_SPREAD_DIALOG, data.SpreadDialog)
	self:InitCardInstanceByCardSpread(data)
	self:UpdateRoundText()
	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.TarotThink, GameplayEventParam1.StateEnd)
end

function M:SwitchCameraView()
	local cfg = DivinerCameraConfig.GetConfig(1)

	if cfg then
		gUtils:SetFixCameraView(MyPlayerManager.PlayerUnit, cfg, self.bindData.VCam.gameObject)
		self.bindData.VCam.gameObject:SetActive(true)
	end
end

function M:MarkBuffEffectDirty(isNPC)
	if isNPC then
		if self.buffEffectDirty == self.GAME_EFFECT_DIRTY_TYPE.PLAYER_BUFF_DIRTY then
			self.buffEffectDirty = self.GAME_EFFECT_DIRTY_TYPE.BOTH_DIRTY
		else
			self.buffEffectDirty = self.GAME_EFFECT_DIRTY_TYPE.NPC_BUFF_DIRTY
		end
	elseif self.buffEffectDirty == self.GAME_EFFECT_DIRTY_TYPE.NPC_BUFF_DIRTY then
		self.buffEffectDirty = self.GAME_EFFECT_DIRTY_TYPE.BOTH_DIRTY
	else
		self.buffEffectDirty = self.GAME_EFFECT_DIRTY_TYPE.PLAYER_BUFF_DIRTY
	end
end

function M:RefreshBuffList()
	local playerBuffList = {}
	local npcBuffList = {}
	local refreshPlayer = self.buffEffectDirty == self.GAME_EFFECT_DIRTY_TYPE.PLAYER_BUFF_DIRTY or self.buffEffectDirty == self.GAME_EFFECT_DIRTY_TYPE.BOTH_DIRTY
	local refreshNPC = self.buffEffectDirty == self.GAME_EFFECT_DIRTY_TYPE.NPC_BUFF_DIRTY or self.buffEffectDirty == self.GAME_EFFECT_DIRTY_TYPE.BOTH_DIRTY

	if refreshNPC and self.shieldValue > 0 then
		local shieldInfo = {
			effectIndex = -1
		}

		table.insert(npcBuffList, shieldInfo)
	end

	local buffList = self.gameEffectDict[self.GAME_EFFECT_TYPE.GAME_BUFF]

	for i = 1, #buffList do
		local effectInfo = buffList[i]

		if effectInfo then
			local info = {
				effectIndex = i
			}

			if effectInfo.isNPC then
				if refreshNPC then
					table.insert(npcBuffList, info)
				end
			elseif refreshPlayer then
				table.insert(playerBuffList, info)
			end
		end
	end

	if refreshPlayer then
		self.playerBuffList = playerBuffList

		self.bindData.playerBuffList:SetList(self.playerBuffList)
	end

	if refreshNPC then
		self.npcBuffList = npcBuffList

		self.bindData.npcBuffList:SetList(self.npcBuffList)
	end

	self.buffEffectDirty = self.GAME_EFFECT_DIRTY_TYPE.NO_DIRTY
end

function M:OnPlayerBuffListRender(btn, index, data)
	local buffList = self.gameEffectDict[self.GAME_EFFECT_TYPE.GAME_BUFF]
	local effectInfo = buffList[data.effectIndex]

	if not effectInfo then
		return
	end

	local store = gStoreManager:GetStoreGroup("ProfessionBuff"):GetStoreByWidget(btn)

	if not store then
		return
	end

	self:UpdateBuffStore(effectInfo.eventId, store)
end

function M:OnNPCBuffListRender(btn, index, data)
	local store = gStoreManager:GetStoreGroup("ProfessionBuff"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.effectIndex > 0 then
		local buffList = self.gameEffectDict[self.GAME_EFFECT_TYPE.GAME_BUFF]
		local effectInfo = buffList[data.effectIndex]

		if not effectInfo then
			return
		end

		self:UpdateBuffStore(effectInfo.effectType, store)
	else
		store.buffIcon = DivinerConfig.ShieldBuffIcon or 0
		store.buffName = DivinerConfig.ShieldBuffName or ""
		store.buffDesc = DivinerConfig.ShieldBuffDes or ""
		store.buffNum = self.shieldValue
		store.buffNumStatus = self.SHOW_NUM_TYPE.SHOW
	end
end

function M:UpdateBuffStore(eventID, store)
	local eventCfg = DivinerCardEventConfig.GetConfig(eventID)

	if eventCfg then
		store.buffIcon = eventCfg.BuffIcon or 0
		store.buffName = eventCfg.BuffName or ""
		store.buffDesc = string.format(eventCfg.Description or "", eventCfg.Parameter1)
		store.buffNum = eventCfg.Parameter2 and eventCfg.Parameter2 > 0 or 0
		store.buffNumStatus = eventCfg.Parameter2 and eventCfg.Parameter2 > 0 and self.SHOW_NUM_TYPE.SHOW or self.SHOW_NUM_TYPE.HIDE
	end
end

function M:GetRoundDialogID(isStart)
	if self.currentCardSpread and self.roundNum then
		local dialogID = isStart and self.currentCardSpread.RoundStartDialog[self.roundNum] or self.currentCardSpread.RoundEndDialog[self.roundNum]

		if dialogID then
			return dialogID
		end
	end

	print_error("获取回合对话id失败！")

	return nil
end

function M:GetCurrentSpreadPosition()
	return self.currentCardSpread and self.currentCardSpread.CardLayoutPosition[self.putAuraIndex]
end

function M:TryInitPlayerCardBone()
	if not self.cardBone or gCS.LuaUtils.IsNull(self.cardBone) then
		self.cardBone = LX6.Utils.UnitUtils.NameToBone("Handr", MyPlayerManager.PlayerUnit)

		if not self.cardBone or gCS.LuaUtils.IsNull(self.cardBone) then
			print_error("找不到角色放置卡牌的骨骼！")
		end
	end
end

function M:InitPlayerAction()
	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.TarotWait, GameplayEventParam1.Number0)
end

function M:ResetPlayerAction()
	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.TarotEnd, GameplayEventParam1.Number0)
end

function M:ChangePlayerAction(currentStage, targetStage)
	if currentStage ~= targetStage then
		if targetStage == self.GAME_STAGE.NEED_DIALOG then
			gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.TarotThink, GameplayEventParam1.StateStart)
		elseif targetStage == self.GAME_STAGE.CARD_SPREAD_CHOOSE then
			-- Nothing
		elseif targetStage == self.GAME_STAGE.PREPARE_CARDS then
			gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.TarotPrepareCards, GameplayEventParam1.StateStart)
		else
			if targetStage == self.GAME_STAGE.ROUND_START_DIALOG then
				self.putAuraIndex = self.putAuraIndex + 1
				local cardPos = self:GetCurrentSpreadPosition()

				if cardPos then
					FrameTimer.New(function ()
						gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.TarotLookCard, cardPos + GameplayEventParam1.Number0)
					end, 1):Start()
				end

				return
			end

			if targetStage == self.GAME_STAGE.ROUND_END_DIALOG then
				local cardPos = self:GetCurrentSpreadPosition()

				if cardPos then
					gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.TarotPutBackCard, cardPos + GameplayEventParam1.Number0)
				end
			elseif targetStage == self.GAME_STAGE.GAME_SUCCESS_DIALOG or targetStage == self.GAME_STAGE.GAME_END_DIALOG then
				FrameTimer.New(function ()
					gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.TarotPutCardIntoDeck, GameplayEventParam1.Number0)
				end, 1):Start()
			end
		end
	end
end

function M:OnPlayerActionEnd(data)
	local targetEvent = nil
	local targetParam = GameplayEventParam1.Number0
	local dataTable = data:ToTable()
	local TarotAnimEndState = dataTable[1]

	if TarotAnimEndState == 1 or TarotAnimEndState == 2 then
		if self.currentStage == self.GAME_STAGE.PREPARE_CARDS then
			if self.putAuraIndex < self.currentCardSpread.CardsNum then
				targetEvent = GameplayEvent.TarotChooseCard
				self.putAuraIndex = self.putAuraIndex + 1
				local cardPos = self:GetCurrentSpreadPosition()
				targetParam = cardPos and cardPos + GameplayEventParam1.Number0 or GameplayEventParam1.Number1
			else
				self.putAuraIndex = 0
				targetEvent = GameplayEvent.TarotChooseCard
				targetParam = GameplayEventParam1.StateEnd
			end
		end
	elseif TarotAnimEndState == 4 then
		if self.currentStage == self.GAME_STAGE.ROUND_END_DIALOG and self:CancelWaitAnim(self.STAGE_WAIT_ACTION.WAIT_PUT_CARD) then
			self:NextRound()
		end
	elseif TarotAnimEndState == 6 and #dataTable == 2 then
		self:OnChooseAuraCardAction(dataTable[2]:ToTable())
	elseif TarotAnimEndState == 7 and #dataTable == 2 then
		self:OnLookAuraCardAction(dataTable[2]:ToTable())
	elseif TarotAnimEndState == 8 and #dataTable == 2 then
		self:OnPutBackAuraCardAction(dataTable[2]:ToTable())
	elseif TarotAnimEndState == 9 and #dataTable == 2 then
		self:OnPutBackCardIntoDeck(dataTable[2]:ToTable())
	elseif TarotAnimEndState == 10 and self:CancelWaitAnim(self.STAGE_WAIT_ACTION.WAIT_PREPARE_CARDS) then
		self:OnRoundStart()
	end

	if targetEvent then
		FrameTimer.New(function ()
			gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, targetEvent, targetParam)
		end, 1):Start()
	end
end

function M:InitDialogAndAnimWaitState()
	self.currentWaitState = {
		action = self.STAGE_WAIT_ACTION.NO_WAIT_ACTION,
		waitState = self.STAGE_WAIT.NO_WAIT
	}
end

function M:StartWaitDialogAndAnim(waitAction)
	if self.currentWaitState.action == self.STAGE_WAIT_ACTION.NO_WAIT_ACTION then
		self.currentWaitState.action = waitAction
		self.currentWaitState.waitState = self.STAGE_WAIT.WAIT_BOTH
	else
		print_error("Start wait dialog and anim, but current wait action exist, action=", self.currentWaitState.action)
	end
end

function M:CancelWaitDialog(waitAction)
	if self.currentWaitState.action == waitAction then
		if self.currentWaitState.waitState == self.STAGE_WAIT.WAIT_BOTH then
			self.currentWaitState.waitState = self.STAGE_WAIT.WAIT_ANIM
		elseif self.currentWaitState.waitState == self.STAGE_WAIT.WAIT_DIALOG then
			self.currentWaitState.waitState = self.STAGE_WAIT.NO_WAIT
			self.currentWaitState.action = self.STAGE_WAIT_ACTION.NO_WAIT_ACTION
		end

		return self.currentWaitState.waitState == self.STAGE_WAIT.NO_WAIT
	end
end

function M:CancelWaitAnim(waitAction)
	if self.currentWaitState.action == waitAction then
		if self.currentWaitState.waitState == self.STAGE_WAIT.WAIT_BOTH then
			self.currentWaitState.waitState = self.STAGE_WAIT.WAIT_DIALOG
		elseif self.currentWaitState.waitState == self.STAGE_WAIT.WAIT_ANIM then
			self.currentWaitState.waitState = self.STAGE_WAIT.NO_WAIT
			self.currentWaitState.action = self.STAGE_WAIT_ACTION.NO_WAIT_ACTION
		end

		return self.currentWaitState.waitState == self.STAGE_WAIT.NO_WAIT
	end
end

function M:InitCardTemplate()
	if not self.loadCardOp or gCS.LuaUtils.IsNull(self.cardTemplate) then
		self.loadCardOp = gResourceManager:LoadAssetWithCallBack(DivinerConfig.CardAssetPath, typeof(UnityEngine.GameObject), function (loadOp)
			self.cardTemplate = loadOp.asset
		end)
	end
end

function M:ReleaseCardTemplate()
	self.loadTexOp = gResourceManager:UnloadAssetLoadOp(self.loadTexOp)
	self.cardTemplate = nil

	self:DestroyAllCardIns()
end

function M:InitCardInstanceByCardSpread(data)
	if not self.spreadCardInstances then
		self.spreadCardInstances = {}
	end

	if self.cardTemplate then
		for i = 1, data.CardsNum do
			local spreadPos = data.CardLayoutPosition[i]
			local cardInstanceData = self.spreadCardInstances[spreadPos]

			if cardInstanceData and cardInstanceData.instance then
				if cardInstanceData.state ~= self.INS_STATE.NOT_DISPLAY then
					self:HideCardIns(spreadPos)
				end
			else
				cardInstanceData = {
					instance = UnityEngine.GameObject.Instantiate(self.cardTemplate),
					state = self.INS_STATE.NOT_DISPLAY
				}

				cardInstanceData.instance.transform:SetPosition(0, 0, -10000)
				cardInstanceData.instance.transform:SetLocalEulerAngles(0, 0, 0)

				self.spreadCardInstances[spreadPos] = cardInstanceData
			end
		end
	end
end

function M:DestroyAllCardIns()
	if self.spreadCardInstances and #self.spreadCardInstances > 0 then
		for k, cardInsInfo in pairs(self.spreadCardInstances) do
			if cardInsInfo and cardInsInfo.instance then
				UnityEngine.GameObject.Destroy(cardInsInfo.instance)
			end
		end
	end

	self.spreadCardInstances = nil
end

function M:ShowCardInsInHand(spreadPos)
	local cardInstanceData = self.spreadCardInstances and self.spreadCardInstances[spreadPos]

	self:TryInitPlayerCardBone()

	if self.cardBone and cardInstanceData and cardInstanceData.state ~= self.INS_STATE.IN_HAND then
		cardInstanceData.instance.transform:SetParent(self.cardBone, false)
		cardInstanceData.instance.transform:SetLocalPosition(Vector3.zero)
		cardInstanceData.instance.transform:SetLocalEulerAngles(0, 0, 0)

		cardInstanceData.state = self.INS_STATE.IN_HAND
	end
end

function M:ShowCardInsInDesk(spreadPos)
	local cardInstanceData = self.spreadCardInstances and self.spreadCardInstances[spreadPos]

	if cardInstanceData and cardInstanceData.state ~= self.INS_STATE.IN_DESK then
		cardInstanceData.instance.transform:SetParent(nil, true)

		cardInstanceData.state = self.INS_STATE.IN_DESK
	end
end

function M:HideCardIns(spreadPos)
	local cardInstanceData = self.spreadCardInstances and self.spreadCardInstances[spreadPos]

	if cardInstanceData and cardInstanceData.state ~= self.INS_STATE.NOT_DISPLAY then
		cardInstanceData.instance.transform:SetParent(nil)
		cardInstanceData.instance.transform:SetPosition(0, 0, -10000)
		cardInstanceData.instance.transform:SetLocalEulerAngles(0, 0, 0)

		cardInstanceData.state = self.INS_STATE.NOT_DISPLAY
	end
end

function M:OnPutBackCardIntoDeck(timeData)
	if self.spreadCardInstances and #self.spreadCardInstances > 0 and timeData and #timeData == 9 then
		if self.deckCoroutine then
			coroutine.stop(self.deckCoroutine)

			self.deckCoroutine = nil
		end

		self.deckCoroutine = coroutine.start(function ()
			for i = 1, 9 do
				coroutine.wait(timeData[i])

				if self.spreadCardInstances[i] then
					self:HideCardIns(i)
				end
			end

			self.deckCoroutine = nil
		end)
	end
end

function M:StopAllTimer()
	if self.deckCoroutine then
		coroutine.stop(self.deckCoroutine)

		self.deckCoroutine = nil
	end

	if self.chooseAuraCardTimer then
		self.chooseAuraCardTimer:Stop()

		self.chooseAuraCardTimer = nil
	end

	if self.lookAuraCardTimer then
		self.lookAuraCardTimer:Stop()

		self.lookAuraCardTimer = nil
	end

	if self.putBackAuraCardTimer then
		self.putBackAuraCardTimer:Stop()

		self.putBackAuraCardTimer = nil
	end

	if self.PatienceChangeTipTimer then
		self.PatienceChangeTipTimer:Stop()

		self.PatienceChangeTipTimer = nil
	end

	if self.TrustChangeTipTimer then
		self.TrustChangeTipTimer:Stop()

		self.TrustChangeTipTimer = nil
	end
end

function M:OnChooseAuraCardAction(timeData)
	local cardPos = self:GetCurrentSpreadPosition()

	if cardPos and timeData and #timeData == 9 then
		self:ShowCardInsInHand(cardPos)

		local waitTime = timeData[cardPos]

		if self.chooseAuraCardTimer then
			self.chooseAuraCardTimer:Stop()

			self.chooseAuraCardTimer = nil
		end

		self.chooseAuraCardTimer = Timer.New(function ()
			self.chooseAuraCardTimer = nil

			self:ShowCardInsInDesk(cardPos)
		end, waitTime):Start()
	end
end

function M:OnLookAuraCardAction(timeData)
	local cardPos = self:GetCurrentSpreadPosition()

	if cardPos and timeData and #timeData == 9 then
		local waitTime = timeData[cardPos]

		if self.lookAuraCardTimer then
			self.lookAuraCardTimer:Stop()

			self.lookAuraCardTimer = nil
		end

		self.lookAuraCardTimer = Timer.New(function ()
			self.lookAuraCardTimer = nil

			self:ShowCardInsInHand(cardPos)
		end, waitTime):Start()
	end
end

function M:OnPutBackAuraCardAction(timeData)
	local cardPos = self:GetCurrentSpreadPosition()

	if cardPos and timeData and #timeData == 9 then
		local waitTime = timeData[cardPos]

		if self.putBackAuraCardTimer then
			self.putBackAuraCardTimer:Stop()

			self.putBackAuraCardTimer = nil
		end

		self.putBackAuraCardTimer = Timer.New(function ()
			self.putBackAuraCardTimer = nil

			self:ShowCardInsInDesk(cardPos)
		end, waitTime):Start()
	end
end

function M:HideAllCardIns()
	if self.spreadCardInstances then
		for k, v in pairs(self.spreadCardInstances) do
			self:HideCardIns(k)
		end
	end
end

function M:InitPersuade(persuadeId)
	self.persuadeId = persuadeId
	self.bindData.StageCtrl = 2
	self.bindData.ShowInfoCtrl = 1
	self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.TRUE
	self.currentStage = self.STAGE.OPTIONS
	self.success = false
	local persuadeCfg = LTConfig.DivinerPersuadeConfig.GetConfig(persuadeId)

	if persuadeCfg then
		local jobId = 0
		local spirit = gSpiritManager:GetSpirit(gSpiritManager:GetCurFirstSpiritTid())

		if spirit then
			jobId = spirit.SpiritInfo.SpiritJobInfo.CurrentJob
		end

		self.basicPersuadePoint = 0

		for i = 0, LTConfig.DivinerConfig.count - 1 do
			local divinerCfg = LTConfig.DivinerConfig.LoadAt(i)

			if divinerCfg.Id == jobId then
				self.basicPersuadePoint = divinerCfg.BasicPersuadePoint

				break
			end
		end

		self.currentPersuadePoint = self.basicPersuadePoint
		self.difficulty = persuadeCfg.Difficulty
		self.currentProgress = 0
		self.currentRound = 1

		self:RefreshLevel()
		self:RefreshLevelContent()

		self.levelDialogs = {}

		for i = 0, LTConfig.DivinerPersuadeDialogConfig.count - 1 do
			local dialogCfg = LTConfig.DivinerPersuadeDialogConfig.LoadAt(i)

			if dialogCfg and dialogCfg.PersuadeId == persuadeId and dialogCfg.ProgressLevel and dialogCfg.ProgressLevel > 0 then
				if not self.levelDialogs[dialogCfg.ProgressLevel] then
					self.levelDialogs[dialogCfg.ProgressLevel] = {}
				end

				table.insert(self.levelDialogs[dialogCfg.ProgressLevel], dialogCfg.Id)
			end
		end

		self.nextDialogs = nil
		self.currentDialogs = {}
		self.exceptDialogs = {}

		self:RefreshOptions()
		self:RefreshRound()

		self.bindData.npcName = persuadeCfg.Name
		self.bindData.npcHeadIcon = persuadeCfg.HeadIcon
		self.bindData.persuadeText = persuadeCfg.PersuadeDes
	end
end

function M:IsSuccess()
	return self.difficulty <= self.currentProgress
end

function M:RefreshLevel()
	local persuasionProgressDivision = LTConfig.DivinerConfig.PersuasionProgressDivision
	local percent = self.currentProgress / self.difficulty
	self.currentLevel = 0

	for i = #persuasionProgressDivision, 1, -1 do
		if persuasionProgressDivision[i] <= percent then
			self.currentLevel = i

			break
		end
	end

	gDivinerManager:SyncPersuadeLevelToServer(self.currentLevel)
end

function M:RefreshLevelContent()
	local percent = self.currentProgress / self.difficulty
	self.bindData.patientProgress = percent
	self.bindData.patient = string.format("%d/%d", self.currentProgress, self.difficulty)
end

function M:RefreshOptions()
	self.currentDialogs = {}
	local dialogs = nil

	if self.nextDialogs and #self.nextDialogs > 0 then
		dialogs = self.nextDialogs
		self.nextDialogs = nil
	else
		dialogs = self.levelDialogs[self.currentLevel]
	end

	if dialogs then
		for i = 1, #dialogs do
			local id = dialogs[i]

			if not table.contains(self.exceptDialogs, id) then
				local cfg = LTConfig.DivinerPersuadeDialogConfig.GetConfig(id)

				if cfg then
					table.insert(self.currentDialogs, {
						id = id,
						persuadeType = cfg.PersuadeType,
						optionText = cfg.OptionText
					})
				end
			end
		end
	end

	self.bindData.handCardList:SetList(self.currentDialogs)
	self.bindData.handCardList:SelectItem(0, false)
end

function M:RefreshRound()
	self.bindData.round = string.format("#F(36)%d#z/%d", self.currentRound, self.basicPersuadePoint)
end

function M:OnPersuadeOptionRender(btn, index, data)
	local store = self:GetStoreByWidget(btn)

	if store then
		store.desc = data.optionText
		local typeCfg = LTConfig.DivinerPersuadeTypeConfig.GetConfig(data.persuadeType)

		if typeCfg then
			store.successRate = string.format("%d%%", math.floor(typeCfg.SuccessRate * 100))
			store.pointValue = string.format("+%d", typeCfg.PointValue)
			store.title = string.format("#c168924[%s]#z", typeCfg.Name)
		end
	end

	store.btnPC.luaClick = self:CreateActionWithArgs("OnPersuadeOptionPCBtnClick", data)
end

function M:OnPersuadeOptionPCBtnClick(data)
	self:OnPersuadeOptionClick(nil, data)
end

function M:OnPersuadeOptionClick(btn, data)
	if self.currentStage ~= self.STAGE.OPTIONS or self.currentPersuadePoint < 1 then
		return
	end

	local optionCfg = LTConfig.DivinerPersuadeDialogConfig.GetConfig(data.id)
	local typeCfg = LTConfig.DivinerPersuadeTypeConfig.GetConfig(data.persuadeType)

	if optionCfg and typeCfg then
		if optionCfg.CanRepeat == false then
			table.insert(self.exceptDialogs, data.id)
		end

		self.currentPersuadePoint = self.currentPersuadePoint - 1
		self.currentRound = self.currentRound + 1

		math.randomseed(os.time())

		local current = math.random(100) / 100
		local needShowDialogId = 0

		if current <= typeCfg.SuccessRate then
			self.currentProgress = self.currentProgress + typeCfg.PointValue
			self.currentProgres = self.difficulty < self.currentProgress and self.difficulty or self.currentProgress

			self:RefreshLevel()

			self.nextDialogs = optionCfg.SucessBranch
			needShowDialogId = optionCfg.SucessDialogId
		else
			self.nextDialogs = optionCfg.FailBranch
			needShowDialogId = optionCfg.FailDialogId
		end

		self.currentStage = self.STAGE.DIALOG

		gDialogManager:ShowGeneralDialog(needShowDialogId, gDialogSource.Diviner, nil, nil, function (dialogId, selectIndex, state, nextDialogId)
			if nextDialogId == 0 and state == 0 and self.isShow then
				self:OnDialogEnd()
			end
		end)

		self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.FALSE
	end
end

function M:OnDialogEnd()
	self.currentStage = self.STAGE.OPTIONS

	if self:IsSuccess() then
		self.success = true

		gPanelManager:Close(gPanelId.S_DIVINATION_PANEL)
	elseif self.currentPersuadePoint < 1 then
		self.success = false

		gPanelManager:Close(gPanelId.S_DIVINATION_PANEL)
	else
		self.bindData.ShowInterpretationCtrl = self.CONTROL_TYPE.TRUE

		self:RefreshOptions()
		self:RefreshRound()
		self:RefreshLevelContent()
	end
end

function M:OnBtnBack()
	gPanelManager:Close(gPanelId.S_DIVINATION_PANEL)
end

function M:OnSwitchCameraBtnClick()
	self:SwitchToNextCamera()
end

function M:SwitchToNextCamera()
	if self.currentCameraType == self.CAMERA_TYPE.FREE_LOOK then
		self:SwitchNextFixCamera()
	else
		self.currentFixCameraDataIndex = self.currentFixCameraDataIndex + 1

		if LTConfig.DivinerCameraConfig.count <= self.currentFixCameraDataIndex then
			self.currentFixCameraDataIndex = 0

			self:DisableAllFixCamera()
		else
			self:SwitchNextFixCamera()
		end
	end
end

function M:SwitchToFreeLook()
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(LTConfig.DivinerConfig.FreeLockActionStatusId, LTConfig.DivinerConfig.FreeLockActionSwitchTime, nil, 5)

	self.currentCameraType = self.CAMERA_TYPE.FREE_LOOK
end

function M:SwitchToNormalFreeLook()
	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(LTConfig.DivinerConfig.FreeLockActionSwitchTime, nil, 5)
end

function M:DisableAllFixCamera()
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("DivinationPanel")

	if not cmRegister then
		return
	end

	cmRegister:DisableAllVCamera()
	self:SwitchToFreeLook()
end

function M:SwitchNextFixCamera()
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("DivinationPanel")

	if not cmRegister then
		return
	end

	local cameraCfg = LTConfig.DivinerCameraConfig.LoadAt(self.currentFixCameraDataIndex)

	if not cameraCfg then
		return
	end

	self.currentFixCameraIndex = (self.currentFixCameraIndex + 1) % 2
	local playerTrans = MyPlayerManager.PlayerUnit.PlayerObj
	local worldPos = playerTrans:TransformPoint(cameraCfg.PositionX, cameraCfg.PositionY, cameraCfg.PositionZ)
	local dir = Quaternion.Euler(cameraCfg.RotationX, cameraCfg.RotationY, cameraCfg.RotationZ) * Vector3.forward
	local worldEuler = Quaternion.LookRotation(playerTrans:TransformDirection(dir)).eulerAngles
	local cameraName = "FixCam" .. tostring(self.currentFixCameraIndex + 1)
	local cm = cmRegister:GetVcamByName(cameraName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFixCameraData(cm.gameObject, worldPos, worldEuler, cameraCfg.CameraFov)
	cmRegister:EnableVCamera(cameraName, LX6.Cinemachine.EVcamPriority.Panel)

	self.currentCameraType = self.CAMERA_TYPE.FIX_CAMERA
end

function M:BindListener()
	if not self.IsBindListener then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			LX6.Manager.GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.ScrollWheel)
		end

		self.IsBindListener = true
	end
end

function M:UnbindListener()
	if self.IsBindListener then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			LX6.Manager.GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.ScrollWheel)
		end

		self.IsBindListener = false
	end
end

function M:OnMouseScrollWheel(context)
	if gCS.LuaUtils.IsInPcOrEditor() then
		if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
			return
		end

		if context.performed then
			local zoom = context:ReadValueVector2().y
			local zoomResult = zoom * self.zoomFactor

			if self.scaleMax < zoomResult then
				self:PcKeyChangeSelect(true)
			else
				self:PcKeyChangeSelect(false)
			end
		end
	end
end

function M:PcKeyChangeSelect(isUpDir)
	local index = self.bindData.handCardList.selectedIndex

	if isUpDir then
		index = index - 1
	else
		index = index + 1
	end

	index = math.max(index, 0)
	index = math.min(math.max(#self.currentDialogs - 1, 0), index)

	self.bindData.handCardList:SelectItem(index, false)
end
