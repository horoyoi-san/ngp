-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AkxFloatWindowPanel.lua
-- Decompiled from: 01947_AkxFloatWindowPanel.lua_d4118df8a47b.luajit

C_AkxFloatWindowPanel = DefClass("C_AkxFloatWindowPanel", C_AkxFloatWindowPanel, C_AkxChattingPageStore)
GroupName2Class.AkxFloatWindowPanel = C_AkxFloatWindowPanel
local M = C_AkxFloatWindowPanel

M.OnShow = function(self, panelId, data)
	if data and data.sessionid then
		self.sessionid = data.sessionid
	end

	M.base.OnShow(self, panelId, data)
	M.base.RefreshPanel(self, data)
end

M.OnAwake = function(self)
	self.bindData.btnClose.luaClick = self.CreateAction(self, self.OnClickClose)
	self.bindData.btnFullScreen.luaClick = self.CreateAction(self, self.OnClickFullScreen)

	M.base.OnAwake(self)
end

M.OnEnable = function(self)
	self.bIsFloatWindow = true

	M.base.OnEnable(self)
end

M.OnDisable = function(self)
	self.sessionid = nil
end

M.OnClose = function(self)
	M.base.OnClose(self)
end

M.OnClickClose = function(self)
	gPanelManager:Close(gPanelId.AKASHA_FLOAT_WINDOW_PANEL)
end

M.OnClickFullScreen = function(self)
	gAkxManager:OpenFullscreenFromWindow(self.sessionid)
	gPanelManager:Close(gPanelId.AKASHA_FLOAT_WINDOW_PANEL)
end
