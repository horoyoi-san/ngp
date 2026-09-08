-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Decorator\Repeat.lua
-- Decompiled from: 00393_Repeat.lua_feb6019c273d.luajit

C_GuideBT_Repeat = DefClass("C_GuideBT_Repeat", C_GuideBT_Repeat, C_GuideBT_DecoratorBase)
local M = C_GuideBT_Repeat

M.OnTick = function(self)
	if self.GetChild(self) then
		self:GetChild():DoTick()
	end

	return gGuideNodeState.Running
end
