local PlatformSettingsData = require("LuaGen/QualityData/platform_settings_data")
local DetailQualityLevelData = require("LuaGen/QualityData/detail_quality_level_data")
local SettingsScriptFunc = require("LX6/GUI/Setting/SettingsScriptFunc")
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local defaultProfile = ProfileManager.defaultProfile
local GameQualitySettings = LX6.Manager.GameQualitySettings
local PlatformSettingQuality = LX6.Quality.PlatformSettingQuality
local Screen = UnityEngine.Screen
local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local ShezhiPanelShezhiConfig = LTConfig.ShezhiPanelShezhiConfig
local languageProfile = ProfileManager.languageProfile
local M = {
	defaultSettingVersion = 4,
	hasChangeVersion = false,
	unitHideDistance = 30,
	CanEnterGame = true,
	DefaultQuality = 2,
	isSettingRefresh = false,
	unitLimit = 40,
	useLodMaterialEffect = false,
	unitDecoHideDistance = 20,
	DeviceQuality = LX6.Quality.MobileDeviceQuality.Ultra,
	DeviceMemoryLevel = LX6.Quality.MobileDeviceMemoryQuality.Ultra,
	RealDeviceMemoryLevel = LX6.Quality.MobileDeviceMemoryQuality.Ultra,
	DeviceGraphicsQuality = LX6.Quality.DeviceGraphicsQuality.L3,
	PCName = {}
}
local QUALITY_PLAYFORM_2_NAME = {
	nil,
	"Mobile",
	nil,
	nil,
	"PS",
	"PC",
	nil,
	"PV"
}
local QUALITY_PLATFORM_MAP = {
	[2] = {
		"phone_1_low",
		"phone_2_fast",
		"phone_3_good",
		"phone_4_high",
		"phone_5_movie"
	},
	[5] = {
		"ps_1_low",
		"ps_2_fast",
		"ps_3_good",
		"ps_4_high",
		"ps_5_movie",
		"ps_6_ultimate"
	},
	[6] = {
		"pc_1_low",
		"pc_2_fast",
		"pc_3_good",
		"pc_4_high",
		"pc_5_movie"
	},
	[8] = {
		"pv_1_low",
		"pv_2_fast",
		"pv_3_good",
		"pv_4_high",
		"pv_5_movie"
	}
}
local SETTING_DETAIL_PREFIX_MAP = {
	sceneCount = "scene_count",
	effect = "effect_default",
	charMeshTex = "character_meshtex",
	cutsceneLevel = "cutscene_level",
	resolutionScreen = "resolution_screen",
	cache = "cache_default",
	sceneMat = "scene_mat",
	resolutionShadow = "resolution_shadow",
	vehicleCount = "vehicle_count",
	charCount = "character_count",
	matLevel = "mat_level",
	graphicsGamePad = "graphics_gamepadmemory",
	graphicsPC = "graphics_pcmemory",
	graphicsIOS = "graphics_iosmemory",
	graphicsAndroid = "graphics_androidmemory",
	postProcess = "postProcess_default"
}
local SETTING_DETAIL_SUFFIX_MAP = {
	"_L1",
	"_L2",
	"_L3",
	"_L4",
	"_L5",
	"_L6",
	"_L7",
	"_L8",
	"_L9",
	"_L10",
	"_PV"
}

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.NewScene then
		SettingsScriptFunc.ReloadAllProfile()
		self:LoadingFinish()
	end
end

function M:RefreshQualityDebugInfo(deviceLevel, displayLevel)
	gStoreManager:SetCommonDebugInfo("deviceLevel", QUALITY_PLAYFORM_2_NAME[deviceLevel] or "error")
	gStoreManager:SetCommonDebugInfo("displayLevel", self:GetDisplayLevelName(displayLevel))
end

function M:LoadQualityData(deviceLevel, displayLevel)
	self:RefreshQualityDebugInfo(deviceLevel, displayLevel)

	local cutomLevel = self:GetCustomLevel()

	if displayLevel == cutomLevel then
		return
	end

	print_notice("[档位] 加载档位数据，deviceLevel = " .. deviceLevel .. ", displayLevel = " .. displayLevel)

	if displayLevel >= cutomLevel - 1 then
		if displayLevel ~= cutomLevel - 1 then
			gameProfile.displayLevel = 3

			ProfileManager.SaveGameProperty()
			print_error("你的本地档位缓存数据不对，当你看到这条消息时，本地缓存档位已被修改，重进游戏即可正常进入，有疑问联系leilei处理")
			LX6.Utils.LogUtilsLua.SendToPopo("本地缓存档位有误，联系程序雷擂处理displayLevel = " .. displayLevel, "leilei03")
		end
	end

	if displayLevel > cutomLevel - 1 then
		displayLevel = cutomLevel - 1
	end

	local configName = QUALITY_PLATFORM_MAP[deviceLevel][displayLevel]

	if configName == nil then
		print_error("LoadQualityData Error! platform settings not exist! deviceLevel=" .. deviceLevel .. " displayLevel=" .. displayLevel)

		return
	end

	local currentPlatFormSetting = PlatformSettingsData[configName]

	if currentPlatFormSetting then
		self:SyncPlatformSettingsToGameProfile(currentPlatFormSetting)
	end

	self:LoadDetailQualityDataFromGameProfile()
	self:SetReportQualitList({
		"deviceLevel",
		"displayLevel"
	}, {
		deviceLevel,
		displayLevel
	})

	if gQualityManager.hasChangeVersion then
		ProfileManager.SaveGameProperty()
		ProfileManager.SaveDevProperty()

		gQualityManager.hasChangeVersion = false
	end
end

