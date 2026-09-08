-- Original chunk: @Lua\LuaFiles\LX6\Manager\Social\SocialFriendManager.lua
-- Decompiled from: 00266_SocialFriendManager.lua_f53b03dae2ad.luajit

C_SocialFriendManager = DefClass("C_SocialFriendManager", C_SocialFriendManager)
local M = C_SocialFriendManager

M.ctor = function(self)
	self.friendTabType = {
		["\\xbd8!<s\\xbbS\\xd02\\xa4\\xbd"] = 3,
		["uHǸ\\x8a\\x94\r\\xda\\xfc"] = 1,
		["bChO\\<"] = 4,
		["dUc|^=,"] = 2,
		["\\xbc&%>l\\x98f\\xcb8\\xbf\\xa9"] = 5,
		["$\\xf1V)\\xd4.\\xb3P\\xb4S\\xa3\\xa2"] = 0
	}
	self.friendList = {}
	self.friendApplicationList = {}
	self.isRejectAllFriendApply = true
	self.hasRequestedApplicationList = false
	self.unlockedNameEffects = nil
	self.selectedNameEffect = nil
	self._pendingNameRefresh = {}

	gMessageManager:AddMessageListener(gEventConstants.LOAD_SCENE_COMPLETED, function ()
		self:OnLoadSceneComplete()
	end)
	gMessageManager:AddMessageListener(gEventConstants.ON_PS5_INVITE_ELIGIBILITY_CHANGED, function ()
		self:OnSafetySnapshotReady()
	end)

	self.debug = false
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self:ClearData()

		self.hasRequestedApplicationList = false
	end
end

M.OnLoadSceneComplete = function(self)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	if not self.hasRequestedApplicationList then
		self.hasRequestedApplicationList = true

		self:RequestFriendApplicationList()
	end

	if not self.unlockedNameEffects then
		gClientToGameDelegate:AskQueryPlayerUnlockNameEffect().Callback = function (err, list)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			else
				self.unlockedNameEffects = {}

				for k, v in pairs(list) do
					if k and v then
						self.unlockedNameEffects[k] = v
					end
				end
			end
		end

		gHunLunManager:GetPersonalInfo(gPlayerManager.infoLogin.bindData.pid, function (data)
			if data then
				self.selectedNameEffect = data.NameEffect
			else
				print_error("SocialFriendManager: 在查询已佩戴的彩色昵称时获取玩家信息失败 pid=", ulong.tostring(pid))
			end
		end)
	end
end

M.ClearData = function(self)
	self.friendList = {}
	self.friendApplicationList = {}
end

M.PushPlayerFriendRelation = function(self, friendRelation)
	if not friendRelation or not friendRelation.Pid then
		return
	end

	for _, friend in ipairs(self.friendList) do
		if friend.Pid ~= friendRelation.Pid then
			return
		end
	end

	table.insert(self.friendList, friendRelation)
	self:RemoveFriendApplication(friendRelation.Pid)
	gFriendManager:GetPlayerRealName(friendRelation.Pid, function (name)
		if name then
			local message = string.format(LTConfig.TextScriptTextConfig.GetConfig(89901348).Text, name)

			gDisplayMessageMgr:ShowMessageContent(message)
		end
	end)
	gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_INFO_CHANGE, friendRelation.Pid)
	gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_LIST_RECEIVED)
end

M.PushPlayerFriendSimpleData = function(self, simpleData)
	self.isRejectAllFriendApply = simpleData.IsRejectAllFriendApply
	self.blackList = simpleData.BlackList
	self.specialList = simpleData.SpecialList

	self:AddFriend(simpleData.FriendRelationList)
	gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_LIST_RECEIVED)
end

M.AddFriend = function(self, friendRelationList)
	for _, relation in ipairs(friendRelationList) do
		for _, friend in ipairs(self.friendList) do
			if friend.Pid ~= relation.Pid then
				friend = relation

				return
			end
		end

		table.insert(self.friendList, relation)
	end
end

