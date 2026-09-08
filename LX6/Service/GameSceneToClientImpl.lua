-- Original chunk: @Lua\LuaFiles\LX6\Service\GameSceneToClientImpl.lua
-- Decompiled from: 02354_GameSceneToClientImpl.lua_10b20d54f7a6.luajit

local gGFConstant = require("LX6/GuideFlow/GFConstant")
local AtmosphereManager = LX6.Manager.AtmosphereManager
local RaidConfig = LTConfig.RaidConfig
local MessageConfig = LTConfig.MessageConfig
local UnitStateAtlasConfig = LTConfig.UnitStateAtlasConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local NpcClientType = LX6.Units.NpcClientType
local SceneitemVirtualWeaponSlotConfig = LTConfig.SceneitemVirtualWeaponSlotConfig
local TaxiManager = LX6.Drive.GamePlay.TaxiSystemManager.Instance
slot9 = gRpcChecker
local GameSceneToClientImpl = slot9:CreateRpcImpl()

GameSceneToClientImpl.SyncChangeName = function(pid, name)
	local playerUnit = gCS.SceneDataMgr.GetUnit(pid)

	if playerUnit == nil then
		local dataSet = gDataSetManager:GetUnitData(playerUnit.Pid)
		dataSet.name = name
	end

	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		gHunLunManager:ApplyPlayerNameChange(name)
	else
		if gLinkPlayerHub then
			gLinkPlayerHub:UpdatePlayerName(pid, name)
		end

		gMessageManager:SendMessage(gEventConstants.PLAYER_CHANGE_NAME, {
			Pid = pid,
			Name = name
		})
	end

	gBattleNetcodeUtils:SetUserName(pid, name, true)
end

GameSceneToClientImpl.SyncPlayerRevive = function()
	if gPanelManager:IsPanelShowing(gPanelId.S_PLAYER_DEAD_PANEL) then
		gPanelManager:Close(gPanelId.S_PLAYER_DEAD_PANEL)
	end

	gLuaUIMgr:RemoveEnterGamePromptPanelID(gPanelId.S_PLAYER_DEAD_PANEL)

	gDeadManager.isDead = false
end

GameSceneToClientImpl.SyncPlayerDead = function(info)
	if not gCS.SceneDataMgr.IsRaidEnd and gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene then
		gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
		gCS.CameraDataMgr.MainCamera.gameObject:SetActive(true)

		if gCS.GuiUtils.currentDialogType ~= gDialogType.FORMAL or gCS.GuiUtils.currentDialogType ~= gDialogType.BLACK then
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

GameSceneToClientImpl.SyncBreakSkill = function(unitId)
	gCS.BattleManager.CheckBreakSkill(unitId)
end

GameSceneToClientImpl.SyncPrepareSwitchSceneTimeline = function(withoutDefaultTimeline, replaceTimelineName)
end

GameSceneToClientImpl.SyncShowMessage = function(messageId, args)
	local list = gNewMailsMgr:GetExtraParams(args)

	gDisplayMessageMgr:ShowServerMessage(messageId, list)
end

GameSceneToClientImpl.SyncShowTipMessage = function(messageId, type, args, taskId)
	local config = MessageConfig.GetConfig(messageId)

	if not config then
		return
	end

	local s = string.split(gString.Format(config.Content, unpack(args or {})), "//")

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, {
		Param = {
			["\\xed\\xd2)4\\xf4"] = 1,
			taskId = taskId,
			taskState = type,
			name = s[1],
			des = s[2]
		}
	})
end

GameSceneToClientImpl.SyncTupoInitInfo = function(initSecond, enemyDieAddSecond)
end

GameSceneToClientImpl.SyncTupoChangeInfo = function(leftEnemyCount, totalEnemyCount, leftTime, totalTime, currWave, totalWave, refreshTime)
	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.DeadS) then
		return
	end

	if refreshTime then
		-- Nothing
	end

	if not gTriggerEnemyMgr.syncRemainEnemyGroupId or gTriggerEnemyMgr.syncRemainEnemyGroupId ~= 0 then
		local func = function()
		end

		gPanelManager:CheckShow(gPanelId.RAID_TASK, {
			["\\xe3\\x93\\xfc\\xff6\\xef\\x9b\\xfe\\x83'-"] = true,
			taskStrFunc = func,
			progress = currWave .. "/" .. totalWave
		})

		return
	end
end

GameSceneToClientImpl.SyncUnitHp = function(pid, hp)
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

GameSceneToClientImpl.SyncClearSpoonEnemies = function(enemyIds)
	for i = 1, #enemyIds do
		gCS.BattleManager.CheckClearDelayDeath(enemyIds[i])
	end
end

GameSceneToClientImpl.SyncRemainReviveCount = function(reviveCount)
	gDeadManager:RefreshReviveCount(reviveCount)
end

GameSceneToClientImpl.SyncSpiritAbilities = function(id, values)
end

GameSceneToClientImpl.SyncSpiritAbility = function(id, abilityId, value)
end

GameSceneToClientImpl.SyncSpoonClientSoundTrigger = function(soundTriggerTiming, nodeId)
	gSoundMgr:SyncSpoonClientSoundTrigger(soundTriggerTiming, nodeId)
end

GameSceneToClientImpl.SyncUnitLockTarget = function(unitId, targetId)
	local unit = gCS.SceneDataMgr.GetUnit(unitId)

	if unit then
		if unit.IsMe then
			return
		end

		if unit.isBoss then
			gBossViewManager:UpdateTargets(unitId, targetId)
		end

		if unit.ClientData.Type ~= UX.Game.EntityType.Enemy then
			gCS.BattleManager.CheckEnemyLookAtIK_CS(unit)
		end

		unit.LockTargetId = targetId
	end

	gMessageManager:SendMessage(gEventConstants.UNIT_LOCK_TARGET, {
		triggerId = unitId,
		targetId = targetId
	})
end

GameSceneToClientImpl.SyncReplayEffects = function(list)
	if list == nil then
		for i = 1, list.Count do
			GameSceneToClientImpl.PlayEffect(list[i])
		end
	end
end

GameSceneToClientImpl.SyncRaidStartTime = function(raidInstanceId, time)
	gRaidDataManager:UpdateRaidStartTime(raidInstanceId, time)

	gCS.TimeManager.raidStartTime = time
	gRaidDataManager.StartTime = time

	gCS.LuaUtils.ServerRotationPositionList()
end

GameSceneToClientImpl.SyncRaidState = function(raidInstanceId, state)
	gRaidDataManager:UpdateRaidState(raidInstanceId, state)
end

GameSceneToClientImpl.SyncRemoveEffect = function(unitId, effectId, instanceId)
	if effectId ~= 0 then
		return
	end

	local csunit = gCS.SceneDataMgr.GetUnit(unitId)

	if csunit == nil then
		gCS.EffectMgr:CleanUpUnitServerEffects(csunit.Pid, effectId, instanceId)
	end
end

GameSceneToClientImpl.SyncPartyResponse = function(response, NPCIds)
	gPartyManager:OnSyncResponse(response, NPCIds)
end

GameSceneToClientImpl.SyncPartySettleData = function(settleData)
	gPartyManager:OnSyncSettleData(settleData)
end

GameSceneToClientImpl.SyncPartyPlayerLogin = function(info)
	gPartyManager:SyncPartyPlayerLogin(info)
end

GameSceneToClientImpl.SyncPartyStart = function(partyOverTime, lotteryStartTime)
	gPartyManager:OnSyncPartyStart(partyOverTime, lotteryStartTime)
end

