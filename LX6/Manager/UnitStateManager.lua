-- Original chunk: @Lua\LuaFiles\LX6\Manager\UnitStateManager.lua
-- Decompiled from: 00177_UnitStateManager.lua_f0b2404a5aa5.luajit

local UnitStateMessageForbiddenConfig = LTConfig.UnitStateMessageForbiddenConfig
local M = {}

M.Init = function(self)
	local states = {}

	for i = 0, UnitStateMessageForbiddenConfig.count - 1 do
		local cfg = UnitStateMessageForbiddenConfig.LoadAt(i)
		local state = cfg.State
		local event = cfg.Event

		if states[state] then
			states[state][event] = true
		else
			states[state] = {
				[event] = true
			}
		end
	end

	self.states = states
end

M.IsMessageForbidden = function(self, state, event)
	local events = self.states[state]

	if events and (events[event] or events[0]) then
		return true
	end

	events = self.states[0]

	if events and (events[event] or events[0]) then
		return true
	end

	return false
end

gUnitStateManager = M
