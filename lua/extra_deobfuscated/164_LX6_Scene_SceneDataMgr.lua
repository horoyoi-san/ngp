local M = gSceneDataMgr or {}

function M:UpdateRaidData(raidId, instanceId)
	self.CurrentRaidId = raidId
	self.RaidInstanceId = instanceId
end

gSceneDataMgr = M