GameSceneToClientImpl.SyncLotteryCountdown = function(itemId, itemCount, participants)
	gPartyManager:OnSyncLotteryCountdown(itemId, itemCount, participants)
end

GameSceneToClientImpl.SyncLotteryResult = function(results)
	gPartyManager:OnSyncLotteryResult(results)
end

GameSceneToClientImpl.SyncPartyDanceInvite = function(info)
	gPartyManager:OnSyncPartyDanceInvite(info)
end

GameSceneToClientImpl.SyncPartyDanceSongRecommend = function(musicId)
	gPartyManager:OnSyncPartyDanceSongRecommend(musicId)
end

GameSceneToClientImpl.SyncPartyDanceStart = function(info)
	gPartyManager:OnSyncPartyDanceStart(info)
end

GameSceneToClientImpl.SyncPartyDanceEnd = function(zoneGadgetUId)
	gPartyManager:OnSyncPartyDanceEnd(zoneGadgetUId)
end

GameSceneToClientImpl.SyncPartyDancePartnerState = function(partnerPid, state)
	gPartyManager:OnSyncPartyDancePartnerState(partnerPid, state)
end

GameSceneToClientImpl.SyncPartyDanceSettle = function(info)
	gPartyManager:OnSyncPartyDanceSettle(info)
end

GameSceneToClientImpl.SyncPartyDanceFloorState = function(state)
	gPartyManager:OnSyncPartyDanceFloorState(state)
end

GameSceneToClientImpl.SyncPartyDanceFloorCountdown = function(zoneGadgetUId, totalSeconds, startTimestamp)
	gPartyManager:OnSyncPartyDanceFloorCountdown(zoneGadgetUId, totalSeconds, startTimestamp)
end

GameSceneToClientImpl.SyncRaiseVote = function(data, type, voteSessionId)
	gLinkManager:OnSyncRaiseVote(data, type, voteSessionId)
end

GameSceneToClientImpl.SyncCastVote = function(voteType, voteSessionId, pid, vote)
	gLinkManager:OnSyncCastVote(voteType, voteSessionId, pid, vote)
end

GameSceneToClientImpl.SyncVoteEnd = function(voteSessionId)
	gLinkManager:OnVoteEnd(voteSessionId)
end

GameSceneToClientImpl.SyncPlayerPoilceChaseCountDown = function(countDownType, countDownTime)
	if countDownType ~= UX.Game.PlayerPoilceChaseCountDownType.Success then
		-- Nothing
	elseif countDownType ~= UX.Game.PlayerPoilceChaseCountDownType.Fail then
		gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_COUNT_DOWN, {
			Param = {
				["ZI糇\\xbd\\xda\\xed"] = false,
				time = countDownTime
			}
		})
	else
		gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
	end
end

GameSceneToClientImpl.SyncPlayerPoliceChasedVehicles = function(vehicleUId)
	gPoliceChaseManager:SyncPlayerPoliceChasedVehicles(vehicleUId)
end

GameSceneToClientImpl.SyncPlayerPoliceChaseFinish = function()
	gPoliceChaseManager:SyncPlayerPoliceChaseFinish()
end

GameSceneToClientImpl.SyncSwitchControl = function(spiritId, enemyId, enterOrLeave, reason)
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

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.PhoneCall, "isSummonAgentControl", enterOrLeave)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.MilkCar, "isSummonAgentControl", enterOrLeave)

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

GameSceneToClientImpl.SyncControllableAgent = function(spiritId, agentId)
	gBattleMgr.SummonAgentId = agentId

	gMessageManager:SendMessage(gEventConstants.SUMMON_STATE_SWITCH, agentId)
end

GameSceneToClientImpl.SyncShowUnitStateImmune = function(evt)
end

GameSceneToClientImpl.SyncNpcName = function(pid, name)
	local csunit = gCS.LocalUnitMgr:GetNpcByPid(pid)

	if csunit == nil then
		local pid = csunit.Pid
		local unit = gDataSetManager:GetUnitData(pid)

		if unit then
			unit.name = name
			local unit = gCS.SceneDataMgr.GetUnit(pid)
			unit.ClientData.Name = name
		end
	end
end

GameSceneToClientImpl.SyncSceneNpcFadeOut = function(pid)
	local csunit = gCS.SceneDataMgr.GetUnit(pid)

	if csunit ~= nil then
		return
	end

	if csunit.NpcType ~= NpcClientType.Normal then
		csunit.FadeOutEffectId = 53205910

		gCS.BaseUnitUtils.DestroyAgentUnit(csunit, false, true, false)
	end
end

GameSceneToClientImpl.SyncBeginPortal = function()
end

GameSceneToClientImpl.SyncEndPortal = function()
	Timer.New(function ()
		gMessageManager:SendMessage(gEventConstants.PORTAL_END)
	end, 0.1):Start()

	if gCS.MyPlayerManager.PlayerUnit then
		gUnitStateMgr:LeaveClimbAction(gCS.MyPlayerManager.PlayerUnit)
	end
end

GameSceneToClientImpl.SyncAgentCampInfo = function(pid, camp)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit and camp == UX.Game.UnitCamp.Unknown then
		gCS.LuaUtils.SetUnitCamp(pid, camp)
	end

	if pid ~= gPlayerManager.infoBase.bindData.Pid then
		local raidConfig = RaidConfig.GetConfig(gRaidDataManager.RaidId)

		if raidConfig ~= nil then
			print_error("raidconfig not find", gRaidDataManager.RaidId)
		end
	end
end

GameSceneToClientImpl.SyncRaidEndReward = function(raidInstanceId, reward, isAutoDraw)
	gRaidDataManager:UpdateRaidRewardInfo(raidInstanceId, reward)

	gSettlementMgr.Reward = reward

	if reward == nil then
		local popupParam = gItemUtils:ConvertRewardDetail(reward)
		gSettlementMgr.Rewarded = true

		gSettlementMgr:ShowRewardPanel(popupParam, isAutoDraw)
	end
end

GameSceneToClientImpl.SyncRaidSettlement = function(raidInstanceId, isWin, battleData, optionalDrops, closeTime, nextActivityId)
	gSettlementMgr:OnRaidEnd(raidInstanceId, isWin, battleData, optionalDrops, closeTime, nextActivityId)
end

GameSceneToClientImpl.SyncRaidCloseTime = function(closeTime)
end

GameSceneToClientImpl.SyncClientUseSkill = function(unitId, targetId, unitPartIndex, targetDestructibleId, skillId, facing, unitPos, location)
end

GameSceneToClientImpl.SyncBVBEnemyUltEnergy = function(enemyId, ultEnergy)
	gBattlePetsMgr:SyncBVBEnemyUltEnergy(enemyId, ultEnergy)
end

GameSceneToClientImpl.SyncBVBStartSelectFightPokemon = function(fightPokemons, ddl, opponentPokemons)
	gBattlePetsMgr:SyncBVBStartSelectFightPokemon(fightPokemons, ddl, opponentPokemons)
end

GameSceneToClientImpl.SyncBVBUpdateFightPokemon = function(fightPokemon)
	gBattlePetsMgr:SyncBVBUpdateFightPokemon(fightPokemon)
end

GameSceneToClientImpl.SyncBVBUpdateFightPokemons = function(fightPokemons)
	gBattlePetsMgr:SyncBVBUpdateFightPokemons(fightPokemons)
end

GameSceneToClientImpl.SyncBVBStartSelectChaosBuff = function(buffs, ddl, refreshCost)
	gBattlePetsMgr:SyncBVBStartSelectChaosBuff(buffs, ddl, refreshCost)
end

GameSceneToClientImpl.SyncBVBMoney = function(money)
	gBattlePetsMgr:SyncBVBMoney(money)
