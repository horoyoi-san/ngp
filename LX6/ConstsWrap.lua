-- Original chunk: @Lua\LuaFiles\LX6\ConstsWrap.lua
-- Decompiled from: 00025_ConstsWrap.lua_652bfb3df9c8.luajit

local o = nil
local rawset = rawset
o = L50.Chat.ChatManager

rawset(o, "PlayerSelf", 1)

o = LX6.Constants.LayerConstants

rawset(o, "Default", 0)
rawset(o, "IgnoreRaycast", 2)

o = LX6.Constants.SoundConstants.SoundRtpcName

rawset(o, "PlaySpeed", "LP_SoundTimeStretchRatio")
rawset(o, "DistanceToRoad", "GP_DistanceToRoad")
rawset(o, "NPC_Num", "GP_Count_NPC_Nearby")
rawset(o, "NearVehicleCount", "GP_Count_Vehicle_Nearby")
rawset(o, "PlayerAreaSize", "GP_Raycast_SpaceVolume")
rawset(o, "SpaceHeight", "GP_Raycast_SpaceHeight")
rawset(o, "SpaceWidth", "GP_Raycast_SpaceWidth")
rawset(o, "Walla_NPC_Num", "LP_Count_NPC_Quadrant")
rawset(o, "CoastDistance", "GP_DistanceToCoast")
rawset(o, "WindStrength", "GP_WindStrength")
rawset(o, "VehicleRoadNoiseAvgDistance", "LP_Vehicle_RoadNoise_AvgDistance")
rawset(o, "VehicleRoadNoiseAvgSpeed", "LP_Vehicle_RoadNoise_AvgSpeed")
rawset(o, "VehicleRoadNoiseCount", "LP_Vehicle_RoadNoise_Count")
rawset(o, "MetroAngle", "LP_Metro_Angle")
rawset(o, "MetroAbsoluteVelocity", "LP_Metro_AbsoluteVelocity")
rawset(o, "MetroRelativeVelocity", "LP_Metro_RelativeVelocity")
rawset(o, "MetroRelativeVelocityUnsigned", "LP_Metro_RelativeVelocity_Unsigned")
rawset(o, "MetroSoundLocation", "LP_Metro_SoundLocation")
rawset(o, "MetroPlayerDoorState", "LP_Metro_PlayerDoorState")
rawset(o, "MetroSelfDoorState", "LP_Metro_SelfDoorState")
rawset(o, "MetroDopplerFrequencyRatio", "LP_Metro_DopplerFrequencyRatio")
rawset(o, "ObjectSwingVelocity", "LP_Swing_Velocity")
rawset(o, "ObjectVelocity", "LP_Object_AbsoluteVelocity")
rawset(o, "ObjectAngularVelocity", "LP_Object_AngularVelocity")
rawset(o, "ObjectAngular", "LP_Object_Angular")
rawset(o, "EnableMotion", "LP_Object_EnableMotion")
rawset(o, "ObjectGravity", "LP_Object_Gravity")
rawset(o, "ObjectMass", "LP_Object_Mass")
rawset(o, "ObjectRelativeVelocity", "LP_Object_RelativeVelocity")
rawset(o, "ObjectCollisionImpulse", "LP_Object_CollisionImpulse")
rawset(o, "ObjectForceBar", "LP_Object_Force_Bar")
rawset(o, "ObjectCount", "LP_Object_Count")
rawset(o, "MouseSpeed", "LP_Param_Mouse_Speed")
rawset(o, "Model_Velocity", "LP_Player_AbsoluteVelocity")
rawset(o, "Absolute_Velocity", "GP_Player_AbsoluteVelocity")
rawset(o, "Absolute_Velocity_Low_Latency", "GP_Player_AbsoluteVelocity_LowLatency")
rawset(o, "PlayerAxis_Y", "GP_Player_Height_Absolute")
rawset(o, "ListenerAxis_Y", "GP_Listener_Height_Absolute")
rawset(o, "ListenerDistance", "GP_Listener_Distance")
rawset(o, "PlayerFloorHeightOffset", "GP_Player_Height_Relative")
rawset(o, "Swing_Angle_Horizontal", "GP_Player_SwingAngle_Horizontal")
rawset(o, "Swing_Angle", "GP_Player_SwingAngle_Vertical")
rawset(o, "PlayerForwardAngle", "LP_Player_ForwardAngle")
rawset(o, "ActionBoneAcceleration", "LP_Action_BoneAcceleration")
rawset(o, "ActionFoleyParamLower", "LP_Action_DynamicFoley_Bottoms")
rawset(o, "ActionFoleyParamUpper", "LP_Action_DynamicFoley_Tops")
rawset(o, "ActionFoleyParamMax", "LP_Action_DynamicFoley_Max")
rawset(o, "FootWaterDepth", "LP_Footsteps_WaterDepth")
rawset(o, "PlayerWaterDepth", "LP_Player_WaterDepth")
rawset(o, "WeaponDurability", "LP_WeaponDurability")
rawset(o, "SoundOwner", "LP_Owner")
rawset(o, "ControllerSpeakerVolume", "GP_Volume_ControllerSpeaker")
rawset(o, "MotionVolume", "GP_Volume_Motion")
rawset(o, "MusicVolume", "GP_Volume_Music")
rawset(o, "EffectVolume", "GP_Volume_SFX")
rawset(o, "VoiceVolume", "GP_Volume_VO")
rawset(o, "MusicInstEnsVolume", "Music_InstEns_Volume")
rawset(o, "GameTime", "GP_GameTime")
rawset(o, "RadioVolume", "GP_RadioVolume")
rawset(o, "UIGameTime", "GP_UI_SkipTime_GameTime")
rawset(o, "PianoNoteOff", "LP_Piano_NoteOff")
rawset(o, "RaidoChannel", "LP_RadioChannel")
rawset(o, "GlobalPauseScale", "Global_Pause_Scale")
rawset(o, "ScenePauseScale", "Scene_Pause_Scale")
rawset(o, "GlobalSkillPauseScale", "Global_Skill_Pause_Scale")
rawset(o, "GlobalTimelineScale", "GP_Timeline_Scale")
rawset(o, "BypassWwiseRecorder", "GP_BypassRecorder")
rawset(o, "GlobalEnemyAboutToAttack", "GP_EnemyAboutToAttack")
rawset(o, "EnemyAboutToAttack", "LP_EnemyAboutToAttack")
rawset(o, "GameVideoType", "LP_GameVideoType")
rawset(o, "DoorVelocity", "LP_Door_Velocity")
rawset(o, "IsPlayer", "LP_Vehicle_IsPlayer")
rawset(o, "VehicleMotionVelocity_GP", "GP_VehicleMotion_Velocity")
rawset(o, "VehicleMotionAcceleration_GP", "GP_VehicleMotion_Acceleration")
rawset(o, "VehicleMotionGear_GP", "GP_VehicleMotion_Gear")
rawset(o, "VehicleMotionThrottleInput_GP", "GP_VehicleMotion_Throttle")
rawset(o, "VehicleVelocity", "LP_Vehicle_AbsoluteVelocity")
rawset(o, "VehicleAcceleration", "LP_Vehicle_Acceleration")
rawset(o, "VehicleDopplerFrequencyRatio", "LP_Vehicle_DopplerFrequencyRatio")
rawset(o, "VehicleForwardAngle", "LP_Vehicle_ForwardAngle")
rawset(o, "VehiclePlayerRelativeHeight", "LP_Vehicle_PlayerRelativeHeight")
rawset(o, "VehicleRelativeVelocity", "LP_Vehicle_RelativeVelocity")
rawset(o, "VehicleRelativeVelocityUnsigned", "LP_Vehicle_RelativeVelocity_Unsigned")
rawset(o, "VehicleThrottle", "LP_Vehicle_Throttle")
rawset(o, "VehicleHeadingAngle", "LP_Vehicle_HeadingAngle")
rawset(o, "VehiclePrioritySame", "LP_Vehicle_PrioritySame")
rawset(o, "VehiclePriorityDifferent", "LP_Vehicle_PriorityDifferent")
rawset(o, "VehiclePlayerVelocity", "LP_Vehicle_Player_Velocity")
rawset(o, "VehicleHorizontalVelocity", "LP_Vehicle_Player_Hit_Velocity_Horizontal")
rawset(o, "VehicleVerticalVelocity", "LP_Vehicle_Player_Hit_Velocity_Vertical")
rawset(o, "VehicleAirborne", "LP_Vehicle_Player_Airborne")
rawset(o, "VehicleGear", "LP_Vehicle_Player_Gear")
rawset(o, "VehicleCollideImpulse", "LP_Vehicle_Player_Impulse")
rawset(o, "VehicleBrakeInput", "LP_Vehicle_Player_Input_Brake")
rawset(o, "VehicleParamHandbrake", "LP_Vehicle_Player_Input_HandBrake")
rawset(o, "VehicleThrottleInput", "LP_Vehicle_Player_Input_Throttle")
rawset(o, "VehicleRPM", "LP_Vehicle_Player_RPM")
rawset(o, "VehicleThrottleWithVd", "LP_Vehicle_Player_Throttle_with_VD")
rawset(o, "VehicleVd", "LP_Vehicle_Player_VD")
rawset(o, "VehicleWheelSusp", "LP_Vehicle_Player_WheelSuspension")
rawset(o, "VehicleYawAngularSpeed", "LP_Vehicle_Player_YawAngularSpeed")
rawset(o, "VehicleClutch", "LP_Vehicle_Player_Clutch")
rawset(o, "VehicleTurbine", "LP_Vehicle_Player_Turbine")
rawset(o, "VehicleDecoupledRPMDiff", "LP_Vehicle_Player_DeltaRPM")
rawset(o, "VehicleHitAngular", "LP_Vehicle_Player_HitAngular")
rawset(o, "VehicleHitImpulse", "LP_Vehicle_Player_HitImpulse")
rawset(o, "VehicleHitGroundMaxSpeed", "LP_Vehicle_Player_FallMaxSpeed")
rawset(o, "VehicleConvertibleOcclusion", "GP_Vehicle_ConvertibleOcclusion")
rawset(o, "VehicleConvertibleOcclusion_Player", "GP_Vehicle_Player_ConvertibleOcclusion")
rawset(o, "VehiclePlayerModKit", "LP_Vehicle_Player_ModKit")
rawset(o, "HelicopterForwardBack", "LP_Helicopter_Player_ForwardBack")
rawset(o, "HelicopterForwardBackAccel", "LP_Helicopter_Player_ForwardBackAccel")
rawset(o, "HelicopterRightLeft", "LP_Helicopter_Player_RightLeft")
rawset(o, "HelicopterRightLeftAccel", "LP_Helicopter_Player_RightLeftAccel")
rawset(o, "HelicopterUpDown", "LP_Helicopter_Player_UpDown")
rawset(o, "HelicopterUpDownAccel", "LP_Helicopter_Player_UpDownAccel")
rawset(o, "HelicopterVelocity", "LP_Helicopter_Player_Velocity")
rawset(o, "HelicopterXZRotationMax", "LP_Helicopter_Player_XZRotationMax")
rawset(o, "HelicopterFloorHeight", "LP_Helicopter_Player_Height")
rawset(o, "TafeiMotoState", "LP_Vehicle_Player_TafeiMoto")
rawset(o, "VehicleReflectionLeft", "LP_Vehicle_Player_Reflect_L")
rawset(o, "VehicleReflectionRight", "LP_Vehicle_Player_Reflect_R")
rawset(o, "VehicleMotionBicycleCrankAngle", "GP_VehicleMotion_Bicycle_CrankAngle")
rawset(o, "VehicleMotionBicycleCadence", "GP_VehicleMotion_Bicycle_Cadence")
rawset(o, "AcidDoorCorrosion", "LP_AcidDoorTest_Function_Corrosion")
rawset(o, "CameraUnderwaterDepth", "GP_camera_ underwater_depth")

