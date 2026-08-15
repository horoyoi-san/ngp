local CommunityManager = require("LX6/GUI/Community/CommunityManager")
local V3XingZheFileMgr = require("LX6/GUI/HunLun/V3XingZheFileMgr")
local LayerConstants = LX6.Constants.LayerConstants
local SkillConfig = LTConfig.SkillConfig
local GameObject = UnityEngine.GameObject
local RaidConfig = LTConfig.RaidConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local GameConfig = LTConfig.GameConfig
local AgentConfig = LTConfig.AgentConfig
local BattleGadgetTerrainKillingConfig = LTConfig.BattleGadgetTerrainKillingConfig
local xpcall = xpcall
local UnitOperateUtils = require("LX6/Utils/UnitOperateUtils")
local module = {
	JoyStickMove = Vector2.zero,
	LastJoyStickMove = Vector2.zero,
	ShowHpUnderControl = function (self, unit)
		if unit then
			local pid = unit.Pid
			local dataSet = gDataSetManager:GetUnitData(pid)

			if dataSet then
				dataSet.showHpOrUnderAttack = true
			end

			if gBattleMgr.hideHpBarTimer[pid] then
				gLuaTimeMgrUtils.CancelUnitDelay(gBattleMgr.hideHpBarTimer[pid])

				gBattleMgr.hideHpBarTimer[pid] = nil
			end

			gBattleMgr.hideHpBarTimer[pid] = gLuaTimeMgrUtils.UnitDelay(pid, GameConfig.HPBarShowTime, function ()
				if dataSet then
					dataSet.showHpOrUnderAttack = false
				end
			end, nil, nil, nil, false, true)
		end
	end,
	OnUnitUnderAttack = function (self, pid, attackerPid, hpAmount)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if not unit then
			return
		end

		if hpAmount > 0.5 then
			self:ShowHpUnderControl(unit)
		end
	end,
	OnUnitHpMaxChange = function (self, pid, maxhp)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if not unit then
			return
		end

		gHudMgr:HpChanged(pid)

		local dataSet = gDataSetManager:GetUnitData(pid)

		if dataSet ~= nil then
			dataSet.maxhp = maxhp
		end
	end,
	OnUnitHpChange = function (self, pid, hp, maxhp, shield)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if not unit then
			return
		end

		if unit.ClientData.Hp ~= hp and unit.ClientData.Hp < hp and unit.ClientData.Hp > 1 and unit.ClientData.Hp < unit.ClientData.MaxHp then
			self:ShowHpUnderControl(unit)
		end

		unit.ClientData.Hp = hp
		unit.ClientData.MaxHp = maxhp

		if unit.ClientData.Shield ~= shield then
			if unit.ClientData.Shield < shield then
				self:ShowHpUnderControl(unit)
			end

			unit.ClientData.Shield = shield
		end

		gHudMgr:HpChanged(pid)
		gBattlePetsMgr:OnPokemonHpChange(pid)

		local data = gDataSetManager:GetUnitData(pid)

		if data ~= nil then
			data.hp = hp
			data.maxhp = maxhp
			data.shield = shield
		end

		if unit.IsMe then
			gMessageManager:SendMessage(gEventConstants.PLAYER_HP_CHANGE, pid)
		end
	end,
	OnUnitShowWeaponBar = function (self, pid, show)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit == nil then
			return
		end
	end,
	OnUnitShowPartBar = function (self, pid, index, show)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit == nil then
			return
		end

		gHudMgr:ShowPartShieldBar(pid, index, show)
	end,
	CheckAssistantedShowHp = function (self, pid)
		local data = gDataSetManager:GetUnitData(pid)

		if not data then
			return
		end

		local showHp = not data.beingAssassinated

		self:OnUnitShowHp(pid, showHp)
	end,
	OnUnitShowHp = function (self, pid, show)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit == nil then
			return
		end

		gHudMgr:ShowHpBar(pid, show)
	end,
	CreateUnitDataSet = function (self, pid, cs_unit)
		gDataSetManager:CreateUnitData(pid, cs_unit.IsMe, cs_unit)
	end,
	OnUnitResetDataSet = function (self, pid, cs_unit)
		gDataSetManager:CreateUnitData(pid, cs_unit.IsMe, cs_unit)
	end,
	OnUnitDestroy = function (self, pid)
		gMessageManager:SendMessage(gEventConstants.UNIT_DESTROY, pid)

		local dataset = gDataSetManager:GetUnitData(pid)

		if dataset then
			gGpsManager:TryRemoveMapGuideByEnemyId(dataset.subType)
		end

		gGpsManager:RemoveGPSById(pid, gTaskGpsType.WeakGuide)
		gDataSetManager:RemoveUnitData(pid)
	end,
	OnUnitCreateHp = function (self, pid)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit == nil then
			return
		end

		gHudMgr:CreateHpBar(pid)
	end,
	SetUnitIsDead = function (self, unitId, value)
		local unitDataSet = gDataSetManager:GetUnitData(unitId)

		if unitDataSet then
			unitDataSet.isDead = value
		end
	end,
	CloseMainChat = function (self)
		return
	end,
	OnShowId = function (self, pid, visible, value)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit == nil then
			return
		end

		gHudMgr:OnShowId(pid, visible, value)
	end,
	OnShowHpNum = function (self, pid, visible)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit == nil then
			return
		end

		gHudMgr:OnShowHpNum(pid, visible)
	end,
	OnShowDamAndDefNum = function (self, pid, visible)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit == nil then
			return
		end

		gHudMgr:OnShowDamAndDefNum(pid, visible)
	end,
	OnShowLevelNum = function (self, pid, visible)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit == nil then
			return
		end

		gHudMgr:OnShowLevelNum(pid, visible)
	end,
	DoDialogAction = function (self, actionStr, dialogId, npc)
		if actionStr then
			gDialogAction:RunFunc(actionStr, dialogId, npc)
		end
	end
}

