-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameQuality\QualityUtils.lua
-- Decompiled from: 02364_QualityUtils.lua_0aebb25a16b7.luajit

local DeviceQualityLevelData = require("LuaGen/QualityData/device_quality_level_data")
local ProfileManager = LX6.Engine.ProfileManager
local devProfile = ProfileManager.devProfile
local GameQualitySettings = LX6.Manager.GameQualitySettings
local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local DeviceDisplayLevel = UX.Game.DeviceDisplayLevel
local PlatformSettingQuality = LX6.Quality.PlatformSettingQuality
local module = {
	IsGameCloudPlatform = function ()
		return UniSDKManager == nil and UniSDKManager.isGameCloud ~= true
	end
}

module.IsMobileQualityPlatform = function()
	return not module.IsGameCloudPlatform() and (not gCS.LuaUtils.IsNonMobileAdaptive() or gQualityManager:GetQualityPlatform())
end

module.IsPCQualityPlatform = function()
	return module.IsGameCloudPlatform() or gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() or gCS.LuaUtils.IsOnEditor or gQualityManager:IsInEditorPCPlatform()
end

module.GetEditorOverridePlatform = function()
	if not gCS.LuaUtils.IsOnEditor then
		return nil
	end

	if devProfile.QualityPlatform ~= PlatformSettingQuality.Default then
		return nil
	end

	if devProfile.QualityPlatform == PlatformSettingQuality.Android and devProfile.QualityPlatform == PlatformSettingQuality.IOS and devProfile.QualityPlatform == PlatformSettingQuality.PC and devProfile.QualityPlatform == PlatformSettingQuality.PS and devProfile.QualityPlatform == PlatformSettingQuality.PS5Pro and devProfile.QualityPlatform == PlatformSettingQuality.Cloud then
		return nil
	end

	return devProfile.QualityPlatform
end

module.GetEditorOverrideDeviceQuality = function(editorPlatform, deviceName, deviceModel, graphicDeviceName, deviceType, memory, processorCount, processorFrequency, cpuName, socName)
	if editorPlatform ~= PlatformSettingQuality.IOS then
		local displayLevel = module.GetIosDeviceQuality(deviceModel, graphicDeviceName, deviceType)

		return PlatformSettingQuality.IOS, module.GetIOSDeviceMemoryQuality(memory, displayLevel), displayLevel
	elseif editorPlatform ~= PlatformSettingQuality.Android then
		local deviceMemoryQuality = module.GetAndroidDeviceMemoryQuality(memory)
		local displayLevel = module.GetAndroidDeviceQuality(deviceName, deviceModel, graphicDeviceName, processorCount, processorFrequency, deviceMemoryQuality, socName or cpuName)

		return PlatformSettingQuality.Android, deviceMemoryQuality, displayLevel
	elseif editorPlatform ~= PlatformSettingQuality.PS then
		return PlatformSettingQuality.PS, LX6.Quality.MobileDeviceMemoryQuality.PC, DeviceDisplayLevel.Ultra
	elseif editorPlatform ~= PlatformSettingQuality.PS5Pro then
		return PlatformSettingQuality.PS5Pro, LX6.Quality.MobileDeviceMemoryQuality.PC, DeviceDisplayLevel.Ultra
	elseif editorPlatform ~= PlatformSettingQuality.Cloud then
		return PlatformSettingQuality.Cloud, LX6.Quality.MobileDeviceMemoryQuality.PC, DeviceDisplayLevel.Ultra
	elseif editorPlatform ~= PlatformSettingQuality.PC then
		return PlatformSettingQuality.PC, module.GetPCDeviceMemoryQuality(memory), DeviceDisplayLevel.High
	end

	return nil
end