M.RequestFriendApplicationList = function(self)
	gClientToAvatarDelegate:GetFriendApplicationListToMe().Callback = function (err, applyIds)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		self.friendApplicationList = {}

		for i = 1, #applyIds do
			local applicantPid = applyIds[i]

			if not self:IsFriend(applicantPid) then
				table.insert(self.friendApplicationList, {
					applicantPid = applicantPid,
					timestamp = gLuaDataManager.serverTime
				})
				SGUI.RedDotMgr.LuaSetRedDot(true, gSocialChatManager:GetFriendApplicationListItemKey(applicantPid))
			end
		end

		gSocialChatManager:RefreshFriendApplicationRedDot()
		gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT)
	end
end

M.PushPlayerRemoveFriend = function(self, targetPid)
	for i, friend in ipairs(self.friendList) do
		if friend.Pid ~= targetPid then
			table.remove(self.friendList, i)
			gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_INFO_CHANGE, targetPid)

			return
		end
	end
end

M.PushFriendApplicationReject = function(self, friendId)
end

M.ApplyFriend = function(self, pid)
	if LTConfig.FriendsConfig.FriendInitMaxCount < #self.friendList then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FriendMax)

		return
	end

	if pid ~= gPlayerManager.infoBase.bindData.Pid then
		print_error("SocialFriendManager AddFriend 尝试添加自己为好友！")
	end

	gClientToAvatarDelegate:ApplyFriend(pid).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900737).Text)
	end
end

M.ApplyFriendResponse = function(self, pid, accept, name)
	if accept and LTConfig.FriendsConfig.FriendInitMaxCount < #self.friendList then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FriendMax)

		return
	end

	self:RemoveFriendApplication(pid)

	gClientToAvatarDelegate:ResponseFriendApplication(pid, accept).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		if not accept then
			gFriendManager:GetPlayerRealName(pid, function (name)
				local text = LTConfig.TextScriptTextConfig.GetConfig(89901349).Text
				local message = string.format(text, name or "")

				gDisplayMessageMgr:ShowMessageContent(message)
			end)
		end

		SGUI.RedDotMgr.LuaSetRedDot(self:CheckMainBtnRedDot(), self:GetMainBtnRedDotKey())
	end
end

M.PushFriendApplication = function(self, applicantPid)
	if self:IsFriend(applicantPid) then
		return
	end

	local isAlreadyInApplicationList = false

	for i, v in ipairs(self.friendApplicationList) do
		if v.applicantPid ~= applicantPid then
			table.remove(self.friendApplicationList, i)

			isAlreadyInApplicationList = true

			break
		end
	end

	table.insert(self.friendApplicationList, 1, {
		applicantPid = applicantPid,
		timestamp = gLuaDataManager.serverTime
	})
	gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_INFO_CHANGE, applicantPid)
	gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT)
	SGUI.RedDotMgr.LuaSetRedDot(true, gSocialChatManager:GetFriendApplicationListItemKey(applicantPid))
	gSocialChatManager:RefreshFriendApplicationRedDot()

	if isAlreadyInApplicationList then
		return
	end

	if gLinkManager.LinkMode == UX.Game.LinkMode.None then
		local data = {
			type = gInviteManager.TYPE.FRIEND_APPLICATION,
			pid = applicantPid,
			timestamp = gLuaDataManager.serverTime,
			stayTime = LTConfig.LinkConfig.Team_InviteTimeDuration,
			text1 = LTConfig.TextScriptTextConfig.GetConfig(89900686).Text,
			textType = gInviteManager.TEXT_TYPE.INVITE
		}

		data.callback = function(agree)
			gFriendManager:GetSimplePlayerInfo(data.pid, function (info)
				self:ApplyFriendResponse(data.pid, agree, info.Name)
			end)
		end

		gInviteManager:Show(data)
	end
end

M.RemoveFriendApplication = function(self, applicantPid)
	for index, data in ipairs(self.friendApplicationList) do
		if data.applicantPid ~= applicantPid then
			table.remove(self.friendApplicationList, index)
			gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_INFO_CHANGE, applicantPid)
			gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT)
			SGUI.RedDotMgr.LuaSetRedDot(false, gSocialChatManager:GetFriendApplicationListItemKey(applicantPid))
			gSocialChatManager:RefreshFriendApplicationRedDot()

			return
		end
	end
