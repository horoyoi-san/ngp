-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\Diviner\DivinerManager.lua
-- Decompiled from: 00557_DivinerManager.lua_a12cd56fe16f.luajit

local M = gDivinerManager or {}
M.IsInit = M.IsInit or false
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr
local ReactionConfig = LTConfig.DivinerDivinateReactionConfig
local DemandConfig = LTConfig.DivinerDemandConfig

M.OnInit = function(self)
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
		["FX\\x93Si\\x81\\xd9xL[]i"] = 3,
		["RY~"] = 4,
		["FX\\x93Si\\x81\\xd9xH[]g"] = 2,
		["\\xf0\\xf5+5?\n\\xd5"] = 1
	}
	self.PLAY_STATE = {
		["\t\\xd0L\\xab\\xd2\\x9e\n\\xd4\\xcd\\xd4Q\\xc8"] = 2,
		[".m\\xa6\\xaf\\xb1e"] = 7,
		["\\x9b\\x947\\x98_\\xda"] = 6,
		["8m\\xbc\\xaf\\xade"] = 4,
		["\\x88\\x90)\\x87U\\xce"] = 3,
		[">z\\xb0\\xa0\\xa0i"] = 5,
		["T\rS~"] = 1
	}
	self.CHAT_STAGE = {
		["\\x9b\\x947\\x98_\\xda"] = 1,
		["8m\\xbc\\xaf\\xade"] = 0
	}
	self.END_REASON = {
		["\\xb1Y\\xb1~\\xff\\x83\\x95"] = 2,
		["\\x9f\\x98(\\x8eU\\xcb"] = 4,
		["\\xbdT\\xb8~\\xff\\x83\\x95"] = 3,
		["}\\xf6\\x89\\xbb;\\x8c%\\xee\\xcd"] = 1
	}
	self.curPlayState = self.PLAY_STATE.NONE
	self.isDebug = false
	self.listenerAdded = false
	self.eventHandlers = {
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = function (_, data)
			self:OnGameplaySignal(data)
		end,
		[gEventConstants.ON_YANJIE_DETAIL_CONTENT_CLOSE] = function (_, data)
			self:OnYanJieDetailContentClosed()
		end,
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = function (_, switchSceneEventParams)
			local switchType = switchSceneEventParams.switchSceneType

			if gSwitchSceneType.Reconnect >= switchType and self.curPlayState == self.PLAY_STATE.NONE then
				self:FinishDivinerGameBeforeSwitchScene()
			end
		end
	}

	self:AddEventListener()

	self.IsInit = true
	self.DAN_MU_EVENT = {
		["\\xe6R-\\xd4#\\xb0@\\xa8Z\\xb5\\xb2"] = 8,
		["\\x92*\\xff\\xafF)\\xc2^?\\xd8\\xfc,EY\\xd92\\x83\\xde"] = 12,
		["VTڸ\\x967\\xbf\\xc4\\xed"] = 1,
		["'/-\\xe5}\\x9c\\xc8 \\xa1\"\\xe3\\xcd\\xe9a\\xef"] = 9,
		["w\\x88\\x83\\xaaݴ\\xc0\\xba*\\xb1%"] = 15,
		["\\x86*\\xe0\\xbd],\\xf9K\\xdc\\xe7&TY\\xf5%\\xb3\\xdc\r"] = 5,
		["\\x9e24:j\\xa2P\\xcc2\\xbf\\xbc"] = 20,
		["3\\x86䥦\\xfc\\xaf\\xb5\\x86\\xe2\\xf1'ř%\\x8c\\xf1"] = 18,
		["p\\xf51\\xe5'6;\\xcan.\\xeaM\\x8dN\\xc3\\xe2"] = 19,
		["vUn\\xacq\\xe3G;xtfo\\xc63z\\xe2O"] = 13,
		["d\\xf95\\xff<6+\\xc6^4\\xdcF\\x893M\\xd3\\xf2"] = 17,
		["PV۸\\xbb\\xb0\\xca\\xe3"] = 6,
		["vUn\\xacq\\xe5\\5~dqy\\xc63z\\xe2O"] = 11,
		["w\\x88\\x83\\xaaݴ\\xc0\\xa56\\xb7=#"] = 10,
		["EN~zZ!,"] = 3,
		["vUn\\xacq\\xf0\\5ovy\\xc63z\\xe2O"] = 14,
		["\\xe3\\x9f\\xed\\xd9\\xff\\x8b\\xee\\x873;"] = 7,
		["3/2\\xf7f\\x99\\xf31\\x97)\\xe7\\xfb\\xeaq\\xff"] = 16,
		["BAxl\\!,"] = 21,
		["\\xe3\\x9f\\xed\\xd9\\xe3\\x83\\xe8\\xbd58"] = 4,
		["\\x99=2,l\\xa2P\\xcc2\\xbf\\xbc"] = 2
	}
	self.SPIRIT_TO_DAN_MU_EVENT = {
		[15020967] = 22,
		[15020968] = 23,
		[15020997] = 24,
		[15020992] = 25,
		[15021040] = 26,
		[15021023] = 27,
		[15021021] = 28,
		[15021017] = 29,
		[15020989] = 30,
		[15021025] = 31,
		[15021044] = 32,
		[15021041] = 33,
		[15021043] = 34,
		[15021045] = 35,
		[15021039] = 36
	}
end