o = LX6.Constants.SoundConstants.SoundStateGroup

rawset(o, "DefaultStateValue", "None")

o = LX6.Constants.SoundConstants.SoundStateGroup.Cinematics

rawset(o, "StateName", "StateGroup_Cinematics")
rawset(o, "OnlyTimelineSound", "OnlyTimelineSound")
rawset(o, "OnlyTimelineAndAmb", "OnlyTimelineAndAmbSound")
rawset(o, "FullSoundExceptDx", "FullSoundExceptDx")
rawset(o, "StoryTimeline", "State_Timeline")

o = LX6.Constants.SoundConstants.SoundStateGroup.ControllerType

rawset(o, "StateName", "StateGroup_ControllerType")
rawset(o, "Dulsense", "State_DualSense")
rawset(o, "Other", "State_NonDulsense")

o = LX6.Constants.SoundConstants.SoundStateGroup.EGuitarStrumChord

rawset(o, "StateName", "SW_EGuitarStrum_Chord")
rawset(o, "ChordA", "A")
rawset(o, "ChordAm", "Am")
rawset(o, "ChordB", "B")
rawset(o, "ChordBm", "Bm")
rawset(o, "ChordC", "C")
rawset(o, "ChordCm", "Cm")
rawset(o, "ChordD", "D")
rawset(o, "ChordDm", "Dm")
rawset(o, "ChordE", "E")
rawset(o, "ChordEm", "Em")
rawset(o, "ChordF", "F")
rawset(o, "ChordFm", "Fm")
rawset(o, "ChordG", "G")
rawset(o, "ChordGm", "Gm")

