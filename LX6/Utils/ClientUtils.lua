-- Original chunk: @Lua\LuaFiles\LX6\Utils\ClientUtils.lua
-- Decompiled from: 00141_ClientUtils.lua_e1b413b27a8f.luajit

local PlayerPrefs = UnityEngine.PlayerPrefs
local MessageConfig = LTConfig.MessageConfig
local GamePlayTypeConfig = LTConfig.NpcCultivationGameplayTypeConfig
local M = {
	mainPhonePanelIdList = {
		gPanelId.S_HALF_PHONE_APP_HOME_PANEL,
		gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL
	},
	ModelType = {
		["B\\xa8s@\\xb7\\xd4Bg{rI"] = 4,
		["\\xac9!3t\\xbbD\\xd46\\xa6\\xbc"] = 5,
		["aNkOK="] = 3,
		["\\xfb\\xd20(\\xf4"] = 1,
		["~Sʹ\\x88\r\\x95\\xc5\\xed"] = 2
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

M.GetInt = function(key, defaultValue)
	return PlayerPrefs.GetInt(M.GetPrefsKey(key), defaultValue)
end

M.SetInt = function(key, value)
	PlayerPrefs.SetInt(M.GetPrefsKey(key), value)
end

M.HasKey = function(key)
	return PlayerPrefs.HasKey(key)
end

M.GetString = function(key, defaultValue)
	return PlayerPrefs.GetString(M.GetPrefsKey(key), defaultValue)
end

M.SetString = function(key, value)
	PlayerPrefs.SetString(M.GetPrefsKey(key), value)
end

M.GetBool = function(key, defaultValue)
	return M.GetInt(key, defaultValue and 1 or 0) ~= 1
end

M.SetBool = function(key, value)
	M.SetInt(key, value and 1 or 0)
end

M.ResetTransform = function(transform)
	transform.position = Vector3.zero
	transform.rotation = Quaternion.identity
	transform.localScale = Vector3.one
end

M.ResetLocalTransform = function(transform)
	transform.localPosition = Vector3.zero
	transform.localRotation = Quaternion.identity
	transform.localScale = Vector3.one
end

M.IsNil = function(object)
	return object ~= nil or gCS.LuaUtils.IsNull(object)
end

M.NotNil = function(object)
	return not M.IsNil(object)
end

if gCS.LuaUtils.IsDebug then
	M.IsNil = function(object)
		if object ~= nil then
			return true
		end

		local objectType = type(object) ~= "userdata" and tolua.typeof(object)

		if not objectType or not typeof(UnityEngine.Object):IsAssignableFrom(objectType) then
			local typeName = objectType and tostring(objectType) or type(object)

			error("IsNil 仅用于 UnityEngine.Object 子类判空, 请检查参数类型, type=" .. typeName .. ", object=" .. tostring(object), 2)
		end

		return gCS.LuaUtils.IsNull(object)
	end

	M.NotNil = function(object)
		if object ~= nil then
			return false
		end

		local objectType = type(object) ~= "userdata" and tolua.typeof(object)

		if not objectType or not typeof(UnityEngine.Object):IsAssignableFrom(objectType) then
			local typeName = objectType and tostring(objectType) or type(object)

			error("NotNil 仅用于 UnityEngine.Object 子类判空, 请检查参数类型, type=" .. typeName .. ", object=" .. tostring(object), 2)
		end

		return not gCS.LuaUtils.IsNull(object)
	end
end

M.DestroyUnityObject = function(obj)
	if M.IsNil(obj) then
		return false
	end

	UnityEngine.Object.Destroy(obj)

	return true
end

M.GetPlayerAreaId = function()
	local mapId = gRaidDataManager.RaidId
	local position = gCS.MyPlayerManager.PlayerUnit.Position

	return LX6.Gps.MapBlockMgr.GetBlockIdXZ(mapId, position.X, position.Z)
end

M.GetPlayerPosition = function()
	return gCS.MyPlayerManager.PlayerUnit.Position
end

M.EnvSdkReviewWords = function(text, successCallback, failCallback, channel)
	slot4 = gCoroutineManager

	slot4:StartCoroutine(function ()
		local wait = EnvSDK.reviewWordsAsync(text, 1, channel)

		coroutine.yield(wait)

		local result = wait.result

		if result.code == 202 and result.code == 201 then
			successCallback(text)
		else
			failCallback()
		end
	end)
end

M.ResetAnimation = function(animation, clipName)
	local animationState = animation.get_Item(animation, clipName)

	if animationState then
		animation.Play(animation, clipName)

		animationState.time = 0
		animationState.enabled = true

		animation.Sample(animation)

		animationState.enabled = false
	end
end

M.ResetMy3CState = function()
	gUnitStateMgr:ResetMyStateAndClearMove()
	gCS.LogicStateMachineManager.OnSettingOutOfStuck(gCS.MyPlayerManager.PlayerUnit)
end

M.GetAnimationClipLength = function(animation, clipName)
	local animationState = animation.get_Item(animation, clipName)

	return animationState.length
end

M.FinishAnimation = function(animation, clipName)
	if gClientUtils.IsNil(animation) then
		return
	end

	local animationState = animation.get_Item(animation, clipName)

	if animationState then
		animation.Play(animation, clipName)

		animationState.time = animationState.length
		animationState.enabled = true

		animation.Sample(animation)

		animationState.enabled = false
	end
end

M.CheckNameValid = function(name, maxLen, minLen, channel, callback)
	minLen = minLen or 1

	local failCallback = function()
		gDisplayMessageMgr:ShowMessage(MessageConfig.SNSCheckFail)
	end

	local successCallback = function()
		if UX.Utils.NameValidityChecker.CheckName(name, maxLen, minLen) == 0 then
			gDisplayMessageMgr:ShowMessage(MessageConfig.NameInvalid)

			return
		end

		if callback then
			callback()
		end
	end

	gClientUtils.EnvSdkReviewWords(name, successCallback, failCallback, channel)
end

local NameCheckResult = UX.Utils.NameValidityChecker.NameCheckResult
local NameCheckResultStr = {
	[NameCheckResult.NameEmpty] = 65102274,
	[NameCheckResult.NameTooShort] = 65102288,
	[NameCheckResult.NameTooLong] = 65102289,
	[NameCheckResult.PunctuationOnly] = 65102290,
	[NameCheckResult.NameContainsInvalidCharacter] = 65100843
}
M.NameCheckResultStr = NameCheckResultStr

M.CheckNameFormat = function(text, minLen, maxLen)
	if string.is_null_or_empty(text) then
		local textCfg = MessageConfig.GetConfig(NameCheckResultStr[NameCheckResult.NameEmpty])

		return false, textCfg and textCfg.Content or ""
	end

	local visualLength = LX6.Utils.TextUtils.GetVisualLength(text)

	if maxLen >= visualLength then
		local textCfg = MessageConfig.GetConfig(NameCheckResultStr[NameCheckResult.NameTooLong])

		return false, textCfg and textCfg.Content or ""
	end

	if visualLength >= minLen then
		local textCfg = MessageConfig.GetConfig(NameCheckResultStr[NameCheckResult.NameTooShort])

		return false, textCfg and textCfg.Content or ""
	end

	local result = gCS.GuiUtils.IsInputNameValidNoMsg(text, minLen, maxLen)
	local textCfg = MessageConfig.GetConfig(NameCheckResultStr[result])

	return result ~= 0, textCfg and textCfg.Content or ""
end

M.SetCameraRotateEnabled = function(isEnabled, source)
	if M.NotNil(gCS.CameraDataMgr.cameraControllerManager) then
		gCS.CameraDataMgr.cameraControllerManager:SetRotateEnable(isEnabled, source or 0)
	end
end

M.RunCode = function(code, funcScript)
	local f = load(code, nil, "t", funcScript)

	if f then
		local status, err = xpcall(f, tolua.traceback)

		return status, err
	end

	return false
end

M.OnMainPhonePanelOpen = function()
	gNewGuideMgr:NotifySignal(EGuideSignal.PhoneOpen)
	M.PlayPhoneAction()
	M.SetCameraRotateEnabled(false)
end

M.OnMainPhonePanelClose = function()
	M.ExitPhoneAction()
	M.SetCameraRotateEnabled(true)

	gCS.TransitionMgr.showMainCube = false
end

M.PlayPhoneAction = function()
	if gCS.TransitionMgr.IsPlayPhoneAction then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("PlayPhoneAction")
	end

	if gCS.LuaUtils.IsBaseUnitValid(gCS.MyPlayerManager.PlayerUnit) then
		local actionKey = gUtils:GetActionKey(LTConfig.WeatherConfig.CompletionAction, gLuaFightConstants.ACTION_GROUP_01)
		local isPlayWeatherCompletionAction = gCS.AnimationManager.GetCurrentLayerActionKey(gCS.MyPlayerManager.PlayerUnit) ~= actionKey

		if isPlayWeatherCompletionAction then
			if gGameManager.Env.IsENABLE_PROFILER then
				gGameManager:EndSample()
			end

			return
		end

		for i = 0, LTConfig.PhonePanelActionConflictConfig.count - 1 do
			local actionConflictCfg = LTConfig.PhonePanelActionConflictConfig.LoadAt(i)
			local actionCheckFunction = gPhonePanelRuleCheckManager.actionCheckFunctions[actionConflictCfg.Id]

			if actionCheckFunction() then
				if actionConflictCfg.FunctionStartType ~= gClientConst.PHONE_PANEL_FUNCTION_START_TYPE.Normal then
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
		gGameManager:EndSample()
	end
end

M.ExitPhoneAction = function(skipCheckSwitchAction)
	if not gCS.LuaUtils.IsBaseUnitValid(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

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

	L18.Spoon.Task.SpoonRoomMgr.Instance:SetLockRoomProbe(false)
end

M.CloseMainPhonePanel = function(isForce)
	gMainPhoneUtils.CloseMainPhonePanel(isForce)
end

M.HighSpeedDown = function(self)
end

M.PrintLog = function(self)
	local LogUtils = LX6.Utils.LogUtilsLua

	local prepare = function(...)
		local n = select("#", ...)
		local args = {
			...
		}

		for i = 1, n do
			local v = args[i]

			if v ~= nil then
				args[i] = "nil"
			elseif type(v) ~= "table" then
				args[i] = table.tostring(v, false)
			end
		end

		table.insert(args, "\n")
		table.insert(args, debug.traceback())

		return unpack(args)
	end

	print_warn = function(...)
		LogUtils.Notice(prepare(...))
	end

	print_debug = function(...)
		LogUtils.Notice(prepare(...))
	end
end

M.CloseMainPhonePanelCs = function(self, isForce)
	M.CloseMainPhonePanel(isForce)
end

M.ClearPaoKuState = function(self, noClearShootOrCrouch, leaveMoto, noClearMotoSpeed, noClearFeiSuoCrouch, noBreakMind, noClearMoveGround, autoIdle, noClearUpperStateAction)
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

M.OpenMainPhonePanel = function()
	if gPanelManager:IsPanelShowing(gPanelId.S_HALF_PHONE_APP_HOME_PANEL) then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_HALF_PHONE_APP_HOME_PANEL)
end

M.CheckMainPhoneHalfScreenEnable = function()
	if gGmUtils.isHalfScreenEnable ~= nil then
		return true
	else
		return gGmUtils.isHalfScreenEnable
	end
end

M.CheckMainPhoneIsShowing = function()
	local currentPanelId = gClientUtils.currentMainPanelId

	if currentPanelId and gPanelManager:IsPanelShowing(currentPanelId) then
		return true
	end

	return false
end

M.IsMainPhoneExist = function()
	local panelIdList = M.GetMainPhonePanelIdList()

	for _, panelId in ipairs(panelIdList) do
		if gPanelManager:IsPanelShowing(panelId) then
			return true
		end
	end

	return false
end

M.GetMainPhonePanelId = function()
	local mainPanelId = gClientUtils.currentMainPanelId

	if mainPanelId and gPanelManager:IsPanelShowing(mainPanelId) then
		return mainPanelId
	end

	return gPanelId.S_HALF_PHONE_APP_HOME_PANEL
end

M.CheckIsMainPhonePanelId = function(panelId)
	local panelIdList = M.GetMainPhonePanelIdList()

	return table.find(panelIdList, panelId)
end

M.GetMainPhonePanelIdList = function()
	return M.mainPhonePanelIdList
end

M.OpenMap = function()
	if gMapUtils:CheckRaidCanOpenMap() then
		gPanelManager:CheckShow(gPanelId.S_NEW_MAP_PANEL)
	end
end

M.GetCurrentMiniGameManager = function()
	if gBasketballGameManager.currentGame then
		return gBasketballGameManager
	end

	if gDartsGameManager.preEnd then
		gDartsGameManager.preEnd = false

		return gDartsGameManager
	end
end

M.GetIgnorePauseCheckPanelIdList = function()
	local mainPhonePanelIdList = M.GetMainPhonePanelIdList()
	local otherIgnorePanelIdList = {}

	return array.concat(mainPhonePanelIdList, otherIgnorePanelIdList)
end

M.GetOssPostImage = function(bucketName, size)
	return ("%s?x-oss-process=image/resize,m_fill,w_%d,h_%d"):format(bucketName, size.x, size.y)
end

M.IsControllerMode = function()
	local navMgr = SGUI.UNavigationMgr.Inst

	return M.NotNil(navMgr) and navMgr.CurNavigationMode == SGUI.NavigationMode.None
end

M.FormatTimeToMMSS = function(time)
	local minutes = math.floor(time / 60)
	local seconds = math.floor(time - minutes * 60)

	return gString.Format("%02d:%02d", minutes, seconds)
end

M.RichTextToPlain = function(richText)
	local name = gPlayerManager.infoLogin.bindData.name

	if name ~= nil then
		print_error("在未登录时调用了 RichTextToPlain！")

		name = ""
	end

	return string.gsub(richText, "<player>", name)
end

M.InitNavAreasInChildren = function(widget, panelId, gamepadBar, forceSetGamepadBar)
	if M.IsNil(widget) or panelId ~= nil then
		print_error("bad argument to 'SetAreaPanelId', widget", widget, "panelId", panelId)

		return
	end

	local navAreas = widget.GetComponentsInChildren(widget, typeof(SGUI.UNavigationArea), true)

	for i = 0, navAreas.Length - 1 do
		local navArea = navAreas[i]

		gCS.LuaUtils.SetNavAreaPanelId(navArea, panelId)

		if forceSetGamepadBar or M.IsNil(navArea.gamePadBar) then
			navArea.gamePadBar = gamepadBar
		end
	end
end

M.CheckPanelSystemUnlocked = function(panelId)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panelId)

	if panelCfg and panelCfg.SystemId and panelCfg.SystemId <= 0 then
		return gSystemUnlockMgr:IsUnlock(panelCfg.SystemId)
	end

	return true
end

M.GetCurrentLanguageId = function()
	local languageProfile = LX6.Engine.ProfileManager.languageProfile

	return languageProfile.textLanguage
end

M.FormatDistance = function(distance)
	if distance > 1000 then
		distance = distance / 1000

		return ("%.1fkm"):format(distance)
	else
		return ("%dm"):format(math.floor(distance + 0.5))
	end
end

M.GetGrowthIdByLv = function(targetLv)
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if growthCfg.Lv ~= targetLv then
			return growthCfg.Id
		end
	end
end

M.GetPlayerCurrentExp = function()
	local currentExp = gPlayerManager.infoMinor.bindData.fan123

	return currentExp
end

M.GetPlayerLevel = function()
	return gPlayerManager.infoMinor.bindData.level
end

M.GetFactionInfo = function(factionId)
	local factionInfoDic = gPlayerManager.infoAchievement.bindData.FactionInfoDic

	return factionInfoDic and factionInfoDic[factionId]
end

M.CsGetFactionInfo = function(self, factionId)
	return gClientUtils.GetFactionInfo(factionId)
end

M.GetFameLevel = function(self, factionId)
	local info = gClientUtils.GetFactionInfo(factionId)

	return info and info.DispositionLevel or 999
end

M.LuaPatchTest = function()
	return 0
end

M.CheckHasLevelReward = function()
	local hasUnlocked = gMainPhoneUtils.CheckFansSystemUnlocked()

	if not hasUnlocked then
		return false
	end

	local levelRewardList = gPlayerManager.infoMinor.bindData.levelRewardList

	return #levelRewardList >= 0
end

M.GetTargetLevelExp = function(targetLevel)
	targetLevel = targetLevel or gPlayerManager.infoMinor.bindData.level
	local growthId = gClientUtils.GetGrowthIdByLv(targetLevel)
	local growthCfg = LTConfig.GrowthConfig.GetConfig(growthId)

	return growthCfg and growthCfg.Exp or 0
end

M.CheckIsLinkMode = function()
	return gLinkManager.LinkMode == UX.Game.LinkMode.None
end

M.FormatWithThousandsSeparator = function(num)
	local str = tostring(num)
	local formatted = ""
	local length = #str

	for i = 1, length do
		formatted = formatted .. str.sub(str, i, i)

		if (length - i) % 3 ~= 0 and i == length then
			formatted = formatted .. ","
		end
	end

	return formatted
end

M.ShowCommonScrollNumber = function(widget, startNumber, endNumber)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	store.scrollNumGroup.startNum = startNumber
	store.scrollNumGroup.targetNum = endNumber

	store.scrollNumGroup:SetToStartNum()
	store.scrollNumGroup:Play()
end

M.CheckCurrentIsDefaultSpirit = function()
	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	return currentSpiritId ~= LTConfig.FightSpiritConfig.DefaultMale or currentSpiritId ~= LTConfig.FightSpiritConfig.DefaultFemale
end

M.GetCurrentSpiritDisplayName = function()
	if gClientUtils.CheckIsLinkMode() then
		return gPlayerManager.infoLogin.bindData.playerName
	end

	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	if gSpiritManager.CheckIsDefaultSpiritId(currentSpiritId) then
		return gPlayerManager.infoLogin.bindData.playerName
	end

	local fightSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(currentSpiritId)

	return fightSpiritCfg.Name
end

M.SetCSIsInFeisuoState = function(self, isInFeisuo)
	gPlayerManager.main.bindData.isInFeisuo = isInFeisuo

	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.FeiSuo01, isInFeisuo)