local function PlayNpcTalks(npc, infoList)
	for i = 1, #infoList do
		local value = infoList[i]

		if value ~= nil and npc ~= nil then
			local str = value.message
			local time = value.time

			if str ~= nil and time ~= nil then
				npc:UnitTalk(str, time, false)

				local soundCfgID = value.action

				if soundCfgID and soundCfgID > 0 then
					gCS.BaseUnitUtils.PlayUnitSound(npc.Pid, soundCfgID)
				end

				coroutine.wait(time)
			end
		end
	end
end

function module:AgentPlotInteraction(isPlayerNear, unit)
	local agentConfig = AgentConfig.GetConfig(unit.ClientData.SubType)
	local interactionConfig = gInteractionManager:GetAgentInteractConfig(agentConfig)
	local infoList = nil
	local talks = {}

	if interactionConfig then
		if isPlayerNear then
			if interactionConfig.EnterAction then
				infoList = interactionConfig.EnterAction
			end
		elseif interactionConfig.LeaveAction then
			infoList = interactionConfig.LeaveAction
		end
	end

	if infoList then
		for i = 1, #infoList do
			local value = infoList[i]

			table.insert(talks, value)
		end
	end

	if talks and #talks > 0 then
		if unit == nil then
			return
		end

		coroutine.start(PlayNpcTalks, unit, talks)
	end
end

function module:OnUnitVisiableChange(pid, isInVisiable)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit == nil then
		return
	end

	local dataset = gDataSetManager:GetUnitData(pid)

	if dataset then
		dataset.realInVisiable = isInVisiable
	end

	gCS.EffectMgr:ShowOrHideEffectForUnit(pid, isInVisiable)
	gLockTargetMgr:CheckShowLockEffectActiveSgui(unit)
end

function module:ShowBattleMsg(value)
	gBattleMgr.ShowBattleMsg = value
end

function module:EnableNewCombo(value)
	gBattleMgr.IsUseNewCombo = value
end

function module:SetMyPid(value)
	gPlayerManager.infoBase.bindData.Pid = value
end

function module:OnSurveyDoneFinishAsk()
	gClientToGameDelegate:AskFinishQuestionnaire().Callback = function (err)
		gPlayerManager.infoMinor.bindData.Questionnaire = GameConfig.SurveyVersion

		gMessageManager:SendMessage(gEventConstants.WELFARE_QUESTION_DONE)
	end
end

function module:LuaLoadFile(path, t)
	gLuaLoadFiles.AddFile(path, t)
end

function module:AskClientAction(type, args1, args2, args3)
	return
end

function module:GetCustomRaidName(raidId)
	if gUIUtils:IsInOtherWorld() then
		local cfg = RaidConfig.GetConfig(raidId)

		if cfg then
			return cfg.Name
		end
	else
		local cfg = RaidConfig.GetConfig(raidId)

		if cfg then
			return cfg.Name
		end

		print_error(" raid Id ", raidId, "不存在，确认所填标签")

		return "未知地点"
	end
end

function module:InitMyUnitState()
	local myPlayerUnitId = gCS.MyPlayerManager.PlayerUnitId

	if not ulong.equals(myPlayerUnitId, ulong.zero) then
		local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

		if not gDriveVehiclesManager.isDriveMode then
			myPlayerCSUnit:SetCCMoveEnable(true)

			if not gCS.UnitStateMgr:HasState(myPlayerUnitId, UnitStateConfig.Sitting) then
				myPlayerCSUnit:SetGroundSolvingActivation(true)
			else
				myPlayerCSUnit:SetGroundSolvingActivation(false)
			end
		end
	end
end

function module:SetIsOnJoystickMove(value)
	gUnitOperateManager.isOnJoystickMove = value

	if value == false then
		self.JoyStickMove.x = 0
		self.JoyStickMove.y = 0
		gUnitOperateManager.joyStickPercent = 0
		gCS.TransitionMgr.joyStickPercent = 0
	end
end

