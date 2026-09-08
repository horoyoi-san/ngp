-- Original chunk: @Lua\LuaFiles\LX6\Service\GameToClientImpl.lua
-- Decompiled from: 02352_GameToClientImpl.lua_c7012e192cea.luajit

local MoneyType = UX.Game.MoneyType
local ConsumableConfig = LTConfig.ConsumableConfig
local MessageConfig = LTConfig.MessageConfig
local DropConfig = LTConfig.DropConfig
local ItemReason = UX.Game.ItemReason
slot5 = gRpcChecker
local GameToClientImpl = slot5:CreateRpcImpl()

GameToClientImpl.SyncPlayerInfo = function(playerInfo)
	local status, err = xpcall(GameToClientImpl.SyncPlayerInfoProxy, tolua.traceback, playerInfo)

	gMessageManager:SendMessage(gEventConstants.JOB_CHANGE_EVENT)

	if not status then
		print_error_without_stack("SyncPlayerInfo error:", err)
	end
end

GameToClientImpl.SyncPlayerInfoProxy = function(playerInfo)
	gPlayerManager:InitPlayerInfo(playerInfo)

	if gGuitarManager and gGuitarManager.SyncPlayerInfo then
		gGuitarManager:SyncPlayerInfo(playerInfo)
	end

	gSystemUnlockMgr:OnLogin()
	gMapSystem:SyncPlayerInfo(playerInfo)
	gSpiritManager:SyncPlayerInfoSpirit(playerInfo.InfoSpirit)
	gBattleSpiritMgr:SyncPlayerInfo(playerInfo.InfoSpirit)
	gCommonItemManager:SetPlayerInfoItem(playerInfo.InfoItem)
	gCommonItemManager:SetPlayerInfoSubmitItem(playerInfo.InfoMinor and playerInfo.InfoMinor.InfoSubmitItem or nil)
	gEmojiManager:ReInit()
	gClueManager:OnLogin()
	gGuideMainPanelMgr:OnLogin()

	if gLuaUIMgr.uidLayerPanelStore then
		gLuaUIMgr.uidLayerPanelStore:RefreshUID()
	end

	gNpcChatManager:SyncPlayerInfo(playerInfo)
	gCompoundManager:SyncPlayerInfo(playerInfo)

	if playerInfo.InfoMinor and playerInfo.InfoMinor.PlayerTradeInfo then
		gTradeManager:OnSyncPlayerTradeInfo(playerInfo.InfoMinor.PlayerTradeInfo)
	end

	if playerInfo.InfoMinor and playerInfo.InfoMinor.PlayerGiftInfo then
		gMallGiftManager:OnSyncPlayerGiftInfo(playerInfo.InfoMinor.PlayerGiftInfo)
	end

	gMartialArtistManager:InitPlayerInfo(playerInfo)
	gOnlineSeasonProgressMgr:ParseLoginData(playerInfo.InfoMinor and playerInfo.InfoMinor.InfoOnlineSeasonProgress or nil)
	gTalentTreeMgr:OnSyncGamePlayTalentInfo(playerInfo.InfoMinor.GameplayTalentInfos)
end

GameToClientImpl.SyncSceneFogMapAllUnlock = function(sceneId, unlocked)
	LX6.Gps.MapFogDataMgr.SyncUnlockScene(sceneId, unlocked)
end

GameToClientImpl.SyncMapRandomEventsList = function(randomDic, notAbortList)
	if gMapSubSystem_RangeEvent then
		gMapSubSystem_RangeEvent:SyncRuleDict(randomDic, notAbortList)
	end
end

GameToClientImpl.SyncFactionHighLightEventList = function(eventIds)
	if gMapSubSystem_Faction then
		gMapSubSystem_Faction:SyncFactionHighLightEvents(eventIds)
	end
end

GameToClientImpl.ShowTaskFailPanel = function(taskId, stateData, fromDead)
	gTaskManager:TryShowFailPanel(taskId, stateData, fromDead)
end

GameToClientImpl.SyncFactionInfluenceAreaOccupy = function(areaId, occupy)
	if gMapSubSystem_Gangster then
		gMapSubSystem_Gangster:OnOccupyArea(areaId, occupy)
	end
end

GameToClientImpl.SyncFillFactionArea = function(areaId)
	if gMapSubSystem_Gangster then
		gMapSubSystem_Gangster:OnFillFactionArea(areaId)
	end
end

GameToClientImpl.SyncFactionAreaEncroachment = function(info)
	if gMapSubSystem_Gangster then
		gMapSubSystem_Gangster:SyncFactionAreaEncroachment(info)
	end
end

GameToClientImpl.SyncClearFactionAreaAllEncroachment = function(areaId)
	if gMapSubSystem_Gangster then
		gMapSubSystem_Gangster:ClearFactionAreaAllEncroachment(areaId)
	end
end

GameToClientImpl.SyncClearFactionAreaEncroachment = function(areaId, factionId)
	if gMapSubSystem_Gangster then
		gMapSubSystem_Gangster:ClearFactionAreaEncroachment(areaId, factionId)
	end
end

GameToClientImpl.SyncFactionAreaTriggerCounterAttack = function(info)
	if gMapSubSystem_Gangster then
		gMapSubSystem_Gangster:SyncFactionAreaTriggerCounterAttack(info)
	end
end

GameToClientImpl.SyncPlayerAddNewSpirit = function(spirit, reason)
	gSpiritManager:AddSpiritViewData(spirit)
	gWeaponManager:SyncSpiritWeaponSlot(spirit.SpiritInfo.TemplateId, spirit.SpiritInfo.WeaponSlots)
end

GameToClientImpl.SyncHideAndSeekUiUnit = function(unit)
	gNewGamePlayProgressMgr:AddNewPopup(unit)
end

GameToClientImpl.SyncSwitchSceneFailed = function(raidId, errorId)
	if errorId == MessageConfig.Ok then
		print_warn("SyncSwitchSceneFailed error", gCS.Error.GetNameById(errorId))
	end

	gRpcUtils.isSendingSwitchRaidRpc = false

	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
end

GameToClientImpl.SyncSwitchUniverse = function(fromUniverseId, toUniverseId)
	gMultiverseMgr:OnSyncSwitchUniverse(fromUniverseId, toUniverseId)
end

GameToClientImpl.SyncLastChangeNameTime = function(timeStamp)
	gHunLunManager:SyncLastChangeNameTime(timeStamp)
end

GameToClientImpl.SyncWeaponDecorationReturnItem = function(decorationId, itemUid)
	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.WEAPON_DECORATION_RETURN_ITEM, decorationId, itemUid)
end

GameToClientImpl.SyncMoney = function(money, gold, bindingGold)
	gPlayerManager.infoItem.bindData.lastMoney = gPlayerManager.infoItem.bindData.money
	gPlayerManager.infoItem.bindData.money = money
	gPlayerManager.infoItem.bindData.gold = gold
	gPlayerManager.infoItem.bindData.bindGold = bindingGold

	gMessageManager:SendMessage(gEventConstants.MONEY_CHANGE)
	gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
end

GameToClientImpl.SyncMoneyAdd = function(moneyAdd, reason, silence)
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

GameToClientImpl.SyncMoneyRemove = function(moneyRemove)
	if moneyRemove <= 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoseMoney, nil, , moneyRemove)
	end
end

GameToClientImpl.SyncMoneyRemoveInfo = function(value, LogoId, textId, moneyEnough)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.PayTips, {
		Param = {
			value = value,
			logoId = LogoId,
			textId = textId,
			moneyEnough = moneyEnough
		}
	})
end

GameToClientImpl.SyncLoginEnterDefaultUniverse = function()
	gMultiverseMgr:OnSyncLoginEnterDefaultUniverse()
end

GameToClientImpl.SyncGoldAdd = function(intention, bindGoldAdd, goldAdd, reason, silence)
	if not silence then
		local rewardItems = {}

		if goldAdd <= 0 then
			table.insert(rewardItems, {
				ItemId = gUIUtils:GetMoneyTypeId(MoneyType.Gold),
				Count = goldAdd
			})
		end

		if bindGoldAdd <= 0 then
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

GameToClientImpl.SyncGoldRemove = function(intention, bindGoldRemove, goldRemove)
	if goldRemove <= 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoseGold, nil, , goldRemove)
	end

	if bindGoldRemove <= 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.LoseBindGold, nil, , bindGoldRemove)
	end
end

GameToClientImpl.SyncBackpackItemChanged = function(addList, updateList, deleteList)
	gCommonItemManager:SetPackItem(addList, updateList, deleteList)
end

GameToClientImpl.SyncItemDayCount = function(itemDayCount)
	gPlayerManager.infoItem.pack.itemUseTimes[itemDayCount.TemplateId] = itemDayCount.Count
end

GameToClientImpl.SyncItemShortcut = function(ItemShortcutInfoDict, destructibleShortcut)
	gPlayerManager.infoItem.pack.itemShortcutDic = ItemShortcutInfoDict
	gPlayerManager.infoItem.pack.destructibleShortcut = destructibleShortcut

	gMessageManager:SendMessage(gEventConstants.ITEM_SHORTCUT_CHANGED)
end

GameToClientImpl.ShowReceiveRewardDetail = function(msg)
	if msg.Reason ~= UX.Game.ItemReason.PoliceReturnInvalidVehicleFine then
		gPoliceJobManager:OnDropPoliceReturnInvalidVehicleFine()
	end

	if msg.Reason ~= UX.Game.ItemReason.Mall or msg.Reason ~= UX.Game.ItemReason.MallBundle then
		gMallManager:ShowMallPurchaseReward(msg)

		return
	end

	if msg.Reason ~= UX.Game.ItemReason.Gacha or msg.Reason ~= UX.Game.ItemReason.GachaDraw then
		return
	end

	if (msg.Reason ~= UX.Game.ItemReason.Charge or msg.Reason ~= UX.Game.ItemReason.FirstCharge) and gGachaManager:IsSuppressingChargeReward() then
		return
	end

	if msg.Reason ~= UX.Game.ItemReason.LinkMultiPlayerMahjongSuccess or msg.Reason ~= UX.Game.ItemReason.LinkMultiPlayerMahjongFail then
		gMaJiangManager:OnGameReward(msg)

		return
	end

	gDropManager:ShowReceiveRewardDetail(msg)

	if msg.Reason ~= UX.Game.ItemReason.PoliceFine then
		gPoliceJobManager:OnDropPoliceJobExp(msg.Reward)
	end

	if msg.Reason ~= UX.Game.ItemReason.Diviner then
		gDivinerManager:OnDivinerDrop(msg)
	end

	if msg.Reason ~= UX.Game.ItemReason.TruckJob then
		gDeliveryTaskManager:SetTruckJobDrop(msg)
	end
end

GameToClientImpl.SyncGachaDrawInfo = function(drawDetails, isGrandPrizeWithAllFillers)
	gGachaManager:ShowGachaResult(drawDetails, isGrandPrizeWithAllFillers)
end

GameToClientImpl.SyncMallReceiveRewardDetail = function(msg)
	local rewardDetail = msg.Reward[gDropManager.RewardType.Normal] or {}
	local firstDetail = msg.Reward[gDropManager.RewardType.First]
	rewardDetail.Items = rewardDetail.Items or {}

	if firstDetail and firstDetail.Items then
		array.concat(rewardDetail.Items, firstDetail.Items)
	end

	local items = {}

	if rewardDetail.Items == nil and #rewardDetail.Items <= 0 then
		for i = 1, #rewardDetail.Items do
			local item = rewardDetail.Items[i].ItemId
			local count = rewardDetail.Items[i].Count
			local conf = ConsumableConfig.GetConfig(item)
			local displayDrop = false

			if conf ~= nil then
				conf = ConsumableConfig.GetConfig(item)
			else
				displayDrop = conf.SubType ~= ConsumableTypeConfig.Use
			end

			if conf == nil then
				local dropConf = conf.Drop == nil and conf.Drop == 0 and DropConfig.GetConfig(conf.Drop) or nil

				if dropConf ~= nil or not displayDrop then
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

					if rewardDetail.BindingGold ~= nil then
						rewardDetail.BindingGold = 0
					end

					if rewardDetail.Money ~= nil then
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

GameToClientImpl.SyncMallCartInfo = function(cartItemList)
	gPlayerManager.infoMinor.bindData.MallInfo.CartItemList = cartItemList

	gMessageManager:SendMessage(gEventConstants.MALL_CART_CHANGE)
end

GameToClientImpl.SyncMallCartItemUpsert = function(items)
	local cartItemList = gPlayerManager.infoMinor.bindData.MallInfo.CartItemList

	for i = items.Count, 1, -1 do
		local item = items[i]

		for j = cartItemList.Count, 1, -1 do
			if cartItemList[j].CommodityId ~= item.CommodityId then
				table.remove(cartItemList, j)

				cartItemList.Count = cartItemList.Count - 1
				cartItemList.Length = cartItemList.Length - 1

				break
			end
		end

		table.insert(cartItemList, 1, item)

		cartItemList.Count = cartItemList.Count + 1
		cartItemList.Length = cartItemList.Length + 1
	end

	gMessageManager:SendMessage(gEventConstants.MALL_CART_CHANGE)
