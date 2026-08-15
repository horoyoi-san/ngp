local DeviceQualityLevelData = require("LuaGen/QualityData/device_quality_level_data")
local ProfileManager = LX6.Engine.ProfileManager
local devProfile = ProfileManager.devProfile
local GameQualitySettings = LX6.Manager.GameQualitySettings
local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local DeviceDisplayLevel = LX6.Quality.DeviceDisplayLevel
local module = {}

function module.CheckDevice(deviceName, deviceModel, graphicDeviceName, deviceType, memory, processorCount, processorFrequency, graphicsQuality, cpu_name, drivenName)
	local deviceQuality = LX6.Quality.MobileDeviceQuality.Middle
	local displayLevel = DeviceDisplayLevel.High
	local deviceMemoryQuality = LX6.Quality.MobileDeviceMemoryQuality.Middle

	if not gCS.LuaUtils.IsNonMobileAdaptive() or gQualityManager:GetQualityPlatform() then
		if gCS.LuaUtils.IsOnAndroid or gQualityManager:IsInEditorAndroidPlatform() then
			deviceMemoryQuality = module.GetAndroidDeviceMemoryQuality(memory)
			displayLevel = module.GetAndroidDeviceQuality(deviceName, deviceModel, graphicDeviceName, processorCount, processorFrequency, deviceMemoryQuality)
		elseif gCS.LuaUtils.IsOnIOS or gQualityManager:IsInEditorIOSPlatform() then
			deviceMemoryQuality = module.GetIOSDeviceMemoryQuality(memory, deviceQuality)
			displayLevel = module.GetIosDeviceQuality(deviceModel, graphicDeviceName, deviceType)
		else
			deviceMemoryQuality = LX6.Quality.MobileDeviceMemoryQuality.High
		end

		deviceQuality = LX6.Quality.MobileDeviceQuality.Middle
	elseif gCS.LuaUtils.IsOnPS5 or gQualityManager:IsInEditorPSPlatform() then
		deviceQuality = LX6.Quality.MobileDeviceQuality.PS
		deviceMemoryQuality = LX6.Quality.MobileDeviceMemoryQuality.PC
	elseif gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() or gCS.LuaUtils.IsOnEditor or gQualityManager:IsInEditorPCPlatform() then
		deviceMemoryQuality = module.GetPCDeviceMemoryQuality(memory)
		deviceQuality = LX6.Quality.MobileDeviceQuality.PC
	end

	if devProfile.MyDeviceQuality > 0 then
		deviceQuality = devProfile.MyDeviceQuality

		ProfileManager.SaveDevProperty()
	end

	gQualityManager.DeviceQuality = deviceQuality

	if ProfileManager.gameProfile.miniMemory then
		gQualityManager.DeviceMemoryLevel = LX6.Quality.MobileDeviceMemoryQuality.Low
	else
		gQualityManager.DeviceMemoryLevel = deviceMemoryQuality
	end

	gQualityManager.RealDeviceMemoryLevel = deviceMemoryQuality
	gQualityManager.DeviceGraphicsQuality = graphicsQuality
	gQualityManager.DefaultQuality = displayLevel
	GameQualitySettings.Instance.DeviceQuality = gQualityManager.DeviceQuality
	GameQualitySettings.Instance.DeviceMemoryQuality = gQualityManager.DeviceMemoryLevel
	GameQualitySettings.Instance.DefaultQuality = gQualityManager.DefaultQuality

	print_notice("deviceQuality = " .. deviceQuality .. ", deviceMemoryLevel = " .. deviceMemoryQuality)
	gQualityManager:LoginReportLog(deviceName, deviceModel, graphicDeviceName, deviceType, memory, processorCount, processorFrequency, graphicsQuality, cpu_name, deviceQuality, drivenName)
end

