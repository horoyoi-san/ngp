local M = gDivinerManager or {}
M.IsInit = M.IsInit or false
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr
local ReactionConfig = LTConfig.DivinerDivinateReactionConfig
local DemandConfig = LTConfig.DivinerDemandConfig

function M:OnInit()
	if self.IsInit then
		return
	end

	self.cardTemplate = {}
	self.cardPos = {
		2,
		4,
		5,
		6
	}
	self.cardPosToIndex = {
		0,
		1,
		0,
		2,
		3,
		4,
		0,
		0,
		0
	}
	self.CARD_STAGE = {
		IN_DESK_FACE = 3,
		HIDE = 4,
		IN_DESK_BACK = 2,
		IN_HAND = 1
	}
	self.PLAY_STATE = {
		WAIT_SERVER_RES = 2,
		REWARD = 7,
		PERSUADE = 6,
		DEMAND = 4,
		CALL_NPC = 3,
		BRANCH = 5,
		NONE = 1
	}
	self.CHAT_STAGE = {
		PERSUADE = 1,
		DEMAND = 0
	}
	self.END_REASON = {
		NORMAL_FAIL = 2,
		TIME_OUT = 4,
		BATTLE_FAIL = 3,
		NEXT_STAGE = 1
	}
	self.curPlayState = self.PLAY_STATE.NONE
	self.isDebug = true
	self.listenerAdded = false
	self.eventHandlers = {
		[gEventConstants.TAROT_ANIMATION_END] = function (_, data)
			self:OnBeginPutCardToDesk(data)
		end,
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = function (_, data)
			self:OnGameplaySignal(data)
		end
	}

	self:AddEventListener()

	self.IsInit = true
end

function M:OnGameplaySignal(data)
	if self.isDebug then
		print_notice("DivinerManager OnGameplaySignal " .. tostring(data and data:GetCfgId()))
	end

	local signalId = data:GetCfgId()

	if signalId == 3102 then
		if self.curPlayState == self.PLAY_STATE.CALL_NPC then
			local pid = data:GetPid()

			self:OnDivinerAgentDoAttractInternal(pid)
			FrameTimer.New(function ()
				gDivinerManager:SendNPCEnterDiviner()
			end, 1):Start()
		end
	elseif signalId == 3104 then
		if self.needAskBattle then
			self.needAskBattle = false

			gClientToGameDelegate:AskDivinerEnterBattle().Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end

			gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_CUSTOMER_ENTER_BATTLE_END")
		end
	elseif signalId == 3105 then
		gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_CUSTOMER_STAND_UP_END")
	end
end

function M:AddEventListener()
	if not self.listenerAdded then
		self.listenerAdded = true

		gMessageManager:RegisterEventHandlers(self.eventHandlers)
	end
end

function M:RemoveEventListener()
	if self.listenerAdded then
		self.listenerAdded = false

		gMessageManager:UnregisterEventHandlers(self.eventHandlers)
	end
end

function M:StartBranchSelectInternal(data)
	self.branchSelectAnimComplete = false
	self.waitOpenBranchData = data

	self:StartPrepareCardAnim()

	local showDialog = false

	if data.dialogId and data.dialogId > 0 then
		self.branchSelectDialogComplete = false

		if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
			showDialog = true

			self.fakeDialogPanel:ShowFakeDialogById(data.dialogId, function ()
				self.branchSelectDialogComplete = true

				self:CheckOpenBranchSelectPanel()
			end)
		end
	end

	if not showDialog then
		self.branchSelectDialogComplete = true

		self:CheckOpenBranchSelectPanel()
	end

	self:SwitchToCardFreeCamera()
end

function M:EndBranchSelect(data)
	self:OnBranchPanelClosed(data.cardData)

	self.waitOpenBranchData = nil
	self.branchSelectDialogComplete = false
	self.branchSelectAnimComplete = false

	self:SelectBranch(data.branchId)
end

function M:CheckOpenBranchSelectPanel()
	if self.branchSelectDialogComplete and self.branchSelectAnimComplete and self.waitOpenBranchData then
		gPanelManager:Close(gPanelId.DIALOG_BASE_PANEL)

		local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(self.waitOpenBranchData.demandId)

		if demandCfg then
			local TarotInitialOrder = demandCfg.TarotInitialOrder
			local needAcceptBranchIds = demandCfg.BranchId

			if not needAcceptBranchIds or needAcceptBranchIds == 0 then
				print_error_without_stack("占卜师分支配置错误，塔罗牌无有效分支数据！demandId Id : " .. tostring(self.waitOpenBranchData.demandId))

				return
			end

			if not TarotInitialOrder or #TarotInitialOrder ~= 4 then
				print_error_without_stack("占卜师分支配置错误，塔罗牌初始顺序数据无效！demandId Id : " .. tostring(self.waitOpenBranchData.demandId))

				return
			end

			gPanelManager:CheckShow(gPanelId.DIVINATIONV_PANEL, self.waitOpenBranchData)
		end
	end
end

