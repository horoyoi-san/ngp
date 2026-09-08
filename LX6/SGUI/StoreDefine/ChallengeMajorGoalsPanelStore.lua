-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChallengeMajorGoalsPanelStore.lua
-- Decompiled from: 01550_ChallengeMajorGoalsPanelStore.lua_9bb9ccef8694.luajit

local ChallengeType = LTConfig.ChallengeConfig.ChallengeTypeType
C_ChallengeMajorGoalsPanelStore = DefClass("C_ChallengeMajorGoalsPanelStore", C_ChallengeMajorGoalsPanelStore, C_StoreGroup)
GroupName2Class.ChallengeMajorGoalsPanelStore = C_ChallengeMajorGoalsPanelStore
local M = C_ChallengeMajorGoalsPanelStore

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.CHALLENGE_SPEED_RACE] = function (eventId, entityRankMap)
			if self.STATE_EnableOnce and self.challengeType ~= ChallengeType.Racing and not self.isPlayingRankSwitchAnime then
				self:RefreshRacingDisplay(entityRankMap)
			end
		end,
		[gEventConstants.CHALLENGE_SPEED_RACE_RANK_MAP_CHANGE] = self.CreateAction(self, self.InitRacing),
		[gEventConstants.CAR_RACE_LAP_CHANGE] = self.CreateAction(self, self.RefreshRaceRaceLap)
	}
end

M.OnAwake = function(self)
	self.ANIME = {
		["H\\xa0\\xa7\\xa2\\xaf"] = "M\\a\\x9e22jp\\x95\\x97\\xa9\\x873\\xba\\xe7$\\xbc,\\xcf'\\xa97x\\x81,\\xa2h\\x9d$֗a\\x9e\\xbd"
	}
	self.updateCount = 0
	self.paramName = {}
	self.challengeCfg = nil
	self.challengeType = -1
	self.isPlayingRankSwitchAnime = false
	self.raceSwitchAnimeTimer = nil
	self.raceSwitchRankTimer = nil
	self.MaxShowRacerNum = 0
	self.racerStoreCount = 0
	self.bindData.rankList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRankListItem)
	self.RankDownAnime = "S_challengeRankTemplate_Down"
	self.RankUpAnime = "S_challengeRankTemplate_Up"
	self.unColliderHintsTimer = nil
	self.bottomUIType = {
		["\\xe9\\xde*\\xe5"] = 2,
		["\\xa2iv"] = 1,
		["T-s^"] = 0
	}
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.isUgc = data and data.isUgc

	if self.isUgc then
		self.InitLapPanel(self, data)

		self.challengeType = ChallengeType.Racing
		self.bindData.typeCtrl = self.challengeType

		self.InitRacing(self)

		return
	end

	if data and data.taskId then
		self.taskId = tonumber(data.taskId)

		self.InitLapPanel(self, data)
		self.RefreshDisplay(self)
	end
end

M.GetRaceMgr = function(self)
	if self.isUgc then
		return L50.Spoon.UgcRaceManager.Instance
	end

	return gCarRaceManager
end

M.InitLapPanel = function(self, data)
	self.bindData.showLapTitleCtrl = data.isLap and self.bottomUIType.Lap or self.bottomUIType.None
	self.bindData.allLap = "/" .. (data.allLap or 0)
	self.bindData.curLap = data.curLap or 0
end

M.OnClose = function(self)
	self.updateCount = 0
	self.paramName = nil
	self.challengeType = -1

	if self.raceSwitchAnimeTimer then
		self.raceSwitchAnimeTimer:Stop()

		self.raceSwitchAnimeTimer = nil
	end

	if self.raceSwitchRankTimer then
		self.raceSwitchRankTimer:Stop()

		self.raceSwitchRankTimer = nil
	end

	self.playerRaceId = 0
	self.isPlayingRankSwitchAnime = false
	self.isUgc = nil
end

M.RefreshDisplay = function(self)
	self.challengeCfg = gChallengeManager:GetChallengeConfigByTaskId(self.taskId)

	if not self.challengeCfg then
		return
	end

	self.challengeType = self.challengeCfg.ChallengeType
	self.bindData.typeCtrl = self.challengeType

	if self.challengeType ~= ChallengeType.Racing then
		self.InitRacing(self)
	end
end