end

GameSceneToClientImpl.SyncBVBFightEndTime = function(round, endTime)
	gBattlePetsMgr:SyncBVBFightEndTime(round, endTime)
end

GameSceneToClientImpl.SyncBVBRoundEnd = function(result, bonus, nextRoundStartTime)
	gBattlePetsMgr:SyncBVBRoundEnd(result, bonus, nextRoundStartTime)
end

GameSceneToClientImpl.SyncBVBChaosBuff = function(buffId, level)
	gBattlePetsMgr:SyncBVBChaosBuff(buffId, level)
end

GameSceneToClientImpl.SyncBVBGameEnd = function(gameMode, result, reward)
	gBattlePetsMgr:SyncBVBGameEnd(result, reward)
end

GameSceneToClientImpl.SyncBVBStartFight = function(me, other)
	gBattlePetsMgr:SyncBVBStartFight(me.Pokemons, other.Pokemons, me.TagInfos, other.TagInfos, me.ChaosBuffs, other.ChaosBuffs)
end

GameSceneToClientImpl.SyncBVBUltSkill = function(agentId)
	gBattlePetsMgr:SyncBVBUltSkill(agentId)
end

GameSceneToClientImpl.SyncBVBDamageStatistics = function(data)
	gBattlePetsMgr:SyncBVBDamageStatistics(data)
end

GameSceneToClientImpl.SyncChaosAgentStatisticInfo = function(data)
	gBattlePetsMgr:SyncChaosAgentStatisticInfo(data)
end

GameSceneToClientImpl.SyncBVBChaosTagInfo = function(tagInfos)
	gBattlePetsMgr:SyncBVBChaosTagInfo(tagInfos)
end

GameSceneToClientImpl.SyncBVBStartGame = function(me, other)
	gBattlePetsMgr:SyncBVBStartGame(me, other)
end

GameSceneToClientImpl.SyncBVBLinkSelectTeam = function()
	gBattlePetsMgr:SyncBVBLinkSelectTeam()
end

local shakeTimer = nil

GameSceneToClientImpl.SyncEnemyDetectStatus = function(guardPid, stealthValue, state)
	local unit = gCS.SceneDataMgr.GetUnit(guardPid)

	if unit then
		local unitDataSet = gDataSetManager:GetUnitData(unit.Pid)

		if unitDataSet ~= nil then
			return
		end

		unitDataSet.detectionValue = stealthValue
		unitDataSet.detectionState = state
		unitDataSet.detectionToMeValue = stealthValue

		if stealthValue ~= 100 then
			gLuaTimeMgrUtils.Delay(function ()
				unitDataSet.detectionToMeValue = 0
			end, 0.7)
		end

		if shakeTimer ~= nil and stealthValue > 50 then
			slot5 = gSoundMgr

			slot5:PlaySoundByTid(LTConfig.GameConfig.ConsoleAlertnessvalueSound)

			shakeTimer = gLuaTimeMgrUtils.Delay(function ()
				shakeTimer = nil
			end, LTConfig.GameConfig.ConsoleAlertnessvalueCD)
		end

		if unitDataSet.stealthCfgId ~= nil or unitDataSet.stealthCfgId ~= 0 then
			return
		end

		if stealthValue <= 0 and gPanelManager:IsPanelShowing(gPanelId.S_OFF_SCREEN_HINT_PANEL) then
			gMessageManager:SendMessage(gEventConstants.ADD_OR_REMOVE_DETECT_TO_ME, {
				["D\\xbd\\x83\\xab\\xb2"] = true,
				unitPid = unit.Pid
			})
		end

		if stealthValue ~= 0 and gPanelManager:IsPanelShowing(gPanelId.S_OFF_SCREEN_HINT_PANEL) then
			gMessageManager:SendMessage(gEventConstants.ADD_OR_REMOVE_DETECT_TO_ME, {
				["D\\xbd\\x83\\xab\\xb2"] = false,
				unitPid = unit.Pid
			})
		end

		if gMapSubSystem_CommonUnit then
			gMapSubSystem_CommonUnit:OnDetectStateChange(guardPid, state)
		end
	end
end

GameSceneToClientImpl.SyncEnemyDetect = function(guardPid, stealthCfgId)
	local unit = gCS.SceneDataMgr.GetUnit(guardPid)

	if unit then
		local unitDataSet = gDataSetManager:GetUnitData(unit.Pid)

		if unitDataSet then
			unitDataSet.stealthCfgId = stealthCfgId
		end
	end

	gMapSubSystem_CommonUnit:OnSyncEnemyDetectInfo(guardPid, stealthCfgId)
end

GameSceneToClientImpl.SyncEnemyLevel = function(id, level)
	local unit = gCS.SceneDataMgr.GetUnit(id)

	if unit then
		unit.ClientData.Level = level
	end

	local unitData = gDataSetManager:GetUnitData(id)

	if unitData then
		unitData.level = level
	end
end

GameSceneToClientImpl.SyncShowWorldEnemyRewardMessage = function(enemyId)
end

GameSceneToClientImpl.SyncWorldBossStateChange = function(instanceId, enemySpoonId, state, campId, rebornTime)
end

GameSceneToClientImpl.SyncPlayerWeather = function(weatherTypeId, nextWeatherTypeId, transitionSecond)
	AtmosphereManager.Instance:SetWeather(weatherTypeId, transitionSecond)

	AtmosphereManager.Instance.NextWeatherConfigId = nextWeatherTypeId

	gMessageManager:SendMessage(gEventConstants.WEATHER_CHANGE)
end

GameSceneToClientImpl.SyncShowUnitStateConfliction = function(state, evt)
	if not gUnitStateManager:IsMessageForbidden(state, evt) then
		if state ~= UnitStateConfig.DeadS and evt ~= UnitStateAtlasConfig.TimeJump then
			return
		end

		local stateCfg = UnitStateConfig.GetConfig(state)

		if stateCfg then
			local evtCfg = UnitStateAtlasConfig.GetConfig(evt)

			if evtCfg then
				local statestr = stateCfg.UnitStateNote
				local evtstr = evtCfg.Name

				gDisplayMessageMgr:ShowMessage(MessageConfig.StateConflict, nil, , statestr, evtstr)
			end
		end
	end
end

GameSceneToClientImpl.SyncEntityActionGroup = function(pid, actionGroupId)
	gCS.LuaUtils.SetActionGroupId(pid, actionGroupId, false)
end

GameSceneToClientImpl.SyncWorldRewardTriggeredInfo = function(pids)
	local pid = nil

	for i = 1, pids.Count do
		pid = pids[i]
		gLuaDataManager.receivedRewardEnemies[tostring(pid)] = pid
	end
end

GameSceneToClientImpl.SyncActionDataOpen = function(open)
	gLuaDataManager.needSyncActionDatas = open
	gLuaDataManager.needSyncEffect = open
end

GameSceneToClientImpl.SyncGroupEnemyLockTarget = function(groupId, lockTarget)
	gTriggerEnemyMgr:EnemyGroupSwitchLockState(groupId, lockTarget)
end

GameSceneToClientImpl.SyncWildEnemyGroupCheckTime = function(list)
	gTriggerEnemyMgr:ResetActiveList(list)
	gMessageManager:SendMessage(gEventConstants.WILD_ENEMY_CAMP_STATE_CHANGE)
end

GameSceneToClientImpl.SyncActiveWildEnemyGroup = function(id, campId, first, ids)
	gTriggerEnemyMgr:AddActiveGroup(id, ids, first)
	gMessageManager:SendMessage(gEventConstants.WILD_ENEMY_CAMP_STATE_CHANGE, {
		["A_̲\\x96\\x8c\r\\xc4\\xed"] = 0,
		campId = campId,
		state = UX.Game.WorldBossState.Default
	})