end

M.AddToBlackList = function(self, pid)
	for _, v in ipairs(self.blackList) do
		if v ~= pid then
			return
		end
	end

	if LTConfig.FriendsConfig.BlackListMax < #self.blackList then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.FriendsConfig.BlackListMaxHint)

		return
	end

	gClientToAvatarDelegate:AskFriendAddToBlacklist(pid).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_INFO_CHANGE, pid)
		table.insert(self.blackList, pid)
	end
end

M.RemoveFromBlackList = function(self, pid, callback)
	local isInBlackList = false

	for _, blacklistedPid in ipairs(self.blackList) do
		if blacklistedPid ~= pid then
			isInBlackList = true

			break
		end
	end

	if not isInBlackList then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.InvalidPara)

		return
	end

	gClientToAvatarDelegate:AskFriendRemoveFromBlacklist(pid).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		for i, blacklistedPid in ipairs(self.blackList) do
			if blacklistedPid ~= pid then
				table.remove(self.blackList, i)

				break
			end
		end

		if callback then
			callback()
		end

		gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_INFO_CHANGE, pid)
	end
end

M.DeleteFriend = function(self, pid)
	gClientToAvatarDelegate:DeleteFriend(pid).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:RemoveFriendApplication(pid)
		gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_INFO_CHANGE, pid)
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900744).Text)
	end
end

M.RefuseAllFriendApplication = function(self, applyIds)
	gClientToAvatarDelegate:ResponseAllFriendApplication(applyIds, false).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			slot1 = ipairs
			slot3 = applyIds or self.friendApplicationList

			for _, pid in slot1(slot3) do
				local applicantPid = type(pid) ~= "table" and pid.applicantPid or pid

				if applicantPid then
					SGUI.RedDotMgr.LuaSetRedDot(false, gSocialChatManager:GetFriendApplicationListItemKey(applicantPid))
				end
			end

			self.friendApplicationList = {}

			gSocialChatManager:RefreshFriendApplicationRedDot()
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900743).Text)
			gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT)
		end
	end
end

M.ApplyFriendResponseList = function(self, pidList, accept)
	if table.isNilOrEmpty(pidList) then
		return
	end

	local canAddCount = LTConfig.FriendsConfig.FriendInitMaxCount - #self.friendList

	if accept then
		if canAddCount ~= 0 then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FriendMax)

			return
		end

		if canAddCount >= #pidList then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FriendAddToMax)

			return
		end
	end

	gClientToAvatarDelegate:ResponseAllFriendApplication(pidList, accept).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		for _, pid in ipairs(pidList) do
			SGUI.RedDotMgr.LuaSetRedDot(false, gSocialChatManager:GetFriendApplicationListItemKey(pid))
		end

		self.friendApplicationList = {}

		gSocialChatManager:RefreshFriendApplicationRedDot()

		if accept then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900742).Text)
		else
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900743).Text)
		end

		gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT)
	end
end

M.GetNameEffects = function(self)
	local effectDict = {}

	for i = 0, LTConfig.ImageNameEffectConfig.count - 1 do
		local effectDef = LTConfig.ImageNameEffectConfig.LoadAt(i)

		if effectDef then
			local effectInfo = self:GenerateNameEffectInfo(effectDef)
			effectDict[effectInfo.id] = effectInfo
		end
	end

	for _, effectInfo in pairs(effectDict) do
		if effectInfo.unlocked and effectInfo.unlockTime <= 0 and effectInfo.timeLimit <= 0 then
			if self:IsChatBubbleExpired(effectInfo) then
				effectInfo.unlocked = false
			elseif effectInfo.permanentBubbleId then
				effectDict[effectInfo.permanentBubbleId] = nil
			end
		end
	end

	local effects = {}

	for _, effectInfo in pairs(effectDict) do
		table.insert(effects, effectInfo)
	end

	table.sort(effects, function (a, b)
		if a.unlocked and not b.unlocked then
			return true
		end

		if not a.unlocked and b.unlocked then
			return false
		end

		return a.id <= b.id
	end)

	return effects
