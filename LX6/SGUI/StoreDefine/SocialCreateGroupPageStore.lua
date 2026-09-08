-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialCreateGroupPageStore.lua
-- Decompiled from: 01277_SocialCreateGroupPageStore.lua_3cc95f60a493.luajit

local TextConfig = LTConfig.TextConfig
C_SocialCreateGroupPageStore = DefClass("C_SocialCreateGroupPageStore", C_SocialCreateGroupPageStore, C_StoreGroup)
GroupName2Class.SocialCreateGroupPageStore = C_SocialCreateGroupPageStore
local M = C_SocialCreateGroupPageStore

M.OnAwake = function(self)
	self.bindData.input.characterLimit = 0
	self.bindData.input.luaValueChanged = self.CreateAction(self, "OnInputFieldChange")
	self.bindData.createBtn.luaClick = self.CreateAction(self, "OnCreateBtnClick")
	self.bindData.deleteBtn.luaClick = self.CreateAction(self, "OnDeleteBtnClick")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
end

M.OnEnable = function(self)
	self:ResetInput()
	FrameTimer.New(function ()
		self.bindData.input:ActivateInputField()
	end, 5):Start()
end

M.OnShow = function(self, data)
	self.parentNavi = data
	self.bindData.navi.leftNav = self.parentNavi
end

M.ResetInput = function(self)
	self.bindData.input.text = ""

	self.bindData.createBtn:SetActive(false)
	self.bindData.deleteBtn:SetActive(false)
end

M.OnInputFieldChange = function(self)
	local visualLength = LX6.Utils.TextUtils.GetVisualLength(self.bindData.input.text)
	local tooLong = LTConfig.FriendsConfig.GroupNameMaxLength <= visualLength
	local bValid = not self:ContentIsEmpty(self.bindData.input.text) and not tooLong

	if tooLong then
		self.bindData.showNotice = 1
	else
		self.bindData.showNotice = 0
	end

	if not bValid then
		self.bindData.createBtn:SetActive(false)
		self.bindData.deleteBtn:SetActive(false)

		return
	end

	self.bindData.createBtn:SetActive(true)
	self.bindData.deleteBtn:SetActive(true)
end

M.ContentIsEmpty = function(self, str)
	for i = 1, #str do
		if string.sub(str, i, i) == "\n" and string.sub(str, i, i) == " " then
			return false
		end
	end

	return true
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

M.OnCreateBtnClick = function(self)
	if self.ContentIsEmpty(self, self.bindData.input.text) then
		return
	end

	gClientUtils.EnvSdkReviewWords(self.bindData.input.text, function ()
		gClientToAvatarDelegate:AskCreateChatGroup(self.bindData.input.text).Callback = function (errorId, msg)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			self:OnCreateChatGroup(msg)
		end

		self:ResetInput()
	end, function ()
	end, "SocialGroup")
end

M.OnCreateChatGroup = function(self, msg)
	gDisplayMessageMgr:ShowMessageContent(TextConfig.GetConfig(TextConfig.CreateChatGroup).Text)
	gSocialChatManager:JumpToChat(gSocialChatManager.ChatTopChannel.Group, msg.Id)
	gStoreManager:GetStoreGroup("SocialFriendPageStore"):SetBackPage()
end

M.OnDeleteBtnClick = function(self)
	self.bindData.input.text = ""
end

M.OnBackBtnClick = function(self)
	gStoreManager:GetStoreGroup("SocialFriendPageStore"):SetBackPage()
end