o = LX6.Constants.SoundConstants.SoundStateGroup.EGuitarStrumRhy

rawset(o, "StateName", "SW_EGuitarStrum_Rhy")
rawset(o, "Rhy1", "Rhy1")
rawset(o, "Rhy2", "Rhy2")
rawset(o, "Rhy3", "Rhy3")
rawset(o, "Rhy4", "Rhy4")
rawset(o, "Rhy5", "Rhy5")
rawset(o, "Rhy6", "Rhy6")

o = LX6.Constants.SoundConstants.SoundStateGroup.GamePlay_Mix

rawset(o, "StateName", "StateGroup_GamePlay_Mix")
rawset(o, "Explore", "State_Explore")
rawset(o, "Combat", "State_Combat")
rawset(o, "CG", "State_CutScene")
rawset(o, "Teleporting", "State_Teleporting")

o = LX6.Constants.SoundConstants.SoundStateGroup.GameState

rawset(o, "StateName", "StateGroup_GameState")
rawset(o, "Explore", "State_Explore")
rawset(o, "Combat", "State_Combat")
rawset(o, "CG", "State_CutScene")

o = LX6.Constants.SoundConstants.SoundStateGroup.MonsterTypes

rawset(o, "StateName", "StateGroup_MonsterTypes")
rawset(o, "Default", "State_Default")

