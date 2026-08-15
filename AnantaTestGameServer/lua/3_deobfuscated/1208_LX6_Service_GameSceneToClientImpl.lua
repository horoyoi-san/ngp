local gGFConstant = require("LX6/GuideFlow/GFConstant")
local AtmosphereManager = LX6.Manager.AtmosphereManager
local RaidConfig = LTConfig.RaidConfig
local MessageConfig = LTConfig.MessageConfig
local AttrStat = LTConfig.AttributeNameConfig
local AttributeNameConfig = LTConfig.AttributeNameConfig
local UnitStateAtlasConfig = LTConfig.UnitStateAtlasConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local NpcClientType = LX6.Units.NpcClientType
local GameSceneToClientImpl = gRpcChecker:CreateRpcImpl()

function GameSceneToClientImpl.SyncChangeName(pid, name)
	local playerUnit = gCS.SceneDataMgr.GetUnit(pid)

	if playerUnit ~= nil then
		local dataSet = gDataSetManager:GetUnitData(playerUnit.Pid)
		dataSet.name = name
	end

	if pid == gPlayerManager.infoLogin.bindData.pid then
		gPlayerManager.infoLogin.bindData.playerName = name

		if LX6.Engine.ProfileManager.gameProfile.isUsePlayerName then
			gPlayerManager.infoLogin.bindData.name = name
		end

		gCS.MyPlayerManager.PlayerUnit.ClientData.Name = name
		gCS.MyPlayerManager.PlayerInfo.Name = name

		UniSDKManager.OnUserNameChange(name)
		LX6.Utils.DRPFUtils.Clear()
	end

	gMessageManager:SendMessage(gEventConstants.PLAYER_CHANGE_NAME, {
		Pid = pid,
		Name = name
	})
	gBattleNetcodeUtils:SetUserName(pid, name, true)
end

function GameSceneToClientImpl.SyncPlayerRevive()
	if gPanelManager:IsPanelShowing(gPanelId.S_PLAYER_DEAD_PANEL) then
		gPanelManager:Close(gPanelId.S_PLAYER_DEAD_PANEL)
	end

	gLuaUIMgr:RemoveEnterGamePromptPanelID(gPanelId.S_PLAYER_DEAD_PANEL)

	gDeadManager.isDead = false
end

function GameSceneToClientImpl.SyncPlayerDead(info)
	if not gCS.SceneDataMgr.IsRaidEnd and gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene then
		gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
		gCS.CameraDataMgr.MainCamera.gameObject:SetActive(true)

		if gCS.GuiUtils.currentDialogType == gDialogType.FORMAL or gCS.GuiUtils.currentDialogType == gDialogType.BLACK then
			gDialogManager:CloseDialog()
		end

		LX6.GUI.GuiMgr.Instance:ClearShowScenePanel()
	end

	gMessageManager:SendMessage(gEventConstants.SELF_PLAYER_DEAD)

	gDeadManager.isDead = true

	if not gRaidDataManager.isRaidFailed and not gPanelManager:IsPanelShowing(gPanelId.S_PLAYER_DEAD_PANEL) then
		gDeadManager:CheckShowRevivePanel(info)
	end
end

function GameSceneToClientImpl.SyncBreakSkill(unitId)
	gCS.BattleManager.CheckBreakSkill(unitId)
end

function GameSceneToClientImpl.SyncPrepareSwitchSceneTimeline(withoutDefaultTimeline, replaceTimelineName)
	gCS.SwitchSceneManager.notUseDefaultTimeline = withoutDefaultTimeline
	gCS.SwitchSceneManager.targetTimelineName = replaceTimelineName
end

function GameSceneToClientImpl.SyncShowMessage(messageId, args)
	local list = gNewMailsMgr:GetExtraParams(args)

	gDisplayMessageMgr:ShowServerMessage(messageId, list)
end

function GameSceneToClientImpl.SyncShowTipMessage(messageId, type, args, taskId)
	local config = MessageConfig.GetConfig(messageId)

	if not config then
		return
	end

	local s = string.split(gString.Format(config.Content, unpack(args or {})), "//")

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, {
		Param = {
			TipType = 1,
			taskId = taskId,
			taskState = type,
			name = s[1],
			des = s[2]
		}
	})
end

function GameSceneToClientImpl.SyncShowTaskMessage(messageId, args)
	local function func()
		local s = string.split(gString.Format(MessageConfig.GetConfig(messageId).Content, unpack(args or {})), "//")

		return s[1]
	end
end

function GameSceneToClientImpl.SyncTupoInitInfo(initSecond, enemyDieAddSecond)
	return
end

function GameSceneToClientImpl.SyncTupoChangeInfo(leftEnemyCount, totalEnemyCount, leftTime, totalTime, currWave, totalWave, refreshTime)
	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.DeadS) then
		return
	end

	if refreshTime then
		-- Nothing
	end

	if not gTriggerEnemyMgr.syncRemainEnemyGroupId or gTriggerEnemyMgr.syncRemainEnemyGroupId == 0 then
		local function func()
			return
		end

		gPanelManager:CheckShow(gPanelId.RAID_TASK, {
			displayMessage = true,
			taskStrFunc = func,
			progress = currWave .. "/" .. totalWave
		})

		return
	end
end

function GameSceneToClientImpl.SyncUnitHp(pid, hp)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit then
		gCS.LuaUtils.SetUnitHp(pid, hp)
		gCsToLuaHandler:OnUnitHpChange(pid, hp, unit.ClientData.MaxHp, unit.ClientData.Shield)
	end

	gMessageManager:SendMessage(gEventConstants.TEAM_MATE_STATUS_CHANGED, {
		pid = pid,
		hp = hp
	})
end

function GameSceneToClientImpl.SyncClearSpoonEnemies(enemyIds)
	for i = 1, #enemyIds do
		gCS.BattleManager.CheckClearDelayDeath(enemyIds[i])
	end
