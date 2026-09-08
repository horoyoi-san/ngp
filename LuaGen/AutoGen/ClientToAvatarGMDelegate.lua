-- Original chunk: @Lua\LuaGen\AutoGen\ClientToAvatarGMDelegate.lua
-- Decompiled from: 00067_ClientToAvatarGMDelegate.lua_c817fa7c1f53.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToAvatarGMDelegate = invoker.New(invoker)

ClientToAvatarGMDelegate.Sender = function()
	return NetworkManager.LuaGateRpcProcessor
end

SerializerHelper.KillYouKillMeKillUnityAndCrash_Serializer = function(writer)
end

ClientToAvatarGMDelegate.KillYouKillMeKillUnityAndCrash = function(self)
	return self.Invoke(self, 155004032, SerializerHelper.KillYouKillMeKillUnityAndCrash_Serializer)
end

SerializerHelper.SyncQueryGameObjectFilter_Serializer = function(writer, id, list)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, list, SerializeBase.WriteComplexWrap(SerializeAuto.WriteQueryGameObjectFilter, "QueryGameObjectFilter", false), nil, "list", false, 0, nil)
end

ClientToAvatarGMDelegate.SyncQueryGameObjectFilter = function(self, id, list)
	return self.Invoke(self, 155057386, SerializerHelper.SyncQueryGameObjectFilter_Serializer, id, list)
end

SerializerHelper.SyncSetObjectValue_Serializer = function(writer, id, exception)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	writer.WriteString(writer, exception, true, "SyncSetObjectValue.exception", 0)
end

ClientToAvatarGMDelegate.SyncSetObjectValue = function(self, id, exception)
	return self.Invoke(self, 155068010, SerializerHelper.SyncSetObjectValue_Serializer, id, exception)
end

SerializerHelper.UploadClientCommands_Serializer = function(writer, commands, token)
	SerializeBase.WriteList7Bit(writer, commands, SerializeBase.WriteComplexWrap(SerializeAuto.WriteClientCommandData, "ClientCommandData", false), nil, "commands", false, 0, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

ClientToAvatarGMDelegate.UploadClientCommands = function(self, commands, token)
	return self.Invoke(self, 155125664, SerializerHelper.UploadClientCommands_Serializer, commands, token)
end

SerializerHelper.SyncReportFileSystemDownload_Serializer = function(writer, file, token, error)
	SerializeBase.WriteList7Bit(writer, file, writer.WriteByte, 0, "file", true, 0, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
	writer.WriteString(writer, error, true, "SyncReportFileSystemDownload.error", 0)
end

ClientToAvatarGMDelegate.SyncReportFileSystemDownload = function(self, file, token, error)
	return self.Invoke(self, 155131536, SerializerHelper.SyncReportFileSystemDownload_Serializer, file, token, error)
end

SerializerHelper.QueryClientCommands_Serializer = function(writer)
end

ClientToAvatarGMDelegate.QueryClientCommands = function(self)
	return self.Invoke(self, 155150905, SerializerHelper.QueryClientCommands_Serializer)
end

SerializerHelper.SyncReportFileSystemPath_Serializer = function(writer, rst, token)
	SerializeBase.WriteList7Bit(writer, rst, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDebugFileDescription, "DebugFileDescription", false), nil, "rst", false, 0, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

ClientToAvatarGMDelegate.SyncReportFileSystemPath = function(self, rst, token)
	return self.Invoke(self, 155181732, SerializerHelper.SyncReportFileSystemPath_Serializer, rst, token)
end

SerializerHelper.SyncEcsEntities_Serializer = function(writer, id, entities)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, entities, SerializeBase.WriteComplexWrap(SerializeAuto.WriteEcsEntityInfo, "EcsEntityInfo", false), nil, "entities", false, 0, nil)
end

ClientToAvatarGMDelegate.SyncEcsEntities = function(self, id, entities)
	return self.Invoke(self, 155229926, SerializerHelper.SyncEcsEntities_Serializer, id, entities)
end

SerializerHelper.SyncReportUploadClientFile_Serializer = function(writer, id, message)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	writer.WriteString(writer, message, false, "SyncReportUploadClientFile.message", 0)
end

ClientToAvatarGMDelegate.SyncReportUploadClientFile = function(self, id, message)
	return self.Invoke(self, 155299567, SerializerHelper.SyncReportUploadClientFile_Serializer, id, message)
end

SerializerHelper.SyncQueryObjectRoot_Serializer = function(writer, id, info)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteGmQueryObjectRoot, "info", false)
end

