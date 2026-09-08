-- Original chunk: @Lua\LuaFiles\LX6\Extend\MathEx.lua
-- Decompiled from: 00034_MathEx.lua_25ce49367d61.luajit

math.random_weights_01 = function(items, weights)
	local p = math.random()
	local total = 0

	for i, item in ipairs(items) do
		total = total + weights[i]

		if p < total then
			return item
		end
	end

	return nil
end

math.random_weights = function(items, weights)
	local total = 0

	for i = 1, #weights do
		total = total + weights[i]
	end

	for i = 1, #weights do
		weights[i] = weights[i] / total
	end

	return math.random_weights_01(items, weights)
end

math.random_weights_entry = function(items, weights_entry)
	local total = 0
	local weights = {}

	for i = 1, #items do
		total = total + items[i][weights_entry]
	end

	for i = 1, #items do
		weights[i] = items[i][weights_entry] / total
	end

	return math.random_weights_01(items, weights)
end
