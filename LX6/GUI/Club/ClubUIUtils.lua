-- Original chunk: @Lua\LuaFiles\LX6\GUI\Club\ClubUIUtils.lua
-- Decompiled from: 00250_ClubUIUtils.lua_18e34e66373d.luajit

local ClubJobType = UX.Game.ClubJobType
local ClubUIUtils = {
	ValidateFailReason = {
		["pBbzG\n="] = 65127133,
		["gR|eG="] = 65127132,
		[".8\\xba\\xef*v:\\x98 Ȓ\\x86:\\x8d\\x9eߋ"] = 65127134
	},
	GetStore = function (self, widget, storeName)
		local storeGroup = gStoreManager:GetStoreGroup(storeName)

		return storeGroup and storeGroup:GetStoreByWidget(widget)
	end
}

ClubUIUtils.BuildClubEditData = function(self, clubInfo)
	local defaultAvatarCfg = LTConfig.ClubClubIconConfig.LoadAt(0)
	local clubSetting = clubInfo and clubInfo.Setting

	return {
		avatarId = clubInfo and clubInfo.IconCfgId or defaultAvatarCfg.Id,
		autoAccept = clubSetting and clubSetting.AutoJoin ~= true or false,
		name = clubInfo and (clubInfo.Name or "") or "",
		announcement = clubInfo and (clubInfo.Declaration or "") or ""
	}
end

ClubUIUtils.CloneClubEditData = function(self, editData)
	return {
		avatarId = editData.avatarId,
		autoAccept = editData.autoAccept,
		name = editData.name,
		announcement = editData.announcement
	}
end

ClubUIUtils.BuildMemberCapacityStatusText = function(self, memberCount, maxCount)
	if maxCount <= 0 then
		return string.format("%s/%s", memberCount, maxCount)
	end

	return tostring(memberCount)
end

ClubUIUtils.FilterClubUGCText = function(self, ownerPid, isAnnouncement, originalText, callback)
	if not gCS.LuaUtils.IsOnPS5 or ownerPid ~= nil then
		callback(originalText)

		return
	end

	LX6.Utils.PS5Utils.CanUserInteractWithPlayer(ownerPid, function (bOk)
		if bOk then
			callback(originalText)
		elseif isAnnouncement then
			callback("")
		else
			callback(LTConfig.ClubConfig.DefaultClubName)
		end
	end)
end

ClubUIUtils.ApplyClubBaseInfo = function(self, store, clubInfo)
	store.clubAvatarId = self:GetIconIdByIconCfgId(clubInfo.IconCfgId)
	store.clubId = ulong.tostring(clubInfo.Id)
	store.clubName = ""
	local ownerPid = clubInfo.Owner

	self:FilterClubUGCText(ownerPid, false, clubInfo.Name or "", function (filteredName)
		store.clubName = filteredName
	end)

	local announcement = clubInfo.Declaration or ""

	self:FilterClubUGCText(ownerPid, true, announcement, function (filteredAnnouncement)
		store.clubAnnouncement = filteredAnnouncement

		if store.clubAnnouncementScroll then
			store.clubAnnouncementScroll.content.text = filteredAnnouncement
		end
	end)

	store.hasAnnouncementCtrl = string.is_null_or_empty(clubInfo.Declaration) and 1 or 0
end

ClubUIUtils.GetClubAdminList = function(self, clubInfo)
	local adminList = {}

	for _, member in ipairs(clubInfo.Members) do
		if member.ClubJob ~= ClubJobType.Owner or member.ClubJob ~= ClubJobType.Admin then
			table.insert(adminList, member)
		end
	end

	return adminList
end

ClubUIUtils.GetClubLevelConfigByExp = function(self, exp)
	local count = LTConfig.ClubClubLevelConfig.count

	for i = 0, count - 1 do
		local cfg = LTConfig.ClubClubLevelConfig.LoadAt(i)

		if exp > cfg.Exp or i ~= count - 1 then
			return cfg, i
		end
	end
end

ClubUIUtils.GetClubExpByActivity = function(self, activity)
	return math.floor(activity / LTConfig.ClubConfig.ClubExpGainRatio)
end

