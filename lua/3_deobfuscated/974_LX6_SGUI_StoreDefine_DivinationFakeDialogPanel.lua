C_DivinationFakeDialogPanel = DefClass("C_DivinationFakeDialogPanel", C_DivinationFakeDialogPanel, C_StoreGroup)
GroupName2Class.DivinationFakeDialogPanel = C_DivinationFakeDialogPanel
local M = C_DivinationFakeDialogPanel
local SceneDataMgr = gCS.SceneDataMgr
local ClueConfig = LTConfig.DivinerClueConfig
local DivinerConfig = LTConfig.DivinerConfig
local BranchConfig = LTConfig.DivinerBranchConfig
local DemandConfig = LTConfig.DivinerDemandConfig
local PersonalityConfig = LTConfig.DivinerPersonalityConfig

function M:ctor()
	self.curInputText = ""
	self.PANEL_TYPE = {
		PERSUADE = 3,
		END = 1,
		NORMAL = 0,
		DEMAND = 2
	}
	self.NEXT_STAGE = {
		NORMAL = 0,
		TIME_OUT = 3,
		FAIL = 1,
		BATTLE = 2
	}
	self.leftNameFormat = "#IHud%s#z"
end

function M:DefineAllVariables()
	self.isShow = false
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
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.isShow = true

	self:InitData()
	self:InitDataCallNpcData()

	self.bindData.dialogContent.activation = false
	gDivinerManager.fakeDialogPanel = self

	if gDivinerManager.spoonNeedShowToDemand then
		gDivinerManager:StartDemandAIDialog()
	else
		self:TriggerIntoCallNpcStage()
	end

	gDivinerManager:ChangeTaskTarget()
end

function M:OnClose()
	self.isShow = false
	self.clueList = nil

	self:ClearCDTimer()

	gDivinerManager.fakeDialogPanel = nil

	self:StopRewardTimer()
end

function M:OnUpdate()
	if self.isShowingMsg and self.curInterval < os.time() - self.curShownTime then
		local nextMsg = nil

		if #self.messageQueue > 0 then
			nextMsg = self.messageQueue[1]

			table.remove(self.messageQueue, 1)
		end

		self:ShowDialogContentInternal(nextMsg)
	end

	if self.triggerNextTime and self.triggerNextTime < gLuaDataManager.serverTime then
		self.triggerNextTime = nil

		if gDivinerManager.curPlayState == gDivinerManager.PLAY_STATE.DEMAND then
			if self.nextStage == self.NEXT_STAGE.NORMAL then
				gDivinerManager:CheckDemandAIChatFinish()
			elseif self.nextStage == self.NEXT_STAGE.FAIL then
				gDivinerManager:CheckDemandAIChatFailFinish()
			elseif self.nextStage == self.NEXT_STAGE.BATTLE or self.nextStage == self.NEXT_STAGE.TIME_OUT then
				gDivinerManager:CheckDemandAIChatFailFinish()
			end
		elseif gDivinerManager.curPlayState == gDivinerManager.PLAY_STATE.PERSUADE then
			if self.nextStage == self.NEXT_STAGE.NORMAL then
				gDivinerManager:CheckPersuadeAIChatFinish()
			elseif self.nextStage == self.NEXT_STAGE.FAIL then
				gDivinerManager:CheckPersuadeAIChatFinish()
			elseif self.nextStage == self.NEXT_STAGE.BATTLE or self.nextStage == self.NEXT_STAGE.TIME_OUT then
				gDivinerManager:CheckPersuadeAIChatFinish()
			end
		end
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.sendBtn.luaClick = self:CreateAction("OnClickSendBtn")
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.topBtn.luaClick = self:CreateAction("OnClickTopBtn")
	self.bindData.centerBtn.luaClick = self:CreateAction("OnClickCenterBtn")
	self.bindData.bottomBtn.luaClick = self:CreateAction("OnClickBottomBtn")
	self.bindData.callNpcBtn.luaClick = self:CreateAction("OnClickCallNpcBtn")
	self.bindData.nextBtn.luaClick = self:CreateAction("OnClickNextBtn")
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputFieldInputValueChanged")
	self.bindData.inputField.luaEndEdit = self:CreateAction("OnInputFieldInputEndEdit")
	self.bindData.clueList.luaSimpleRenderItem = self:CreateAction("OnRenderClueListItem")
	self.bindData.clueList.luaSimpleDynamicRenderItem = self:CreateAction("OnRenderClueListItem")
