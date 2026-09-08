-- Original chunk: @Lua\LuaFiles\LX6\GUI\Club\ClubManager.lua
-- Decompiled from: 00249_ClubManager.lua_be66a4f9c258.luajit

local ClubJobType = UX.Game.ClubJobType
C_ClubManager = DefClass("C_ClubManager", C_ClubManager)
local M = C_ClubManager

M.ctor = function(self)
	self:ResetClubData()
end

M.ResetClubData = function(self)
	self.clubInfo = nil
	self.memberList = {}
	self.memberMap = {}
	self.myJob = ClubJobType and ClubJobType.Normal or 0
	self.playerClubTaskInfo = nil
	self.clubHonors = nil
	self.clubEventList = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.ONLINE_SEASON_CHANGED, self:CreateAction("OnOnlineSeasonChanged"))
end

M.OnOnlineSeasonChanged = function(self, eventId, info)
	if not self.clubInfo then
		return
	end

	self:AskQueryClubHonors()
	self:SendClubInfoRefresh()
end

M.SetClubInfo = function(self, clubInfo)
	self.clubInfo = clubInfo

	self:RefreshMemberCache()
end

M.RefreshMemberCache = function(self)
	self.memberList = {}
	self.memberMap = {}
	self.myJob = ClubJobType and ClubJobType.Normal or 0

	if not self.clubInfo or table.isNilOrEmpty(self.clubInfo.Members) then
		return
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid

	for _, member in ipairs(self.clubInfo.Members) do
		table.insert(self.memberList, member)

		self.memberMap[member.Pid] = member

		if ulong.equals(member.Pid, myPid) then
			self.myJob = member.ClubJob
		end
	end
end

M.GetClubInfo = function(self)
	return self.clubInfo
end

M.GetPlayerClubTaskInfo = function(self)
	return self.playerClubTaskInfo
end

M.GetMemberList = function(self)
	return self.memberList
end

M.GetMember = function(self, pid)
	return self.memberMap[pid]
end

M.GetClubOwnerPid = function(self)
	if self.clubInfo ~= nil then
		return nil
	end

	for _, member in ipairs(self.memberList) do
		if member.ClubJob ~= ClubJobType.Owner then
			return member.Pid
		end
	end

	return nil
end

M.GetMyJobType = function(self)
	return self.myJob
end

M.HasClub = function(self)
	return self.clubInfo == nil
end

M.CanEditClub = function(self)
	return self.myJob ~= ClubJobType.Owner
end

M.HasAdminPrivilege = function(self)
	return self.myJob ~= ClubJobType.Owner or self.myJob ~= ClubJobType.Admin
end

M.CanManageMember = function(self, targetPid)
	if not self:HasClub() then
		return false
	end

	if not self:HasAdminPrivilege() then
		return false
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid

	if ulong.equals(myPid, targetPid) then
		return false
	end

	local targetMember = self:GetMember(targetPid)

	if not targetMember then
		return false
	end

	if self.myJob ~= ClubJobType.Admin then
		return targetMember.ClubJob ~= ClubJobType.Normal
	end

	return targetMember.ClubJob == ClubJobType.Owner
end

M.CanChangeOwner = function(self, targetPid)
	if self.myJob == ClubJobType.Owner then
		return false
	end

	local targetMember = self:GetMember(targetPid)

	if not targetMember then
		return false
	end

	return targetMember.ClubJob ~= ClubJobType.Admin
end

M.IsAdminPositionFull = function(self)
	if not self.clubInfo then
		return true
	end

	local adminCount = 0

	for _, member in ipairs(self.memberList) do
		if member.ClubJob ~= ClubJobType.Admin then
			adminCount = adminCount + 1
		end
	end

	return LTConfig.ClubConfig.ClubDefaultAdministratorNum > adminCount
end

M.GetLastLeaveClubTime = function(self)
	return gPlayerManager.infoLogin.bindData.LastLeaveClubTime or 0
end

