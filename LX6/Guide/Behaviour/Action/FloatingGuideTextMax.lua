-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\FloatingGuideTextMax.lua
-- Decompiled from: 00408_FloatingGuideTextMax.lua_fe8364125667.luajit

C_GuideBT_FloatingGuideTextMax = DefClass("C_GuideBT_FloatingGuideTextMax", C_GuideBT_FloatingGuideTextMax, C_GuideBT_ActionBase)
local M = C_GuideBT_FloatingGuideTextMax

M.OnEnterRunning = function(self)
	SGUI.GuideMgr.ShowFloatingGuideTextMax()
	gStoreManager:GetStoreGroup("FloatingGuideTextStore"):OnShow(nil, {
		guideTextData = self.guideTextData:Eval()
	})
end

M.OnExitRunning = function(self)
	SGUI.GuideMgr.CloseFloatingGuideTextMax()
end

M.OnTick = function(self)
	return gGuideNodeState.Running
end
