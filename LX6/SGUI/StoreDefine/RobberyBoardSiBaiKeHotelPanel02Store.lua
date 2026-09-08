-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobberyBoardSiBaiKeHotelPanel02Store.lua
-- Decompiled from: 00924_RobberyBoardSiBaiKeHotelPanel02Store.lua_62c2f550bc96.luajit

C_RobberyBoardSiBaiKeHotelPanel02Store = DefClass("C_RobberyBoardSiBaiKeHotelPanel02Store", C_RobberyBoardSiBaiKeHotelPanel02Store, C_StoreGroup)
GroupName2Class.RobberyBoardSiBaiKeHotelPanel02Store = C_RobberyBoardSiBaiKeHotelPanel02Store
local M = C_RobberyBoardSiBaiKeHotelPanel02Store

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showItemDetailCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.investFinishedCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isTeamLeaderCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isSingleCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showTipCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showItemDetailCtrlEnum = nil
	self.investFinishedCtrlEnum = nil
	self.isTeamLeaderCtrlEnum = nil
	self.isSingleCtrlEnum = nil
	self.showTipCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.countDowCo = coroutine.stop(self.countDowCo)

	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.multiPlayerId = args.multiPlayerId
	self.hasNavigateInvest = nil
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local extraState = multiPlayerCfg.ExtraStates[1]
	self.readyEndTime = gLuaDataManager.serverTime + extraState.Timeout
	self.memberList = args.memberList
end

M.InitView = function(self, _)
	self.lineMap = {
		self.bindData.lineLong1,
		self.bindData.lineLong2,
		self.bindData.lineShort1,
		self.bindData.lineShort2
	}
	self.progressDesMap = {
		self.bindData.progressDes1,
		self.bindData.progressDes2
	}

	for i = 1, 4 do
		self.bindData[("playerNum%d"):format(i)]:SetActive(false)
		self.bindData[("progress%d"):format(i)]:SetActive(false)
		self.lineMap[i]:SetActive(false)
	end

	self.bindData.investFinishedCtrl = 0
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	self.bindData.name = multiPlayerCfg.Name

	self.RefreshPanelView(self)
end

M.RefreshPanelView = function(self)
	if not gClientUtils.NotNil(self.rootWidget) then
		return
	end

	self.bindData.teamMemberList:SetSimpleList(#self.memberList)
	self:RefreshProgressDes()
	self:PlaceAllLines()
	self:RefreshTopListView()
	self:RefreshRewardListView()
	self:RefreshItemListView()

	if self.bindData.showItemDetailCtrl ~= 1 then
		self.RefreshItemDetailListView(self)
	end

	self.RefreshPlayerInvestPercentView(self)
	self.RefreshButtonView(self)
	self.RefreshCountdownTimeView(self)
	self.RefreshTipView(self)
end

M.RefreshTipView = function(self)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local ownerItemMap = self.GetMatchOwnerItemInfoMap(self)

	for _, itemId in ipairs(multiPlayerCfg.NeedKeyIds) do
		if (ownerItemMap[itemId] or 0) >= 1 then
			self.bindData.showTipCtrl = 1

			return
		end
	end

	self.bindData.showTipCtrl = 0
end

M.RefreshTopListView = function(self)
	self.bindData.list:SetSimpleList(3)
end

M.RefreshRewardListView = function(self)
	local myReward = self.GetMyReward(self)
	self.bindData.myReward = gClientUtils.FormatWithThousandsSeparator(myReward)
	local totalReward = self.GetTotalReward(self)
	self.bindData.totalReward = gSocialNetworkUtils.GetCountFormat(totalReward)
end

M.GetMemberRewardList = function(self, member)
	local dropList = self:GetMemberDividendDropList(member)
	local rewardList = gCommonItemManager:GetItemSortedListByDropList(dropList, true)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)

	if multiPlayerCfg.DividendsExpectation <= 0 then
		rewardList[1] = rewardList[1] or self:GetDefaultMoneyItem()
		local rewardItem = rewardList[1]
		rewardItem.Count = rewardItem.Count + multiPlayerCfg.DividendsExpectation
	end

	return rewardList
end

