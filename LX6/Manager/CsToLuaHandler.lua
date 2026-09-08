-- Original chunk: @Lua\LuaFiles\LX6\Manager\CsToLuaHandler.lua
-- Decompiled from: 00676_CsToLuaHandler.lua_3428c293e415.luajit

local LayerConstants = LX6.Constants.LayerConstants
local SkillConfig = LTConfig.SkillConfig
local GameObject = UnityEngine.GameObject
local RaidConfig = LTConfig.RaidConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local GameConfig = LTConfig.GameConfig
local AgentConfig = LTConfig.AgentConfig
local BattleGadgetTerrainKillingConfig = LTConfig.BattleGadgetTerrainKillingConfig
local MessageConfig = LTConfig.MessageConfig
local xpcall = xpcall
local UnitOperateUtils = require("LX6/Utils/UnitOperateUtils")
local module = {
	debugGTK = false,
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
			end, nil, , , false, true)
		end
	end,
	OnUnitUnderAttack = function (self, pid, attackerPid, hpAmount)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if not unit then
			return
		end

		if hpAmount <= 0.5 then
			self.ShowHpUnderControl(self, unit)
		end
	end,
	OnUnitHpMaxChange = function (self, pid, maxhp)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if not unit then
			return
		end

		gHudMgr:HpChanged(pid)

		local dataSet = gDataSetManager:GetUnitData(pid)

		if dataSet == nil then
			dataSet.maxhp = maxhp
		end
	end,
	OnUnitHpChange = function (self, pid, hp, maxhp, shield)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if not unit then
			return
		end

		if unit.ClientData.Hp == hp and unit.ClientData.Hp >= hp and unit.ClientData.Hp <= 1 and unit.ClientData.Hp >= unit.ClientData.MaxHp then
			self.ShowHpUnderControl(self, unit)
		end

		unit.ClientData.Hp = hp
		unit.ClientData.MaxHp = maxhp

		if unit.ClientData.Shield == shield then
			if unit.ClientData.Shield >= shield then
				self.ShowHpUnderControl(self, unit)
			end

			unit.ClientData.Shield = shield
		end

		gHudMgr:HpChanged(pid)
		gBattlePetsMgr:OnPokemonHpChange(pid)
		gBloodBarGameManager:OnHpChanged(pid)

		local data = gDataSetManager:GetUnitData(pid)

		if data == nil then
			data.hp = hp
			data.maxhp = maxhp
			data.shield = shield
		end

		if unit.IsPlayer then
			gMessageManager:SendMessage(gEventConstants.PLAYER_HP_CHANGE, pid)
		end
	end,
	OnUnitShowWeaponBar = function (self, pid, show)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit ~= nil then
			return
		end
	end,
	OnUnitShowPartBar = function (self, pid, index, show)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit ~= nil then
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

		self.OnUnitShowHp(self, pid, showHp)
	end,
	OnUnitShowHp = function (self, pid, show)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit ~= nil then
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

		gDataSetManager:RemoveUnitData(pid)
	end,
	SetUnitIsDead = function (self, unitId, value)
		local unitDataSet = gDataSetManager:GetUnitData(unitId)

		if unitDataSet then
			unitDataSet.isDead = value
		end
	end,
	CloseMainChat = function (self)
	end,
	OnShowId = function (self, pid, visible, value)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit ~= nil then
			return
		end

		gHudMgr:OnShowId(pid, visible, value)
	end,
	OnShowHpNum = function (self, pid, visible)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit ~= nil then
			return
		end

		gHudMgr:OnShowHpNum(pid, visible)
	end,
	OnShowDamAndDefNum = function (self, pid, visible)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit ~= nil then
			return
		end

		gHudMgr:OnShowDamAndDefNum(pid, visible)
	end,
	OnShowLevelNum = function (self, pid, visible)
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if unit ~= nil then
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

local PlayNpcTalks = function(npc, infoList)
	for i = 1, #infoList do
		local value = infoList[i]

		if value == nil and npc == nil then
			local str = value.message
			local time = value.time

			if str == nil and time == nil then
				npc.UnitTalk(npc, str, time, false)

				local soundCfgID = value.action

				if soundCfgID and soundCfgID <= 0 then
					gCS.BaseUnitUtils.PlayUnitSound(npc.Pid, soundCfgID)
				end

				coroutine.wait(time)
			end
		end
	end
end

module.AgentPlotInteraction = function(self, isPlayerNear, unit)
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

	if talks and #talks <= 0 then
		if unit ~= nil then
			return
		end

		coroutine.start(PlayNpcTalks, unit, talks)
	end
end

module.OnUnitVisiableChange = function(self, pid, isInVisiable)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit ~= nil then
		return
	end

	local dataset = gDataSetManager:GetUnitData(pid)

	if dataset then
		dataset.realInVisiable = isInVisiable
	end

	gCS.EffectMgr:ShowOrHideEffectForUnit(pid, isInVisiable)
	gLockTargetMgr:CheckShowLockEffectActiveSgui(unit)
end

module.ShowBattleMsg = function(self, value)
	gBattleMgr.ShowBattleMsg = value
end

module.EnableNewCombo = function(self, value)
	gBattleMgr.IsUseNewCombo = value
end

module.SetMyPid = function(self, value)
	gPlayerManager.infoBase.bindData.Pid = value
end

module.OnSurveyDoneFinishAsk = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskFinishQuestionnaire().Callback = function (err)
		gPlayerManager.infoMinor.bindData.Questionnaire = GameConfig.SurveyVersion

		gMessageManager:SendMessage(gEventConstants.WELFARE_QUESTION_DONE)
	end
end

module.AskClientAction = function(self, type, args1, args2, args3)
end

module.GetCustomRaidName = function(self, raidId)
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

module.InitMyUnitState = function(self)
	local myPlayerUnitId = gCS.MyPlayerManager.PlayerUnitId

	if not ulong.equals(myPlayerUnitId, ulong.zero) then
		local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

		if not gDriveVehiclesManager.isDriveMode then
			myPlayerCSUnit:SetCCMoveEnable(true)

			if not gCS.UnitStateMgr:HasState(myPlayerUnitId, UnitStateConfig.Sitting) then
				myPlayerCSUnit.SetGroundSolvingActivation(myPlayerCSUnit, true)
			else
				myPlayerCSUnit.SetGroundSolvingActivation(myPlayerCSUnit, false)
			end
		end
	end
end

module.SetIsOnJoystickMove = function(self, value)
	gUnitOperateManager.isOnJoystickMove = value

	if value ~= false then
		self.JoyStickMove.x = 0
		self.JoyStickMove.y = 0
		gUnitOperateManager.joyStickPercent = 0
		gCS.TransitionMgr.joyStickPercent = 0
	end
