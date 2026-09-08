-- Original chunk: @Lua\LuaFiles\LX6\GUI\Dialog\DialogScriptFunc.lua
-- Decompiled from: 00507_DialogScriptFunc.lua_2a7f3c8e8c45.luajit

local MessageConfig = LTConfig.MessageConfig
local ClawMachineConfig = LTConfig.ClawMachineConfig
local GamePlayTypeConfig = LTConfig.NpcCultivationGameplayTypeConfig
local M = {
	currentDialogId = 0,
	currentTaskId = 0,
	Data = nil,
	isNextAction = false,
	isClick = false,
	Vector3 = Vector3,
	gPanelId = gPanelId
}

M.FeiSuoAction = function()
	if M.Data then
		if M.Data.id and M.Data.id <= 0 then
			local unit = gCS.LocalUnitMgr:GetNpcByTemplateId(M.Data.id)

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
		elseif M.Data.vehicleId and M.Data.vehicleId <= 0 then
			local vehicleUnit = gDriveVehiclesManager:GetBaseVehicle(M.Data.vehicleId)

			if vehicleUnit then
				local vehicleFeiSuoPoint = vehicleUnit.GetFeiSuoPoint(vehicleUnit)

				if vehicleFeiSuoPoint then
					M.taskFeisuoMover = vehicleFeiSuoPoint.gameObject

					gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnit.Pid, vehicleFeiSuoPoint.position, vehicleFeiSuoPoint, gLuaFightConstants.FeisuoType_Task, M.Data.banMove, M.Data.isPoint)
				end
			end
		elseif M.Data.GadgetUniqueId and not ulong.equals(M.Data.GadgetUniqueId, 0) and M.Data.slotBindName then
			local entity = gGadgetManager:GetEntitySearchByInstanceId(M.Data.GadgetUniqueId)
			local go = nil
			local slotName = M.Data.slotBindName
			local targetPos = nil

			if entity.GetGameObjectById then
				local gameObjectMap = entity:GetGameObjectMap():ToTable()

				for i, v in pairs(gameObjectMap) do
					if v.name ~= slotName then
						go = v

						break
					end
				end
			elseif entity and entity.gameObjectRoot[slotName] and entity.gameObjectRoot[slotName][0] then
				targetPos = entity.gameObjectRoot[slotName][0]
			end

			local moverGo = nil
			local moverBindId = M.Data.moverBindId

			if moverBindId and moverBindId == 0 then
				moverGo = entity.GetGameObjectById(entity, moverBindId)
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

M.AbsorbAndSpitOutDestructible = function(radius, maxCount, absorbSpeed, absorbActionGroup, absorbActionType, attachBoneName, spitDelay, spitSpeed, spitActionGroup, spitActionType, finishDelay, startAbsorbDelay, mergeObjShowDelay, spitBindBoneName, spitOriScaleRatio, spitScaleChangeDur)
	local pid = M.currentNpc.Pid

	gCS.BaseUnitUtils.AbsorbAndSpitOutDestructible(pid, radius, maxCount, absorbSpeed, absorbActionGroup, absorbActionType, attachBoneName, spitDelay, spitSpeed, spitActionGroup, spitActionType, finishDelay, startAbsorbDelay, mergeObjShowDelay, spitBindBoneName, spitOriScaleRatio, spitScaleChangeDur)
end

M.RefreshDialogTriggerState = function()
	gMessageManager:SendMessage(gEventConstants.REFRESH_DIALOG_TRIGGER_STATE)
end

M.AskLeaveRaid = function()
	gUIUtils:ShowExitRaidWindow()
end

M.StartBlackCatShot = function(SubQuestId, UnitConfigId, Distance, MinX, MaxX, MinY, MaxY, MinFov, MaxFov, X, Y, Fov, TaskNeedFov, npcCfgId, posX, posY, posZ, angleX, angleY, angleZ, hideNpcId, animationGroup, animationId, lookAtPlayer)
end

M.EnableNpcAIChat = function(aiNpcModelIndex)
end

M.ShowDialog = function(diaId)
	local dialogParam = gDialogManager:CreateDialogParam()
	dialogParam.dialogSource = gDialogSource.DialogScriptFunc

	gDialogManager:ShowDialogInteractionActionFinish(diaId, M.currentNpc, nil, dialogParam)
end

M.ShowActivityDialog = function(diaId)
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

