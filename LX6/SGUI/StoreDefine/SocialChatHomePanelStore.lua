-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialChatHomePanelStore.lua
-- Decompiled from: 01331_SocialChatHomePanelStore.lua_0ba8b90cb833.luajit

C_SocialChatHomePanelStore = DefClass("C_SocialChatHomePanelStore", C_SocialChatHomePanelStore, C_StoreGroup)
GroupName2Class.SocialChatHomePanelStore = C_SocialChatHomePanelStore
local M = C_SocialChatHomePanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
end

M.OnActiveDeviceChange = function(self)
	self.OnDisableMove(self)
end

M.OnEnable = function(self)
	self.OnDisableMove(self)
end

M.OnDisable = function(self)
	gLuaDataManager.guiMgr.sguiJoystick.Visible = true
end

M.OnShow = function(self, panelId, args)
	self.args = args
	self.panelId = panelId

	self.InitView(self)
end

M.InitView = function(self)
	self.bindData.tabRect.selectedIndex = 0
end

M.OnRenderTab = function(self, _, widget)
	local group = gStoreManager:GetStoreGroup(widget.Store)

	if group then
		if self.args then
			group.SetData(group, self.args)

			self.args = nil

			return
		end

		group.SetData(group)
	end
end

M.OpenSettingPage = function(self)
	self.bindData.tabRect.selectedIndex = 2
end

M.OpenHomePage = function(self)
	self.bindData.tabRect.selectedIndex = 0
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnDisableMove = function(self)
	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		gLuaDataManager.guiMgr.sguiJoystick.Visible = false
	else
		gLuaDataManager.guiMgr.sguiJoystick.Visible = true
	end
end
