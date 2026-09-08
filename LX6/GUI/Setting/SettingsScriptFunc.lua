-- Original chunk: @Lua\LuaFiles\LX6\GUI\Setting\SettingsScriptFunc.lua
-- Decompiled from: 00231_SettingsScriptFunc.lua_67cb39291a5d.luajit

local ProfileManager = LX6.Engine.ProfileManager
local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local ShezhiPanelLanguagesConfig = LTConfig.ShezhiPanelLanguagesConfig
local MessageConfig = LTConfig.MessageConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local ConstConfig = LX6.Manager.ConstConfig
local RebindMode = LX6.Manager.RebindMode
local gameProfile = ProfileManager.gameProfile
local defaultProfile = ProfileManager.defaultProfile
local languageProfile = ProfileManager.languageProfile
local SettingsScriptFunc = {}
local json = require("cjson/json")
local M = SettingsScriptFunc
local this = SettingsScriptFunc

M.Lock = function()
	gPanelManager:CheckShow(gPanelId.V3_MESSAGE_WARNING, {
		des = LTConfig.TextScriptTextConfig.GetConfig(89900581).Text
	})
end

M.GetAliasings = function()
	local data = this.SettingData

	if data then
		local aliasings = gQualityManager:GetAliasings()

		if not table.isNilOrEmpty(aliasings) then
			gMessageManager:SendMessage(gEventConstants.SETTING_SEND_ALIASING_NAME, {
				fatherId = data.fatherId,
				name = aliasings
			})
		end
	end
end

M.SetGamePadShowIcon = function(num)
	local data = this.SettingData

	if data then
		gMessageManager:SendMessage(gEventConstants.SETTING_SEND_GAMEPAD_SHOW_ICON, {
			fatherId = data.fatherId,
			showIconButtonId = num
		})
	end
end

M.SaveMotionStrengthSliderValue = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.motionStrength = data.value
	end
end

M.SaveAllVolumeSliderValue = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.allVolume = data.value / 100
	end
end

M.SaveAllVolumeIsOn = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isAllVolumeOn = data.value
	end
end

M.SaveMusicSliderValue = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.bgmVolume = data.value / 100
	end
end

M.SaveMusicIsOn = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isBgmVolumeOn = data.value
	end
end

M.SaveEffectSliderValue = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.effectVolume = data.value / 100
	end
end

M.SaveEffectIsOn = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isSoundEffectOn = data.value
	end
end

M.SaveFightTalkSliderValue = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.fightTalkVolume = data.value / 100
	end
end

M.SaveFightTalkIsOn = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isFightTalkOn = data.value
	end
end

M.SetDisplayLevel = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local displayLevel = data.value

		if gCS.LuaUtils.IsOnPS5 or gQualityManager:IsInEditorPSPlatform() then
			displayLevel = displayLevel + 2
		end

		if gameProfile.displayLevel == displayLevel then
			gameProfile.displayLevel = displayLevel
			local recommendLevel = gQualityManager.DeviceQuality

			gQualityManager:LoadQualityData(recommendLevel, displayLevel)

			if displayLevel == gQualityManager:GetCustomLevel() then
				gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
				gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_CHAR_MESH)
			end
		end
	end
end

M.SetPCResolution = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) and not table.isNilOrEmpty(gQualityManager.PCName) then
		gQualityManager:ChangePCResolution(data.value)
	end
end

M.SetPCResolutionFullMode = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) and not table.isNilOrEmpty(gQualityManager.PCName) then
		gQualityManager:SetPCScreenIsFull(data.value)
	end
end

M.SetResolutionScreen = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeResolutionScreen(data.value)
	end
end

M.SetAdaptableSize = function(self)
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:SetAdaptableSize(data.value)
	end
end

local FPS_UNLIMITED = -1

M.SetFps = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local fps = this.GetFpsByType(data.value)

		gQualityManager:ChangeFPS(fps)

		if fps ~= FPS_UNLIMITED then
			gameProfile.vSync = false

			gQualityManager:ChangeVSync(false)
		elseif gameProfile.vSync then
			gQualityManager:ChangeVSync(gameProfile.vSync)
		end
	end
end

M.SetPCDisplayIndex = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:SetPCDisplayIndex(data.value)
	end
end

M.GetFpsByType = function(type)
	return ShezhiPanelConfig.NormalFps[type]
end

M.SetResolutionShadow = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeResolutionShadow(data.value)
	end
end

M.SetPostProcess = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangePostProcess(data.value)
	end
end

M.SetAntiAliasing = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local aliasings = gQualityManager:GetAliasings()

		if not table.isNilOrEmpty(aliasings) and aliasings[data.value] then
			gQualityManager:ChangeAntiAliasing(aliasings[data.value])
		else
			print_error("SetAntiAliasing error  value = " .. data.value)
		end
	end
end

M.SetAntiAliasingQuality = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local antialiasingsQualitys = gQualityManager:GetAntiAliasingQualitys()

		if not table.isNilOrEmpty(antialiasingsQualitys) and antialiasingsQualitys[data.value] then
			gQualityManager:ChangeAntiAliasingQuality(antialiasingsQualitys[data.value])
		else
			print_error("SetAntiAliasingQuality error  value = " .. data.value)
		end
	end
