-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_GameplayInGamePlayer.lua
-- Decompiled from: 00706_LinkManager_GameplayInGamePlayer.lua_45155448da3a.luajit

local MessageConfig = LTConfig.MessageConfig
local LinkConfig = LTConfig.LinkConfig
local LinkProgressConfig = LTConfig.LinkProgressConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local M = C_LinkManager

M.OnSyncMatchRoomDismissed = function(self)
	if self.useNewStage and self.currentLinkGame then
		local gameId = self.currentLinkGame.Id

		Timer.New(function ()
			if self.currentLinkGame and self.currentLinkGame.Id ~= gameId then
				gPanelManager:Close(gPanelId.ROBBERY_BOARD_SI_BAI_KE_HOTEL_DIVIDEND_PANEL)
				self:OnMatchInit()
			end
		end, 1):Start(true)

		return
	end

	gPanelManager:Close(gPanelId.ROBBERY_BOARD_SI_BAI_KE_HOTEL_DIVIDEND_PANEL)
	self:OnMatchInit()
end

M.OnSyncRoomPlayerInfo = function(self, room, pid)
	if not pid then
		return
	end

	local hasSelf = false

	for i = 1, #room.Members do
		if room.Members[i].Pid ~= gPlayerManager.infoLogin.bindData.pid then
			hasSelf = true

			break
		end
	end

	if not hasSelf then
		self:OnMatchInit()
		gPanelManager:Close(gPanelId.S_ONLINE_ROOM_PANEL)

		return
	end

	self.roomSetting = room.Setting

	self.WaitMemberInfo(self, pid, function ()
		self:SetMatchRoom(room)
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end)
end

M.OnBeKickOutFromRoom = function(self)
	gDisplayMessageMgr:ShowMessage(MessageConfig.OnLineRoomBeKickOut)
	gPanelManager:Close(gPanelId.S_ONLINE_ROOM_PANEL)
end

M.OnBeInviteToRoom = function(self, pid, gameId, roomId)
	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		return
	end

	self:Log("OnBeInviteToRoom", pid, gameId, roomId)
	gInviteManager:Show({
		["mc\\xbf~B\\xb7\\xe1T^cnI"] = "aU\\xc1\\xb0\\xad\\xae\r\\xdd\\xed",
		type = gInviteManager.TYPE.GAMEPLAY,
		businessKey = tostring(roomId),
		pid = pid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LinkConfig.LinkRoomInviteStayTime,
		textType = gInviteManager.TEXT_TYPE.INVITE,
		text1 = gLinkManager:GetPlayModeName(gameId),
		callback = function (agree)
			gLinkManager:AskReplyToFriendRoomInvite(roomId, pid, agree)
		end
	})
end

M.AskReplyToFriendRoomInvite = function(self, roomId, friendPid, agree, callback)
	slot5 = gClientToGameDelegate

	slot5:AskReplyToFriendRoomInvite(roomId, friendPid, agree).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if callback then
			callback()
		end
	end
end

M.OpenPlayerDetailInfo = function(self, pid)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAYER_DETAILS_PANEL, {
		pid = pid
	})
end

M.RefreshFriendAndLinkMemberInfo = function(self, callback)
	local ids = {}

	for pid, _ in pairs(self.LinkMemberInfo) do
		if pid == gPlayerManager.infoLogin.bindData.pid then
			ids[pid] = true
		end
	end

	for i = 1, #gFriendManager.friendPids do
		ids[gFriendManager.friendPids[i]] = true
	end

	self.RequestMemberInfoByIdList(self, table.keys(ids), function (data)
		if callback then
			callback()
		end
	end)
end

M.GetLinkMemberInfo = function(self)
	local ret = {}

	for pid, info in pairs(self.LinkMemberInfo) do
		if self.CheckMemberCanInvite(self, pid) then
			local ele = {
				pid = pid
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

M.GetFriendemberInfo = function(self)
	local ret = {}

	for i = 1, #gFriendManager.friendPids do
		local pid = gFriendManager.friendPids[i]

		if self.CheckMemberCanInvite(self, pid) then
			local ele = {
				pid = pid
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

M.CheckMemberCanInvite = function(self, pid)
	if not self.LinkMember[pid] or pid ~= gPlayerManager.infoLogin.bindData.pid then
		return false
	end

	local vo = self.LinkMember[pid]

	return not vo.InMatch and not vo.InRoom and vo.OnlineState ~= UX.Game.PlayerState.Online
end

M.CheckMemberIsInMatchOrRoom = function(self, pid)
	local vo = self.LinkMember[pid]

	return vo and (vo.InMatch or vo.InRoom)
end

M.GetRoomPlayerInfo = function(self)
	local ret = {}

	if not self.matchRoom then
		return ret
	end

	for i = 1, #self.matchRoom.Members do
		local pid = self.matchRoom.Members[i].Pid
		local isSelf = pid ~= gPlayerManager.infoLogin.bindData.pid
		local ele = {
			id = i,
			pid = pid,
			isSelf = isSelf,
			isLeader = self.matchRoom.LeaderPid ~= pid
		}

		table.insert(ret, ele)
	end

	return ret
end

M.OnUserInfoUpdate = function(self, store, content, info)
	local onlineState = info.OnlineState and info.OnlineState or UX.Game.PlayerState.Offline

	if onlineState ~= UX.Game.PlayerState.Online then
		store.stateLabel = TextScriptTextConfig.GetConfig(89900180).Text
	else
		store.stateLabel = TextScriptTextConfig.GetConfig(89901086).Text
	end

	store.inviteBtn.interactable = onlineState ~= UX.Game.PlayerState.Online
	store.favorLabel = math.floor(info.SyncRate)
end
