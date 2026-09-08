-- Original chunk: @Lua\LuaFiles\LX6\Service\RPCDeserializeBase.lua
-- Decompiled from: 02346_RPCDeserializeBase.lua_49bd54ceeac5.luajit

local MidToName = require("LuaGen/AutoGen/RPCMethodIdToName")
local LogUtils = LX6.Utils.LogUtilsLua
local Serializer = {}
local SerializeObjectMarkNull = 0

Serializer.Dispatcher = function(ctx, br, mid)
	local reader = ctx.midToReader[mid]

	if not reader then
		return false
	end

	local handler = ctx.sidToImpl[math.floor(mid / 1000000)][ctx.midToName[mid]]

	if handler then
		local autoQaFunctions = L50.Gm.AutoQaFunctions

		if autoQaFunctions and (autoQaFunctions.IsRpcPrinting or autoQaFunctions.IsProtocolRpcTest or autoQaFunctions.IsRPCCollect) then
			local args = {
				reader(br)
			}

			if autoQaFunctions.IsRPCCollect then
				autoQaFunctions.SendRpcName(MidToName[mid], 1)
			end

			if autoQaFunctions.IsRpcPrinting and LX6.Engine.DebugRpcMgr.FilterRpc(MidToName[mid]) then
				local serviceName = UX.RPC.LuaRpcProcessor.GetMethodServiceName(mid)

				print_warn(gString.Format("[Lua rpc: %s->c] [%s] ", serviceName, MidToName[mid]), args)
				LogUtils.RecordRPC(gString.Format("[s->c] [%s].[%s] %s", serviceName, MidToName[mid], args))
			end

			if autoQaFunctions.IsProtocolRpcTest then
				local tmpArgs = {}

				for i = 1, #args do
					local v = args[i]

					if v ~= nil then
						tmpArgs[i] = "nil"
					elseif type(v) ~= "table" then
						tmpArgs[i] = table.tostring(v, false)
					else
						tmpArgs[i] = args[i]
					end
				end

				autoQaFunctions.OnSendProtocolLuaRPC(false, MidToName[mid], tmpArgs)
			end

			handler(unpack(args, 1, table.maxn(args)))

			return true
		end

		handler(reader(br))

		return true
	else
		return false
	end
end

Serializer.ReturnMessageDeserializer = function(ctx, br, mid)
	local reader = ctx.midToReturnMessageReader[mid]

	if not reader then
		return
	end

	return {
		reader(br)
	}
end

Serializer.ReadBuffer = function(reader)
	if reader.ReadByte(reader) == SerializeObjectMarkNull then
		return reader.ReadBuffer(reader)
	else
		return nil
	end
end

Serializer.ReadBuffer7Bit = function(reader)
	if reader.ReadByte(reader) == SerializeObjectMarkNull then
		return reader.ReadBuffer7Bit(reader)
	else
		return nil
	end
end

Serializer.ReadComplex = function(reader, nontrivial)
	local obj = {}
	local byte = reader.ReadByte(reader)

	if byte == SerializeObjectMarkNull then
		nontrivial(reader, obj)
	else
		return nil
	end

	return obj
end

Serializer.ReadStruct = function(reader, nontrivial)
	local obj = {}

	nontrivial(reader, obj)

	return obj
end

Serializer.ReadList = function(reader, itemReader)
	local byte = reader.ReadByte(reader)

	if byte ~= SerializeObjectMarkNull then
		return nil
	end

	local size = reader.ReadInt32(reader)
	local list = {
		Count = size,
		Length = size
	}

	for i = 1, size do
		list[i] = itemReader(reader)
	end

	return list
end

Serializer.ReadList7Bit = function(reader, itemReader)
	local byte = reader.ReadByte(reader)

	if byte ~= SerializeObjectMarkNull then
		return nil
	end

	local size = reader.ReadInt7Bit(reader)
	local list = {
		Count = size,
		Length = size
	}

	for i = 1, size do
		list[i] = itemReader(reader)
	end

	return list
end

Serializer.ReadDict = function(reader, keyReader, itemReader)
	if reader.ReadByte(reader) ~= SerializeObjectMarkNull then
		return nil
	end

	local size = reader.ReadInt32(reader)
	local dict = {}

	for i = 1, size do
		local key = keyReader(reader)
		dict[key] = itemReader(reader)
	end

	return dict
end

Serializer.ReadDict7Bit = function(reader, keyReader, itemReader)
	if reader.ReadByte(reader) ~= SerializeObjectMarkNull then
		return nil
	end

	local size = reader.ReadInt7Bit(reader)
	local dict = {}

	for i = 1, size do
		local key = keyReader(reader)
		dict[key] = itemReader(reader)
	end

	return dict
end

return Serializer
