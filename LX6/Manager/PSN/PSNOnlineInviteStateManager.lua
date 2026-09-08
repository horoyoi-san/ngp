-- Original chunk: @Lua\LuaFiles\LX6\Manager\PSN\PSNOnlineInviteStateManager.lua
-- Decompiled from: 00262_PSNOnlineInviteStateManager.lua_098b9fa7ec2e.luajit

C_PSNOnlineInviteStateManager = DefClass("C_PSNOnlineInviteStateManager", C_PSNOnlineInviteStateManager)
local M = C_PSNOnlineInviteStateManager
local MessageConfig = LTConfig.MessageConfig

M.ctor = function(self)
	self.K_INVITE_TYPE = {
		["}\\x8f\\x90\\x9b\\x8f"] = 4,
		["\\x8c\\x90(\\x8eZ\\xdf\n"] = 3,
		["VSp"] = 1,
		["N\\v"] = 2
	}
	self._sessionCreated = false
	self._isCreatingSession = false
	self._isLeavingSession = false
	self._createSessionCallbacks = {}
	self._leaveAfterCreate = false
	self._rev = 1
	self._lastWritePayload = nil
	self._pendingPayload = nil
	self._isWriting = false
	self._premiumActive = false
	self._premiumState = {
		["++3\\xca|\\x96\\xc7'\\xa6\\xea\\xf3\\xffq\\xe9"] = false,
		["\\x96'/}\\x9eU\\xd8#\\xa5\\xab"] = false,
		["\\xe6^ :\\xdc\\xafD\\xb3x\\xa5\\xbb"] = 0
	}
	self._queriedPlayers = {}
	self._carrierStateCache = {
		["ey\\xa5yh\\xbb\\xe1Fhv{H"] = false,
		["m\\x93\\x9e\\xbe޼\\xc0\\xba:\\x86&"] = 3,
		["}\\xf21\\xe5=6-\\xcfd\\xc6N\\x9e8[\\xd6\\xe3"] = 2
	}
end

M.OnInit = function(self)
	if not gCS.LuaUtils.IsOnPS5 then
		return
	end

	gMessageManager:AddMessageListener(gEventConstants.LINK_MODE_CHANGE, self:CreateAction("OnLinkModeChange"))
	gMessageManager:AddMessageListener(gEventConstants.TEAM_JOIN, self:CreateAction("OnTeamJoin"))
	gMessageManager:AddMessageListener(gEventConstants.TEAM_LEAVE, self:CreateAction("OnTeamLeave"))
	gMessageManager:AddMessageListener(gEventConstants.TEAM_MEMBER_CHANGED, self:CreateAction("OnTeamMemberChanged"))
	gMessageManager:AddMessageListener(gEventConstants.TEAM_REFRESH_DATA, self:CreateAction("OnGameStateChanged"))
	gMessageManager:AddMessageListener(gEventConstants.ON_LINK_SYNC_STAGE_CHANGE_PREPARE, self:CreateAction("OnEnterGameplay"))
	gMessageManager:AddMessageListener(gEventConstants.ON_CUSTOM_ROOM_INFO_CHANGE, self:CreateAction("OnPartyRoomChange"))
	gMessageManager:AddMessageListener(gEventConstants.ON_CUSTOM_ROOM_DESTROY, self:CreateAction("OnPartyRoomDestroy"))
	gMessageManager:AddMessageListener(gEventConstants.ON_CUSTOM_ROOM_SETTING_CHANGE, self:CreateAction("OnGameStateChanged"))
	gMessageManager:AddMessageListener(gEventConstants.ON_CUSTOM_ROOM_OWNER_CHANGE, self:CreateAction("OnGameStateChanged"))
	gMessageManager:AddMessageListener(gEventConstants.LINK_MEMBER_CHANGE, self:CreateAction("OnMemberChange"))
	gMessageManager:AddMessageListener(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE, self:CreateAction("OnMemberChange"))
	gMessageManager:AddMessageListener(gEventConstants.ON_CUSTOM_ROOM_MEMBER_CHANGE, self:CreateAction("OnMemberChange"))
	gMessageManager:AddMessageListener(gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE, self:CreateAction("OnWatchStateChange"))
	gMessageManager:AddMessageListener(gEventConstants.LOAD_SCENE_COMPLETED, self:CreateAction("ResyncAll"))
	gMessageManager:AddMessageListener(gEventConstants.ON_LINK_TAG_CHANGE, self:CreateAction("OnLinkTagChange"))
	gMessageManager:AddMessageListener(gEventConstants.ON_CONSOLE_MULTIPLAYER_SESSION_UPDATED, self:CreateAction("OnCarrierSessionUpdated"))