function M:LoadDetailQualityDataFromGameProfile()
	local detailName = nil
	detailName = self:GetDetailName("resolutionScreen", gameProfile.resolutionScreen)

	if detailName ~= nil then
		self:SyncResolutionScreenDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("resolutionShadow", gameProfile.resolutionShadow)

	if detailName ~= nil then
		self:SyncResolutionShadowDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("matLevel", gameProfile.matLevel)

	if detailName ~= nil then
		self:SyncMatLevelDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("charCount", gameProfile.charCount)

	if detailName ~= nil then
		self:SyncCharCountDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("vehicleCount", gameProfile.vehicleCount)

	if detailName ~= nil then
		self:SyncVehicleCountDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("cutsceneLevel", gameProfile.cutsceneLevel)

	if detailName ~= nil then
		self:SyncCutsceneLevelDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("charMeshTex", gameProfile.charMeshTex)

	if detailName ~= nil then
		self:SyncCharMeshTexDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("sceneCount", gameProfile.sceneCount)

	if detailName ~= nil then
		self:SyncSceneCountDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("sceneMat", gameProfile.sceneMat)

	if detailName ~= nil then
		self:SyncSceneMatDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("effect", gameProfile.effect)

	if detailName ~= nil then
		self:SyncEffectDetailData(DetailQualityLevelData[detailName])
	end

	detailName = self:GetDetailName("postProcess", gameProfile.postProcess)

	if detailName ~= nil then
		self:SyncPostProcessDetailData(DetailQualityLevelData[detailName])
	end

	if gameProfile.miniMemory then
		self.DeviceMemoryLevel = LX6.Quality.MobileDeviceMemoryQuality.Low
	else
		self.DeviceMemoryLevel = self.RealDeviceMemoryLevel
	end

	detailName = self:GetDetailName("cache", self.DeviceMemoryLevel)

	if detailName ~= nil then
		self:SyncCacheDetailData(DetailQualityLevelData[detailName])
	end

	local graphicsDetailKey = "graphicsPC"

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		graphicsDetailKey = "graphicsPC"
	elseif gCS.LuaUtils.IsOnAndroid then
		graphicsDetailKey = "graphicsAndroid"
	elseif gCS.LuaUtils.IsOnIOS then
		graphicsDetailKey = "graphicsIOS"
	elseif gCS.LuaUtils.IsOnPS5 then
		graphicsDetailKey = "graphicsGamePad"
	end

	detailName = self:GetDetailName(graphicsDetailKey, M.DeviceGraphicsQuality)

	print_notice("[档位系统] graphicsDetailKey = " .. graphicsDetailKey .. ", detailName = " .. detailName)

	if detailName ~= nil then
		self:SyncGraphicsDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"antiAliasing",
		gameProfile.antiAliasing
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"antialiasingQuality",
		gameProfile.antialiasingQuality
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"antialiasingLevel",
		gameProfile.antialiasingLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"frameGeneration",
		gameProfile.frameGeneration
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"fpsType",
		gameProfile.fpsType
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"vSync",
		gameProfile.vSync
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"raytracingOn",
		gameProfile.raytracingOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"ssrOn",
		gameProfile.ssrOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"miniMemory",
		gameProfile.miniMemory
	})
end

function M:SyncResolutionScreenDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"resolutionQuality",
		detailData.resolutionQuality
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"resolution",
		detailData.resolution
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"resolutionHeight",
		detailData.resolutionHeight
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"dynamicScale",
		detailData.dynamicScale
	})
end

function M:ChangeResolutionScreen(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("resolutionScreen", level)

	if detailName ~= nil then
		self:SyncResolutionScreenDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"resolutionScreen",
		level
	})
	self:SetReportQualitList({
		"resolutionScreen"
	}, {
		level
	})
end

local MIN_HARD_HEIGHT = 570

function M:GetPCResolutions()
	local pcName = {}

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local resolutions = Screen.resolutions:ToTable()
		local index = 0
		local beforePcName = {}

		for i = 1, #resolutions do
			local view = {
				width = resolutions[i].width,
				height = resolutions[i].height
			}
			local canAdd = true

			if view.height < MIN_HARD_HEIGHT then
				canAdd = false
			end

			if not table.isNilOrEmpty(beforePcName) then
				for k, v in pairs(beforePcName) do
					if v and v.width == view.width and v.height == view.height then
						canAdd = false
					end
				end
			end

			if canAdd then
				index = index + 1
				beforePcName[index] = view
			end
		end

		for k = 1, #beforePcName do
			pcName[#beforePcName - k + 1] = beforePcName[k]
		end

		M.PCName = pcName
	end

	return pcName
end

function M:ChangePCResolution(level)
	if gCS.LuaUtils.IsNonMobileAdaptive() and self.PCName[level] then
		gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
			"pcResolutionScreenWidth",
			M.PCName[level].width
		})
		gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
			"pcResolutionScreenHeight",
			M.PCName[level].height
		})
		self:SetReportQualitList({
			"pcResolutionScreenWidth",
			"pcResolutionScreenHeight"
		}, {
			M.PCName[level].width,
			M.PCName[level].height
		})
	end
end

function M:GetAliasings()
	local aliasings = GameQualitySettings.GetAvaliableAntiAliasing():ToTable()
	local temp = ""

	for i, v in pairs(aliasings) do
		temp = temp .. v .. ","
	end

	print_notice("GetAliasings :" .. temp)

	return aliasings
end

function M:GetAntiAliasingQualitys()
	local antialiasingQualitys = GameQualitySettings.GetAvaliableAntiAliasingQualitys():ToTable()
	local temp = ""

	for i, v in pairs(antialiasingQualitys) do
		temp = temp .. v .. ","
	end

	print_notice("GetAntiAliasingQuality :" .. temp)

	return antialiasingQualitys
end

function M:GetAntiAliasingLevels()
	local antialiasingLevels = GameQualitySettings.GetAvaliableAntiAliasingLevels():ToTable()
	local temp = ""

	for i, v in pairs(antialiasingLevels) do
		temp = temp .. v .. ","
	end

	print_notice("GetAntiAliasingLevels :" .. temp)

	return antialiasingLevels
end

function M:GetFrameGenerationQuality()
	local frameGenerationQuality = GameQualitySettings.GetAvaliableFrameGeneration():ToTable()
	local temp = ""

	for i, v in pairs(frameGenerationQuality) do
		temp = temp .. v .. ","
	end

	print_notice("GetFrameGenerationQuality :" .. temp)

	return frameGenerationQuality
end

