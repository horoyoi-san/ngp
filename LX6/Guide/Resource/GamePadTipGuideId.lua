-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\GamePadTipGuideId.lua
-- Decompiled from: 00476_GamePadTipGuideId.lua_84be55fa893f.luajit

C_GuideBT_GamePadTipGuideId = DefClass("C_GuideBT_GamePadTipGuideId", C_GuideBT_GamePadTipGuideId, C_GuideBT_ResourceBase)
local M = C_GuideBT_GamePadTipGuideId

M.Eval = function(self)
	local val = SGUI.GuideMgr.ConcatGamePadTipGuideId(self.guideId:Eval() or nil, self.tipGuideId:Eval() or nil)

	self.output:SetImmutable(val)
end
