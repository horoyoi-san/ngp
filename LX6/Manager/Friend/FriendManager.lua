-- Original chunk: @Lua\LuaFiles\LX6\Manager\Friend\FriendManager.lua
-- Decompiled from: 00173_FriendManager.lua_969123967478.luajit

local M = {
	["\\xdd5\\xa0\\xea.\\xf5\\xa4\\xef\\xf0\\xa0\\x90ʆ3\\xea\\xb36\\x9f\\xdcW\\xac\\xaf\\x8e"] = 1800,
	cs = LX6.Manager.FriendManager.Instance,
	friendRelation = {},
	k_EmptyTable = {},
	friendApplicationList = {},
	richProfileInfoCache = {},
	OnlineStatus = {
		["3F\\x9d\\x87\\x8dD"] = 0,
		["/A\\x9f\\x89\\x8fD"] = 2,
		["\\xf6\\xdd*\\xf4"] = 3,
		X7nB = 1
	}
}
local mt = {
	__index = function (self, k)
		if k ~= "friendPids" then
			return self.GetFriendPidList(self)
		end

		return rawget(self, k)
	end
}

setmetatable(M, mt)

local emptyTableMt = {
	__newindex = function (_, _)
		print_error("do not write to this table!")
	end
}

setmetatable(M.k_EmptyTable, emptyTableMt)

M.GetFriendPidList = function(self)
	local list = self.cs:LuaGetFriendPidList()

	return list and list:ToTable() or self.k_EmptyTable
end

M.IsFriend = function(self, pid)
	if not ulong.check(pid) then
		if pid == nil then
			print_error("FriendManager.IsFriend: pid is not ulong!", pid)
		end

		return false
	end

	return self.cs:IsFriend(pid)
end

M.GetSimplePlayerInfo = function(self, pid, callback, noCache, useDefaultIfNotFound)
	if not ulong.check(pid) then
		if pid == nil then
			print_error("FriendManager.GetSimplePlayerInfo: pid is not ulong!", pid)
		end

		callback(nil)

		return
	end

	self.cs:GetSimplePlayerInfo(pid, callback, noCache, useDefaultIfNotFound)
end

M.GetOrderedFriendSimpleInfoList = function(self, callback)
	slot2 = gFriendManager.cs

	slot2:GetOrderedFriendList(function (pidList)
		pidList = pidList:ToTable()
		slot1 = gFriendManager

		slot1:GetSimplePlayerInfoByPidList(pidList, function (data)
			if callback then
				callback(data)
			end
		end, true)
	end)
end

M.GetSimplePlayerInfoByPidList = function(self, pidList, callback, noCache, useDefaultIfNotFound)
	if table.isNilOrEmpty(pidList) then
		if callback then
			callback(self.k_EmptyTable)
		end

		return
	end

	local csCallback = nil

	if callback then
		csCallback = function(data)
			if data then
				callback(data.ToTable(data))
			else
				callback(self.k_EmptyTable)
			end
		end
	end

	self.cs:GetSimplePlayerInfoByPidList(self.cs.ToUlongList(pidList), csCallback, noCache, useDefaultIfNotFound)
end

M.GetPlayerOnlineStatus = function(self, pid)
	return gLinkPlayerHub.cs:GetPlayerOnlineStatus(pid)
end

M.ApplyFriend = function(self, pid, cb)
	if self.IsInBlackList(self, pid) then
		gMainPhoneUtils.ShowFrontContent({
			showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
			description = LTConfig.TextScriptTextConfig.GetConfig(89901127).Text,
			onConfirmCallback = function ()
				slot0 = self

				slot0:RemoveFromBlackList(pid, function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						self:ApplyFriend(pid, cb)
					end
				end)
			end
		})

		return
	end

	if cb then
		self.cs:ApplyFriend(pid, cb)
	else
		self.cs:ApplyFriend(pid)
	end
end

M.ResponseApplyFriend = function(self, pid, accept, name)
	self.cs:ResponseApplyFriend(pid, accept, name)
end

M.ApplyFriendResponseList = function(self, pidList, accept)
	self.cs:ApplyFriendResponseList(self.cs.ToUlongList(pidList), accept)
end

M.DeleteFriend = function(self, pid, cb, noNotify)
	if noNotify then
		self.cs:DeleteFriend(pid, cb, noNotify)
	elseif cb then
		self.cs:DeleteFriend(pid, cb)
	else
		self.cs:DeleteFriend(pid)
	end