end

GameToClientImpl.SyncMallCartItemRemove = function(commodityIdList)
	local cartItemList = gPlayerManager.infoMinor.bindData.MallInfo.CartItemList
	local removeSet = {}

	for i = 1, commodityIdList.Count do
		removeSet[commodityIdList[i]] = true
	end

	for i = cartItemList.Count, 1, -1 do
		if removeSet[cartItemList[i].CommodityId] then
			table.remove(cartItemList, i)

			cartItemList.Count = cartItemList.Count - 1
			cartItemList.Length = cartItemList.Length - 1
		end
	end

	gMessageManager:SendMessage(gEventConstants.MALL_CART_CHANGE)
end

GameToClientImpl.ShowTaskChangePanel = function(oldCurrentId, newCurrentId)
	gTaskManager:ShowTaskChangePanel(oldCurrentId, newCurrentId)
end

GameToClientImpl.SyncPlayerAllTask = function(taskInfos, submitTaskList, currentTask, eventPanelInfo, loadingFinish)
	if currentTask <= 0 then
		local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(currentTask)
		local CurrentTaskType = gTaskManager:GetCurrentTaskType(currentTask)
		gTaskNodeManager.NowDoingTask[CurrentTaskType] = currentTask
		gTaskNodeManager.NowDoingTaskLine[CurrentTaskType] = taskLineInfo and taskLineInfo.TaskLineId or nil
	end
end

GameToClientImpl.SyncTemporaryCurrentTask = function(taskId, eventId, reason)
	gTaskManager:SyncTemporaryCurrentTask(taskId, eventId, reason)
end

GameToClientImpl.SyncTaskTitleGuideUnlock = function(taskTitleId, unlocked)
	if gMapSystem and gMapSystem.taskUtils then
		gMapSystem.taskUtils:SetTaskTitleGuide(taskTitleId, unlocked)
	end
end

GameToClientImpl.SyncActivateNpcCard = function(infocs)
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

GameToClientImpl.SyncActivateLockedNpcCard = function(infocs)
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

GameToClientImpl.SyncNpcUnlockVoice = function(npcCardId, voice)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId ~= npcCardId then
			list[i].UnlockedVoice[#list[i].UnlockedVoice + 1] = voice

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

GameToClientImpl.SyncNpcInteractDays = function(npcCardId, days, lastTime)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId ~= npcCardId then
			list[i].InteractDays = days
			list[i].LastInteractTime = lastTime

			break
		end
	end
end

GameToClientImpl.SyncNpcUnlockStory = function(npcCardId, story, unlockTime)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId ~= npcCardId then
			list[i].UnlockedStoryDict[story] = unlockTime

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

GameToClientImpl.SyncNpcInteractedStory = function(npcCardId, story)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId ~= npcCardId then
			list[i].InteractedStories[#list[i].InteractedStories + 1] = story

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

GameToClientImpl.SyncNpcInteractedVoice = function(npcCardId, voice)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId ~= npcCardId then
			list[i].InteractedVoices[#list[i].InteractedVoices + 1] = voice

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

GameToClientImpl.SyncNpcTakeFavorReward = function(npcCardId, level)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId ~= npcCardId then
			list[i].FavorLevelReward = level

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

GameToClientImpl.SyncNpcInteractedOuterStory = function(npcCardId, hasInteracted)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId ~= npcCardId then
			list[i].HasNoInteractedStory = hasInteracted

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

GameToClientImpl.SyncNpcInteractedOuterVoice = function(npcCardId, hasInteracted)
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

	for i = 1, #list do
		if list[i].TemplateId ~= npcCardId then
			list[i].HasUninteractedNpcVoice = hasInteracted

			gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)

			break
		end
	end
end

GameToClientImpl.SyncNpcFavor = function(npcCardId, favorDiff, favor, gamePlayType)
	gNpcFavorManager:OnSyncNpcFavor(npcCardId, favorDiff, favor, gamePlayType)
end

GameToClientImpl.SyncLockedNpcFavor = function(npcCardId, favorDiff, favor)
	gNpcFavorManager:OnSyncNpcFavor(npcCardId, favorDiff, favor, nil)
end

GameToClientImpl.SyncNpcPhotoPosInfo = function(npcCardId, isGroup, posInfo)
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

GameToClientImpl.SyncNpcFirstChatPosInfo = function(npcCardId, posInfo)
	local info = gNpcInteracsUtils:TryGetNpcCultivationInfo(npcCardId)

	if not info then
		print_error("不存在或未同步的角色好感数据!npcCardId = ", npcCardId)

		return
	end

	info.FirstChatPosList = posInfo
end

GameToClientImpl.SyncFavorNpcTimeTableInfos = function(vehicleIdDict)
	gNpcDaliyManager:OnSyncNpcTimeTableInfos(vehicleIdDict)
end

GameToClientImpl.SyncAgentTagTimeTableInfo = function(agentTag, timeTableInfo)
	gNpcDaliyManager:OnSyncAgentTagTimeTableInfo(agentTag, timeTableInfo)
end

GameToClientImpl.SyncMilkNpcFavor = function(value)
end

GameToClientImpl.SyncAllUnlockedVehicles = function(unlockedVehicles)
	gApplyCarManager:SyncAllUnlockedVehicles(unlockedVehicles)
end

GameToClientImpl.SyncAllActivities = function(activities)
	gAwardActivityManager:OnSyncAwardActivity(activities)
end

GameToClientImpl.SyncNewActivity = function(activity)
	gAwardActivityManager:OnSyncNewActivity(activity)
end

GameToClientImpl.SyncActivityData = function(activityData)
	gAwardActivityManager:OnSyncActivityData(activityData)
end

GameToClientImpl.SyncRemoveActivity = function(activityCfgId)
	gAwardActivityManager:OnRemoveActivity(activityCfgId)
end

GameToClientImpl.SyncPlayerPopularityResetFirstOpen = function()
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo then
		popularityInfo.IsFirstTriggered = false
		popularityInfo.IsFirstPhoneOpened = false
	end

	if gHotCenterManager then
		gHotCenterManager:ResetPopularityFirstOpenState()
	end
end

local GetPopularityListCount = function(list)
	if not list then
		return 0
	end

	if list.Count == nil then
		return list.Count
	end

	return #list
end

local RefreshPopularityInfo = function(refreshReward)
	gMessageManager:SendMessage(gEventConstants.ON_PLAYER_POPULARITY_CHANGE)

	if refreshReward then
		gMessageManager:SendMessage(gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE)
	end

	if gHotCenterManager then
		gHotCenterManager:RefreshPopularityInfoScroll()
	end
end

GameToClientImpl.SyncPlayerPopularityRecord = function(recordData)
	if not recordData or not UXCommon.Time.UXLogicTime.IsSameDay(recordData.Time, gLuaDataManager.serverTime) then
		return
	end

	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if not popularityInfo then
		return
	end

	local recordList = popularityInfo.DropRecordList or {}

	for i = 1, GetPopularityListCount(recordList) do
		local info = recordList[i]

		if info.Time ~= recordData.Time and info.DropId ~= recordData.DropId and info.Popularity ~= recordData.Popularity then
			return
		end
	end

	table.insert(recordList, recordData)

	popularityInfo.DropRecordList = recordList

	RefreshPopularityInfo(false)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.PopularityReward, {
		Popularity = recordData.Popularity,
		DropId = recordData.DropId
	})
end

GameToClientImpl.SyncPlayerPopularityDayRewardInfo = function(rewardInfoList)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if not popularityInfo then
		return
	end

	if gHotCenterManager then
		gHotCenterManager:UpdateYesterdayPopularityEarnings(rewardInfoList)
	end

	local todayRewardInfoList = {}

	for i = 1, GetPopularityListCount(rewardInfoList) do
		local rewardInfo = rewardInfoList[i]

		if UXCommon.Time.UXLogicTime.IsSameDay(rewardInfo.Time, gLuaDataManager.serverTime) then
			table.insert(todayRewardInfoList, rewardInfo)
		end
	end

	popularityInfo.DayRewardList = todayRewardInfoList

	RefreshPopularityInfo(true)
end

GameToClientImpl.SyncPlayerYesterdayAvgPopularity = function(popularity)
	gPlayerManager.infoMinor.bindData.popularityInfo.YesterdayAvgPopularity = popularity

	gMessageManager:SendMessage(gEventConstants.ON_PLAYER_POPULARITY_CHANGE)
end

GameToClientImpl.SyncPlayerPopularityFanBoxDropInfo = function(fanBoxDropInfo)
	gPlayerManager.infoMinor.bindData.popularityInfo.FanBoxDropInfo = fanBoxDropInfo
end

GameToClientImpl.SyncPlayerPastDaysPopularity = function(historyList)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo then
		popularityInfo.PastDaysHighestPopularityList = historyList

		RefreshPopularityInfo(false)
	end
end

GameToClientImpl.SyncPlayerTempSpirits = function(tempSpirits)
	gSpiritManager:SyncPlayerTempSpirit(tempSpirits)
end

GameToClientImpl.SyncPlayerAllSpirits = function(allSpirits)
	gSpiritManager:SyncPlayerAllSpirits(allSpirits)
end

GameToClientImpl.SyncSpiritSexTransition = function(oldSpiritId, newSpiritId, sexTransitionLastTime)
	gSpiritManager:SyncSpiritSexTransition(oldSpiritId, newSpiritId, sexTransitionLastTime)
end

GameToClientImpl.SyncHackerJobInfo = function(hackerJobInfo)
	gHackManager:SyncHackerJobInfo(hackerJobInfo)
end

GameToClientImpl.NotifyNewHackerPosts = function()
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.HackerNewTips)
end

GameToClientImpl.SyncHackerBatteryCurrentAndTotalCount = function(hackInfo)
	gInteractionManager.hackInfo = hackInfo

	gMessageManager:SendMessage(gEventConstants.HACK_BATTERY_CHANGE, hackInfo)
end

GameToClientImpl.SyncItemCountLimit = function(itemCountLimitList)
	gPlayerManager.infoItem.bindData.itemCountLimitInfoList = itemCountLimitList

	gCommonItemManager:RefreshItemCountLimit()
end

GameToClientImpl.SyncReturnOverflowMaterial = function(overflowMaterials)
	gSpiritManager:SyncReturnOverflowMaterial(overflowMaterials)
end

GameToClientImpl.SyncCurrentSpiritCardGroupIndex = function(index)
	gSpiritManager.currentGroupIndex = index
end

GameToClientImpl.SyncChaosMasterBuffOptions = function(buffs)
end

GameToClientImpl.SyncMapEntrance = function(openEntrance, displayableEntrance)
	gMapUtils:SyncMapEntranceState(displayableEntrance, openEntrance)
end

GameToClientImpl.UpdateMapEntrance = function(mapEntranceId, isOpen, isShow)
	gMapUtils:UpdateMapEntranceState(mapEntranceId, isOpen, isShow)
end

GameToClientImpl.SyncBVBPokemonBreakthrough = function(pokemon)
	gBattlePetsMgr:SyncNewPet(pokemon)
end

GameToClientImpl.SyncNeedBundles = function(raid, mode, bundles)
	gDlcDownLoadMgr:OnSyncNeededBundles(raid, mode, bundles)
end

GameToClientImpl.KickOff = function(pid, suiteName, caseName, luastr)
	gClientQARunner:KickOff(pid, suiteName, caseName, luastr)
end

GameToClientImpl.ShowLogInClient = function(pid)
	gClientQARunner:ShowLogInClient(pid)
end

GameToClientImpl.ShowServerMessageIdWithArgs = function(msgId, args, para)
	gDisplayMessageMgr:DisplayServerMessageId_NeedCallback(msgId, args, para)
end

GameToClientImpl.SyncEnterScene = function(enterInfo)
	gSceneManager:OnSyncEnterScene(enterInfo)
end

GameToClientImpl.SyncShowMessage = function(messageId, args)
	gDisplayMessageMgr:ShowServerMessage(messageId, args)
end

GameToClientImpl.SyncTaskWithErrorRole = function(taskId, eventId, spiritId)
	local eventCfg = LTConfig.TaskEventConfig.GetConfig(eventId)
	local taskName = eventCfg and eventCfg.EventName
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	local roleName = spiritCfg and spiritCfg.Name
	local para = {
		TaskId = taskId,
		SpiritId = spiritId
	}

	local callback = function(state)
		gClientToGameDelegate:DoMessageCallback(MessageConfig.TaskWithWrongRole, state, para).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:ShowMessage(err)
			end
		end
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.TaskWithWrongRole, function ()
		callback(gDisplayMessageMgr.MessageCallbackState.Confirm)
	end, function ()
		callback(gDisplayMessageMgr.MessageCallbackState.Cancel)
	end, taskName, roleName)
end

GameToClientImpl.SyncHasNotEarnedAchievement = function(count)
	gNewAchievementMgr:SyncHasNotEarnedAchievement(count)
