-- Original chunk: @Lua\LuaFiles\LX6\Data\Game\GameManager.lua
-- Decompiled from: 00108_GameManager.lua_e98c40c6d034.luajit

require("LX6/Data/Game/EnvData")
require("LX6/Data/Game/CacheData")

C_GameManager = DefClass("C_GameManager", C_GameManager, C_BaseDataManager)
local GameManager = C_GameManager
local EnvData = C_EnvData
local CacheData = C_CacheData

GameManager.DefineData = function(self)
	self.Env = EnvData.New(self)
	self.Cache = CacheData.New(self)
	self.PROFILER_MARKER_FROM_LUA = {}
	self.PROFILER_MARKER_FROM_LUA_IDALLOC = 0
end

GameManager.DefineEvents = function(self)
	self.EventHandler = {}
end

GameManager.OnInit = function(self)
	self:Init()
end

GameManager.LuaProfilerEnableChanged = function(self, isEnable)
	if self.Env == nil then
		self.Env.IsENABLE_PROFILER = isEnable
	end
end

GameManager.BeginSample = function(self, markerName)
	local dict = self.PROFILER_MARKER_FROM_LUA
	local markerId = dict[markerName]

	if markerId then
		gCS.LuaUtils.BeginSample(markerId)
	else
		markerId = self.PROFILER_MARKER_FROM_LUA_IDALLOC + 1
		self.PROFILER_MARKER_FROM_LUA_IDALLOC = markerId
		dict[markerName] = markerId

		gCS.LuaUtils.AddProfileMarkerIdFromLua(markerId, markerName)
		gCS.LuaUtils.BeginSample(markerId)
	end
end

GameManager.EndSample = function(self)
	gCS.LuaUtils.EndSample()
end

local profiler = rawget(_G, "MikuLuaProfiler")
local endReturn = rawget(_G, "miku_unpack_return_value")

GameManager.BeginLuaSample = function(self, name)
	if not self.Env or not self.Env.isEditor then
		print_error("在初始化未完成时或非编辑器下禁止调用自定义lua profiler sample!")

		return
	end

	if profiler then
		profiler.LuaProfiler.BeginSampleCustom(name)
	end
end

GameManager.EndLuaSample = function(self)
	if not self.Env or not self.Env.isEditor then
		print_error("在初始化未完成时或非编辑器下禁止调用自定义lua profiler sample!")

		return
	end

	if profiler then
		profiler.LuaProfiler.EndSample()
	end
end

GameManager.EndLuaSampleReturn = function(self, ...)
	if not self.Env or not self.Env.isEditor then
		print_error("在初始化未完成时或非编辑器下禁止调用自定义lua profiler sample!")

		return
	end

	if endReturn then
		endReturn(...)
	end
end

gGameManager = gGameManager or GameManager.New()
