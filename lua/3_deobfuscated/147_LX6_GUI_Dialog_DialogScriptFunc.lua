local MessageConfig = LTConfig.MessageConfig
local ClawMachineConfig = LTConfig.ClawMachineConfig
local NPCChatGamePlayTypeConfig = LTConfig.NPCChatGamePlayTypeConfig
local M = {
	currentDialogId = 0,
	currentTaskId = 0,
	Data = nil,
	isNextAction = false,
	isClick = false,
	Vector3 = Vector3,
	gPanelId = gPanelId
}

function M.FeiSuoAction()
	if M.Data then
		if M.Data.id and M.Data.id > 0 then
			local unit = gCS.NpcMgr:GetNpcByTemplateId(M.Data.id)

			if unit then
				if unit.ModelSlot and unit.ModelSlot.feisuoPoint then
					M.taskFeisuoMover = unit.ModelSlot.feisuoPoint.gameObject

					gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnit.Pid, unit.LocalPosition, unit.ModelSlot.feisuoPoint, gLuaFightConstants.FeisuoType_Task, M.Data.banMove, M.Data.isPoint)
				else
					print_error("任务飞索指定的单位的feisuoPoint骨骼找不到", M.Data.id, unit.ModelSlot)
				end
			else
				print_error("任务飞索指定的单位找不到", M.Data.id)
			end
		elseif M.Data.vehicleId and M.Data.vehicleId > 0 then
			local vehicleUnit = gDriveVehiclesManager:GetVehicleInScene(M.Data.vehicleId)

			if vehicleUnit and vehicleUnit.feisuoPoint then
				M.taskFeisuoMover = vehicleUnit.feisuoPoint.gameObject

				gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnit.Pid, vehicleUnit.feisuoPoint.position, vehicleUnit.feisuoPoint, gLuaFightConstants.FeisuoType_Task, M.Data.banMove, M.Data.isPoint)
			end
		elseif M.Data.GadgetUniqueId and not ulong.equals(M.Data.GadgetUniqueId, 0) and M.Data.slotBindName then
			local entity = gGadgetManager:GetEntitySearchByInstanceId(M.Data.GadgetUniqueId)
			local go = nil
			local slotName = M.Data.slotBindName
			local targetPos = nil

			if entity.GetGameObjectById then
				local gameObjectMap = entity:GetGameObjectMap():ToTable()

				for i, v in pairs(gameObjectMap) do
					if v.name == slotName then
						go = v

						break
					end
				end
			elseif entity and entity.gameObjectRoot[slotName] and entity.gameObjectRoot[slotName][0] then
				targetPos = entity.gameObjectRoot[slotName][0]
			end

			local moverGo = nil
			local moverBindId = M.Data.moverBindId

			if moverBindId and moverBindId ~= 0 then
				moverGo = entity:GetGameObjectById(moverBindId)
			end

			if moverGo then
				M.taskFeisuoMover = moverGo
			end

			if go then
				gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnit.Pid, go.transform.position, go.transform, gLuaFightConstants.FeisuoType_Task, M.Data.banMove)
			elseif targetPos then
				gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnit.Pid, targetPos, nil, gLuaFightConstants.FeisuoType_Task, M.Data.banMove)
			end
		elseif M.Data.pos then
			gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnit.Pid, M.Data.pos, nil, gLuaFightConstants.FeisuoType_Task, M.Data.banMove)
		end
	end
end

function M.AbsorbAndSpitOutDestructible(radius, maxCount, absorbSpeed, absorbActionGroup, absorbActionType, attachBoneName, spitDelay, spitSpeed, spitActionGroup, spitActionType, finishDelay, startAbsorbDelay, mergeObjShowDelay, spitBindBoneName, spitOriScaleRatio, spitScaleChangeDur)
	local pid = M.currentNpc.Pid

	gCS.BaseUnitUtils.AbsorbAndSpitOutDestructible(pid, radius, maxCount, absorbSpeed, absorbActionGroup, absorbActionType, attachBoneName, spitDelay, spitSpeed, spitActionGroup, spitActionType, finishDelay, startAbsorbDelay, mergeObjShowDelay, spitBindBoneName, spitOriScaleRatio, spitScaleChangeDur)