function module:ReloadLuaFile(fileName)
	local fullPath = ""
	local tab1 = nil
	local cur = ""
	local len = string.len(fileName)

	for key, _ in pairs(package.preload) do
		cur = tostring(key)

		if string.find(cur, fileName) then
			local len1 = string.len(cur)
			local s = string.sub(cur, len1 - len, len1 - len)

			if s == "." and string.sub(cur, len1 - len + 1, len1) == fileName then
				tab1 = package.preload[key]
				fullPath = cur

				break
			end
		end
	end

	for key, _ in pairs(package.loaded) do
		cur = tostring(key)

		if string.find(cur, fileName) then
			local len1 = string.len(cur)
			local s = string.sub(cur, len1 - len, len1 - len)

			if s == "." and string.sub(cur, len1 - len + 1, len1) == fileName then
				tab1 = package.loaded[key]
				fullPath = cur

				break
			end
		end
	end

	if fullPath ~= "" and tab1 then
		local tab2 = dofile(fullPath)

		if tab2 then
			for k, v in pairs(tab2) do
				tab1[k] = v
			end
		end
	end

	print_warn("[ReloadLuaFile]", fileName, fullPath, fullPath ~= "" and "success" or "failed")
end

function module:CancelAllAction(pid)
	gLuaTimeMgrUtils.CancelAllUnitDelay(pid)
end

function module:ApplyProfileToLua()
	gUtils:InitLanguage()
end

function module:isShowFullScreenChange(value)
	gGameManager.Cache.isShowFullScreen = value
end

function module:RefreshServerTime(serverTime, serverUnixTime)
	gLuaDataManager.serverTime = serverTime
	gLuaDataManager.serverUnixTime = serverUnixTime
end

function module:LoadQualityData(deviceLevel, qualityLevel)
	gQualityManager:LoadQualityData(deviceLevel, qualityLevel)
end

function module:LoadDetailQualityDataFromGameProfile()
	gQualityManager:LoadDetailQualityDataFromGameProfile()
end

function module:GenSpawnInfoSimple(npcInfo, show)
	return {
		isCreateForTask = false,
		actionId = npcInfo.actionId,
		hideEffectId = npcInfo.hideEffectId or 0,
		spawnEffectId = npcInfo.spawnEffectId or 0,
		isTemp = npcInfo.isTemp or false,
		gpsOffsetY = npcInfo.gpsOffsetY or 0,
		spiritAcquisitionCfgId = npcInfo.spiritAcquisitionCfgId or 0,
		layer = npcInfo.layer or -1,
		modelId = npcInfo.modelId or 0,
		petPerformData = npcInfo.petPerformData,
		randomModelCfgId = npcInfo.randomModelCfgId or 0,
		treeName = npcInfo.treeName,
		stimIDList = npcInfo.stimIDList,
		forbidAetherAI = npcInfo.forbidAetherAI,
		indoorID = npcInfo.indoorID or 0,
		metroCarriageId = npcInfo.metroCarriageId or 0,
		metroLineId = npcInfo.metroLineId or 0,
		needFTF180DegreeInteract = npcInfo.NeedFTF180DegreeInteract,
		playerFTF180DegreeInteract = npcInfo.PlayerFTF180DegreeInteract
	}
end

function module:SyncGameSwitchToClient(keys, values)
	keys = keys:ToTable()
	values = values:ToTable()

	for i, key in ipairs(keys) do
		local value = values[i]

		gGameSwitch.Sync(key, value)
	end

	CommunityManager.SetEnableCommunity(gGameSwitch.EnableCommunity)
	V3XingZheFileMgr.SetEnableXingZhe(gGameSwitch.DisableEditXingZheDangAn)
	gMessageManager:SendMessage(gEventConstants.ON_GAMESWITCH_CHANGED)
end

function module:GmRunLua(content)
	local f = load(content, nil, "t")

	if f then
		local status, err = xpcall(f, tolua.traceback)

		if not status then
			print_error(err)
		end
	else
		print_error("QA请忽略 GmRunLua Compile Error")
	end
end

function module:RunRaidRoomAction(roomId, taskId, codeStr)
	if codeStr and codeStr ~= "" then
		gTaskNodeManager.RunScriptRoomId = roomId

		gDialogAction:RunCodeByTask(codeStr, taskId)
	end
end

function module:ClearMyUnitState(pid)
	local unit = gDataSetManager:GetUnitData(pid)

	if unit and unit.isMe then
		gClientUtils:ClearPaoKuState()
		gUnitStateMgr:ResetMyStateAndClearMove(true)
	end
end

function module:UnitBodyRadiusChange(pid, value)
	return
end

function module:BackToLogin()
	gLoginManager:BackToLogin()
end

function module:KickToLogin()
	gLoginManager:KickToLogin()
end

function module:SetRootMotionAllTime(time)
	return
end

function module:ClearSpoon()
	gSpoonMgr:ClearSpoon()
end

