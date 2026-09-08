-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatApplicationPanelStore.lua
-- Decompiled from: 02108_ChatApplicationPanelStore.lua_e9e8e797120c.luajit

C_ChatApplicationPanelStore = DefClass("C_ChatApplicationPanelStore", C_ChatApplicationPanelStore, C_ChatBrowserPanelStore)
GroupName2Class.ChatApplicationPanelStore = C_ChatApplicationPanelStore
local M = C_ChatApplicationPanelStore

M.OnAwake = function(self)
	M.base.OnAwake(self)

	self.bindData.showTypeCtrl = 0
	self.bindData.btn.luaClick = self.CreateAction(self, self.OnApplyBtnClick)
end

M.OnShow = function(self, _, data)
	M.base.OnShow(self, _, data)

	if data.chatID ~= self.lastShowChatId then
		self.bindData.showTypeCtrl = self.registered and 2 or 0

		return
	end

	self.registered = false
	self.lastShowChatId = data.chatID
end

M.OnApplyBtnClick = function(self)
	if self.registered then
		return
	end

	self.bindData.showTypeCtrl = 1
	self.registered = true

	gClientToGameSceneDelegate:AskFinishNpcChatRegistration(self.data.chatID)
end

M.OnDestroy = function(self)
	self.lastShowChatId = nil
end
