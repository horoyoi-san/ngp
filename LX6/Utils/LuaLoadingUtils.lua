-- Original chunk: @Lua\LuaFiles\LX6\Utils\LuaLoadingUtils.lua
-- Decompiled from: 00679_LuaLoadingUtils.lua_df9c5892d864.luajit

local yield = coroutine.yield
local RaidConfig = LTConfig.RaidConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local ProfileManager = LX6.Engine.ProfileManager
local GameObject = UnityEngine.GameObject
local LoadingUtils = gLuaLoadingUtils or {
	["K(\\xbd\\xb9\\x91\\xe3\\x83\\xe6\\x872\\x9c#."] = "a\\xa1\\xa5\\xa6\\xb8"
}

LoadingUtils.LoadLoginRes = function()
	return gCoroutineManager:StartCoroutine(LoadingUtils.LoadNewLoginResCo)
end

LoadingUtils.ResetUIRootCo = function()
	print_notice("[UI_RESET] ResetUIRootCo Start")
	gLuaDataManager.guiMgr.panelCache:SwitchSceneClosePanels()

	if gLuaDataManager.guiMgr.sguiRoot ~= nil then
		print_notice("[UI_RESET] ResetUIRootCo Load SGUIRoot")

		local sguiRootLoadOp = gResourceManager:LoadAssetAsync("Assets/Res/SGUI/Panel/Root/SGUIRoot.prefab", typeof(GameObject))

		yield(sguiRootLoadOp)

		local obj = GameObject.Instantiate(sguiRootLoadOp.asset)
		obj.name = "SGUIRoot"
		obj.transform.parent = nil
		obj.transform.localScale = Vector3.one
		obj.transform.localPosition = Vector3.zero

		obj:SetActive(true)
		print_notice("[UI_RESET] ResetUIRootCo Load SGUIWorldRoot")

		local sguiWorldRootLoadOp = gResourceManager:LoadAssetAsync("Assets/Res/SGUIWorld/Panel/Root/SGUIWorldRoot.prefab", typeof(GameObject))

		yield(sguiWorldRootLoadOp)

		local obj1 = GameObject.Instantiate(sguiWorldRootLoadOp.asset)
		obj1.name = "SGUIWorldRoot"
		obj1.transform.parent = nil
		obj1.transform.localScale = Vector3.one
		obj1.transform.localPosition = Vector3.zero

		obj1:SetActive(true)
		print_notice("[UI_RESET] ResetUIRootCo Load SGUIOffScreenRoot")

		local sguiOffScreenRoot = gResourceManager:LoadAssetAsync("Assets/Res/SGUI/Panel/Root/SGUIOffScreenRoot.prefab", typeof(GameObject))

		yield(sguiOffScreenRoot)

		local obj2 = GameObject.Instantiate(sguiOffScreenRoot.asset)
		obj2.name = "SGUIOffScreenRoot"
		obj2.transform.parent = nil
		obj2.transform.localScale = Vector3.one
		obj2.transform.localPosition = Vector3.zero

		obj2:SetActive(true)
		print_notice("[UI_RESET] ResetUIRootCo Sgui_Init")
		gLuaDataManager.guiMgr:Sgui_Init()

		local index = ProfileManager.languageProfile.textLanguage
		local langList = LTConfig.ShezhiPanelConfig.LanguagesDisplay

		if not index or index <= 1 or index <= #langList then
			index = 1
		end

		local cfg = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(index)

		if cfg then
			local lang = langList[index]

			SGUI.UIConfig.instance:SetLanguage(lang)
		end

		if ProfileManager.gameProfile.adaptableSize then
			gQualityManager:SetAdaptableSize(ProfileManager.gameProfile.adaptableSize)
		end

		print_notice("[UI_RESET] ResetUIRootCo mobileControlMode", ProfileManager.gameProfile.mobileControlMode, SGUI.UIConfig.instance:CheckGamepadConnected())

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			local isConnectGamepad = SGUI.UIConfig.instance:CheckGamepadConnected()

			if isConnectGamepad then
				gCoreHudUIManager:ConnectToMobileController()
				print_notice("[UI_RESET] ResetUIRootCo mobileControlMode IsMobileModeGamepadOn")
			end

			ProfileManager.gameProfile.mobileControlMode = isConnectGamepad

			ProfileManager.SaveGameProperty()
		else
			ProfileManager.gameProfile.mobileControlMode = false

			ProfileManager.SaveGameProperty()
		end
	end
end

