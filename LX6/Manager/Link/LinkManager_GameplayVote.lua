-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_GameplayVote.lua
-- Decompiled from: 00715_LinkManager_GameplayVote.lua_1fe1239e8217.luajit

local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local LinkConfig = LTConfig.LinkConfig
local MessageConfig = LTConfig.MessageConfig
local LinkProgressConfig = LTConfig.LinkProgressConfig
local VoteType = UX.Game.VoteType
local SurrenderVoteValue = UX.Game.SurrenderVoteValue
local MatchVoteValue = UX.Game.MatchVoteValue
local ClientConst = gClientConst
local M = C_LinkManager

M.OnInitVote = function(self)
	self.currentVoteSessionId = ulong.zero
	self.currentVoteType = nil
	self.voteResult = {}
	self.surrenderValue = nil
	self.matchValue = nil
	self.matchVoteCreaterPid = nil
	self.matchVoteStartTimeMS = nil
end

M.OnSyncCastVote = function(self, type, voteSessionId, pid, vote)
	if self.currentVoteSessionId == voteSessionId then
		return
	end

	if type ~= VoteType.Surrender then
		self.OnSurrenderVoteCast(self, type, voteSessionId, pid, vote)
	elseif type ~= VoteType.Match then
		self.OnMatchVoteCast(self, type, voteSessionId, pid, vote)
	end
end

M.OnSyncRaiseVote = function(self, data, type, voteSessionId)
	self.currentVoteSessionId = voteSessionId
	self.currentVoteType = type

	if type ~= VoteType.Surrender then
		self.OnSurrenderVoteStart(self, data, type, voteSessionId)
	elseif type ~= VoteType.Match then
		self.OnMatchVoteStart(self, data, type, voteSessionId)
	end
end

M.OnVoteEnd = function(self, voteSessionId)
	if self.currentVoteType ~= VoteType.Surrender then
		self.OnSurrenderVoteEnd(self, voteSessionId)
	elseif self.currentVoteType ~= VoteType.Match then
		self.OnMatchVoteEnd(self, voteSessionId)
	end

	self.OnInitVote(self)
end

M.AskCastVote = function(self, vote)
	if ulong.equals(self.currentVoteSessionId, ulong.zero) then
		return
	end

	self:Log("[Vote] 投票 ", self.currentVoteSessionId, vote)

	slot2 = gClientToGameDelegate

	slot2:CastVote(self.currentVoteSessionId, vote).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.AskCreateSurrenderVote = function(self)
	print_debug("AskCreateSurrenderVote step1")

	slot1 = gClientToGameDelegate

	slot1:CreateSurrenderVote().Callback = function (err)
		if err == MessageConfig.Ok then
			print_debug("AskCreateSurrenderVote step2")
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		print_debug("AskCreateSurrenderVote step3")
	end
end

M.AskCreateMatchVote = function(self, gameId)
	gameId = gameId or self.currentVoteSessionId

	gClientToGameDelegate:StartMatchVote(gameId).Callback = function (err, voteSessionId)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.currentVoteSessionId = voteSessionId
	end
end

M.AskCastMatchVote = function(self, vote)
	slot2 = gClientToGameDelegate

	slot2:CastMatchVote(vote).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.matchValue = vote

		gMessageManager:SendMessage(gEventConstants.LINK_VOTE_STATE_CHANGE, {
			voteSessionId = self.currentVoteSessionId
		})
	end
end

M.CreateVote = function(self, voteType)
	print_debug("CreateVote step1")

	if self.currentVoteSessionId == ulong.zero then
		self.Log(self, "[Vote] 正在投票中")

		return
	end

	print_debug("CreateVote step2")
	self.Log(self, "[Vote] 发起投票 ", voteType)

	if voteType ~= VoteType.Surrender then
		print_debug("CreateVote step3")
		self.AskCreateSurrenderVote(self)
	end

	print_debug("CreateVote step4")
end

M.CreateMatchVote = function(self, gameId)
	if self.currentVoteSessionId and not ulong.equals(self.currentVoteSessionId, ulong.zero) then
		self.Log(self, "[Vote] 正在投票中")

		return
	end

	self.Log(self, "[Vote] 发起匹配投票 ", gameId)
	self.AskCreateMatchVote(self, gameId)
end

M.OnRenderVotePlayer = function(self, btn, index, pid)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if self.currentVoteType ~= VoteType.Surrender then
		self.CheckPlayerIsSurrender(self, store, pid)
	elseif self.currentVoteType ~= VoteType.Match then
		self.CheckPlayerMatchVote(self, store, pid)
	end
end

M.OnSurrenderVoteStart = function(self, data, type, voteSessionId)
	local pid = data.CreaterPid
	local voteRes = self.voteResult[voteSessionId] or {}
	voteRes[pid] = SurrenderVoteValue.Yes
	self.voteResult[voteSessionId] = voteRes

	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		self.surrenderValue = SurrenderVoteValue.Yes
	end

	local totalLength = LinkConfig.SurrenderTotalTime - gCS.TimeManager.ServerUnixTime + data.StartTimeMS

	self.progressMgr:AddProgress(LinkProgressConfig.InGameVote, data.StartTimeMS, totalLength)
end