module.CheckDevice = function(deviceName, deviceModel, graphicDeviceName, deviceType, memory, processorCount, processorFrequency, graphicsQuality, cpu_name, drivenName, socName)
	local platformQuality = PlatformSettingQuality.Default
	local displayLevel = DeviceDisplayLevel.High
	local deviceMemoryQuality = LX6.Quality.MobileDeviceMemoryQuality.Middle
	local editorOverridePlatform = module.GetEditorOverridePlatform()

	if editorOverridePlatform == nil then
		platformQuality, deviceMemoryQuality, displayLevel = module.GetEditorOverrideDeviceQuality(editorOverridePlatform, deviceName, deviceModel, graphicDeviceName, deviceType, memory, processorCount, processorFrequency, cpu_name, socName)

		print_notice("[GameQuality] editor override platformQuality = " .. platformQuality)
	elseif module.IsMobileQualityPlatform() then
		if gCS.LuaUtils.IsOnIOS or gQualityManager:IsInEditorIOSPlatform() then
			displayLevel = module.GetIosDeviceQuality(deviceModel, graphicDeviceName, deviceType)
			deviceMemoryQuality = module.GetIOSDeviceMemoryQuality(memory, displayLevel)
			platformQuality = PlatformSettingQuality.IOS
		elseif gCS.LuaUtils.IsOnAndroid or gQualityManager:IsInEditorAndroidPlatform() then
			deviceMemoryQuality = module.GetAndroidDeviceMemoryQuality(memory)
			displayLevel = module.GetAndroidDeviceQuality(deviceName, deviceModel, graphicDeviceName, processorCount, processorFrequency, deviceMemoryQuality, socName or cpu_name)
			platformQuality = PlatformSettingQuality.Android
		else
			deviceMemoryQuality = LX6.Quality.MobileDeviceMemoryQuality.High
			platformQuality = PlatformSettingQuality.Android
		end
	elseif gCS.LuaUtils.IsOnPS5 or gQualityManager:IsInEditorPSPlatform() then
		if gCS.LuaUtils.IsPS5Pro or gQualityManager:IsInEditorPS5ProPlatform() then
			platformQuality = PlatformSettingQuality.PS5Pro
		else
			platformQuality = PlatformSettingQuality.PS
		end

		deviceMemoryQuality = LX6.Quality.MobileDeviceMemoryQuality.PC
		displayLevel = DeviceDisplayLevel.Ultra
	elseif module.IsGameCloudPlatform() then
		platformQuality = PlatformSettingQuality.Cloud
		deviceMemoryQuality = LX6.Quality.MobileDeviceMemoryQuality.PC
		displayLevel = DeviceDisplayLevel.Ultra
	elseif module.IsPCQualityPlatform() then
		deviceMemoryQuality = module.GetPCDeviceMemoryQuality(memory)
		platformQuality = PlatformSettingQuality.PC

		if module.IsGameCloudPlatform() or gCS.LuaUtils.IsOnEditor and ProfileManager.devProfile.QualityPlatform ~= PlatformSettingQuality.Cloud then
			platformQuality = PlatformSettingQuality.Cloud
		end
	end

	if devProfile.MyDeviceQuality <= 0 then
		platformQuality = devProfile.MyDeviceQuality

		ProfileManager.SaveDevProperty()
	end

	gQualityManager.DeviceQuality = platformQuality

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

	print_notice("platformQuality = " .. platformQuality .. ", deviceMemoryLevel = " .. deviceMemoryQuality)
	gQualityManager:LoginReportLog(deviceName, deviceModel, graphicDeviceName, deviceType, memory, processorCount, processorFrequency, graphicsQuality, cpu_name, platformQuality, drivenName)
end

module.GetIOSDeviceMemoryQuality = function(memory, displayLevel)
	if memory >= 0 then
		if displayLevel < DeviceDisplayLevel.Middle then
			return LX6.Quality.MobileDeviceMemoryQuality.Low
		elseif displayLevel ~= DeviceDisplayLevel.High then
			return LX6.Quality.MobileDeviceMemoryQuality.Middle
		elseif displayLevel ~= DeviceDisplayLevel.Ultra then
			return LX6.Quality.MobileDeviceMemoryQuality.High
		end

		return LX6.Quality.MobileDeviceMemoryQuality.Ultra
	end

	if memory >= 2500 then
		return LX6.Quality.MobileDeviceMemoryQuality.Low
	end

	if memory >= 3500 then
		return LX6.Quality.MobileDeviceMemoryQuality.Middle
	end

	if memory >= 4500 then
		return LX6.Quality.MobileDeviceMemoryQuality.High
	end

	return LX6.Quality.MobileDeviceMemoryQuality.Ultra
end