end

M.AskFriendRed = function(self, cb)
	if cb then
		self.cs:AskFriendRed(cb)
	else
		self.cs:AskFriendRed()
	end
end

M.AskApplyFriend = function(self, pid, cb)
	self.cs:ApplyFriend(pid, cb)
end

M.AskDeleteFriend = function(self, pid, cb, noNotify)
	self.cs:DeleteFriend(pid, cb, noNotify)
end

M.AskApplyFriendResponse = function(self, pid, accept)
	self.cs:ApplyFriendResponse(pid, accept)
	self:RemoveFriendApplication(pid)
end

M.IsInBlackList = function(self, pid)
	return self.cs:IsInBlackList(pid)
end

M.GetFriendRemarkName = function(self, pid)
	return self.cs:GetFriendRemarkName(pid)
end

M.ChangeFriendRemark = function(self, pid, remark, callback)
	self.cs:ChangeFriendRemark(pid, remark, callback)
end

M.AddToBlackList = function(self, pid, callback)
	self.cs:AddToBlackList(pid, callback)
end

M.RemoveFromBlackList = function(self, pid, callback)
	self.cs:RemoveFromBlackList(pid, callback)
end

M.AddToSpecialList = function(self, pid, callback)
	self.cs:AddToSpecialList(pid, callback)
end

M.RemoveFromSpecialList = function(self, pid, callback)
	self.cs:RemoveFromSpecialList(pid, callback)
end

M.IsSpecialFriend = function(self, pid)
	return self.cs:IsSpecialFriend(pid)
end

M.SetRejectAllFriendApply = function(self, reject, cb)
	self.cs:SetRejectAllFriendApply(reject, cb)
end

M.GetBlackList = function(self)
	local list = self.cs:LuaGetBlackList()

	return list and list:ToTable() or self.k_EmptyTable
end

M.GetSpecialList = function(self)
	local list = self.cs:LuaGetSpecialList()

	return list and list:ToTable() or self.k_EmptyTable
end

M.IsRejectAllFriendApply = function(self)
	return self.cs.IsRejectAllFriendApply
end

M.GetPlayerRealName = function(self, pid, callback, noCache)
	if not callback then
		return self.cs:GetPlayerRealName(pid)
	end

	return self.cs:GetPlayerRealName(pid, callback, noCache)
end

M.NoticeUpdateFriendInfo = function(self, pidList)
	pidList = pidList and pidList:ToTable() or self.k_EmptyTable

	gMessageManager:SendMessage(gEventConstants.UPDATE_FRIEND_INFO, pidList)
end

