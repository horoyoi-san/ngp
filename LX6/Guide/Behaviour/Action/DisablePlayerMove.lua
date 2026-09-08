-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\DisablePlayerMove.lua
-- Decompiled from: 00406_DisablePlayerMove.lua_ba3165c7f469.luajit

C_GuideBT_DisablePlayerMove = DefClass("C_GuideBT_DisablePlayerMove", C_GuideBT_DisablePlayerMove, C_GuideBT_ActionBase)
local M = C_GuideBT_DisablePlayerMove

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	gLuaDataManager.guiMgr.sguiJoystick.Visible = false

	LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gBanId.GUIDE)
end

M.OnExitRunning = function(self)
	gLuaDataManager.guiMgr.sguiJoystick.Visible = true

	LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gBanId.GUIDE)
end
