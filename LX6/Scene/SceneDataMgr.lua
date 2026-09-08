-- Original chunk: @Lua\LuaFiles\LX6\Scene\SceneDataMgr.lua
-- Decompiled from: 00166_SceneDataMgr.lua_564f4d8e33b6.luajit

local M = gSceneDataMgr or {}

M.UpdateRaidData = function(self, raidId, instanceId)
	self.CurrentRaidId = raidId
	self.RaidInstanceId = instanceId
end

gSceneDataMgr = M
