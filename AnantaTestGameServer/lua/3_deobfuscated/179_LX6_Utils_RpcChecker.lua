local R = require("LX6/Utils/R")
local M = {
	OnInit = function (self)
		return
	end
}

function Do(...)
	local arg = {
		...
	}

	for i, v in ipairs(arg) do
		Check(v .. "ToClientImpl", "I" .. v .. "ToClient")
	end
end

function Check(path, name)
	local impl = require("LX6/Service/" .. path)
	local interface = R.typeof("UX.Game." .. name)
	local cImpl = R.typeof("LX6.Service." .. path)

	for k, v in pairs(impl._meta) do
		local method = interface.GetMethod(k)

		if method == nil then
			print_error(path .. ":" .. k .. " 已删除，请删除客户端对应代码")
		end
	end

	local BindingFlags = R("System.Reflection.BindingFlags")
	local flags = bit.bor(BindingFlags.Public, BindingFlags.Instance, BindingFlags.DeclaredOnly)
	local allMethods = interface.GetMethods(flags)

	R.foreach(allMethods, function (method)
		if impl[method.Name] == nil and cImpl.GetMethod(method.Name, flags) == nil then
			print_error(path .. ":" .. method.Name .. " 在客户端没有对应实现，也许客户端还没接，也许应该删除服务端代码")
		end
	end)
end

function M:CreateRpcImpl()
	local obj = {}
	local holder = {}

	setmetatable(obj, {
		__index = function (this, key)
			if key == "_meta" then
				return holder
			end

			return holder[key]
		end,
		__newindex = function (this, key, value)
			if holder[key] ~= nil and value ~= nil then
				print_error("重复定义RPC实现：" .. key)
				print_error("如果是打Patch的话，可以先置空RPC再赋值，或者用rawset")

				return
			end

			holder[key] = value
		end
	})

	return obj
end

gRpcChecker = M
