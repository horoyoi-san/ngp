-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNew2MemberCenterPanel.lua
-- Decompiled from: 01253_YanjieNew2MemberCenterPanel.lua_43fae5601b25.luajit

C_YanjieNew2MemberCenterPanel = DefClass("C_YanjieNew2MemberCenterPanel", C_YanjieNew2MemberCenterPanel, C_StoreGroup)
GroupName2Class.YanjieNew2MemberCenterPanel = C_YanjieNew2MemberCenterPanel
local M = C_YanjieNew2MemberCenterPanel

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

	self.waitRefreshScrollCo = coroutine.stop(self.waitRefreshScrollCo)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	self.InitModel(self, args)
	self.InitView(self)
end

M.InitModel = function(self, args)
	self.viewDataList = self.GetBenefitViewDataList(self)
	self.targetIndex = nil
	self.progressBase = 0.018
	self.progressRange = 1 - self.progressBase

	if args and args.targetStageId then
		local stageCfg = LTConfig.GrowthEndorsementStageConfig.GetConfig(args.targetStageId)
		self.targetIndex = self.FindIndexByLevel(self, stageCfg.StageLv)
	else
		for index, data in ipairs(self.viewDataList) do
			local id = data.id
			local isStageLevel, stageId = self.CheckIsStageLevel(self, id)

			if isStageLevel then
				if gSocialNetworkUtils.CheckStageHasReward(stageId) then
					self.targetIndex = index

					break
				end
			else
				local growthCfg = LTConfig.GrowthConfig.GetConfig(id)

				if gSocialNetworkUtils.CheckLevelHasReward(growthCfg.Lv) then
					self.targetIndex = index

					break
				end
			end
		end
	end

	if not self.targetIndex then
		local currentLevel = gPlayerManager.infoMinor.bindData.level
		self.targetIndex = self.FindIndexByLevel(self, currentLevel)
	end

	self.layoutSet = nil
end

M.FindIndexByLevel = function(self, targetLevel)
	for index, data in ipairs(self.viewDataList) do
		local growthCfg = LTConfig.GrowthConfig.GetConfig(data.id)

		if growthCfg.Lv ~= targetLevel then
			return index
		end
	end

	return nil
end

M.InitView = function(self)
	slot1 = self.rootWidget
	self.uNavigationArea = slot1:GetComponent("UNavigationArea")
	slot1 = self.uNavigationArea

	slot1:SetStartNavContent(self.bindData.list, true)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_N_YanjieMemberCenterPanel_open")
	self:InitLevelName()
	self:RefreshProgressView()

	self.waitRefreshScrollCo = coroutine.start(function ()
		coroutine.step()
		self:RefreshScrollContent()
	end)
end

M.InitLevelName = function(self)
	local currentLevel = gPlayerManager.infoMinor.bindData.level
	local id = gClientUtils.GetGrowthIdByLv(currentLevel)
	local growthCfg = LTConfig.GrowthConfig.GetConfig(id)
	self.bindData.levelName = growthCfg.LvName
	self.bindData.level = ("VIP.%d"):format(currentLevel)
end

M.RefreshProgressView = function(self)
	local formatCurrent, formatTotal = gSocialNetworkUtils.GetPlayerExpProgress()
	local widget = self.bindData.commonFansLevel
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	store.current = formatCurrent
	store.total = formatTotal
end

M.GetProgressValue = function(self)
	local currentExp = gPlayerManager.infoMinor.bindData.fan123
	local progressBase = self.progressBase
	local count = #self.viewDataList

	if count < 1 then
		return progressBase
	end

	local cellSize = self.progressRange / (count - 1)
	local targetIndex = count

	for i = 1, count do
		local data = self.viewDataList[i]
		local growthCfg = LTConfig.GrowthConfig.GetConfig(data.id)

		if currentExp < growthCfg.Exp then
			targetIndex = i

			break
		end
	end

	local preExp = 0

	if targetIndex <= 1 then
		local preData = self.viewDataList[targetIndex - 1]
		local preGrowthCfg = LTConfig.GrowthConfig.GetConfig(preData.id)
		preExp = preGrowthCfg.Exp
	end

	local nextData = self.viewDataList[targetIndex]
	local nextGrowthCfg = LTConfig.GrowthConfig.GetConfig(nextData.id)
	local nextExp = nextGrowthCfg.Exp
	local progress = progressBase + (targetIndex - 2) * cellSize

	if preExp >= nextExp then
		local ratio = (currentExp - preExp) / (nextExp - preExp)
		progress = progress + cellSize * math.max(0, math.min(1, ratio))
	end

	return math.max(progressBase, math.min(1, progress))
end