function module.GetIOSDeviceMemoryQuality(memory, deviceQuality)
	if memory < 0 then
		if deviceQuality == LX6.Quality.MobileDeviceQuality.Low then
			return LX6.Quality.MobileDeviceMemoryQuality.Low
		elseif deviceQuality == LX6.Quality.MobileDeviceQuality.Middle then
			return LX6.Quality.MobileDeviceMemoryQuality.Middle
		elseif deviceQuality == LX6.Quality.MobileDeviceQuality.High then
			return LX6.Quality.MobileDeviceMemoryQuality.High
		elseif deviceQuality == LX6.Quality.MobileDeviceQuality.Ultra then
			return LX6.Quality.MobileDeviceMemoryQuality.Ultra
		end
	end

	if memory < 2500 then
		return LX6.Quality.MobileDeviceMemoryQuality.Low
	end

	if memory < 3500 then
		return LX6.Quality.MobileDeviceMemoryQuality.Middle
	end

	if memory < 4500 then
		return LX6.Quality.MobileDeviceMemoryQuality.High
	end

	return LX6.Quality.MobileDeviceMemoryQuality.Ultra
end

function module.GetIosDeviceQuality(deviceModel, graphicDeviceName, deviceType)
	local deviceQuality = LX6.Quality.MobileDeviceQuality.High
	local hasCurrentPhoneType = false

	for i = 1, #DeviceQualityLevelData.IOS do
		local item = DeviceQualityLevelData.IOS[i]

		if string.contains(item[2], deviceModel) then
			hasCurrentPhoneType = true

			if item[4] and item[4] > 0 then
				gCS.LuaUtils.SetDeviceDpi(item[4])
			end

			if string.contains(item[1], "ipad") then
				gCS.LuaUtils.SetIsPad(true)
			end

			deviceQuality = item[3]

			print_notice("deviceModel = " .. deviceModel .. " , deviceQuality = " .. deviceQuality .. " , graphicDeviceName = " .. graphicDeviceName)

			break
		end
	end

	if not hasCurrentPhoneType then
		if gCS.LuaUtils.IsOnEditor then
			deviceQuality = DeviceDisplayLevel.Movie
		else
			print_error("没有找到对应的iOS机型配置，使用默认配置，请在配表补齐配置 , graphicDeviceName = " .. graphicDeviceName)

			deviceQuality = module.SetIOSLevelByGraphicsDeivceName(graphicDeviceName, deviceType)
		end
	end

	return deviceQuality
end

function module.SetIOSLevelByGraphicsDeivceName(graphicDeviceName, deviceType)
	if string.contains(graphicDeviceName, "Apple") then
		if deviceType <= 11 then
			return DeviceDisplayLevel.Middle
		end

		if deviceType <= 13 then
			return DeviceDisplayLevel.High
		end

		if deviceType <= 15 then
			return DeviceDisplayLevel.Ultra
		end

		if deviceType >= 16 then
			gCS.LuaUtils.SetDeviceDpi(460)

			return DeviceDisplayLevel.Movie
		end
	end

	return DeviceDisplayLevel.Middle
end

function module.GetAndroidDeviceQuality(deviceName, deviceModel, graphicDeviceName, processorCount, processorFrequency, deviceMemoryQuality)
	local androidMatchInfo = {}

	for _, info in pairs(DeviceQualityLevelData.Android) do
		table.insert(androidMatchInfo, info)
	end

	table.sort(androidMatchInfo, function (matchInfoA, matchInfoB)
		return matchInfoB.displayLevel < matchInfoA.displayLevel
	end)

	for _, info in pairs(androidMatchInfo) do
		for _, subName in pairs(info.deviceName) do
			if string.find(deviceName, subName) or string.find(deviceModel, subName) then
				return info.displayLevel
			end
		end
	end

	for _, info in pairs(androidMatchInfo) do
		local qualityByGpu = module.GetAndroidDeviceQualityByGPU(info, graphicDeviceName)

		if qualityByGpu then
			return qualityByGpu
		end
	end

	local processorPower = processorFrequency * (processorCount + 8) / 16
	local deviceLevel = DeviceDisplayLevel.Original

	if DeviceQualityLevelData.CPUPowerLine.ultraHighLine < processorPower then
		deviceLevel = DeviceDisplayLevel.Original
	elseif DeviceQualityLevelData.CPUPowerLine.highMiddleLine < processorPower then
		deviceLevel = DeviceDisplayLevel.Movie
	elseif DeviceQualityLevelData.CPUPowerLine.MiddleLowLine < processorPower then
		deviceLevel = DeviceDisplayLevel.Ultra
	else
		deviceLevel = DeviceDisplayLevel.High
	end

	if deviceMemoryQuality == LX6.Quality.MobileDeviceMemoryQuality.Low then
		deviceLevel = DeviceDisplayLevel.Middle
	elseif deviceMemoryQuality == LX6.Quality.MobileDeviceMemoryQuality.Middle then
		deviceLevel = DeviceDisplayLevel.High
	end

	return deviceLevel
