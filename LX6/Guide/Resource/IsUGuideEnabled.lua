-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\IsUGuideEnabled.lua
-- Decompiled from: 00484_IsUGuideEnabled.lua_fdab42a2040e.luajit

C_GuideBT_IsUGuideEnabled = DefClass("C_GuideBT_IsUGuideEnabled", C_GuideBT_IsUGuideEnabled, C_GuideBT_ResourceBase)
local M = C_GuideBT_IsUGuideEnabled

M.Eval = function(self)
	local guideKey = self.guideId or self.guideKey
	self.output.val = SGUI.GuideMgr.IsUGuideRegistered(guideKey)
end

M.GetDebugLabel = function(self)
	return self.output.val
end
