-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieLevelAwardsPanelStore.lua
-- Decompiled from: 02061_YanjieLevelAwardsPanelStore.lua_cd6adae61518.luajit

C_YanjieLevelAwardsPanelStore = DefClass("C_YanjieLevelAwardsPanelStore", C_YanjieLevelAwardsPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieLevelAwardsPanelStore = C_YanjieLevelAwardsPanelStore
local M = C_YanjieLevelAwardsPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnDynamicRenderItem")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	self.viewDataList = self:GetViewDataList()

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

M.GetViewDataList = function(self)
	local viewDataList = {}
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if growthCfg.Drop <= 0 then
			table.insert(viewDataList, {
				id = growthCfg.Id
			})
		end
	end

	if #viewDataList <= 0 then
		local lastViewData = viewDataList[#viewDataList]
		lastViewData.isLast = true
	end

	return viewDataList
end

M.OnRenderItem = function(self, btn, csIndex)
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

	store.list.luaSimpleRenderItem = function(childBtn, childCsIndex)
		local childLuaIndex = childCsIndex + 1
		local childData = dropViewDataList[childLuaIndex]
		local hasReward = gSocialNetworkUtils.CheckLevelHasReward(childData.growthLv)
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

M.AskTakeLevelReward = function(self, targetLevel)
	if gSocialNetworkUtils.CheckLevelHasReward(targetLevel) then
		local rootGo = self.rootGo
		slot3 = gClientToGameDelegate

		slot3:AskTakeLevelReward(targetLevel).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			local levelRewardList = gPlayerManager.infoMinor.bindData.levelRewardList

			for index, levelReward in ipairs(levelRewardList) do
				if levelReward ~= targetLevel then
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

M.CheckHasGetAward = function(self, targetLevel)
	local currentLevel = gPlayerManager.infoMinor.bindData.level

	if targetLevel < currentLevel then
		local growthId = gClientUtils.GetGrowthIdByLv(targetLevel)
		local growthCfg = LTConfig.GrowthConfig.GetConfig(growthId)

		if growthCfg.Drop <= 0 then
			local levelRewardList = gPlayerManager.infoMinor.bindData.levelRewardList

			for _, levelReward in ipairs(levelRewardList) do
				if levelReward ~= targetLevel then
					return false
				end
			end

			return true
		end
	end
end

M.CheckIsReachLevel = function(self, targetLevel)
	local currentLevel = gPlayerManager.infoMinor.bindData.level

	return targetLevel <= currentLevel
end

M.OnDynamicRenderItem = function(self, btn, _, data)
	self.OnRenderItem(self, btn, _, data)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
