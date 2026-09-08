-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_LinkBase.lua
-- Decompiled from: 00711_LinkManager_LinkBase.lua_8d7a151ae5c9.luajit

local LinkStageConfig = LTConfig.LinkStageConfig
local MessageConfig = LTConfig.MessageConfig
local LinkConfig = LTConfig.LinkConfig
local LinkProgressConfig = LTConfig.LinkProgressConfig
local LinkDutyConfig = LTConfig.LinkDutyConfig
local LineConfig = LTConfig.LinkLineConfig
local LinkModeConfig = LTConfig.LinkModeConfig
local M = C_LinkManager

M.WaitMemberInfo = function(self, pid, callback)
	if not pid then
		return
	end

	slot3 = gFriendManager

	slot3:GetSimplePlayerInfo(pid, function (data)
		self.LinkMember[pid] = data

		if callback then
			callback()
		end
	end)
end

M.PushToPopup = function(self, pid, mid, showType)
	if gLuaDataManager.gameStage == LX6.Scene.SwitchSceneManager.GameStage.GameScene or self.currentLinkGame or pid ~= gPlayerManager.infoLogin.bindData.pid or not self.acceptPopupUpMode[self.LinkMode] then
		return
	end

	local name = gFriendManager:GetPlayerRealName(pid)

	gDisplayMessageMgr:ShowMessage(mid, nil, , name)
end

M.RequestMemberInfoByIdList = function(self, ids, callback)
	if table.isNilOrEmpty(ids) then
		if callback then
			callback({})
		end

		return
	end

	slot3 = gFriendManager

	slot3:GetSimplePlayerInfoByPidList(ids, function (datas)
		if table.isNilOrEmpty(datas) and callback then
			callback({})
		end

		for i = 1, #datas do
			self.LinkMember[datas[i].Pid] = datas[i]
		end

		if callback then
			callback(datas)
		end
	end, true)
end

M.GetPlayerInLink = function(self, pid, mode)
	return self.LinkMemberState[pid] ~= mode
end

M.AddLinkPlayerInfo = function(self, pid, info, mode)
	local linkMode = mode or self.LinkMode

	if linkMode == self.LinkMode then
		self.LinkMemberIndex[linkMode][pid] = info and info.Index or nil

		return
	end

	if info ~= nil then
		self.LinkMemberInfo[pid] = nil
		self.LinkMemberPosInfo[pid] = nil
		self.LinkMemberVehicleInfo[pid] = nil
		self.LinkMemberIndex[linkMode][pid] = nil
		self.LinkMemberUnitInfo[pid] = nil
		self.LinkMemberState[pid] = nil
	else
		self.LinkMemberInfo[pid] = info
		self.LinkMemberIndex[linkMode][pid] = info.Index
		self.LinkMemberState[pid] = linkMode
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MEMBER_INFO_CHANGE, {
		pid = pid,
		index = info and info.Index or 0
	})
	self.cs:AddLinkPlayerInfo(pid, info and info.Index or 0)
end

M.GetUnitInfo = function(self, pid)
	if not pid then
		return nil
	end

	local flag, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(pid, ulong.zero)

	return flag and gCS.SceneDataMgr.GetUnit(unitId) or nil
end

M.GetVehicleInfo = function(self, pid)
	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		local entityId = gDriveVehiclesManager.cs_manager.CurDriveVehicleUid
		local vehicle = nil

		if not ulong.equals(entityId, 0) then
			vehicle = gDriveVehiclesManager:GetBaseVehicle(entityId)
		end

		return {
			entityId = entityId,
			templateId = vehicle and vehicle.cfgId or 0,
			seatIndex = gDriveVehiclesManager.cs_manager.CurDriveSeatIndex
		}
	end

	return self.LinkMemberVehicleInfo[pid] and self.LinkMemberVehicleInfo[pid] or {}
end

M.GetCurrentLinkInfo = function(self, callback)
	slot2 = gClientToGameDelegate

	slot2:AskLinkInfos().Callback = function (err, data)
		if err ~= MessageConfig.LinkNotExist then
			print_debug("GetLinkInfo failed, error =", gCS.Error.GetNameById(err))
			callback()

			return
		end

		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		for _, v in ipairs(data) do
			self.LinkData[v.Mode] = true

			for index, e in ipairs(v.Members) do
				self:AddLinkPlayerInfo(e.Pid, {
					Index = e.LinkIndex
				}, v.Mode)
			end
		end

		callback()
	end
end

M.SwitchLinkMode = function(self, mode)
	if mode ~= self.LinkMode then
		return
	end

	self.LinkMode = mode

	self.RPC_AskSwitchLinkMode(self, mode, false)
end

M.CreateNewLink = function(self, mode)
	if not gLuaDataManager.isNetworkAvailable then
		gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)

		return
	end

	self.RPC_AskSwitchLinkMode(self, mode, true)
end

