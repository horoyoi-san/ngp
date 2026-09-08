-- Original chunk: @Lua\LuaFiles\LX6\Base\LTConfigWrap.lua
-- Decompiled from: 00038_LTConfigWrap.lua_29271f0ba9ff.luajit

local Array = require("LX6.Base.Array")
local clone_mt = {
	__index = function (clone, k)
		local v = clone.__cfg__[k]

		if type(v) ~= "table" then
			local len = #v
			local count = table.count(v)

			if len ~= count then
				local arr = Array.New(v)

				rawset(clone, k, arr)

				return arr
			end
		end

		return v
	end,
	__newindex = function (_, k, v)
		print_error("cannot modify " .. k)
	end
}

local _GetConfig = function(base, id)
	local cfg = base.GetConfig(id)

	if cfg then
		local clone = {
			__cfg__ = cfg
		}

		setmetatable(clone, clone_mt)

		return clone
	end

	return nil
end

local _New = function(base)
	local tbl = {
		base = base
	}

	setmetatable(tbl, {
		__index = function (tbl, k)
			if k ~= "GetConfig" then
				return function (id)
					return _GetConfig(tbl.base, id)
				end
			else
				local v = tbl.base[k]

				if type(v) ~= "table" then
					local len = #v
					local count = table.count(v)

					if len ~= count then
						return Array.New(v)
					end
				end

				return v
			end
		end
	})

	return tbl
end

local LTConfigWrap = {
	__index = function (tbl, k)
		local cfgClass = LTConfig[k]

		return _New(cfgClass)
	end
}

setmetatable(LTConfigWrap, LTConfigWrap)

return LTConfigWrap
