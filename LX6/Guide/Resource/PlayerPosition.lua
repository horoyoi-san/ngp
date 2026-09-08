-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\PlayerPosition.lua
-- Decompiled from: 00497_PlayerPosition.lua_895510f45044.luajit

C_GuideBT_PlayerPosition = DefClass("C_GuideBT_PlayerPosition", C_GuideBT_PlayerPosition, C_GuideBT_ResourceBase)
local M = C_GuideBT_PlayerPosition

M.Eval = function(self)
	local vec3 = nil
	local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

	if myPlayerCSUnit then
		vec3 = myPlayerCSUnit.LocalPosition
	else
		vec3 = Vector3.zero
	end

	self.pos.val = vec3
	self.x.val = vec3.x
	self.y.val = vec3.y
	self.z.val = vec3.z
end