M.SetCameraFocusItem = function(cameraDis, isHidePlayer, observationOffset, lookAtOffset)
	cameraDis = cameraDis or 3

	if isHidePlayer ~= nil then
		isHidePlayer = false
	end

	observationOffset = observationOffset or Vector3.zero
	lookAtOffset = lookAtOffset or Vector3.zero
	local lookAtPos = M.currentNpc.PlayerObj:TransformPoint(lookAtOffset)

	gCS.CameraDataMgr.cinemachineManager:EnableFocusNpcCamera(0, isHidePlayer, cameraDis, observationOffset, lookAtPos)
end

M.ShowDialogWithoutNpc = function(diaId)
	gDialogManager:ShowDialogInteractionActionFinish(diaId)
end

M.Vibrate = function(times, deltaTime)
	local timesReal = 2
	local deltaTimeReal = 0.65

	if times == nil then
		timesReal = times
	end

	if deltaTime == nil then
		deltaTimeReal = deltaTime
	end

	gCS.LuaUtils.Vibrate(timesReal, deltaTimeReal)
end

M.PlaySound = function(effectId)
	gSoundMgr:PlaySoundByTid(effectId)
end

M.PlayVoice = function(effectId)
	local unit = M.currentNpc or gCS.MyPlayerManager.PlayerUnit

	gUIUtils:PlayVoiceOld(effectId, unit)
end

M.ShowSprite = function(spriteName)
end

M.ShowArrowToMove = function(direction, callBackStr, x, y, canFail, failCallBack)
end

M.ShowButtonToClick = function(callBackStr, time, addValue, x, y, canFail, failCallBack)
	if time ~= nil then
		time = 30
	end

	if addValue ~= nil then
		addValue = 0.1
	end

	if x ~= nil then
		x = 50
	end

	if y ~= nil then
		y = 50
	end
end

M.ShowButtonToClickOnce = function(callBackStr, x, y)
	if x ~= nil then
		x = 50
	end

	if y ~= nil then
		y = 50
	end
end

M.PlayGuideXiaoqianAction = function(effectId, isStart)
	gMessageManager:SendMessage(gEventConstants.GUIDE_PLAY_XIAOQIAN_ACTION, {
		effectId,
		isStart
	})
end

M.ShowHappyJump = function()
end

M.ShowOrClosePanelById = function(panelId)
	if gPanelManager:IsPanelShowing(panelId) then
		gPanelManager:Close(panelId)
	else
		gPanelManager:CheckShow(panelId)
	end
end

M.ShowChallengeStatement = function(taskId)
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_STATEMENT_PANEL, {
		taskId = taskId
	})
end

M.ShowPanelById = function(panelId, parma)
end

M.ShowPanel = function(id)
end

M.ShowInfoDisplayPanel = function(bookId)
	gCommonInfoPanelUtils.OpenCommonInfoPanelWithoutTarget({
		id = bookId
	})
end

M.ShowMahjongMatchPanel = function()
	gDialogScriptFunc.OpenMatchPanel(LTConfig.LinkMultiPlayerConfig.NormalMahjong)
end

M.ShowBowlingTeachPanel = function()
	gPanelManager:CheckShow(gPanelId.BOWLING_TEACH_PANEL)
end

M.KTVBuyTicket = function()
	local cfg = LTConfig.KTVConfig
	slot1 = gClientToGameDelegate

	slot1:AskKTVBuyPackageTicket().Callback = function (err, ticket)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if ticket then
			gKTVGameManager:StoreTicket(ticket.TicketId, ticket.RemainCount)
		end

		gNewPopupManager:PushPopup(LTConfig.PopupConfig.PayTips, {
			Param = {
				["\\x92;.:a\\xb8O\\xd6\"\\xad\\xb1"] = true,
				value = cfg.MoneyCost,
				logoId = cfg.DecreaseMoneyLogoId,
				textId = cfg.DecreaseMoneyTextId
			}
		})
		M.ShowDialog(cfg.BuyTicketDialogId)
	end
end

M.ShowBlackOutEffect = function(isDawn)
end

M.FireRoom = function(roomName)
	print_error("除新手引导以外，客户端不再支持FireRoom id = ", M.currentDialogId)
end

M.OpenRandomBattle = function()
end

M.PlayEffect = function(effectId, offsetX, offsetY, offsetZ)
	local offset = Vector3.New(offsetX or 0, offsetY or 0, offsetZ or 0)

	if gPlayerManager.infoBase.bindData.Pid and gCS.MyPlayerManager.PlayerUnit == nil then
		offset = gCS.MyPlayerManager.PlayerUnit.LocalRotation * offset

		gCS.EffectMgr:PlayEffectsForUnitId(gPlayerManager.infoBase.bindData.Pid, effectId, LX6.Effect.EffectPlayTag.Task, gCS.MyPlayerManager.PlayerUnit.LocalPosition + offset)
	else
		gCS.EffectMgr:PlayEffect(effectId, LX6.Effect.EffectPlayTag.Task, Vector3.zero)
	end