end

function M.RefreshDialogTriggerState()
	gMessageManager:SendMessage(gEventConstants.REFRESH_DIALOG_TRIGGER_STATE)
end

function M.AskLeaveRaid()
	gUIUtils:ShowExitRaidWindow()
end

function M.StartBlackCatShot(SubQuestId, UnitConfigId, Distance, MinX, MaxX, MinY, MaxY, MinFov, MaxFov, X, Y, Fov, TaskNeedFov, npcCfgId, posX, posY, posZ, angleX, angleY, angleZ, hideNpcId, animationGroup, animationId, lookAtPlayer)
	return
end

function M.EnableNpcAIChat(aiNpcModelIndex)
	return
end

function M.ShowDialog(diaId)
	gDialogManager:ShowDialogInteractionActionFinish(diaId, M.currentNpc)
end

function M.ShowActivityDialog(diaId)
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(M.currentNpc.Pid)
	local dialogParam = gDialogManager:CreateDialogParam()

	if npcSpawn then
		local cfgId = npcSpawn.spiritAcquisitionCfgId
		local DialogCameraSpawnName = LTConfig.AgentDataSetsActivityConfig.GetConfig(cfgId).DialogCameraSpawnName
		local dialogData = gSpoonMgr:GetRaidGraph():GetDialogSpawnDataByCameraId(DialogCameraSpawnName)

		if dialogData then
			dialogParam.DCTConfig.customPosition = dialogData.pos
			dialogParam.DCTConfig.customRotation = dialogData.forward
		end
	else
		print_error("未找到交互NPC Spawn信息")
	end

	dialogParam.speakNpc = gCS.SceneDataMgr.GetUnit(M.currentNpc.Pid)

	gDialogManager:ShowGeneralDialog(diaId, gDialogSource.Activity)
end

function M.ShowDialogFocusNpc(diaId, isHidePlayer, cameraDis, observationOffset, lookAtOffset)
	observationOffset = observationOffset or Vector3.zero
	lookAtOffset = lookAtOffset or Vector3.zero
	cameraDis = cameraDis or 0
	isHidePlayer = isHidePlayer ~= nil and isHidePlayer or false
	local lookAtPos = M.currentNpc.PlayerObj:TransformPoint(lookAtOffset)

	print_error("ShowDialogFocusNpc", true, diaId, isHidePlayer, cameraDis, observationOffset, lookAtPos)
	gCS.CameraDataMgr.cinemachineManager:EnableFocusNpcCamera(diaId, isHidePlayer, cameraDis, observationOffset, lookAtPos)
	gDialogManager:ShowGeneralDialog(diaId, gDialogSource.DialogScriptFunc)
end

function M.SetCameraFocusItem(cameraDis, isHidePlayer, observationOffset, lookAtOffset)
	cameraDis = cameraDis or 3

	if isHidePlayer == nil then
		isHidePlayer = false
	end

	observationOffset = observationOffset or Vector3.zero
	lookAtOffset = lookAtOffset or Vector3.zero
	local lookAtPos = M.currentNpc.PlayerObj:TransformPoint(lookAtOffset)

	gCS.CameraDataMgr.cinemachineManager:EnableFocusNpcCamera(0, isHidePlayer, cameraDis, observationOffset, lookAtPos)
end

function M.ShowDialogWithoutNpc(diaId)
	gDialogManager:ShowDialogInteractionActionFinish(diaId)
end

function M.Vibrate(times, deltaTime)
	local timesReal = 2
	local deltaTimeReal = 0.65

	if times ~= nil then
		timesReal = times
	end

	if deltaTime ~= nil then
		deltaTimeReal = deltaTime
	end

	gCS.LuaUtils.Vibrate(timesReal, deltaTimeReal)
end

function M.PlaySound(effectId)
	gSoundMgr:PlaySoundByTid(effectId)
end

function M.PlayVoice(effectId)
	local unit = M.currentNpc or gCS.MyPlayerManager.PlayerUnit

	gUIUtils:PlayVoiceOld(effectId, unit)