M.OnGameplaySignal = function(self, data)
	if self.isDebug then
		print_notice("DivinerManager OnGameplaySignal " .. tostring(data and data:GetCfgId()))
	end

	local signalId = data:GetCfgId()

	if signalId ~= 3102 then
		if self.curPlayState ~= self.PLAY_STATE.CALL_NPC then
			local pid = data:GetPid()

			self:OnDivinerAgentDoAttractInternal(pid)
			self:SendCustomerSitLiveChatEvent()
			FrameTimer.New(function ()
				gDivinerManager:SendNPCEnterDiviner()
			end, 1):Start()
		end
	elseif signalId ~= 3103 then
		self.curWaitQueuePid = data:GetPid()
	elseif signalId ~= 3104 then
		if self.needAskBattle then
			self.needAskBattle = false

			gClientToGameDelegate:AskDivinerEnterBattle().Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end

			gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
				["PNkgO:!"] = "R\\x84\\x85C\\xab\\xf1ٞ\\xc5\\xc8\\xc1T\\x9f\\x99]\\xba\\xf6\\xc8\\xdf\\xd3O\\x9e\\x94G\\xb1\\xfc",
				entityInstanceId = self.spoonInstanceId
			})
		end
	elseif signalId ~= 3105 then
		gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
			["PNkgO:!"] = "0\\xc2\\xccf33|n9ZumI\\xc0|\\xa7ډX6\\xef\\xceR\\x9fT\\xce+\\xce\\xd4k",
			entityInstanceId = self.spoonInstanceId
		})
	elseif signalId ~= 3106 then
		if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
			self.fakeDialogPanel:ActiveCallNpcBtnState()
		end
	elseif signalId ~= 3107 then
		self.branchSelectAnimComplete = true

		self:CheckOpenBranchSelectPanel()
	elseif signalId ~= 3108 then
		self:DestroyAllCardIns()
	end
end

M.AddEventListener = function(self)
	if not self.listenerAdded then
		self.listenerAdded = true

		gMessageManager:RegisterEventHandlers(self.eventHandlers)
	end
end

M.RemoveEventListener = function(self)
	if self.listenerAdded then
		self.listenerAdded = false

		gMessageManager:UnregisterEventHandlers(self.eventHandlers)
	end
end

M.StartBranchSelectInternal = function(self, data)
	self.branchSelectAnimComplete = false
	self.waitOpenBranchData = data

	self:StartPrepareCardAnim()

	local showDialog = false

	if data.dialogId and data.dialogId <= 0 then
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

M.EndBranchSelect = function(self, data)
	self.waitOpenBranchData = nil
	self.branchSelectDialogComplete = false
	self.branchSelectAnimComplete = false

	self:SelectBranch(data.branchId)
end

M.CheckOpenBranchSelectPanel = function(self)
	if self.branchSelectDialogComplete and self.branchSelectAnimComplete and self.waitOpenBranchData then
		local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(self.waitOpenBranchData.demandId)

		if demandCfg then
			local TarotInitialOrder = demandCfg.TarotInitialOrder
			local needAcceptBranchIds = demandCfg.BranchId

			if not needAcceptBranchIds or needAcceptBranchIds ~= 0 then
				print_error_without_stack("占卜师分支配置错误，塔罗牌无有效分支数据！demandId Id : " .. tostring(self.waitOpenBranchData.demandId))

				return
			end

			if not TarotInitialOrder or #TarotInitialOrder == 4 then
				print_error_without_stack("占卜师分支配置错误，塔罗牌初始顺序数据无效！demandId Id : " .. tostring(self.waitOpenBranchData.demandId))

				return
			end

			gDivinerManager.divinerTable:EnableCamera()
			Timer.New(function ()
				if self.curPlayState ~= self.PLAY_STATE.BRANCH then
					gPanelManager:CheckShow(gPanelId.DIVINATIONV_PANEL, self.waitOpenBranchData)
				end
			end, 0.5):Start()
		end
	end
end

M.StartPrepareCardAnim = function(self)
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

M.StartPutBackIntoDeck = function(self)
	if self.currentCardSpread then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.TarotWait, MuGenStates.Logic.GameplayEventParam1.StateEnd)
	end
end

M.LoadAndInstantiateCard = function(self, cardIds)
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

M.ExecuteCardBind = function(self, cardIndex, isBind, destroy)
	if self.curPlayState ~= self.PLAY_STATE.NONE then
		return
	end

	if destroy then
		self:DestroyCardInsByIndex(cardIndex)
	elseif isBind then
		self:ShowCardInsInHand(cardIndex)
	else
		self:ShowCardInsInDeskBack(cardIndex, false, nil, true)
	end
end

M.ShowCardInsInHand = function(self, cardIndex)
	local cardInfo = self.currentCardSpread[cardIndex]

	if cardInfo then
		local cardTemplate = self.cardTemplate[cardInfo.id]

		if cardTemplate and cardTemplate.template then
			if not cardTemplate.instance or gClientUtils.IsNil(cardTemplate.instance) then
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

M.ShowCardInsInDeskBack = function(self, cardIndex, face, newId, positive)
	local cardInfo = self.currentCardSpread[cardIndex]

	if cardInfo then
		if newId and newId == cardInfo.id then
			self:DestroyCardInsByIndex(cardIndex)
		end

		local cardTemplate = self.cardTemplate[cardInfo.id]

		if cardTemplate and cardTemplate.template then
			if not cardTemplate.instance or gClientUtils.IsNil(cardTemplate.instance) then
				cardTemplate.instance = UnityEngine.GameObject.Instantiate(cardTemplate.template)
			end

			if cardTemplate.instance then
				if self.divinerTable then
					self.divinerTable:PlaceCard(cardIndex - 1, cardTemplate.instance, face, positive)
				end

				cardTemplate.instance.transform:SetParent(nil, true)

				cardInfo.stage = self.CARD_STAGE.IN_DESK_BACK
			end
		end
	end
