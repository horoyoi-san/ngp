-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineTVShowMainPanelStore.lua
-- Decompiled from: 01366_TimelineTVShowMainPanelStore.lua_40a3fb7cc882.luajit

C_TimelineTVShowMainPanelStore = DefClass("C_TimelineTVShowMainPanelStore", C_TimelineTVShowMainPanelStore, C_StoreGroup)
GroupName2Class.TimelineTVShowMainPanelStore = C_TimelineTVShowMainPanelStore
local M = C_TimelineTVShowMainPanelStore

M.OnShow = function(self, panelId, type)
	if type ~= "1" then
		self.SetShowType(self, 1)
	elseif type ~= "2" then
		self.SetShowType(self, 2)
	end
end

M.SetShowType = function(self, type)
	self.bindData.showTypeCtrl = type
end
