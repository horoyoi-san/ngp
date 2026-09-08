-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MaJiangManager_Rank.lua
-- Decompiled from: 00348_MaJiangManager_Rank.lua_1f20994c6329.luajit

local M = C_MaJiangManager
local MahjongConfig = LTConfig.MahjongConfig
local MahjongPveMahjongNpcTalkConfig = LTConfig.MahjongPveMahjongNpcTalkConfig
local MessageConfig = LTConfig.MessageConfig

M.CheckRedPoint = function(self)
	local mahjongInfo = self.myRankInfo

	if mahjongInfo ~= nil or mahjongInfo.MaxRank >= 2 then
		return false
	end

	local newReward = {}

	for i = 2, mahjongInfo.MaxRank do
		newReward[i] = 1
	end

	if mahjongInfo.RewardRank then
		for _, v in ipairs(mahjongInfo.RewardRank) do
			newReward[v] = 0
		end
	end

	for _, v in pairs(newReward) do
		if v ~= 1 then
			return true
		end
	end

	return false
end

M.GetRewardList = function(self)
	local rewardData = {}

	for i = 1, #MahjongConfig.MahjongDivisionReward do
		local data = {
			["^\\xba\\xa3\\xbb\\xb3"] = 1,
			score = MahjongConfig.MahjongDivisionLowerLimit[i],
			rank = i + 1,
			rankingName = MahjongConfig.MahjongRankName[i + 1],
			rankingIcon = MahjongConfig.MahjongRankIcon[i + 1],
			dropId = MahjongConfig.MahjongDivisionReward[i]
		}

		table.insert(rewardData, data)
	end

	for i = 1, self.myRankInfo.MaxRank - 1 do
		rewardData[i].state = 2
	end

	if self.myRankInfo.RewardRank then
		for _, v in ipairs(self.myRankInfo.RewardRank) do
			rewardData[v - 1].state = 0
		end
	end

	table.sort(rewardData, function (a, b)
		if a.state == b.state then
			return b.state <= a.state
		end

		return a.score <= b.score
	end)

	local rewardList = {}

	for _, v in ipairs(rewardData) do
		local rewardView = {
			score = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901067).Text, v.score),
			rank = v.rank,
			rankingName = v.rankingName,
			rewardState = v.state,
			dropId = v.dropId,
			icon = v.rankingIcon
		}

		table.insert(rewardList, rewardView)
	end

	return rewardList
end

M.AskGetMahjongRankReward = function(self, rank, callback)
	slot3 = gClientToGameDelegate

	slot3:GetMahjongRankReward(rank).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("[Majiang-Manager] GetMahjongRankReward err:", gCS.Error.GetNameById(err))
		end

		slot1 = gClientToGameDelegate

		slot1:AskMahjongInfo().Callback = function (innerErr, data)
			if innerErr == MessageConfig.Ok then
				print_error("[Majiang-Manager] AskMahjongInfo err:", gCS.Error.GetNameById(innerErr))
			end

			if callback then
				callback(data)
			end

			self.myRankInfo = data
		end
	end
end

M.RequestMahjongInfo = function(self, callback, failCallback)
	slot3 = gClientToGameDelegate

	slot3:AskMahjongInfo().Callback = function (err, data)
		if err == MessageConfig.Ok then
			print_error("[Majiang-Manager] AskMahjongInfo err:", gCS.Error.GetNameById(err))

			if failCallback then
				failCallback()
			end

			return
		end

		self.myRankInfo = data

		if callback then
			callback(data)
		end
	end
end

M.GetRankingList = function(self)
	if self.rankingList and #self.rankingList <= 0 then
		return self.rankingList
	end

	local allData = {}
	self.rankingList = {}

	for i = 0, MahjongPveMahjongNpcTalkConfig.count - 1 do
		local cfg = MahjongPveMahjongNpcTalkConfig.LoadAt(i)
		local v = {
			name = cfg.Name,
			score = cfg.Score,
			icon = cfg.SIcon
		}

		table.insert(allData, v)
	end

	table.sort(allData, function (a, b)
		return b.score <= a.score
	end)

	local len = math.min(#allData, MahjongConfig.MahjongRankMaxLen)

	for i = 1, len do
		table.insert(self.rankingList, allData[i])
	end

	return self.rankingList
end

M.GetRankingNameAndIcon = function(self, score)
	local v = score or 0
	local limit = MahjongConfig.MahjongDivisionLowerLimit
	local name = MahjongConfig.MahjongRankName
	local icon = MahjongConfig.MahjongRankIcon

	for i = 1, #limit do
		if v >= limit[i] then
			return name[i], icon[i]
		end
	end

	return name[#name], icon[#icon]
end

M.OpenRankPanel = function(self)
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_RANK_WINDOW_PANEL)
end

M.OpenRankListPanel = function(self)
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_RANKING_PANEL)
end

M.OpenRewardPanel = function(self)
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_REWARD_PANEL)
end