end

function M.ShowSprite(spriteName)
	return
end

function M.ShowArrowToMove(direction, callBackStr, x, y, canFail, failCallBack)
	return
end

function M.ShowButtonToClick(callBackStr, time, addValue, x, y, canFail, failCallBack)
	if time == nil then
		time = 30
	end

	if addValue == nil then
		addValue = 0.1
	end

	if x == nil then
		x = 50
	end

	if y == nil then
		y = 50
	end
end

function M.ShowButtonToClickOnce(callBackStr, x, y)
	if x == nil then
		x = 50
	end

	if y == nil then
		y = 50
	end
end

function M.PlayGuideXiaoqianAction(effectId, isStart)
	gMessageManager:SendMessage(gEventConstants.GUIDE_PLAY_XIAOQIAN_ACTION, {
		effectId,
		isStart
	})
end

function M.ShowHappyJump()
	return
end

function M.ShowOrClosePanelById(panelId)
	if gPanelManager:IsPanelShowing(panelId) then
		gPanelManager:Close(panelId)
	else
		gPanelManager:CheckShow(panelId)
	end
end

function M.ShowPanelById(panelId, parma)
	return
end

function M.ShowPanel(id)
	return
end

function M.ShowInfoDisplayPanel(bookId)
	gCommonInfoPanelUtils.OpenCommonInfoPanelWithoutTarget({
		id = bookId
	})
end

function M.ShowBlackOutEffect(isDawn)
	return
end

function M.FireRoom(roomName)
	print_error("除新手引导以外，客户端不再支持FireRoom id = ", M.currentDialogId)
end

function M.OpenRandomBattle()
	return
end

function M.PlayEffect(effectId, offsetX, offsetY, offsetZ)
	local offset = Vector3.New(offsetX or 0, offsetY or 0, offsetZ or 0)

	if gPlayerManager.infoBase.bindData.Pid and gCS.MyPlayerManager.PlayerUnit ~= nil then
		offset = gCS.MyPlayerManager.PlayerUnit.LocalRotation * offset

		gCS.EffectMgr:PlayEffectsForUnitId(gPlayerManager.infoBase.bindData.Pid, effectId, gCS.MyPlayerManager.PlayerUnit.LocalPosition + offset)
	else
		gCS.EffectMgr:PlayEffects(effectId, Vector3.zero)
	end
end

function M.PlayEffectOnNpc(effectId)
	if M.currentNpc and not gCS.EffectMgr:HasEffectForUnit(M.currentNpc.Pid, effectId) then
		gCS.EffectMgr:PlayEffectsForUnitId(M.currentNpc.Id, effectId)
	end
end

function M.ShowPhoto(isShow, scale)
	return
end

function M.PvpTutorial()
	return
end

function M.PveTutorial()
	local npc = M.currentNpc

	M.OpenPveTutorialUI(npc)
end

function M.OpenPveTutorialUI(npc)
	return
end

function M.StartDebate()
	gClientToGameDelegate:AskVerbalTrickStart().Callback = function (err)
		if err == MessageConfig.Ok then
			-- Nothing
		end
	end
end

function M.TaskViewItem(id, type)
	return
end

function M.PlayControlEvent(eventName)
	gPlayerManager:GuideEvent(eventName)
end

function M.ShowLingAttrPanel(lingTemplateId)
	return
end

function M.SetTaskCounterValue(taskId, counterIndex, value)
	print_error("客户端action不再支持修改TaskCounter，需要请填服务端action, dalogId=", M.currentDialogId)
end

function M.FreezeDialogClick(time)
	gLuaUIMgr.dialogNextCanClickTime = Time.unscaledTime + time
end

function M.OpenNpcShop(shopId)
	gPanelManager:CheckShow(gPanelId.S_NPC_SHOP_PANEL, {
		shopId = shopId,
		focusNpc = M.currentNpc
	})
end

function M.ShowMessage(messageId)
	gDisplayMessageMgr:ShowMessage(messageId)
end