function M:SetPCScreenIsFull(screenFullData)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
			"pcResolutionIsFullScreen",
			screenFullData
		})
		self:SetReportQualitList({
			"pcResolutionIsFullScreen"
		}, {
			screenFullData
		})
	end
end

function M:GetDisplayIndex()
	local displayIndexs = GameQualitySettings.GetDisplayIndex():ToTable()

	return displayIndexs
end

function M:SetPCDisplayIndex(displayIndex)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
			"pcResolutionDisplayIndex",
			displayIndex
		})
		self:SetReportQualitList({
			"pcResolutionDisplayIndex"
		}, {
			displayIndex
		})
	end
end

function M:SetAdaptableSize(level)
	local ertraPanelScale = 1

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		local AdaptableSizePC = ShezhiPanelConfig.AdaptableSizePC
		SGUI.UIConfig.instance.standaloneAdaptationScale = AdaptableSizePC[level] or 1

		if level == 2 then
			ertraPanelScale = AdaptableSizePC[2] / AdaptableSizePC[1]
		end
	elseif gCS.LuaUtils.IsOnPS5 or gQualityManager:IsInEditorPSPlatform() then
		local AdaptableSizePS = ShezhiPanelConfig.AdaptableSizePS
		SGUI.UIConfig.instance.consoleAdaptationScale = AdaptableSizePS[level] or 1

		if level == 1 then
			ertraPanelScale = AdaptableSizePS[1] / AdaptableSizePS[2]
		end
	end

	SGUI.UIConfig.instance:SetExtraPanelScale(ertraPanelScale)
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"adaptableSize",
		level
	})
end

function M:GetAdaptableScaleMode(level)
	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		if level == 2 then
			return true
		end

		return false
	elseif gCS.LuaUtils.IsOnPS5 or gQualityManager:IsInEditorPSPlatform() then
		if level == 1 then
			return true
		end

		return false
	end

	return true
end

function M:SyncResolutionShadowDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"mainLightShadowQuality_PC",
		detailData.mainLightShadowQuality_PC
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"mainLightShadowQuality_Mobile",
		detailData.mainLightShadowQuality_Mobile
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"enableMainLightShadow",
		detailData.enableMainLightShadow
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"enableAdditionalLightsShadow",
		detailData.enableAdditionalLightsShadow
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"useRTShadow",
		detailData.useRTShadow
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"meUseRTShadow",
		detailData.meUseRTShadow
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"otherPlayerUseRTShadow",
		detailData.otherPlayerUseRTShadow
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"otherUnitUseRTShadow",
		detailData.otherUnitUseRTShadow
	})
end

function M:ChangeResolutionShadow(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("resolutionShadow", level)

	if detailName ~= nil then
		self:SyncResolutionShadowDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"resolutionShadow",
		level
	})
end

function M:SyncCharCountDetailData(detailData)
	self.unitLimit = detailData.unitLimit
	self.unitHideDistance = detailData.unitHideDistance

	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"unitLimit",
		self.unitLimit
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"unitHideDistance",
		self.unitHideDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"processModelLoadPerFrame",
		detailData.processModelLoadPerFrame
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"processUIModelLoadPerFrame",
		detailData.processUIModelLoadPerFrame
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"npcRenderingHighDistance",
		detailData.npcRenderingHighDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"npcRenderingHighCount",
		detailData.npcRenderingHighCount
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"indoorNPCRenderingHighCountRatio",
		detailData.indoorNPCRenderingHighCountRatio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"npcLODDynamicBias",
		detailData.npcLODDynamicBias
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"npcECSHighDistance",
		detailData.npcECSHighDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"npcECSHighCount",
		detailData.npcECSHighCount
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"densityFactor",
		detailData.densityFactor
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"spoonNpcIndoorHideDistance",
		detailData.spoonNpcIndoorHideDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"spoonNpcOutdoorHideDistance",
		detailData.spoonNpcOutdoorHideDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"useBakeryVolume",
		detailData.useBakeryVolume
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"useDmInTimeline",
		detailData.useDmInTimeline
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"useHairShadowRT",
		detailData.useHairShadowRT
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"scaleHairRTRatio",
		detailData.scaleHairRTRatio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"skinQuality",
		detailData.skinQuality
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"unitLODMeshCacheCount",
		detailData.unitLODMeshCacheCount
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"unitSkinCacheCount",
		detailData.unitSkinCacheCount
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"unitEntityAssetCacheCount",
		detailData.unitEntityAssetCacheCount
	})
end

function M:SyncVehicleCountDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"massVehicleLOD0DistanceInView",
		detailData.massVehicleLOD0DistanceInView
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"massVehicleLOD1To2DistanceInView",
		detailData.massVehicleLOD1To2DistanceInView
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"massVehicleEcs2GoDistanceInView",
		detailData.massVehicleEcs2GoDistanceInView
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"massVehicleEcsLowLODDistanceInView",
		detailData.massVehicleEcsLowLODDistanceInView
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"vehicleMinInViewTime",
		detailData.vehicleMinInViewTime
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"vehicleForceGoDistance",
		detailData.vehicleForceGoDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"vehicleCandidateGoDistance",
		detailData.vehicleCandidateGoDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"vehicleGoSwitchCamSpeedThreshold",
		detailData.vehicleGoSwitchCamSpeedThreshold
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"massVehicleLOD0CountLimit",
		detailData.massVehicleLOD0CountLimit
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"massVehicleLOD1CountLimit",
		detailData.massVehicleLOD1CountLimit
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"massVehicleLOD2CountLimit",
		detailData.massVehicleLOD2CountLimit
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"vehicleDummyRange",
		detailData.vehicleDummyRange
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"MetroLOD0Dis",
		detailData.MetroLOD0Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"MetroLOD1Dis",
		detailData.MetroLOD1Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"MetroLOD2Dis",
		detailData.MetroLOD2Dis
	})
end

function M:SyncCutsceneLevelDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"timelineEffectMode",
		detailData.timelineEffectMode
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"timelinePlayerLODMeshLevel",
		detailData.timelinePlayerLODMeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"timelineNpcLOD0MeshLevel",
		detailData.timelineNpcLOD0MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"timelineNpcLOD1MeshLevel",
		detailData.timelineNpcLOD1MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"timelineNpcLOD2MeshLevel",
		detailData.timelineNpcLOD2MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"timelineNpcLOD1Dis",
		detailData.timelineNpcLOD1Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"timelineNpcLOD2Dis",
		detailData.timelineNpcLOD2Dis
	})
