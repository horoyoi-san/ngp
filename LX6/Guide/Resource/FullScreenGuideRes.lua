-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\FullScreenGuideRes.lua
-- Decompiled from: 00475_FullScreenGuideRes.lua_ab8ead67e0e7.luajit

C_GuideBT_FullScreenGuideRes = DefClass("C_GuideBT_FullScreenGuideRes", C_GuideBT_FullScreenGuideRes, C_GuideBT_ResourceBase)
local M = C_GuideBT_FullScreenGuideRes

M.Eval = function(self)
	local val = {
		title = self.title,
		textureId = self.textureId,
		videoId = self.videoId,
		textId = self.textId,
		controllerId = self.controllerId,
		mobileId = self.mobileId
	}

	self.output:SetImmutable(val)
end
