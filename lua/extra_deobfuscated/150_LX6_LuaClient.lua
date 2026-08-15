local fp = require("Core/moses")
local M = gLuaClient or {}

function M:Init()
	self:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, function (eventId, switchType)
		self:OnBeforeSwitchScene(switchType)
	end)

	local ForceUpdateNameArray = {
		"gCoroutineManager",
		"gClientQARunner",
		"gStoreManager"
	}
	local UpdateNameArray = {
		"gLuaDataManager",
		"gMapSystem"
	}

	local function wrap(f)
		return gGameManager.Env.IsENABLE_PROFILER and function (name)
			local mgr = _G[name]

			return function ()
				gCS.LuaUtils.BeginSample(name)
				f(mgr)
				gCS.LuaUtils.EndSample()
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
		"gStoreManager",
		"gCoreHudUIManager",
		"gUIFunctionStateManager"
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

function M:OnInit()
	gGameManager:OnInit()
	gPanelEntry:OnInit()
	gStoreManager:OnInit()
	gPlayerManager:OnInit()
	gGamePlayTransitionMgr:OnInit()
	gNewMailsMgr:OnInit()
	gBattleMgr:OnInit()
	gMainMenuMgr:OnInit()
	gDropManager:OnInit()
	gStoneManager:OnInit()
	gBaiKeArchiveManager:OnInit()
	gPackagePanelManager:OnInit()
	gLuaDataManager:OnInit()
	gUtils:OnInit()
	gSoundMgr:OnInit()
	gPlayerItemManager:OnInit()
	gDisplayMessageMgr:OnInit()
	gTaskManager:OnInit()
	gChatManager:OnInit()
	gNpcChatManager:OnInit()
	gTaskNodeManager:OnInit()
	gHackManager:OnInit()
	gUIDisplayQueueMgr:OnInit()
	gEmojiManager:OnInit()
	gStealthManager:OnInit()
	gFeiSuoCrouchManager:OnInit()
	gCutsceneManager:OnInit()
	gSceneGameRuleManager:OnInit()
	gLingUtils:OnInit()
	gGadgetManager:OnInit()
	gRpcChecker:OnInit()
	gFerrisMgr:OnInit()
	gSettlementMgr:OnInit()
	gCameraUtils:OnInit()
	gClueManager:OnInit()
	gGpsManager:OnInit()
	gMapManager:OnInit()
	gMapSystem:OnInit()
	gGFManager:OnInit()
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
	gMiniGameDataManager:OnInit()
	gShopManager:OnInit()
	gCommonItemManager:OnInit()
	gRailManager:OnInit()
	gUIFunctionStateManager:OnInit()
	gDressManager:OnInit()
	gHurtStiffManager:OnInit()
	gSpiritAcquisitionManager:OnInit()
	gAgentTrustManager:OnInit()
	gBattlePetsMgr:OnInit()
	gProduceManager:OnInit()
	gPoliceJobManager:OnInit()
	gFSMManager:OnInit()
	gLoginManager:OnInit()
	gDoctorManager:OnInit()
	gDivinerManager:OnInit()
	gMainPageManager:OnInit()
	gCoreHudUIManager:OnInit()
	gDlcDownLoadMgr:OnInit()
	gWasherManager:OnInit()
	gTalentTreeMgr:OnInit()
	gDriveVehiclesManager:OnInit()
	gFurnitureManager:OnInit()
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
end

local function errorHandler(err)
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

			if name == "(*temporary)" and type(value) == "string" and string.sub(value, 1, 13) == "errorMessage:" then
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

function M:OnUpdate()
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

	while i <= #self.DynamicUpdateArray do
		local v = self.DynamicUpdateArray[i]
		i = i + 1
		local ok, err = xpcall(v.func, tolua.traceback)

		if not ok then
			print_error(err)
		end
	end
end

function M:OnLateUpdate()
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

