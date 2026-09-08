-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComputerDeleteToolTips.lua
-- Decompiled from: 01547_ComputerDeleteToolTips.lua_df6dbbd19b1b.luajit

C_ComputerDeleteToolTips = DefClass("C_ComputerDeleteToolTips", C_ComputerDeleteToolTips, C_StoreGroup)
GroupName2Class.ComputerDeleteToolTips = C_ComputerDeleteToolTips
local M = C_ComputerDeleteToolTips

M.OnAwake = function(self)
	self.bindData.button.luaClick = self.CreateAction(self, "OnDeleteClick")
end

M.OnDeleteClick = function(self)
	if self.onDeleteCallback then
		self.onDeleteCallback()
	end
end

M.OnDestroy = function(self)
	self.onDeleteCallback = nil
end
