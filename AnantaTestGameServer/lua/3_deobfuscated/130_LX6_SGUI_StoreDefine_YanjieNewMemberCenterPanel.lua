C_YanjieNewMemberCenterPanel = DefClass("C_YanjieNewMemberCenterPanel", C_YanjieNewMemberCenterPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewMemberCenterPanel = C_YanjieNewMemberCenterPanel
local M = C_YanjieNewMemberCenterPanel

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.getAllRewardButton.luaClick = self:CreateAction("OnGetAllRewardClick")
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.LIST_TEMPLATE_TYPE = {
		CONTENT = 1,
		TITLE = 0
	}
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.viewDataList = self:GetBenefitViewDataList()

	self.bindData.list:SetSimpleList(#self.viewDataList)
	gSocialNetworkUtils.RefreshPlayerExpProgressView(self.bindData.commonFansLevel)
	self:RefreshGetAllRewardButtonView()
end

function M:RefreshGetAllRewardButtonView()
	local hasLevelReward = gClientUtils.CheckHasLevelReward()

	self.bindData.getAllRewardButton:SetActive(hasLevelReward)
end

function M:GetBenefitViewDataList()
	local viewDataList = {}
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if #growthCfg.Benefit > 0 then
			local benefitViewDataList = {}

			table.insert(benefitViewDataList, {
				tIndex = self.LIST_TEMPLATE_TYPE.TITLE,
				id = growthCfg.Id
			})

			for index, _ in ipairs(growthCfg.Benefit) do
				table.insert(benefitViewDataList, {
					tIndex = self.LIST_TEMPLATE_TYPE.CONTENT,
					id = growthCfg.Id,
					benefitIndex = index
				})
			end

			table.insert(viewDataList, {
				id = growthCfg.Id,
				benefitViewDataList = benefitViewDataList
			})
		end
	end

	return viewDataList
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	function store.list.onGetTIndex(onGetCsIndex)
		local benefitData = data.benefitViewDataList[onGetCsIndex + 1]

		return benefitData.tIndex
	end

	function store.list.luaSimpleRenderItem(childBtn, childCsIndex)
		local childLuaIndex = childCsIndex + 1
		local childData = data.benefitViewDataList[childLuaIndex]
		local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)

		if childData.tIndex == self.LIST_TEMPLATE_TYPE.TITLE then
			local growthCfg = LTConfig.GrowthConfig.GetConfig(childData.id)
			local exp = gClientUtils.GetTargetLevelExp(growthCfg.Lv)
			childStore.title = LTConfig.TextScriptTextConfig.GetConfig(89901171).Text:format(exp)
		elseif childData.tIndex == self.LIST_TEMPLATE_TYPE.CONTENT then
			local benefitIndex = childData.benefitIndex
			local growthCfg = LTConfig.GrowthConfig.GetConfig(childData.id)
			local benefit = growthCfg.Benefit[benefitIndex]
			childStore.title = benefit.benefitname
			childStore.description = benefit.benefitdescription
			childStore.iconId = growthCfg.BenefitIcon[benefitIndex] or 0
		end
	end

	store.list:SetSimpleList(#data.benefitViewDataList)

	store.isReachLevelControl = self:CheckHasReachLevel(data.id) and 1 or 0
	local growthCfg = LTConfig.GrowthConfig.GetConfig(data.id)
	local dropId = growthCfg.Drop
	local dropViewDataList = gCommonItemManager:GetSingleSortedListRenderData(dropId) or {}

	for _, dropViewData in ipairs(dropViewDataList) do
		dropViewData.growthLv = growthCfg.Lv
	end

	function store.rewardList.luaSimpleRenderItem(childBtn, childCsIndex)
		local childData = dropViewDataList[childCsIndex + 1]
		local hasReward = self:CheckLevelHasReward(childData.growthLv)
		childBtn.enabledTooltip = not hasReward

		gCommonItemManager:OnCommonItemRender(childBtn, nil, childData)

		local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
		childStore.available = hasReward and 1 or 0
		childStore.have = self:CheckHasGetAward(childData.growthLv) and 1 or 0

		if hasReward then
			childBtn.luaClick = self:CreateActionWithArgs("AskTakeLevelReward")
		else
			childBtn.luaClick = nil
		end
	end

	store.rewardList:SetSimpleList(#dropViewDataList)

	local hasDrop = #dropViewDataList > 0

	store.rewardNode:SetActive(hasDrop)
	store.controllerKeyNode:SetActive(hasDrop)
end

function M:AskTakeLevelReward()
	local targetLevel = gClientUtils.GetPlayerLevel()
	local rootGo = self.rootGo

	gClientToGameDelegate:AskTakeLevelReward(targetLevel).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gPlayerManager.infoMinor.bindData.levelRewardList = {}

		gMessageManager:SendMessage(gEventConstants.ON_LEVEL_REWARD_UPDATE)

		if gClientUtils.IsNil(rootGo) then
			return
		end

		self.bindData.list:RefreshList()
		self:RefreshGetAllRewardButtonView()
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

function M:CheckHasReachLevel(id)
	local growthCfg = LTConfig.GrowthConfig.GetConfig(id)
	local currentLevel = gClientUtils.GetPlayerLevel()

	return growthCfg.Lv <= currentLevel
end

function M:OnGetAllRewardClick()
	self:AskTakeLevelReward()
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
