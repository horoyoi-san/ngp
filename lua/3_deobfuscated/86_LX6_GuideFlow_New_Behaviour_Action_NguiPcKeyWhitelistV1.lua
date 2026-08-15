C_GuideBT_NguiPcKeyWhitelistV1 = DefClass("C_GuideBT_NguiPcKeyWhitelistV1", C_GuideBT_NguiPcKeyWhitelistV1, C_GuideBT_ActionBase)
local M = C_GuideBT_NguiPcKeyWhitelistV1

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	return
end

function M:OnExitRunning()
	return
end
