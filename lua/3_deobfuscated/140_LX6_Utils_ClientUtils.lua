local PlayerPrefs = UnityEngine.PlayerPrefs
local MessageConfig = LTConfig.MessageConfig
local M = {
	mainPhonePanelIdList = {
		gPanelId.S_PHONE_APP_HOME_PANEL,
		gPanelId.S_HALF_PHONE_APP_HOME_PANEL,
		gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL
	},
	ModelType = {
		MiddleFemale = 4,
		SmallFemale = 5,
		BigFemale = 3,
		BigMale = 1,
		MiddleMale = 2
	},
	GetPrefsKey = function (key)
		if gPlayerManager.infoLogin.bindData.pid then
			local roleId = ulong.tostring(gPlayerManager.infoLogin.bindData.pid)

			return ("%s_%s"):format(key, roleId)
		else
			return key
		end
	end
}

function M.GetInt(key, defaultValue)
	return PlayerPrefs.GetInt(M.GetPrefsKey(key), defaultValue)
end

function M.SetInt(key, value)
	PlayerPrefs.SetInt(M.GetPrefsKey(key), value)
end

function M.HasKey(key)
	return PlayerPrefs.HasKey(key)
end

function M.GetString(key, defaultValue)
	return PlayerPrefs.GetString(M.GetPrefsKey(key), defaultValue)
end

function M.SetString(key, value)
	PlayerPrefs.SetString(M.GetPrefsKey(key), value)
end

function M.GetBool(key, defaultValue)
	return M.GetInt(key, defaultValue and 1 or 0) == 1
end

function M.SetBool(key, value)
	M.SetInt(key, value and 1 or 0)
end

function M.ResetTransform(transform)
	transform.position = Vector3.zero
	transform.rotation = Quaternion.identity
	transform.localScale = Vector3.one
end

function M.ResetLocalTransform(transform)
	transform.localPosition = Vector3.zero
	transform.localRotation = Quaternion.identity
	transform.localScale = Vector3.one
end

function M.IsNil(object)
	return object == nil or gCS.LuaUtils.IsNull(object)
end

function M.NotNil(object)
	return not M.IsNil(object)
end

function M.GetPlayerAreaId()
	local mapId = gRaidDataManager.RaidId
	local position = gCS.MyPlayerManager.PlayerUnit.Position

	return LX6.Gps.MapBlockMgr.GetBlockIdXZ(mapId, position.X, position.Z)
end

function M.GetPlayerPosition()
	return gCS.MyPlayerManager.PlayerUnit.Position
end

function M.EnvSdkReviewWords(text, successCallback, failCallback, channel)
	if gLoginManager:CheckIsTgsPack() then
		FrameTimer.New(function ()
			successCallback(text)
		end, 1):Start()

		return
	end

	gCoroutineManager:StartCoroutine(function ()
		local wait = EnvSDK.reviewWordsAsync(text, 1, channel)

		coroutine.yield(wait)

		local result = wait.result

		if result.code ~= 202 and result.code ~= 201 then
			successCallback(text)
		else
			failCallback()
		end
	end)
end

function M.ResetAnimation(animation, clipName)
	local animationState = animation:get_Item(clipName)

	if animationState then
		animation:Play(clipName)

		animationState.time = 0
		animationState.enabled = true

		animation:Sample()

		animationState.enabled = false
	end
end

function M.ResetMy3CState()
	gUnitStateMgr:ResetMyStateAndClearMove()
	gCS.LogicStateMachineManager.OnSettingOutOfStuck(gCS.MyPlayerManager.PlayerUnit)
end

function M.GetAnimationClipLength(animation, clipName)
	local animationState = animation:get_Item(clipName)

	return animationState.length
end

function M.FinishAnimation(animation, clipName)
	if gClientUtils.IsNil(animation) then
		return
	end

	local animationState = animation:get_Item(clipName)

	if animationState then
		animation:Play(clipName)

		animationState.time = animationState.length
		animationState.enabled = true

		animation:Sample()

		animationState.enabled = false
	end
end