end

M.OnLinkModeChange = function(self)
	local linkMode = gLinkManager.LinkMode

	self:SyncFromGameState()

	if linkMode == UX.Game.LinkMode.None then
		self:_onEnterOnline()
	else
		self:_onExitOnline()
	end

	self:_applyCarrierSessionState()
end

M.OnTeamJoin = function(self)
	self:SyncFromGameState()
	self:_onEnterOnline()
	self:_applyCarrierSessionState()
end

M.OnTeamLeave = function(self)
	self:SyncFromGameState()
	self:_onExitOnline()
	self:_applyCarrierSessionState()
end

M.OnTeamMemberChanged = function(self)
	self:SyncFromGameState()
	self:_syncPlayerNum()
	self:_syncNonPsnPlayer()
	self:_applyCarrierSessionState()
end

M.OnEnterGameplay = function(self)
	self:SyncFromGameState()
	self:_onEnterOnline()
	self:_applyCarrierSessionState()
end

M.OnPartyRoomChange = function(self, _, info)
	self:SyncFromGameState()

	if info then
		self:_onEnterOnline()
	else
		self:_onExitOnline()
	end

	self:_applyCarrierSessionState()
end

M.OnPartyRoomDestroy = function(self)
	self:SyncFromGameState()
	self:_onExitOnline()
	self:_applyCarrierSessionState()
end

M.OnGameStateChanged = function(self)
	self:SyncFromGameState()
	self:_syncPlayerNum()
	self:_syncNonPsnPlayer()
	self:_applyCarrierSessionState()
end

M.OnMemberChange = function(self)
	self:_syncPlayerNum()
	self:_syncNonPsnPlayer()
	self:_applyCarrierSessionState()
end

M.OnWatchStateChange = function(self)
	self:_syncSpectator()
end

M.ResyncAll = function(self)
	self:SyncFromGameState()
	self:_syncPlayerNum()
	self:_syncSpectator()
	self:_syncNonPsnPlayer()
	self:_applyCarrierSessionState()

	if not self:IsInAnyOnlineState() then
		print_notice("[PSNState] ResyncAll exitOnline detected")
		self:_onExitOnline()
	end
end

M.SyncFromGameState = function(self)
	local newPayload = self:_computeCurrentPayload()

	if self:_isSameAsLastWrite(newPayload) then
		return
	end

	print_notice(string.format("[PSNState] SyncFromGameState payloadChanged k=%s isWriting=%s", tostring(newPayload and newPayload.k or "nil"), tostring(self._isWriting)))

	self._pendingPayload = newPayload

	if self._isWriting then
		return
	end

	self:_doWriteCustomData()
end

M._computeCurrentPayload = function(self)
	local payload = self:BuildPayload_Party()

	if payload then
		return payload
	end

	payload = self:BuildPayload_Gameplay()

	if payload then
		return payload
	end

	payload = self:BuildPayload_Team()

	if payload then
		return payload
	end

	payload = self:BuildPayload_Link()

	if payload then
		return payload
	end

	return nil
end

local _shallowEqual = function(a, b)
	if a ~= b then
		return true
	end

	if a ~= nil or b ~= nil then
		return false
	end

	for k, v in pairs(a) do
		if b[k] == v then
			return false
		end
	end

	for k, _ in pairs(b) do
		if a[k] ~= nil then
			return false
		end
	end

	return true
end