function module:OnJoyStickMove(x, y, joyStickPercent)
	gCS.SkillJumpManager.Instance:CheckPressJoyStickTime(x, y)

	self.JoyStickMove.x = x
	self.JoyStickMove.y = y
	gUnitOperateManager.joyStickPercent = joyStickPercent
	gCS.TransitionMgr.joyStickPercent = joyStickPercent

	if self.LastJoyStickMove.x ~= x or self.LastJoyStickMove.y ~= y then
		local old = gUtils:GetAngleYByDirectionV2(self.LastJoyStickMove)
		local new = gUtils:GetAngleYByDirectionV2(self.JoyStickMove)

		if GameConfig.CanSwitchUnitJoyAngle < Mathf.Abs(new - old) then
			self.LastJoyStickMove.x = x
			self.LastJoyStickMove.y = y
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_JOYSTICK_MOVE)
end

function module:TrampolineTrigger(x, z, index)
	gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
end

function module:MyEnterWASDMove(x, y, z)
	if self:GetSkillData(gCS.MyPlayerManager.PlayerUnit) and self:GetSkillData(gCS.MyPlayerManager.PlayerUnit).skillId then
		local skillconfig = SkillConfig.GetConfig(self:GetSkillData(gCS.MyPlayerManager.PlayerUnit).skillId)

		if skillconfig and skillconfig.RotateSpeed.stoptime > 0 then
			gCS.MyPlayerManager.PlayerUnit:SetFacingDirection(x, y, z)
		end
	end

	if not self.tempTable then
		self.tempTable = {}
	end

	self.tempTable[1] = x
	self.tempTable[2] = y
	self.tempTable[3] = z

	gMessageManager:SendMessage(gEventConstants.READY_TO_MOVE, self.tempTable)
end

function module:GetSkillData(cs_unit)
	if cs_unit then
		return gCS.BattleManager.GetSkillData(cs_unit)
	end

	return nil
end

function module:OnChairTriggerChange(instanceId, chairType, eventId, index, forwardTriggerId, leftTriggerId, rightTriggerId, backTriggerId, spotPos, spotDir, finalPos, finalDir, ...)
	return
end

function module:GmResetAllTaskNpc()
	return
end

function module:KeyUpNotCheck(enable)
	gLuaDataManager.keyUpNotCheck = enable
end

function module:UpdateJobSex(pid, sexType)
	return
end

function module:ClearFreePaokuActiVeArea()
	return
end

function module:ClearPaoku(noCheckAction)
	local myPlayerUnitId = gCS.MyPlayerManager.PlayerUnitId

	if not ulong.equals(myPlayerUnitId, ulong.zero) then
		local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

		gClientUtils:ClearPaoKuState(false, false)

		if not gCS.MyPlayerManager.isMotorRider then
			myPlayerCSUnit.State.ActionGroupId = gLuaFightConstants.ACTION_GROUP_01

			gCS.BattleManager.SetBattleActionGroupId(myPlayerCSUnit, gLuaFightConstants.ACTION_GROUP_01)
		end

		gCsToLuaHandler:ClearFreePaokuActiVeArea()
		gCS.LuaUtils.TouchGround(myPlayerCSUnit, true, true)

		if not noCheckAction then
			gCS.AnimControllerManager.CheckActionEndPlayByPid(myPlayerUnitId)
		end
	end
end

function module:AskEnemyItemPickUp(pid, bindItemIndex)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit and unit.isMaster then
		gClientToGameSceneDelegate:AskEnemyItemPickUp(pid, bindItemIndex)
	end
end

function module:BeginBeeGame()
	gSceneGameRuleManager:CreateProcedureGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)
end

function module:KillBeeGameAllEnemy()
	local gameRule = gSceneGameRuleManager:GetGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)

	if gameRule then
		gameRule:KillAll()
	end
end

function module:LostFocusJumpKeyUpFunc()
	if not gLuaDataManager.keyUpNotCheck then
		UnitOperateUtils.LostFocusJumpKeyUpFunc(gCS.MyPlayerManager.PlayerUnit)
	end
end

function module:OnHitNpc(unitId, hitUnitId, skillId, hitPoint)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.NonMindSkillTrigger, {
		skillId = skillId,
		hitId = hitUnitId
	})
end

function module:GMUnlockMiniChat(enable)
	gChatManager.isUnLockMiniChat = enable
end

function module:OnSyncRemoveSpoonDestructible(spoonId)
	gMessageManager:SendMessage(gEventConstants.ON_SPOON_DESTRUCTIBLE_REMOVE, spoonId)
end

function module:OnSyncRemoveSpoonDestructibleGps(gpsGroupIdIndex)
	if string.contains(gpsGroupIdIndex, "@") then
		-- Nothing
	end
end

function module:OnRefreshSpoonDestructibleGps(gpsGroupIdIndex, position)
	if string.contains(gpsGroupIdIndex, "@") then
		-- Nothing
	end
end

function module:AddCSGps(gpsId, posiiton, iconId)
	if iconId == nil or iconId == 0 then
		iconId = gTaskManager.TaskIconId[4]
	end

	local gpsData = {
		InstanceId = "csGps" .. gpsId,
		GpsType = gTaskGpsType.Follow,
		TargetPos = posiiton,
		IconId = iconId
	}

	gGpsManager:AddGPS(gpsData)
end

