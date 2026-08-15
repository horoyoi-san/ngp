C_GuideBT_CBTEnemyTimeScale = DefClass("C_GuideBT_CBTEnemyTimeScale", C_GuideBT_CBTEnemyTimeScale, C_GuideBT_ActionBase)
local M = C_GuideBT_CBTEnemyTimeScale

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	return
end

function M:OnExitRunning()
	return
end
