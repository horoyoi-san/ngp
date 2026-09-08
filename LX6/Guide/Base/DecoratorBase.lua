-- Original chunk: @Lua\LuaFiles\LX6\Guide\Base\DecoratorBase.lua
-- Decompiled from: 00380_DecoratorBase.lua_a24e5dfe295a.luajit

C_GuideBT_DecoratorBase = DefClass("C_GuideBT_DecoratorBase", C_GuideBT_DecoratorBase, C_GuideBT_CompositeBase)
local M = C_GuideBT_DecoratorBase

M.GetChild = function(self)
	return self.children[1]
end