end

M.DestroyAllCardIns = function(self)
	if self.currentCardSpread then
		for i = 1, #self.currentCardSpread do
			local cardInfo = self.currentCardSpread[i]

			if cardInfo then
				local cardTemplate = self.cardTemplate[cardInfo.id]

				if cardTemplate.instance then
					if not gClientUtils.IsNil(cardTemplate.instance) then
						UnityEngine.GameObject.Destroy(cardTemplate.instance)
					end

					cardTemplate.instance = nil
				end
			end
		end
	end

	self.currentCardSpread = nil
end

M.DestroyCardInsByIndex = function(self, index)
	if self.currentCardSpread then
		local cardInfo = self.currentCardSpread[index]

		if cardInfo then
			local cardTemplate = self.cardTemplate[cardInfo.id]

			if cardTemplate.instance then
				if not gClientUtils.IsNil(cardTemplate.instance) then
					UnityEngine.GameObject.Destroy(cardTemplate.instance)
				end

				cardTemplate.instance = nil
				cardInfo.instance = nil
			end
		end
	end
end

M.InitReactionMotion = function(self)
	self.reactionMap = {}

	for i = 0, ReactionConfig.count - 1 do
		local cfg = ReactionConfig.LoadAt(i)

		if cfg.SignalType == ReactionConfig.SignalTypeType.None then
			local collection = self.reactionMap[cfg.SignalType]

			if not collection then
				collection = {}
				self.reactionMap[cfg.SignalType] = collection
			end

			if cfg.NPCGameplaySignal <= 0 then
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

M.GetNPCReactionSignal = function(self, type)
	if self.curCustomerInfo and self.curCustomerInfo.DemandId <= 0 then
		local demandCfg = DemandConfig.GetConfig(self.curCustomerInfo.DemandId)

		if demandCfg then
			local collection = self.reactionMap[type]

			if collection then
				local signals = collection[demandCfg.ReactionType]
				signals = signals or collection[0]

				if signals then
					if #signals ~= 1 then
						self.lastReactionId = signals[1]

						return self.lastReactionId
					elseif #signals <= 1 then
						local temp = {}

						for _, signal in pairs(signals) do
							if signal == self.lastReactionId then
								table.insert(temp, signal)
							end
						end

						if #temp ~= 0 then
							return self.lastReactionId
						elseif #temp ~= 1 then
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

M.SendPlayerEnterDiviner = function(self)
	self:CommonSendPlayerSignal(ReactionConfig.Enter)
end

M.SendPlayerCallNpc = function(self)
	self:CommonSendPlayerSignal(ReactionConfig.Call)
end

M.SendPlayerCallNextNpc = function(self)
	self:CommonSendPlayerSignal(ReactionConfig.CallNext)

	local cfg = ReactionConfig.GetConfig(ReactionConfig.CallNext)

	if cfg and cfg.GameplaySignal <= 0 and self.curWaitQueuePid then
		local unit = SceneDataMgr.GetUnit(self.curWaitQueuePid)

		if unit then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, cfg.GameplaySignal)
		end
	end
end

M.SendPlayerFinishDiviner = function(self)
	if not self.spoonPid then
		self:CommonSendPlayerSignal(ReactionConfig.Finish)
	end
end

M.CommonSendPlayerSignal = function(self, Id)
	local cfg = ReactionConfig.GetConfig(Id)

	if cfg and cfg.GameplaySignal <= 0 then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, cfg.GameplaySignal)
	end
end

M.SendNPCEnterDiviner = function(self)
	self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Enter)
end

M.SendNPCWaitDiviner = function(self)
	self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Wait)
end

M.SendNPCAgree = function(self)
	self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Agree)
end

M.SendNPCNotAgree = function(self)
	self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.NotAgree)
end

M.SendNPCBattle = function(self)
	if not self.sendStandUp then
		if not self.spoonPid then
			self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Battle)
		end

		self.needAskBattle = true
		self.sendStandUp = true
	end
end

M.SendNPCSuccess = function(self)
	if not self.spoonPid then
		self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Success)
	end
end

M.SendNPCFail = function(self)
	if not self.sendStandUp then
		self.sendStandUp = true

		if not self.spoonPid then
			self:CommonSendNpcSignal(ReactionConfig.SignalTypeType.Fail)
		end
	end
end

M.CommonSendNpcSignal = function(self, type)
	local signal = self:GetNPCReactionSignal(type)

	if signal and signal <= 0 and self.curCustomerInfo then
		local unit = SceneDataMgr.GetUnit(self.curCustomerInfo.AgentId)

		if unit then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
		end
	end
end

M.GMDivinerAgentDoAttractInternal = function(self, pid)
	if pid then
		self:OnDivinerAgentDoAttractInternal(ulong.new(pid, 0))
	end
end

M.OnDivinerAgentDoAttractInternal = function(self, pid)
	if pid then
		local unit = SceneDataMgr.GetUnit(pid)

		if unit and not unit.IsDead and not unit.IsDestroyed then
			local agentConfig = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)
			self.customerName = agentConfig and agentConfig.Name or ""

			self:RequestToDemandStage(pid)
		end
	else
		print_error("DivinerManager 兴趣点触发了下一位顾客，但pid无效 ")
	end
end