end

M.SetAntiAliasingLevel = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local aliasings = gQualityManager:GetAntiAliasingLevels()

		if not table.isNilOrEmpty(aliasings) and aliasings[data.value] then
			gQualityManager:ChangeAntiAliasingLevel(aliasings[data.value])
		else
			print_error("SetAntiAliasing error  value = " .. data.value)
		end
	end
end

M.SetFrameGen = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local frameGenerations = gQualityManager:GetFrameGenerationQuality()

		if not table.isNilOrEmpty(frameGenerations) and frameGenerations[data.value] then
			gQualityManager:ChangeFrameGeneration(frameGenerations[data.value])
		else
			print_error("SetFrameGen error  value = " .. data.value)
		end
	end
end

M.SetAnisotropicFilterLevel = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local profileLevel = math.max(0, math.min(4, data.value - 1))

		gQualityManager:ChangeAnisotropicFilterLevel(profileLevel)
	end
end

M.ResetAnisotropicFilterLevel = function()
	this.SettingData = {
		value = (defaultProfile.anisotropicFilterLevel or 0) + 1
	}

	M.SetAnisotropicFilterLevel()
end

M.SetvSync = function()
	if gameProfile.fpsType ~= FPS_UNLIMITED then
		return
	end

	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local isOn = data.value ~= 1

		gQualityManager:ChangeVSync(isOn)
	end
end

M.CheckvSync = function()
	if gameProfile.fpsType ~= FPS_UNLIMITED then
		return false
	end

	return gameProfile.frameGeneration ~= 1
end

M.SetSSR = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local isOn = data.value ~= 1

		gQualityManager:SetSSROn(isOn)
	end
end

M.SetRaytracing = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local isOn = data.value ~= 1

		gQualityManager:SetRaytracing(isOn)
	end
end

M.SetSceneCount = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeSceneCount(data.value)
	end
end

M.SetSceneMat = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeSceneMat(data.value)
	end
end

M.SetCharMeshTex = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeCharMeshTex(data.value)
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_CHAR_MESH)
	end
end

M.SetEffect = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeEffect(data.value)
	end
end

M.SetMatQuality = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeMatLevel(data.value)
	end
end

M.SetCharCount = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeCharCount(data.value)
	end
end

M.SetVehicleCount = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeVehicleCount(data.value)
	end
end

M.SetCutsceneLevel = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeCutsceneLevel(data.value)
	end
end

M.SetIsDialogTyperOn = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local isOn = data.value ~= 1
		gameProfile.isDialogTyperOn = isOn
	end
end

M.SetShotGlobalCameraRotateSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotGlobalCameraRotateLevel = value * 2

		ProfileManager.SaveGameProperty()
	end
end

M.SetCameraRotateSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.cameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.cameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetShotFireCameraRotateXSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetShotFireCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetShotNotFireCameraRotateXSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotNotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetShotNotFireCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotNotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetShotOpenLensFireCameraRotateXSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotOpenLensFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetShotOpenLensFireCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotOpenLensFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetShotOpenLensNotFireCameraRotateXSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotOpenLensNotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetShotOpenLensNotFireCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotOpenLensNotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleShotFireCameraRotateXSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleShotFireCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleShotNotFireCameraRotateXSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotNotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleShotNotFireCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotNotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleShotOpenLensFireCameraRotateXSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotOpenLensFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleShotOpenLensFireCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotOpenLensFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleShotOpenLensNotFireCameraRotateXSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotOpenLensNotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleShotOpenLensNotFireCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotOpenLensNotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetSwingCameraRotateSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.swingCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetSwingCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.swingCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleCameraRotateSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetVehicleCameraRotateYSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SwingCameraItensity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.swingCameraItensity = Mathf.Clamp(value, 1, 10)

		gQualityManager:ReplyAntiDinicMode()
		ProfileManager.SaveGameProperty()
	end
end

M.SetLensDistortionIntensity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.lensDistortionIntensity = Mathf.Clamp(value, 0, 10)

		gQualityManager:ReplyAntiDinicMode()
		ProfileManager.SaveGameProperty()
	end
end

M.ResetLensDistortionIntensity = function()
	gameProfile.lensDistortionIntensity = defaultProfile.lensDistortionIntensity
end

M.SetCameraMotionBlurIntensity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.cameraMotionBlurIntensity = Mathf.Clamp(value, 0, 10)

		gQualityManager:ReplyAntiDinicMode()
		ProfileManager.SaveGameProperty()
		gCS.CameraDataMgr.cameraEffectController:ResetMotionBlurByProfile()
	end
end

M.SetInverseCamInputX = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local inverse = data.value ~= 1
		gameProfile.inverseCamInputX = inverse

		ProfileManager.SaveGameProperty()
	end
end

M.SetInverseCamInputY = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local inverse = data.value ~= 1
		gameProfile.inverseCamInputY = inverse

		ProfileManager.SaveGameProperty()
	end
end

M.SetLockTargetCameraOn = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isLockTargetCameraOn = data.value ~= 1
	end
end

