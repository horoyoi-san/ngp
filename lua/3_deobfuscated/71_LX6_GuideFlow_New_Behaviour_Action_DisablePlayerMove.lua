C_GuideBT_DisablePlayerMove = DefClass("C_GuideBT_DisablePlayerMove", C_GuideBT_DisablePlayerMove, C_GuideBT_ActionBase)
local M = C_GuideBT_DisablePlayerMove

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	gLuaDataManager.guiMgr.sguiJoystick.Visible = false

	LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gBanId.GUIDE)
end

function M:OnExitRunning()
	gLuaDataManager.guiMgr.sguiJoystick.Visible = true

	LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gBanId.GUIDE)
end