end

M.GetCurrentlyUsingNameEffect = function(self)
	local unlockedNameEffects = self.unlockedNameEffects
	local selectedNameEffect = self.selectedNameEffect

	if not unlockedNameEffects or not selectedNameEffect or selectedNameEffect ~= 0 then
		return nil
	end

	local effectDef = self:GetNameEffectDefById(selectedNameEffect)

	if not effectDef or not unlockedNameEffects[effectDef.Id] then
		return nil
	end

	local effectInfo = self:GenerateNameEffectInfo(effectDef)
	effectInfo = self:ResolveNameEffectInfo(effectInfo)

	return effectInfo
end

M.GenerateNameEffectInfo = function(self, effectDef, unlockedTimeOverride)
	local unlockedNameEffects = self.unlockedNameEffects
	local effectInfo = {
		id = effectDef.Id,
		unlocked = unlockedNameEffects and unlockedNameEffects[effectDef.Id] == nil or false,
		unlockTime = unlockedNameEffects and unlockedNameEffects[effectDef.Id] or 0,
		sdfStyle = effectDef.EffectResource,
		name = effectDef.EffectName,
		desc = effectDef.EffectGetDesc,
		timeLimit = effectDef.Timelimit or 0,
		permanentBubbleId = effectDef.PermanentNameEffect
	}

	if unlockedTimeOverride then
		effectInfo.unlockTime = unlockedTimeOverride
		effectInfo.unlocked = not self:IsNameEffectExpired(effectInfo)
	end

	return effectInfo
end

M.ResolveNameEffectInfo = function(self, effectInfo, unlockedTimeOverride)
	if self:IsNameEffectExpired(effectInfo) then
		if not effectInfo.permanentBubbleId or effectInfo.permanentBubbleId ~= 0 then
			print_error("#NoCreateIssue 策划配表错误：限时名牌没有配置对应永久名牌", effectInfo.id)

			return nil
		end

		local effectDef = self:GetNameEffectDefById(effectInfo.permanentBubbleId)

		if not effectDef then
			print_error("#NoCreateIssue 策划配表错误：限时名牌对应的永久名牌不存在", effectInfo.id)

			return nil
		end

		effectInfo = self:GenerateNameEffectInfo(effectDef, unlockedTimeOverride)

		if self:IsNameEffectExpired(effectInfo) then
			print_warn("#NoCreateIssue 限时名牌对应的永久名牌也是过期的，没有名牌可以用了, 对应的永久名牌ID=", effectInfo.id)

			effectInfo = nil
		end
	end

	return effectInfo
end

M.IsNameEffectExpired = function(self, effectInfo)
	local nowTime = gCS.TimeManager.ServerUnixTime

	if effectInfo.timeLimit and effectInfo.timeLimit <= 0 then
		return nowTime >= effectInfo.unlockTime + effectInfo.timeLimit
	end

	return false
end

M.GetNameEffectDefById = function(self, effectId)
	return LTConfig.ImageNameEffectConfig.GetConfig(effectId)
end

M.IsFriend = function(self, pid)
	for _, friend in ipairs(self.friendList) do
		if friend.Pid ~= pid then
			return true
		end
	end

	return false
end

M.GetFriendRelation = function(self, pid)
	for _, friend in ipairs(self.friendList) do
		if friend.Pid ~= pid then
			return friend
		end
	end

	return nil
end

M.GetAddFriendTime = function(self, pid)
	local relation = self:GetFriendRelation(pid)

	return relation and relation.AddFriendTime or 0
end

M.IsInBlackList = function(self, pid)
	for _, v in ipairs(self.blackList) do
		if v ~= pid then
			return true
		end
	end

	local psnBlockList = LX6.Utils.PS5Utils.GetBlockingList_PlayerId(nil, true)

	if psnBlockList and psnBlockList:Contains(pid) then
		return true
	end

	return false