M.SetSpoonCustomerInfo = function(self, demandId, pid, autoFinish, demandWaitGuide, persuadeWaitGuide)
	self.spoonDataSet = true
	self.spoonDemandId = demandId
	self.spoonPid = pid
	self.spoonAutoFinish = autoFinish
	self.spoonNeedShowToDemand = false
end

M.EnterDivinerGame = function(self, demandId, pid, autoFinish, spoonInstanceId, divinerTable)
	if not self.reactionMap then
		self:InitReactionMotion()
	end

	self.spoonInstanceId = spoonInstanceId

	if not divinerTable then
		print_error("DivinerManager:没有正确获取到占卜桌，请检查机关配置，不允许进入占卜玩法！")

		return
	end

	self.divinerTable = divinerTable

	self.divinerTable:DisableCamera()

	self.curWaitQueuePid = nil

	if self.curPlayState ~= self.PLAY_STATE.NONE then
		self.dropInfos = {}
		self.dropQueue = {}
		self.firstSit = true

		if not self.spoonDataSet and (not demandId or demandId ~= 0) then
			self.spoonDemandId = nil
			self.spoonPid = nil
			self.spoonAutoFinish = nil
			self.spoonNeedShowToDemand = nil
		end

		self.spoonDataSet = false
		self.curPlayState = self.PLAY_STATE.WAIT_SERVER_RES
		self.divinerLangType = self:GetCurLanguageAbbreviation() or "CN"

		if self.spoonPid then
			local unit = SceneDataMgr.GetUnit(self.spoonPid)

			if unit and not unit.IsDead and not unit.IsDestroyed then
				local agentConfig = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)
				self.customerName = agentConfig and agentConfig.Name or ""
			else
				self.customerName = ""
			end

			gClientToGameDelegate:AskEnterDivinerGame().Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gClientToGameDelegate:AskStartDivinerGameWithDemand(self.spoonPid, self.customerName, self.spoonDemandId, self.divinerLangType).Callback = function (startErr, data)
						if startErr ~= LTConfig.MessageConfig.Ok then
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
				if err ~= LTConfig.MessageConfig.Ok then
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
		print_error("DivinerManager:当前正在占卜师玩法中，不能重复进入！")
	end
end

M.SuccessEnterSpoonDivinerGame = function(self, customerInfo)
	self:SwitchToDivinerFreeCamera()

	self.curPlayState = self.PLAY_STATE.DEMAND
	self.sendStandUp = false

	gPanelManager:CheckShow(gPanelId.DIVINATION_FAKE_DIALOG)
	self:SendPlayerEnterDiviner()

	self.curCustomerId = customerInfo.AgentId

	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
		["PNkgO:!"] = "hH\\xc1l\\xea\\xd8\\xc6F\\xdaWb\\xda\\xdd]\\xcdHS\\xef\\xef\\xcc\\xe9\\xbd\\xc0P",
		entityInstanceId = self.spoonInstanceId
	})

	self.agentStartTime = gLuaDataManager.serverTime
	self.curCustomerInfo = customerInfo
	self.curAttitude = customerInfo.Attitude
	self.curPatience = customerInfo.Patience
	self.maxPatience = customerInfo.Patience
	self.curPersuasion = 0

	self:StartDemandAIDialog()
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
		["PNkgO:!"] = "\\xcb\\x95\\xcb0Ɵ\\xc0ւ\\xaaЭֹ\\xb2\\xeba\\xac\\x87&\\xbf",
		entityInstanceId = self.spoonInstanceId
	})
end

M.AskEnterDivinerGame = function(self)
	gClientToGameDelegate:AskEnterDivinerGame().Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			self:SwitchToDivinerFreeCamera()
			self:ShowFakeDialogPanel()
			gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
				["PNkgO:!"] = "hH\\xc1l\\xea\\xd8\\xc6F\\xdaWb\\xda\\xdd]\\xcdHS\\xef\\xef\\xcc\\xe9\\xbd\\xc0P",
				entityInstanceId = self.spoonInstanceId
			})
		else
			self.curPlayState = self.PLAY_STATE.NONE

			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.ShowFakeDialogPanel = function(self)
	self.curPlayState = self.PLAY_STATE.CALL_NPC

	gPanelManager:CheckShow(gPanelId.DIVINATION_FAKE_DIALOG)
	self:SendPlayerEnterDiviner()
end

M.RequestToDemandStage = function(self, agentId)
	if self.curPlayState == self.PLAY_STATE.CALL_NPC then
		return
	end

	self.curPlayState = self.PLAY_STATE.WAIT_SERVER_RES
	self.curCustomerId = agentId
	self.sendStandUp = false

	gClientToGameDelegate:AskStartDivinerGame(agentId, self.customerName, self.divinerLangType).Callback = function (err, customerInfo)
		if err ~= LTConfig.MessageConfig.Ok then
			self.curPlayState = self.PLAY_STATE.DEMAND
			self.agentStartTime = gLuaDataManager.serverTime

			if self.curCustomerId ~= customerInfo.AgentId then
				self.curCustomerInfo = customerInfo
				self.curAttitude = customerInfo.Attitude
				self.curPatience = customerInfo.Patience
				self.maxPatience = customerInfo.Patience
				self.curPersuasion = 0

				self:StartDemandAIDialog()
			else
				print_error("DivinerManager AskStartDivinerGame 回传的data中的agentId和请求时使用的agentId不符！")
			end

			gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
				["PNkgO:!"] = "\\xcb\\x95\\xcb0Ɵ\\xc0ւ\\xaaЭֹ\\xb2\\xeba\\xac\\x87&\\xbf",
				entityInstanceId = self.spoonInstanceId
			})
		else
			self.curPlayState = self.PLAY_STATE.NONE

			gDisplayMessageMgr:DisplayServerMessageId(err)
			self:FinishDivinerGame(true)
		end
	end