M.SetLastLeaveClubTime = function(self, lastLeaveClubTime)
	gPlayerManager.infoLogin.bindData.LastLeaveClubTime = lastLeaveClubTime
end

M.GetJoinClubCdEndTime = function(self)
	local clubExitCd = LTConfig.ClubConfig.ClubExitCD
	local lastLeaveClubTime = self:GetLastLeaveClubTime()

	if lastLeaveClubTime < 0 then
		return 0
	end

	return lastLeaveClubTime + clubExitCd * gClientConst.SECONDS_PER_HOUR
end

M.IsJoinClubInCd = function(self)
	return gCS.TimeManager.ServerUnixTime <= self:GetJoinClubCdEndTime()
end

M.BuildClubSetting = function(self, autoJoin)
	return {
		AutoJoin = autoJoin ~= true
	}
end

M.GetSystemJobList = function(self)
	return self.clubInfo and self.clubInfo.SystemJobList or {}
end

M.GetCustomJobList = function(self)
	return self.clubInfo and self.clubInfo.CustomJobList or {}
end

M.GetClubJobById = function(self, jobId)
	if jobId ~= nil or jobId ~= 0 then
		return nil
	end

	for _, job in ipairs(self:GetSystemJobList()) do
		if job.Id ~= jobId then
			return job
		end
	end

	for _, job in ipairs(self:GetCustomJobList()) do
		if job.Id ~= jobId then
			return job
		end
	end

	return nil
end

M.GetJobDisplayName = function(self, member)
	if member ~= nil then
		return ""
	end

	if member.JobId == nil and member.JobId == 0 then
		local job = self:GetClubJobById(member.JobId)

		if job and not string.is_null_or_empty(job.Name) then
			return job.Name
		end
	end

	return LTConfig.ClubConfig.ClubMemberTypeText[member.ClubJob + 1] or ""
end

M.GetJobColor = function(self, member)
	if member ~= nil then
		return nil
	end

	local cfg = LTConfig.ClubConfig

	if member.JobId == nil and member.JobId == 0 then
		return cfg.CustomPositionColor
	end

	if member.ClubJob ~= ClubJobType.Owner then
		return cfg.PresidentColor
	elseif member.ClubJob ~= ClubJobType.Admin then
		return cfg.AdminColor
	end

	return cfg.MemberColor
end

M.GetJobHolderMember = function(self, jobId)
	if jobId ~= nil or jobId ~= 0 then
		return nil
	end

	for _, member in ipairs(self.memberList) do
		if member.JobId ~= jobId then
			return member
		end
	end

	return nil
end

M.GetMemberRemainingJobEditCount = function(self, pid)
	local member = self:GetMember(pid)
	local maxCount = LTConfig.ClubConfig.PositionEditMaxTime or 3

	if member ~= nil then
		return maxCount
	end

	return math.max(maxCount - (member.JobChangeCount or 0), 0)
end

M.GetClubHonors = function(self)
	return self.clubHonors
end

M.GetClubEventList = function(self)
	return self.clubEventList
end

M.SendClubInfoRefresh = function(self)
	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_LIST_REFRESH)
	gMessageManager:SendMessage(gEventConstants.CLUB_PERMISSION_CHANGED)
	gMessageManager:SendMessage(gEventConstants.CLUB_SELF_JOB_CHANGED, self.myJob)
end

M.OnSyncPlayerClubInfo = function(self, clubData)
	if clubData ~= nil then
		self:ResetClubData()
		gMessageManager:SendMessage(gEventConstants.CLUB_LEFT)
		gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)

		return
	end

	self:SetClubInfo(clubData)
	self:SendClubInfoRefresh()
end

M.OnSyncPlayerUpdateClubInfo = function(self, clubData)
	self:OnSyncPlayerClubInfo(clubData)
end

M.OnSyncPlayerClubSimpleInfo = function(self, taskInfo)
	self.playerClubTaskInfo = taskInfo

	gMessageManager:SendMessage(gEventConstants.CLUB_TASK_INFO_REFRESH)
