local TextCommonTextConfig = LTConfig.TextCommonTextConfig
C_TeamManager = DefClass("C_TeamManager", C_TeamManager)
local M = C_TeamManager

function M:ctor()
	self.teamId = 0
	self.leaderPid = 0
	self.members = {}
	self.allowMemberInvite = false
	self.autoApplyJoin = false
	self.teamRequestList = {}
	self.TEAM_STATUS = {
		FULL = 2,
		DISSOLUTION = 3,
		JOINED = 1,
		NONE = 0
	}
	self.rejectedPidList = {}
	self.chatRefreshTimer = {}

	gMessageManager:AddMessageListener(gEventConstants.LINK_MODE_CHANGE, function ()
		self:OnLinkModeChange()
	end)
end

function M:OnLinkModeChange(_, data)
	if gLinkManager.LinkMode == UX.Game.LinkMode.Private or gLinkManager.LinkMode == UX.Game.LinkMode.Public then
		gPanelManager:CheckShow(gPanelId.S_TEAM_MAIN_PANEL)
	else
		gPanelManager:Close(gPanelId.S_TEAM_MAIN_PANEL)
	end
end

function M:ClearData()
	self.teamId = nil
	self.leaderPid = nil
	self.members = nil
	self.allowMemberInvite = nil
	self.autoInviteToJoin = nil
	self.teamRequestList = nil
end

function M:SyncPlayerTeamInfo(teamInfo)
	self:RefreshTeamData(teamInfo)
end

function M:SyncPlayerJoinTeam(teamInfo)
	self:RefreshTeamData(teamInfo)
end

function M:SyncPlayerTeamSettingChange(teamId, setting)
	self.allowMemberInvite = setting.AllowMemberInvite
	self.autoApplyJoin = setting.AutoApplyJoin
end

function M:SyncPlayerCreateTeam(teamInfo)
	self:RefreshTeamData(teamInfo)
end

function M:SyncPlayerTeamMemberLeave(teamId, playerInfo)
	self:DeleteTeamMember(playerInfo)
end

function M:SyncPlayerTeamMemberKick(teamId, playerInfo)
	self:DeleteTeamMember(playerInfo)

	if playerInfo.Pid == gPlayerManager.infoLogin.bindData.pid then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_KickedOut)
	end
end

function M:SyncPlayerTeamMemberJoin(teamId, playerInfo)
	self:AddTeamMember(playerInfo)
end

function M:SyncPlayerTeamLeaderChange(teamId, playerInfo)
	self.leaderPid = playerInfo.Pid

	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_NewCaptainGet, nil, nil, playerInfo.Name)
end

function M:SyncPlayerInviteToTeam(playerInfo, teamId)
	local data = {
		type = gInviteManager.TYPE.TEAM,
		pid = playerInfo.Pid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LTConfig.LinkConfig.Team_InviteTimeDuration,
		text1 = LTConfig.TextScriptTextConfig.GetConfig(89901158).Text,
		textType = gInviteManager.TEXT_TYPE.INVITE,
		callback = function (agree)
			if agree then
				gClientToGameDelegate:AskResponseTeamInvite(playerInfo.Pid, teamId, false).Callback = function (err, data)
					if err ~= LTConfig.MessageConfig.Ok then
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

function M:SyncPlayerResponseTeamInvite(playerInfo, teamId, reject)
	if reject then
		self.rejectedPidList[playerInfo.Pid] = gLuaDataManager.serverTime

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_RejectInvitation, nil, nil, playerInfo.Name)

		return
	end

	self:AddTeamMember(playerInfo)
end