end

M.PlayEffectOnNpc = function(effectId)
	if M.currentNpc and not gCS.EffectMgr:HasEffectForUnit(M.currentNpc.Pid, effectId) then
		gCS.EffectMgr:PlayEffectsForUnitId(M.currentNpc.Id, effectId, LX6.Effect.EffectPlayTag.Task)
	end
end

M.ShowPhoto = function(isShow, scale)
end

M.PvpTutorial = function()
end

M.PveTutorial = function()
	local npc = M.currentNpc

	M.OpenPveTutorialUI(npc)
end

M.OpenPveTutorialUI = function(npc)
end

M.StartDebate = function()
	slot0 = gClientToGameDelegate

	slot0:AskVerbalTrickStart().Callback = function (err)
		if err ~= MessageConfig.Ok then
			-- Nothing
		end
	end
end

M.TaskViewItem = function(id, type)
end

M.PlayControlEvent = function(eventName)
	gPlayerManager:GuideEvent(eventName)
end

M.ShowLingAttrPanel = function(lingTemplateId)
end

M.SetTaskCounterValue = function(taskId, counterIndex, value)
	print_error("客户端action不再支持修改TaskCounter，需要请填服务端action, dalogId=", M.currentDialogId)
end

M.FreezeDialogClick = function(time)
	gLuaUIMgr.dialogNextCanClickTime = Time.unscaledTime + time
end

M.OpenNpcShop = function(shopId)
	gPanelManager:CheckShow(gPanelId.S_NPC_SHOP_PANEL, {
		shopId = shopId,
		focusNpc = M.currentNpc
	})
end

M.OpenBlackMarket = function(shopId)
	gPanelManager:CheckShow(gPanelId.FULL_SCREEN_STORE, {
		shopId = shopId
	})
end

M.ShopSell = function(shopId)
	shopId = tonumber(shopId)
	slot1 = gClientToGameDelegate

	slot1:AskNpcShop(shopId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gCommonItemManager:OpenInventoryPanel({
			mode = gCommonItemManager.INVENTORY_MODE.SELL,
			shopId = shopId
		})
	end
end

M.ShowMessage = function(messageId)
	gDisplayMessageMgr:ShowMessage(messageId)
end

M.PlayNpcAction = function(actionId, loop)
	local npc = M.currentNpc

	if npc ~= nil then
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

M.PlayNpcActions = function(startAction, loopAction)
	local npc = M.currentNpc

	if npc ~= nil then
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

M.PlayAction = function(unitIndex, ...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_ACTION, {
		false,
		unitIndex,
		{
			...
		}
	})
end

M.PlayActionLoop = function(unitIndex, ...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_ACTION, {
		true,
		unitIndex,
		{
			...
		}
	})
end

M.PlayActionStop = function(unitIndex)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_ACTION, {
		false,
		unitIndex
	})
end

M.PlayHouseNpcAction = function(...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_HOUSE_NPC_ACTION, {
		{
			...
		},
		false
	})
end

M.PlayHouseNpcActionLoop = function(...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_HOUSE_NPC_ACTION, {
		{
			...
		},
		true
	})
end

M.StopHouseNpcAction = function()
	gMessageManager:SendMessage(gEventConstants.DIALOG_HOUSE_NPC_ACTION, {})
end

M.SetModelActionType = function(unitIndex, actionType)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_ACTION_TYPE, {
		unitIndex,
		0,
		actionType
	})
end

M.SetModelActionTypeByNpcId = function(npcId, actionType)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_ACTION_TYPE, {
		0,
		npcId,
		actionType
	})
end

M.SetModeActionSequence = function(actionGroup)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_ACTION_TYPE, {
		0,
		[4] = actionGroup
	})
end

M.SetModelIK = function(sourceIndex, targetIndex)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_IK, {
		sourceIndex,
		targetIndex
	})
end

M.StopModelIK = function(sourceIndex)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_IK, {
		sourceIndex
	})
end

M.ForbidModelIK = function(sourceIndex)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_MODEL_IK, {
		sourceIndex,
		-1
	})
end

M.ShowNpcChat = function(content, time)
end

M.ShowQtzFlowerSeedPanel = function()
end

