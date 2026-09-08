-- Original chunk: @Lua\LuaFiles\Core\Set\init.lua
-- Decompiled from: 01121_init.lua_baf743329814.luajit

local utils = require("Core.Set.utils")

Set = function(list)
	local self = {
		items = {},
		size = 0
	}

	if type(list) ~= "table" then
		for _, value in ipairs(list) do
			self.items[value] = true
			self.size = self.size + 1
		end
	end

	self.insert = function(value)
		if not self.items[value] then
			self.items[value] = true
			self.size = self.size + 1
		end
	end

	self.has = function(value)
		return self.items[value] ~= true
	end

	self.clear = function()
		self.items = {}
		self.size = 0
	end

	self.clearNoAlloc = function()
		table.clear(self.items)

		self.size = 0
	end

	self.delete = function(value)
		if self.items[value] then
			self.items[value] = nil
			self.size = self.size - 1

			return true
		end

		return false
	end

	self.each = function(callback)
		for key in pairs(self.items) do
			callback(key)
		end
	end

	self.every = function(callback)
		for key in pairs(self.items) do
			if not callback(key) then
				return false
			end
		end

		return true
	end

	self.any = function(callback)
		for key in pairs(self.items) do
			if callback(key) then
				return true
			end
		end

		return false
	end

	self.union = function(...)
		local args = {
			...
		}
		local result = Set(utils.to_array(self.items))

		for _, set in ipairs(args) do
			set.each(function (value)
				result.insert(value)
			end)
		end

		return result
	end

	self.unionInplace = function(...)
		local args = {
			...
		}

		for _, set in ipairs(args) do
			set.each(function (value)
				self.insert(value)
			end)
		end
	end

	self.intersection = function(...)
		local args = {
			...
		}
		local result = Set()

		self.each(function (value)
			local is_common = true

			for _, set in ipairs(args) do
				if not set.has(value) then
					is_common = false

					break
				end
			end

			if is_common then
				result.insert(value)
			end
		end)

		return result
	end

	local tmpT = {}

	self.intersectionNoAlloc = function(...)
		local args = {
			...
		}

		self.each(function (value)
			for _, set in ipairs(args) do
				if not set.has(value) then
					table.insert(tmpT, value)

					break
				end
			end
		end)

		for _, v in ipairs(tmpT) do
			self.delete(v)
		end

		table.clear(tmpT)

		return self
	end

	self.difference = function(...)
		local args = {
			...
		}
		local result = Set()

		self.each(function (value)
			local is_common = false

			for _, set in ipairs(args) do
				if set.has(value) then
					is_common = true

					break
				end
			end

			if not is_common then
				result.insert(value)
			end
		end)

		return result
	end

	self.symmetric_difference = function(set)
		local difference = Set(utils.to_array(self.items))

		set.each(function (value)
			if difference.has(value) then
				difference.delete(value)
			else
				difference.insert(value)
			end
		end)

		return difference
	end

	self.is_superset = function(subset)
		return self.every(function (value)
			return subset.has(value)
		end)
	end

	return self
end

return Set
