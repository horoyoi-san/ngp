-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_Region.lua
-- Decompiled from: 02299_MapSystem_Region.lua_2aa7faa56c15.luajit

gMapSystem_Region = gMapSystem_Region or {}
local M = gMapSystem_Region

M.Init = function(self)
end

M.IsCountryUnlocked = function(self, countryId)
	local cfg = LTConfig.CollectionCountryConfig.GetConfig(countryId)

	if not cfg then
		return false
	end

	if cfg.SystemUnlockId == 0 and not gSystemUnlockMgr:IsUnlock(cfg.SystemUnlockId) then
		return false
	else
		return true
	end
end

return M
