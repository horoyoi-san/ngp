-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoMinorSpiritStandingDrawingData.lua
-- Decompiled from: 00103_PlayerInfoMinorSpiritStandingDrawingData.lua_0748527ead97.luajit

C_PlayerInfoMinorSpiritStandingDrawingData = DefClass("C_PlayerInfoMinorSpiritStandingDrawingData", C_PlayerInfoMinorSpiritStandingDrawingData, C_PlayerDataBase)
local M = C_PlayerInfoMinorSpiritStandingDrawingData

M.InitPlayerInfo = function(self, info)
end

M.OnLogOut = function(self)
	self.bindData:Clear()
end