M.SwitchScene = function(raidId, mapEntranceId)
	if mapEntranceId ~= nil then
		mapEntranceId = 0
	end

	gRpcUtils:AskPublicSwitchToPublicScene(raidId, mapEntranceId)
end

local PlayNpcTalks = function(npc, contents, time)
	for i = 1, #contents do
		local str = contents[i]

		if npc == nil and str == nil then
			npc.UnitTalk(npc, str, time, false)
			coroutine.wait(time)
		end
	end
end

M.ShowMultipleChats = function(time, ...)
end

M.DelayScreen = function()
end

M.EndWithHeiPing = function()
	gLuaUIMgr.dialogEndWithBlack = true
end

M.LightIntensity = function(intensity)
	gCS.LightSettings.Instance:CoverColorIntensity(true, intensity)
end

M.LightIntensityOff = function()
	gCS.LightSettings.Instance:CoverColorIntensity(false, 1)
end

M.FindTeacher = function()
end

M.FindStudent = function()
end

M.ShowLingZhuanyiPanel = function()
end

M.IsInMyGuildLand = function()
end

M.InMapTansfer = function()
end

M.UseItem = function(itemTemplateId, itemCount)
	if gCommonItemManager:QueryItemById(itemTemplateId) then
		gCommonItemManager:UseItemByTemplateId(itemTemplateId, itemCount)
	end
end

M.UseItemByList = function(itemTemplateIdList, itemCount)
	for i, v in pairs(itemTemplateIdList) do
		local id = itemTemplateIdList[i]

		if gCommonItemManager:QueryItemById(id) then
			gCommonItemManager:UseItemByTemplateId(id, itemCount)

			return
		end
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.ItemNotExist)
end

M.CheckShowStaticPanel = function(id, data)
	if not M.CheckPanelCanShow(id) then
		return
	end

	gCommonItemManager:CloseInventoryPanel()
	gPanelManager:CheckShow(id, data)
end

M.CheckShowPanel = function(id, data)
	gPanelManager:CheckShow(id, data)
end

M.HasBuff = function(buffID)
	return gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, buffID)
end

M.IsClick = function()
	return M.isClick
end

M.AskExchangeInvitation = function()
end

M.OpenFunInteractivePanel = function()
end

M.OpenTryOnPanel = function(step)
end

M.OpenDisPatchPanel = function()
end

M.LODHigh = function(enable)
	gCS.CameraDataMgr.forceShaderLOD_High = enable
end

M.OpenMonsterPanel = function()
	gPanelManager:CheckShow(gPanelId.S_SKILL_DEBUG_PANEL, {
		["\\~\\xa3`m\\xb6\\xf6bdsU"] = true
	})
end

M.AskOnlyOneTaskSpiritAndOpenYanWen = function()
	slot0 = gClientToGameDelegate

	slot0:AskOnlyOneTaskSpirit().Callback = function (err, uid, isDestroy)
		if err ~= MessageConfig.Ok and not isDestroy then
			-- Nothing
		end
	end
end

M.SetDialogCameraRootEnemyPos = function(enemyId)
	gMessageManager:SendMessage(gEventConstants.DIALOG_MOVE_CAMERA_ENEMY_NPC_POS, {
		1,
		enemyId
	})
end

M.SetDialogCameraRootNpcPos = function(npcId)
	gMessageManager:SendMessage(gEventConstants.DIALOG_MOVE_CAMERA_ENEMY_NPC_POS, {
		2,
		npcId
	})
end

M.SetBranchActions = function(...)
	gMessageManager:SendMessage(gEventConstants.DIALOG_NPC_SET_BRANCH_ACTIONS, {
		...
	})
end

M.PlayRootMotionAction = function(action, x, y, z, loopAction)
	print_error("PlayRootMotionAction 这个功能失效，有问题找肖阳")
end

M.OpenDailyTaskPanel = function()
end

M.OpenGuGuFeedBack = function()
end

M.EmptyFunc = function(param)
end

M.EnterFaceBuild = function(resetCharacter)
end

M.SwitchFaceBuildFile = function(jobId)
end

M.OpenFriendAddPanel = function()
end

M.OpenLifeSkillMain = function()
end

M.GetGuildFuLi = function()
end

M.AcceptCurrentTask = function(taskId)
	gTaskManager:SetCurrentTask(taskId)
end