function M:StartPrepareCardAnim()
	self:DestroyAllCardIns()

	local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(self.waitOpenBranchData.demandId)

	if demandCfg then
		self.currentCardIndex = 0
		self.currentCardSpread = {}
		local loadIds = {}

		for i = 1, #demandCfg.TarotInitialOrder do
			local cardId = demandCfg.TarotInitialOrder[i]

			table.insert(self.currentCardSpread, {
				id = cardId,
				stage = self.CARD_STAGE.HIDE
			})
			table.insert(loadIds, cardId)

			local cardCfg = LTConfig.DivinerDivinationCardConfig.GetConfig(cardId)

			if cardCfg then
				table.insert(loadIds, cardCfg.CorrespondingCard)
			end
		end

		self:LoadAndInstantiateCard(loadIds)
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.TarotWait, MuGenStates.Logic.GameplayEventParam1.StateStart)
	else
		self.branchSelectAnimComplete = true
	end
end

function M:StartPutBackIntoDeck()
	if self.currentCardSpread then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.TarotWait, MuGenStates.Logic.GameplayEventParam1.StateEnd)
	end
end

function M:LoadAndInstantiateCard(cardIds)
	for i = 1, #cardIds do
		local cardId = cardIds[i] or 0
		local cardCfg = LTConfig.DivinerDivinationCardConfig.GetConfig(cardId)

		if cardCfg then
			local cardTemplate = self.cardTemplate[cardId]

			if not cardTemplate then
				cardTemplate = {}
				local modelPath = string.format(gBundleConstants.CHARACTER_Default_AVATAR_BUNDLE_PATH_FORMATTER, cardCfg.Model)
				cardTemplate.assetOp = gResourceManager:LoadAssetWithCallBack(modelPath, typeof(UnityEngine.GameObject), function (loadOp)
					self.cardTemplate[cardId].template = loadOp.asset
				end)
				self.cardTemplate[cardId] = cardTemplate
			end
		end
	end
end

function M:OnBranchPanelClosed(data)
	for i = 1, #data do
		local dataInfo = data[i]
		local cardInfo = self.currentCardSpread[i]

		if cardInfo and self.cardTemplate then
			if cardInfo.id == dataInfo.id then
				if dataInfo.face then
					local cardTemplate = self.cardTemplate[cardInfo.id]

					if cardTemplate and cardTemplate.template then
						if not cardTemplate.instance then
							cardTemplate.instance = UnityEngine.GameObject.Instantiate(cardTemplate.template)
						end

						local cardCfg = LTConfig.DivinerDivinationCardConfig.GetConfig(dataInfo.id)
						local negativeValue = cardCfg and not cardCfg.IsPositive and 180 or 0

						if cardTemplate.instance and cardInfo.stage ~= self.CARD_STAGE.IN_DESK_FACE then
							local eulerAngles = cardTemplate.instance.transform.eulerAngles

							cardTemplate.instance.transform:SetLocalEulerAngles(eulerAngles.x, eulerAngles.y + negativeValue, eulerAngles.z + 180)

							cardInfo.stage = self.CARD_STAGE.IN_DESK_FACE
						end
					end
				end
			else
				local oldCardTemplate = self.cardTemplate[cardInfo.id]

				if oldCardTemplate.instance and cardInfo.stage ~= self.CARD_STAGE.IN_DESK_FACE then
					cardInfo.id = dataInfo.id
					local newCardTemplate = self.cardTemplate[dataInfo.id]

					if newCardTemplate and newCardTemplate.template then
						if not newCardTemplate.instance then
							newCardTemplate.instance = UnityEngine.GameObject.Instantiate(newCardTemplate.template)
							cardInfo.instance = newCardTemplate.instance
						end

						if newCardTemplate.instance and cardInfo.stage ~= self.CARD_STAGE.IN_DESK_FACE then
							local eulerAngles = oldCardTemplate.instance.transform.eulerAngles
							local position = oldCardTemplate.instance.transform.position
							local cardCfg = LTConfig.DivinerDivinationCardConfig.GetConfig(dataInfo.id)
							local negativeValue = cardCfg and not cardCfg.IsPositive and 180 or 0

							newCardTemplate.instance.transform:SetPosition(position.x, position.y, position.z)
							newCardTemplate.instance.transform:SetLocalEulerAngles(eulerAngles.x, eulerAngles.y + negativeValue, eulerAngles.z + 180)

							cardInfo.stage = self.CARD_STAGE.IN_DESK_FACE
						end

						UnityEngine.GameObject.Destroy(oldCardTemplate.instance)

						oldCardTemplate.instance = nil
					end
				end
			end
		end
	end
end

function M:OnBeginPutCardToDesk(data)
	local dataTable = data:ToTable()
	local TarotAnimEndState = dataTable[1]

	if TarotAnimEndState == 6 and #dataTable == 2 then
		self.currentCardIndex = self.currentCardIndex + 1
		local index = self.currentCardIndex
		local timeData = dataTable[2]:ToTable()
		local cardPos = self.cardPos[self.currentCardIndex]

		if cardPos and timeData and #timeData == 9 then
			self:ShowCardInsInHand(self.currentCardIndex)

			local waitTime = timeData[cardPos]

			if self.chooseAuraCardTimer then
				self.chooseAuraCardTimer:Stop()

				self.chooseAuraCardTimer = nil
			end

			self.chooseAuraCardTimer = Timer.New(function ()
				self.chooseAuraCardTimer = nil

				self:ShowCardInsInDeskBack(index)
			end, waitTime):Start()
		end

		return
	end

	if TarotAnimEndState == 10 then
		self.branchSelectAnimComplete = true

		self:CheckOpenBranchSelectPanel()
	elseif TarotAnimEndState == 9 and #dataTable == 2 then
		self:StartPutBackIntoDeckTimer(dataTable[2]:ToTable())
	elseif TarotAnimEndState == 5 then
		self:DestroyAllCardIns()
	end