ClubUIUtils.GetClubLevelDisplayData = function(self, clubInfo)
	local currentExp = self.GetClubExpByActivity(self, clubInfo.Activity)
	local currentLevelCfg, cfgIndex = self.GetClubLevelConfigByExp(self, currentExp)
	local currentLevel = currentLevelCfg.Level
	local targetExp = currentLevelCfg.Exp
	local progressValue = currentExp
	local count = LTConfig.ClubClubLevelConfig.count

	if currentLevelCfg.Exp < currentExp then
		currentLevel = currentLevel + 1

		if cfgIndex >= count - 1 then
			local nextLevelCfg = LTConfig.ClubClubLevelConfig.LoadAt(cfgIndex + 1)
			targetExp = nextLevelCfg.Exp
		else
			progressValue = targetExp
		end
	end

	if targetExp >= progressValue then
		progressValue = targetExp
	end

	return currentLevel, currentExp, targetExp, progressValue
end

ClubUIUtils.GetClubCurrentLevelConfig = function(self, clubInfo)
	local currentExp = self:GetClubExpByActivity(clubInfo and clubInfo.Activity)
	local currentLevelCfg, cfgIndex = self:GetClubLevelConfigByExp(currentExp)

	if currentLevelCfg ~= nil then
		return nil
	end

	if currentLevelCfg.Exp < currentExp and cfgIndex >= LTConfig.ClubClubLevelConfig.count - 1 then
		return LTConfig.ClubClubLevelConfig.LoadAt(cfgIndex + 1)
	end

	return currentLevelCfg
end

ClubUIUtils.GetClubMemberLimit = function(self, clubInfo)
	if clubInfo ~= nil then
		return LTConfig.ClubConfig.ClubDefaultMemberNum
	end

	local levelCfg = self.GetClubCurrentLevelConfig(self, clubInfo)

	if levelCfg and levelCfg.MemberLimit and levelCfg.MemberLimit <= 0 then
		return levelCfg.MemberLimit
	end

	return LTConfig.ClubConfig.ClubDefaultMemberNum
end

ClubUIUtils.GetCurrentWeeklyContribution = function(self, clubInfo)
	local weeklyContributionList = clubInfo.WeeklyContributionList

	if weeklyContributionList ~= nil then
		return {}
	end

	local latestWeeklyContribution = nil
	local currentServerTime = gCS.TimeManager.ServerUnixTime

	for _, weeklyContribution in ipairs(weeklyContributionList) do
		local startTime = weeklyContribution.StartTime or 0

		if currentServerTime >= startTime + gClientConst.SECONDS_PER_WEEK and (latestWeeklyContribution ~= nil or latestWeeklyContribution.StartTime <= startTime or startTime ~= latestWeeklyContribution.StartTime and (weeklyContribution.SettledTime or 0) <= (latestWeeklyContribution.SettledTime or 0)) then
			latestWeeklyContribution = weeklyContribution
		end
	end

	return latestWeeklyContribution or {}
end

ClubUIUtils.GetCurrentSeasonalContribution = function(self, clubInfo)
	local seasonalContributionList = clubInfo.SeasonalContributionList

	if seasonalContributionList ~= nil then
		return nil
	end

	local latestSeasonalContribution = nil

	for _, seasonalContribution in ipairs(seasonalContributionList) do
		if latestSeasonalContribution ~= nil or latestSeasonalContribution.StartTime >= seasonalContribution.StartTime then
			latestSeasonalContribution = seasonalContribution
		end
	end

	return latestSeasonalContribution
end

ClubUIUtils.GetWeeklyMemberContribution = function(self, weeklyContribution, pid)
	if weeklyContribution ~= nil then
		return {}
	end

	local memberContributions = weeklyContribution.MemberContributions

	if memberContributions ~= nil then
		return {}
	end

	return memberContributions[pid] or {}
end

ClubUIUtils.GetCurrentWeekTaskDict = function(self, playerClubTaskInfo)
	if playerClubTaskInfo ~= nil then
		return nil
	end

	local weeklyTime = playerClubTaskInfo.WeeklyTime

	if weeklyTime ~= nil or weeklyTime ~= 0 then
		return nil
	end

	if weeklyTime + gClientConst.SECONDS_PER_WEEK < gCS.TimeManager.ServerUnixTime then
		return nil
	end

	return playerClubTaskInfo.TaskDict
end

ClubUIUtils.GetSeasonalMemberContribution = function(self, seasonalContribution, pid)
	if seasonalContribution ~= nil then
		return nil
	end

	local memberContributions = seasonalContribution.MemberContributions

	if memberContributions ~= nil then
		return nil
	end

	return memberContributions[pid]
