local ProfileManager = LX6.Engine.ProfileManager
local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local ShezhiPanelLanguagesConfig = LTConfig.ShezhiPanelLanguagesConfig
local MessageConfig = LTConfig.MessageConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local ConstConfig = LX6.Manager.ConstConfig
local gameProfile = ProfileManager.gameProfile
local defaultProfile = ProfileManager.defaultProfile
local languageProfile = ProfileManager.languageProfile
local DeviceDisplayLevel = LX6.Quality.DeviceDisplayLevel
local SettingsScriptFunc = {}
local M = SettingsScriptFunc
local this = SettingsScriptFunc

function M.Lock()
	gPanelManager:CheckShow(gPanelId.V3_MESSAGE_WARNING, {
		des = LTConfig.TextScriptTextConfig.GetConfig(89900581).Text
	})
end

function M.GetAliasings()
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

function M.SetGamePadShowIcon(num)
	local data = this.SettingData

	if data then
		gMessageManager:SendMessage(gEventConstants.SETTING_SEND_GAMEPAD_SHOW_ICON, {
			fatherId = data.fatherId,
			showIconButtonId = num
		})
	end
end

function M.SaveMotionStrengthSliderValue()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.motionStrength = data.value
	end
end

function M.SaveAllVolumeSliderValue()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.allVolume = data.value / 100
	end
end

function M.SaveAllVolumeIsOn()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isAllVolumeOn = data.value
	end
end

function M.SaveMusicSliderValue()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.bgmVolume = data.value / 100
	end
end

function M.SaveMusicIsOn()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isBgmVolumeOn = data.value
	end
end

function M.SaveEffectSliderValue()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.effectVolume = data.value / 100
	end
end

function M.SaveEffectIsOn()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isSoundEffectOn = data.value
	end
end

function M.SaveFightTalkSliderValue()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.fightTalkVolume = data.value / 100
	end
end

function M.SaveFightTalkIsOn()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isFightTalkOn = data.value
	end
end

function M.SetDisplayLevel()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local displayLevel = data.value
		local isMobile = gCS.LuaUtils.IsOnAndroid or gCS.LuaUtils.IsOnIOS or gQualityManager:IsInEditorAndroidPlatform() or gQualityManager:IsInEditorIOSPlatform()

		if data.value == 5 then
			if not isMobile then
				data.value = ShezhiPanelConfig.CustomLevel.pcLevel
			end
		end

		if not isMobile then
			displayLevel = math.max(displayLevel, DeviceDisplayLevel.Ultra)
		else
			displayLevel = math.max(displayLevel, DeviceDisplayLevel.Movie)
		end

		if gameProfile.displayLevel ~= displayLevel then
			gameProfile.displayLevel = displayLevel
			local recommendLevel = gQualityManager.DeviceQuality

			gQualityManager:LoadQualityData(recommendLevel, displayLevel)

			if displayLevel ~= gQualityManager:GetCustomLevel() then
				gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
				gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_CHAR_MESH)
			end
		end
	end
end

function M.SetPCResolution()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) and not table.isNilOrEmpty(gQualityManager.PCName) then
		gQualityManager:ChangePCResolution(data.value)
	end
end

function M.SetPCResolutionFullMode()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) and not table.isNilOrEmpty(gQualityManager.PCName) then
		gQualityManager:SetPCScreenIsFull(data.value)
	end
end

function M.SetResolutionScreen()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeResolutionScreen(data.value)
	end
end

function M:SetAdaptableSize()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:SetAdaptableSize(data.value)
	end
end

function M.SetFps()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local fps = this.GetFpsByType(data.value)

		gQualityManager:ChangeFPS(fps)

		if gameProfile.vSync then
			gQualityManager:ChangeVSync(gameProfile.vSync)
		end
	end
end

function M.SetPCDisplayIndex()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:SetPCDisplayIndex(data.value)
	end
end

function M.GetFpsByType(type)
	return ShezhiPanelConfig.NormalFps[type]