end

M.OpenChatPanel = function(self, args)
	gNpcChatUtils.OpenChatPanel(args)
end

M.PlayGamePlayTimeline = function(self, gamePlayId, timelineName, transform, callback)
	if gamePlayId ~= GamePlayTypeConfig.Dance808 then
		gBengdiActionManager:PlayInviteTimeline(timelineName, transform, callback)
	end
end

M.PlaySingleAction = function(unit, actionType, group, allTime, fadeInTime, startTime, realEnd, actionEndCB, transitionSchemaIndex)
	group = group or unit.State.ActionGroupId
	allTime = allTime or -1
	fadeInTime = fadeInTime or -1
	startTime = startTime or 0
	realEnd = realEnd or false
	transitionSchemaIndex = transitionSchemaIndex or 0

	gCS.AnimControllerManager.PlayAction(unit, actionType, group, allTime, startTime, fadeInTime, realEnd, actionEndCB, transitionSchemaIndex)
end

M.PlayQueuedActions = function(self, unit, actions, actionGroup, times, fadeInTime, startTime, realEnd, actionEndCB)
	local actionT = actions
	local timesT = times
	local fadeInTimeT = fadeInTime
	local actionsType = type(actions)
	local timesType = type(times)
	local fadeInTimeType = type(fadeInTime)
	actionGroup = actionGroup or unit.State.ActionGroupId

	if actionsType == "table" and actionsType == "number" then
		actionT = actions.ToTable(actions)
	end

	if timesType == "table" and timesType == "number" then
		timesT = times.ToTable(times)
	end

	if fadeInTime then
		if fadeInTimeType == "table" and fadeInTimeType == "number" then
			fadeInTimeT = fadeInTime.ToTable(fadeInTime)
		elseif fadeInTimeType ~= "number" then
			fadeInTimeT = {
				fadeInTimeT
			}
		end
	end

	if startTime ~= nil then
		startTime = 0
	end

	gCS.AnimControllerManager.PlayQueuedActions(unit, actionT, actionGroup, timesT, fadeInTimeT, startTime, realEnd, actionEndCB)