module.GetIosDeviceQuality = function(deviceModel, graphicDeviceName, deviceType)
	local displayLevel = DeviceDisplayLevel.High
	local hasCurrentPhoneType = false

	for i = 1, #DeviceQualityLevelData.IOS do
		local item = DeviceQualityLevelData.IOS[i]

		if string.contains(item[2], deviceModel) then
			hasCurrentPhoneType = true

			if item[4] and item[4] <= 0 then
				gCS.LuaUtils.SetDeviceDpi(item[4])
			end

			if string.contains(item[1], "ipad") then
				gCS.LuaUtils.SetIsPad(true)
			end

			displayLevel = item[3]

			print_notice("deviceModel = " .. deviceModel .. " , displayLevel = " .. displayLevel .. " , graphicDeviceName = " .. graphicDeviceName)

			break
		end
	end

	if not hasCurrentPhoneType then
		if gCS.LuaUtils.IsOnEditor then
			displayLevel = DeviceDisplayLevel.Movie
		else
			print_warn("没有找到对应的iOS机型配置，使用默认配置，请在配表补齐配置 , graphicDeviceName = " .. graphicDeviceName)

			displayLevel = module.SetIOSLevelByGraphicsDeivceName(graphicDeviceName, deviceType)
		end
	end

	return displayLevel
end

module.SetIOSLevelByGraphicsDeivceName = function(graphicDeviceName, deviceType)
	if string.contains(graphicDeviceName, "Apple") then
		if deviceType < 11 then
			return DeviceDisplayLevel.Middle
		end

		if deviceType < 13 then
			return DeviceDisplayLevel.High
		end

		if deviceType < 15 then
			return DeviceDisplayLevel.Ultra
		end

		if deviceType > 16 then
			gCS.LuaUtils.SetDeviceDpi(460)

			return DeviceDisplayLevel.Movie
		end
	end

	return DeviceDisplayLevel.Middle
end

module.GetAndroidDeviceQuality = function(deviceName, deviceModel, graphicDeviceName, processorCount, processorFrequency, deviceMemoryQuality, socName)
	local androidMatchInfo = {}

	for _, info in pairs(DeviceQualityLevelData.Android) do
		table.insert(androidMatchInfo, info)
	end

	table.sort(androidMatchInfo, function (matchInfoA, matchInfoB)
		return matchInfoB.displayLevel <= matchInfoA.displayLevel
	end)

	for _, info in pairs(androidMatchInfo) do
		for _, subName in pairs(info.deviceName) do
			if string.find(deviceName, subName) or string.find(deviceModel, subName) then
				return info.displayLevel
			end
		end
	end

	for _, info in pairs(androidMatchInfo) do
		local qualityBySoc = module.GetAndroidDeviceQualityBySOC(info, socName)

		if qualityBySoc then
			return qualityBySoc
		end
	end

	for _, info in pairs(androidMatchInfo) do
		local qualityByGpu = module.GetAndroidDeviceQualityByGPU(info, graphicDeviceName)

		if qualityByGpu then
			return qualityByGpu
		end
	end

	return DeviceDisplayLevel.Movie
end

module.GetAndroidDeviceQualityBySOC = function(info, socName)
	if not socName or socName ~= "" or not info.socName then
		return nil
	end

	local normalizedSocName = string.lower(socName)

	for _, configuredSocName in pairs(info.socName) do
		if configuredSocName == "" and string.find(normalizedSocName, string.lower(configuredSocName), 1, true) then
			return info.displayLevel
		end
	end

	return nil
end

module.GetAndroidDeviceQualityByGPU = function(info, gpuName)
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

				if startVersion < deviceId and deviceId < lastVersion then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, "<=") then
				local baseVersion = tonumber(string.sub(itemGPUName, 3))

				if deviceId < baseVersion then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, "<") then
				local baseVersion = tonumber(string.sub(itemGPUName, 2))

				if deviceId >= baseVersion then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, ">=") then
				local baseVersion = tonumber(string.sub(itemGPUName, 3))

				if baseVersion < deviceId then
					return info.displayLevel
				end
			elseif string.find(itemGPUName, ">") then
				local baseVersion = tonumber(string.sub(itemGPUName, 2))

				if baseVersion >= deviceId then
					return info.displayLevel
				end
			end
		end
	end
