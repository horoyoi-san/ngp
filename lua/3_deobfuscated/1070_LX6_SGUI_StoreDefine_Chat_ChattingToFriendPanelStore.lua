C_ChattingToFriendPanelStore = DefClass("C_ChattingToFriendPanelStore", C_ChattingToFriendPanelStore, C_ChatChattingPanelStore)
GroupName2Class.ChattingToFriendPanelStore = C_ChattingToFriendPanelStore
local M = C_ChattingToFriendPanelStore

function M:OnAwake()
	M.base.OnAwake(self)

	self.bindData.sendButton.luaClick = self:CreateAction(self.OnSendButtonClick)
	self.normalBtn = gStoreManager:GetStoreGroup("ChatNormalBtnBarStore")
end

function M:InitDataOnAwake()
	self.lastTimestamp = nil
end

function M:InitView()
	M.base.InitView(self)
	self:SetNormalBtnBar()
	self:CheckRedPoint()
end

function M:CheckRedPoint()
	if not gChatManager.unReadList then
		return
	end

	for i = #gChatManager.unReadList, 1, -1 do
		if gChatManager.unReadList[i] == self.subChannelId then
			table.remove(gChatManager.unReadList, i)
		end
	end

	if #gChatManager.unReadList <= 0 then
		SGUI.RedDotMgr.LuaSetRedDot(false, "OnlineChatBtn")
	end
end

function M:SetNormalBtnBar()
	local data = {
		topChannelId = self.topChannelId,
		subChannelId = self.subChannelId
	}

	self.normalBtn:SetData(data)
end

function M:BeforeAddMessage(msg)
	self:TryAddTimestamp(msg.timeStamp)
end

function M:TryAddTimestamp(timestamp)
	local lastTimestamp = self.lastTimestamp

	if lastTimestamp == nil or timestamp - lastTimestamp > 300 then
		self:AddCustomViewItem({
			content = gCS.LuaUtils.FormatTimestamp(timestamp)
		}, gChatConst.MessageType.Tips, "Mid")

		self.lastTimestamp = timestamp
	end
end

function M:OnSendButtonClick()
	if self.bindData.sendingMessage then
		return
	end

	local inputValue = self.bindData.inputField.text

	if string.is_null_or_empty(inputValue) then
		local chatInputEmptyCfg = LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.V4ChatInputEmpty)

		gChatUtils.ShowPhoneAppTip(chatInputEmptyCfg.Content)

		return
	end

	self.bindData.sendingMessage = true

	gChatManager:TrySendChat(inputValue, self.topChannelId, self.subChannelId)
end

function M:ScrollToBottom()
	M.base.ScrollToBottom(self, true)
end