o = LX6.Constants.SoundConstants.SoundStateGroup.MotionGrade

rawset(o, "StateName", "StateGroup_MotionGrade")
rawset(o, "All", "motion_all")
rawset(o, "Part", "motion_part")
rawset(o, "None", "motion_off")

o = LX6.Constants.SoundConstants.SoundStateGroup.MovementState

rawset(o, "StateName", "StateGroup_MovementState")
rawset(o, "Default", "_default")
rawset(o, "Swing", "State_Swing")
rawset(o, "Drive", "State_Drive")

o = LX6.Constants.SoundConstants.SoundStateGroup.MusicChoirBoys

rawset(o, "StateName", "StateGroup_Music_Choir_Boys")
rawset(o, "Boys_Normal", "Boys_Normal")
rawset(o, "Boys_Power", "Boys_Power")

o = LX6.Constants.SoundConstants.SoundStateGroup.MusicChoirGirls

rawset(o, "StateName", "StateGroup_Music_Choir_Girls")
rawset(o, "Girls_Normal", "Girls_Normal")
rawset(o, "Girls_Power", "Girls_Power")

o = LX6.Constants.SoundConstants.SoundStateGroup.MusicChoirPlayer

rawset(o, "StateName", "StateGroup_Music_Choir_Player")
rawset(o, "Player_Normal", "Player_Normal")
rawset(o, "Player_Power", "Player_Power")

o = LX6.Constants.SoundConstants.SoundStateGroup.MusicState

rawset(o, "StateName", "StateGroup_Music_Move")
rawset(o, "Explore", "State_Music_Explore")
rawset(o, "PaoKu", "State_Music_PaoKu")

o = LX6.Constants.SoundConstants.SoundStateGroup.PanelType

rawset(o, "StateName", "StateGroup_Panel")
rawset(o, "MenuPause", "State_MenuPause")
rawset(o, "MenuNormal", "State_MenuNormal")

o = LX6.Constants.SoundConstants.SoundStateGroup.PlayerElevator