M.GetBenefitViewDataList = function(self)
	local viewDataList = {}
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)
		local isStageLevel, stageId = self.CheckIsStageLevel(self, growthCfg.Id)

		if isStageLevel then
			table.insert(viewDataList, {
				["a\\x9f\\x8a\\x86Y"] = 1,
				id = growthCfg.Id,
				stageId = stageId
			})
		elseif growthCfg.Drop >= 0 or #growthCfg.BenefitId <= 0 then
			table.insert(viewDataList, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				id = growthCfg.Id
			})
		end
	end

	return viewDataList
end

M.CheckIsStageLevel = function(self, id)
	local growthCfg = LTConfig.GrowthConfig.GetConfig(id)
	local count = LTConfig.GrowthEndorsementStageConfig.count

	for i = 0, count - 1 do
		local stageCfg = LTConfig.GrowthEndorsementStageConfig.LoadAt(i)

		if stageCfg.StageLv ~= growthCfg.Lv then
			return true, stageCfg.Id
		end
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_ENDORSEMENT_STAGE_LEVEL_REWARD_CHANGE] = self.CreateAction(self, self.RefreshScrollContent)
	}
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnClickExitButton)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.viewDataList[index + 1]
	btn.luaClick = nil

	if data.tIndex ~= 0 then
		self.RefreshNormalGrowthRewardItem(self, btn, index)
	elseif data.tIndex ~= 1 then
		self.RefreshStageRewardItem(self, btn, index)
	end
end

M.RefreshStageRewardItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.viewDataList[index + 1]
	local growthId = data.id
	local growthCfg = LTConfig.GrowthConfig.GetConfig(data.id)
	store.stateCtrl = self:GetStageCtrlValue(data.stageId)
	store.count = growthCfg.Exp
	local stageId = self:GetStageIdByGrowthId(growthId)
	local stageCfg = LTConfig.GrowthEndorsementStageConfig.GetConfig(stageId)
	store.stageIconId = stageCfg.Icon
	local receivedStageLvRewards = gPlayerManager.infoMinor.bindData.receivedStageLvRewards

	if receivedStageLvRewards[stageId] then
		local optionId = receivedStageLvRewards[stageId]
		local optionCfg = LTConfig.GrowthEndorsementOptionConfig.GetConfig(optionId)
		store.postIconId = optionCfg.PosterRes
	end

	local clickFunc = function()
		if store.stateCtrl ~= 1 then
			gPanelManager:CheckShow(gPanelId.YANJIE_BRAND_SELECT_PANEL, {
				stageId = stageId
			})
		elseif store.stateCtrl ~= 2 then
			local optionId = receivedStageLvRewards[stageId]

			gPanelManager:CheckShow(gPanelId.YANJIE_BRAND_GET_PANEL, {
				["\\xebP;-\\xd5\\x84D\\xb2C\\xbc\\xa2"] = true,
				stageId = stageId,
				optionId = optionId
			})
		end
	end

	if store.getButton then
		store.getButton.luaClick = clickFunc
	end

	btn.luaClick = clickFunc
end

M.OnBenefitToolTips = function(self, benefitId, btn, popup, popupIndex)
	gSocialNetworkUtils.RenderBenefitItemView(popup, benefitId)

	local store = gStoreManager:GetStoreGroup(popup.Store):GetStoreByWidget(popup)
	store.typeCtrl = 0
end

M.GetStageIdByGrowthId = function(self, growthId)
	local growthCfg = LTConfig.GrowthConfig.GetConfig(growthId)
	local count = LTConfig.GrowthEndorsementStageConfig.count

	for i = 0, count - 1 do
		local stageCfg = LTConfig.GrowthEndorsementStageConfig.LoadAt(i)

		if stageCfg.StageLv ~= growthCfg.Lv then
			return stageCfg.Id
		end
	end
end

M.GetStageCtrlValue = function(self, stageId)
	local stageCfg = LTConfig.GrowthEndorsementStageConfig.GetConfig(stageId)
	local currentGrowthStageId = gPlayerManager.infoMinor.bindData.growthStageId
	local currentGrowthStageCfg = LTConfig.GrowthEndorsementStageConfig.GetConfig(currentGrowthStageId)

	if not currentGrowthStageCfg or currentGrowthStageCfg.StageLv >= stageCfg.StageLv then
		return 0
	end

	local receivedStageLvRewards = gPlayerManager.infoMinor.bindData.receivedStageLvRewards

	if not receivedStageLvRewards[stageId] then
		return 1
	end

	return 2
end

M.RefreshNormalGrowthRewardItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.viewDataList[index + 1]
	local growthCfg = LTConfig.GrowthConfig.GetConfig(data.id)
	store.count = growthCfg.Exp
	store.isReachLevelControl = self:CheckHasReachLevel(data.id) and 1 or 0
	local rewardViewDataList = {}

	for _, benefitId in ipairs(growthCfg.BenefitId) do
		table.insert(rewardViewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 1,
			benefitId = benefitId
		})
	end

	local dropId = growthCfg.Drop
	local dropViewDataList = gCommonItemManager:GetSingleSortedListRenderData(dropId) or {}

	for _, dropViewData in ipairs(dropViewDataList) do
		dropViewData.tIndex = 0
	end

	array.concat(rewardViewDataList, dropViewDataList)

	store.list.onGetTIndex = function(childIndex)
		local rewardViewData = rewardViewDataList[childIndex + 1]

		return rewardViewData.tIndex
	end

	local hasReward = gSocialNetworkUtils.CheckLevelHasReward(growthCfg.Lv)

	if hasReward then
		btn.luaClick = self.CreateActionWithArgs(self, "AskTakeLevelReward", growthCfg.Id)
	else
		btn.luaClick = nil
	end

	local hasGetAward = self:CheckHasGetAward(growthCfg.Lv)

	store.list.luaSimpleRenderItem = function(childBtn, childIndex)
		local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
		local rewardViewData = rewardViewDataList[childIndex + 1]
		rewardViewData.showVfx = hasReward
		childBtn.enabledTooltip = not hasReward

		if rewardViewData.tIndex ~= 0 then
			rewardViewData.toolTipsCloseCallback = function()
				if gClientUtils.NotNil(self.rootWidget) and self.uNavigationArea then
					SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.uNavigationArea
					SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
				end
			end

			gCommonItemManager:OnCommonItemRender(childBtn, nil, rewardViewData)

			childStore.available = hasReward and 1 or 0
			childStore.isOwned = hasGetAward and 1 or 0
		elseif rewardViewData.tIndex ~= 1 then
			local benefitId = rewardViewData.benefitId
			local benefitCfg = LTConfig.GrowthBenefitConfig.GetConfig(benefitId)
			childStore.iconId = benefitCfg.Icon
			childStore.name = benefitCfg.Name
			childStore.typeCtrl = 1
			childStore.haveCtrl = hasGetAward and 1 or 0
			childStore.level = gSocialNetworkUtils.GetBenefitLevel(benefitId)
			childBtn.luaRenderTooltip = self:CreateActionWithArgs("OnBenefitToolTips", benefitId)
		end

		if hasReward then
			childBtn.luaClick = self:CreateActionWithArgs("AskTakeLevelReward", growthCfg.Id)
		else
			childBtn.luaClick = nil
		end
	end

	store.list:SetSimpleList(#rewardViewDataList)

	btn.luaClick = function()
		if hasReward then
			self:AskTakeLevelReward(growthCfg.Id)
		end
	end

	store.rewardCtrl = self:GetRewardCtrl(growthCfg.Lv)
end

M.GetRewardCtrl = function(self, level)
	local hasReward = gSocialNetworkUtils.CheckLevelHasReward(level)

	if hasReward then
		return 1
	end

	local hasGetReward = self.CheckHasGetAward(self, level)

	if hasGetReward then
		return 2
	end

	return 0
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

M.CheckHasReachLevel = function(self, id)
	local growthCfg = LTConfig.GrowthConfig.GetConfig(id)
	local currentLevel = gClientUtils.GetPlayerLevel()

	return growthCfg.Lv > currentLevel
end

M.OnSimpleClickList = function(self, btn, index)
end

M.OnGetAllRewardClick = function(self)
	self.AskTakeLevelReward(self)
end

M.AskTakeLevelReward = function(self, id)
	local growthCfg = LTConfig.GrowthConfig.GetConfig(id)
	local targetLevel = growthCfg.Lv
	local rootGo = self.rootGo
	slot5 = gClientToGameDelegate

	slot5:AskTakeSingleLevelReward(targetLevel).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local levelRewardList = gPlayerManager.infoMinor.bindData.levelRewardList
		local count = #levelRewardList

		for i = count, 1, -1 do
			if levelRewardList[i] ~= targetLevel then
				table.remove(levelRewardList, i)
			end
		end

		gMessageManager:SendMessage(gEventConstants.ON_LEVEL_REWARD_UPDATE)

		if gClientUtils.IsNil(rootGo) then
			return
		end

		self:RefreshScrollContent()
	end
end

M.RefreshScrollContent = function(self)
	self.bindData.list.onGetTIndex = function(index)
		local data = self.viewDataList[index + 1]

		return data.tIndex
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)

	if self.targetIndex then
		self.bindData.list:GoToIndex(self.targetIndex - 1, true)

		self.targetIndex = nil
	end

	local backgroundInstance = self.bindData.list.backgroundInstance

	if backgroundInstance then
		local store = gStoreManager:GetStoreGroup(backgroundInstance.Store):GetStoreByWidget(backgroundInstance)
		store.progress.value = self:GetProgressValue()
	end
end