end

GameSceneToClientImpl.SyncInactiveWildEnemyGroup = function(id, campId, last, rebornTime, banned)
	gTriggerEnemyMgr:RemoveActiveGroup(id, banned)
	gMessageManager:SendMessage(gEventConstants.WILD_ENEMY_CAMP_STATE_CHANGE, {
		campId = campId,
		state = UX.Game.WorldBossState.Dead,
		rebornTime = rebornTime
	})
end

GameSceneToClientImpl.SyncWildEnemyGroupLiberate = function(groupId)
	gTriggerEnemyMgr:ShowCampLiberatePopup(groupId)
end

GameSceneToClientImpl.SyncGeneralCutInPost = function(actionType, timelineType)
	if actionType ~= 2 then
		gCS.ClimbManager.CheckTimeLine(timelineType, 0, 0)
	end
end

GameSceneToClientImpl.SyncLuaSlotEntityMessage = function(signalName)
	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, signalName)
end

GameSceneToClientImpl.SyncPlayerCurrentSpirit = function(pid, templateId, spiritId, isAgentSwitch)
	gBattleSpiritMgr.SyncPlayerCurrentSpirit(pid, templateId, spiritId, isAgentSwitch)
	gCS.SwitchSpiritManager.SetCurrentSpiritId(pid, spiritId)
end

GameSceneToClientImpl.SyncUnitElement3 = function(battleUnitId, element, value)
end

GameSceneToClientImpl.SendCustomHotPatchGameSceneToClient = function(data)
end

GameSceneToClientImpl.SyncUnitAddBuff = function(pid, buffItem)
	gBuffUtils:SyncHUDAddBuffViewData(pid, buffItem)
end

GameSceneToClientImpl.SyncUnitRemoveBuff = function(pid, instanceId)
	gBuffUtils:SyncHUDRemoveBuffViewData(pid, instanceId)
end

GameSceneToClientImpl.SyncUnitUpdateBuff = function(pid, buffItem)
	gBuffUtils:SyncHUDUpdateBuffViewData(pid, buffItem)
end

GameSceneToClientImpl.SyncUnitBuffList = function(pid, buffList)
	gBuffUtils:SyncHUDListBuffViewData(pid, buffList)
end

GameSceneToClientImpl.SyncEnemyPlayAction = function(enemyId, actionId, time)
	local enemy = gCS.SceneDataMgr.GetUnit(enemyId)

	if enemy then
		if gCS.BattleManager.HasHitState(enemy) then
			return
		end

		local actionTime = gCS.AnimationManager.AnimatorGetAnimationTime(enemy, actionId, enemy.State.ActionGroupId)

		if time ~= nil or time ~= 0 then
			time = actionTime
		end

		gCS.AnimControllerManager.PlayAction(enemy, actionId, enemy.State.ActionGroupId, time, 0, -1, false, nil, 0)
		enemy:StopMove()
	end
end

GameSceneToClientImpl.SyncRaidTargets = function(targetCounter)
	gRaidDataManager:SetAllTarget(targetCounter)
end

GameSceneToClientImpl.SyncRaidTargetCounter = function(targetId, counter)
	gRaidDataManager:UpdateOneTarget(targetId, counter)
end

GameSceneToClientImpl.SyncGravityFieldOn = function(id, templateId, position, angle, duration, level)
	local config = LTConfig.GravityConfig.GetConfig(templateId)

	if config then
		gCS.ForceFieldMgr.Instance:CreateForceField(id, config.Key, Vector3.New(position.X, position.Y, position.Z), angle, duration, level)
	end
end

GameSceneToClientImpl.SyncSpiritUnitUrbanAttrs = function(id, urbanAttrs)
	local cs_unit = gCS.SceneDataMgr.GetUnit(id)

	if not cs_unit then
		return
	end

	local cardId = cs_unit.ClientData.cardId

	gSpiritManager:SyncSpiritUrbanAttrs(cardId, urbanAttrs)
end

GameSceneToClientImpl.SyncPoliceDispatchHelicopter = function(pos, npcId)
end

GameSceneToClientImpl.SynExitHelicopterView = function()
	gPanelManager:Close(gPanelId.S_POLICE_HELICOPTER)
end

GameSceneToClientImpl.SyncCleaningInfo = function(start, info)
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

GameSceneToClientImpl.SyncGlueStartChange = function(start)
	if not start then
		L50.L50App.Scene.WashMgr.Progress = 0
		L50.L50App.Scene.WashMgr.serverIsStart = false
	else
		L50.L50App.Scene.WashMgr.serverIsStart = true
	end

	gWasherManager:SetCurrentCleaningInfo(start)
end

GameSceneToClientImpl.StartProgressTemplateCall = function(templateCallId, visibility)
	gNewGamePlayProgressMgr:StartProgressTemplate(templateCallId, visibility)
end

GameSceneToClientImpl.StopProgressTemplateCall = function(templateCallId)
	gNewGamePlayProgressMgr:StopProgressTemplate(templateCallId)
end

GameSceneToClientImpl.StartProgress = function(progressId, startTime, startLength, totalLength, speed, visible, visiblePidCnt)
	gNewGamePlayProgressMgr:ChangeProgressState(progressId, startTime, startLength, totalLength, speed, visible)
end

GameSceneToClientImpl.StopProgress = function(progressId)
	gNewGamePlayProgressMgr:StopProgress(progressId)
end

GameSceneToClientImpl.StopAllProgressTemplateCall = function()
	gNewGamePlayProgressMgr:StopAllProgressTemplate()
end

GameSceneToClientImpl.ChangeProgressVisible = function(progressId, visible, visiblePidCnt)
	gNewGamePlayProgressMgr:ChangeProgressVisible(progressId, visible)
end

GameSceneToClientImpl.StopAllProgress = function()
	gNewGamePlayProgressMgr:StopAllProgress()
end

GameSceneToClientImpl.SyncFightSpiritStartDie = function(id)
	local unit = gCS.SceneDataMgr.GetUnit(id)

	if not unit then
		return
	end
end

GameSceneToClientImpl.SyncSelectTempBuff = function(buffIds)
	gRoguelikeManager:OnSelectTempItem(gRoguelikeManager.SELECT_TYPE.BUFF, buffIds)
end

GameSceneToClientImpl.SyncSelectTempWeapon = function(weaponIds)
	gRoguelikeManager:OnSelectTempItem(gRoguelikeManager.SELECT_TYPE.WEAPON, weaponIds)
end

GameSceneToClientImpl.SyncRogueSettle = function(reward, weaponIds, score, rogueId)
	gRoguelikeManager:OnSyncRogueSettle(reward, weaponIds, score, rogueId)
end

GameSceneToClientImpl.SyncStopShowAction = function()
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(true, LX6.PaoKu.TransitionMgr.ShowActionBanReason.ServerBan)
end

GameSceneToClientImpl.SyncRecoverShowAction = function()
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(false, LX6.PaoKu.TransitionMgr.ShowActionBanReason.ServerBan)
end

GameSceneToClientImpl.SyncRaidGamePlayInfo = function(info)
	gGameplayRecordValueManager:OnChangeRaidGamePlayInfo(info.RecordValueInfo)
end

GameSceneToClientImpl.SyncRaidGamePlayRecordDoubleValue = function(recordId, paramId, value, recordValue)
	gGameplayRecordValueManager:OnChangeRecordDoubleValue(recordId, paramId, value, recordValue)
end