M.InitRacing = function(self)
	local raceMgr = self.GetRaceMgr(self)

	if not raceMgr then
		return
	end

	self.racerNameDict = {}
	self.racerIconDict = {}
	self.racer2RankSnapchat = table.clone(raceMgr:GetEntityRankMap() or {})
	self.rank2RacerSnapchat = {}
	local racerCount = 0

	for id, rank in pairs(self.racer2RankSnapchat) do
		local name = raceMgr.GetEntityNameById(raceMgr, id)
		self.racerNameDict[id] = name
		self.rank2RacerSnapchat[rank] = id
		racerCount = racerCount + 1
	end

	self.ShowRank = racerCount >= 4
	self.bindData.showRankTitleCtrl = self.ShowRank and 1 or 0
	self.MaxShowRacerNum = self.ShowRank and 3 or racerCount
	self.playerRaceId = raceMgr:GetPlayerId()
	local playerRank = raceMgr:GetPlayerRank()

	if self.ShowRank then
		self.bindData.rankCurrent = string.format("%02d", playerRank)
		self.bindData.rankTotal = "/ " .. racerCount
	end

	self.rankList = {}

	for rank, id in pairs(self.rank2RacerSnapchat) do
		if rank < self.MaxShowRacerNum then
			table.insert(self.rankList, {
				rank = rank,
				nameText = self.racerNameDict[id],
				rankHighlightCtrl = rank ~= playerRank and 1 or 0
			})
		end
	end

	self.racerStoreCount = 0
	self.racerStore = {}

	self.bindData.rankList:SetSimpleList(#self.rankList)

	if self.isUgc then
		self.SetShowUnColliderHints(self, false)
	elseif self.challengeCfg and self.challengeCfg.UrbanJobType ~= LTConfig.UrbanJobJobClassConfig.RacingDriver then
		local unColliderTime = LTConfig.RacingDriverConfig.EnableNoHitTime

		self.SetUnColliderHintsTimer(self, unColliderTime)
	else
		self.SetShowUnColliderHints(self, false)
	end
end

M.RefreshRaceRaceLap = function(self, _, lap)
	self.bindData.curLap = lap or 0
end

M.RefreshRacingDisplay = function(self, rankSnapchat)
	if self.racerStoreCount == self.MaxShowRacerNum then
		return
	end

	if type(rankSnapchat) == "table" and rankSnapchat.ToTable == nil then
		rankSnapchat = rankSnapchat.ToTable(rankSnapchat)
	end

	if self.ShowRank then
		self.bindData.rankCurrent = string.format("%02d", self:GetRaceMgr():GetPlayerRank())
	end

	local pos = {}
	local rank2Racer = {}
	local racer2Rank = table.clone(rankSnapchat)
	local change = false

	for id, rank in pairs(rankSnapchat) do
		local toPos = self.racer2RankSnapchat[id]

		if toPos ~= nil then
			rank2Racer[rank] = id
		else
			pos[rank] = {
				fromRacer = self.rank2RacerSnapchat[rank],
				toRacer = id,
				fromPos = rank,
				toPos = toPos
			}
			rank2Racer[rank] = id

			if pos[rank].fromPos == pos[rank].toPos and (pos[rank].fromPos > self.MaxShowRacerNum or pos[rank].toPos < self.MaxShowRacerNum) then
				change = true
			end
		end
	end

	self.racer2RankSnapchat = racer2Rank
	self.rank2RacerSnapchat = rank2Racer

	if change then
		self.isPlayingRankSwitchAnime = true

		self.PlayRankSwitchAnime(self, pos, 1)
	end
end

M.PlayRankSwitchAnime = function(self, pos, index)
	if self.MaxShowRacerNum >= index then
		self.isPlayingRankSwitchAnime = false

		self:RefreshRacingDisplay(self:GetRaceMgr():GetEntityRankMap())

		return
	end

	local curIndex = index
	local switch = pos[curIndex]

	if switch.fromPos == switch.toPos then
		local downRank = curIndex
		local upRank = false
		pos[switch.toPos].fromRacer = switch.fromRacer

		for i = index + 1, self.MaxShowRacerNum do
			if pos[i].toRacer ~= switch.fromRacer then
				pos[i].toPos = switch.toPos
				upRank = i
			end
		end

		if downRank and self.racerStore[downRank] then
			gCS.LuaUtils.PlayAnimationByName(self.racerStore[downRank].anime, self.RankDownAnime)
		end

		if upRank and self.racerStore[upRank] then
			gCS.LuaUtils.PlayAnimationByName(self.racerStore[upRank].anime, self.RankUpAnime)
		end

		self.raceSwitchAnimeTimer = Timer.New(function ()
			self.raceSwitchAnimeTimer = nil
			curIndex = curIndex + 1

			self:PlayRankSwitchAnime(pos, curIndex)
		end, 0.334):Start()
		self.raceSwitchRankTimer = Timer.New(function ()
			self.raceSwitchRankTimer = nil

			if downRank and self.racerStore[downRank] then
				gCS.LuaUtils.PlayAnimationByName(self.racerStore[downRank].anime, self.RankDownAnime, 0, true)

				self.racerStore[downRank].nameText = self.racerNameDict[switch.toRacer]
				self.racerStore[downRank].rankHighlightCtrl = switch.toRacer ~= self.playerRaceId and 1 or 0
			end

			if upRank and self.racerStore[upRank] then
				gCS.LuaUtils.PlayAnimationByName(self.racerStore[upRank].anime, self.RankUpAnime, 0, true)

				self.racerStore[upRank].nameText = self.racerNameDict[switch.fromRacer]
				self.racerStore[upRank].rankHighlightCtrl = switch.fromRacer ~= self.playerRaceId and 1 or 0
			end
		end, 0.167):Start()

		return
	end

	curIndex = curIndex + 1

	self.PlayRankSwitchAnime(self, pos, curIndex)
end

M.OnRenderRankListItem = function(self, btn, index)
	local data = self.rankList[index + 1]
	self.racerStoreCount = self.racerStoreCount + 1
	local store = self.GetStoreByWidget(self, btn)
	self.racerStore[index + 1] = store
	store.nameText = data.nameText
	store.rankNumText = data.rank
	store.rankHighlightCtrl = data.rankHighlightCtrl
	store.rankNumCtrl = data.rank - 1
end

M.SetUnColliderHintsTimer = function(self, time)
	if self.unColliderHintsTimer then
		self.unColliderHintsTimer:Stop()

		self.unColliderHintsTimer = nil
	end

	if not time or time < 0 then
		self.SetShowUnColliderHints(self, false)

		return
	end

	self:SetShowUnColliderHints(true)

	self.unColliderHintsTimer = Timer.New(function ()
		self.unColliderHintsTimer = nil

		self:SetShowUnColliderHints(false)
	end, time):Start()
end

M.SetShowUnColliderHints = function(self, isShow)
	self.bindData.showHintsCtrl = isShow and 1 or 0
end