M._RealSetLanguage = function(index)
	local langList = ShezhiPanelConfig.LanguagesDisplay

	if not index or index <= 1 or index <= #langList then
		return
	end

	local lang = langList[index]
	local curLang = LTConfig.TableGetLanguage()

	if curLang == lang then
		if gCS.LuaUtils.IsOnEditor and gLuaDataManager.configChanged then
			gDisplayMessageMgr:ShowMessageContentDebug("热更后，切语言可能失效")
		end

		local cfg = ShezhiPanelLanguagesConfig.GetConfig(index)

		if cfg then
			SGUI.UIConfig.instance:SetLanguage(lang)
		end

		LTConfig.TableSetLanguage(lang)
		LTConfig.ChangeLang()

		languageProfile.textLanguage = index

		ProfileManager.SaveLanguageProperty()
		LX6.Manager.LocalizationManager.Instance:OnLanguageChange()
		gMessageManager:SendMessage(gEventConstants.LANGUAGE_CHANGE, lang)
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS, {
			["\\x9d5.p\\x92V\\xed>\\xba\\xaa"] = true,
			["}s\\xaaeI\\xa1\\xfaseNq\\"] = true
		})
	end
end

M.SetLanguage = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		M._RealSetLanguage(data.value)
	end
end

M.SetVoiceLanguage = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		if not gDlcDownLoadMgr:IsVoiceDLCReady(data.value) then
			gDlcDownLoadMgr:ShowVoiceDLCDownloadMessage()

			return false
		end

		local voiceLang = ShezhiPanelConfig.VoiceLanguagesDisplay[data.value]

		gSoundMgr:SetVoiceLanguage(voiceLang)

		languageProfile.voiceLanguage = data.value

		ProfileManager.SaveLanguageProperty()
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_VOICE_CALL_VISIBILITY)

		return true
	end

	return false
end

M.SetMotionLevel = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.MotionLevel = data.value
	end
end

M.SaveHandleSpeakerIsOn = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isHandleSpeakerOn = data.value
	end
end

M.SetMuteWhenUnfocused = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		if data.value ~= 1 then
			gameProfile.muteWhenUnfocused = true
		else
			gameProfile.muteWhenUnfocused = false
		end
	end
end

M.SetHandleSpeakerOutput = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.handleSpeakerOutputId = data.value
	end
end

M.SaveHandleSpeakerVolume = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.handleSpeakerValue = data.value / 100
	end
end

M.SetSoundNumberLevel = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.soundNumberLevel = data.value
	end
end

M.SetIsShowBubble = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isShowBubble = data.value ~= 1
	end
end

M.SetIsShowZhanlingBubble = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isShowZhanlingBubble = data.value ~= 1
	end
end

M.SetShowUniqueSkillAnimation = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.ShowUniqueSkillAnimation = data.value ~= 1
	end
end

M.SetIsVibrating = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isVibrating = data.value ~= 1
	end
end

M.SetVehicleSteerSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleSteerSpeedLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

M.SetHelicopterSimpleDriveMode = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.helicopterSimpleDriveMode = data.value ~= 1

		gMessageManager:SendMessage(gEventConstants.HELICOPTER_SIMPLE_DRIVE_MODE_ENABLED)
	end
end

M.SetSwitchShoulderFire = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isClickSwitchShoulderFire = data.value ~= 2
	end
end

M.SetBattlePeaceMode = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isBattlePeaceMode = data.value ~= 1
	end
end

M.SetBattlePeaceModeOnline = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isBattlePeaceModeOnline = data.value ~= 1
	end
end

M.SetBoxingGloveVisible = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isBoxingGloveVisible = data.value ~= 1
	end
end

M.SetAuxiliaryCombatMode = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.auxiliaryCombatMode = data.value ~= 1
	end
end

M.SetAuxiliaryAimModeMobile = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.auxiliaryAimModeMobile = data.value ~= 1

		gMessageManager:SendMessage(gEventConstants.SETTING_AIM_ASSIST_CHANGE)
	end
end

M.SetAuxiliaryAimModeMouse = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.auxiliaryAimModeMouse = data.value ~= 1

		gMessageManager:SendMessage(gEventConstants.SETTING_AIM_ASSIST_CHANGE)
	end
end

M.SetAuxiliaryAimModeGamepad = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.auxiliaryAimModeGamepad = data.value ~= 1

		gMessageManager:SendMessage(gEventConstants.SETTING_AIM_ASSIST_CHANGE)
	end
end

M.SetShowPlayerName = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local usePlayerName = data.value ~= 1

		gClientToGameDelegate:AskChangeRoleUseSystemName(not usePlayerName).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gPlayerManager.infoLogin.bindData.UsePlayerName = usePlayerName

			if gCS.MyPlayerManager.PlayerInfo then
				gCS.MyPlayerManager.PlayerInfo.UsePlayerName = usePlayerName
			end

			gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
			gSpiritManager:RefreshMainSpiritName()
		end
	end
end

M.SetPowerSavingMode = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.powerSavingMode = data.value ~= 1
	end
end

M.SetMobileControlMode = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gCS.PanelManager.Instance.IsMobileMode = not data.value ~= 1

		ProfileManager.SaveGameProperty()
		ProfileManager.SaveDevProperty()
		ProfileManager.SaveLanguageProperty()
		gLoginManager:DoKickToLogin()
	end