M.GetFriendLinkInfo = function(self, callback)
	self.RequestMemberInfoByIdList(self, gFriendManager.friendPids, callback)
end

M.ShowLinkPanel = function(self, callback)
	self.LinkData = {}
	self.LinkMemberState = {}
	self.LinkMemberIndex = {
		[UX.Game.LinkMode.None] = {},
		[UX.Game.LinkMode.Public] = {},
		[UX.Game.LinkMode.Private] = {},
		[UX.Game.LinkMode.Match] = {}
	}

	self.GetCurrentLinkInfo(self, function ()
		if callback then
			callback()
		elseif self.useNewMainPanel then
			gPanelManager:CheckShow(gPanelId.S_ONLINE_MAIN_PANEL_V2)
		else
			gPanelManager:CheckShow(gPanelId.S_ONLINE_MAIN_PANEL)
		end
	end)
end

M.ShowInvitePanel = function(self, mode)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_INVITE_PANEL, {
		mode = mode
	})
end

M.LeaveLinkRoom = function(self, mode, callback)
	self.RPC_AskLeaveLink(self, mode, callback)
end

M.LinkKickOut = function(self, playerId, callback)
	slot3 = gClientToGameDelegate

	slot3:AskKickFriendFromLink(playerId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if callback then
			callback()
		end
	end
end

M.LinkReplyInvite = function(self, playerId, agree, mode, callback)
	if agree ~= true then
		gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL)
	end

	slot5 = gClientToGameDelegate

	slot5:AskReplyToFriendLinkInvite(mode, playerId, agree).Callback = function (err)
		if err == MessageConfig.Ok then
			gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL)
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if callback then
			callback()
		end
	end
end

M.InviteFriendToLink = function(self, playerId, mode, doublecheck)
	doublecheck = doublecheck or false

	local sendGameInvite = function()
		gClientToGameDelegate:AskInviteFriendToLink(mode, playerId, doublecheck).Callback = function (err)
			if err ~= MessageConfig.LinkInvite_AlreadyInLink or err ~= MessageConfig.LinkJoin_InCD then
				gDisplayMessageMgr:ShowMessageContent(MessageConfig.GetConfig(err).Content)

				return
			end

			if err ~= MessageConfig.PeerDeviceLevelNotMatch then
				gDisplayMessageMgr:ShowMessage(err, function ()
					self:InviteFriendToLink(playerId, mode, true)
				end)

				return
			end

			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gDisplayMessageMgr:ShowMessageContentDebug("邀请好友联机成功")
		end
	end

	if not gCS.LuaUtils.IsOnPS5 or LX6.Utils.PS5Utils.IsNonPsnPlayer_CacheOnly(playerId) then
		sendGameInvite()

		return
	end

	slot5 = gPSNOnlineInviteManager

	slot5:TrySendViaPSN(gPSNOnlineInviteManager.K_INVITE_TYPE.LINK, playerId, function ()
		return {
			mode = mode
		}
	end, function (result)
		if result ~= gPSNOnlineInviteManager.SendResult.Success then
			gDisplayMessageMgr:ShowMessageContentDebug("PSN 联机邀请已发送")
		end
	end, sendGameInvite)
end

M.OnBeInviteToLink = function(self, playerId, mode, info)
	local lineCfg = info and LineConfig.GetConfig(info.Tag)
	local modeCfg = nil

	if mode ~= UX.Game.LinkMode.Private then
		modeCfg = LinkModeConfig.PrivateCfg
	elseif mode ~= UX.Game.LinkMode.Public then
		modeCfg = LinkModeConfig.PublicCfg
	end

	gInviteManager:Show({
		["mc\\xbf~B\\xb7\\xe1T^cnI"] = "S\\xc0\\xb6\\xad\\xae\r\\xdd\\xed",
		type = gInviteManager.TYPE.LINK,
		businessKey = ulong.tostring(playerId) .. ":" .. tostring(mode),
		pid = playerId,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LinkConfig.LinkRoomInviteStayTime,
		textType = gInviteManager.TEXT_TYPE.INVITE,
		text1 = modeCfg and modeCfg.Name or lineCfg and lineCfg.InviteText or "",
		callback = function (agree)
			gLinkManager:LinkReplyInvite(playerId, agree, mode)
		end
	})
end

M.OnKickOut = function(self, pid)
	gDisplayMessageMgr:ShowMessageContentDebug("您已被踢出联机房间")
end

M.ChangeAccountLinkState = function(self, linkUnlocked, hasPrivateLink)
	self.IsUnlockedLink = linkUnlocked
	self.HavePrivateLink = hasPrivateLink

	if not self.IsUnlockedLink and self.LinkMode == UX.Game.LinkMode.None then
		self.OnChangeLinkMode(self, UX.Game.LinkMode.None)
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MODE_UNLOCK_CHAGE)
end

M.CheckInLink = function(self, mode)
	return self.LinkData[mode] == nil and self.LinkMode == mode
