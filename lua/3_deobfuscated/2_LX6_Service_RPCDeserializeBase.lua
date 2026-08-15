local MidToName = require("LuaGen/AutoGen/RPCMethodIdToName")
local LogUtils = LX6.Utils.LogUtilsLua
local Serializer = {}
local SerializeObjectMarkNull = 0

function Serializer.Dispatcher(ctx, br, mid)
	local reader = ctx.midToReader[mid]

	if not reader then
		return false
	end

	local handler = ctx.sidToImpl[math.floor(mid / 1000000)][ctx.midToName[mid]]

	if handler then
		if L50.Gm.AutoQaFunctions and (L50.Gm.AutoQaFunctions.IsRpcPrinting or L50.Gm.AutoQaFunctions.IsProtocolRpcTest or L50.Gm.AutoQaFunctions.IsRPCCollect) then
			local args = {
				reader(br)
			}

			if L50.Gm.AutoQaFunctions.IsRPCCollect then
				L50.Gm.AutoQaFunctions.SendRpcName(MidToName[mid], 1)
			end

			if L50.Gm.AutoQaFunctions.IsRpcPrinting and LX6.Engine.DebugRpcMgr.FilterRpc(MidToName[mid]) then
				local serviceName = UX.RPC.LuaRpcProcessor.GetMethodServiceName(mid)

				print_warn(gString.Format("[Lua rpc: %s->c] [%s] ", serviceName, MidToName[mid]), args)
				LogUtils.RecordRPC(gString.Format("[s->c] [%s].[%s] %s", serviceName, MidToName[mid], args))
			end

			if L50.Gm.AutoQaFunctions.IsProtocolRpcTest then
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

				L50.Gm.AutoQaFunctions.OnSendProtocolLuaRPC(false, MidToName[mid], tmpArgs)
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

function Serializer.ReturnMessageDeserializer(ctx, br, mid)
	local reader = ctx.midToReturnMessageReader[mid]

	if not reader then
		return
	end

	return {
		reader(br)
	}
end

function Serializer.ReadBuffer(reader)
	if reader:ReadByte() ~= SerializeObjectMarkNull then
		return reader:ReadBuffer()
	else
		return nil
	end
end

function Serializer.ReadComplex(reader, nontrivial)
	local obj = {}
	local byte = reader:ReadByte()

	if byte ~= SerializeObjectMarkNull then
		nontrivial(reader, obj)
	else
		return nil
	end

	return obj
end

function Serializer.ReadStruct(reader, nontrivial)
	local obj = {}

	nontrivial(reader, obj)

	return obj
end

function Serializer.ReadList(reader, itemReader)
	local byte = reader:ReadByte()

	if byte == SerializeObjectMarkNull then
		return nil
	end

	local size = reader:ReadInt32()
	local list = {
		Count = size,
		Length = size
	}

	for i = 1, size do
		list[i] = itemReader(reader)
	end

	return list
end

function Serializer.ReadDict(reader, keyReader, itemReader)
	if reader:ReadByte() == SerializeObjectMarkNull then
		return nil
	end

	local size = reader:ReadInt32()
	local dict = {}

	for i = 1, size do
		local key = keyReader(reader)
		dict[key] = itemReader(reader)
	end

	return dict
end

return Serializer
