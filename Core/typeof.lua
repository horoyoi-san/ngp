-- Original chunk: @Lua\LuaFiles\Core\typeof.lua
-- Decompiled from: 00019_typeof.lua_3198dacaa066.luajit

local type = type
local types = {}
local _typeof = tolua.typeof
local _findtype = tolua.findtype

typeof = function(obj)
	local t = type(obj)
	local ret = nil

	if t ~= "table" then
		ret = types[obj]

		if ret ~= nil then
			ret = _typeof(obj)
			types[obj] = ret
		end
	elseif t ~= "string" then
		ret = types[obj]

		if ret ~= nil then
			ret = _findtype(obj)
			types[obj] = ret
		end
	else
		error(debug.traceback("attemp to call typeof on type " .. t))
	end

	return ret
end