end

function M:ChangeCharCount(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("charCount", level)

	if detailName ~= nil then
		self:SyncCharCountDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"charCount",
		level
	})
	self:SetReportQualitList({
		"charCount"
	}, {
		level
	})
end

function M:ChangeVehicleCount(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("vehicleCount", level)

	if detailName ~= nil then
		self:SyncVehicleCountDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"vehicleCount",
		level
	})
	self:SetReportQualitList({
		"vehicleCount"
	}, {
		level
	})
end

function M:ChangeCutsceneLevel(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("cutsceneLevel", level)

	if detailName ~= nil then
		self:SyncCutsceneLevelDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"cutsceneLevel",
		level
	})
	self:SetReportQualitList({
		"cutsceneLevel"
	}, {
		level
	})
end

function M:SyncCharMeshTexDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"myPlayerLOD0MeshLevel",
		detailData.myPlayerLOD0MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"myPlayerLOD1MeshLevel",
		detailData.myPlayerLOD1MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"myPlayerLOD2MeshLevel",
		detailData.myPlayerLOD2MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"myPlayerLOD1Dis",
		detailData.myPlayerLOD1Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"myPlayerLOD2Dis",
		detailData.myPlayerLOD2Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nonMyPlayerLOD0MeshLevel",
		detailData.nonMyPlayerLOD0MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nonMyPlayerLOD1MeshLevel",
		detailData.nonMyPlayerLOD1MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nonMyPlayerLOD2MeshLevel",
		detailData.nonMyPlayerLOD2MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nonMyPlayerLOD1Dis",
		detailData.nonMyPlayerLOD1Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nonMyPlayerLOD2Dis",
		detailData.nonMyPlayerLOD2Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"atmosphereNpcLOD0MeshLevel",
		detailData.atmosphereNpcLOD0MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"atmosphereNpcLOD1MeshLevel",
		detailData.atmosphereNpcLOD1MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"atmosphereNpcLOD2MeshLevel",
		detailData.atmosphereNpcLOD2MeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"atmosphereNpcLOD1Dis",
		detailData.atmosphereNpcLOD1Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"atmosphereNpcLOD2Dis",
		detailData.atmosphereNpcLOD2Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"uiUnitLODMeshLevel",
		detailData.uiUnitLODMeshLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"enableSSS",
		detailData.enableSSS
	})
end

function M:ChangeCharMeshTex(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("charMeshTex", level)

	if detailName ~= nil then
		self:SyncCharMeshTexDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"charMeshTex",
		level
	})
	self:SetReportQualitList({
		"charMeshTex"
	}, {
		level
	})
end

function M:SyncMatLevelDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"matQuality",
		detailData.matQuality
	})
end

function M:ChangeMatLevel(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("matLevel", level)

	if detailName ~= nil then
		self:SyncMatLevelDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"matLevel",
		level
	})
	self:SetReportQualitList({
		"matLevel"
	}, {
		level
	})
end

function M:SyncSceneCountDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"lodFactor",
		detailData.lodFactor
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"lodTween",
		detailData.lodTween
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"indoorLoadFactor",
		detailData.indoorLoadFactor
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"lightLoadFactor",
		detailData.lightLoadFactor
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"enableDetailsInstancing",
		detailData.enableDetailsInstancing
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsInstancingLOD0Dis",
		detailData.detailsInstancingLOD0Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsInstancingLOD1Dis",
		detailData.detailsInstancingLOD1Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsInstancingLOD2Dis",
		detailData.detailsInstancingLOD2Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsInstancingLOD3Dis",
		detailData.detailsInstancingLOD3Dis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsInstancingLOD0DensityCoef",
		detailData.detailsInstancingLOD0DensityCoef
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsInstancingLOD1DensityCoef",
		detailData.detailsInstancingLOD1DensityCoef
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsInstancingLOD2DensityCoef",
		detailData.detailsInstancingLOD2DensityCoef
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsInstancingLOD3DensityCoef",
		detailData.detailsInstancingLOD3DensityCoef
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"enableDetailsTouchBend",
		detailData.enableDetailsTouchBend
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsTouchBendTexSize",
		detailData.detailsTouchBendTexSize
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"detailsTouchBendCameraRange",
		detailData.detailsTouchBendCameraRange
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"characterCapsuleAOFilter",
		detailData.characterCapsuleAOFilter
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"enableVolumeAO",
		detailData.enableVolumeAO
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"npcCapsuleShadowDistance",
		detailData.npcCapsuleShadowDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"cameraFarClipFactor",
		detailData.cameraFarClipFactor
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"mipZeroStartDistance",
		detailData.mipZeroStartDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"textureSizeForceStopToChangeMip",
		detailData.textureSizeForceStopToChangeMip
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"mip0Ratio",
		detailData.mip0Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"mip1Ratio",
		detailData.mip1Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"mip2Ratio",
		detailData.mip2Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"mip3Ratio",
		detailData.mip3Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"mip4Ratio",
		detailData.mip4Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nexusMip0Ratio",
		detailData.nexusMip0Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nexusMip1Ratio",
		detailData.nexusMip1Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nexusMip2Ratio",
		detailData.nexusMip2Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nexusMip3Ratio",
		detailData.nexusMip3Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"nexusMip4Ratio",
		detailData.nexusMip4Ratio
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"globalTexIndexCapacity",
		detailData.globalTexIndexCapacity
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"enableGPUScene",
		detailData.enableGPUScene
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"smallSubSectorsToSkip",
		detailData.smallSubSectorsToSkip
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"sceneQualityProtocolLevel",
		detailData.sceneQualityProtocolLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"highRangeBySizeBig",
		detailData.highRangeBySizeBig
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"highRangeBySizeMiddle",
		detailData.highRangeBySizeMiddle
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"highRangeBySizeSmall",
		detailData.highRangeBySizeSmall
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low1RangeBySizeBig",
		detailData.low1RangeBySizeBig
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low1RangeBySizeMiddle",
		detailData.low1RangeBySizeMiddle
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low1RangeBySizeSmall",
		detailData.low1RangeBySizeSmall
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low2RangeBySizeBig",
		detailData.low2RangeBySizeBig
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low2RangeBySizeMiddle",
		detailData.low2RangeBySizeMiddle
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low2RangeBySizeSmall",
		detailData.low2RangeBySizeSmall
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"maxActiveDebrisNum",
		detailData.maxActiveDebrisNum
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"hideImmediatelyToPlayer",
		detailData.hideImmediatelyToPlayer
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"hideImmediatelyToPlayerBehind",
		detailData.hideImmediatelyToPlayerBehind
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"highGadgetLodSmall",
		detailData.highGadgetLodSmall
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low1GadgetLodSmall",
		detailData.low1GadgetLodSmall
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low2GadgetLodSmall",
		detailData.low2GadgetLodSmall
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"highGadgetLodBig",
		detailData.highGadgetLodBig
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low1GadgetLodBig",
		detailData.low1GadgetLodBig
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low2GadgetLodBig",
		detailData.low2GadgetLodBig
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"highModelDgScreenHeightRate",
		detailData.highModelDgScreenHeightRate
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"middleModelDgScreenHeightRate",
		detailData.middleModelDgScreenHeightRate
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"lowModelDgScreenHeightRate",
		detailData.lowModelDgScreenHeightRate
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"highRangeForDecorativeVehicle",
		detailData.highRangeForDecorativeVehicle
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low1RangeForDecorativeVehicle",
		detailData.low1RangeForDecorativeVehicle
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"low2RangeForDecorativeVehicle",
		detailData.low2RangeForDecorativeVehicle
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"dynamicLightAneEffQualityLevel",
		detailData.dynamicLightAneEffQualityLevel
	})
