-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ShowGuideLink.lua
-- Decompiled from: 00433_ShowGuideLink.lua_9994d10625ec.luajit

C_GuideBT_ShowGuideLink = DefClass("C_GuideBT_ShowGuideLink", C_GuideBT_ShowGuideLink, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowGuideLink
local GuideLinkCommon = require("LX6/Guide/Behaviour/Action/GuideLinkCommon")

M.OnCreate = function(self)
	self._linkUid = 0
end

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	M.base.OnEnterRunning(self)

	self._linkUid = GuideLinkCommon.Create(self.guideKey1, self.guideKey2, self.linePrefabPath, self.endpoint1, self.endpoint2, self.turningOuterAngle)
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)

	if self._linkUid == 0 then
		GuideLinkCommon.Remove(self._linkUid)

		self._linkUid = 0
	end
end