end

GameToClientImpl.SyncNewAchievement = function(id, detail)
	gNewAchievementMgr:OnSyncNewAchievement(id, detail)
end

GameToClientImpl.SyncDiDiNextTask = function(taskId)
end

GameToClientImpl.SyncJobMissionStateChange = function(jobClass, active)
	gMessageManager:SendMessage(gEventConstants.JOB_MISSION_STATE_CHANGE, {
		job = jobClass,
		active = active
	})
end

GameToClientImpl.SyncAddHouse = function(houseInfo)
	gBuyHouseUtils.SyncAddHouse(houseInfo)
	gMessageManager:SendMessage(gEventConstants.MAP_ENTRANCE_UPDATE)
end

GameToClientImpl.SyncRemoveHouse = function(houseId)
	gBuyHouseUtils.SyncRemoveHouse(houseId)
end

GameToClientImpl.SyncHouseParking = function(cancelInfoList, addInfoList)
	gGarageManager:SyncHouseParking(cancelInfoList, addInfoList)
end

GameToClientImpl.SyncHouseParkingEntityBinding = function(bindingList)
	gGarageManager:SyncHouseParkingEntityBinding(bindingList)
end

GameToClientImpl.SyncFurnitureInfo = function(furnitureId, count, placedCount)
	gBuyHouseUtils.SyncFurnitureInfo(furnitureId, count, placedCount)
end

GameToClientImpl.SyncNewTuite = function(tuiteInfo)
	table.insert(gPlayerManager.infoMinor.bindData.playerTuiteInfo.TuiteList, tuiteInfo)

	if gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.SocialNetworkId) then
		gSocialNetworkPopupManager:PushPopupInfo(tuiteInfo)
	end
end

GameToClientImpl.SyncUpdateTuiteInfo = function(tuiteInfo)
	local tuiteList = gPlayerManager.infoMinor.bindData.playerTuiteInfo.TuiteList

	if not tuiteList then
		return
	end

	for index, tuite in ipairs(tuiteList) do
		if tuite.CfgId ~= tuiteInfo.CfgId then
			tuiteList[index] = tuiteInfo

			return
		end
	end

	table.insert(tuiteList, tuiteInfo)

	if gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.SocialNetworkId) then
		gSocialNetworkPopupManager:PushPopupInfo(tuiteInfo)
	end
end

GameToClientImpl.SyncDeleteTuiteComment = function(tuiteId, commentId)
end

GameToClientImpl.SyncDeleteAllTuiteComment = function(tuiteId)
end

GameToClientImpl.SyncPlayerTwitterButton = function(twitterId, isOpen, secondShowType, showInteractionButton)
	gSocialNetworkUtils:SyncPlayerTwitterButton(twitterId, isOpen, secondShowType, showInteractionButton)
end

GameToClientImpl.SyncTwitterMonitoredBehaviors = function(behaviors)
	gSocialNetworkUtils.SyncTwitterMonitoredBehaviors(behaviors)
end

GameToClientImpl.SyncOpenTuitePanel = function(tuiteId)
	gPanelManager:CheckShow(gPanelId.YANJIE_APP_HOME_PANEL, {
		["\\xf4\\x9f\\xe3\\xd5\\xe5\\x9fٛ0-"] = 1,
		id = tuiteId
	})
end

GameToClientImpl.AddSpiritPhoneInfos = function(spiritId, phoneInfos)
	local spiritPhoneInfos = gPlayerManager.infoMinor.bindData.spiritPhoneInfos
	spiritPhoneInfos[spiritId] = phoneInfos
end

GameToClientImpl.SyncPhoneAutoAddContact = function(phoneContactUnlockId, phoneInfo, selfSpiritId)
	local phoneContactUnlockCfg = LTConfig.PhoneContactUnlockConfig.GetConfig(phoneContactUnlockId)
	local spiritIdList = phoneContactUnlockCfg.SpiritIdList
	spiritIdList = #spiritIdList <= 0 and spiritIdList or gCallPhoneUtils.GetAllSpiritIdList()

	for _, spiritId in ipairs(spiritIdList) do
		if selfSpiritId == spiritId and gCallPhoneUtils.TryGetPhoneInfos(spiritId) then
			gCallPhoneUtils.SyncAddPhoneContact(spiritId, {
				PhoneNumber = phoneInfo.PhoneNumber,
				Remark = phoneInfo.Remark
			})
		end
	end
end

GameToClientImpl.SyncPhoneAutoDeleteContact = function(phoneContactUnlockId, phoneInfo, selfSpiritId)
	local phoneContactUnlockCfg = LTConfig.PhoneContactUnlockConfig.GetConfig(phoneContactUnlockId)
	local spiritIdList = phoneContactUnlockCfg.SpiritIdList
	spiritIdList = #spiritIdList <= 0 and spiritIdList or gCallPhoneUtils.GetAllSpiritIdList()

	for _, spiritId in ipairs(spiritIdList) do
		if selfSpiritId == spiritId and gCallPhoneUtils.TryGetPhoneInfos(spiritId) then
			gCallPhoneUtils.SyncDeletePhoneContact(spiritId, {
				PhoneNumber = phoneInfo.PhoneNumber,
				Remark = phoneInfo.Remark
			})
		end
	end
end

GameToClientImpl.SyncFashionInfoDict = function(fashionInfoDict)
	gDressData:SyncFashionInfoDict(fashionInfoDict)
end

GameToClientImpl.SyncAddOrUpdateFashion = function(fashionInfo)
	gDressData:SyncAddOrUpdateFashion(fashionInfo)
end

GameToClientImpl.SyncAddOrUpdateFashionList = function(fashionInfoList)
	gDressData:SyncAddOrUpdateFashionList(fashionInfoList)
end

GameToClientImpl.SyncRemoveFashion = function(fashionId)
	gDressData:SyncRemoveFashion(fashionId)
end

GameToClientImpl.SyncRemoveFashionList = function(fashionIdList)
	gDressData:SyncRemoveFashionList(fashionIdList)
end

GameToClientImpl.SyncFashionSuitInstance = function(fashionSuitId, info)
	gDressData:SyncFashionSuitInstance(fashionSuitId, info)
end

GameToClientImpl.SyncAddRadioSong = function(songId)
	if gPlayerManager.infoMinor.bindData.PlayerRadioSongsData and gPlayerManager.infoMinor.bindData.PlayerRadioSongsData.SongInfoDict then
		gPlayerManager.infoMinor.bindData.PlayerRadioSongsData.SongInfoDict[songId] = true

		gRadioPlayerManager:SyncAddRadioSong()
	end
end

GameToClientImpl.SyncSetSpiritFashions = function(spiritId, source, spiritWearFashionsInfo)
	if bit.band(source, UX.Game.FashionWearSource.HouseShowcase) ~= 0 then
		gDressData:SyncSetSpiritFashions(spiritId, spiritWearFashionsInfo)
	end
end

GameToClientImpl.SyncSetSpiritActiveTryWearSource = function(spiritId, activeTryWearSource)
	gDressData:SyncSetSpiritActiveTryWearSource(spiritId, activeTryWearSource)
end

GameToClientImpl.SyncHostFashionList = function(hostPid, hostFashionIds)
	gDressData:SyncHostFashionList(hostPid, hostFashionIds)
end

GameToClientImpl.SyncCollectionCountryUnlock = function(countryId)
	if gPlayerManager.infoAchievement and gPlayerManager.infoAchievement.bindData.UnlockedCountryList then
		local UnlockedCountryList = gPlayerManager.infoAchievement.bindData.UnlockedCountryList

		if array.contains(UnlockedCountryList, countryId) then
			return
		end

		table.insert(UnlockedCountryList, countryId)
	end
end

GameToClientImpl.SyncCollectionQuestUnlock = function(questId)
	local UnlockedQuestList = gPlayerManager.infoAchievement.bindData.UnlockedQuestList

	if UnlockedQuestList ~= nil or array.contains(UnlockedQuestList, questId) then
		return
	end

	table.insert(UnlockedQuestList, questId)
	gMessageManager:SendMessage(gEventConstants.SYNC_COLLECTION_UNLOCK, {
		questId = questId
	})
end

GameToClientImpl.SyncCompletedSubQuest = function(subQuestId)
	local SubQuest = gPlayerManager.infoAchievement.bindData.CompletedSubQuestCnt

	if SubQuest ~= nil then
		return
	end

	if SubQuest[subQuestId] ~= nil then
		SubQuest[subQuestId] = 0
	end

	SubQuest[subQuestId] = SubQuest[subQuestId] + 1

	gMessageManager:SendMessage(gEventConstants.SYNC_COLLECTION_GET)

	local id = gGpsTools.GetMapId(EMapElementType.Collection, subQuestId)

	gGpsManager:TryRemoveMapGuideById(id)
end

GameToClientImpl.SyncFirstEnemyKillRecord = function(enemyKillRecord)
	gPlayerManager.infoAchievement.bindData.FirstKillEnemyRecord = enemyKillRecord
end

GameToClientImpl.SyncCompletedChallenge = function(challengeRecord, rewardInfo)
	local currentMiniGameManager = gClientUtils.GetCurrentMiniGameManager()

	if currentMiniGameManager then
		currentMiniGameManager:DestroyGame()

		return
	end

	local challengeInfo = gPlayerManager.infoAchievement.bindData.ChallengeRecordInfo
	local hasRecord = false

	if challengeInfo then
		for i, v in pairs(challengeInfo) do
			if v.ChallengeId ~= challengeRecord.ChallengeId then
				v = challengeRecord
				hasRecord = true
			end
		end
	end

	if not hasRecord then
		table.insert(gPlayerManager.infoAchievement.bindData.ChallengeRecordInfo, challengeRecord)
	end
end

GameToClientImpl.SyncPlayerClearTodayInspireHubGameplayJoinData = function()
end

GameToClientImpl.SyncPlayerInspireHubTodayGameplayJoinCount = function(gameplayId, count)
end

GameToClientImpl.SyncPlayerCompetitionSeason = function(seasonInfo)
	gInspireHubManager:SyncPlayerCompetitionSeason(seasonInfo)
end

GameToClientImpl.SyncPlayerUpdateCompetitionSeasonData = function(seasonInfo)
	gInspireHubManager:SyncPlayerUpdateCompetitionSeasonData(seasonInfo)
end

GameToClientImpl.SyncNpcGiftTagInfo = function(npcCardId, tagList)
	local info = gNpcInteracsUtils:TryGetNpcCultivationInfo(npcCardId)

	if not info then
		print_error("不存在或未同步的角色好感数据!npcCardId = ", npcCardId)

		return
	end

	info.ActiveGiftTags = tagList
end

GameToClientImpl.SyncNpcInteractPointCount = function(count)
	gPlayerManager.infoMinorNpcCultivation.bindData.InteractPoint = count

	gMessageManager:SendMessage(gEventConstants.NPC_INVITE_POINT_CHANGE)
end

GameToClientImpl.SyncNpcGiftSendAvailableCount = function(count)
	gPlayerManager.infoMinorNpcCultivation.bindData.availableGiftSendCount = count
end

GameToClientImpl.SyncNpcChatJoinGameplay = function(npcId, gameplay)
end

GameToClientImpl.SyncTaskInviteRideNpcCultivationId = function(npcCultivationId)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_TASK_RIDE_NPC_CULTIVATION_ID, npcCultivationId)
end

GameToClientImpl.SyncNpcChatLeaveGameplay = function(npcId, gameplay)
	gNpcChatManager:OnSyncNpcChatLeaveGameplay(npcId, gameplay)
end

GameToClientImpl.SyncNpcChatInvite = function(gameplay)
	local params = {
		["EH~jK-/"] = true,
		npcInviteGamePlay = gameplay
	}

	gNpcChatUtils.OpenChatPanel(params)
end

GameToClientImpl.SyncAnimalInfo = function(data)
	local animalInfos = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos
	local initAnimalInfo = false

	if animalInfos ~= nil then
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
			if animalInfo.FavorLevel <= v.FavorLevel or animalInfo.Favor <= v.Favor or animalInfo.NickName == v.NickName then
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

	gMessageManager:SendMessage(gEventConstants.ANIMAL_INFO_CHANGED)
end

GameToClientImpl.SyncNewPokemon = function(pokemon)
	gBattlePetsMgr:SyncNewPet(pokemon)
end

GameToClientImpl.SyncRemovePokemon = function(pokemonIdList)
	gBattlePetsMgr:SyncRemovePet(pokemonIdList)
end

GameToClientImpl.SyncPokemonSquad = function(list)
	gBattlePetsMgr:SyncQuickSummonList(list)
end

GameToClientImpl.SyncDropLimitInfo = function(dropId, info)
	gDropManager:OnSyncDropLimitNewInfo(dropId, info)
end

GameToClientImpl.SyncDropLimitInfoRemove = function(dropId)
	gDropManager:OnSyncDropLimitNewInfo(dropId, nil)
end

GameToClientImpl.SyncUpdatePokemonLockState = function(id, data)
	gBattlePetsMgr:SyncPetLockChange(id, data)