end

function GameSceneToClientImpl.SyncRemainReviveCount(reviveCount)
	gDeadManager:RefreshReviveCount(reviveCount)
end

function GameSceneToClientImpl.SyncSpiritAbilities(id, values)
	return
end

function GameSceneToClientImpl.SyncSpiritAbility(id, abilityId, value)
	return
end

function GameSceneToClientImpl.SyncSpoonClientSoundTrigger(soundTriggerTiming, nodeId)
	gSoundMgr:SyncSpoonClientSoundTrigger(soundTriggerTiming, nodeId)
end

function GameSceneToClientImpl.SyncUnitLockTarget(unitId, targetId)
	local unit = gCS.SceneDataMgr.GetUnit(unitId)

	if unit then
		if unit.isBoss then
			gBossViewManager:UpdateTargets(unitId, targetId)
		end

		if unit.ClientData.Type == UX.Game.EntityType.Enemy then
			gCS.BattleManager.CheckEnemyLookAtIK_CS(unit)
		end

		unit.LockTargetId = targetId

		if unit.IsMe then
			gCS.LockTargetMgr:SetStrongLockEnemy(targetId)
		end

		if gCS.MyPlayerManager.PlayerUnit and ulong.equals(gCS.MyPlayerManager.PlayerUnit.Pid, targetId) then
			gStealthManager:KillPerceivedEffect(unitId)
		end
	end

	gMessageManager:SendMessage(gEventConstants.UNIT_LOCK_TARGET, {
		triggerId = unitId,
		targetId = targetId
	})
end

function GameSceneToClientImpl.SyncReplayEffects(list)
	if list ~= nil then
		for i = 1, list.Count do
			GameSceneToClientImpl.PlayEffect(list[i])
		end
	end
end

function GameSceneToClientImpl.SyncRaidStartTime(raidInstanceId, time)
	gRaidDataManager:UpdateRaidStartTime(raidInstanceId, time)

	gCS.TimeManager.raidStartTime = time
	gRaidDataManager.StartTime = time

	gCS.LuaUtils.ServerRotationPositionList()
end

function GameSceneToClientImpl.SyncRaidState(raidInstanceId, state)
	gRaidDataManager:UpdateRaidState(raidInstanceId, state)
end

function GameSceneToClientImpl.SyncRemoveEffect(unitId, effectId, instanceId)
	if effectId == 0 then
		return
	end

	local csunit = gCS.SceneDataMgr.GetUnit(unitId)

	if csunit ~= nil then
		gCS.EffectMgr:CleanUpUnitServerEffects(csunit.Pid, effectId, instanceId)
	end
end

function GameSceneToClientImpl.SyncPartyResponse(response, NPCIds)
	return
end

function GameSceneToClientImpl.SyncPartySettleData(settleData)
	return
end

function GameSceneToClientImpl.SyncRaiseVote(voteType, voteSessionId)
	return
end

function GameSceneToClientImpl.SyncCastVote(voteType, voteSessionId, pid, vote)
	return
end

function GameSceneToClientImpl.SyncPlayerPoilceChaseCountDown(countDownType, countDownTime)
	if countDownType == UX.Game.PlayerPoilceChaseCountDownType.Success then
		-- Nothing
	elseif countDownType == UX.Game.PlayerPoilceChaseCountDownType.Fail then
		gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_COUNT_DOWN, {
			Param = {
				isIncrease = false,
				time = countDownTime
			}
		})
	else
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end
end

function GameSceneToClientImpl.SyncPlayerPoliceChasedVehicles(vehicleUId)
	gPoliceChaseManager:SyncPlayerPoliceChasedVehicles(vehicleUId)
end

function GameSceneToClientImpl.SyncPlayerPoliceChaseFinish()
	gPoliceChaseManager:SyncPlayerPoliceChaseFinish()
end

function GameSceneToClientImpl.SyncSwitchControl(spiritId, enemyId, enterOrLeave, reason)
	gCS.BaseUnitModuleUtils.DoHackEnemy(spiritId, enemyId, enterOrLeave)

	if enterOrLeave then
		gPanelManager:CheckShow(gPanelId.S_DRIOD_OUT_AREA_PANEL)
	else
		gPanelManager:Close(gPanelId.S_DRIOD_OUT_AREA_PANEL)
	end

	local cs_unit = gCS.SceneDataMgr.GetUnit(enemyId)

	if not cs_unit or not cs_unit.ClientData or not cs_unit.ClientData.AgentId then
		print_error("unit 数据错误, enemyId=", enemyId, cs_unit or "nil", cs_unit and cs_unit.ClientData or "nil", cs_unit and cs_unit.ClientData and cs_unit.ClientData.AgentId or "nil")

		return
	end

	local agentCfg = LTConfig.AgentConfig.GetConfig(cs_unit.ClientData.AgentId)
	local summonCfg = LTConfig.SummonConfig.GetConfig(agentCfg.SummonTag)

	if not summonCfg then
		print_error("SummonConfig 取不到数据, SummonTag=", agentCfg.SummonTag)

		return
	end

	gBattleMgr.SummonInControl = enterOrLeave
	local data = {
		enterOrLeave = enterOrLeave,
		type = summonCfg.Type,
		reason = reason,
		cs_unit = cs_unit
	}

	if enterOrLeave then
		gBattleMgr.SummonData = data
	else
		gBattleMgr.SummonData = nil
	end

	gMessageManager:SendMessage(gEventConstants.ANDROID_CONTROL_SWITCH, data)
end

function GameSceneToClientImpl.SyncControllableAgent(spiritId, agentId)
	gBattleMgr.SummonAgentId = agentId

	gMessageManager:SendMessage(gEventConstants.SUMMON_STATE_SWITCH, agentId)
end