function M.PlayNpcAction(actionId, loop)
	local npc = M.currentNpc

	if npc == nil then
		return
	end

	local actionIDs = actionId
	local times = nil

	if loop then
		times = 999999
	else
		times = -1
	end

	gClientUtils.PlaySingleAction(npc, actionId, npc.State.ActionGroupId, times)
end

function M.PlayNpcActions(startAction, loopAction)
	local npc = M.currentNpc

	if npc == nil then
		return
	end

	local actionIDs = {
		startAction,
		loopAction
	}
	local time = gCS.AnimationManager.AnimatorGetAnimationTime(npc, startAction, npc.State.ActionGroupId)
	local times = {
		time,
		999999
	}

	gClientUtils:PlayQueuedActions(npc, actionIDs, nil, times)
end

function M.PlayAction(unitIndex, ...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_ACTION, {
		false,
		unitIndex,
		{
			...
		}
	})
end

function M.PlayActionLoop(unitIndex, ...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_ACTION, {
		true,
		unitIndex,
		{
			...
		}
	})
end

function M.PlayActionStop(unitIndex)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_ACTION, {
		false,
		unitIndex
	})
end

function M.PlayHouseNpcAction(...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_HOUSE_NPC_ACTION, {
		{
			...
		},
		false
	})
end

function M.PlayHouseNpcActionLoop(...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_HOUSE_NPC_ACTION, {
		{
			...
		},
		true
	})
end

function M.StopHouseNpcAction()
	gMessageManager:SendMessage(gEventConstants.DIALOG_HOUSE_NPC_ACTION, {})
end

function M.SetModelActionType(unitIndex, actionType)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_ACTION_TYPE, {
		unitIndex,
		0,
		actionType
	})
end

function M.SetModelActionTypeByNpcId(npcId, actionType)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_ACTION_TYPE, {
		0,
		npcId,
		actionType
	})
end

function M.SetModeActionSequence(actionGroup)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_ACTION_TYPE, {
		0,
		[4] = actionGroup
	})
end

function M.SetModelIK(sourceIndex, targetIndex)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_IK, {
		sourceIndex,
		targetIndex
	})
end

function M.StopModelIK(sourceIndex)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_IK, {
		sourceIndex
	})
end

function M.ForbidModelIK(sourceIndex)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_IK, {
		sourceIndex,
		-1
	})
end

function M.ShowNpcChat(content, time)
	return
end

function M.ShowQtzFlowerSeedPanel()
	return
end

function M.SwitchScene(raidId, mapEntranceId)
	if mapEntranceId == nil then
		mapEntranceId = 0
	end

	gRpcUtils:AskPublicSwitchToPublicScene(raidId, mapEntranceId)
end

local function PlayNpcTalks(npc, contents, time)
	for i = 1, #contents do
		local str = contents[i]

		if npc ~= nil and str ~= nil then
			npc:UnitTalk(str, time, false)
			coroutine.wait(time)
		end
	end
end

function M.ShowMultipleChats(time, ...)
	return
end

function M.DelayScreen()
	return
end

function M.EndWithHeiPing()
	gLuaUIMgr.dialogEndWithBlack = true
end

function M.LightIntensity(intensity)
	gCS.LightSettings.Instance:CoverColorIntensity(true, intensity)
end

function M.LightIntensityOff()
	gCS.LightSettings.Instance:CoverColorIntensity(false, 1)
end

function M.FindTeacher()
	return
end

function M.FindStudent()
	return
end

function M.ShowLingZhuanyiPanel()
	return
end

function M.IsInMyGuildLand()
	return
end

function M.InMapTansfer()
	return
end

function M.UseItem(itemTemplateId, itemCount)
	if gPlayerItemManager:QueryItemById(itemTemplateId) then
		gPlayerItemManager:UseItemByTemplateId(itemTemplateId, itemCount)
	end
end

function M.UseItemByList(itemTemplateIdList, itemCount)
	for i, v in pairs(itemTemplateIdList) do
		local id = itemTemplateIdList[i]

		if gPlayerItemManager:QueryItemById(id) then
			gPlayerItemManager:UseItemByTemplateId(id, itemCount)

			return
		end
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.ItemNotExist)
end

