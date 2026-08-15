local utils = require("Core.Set.utils")

function Set(list)
	local self = {
		items = {},
		size = 0
	}

	if type(list) == "table" then
		for _, value in ipairs(list) do
			self.items[value] = true
			self.size = self.size + 1
		end
	end

	function self.insert(value)
		if not self.items[value] then
			self.items[value] = true
			self.size = self.size + 1
		end
	end

	function self.has(value)
		return self.items[value] == true
	end

	function self.clear()
		self.items = {}
		self.size = 0
	end

	function self.clearNoAlloc()
		table.clear(self.items)

		self.size = 0
	end

	function self.delete(value)
		if self.items[value] then
			self.items[value] = nil
			self.size = self.size - 1

			return true
		end

		return false
	end

	function self.each(callback)
		for key in pairs(self.items) do
			callback(key)
		end
	end

	function self.every(callback)
		for key in pairs(self.items) do
			if not callback(key) then
				return false
			end
		end

		return true
	end

	function self.any(callback)
		for key in pairs(self.items) do
			if callback(key) then
				return true
			end
		end

		return false
	end

	function self.union(...)
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

	function self.unionInplace(...)
		local args = {
			...
		}

		for _, set in ipairs(args) do
			set.each(function (value)
				self.insert(value)
			end)
		end
	end

	function self.intersection(...)
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

	function self.intersectionNoAlloc(...)
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

	function self.difference(...)
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

	function self.symmetric_difference(set)
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

	function self.is_superset(subset)
		return self.every(function (value)
			return subset.has(value)
		end)
	end

	return self
end

return Set