end

function M:StartPutBackIntoDeckTimer(timeData)
	if timeData and #timeData == 9 then
		if self.putBackIntoDeckCoroutine then
			coroutine.stop(self.putBackIntoDeckCoroutine)

			self.putBackIntoDeckCoroutine = nil
		end

		self.putBackIntoDeckCoroutine = coroutine.start(function ()
			for i = 1, 9 do
				coroutine.wait(timeData[i])

				local index = self.cardPosToIndex[i]

				if index and index > 0 then
					self:DestroyCardInsByIndex(index)
				end
			end

			self.putBackIntoDeckCoroutine = nil
		end)
	end
end

function M:ShowCardInsInHand(cardIndex)
	local cardInfo = self.currentCardSpread[cardIndex]

	if cardInfo then
		local cardTemplate = self.cardTemplate[cardInfo.id]

		if cardTemplate and cardTemplate.template then
			if not cardTemplate.instance then
				cardTemplate.instance = UnityEngine.GameObject.Instantiate(cardTemplate.template)
				cardInfo.instance = cardTemplate.instance
			end

			local cardBone = LX6.Utils.UnitUtils.NameToBone("Handr", MyPlayerManager.PlayerUnit)

			if not cardBone or gCS.LuaUtils.IsNull(cardBone) then
				print_error("找不到角色放置卡牌的骨骼！")
			end

			if cardBone and cardTemplate.instance then
				cardTemplate.instance.transform:SetParent(cardBone, false)
				cardTemplate.instance.transform:SetLocalPosition(Vector3.zero)
				cardTemplate.instance.transform:SetLocalEulerAngles(0, 0, 0)

				cardInfo.stage = self.CARD_STAGE.IN_HAND
			end
		end
	end
end

function M:ShowCardInsInDeskBack(cardIndex)
	local cardInfo = self.currentCardSpread[cardIndex]

	if cardInfo then
		local cardTemplate = self.cardTemplate[cardInfo.id]

		if cardTemplate and cardTemplate.template then
			if not cardTemplate.instance then
				cardTemplate.instance = UnityEngine.GameObject.Instantiate(cardTemplate.template)
			end

			if cardTemplate.instance and cardInfo.stage ~= self.CARD_STAGE.IN_DESK_BACK then
				cardTemplate.instance.transform:SetParent(nil, true)

				cardInfo.stage = self.CARD_STAGE.IN_DESK_BACK
			end
		end
	end
end

function M:DestroyAllCardIns()
	if self.currentCardSpread then
		for i = 1, #self.currentCardSpread do
			local cardInfo = self.currentCardSpread[i]

			if cardInfo then
				local cardTemplate = self.cardTemplate[cardInfo.id]

				if cardTemplate.instance then
					UnityEngine.GameObject.Destroy(cardTemplate.instance)

					cardTemplate.instance = nil
				end
			end
		end
	end

	self.currentCardSpread = nil
end

function M:DestroyCardInsByIndex(index)
	if self.currentCardSpread then
		local cardInfo = self.currentCardSpread[index]

		if cardInfo then
			local cardTemplate = self.cardTemplate[cardInfo.id]

			if cardTemplate.instance then
				UnityEngine.GameObject.Destroy(cardTemplate.instance)

				cardTemplate.instance = nil
				cardInfo.instance = nil
			end
		end
	end
end

function M:InitReactionMotion()
	self.reactionMap = {}

	for i = 0, ReactionConfig.count - 1 do
		local cfg = ReactionConfig.LoadAt(i)

		if cfg.SignalType ~= ReactionConfig.SignalTypeType.None then
			local collection = self.reactionMap[cfg.SignalType]

			if not collection then
				collection = {}
				self.reactionMap[cfg.SignalType] = collection
			end

			if cfg.NPCGameplaySignal > 0 then
				local signals = collection[cfg.CustomerType]

				if not signals then
					signals = {}
					collection[cfg.CustomerType] = signals
				end

				table.insert(signals, cfg.NPCGameplaySignal)
			end
		end
	end
end

function M:GetNPCReactionSignal(type)
	if self.curCustomerInfo and self.curCustomerInfo.DemandId > 0 then
		local demandCfg = DemandConfig.GetConfig(self.curCustomerInfo.DemandId)

		if demandCfg then
			local collection = self.reactionMap[type]

			if collection then
				local signals = collection[demandCfg.ReactionType]
				signals = signals or collection[0]

				if signals then
					if #signals == 1 then
						self.lastReactionId = signals[1]

						return self.lastReactionId
					elseif #signals > 1 then
						local temp = {}

						for _, signal in pairs(signals) do
							if signal ~= self.lastReactionId then
								table.insert(temp, signal)
							end
						end

						if #temp == 0 then
							return self.lastReactionId
						elseif #temp == 1 then
							self.lastReactionId = temp[1]

							return self.lastReactionId
						else
							self.lastReactionId = array.random(temp)

							return self.lastReactionId
						end
					end
				end
			end
		end
	end

	return nil
