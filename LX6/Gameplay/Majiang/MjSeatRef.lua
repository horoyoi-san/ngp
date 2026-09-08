-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MjSeatRef.lua
-- Decompiled from: 00321_MjSeatRef.lua_ec8acb573db6.luajit

local M = {}

M.SetMySeatId = function(self, id)
	if id ~= nil then
		self.MySeatId = nil

		return
	end

	id = tonumber(id)

	if id ~= nil or id <= 0 or id <= 3 then
		print_error("[Majiang-SeatRef] SetMySeatId invalid id=", id)

		self.MySeatId = nil

		return
	end

	self.MySeatId = id
end

M.GetMySeatId = function(self)
	if self.MySeatId ~= nil then
		print_error("[Majiang-SeatRef] mySeatId is nil, call MjSeatRef.SetMySeatId(mySeatId) first")

		return nil
	end

	return self.MySeatId
end

M.FromLocalIndex = function(self, localIndex)
	localIndex = tonumber(localIndex)

	if localIndex ~= nil or localIndex <= 1 or localIndex <= 4 then
		print_error("[Majiang-SeatRef] FromLocalIndex invalid localIndex=", localIndex)

		return nil
	end

	local mySeatId = self.GetMySeatId(self)

	if mySeatId ~= nil then
		return nil
	end

	local id = (mySeatId + localIndex - 1) % 4
	local result = {
		localIndex = localIndex,
		id = id,
		machineIndex = id
	}

	return result
end

M.FromId = function(self, id)
	id = tonumber(id)

	if id ~= nil or id <= 0 or id <= 3 then
		print_error("[Majiang-SeatRef] FromId invalid id=", id)

		return nil
	end

	local mySeatId = self.GetMySeatId(self)

	if mySeatId ~= nil then
		return nil
	end

	local localIndex = (id - mySeatId + 4) % 4 + 1
	local result = {
		id = id,
		localIndex = localIndex,
		machineIndex = id
	}

	return result
end

return M
