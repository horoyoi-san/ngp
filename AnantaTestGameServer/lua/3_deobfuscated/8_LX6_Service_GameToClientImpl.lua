local MoneyType = UX.Game.MoneyType
local ConsumableConfig = LTConfig.ConsumableConfig
local MessageConfig = LTConfig.MessageConfig
local DropConfig = LTConfig.DropConfig
local ItemReason = UX.Game.ItemReason
local NPCChatGamePlayTypeConfig = LTConfig.NPCChatGamePlayTypeConfig
local GameToClientImpl = gRpcChecker:CreateRpcImpl()

function GameToClientImpl.SyncPlayerInfo(playerInfo)
	local status, err = xpcall(GameToClientImpl.SyncPlayerInfoProxy, tolua.traceback, playerInfo)

	gMessageManager:SendMessage(gEventConstants.JOB_CHANGE_EVENT)

	if not status then
		print_error_without_stack("SyncPlayerInfo error:", err)
	end
end

function GameToClientImpl.SyncPlayerInfoProxy(playerInfo)
	gPlayerManager:InitPlayerInfo(playerInfo)
	gSystemUnlockMgr:OnLogin()
	gMapSystem:SyncPlayerInfo(playerInfo)
	gSpiritManager:SyncPlayerInfoSpirit(playerInfo.InfoSpirit)
	gBattleSpiritMgr:SyncPlayerInfo(playerInfo.InfoSpirit)
	gPlayerItemManager:SetPlayerInfoItem(playerInfo.InfoItem)
	gEmojiManager:ReInit()
	gClueManager:OnLogin()
	gGuideMainPanelMgr:OnLogin()

	if gLuaUIMgr.uidLayerPanelStore then
		gLuaUIMgr.uidLayerPanelStore:RefreshUID()
	end

	gNpcChatManager:SyncPlayerInfo(playerInfo)
end

function GameToClientImpl.SyncSceneFogMapAllUnlock(sceneId, unlocked)
	LX6.Gps.MapFogDataMgr.SyncUnlockScene(sceneId, unlocked)
end

function GameToClientImpl.SyncMapRandomEventsList(randomDic, notAbortList)
	if gMapSubSystem_RangeEvent then
		gMapSubSystem_RangeEvent:SyncRuleDict(randomDic, notAbortList)
	end
end

function GameToClientImpl.SyncFactionHighLightEventList(eventIds)
	if gMapSubSystem_Faction then
		gMapSubSystem_Faction:SyncFactionHighLightEvents(eventIds)
	end
end

function GameToClientImpl.ShowTaskFailPanel(taskId, stateData, fromDead)
	gTaskManager:TryShowFailPanel(taskId, stateData, fromDead)
end

function GameToClientImpl.SyncFactionInfluenceAreaOccupy(areaId, occupy)
	if gMapSubSystem_Gangster then
		gMapSubSystem_Gangster:OnOccupyArea(areaId, occupy)
	end
end

function GameToClientImpl.SyncPlayerAddNewSpirit(spirit, reason)
	gSpiritManager:AddSpiritViewData(spirit)

	gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[spirit.SpiritInfo.TemplateId] = spirit.SpiritInfo.WeaponSlots
end

function GameToClientImpl.SyncSwitchSceneFailed(raidId, errorId)
	if errorId ~= MessageConfig.Ok then
		print_warn("SyncSwitchSceneFailed error", gCS.Error.GetNameById(errorId))
	end

	gRpcUtils.isSendingSwitchRaidRpc = false

	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
end

function GameToClientImpl.SyncMoney(money, gold, bindingGold)
	gPlayerManager.infoItem.bindData.lastMoney = gPlayerManager.infoItem.bindData.money
	gPlayerManager.infoItem.bindData.money = money
	gPlayerManager.infoItem.bindData.gold = gold
	gPlayerManager.infoItem.bindData.bindGold = bindingGold

	gMessageManager:SendMessage(gEventConstants.MONEY_CHANGE)
	gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
end

function GameToClientImpl.SyncMoneyAdd(moneyAdd, reason, silence)
	if not silence then
		local rewardItems = {}

		table.insert(rewardItems, {
			ItemId = gUIUtils:GetMoneyTypeId(MoneyType.Money),
			Count = moneyAdd
		})
		gDropManager:AddToNextFrameList({
			Rewards = rewardItems
		}, C_DropManager.DEFAULT_SHOW_TYPE)
	end
end

function GameToClientImpl.SyncMoneyRemove(moneyRemove)
	if moneyRemove > 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoseMoney, nil, nil, moneyRemove)
	end
end

function GameToClientImpl.SyncMoneyRemoveInfo(value, LogoId, textId, moneyEnough)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.PayTips, {
		Param = {
			value = value,
			logoId = LogoId,
			textId = textId,
			moneyEnough = moneyEnough
		}
	})
end

function GameToClientImpl.SyncGoldAdd(intention, bindGoldAdd, goldAdd, reason, silence)
	if not silence then
		local rewardItems = {}

		if goldAdd > 0 then
			table.insert(rewardItems, {
				ItemId = gUIUtils:GetMoneyTypeId(MoneyType.Gold),
				Count = goldAdd
			})
		end

		if bindGoldAdd > 0 then
			table.insert(rewardItems, {
				ItemId = gUIUtils:GetMoneyTypeId(MoneyType.BindingGold),
				Count = bindGoldAdd
			})
		end

		gDropManager:AddToNextFrameList({
			Rewards = rewardItems
		}, C_DropManager.DEFAULT_SHOW_TYPE)
	end
end

function GameToClientImpl.SyncGoldRemove(intention, bindGoldRemove, goldRemove)
	if goldRemove > 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoseGold, nil, nil, goldRemove)
	end

	if bindGoldRemove > 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoseBindGold, nil, nil, bindGoldRemove)
	end
end

function GameToClientImpl.SyncBackpackItemChanged(addList, updateList, deleteList)
	gPlayerItemManager:SetPackItem(addList, updateList, deleteList)
end

function GameToClientImpl.SyncItemDayCount(itemDayCount)
	gPlayerManager.infoItem.pack.itemUseTimes[itemDayCount.TemplateId] = itemDayCount.Count
end

function GameToClientImpl.SyncItemShortcut(ItemShortcutInfoDict, destructibleShortcut)
	gPlayerManager.infoItem.pack.itemShortcutDic = ItemShortcutInfoDict
	gPlayerManager.infoItem.pack.destructibleShortcut = destructibleShortcut

	gMessageManager:SendMessage(gEventConstants.ITEM_SHORTCUT_CHANGED)
end

function GameToClientImpl.ShowReceiveRewardDetail(msg)
	if msg.Reason == UX.Game.ItemReason.PoliceReturnInvalidVehicleFine then
		gPoliceJobManager:OnDropPoliceReturnInvalidVehicleFine()
	end

	gDropManager:ShowReceiveRewardDetail(msg)

	if msg.Reason == UX.Game.ItemReason.PoliceFine then
		gPoliceJobManager:OnDropPoliceJobExp(msg.Reward)
	end

	if msg.Reason == UX.Game.ItemReason.Diviner then
		gDivinerManager:OnDivinerDrop(msg)
	end

	if msg.Reason == UX.Game.ItemReason.TruckJob then
		gDeliveryTaskManager:SetTruckJobDrop(msg)
	end
end

function GameToClientImpl.SyncMallReceiveRewardDetail(msg)
	local rewardDetail = msg.Reward[gDropManager.RewardType.Normal] or {}
	local firstDetail = msg.Reward[gDropManager.RewardType.First]
	rewardDetail.Items = rewardDetail.Items or {}

	if firstDetail and firstDetail.Items then
		array.concat(rewardDetail.Items, firstDetail.Items)
	end

	local items = {}

	if rewardDetail.Items ~= nil and #rewardDetail.Items > 0 then
		for i = 1, #rewardDetail.Items do
			local item = rewardDetail.Items[i].ItemId
			local count = rewardDetail.Items[i].Count
			local conf = ConsumableConfig.GetConfig(item)
			local displayDrop = false

			if conf == nil then
				conf = ConsumableConfig.GetConfig(item)
			else
				displayDrop = conf.SubType == ConsumableTypeConfig.Use
			end

			if conf ~= nil then
				local dropConf = conf.Drop ~= nil and conf.Drop ~= 0 and DropConfig.GetConfig(conf.Drop) or nil

				if dropConf == nil or not displayDrop then
					table.insert(items, {
						ItemId = item,
						Count = count
					})
				else
					for j = 1, #dropConf.Item1 do
						table.insert(items, {
							ItemId = dropConf.Item1[j].id1,
							Count = dropConf.Item1[j].count * count
						})
					end

					if rewardDetail.BindingGold == nil then
						rewardDetail.BindingGold = 0
					end

					if rewardDetail.Money == nil then
						rewardDetail.Money = 0
					end

					rewardDetail.BindingGold = rewardDetail.BindingGold + dropConf.BindingGold * count
					rewardDetail.Money = rewardDetail.Money + dropConf.Money * count
				end
			end
		end
	end

	rewardDetail.Items = items

	gMessageManager:SendMessage(gEventConstants.MALL_RECEIEVE_ITEM, {
		item = msg
	})
