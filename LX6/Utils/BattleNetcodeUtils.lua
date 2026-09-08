-- Original chunk: @Lua\LuaFiles\LX6\Utils\BattleNetcodeUtils.lua
-- Decompiled from: 02184_BattleNetcodeUtils.lua_dfdf31183bc5.luajit

local M = {
	SetUserName = function (self, uid, name, changed)
		local dataSet = gDataSetManager:GetOrCreateUserData(uid)

		if dataSet == nil then
			dataSet.DisplayName = name
		else
			print_error("[SyncScenePlayerName]找不到DataSet: ", ulong.tostring(uid))
		end
	end,
	GetUserName = function (self, uid)
		local dataSet = gDataSetManager:GetOrCreateUserData(uid)

		if dataSet == nil then
			return dataSet.DisplayName
		end

		return ""
	end
}
gBattleNetcodeUtils = M
