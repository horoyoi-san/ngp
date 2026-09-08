-- Original chunk: @Lua\LuaFiles\LX6\Manager\ExtractionShooterManager.lua
-- Decompiled from: 00238_ExtractionShooterManager.lua_b0c1ba0ddc4b.luajit

C_ExtractionShooterManager = DefClass("C_ExtractionShooterManager", C_ExtractionShooterManager, nil, )
local M = C_ExtractionShooterManager
local SUCCESS_SETTLE_TIMELINE_NAME = "ol_play_SDC_leave"
local BAG_CONFIG_ID = LTConfig.ExtractionShooterBagConfig
local EVACUATION_PLACE_EFFECT_ID = 53800112

M.ctor = function(self)
	self.innerRoomId = {}
	self.outerRoomId = {}
	self.placeDatas = {}
	self.evacuationPlaceEffectUUIDs = {}
	self.tarkovBagMetaMap = nil
	self.tarkovStashBagConfigIdsByGamePlayTypeId = nil
	self.collectionBookTotalScore = 0
	self.bringOutFundDict = {}

	gMessageManager:AddMessageListener(gEventConstants.ON_ENTER_EXTRACTION_SHOOTER_EVACUATION_PLACE, self:CreateAction("OnEnterEvacuationPlace"))
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.NewScene or switchType ~= gSwitchSceneType.KickToLogin then
		self.containerInfoMap = {}
		local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()

		if extractionShooterInfo then
			extractionShooterInfo.EquippedWeaponBagConfigId = 0
			extractionShooterInfo.EquippedWeaponSlotIndex = 0
		end
	end
end

M.OnEnterEvacuationPlace = function(self)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.ExtractionPlace)
end

M.ShowEndPanel = function(self, isSuccess)
	local bagPanelData = gPanelManager.panelData[gPanelId.ANANTARKOV_BAG_PANEL]

	if gPanelManager:IsPanelShowing(gPanelId.ANANTARKOV_END_PANEL) or gPanelManager:IsPanelShowing(gPanelId.COMMON_TEAM_RANK) or bagPanelData and bagPanelData.activeEndMode then
		return
	end

	gPanelManager:Close(gPanelId.ANANTARKOV_BAG_PANEL)

	local openAnantarkovEndPanel = function()
		gPanelManager:CheckShow(gPanelId.ANANTARKOV_END_PANEL, {
			isSuccess = isSuccess
		})
	end

	local extractionPointId = isSuccess and gLinkManager.selfOnlineChallengeData.extractionSettleData.ExtractionPointId

	local playSuccessVideoThenOpen = function()
		if not isSuccess then
			openAnantarkovEndPanel()

			return
		end

		local timelineData = gTimelineManager:Timeline_CreateTimelineData()

		if not extractionPointId then
			openAnantarkovEndPanel()

			return
		end

		local timelineRoot = LX6.Item.GadgetMgr.Instance:GetExtractionTimelineRoot(extractionPointId)

		if not timelineRoot then
			openAnantarkovEndPanel()

			return
		end

		timelineData.pos = timelineRoot.transform.position
		timelineData.rot = timelineRoot.transform.eulerAngles
		timelineData.onFinishCallback = openAnantarkovEndPanel

		gTimelineManager:Timeline_LoadAndPlay(SUCCESS_SETTLE_TIMELINE_NAME, timelineData)
	end

	coroutine.start(function ()
		coroutine.wait(1)
		playSuccessVideoThenOpen()
	end)
end

M.OnEndPanelContinue = function(self, isSuccess)
	if gLinkManager.currentGameCfg then
		self:ShowEndTeamRankPanel(isSuccess, gPanelId.ANANTARKOV_END_PANEL)

		return
	end

	self:ShowEndBagPanel()
end

M.ShowEndTeamRankPanel = function(self, isSuccess, previousPanelId)
	gLinkManager:OpenFinalRankPanel(isSuccess, function ()
		self:ShowEndBagPanel(isSuccess)
	end, function ()
		gPanelManager:Close(previousPanelId)
	end)
end

M.ShowEndBagPanel = function(self, isSuccess)
	local exitButtonClick = self:CreateAction("OnClickEndBagExitButton")

	if isSuccess == nil then
		exitButtonClick = self:CreateActionWithArgs(self.OnClickEndBagExitButton, isSuccess)
	end

	gPanelManager:CheckShowSync(gPanelId.ANANTARKOV_BAG_PANEL, {
		["\\xe0K%\\xd59\\xb8E\\x8cY\\xb4\\xb3"] = true,
		nextButtonClick = self:CreateAction("OnClickEndBagNextButton"),
		exitButtonClick = exitButtonClick
	})
end

M.OnClickEndBagExitButton = function(self, isSuccess)
	if isSuccess == nil then
		self:ShowEndTeamRankPanel(isSuccess, gPanelId.ANANTARKOV_BAG_PANEL)

		return
	end
end

M.OnClickEndBagNextButton = function(self)
	if gLinkManager:CheckInMatchMode() then
		gLinkManager:AskLeaveGame()
	end

	gPanelManager:Close(gPanelId.ANANTARKOV_BAG_PANEL)
	gPanelManager:Close(gPanelId.ANANTARKOV_END_PANEL)
end