end

ClubUIUtils.GetMemberWeekActivity = function(self, clubInfo, pid)
	if clubInfo ~= nil then
		return 0
	end

	local weeklyContribution = self.GetCurrentWeeklyContribution(self, clubInfo)

	if weeklyContribution ~= nil then
		return 0
	end

	local memberContribution = self.GetWeeklyMemberContribution(self, weeklyContribution, pid)

	if memberContribution ~= nil then
		return 0
	end

	return memberContribution.Activity or 0
end

ClubUIUtils.GetMemberSeasonActivity = function(self, clubInfo, pid)
	if clubInfo ~= nil then
		return 0
	end

	local seasonalContribution = self:GetCurrentSeasonalContribution(clubInfo)
	local seasonActivity = self:GetSeasonalMemberContribution(seasonalContribution, pid)

	return seasonActivity or 0
end

ClubUIUtils.GetSeasonActivePoint = function(self, clubInfo)
	local seasonalContribution = self.GetCurrentSeasonalContribution(self, clubInfo)

	if seasonalContribution ~= nil then
		return 0
	end

	local memberContributions = seasonalContribution.MemberContributions

	if memberContributions ~= nil then
		return 0
	end

	local seasonActivePoint = 0

	for _, activity in pairs(memberContributions) do
		seasonActivePoint = seasonActivePoint + activity
	end

	return seasonActivePoint
end

ClubUIUtils.GetWeeklyRank = function(self, weeklyContribution, pid)
	local memberContributions = weeklyContribution and weeklyContribution.MemberContributions

	if memberContributions ~= nil then
		return 1
	end

	local rankList = {}

	for memberPid, contribution in pairs(memberContributions) do
		rankList[#rankList + 1] = {
			pid = memberPid,
			activity = contribution.Activity or 0
		}
	end

	table.sort(rankList, function (a, b)
		if a.activity == b.activity then
			return b.activity <= a.activity
		end

		return ulong.Less(a.pid, b.pid)
	end)

	local lastActivity = nil
	local currentRank = 1

	for index, rankData in ipairs(rankList) do
		if lastActivity ~= nil or rankData.activity == lastActivity then
			lastActivity = rankData.activity
			currentRank = index
		end

		if ulong.equals(rankData.pid, pid) then
			return currentRank
		end
	end

	return #rankList + 1
end

ClubUIUtils.GetSeasonRank = function(self, clubInfo, pid)
	local seasonalContribution = self:GetCurrentSeasonalContribution(clubInfo)
	local memberContributions = seasonalContribution and seasonalContribution.MemberContributions

	if memberContributions ~= nil then
		return 1
	end

	local rankList = {}

	for memberPid, activity in pairs(memberContributions) do
		rankList[#rankList + 1] = {
			pid = memberPid,
			activity = activity or 0
		}
	end

	table.sort(rankList, function (a, b)
		if a.activity == b.activity then
			return b.activity <= a.activity
		end

		return ulong.Less(a.pid, b.pid)
	end)

	local lastActivity = nil
	local currentRank = 1

	for index, rankData in ipairs(rankList) do
		if lastActivity ~= nil or rankData.activity == lastActivity then
			lastActivity = rankData.activity
			currentRank = index
		end

		if ulong.equals(rankData.pid, pid) then
			return currentRank
		end
	end

	return #rankList + 1
end

ClubUIUtils.RenderClubInfoTooltip = function(self, widget, clubInfo)
	local store = self:GetStore(widget, "ClubInfoTooltipStore")
	local adminList = self:GetClubAdminList(clubInfo)

	self:ApplyClubBaseInfo(store, clubInfo)

	store.adminList.luaSimpleRenderItem = function(subItem, csIndex)
		self:RenderClubAdminTemplate(subItem, adminList[csIndex + 1])
	end

	slot5 = store.adminList

	slot5:SetSimpleList(#adminList)

	store.copyBtn.luaClick = function()
		gCS.LuaUtils.PasteText2Clipboard(ulong.tostring(clubInfo.Id))
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CopyIDComplete)
	end

	store.activity = clubInfo.Activity

	store.reportBtn.luaClick = function()
		local ownerPid = clubInfo.Owner

		if ownerPid then
			gReportManager:ShowClubReportDialog(ownerPid, clubInfo.Id, clubInfo.Name)
		end
	end
