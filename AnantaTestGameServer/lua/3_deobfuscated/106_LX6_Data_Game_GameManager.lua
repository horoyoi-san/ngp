require("LX6/Data/Game/EnvData")
require("LX6/Data/Game/CacheData")

C_GameManager = DefClass("C_GameManager", C_GameManager, C_BaseDataManager)
local GameManager = C_GameManager
local EnvData = C_EnvData
local CacheData = C_CacheData

function GameManager:DefineData()
	self.Env = EnvData.New(self)
	self.Cache = CacheData.New(self)
end

function GameManager:DefineEvents()
	self.EventHandler = {}
end

function GameManager:OnInit()
	self:Init()
end

function GameManager:LuaProfilerEnableChanged(isEnable)
	if self.Env ~= nil then
		self.Env.IsENABLE_PROFILER = isEnable
	end
end

local profiler = rawget(_G, "MikuLuaProfiler")
local endReturn = rawget(_G, "miku_unpack_return_value")

function GameManager:BeginLuaSample(name)
	if not self.Env or not self.Env.isEditor then
		print_error("在初始化未完成时或非编辑器下禁止调用自定义lua profiler sample!")

		return
	end

	if profiler then
		profiler.LuaProfiler.BeginSampleCustom(name)
	end
end

function GameManager:EndLuaSample()
	if not self.Env or not self.Env.isEditor then
		print_error("在初始化未完成时或非编辑器下禁止调用自定义lua profiler sample!")

		return
	end

	if profiler then
		profiler.LuaProfiler.EndSample()
	end
end

function GameManager:EndLuaSampleReturn(...)
	if not self.Env or not self.Env.isEditor then
		print_error("在初始化未完成时或非编辑器下禁止调用自定义lua profiler sample!")

		return
	end

	if endReturn then
		endReturn(...)
	end
end

gGameManager = gGameManager or GameManager.New()