end

M.GetNpcCultivationId = function(firstSpiritId)
	firstSpiritId = firstSpiritId or gSpiritManager:GetCurFirstSpiritTid()
	local count = LTConfig.NpcCultivationConfig.count

	for i = 0, count - 1 do
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.LoadAt(i)

		if npcCultivationCfg.FightSpiritID ~= firstSpiritId then
			return npcCultivationCfg.Id
		end
	end
end

M.CheckIsGamePadMode = function()
	return SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
end

M.CheckIsForbidRequestRpc = function()
	return gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene or not gCS.NetworkManager.Instance:IsServerConnected()
end

M.GetTaskRewardList = function(taskEventId)
	local dropList = {}
	local taskLineInfo = gTaskNodeManager:GetTaskLineById(taskEventId)

	if taskLineInfo then
		for i = 1, #taskLineInfo.TaskList do
			local taskId = taskLineInfo.TaskList[i]
			local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)

			if taskCfg and taskCfg.Drop <= 0 then
				table.insert(dropList, {
					dropId = taskCfg.Drop
				})
			end
		end
	end

	return gCommonItemManager:GetSingleSortedListRenderData(dropList, true)
end

M.CheckReachWorldLifeDropLimit = function(self, worldLifeType)
	local maxWorldLifeCount = gClientUtils.GetWorldLifeDropMaxCount(worldLifeType)

	if maxWorldLifeCount >= 0 then
		return false
	end

	local currentDropCount = gPlayerManager.infoMinor.bindData.playerInfoAtmosphereGameplay[worldLifeType] or 0

	return maxWorldLifeCount > currentDropCount