end

function M:InitData()
	self.curInputText = ""
	self.messageQueue = {}
	self.isShowingMsg = false
	self.curShownTime = 0
	self.nextStage = self.NEXT_STAGE.NORMAL
	self.autoClose = false
end

function M:OnClickSendBtn()
	if not string.is_null_or_empty(self.curInputText) then
		self.bindData.canSend = false

		gClientUtils.EnvSdkReviewWords(self.curInputText, function ()
			if self.isShow then
				self.bindData.canSend = self.canInput

				self:OnClickSendBtnInternal()
			end
		end, function ()
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)

			if self.isShow then
				self.bindData.canSend = self.canInput
			end
		end, "Diviner")
	end
end

function M:OnClickSendBtnInternal()
	local sendDemandOrPersuadeSuccess = false

	if gDivinerManager.curPlayState == gDivinerManager.PLAY_STATE.DEMAND then
		sendDemandOrPersuadeSuccess = gDivinerManager:SendDemandAIMessage(self.curInputText, self.curAgentId, self.curStage)
	elseif gDivinerManager.curPlayState == gDivinerManager.PLAY_STATE.PERSUADE then
		sendDemandOrPersuadeSuccess = gDivinerManager:SendPersuadeAIMessage(self.curInputText, self.curAgentId, self.curStage)
	end

	if sendDemandOrPersuadeSuccess then
		self.canInput = false
		self.bindData.inputRoot.activation = false

		self:ShowDialogContent({
			message = self.curInputText,
			leftName = string.format(self.leftNameFormat, gPlayerManager.infoLogin.bindData.name),
			interval = DivinerConfig.PlayerMessageInterval
		})

		self.bindData.inputField.text = ""
	end
end

function M:OnClickSendBtnCallNpc()
	local dialogId = nil
	local dialogIds = LTConfig.DivinerConfig.HawkingDialogID

	if dialogIds then
		if #dialogIds == 1 then
			dialogId = dialogIds[1]
		else
			dialogId = array.random(dialogIds)
		end

		local dialogCfg = LTConfig.DialogConfig.GetConfig(dialogId)
		local nextMessage = nil

		if dialogCfg then
			nextMessage = {
				message = dialogCfg.Message,
				leftName = string.format(self.leftNameFormat, gPlayerManager.infoLogin.bindData.name),
				interval = DivinerConfig.PlayerMessageInterval
			}
		end

		self:ShowDialogContent({
			message = self.curInputText,
			interval = DivinerConfig.PlayerMessageInterval
		})
		self:ShowDialogContent(nextMessage)

		self.bindData.inputField.text = ""

		gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_REQUEST_NEXT")
	end
end

function M:OnClickBackBtn()
	gDivinerManager:FinishDivinerGame(true)
end

function M:OnClickTopBtn()
	self:OnSuggestContentClick(1)
end

function M:OnClickCenterBtn()
	self:OnSuggestContentClick(2)
end

function M:OnClickBottomBtn()
	self:OnSuggestContentClick(3)
end

function M:OnClickCallNpcBtn()
	self:OnClickSendBtnCallNpc()
	gDivinerManager:SendPlayerCallNpc()
end

function M:OnClickNextBtn()
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_REQUEST_NEXT")
	gDivinerManager:SendPlayerCallNextNpc()
end

function M:OnInputFieldInputValueChanged(text)
	self.curInputText = text
end

function M:OnInputFieldInputEndEdit(text, enter)
	self.curInputText = text

	if enter then
		self:OnClickSendBtn()
	end
end

