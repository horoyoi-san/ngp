C_ChatEditNamePanelStore = DefClass("C_ChatEditNamePanelStore", C_ChatEditNamePanelStore, C_AppFragmentStore)
GroupName2Class.ChatEditNamePanelStore = C_ChatEditNamePanelStore
local M = C_ChatEditNamePanelStore

function M:OnAwake()
	self.bindData.cancelBtn.luaClick = self:CreateAction(self.OnCancelBtnClick)
	self.bindData.confirmBtn.luaClick = self:CreateAction(self.OnConfirmBtnClick)
	self.bindData.inputField.maxLength = LTConfig.GameConfig.PlayerNameMaxLength
	self.bindData.inputField.luaValueChanged = self:CreateAction(self.OnInputFieldValueChanged)
	self.bindData.inputField.luaExceedLength = self:CreateAction(self.OnExceedLength)
end

function M:OnShow(_, data)
	self.data = data
	self.targetPid = data.targetPid
	self.origRemarkName = gFriendManager:GetFriendRemarkName(self.targetPid)
	self.bindData.inputField.text = self.origRemarkName

	gChatAvatarUtils:SetChannelAvatar(gChatTopChannel.Friend, data.targetPid, self.bindData.chatHead)
end

function M:OnClose()
	self.data.closeCallback()
end

function M:OnCancelBtnClick()
	self.activity:CloseCurrentFragment()
end

function M:OnConfirmBtnClick()
	gFriendManager:ChangeFriendRemark(self.targetPid, self.bindData.inputField.text, function (err)
		if err == LTConfig.MessageConfig.Ok then
			self.activity:CloseCurrentFragment()
		end
	end)
end

function M:OnInputFieldValueChanged(text)
	self.bindData.inputField.text = gCS.LuaUtils.TruncateString(text, 21)
end

function M:OnExceedLength()
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