M.GetDefaultMoneyItem = function(self)
	return {
		["K\\x9e\\x80\\xaaE"] = 28000060,
		["n\\xa1\\xb7\\xa1\\xa2"] = 0
	}
end

M.GetTotalReward = function(self)
	local totalDropList = {}

	for _, member in ipairs(self.memberList) do
		local memberDropList = self.GetMemberDividendDropList(self, member)

		array.concat(totalDropList, memberDropList)
	end

	local totalRewardList = gCommonItemManager:GetItemSortedListByDropList(totalDropList, true)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)

	if multiPlayerCfg.DividendsExpectation <= 0 then
		totalRewardList[1] = totalRewardList[1] or self:GetDefaultMoneyItem()
		local rewardItem = totalRewardList[1]
		local matchMemberCount = self:GetMatchMemberCount()
		rewardItem.Count = rewardItem.Count + multiPlayerCfg.DividendsExpectation * matchMemberCount
	end

	local rewardItem = totalRewardList[1]
	local totalReward = rewardItem and rewardItem.Count or 0

	return totalReward
end

M.GetMyReward = function(self)
	local totalReward = self.GetTotalReward(self)
	local selfMember = self.GetSelfMember(self)
	local percent = self.GetMemberDividendPercent(self, selfMember)

	return math.floor(totalReward * percent + 0.5)
end

M.GetSelfMember = function(self)
	for _, member in ipairs(self.memberList) do
		if member.Pid ~= gPlayerManager.infoLogin.bindData.pid then
			return member
		end
	end
end