function M:InitDataCallNpcData()
	self.hawkingPreset = {}
	local hawkingPresetTexts = LTConfig.DivinerConfig.HawkingPresetText

	if hawkingPresetTexts and #hawkingPresetTexts >= 3 then
		if #hawkingPresetTexts > 3 then
			local indexes = {}

			for i = 1, #hawkingPresetTexts do
				table.insert(indexes, i)
			end

			for i = 1, 3 do
				local j = math.random(#indexes)
				local index = indexes[j]

				table.insert(self.hawkingPreset, hawkingPresetTexts[index])
				table.remove(indexes, j)
			end
		else
			for i = 1, 3 do
				table.insert(self.hawkingPreset, hawkingPresetTexts[i])
			end
		end
	else
		print_error("占卜师setting配置的招揽喊话预设文本错误，请检查配置！")
	end

	local hawkingPreset = self.hawkingPreset[1]

	if hawkingPreset and not string.is_null_or_empty(hawkingPreset.PresetText) then
		self.bindData.topBtnText = hawkingPreset.PresetText
	end

	hawkingPreset = self.hawkingPreset[2]

	if hawkingPreset and not string.is_null_or_empty(hawkingPreset.PresetText) then
		self.bindData.centerBtnText = hawkingPreset.PresetText
	end

	hawkingPreset = self.hawkingPreset[3]

	if hawkingPreset and not string.is_null_or_empty(hawkingPreset.PresetText) then
		self.bindData.bottomBtnText = hawkingPreset.PresetText
	end
end

function M:TriggerIntoCallNpcStage()
	self:RefreshStage()
end

function M:OnSuggestContentClick(index)
	local hawkingPreset = self.hawkingPreset[index]

	if hawkingPreset and hawkingPreset.DialogId and hawkingPreset.DialogId > 0 then
		local dialogId = hawkingPreset.DialogId
		local dialogCfg = LTConfig.DialogConfig.GetConfig(dialogId)
		local nextMessage = nil

		if dialogCfg then
			nextMessage = {
				message = dialogCfg.Message,
				leftName = dialogCfg.LeftName,
				interval = DivinerConfig.PlayerMessageInterval
			}
		end

		self:ShowDialogContent({
			message = hawkingPreset.PresetText,
			interval = DivinerConfig.PlayerMessageInterval
		})
		self:ShowDialogContent(nextMessage)
		gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "DIVINATION_REQUEST_NEXT")
	end
end

function M:ClearCDTimer()
	if self.cdTimer then
		self.cdTimer:Stop()

		self.cdTimer = nil
	end
end

function M:SetIntoCD()
	self.bindData.canSend = false
	local time = LTConfig.DivinerConfig.HawkingCD

	self:ClearCDTimer()

	self.cdTimer = Timer.New(function ()
		if self.isShow then
			self.bindData.canSend = true
		end
	end, time or 2):Start()
end

function M:GetDialogComponentStore(widget)
	return gStoreManager:GetStoreGroup("S_DialogComponentStore"):GetStoreByWidget(widget)
end

function M:ConcatLeftNameAndMessage(Content_Message, Content_LeftName)
	local message = nil

	if string.is_null_or_empty(Content_LeftName) then
		message = Content_Message
	else
		message = "#IDD" .. Content_LeftName .. ": #Z" .. Content_Message
	end

	return message
end

function M:ShowDialogContent(messageData)
	if self.isShowingMsg then
		table.insert(self.messageQueue, messageData)
	else
		self:ShowDialogContentInternal(messageData)
	end
end

function M:ShowDialogContentInternal(messageData)
	if messageData then
		local func = self.curShowData and self.curShowData.waitFunc
		self.isShowingMsg = true
		self.curInterval = messageData.interval or 2
		self.curShowData = messageData
		self.curShownTime = os.time()
		local store = self:GetDialogComponentStore(self.bindData.dialogContent)

		if store then
			store.message = self:ConcatLeftNameAndMessage(messageData.message, messageData.leftName)

			if messageData.jobName then
				store.showJob = 1
				store.job = messageData.jobName
			else
				store.showJob = 0
			end
		end

		self.bindData.dialogContent.activation = true

		self.bindData.dialogAnim:Play()

		if func then
			func()
		end

		self.bindData.inputRoot.activation = false
	else
		self.isShowingMsg = false

		self:CloseDialogContent()
	end
end

function M:CloseDialogContent()
	local func = self.curShowData.waitFunc
	self.curShowData = nil

	if func then
		func()
	end

	self.bindData.dialogContent.activation = false

	self.bindData.dialogAnim:Stop()

	if not self.isShowingMsg and gDivinerManager.curPlayState == gDivinerManager.PLAY_STATE.DEMAND or gDivinerManager.curPlayState == gDivinerManager.PLAY_STATE.PERSUADE then
		self:CheckShowInputRoot()
	end

	if gDivinerManager.curPlayState == gDivinerManager.PLAY_STATE.REWARD and not self.rewardTimer then
		self:RewardFinished()
	end