end

function M:ChangeSceneCount(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("sceneCount", level)

	if detailName ~= nil then
		self:SyncSceneCountDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"sceneCount",
		level
	})
	self:SetReportQualitList({
		"sceneCount"
	}, {
		level
	})
end

function M:SyncSceneMatDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"useNormTex",
		detailData.useNormTex
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"useLightTex",
		detailData.useLightTex
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"realTimeReflectionLevel",
		detailData.realTimeReflectionLevel
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"waterReflectionMode",
		detailData.waterReflectionMode
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"waterSSPRBlurOn",
		detailData.waterSSPRBlurOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"waterSSPRRTMaxSize",
		detailData.waterSSPRRTMaxSize
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"waterSSPRRDispatchMaxScale",
		detailData.waterSSPRRDispatchMaxScale
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"waterInteractionOn",
		detailData.waterInteractionOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"realtimeLightingQuality",
		detailData.realtimeLightingQuality
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"ssrQuality",
		detailData.ssrQuality
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"ssrDeltaUV",
		detailData.ssrDeltaUV
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"ssrFadeDistance",
		detailData.ssrFadeDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"ssrSampleCount",
		detailData.ssrSampleCount
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumeFogOn",
		detailData.volumeFogOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumetricFogLightIntensityThresholdMul",
		detailData.volumetricFogLightIntensityThresholdMul
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumetricFogMainLightOn",
		detailData.volumetricFogMainLightOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumetricFogDepthExtent",
		detailData.volumetricFogDepthExtent
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumetricFogEndDistance",
		detailData.volumetricFogEndDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumetricFogGridSize",
		detailData.volumetricFogGridSize
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumetricFogSliceCount",
		detailData.volumetricFogSliceCount
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"giFogMaxDistance",
		detailData.giFogMaxDistance
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumetricFogXYBufferBudget",
		detailData.volumetricFogXYBufferBudget
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumetricFogDepthBudget",
		detailData.volumetricFogDepthBudget
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volumetricFogSliceDistributionUniformity",
		detailData.volumetricFogSliceDistributionUniformity
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"BrushFogOn",
		detailData.BrushFogOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"LightFogEffectOn",
		detailData.LightFogEffectOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"LocalVolumeLight",
		detailData.LocalVolumeLight
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"crepuscularRayOn",
		detailData.crepuscularRayOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"crepuscularRayQuality",
		detailData.crepuscularRayQuality
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"crepuscularRayMaxDepth",
		detailData.crepuscularRayMaxDepth
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"crepuscularRaySampleCount",
		detailData.crepuscularRaySampleCount
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"giFogOn",
		detailData.giFogOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"globalCubeFogOn",
		detailData.globalCubeFogOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"volRenderOn",
		detailData.volRenderOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"stylizedDomeCloudOn",
		detailData.stylizedDomeCloudOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"giQuality",
		detailData.giQuality
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"ssrUIOn",
		detailData.ssrUIOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"ssrUIOn",
		detailData.ssrUIOn
	})
end

function M:ChangeSceneMat(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("sceneMat", level)

	if detailName ~= nil then
		self:SyncSceneMatDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"sceneMat",
		level
	})
	self:SetReportQualitList({
		"sceneMat"
	}, {
		level
	})
end

function M:SyncEffectDetailData(detailData)
	self.useLodMaterialEffect = detailData.useLodMaterialEffect

	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"effectHideQuality",
		detailData.effectHideQuality
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"timelineEffectLimit",
		detailData.timelineEffectLimit
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"useLodMaterialEffect",
		detailData.useLodMaterialEffect
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"processEffectLoadPerFrame",
		detailData.processEffectLoadPerFrame
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"sceneEffectMinBoundsSize",
		detailData.sceneEffectMinBoundsSize
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"sceneEffectMaxBoundsSize",
		detailData.sceneEffectMaxBoundsSize
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"sceneEffectBaseBoundsSize",
		detailData.sceneEffectBaseBoundsSize
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"sceneEffectBaseCullingDis",
		detailData.sceneEffectBaseCullingDis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"sceneEffectBaseInViewDis",
		detailData.sceneEffectBaseInViewDis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"sceneEffectBaseAllOnDis",
		detailData.sceneEffectBaseAllOnDis
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"particleLodFactor",
		detailData.particleLodFactor
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"particlePerfBudgetFactor",
		detailData.particlePerfBudgetFactor
	})
