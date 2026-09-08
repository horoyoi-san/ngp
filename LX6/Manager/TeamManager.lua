-- Original chunk: @Lua\LuaFiles\LX6\Manager\TeamManager.lua
-- Decompiled from: 00265_TeamManager.lua_9a9e3dc208f7.luajit

local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local CCVoiceManager = LX6.Audio.CCMini.CCVoiceManager.Instance
local channel = UX.Game.MessageChannel.Team
local ProfileManager = LX6.Engine.ProfileManager
C_TeamManager = DefClass("C_TeamManager", C_TeamManager)
local M = C_TeamManager

M.ctor = function(self)
	self.teamId = nil
	self.leaderPid = 0
	self.members = {}
	self.memberorders = {}
	self.allowMemberInvite = false
	self.autoApplyJoin = false
	self.teamRequestList = {}
	self.TEAM_STATUS = {
		["\\Qw"] = 3,
		["\\xbbW\\xb1t\\xed\\x85\\x97"] = 2,
		["6g\\xb8\\xa0\\xa6e"] = 1,
		["T\rS~"] = 0
	}
	self.MICRO_INPUT_TYPE = {
		["\\x84\\x81 \\x85U\\xd7"] = 1,
		["(g\\xb6\\xa9\\xafd"] = 3,
		["R\rQ"] = 2
	}
	self.rejectedPidList = {}
	self.chatRefreshTimer = {}
	self.voiceBlockedList = {}
	self.microphoneMode = {
		["\\xac</-l\\x9eT\\xcd\\xaf\\xa0"] = 3,
		["%\\xefP.\\xdc3\\xa6D\\xaf{\\xb9\\xb5"] = 1,
		["cOݵ\\xb0\\x8c\\xc5\\xe3"] = 2
	}
	self.VoiceType = {
		["Sݩ\\x81\\x97\n\\xc5\\xf1"] = 1,
		["\\xf6\\xcb3-\\xf2"] = 0,
		["Q\\xbc6\\xc7k\\xbei48~\\xb1\\xf6*\\xd7\\xe2"] = 3,
		["By\\xber\\xb7\\xe6Scty_"] = 5,
		["W7i^"] = 2,
		["\\xc6V\\x8f\\xee\\xbd$A\\xc4\"\\xe7~д\\xabV\\xbek]\\xb9\\xc3"] = 4
	}
	self.MicroMode2VoiceType = {
		[self.microphoneMode.GlobalOpenMic] = self.VoiceType.OpenMic,
		[self.microphoneMode.PushToTalk] = self.VoiceType.LongPressMicrophone,
		[self.microphoneMode.ShortcutKey] = self.VoiceType.ClickStartEndMicrophone
	}
	self.teamMaxMemberCount = 4
	self.curVoiceType = self.VoiceType.ListenOnly
	self.savedVoiceType = self.VoiceType.ListenOnly

	gMessageManager:AddMessageListener(gEventConstants.LINK_MODE_CHANGE, function ()
		self:OnLinkModeChange()
	end)
	gMessageManager:AddMessageListener(gEventConstants.MICROPHONE_MODE_CHANGED, function (eventId, arg)
		self:OnMicModeChange(arg)
	end)
	gMessageManager:AddMessageListener(gEventConstants.LINK_MEMBER_CHANGE, function (eventId, arg)
		self:OnLinkMemberChange(arg)
	end)
end

M.OnLinkModeChange = function(self, _, data)
	self:RefreshHudUIState()
end

M.RefreshHudUIState = function(self)
	self:RefreshMemberLinkState()

	if gLinkManager.LinkMode == UX.Game.LinkMode.None and not gLinkManager:IsDisableMemberInfo() and gLinkManager:GetShowTeamMainState() then
		gPanelManager:CheckShow(gPanelId.S_TEAM_MAIN_PANEL)
	else
		gPanelManager:Close(gPanelId.S_TEAM_MAIN_PANEL)
	end

	if gLinkManager.LinkMode == UX.Game.LinkMode.None then
		gPanelManager:CheckShow(gPanelId.SOCIAL_BULLET_COMMENTS_PANEL)
	else
		gPanelManager:Close(gPanelId.SOCIAL_BULLET_COMMENTS_PANEL)
	end
end

M.OnLinkMemberChange = function(self, data)
	self:RefreshMemberLinkState()
end