function GameSceneToClientImpl.SyncShowUnitStateImmune(evt)
	return
end

function GameSceneToClientImpl.SyncNpcName(pid, name)
	local csunit = gCS.NpcMgr:GetNpcByPid(pid)

	if csunit ~= nil then
		local pid = csunit.Pid
		local unit = gDataSetManager:GetUnitData(pid)

		if unit then
			unit.name = name
			local unit = gCS.SceneDataMgr.GetUnit(pid)
			unit.ClientData.Name = name
		end
	end
end

function GameSceneToClientImpl.SyncSceneNpcFadeOut(pid)
	local csunit = gCS.SceneDataMgr.GetUnit(pid)

	if csunit == nil then
		return
	end

	if csunit.NpcType == NpcClientType.Normal then
		csunit.FadeOutEffectId = 53205910

		gCS.BaseUnitUtils.DestroyAgentUnit(csunit, false, true, false)
	end
end

function GameSceneToClientImpl.SyncBeginPortal()
	return
end

function GameSceneToClientImpl.SyncEndPortal()
	Timer.New(function ()
		gMessageManager:SendMessage(gEventConstants.PORTAL_END)
	end, 0.1):Start()

	if gCS.MyPlayerManager.PlayerUnit then
		gUnitStateMgr:LeaveClimbAction(gCS.MyPlayerManager.PlayerUnit)
	end
end

function GameSceneToClientImpl.SyncAgentCampInfo(pid, camp)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit and camp ~= UX.Game.UnitCamp.Unknown then
		gCS.LuaUtils.SetUnitCamp(pid, camp)
	end

	if pid == gPlayerManager.infoBase.bindData.Pid then
		local raidConfig = RaidConfig.GetConfig(gRaidDataManager.RaidId)

		if raidConfig == nil then
			print_error("raidconfig not find", gRaidDataManager.RaidId)
		end
	end
end

function GameSceneToClientImpl.SyncRaidEndReward(raidInstanceId, reward, isAutoDraw)
	gRaidDataManager:UpdateRaidRewardInfo(raidInstanceId, reward)

	gSettlementMgr.Reward = reward

	if reward ~= nil then
		local popupParam = gItemUtils:ConvertRewardDetail(reward)
		gSettlementMgr.Rewarded = true

		gSettlementMgr:ShowRewardPanel(popupParam, isAutoDraw)
	end
end

function GameSceneToClientImpl.SyncRaidSettlement(raidInstanceId, isWin, battleData, optionalDrops, closeTime, nextActivityId)
	gSettlementMgr:OnRaidEnd(raidInstanceId, isWin, battleData, optionalDrops, closeTime, nextActivityId)
end

function GameSceneToClientImpl.SyncRaidCloseTime(closeTime)
	return
end

function GameSceneToClientImpl.SyncClientUseSkill(unitId, targetId, unitPartIndex, targetDestructibleId, skillId, facing, unitPos, location)
	return
end

function GameSceneToClientImpl.SyncBVBEnemyUltEnergy(enemyId, ultEnergy)
	gBattlePetsMgr:SyncBVBEnemyUltEnergy(enemyId, ultEnergy)
end

function GameSceneToClientImpl.SyncBVBStartSelectFightPokemon(fightPokemons, ddl, opponentPokemons)
	gBattlePetsMgr:SyncBVBStartSelectFightPokemon(fightPokemons, ddl, opponentPokemons)
end

function GameSceneToClientImpl.SyncBVBUpdateFightPokemon(fightPokemon)
	gBattlePetsMgr:SyncBVBUpdateFightPokemon(fightPokemon)
end

function GameSceneToClientImpl.SyncBVBUpdateFightPokemons(fightPokemons)
	gBattlePetsMgr:SyncBVBUpdateFightPokemons(fightPokemons)
end

function GameSceneToClientImpl.SyncBVBStartSelectChaosBuff(buffs, ddl, refreshCost)
	gBattlePetsMgr:SyncBVBStartSelectChaosBuff(buffs, ddl, refreshCost)
end

function GameSceneToClientImpl.SyncBVBMoney(money)
	gBattlePetsMgr:SyncBVBMoney(money)
end

function GameSceneToClientImpl.SyncBVBFightEndTime(round, endTime)
	gBattlePetsMgr:SyncBVBFightEndTime(round, endTime)
end

function GameSceneToClientImpl.SyncBVBRoundEnd(result, bonus, nextRoundStartTime)
	gBattlePetsMgr:SyncBVBRoundEnd(result, bonus, nextRoundStartTime)
end

function GameSceneToClientImpl.SyncBVBChaosBuff(buffId, level)
	gBattlePetsMgr:SyncBVBChaosBuff(buffId, level)
end

function GameSceneToClientImpl.SyncBVBGameEnd(gameMode, result, reward)
	gBattlePetsMgr:SyncBVBGameEnd(result, reward)
end

function GameSceneToClientImpl.SyncBVBStartFight(me, other)
	gBattlePetsMgr:SyncBVBStartFight(me.Pokemons, other.Pokemons, me.TagInfos, other.TagInfos, me.ChaosBuffs, other.ChaosBuffs)
end

function GameSceneToClientImpl.SyncBVBUltSkill(agentId)
	gBattlePetsMgr:SyncBVBUltSkill(agentId)
end

function GameSceneToClientImpl.SyncBVBDamageStatistics(data)
	gBattlePetsMgr:SyncBVBDamageStatistics(data)
end

function GameSceneToClientImpl.SyncChaosAgentStatisticInfo(data)
	gBattlePetsMgr:SyncChaosAgentStatisticInfo(data)
end

function GameSceneToClientImpl.SyncBVBChaosTagInfo(tagInfos)
	gBattlePetsMgr:SyncBVBChaosTagInfo(tagInfos)
end