end

function M:SendPlayerEnterDiviner()
	self:CommonSendPlayerSignal(ReactionConfig.Enter)
end

function M:SendPlayerCallNpc()
	self:CommonSendPlayerSignal(ReactionConfig.Call)
end

function M:SendPlayerCallNextNpc()
	self:CommonSendPlayerSignal(ReactionConfig.CallNext)
end

function M:SendPlayerFinishDiviner()
	self:CommonSendPlayerSignal(ReactionConfig.Finish)
end

function M:CommonSendPlayerSignal(Id)
	local cfg = ReactionConfig.GetConfig(Id)

	if cfg and cfg.GameplaySignal > 0 then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, cfg.GameplaySignal)
	end
end

function M:SendNPCEnterDiviner()
	self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Enter)
end

function M:SendNPCWaitDiviner()
	self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Wait)
end

function M:SendNPCAgree()
	self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Agree)
end

function M:SendNPCNotAgree()
	self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.NotAgree)
end

function M:SendNPCBattle()
	if not self.sendStandUp then
		self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Battle)

		self.needAskBattle = true
		self.sendStandUp = true
	end
end

function M:SendNPCSuccess()
	self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Success)
end

function M:SendNPCFail()
	if not self.sendStandUp then
		self.sendStandUp = true

		self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Fail)
	end
end

function M:CommonSendNpcSignal(type)
	local signal = self:GetNPCReactionSignal(type)

	if signal and signal > 0 and self.curCustomerInfo then
		local unit = SceneDataMgr.GetUnit(self.curCustomerInfo.AgentId)

		if unit then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
		end
	end
end

function M:OnDivinerAgentDoAttractInternalTest(pid)
	self:OnDivinerAgentDoAttractInternal(ulong.new(pid, 0))
end

function M:OnDivinerAgentDoAttractInternal(pid)
	if pid then
		local unit = SceneDataMgr.GetUnit(pid)

		if unit and not unit.IsDead and not unit.IsDestroyed then
			self:RequestToDemandStage(pid)
		end
	else
		print_error("DivinerManager 兴趣点触发了下一位顾客，但pid无效 ")
	end
end

function M:EnterDivinerGame(demandId, pid, autoFinish, demandWaitGuide, persuadeWaitGuide)
	if not self.reactionMap then
		self:InitReactionMotion()
	end

	if self.curPlayState == self.PLAY_STATE.NONE then
		self.dropInfos = {}
		self.dropQueue = {}

		if demandId and demandId > 0 and pid then
			self.spoonDemandId = demandId
			self.spoonPid = pid
			self.spoonAutoFinish = autoFinish
			self.spoonDemandWaitGuide = demandWaitGuide
			self.spoonPersuadeWaitGuide = persuadeWaitGuide
			self.spoonNeedShowToDemand = false
		else
			self.spoonDemandId = nil
			self.spoonPid = nil
			self.spoonAutoFinish = nil
			self.spoonDemandWaitGuide = nil
			self.spoonPersuadeWaitGuide = nil
			self.spoonNeedShowToDemand = nil
		end

		self.curPlayState = self.PLAY_STATE.WAIT_SERVER_RES

		if self.spoonPid then
			gClientToGameDelegate:AskEnterDivinerGame().Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gClientToGameDelegate:AskStartDivinerGameWithDemand(pid, demandId).Callback = function (startErr, data)
						if startErr == LTConfig.MessageConfig.Ok then
							self:SuccessEnterSpoonDivinerGame(data)
						else
							self.curPlayState = self.PLAY_STATE.NONE

							gDisplayMessageMgr:DisplayServerMessageId(startErr)
						end
					end
				else
					self.curPlayState = self.PLAY_STATE.NONE

					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		else
			gClientToGameDelegate:AskDivinerCheckSpecialEvent().Callback = function (err, data)
				if err == LTConfig.MessageConfig.Ok then
					if data then
						self.curPlayState = self.PLAY_STATE.NONE
					else
						self:AskEnterDivinerGame()
					end
				else
					self.curPlayState = self.PLAY_STATE.NONE

					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		end
	else
		print_error("当前正在占卜师玩法中，不能重复进入！")
	end
end

function M:SuccessEnterSpoonDivinerGame(customerInfo)
	self:SwitchToDivinerFreeCamera()

	self.curPlayState = self.PLAY_STATE.DEMAND
	self.sendStandUp = false

	gPanelManager:CheckShow(gPanelId.DIVINATION_FAKE_DIALOG)
	self:SendPlayerEnterDiviner()
	self:StartDivinerTask()

	self.curCustomerId = customerInfo.AgentId

	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_GAMEPLAY_START")

	self.agentStartTime = gLuaDataManager.serverTime
	self.curCustomerInfo = customerInfo
	self.curAttitude = customerInfo.Attitude

	self:StartDemandAIDialog()
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_SESSION_START")

	local state = LTConfig.UnitStateConfig.OnlyLook

	gCS.UnitStateMgr:AddClientState(MyPlayerManager.PlayerUnit.Pid, state, 999999)
end