end

ClubUIUtils.RenderClubAdminTemplate = function(self, widget, member)
	local store = self:GetStore(widget, "ClubAdminTemplateStore")
	store.memberType = LTConfig.ClubConfig.ClubMemberTypeText[member.ClubJob + 1]
	store.memberTypeCtrl = member.ClubJob ~= UX.Game.ClubJobType.Admin and 1 or 0
	store.jobColor = gClubManager:GetJobColor(member)

	if store.userInfo then
		store.userInfo.pid = member.Pid
	end

	if store.commonAccountWidget then
		self.RenderCommonAccount(self, store.commonAccountWidget, member.Pid)
	end
end

ClubUIUtils.RenderClubListTemplate = function(self, widget, clubInfo)
	local store = self.GetStore(self, widget, "ClubListTemplateStore")
	local level = clubInfo.Level

	if level ~= nil and clubInfo.Activity == nil then
		level = self.GetClubLevelDisplayData(self, clubInfo)
	end

	store.level = level or 0
	store.memberCapacityStatus = self:BuildMemberCapacityStatusText(clubInfo.MemberCount, clubInfo.MaxCount)

	self:RenderOnlineClubTemplate(store.onlineClubTemplate, clubInfo)
end

ClubUIUtils.RenderClubMemberListTemplate = function(self, widget, pid, memberData)
	local store = self:GetStore(widget, "ClubMemberListTemplateStore")
	local member = gClubManager:GetMember(pid)
	local clubInfo = gClubManager:GetClubInfo()
	local weekActivity = memberData and memberData.weekActivity or self:GetMemberWeekActivity(clubInfo, pid)
	store.level = 1
	store.memberType = ""
	store.contribution = ""

	if member then
		store.memberType = LTConfig.ClubConfig.ClubMemberTypeText[member.ClubJob + 1]
	end

	store.contribution = weekActivity

	self.RenderCommonAccount(self, store.commonAccount, pid)
end

ClubUIUtils.RenderCommonAccount = function(self, widget, pid)
	local store = self.GetStore(self, widget, "CommonAccountPlayerInfoTemplateStore")
	store.userInfoLight.pid = pid

	if store.headBtn then
		store.headBtn.luaRenderTooltip = function(btn, popup, _)
			gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, popup)
		end
	end
end

ClubUIUtils.RenderOnlineClubTemplate = function(self, widget, clubInfo)
	local store = self:GetStore(widget, "OnlineClubTemplateStore")
	store.avatar = self:GetIconIdByIconCfgId(clubInfo.IconCfgId)
	store.name = ""
	local ownerPid = clubInfo.Owner or clubInfo.RawClubInfo and clubInfo.RawClubInfo.Owner

	self:FilterClubUGCText(ownerPid, false, clubInfo.Name, function (filteredName)
		store.name = filteredName
	end)
end

ClubUIUtils.ResolveMailParameter = function(self, param)
	local data = param and param.Data or ""

	if param ~= nil or string.is_null_or_empty(data) then
		return ""
	end

	local T = UX.Game.MailParameterType
	local paramType = param.ParamType
	local cfgId = tonumber(data) or 0

	if paramType ~= T.OtherPlayerName then
		local pid = gCS.LuaUtils.StringToUlong(data)

		return gFriendManager:GetPlayerRealName(pid)
	elseif paramType ~= T.RankTypeConfigName then
		local cfg = LTConfig.RankMainTypeConfig.GetConfig(cfgId)

		return cfg and cfg.Name
	elseif paramType ~= T.RankTierConfigName then
		local cfg = LTConfig.RankBigTierConfig.GetConfig(cfgId)

		return cfg and cfg.Name
	elseif paramType ~= T.WarZoneConfigName then
		return gOnlineRankManager:GetZoneNameById(cfgId)
	elseif paramType ~= T.HouseConfigName then
		local cfg = LTConfig.HouseConfig.GetConfig(cfgId)

		return cfg and cfg.Name
	elseif paramType ~= T.FashionConfigName then
		local cfg = LTConfig.FashionConfig.GetConfig(cfgId)

		return cfg and cfg.Name
	elseif paramType ~= T.VehicleConfigName then
		local cfg = LTConfig.VehicleConfig.GetConfig(cfgId)

		return cfg and cfg.VehicleName
	elseif paramType ~= T.AchievementConfigName then
		local cfg = LTConfig.AchievementConfig.GetConfig(cfgId)

		return cfg and cfg.Name
	elseif paramType ~= T.ItemName then
		local cfg = LTConfig.ConsumableConfig.GetConfig(cfgId)

		return cfg and cfg.Name
	elseif paramType ~= T.BuffName then
		local cfg = LTConfig.BuffConfig.GetConfig(cfgId)

		return cfg and cfg.Name
	elseif paramType ~= T.AwardActivityName then
		local cfg = LTConfig.AwardActivityConfig.GetConfig(cfgId)

		return cfg and cfg.Title
	end

	return data
