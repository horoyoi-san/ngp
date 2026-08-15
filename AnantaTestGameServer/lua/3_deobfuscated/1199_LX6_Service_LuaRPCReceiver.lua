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

		if mode == Define.UxRpcPacketMode.Notify then
			return self:ProcessRPCNotifyMessage()
		elseif mode == Define.UxRpcPacketMode.Return then
			return self:ProcessRPCReturnMessage(processor)
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

		if exportOption == 0 and handled == false then
			if isDebugBuild == true then
				LogError("#NoCreateIssue ProcessRPCNotifyMessage", MidToName[methodId], methodId, "这个rpc定义为了lua only，但是还没实现对应的lua impl 策划忽略")
			end

			handled = true
		elseif exportOption == 1 and handled == true and isDebugBuild == true then
			LogError("ProcessRPCNotifyMessage", MidToName[methodId], methodId, "这个rpc定义为了csharp only，但是在lua里发现了impl")
		end

		if exportOption == 2 then
			handled = false
		end

		return handled
	end
}

function LuaRPCReceiver:ProcessRPCReturnMessage(processor)
	self.reader:SetPosition(Define.ProtocolIndex.Mid)

	local methodId = self.reader:ReadInt32()
	local invokeId = self.reader:ReadInt32()
	local task = Queue(processor):RemoveResult(invokeId)

	if not task or not self.ReturnMessageDeserializer then
		return false
	end

	if gCS.LuaUtils.IsOnEditor and task.callback == nil and not gCS.LuaUtils.IsGMRpc(methodId) then
		print_error("mid=" .. methodId .. " method=" .. MidToName[methodId] .. " 没有注册Callback，客户端先判断下Rpc需不需要Callback，不需要的话通知服务端删除Callback")
	end

	local errId = self.reader:ReadInt32()

	if errId == 0 then
		local r = self.ReturnMessageDeserializer(self.reader, methodId)

		if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsRpcPrinting and LX6.Engine.DebugRpcMgr.FilterRpc(MidToName[methodId]) then
			local serviceName = UX.RPC.LuaRpcProcessor.GetMethodServiceName(methodId)

			print_warn(gString.Format("[Lua rpc: c->%s cb] [%s]", serviceName, MidToName[methodId]), "0(Ok)", r)
		end

		if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsProtocolRpcTest then
			local args = {
				"0(Ok)"
			}

			if not r then
				args[2] = "nil"
			else
				args[2] = table.tostring(r, false)
			end

			L50.Gm.AutoQaFunctions.OnSendProtocolLuaRPC(false, MidToName[methodId], args)
		end

		if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsRPCCollect then
			L50.Gm.AutoQaFunctions.SendRpcName(MidToName[methodId] .. "_Callback", 1)
		end

		if not r then
			task:SetResult(nil)
		else
			task:SetResult(unpack(r))
		end
	else
		if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsRpcPrinting then
			local serviceName = UX.RPC.LuaRpcProcessor.GetMethodServiceName(methodId)

			print_warn(gString.Format("[Lua rpc: c->%s cb] [%s]", serviceName, MidToName[methodId]), errId .. "(" .. gCS.Error.GetNameById(errId) .. ")", "nil")
		end

		if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsProtocolRpcTest then
			local args = {
				errId .. "(" .. gCS.Error.GetNameById(errId) .. ")",
				"nil"
			}

			L50.Gm.AutoQaFunctions.OnSendProtocolLuaRPC(false, MidToName[methodId], args)
		end

		if L50.Gm.AutoQaFunctions and L50.Gm.AutoQaFunctions.IsRPCCollect then
			L50.Gm.AutoQaFunctions.SendRpcName(MidToName[methodId] .. "_Callback", 1)
		end

		task:SetError(errId)
	end

	return true
end

return LuaRPCReceiver
