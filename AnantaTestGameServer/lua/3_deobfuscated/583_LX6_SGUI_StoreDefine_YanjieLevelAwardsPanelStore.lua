C_YanjieLevelAwardsPanelStore = DefClass("C_YanjieLevelAwardsPanelStore", C_YanjieLevelAwardsPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieLevelAwardsPanelStore = C_YanjieLevelAwardsPanelStore
local M = C_YanjieLevelAwardsPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.list.luaSimpleDynamicRenderItem = self:CreateAction("OnDynamicRenderItem")
end

function M:InitModel(args)
	M.base.InitModel(self, args)
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.viewDataList = self:GetViewDataList()

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

function M:GetViewDataList()
	local viewDataList = {}
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if growthCfg.Drop > 0 then
			table.insert(viewDataList, {
				id = growthCfg.Id
			})
		end
	end

	if #viewDataList > 0 then
		local lastViewData = viewDataList[#viewDataList]
		lastViewData.isLast = true
	end

	return viewDataList
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local id = data.id
	local growthCfg = LTConfig.GrowthConfig.GetConfig(id)
	local dropId = growthCfg.Drop
	local dropViewDataList = gCommonItemManager:GetSingleSortedListRenderData(dropId)

	for _, dropViewData in ipairs(dropViewDataList) do
		dropViewData.growthLv = growthCfg.Lv
	end

	function store.list.luaSimpleRenderItem(childBtn, childCsIndex)
		local childLuaIndex = childCsIndex + 1
		local childData = dropViewDataList[childLuaIndex]
		local hasReward = self:CheckLevelHasReward(childData.growthLv)
		childData.available = hasReward
		childData.hava = self:CheckHasGetAward(childData.growthLv)
		btn.enabledTooltip = not hasReward

		gCommonItemManager:OnCommonItemRender(btn, _, childData)

		if hasReward then
			btn.luaClick = self:CreateActionWithArgs(self.AskTakeLevelReward, childData.growthLv)
		else
			btn.luaClick = nil
		end
	end

	local dataCount = #dropViewDataList
	local row = math.ceil(dataCount / 4)
	local height = row * store.item.sizeDelta.y + store.list.rowSpacing * (row - 1)
	height = height + math.abs(store.list.transform.localPosition.y)
	local layoutSizeDelta = store.layout.sizeDelta
	store.layout.sizeDelta = Vector2.Fetch(layoutSizeDelta.x, height)

	store.list:SetSimpleList(dataCount)

	store.isReachLevelControl = self:CheckIsReachLevel(growthCfg.Lv) and 1 or 0
	store.isGetAwardControl = self:CheckHasGetAward(growthCfg.Lv) and 1 or 0
	store.isLastControl = data.isLast and 1 or 0
	store.button.luaClick = self:CreateActionWithArgs(self.AskTakeLevelReward, growthCfg.Lv)
end

function M:AskTakeLevelReward(targetLevel)
	if self:CheckLevelHasReward(targetLevel) then
		local rootGo = self.rootGo

		gClientToGameDelegate:AskTakeLevelReward(targetLevel).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			local levelRewardList = gPlayerManager.infoMinor.bindData.levelRewardList

			for index, levelReward in ipairs(levelRewardList) do
				if levelReward == targetLevel then
					table.remove(levelRewardList, index)
				end
			end

			gMessageManager:SendMessage(gEventConstants.ON_LEVEL_REWARD_UPDATE)

			if gClientUtils.IsNil(rootGo) then
				return
			end

			self.bindData.list:RefreshList()
		end
	end
end

function M:CheckLevelHasReward(targetLevel)
	local levelRewardList = gPlayerManager.infoMinor.bindData.levelRewardList

	for _, levelReward in ipairs(levelRewardList) do
		if levelReward == targetLevel then
			return true
		end
	end
end

function M:CheckHasGetAward(targetLevel)
	local currentLevel = gPlayerManager.infoMinor.bindData.level

	if targetLevel <= currentLevel then
		local growthId = gClientUtils.GetGrowthIdByLv(targetLevel)
		local growthCfg = LTConfig.GrowthConfig.GetConfig(growthId)

		if growthCfg.Drop > 0 then
			local levelRewardList = gPlayerManager.infoMinor.bindData.levelRewardList

			for _, levelReward in ipairs(levelRewardList) do
				if levelReward == targetLevel then
					return false
				end
			end

			return true
		end
	end
end

function M:CheckIsReachLevel(targetLevel)
	local currentLevel = gPlayerManager.infoMinor.bindData.level

	return targetLevel < currentLevel
end

function M:OnDynamicRenderItem(btn, _, data)
	self:OnRenderItem(btn, _, data)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
