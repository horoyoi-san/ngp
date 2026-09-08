-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChattingToFriendPanelStore.lua
-- Decompiled from: 02097_ChattingToFriendPanelStore.lua_386b9d12ff83.luajit

C_ChattingToFriendPanelStore = DefClass("C_ChattingToFriendPanelStore", C_ChattingToFriendPanelStore, C_ChatChattingPanelStore)
GroupName2Class.ChattingToFriendPanelStore = C_ChattingToFriendPanelStore
local M = C_ChattingToFriendPanelStore

M.OnAwake = function(self)
	M.base.OnAwake(self)

	self.bindData.sendButton.luaClick = self:CreateAction(self.OnSendButtonClick)
	self.normalBtn = gStoreManager:GetStoreGroup("ChatNormalBtnBarStore")
end

M.InitDataOnAwake = function(self)
	self.lastTimestamp = nil
end

M.InitView = function(self)
	M.base.InitView(self)
	self.SetNormalBtnBar(self)
	self.CheckRedPoint(self)
end

M.CheckRedPoint = function(self)
	if not gChatManager.unReadList then
		return
	end

	for i = #gChatManager.unReadList, 1, -1 do
		if gChatManager.unReadList[i] ~= self.subChannelId then
			table.remove(gChatManager.unReadList, i)
		end
	end

	if #gChatManager.unReadList < 0 then
		SGUI.RedDotMgr.LuaSetRedDot(false, "OnlineChatBtn")
	end
end

M.SetNormalBtnBar = function(self)
	local data = {
		topChannelId = self.topChannelId,
		subChannelId = self.subChannelId
	}

	self.normalBtn:SetData(data)
end

M.BeforeAddMessage = function(self, msg)
	self.TryAddTimestamp(self, msg.timeStamp)
end

M.TryAddTimestamp = function(self, timestamp)
	local lastTimestamp = self.lastTimestamp

	if lastTimestamp ~= nil or timestamp - lastTimestamp <= 300 then
		self.AddCustomViewItem(self, {
			content = gCS.LuaUtils.FormatTimestamp(timestamp)
		}, gChatConst.MessageType.Tips, "Mid")

		self.lastTimestamp = timestamp
	end
end

M.OnSendButtonClick = function(self)
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

M.ScrollToBottom = function(self)
	M.base.ScrollToBottom(self, true)
end