GameSceneToClientImpl.SyncRaidGamePlayRecordRemove = function(recordId, paramId)
	gGameplayRecordValueManager:OnRemoveRecordValue(recordId, paramId)
end

GameSceneToClientImpl.SyncEnemyMovingLuaSlotId = function(unitId, luaSlotId, bindRefName, isInit)
	local entity = gGadgetManager:GetEntitySearchByInstanceId(luaSlotId)

	local check = function(entityGo, unitId)
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
			if v.name ~= slotName then
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

GameSceneToClientImpl.SyncGamePause = function(v)
	gLuaUIMgr.GamePause = v

	gCS.PauseManager.Instance:SyncBreakStateFromServer(v)

	if gLuaUIMgr.uidLayerPanelStore then
		gLuaUIMgr.uidLayerPanelStore:ShowPauseInfo(v)
	end
end

GameSceneToClientImpl.SyncMultiplayerStatus = function(isMultiplayer)
	gPauseManager.isMultiplayer = isMultiplayer
end

GameSceneToClientImpl.SyncAreaTargetCounter = function(targetId, counter)
	gSeasonDataMgr:UpdateAreaTargetCounterDatas({
		[targetId] = counter
	})
end

GameSceneToClientImpl.SyncSceneItemValueChange = function(type, id, name, value)
	if type ~= UX.Game.SceneItemEntityType.Gadget then
		gGadgetManager:ChangeGadgetValue(id, name, value)
	elseif type ~= UX.Game.SceneItemEntityType.Destructible then
		-- Nothing
	end
end

GameSceneToClientImpl.SyncSceneItemSignalSend = function(type, id, signalName)
	if type ~= UX.Game.SceneItemEntityType.Gadget then
		-- Nothing
	elseif type ~= UX.Game.SceneItemEntityType.Destructible then
		-- Nothing
	end
end

GameSceneToClientImpl.SyncInteractBindPerformance = function(id, gadgetId, bindId, interactActionType, index, dynamicBindItem, startTime, delayTime)
end