end

function M:ChangeEffect(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("effect", level)

	if detailName ~= nil then
		self:SyncEffectDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"effect",
		level
	})
	self:SetReportQualitList({
		"effect"
	}, {
		level
	})
end

function M:SyncPostProcessDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"bloomOn",
		detailData.bloomOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"sunShaftsOn",
		detailData.sunShaftsOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"radialBlurOn",
		detailData.radialBlurOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"cameraDofOn",
		detailData.cameraDofOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"dofOn",
		detailData.dofOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"motionBlurOn",
		detailData.motionBlurOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"exposureOn",
		detailData.exposureOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"gtaoOn",
		detailData.gtaoOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"lightFlareOn",
		detailData.lightFlareOn
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"paraffinFlareOn",
		detailData.paraffinFlareOn
	})
end

function M:ChangePostProcess(level)
	level = self:ConvertLevelForNonMobile(level)
	local detailName = self:GetDetailName("postProcess", level)

	if detailName ~= nil then
		self:SyncPostProcessDetailData(DetailQualityLevelData[detailName])
	end

	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"postProcess",
		level
	})
end

function M:ChangeAntiAliasing(level)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"antiAliasing",
		level
	})
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"antiAliasing",
		level
	})
end

function M:ChangeAntiAliasingQuality(level)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"antialiasingQuality",
		level
	})
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"antialiasingQuality",
		level
	})
end

function M:ChangeAntiAliasingLevel(level)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"antialiasingLevel",
		level
	})
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"antialiasingLevel",
		level
	})
end

function M:ChangeFrameGeneration(level)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"frameGeneration",
		level
	})
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"frameGeneration",
		level
	})
end

function M:ChangeFPS(fps)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"fpsType",
		fps
	})
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"fpsType",
		fps
	})
	self:SetReportQualitList({
		"fpsType"
	}, {
		fps
	})
end

function M:ChangeVSync(on)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"vSync",
		on
	})
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"vSync",
		on
	})
	self:SetReportQualitList({
		"vSync"
	}, {
		on
	})
end

function M:SetSSROn(on)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"ssrOn",
		on
	})
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"ssrOn",
		on
	})
	self:SetReportQualitList({
		"ssrOn"
	}, {
		on
	})
end

function M:SetRaytracing(on)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"raytracingOn",
		on
	})
	gMessageManager:SendMessage(gEventConstants.SET_CHANGED, {
		"raytracingOn",
		on
	})
	self:SetReportQualitList({
		"raytracingOn"
	}, {
		on
	})
end

function M:SyncCacheDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"instanceCacheFreeLimit",
		detailData.instanceCacheFreeLimit
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"loadSectorLimit",
		detailData.loadSectorLimit
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"useSmallestMipmapUnused",
		detailData.useSmallestMipmapUnused
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"unusedTimeout",
		detailData.unusedTimeout
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"unusedMemory",
		detailData.unusedMemory
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"unusedMipmap",
		detailData.unusedMipmap
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"discardedTimeout",
		detailData.discardedTimeout
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"doNormalLowMemoryThreshold",
		detailData.doNormalLowMemoryThreshold
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"doAggressiveLowMemoryThreshold",
		detailData.doAggressiveLowMemoryThreshold
	})
end

function M:SyncGraphicsDetailData(detailData)
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingSceneBudget",
		detailData.streamingSceneBudget
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingCharBudget",
		detailData.streamingCharBudget
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingLow2Budget",
		detailData.streamingLow2Budget
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingEffectBudget",
		detailData.streamingEffectBudget
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingNexusBudget",
		detailData.streamingNexusBudget
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingVehicleBudget",
		detailData.streamingVehicleBudget
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingSceneCalculateMipScale",
		detailData.streamingSceneCalculateMipScale
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingCharCalculateMipScale",
		detailData.streamingCharCalculateMipScale
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingLow2CalculateMipScale",
		detailData.streamingLow2CalculateMipScale
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingEffectCalculateMipScale",
		detailData.streamingEffectCalculateMipScale
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingNexusCalculateMipScale",
		detailData.streamingNexusCalculateMipScale
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingVehicleCalculateMipScale",
		detailData.streamingVehicleCalculateMipScale
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingMipmapsMaxLevelReduction",
		detailData.streamingMipmapsMaxLevelReduction
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"streamingMipmapsMaxIORequests",
		detailData.streamingMipmapsMaxIORequests
	})
	gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
		"enableGPUSceneRender",
		detailData.enableGPUSceneRender
	})
end

function M:SyncPlatformSettingsToGameProfile(currentPlatFormSetting)
	gameProfile.resolutionScreen = currentPlatFormSetting.resolutionScreen
	gameProfile.resolutionShadow = currentPlatFormSetting.resolutionShadow
	gameProfile.charCount = currentPlatFormSetting.charCount
	gameProfile.charMeshTex = currentPlatFormSetting.charMeshTex
	gameProfile.sceneCount = currentPlatFormSetting.sceneCount
	gameProfile.sceneMat = currentPlatFormSetting.sceneMat
	gameProfile.effect = currentPlatFormSetting.effect
	gameProfile.postProcess = currentPlatFormSetting.postProcess
	gameProfile.fpsType = currentPlatFormSetting.fpsType
	gameProfile.vSync = currentPlatFormSetting.vSync
	gameProfile.ssrUIOn = currentPlatFormSetting.ssrUIOn
	gameProfile.vehicleCount = currentPlatFormSetting.vehicleCount
	gameProfile.cutsceneLevel = currentPlatFormSetting.cutsceneLevel
	gameProfile.matLevel = currentPlatFormSetting.matLevel
	gameProfile.antiAliasing = currentPlatFormSetting.antiAliasing
	gameProfile.frameGeneration = currentPlatFormSetting.frameGenerationQuality
	gameProfile.raytracingOn = currentPlatFormSetting.raytracingOn
	gameProfile.ssrOn = currentPlatFormSetting.ssrOn
	gameProfile.miniMemory = currentPlatFormSetting.miniMemory

	GameQualitySettings.Instance:UploadQualitySetting()