end

M.StartDemandAIDialog = function(self)
	self.curPlayState = self.PLAY_STATE.DEMAND
	self.clueData = {}
	self.dropQueue = {}
	self.demandFinished = false
	self.persuadeSuccess = false
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
end

M.CommonStartTimeCheck = function(self)
	if self.dialogTimeChecked and not self.startTimeChecked then
		self.startTimeChecked = true

		gClientToGameDelegate:AskDivinerStartTimeCheck(self.divinerLangType).Callback = function (err, endTime)
			if err ~= LTConfig.MessageConfig.Ok then
				if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
					gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
				end

				gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_COUNT_DOWN, {
					Param = {
						["ZI糇\\xbd\\xda\\xed"] = false,
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

M.CloseChatCountDown = function(self)
	gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
end

M.GetDemandClueList = function(self)
	if not self.clueData or #self.clueData ~= 0 then
		self.clueData = {}

		if self.curCustomerInfo and self.curCustomerInfo.DemandId and self.curCustomerInfo.DemandId <= 0 then
			local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(self.curCustomerInfo.DemandId)

			if demandCfg and #demandCfg.Clues <= 0 then
				for _, v in pairs(demandCfg.Clues) do
					table.insert(self.clueData, {
						["N\\xa6\\xa7\\xac\\xbd"] = false,
						["|-q_"] = false,
						id = v
					})
				end
			end
		end
	end

	return self.clueData
end

M.GetDemandExplorationTips = function(self)
	if self.curCustomerInfo and self.curCustomerInfo.DemandId and self.curCustomerInfo.DemandId <= 0 then
		local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(self.curCustomerInfo.DemandId)

		return demandCfg.ExplorationDialogTips
	end
end

M.SendDemandAIMessage = function(self, message, agentId, stage)
	if self.curCustomerId and not string.is_null_or_empty(message) then
		gClientToGameDelegate:AskDivinerRequestAppeal(self.curCustomerId, message, self.divinerLangType).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
					self.fakeDialogPanel:OnSyncAIChatError({
						["P^bjk*"] = false,
						["H\\xbc\\xb0\\xa0\\xa4"] = 0,
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

M.CheckDemandAIChatFinish = function(self)
	if self.curPlayState ~= self.PLAY_STATE.DEMAND and self.demandFinished then
		self:StartBranchSelect()
	end
end

M.CheckDemandAIChatFailFinish = function(self)
	if self.curPlayState ~= self.PLAY_STATE.DEMAND and self.demandFinished then
		self:FinishAndToReward()
	end
end

M.TriggerDemandAIChatFinish = function(self)
	self.demandFinished = true
end

M.StartBranchSelect = function(self)
	self.curPlayState = self.PLAY_STATE.BRANCH

	self:StartBranchSelectInternal({
		["\\xaf\\xb8\\xa7e9\\xd77"] = 0,
		demandId = self.curCustomerInfo.DemandId
	})
end

M.SelectBranch = function(self, branchId)
	if not branchId or branchId ~= 0 then
		self:FinishDivinerGame(true)
	end

	self.curBranchId = branchId
	self.curDemandPath = 0
	local path = nil
	local branchConfig = LTConfig.DivinerBranchConfig.GetConfig(self.curBranchId)

	if branchConfig and branchConfig.DemandBranch then
		local demandCfg = LTConfig.DivinerDemandConfig.GetConfig(self.curCustomerInfo.DemandId)

		if demandCfg and demandCfg.Path and branchConfig.DemandBranch >= #demandCfg.Path then
			path = demandCfg.Path[branchConfig.DemandBranch + 1]
		end
	end

	if path then
		gClientToGameDelegate:AskDivinerChooseBranch(self.curCustomerId, path, self.divinerLangType).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
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

M.StartPersuade = function(self)
	self.curPlayState = self.PLAY_STATE.PERSUADE
	self.persuadeResult = nil
	self.persuadeFinished = false
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

	self:SwitchToDivinerFreeCamera()
end

M.TriggerPersuadeAIChatFinish = function(self)
	self.persuadeFinished = true
end

M.SendPersuadeAIMessage = function(self, message, agentId, stage)
	if self.curCustomerId and not string.is_null_or_empty(message) then
		gClientToGameDelegate:AskDivinerPersuade(self.curCustomerId, message, self.divinerLangType).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
					self.fakeDialogPanel:OnSyncAIChatError({
						["P^bjk*"] = false,
						["H\\xbc\\xb0\\xa0\\xa4"] = 0,
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

M.CheckPersuadeAIChatFinish = function(self)
	if self.curPlayState ~= self.PLAY_STATE.PERSUADE and self.persuadeFinished then
		self:FinishAndToReward()
	end
end

M.FinishAndToReward = function(self)
	if self.curPlayState ~= self.PLAY_STATE.BRANCH or self.curPlayState ~= self.PLAY_STATE.PERSUADE then
		self:StartPutBackIntoDeck()
	end

	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
		["PNkgO:!"] = "7Z7oU1>\\x80a=\\xce{YB\\S\\xd7P\\xdbe",
		entityInstanceId = self.spoonInstanceId
	})

	self.curPlayState = self.PLAY_STATE.REWARD

	if self.fakeDialogPanel and self.fakeDialogPanel then
		self.fakeDialogPanel:TriggerIntoRewardStage()
	end
end

M.ChangeToCallNpcState = function(self)
	self.curPlayState = self.PLAY_STATE.CALL_NPC

	if self.fakeDialogPanel and self.fakeDialogPanel then
		self.fakeDialogPanel:TriggerIntoCallNpcStage()
	end
end

M.PopupNextCustomerDropInfo = function(self)
	if #self.dropQueue <= 0 then
		local id = self.dropQueue[1]

		table.remove(self.dropQueue, 1)

		return self.dropInfos[id]
	end

	return nil
end

M.PushNextCustomerDropInfo = function(self, customerId)
	table.insert(self.dropQueue, customerId)
end

M.FinishPersuade = function(self, result)
	self.persuadeResult = result
	self.persuadeSuccess = self.persuadeResult ~= 1
	local pathCfg = LTConfig.DivinerPathConfig.GetConfig(self.curDemandPath)
	local review = nil

	if pathCfg then
		if self.persuadeResult ~= 1 then
			review = array.random(pathCfg.SuccessReview)
		elseif self.persuadeResult ~= 2 then
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

M.FinishDivinerGame = function(self, sendFailSignal)
	local table = self.divinerTable
	self.divinerTable = nil
	self.firstSit = true

	gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, LTConfig.UnitStateConfig.OnlyLook)

	self.curPlayState = self.PLAY_STATE.NONE

	self:SwitchToNormalFreeLook()

	gClientToGameDelegate:AskLeaveDivinerGame().Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	gClientToGameDelegate:AskDivinerTriggerResult()
	self:DestroyAllCardIns()
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
		["PNkgO:!"] = "\\xe3i\\xa5\\xcb\\x9d|\\xfe\\xc2~\\xfc\\x87\\x95x\\x97\\w\\x99\\xe2",
		entityInstanceId = self.spoonInstanceId
	})
	gPanelManager:Close(gPanelId.DIVINATION_FAKE_DIALOG)
	gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	self:ShowTotalReward()
	self:SendPlayerFinishDiviner()

	if sendFailSignal and self.curPlayState == self.PLAY_STATE.CALL_NPC then
		self:SendNPCFail()
	end

	if table then
		table:ClearTable()
		table:DisableCamera()
	end
end

M.FinishDivinerGameBeforeSwitchScene = function(self)
	local table = self.divinerTable
	self.divinerTable = nil
	self.firstSit = true

	gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, LTConfig.UnitStateConfig.OnlyLook)

	self.curPlayState = self.PLAY_STATE.NONE

	self:DestroyAllCardIns()
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
		["PNkgO:!"] = "\\xe3i\\xa5\\xcb\\x9d|\\xfe\\xc2~\\xfc\\x87\\x95x\\x97\\w\\x99\\xe2",
		entityInstanceId = self.spoonInstanceId
	})

	if table then
		table:ClearTable()
		table:DisableCamera()
	end
