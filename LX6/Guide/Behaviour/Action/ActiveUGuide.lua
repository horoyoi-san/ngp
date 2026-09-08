-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ActiveUGuide.lua
-- Decompiled from: 00395_ActiveUGuide.lua_dd3e207ba4d2.luajit

C_GuideBT_ActiveUGuide = DefClass("C_GuideBT_ActiveUGuide", C_GuideBT_ActiveUGuide, C_GuideBT_ActionBase)
local M = C_GuideBT_ActiveUGuide
local ShowUGuideCommon = require("LX6/Guide/Behaviour/Action/ShowUGuideCommon")
local GuideParamsCommon = require("LX6/Guide/Behaviour/Action/GuideParamsCommon")

M.OnCreate = function(self)
	ShowUGuideCommon.OnCreate(self, "ActiveUGuide", nil)
end

M.OnTick = function(self)
	return ShowUGuideCommon.OnTick(self)
end

M.OnActiveDeviceChange = function(self)
	ShowUGuideCommon.OnActiveDeviceChange(self, function ()
		return ""
	end)

	if self.uGuideParam and self.realGuideKey then
		GuideParamsCommon.ApplyToGuideMgr(self.realGuideKey, self.uGuideParam:Eval())
	end
end

M.OnEnterRunning = function(self)
	M.base.OnEnterRunning(self)

	self.realGuideKey = self.guideId or self.guideKey

	if self.uGuideParam and self.realGuideKey then
		GuideParamsCommon.ApplyToGuideMgr(self.realGuideKey, self.uGuideParam:Eval())
	end

	ShowUGuideCommon.OnEnterRunning(self, self.realGuideKey)
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)
	ShowUGuideCommon.OnExitRunning(self)
end