end

GameToClientImpl.SyncHotSpringInfo = function(info)
	gHotSpringManager:OnSyncHotSpringInfo(info)
end

GameToClientImpl.SyncCommodityInfos = function(shopId, infos)
	gShopManager:SyncCommodityInfos(shopId, infos)
end

GameToClientImpl.SyncShopDiscount = function(shopId, currentDiscount, factionDiscount, badgeDiscountDict)
	gShopManager:SyncShopDiscount(shopId, currentDiscount, factionDiscount, badgeDiscountDict)
end

GameToClientImpl.SyncShopGeneralBuyBackDiscount = function(shopId, currentDiscount, factionDiscount, badgeDiscountDict)
	gShopManager:SyncShopGeneralBuyBackDiscount(shopId, currentDiscount, factionDiscount, badgeDiscountDict)
end

GameToClientImpl.SyncAllShopDataOnLogin = function(allShopData)
	for i = 1, allShopData.Length do
		local data = allShopData[i]

		gShopManager:SyncCommodityInfos(data.ShopId, data.CommodityInfos, true)
		gShopManager:SyncShopDiscount(data.ShopId, data.CurrentDiscount, data.NextDiscount, true)
	end
end

GameToClientImpl.SyncBuybackCommodityInfos = function(shopId, infos)
	gShopManager:SyncBuybackCommodityInfos(shopId, infos)
end

GameToClientImpl.SyncFullCommodityInfos = function(shopId, infos)
	gShopManager:SyncFullCommodityInfos(shopId, infos)
end

GameToClientImpl.SyncFullBuybackCommodityInfos = function(shopId, infos)
	gShopManager:SyncFullBuybackCommodityInfos(shopId, infos)
end

GameToClientImpl.SyncShopRefreshState = function(shopId, refreshState)
	gShopManager:SyncShopRefreshState(shopId, refreshState)
end

GameToClientImpl.SyncCommodityPriceHistory = function(shopId, sellHistories, buybackHistories)
	gShopManager:SyncCommodityPriceHistory(shopId, sellHistories, buybackHistories)
end

GameToClientImpl.SyncUpdateExtractionShooterBringOutFund = function(gamePlayTypeId, fund)
	gExtractionShooterManager.SyncUpdateExtractionShooterBringOutFund(gamePlayTypeId, fund)
end

GameToClientImpl.SyncAllExtractionShooterBringOutFunds = function(funds)
	gExtractionShooterManager.SyncAllExtractionShooterBringOutFunds(funds)
end

GameToClientImpl.SyncClawDateInfo = function(data)
	gClawMachineManager:DateTaskBegin(data)
end

GameToClientImpl.SyncClawDateOut = function()
	gClawMachineManager:DateTaskEnd()
end

GameToClientImpl.SyncShowGuide = function(guide, counter)
	gNewGuideMgr:OnSyncShowGuide(guide, counter)
end

GameToClientImpl.SyncGuideTeachInfos = function(newGuideTeachInfos, rewardedGuideTeachInfos)
	gGuideMainPanelMgr:OnSyncGuideTeachInfos(newGuideTeachInfos, rewardedGuideTeachInfos)
end

GameToClientImpl.SyncInputDeviceUsage = function(inputDeviceUsage)
	gNewGuideMgr:OnSyncInputDeviceUsage(inputDeviceUsage)
end

GameToClientImpl.SyncMultiverseStatus = function(multiverseStatusInfo)
	gMultiverseMgr:OnMultiverseStatusChange(multiverseStatusInfo)
end

GameToClientImpl.SyncMomentsNotify = function(info)
	gNewBubbleMgr:OnSyncNewNotify(info)
end

GameToClientImpl.SyncUnlockSystems = function(unlockSystems)
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

GameToClientImpl.SyncInvestigateGallery = function(galleryId, unlock, galleryInfo)
	if not unlock then
		table.removeEx(gPlayerManager.infoAchievement.bindData.UnlockInvestigateGalleryList, galleryId)
	else
		table.insert(gPlayerManager.infoAchievement.bindData.UnlockInvestigateGalleryList, galleryId)
	end

	if gMapSubSystem_Legend then
		gMapSubSystem_Legend:SyncGalleryUnlock(galleryId, unlock, galleryInfo)
	end
end

GameToClientImpl.SyncCountryReputation = function(country, reputation)
	local dict = gPlayerManager.infoAchievement.bindData.CountryReputationInfo

	if not dict then
		dict = {}
		gPlayerManager.infoAchievement.bindData.CountryReputationInfo = dict
	end

	dict[country] = reputation
end

GameToClientImpl.SyncFactionInfoChange = function(factionId, info, oldInfo, dropTextId)
	gFactionManager:OnFactionChange(factionId, info, oldInfo, dropTextId)
end

GameToClientImpl.SyncFactionInfosChange = function(changeInfos, dropTextId)
	gFactionManager:OnFactionsChange(changeInfos, dropTextId)
end

GameToClientImpl.SyncLinkInvite = function(friendPid, mode, info)
	gLinkManager:OnBeInviteToLink(friendPid, mode, info)
end

GameToClientImpl.SyncLinkKicked = function(kickedByPid)
	gLinkManager:OnKickOut(kickedByPid)
end

GameToClientImpl.SyncCurrentLinkMode = function(mode)
	gLinkManager:OnChangeLinkMode(mode, true)
end

GameToClientImpl.SyncLeaveGame = function(multiplayId)
	gLinkManager:ClearLinkGame()
end

GameToClientImpl.SyncLinkMatchRoomPrepare = function(roomId, prepareRoom)
	gLinkManager:OnSyncLinkMatchRoomPrepare(roomId, prepareRoom)
end

GameToClientImpl.SyncPrepareRoom = function(room)
	if room then
		gLinkManager:SyncStageChange(room)
	end
end

GameToClientImpl.SyncPrepareRoomInvite = function(inviterPid, gameId, roomId)
	gLinkManager:SyncPrepareRoomInvite(inviterPid, gameId, roomId)
end

GameToClientImpl.SyncMatchRoomInvite = function(pid, gameId, roomId)
	gLinkManager:OnBeInviteToRoom(pid, gameId, roomId)
end

GameToClientImpl.SyncMatchRoomKicked = function()
	gLinkManager:OnBeKickOutFromRoom()
end

GameToClientImpl.SyncMatchInfo = function(matchInfo)
	gLinkManager:OnGetMatchInfo(matchInfo)
end

GameToClientImpl.SyncFerrisWheelInfo = function(infos)
	gFerrisMgr.ticketTypeList = {}

	L50.L50App.Scene.FerrisMgr:ClearTicketType()

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

GameToClientImpl.SyncKTVCurrentSession = function(packageTicket)
	if packageTicket and packageTicket.RemainCount <= 0 then
		gKTVGameManager:StoreTicket(packageTicket.TicketId, packageTicket.RemainCount)
	else
		gKTVGameManager:ClearTicket()
	end
end

local ResetEventConditionProgress = function(eventConditionIdList, progressInfo)
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

GameToClientImpl.SyncResetEventConditionProgress = function(module, eventConditionIdList, spiritId)
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
	elseif spiritId ~= gClientConst.MAX_INT then
		for _, progressInfo in pairs(curModuleEventProgressInfo.ProgressInfoDict) do
			ResetEventConditionProgress(eventConditionIdList, progressInfo)
		end
	else
		local progressInfo = curModuleEventProgressInfo.ProgressInfoDict[spiritId]

		ResetEventConditionProgress(eventConditionIdList, progressInfo)
	end

	gMessageManager:SendMessage(gEventConstants.ON_EVENT_CONDITION_PROGRESS_CHANGE)
end

GameToClientImpl.SyncChangeEventConditionProgress = function(module, spiritId, changeEventProgressInfoDict, finishEventConditionIdList, isUniverse)
	local curModuleEventProgressInfoDict = isUniverse and gPlayerManager.infoMinor.bindData.UniverseModuleEventProgressInfoDict or gPlayerManager.infoMinor.bindData.ModuleEventProgressInfoDict
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
				["n\\xa1\\xb7\\xa1\\xa2"] = 0,
				["0M\\x9f\\x89\\x97I"] = 0
			}
		}
		curModuleEventProgressInfo.ProgressInfoDict[spiritId] = curProgressInfo
	end

	if changeEventProgressInfoDict then
		for eventConditionId, eventProgressInfo in pairs(changeEventProgressInfoDict) do
			curProgressInfo.EventProgressInfoDict[eventConditionId] = eventProgressInfo
			local finishedTemplateIdList = curProgressInfo.FinishedTemplateIdList

			for idx, finishedTemplateId in ipairs(finishedTemplateIdList) do
				if finishedTemplateId ~= eventConditionId then
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

GameToClientImpl.SyncSpiritAbilityInfo = function(spiritId, info)
	gSpiritManager:SyncSpiritAbilityInfo(spiritId, info)
end

GameToClientImpl.SyncUrbanBadgeInfo = function(badgeId, badgeInfo)
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

GameToClientImpl.SyncSpiritBadgeInfo = function(spiritId, badgeId, badgeInfo)
	gSpiritManager:SyncSpiritBadgeInfo(spiritId, badgeId, badgeInfo)
end

GameToClientImpl.SyncSpiritJobInfo = function(spiritId, availableJobs, currentJob)
	gSpiritManager:SyncSpiritJobInfo(spiritId, availableJobs, currentJob)
	gMessageManager:SendMessage(gEventConstants.JOB_CHANGE_EVENT, currentJob)
end

GameToClientImpl.SyncPoliceNextOrder = function(id, eventId, selected, isComplete, selectTime)
	if not isComplete then
		if selected and selectTime ~= 0 then
			gPoliceJobManager:PoliceTaskRecover(id, eventId)
		else
			print_debug("同步警察订单")

			if gTaskUtils:GetTaskGuideCurType() == gTaskUtils.TaskGuideSubPanel.Police then
				gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
			end

			slot5 = gPoliceJobManager

			slot5:SendMessageToPanel(function ()
				gMessageManager:SendMessage(gEventConstants.POLICE_TASK_DISTRIBUTE, {
					id = id,
					eventId = eventId,
					selectTime = selectTime
				})
			end)
		end
	else
		gMessageManager:SendMessage(gEventConstants.POLICE_DROP_EVENT)
	end
end

GameToClientImpl.SyncPoliceCompleteMissionCnt = function(todayCompleteCnt)
	gPoliceJobManager:OnSyncMissionCount({
		["9\\xb9\\xf03v*1\\x82'啑6\\xad\\x96څ"] = 0,
		todayCompleteCnt = todayCompleteCnt
	})
end

GameToClientImpl.SyncPoliceMissionExamInfo = function(factIds, examTaskId, examIndex)
	slot3 = gPoliceJobManager

	slot3:SendMessageToPanel(function ()
		gMessageManager:SendMessage(gEventConstants.POLICE_FACT_START, {
			factIds = factIds,
			examTaskId = examTaskId,
			examIndex = examIndex
		})
	end)
end

GameToClientImpl.SyncSetSkyCountdownMode = function(mode, endTime)
	gSkyCountManager:SyncSetSkyCountdownMode(mode, endTime)
end

GameToClientImpl.SyncPoliceChargingSkillProgress = function(progress, maxLayer, speed)
	gPoliceChaseManager:SyncPoliceChargingSkillProgress(progress, maxLayer, speed)
end

GameToClientImpl.SyncSpiritHistoryJobInfo = function(spiritId, historyJobs)
	gSpiritManager:SyncSpiritHistoryJobInfo(spiritId, historyJobs)
end

GameToClientImpl.SyncClearReceivedFanStageLvRewards = function(stageIdList)
	local receivedStageLvRewards = gPlayerManager.infoMinor.bindData.receivedStageLvRewards

	for _, stageId in ipairs(stageIdList) do
		receivedStageLvRewards[stageId] = nil
	end

	gSocialNetworkUtils.OnClearStageRewards(stageIdList)
	gMessageManager:SendMessage(gEventConstants.ON_ENDORSEMENT_STAGE_LEVEL_REWARD_CHANGE)
end

GameToClientImpl.SyncPlayerFanInfo = function(fan12, fan123, level, levelRewardList, yesterdayFan, growthStageId, weeklyFanGrowth)
	local preFan12 = gPlayerManager.infoMinor.bindData.fan12
	local preFan123 = gPlayerManager.infoMinor.bindData.fan123
	local preLevel = gPlayerManager.infoMinor.bindData.level
	local isLevelUp = preLevel == level
	local isFanChange = preFan12 == fan12
	gPlayerManager.infoMinor.bindData.fan123 = fan123
	gPlayerManager.infoMinor.bindData.fan12 = fan12
	gPlayerManager.infoMinor.bindData.yesterdayFan = yesterdayFan
	gPlayerManager.infoMinor.bindData.level = level
	gPlayerManager.infoMinor.bindData.levelRewardList = levelRewardList
	gPlayerManager.infoMinor.bindData.growthStageId = growthStageId
	gPlayerManager.infoMinor.bindData.weeklyFanGrowth = weeklyFanGrowth

	gSocialNetworkUtils:FansChangeRecord(preFan123)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PLAYER_FAN_INFO)
	gMessageManager:SendMessage(gEventConstants.ON_PLAYER_FAN_CHANGE, {
		preExp = preFan123,
		currentExp = fan123
	})

	if gMainPhoneUtils.CheckAppCanShowInStore(LTConfig.MobileMenuSGuiConfig.SocialNetworkId) and isFanChange then
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

