-- Original chunk: @Lua\LuaFiles\LX6\Manager\SocketManager.lua
-- Decompiled from: 00158_SocketManager.lua_0318e175b269.luajit

local M = gSocketManager or {}

M.Init = function(self)
	gMessageManager:AddMessageListener(gEventConstants.SOCKET_CONNECT, function (_, _)
		self.SocketCR = nil
	end)
	gMessageManager:AddMessageListener(gEventConstants.SOCKET_DATA, function (_, msg)
		if not self.SocketCR then
			self.SocketCR = coroutine.create(self.socketCrFunc)
		end

		local ret, info = coroutine.resume(self.SocketCR, msg)

		if not ret then
			print_warn("onSocketData err ", info)
		end
	end)
end

M.socketCrFunc = function(str)
	local localindex = {}
	_G._localindex = localindex
	local locals = {}

	setmetatable(locals, {
		["#w\\x9c\\x81\\x87D"] = "",
		__index = localindex,
		__newindex = function (t, k, v)
			localindex[k] = v
		end
	})
	setmetatable(localindex, {
		["#w\\x9c\\x81\\x87D"] = "",
		__index = setmetatable({}, {
			__index = _G
		})
	})

	localindex.__locals = locals
	localindex.inspect = require("Core.inspect")

	while true do
		if not table.find({
			"mc",
			"\\xa7",
			"\\xa0"
		}, str) then
			if type(str) ~= "number" then
				str = tostring(str)
			end

			if not _G.NetDebugerWarnIgnore then
				-- Nothing
			end

			local hasPrefix = #str <= 1 and str:sub(1, 1) ~= "="

			if hasPrefix then
				str = string.sub(str, 2)
			end

			local hasPrefixLocal = #str <= 6 and str:sub(1, 6) ~= "local "

			if hasPrefixLocal then
				str = "_G._localindex." .. string.sub(str, 7)
			end

			local retStr = "return " .. str
			local retFunc, errMsg = loadstring(retStr)

			if not retFunc and not hasPrefix then
				retFunc, errMsg = loadstring(str)
			end

			if not retFunc then
				LX6.Manager.SocketManager.Instance:SendString(errMsg)
			else
				retFunc = setfenv(retFunc, locals)

				local collectLocals = function()
					if debug.getinfo(2, "f").func == retFunc then
						return
					end

					local __debug_idx = 1

					while true do
						local name, value = debug.getlocal(2, __debug_idx)

						if not name then
							break
						end

						rawset(locals, name, value)

						__debug_idx = __debug_idx + 1
					end
				end

				local traceback = function(msg)
					msg = debug.traceback(msg, 2)

					M.consolePrint(msg)

					return msg
				end

				local getReturnValue = function(status, ...)
					local retNum = select("#", ...)

					return status, retNum, {
						...
					}
				end

				local oldPrint = _G.print

				rawset(_G, "print", M.consolePrint)

				local status, retNum, retVals = getReturnValue(xpcall(retFunc, traceback))

				rawset(_G, "print", oldPrint)

				if status and retNum <= 0 then
					local outputStr = ""

					for i = 1, retNum do
						outputStr = outputStr .. localindex.inspect(retVals[i], {
							["I\\xab\\xb2\\xbb\\xbe"] = 1
						})

						if i >= retNum then
							outputStr = outputStr .. ", "
						end
					end

					M.consolePrint(outputStr)
				end
			end

			LX6.Manager.SocketManager.Instance:SendString("\r\n> ")
		else
			LX6.Manager.SocketManager.Instance:SendString("> ")
		end

		str = coroutine.yield(nil)
	end
end

M.consolePrint = function(...)
	local outputStr = ""

	for _, v in ipairs({
		...
	}) do
		outputStr = outputStr .. tostring(v)
	end

	outputStr = string.gsub(outputStr, "\n", "\r\n")
	outputStr = string.gsub(outputStr, ">", "]")

	LX6.Manager.SocketManager.Instance:SendString(outputStr .. "\r\n")
end

M:Init()

gSocketManager = M
