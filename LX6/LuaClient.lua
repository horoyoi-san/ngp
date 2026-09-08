-- Original chunk: @Lua\LuaFiles\LX6\LuaClient.lua
-- Decompiled from: 00152_LuaClient.lua_02f67b83a0fb.luajit

local fp = require("Core/moses")
local M = gLuaClient or {}

M.Init = function(self)
	self:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, function (eventId, switchSceneEventParams)
		self:OnBeforeSwitchScene(switchSceneEventParams)
	end)

	local ForceUpdateNameArray = {
		"s\\xdf(\\xfe&\";\\xcao%\\xf8J\\x82\rE\\xc3\\xf4",
		"$\t,\\xedv\\x96\\xe3\\x89\\xf3\\xfc\\xe8q\\xe9",
		"\\xd0K#\\xd51\\xb7O\\xa0Q\\xb5\\xa4"
	}
	local UpdateNameArray = {
		"$5\\xe5W\\x99\\xe35\\x85.\\xe8\\xf3\\xe1q\\xe9",
		"Twϭ\\xb7\\xab\\xcc\\xe5"
	}

	local wrap = function(f)
		return gGameManager.Env.IsENABLE_PROFILER and function (name)
			local mgr = _G[name]

			return function ()
				gGameManager:BeginSample(name)
				f(mgr)
				gGameManager:EndSample()
			end
		end or function (name)
			local mgr = _G[name]

			return function ()
				f(mgr)
			end
		end
	end

	self.ForceUpdateArray = fp.mapi(ForceUpdateNameArray, wrap(function (mgr)
		mgr:OnUpdate()
	end))
	self.UpdateArray = fp.mapi(UpdateNameArray, wrap(function (mgr)
		mgr:OnUpdate()
	end))
	self.LateUpdateNameArray = {
		"\\xd0K#\\xd51\\xb7O\\xa0Q\\xb5\\xa4",
		"s\\xdf(\\xfe,:\\xc7T\t\\xf8J\\x82\rE\\xc3\\xf4",
		"'\\xffv\\xaa\\xf0-\\xaa1Z\\xdf0\\xf7RͲ\\x94X\\xa0bU\\xb2\\xd4",
		"\\xbb\\xf2:9w,9\\x901*ٱ\\x94=\\x98\\x90̜"
	}
	self.LateUpdateArray = fp.mapi(self.LateUpdateNameArray, wrap(function (mgr)
		mgr:OnLateUpdate()
	end))
	self.DynamicUpdateArray = {}
	self.DynamicUpdateMgrFindArray = {}
	self.DynamicReadyToUnregisterArray = {}
	self.IsDynamicUnregister = false
	self.RequiredMgr = {}
end