function GameSceneToClientImpl.SyncBVBStartGame(me, other)
	gBattlePetsMgr:SyncBVBStartGame(me, other)
end

function GameSceneToClientImpl.SyncBVBLinkSelectTeam()
	gBattlePetsMgr:SyncBVBLinkSelectTeam()
end

function GameSceneToClientImpl.SyncEnemyDetectStatus(guardPid, stealthValue, state)
	local unit = gCS.SceneDataMgr.GetUnit(guardPid)

	if unit then
		local unitDataSet = gDataSetManager:GetUnitData(unit.Pid)

		if unitDataSet == nil then
			return
		end

		local preState = unitDataSet.detectionState
		unitDataSet.detectionValue = stealthValue
		unitDataSet.detectionState = state
		unitDataSet.detectionToMeValue = stealthValue

		if stealthValue == 100 then
			gLuaTimeMgrUtils.Delay(function ()
				unitDataSet.detectionToMeValue = 0
			end, 0.7)
		end

		gStealthManager:SwitchUnitStealthState(unit.Pid, state, preState, stealthValue)
	end
end

function GameSceneToClientImpl.SyncEnemyDetect(guardPid, stealthCfgId)
	local unit = gCS.SceneDataMgr.GetUnit(guardPid)

	if unit then
		local unitDataSet = gDataSetManager:GetUnitData(unit.Pid)

		if unitDataSet then
			unitDataSet.stealthCfgId = stealthCfgId
		end
	end

	gMapSubSystem_CommonUnit:OnSyncEnemyDetectInfo(guardPid, stealthCfgId)
end

function GameSceneToClientImpl.SyncEnemyLevel(id, level)
	local unit = gCS.SceneDataMgr.GetUnit(id)

	if unit then
		unit.ClientData.Level = level
	end

	local unitData = gDataSetManager:GetUnitData(id)

	if unitData then
		unitData.level = level
	end
end

function GameSceneToClientImpl.SyncShowWorldEnemyRewardMessage(enemyId)
	return
end

function GameSceneToClientImpl.SyncWorldBossStateChange(instanceId, enemySpoonId, state, campId, rebornTime)
	return
end

function GameSceneToClientImpl.SyncPlayerWeather(weatherTypeId, nextWeatherTypeId, transitionSecond)
	AtmosphereManager.Instance:SetWeather(weatherTypeId, transitionSecond)

	AtmosphereManager.Instance.NextWeatherConfigId = nextWeatherTypeId

	gMessageManager:SendMessage(gEventConstants.WEATHER_CHANGE)
end

function GameSceneToClientImpl.SyncShowUnitStateConfliction(state, evt)
	if not gUnitStateManager:IsMessageForbidden(state, evt) then
		if state == UnitStateConfig.DeadS and evt == UnitStateAtlasConfig.TimeJump then
			return
		end

		local stateCfg = UnitStateConfig.GetConfig(state)

		if stateCfg then
			local evtCfg = UnitStateAtlasConfig.GetConfig(evt)

			if evtCfg then
				local statestr = stateCfg.UnitStateNote
				local evtstr = evtCfg.Atlas

				gDisplayMessageMgr:ShowMessage(MessageConfig.StateConflict, nil, nil, statestr, evtstr)
			end
		end
	end
end

function GameSceneToClientImpl.SyncEntityActionGroup(pid, actionGroupId)
	gCS.LuaUtils.SetActionGroupId(pid, actionGroupId, false)
end

function GameSceneToClientImpl.SyncWorldRewardTriggeredInfo(pids)
	local pid = nil

	for i = 1, pids.Count do
		pid = pids[i]
		gLuaDataManager.receivedRewardEnemies[tostring(pid)] = pid
	end
end

function GameSceneToClientImpl.SyncActionDataOpen(open)
	gLuaDataManager.needSyncActionDatas = open
	gLuaDataManager.needSyncEffect = open
	LX6.Item.DestructibleMgr.Instance.needSyncDestructibleDatas = open
end

function GameSceneToClientImpl.SyncGroupEnemyLockTarget(groupId, lockTarget)
	gTriggerEnemyMgr:EnemyGroupSwitchLockState(groupId, lockTarget)
end

function GameSceneToClientImpl.SyncWildEnemyGroupCheckTime(list)
	gTriggerEnemyMgr:ResetActiveList(list)
	gMessageManager:SendMessage(gEventConstants.WILD_ENEMY_CAMP_STATE_CHANGE)
end

function GameSceneToClientImpl.SyncActiveWildEnemyGroup(id, campId, first, ids)
	gTriggerEnemyMgr:AddActiveGroup(id, ids)
	gMessageManager:SendMessage(gEventConstants.WILD_ENEMY_CAMP_STATE_CHANGE, {
		rebornTime = 0,
		campId = campId,
		state = UX.Game.WorldBossState.Default
	})
end

function GameSceneToClientImpl.SyncInactiveWildEnemyGroup(id, campId, last, rebornTime, banned)
	gTriggerEnemyMgr:RemoveActiveGroup(id, banned)
	gMessageManager:SendMessage(gEventConstants.WILD_ENEMY_CAMP_STATE_CHANGE, {
		campId = campId,
		state = UX.Game.WorldBossState.Dead,
		rebornTime = rebornTime
	})
end

function GameSceneToClientImpl.SyncGeneralCutInPost(actionType, timelineType)
	if actionType == 2 then
		gCS.ClimbManager.CheckTimeLine(timelineType, 0, 0)
	end
end

function GameSceneToClientImpl.SyncLuaSlotEntityMessage(signalName)
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, signalName)
end

function GameSceneToClientImpl.SyncPlayerCurrentSpirit(pid, templateId, spiritId, isAgentSwitch)
	gBattleSpiritMgr.SyncPlayerCurrentSpirit(pid, templateId, spiritId, isAgentSwitch)
end