end

M.OnSyncPlayerJoinedClub = function(self, clubData)
	self:SetClubInfo(clubData)
	self:SetLastLeaveClubTime(0)
	gMessageManager:SendMessage(gEventConstants.CLUB_JOINED)
	self:SendClubInfoRefresh()
end

M.OnSyncPlayerClubNameChanged = function(self, clubId, name)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	self.clubInfo.Name = name

	gMessageManager:SendMessage(gEventConstants.CLUB_NAME_CHANGED, name)
	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
end

M.OnSyncPlayerClubIconChanged = function(self, clubId, iconId)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	self.clubInfo.IconCfgId = iconId

	gMessageManager:SendMessage(gEventConstants.CLUB_ICON_CHANGED, iconId)
	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
end

M.OnSyncPlayerClubDeclarationChanged = function(self, clubId, declaration)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	self.clubInfo.Declaration = declaration

	gMessageManager:SendMessage(gEventConstants.CLUB_DECLARATION_CHANGED, declaration)
	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
end

M.OnSyncPlayerClubSettingChanged = function(self, clubId, setting)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	self.clubInfo.Setting = setting

	gMessageManager:SendMessage(gEventConstants.CLUB_SETTING_CHANGED, setting)
	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
end

M.OnSyncPlayerClubSettingsChanged = function(self, clubId, name, declaration, iconId, setting)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	self.clubInfo.Name = name
	self.clubInfo.Declaration = declaration
	self.clubInfo.IconCfgId = iconId
	self.clubInfo.Setting = setting

	gMessageManager:SendMessage(gEventConstants.CLUB_NAME_CHANGED, name)
	gMessageManager:SendMessage(gEventConstants.CLUB_DECLARATION_CHANGED, declaration)
	gMessageManager:SendMessage(gEventConstants.CLUB_ICON_CHANGED, iconId)
	gMessageManager:SendMessage(gEventConstants.CLUB_SETTING_CHANGED, setting)
	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
end

M.OnSyncPlayerNewMemberJoinedClub = function(self, newMember)
	if self.clubInfo ~= nil then
		return
	end

	table.insert(self.clubInfo.Members, newMember)
	self:RefreshMemberCache()
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_JOINED, newMember)
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_LIST_REFRESH)
	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
end

M.OnSyncPlayerMemberLeaveClub = function(self, clubId, memberPid, isKick)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid

	if ulong.equals(myPid, memberPid) then
		self:ResetClubData()
		gMessageManager:SendMessage(gEventConstants.CLUB_LEFT, isKick)
		gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)

		return
	end

	local newMemberList = {}

	for _, member in ipairs(self.clubInfo.Members) do
		if not ulong.equals(member.Pid, memberPid) then
			table.insert(newMemberList, member)
		end
	end

	self.clubInfo.Members = newMemberList

	self:RefreshMemberCache()
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_LEFT, memberPid)
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_LIST_REFRESH)
	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
end

M.OnSyncPlayerClubOwnerChanged = function(self, clubId, newOwner)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	local oldOwner = self.clubInfo.Owner
	self.clubInfo.Owner = newOwner

	for _, member in ipairs(self.clubInfo.Members) do
		if ulong.equals(member.Pid, newOwner) then
			member.ClubJob = ClubJobType.Owner
		end
	end

	self:RefreshMemberCache()
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_LIST_REFRESH)
	gMessageManager:SendMessage(gEventConstants.CLUB_PERMISSION_CHANGED)

	local myPid = gPlayerManager.infoLogin.bindData.pid

	if oldOwner ~= myPid or newOwner ~= myPid then
		gMessageManager:SendMessage(gEventConstants.CLUB_SELF_JOB_CHANGED, self.myJob)
	end

	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
end

M.OnSyncPlayerRemoveClubApplication = function(self, clubId, applicantPid)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	gMessageManager:SendMessage(gEventConstants.CLUB_APPLICATION_REFRESH, applicantPid)
end

