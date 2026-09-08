-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\CustomRoomManager.lua
-- Decompiled from: 02200_CustomRoomManager.lua_fd8b133db95b.luajit

C_CustomRoomManager = DefClass("C_CustomRoomManager", C_CustomRoomManager, nil, )
local M = C_CustomRoomManager

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.KickToLogin then
		self:Clear()
	end
end

M.Clear = function(self)
	self.roomInfo = nil
end

M.OnSyncRoomInfo = function(self, info)
	print_notice("[Party]OnSyncRoomInfo", inspect(info))

	local isLeavePartyRoom = self.roomInfo and self.roomInfo.PartyInfo == nil and info ~= nil
	self.roomInfo = info

	if isLeavePartyRoom then
		gPartyManager:Clear()
	end

	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_INFO_CHANGE, info)
end

M.OnSyncStatusChange = function(self, roomId, status, statusOverTime)
	print_notice("[Party]OnSyncStatusChange", roomId, status, statusOverTime)

	if not self.roomInfo or not ulong.equals(self.roomInfo.RoomId, roomId) then
		return
	end

	self.roomInfo.Status = status
	self.roomInfo.CurrentStatusOverTime = statusOverTime

	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_STATUS_CHANGE, {
		roomId = roomId,
		status = status
	})
end

M.OnSyncSettingChange = function(self, roomId, setting)
	if not self.roomInfo or not ulong.equals(self.roomInfo.RoomId, roomId) then
		return
	end

	if setting.Name then
		self.roomInfo.Name = setting.Name
	end

	if setting.Password == nil then
		self.roomInfo.HasPassword = setting.Password
	end

	if setting.PartySetting then
		self:ApplyPartySetting(setting.PartySetting)
	end

	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_SETTING_CHANGE, {
		roomId = roomId,
		setting = setting
	})
end

M.ApplyPartySetting = function(self, partySetting)
	if not self.roomInfo.PartyInfo then
		self.roomInfo.PartyInfo = partySetting

		return
	end

	local partyInfo = self.roomInfo.PartyInfo

	if partySetting.SetLottery then
		partyInfo.Lottery = true
		partyInfo.LotteryItemId = partySetting.LotteryItemId
		partyInfo.LotteryItemCount = partySetting.LotteryItemCount
	end

	if partySetting.SetGift then
		partyInfo.HasGift = true
		partyInfo.GiftItemId = partySetting.GiftItemId
		partyInfo.GiftItemCount = partySetting.GiftItemCount
	end

	partyInfo.OwnerJoinLottery = partySetting.OwnerJoinLottery
	partyInfo.EnableLiveBarrage = partySetting.EnableLiveBarrage
	partyInfo.EnableRoomAudio = partySetting.EnableRoomAudio
end

M.OnSyncOwnerChange = function(self, roomId, newOwnerPid)
	if not self.roomInfo or not ulong.equals(self.roomInfo.RoomId, roomId) then
		return
	end

	self.roomInfo.OwnerPid = newOwnerPid

	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_OWNER_CHANGE, {
		roomId = roomId,
		newOwnerPid = newOwnerPid
	})
end

M.OnSyncMemberJoin = function(self, roomId, memberInfo)
	if not self.roomInfo or not ulong.equals(self.roomInfo.RoomId, roomId) then
		return
	end

	if not self.roomInfo.Members then
		self.roomInfo.Members = {}
	end

	table.insert(self.roomInfo.Members, memberInfo)
	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_MEMBER_CHANGE, {
		["PRϳ\\x83\r\\x8c\\xd9\\xed"] = "p-tU",
		roomId = roomId,
		memberPid = memberInfo.Pid,
		memberInfo = memberInfo
	})
end

M.OnSyncMemberLeave = function(self, roomId, memberPid)
	if not self.roomInfo or not ulong.equals(self.roomInfo.RoomId, roomId) then
		return
	end

	self:_RemoveMember(memberPid)
	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_MEMBER_CHANGE, {
		["PRϳ\\x83\r\\x8c\\xd9\\xed"] = "A\\xab\\xa3\\xb9\\xb3",
		roomId = roomId,
		memberPid = memberPid
	})
end

M.OnSyncMemberKick = function(self, roomId, memberPid)
	if not self.roomInfo or not ulong.equals(self.roomInfo.RoomId, roomId) then
		return
	end

	self:_RemoveMember(memberPid)
	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_MEMBER_CHANGE, {
		["PRϳ\\x83\r\\x8c\\xd9\\xed"] = "q+~P",
		roomId = roomId,
		memberPid = memberPid
	})
end

M.OnSyncMemberReadyChange = function(self, roomId, memberPid, ready)
	if not self.roomInfo or not ulong.equals(self.roomInfo.RoomId, roomId) then
		return
	end

	if self.roomInfo.Members then
		for _, member in ipairs(self.roomInfo.Members) do
			if ulong.equals(member.Pid, memberPid) then
				member.IsReady = ready

				break
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_MEMBER_CHANGE, {
		["PRϳ\\x83\r\\x8c\\xd9\\xed"] = "\\x8d1!;a\\xbeI\\xd89\\xad\\xbc",
		roomId = roomId,
		memberPid = memberPid,
		ready = ready
	})
