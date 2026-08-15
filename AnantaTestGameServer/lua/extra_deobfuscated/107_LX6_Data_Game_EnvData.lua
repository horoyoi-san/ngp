C_EnvData = DefClass("C_EnvData", C_EnvData, C_BaseData)
local EnvData = C_EnvData

function EnvData:DefineData()
	self.useBundle = false
	self.isEditor = false
	self.IsENABLE_PROFILER = false
	self.IsDebug = false
end

function EnvData:DefineEvents()
	self.EventHandler = {}
end

function EnvData:OnInit()
	self.useBundle = LX6.Engine.ResourceManager.Instance.UseBundle
	self.isEditor = gCS.LuaUtils.IsOnEditor
	self.IsENABLE_PROFILER = gCS.LuaUtils.IsENABLE_PROFILER
	self.IsDebug = gCS.LuaUtils.IsDebug
end

function EnvData:OnDispose()
	return
end
