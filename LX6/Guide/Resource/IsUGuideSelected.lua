-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\IsUGuideSelected.lua
-- Decompiled from: 00485_IsUGuideSelected.lua_b78946400a48.luajit

C_GuideBT_IsUGuideSelected = DefClass("C_GuideBT_IsUGuideSelected", C_GuideBT_IsUGuideSelected, C_GuideBT_ResourceBase)
local M = C_GuideBT_IsUGuideSelected

M.Eval = function(self)
	local id = self.guideId:Eval()

	if string.is_null_or_empty(id) then
		self.output.val = false
	end

	self.output.val = SGUI.GuideMgr.IsUGuideSelected(id)
end

M.GetDebugLabel = function(self)
	return self.output.val
end