end

function GameToClientImpl.ShowTaskChangePanel(oldCurrentId, newCurrentId)
	gTaskManager:ShowTaskChangePanel(oldCurrentId, newCurrentId)
end

function GameToClientImpl.SyncPlayerAllTask(taskInfos, submitTaskList, submitEventList, currentTask, eventPanelInfo, eventViewInfoList, loadingFinish)
	if currentTask > 0 then
		local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(currentTask)
		local CurrentTaskType = gTaskManager:GetCurrentTaskType(currentTask)
		gTaskNodeManager.NowDoingTask[CurrentTaskType] = currentTask
		gTaskNodeManager.NowDoingTaskLine[CurrentTaskType] = taskLineInfo and taskLineInfo.TaskLineId or nil
	end
end

function GameToClientImpl.SyncTemporaryCurrentTask(taskId, eventId, reason)
	gTaskManager:SyncTemporaryCurrentTask(taskId, eventId, reason)
end

function GameToClientImpl.SyncTaskTitleGuideUnlock(taskTitleId, unlocked)
	if gMapSystem and gMapSystem.taskUtils then
		gMapSystem.taskUtils:SetTaskTitleGuide(taskTitleId, unlocked)
	end
end

function GameToClientImpl.SyncActivateNpcCard(infocs)
	local npcCardId = infocs.TemplateId
	local newInfo = gNpcInteracsUtils:CreateNpcCardInfo(infocs, npcCardId)
	newInfo.TemplateId = npcCardId
	local info = gNpcInteracsUtils:GetNpcCultivationInfo(npcCardId)

	if info then
		for i, v in pairs(newInfo) do
			info[i] = v
		end
	else
		gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos[#gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos + 1] = newInfo
		gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfosDic[newInfo.TemplateId] = #gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos

		gNpcInteracsUtils:RemoveUnlockNpcCultivationInfo(npcCardId)
		gNpcChatManager:ReLoadNpcChatMsg(npcCardId)
	end

	gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)
end