M.GetPlayerRichProfileInfo = function(self, pid, callback, noCache)
	pid = pid or gPlayerManager.infoLogin.bindData.pid
	local pidStr = ulong.tostring(pid)
	local info = self.richProfileInfoCache[pidStr]

	if not noCache and info then
		if gLuaDataManager.serverTime >= info.updateTime + self.RichProfileInfoCacheTime then
			callback(info)

			return
		else
			self.richProfileInfoCache[pidStr] = nil
		end
	end

	info = {
		pid = pid
	}
	local rpcCnt = 0

	local OnDataReached = function()
		rpcCnt = rpcCnt - 1

		if rpcCnt < 0 then
			if info.background < 0 then
				info.background = LTConfig.ImageBackGroudConfig.DefaultBg
			end

			info.updateTime = gLuaDataManager.serverTime
			self.richProfileInfoCache[pidStr] = info

			if gCS.LuaUtils.IsOnPS5 then
				LX6.Utils.PS5Utils.CanUserInteractWithPlayer(pid, function (bOk)
					if not bOk then
						info.clubName = nil
						info.sign = LTConfig.ImageConfig.SocialRestrictions
					end

					callback(info)
				end)
			else
				callback(info)
			end
		end
	end

	local rankInfo = {}
	local rankIds = {}

	for i = 0, LTConfig.RankConfig.count - 1 do
		local rankCfg = LTConfig.RankConfig.LoadAt(i)

		if rankCfg then
			table.insert(rankIds, rankCfg.Id)
		end
	end

	rpcCnt = 2
	slot10 = gClientToGameDelegate

	slot10:AskPlayerRankingSummary(pid, rankIds).Callback = function (err, results)
		if err == 0 then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			print_error("GetPlayerRichProfileInfo: 请求玩家排行摘要失败，错误码：", gCS.Error.GetNameById(err), "pid=", pid)

			return
		end

		for _, summary in ipairs(results) do
			rankInfo[summary.RankConfigId] = {
				rankId = summary.RankConfigId,
				score = summary.Score,
				rank = summary.Rank,
				tierDetail = summary.TierDetail
			}
		end

		info.rankInfo = rankInfo

		OnDataReached()
	end

	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		info.name = gPlayerManager.infoLogin.bindData.playerName or gPlayerManager.infoLogin.bindData.name
		info.sex = gPlayerManager.infoLogin.bindData.sexType
		local clubInfo = gClubManager:GetClubInfo()

		if clubInfo then
			info.clubName = clubInfo.Name
			info.clubIconId = clubInfo.IconCfgId
		end

		info.infoPzHeadInfo = gPlayerManager.infoLogin.bindData.infoLinkPzHeadInfo or gPlayerManager.infoLogin.bindData.infoPzHeadInfo
		info.cityPediaCredit = gBaiKeArchiveManager.GetCityPediaCredit()

		gHunLunManager:GetPersonalInfo(pid, function (data)
			if data then
				info.background = data.Background
				info.birthday = data.Birthday
				info.sign = data.Signature or ""
				info.popup = 0
				info.name_effect = 0
			else
				print_error("GetPlayerRichProfileInfo: 获取玩家信息失败 pid=", ulong.tostring(pid))
			end

			OnDataReached()
		end)
	else
		rpcCnt = rpcCnt + 2

		self:GetSimplePlayerInfo(pid, function (d)
			local data = d

			if data then
				info.sex = data.Sex
				info.infoPzHeadInfo = data.LinkPzHeadInfo or data.PzHeadInfo
				info.birthday = data.Birthday
				info.background = data.Background
				info.sign = data.Signature or ""
				info.onlineState = data.OnlineState
				info.cityPediaCredit = data.Credit
				info.popup = data.PopUp
				info.name_effect = data.NameEffect
				local tiers = {}

				if data.TierInfo and data.TierInfo.Tiers then
					for i = 0, data.TierInfo.Tiers.Count - 1 do
						local tier = data.TierInfo.Tiers[i]

						if tier then
							tiers[tier.RankConfigId] = {
								rankId = tier.RankConfigId,
								tierDetail = tier
							}
						else
							print_warn("#NoCreateIssue GetPlayerRichProfileInfo: RPC返回Tier数据异常： pid=", ulong.tostring(pid), "#data.TierInfo.Tiers=", data.TierInfo.Tiers.Count, "data.TierInfo.Tiers[" .. i .. "] = nil")
						end
					end
				end

				for _, k in ipairs(rankIds) do
					if not info.rankInfo or not info.rankInfo[k] then
						local tier = tiers[k]

						if tier then
							info.rankInfo = info.rankInfo or {}
							info.rankInfo[k] = tier
						end
					end
				end
			else
				print_error("GetPlayerRichProfileInfo: 获取玩家信息失败 pid=", ulong.tostring(pid))
			end

			OnDataReached()
		end, true, true)

		slot10 = gClientToGameDelegate

		slot10:AskQueryBasicClubInfo(pid).Callback = function (err, data)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
				print_error("GetPlayerRichProfileInfo: 获取玩家俱乐部信息失败 pid=", ulong.tostring(pid))
			else
				info.clubName = data.Name
				info.clubIconId = data.IconCfgId

				OnDataReached()
			end
		end

		self:GetPlayerRealName(pid, function (name)
			info.name = name

			OnDataReached()
		end)
	end
end

M.OpenPlayerProfile = function(self, pid)
	if not self.IsPlayerProfileEnabled(self) then
		return
	end

	self.GetPlayerRichProfileInfo(self, pid, function (info)
		if not info then
			print_error("OpenPlayerProfile: 获取玩家俱乐部信息失败 pid=", ulong.tostring(pid))

			return
		end

		if gPanelManager:IsPanelShowing(gPanelId.PLAYER_PROFILE_PANEL) then
			local store = gStoreManager:GetStoreGroup("PlayerProfileStore")

			if store then
				store.NavigateTo(store, info)

				return
			end
		end

		gPanelManager:CheckShow(gPanelId.PLAYER_PROFILE_PANEL, info)
	end, true)
end

M.IsPlayerProfileEnabled = function(self)
	local systemUnlock = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.PersonalHomepage)

	return systemUnlock
end

gFriendManager = M