M.GetMainTabListViewData = function(gameTypeId)
	local viewDataList = {}
	local count = LTConfig.ExtractionShooterHomePageConfig.count

	for i = 0, count - 1 do
		local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.LoadAt(i)
		local hasUnlocked = true

		if homePageCfg.SystemUnlockId <= 0 then
			hasUnlocked = gSystemUnlockMgr:IsUnlock(homePageCfg.SystemUnlockId)
		end

		if hasUnlocked and homePageCfg.Type ~= LTConfig.ExtractionShooterHomePageConfig.TypeType.Normal and homePageCfg.GameType ~= gameTypeId then
			table.insert(viewDataList, {
				id = homePageCfg.Id,
				title = homePageCfg.Name
			})
		end
	end

	table.sort(viewDataList, function (data1, data2)
		local id1 = data1.id
		local id2 = data2.id
		local homePageCfg1 = LTConfig.ExtractionShooterHomePageConfig.GetConfig(id1)
		local homePageCfg2 = LTConfig.ExtractionShooterHomePageConfig.GetConfig(id2)

		if homePageCfg1.SortOrder == homePageCfg2.SortOrder then
			return homePageCfg1.SortOrder <= homePageCfg2.SortOrder
		end

		return id1 <= id2
	end)

	return viewDataList
end

M.OpenMainTabPagePanel = function(gameTypeId)
	local viewDataList = gExtractionShooterManager.GetMainTabListViewData(gameTypeId)
	local data = viewDataList and viewDataList[1]

	if not data then
		print_error("@linminghe OpenMainTabPagePanel error gameTypeId", gameTypeId)

		return
	end

	local id = data.id
	local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(id)
	local panelId = homePageCfg.OpenPanelId

	gMainPageManager:LockMainPage(panelId)
	gPanelManager:CheckShow(panelId, {
		homePageId = id
	})
	gPanelManager:CheckShow(gPanelId.ANANTARKOV_MAIN_PANEL, {
		currentPageId = id,
		gameTypeId = gameTypeId
	})
end

M.OnSyncRoomId = function(self, innerRoomIds, outerRoomIds)
	local newInner = {}

	for i = 1, #innerRoomIds do
		newInner[innerRoomIds[i]] = true
	end

	local newOuter = {}

	for i = 1, #outerRoomIds do
		newOuter[outerRoomIds[i]] = true
	end

	self.innerRoomId = newInner
	self.outerRoomId = newOuter

	self:RefreshEvacuationPlaceEffects()
end

M.CheckInInnerExPoint = function(self, roomId)
	return self.innerRoomId[roomId] ~= true
end

M.CheckInOuterExPoint = function(self, roomId)
	return self.outerRoomId[roomId] ~= true
end

M.RefreshEvacuationPlaceEffects = function(self)
	self.placeDatas = self.placeDatas or {}
	self.evacuationPlaceEffectUUIDs = self.evacuationPlaceEffectUUIDs or {}

	for id, uuid in pairs(self.evacuationPlaceEffectUUIDs) do
		if not self.innerRoomId[id] or not self.placeDatas[id] then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(uuid)

			self.evacuationPlaceEffectUUIDs[id] = nil
		end
	end

	for id in pairs(self.placeDatas) do
		local placeData = self.placeDatas[id]
		local roomShape = placeData and placeData.InnerRoomShape
		local roomId = roomShape and roomShape.roomId

		if roomShape and roomShape.Center and roomId then
			for innerRoomId in pairs(self.innerRoomId) do
				if innerRoomId ~= roomId and not self.evacuationPlaceEffectUUIDs[id] and roomShape and roomShape.Center then
					local center = roomShape.Center
					local pos = Vector3.New(center.X, center.Y, center.Z)
					self.evacuationPlaceEffectUUIDs[id] = gCS.EffectMgr:PlayEffect(EVACUATION_PLACE_EFFECT_ID, LX6.Effect.EffectPlayTag.Gameplay, pos, Vector3.zero, Vector3.one, 0, -1)
				end
			end
		end
	end
end

M.SyncExtractionShooterSetItemInfo = function(bagConfigId, itemInfo)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	local itemInfoList = bagInfo and bagInfo.ItemInfoList

	if itemInfoList then
		local hasFound = false

		for index, info in ipairs(itemInfoList) do
			if info.CellX ~= itemInfo.CellX and info.CellY ~= itemInfo.CellY then
				hasFound = true
				itemInfoList[index] = itemInfo

				break
			end
		end

		if not hasFound then
			table.insert(itemInfoList, itemInfo)
		end

		if gCommonItemManager:IsBulletItem(itemInfo.Id) then
			gMessageManager:SendMessage(gEventConstants.BULLET_ITEM_CHANGED, itemInfo.Id)
		end

		gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_UPDATE, bagConfigId, itemInfo)
	end
end

M.SyncExtractionShooterRemoveItemInfo = function(bagConfigId, cellX, cellY)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	local itemInfoList = bagInfo and bagInfo.ItemInfoList

	if itemInfoList then
		local removedTemplateId = nil

		for index, itemInfo in ipairs(itemInfoList) do
			if itemInfo.CellX ~= cellX and itemInfo.CellY ~= cellY then
				removedTemplateId = itemInfo.Id

				table.remove(itemInfoList, index)

				break
			end
		end

		if removedTemplateId and gCommonItemManager:IsBulletItem(removedTemplateId) then
			gMessageManager:SendMessage(gEventConstants.BULLET_ITEM_CHANGED, removedTemplateId)
		end

		gMessageManager:SendMessage(gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_REMOVE, bagConfigId)
	end
end

M.SyncExtractionShooterContainerInfo = function(self, containerInstanceId, containerInfo)
	self.containerInfoMap = self.containerInfoMap or {}
	self.containerInfoMap[containerInstanceId] = containerInfo

	gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_CONTAINER_UPDATE, containerInstanceId)
end

M.SyncExtractionShooterClearBag = function(bagConfigId)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)

	if bagInfo then
		bagInfo.ItemInfoList = {}

		gMessageManager:SendMessage(gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_CLEAR, bagConfigId)
	end
end

M.SyncPlayerEnterExtractionShooter = function()
	gPanelManager:CheckShow(gPanelId.ANANTARKOV_HUD_PANEL)
	gMessageManager:SendMessage(gEventConstants.ON_ENTER_EXTRACTION_SHOOTER)

	gExtractionShooterManager.placeDatas = {}
	gExtractionShooterManager.evacuationPlaceEffectUUIDs = {}