function GameToClientImpl.SyncActivateLockedNpcCard(infocs)
	local npcCardId = infocs.TemplateId
	local newInfo = gNpcInteracsUtils:CreateNpcCardInfo(infocs, npcCardId)
	newInfo.TemplateId = npcCardId
	local info = gNpcInteracsUtils:GetUnlockedNpcCultivationInfo(npcCardId)

	if info then
		for i, v in pairs(newInfo) do
			info[i] = v
		end
	else
		gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos[#gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos + 1] = newInfo
		gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfosDic[newInfo.TemplateId] = #gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos
	end

	gSpiritAcquisitionManager:PopUpFavorUnlock(npcCardId)
end

function GameToClientImpl.SyncNpcUnlockVoice(npcCardId, voice)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId == npcCardId then
			list[i].UnlockedVoice[#list[i].UnlockedVoice + 1] = voice

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

function GameToClientImpl.SyncNpcInteractDays(npcCardId, days, lastTime)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId == npcCardId then
			list[i].InteractDays = days
			list[i].LastInteractTime = lastTime

			break
		end
	end
end

function GameToClientImpl.SyncNpcUnlockStory(npcCardId, story, unlockTime)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId == npcCardId then
			list[i].UnlockedStoryDict[story] = unlockTime

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

function GameToClientImpl.SyncNpcInteractedStory(npcCardId, story)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId == npcCardId then
			list[i].InteractedStories[#list[i].InteractedStories + 1] = story

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

function GameToClientImpl.SyncNpcInteractedVoice(npcCardId, voice)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId == npcCardId then
			list[i].InteractedVoices[#list[i].InteractedVoices + 1] = voice

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

function GameToClientImpl.SyncNpcTakeFavorReward(npcCardId, level)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId == npcCardId then
			list[i].FavorLevelReward = level

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

function GameToClientImpl.SyncNpcInteractedOuterStory(npcCardId, hasInteracted)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId == npcCardId then
			list[i].HasNoInteractedStory = hasInteracted

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

function GameToClientImpl.SyncNpcInteractedOuterVoice(npcCardId, hasInteracted)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId == npcCardId then
			list[i].HasUninteractedNpcVoice = hasInteracted

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

function GameToClientImpl.SyncNpcFavor(npcCardId, favorDiff, favor, gamePlayType)
	gNpcFavorManager:OnSyncNpcFavor(npcCardId, favorDiff, favor, gamePlayType)
end

function GameToClientImpl.SyncLockedNpcFavor(npcCardId, favorDiff, favor)
	gNpcFavorManager:OnSyncNpcFavor(npcCardId, favorDiff, favor, nil)
end

function GameToClientImpl.SyncNpcPhotoPosInfo(npcCardId, isGroup, posInfo)
	local info = gNpcInteracsUtils:TryGetNpcCultivationInfo(npcCardId)

	if not info then
		print_error("不存在或未同步的角色好感数据!npcCardId = ", npcCardId)

		return
	end

	if isGroup then
		info.GroupNpcPhotoPosList = posInfo
	else
		info.SingleNpcPhotoPosList = posInfo
	end
end

function GameToClientImpl.SyncNpcFirstChatPosInfo(npcCardId, posInfo)
	local info = gNpcInteracsUtils:TryGetNpcCultivationInfo(npcCardId)

	if not info then
		print_error("不存在或未同步的角色好感数据!npcCardId = ", npcCardId)

		return
	end

	info.FirstChatPosList = posInfo
end

function GameToClientImpl.SyncFavorNpcTimeTableInfos(vehicleIdDict)
	gNpcDaliyManager:OnSyncNpcTimeTableInfos(vehicleIdDict)
end

function GameToClientImpl.SyncMilkNpcFavor(value)
	return
end

function GameToClientImpl.SyncAllUnlockedVehicles(unlockedVehicles)
	gApplyCarManager:SyncAllUnlockedVehicles(unlockedVehicles)
end

function GameToClientImpl.SyncAllActivities(activities)
	gAwardActivityManager:OnSyncAwardActivity(activities)
end

function GameToClientImpl.SyncNewActivity(activity)
	gAwardActivityManager:OnSyncNewActivity(activity)
end

function GameToClientImpl.SyncActivityData(activityData)
	gAwardActivityManager:OnSyncActivityData(activityData)
end

function GameToClientImpl.SyncRemoveActivity(activityCfgId)
	gAwardActivityManager:OnRemoveActivity(activityCfgId)
end

function GameToClientImpl.SyncPlayerYesterdayAvgPopularity(popularity)
	gPlayerManager.infoMinor.bindData.popularityInfo.YesterdayAvgPopularity = popularity

	gMessageManager:SendMessage(gEventConstants.ON_PLAYER_POPULARITY_CHANGE)
end

function GameToClientImpl.SyncPlayerTempSpirits(tempSpirits)
	gSpiritManager:SyncPlayerTempSpirit(tempSpirits)
end

function GameToClientImpl.SyncPlayerAllSpirits(allSpirits)
	gSpiritManager:SyncPlayerAllSpirits(allSpirits)
end

function GameToClientImpl.SyncSpiritHackerJobInfo(spiritId, hackerJobInfo)
	gHackManager:SyncSpiritHackerJobInfo(spiritId, hackerJobInfo)
end

function GameToClientImpl.NotifyNewHackerPosts(spiritId)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.HackerNewTips)
end

function GameToClientImpl.SyncHackerBatteryCurrentAndTotalCount(hackInfo)
	gInteractionManager.hackInfo = hackInfo

	gMessageManager:SendMessage(gEventConstants.HACK_BATTERY_CHANGE, hackInfo)
end

function GameToClientImpl.SyncItemCountLimit(itemCountLimitList)
	gPlayerManager.infoItem.bindData.itemCountLimitInfoList = itemCountLimitList

	gCommonItemManager:RefreshItemCountLimit()
end

function GameToClientImpl.SyncReturnOverflowMaterial(overflowMaterials)
	gSpiritManager:SyncReturnOverflowMaterial(overflowMaterials)
end

function GameToClientImpl.SyncCurrentSpiritCardGroupIndex(index)
	gSpiritManager.currentGroupIndex = index
end

function GameToClientImpl.SyncChaosMasterBuffOptions(buffs)
	return
end

function GameToClientImpl.SyncMapEntrance(openEntrance, displayableEntrance)
	gMapUtils:SyncMapEntranceState(displayableEntrance, openEntrance)
end

function GameToClientImpl.UpdateMapEntrance(mapEntranceId, isOpen, isShow)
	gMapUtils:UpdateMapEntranceState(mapEntranceId, isOpen, isShow)
end

function GameToClientImpl.SyncBVBPokemonBreakthrough(pokemon)
	gBattlePetsMgr:SyncNewPet(pokemon)
end

function GameToClientImpl.KickOff(pid, suiteName, caseName, luastr)
	gClientQARunner:KickOff(pid, suiteName, caseName, luastr)
end

function GameToClientImpl.ShowLogInClient(pid)
	gClientQARunner:ShowLogInClient(pid)
end

function GameToClientImpl.ShowServerMessageIdWithArgs(msgId, args, para)
	gDisplayMessageMgr:DisplayServerMessageId_NeedCallback(msgId, args, para)
end

function GameToClientImpl.SyncEnterScene(enterInfo)
	gSceneManager:OnSyncEnterScene(enterInfo)
end

function GameToClientImpl.SyncShowMessage(messageId, args)
	gDisplayMessageMgr:ShowServerMessage(messageId, args)
end

function GameToClientImpl.SyncHasNotEarnedAchievement(count)
	gNewAchievementMgr:SyncHasNotEarnedAchievement(count)
end

function GameToClientImpl.SyncNewAchievement(id, detail)
	gNewAchievementMgr:OnSyncNewAchievement(id, detail)
end

function GameToClientImpl.SyncDiDiNextTask(taskId)
	return
end

function GameToClientImpl.SyncJobMissionStateChange(jobClass, active)
	gMessageManager:SendMessage(gEventConstants.JOB_MISSION_STATE_CHANGE, {
		job = jobClass,
		active = active
	})
end

function GameToClientImpl.SyncAddHouse(houseInfo)
	gBuyHouseUtils.SyncAddHouse(houseInfo)
end

function GameToClientImpl.SyncRemoveHouse(houseId)
	gBuyHouseUtils.SyncRemoveHouse(houseId)
end

function GameToClientImpl.SyncHouseParking(cancelInfoList, addInfoList)
	gGarageManager:SyncHouseParking(cancelInfoList, addInfoList)
end

function GameToClientImpl.SyncFurnitureInfo(furnitureId, count, placedCount)
	gBuyHouseUtils.SyncFurnitureInfo(furnitureId, count, placedCount)
end

function GameToClientImpl.SyncNewTuite(tuiteInfo)
	if gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.SocialNetworkId) then
		gSocialNetworkPopupManager:PushPopupInfo(tuiteInfo)
	end
end

function GameToClientImpl.SyncPlayerTwitterButton(twitterId, isOpen, secondShowType, showInteractionButton)
	gSocialNetworkUtils:SyncPlayerTwitterButton(twitterId, isOpen, secondShowType, showInteractionButton)
end

function GameToClientImpl.SyncTwitterMonitoredBehaviors(behaviors)
	gSocialNetworkUtils.SyncTwitterMonitoredBehaviors(behaviors)
end

function GameToClientImpl.SyncOpenTuitePanel(tuiteId)
	gPanelManager:CheckShow(gPanelId.YANJIE_APP_HOME_PANEL, {
		secondShowType = 1,
		id = tuiteId
	})
end

function GameToClientImpl.AddSpiritPhoneInfos(spiritId, phoneInfos)
	local spiritPhoneInfos = gPlayerManager.infoMinor.bindData.spiritPhoneInfos
	spiritPhoneInfos[spiritId] = phoneInfos
end

function GameToClientImpl.SyncPhoneAutoAddContact(phoneContactUnlockId, phoneInfo, selfSpiritId)
	local phoneContactUnlockCfg = LTConfig.PhoneContactUnlockConfig.GetConfig(phoneContactUnlockId)
	local spiritIdList = phoneContactUnlockCfg.SpiritIdList
	spiritIdList = #spiritIdList > 0 and spiritIdList or gCallPhoneUtils.GetAllSpiritIdList()

	for _, spiritId in ipairs(spiritIdList) do
		if selfSpiritId ~= spiritId and gCallPhoneUtils.TryGetPhoneInfos(spiritId) then
			gCallPhoneUtils.SyncAddPhoneContact(spiritId, {
				PhoneNumber = phoneInfo.PhoneNumber,
				Remark = phoneInfo.Remark
			})
		end
	end
end

function GameToClientImpl.SyncPhoneAutoDeleteContact(phoneContactUnlockId, phoneInfo, selfSpiritId)
	local phoneContactUnlockCfg = LTConfig.PhoneContactUnlockConfig.GetConfig(phoneContactUnlockId)
	local spiritIdList = phoneContactUnlockCfg.SpiritIdList
	spiritIdList = #spiritIdList > 0 and spiritIdList or gCallPhoneUtils.GetAllSpiritIdList()

	for _, spiritId in ipairs(spiritIdList) do
		if selfSpiritId ~= spiritId and gCallPhoneUtils.TryGetPhoneInfos(spiritId) then
			gCallPhoneUtils.SyncDeletePhoneContact(spiritId, {
				PhoneNumber = phoneInfo.PhoneNumber,
				Remark = phoneInfo.Remark
			})
		end
	end
end

function GameToClientImpl.SyncAddFashion(fashionInfo)
	gDressData:SyncAddFashion(fashionInfo)
end

function GameToClientImpl.SyncAddFashionList(fashionInfoList)
	gDressData:SyncAddFashionList(fashionInfoList)
end

function GameToClientImpl.SyncSetSpiritFashions(spiritId, spiritWearFashionsInfo)
	gDressData:SyncSetSpiritFashions(spiritId, spiritWearFashionsInfo)
end

function GameToClientImpl.SyncSetSpiritEnableTryWear(spiritId, enableClientTryWearCount)
	gDressData:SyncSetSpiritEnableTryWear(spiritId, enableClientTryWearCount)
end

function GameToClientImpl.SyncSetTaskTryWearFashionInfo(spiritId, taskTryWearInfo)
	gDressData:SyncSetTaskTryWearFashionInfo(spiritId, taskTryWearInfo)
end

function GameToClientImpl.SyncUnSetTaskTryWearFashionInfo(spiritId)
	gDressData:SyncUnSetTaskTryWearFashionInfo(spiritId)
end

function GameToClientImpl.SyncCollectionCountryUnlock(countryId)
	if gPlayerManager.infoAchievement and gPlayerManager.infoAchievement.bindData.UnlockedCountryList then
		local UnlockedCountryList = gPlayerManager.infoAchievement.bindData.UnlockedCountryList

		if array.contains(UnlockedCountryList, countryId) then
			return
		end

		table.insert(UnlockedCountryList, countryId)
	end
end

function GameToClientImpl.SyncCollectionQuestUnlock(questId)
	local UnlockedQuestList = gPlayerManager.infoAchievement.bindData.UnlockedQuestList

	if UnlockedQuestList == nil or array.contains(UnlockedQuestList, questId) then
		return
	end

	table.insert(UnlockedQuestList, questId)
	gMessageManager:SendMessage(gEventConstants.SYNC_COLLECTION_UNLOCK, {
		questId = questId
	})
end

function GameToClientImpl.SyncCompletedSubQuest(subQuestId)
	local SubQuest = gPlayerManager.infoAchievement.bindData.CompletedSubQuestCnt

	if SubQuest == nil then
		return
	end

	if SubQuest[subQuestId] == nil then
		SubQuest[subQuestId] = 0
	end

	SubQuest[subQuestId] = SubQuest[subQuestId] + 1

	gMessageManager:SendMessage(gEventConstants.SYNC_COLLECTION_GET)

	local id = gGpsTools.GetMapId(EMapElementType.Collection, subQuestId)

	gGpsManager:TryRemoveMapGuideById(id)
end

function GameToClientImpl.SyncFirstEnemyKillRecord(enemyKillRecord)
	gPlayerManager.infoAchievement.bindData.FirstKillEnemyRecord = enemyKillRecord
end

function GameToClientImpl.SyncCompletedChallenge(challengeRecord, rewardInfo)
	local currentMiniGameManager = gClientUtils.GetCurrentMiniGameManager()

	if currentMiniGameManager then
		currentMiniGameManager:DestroyGame()

		return
	end

	local challengeInfo = gPlayerManager.infoAchievement.bindData.ChallengeRecordInfo
	local hasRecord = false

	if challengeInfo then
		for i, v in pairs(challengeInfo) do
			if v.ChallengeId == challengeRecord.ChallengeId then
				v = challengeRecord
				hasRecord = true
			end
		end
	end

	if not hasRecord then
		table.insert(gPlayerManager.infoAchievement.bindData.ChallengeRecordInfo, challengeRecord)
	end
end

function GameToClientImpl.SyncPlayerClearTodayInspireHubGameplayJoinData()
	return
end

function GameToClientImpl.SyncPlayerInspireHubTodayGameplayJoinCount(gameplayId, count)
	return
end

function GameToClientImpl.SyncPlayerCompetitionSeason(seasonInfo)
	gInspireHubManager:SyncPlayerCompetitionSeason(seasonInfo)
end

function GameToClientImpl.SyncPlayerUpdateCompetitionSeasonData(seasonInfo)
	gInspireHubManager:SyncPlayerUpdateCompetitionSeasonData(seasonInfo)
end

function GameToClientImpl.SyncTraceGpsInfo(gpsInfo)
	return
end

function GameToClientImpl.SyncNpcGiftTagInfo(npcCardId, tagList)
	local info = gNpcInteracsUtils:TryGetNpcCultivationInfo(npcCardId)

	if not info then
		print_error("不存在或未同步的角色好感数据!npcCardId = ", npcCardId)

		return
	end

	info.ActiveGiftTags = tagList
end

function GameToClientImpl.SyncNpcInteractPointCount(count)
	gPlayerManager.infoMinorNpcCultivation.bindData.InteractPoint = count

	gMessageManager:SendMessage(gEventConstants.NPC_INVITE_POINT_CHANGE)
end

function GameToClientImpl.SyncNpcGiftSendAvailableCount(count)
	gPlayerManager.infoMinorNpcCultivation.bindData.availableGiftSendCount = count
end

function GameToClientImpl.SyncNpcChatJoinGameplay(npcId, gameplay)
	return
end

function GameToClientImpl.SyncTaskInviteRideNpcCultivationId(npcCultivationId)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_TASK_RIDE_NPC_CULTIVATION_ID, npcCultivationId)
end

function GameToClientImpl.SyncNpcChatLeaveGameplay(npcId, gameplay)
	gNpcChatManager:OnSyncNpcChatLeaveGameplay(npcId, gameplay)
end

function GameToClientImpl.SyncNpcChatInvite(gameplay)
	local params = {
		forceShow = true,
		npcInviteGamePlay = gameplay
	}

	gNpcChatUtils.OpenChatPanel(params)
end

function GameToClientImpl.SyncAnimalInfo(data)
	local animalInfos = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos
	local initAnimalInfo = false

	if animalInfos == nil then
		animalInfos = {}
		initAnimalInfo = true
		gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos = animalInfos
	end

	local count = 0
	local favorUp = false
	local updateInfo = 0

	for k, v in pairs(data) do
		count = count + 1
		local animalInfo = animalInfos[k]

		if animalInfo then
			if animalInfo.FavorLevel < v.FavorLevel or animalInfo.Favor < v.Favor or animalInfo.NickName ~= v.NickName then
				favorUp = true
				updateInfo = v
			end

			animalInfo.Favor = v.Favor
			animalInfo.FavorLevel = v.FavorLevel
			animalInfo.NickName = v.NickName
			animalInfo.Unlock = v.Unlock
			animalInfo.Interacted = v.Interacted
		else
			if not initAnimalInfo then
				favorUp = true
				updateInfo = v
			end

			animalInfo = {
				Id = v.Id,
				Favor = v.Favor,
				FavorLevel = v.FavorLevel,
				NickName = v.NickName,
				Unlock = v.Unlock,
				Interacted = v.Interacted
			}
			animalInfos[k] = animalInfo
		end
	end

	if count == 1 and favorUp then
		gAnimalManager:OnAnimalFavorChanged(updateInfo.Id)
	end

	gMessageManager:SendMessage(gEventConstants.ANIMAL_INFO_CHANGED)
end

function GameToClientImpl.SyncNewPokemon(pokemon)
	gBattlePetsMgr:SyncNewPet(pokemon)
end

function GameToClientImpl.SyncRemovePokemon(pokemonIdList)
	gBattlePetsMgr:SyncRemovePet(pokemonIdList)
end

function GameToClientImpl.SyncPokemonSquad(list)
	gBattlePetsMgr:SyncQuickSummonList(list)
end

function GameToClientImpl.SyncDropLimitInfo(dropId, info)
	gDropManager:OnSyncDropLimitNewInfo(dropId, info)
end

function GameToClientImpl.SyncDropLimitInfoRemove(dropId)
	gDropManager:OnSyncDropLimitNewInfo(dropId, nil)
end

function GameToClientImpl.SyncUpdatePokemonLockState(id, data)
	gBattlePetsMgr:SyncPetLockChange(id, data)
end

function GameToClientImpl.SyncHotSpringInfo(info)
	gHotSpringManager:OnSyncHotSpringInfo(info)
end

function GameToClientImpl.SyncCommodityInfo(infos)
	gMessageManager:SendMessage(gEventConstants.NPCSHOP_COMMODITYINFO_CHANGE, infos)
end

function GameToClientImpl.SyncClawDateInfo(data)
	gClawMachineManager:DateTaskBegin(data)
end

function GameToClientImpl.SyncClawDateOut()
	gClawMachineManager:DateTaskEnd()
end

function GameToClientImpl.SyncShowGuide(guide, counter)
	print_notice("GF Debug => Rpc SyncShowGuide guideId=", guide, " counter=", counter, Time.time, Time.frameCount)

	if guide == 0 then
		print_notice("GF Debug => Rpc SyncShowGuide 清理当前引导", counter, Time.time, Time.frameCount)
		gGFManager:UnActiveCurrentGuide()
	else
		print_notice("GF Debug => Rpc SyncShowGuide 激活新引导", counter, Time.time, Time.frameCount)
		gGFManager:ActiveGuide(guide, counter)
	end
end

function GameToClientImpl.SyncGuideTeachInfos(newGuideTeachInfos, rewardedGuideTeachInfos)
	local newInfo = gPlayerManager.infoMinor.bindData.NewGuideTeachInfos

	if not newInfo then
		newInfo = {}
		gPlayerManager.infoMinor.bindData.NewGuideTeachInfos = newInfo
	end

	for k, v in pairs(newInfo) do
		newInfo[k] = nil
	end

	for i = 1, newGuideTeachInfos.Length do
		newInfo[newGuideTeachInfos[i]] = true
	end

	newInfo.Count = newGuideTeachInfos.Length
	local rewardedInfos = gPlayerManager.infoMinor.bindData.RewardedGuideTeachInfos

	if not rewardedInfos then
		print_error("RewardedGuideTeachInfos未初始化")
	else
		for k, _ in pairs(rewardedInfos) do
			rewardedInfos[k] = nil
		end

		for i = 1, rewardedGuideTeachInfos.Length do
			rewardedInfos[rewardedGuideTeachInfos[i]] = true
		end

		rewardedInfos.Count = rewardedGuideTeachInfos.Length
	end

	gGuideMainPanelMgr:OnSyncNewGuideTeachInfos()
end

function GameToClientImpl.SyncMomentsNotify(info)
	gNewBubbleMgr:OnSyncNewNotify(info)
end

function GameToClientImpl.SyncUnlockSystems(unlockSystems)
	if not gPlayerManager.infoMinor.bindData.UnlockSystems then
		return
	end

	local unlockIds = {}

	for i = 1, unlockSystems.Length do
		table.insert(unlockIds, unlockSystems[i])

		gPlayerManager.infoMinor.bindData.UnlockSystems[unlockSystems[i]] = true
	end

	gSystemUnlockMgr:SetUnlockSystem(unlockIds)
	gMainMenuMgr:SetUnLockSystems()
end

function GameToClientImpl.SyncInvestigateGallery(galleryId, unlock, galleryInfo)
	if not unlock then
		table.removeEx(gPlayerManager.infoAchievement.bindData.UnlockInvestigateGalleryList, galleryId)
	else
		table.insert(gPlayerManager.infoAchievement.bindData.UnlockInvestigateGalleryList, galleryId)
	end

	if gMapSubSystem_Legend then
		gMapSubSystem_Legend:SyncGalleryUnlock(galleryId, unlock, galleryInfo)
	end
end

function GameToClientImpl.SyncCountryReputation(country, reputation)
	local dict = gPlayerManager.infoAchievement.bindData.CountryReputationInfo

	if not dict then
		dict = {}
		gPlayerManager.infoAchievement.bindData.CountryReputationInfo = dict
	end

	dict[country] = reputation
end

function GameToClientImpl.SyncFactionInfoChange(factionId, info, oldInfo, dropTextId)
	gFactionManager:OnFactionChange(factionId, info, oldInfo, dropTextId)
end

function GameToClientImpl.SyncFactionInfosChange(changeInfos, dropTextId)
	gFactionManager:OnFactionsChange(changeInfos, dropTextId)
end

function GameToClientImpl.SyncLinkInvite(friendPid, mode)
	gLinkManager:OnBeInviteToLink(friendPid, mode)
end

function GameToClientImpl.SyncLinkKicked(kickedByPid)
	gLinkManager:OnKickOut(kickedByPid)
end

function GameToClientImpl.SyncCurrentLinkMode(mode)
	gLinkManager:OnChangeLinkMode(mode)
end

function GameToClientImpl.SyncLinkMatchRoomPrepare(roomId, prepareRoom)
	gLinkManager:OnSyncLinkMatchRoomPrepare(roomId, prepareRoom)
end

function GameToClientImpl.SyncMatchRoomInvite(pid, gameId, roomId)
	gLinkManager:OnBeInviteToRoom(pid, gameId, roomId)
end

function GameToClientImpl.SyncMatchRoomKicked()
	gLinkManager:OnBeKickOutFromRoom()
end

function GameToClientImpl.SyncMatchInfo(matchInfo)
	gLinkManager:OnGetMatchInfo(matchInfo)
end

function GameToClientImpl.SyncFerrisWheelInfo(infos)
	gFerrisMgr.ticketTypeList = {}

	if not infos then
		return
	end

	for gameTypeId, ticketType in pairs(infos) do
		if not ticketType then
			return
		end

		gFerrisMgr:SetTicketType(gameTypeId, ticketType)
	end
end

local function ResetEventConditionProgress(eventConditionIdList, progressInfo)
	if not progressInfo then
		return
	end

	local finishedTemplateIdList = progressInfo.FinishedTemplateIdList

	if finishedTemplateIdList then
		for index = finishedTemplateIdList.Count, 1, -1 do
			local finishedTemplateId = finishedTemplateIdList[index]

			if table.contains(eventConditionIdList, finishedTemplateId) then
				table.remove(finishedTemplateIdList, index)

				finishedTemplateIdList.Count = finishedTemplateIdList.Count - 1
				finishedTemplateIdList.Length = finishedTemplateIdList.Length - 1
			end
		end
	end

	local eventProgressInfoDict = progressInfo.EventProgressInfoDict

	if eventProgressInfoDict then
		for templateId, _ in pairs(eventProgressInfoDict) do
			if table.contains(eventConditionIdList, templateId) then
				eventProgressInfoDict[templateId] = nil
			end
		end
	end
end

function GameToClientImpl.SyncResetEventConditionProgress(module, eventConditionIdList, spiritId)
	local curModuleEventProgressInfoDict = gPlayerManager.infoMinor.bindData.ModuleEventProgressInfoDict

	if not curModuleEventProgressInfoDict then
		return
	end

	local curModuleEventProgressInfo = curModuleEventProgressInfoDict[module]

	if not curModuleEventProgressInfo then
		curModuleEventProgressInfo = {
			ProgressInfoDict = {}
		}
		curModuleEventProgressInfoDict[module] = curModuleEventProgressInfo
	elseif spiritId == gClientConst.MAX_INT then
		for _, progressInfo in pairs(curModuleEventProgressInfo.ProgressInfoDict) do
			ResetEventConditionProgress(eventConditionIdList, progressInfo)
		end
	else
		local progressInfo = curModuleEventProgressInfo.ProgressInfoDict[spiritId]

		ResetEventConditionProgress(eventConditionIdList, progressInfo)
	end

	gMessageManager:SendMessage(gEventConstants.ON_EVENT_CONDITION_PROGRESS_CHANGE)
end

function GameToClientImpl.SyncChangeEventConditionProgress(module, spiritId, changeEventProgressInfoDict, finishEventConditionIdList)
	local curModuleEventProgressInfoDict = gPlayerManager.infoMinor.bindData.ModuleEventProgressInfoDict
	local curModuleEventProgressInfo = curModuleEventProgressInfoDict[module]

	if not curModuleEventProgressInfo then
		curModuleEventProgressInfo = {
			ProgressInfoDict = {}
		}
		curModuleEventProgressInfoDict[module] = curModuleEventProgressInfo
	end

	local curProgressInfo = curModuleEventProgressInfo.ProgressInfoDict[spiritId]

	if not curProgressInfo then
		curProgressInfo = {
			EventProgressInfoDict = {},
			FinishedTemplateIdList = {
				Count = 0,
				Length = 0
			}
		}
		curModuleEventProgressInfo.ProgressInfoDict[spiritId] = curProgressInfo
	end

	if changeEventProgressInfoDict then
		for eventConditionId, eventProgressInfo in pairs(changeEventProgressInfoDict) do
			curProgressInfo.EventProgressInfoDict[eventConditionId] = eventProgressInfo
			local finishedTemplateIdList = curProgressInfo.FinishedTemplateIdList

			for idx, finishedTemplateId in ipairs(finishedTemplateIdList) do
				if finishedTemplateId == eventConditionId then
					table.remove(finishedTemplateIdList, idx)

					finishedTemplateIdList.Count = finishedTemplateIdList.Count - 1
					finishedTemplateIdList.Length = finishedTemplateIdList.Length - 1

					break
				end
			end
		end
	end

	if finishEventConditionIdList then
		for _, eventConditionId in ipairs(finishEventConditionIdList) do
			curProgressInfo.EventProgressInfoDict[eventConditionId] = nil
			local finishedTemplateIdList = curProgressInfo.FinishedTemplateIdList

			table.insert(finishedTemplateIdList, eventConditionId)

			finishedTemplateIdList.Count = finishedTemplateIdList.Count + 1
			finishedTemplateIdList.Length = finishedTemplateIdList.Length + 1
		end

		gEventConditionUtils.NotifyModuleUnlocked(module, finishEventConditionIdList)
	end

	gMessageManager:SendMessage(gEventConstants.ON_EVENT_CONDITION_PROGRESS_CHANGE)
end

function GameToClientImpl.SyncSpiritAbilityInfo(spiritId, info)
	gSpiritManager:SyncSpiritAbilityInfo(spiritId, info)
end

function GameToClientImpl.SyncUrbanBadgeInfo(badgeId, badgeInfo)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(badgeInfo.TemplateId)

	if not cfg or cfg.OnlyServer then
		return
	end

	local isShowPopUp = false
	local badges = gPlayerManager.infoMinor.bindData.Badges
	local curBadgeInfo = badges[badgeId]

	if not curBadgeInfo then
		isShowPopUp = true
	end

	if badgeInfo then
		badges[badgeInfo.TemplateId] = badgeInfo
	else
		badges[badgeId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_URBAN_BADGEINFO)

	if isShowPopUp then
		gSpiritManager:PushPopWait(badgeInfo)
	end
end

function GameToClientImpl.SyncSpiritBadgeInfo(spiritId, badgeId, badgeInfo)
	gSpiritManager:SyncSpiritBadgeInfo(spiritId, badgeId, badgeInfo)
end

function GameToClientImpl.SyncSpiritJobInfo(spiritId, availableJobs, currentJob)
	gSpiritManager:SyncSpiritJobInfo(spiritId, availableJobs, currentJob)
	gMessageManager:SendMessage(gEventConstants.JOB_CHANGE_EVENT, currentJob)
end

function GameToClientImpl.SyncPoliceNextOrder(id, eventId, selected, isComplete)
	if not isComplete then
		if not selected then
			gPoliceJobManager:PoliceTaskRecover(id, eventId)
		else
			print_debug("同步警察订单")

			if gTaskUtils:GetTaskGuideCurType() ~= gTaskUtils.TaskGuideSubPanel.Police then
				gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
			end

			gMessageManager:SendMessage(gEventConstants.POLICE_TASK_DISTRIBUTE, {
				id = id,
				eventId = eventId
			})
		end
	else
		gMessageManager:SendMessage(gEventConstants.POLICE_DROP_EVENT)
	end
end

function GameToClientImpl.SyncPoliceMissionExamInfo(factIds, examTaskId, examIndex)
	gPoliceJobManager:SendMessageToPanel(function ()
		gMessageManager:SendMessage(gEventConstants.POLICE_FACT_START, {
			factIds = factIds,
			examTaskId = examTaskId,
			examIndex = examIndex
		})
	end)
end

function GameToClientImpl.SyncPoliceChargingSkillProgress(progress, maxLayer, speed)
	gPoliceChaseManager:SyncPoliceChargingSkillProgress(progress, maxLayer, speed)
end

function GameToClientImpl.SyncSpiritHistoryJobInfo(spiritId, historyJobs)
	gSpiritManager:SyncSpiritHistoryJobInfo(spiritId, historyJobs)
end

function GameToClientImpl.SyncPlayerFanInfo(fan12, fan123, level, levelRewardList, yesterdayFan)
	local preFan12 = gPlayerManager.infoMinor.bindData.fan12
	local preFan123 = gPlayerManager.infoMinor.bindData.fan123
	local preLevel = gPlayerManager.infoMinor.bindData.level
	local isLevelUp = preLevel ~= level
	local isFanChange = preFan12 ~= fan12
	gPlayerManager.infoMinor.bindData.fan123 = fan123
	gPlayerManager.infoMinor.bindData.fan12 = fan12
	gPlayerManager.infoMinor.bindData.yesterdayFan = yesterdayFan
	gPlayerManager.infoMinor.bindData.level = level
	gPlayerManager.infoMinor.bindData.levelRewardList = levelRewardList

	gSocialNetworkUtils:FansChangeRecord(preFan123)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PLAYER_FAN_INFO)
	gMessageManager:SendMessage(gEventConstants.ON_PLAYER_FAN_CHANGE, {
		preExp = preFan123,
		currentExp = fan123
	})

	if gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.SocialNetworkId) and isFanChange then
		if isLevelUp then
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_CommonFansLevelUpPanel, {
				preExp = preFan123,
				currentExp = fan123
			})
		else
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.FansReward, {
				preExp = preFan12,
				currentExp = fan12
			})
		end
	end