end

function M.SetResolutionShadow()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeResolutionShadow(data.value)
	end
end

function M.SetPostProcess()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangePostProcess(data.value)
	end
end

function M.SetAntiAliasing()
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

function M.SetAntiAliasingQuality()
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

function M.SetAntiAliasingLevel()
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

function M.SetFrameGen()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local frameGenerations = gQualityManager:GetFrameGenerationQuality()

		if not table.isNilOrEmpty(frameGenerations) and frameGenerations[data.value] then
			gQualityManager:ChangeFrameGeneration(frameGenerations[data.value])
			gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
		else
			print_error("SetFrameGen error  value = " .. data.value)
		end
	end
end

function M.SetvSync()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local isOn = data.value == 1

		gQualityManager:ChangeVSync(isOn)
	end
end

function M.CheckvSync()
	return gameProfile.frameGeneration == 1
end

function M.SetSSR()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local isOn = data.value == 1

		gQualityManager:SetSSROn(isOn)
	end
end

function M.SetRaytracing()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local isOn = data.value == 1

		gQualityManager:SetRaytracing(isOn)
	end
end

function M.SetSceneCount()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeSceneCount(data.value)
	end
end

function M.SetSceneMat()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeSceneMat(data.value)
	end
end

function M.SetCharMeshTex()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeCharMeshTex(data.value)
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_CHAR_MESH)
	end
end

function M.SetEffect()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeEffect(data.value)
	end
end

function M.SetMatQuality()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeMatLevel(data.value)
	end
end

function M.SetCharCount()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeCharCount(data.value)
	end
end

function M.SetVehicleCount()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeVehicleCount(data.value)
	end
end

function M.SetCutsceneLevel()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gQualityManager:ChangeCutsceneLevel(data.value)
	end
end

function M.SetIsDialogTyperOn()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local isOn = data.value == 1
		gameProfile.isDialogTyperOn = isOn
	end
end

function M.SetShotGlobalCameraRotateSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotGlobalCameraRotateLevel = value

		ProfileManager.SaveGameProperty()
	end
end

function M.SetCameraRotateSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.cameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.cameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetShotFireCameraRotateXSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetShotFireCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetShotNotFireCameraRotateXSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotNotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetShotNotFireCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotNotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetShotOpenLensFireCameraRotateXSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotOpenLensFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetShotOpenLensFireCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotOpenLensFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetShotOpenLensNotFireCameraRotateXSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotOpenLensNotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetShotOpenLensNotFireCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.shotOpenLensNotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleShotFireCameraRotateXSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleShotFireCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleShotNotFireCameraRotateXSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotNotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleShotNotFireCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotNotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleShotOpenLensFireCameraRotateXSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotOpenLensFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleShotOpenLensFireCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotOpenLensFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleShotOpenLensNotFireCameraRotateXSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotOpenLensNotFireCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleShotOpenLensNotFireCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleShotOpenLensNotFireCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetSwingCameraRotateSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.swingCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetSwingCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.swingCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleCameraRotateSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleCameraRotateXLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetVehicleCameraRotateYSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleCameraRotateYLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SwingCameraItensity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.swingCameraItensity = Mathf.Clamp(value, 1, 10)

		gQualityManager:ReplyAntiDinicMode()
		ProfileManager.SaveGameProperty()
	end
end

function M.SetLensDistortionIntensity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.lensDistortionIntensity = Mathf.Clamp(value, 0, 10)

		gQualityManager:ReplyAntiDinicMode()
		ProfileManager.SaveGameProperty()
	end
end

function M.ResetLensDistortionIntensity()
	gameProfile.lensDistortionIntensity = defaultProfile.lensDistortionIntensity
end

function M.SetCameraMotionBlurIntensity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.cameraMotionBlurIntensity = Mathf.Clamp(value, 0, 10)

		gQualityManager:ReplyAntiDinicMode()
		ProfileManager.SaveGameProperty()
		gCS.CameraDataMgr.cameraEffectController:ResetMotionBlurByProfile()
	end
