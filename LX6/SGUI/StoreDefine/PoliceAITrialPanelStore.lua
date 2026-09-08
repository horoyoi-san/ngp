-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceAITrialPanelStore.lua
-- Decompiled from: 00781_PoliceAITrialPanelStore.lua_79412a47830f.luajit

C_PoliceAITrialPanelStore = DefClass("C_PoliceAITrialPanelStore", C_PoliceAITrialPanelStore, C_StoreGroup)
GroupName2Class.PoliceAITrialPanelStore = C_PoliceAITrialPanelStore
local M = C_PoliceAITrialPanelStore
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local PoliceConfig = LTConfig.PoliceConfig
local PoliceJobUtils = L18.Gameplay.PoliceJobUtils
local ItemCfg = LTConfig.NpcInformationItemConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.STATE = {
		["`\\xfa\\x89\\xa8-\\x95!\\xe7\\xdc"] = 2,
		["\\xa8\tQ\\xb3f\\xe6\\x8f\\x8a"] = 1,
		["d\\x80\\x92\\x9a\\x82"] = 0
	}
	self.LIST_TEMPLATE = {
		["1\\xc6~)\\xf8#\\x84d\\x92c\\x9c\\x82"] = 1,
		["y\\x87\\x96\\x83\\x93"] = 0
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.mgr = gPoliceJobManager.panelMgr
	self.fuxiBridge = L50.Police.PoliceBridge
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.isShow = true

	self:InitAITrialInfo(data)
	self:SwitchToFixCamera()
	Timer.New(function ()
		gBlackScreenManager:CloseTransition(gBlackScreenId.POLICE_EXAMINE)
	end, 1):Start()
end

M.OnClose = function(self)
	self.isShow = false

	self.mgr:TriggerSpoonEndTrial(self.curSettlement)

	self.curSettlement = nil
	self.summary = nil
	self.endMessage = nil
	self.searchItems = nil
	self.listData = nil

	self:StopSettlementTimer()
	gPoliceJobManager.cs:DestroyTrialUnit()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.DIALOG_END] = function (eventId, FirstDialogId)
			if FirstDialogId ~= self.currentWaitDialog then
				self:OnWaitDialogEnd()
			end
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.sendBtn.luaClick = self.CreateAction(self, "OnClickSendBtn")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetListTIndex")
	self.bindData.messageList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderMessageListItem")
	self.bindData.messageList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderMessageListItem")
	self.bindData.messageList.onGetTIndex = self.CreateAction(self, "OnMessageListGetTIndex")
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputFieldInputValueChanged")
	self.bindData.inputField.luaEndEdit = self.CreateAction(self, "OnInputFieldInputEndEdit")
end

M.OnClickBackBtn = function(self)
	if self.curSettlement then
		return
	end

	slot1 = gPanelManager

	slot1:Close(gPanelId.POLICE_AI_TRIAL_PANEL)

	slot1 = gClientToGameDelegate

	slot1:AskInterruptInterrogation(self.caseId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.OnClickSendBtn = function(self)
	if not string.is_null_or_empty(self.curInputText) and self.leftTimes <= 0 and self.npcPersuasionLevelUpdated <= 0 and self.curStage ~= self.STATE.INPUT then
		self.bindData.sendBtn.interactable = false
		self.bindData.inputField.interactable = false

		gClientUtils.EnvSdkReviewWords(self.curInputText, function ()
			if self.isShow then
				self:OnClickSendBtnInternal()
			end
		end, function ()
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)

			if self.isShow then
				self.bindData.sendBtn.interactable = true
				self.bindData.inputField.interactable = true
			end
		end, "PoliceAITrial")
	end
end

M.OnClickSendBtnInternal = function(self)
	self.waitingMsg = 1

	table.insert(self.msgList, {
		["\\xa2\\xa25\\xa7k'\\xfb!"] = true,
		content = self.curInputText
	})

	local text = self.curInputText
	self.curInputText = nil
	self.bindData.inputField.text = ""

	self.fuxiBridge.SimpleInterrogationChat(text, false, function (data)
		if self.isShow then
			self:FuxiCallback(data)
		end
	end)
	self.RefreshMsgList(self)
end