function module:RemoveCSGps(gpsId)
	gGpsManager:RemoveGPSById("csGps" .. gpsId, gTaskGpsType.Follow)
end

function module:TestTypeOf()
	print_error("TestTypeOf", typeof(UnityEngine.GameObject))
end

function module:RefreshEnterWallInfo()
	gCS.ClimbManager.EnterOrLeaveFreeBuilding(true, 0, true)
end

function module:crash()
	ulong.crash(1, 0)
end

function module:AskSwitchPlayerSpirit(templateId)
	gClientToGameSceneDelegate:AskSwitchPlayerSpirit(templateId)
end

function module:AskDoorTransfer(roomId, toRoomId, position)
	gClientToGameSceneDelegate:AskDoorTransfer(0, roomId, toRoomId, position)
end

function module:GetCurrentTask()
	local id = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]
	local curTaskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(id)

	if curTaskInfo then
		local nane = curTaskInfo.ConfigData.Name

		return id .. " " .. nane
	end

	return "no task"
end

function module:GMSetFpsUnlimit()
	gQualityManager:ChangeFPS(300)
end

function module:GMOpenBanDeviceCheck()
	gQualityManager.CanEnterGame = true
end

function module:OnAskFlagChange(value)
	gLuaDataManager.AskFlag = value
end

function module:GMResetOperationModeKey()
	local keyName = "PLAYER_SELECTED_OPERATION_MODE" .. ulong.tostring(gPlayerManager.infoBase.bindData.Pid)

	UnityEngine.PlayerPrefs.SetInt(keyName, 0)
end

function module:OnRemoveDestructibleGUI(id)
	gHudMgr:DestroyDestructTarget(id)
	gCS.LockTargetMgr:OnDestructibleCantLock(id)
end

function module:AutoCloseDeadPanelAndRevive(enable)
	gDeadManager.autoCloseDeadPanelAndRevive = enable
end

function module:StartRest(startGameTime, hour, min, gameVideoId, callback)
	gTimeAppUtils.StartRestTime(hour, min, true, callback, startGameTime, gameVideoId)
end

function module:CkeckIsOpenPhone()
	return gCS.PaoKuManager.ParkourStateLua == LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.OpenPhone
end

function module:GetHudTargetPostion(pid)
	if gLuaUIMgr.hudPanel then
		return gLuaUIMgr.hudPanel.GetHudTargetPostion(pid)
	end

	return nil
end

function module:ClickSpoonClientTest(graphName, nodeId)
	for _, contextData in pairs(gSpoonClientMgr.contexts) do
		if contextData.graphName == graphName then
			local data = {
				nodeId = nodeId
			}

			gSpoonClientMgr:ReleaseContextEvent(contextData.instanceId, gSpoonEventType.SlotDebugClick, data)

			return
		end
	end
end

function module:ClickSpoonGadgetTest(graphName, nodeId, entityId, eventName, exBool)
	for _, contextData in pairs(gSpoonClientMgr.contexts) do
		if entityId == contextData.instanceId then
			local data = {
				isDebug = true,
				nodeId = nodeId,
				isEnter = exBool
			}

			if gSpoonEventType[eventName] then
				gSpoonClientMgr:ReleaseContextEvent(contextData.instanceId, gSpoonEventType[eventName], data)
			else
				print_error("该节点类型还未支持调试执行，遇到请反馈小白")
			end

			return
		end
	end
end

function module:TelePortCurrentTaskPos()
	if gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] > 0 then
		local taskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])
		local pos = taskInfo.UseTansGuide and not gCS.LuaUtils.IsNull(taskInfo.TargetTrans) and taskInfo.TargetTrans.position or taskInfo.TargetPos

		if pos then
			L50.Gm.AutoQaFunctions.TeleportXYZ(pos.x, pos.y, pos.z)
		else
			gDisplayMessageMgr:ShowMessageContentDebug("无法传送到此")
		end
	end
end

function module:ModifyAssassinationDirection(enable)
	gFeiSuoCrouchManager.modifyAssassinationDirection = enable
end

function module:SetSpoonClientGraphReuse(enable)
	gSpoonClientMgr:SetSpoonClientGraphReuse(enable)
end

function module:GMSetQualityDetailLevel(detailName, level)
	gQualityManager:GMSetQualityDetailLevel(detailName, level)
end

function module:GMSetResolutionScreen(name, value)
	gQualityManager:GMSetQualityDetails("resolutionScreen", name, value)
end

function module:GMSetResolutionShadow(name, value)
	gQualityManager:GMSetQualityDetails("resolutionShadow", name, value)
end

function module:GMSetMatLevel(name, value)
	gQualityManager:GMSetQualityDetails("matLevel", name, value)
end

function module:GMSetCharCount(name, value)
	gQualityManager:GMSetQualityDetails("charCount", name, value)
end

function module:GMSetCharMeshTex(name, value)
	gQualityManager:GMSetQualityDetails("charMeshTex", name, value)
end

function module:GMSetSceneCount(name, value)
	gQualityManager:GMSetQualityDetails("sceneCount", name, value)
end