end

M.SyncExtractionShooterTokenCount = function(tokenCount)
	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()

	if extractionShooterInfo then
		extractionShooterInfo.TokenCount = tokenCount
	end
end

M.SyncCollectionBookTotalScore = function(totalScore)
	gExtractionShooterManager.collectionBookTotalScore = totalScore

	gMessageManager:SendMessage(gEventConstants.ON_COLLECTION_BOOK_TOTAL_SCORE_UPDATE)
end

M.SyncUpdateExtractionShooterBringOutFund = function(gamePlayTypeId, fund)
	gExtractionShooterManager.bringOutFundDict[gamePlayTypeId] = fund

	gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_BRING_OUT_CHANGE, gamePlayTypeId)
end

M.SyncAllExtractionShooterBringOutFunds = function(funds)
	gExtractionShooterManager.bringOutFundDict = {}

	for gamePlayTypeId, fund in pairs(funds) do
		gExtractionShooterManager.bringOutFundDict[gamePlayTypeId] = fund
	end

	gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_BRING_OUT_CHANGE)
end

M.SyncExtractionShooterChangeBagCapacity = function(bagConfigId, capacity)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	bagInfo.Capacity = capacity

	gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_BAG_CAPACITY_CHANGE, bagConfigId)
end

M.SyncExtractionShooterSortBagResult = function(bagId, itemInfoList)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagId)

	if bagInfo then
		bagInfo.ItemInfoList = itemInfoList

		gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_SORT_BAG_RESULT, bagId)
	end
end

M.SyncExtractionShooterBagExpansionUnlocked = function(expansionId, _)
	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()

	if not extractionShooterInfo then
		return
	end

	local unlockedExpansionIds = extractionShooterInfo.UnlockedExpansionIds or {}
	unlockedExpansionIds[expansionId] = true
	extractionShooterInfo.UnlockedExpansionIds = unlockedExpansionIds
	local expansionCfg = LTConfig.ExtractionShooterBagExpansionConfig.GetConfig(expansionId)
	local bagConfigId = expansionCfg.BelongBagId <= 0 and expansionCfg.BelongBagId or expansionCfg.BagAddId

	gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_BAG_EXPANSION_SUCCESS, bagConfigId)
end

M.SyncExtractionShooterEvacuationPlace = function(self, dict)
	self.placeDatas = dict or {}
end

M.SyncUpdateExtractionShooterGamePlayTypeTotalBringOutIncome = function(gamePlayTypeId, totalIncome)
	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()

	if extractionShooterInfo then
		local gamePlayTypeTotalBringOutIncome = extractionShooterInfo.GamePlayTypeTotalBringOutIncome or {}
		gamePlayTypeTotalBringOutIncome[gamePlayTypeId] = totalIncome
	end
end

M.AskExtractionShooterShiftItem = function(self, srcBagConfigId, fromCellX, fromCellY, toBagConfigId, toCellX, toCellY, isRotated, callback)
	isRotated = isRotated or false

	gClientToGameDelegate:AskExtractionShooterShiftItem(srcBagConfigId, fromCellX, fromCellY, toBagConfigId, toCellX, toCellY, isRotated).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
			gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_SHIFT_FAIL)

			return
		end

		if callback then
			callback()
		end
	end
end

M.AskExtractionShooterShiftContainerItemToBag = function(self, containerInstanceId, fromCellX, fromCellY, bagConfigId, toCellX, toCellY, isRotated)
	isRotated = isRotated or false
	local containerInfo = gExtractionShooterManager:GetContainerInfo(containerInstanceId)
	local itemInfoList = containerInfo.ItemList
	local targetItemInfo = nil

	for _, itemInfo in ipairs(itemInfoList) do
		if itemInfo.CellX ~= fromCellX and itemInfo.CellY ~= fromCellY then
			targetItemInfo = itemInfo

			break
		end
	end

	if not gExtractionShooterManager.CheckCellAllowed(bagConfigId, targetItemInfo.Id) then
		return
	end

	if gExtractionShooterManager.CheckIsSlotGroupBag(bagConfigId) then
		self:AskExtractionShooterShiftContainerItemToSlot(containerInstanceId, fromCellX, fromCellY, bagConfigId, toCellX)

		return
	end

	gClientToGameSceneDelegate:AskExtractionShooterShiftContainerItemToBag(containerInstanceId, fromCellX, fromCellY, bagConfigId, toCellX, toCellY, isRotated).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
			gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_SHIFT_FAIL)

			return
		end
	end
end

M.AskExtractionShooterRemoveItem = function(self, bagConfigId, cellX, cellY)
	if gCS.LuaUtils.CheckHasObstacleInFront(gCS.MyPlayerManager.PlayerUnit, LTConfig.ExtractionShooterConfig.DropItemDistance) then
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.DropItemFail)

		return
	end

	gClientToGameDelegate:AskExtractionShooterRemoveItem(bagConfigId, cellX, cellY).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
		local itemInfoList = bagInfo and bagInfo.ItemInfoList

		if itemInfoList then
			for index, itemInfo in ipairs(itemInfoList) do
				if itemInfo.CellX ~= cellX and itemInfo.CellY ~= cellY then
					table.remove(itemInfoList, index)
					gMessageManager:SendMessage(gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_REMOVE, bagConfigId)

					break
				end
			end
		end
	end
end