end

module.ReloadLuaFile = function(self, fileName)
	local fullPath = ""
	local tab1 = nil
	local cur = ""
	local len = string.len(fileName)

	for key, _ in pairs(package.preload) do
		cur = tostring(key)

		if string.find(cur, fileName) then
			local len1 = string.len(cur)
			local s = string.sub(cur, len1 - len, len1 - len)

			if s ~= "." and string.sub(cur, len1 - len + 1, len1) ~= fileName then
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

			if s ~= "." and string.sub(cur, len1 - len + 1, len1) ~= fileName then
				tab1 = package.loaded[key]
				fullPath = cur

				break
			end
		end
	end

	if fullPath == "" and tab1 then
		local tab2 = dofile(fullPath)

		if tab2 then
			for k, v in pairs(tab2) do
				tab1[k] = v
			end
		end
	end

	print_warn("[ReloadLuaFile]", fileName, fullPath, fullPath == "" and "success" or "failed")
end

module.CancelAllAction = function(self, pid)
	gLuaTimeMgrUtils.CancelAllUnitDelay(pid)
end

module.ApplyProfileToLua = function(self)
	gUtils:InitLanguage()
end

module.isShowFullScreenChange = function(self, value)
	gGameManager.Cache.isShowFullScreen = value
end

module.RefreshServerTime = function(self, serverTime, serverUnixTime)
	gLuaDataManager.serverTime = serverTime
	gLuaDataManager.serverUnixTime = serverUnixTime
end

module.LoadQualityData = function(self, deviceLevel, qualityLevel)
	gQualityManager:LoadQualityData(deviceLevel, qualityLevel)
end

module.LoadDetailQualityDataFromGameProfile = function(self)
	gQualityManager:LoadDetailQualityDataFromGameProfile()
end

module.GenSpawnInfoSimple = function(self, npcInfo, show)
	return {
		["*9\\xf6v\\x99\\xe31\\x8e \\xf4\\xc6\\xe7g\\xf0"] = false,
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
		platformPartId = npcInfo.platformPartId or 0,
		platformId = npcInfo.platformId or 0,
		platformType = npcInfo.platformType or 0,
		needFTF180DegreeInteract = npcInfo.NeedFTF180DegreeInteract,
		playerFTF180DegreeInteract = npcInfo.PlayerFTF180DegreeInteract
	}
end

module.SyncGameSwitchToClient = function(self, keys, values)
	keys = keys.ToTable(keys)
	values = values.ToTable(values)

	for i, key in ipairs(keys) do
		local value = values[i]

		gGameSwitch.Sync(key, value)
	end

	gMessageManager:SendMessage(gEventConstants.ON_GAMESWITCH_CHANGED)
end

module.GmRunLua = function(self, content)
	local f = load(content, nil, "t")

	if f then
		local status, err = xpcall(f, tolua.traceback)

		if not status then
			print_error("#NoCreateIssue" .. err)
		end
	else
		print_error("#NoCreateIssue GmRunLua Compile Error")
	end
end

module.RunRaidRoomAction = function(self, roomId, taskId, codeStr)
	if codeStr and codeStr == "" then
		gTaskNodeManager.RunScriptRoomId = roomId

		gDialogAction:RunCodeByTask(codeStr, taskId)
	end
end

module.ClearMyUnitState = function(self, pid)
	local unit = gDataSetManager:GetUnitData(pid)

	if unit and unit.isMe then
		gClientUtils:ClearPaoKuState()
		gUnitStateMgr:ResetMyStateAndClearMove(true)
	end
end

module.UnitBodyRadiusChange = function(self, pid, value)
end

module.BackToLogin = function(self)
	gLoginManager:BackToLogin()
end

module.KickToLogin = function(self)
	gLoginManager:KickToLogin()
end

module.SetRootMotionAllTime = function(self, time)
end

module.ClearSpoon = function(self)
	gSpoonMgr:ClearSpoon()
end

module.OnJoyStickMove = function(self, x, y, joyStickPercent)
	gCS.SkillJumpManager.Instance:CheckPressJoyStickTime(x, y)

	self.JoyStickMove.x = x
	self.JoyStickMove.y = y
	gUnitOperateManager.joyStickPercent = joyStickPercent
	gCS.TransitionMgr.joyStickPercent = joyStickPercent

	if self.LastJoyStickMove.x == x or self.LastJoyStickMove.y == y then
		local old = gUtils:GetAngleYByDirectionV2(self.LastJoyStickMove)
		local new = gUtils:GetAngleYByDirectionV2(self.JoyStickMove)

		if GameConfig.CanSwitchUnitJoyAngle >= Mathf.Abs(new - old) then
			self.LastJoyStickMove.x = x
			self.LastJoyStickMove.y = y
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_JOYSTICK_MOVE)
end

module.TrampolineTrigger = function(self, x, z, index)
	gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
end

module.MyEnterWASDMove = function(self, x, y, z)
	if self.GetSkillData(self, gCS.MyPlayerManager.PlayerUnit) and self.GetSkillData(self, gCS.MyPlayerManager.PlayerUnit).skillId then
		local skillconfig = SkillConfig.GetConfig(self.GetSkillData(self, gCS.MyPlayerManager.PlayerUnit).skillId)

		if skillconfig and skillconfig.RotateSpeed.stoptime <= 0 then
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

module.GetSkillData = function(self, cs_unit)
	if cs_unit then
		return gCS.BattleManager.GetSkillData(cs_unit)
	end

	return nil
end

module.OnChairTriggerChange = function(self, instanceId, chairType, eventId, index, forwardTriggerId, leftTriggerId, rightTriggerId, backTriggerId, spotPos, spotDir, finalPos, finalDir, ...)
end

module.GmResetAllTaskNpc = function(self)
end

module.KeyUpNotCheck = function(self, enable)
	gLuaDataManager.keyUpNotCheck = enable
end

module.UpdateJobSex = function(self, pid, sexType)
end

module.ClearFreePaokuActiVeArea = function(self)
end

module.ClearPaoku = function(self, noCheckAction)
	local myPlayerUnitId = gCS.MyPlayerManager.PlayerUnitId

	if not ulong.equals(myPlayerUnitId, ulong.zero) then
		local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

		gClientUtils:ClearPaoKuState(false, false)

		if not myPlayerCSUnit.State.IsInMotoRide then
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

module.AskEnemyItemPickUp = function(self, pid, bindItemIndex)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit and unit.isMaster then
		gClientToGameSceneDelegate:AskEnemyItemPickUp(pid, bindItemIndex)
	end