end

function module.GetAndroidDeviceQualityByGPU(info, gpuName)
	for i, gpuPrefix in pairs(info.gpuPrefix) do
		local itemGPUTypeName = DeviceQualityLevelData.GPUName[tostring(gpuPrefix)]
		local itemGPUName = info.gpuDeviceName[i]

		if string.find(itemGPUTypeName, "Adreno") then
			itemGPUTypeName = "Adreno"
		end

		if string.find(gpuName, itemGPUTypeName) and string.find(gpuName, itemGPUName) then
			return info.displayLevel
		end

		if string.find(gpuName, "Adreno") then
			local deviceId = module.GetAdrenoId(gpuName)
			local betweenIndex = string.find(itemGPUName, "~")

			if betweenIndex then
				local startVersion = tonumber(string.sub(itemGPUName, 1, betweenIndex - 1))
				local lastVersion = tonumber(string.sub(itemGPUName, betweenIndex + 1, -1))

				if startVersion <= deviceId and deviceId <= lastVersion then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, "<=") then
				local baseVersion = tonumber(string.sub(itemGPUName, 3))

				if deviceId <= baseVersion then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, "<") then
				local baseVersion = tonumber(string.sub(itemGPUName, 2))

				if deviceId < baseVersion then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, ">=") then
				local baseVersion = tonumber(string.sub(itemGPUName, 3))

				if baseVersion <= deviceId then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, ">") then
				local baseVersion = tonumber(string.sub(itemGPUName, 2))

				if baseVersion < deviceId then
					return info.displayLevel
				end
			end
		end
	end
end

function module.GetAdrenoId(gpuName)
	local reverseGpuName = string.reverse(gpuName)
	local index = string.find(reverseGpuName, " ")
	local reverseAdrenoId = string.sub(reverseGpuName, 1, index - 1)
	local deviceIdStr = string.reverse(reverseAdrenoId)
	local deviceIdNum = tonumber(deviceIdStr)

	if deviceIdNum ~= nil then
		return deviceIdNum
	end

	deviceIdNum = 0

	for matchStr in string.gmatch(deviceIdStr, "(%d+)") do
		deviceIdNum = tonumber(matchStr)

		break
	end

	if deviceIdNum ~= nil then
		return deviceIdNum
	else
		return 0
	end
end

function module.GetAndroidDeviceMemoryQuality(memory)
	if memory < 2500 then
		return LX6.Quality.MobileDeviceMemoryQuality.Low
	elseif memory < 4500 then
		return LX6.Quality.MobileDeviceMemoryQuality.Middle
	elseif memory < 6500 then
		return LX6.Quality.MobileDeviceMemoryQuality.High
	end

	return LX6.Quality.MobileDeviceMemoryQuality.Ultra
end

function module.CheckDeviceByScore(gpuScore, cpuScore, memory, vdramSize)
	if gpuScore > 0 and cpuScore > 0 then
		module._CheckDeviceByScore(gpuScore, cpuScore, memory, vdramSize)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gQualityManager.DefaultQuality = math.max(gQualityManager.DefaultQuality, DeviceDisplayLevel.Ultra)
	else
		gQualityManager.DefaultQuality = math.max(gQualityManager.DefaultQuality, DeviceDisplayLevel.Movie)
	end

	if devProfile.CurrentSettingVersion ~= gQualityManager.defaultSettingVersion then
		print_notice("[档位分数] 更新了缓存版本，已重置本地缓存 , DefaultQuality = " .. gQualityManager.DefaultQuality)

		ProfileManager.gameProfile.displayLevel = gQualityManager.DefaultQuality
		devProfile.CurrentSettingVersion = gQualityManager.defaultSettingVersion
		gQualityManager.hasChangeVersion = true
	end

	gQualityManager:LoadQualityData(gQualityManager.DeviceQuality, ProfileManager.gameProfile.displayLevel)
	gStoreManager:SetCommonDebugInfo("gpuScore/cpuScore", gpuScore .. "/" .. cpuScore)
	gStoreManager:SetCommonDebugInfo("memory/vDram", memory .. "/" .. vdramSize)
