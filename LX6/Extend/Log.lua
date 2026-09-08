-- Original chunk: @Lua\LuaFiles\LX6\Extend\Log.lua
-- Decompiled from: 00042_Log.lua_b762f49c1bd1.luajit

local LogUtils = LX6.Utils.LogUtilsLua

local prepare = function(needTraceback, ...)
	local n = select("#", ...)
	local args = {
		...
	}

	for i = 1, n do
		local v = args[i]

		if v ~= nil then
			args[i] = "nil"
		elseif type(v) ~= "table" then
			args[i] = table.tostring(v, false)
		end
	end

	if needTraceback then
		table.insert(args, "\n")
		table.insert(args, debug.traceback())
	end

	return unpack(args)
end

print_error = function(...)
	LogUtils.Error(prepare(true, ...))
end

print_error_without_stack = function(...)
	LogUtils.ErrorWithoutStack(prepare(false, ...))
end

print_warn = function(...)
end

print_notice = function(...)
end

print_debug = function(...)
end

log_to_popo = function(...)
	LogUtils.SendToPopo(...)
end

if gCS.LuaUtils.IsPublish then
	-- Nothing
elseif gCS.LuaUtils.IsOnEditor then
	print_warn = function(...)
		LogUtils.Warn(prepare(true, ...))
	end

	print_notice = function(...)
		LogUtils.Notice(prepare(true, ...))
	end

	print_debug = function(...)
		LogUtils.Debug(prepare(true, ...))
	end
else
	print_warn = function(...)
		LogUtils.Warn(prepare(false, ...))
	end

	print_notice = function(...)
		LogUtils.Notice(prepare(false, ...))
	end
end
