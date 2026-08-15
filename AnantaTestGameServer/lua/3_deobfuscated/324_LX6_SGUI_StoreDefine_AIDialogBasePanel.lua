C_AIDialogBasePanel = DefClass("C_AIDialogBasePanel", C_AIDialogBasePanel, C_StoreGroup)
GroupName2Class.AIDialogBasePanel = C_AIDialogBasePanel
local M = C_AIDialogBasePanel
local SceneDataMgr = gCS.SceneDataMgr

function M:ctor()
	self.isShow = false
	self.curInputText = ""
	self.messageQueue = {}
	self.historyMessage = {}
	self.isShowingMsg = false
	self.curShownTime = 0
	self.messageShowInterval = 2
	self.agentName = ""
	self.curAgentId = 0
	self.curStage = 0
	self.hideInputWhenDisable = false
	self.leftNameFormat = "#IHud%s#z"
	self.autoClose = false
	self.canInput = true
end

function M:DefineAllVariables()
	return
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
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.isShow = true
	self.agentName = data.agentName
	self.curAgentId = data.agentId
	self.curStage = data.stage
	self.sendBtnCallback = data.sendBtnCallback
	self.backBtnCallback = data.backBtnCallback
	self.closeCallback = data.closeCallback
	self.onCloseDialogContent = data.onCloseDialogContent
	self.messageShowInterval = data.messageShowInterval
	self.curInputText = ""
	self.messageQueue = {}

	if data.hideInputWhenDisable then
		self.hideInputWhenDisable = true
	else
		self.hideInputWhenDisable = false
	end

	if data.history then
		self.historyMessage = data.history
	else
		self.historyMessage = {}
	end

	self.isShowingMsg = false
	self.curShownTime = 0
	self.autoClose = false

	if data.canInput == false then
		self.canInput = false
	else
		self.canInput = true
	end

	if not self.messageShowInterval or self.messageShowInterval <= 0 then
		self.messageShowInterval = 2
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

	if #self.historyMessage > 0 then
		self.bindData.historyList:SetSimpleList(#self.historyMessage)

		self.bindData.historyList.normalizedScrollPosition = Vector2.Fetch(0, 0)
	end

	self.bindData.dialogContent:SetActive(false)
	self.bindData.dialogAnim:Stop()
end

function M:OnClose()
	self.isShow = false

	if self.closeCallback then
		self.closeCallback()

		self.closeCallback = nil
	end

	self.historyMessage = nil
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ON_SYNC_AI_CHAT_ERROR] = function (eventId, data)
			if self.isShow then
				if self.hideInputWhenDisable then
					self.bindData.inputRoot:SetActive(not self.autoClose and self.canInput)
				else
					self.bindData.sendBtn.interactable = not self.autoClose and self.canInput
					self.bindData.inputField.interactable = not self.autoClose and self.canInput
				end
			end
		end,
		[gEventConstants.ON_SYNC_AI_CHAT_MESSAGE] = function (eventId, data)
			if self.isShow and self.curAgentId == data.agentId and self.curStage == data.stage then
				if data.autoClose then
					self.autoClose = true
				elseif data.autoClose == false then
					self.autoClose = false
				end

				if data.canInput then
					self.canInput = true
				elseif data.canInput == false then
					self.canInput = false
				end

				if self.hideInputWhenDisable then
					self.bindData.inputRoot:SetActive(not self.autoClose and self.canInput)
				else
					self.bindData.sendBtn.interactable = not self.autoClose and self.canInput
					self.bindData.inputField.interactable = not self.autoClose and self.canInput
				end

				self:ShowDialogContent({
					message = data.message or "",
					leftName = self.agentName or ""
				})
			end
		end,
		[gEventConstants.ON_SYNC_AI_CHAT_HISTORY] = function (eventId, data)
			if self.isShow and self.curAgentId == data.agentId and self.curStage == data.stage then
				if data.autoClose then
					self.autoClose = true
				elseif data.autoClose == false then
					self.autoClose = false
				end

				if data.canInput then
					self.canInput = true
				elseif data.canInput == false then
					self.canInput = false
				end

				table.insert(self.historyMessage, {
					message = data.message or "",
					leftName = data.agentName or ""
				})
				self.bindData.historyList:SetSimpleList(#self.historyMessage)

				self.bindData.historyList.normalizedScrollPosition = Vector2.Fetch(0, 0)
			end
		end
	}
