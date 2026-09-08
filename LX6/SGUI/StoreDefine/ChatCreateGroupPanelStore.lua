-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChatCreateGroupPanelStore.lua
-- Decompiled from: 02026_ChatCreateGroupPanelStore.lua_d20ba91fdd30.luajit

local TextConfig = LTConfig.TextConfig
C_ChatCreateGroupPanelStore = DefClass("C_ChatCreateGroupPanelStore", C_ChatCreateGroupPanelStore, C_AppFragmentStore)
GroupName2Class.ChatCreateGroupPanelStore = C_ChatCreateGroupPanelStore
local M = C_ChatCreateGroupPanelStore

M.OnAwake = function(self)
	self.bindData.input.characterLimit = 0
	self.bindData.input.maxLength = LTConfig.GameConfig.PlayerNameMaxLength
	self.bindData.input.luaValueChanged = self.CreateAction(self, "OnInputFieldChange")
	self.bindData.input.luaExceedLength = self.CreateAction(self, "OnExceedLength")
	self.bindData.comfirmBtn.luaClick = self.CreateAction(self, "OnComfirmBtnClick")
	self.bindData.emptyBtn.luaClick = self.CreateAction(self, "OnEmptyBtnClick")
end

M.OnInputFieldChange = function(self)
	if self.ContentIsEmpty(self, self.bindData.input.text) then
		self.bindData.comfirmBtn:SetActive(false)
		self.bindData.emptyBtn:SetActive(false)

		return
	end

	self.bindData.comfirmBtn:SetActive(true)
	self.bindData.emptyBtn:SetActive(true)
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

M.OnComfirmBtnClick = function(self)
	if self.ContentIsEmpty(self, self.bindData.input.text) then
		return
	end

	slot1 = gClientToAvatarDelegate

	slot1:AskCreateChatGroup(self.bindData.input.text).Callback = function (errorId, msg)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self:OnCreateChatGroup()
	end
end

M.OnCreateChatGroup = function(self)
	self.activity:CloseCurrentFragment()
	gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.CreateChatGroup).Text)
end

M.OnEmptyBtnClick = function(self)
	self.bindData.input.text = ""
end