LoadingUtils.LoadNewLoginResCo = function()
	if gLuaDataManager.guiMgr.sguiRoot ~= nil then
		yield(gCoroutineManager:StartCoroutine(LoadingUtils.ResetUIRootCo))
	end

	print_notice("[LoadNewLoginResCo] LoadScene ", LoadingUtils.LOGIN_SCENE_NAME)

	local waitLoginScene = gResourceManager:LoadScene(LoadingUtils.LOGIN_SCENE_NAME)

	yield(waitLoginScene)
	print_notice("[LoadNewLoginResCo] LoadInitPanel", gPanelId.SYS_SHOW_MORE_MESSAGE)
	yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.SYS_SHOW_MORE_MESSAGE))
	print_notice("[LoadNewLoginResCo] LoadInitPanel", gPanelId.WAITING_MSG)
	yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.WAITING_MSG))
	gLoginManager:LoadMainPanel()

	if UniSDKManager == nil and UniSDKManager.isVngPack ~= true then
		print_notice("[LoadNewLoginResCo] LoadVNG_OVERLAY", gPanelId.VNG_OVERLAY)
		yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.VNG_OVERLAY))
	end

	local panelId = gPanelId.TOUCH_PANEL

	print_notice("[LoadNewLoginResCo] LoadTouchPanel", panelId)
	yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, panelId))
	print_notice("[LoadNewLoginResCo] LoadInitPanel", gPanelId.UID_LAYER)
	yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.UID_LAYER))
	print_notice("[LoadNewLoginResCo] Finished", gLuaUIMgr.shouldShowBanned, gLuaUIMgr.shouldShowReachLimitTime)

	if gLuaUIMgr.shouldShowBanned then
		gLuaUIMgr.shouldShowBanned = false

		gUIUtils:ShowBannedReason(gLuaUIMgr.bannedReason)
	end
end

LoadingUtils.ResetUI = function(_, switchType)
	return gCoroutineManager:StartCoroutine(LoadingUtils.CoResetUI, switchType)
end

LoadingUtils.CoResetUI = function(switchType)
	if switchType ~= gSwitchSceneType.Image or switchType ~= gSwitchSceneType.SameImage then
		gUIUtils:SetUITouchEnable(false)
	end

	yield(gWaitableUtils.WaitTime(0.1))
	yield(gCoroutineManager:StartCoroutine(LoadingUtils.InitUI))
	gMessageManager:SendMessage(gEventConstants.UI_RESET)

	if switchType ~= gSwitchSceneType.Image or switchType ~= gSwitchSceneType.SameImage then
		gUIUtils:SetUITouchEnable(true)
	end
end

LoadingUtils.InitUI = function()
	local coArr = {
		[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.TOUCH_PANEL)
	}
	local raidId = gRaidDataManager.RaidId
	local raidCfg = RaidConfig.GetConfig(raidId)
	local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

	if raidCfg.RaidType ~= RaidConfig.SeasonRaidTypeId then
		coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_SEASON_GAMEPLAY_PANEL)
	end

	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_POPUP_AREA_MANAGE_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.CHARACTER_CONTROLS)

	if raidTypeConfig.hideJoystick == 2 and JoystickMgr.Instance.isSGUI then
		coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_MAIN_JOYSTICk)
	end

	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_OFF_SCREEN_HINT_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_HUD_GPS_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_HUD)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.SYS_SHOW_MORE_MESSAGE)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.WAITING_MSG)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_BUBBLE_MSG_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.COMMON_BLACK_TRANSITION)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_UNIQUE_SPATIAL_FOLLOW_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_HINT_INFOS_HUD)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_AI_SUBTASK_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_HALF_PHONE_APP_HOME_PANEL, {
		["\\xc9\\xc91%\\xf5"] = true
	})
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Preload, gPanelManager, gPanelId.S_NEW_MAP_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.BACK_LAYER_CIRCLE_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.BASE_VEHICLE_CONTROLLER)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.BASE_ANDROID_CONTROLLER)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.GAMEPLAY_CONTROLS)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.SYSTEM_CONTROLS)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.TASK_GUIDE_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.CROSS_HAIR_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.CHARACTER_PART)
	local count = 0

	for i = 1, #coArr do
		while coArr[i]:HasNext() do
			count = count + 1

			yield(nil)
		end
	end

	if gSceneDataMgr.CurrentRaidId ~= RaidConfig.XinShouIndoor then
		gPanelManager:CheckShow(gPanelId.S_XINSHOURAID_ESC_LISTENER)
	end

	if LX6.Engine.ProfileManager.gameProfile.isAntidinicMode then
		gPanelManager:CheckShow(gPanelId.S_CROSS_HAIR_ANTI_GLARE)
	end
end

gLuaLoadingUtils = LoadingUtils