M.RefreshMemberLinkState = function(self)
	if not self:IsInTeam() then
		return
	end

	local currentLinkMode = gLinkManager.LinkMode

	for _, member in ipairs(self.members) do
		local linkMode = gLinkManager.LinkMemberState[member.Pid]
		member.IsInCurrentLink = linkMode ~= currentLinkMode
	end

	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
end

M.ClearData = function(self)
	print_debug("team  CCVoiceManager:ExitVoiceTeam ")
	CCVoiceManager:ExitVoiceTeam(UX.Game.MessageChannel.Team)
	gMessageManager:SendMessage(gEventConstants.TEAM_LEAVE)

	self.teamId = nil
	self.leaderPid = nil
	self.members = nil
	self.memberorders = nil
	self.allowMemberInvite = nil
	self.autoInviteToJoin = nil
	self.teamRequestList = nil
	self.voiceBlockedList = {}
end

M.SyncPlayerTeamInfo = function(self, teamInfo)
	local wasInTeam = self:IsInTeam()

	self:RefreshTeamData(teamInfo)

	if not wasInTeam and self:IsInTeam() then
		self:JoinVoiceTeam()
	end
end

M.SyncPlayerJoinTeam = function(self, teamInfo)
	self:RefreshTeamData(teamInfo)
	self:JoinVoiceTeam()
	gMessageManager:SendMessage(gEventConstants.TEAM_JOIN)
end

M.SyncPlayerTeamSettingChange = function(self, teamId, setting)
	self.allowMemberInvite = setting.AllowMemberInvite
	self.autoApplyJoin = setting.AutoApplyJoin

	gMessageManager:SendMessage(gEventConstants.TEAM_SETTING_CHANGED)
end

M.SyncPlayerCreateTeam = function(self, teamInfo)
	self:RefreshTeamData(teamInfo)
	self:JoinVoiceTeam()
	gMessageManager:SendMessage(gEventConstants.TEAM_JOIN)
end

M.SyncPlayerTeamMemberLeave = function(self, teamId, playerInfo)
	self:DeleteTeamMember(playerInfo)
end

M.SyncPlayerTeamMemberKick = function(self, teamId, playerInfo)
	self:DeleteTeamMember(playerInfo)

	if playerInfo.Pid ~= gPlayerManager.infoLogin.bindData.pid then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_KickedOut)
	end
end

M.SyncPlayerTeamMemberJoin = function(self, teamId, playerInfo)
	if playerInfo.TeamId == self.teamId then
		return
	end

	self:AddTeamMember(playerInfo)
end

M.SyncPlayerTeamLeaderChange = function(self, teamId, playerInfo)
	self.leaderPid = playerInfo.Pid

	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_NewCaptainGet, nil, , gSocialFriendManager:GetPlayerDisplayName(playerInfo.Pid, playerInfo.Name))
end

M.SyncPlayerInviteToTeam = function(self, playerInfo, teamId)
	local data = {
		type = gInviteManager.TYPE.TEAM,
		pid = playerInfo.Pid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LTConfig.LinkConfig.Team_InviteTimeDuration,
		text1 = LTConfig.TextScriptTextConfig.GetConfig(89901158).Text,
		textType = gInviteManager.TEXT_TYPE.INVITE,
		callback = function (agree)
			gClientToGameDelegate:AskResponseTeamInvite(playerInfo.Pid, teamId, not agree).Callback = function (err, data)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end
			end
		end
	}

	gInviteManager:Show(data)
end

M.SyncPlayerResponseTeamInvite = function(self, playerInfo, teamId, reject)
	if reject then
		self.rejectedPidList[playerInfo.Pid] = gLuaDataManager.serverTime

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_RejectInvitation, nil, , gSocialFriendManager:GetPlayerDisplayName(playerInfo.Pid, playerInfo.Name))

		return
	end
end

M.SyncPlayerResponseTeamLeaderApply = function(self, oldLeader, teamId, reject)
	if teamId == self.teamId then
		return
	end

	if reject then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_RejectCaptaincy, nil, , gSocialFriendManager:GetPlayerDisplayName(oldLeader.Pid, oldLeader.Name))
	end
end

