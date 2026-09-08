-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\DisablePlayerCameraRotate.lua
-- Decompiled from: 00405_DisablePlayerCameraRotate.lua_ee7fcde99d23.luajit

C_GuideBT_DisablePlayerCameraRotate = DefClass("C_GuideBT_DisablePlayerCameraRotate", C_GuideBT_DisablePlayerCameraRotate, C_GuideBT_ActionBase)
local M = C_GuideBT_DisablePlayerCameraRotate

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	gClientUtils.SetCameraRotateEnabled(false, LX6.Manager.BanCameraControlSource.GUIDE)
end

M.OnExitRunning = function(self)
	gClientUtils.SetCameraRotateEnabled(true, LX6.Manager.BanCameraControlSource.GUIDE)
end
