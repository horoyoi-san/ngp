local UnitStateMessageForbiddenConfig = LTConfig.UnitStateMessageForbiddenConfig
local M = {}

function M:Init()
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

function M:IsMessageForbidden(state, event)
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