GameSceneToClientImpl.SyncCaptureEnemy = function(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	gInteractionManager:UnitStartStorge(unit)
end

GameSceneToClientImpl.SyncSceneItemOccupantChange = function(type, id, pid, index, add)
	if type ~= UX.Game.SceneItemEntityType.Gadget then
		gGadgetManager:ModifySceneInterestPoint(id, add, index, pid)
	elseif type ~= UX.Game.SceneItemEntityType.Destructible then
		-- Nothing
	end
end

GameSceneToClientImpl.SyncScenePlayerName = function(uid, name)
	gBattleNetcodeUtils:SetUserName(uid, name, false)
end

GameSceneToClientImpl.SyncLinkMemberSceneInfoChange = function(pid, agentId, name, position, facing, raidId)
	gLinkManager:OnMemberPosInfoChange(pid, agentId, name, position, facing, raidId)
end

GameSceneToClientImpl.SyncLinkMemberVehicleInfoChange = function(pid, vehicleEntityId, vehicleTemplateId, seatIndex)
	gLinkManager:OnMemberVehicleInfoChange(pid, vehicleEntityId, vehicleTemplateId, seatIndex)
end

GameSceneToClientImpl.SyncLinkMemberInfo = function(member)
	gLinkManager:InitLinkMember(member)
end

GameSceneToClientImpl.SyncMatchGameMemberDetach = function(pid)
	slot1 = gLinkManager

	slot1:WaitMemberInfo(pid, function (data)
		gLinkManager:OnChanegeMemberDetach(pid)
	end)
end

GameSceneToClientImpl.SyncMatchGameMemberOffline = function(pid)
	gLinkManager:OnLinkMemberChange(UX.Game.LinkMode.None, {
		Pid = pid
	}, false)
end

GameSceneToClientImpl.SyncMatchGameSettleData = function(data, success)
	gLinkManager:OnSyncOnlineChallengeData(data)
end

GameSceneToClientImpl.SyncMatchGameMembersAllLoaded = function(gameStartTime)
	gLinkManager.gameStartTime = gameStartTime
end

GameSceneToClientImpl.SyncRacingResultData = function(racingResultDatas)
	if L50.Spoon.UgcRaceManager.ExitUgcTrial() then
		return
	end

	gChallengeManager:OnSyncRacingResultData(racingResultDatas)
end

GameSceneToClientImpl.SyncRacingGameFail = function()
	gChallengeManager:OnSyncRacingGameFail()
end

GameSceneToClientImpl.SyncOutOfJam = function()
	gCsToLuaHandler:ClearPaoku()
	gCS.MindPowerMgr:LeaveMagnet()
end

GameSceneToClientImpl.SyncEnemyFightEdict = function(pid, isGive)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	unit.ClientData.HaveAttackToken = isGive
end

GameSceneToClientImpl.SyncEnemyPoiseRate = function(id, ratio)
	local unit = gCS.SceneDataMgr.GetUnit(id)

	if unit ~= nil then
		return
	end

	unit.ClientData.DisarmRate = ratio

	gHudMgr:DisarmChanged(id)
	gBossViewManager:DisarmChanged(id)
end

GameSceneToClientImpl.SyncEnemyDisarmState = function(id, isDisarmed)
end

GameSceneToClientImpl.SyncEnemyPoiseWeaponChangeInfo = function(id, values)
	gBattleMgr:SetEnemyPoiseWeaponChangeInfo(id, values)
end

GameSceneToClientImpl.SyncSpiritWeaponDetail = function(spiritWeaponDetail)
	gWeaponManager:SyncSpiritWeaponSlot(spiritWeaponDetail.SpiritTid, spiritWeaponDetail.WeaponSlots)

	if spiritWeaponDetail.SpiritUid ~= gBattleSpiritMgr.currentSpiritPid then
		gWeaponManager:SyncCurrWeaponSlots(spiritWeaponDetail.WeaponSlots)
		gWeaponManager:SyncCurrTempWeaponSlots(spiritWeaponDetail.TempWeaponSlots)
		gWeaponManager:SyncTempExtraWeapon(spiritWeaponDetail.CurrentTempWeapon)
		gWeaponManager:SyncVirtualWeaponSlots(spiritWeaponDetail.VirtualWeaponSlots)
		gWeaponManager:OnSwitchCurrentWeapon(spiritWeaponDetail.CurrentWeaponUid)
	end
end

GameSceneToClientImpl.SyncSpiritAddWeaponAction = function(spiritAddWeaponAction)
	if spiritAddWeaponAction.SlotIndex ~= -1 then
		gWeaponManager:SyncTempExtraWeapon(spiritAddWeaponAction.Weapon)

		return
	end

	if SceneitemVirtualWeaponSlotConfig.GetConfig(spiritAddWeaponAction.SlotIndex) then
		gWeaponManager:SyncVirtualWeaponSlotsAdd(spiritAddWeaponAction.SlotIndex, spiritAddWeaponAction.Weapon)

		return
	end

	if spiritAddWeaponAction.SpiritUid ~= gBattleSpiritMgr.currentSpiritPid then
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

GameSceneToClientImpl.SyncSpiritRemoveWeaponAction = function(spiritRemoveWeaponAction)
	if spiritRemoveWeaponAction.SpiritUid ~= gBattleSpiritMgr.currentSpiritPid then
		if gWeaponManager.TempWeaponMode then
			gWeaponManager:SyncCurrTempWeaponSlotsRemove(spiritRemoveWeaponAction.WeaponUid, spiritRemoveWeaponAction.Reason)
		else
			gWeaponManager:SyncCurrWeaponSlotsRemove(spiritRemoveWeaponAction.WeaponUid, spiritRemoveWeaponAction.Reason)
		end

		gWeaponManager:TryRemoveTempExtraWeapon(spiritRemoveWeaponAction.WeaponUid)
		gWeaponManager:TryRemoveVirtualWeaponSlots(spiritRemoveWeaponAction.WeaponUid)
	end

	if not gWeaponManager.TempWeaponMode then
		gWeaponManager:SyncSpiritWeaponSlotsRemove(spiritRemoveWeaponAction.SpiritTid, spiritRemoveWeaponAction.WeaponUid, spiritRemoveWeaponAction.Reason)
	end
end

GameSceneToClientImpl.SyncSpiritUpdateWeaponAction = function(spiritUpdateWeaponAction)
	gWeaponManager:SyncSpiritUpdateWeapon(spiritUpdateWeaponAction.Weapon.InstanceId, spiritUpdateWeaponAction.Weapon, spiritUpdateWeaponAction.SpiritTid)
end

GameSceneToClientImpl.SyncSpiritSwitchWeaponAction = function(spiritSwitchWeaponDetail)
	local unit = gCS.SceneDataMgr.GetUnit(spiritSwitchWeaponDetail.SpiritUid)

	if unit ~= nil then
		return
	end

	if not unit.IsMe then
		return
	end

	gWeaponManager:OnSwitchCurrentWeapon(spiritSwitchWeaponDetail.WeaponInstanceId)
end

GameSceneToClientImpl.SyncSpiritWeaponDurabilityChangedAction = function(spiritWeaponDurabilityChangedAction)
	gWeaponManager:SyncWeaponDurabilityChange(spiritWeaponDurabilityChangedAction.WeaponInstanceId, spiritWeaponDurabilityChangedAction.Durability, spiritWeaponDurabilityChangedAction.MagazineAmmo, spiritWeaponDurabilityChangedAction.CurrentBulletId)
end

local GameGroundZoneType = UX.Game.GameGroundZoneType

GameSceneToClientImpl.SyncStartScratchGameZone = function(gadgetUid, scratchSubType, result)
	gScratchGameManager:Show(gadgetUid, scratchSubType, result)
end

GameSceneToClientImpl.SyncGameGroundZoneInfo = function(zoneInfo)
	if zoneInfo ~= nil then
		gDartsGameManager:DestroyGame()
		gBBQGameManager:StopBBQGame()
		gRingTossNetMgr:OnZoneDestroyed()

		return
	end

	if zoneInfo.ZoneType ~= GameGroundZoneType.Dart then
		gDartsGameManager:OnSyncZoneInfo(zoneInfo.GadgetUId, zoneInfo, true)
	elseif zoneInfo.ZoneType ~= GameGroundZoneType.Bowling then
		gBowlingGameManager:OnSyncGameGroundZoneInfo(zoneInfo)
	elseif zoneInfo.ZoneType ~= GameGroundZoneType.Racing then
		gChallengeManager:OnSyncRacingZoneInfo(zoneInfo)
	elseif zoneInfo.ZoneType ~= GameGroundZoneType.BBQ then
		gBBQGameManager:OnSyncZoneInfo(zoneInfo.GadgetUId, zoneInfo, true)
	elseif zoneInfo.ZoneType ~= GameGroundZoneType.ChineseChess then
		gChineseChessMgr:OnSyncGameGroundZoneInfo(zoneInfo)
	elseif zoneInfo.ZoneType ~= GameGroundZoneType.RingToss then
		gRingTossNetMgr:OnSyncGameGroundZoneInfo(zoneInfo)
	elseif zoneInfo.ZoneType ~= GameGroundZoneType.Scratch then
		gScratchGameManager:OnSyncGameGroundZoneInfo(zoneInfo)
	end
end

GameSceneToClientImpl.SyncGameGroundZonePlayerInfo = function(zoneIdentifier, participantInfo, add, remove)
	if zoneIdentifier.ZoneType ~= GameGroundZoneType.BBQ then
		gBBQGameManager:OnServerEnterRoom(zoneIdentifier.GadgetUId, participantInfo, add, remove)
	end

	if participantInfo.Pid == gPlayerManager.infoLogin.bindData.pid then
		if zoneIdentifier.ZoneType ~= GameGroundZoneType.Dart then
			gDartsGameManager:OnServerEnterRoom(zoneIdentifier.GadgetUId, participantInfo)
		elseif zoneIdentifier.ZoneType ~= GameGroundZoneType.Bowling then
			gBowlingGameManager:OnSyncGameGroundZonePlayerInfo(zoneIdentifier.GadgetUId, participantInfo, add)
		elseif zoneIdentifier.ZoneType ~= GameGroundZoneType.ChineseChess then
			gChineseChessMgr:OnSyncGameGroundZonePlayerInfo(participantInfo, add)
		end
	end

	if participantInfo.IsPlayAgain then
		local pid = participantInfo.Pid

		if participantInfo.AIAgentInfo then
			pid = participantInfo.AIAgentInfo.Uid
		end

		local memberList = gLinkManager:GetEndMemberList()

		if not table.isNilOrEmpty(memberList) then
			for _, memberPid in ipairs(memberList) do
				if memberPid ~= pid then
					gLinkManager:OnPlayGameAgain(pid)

					break
				end
			end
		end
	end
end

GameSceneToClientImpl.SyncGameGroundZoneState = function(zoneIdentifier, state, countDownInfo)
	if state ~= UX.Game.GameGroundZoneState.GameStart then
		gLinkManager.tryAgainDict = {}

		gLinkManager:ExitFinalRankPanel()
	end

	if zoneIdentifier.ZoneType ~= GameGroundZoneType.Dart then
		gDartsGameManager:OnGameStateChange(zoneIdentifier.GadgetUId, state)
	elseif zoneIdentifier.ZoneType ~= GameGroundZoneType.Bowling then
		gBowlingGameManager:OnSyncGameGroundZoneState(zoneIdentifier.GadgetUId, state)
	elseif zoneIdentifier.ZoneType ~= GameGroundZoneType.BBQ then
		gBBQGameManager:OnGameStateChange(zoneIdentifier.GadgetUId, state, countDownInfo)
	end
end

GameSceneToClientImpl.SyncGameGroundZoneTurnChange = function(zoneIdentifier, currentRound, currentTurn)
	if zoneIdentifier.ZoneType ~= GameGroundZoneType.Bowling then
		gBowlingGameManager:OnSyncGameGroundZoneTurnChange(zoneIdentifier.GadgetUId, currentRound, currentTurn)
	elseif zoneIdentifier.ZoneType ~= GameGroundZoneType.Dart then
		gDartsGameManager:OnSyncZoneTurnChange(zoneIdentifier.GadgetUId, currentRound, currentTurn)
	elseif zoneIdentifier.ZoneType ~= GameGroundZoneType.ChineseChess then
		gChineseChessMgr:OnSyncZoneTurnChange(currentRound, currentTurn)
	elseif zoneIdentifier.ZoneType ~= GameGroundZoneType.RingToss then
		gRingTossNetMgr:OnSyncZoneTurnChange(currentRound, currentTurn)
	end
end

GameSceneToClientImpl.SyncDartScoreInfo = function(uId, scoreInfo)
	gDartsGameManager:OnSyncDartScoreInfo(uId, scoreInfo)
end

GameSceneToClientImpl.SyncBBQMeatCreated = function(gadgetUId, meatInfo, creatorSeatIndex)
	gBBQGameManager:OnSyncBBQMeatCreated(gadgetUId, meatInfo, creatorSeatIndex)
end

GameSceneToClientImpl.SyncBBQMeatPlacedOnGrill = function(gadgetUId, meatId, grillPosition)
	gBBQGameManager:OnSyncBBQMeatPlacedOnGrill(gadgetUId, meatId, grillPosition)
end

GameSceneToClientImpl.SyncBBQMeatPickedFromGrill = function(gadgetUId, meatId, pickerSeatIndex, updatedInfo)
	gBBQGameManager:OnSyncBBQMeatPickedFromGrill(gadgetUId, meatId, pickerSeatIndex, updatedInfo)
end

GameSceneToClientImpl.SyncBBQMeatFlipped = function(gadgetUId, meatId, flipperSeatIndex, updatedInfo)
	gBBQGameManager:OnSyncBBQMeatFlipped(gadgetUId, meatId, flipperSeatIndex, updatedInfo)
end

GameSceneToClientImpl.SyncBBQMeatScored = function(gadgetUId, meatId, targetSeatIndex, result)
	gBBQGameManager:OnSyncBBQMeatScored(gadgetUId, meatId, targetSeatIndex, result)
end

GameSceneToClientImpl.SyncBBQMeatDropped = function(gadgetUId, meatId)
	gBBQGameManager:OnSyncBBQMeatDropped(gadgetUId, meatId)
end

GameSceneToClientImpl.SyncBBQChopstickState = function(gadgetUId, seatIndex, state)
	gBBQGameManager:OnSyncBBQChopstickState(gadgetUId, seatIndex, state)
end

GameSceneToClientImpl.SyncBBQGameEnd = function(gadgetUId, endInfo)
	gBBQGameManager:OnSyncBBQGameEnd(gadgetUId, endInfo)
end

GameSceneToClientImpl.SyncBowlingScoreInfo = function(uId, scoreInfo)
	gBowlingGameManager:OnSyncBowlingScoreInfo(uId, scoreInfo)
end

GameSceneToClientImpl.SyncBowlingClientInfo = function(info)
	gBowlingGameManager:OnSyncBowlingClientInfo(info)
end

GameSceneToClientImpl.SyncBowlingRoomTrigger = function(enter, roomSyncInfos)
	gBowlingGameManager:OnSyncBowlingRoomTrigger(enter, roomSyncInfos)
end

GameSceneToClientImpl.SyncBowlingHosting = function(targetSeatIndex, targetPid)
	gBowlingGameManager:OnSyncBowlingHosting(targetSeatIndex, targetPid)
end

GameSceneToClientImpl.SyncBowlingHosted = function()
	gBowlingGameManager:OnSyncBowlingHosted()
end

GameSceneToClientImpl.SyncPlayerCrimeLevel = function(crimeValue)
	if gMapSubSystem_Crime then
		gMapSubSystem_Crime:SyncPlayerCrimeLevel(crimeValue)
	end
end

GameSceneToClientImpl.SyncPoliceBeginArrest = function(agentId, targetPid, ArrestType)
	if targetPid == gPlayerManager.infoLogin.bindData.pid then
		return
	end

	if ArrestType ~= 0 then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PlayerUnderArrest, MuGenStates.Logic.GameplayEventParam1.BeingArrest1)
	elseif ArrestType ~= 1 then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PlayerUnderArrestInCar)
	end

	gPanelManager:CheckShow(gPanelId.S_PLAYER_RARRESTED_PANEL)