GameToClientImpl.SyncPlayerNpcProfileActivate = function(profileInfo)
	gAgentTrustManager:PopUpAgentProfile(profileInfo)
	gAgentTrustManager:UpdateProfileInfo(profileInfo)
end

GameToClientImpl.SyncPlayerNpcProfileTargetFinish = function(profileId, target)
	gAgentTrustManager:UpdateNpcProfileTargetFinish(profileId, target.TargetId)
end

GameToClientImpl.SyncPlayerNpcProfileRewardGot = function(profileId, rewardId)
	gAgentTrustManager:UpdateNpcProfileRewardGot(profileId, rewardId)
end

GameToClientImpl.SyncPlayerNpcProfileTrustValueChanged = function(info)
	if info.Reason ~= UX.Game.ItemReason.NpcProfileTarget then
		gAgentTrustManager:PopUpAgentProfileTrustChange(info.ProfileId, gAgentTrustManager:GetTrustValue(info.ProfileId), info.TrustValue)
	end

	gAgentTrustManager:UpdateNpcProfileTrustValue(info)
end

GameToClientImpl.SyncPlayerNpcProfileMultiTrustValueChanged = function(infos)
	for _, info in ipairs(infos) do
		if info.Reason ~= UX.Game.ItemReason.NpcProfileTarget then
			gAgentTrustManager:PopUpAgentProfileTrustChange(info.ProfileId, gAgentTrustManager:GetTrustValue(info.ProfileId), info.TrustValue)
		end

		gAgentTrustManager:UpdateNpcProfileTrustValue(info)
	end
end

GameToClientImpl.SyncPlayerNpcProfileTargetReset = function(target)
end

GameToClientImpl.SyncPlayerNpcProfileTargetAllReset = function()
end

GameToClientImpl.SyncPlayerPopularity = function(currPopularity, historyList)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo then
		popularityInfo.Popularity = currPopularity

		if gHotCenterManager then
			gHotCenterManager:RecordTodayHighestPopularity(currPopularity)
		end

		RefreshPopularityInfo(false)
	end
end

GameToClientImpl.SyncPlayerPopularityChange = function(currPopularity, incrementPopularityList)
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	if popularityInfo then
		popularityInfo.Popularity = currPopularity

		if gHotCenterManager then
			gHotCenterManager:RecordTodayHighestPopularity(currPopularity)
		end

		RefreshPopularityInfo(false)
	end
end

GameToClientImpl.SyncAcceptTruckJobOrder = function(id, orderInfo, deliveryAgentId, deliveryGadgetId)
	orderInfo.npcInstanceId = deliveryAgentId
	orderInfo.deliveryGadgetId = deliveryGadgetId

	gMessageManager:SendMessage(gEventConstants.ON_ACCEPT_TRUCK_JOB_ORDER, orderInfo)
	gMessageManager:SendMessage(gEventConstants.REFRESH_DELIVERY_DATA, {
		UniqueId = orderInfo.UniqueId,
		AcceptInfo = orderInfo.AcceptInfo
	})
end

GameToClientImpl.SyncTruckHighValueOrder = function(order)
	gMessageManager:SendMessage(gEventConstants.HIGH_VALUE_ORDER, order)
end

GameToClientImpl.SyncSpiritTalentExpAndLevel = function(spiritId, addExp, exp, level)
	gTalentTreeMgr:OnSyncSpiritTalentExpAndLevel(spiritId, addExp, exp, level, true)
end

GameToClientImpl.SyncSpiritJobTalentPoint = function(spiritId, jobClassId, talentPoint, reason)
	gTalentTreeMgr:OnSyncSpiritJobTalentPoint(spiritId, jobClassId, talentPoint, reason)
end

GameToClientImpl.SyncCommonSpiritTalentExp = function(changeExp, isAdd, exp)
end

GameToClientImpl.SyncActiveSpiritJobTalentLayer = function(spiritId, jobClassId, talentId, layer)
	gTalentTreeMgr:OnSyncActiveSpiritJobTalent(spiritId, jobClassId, talentId, layer)
end

GameToClientImpl.SyncActiveGameplayTalentLayer = function(gameplayId, talentId, layer)
	gTalentTreeMgr:OnSyncActiveGameplayTalent(gameplayId, talentId, layer)
end

GameToClientImpl.SyncGameplayTalentPoint = function(gameplayId, talentPoint, reason)
	gTalentTreeMgr:OnSyncGameplayTalentPoint(gameplayId, talentPoint, reason)
end

GameToClientImpl.SyncGameplayTalentExpAndLevel = function(gameplayId, addExp, exp, level)
	gTalentTreeMgr:OnSyncGameplayTalentExpAndLevel(gameplayId, addExp, exp, level)
end

GameToClientImpl.SyncPlayerPopularityCoinChanged = function(yesterdayCoinGet, todayCoinGet, totalLeftMoney, pastHoursCoinRewards)
end

GameToClientImpl.SyncFavorNpcSpoonAgentId = function(agentTag, spoonAgentId, Position, busyInfo)
	gNpcDaliyManager:OnSyncFavorNpcSpoonAgentId(agentTag, spoonAgentId, Position, busyInfo)
end

GameToClientImpl.SyncFavorNpcCommuteState = function(agentTag, isCommuting)
	gNpcDaliyManager:OnSyncFavorNpcCommuteState(agentTag, isCommuting)
end

GameToClientImpl.SyncFavorNpcCommuteStop = function(agentTags)
	gNpcDaliyManager:OnSyncFavorNpcCommuteStop(agentTags)
end

GameToClientImpl.SyncPlayerProduceInfo = function(availableProduces)
	gProduceManager:SetAvailableProduces(availableProduces)
end

GameToClientImpl.SyncScientistFactorMachineInfo = function(info)
	if gFactorMachineManager then
		gFactorMachineManager:OnSyncFactorMachineInfo(info.IsActivated, info.FactorDict, info.MatchGameBestRecords)
	end
end

GameToClientImpl.SyncSingleFactorStorage = function(factorConfigId, currentStorage)
	if gFactorMachineManager then
		gFactorMachineManager:OnSyncSingleFactorStorage(factorConfigId, currentStorage)
	end
end

GameToClientImpl.SyncCardFlipGameSettled = function(result)
	if gFactorMachineManager then
		gFactorMachineManager:OnSyncCardFlipGameSettled(result)
	end
end

GameToClientImpl.SyncEnchantPreviewResult = function(info)
	local bd = gPlayerManager and gPlayerManager.infoScientist and gPlayerManager.infoScientist.bindData

	if not bd then
		return
	end

	bd.PendingEnchantWeaponInstanceId = info.WeaponInstanceId
	bd.PendingEnchantSlots = info.NewSlots

	gMessageManager:SendMessage(gEventConstants.ENCHANT_PREVIEW_RESULT, info)
end

GameToClientImpl.SyncEnchantAffixUnlock = function(affixId)
	local bd = gPlayerManager and gPlayerManager.infoScientist and gPlayerManager.infoScientist.bindData

	if not bd then
		return
	end

	bd.UnlockedEnchantAffixIds[affixId] = true
end

GameToClientImpl.SyncTruckOrderResult = function(truckJobOrderWrap, preRankId, newRankId, rewardPoint)
	gMessageManager:SendMessage(gEventConstants.ON_TRUCK_ORDER_COMPLETED, truckJobOrderWrap)
	gDeliveryTaskManager:CompleteTruckOrder(truckJobOrderWrap, preRankId, newRankId, rewardPoint)
end

GameToClientImpl.SyncComputerNewUnlockEmail = function(computerEmail)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	if computerUnlockInfo then
		computerUnlockInfo.UnlockEmails[computerEmail.CfgId] = computerEmail
	end
end

GameToClientImpl.SyncComputerNewUnlockFile = function(computerFile)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	if computerUnlockInfo then
		computerUnlockInfo.UnlockFiles[computerFile.CfgId] = computerFile
	end
end

GameToClientImpl.SyncPoliceServiceData = function(spiritId, serviceData, weeklyServiceData, stopPatrol)
	gPoliceJobManager.panelMgr:OnPoliceServiceDataSync(spiritId, serviceData, weeklyServiceData)
	gPoliceJobManager:OpenPoliceEndPanel(spiritId, serviceData, stopPatrol)
end

GameToClientImpl.SyncSpiritPoliceJobInfo = function(spiritId, policeJobInfo)
	gPoliceJobManager.panelMgr:OnSpiritPoliceJobInfoSync(spiritId, policeJobInfo)
end

GameToClientImpl.SyncSpiritPoliceCaseInfos = function(spiritId, cases)
	gPoliceJobManager.panelMgr:OnSpiritPoliceCaseInfosSync(spiritId, cases)
end

GameToClientImpl.SyncSpiritPoliceViolationInfos = function(spiritId, violations)
	gPoliceJobManager.panelMgr:OnSpiritPoliceViolationInfosSync(spiritId, violations)
end

GameToClientImpl.SyncPoliceDispatchInfos = function(spiritId, dispatchInfos)
	gPoliceJobManager.panelMgr:OnPoliceDispatchInfosSync(spiritId, dispatchInfos)
end

GameToClientImpl.SyncPoliceFakeFileInfo = function(spiritId, policeFakeFileInfo)
	gPoliceJobManager.panelMgr:OnSyncPoliceFakeFileInfo(spiritId, policeFakeFileInfo)
end

GameToClientImpl.SyncPoliceFakeFileSingleInfo = function(spiritId, fakeFileId, singlePoliceFakeFileInfo)
	gPoliceJobManager.panelMgr:OnSyncPoliceFakeFileSingleInfo(spiritId, fakeFileId, singlePoliceFakeFileInfo)
end

GameToClientImpl.SyncPoliceAddFakeFileClueInfo = function(spiritId, clueInfo)
	gPoliceJobManager.panelMgr:OnSyncPoliceAddFakeFileClueInfo(spiritId, clueInfo)
end

GameToClientImpl.SyncPoliceDailyIncidentInfo = function(NowEffctIncidentConfigId, HasGetTodaysIncidentReward)
	gPoliceJobManager:OnSyncPoliceDailyIncidentInfo(NowEffctIncidentConfigId, HasGetTodaysIncidentReward)
end

GameToClientImpl.SyncInterrogationInterrupt = function(info)
	gPoliceJobManager.panelMgr:OnSyncInterrogationInterrupt(info)
end

GameToClientImpl.SyncTruckOrdersNewDay = function()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_TRUNK_ORDER_NEW_DAY)
end

GameToClientImpl.SyncTruckAbortedOrder = function(id)
	gMessageManager:SendMessage(gEventConstants.ON_TRUCK_ORDER_OBSOLETED, id)
end

GameToClientImpl.SyncTruckOrderWrap = function(order)
	gDeliveryTaskManager:ModifyOrderCargoInfo(order)
end

GameToClientImpl.SyncCurrentTruckOrder = function(id)
	gDeliveryTaskManager:ChangeCurOrderByUniqueId(id)
	gMessageManager:SendMessage(gEventConstants.ON_CURRENT_TRUCK_ORDER_CHANGE, id)
end

GameToClientImpl.SyncAllAcceptTruckOrder = function(orderInfo)
end

GameToClientImpl.SyncSpiritBeggarJobData = function(spiritId, data)
	gBeggarManager:OnSyncSpiritBeggarJobData(spiritId, data)
end

GameToClientImpl.SyncBeggarPaintRequest = function(npcInstanceId, drawThemeId, startTime, endTime)
	gBeggarManager:OnSyncNewPaintTask(npcInstanceId, drawThemeId, startTime, endTime)
end

GameToClientImpl.SyncBeggarAiPaintingDone = function(sourceObjectKey, resultObjectKey, success)
	gBeggarManager:OnSyncBeggarAiPaintingDone(sourceObjectKey, resultObjectKey, success)
end

GameToClientImpl.SyncBeggarAiPaintingAdd = function(info)
	gBeggarManager:OnSyncBeggarAiPaintingAdd(info)
end

GameToClientImpl.SyncBeggarAiPaintingRemove = function(imageIndex)
	gBeggarManager:SyncBeggarAiPaintingRemove(imageIndex)
end

GameToClientImpl.SyncSpiritGroupChatInfos = function(chats)
	gUrbanAbilityManager:SyncSpiritGroupChatInfos(chats)
end