end

function module._CheckDeviceByScore(gpuScore, cpuScore, memory, vdramSize)
	if gCS.LuaUtils.IsOnAndroid or gQualityManager:IsInEditorAndroidPlatform() or gCS.LuaUtils.IsOnIOS or gQualityManager:IsInEditorIOSPlatform() then
		return
	end

	if gpuScore <= 0 or cpuScore <= 0 then
		LX6.Utils.LogUtilsLua.SendToPopo("[档位分数] 分数检查未通过  gpuScore = " .. gpuScore .. ", cpuScore = " .. cpuScore, "leilei03")

		return
	end

	if gpuScore < ShezhiPanelConfig.BanDevicePartScore.gpuScore or cpuScore < ShezhiPanelConfig.BanDevicePartScore.cpuScore then
		LX6.Utils.LogUtilsLua.SendToPopo("[档位分数] 设备分数检查未通过,gpuScore = " .. gpuScore .. " cpuScore =" .. cpuScore, "leilei03")

		return
	end

	gQualityManager.CanEnterGame = true

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() or gCS.LuaUtils.IsOnEditor or gQualityManager:IsInEditorPCPlatform() then
		local displayLevl = module.GetPcDisplayLevelByScore(gpuScore, cpuScore, memory, vdramSize)

		print_notice("[档位分数] 根据档位分数得到的显示档位 = " .. displayLevl)
		gQualityManager:SetReportQualitList({
			"gpuScore",
			"cpuScore"
		}, {
			gpuScore,
			cpuScore
		})

		gQualityManager.DefaultQuality = displayLevl
		GameQualitySettings.Instance.DefaultQuality = displayLevl
	end
end

function module.CheckDeviceCanEnterGame(gpuName, cpuName)
	if gCS.LuaUtils.IsOnlyPCPlatform() or ShezhiPanelConfig.IsIgnorePlatformCheck and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() or ShezhiPanelConfig.IsOpenDeviceCheck then
		if devProfile.IsBanDeviceCheck then
			return true
		end

		if ShezhiPanelConfig.IsOpenDeviceCheck then
			if string.find(string.lower(gpuName), string.lower("NVIDIA GeForce")) then
				local gpuGen = module.GetNVIDIAGen(gpuName)

				if gpuGen < 100 then
					LX6.Utils.LogUtilsLua.SendToPopo("[档位分数] 当前GPU数据获取错误,gpuName = " .. gpuName .. " gpuGen =" .. gpuGen, "leilei03")

					return true
				end

				local whiteList = ShezhiPanelConfig.WhiteDeviceListGpu

				if gpuGen < ShezhiPanelConfig.BanDevice.nviGpuNum and not table.contains(whiteList, gpuGen) then
					return false
				end
			end

			if string.find(string.lower(cpuName), string.lower("Core")) and string.find(string.lower(cpuName), string.lower("Intel")) then
				local cpuGen = module.GetIntelGen(cpuName)

				if cpuGen < 1000 then
					LX6.Utils.LogUtilsLua.SendToPopo("[档位分数] 当前CPU数据获取错误,cpuName = " .. cpuName .. " cpuGen =" .. cpuGen, "leilei03")

					return true
				end

				local whiteList = ShezhiPanelConfig.WhiteDeviceListCpu

				if cpuGen < ShezhiPanelConfig.BanDevice.coreCpuNum and not table.contains(whiteList, cpuGen) then
					return false
				end
			end
		end
	end

	return true