M.TryPlayAction = function(...)
	local npc = M.currentNpc

	if npc ~= nil then
		return
	end

	local n = select("#", ...)
	local args = {
		...
	}
	local haveAction = {}

	for i = 1, n do
		local actionTime = gCS.AnimationManager.AnimatorGetAnimationTime(npc, args[i], npc.State.ActionGroupId)

		if actionTime and actionTime <= 0 then
			table.insert(haveAction, args[i])
		end
	end

	if #haveAction < 0 then
		return
	end

	local idx = math.random(1, #haveAction)
	local actionTime = gCS.AnimationManager.AnimatorGetAnimationTime(npc, haveAction[idx], npc.State.ActionGroupId)

	gClientUtils.PlaySingleAction(npc, haveAction[idx], nil, actionTime)
end

M.OpenAbyssPanel = function()
end

M.ShowBountyHunterTask = function(taskId)
	taskId = taskId or M.currentTaskId

	gTaskManager:SetCurrentTask(taskId)
end

M.HideBountyHunterTask = function()
	local taskId = M.currentTaskId

	gTaskManager:RemoveCurrentTask(taskId)
end

M.ContinueTimeLineSkill = function(timelineName)
	gTimelineManager:Timeline_Pause(timelineName, false)
end

M.PlaySceneSlotTweenByString = function(strKey, groupId, isReverse, resetBegin)
	local entity = gGadgetManager:GetEntityByTypeOtherName("LuaSlotComponent", strKey)
	groupId = tonumber(groupId)

	if entity then
		local movement = entity.GetPlugin(entity, entity.commonPlugins.LuaSlotEntityMovementPlugin)

		if isReverse then
			movement.PlayReverse(movement, groupId, resetBegin)
		else
			movement.PlayForward(movement, groupId, resetBegin)
		end
	end
end

M.PlaySceneSlotTweenOneByOne = function(strKey, listStart, listEnd)
	local entity = gGadgetManager:GetEntityByTypeOtherName("LuaSlotComponent", strKey)

	if entity then
		local movement = entity.GetOrAddPlugin(entity, entity.commonPlugins.LuaSlotEntityMovementPlugin)

		if movement then
			listStart = tonumber(listStart)
			listEnd = tonumber(listEnd)

			movement.PlayTweenByGroupIdOneByOneBundle(movement, listStart, listEnd)
		end
	end
end

M.ClientSpawnEnemy = function(taskId, npcId, minRadius, maxRadius, isInCounter, ...)
end

M.OpenRaidDoor = function()
	if not gSpoonMgr:GetRaidGraph():GetInteractiveNpcStates(M.currentNpc.NpcId) then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900844).Text)
	end
end

M.PopupPictureCollectHint = function(galleryId)
end

M.CreateProcedureGameRule = function(ruleType)
	gSceneGameRuleManager:CreateProcedureGameRule(ruleType)
end

M.ShowBlackCatShotPanel = function(SubQuestId, UnitConfigId, Distance, MinX, MaxX, MinY, MaxY, MinFov, MaxFov, X, Y, Fov, TaskNeedFov)
end

M.PauseDropQueue = function(autoResumeTime)
	if autoResumeTime and autoResumeTime == 0 then
		gLuaTimeMgrUtils.Delay(function ()
			M.ResumeDropQueue()
		end, autoResumeTime)
	end

	gMessageManager:SendMessage(gEventConstants.DROP_QUEUE_PAUSE)
end

M.ResumeDropQueue = function()
	gMessageManager:SendMessage(gEventConstants.DROP_QUEUE_RESUME)
end

M.ShowChallengePanel = function(taskId)
end

M.CloseChallengePanel = function()
end

M.DinnerAlone = function(gameplayId)
end

M.DinnerInviteNpc = function(gameplayId)
	local cfg = gRestaurantManager:GetRestaurantCfg(gameplayId)

	if cfg then
		gClientToGameSceneDelegate:AskRestaurantInviteNpc(cfg.Id)
	else
		print_error("邀请Npc出错，RestaurantConfig表里找不到对应的餐饮店配置，gameplayId = ", gameplayId)
	end
end

M.OnsenInvite = function()
	gHotSpringManager:OnInviteNpc(M.currentNpc)
end

M.InviteNpcContinueOrder = function()
	local stayHandler = function()
		if gRestaurantManager.dateStage ~= C_RestaurantManager.DATE_STAGE.NORMAL_ORDER or gRestaurantManager.dateStage ~= C_RestaurantManager.DATE_STAGE.PET_ANIMAL_ORDER or gRestaurantManager.dateStage ~= C_RestaurantManager.DATE_STAGE.MAID_TEA_ORDER then
			gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
				["hw\\xa1r\\\\xbe\\xf3^^cnI"] = "/3\\xf0r\\x8d\\xe55\\xa6;\\xc9\\xe0\\xe2q\\xe9",
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