M.SyncPlayerTeamInvitationApply = function(self, teamId, inviter, invitee)
	local data = {
		type = gInviteManager.TYPE.TEAM,
		textType = gInviteManager.TEXT_TYPE.INVITEXXX,
		pid = inviter.Pid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LTConfig.LinkConfig.Team_InviteTimeDuration,
		text1 = gSocialFriendManager:GetPlayerDisplayName(invitee.Pid, invitee.Name),
		text2 = TextCommonTextConfig.GetConfig(TextCommonTextConfig.JoinTheTeam).Text,
		callback = function (agree)
			if agree then
				gClientToGameDelegate:AskJoinTeam(invitee.Pid, teamId, false).Callback = function (err, data)
					if err == LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)

						return
					end
				end
			else
				print_debug("拒绝邀请入队")
			end
		end
	}

	gInviteManager:Show(data)
end

M.SyncPlayerTeamApply = function(self, teamId, applier)
	local data = {
		type = gInviteManager.TYPE.TEAM,
		textType = gInviteManager.TEXT_TYPE.APPLY,
		pid = applier.Pid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LTConfig.LinkConfig.Team_ApplyTimeDuration,
		text1 = LTConfig.TextScriptTextConfig.GetConfig(89901158).Text,
		callback = function (agree)
			if agree then
				gClientToGameDelegate:AskJoinTeam(applier.Pid).Callback = function (err, data)
					if err == LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)

						return
					end
				end
			else
				print_debug("拒绝入队申请")
			end
		end
	}

	gInviteManager:Show(data)
end

M.SyncPlayerChangeLeaderApply = function(self, teamId, applier)
	local data = {
		type = gInviteManager.TYPE.TEAM,
		textType = gInviteManager.TEXT_TYPE.APPLY,
		pid = applier.Pid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LTConfig.LinkConfig.Team_ApplyTimeDuration,
		text1 = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamLeader).Text,
		callback = function (agree)
			gClientToGameDelegate:AskResponseTeamLeaderApply(applier.Pid, not agree).Callback = function (err, data)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end
			end
		end
	}

	gInviteManager:Show(data)
end

M.AskCreateTeam = function(self)
	gClientToGameDelegate:AskCreateTeam().Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gTeamManager:SyncPlayerCreateTeam(data)
	end
end

M.AskKickTeamMember = function(self, pid)
	local rightCallBack = function()
		gClientToGameDelegate:AskKickTeamMember(pid).Callback = function (err, data)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end

		return true
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_IfExpel, rightCallBack, nil)
end

M.AskChangeTeamLeader = function(self, pid)
	local rightCallBack = function()
		gClientToGameDelegate:AskChangeTeamLeader(pid).Callback = function (err, data)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end

		return true
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_IfTransferCaptain, rightCallBack, nil)
end

M.AskChangeTeamLeaderApply = function(self)
	gClientToGameDelegate:AskChangeTeamLeaderApply().Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.GetTeamId = function(self)
	return self.teamId
end

M.RefreshTeamData = function(self, teaminfo)
	if not teaminfo or not teaminfo.Members or #teaminfo.Members ~= 0 then
		self:ClearData()
		gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)

		return
	end

	self.teamId = teaminfo.TeamId
	self.leaderPid = teaminfo.LeaderPid
	self.members = teaminfo.Members
	self.memberorders = teaminfo.MemberOrder

	for i, v in ipairs(self.members) do
		if gLinkManager and gLinkManager.LinkMember and v.Pid then
			gLinkManager.LinkMember[v.Pid] = v
		end

		CCVoiceManager:RefreshPlatformIgnore(channel, v.Pid)
	end

	self.allowMemberInvite = teaminfo.Setting.AllowMemberInvite
	self.autoApplyJoin = teaminfo.Setting.AutoApplyJoin

	self:RefreshHudUIState()
	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
end

M.DeleteTeamMember = function(self, playerInfo)
	if not self.members then
		return
	end

	for i = #self.members, 1, -1 do
		if self.members[i].Pid ~= playerInfo.Pid then
			table.remove(self.members, i)

			break
		end
	end

	for i = 1, #self.memberorders do
		if self.memberorders[i] ~= playerInfo.Pid then
			self.memberorders[i] = ulong.zero
		end
	end

	if playerInfo.Pid ~= gPlayerManager.infoLogin.bindData.pid then
		self:ClearData()
	end

	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
	gMessageManager:SendMessage(gEventConstants.TEAM_MEMBER_CHANGED)
end