end

function M.SetInverseCamInputX()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local inverse = data.value == 1
		gameProfile.inverseCamInputX = inverse

		ProfileManager.SaveGameProperty()
	end
end

function M.SetInverseCamInputY()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local inverse = data.value == 1
		gameProfile.inverseCamInputY = inverse

		ProfileManager.SaveGameProperty()
	end
end

function M.SetLockTargetCameraOn()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isLockTargetCameraOn = data.value == 1
	end
end

function M._RealSetLanguage(index)
	local lang = ShezhiPanelConfig.LanguagesDisplay[index]
	local curLang = LTConfig.TableGetLanguage()

	if curLang ~= lang then
		local cfg = ShezhiPanelLanguagesConfig.GetConfig(index)

		if cfg then
			SGUI.UIConfig.instance:SetLanguage(lang)
		end

		LTConfig.TableSetLanguage(lang)
		LTConfig.ChangeLang()
		LX6.Translation.TranslationUtils.OnLanguageChange()

		languageProfile.textLanguage = index

		ProfileManager.SaveLanguageProperty()
		gMessageManager:SendMessage(gEventConstants.LANGUAGE_CHANGE, lang)
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS, {
			banShowTips = true,
			refreshToTop = true
		})
		LX6.Manager.LocalizeManager.Instance:SetImageLocalize()
	end
end

function M.SetLanguage()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		M._RealSetLanguage(data.value)
	end
end

function M.SetVoiceLanguage()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local voiceLang = ShezhiPanelConfig.VoiceLanguagesDisplay[data.value]

		gSoundMgr:SetVoiceLanguage(voiceLang)

		languageProfile.voiceLanguage = data.value

		ProfileManager.SaveLanguageProperty()
	end
end

function M.SetMotionLevel()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local stateValue = gSoundMgr.GameStateGroup.MotionGrade.All

		if data.value == 1 then
			stateValue = gSoundMgr.GameStateGroup.MotionGrade.All
		elseif data.value == 2 then
			stateValue = gSoundMgr.GameStateGroup.MotionGrade.Part
		else
			stateValue = gSoundMgr.GameStateGroup.MotionGrade.None
		end

		gSoundMgr:SetStateValue(gSoundMgr.GameStateGroup.MotionGrade.StateName, stateValue)

		gameProfile.motionLevel = data.value
	end
end

function M.SaveHandleSpeakerIsOn()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isHandleSpeakerOn = data.value
	end
end

function M.SetHandleSpeakerOutput()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.handleSpeakerOutputId = data.value
	end
end

function M.SaveHandleSpeakerVolume()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.handleSpeakerValue = data.value / 100
	end
end

function M.SetSoundNumberLevel()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.soundNumberLevel = data.value
	end
end

function M.SetIsShowBubble()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isShowBubble = data.value == 1
	end
end

function M.SetIsShowZhanlingBubble()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isShowZhanlingBubble = data.value == 1
	end
end

function M.SetShowUniqueSkillAnimation()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.ShowUniqueSkillAnimation = data.value == 1
	end
end

function M.SetIsVibrating()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isVibrating = data.value == 1
	end
end

function M.SetVehicleSteerSensitivity()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		local value = data.value
		gameProfile.vehicleSteerSpeedLevel = Mathf.Clamp(value, 1, 100)

		ProfileManager.SaveGameProperty()
	end
end

function M.SetSwitchShoulderFire()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isClickSwitchShoulderFire = data.value == 2
	end
end

function M.SetBattlePeaceMode()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isBattlePeaceMode = data.value == 1
	end
end

function M.SetShowPlayerName()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isUsePlayerName = data.value == 1

		gSpiritManager:RefreshMainSpiritName()
		ProfileManager.SaveGameProperty()
	end
end

function M.SetPowerSavingMode()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.powerSavingMode = data.value == 1
	end
