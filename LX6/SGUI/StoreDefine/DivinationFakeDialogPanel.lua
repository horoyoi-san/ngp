-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DivinationFakeDialogPanel.lua
-- Decompiled from: 01895_DivinationFakeDialogPanel.lua_0575eaa2d2be.luajit

C_DivinationFakeDialogPanel = DefClass("C_DivinationFakeDialogPanel", C_DivinationFakeDialogPanel, C_StoreGroup)
GroupName2Class.DivinationFakeDialogPanel = C_DivinationFakeDialogPanel
local M = C_DivinationFakeDialogPanel
local SceneDataMgr = gCS.SceneDataMgr
local DivinerClueConfig = LTConfig.DivinerClueConfig
local DivinerConfig = LTConfig.DivinerConfig
local PersonalityConfig = LTConfig.DivinerPersonalityConfig

M.ctor = function(self)
	self.curInputText = ""
	self.PANEL_TYPE = {
		["\\x9b\\x947\\x98_\\xda"] = 3,
		["\\xabFB"] = 1,
		["2g\\xa3\\xa3\\xa2m"] = 0,
		["8m\\xbc\\xaf\\xade"] = 2
	}
	self.NEXT_STAGE = {
		["2g\\xa3\\xa3\\xa2m"] = 0,
		["\\x9f\\x98(\\x8eU\\xcb"] = 3,
		["\\Tw"] = 1,
		[">i\\xa5\\xba\\xafd"] = 2
	}
	self.CLUE_TEMPLATE_TYPE = {
		["YH~"] = 1,
		["\\xaf[M"] = 0,
		["~\\x9e\\x8e\\x86\\x82"] = 2
	}
	self.STATUS_TYPE = {
		["\\x9b\\x947\\x98_\\xda"] = 1,
		["\\x8a\\x851\\x82^\\xda"] = 0,
		["\\x9b\\x901\\x82O\\xdd"] = 2
	}
	self.leftNameFormat = "#IHud%s#z"
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.gamepadUpdateRotate = false
	self.isGamePadMode = false
end

M.DefineAllVariables = function(self)
	self.isShow = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.isShow = true

	self.InitData(self)

	gDivinerManager.fakeDialogPanel = self

	if gDivinerManager.spoonNeedShowToDemand then
		gDivinerManager:StartDemandAIDialog()
	else
		self.TriggerIntoCallNpcStage(self)
	end

	if gDivinerManager.needOpenLivestream then
		self.InitLiveChatPanel(self)
	else
		gDivinerManager.isInLivestream = false
		self.bindData.showLivestreamCtrl = 0
	end

	self.RefreshLiveBtn(self)
	self.InitAIDialogBasePanel(self)
	self.RefreshStage(self)
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(self.m_Id, 1)
end

M.OnClose = function(self)
	self.isShow = false
	gDivinerManager.fakeDialogPanel = nil

	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(self.m_Id)
	self.StopRewardTimer(self)
end

