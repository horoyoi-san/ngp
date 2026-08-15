C_GuideBT_DisablePlayerCameraRotate = DefClass("C_GuideBT_DisablePlayerCameraRotate", C_GuideBT_DisablePlayerCameraRotate, C_GuideBT_ActionBase)
local M = C_GuideBT_DisablePlayerCameraRotate

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	gClientUtils.SetCameraRotateEnabled(false, LX6.Manager.BanCameraControlSource.GUIDE)
end

function M:OnExitRunning()
	gClientUtils.SetCameraRotateEnabled(true, LX6.Manager.BanCameraControlSource.GUIDE)
end