end

function M:CheckShowInputRoot()
	if not self.isShowingMsg and self.canInput then
		self.bindData.inputRoot.activation = true

		self.bindData.inputField:Focus()
		self.bindData.inputField:ActivateInputField()
	end
end

function M:ShowFakeDialogById(dialogId, waitFunc)
	local dialogCfg = LTConfig.DialogConfig.GetConfig(dialogId)
	local loopCount = 0

	while dialogCfg and loopCount < 20 do
		local func = nil

		if dialogCfg.NextDialog <= 0 then
			func = waitFunc
		end

		self:ShowFakeDialogByIdInternal(dialogCfg, func)

		if dialogCfg.NextDialog > 0 then
			dialogCfg = LTConfig.DialogConfig.GetConfig(dialogCfg.NextDialog)
		else
			dialogCfg = nil
		end

		loopCount = loopCount + 1
	end
end

function M:ShowFakeDialogByIdInternal(dialogCfg, waitFunc)
	local nextMessage = nil

	if dialogCfg then
		nextMessage = {
			message = dialogCfg.Message,
			leftName = dialogCfg.LeftName,
			Id = dialogCfg.Id,
			waitFunc = waitFunc,
			interval = DivinerConfig.DialogMessageInterval
		}
	end

	self:ShowDialogContent(nextMessage)
end

function M:StartDemandOrPersuadeStage(data, waitFunc)
	self.autoClose = false
	self.agentName = data.agentName
	self.curAgentId = data.agentId
	self.curStage = data.stage

	if data.history then
		self.historyMessage = data.history
	else
		self.historyMessage = {}
	end

	self.isShowingMsg = false
	self.curShownTime = 0

	if data.canInput == false then
		self.canInput = false
	else
		self.canInput = true
	end

	if not self.agentName and self.curAgentId then
		local unit = SceneDataMgr.GetUnit(self.curAgentId)

		if unit then
			local agentCfg = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)

			if agentCfg and agentCfg.Name then
				self.agentName = agentCfg.Name
			end
		end
	end

	local dialogId = nil

	if gDivinerManager.curPlayState == gDivinerManager.PLAY_STATE.DEMAND then
		data.demandCfg = LTConfig.DivinerDemandConfig.GetConfig(gDivinerManager.curCustomerInfo and gDivinerManager.curCustomerInfo.DemandId or 0)
		dialogId = data.demandCfg and data.demandCfg.DialogId
	elseif gDivinerManager.curPlayState == gDivinerManager.PLAY_STATE.PERSUADE then
		local branchCfg = LTConfig.DivinerBranchConfig.GetConfig(gDivinerManager.curBranchId or 0)
		dialogId = branchCfg and branchCfg.DialogId
	end

	if dialogId and dialogId > 0 then
		self:ShowFakeDialogById(dialogId, waitFunc)
	else
		if waitFunc then
			waitFunc()
		end

		self.bindData.dialogContent.activation = false

		self.bindData.dialogAnim:Stop()
	end

	self.bindData.attitudeProgress:ProgressToValue(gDivinerManager.curAttitude)
	self:RefreshStage(data)
end

function M:DemandFinished()
	self.canInput = false
	self.bindData.inputRoot.activation = false
	self.nextStage = self.NEXT_STAGE.NORMAL

	self:CommonDemandFinish()
end

function M:DemandNormalFailed()
	self.nextStage = self.NEXT_STAGE.FAIL

	self:CommonDemandFinish()
end

function M:DemandBattleFailed()
	self.nextStage = self.NEXT_STAGE.BATTLE
	self.autoClose = true

	self:CommonDemandFinish()
end

function M:DemandTimeOutFailed()
	self.nextStage = self.NEXT_STAGE.TIME_OUT
	self.autoClose = true

	self:CommonDemandFinish()
end

