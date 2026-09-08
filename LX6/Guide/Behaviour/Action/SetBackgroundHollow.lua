-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SetBackgroundHollow.lua
-- Decompiled from: 00425_SetBackgroundHollow.lua_1120c2b5cf71.luajit

C_GuideBT_SetBackgroundHollow = DefClass("C_GuideBT_SetBackgroundHollow", C_GuideBT_SetBackgroundHollow, C_GuideBT_ActionBase)
local M = C_GuideBT_SetBackgroundHollow

M.OnCreate = function(self)
	self._hollowUid = 0
end

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	M.base.OnEnterRunning(self)

	self._hollowUid = SGUI.GuideMgr.CreateHollowMask(self.guideKey:Eval(), self:CreateConfig(self.hollowConfig))
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)

	if self._hollowUid == 0 then
		SGUI.GuideMgr.RemoveHollowMask(self._hollowUid)

		self._hollowUid = 0
	end
end

M.CreateConfig = function(self, config)
	local csConfig = SGUI.GuideMgr.CreateHollowConfig()
	csConfig.maskType = config.maskType
	csConfig.drawCenter = config.drawCenter
	csConfig.scale = config.scale
	csConfig.circleSegments = config.circleSegments

	return csConfig
end
