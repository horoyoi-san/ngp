-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AIDialogBasePanel.lua
-- Decompiled from: 01597_AIDialogBasePanel.lua_51efde077c8e.luajit

C_AIDialogBasePanel = DefClass("C_AIDialogBasePanel", C_AIDialogBasePanel, C_StoreGroup)
GroupName2Class.AIDialogBasePanel = C_AIDialogBasePanel
local M = C_AIDialogBasePanel

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.INPUT_STATE = {
		["C\\xdd\\xd8\\xe2X\\xe7t\\xa5\"r\\xf3\\xd2"] = 0,
		["\\xee\\xfa=)!\\xd8"] = 1
	}
	self.INPUT_FILED_CTRL = {
		["H\\xa3\\xb2\\xbb\\xaf"] = 1,
		["\\xbf\\xb9\\xa5a7\\xf04"] = 2,
		["LQi{M,"] = 3,
		["G\\x83\\x83\\x82M"] = 0
	}
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
end

M.OnClose = function(self)
	self.ClearData(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.sendBtn.luaClick = self.CreateAction(self, "OnClickSendBtn")
	self.bindData.reviewBtn.luaClick = self.CreateAction(self, "OnClickReviewBtn")
	self.bindData.reviewBackBtn.luaClick = self.CreateAction(self, "OnClickReviewBackBtn")
	self.bindData.reviewList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderHistoryListItem")
	self.bindData.reviewList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnDynamicRenderHistoryListItem")
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputFieldInputValueChanged")
	self.bindData.inputField.luaEndEdit = self.CreateAction(self, "OnInputFieldInputEndEdit")
	self.bindData.inputField.onActivateAction = self.CreateAction(self, "OnInputActivate")
	self.bindData.inputField.onDeActivateAction = self.CreateAction(self, "OnInputDeactivate")

	if self.bindData.ctrlReviewBtn then
		self.bindData.ctrlReviewBtn.luaClick = self.CreateAction(self, "OnClickReviewBtn")
	end

	local store = self.GetDialogComponentStore(self, self.bindData.dialogTemp)

	if store then
		store.NextButton.luaClick = self.CreateAction(self, "OnClickNextDialogBtn")
	end
end

M.OnClickSendBtn = function(self)
	if self.isShow and self.canSend and not string.is_null_or_empty(self.curInputText) and self.curInputState ~= self.INPUT_STATE.WAIT_PLAYER_INPUT then
		self.curInputState = self.INPUT_STATE.WAIT_AI

		gClientUtils.EnvSdkReviewWords(self.curInputText, function ()
			if self.isShow then
				self:OnClickSendBtnInternal()
			end
		end, function ()
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)

			if self.isShow then
				self.curInputState = self.INPUT_STATE.WAIT_PLAYER_INPUT

				self:RefreshInputState()
			end
		end, "AIDialogBasePanel")
	end
end