end

module.BeginBeeGame = function(self)
	gSceneGameRuleManager:CreateProcedureGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)
end

module.KillBeeGameAllEnemy = function(self)
	local gameRule = gSceneGameRuleManager:GetGameRule(gSceneGameRuleManager.GameRuleType.Galaxian)

	if gameRule then
		gameRule.KillAll(gameRule)
	end
end

module.LostFocusJumpKeyUpFunc = function(self)
	if not gLuaDataManager.keyUpNotCheck then
		UnitOperateUtils.LostFocusJumpKeyUpFunc(gCS.MyPlayerManager.PlayerUnit)
	end
end

module.OnHitNpc = function(self, unitId, hitUnitId, skillId, hitPoint)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.NonMindSkillTrigger, {
		skillId = skillId,
		hitId = hitUnitId
	})
end

module.GMUnlockMiniChat = function(self, enable)
end

module.OnSyncRemoveSpoonDestructible = function(self, spoonId)
	gMessageManager:SendMessage(gEventConstants.ON_SPOON_DESTRUCTIBLE_REMOVE, spoonId)
end

module.OnSyncRemoveSpoonDestructibleGps = function(self, gpsGroupIdIndex)
	if string.contains(gpsGroupIdIndex, "@") then
		-- Nothing
	end
end

module.OnRefreshSpoonDestructibleGps = function(self, gpsGroupIdIndex, position)
	if string.contains(gpsGroupIdIndex, "@") then
		-- Nothing
	end
end

module.AddCSGps = function(self, gpsId, posiiton, iconId)
	if iconId ~= nil or iconId ~= 0 then
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

module.RemoveCSGps = function(self, gpsId)
	gGpsManager:RemoveGPSById("csGps" .. gpsId, gTaskGpsType.Follow)
end

module.TestTypeOf = function(self)
	print_error("TestTypeOf", typeof(UnityEngine.GameObject))
end

module.crash = function(self)
	ulong.crash(1, 0)
end

module.AskSwitchPlayerSpirit = function(self, templateId)
	gClientToGameSceneDelegate:AskSwitchPlayerSpirit(templateId)
end

module.GetCurrentTask = function(self)
	local id = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]
	local curTaskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(id)

	if curTaskInfo then
		local nane = curTaskInfo.ConfigData.Name

		return id .. " " .. nane
	end

	return "no task"
end

module.GMSetFpsUnlimit = function(self)
	gQualityManager:ChangeFPS(300)
end

module.OpenBanDeviceCheck = function(self)
	gQualityManager.CanEnterGame = true
end

module.OnAskFlagChange = function(self, value)
	gLuaDataManager.AskFlag = value
end

module.GMResetOperationModeKey = function(self)
	local keyName = "PLAYER_SELECTED_OPERATION_MODE" .. ulong.tostring(gPlayerManager.infoBase.bindData.Pid)

	UnityEngine.PlayerPrefs.SetInt(keyName, 0)
end

module.OnRemoveDestructibleGUI = function(self, id)
	gHudMgr:DestroyDestructTarget(id)
end

module.AutoCloseDeadPanelAndRevive = function(self, enable)
	gDeadManager.autoCloseDeadPanelAndRevive = enable
end

module.StartRest = function(self, args)
	args.ignoreAskPassingTimeRpc = true

	gTimeAppUtils.StartRestTime(args)
end

module.CkeckIsOpenPhone = function(self)
	return gCS.PaoKuManager.ParkourStateLua ~= LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.OpenPhone
end

module.GetHudTargetPostion = function(self, pid)
	if gLuaUIMgr.hudPanel then
		return gLuaUIMgr.hudPanel.GetHudTargetPostion(pid)
	end

	return nil
end

module.ClickSpoonGadgetTest = function(self, graphName, nodeId, entityId, eventName, exBool)
	for _, contextData in pairs(gSpoonClientMgr.contexts) do
		if entityId ~= contextData.instanceId then
			local data = {
				["\\xd0\\xc801\\xf6"] = true,
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

module.TelePortCurrentTaskPos = function(self)
	if gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] <= 0 then
		local taskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])
		local pos = taskInfo.UseTansGuide and not gCS.LuaUtils.IsNull(taskInfo.TargetTrans) and taskInfo.TargetTrans.position or taskInfo.TargetPos

		if pos then
			L50.Gm.AutoQaFunctions.TeleportXYZ(pos.x, pos.y, pos.z)
		else
			gDisplayMessageMgr:ShowMessageContentDebug("无法传送到此")
		end
	end
end

module.ModifyAssassinationDirection = function(self, enable)
	gFeiSuoCrouchManager.modifyAssassinationDirection = enable
end

module.SetSpoonClientGraphReuse = function(self, enable)
	gSpoonClientMgr:SetSpoonClientGraphReuse(enable)
end

module.GMSetQualityDetailLevel = function(self, detailName, level)
	gQualityManager:GMSetQualityDetailLevel(detailName, level)
end

module.GMSetResolutionScreen = function(self, name, value)
	gQualityManager:GMSetQualityDetails("resolutionScreen", name, value)
end

module.GMSetResolutionShadow = function(self, name, value)
	gQualityManager:GMSetQualityDetails("resolutionShadow", name, value)
end

module.GMSetMatLevel = function(self, name, value)
	gQualityManager:GMSetQualityDetails("matLevel", name, value)
end

module.GMSetCharCount = function(self, name, value)
	gQualityManager:GMSetQualityDetails("charCount", name, value)
end

module.GMSetCharMeshTex = function(self, name, value)
	gQualityManager:GMSetQualityDetails("charMeshTex", name, value)
end

module.GMSetSceneCount = function(self, name, value)
	gQualityManager:GMSetQualityDetails("sceneCount", name, value)
end

module.GMSetSceneMat = function(self, name, value)
	gQualityManager:GMSetQualityDetails("sceneMat", name, value)
end

module.GMSetEffect = function(self, name, value)
	gQualityManager:GMSetQualityDetails("effect", name, value)
end

module.GMSetPostProcess = function(self, name, value)
	gQualityManager:GMSetQualityDetails("postProcess", name, value)
end

module.GMSetVehicleCount = function(self, name, value)
	gQualityManager:GMSetQualityDetails("vehicleCount", name, value)
end

module.GMSetCache = function(self, name, value)
	gQualityManager:GMSetCacheDetails(name, value)
end

module.GMSetGraphics = function(self, name, value)
	gQualityManager:GMSetGraphicsDetails(name, value)
end

module.CheckHurtBoneStartAction = function(self, code, pid)
	if code == nil and code == "" then
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