end

function M.SetMobileControlMode()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gCS.PanelManager.Instance.IsMobileMode = not data.value == 1

		ProfileManager.SaveGameProperty()
		ProfileManager.SaveDevProperty()
		ProfileManager.SaveLanguageProperty()
		gLoginManager:DoKickToLogin()
	end
end

function M.SetCharMotionInviteNotDisturb()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gCharMotionUtils.SetInviteNotDisturb(function ()
			gameProfile.isCharMotionInviteNotDisturb = gCharMotionUtils.CheckInviteNotDisturb()
		end)
	end
end

function M.SetAntidinicMode()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isAntidinicMode = data.value == 1

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

function M.SetAntidinicModeAll()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		if data.value == 1 then
			gDisplayMessageMgr:ShowMessage(MessageConfig.Setting_MotionSicknessPrevention, function ()
				gQualityManager:_RealSetAntidinicModeAll(true)
			end, function ()
				gQualityManager:ReplyAntiDinicMode()
			end)
		else
			gQualityManager:_RealSetAntidinicModeAll(false)
		end
	end
end

function M:SetVehicleOprMode()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isVehicleJoystickMode = data.value
		local modeTextId = data.value and 89901270 or 89901269
		local message = gString.Format(TextScriptTextConfig.GetConfig(89901268).Text, TextScriptTextConfig.GetConfig(modeTextId).Text)

		gDisplayMessageMgr:ShowMessageContent(message)
		gMessageManager:SendMessage(gEventConstants.SETTING_SEND_VEHICLE_MODE, data.value)
	end
end

function M:SetExchangeWingSuit()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		gameProfile.isExchangeWingSuit = data.value == 1
	end
end

function M:SetMobileGamepadMode()
	local data = this.SettingData

	if not table.isNilOrEmpty(data) then
		if data.value == 1 then
			M.CheckIsMobileControllerOn()
		else
			gameProfile.mobileControlMode = false

			ProfileManager.SaveGameProperty()
			ProfileManager.SaveDevProperty()
			ProfileManager.SaveLanguageProperty()
			SGUI.UIConfig.instance:SetAdaptationPlatform(SGUI.EPlatform.Mobile)

			gCS.PanelManager.Instance.IsMobileMode = true

			if LX6.GUI.GuiMgr.Instance.sguiJoystick == nil then
				LX6.GUI.GuiMgr.Instance.sguiJoystick:ShowJoystickUI(true)
			end

			SGUI.InputActionBind.fixedGameDevice = SGUI.GameDevice.KeyboardMouse

			gLoginManager:DoKickToLogin(nil, nil, true)
		end
	end
end

function M.CheckIsMobileControllerOn()
	if gCoreHudUIManager.isEnterController then
		gameProfile.mobileControlMode = true

		ProfileManager.SaveGameProperty()
		ProfileManager.SaveDevProperty()
		ProfileManager.SaveLanguageProperty()
		SGUI.UIConfig.instance:SetAdaptationPlatform(SGUI.EPlatform.Console)

		gCS.PanelManager.Instance.IsMobileMode = false

		if LX6.GUI.GuiMgr.Instance.sguiJoystick ~= nil then
			LX6.GUI.GuiMgr.Instance.sguiJoystick:ShowJoystickUI(false)
		end

		SGUI.InputActionBind.fixedGameDevice = SGUI.GameDevice.PlayStation

		gLoginManager:DoKickToLogin(nil, nil, true)
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.MoblieNoController)
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
	end
end

function M.TurnToSelectedPersonalInfo()
	UniSDKManager.ShowSelectedPersonalInfo()
end

function M.TurnToSharedPersonalInfo()
	UniSDKManager.ShowPolicyInfo(ConstConfig.GetConfig(ConstConfig.SharedPersonalInfo))
end

function M.TurnToPrivatePolicy()
	UniSDKManager.ShowPolicyInfo(ConstConfig.GetConfig(ConstConfig.PrivatePolicy))
