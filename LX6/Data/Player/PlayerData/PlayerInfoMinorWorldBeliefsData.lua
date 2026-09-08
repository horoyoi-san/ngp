-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoMinorWorldBeliefsData.lua
-- Decompiled from: 00104_PlayerInfoMinorWorldBeliefsData.lua_af9d9b76abab.luajit

C_PlayerInfoMinorWorldBeliefsData = DefClass("C_PlayerInfoMinorWorldBeliefsData", C_PlayerInfoMinorWorldBeliefsData, C_PlayerDataBase)
local M = C_PlayerInfoMinorWorldBeliefsData

M.InitPlayerInfo = function(self, info)
	local t = self.DataSet_Template

	self.bindData:RefreshData(t)
end

M.OnLogOut = function(self)
	self.bindData:Clear()
end