M.OpenMovieSelectPanel = function(cinemaId, locationId)
	local panelId = gLinkManager:CheckInLinkMode() and gPanelId.CINEMA_OL_MAIN_PANEL or gPanelId.S_CINEMA_MAIN_PANEL

	if gCS.LuaUtils.IsDebug and (LTConfig.CinemaConfig.GetConfig(cinemaId) ~= nil or LTConfig.CinemaLocationConfig.GetConfig(locationId) ~= nil) then
		print_error("OpenMovieSelectPanel get bad config id", cinemaId, locationId)
	end

	gPanelManager:CheckShow(panelId, {
		cinemaId = cinemaId,
		locationId = locationId
	})
end

M.Exercise1p = function(gymId)
	gGymManager:Exercise1p(gymId)
end

M.Exercise2p = function(gymId)
	gGymManager:Exercise2p(gymId)
end

M.ClawMachineStart = function(machineId)
	gClawMachineManager:StartPlayClawMachineById(machineId, C_ClawMachineManager.PLAY_MODE.SOLO)
end

M.ResetAllClawMachine = function()
	gCS.ClawMachineMgr:ResetAllClawMachine(false)
	gDialogManager:ShowGeneralDialog(ClawMachineConfig.ArrangeDialog, gDialogSource.ClawMachine)
end

M.ClawMachineInviteNpc = function(machineId)
	gClawMachineManager.npcRelatedMachineId = machineId
	gClawMachineManager.inviteMachineNpcId = M.currentNpc.NpcId

	gClientToGameDelegate:AskSimulationInviteNpc(GamePlayTypeConfig.ClawMachine)
end

M.ClawmachineStartDate = function(machineId)
	gClawMachineManager:StartPlayDateMachine(machineId)
end

M.WashWallInviteNpc = function()
	gClientToGameDelegate:AskSimulationInviteNpc(GamePlayTypeConfig.Washwall)
end

M.RowBoatInviteNpc = function()
	L50.Spoon.RowingGamePlayModule.Instance:StartRowBoatInviteNpc(M.currentNpc.Pid)
end

M.InviteMahjongRandom = function()
	gMaJiangManager:Spoon_InviteMahjong_AskInviteNpcRandom()
end

M.InviteMahjongFromChat = function()
	gClientToGameDelegate:AskSimulationInviteNpc(GamePlayTypeConfig.Mahjong)
end

M.MahjongRank = function()
	gMaJiangManager:OpenRankPanel()
end

M.SendMessage = function(messageId)
	gMessageManager:SendMessage(messageId)
end

M.TaskShortCutShowPhoto = function(showPictureImageId)
	local imgId = showPictureImageId

	if imgId then
		gUIUtils:CommonShowPhoto({
			imageId = imgId
		})
	end
end

M.TaskShortCutHackingScan = function()
	L50.L50App.Scene.ScanMgr:OnTriggerScan()
end

M.TaskShortCutShowTakePhotoUI = function()
	gTakePhotoUtils.TryTakePhoto()
end

M.ShowSelfIeModePhoto = function()
	gTakePhotoUtils.TryTakePhoto(nil, {
		["fe\\x9fr@\\xb4\\xdbBGuzI"] = true
	})
end

M.TaskShortCutOpenCallPhone = function()
	gMainPhoneFunctionAction.OpenCallPhone()
end

M.OpenPhonePanel = function(self)
	gClientUtils.OpenMainPhonePanel()
end

M.OpenGangsterMap = function()
	local params = {
		["hw\\xa2p_\\xa6\\xf7UGuzI"] = true
	}

	gMapUtils:CheckRaidCanOpenMap(params)
end

M.ChatFavorable = function()
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(M.currentNpc.Pid)

	if not npcSpawn then
		return
	end

	local cfgId = npcSpawn.spiritAcquisitionCfgId

	LifeScheduleInteract:FireStart(M.currentNpc, LifeScheduleInteract.Type.Chat)
	gSpiritAcquisitionManager:ChatFavorable(cfgId, M.currentNpc)
end

M.PhotoFavorable = function()
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(M.currentNpc.Pid)

	if not npcSpawn then
		return
	end

	LifeScheduleInteract:FireStart(M.currentNpc, LifeScheduleInteract.Type.Photo)
	gSpiritAcquisitionManager:TakePhotoFavorable(M.currentNpc)
end