function M.CheckShowStaticPanel(id, data)
	if not M.CheckPanelCanShow(id) then
		return
	end

	gPanelManager:Close(gPanelId.S_INVENTORY_PANEL)
	gPanelManager:CheckShow(id, data)
end

function M.HasBuff(buffID)
	return gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, buffID)
end

function M.IsClick()
	return M.isClick
end

function M.AskExchangeInvitation()
	return
end

function M.OpenFunInteractivePanel()
	return
end

function M.OpenTryOnPanel(step)
	return
end

function M.OpenDisPatchPanel()
	return
end

function M.LODHigh(enable)
	gCS.CameraDataMgr.forceShaderLOD_High = enable
end

function M.OpenMonsterPanel()
	gPanelManager:CheckShow(gPanelId.S_SKILL_DEBUG_PANEL, {
		ShowAddEnemy = true
	})
end

function M.AskOnlyOneTaskSpiritAndOpenYanWen()
	gClientToGameDelegate:AskOnlyOneTaskSpirit().Callback = function (err, uid, isDestroy)
		if err == MessageConfig.Ok and not isDestroy then
			-- Nothing
		end
	end
end

function M.SetDialogCameraRootEnemyPos(enemyId)
	gMessageManager:SendMessage(gEventConstants.DIALOG_MOVE_CAMERA_ENEMY_NPC_POS, {
		1,
		enemyId
	})
end

function M.SetDialogCameraRootNpcPos(npcId)
	gMessageManager:SendMessage(gEventConstants.DIALOG_MOVE_CAMERA_ENEMY_NPC_POS, {
		2,
		npcId
	})
end

function M.SetBranchActions(...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_BRANCH_ACTIONS, {
		...
	})
end

function M.PlayRootMotionAction(action, x, y, z, loopAction)
	print_error("PlayRootMotionAction 这个功能失效，有问题找肖阳")
end

function M.OpenDailyTaskPanel()
	gPanelManager:CheckShow(gPanelId.S_SCHEDULE_PANEL)
end

function M.OpenGuGuFeedBack()
	return
end

function M.EmptyFunc(param)
	return
end

function M.EnterFaceBuild(resetCharacter)
	return
end

function M.SwitchFaceBuildFile(jobId)
	return
end

local DialogType = {
	RoomLock = 2,
	LongLive = 3,
	FirstTime = 1
}

function M.OpenFriendAddPanel()
	return
end

function M.OpenLifeSkillMain()
	return
end

function M.GetGuildFuLi()
	return
end

function M.AcceptCurrentTask(taskId)
	gTaskManager:SetCurrentTask(taskId)
end

function M.TryPlayAction(...)
	local npc = M.currentNpc

	if npc == nil then
		return
	end

	local n = select("#", ...)
	local args = {
		...
	}
	local haveAction = {}

	for i = 1, n do
		local actionTime = gCS.AnimationManager.AnimatorGetAnimationTime(npc, args[i], npc.State.ActionGroupId)

		if actionTime and actionTime > 0 then
			table.insert(haveAction, args[i])
		end
	end

	if #haveAction <= 0 then
		return
	end

	local idx = math.random(1, #haveAction)
	local actionTime = gCS.AnimationManager.AnimatorGetAnimationTime(npc, haveAction[idx], npc.State.ActionGroupId)

	gClientUtils.PlaySingleAction(npc, haveAction[idx], nil, actionTime)
end

function M.OpenAbyssPanel()
	return
end

function M.ShowBountyHunterTask(taskId)
	taskId = taskId or M.currentTaskId

	gTaskManager:SetCurrentTask(taskId)
end

function M.HideBountyHunterTask()
	local taskId = M.currentTaskId

	gTaskManager:RemoveCurrentTask(taskId)
end

function M.ContinueTimeLineSkill(timelineName)
	gTimelineManager:Timeline_Pause(timelineName, false)
end

function M.PlaySceneSlotTweenByString(strKey, groupId, isReverse, resetBegin)
	local entity = gGadgetManager:GetEntityByTypeOtherName("LuaSlotComponent", strKey)
	groupId = tonumber(groupId)

	if entity then
		local movement = entity:GetPlugin(entity.commonPlugins.LuaSlotEntityMovementPlugin)

		if isReverse then
			movement:PlayReverse(groupId, resetBegin)
		else
			movement:PlayForward(groupId, resetBegin)
		end
	end
end

function M.PlaySceneSlotTweenOneByOne(strKey, listStart, listEnd)
	local entity = gGadgetManager:GetEntityByTypeOtherName("LuaSlotComponent", strKey)

	if entity then
		local movement = entity:GetOrAddPlugin(entity.commonPlugins.LuaSlotEntityMovementPlugin)

		if movement then
			listStart = tonumber(listStart)
			listEnd = tonumber(listEnd)

			movement:PlayTweenByGroupIdOneByOneBundle(listStart, listEnd)
		end
	end
end

function M.ClientSpawnEnemy(taskId, npcId, minRadius, maxRadius, isInCounter, ...)
	return
end

function M.OpenRaidDoor()
	if not gSpoonMgr:GetRaidGraph():GetInteractiveNpcStates(M.currentNpc.NpcId) then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900844).Text)
	end