M.AskExtractionShooterShiftBagItemToContainer = function(self, bagConfigId, itemInfo, containerInstanceId, toCellX, toCellY, isRotated)
	isRotated = isRotated or false

	if not gExtractionShooterManager.CheckCellAllowed(bagConfigId, itemInfo.Id) then
		return
	end

	if gExtractionShooterManager.CheckIsSlotGroupBag(bagConfigId) then
		self:AskExtractionShooterShiftSlotItemToContainer(bagConfigId, itemInfo.CellX, containerInstanceId, toCellX, toCellY, isRotated)

		return
	end

	gClientToGameSceneDelegate:AskExtractionShooterShiftBagItemToContainer(bagConfigId, itemInfo.CellX, itemInfo.CellY, containerInstanceId, toCellX, toCellY, isRotated).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
			gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_SHIFT_FAIL)

			return
		end
	end
end

M.AskExtractionShooterRemoveContainerItem = function(self, containerInstanceId, cellX, cellY)
	if gCS.LuaUtils.CheckHasObstacleInFront(gCS.MyPlayerManager.PlayerUnit, LTConfig.ExtractionShooterConfig.DropItemDistance) then
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.DropItemFail)

		return
	end

	gClientToGameSceneDelegate:AskExtractionShooterRemoveContainerItem(containerInstanceId, cellX, cellY).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local containerInfo = self:GetContainerInfo(containerInstanceId)

		if containerInfo then
			local itemInfoList = containerInfo.ItemList

			for index, itemInfo in ipairs(itemInfoList) do
				if itemInfo.CellX ~= cellX and itemInfo.CellY ~= cellY then
					table.remove(itemInfoList, index)
					gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_CONTAINER_ITEM_REMOVE)

					break
				end
			end
		end
	end
end

M.AskExtractionShooterShiftContainerItem = function(self, containerInstanceId, fromCellX, fromCellY, toCellX, toCellY, isRotated)
	isRotated = isRotated or false

	gClientToGameSceneDelegate:AskExtractionShooterShiftContainerItem(containerInstanceId, fromCellX, fromCellY, toCellX, toCellY, isRotated).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskExtractionShooterEndSearchContainer = function(self, containerInstanceId)
	gClientToGameSceneDelegate:AskExtractionShooterEndSearchContainer(containerInstanceId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskExtractionShooterSplitItem = function(self, bagConfigId, splitCellX, splitCellY, splitCount, isRotated)
	isRotated = isRotated or false

	gClientToGameDelegate:AskExtractionShooterSplitItem(bagConfigId, splitCellX, splitCellY, splitCount, isRotated).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_SPLIT_ITEM, bagConfigId)
	end
end

M.AskExtractionShooterRaidSplitItem = function(self, bagConfigId, containerInstanceId, splitCellX, splitCellY, splitCount, isRotated)
	isRotated = isRotated or false

	gClientToGameSceneDelegate:AskExtractionShooterRaidSplitItem(bagConfigId, containerInstanceId, splitCellX, splitCellY, splitCount, isRotated).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_RAID_SPLIT_ITEM)
	end
end

M.AskSellItem = function(self, bagConfigId, sellCellX, sellCellY, sellCount, sellMoney)
	gClientToGameDelegate:AskSellItem(bagConfigId, sellCellX, sellCellY, sellCount).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local messageContent = LTConfig.ExtractionShooterConfig.SellItemSuccessTips:format(sellMoney)

		gDisplayMessageMgr:ShowMessageContent(messageContent)
		gMessageManager:SendMessage(gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_SELL_ITEM, bagConfigId)
	end
end

M.AskBringOutItem = function(self, bagConfigId, cellX, cellY)
	gClientToGameDelegate:AskBringOutItem(bagConfigId, cellX, cellY).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskExtractionShooterBagExpansion = function(self, expansionId)
	gClientToGameDelegate:AskExtractionShooterBagExpansion(expansionId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskExtractionShooterSortBag = function(self, bagId, callback)
	gClientToGameDelegate:AskExtractionShooterSortBag(bagId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		if callback then
			callback()
		end
	end
end

M.AskExtractionShooterTransferAllToStash = function(self)
	gClientToGameDelegate:AskExtractionShooterTransferAllToStash().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskGeneralBuyBackExtractionShooterItemToShop = function(self, shopId, slotList)
	gClientToGameDelegate:AskGeneralBuyBackExtractionShooterItemToShop(shopId, slotList).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_EXTRACTION_SHOOTER_SELL_ITEM_TO_SHOP)
	end
end

M.AskExtractionShooterShiftSlotItemToContainer = function(self, bagConfigId, fromIndex, containerInstanceId, toCellX, toCellY, isRotated)
	isRotated = isRotated or false

	gClientToGameSceneDelegate:AskExtractionShooterShiftSlotItemToContainer(bagConfigId, fromIndex, containerInstanceId, toCellX, toCellY, isRotated).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskExtractionShooterShiftContainerItemToSlot = function(self, containerInstanceId, fromCellX, fromCellY, bagConfigId, slotIndex)
	gClientToGameSceneDelegate:AskExtractionShooterShiftContainerItemToSlot(containerInstanceId, fromCellX, fromCellY, bagConfigId, slotIndex).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.OnSearchContainer = function(self, containerInstanceId, containerNameId, itemContainerId)
	gClientToGameSceneDelegate:AskExtractionShooterSearchContainer(containerInstanceId).Callback = function (errorId, extractionShooterContainerInfo)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		print_notice("ExtractionShooterContainerInfo:", inspect(extractionShooterContainerInfo))
		self:SyncExtractionShooterContainerInfo(containerInstanceId, extractionShooterContainerInfo)
		gPanelManager:CheckShow(gPanelId.ANANTARKOV_BAG_PANEL, {
			containerInstanceId = containerInstanceId,
			containerNameId = containerNameId,
			itemContainerId = itemContainerId
		})
	end
end

M.GetContainerInfo = function(self, containerInstanceId)
	return self.containerInfoMap and self.containerInfoMap[containerInstanceId]
end

M.GetBagTotalPriceAndWeight = function(gamePlayTypeId)
	local bagStoreSet = gExtractionShooterManager.GetBagStoreSet(gamePlayTypeId)
	local bagIdList = {
		bagStoreSet.normal,
		bagStoreSet.safebox,
		bagStoreSet.strengthen,
		bagStoreSet.shield,
		bagStoreSet.wheel
	}
	local totalPrice = 0
	local totalWeight = 0

	for _, bagId in ipairs(bagIdList) do
		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagId)

		for _, itemInfo in ipairs(bagInfo.ItemInfoList) do
			local itemId = itemInfo.Id
			local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemId)
			local price = gExtractionShooterManager.GetItemSystemPrice(itemId) * itemInfo.StackCount
			local weight = itemCfg.Weight * itemInfo.StackCount
			totalPrice = totalPrice + price
			totalWeight = totalWeight + weight
		end
	end

	return totalPrice, totalWeight