M.OnInit = function(self)
	gGameManager:OnInit()
	gPanelEntry:OnInit()
	gStoreManager:OnInit()
	gPlayerManager:OnInit()
	gGamePlayTransitionMgr:OnInit()
	gNewMailsMgr:OnInit()
	gBattleMgr:OnInit()
	gMainMenuMgr:OnInit()
	gDropManager:OnInit()
	gBaiKeArchiveManager:OnInit()
	gGalleryManager:OnInit()
	gPackagePanelManager:OnInit()
	gLuaDataManager:OnInit()
	gUtils:OnInit()
	gSoundMgr:OnInit()
	gCommonItemManager:OnInit()
	gDisplayMessageMgr:OnInit()
	gTaskManager:OnInit()
	gChatManager:OnInit()
	gNpcChatManager:OnInit()
	gTaskNodeManager:OnInit()
	gHackManager:OnInit()
	gUIDisplayQueueMgr:OnInit()
	gEmojiManager:OnInit()
	gFeiSuoCrouchManager:OnInit()
	gSceneGameRuleManager:OnInit()
	gLingUtils:OnInit()
	gGadgetManager:OnInit()
	gReliableRpcManager:OnInit()
	gRpcChecker:OnInit()
	gFerrisMgr:OnInit()
	gSettlementMgr:OnInit()
	gCameraUtils:OnInit()
	gClueManager:OnInit()
	gGpsManager:OnInit()
	gMapManager:OnInit()
	gMapSystem:OnInit()
	gNewGuideMgr:OnInit()
	gUrbanAbilityManager:OnInit()
	gSpiritManager:OnInit()
	gPaoKuGpsManager:OnInit()
	gFireworkMgr:OnInit()
	gShootManager:OnInit()
	gUnitStateMgr:onInit()
	gNewAchievementMgr:OnInit()
	gMusicGameManager:OnInit()
	gBattleSpiritMgr:OnInit()
	gDeadManager:OnInit()
	gBuffUtils:OnInit()
	gPauseManager:OnInit()
	gHitSettlementFunc:OnInit()
	gRadioPlayerManager:OnInit()
	gRoarPlayerManager:OnInit()
	gPinHaoBanManager:OnInit()
	gSeasonDataMgr:OnInit()
	gLinkManager:OnInit()
	gNewPopupManager:OnInit()
	gPopupPauseManager:OnInit()
	gGarageManager:OnInit()
	gDartsGameManager:OnInit()
	gFlyNeedleGameManager:OnInit()
	gStickCatchGameManager:OnInit()
	gGooseImitationManager:OnInit()
	gPitchPotGameManager:OnInit()
	gMiniGameDataManager:OnInit()
	gFryTeaManager:OnInit()
	gShopManager:OnInit()
	gMallManager:OnInit()
	gCommonItemManager:OnInit()
	gRailManager:OnInit()
	gUIFunctionStateManager:OnInit()
	gDressManager:OnInit()
	gHurtStiffManager:OnInit()
	gSpiritAcquisitionManager:OnInit()
	gAgentTrustManager:OnInit()
	gBattlePetsMgr:OnInit()
	gProduceManager:OnInit()
	gCompoundManager:OnInit()
	gPoliceJobManager:OnInit()
	gFSMManager:OnInit()
	gLoginManager:OnInit()
	gDivinerManager:OnInit()
	gMainPageManager:OnInit()
	gCoreHudUIManager:OnInit()
	gDlcDownLoadMgr:OnInit()
	gWasherManager:OnInit()
	gTalentTreeMgr:OnInit()
	gDriveVehiclesManager:OnInit()
	gFurnitureManager:OnInit()
	gHouseGadgetManager:OnInit()
	gHouseManager:OnInit()
	gNpcFavorManager:OnInit()
	gBossViewManager:OnInit()
	gWeaponManager:OnInit()
	gNewBubbleMgr:OnInit()
	gNpcDaliyManager:OnInit()
	gAwardActivityManager:OnInit()
	gGaoQiaoManager:OnInit()
	gCoreHudTipManager:OnInit()
	gAnnouncementMgr:OnInit()
	gBloodBarGameManager:OnInit()
	gHideAndSeekManager:OnInit()
	gVehicleGamePlayManager:OnInit()
	gOCMgr:OnInit()
	gBattlePassMgr:OnInit()
	gCoreHudEffectManager:OnInit()
	gCinemaManager:OnInit()
	gRedPointMgr:OnInit()
	gOnlineSeasonProgressMgr:OnInit()
	gClubManager:OnInit()
	gPartyManager:OnInit()
	gSkyCountManager:OnInit()
	gAgentWeaponManager:OnInit()
	gCoreHudModeMgr:OnInit()
	gCombatPowerManager:OnInit()
	gPSNOnlineInviteStateManager:OnInit()
	gPSNOnlineInviteManager:OnInit()
end