end

M.ShowTotalReward = function(self)
	local totalMoney = 0
	local totalPerson = 0
	local totalSuccess = 0

	for k, v in pairs(self.dropInfos) do
		totalMoney = totalMoney + v.money
		totalPerson = totalPerson + 1

		if v.result ~= 1 then
			totalSuccess = totalSuccess + 1
		end
	end

	self.dropInfos = {}
	self.dropQueue = {}

	if totalPerson >= 0 or totalSuccess >= 0 or totalMoney <= 0 then
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

M.OnSyncDivinerCustomerInfo = function(self, customerInfo)
	if self.curPlayState ~= self.PLAY_STATE.NONE then
		gClientToGameDelegate:AskLeaveDivinerGame().Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end

	if customerInfo and self.agentId ~= customerInfo.AgentId then
		self.curCustomerInfo = customerInfo
	end
end

M.SendLiveChatEvent = function(self, event, message)
	if self.isInLivestream and event and event <= 0 and self.curPlayState == self.PLAY_STATE.NONE then
		gClientToGameDelegate:AskDivinerLiveChatInteract(event, self.divinerLangType).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end
	end
end

M.SendStartLiveChatEvent = function(self)
	self:SendLiveChatEvent(self.DAN_MU_EVENT.enter_game)

	local event = self.SPIRIT_TO_DAN_MU_EVENT[gSpiritManager:GetCurFirstSpiritTid()]

	if event then
		self:SendLiveChatEvent(event)
	end
end

M.SendCustomerSitLiveChatEvent = function(self)
	if self.firstSit then
		self.firstSit = false

		self:SendLiveChatEvent(self.DAN_MU_EVENT.first_sit)
	else
		self:SendLiveChatEvent(self.DAN_MU_EVENT.after_sit)
	end
end

M.OnSyncDivinerAIError = function(self, agentId, stage, error)
	if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
		self.fakeDialogPanel:OnSyncAIChatError({
			["P^bjk*"] = true,
			agentId = agentId,
			stage = stage,
			error = error
		})

		if self.curPlayState ~= self.PLAY_STATE.PERSUADE and self.persuadeFinished then
			self.fakeDialogPanel:TriggerStartDelayToNextStage()
		end

		if self.curPlayState ~= self.PLAY_STATE.DEMAND and self.demandFinished then
			self.fakeDialogPanel:TriggerStartDelayToNextStage()
		end
	end
end

