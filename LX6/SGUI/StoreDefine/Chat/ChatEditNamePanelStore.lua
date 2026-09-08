-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatEditNamePanelStore.lua
-- Decompiled from: 01939_ChatEditNamePanelStore.lua_f65f53607094.luajit

C_ChatEditNamePanelStore = DefClass("C_ChatEditNamePanelStore", C_ChatEditNamePanelStore, C_AppFragmentStore)
GroupName2Class.ChatEditNamePanelStore = C_ChatEditNamePanelStore
local M = C_ChatEditNamePanelStore

M.OnAwake = function(self)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.OnCancelBtnClick)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnConfirmBtnClick)
	self.bindData.inputField.maxLength = LTConfig.GameConfig.PlayerNameMaxLength
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, self.OnInputFieldValueChanged)
	self.bindData.inputField.luaExceedLength = self.CreateAction(self, self.OnExceedLength)
end

M.OnShow = function(self, _, data)
	self.data = data
	self.targetPid = data.targetPid
	self.origRemarkName = gFriendManager:GetFriendRemarkName(self.targetPid)
	self.bindData.inputField.text = self.origRemarkName

	gChatAvatarUtils:SetChannelAvatar(gChatTopChannel.Friend, data.targetPid, self.bindData.chatHead)
end

M.OnClose = function(self)
	self.data.closeCallback()
end

M.OnCancelBtnClick = function(self)
	self.activity:CloseCurrentFragment()
end

M.OnConfirmBtnClick = function(self)
	slot1 = gFriendManager

	slot1:ChangeFriendRemark(self.targetPid, self.bindData.inputField.text, function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			self.activity:CloseCurrentFragment()
		end
	end)
end

M.OnInputFieldValueChanged = function(self, text)
	self.bindData.inputField.text = gCS.LuaUtils.TruncateString(text, 21)
end

M.OnExceedLength = function(self)
	self.bindData.showNotice = 1

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self.timer = Timer.New(function ()
		if self.bindData.showNotice then
			self.bindData.showNotice = 0
		end

		self.timer = nil
	end, 1):Start()
end
