-- Original chunk: @Lua\LuaFiles\LX6\Data\Game\EnvData.lua
-- Decompiled from: 00109_EnvData.lua_d1e6862c6b09.luajit

C_EnvData = DefClass("C_EnvData", C_EnvData, C_BaseData)
local EnvData = C_EnvData

EnvData.DefineData = function(self)
	self.useBundle = false
	self.isEditor = false
	self.IsENABLE_PROFILER = false
	self.IsDebug = false
end

EnvData.DefineEvents = function(self)
	self.EventHandler = {}
end

EnvData.OnInit = function(self)
	self.useBundle = LX6.Engine.ResourceManager.Instance.UseBundle
	self.isEditor = gCS.LuaUtils.IsOnEditor
	self.IsENABLE_PROFILER = gCS.LuaUtils.IsENABLE_PROFILER
	self.IsDebug = gCS.LuaUtils.IsDebug
end

EnvData.OnDispose = function(self)
end
