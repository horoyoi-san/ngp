-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieMapDetailPagePanel.lua
-- Decompiled from: 02089_YanjieMapDetailPagePanel.lua_9dd051d55a88.luajit

C_YanjieMapDetailPagePanel = DefClass("C_YanjieMapDetailPagePanel", C_YanjieMapDetailPagePanel, C_YanjieNewDetailPagePanel)
GroupName2Class.YanjieMapDetailPagePanel = C_YanjieMapDetailPagePanel
local M = C_YanjieMapDetailPagePanel

M.OnShow = function(self, _, args)
	M.base.ShowPanel(self, args)
end

M.OnExecuteExitAction = function(self)
	gPanelManager:Close(self.m_Id)
end