ClientToAvatarGMDelegate.SyncQueryObjectRoot = function(self, id, info)
	return self.Invoke(self, 155340746, SerializerHelper.SyncQueryObjectRoot_Serializer, id, info)
end

SerializerHelper.SyncEcsArchetypes_Serializer = function(writer, id, archetypes)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, archetypes, SerializeBase.WriteComplexWrap(SerializeAuto.WriteEcsArchetypeInfo, "EcsArchetypeInfo", false), nil, "archetypes", false, 0, nil)
end

ClientToAvatarGMDelegate.SyncEcsArchetypes = function(self, id, archetypes)
	return self.Invoke(self, 155369075, SerializerHelper.SyncEcsArchetypes_Serializer, id, archetypes)
end

SerializerHelper.SyncReportDeleteClientFile_Serializer = function(writer, id, message)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	writer.WriteString(writer, message, false, "SyncReportDeleteClientFile.message", 0)
end

ClientToAvatarGMDelegate.SyncReportDeleteClientFile = function(self, id, message)
	return self.Invoke(self, 155384702, SerializerHelper.SyncReportDeleteClientFile_Serializer, id, message)
end

SerializerHelper.SyncEcsEntityDetail_Serializer = function(writer, id, detail)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, detail, SerializeAuto.WriteEcsEntityDetail, "detail", false)
end

ClientToAvatarGMDelegate.SyncEcsEntityDetail = function(self, id, detail)
	return self.Invoke(self, 155480268, SerializerHelper.SyncEcsEntityDetail_Serializer, id, detail)
end

SerializerHelper.HotPatchTestGm_Serializer = function(writer, para)
	SerializeBase.WritePrimitive(writer, para, writer.WriteInt32, 0)
end

ClientToAvatarGMDelegate.HotPatchTestGm = function(self, para)
	return self.Invoke(self, 155543785, SerializerHelper.HotPatchTestGm_Serializer, para)
end

SerializerHelper.CaptureClient_Serializer = function(writer)
end

ClientToAvatarGMDelegate.CaptureClient = function(self)
	return self.Invoke(self, 155598879, SerializerHelper.CaptureClient_Serializer)
end

SerializerHelper.SyncEcsComponentFields_Serializer = function(writer, id, fields)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, fields, SerializeBase.WriteComplexWrap(SerializeAuto.WriteQueryFieldInfo, "QueryFieldInfo", false), nil, "fields", false, 0, nil)
end

ClientToAvatarGMDelegate.SyncEcsComponentFields = function(self, id, fields)
	return self.Invoke(self, 155610264, SerializerHelper.SyncEcsComponentFields_Serializer, id, fields)
end

SerializerHelper.SyncQueryObjectFields_Serializer = function(writer, id, fields)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, fields, SerializeBase.WriteComplexWrap(SerializeAuto.WriteQueryFieldInfo, "QueryFieldInfo", false), nil, "fields", false, 0, nil)
end

ClientToAvatarGMDelegate.SyncQueryObjectFields = function(self, id, fields)
	return self.Invoke(self, 155622056, SerializerHelper.SyncQueryObjectFields_Serializer, id, fields)
end

SerializerHelper.SyncEcsWorlds_Serializer = function(writer, id, worlds)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, worlds, SerializeBase.WriteComplexWrap(SerializeAuto.WriteEcsWorldInfo, "EcsWorldInfo", false), nil, "worlds", false, 0, nil)
end

ClientToAvatarGMDelegate.SyncEcsWorlds = function(self, id, worlds)
	return self.Invoke(self, 155682440, SerializerHelper.SyncEcsWorlds_Serializer, id, worlds)
