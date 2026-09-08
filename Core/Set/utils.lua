-- Original chunk: @Lua\LuaFiles\Core\Set\utils.lua
-- Decompiled from: 01122_utils.lua_213d63171e98.luajit

return {
	to_array = function (hash)
		local output = {}

		for key in pairs(hash) do
			table.insert(output, key)
		end

		return output
	end
}