function M:AskEnterDivinerGame()
	gClientToGameDelegate:AskEnterDivinerGame().Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self:SwitchToDivinerFreeCamera()
			self:ShowFakeDialogPanel()

			local state = LTConfig.UnitStateConfig.OnlyLook

			gCS.UnitStateMgr:AddClientState(MyPlayerManager.PlayerUnit.Pid, state, 999999)
			gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_GAMEPLAY_START")
		else
			self.curPlayState = self.PLAY_STATE.NONE

			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:ShowFakeDialogPanel()
	self.curPlayState = self.PLAY_STATE.CALL_NPC

	gPanelManager:CheckShow(gPanelId.DIVINATION_FAKE_DIALOG)
	self:SendPlayerEnterDiviner()
	self:StartDivinerTask()
end

function M:RequestToDemandStage(agentId)
	if self.curPlayState ~= self.PLAY_STATE.CALL_NPC then
		return
	end

	self.curPlayState = self.PLAY_STATE.WAIT_SERVER_RES
	self.curCustomerId = agentId
	self.sendStandUp = false

	gClientToGameDelegate:AskStartDivinerGame(agentId).Callback = function (err, customerInfo)
		if err == LTConfig.MessageConfig.Ok then
			self.curPlayState = self.PLAY_STATE.DEMAND
			self.agentStartTime = gLuaDataManager.serverTime

			if self.curCustomerId == customerInfo.AgentId then
				self.curCustomerInfo = customerInfo
				self.curAttitude = customerInfo.Attitude

				self:StartDemandAIDialog()
			else
				print_error("DivinerManager AskStartDivinerGame 回传的data中的agentId和请求时使用的agentId不符！")
			end

			gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_SESSION_START")
		else
			self.curPlayState = self.PLAY_STATE.NONE

			gDisplayMessageMgr:DisplayServerMessageId(err)
			self:FinishDivinerGame(true)
		end
	end
end

function M:StartDemandAIDialog()
	self.curPlayState = self.PLAY_STATE.DEMAND
	self.curClues = {}
	self.dropQueue = {}
	self.demandFinished = false
	self.persuadeSuccess = false
	self.waitGuideTimer = self.spoonDemandWaitGuide
	self.dialogTimeChecked = false
	self.startTimeChecked = false
	self.needAskBattle = false

	if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
		self.fakeDialogPanel:StartDemandOrPersuadeStage({
			agentId = self.curCustomerInfo.AgentId,
			stage = self.CHAT_STAGE.DEMAND
		}, function ()
			self.dialogTimeChecked = true

			self:CommonStartTimeCheck()
		end)
	elseif self.spoonPid then
		self.spoonNeedShowToDemand = true
	end

	self:ChangeTaskTarget()
end

function M:GuideToCheckTimer()
	self.waitGuideTimer = false

	if self.spoonPid then
		self:CommonStartTimeCheck()
	end
end

function M:CommonStartTimeCheck()
	if not self.waitGuideTimer and self.dialogTimeChecked and not self.startTimeChecked then
		self.startTimeChecked = true
		local langType = self:GetCurLanguageAbbreviation() or "CN"

		gClientToGameDelegate:AskDivinerStartTimeCheck(langType).Callback = function (err, endTime)
			if err == LTConfig.MessageConfig.Ok then
				if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
					gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
				end

				gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_COUNT_DOWN, {
					Param = {
						isIncrease = false,
						time = endTime - gLuaDataManager.serverTime
					}
				})
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)
				gDivinerManager:FinishDivinerGame(true)
			end
		end
	end
end

function M:CloseChatCountDown()
	gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
end

function M:GetDemandClueList()
	local clueData = {}

	if self.curCustomerInfo and self.curCustomerInfo.DemandId and self.curCustomerInfo.DemandId > 0 then
		local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(self.curCustomerInfo.DemandId)

		if demandCfg then
			table.insert(clueData, {
				occur = true,
				isTips = true,
				id = self.curCustomerInfo.DemandId
			})

			if #demandCfg.Clues > 0 then
				for _, v in pairs(demandCfg.Clues) do
					table.insert(clueData, {
						isTips = false,
						id = v,
						occur = self.curClues[v]
					})
				end
			end
		end
	end

	return clueData
end

function M:SendDemandAIMessage(message, agentId, stage)
	local langType = self:GetCurLanguageAbbreviation()

	if self.curCustomerId and not string.is_null_or_empty(message) and langType then
		gClientToGameDelegate:AskDivinerRequestAppeal(self.curCustomerId, message, langType).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
					self.fakeDialogPanel:OnSyncAIChatError({
						syncError = false,
						error = 0,
						agentId = agentId,
						stage = stage
					})
				end
			end
		end

		return true
	end

	return false
end

function M:CheckDemandAIChatFinish()
	if self.curPlayState == self.PLAY_STATE.DEMAND and self.demandFinished then
		self:StartBranchSelect()
	end
end

function M:CheckDemandAIChatFailFinish()
	if self.curPlayState == self.PLAY_STATE.DEMAND and self.demandFinished then
		self:FinishAndToReward()
	end
end

function M:TriggerDemandAIChatFinish()
	self.demandFinished = true
end