end

function M:GetDetailName(detailKey, detailLevel)
	local prefix = SETTING_DETAIL_PREFIX_MAP[detailKey]

	if prefix then
		local suffix = SETTING_DETAIL_SUFFIX_MAP[detailLevel]

		print_debug("GetDetailName", detailKey, detailLevel, prefix .. suffix)

		return prefix .. suffix
	else
		return nil
	end
end

function M:ConvertLevelForNonMobile(level)
	if not gCS.LuaUtils.IsNonMobileAdaptive() or self:GetQualityPlatform() then
		return level
	end

	if level > 5 then
		return level
	end

	return level + 5
end

function M:ConvertLevelForDisplay(level)
	if not gCS.LuaUtils.IsNonMobileAdaptive() or self:GetQualityPlatform() then
		return level
	end

	if level <= 5 then
		return level
	end

	return level - 5
end

function M:GetQualityPlatform()
	if gCS.LuaUtils.IsOnEditor and (ProfileManager.devProfile.QualityPlatform == PlatformSettingQuality.Android or ProfileManager.devProfile.QualityPlatform == PlatformSettingQuality.IOS) then
		return true
	end

	return false
end

function M:IsInEditorPCPlatform()
	if gCS.LuaUtils.IsOnEditor then
		return ProfileManager.devProfile.QualityPlatform == PlatformSettingQuality.PC
	end

	return false
end

function M:IsInEditorAndroidPlatform()
	if gCS.LuaUtils.IsOnEditor then
		return ProfileManager.devProfile.QualityPlatform == PlatformSettingQuality.Android
	end

	return false
end

function M:IsInEditorIOSPlatform()
	if gCS.LuaUtils.IsOnEditor then
		return ProfileManager.devProfile.QualityPlatform == PlatformSettingQuality.IOS
	end

	return false
end

function M:IsInEditorPSPlatform()
	if gCS.LuaUtils.IsOnEditor then
		return ProfileManager.devProfile.QualityPlatform == PlatformSettingQuality.PS
	end

	return false
end

local gameProfileEnum = {
	cache = "cache_default",
	graphicsGamePad = "graphics_gamepadmemory",
	graphicsPC = "graphics_pcmemory",
	graphicsIOS = "graphics_iosmemory",
	graphicsAndroid = "graphics_androidmemory",
	resolutionScreen = gameProfile.resolutionScreen,
	resolutionShadow = gameProfile.resolutionShadow,
	matLevel = gameProfile.matLevel,
	charCount = gameProfile.charCount,
	charMeshTex = gameProfile.charMeshTex,
	sceneCount = gameProfile.sceneCount,
	sceneMat = gameProfile.sceneMat,
	effect = gameProfile.effect,
	postProcess = gameProfile.postProcess,
	vehicleCount = gameProfile.vehicleCount,
	cutsceneLevel = gameProfile.cutsceneLevel
}

function M:GMSetQualityDetailLevel(name, level)
	local detailName = self:GetDetailName(name, level)

	if string.contains(name, "resolutionScreen") then
		self:SyncResolutionScreenDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "resolutionShadow") then
		self:SyncResolutionShadowDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "matLevel") then
		self:SyncMatLevelDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "charCount") then
		self:SyncCharCountDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "vehicleCount") then
		self:SyncVehicleCountDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "cutsceneLevel") then
		self:SyncCutsceneLevelDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "charMeshTex") then
		self:SyncCharMeshTexDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "sceneCount") then
		self:SyncSceneCountDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "sceneMat") then
		self:SyncSceneMatDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "effect") then
		self:SyncEffectDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "postProcess") then
		self:SyncPostProcessDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "cache") then
		self:SyncCacheDetailData(DetailQualityLevelData[detailName])
	end

	if string.contains(name, "graphics") then
		self:SyncGraphicsDetailData(DetailQualityLevelData[detailName])
	end
end

function M:GMSetQualityDetails(detailPreName, name, value)
	local detailName = gQualityManager:GetDetailName(detailPreName, gameProfileEnum[detailPreName])

	if detailName ~= nil then
		local detailData = DetailQualityLevelData[detailName]

		if detailData[name] ~= nil then
			if type(detailData[name]) == "boolean" then
				gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
					name,
					value == 1
				})
				print_notice("GMSetQualityDetails " .. name .. " = " .. tostring(value == 1))
			else
				gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
					name,
					value
				})
				print_notice("GMSetQualityDetails " .. name .. " = " .. value)
			end
		else
			print_error("输入的name在" .. detailName .. "中找不到对应的数据  name = " .. name .. "  value = " .. value)
		end
	end
end

function M:GMSetCacheDetails(name, value)
	local detailName = self:GetDetailName("cache", gQualityManager.DeviceMemoryLevel)

	if detailName ~= nil then
		local detailData = DetailQualityLevelData[detailName]

		if detailData[name] ~= nil then
			if type(detailData[name]) == "boolean" then
				gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
					name,
					value == 1
				})
				print_notice("GMSetQualityDetails " .. name .. " = " .. tostring(value == 1))
			else
				gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
					name,
					value
				})
				print_notice("GMSetQualityDetails " .. name .. " = " .. value)
			end
		else
			print_error("输入的name在" .. detailName .. "中找不到对应的数据  name = " .. name .. "  value = " .. value)
		end
	end
end

function M:GMSetGraphicsDetails(name, value)
	local detailName = self:GetDetailName("graphics", gQualityManager.DeviceGraphicsQuality)

	if detailName ~= nil then
		local detailData = DetailQualityLevelData[detailName]

		if detailData[name] ~= nil then
			if type(detailData[name]) == "boolean" then
				gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
					name,
					value == 1
				})
				print_notice("GMSetQualityDetails " .. name .. " = " .. tostring(value == 1))
			else
				gMessageManager:SendMessage(gEventConstants.SET_SYNC, {
					name,
					value
				})
				print_notice("GMSetQualityDetails " .. name .. " = " .. value)
			end
		else
			print_error("输入的name在" .. detailName .. "中找不到对应的数据  name = " .. name .. "  value = " .. value)
		end
	end