M.GivePresentFavorable = function()
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(M.currentNpc.Pid)

	if not npcSpawn then
		return
	end

	local cfgId = npcSpawn.spiritAcquisitionCfgId

	LifeScheduleInteract:FireStart(M.currentNpc, LifeScheduleInteract.Type.Gift)
	gSpiritAcquisitionManager:GivePresentFavorable(cfgId, {
		disabled = gSpiritAcquisitionManager:GetPresentGiveState()
	})
end

M.OpenCharMotionPanel = function()
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(M.currentNpc.Pid)

	if not npcSpawn then
		return
	end

	LifeScheduleInteract:FireStart(M.currentNpc, LifeScheduleInteract.Type.CharMotion)
	gMainPhoneFunctionAction.OpenCharMotionPanel({
		showType = LTConfig.ActionItemTabConfig.ShowTypeType.Interaction,
		npcId = M.currentNpc.NpcId,
		npcPid = M.currentNpc.Pid
	})
end

M.CallCar = function(contactOptionId)
	gCallPhoneUtils.CallCar(contactOptionId)
end

M.StartStorage = function()
	gInteractionManager:UnitStartStorge(M.currentNpc)
end

M.CallMileCar = function(contactOptionId)
	gCallPhoneUtils.CallMilkCar(contactOptionId)
end

M.ReportAlarm = function(contactOptionId)
	gCallPhoneUtils.ReportAlarm(contactOptionId)
end

M.CheckContactOptionHasUnlock = function(contactOptionId)
	return gCallPhoneUtils.CheckContactOptionHasUnlock(contactOptionId)
end

M.ShowNpcFavourDialog = function(contactOptionId)
	if gClientUtils.CheckIsLinkMode() then
		return
	end

	gCallPhoneUtils.ShowNpcFavourDialog(contactOptionId)
end

M.CheckContainJobClassId = function(JobClassId)
	return gSpiritJobManager:CheckContainJobClassId(JobClassId)
end

M.CheckNotContainJobClassId = function(JobClassId)
	return not gSpiritJobManager:CheckContainJobClassId(JobClassId)
end

M.CheckCurrentRoleIsMatching = function(id)
	if type(id) ~= "number" then
		return gCS.MyPlayerManager.PlayerUnit.ClientData.SubType ~= id
	end

	if type(id) ~= "table" then
		local res = false

		for i, v in pairs(id) do
			res = res or gCS.MyPlayerManager.PlayerUnit.ClientData.SubType ~= v
		end

		return res
	end

	print_error("Dialog对话分支条件设置错误，CheckCurrentRoleIsMatching的输入值有问题，请检查。对话ID：" .. gDialogManager:GetCurrentDialogId())

	return true
end

M.CheckNotCurrentjob = function(JobClassId)
	return not gSpiritJobManager:CheckIsCurrentjob(JobClassId)
end

M.OpenChaosMasterNpc = function(npcId, gameMode)
	if gameMode ~= nil then
		gameMode = UX.Game.BVBGameModeType.BVBGameSimpleBrawl
	end

	gPanelManager:CheckShow(gPanelId.CHAOS_MASTER_PREVIEW_PANEL, {
		npcId = npcId,
		gameMode = gameMode
	})
end

M.PoliceHasFine = function(fineId)
	return gPoliceJobManager.examineMgr:HasFine(fineId)
end

M.EnterNpcQte = function()
	gCS.BaseUnitUtils.StartRidingInteract(gCS.MyPlayerManager.PlayerUnit.Pid, M.currentNpc.Pid, true)
end

M.Mount = function()
	gCS.BaseUnitUtils.Mount(M.currentNpc.Pid)
end

M.Dismount = function()
	gCS.BaseUnitUtils.Dismount()
end

M.DismountCheckScore = function()
	gCS.BaseUnitUtils.DismountCheckScore()
end

M.CheckMilkVehicleEnable = function()
	return gCallPhoneUtils.CheckMilkCarHasUnlocked() and not gLinkManager:CheckInMatchMode()
end

M.GetTaskEventState = function(eventId)
	local state = gTaskManager:GetTaskEventState(eventId)

	return state
end

M.InGameTimeRange = function(startHour, endHour)
	return L50.L50App.Scene.GamePlayUtils:IsInGameTimeRange(startHour, endHour)
end

M.OpenMatchPanel = function(matchId)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL, {
		modeId = matchId
	})
end

