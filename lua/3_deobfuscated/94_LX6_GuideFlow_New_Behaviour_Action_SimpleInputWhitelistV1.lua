C_GuideBT_SimpleInputWhitelistV1 = DefClass("C_GuideBT_SimpleInputWhitelistV1", C_GuideBT_SimpleInputWhitelistV1, C_GuideBT_ActionBase)
local M = C_GuideBT_SimpleInputWhitelistV1

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	SGUI.GuideMgr.SimpleSetWhitelistV1(self.guid, self.pckeyId, self.controllerId)
end

function M:OnExitRunning()
	SGUI.GuideMgr.RemoveWhitelistV1(self.guid)
end
