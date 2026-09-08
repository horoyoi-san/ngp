-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_GameplayRoom.lua
-- Decompiled from: 00709_LinkManager_GameplayRoom.lua_676867860ab9.luajit

local MessageConfig = LTConfig.MessageConfig
local LinkConfig = LTConfig.LinkConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local M = C_LinkManager

M.OnSyncLinkMatchRoomPrepare = function(self, roomId, room)
	if roomId ~= 0 or not room then
		gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
		self.OnMatchInit(self)
	else
		self.InitCurrentLinkGame(self, room)
	end
end

M.OnRoomSettingChange = function(self, setting)
	self.roomSetting = setting

	gMessageManager:SendMessage(gEventConstants.LINK_ROOM_SETTING_CHANGE)
end

M.IsAllowAI = function(self, multiplayId)
	local cfg = nil

	if multiplayId then
		cfg = LinkMultiPlayerConfig.GetConfig(multiplayId)
	else
		cfg = self.currentGameCfg
	end

	if not cfg then
		return false
	end

	return cfg.IsAIAllowed
end

M.AskNewRoom = function(self, autoInvite)
	autoInvite = self:CheckCanInviteAll() and autoInvite or false

	gClientToGameDelegate:AskNewRoom(self.targetPlayId, autoInvite).Callback = function (err, room)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if not room then
			return
		end

		if autoInvite then
			for k, v in pairs(self.LinkMemberInfo) do
				self.roomAskInviteDict[k] = gCS.TimeManager.ServerUnixTime
			end
		end

		self:SetMatchRoom(room)
		self:EndOfSearching()
		gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_PANEL)
	end
end

M.AskInviteFriendToRoom = function(self, playerId)
	self.roomAskInviteDict[playerId] = gCS.TimeManager.ServerUnixTime

	print_error("AskInviteFriendToRoom RPC not implemented, playerId:", playerId)
end

M.InvitePlayerToPrepareRoom = function(self, playerId)
	local linkGame = self.GetCurrentLinkGame(self)

	local sendGameInvite = function()
		slot0 = gClientToGameDelegate

		slot0:InvitePlayerToPrepareRoom(playerId).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:ShowMessage(err)
			end
		end
	end

	if not gCS.LuaUtils.IsOnPS5 or LX6.Utils.PS5Utils.IsNonPsnPlayer_CacheOnly(playerId) then
		sendGameInvite()

		return
	end

	slot4 = gPSNOnlineInviteManager

	slot4:TrySendViaPSN(gPSNOnlineInviteManager.K_INVITE_TYPE.GAMEPLAY, playerId, function ()
		if not linkGame or not linkGame.uxData then
			return nil
		end

		return {
			gameId = linkGame.uxData.GameId,
			roomId = linkGame.uxData.Id
		}
	end, nil, sendGameInvite)
end

M.SetMatchRoom = function(self, matchRoom)
	self.Log(self, "SetMatchRoom", matchRoom)

	self.matchRoom = matchRoom
	self.matchRoomMemberDict = {}

	if self.matchRoom then
		self.targetPlayId = self.matchRoom.GameId

		self.OnGameCfgInit(self)

		for i = 1, #self.matchRoom.Members do
			self.matchRoomMemberDict[self.matchRoom.Members[i].Pid] = true
		end
	else
		gPanelManager:Close(gPanelId.S_ONLINE_ROOM_PANEL)
	end

	if not self.stageRoom and not gPanelManager:IsPanelShowing(gPanelId.S_ONLINE_ROOM_PANEL) and self.matchRoomMemberDict[gPlayerManager.infoLogin.bindData.pid] then
		gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_PANEL)
	end
end

M.CheckRoomCanEnterGame = function(self, hideMessage)
	if not self.matchRoom then
		return false
	end

	for i = 1, #self.matchRoom.Members do
		if gCS.TimeManager.ServerUnixTime >= self.matchRoom.Members[i].MatchForbidDueTime then
			local time = gString.Format("%ds", self.matchRoom.Members[i].MatchForbidDueTime - gCS.TimeManager.ServerUnixTime)

			if not hideMessage then
				gDisplayMessageMgr:ShowMessage(MessageConfig.PrepareMemberForceExitGetCD, nil, , time)
			end

			return false
		end
	end

	return true
end

M.CheckIsRoomLeader = function(self)
	return self.matchRoom and self.matchRoom.LeaderPid ~= gPlayerManager.infoLogin.bindData.pid
end

M.AskKickFriendFromRoom = function(self, playerId)
	slot2 = gClientToGameDelegate

	slot2:AskKickFriendInRoom(playerId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.AskLeaveRoom = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskLeaveRoom().Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gMessageManager:SendMessage(gEventConstants.LINK_LEAVE_ROOM)
	end
end

M.CheckCanInviteAll = function(self)
	if table.isNilOrEmpty(self.matchInfo) then
		return true
	end

	return self.matchInfo.LastInviteAllTime + LinkConfig.InviteAllCD <= gCS.TimeManager.ServerUnixTime
end

M.CheckRoomCanEnterAndStart = function(self)
	local range = self:GetPlayModeRange(self.targetPlayId)

	return #self.matchRoom.Members <= range[2], range[1] < #self.matchRoom.Members and #self.matchRoom.Members > range[2]
end

M.ChangeAllowNonLeaderInvite = function(self)
	if not self.CheckIsRoomLeader(self) then
		return
	end

	self.roomSetting.AllowNonLeaderInvite = not self.roomSetting.AllowNonLeaderInvite
	slot1 = gClientToGameDelegate

	slot1:AskChangeRoomSetting(self.roomSetting).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end