end

function GameToClientImpl.SyncPlayerNpcProfileActivate(profileInfo)
	gAgentTrustManager:PopUpAgentProfile(profileInfo)
	gAgentTrustManager:UpdateProfileInfo(profileInfo)
end

function GameToClientImpl.SyncPlayerNpcProfileTargetFinish(profileId, target)
	gAgentTrustManager:UpdateNpcProfileTargetFinish(profileId, target.TargetId)
end

function GameToClientImpl.SyncPlayerNpcProfileRewardGot(profileId, rewardId)
	gAgentTrustManager:UpdateNpcProfileRewardGot(profileId, rewardId)
end

function GameToClientImpl.SyncPlayerNpcProfileTrustValueChanged(info)
	if info.Reason == UX.Game.ItemReason.NpcProfileTarget then
		gAgentTrustManager:PopUpAgentProfileTrustChange(info.ProfileId, gAgentTrustManager:GetTrustValue(info.ProfileId), info.TrustValue)
	end

	gAgentTrustManager:UpdateNpcProfileTrustValue(info)
end

function GameToClientImpl.SyncPlayerNpcProfileMultiTrustValueChanged(infos)
	for _, info in ipairs(infos) do
		if info.Reason == UX.Game.ItemReason.NpcProfileTarget then
			gAgentTrustManager:PopUpAgentProfileTrustChange(info.ProfileId, gAgentTrustManager:GetTrustValue(info.ProfileId), info.TrustValue)
		end

		gAgentTrustManager:UpdateNpcProfileTrustValue(info)
	end