M.OnSyncPlayerClubMemberJobChanged = function(self, clubId, memberPid, jobType, jobId)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	for _, member in ipairs(self.clubInfo.Members) do
		if ulong.equals(member.Pid, memberPid) then
			member.ClubJob = jobType
			member.JobId = jobId or 0

			break
		end
	end

	self:RefreshMemberCache()
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_LIST_REFRESH)

	if ulong.equals(memberPid, gPlayerManager.infoLogin.bindData.pid) then
		gMessageManager:SendMessage(gEventConstants.CLUB_PERMISSION_CHANGED)
		gMessageManager:SendMessage(gEventConstants.CLUB_SELF_JOB_CHANGED, self.myJob)
	end

	gMessageManager:SendMessage(gEventConstants.CLUB_INFO_REFRESH)
end

M.OnSyncPlayerClubCustomJobListChanged = function(self, clubId, jobList)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	self.clubInfo.CustomJobList = jobList

	gMessageManager:SendMessage(gEventConstants.CLUB_JOB_LIST_REFRESH)
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_LIST_REFRESH)
end

M.OnSyncPlayerClubSystemJobListChanged = function(self, clubId, jobList)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) then
		return
	end

	self.clubInfo.SystemJobList = jobList

	gMessageManager:SendMessage(gEventConstants.CLUB_JOB_LIST_REFRESH)
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_LIST_REFRESH)
end

M.OnSyncPlayerClubEvent = function(self, honorEvent)
	if honorEvent ~= nil then
		return
	end

	table.insert(self.clubEventList, honorEvent)

	local maxAmount = LTConfig.ClubConfig.HonorMaxAmount or 50

	while maxAmount >= #self.clubEventList do
		table.remove(self.clubEventList, 1)
	end

	gMessageManager:SendMessage(gEventConstants.CLUB_EVENT_REFRESH, honorEvent)
end

M.OnSyncPlayerClubMemberInfo = function(self, clubId, member)
	if not self.clubInfo or not ulong.equals(self.clubInfo.Id, clubId) or member ~= nil then
		return
	end

	for index, oldMember in ipairs(self.clubInfo.Members) do
		if ulong.equals(oldMember.Pid, member.Pid) then
			self.clubInfo.Members[index] = member

			break
		end
	end

	self:RefreshMemberCache()
	gMessageManager:SendMessage(gEventConstants.CLUB_MEMBER_LIST_REFRESH)
end

M.OnSyncPlayerLastLeaveClubTime = function(self, lastLeaveTime)
	self:SetLastLeaveClubTime(lastLeaveTime)
end

M.AskCreateClub = function(self, name, declaration, iconId, setting, callback)
	if self.t_waitCreateClubCallback then
		return
	end

	self.t_waitCreateClubCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskCreateClub", nil, , name, declaration, iconId, setting).Callback = function (err, clubInfo)
		self.t_waitCreateClubCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		self:OnSyncPlayerJoinedClub(clubInfo)
		gUtils:InvokeNullableFunction(callback, err, clubInfo)
	end
end