end

GameSceneToClientImpl.SyncPoliceEscape = function(value)
	if gMapSubSystem_Crime then
		gMapSubSystem_Crime:SyncPoliceEscape(value)
	end
end

GameSceneToClientImpl.SyncPoliceEscapeSuccess = function()
	if gMapSubSystem_Crime then
		gMapSubSystem_Crime:SyncPoliceEscapeSuccess()
	end
end

GameSceneToClientImpl.SyncMatchGameLeftFailureDieCount = function(leftFailureDieCount)
	gLinkManager:OnMatchGameLeftFailureCountUpdate(leftFailureDieCount)
end

GameSceneToClientImpl.SyncSandevistanStart = function(speed)
	if gCS.DriveManager.CurrentPlayerBaseVehicle then
		gCS.DriveManager.CurrentPlayerBaseVehicle:SetEnableCopyMesh(true)
	end

	gCS.BattleManager.CostFightResource(gCS.MyPlayerManager.PlayerUnit, LTConfig.SkillResourcesConfig.DriveTimeScaleEnergy, 1, false)
	gPauseManager:StartGamePlayPause_CustomData_ChangeOthersTimeSpeed(speed)
end

GameSceneToClientImpl.SyncSandevistanEnd = function()
	if gCS.DriveManager.CurrentPlayerBaseVehicle then
		gCS.DriveManager.CurrentPlayerBaseVehicle:SetEnableCopyMesh(false)
	end

	gPauseManager:EndGamePlayPause_CustomData_ChangeOthersTimeSpeed()
end

GameSceneToClientImpl.SyncAgentPoliceExamData = function(agentId, data)
	gPoliceJobManager:OnSyncAgentPoliceExamData(agentId, data)
end

GameSceneToClientImpl.SyncPlayerArrestStateNotify = function(id)
	gPoliceJobManager:OnSyncPlayerArrestStateNotify(id)
end

GameSceneToClientImpl.SyncTaxiReachDestination = function(vehicleId)
	TaxiManager:OnTaxiReachDestination(vehicleId)
end

GameSceneToClientImpl.SyncMahjongReadyStart = function(gadgetUid, duty)
	gMaJiangManager:OnSyncMahjongReadyStart(gadgetUid, duty)
end

GameSceneToClientImpl.SyncMahjongTimeOut = function(gadgetUId)
	gMaJiangManager:OnSyncMahjongTimeOut(gadgetUId)
end

GameSceneToClientImpl.SyncMahjongWorldBattleRoomInfo = function(info)
	gMaJiangManager:OnSyncMahjongWorldBattleRoomInfo(info)
end

GameSceneToClientImpl.SyncMatchGamePlayAgain = function(pid, playAgain)
	if playAgain then
		gLinkManager:OnPlayGameAgain(pid)
	end
end

GameSceneToClientImpl.SyncPlayerLoadRate = function(pid, rate)
	gLinkManager:OnSyncLoadingState(pid, rate)
end

GameSceneToClientImpl.SyncPlayerCurrentOxygenValue = function(oxygenValue)
	gMessageManager:SendMessage(gEventConstants.ON_OXYGEN_UPDATE, oxygenValue)
end

GameSceneToClientImpl.SyncPlayerOxygenSystemState = function(isOpen)
	gMessageManager:SendMessage(gEventConstants.ON_OXYGEN_OPEN, isOpen)
end

GameSceneToClientImpl.SyncPlayerOutOfStuck = function(outOfStuckTeleportType)
	gMessageManager:SendMessage(gEventConstants.SETTING_OUT_OF_STUCK)
end

GameSceneToClientImpl.SyncToggleUnitMiniMapHostileIcon = function(id, flag)
	if gMapSubSystem_CommonUnit then
		gMapSubSystem_CommonUnit:SetServerHostileUnit(id, flag)
	end
end

GameSceneToClientImpl.SyncConvertTaskNpcToPed = function(pid, pedInitData)
	gAgentTrustManager:OnNpcConvertToPed(pid)
end

GameSceneToClientImpl.SyncExtractionShooterContainerInfo = function(containerInstanceId, extractionShooterContainerInfo)
	gExtractionShooterManager:SyncExtractionShooterContainerInfo(containerInstanceId, extractionShooterContainerInfo)
end

GameSceneToClientImpl.SyncSetScreenBlackForSpoon = function(duration)
	gBlackScreenManager:AutoTransition(gBlackScreenId.SPOON_SET_SCREEN_BLACK, "", false, false, 0, duration, 0)
end