end

function GameToClientImpl.SyncPlayerPopularity(currPopularity, historyList, underflowPopularity)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo then
		popularityInfo.Popularity = currPopularity
		popularityInfo.HistoryPopularityList = historyList
		popularityInfo.UnderflowPopularity = underflowPopularity

		gMessageManager:SendMessage(gEventConstants.ON_PLAYER_POPULARITY_CHANGE)
	end
end

function GameToClientImpl.SyncPlayerPopularityChange(currPopularity, incrementPopularityList, _)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo then
		popularityInfo.Popularity = currPopularity
		local historyPopularityList = popularityInfo.HistoryPopularityList or {}

		for _, incrementPopularity in ipairs(incrementPopularityList) do
			table.insert(historyPopularityList, incrementPopularity)
		end

		popularityInfo.HistoryPopularityList = historyPopularityList

		gMessageManager:SendMessage(gEventConstants.ON_PLAYER_POPULARITY_CHANGE)
	end
end

function GameToClientImpl.SyncAcceptTruckJobOrder(id, orderInfo, deliveryAgentId)
	orderInfo.npcInstanceId = deliveryAgentId

	gMessageManager:SendMessage(gEventConstants.ON_ACCEPT_TRUCK_JOB_ORDER, orderInfo)
	gMessageManager:SendMessage(gEventConstants.REFRESH_DELIVERY_DATA, {
		UniqueId = orderInfo.UniqueId,
		AcceptInfo = orderInfo.AcceptInfo
	})