M._isSameAsLastWrite = function(self, newPayload)
	if newPayload ~= nil and self._lastWritePayload ~= nil then
		return true
	end

	if newPayload ~= nil or self._lastWritePayload ~= nil then
		return false
	end

	if newPayload.k == self._lastWritePayload.k then
		return false
	end

	return _shallowEqual(newPayload.a, self._lastWritePayload.a)
end

M._doWriteCustomData = function(self)
	self._isWriting = true
	local payload = self._pendingPayload
	self._pendingPayload = nil

	gPSNOnlineInviteManager:ClearPendingInvite()

	local data = nil

	if payload then
		data = self:_encodePayload(payload)

		if not data then
			self._pendingPayload = payload
			self._isWriting = false

			return
		end
	end

	print_notice(string.format("[PSNState] _doWriteCustomData k=%s hasSession=%s needCreate=%s", tostring(payload and payload.k or "nil"), tostring(self._sessionCreated), tostring(data and not self._sessionCreated)))

	if data and not self._sessionCreated then
		self:_createCarrierSession(function (success)
			if not success then
				self._pendingPayload = payload
				self._isWriting = false

				return
			end

			LX6.Utils.PS5Utils.MultiplayerSession.CustomData = data
			self._lastWritePayload = payload
			self._isWriting = false

			if self._pendingPayload then
				self:_doWriteCustomData()
			end
		end)

		return
	end

	if self._sessionCreated then
		LX6.Utils.PS5Utils.MultiplayerSession.CustomData = data
	end

	self._lastWritePayload = payload
	self._isWriting = false

	if self._pendingPayload then
		self:_doWriteCustomData()
	end
end

M.LeaveSessionIfNeeded = function(self)
	if self._isCreatingSession then
		print_notice("[PSNState] LeaveSessionIfNeeded deferred: creating in progress")

		self._leaveAfterCreate = true

		return
	end

	if not self._sessionCreated or self._isLeavingSession then
		return
	end

	print_notice("[PSNState] LeaveSessionIfNeeded leaving")

	self._isLeavingSession = true

	LX6.Utils.PS5Utils.MultiplayerSession:LeaveSession(function (result)
		self._isLeavingSession = false

		if result == 0 then
			print_error("[PSNOnlineInviteStateManager] Leave carrier session failed, result=", result)

			return
		end

		self._sessionCreated = false
		self._lastWritePayload = nil
		self._pendingPayload = nil

		self:_resetCarrierStateCache()

		if self:IsInAnyOnlineState() then
			self:SyncFromGameState()
			self:_onEnterOnline()
		end
	end)
end

M.EnsureSession = function(self, callback)
	if self._sessionCreated then
		if callback then
			callback(true)
		end

		return
	end

	self:_createCarrierSession(callback)
end

M.HasCarrierSession = function(self)
	return self._sessionCreated and not self._isLeavingSession
end