function M:CommonDemandFinish()
	if self.nextStage == self.NEXT_STAGE.NORMAL then
		local demandId = gDivinerManager.curCustomerInfo and gDivinerManager.curCustomerInfo.DemandId

		if demandId then
			local demandCfg = DemandConfig.GetConfig(demandId)

			if demandCfg then
				local nextMessage = {
					message = demandCfg.TruePurpose,
					leftName = string.format(self.leftNameFormat, gPlayerManager.infoLogin.bindData.name),
					interval = DivinerConfig.PlayerMessageInterval
				}

				self:ShowDialogContent(nextMessage)
			end
		end
	end

	local langType = gDivinerManager:GetCurLanguageAbbreviation() or "CN"

	gClientToGameDelegate:AskDivinerFinishRequestAppeal(gDivinerManager.curCustomerInfo.AgentId, langType).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gDivinerManager:FinishDivinerGame(true)
		end
	end
end

function M:PersuadeFinished()
	self:CommonPersuadeFinish()

	self.canInput = false
	self.bindData.inputRoot.activation = false
	self.nextStage = self.NEXT_STAGE.NORMAL
end

function M:PersuadeNormalFailed()
	self.nextStage = self.NEXT_STAGE.FAIL

	self:CommonPersuadeFinish()
end

function M:PersuadeBattleFailed()
	self.autoClose = true
	self.nextStage = self.NEXT_STAGE.BATTLE

	self:CommonPersuadeFinish()
end

function M:PersuadeTimeOutFailed()
	self.autoClose = true
	self.nextStage = self.NEXT_STAGE.TIME_OUT

	self:CommonPersuadeFinish()
end

function M:CommonPersuadeFinish()
	local langType = gDivinerManager:GetCurLanguageAbbreviation() or "CN"

	gClientToGameDelegate:AskDivinerFinishPersuade(gDivinerManager.curCustomerInfo.AgentId, langType).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gDivinerManager:FinishDivinerGame(true)
		end
	end
end

function M:TriggerStartDelayToNextStage()
	if not self.triggerNextTime then
		self.triggerNextTime = gLuaDataManager.serverTime + (DivinerConfig.NextStageInterval or 2)
	end
end

function M:OnSyncAIChatError()
	if self.isShow and not self.isShowingMsg then
		self:CheckShowInputRoot()
	end
end

function M:OnSyncAIChatMessage(data)
	if self.isShow and self.curAgentId == data.agentId and self.curStage == data.stage then
		if data.canInput then
			self.canInput = true
		elseif data.canInput == false then
			self.canInput = false
		end

		if data.attitude then
			self.bindData.attitudeProgress:ProgressToValue(gDivinerManager.curAttitude)
		end

		self:ShowDialogContent({
			message = data.message or "",
			leftName = self.agentName or "",
			waitFunc = data.waitFunc,
			interval = DivinerConfig.AIMessageInterval
		})
	end
end

function M:TriggerIntoRewardStage()
	self:RefreshStage()
end

function M:CheckShowReward()
	self.bindData.inputRoot.activation = false
	local info = gDivinerManager:PopupNextCustomerDropInfo()

	if info then
		self.triggerNextTime = nil
		self.bindData.typeCtrl = self.PANEL_TYPE.END
		self.bindData.money = info.money
		self.bindData.exp = info.exp
		local reviewCfg = LTConfig.DivinerOrderReviewConfig.GetConfig(info.review)

		if reviewCfg then
			self.bindData.starCtrl = reviewCfg.StarRating - 1
			self.bindData.reviewText = reviewCfg.Content
		end

		local time = info.useTime
		local minutes = math.floor(time / gClientConst.SECONDS_PER_MINUTE)
		local seconds = time % gClientConst.SECONDS_PER_MINUTE
		self.bindData.useTime = ("%02d:%02d"):format(minutes, seconds)
		local avatarStore = gStoreManager:GetStoreGroup(self.bindData.headAvatar.Store):GetStoreByWidget(self.bindData.headAvatar)
		avatarStore.headIcon = self:GetNpcAvatarId(info.agentId)

		self:StartRewardTimer()
	elseif not self.isShowingMsg then
		self:RewardFinished()
	end
end

function M:RewardFinished()
	if self.autoClose or gDivinerManager.spoonAutoFinish then
		gDivinerManager:FinishDivinerGame()
	else
		gClientToGameDelegate:AskDivinerTriggerResult()
		gDivinerManager:ChangeToCallNpcState()
	end
end