end

function M.TurnToUserCenter()
	gCS.LoginManager:OpenUserCenter()
end

function M.ResetDisplay()
	gameProfile.displayLevel = defaultProfile.displayLevel
end

function M.ResetPCResolutionFullMode()
	gQualityManager:SetPCScreenIsFull(defaultProfile.pcResolutionIsFullScreen)
end

function M.ResetPCResolution()
	this.SettingData = {
		value = 1
	}

	M.SetPCResolution()
end

function M.ResetResolutionScreen()
	this.SettingData = {
		value = gQualityManager:ConvertLevelForDisplay(defaultProfile.resolutionScreen)
	}

	M.SetResolutionScreen()
end

function M.ResetCameraMotionBlurIntensity()
	gameProfile.cameraMotionBlurIntensity = defaultProfile.cameraMotionBlurIntensity

	gCS.CameraDataMgr.cameraEffectController:ResetMotionBlurByProfile()
end

function M.ResetPowerSavingMode()
	gameProfile.powerSavingMode = false
end

function M.ResetCharMotionInviteNotDisturb()
	gameProfile.isCharMotionInviteNotDisturb = gCharMotionUtils.CheckInviteNotDisturb()
end

function M.ResetAllVolumeSliderValue()
	this.SettingData = {
		value = defaultProfile.isAllVolumeOn
	}
	gameProfile.allVolume = defaultProfile.allVolume

	M.SaveAllVolumeIsOn()
end

function M.ResetMusicSliderValue()
	this.SettingData = {
		value = defaultProfile.isBgmVolumeOn
	}
	gameProfile.bgmVolume = defaultProfile.bgmVolume

	M.SaveMusicIsOn()
end

function M.ResetEffectSliderValue()
	this.SettingData = {
		value = defaultProfile.isSoundEffectOn
	}
	gameProfile.effectVolume = defaultProfile.effectVolume

	M.SaveEffectIsOn()
end

function M.ResetFightTalkSliderValue()
	this.SettingData = {
		value = defaultProfile.isFightTalkOn
	}

	M.SaveFightTalkIsOn()
end

function M.ResetLanguage()
	this.SettingData = {
		value = defaultProfile.language
	}

	M.SetLanguage()
end

function M.ResetVoiceLanguage()
	this.SettingData = {
		value = defaultProfile.voiceLanguage
	}

	M.SetVoiceLanguage()
end

function M.ResetAdaptableSize()
	this.SettingData = {
		value = gQualityManager:ConvertLevelForDisplay(defaultProfile.adaptableSize)
	}

	M.SetAdaptableSize()
end

function M.ResetMotionLevel()
	gameProfile.motionLevel = defaultProfile.motionLevel
end

function M.ResetIsDialogTyperOn()
	gameProfile.isDialogTyperOn = defaultProfile.isDialogTyperOn
end

function M.ResetIsShowBubble()
	gameProfile.isShowBubble = defaultProfile.isShowBubble
end

function M.ResetIsShowZhanlingBubble()
	gameProfile.isShowZhanlingBubble = defaultProfile.isShowZhanlingBubble
end

function M.ResetShowUniqueSkillAnimation()
	gameProfile.ShowUniqueSkillAnimation = defaultProfile.ShowUniqueSkillAnimation
end

function M.ResetIsVibrating()
	gameProfile.isVibrating = defaultProfile.isVibrating
end

function M.ResetSwitchShoulderFire()
	gameProfile.isClickSwitchShoulderFire = defaultProfile.isClickSwitchShoulderFire
end

function M.ResetBattlePeaceMode()
	gameProfile.isBattlePeaceMode = defaultProfile.isBattlePeaceMode
end

function M.ResetCameraRotateSensitivity()
	gameProfile.cameraRotateXLevel = defaultProfile.cameraRotateXLevel
end

function M.ResetCameraRotateYSensitivity()
	gameProfile.cameraRotateYLevel = defaultProfile.cameraRotateYLevel
