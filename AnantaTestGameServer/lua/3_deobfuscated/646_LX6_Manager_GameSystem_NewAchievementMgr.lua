local MessageConfig = LTConfig.MessageConfig
local AchievementFirstCategoryConfig = LTConfig.AchievementFirstCategoryConfig
local AchievementConfig = LTConfig.AchievementConfig
local RedDotMgr = SGUI.RedDotMgr
local AchievementSecCategoryConfig = LTConfig.AchievementSecCategoryConfig
local StaticProps = {}
C_NewAchievementMgr = DefClass("C_NewAchievementMgr", C_NewAchievementMgr, nil, StaticProps)
local M = C_NewAchievementMgr

function M:ctor()
	self.isPanelOpen = false
	self.firstCategoryId2Achievement = {}
	self.secCategoryId2Achievement = {}
	self.achievements = {}

	for i = 0, AchievementConfig.count - 1 do
		local cfg = AchievementConfig.LoadAt(i)
		local secCfg = AchievementSecCategoryConfig.GetConfig(cfg.SecCategoryType)

		if secCfg then
			if not self.firstCategoryId2Achievement[secCfg.FatherId] then
				self.firstCategoryId2Achievement[secCfg.FatherId] = {}
			end

			if not self.secCategoryId2Achievement[cfg.SecCategoryType] then
				self.secCategoryId2Achievement[cfg.SecCategoryType] = {}
			end

			table.insert(self.firstCategoryId2Achievement[secCfg.FatherId], cfg.Id)
			table.insert(self.secCategoryId2Achievement[cfg.SecCategoryType], cfg.Id)
			table.insert(self.achievements, cfg.Id)
		end
	end

	self:Clear()

	self.hasRedDot = 0
end

function M:Clear()
	self.achievementData = {}
	self.achievementFinishState = {}
	self.achievementRedDotState = {}
	self.achievementRewardState = {}

	for k, v in pairs(AchievementConfig.QualityType) do
		self.achievementRewardState[v] = 0
	end
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self:CreateAction("OnAfterSwitchScene"))
end

function M:OnBeforeSwitchScene(eventId, switchType)
	return
end

function M:OnAfterSwitchScene(eventId, switchType)
	self:AskPlayerAchievementInfo()
end

function M:OnPanelOpen()
	if self.isPanelOpen then
		return
	end

	self.isPanelOpen = true

	self:AskPlayerAchievementInfo()
end

function M:OnPanelExit()
	if not self.isPanelOpen then
		return
	end

	self.isPanelOpen = false
end

function M:SyncHasNotEarnedAchievement(count)
	self.hasRedDot = count
end

function M:OnSyncNewAchievement(id, detail)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.AchievementUnlock) then
		return
	end

	self:OnAchievementFinished(id, detail)
	gMessageManager:SendMessage(gEventConstants.GAIN_ACHIEVEMENT, id)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.AchievementUnlocked, {
		Param = {
			achieveId = id
		}
	})

	local cfg = AchievementConfig.GetConfig(id)

	if cfg and cfg.TrophyGroupIndex then
		local eventName = "CustomUnlockTrophy" .. id

		UniSDKManager.PS5_UpdateTrophyProgressByEvent(eventName, id, cfg.MaxProgressBarNum)
	end
end

function M:GetAllRedCount()
	return self.hasRedDot
end

function M:GetRedCountById(tabId)
	local list = self.firstCategoryId2Achievement[tabId] or self.secCategoryId2Achievement[tabId]

	if not list then
		return self.achievementRedDotState[tabId] and 1 or 0
	end

	local count = 0

	for i = 1, #list do
		local achievementId = list[i]

		if self.achievementRedDotState[achievementId] then
			count = count + 1
		end
	end

	return count
end

function M:GetProgressById(id)
	local list = self:GetRawList(id)

	if not list then
		local cfg = AchievementConfig.GetConfig(id)

		if not cfg then
			return 0, 0
		end

		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.Achievement, id, 0)

		return progress, cfg.MaxProgressBarNum
	end

	local count = 0

	for i = 1, #list do
		local achievementId = list[i]

		if self.achievementFinishState[achievementId] then
			count = count + 1
		end
	end

	return count, #list
end

function M:CheckIsHide(achieveId)
	local cfg = AchievementConfig.GetConfig(achieveId)

	return cfg.Hide and not self.achievementFinishState[achieveId]
end

function M:GetRawList(id)
	if not id then
		return self.achievements
	end

	return self.firstCategoryId2Achievement[id] or self.secCategoryId2Achievement[id]
end

function M:GetAchievementData(id)
	return self.achievementData[id] or {
		HasEarnedRewards = false,
		AchieveTime = 0,
		Progress = 0
	}
end

function M:GetAchievementFirstCover()
	local ret = {}

	for i = 0, AchievementFirstCategoryConfig.count - 1 do
		local cfg = AchievementFirstCategoryConfig.LoadAt(i)
		local ele = {
			id = cfg.Id,
			title = cfg.FirstCategoryName,
			iconId = cfg.SAchievementListImage
		}

		table.insert(ret, ele)
	end

	return ret
end