function M.CheckNameValid(name, maxLen, minLen, channel, callback)
	minLen = minLen or 1

	local function failCallback()
		gDisplayMessageMgr:ShowMessage(MessageConfig.SNSCheckFail)
	end

	local function successCallback()
		if UX.Utils.NameValidityChecker.CheckName(name, maxLen, minLen) ~= 0 then
			gDisplayMessageMgr:ShowMessage(MessageConfig.NameInvalid)

			return
		end

		if callback then
			callback()
		end
	end

	gClientUtils.EnvSdkReviewWords(name, successCallback, failCallback, channel)
end

function M.SetCameraRotateEnabled(isEnabled, source)
	if M.NotNil(gCS.CameraDataMgr.cameraControllerManager) then
		gCS.CameraDataMgr.cameraControllerManager:SetRotateEnable(isEnabled, source or 0)
	end
end

function M.RunCode(code, funcScript)
	local f = load(code, nil, "t", funcScript)

	if f then
		local status, err = xpcall(f, tolua.traceback)

		return status, err
	end

	return false
end

function M.OnMainPhonePanelOpen()
	gNewGuideMgr:NotifySignal(EGuideSignal.PhoneOpen)
	M.PlayPhoneAction()
	M.SetCameraRotateEnabled(false)
end

function M.OnMainPhonePanelClose()
	M.ExitPhoneAction()
	M.SetCameraRotateEnabled(true)

	gCS.TransitionMgr.showMainCube = false
end

function M.PlayPhoneAction()
	if gCS.TransitionMgr.IsPlayPhoneAction then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("PlayPhoneAction")
	end

	if gCS.MyPlayerManager.PlayerUnit and not gCS.MyPlayerManager.PlayerUnit.IsDestroyed then
		local actionKey = gUtils:GetActionKey(LTConfig.WeatherConfig.CompletionAction, gLuaFightConstants.ACTION_GROUP_01)
		local isPlayWeatherCompletionAction = gCS.AnimationManager.GetCurrentLayerActionKey(gCS.MyPlayerManager.PlayerUnit) == actionKey

		if isPlayWeatherCompletionAction then
			if gGameManager.Env.IsENABLE_PROFILER then
				gCS.LuaUtils.EndSample()
			end

			return
		end

		for i = 0, LTConfig.PhonePanelActionConflictConfig.count - 1 do
			local actionConflictCfg = LTConfig.PhonePanelActionConflictConfig.LoadAt(i)
			local actionCheckFunction = gPhonePanelRuleCheckManager.actionCheckFunctions[actionConflictCfg.Id]

			if actionCheckFunction() then
				if actionConflictCfg.FunctionStartType == gClientConst.PHONE_PANEL_FUNCTION_START_TYPE.Normal then
					gCS.TransitionMgr.IsPlayPhoneAction = true
					gCS.TransitionMgr.IsExitPhoneAction = false
					gCS.TransitionMgr.showMainCube = true

					gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
				end

				break
			end
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M.ExitPhoneAction(skipCheckSwitchAction)
	local isSteal = false
	local item = nil
	item = gCS.MindPowerMgr:GetAimItem()

	if item and gCS.MyPlayerManager.inRobMobileState then
		isSteal = true

		gCS.MindPowerMgr:TryExitLookAtMobile()
		gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

		gCS.TransitionMgr.IsPlayPhoneAction = false
		gCS.TransitionMgr.IsExitPhoneAction = true
	end

	if not isSteal then
		gCS.TransitionMgr.IsPlayPhoneAction = false
		gCS.TransitionMgr.IsExitPhoneAction = true

		if not skipCheckSwitchAction then
			gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
		end
	end

	LX6.Share.SceneRoomR.LockRoomProbe(false)
end

function M.CloseMainPhonePanel(isForce)
	gMainPhoneUtils.CloseMainPhonePanel(isForce)
end

function M:HighSpeedDown()
	return
end