M.OnUpdate = function(self)
	if self.triggerNextTime and self.triggerNextTime >= gLuaDataManager.serverTime then
		self.triggerNextTime = nil

		if gDivinerManager.curPlayState ~= gDivinerManager.PLAY_STATE.DEMAND then
			if self.nextStage ~= self.NEXT_STAGE.NORMAL then
				gDivinerManager:CheckDemandAIChatFinish()
			elseif self.nextStage ~= self.NEXT_STAGE.FAIL then
				gDivinerManager:CheckDemandAIChatFailFinish()
			elseif self.nextStage ~= self.NEXT_STAGE.BATTLE or self.nextStage ~= self.NEXT_STAGE.TIME_OUT then
				gDivinerManager:CheckDemandAIChatFailFinish()
			end
		elseif gDivinerManager.curPlayState ~= gDivinerManager.PLAY_STATE.PERSUADE then
			if self.nextStage ~= self.NEXT_STAGE.NORMAL then
				gDivinerManager:CheckPersuadeAIChatFinish()
			elseif self.nextStage ~= self.NEXT_STAGE.FAIL then
				gDivinerManager:CheckPersuadeAIChatFinish()
			elseif self.nextStage ~= self.NEXT_STAGE.BATTLE or self.nextStage ~= self.NEXT_STAGE.TIME_OUT then
				gDivinerManager:CheckPersuadeAIChatFinish()
			end
		end
	end

	if #self.statusQueue <= 0 then
		local curTime = gLogicTime.time
		local count = #self.statusQueue

		for i = 1, count do
			local index = count - i + 1

			if self.statusQueue[index].time >= curTime then
				table.remove(self.statusQueue, index)
			end
		end

		self.needRefreshStatus = true
	end

	if self.needRefreshStatus then
		self.needRefreshStatus = false

		self.bindData.statusList:SetSimpleList(#self.statusQueue)
	end

	if self.isGamePadMode then
		self.UpdateCameraRotateGamePad(self)
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.isGamePadMode = SGUI.GameDevice.KeyboardMouse <= device

	if self.bindData.backBtn then
		self.bindData.backBtn.interactable = not self.SubGroup.AIDialogBasePanel.inputFieldActive or self.isGamePadMode
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.callNpcBtn.luaClick = self.CreateAction(self, "OnClickCallNpcBtn")
	self.bindData.nextBtn.luaClick = self.CreateAction(self, "OnClickNextBtn")
	self.bindData.liveBtn.luaClick = self.CreateAction(self, "OnClickLiveBtn")
	self.bindData.demandList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderDemandItem")
	self.bindData.demandList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleDynamicRenderDemandItem")
	self.bindData.demandList.onGetTIndex = self.CreateAction(self, "OnGetDemandTIndex")
	self.bindData.statusList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderStatusItem")

	if self.bindData.cameraRotateRespond then
		self.bindData.cameraRotateRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")
	end
end

M.OnSimpleRenderDemandItem = function(self, btn, index)
	self.OnRenderDemandItem(self, btn, index, false)
end

M.OnSimpleDynamicRenderDemandItem = function(self, btn, index)
	self.OnRenderDemandItem(self, btn, index, true)
end

M.OnRenderDemandItem = function(self, btn, index, dynamic)
	local data = self.clueList[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= self.CLUE_TEMPLATE_TYPE.SPLIT then
		return
	end

	if data.tIndex ~= self.CLUE_TEMPLATE_TYPE.CLUE then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		store.checkCtrl = data.check and 1 or 0
		store.index = string.format("0%d", data.index)
		local clueCfg = DivinerClueConfig.GetConfig(data.id)

		if data.check then
			store.foldCtrl = 0
			store.clueDesc = data.summary or ""
			store.clueTitle = clueCfg.ClueHint or ""
		else
			local preData = self.clueList[data.preDataIndex]

			if not preData or preData and preData.check then
				store.foldCtrl = 0
				store.clueDesc = DivinerConfig.CurUnlockClueDes or ""
				store.clueTitle = clueCfg.ClueHint or ""
			else
				store.foldCtrl = 1
				store.clueDesc = ""
				store.clueTitle = DivinerConfig.CurUnlockClueTitle or ""
			end
		end

		if dynamic then
			store.layout:ForceRebuildLayoutImmediate()
		end
	elseif data.tIndex ~= self.CLUE_TEMPLATE_TYPE.ASK then
		btn.title.text = gDivinerManager:GetDemandExplorationTips()
	end
end

M.OnGetDemandTIndex = function(self, index)
	local data = self.clueList[index + 1]

	if data then
		return data.tIndex or 0
	end

	return 0
end

M.OnSimpleRenderStatusItem = function(self, btn, index)
	local data = self.statusQueue[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.statusCtrl = data.type
	store.arrowCountCtrl = 0
	store.arrowDirectionCtrl = data.up and 0 or 1
	store.content = data.content or ""
end

M.OnClickBackBtn = function(self)
	gDivinerManager:FinishDivinerGame(true)
end

M.OnClickCallNpcBtn = function(self)
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
		["PNkgO:!"] = "\\xe3i\\xa5\\xcb\\x9d|\\xfe\\xc6b쒊m\\x91Mw\\x8f\\xf2",
		entityInstanceId = gDivinerManager.spoonInstanceId
	})
	gDivinerManager:SendPlayerCallNpc()
	self:DeactiveCallNpcBtnState()
end

M.OnClickNextBtn = function(self)
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, {
		["PNkgO:!"] = "\\xe3i\\xa5\\xcb\\x9d|\\xfe\\xc6b쒊m\\x91Mw\\x8f\\xf2",
		entityInstanceId = gDivinerManager.spoonInstanceId
	})
	gDivinerManager:SendPlayerCallNextNpc()
	self:DeactiveCallNpcBtnState()
