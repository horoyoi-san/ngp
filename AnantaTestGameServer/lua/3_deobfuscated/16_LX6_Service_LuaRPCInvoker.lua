local Define = require("LX6/Service/RPCCommonDefine")
local Queue = require("LX6/Service/RpcResultQueue")
local RPCTask = require("LX6/Service/RpcTask")
local MidToName = require("LuaGen/AutoGen/RPCMethodIdToName")
local LogUtils = LX6.Utils.LogUtilsLua
local LuaRPCInvoker = {
	recursive_lock = 0,
	writer = UX.RPC.Serialize.UXBinaryWriter.New(32),
	__index = LuaRPCInvoker,
	New = function (self, o)
		o = o or {}

		setmetatable(o, self)

		return o
	end
}

function pretty_print(...)
	local s = ""

	for i, v in ipairs({
		...
	}) do
		s = s .. tostring(v) .. " "
	end

	return s
end

function LuaRPCInvoker:Invoke(methodId, serializer, ...)
	if gCS.LuaUtils.IsOnEditor and not gLuaDataManager.isNetworkAvailable then
		if not gCS.NetworkManager:IsServerConnected() then
			print_error("在断网过程中，调用RPC：" .. MidToName[methodId] .. "，因为必然会超时")
		else
			print_error("在Loading过程中，调用RPC：" .. MidToName[methodId] .. "，因为必然会超时")
		end
	end

	local sender = self.Sender()

	if not sender then
		return
	end

	local stacktrace = nil

	if gCS.LuaUtils.IsOnEditor then
		stacktrace = debug.traceback()
	end

	if not sender:CallMethod(methodId, stacktrace, {
		...
	}) then
		local t = RPCTask.New(methodId)

		t:SetError(Define.UXRPCTaskError.SendMessageTooFast)

		return t
	end

	local invokeId = sender:GetNextInvokeId()
	local task = RPCTask.New(methodId, invokeId)
	self.writer.Position = Define.ProtocolIndex.Mode

	self.writer:WriteByte(Define.UxRpcPacketMode.Invoke)
	self.writer:WriteInt32(methodId)
	self.writer:WriteInt32(invokeId)

	if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsRpcPrinting and LX6.Engine.DebugRpcMgr.FilterRpc(MidToName[methodId]) then
		local serviceName = UX.RPC.LuaRpcProcessor.GetMethodServiceName(methodId)

		print_warn(gString.Format("[Lua rpc: c->%s] [%s]", serviceName, MidToName[methodId]), ...)
		LogUtils.RecordRPC(gString.Format("[c->s] [%s].[%s] [%s]", serviceName, MidToName[methodId], pretty_print(...)))
	end

	if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsProtocolRpcTest then
		local args = {
			...
		}
		local tmpArgs = {}

		for i = 1, #args do
			local v = args[i]

			if v == nil then
				tmpArgs[i] = "nil"
			elseif type(v) == "table" then
				tmpArgs[i] = table.tostring(v, false)
			else
				tmpArgs[i] = args[i]
			end
		end

		L50.Gm.AutoQaFunctions.OnSendProtocolLuaRPC(true, MidToName[methodId], tmpArgs)
	end

	if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsRPCCollect then
		L50.Gm.AutoQaFunctions.SendRpcName(MidToName[methodId], 0)
	end

	serializer(self.writer, ...)

	local err = sender:SendData(methodId, self.writer)

	if err ~= 0 then
		if self.recursive_lock < 5 then
			self.recursive_lock = self.recursive_lock + 1

			task:SetError(err)

			self.recursive_lock = self.recursive_lock - 1
		else
			print_error("recursive_lock", MidToName[methodId], ...)

			self.recursive_lock = 0
		end

		return task
	end

	Queue(sender):EnqueueResult(task)

	return task
end

function LuaRPCInvoker:Notify(methodId, serializer, ...)
	local sender = self.Sender()

	if not sender then
		return
	end

	local stacktrace = nil

	if gCS.LuaUtils.IsOnEditor then
		stacktrace = debug.traceback()
	end

	if not sender:CallMethod(methodId, stacktrace, {
		...
	}) then
		print_warn("send rpc too fast " .. methodId)

		return
	end

	self.writer.Position = Define.ProtocolIndex.Mode

	self.writer:WriteByte(Define.UxRpcPacketMode.Notify)
	self.writer:WriteInt32(methodId)

	if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsRpcPrinting and LX6.Engine.DebugRpcMgr.FilterRpc(MidToName[methodId]) then
		local serviceName = UX.RPC.LuaRpcProcessor.GetMethodServiceName(methodId)

		print_warn(gString.Format("[Lua rpc: c->%s] [%s]", serviceName, MidToName[methodId]), ...)
		LogUtils.RecordRPC(gString.Format("[c->s] [%s].[%s]", serviceName, MidToName[methodId], pretty_print(...)))
	end

	if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsProtocolRpcTest then
		local args = {
			...
		}
		local tmpArgs = {}

		for i = 1, #args do
			local v = args[i]

			if v == nil then
				tmpArgs[i] = "nil"
			elseif type(v) == "table" then
				tmpArgs[i] = table.tostring(v, false)
			else
				tmpArgs[i] = args[i]
			end
		end

		L50.Gm.AutoQaFunctions.OnSendProtocolLuaRPC(true, MidToName[methodId], tmpArgs)
	end

	if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsRPCCollect then
		L50.Gm.AutoQaFunctions.SendRpcName(MidToName[methodId], 0)
	end

	serializer(self.writer, ...)
	sender:SendData(methodId, self.writer)
end

return LuaRPCInvoker