end

M.SetCharMotionInviteNotDisturb = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local inviteNotDisturb = gCharMotionUtils.CheckInviteNotDisturb() and 1 or 2

		if inviteNotDisturb ~= data.value then
			return
		end

		gCharMotionUtils.SetInviteNotDisturb(function ()
			gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
		end)
	end
end

M.SetSoloAllowTeamInvite = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.soloAllowTeamInvite = data.value ~= 1
	end
end

M.SetSoloAllowLinkInvite = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.soloAllowLinkInvite = data.value ~= 1
	end
end

M.SetSoloAllowGameplayInvite = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.soloAllowGameplayInvite = data.value ~= 1
	end
end

M.SetAntidinicMode = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isAntidinicMode = data.value ~= 1

		if gameProfile.isAntidinicMode then
			gPanelManager:CheckShow(gPanelId.S_CROSS_HAIR_ANTI_GLARE)
		else
			gPanelManager:Close(gPanelId.S_CROSS_HAIR_ANTI_GLARE)

			if gameProfile.isAntidinicModeAll then
				gQualityManager:ReplyAntiDinicMode()
			end
		end

		ProfileManager.SaveGameProperty()
	end
end

M.SetAntidinicModeAll = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local wantEnable = data.value ~= 1

		if wantEnable ~= gameProfile.isAntidinicModeAll then
			return
		end

		if wantEnable then
			slot2 = gDisplayMessageMgr

			slot2:ShowMessage(MessageConfig.Setting_MotionSicknessPrevention, function ()
				gQualityManager:_RealSetAntidinicModeAll(true)
			end, function ()
				gQualityManager:ReplyAntiDinicMode(true)
			end)
		else
			gQualityManager:_RealSetAntidinicModeAll(false)
		end
	end
end

M.SetVehicleOprMode = function(self)
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isVehicleJoystickMode = data.value
		local modeTextId = data.value and 89901270 or 89901269
		local message = gString.Format(TextScriptTextConfig.GetConfig(89901268).Text, TextScriptTextConfig.GetConfig(modeTextId).Text)

		gDisplayMessageMgr:ShowMessageContent(message)
		gMessageManager:SendMessage(gEventConstants.SETTING_SEND_VEHICLE_MODE, data.value)
	end
end

M.SetExchangeWingSuit = function(self)
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isExchangeWingSuit = data.value ~= 1
	end
end

M.SetMobileGamepadMode = function(self)
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		if data.value ~= 1 then
			M.CheckIsMobileControllerOn()
		else
			gameProfile.mobileControlMode = false

			ProfileManager.SaveGameProperty()
			ProfileManager.SaveDevProperty()
			ProfileManager.SaveLanguageProperty()
			SGUI.UIConfig.instance:SetAdaptationPlatform(SGUI.EPlatform.Mobile)

			gCS.PanelManager.Instance.IsMobileMode = true

			if LX6.GUI.GuiMgr.Instance.sguiJoystick ~= nil then
				LX6.GUI.GuiMgr.Instance.sguiJoystick:ShowJoystickUI(true)
			end

			SGUI.InputActionBind.fixedGameDevice = SGUI.GameDevice.KeyboardMouse

			gLoginManager:DoKickToLogin(nil, , true)
		end
	end
end

M.CheckIsMobileControllerOn = function()
	if gCoreHudUIManager.isEnterController then
		gameProfile.mobileControlMode = true

		ProfileManager.SaveGameProperty()
		ProfileManager.SaveDevProperty()
		ProfileManager.SaveLanguageProperty()
		SGUI.UIConfig.instance:SetAdaptationPlatform(SGUI.EPlatform.Console)

		gCS.PanelManager.Instance.IsMobileMode = false

		if LX6.GUI.GuiMgr.Instance.sguiJoystick == nil then
			LX6.GUI.GuiMgr.Instance.sguiJoystick:ShowJoystickUI(false)
		end

		SGUI.InputActionBind.fixedGameDevice = SGUI.GameDevice.PlayStation

		gLoginManager:DoKickToLogin(nil, , true)
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.MoblieNoController)
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
	end
end

M.SetMobileButtonTextNum = function(self)
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.mobileButtonTextNum = data.value

		gStoreButtonMgr:InitBtnTextVisible()
	end
end

M.SetSafeAreaOffset = function(self)
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.safeAreaOffset = Mathf.Clamp(value, 1, 100)

		SGUI.UIConfig.instance:ChangeSafeAreaOffset(gameProfile.safeAreaOffset)
	end
end

M.SetControllerSetting = function(self)
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isCustomizeController = data.value ~= 2

		ProfileManager.SaveGameProperty()

		if gameProfile.isCustomizeController then
			gMessageManager:SendMessage(gEventConstants.REBIND_TO_CUSTOM, RebindMode.Gamepad)
		else
			gMessageManager:SendMessage(gEventConstants.REBIND_TO_DEFAULT, RebindMode.Gamepad)
		end

		gMessageManager:SendMessage(gEventConstants.SETTING_KEY_PANEL_CHANGED)
	end
end