M.OpenMartialArtistPanel = function(challengeId)
	local challengeCfg = LTConfig.ChallengeConfig.GetConfig(challengeId or 0)

	if challengeCfg then
		if challengeCfg.ChallengeTag ~= LTConfig.ChallengeChallengeTagConfig.Zongshi then
			gPanelManager:CheckShow(gPanelId.ACHALLENGE_PANEL, challengeId)
		elseif challengeCfg.ChallengeTag ~= LTConfig.ChallengeChallengeTagConfig.Menpai then
			gPanelManager:CheckShow(gPanelId.BATTLE_CHALLENGE_PANEL, challengeId)
		else
			print_error("@hzliuyibing Martial artist(wushi) show panel by dialogfunc failed! Challenge tag is not Zongshi or Menpai! id is " .. tostring(challengeId))
		end
	end
end

M.IsMoneyMoreThan = function(x)
	return x > gPlayerManager.infoItem.bindData.money
end

M.IsMoneyLessThan = function(x)
	return gPlayerManager.infoItem.bindData.money <= x
end

M.ShowCommonGameplayTalentTree = function(gameplayId)
	gMainPageManager:LockMainPage(gPanelId.TALENT_TREE_PANEL)
	gItemHyperLinkManager:ShowCommonGameplayTalentTree(gameplayId)
end

M.OpenBuyHousePanel = function(houseId)
	local bigMapStore = gStoreManager:GetStoreGroup("NewMapPanelStore")

	if bigMapStore and bigMapStore.compRefs and bigMapStore.compRefs.Tooltip and bigMapStore.compRefs.Tooltip.CloseTooltip then
		bigMapStore.compRefs.Tooltip:CloseTooltip(true)
	end

	gMapSystem.notShowMainPageTabPanel = true
	local raidId = gMapManager:GetParentRaidId(gMapSystem.lastRaidId)
	local indoorId = gMapSystem.lastIndoorId

	if indoorId <= 0 then
		local indoorCfg = LTConfig.IndoorConfig.GetConfig(indoorId)

		if indoorCfg then
			raidId = indoorCfg.ParentRaid or LTConfig.RaidConfig.WorldMap
		else
			raidId = LTConfig.RaidConfig.WorldMap
		end
	end

	gPanelManager:CheckShow(gPanelId.S_NEW_MAP_PANEL, {
		["KHyzK3="] = true,
		["\\xa2\\xbf\\xa4e,\\xd77"] = 0,
		houseId = houseId,
		raidId = raidId
	})
end

M.ShowSubmitItem = function(submitItemId)
	gPanelManager:CheckShow(gPanelId.ITEM_DELIVERY_PANEL, {
		submitEventId = submitItemId
	})
end

M.OpenBringInItemPanel = function(gamePlayTypeId)
	gPanelManager:CheckShow(gPanelId.ITEM_DELIVERY_PANEL, {
		["\\x9d&)1\\xb4O\\xf48\\xae\\xbc"] = true,
		gamePlayTypeId = gamePlayTypeId
	})
end

M.OpenNpcInteractPanel = function()
	gPanelManager:CheckShow(gPanelId.AGENT_INTERACT_PANEL, {
		agentPid = M.currentNpc.Pid
	})
end

M.OpenGrandpaCreatePanel = function(npc)
	local target = npc or M.currentNpc
	local pid = target and target.Pid

	gOCMgr:OpenGrandpaCreate(pid)
end

M.OpenGrandpaMemoryPanel = function(npc)
	local target = npc or M.currentNpc
	local pid = target and target.Pid

	gOCMgr:OpenGrandpaMemory(pid)
end

M.EnterAnimalInteraction_Story = function(type)
	gAnimalManager:EnterAnimalInteraction_Story(M.currentNpc, type)
end

M.OpenCompoundMakePanel = function(craftingTableId)
	gPanelManager:CheckShow(gPanelId.COMPOUND_MAKE, {
		craftingTableId = craftingTableId
	})
end

M.EnterWushuTournament = function()
	gWushuTournamentManager:EnterWushuTournament()
end

M.OpenExtractionShooterMainPagePanel = function(gameTypeId)
	gExtractionShooterManager.OpenMainTabPagePanel(gameTypeId)
end

M.HyperLinkAction = function(hyperLinkId)
	local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

	gCommonItemManager:OnDescItemClick(_, hyperLinkInfo)
end

M.JumpExtractionShooterHomePage = function(args)
	gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_JUMP_HOME_PAGE, args)
end

M.StartNightRun = function(trackId)
	gPanelManager:CheckShow(gPanelId.COMMON_GAMEPLAY_START_PANEL, {
		playId = LTConfig.GameplayHudDescBeginConfig.NightRun,
		customData = {
			trackId = tonumber(trackId) or 0
		}
	})
end

gDialogScriptFunc = M
