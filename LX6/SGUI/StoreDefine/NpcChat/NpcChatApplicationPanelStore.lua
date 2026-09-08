-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatApplicationPanelStore.lua
-- Decompiled from: 02083_NpcChatApplicationPanelStore.lua_63f4de5563ad.luajit

C_NpcChatApplicationPanelStore = DefClass("C_NpcChatApplicationPanelStore", C_NpcChatApplicationPanelStore, C_NpcChatBrowserPanelStore)
GroupName2Class.NpcChatApplicationPanelStore = C_NpcChatApplicationPanelStore
local M = C_NpcChatApplicationPanelStore

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