end

function M.OpenFightTrialPanel()
	local params = {
		doTrialDirectly = true,
		seasonId = gInspireHubManager:GetSeasonId(),
		gamePlayId = LTConfig.InspireHubGamePlayConfig.Fight
	}

	gPanelManager:CheckShow(gPanelId.TRIAL_PANEL, params)
end

function M.PopupPictureCollectHint(galleryId)
	return
end

function M.CreateProcedureGameRule(ruleType)
	gSceneGameRuleManager:CreateProcedureGameRule(ruleType)
end

function M.ShowBlackCatShotPanel(SubQuestId, UnitConfigId, Distance, MinX, MaxX, MinY, MaxY, MinFov, MaxFov, X, Y, Fov, TaskNeedFov)
	return
end

function M.PauseDropQueue(autoResumeTime)
	if autoResumeTime and autoResumeTime ~= 0 then
		gLuaTimeMgrUtils.Delay(function ()
			M.ResumeDropQueue()
		end, autoResumeTime)
	end

	gMessageManager:SendMessage(gEventConstants.DROP_QUEUE_PAUSE)
end

function M.ResumeDropQueue()
	gMessageManager:SendMessage(gEventConstants.DROP_QUEUE_RESUME)
end

function M.ShowChallengePanel(taskId)
	return
end

function M.FinishChallengePanel(taskId)
	return
end

function M.CloseChallengePanel()
	return
end

function M.DinnerAlone(gameplayId)
	return
end

function M.DinnerInviteNpc(gameplayId)
	local cfg = gRestaurantManager:GetRestaurantCfg(gameplayId)

	if cfg then
		gClientToGameSceneDelegate:AskRestaurantInviteNpc(cfg.Id)
	else
		print_error("邀请Npc出错，RestaurantConfig表里找不到对应的餐饮店配置，gameplayId = ", gameplayId)
	end
end

function M.OnsenInvite()
	gHotSpringManager:OnInviteNpc(M.currentNpc)
end

function M.InviteNpcContinueOrder()
	local function stayHandler()
		if gRestaurantManager.dateStage == C_RestaurantManager.DATE_STAGE.NORMAL_ORDER or gRestaurantManager.dateStage == C_RestaurantManager.DATE_STAGE.PET_ANIMAL_ORDER or gRestaurantManager.dateStage == C_RestaurantManager.DATE_STAGE.MAID_TEA_ORDER then
			gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
				gameplayType = "RestaurantOrder",
				params = {
					focusNpc = gRestaurantManager.inviteCsUnit,
					mode = C_RestaurantManager.ORDER_MODE.DATE,
					gameplayId = gRestaurantManager.currentGameplayId,
					cameraIdList = {
						gRestaurantManager.dateCameraId
					},
					npcTreat = gRestaurantManager.NPCTreat
				}
			})
		end
	end

	gBlackScreenManager:AutoTransition(gBlackScreenId.RESTAURANT_INVITE, "", false, false, 0.5, 1, 0.5, stayHandler)
end