end

function M.ResetSwingCameraRotateSensitivity()
	gameProfile.swingCameraRotateXLevel = defaultProfile.swingCameraRotateXLevel
end

function M.ResetSwingCameraRotateYSensitivity()
	gameProfile.swingCameraRotateYLevel = defaultProfile.swingCameraRotateYLevel
end

function M.ResetShotCameraRotateSensitivity()
	gameProfile.shotCameraRotateXLevel = defaultProfile.shotCameraRotateXLevel
end

function M.ResetShotCameraRotateYSensitivity()
	gameProfile.shotCameraRotateYLevel = defaultProfile.shotCameraRotateYLevel
end

function M.ResetShotCameraOpenLensRotateSensitivity()
	gameProfile.shotCameraOpenLensRotateXLevel = defaultProfile.shotCameraOpenLensRotateXLevel
end

function M.ResetShotCameraOpenLensRotateYSensitivity()
	gameProfile.shotCameraOpenLensRotateYLevel = defaultProfile.shotCameraOpenLensRotateYLevel
end

function M.ResetVehicleShotCameraRotateSensitivity()
	gameProfile.vehicleShotCameraRotateXLevel = defaultProfile.vehicleShotCameraRotateXLevel
end

function M.ResetVehicleShotCameraRotateYSensitivity()
	gameProfile.vehicleShotCameraRotateYLevel = defaultProfile.vehicleShotCameraRotateYLevel
end

function M.ResetShotGlobalCameraRotateSensitivity()
	gameProfile.shotGlobalCameraRotateLevel = defaultProfile.shotGlobalCameraRotateLevel
end

function M.ResetShotFireCameraRotateXSensitivity()
	gameProfile.shotFireCameraRotateXLevel = defaultProfile.shotFireCameraRotateXLevel
end

function M.ResetShotFireCameraRotateYSensitivity()
	gameProfile.shotFireCameraRotateYLevel = defaultProfile.shotFireCameraRotateYLevel
end

function M.ResetShotNotFireCameraRotateXSensitivity()
	gameProfile.shotNotFireCameraRotateXLevel = defaultProfile.shotNotFireCameraRotateXLevel
end

function M.ResetShotNotFireCameraRotateYSensitivity()
	gameProfile.shotNotFireCameraRotateYLevel = defaultProfile.shotNotFireCameraRotateYLevel
end

function M.ResetShotOpenLensFireCameraRotateXSensitivity()
	gameProfile.shotOpenLensFireCameraRotateXLevel = defaultProfile.shotOpenLensFireCameraRotateXLevel
end

function M.ResetShotOpenLensFireCameraRotateYSensitivity()
	gameProfile.shotOpenLensFireCameraRotateYLevel = defaultProfile.shotOpenLensFireCameraRotateYLevel
end

function M.ResetShotOpenLensNotFireCameraRotateXSensitivity()
	gameProfile.shotOpenLensNotFireCameraRotateXLevel = defaultProfile.shotOpenLensNotFireCameraRotateXLevel
end

function M.ResetShotOpenLensNotFireCameraRotateYSensitivity()
	gameProfile.shotOpenLensNotFireCameraRotateYLevel = defaultProfile.shotOpenLensNotFireCameraRotateYLevel
end

function M.ResetVehicleShotFireCameraRotateXSensitivity()
	gameProfile.vehicleShotFireCameraRotateXLevel = defaultProfile.vehicleShotFireCameraRotateXLevel
end

function M.ResetVehicleShotFireCameraRotateYSensitivity()
	gameProfile.vehicleShotFireCameraRotateYLevel = defaultProfile.vehicleShotFireCameraRotateYLevel
end

function M.ResetVehicleShotNotFireCameraRotateXSensitivity()
	gameProfile.vehicleShotNotFireCameraRotateXLevel = defaultProfile.vehicleShotNotFireCameraRotateXLevel
end