rawset(o, "StateName", "StateGroup_PlayerElevatorStatus")
rawset(o, "Default", "State_ElevatorWaitting")
rawset(o, "Interior", "State_ElevatorRunning")
rawset(o, "Exterior", "State_ElevatorWaitting")

o = LX6.Constants.SoundConstants.SoundStateGroup.WorldRegion

rawset(o, "StateName", "StateGroup_WorldRegions")
rawset(o, "Default", "State_Area_Default")
rawset(o, "Camp", "State_Area_Camp")

o = LX6.Constants.SoundConstants.SoundStatePriority

rawset(o, "Default", 0)
rawset(o, "SoundStateTask", 2)
rawset(o, "MenuNormal", 4)
rawset(o, "Normal", 5)
rawset(o, "FullScreenUIPanel", 5)
rawset(o, "TimelineTextTrack", 6)
rawset(o, "ExclusiveUIPanel", 6)
rawset(o, "TimelineClipDefault", 8)
rawset(o, "CutScene", 10)
rawset(o, "Loading", 10)
rawset(o, "TeleportTimeline", 12)
rawset(o, "Max", 9999)

o = LX6.Constants.SoundConstants.SoundSwitchGroupName

rawset(o, "FashionBag", "SW_Fashion_Bag")
rawset(o, "FashionShoes", "SW_Fashion_Shoes")
rawset(o, "FashionCloth", "SW_Fashion_Cloth")
rawset(o, "FashionProps", "SW_Fashion_Props")
rawset(o, "ModelSwitch", "SW_Model")
rawset(o, "VehicleTypeSwitch", "SW_Vehicle")
rawset(o, "WeaponTypeSwitch", "SW_Weapon")
rawset(o, "WeaponWhooshSwitch", "SW_Weapon_Whsh")
rawset(o, "DieWeaponTypeSwitch", "SW_Die_Weapon")
rawset(o, "GroundMaterialSwitch", "SW_Material")
rawset(o, "HitAgentMaterial", "SW_Material_HitAgent")
rawset(o, "HitVehicleMaterial", "SW_Material_HitVehicle")
rawset(o, "FollowNpcSwitch", "ExistNpc")
rawset(o, "HitTypeSwitch", "SW_HitType")
rawset(o, "OwnerSwitch", "SW_Owner")
rawset(o, "BattleVoiceIndexSwitch", "SW_BattleVoice_Index")
rawset(o, "BattleVoiceListenerSuffix", "Listener")
rawset(o, "ControlledCharacterSexSwitch", "SW_Controlled_Character_Sex")
rawset(o, "GameVideoTypeSwitch", "SW_GameVideoType")
rawset(o, "ShootModeSwitch", "SW_ShootMode")
rawset(o, "MotionCombat", "SW_Motion_Combat")
rawset(o, "InteractBasketballMaterial", "SW_Interact_Basketball_Material")

o = LX6.Constants.SoundConstants.SoundSwitchGroupValue.Owner

rawset(o, "Player", "Owner_1P")
rawset(o, "Other", "Owner_3P")

o = LX6.Manager.ConstConfig