function M.OpenMovieSelectPanel(cinemaId, locationId)
	local panelId = gLinkManager:CheckInLinkMode() and gPanelId.CINEMA_OL_MAIN_PANEL or gPanelId.S_CINEMA_MAIN_PANEL

	if gCS.LuaUtils.IsDebug and (LTConfig.CinemaConfig.GetConfig(cinemaId) == nil or LTConfig.CinemaLocationConfig.GetConfig(locationId) == nil) then
		print_error("OpenMovieSelectPanel get bad config id", cinemaId, locationId)
	end

	gPanelManager:CheckShow(panelId, {
		cinemaId = cinemaId,
		locationId = locationId
	})
end

function M.Exercise1p(gymId)
	gGymManager:Exercise1p(gymId)
end

function M.Exercise2p(gymId)
	gGymManager:Exercise2p(gymId)
end

function M.ClawMachineStart(machineId)
	gClawMachineManager:StartPlayClawMachineById(machineId, C_ClawMachineManager.PLAY_MODE.SOLO)
end

function M.ResetAllClawMachine()
	gCS.ClawMachineMgr:ResetAllClawMachine(false)
	gDialogManager:ShowGeneralDialog(ClawMachineConfig.ArrangeDialog, gDialogSource.DialogScriptFunc)
end

function M.ClawMachineInviteNpc(machineId)
	gClawMachineManager.npcRelatedMachineId = machineId
	gClawMachineManager.inviteMachineNpcId = M.currentNpc.NpcId

	gClientToGameDelegate:AskSimulationInviteNpc(NPCChatGamePlayTypeConfig.ClawMachine)
end

function M.ClawmachineStartDate(machineId)
	gClawMachineManager:StartPlayDateMachine(machineId)
end

function M.WashWallInviteNpc()
	gClientToGameDelegate:AskSimulationInviteNpc(NPCChatGamePlayTypeConfig.Washwall)
end

function M.InviteMahjongInRoom()
	gMaJiangManager:AskInviteNpcInRoom()
end

function M.InviteMahjongRandom()
	gMaJiangManager:AskInviteNpcRandom()
end

function M.InviteMahjongFromChat()
	gClientToGameDelegate:AskSimulationInviteNpc(NPCChatGamePlayTypeConfig.Mahjong)
end

function M.MahjongRank()
	gMaJiangManager:OpenRankPanel()
end

function M.SendMessage(messageId)
	gMessageManager:SendMessage(messageId)
end

function M.TaskShortCutShowPhoto(showPictureImageId)
	local imgId = showPictureImageId

	if imgId then
		gUIUtils:CommonShowPhoto({
			imageId = imgId
		})
	end
end

function M.TaskShortCutHackingScan()
	L50.L50App.Scene.ScanMgr:OnTriggerScan()
end

function M.TaskShortCutShowTakePhotoUI()
	gTakePhotoUtils.TryTakePhoto()
end

function M.ShowSelfIeModePhoto()
	gTakePhotoUtils.TryTakePhoto(nil, {
		isSelfIeMode = true
	})
end

function M.TaskShortCutOpenCallPhone()
	gMainPhoneFunctionAction.OpenCallPhone()
end

function M:OpenPhonePanel()
	gClientUtils.OpenMainPhonePanel()
end

function M.OpenGangsterMap()
	local params = {
		gangsterMode = true
	}

	gMapUtils:CheckRaidCanOpenMap(params)
end

function M.ChatFavorable()
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(M.currentNpc.Pid)

	if not npcSpawn then
		return
	end

	local cfgId = npcSpawn.spiritAcquisitionCfgId

	gSpiritAcquisitionManager:ChatFavorable(cfgId, M.currentNpc)
end

function M.PhotoFavorable()
	gSpiritAcquisitionManager:TakePhotoFavorable(M.currentNpc)
end

function M.GivePresentFavorable()
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(M.currentNpc.Pid)

	if not npcSpawn then
		return
	end

	local cfgId = npcSpawn.spiritAcquisitionCfgId

	gSpiritAcquisitionManager:GivePresentFavorable(cfgId, {
		disabled = gSpiritAcquisitionManager:GetPresentGiveState()
	})
end