end

M.GetExtractionShooterInfo = function()
	return gPlayerManager.infoMinor.bindData.extractionShooterInfo
end

M.GetBagInfoByConfigId = function(bagConfigId)
	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()

	if not extractionShooterInfo then
		return {}
	end

	local bagInfo = extractionShooterInfo.Bags and extractionShooterInfo.Bags[bagConfigId] or extractionShooterInfo.SlotGroups and extractionShooterInfo.SlotGroups[bagConfigId]

	return bagInfo or {}
end

M.BuildTarkovBagMetaMap = function(self)
	self.tarkovBagMetaMap = {}
	self.tarkovStashBagConfigIdsByGamePlayTypeId = {}
	local bagConfig = LTConfig.ExtractionShooterBagConfig

	if not bagConfig then
		return
	end

	for index = 0, bagConfig.count - 1 do
		local cfg = bagConfig.LoadAt(index)

		if cfg then
			self.tarkovBagMetaMap[cfg.Id] = {
				gamePlayTypeId = cfg.GameplayType,
				type = cfg.Type
			}

			if cfg.Type ~= bagConfig.TypeType.Stash then
				local stashBagConfigIds = self.tarkovStashBagConfigIdsByGamePlayTypeId[cfg.GameplayType]

				if not stashBagConfigIds then
					stashBagConfigIds = {}
					self.tarkovStashBagConfigIdsByGamePlayTypeId[cfg.GameplayType] = stashBagConfigIds
				end

				table.insert(stashBagConfigIds, cfg.Id)
			end
		end
	end
end

M.GetTarkovBagMeta = function(self, bagConfigId)
	if not bagConfigId or bagConfigId ~= 0 then
		return nil
	end

	if not self.tarkovBagMetaMap then
		self:BuildTarkovBagMetaMap()
	end

	return self.tarkovBagMetaMap[bagConfigId]
end

M.GetTarkovStashBagConfigIds = function(self, gamePlayTypeId)
	if not self.tarkovStashBagConfigIdsByGamePlayTypeId then
		self:BuildTarkovBagMetaMap()
	end

	return self.tarkovStashBagConfigIdsByGamePlayTypeId[gamePlayTypeId] or {}
end

M.ForEachSyncedTarkovBagItem = function(self, func)
	local extractionShooterInfo = self.GetExtractionShooterInfo()

	if not extractionShooterInfo then
		return false
	end

	return self:ForEachTarkovBagInfoCollection(extractionShooterInfo.Bags, func) or self:ForEachTarkovBagInfoCollection(extractionShooterInfo.SlotGroups, func)
end

M.ForEachTarkovGamePlayBagItem = function(self, func, gamePlayTypeId)
	return self:ForEachSyncedTarkovBagItem(function (itemInfo, bagConfigId)
		local bagMeta = self:GetTarkovBagMeta(bagConfigId)

		if bagMeta and bagMeta.gamePlayTypeId ~= gamePlayTypeId then
			return func(itemInfo, bagConfigId)
		end
	end)
end

M.GetTarkovWeaponBagByInstanceId = function(self, instanceId)
	if not instanceId or instanceId ~= 0 then
		return nil
	end

	local weaponData, retBagConfigId, retCellX, retCellY = nil

	self:ForEachSyncedTarkovBagItem(function (itemInfo, bagConfigId)
		local data = itemInfo.WeaponData

		if data and data.InstanceId ~= instanceId then
			weaponData = data
			retBagConfigId = bagConfigId
			retCellX = itemInfo.CellX
			retCellY = itemInfo.CellY

			return true
		end
	end)

	return weaponData, retBagConfigId, retCellX, retCellY
end

M.ForEachTarkovBagItem = function(func, gamePlayTypeId)
	local bagStoreSet = gExtractionShooterManager.GetBagStoreSet(gamePlayTypeId)
	local tarkovBagIds = {
		bagStoreSet.normal,
		bagStoreSet.safebox,
		bagStoreSet.inventory,
		bagStoreSet.wheel
	}

	for _, bagConfigId in ipairs(tarkovBagIds) do
		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
		local itemInfoList = bagInfo and bagInfo.ItemInfoList

		if itemInfoList then
			for _, itemInfo in ipairs(itemInfoList) do
				if func(itemInfo, bagConfigId) then
					return
				end
			end
		end
	end
end

M.GetTarkovWeaponByInstanceId = function(instanceId, gamePlayTypeId)
	if not instanceId or instanceId ~= 0 then
		return nil
	end

	local weaponData, retBagConfigId, retCellX, retCellY = nil

	gExtractionShooterManager.ForEachTarkovBagItem(function (itemInfo, bagConfigId)
		local data = itemInfo.WeaponData

		if data and data.InstanceId ~= instanceId then
			weaponData = data
			retBagConfigId = bagConfigId
			retCellX = itemInfo.CellX
			retCellY = itemInfo.CellY

			return true
		end
	end, gamePlayTypeId)

	return weaponData, retBagConfigId, retCellX, retCellY