M.AskLeaveClub = function(self, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitLeaveClubCallback then
		return
	end

	self.t_waitLeaveClubCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskLeaveClub", nil, , self.clubInfo.Id).Callback = function (err)
		self.t_waitLeaveClubCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		self.clubInfo = nil

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskJoinClub = function(self, memberPid, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitJoinClubCallback then
		return
	end

	self.t_waitJoinClubCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskJoinClub", nil, , self.clubInfo.Id, memberPid).Callback = function (err)
		self.t_waitJoinClubCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskApplyJoinClub = function(self, clubId, callback)
	if self.t_waitApplyJoinClubCallback then
		return
	end

	self.t_waitApplyJoinClubCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskApplyJoinClub", nil, , clubId).Callback = function (err)
		self.t_waitApplyJoinClubCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskApplyJoinClubWithOneKey = function(self, clubIdList, callback)
	if self.t_waitApplyJoinClubWithOneKeyCallback then
		return
	end

	self.t_waitApplyJoinClubWithOneKeyCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskApplyJoinClubWithOneKey", nil, , clubIdList).Callback = function (err)
		self.t_waitApplyJoinClubWithOneKeyCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskKickMemberFromClub = function(self, memberPid, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitKickMemberFromClubCallback then
		return
	end

	self.t_waitKickMemberFromClubCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskKickMemberFromClub", nil, , self.clubInfo.Id, memberPid).Callback = function (err)
		self.t_waitKickMemberFromClubCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskChangeClubOwner = function(self, newOwnerPid, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitChangeClubOwnerCallback then
		return
	end

	self.t_waitChangeClubOwnerCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskChangeClubOwner", nil, , self.clubInfo.Id, newOwnerPid).Callback = function (err)
		self.t_waitChangeClubOwnerCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskChangeClubMemberJobType = function(self, memberPid, jobType, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitChangeClubMemberJobTypeCallback then
		return
	end

	self.t_waitChangeClubMemberJobTypeCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskChangeClubMemberJobType", nil, , self.clubInfo.Id, memberPid, jobType).Callback = function (err)
		self.t_waitChangeClubMemberJobTypeCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskChangeClubName = function(self, name, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitChangeClubNameCallback then
		return
	end

	self.t_waitChangeClubNameCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskChangeClubName", nil, , self.clubInfo.Id, name).Callback = function (err)
		self.t_waitChangeClubNameCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskChangeClubDeclaration = function(self, declaration, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitChangeClubDeclarationCallback then
		return
	end

	self.t_waitChangeClubDeclarationCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskChangeClubDeclaration", nil, , self.clubInfo.Id, declaration).Callback = function (err)
		self.t_waitChangeClubDeclarationCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskChangeClubIcon = function(self, iconCfgId, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitChangeClubIconCallback then
		return
	end

	self.t_waitChangeClubIconCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskChangeClubIcon", nil, , self.clubInfo.Id, iconCfgId).Callback = function (err)
		self.t_waitChangeClubIconCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskChangeClubSetting = function(self, setting, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitChangeSettingCallback then
		return
	end

	self.t_waitChangeSettingCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskChangeClubSetting", nil, , self.clubInfo.Id, setting).Callback = function (err)
		self.t_waitChangeSettingCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskChangeClubSettings = function(self, name, declaration, iconCfgId, setting, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitChangeClubSettingsCallback then
		return
	end

	self.t_waitChangeClubSettingsCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskChangeClubSettings", nil, , self.clubInfo.Id, name, declaration, iconCfgId, setting).Callback = function (err)
		self.t_waitChangeClubSettingsCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskQueryClubInfo = function(self, clubId, callback)
	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskQueryClubInfo", nil, , clubId).Callback = function (err, clubInfo)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err, clubInfo)
	end
end

M.AskQueryClubInfoByName = function(self, name, callback)
	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskQueryClubInfoByName", nil, , name).Callback = function (err, clubInfoList)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err, clubInfoList)
	end
end

M.AskQueryRecommendClubs = function(self, callback)
	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskQueryRecommendClubs", nil, ).Callback = function (err, clubList)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err, clubList)
	end
end

M.AskGetClubApplicationList = function(self, callback)
	if not self.clubInfo then
		return
	end

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskGetClubApplicationList", nil, , self.clubInfo.Id).Callback = function (err, applicationList)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		SGUI.RedDotMgr.LuaSetRedDot(applicationList.Count >= 0, "Club/Club.MemberTab/Club.MemberTab.Application")
		gUtils:InvokeNullableFunction(callback, err, applicationList)
	end
end

M.AskGetClubApplicationCount = function(self, callback)
	if not self.clubInfo then
		return
	end

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskGetClubApplicationCount", nil, , self.clubInfo.Id).Callback = function (err, count)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		SGUI.RedDotMgr.LuaSetRedDot(count >= 0, "Club/Club.MemberTab/Club.MemberTab.Application")
		gUtils:InvokeNullableFunction(callback, err, count)
	end
end

M.AskRemoveClubApplication = function(self, memberPid, callback)
	if not self.clubInfo then
		return
	end

	if self.t_waitRemoveClubApplicationCallback then
		return
	end

	self.t_waitRemoveClubApplicationCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskRemoveClubApplication", nil, , self.clubInfo.Id, memberPid).Callback = function (err)
		self.t_waitRemoveClubApplicationCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskTakeClubWeeklyAward = function(self, clubId, cfgId, callback)
	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskTakeClubWeeklyAward", nil, , clubId, cfgId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskQueryClubHonors = function(self, callback)
	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskQueryClubHonors", nil, ).Callback = function (err, honors)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		self.clubHonors = honors

		gMessageManager:SendMessage(gEventConstants.CLUB_HONOR_REFRESH)
		gUtils:InvokeNullableFunction(callback, err, honors)
	end
end

M.AskGetClubEvents = function(self, callback)
	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskGetClubEvents", nil, ).Callback = function (err, eventList)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		local sortedList = {}

		if eventList then
			for _, honorEvent in ipairs(eventList) do
				table.insert(sortedList, honorEvent)
			end

			table.sort(sortedList, function (a, b)
				return (a.Time or 0) <= (b.Time or 0)
			end)
		end

		self.clubEventList = sortedList
		local maxAmount = LTConfig.ClubConfig.HonorMaxAmount or 50

		while maxAmount >= #self.clubEventList do
			table.remove(self.clubEventList, 1)
		end

		gMessageManager:SendMessage(gEventConstants.CLUB_EVENT_REFRESH)
		gUtils:InvokeNullableFunction(callback, err, sortedList)
	end
end

M.AskClubCreateCustomJob = function(self, jobName, callback)
	if self.t_waitClubCreateCustomJobCallback then
		return
	end

	self.t_waitClubCreateCustomJobCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskClubCreateCustomJob", nil, , jobName).Callback = function (err, job)
		self.t_waitClubCreateCustomJobCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err, job)
	end
end

M.AskClubChangeJobName = function(self, jobId, jobName, callback)
	if self.t_waitClubChangeJobNameCallback then
		return
	end

	self.t_waitClubChangeJobNameCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskClubChangeJobName", nil, , jobId, jobName).Callback = function (err, job)
		self.t_waitClubChangeJobNameCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err, job)
	end
end

M.AskClubDeleteCustomJob = function(self, customJobId, callback)
	if self.t_waitClubDeleteCustomJobCallback then
		return
	end

	self.t_waitClubDeleteCustomJobCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskClubDeleteCustomJob", nil, , customJobId).Callback = function (err)
		self.t_waitClubDeleteCustomJobCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskClubAssignCustomJob = function(self, pid, jobId, callback)
	if self.t_waitClubAssignCustomJobCallback then
		return
	end

	self.t_waitClubAssignCustomJobCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskClubAssignCustomJob", nil, , pid, jobId).Callback = function (err, job)
		self.t_waitClubAssignCustomJobCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err, job)
	end
end

M.AskClubResignCustomJob = function(self, pid, callback)
	if self.t_waitClubResignCustomJobCallback then
		return
	end

	self.t_waitClubResignCustomJobCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskClubResignCustomJob", nil, , pid).Callback = function (err)
		self.t_waitClubResignCustomJobCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

M.AskClubGiveUpCustomJob = function(self, callback)
	if self.t_waitClubGiveUpCustomJobCallback then
		return
	end

	self.t_waitClubGiveUpCustomJobCallback = true

	gRpcUtils:SafeQueueAsk(gClientToGameDelegate, "AskClubGiveUpCustomJob", nil, ).Callback = function (err)
		self.t_waitClubGiveUpCustomJobCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gUtils:InvokeNullableFunction(callback, err)

			return
		end

		gUtils:InvokeNullableFunction(callback, err)
	end
end

gClubManager = gClubManager or C_ClubManager.new()