GameToClientImpl.SyncSpiritMobileSkinPartInfo = function(spiritId, mobileSkinInfo, availableSkinParts)
	local spiritViewData = gSpiritManager:GetSpirit(spiritId)

	if spiritViewData and spiritViewData.SpiritInfo then
		spiritViewData.SpiritInfo.MobileSkinInfo = mobileSkinInfo
	end

	if availableSkinParts then
		gPlayerManager.infoSpirit.bindData.AvailableSkinParts = availableSkinParts
	end

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_SPIRIT_SKIN_PART_INFO_CHANGE)
end

GameToClientImpl.SyncPlayerMobileAppChanged = function(appList, changedList)
	gPlayerManager.infoSpirit.bindData.InstalledApps = appList

	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_INSTALL_STATE_CHANGE)
end

GameToClientImpl.SyncQuantumWalletInfo = function(quantumWalletStartTime)
	gCommonItemManager:OnSyncQuantumWalletInfo(quantumWalletStartTime)
end

GameToClientImpl.SyncUnlockInteractionActionItems = function(newActionItemList)
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

GameToClientImpl.SyncPlayerClubSimpleInfo = function(taskInfo)
	gClubManager:OnSyncPlayerClubSimpleInfo(taskInfo)
end

GameToClientImpl.SyncDivinerCustomerInfo = function(customerInfo)
	gDivinerManager:OnSyncDivinerCustomerInfo(customerInfo)
end

GameToClientImpl.SyncDivinerAIError = function(agentId, stage, error)
	gDivinerManager:OnSyncDivinerAIError(agentId, stage, error)
end

GameToClientImpl.SyncDivinerAIMessage = function(info)
	gDivinerManager:OnSyncDivinerAIMessage(info)
end

GameToClientImpl.SyncDivinerMilestoneSummary = function(agentId, clueId, summary)
	gDivinerManager:OnSyncDivinerMilestoneSummary(agentId, clueId, summary)
end

GameToClientImpl.SyncDivinerLiveChatMessage = function(messages, isSC)
	gDivinerManager:OnSyncDivinerLiveChatMessage(messages, isSC)
end

GameToClientImpl.SyncPortalItemInfo = function(raidId, position)
	gMapUtils:SyncPortalItem(raidId, position)
end

GameToClientImpl.SyncArmoryAddWeapon = function(weapon)
	gWeaponManager:SyncArmoryAddWeaponEx(LTConfig.SceneitemWeaponArmoryIndexConfig.WeaponArmoryIndex_World, weapon)
end

GameToClientImpl.SyncArmoryRemoveWeapon = function(id)
	gWeaponManager:SyncArmoryRemoveWeaponEx(LTConfig.SceneitemWeaponArmoryIndexConfig.WeaponArmoryIndex_World, id)
end

GameToClientImpl.SyncArmoryUpdateWeapon = function(weapon)
	gWeaponManager:SyncArmoryUpdateWeaponEx(LTConfig.SceneitemWeaponArmoryIndexConfig.WeaponArmoryIndex_World, weapon)
end

GameToClientImpl.SyncArmoryAddWeaponEx = function(armoryId, weapon)
	gWeaponManager:SyncArmoryAddWeaponEx(armoryId, weapon)
end

GameToClientImpl.SyncArmoryRemoveWeaponEx = function(armoryId, weaponInstanceId)
	gWeaponManager:SyncArmoryRemoveWeaponEx(armoryId, weaponInstanceId)
end

GameToClientImpl.SyncArmoryUpdateWeaponEx = function(armoryId, weapon)
	gWeaponManager:SyncArmoryUpdateWeaponEx(armoryId, weapon)
end

GameToClientImpl.SyncWeaponFightStyleChange = function(weaponInstanceId, fightStyleId)
	local weapon = gWeaponManager:GetWeaponByInstanceId(weaponInstanceId)

	if weapon then
		weapon.FightStyleId = fightStyleId

		gMessageManager:SendMessage(gEventConstants.WEAPON_FIGHT_STYLE_CHANGE, weaponInstanceId, fightStyleId)
	end
end

GameToClientImpl.PushJoinNewChatGroup = function(chatGroup)
	gChatGroupManager:PushJoinNewChatGroup(chatGroup)
end

GameToClientImpl.PushPlayerImSimpleData = function(simpleData)
	gChatGroupManager:PushPlayerImSimpleData(simpleData)
end

GameToClientImpl.SyncInviteeInvitePlayerInteractionAction = function(pid, actionId)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_INVITE_INTERACT, {
		pid = pid,
		actionId = actionId
	})
	gCS.BaseUnitUtils.InitCoUnitExceptionHanlder(pid)
	gCharMotionUtils.InvitePlayerInteractionAction(pid, actionId)
end

GameToClientImpl.SyncInviterReplyInvitePlayerInteractionAction = function(replyState)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_MOTION_ACTION_REPLAY_INVITE_RESULT, replyState)
end

GameToClientImpl.SyncCancelInviterPlayerInteractionAction = function(interactionActionState)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_CANCEL_INVITE_PLAYER_ACTION, interactionActionState)
end

GameToClientImpl.SyncCancelInviteePlayerInteractionAction = function(interactionActionState)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_CANCEL_INVITEE_PLAYER_ACTION, interactionActionState)
end

GameToClientImpl.SyncStartPlayerInteractionAction = function(ownerId)
	gCS.BaseUnitUtils.StartCoUnitExceptionHanlder()
	gCS.BaseUnitUtils.StartCoUnitSignalListener()
	gCharMotionUtils.SyncInviteeStartPlayAction(ownerId)
end

GameToClientImpl.SyncInviterPlayerInteractionAction = function(inviterState, inviteePid, actionItemId)
	if inviterState ~= UX.Game.InteractionActionState.Playing then
		slot3 = gClientToGameDelegate

		slot3:AskCancelInviterPlayerInteractionAction().Callback = function (errorId)
		end
	end
end

GameToClientImpl.SyncClearNpcGroupChatInfo = function(groupId)
	gNpcChatManager:ClearNpcGroupChatInfo(groupId)
end

GameToClientImpl.SyncNpcChatGroupRename = function(groupId, textId)
	local bindData = gPlayerManager.infoMinorNpcCultivation.bindData
	local playerNpcCultivationInfo = bindData.playerNpcCultivationInfo or {}
	bindData.playerNpcCultivationInfo = playerNpcCultivationInfo
	local chatGroupRenameDict = playerNpcCultivationInfo.chatGroupRenameDict or {}
	playerNpcCultivationInfo.chatGroupRenameDict = chatGroupRenameDict
	chatGroupRenameDict[groupId] = textId

	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_GROUP_NAME_CHANGED, {
		groupId = groupId,
		textId = textId
	})
end

GameToClientImpl.SyncClearNpcChatInfo = function(npcId)
	gNpcChatManager:ClearNpcChatInfo(npcId)
end

GameToClientImpl.SyncNpcChat = function(chatItem)
	gNpcChatManager:AddNewNpcChatItem(chatItem)
end

GameToClientImpl.SyncNpcChats = function(chatItems)
	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_MESSAGE_SKIP_ALL, chatItems)
end

GameToClientImpl.SyncRemoveNpcChat = function(chatId, asNpc)
	gNpcChatManager:RemoveNpcChatSegment(chatId, asNpc)
end

GameToClientImpl.SyncPlayerUnlockChatBubble = function(bubbleInfo)
	local chatInfo = gPlayerManager.infoMinor.bindData.ChatInfo
	chatInfo.UnlockBubbles = chatInfo.UnlockBubbles or {}
	chatInfo.UnlockBubbles[bubbleInfo.Id] = bubbleInfo

	gMessageManager:SendMessage(gEventConstants.SOCIAL_CHAT_BUBBLE_INFO_CHANGED)
end

GameToClientImpl.SyncPlayerUseChatBubble = function(bubbleId)
	local chatInfo = gPlayerManager.infoMinor.bindData.ChatInfo
	chatInfo.SelectedBubble = bubbleId

	gMessageManager:SendMessage(gEventConstants.SOCIAL_CHAT_BUBBLE_INFO_CHANGED)
end

GameToClientImpl.SyncNewNpcQueueEvent = function(eventInfo)
	gNpcDaliyManager:OnNewQueueEvent(eventInfo)
end

GameToClientImpl.SyncRemoveNpcQueueEvent = function(eventId)
	gNpcDaliyManager:OnQueueEventRemove(eventId)
end

GameToClientImpl.SyncNpcTodayEventsTriggerCount = function(totalTodayCount, lastTriggerTime, npcId, npcTodayCount)
	gNpcDaliyManager:OnQueueEventTriggerChange(totalTodayCount, lastTriggerTime, npcId, npcTodayCount)
end

GameToClientImpl.SyncResetNpcEventsTriggerCount = function()
	gNpcDaliyManager:OnQueueEvenetReset()
end

GameToClientImpl.SyncPlayerTeamInfo = function(teaminfo)
	gTeamManager:SyncPlayerTeamInfo(teaminfo)
end

GameToClientImpl.SyncPlayerJoinTeam = function(teamInfo)
	gTeamManager:SyncPlayerJoinTeam(teamInfo)
end

GameToClientImpl.SyncPlayerTeamMemberStateChange = function(teamId, playerSyncInfo)
	local vo = playerSyncInfo and playerSyncInfo.PlayerBasicInfo

	if vo and vo.Pid then
		gLinkManager.LinkMember[vo.Pid] = vo
		local memberInfo = playerSyncInfo.LinkPlanningBoardMemberInfo

		if memberInfo then
			gPlanningBoardManager:OnSyncLinkPlanningBoardMemberInfo(vo.Pid, memberInfo)
		end
	end

	gTeamManager:SyncPlayerTeamMemberStateChange(teamId, playerSyncInfo)
end

GameToClientImpl.SyncPlayerTeamSettingChange = function(teamId, setting)
	gTeamManager:SyncPlayerTeamSettingChange(teamId, setting)
end

GameToClientImpl.SyncPlayerCreateTeam = function(teamInfo)
	gTeamManager:SyncPlayerCreateTeam(teamInfo)
end

GameToClientImpl.SyncPlayerTeamMemberLeave = function(teamId, playerInfo)
	gTeamManager:SyncPlayerTeamMemberLeave(teamId, playerInfo)
end

GameToClientImpl.SyncPlayerTeamMemberKick = function(teamId, playerInfo)
	gTeamManager:SyncPlayerTeamMemberKick(teamId, playerInfo)
end

GameToClientImpl.SyncPlayerTeamMemberJoin = function(teamId, playerInfo)
	gTeamManager:SyncPlayerTeamMemberJoin(teamId, playerInfo)
end

GameToClientImpl.SyncPlayerTeamLeaderChange = function(teamId, playerInfo)
	gTeamManager:SyncPlayerTeamLeaderChange(teamId, playerInfo)
end

GameToClientImpl.SyncPlayerInviteToTeam = function(playerInfo, teamId)
	gTeamManager:SyncPlayerInviteToTeam(playerInfo, teamId)
end

GameToClientImpl.SyncPlayerResponseTeamInvite = function(playerInfo, teamId, reject)
	gTeamManager:SyncPlayerResponseTeamInvite(playerInfo, teamId, reject)
end

GameToClientImpl.SyncPlayerResponseTeamLeaderApply = function(oldLeader, teamId, reject)
	gTeamManager:SyncPlayerResponseTeamLeaderApply(oldLeader, teamId, reject)
end

GameToClientImpl.SyncPlayerTeamInvitationApply = function(teamId, inviter, invitee)
	gTeamManager:SyncPlayerTeamInvitationApply(teamId, inviter, invitee)
end

GameToClientImpl.SyncPlayerTeamApply = function(teamId, applier)
	gTeamManager:SyncPlayerTeamApply(teamId, applier)
end

GameToClientImpl.SyncPlayerChangeLeaderApply = function(teamId, applier)
	gTeamManager:SyncPlayerChangeLeaderApply(teamId, applier)
end

GameToClientImpl.SyncGameState = function(inMatch, multiPlayerId)
	gLinkManager.currentMultiPlayerId = inMatch and multiPlayerId or 0
	local myPid = gPlayerManager.infoLogin.bindData.pid

	if myPid and gLinkManager.LinkMember[myPid] then
		gLinkManager.LinkMember[myPid].InMatch = inMatch
	end

	gTeamManager:SyncTeamMemberInMatchState(myPid, inMatch)
end

GameToClientImpl.SyncUnlockPhoneContactOptions = function(ids)
	gCallPhoneUtils.SyncPhoneUnlockOptionIdList(ids)
end

GameToClientImpl.SyncInviteePlayerInteractionAction = function(inviterState, inviteePid, actionItemId)
	if inviterState ~= UX.Game.InteractionActionState.Playing then
		-- Nothing
	end
end

GameToClientImpl.SyncNewCityPediaInfo = function(cityPediaId)
	gBaiKeArchiveManager.OnSyncNewCityPediaInfo(cityPediaId)
end

GameToClientImpl.SyncCityPediaCreditUpdate = function(newTotalCredit, newLevel, itemType, itemId)
	local creditInfo = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CreditInfo

	if creditInfo then
		creditInfo.Credit = newTotalCredit
		creditInfo.Level = newLevel

		gMessageManager:SendMessage(gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE)
		gBaiKeArchiveManager.RefreshBaikePhoneAppRedDot()
	end
