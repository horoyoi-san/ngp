-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCDialogTestStore.lua
-- Decompiled from: 00944_OCDialogTestStore.lua_d487d73e5a39.luajit

local Consts = gClientConst
local UNavigationMgr = SGUI.UNavigationMgr
local OCConfig = LTConfig.OriginalCharacterConfig
C_OCDialogTestStore = DefClass("C_OCDialogTestStore", C_OCDialogTestStore, C_StoreGroup)
GroupName2Class.OCDialogTestStore = C_OCDialogTestStore
local M = C_OCDialogTestStore

M.ctor = function(self)
	self.mgr = gOCMgr
	self.parentStore = nil
end

M.DefineAllVariables = function(self)
	self.allDialogItems = {}
	self.promptOptions = {}
	self.isWaitingResponse = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.statusCtrlEnum = {
		["K\\xa7\\xb0\\xbc\\xa2"] = 0,
		["H\\xa3\\xad\\xa5\\xbf"] = 2,
		["[\\xa1\\xab\\xac\\xb3"] = 3,
		["w#tU"] = 1
	}
	self.showPromptCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.stageCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["\\xaf\\xb4\\xaa2\\xeaa"] = 2,
		["\\xaf\\xb4\\xaa2\\xeag"] = 4,
		["\\xaf\\xb4\\xaa2\\xea`"] = 3,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.generateCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.statusCtrlEnum = nil
	self.showPromptCtrlEnum = nil
	self.stageCtrlEnum = nil
	self.generateCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnStart = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.stageCtrl = 4

	if self.parentStore.isFirst then
		self.parentStore.isFirst = false

		self:ClearWaitingResponse()

		self.allDialogItems = {}

		self.bindData.dialogList:SetSimpleList(#self.allDialogItems)
		self.mgr:FirstChat(self.recvCB)

		self.bindData.statusCtrl = self.statusCtrlEnum.first
		self.bindData.showPromptCtrl = self.showPromptCtrlEnum._true
	end

	if self.mgr.isMeikaGrandpa then
		self.bindData.stageCtrl = self.mgr:GetCurrentStage()
		self.bindData.showPromptCtrl = self.showPromptCtrlEnum._true
		self.bindData.statusCtrl = self.statusCtrlEnum.main
	end
end

M.OnClose = function(self)
	self.ClearWaitingResponse(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
	self.recvCB = self.CreateAction(self, self.OnRecvRes)
end

M.RegisterWidget = function(self)
	self.bindData.reviewBtn.luaClick = self.CreateAction(self, self.OnClickReviewBtn)
	self.bindData.chatBtn.luaClick = self.CreateAction(self, self.OnClickChatBtn)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.settingBtn.luaClick = self.CreateAction(self, self.OnClickSettingBtn)
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, self.OnClickRefreshBtn)
	self.bindData.emojiBtn.luaClick = self.CreateAction(self, self.OnClickEmojiBtn)
	self.bindData.promptBtn.luaClick = self.CreateAction(self, self.OnClickPromptBtn)

	if self.bindData.memoryBtn then
		self.bindData.memoryBtn.luaClick = self.CreateAction(self, self.OnMemoryBtnClick)
	end

	self.bindData.dialogList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderDialogListItem)
	self.bindData.dialogList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderDialogListItem)
	self.bindData.promptList.luaSimpleClick = self.CreateAction(self, self.OnClickPromptList)
	self.bindData.desInput.luaEndEdit = self.CreateAction(self, self.OnEndEdit)
	self.bindData.desInput.onActivateAction = self.CreateAction(self, self.OnInputFieldActivate)
	self.bindData.desInput.onDeActivateAction = self.CreateAction(self, self.OnInputFieldDeactivate)
	self.bindData.clickProtector.protectionDuration = OCConfig.SendIntervalSec
	self.bindData.desInput.inputEmojiSupport = true
	local emojiSelectStore = self.SubGroup.EmojiSelectStore

	if emojiSelectStore then
		emojiSelectStore.SetParentStore(emojiSelectStore, self)
	end
end

M.OnClickReviewBtn = function(self)
	if self.parentStore then
		self.parentStore:SwitchTab()
	end