function M:PrintLog()
	local LogUtils = LX6.Utils.LogUtilsLua

	local function prepare(...)
		local n = select("#", ...)
		local args = {
			...
		}

		for i = 1, n do
			local v = args[i]

			if v == nil then
				args[i] = "nil"
			elseif type(v) == "table" then
				args[i] = table.tostring(v, false)
			end
		end

		table.insert(args, "\n")
		table.insert(args, debug.traceback())

		return unpack(args)
	end

	function print_warn(...)
		LogUtils.Notice(prepare(...))
	end

	function print_debug(...)
		LogUtils.Notice(prepare(...))
	end
end

function M:CloseMainPhonePanelCs(isForce)
	M.CloseMainPhonePanel(isForce)
end

function M:ClearPaoKuState(noClearShootOrCrouch, leaveMoto, noClearMotoSpeed, noClearFeiSuoCrouch, noBreakMind, noClearMoveGround, autoIdle, noClearUpperStateAction)
	noClearShootOrCrouch = noClearShootOrCrouch or false
	leaveMoto = leaveMoto or false
	noClearMotoSpeed = noClearMotoSpeed or false
	noClearFeiSuoCrouch = noClearFeiSuoCrouch or false
	noBreakMind = noBreakMind or false
	noClearMoveGround = noClearMoveGround or false
	autoIdle = autoIdle or false
	noClearUpperStateAction = noClearUpperStateAction or false

	gCS.ClimbManager.ClearPaoKuState(noClearShootOrCrouch, leaveMoto, noClearMotoSpeed, noClearFeiSuoCrouch, noBreakMind, noClearMoveGround, autoIdle, noClearUpperStateAction)
	gInteractionManager:SetInteractTargetCollider(true)
end

function M.OpenMainPhonePanel()
	if gPanelManager:IsPanelShowing(gPanelId.S_HALF_PHONE_APP_HOME_PANEL) then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_HALF_PHONE_APP_HOME_PANEL)
end

function M.CheckMainPhoneHalfScreenEnable()
	if gGmUtils.isHalfScreenEnable == nil then
		return true
	else
		return gGmUtils.isHalfScreenEnable
	end
end

function M.CheckMainPhoneIsShowing()
	local panelIdList = M.GetMainPhonePanelIdList()

	for _, panelId in ipairs(panelIdList) do
		if gPanelManager:IsPanelShowing(panelId) then
			local phoneAppHomePanelStore = gStoreManager:GetStoreGroup("PhoneAppHomePanelStore")

			return phoneAppHomePanelStore.panelState == gClientConst.PanelState.Show
		end
	end

	return false
end

function M.IsMainPhoneExist()
	local panelIdList = M.GetMainPhonePanelIdList()

	for _, panelId in ipairs(panelIdList) do
		if gPanelManager:IsPanelShowing(panelId) then
			return true
		end
	end

	return false
end

function M.GetMainPhonePanelId()
	if M.frontPhoneShowing then
		return gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL
	end

	if M.CheckMainPhoneHalfScreenEnable() then
		return gPanelId.S_HALF_PHONE_APP_HOME_PANEL
	end

	return gPanelId.S_PHONE_APP_HOME_PANEL
end

function M.CheckIsMainPhonePanelId(panelId)
	local panelIdList = M.GetMainPhonePanelIdList()

	return table.find(panelIdList, panelId)
end

function M.GetMainPhonePanelIdList()
	return M.mainPhonePanelIdList
end

function M.CheckMainPhoneSGuiEnable()
	if gGmUtils.isMainPhoneSGuiEnable == nil then
		return true
	end

	return gGmUtils.isMainPhoneSGuiEnable
end

function M.OpenMap()
	if gMapUtils:CheckRaidCanOpenMap() then
		gPanelManager:CheckShow(gPanelId.S_NEW_MAP_PANEL)
	end
end

function M.GetCurrentMiniGameManager()
	if gBasketballGameManager.currentGame then
		return gBasketballGameManager
	end

	if gDartsGameManager.preEnd then
		gDartsGameManager.preEnd = false

		return gDartsGameManager
	end
end

function M.GetIgnorePauseCheckPanelIdList()
	local mainPhonePanelIdList = M.GetMainPhonePanelIdList()
	local otherIgnorePanelIdList = {}

	return array.concat(mainPhonePanelIdList, otherIgnorePanelIdList)
