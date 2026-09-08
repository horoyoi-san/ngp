-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_RobberyBoardTimeLineGuideTask1.lua
-- Decompiled from: 01395_S_RobberyBoardTimeLineGuideTask1.lua_eae7151a5258.luajit

C_S_RobberyBoardTimeLineGuideTask1 = DefClass("C_S_RobberyBoardTimeLineGuideTask1", C_S_RobberyBoardTimeLineGuideTask1, C_StoreGroup)
GroupName2Class.S_RobberyBoardTimeLineGuideTask1 = C_S_RobberyBoardTimeLineGuideTask1
local M = C_S_RobberyBoardTimeLineGuideTask1

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	local uiPivot = args and args.uiPivot

	if gClientUtils.IsNil(uiPivot) then
		return
	end

	self.id = args and args.id or 12150010

	self.rootGo.transform:ChangeLayersRecursively(Layer.Default)

	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
	self.tabDataList = self:GetTabDataList()
	self.currentRouteId = self.tabDataList[1].routeId

	self.bindData.tabList:SetSimpleList(#self.tabDataList)
	self:InitButtonStoreMap()
	self:RefreshPanelView()
	self:RefreshItemList()
end

M.GetTabDataList = function(self)
	local planningBoardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local allStepIdList = planningBoardCfg.AllStep
	self.routeStepMap = {}

	for _, stepId in ipairs(allStepIdList) do
		local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
		local stepIdList = self.routeStepMap[stepCfg.RouteGroup] or {}

		table.insert(stepIdList, stepId)

		self.routeStepMap[stepCfg.RouteGroup] = stepIdList
	end

	local routeIdList = {}

	for routeId, _ in pairs(self.routeStepMap) do
		table.insert(routeIdList, routeId)
	end

	table.sort(routeIdList)

	local viewDataList = {}

	for index, routeId in ipairs(routeIdList) do
		table.insert(viewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			routeId = routeId,
			tabIndex = index - 1
		})
	end

	return viewDataList
end

M.InitButtonStoreMap = function(self)
	self.buttonStoreMap = {}
	local stepIdList = self.GetCurrentRouteStepIdList(self)

	for index, stepId in ipairs(stepIdList) do
		local fieldName = ("step%d"):format(index)
		local button = self.bindData[fieldName]
		local store = self:GetWidgetStore(button)
		self.buttonStoreMap[stepId] = store
	end
end

M.GetCurrentRouteStepIdList = function(self)
	local routeId = self.GetCurrentRouteId(self)
	local stepIdList = self.routeStepMap[routeId]

	return stepIdList
end

M.GetCurrentRouteId = function(self)
	return self.currentRouteId
end

M.RefreshPanelView = function(self)
	local stepIdList = self.GetCurrentRouteStepIdList(self)

	for index, stepId in ipairs(stepIdList) do
		local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
		local taskId = stepCfg.TaskId
		local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(taskId)

		if multiPlayerCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardReady then
			self.RefreshCommonStepView(self, stepId, index)
		elseif multiPlayerCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardDividends then
			self.RefreshDividendsStepView(self, stepId, index)
		end
	end
end