M.OnSyncDivinerAIMessage = function(self, info)
	if self.isDebug then
		print_notice(string.format("DivinerManager OnSyncDivinerAIMessage stage %s result %s msg %s clue %s attitude %s persuasion %s", tostring(info.Stage), tostring(info.Result), tostring(info.Msg), tostring(info.ClueId), tostring(info.Attitude), tostring(info.Persuasion)))
	end

	local lastAttitude = self.curAttitude
	local lastPatience = self.curPatience
	local lastPersuasion = self.curPersuasion
	self.curAttitude = info.Attitude
	self.curPatience = info.Patience
	self.curPersuasion = info.Persuasion
	self.curEndReason = info.EndReason
	local canSend = true

	if self.curPlayState ~= self.PLAY_STATE.DEMAND then
		if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
			local waitFunc = nil

			if self.demandFinished then
				waitFunc = function()
					if self.demandFinished then
						self.fakeDialogPanel:TriggerStartDelayToNextStage()
					end
				end
			end

			self.fakeDialogPanel:OnSyncAIChatMessage({
				agentId = info.AgentId,
				stage = info.Stage,
				message = info.MsgSegments,
				canInput = not self.demandFinished,
				attitude = self.curAttitude,
				waitFunc = waitFunc
			})

			if info.Stage ~= self.CHAT_STAGE.DEMAND then
				if lastPatience == self.curPatience then
					if self.curPatience >= lastPatience then
						self:SendLiveChatEvent(self.DAN_MU_EVENT.demand_patience_down)
						self.fakeDialogPanel:AddPatienceDown()
					else
						self.fakeDialogPanel:AddPatienceUp()
					end
				end

				if lastAttitude == self.curAttitude then
					if self.curAttitude >= lastAttitude then
						self.fakeDialogPanel:AddAttitudeDown()
					else
						self:SendLiveChatEvent(self.DAN_MU_EVENT.demand_like_up)
						self.fakeDialogPanel:AddAttitudeUp()
					end
				end

				if self.demandFinished then
					canSend = false

					if self.curEndReason ~= self.END_REASON.NORMAL_FAIL then
						self:SendNPCFail()
					elseif self.curEndReason ~= self.END_REASON.BATTLE_FAIL then
						self:SendNPCBattle()
					end
				elseif self.curEndReason ~= self.END_REASON.NEXT_STAGE then
					self:TriggerDemandAIChatFinish()
					self.fakeDialogPanel:DemandFinished()
					self:CloseChatCountDown()
					self:SendLiveChatEvent(self.DAN_MU_EVENT.demand_success)
				elseif self.curEndReason ~= self.END_REASON.NORMAL_FAIL then
					self:TriggerDemandAIChatFinish()
					self.fakeDialogPanel:DemandNormalFailed()
					self:CloseChatCountDown()
					self:SendLiveChatEvent(self.DAN_MU_EVENT.demand_failed)
				elseif self.curEndReason ~= self.END_REASON.BATTLE_FAIL then
					self:TriggerDemandAIChatFinish()
					self.fakeDialogPanel:DemandBattleFailed()
					self:CloseChatCountDown()
					self:SendLiveChatEvent(self.DAN_MU_EVENT.demand_failed)
				elseif self.curEndReason ~= self.END_REASON.TIME_OUT then
					self:TriggerDemandAIChatFinish()
					self.fakeDialogPanel:DemandTimeOutFailed()
					self:CloseChatCountDown()
					self:SendLiveChatEvent(self.DAN_MU_EVENT.demand_time_out)
					self:SendNPCFail()

					canSend = false
				end
			end
		end
	elseif self.curPlayState ~= self.PLAY_STATE.PERSUADE then
		local persuadeWaitFunc = nil

		if self.fakeDialogPanel and self.fakeDialogPanel.isShow then
			if info.Stage ~= self.CHAT_STAGE.PERSUADE then
				if lastPatience == self.curPatience then
					if self.curPatience >= lastPatience then
						self:SendLiveChatEvent(self.DAN_MU_EVENT.persuade_patience_down)
						self.fakeDialogPanel:AddPatienceDown()
					else
						self.fakeDialogPanel:AddPatienceUp()
					end
				end

				if lastAttitude == self.curAttitude then
					if self.curAttitude >= lastAttitude then
						self:SendLiveChatEvent(self.DAN_MU_EVENT.persuade_attitude_down)
						self.fakeDialogPanel:AddAttitudeDown()
					else
						self:SendLiveChatEvent(self.DAN_MU_EVENT.persuade_like_up)
						self.fakeDialogPanel:AddAttitudeUp()
					end
				end

				if lastPersuasion == self.curPersuasion then
					if self.curPersuasion >= lastPersuasion then
						self:SendLiveChatEvent(self.DAN_MU_EVENT.persuade_progress_down)
						self.fakeDialogPanel:AddPersuadeDown()
					else
						self:SendLiveChatEvent(self.DAN_MU_EVENT.persuade_progress_up)
						self.fakeDialogPanel:AddPersuadeUp()
					end
				end

				if info.Result <= 0 then
					self:FinishPersuade(info.Result)
				end

				if self.persuadeFinished then
					persuadeWaitFunc = function()
						if self.persuadeFinished then
							self.fakeDialogPanel:TriggerStartDelayToNextStage()
						end
					end

					canSend = false

					if self.curEndReason ~= self.END_REASON.NEXT_STAGE then
						self:SendNPCSuccess()
						self:SendLiveChatEvent(self.DAN_MU_EVENT.divination_success)
					elseif self.curEndReason ~= self.END_REASON.NORMAL_FAIL then
						self:SendNPCFail()
						self:SendLiveChatEvent(self.DAN_MU_EVENT.divination_failed)
					elseif self.curEndReason ~= self.END_REASON.BATTLE_FAIL then
						self:SendNPCBattle()
						self:SendLiveChatEvent(self.DAN_MU_EVENT.divination_failed)
					end
				elseif self.curEndReason ~= self.END_REASON.NEXT_STAGE then
					self:TriggerPersuadeAIChatFinish()
					self.fakeDialogPanel:PersuadeFinished()
					self:CloseChatCountDown()
					self:SendLiveChatEvent(self.DAN_MU_EVENT.persuade_success)
				elseif self.curEndReason ~= self.END_REASON.NORMAL_FAIL then
					self:TriggerPersuadeAIChatFinish()
					self.fakeDialogPanel:PersuadeNormalFailed()
					self:CloseChatCountDown()
					self:SendLiveChatEvent(self.DAN_MU_EVENT.persuade_failed)
				elseif self.curEndReason ~= self.END_REASON.BATTLE_FAIL then
					self:TriggerPersuadeAIChatFinish()
					self.fakeDialogPanel:PersuadeBattleFailed()
					self:CloseChatCountDown()
					self:SendLiveChatEvent(self.DAN_MU_EVENT.persuade_failed)
				elseif self.curEndReason ~= self.END_REASON.TIME_OUT then
					self:TriggerPersuadeAIChatFinish()
					self.fakeDialogPanel:PersuadeTimeOutFailed()
					self:CloseChatCountDown()
					self:SendLiveChatEvent(self.DAN_MU_EVENT.persuade_time_out)
					self:SendNPCFail()
					self:SendLiveChatEvent(self.DAN_MU_EVENT.divination_failed)
					self.fakeDialogPanel:TriggerStartDelayToNextStage()

					canSend = false
				end
			end

			self.fakeDialogPanel:OnSyncAIChatMessage({
				agentId = info.AgentId,
				stage = info.Stage,
				message = info.MsgSegments,
				canInput = not self.persuadeFinished,
				attitude = self.curAttitude,
				waitFunc = persuadeWaitFunc
			})
		end
	end

	if canSend then
		if self.curAttitude < lastAttitude then
			self:SendNPCNotAgree()
		elseif lastAttitude >= self.curAttitude then
			self:SendNPCAgree()
		end
	end