end

function M.GetFilePickerImageUrl(url, size)
	if size then
		return ("%s?fop=imageView/0/w/%d/h/%d"):format(url, size.x, size.y)
	else
		return ("%s?fop=imageView"):format(url)
	end
end

function M.IsControllerMode()
	local navMgr = SGUI.UNavigationMgr.Inst

	return M.NotNil(navMgr) and navMgr.CurNavigationMode ~= SGUI.NavigationMode.None
end

function M.FormatTimeToMMSS(time)
	local minutes = math.floor(time / 60)
	local seconds = math.floor(time - minutes * 60)

	return gString.Format("%02d:%02d", minutes, seconds)
end

function M.RichTextToPlain(richText)
	local name = gPlayerManager.infoLogin.bindData.name

	if name == nil then
		print_error("在未登录时调用了 RichTextToPlain！")

		name = ""
	end

	return string.gsub(richText, "<player>", name)
end

function M.InitNavAreasInChildren(widget, panelId, gamepadBar, forceSetGamepadBar)
	if M.IsNil(widget) or panelId == nil then
		print_error("bad argument to 'SetAreaPanelId', widget", widget, "panelId", panelId)

		return
	end

	local navAreas = widget:GetComponentsInChildren(typeof(SGUI.UNavigationArea), true)

	for i = 0, navAreas.Length - 1 do
		local navArea = navAreas[i]

		gCS.LuaUtils.SetNavAreaPanelId(navArea, panelId)

		if forceSetGamepadBar or M.IsNil(navArea.gamePadBar) then
			navArea.gamePadBar = gamepadBar
		end
	end
end

function M.CheckPanelSystemUnlocked(panelId)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panelId)

	if panelCfg and panelCfg.SystemId and panelCfg.SystemId > 0 then
		return gSystemUnlockMgr:IsUnlock(panelCfg.SystemId)
	end

	return true
end

function M.GetCurrentLanguageId()
	local languageProfile = LX6.Engine.ProfileManager.languageProfile

	return languageProfile.textLanguage
end

function M.FormatDistance(distance)
	if distance >= 1000 then
		distance = distance / 1000

		return ("%.1fkm"):format(distance)
	else
		return ("%dm"):format(math.floor(distance + 0.5))
	end
end

function M.GetGrowthIdByLv(targetLv)
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if growthCfg.Lv == targetLv then
			return growthCfg.Id
		end
	end
end

function M.GetPlayerCurrentExp()
	local currentExp = gPlayerManager.infoMinor.bindData.fan123

	return currentExp
end

function M.GetPlayerLevel()
	return gPlayerManager.infoMinor.bindData.level
end

function M.GetFactionInfo(factionId)
	local factionInfoDic = gPlayerManager.infoAchievement.bindData.FactionInfoDic

	return factionInfoDic and factionInfoDic[factionId]
end

function M:CsGetFactionInfo(factionId)
	return gClientUtils.GetFactionInfo(factionId)
end

function M:GetFameLevel(factionId)
	local info = self.GetFactionInfo(factionId)

	return info and info.DispositionLevel or 999
end

function M.LuaPatchTest()
	return 0
end

function M.CheckHasLevelReward()
	local hasUnlocked = gMainPhoneUtils.CheckFansSystemUnlocked()

	if not hasUnlocked then
		return false
	end

	local levelRewardList = gPlayerManager.infoMinor.bindData.levelRewardList

	return #levelRewardList > 0
end

function M.GetTargetLevelExp(targetLevel)
	targetLevel = targetLevel or gPlayerManager.infoMinor.bindData.level
	local growthCfg = LTConfig.GrowthConfig.GetConfig(targetLevel)

	return growthCfg and growthCfg.Exp or 0
end

function M.CheckIsLinkMode()
	return gLinkManager.LinkMode ~= UX.Game.LinkMode.None
end