M.FuxiCallback = function(self, data)
	self.curStage = self.STATE.INPUT
	self.waitingMsg = 0
	self.bindData.sendBtn.interactable = true
	self.bindData.inputField.interactable = true

	self.bindData.inputField:Focus()

	if gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		self.bindData.inputField:ActivateInputField()
	end

	if not data then
		self.RefreshMsgList(self)

		return
	end

	self.leftTimes = data.TurnsLeft
	local delta = data.NpcPersuasionLevelUpdated - self.npcPersuasionLevelUpdated
	self.npcPersuasionLevelUpdated = data.NpcPersuasionLevelUpdated
	self.bindData.bubbleText = delta >= 0 and delta or ""
	self.bindData.lastTimes = string.format(PoliceConfig.PoliceTrailChatRoundText, self.leftTimes)

	self.bindData.bubbleAnim:Play()
	self.bindData.hpProgress:ProgressToValue(self.npcPersuasionLevelUpdated)

	self.bindData.hp = self.npcPersuasionLevelUpdated

	if not string.is_null_or_empty(data.InterrogationSummary) then
		self.summary = data.InterrogationSummary
		local msg = string.split(data.Msg, "\n")
		self.endMessage = msg[1]
		self.endMessageHali = msg[2]
	else
		table.insert(self.msgList, {
			["\\xa2\\xa25\\xa7k'\\xfb!"] = false,
			content = data.Msg
		})
		self.RefreshMsgList(self)
	end

	if data.TaskResult >= 0 or self.leftTimes > 0 or self.npcPersuasionLevelUpdated < 0 then
		self.curStage = self.STATE.SETTLEMENT
		local sessionId = self.fuxiBridge.GetCurrentSessionId()
		slot4 = gClientToGameDelegate

		slot4:AskFinishAIInterrogation(self.caseId, {
			SessionID = sessionId
		}).Callback = function (err, settlement)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
				gPanelManager:Close(gPanelId.POLICE_AI_TRIAL_PANEL)

				return
			end

			if self.isShow then
				self:StartSettlementTimer(settlement)
			end
		end
	end
end

M.GMSkipPoliceAITrial = function(self, state)
	if self.curStage == self.STATE.SETTLEMENT then
		slot2 = gClientToGameGMDelegate

		slot2:GmFinishCurrentInterrogation(state).Callback = function (err, res)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
				gPanelManager:Close(gPanelId.POLICE_AI_TRIAL_PANEL)

				return
			end

			if self.isShow then
				if res.aiResult then
					self.curSettlement = res.aiResult

					self:StartSettlement()
				else
					gPanelManager:Close(gPanelId.POLICE_AI_TRIAL_PANEL)
				end
			end
		end
	end
end