end

M.OnClickChatBtn = function(self)
	if self.isWaitingResponse then
		return
	end

	local chatInfo = self.bindData.desInput.text

	if string.is_null_or_empty(chatInfo) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.V4ChatInputEmpty)

		return
	end

	chatInfo = self.bindData.desInput:TransferInputEmojiTextToRichText()

	self:ClearPromptOptions()

	self.bindData.statusCtrl = self.statusCtrlEnum.main
	self.typingDialogItem = nil
	self.bindData.desInput.text = ""

	self:AddDialogItem(self.mgr.currentSessionId, chatInfo, true)
	self:AddTypingDialogItem()

	self.isWaitingResponse = true

	self.mgr:ChatToNpc(chatInfo, self.recvCB)
end

M.OnClickConfirmBtn = function(self)
	self.parentStore:ConfirmCurrent()
end

M.OnClickSettingBtn = function(self)
	self.parentStore:OnSetting()
end

M.RequestSuggestUserInputs = function(self, sessionId)
	self.bindData.generateCtrl = self.generateCtrlEnum._true

	self.mgr:SuggestUserInputs(sessionId, self:CreateAction(self.OnSuggestInputsRes))
end

M.OnClickRefreshBtn = function(self)
	self.RequestSuggestUserInputs(self, nil)
end

M.OnClickEmojiBtn = function(self)
	if self.bindData.statusCtrl ~= self.statusCtrlEnum.emoji then
		self.bindData.statusCtrl = self.statusCtrlEnum.main
	else
		self.bindData.statusCtrl = self.statusCtrlEnum.emoji
		local emojiStore = self.SubGroup.EmojiSelectStore

		if emojiStore and not emojiStore.parentStore then
			emojiStore.SetParentStore(emojiStore, self)
		end

		emojiStore.OnInit(emojiStore)
	end
end

M.InsertEmojiToInput = function(self, emojiId)
	if not string.is_null_or_empty(tostring(emojiId)) then
		self.bindData.desInput:InsertInputEmoji(emojiId)
	end

	self.bindData.statusCtrl = self.statusCtrlEnum.main
end

M.OnRecvRes = function(self, response)
	if not response then
		self.ClearWaitingResponse(self)

		return
	end

	if not self.STATE_EnableOnce then
		self.ClearWaitingResponse(self)

		return
	end

	self.ClearWaitingResponse(self)
	self.AddDialogItem(self, self.mgr.currentSessionId, response.Reply, false, response.ReplyId)
	self.RequestSuggestUserInputs(self, self.mgr.currentSessionId)
end