end

M.OnClickLiveBtn = function(self)
	if not gDivinerManager.isInLivestream then
		self.InitLiveChatPanel(self)
		self.RefreshLiveBtn(self)
	end
end

M.TriggerIntoCallNpcStage = function(self)
	self.RefreshStage(self)
end

M.StartDemandOrPersuadeStage = function(self, data, waitFunc)
	self.autoClose = false
	self.agentName = data.agentName
	self.curAgentId = data.agentId
	self.curStage = data.stage
	self.curShownTime = 0

	if data.canInput ~= false then
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

	if gDivinerManager.curPlayState ~= gDivinerManager.PLAY_STATE.DEMAND then
		data.demandCfg = LTConfig.DivinerDemandConfig.GetConfig(gDivinerManager.curCustomerInfo and gDivinerManager.curCustomerInfo.DemandId or 0)
		dialogId = data.demandCfg and data.demandCfg.DialogId
	elseif gDivinerManager.curPlayState ~= gDivinerManager.PLAY_STATE.PERSUADE then
		local branchCfg = LTConfig.DivinerBranchConfig.GetConfig(gDivinerManager.curBranchId or 0)
		dialogId = branchCfg and branchCfg.DialogId
	end

	dialogId = 0

	if dialogId and dialogId <= 0 then
		-- Nothing
	elseif waitFunc then
		waitFunc()
	end

	self.bindData.moodValue = gDivinerManager.curAttitude / 100
	self.bindData.patienceValue = gDivinerManager.curPatience / gDivinerManager.maxPatience

	self.RefreshStage(self, data)
end

M.DemandFinished = function(self)
	self.nextStage = self.NEXT_STAGE.NORMAL

	self.CommonDemandFinish(self)
end

M.DemandNormalFailed = function(self)
	self.nextStage = self.NEXT_STAGE.FAIL

	self.CommonDemandFinish(self)
end

M.DemandBattleFailed = function(self)
	self.nextStage = self.NEXT_STAGE.BATTLE
	self.autoClose = true

	self.CommonDemandFinish(self)
end

M.DemandTimeOutFailed = function(self)
	self.nextStage = self.NEXT_STAGE.TIME_OUT

	self.TriggerStartDelayToNextStage(self)
end

M.CommonDemandFinish = function(self)
	local langType = gDivinerManager:GetCurLanguageAbbreviation() or "CN"

	gClientToGameDelegate:AskDivinerFinishRequestAppeal(gDivinerManager.curCustomerInfo.AgentId, langType).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gDivinerManager:FinishDivinerGame(true)
		end
	end
end

M.PersuadeFinished = function(self)
	self.CommonPersuadeFinish(self)

	self.canInput = false
	self.nextStage = self.NEXT_STAGE.NORMAL
end

M.PersuadeNormalFailed = function(self)
	self.nextStage = self.NEXT_STAGE.FAIL

	self.CommonPersuadeFinish(self)
end