function M.CallCar(contactOptionId)
	gCallPhoneUtils.CallCar(contactOptionId)
end

function M.StartStorage()
	gInteractionManager:UnitStartStorge(M.currentNpc)
end

function M.CallMileCar(contactOptionId)
	gCallPhoneUtils.CallMilkCar(contactOptionId)
end

function M.ReportAlarm(contactOptionId)
	gCallPhoneUtils.ReportAlarm(contactOptionId)
end

function M.CheckContactOptionHasUnlock(contactOptionId)
	return gCallPhoneUtils.CheckContactOptionHasUnlock(contactOptionId)
end

function M.ShowNpcFavourDialog(contactOptionId)
	gCallPhoneUtils.ShowNpcFavourDialog(contactOptionId)
end

function M.CheckContainJobClassId(JobClassId)
	return gSpiritJobManager:CheckContainJobClassId(JobClassId)
end

function M.CheckNotContainJobClassId(JobClassId)
	return not gSpiritJobManager:CheckContainJobClassId(JobClassId)
end

function M.CheckCurrentRoleIsMatching(id)
	if type(id) == "number" then
		return gCS.MyPlayerManager.PlayerUnit.ClientData.SubType == id
	end

	if type(id) == "table" then
		local res = false

		for i, v in pairs(id) do
			res = res or gCS.MyPlayerManager.PlayerUnit.ClientData.SubType == v
		end

		return res
	end

	print_error("Dialog对话分支条件设置错误，CheckCurrentRoleIsMatching的输入值有问题，请检查。对话ID：" .. gDialogManager:GetCurrentDialogId())

	return true
end

function M.CheckNotCurrentjob(JobClassId)
	return not gSpiritJobManager:CheckIsCurrentjob(JobClassId)
end

function M.OpenChaosMasterNpc(npcId, gameMode)
	if gameMode == nil then
		gameMode = UX.Game.BVBGameModeType.BVBGameSimpleBrawl
	end

	gPanelManager:CheckShow(gPanelId.CHAOS_MASTER_PREVIEW_PANEL, {
		npcId = npcId,
		gameMode = gameMode
	})
end

function M.OpenChaosMasterNpcTest()
	local gameMode = UX.Game.BVBGameModeType.BVBGameSimpleBrawl

	gPanelManager:CheckShow(gPanelId.CHAOS_MASTER_PREVIEW_PANEL, {
		npcId = 100,
		isTest = true,
		gameMode = gameMode
	})
end

function M.PoliceHasFine(fineId)
	return gPoliceJobManager.examineMgr:HasFine(fineId)
end

function M.EnterNpcQte()
	gCS.BaseUnitUtils.StartRidingInteract(gCS.MyPlayerManager.PlayerUnit.Pid, M.currentNpc.Pid, true)
end

function M.Mount()
	gCS.BaseUnitUtils.Mount(M.currentNpc.Pid)
end

function M.Dismount()
	gCS.BaseUnitUtils.Dismount()
end

function M.OpenCharMotionPanel()
	gMainPhoneFunctionAction.OpenCharMotionPanel({
		showType = gClientConst.MOTION_ACTION_SHOW_TYPE.Double,
		npcId = M.currentNpc.NpcId,
		npcPid = M.currentNpc.Pid
	})
end

function M.CheckMilkVehicleEnable()
	return gCallPhoneUtils.CheckMilkCarHasUnlocked() and not gLinkManager:CheckInMatchMode()
end

function M.CheckTaskAccepted(taskId)
	for i, v in pairs(gTaskManager.acceptedTasks) do
		if i == taskId and v then
			return true
		end
	end

	for i, v in pairs(gTaskManager.submitTasks) do
		if i == taskId and v then
			return true
		end
	end

	return false
end

function M.GetTaskEventState(eventId)
	local state = gTaskManager:GetTaskEventState(eventId)

	return state
end

function M.InGameTimeRange(startHour, endHour)
	return L50.L50App.Scene.GamePlayUtils:IsInGameTimeRange(startHour, endHour)
end

function M.OpenMatchPanel(matchId)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL, {
		modeId = matchId
	})
end

gDialogScriptFunc = M