end

M.GetItemInfoBySlot = function(slotIndex, bagId)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagId)
	local itemInfoList = bagInfo.ItemInfoList
	local cellX, cellY = gExtractionShooterManager.GetCellIndexBySlotIndex(slotIndex)

	for _, itemInfo in ipairs(itemInfoList) do
		if itemInfo.CellX ~= cellX and itemInfo.CellY ~= cellY then
			return itemInfo
		end
	end
end

M.GetInventoryPrice = function(gamePlayTypeId)
	local bagStoreSet = gExtractionShooterManager.GetBagStoreSet(gamePlayTypeId)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagStoreSet.inventory)
	local itemInfoList = bagInfo and bagInfo.ItemInfoList
	local totalPrice = 0

	if itemInfoList then
		for _, itemInfo in ipairs(itemInfoList) do
			local itemId = itemInfo.Id
			local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemId)
			local itemTypeCfg = LTConfig.ExtractionShooterItemTypeConfig.GetConfig(itemCfg.Type)
			local price = gExtractionShooterManager.GetItemSystemPrice(itemId) * itemInfo.StackCount

			if itemTypeCfg and itemTypeCfg.CanSell then
				totalPrice = totalPrice + price
			end
		end
	end

	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()

	return totalPrice, extractionShooterInfo.TokenCount
end

M.GetSlotIndexByWidget = function(widget)
	local slotIndex = tonumber(string.match(widget.gameObject.name, "WeaponItem(%d+)"))

	return slotIndex
end

M.GetBagCapacity = function(bagConfigId)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)

	if bagInfo.Capacity then
		return bagInfo.Capacity[1], bagInfo.Capacity[2]
	end

	local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagInfo.BagId)
	local baseX = bagCfg.Capacity.x
	local baseY = bagCfg.Capacity.y

	return baseX, baseY
end

M.GetCellIndexBySlotIndex = function(slotIndex)
	return slotIndex - 1 - LTConfig.SceneitemConfig.PrivateWeaponSlotSize, 0
end

M.GetInventoryBagItemCount = function(id)
	local count = LTConfig.ExtractionShooterBagConfig.count
	local ownerCount = 0

	for i = 0, count - 1 do
		local bagCfg = LTConfig.ExtractionShooterBagConfig.LoadAt(i)

		if bagCfg.Type ~= LTConfig.ExtractionShooterBagConfig.TypeType.Stash then
			local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagCfg.Id)

			if bagInfo then
				local itemInfoList = bagInfo.ItemInfoList

				for _, itemInfo in ipairs(itemInfoList) do
					if itemInfo.Id ~= id then
						ownerCount = ownerCount + itemInfo.StackCount
					end
				end
			end
		end
	end

	return ownerCount
end

M.GetBagStoreSet = function(gamePlayTypeId)
	if not gamePlayTypeId then
		if gExtractionShooterManager.CheckInGame() then
			local currentGameCfg = gLinkManager.currentGameCfg
			local multiPlayerId = currentGameCfg.Id
			local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(multiPlayerId)
			local extractionShooterCfg = LTConfig.ExtractionShooterConfig.GetConfig(multiPlayerCfg.ExtractionSettings)
			gamePlayTypeId = extractionShooterCfg and extractionShooterCfg.Type
		else
			print_error("@linminghe GetBagStoreSet error gamePlayTypeId nil")

			gamePlayTypeId = 1
		end
	end

	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gamePlayTypeId)
	local storageSet = gamePlayTypeCfg.StorageSet

	return {
		normal = storageSet.normal,
		safebox = storageSet.safebox,
		wheel = storageSet.wheel,
		inventory = storageSet.inventory,
		strengthen = BAG_CONFIG_ID.StrengthenSlot,
		shield = BAG_CONFIG_ID.ShieldSlot
	}
end

M.ForEachTarkovBagInfoCollection = function(self, dictionary, func)
	if not dictionary then
		return false
	end

	for bagConfigId, bagInfo in pairs(dictionary) do
		local itemInfoList = bagInfo and bagInfo.ItemInfoList

		if itemInfoList then
			for _, itemInfo in ipairs(itemInfoList) do
				if func(itemInfo, bagConfigId) then
					return true
				end
			end
		end
	end

	return false
end

M.GetExtractionItemCfgByConsumableId = function(consumableId)
	if not consumableId or consumableId ~= 0 then
		return nil
	end

	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(consumableId)

	if not consumableCfg or consumableCfg.ExtractionId ~= 0 then
		return nil
	end

	return LTConfig.ExtractionShooterItemConfig.GetConfig(consumableCfg.ExtractionId)
end

M.GetCollectionBookTotalScore = function()
	return gExtractionShooterManager.collectionBookTotalScore
end

M.GetBringOutFund = function(gamePlayTypeId)
	gamePlayTypeId = gamePlayTypeId or 1

	return gExtractionShooterManager.bringOutFundDict[gamePlayTypeId]
end

M.GetFundAmount = function(gamePlayTypeId)
	local fund = gExtractionShooterManager.GetBringOutFund(gamePlayTypeId)

	return fund and fund.Amount or 0
end

M.GetItemInfoSourceCfg = function(itemId)
	local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemId)

	if not itemCfg then
		return nil, , false
	end

	local itemTypeCfg = LTConfig.ExtractionShooterItemTypeConfig.GetConfig(itemCfg.Type)
	local isSceneItem = itemTypeCfg == nil and itemTypeCfg.ReadInfoType ~= LTConfig.ExtractionShooterItemTypeConfig.ReadInfoTypeType.SceneItem

	if isSceneItem then
		return LTConfig.SceneitemConfig.GetConfig(itemCfg.RealSceneItemModelId), itemCfg, true
	end

	return LTConfig.ConsumableConfig.GetConfig(itemId), itemCfg, false
