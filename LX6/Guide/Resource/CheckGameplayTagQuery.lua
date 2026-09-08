-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckGameplayTagQuery.lua
-- Decompiled from: 00462_CheckGameplayTagQuery.lua_9c00b03e6c58.luajit

C_GuideBT_CheckGameplayTagQuery = DefClass("C_GuideBT_CheckGameplayTagQuery", C_GuideBT_CheckGameplayTagQuery, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckGameplayTagQuery

M.Eval = function(self)
	if not self.queryId or self.queryId ~= 0 then
		print_error("@GuideBT CheckGameplayTagQuery 没有设置 queryId, guideId =", self.tree.guideId)

		self.output.val = false

		return
	end

	self.output.val = gCS.LuaUtils.TagManagerQuery(self.queryId)
end
