local yield = coroutine.yield
local RaidConfig = LTConfig.RaidConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local ProfileManager = LX6.Engine.ProfileManager
local GameObject = UnityEngine.GameObject
local LoadingUtils = gLuaLoadingUtils or {
	LOGIN_SCENE_NAME = "Login"
}

function LoadingUtils.LoadLoginRes()
	return gCoroutineManager:StartCoroutine(LoadingUtils.LoadNewLoginResCo)
end

function LoadingUtils.ResetUIRootCo()
	print_notice("ResetUIRootCo Start")
	gLuaDataManager.guiMgr.panelCache:SwitchSceneClosePanels()

	if gLuaDataManager.guiMgr.sguiRoot == nil then
		print_notice("ResetUIRootCo Load SGUIRoot")

		local sguiRootLoadOp = gResourceManager:LoadAssetAsync("Assets/Res/SGUI/Panel/Root/SGUIRoot.prefab", typeof(GameObject))

		yield(sguiRootLoadOp)

		local obj = GameObject.Instantiate(sguiRootLoadOp.asset)
		obj.name = "SGUIRoot"
		obj.transform.parent = nil
		obj.transform.localScale = Vector3.one
		obj.transform.localPosition = Vector3.zero

		obj:SetActive(true)
		print_notice("ResetUIRootCo Load SGUIWorldRoot")

		local sguiWorldRootLoadOp = gResourceManager:LoadAssetAsync("Assets/Res/SGUIWorld/Panel/Root/SGUIWorldRoot.prefab", typeof(GameObject))

		yield(sguiWorldRootLoadOp)

		local obj1 = GameObject.Instantiate(sguiWorldRootLoadOp.asset)
		obj1.name = "SGUIWorldRoot"
		obj1.transform.parent = nil
		obj1.transform.localScale = Vector3.one
		obj1.transform.localPosition = Vector3.zero

		obj1:SetActive(true)
		print_notice("ResetUIRootCo Sgui_Init")
		gLuaDataManager.guiMgr:Sgui_Init()

		local index = ProfileManager.languageProfile.textLanguage
		local cfg = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(index)

		if cfg then
			local lang = LTConfig.ShezhiPanelConfig.LanguagesDisplay[index]

			SGUI.UIConfig.instance:SetLanguage(lang)
		end

		if ProfileManager.gameProfile.adaptableSize then
			gQualityManager:SetAdaptableSize(ProfileManager.gameProfile.adaptableSize)
		end

		print_notice("[ResetUIRootCo] mobileControlMode", ProfileManager.gameProfile.mobileControlMode)

		if ProfileManager.gameProfile.mobileControlMode then
			if gCS.LuaUtils.IsMobileModeGamepadOn() then
				SGUI.UIConfig.instance:SetAdaptationPlatform(SGUI.EPlatform.Console)

				gCS.PanelManager.Instance.IsMobileMode = false

				if LX6.GUI.GuiMgr.Instance.sguiJoystick ~= nil then
					LX6.GUI.GuiMgr.Instance.sguiJoystick:ShowJoystickUI(false)
				end

				SGUI.InputActionBind.fixedGameDevice = SGUI.GameDevice.PlayStation

				print_notice("[ResetUIRootCo] mobileControlMode IsMobileModeGamepadOn")
			else
				ProfileManager.gameProfile.mobileControlMode = false

				ProfileManager.SaveGameProperty()
			end
		end
	end
end

function LoadingUtils.LoadNewLoginResCo()
	if gLuaDataManager.guiMgr.sguiRoot == nil then
		yield(gCoroutineManager:StartCoroutine(LoadingUtils.ResetUIRootCo))
	end

	print_notice("[LoadNewLoginResCo] LoadScene ", LoadingUtils.LOGIN_SCENE_NAME)

	local waitLoginScene = gResourceManager:LoadScene(LoadingUtils.LOGIN_SCENE_NAME)

	yield(waitLoginScene)
	print_notice("[LoadNewLoginResCo] LoadInitPanel", gPanelId.SYS_SHOW_MORE_MESSAGE)
	yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.SYS_SHOW_MORE_MESSAGE))
	print_notice("[LoadNewLoginResCo] LoadInitPanel", gPanelId.WAITING_MSG)
	yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.WAITING_MSG))

	if gLoginManager:CheckIsTgsPack() then
		print_notice("[LoadNewLoginResCo] LoadInitPanel", gPanelId.SWITCH_GAME_MODE_PANEL)
		yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.SWITCH_GAME_MODE_PANEL))
	else
		local panelId = gCS.LoginManager.isFirstLogin and gPanelId.HEALTHY_ADVICE or gPanelId.USER_LOGIN

		print_notice("[LoadNewLoginResCo] LoadInitPanel", panelId)
		yield(gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, panelId))
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

function LoadingUtils.ResetUI(_, switchType)
	return gCoroutineManager:StartCoroutine(LoadingUtils.CoResetUI, switchType)
end

function LoadingUtils.CoResetUI(switchType)
	if switchType == gSwitchSceneType.Image or switchType == gSwitchSceneType.SwitchFromWorldMap or switchType == gSwitchSceneType.SwitchToWorldMap then
		gUIUtils:SetUITouchEnable(false)
	end

	yield(gWaitableUtils.WaitTime(0.1))
	yield(gCoroutineManager:StartCoroutine(LoadingUtils.InitUI))
	gMessageManager:SendMessage(gEventConstants.UI_RESET)

	if switchType == gSwitchSceneType.Image or switchType == gSwitchSceneType.SwitchFromWorldMap or switchType == gSwitchSceneType.SwitchToWorldMap then
		gUIUtils:SetUITouchEnable(true)
	end
end

function LoadingUtils.InitUI()
	local coArr = {
		[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.TOUCH_PANEL)
	}
	local raidId = gRaidDataManager.RaidId
	local raidCfg = RaidConfig.GetConfig(raidId)
	local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

	if raidCfg.RaidType == RaidConfig.SeasonRaidTypeId then
		coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_SEASON_GAMEPLAY_PANEL)
	end

	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_POPUP_AREA_MANAGE_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Load, gPanelManager, gPanelId.S_CORE_HUD_PANEL)

	if raidTypeConfig.hideJoystick ~= 2 and JoystickMgr.Instance.isSGUI then
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
		preLoad = true
	})
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Preload, gPanelManager, gPanelId.S_INVENTORY_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Preload, gPanelManager, gPanelId.TALENT_TREE_PANEL)
	coArr[#coArr + 1] = gCoroutineManager:StartCoroutine(gPanelManager.Preload, gPanelManager, gPanelId.S_NEW_MAP_PANEL)
	local count = 0

	for i = 1, #coArr do
		while coArr[i]:HasNext() do
			count = count + 1

			yield(nil)
		end
	end

	if gSceneDataMgr.CurrentRaidId == RaidConfig.XinShouIndoor then
		gPanelManager:CheckShow(gPanelId.S_XINSHOURAID_ESC_LISTENER)
	end

	if LX6.Engine.ProfileManager.gameProfile.isAntidinicMode then
		gPanelManager:CheckShow(gPanelId.S_CROSS_HAIR_ANTI_GLARE)
	end
end

gLuaLoadingUtils = LoadingUtils