M.AddTeamMember = function(self, playerInfo)
	if not self.members then
		return
	end

	for i, v in pairs(self.members) do
		if type(v) == "number" and v.Pid ~= playerInfo.Pid then
			return
		end
	end

	CCVoiceManager:RefreshPlatformIgnore(channel, playerInfo.Pid)
	table.insert(self.members, playerInfo)
	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
	gMessageManager:SendMessage(gEventConstants.TEAM_MEMBER_CHANGED)
end

M.LeaveTeam = function(self)
	self:ClearData()
	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
end

M.InviteToTeam = function(self, pid)
	local sendGameInvite = function()
		gClientToGameDelegate:AskInviteToTeam(pid).Callback = function (err, data)
			if err == LTConfig.MessageConfig.Ok then
				if err ~= LTConfig.MessageConfig.NoPlayer then
					gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.PlayerOffline)

					return
				end

				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901333).Text)
			gInviteManager:AddInviteFriend(gInviteManager.TYPE.TEAM, LTConfig.LinkConfig.LinkInviteCountDownTime, pid)
		end
	end

	if not gCS.LuaUtils.IsOnPS5 or LX6.Utils.PS5Utils.IsNonPsnPlayer_CacheOnly(pid) then
		sendGameInvite()

		return
	end

	gPSNOnlineInviteManager:TrySendViaPSN(gPSNOnlineInviteManager.K_INVITE_TYPE.TEAM, pid, function ()
		return {
			teamId = gTeamManager.teamId
		}
	end, function (result)
		if result ~= gPSNOnlineInviteManager.SendResult.Success then
			gInviteManager:AddInviteFriend(gInviteManager.TYPE.TEAM, LTConfig.LinkConfig.LinkInviteCountDownTime, pid)
		end
	end, sendGameInvite)
end

M.InviteGroupFriendToTeam = function(self, groupId)
	gInviteManager:AddInviteGroup(gInviteManager.TYPE.TEAM, LTConfig.LinkConfig.LinkInviteCountDownTime, groupId)
end

M.GetMemberOrder = function(self, pid)
	if self.memberorders then
		for i, v in ipairs(self.memberorders) do
			if v ~= pid then
				return i
			end
		end
	end

	return 1
end

M.GetMember = function(self, Pid)
	if not self.members then
		return nil
	end

	for _, member in ipairs(self.members) do
		if member.Pid ~= Pid then
			return member
		end
	end

	return nil
end

M.IsInTeam = function(self)
	return self.members and #self.members >= 0
end

M.IsTeamLeader = function(self)
	return self.leaderPid ~= gPlayerManager.infoLogin.bindData.pid
end

M.IsTeamFull = function(self)
	return self.members and #self.members < 4
end

M.GetTeamNumber = function(self)
	if not self.members then
		return 0
	end

	return #self.members
end

M.IsInTeamByPid = function(self, pid)
	if not self.members then
		return false
	end

	for _, member in ipairs(self.members) do
		if type(member) == "number" and member.Pid ~= pid then
			return true
		end
	end

	return false
end

M.AskApplyToTeam = function(self, teamId)
	if self:IsInTeam() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_YouAlreadyInOneTeam)

		return
	end

	local isCD = gInviteManager:IsApplyCD(gInviteManager.TYPE.TEAM, teamId)

	if isCD then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_OperateFrequent)

		return
	end

	gInviteManager:AddApplyList(gInviteManager.TYPE.TEAM, LTConfig.LinkConfig.Team_ApplyTimeDuration, teamId)

	gClientToGameDelegate:AskApplyToTeam(teamId, false).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if not gTeamManager.autoApplyJoin then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_YouAlreadySendApply)
		end
	end
end

M.OnClickInviteTeam = function(self, pid)
	if self.InvitePlayerTeamData and self.InvitePlayerTeamData.TeamId then
		self:AskApplyToTeam(self.InvitePlayerTeamData.TeamId)

		return
	end

	if not self:IsInTeam() then
		self:CreateAndInviteTeam(pid)

		return
	end

	if self:IsInTeamByPid(pid) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_AlreadyInAnotherTeam)

		return
	end

	if not self.allowMemberInvite and not self:IsTeamLeader() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_HasNoPermissions)

		return
	end

	if gInviteManager:IsInviteFriendCD(gInviteManager.TYPE.TEAM, pid) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_OperateFrequent)

		return
	end

	self:InviteToTeam(pid)