end

M.GetItemSystemPrice = function(consumableId)
	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(consumableId)

	return consumableCfg and consumableCfg.SystemPrice or 0
end

M.GetItemTotalPrice = function(itemInfo)
	local systemPrice = gExtractionShooterManager.GetItemSystemPrice(itemInfo.Id)

	return systemPrice * itemInfo.StackCount
end

M.GetItemName = function(itemId)
	local srcCfg = gExtractionShooterManager.GetItemInfoSourceCfg(itemId)

	return srcCfg and srcCfg.Name
end

M.GetItemQuality = function(itemId)
	local srcCfg = gExtractionShooterManager.GetItemInfoSourceCfg(itemId)

	return srcCfg and srcCfg.Quality
end

M.GetItemIconId = function(itemId)
	local srcCfg, itemCfg, isSceneItem = gExtractionShooterManager.GetItemInfoSourceCfg(itemId)

	if not srcCfg then
		return nil
	end

	if isSceneItem then
		return srcCfg.SWeaponWheelsIconId
	end

	local sItemIconId = itemCfg.SItemIconId

	if sItemIconId ~= 0 then
		sItemIconId = srcCfg.SItemIconId
	end

	return sItemIconId
end

M.CheckInGame = function()
	if gLinkManager:CheckInMatchMode() then
		return gLinkManager.curMultiType ~= LTConfig.LinkMultiPlayerConfig.MultiTypeType.ExtractionShooter
	end

	return false
end

M.CheckItemCanRightClick = function(self, itemInfo)
	if itemInfo.StackCount <= 0 then
		return true
	end

	local id = itemInfo.Id
	local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(id)
	local inGame = gExtractionShooterManager.CheckInGame()

	if gExtractionShooterManager.CheckItemCanDiscard(id) then
		return true
	end

	if inGame and itemCfg and itemCfg.ConsumableId <= 0 and itemCfg.CanBringOut then
		return true
	end
end

M.CheckItemCanDiscard = function(id)
	local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(id)
	local inGame = gExtractionShooterManager.CheckInGame()

	if inGame and itemCfg and itemCfg.IfDiscard then
		return true
	end
end

M.CheckSlotIndexHasUnlocked = function(slotIndex, bagConfigId)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagInfo.BagId)
	local baseCapacity = bagCfg.SlotCapacity.initial

	return slotIndex > baseCapacity + bagInfo.AddUnlockedCount
end

M.CheckIsSlotGroupBag = function(bagConfigId)
	if not bagConfigId then
		return false
	end

	local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagConfigId)

	if not bagCfg then
		return false
	end

	local typeType = LTConfig.ExtractionShooterBagConfig.TypeType

	return bagCfg.Type ~= typeType.WeaponWheel or bagCfg.Type ~= typeType.StrengthSlot or bagCfg.Type ~= typeType.CapacitySlot
end

M.TryGetFreeCellIndexByConfigId = function(bagConfigId, itemId, srcItemInfo)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagConfigId)

	if bagCfg.Type ~= LTConfig.ExtractionShooterBagConfig.TypeType.WeaponWheel then
		local itemInfoList = bagInfo.ItemInfoList
		local occupyMap = {}

		for _, itemInfo in ipairs(itemInfoList) do
			occupyMap[itemInfo.CellX] = true
		end

		for i = 1, 8 do
			if not occupyMap[i - 1] then
				return i - 1, 0
			end
		end

		return nil
	elseif bagCfg.Type ~= LTConfig.ExtractionShooterBagConfig.TypeType.StrengthSlot then
		return #bagInfo.ItemInfoList ~= 0 and 0 or nil
	elseif bagCfg.Type ~= LTConfig.ExtractionShooterBagConfig.TypeType.CapacitySlot then
		return #bagInfo.ItemInfoList ~= 0 and 0 or nil
	end

	local itemCfg = gExtractionShooterUtils.GetItemCfgByConsumableId(itemId)

	if not itemCfg then
		return nil
	end

	local ctx = gExtractionShooterUtils.BuildBagContextByConfigId(bagConfigId)
	local bindPid = srcItemInfo and srcItemInfo.BindPid or 0
	local isLocked = srcItemInfo and srcItemInfo.IsLocked or false
	local mergeToItemInfo = gExtractionShooterUtils.TryGetStackableItem(ctx, itemId, bindPid, isLocked, srcItemInfo)

	if mergeToItemInfo then
		return mergeToItemInfo.CellX, mergeToItemInfo.CellY
	end

	local ok, cellX, cellY = gExtractionShooterUtils.TryGetFreeCellByOrder(ctx, itemCfg, false)

	if ok then
		return cellX, cellY
	end

	return nil
end

M.GetBagConfigIdAndCellByPrice = function(itemInfo, gamePlayTypeId)
	local totalPrice = itemInfo.StackCount * gExtractionShooterManager.GetItemSystemPrice(itemInfo.Id)
	local safeLimit = LTConfig.ExtractionShooterConfig.DefaultSaftyPutIn
	local bagStoreSet = gExtractionShooterManager.GetBagStoreSet(gamePlayTypeId)

	if safeLimit >= totalPrice or not {
		bagStoreSet.safebox,
		bagStoreSet.normal
	} then
		local bagPriority = {
			bagStoreSet.normal,
			bagStoreSet.safebox
		}
	end

	for _, bagConfigId in ipairs(bagPriority) do
		local freeCellX, freeCellY = gExtractionShooterManager.TryGetFreeCellIndexByConfigId(bagConfigId, itemInfo.Id, itemInfo)

		if freeCellX then
			return bagConfigId, freeCellX, freeCellY
		end
	end

	gDisplayMessageMgr:ShowMessageContent(LTConfig.ExtractionShooterConfig.BagAndSafeBoxCellFullTips)

	return nil, , 