M._createCarrierSession = function(self, callback)
	if self._sessionCreated then
		if callback then
			callback(true)
		end

		return
	end

	if callback then
		table.insert(self._createSessionCallbacks, callback)
	end

	if self._isCreatingSession then
		return
	end

	self._isCreatingSession = true

	print_notice(string.format("[PSNState] _createCarrierSession starting callbacks=%s", tostring(#self._createSessionCallbacks)))
	LX6.Utils.PS5Utils.MultiplayerSession:CreateSession(function (result)
		self._isCreatingSession = false

		if result == 0 then
			print_error("[PSNOnlineInviteStateManager] Create carrier session failed, result=", result)

			local callbacks = self._createSessionCallbacks
			self._createSessionCallbacks = {}

			for _, onCreated in ipairs(callbacks) do
				onCreated(false)
			end

			return
		end

		print_notice("[PSNState] _createCarrierSession success")

		self._sessionCreated = true
		local callbacks = self._createSessionCallbacks
		self._createSessionCallbacks = {}

		for _, onCreated in ipairs(callbacks) do
			onCreated(true)
		end

		if self._leaveAfterCreate or not self:IsInAnyOnlineState() then
			self._leaveAfterCreate = false

			self:LeaveSessionIfNeeded()

			return
		end

		self:_resetCarrierStateCache()
		self:_applyCarrierSessionState()
	end)
end

M._encodePayload = function(self, payload)
	local pid = ulong.tostring(gPlayerManager.infoLogin.bindData.pid)
	payload.v = 1
	payload.from = pid
	payload.rev = self._rev
	payload.ts = gCS.TimeManager.ServerUnixTime
	local json = require("cjson/json")
	local ok, str = pcall(json.encode, payload)

	if not ok then
		print_error("[PSNOnlineInviteStateManager] json.encode failed", str)

		return nil
	end

	self._rev = self._rev + 1

	return str
end

M._resetCarrierStateCache = function(self)
	self._carrierStateCache = {
		["ey\\xa5yh\\xbb\\xe1Fhv{H"] = false,
		["m\\x93\\x9e\\xbe޼\\xc0\\xba:\\x86&"] = 3,
		["}\\xf21\\xe5=6-\\xcfd\\xc6N\\x9e8[\\xd6\\xe3"] = 2
	}
end

M.BuildPayload_Link = function(self)
	local mode = gLinkManager.LinkMode

	if mode ~= UX.Game.LinkMode.None then
		return nil
	end

	if mode ~= UX.Game.LinkMode.Custom and not self:IsCustomLinkInvitable() then
		return nil
	end

	return {
		k = self.K_INVITE_TYPE.LINK,
		a = {
			mode = mode
		}
	}
end

M.BuildPayload_Team = function(self)
	if not gTeamManager:IsInTeam() then
		return nil
	end

	return {
		k = self.K_INVITE_TYPE.TEAM,
		a = {
			team = ulong.tostring(gTeamManager.teamId)
		}
	}
end

M.BuildPayload_Gameplay = function(self)
	local linkGame = gLinkManager:GetCurrentLinkGame()

	if not linkGame or not linkGame.uxData then
		return nil
	end

	if not self:CanInviteToCurrentGameplay() then
		return nil
	end

	return {
		k = self.K_INVITE_TYPE.GAMEPLAY,
		a = {
			game = linkGame.uxData.GameId,
			room = ulong.tostring(linkGame.uxData.Id)
		}
	}
end

M.BuildPayload_Party = function(self)
	local roomInfo = gCustomRoomMgr.roomInfo

	if not roomInfo or not roomInfo.PartyInfo then
		return nil
	end

	local a = {
		party = roomInfo.PartyInfo.PartyConfigId,
		room = ulong.tostring(roomInfo.Id),
		hasPwd = roomInfo.HasPassword or false
	}

	return {
		k = self.K_INVITE_TYPE.PARTY,
		a = a
	}
end

M.IsCustomLinkInvitable = function(self)
	local tag = gMapSystem:GetCurLinkTag()

	return tag ~= UX.Game.LinkTag.Visit or tag ~= UX.Game.LinkTag.CollectionRoom
end

M.CanInviteToCurrentGameplay = function(self)
	local linkGame = gLinkManager:GetCurrentLinkGame()

	if not linkGame or not linkGame.uxData then
		return false
	end

	local setting = linkGame.uxData.Setting

	if setting and not setting.AllowNonLeaderInvite and not linkGame:IsLeader(gPlayerManager.infoLogin.bindData.pid) then
		return false
	end

	return true
end

M.IsInAnyOnlineState = function(self)
	return gLinkManager.LinkMode == UX.Game.LinkMode.None or gTeamManager:IsInTeam() or gLinkManager:GetCurrentLinkGame() == nil or gCustomRoomMgr:IsInRoom()
end

local JOINABLE = {
	["\\xff\\xc9 \\xe2"] = 1,
	["=F\\x88\\x81\\x8dD"] = 3,
	["c\\xa1\\x8d\\xa1\\xb3"] = 0,
	["A\\x93\\x95\\xb1أ\\xea=\\x8f-\\xb72"] = 2
}
local INVITABLE = {
	["_Ϲ\\x81\\x97\n\\xc5\\xf1"] = 1,
	["c\\xa1\\x8d\\xa1\\xb3"] = 0,
	["1M\\x9c\\x8c\\x86S"] = 2
}

M.SyncFromGameInviteState = function(self, state)
	if not state then
		return
	end

	if not self._sessionCreated then
		return
	end

	local joinDisabled, joinableUserType, invitableUserType = nil

	if state.isRoomFull then
		joinDisabled = true
		joinableUserType = JOINABLE.NoOne
		invitableUserType = INVITABLE.NoOne
	else
		joinDisabled = not state.canJoin
		joinableUserType = JOINABLE[state.joinScope] or JOINABLE.NoOne
		invitableUserType = state.canInvite and INVITABLE.LeaderOnly or INVITABLE.NoOne
	end

	local cached = self._carrierStateCache

	if joinDisabled ~= cached.joinDisabled and joinableUserType ~= cached.joinableUserType and invitableUserType ~= cached.invitableUserType then
		return
	end

	local session = LX6.Utils.PS5Utils.MultiplayerSession
	session.JoinDisabled = joinDisabled
	session.JoinableUserType = joinableUserType
	session.InvitableUserType = invitableUserType

	print_notice(string.format("[PSNState] SyncFromGameInviteState joinDisabled=%s joinable=%s invitable=%s", tostring(joinDisabled), tostring(joinableUserType), tostring(invitableUserType)))

	cached.joinDisabled = joinDisabled
	cached.joinableUserType = joinableUserType
	cached.invitableUserType = invitableUserType
end

M._applyCarrierSessionState = function(self)
	if not self._sessionCreated then
		return
	end

	local roomInfo = gCustomRoomMgr.roomInfo

	if roomInfo then
		local memberCount = roomInfo.Members and #roomInfo.Members or 0
		local partyInfo = roomInfo.PartyInfo
		local partyCfg = partyInfo and LTConfig.PartyConfig.GetConfig(partyInfo.PartyConfigId)
		local maxMembers = roomInfo.MaxMembers or partyCfg and partyCfg.MaxNum or 0
		local isRoomFull = maxMembers <= 0 and maxMembers > memberCount

		print_notice(string.format("[PSNState] _applyCarrierSessionState Party canJoin=%s canInvite=%s isRoomFull=%s members=%s/%s", tostring(not isRoomFull), tostring(gCustomRoomMgr:IsOwner()), tostring(isRoomFull), tostring(memberCount), tostring(maxMembers)))
		self:SyncFromGameInviteState({
			["IHeg}="] = "=F\\x88\\x81\\x8dD",
			canJoin = not isRoomFull,
			canInvite = gCustomRoomMgr:IsOwner(),
			isRoomFull = isRoomFull
		})

		return
	end

	local linkGame = gLinkManager:GetCurrentLinkGame()

	if linkGame then
		local members = linkGame:GetMembers()
		local memberCount = members and #members or 0
		local cfg = linkGame:GetConfig()
		local maxPlayers = cfg and cfg.PlayerNum and cfg.PlayerNum[2] or 0
		local isRoomFull = maxPlayers <= 0 and maxPlayers > memberCount

		print_notice(string.format("[PSNState] _applyCarrierSessionState Gameplay canJoin=%s canInvite=%s isRoomFull=%s members=%s/%s", tostring(not isRoomFull), tostring(self:CanInviteToCurrentGameplay()), tostring(isRoomFull), tostring(memberCount), tostring(maxPlayers)))
		self:SyncFromGameInviteState({
			["IHeg}="] = "=F\\x88\\x81\\x8dD",
			canJoin = not isRoomFull,
			canInvite = self:CanInviteToCurrentGameplay(),
			isRoomFull = isRoomFull
		})

		return
	end

	if gTeamManager:IsInTeam() then
		local memberCount = gTeamManager:GetTeamNumber()
		local maxPlayers = LTConfig.LinkConfig.Team_MaxPlayerNum or 4
		local isRoomFull = memberCount < maxPlayers

		print_notice(string.format("[PSNState] _applyCarrierSessionState Team canJoin=%s canInvite=%s isRoomFull=%s members=%s/%s", tostring(not isRoomFull), tostring(gTeamManager.allowMemberInvite or gTeamManager:IsTeamLeader()), tostring(isRoomFull), tostring(memberCount), tostring(maxPlayers)))
		self:SyncFromGameInviteState({
			["IHeg}="] = "=F\\x88\\x81\\x8dD",
			canJoin = not isRoomFull,
			canInvite = gTeamManager.allowMemberInvite or gTeamManager:IsTeamLeader(),
			isRoomFull = isRoomFull
		})

		return
	end

	local linkMode = gLinkManager.LinkMode

	if linkMode == UX.Game.LinkMode.None then
		local memberCount = gLinkManager:GetCurrentLinkPlayerNumber()
		local maxPlayers = nil

		if linkMode == UX.Game.LinkMode.Custom then
			maxPlayers = gLinkManager:GetMaxPlayerNum(linkMode)
		end

		local isRoomFull = maxPlayers and maxPlayers > memberCount or false

		print_notice(string.format("[PSNState] _applyCarrierSessionState Link canJoin=%s canInvite=true isRoomFull=%s members=%s", tostring(not isRoomFull), tostring(isRoomFull), tostring(memberCount)))
		self:SyncFromGameInviteState({
			["IHeg}="] = "=F\\x88\\x81\\x8dD",
			["@Fb@@="] = true,
			canJoin = not isRoomFull,
			isRoomFull = isRoomFull
		})

		return
	end
end

M.OnLinkTagChange = function(self, _, linkTag)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Custom then
		self:SyncFromGameState()
	end
end

M.OnCarrierSessionUpdated = function(self, _, notificationType)
	print_notice(string.format("[PSNState] OnCarrierSessionUpdated type=%s", tostring(notificationType)))

	if notificationType == 1 then
		return
	end

	self._sessionCreated = false
	self._lastWritePayload = nil

	self:_resetCarrierStateCache()

	if self:IsInAnyOnlineState() then
		print_notice("[PSNState] OnCarrierSessionUpdated rebooting carrier session + Premium")

		self._lastWritePayload = nil

		self:SyncFromGameState()

		if self._premiumActive then
			self._premiumActive = false

			self:_onEnterOnline()
		end
	end
end

M._onEnterOnline = function(self)
	if self._premiumActive then
		self:_syncPlayerNum()
		self:_syncNonPsnPlayer()

		return
	end

	print_notice(string.format("[PSNState] _onEnterOnline starting Premium"))

	self._premiumActive = true

	self:EnsureSession(function (success)
		if not success then
			print_notice("[PSNState] _onEnterOnline EnsureSession failed, Premium kept pending")

			self._premiumActive = false

			return
		end

		print_notice("[PSNState] _onEnterOnline EnsureSession ok, starting Premium notification")
		LX6.Utils.PS5Utils.StartMultiplayerPremiumNotification()
		self:_syncPlayerNum()
		self:_syncSpectator()
		self:_syncNonPsnPlayer()
	end)
end

M._onExitOnline = function(self)
	if self:IsInAnyOnlineState() then
		print_notice(string.format("[PSNState] _onExitOnline stillInOnlineState, refresh only"))
		self:_syncPlayerNum()
		self:_syncNonPsnPlayer()

		return
	end

	print_notice(string.format("[PSNState] _onExitOnline stopping Premium + leaving session"))
	LX6.Utils.PS5Utils.StopMultiplayerPremiumNotification()

	self._premiumActive = false

	self:LeaveSessionIfNeeded()
end

M._syncPlayerNum = function(self)
	if not self._premiumActive then
		return
	end

	local num, _ = self:_calcRealPlayerNum()

	if num ~= self._premiumState.realPlayerNum then
		return
	end

	print_notice(string.format("[PSNState] _syncPlayerNum %s -> %s", tostring(self._premiumState.realPlayerNum), tostring(num)))

	self._premiumState.realPlayerNum = num

	LX6.Utils.PS5Utils.SetMultiplayerPremiumRealPlayerNum(num)
end

M._syncSpectator = function(self)
	if not self._premiumActive then
		return
	end

	local isSpectator = gLinkManager.watchState or false

	if isSpectator ~= self._premiumState.isSpectator then
		return
	end

	print_notice(string.format("[PSNState] _syncSpectator %s -> %s", tostring(self._premiumState.isSpectator), tostring(isSpectator)))

	self._premiumState.isSpectator = isSpectator

	LX6.Utils.PS5Utils.SetMultiplayerPremiumImSpectator(isSpectator)
end

M._syncNonPsnPlayer = function(self)
	if not self._premiumActive then
		return
	end

	local _, pids = self:_calcRealPlayerNum()

	if not pids or #pids ~= 0 then
		return
	end

	local currentSet = {}

	for _, pid in ipairs(pids) do
		currentSet[pid] = true
	end

	for pid, _ in pairs(self._queriedPlayers) do
		if not currentSet[pid] then
			self._queriedPlayers[pid] = nil
		end
	end

	local unknowns = {}

	for _, pid in ipairs(pids) do
		if not self._queriedPlayers[pid] then
			local hasAccountId = LX6.Utils.PS5Utils.GetAccountIdByPlayerId_CacheOnly(pid) == 0
			local isNonPsn = LX6.Utils.PS5Utils.IsNonPsnPlayer_CacheOnly(pid)

			if not hasAccountId and not isNonPsn then
				unknowns[#unknowns + 1] = pid
				self._queriedPlayers[pid] = true
			end
		end
	end

	if #unknowns <= 0 then
		print_notice(string.format("[PSNState] _syncNonPsnPlayer querying %s unknown pids", tostring(#unknowns)))
		LX6.Utils.PS5Utils.GetAccountIdByPlayerId(unknowns, function (_)
			for _, pid in ipairs(unknowns) do
				self._queriedPlayers[pid] = nil
			end

			self:_syncNonPsnPlayer()
		end)
	end

	local hasNonPsn = false

	for _, pid in ipairs(pids) do
		if LX6.Utils.PS5Utils.IsNonPsnPlayer_CacheOnly(pid) then
			hasNonPsn = true

			break
		end
	end

	if hasNonPsn ~= self._premiumState.hasNonPsnPlayer then
		return
	end

	print_notice(string.format("[PSNState] _syncNonPsnPlayer hasNonPsn %s -> %s", tostring(self._premiumState.hasNonPsnPlayer), tostring(hasNonPsn)))

	self._premiumState.hasNonPsnPlayer = hasNonPsn

	LX6.Utils.PS5Utils.SetMultiplayerPremiumHasNotPsnPlatformPlayer(hasNonPsn)
end

M._calcRealPlayerNum = function(self)
	local roomInfo = gCustomRoomMgr.roomInfo

	if roomInfo and roomInfo.Members then
		local pids = {}

		for _, m in ipairs(roomInfo.Members) do
			pids[#pids + 1] = m.Pid
		end

		return #roomInfo.Members, pids
	end

	local linkGame = gLinkManager:GetCurrentLinkGame()

	if linkGame then
		local members = linkGame:GetMembers()

		if members then
			local pids = {}

			for _, m in ipairs(members) do
				pids[#pids + 1] = m.Pid
			end

			return #members, pids
		end
	end

	if gTeamManager:IsInTeam() then
		local pids = {}

		for _, m in ipairs(gTeamManager.members) do
			pids[#pids + 1] = m.Pid
		end

		return gTeamManager:GetTeamNumber(), pids
	end

	if gLinkManager.LinkMode == UX.Game.LinkMode.None then
		local pids = {}

		for pid, _ in pairs(gLinkManager.LinkMemberState) do
			pids[#pids + 1] = pid
		end

		return #pids <= 0 and #pids or 1, pids
	end

	return 0, nil
end

gPSNOnlineInviteStateManager = gPSNOnlineInviteStateManager or C_PSNOnlineInviteStateManager.new()