M.PersuadeBattleFailed = function(self)
	self.autoClose = true
	self.nextStage = self.NEXT_STAGE.BATTLE

	self.CommonPersuadeFinish(self)
end

M.PersuadeTimeOutFailed = function(self)
	self.nextStage = self.NEXT_STAGE.TIME_OUT
end

M.CommonPersuadeFinish = function(self)
	local langType = gDivinerManager:GetCurLanguageAbbreviation() or "CN"

	gClientToGameDelegate:AskDivinerFinishPersuade(gDivinerManager.curCustomerInfo.AgentId, langType).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gDivinerManager:FinishDivinerGame(true)
		end
	end
end

M.TriggerStartDelayToNextStage = function(self)
	if not self.triggerNextTime then
		self.triggerNextTime = gLuaDataManager.serverTime + (DivinerConfig.NextStageInterval or 2)
	end
end

M.TriggerIntoRewardStage = function(self)
	self.RefreshStage(self)
end

M.CheckShowReward = function(self)
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
	else
		self.RewardFinished(self)
	end
end

M.RewardFinished = function(self)
	if self.autoClose or gDivinerManager.spoonAutoFinish then
		gDivinerManager:FinishDivinerGame()
	else
		gClientToGameDelegate:AskDivinerTriggerResult()
		gDivinerManager:ChangeToCallNpcState()
	end
end

M.StartRewardTimer = function(self)
	self:StopRewardTimer()

	local showTime = LTConfig.DivinerConfig.ShowCustomerRewardTime or 4
	self.rewardTimer = Timer.New(function ()
		if self.isShow then
			self:RewardFinished()
		end
	end, showTime):Start()
end

M.StopRewardTimer = function(self)
	if self.rewardTimer then
		self.rewardTimer:Stop()

		self.rewardTimer = nil
	end
end

M.GetNpcAvatarId = function(self, agentId)
	local unit = gCS.SceneDataMgr.GetUnit(agentId)

	if unit and unit.ClientData.AgentId <= 0 then
		local agentCfg = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)

		if agentCfg and agentCfg.HeadIcon then
			return agentCfg.HeadIcon
		end
	end

	return 0
end