end

function module.GetPCDeviceMemoryQuality(memory)
	return LX6.Quality.MobileDeviceMemoryQuality.PC
end

function module.GetPcDisplayLevelByScore(gpuScore, cpuScore, memory, vdramSize)
	local scoreConfigs = {
		{
			dataKey = "PCCpuScores",
			scoreValue = cpuScore
		},
		{
			dataKey = "PCGpuScores",
			scoreValue = gpuScore
		},
		{
			dataKey = "PCMemoryScores",
			scoreValue = memory
		},
		{
			dataKey = "PCVramScores",
			scoreValue = vdramSize
		}
	}
	local minDisplayLevels = {}
	local hasValidScore = false

	for _, config in ipairs(scoreConfigs) do
		local scoreData = DeviceQualityLevelData[config.dataKey]

		if not table.isNilOrEmpty(scoreData) then
			local displayLevel = 1

			for _, info in pairs(scoreData) do
				if info.score <= config.scoreValue then
					displayLevel = math.max(displayLevel, info.displayLevel)
					hasValidScore = true
				end
			end

			table.insert(minDisplayLevels, displayLevel)
		end
	end

	if not hasValidScore or #minDisplayLevels == 0 then
		return 1
	end

	local displayLevel = math.huge

	for _, level in ipairs(minDisplayLevels) do
		displayLevel = math.min(displayLevel, level)
	end

	return displayLevel
end

function module.GetPCDeviceQuality(graphicDeviceName, cpu_name)
	return LX6.Quality.MobileDeviceQuality.PC
end

function module.GetPCDeviceQualityByGPU(info, gpuName)
	for i, gpuPrefix in pairs(info.gpuPrefix) do
		local itemGPUTypeName = DeviceQualityLevelData.PCGPUName[tostring(gpuPrefix)]
		local itemGPUName = info.gpuDeviceName[i]

		if string.find(gpuName, itemGPUTypeName) and string.find(string.lower(gpuName), string.lower("NVIDIA GeForce")) then
			if string.find(gpuName, itemGPUName) then
				return info.displayLevel
			end

			local gen = module.GetNVIDIAGen(gpuName)
			local betweenIndex = string.find(itemGPUName, "~")

			if betweenIndex then
				local startGen = tonumber(string.sub(itemGPUName, 1, betweenIndex - 1))
				local lastGen = tonumber(string.sub(itemGPUName, betweenIndex + 1, -1))

				if startGen < gen and gen <= lastGen then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, "<=") then
				local baseGen = tonumber(string.sub(itemGPUName, 3))

				if gen <= baseGen then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, "<") then
				local baseGen = tonumber(string.sub(itemGPUName, 2))

				if gen < baseGen then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, ">=") then
				local baseGen = tonumber(string.sub(itemGPUName, 3))

				if baseGen <= gen then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, ">") then
				local baseGen = tonumber(string.sub(itemGPUName, 2))

				if baseGen < gen then
					return info.displayLevel
				end
			end
		end
	end
end

function module.GetNVIDIAGen(gpuName)
	local numList = {}
	local isContinuous = false
	local hasReadNum = false

	for i = 1, #gpuName do
		local charByte = string.byte(string.sub(gpuName, i, i))

		if charByte >= 48 and charByte <= 57 then
			hasReadNum = true
			isContinuous = true

			table.insert(numList, charByte - 48)
		else
			isContinuous = false
		end

		if hasReadNum and not isContinuous then
			break
		end
	end

	local num = 0

	for i = 1, #numList do
		num = num + numList[i] * 10^(#numList - i)
	end

	return num
end

function module.GetIntelGen(cpuName)
	local pattern = "i%d-%d+"
	local cpuGeneration = string.match(cpuName, pattern)

	if cpuGeneration then
		local pareStr = string.match(cpuGeneration, "-%d+")

		if pareStr then
			local num = string.match(pareStr, "%d+")

			return tonumber(num)
		end
	end

	local strs = string.split(cpuName, "-")
	local number = string.match(strs[#strs], "%d+") or "0"

	return tonumber(number)
end

return module
