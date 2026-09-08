-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\GuideText.lua
-- Decompiled from: 00481_GuideText.lua_b8d5d7246e6f.luajit

C_GuideBT_GuideText = DefClass("C_GuideBT_GuideText", C_GuideBT_GuideText, C_GuideBT_ResourceBase)
local M = C_GuideBT_GuideText

M.Eval = function(self)
	local val = {
		text = self.text,
		textId = self.textId,
		controllerId = self.controllerId,
		mobileId = self.mobileId,
		dualSenseId = self.dualSenseId
	}

	self.output:SetImmutable(val)
end