end

M.CreateAndInviteTeam = function(self, pid)
	local callBack = function()
		gClientToGameDelegate:AskCreateTeam().Callback = function (err, data)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gTeamManager:InviteToTeam(pid)
			gTeamManager:SyncPlayerCreateTeam(data)
		end

		return true
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_CheckIfCreatTeam, callBack, nil)
end

M.CheckCanInvite = function(self)
	if not self:IsInTeam() then
		return false
	end

	if self:IsTeamFull() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_YourTeamIsFull)

		return false
	end

	if not self.allowMemberInvite and not self:IsTeamLeader() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_HasNoPermissions)

		return false
	end

	return true
end

M.AskQueryTeamInfoByPid = function(self, ownerId, pid)
	self.InviteBtnTextId = nil
	self.InvitePlayerTeamData = nil

	gClientToGameDelegate:AskQueryTeamInfoByPid(ownerId).Callback = function (err, data)
		local textId = 0

		if err == LTConfig.MessageConfig.Ok then
			return
		end

		if data and data.TeamId then
			if self:IsInTeamByPid(ownerId) then
				textId = TextCommonTextConfig.NotInviteTeam
			else
				textId = TextCommonTextConfig.ApplyJoinTeam
			end
		elseif gInviteManager:IsInviteFriendCD(gInviteManager.TYPE.TEAM, ownerId) then
			textId = TextCommonTextConfig.InvitingTeam
		else
			textId = TextCommonTextConfig.InviteTeam
		end

		self.InviteBtnTextId = textId
		self.InvitePlayerTeamData = data

		gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_INVITE_BTN, pid)
	end
end

M.GetInviteBtnTextId = function(self)
	if not self.InviteBtnTextId then
		return TextCommonTextConfig.InviteTeam
	end

	return self.InviteBtnTextId
end

M.CheckIdRejected = function(self, pid)
	local time = self.rejectedPidList[pid]

	if not time then
		return false
	end

	local cdData = gInviteManager:IsInviteFriendCD(gInviteManager.TYPE.TEAM, pid)

	if cdData and time >= cdData.timestamp + cdData.stayTime and cdData.timestamp >= time then
		return true
	else
		return false
	end
end

M.EnterSceneRoom = function(self, param)
	self.roomId = param.roomId

	self:CloseAreaTips()

	if self.exitRoomTimer then
		self.exitRoomTimer:Stop()

		self.exitRoomTimer = nil

		return
	end

	if self.enterRoomTimer then
		return
	end

	self.areaPopUpId = gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_OnlineSpecialAreaTips, {
		["[\\xb4\\x96\\x8aU"] = false,
		areaId = param.areaId
	})
	self.enterRoomTimer = Timer.New(function ()
		self:CloseAreaTips()
		self.enterRoomTimer:Stop()

		self.enterRoomTimer = nil
	end, 3):Start()
end

M.ExitSceneRoom = function(self, param)
	self:CloseAreaTips()

	if self.enterRoomTimer then
		self.enterRoomTimer:Stop()

		self.enterRoomTimer = nil
	end

	if self.exitRoomTimer then
		return
	end

	self.areaPopUpId = gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_OnlineSpecialAreaTips, {
		["[\\xb4\\x96\\x8aU"] = true,
		exitDalay = param.exitDalay,
		areaId = param.areaId
	})
	self.roomId = param.roomId
	self.exitRoomTimer = Timer.New(function ()
		self:CloseAreaTips()
		self.exitRoomTimer:Stop()

		self.exitRoomTimer = nil
	end, param.exitDalay):Start()
end

M.CloseAreaTips = function(self)
	if self.areaPopUpId then
		gNewPopupManager:RemovePopup(self.areaPopUpId)

		self.areaPopUpId = nil
	end

	gPanelManager:Close(gPanelId.S_ONLINE_SPECIAL_AREA_TIPS)
end