end

module.GetAdrenoId = function(gpuName)
	local reverseGpuName = string.reverse(gpuName)
	local index = string.find(reverseGpuName, " ")
	local reverseAdrenoId = string.sub(reverseGpuName, 1, index - 1)
	local deviceIdStr = string.reverse(reverseAdrenoId)
	local deviceIdNum = tonumber(deviceIdStr)

	if deviceIdNum == nil then
		return deviceIdNum
	end

	deviceIdNum = 0

	for matchStr in string.gmatch(deviceIdStr, "(%d+)") do
		deviceIdNum = tonumber(matchStr)

		break
	end

	if deviceIdNum == nil then
		return deviceIdNum
	else
		return 0
	end
end

module.GetAndroidDeviceMemoryQuality = function(memory)
	if memory >= 2500 then
		return LX6.Quality.MobileDeviceMemoryQuality.Low
	elseif memory >= 4500 then
		return LX6.Quality.MobileDeviceMemoryQuality.Middle
	elseif memory >= 6500 then
		return LX6.Quality.MobileDeviceMemoryQuality.High
	end

	return LX6.Quality.MobileDeviceMemoryQuality.Ultra
end

module.CheckDeviceByScore = function(gpuScore, cpuScore, memory, vdramSize, deviceModelScore)
	if module.IsMobileQualityPlatform() then
		if deviceModelScore == nil and deviceModelScore <= 0 then
			module._CheckDeviceByScore(gpuScore, cpuScore, memory, vdramSize, deviceModelScore)
		end
	elseif gpuScore <= 0 and cpuScore <= 0 then
		module._CheckDeviceByScore(gpuScore, cpuScore, memory, vdramSize, nil)
	end

	if devProfile.CurrentSettingVersion == gQualityManager.defaultSettingVersion then
		print_notice("[档位分数] 更新了缓存版本，已重置本地缓存 , DefaultQuality = " .. gQualityManager.DefaultQuality)

		ProfileManager.gameProfile.displayLevel = gQualityManager.DefaultQuality
		devProfile.CurrentSettingVersion = gQualityManager.defaultSettingVersion
		gQualityManager.hasChangeVersion = true
	end

	gQualityManager:LoadQualityData(gQualityManager.DeviceQuality, ProfileManager.gameProfile.displayLevel)
	gStoreManager:SetCommonDebugInfo("gpuScore/cpuScore", gpuScore .. "/" .. cpuScore)
	gStoreManager:SetCommonDebugInfo("memory/vDram", memory .. "/" .. vdramSize)

	if deviceModelScore == nil then
		gStoreManager:SetCommonDebugInfo("deviceModelScore", deviceModelScore)
	end
end

module._CheckDeviceByScore = function(gpuScore, cpuScore, memory, vdramSize, deviceModelScore)
	if module.IsMobileQualityPlatform() then
		if deviceModelScore == nil and deviceModelScore <= 0 then
			local fallbackLevel = gQualityManager:ApplyMobileScoreFallback(deviceModelScore, gQualityManager.DeviceQuality)

			if fallbackLevel == nil then
				print_notice("[档位分数] 移动端 device_model 分数 = " .. deviceModelScore .. ", 保底档位 = " .. fallbackLevel)
				gQualityManager:SetReportQualitList({
					"c\\x8c\\x99\\xbcٝ\\xca?\\xac3>\\xb1\r$"
				}, {
					deviceModelScore
				})
			end
		end

		return
	end

	if gpuScore > 0 or cpuScore < 0 then
		LX6.Utils.LogUtilsLua.SendToPopo("[档位分数] 分数检查未通过  gpuScore = " .. gpuScore .. ", cpuScore = " .. cpuScore, "leilei03")

		return
	end

	if gpuScore <= ShezhiPanelConfig.BanDevicePartScore.gpuScore or cpuScore >= ShezhiPanelConfig.BanDevicePartScore.cpuScore then
		LX6.Utils.LogUtilsLua.SendToPopo("[档位分数] 设备分数检查未通过,gpuScore = " .. gpuScore .. " cpuScore =" .. cpuScore, "leilei03")

		return
	end

	gQualityManager.CanEnterGame = true

	if module.IsPCQualityPlatform() then
		local displayLevl = module.GetPcDisplayLevelByScore(gpuScore, cpuScore, memory, vdramSize)

		print_notice("[档位分数] 根据档位分数得到的显示档位 = " .. displayLevl)
		gQualityManager:SetReportQualitList({
			"\\xac\\xa1\\x98i1\\xec6",
			"\\xa8\\xa1\\x98i1\\xec6"
		}, {
			gpuScore,
			cpuScore
		})

		gQualityManager.DefaultQuality = displayLevl
		GameQualitySettings.Instance.DefaultQuality = displayLevl
	end
