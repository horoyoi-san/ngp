local AgentDataSetsConfig = LTConfig.AgentDataSetsActivityConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local NpcCultivationGiftTagsConfig = LTConfig.NpcCultivationGiftTagsConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local MessageConfig = LTConfig.MessageConfig
local DropConfig = LTConfig.DropConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local bindData = gPlayerManager.infoMinorNpcCultivation.bindData
local EInvokeTime = SGUI.EInvokeTime
C_DeliverGiftsPanelStore = DefClass("C_DeliverGiftsPanelStore", C_DeliverGiftsPanelStore, C_StoreGroup)
GroupName2Class.DeliverGiftsPanelStore = C_DeliverGiftsPanelStore
local M = C_DeliverGiftsPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.cfgId = 0
	self.npcPid = nil
	self.favorItemList = {}
	self.filterItemList = {}
	self.allTagList = {}
	self.selectedTags = {}
	self.selectItemUid = nil
	self.selectItemTag = nil
	self.selectItemData = nil
	self.selectItem = {}
	self.hasPresentGift = false
	self.favorInfo = nil
	self.unit = nil
	self.agentDataSetCfg = nil
	self.deliverCb = self:CreateAction("OnDeliverBtnClick")
	self.valueChangeCb = self:CreateAction("OnGiftNumChange")
	self.favorFakeShowCb = self:CreateAction("OnCloseToolTip")
	self.btnCheckFunc = self:CreateAction("GetCanSendGift")
	self.dataEvents = {
		{
			bindData,
			"availableGiftSendCount",
			function ()
				self:RefreshGiftLeftTimes()
			end
		}
	}
	self.msgEvents = {
		[gEventConstants.NPC_CULTIVATION_REFRESH] = self:CreateAction(self.OnNpcFavorChange)
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterButtons()
	self:RegisterLists()
	self:CacheGiftTagsConfig()
	self:CacheItemData()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterDataSetEvents(self.dataEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
	self:ClearDataSetEvents()
end

function M:OnShow(panelId, data)
	if not data.cfgId or not data.npcPid then
		print_error("未传入SpiritAcquisition cfgId或npcPid!")
		gPanelManager:Close(self.m_Id)

		return
	end

	self.cfgId = data.cfgId
	self.npcPid = data.npcPid
	self.agentDataSetCfg = AgentDataSetsConfig.GetConfig(self.cfgId)

	self:RefreshUnit()
	self:RefreshCamera()
	self:RefreshAvatar()
	self:RefreshFilterItems()
	self:RefreshFilter()
	self:RefreshFavorData()
	self:RefreshFavor()
	self:RefreshGiftLeftTimes()

	gPlayerManager.cacheInfo.bindData.ignoreFavorChangeShow = true
end

function M:OnClose()
	if self.hasPresentGift and self.unit then
		gMessageManager:SendMessage(gEventConstants.NPC_GIFT_FINISH_WITH_INTERACT, self.npcPid)
		L18.Gameplay.MotionActionManager.Instance:TryMultiInteractWithCallBack(23, gCS.MyPlayerManager.PlayerUnit, self.unit)
	else
		gMessageManager:SendMessage(gEventConstants.NPC_GIFT_FINISH_WITHOUT_INTERACT, self.npcPid)
	end

	self:RefreshCamera(true)

	gPlayerManager.cacheInfo.bindData.ignoreFavorChangeShow = false
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnNpcFavorChange(eventId, data)
	self:RefreshGiftTags()
	self:RefreshFavorData()

	self.bindData.expLabel = gUIUtils:GetNumberStr(self.favorInfo.favor - self.currentFavor)

	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)
	self:RefreshFavor()
end

function M:RegisterButtons()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnClick")
	self.bindData.filterBtn.luaClick = self:CreateAction("OnFilterBtnClick")
	self.bindData.closeFilterBtn.luaClick = self:CreateAction("OnCloseFilterBtnClick")
	self.bindData.closeToolTipBtn.luaClick = self:CreateAction("OnCloseToolTipBtnClick")
end

function M:OnExitBtnClick()
	gPanelManager:Close(self.m_Id)
end

function M:OnFilterBtnClick()
	self:OnCloseToolTipBtnClick()

	if not self.bindData.filterMenuCtrl then
		self.bindData.filterMenuCtrl = 1

		return
	end

	self.bindData.filterMenuCtrl = 1 - self.bindData.filterMenuCtrl
end

function M:OnCloseFilterBtnClick()
	self.bindData.filterMenuCtrl = 0

	self:RefreshFilterItems()
end

function M:OnCloseToolTipBtnClick()
	self.bindData.tooltipCtrl = 0

	self.bindData.itemList:DeselectAll()
	self:RefreshFavor()
end

function M:OnDeliverBtnClick(data, count)
	gClientToGameDelegate:AskInteractNpcWithGift(self.cfgId, self.selectItemUid, count).Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			print_error("[DebugLog]动态失败", gCS.Error.GetNameById(err))

			return
		else
			self.hasPresentGift = true

			self:RefreshToolTips()
			self:RefreshFavor()
			self:CacheItemData()

			if #self.favorItemList == #self.filterItemList then
				self.bindData.itemList:RefreshLogicList()
			else
				self:RefreshFilterItems()
			end
		end
	end
end

function M:RegisterLists()
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction(self.OnRenderItemList)
	self.bindData.filterList.luaSimpleRenderItem = self:CreateAction(self.OnRenderFilterList)
	self.bindData.favorTagList.luaSimpleRenderItem = self:CreateAction(self.OnRenderToolTipTagList)
	self.bindData.itemList.luaSimpleClick = self:CreateAction(self.OnClickItemList)
end

function M:OnRenderToolTipTagList(btn, index)
	gNpcFavorManager:OnRenderToolTipTagList(btn, index, self.favorTags[index + 1])
end

function M:OnRenderItemList(btn, index)
	local data = self.filterItemList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local item = gPlayerItemManager.packItemDict[data.uid]
		store.count = item.Count
		store.iconId = data.iconId
		store.quality = data.quality
	end
end

function M:OnClickItemList(btn, index)
	local data = self.filterItemList[index + 1]
	local select = gPlayerItemManager.packItemDict[data.uid]

	table.clear(self.selectItem)

	self.selectItem.TemplateId = select.TemplateId
	self.selectItem.Count = select.Count
	self.selectItemUid = data.uid
	self.selectItemData = data
	self.selectItemTag = data.tags
	local range = table.clone(select.range) or {}
	local giveLimit = math.min(self:GetGiftLimit(), select.Count)

	if self:GetCanSendGift() then
		if range[2] then
			range[2] = math.min(self.range[2], giveLimit)
		else
			range[1] = select.Count > 0 and 1 or 0
			range[2] = math.min(select.Count, giveLimit)
		end
	else
		table.clear(range)
	end

	self.selectItem.range = range
	self.selectItem.showSource = false
	self.bindData.tooltipCtrl = 1

	self:RefreshToolTips()
end

function M:OnRenderFilterList(btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.tagList.luaSimpleRenderItem = self:CreateAction(self.OnRenderFilterTagList)
		store.tagList.luaSimpleClick = self:CreateAction(self.OnClickFilterTagList)

		store.tagList:SetSimpleList(#self.allTagList)
	end
end

function M:OnRenderFilterTagList(btn, index)
	local data = self.allTagList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.tagColor = data.giftTagColor
		store.tagNameText = data.giftTagName
	end
end

function M:OnClickFilterTagList(btn, index)
	local data = self.allTagList[index + 1]
	self.selectedTags[data.id] = btn.isSelected

	self:RefreshFilterItems()

	for _, v in pairs(self.selectedTags) do
		if v then
			self.bindData.IsFilteringCtrl = 0

			return
		end
	end

	self.bindData.IsFilteringCtrl = 1
end

function M:CacheGiftTagsConfig()
	for i = 0, NpcCultivationGiftTagsConfig.count - 1 do
		local cfg = NpcCultivationGiftTagsConfig.LoadAt(i)
		local tag = {
			id = cfg.Id,
			giftTagName = cfg.GiftTagName,
			giftTagColor = Color.NewByStr(cfg.GiftTagColor)
		}

		table.insert(self.allTagList, tag)
	end
end

function M:CacheItemData()
	table.clear(self.favorItemList)

	local items = gPlayerItemManager.packItems
	local needCloseToolTips = true

	for _, item in ipairs(items) do
		local templateId = item.TemplateId
		local count = item.Count
		local config = ConsumableConfig.GetConfig(templateId)

		if config.SubType == ConsumableTypeConfig.NpcGift then
			local uid = item.UniqueId
			local data = {
				templateId = templateId,
				count = count,
				uid = uid,
				iconId = config.SItemIconId,
				quality = config.Quality,
				desc = config.Description,
				name = config.Name,
				tags = config.GiftTags
			}

			table.insert(self.favorItemList, data)
		end

		if self.selectItemUid and ulong.equals(self.selectItemUid, item.UniqueId) then
			needCloseToolTips = false
		end
	end

	table.sort(self.favorItemList, function (a, b)
		return b.templateId < a.templateId
	end)

	if needCloseToolTips and self.selectItemUid ~= nil then
		self:OnCloseToolTipBtnClick()
	end
end

function M:RefreshUnit()
	self.unit = gCS.SceneDataMgr.GetUnit(self.npcPid)
end

function M:RefreshCamera(isExit)
	if isExit then
		gCS.CameraDataMgr.cinemachineManager:DisableCustomFreeLook(1)

		return
	end

	local pos = Vector3.New(self.unit.HeadPos.x, self.unit.HeadPos.y + self.agentDataSetCfg.HeightOffset, self.unit.HeadPos.z)

	gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(pos, self.agentDataSetCfg.CameraId, 1)
end

function M:RefreshAvatar()
	local templateId = self.agentDataSetCfg.NpccultivationId
	local fightSpiritId = NpcCultivationConfig.GetConfig(templateId).FightSpiritID
	local sHeadIconId = FightSpiritConfig.GetConfig(fightSpiritId).SHeadIconID
	local name = NpcCultivationConfig.GetConfig(templateId).Name
	local avatarStore = gStoreManager:GetStoreGroup("FavorCommonAvatar"):GetStoreByWidget(self.bindData.headAvatarWidget)
	avatarStore.headIcon = sHeadIconId
	avatarStore.headName = name
	avatarStore.headLevel = "Lv." .. gSpiritAcquisitionManager:GetSpiritFavorLevel(templateId)
end

function M:RefreshFilter()
	self.bindData.filterList:SetSimpleList(1)
end

function M:RefreshFilterItems()
	local isEmptySelect = true

	for tag, selected in pairs(self.selectedTags) do
		if selected then
			isEmptySelect = false

			break
		end
	end

	if isEmptySelect then
		self.filterItemList = table.clone(self.favorItemList)
	else
		self.filterItemList = {}

		for _, item in ipairs(self.favorItemList) do
			local itemTags = item.tags
			local isAllMatch = true

			for sid, select in pairs(self.selectedTags) do
				if select then
					local isMatch = false

					for _, id in ipairs(itemTags) do
						if id == sid then
							isMatch = true
						end
					end

					if not isMatch then
						isAllMatch = false
					end
				end
			end

			if isAllMatch then
				table.insert(self.filterItemList, item)
			end
		end
	end

	self.bindData.itemList:DeselectAll()
	self.bindData.itemList:SetSimpleList(#self.filterItemList)
	self.bindData.itemList:SetNavSelectToTop()
end

function M:RefreshFavorData()
	if not self.cfgId or self.cfgId == 0 then
		return
	end

	local templateId = self.agentDataSetCfg.NpccultivationId
	self.favorInfo = gNpcFavorManager:GetSpiritFavorInfo(templateId)
end

function M:RefreshGiftLeftTimes()
	local giftLimit, nowCount, maxCount = gSpiritAcquisitionManager:GetPresentGiveState()
	self.bindData.giftTimesText = string.format("%s/%s", nowCount, maxCount)
end

function M:RefreshGiftTags()
	if not self.cfgId or self.cfgId == 0 then
		return
	end

	local templateId = self.agentDataSetCfg.NpccultivationId
	self.favorTags = gNpcFavorManager:GetNpcGiftTagInfo(templateId)

	self.bindData.favorTagList:SetSimpleList(#self.favorTags)
end

function M:GetCanSendGift()
	return self:_GetCanSendGift() == 0
end

function M:_GetCanSendGift()
	local templateId = self.agentDataSetCfg.NpccultivationId
	local isMax = gNpcFavorManager:CheckNpcFavorIsMax(templateId)

	if isMax then
		return 89901327
	end

	local isFull = gSpiritAcquisitionManager:GetCanPresentGiveTimes() == 0

	if isFull then
		return 89901332
	end

	return 0
end

function M:RefreshToolTips()
	local canSendGift = self:_GetCanSendGift()

	if canSendGift ~= 0 then
		table.clear(self.selectItem.range)

		self.selectItem.warnText = LTConfig.TextScriptTextConfig.GetConfig(canSendGift).Text
	else
		local giveLimit = math.min(self:GetGiftLimit(), self.selectItem.Count)
		self.selectItem.range[2] = giveLimit
	end

	self.SubGroup.InventoryItemDetailInfoTemplateStore:SetSelectedItem(self.selectItem, self.btnCheckFunc, self.deliverCb, self.valueChangeCb, self.bindData.navi)
end

function M:GetGiftLimit()
	local giveTimes = gSpiritAcquisitionManager:GetCanPresentGiveTimes()
	local favor, favorCoef = self:GetSelectedItemFavorAndFavorCoef()
	local nowFavor = self.favorInfo.favor
	local maxFavor = NpcCultivationConfig.FavorMax
	local maxFavorGiveTimes = math.ceil((maxFavor - nowFavor) / (favor * favorCoef))

	return math.min(giveTimes, maxFavorGiveTimes)
end

function M:GetRaiseFavor(val)
	local favor, favorCoef = self:GetSelectedItemFavorAndFavorCoef()
	favor = favor * favorCoef * val

	return favor
end

function M:GetSelectedItemFavorAndFavorCoef()
	local templateId = self.agentDataSetCfg.NpccultivationId
	local favorTagNum = 0
	local spiritGiftConfig = NpcCultivationConfig.GetConfig(templateId)
	local favorTagSet = spiritGiftConfig.PreferTags

	if self.selectItemTag then
		for _, tag in pairs(self.selectItemTag) do
			if table.contains(favorTagSet, tag) then
				favorTagNum = favorTagNum + 1
			end
		end
	end

	local quality = self.selectItemData.quality
	local dropId = spiritGiftConfig.LevelFavourDropId[5 - quality]
	local favor = DropConfig.GetConfig(dropId).NpcFavor[1].count
	local favorCoef = spiritGiftConfig.TagFavourValueCoef[favorTagNum + 1]
	local fightSpiritId = NpcCultivationConfig.GetConfig(templateId).FightSpiritID
	local agentId = FightSpiritConfig.GetConfig(fightSpiritId).AgentId
	local factionId = LTConfig.AgentConfig.GetConfig(agentId).Faction

	if factionId and factionId > 0 then
		local factionInfo = gPlayerManager.infoAchievement.bindData.FactionInfoDic[factionId]

		if factionInfo then
			local level = factionInfo.DispositionLevel
			local levelT1 = 5
			local levelT2 = 6
			local rateT1 = 1.2
			local rateT2 = 1.4

			if levelT2 <= level then
				favorCoef = favorCoef * rateT2
			elseif levelT1 <= level then
				favorCoef = favorCoef * rateT1
			end
		end
	end

	return favor, favorCoef
end

function M:OnCloseToolTip()
	self:RefreshFavor()

	self.selectItemData = nil
end

function M:RefreshFavor()
	self.currentFavor = self.favorInfo.favor
	self.bindData.favorLevelText = string.format("Lv.%d", self.favorInfo.favorLevel)
	self.bindData.favorProgress.maxValue = self.favorInfo.maxFavor
	self.bindData.favorProgress.minValue = self.favorInfo.minFavor

	self.bindData.favorProgress:ProgressToValue(self.favorInfo.favor)
end

function M:OnGiftNumChange(val)
	return
end