function module:GMSetSceneMat(name, value)
	gQualityManager:GMSetQualityDetails("sceneMat", name, value)
end

function module:GMSetEffect(name, value)
	gQualityManager:GMSetQualityDetails("effect", name, value)
end

function module:GMSetPostProcess(name, value)
	gQualityManager:GMSetQualityDetails("postProcess", name, value)
end

function module:GMSetVehicleCount(name, value)
	gQualityManager:GMSetQualityDetails("vehicleCount", name, value)
end

function module:GMSetCache(name, value)
	gQualityManager:GMSetCacheDetails(name, value)
end

function module:GMSetGraphics(name, value)
	gQualityManager:GMSetGraphicsDetails(name, value)
end

function module:CheckHurtBoneStartAction(code, pid)
	if code ~= nil and code ~= "" then
		local f = load(code, nil, "t", {
			M = gSkillJumpScriptFunc
		})

		if not f then
			return false
		end

		gSkillJumpScriptFunc.unitPid = pid
		local status, ret = xpcall(f, tolua.traceback)

		if status then
			return ret
		end

		print_error("怪物受击抖动 RunFunc 报错，请检查条件是否正确", "pid", pid, "code", code, "status", status, "ret", ret)
	end

	return true
end

function module:PVHideUid(hide)
	if gLuaUIMgr.uidLayerPanelStore then
		gLuaUIMgr.uidLayerPanelStore:RefreshUIDDisplay(not hide)
	end
end

function module:PVHideHUDBtn(hide)
	gUIFunctionStateManager:PVHideBtn(hide)
end

function module:GMOpenTestMindPowerAndSpecialSkill(enable)
	gBattleMgr:GMOpenTestMindPowerAndSpecialSkill(enable)
end

function module:SyncUnitDataSet(unitId, isRealInvisible)
	local unitDataSet = gDataSetManager:GetUnitData(unitId)

	if unitDataSet then
		unitDataSet.realInVisiable = isRealInvisible
	end
end

function module:OnStartRideQTE(riderPid, beRidenPid)
	gPanelManager:CheckShow(gPanelId.TOILET_OSTRICH_GAME_PANEL, {
		npcPid = beRidenPid
	})
end

function module:OnUnitAttachToUnit(unitId, attachToUnitId)
	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.GoRiding, false)
	gCS.ClimbManager.TryChangeParkourState(0, true)

	local isAttachToUnit = ulong.Greater(attachToUnitId, 0)
	local coreHudPanelStore = gStoreManager:GetStoreGroup("CoreHudPanelStore")

	coreHudPanelStore:SwitchMainPhoneModeCtrlToShoot(isAttachToUnit)
end

function module:OnUnitAttachToVehicleUnit(unitId, vehiclePid, agentConfigID, enable, vehicleStartTime, vehicleDuration)
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattle02Store")

	store:RefreshCountDown(enable, vehicleStartTime, vehicleDuration)
	store:BindAgentConfig(agentConfigID)
end

function module:PlayHudFadeInEffect()
	gStoreManager:GetStoreGroup("CoreHudPanelStore"):PlayHudFadeInEffect()
end

function module:GMUseNewPhotoPanel(enable)
	gTakePhotoUtils.isUsingNewVersion(enable)
end

function module:RegisterHudUIRoot(uniIdentifier, hudTargetType, unit, hudUIRoot)
	gHudMgr:RegisterHudCtrl(uniIdentifier, hudTargetType, unit, hudUIRoot)
end

function module:AddHudTemplate(uniIdentifier, InstanceId, templateType, templateTag)
	gHudMgr:AddHudTemplate(uniIdentifier, InstanceId, templateType, templateTag)
end

function module:DestroyHudUIRoot(uniIdentifier)
	gHudMgr:DestroyHudCtrl(uniIdentifier)
end

function module:AllowForceTakePhoto(force)
	gTakePhotoUtils.isDebugForce = force
end

function module:GetSpiritFavor(pid)
	return gSpiritAcquisitionManager:GetSpiritFavor(pid)
end

function module:GetSpiritFavorAnim(pid)
	if gSpiritAcquisitionManager:CheckIfInteractionTrueSpirit() then
		return gSpiritAcquisitionManager:GetSpiritFavorAnim(pid)
	end

	return 0
end

function module:InjectFixTestAdd(a)
	a = a + 1

	return a
end

function module:SetDestructibleHpProgress(destructId, hpProgress)
	gHudMgr:SetDestructibleHpProgress(destructId, hpProgress)
end

function module:SetDestructibleDebugInfo(destructId, hp, maxHp, damageText)
	gHudMgr:SetDestructibleDebugInfo(destructId, hp, maxHp, damageText)
end

function module:SetDestructibleDebugVisible(destructId, visible)
	gHudMgr:SetDestructibleDebugVisible(destructId, visible)
end

function module:SetDestructibleCommonDebugInfo(destructId, info)
	gHudMgr:SetDestructibleCommonDebugInfo(destructId, info)
end

function module:SetDestructibleCommonDebugInfoVisible(destructId, visible)
	gHudMgr:SetDestructibleCommonDebugInfoVisible(destructId, visible)
