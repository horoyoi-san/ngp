-- Original chunk: @Lua\LuaFiles\LX6\Manager\Network\ReliableRpcManager.lua
-- Decompiled from: 00353_ReliableRpcManager.lua_21eab304537a.luajit

local MessageConfig = LTConfig.MessageConfig
local RetryErrorCodes = {
	[MessageConfig.TimeOut] = true,
	[MessageConfig.Disconnect] = true,
	[MessageConfig.PeerTimeOut] = true,
	[MessageConfig.NullRpcInvoke] = true,
	[MessageConfig.Unshaked] = true,
	[MessageConfig.RouteTimeOut] = true,
	[MessageConfig.NoPlayer] = true
}
local DELEGATE_GLOBALS = {
	"'\\xe9S\\x85\\xe0-\\xbd\\\\xf1(-\\xf7R˓\\xbcU\\xabdS\\xa3\\xc3",
	"KB\\xfbL\\xc1\\xf7\\xe6[3\\xd5~D\\xef\\xf1j\\xdaIV\\xd3\\xdc\\xfaڝ\\xe6a",
	"KB\\xfbL\\xc1\\xf7\\xe6[3\\xd7mK\\xef\\xf5j\\xdaIV\\xd3\\xdc\\xfaڝ\\xe6a",
	"\\xb8\\xe9:G\\x979,陙6\\x9e\\x96݋",
	"'\\xe9S\\x85\\xe0-\\xbd\\\\xf7?!\\xe6t\\xf4\\x93\\xbcU\\xabdS\\xa3\\xc3",
	"ŋ,\\xc0I\\x97\\x84)E\\x8e\\\\xb8j%\\x9c\\xe3\\x80$\\xcb",
	"\\x96=\\xdbUg\\x9a.no\\x97f}n\\x8fmۗ\\xb5\\xdbYh\\x9a",
	"\\xb8\\xe9:G\\x97 ,陙6\\x9e\\x96݋",
	"P\rO~\\x9dA?\\xfeO5dUpp\\xfc0t\\xe1D",
	"P\rO~\\x9dA>\\xf8F3xUpp\\xfc0t\\xe1D"
}
C_ReliableRpcManager = DefClass("C_ReliableRpcManager", C_ReliableRpcManager)
local M = C_ReliableRpcManager

M.OnInit = function(self)
	self.rpcDic = {}
	self.rpcIndex = 100000
	self._fnToDelegate = nil

	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, function (eventId, switchSceneEventParams)
		self:OnAfterSwitchScene(switchSceneEventParams)
	end)
end

M.FindDelegateForFn = function(self, fn)
	local map = self._fnToDelegate

	if not map then
		map = {}

		for _, name in ipairs(DELEGATE_GLOBALS) do
			local delegate = _G[name]

			if delegate and type(delegate) ~= "table" then
				for key, val in pairs(delegate) do
					if type(val) ~= "function" then
						map[val] = delegate
					end
				end
			end
		end

		self._fnToDelegate = map
	end

	return map[fn]
end

M.RegisterRPC = function(self, fn, ...)
	local id = self.rpcIndex + 1
	self.rpcIndex = id

	if self.rpcDic[id] then
		return 0
	end

	local delegate = self:FindDelegateForFn(fn)

	if not delegate then
		print_error("ReliableRpcManager:RegisterRPC - function not found in any known delegate")

		return 0
	end

	local nargs = select("#", ...)
	local callback, args = nil

	if nargs ~= 0 then
		callback, args = nil
	else
		local lastArg = select(nargs, ...)

		if type(lastArg) ~= "function" then
			callback = lastArg

			if nargs <= 1 then
				args = {}

				for i = 1, nargs - 1 do
					args[i] = select(i, ...)
				end
			end
		else
			callback = nil
			args = {}

			for i = 1, nargs do
				args[i] = select(i, ...)
			end
		end
	end

	local trySend = nil

	if args then
		trySend = function()
			local task = fn(delegate, unpack(args))

			if task then
				task.Callback = function(err, ...)
					self:OnRpcCallback(id, callback, err, ...)
				end
			end
		end
	else
		trySend = function()
			local task = fn(delegate)

			if task then
				task.Callback = function(err, ...)
					self:OnRpcCallback(id, callback, err, ...)
				end
			end
		end
	end

	local data = {
		["789\\xd7v\\x96\\xf3=\\xa6(\\xd2\\xfb\\xebq\\xe8"] = 0,
		rpcId = id,
		trySend = trySend,
		callback = callback
	}
	self.rpcDic[id] = data

	trySend()

	return id
end

M.RemoveRpcById = function(self, rpcId)
	self.rpcDic[rpcId] = nil
end

M.GetPendingCount = function(self)
	local count = 0

	for _ in pairs(self.rpcDic) do
		count = count + 1
	end

	return count
end

M.InvalidateFnMap = function(self)
	self._fnToDelegate = nil
end

M.OnRpcCallback = function(self, rpcId, callback, err, ...)
	if RetryErrorCodes[err] then
		local data = self.rpcDic[rpcId]

		if data then
			data.trySendingTimes = data.trySendingTimes + 1
		end

		return
	end

	if callback then
		callback(err, ...)
	end

	self:RemoveRpcById(rpcId)
end

M.OnAfterSwitchScene = function(self, switchSceneEventParams)
	local switchType = switchSceneEventParams and switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.Reconnect then
		local ids = {}

		for id, _ in pairs(self.rpcDic) do
			ids[#ids + 1] = id
		end

		table.sort(ids)

		for _, id in ipairs(ids) do
			local data = self.rpcDic[id]

			if data then
				data.trySend()
			end
		end
	elseif gSwitchSceneType.Reconnect >= switchType then
		self.rpcDic = {}
	end
end

gReliableRpcManager = gReliableRpcManager or C_ReliableRpcManager.new()