M.SetMicrophoneMode = function(self)
	local data = this.SettingData

	if table.isNilOrEmpty(data) then
		return
	end

	local oldMode = gameProfile.microphoneMode
	local newMode = data.value
	gameProfile.microphoneMode = newMode

	gMessageManager:SendMessage(gEventConstants.MICROPHONE_MODE_CHANGED, {
		newMode = newMode,
		oldMode = oldMode
	})
end

M.SetCCVoiceListeningVolume = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.ccVoiceListeningVolume = data.value
	end
end

M.SetCCVoiceMicVolume = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.ccVoiceMicVolume = data.value
	end
end

M.SetSwapConfirmAndCancel = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.swapConfirmCancel = data.value ~= 1
	end
end

M.SetSwapL3AndR3 = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.swapL3R3 = data.value ~= 1
	end
end

M.SetGyroControllerEnable = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isEnableGyroSensitivity = data.value ~= 1

		gBattleMgr:EnableGyroController(gameProfile.isEnableGyroSensitivity)
	end
end

M.SetShootGyroControllerSensitivity = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.cameraGyroSensitivity = Mathf.Clamp(data.value, 1, 100)
	end
end

M.SetVedioMemoryLoadMsg = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.showVideoMemoryMsg = data.value ~= 1
	end
end

M.SetVehicleStuntsCamera = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isAllowVehicleStuntsCamera = data.value ~= 1
	end
end

M.SetUltButtonToR2 = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isUltButtonToR2 = data.value ~= 1
	end
end

M.SetJoystickPositionMode = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.joystickPositionMode = data.value
		LX6.GUI.GuiMgr.Instance.sguiJoystick.isDynamic = gameProfile.joystickPositionMode ~= 1
	end
end

M.TurnToSelectedPersonalInfo = function()
	UniSDKManager.ShowSelectedPersonalInfo()
end

M.TurnToSharedPersonalInfo = function()
	UniSDKManager.ShowPolicyInfo(ConstConfig.GetConfig(ConstConfig.SharedPersonalInfo))
end

M.TurnToPrivatePolicy = function()
	UniSDKManager.ShowPolicyInfo(ConstConfig.GetConfig(ConstConfig.PrivatePolicy))
end

M.TurnToUserCenter = function()
	gCS.LoginManager:OpenUserCenter()
end

M.TurnToDLCDownload = function()
	gDlcDownLoadMgr:ShowPanel(1)
end

M.TurnToRebindPC = function()
	gPanelManager:CheckShow(gPanelId.SETTING_BTN_RESET_PANEL)
end

M.TurnToExchangeCode = function()
	slot0 = gDisplayMessageMgr

	slot0:ShowInputBox(MessageConfig.ExchangeCode, nil, function (inputText)
		LX6.SDK.SerialNumberSystem.QueryOrActiveGiftCode(inputText)
	end, true)
end

M.TurnToBrightAdjust = function()
	gPanelManager:CheckShow(gPanelId.S_SETTING_BRIGHT_ADJUST)
end

M.SetOnlineSignalCircle = function()
	gPanelManager:CheckShow(gPanelId.ONLINE_SIGNAL_CIRCLE_FULL_SCREEN_PANEL)
end

M.TurnToRebindGamepad = function(self)
	gPanelManager:CheckShow(gPanelId.SETTING_BTN_RESET_PANEL_CONTROLLER)
end

M.ResetDisplay = function()
	gameProfile.displayLevel = defaultProfile.displayLevel
end

M.ResetPCResolutionFullMode = function()
	gQualityManager:SetPCScreenIsFull(defaultProfile.pcResolutionIsFullScreen)
end

M.ResetPCResolution = function()
	this.SettingData = {
		value = 1
	}

	M.SetPCResolution()
end

M.ResetResolutionScreen = function()
	this.SettingData = {
		value = gQualityManager:ConvertLevelForDisplay(defaultProfile.resolutionScreen)
	}

	M.SetResolutionScreen()
end

M.ResetCameraMotionBlurIntensity = function()
	gameProfile.cameraMotionBlurIntensity = defaultProfile.cameraMotionBlurIntensity

	gCS.CameraDataMgr.cameraEffectController:ResetMotionBlurByProfile()
end

M.ResetPowerSavingMode = function()
	gameProfile.powerSavingMode = true
end

M.ResetCharMotionInviteNotDisturb = function()
	gameProfile.isCharMotionInviteNotDisturb = gCharMotionUtils.CheckInviteNotDisturb()
end

M.ResetSoloAllowTeamInvite = function()
	gameProfile.soloAllowTeamInvite = true
end

M.ResetSoloAllowLinkInvite = function()
	gameProfile.soloAllowLinkInvite = true
end

M.ResetSoloAllowGameplayInvite = function()
	gameProfile.soloAllowGameplayInvite = true
end

M.ResetAllVolumeSliderValue = function()
	this.SettingData = {
		value = defaultProfile.isAllVolumeOn
	}
	gameProfile.allVolume = defaultProfile.allVolume

	M.SaveAllVolumeIsOn()
end

M.ResetMusicSliderValue = function()
	this.SettingData = {
		value = defaultProfile.isBgmVolumeOn
	}
	gameProfile.bgmVolume = defaultProfile.bgmVolume

	M.SaveMusicIsOn()
