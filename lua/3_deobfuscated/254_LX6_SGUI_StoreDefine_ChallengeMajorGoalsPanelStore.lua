local ChallengeType = LTConfig.ChallengeConfig.ChallengeTypeType
C_ChallengeMajorGoalsPanelStore = DefClass("C_ChallengeMajorGoalsPanelStore", C_ChallengeMajorGoalsPanelStore, C_StoreGroup)
GroupName2Class.ChallengeMajorGoalsPanelStore = C_ChallengeMajorGoalsPanelStore
local M = C_ChallengeMajorGoalsPanelStore

function M:ctor()
	self.msgEvents = {
		[gEventConstants.CHALLENGE_SPEED_RACE] = function (eventId, entityRankMap)
			if self.STATE_EnableOnce and self.challengeType == ChallengeType.Racing and not self.isPlayingRankSwitchAnime then
				self:RefreshRacingDisplay(entityRankMap)
			end
		end,
		[gEventConstants.CHALLENGE_SPEED_RACE_RANK_MAP_CHANGE] = self:CreateAction(self.InitRacing)
	}
end

function M:OnAwake()
	self.ANIME = {
		enemy = "S_Vx_ChallengeMajorGoalsPanel_complete"
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
	self.bindData.rankList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRankListItem)
	self.RankDownAnime = "S_challengeRankTemplate_Down"
	self.RankUpAnime = "S_challengeRankTemplate_Up"
	self.unColliderHintsTimer = nil
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	if data.taskId then
		self.taskId = tonumber(data.taskId)

		self:RefreshDisplay()
	end
end

function M:OnClose()
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
end

function M:RefreshDisplay()
	self.challengeCfg = gChallengeManager:GetChallengeConfigByTaskId(self.taskId)

	if not self.challengeCfg then
		return
	end

	self.challengeType = self.challengeCfg.ChallengeType
	self.bindData.typeCtrl = self.challengeType

	if self.challengeType == ChallengeType.Racing then
		self:InitRacing()
	end
end

function M:InitRacing()
	self.racerNameDict = {}
	self.racerIconDict = {}
	self.racer2RankSnapchat = table.clone(gCarRaceManager:GetEntityRankMap() or {})
	self.rank2RacerSnapchat = {}
	local racerCount = 0

	for id, rank in pairs(self.racer2RankSnapchat) do
		local name = gCarRaceManager:GetEntityNameById(id)
		self.racerNameDict[id] = name
		self.rank2RacerSnapchat[rank] = id
		racerCount = racerCount + 1
	end

	self.ShowRank = racerCount > 4
	self.bindData.showRankTitleCtrl = self.ShowRank and 1 or 0
	self.MaxShowRacerNum = self.ShowRank and 3 or racerCount
	self.playerRaceId = gCarRaceManager.taskID
	local playerRank = gCarRaceManager:GetPlayerRank()

	if self.ShowRank then
		self.bindData.rankCurrent = string.format("%02d", playerRank)
		self.bindData.rankTotal = "/ " .. racerCount
	end

	self.rankList = {}

	for rank, id in pairs(self.rank2RacerSnapchat) do
		if rank <= self.MaxShowRacerNum then
			table.insert(self.rankList, {
				rank = rank,
				nameText = self.racerNameDict[id],
				rankHighlightCtrl = rank == playerRank and 1 or 0
			})
		end
	end

	self.racerStoreCount = 0
	self.racerStore = {}

	self.bindData.rankList:SetSimpleList(#self.rankList)

	if self.challengeCfg.Id == 1001 then
		local unColliderTime = LTConfig.RacingDriverConfig.EnableNoHitTime

		self:SetUnColliderHintsTimer(unColliderTime)
	else
		self:SetShowUnColliderHints(false)
	end
end

function M:RefreshRacingDisplay(rankSnapchat)
	if not self.racerStoreCount == self.MaxShowRacerNum then
		return
	end

	if self.ShowRank then
		self.bindData.rankCurrent = string.format("%02d", gCarRaceManager:GetPlayerRank())
	end

	local pos = {}
	local rank2Racer = {}
	local racer2Rank = table.clone(rankSnapchat)
	local change = false

	for id, rank in pairs(rankSnapchat) do
		pos[rank] = {
			fromRacer = self.rank2RacerSnapchat[rank],
			toRacer = id,
			fromPos = rank,
			toPos = self.racer2RankSnapchat[id]
		}
		rank2Racer[rank] = id

		if pos[rank].fromPos ~= pos[rank].toPos and (pos[rank].fromPos <= self.MaxShowRacerNum or pos[rank].toPos <= self.MaxShowRacerNum) then
			change = true
		end
	end

	self.racer2RankSnapchat = racer2Rank
	self.rank2RacerSnapchat = rank2Racer

	if change then
		self.isPlayingRankSwitchAnime = true

		self:PlayRankSwitchAnime(pos, 1)
	end
end

function M:PlayRankSwitchAnime(pos, index)
	if self.MaxShowRacerNum < index then
		self.isPlayingRankSwitchAnime = false

		self:RefreshRacingDisplay(gCarRaceManager:GetEntityRankMap())

		return
	end

	local curIndex = index
	local switch = pos[curIndex]

	if switch.fromPos ~= switch.toPos then
		local downRank = curIndex
		local upRank = false
		pos[switch.toPos].fromRacer = switch.fromRacer

		for i = index + 1, self.MaxShowRacerNum do
			if pos[i].toRacer == switch.fromRacer then
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
				self.racerStore[downRank].rankHighlightCtrl = switch.toRacer == self.playerRaceId and 1 or 0
			end

			if upRank and self.racerStore[upRank] then
				gCS.LuaUtils.PlayAnimationByName(self.racerStore[upRank].anime, self.RankUpAnime, 0, true)

				self.racerStore[upRank].nameText = self.racerNameDict[switch.fromRacer]
				self.racerStore[upRank].rankHighlightCtrl = switch.fromRacer == self.playerRaceId and 1 or 0
			end
		end, 0.167):Start()

		return
	end

	curIndex = curIndex + 1

	self:PlayRankSwitchAnime(pos, curIndex)
end

function M:OnRenderRankListItem(btn, index)
	local data = self.rankList[index + 1]
	self.racerStoreCount = self.racerStoreCount + 1
	local store = self:GetStoreByWidget(btn)
	self.racerStore[index + 1] = store
	store.nameText = data.nameText
	store.rankNumText = data.rank
	store.rankHighlightCtrl = data.rankHighlightCtrl
	store.rankNumCtrl = data.rank - 1
end

function M:SetUnColliderHintsTimer(time)
	if self.unColliderHintsTimer then
		self.unColliderHintsTimer:Stop()

		self.unColliderHintsTimer = nil
	end

	if not time or time <= 0 then
		self:SetShowUnColliderHints(false)

		return
	end

	self:SetShowUnColliderHints(true)

	self.unColliderHintsTimer = Timer.New(function ()
		self.unColliderHintsTimer = nil

		self:SetShowUnColliderHints(false)
	end, time):Start()
end

function M:SetShowUnColliderHints(isShow)
	self.bindData.showHintsCtrl = isShow and 1 or 0
end