end

function GameToClientImpl.SyncTruckHighValueOrder(order)
	gMessageManager:SendMessage(gEventConstants.HIGH_VALUE_ORDER, order)
end

function GameToClientImpl.SyncSpiritTalentExpAndLevel(spiritId, addExp, exp, level)
	gTalentTreeMgr:OnSyncSpiritTalentExpAndLevel(spiritId, addExp, exp, level)
end

function GameToClientImpl.SyncSpiritJobTalentPoint(spiritId, jobClassId, talentPoint, reason)
	gTalentTreeMgr:OnSyncSpiritJobTalentPoint(spiritId, jobClassId, talentPoint, reason)
end

function GameToClientImpl.SyncCommonSpiritTalentExp(changeExp, exp)
	gTalentTreeMgr:OnSyncCommonTalentInfo(changeExp, exp)
end

function GameToClientImpl.SyncActiveSpiritJobTalentLayer(spiritId, jobClassId, talentId, layer)
	gTalentTreeMgr:OnSyncActiveSpiritJobTalent(spiritId, jobClassId, talentId, layer)
end

function GameToClientImpl.SyncPlayerPopularityAdd(popularityAdd, totalLeftMoney, walletRewardList, dropList, pastHoursCoinRewards)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo then
		popularityInfo.TotalLeftMoney = totalLeftMoney
		popularityInfo.WalletRewards = walletRewardList
		popularityInfo.PastHoursCoinRewards = pastHoursCoinRewards

		gMessageManager:SendMessage(gEventConstants.ON_PLAYER_POPULARITY_CHANGE)
	end
end

function GameToClientImpl.SyncFavorNpcSpoonAgentId(agentTag, spoonAgentId, Position, isAtTemporaryPosition)
	gNpcDaliyManager:OnSyncFavorNpcSpoonAgentId(agentTag, spoonAgentId, Position, isAtTemporaryPosition)
