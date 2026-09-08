-- Original chunk: @Lua\LuaFiles\LX6\Service\RPCReceiveProcessor.lua
-- Decompiled from: 02344_RPCReceiveProcessor.lua_5c43d55d6fa0.luajit

local receiver = require("LX6/Service/LuaRPCReceiver")
local Base = require("LX6/Service/RPCDeserializeBase")
local Auto, md5 = require("LuaGen/AutoGen/RPCDeserializeAuto")

receiver.Dispatcher = function(reader, mid)
	return Base.Dispatcher(Auto, reader, mid)
end

receiver.ReturnMessageDeserializer = function(reader, mid)
	return Base.ReturnMessageDeserializer(Auto, reader, mid)
end

receiver.GetRpcExportOption = function(mid)
	return Auto.midToExportOption[mid]
end

return receiver