M.OnRefresh = function(self, originalData, response)
	self.ClearWaitingResponse(self)

	if not response then
		return
	end

	local removeStart = -1

	for i = #self.allDialogItems, 1, -1 do
		local item = self.allDialogItems[i]

		if item ~= originalData then
			removeStart = i

			break
		end
	end

	if removeStart <= 0 then
		for i = #self.allDialogItems, removeStart, -1 do
			table.remove(self.allDialogItems, i)
		end
	end

	if not response.IsFirstChat and originalData and originalData.isSelf then
		self.mgr:_AddDialogItem(self.allDialogItems, self.mgr.currentSessionId, originalData.label, true)
	end

	self.mgr:_AddDialogItem(self.allDialogItems, self.mgr.currentSessionId, response.Reply, false, response.ReplyId)
	self.bindData.dialogList:SetSimpleList(#self.allDialogItems)
end

M.OnSuggestInputsRes = function(self, data)
	if not self.STATE_EnableOnce then
		return
	end

	self.bindData.generateCtrl = self.generateCtrlEnum._false

	if not data or not data.InputCandidates then
		return
	end

	self.promptOptions = data.InputCandidates:ToTable()

	if self.bindData.showPromptCtrl ~= self.showPromptCtrlEnum._true or self.bindData.statusCtrl ~= self.statusCtrlEnum.first then
		self.bindData.promptList:InitSimpleList()

		for i = 1, #self.promptOptions do
			self.bindData.promptList:AddSimpleLabel(0, self.promptOptions[i])
		end

		self.bindData.promptList:RefreshList()
	end
end

M.OnSimpleRenderDialogListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.allDialogItems[index + 1]

	if not data then
		return
	end

	if data.isTyping then
		self.OnRenderTypingDialogListItem(self, store, data)

		return
	end

	self:SetDialogOperateBtnsInteractable(store, true)

	slot5 = self.mgr

	slot5:OnSimpleRenderDialogListItem(store, data, function (response, _)
		self:OnRefresh(data, response)
	end)
end

M.OnClickPromptList = function(self, btn, index)
	local text = self.promptOptions[index + 1]

	if not string.is_null_or_empty(text) then
		self.bindData.desInput.text = text
	end

	self.ClearPromptOptions(self)

	self.bindData.statusCtrl = self.statusCtrlEnum.main
end

M.ClearPromptOptions = function(self)
	self.bindData.showPromptCtrl = self.showPromptCtrlEnum._false
end

M.AddDialogItem = function(self, sessionId, content, isSelf, replyId, isTyping)
	self.mgr:_AddDialogItem(self.allDialogItems, sessionId, content, isSelf, replyId)

	local item = self.allDialogItems[#self.allDialogItems]

	if item then
		item.isTyping = isTyping
	end

	self.bindData.dialogList:SetSimpleList(#self.allDialogItems)
	self.bindData.dialogList:GoToIndex(-1, true)

	return item
end

M.AddTypingDialogItem = function(self)
	self.RemoveTypingDialogItem(self)

	self.typingDialogItem = self.AddDialogItem(self, self.mgr.currentSessionId, OCConfig.InputIngMessage, false, nil, true)
end

M.RemoveTypingDialogItem = function(self)
	local removed = false

	for i = #self.allDialogItems, 1, -1 do
		local item = self.allDialogItems[i]

		if item and (item.isTyping or item ~= self.typingDialogItem) then
			table.remove(self.allDialogItems, i)

			removed = true
		end
	end

	self.typingDialogItem = nil

	if removed then
		self.bindData.dialogList:SetSimpleList(#self.allDialogItems)
	end
end

M.ClearWaitingResponse = function(self)
	self.isWaitingResponse = false

	self.RemoveTypingDialogItem(self)
end

M.OnRenderTypingDialogListItem = function(self, store, data)
	store.titleLabel = self.mgr.baseData.name
	store.isSelf = Consts.BOOL2CTL[false]
	store.isMeika = Consts.BOOL2CTL[self.mgr.isMeikaGrandpa]

	store.Commit(store, "contentLabel", data.label, COMMIT_IMMEDIATELY)
	self.SetDialogOperateBtnsInteractable(self, store, false)
end

M.SetDialogOperateBtnsInteractable = function(self, store, interactable)
	local btns = {
		store.likeBtn,
		store.disLikeBtn,
		store.newBtn,
		store.editBtn,
		store.moreBtn
	}

	for i = 1, #btns do
		local btn = btns[i]

		if btn then
			btn.interactable = interactable

			if not interactable then
				if btn.SetSelected then
					btn.SetSelected(btn, false)
				else
					btn.isSelected = false
				end
			end
		end
	end
end

M.OnClickPromptBtn = function(self)
	self.bindData.showPromptCtrl = self.bindData.showPromptCtrl ~= self.showPromptCtrlEnum._true and self.showPromptCtrlEnum._false or self.showPromptCtrlEnum._true

	if self.bindData.showPromptCtrl ~= self.showPromptCtrlEnum._true then
		self.bindData.promptList:InitSimpleList()

		for i = 1, #self.promptOptions do
			self.bindData.promptList:AddSimpleLabel(0, self.promptOptions[i])
		end

		self.bindData.promptList:RefreshList()
	end
end

M.OnMemoryBtnClick = function(self)
	if self.parentStore.EnterMemory then
		self.parentStore:EnterMemory()
	end
end

M.OnEndEdit = function(self, text, enter)
	if enter then
		self.OnClickChatBtn(self)
	end
end

M.OnInputFieldActivate = function(self)
	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.descNavigationArea
	self.inputFieldActive = true
end

M.OnInputFieldDeactivate = function(self)
	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavigationArea
	self.inputFieldActive = false
end
