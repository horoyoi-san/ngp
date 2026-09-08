-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonInfo\CommonInfoPanelsBaseStore.lua
-- Decompiled from: 01221_CommonInfoPanelsBaseStore.lua_00863ea0f7e0.luajit

C_CommonInfoPanelsBaseStore = DefClass("C_CommonInfoPanelsBaseStore", C_CommonInfoPanelsBaseStore, C_StoreGroup)
local M = C_CommonInfoPanelsBaseStore

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.data = data

	if data.onShowCallback then
		data.onShowCallback()
	end

	self.InitOnShow(self, data, data.panelTypeCfg)
end

M.InitOnShow = function(self, data, panelTypeCfg)
end

M.OnClose = function(self)
	self.ClearOnClose(self)

	if self.data.onCloseCallback then
		self.data.onCloseCallback()
	end
end

M.ClearOnClose = function(self)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.panelId)
end