function GameSceneToClientImpl.SyncUnitElement3(battleUnitId, element, value)
	return
end

function GameSceneToClientImpl.SyncUnitHurtEffect(hurterId, attackerId, hurtTemplateId, skillId, hurtEffectFacePos)
	local hurterUnit = gCS.SceneDataMgr.GetUnit(hurterId)
	local attackerUnit = gCS.SceneDataMgr.GetUnit(attackerId)

	if hurterUnit == nil or attackerUnit == nil then
		return
	end

	local hitPos = not gUtils:IsUXPositionNaN(hurtEffectFacePos) and Vector3.New(hurtEffectFacePos.X, hurtEffectFacePos.Y, hurtEffectFacePos.Z) or nil
	local skillHitToLuaData = {
		creationId = 0,
		skillUUID = -1,
		attackPid = attackerId,
		hurtPid = hurterId,
		hurtId = hurtTemplateId,
		hitPoint = hurterUnit ~= nil and hurterUnit.LocalPosition or Vector3.zero,
		hitCenter = attackerUnit ~= nil and attackerUnit.LocalPosition or Vector3.zero,
		hitDirection = hitPos,
		skillId = skillId
	}

	gCS.BattleManager.LuaTryDoHurtAction(attackerId, hurterId, skillHitToLuaData.hitPoint, skillHitToLuaData.hitCenter, skillHitToLuaData.hitDirection, hurtTemplateId, skillId, -1)
end

function GameSceneToClientImpl.SendCustomHotPatchGameSceneToClient(data)
	return
end

function GameSceneToClientImpl.SyncUnitAddBuff(pid, buffItem)
	gBuffUtils:SyncHUDAddBuffViewData(pid, buffItem)
end

function GameSceneToClientImpl.SyncUnitRemoveBuff(pid, instanceId)
	gBuffUtils:SyncHUDRemoveBuffViewData(pid, instanceId)
end

function GameSceneToClientImpl.SyncUnitUpdateBuff(pid, buffItem)
	gBuffUtils:SyncHUDUpdateBuffViewData(pid, buffItem)
end

function GameSceneToClientImpl.SyncUnitBuffList(pid, buffList)
	gBuffUtils:SyncHUDListBuffViewData(pid, buffList)
end

function GameSceneToClientImpl.SyncEnemyPlayAction(enemyId, actionId, time)
	local enemy = gCS.SceneDataMgr.GetUnit(enemyId)

	if enemy then
		if gCS.BattleManager.HasHitState(enemy) then
			return
		end

		local actionTime = gCS.AnimationManager.AnimatorGetAnimationTime(enemy, actionId, enemy.State.ActionGroupId)

		if time == nil or time == 0 then
			time = actionTime
		end

		gCS.AnimControllerManager.PlayAction(enemy, actionId, enemy.State.ActionGroupId, time, 0, -1, false, nil, 0)
		enemy:StopMove()
	end
end

function GameSceneToClientImpl.SyncRaidTargets(targetCounter)
	gRaidDataManager:SetAllTarget(targetCounter)
end

function GameSceneToClientImpl.SyncRaidTargetCounter(targetId, counter)
	gRaidDataManager:UpdateOneTarget(targetId, counter)
end

function GameSceneToClientImpl.SyncGravityFieldOn(id, templateId, position, angle, duration, level)
	local config = LTConfig.GravityConfig.GetConfig(templateId)

	if config then
		gCS.ForceFieldMgr.Instance:CreateForceField(id, config.Key, Vector3.New(position.X, position.Y, position.Z), angle, duration, level)
	end
end

function GameSceneToClientImpl.SyncSpiritUnitUrbanAttrs(id, urbanAttrs)
	local cs_unit = gCS.SceneDataMgr.GetUnit(id)

	if not cs_unit then
		return
	end

	local cardId = cs_unit.ClientData.cardId

	gSpiritManager:SyncSpiritUrbanAttrs(cardId, urbanAttrs)
end

function GameSceneToClientImpl.SyncPoliceDispatchHelicopter(pos, npcId)
	return
end

function GameSceneToClientImpl.SynExitHelicopterView()
	gPanelManager:Close(gPanelId.S_POLICE_HELICOPTER)
end

function GameSceneToClientImpl.SyncCleaningInfo(start, info)
	if not start then
		L50.L50App.Scene.WashMgr.Progress = 0
		L50.L50App.Scene.WashMgr.serverIsStart = false

		if info then
			gPanelManager:CheckShow(gPanelId.S_CLEAR_MAIN, info)
		end
	else
		L50.L50App.Scene.WashMgr.serverIsStart = true
	end

	gWasherManager:SetCurrentCleaningInfo(start, info)
end

function GameSceneToClientImpl.StartProgressTemplateCall(templateCallId, visibility)
	gNewGamePlayProgressMgr:StartProgressTemplate(templateCallId, visibility)
end

function GameSceneToClientImpl.StopProgressTemplateCall(templateCallId)
	gNewGamePlayProgressMgr:StopProgressTemplate(templateCallId)
end

function GameSceneToClientImpl.StartProgress(progressId, startTime, startLength, totalLength, speed)
	gNewGamePlayProgressMgr:ChangeProgressState(progressId, startTime, startLength, totalLength, speed)
end

function GameSceneToClientImpl.StopProgress(progressId)
	gNewGamePlayProgressMgr:StopProgress(progressId)
end

function GameSceneToClientImpl.SyncFightSpiritStartDie(id)
	local unit = gCS.SceneDataMgr.GetUnit(id)

	if not unit then
		return
	end
end

function GameSceneToClientImpl.SyncStopShowAction()
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(true, LX6.PaoKu.TransitionMgr.ShowActionBanReason.ServerBan)
end

function GameSceneToClientImpl.SyncRecoverShowAction()
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(false, LX6.PaoKu.TransitionMgr.ShowActionBanReason.ServerBan)
end

