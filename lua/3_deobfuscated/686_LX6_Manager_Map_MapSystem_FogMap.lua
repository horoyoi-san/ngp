gMapSystem_FogMap = gMapSystem_FogMap or {}
local M = gMapSystem_FogMap

function M:Init()
	return
end

function M:OnLogin()
	return
end

function M:OnLogout()
	return
end

function M:IsUnlocked(sceneId, x, z)
	return not LX6.Gps.MapFogDataMgr.IsInFog(sceneId, x, z)
end

return M