end

M.ResetEffectSliderValue = function()
	this.SettingData = {
		value = defaultProfile.isSoundEffectOn
	}
	gameProfile.effectVolume = defaultProfile.effectVolume

	M.SaveEffectIsOn()
end

M.ResetFightTalkSliderValue = function()
	this.SettingData = {
		value = defaultProfile.isFightTalkOn
	}

	M.SaveFightTalkIsOn()
end

M.ResetLanguage = function()
	this.SettingData = {
		value = defaultProfile.language
	}

	M.SetLanguage()
end

M.ResetVoiceLanguage = function()
	this.SettingData = {
		value = defaultProfile.voiceLanguage
	}

	M.SetVoiceLanguage()
end

M.ResetAdaptableSize = function()
	this.SettingData = {
		value = gQualityManager:ConvertLevelForDisplay(defaultProfile.adaptableSize)
	}

	M.SetAdaptableSize()
end

M.ResetMotionLevel = function()
	gameProfile.MotionLevel = defaultProfile.motionLevel
end

M.ResetIsDialogTyperOn = function()
	gameProfile.isDialogTyperOn = defaultProfile.isDialogTyperOn
end

M.ResetIsShowBubble = function()
	gameProfile.isShowBubble = defaultProfile.isShowBubble
end

M.ResetIsShowZhanlingBubble = function()
	gameProfile.isShowZhanlingBubble = defaultProfile.isShowZhanlingBubble
end

M.ResetShowUniqueSkillAnimation = function()
	gameProfile.ShowUniqueSkillAnimation = defaultProfile.ShowUniqueSkillAnimation
end

M.ResetIsVibrating = function()
	gameProfile.isVibrating = defaultProfile.isVibrating
end

M.ResetSwitchShoulderFire = function()
	gameProfile.isClickSwitchShoulderFire = defaultProfile.isClickSwitchShoulderFire
end

M.ResetBattlePeaceMode = function()
	gameProfile.isBattlePeaceMode = defaultProfile.isBattlePeaceMode
end

M.ResetBattlePeaceModeOnline = function()
	gameProfile.isBattlePeaceModeOnline = defaultProfile.isBattlePeaceModeOnline
end

M.ResetBoxingGloveVisible = function()
	gameProfile.isBoxingGloveVisible = defaultProfile.isBoxingGloveVisible
end

M.ResetAuxiliaryCombat = function()
	gameProfile.auxiliaryCombatMode = defaultProfile.auxiliaryCombatMode
end

M.ResetAuxiliaryAimModeMobile = function()
	gameProfile.auxiliaryAimModeMobile = defaultProfile.auxiliaryAimModeMobile
end

M.ResetAuxiliaryAimModeMouse = function()
	gameProfile.auxiliaryAimModeMouse = defaultProfile.auxiliaryAimModeMouse
end

M.ResetAuxiliaryAimModeGamepad = function()
	gameProfile.auxiliaryAimModeGamepad = defaultProfile.auxiliaryAimModeGamepad
end

M.ResetCameraRotateSensitivity = function()
	gameProfile.cameraRotateXLevel = defaultProfile.cameraRotateXLevel
end

M.ResetCameraRotateYSensitivity = function()
	gameProfile.cameraRotateYLevel = defaultProfile.cameraRotateYLevel
end

M.ResetSwingCameraRotateSensitivity = function()
	gameProfile.swingCameraRotateXLevel = defaultProfile.swingCameraRotateXLevel
end

M.ResetSwingCameraRotateYSensitivity = function()
	gameProfile.swingCameraRotateYLevel = defaultProfile.swingCameraRotateYLevel
end

M.ResetVehicleShotCameraRotateSensitivity = function()
	gameProfile.vehicleShotCameraRotateXLevel = defaultProfile.vehicleShotCameraRotateXLevel
end

M.ResetVehicleShotCameraRotateYSensitivity = function()
	gameProfile.vehicleShotCameraRotateYLevel = defaultProfile.vehicleShotCameraRotateYLevel
end

M.ResetShotGlobalCameraRotateSensitivity = function()
	gameProfile.shotGlobalCameraRotateLevel = defaultProfile.shotGlobalCameraRotateLevel
end

M.ResetShotFireCameraRotateXSensitivity = function()
	gameProfile.shotFireCameraRotateXLevel = defaultProfile.shotFireCameraRotateXLevel
end

M.ResetShotFireCameraRotateYSensitivity = function()
	gameProfile.shotFireCameraRotateYLevel = defaultProfile.shotFireCameraRotateYLevel
end

M.ResetShotNotFireCameraRotateXSensitivity = function()
	gameProfile.shotNotFireCameraRotateXLevel = defaultProfile.shotNotFireCameraRotateXLevel
end

M.ResetShotNotFireCameraRotateYSensitivity = function()
	gameProfile.shotNotFireCameraRotateYLevel = defaultProfile.shotNotFireCameraRotateYLevel
end

M.ResetShotOpenLensFireCameraRotateXSensitivity = function()
	gameProfile.shotOpenLensFireCameraRotateXLevel = defaultProfile.shotOpenLensFireCameraRotateXLevel
end