end

GameToClientImpl.SyncCityPediaBasicCreditInfo = function(credit, level)
	local creditInfo = gPlayerManager.infoMinor.bindData.playerCityPediaInfos.CreditInfo

	if creditInfo then
		creditInfo.Credit = credit
		creditInfo.Level = level

		gMessageManager:SendMessage(gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE)
		gBaiKeArchiveManager.RefreshBaikePhoneAppRedDot()
	end
end

GameToClientImpl.SyncFishRecordUpdate = function(fishConfigId, record)
	gBaiKeArchiveManager.OnSyncFishRecordUpdate(fishConfigId, record)
end

GameToClientImpl.SyncInviteRideNpcInfo = function(InviteRideNpcId, IsInviteRideNpcActive)
	gNpcFavorManager:OnSyncRideNpc(InviteRideNpcId, IsInviteRideNpcActive)
end

GameToClientImpl.SyncWasherMissionResult = function(result)
	gWasherManager.OnSyncWasherMissionResult(result)
end

GameToClientImpl.SyncTaskRoleTeam = function(roleTeam, enableRoleIds, tipRoleId, enableSwitch)
	gSpiritManager:SyncTaskRoleTeam(roleTeam, enableRoleIds, tipRoleId, enableSwitch)
end

GameToClientImpl.SyncWatchInteractionInfo = function(pid, name, type, context, isSource, isResponse)
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

GameToClientImpl.SyncCanWatchOther = function(canWatch, watchingPid)
	gLinkManager:OnSyncWatchState(canWatch, watchingPid)
end

GameToClientImpl.SyncPlanningBoardInfo = function(planningBoardInfo)
	gPlayerManager.infoMinor.bindData.planningBoardInfo = planningBoardInfo

	gMessageManager:SendMessage(gEventConstants.ON_PLANNING_BOARD_INFO_CHANGE)
end

GameToClientImpl.SyncBartenderElementStockOz = function(bartenderId, elementId, stockOz)
	print_debug("SyncBartenderElementStockOz", bartenderId, elementId, stockOz)
end

GameToClientImpl.SyncBartenderCustomerInfo = function(customerInfo)
	gBartendManager:OnSyncCustomerInfo(customerInfo)
end

GameToClientImpl.SyncPartyResponse = function(response, npcIdList)
	gPartyManager:OnSyncResponse(response, npcIdList)
end

GameToClientImpl.SyncPartySettleData = function(settleData)
	gPartyManager:OnSyncSettleData(settleData)
end

GameToClientImpl.SyncGangBossFullDetails = function(fullDetails)
	gGangMemberManager:SyncGangBossFullDetails(fullDetails)
end

GameToClientImpl.SyncGangBossGangMemberDetails = function(membersInfos)
	gGangMemberManager:SyncGangBossGangMemberDetails(membersInfos)
end

GameToClientImpl.SyncGangBossCurrentBattleAgentCount = function(count)
	gGangMemberManager:SyncGangBossCurrentBattleAgentCount(count)
end

GameToClientImpl.SyncGangBossSummonOrder = function(orderedTemplatedIds)
	gGangMemberManager:SyncGangBossSummonOrder(orderedTemplatedIds)
end

GameToClientImpl.SyncChargeInfo = function(chargeInfo)
	gPlayerManager.infoMinor.bindData.ChargeInfo = chargeInfo

	gMessageManager:SendMessage(gEventConstants.SYNC_CHARGE_INFO)
end

GameToClientImpl.SyncMonthlyPassInfo = function(monthlyPassInfo, rewardInfo)
	local mallInfo = gPlayerManager.infoMinor.bindData.MallInfo
	mallInfo.PlayerMonthlyPassInfo.MonthlyPassInfos[monthlyPassInfo.Id] = monthlyPassInfo

	gMessageManager:SendMessage(gEventConstants.SYNC_MONTHLY_PASS_INFO)

	if rewardInfo then
		gMallManager:HandleMonthlyPassReward(rewardInfo)

		if rewardInfo.BuyRewardInfo then
			gMallManager:UnlockMonthCardBuy()
		end
	end
end

GameToClientImpl.SyncChargeDeliveryResult = function(result)
	gMallManager:HandleChargeDeliveryResult(result)
end

GameToClientImpl.SyncLastRaidMultiPlayerId = function(multiPlayerId)
	gPlanningBoardManager.lastMultiPlayerId = multiPlayerId
end

GameToClientImpl.SyncExtractionShooterBagExpansionUnlocked = function(expansionId, bagConfigId)
	gExtractionShooterManager.SyncExtractionShooterBagExpansionUnlocked(expansionId, bagConfigId)
end

GameToClientImpl.SyncUpdateExtractionShooterGamePlayTypeTotalBringOutIncome = function(gamePlayTypeId, totalIncome)
	gExtractionShooterManager.SyncUpdateExtractionShooterGamePlayTypeTotalBringOutIncome(gamePlayTypeId, totalIncome)
end

GameToClientImpl.SyncExtractionShooterChangeBagCapacity = function(bagConfigId, newCapacity)
	gExtractionShooterManager.SyncExtractionShooterChangeBagCapacity(bagConfigId, newCapacity)
end

GameToClientImpl.SyncExtractionShooterSortBagResult = function(bagId, itemInfoList)
	gExtractionShooterManager.SyncExtractionShooterSortBagResult(bagId, itemInfoList)
end

GameToClientImpl.SyncExtractionShooterSetItemInfo = function(bagConfigId, itemInfo)
	gExtractionShooterManager.SyncExtractionShooterSetItemInfo(bagConfigId, itemInfo)
end

GameToClientImpl.SyncExtractionShooterBringOutValue = function(bringOutValue)
end

GameToClientImpl.SyncExtractionShooterRemoveItemInfo = function(bagConfigId, cellX, cellY)
	gExtractionShooterManager.SyncExtractionShooterRemoveItemInfo(bagConfigId, cellX, cellY)
end

GameToClientImpl.SyncExtractionShooterClearBag = function(bagConfigId)
	gExtractionShooterManager.SyncExtractionShooterClearBag(bagConfigId)
end

GameToClientImpl.SyncPlayerEnterExtractionShooter = function()
	gExtractionShooterManager.SyncPlayerEnterExtractionShooter()
end

GameToClientImpl.SyncExtractionShooterEvacuationPlace = function(evacuationPlaces)
	if gMapSubSystem_EvacuationPlace then
		gMapSubSystem_EvacuationPlace:SyncEvacuationPlaceData(evacuationPlaces)
	end

	gExtractionShooterManager:SyncExtractionShooterEvacuationPlace(evacuationPlaces)
end

GameToClientImpl.SyncExtractionShooterEvacuationRooms = function(innerRooms, outerRooms)
	gExtractionShooterManager:OnSyncRoomId(innerRooms, outerRooms)
end

GameToClientImpl.SyncBattlePassInfos = function(playerBattlePassInfos)
	if not playerBattlePassInfos or not playerBattlePassInfos.BattlePassInfoDict then
		return
	end

	gBattlePassMgr:SetSeasonalBpId(playerBattlePassInfos.CurrentSeasonalBattlePassId)

	for bpId, info in pairs(playerBattlePassInfos.BattlePassInfoDict) do
		gBattlePassMgr:SyncBattlePassInfo(info)
	end
end

GameToClientImpl.SyncBattlePassProgress = function(bpId, newLevel, newExp, newWeeklyExp)
	gBattlePassMgr:SyncBattlePassProgress(bpId, newLevel, newExp, newWeeklyExp)
end

GameToClientImpl.SyncBattlePassType = function(bpId, newPassType)
	gBattlePassMgr:SyncBattlePassType(bpId, newPassType)
end

GameToClientImpl.SyncBattlePassId = function(newId)
	gBattlePassMgr:SyncBattlePassId(newId)
end

GameToClientImpl.SyncBattlePassTasks = function(bpId, taskId, newState)
	gBattlePassMgr:SyncBattlePassTasks(bpId, taskId, newState)
end

GameToClientImpl.SyncWeeklyTaskCompletion = function(bpId, taskId, completionCount)
	gBattlePassMgr:SyncWeeklyTaskCompletion(bpId, taskId, completionCount)
end

GameToClientImpl.SyncBattlePassRewardClaimStates = function(bpId, updatedStates)
	gBattlePassMgr:SyncBattlePassRewardClaimStates(bpId, updatedStates)
end

GameToClientImpl.SyncCityHideAndSeekPlayerInfo = function(seekers, hiders)
	if gMapSubSystem_HideAndSeek then
		gMapSubSystem_HideAndSeek:ClearData()
		gMapSubSystem_HideAndSeek:CheckCurCamp(seekers, hiders)
		gMapSubSystem_HideAndSeek:TryAddSeekers(seekers)
		gMapSubSystem_HideAndSeek:TryAddHiders(hiders)
	end

	gHideAndSeekManager:SyncCityHideAndSeekPlayerInfo(seekers, hiders)
end

GameToClientImpl.SyncHideAndSeekGhostMice = function(rats)
	gHideAndSeekManager:SyncHideAndSeekGhostMice(rats)
	gMapSubSystem_HideAndSeek:SyncHideAndSeekGhostMice(rats)
end

GameToClientImpl.SyncStartGhostMode = function(pid)
	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		gMapSubSystem_HideAndSeek:SyncStartGhostMode()
	end

	gHideAndSeekManager:SyncStartGhostMode(pid)
end

GameToClientImpl.SyncStartHideAndSeekGame = function(endTime)
	slot1 = gMessageManager

	slot1:SendMessage(gEventConstants.ENTER_HIDE_AND_SEEK)

	param = {
		endTime = endTime
	}

	gPanelManager:CheckShow(gPanelId.S_ONLINE_MAP_COUNTDOWN_PANEL, param)
	gMapSubSystem_Player:HideTeamMember(true)
	gHudMgr:SetPlayersHeadInfoAllow(false, "HideAndSeek")
	gMapManager:SetMiniMapScale(LTConfig.HideAndSeekConfig.MapScale, gMapScaleType.HideAndSeek)
end

GameToClientImpl.SyncHideAndSeekEnd = function()
	gPanelManager:Close(gPanelId.S_ONLINE_MAP_COUNTDOWN_PANEL)
	gMapSubSystem_Player:HideTeamMember(false)
	gHudMgr:SetPlayersHeadInfoAllow(true, "HideAndSeek")
	gHideAndSeekManager:SyncHideAndSeekEnd()
	gMapManager:RemoveMiniMapScaleType(gMapScaleType.HideAndSeek)
end

GameToClientImpl.AskPSNSync = function()
end

GameToClientImpl.SyncPSNOnlySetting = function(PSNOnly)
	gLinkManager.isPSNOnly = PSNOnly
end

GameToClientImpl.SyncLinkPlanningBoardMultiPlayerIdStates = function(multiPlayerIdStates)
	if gPlayerManager.infoMinor.bindData.playerLinkPlanningBoardInfo then
		gPlayerManager.infoMinor.bindData.playerLinkPlanningBoardInfo.MultiPlayerIdStates = multiPlayerIdStates

		gPlanningBoardManager:OnSyncOwnMultiPlayerIdStates(multiPlayerIdStates)
		gMessageManager:SendMessage(gEventConstants.ON_PLAYER_MAX_MULTI_PLAYER_ID_CHANGE)
	end
end

GameToClientImpl.SyncLinkPlanningBoardMemberInfo = function(pid, info)
	gPlanningBoardManager:OnSyncLinkPlanningBoardMemberInfo(pid, info)
end

GameToClientImpl.SyncHideAndSeekEndTime = function(endTime)
	param = {
		endTime = endTime
	}

	gPanelManager:CheckShow(gPanelId.S_ONLINE_MAP_COUNTDOWN_PANEL, param)
end

GameToClientImpl.SyncHideAndSeekStage = function(stage)
end

GameToClientImpl.SyncExtractionShooterTokenCount = function(tokenCount)
	gExtractionShooterManager.SyncExtractionShooterTokenCount(tokenCount)
end

GameToClientImpl.SyncCollectionBookTotalScore = function(totalScore)
	gExtractionShooterManager.SyncCollectionBookTotalScore(totalScore)
end

GameToClientImpl.SyncCatMapMarker = function(targetPid, pos, expireTime)
	gMapSubSystem_HideAndSeek:SyncCatMapMarker(targetPid, expireTime)
end

GameToClientImpl.SyncShowUIEffectNotify = function(notifyParam)
	if notifyParam and notifyParam.OperatorType > 1 and notifyParam.OperatorType < 3 then
		gMessageManager:SendMessage(gEventConstants.ON_SHOW_UI_EFFECT, notifyParam)
	end
end

GameToClientImpl.SyncUpdateWorldLifeDropLimit = function(worldLifeType, count)
	local playerInfoAtmosphereGameplay = gPlayerManager.infoMinor.bindData.playerInfoAtmosphereGameplay
	playerInfoAtmosphereGameplay[worldLifeType] = count
end

