-- Original chunk: @Lua\LuaFiles\LX6\Guide\Base\CompositeBase.lua
-- Decompiled from: 00379_CompositeBase.lua_1f213b7dbc71.luajit

C_GuideBT_CompositeBase = DefClass("C_GuideBT_CompositeBase", C_GuideBT_CompositeBase, C_GuideBT_BehaviourBase)
local M = C_GuideBT_CompositeBase

M.ctor = function(self)
	self.children = {}
	self.childCount = 0
end

M.AddChild = function(self, child)
	self.childCount = self.childCount + 1
	self.children[self.childCount] = child
end

M.CompressChildren = function(self)
	local j = 1

	for i = 1, self.childCount do
		if self.children[i] then
			self.children[j] = self.children[i]
			j = j + 1
		end
	end
end