local errorHandler = function(err)
	local errorInfo = "errorMessage:" .. err
	local level = 2

	while true do
		local info = debug.getinfo(level, "nSluf")

		if not info then
			break
		end

		errorInfo = errorInfo .. "\nStack Frame Level " .. level - 2 .. "-"
		errorInfo = errorInfo .. "Function:" .. (info.name or "anonymous") .. " namewhat:" .. info.namewhat .. " what:" .. info.what
		errorInfo = errorInfo .. " Source:" .. info.short_src .. " Line:" .. info.currentline
		local numUps = info.nups
		errorInfo = errorInfo .. " nups: " .. numUps
		local index = 1

		while true do
			local name, value = debug.getlocal(level, index)

			if not name then
				break
			end

			if name ~= "(*temporary)" and type(value) ~= "string" and string.sub(value, 1, 13) ~= "errorMessage:" then
				errorInfo = errorInfo .. string.format("\n\tLocal %s (%s):errorMessage:", name, type(value))
			else
				errorInfo = errorInfo .. string.format("\n\tLocal %s (%s): %s", name, type(value), tostring(value))
			end

			index = index + 1
		end

		index = 1

		while true do
			local name, value = debug.getupvalue(info.func, index)

			if not name then
				break
			end

			errorInfo = errorInfo .. string.format("\n\tUpValue %s (%s): %s", name, type(value), tostring(value))
			index = index + 1
		end

		level = level + 1
	end

	return errorInfo
end

M.OnUpdate = function(self)
	for _, v in ipairs(self.ForceUpdateArray) do
		local ok, err = xpcall(v, tolua.traceback)

		if not ok then
			print_error(err)
		end
	end

	if not gPlayerManager.infoBase.bindData.Pid then
		return
	end

	for _, v in ipairs(self.UpdateArray) do
		local ok, err = xpcall(v, tolua.traceback)

		if not ok then
			print_error(err)
		end
	end

	local i = 1

	while i < #self.DynamicUpdateArray do
		local v = self.DynamicUpdateArray[i]
		i = i + 1
		local ok, err = xpcall(v.func, tolua.traceback)

		if not ok then
			print_error(err)
		end
	end
end

M.OnLateUpdate = function(self)
	for i, v in ipairs(self.LateUpdateArray) do
		local ok, err = xpcall(v, tolua.traceback)

		if not ok then
			local lateUpdateName = self.LateUpdateNameArray[i]

			print_error("LateUpdate-" .. (lateUpdateName or "Unknown"), err)
		end
	end

	if self.IsDynamicUnregister then
		self:PerformUnregisterDynamicUpdate()
	end
end