end

function M:SetReportQualitList(nameList, valueList)
	if not ShezhiPanelConfig.IsOpenDeviceLog then
		return
	end

	if #nameList ~= #valueList then
		return
	end

	local reportStr = ""

	for i = 1, #nameList do
		reportStr = self:AddReportLog(reportStr, nameList[i], valueList[i])
	end

	self:AskReportQualitySetting(reportStr)
end

function M:LoginReportLog(deviceName, deviceModel, graphicDeviceName, deviceType, memory, processorCount, processorFrequency, graphicsQuality, cpu_name, deviceQuality, drivenName)
	if not ShezhiPanelConfig.IsOpenDeviceLog then
		return
	end

	local reportStr = ""
	reportStr = self:AddReportLog(reportStr, "deviceName", deviceName)
	reportStr = self:AddReportLog(reportStr, "deviceModel", deviceModel)
	reportStr = self:AddReportLog(reportStr, "gpu_name", graphicDeviceName)
	reportStr = self:AddReportLog(reportStr, "cpu_name", cpu_name)
	reportStr = self:AddReportLog(reportStr, "deviceType", deviceType)
	reportStr = self:AddReportLog(reportStr, "memory", memory)
	reportStr = self:AddReportLog(reportStr, "processorCount", processorCount)
	reportStr = self:AddReportLog(reportStr, "processorFrequency", processorFrequency)
	reportStr = self:AddReportLog(reportStr, "graphicsQuality", graphicsQuality)
	reportStr = self:AddReportLog(reportStr, "deviceQuality", deviceQuality)
	reportStr = self:AddReportLog(reportStr, "drivenName", drivenName)
	self.loginReport = reportStr
end

function M:AddReportLog(reportStr, name, value)
	if reportStr == nil then
		reportStr = ""
	end

	reportStr = reportStr .. "'" .. name .. "':'" .. tostring(value) .. "',"

	return reportStr
end

function M:LoadingFinish()
	if self.loginReport then
		self.loginReport = self:AddReportLog(self.loginReport, "pcResolutionIsFullScreen", languageProfile.pcResolutionIsFullScreen)
		self.loginReport = self:AddReportLog(self.loginReport, "pcResolutionScreenWidth", languageProfile.pcResolutionScreenWidth)
		self.loginReport = self:AddReportLog(self.loginReport, "pcResolutionScreenHeight", languageProfile.pcResolutionScreenHeight)

		self:AskReportQualitySetting(self.loginReport)

		self.loginReport = nil
	end
end

function M:AskReportQualitySetting(str)
	if not ShezhiPanelConfig.IsOpenDeviceLog then
		return
	end

	local setting = {
		setting = str
	}

	print_notice("[GameQuality] " .. str)
	gClientToGameDelegate:AskReportQualitySetting(setting)
end

function M:GetCustomLevel()
	local customLevel = ShezhiPanelConfig.CustomLevel.pcLevel

	if gCS.LuaUtils.IsOnAndroid or gCS.LuaUtils.IsOnIOS or self:IsInEditorAndroidPlatform() or self:IsInEditorIOSPlatform() then
		customLevel = ShezhiPanelConfig.CustomLevel.mobileLevel
	end

	return customLevel
end

function M:GetDisplayLevelName(displayLevel)
	local displayCfg = ShezhiPanelShezhiConfig.GetConfig(ShezhiPanelShezhiConfig.DisplayLevel)
	local nameList = displayCfg.PCName

	if gCS.LuaUtils.IsOnAndroid or gCS.LuaUtils.IsOnIOS or self:IsInEditorAndroidPlatform() or self:IsInEditorIOSPlatform() then
		nameList = displayCfg.iOSName
	end

	local name = nameList[displayLevel]

	if not name or not name.name then
		return "error"
	end

	local index = tonumber(name.name) + 1
	local nameType = ShezhiPanelConfig.DisplayLevelType[index]

	if not nameType then
		return "error"
	end

	return nameType.name
end

function M:_RealSetAntidinicModeAll(isAntidinicModeAll)
	if isAntidinicModeAll == true then
		gPanelManager:CheckShow(gPanelId.S_CROSS_HAIR_ANTI_GLARE)

		gameProfile.cameraMotionBlurIntensity = ShezhiPanelShezhiConfig.GetConfig(ShezhiPanelShezhiConfig.CameraMotionBlur).SliderSetValues.minValue or 1
		gameProfile.lensDistortionIntensity = ShezhiPanelShezhiConfig.GetConfig(ShezhiPanelShezhiConfig.LensDistortionIntensity).SliderSetValues.minValue or 1
		gameProfile.swingCameraItensity = ShezhiPanelShezhiConfig.GetConfig(ShezhiPanelShezhiConfig.SwingCameraItensity).SliderSetValues.minValue or 1
		gameProfile.isAntidinicMode = true
		gameProfile.isAntidinicModeAll = true
	else
		gameProfile.cameraMotionBlurIntensity = defaultProfile.cameraMotionBlurIntensity
		gameProfile.lensDistortionIntensity = defaultProfile.lensDistortionIntensity
		gameProfile.swingCameraItensity = defaultProfile.swingCameraItensity
		gameProfile.isAntidinicModeAll = defaultProfile.isAntidinicModeAll
		gameProfile.isAntidinicMode = defaultProfile.isAntidinicMode

		gPanelManager:Close(gPanelId.S_CROSS_HAIR_ANTI_GLARE)
	end

	ProfileManager.SaveGameProperty()
	gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
end

function M:ReplyAntiDinicMode()
	if not self.isSettingRefresh and gameProfile.isAntidinicModeAll == true then
		gameProfile.isAntidinicModeAll = false

		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
	end
end

function M:GetDisplayLevelIndex()
	local level = gameProfile.displayLevel == 0 and gQualityManager.DefaultQuality or gameProfile.displayLevel

	return level
end

function M:CheckIsDisplayLevel(id)
	local cfg = ShezhiPanelShezhiConfig.GetConfig(id)

	if not cfg then
		return false
	end

	return cfg.IsConnectDisplayLevel and #cfg.iOSName == 5
end

gQualityManager = M
