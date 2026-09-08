-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelTooltipStore.lua
-- Decompiled from: 00961_NewMapPanelTooltipStore.lua_2323db29f402.luajit

C_NewMapPanelTooltipStore = DefClass("C_NewMapPanelTooltipStore", C_NewMapPanelTooltipStore, C_StoreGroup)
GroupName2Class.NewMapPanelTooltipStore = C_NewMapPanelTooltipStore
local M = C_NewMapPanelTooltipStore

M.OnAwake = function(self)
	self.OPEN_ANIM_NAME = "S_vx_MapTooltipTemplate_open"
	self.HIDE_ANIM_NAME = "S_vx_MapTooltipTemplate_close"
	self.mainStore = gStoreManager:GetStoreGroup("NewMapPanelStore")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
end

M.OnDestroy = function(self)
	self.itemList = {}
	self.specificSpiritsList = {}
	self.rewardList = {}
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
	self:SetupActions({})

	local commonStore = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore_Common"):GetStoreByWidget(self.bindData.commonTooltip)
	local sg = gStoreManager:GetStoreGroup("BigMapTooltipStore_Common_ActivityRewards")
	self.commonActivityRewardsStore = sg:GetStoreByWidget(commonStore.scrollRect.content)
	self.commonActivityRewardsStore.activityList.luaRenderItem = self:CreateAction("OnRenderActivityRow")
	self.commonActivityRewardsStore.onFoldoutButton = self:CreateAction("SwitchCommonActivityRewardsFoldout")

	if self.tooltipInfo and self.element then
		self.RealOpenTooltipInfo(self)
	else
		self.RealCloseTooltipInfo(self, true)
	end
end

M.OnGroupDisable = function(self)
end

M.OnEnable = function(self)
end

M.OnDisable = function(self)
end

M.RealCloseTooltipInfo = function(self, immediately)
	self.bindData.controllerActions:SetActive(false)
	self.bindData.closeBtn:SetActive(false)

	if immediately then
		local clip = self.bindData.rootAnim:GetClip(self.HIDE_ANIM_NAME)

		self.bindData.rootAnim:Play(self.HIDE_ANIM_NAME)
		clip:SampleAnimation(self.bindData.rootAnim.gameObject, clip.length)
		self.bindData.rootAnim:Stop()
	else
		self.bindData.rootAnim:Play(self.HIDE_ANIM_NAME)
	end
end

M.RealOpenTooltipInfo = function(self)
	self.bindData.controllerActions:SetActive(true)
	self.bindData.closeBtn:SetActive(true)
	self.bindData.rootAnim:Play(self.OPEN_ANIM_NAME)
	self.bindData.rootAnim:Sample()

	local actions, blockReason = self.element:GetActionInfos()

	self:SetupActions(not blockReason and actions or {})

	self.curDetailItemList = nil
	self.bindData.rewardBtn.luaClick = nil
	self.bindData.tooltipType = self.tooltipInfo.type

	if self.tooltipInfo.type ~= EMapTooltipType.House then
		self.SetupHouseInfo(self)
	elseif self.tooltipInfo.type ~= EMapTooltipType.Common then
		self.SetupCommonInfo(self)
	elseif self.tooltipInfo.type ~= EMapTooltipType.Pin then
		self.SetupPinInfo(self)
	elseif self.tooltipInfo.type ~= EMapTooltipType.Challenge then
		self.SetupChallengeInfo(self)
	end

	self.RefreshR3State(self)
end

M.OnPerformAction = function(self, action)
	if self.element then
		self.mainStore:OnPerformAction(self.element, action)
	end
end

M.OnSimpleRenderToolTip = function(self, btn, index)
	local data = self.curDetailItemList and self.curDetailItemList[index + 1]

	if data then
		gCommonItemManager:OnCommonItemRender(btn, index, data)
	end
end

