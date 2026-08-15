C_ChatNormalBtnBarStore = DefClass("C_ChatNormalBtnBarStore", C_ChatNormalBtnBarStore, C_StoreGroup)
GroupName2Class.ChatNormalBtnBarStore = C_ChatNormalBtnBarStore
local M = C_ChatNormalBtnBarStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.sendBtn.luaClick = self:CreateAction("OnSendBtnClick")
	self.bindData.emojiBtn.luaClick = self:CreateAction("OnEmojiBtnClick")
	self.bindData.deleteBtn.luaClick = self:CreateAction("OnDeleteBtnClick")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")

	self.bindData.closeBtn:SetActive(false)

	self.bindData.voiceBtn.luaClick = self:CreateAction("OnVoiceBtnClick")
	self.bindData.emojiList.luaRenderItem = self:CreateAction("OnRenderEmojiItem")
	self.bindData.cancelBtn.luaClick = self:CreateAction("OnCancelBtnClick")
	self.bindData.recordBtn.luaBeginLongPress = self:CreateAction("OnRecordBtnClickBegin")
	self.bindData.recordBtn.luaEndLongPress = self:CreateAction("OnRecordBtnClickEnd")
	self.bindData.input.onActivateAction = self:CreateAction("OnInputActivate")
	self.bindData.input.onDeActivateAction = self:CreateAction("OnInputDeactivate")
	self.bindData.mouseMoveRespond.luaGamePadInputChanged = self:CreateAction("OnMouseMove")
end

function M:OnEnable()
	self:ActivateInputField()
end

function M:OnMouseMove(context)
	if self.bindData.status ~= 2 then
		return
	end

	local inRect = self:IsScreenPointInRect(self.bindData.voiceCanelAreaRect)

	if inRect then
		self:OnCancelBtnClick()
	end
end

function M:IsScreenPointInRect(rectTransform)
	return gCS.LuaUtils.RectangleContainsScreenPoint(rectTransform, UnityEngine.Input.mousePosition)
end

function M:OnInputActivate()
	self.inputActive = true
end

function M:OnInputDeactivate()
	self.inputActive = false
end

function M:ActivateInputField()
	self.activeInputFieldCo = coroutine.start(function ()
		coroutine.wait(0.2)
		self.bindData.input:ActivateInputField()
	end)
end

function M:SetData(data)
	if self.bindData.input then
		self.bindData.input.text = ""
	end

	if self.bindData.status then
		self.bindData.status = 0
	end

	self.topChannelId = data.topChannelId
	self.subChannelId = data.subChannelId
end

function M:OnEmojiBtnClick()
	self.bindData.closeBtn:SetActive(true)
	print_debug("zxxx OnEmojiBtnClick")

	self.bindData.status = 3

	self:SetEmojiList()
end

function M:OnDeleteBtnClick()
	if string.is_null_or_empty(self.bindData.input.text) then
		return
	end

	local text = self:DeleteInputText()
	self.bindData.input.text = text
end

function M:DeleteInputText()
	local str = self.bindData.input.text
	local length = #str

	if length < 2 then
		return str
	end

	local secondLast = str:sub(length - 1, length - 1)
	local thirdLast = str:sub(length - 2, length - 2)

	if thirdLast == "#" then
		return str:sub(1, length - 3)
	elseif secondLast == "#" then
		return str:sub(1, length - 2)
	else
		return str:sub(1, length - 1)
	end
end

function M:OnCloseBtnClick()
	self.bindData.status = 0

	self.bindData.closeBtn:SetActive(false)
end

function M:OnVoiceBtnClick()
	self.bindData.status = 1
end

function M:OnRecordBtnClickBegin()
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

function M:UpdateRecordTimeDisplay(reset)
	if reset then
		self.bindData.time = "00.00"
	else
		local minutes = math.floor(self.recordTime / 60)
		local seconds = math.floor(self.recordTime % 60)
		self.bindData.time = string.format("%02d:%02d", minutes, seconds)
	end
end

function M:OnRecordBtnClickEnd()
	if self.isCancel then
		return
	end

	self:StopRecordTimer()
	gCS.IMManager:StopRecordAudio()

	self.bindData.status = 0
end

function M:OnCancelBtnClick()
	self.isCancel = true

	self:StopRecordTimer()
	gCS.IMManager:CancelRecordAudio()

	self.bindData.status = 0
end

function M:StopRecordTimer()
	if self.recordTimer then
		coroutine.stop(self.recordTimer)

		self.recordTimer = nil
	end

	self.recordTime = 0

	self:UpdateRecordTimeDisplay(true)
end

function M:OnSendBtnClick()
	local inputValue = self.bindData.input.text

	if not self.inputActive and string.is_null_or_empty(inputValue) then
		self:ActivateInputField()

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

function M:SetEmojiList()
	local emojiList = {}

	for i = 1, #LTConfig.SocialMediaConfig.EmojiList do
		local data = {
			id = LTConfig.SocialMediaConfig.EmojiList[i]
		}

		table.insert(emojiList, data)
	end

	self.bindData.emojiList:SetList(emojiList)
end

function M:OnRenderEmojiItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("ChatEmojiTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.id
	btn.luaClick = self:CreateActionWithArgs("OnEmojiItemBtnClick", index)
end

function M:OnEmojiItemBtnClick(index)
	self.bindData.input.text = self.bindData.input.text .. "#" .. index + 1
end
