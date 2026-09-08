-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_FogMap.lua
-- Decompiled from: 02295_MapSystem_FogMap.lua_44849cca4c0e.luajit

gMapSystem_FogMap = gMapSystem_FogMap or {}
local M = gMapSystem_FogMap

M.Init = function(self)
end

M.OnLogin = function(self)
end

M.OnLogout = function(self)
end

M.IsUnlocked = function(self, sceneId, x, z)
	return not LX6.Gps.MapFogDataMgr.IsInFog(sceneId, x, z)
end

return M
