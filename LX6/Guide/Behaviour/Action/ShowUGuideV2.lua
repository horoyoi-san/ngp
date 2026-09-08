-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ShowUGuideV2.lua
-- Decompiled from: 00454_ShowUGuideV2.lua_39163a539edc.luajit

C_GuideBT_ShowUGuideV2 = DefClass("C_GuideBT_ShowUGuideV2", C_GuideBT_ShowUGuideV2, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowUGuideV2
local ShowUGuideCommon = require("LX6/Guide/Behaviour/Action/ShowUGuideCommon")
local GuideParamsCommon = require("LX6/Guide/Behaviour/Action/GuideParamsCommon")

M.OnCreate = function(self)
	ShowUGuideCommon.OnCreate(self, "ShowUGuideV2", false)
end

M.RefreshTipText = function(self)
	ShowUGuideCommon.RefreshTipText(self, function ()
		return self:GetGuideText()
	end)
end

M.RefreshSmartLineTipText = function(self)
	ShowUGuideCommon.RefreshSmartLineTipText(self, function ()
		return self:GetGuideText()
	end)
end

M.GetGuideText = function(self)
	return ShowUGuideCommon.GetGuideText(self, "#NoCreateIssue ShowUGuideV2启用了弹窗功能但是没有配置文本数据，guideKey=", self.guideId or self.guideKey)
end

M.OnTick = function(self)
	return ShowUGuideCommon.OnTick(self)
end

M.OnActiveDeviceChange = function(self)
	ShowUGuideCommon.OnActiveDeviceChange(self, function ()
		return self:GetGuideText()
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