function M:StartBranchSelect()
	self.curPlayState = self.PLAY_STATE.BRANCH
	local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(self.curCustomerInfo.DemandId)

	if demandCfg and demandCfg.TarotStartDialogId and demandCfg and demandCfg.TarotStartDialogId > 0 then
		self.fakeDialogPanel:ShowFakeDialogById(demandCfg.TarotStartDialogId, function ()
			self:StartBranchSelectInternal({
				dialogId = 0,
				demandId = self.curCustomerInfo.DemandId
			})
		end)
	else
		self:StartBranchSelectInternal({
			dialogId = 0,
			demandId = self.curCustomerInfo.DemandId
		})
	end

	self:ChangeTaskTarget()
end

function M:SelectBranch(branchId)
	if not branchId or branchId == 0 then
		self:FinishDivinerGame(true)
	end

	self.curBranchId = branchId
	self.curDemandPath = 0
	local path = nil
	local branchConfig = LTConfig.DivinerBranchConfig.GetConfig(self.curBranchId)

	if branchConfig and branchConfig.DemandBranch then
		local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(self.curCustomerInfo.DemandId)

		if demandCfg and demandCfg.Path and branchConfig.DemandBranch < #demandCfg.Path then
			path = demandCfg.Path[branchConfig.DemandBranch + 1]
		end
	end

	if path then
		gClientToGameDelegate:AskDivinerChooseBranch(self.curCustomerId, path).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				self.curDemandPath = path

				self:StartPersuade()
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)
				self:FinishDivinerGame(true)
			end
		end
	else
		self:FinishDivinerGame(true)
	end
end

function M:StartPersuade()
	self.curPlayState = self.PLAY_STATE.PERSUADE
	self.persuadeResult = nil
	self.persuadeFinished = false
	self.waitGuideTimer = self.spoonPersuadeWaitGuide
	self.dialogTimeChecked = false
	self.startTimeChecked = false

	if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
		self.fakeDialogPanel:StartDemandOrPersuadeStage({
			agentId = self.curCustomerInfo.AgentId,
			stage = self.CHAT_STAGE.PERSUADE,
			branchId = self.curBranchId,
			persuadeId = self.curDemandPath
		}, function ()
			self.dialogTimeChecked = true

			self:CommonStartTimeCheck()
		end)
	end

	self:ChangeTaskTarget()
	self:SwitchToDivinerFreeCamera()
end

function M:TriggerPersuadeAIChatFinish()
	self.persuadeFinished = true
end

function M:SendPersuadeAIMessage(message, agentId, stage)
	local langType = self:GetCurLanguageAbbreviation()

	if self.curCustomerId and not string.is_null_or_empty(message) and langType then
		gClientToGameDelegate:AskDivinerPersuade(self.curCustomerId, message, langType).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
					self.fakeDialogPanel:OnSyncAIChatError({
						syncError = false,
						error = 0,
						agentId = agentId,
						stage = stage
					})
				end
			end
		end

		return true
	end

	return false
end

function M:CheckPersuadeAIChatFinish()
	if self.curPlayState == self.PLAY_STATE.PERSUADE and self.persuadeFinished then
		self:FinishAndToReward()
	end
end

function M:FinishAndToReward()
	if self.PLAY_STATE == self.PLAY_STATE.BRANCH or self.PLAY_STATE == self.PLAY_STATE.PERSUADE then
		self:StartPutBackIntoDeck()
	end

	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_SESSION_END")

	self.curPlayState = self.PLAY_STATE.REWARD

	if self.fakeDialogPanel and self.fakeDialogPanel then
		self.fakeDialogPanel:TriggerIntoRewardStage()
	end

	self:ChangeTaskTarget()
end

function M:ChangeToCallNpcState()
	self.curPlayState = self.PLAY_STATE.CALL_NPC

	if self.fakeDialogPanel and self.fakeDialogPanel then
		self.fakeDialogPanel:TriggerIntoCallNpcStage()
	end

	self:ChangeTaskTarget()
end

function M:PopupNextCustomerDropInfo()
	if #self.dropQueue > 0 then
		local id = self.dropQueue[1]

		table.remove(self.dropQueue, 1)

		return self.dropInfos[id]
	end

	return nil
end

function M:PushNextCustomerDropInfo(customerId)
	table.insert(self.dropQueue, customerId)
end

function M:IsPersuadeSuccess()
	if self.persuadeSuccess then
		return true
	end

	return false
end

function M:FinishPersuade(result)
	self.persuadeResult = result
	self.persuadeSuccess = self.persuadeResult == 1
	local pathCfg = LTConfig.DivinerPathConfig.GetConfig(self.curDemandPath)
	local review = nil

	if pathCfg then
		if self.persuadeResult == 1 then
			review = array.random(pathCfg.SuccessReview)
		elseif self.persuadeResult == 2 then
			review = array.random(pathCfg.FailReview)
		end
	end

	local info = nil

	if self.dropInfos[self.curCustomerId] then
		info = self.dropInfos[self.curCustomerId]
	else
		info = {
			agentId = self.curCustomerId,
			money = 0,
			exp = 0,
			result = result,
			useTime = gLuaDataManager.serverTime - self.agentStartTime
		}
		self.dropInfos[self.curCustomerId] = info
	end

	info.review = review or 0
end