function M:SyncPlayerTeamInvitationApply(teamId, inviter, invitee)
	local data = {
		type = gInviteManager.TYPE.TEAM,
		textType = gInviteManager.TEXT_TYPE.INVITEXXX,
		pid = inviter.Pid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LTConfig.LinkConfig.Team_InviteTimeDuration,
		text1 = invitee.Name,
		text2 = TextCommonTextConfig.GetConfig(TextCommonTextConfig.JoinTheTeam).Text,
		callback = function (agree)
			if agree then
				gClientToGameDelegate:AskJoinTeam(invitee.Pid, teamId, false).Callback = function (err, data)
					if err ~= LTConfig.MessageConfig.Ok then
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

function M:SyncPlayerTeamApply(teamId, applier)
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
					if err ~= LTConfig.MessageConfig.Ok then
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

function M:SyncPlayerChangeLeaderApply(teamId, applier)
	local data = {
		type = gInviteManager.TYPE.TEAM,
		textType = gInviteManager.TEXT_TYPE.APPLY,
		pid = applier.Pid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LTConfig.LinkConfig.Team_ApplyTimeDuration,
		text1 = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamLeader).Text,
		callback = function (agree)
			if agree then
				gClientToGameDelegate:AskChangeTeamLeader(applier.Pid).Callback = function (err, data)
					if err ~= LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)

						return
					end
				end
			else
				print_debug("拒绝当队长申请")
			end
		end
	}

	gInviteManager:Show(data)
end

function M:AskCreateTeam()
	gClientToGameDelegate:AskCreateTeam().Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gTeamManager:SyncPlayerCreateTeam(data)
	end
end

function M:AskKickTeamMember(pid)
	local function rightCallBack()
		gClientToGameDelegate:AskKickTeamMember(pid).Callback = function (err, data)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end

		return true
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_IfExpel, rightCallBack, nil)
end

function M:AskChangeTeamLeader(pid)
	local function rightCallBack()
		gClientToGameDelegate:AskChangeTeamLeader(pid).Callback = function (err, data)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end

		return true
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_IfTransferCaptain, rightCallBack, nil)
end

function M:AskChangeTeamLeaderApply()
	gClientToGameDelegate:AskChangeTeamLeaderApply().Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:RefreshTeamData(teaminfo)
	if not teaminfo then
		self:ClearData()

		return
	end

	if not teaminfo.Members or #teaminfo.Members == 0 then
		self:ClearData()
		gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)

		return
	end

	self.teamId = teaminfo.TeamId
	self.leaderPid = teaminfo.LeaderPid
	self.members = teaminfo.Members
	self.allowMemberInvite = teaminfo.Setting.AllowMemberInvite
	self.autoApplyJoin = teaminfo.Setting.AutoApplyJoin

	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
end

function M:DeleteTeamMember(playerInfo)
	if not self.members then
		return
	end

	for i = #self.members, 1, -1 do
		if self.members[i].Pid == playerInfo.Pid then
			table.remove(self.members, i)

			break
		end
	end

	if playerInfo.Pid == gPlayerManager.infoLogin.bindData.pid then
		self:ClearData()
	end

	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
end

function M:AddTeamMember(playerInfo)
	if not self.members then
		return
	end

	for i, v in pairs(self.members) do
		if type(v) ~= "number" and v.Pid == playerInfo.Pid then
			return
		end
	end

	table.insert(self.members, playerInfo)
	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
end

function M:LeaveTeam()
	self:ClearData()
	gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_DATA)
end

function M:InviteToTeam(pid)
	gClientToGameDelegate:AskInviteToTeam(pid).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901333).Text)
		gInviteManager:AddInviteFriend(gInviteManager.TYPE.TEAM, LTConfig.LinkConfig.Team_ApplyTimeDuration, pid)
	end
end

function M:InviteGroupFriendToTeam(groupId)
	gInviteManager:AddInviteGroup(gInviteManager.TYPE.TEAM, LTConfig.LinkConfig.Team_GroupInviteCD, groupId)
end

function M:GetMember(Pid)
	for _, member in ipairs(self.members) do
		if member.Pid == Pid then
			return member
		end
	end

	return nil
end

function M:IsInTeam()
	return self.members and #self.members > 0
end

function M:IsTeamLeader()
	return self.leaderPid == gPlayerManager.infoLogin.bindData.pid
end

function M:IsTeamFull()
	return self.members and #self.members >= 4
end

