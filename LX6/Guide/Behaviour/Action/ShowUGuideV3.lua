-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ShowUGuideV3.lua
-- Decompiled from: 00437_ShowUGuideV3.lua_5b93512314a6.luajit

C_GuideBT_ShowUGuideV3 = DefClass("C_GuideBT_ShowUGuideV3", C_GuideBT_ShowUGuideV3, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowUGuideV3
local ShowUGuideCommon = require("LX6/Guide/Behaviour/Action/ShowUGuideCommon")
local GuideParamsCommon = require("LX6/Guide/Behaviour/Action/GuideParamsCommon")

M.OnCreate = function(self)
	ShowUGuideCommon.OnCreate(self, "ShowUGuideV3", false)
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
	return ShowUGuideCommon.GetGuideText(self, "#NoCreateIssue ShowUGuideV3启用了弹窗功能但是没有配置文本数据，guideKey=", self.GetRealGuideKey(self))
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

M.GetRealGuideKey = function(self)
	if self.guideId then
		return self.guideId:Eval()
	elseif self.guideKey then
		return self.guideKey:Eval()
	end
end

M.OnEnterRunning = function(self)
	M.base.OnEnterRunning(self)

	self.realGuideKey = self.GetRealGuideKey(self)

	if self.uGuideParam and self.realGuideKey then
		GuideParamsCommon.ApplyToGuideMgr(self.realGuideKey, self.uGuideParam:Eval())
	end

	ShowUGuideCommon.OnEnterRunning(self, self.realGuideKey, "#NoCreateIssue ShowUGuideV3没有配置guideKey")
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)
	ShowUGuideCommon.OnExitRunning(self)
end
