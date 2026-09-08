-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChatNormalBtnBarStore.lua
-- Decompiled from: 01480_ChatNormalBtnBarStore.lua_eaf2c28c0638.luajit

C_ChatNormalBtnBarStore = DefClass("C_ChatNormalBtnBarStore", C_ChatNormalBtnBarStore, C_StoreGroup)
GroupName2Class.ChatNormalBtnBarStore = C_ChatNormalBtnBarStore
local M = C_ChatNormalBtnBarStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.sendBtn.luaClick = self:CreateAction("OnSendBtnClick")
	self.bindData.emojiBtn.luaClick = self:CreateAction("OnEmojiBtnClick")
	self.bindData.deleteBtn.luaClick = self:CreateAction("OnDeleteBtnClick")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")

	self.bindData.closeBtn:SetActive(false)

	self.bindData.voiceBtn.luaClick = self:CreateAction("OnVoiceBtnClick")
	self.bindData.emojiList.luaSimpleRenderItem = self:CreateAction("OnRenderEmojiItem")
	self.bindData.cancelBtn.luaClick = self:CreateAction("OnCancelBtnClick")
	self.bindData.recordBtn.luaBeginLongPress = self:CreateAction("OnRecordBtnClickBegin")
	self.bindData.recordBtn.luaEndLongPress = self:CreateAction("OnRecordBtnClickEnd")
	self.bindData.input.onActivateAction = self:CreateAction("OnInputActivate")
	self.bindData.input.onDeActivateAction = self:CreateAction("OnInputDeactivate")
	self.bindData.mouseMoveRespond.luaGamePadInputChanged = self:CreateAction("OnMouseMove")
end

M.OnEnable = function(self)
	self.ActivateInputField(self)
end

M.OnMouseMove = function(self, context)
	if self.bindData.status == 2 then
		return
	end

	local inRect = self.IsScreenPointInRect(self, self.bindData.voiceCanelAreaRect)

	if inRect then
		self.OnCancelBtnClick(self)
	end
end

M.IsScreenPointInRect = function(self, rectTransform)
	return gCS.LuaUtils.RectangleContainsScreenPoint(rectTransform, UnityEngine.Input.mousePosition)
end

M.OnInputActivate = function(self)
	self.inputActive = true
end

M.OnInputDeactivate = function(self)
	self.inputActive = false
end

M.ActivateInputField = function(self)
	self.activeInputFieldCo = coroutine.start(function ()
		coroutine.wait(0.2)
		self.bindData.input:ActivateInputField()
	end)
end

M.SetData = function(self, data)
	if self.bindData.input then
		self.bindData.input.text = ""
	end

	if self.bindData.status then
		self.bindData.status = 0
	end

	self.topChannelId = data.topChannelId
	self.subChannelId = data.subChannelId
end

M.OnEmojiBtnClick = function(self)
	self.bindData.closeBtn:SetActive(true)
	print_debug("zxxx OnEmojiBtnClick")

	self.bindData.status = 3

	self:SetEmojiList()
end

M.OnDeleteBtnClick = function(self)
	if string.is_null_or_empty(self.bindData.input.text) then
		return
	end

	local text = self.DeleteInputText(self)
	self.bindData.input.text = text
end

M.DeleteInputText = function(self)
	local str = self.bindData.input.text
	local length = #str

	if length >= 2 then
		return str
	end

	local secondLast = str.sub(str, length - 1, length - 1)
	local thirdLast = str.sub(str, length - 2, length - 2)

	if thirdLast ~= "#" then
		return str.sub(str, 1, length - 3)
	elseif secondLast ~= "#" then
		return str.sub(str, 1, length - 2)
	else
		return str.sub(str, 1, length - 1)
	end
end

M.OnCloseBtnClick = function(self)
	self.bindData.status = 0

	self.bindData.closeBtn:SetActive(false)
end

M.OnVoiceBtnClick = function(self)
	self.bindData.status = 1
end

M.OnRecordBtnClickBegin = function(self)
	self.isCancel = false
	self.bindData.status = 2
	self.recordTime = 0
	self.recordStartTime = os.clock()
	self.recordTimer = coroutine.start(function ()
		while true do
			coroutine.wait(0.1)

			self.recordTime = os.clock() - self.recordStartTime

			self:UpdateRecordTimeDisplay()
		end
	end)

	gCS.IMManager:StartRecordAudio(self.topChannelId, self.subChannelId, "")
end

M.UpdateRecordTimeDisplay = function(self, reset)
	if reset then
		self.bindData.time = "00.00"
	else
		local minutes = math.floor(self.recordTime / 60)
		local seconds = math.floor(self.recordTime % 60)
		self.bindData.time = string.format("%02d:%02d", minutes, seconds)
	end
end

M.OnRecordBtnClickEnd = function(self)
	if self.isCancel then
		return
	end

	self:StopRecordTimer()
	gCS.IMManager:StopRecordAudio()

	self.bindData.status = 0
end

M.OnCancelBtnClick = function(self)
	self.isCancel = true

	self:StopRecordTimer()
	gCS.IMManager:CancelRecordAudio()

	self.bindData.status = 0
end

M.StopRecordTimer = function(self)
	if self.recordTimer then
		coroutine.stop(self.recordTimer)

		self.recordTimer = nil
	end

	self.recordTime = 0

	self.UpdateRecordTimeDisplay(self, true)
end

M.OnSendBtnClick = function(self)
	local inputValue = self.bindData.input.text

	if not self.inputActive and string.is_null_or_empty(inputValue) then
		self.ActivateInputField(self)

		return
	end

	if string.is_null_or_empty(inputValue) then
		local chatInputEmptyCfg = LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.V4ChatInputEmpty)

		gChatUtils.ShowPhoneAppTip(chatInputEmptyCfg.Content)

		return
	end

	self:ActivateInputField()

	self.bindData.status = 0
	self.bindData.input.text = ""

	gChatManager:TrySendChat(inputValue, self.topChannelId, self.subChannelId)
end

M.SetEmojiList = function(self)
	local emojiList = {}

	for i = 1, #LTConfig.SocialMediaConfig.EmojiList do
		local data = {
			id = LTConfig.SocialMediaConfig.EmojiList[i]
		}

		table.insert(emojiList, data)
	end

	self._emojiListData = emojiList

	self.bindData.emojiList:SetSimpleList(#emojiList)
end

M.OnRenderEmojiItem = function(self, btn, index)
	local data = self._emojiListData[index + 1]
	local store = gStoreManager:GetStoreGroup("ChatEmojiTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.id
	btn.luaClick = self.CreateActionWithArgs(self, "OnEmojiItemBtnClick", index)
end

M.OnEmojiItemBtnClick = function(self, index)
	self.bindData.input.text = self.bindData.input.text .. "#" .. index + 1
end
