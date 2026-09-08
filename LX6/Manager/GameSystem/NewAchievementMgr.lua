-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\NewAchievementMgr.lua
-- Decompiled from: 02223_NewAchievementMgr.lua_634c9ff943fe.luajit

local MessageConfig = LTConfig.MessageConfig
local AchievementFirstCategoryConfig = LTConfig.AchievementFirstCategoryConfig
local AchievementConfig = LTConfig.AchievementConfig
local RedDotMgr = SGUI.RedDotMgr
local AchievementSecCategoryConfig = LTConfig.AchievementSecCategoryConfig
local AchievementStatus = UX.Game.AchievementStatus
local StaticProps = {}
C_NewAchievementMgr = DefClass("C_NewAchievementMgr", C_NewAchievementMgr, nil, StaticProps)
local M = C_NewAchievementMgr

M.ctor = function(self)
	self.isPanelOpen = false
	self.firstCategoryId2Achievement = {}
	self.secCategoryId2Achievement = {}
	self.achievements = {}
	self.rpcQueue = {}
	self.lastSendRpcTime = 0

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

	self.hasRedDot = 0

	self:Clear()

	local achievementInfos = gPlayerManager.infoAchievement.bindData.AchievementInfos or {}

	for k, v in pairs(achievementInfos) do
		self:OnAchievementFinished(k, v)
	end
end

M.Clear = function(self)
	self.achievementData = {}
	self.achievementFinishState = {}
	self.achievementRedDotState = {}
	self.achievementRewardState = {}

	for k, v in pairs(AchievementConfig.QualityType) do
		self.achievementRewardState[v] = 0
	end
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self:CreateAction("OnAfterSwitchScene"))
end

M.OnUpdate = function(self)
	local nowTime = gCS.TimeManager.ServerUnixTime

	if not table.isNilOrEmpty(self.rpcQueue) and nowTime - self.lastSendRpcTime <= 0.5 then
		local lastIdx = #self.rpcQueue
		local callback = self.rpcQueue[lastIdx]

		if callback then
			callback()
		end

		self.rpcQueue[lastIdx] = nil
	end

	self:RefreshUpdateState()
end

M.RefreshUpdateState = function(self)
	if table.isNilOrEmpty(self.rpcQueue) then
		gLuaClient:UnregisterDynamicUpdate("gNewAchievementMgr")
	else
		gLuaClient:RegisterDynamicUpdate("gNewAchievementMgr", self)
	end
end

M.OnBeforeSwitchScene = function(self, eventId, switchType)
end

M.OnAfterSwitchScene = function(self, eventId, switchSceneEventParams)
	self:Clear()

	local achievementInfos = gPlayerManager.infoAchievement.bindData.AchievementInfos or {}

	for k, v in pairs(achievementInfos) do
		self:OnAchievementFinished(k, v)
	end
end

M.OnPanelOpen = function(self)
	if self.isPanelOpen then
		return
	end

	self.isPanelOpen = true

	self:Clear()

	local achievementInfos = gPlayerManager.infoAchievement.bindData.AchievementInfos or {}

	for k, v in pairs(achievementInfos) do
		self:OnAchievementFinished(k, v)
	end
end

M.OnPanelExit = function(self)
	if not self.isPanelOpen then
		return
	end

	self.isPanelOpen = false
end

M.SyncHasNotEarnedAchievement = function(self, count)
	self.hasRedDot = count
end

M.OnSyncNewAchievement = function(self, id, detail)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.AchievementUnlock) then
		return
	end

	local achievementInfos = gPlayerManager.infoAchievement.bindData.AchievementInfos

	if not achievementInfos then
		achievementInfos = {}
		gPlayerManager.infoAchievement.bindData.AchievementInfos = achievementInfos
	end

	achievementInfos[id] = detail

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

		LX6.Utils.PS5Utils.UpdateTrophyProgressByEvent(eventName, id, cfg.MaxProgressBarNum)
	end
end

M.GetAllRedCount = function(self)
	return self.hasRedDot
end

M.GetRedCountById = function(self, tabId)
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

M.GetProgressById = function(self, id)
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

M.CheckIsHide = function(self, achieveId)
	local cfg = AchievementConfig.GetConfig(achieveId)

	return cfg.Hide and not self.achievementFinishState[achieveId]
end

M.GetRawList = function(self, id)
	if not id then
		return self.achievements
	end

	return self.firstCategoryId2Achievement[id] or self.secCategoryId2Achievement[id]
end

M.GetAchievementData = function(self, id)
	return self.achievementData[id] or {
		["\\xbe7(6}\\x8bD\\xed>\\xa7\\xbc"] = 0,
		["\\x9b\\xa3\n\\xacx;\\xed "] = 0,
		Status = AchievementStatus.None
	}
end

M.GetAchievementFirstCover = function(self)
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

