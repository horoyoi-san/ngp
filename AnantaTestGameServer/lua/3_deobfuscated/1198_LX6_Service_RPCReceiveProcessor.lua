local receiver = require("LX6/Service/LuaRPCReceiver")
local Base = require("LX6/Service/RPCDeserializeBase")
local Auto, md5 = require("LuaGen/AutoGen/RPCDeserializeAuto")

function receiver.Dispatcher(reader, mid)
	return Base.Dispatcher(Auto, reader, mid)
end

function receiver.ReturnMessageDeserializer(reader, mid)
	return Base.ReturnMessageDeserializer(Auto, reader, mid)
end

function receiver.GetRpcExportOption(mid)
	return Auto.midToExportOption[mid]
end

return receiver
