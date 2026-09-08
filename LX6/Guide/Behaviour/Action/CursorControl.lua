-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\CursorControl.lua
-- Decompiled from: 00403_CursorControl.lua_ffa2c13c8dd9.luajit

local GameInputManager = LX6.Manager.GameInputManager
C_GuideBT_CursorControl = DefClass("C_GuideBT_CursorControl", C_GuideBT_CursorControl, C_GuideBT_ActionBase)
local M = C_GuideBT_CursorControl

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.Run = function(self)
end

M.OnEnterRunning = function(self)
	local ifShow = self.show

	GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.Guide, ifShow, UnityEngine.CursorLockMode.None)
end

M.OnExitRunning = function(self)
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Guide)
end