function GameSceneToClientImpl.SyncRaidGamePlayInfo(info)
	gGameplayRecordValueManager:OnChangeRaidGamePlayInfo(info.RecordValueInfo)
end

function GameSceneToClientImpl.SyncRaidGamePlayRecordDoubleValue(recordId, paramId, value)
	gGameplayRecordValueManager:OnChangeRecordDoubleValue(recordId, paramId, value)
end

function GameSceneToClientImpl.SyncRaidGamePlayRecordRemove(recordId, paramId)
	gGameplayRecordValueManager:OnRemoveRecordValue(recordId, paramId)
end

function GameSceneToClientImpl.SyncEnemyMovingLuaSlotId(unitId, luaSlotId, bindRefName, isInit)
	local entity = gGadgetManager:GetEntitySearchByInstanceId(luaSlotId)

	local function check(entityGo, unitId)
		local area = entityGo:GetComponentInParent(typeof(L18.Script.LX6.MoveGroundArea))

		if area then
			local e = gCS.SceneDataMgr.GetUnit(unitId)
			local pos = entityGo.transform.position

			if e then
				if isInit then
					e:SetMyPositionNoCheck(pos.x, pos.y, pos.z)
				end

				e:SetMotorMoveCollider(true)
			end

			gCS.LuaUtils.BindMoveGround(unitId)
		end
	end

	local slotName = bindRefName
	local gameObjectMap = entity and entity:GetGameObjectMap():ToTable() or nil
	local go = nil

	if gameObjectMap then
		for i, v in pairs(gameObjectMap) do
			if v.name == slotName then
				go = v

				break
			end
		end
	end

	if not gCS.LuaUtils.IsNull(go) then
		local entityGo = go

		check(entityGo, unitId)
	end
end

function GameSceneToClientImpl.SyncGamePause(v)
	gLuaUIMgr.GamePause = v

	gCS.PauseManager.Instance:SyncBreakStateFromServer(v)

	if gLuaUIMgr.uidLayerPanelStore then
		gLuaUIMgr.uidLayerPanelStore:ShowPauseInfo(v)
	end
end

function GameSceneToClientImpl.SyncMultiplayerStatus(isMultiplayer)
	gPauseManager.isMultiplayer = isMultiplayer
end

function GameSceneToClientImpl.SyncAreaTargetCounter(targetId, counter)
	gSeasonDataMgr:UpdateAreaTargetCounterDatas({
		[targetId] = counter
	})
end

function GameSceneToClientImpl.SyncSceneItemValueChange(type, id, name, value)
	if type == UX.Game.SceneItemEntityType.Gadget then
		gGadgetManager:ChangeGadgetValue(id, name, value)
	elseif type == UX.Game.SceneItemEntityType.Destructible then
		-- Nothing
	end
end

function GameSceneToClientImpl.SyncSceneItemSignalSend(type, id, signalName)
	if type == UX.Game.SceneItemEntityType.Gadget then
		-- Nothing
	elseif type == UX.Game.SceneItemEntityType.Destructible then
		-- Nothing
	end
end

function GameSceneToClientImpl.SyncInteractBindPerformance(id, gadgetId, bindId, interactActionType, index, dynamicBindItem, startTime, delayTime)
	local unitPid = LX6.TimelineScript.TimelineUtils.Bridge_GetUnitPidByPlayerPid(id)
	local unit = gCS.SceneDataMgr.GetUnit(unitPid)

	if unit and not unit.IsMe then
		local gadgetEntity = gGadgetManager:GetEntitySearchByInstanceId(gadgetId)

		if not gadgetEntity or bindId == 0 then
			print_error("SyncInteractBindPerformance gadgetEntity == nil", gadgetId, bindId)

			return
		end

		local gameObjectMap = gadgetEntity:GetGameObjectMap()
		local trans = gameObjectMap[bindId]
		local timePass = LTUtils.UXTime.GetNowUnixTime() - startTime
		delayTime = delayTime < timePass and 0 or delayTime - timePass

		gInteractionManager:GadgetDynamicBind(unit, interactActionType, index, dynamicBindItem, delayTime, trans)
	end
end