M.RefreshMsgList = function(self)
	self.bindData.messageList:SetSimpleList(#self.msgList + self.waitingMsg)
	self.bindData.messageList:GoToIndex(#self.msgList + self.waitingMsg - 1, false)
end

M.StartSettlementTimer = function(self, settlement)
	self.curSettlement = settlement
	self.timer = Timer.New(function ()
		if self.isShow then
			self:StartSettlement()

			self.timer = nil
		end
	end, 2):Start()
end

M.StopSettlementTimer = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.StartSettlement = function(self)
	if self.curSettlement then
		self.rootWidget:SetActiveQuickly(false)
		self:ShowEndDialog()
	else
		gPanelManager:Close(gPanelId.POLICE_AI_TRIAL_PANEL)
	end
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.listData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= self.LIST_TEMPLATE.TITLE then
		if data.textId then
			local title = TextScriptTextConfig.GetConfig(data.textId).Text
			store.label = title
		elseif data.title then
			store.label = data.title
		end

		store.content = data.content
	else
		store.list.luaSimpleRenderItem = function(itemBtn, itemIndex)
			local itemData = self.searchItems[itemIndex + 1]

			if not itemData then
				return
			end

			local itemStore = gStoreManager:GetStoreGroup(itemBtn.Store):GetStoreByWidget(itemBtn)

			if not itemStore then
				return
			end

			itemStore.text = itemData.name
			itemStore.checkCtrl = itemData.check and 1 or 0
		end

		store.list:SetSimpleList(#self.searchItems)
	end
end

M.OnGetListTIndex = function(self, index)
	local data = self.listData[index + 1]

	if not data then
		return 0
	end

	return data.tIndex or 0
end

M.OnSimpleRenderMessageListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.msgList[index + 1]

	if not data then
		if self.waitingMsg <= 0 then
			store.title = self.npcName
		end

		return
	end

	store.title = data.isPlayer and self.playerName or self.npcName
	store.content = data.content
end

M.OnMessageListGetTIndex = function(self, index)
	local data = self.msgList[index + 1]

	if data then
		return 0
	end

	return 1
end

M.OnInputFieldInputValueChanged = function(self, text)
	self.curInputText = text
end

M.OnInputFieldInputEndEdit = function(self, text, enter)
	self.curInputText = text

	if enter then
		self.OnClickSendBtn(self)
	end
end

M.InitAITrialInfo = function(self, data)
	self.curSettlement = nil
	self.summary = nil
	self.endMessage = nil
	self.endMessageHali = nil
	self.caseId = data.caseId
	self.waitingMsg = 0
	local caseInfo = self.mgr:GetCaseInfo(self.caseId)

	self:InitBasicInfo(caseInfo, data.fuxiData)

	self.msgList = {}
	self.curStage = self.STATE.INPUT
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = LTConfig.FightSpiritConfig.GetConfig(tid)
	self.playerName = spirit.Name
	self.bindData.lastTimes = string.format(PoliceConfig.PoliceTrailChatRoundText, self.leftTimes)

	self.bindData.hpProgress:ResetValue(self.npcPersuasionLevelUpdated, 0, 0, self.npcPersuasionLevelUpdated)

	self.bindData.hp = self.npcPersuasionLevelUpdated

	self.bindData.messageList:SetSimpleList(#self.msgList + self.waitingMsg)
	self.bindData.list:SetSimpleList(#self.listData)

	self.bindData.inputField.disableReviewWords = true
end

M.InitBasicInfo = function(self, caseInfo, fuxiData)
	self.isHali = caseInfo.NpcId ~= LTConfig.PoliceConfig.TaskTrailHarryAgentid

	if self.isHali then
		self.InitHaliBasicInfo(self, caseInfo, fuxiData)
	else
		self.InitNormalBasicInfo(self, caseInfo, fuxiData)
	end
end

M.InitHaliBasicInfo = function(self, caseInfo, fuxiData)
	local agentCfg = LTConfig.AgentConfig.GetConfig(LTConfig.PoliceConfig.TaskTrailHarryAgentid)

	if not agentCfg then
		print_error("Police initialize ai trial info failed.Can not find agent config by id " .. tostring(caseInfo.NpcId))

		return
	end

	self.npcName = PoliceConfig.TaskTrailHarryName[2]
	self.npcPersonality = agentCfg.Personality
	self.npcSex = agentCfg.SexType ~= UX.Game.SexType.Male and 1 or 2
	self.npcIsFake = caseInfo.IsFakePerson
	self.npcPersuasionLevelUpdated = fuxiData.NpcPersuasionLevelUpdated
	self.leftTimes = fuxiData.TurnsLeft
	self.bindData.npcName = self.npcName
	self.bindData.stateCtrl = 1
	self.bindData.inputPlaceHolder = PoliceConfig.TaskTrailHarryWorkAction
	self.listData = {}

	table.insert(self.listData, {
		tIndex = self.LIST_TEMPLATE.TITLE,
		title = PoliceConfig.TaskTrailHarryName[1],
		content = PoliceConfig.TaskTrailHarryName[2]
	})
	table.insert(self.listData, {
		tIndex = self.LIST_TEMPLATE.TITLE,
		title = PoliceConfig.TaskTrailHarryAge[1],
		content = PoliceConfig.TaskTrailHarryAge[2]
	})
	table.insert(self.listData, {
		tIndex = self.LIST_TEMPLATE.TITLE,
		title = PoliceConfig.TaskTrailHarryJob[1],
		content = PoliceConfig.TaskTrailHarryJob[2]
	})
	table.insert(self.listData, {
		tIndex = self.LIST_TEMPLATE.TITLE,
		title = PoliceConfig.TaskTrailHarryKPI[1],
		content = PoliceConfig.TaskTrailHarryKPI[2]
	})
	table.insert(self.listData, {
		tIndex = self.LIST_TEMPLATE.TITLE,
		title = PoliceConfig.TaskTrailHarryMarriage[1],
		content = PoliceConfig.TaskTrailHarryMarriage[2]
	})

	self.searchItems = {}
	local count = #PoliceConfig.TaskTrailHarryItem

	if count <= 0 then
		for i = 1, count do
			table.insert(self.searchItems, {
				["N\\xa6\\xa7\\xac\\xbd"] = false,
				name = PoliceConfig.TaskTrailHarryItem[i]
			})
		end
	end

	if #self.searchItems <= 0 then
		table.insert(self.listData, {
			tIndex = self.LIST_TEMPLATE.SEARCH_RESULT
		})
	end

	gDialogManager:ShowGeneralDialog(PoliceConfig.TaskTrailHarryOpenningDialogAI, gDialogSource.Police)
end

M.InitNormalBasicInfo = function(self, caseInfo, fuxiData)
	local agentCfg = LTConfig.AgentConfig.GetConfig(caseInfo.NpcId)

	if not agentCfg then
		print_error("Police initialize ai trial info failed.Can not find agent config by id " .. tostring(caseInfo.NpcId))

		return
	end

	self.npcName = agentCfg.Name
	local npcJob = agentCfg.JobFakeTag
	self.npcPersonality = agentCfg.Personality
	self.npcSex = agentCfg.SexType ~= UX.Game.SexType.Male and 1 or 2
	self.npcIsFake = caseInfo.IsFakePerson
	self.npcPersuasionLevelUpdated = fuxiData.NpcPersuasionLevelUpdated
	self.leftTimes = fuxiData.TurnsLeft
	self.bindData.npcName = self.npcName
	self.bindData.stateCtrl = 0
	self.bindData.inputPlaceHolder = PoliceConfig.PoliceTrailWorkAction
	self.listData = {}

	table.insert(self.listData, {
		["M\\x89\\x9a\\xaaE"] = 89901553,
		tIndex = self.LIST_TEMPLATE.TITLE,
		content = fuxiData.PoliceReport
	})
	table.insert(self.listData, {
		["M\\x89\\x9a\\xaaE"] = 89901443,
		tIndex = self.LIST_TEMPLATE.TITLE,
		content = npcJob
	})

	self.searchItems = {}

	if caseInfo.CrimeDefaultItems.Count <= 0 then
		for i = 1, caseInfo.CrimeDefaultItems.Count do
			local itemConfig = ItemCfg.GetConfig(caseInfo.CrimeDefaultItems[i])
			local check = itemConfig and itemConfig.Type == ItemCfg.TypeType.Safe
			local fineId = 0

			if check then
				fineId = gPoliceJobManager.examineMgr:GetFineIdByItemType(itemConfig.Type)
			end

			if itemConfig then
				table.insert(self.searchItems, {
					name = itemConfig.Name,
					fineId = fineId,
					check = check
				})
			end
		end
	end

	if #self.searchItems <= 0 then
		table.insert(self.listData, {
			tIndex = self.LIST_TEMPLATE.SEARCH_RESULT
		})
	end

	self.currentWaitDialog = PoliceConfig.PoliceTrailOpenningDialog

	gDialogManager:ShowGeneralDialog(PoliceConfig.PoliceTrailOpenningDialog, gDialogSource.Police)
end

M.OnWaitDialogEnd = function(self)
	if self.currentWaitDialog ~= PoliceConfig.PoliceTrailOpenningDialog then
		PoliceJobUtils.ShowTrailAIDialog(self.mgr.TRIAL_DIALOG_TYPE.RPS_START, self.npcPersonality, self.npcSex, self.npcIsFake)
	elseif self.currentWaitDialog ~= PoliceConfig.PoliceTrailSuccessNpcDialog or self.currentWaitDialog ~= PoliceConfig.PoliceTrailSuccessHaliDialog then
		self.ShowEndDialog(self)
	end
end

M.ShowEndDialog = function(self)
	if self.endMessage or self.endMessageHali then
		self.currentWaitDialog = self.isHali and PoliceConfig.PoliceTrailSuccessHaliDialog or PoliceConfig.PoliceTrailSuccessNpcDialog
		local param = gDialogManager:CreateDialogParam()

		if self.endMessage then
			param.CustomStr = self.endMessage
			self.endMessage = nil
		elseif self.endMessageHali then
			param.CustomStr = self.endMessageHali
			self.endMessageHali = nil
		end

		gDialogManager:ShowGeneralDialog(self.currentWaitDialog, gDialogSource.Police, nil, param)
	else
		local settlement = self.curSettlement
		local summary = self.summary

		gPanelManager:Close(gPanelId.POLICE_AI_TRIAL_PANEL)

		if not self.isHali then
			gPanelManager:CheckShow(gPanelId.POLICE_TRIAL_RESULT_PANEL, {
				settlement = settlement,
				summary = summary
			})
		end
	end
end

M.SwitchToFixCamera = function(self)
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("PoliceTrialPanel")

	if not cmRegister then
		return
	end

	local playerTrans = gCS.MyPlayerManager.PlayerUnit.PlayerObj
	local worldPos = playerTrans.TransformPoint(playerTrans, PoliceConfig.PoliceTrailCameraPos[1], PoliceConfig.PoliceTrailCameraPos[2], PoliceConfig.PoliceTrailCameraPos[3])
	local dir = Quaternion.Euler(PoliceConfig.PoliceTrailCameraRot[1], PoliceConfig.PoliceTrailCameraRot[2], PoliceConfig.PoliceTrailCameraRot[3]) * Vector3.forward
	local worldEuler = Quaternion.LookRotation(playerTrans.TransformDirection(playerTrans, dir)).eulerAngles
	local cameraName = "FixCam1"
	local cm = cmRegister.GetVcamByName(cmRegister, cameraName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFixCameraData(cm.gameObject, worldPos, worldEuler, PoliceConfig.PoliceTrailCameraFoV)
	cmRegister:EnableVCamera(cameraName, LX6.Cinemachine.EVcamPriority.Panel)
end