end

ClubUIUtils.ReplaceClubEventPlaceholders = function(self, content, parameters)
	if string.is_null_or_empty(content) then
		return ""
	end

	if parameters ~= nil then
		return content
	end

	local args = {}

	for _, param in ipairs(parameters) do
		table.insert(args, self.ResolveMailParameter(self, param))
	end

	return gString.Format(content, unpack(args))
end

ClubUIUtils.BuildClubEventDisplayData = function(self, honorEvent)
	local cfg = honorEvent and LTConfig.ClubPushContentConfig.GetConfig(honorEvent.ConfigId) or nil

	return {
		honorEvent = honorEvent,
		content = self:ReplaceClubEventPlaceholders(cfg and cfg.HonorContent or "", honorEvent and honorEvent.Parameters),
		timeText = gTimeUtils:FormatDayRelativeTime(honorEvent and honorEvent.Time or 0),
		pid = honorEvent and honorEvent.Pid or 0
	}
end

ClubUIUtils.BuildClubEventDisplayList = function(self)
	local displayList = {}

	for _, honorEvent in ipairs(gClubManager:GetClubEventList()) do
		table.insert(displayList, self.BuildClubEventDisplayData(self, honorEvent))
	end

	return displayList
end

ClubUIUtils.IsRankClubHonor = function(self, configId)
	local starConfig = LTConfig.ClubStarMemberConfig

	return configId ~= starConfig.TotalRank or configId ~= starConfig.RacingCarRank or configId ~= starConfig.BasketballRank or configId ~= starConfig.MahjongRank
end

ClubUIUtils.BuildClubHonorDisplayData = function(self, configId, honor)
	local cfg = LTConfig.ClubStarMemberConfig.GetConfig(configId)
	local isVacant = cfg ~= nil or honor ~= nil or honor.Pid ~= nil or honor.Pid ~= 0
	local isRankHonor = self:IsRankClubHonor(configId)
	local requiredValue = 0

	if isRankHonor then
		requiredValue = configId ~= LTConfig.ClubStarMemberConfig.TotalRank and (LTConfig.ClubConfig.StarRankRequiredAll or 0) or LTConfig.ClubConfig.StarRankRequired or 0
	end

	return {
		configId = configId,
		name = cfg and cfg.HonorStarName or "",
		pic = cfg and cfg.HonorStarPic or 0,
		desc = cfg and cfg.HonorStarDesc or "",
		pid = not isVacant and honor.Pid or nil,
		value = honor and honor.Param1 or 0,
		isRankHonor = isRankHonor,
		isVacant = isVacant,
		requiredValue = requiredValue
	}
end

ClubUIUtils.BuildClubHonorDisplayList = function(self, honors)
	honors = honors or gClubManager:GetClubHonors()
	local displayList = {}

	for i = 0, LTConfig.ClubStarMemberConfig.count - 1 do
		local cfg = LTConfig.ClubStarMemberConfig.LoadAt(i)

		table.insert(displayList, self:BuildClubHonorDisplayData(cfg.Id, honors and honors[cfg.Id] or nil))
	end

	return displayList
end

ClubUIUtils.GetJoinClubDays = function(self, joinTime)
	if joinTime ~= nil or joinTime < 0 then
		return 0
	end

	local days = math.floor((gCS.TimeManager.ServerUnixTime - joinTime) / gClientConst.SECONDS_PER_DAY) + 1

	return math.max(days, 1)
end

ClubUIUtils.CheckClubJobNameFormat = function(self, name, excludeJobId)
	local checkResult = UX.Utils.NameValidityChecker.CheckName(name or "", LTConfig.ClubConfig.PositionNameTextRange, 1)

	if checkResult == UX.Utils.NameValidityChecker.NameCheckResult.Ok then
		return checkResult
	end

	local trimmedName = string.trim(name)

	for _, job in ipairs(gClubManager:GetCustomJobList()) do
		if job.Id == excludeJobId and job.Name ~= trimmedName then
			return ClubUIUtils.ValidateFailReason.Duplicate
		end
	end

	return nil