function GameSceneToClientImpl.SyncCaptureEnemy(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	gInteractionManager:UnitStartStorge(unit)
end

function GameSceneToClientImpl.SyncSceneItemOccupantChange(type, id, pid, index, add)
	if type == UX.Game.SceneItemEntityType.Gadget then
		gGadgetManager:ModifySceneInterestPoint(id, add, index, pid)
	elseif type == UX.Game.SceneItemEntityType.Destructible then
		-- Nothing
	end
end

function GameSceneToClientImpl.SyncSceneItemLinkOccupantChange(type, id, linkId)
	if type == UX.Game.SceneItemEntityType.Gadget then
		gSpoonClientMgr:ReleaseContextEvent(id, gSpoonEventType.OnlineGameplayOccupy, not linkId == 0)
	end
end

function GameSceneToClientImpl.SyncScenePlayerName(uid, name)
	gBattleNetcodeUtils:SetUserName(uid, name, false)
end

function GameSceneToClientImpl.SyncLinkMemberSceneInfoChange(pid, name, position, facing, raidId)
	gLinkManager:OnMemberPosInfoChange(pid, name, position, facing, raidId)
end

function GameSceneToClientImpl.SyncLinkMemberVehicleInfoChange(pid, vehicleEntityId, vehicleTemplateId, seatIndex)
	gLinkManager:OnMemberVehicleInfoChange(pid, vehicleEntityId, vehicleTemplateId, seatIndex)
end

function GameSceneToClientImpl.SyncLinkMemberInfo(member)
	gLinkManager:InitLinkMember(member)
end

function GameSceneToClientImpl.SyncMatchGameSettleData(data, success)
	gChallengeManager:OnSyncOnlineChallengeData(data, success)
end

function GameSceneToClientImpl.SyncMatchGameMembersAllLoaded(gameStartTime)
	gLinkManager.gameStartTime = gameStartTime
end

function GameSceneToClientImpl.SyncOutOfJam()
	gCsToLuaHandler:ClearPaoku()
	gCS.MindPowerMgr:LeaveMagnet()
end

function GameSceneToClientImpl.SyncEnemyFightEdict(pid, isGive)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	unit.ClientData.HaveAttackToken = isGive
end

function GameSceneToClientImpl.SyncEnemyPoiseRate(id, ratio)
	local unit = gCS.SceneDataMgr.GetUnit(id)

	if unit == nil then
		return
	end

	unit.ClientData.DisarmRate = ratio

	gHudMgr:DisarmChanged(id)
end

function GameSceneToClientImpl.SyncEnemyDisarmState(id, isDisarmed)
	return
end

function GameSceneToClientImpl.SyncEnemyPoiseWeaponChangeInfo(id, values)
	gBattleMgr:SetEnemyPoiseWeaponChangeInfo(id, values)
end

function GameSceneToClientImpl.SyncSpiritWeaponDetail(spiritWeaponDetail)
	if spiritWeaponDetail.SpiritUid == gBattleSpiritMgr.currentSpiritPid then
		gWeaponManager:SyncCurrWeaponSlots(spiritWeaponDetail.WeaponSlots)
		gWeaponManager:SyncCurrTempWeaponSlots(spiritWeaponDetail.TempWeaponSlots)
		gWeaponManager:SyncTempExtraWeapon(spiritWeaponDetail.CurrentTempWeapon)
		gWeaponManager:OnSwitchCurrentWeapon(spiritWeaponDetail.CurrentWeaponUid)
	end

	gWeaponManager:SyncSpiritWeaponSlot(spiritWeaponDetail.SpiritTid, spiritWeaponDetail.WeaponSlots)
end

function GameSceneToClientImpl.SyncSpiritAddWeaponAction(spiritAddWeaponAction)
	if spiritAddWeaponAction.SlotIndex == -1 then
		gWeaponManager:SyncTempExtraWeapon(spiritAddWeaponAction.Weapon)
		gWeaponManager:OnSwitchCurrentWeapon(spiritAddWeaponAction.Weapon.InstanceId)

		return
	end

	if spiritAddWeaponAction.SpiritUid == gBattleSpiritMgr.currentSpiritPid then
		if gWeaponManager.TempWeaponMode then
			gWeaponManager:SyncCurrTempWeaponSlotsAdd(spiritAddWeaponAction.SlotIndex, spiritAddWeaponAction.Weapon)
		else
			gWeaponManager:SyncCurrWeaponSlotsAdd(spiritAddWeaponAction.SlotIndex, spiritAddWeaponAction.Weapon)
		end
	end

	if not gWeaponManager.TempWeaponMode then
		gWeaponManager:SyncSpiritWeaponSlotsAdd(spiritAddWeaponAction.SpiritTid, spiritAddWeaponAction.SlotIndex, spiritAddWeaponAction.Weapon)
	end
end

function GameSceneToClientImpl.SyncSpiritRemoveWeaponAction(spiritRemoveWeaponAction)
	if spiritRemoveWeaponAction.SpiritUid == gBattleSpiritMgr.currentSpiritPid then
		if gWeaponManager.TempWeaponMode then
			gWeaponManager:SyncCurrTempWeaponSlotsRemove(spiritRemoveWeaponAction.WeaponUid, spiritRemoveWeaponAction.Reason)
		else
			gWeaponManager:SyncCurrWeaponSlotsRemove(spiritRemoveWeaponAction.WeaponUid, spiritRemoveWeaponAction.Reason)
		end

		gWeaponManager:TryRemoveTempExtraWeapon(spiritRemoveWeaponAction.WeaponUid)
	end

	if not gWeaponManager.TempWeaponMode then
		gWeaponManager:SyncSpiritWeaponSlotsRemove(spiritRemoveWeaponAction.SpiritTid, spiritRemoveWeaponAction.WeaponUid, spiritRemoveWeaponAction.Reason)
	end
end

function GameSceneToClientImpl.SyncWeaponDurabilityChanged(weaponId, durability)
	gWeaponManager:SyncCurrWeaponSlotsDurability(weaponId, durability)
	gMessageManager:SendMessage(gEventConstants.WEAPON_DURABILITY_CHANGE, {
		weaponId = weaponId,
		durability = durability
	})
end

function GameSceneToClientImpl.SyncSpiritUpdateWeaponAction(spiritUpdateWeaponAction)
	if spiritUpdateWeaponAction.SpiritUid == gBattleSpiritMgr.currentSpiritPid then
		gWeaponManager:SyncOperatorFlags(spiritUpdateWeaponAction.Weapon.InstanceId, spiritUpdateWeaponAction.Weapon.OperatorFlags)
	end
end

function GameSceneToClientImpl.SyncSpiritSwitchWeaponAction(spiritSwitchWeaponDetail)
	local unit = gCS.SceneDataMgr.GetUnit(spiritSwitchWeaponDetail.SpiritUid)

	if unit == nil then
		return
	end

	if not unit.IsMe then
		return
	end

	gWeaponManager:OnSwitchCurrentWeapon(spiritSwitchWeaponDetail.WeaponInstanceId)
end

local GameGroundZoneType = UX.Game.GameGroundZoneType

function GameSceneToClientImpl.SyncGameGroundZoneInfo(zoneInfo)
	if zoneInfo.ZoneType == GameGroundZoneType.Dart then
		gDartsGameManager:OnSyncZoneInfo(zoneInfo.GadgetUId, zoneInfo, true)
	elseif zoneInfo.ZoneType == GameGroundZoneType.Bowling then
		gBowlingGameManager:OnSyncGameGroundZoneInfo(zoneInfo)
	end
end

function GameSceneToClientImpl.SyncGameGroundZonePlayerInfo(uId, participantInfo, add)
	gDartsGameManager:OnServerEnterRoom(uId, participantInfo)
	gBowlingGameManager:OnSyncGameGroundZonePlayerInfo(uId, participantInfo, add)
end

function GameSceneToClientImpl.SyncGameGroundZoneState(uId, state)
	gDartsGameManager:OnGameStateChange(uId, state)
	gBowlingGameManager:OnSyncGameGroundZoneState(uId, state)
end

function GameSceneToClientImpl.SyncGameGroundZoneTurnChange(uId, currentRound, currentTurn)
	gBowlingGameManager:OnSyncGameGroundZoneTurnChange(uId, currentRound, currentTurn)
end

function GameSceneToClientImpl.SyncDartScoreInfo(uId, scoreInfo)
	gDartsGameManager:OnSyncDartScoreInfo(uId, scoreInfo)
end

function GameSceneToClientImpl.SyncBowlingScoreInfo(uId, scoreInfo)
	gBowlingGameManager:OnSyncBowlingScoreInfo(uId, scoreInfo)
end

function GameSceneToClientImpl.SyncBowlingClientInfo(info)
	gBowlingGameManager:OnSyncBowlingClientInfo(info)
end

function GameSceneToClientImpl.SyncPlayerCrimeLevel(crimeValue)
	if gMapSubSystem_Crime then
		gMapSubSystem_Crime:SyncPlayerCrimeLevel(crimeValue)
	end
end

function GameSceneToClientImpl.SyncPoliceBeginArrest(agentId, targetPid, ArrestType)
	if targetPid ~= gPlayerManager.infoLogin.bindData.pid then
		return
	end

	if ArrestType == 0 then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PlayerUnderArrest, MuGenStates.Logic.GameplayEventParam1.BeingArrest1)
	elseif ArrestType == 1 then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PlayerUnderArrestInCar)
	end

	gPanelManager:CheckShow(gPanelId.S_PLAYER_RARRESTED_PANEL)
