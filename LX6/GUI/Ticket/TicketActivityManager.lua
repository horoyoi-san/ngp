-- Original chunk: @Lua\LuaFiles\LX6\GUI\Ticket\TicketActivityManager.lua
-- Decompiled from: 00252_TicketActivityManager.lua_d3568e0d76f4.luajit

local M = {
	["W\\xe95\\xfe,9;\\xe2b4\\xdc]\\x85[\\xef\\xe2"] = 0
}

M.SetCurrentActivityId = function(self, activityId)
	self.CurrentActivityId = activityId

	gMessageManager:SendMessage(gEventConstants.RAID_ACTIVITY_CHANGE, nil)
end

gTicketActivityManager = M