function M.ResetVehicleShotNotFireCameraRotateYSensitivity()
	gameProfile.vehicleShotNotFireCameraRotateYLevel = defaultProfile.vehicleShotNotFireCameraRotateYLevel
end

function M.ResetVehicleShotOpenLensNotFireCameraRotateXSensitivity()
	gameProfile.vehicleShotOpenLensNotFireCameraRotateXLevel = defaultProfile.vehicleShotOpenLensNotFireCameraRotateXLevel
end

function M.ResetVehicleShotOpenLensNotFireCameraRotateYSensitivity()
	gameProfile.vehicleShotOpenLensNotFireCameraRotateYLevel = defaultProfile.vehicleShotOpenLensNotFireCameraRotateYLevel
end

function M.ResetVehicleShotOpenLensFireCameraRotateXSensitivity()
	gameProfile.vehicleShotOpenLensFireCameraRotateXLevel = defaultProfile.vehicleShotOpenLensFireCameraRotateXLevel
end

function M.ResetVehicleShotOpenLensFireCameraRotateYSensitivity()
	gameProfile.vehicleShotOpenLensFireCameraRotateYLevel = defaultProfile.vehicleShotOpenLensFireCameraRotateYLevel
end

function M.ResetVehicleCameraRotateSensitivity()
	gameProfile.vehicleCameraRotateXLevel = defaultProfile.vehicleCameraRotateXLevel
end

function M.ResetVehicleCameraRotateYSensitivity()
	gameProfile.vehicleCameraRotateYLevel = defaultProfile.vehicleCameraRotateYLevel
end

function M.ResetVehicleSteerSensitivity()
	gameProfile.vehicleSteerSpeedLevel = defaultProfile.vehicleSteerSpeedLevel
end

function M.ResetSwingCameraItensity()
	gameProfile.swingCameraItensity = defaultProfile.swingCameraItensity
end

function M.ResetInverseCamInputX()
	gameProfile.inverseCamInputX = defaultProfile.inverseCamInputX
end

function M.ResetInverseCamInputY()
	gameProfile.inverseCamInputY = defaultProfile.inverseCamInputY
end

function M.ResetLockTargetCameraOn()
	gameProfile.isLockTargetCameraOn = defaultProfile.isLockTargetCameraOn
end

function M.ResetMotionLevel()
	gameProfile.motionLevel = defaultProfile.motionLevel
end

function M.ResetMotionStrengthSliderValue()
	gameProfile.motionStrength = defaultProfile.motionStrength
end

function M.ResetHandleSpeakerIsOn()
	gameProfile.isHandleSpeakerOn = defaultProfile.isHandleSpeakerOn
	gameProfile.handleSpeakerValue = defaultProfile.handleSpeakerValue
end

function M.ResetHandleSpeakerOutput()
	gameProfile.handleSpeakerOutputId = defaultProfile.handleSpeakerOutputId
end

function M.ResetSoundNumberLevel()
	gameProfile.soundNumberLevel = defaultProfile.soundNumberLevel
end

function M.ResetShowPlayerName()
	gameProfile.isUsePlayerName = defaultProfile.isUsePlayerName
end

function M.ResetAntidinicMode()
	gameProfile.isAntidinicMode = defaultProfile.isAntidinicMode

	if gameProfile.isAntidinicMode then
		gPanelManager:CheckShow(gPanelId.S_CROSS_HAIR_ANTI_GLARE)
	else
		gPanelManager:Close(gPanelId.S_CROSS_HAIR_ANTI_GLARE)
	end
end

function M.ResetAntidinicModeAll()
	gameProfile.isAntidinicModeAll = defaultProfile.isAntidinicModeAll
end

function M.ResetExchangeWingSuit()
	gameProfile.isExchangeWingSuit = defaultProfile.isExchangeWingSuit
end

function M.ReloadAllProfile()
	gameProfile = ProfileManager.gameProfile
end

return SettingsScriptFunc