M.RefreshClueList = function(self)
	local clues = gDivinerManager:GetDemandClueList()
	self.clueList = {
		{
			tIndex = self.CLUE_TEMPLATE_TYPE.ASK
		}
	}
	local preDataIndex = 0

	for i = 1, #clues do
		local clue = clues[i]
		clue.tIndex = self.CLUE_TEMPLATE_TYPE.CLUE
		clue.index = i
		clue.preDataIndex = preDataIndex

		table.insert(self.clueList, clue)

		preDataIndex = #self.clueList

		table.insert(self.clueList, {
			tIndex = self.CLUE_TEMPLATE_TYPE.SPLIT
		})
	end

	self.bindData.demandList:SetSimpleList(#self.clueList)
end

M.RefreshStage = function(self, data)
	local state = gDivinerManager.curPlayState

	if state ~= gDivinerManager.PLAY_STATE.DEMAND then
		self.bindData.typeCtrl = self.PANEL_TYPE.DEMAND

		if data and data.demandCfg then
			self.bindData.npcName = self.agentName
			self.bindData.npcIcon = self:GetNpcAvatarId(self.curAgentId or 0)
			local personalityCfg = PersonalityConfig.GetConfig(gDivinerManager.curCustomerInfo and gDivinerManager.curCustomerInfo.PersonalityId or 0)

			if personalityCfg then
				self.bindData.npcDesc = personalityCfg.MBTI
			end

			self.RefreshClueList(self)
		end

		self.SubGroup.AIDialogBasePanel:ActivateInputField()
	elseif state ~= gDivinerManager.PLAY_STATE.PERSUADE then
		self.bindData.typeCtrl = self.PANEL_TYPE.PERSUADE
		self.bindData.npcName = self.agentName
		self.bindData.npcIcon = self:GetNpcAvatarId(self.curAgentId or 0)
		local personalityCfg = PersonalityConfig.GetConfig(gDivinerManager.curCustomerInfo and gDivinerManager.curCustomerInfo.PersonalityId or 0)

		if personalityCfg then
			self.bindData.npcDesc = personalityCfg.MBTI
		end

		local pathCfg = LTConfig.DivinerPathConfig.GetConfig(data and data.persuadeId)
		self.bindData.persuadeTitle = pathCfg.PathDes or ""
		self.bindData.persuadeProgress.maxValue = pathCfg.SucessPersuasion or 100
		self.bindData.persuadeProgress.value = gDivinerManager.curPersuasion

		self.SubGroup.AIDialogBasePanel:ActivateInputField()
	elseif state ~= gDivinerManager.PLAY_STATE.REWARD then
		self.CheckShowReward(self)
	else
		self.bindData.typeCtrl = self.PANEL_TYPE.NORMAL

		self.ActiveCallNpcBtnState(self)
	end

	self.RefreshInputShowState(self)
end

M.InitData = function(self)
	self.messageQueue = {}
	self.statusQueue = {}
	self.curShownTime = 0
	self.statusShowTime = 2
	self.nextStage = self.NEXT_STAGE.NORMAL
	self.autoClose = false
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(gSpiritManager:GetCurFirstSpiritTid())
	self.playerName = spiritCfg and spiritCfg.Name or ""
	self.playerIcon = spiritCfg and spiritCfg.SHeadIconID or 0

	self:ActiveCallNpcBtnState()

	self.isGamePadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
end

M.AddAttitudeUp = function(self)
	table.insert(self.statusQueue, {
		[""] = true,
		type = self.STATUS_TYPE.ATTITUDE,
		time = gLogicTime.time + self.statusShowTime,
		content = DivinerConfig.AttitudeUp
	})

	self.needRefreshStatus = true
end

M.AddAttitudeDown = function(self)
	table.insert(self.statusQueue, {
		[""] = false,
		type = self.STATUS_TYPE.ATTITUDE,
		time = gLogicTime.time + self.statusShowTime,
		content = DivinerConfig.AttitudeDown
	})

	self.needRefreshStatus = true
end

M.AddPatienceUp = function(self)
	table.insert(self.statusQueue, {
		[""] = true,
		type = self.STATUS_TYPE.PATIENCE,
		time = gLogicTime.time + self.statusShowTime,
		content = DivinerConfig.PatienceUp
	})

	self.needRefreshStatus = true
end

M.AddPatienceDown = function(self)
	table.insert(self.statusQueue, {
		[""] = false,
		type = self.STATUS_TYPE.PATIENCE,
		time = gLogicTime.time + self.statusShowTime,
		content = DivinerConfig.PatienceDown
	})

	self.needRefreshStatus = true
end

M.AddPersuadeUp = function(self)
	table.insert(self.statusQueue, {
		[""] = true,
		type = self.STATUS_TYPE.PERSUADE,
		time = gLogicTime.time + self.statusShowTime,
		content = DivinerConfig.PersuadeUp
	})

	self.needRefreshStatus = true
end

M.AddPersuadeDown = function(self)
	table.insert(self.statusQueue, {
		[""] = false,
		type = self.STATUS_TYPE.PERSUADE,
		time = gLogicTime.time + self.statusShowTime,
		content = DivinerConfig.PersuadeDown
	})

	self.needRefreshStatus = true
end

M.RefreshInputShowState = function(self)
	local showInput = false

	if gDivinerManager.curPlayState ~= gDivinerManager.PLAY_STATE.DEMAND or gDivinerManager.curPlayState ~= gDivinerManager.PLAY_STATE.PERSUADE then
		showInput = true
	end

	self.bindData.showInputCtrl = showInput and 0 or 1
end

M.ActiveCallNpcBtnState = function(self)
	self.bindData.callNpcBtn.interactable = true
	self.bindData.nextBtn.interactable = true
end

M.DeactiveCallNpcBtnState = function(self)
	self.bindData.callNpcBtn.interactable = false
	self.bindData.nextBtn.interactable = false
end

M.InitLiveChatPanel = function(self)
	gDivinerManager.isInLivestream = true
	self.bindData.showLivestreamCtrl = 1
	slot1 = self.SubGroup.DivinerLivestreamPanelStore

	slot1:SetData({
		streamerIconId = self.playerIcon,
		streamerName = self.playerName
	})

	slot1 = gClientToGameDelegate

	slot1:AskDivinerLiveChatOpen(gDivinerManager.divinerLangType).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gDivinerManager:SendStartLiveChatEvent()
	end
end

M.InitAIDialogBasePanel = function(self)
	local autoNextTime = DivinerConfig.AutoNextDialogTime or 3
	self.bindData.backBtn.interactable = true

	self.SubGroup.AIDialogBasePanel:InitData(self:CreateAction("OnPlayerSendMessage"), self.playerName, autoNextTime, nil, self:CreateAction("OnInputFieldActiveCallback"), self:CreateAction("OnInputFieldDeActiveCallback"), DivinerConfig.ChatBoxInputMaxCharacters)
end

M.OnInputFieldActiveCallback = function(self)
	self.bindData.backBtn.interactable = self.isGamePadMode
end

M.OnInputFieldDeActiveCallback = function(self)
	self.bindData.backBtn.interactable = true
end

M.OnPlayerSendMessage = function(self, curInputText)
	local sendDemandOrPersuadeSuccess = false

	if gDivinerManager.curPlayState ~= gDivinerManager.PLAY_STATE.DEMAND then
		sendDemandOrPersuadeSuccess = gDivinerManager:SendDemandAIMessage(curInputText, self.curAgentId, self.curStage)
	elseif gDivinerManager.curPlayState ~= gDivinerManager.PLAY_STATE.PERSUADE then
		sendDemandOrPersuadeSuccess = gDivinerManager:SendPersuadeAIMessage(curInputText, self.curAgentId, self.curStage)
	end

	return sendDemandOrPersuadeSuccess
end

M.OnSyncAIChatError = function(self)
	if self.isShow then
		self.SubGroup.AIDialogBasePanel:ResetInputState()
	end
end

M.OnSyncAIChatMessage = function(self, data)
	if self.isShow and self.curAgentId ~= data.agentId and self.curStage ~= data.stage then
		if data.canInput then
			self.canInput = true
		elseif data.canInput ~= false then
			self.canInput = false
		end

		self.bindData.moodValue = gDivinerManager.curAttitude / 100
		self.bindData.patienceValue = gDivinerManager.curPatience / gDivinerManager.maxPatience

		if self.curStage ~= gDivinerManager.CHAT_STAGE.PERSUADE then
			self.bindData.persuadeProgress:ProgressToValue(gDivinerManager.curPersuasion)
		end

		self.SubGroup.AIDialogBasePanel:OnSyncAIMessageTable(data.message or "", self.agentName or "", data.waitFunc, self.canInput, true)
	end
end

M.OnRightStickControl = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		self.gamepadUpdateRotate = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.gamepadUpdateRotate = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0
	end
end

M.UpdateCameraRotateGamePad = function(self)
	if not self.gamepadUpdateRotate then
		return
	end

	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if gCS.ShootModule.GetIsInVehicleShootState(csUnit) or gCS.ShootModule.GetIsInVehicleForwardShootState(csUnit) then
		gCameraUtils:DoRotateCameraByGamePad(6, self.rightStickValue.x, self.rightStickValue.y)
	else
		gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
	end
end

M.RefreshLiveBtn = function(self)
	if not gDivinerManager.needOpenLivestream and not gDivinerManager.isInLivestream and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.DivinerLive) then
		self.bindData.showLivestreamBtnCtrl = 1
	else
		self.bindData.showLivestreamBtnCtrl = 0
	end
end
