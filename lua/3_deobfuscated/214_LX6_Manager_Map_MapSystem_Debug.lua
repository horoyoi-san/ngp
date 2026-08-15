local MapDebugMgr = LX6.Gps.MapDebugMgr
gMapSystem = gMapSystem or {}
local M = gMapSystem
EMapSystemDebugKey = {
	PrintScaleInfo = 1,
	CommonUnitIgnoreMask = 2,
	IgnoreCollectionTaskAvailableCheck = 11,
	PoiIILodMax2 = 7,
	EnableSubSystemDebug = 10,
	BigMapUseAllView = 4,
	PerformanceTest = 17,
	ShowAllMapArea = 5,
	EnableAssert = 16,
	AlwaysUseVehicleNav = 19,
	ShowDebugInfo = 6,
	IgnoreScaleClamp = 3,
	UseNewMiniMapComp = 20,
	BigMapUseRangeEventView = 12,
	FogMap = 18,
	MiniMapAlwaysRotate = 8
}
EMapSystemDebugType = {
	Switch = 1,
	Input = 3,
	Slider = 2,
	Action = 4
}
M.DebugEntries = {
	[EMapSystemDebugKey.PrintScaleInfo] = {
		desc = "打印缩放信息",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.CommonUnitIgnoreMask] = {
		desc = "通用单位忽略遮罩",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.IgnoreScaleClamp] = {
		desc = "忽略缩放倍率限制",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.BigMapUseAllView] = {
		desc = "大地图使用所有View",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.ShowAllMapArea] = {
		desc = "显示所有地图区域",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.ShowDebugInfo] = {
		desc = "显示调试信息",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.PoiIILodMax2] = {
		desc = "poi II lod 最大为2",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.MiniMapAlwaysRotate] = {
		desc = "小地图以摄像机方向作为上方向",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.EnableSubSystemDebug] = {
		desc = "启用_Debug子系统",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.IgnoreCollectionTaskAvailableCheck] = {
		desc = "是否忽略Collection任务可接检查",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.BigMapUseRangeEventView] = {
		desc = "大地图使用随机事件View",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.EnableAssert] = {
		value = true,
		desc = "启用程序本地Assert",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.PerformanceTest] = {
		value = true,
		desc = "性能优化测试",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.FogMap] = {
		value = true,
		desc = "开启FogMap",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.AlwaysUseVehicleNav] = {
		value = false,
		desc = "是否始终使用车辆导航",
		debugType = EMapSystemDebugType.Switch
	},
	[EMapSystemDebugKey.UseNewMiniMapComp] = {
		value = false,
		desc = "是否使用新的小地图组件",
		debugType = EMapSystemDebugType.Switch
	}
}
M.testFlagGroup = {
	sw = {
		"IgnoreScaleClamp",
		"BigMapUseAllView",
		"ShowAllMapArea",
		"ShowDebugInfo"
	},
	sw1202 = {
		"MiniMapAlwaysRotate",
		"CommonUnitIgnoreMask"
	},
	viewRangeEvent = {
		"BigMapUseRangeEventView",
		"ShowDebugInfo"
	}
}

function M:InitDebug()
	MapDebugMgr.InitFromLua()

	for switchKey, entry in pairs(self.DebugEntries) do
		for key, value in pairs(EMapSystemDebugKey) do
			if value == switchKey then
				entry.keyName = key

				break
			end
		end

		if entry.debugType == EMapSystemDebugType.Switch then
			local value = not not entry.value
			entry.value = value

			MapDebugMgr.SyncSwitchFromLua(entry.keyName, entry.desc, value)
		end
	end
end

function M:CheckDebugSwitch(switchKey)
	local entry = self.DebugEntries[switchKey]

	if not entry or entry.debugType ~= EMapSystemDebugType.Switch then
		return false
	end

	return entry.value == true
end

function M:GmSetDebugSwitch(debugKey, value)
	value = not not value
	local entry = self.DebugEntries[debugKey]

	if not entry or entry.debugType ~= EMapSystemDebugType.Switch then
		return
	end

	if entry.value == value then
		return
	end

	entry.value = value

	MapDebugMgr.SyncSwitchFromLua(entry.keyName, entry.desc, value)
end

function M:GmSetDebugFloat(debugKey, value)
	return
end

function M:GmSwitchFlag(flagName, value)
	print_debug("[MapSystem] GmSwitchFlag", flagName, value)
	self:GmSetDebugSwitch(EMapSystemDebugKey[flagName], value)
end

function M:GmSwitchFlagGroup(groupName, value)
	local group = self.testFlagGroup[groupName]

	for _, flagName in ipairs(group) do
		self:GmSwitchFlag(flagName, value)
	end
end

function M:GmSetIsPV(isPV)
	self.isPV = isPV

	gMessageManager:SendMessage(gEventConstants.MAP_IS_PV_FLAG_CHANGE, isPV)
end

function M:BlockPerformanceTest()
	local randTable = {}
	local randVecTable = {}

	for i = 1, 10000 do
		randTable[2 * i - 1] = math.random(0, 4000)
		randTable[2 * i] = math.random(0, 4000)
		randVecTable[i] = Vector3.New(randTable[2 * i - 1], 0, randTable[2 * i])
	end

	local startTime2 = os.clock()

	for i = 1, 10000 do
	end

	local endTime2 = os.clock()

	print_error("Performance Test (Sample 10000), New Block Test: " .. endTime2 - startTime2)
end

function M:GmSetCommonUnitTickInterval(interval)
	if not interval or interval < 0 then
		print_error("Invalid CommonUnitTickInterval: " .. tostring(interval))

		return
	end

	for _, tickEntry in ipairs(self.tickEntries) do
		if tickEntry.systemType == EMapSubSystemType.CommonUnit then
			tickEntry.interval = interval

			break
		end
	end

	print_debug("Set CommonUnit Tick Interval: " .. interval)
end

function M:LuaTableBenchmark(count)
	local testArr = {}
	local startTime3 = os.clock()

	for i = 1, count do
		testArr[i] = i
	end

	local endTime3 = os.clock()
	local csharpBenchmarkResult = LX6.Gps.MapSystem.LuaTableBenchmark(count)

	print_error("Performance Test(Sample Count: " .. count .. "):\n" .. "SetArray In Lua: " .. (1000 * (endTime3 - startTime3) .. "\n") .. "CSharp Benchmark: \n" .. (csharpBenchmarkResult or "Error\n"))
end

function M:CsGetMapViews()
	return self.container.views
end

function M:CsGetElementName(id)
	local element = self.container:GetByGpsId(id)

	if not element then
		return ""
	end

	return element:GetName() or ""
end