M.RefreshPlayerInvestPercentView = function(self)
	self.bindData.playerList:SetSimpleList(#self.memberList)
end

M.RefreshButtonView = function(self)
	local readyMemberCount = gPlanningBoardManager.GetReadyMemberCount()
	local matchMemberCount = self:GetMatchMemberCount()
	self.bindData.continueInvestText = LTConfig.PlanningBoardConfig.ContinueInvestText:format(readyMemberCount, matchMemberCount)
	self.bindData.investFinishText = LTConfig.PlanningBoardConfig.InvestFinishText:format(readyMemberCount, matchMemberCount)
end

M.RefreshCountdownTimeView = function(self)
	self.countDowCo = coroutine.stop(self.countDowCo)
	self.countDowCo = coroutine.start(function ()
		while true do
			local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
			local leftTime = math.floor(self.readyEndTime - gLuaDataManager.serverTime)
			leftTime = math.max(leftTime, 0)
			self.bindData.countdownText = LTConfig.PlanningBoardConfig.CountdownText:format(multiPlayerCfg.Name, leftTime)

			coroutine.wait(0.5)
		end
	end)
end

M.GetMemberDividendPercent = function(self, member)
	local memberRewardItem = self.GetMemberRewardList(self, member)[1]
	local totalReward = self.GetTotalReward(self)
	local allMemberPutKeyCount = self.GetAllMemberPutKeyCount(self)
	local memberPutKeyCount = self.GetMemberPutKeyCount(self, member.Pid)
	local matchMemberCount = self.GetMatchMemberCount(self)

	return (memberPutKeyCount + 1) / (allMemberPutKeyCount + 1 * matchMemberCount)
end

M.GetAllMemberPutKeyCount = function(self)
	local totalPutKeyCount = 0

	for _, member in ipairs(self.memberList) do
		local memberTotalPutCount = self.GetMemberPutKeyCount(self, member.Pid)
		totalPutKeyCount = totalPutKeyCount + memberTotalPutCount
	end

	return totalPutKeyCount
end

M.GetMemberItemPutKeyCount = function(self, pid, itemId)
	local putItemCount = gPlanningBoardManager.GetMemberPutItemCount(pid, itemId)

	return putItemCount
end

M.GetMemberPutKeyCount = function(self, pid)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local memberTotalPutCount = 0

	for _, itemId in ipairs(itemIdList) do
		local putItemCount = gPlanningBoardManager.GetMemberPutItemCount(pid, itemId)
		memberTotalPutCount = memberTotalPutCount + putItemCount
	end

	return memberTotalPutCount
end

M.GetMemberDividendDropList = function(self, member)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local memberDropList = {}
	local baseDropIdList = multiPlayerCfg.DropSuccess

	for _, dropId in ipairs(baseDropIdList) do
		table.insert(memberDropList, {
			dropId = dropId
		})
	end

	for _, itemId in ipairs(itemIdList) do
		local putItemCount = gPlanningBoardManager.GetMemberPutItemCount(member.Pid, itemId)

		if putItemCount <= 0 then
			local dropId = gPlanningBoardManager.GetDividendDropId(itemId)

			table.insert(memberDropList, {
				dropId = dropId,
				count = putItemCount
			})
		end
	end

	return memberDropList
end

M.GetMatchMemberCount = function(self)
	return #self.memberList
end

M.RefreshItemListView = function(self)
	local matchMemberCount = self:GetMatchMemberCount()
	self.bindData.isSingleCtrl = matchMemberCount ~= 1 and 1 or 0
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local needItemIdList = multiPlayerCfg.NeedKeyIds

	self.bindData.itemList.luaSimpleRenderItem = function(btn, index)
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		local itemId = needItemIdList[index + 1]
		local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
		store.iconId = consumableCfg.SMoneyIconId
		local ownerCount = self:GetMemberOwnerKeyCount(gPlayerManager.infoLogin.bindData.pid, itemId)
		local putKeyCount = self:GetMemberItemPutKeyCount(gPlayerManager.infoLogin.bindData.pid, itemId)
		store.num = ownerCount - putKeyCount
		local itemData = gCommonItemManager:GetItemRenderData({
			["\\xd0\\xcf01\\xfc"] = 1,
			itemId = itemId
		})
		itemData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

		btn:SetPopupDirection(16)
		gCommonItemManager:OnCommonItemRender(btn, nil, itemData)
	end

	self.bindData.itemList:SetSimpleList(#needItemIdList)
end

M.GetMemberOwnerKeyCount = function(self, pid, itemId)
	local info = gPlanningBoardManager:GetMemberInfo(pid)
	local memberKeyCounts = info and info.MemberKeyCounts

	return memberKeyCounts and memberKeyCounts[itemId] or 0
end

M.GetMatchOwnerItemInfoMap = function(self)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local ownerItemMap = {}

	for _, itemId in ipairs(itemIdList) do
		local num = 0

		for _, member in ipairs(self.memberList) do
			local info = gPlanningBoardManager:GetMemberInfo(member.Pid)
			local memberKeyCounts = info and info.MemberKeyCounts
			local ownerCount = memberKeyCounts and memberKeyCounts[itemId] or 0
			num = num + ownerCount
		end

		ownerItemMap[itemId] = num
	end

	return ownerItemMap
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TEAM_REFRESH_DATA] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.ON_EXTRA_STATE_MEMBER_CONFIRM_CHANGE] = self.CreateAction(self, "RefreshButtonView"),
		[gEventConstants.ON_PLANNING_BOARD_DIVIDENDS_PUT_IN_KEYS_SUCCESS] = self.CreateAction(self, "RefreshPanelView")
	}
end

M.RegisterWidget = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.detailButton.luaClick = self.CreateAction(self, "OnDetailClick")
	self.bindData.itemDetailList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItemDetailListItem")
	self.bindData.investFinishButton.luaClick = self.CreateAction(self, "OnInvestFinishClick")
	self.bindData.continueInvestButton.luaClick = self.CreateAction(self, "OnContinueInvestClick")
	self.bindData.playerList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPlayerItem")
	self.bindData.teamMemberList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTeamMemberItem")
	self.bindData.controllerCloseButton.luaClick = self.CreateAction(self, "OnCloseDetailClick")
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local itemWidget = store.itemWidget
	local playerListWidget = store.playerListWidget
	local investWidget = store.investWidget

	self:RefreshItemWidgetView(itemWidget, index)
	self:RefreshPlayerListWidgetView(playerListWidget, index)
	self:RefreshInvestWidgetView(investWidget, index, btn)

	store.enoughCtrl = self:CheckItemEnough(index) and 1 or 0
end

M.CheckItemEnough = function(self, index)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local itemId = itemIdList[index + 1]
	local ownerCount = self:GetMemberOwnerKeyCount(gPlayerManager.infoLogin.bindData.pid, itemId)

	return ownerCount >= 0