M.ResetShotOpenLensFireCameraRotateYSensitivity = function()
	gameProfile.shotOpenLensFireCameraRotateYLevel = defaultProfile.shotOpenLensFireCameraRotateYLevel
end

M.ResetShotOpenLensNotFireCameraRotateXSensitivity = function()
	gameProfile.shotOpenLensNotFireCameraRotateXLevel = defaultProfile.shotOpenLensNotFireCameraRotateXLevel
end

M.ResetShotOpenLensNotFireCameraRotateYSensitivity = function()
	gameProfile.shotOpenLensNotFireCameraRotateYLevel = defaultProfile.shotOpenLensNotFireCameraRotateYLevel
end

M.ResetVehicleShotFireCameraRotateXSensitivity = function()
	gameProfile.vehicleShotFireCameraRotateXLevel = defaultProfile.vehicleShotFireCameraRotateXLevel
end

M.ResetVehicleShotFireCameraRotateYSensitivity = function()
	gameProfile.vehicleShotFireCameraRotateYLevel = defaultProfile.vehicleShotFireCameraRotateYLevel
end

M.ResetVehicleShotNotFireCameraRotateXSensitivity = function()
	gameProfile.vehicleShotNotFireCameraRotateXLevel = defaultProfile.vehicleShotNotFireCameraRotateXLevel
end

M.ResetVehicleShotNotFireCameraRotateYSensitivity = function()
	gameProfile.vehicleShotNotFireCameraRotateYLevel = defaultProfile.vehicleShotNotFireCameraRotateYLevel
end

M.ResetVehicleShotOpenLensNotFireCameraRotateXSensitivity = function()
	gameProfile.vehicleShotOpenLensNotFireCameraRotateXLevel = defaultProfile.vehicleShotOpenLensNotFireCameraRotateXLevel
end

M.ResetVehicleShotOpenLensNotFireCameraRotateYSensitivity = function()
	gameProfile.vehicleShotOpenLensNotFireCameraRotateYLevel = defaultProfile.vehicleShotOpenLensNotFireCameraRotateYLevel
end

M.ResetVehicleShotOpenLensFireCameraRotateXSensitivity = function()
	gameProfile.vehicleShotOpenLensFireCameraRotateXLevel = defaultProfile.vehicleShotOpenLensFireCameraRotateXLevel
end

M.ResetVehicleShotOpenLensFireCameraRotateYSensitivity = function()
	gameProfile.vehicleShotOpenLensFireCameraRotateYLevel = defaultProfile.vehicleShotOpenLensFireCameraRotateYLevel
end

M.ResetVehicleCameraRotateSensitivity = function()
	gameProfile.vehicleCameraRotateXLevel = defaultProfile.vehicleCameraRotateXLevel
end

M.ResetVehicleCameraRotateYSensitivity = function()
	gameProfile.vehicleCameraRotateYLevel = defaultProfile.vehicleCameraRotateYLevel
end

M.ResetVehicleSteerSensitivity = function()
	gameProfile.vehicleSteerSpeedLevel = defaultProfile.vehicleSteerSpeedLevel
end

M.ResetHelicopterSimpleDriveMode = function()
	gameProfile.helicopterSimpleDriveMode = defaultProfile.helicopterSimpleDriveMode
end

M.ResetSwingCameraItensity = function()
	gameProfile.swingCameraItensity = defaultProfile.swingCameraItensity
end

M.ResetInverseCamInputX = function()
	gameProfile.inverseCamInputX = defaultProfile.inverseCamInputX
end

M.ResetInverseCamInputY = function()
	gameProfile.inverseCamInputY = defaultProfile.inverseCamInputY
end

M.ResetLockTargetCameraOn = function()
	gameProfile.isLockTargetCameraOn = defaultProfile.isLockTargetCameraOn
end

M.ResetMotionLevel = function()
	gameProfile.MotionLevel = defaultProfile.motionLevel
end

M.ResetMotionStrengthSliderValue = function()
	gameProfile.motionStrength = defaultProfile.motionStrength
end

M.ResetHandleSpeakerIsOn = function()
	gameProfile.isHandleSpeakerOn = defaultProfile.isHandleSpeakerOn
	gameProfile.handleSpeakerValue = defaultProfile.handleSpeakerValue
end

M.ResetMuteWhenUnfocused = function()
	gameProfile.muteWhenUnfocused = defaultProfile.muteWhenUnfocused
end

M.ResetHandleSpeakerOutput = function()
	gameProfile.handleSpeakerOutputId = defaultProfile.handleSpeakerOutputId
end

M.ResetSoundNumberLevel = function()
	gameProfile.soundNumberLevel = defaultProfile.soundNumberLevel
end

M.ResetShowPlayerName = function()
	slot0 = gClientToGameDelegate

	slot0:AskChangeRoleUseSystemName(false).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gCS.MyPlayerManager.PlayerInfo.UsePlayerName = true
		gPlayerManager.infoLogin.bindData.UsePlayerName = true

		gSpiritManager:RefreshMainSpiritName()
	end
end

M.ResetAntidinicMode = function()
	gameProfile.isAntidinicMode = defaultProfile.isAntidinicMode

	if gameProfile.isAntidinicMode then
		gPanelManager:CheckShow(gPanelId.S_CROSS_HAIR_ANTI_GLARE)
	else
		gPanelManager:Close(gPanelId.S_CROSS_HAIR_ANTI_GLARE)
	end