module.PVHideUid = function(self, hide)
	if gLuaUIMgr.uidLayerPanelStore then
		gLuaUIMgr.uidLayerPanelStore:RefreshUIDDisplay(not hide)
	end
end

module.PVHideHUDBtn = function(self, hide)
	gUIFunctionStateManager:PVHideBtn(hide)
end

module.GMOpenTestMindPowerAndSpecialSkill = function(self, enable)
	gBattleMgr:GMOpenTestMindPowerAndSpecialSkill(enable)
end

module.SyncUnitDataSet = function(self, unitId, isRealInvisible)
	local unitDataSet = gDataSetManager:GetUnitData(unitId)

	if unitDataSet then
		unitDataSet.realInVisiable = isRealInvisible
	end
end

module.OnStartRideQTE = function(self, riderPid, beRidenPid)
	gPanelManager:CheckShow(gPanelId.TOILET_OSTRICH_GAME_PANEL, {
		npcPid = beRidenPid
	})
end

module.OnUnitAttachToUnit = function(self, unitId, attachToUnitId)
	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.GoRiding, false)
	gCS.ClimbManager.TryChangeParkourState(0, true)

	local isAttachToUnit = ulong.Greater(attachToUnitId, 0)

	if isAttachToUnit then
		gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StartGameplayByType(gHUDGameplayType.MOUNT)
	else
		gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StopGameplayByType(gHUDGameplayType.MOUNT)
	end
end

module.OnUnitAttachToVehicleUnit = function(self, unitId, vehiclePid, agentConfigID, enable, vehicleStartTime, vehicleDuration)
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattle02Store")

	store:RefreshCountDown(enable, vehicleStartTime, vehicleDuration)
	store:BindAgentConfig(agentConfigID)
end

module.PlayHudFadeInEffect = function(self)
	gStoreManager:GetStoreGroup("CoreHudCharacterControlStore"):PlayHudFadeInEffect()
end

module.GMUseNewPhotoPanel = function(self, enable)
	gTakePhotoUtils.isUsingNewVersion(enable)
end

module.RegisterHudUIRoot = function(self, uniIdentifier, hudTargetType, unit, hudUIRoot)
	gHudMgr:RegisterHudCtrl(uniIdentifier, hudTargetType, unit, hudUIRoot)
end

module.AddHudTemplate = function(self, uniIdentifier, InstanceId, templateType, templateTag)
	gHudMgr:AddHudTemplate(uniIdentifier, InstanceId, templateType, templateTag)
end

module.DestroyHudUIRoot = function(self, uniIdentifier)
	gHudMgr:DestroyHudCtrl(uniIdentifier)
end

module.AllowForceTakePhoto = function(self, force)
	gTakePhotoUtils.isDebugForce = force
end

module.GetSpiritFavor = function(self, pid)
	return gSpiritAcquisitionManager:GetSpiritFavor(pid)
end

module.GetSpiritFavorAnim = function(self, pid)
	if gSpiritAcquisitionManager:CheckIfInteractionTrueSpirit() then
		return gSpiritAcquisitionManager:GetSpiritFavorAnim(pid)
	end

	return 0
end

module.InjectFixTestAdd = function(self, a)
	a = a + 1

	return a
end

module.SetDestructibleHpProgress = function(self, destructId, hpProgress)
	gHudMgr:SetDestructibleHpProgress(destructId, hpProgress)
end

module.SetDestructibleDebugInfo = function(self, destructId, hp, maxHp, damageText)
	gHudMgr:SetDestructibleDebugInfo(destructId, hp, maxHp, damageText)
end

module.SetDestructibleDebugVisible = function(self, destructId, visible)
	gHudMgr:SetDestructibleDebugVisible(destructId, visible)
end

module.SetDestructibleCommonDebugInfo = function(self, destructId, info)
	gHudMgr:SetDestructibleCommonDebugInfo(destructId, info)
end

module.SetDestructibleCommonDebugInfoVisible = function(self, destructId, visible)
	gHudMgr:SetDestructibleCommonDebugInfoVisible(destructId, visible)
end

module.BartendOut = function(self, type, delaytime)
end

module.MonsterAIActionDebug = function(self, pid, msg, fadeOutTime)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit then
		gHudMgr:OnShowMonsterAIActionDebug(pid, msg, fadeOutTime)
	end
end

module.VehicleInfoDebug = function(self, vehicle_uid, msg, show)
	gHudMgr:OnShowVehicleDebugInfo(vehicle_uid, msg, show)
end

module.UpdateDebugInfoHud = function(self, targetType, uid, msg)
	local hudCtrl = gHudMgr:GetHudCtrlNoUnit(targetType, uid)

	if not hudCtrl then
		return
	end

	hudCtrl.OnShowId(hudCtrl, true, msg)
end

module.RemoveDebugInfoHud = function(self, targetType, uid)
	local hudCtrl = gHudMgr:GetHudCtrlNoUnit(targetType, uid)

	if not hudCtrl then
		return
	end

	hudCtrl.OnShowId(hudCtrl, false, "")
end