M.OnClickReviewBtn = function(self)
	if self.isShow then
		self.bindData.reviewCtrl = 1
		self.openReview = true

		if self.lastReviewCount == #self.historyMessage then
			self.lastReviewCount = #self.historyMessage

			self.bindData.reviewList:SetSimpleList(#self.historyMessage)
		end

		self.bindData.reviewList.normalizedScrollPosition = Vector2.Fetch(0, 0)
	end
end

M.OnClickReviewBackBtn = function(self)
	if self.isShow then
		self.bindData.reviewCtrl = 0
		self.openReview = false
	end
end

M.OnClickNextDialogBtn = function(self)
	if self.isShow then
		self.TriggerNextDialog(self)
	end
end

M.OnRenderHistoryListItem = function(self, btn, index)
	local data = self.historyMessage[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store and data then
		store.text = self.ConcatLeftNameAndMessage(self, data.name, data.message)
	end
end

M.OnDynamicRenderHistoryListItem = function(self, btn, index)
	local data = self.historyMessage[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store and data then
		store.text = self.ConcatLeftNameAndMessage(self, data.name, data.message)
	end
end

M.OnInputFieldInputValueChanged = function(self, text)
	self.curInputText = text

	self.RefreshInputState(self)
end

M.OnInputFieldInputEndEdit = function(self, text, enter)
	self.curInputText = text

	if enter then
		self.OnClickSendBtn(self)
	end
end

M.OnInputActivate = function(self)
	self.inputFieldActive = true
	self.bindData.reviewBtn.interactable = false

	if self.inputActiveCb then
		self.inputActiveCb()
	end
end

M.OnInputDeactivate = function(self)
	self.inputFieldActive = false
	self.bindData.reviewBtn.interactable = true

	if self.inputDeActiveCb then
		self.inputDeActiveCb()
	end
end

M.InitData = function(self, sendPlayerMsgCallback, playerName, autoNextTime, backBtnCallback, inputActiveCb, inputDeActiveCb, characterLimit)
	self.isShow = true
	self.canInput = true
	self.canSend = true
	self.isShowingMsg = false
	self.messageQueue = {}
	self.historyMessage = {}
	self.playerName = playerName

	if autoNextTime and autoNextTime <= 0 then
		self.autoNextTime = autoNextTime
	else
		self.autoNextTime = nil
	end

	self.sendPlayerMsgCallback = sendPlayerMsgCallback
	self.backBtnCallback = backBtnCallback
	self.inputActiveCb = inputActiveCb
	self.inputDeActiveCb = inputDeActiveCb
	self.curInputState = self.INPUT_STATE.WAIT_PLAYER_INPUT
	self.bindData.reviewCtrl = 0
	self.openReview = false
	self.lastReviewCount = nil
	self.curShownMsgData = nil
	self.characterLimit = characterLimit or 500
	self.bindData.inputField.disableReviewWords = true
	self.curNormalType = self.INPUT_FILED_CTRL.normal

	self:SetInputFieldText()
	self:RefreshInputState()
	self:CloseDialogContent()

	self.bindData.inputField.characterLimit = self.characterLimit
	self.bindData.reviewBtn.interactable = true
end

M.ClearData = function(self)
	self.isShow = false
	self.messageQueue = nil
end

M.OnSyncAIMessage = function(self, message, name, waitFunc, canInput, autoActiveInputField)
	self.canSend = false

	local func = function()
		if waitFunc then
			waitFunc()
		end

		self.canSend = true

		self:RefreshInputState()
	end

	self:ShowDialogContent({
		name = name,
		message = message or "",
		waitFunc = func
	})

	self.canInput = canInput
	self.curInputState = self.INPUT_STATE.WAIT_PLAYER_INPUT

	self:RefreshInputState()

	if autoActiveInputField then
		self.bindData.inputField:Focus()

		if gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
			self.bindData.inputField:ActivateInputField()
		end
	end
end

M.OnSyncAIMessageTable = function(self, message, name, waitFunc, canInput, autoActiveInputField)
	if message and #message <= 0 then
		self.canSend = false

		for i = 1, #message do
			local waitFunction = i ~= #message and function ()
				if waitFunc then
					waitFunc()
				end

				self.canSend = true

				self:RefreshInputState()
			end or nil

			self:ShowDialogContent({
				name = name,
				message = message[i] or "",
				waitFunc = waitFunction
			})
		end
	else
		self.canSend = true

		if waitFunc then
			waitFunc()
		end
	end

	self.canInput = canInput
	self.curInputState = self.INPUT_STATE.WAIT_PLAYER_INPUT

	self.RefreshInputState(self)

	if autoActiveInputField then
		self.bindData.inputField:Focus()

		if gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
			self.bindData.inputField:ActivateInputField()
		end
	end
end

M.ActivateInputField = function(self)
	self.bindData.inputField:Focus()

	if gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		self.bindData.inputField:ActivateInputField()
	end
end

M.ResetInputState = function(self)
	self.curInputState = self.INPUT_STATE.WAIT_PLAYER_INPUT

	self.RefreshInputState(self)
end

M.SetCanInput = function(self, canInput)
	self.canInput = canInput

	self.RefreshInputState(self)
end

M.RefreshInputState = function(self)
	local curLen = self.bindData.inputField.textLength

	if self.INPUT_STATE.WAIT_PLAYER_INPUT ~= self.curInputState and self.canSend then
		self.curNormalType = curLen <= 0 and self.INPUT_FILED_CTRL.normal or self.INPUT_FILED_CTRL.empty
	else
		self.curNormalType = self.INPUT_FILED_CTRL.thinking
	end

	self.bindData.inputField.interactable = self.canInput
	self.bindData.sendBtn.interactable = self.canInput and self.canSend
	local curLimit = self.characterLimit

	if curLimit < curLen then
		self.bindData.sendTypeCtrl = self.INPUT_FILED_CTRL.overcount
	else
		self.bindData.sendTypeCtrl = self.curNormalType
	end

	self.bindData.curLimitNum = curLen
	self.bindData.maxLimitNum = curLimit
end

M.SetInputFieldText = function(self, text)
	self.curInputText = text
	self.bindData.inputField.text = self.curInputText
end

M.OnClickSendBtnInternal = function(self)
	if self.sendPlayerMsgCallback then
		local success = self.sendPlayerMsgCallback(self.curInputText)

		if success then
			self.curInputState = self.INPUT_STATE.WAIT_AI

			self:ShowDialogContent({
				name = self.playerName,
				message = self.curInputText
			})
			FrameTimer.New(function ()
				if self.isShow then
					self:SetInputFieldText()
				end
			end, 1):Start()
		else
			self.curInputState = self.INPUT_STATE.WAIT_PLAYER_INPUT
		end
	else
		self.curInputState = self.INPUT_STATE.WAIT_PLAYER_INPUT
	end

	self.RefreshInputState(self)
end

M.OnUpdate = function(self)
	if self.isShowingMsg and self.autoNextTime and self.autoNextTime <= 0 and self.autoNextTime >= gLogicTime.time - self.curShownTime then
		self.TriggerNextDialog(self)
	end
end

M.ShowDialogContent = function(self, messageData)
	if self.isShowingMsg then
		table.insert(self.messageQueue, messageData)
	else
		self.ShowDialogContentInternal(self, messageData)
	end

	table.insert(self.historyMessage, messageData)

	if self.openReview then
		self.lastReviewCount = #self.historyMessage

		self.bindData.reviewList:SetSimpleList(#self.historyMessage)
	end
end

M.TriggerNextDialog = function(self)
	local nextMsg = nil

	if #self.messageQueue <= 0 then
		nextMsg = self.messageQueue[1]

		table.remove(self.messageQueue, 1)
	end

	self.ShowDialogContentInternal(self, nextMsg)
end

M.ShowDialogContentInternal = function(self, messageData)
	if messageData then
		if not self.isShowingMsg then
			self.bindData.dialogTemp.gameObject:SetActive(true)
		end

		self.isShowingMsg = true
		self.curShownTime = gLogicTime.time
		local store = self.GetDialogComponentStore(self, self.bindData.dialogTemp)

		if store then
			store.message = messageData.message

			if messageData.name then
				store.showJob = 1
				store.job = messageData.name
			else
				store.showJob = 0
			end
		end

		if self.curShownMsgData and self.curShownMsgData.waitFunc then
			local func = self.curShownMsgData.waitFunc
			self.curShownMsgData = nil

			func()
		end

		self.curShownMsgData = messageData
	else
		self.CloseDialogContent(self)
	end
end

M.CloseDialogContent = function(self)
	if self.curShownMsgData and self.curShownMsgData.waitFunc then
		local func = self.curShownMsgData.waitFunc
		self.curShownMsgData = nil

		func()
	end

	self.isShowingMsg = false

	self.bindData.dialogTemp.gameObject:SetActive(false)
end

M.GetDialogComponentStore = function(self, widget)
	if widget then
		return gStoreManager:GetStoreGroup("S_DialogComponentStore"):GetStoreByWidget(widget)
	end
end

M.ConcatLeftNameAndMessage = function(self, Content_LeftName, Content_Message)
	local message = nil

	if string.is_null_or_empty(Content_LeftName) then
		message = Content_Message
	else
		message = "#IDD" .. Content_LeftName .. ": #Z" .. Content_Message
	end

	return message
end