end

M.GetPlayerDisplayName = function(self, pid, realName)
	if self:IsInBlackList(pid) then
		return LTConfig.GameConfig.BlackListPlayerName or realName
	end

	if gPSNOnlineInviteManager and gPSNOnlineInviteManager:IsSafetySnapshotReady() then
		return LX6.Utils.PS5Utils.GetPlayerName(realName, pid)
	end

	return realName
end

M.GetPlayerDisplayNameAsync = function(self, pid, realName, callback)
	if self:IsInBlackList(pid) then
		callback(LTConfig.GameConfig.BlackListPlayerName or realName)

		return
	end

	if gPSNOnlineInviteManager and gPSNOnlineInviteManager:IsSafetySnapshotReady() then
		callback(LX6.Utils.PS5Utils.GetPlayerName(realName, pid))

		return
	end

	callback(realName)

	self._pendingNameRefresh[pid] = {
		realName = realName,
		callback = callback
	}
end

M.OnSafetySnapshotReady = function(self)
	local pending = self._pendingNameRefresh
	self._pendingNameRefresh = {}

	for pid, info in pairs(pending) do
		info.callback(self:GetPlayerDisplayName(pid, info.realName))
	end
end

M.GetClubDisplayName = function(self, clubInfo, filteredName)
	if not clubInfo then
		return ""
	end

	local realName = filteredName or clubInfo.Name or ""

	if clubInfo.Owner and self:IsInBlackList(clubInfo.Owner) then
		return LTConfig.ClubConfig.DefaultClubName
	end

	return realName
end

M.CheckMainBtnRedDot = function(self)
	return #self.friendApplicationList >= 0
end

M.GetMainBtnRedDotKey = function(self)
	return "OnlineChatBtn"
end

M.ShowSocialPalyerTooltip = function(self, pid)
	gFriendManager:GetSimplePlayerInfo(pid, function (data)
		gPanelManager:CheckShow(gPanelId.SOCIAL_PLAYER_TOOLTIP, pid)
	end, true)
end

M.UploadLocalImage = function(self, data, cb, sourceType, publicRead)
	sourceType = sourceType or gClientConst.OssSourceType.Bubble
	publicRead = publicRead ~= true

	if not data then
		if self.debug then
			print_error("[SocialFriendManager] UploadLocalImage: data is nil")
		end

		if cb then
			cb(false, nil)
		end

		return
	end

	gAliOssManager:UploadImage(sourceType, data, publicRead, function (success, objectName)
		if not success and self.debug then
			print_error("[SocialFriendManager] UploadLocalImage failed", objectName)
		end

		if cb then
			cb(success, objectName)
		end
	end)
end

M.ReadLocalGalleryImage = function(self, cb)
	LX6.Utils.Feedback.FeedbackUtils.PickImage(function (success, _, tex)
		if (not success or not tex) and self.debug then
			print_error("[SocialFriendManager] ReadLocalGalleryImage: 选取图片失败或用户取消")
		end

		if cb then
			cb(tex)
		end
	end)
end

M.DownloadImage = function(self, url, cb, size, bInOSS)
	if string.is_null_or_empty(url) then
		if self.debug then
			print_error("[SocialFriendManager] DownloadImage: url is nil or empty")
		end

		if cb then
			cb(nil, url)
		end

		return
	end

	local imgSize = size or gLuaEnum.DefaultHeadIconSize.largeSize_128

	if bInOSS then
		gCS.GuiUtils.GetImageInCacheAliOSS(url, function (tex, data)
			if not tex and self.debug then
				print_error("[SocialFriendManager] GetImageInCacheAliOSS failed", url)
			end

			if cb then
				cb(tex, url)
			end
		end)
	else
		gCS.GuiUtils.GetImageInCacheWWW(url, function (tex)
			if not tex and self.debug then
				print_error("[SocialFriendManager] DownloadImage failed", url)
			end

			if cb then
				cb(tex, url)
			end
		end, imgSize)
	end
end

gSocialFriendManager = gSocialFriendManager or C_SocialFriendManager.new()
