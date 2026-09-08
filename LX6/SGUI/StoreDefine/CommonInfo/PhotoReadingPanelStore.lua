-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonInfo\PhotoReadingPanelStore.lua
-- Decompiled from: 01980_PhotoReadingPanelStore.lua_ac19dbd0116a.luajit

C_PhotoReadingPanelStore = DefClass("C_PhotoReadingPanelStore", C_PhotoReadingPanelStore, C_CommonInfoPanelsBaseStore)
GroupName2Class.PhotoReadingPanelStore = C_PhotoReadingPanelStore
local M = C_PhotoReadingPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.ClosePanel)
end

M.InitOnShow = function(self, data, panelTypeCfg)
	local cfg = LTConfig.InformationConfig.GetConfig(data[1].id)
	self.bindData.title = cfg.Title
	self.bindData.image = cfg.Image
end