end

function module:BartendOut(type, delaytime)
	return
end

function module:MonsterAIActionDebug(pid, msg, fadeOutTime)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit then
		gHudMgr:OnShowMonsterAIActionDebug(pid, msg, fadeOutTime)
	end
end

function module:VehicleInfoDebug(vehicle_uid, msg, show)
	gHudMgr:OnShowVehicleDebugInfo(vehicle_uid, msg, show)
end

function module:UpdateDebugInfoHud(targetType, uid, msg)
	local hudCtrl = gHudMgr:GetHudCtrlNoUnit(targetType, uid)

	if not hudCtrl then
		return
	end

	hudCtrl:OnShowId(true, msg)
end

function module:RemoveDebugInfoHud(targetType, uid)
	local hudCtrl = gHudMgr:GetHudCtrlNoUnit(targetType, uid)

	if not hudCtrl then
		return
	end

	hudCtrl:OnShowId(false, "")
end

function module:GetTerrainKillingGadget(pid, unitPos, toPlayerDisSqr, playerToUnit, playerPos, playerForward, cam, camPos, camForward)
	local unit2KillGadgets = gGadgetManager:GetTerrainKillingList()
	local killGadgets = unit2KillGadgets[pid]

	if not killGadgets or #killGadgets == 0 then
		return nil
	end

	local closestIdx = 0
	local closestDisSqr = 10000000

	for i = 1, #killGadgets do
		local killGadget = killGadgets[i]
		local valid, disSqr = self:CheckTerrainKillingGadgetCondition(killGadget, unitPos, toPlayerDisSqr, playerPos, playerToUnit, playerForward, cam, camPos, camForward)

		if valid and disSqr < closestDisSqr then
			closestIdx = i
			closestDisSqr = disSqr
		end
	end

	return killGadgets[closestIdx]
end

function module:CheckTerrainKillingGadgetCondition(killGadget, unitPos, toPlayerDisSqr, playerPos, playerToUnit, playerForward, cam, camPos, camForward)
	local cfg = BattleGadgetTerrainKillingConfig.GetConfig(killGadget.cfgId)

	if toPlayerDisSqr > cfg.ToPlayerDistance * cfg.ToPlayerDistance then
		return false
	end

	local pointPos = killGadget.targetTrans.position
	local pointDir = killGadget.targetTrans.forward
	local playerToPoint = pointPos - playerPos
	local playerToPointDisSqr = playerToPoint.sqrMagnitude
	local angle = Vector3.Angle(playerToPoint, playerToUnit)
	local rayStart = unitPos
	rayStart.y = 0.4 + rayStart.y
	local rayEnd = pointPos
	rayEnd.y = 0.4 + rayEnd.y
	local heightDelta = pointPos.y - unitPos.y

	if cfg.EnemyPointToPlayerAngle < angle or cfg.HeightDeltaRange.max < heightDelta or heightDelta < cfg.HeightDeltaRange.min or cfg.IsEnemyCloserThanPoint and playerToPointDisSqr < toPlayerDisSqr or cfg.PointDirToPIAngle > 0 and cfg.PointDirToPIAngle < gUtils:GetAngle(pointDir, playerToPoint) or cfg.PointDirToTIAngle > 0 and cfg.PointDirToTIAngle < gUtils:GetAngle(pointDir, pointPos - unitPos) or cfg.EnemyPointInPlayerAngle > 0 and (cfg.EnemyPointInPlayerAngle / 2 < math.abs(gUtils:GetAngle(playerToUnit, playerForward)) or cfg.EnemyPointInPlayerAngle / 2 < math.abs(gUtils:GetAngle(pointPos - playerPos, playerForward))) or not gCS.LuaUtils.IsInCameraView(cam, camPos, camForward, pointPos, cfg.PointViewRange.xMin, cfg.PointViewRange.xMax, cfg.PointViewRange.yMin, cfg.PointViewRange.yMax) or cfg.IsCheckEnemyToPointObstacle and self:CheckObstacle(killGadget.entityId, rayStart, rayEnd - rayStart, Vector3.Distance(rayEnd, rayStart)) then
		return false
	end

	return true, playerToPointDisSqr
end

function module:CheckObstacle(entityId, startPt, dir, dis)
	local tmpVector = gUtils:GetVector(0, 0, 0)
	local hit, _ = gCS.LuaUtils.GetTerrainKillingHitPoint(startPt, dir, 0.1, dis, LayerConstants.colliderMoveLayer, entityId, tmpVector, true)

	gUtils:AddVector(tmpVector)

	return hit
end

function module:PlayEnergyShortageAnim(pid)
	gHudMgr:PlayEnergyShortageAnim(pid)
end

function module:SetForceHideHp(pid, force)
	gHudMgr:SetForceHideHp(pid, force)
end

