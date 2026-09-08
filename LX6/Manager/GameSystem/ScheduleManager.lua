-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\ScheduleManager.lua
-- Decompiled from: 02201_ScheduleManager.lua_fd8fe791f064.luajit

local StaticProps = {}
C_ScheduleManager = DefClass("C_ScheduleManager", C_ScheduleManager, nil, StaticProps)
local M = C_ScheduleManager

M.ctor = function(self)
	self:OnInit()
end

M.OnInit = function(self)
end

gScheduleManager = gScheduleManager or C_ScheduleManager.new()