end

M.GetWorldLifeDropMaxCount = function(worldLifeType)
	if worldLifeType ~= LTConfig.WorldLifeTypeConfig.Scratch then
		return LTConfig.PoiGameConfig.Scratch_DailyRewardLimit
	end

	return -1
end

M.GetLinkHeadId = function(memberInfo)
	if not memberInfo then
		return 0
	end

	if memberInfo.LinkPzHeadInfo and memberInfo.LinkPzHeadInfo.SystemHeadId and memberInfo.LinkPzHeadInfo.SystemHeadId == 0 then
		return memberInfo.LinkPzHeadInfo.SystemHeadId
	end

	return memberInfo.PzHeadInfo and memberInfo.PzHeadInfo.SystemHeadId or 0
end

M.GetMyLinkHeadId = function()
	local bd = gPlayerManager.infoLogin.bindData

	if M.CheckIsLinkMode() and bd.infoLinkPzHeadInfo and bd.infoLinkPzHeadInfo.SystemHeadId and bd.infoLinkPzHeadInfo.SystemHeadId == 0 then
		return bd.infoLinkPzHeadInfo.SystemHeadId
	end

	return bd.infoPzHeadInfo and bd.infoPzHeadInfo.SystemHeadId or 0
end

M.MapTeleport = function()
	gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
	gMainPhoneUtils.CloseMainPhonePanel(true)
	gMessageManager:SendMessage(gEventConstants.ON_MAP_TELEPORT)
end

gClientUtils = M