rawset(o, "ServerListURL", "ServerListURL")
rawset(o, "AuditVersion", "AuditVersion")
rawset(o, "AuditServerListURL", "AuditServerListURL")
rawset(o, "AnnouncementUrl", "AnnouncementUrl")
rawset(o, "AuditNeed", "AuditNeed")
rawset(o, "VideoResUrl", "VideoResUrl")
rawset(o, "AudioResUrl", "AudioResUrl")
rawset(o, "NewVersionUrls", "NewVersionUrls")
rawset(o, "NewPatchUrls", "NewPatchUrls")
rawset(o, "IFixUrl", "IFixUrl")
rawset(o, "IFixInfoUrl", "IFixInfoUrl")
rawset(o, "EnterTutorial", "EnterTutorial")
rawset(o, "VersionControlNum", "VersionControlNum")
rawset(o, "VersionControlTag", "VersionControlTag")
rawset(o, "UseTouchInputActionMap", "UseTouchInputActionMap")
rawset(o, "DefaultAdaptationPlatform", "DefaultAdaptationPlatform")
rawset(o, "DeviceScoreSourceUrl", "DeviceScoreSourceUrl")
rawset(o, "QualityDefinitionUrl", "QualityDefinitionUrl")
rawset(o, "LoginLog", "LoginLog")
rawset(o, "OnlineTest", "OnlineTest")
rawset(o, "OverSea", "OverSea")
rawset(o, "GamescomDemo", "GamescomDemo")
rawset(o, "JF_LOG_KEY", "JF_LOG_KEY")
rawset(o, "JF_GAS3_URL", "JF_GAS3_URL")
rawset(o, "UseFever", "UseFever")
rawset(o, "VIRTUAL_ORDER", "VIRTUAL_ORDER")
rawset(o, "UNIPAY_CASHIER_SECRET", "UNIPAY_CASHIER_SECRET")
rawset(o, "UNIPAY_CASHIER_URL", "UNIPAY_CASHIER_URL")
rawset(o, "ForceScreenProtection", "ForceScreenProtection")
rawset(o, "NGPUSH_PRODUCT_ID", "NGPUSH_PRODUCT_ID")
rawset(o, "NGPUSH_CLIENT_KEY", "NGPUSH_CLIENT_KEY")
rawset(o, "ENVSDK_GAMEID", "ENVSDK_GAMEID")
rawset(o, "ENVSDK_KEY", "ENVSDK_KEY")
rawset(o, "ENVSDK_HOST", "ENVSDK_HOST")
rawset(o, "APPDUMP_GAMEID", "APPDUMP_GAMEID")
rawset(o, "APPDUMP_KEY", "APPDUMP_KEY")
rawset(o, "DRPF_PROJECT", "DRPF_PROJECT")
rawset(o, "DRPF_SOURCE1", "DRPF_SOURCE1")
rawset(o, "DRPF_SOURCE2", "DRPF_SOURCE2")
rawset(o, "NGVOICE_USER_AGENT", "NGVOICE_USER_AGENT")
rawset(o, "NGVOICE_SERVER_PATH", "NGVOICE_SERVER_PATH")
rawset(o, "NGVOICE_SERVER_HOST", "NGVOICE_SERVER_HOST")
rawset(o, "CDKEY_GAMEID", "CDKEY_GAMEID")
rawset(o, "CDKEY_URL", "CDKEY_URL")
rawset(o, "CDKEY_ACTIVATION_KEY", "CDKEY_ACTIVATION_KEY")
rawset(o, "CDKEY_ACTIVATION_PATH", "CDKEY_ACTIVATION_PATH")
rawset(o, "CDKEY_GIFT_KEY", "CDKEY_GIFT_KEY")
rawset(o, "CDKEY_GIFT_PATH", "CDKEY_GIFT_PATH")
rawset(o, "SharedPersonalInfo", "SharedPersonalInfo")
rawset(o, "PrivatePolicy", "PrivatePolicy")
rawset(o, "CloudMusic_AppId", "CloudMusic_AppId")
rawset(o, "CloudMusic_PrivateKey", "CloudMusic_PrivateKey")
rawset(o, "FuXiBaseUrl", "FuXiBaseUrl")
rawset(o, "FuXiAkxBaseUrl", "FuXiAkxBaseUrl")
rawset(o, "FuXiTTSBaseUrl", "FuXiTTSBaseUrl")
rawset(o, "SpiritBaseUrl", "SpiritBaseUrl")
rawset(o, "SpiritTokenBaseUrl", "SpiritTokenBaseUrl")
rawset(o, "FuXiAkxUsername", "FuXiAkxUsername")
rawset(o, "FuXiAkxSecret", "FuXiAkxSecret")
rawset(o, "FuXiPoliceBaseUrl", "FuXiPoliceBaseUrl")
rawset(o, "FuXiBeggarBaseUrl", "FuXiBeggarBaseUrl")
rawset(o, "FuXiMartialArtistBaseUrl", "FuXiMartialArtistBaseUrl")
rawset(o, "OpenIdLoginUrl", "OpenIdLoginUrl")
rawset(o, "PackageLocation", "PackageLocation")
rawset(o, "AutoSwitchTextModeWithAllPrefix", "AutoSwitchTextModeWithAllPrefix")
rawset(o, "PS5ProtocolUrl", "PS5ProtocolUrl")

o = LX6.Utils.GuiUtils

rawset(o, "UI_TRANS_OUT_RANGE", -100000)