function M:FinishDivinerGame(sendFailSignal)
	gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, LTConfig.UnitStateConfig.OnlyLook)

	self.curPlayState = self.PLAY_STATE.NONE

	self:SwitchToNormalFreeLook()

	gClientToGameDelegate:AskLeaveDivinerGame().Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	gClientToGameDelegate:AskDivinerTriggerResult()
	self:DestroyAllCardIns()
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_GAMEPLAY_END")
	gPanelManager:Close(gPanelId.DIVINATION_FAKE_DIALOG)
	gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	self:ShowTotalReward()
	self:SendPlayerFinishDiviner()
	self:FinishDivinerTask()

	if sendFailSignal and self.curPlayState ~= self.PLAY_STATE.CALL_NPC then
		self:SendNPCFail()
	end
end

function M:ShowTotalReward()
	local totalMoney = 0
	local totalPerson = 0
	local totalSuccess = 0

	for k, v in pairs(self.dropInfos) do
		totalMoney = totalMoney + v.money
		totalPerson = totalPerson + 1

		if v.result == 1 then
			totalSuccess = totalSuccess + 1
		end
	end

	self.dropInfos = nil
	self.dropQueue = nil

	if totalPerson > 0 or totalSuccess > 0 or totalMoney > 0 then
		local popListData = {}

		table.insert(popListData, {
			leftContent = LTConfig.DivinerConfig.PopupOrder,
			rightContent = totalPerson
		})
		table.insert(popListData, {
			leftContent = LTConfig.DivinerConfig.PopupSuccess,
			rightContent = totalSuccess
		})
		table.insert(popListData, {
			leftContent = LTConfig.DivinerConfig.PopupTotalMoney,
			rightContent = totalMoney
		})

		local popData = {
			mainTitle = LTConfig.DivinerConfig.PopupMainTitle,
			listData = popListData
		}

		gNewPopupManager:PushPopup(LTConfig.PopupConfig.DivinerReward, popData)
	end
end

function M:OnSyncDivinerCustomerInfo(customerInfo)
	if self.curPlayState == self.PLAY_STATE.NONE then
		gClientToGameDelegate:AskLeaveDivinerGame().Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end

	if customerInfo and self.agentId == customerInfo.AgentId then
		self.curCustomerInfo = customerInfo
	end
end

function M:OnSyncDivinerAIError(agentId, stage, error)
	if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
		self.fakeDialogPanel:OnSyncAIChatError({
			syncError = true,
			agentId = agentId,
			stage = stage,
			error = error
		})

		if self.curPlayState == self.PLAY_STATE.PERSUADE and self.persuadeFinished then
			self.fakeDialogPanel:TriggerStartDelayToNextStage()
		end

		if self.curPlayState == self.PLAY_STATE.DEMAND and self.demandFinished then
			self.fakeDialogPanel:TriggerStartDelayToNextStage()
		end
	end
end

function M:OnSyncDivinerAIMessage(info)
	if self.isDebug then
		print_notice(string.format("DivinerManager OnSyncDivinerAIMessage stage %s result %s msg %s clue %s attitude %s persuasion %s", tostring(info.Stage), tostring(info.Result), tostring(info.Msg), tostring(info.ClueId), tostring(info.Attitude), tostring(info.Persuasion)))
	end

	local lastAttitude = self.curAttitude
	self.curAttitude = info.Attitude
	self.curEndReason = info.EndReason
	local canSend = true

	if self.curPlayState == self.PLAY_STATE.DEMAND then
		if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
			local waitFunc = nil

			if self.demandFinished then
				function waitFunc()
					if self.demandFinished then
						self.fakeDialogPanel:TriggerStartDelayToNextStage()
					end
				end
			end

			self.fakeDialogPanel:OnSyncAIChatMessage({
				agentId = info.AgentId,
				stage = info.Stage,
				message = info.Msg,
				canInput = not self.demandFinished,
				attitude = self.curAttitude,
				waitFunc = waitFunc
			})

			if info.Stage == self.CHAT_STAGE.DEMAND then
				if info.ClueId > 0 then
					self.curClues[info.ClueId] = true

					self.fakeDialogPanel:RefreshClueList()
				end

				if self.demandFinished then
					canSend = false

					if self.curEndReason == self.END_REASON.NORMAL_FAIL then
						self:SendNPCFail()
					elseif self.curEndReason == self.END_REASON.BATTLE_FAIL then
						self:SendNPCBattle()
					elseif self.curEndReason == self.END_REASON.TIME_OUT then
						self:SendNPCFail()
					end
				elseif self.curEndReason == self.END_REASON.NEXT_STAGE then
					self:TriggerDemandAIChatFinish()
					self.fakeDialogPanel:DemandFinished()
					self:CloseChatCountDown()
				elseif self.curEndReason == self.END_REASON.NORMAL_FAIL then
					self:TriggerDemandAIChatFinish()
					self.fakeDialogPanel:DemandNormalFailed()
					self:CloseChatCountDown()
				elseif self.curEndReason == self.END_REASON.BATTLE_FAIL then
					self:TriggerDemandAIChatFinish()
					self.fakeDialogPanel:DemandBattleFailed()
					self:CloseChatCountDown()
				elseif self.curEndReason == self.END_REASON.TIME_OUT then
					self:TriggerDemandAIChatFinish()
					self.fakeDialogPanel:DemandTimeOutFailed()
					self:CloseChatCountDown()
				end
			end
		end
	elseif self.curPlayState == self.PLAY_STATE.PERSUADE then
		local persuadeWaitFunc = nil

		if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
			if info.Stage == self.CHAT_STAGE.PERSUADE then
				if info.Result > 0 then
					self:FinishPersuade(info.Result)
				end

				if self.persuadeFinished then
					function persuadeWaitFunc()
						if self.persuadeFinished then
							self.fakeDialogPanel:TriggerStartDelayToNextStage()
						end
					end

					canSend = false

					if self.curEndReason == self.END_REASON.NEXT_STAGE then
						self:SendNPCSuccess()
					elseif self.curEndReason == self.END_REASON.NORMAL_FAIL then
						self:SendNPCFail()
					elseif self.curEndReason == self.END_REASON.BATTLE_FAIL then
						self:SendNPCBattle()
					elseif self.curEndReason == self.END_REASON.TIME_OUT then
						self:SendNPCFail()
					end
				elseif self.curEndReason == self.END_REASON.NEXT_STAGE then
					self:TriggerPersuadeAIChatFinish()
					self.fakeDialogPanel:PersuadeFinished()
					self:CloseChatCountDown()
				elseif self.curEndReason == self.END_REASON.NORMAL_FAIL then
					self:TriggerPersuadeAIChatFinish()
					self.fakeDialogPanel:PersuadeNormalFailed()
					self:CloseChatCountDown()
				elseif self.curEndReason == self.END_REASON.BATTLE_FAIL then
					self:TriggerPersuadeAIChatFinish()
					self.fakeDialogPanel:PersuadeBattleFailed()
					self:CloseChatCountDown()
				elseif self.curEndReason == self.END_REASON.TIME_OUT then
					self:TriggerPersuadeAIChatFinish()
					self.fakeDialogPanel:PersuadeTimeOutFailed()
					self:CloseChatCountDown()
				end
			end

			self.fakeDialogPanel:OnSyncAIChatMessage({
				agentId = info.AgentId,
				stage = info.Stage,
				message = info.Msg,
				canInput = not self.persuadeFinished,
				attitude = self.curAttitude,
				waitFunc = persuadeWaitFunc
			})
		end
	end

	if canSend then
		if self.curAttitude <= lastAttitude then
			self:SendNPCNotAgree()
		elseif lastAttitude < self.curAttitude then
			self:SendNPCAgree()
		end
	end