end

M.RefreshItemWidgetView = function(self, itemWidget, index)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local store = gStoreManager:GetStoreGroup(itemWidget.Store):GetStoreByWidget(itemWidget)
	local itemId = itemIdList[index + 1]
	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
	store.iconId = consumableCfg.SItemIconId
	local totalPutItemCount = 0

	for _, member in ipairs(self.memberList) do
		local putItemCount = gPlanningBoardManager.GetMemberPutItemCount(member.Pid, itemId)
		totalPutItemCount = totalPutItemCount + putItemCount
	end

	store.current = totalPutItemCount
	store.total = 1
	local meetCondition = totalPutItemCount < 1

	store.checkWidget:SetActive(meetCondition)
end

M.RefreshPlayerListWidgetView = function(self, playerListWidget, index)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local itemId = itemIdList[index + 1]
	local store = gStoreManager:GetStoreGroup(playerListWidget.Store):GetStoreByWidget(playerListWidget)

	store.list.luaSimpleRenderItem = function(childBtn, childIndex)
		local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
		local member = self.memberList[childIndex + 1]
		local putItemCount = gPlanningBoardManager.GetMemberPutItemCount(member.Pid, itemId)
		childStore.emptyCtrl = putItemCount <= 0 and 0 or 1
		local avatarStore = gStoreManager:GetStoreGroup(childStore.avatarWidget.Store):GetStoreByWidget(childStore.avatarWidget)
		avatarStore.userInfo.pid = member.Pid
		avatarStore.showPlayerNumberCtrl = 1
		avatarStore.showTeamColorCtrl = #self.memberList <= 1 and 1 or 0
		avatarStore.color = gLinkManager:GetColorStr(member.Pid)
	end

	local matchMemberCount = self:GetMatchMemberCount()

	store.list:SetSimpleList(matchMemberCount)
end

M.RefreshInvestWidgetView = function(self, investWidget, index, btn)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local store = gStoreManager:GetStoreGroup(investWidget.Store):GetStoreByWidget(investWidget)
	local targetItemId = itemIdList[index + 1]
	local ownerCount = gCommonItemManager:GetPackItemNum(targetItemId)
	store.investButton.interactable = ownerCount <= 0 and self.bindData.investFinishedCtrl ~= 0
	local info = gPlanningBoardManager.memberInfos[gPlayerManager.infoLogin.bindData.pid]
	local planningBoardPutInKeys = info and info.PutInKeys
	local hasPutIn = planningBoardPutInKeys and planningBoardPutInKeys[targetItemId] and planningBoardPutInKeys[targetItemId] >= 0
	store.investCtrl = hasPutIn and 1 or 0

	if not self.hasNavigateInvest then
		self.hasNavigateInvest = true
	end

	local executeInvestFunction = function()
		local itemInfoMap = {}

		for _, itemId in ipairs(itemIdList) do
			if itemId == targetItemId then
				local putItemCount = gPlanningBoardManager.GetMemberPutItemCount(gPlayerManager.infoLogin.bindData.pid, itemId)

				if putItemCount <= 0 then
					itemInfoMap[itemId] = putItemCount
				end
			end
		end

		local putItemCount = store.investCtrl ~= 0 and 1 or 0

		if putItemCount <= 0 then
			itemInfoMap[targetItemId] = putItemCount
		end

		gPlanningBoardManager:AskLinkPlanningBoardDividendsPutInKeys(itemInfoMap)
	end

	store.investButton.luaClick = executeInvestFunction
	btn.luaClick = executeInvestFunction
end

M.OnDetailClick = function(self)
	self.bindData.showItemDetailCtrl = self.bindData.showItemDetailCtrl ~= 0 and 1 or 0

	if self.bindData.showItemDetailCtrl ~= 1 then
		self.RefreshItemDetailListView(self)
	end
end