end

SerializerHelper.UploadCapture_Serializer = function(writer, data, token)
	SerializeBase.WriteBuffer7Bit(writer, data, "data", false, 0, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

ClientToAvatarGMDelegate.UploadCapture = function(self, data, token)
	return self.Invoke(self, 155707774, SerializerHelper.UploadCapture_Serializer, data, token)
end

SerializerHelper.AskIsTestCasePatchApply_Serializer = function(writer, patchtype)
	writer.WriteString(writer, patchtype, false, "AskIsTestCasePatchApply.patchType", 0)
end

ClientToAvatarGMDelegate.AskIsTestCasePatchApply = function(self, patchtype)
	return self.Invoke(self, 155743750, SerializerHelper.AskIsTestCasePatchApply_Serializer, patchtype)
end

SerializerHelper.SyncQueryScene_Serializer = function(writer, id, scene)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, scene, SerializeAuto.WriteGmQuerySceneInfo, "scene", false)
end

ClientToAvatarGMDelegate.SyncQueryScene = function(self, id, scene)
	return self.Invoke(self, 155758336, SerializerHelper.SyncQueryScene_Serializer, id, scene)
end

SerializerHelper.SyncAllQueryScene_Serializer = function(writer, id, scene)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, scene, SerializeBase.WriteComplexWrap(SerializeAuto.WriteGmQuerySceneInfo, "GmQuerySceneInfo", false), nil, "scene", false, 0, nil)
end

ClientToAvatarGMDelegate.SyncAllQueryScene = function(self, id, scene)
	return self.Invoke(self, 155781463, SerializerHelper.SyncAllQueryScene_Serializer, id, scene)
end

SerializerHelper.GmTestBanUser_Serializer = function(writer, reason)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteUInt32, 0)
end

ClientToAvatarGMDelegate.GmTestBanUser = function(self, reason)
	return self.Invoke(self, 155799366, SerializerHelper.GmTestBanUser_Serializer, reason)
end

SerializerHelper.UploadLogs_Serializer = function(writer, logs, token)
	SerializeBase.WriteList7Bit(writer, logs, SerializeBase.WriteStringWrap(false, "logs", 0), nil, "logs", false, 0, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

ClientToAvatarGMDelegate.UploadLogs = function(self, logs, token)
	return self.Invoke(self, 155845259, SerializerHelper.UploadLogs_Serializer, logs, token)
end

SerializerHelper.SyncQueryObject_Serializer = function(writer, id, list)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, list, SerializeBase.WriteComplexWrap(SerializeAuto.WriteGmQuerySceneObjectInfo, "GmQuerySceneObjectInfo", false), nil, "list", false, 0, nil)
end

ClientToAvatarGMDelegate.SyncQueryObject = function(self, id, list)
	return self.Invoke(self, 155856270, SerializerHelper.SyncQueryObject_Serializer, id, list)
end

SerializerHelper.SyncReportFileSystemRoot_Serializer = function(writer, rst, token)
	SerializeBase.WriteComplex(writer, rst, SerializeAuto.WriteDebugFileResult, "rst", false)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

ClientToAvatarGMDelegate.SyncReportFileSystemRoot = function(self, rst, token)
	return self.Invoke(self, 155972394, SerializerHelper.SyncReportFileSystemRoot_Serializer, rst, token)
end

SerializerHelper.GmKickMe_Serializer = function(writer)
end

ClientToAvatarGMDelegate.GmKickMe = function(self)
	return self.Invoke(self, 155983816, SerializerHelper.GmKickMe_Serializer)
end

SerializerHelper.SyncSetEcsComponentValue_Serializer = function(writer, id, exception)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	writer.WriteString(writer, exception, true, "SyncSetEcsComponentValue.exception", 0)
end

ClientToAvatarGMDelegate.SyncSetEcsComponentValue = function(self, id, exception)
	return self.Invoke(self, 155987555, SerializerHelper.SyncSetEcsComponentValue_Serializer, id, exception)
end

return ClientToAvatarGMDelegate