function M.FormatWithThousandsSeparator(num)
	local str = tostring(num)
	local formatted = ""
	local length = #str

	for i = 1, length do
		formatted = formatted .. str:sub(i, i)

		if (length - i) % 3 == 0 and i ~= length then
			formatted = formatted .. ","
		end
	end

	return formatted
end

function M.ShowCommonScrollNumber(widget, startNumber, endNumber)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local separatorList = {
		store.separator1,
		store.separator2,
		store.separator3,
		store.separator4
	}
	local maxLength = #tostring(endNumber)
	local separatorCount = math.floor((maxLength - 1) / 3)

	for index, separatorWidget in ipairs(separatorList) do
		separatorWidget.gameObject:SetActive(index <= separatorCount)
	end

	store.scrollNumGroup.startNum = startNumber
	store.scrollNumGroup.targetNum = endNumber

	store.scrollNumGroup:SetToStartNum()
	store.scrollNumGroup:Play()
end

function M.CheckCurrentIsDefaultSpirit()
	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	return currentSpiritId == LTConfig.FightSpiritConfig.DefaultMale or currentSpiritId == LTConfig.FightSpiritConfig.DefaultFemale
end

function M:SetCSIsInFeisuoState(isInFeisuo)
	gPlayerManager.main.bindData.isInFeisuo = isInFeisuo

	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.FeiSuo01, isInFeisuo)
end

function M:OpenChatPanel(args)
	gNpcChatUtils.OpenChatPanel(args)
end

function M.GetNpcCultivationAgentId(id)
	local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(id)
	local fightSpiritId = npcCultivationCfg.FightSpiritID
	local fightSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(fightSpiritId)
	local agentId = fightSpiritCfg.AgentId

	return agentId
end

function M:PlayGamePlayTimeline(gamePlayId, timelineName, transform, callback)
	if gamePlayId == LTConfig.NPCChatGamePlayTypeConfig.Dance808 then
		gBengdiActionManager:PlayInviteTimeline(timelineName, transform, callback)
	end
end

function M.PlaySingleAction(unit, actionType, group, allTime, fadeInTime, startTime, realEnd, actionEndCB, transitionSchemaIndex)
	group = group or unit.State.ActionGroupId
	allTime = allTime or -1
	fadeInTime = fadeInTime or -1
	startTime = startTime or 0
	realEnd = realEnd or false
	transitionSchemaIndex = transitionSchemaIndex or 0

	gCS.AnimControllerManager.PlayAction(unit, actionType, group, allTime, startTime, fadeInTime, realEnd, actionEndCB, transitionSchemaIndex)
end

function M:PlayQueuedActions(unit, actions, actionGroup, times, fadeInTime, startTime, realEnd, actionEndCB)
	local actionT = actions
	local timesT = times
	local fadeInTimeT = fadeInTime
	local actionsType = type(actions)
	local timesType = type(times)
	local fadeInTimeType = type(fadeInTime)
	actionGroup = actionGroup or unit.State.ActionGroupId

	if actionsType ~= "table" and actionsType ~= "number" then
		actionT = actions:ToTable()
	end

	if timesType ~= "table" and timesType ~= "number" then
		timesT = times:ToTable()
	end

	if fadeInTime then
		if fadeInTimeType ~= "table" and fadeInTimeType ~= "number" then
			fadeInTimeT = fadeInTime:ToTable()
		elseif fadeInTimeType == "number" then
			fadeInTimeT = {
				fadeInTimeT
			}
		end
	end

	if startTime == nil then
		startTime = 0
	end

	gCS.AnimControllerManager.PlayQueuedActions(unit.cs_unit, actionT, actionGroup, timesT, fadeInTimeT, startTime, realEnd, actionEndCB)
end

function M.GetNpcCultivationId(firstSpiritId)
	firstSpiritId = firstSpiritId or gSpiritManager:GetCurFirstSpiritTid()
	local count = LTConfig.NpcCultivationConfig.count

	for i = 0, count - 1 do
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.LoadAt(i)

		if npcCultivationCfg.FightSpiritID == firstSpiritId then
			return npcCultivationCfg.Id
		end
	end
end

function M.CheckIsGamePadMode()
	return SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
end

gClientUtils = M