function M:GetTeamNumber()
	if not self.members then
		return 0
	end

	return #self.members
end

function M:IsInTeamByPid(pid)
	if not self.members then
		return false
	end

	for _, member in ipairs(self.members) do
		if type(member) ~= "number" and member.Pid == pid then
			return true
		end
	end

	return false
end

function M:AskApplyToTeam(teamId)
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
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:OnClickInviteTeam(pid)
	if self.InvitePlayerTeamData and self.InvitePlayerTeamData.TeamId then
		self:AskApplyToTeam(self.InvitePlayerTeamData.TeamId)

		return
	end

	if not self:IsInTeam() then
		local function callBack()
			gClientToGameDelegate:AskCreateTeam().Callback = function (err, data)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				gTeamManager:InviteToTeam(pid)
				gTeamManager:SyncPlayerCreateTeam(data)
			end

			return true
		end

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_CheckIfCreatTeam, callBack, nil)

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

function M:CheckIsShowInviteTeamBtn()
	return true
end

function M:AskQueryTeamInfoByPid(pid)
	self.InviteBtnTextId = nil
	self.InvitePlayerTeamData = nil

	gClientToGameDelegate:AskQueryTeamInfoByPid(pid).Callback = function (err, data)
		local textId = 0

		if err ~= LTConfig.MessageConfig.Ok then
			return
		end

		if data and data.TeamId then
			if self:IsInTeamByPid(pid) then
				textId = TextCommonTextConfig.NotInviteTeam
			else
				textId = TextCommonTextConfig.ApplyJoinTeam
			end
		elseif gInviteManager:IsInviteFriendCD(gInviteManager.TYPE.TEAM, pid) then
			textId = TextCommonTextConfig.InvitingTeam
		else
			textId = TextCommonTextConfig.InviteTeam
		end

		self.InviteBtnTextId = textId
		self.InvitePlayerTeamData = data

		gMessageManager:SendMessage(gEventConstants.TEAM_REFRESH_INVITE_BTN)
	end
end

function M:GetInviteBtnTextId()
	if not self.InviteBtnTextId then
		return TextCommonTextConfig.InviteTeam
	end

	return self.InviteBtnTextId
end

function M:CheckIdRejected(pid)
	local time = self.rejectedPidList[pid]

	if not time then
		return false
	end

	local cdData = gInviteManager:IsInviteFriendCD(gInviteManager.TYPE.TEAM, pid)

	if cdData and time < cdData.timestamp + cdData.stayTime and cdData.timestamp < time then
		return true
	else
		return false
	end
end

function M:EnterSceneRoom(param)
	self.roomId = param.roomId

	self:CloseAreaTips()

	if self.exitRoomTimer then
		self.exitRoomTimer:Stop()

		self.exitRoomTimer = nil

		return
	end

	self.areaPopUpId = gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_OnlineSpecialAreaTips, {
		isExit = false
	})
	self.enterRoomTimer = Timer.New(function ()
		self:CloseAreaTips()
		self.enterRoomTimer:Stop()

		self.enterRoomTimer = nil
	end, 3):Start()
end

function M:ExitSceneRoom(param)
	self:CloseAreaTips()

	if self.enterRoomTimer then
		self.enterRoomTimer:Stop()

		self.enterRoomTimer = nil
	end

	self.areaPopUpId = gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_OnlineSpecialAreaTips, {
		isExit = true,
		exitDalay = param.exitDalay
	})
	self.roomId = param.roomId
	self.exitRoomTimer = Timer.New(function ()
		self:CloseAreaTips()
		self.exitRoomTimer:Stop()

		self.exitRoomTimer = nil
	end, param.exitDalay):Start()
end

function M:CloseAreaTips()
	if self.areaPopUpId then
		gNewPopupManager:RemovePopup(self.areaPopUpId)

		self.areaPopUpId = nil
	end

	gPanelManager:Close(gPanelId.S_ONLINE_SPECIAL_AREA_TIPS)
end

gTeamManager = gTeamManager or C_TeamManager.new()