end

M.OnSyncDivinerMilestoneSummary = function(self, agentId, clueId, summary)
	if self.curPlayState ~= self.PLAY_STATE.DEMAND and agentId ~= self.curCustomerId and clueId <= 0 then
		local needSend = false

		for i = 1, #self.clueData do
			local clueData = self.clueData[i]

			if clueData.id ~= clueId then
				needSend = not clueData.check
				clueData.check = true
				clueData.summary = summary

				break
			end
		end

		if needSend then
			self:SendLiveChatEvent(self.DAN_MU_EVENT.clue_check)

			local clueCfg = LTConfig.DivinerClueConfig.GetConfig(clueId)

			if clueCfg and clueCfg.ClueDanmuEventId <= 0 then
				self:SendLiveChatEvent(clueCfg.ClueDanmuEventId)
			end
		end

		self.fakeDialogPanel:RefreshClueList()
	end
end

M.GetCurLanguageAbbreviation = function(self)
	local langIdx = LX6.Engine.ProfileManager.languageProfile.textLanguage
	local langCfg = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(langIdx)

	return langCfg and langCfg.Abbreviation
end

M.OnSyncDivinerLiveChatMessage = function(self, messages, isSC)
	if self.fakeDialogPanel and self.fakeDialogPanel.isShow and self.fakeDialogPanel.SubGroup.DivinerLivestreamPanelStore then
		if isSC then
			self.fakeDialogPanel.SubGroup.DivinerLivestreamPanelStore:AddSCMessages(messages)
		else
			self.fakeDialogPanel.SubGroup.DivinerLivestreamPanelStore:AddMessages(messages)
		end
	end
end

M.OnDivinerDrop = function(self, msg)
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

	if self.curPlayState ~= self.PLAY_STATE.REWARD and self.fakeDialogPanel and self.fakeDialogPanel.isShow then
		self.fakeDialogPanel:CheckShowReward()
	end
end

M.SwitchToDivinerFreeCamera = function(self)
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(LTConfig.DivinerConfig.FreeLockActionStatusId, LTConfig.DivinerConfig.FreeLockActionSwitchTime, nil, 5)
end

M.SwitchToCardFreeCamera = function(self)
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(LTConfig.DivinerConfig.TarotFreeLockActionStatusId, LTConfig.DivinerConfig.TarotFreeLockActionSwitchTime, nil, 5)
end

M.SwitchToNormalFreeLook = function(self)
	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(LTConfig.DivinerConfig.FreeLockActionSwitchTime, nil, 5)
end

M.RequestDivinerPublishTwitter = function(self, instanceId)
	self.waitYanJieInstanceId = instanceId
	self.needOpenLivestream = false

	gClientToGameDelegate:AskDivinerPublishTuite().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end
end

M.OnYanJieDetailContentClosed = function(self)
	if self.waitYanJieInstanceId then
		local data = {
			["PNkgO:!"] = "\\xcb\\x95\\xcb0Ɵ\\xc0ւ\\xaaکں\\xb9\\xebq\\xb4\\x89'\\xae",
			entityInstanceId = self.waitYanJieInstanceId
		}
		self.waitYanJieInstanceId = nil

		gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, data)
	end
end

gDivinerManager = M