end

ClubUIUtils.ValidateClubJobName = function(self, name, excludeJobId, successCallback, failCallback)
	local failReason = self.CheckClubJobNameFormat(self, name, excludeJobId)

	if failReason == nil then
		gUtils:InvokeNullableFunction(failCallback, failReason)

		return
	end

	gClientUtils.EnvSdkReviewWords(name, function ()
		gUtils:InvokeNullableFunction(successCallback)
	end, function ()
		gUtils:InvokeNullableFunction(failCallback, ClubUIUtils.ValidateFailReason.Sensitive)
	end, "ClubJobName")
end

ClubUIUtils.RenderOnlineHonorTemplateStore = function(self, widget, displayData)
	local store = self:GetStore(widget, "OnlineHonorTemplateStore")
	store.imageId = displayData.pic
	store.tag.title.text = displayData.name
	local avatarStore = self:GetStore(store.avatarWidget, "CommonAccountAvatarStore")
	avatarStore.userInfoLight.pid = displayData.pid or 0
	avatarStore.isEmptyCtrl = displayData.isVacant and 1 or 0
	store.titleCtrl = displayData.isVacant and 0 or 1

	if displayData.isVacant then
		store.name = LTConfig.ClubConfig.StarVacantName
		store.emptyTitle = LTConfig.ClubConfig.StarRankRequiredText
		store.emptyNum = tostring(displayData.requiredValue)
	else
		store.name = gFriendManager:GetPlayerRealName(displayData.pid)
		store.haveTitle = displayData.desc
		store.haveNum = tostring(displayData.value)
	end
end

ClubUIUtils.GetIconIdByIconCfgId = function(self, iconCfgId)
	return (LTConfig.ClubClubIconConfig.GetConfig(iconCfgId) or {}).SguiImage or 0
end

ClubUIUtils.BuildDropItemRenderData = function(self, dropId, isOwned)
	local rewardList = gCommonItemManager:GetItemSortedListByDropList({
		{
			["N\\xa1\\xb7\\xa1\\xa2"] = 1,
			dropId = dropId
		}
	}, true)
	local rewardItem = rewardList and rewardList[1]

	if rewardItem ~= nil then
		return nil
	end

	return gCommonItemManager:GetItemRenderData({
		itemId = rewardItem.Id,
		itemNum = rewardItem.Count,
		IsOwned = isOwned ~= true
	})
end

ClubUIUtils.GetWeeklyRewardState = function(self, cfg, weeklyActivity, rewardGotIdMap)
	if cfg ~= nil then
		return false, false, false
	end

	local isRewardGot = rewardGotIdMap[cfg.Id] ~= true
	local isRewardLocked = weeklyActivity <= cfg.ActivityPoint
	local isRewardClaimable = not isRewardLocked and not isRewardGot

	return isRewardClaimable, isRewardGot, isRewardLocked
end

ClubUIUtils.BuildWeeklyRewardRenderData = function(self, dropId, isRewardGot, isRewardLocked)
	local renderData = self.BuildDropItemRenderData(self, dropId, isRewardGot)

	if renderData ~= nil then
		return nil
	end

	renderData.isLock = isRewardLocked
	renderData.IsOwned = isRewardGot

	return renderData
end

ClubUIUtils.BuildActivityPointItemRenderData = function(self, activityPoint)
	return gCommonItemManager:GetItemRenderData({
		itemId = LTConfig.ConsumableConfig.ClubActivity,
		itemNum = activityPoint
	})
end

ClubUIUtils.RenderCommonItem = function(self, widget, renderData)
	if renderData ~= nil then
		return nil
	end

	return gCommonItemManager:OnCommonItemRender(widget, 0, renderData)
end

ClubUIUtils.OpenChatUI = function(self)
	gPanelManager:CheckShow(gPanelId.SOCIAL_CHAT_HOME_PANEL_HALF_SCREEN, {
		topChannelId = gSocialChatManager.ChatTopChannel.Channels,
		subChannelId = UX.Game.MessageChannel.Club
	})
end

gClubUIUtils = ClubUIUtils