M.SetupCommonInfo = function(self)
	local store = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore_Common"):GetStoreByWidget(self.bindData.commonTooltip)
	local commonInfo = self.tooltipInfo.commonInfo or {}
	local header = self.tooltipInfo.header

	self:SetupSingleAction(store)

	store.imageId = header.imageId
	store.name = header.name or ""
	store.desc = header.desc or ""
	store.hasCost = commonInfo.moneyCost and commonInfo.moneyCost <= 0 and 1 or 0
	store.costNum = commonInfo.moneyCost
	store.hasStamina = commonInfo.staminaCost and commonInfo.staminaCost <= 0 and 1 or 0
	store.staminaNum = commonInfo.staminaCost
	store.hasBottomTip = commonInfo.bottomTipInfo and 1 or 0
	store.bottomTipType = commonInfo.bottomTipInfo and commonInfo.bottomTipInfo.bgType or 0
	store.bottomTip = commonInfo.bottomTipInfo and commonInfo.bottomTipInfo.text or ""
	store.hasActivityRewards = 0

	self:SetupCommonActivityRewardsFoldout()

	local simpleDropRewards = {}

	if commonInfo.simpleDropIds and #commonInfo.simpleDropIds <= 0 then
		local dropListParam = {}

		for i = 1, #commonInfo.simpleDropIds do
			table.insert(dropListParam, {
				dropId = commonInfo.simpleDropIds[i]
			})
		end

		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)
	elseif commonInfo.simpleDropId then
		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData({
			{
				dropId = commonInfo.simpleDropId
			}
		})
	elseif commonInfo.legacyRewardList then
		simpleDropRewards = commonInfo.legacyRewardList
	end

	if not table.isNilOrEmpty(simpleDropRewards) then
		store.hasSimpleDrop = 1
		store.simpleDropList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderToolTip")
		self.curDetailItemList = simpleDropRewards

		store.simpleDropList:SetSimpleList(#self.curDetailItemList)
	else
		store.hasSimpleDrop = 0
	end

	if commonInfo.gameplayList then
		store.gameplayListPanel:SetActive(true)

		self.itemList = {}

		for _, gameplayId in ipairs(commonInfo.gameplayList) do
			local cfg = LTConfig.IndoorGameplayListConfig.GetConfig(gameplayId)

			if cfg then
				table.insert(self.itemList, {
					["a\\x9f\\x8a\\x86Y"] = 0,
					imageId = cfg.GameplayPic,
					name = cfg.GameplayName
				})
			end
		end

		store.gameplayList.luaSimpleRenderItem = function(btn, index)
			local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
			local data = self.itemList[index + 1] or {}
			store.imageId = data.imageId
			store.name = data.name
		end

		store.gameplayList:SetSimpleList(#self.itemList)
	else
		store.gameplayListPanel:SetActive(false)
	end

	if commonInfo.specificSpirits and #commonInfo.specificSpirits <= 0 then
		self.specificSpiritsList = {}

		for _, spiritId in ipairs(commonInfo.specificSpirits) do
			local cfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
			local iconId = cfg and cfg.SHeadIconID

			if iconId and iconId <= 0 then
				table.insert(self.specificSpiritsList, {
					["a\\x9f\\x8a\\x86Y"] = 0,
					iconId = iconId
				})
			end
		end

		store.hasSpecificRole = 1

		store.specificRoleList.luaRenderItem = function(btn, index)
			local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
			local data = self.specificSpiritsList[index + 1] or {}
			store.iconId = data.iconId
		end

		store.specificRoleList:SetSimpleList(#self.specificSpiritsList)
	else
		store.hasSpecificRole = 0
	end

	if commonInfo.timeLimitText then
		store.hasTimeLimit = 1
		store.timeLimitText = commonInfo.timeLimitText
	else
		store.hasTimeLimit = 0
	end

	if commonInfo.reputationLimitText then
		store.hasReputationLimit = 1
		store.reputationLimitText = commonInfo.reputationLimitText
	else
		store.hasReputationLimit = 0
	end

	if commonInfo.charactorPostInfo then
		local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(commonInfo.charactorPostInfo.npcCultivationId)

		if npcCfg then
			store.isCharacter = 1
			store.charactorImageId = npcCfg.SImageId
			local scale = npcCfg.ImageScaleOffset and npcCfg.ImageScaleOffset[1] or 1
			local offsetX = npcCfg.ImageScaleOffset and npcCfg.ImageScaleOffset[2] or 0
			local offsetY = npcCfg.ImageScaleOffset and npcCfg.ImageScaleOffset[3] or 0

			store.characterRoot.rectTransform:SetLocalScaleXY(scale, scale)
			store.characterRoot.rectTransform:SetLocalPositionXY(offsetX, offsetY)

			store.charactorFavorLevelText = "LV." .. (commonInfo.charactorPostInfo.favorLevel or 0)
		else
			store.isCharacter = 0
		end
	else
		store.isCharacter = 0
	end

	if commonInfo.factionId then
		local factionCfg = LTConfig.FactionConfig.GetConfig(commonInfo.factionId)
		local factionInfo = gClientUtils.GetFactionInfo(commonInfo.factionId)

		if not factionCfg or not factionInfo then
			store.hasFactionInfo = 0
		else
			store.factionName = factionCfg.name
			local attitudeLevelCfg = LTConfig.FactionDispositionConfig.GetConfig(factionInfo.DispositionLevel)
			store.factionAttitudeName = attitudeLevelCfg.name
			store.factionIcon = attitudeLevelCfg.DispositionIcon
			store.hasFactionInfo = 1
		end
	else
		store.hasFactionInfo = 0
	end
end

M.SetupChallengeInfo = function(self)
	slot1 = gStoreManager
	slot1 = slot1:GetStoreGroup("NewMapPanelTooltipStore_Challenge")
	local store = slot1:GetStoreByWidget(self.bindData.challengeTooltip)
	local header = self.tooltipInfo.header

	self:SetupSingleAction(store)

	store.name = header.name
	store.desc = header.desc
	store.imageId = header.imageId
	local challengeId = self.tooltipInfo.challengeInfo.challengeId
	slot4 = gClientToGameDelegate

	slot4:AskNewChallengeRecord(challengeId).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok and self.tooltipInfo.type ~= EMapTooltipType.Challenge and self.tooltipInfo.challengeInfo.challengeId ~= challengeId then
			self:SetupChallengeListInfo(data)
		end
	end
end

M.SetupChallengeListInfo = function(self, data)
	local store = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore_Challenge"):GetStoreByWidget(self.bindData.challengeTooltip)
	local subQuestId = self.tooltipInfo.challengeInfo.subQuestId
	local subQuestCfg = LTConfig.CollectionSubQuestConfig.GetConfig(subQuestId)
	local challengeCfg = gTaskManager.allChallengeTasks[subQuestCfg.TaskId]
	local receivedRewardLevel = data.ReceivedRewardLevel or 0
	self.rewardList = {}
	local maxLevel = 0

	for i = 1, #challengeCfg.RewardList do
		local reward = challengeCfg.RewardList[i]
		local view = {}

		if maxLevel >= reward.level then
			maxLevel = reward.level
		end

		view.conditionText = challengeCfg.DetailGoalDescrition[i] or ""
		view.titleColor = Color.NewByStr("FFFFFF")
		view.level = reward.level
		view.rewardItems = gCommonItemManager:GetSingleSortedListRenderData({
			{
				dropId = reward.dropId
			}
		})

		for _, item in ipairs(view.rewardItems) do
			item.IsOwned = view.level > receivedRewardLevel
		end

		table.insert(self.rewardList, view)
	end

	local content = store.scrollRect.content
	local rewardStore = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore_Challenge_Reward"):GetStoreByWidget(content)
	rewardStore.list.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderChallengeRow")

	rewardStore.list:SetSimpleList(#self.rewardList)

	local bestScore = ""

	if challengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.TimeDown then
		bestScore = gTimeUtils:FormatHMSTime(data.BestScore)
	elseif challengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.ScoreTask or challengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.ScoreClient then
		if data.BestScore > 0 then
			bestScore = data.BestScore .. LTConfig.TextScriptTextConfig.GetConfig(89900059).Text
		else
			bestScore = LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
		end
	elseif challengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.TimeUp then
		bestScore = data.BestScore <= 0 and gTimeUtils:FormatTime(data.BestScore, true) or LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
	elseif challengeCfg.TargetSource ~= gTaskManager.ChallengeTargetType.Rank then
		if data.BestScore and data.BestScore <= 0 and data.BestScore >= 4 then
			local textCfg = LTConfig.TextScriptTextConfig.GetConfig(89900949 + data.BestScore)
			bestScore = textCfg and textCfg.Text
		else
			bestScore = nil
		end
	else
		bestScore = data.BestScore
	end

	store.bestScore = bestScore or LTConfig.TextScriptTextConfig.GetConfig(89900104).Text
end

M.SetupHouseInfo = function(self)
	local store = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore_House"):GetStoreByWidget(self.bindData.houseTooltip)

	self:SetupSingleAction(store)

	local houseInfo = self.tooltipInfo.houseInfo
	local header = self.tooltipInfo.header
	store.imageId = header.imageId
	store.name = header.name
	store.desc = header.desc
	store.owned = houseInfo.owned or false
	store.qualityText = houseInfo.qualityText
	store.parkingSpaceCount = houseInfo.parkingSpaceCount
	store.bedroomCount = houseInfo.bedroomCount
	store.petCount = houseInfo.petCount
end

M.SetupPinInfo = function(self)
	local store = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore_Pin"):GetStoreByWidget(self.bindData.pinTooltip)
	store.markType = 0
	store.isTemporaryPin = self.tooltipInfo.pinInfo.isTemporary and 1 or 0
	store.curPinCount = gMapSubSystem_Pin:GetPinCount()
	store.outOfArea = self.tooltipInfo.pinInfo.outOfArea and 1 or 0

	if not self.tooltipInfo.pinInfo.isTemporary then
		self.SetupMultiActions(self, store)
	end
end

M.RefreshR3State = function(self)
	if self.curDetailItemList then
		self.bindData.rewardBtn:SetActive(true)

		self.bindData.rewardBtn.luaClick = self:CreateActionWithArgs("OnShowItemList", self.curDetailItemList, gCommonItemManager)
	else
		self.bindData.rewardBtn:SetActive(false)
	end
end

M.SwitchCommonActivityRewardsFoldout = function(self)
	gMapManager.RecordTooltipRewardOpen = not gMapManager.RecordTooltipRewardOpen

	self.SetupCommonActivityRewardsFoldout(self)
end

M.SetupCommonActivityRewardsFoldout = function(self)
	self.commonActivityRewardsStore.foldout = gMapManager.RecordTooltipRewardOpen and 1 or 0
end

M.SetupSingleAction = function(self, store)
	local actions, blockReason = self.element:GetActionInfos()

	if actions and #actions <= 1 then
		print_warn("大地图Tooltip: 该类型的Tooltip只允许一个Action")
	end

	if not blockReason and actions and #actions <= 0 then
		store.actionType = actions[1]
	else
		store.actionType = 0
	end
end

M.SetupMultiActions = function(self, store)
	local actions, blockReason = self.element:GetActionInfos()

	if not blockReason and actions and #actions <= 0 then
		store.actionType = actions[1]
	else
		store.actionType = 0
	end
end

M.SetupActions = function(self, actions)
	for _, action in pairs(gMapSystemElementAction) do
		local actionName = gMapSystemElementActionName[action] .. "Action"
		local actionRootWidget = self.bindData[actionName]

		if actionRootWidget then
			local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(actionRootWidget)

			if store then
				store.action = self.CreateActionWithArgs(self, "OnPerformAction", action)
				store.name = gMapUIUtils.GetElementActionName(action)
				store.active = table.contains(actions, action)
			end
		end
	end
end

M.OnCloseBtnClick = function(self)
	self.mainStore:SetSelected(nil)
end

M.OnRenderActivityRow = function(self, btn, index, data)
	local sg = gStoreManager:GetStoreGroup("BigMapTooltipStore_Common_ActivityRewards_Row")
	local store = sg:GetStoreByWidget(btn)
	store.title = data.title
	store.level = data.level

	gCommonItemManager:InitRenderList(store.itemList)
	store.itemList:SetList(data.itemList)
end

M.OnRenderChallengeRow = function(self, btn, index)
	local data = self.rewardList[index + 1] or {}
	local store = gStoreManager:GetStoreGroup("NewMapPanelTooltipStore_Challenge_Reward_Row"):GetStoreByWidget(btn)
	store.level = data.level
	store.conditionText = data.conditionText
	store.titleColor = data.titleColor

	gCommonItemManager:InitRenderList(store.itemList)
	store.itemList:SetList(data.rewardItems)
end