end

function M:GetCurLanguageAbbreviation()
	local langIdx = LX6.Engine.ProfileManager.languageProfile.textLanguage
	local langCfg = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(langIdx)

	return langCfg and langCfg.Abbreviation
end

function M:OnDivinerDrop(msg)
	if self.curCustomerId then
		local money = 0
		local exp = 0

		for k, v in pairs(msg.Reward) do
			money = money + v.Money

			if v.JobExpInfo and v.JobExpInfo[LTConfig.UrbanJobJobClassConfig.Diviner] then
				exp = exp + v.JobExpInfo[LTConfig.UrbanJobJobClassConfig.Diviner]
			end
		end

		local info = nil

		if self.dropInfos[self.curCustomerId] then
			info = self.dropInfos[self.curCustomerId]
		else
			info = {
				agentId = self.curCustomerId,
				review = 0,
				result = 0,
				useTime = gLuaDataManager.serverTime - self.agentStartTime
			}
			self.dropInfos[self.curCustomerId] = info
		end

		info.money = money
		info.exp = exp

		self:PushNextCustomerDropInfo(self.curCustomerId)
	end

	if self.curPlayState == self.PLAY_STATE.REWARD and self.fakeDialogPanel and self.fakeDialogPanel.isShow then
		self.fakeDialogPanel:CheckShowReward()
	end
end

function M:SwitchToDivinerFreeCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(LTConfig.DivinerConfig.FreeLockActionStatusId, LTConfig.DivinerConfig.FreeLockActionSwitchTime, nil, 5)
end

function M:SwitchToCardFreeCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(LTConfig.DivinerConfig.TarotFreeLockActionStatusId, LTConfig.DivinerConfig.TarotFreeLockActionSwitchTime, nil, 5)
end

function M:SwitchToNormalFreeLook()
	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(LTConfig.DivinerConfig.FreeLockActionSwitchTime, nil, 5)
end

function M:StartDivinerTask()
	return
end

function M:FinishDivinerTask()
	return
end

function M:ChangeTaskTarget()
	local desID = nil

	if self.curPlayState == self.PLAY_STATE.CALL_NPC then
		desID = LTConfig.DivinerConfig.CustomerAcquisitionStageGoal
	elseif self.curPlayState == self.PLAY_STATE.DEMAND then
		desID = LTConfig.DivinerConfig.RequirementAnalysisStageGoal
	elseif self.curPlayState == self.PLAY_STATE.BRANCH then
		desID = LTConfig.DivinerConfig.DivinateStageGoal
	elseif self.curPlayState == self.PLAY_STATE.PERSUADE and self.curDemandPath and self.curDemandPath > 0 then
		local pathCfg = LTConfig.DivinerPathConfig.GetConfig(self.curDemandPath)
		desID = pathCfg and pathCfg.StageDestination
	end

	if desID and self.fakeDialogPanel and self.fakeDialogPanel.isShow then
		self.fakeDialogPanel:RefreshTaskDes(desID)
	end
end

gDivinerManager = M