M.SyncPlayerTeamMemberStateChange = function(self, teamId, playerSyncInfo)
	if not self.members then
		return
	end

	local playerInfo = playerSyncInfo.PlayerBasicInfo
	local otherFieldMap = {}

	for key, value in pairs(playerSyncInfo) do
		if key == "PlayerBasicInfo" then
			otherFieldMap[key] = value
		end
	end

	local metaTable = {
		__index = otherFieldMap
	}

	setmetatable(playerInfo, metaTable)

	for i, member in ipairs(self.members) do
		if member.Pid ~= playerInfo.Pid then
			self.members[i] = playerInfo
			local order = playerSyncInfo.MemberOrder

			if order and self.memberorders then
				if order ~= -1 then
					for i = 1, #self.memberorders do
						if self.memberorders[i] ~= playerInfo.Pid then
							self.memberorders[i] = ulong.zero
						end
					end
				else
					self.memberorders[order + 1] = playerInfo.Pid
				end
			end

			gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)

			return
		end
	end
end

M.SyncTeamMemberInMatchState = function(self, pid, inMatch)
	if not self.members then
		return
	end

	for i, member in ipairs(self.members) do
		if member.Pid ~= pid then
			member.InMatch = inMatch

			gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)

			return
		end
	end
end

M.JoinVoiceTeam = function(self)
	self.curVoiceType = self.savedVoiceType or self.VoiceType.ListenOnly

	print_debug("team JoinVoiceTeam ", self.teamId)

	local callback = function()
		self:SetVoiceType(self.curVoiceType)
	end

	CCVoiceManager:JoinVoiceTeam(channel, self.teamId, callback)
end

M.SetVoiceType = function(self, type)
	self.curVoiceType = type

	if type == self.VoiceType.MoreSettings then
		self.savedVoiceType = type
	end

	if type ~= self.VoiceType.OpenMic then
		ProfileManager.gameProfile.microphoneMode = self.microphoneMode.GlobalOpenMic

		gTeamManager:SetToggleMicrophone(true)
		gTeamManager:SetToggleMute(false)
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
	elseif type ~= self.VoiceType.ListenOnly then
		gTeamManager:SetToggleMicrophone(false)
		gTeamManager:SetToggleMute(false)
	elseif type ~= self.VoiceType.Mute then
		gTeamManager:SetToggleMicrophone(false)
		gTeamManager:SetToggleMute(true)
	elseif type ~= self.VoiceType.LongPressMicrophone then
		ProfileManager.gameProfile.microphoneMode = self.microphoneMode.PushToTalk

		gTeamManager:SetToggleMicrophone(false)
		gTeamManager:SetToggleMute(false)
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
	elseif type ~= self.VoiceType.ClickStartEndMicrophone then
		ProfileManager.gameProfile.microphoneMode = self.microphoneMode.ShortcutKey

		gTeamManager:SetToggleMicrophone(false)
		gTeamManager:SetToggleMute(false)
		gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS)
	end

	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_VOICE_TYPE)
end

M.IsVoiceBlocked = function(self, playerId)
	return self.voiceBlockedList[playerId] or false
end

M.SetVoiceBlocked = function(self, playerId, isBlocked)
	if isBlocked then
		self.voiceBlockedList[playerId] = true
	else
		self.voiceBlockedList[playerId] = nil
	end

	print_debug("team CCVoiceManager IgnorePlayer ", channel, playerId, isBlocked)
	CCVoiceManager:IgnorePlayer(channel, ulong.tonum2(playerId), isBlocked)
end

M.OnMicModeChange = function(self, arg)
	local oldMode = arg.oldMode
	local newMode = arg.newMode

	if oldMode ~= newMode or not table.contains(self.MICRO_INPUT_TYPE, oldMode) or not table.contains(self.MICRO_INPUT_TYPE, newMode) then
		return
	end

	if not self:IsInTeam() then
		return
	end

	if table.contains(self.MicroMode2VoiceType, self.curVoiceType) then
		self:SetVoiceType(self.MicroMode2VoiceType[newMode])
	end
end

M.SetToggleMicrophone = function(self, open)
	self.isOpenMicrophone = open

	print_debug("team CCVoiceManager ToggleMicrophone ", open)
	CCVoiceManager:ToggleMicrophone(channel, open)
end

M.SetToggleMute = function(self, open)
	print_debug("team CCVoiceManager SetToggleMute ", open)
	CCVoiceManager:ToggleMute(channel, open)
end

M.GetOrderMembers = function(self, tbl)
	tbl = tbl or {}

	if not self.memberorders then
		return tbl
	end

	for _, pid in ipairs(gTeamManager.memberorders) do
		if pid and pid == ulong.zero then
			table.insert(tbl, pid)
		end
	end

	return tbl
end

gTeamManager = gTeamManager or C_TeamManager.new()