module.GetTerrainKillingGadget = function(self, pid, unitPos, toPlayerDisSqr, playerToUnit, playerPos, playerForward, cam, camPos, camForward)
	local enableDebugLog = self.debugGTK

	if enableDebugLog then
		print_error("-------------------------GetTerrainKillingGadget 开始", string.format("pid=%s", ulong.tostring(pid)))
	end

	local unit2KillGadgets = gGadgetManager:GetTerrainKillingList()

	if not unit2KillGadgets then
		if enableDebugLog then
			print_error("❌ GetTerrainKillingGadget 失败-地形击杀列表为空")
		end

		return nil
	end

	local killGadgets = unit2KillGadgets[pid]

	if not killGadgets or #killGadgets ~= 0 then
		if enableDebugLog then
			print_error("❌  失败-该单位未进地形击杀机关", string.format("pid=%s", ulong.tostring(pid)))
		end

		return nil
	end

	if enableDebugLog then
		print_error("GetTerrainKillingGadget 检查机关", string.format("pid=%s 机关数量=%d", ulong.tostring(pid), #killGadgets))
	end

	local closestIdx = 0
	local closestDisSqr = 10000000
	local validCount = 0

	for i = 1, #killGadgets do
		local killGadget = killGadgets[i]
		local valid, disSqr = self.CheckTerrainKillingGadgetCondition(self, killGadget, unitPos, toPlayerDisSqr, playerPos, playerToUnit, playerForward, cam, camPos, camForward, pid)

		if valid then
			validCount = validCount + 1

			if disSqr >= closestDisSqr then
				closestIdx = i
				closestDisSqr = disSqr
			end
		end
	end

	if closestIdx <= 0 then
		if enableDebugLog then
			print_error("🎯 GetTerrainKillingGadget 成功", string.format("pid=%s 最终选择index=%d entityId=%s 距离^2=%.2f 总有效=%d/%d", ulong.tostring(pid), closestIdx, ulong.tostring(killGadgets[closestIdx].entityId), closestDisSqr, validCount, #killGadgets))
		end

		return killGadgets[closestIdx]
	else
		if enableDebugLog then
			print_error("❌ GetTerrainKillingGadget 失败-无有效机关", string.format("pid=%s 检查了%d个机关", ulong.tostring(pid), #killGadgets))
		end

		return nil
	end
end

module.CheckTerrainKillingGadgetCondition = function(self, killGadget, unitPos, toPlayerDisSqr, playerPos, playerToUnit, playerForward, cam, camPos, camForward, pid)
	local cfg = BattleGadgetTerrainKillingConfig.GetConfig(killGadget.cfgId)
	local enableDebugLog = self.debugGTK

	if enableDebugLog then
		print_error("================ 地形击杀条件检查开始", string.format("pid=%s entityId=%s", ulong.tostring(pid), ulong.tostring(killGadget.entityId)), killGadget.targetTrans)
	end

	local maxDistanceSqr = cfg.ToPlayerDistance * cfg.ToPlayerDistance

	if toPlayerDisSqr <= maxDistanceSqr then
		if enableDebugLog then
			print_error("❌ 地形击杀失败-距离过远", string.format("距离^2=%.2f(限制:%.2f)", toPlayerDisSqr, maxDistanceSqr))
		end

		return false
	end

	local pointPos = killGadget.targetTrans.position
	local pointDir = killGadget.targetTrans.forward
	local playerToPoint = pointPos - playerPos
	local playerToPointDisSqr = playerToPoint.sqrMagnitude
	local angle = Vector3.Angle(playerToPoint, playerToUnit)
	local heightDelta = pointPos.y - unitPos.y

	if cfg.EnemyPointToPlayerAngle >= angle then
		if enableDebugLog then
			print_error("❌ 地形击杀失败-角度过大", string.format("角度=%.1f°(限制:%.1f°)", angle, cfg.EnemyPointToPlayerAngle))
		end

		return false
	end

	if cfg.HeightDeltaRange.max <= heightDelta or heightDelta >= cfg.HeightDeltaRange.min then
		if enableDebugLog then
			print_error("❌ 地形击杀失败-高度差超限", string.format("高度差=%.2f(范围:[%.2f,%.2f])", heightDelta, cfg.HeightDeltaRange.min, cfg.HeightDeltaRange.max))
		end

		return false
	end

	if cfg.IsEnemyCloserThanPoint and playerToPointDisSqr >= toPlayerDisSqr then
		if enableDebugLog then
			print_error("❌ 地形击杀失败-交互点更近", string.format("敌人距离^2=%.2f 交互点距离^2=%.2f", toPlayerDisSqr, playerToPointDisSqr))
		end

		return false
	end

	local pointDirToPlayerAngle = gUtils:GetAngle(pointDir, playerToPoint)

	if cfg.PointDirToPIAngle <= 0 and cfg.PointDirToPIAngle >= pointDirToPlayerAngle then
		if enableDebugLog then
			print_error("❌ 地形击杀失败-交互点朝向角度", string.format("与玩家角度=%.1f°(限制:%.1f°)", pointDirToPlayerAngle, cfg.PointDirToPIAngle))
		end

		return false
	end

	local pointDirToEnemyAngle = gUtils:GetAngle(pointDir, pointPos - unitPos)

	if cfg.PointDirToTIAngle <= 0 and cfg.PointDirToTIAngle >= pointDirToEnemyAngle then
		if enableDebugLog then
			print_error("❌ 地形击杀失败-交互点朝向角度", string.format("与敌人角度=%.1f°(限制:%.1f°)", pointDirToEnemyAngle, cfg.PointDirToTIAngle))
		end

		return false
	end

	if cfg.EnemyPointInPlayerAngle <= 0 then
		local enemyInPlayerAngle = math.abs(gUtils:GetAngle(playerToUnit, playerForward))
		local pointInPlayerAngle = math.abs(gUtils:GetAngle(pointPos - playerPos, playerForward))
		local halfAngle = cfg.EnemyPointInPlayerAngle / 2

		if enemyInPlayerAngle >= halfAngle or halfAngle >= pointInPlayerAngle then
			if enableDebugLog then
				print_error("❌ 地形击杀失败-玩家视野范围", string.format("敌人角度=%.1f° 交互点角度=%.1f°(限制:±%.1f°)", enemyInPlayerAngle, pointInPlayerAngle, halfAngle))
			end

			return false
		end
	end

	local inCameraView = gCS.LuaUtils.IsInCameraView(cam, camPos, camForward, pointPos, cfg.PointViewRange.xMin, cfg.PointViewRange.xMax, cfg.PointViewRange.yMin, cfg.PointViewRange.yMax)

	if not inCameraView then
		if enableDebugLog then
			print_error("❌ 地形击杀失败-相机视野外", string.format("视野范围:[%.1f,%.1f,%.1f,%.1f]", cfg.PointViewRange.xMin, cfg.PointViewRange.xMax, cfg.PointViewRange.yMin, cfg.PointViewRange.yMax))
		end

		return false
	end

	if cfg.IsCheckEnemyToPointObstacle then
		local rayStart = Vector3(unitPos.x, unitPos.y + 0.4, unitPos.z)
		local rayEnd = Vector3(pointPos.x, pointPos.y + 0.4, pointPos.z)
		local hasObstacle = self.CheckObstacle(self, killGadget.entityId, rayStart, rayEnd - rayStart, Vector3.Distance(rayEnd, rayStart))

		if hasObstacle then
			if enableDebugLog then
				print_error("❌ 地形击杀失败-障碍物遮挡")
			end

			return false
		end
	end

	return true, playerToPointDisSqr
end

module.CheckObstacle = function(self, entityId, startPt, dir, dis)
	local tmpVector = gUtils:GetVector(0, 0, 0)
	local hit, _ = gCS.LuaUtils.GetTerrainKillingHitPoint(startPt, dir, 0.1, dis, LayerConstants.colliderMoveLayer, entityId, tmpVector, true)

	gUtils:AddVector(tmpVector)

	return hit
end

module.PlayEnergyShortageAnim = function(self, pid)
	gHudMgr:PlayEnergyShortageAnim(pid)
end

module.SetForceHideHp = function(self, pid, force)
	gHudMgr:SetForceHideHp(pid, force)
end

module.BasketballSwitchToShootingUI = function(self, earlyEndTime, perfectStartTime, perfectEndTime, shootStartTime, shootEndTime, keyDownTime)
	gMessageManager:SendMessage(gEventConstants.SWITCH_BASKETBALL_SHOOTING, {
		earlyEndTime = earlyEndTime,
		perfectStartTime = perfectStartTime,
		perfectEndTime = perfectEndTime,
		shootStartTime = shootStartTime,
		shootEndTime = shootEndTime,
		keyDownTime = keyDownTime
	})
end

module.OnBVBEnemyCreate = function(self, pid, camp)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local addEffect = false

	if gBattlePetsMgr.bvbOnlineType ~= gBattlePetsMgr.BVBOnlineType.Single then
		if camp ~= UX.Game.UnitCamp.BVBEnemy then
			addEffect = true
		end
	else
		addEffect = unit.isMaster
	end

	if addEffect then
		local effectId = LTConfig.ChaosMasterConfig.EnemyPokemoneffect

		gCS.EffectMgr:PlayEffectsForUnit(unit, effectId, LX6.Effect.EffectPlayTag.Battle)
	end
end

module.BasketballCancelShootingUI = function(self)
	gMessageManager:SendMessage(gEventConstants.BASKETBALL_SHOOTING_OVER)
end

module.LuaGC = function(self)
	collectgarbage("collect")
end

module.GetCollectgarbageCount = function(self)
	local count = collectgarbage("count")

	return count
end

module.DumpMemorySnapshot = function(self, strSavePath)
	gAnalyzeMemoryMgr:Snapshot(strSavePath)
end

module.CheckAgentAcquainted = function(self, agentId)
	return gAgentTrustManager:GetIfAcquainted(agentId)
end

module.RemoveLevitationBar = function(self)
	local myPlayerUnitId = gCS.MyPlayerManager.PlayerUnitId

	gHudMgr:RemoveLevitationBar(myPlayerUnitId)
end

module.GetCurOncePhotoTemplate = function(self)
	return gTakePhotoUtils.OncePhotoTemplate
end

module.RefreshHpVisible = function(self, pid)
	gHudMgr:RefreshHpVisible(pid)
end

module.FeiSuoAttackSignal = function(self)
	gNewGuideMgr:NotifySignal(EGuideSignal.FeiSuoAttack)
end

module.OpenTakePhoto = function(self, isForce, isBanClose, FovTimes, template, isSelfIeMode, initialFilter, isMinimalUI, isPostProcessPanelBanned, needFocusTarget, notForceSetSetippleAlpha)
	gTakePhotoUtils.TryTakePhoto(nil, {
		isForce = isForce,
		isBanClose = isBanClose,
		FovTimes = FovTimes,
		template = template,
		isSelfIeMode = isSelfIeMode,
		initialFilter = initialFilter,
		isMinimalUI = isMinimalUI,
		isPostProcessPanelBanned = isPostProcessPanelBanned,
		needFocusTarget = needFocusTarget,
		notForceSetSetippleAlpha = notForceSetSetippleAlpha
	})
end

module.SetOncePhotoType = function(self, photoType)
	gTakePhotoUtils.OncePhotoType = photoType
	gCS.PhotoManager.Instance.oncePhotoType = photoType
end

module.SetVideoAllow = function(self, allow)
	if not gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		gTakePhotoUtils.AllowVideoSettle = allow
	end

	if allow then
		gPanelManager:CheckShow(gPanelId.S_PHOTOGRAPH_COUNT_DOWN_PANEL)
	elseif gPanelManager:IsPanelShowing(gPanelId.S_PHOTOGRAPH_COUNT_DOWN_PANEL) then
		gPanelManager:Close(gPanelId.S_PHOTOGRAPH_COUNT_DOWN_PANEL)
	end
end

module.SetVideoFOVCheckAllow = function(self, allow, max, min)
	gTakePhotoUtils.AllowVideoFOVCheck = allow
	gTakePhotoUtils.VideoMaxFov = allow and max or 0
	gTakePhotoUtils.VideoMinFov = allow and min or 0
end

module.SetPasswordLockInputEnabled = function(self, isEnabled)
	gMessageManager:SendMessage(gEventConstants.PASSWORD_INTERACTION_CHANGE, isEnabled)
end

module.SetHudTopText = function(self, pid, text)
	gHudMgr:SetTopText(pid, text)
end

module.RemoveHudTopText = function(self, pid)
	gHudMgr:RemoveTopText(pid)
end

module.SetHpHideByBarrier = function(self, pid, enable)
	gHudMgr:SetHpHideByBarrier(pid, enable)
end

module.SwitchGamePlayHud = function(self, isEnter, hudType)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if isEnter then
		gameplayControlStore.StartGameplayByType(gameplayControlStore, hudType)
	else
		gameplayControlStore.StopGameplayByType(gameplayControlStore, hudType)
	end
end

module.NotifyToughnessUI = function(self, pid, value, maxValue)
	if not gCS.ToughnessMgr.IsOn then
		return
	end

	local unitDataSet = gDataSetManager:GetUnitData(pid)

	if unitDataSet then
		unitDataSet.toughnessValue = value
		unitDataSet.toughnessMaxValue = maxValue
	end
end

module.HotConfigChange = function(self, eventId, data)
	if data ~= nil then
		return
	end

	local list = data.ToTable(data)

	if array.contains(list, "ParkourStateConfig") then
		gMainMenuMgr:InitClientStateConfig()
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

module.AddMiniMapGps = function(self, localGpsId, checkPoint, gpsIcon)
	gMapSubSystem_CommonGps:AddStaticGps(localGpsId, gRaidDataManager.RaidId, checkPoint, EMapViewMask.MiniMap, {
		["t#p^"] = "",
		sIconId = gpsIcon
	}, true, true, true)
end

module.GetNextTwoMiniMapGpsPos = function(self, taskId)
	local cfg = gTaskManager:GetTaskConfigInfo(taskId)
	local taskInfo = gTaskManager:GetTaskInfo(taskId)
	local workActionList = gTaskNodeManager:GetTaskWorkAction(taskId)
	local gpsIndexInfo = {
		["USܮ\\x90!\\xb6 \\xcc\\xf0"] = 0,
		["\\x8c1#0v\\x99h\\xd73\\xaf\\xa1"] = 0,
		firstPos = Vector3.zero,
		secondPos = Vector3.zero
	}

	if taskInfo then
		if #cfg.Counter ~= 0 then
			if self.CheckWorkActionIsPoint(self, workActionList, 1) then
				gpsIndexInfo.firstIndex = 1
				gpsIndexInfo.firstPos = workActionList[1].targetPos
			end

			return gpsIndexInfo
		else
			for i, v in ipairs(taskInfo.Counters) do
				if v and v.Value >= v.ConfigValue and self.CheckWorkActionIsPoint(self, workActionList, v.Index + 1) then
					if gpsIndexInfo.firstIndex ~= 0 then
						gpsIndexInfo.firstIndex = v.Index + 1
						gpsIndexInfo.firstPos = workActionList[v.Index + 1].targetPos
					else
						gpsIndexInfo.secondIndex = v.Index + 1
						gpsIndexInfo.secondPos = workActionList[v.Index + 1].targetPos

						return gpsIndexInfo
					end
				end
			end
		end
	end

	return gpsIndexInfo
end

module.CheckWorkActionIsPoint = function(self, workActionList, index)
	if workActionList[index] and workActionList[index].actionType ~= gTaskManager.ACTION_TYPE.WAYPOINT then
		return true
	end

	return false
end

module.SetCarRaceCheckPoints = function(self, checkPoints)
	gMapSystem.navigation:SetRaceNavLineInfo(checkPoints)
end

module.SetOtherPlayerHudVisible = function(self, visible)
	local members = gLinkManager.LinkMemberInfo

	for uid, _ in pairs(members) do
		if uid == gPlayerManager.infoBase.bindData.Pid then
			local data = gDataSetManager:GetOrCreateUserData(uid)

			if data then
				data.AllowHeadInfo = visible
			end
		end
	end
end

module.GMPassHackerGame = function(self)
	gStoreManager:GetStoreGroup("HackerSignalMappingPanelStore"):GMPass()
	gStoreManager:GetStoreGroup("HackerDecodeKeysPanelStore"):GMPass()
	gStoreManager:GetStoreGroup("HackerCodeTracingPanelStore"):GMPass()
	gStoreManager:GetStoreGroup("HackerFingerprintPanelStore"):GMPass()
end

module.OpenChangeDressWithSpecified = function(self, list, suitList)
	local specified = {}

	if list then
		for i = 0, list.Length - 1 do
			table.insert(specified, list[i])
		end
	end

	local specifiedSuit = {}

	if suitList then
		for i = 0, suitList.Length - 1 do
			table.insert(specifiedSuit, suitList[i])
		end
	end

	gPanelManager:CheckShow(gPanelId.S_CHANGE_DRESS, {
		specified = specified,
		specifiedSuit = specifiedSuit
	})
end

module.GMBanFashionAction = function(self, isBan)
	gDressManager.gmBanAction = isBan
end

module.GMRemoveFashions = function(self, fashionIdList)
	local fashionsInfo = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

	if fashionsInfo ~= nil then
		return
	end

	local fashionIdSet = {}

	for i = 0, fashionIdList.Count - 1 do
		fashionIdSet[fashionIdList[i]] = true
	end

	for _, spiritFashionsInfo in pairs(fashionsInfo.SpiritFashionsInfoDict) do
		local wearInfo = spiritFashionsInfo.SpiritWearFashionsInfo

		if wearInfo then
			local wearList = wearInfo.WearFashionInfoList

			if wearList then
				for i = wearList.Count - 1, 0, -1 do
					if fashionIdSet[wearList[i].FashionId] then
						wearList.RemoveAt(wearList, i)
					end
				end
			end

			local editList = wearInfo.WearFashionEditInfoList

			if editList then
				for i = editList.Count - 1, 0, -1 do
					if fashionIdSet[editList[i].FashionId] then
						editList.RemoveAt(editList, i)
					end
				end
			end
		end
	end
end

module.GMEnableVehicleGyro = function(self, enable)
	print_notice("GMEnableVehicleGyro", enable)

	gStoreManager:GetStoreGroup("DriveControlDriverStore").GYRO_ENABLE = enable
end

module.GMBasketballForceShowSkillBtn = function(self, enable)
	local panelStore = gStoreManager:GetStoreGroup("BasketballHUDGameplayStore")

	panelStore:GMForceShowSkillBtn(enable)
	panelStore:UpdateSkillIcon()
end

module.StartDiceGame = function(self, levelList, entity)
	local optionDataList = {}
	local levelOptionData = {
		id = 1,
		title = LTConfig.TextConfig.GetConfig(73975626).Text,
		options = {}
	}

	if levelList.Length < 0 then
		for i = 0, 3 do
			local data = {}
			local id = 100 + i
			local cfg = LTConfig.PoiGameDiceAIConfig.GetConfig(id)
			data.id = id
			data.label = LTConfig.TextConfig.GetConfig(cfg.SelectionName).Text
			data.drop = 0

			table.insert(levelOptionData.options, data)
		end
	else
		for i = 0, levelList.Length - 1 do
			local data = {}
			local id = levelList[i]
			local cfg = LTConfig.PoiGameDiceAIConfig.GetConfig(id)
			data.id = id
			data.label = LTConfig.TextConfig.GetConfig(cfg.SelectionName).Text
			data.drop = 0

			table.insert(levelOptionData.options, data)
		end
	end

	table.insert(optionDataList, levelOptionData)
	table.insert(optionDataList, 4)
	gPanelManager:CheckShow(gPanelId.COMMON_GAMEPLAY_START_PANEL, {
		playId = LTConfig.GameplayHudDescBeginConfig.Dice,
		options = optionDataList,
		customData = {
			["D\\xbd\\x92\\x99\\x86"] = false,
			entity = entity
		}
	})
end

module.StartDiceGameTaskMode = function(self, levelList, entity, path)
	gPanelManager:CheckShow(gPanelId.S_BAR_GAME_START_PANEL, {
		level = levelList[0],
		customData = {
			entity = entity
		},
		customPath = path
	})
end

module.StartDiceLinkGame = function(self, entity)
	local optionDataList = {}
	local levelOptionData = {}

	table.insert(optionDataList, 4)
	gPanelManager:CheckShow(gPanelId.COMMON_GAMEPLAY_START_PANEL, {
		playId = LTConfig.GameplayHudDescBeginConfig.Dice,
		options = optionDataList,
		customData = {
			["D\\xbd\\x92\\x99\\x86"] = true,
			entity = entity
		}
	})
end

module.AskLeaveDiceZone = function(self, gadgetUId)
	slot2 = gClientToGameSceneDelegate

	slot2:AskLeaveDiceZone(gadgetUId).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("[DiceGame_Net]AskLeaveDiceZone failed", err, gCS.Error.GetNameById(err))
		end
	end
end

module.OpenChaseNPCCountDown = function(self, timer, isclose, callBack)
	if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end

	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_COUNT_DOWN, {
		CallBack = callBack,
		Param = {
			["\t\r"] = 0,
			["ZI糇\\xbd\\xda\\xed"] = false,
			time = timer,
			warningTime = timer
		}
	})
end

module.CloseChaseNPCCountDown = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_COUNT_DOWN) then
		gMessageManager:SendMessage(gEventConstants.FINISH_COUNT_DOWN_SET_CALLBACK, {})
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end
end

module.OpenGomokuStartPanel = function(self)
	slot1 = gClientToGameSceneDelegate

	slot1:QueryGomokuPlayerInfo().Callback = function (errId, playerInfo)
		if errId == 0 then
			print_error("QueryGomokuPlayerInfo Failed Error = ", gCS.Error.GetNameById(errId))
		end

		local refreshRewardCb = function(optionsList, options)
			local rewardList = gGamePlayBeginMgr:GetRewardListByOptions(optionsList, options)
			local itemList = gCommonItemManager:GetItemSortedListByDropList(rewardList, true)
			local difficulty = options[LTConfig.GameplayHudDescBeginOptionConfig.SelectDifficulty] or 0

			for i = 1, #itemList do
				local item = itemList[i]
				local showData = gCommonItemManager:GetItemRenderData({
					itemId = item.Id,
					itemNum = item.Count
				})

				if playerInfo and playerInfo.DroppedDoubleAIDifficultySet[difficulty] then
					showData.IsOwned = true
				end

				itemList[i] = showData
			end

			return itemList
		end

		gPanelManager:CheckShow(gPanelId.COMMON_GAMEPLAY_START_PANEL, {
			playId = LTConfig.GameplayHudDescBeginConfig.Gobang,
			refreshRewardCb = refreshRewardCb
		})
	end
end

module.EnterTakePhoto = function(self, templateType)
	gTakePhotoUtils.OncePhotoTemplate = templateType

	gMessageManager:SendMessage(gEventConstants.ENTER_TAKE_PHOTO)
end

module.EnablePhotoStateTreeSignal = function(self, enable)
	gTakePhotoUtils.UseStateTree = enable
end

module.EnableOldVideoTaskLogic = function(self, enable)
	gTakePhotoUtils.UseOldVideoTaskLogic = enable
end

module.EnableOldPhotoMoreOperationConfig = function(self, enable)
	gTakePhotoUtils.UseOldPhotoMoreOperationConfig = enable
end

module.EnableThirdPersonPhoto = function(self, enable)
	gTakePhotoUtils.UseThirdPersonPhoto = enable
end

module.EnableTimeFreezePhoto = function(self, enable)
	gTakePhotoUtils.UseTimeFreezePhoto = enable
end

module.EnableVideoTaskNotFail = function(self, enable)
	gTakePhotoUtils.DebugVideoTaskNotAllowFail = enable
end

module.EnableVideoTaskNotSuccess = function(self, enable)
	gTakePhotoUtils.DebugVideoTaskNotAllowSuccess = enable
end

module.CheckIsInExtractionShooter = function(self)
	return gExtractionShooterManager.CheckInGame()
end

module.OpenPartyDeadPanel = function(self)
	local info = {
		["T\\x8f\\x82\\xbcٓ\\xd7>\\xa8+\\xbd"] = 0,
		["T\\x8f\\x82\\xbcل\\xc06\\xb93\\xa6"] = 0,
		Type = UX.Game.DieType.FallOffCliff
	}

	gDeadManager:CheckShowPlayerDeadPanel(info)
end

module.TraceTask = function(self, eventId)
	local info = gMapSubSystem_Task.unacceptTask[eventId]
	local element = info and info.mapElement or nil

	gMapSubSystem_Task:ExecuteAction(element, gMapSystemElementAction.TraceTask)
end

module.StartFortune = function(self, gadgetId, pivot)
	gPanelManager:CheckShow(gPanelId.FORTUNE_PANEL, {
		gadgetId = gadgetId,
		pivot = pivot
	})
end

module.StopFortune = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.FORTUNE_PANEL) then
		gPanelManager:Close(gPanelId.FORTUNE_PANEL)
	end
end

module.StartFlyNeedleGame = function(self, gadgetId, difficulty, acupointHideDelay)
	local entity = gGadgetManager:GetEntitySearchByInstanceId(gadgetId)

	if not entity then
		return
	end

	local arg = {
		slotEntity = entity,
		difficulty = difficulty or 0,
		acupointHideDelay = acupointHideDelay
	}

	gFlyNeedleGameManager:CreateGame(arg)
end

module.StartTouHuGame = function(self, gadgetId, difficulty)
	local entity = gGadgetManager:GetEntitySearchByInstanceId(gadgetId)

	if not entity then
		return
	end

	local arg = {
		slotEntity = entity,
		difficulty = difficulty or 0
	}

	gPitchPotGameManager:CreateGame(arg)
end

module.PhotoFavorable = function(self, pid)
	local npc = gCS.SceneDataMgr.GetUnit(pid)

	if not npc then
		print_error("PhotoFavorable: unit not found, pid=", pid)

		return
	end

	gDialogScriptFunc.currentNpc = npc

	gDialogScriptFunc.PhotoFavorable()

	gDialogScriptFunc.currentNpc = nil
end

module.SetWireRiggingControlsState = function(self, isOpen)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		if not isOpen then
			gameplayControlStore.StopGameplayByType(gameplayControlStore, gHUDGameplayType.WIRE_RIGGING_CONTROL)
		else
			gameplayControlStore.StartGameplayByType(gameplayControlStore, gHUDGameplayType.WIRE_RIGGING_CONTROL)
		end
	end
end

module.SetGameplaySurfingPanelState = function(self, isOpen)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		if not isOpen then
			gameplayControlStore.StopGameplayByType(gameplayControlStore, gHUDGameplayType.SURFING)
		else
			gameplayControlStore.StartGameplayByType(gameplayControlStore, gHUDGameplayType.SURFING)
		end
	end
end

module.GetFishTankTransformByGadgetId = function(self, gadgetId)
	return gHouseManager and gHouseManager:GetFishTankTransformByGadgetId(gadgetId) or nil
end

module.GetFishTemplateIdByUniqueId = function(self, uniqueId)
	return gHouseManager and gHouseManager:GetFishTemplateIdByUniqueId(uniqueId) or nil
end

module.UpdateChefRecipeDimensionsUnlock = function(self, list, recipeId)
	local info = gPlayerManager.infoMinor.bindData.ChefUnlockInfo.SubRecipeDict[recipeId]

	for i = 0, list.Count - 1 do
		local index = list[i]

		if not table.contains(info, index) then
			table.insert(info, index)
		end
	end
end

gCsToLuaHandler = module
