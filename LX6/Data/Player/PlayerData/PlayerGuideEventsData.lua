-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerGuideEventsData.lua
-- Decompiled from: 00092_PlayerGuideEventsData.lua_35e67bb0ff30.luajit

C_PlayerGuideEventsData = DefClass("C_PlayerGuideEventsData", C_PlayerGuideEventsData, C_PlayerDataBase)
local M = C_PlayerGuideEventsData

M.OnLogOut = function(self)
	self.bindData:Clear()
end