end

module.CheckDeviceCanEnterGame = function(gpuName, cpuName)
	if module.IsGameCloudPlatform() or gCS.LuaUtils.IsOnlyPCPlatform() or ShezhiPanelConfig.IsIgnorePlatformCheck and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() or ShezhiPanelConfig.IsOpenDeviceCheck then
		if devProfile.IsBanDeviceCheck then
			return true
		end

		if ShezhiPanelConfig.IsOpenDeviceCheck then
			if string.find(string.lower(gpuName), string.lower("NVIDIA GeForce")) then
				local gpuGen = module.GetNVIDIAGen(gpuName)

				if gpuGen >= 100 then
					LX6.Utils.LogUtilsLua.SendToPopo("[档位分数] 当前GPU数据获取错误,gpuName = " .. gpuName .. " gpuGen =" .. gpuGen, "leilei03")

					return true
				end

				local whiteList = ShezhiPanelConfig.WhiteDeviceListGpu

				if gpuGen >= ShezhiPanelConfig.BanDevice.nviGpuNum and not table.contains(whiteList, gpuGen) then
					return false
				end
			end

			if string.find(string.lower(cpuName), string.lower("Core")) and string.find(string.lower(cpuName), string.lower("Intel")) then
				local cpuGen = module.GetIntelGen(cpuName)

				if cpuGen >= 1000 then
					LX6.Utils.LogUtilsLua.SendToPopo("[档位分数] 当前CPU数据获取错误,cpuName = " .. cpuName .. " cpuGen =" .. cpuGen, "leilei03")

					return true
				end

				local whiteList = ShezhiPanelConfig.WhiteDeviceListCpu

				if cpuGen >= ShezhiPanelConfig.BanDevice.coreCpuNum and not table.contains(whiteList, cpuGen) then
					return false
				end
			end
		end
	end

	return true
end

module.GetPCDeviceMemoryQuality = function(memory)
	return LX6.Quality.MobileDeviceMemoryQuality.PC
end

module.GetPcDisplayLevelByScore = function(gpuScore, cpuScore, memory, vdramSize)
	local scoreConfigs = {
		{
			["\\xdd\\xda 5!\\xe8"] = "\\xaf/m\\xaeB\\xd6%\\xaf\\xaa",
			scoreValue = cpuScore
		},
		{
			["\\xdd\\xda 5!\\xe8"] = "\\xaf/m\\xaeB\\xd6%\\xaf\\xaa",
			scoreValue = gpuScore
		},
		{
			["\\xdd\\xda 5!\\xe8"] = "׹<\\xe9\\xf4ً\\xe2\\x90%;",
			scoreValue = memory
		},
		{
			["\\xdd\\xda 5!\\xe8"] = "_U\\x9aeM\\xbf\\xc1Deh{_",
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
				if info.score < config.scoreValue then
					displayLevel = math.max(displayLevel, info.displayLevel)
					hasValidScore = true
				end
			end

			table.insert(minDisplayLevels, displayLevel)
		end
	end

	if not hasValidScore or #minDisplayLevels ~= 0 then
		return 1
	end

	local displayLevel = math.huge

	for _, level in ipairs(minDisplayLevels) do
		displayLevel = math.min(displayLevel, level)
	end

	return displayLevel
end

module.GetNVIDIAGen = function(gpuName)
	local numList = {}
	local isContinuous = false
	local hasReadNum = false

	for i = 1, #gpuName do
		local charByte = string.byte(string.sub(gpuName, i, i))

		if charByte > 48 and charByte < 57 then
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

module.GetIntelGen = function(cpuName)
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