M.OnCameraUpdate = function(self)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("gCameraUtils OnCameraUpdate")
	end

	gCameraUtils:OnCameraUpdate()

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
		gGameManager:BeginSample("gStoreManager OnCameraUpdate")
	end

	gStoreManager:OnCameraUpdate()

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
		gGameManager:BeginSample("gBattleMgr OnCameraUpdate")
	end

	gBattleMgr:OnCameraUpdate()

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.OnBeforeSwitchScene = function(self, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType
	Time.timeScale = 1

	gGamePlayTransitionMgr:OnBeforeSwitchScene(switchType)
	gUnitOperateManager:OnBeforeSwitchScene(switchType)
	gSoundMgr:OnBeforeSwitchScene(switchType)
	gDropManager:OnBeforeSwitchScene(switchType)
	gDisplayMessageMgr:OnBeforeSwitchScene(switchType)
	gBossViewManager:OnBeforeSwitchScene(switchType)
	Timer:OnBeforeSwitchScene(switchType)
	gGpsManager:OnBeforeSwitchScene(switchType)
	gLuaUIMgr:OnBeforeSwitchScene(switchType)
	gUIDisplayQueueMgr:OnBeforeSwitchScene(switchType)
	gHurtStiffData:OnBeforeSwitchScene(switchType)
	gGadgetManager:OnBeforeSwitchScene(switchType)
	gSpiritManager:OnBeforeSwitchScene(switchType)
	gBattleMgr:OnBeforeSwitchScene(switchType)
	gFerrisMgr:OnBeforeSwitchScene(switchType)
	gMainMenuMgr:OnBeforeSwitchScene(switchType)
	gLuaDataManager:OnBeforeSwitchScene(switchType)
	gTimeNotificationManager:OnBeforeSwitchScene(switchType)
	gBundleInfoManager:OnBeforeSwitchScene(switchType)
	gRedPointMgr:OnBeforeSwitchScene(switchType)
	gAntiAddictionManager:OnBeforeSwitchScene(switchType)
	gChatManager:OnBeforeSwitchScene(switchType)
	gNpcChatManager:OnBeforeSwitchScene(switchType)
	gEmojiManager:OnBeforeSwitchScene(switchType)
	gImageManager:OnBeforeSwitchScene(switchType)
	gObjectManager:OnBeforeSwitchScene(switchType)
	gFeiSuoCrouchManager:OnBeforeSwitchScene(switchType)
	gSceneGameRuleManager:OnBeforeSwitchScene(switchType)
	gMapUtils:OnBeforeSwitchScene(switchType)
	gRaidDataManager:OnBeforeSwitchScene(switchType)
	gMapSystem:OnBeforeSwitchScene(switchType)
	gClueManager:OnBeforeSwitchScene(switchType)
	gDialogCameraManager:OnBeforeSwitchScene(switchType)
	gMapManager:OnBeforeSwitchScene(switchType)
	gPlayerManager:OnBeforeSwitchScene(switchType)
	gLuaDataManager:OnBeforeSwitchScene(switchType)
	gDisplayMessageMgr:OnBeforeSwitchScene(switchType)
	gInteractionManager:OnBeforeSwitchScene(switchType)
	gPanelManager:OnBeforeSwitchScene(switchType)
	gAnimalManager:OnBeforeSwitchScene(switchType)
	gRestaurantManager:OnBeforeSwitchScene(switchType)
	gBengdiActionManager:OnBeforeSwitchScene(switchType)
	gClawMachineManager:OnBeforeSwitchScene(switchType)
	gPaoKuGpsManager:OnBeforeSwitchScene(switchType)
	gUnitStateMgr:OnBeforeSwitchScene()
	gUIUtils:OnBeforeSwitchScene(switchType)
	gNewGuideMgr:OnBeforeSwitchScene(switchType)
	gTriggerEnemyMgr:OnBeforeSwitchScene(switchType)
	gDeadManager:OnBeforeSwitchScene(switchType)
	gGachaManager:OnBeforeSwitchScene(switchType)
	gHitSettlementFunc:OnBeforeSwitchScene(switchType)
	gRadioPlayerManager:OnBeforeSwitchScene(switchType)
	gSeasonDataMgr:OnBeforeSwitchScene(switchType)
	gStoreManager:OnBeforeSwitchScene(switchType)
	gMusicGameManager:OnBeforeSwitchScene(switchType)
	gNewPopupManager:OnBeforeSwitchScene(switchType)
	gGymManager:OnBeforeSwitchScene(switchType)
	gQualityManager:OnBeforeSwitchScene(switchType)
	gSettlementMgr:OnBeforeSwitchScene(switchType)
	gGarageManager:OnBeforeSwitchScene(switchType)
	gCommonItemManager:OnBeforeSwitchScene(switchType)
	gBaiKeArchiveManager:OnBeforeSwitchScene(switchType)
	gPhoneCallManager:OnBeforeSwitchScene(switchType)
	gSocialNetworkPopupManager:OnBeforeSwitchScene(switchType)
	gPhoneCallPopupManager:OnBeforeSwitchScene(switchType)
	gSocialNetworkUtils:OnBeforeSwitchScene(switchType)
	gExtractionShooterManager:OnBeforeSwitchScene(switchType)
	gPhoneWaitManager:OnBeforeSwitchScene(switchType)
	gPhonePanelRuleCheckManager:OnBeforeSwitchScene(switchType)
	gAliOssManager:OnBeforeSwitchScene(switchType)
	gYanJieReleaseManager:OnBeforeSwitchScene(switchType)
	gSpiritAcquisitionManager:OnBeforeSwitchScene(switchType)
	gBattlePetsMgr:OnBeforeSwitchScene(switchType)
	gCoreHudUIManager:OnBeforeSwitchScene(switchType)
	gDriveVehiclesManager:OnBeforeSwitchScene(switchType)
	gCoreHudModeMgr:OnBeforeSwitchScene(switchType)
	gBartendManager:OnBeforeSwitchScene(switchType)
	gBuffUtils:OnBeforeSwitchScene(switchType)
	gNewCarStoreMgr:OnBeforeSwitchScene(switchType)
	gShieldDefendMgr:OnBeforeSwitchScene(switchType)
	gVehicleGamePlayManager:OnBeforeSwitchScene(switchType)
	gSocialFriendManager:OnBeforeSwitchScene(switchType)
	gSocialChatGroupManager:OnBeforeSwitchScene(switchType)
	gSocialChatManager:OnBeforeSwitchScene(switchType)
	gCoreHudEffectManager:OnBeforeSwitchScene(switchType)
	gHouseGadgetManager:OnBeforeSwitchScene(switchType)
	gPlanningBoardManager:OnBeforeSwitchScene(switchType)
	gWeaponManager:OnBeforeSwitchScene(switchType)
	gOnlineSeasonProgressMgr:OnBeforeSwitchScene(switchType)
	gSunbathManager:OnBeforeSwitchScene(switchType)
	gCombatPowerManager:OnBeforeSwitchScene(switchType)
	gHudRecommendMgr:OnBeforeSwitchScene(switchType)
end

M.GetMgr = function(self, mgrName)
	local mgr = self.RequiredMgr[mgrName]

	if mgr ~= nil then
		mgr = require(table.concat({
			"CN\\xfa8a\\xb3\\xfcFml",
			mgrName
		}))
		self.RequiredMgr[mgrName] = mgr
	end

	return mgr
end

M.RegisterDynamicUpdate = function(self, mgrName, mgr)
	if mgrName ~= nil or mgr ~= nil then
		return
	end

	self.DynamicReadyToUnregisterArray[mgrName] = nil

	if self.DynamicUpdateMgrFindArray[mgrName] == nil then
		return
	end

	if mgr.OnUpdate ~= nil then
		print_error(table.concat({
			mgrName,
			">3e|)\\x98<*&}\\x9a\\x86\\xa9\\xea3\\xbe\\xa8\\x95*=\\xc75\\x8d3>\\xcd`\\x9b~\\x9c*Ғk\\x84\\xf6"
		}))

		return
	end

	local updateFunc = gGameManager.Env.IsENABLE_PROFILER and function ()
		gGameManager:BeginSample(mgrName)
		mgr:OnUpdate()
		gGameManager:EndSample()
	end or function ()
		mgr:OnUpdate()
	end

	table.insert(self.DynamicUpdateArray, {
		mgrName = mgrName,
		func = updateFunc
	})

	self.DynamicUpdateMgrFindArray[mgrName] = #self.DynamicUpdateArray
end

M.UnregisterDynamicUpdate = function(self, mgrName)
	if self.DynamicUpdateMgrFindArray[mgrName] ~= nil then
		return
	end

	self.DynamicReadyToUnregisterArray[mgrName] = true
	self.IsDynamicUnregister = true
end

M.PerformUnregisterDynamicUpdate = function(self)
	for v, _ in pairs(self.DynamicReadyToUnregisterArray) do
		local index = self.DynamicUpdateMgrFindArray[v]
		local count = #self.DynamicUpdateArray

		if index == count then
			self.DynamicUpdateArray[index] = self.DynamicUpdateArray[count]
			self.DynamicUpdateMgrFindArray[self.DynamicUpdateArray[index].mgrName] = index
		end

		self.DynamicUpdateArray[count] = nil
		self.DynamicUpdateMgrFindArray[v] = nil
	end

	table.clear(self.DynamicReadyToUnregisterArray)

	self.IsDynamicUnregister = false
end

gLuaClient = M