GameToClientImpl.SyncClearWorldLifeDropLimit = function()
	gPlayerManager.infoMinor.bindData.playerInfoAtmosphereGameplay = {}
end

GameToClientImpl.SyncItemCompoundState = function(info)
	gCompoundManager:SyncItemCompoundState(info)
end

GameToClientImpl.SyncSubwayFare = function(fare)
	gMapSubSystem_Entrance:MapTeleport_SyncFare(fare)
end

GameToClientImpl.SyncSubmitItemState = function(changedItems)
	gCommonItemManager:OnSyncSubmitItemState(changedItems)
end

GameToClientImpl.SyncOnlineSeasonChanged = function(info)
	gMessageManager:SendMessage(gEventConstants.ONLINE_SEASON_CHANGED, info)
end

GameToClientImpl.SyncOnlineSeasonProgressState = function(data)
	gMessageManager:SendMessage(gEventConstants.ONLINE_SEASON_PROGRESS_FULL_SYNC, data)
end

GameToClientImpl.SyncOnlineSeasonProgressStateChanges = function(delta)
	gMessageManager:SendMessage(gEventConstants.ONLINE_SEASON_PROGRESS_STATE_CHANGED, delta)
end

GameToClientImpl.SyncFarmerOrders = function(orders)
	gFarmerManager:OnSyncOrders(orders)
end

GameToClientImpl.SyncFarmerOrderUpsert = function(orderConfigId, orderInfo)
	gFarmerManager:OnSyncOrderUpsert(orderConfigId, orderInfo)
end

GameToClientImpl.SyncFarmerOrderRemove = function(orderConfigId)
	gFarmerManager:OnSyncOrderRemove(orderConfigId)
end

GameToClientImpl.SyncFarmerShop = function(slots)
	gFarmerManager:OnSyncShop(slots)
end

GameToClientImpl.SyncFarmerShopSlot = function(shelfIndex, slot)
	gFarmerManager:OnSyncShopSlot(shelfIndex, slot)
end

GameToClientImpl.SyncFarmerIncome = function(income)
	gFarmerManager:OnSyncIncome(income)
end

GameToClientImpl.SyncFarmerSeason = function(seasonId, mutationConsumableIds, hotCropConsumableIdToPrice)
	gFarmerManager:OnSyncSeason(seasonId, mutationConsumableIds, hotCropConsumableIdToPrice)
end

GameToClientImpl.SyncMartialArtistRumorSlotInfo = function(wuxueId, slotInfo)
	gMartialArtistManager:OnSyncRumorSlotInfo(wuxueId, slotInfo)
end

GameToClientImpl.SyncMartialArtistAddRumorInBackpack = function(rumorId)
	gMartialArtistManager:OnSyncAddRumorInBackpack(rumorId)
end

GameToClientImpl.SyncMartialArtistRemoveRumorInBackpack = function(rumorId)
	gMartialArtistManager:OnSyncRemoveRumorInBackpack(rumorId)
end

GameToClientImpl.SyncFinishedWuxueId = function(wuxueId)
	gMartialArtistManager:OnSyncFinishedWuxueId(wuxueId)
end

GameToClientImpl.SyncMartialArtistAddCompletedQuest = function(questId)
	gMartialArtistManager:OnSyncAddCompletedQuest(questId)
end

GameToClientImpl.SyncMartialArtistAddUnlockedQuests = function(questIds)
	gMartialArtistManager:OnSyncAddUnlockedQuests(questIds)
end

GameToClientImpl.SyncMartialArtistTouTingResult = function(startDialogId, rumorIds)
	gMartialArtistManager:OnSyncMartialArtistTouTingResult(startDialogId, rumorIds)
end

GameToClientImpl.SyncPublicEventsList = function(infos)
	gTaskManager:OnSyncPublicEventsList(infos)
end

GameToClientImpl.SyncImageModeration = function(imageModerationResult)
	gAliOssManager:SyncImageModeration(imageModerationResult)
end

GameToClientImpl.SyncPlayerTradeInfo = function(info)
	gTradeManager:OnSyncPlayerTradeInfo(info)
end

GameToClientImpl.SyncTradeBoxCompositeProgress = function(boxId, progress)
	gTradeManager:OnSyncTradeBoxCompositeProgress(boxId, progress)
end

GameToClientImpl.SyncCustomRoomInfo = function(info)
	gCustomRoomMgr:OnSyncRoomInfo(info)
end

GameToClientImpl.SyncCustomRoomStatusChange = function(roomId, status, overTime)
	gCustomRoomMgr:OnSyncStatusChange(roomId, status, overTime)
end

GameToClientImpl.SyncCustomRoomSettingChange = function(roomId, setting)
	gCustomRoomMgr:OnSyncSettingChange(roomId, setting)
end

GameToClientImpl.SyncCustomRoomOwnerChange = function(roomId, newOwnerPid)
	gCustomRoomMgr:OnSyncOwnerChange(roomId, newOwnerPid)
end

GameToClientImpl.SyncCustomRoomMemberJoin = function(roomId, memberInfo)
	gCustomRoomMgr:OnSyncMemberJoin(roomId, memberInfo)
end

GameToClientImpl.SyncCustomRoomMemberLeave = function(roomId, memberPid)
	gCustomRoomMgr:OnSyncMemberLeave(roomId, memberPid)
end

GameToClientImpl.SyncCustomRoomMemberKick = function(roomId, memberPid)
	gCustomRoomMgr:OnSyncMemberKick(roomId, memberPid)
end

GameToClientImpl.SyncCustomRoomMemberReadyChange = function(roomId, memberPid, ready)
	gCustomRoomMgr:OnSyncMemberReadyChange(roomId, memberPid, ready)
end

GameToClientImpl.SyncCustomRoomDestroy = function(roomId)
	gCustomRoomMgr:OnSyncDestroy(roomId)
end

GameToClientImpl.SyncCustomRoomInvite = function(inviterInfo, roomId, roomName)
	gCustomRoomMgr:OnSyncInvite(inviterInfo, roomId, roomName)
end

GameToClientImpl.SyncCustomRoomApply = function(applierInfo, roomId)
	gCustomRoomMgr:OnSyncApply(applierInfo, roomId)
end

GameToClientImpl.SyncCustomRoomApplyResponse = function(roomId, approved)
	gCustomRoomMgr:OnSyncApplyResponse(roomId, approved)
end

GameToClientImpl.SyncPlayerGiftInfo = function(info)
	gMallGiftManager:OnSyncPlayerGiftInfo(info)
end

GameToClientImpl.SyncNewGift = function(gift, giftMessage)
	gMallGiftManager:OnSyncNewGift(gift, giftMessage)
end

GameToClientImpl.SyncMeccaGrandpaInfo = function(grandpaInfo)
	gOCMgr:OnSyncGrandpaInfo(grandpaInfo)
end

GameToClientImpl.SyncOCMemoryChange = function(change)
	gOCMgr:OnSyncMemoryChange(change)
end

GameToClientImpl.SyncMeccaGrandpaPartsInfo = function(info)
	gPlayerManager.infoMinor.bindData.MeccaGrandpaPartsInfo = info
end

GameToClientImpl.SyncLinkConfigUnlock = function(unlockedLinkConfigIds)
	gMapSubSystem_LinkGameplay:OnSyncLinkConfigUnlock(unlockedLinkConfigIds)
end

GameToClientImpl.SyncFishingGearAdd = function(gearInfo)
	local fishingInfo = gPlayerManager.infoMinor.bindData.FishingInfo
	fishingInfo.GearDict[gearInfo.UniqueId] = gearInfo
end

GameToClientImpl.SyncFishingGearRemove = function(uniqueId)
	gPlayerManager.infoMinor.bindData.FishingInfo.GearDict[uniqueId] = nil
end

GameToClientImpl.SyncFishAdd = function(fishInfo)
	local fishingInfo = gPlayerManager.infoMinor.bindData.FishingInfo
	local fishCfg = LTConfig.FishingFishConfig:GetConfig(fishInfo.TemplateId)

	if fishCfg and fishCfg.FishType ~= LTConfig.FishingFishConfig.FishTypeType.Consumable then
		fishingInfo.ConsumableFishDict[fishInfo.UniqueId] = fishInfo
	else
		fishingInfo.OrnamentalFishDict[fishInfo.UniqueId] = fishInfo
	end

	gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
end

GameToClientImpl.SyncFishRemove = function(uniqueId)
	local fishingInfo = gPlayerManager.infoMinor.bindData.FishingInfo

	if fishingInfo.ConsumableFishDict[uniqueId] then
		fishingInfo.ConsumableFishDict[uniqueId] = nil
	elseif fishingInfo.OrnamentalFishDict[uniqueId] then
		fishingInfo.OrnamentalFishDict[uniqueId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
end

GameToClientImpl.SyncFishPlacedChange = function(uniqueId, placedInfo)
	local fishInfo = gPlayerManager.infoMinor.bindData.FishingInfo.OrnamentalFishDict[uniqueId]

	if fishInfo then
		fishInfo.PlacedInfo = placedInfo
		fishInfo.IsPlaced = placedInfo == nil
	end

	gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
end

GameToClientImpl.SyncFishingSpotFull = function(info)
	if gFishingGameManager and gFishingGameManager.OnSyncFishingSpotFull then
		gFishingGameManager:OnSyncFishingSpotFull(info)
	end
end

GameToClientImpl.SyncFishingSpotFishAdd = function(spotId, addedFishes, poolCount)
	if gFishingGameManager and gFishingGameManager.OnSyncFishingSpotFishAdd then
		gFishingGameManager:OnSyncFishingSpotFishAdd(spotId, addedFishes, poolCount)
	end
end

GameToClientImpl.SyncFishingSpotFishRemove = function(spotId, fishId, poolCount)
	if gFishingGameManager and gFishingGameManager.OnSyncFishingSpotFishRemove then
		gFishingGameManager:OnSyncFishingSpotFishRemove(spotId, fishId, poolCount)
	end
end

GameToClientImpl.SyncHideAndSeekShowDetectHeadIcon = function(pid, iconId)
	local unitInfo = gLinkManager:GetUnitInfo(pid)

	if not unitInfo then
		print_error("当前不存在对应unit，Pid:", pid)

		return
	end

	gHudMgr:AddNpcIcon(unitInfo.Pid, iconId, 2)
end

GameToClientImpl.SyncHideAndSeekHideDetectHeadIcon = function(pid)
	local unitInfo = gLinkManager:GetUnitInfo(pid)

	if not unitInfo then
		print_error("当前不存在对应unit，Pid:", pid)

		return
	end

	gHudMgr:RemoveNpcIcon(unitInfo.Pid)
end

GameToClientImpl.SyncPlayerScenarioInfo = function(info)
	gPlayerManager.infoMinor.bindData.PlayerScenarioInfos = info

	gMessageManager:SendMessage(gEventConstants.ON_PLAYER_SCENARIO_INFO_CHANGED)
end

GameToClientImpl.SyncHUDRecommendUpsert = function(targetApp, info)
	gHudRecommendMgr:SyncHUDRecommendUpsert(targetApp, info)
end

GameToClientImpl.SyncHUDRecommendRemove = function(targetApp)
	gHudRecommendMgr:SyncHUDRecommendRemove(targetApp)
end

GameToClientImpl.SyncAllSpiritCombatPower = function(spiritCombatPowers)
	gCombatPowerManager:SyncAllSpiritCombatPower(spiritCombatPowers)
end

GameToClientImpl.SyncSpiritCombatPowerChanged = function(spiritId, combatPower)
	gCombatPowerManager:SyncSpiritCombatPowerChanged(spiritId, combatPower)
end

GameToClientImpl.SyncWushuTournamentRoundSettlement = function(info)
	gWushuTournamentManager:OnSyncWushuTournamentRoundSettlement(info)
end

GameToClientImpl.SyncChefRecipeUnlock = function(id)
	if gPlayerManager.infoMinor.bindData.ChefUnlockInfo.RecipeDict[id] then
		gPlayerManager.infoMinor.bindData.ChefUnlockInfo.RecipeDict[id].Unlock = true
	else
		gPlayerManager.infoMinor.bindData.ChefUnlockInfo.RecipeDict[id] = {
			[")F\\x9d\\x81\\x80J"] = true
		}
	end
end

GameToClientImpl.SyncSceneFogMapValue = function(sceneId, changeValueBytes)
	if not changeValueBytes then
		return
	end

	LX6.Gps.MapFogDataMgr.UnlockTile(sceneId, changeValueBytes)
end

GameToClientImpl.SyncPlayerSettings = function(settings)
	gSettingServerManager:SyncFromServer(settings)
end

GameToClientImpl.SyncMapPins = function(mapPins)
	if gMapSubSystem_Pin then
		gMapSubSystem_Pin:SyncMapPins(mapPins)
	end
end

GameToClientImpl.SyncFortuneResult = function(gadgetId, fortuneResultData)
	local store = gStoreManager:GetStoreGroup("FortunePanelStore")

	if store then
		store:OnSyncFortuneResult(gadgetId, fortuneResultData)
	end
end

return GameToClientImpl
