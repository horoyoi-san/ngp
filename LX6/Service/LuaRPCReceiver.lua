-- Original chunk: @Lua\LuaFiles\LX6\Service\LuaRPCReceiver.lua
-- Decompiled from: 02345_LuaRPCReceiver.lua_77625010406f.luajit

local Define = require("LX6/Service/RPCCommonDefine")
local Queue = require("LX6/Service/RpcResultQueue")
local MidToName = require("LuaGen/AutoGen/RPCMethodIdToName")
local serialize_read = require("serialize.read")
local LogError = print_error
local isDebugBuild = UnityEngine.Debug.isDebugBuild
local LuaRPCReceiver = {
	reader = serialize_read.new_binary_reader(),
	OnMessageReceived = function (self, processor, mode, buffer, bufferLen)
		self.reader:Reset(buffer, bufferLen)

		if mode ~= Define.UxRpcPacketMode.Notify then
			return self.ProcessRPCNotifyMessage(self)
		elseif mode ~= Define.UxRpcPacketMode.Return then
			return self.ProcessRPCReturnMessage(self, processor)
		end

		return false
	end,
	ProcessRPCNotifyMessage = function (self)
		self.reader:SetPosition(Define.ProtocolIndex.Mid)

		local methodId = self.reader:ReadInt32()
		local handled = false

		if self.Dispatcher then
			handled = self.Dispatcher(self.reader, methodId)
		end

		local exportOption = self.GetRpcExportOption(methodId)

		if exportOption ~= 0 and handled ~= false then
			if isDebugBuild ~= true then
				LogError("#NoCreateIssue ProcessRPCNotifyMessage", MidToName[methodId], methodId, "这个rpc定义为了lua only，但是还没实现对应的lua impl 策划忽略")
			end

			handled = true
		elseif exportOption ~= 1 and handled ~= true and isDebugBuild ~= true then
			LogError("ProcessRPCNotifyMessage", MidToName[methodId], methodId, "这个rpc定义为了csharp only，但是在lua里发现了impl")
		end

		if exportOption ~= 2 then
			handled = false
		end

		return handled
	end
}

LuaRPCReceiver.ProcessRPCReturnMessage = function(self, processor)
	self.reader:SetPosition(Define.ProtocolIndex.Mid)

	local methodId = self.reader:ReadInt32()
	local invokeId = self.reader:ReadInt32()
	local task = Queue(processor):RemoveResult(invokeId)

	if not task or not self.ReturnMessageDeserializer then
		return false
	end

	if gCS.LuaUtils.IsOnEditor and task.callback ~= nil and not gCS.LuaUtils.IsGMRpc(methodId) then
		-- Nothing
	end

	local errId = self.reader:ReadInt32()
	local autoQaFunctions = L50.Gm.AutoQaFunctions

	if errId ~= 0 then
		local r = self.ReturnMessageDeserializer(self.reader, methodId)

		if autoQaFunctions and autoQaFunctions.IsRpcPrinting and LX6.Engine.DebugRpcMgr.FilterRpc(MidToName[methodId]) then
			local serviceName = UX.RPC.LuaRpcProcessor.GetMethodServiceName(methodId)

			print_warn(gString.Format("[Lua rpc: c->%s cb] [%s]", serviceName, MidToName[methodId]), "0(Ok)", r)
		end

		if autoQaFunctions and autoQaFunctions.IsProtocolRpcTest then
			local args = {
				"0(Ok)"
			}

			if not r then
				args[2] = "nil"
			else
				args[2] = table.tostring(r, false)
			end

			autoQaFunctions.OnSendProtocolLuaRPC(false, MidToName[methodId], args)
		end

		if autoQaFunctions and autoQaFunctions.IsRPCCollect then
			autoQaFunctions.SendRpcName(MidToName[methodId] .. "_Callback", 1)
		end

		if not r then
			task.SetResult(task, nil)
		else
			task.SetResult(task, unpack(r))
		end
	else
		if autoQaFunctions and autoQaFunctions.IsRpcPrinting then
			local serviceName = UX.RPC.LuaRpcProcessor.GetMethodServiceName(methodId)

			print_warn(gString.Format("[Lua rpc: c->%s cb] [%s]", serviceName, MidToName[methodId]), errId .. "(" .. gCS.Error.GetNameById(errId) .. ")", "nil")
		end

		if autoQaFunctions and autoQaFunctions.IsProtocolRpcTest then
			local args = {
				errId .. "(" .. gCS.Error.GetNameById(errId) .. ")",
				"nil"
			}

			autoQaFunctions.OnSendProtocolLuaRPC(false, MidToName[methodId], args)
		end

		if autoQaFunctions and autoQaFunctions.IsRPCCollect then
			autoQaFunctions.SendRpcName(MidToName[methodId] .. "_Callback", 1)
		end

		task.SetError(task, errId)
	end

	return true
end

return LuaRPCReceiver