M.GetAchievementDetail = function(self, id)
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
				["N\\xa1\\xb7\\xa1\\xa2"] = 1,
				dropId = cfg.Drop
			}
		}, true)
		ele = {
			["s!rU"] = 0,
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
		["\\xc8\\xce0\\xe8"] = 0,
		["C[ܸ\\x8a\\x96\\xc4\\xed"] = "",
		["~'nX"] = "",
		id = id,
		name = cfg.FirstCategoryName or cfg.SecCategoryName,
		icon = cfg.SAchievementLogo or 0,
		reward = {}
	}

	return ele
end

M.GetRewardState = function(self)
	return self.achievementRewardState[1] + self.achievementRewardState[2] + self.achievementRewardState[3], self.achievementRewardState[1], self.achievementRewardState[2], self.achievementRewardState[3]
end

M.GetSecTabList = function(self, firstId)
	local ret = {}

	for i = 0, AchievementSecCategoryConfig.count - 1 do
		local cfg = AchievementSecCategoryConfig.LoadAt(i)

		if cfg.FatherId ~= firstId then
			local ele = {
				id = cfg.Id,
				title = cfg.SecCategoryName
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

M.GetAchievementList = function(self, id, filter)
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

				if groupId == 0 then
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

M.getPriority = function(self, id)
	if self.cachePriority[id] then
		return self.cachePriority[id]
	end

	local priority = 0
	local data = self:GetAchievementData(id)
	local cfg = AchievementConfig.GetConfig(id)

	if data.AchieveTime <= 0 and bit.band(data.Status, AchievementStatus.Rewarded) ~= 0 then
		priority = 1
	elseif cfg.Hide and data.AchieveTime ~= 0 then
		priority = 3
	elseif data.AchieveTime ~= 0 then
		priority = 2
	else
		priority = 4
	end

	return priority
end

M._SortRet = function(self, ret)
	self.cachePriority = {}

	table.sort(ret, function (a, b)
		local aPriority = self:getPriority(a)
		local bPriority = self:getPriority(b)

		if aPriority == bPriority then
			return aPriority <= bPriority
		end

		return a <= b
	end)

	return ret
end

M.AskReceiveReward = function(self, achievementId, callback)
	table.insert(self.rpcQueue, function ()
		gClientToGameDelegate:AskGetAchievementReward(achievementId).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			self:SetRedDotState(achievementId, false)

			local achievement = self.achievementData[achievementId]
			achievement.Status = bit.bor(achievement.Status, AchievementStatus.Rewarded)

			if callback then
				callback()
			end

			self:CalcuateHasRedDotNum()
			gMessageManager:SendMessage(gEventConstants.GAIN_ACHIEVEMENT)
		end
	end)
	self:RefreshUpdateState()
end

M.AskReceiveAllReward = function(self, callback)
	gClientToGameDelegate:AskGetAllAchievementReward().Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.hasRedDot = 0
		self.achievementRedDotState = {}

		for k, v in pairs(self.achievementData) do
			v.Status = bit.bor(v.Status, AchievementStatus.Rewarded)

			self:SetRedDotState(k, false)
		end

		if callback then
			callback()
		end
	end
end

M.CalcuateHasRedDotNum = function(self)
	self.hasRedDot = 0

	for k, v in pairs(self.achievementData) do
		if bit.band(v.Status, AchievementStatus.Completed) == 0 and bit.band(v.Status, AchievementStatus.Rewarded) ~= 0 then
			self.hasRedDot = self.hasRedDot + 1
		end
	end
end

M.OnAchievementFinished = function(self, id, info)
	local cfg = AchievementConfig.GetConfig(id)

	if cfg then
		local isFinished = info.AchieveTime >= 0
		self.achievementData[id] = info
		self.achievementFinishState[id] = isFinished
		local hasRedDot = isFinished and bit.band(info.Status, AchievementStatus.Rewarded) ~= 0

		self:SetRedDotState(id, hasRedDot)

		self.achievementRewardState[cfg.Quality] = isFinished and self.achievementRewardState[cfg.Quality] + 1 or self.achievementRewardState[cfg.Quality]
	end

	self:CalcuateHasRedDotNum()
end

M.SetRedDotState = function(self, id, state)
	self.achievementRedDotState[id] = state

	RedDotMgr.LuaSetRedDot(state, self:GetRedDot(id))
end

M.GetRedDot = function(self, achievementId)
	local cfg = AchievementConfig.GetConfig(achievementId)

	if not cfg then
		return nil
	end

	return ("Achievement/Achievement.Tab:%d/Achievement.SecTab:%d/Achievement:%d"):format(cfg.FirstCategoryType, cfg.SecCategoryType, achievementId)
end

gNewAchievementMgr = gNewAchievementMgr or C_NewAchievementMgr.new()