end

function GameToClientImpl.SyncPlayerProduceInfo(availableProduces)
	gProduceManager:SetAvailableProduces(availableProduces)
end

function GameToClientImpl.SyncTruckOrderResult(truckJobOrderWrap, preRankId, newRankId, rewardPoint)
	gMessageManager:SendMessage(gEventConstants.ON_TRUCK_ORDER_COMPLETED, truckJobOrderWrap)
	gDeliveryTaskManager:CompleteTruckOrder(truckJobOrderWrap, preRankId, newRankId, rewardPoint)
end

function GameToClientImpl.SyncComputerNewUnlockEmail(computerEmail)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	if computerUnlockInfo then
		computerUnlockInfo.UnlockEmails[computerEmail.CfgId] = computerEmail
	end
end

function GameToClientImpl.SyncComputerNewUnlockFile(computerFile)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	if computerUnlockInfo then
		computerUnlockInfo.UnlockFiles[computerFile.CfgId] = computerFile
	end
end

function GameToClientImpl.SyncPoliceExamReaction(reactionId)
	gPoliceJobManager:SyncPoliceExamReaction(reactionId)
end

function GameToClientImpl.SyncPoliceServiceData(spiritId, serviceData, weeklyServiceData, stopPatrol)
	gPoliceJobManager.panelMgr:OnPoliceServiceDataSync(spiritId, serviceData, weeklyServiceData)
	gPoliceJobManager:OpenPoliceEndPanel(spiritId, serviceData, stopPatrol)
end

function GameToClientImpl.SyncSpiritPoliceJobInfo(spiritId, policeJobInfo)
	gPoliceJobManager.panelMgr:OnSpiritPoliceJobInfoSync(spiritId, policeJobInfo)
end

function GameToClientImpl.SyncSpiritPoliceCaseInfos(spiritId, cases)
	gPoliceJobManager.panelMgr:OnSpiritPoliceCaseInfosSync(spiritId, cases)
end

function GameToClientImpl.SyncSpiritPoliceViolationInfos(spiritId, violations)
	gPoliceJobManager.panelMgr:OnSpiritPoliceViolationInfosSync(spiritId, violations)
end

function GameToClientImpl.SyncPoliceDispatchInfos(spiritId, dispatchInfos)
	gPoliceJobManager.panelMgr:OnPoliceDispatchInfosSync(spiritId, dispatchInfos)
end

function GameToClientImpl.SyncPoliceFakeFileInfo(spiritId, policeFakeFileInfo)
	gPoliceJobManager.panelMgr:OnSyncPoliceFakeFileInfo(spiritId, policeFakeFileInfo)
end

function GameToClientImpl.SyncPoliceFakeFileSingleInfo(spiritId, fakeFileId, agentId, curClueValue, fakeFileState)
	gPoliceJobManager.panelMgr:OnSyncPoliceFakeFileSingleInfo(spiritId, fakeFileId, agentId, curClueValue, fakeFileState)
end

function GameToClientImpl.SyncTruckOrdersNewDay()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_TRUNK_ORDER_NEW_DAY)
end

function GameToClientImpl.SyncTruckAbortedOrder(id)
	gMessageManager:SendMessage(gEventConstants.ON_TRUCK_ORDER_OBSOLETED, id)
end

function GameToClientImpl.SyncTruckOrderWrap(order)
	gDeliveryTaskManager:ModifyOrderCargoInfo(order)
end

function GameToClientImpl.SyncCurrentTruckOrder(id)
	gDeliveryTaskManager:ChangeCurOrderByUniqueId(id)
	gMessageManager:SendMessage(gEventConstants.ON_CURRENT_TRUCK_ORDER_CHANGE, id)
end

function GameToClientImpl.SyncAllAcceptTruckOrder(orderInfo)
	return
end

function GameToClientImpl.SyncSpiritBeggarJobData(spiritId, data)
	gBeggarManager:OnSyncSpiritBeggarJobData(spiritId, data)
end

function GameToClientImpl.SyncSpiritGroupChatInfos(chats)
	gUrbanAbilityManager:SyncSpiritGroupChatInfos(chats)
end

function GameToClientImpl.SyncSpiritMobileSkinPartInfo(spiritId, mobileSkinInfo, availableSkinParts)
	local spiritViewData = gSpiritManager:GetSpirit(spiritId)

	if spiritViewData and spiritViewData.SpiritInfo then
		spiritViewData.SpiritInfo.MobileSkinInfo = mobileSkinInfo
	end

	if availableSkinParts then
		gPlayerManager.infoSpirit.bindData.AvailableSkinParts = availableSkinParts
	end

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_SPIRIT_SKIN_PART_INFO_CHANGE)
end

function GameToClientImpl.SyncQuantumWalletInfo(quantumWalletStartTime)
	gCommonItemManager:OnSyncQuantumWalletInfo(quantumWalletStartTime)
end

function GameToClientImpl.SyncUnlockInteractionActionItems(newActionItemList)
	local playerInteractionActionInfo = gPlayerManager.infoMinor.bindData.playerInteractionActionInfo

	if playerInteractionActionInfo then
		local unlockActionItemMap = playerInteractionActionInfo.UnlockActionItemDict or {}

		for _, newActionItem in ipairs(newActionItemList) do
			unlockActionItemMap[newActionItem.CfgId] = newActionItem
		end

		playerInteractionActionInfo.UnlockActionItemDict = unlockActionItemMap

		gMessageManager:SendMessage(gEventConstants.ON_ACTION_ITEMS_CHANGE)
	end
end

function GameToClientImpl.SyncAgentCureReaction(reactionId)
	gDoctorManager:SyncAgentCureReaction(reactionId)
end

function GameToClientImpl.SyncDivinerCustomerInfo(customerInfo)
	gDivinerManager:OnSyncDivinerCustomerInfo(customerInfo)
end

function GameToClientImpl.SyncDivinerAIError(agentId, stage, error)
	gDivinerManager:OnSyncDivinerAIError(agentId, stage, error)
end

function GameToClientImpl.SyncDivinerAIMessage(info)
	gDivinerManager:OnSyncDivinerAIMessage(info)
end

function GameToClientImpl.SyncPortalItemInfo(raidId, position)
	gMapUtils:SyncPortalItem(raidId, position)
end

function GameToClientImpl.SyncArmoryAddWeapon(weapon)
	gPlayerManager.infoSpirit.bindData.ArmoryWeapons[weapon.InstanceId] = weapon

	gMessageManager:SendMessage(gEventConstants.ARMORY_WEAPON_ADD, {
		Weapon = weapon,
		TemplateId = weapon.TemplateId
	})
end

function GameToClientImpl.SyncArmoryRemoveWeapon(id)
	local weapon = gPlayerManager.infoSpirit.bindData.ArmoryWeapons[id]

	if weapon then
		gPlayerManager.infoSpirit.bindData.ArmoryWeapons[id] = nil

		gMessageManager:SendMessage(gEventConstants.ARMORY_WEAPON_REMOVE, {
			InstanceId = id,
			TemplateId = weapon.TemplateId
		})
	end
end

function GameToClientImpl.PushJoinNewChatGroup(chatGroup)
	gChatGroupManager:PushJoinNewChatGroup(chatGroup)
end

function GameToClientImpl.PushPlayerImSimpleData(simpleData)
	gChatGroupManager:PushPlayerImSimpleData(simpleData)
end

function GameToClientImpl.SyncInviteeInvitePlayerInteractionAction(pid, actionId)
	gCharMotionUtils.InvitePlayerInteractionAction(pid, actionId)
end

function GameToClientImpl.SyncInviterReplyInvitePlayerInteractionAction(isAccept)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_MOTION_ACTION_REPLAY_INVITE_RESULT, isAccept)
end

function GameToClientImpl.SyncCancelInviterPlayerInteractionAction(interactionActionState)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_CANCEL_INVITE_PLAYER_ACTION, interactionActionState)
end

function GameToClientImpl.SyncCancelInviteePlayerInteractionAction(interactionActionState)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_CANCEL_INVITEE_PLAYER_ACTION, interactionActionState)
end

function GameToClientImpl.SyncStartPlayerInteractionAction(ownerId)
	gCharMotionUtils.SyncInviteeStartPlayAction(ownerId)
