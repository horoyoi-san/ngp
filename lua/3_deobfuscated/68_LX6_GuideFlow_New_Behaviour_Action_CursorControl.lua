local GameInputManager = LX6.Manager.GameInputManager
C_GuideBT_CursorControl = DefClass("C_GuideBT_CursorControl", C_GuideBT_CursorControl, C_GuideBT_ActionBase)
local M = C_GuideBT_CursorControl

function M:OnTick()
	return gGuideNodeState.Running
end

function M:Run()
	return
end

function M:OnEnterRunning()
	local ifShow = self.show

	GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.Guide, ifShow, UnityEngine.CursorLockMode.None)
end

function M:OnExitRunning()
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Guide)
end
