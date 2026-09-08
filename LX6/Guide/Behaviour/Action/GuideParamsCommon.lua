-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuideParamsCommon.lua
-- Decompiled from: 00398_GuideParamsCommon.lua_b49d5fc587c7.luajit

local M = {
	ApplyToGuideMgr = function (guideId, param)
		if not guideId or guideId ~= "" or not param then
			return
		end

		SGUI.GuideMgr.UpdateGuideOverride(guideId, param.listenFullscreenClick or false, param.listenFullscreenClickDelay or 0)
	end,
	ClearFromGuideMgr = function (guideId)
		if not guideId or guideId ~= "" then
			return
		end

		SGUI.GuideMgr.ClearGuideOverride(guideId)
	end
}

return M