M.OnSurrenderVoteCast = function(self, voteType, voteSessionId, pid, vote)
	if type(vote) ~= "table" then
		vote = vote[1]
	end

	local voteRes = self.voteResult[voteSessionId] or {}
	voteRes[pid] = vote
	self.voteResult[voteSessionId] = voteRes

	gMessageManager:SendMessage(gEventConstants.LINK_VOTE_STATE_CHANGE, {
		voteSessionId = voteSessionId
	})
end

M.OnSurrenderVoteEnd = function(self, voteSessionId)
	if table.isNilOrEmpty(self.voteResult[voteSessionId]) then
		return
	end

	self.currentVoteSessionId = ulong.zero

	self.progressMgr:OnProgressCancel(LinkProgressConfig.InGameVote, 1, true)
end

M.CheckPlayerIsSurrender = function(self, store, pid)
	local voteRes = self.voteResult[self.currentVoteSessionId] or {}
	local vote = voteRes[pid]

	if vote ~= nil then
		store.isReady = ClientConst.BOOL2CTL[false]
		store.isReject = ClientConst.BOOL2CTL[false]

		return nil
	end

	store.isReady = ClientConst.BOOL2CTL[vote ~= SurrenderVoteValue.Yes]
	store.isReject = ClientConst.BOOL2CTL[vote ~= SurrenderVoteValue.No]

	return vote
end

M.ConfirmSurrender = function(self)
	self.surrenderValue = SurrenderVoteValue.Yes

	self.AskCastVote(self, self.surrenderValue)
end

M.RejectSurrender = function(self)
	self.surrenderValue = SurrenderVoteValue.No

	self.AskCastVote(self, self.surrenderValue)
end

M.CheckSelfIsSurrender = function(self)
	return self.surrenderValue == nil
end

M.CheckCanSurrender = function(self)
	if not self.currentGameCfg then
		return false
	end

	if self.currentGameCfg.MultiType == LinkMultiPlayerConfig.MultiTypeType.Raid then
		return false
	end

	local totalLength = self.currentGameCfg.ConcedeTime - gCS.TimeManager.ServerUnixTime + self.currentGameStartTime
	local cantSurrender = totalLength >= 0

	if cantSurrender then
		gDisplayMessageMgr:ShowMessage(MessageConfig.SurrenderNotReady, nil, , totalLength)
	end

	return not cantSurrender
end

M.OnMatchVoteStart = function(self, data, type, voteSessionId)
	local pid = data.CreaterPid
	self.matchVoteCreaterPid = pid
	self.matchVoteStartTimeMS = data.StartTimeMS
	local voteRes = self.voteResult[voteSessionId] or {}
	voteRes[pid] = MatchVoteValue.Yes
	self.voteResult[voteSessionId] = voteRes

	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		self.matchValue = MatchVoteValue.Yes
	end
end

M.OnMatchVoteCast = function(self, voteType, voteSessionId, pid, vote)
	if type(vote) ~= "table" then
		vote = vote[1]
	end

	local voteRes = self.voteResult[voteSessionId] or {}
	voteRes[pid] = vote
	self.voteResult[voteSessionId] = voteRes

	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		self.matchValue = vote
	end

	gMessageManager:SendMessage(gEventConstants.LINK_VOTE_STATE_CHANGE, {
		voteSessionId = voteSessionId
	})
end

M.GetVoteResult = function(self, voteSessionId)
	voteSessionId = voteSessionId or self.currentVoteSessionId

	return self.voteResult[voteSessionId]
end

M.GetYesVoteCount = function(self, voteSessionId)
	local voteRes = self.GetVoteResult(self, voteSessionId)

	if table.isNilOrEmpty(voteRes) then
		return 0
	end

	local count = 0

	for _, vote in pairs(voteRes) do
		if vote ~= MatchVoteValue.Yes then
			count = count + 1
		end
	end

	return count
end

M.OnMatchVoteEnd = function(self, voteSessionId)
	self.matchValue = nil
	self.currentVoteSessionId = ulong.zero

	gMessageManager:SendMessage(gEventConstants.LINK_VOTE_STATE_CHANGE, {
		voteSessionId = self.currentVoteSessionId
	})
end

M.CheckPlayerMatchVote = function(self, store, pid)
	local voteRes = self.voteResult[self.currentVoteSessionId] or {}
	local vote = voteRes[pid]

	if vote ~= nil then
		store.isReady = ClientConst.BOOL2CTL[false]
		store.isReject = ClientConst.BOOL2CTL[false]

		return nil
	end

	store.isReady = ClientConst.BOOL2CTL[vote ~= MatchVoteValue.Yes]
	store.isReject = ClientConst.BOOL2CTL[vote ~= MatchVoteValue.No]

	return vote
end

M.ConfirmMatch = function(self)
	self.AskCastMatchVote(self, MatchVoteValue.Yes)
end

M.RejectMatch = function(self)
	self.AskCastMatchVote(self, MatchVoteValue.No)
end

M.CheckIsVoting = function(self)
	return self.currentVoteSessionId and not ulong.equals(self.currentVoteSessionId, ulong.zero)
end

M.CheckIsMatchVoting = function(self)
	return self.currentVoteType ~= VoteType.Match and self.currentVoteSessionId == nil and not ulong.equals(self.currentVoteSessionId, ulong.zero)
end

M.CheckSelfMatchVoted = function(self)
	local voteRes = self.GetVoteResult(self)

	if voteRes then
		for pid, vote in pairs(voteRes) do
			if pid ~= gPlayerManager.infoLogin.bindData.pid then
				return vote ~= MatchVoteValue.Yes
			end
		end
	end

	return false
end