GameSceneToClientImpl.SyncExtractionGpsInfo = function(highItemGpsInfos, middleItemGpdInfos)
	print_debug("SyncExtractionGpsInfo")
	gMapSubSystem_ExtractionContainer:SyncExtractionGpsInfo(highItemGpsInfos, middleItemGpdInfos)
end

GameSceneToClientImpl.SyncAgentWeaponWheel = function(agentId, currentWeaponId, weaponSlots)
	gAgentWeaponManager:SyncAgentWeaponWheel(agentId, currentWeaponId, weaponSlots)
end

GameSceneToClientImpl.SyncAgentChangeWeapon = function(agentId, weaponId)
	gAgentWeaponManager:SyncAgentChangeWeapon(agentId, weaponId)
end

GameSceneToClientImpl.SyncRemoveRaidEntity = function(id, entityType)
	gAgentWeaponManager:SyncRemoveAgent(id)
end

GameSceneToClientImpl.SyncExtractionMark = function(pid, mark)
end

GameSceneToClientImpl.SyncExtractionMarks = function(marks)
end

GameSceneToClientImpl.SyncShortChat = function(chat)
	gMapSubSystem_ChatMark:OnSyncShortChat(chat)
end

GameSceneToClientImpl.SyncCancelMark = function(pid)
	gMapSubSystem_ChatMark:SyncCancelMark(pid)
end

GameSceneToClientImpl.SyncShortChats = function(chats)
	gMapSubSystem_ChatMark:OnSyncShortChats(chats)
end

GameSceneToClientImpl.SyncChatWheelItems = function(items, multiType)
	print_debug("@xq SyncChatWheelItems")
	gLinkManager:SyncChatWheelItems(items, multiType)
end

GameSceneToClientImpl.SyncVehicleAutonomousDrivingState = function(vehicleEntityId, isStart)
	gDriveVehiclesManager:SyncVehicleAutonomousDrivingState(vehicleEntityId, isStart)
end

GameSceneToClientImpl.SyncPlayerAutonomousDrivingState = function(isInOverrideMode, isAutoDrivingBlocked, isImmersiveModeBlocked)
	gDriveVehiclesManager:SyncPlayerAutonomousDrivingState(isInOverrideMode, isAutoDrivingBlocked, isImmersiveModeBlocked)
	gMessageManager:SendMessage(gEventConstants.PLAYER_AUTO_DRIVE_STATE_CHANGE)
end

GameSceneToClientImpl.SyncBlockedVehicleSummonSlots = function(blockedSlots)
	gDriveVehiclesManager:SyncBlockedVehicleSummonSlots(blockedSlots)
end

GameSceneToClientImpl.SyncDeathPartyPlayerNum = function(aliveCount, totalCount, taskId)
	gLinkManager.ingameAliveCount = aliveCount
	gLinkManager.ingameTotalCount = totalCount
	gLinkManager.taskId = taskId

	if aliveCount ~= 0 and totalCount ~= 0 then
		gPanelManager:Close(gPanelId.ONLINE_INGAME_MISSION_PANEL)

		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.COMPUTER_MAIN_PANEL) then
		gMessageManager:SendMessage(gEventConstants.LINK_HUD_INFO_CHANGE)
	else
		gPanelManager:CheckShow(gPanelId.ONLINE_INGAME_MISSION_PANEL)
	end
end

GameSceneToClientImpl.SyncShieldOn = function(id, templateId, shieldValue, maxShieldValue)
	if id ~= gCS.MyPlayerManager.PlayerUnit.Pid then
		gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.SHIELD_CHANGE, true, templateId, shieldValue, maxShieldValue)
	end
end

GameSceneToClientImpl.SyncShieldOff = function(id, index)
	if id ~= gCS.MyPlayerManager.PlayerUnit.Pid then
		gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.SHIELD_CHANGE, false, index)
	end
end

GameSceneToClientImpl.SyncShieldValue = function(id, index, value, maxValue)
	if id ~= gCS.MyPlayerManager.PlayerUnit.Pid then
		gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.SHIELD_VALUE_CHANGE, index, value, maxValue)
	end
end

GameSceneToClientImpl.SyncPartyMiniGameMatchRoomMatchStart = function(room)
	gLinkManager:OnPartyMiniGameMatchRoomMatchStart(room)
end

GameSceneToClientImpl.SyncPartyMiniGameMatchRoomMemberChange = function(room, memberPid)
	gLinkManager:OnPartyMiniGameMatchRoomMemberChange(room, memberPid)
end

GameSceneToClientImpl.SyncPartyMiniGameMatchRoomMatchCancel = function(room)
	gLinkManager:EndOfSearching()
	gLinkManager:OnMemberRejectConfirm()
end

GameSceneToClientImpl.SyncPartyMiniGameMatchRoomReady = function(prepareRoom)
	gLinkManager:OnPartyMiniGameMatchRoomReady(prepareRoom)
end

GameSceneToClientImpl.SyncPartyMiniGameMatchGameStart = function(prepareRoom, gameStartTime)
	gLinkManager:OnPartyMiniGameMatchGameStart(prepareRoom, gameStartTime)
end

GameSceneToClientImpl.SyncPartyMiniGameMatchRoomDismissed = function()
	gLinkManager:OnSyncMatchRoomDismissed()
end

GameSceneToClientImpl.SyncPartyMiniGameMatchRoomConfirmed = function(roomId, pid)
	gLinkManager:OnPartyMiniGameMatchRoomConfirmed(roomId, pid)
end

GameSceneToClientImpl.SyncVehicleChaseStart = function(groupId, configId)
	gVehicleGamePlayManager:OnSyncVehicleChaseStart(groupId, configId)
end

GameSceneToClientImpl.SyncVehicleChaseEnd = function(groupId, result)
	gVehicleGamePlayManager:OnSyncVehicleChaseEnd(groupId, result)
end

GameSceneToClientImpl.SyncVehicleChaseMode = function(groupId, vehicleUId, mode)
	gVehicleGamePlayManager:OnSyncVehicleChaseMode(groupId, vehicleUId, mode)
end

GameSceneToClientImpl.SyncChineseChessMove = function(uId, move)
	gMessageManager:SendMessage(gEventConstants.ON_CHINESE_CHESS_MOVE, move)
end

GameSceneToClientImpl.SyncChineseChessUndo = function(uId, undoStepCount, newMoveIndex)
	gMessageManager:SendMessage(gEventConstants.ON_CHINESE_CHESS_UNDO, {
		undoStepCount = undoStepCount,
		newMoveIndex = newMoveIndex
	})
end

GameSceneToClientImpl.SyncChineseChessGameOver = function(uId, winner, reason)
	gMessageManager:SendMessage(gEventConstants.ON_CHINESE_CHESS_GAME_OVER, {
		winner = winner,
		reason = reason
	})
end

GameSceneToClientImpl.SyncChineseChessScoreInfo = function(uId, scoreInfo)
	gMessageManager:SendMessage(gEventConstants.ON_CHINESE_CHESS_SCORE_INFO, scoreInfo)
end

GameSceneToClientImpl.SyncChineseChessFlipMove = function(uId, move)
	gMessageManager:SendMessage(gEventConstants.ON_CHINESE_CHESS_FLIP_MOVE, move)
end

GameSceneToClientImpl.SyncChineseChessFlipScoreInfo = function(uId, scoreInfo)
	gMessageManager:SendMessage(gEventConstants.ON_CHINESE_CHESS_FLIP_SCORE_INFO, scoreInfo)
end

GameSceneToClientImpl.SyncCarShopParking = function(info)
	gApplyCarManager:OnSyncCarShopParking(info)
end

return GameSceneToClientImpl