M.RefreshItemDetailListView = function(self)
	self.itemDetailDataList = self:GetItemDetailDataList()

	self.bindData.itemDetailList.onGetTIndex = function(index)
		local data = self.itemDetailDataList[index + 1]

		return data.tIndex
	end

	self.bindData.itemDetailList:SetSimpleList(#self.itemDetailDataList)
end

M.GetItemDetailDataList = function(self)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(self.multiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local itemDetailDataList = {}

	table.insert(itemDetailDataList, {
		["a\\x9f\\x8a\\x86Y"] = 0,
		dataList = itemIdList
	})

	local totalOwnerItemMap = {}

	for _, member in ipairs(self.memberList) do
		local memberItemDataList = {}
		local info = gPlanningBoardManager:GetMemberInfo(member.Pid)
		local memberKeyCounts = info and info.MemberKeyCounts
		local putInKeys = info and info.PutInKeys

		for _, itemId in ipairs(itemIdList) do
			local ownerCount = memberKeyCounts and memberKeyCounts[itemId] or 0
			local putInCount = putInKeys and putInKeys[itemId] or 0
			local availableCount = math.max(ownerCount - putInCount, 0)

			table.insert(memberItemDataList, {
				itemId,
				num = availableCount
			})

			local totalOwnerCount = totalOwnerItemMap[itemId] or 0
			totalOwnerCount = totalOwnerCount + availableCount
			totalOwnerItemMap[itemId] = totalOwnerCount
		end

		table.insert(itemDetailDataList, {
			["a\\x9f\\x8a\\x86Y"] = 1,
			pid = member.Pid,
			dataList = memberItemDataList
		})
	end

	local totalDataList = {}

	for _, itemId in ipairs(itemIdList) do
		local ownerCount = totalOwnerItemMap[itemId] or 0

		table.insert(totalDataList, ownerCount)
	end

	table.insert(itemDetailDataList, {
		["a\\x9f\\x8a\\x86Y"] = 2,
		dataList = totalDataList
	})

	return itemDetailDataList
end

M.OnRenderPlayerItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local member = self.memberList[index + 1]
	local avatarStore = gStoreManager:GetStoreGroup(store.avatarWidget.Store):GetStoreByWidget(store.avatarWidget)
	avatarStore.userInfo.pid = member.Pid
	avatarStore.showPlayerNumberCtrl = 1
	local percent = self:GetMemberDividendPercent(member)
	store.progress = ("%.1f%%"):format(percent * 100)
	store.isSelfCtr = member.Pid ~= gPlayerManager.infoLogin.bindData.pid and 1 or 0
	avatarStore.showTeamColorCtrl = #self.memberList <= 1 and 1 or 0
	avatarStore.color = gLinkManager:GetColorStr(member.Pid)
end

M.OnSimpleRenderItemDetailListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local itemDetailData = self.itemDetailDataList[index + 1]
	local childDataList = itemDetailData.dataList

	if itemDetailData.tIndex ~= 0 then
		store.list.luaSimpleRenderItem = function(childBtn, childIndex)
			local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
			local itemId = childDataList[childIndex + 1]
			local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
			childStore.iconId = consumableCfg.SItemIconId
			local itemData = gCommonItemManager:GetItemRenderData({
				["\\xd0\\xcf01\\xfc"] = 1,
				itemId = itemId
			})
			itemData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

			childBtn:SetPopupDirection(16)
			gCommonItemManager:OnCommonItemRender(childBtn, nil, itemData)
		end
	elseif itemDetailData.tIndex ~= 1 then
		local avatarStore = gStoreManager:GetStoreGroup(store.avatarWidget.Store):GetStoreByWidget(store.avatarWidget)
		local subAvatarStore = gStoreManager:GetStoreGroup(avatarStore.headBtn.Store):GetStoreByWidget(avatarStore.headBtn)

		store.list.luaSimpleRenderItem = function(childBtn, childIndex)
			local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
			local childData = childDataList[childIndex + 1]
			childStore.num = childData.num
		end

		avatarStore.userInfo.pid = itemDetailData.pid
		subAvatarStore.showTeamColorCtrl = #self.memberList <= 1 and 1 or 0
		subAvatarStore.color = gLinkManager:GetColorStr(itemDetailData.pid)
	elseif itemDetailData.tIndex ~= 2 then
		store.list.luaSimpleRenderItem = function(childBtn, childIndex)
			local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
			local totalNum = childDataList[childIndex + 1]
			childStore.num = totalNum
		end
	end

	store.list:SetSimpleList(#childDataList)
end

M.OnInvestFinishClick = function(self)
	local rootGo = self.rootGo
	local requestArgs = {
		["\\xda\\xd46\\xfc"] = true,
		stageId = LTConfig.LinkStageConfig.Invest
	}
	slot3 = gPlanningBoardManager

	slot3:AskExtraStateConfirm(requestArgs, function ()
		if gClientUtils.NotNil(rootGo) then
			self.bindData.investFinishedCtrl = 1

			self:RefreshTopListView()
		end
	end)
end

M.GetPointOutSideCircle = function(self, progress, offset)
	local radius = self.bindData.circle.sizeDelta.x / 2
	local angle = (270 - 360 * progress) * math.pi / 180
	local effectiveRadius = radius + offset
	local x = self.bindData.circleCenter.localPosition.x + effectiveRadius * math.cos(angle)
	local y = self.bindData.circleCenter.localPosition.x + effectiveRadius * math.sin(angle)

	return Vector2.New(x, y)
end

M.OnContinueInvestClick = function(self)
	local requestArgs = {
		["\\xda\\xd46\\xfc"] = false,
		stageId = LTConfig.LinkStageConfig.Invest
	}
	local rootGo = self.rootGo
	slot3 = gPlanningBoardManager

	slot3:AskExtraStateConfirm(requestArgs, function ()
		if gClientUtils.NotNil(rootGo) then
			self.bindData.investFinishedCtrl = 0

			self:RefreshTopListView()
		end
	end)
end

local GAP = 0.015

M.OnRenderTeamMemberItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local playerNumWidget = self.bindData[("playerNum%d"):format(index + 1)]

	playerNumWidget:SetActive(true)

	local progressWidget = self.bindData[("progress%d"):format(index + 1)]

	progressWidget:SetActive(true)

	local member = self.memberList[index + 1]
	local pid = member and member.Pid or gPlayerManager.infoLogin.bindData.pid
	store.userInfo.pid = pid
	local progressStore = gStoreManager:GetStoreGroup(progressWidget.Store):GetStoreByWidget(progressWidget)
	local isSelf = pid ~= gPlayerManager.infoLogin.bindData.pid
	progressStore.isSelfCtrl = isSelf and 1 or 0
	local fillImageNode = progressWidget.transform:Find("Fill")
	local fillImage = fillImageNode and fillImageNode:GetComponent("UImage")

	if fillImage then
		fillImage.ringWidth = isSelf and 260 or 100
	end

	store.showTeamColorCtrl = #self.memberList <= 1 and 1 or 0
	store.color = gLinkManager:GetColorStr(member.Pid)
	self.bindData[("progressColor%d"):format(index + 1)] = gLinkManager:GetColorStr(pid)
	local playerNumStore = gStoreManager:GetStoreGroup(playerNumWidget.Store):GetStoreByWidget(playerNumWidget)
	playerNumStore.userInfo.pid = member and member.Pid or gPlayerManager.infoLogin.bindData.pid
	local totalRawPercent = 0
	local memberCount = #self.memberList

	for i = 1, memberCount do
		totalRawPercent = totalRawPercent + self.GetMemberDividendPercent(self, self.memberList[i])
	end

	local gap = memberCount <= 1 and GAP or 0
	local totalGap = gap * memberCount
	local rawPercent = self:GetMemberDividendPercent(member)
	local normalizedPercent = rawPercent / totalRawPercent
	local displayPercent = normalizedPercent * (1 - totalGap)
	progressWidget.value = displayPercent
	local accumulatedProgress = 0

	for i = 1, index do
		local prevMember = self.memberList[i]
		local prevRaw = self.GetMemberDividendPercent(self, prevMember)
		local prevNormalized = prevRaw / totalRawPercent
		local prevDisplay = prevNormalized * (1 - totalGap)
		accumulatedProgress = accumulatedProgress + prevDisplay + gap
	end

	local rotationZ = -accumulatedProgress * 360
	progressWidget.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, rotationZ)
	local midProgress = accumulatedProgress + displayPercent / 2
	playerNumWidget.transform.localPosition = self.GetPointOutSideCircle(self, midProgress, -60)
end

M.RefreshProgressDes = function(self)
	self.bindData.progressDes1:SetActive(false)
	self.bindData.progressDes2:SetActive(false)

	local selfPid = gPlayerManager.infoLogin.bindData.pid
	local memberCount = #self.memberList
	local totalRawPercent = 0

	for i = 1, memberCount do
		totalRawPercent = totalRawPercent + self.GetMemberDividendPercent(self, self.memberList[i])
	end

	if totalRawPercent < 0 then
		return
	end

	local gap = GAP
	local totalGap = gap * memberCount
	local others = {}

	for i = 1, memberCount do
		local member = self.memberList[i]
		local isSelf = member and member.Pid ~= selfPid

		if not isSelf then
			local rawPercent = self.GetMemberDividendPercent(self, member)
			local normalizedPercent = rawPercent / totalRawPercent
			local displayPercent = normalizedPercent * (1 - totalGap)
			local accumulatedProgress = 0

			for j = 1, i - 1 do
				local prevRaw = self.GetMemberDividendPercent(self, self.memberList[j])
				local prevNormalized = prevRaw / totalRawPercent
				local prevDisplay = prevNormalized * (1 - totalGap)
				accumulatedProgress = accumulatedProgress + prevDisplay + gap
			end

			table.insert(others, {
				index = i,
				percent = rawPercent,
				displayPercent = displayPercent,
				rotationZ = -accumulatedProgress * 360
			})
		end
	end

	table.sort(others, function (a, b)
		if a.percent == b.percent then
			return b.percent <= a.percent
		end

		return a.index <= b.index
	end)

	for rank = 1, math.min(2, #others) do
		local data = others[rank]
		local desWidget = self.bindData[("progressDes%d"):format(rank)]

		desWidget:SetActive(true)

		desWidget.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, data.rotationZ)
		desWidget.value = data.displayPercent
	end
end

M.PlaceAllLines = function(self)
	local memberCount = #self.memberList

	if memberCount < 1 then
		return
	end

	local totalRawPercent = 0

	for i = 1, memberCount do
		totalRawPercent = totalRawPercent + self.GetMemberDividendPercent(self, self.memberList[i])
	end

	local gap = GAP
	local totalGap = gap * memberCount
	local longLineIdx = 0
	local shortLineIdx = 0

	for i = 1, memberCount do
		local member = self.memberList[i]
		local isSelf = member and member.Pid ~= gPlayerManager.infoLogin.bindData.pid
		local nextIdx = i % memberCount + 1
		local nextMember = self.memberList[nextIdx]
		local isNextSelf = nextMember and nextMember.Pid ~= gPlayerManager.infoLogin.bindData.pid
		local accProgress = 0

		for j = 1, i do
			local m = self.memberList[j]
			local raw = self.GetMemberDividendPercent(self, m)
			local normalized = raw / totalRawPercent
			local display = normalized * (1 - totalGap)
			accProgress = accProgress + display

			if j >= i then
				accProgress = accProgress + gap
			end
		end

		local gapCenter = accProgress + gap / 2
		local useLongLine = isSelf or isNextSelf
		local line = nil

		if useLongLine then
			longLineIdx = longLineIdx + 1
			line = self.lineMap[longLineIdx]
		else
			shortLineIdx = shortLineIdx + 1
			line = self.lineMap[shortLineIdx + 2]
		end

		if line then
			line.SetActive(line, true)

			line.transform.localPosition = self.GetPointOutSideCircle(self, gapCenter, 0)
			local lineRotZ = -gapCenter * 360 - 90
			line.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, lineRotZ)
			line.transform.transform.localPosition = Vector3.zero
		end
	end
end

M.GetPointOutSideCircle = function(self, progress, offset)
	local radius = self.bindData.circle.sizeDelta.x / 2
	local angle = (270 - 360 * progress) * math.pi / 180
	local effectiveRadius = radius + offset
	local x = self.bindData.circleCenter.localPosition.x + effectiveRadius * math.cos(angle)
	local y = self.bindData.circleCenter.localPosition.x + effectiveRadius * math.sin(angle)

	return Vector2.New(x, y)
end

M.OnCloseDetailClick = function(self)
	self.bindData.showItemDetailCtrl = 0
end