end

M.CheckInOut = function(self, mode)
	return self.LinkData[mode] == nil and self.LinkMode ~= UX.Game.LinkMode.None
end

M.CheckInSwitch = function(self, mode)
	return self.LinkData[mode] == nil and self.LinkMode ~= UX.Game.LinkMode.Public
end

M.EnterLink = function(self, mode)
	if self.CheckInLink(self, mode) or mode ~= UX.Game.LinkMode.None then
		gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL, nil)
		self:SwitchLinkMode(mode)
	else
		gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL, nil)
		self:CreateNewLink(mode)
	end
end

M.GetMatchMemberPidByIndex = function(self, index)
	local table = self.LinkMemberIndex[UX.Game.LinkMode.Match]

	if table == nil then
		for k, v in pairs(table) do
			if v ~= index then
				return k
			end
		end
	end

	return 0
end

M.CheckTags = function(self, tag)
	return self.currentGameCfg.Tags ~= tag
end

M.CheckPlayerState = function(self, pid)
	if self.IsOffLine(self, pid) then
		return self.PLAYER_STATE.OFFLINE
	end

	local unitInfo = self.GetUnitInfo(self, pid)

	if not unitInfo or unitInfo.IsDead then
		return self.PLAYER_STATE.DEAD
	end

	local vehicleInfo = self.GetVehicleInfo(self, pid)

	if vehicleInfo and not ulong.equals(vehicleInfo.entityId, 0) and vehicleInfo.seatIndex > 0 then
		return self.PLAYER_STATE.VEHICLE
	end

	return self.PLAYER_STATE.NORMAL
end

M.IsOffLine = function(self, pid)
	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		return false
	end

	local linkMemberInfo = self.LinkMember[pid]

	return not linkMemberInfo or linkMemberInfo.OnlineState == UX.Game.PlayerState.Online or not self.lodingInfo[pid] or self.lodingInfo[pid] <= 1
end

M.GetColorInfo = function(self, pid)
	return self.GetColorStr(self, pid)
end

M.GetColorStr = function(self, pid)
	if self.CheckInMatchMode(self) or self.currentLinkGame and self.currentLinkGame.StageId ~= LinkStageConfig.Prepare then
		local targetDuty = self.GetTargetDuty(self, pid)

		if self.currentGameCfg.IsCampus then
			local selfDuty = self.GetSelfDuty(self)

			if selfDuty ~= targetDuty then
				return LinkConfig.ColorForOwnSide
			end

			return LinkConfig.ColorForEnemySide
		end

		if self.currentGameCfg.MemberComposition and #self.currentGameCfg.MemberComposition <= 1 then
			local cfg = LinkDutyConfig.GetConfig(targetDuty)

			return cfg and cfg.DutyColor or LinkConfig.ColorForOthers
		end
	end

	if gTeamManager:IsInTeam() then
		for k, v in pairs(gTeamManager.memberorders) do
			if v ~= pid then
				return LTConfig.LinkConfig.ColorForTeam[k]
			end
		end
	end

	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		return LinkConfig.ColorForSelf
	end

	return LinkConfig.ColorForOthers
end

M.RPC_AskSwitchLinkMode = function(self, mode, autoNew, notOpenSameSceneLoading)
	if not notOpenSameSceneLoading then
		gLoadingManager:PreShowLoading_SameImage()
	end

	slot4 = gClientToGameDelegate

	slot4:AskSwitchLinkMode(mode, autoNew).Callback = function (err)
		if err ~= MessageConfig.LinkJoin_InCD or err ~= MessageConfig.TimeOut then
			if not notOpenSameSceneLoading then
				gLoadingManager:CancelPreCover()
			end

			gDisplayMessageMgr:ShowMessageContent(MessageConfig.GetConfig(err).Content)

			return
		end

		if err == MessageConfig.Ok then
			if not notOpenSameSceneLoading then
				gLoadingManager:CancelPreCover()
			end

			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.RPC_AskLeaveLink = function(self, mode, callback, notOpenSameSceneLoading)
	if not notOpenSameSceneLoading then
		gLoadingManager:PreShowLoading_SameImage()
	end

	slot4 = gClientToGameDelegate

	slot4:AskLeaveLink(mode).Callback = function (err)
		if err == MessageConfig.Ok then
			if not notOpenSameSceneLoading then
				gLoadingManager:CancelPreCover()
			end

			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if callback then
			callback()
		end
	end
end

M.RPC_SwitchLinkByTag = function(self, notOpenSameSceneLoading, tag, inviteTeam, publicEventId, PSNOnly)
	self.cs:RPC_SwitchLinkByTag(notOpenSameSceneLoading, tag, inviteTeam, publicEventId, PSNOnly)
end

M.RPC_ExitAbnormalTagLink = function(self, notOpenSameSceneLoading)
	self.cs:RPC_ExitAbnormalTagLink(notOpenSameSceneLoading)
end