function M:GetAchievementDetail(id)
	local cfg = AchievementFirstCategoryConfig.GetConfig(id) or AchievementSecCategoryConfig.GetConfig(id)
	local ele = {}

	if not cfg then
		cfg = AchievementConfig.GetConfig(id)

		if not cfg then
			return ele
		end

		local secCfg = AchievementSecCategoryConfig.GetConfig(cfg.SecCategoryType)
		local firstCfg = AchievementFirstCategoryConfig.GetConfig(secCfg.FatherId)
		local items = gCommonItemManager:GetItemSortedListByDropList({
			{
				count = 1,
				dropId = cfg.Drop
			}
		}, true)
		ele = {
			icon = 0,
			id = id,
			name = cfg.Name,
			desc = cfg.Description,
			quality = cfg.Quality,
			reward = items,
			parentName = firstCfg.FirstCategoryName .. "-" .. secCfg.SecCategoryName
		}

		return ele
	end

	ele = {
		quality = 0,
		parentName = "",
		desc = "",
		id = id,
		name = cfg.FirstCategoryName or cfg.SecCategoryName,
		icon = cfg.SAchievementLogo or 0,
		reward = {}
	}

	return ele
end

function M:GetRewardState()
	return self.achievementRewardState[1] + self.achievementRewardState[2] + self.achievementRewardState[3], self.achievementRewardState[1], self.achievementRewardState[2], self.achievementRewardState[3]
end

function M:GetSecTabList(firstId)
	local ret = {}

	for i = 0, AchievementSecCategoryConfig.count - 1 do
		local cfg = AchievementSecCategoryConfig.LoadAt(i)

		if cfg.FatherId == firstId then
			local ele = {
				id = cfg.Id,
				title = cfg.SecCategoryName
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

function M:GetAchievementList(id, filter)
	local list = self:GetRawList(id)

	if not list then
		return {}
	end

	local ret = {}
	local groupDict = {}

	for i = 1, #list do
		local achievementId = list[i]
		local cfg = AchievementConfig.GetConfig(achievementId)

		if cfg then
			local title = cfg.Name
			local desc = cfg.Description

			if string.is_null_or_empty(filter) or not self:CheckIsHide(achievementId) and (gUIUtils:IsMatchCondition(title, filter) or gUIUtils:IsMatchCondition(desc, filter)) then
				local groupId = cfg.SingleSelectionGroup

				if groupId ~= 0 then
					if not groupDict[groupId] or not self.achievementFinishState[groupDict[groupId]] then
						groupDict[groupId] = achievementId
					end
				else
					table.insert(ret, achievementId)
				end
			end
		end
	end

	for k, v in pairs(groupDict) do
		table.insert(ret, v)
	end

	return self:_SortRet(ret)
end

function M:getPriority(id)
	if self.cachePriority[id] then
		return self.cachePriority[id]
	end

	local priority = 0
	local data = self:GetAchievementData(id)
	local cfg = AchievementConfig.GetConfig(id)

	if data.AchieveTime > 0 and not data.HasEarnedRewards then
		priority = 1
	elseif cfg.Hide and data.AchieveTime == 0 then
		priority = 3
	elseif data.AchieveTime == 0 then
		priority = 2
	else
		priority = 4
	end

	return priority
end

function M:_SortRet(ret)
	self.cachePriority = {}

	table.sort(ret, function (a, b)
		local aPriority = self:getPriority(a)
		local bPriority = self:getPriority(b)

		if aPriority ~= bPriority then
			return aPriority < bPriority
		end

		return a < b
	end)

	return ret
end

function M:AskReceiveReward(achievementId, callback)
	gClientToGameDelegate:AskGetAchievementReward(achievementId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:SetRedDotState(achievementId, false)

		self.achievementData[achievementId].HasEarnedRewards = true

		if callback then
			callback()
		end

		gMessageManager:SendMessage(gEventConstants.GAIN_ACHIEVEMENT)
	end
end

function M:AskReceiveAllReward(callback)
	gClientToGameDelegate:AskGetAllAchievementReward().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.hasRedDot = 0
		self.achievementRedDotState = {}

		for k, v in pairs(self.achievementData) do
			self.achievementData[k].HasEarnedRewards = true

			self:SetRedDotState(k, false)
		end

		if callback then
			callback()
		end
	end
end

function M:AskPlayerAchievementInfo(callback)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	gClientToGameDelegate:AskPlayerAchievements().Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:Clear()

		for k, v in pairs(data.Achievements) do
			self:OnAchievementFinished(k, v)
		end

		if callback then
			callback(data)
		end
	end
end

function M:OnAchievementFinished(id, info)
	local cfg = AchievementConfig.GetConfig(id)

	if cfg then
		local isFinished = info.AchieveTime > 0
		self.achievementData[id] = info
		self.achievementFinishState[id] = isFinished

		self:SetRedDotState(id, isFinished and not info.HasEarnedRewards)

		self.achievementRewardState[cfg.Quality] = isFinished and self.achievementRewardState[cfg.Quality] + 1 or self.achievementRewardState[cfg.Quality]
	end
end

function M:SetRedDotState(id, state)
	self.achievementRedDotState[id] = state

	RedDotMgr.LuaSetRedDot(state, self:GetRedDot(id))
end

function M:GetRedDot(achievementId)
	local cfg = AchievementConfig.GetConfig(achievementId)

	if not cfg then
		return nil
	end

	return ("Achievement/Achievement.Tab:%d/Achievement.SecTab:%d/Achievement:%d"):format(cfg.FirstCategoryType, cfg.SecCategoryType, achievementId)
end

gNewAchievementMgr = gNewAchievementMgr or C_NewAchievementMgr.new()