end

function GameSceneToClientImpl.SyncPoliceEscape(value)
	if gMapSubSystem_Crime then
		gMapSubSystem_Crime:SyncPoliceEscape(value)
	end
end

function GameSceneToClientImpl.SyncPoliceEscapeSuccess()
	if gMapSubSystem_Crime then
		gMapSubSystem_Crime:SyncPoliceEscapeSuccess()
	end
end

function GameSceneToClientImpl.SyncMatchGameLeftFailureDieCount(leftFailureDieCount)
	gLinkManager:OnMatchGameLeftFailureCountUpdate(leftFailureDieCount)
end

function GameSceneToClientImpl.SyncSandevistanStart(speed)
	if gCS.DriveManager.CurrentPlayerVehicle then
		gCS.DriveManager.CurrentPlayerVehicle:SetEnableCopyMesh(true)
	end

	gCS.BattleManager.CostFightResource(gCS.MyPlayerManager.PlayerUnit, LTConfig.SkillResourcesConfig.DriveTimeScaleEnergy, 1, false)
	gPauseManager:StartGamePlayPause_CustomData_ChangeOthersTimeSpeed(speed)
end

function GameSceneToClientImpl.SyncSandevistanEnd()
	if gCS.DriveManager.CurrentPlayerVehicle then
		gCS.DriveManager.CurrentPlayerVehicle:SetEnableCopyMesh(false)
	end

	gPauseManager:EndGamePlayPause_CustomData_ChangeOthersTimeSpeed()
end

function GameSceneToClientImpl.SyncAgentDiseaseAttack(agentId)
	gMessageManager:SendMessage(gEventConstants.MINIMAP_PATIENT_APPEAR, agentId)
end

function GameSceneToClientImpl.SyncAgentDiseaseCured(agentId, disease)
	gMessageManager:SendMessage(gEventConstants.MINIMAP_PATIENT_HIDE, agentId)
end

function GameSceneToClientImpl.SyncAgentPoliceExamData(agentId, data)
	gPoliceJobManager:OnSyncAgentPoliceExamData(agentId, data)
end

function GameSceneToClientImpl.SyncTaxiReachDestination(vehicleId)
	if gTaxiManager.TaxiVehicleUid == vehicleId then
		gTaxiManager.ReachDestination = true
	end
end

function GameSceneToClientImpl.SyncFakePersonRed(agentId, isRed)
	gPoliceJobManager:SyncFakePersonRed(agentId, isRed)
end

function GameSceneToClientImpl.SyncPlayerLoadRate(pid, rate)
	gLoadingManager:UpdateMultiPlayerLoadRate(pid, rate)
end

function GameSceneToClientImpl.SyncPlayerCurrentOxygenValue(oxygenValue)
	gMessageManager:SendMessage(gEventConstants.ON_OXYGEN_UPDATE, oxygenValue)
end

function GameSceneToClientImpl.SyncPlayerOxygenSystemState(isOpen)
	gMessageManager:SendMessage(gEventConstants.ON_OXYGEN_OPEN, isOpen)
end

function GameSceneToClientImpl.SyncPlayerOutOfStuck(outOfStuckTeleportType)
	gMessageManager:SendMessage(gEventConstants.SETTING_OUT_OF_STUCK)
end

function GameSceneToClientImpl.SyncToggleUnitMiniMapHostileIcon(id, flag)
	if gMapSubSystem_CommonUnit then
		gMapSubSystem_CommonUnit:SetServerHostileUnit(id, flag)
	end
end

function GameSceneToClientImpl.SyncConvertTaskNpcToPed(pid, pedInitData)
	gAgentTrustManager:OnNpcConvertToPed(pid)
end

return GameSceneToClientImpl