end

function GameToClientImpl.SyncInviterPlayerInteractionAction(inviterState, inviteePid, actionItemId)
	if inviterState == UX.Game.InteractionActionState.Playing then
		gClientToGameDelegate:AskCancelInviterPlayerInteractionAction().Callback = function (errorId)
			return
		end
	end
end

function GameToClientImpl.SyncClearNpcGroupChatInfo(groupId)
	gNpcChatManager:ClearNpcGroupChatInfo(groupId)
end

function GameToClientImpl.SyncClearNpcChatInfo(npcId)
	gNpcChatManager:ClearNpcChatInfo(npcId)
end

function GameToClientImpl.SyncNpcChat(chatItem)
	gNpcChatManager:AddNewNpcChatItem(chatItem)
end

function GameToClientImpl.SyncNpcChats(chatItems)
	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_MESSAGE_SKIP_ALL, chatItems)
end

function GameToClientImpl.SyncRemoveNpcChat(chatId, asNpc)
	gNpcChatManager:RemoveNpcChatSegment(chatId, asNpc)
end

function GameToClientImpl.SyncNewNpcQueueEvent(eventInfo)
	gNpcDaliyManager:OnNewQueueEvent(eventInfo)
end

function GameToClientImpl.SyncRemoveNpcQueueEvent(eventId)
	gNpcDaliyManager:OnQueueEventRemove(eventId)
end

function GameToClientImpl.SyncNpcTodayEventsTriggerCount(totalTodayCount, lastTriggerTime, npcId, npcTodayCount)
	gNpcDaliyManager:OnQueueEventTriggerChange(totalTodayCount, lastTriggerTime, npcId, npcTodayCount)
end

function GameToClientImpl.SyncResetNpcEventsTriggerCount()
	gNpcDaliyManager:OnQueueEvenetReset()
end

function GameToClientImpl.SyncPlayerTeamInfo(teaminfo)
	gTeamManager:SyncPlayerTeamInfo(teaminfo)
end

function GameToClientImpl.SyncPlayerJoinTeam(teamInfo)
	gTeamManager:SyncPlayerJoinTeam(teamInfo)
end

function GameToClientImpl.SyncPlayerTeamSettingChange(teamId, setting)
	gTeamManager:SyncPlayerTeamSettingChange(teamId, setting)
end

function GameToClientImpl.SyncPlayerCreateTeam(teamInfo)
	gTeamManager:SyncPlayerCreateTeam(teamInfo)
end

function GameToClientImpl.SyncPlayerTeamMemberLeave(teamId, playerInfo)
	gTeamManager:SyncPlayerTeamMemberLeave(teamId, playerInfo)
end

function GameToClientImpl.SyncPlayerTeamMemberKick(teamId, playerInfo)
	gTeamManager:SyncPlayerTeamMemberKick(teamId, playerInfo)
end

function GameToClientImpl.SyncPlayerTeamMemberJoin(teamId, playerInfo)
	gTeamManager:SyncPlayerTeamMemberJoin(teamId, playerInfo)
end

function GameToClientImpl.SyncPlayerTeamLeaderChange(teamId, playerInfo)
	gTeamManager:SyncPlayerTeamLeaderChange(teamId, playerInfo)
end

function GameToClientImpl.SyncPlayerInviteToTeam(playerInfo, teamId)
	gTeamManager:SyncPlayerInviteToTeam(playerInfo, teamId)
end

function GameToClientImpl.SyncPlayerResponseTeamInvite(playerInfo, teamId, reject)
	gTeamManager:SyncPlayerResponseTeamInvite(playerInfo, teamId, reject)
end

function GameToClientImpl.SyncPlayerTeamInvitationApply(teamId, inviter, invitee)
	gTeamManager:SyncPlayerTeamInvitationApply(teamId, inviter, invitee)
end

function GameToClientImpl.SyncPlayerTeamApply(teamId, applier)
	gTeamManager:SyncPlayerTeamApply(teamId, applier)
end

function GameToClientImpl.SyncPlayerChangeLeaderApply(teamId, applier)
	gTeamManager:SyncPlayerChangeLeaderApply(teamId, applier)
end

function GameToClientImpl.SyncUnlockPhoneContactOptions(ids)
	gCallPhoneUtils.SyncPhoneUnlockOptionIdList(ids)
end

function GameToClientImpl.SyncInviteePlayerInteractionAction(inviterState, inviteePid, actionItemId)
	if inviterState == UX.Game.InteractionActionState.Playing then
		gClientToGameDelegate:AskCancelInviteePlayerInteractionAction().Callback = function (errorId)
			return
		end
	end
end

function GameToClientImpl.SyncNewCityPediaInfo(cityPediaId)
	gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CityPedia2IsReadDict[cityPediaId] = true
end

function GameToClientImpl.SyncCityPediaCreditInfo(creditInfo)
	gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CreditInfo = creditInfo

	gMessageManager:SendMessage(gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE)
end

function GameToClientImpl.SyncCityPediaCreditUpdate(newTotalCredit, newLevel, itemType, itemId)
	local creditInfo = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CreditInfo

	if creditInfo then
		creditInfo.Credit = newTotalCredit
		creditInfo.Level = newLevel

		gMessageManager:SendMessage(gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE)
		gBaiKeArchiveManager.RefreshBaikePhoneAppRedDot()
	end
end

function GameToClientImpl.SyncCityPediaBasicCreditInfo(credit, level)
	local creditInfo = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CreditInfo

	if creditInfo then
		creditInfo.Credit = credit
		creditInfo.Level = level

		gMessageManager:SendMessage(gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE)
		gBaiKeArchiveManager.RefreshBaikePhoneAppRedDot()
	end
end

function GameToClientImpl.SyncInviteRideNpcInfo(InviteRideNpcId, IsInviteRideNpcActive)
	gNpcFavorManager:OnSyncRideNpc(InviteRideNpcId, IsInviteRideNpcActive)
end

function GameToClientImpl.SyncWasherMissionResult(result)
	gWasherManager.OnWasherMissionFinished(result)
end

function GameToClientImpl.SyncTaskRoleTeam(roleTeam, enableRoleIds, tipRoleId, enableSwitch)
	gSpiritManager:SyncTaskRoleTeam(roleTeam, enableRoleIds, tipRoleId, enableSwitch)
end

function GameToClientImpl.SyncWatchInteractionInfo(pid, name, type, context, isSource, isResponse)
	local data = {
		pid = pid,
		name = name,
		type = type,
		context = context,
		isSource = isSource,
		isResponse = isResponse
	}

	gMessageManager:SendMessage(gEventConstants.SYNC_WATCH_INTERACTION_INFO, data)
end

function GameToClientImpl.SyncCanWatchOther(canWatch, watchingPid)
	gLinkManager:OnSyncWatchState(canWatch, watchingPid)
end

function GameToClientImpl.SyncPlanningBoardInfo(planningBoardInfo)
	gPlayerManager.infoMinor.bindData.planningBoardInfo = planningBoardInfo

	gMessageManager:SendMessage(gEventConstants.ON_PLANNING_BOARD_INFO_CHANGE)
end

function GameToClientImpl.SyncBartenderElementStockOz(bartenderId, elementId, stockOz)
	print_debug("SyncBartenderElementStockOz", bartenderId, elementId, stockOz)
end

function GameToClientImpl.SyncBartenderCustomerInfo(customerInfo)
	gBartendManager:OnSyncCustomerInfo(customerInfo)
end

function GameToClientImpl.SyncPartyResponse(response, npcIdList)
	gPartyManager:OnSyncResponse(response, npcIdList)
end

function GameToClientImpl.SyncPartySettleData(settleData)
	gPartyManager:OnSyncSettleData(settleData)
end

function GameToClientImpl.SyncGangBossFullDetails(fullDetails)
	gGangMemberManager:SyncGangBossFullDetails(fullDetails)
end

function GameToClientImpl.SyncGangBossGangMemberDetails(membersInfos)
	gGangMemberManager:SyncGangBossGangMemberDetails(membersInfos)
end

function GameToClientImpl.SyncGangBossCurrentBattleAgentCount(count)
	gGangMemberManager:SyncGangBossCurrentBattleAgentCount(count)
end

return GameToClientImpl