end

M.ResetAntidinicModeAll = function()
	gameProfile.isAntidinicModeAll = defaultProfile.isAntidinicModeAll
end

M.ResetExchangeWingSuit = function()
	gameProfile.isExchangeWingSuit = defaultProfile.isExchangeWingSuit
end

M.ResetMobileButtonTextNum = function()
	gameProfile.mobileButtonTextNum = defaultProfile.mobileButtonTextNum

	gStoreButtonMgr:InitBtnTextVisible()
end

M.ResetSafeAreaOffset = function()
	gameProfile.safeAreaOffset = defaultProfile.safeAreaOffset
end

M.ResetControllerSetting = function()
	gameProfile.isCustomizeController = defaultProfile.isCustomizeController
end

M.ResetMicrophoneMode = function()
	gameProfile.microphoneMode = defaultProfile.microphoneMode
end

M.ResetCCVoiceListeningVolume = function()
	gameProfile.ccVoiceListeningVolume = defaultProfile.ccVoiceListeningVolume
end

M.ResetCCVoiceMicVolume = function()
	gameProfile.ccVoiceMicVolume = defaultProfile.ccVoiceMicVolume
end

M.ResetSwapConfirmAndCancel = function()
	gameProfile.swapConfirmCancel = defaultProfile.swapConfirmCancel
end

M.ResetSwapL3AndR3 = function()
	gameProfile.swapL3R3 = defaultProfile.swapL3R3
end

M.ResetGyroControllerEnable = function()
	gameProfile.isEnableGyroSensitivity = defaultProfile.isEnableGyroSensitivity
end

M.ResetShootGyroControllerSensitivity = function()
	gameProfile.cameraGyroSensitivity = defaultProfile.cameraGyroSensitivity
end

M.ResetVedioMemoryLoadMsg = function()
	gameProfile.showVideoMemoryMsg = defaultProfile.showVideoMemoryMsg
end

M.ResetVehicleStuntsCamera = function()
	gameProfile.isAllowVehicleStuntsCamera = defaultProfile.isAllowVehicleStuntsCamera
end

M.ResetControllerUlt = function()
	gameProfile.isUltButtonToR2 = defaultProfile.isUltButtonToR2
end

M.ResetJoystickPositionMode = function()
	gameProfile.joystickPositionMode = defaultProfile.joystickPositionMode
	LX6.GUI.GuiMgr.Instance.sguiJoystick.isDynamic = gameProfile.joystickPositionMode ~= 1
end

M.SetCutsceneFashionMode = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.cutsceneFashionMode = data.value
	end
end

M.ResetCutsceneFashionMode = function()
	gameProfile.cutsceneFashionMode = defaultProfile.cutsceneFashionMode
end

M.SetServerValue = function(data)
	data = data or this.SettingData

	if not data then
		return
	end

	local key = data.serverSettingId or data.serverMemoryKey

	if not key or not gSettingServerManager then
		return
	end

	if data.templateIndex == nil and data.parentId then
		gSettingServerManager:SetTemplate11Value(data.parentId, key, data.valueType or "number", data.value)
	else
		gSettingServerManager:SetValue(key, data.valueType or "number", data.value)
	end
end

M.ResetServerValue = function(data)
	data = data or this.SettingData

	if not data then
		return
	end

	local key = data.serverSettingId or data.serverMemoryKey

	if not key or not gSettingServerManager then
		return
	end

	if data.templateIndex == nil and data.parentId then
		gSettingServerManager:ResetTemplate11Value(data.parentId, key)
	else
		gSettingServerManager:ResetValue(key)
	end
end

M.SetVoiceCallPinyin = function()
	local data = this.SettingData

	if not data then
		return
	end

	gameProfile.voiceCallPinyinData = data.value

	if not string.is_null_or_empty(data.value) then
		local jsonData = json.decode(data.value)

		if jsonData then
			gameProfile.voiceCallPinyinLabelData = json.encode(jsonData.label)
		end
	end

	gCS.AIDialogVoiceManager:ClearPreviewCache()
end

M.ResetVoiceCallPinyin = function()
	gameProfile.voiceCallPinyinData = defaultProfile.voiceCallPinyinData
	gameProfile.voiceCallPinyinLabelData = defaultProfile.voiceCallPinyinLabelData
end

M.SetVoiceCallEnabled = function(data)
	data = data or this.SettingData

	if not data then
		return
	end

	gameProfile.isVoiceCallEnabled = data.value ~= 1
end

M.ResetVoiceCallEnabled = function()
	gameProfile.isVoiceCallEnabled = defaultProfile.isVoiceCallEnabled
end

M.SetPSOnlySetting = function()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local isOn = data.value ~= 1

		if _G.gLinkManager.isPSNOnly ~= isOn then
			return
		end

		gClientToGameDelegate:SetPSNOnly(isOn)

		_G.gLinkManager.isPSNOnly = isOn
	end
end

M.ReloadAllProfile = function()
	gameProfile = ProfileManager.gameProfile
end

return SettingsScriptFunc