function M:OnCameraUpdate()
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("gCameraUtils OnCameraUpdate")
	end

	gCameraUtils:OnCameraUpdate()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
		gCS.LuaUtils.BeginSample("gStoreManager OnCameraUpdate")
	end

	gStoreManager:OnCameraUpdate()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
		gCS.LuaUtils.BeginSample("gBattleMgr OnCameraUpdate")
	end

	gBattleMgr:OnCameraUpdate()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:OnBeforeSwitchScene(switchType)
	Time.timeScale = 1

	gTriggerEnemyManager:OnBeforeSwitchScene(switchType)
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
	gStealthManager:OnBeforeSwitchScene(switchType)
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
	gTaxiManager:OnBeforeSwitchScene(switchType)
	gMapManager:OnBeforeSwitchScene(switchType)
	gPlayerManager:OnBeforeSwitchScene(switchType)
	gLuaDataManager:OnBeforeSwitchScene(switchType)
	gDisplayMessageMgr:OnBeforeSwitchScene(switchType)
	gInteractionManager:OnBeforeSwitchScene(switchType)
	gPanelManager:OnBeforeSwitchScene(switchType)
	gAnimalManager:OnBeforeSwitchScene(switchType)
	gRestaurantManager:OnBeforeSwitchScene(switchType)
	gClawMachineManager:OnBeforeSwitchScene(switchType)
	gPaoKuGpsManager:OnBeforeSwitchScene(switchType)
	gUnitStateMgr:OnBeforeSwitchScene()
	gUIUtils:OnBeforeSwitchScene(switchType)
	gGFManager:OnBeforeSwitchScene(switchType)
	gDialogManager:OnBeforeSwitchScene(switchType)
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
	gPhoneWaitManager:OnBeforeSwitchScene(switchType)
	gPhonePanelRuleCheckManager:OnBeforeSwitchScene(switchType)
	gYanJieReleaseManager:OnBeforeSwitchScene(switchType)
	gSpiritAcquisitionManager:OnBeforeSwitchScene(switchType)
	gBattlePetsMgr:OnBeforeSwitchScene(switchType)
	gCoreHudUIManager:OnBeforeSwitchScene(switchType)
	gDriveVehiclesManager:OnBeforeSwitchScene(switchType)
	gCoreHudModeMgr:OnBeforeSwitchScene(switchType)
	gBartendManager:OnBeforeSwitchScene(switchType)
	gSKeyManager:OnBeforeSwitchScene(switchType)
	gBuffUtils:OnBeforeSwitchScene(switchType)
	gNewCarStoreMgr:OnBeforeSwitchScene(switchType)
	gShieldDefendMgr:OnBeforeSwitchScene(switchType)
end

function M:GetMgr(mgrName)
	local mgr = self.RequiredMgr[mgrName]

	if mgr == nil then
		mgr = require(table.concat({
			"LX6/Manager/",
			mgrName
		}))
		self.RequiredMgr[mgrName] = mgr
	end

	return mgr
end

function M:RegisterDynamicUpdate(mgrName, mgr)
	if mgrName == nil or mgr == nil then
		return
	end

	self.DynamicReadyToUnregisterArray[mgrName] = nil

	if self.DynamicUpdateMgrFindArray[mgrName] ~= nil then
		return
	end

	if mgr.OnUpdate == nil then
		print_error(table.concat({
			mgrName,
			" does not have an OnUpdate() function."
		}))

		return
	end

	local updateFunc = gGameManager.Env.IsENABLE_PROFILER and function ()
		gCS.LuaUtils.BeginSample(mgrName)
		mgr:OnUpdate()
		gCS.LuaUtils.EndSample()
	end or function ()
		mgr:OnUpdate()
	end

	table.insert(self.DynamicUpdateArray, {
		mgrName = mgrName,
		func = updateFunc
	})

	self.DynamicUpdateMgrFindArray[mgrName] = #self.DynamicUpdateArray
end

function M:UnregisterDynamicUpdate(mgrName)
	if self.DynamicUpdateMgrFindArray[mgrName] == nil then
		return
	end

	self.DynamicReadyToUnregisterArray[mgrName] = true
	self.IsDynamicUnregister = true
end

function M:PerformUnregisterDynamicUpdate()
	for v, _ in pairs(self.DynamicReadyToUnregisterArray) do
		local index = self.DynamicUpdateMgrFindArray[v]
		local count = #self.DynamicUpdateArray

		if index ~= count then
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