function M:StartRewardTimer()
	self:StopRewardTimer()

	local showTime = LTConfig.DivinerConfig.ShowCustomerRewardTime or 4
	self.rewardTimer = Timer.New(function ()
		if self.isShow then
			self:RewardFinished()
		end
	end, showTime):Start()
end

function M:StopRewardTimer()
	if self.rewardTimer then
		self.rewardTimer:Stop()

		self.rewardTimer = nil
	end
end

function M:GetNpcAvatarId(agentId)
	local unit = gCS.SceneDataMgr.GetUnit(agentId)

	if unit and unit.ClientData.AgentId > 0 then
		local agentCfg = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)

		if agentCfg and agentCfg.HeadIcon then
			return agentCfg.HeadIcon
		end
	end

	return 0
end

function M:RefreshClueList()
	self.clueList = gDivinerManager:GetDemandClueList()

	self.bindData.clueList:SetSimpleList(#self.clueList)
end

function M:RefreshStage(data)
	local state = gDivinerManager.curPlayState

	if state == gDivinerManager.PLAY_STATE.DEMAND then
		self.bindData.typeCtrl = self.PANEL_TYPE.DEMAND

		if data and data.demandCfg then
			self.bindData.npcName = self.agentName
			local personalityCfg = PersonalityConfig.GetConfig(gDivinerManager.curCustomerInfo and gDivinerManager.curCustomerInfo.PersonalityId or 0)

			if personalityCfg then
				self.bindData.npcDesc = personalityCfg.MBTI
			end

			self.clueList = gDivinerManager:GetDemandClueList()

			self.bindData.clueList:SetSimpleList(#self.clueList)
		end

		self:CheckShowInputRoot()
	elseif state == gDivinerManager.PLAY_STATE.PERSUADE then
		self.bindData.typeCtrl = self.PANEL_TYPE.PERSUADE
		self.bindData.npcName = self.agentName
		local personalityCfg = PersonalityConfig.GetConfig(gDivinerManager.curCustomerInfo and gDivinerManager.curCustomerInfo.PersonalityId or 0)

		if personalityCfg then
			self.bindData.npcDesc = personalityCfg.MBTI
		end

		if data and data.branchId then
			local branchCfg = BranchConfig.GetConfig(data.branchId)

			if branchCfg then
				self.bindData.branchDesc = branchCfg.BriefDes
			end
		end

		local demandId = gDivinerManager.curCustomerInfo and gDivinerManager.curCustomerInfo.DemandId

		if demandId then
			local demandCfg = DemandConfig.GetConfig(demandId)

			if demandCfg then
				self.bindData.demandDesc = demandCfg.BackgroundDisplay
			end
		end

		self:CheckShowInputRoot()
	elseif state == gDivinerManager.PLAY_STATE.REWARD then
		self:CheckShowReward()

		self.bindData.inputRoot.activation = false
	else
		self.bindData.typeCtrl = self.PANEL_TYPE.NORMAL
		self.bindData.inputRoot.activation = false
	end
end

function M:OnRenderClueListItem(btn, index)
	local store = gStoreManager:GetStoreGroup("DivinationClueTemplate"):GetStoreByWidget(btn)
	local data = self.clueList[index + 1]

	if store and data then
		if data.occur then
			if data.isTips then
				local demandCfg = DemandConfig.GetConfig(data.id)

				if demandCfg then
					store.clue = demandCfg.ExplorationDialogTips
				end
			else
				local clueCfg = ClueConfig.GetConfig(data.id)

				if clueCfg then
					store.clue = clueCfg.ClueDes
				end
			end

			store.tipText = ""
			store.infoCtrl = 0
		else
			store.clue = ""
			local clueCfg = ClueConfig.GetConfig(data.id)

			if clueCfg then
				store.tipText = clueCfg.ClueHint
			end

			store.infoCtrl = 1
		end
	end
end

function M:RefreshTaskDes(textId)
	local store = gStoreManager:GetStoreGroup("DivinationTaskPanelStore"):GetStoreByWidget(self.bindData.taskWidget)

	if store then
		local config = LTConfig.TextCommonTextConfig.GetConfig(textId)

		if config then
			local des = LTConfig.TextCommonTextConfig.GetConfig(textId).Text
			store.nTaskInfo = des
			store.hasGoal = 1
		end
	end
end