M.RefreshDividendsStepView = function(self, stepId, index)
	self:RefreshCommonStepView(stepId, index)

	local store = self.buttonStoreMap[stepId]
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local taskId = stepCfg.TaskId
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(taskId)
	local itemIdList = multiPlayerCfg.NeedKeyIds

	store.needList.luaSimpleRenderItem = function(btn, childIndex)
		local childStore = self:GetWidgetStore(btn)
		local itemId = itemIdList[childIndex + 1]
		local itemData = gCommonItemManager:GetItemRenderData({
			["\\xd0\\xcf01\\xfc"] = 1,
			itemId = itemId
		})
		itemData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

		btn:SetPopupDirection(16)
		gCommonItemManager:OnCommonItemRender(btn, nil, itemData)

		local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
		childStore.iconId = consumableCfg.SItemIconId
		local teamOwnerCount = self:GetKeyOwnerCount(itemId)
		childStore.num = ("%d/%d"):format(teamOwnerCount, 1)
		childStore.isEnoughCtrl = teamOwnerCount > 1 and 1 or 0
	end

	store.needList:SetSimpleList(#itemIdList)
end

M.RefreshCommonStepView = function(self, stepId, index)
	local store = self.buttonStoreMap[stepId]
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local taskId = stepCfg.TaskId
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(taskId)
	store.name = multiPlayerCfg.Name
	store.desc = multiPlayerCfg.Description
	local itemId = multiPlayerCfg.KeyId

	if itemId and itemId <= 0 then
		local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
		store.iconId = consumableCfg.SItemIconId
	end

	local playerNumMin, playerNumMax = unpack(multiPlayerCfg.PlayerNum)

	if playerNumMin ~= playerNumMax then
		store.playerNum = LTConfig.TextScriptTextConfig.GetConfig(89901075).Text:format(playerNumMax)
	else
		store.playerNum = LTConfig.PlanningBoardConfig.LinkPlayerNumRequire:format(playerNumMin, playerNumMax)
	end

	store.imageList.luaSimpleRenderItem = function(childBtn, childIndex)
		local childStore = self:GetWidgetStore(childBtn)
		childStore.iconId = multiPlayerCfg.BoardPics[childIndex + 1]
	end

	store.keyOwnerCount = self:GetKeyOwnerCount(itemId)

	store.imageList:SetSimpleList(#multiPlayerCfg.BoardPics)

	if #multiPlayerCfg.BoardPics <= 1 then
		store.dotList:SetSimpleList(#multiPlayerCfg.BoardPics)
	else
		store.dotList:SetSimpleList(0)
	end

	local dropDataList = self.GetDropDataList(self, stepCfg.TaskId)

	if multiPlayerCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardDividends then
		local rewardList = gCommonItemManager:GetItemSortedListByDropList(dropDataList, true)
		rewardList[1] = rewardList[1] or self:GetDefaultMoneyItem()

		if multiPlayerCfg.DividendsExpectation <= 0 then
			local rewardItem = rewardList[1]
			rewardItem.Count = rewardItem.Count + multiPlayerCfg.DividendsExpectation
		end

		store.rewardList.luaSimpleRenderItem = function(childBtn, childIndex)
			local rewardItem = rewardList[childIndex + 1]
			local itemData = gCommonItemManager:GetItemRenderData({
				itemId = rewardItem.itemId,
				rewardItem = rewardItem.Count
			})
			itemData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

			childBtn:SetPopupDirection(4)
			gCommonItemManager:OnCommonItemRender(childBtn, nil, itemData)
		end

		store.rewardList:SetSimpleList(#rewardList)

		return
	end

	store.rewardList.luaSimpleRenderItem = function(childBtn, childIndex)
		local dropData = dropDataList[childIndex + 1]
		dropData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

		childBtn:SetPopupDirection(4)
		gCommonItemManager:OnCommonItemRender(childBtn, nil, dropData)

		local childStore = self:GetWidgetStore(childBtn)
		childStore.count = ""
	end

	store.rewardList:SetSimpleList(#dropDataList)
end

M.GetDefaultMoneyItem = function(self)
	return {
		["n\\xa1\\xb7\\xa1\\xa2"] = 0,
		itemId = LTConfig.ConsumableConfig.RewardMoney
	}
end

M.GetDropDataList = function(self, taskId)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(taskId)
	local dropList = {}

	for _, dropId in ipairs(multiPlayerCfg.DropSuccess) do
		table.insert(dropList, {
			dropId = dropId
		})
	end

	return gCommonItemManager:GetSingleSortedListRenderData(dropList)
end

M.GetKeyOwnerCount = function(self, itemId)
	local dividendsMultiPlayerId = self.GetCurrentRouteDividendsMultiPlayerId(self)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(dividendsMultiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local itemDetailDataList = gPlanningBoardManager.GetTeamItemDetailDataList(dividendsMultiPlayerId)
	local _, targetIndex = table.find(itemIdList, itemId)

	for _, detailData in ipairs(itemDetailDataList) do
		if detailData.tIndex ~= 2 then
			local totalDataList = detailData.dataList

			return totalDataList[targetIndex] or 0
		end
	end

	return 0
end

M.GetCurrentRouteDividendsMultiPlayerId = function(self)
	local stepIdList = self.GetCurrentRouteStepIdList(self)
	local stepId = stepIdList[#stepIdList]
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)

	return stepCfg.TaskId
end

M.RefreshItemList = function(self)
	local dividendsMultiPlayerId = self:GetCurrentRouteDividendsMultiPlayerId()
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(dividendsMultiPlayerId)
	local needItemIdList = multiPlayerCfg.NeedKeyIds

	self.bindData.itemList.luaSimpleRenderItem = function(btn, index)
		local store = self:GetWidgetStore(btn)
		local itemId = needItemIdList[index + 1]
		local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
		store.iconId = consumableCfg.SItemIconId
		local ownerCount = gCommonItemManager:GetPackItemNum(itemId)
		store.num = ownerCount
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

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LANGUAGE_CHANGE] = self.CreateAction(self, self.OnLanguageChange)
	}
end

M.RegisterWidget = function(self)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTabListItem")
end

M.GetWidgetStore = function(self, widget)
	return gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = self:GetWidgetStore(btn)
	local data = self.tabDataList[index + 1]
	local routeCfg = LTConfig.PlanningBoardRouteConfig.GetConfig(data.routeId)
	store.name = routeCfg.Desc
	btn.isSelected = data.routeId ~= self.currentRouteId
end

M.OnLanguageChange = function(self)
	self.bindData.tabList:RefreshList()
	self:RefreshPanelView()
end
