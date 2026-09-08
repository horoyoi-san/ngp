-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoMinorAtmosphereGameplayData.lua
-- Decompiled from: 00105_PlayerInfoMinorAtmosphereGameplayData.lua_5777f25b8d20.luajit

C_PlayerInfoMinorAtmosphereGameplayData = DefClass("C_PlayerInfoMinorAtmosphereGameplayData", C_PlayerInfoMinorAtmosphereGameplayData, C_PlayerDataBase)
local M = C_PlayerInfoMinorAtmosphereGameplayData

M.InitPlayerInfo = function(self, info)
	local t = self.DataSet_Template
	t.animalInfos = {}

	self.bindData:RefreshData(t)
end

M.OnLogOut = function(self)
	self.bindData:Clear()
end