end

M.OnSyncDestroy = function(self, roomId)
	if not self.roomInfo or not ulong.equals(self.roomInfo.RoomId, roomId) then
		return
	end

	local isPartyRoom = self.roomInfo.PartyInfo == nil

	self:Clear()

	if isPartyRoom then
		gPartyManager:Clear()
	end

	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_DESTROY, {
		roomId = roomId
	})
end

M.OnSyncInvite = function(self, inviterInfo, roomId, roomName)
	local receiverPid = gPlayerManager.infoLogin.bindData.pid

	self:CanShowRoomUGC(inviterInfo.Pid, function (bOk)
		if not bOk or not ulong.equals(receiverPid, gPlayerManager.infoLogin.bindData.pid) then
			return
		end

		gInviteManager:Show({
			type = gInviteManager.TYPE.PARTY,
			pid = inviterInfo.Pid,
			timestamp = gLuaDataManager.serverTime,
			stayTime = LTConfig.LinkConfig.LinkRoomInviteStayTime,
			textType = gInviteManager.TEXT_TYPE.INVITE,
			text1 = roomName,
			callback = function (agree)
				if agree then
					gClientToGameDelegate:ResponsePartyRoomInvite(roomId, true).Callback = function (err)
						if err == LTConfig.MessageConfig.Ok then
							gDisplayMessageMgr:DisplayServerMessageId(err)
						end
					end
				end
			end
		})
		gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_INVITE, {
			inviterInfo = inviterInfo,
			roomId = roomId,
			roomName = roomName
		})
	end)
end

M.OnSyncApply = function(self, applierInfo, roomId)
	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_APPLY, {
		applierInfo = applierInfo,
		roomId = roomId
	})
end

M.OnSyncApplyResponse = function(self, roomId, approved)
	gMessageManager:SendMessage(gEventConstants.ON_CUSTOM_ROOM_APPLY_RESPONSE, {
		roomId = roomId,
		approved = approved
	})
end

M.CanShowRoomUGC = function(self, ownerPid, callback)
	if not gCS.LuaUtils.IsOnPS5 then
		callback(true)

		return
	end

	LX6.Utils.PS5Utils.CanUserInteractWithPlayer(ownerPid, callback)
end

M.GetRoomInfo = function(self)
	return self.roomInfo
end

M.IsInRoom = function(self)
	return self.roomInfo == nil
end

M.IsOwner = function(self)
	if not self.roomInfo then
		return false
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid

	return ulong.equals(self.roomInfo.OwnerPid, myPid)
end

M.GetPartyInfo = function(self)
	if not self.roomInfo then
		return nil
	end

	return self.roomInfo.PartyInfo
end

M.GetMemberByPid = function(self, pid)
	if not self.roomInfo or not self.roomInfo.Members then
		return nil
	end

	for _, member in ipairs(self.roomInfo.Members) do
		if ulong.equals(member.Pid, pid) then
			return member
		end
	end

	return nil
end

M.InviteToPartyRoom = function(self, pid)
	local sendGameInvite = function()
		gClientToGameDelegate:InviteToPartyRoom(pid)
	end

	if not gCS.LuaUtils.IsOnPS5 or LX6.Utils.PS5Utils.IsNonPsnPlayer_CacheOnly(pid) then
		sendGameInvite()

		return
	end

	gPSNOnlineInviteManager:TrySendViaPSN(gPSNOnlineInviteManager.K_INVITE_TYPE.PARTY, pid, function ()
		local roomInfo = self.roomInfo

		if not roomInfo or not roomInfo.PartyInfo then
			return nil
		end

		local ctx = {
			partyId = roomInfo.PartyInfo.PartyConfigId,
			roomId = roomInfo.Id
		}

		return ctx
	end, nil, sendGameInvite)
end

M.TryJoinPartyRoom = function(self, roomId, hasPassword, onSuccess)
	if hasPassword then
		gDisplayMessageMgr:ShowBomb({
			["\\xd0\\xc8=1\\xe5"] = true,
			["jn\\xafrI\\xb6\\xdeBd}jD"] = 8,
			msgType = gDisplayMessageId.SELECT,
			titleText = LTConfig.TextConfig.GetConfig(73971200).Text,
			inputCheck = function (pwd)
				return pwd:match("^%d%d%d%d$") == nil
			end,
			btnConfirmCallback = function (pwd)
				self:_doJoinPartyRoom(roomId, pwd, onSuccess)
			end
		})

		return
	end

	self:_doJoinPartyRoom(roomId, nil, onSuccess)
end

M._doJoinPartyRoom = function(self, roomId, password, onSuccess)
	gClientToGameDelegate:AskJoinPartyRoom(roomId, password).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if onSuccess then
			onSuccess()
		end
	end
end

M._RemoveMember = function(self, memberPid)
	if not self.roomInfo or not self.roomInfo.Members then
		return
	end

	for i, member in ipairs(self.roomInfo.Members) do
		if ulong.equals(member.Pid, memberPid) then
			table.remove(self.roomInfo.Members, i)

			return
		end
	end
end

gCustomRoomMgr = gCustomRoomMgr or C_CustomRoomManager.new()