end

M.CheckCellAllowed = function(bagId, consumableId, slotIndex)
	if slotIndex and (slotIndex > LTConfig.SceneitemConfig.PrivateWeaponSlotSize or not gExtractionShooterManager.CheckSlotIndexHasUnlocked(slotIndex, bagId)) then
		return false
	end

	local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagId)
	local allowedItemTypeList = bagCfg.AllowedItemTypes

	if table.isNilOrEmpty(allowedItemTypeList) then
		return true
	end

	local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(consumableId)
	local itemType = itemCfg.Type

	return table.find(allowedItemTypeList, itemType) == nil
end

M.CheckDeployItemType = function(gamePlayTypeId, itemTypeId)
	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gamePlayTypeId)
	local storageSet = gamePlayTypeCfg.StorageSet
	local bagIdList = {
		storageSet.normal,
		storageSet.safebox,
		storageSet.wheel
	}

	for _, bagId in ipairs(bagIdList) do
		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagId)
		local itemInfoList = bagInfo and bagInfo.ItemInfoList

		if itemInfoList then
			for _, itemInfo in ipairs(itemInfoList) do
				local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)

				if itemCfg.Type ~= itemTypeId then
					return true
				end
			end
		end
	end

	return false
end

M.CheckSafeBoxIsEmpty = function(gamePlayTypeId)
	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gamePlayTypeId)
	local storageSet = gamePlayTypeCfg.StorageSet
	local safeBoxId = storageSet.safebox
	local safeBoxInfo = gExtractionShooterManager.GetBagInfoByConfigId(safeBoxId)
	local itemInfoList = safeBoxInfo and safeBoxInfo.ItemInfoList

	return table.isNilOrEmpty(itemInfoList) or #itemInfoList ~= 0
end

M.QuickShiftBagToBag = function(self, fromBagConfigId, fromCellX, fromCellY, itemInfo, toBagConfigId)
	local freeCellX, freeCellY = gExtractionShooterManager.TryGetFreeCellIndexByConfigId(toBagConfigId, itemInfo.Id, itemInfo)

	if freeCellX then
		self:AskExtractionShooterShiftItem(fromBagConfigId, fromCellX, fromCellY, toBagConfigId, freeCellX, freeCellY)
	else
		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(toBagConfigId)
		local bagCfg = LTConfig.ExtractionShooterBagConfig.GetConfig(bagInfo.BagId)

		gDisplayMessageMgr:ShowMessageContent(LTConfig.ExtractionShooterConfig.BagCellFullTips:format(bagCfg.Name))
	end
end

M.QuickShiftBagToContainer = function(self, fromBagConfigId, itemInfo, containerInstanceId)
	local containerInfo = self:GetContainerInfo(containerInstanceId)
	local containerCfg = LTConfig.ExtractionShooterItemContainerConfig.GetConfig(containerInfo.CfgId)
	local containerCapacityX = containerCfg.Capacity.x
	local containerCapacityY = containerCfg.Capacity.y
	local itemCfg = gExtractionShooterUtils.GetItemCfgByConsumableId(itemInfo.Id)

	if not itemCfg then
		return
	end

	local ctx = gExtractionShooterUtils.BuildBagContext(containerCapacityX, containerCapacityY, containerInfo.ItemList)
	local ok, toCellX, toCellY = gExtractionShooterUtils.TryGetFreeCellByOrder(ctx, itemCfg, false)

	if ok then
		self:AskExtractionShooterShiftBagItemToContainer(fromBagConfigId, itemInfo, containerInstanceId, toCellX, toCellY)
	else
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ExtractionShooterConfig.BagCellFullTips:format(containerCfg.Name))
	end
end

M.QuickShiftContainerToBag = function(self, containerInstanceId, itemInfo, gamePlayTypeId)
	local toBagConfigId, freeCellX, freeCellY = gExtractionShooterManager.GetBagConfigIdAndCellByPrice(itemInfo, gamePlayTypeId)

	if not freeCellX then
		return
	end

	self:AskExtractionShooterShiftContainerItemToBag(containerInstanceId, itemInfo.CellX, itemInfo.CellY, toBagConfigId, freeCellX, freeCellY)
end

M.QuickShiftBagToBagByPrice = function(self, fromBagConfigId, fromCellX, fromCellY, itemInfo, gamePlayTypeId)
	local toBagConfigId, freeCellX, freeCellY = gExtractionShooterManager.GetBagConfigIdAndCellByPrice(itemInfo, gamePlayTypeId)

	if not freeCellX then
		return
	end

	self:AskExtractionShooterShiftItem(fromBagConfigId, fromCellX, fromCellY, toBagConfigId, freeCellX, freeCellY)
end

M.RefreshCommonItemInfoView = function(self, btn, itemInfo)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local itemId = itemInfo.Id
	local iconId = gExtractionShooterManager.GetItemIconId(itemId)
	store.iconId = iconId
	store.weaponIcon = iconId
	store.name = gExtractionShooterManager.GetItemName(itemId)
	store.showCountCtrl = itemInfo.StackCount <= 1 and 1 or 0
	store.count = itemInfo.StackCount <= 1 and itemInfo.StackCount or ""
	local quality = gExtractionShooterManager.GetItemQuality(itemId)
	store.qualityCtrl = quality
	store.QualityCtrl = quality
	store.price = gExtractionShooterManager.GetItemSystemPrice(itemId)

	btn.luaBeginDrag = function()
		btn:CloseTooltip(true)
	end

	btn.luaRightClick = function()
		if self:CheckItemCanRightClick(itemInfo) then
			btn:CloseTooltip(true)
			btn:OpenTooltip(1)
		end
	end
end

gExtractionShooterManager = gExtractionShooterManager or C_ExtractionShooterManager.new()