function module:BasketballSwitchToShootingUI(earlyEndTime, perfectStartTime, perfectEndTime, clipLength, keyDownTime)
	gMessageManager:SendMessage(gEventConstants.SWITCH_BASKETBALL_SHOOTING, {
		earlyEndTime = earlyEndTime,
		perfectStartTime = perfectStartTime,
		perfectEndTime = perfectEndTime,
		clipLength = clipLength,
		keyDownTime = keyDownTime
	})
end

function module:OnBVBEnemyCreate(pid, camp)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local addEffect = false

	if gBattlePetsMgr.bvbOnlineType == gBattlePetsMgr.BVBOnlineType.Single then
		if camp == UX.Game.UnitCamp.BVBEnemy then
			addEffect = true
		end
	else
		addEffect = unit.isMaster
	end

	if addEffect then
		local effectId = LTConfig.ChaosMasterConfig.EnemyPokemoneffect

		gCS.EffectMgr:PlayEffectsForUnit(unit, effectId)
	end
end

function module:BasketballCancelShootingUI()
	gMessageManager:SendMessage(gEventConstants.BASKETBALL_SHOOTING_CANCEL)
end

function module:LuaGC()
	collectgarbage("collect")
end

function module:GetCollectgarbageCount()
	local count = collectgarbage("count")

	return count
end

function module:DumpMemorySnapshot(strSavePath)
	gAnalyzeMemoryMgr:Snapshot(strSavePath)
end

function module:CheckAgentAcquainted(agentId)
	return gAgentTrustManager:GetIfAcquainted(agentId)
end

function module:RemoveLevitationBar()
	local myPlayerUnitId = gCS.MyPlayerManager.PlayerUnitId

	gHudMgr:RemoveLevitationBar(myPlayerUnitId)
end

function module:GetCurOncePhotoTemplate()
	return gTakePhotoUtils.OncePhotoTemplate
end

function module:RefreshHpVisible(pid)
	gHudMgr:RefreshHpVisible(pid)
end

function module:FeiSuoAttackSignal()
	gNewGuideMgr:NotifySignal(EGuideSignal.FeiSuoAttack)
end

function module:OpenTakePhoto(isForce, isBanClose, FovTimes, template)
	gTakePhotoUtils.TryTakePhoto(nil, {
		isForce = isForce,
		isBanClose = isBanClose,
		FovTimes = FovTimes,
		template = template
	})
end

function module:SetOncePhotoType(photoType)
	gTakePhotoUtils.OncePhotoType = photoType
end

function module:SetVideoAllow(allow)
	gTakePhotoUtils.AllowVideoSettle = allow
end

function module:SetVideoFOVCheckAllow(allow, max, min)
	gTakePhotoUtils.AllowVideoFOVCheck = allow
	gTakePhotoUtils.VideoMaxFov = allow and max or 0
	gTakePhotoUtils.VideoMinFov = allow and min or 0
end

function module:SetHudTopText(pid, text)
	gHudMgr:SetTopText(pid, text)
end

function module:RemoveHudTopText(pid)
	gHudMgr:RemoveTopText(pid)
end

function module:SetHpHideByBarrier(pid, enable)
	gHudMgr:SetHpHideByBarrier(pid, enable)
end

function module:SwitchGamePlayHud(isEnter, hudType)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if isEnter then
		gameplayControlStore:StartGameplayByType(hudType)
	else
		gameplayControlStore:StopGameplayByType(hudType)
	end
end

function module:NotifyToughnessUI(pid, value, maxValue)
	if not gCS.ToughnessMgr.IsOn then
		return
	end

	local unitDataSet = gDataSetManager:GetUnitData(pid)

	if unitDataSet then
		unitDataSet.toughnessValue = value
		unitDataSet.toughnessMaxValue = maxValue
	end
end

function module:HotConfigChange(eventId, data)
	if data == nil then
		return
	end

	local list = data:ToTable()

	if array.contains(list, "ParkourStateConfig") then
		gMainMenuMgr:InitClientStateConfig()
	elseif array.contains(list, "ActionGroupBehaviorConfig") then
		ActionDataMgr.ResetActionGroupBehaviorDict()
	else
		for i = 1, #list do
			if string.find(list[i], "ActionTransitionRule") then
				gCS.ClimbManager.InitClimbConfig()

				break
			end

			if string.find(list[i], "GamePlayTransition") then
				gGamePlayTransitionMgr:InitConfig()

				break
			end
		end
	end
end

function module:AddCarRaceGps(localGpsId, checkPoint, gpsIcon)
	gMapSubSystem_CommonGps:AddStaticGps(localGpsId, gRaidDataManager.RaidId, checkPoint, EMapViewMask.MiniMap, {
		name = "",
		sIconId = gpsIcon
	}, true, true, true)
end

function module:GMPassHackerGame()
	gStoreManager:GetStoreGroup("HackerSignalMappingPanelStore"):GMPass()
	gStoreManager:GetStoreGroup("HackerDecodeKeysPanelStore"):GMPass()
	gStoreManager:GetStoreGroup("HackerCodeTracingPanelStore"):GMPass()
end

function module:RemoveHUDDangerIcon(pid)
	gHudMgr:RemoveDangerIcon(pid)
end

gCsToLuaHandler = module
