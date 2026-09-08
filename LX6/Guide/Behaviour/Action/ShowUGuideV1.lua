-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ShowUGuideV1.lua
-- Decompiled from: 00453_ShowUGuideV1.lua_aecd9526f033.luajit

C_GuideBT_ShowUGuideV1 = DefClass("C_GuideBT_ShowUGuideV1", C_GuideBT_ShowUGuideV1, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowUGuideV1
local ShowUGuideCommon = require("LX6/Guide/Behaviour/Action/ShowUGuideCommon")
local GuideParamsCommon = require("LX6/Guide/Behaviour/Action/GuideParamsCommon")

M.OnCreate = function(self)
	ShowUGuideCommon.OnCreate(self, "ShowUGuideV1", function (guideId, component)
		if guideId ~= self.runtimeGuideId then
			self.store = gStoreManager:GetStoreGroup("DefaultUGuideStore"):GetStoreByWidget(component)

			if self.store then
				local guideCfg = LTConfig.GuideGuideTextConfig.GetConfig(self.gudieTextId)
				self.store.guideText = guideCfg and guideCfg.Text or ""

				if self.popVideoId and self.popVideoId == 0 then
					self.store.videoCtrl = 1

					self.store.videoPlayer:Init()
					self.store.videoPlayer:PlayVideo(self.popVideoId, true)
				else
					self.store.videoCtrl = 0
				end
			end
		end
	end)
end

M.RefreshTipText = function(self)
end

M.RefreshSmartLineTipText = function(self)
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