end

function M:RegisterWidget()
	self.bindData.sendBtn.luaClick = self:CreateAction("OnClickSendBtn")
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.historyList.luaSimpleRenderItem = self:CreateAction("OnRenderHistoryListItem")
	self.bindData.historyList.luaSimpleDynamicRenderItem = self:CreateAction("OnDynamicRenderHistoryListItem")
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputFieldInputValueChanged")
	self.bindData.inputField.luaEndEdit = self:CreateAction("OnInputFieldInputEndEdit")
end

function M:OnClickSendBtn()
	if not string.is_null_or_empty(self.curInputText) then
		self.bindData.sendBtn.interactable = false
		self.bindData.inputField.interactable = false

		gClientUtils.EnvSdkReviewWords(self.curInputText, function ()
			if self.isShow then
				self.bindData.sendBtn.interactable = not self.autoClose and self.canInput
				self.bindData.inputField.interactable = not self.autoClose and self.canInput

				self:OnClickSendBtnInternal()
			end
		end, function ()
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)

			if self.isShow then
				self.bindData.sendBtn.interactable = not self.autoClose and self.canInput
				self.bindData.inputField.interactable = not self.autoClose and self.canInput
			end
		end, "AIChat")
	end
end

function M:OnClickSendBtnInternal()
	if self.sendBtnCallback and self.sendBtnCallback(self.curInputText) then
		if self.hideInputWhenDisable then
			self.bindData.inputRoot:SetActive(false)
		else
			self.bindData.sendBtn.interactable = false
			self.bindData.inputField.interactable = false
		end

		self:ShowDialogContent({
			message = self.curInputText,
			leftName = string.format(self.leftNameFormat, gPlayerManager.infoLogin.bindData.name)
		})

		self.bindData.inputField.text = ""
	end
end

function M:OnClickBackBtn()
	if self.backBtnCallback then
		self.backBtnCallback()
	else
		gPanelManager:Close(gPanelId.DIALOG_BASE_PANEL)
	end
end

function M:OnRenderHistoryListItem(btn, index)
	local data = self.historyMessage[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		store.text = self:ConcatLeftNameAndMessage(data.message, data.leftName)
	end
end

function M:OnDynamicRenderHistoryListItem(btn, index)
	local data = self.historyMessage[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		store.text = self:ConcatLeftNameAndMessage(data.message, data.leftName)
	end
end

function M:OnClickHistoryList(btn, data)
	return
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

function M:OnUpdate()
	if self.isShowingMsg and os.time() - self.curShownTime > 2 then
		local nextMsg = nil

		if #self.messageQueue > 0 then
			nextMsg = self.messageQueue[1]

			table.remove(self.messageQueue, 1)
		end

		self:ShowDialogContentInternal(nextMsg)
	end
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

	table.insert(self.historyMessage, messageData)
	self.bindData.historyList:SetSimpleList(#self.historyMessage)

	self.bindData.historyList.normalizedScrollPosition = Vector2.Fetch(0, 0)
end

function M:ShowDialogContentInternal(messageData)
	if messageData then
		self.isShowingMsg = true
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

		self.bindData.dialogContent:SetActive(true)
		self.bindData.dialogAnim:Play()
	else
		self.isShowingMsg = false

		self:CloseDialogContent()
	end
end

function M:CloseDialogContent()
	self.bindData.dialogContent:SetActive(false)
	self.bindData.dialogAnim:Stop()

	if self.autoClose then
		gPanelManager:Close(gPanelId.DIALOG_BASE_PANEL)
	end

	if self.onCloseDialogContent then
		self.onCloseDialogContent()
	end
end
