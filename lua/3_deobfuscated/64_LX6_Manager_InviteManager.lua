C_InviteManager = DefClass("C_InviteManager", C_InviteManager)
local M = C_InviteManager

function M:ctor()
	self.TYPE = {
		GAMEPLAY = 0,
		LINK = 2,
		TEAM = 1
	}
	self.TEXT_TYPE = {
		INVITE = 1,
		APPLY = 0,
		INVITEXXX = 2
	}
	self.inviteList = {}
	self.myInviteFriendList = {
		[self.TYPE.GAMEPLAY] = {},
		[self.TYPE.TEAM] = {},
		[self.TYPE.LINK] = {}
	}
	self.myInviteGroupList = {
		[self.TYPE.GAMEPLAY] = {},
		[self.TYPE.TEAM] = {},
		[self.TYPE.LINK] = {}
	}
	self.myApplyList = {
		[self.TYPE.GAMEPLAY] = {},
		[self.TYPE.TEAM] = {},
		[self.TYPE.LINK] = {}
	}
end

function M:Show(data)
	table.insert(self.inviteList, data)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_OnlineCommonInvitingTip, data)
end

function M:GetCount()
	local count = 0
	local toRemove = {}

	for k, v in pairs(self.inviteList) do
		if v.stayTime < gLuaDataManager.serverTime - v.timestamp then
			table.insert(toRemove, k)
		else
			count = count + 1
		end
	end

	for _, k in ipairs(toRemove) do
		table.remove(self.inviteList, k)
	end

	return count
end

function M:GetAllInviteList()
	self:GetCount()

	return self.inviteList
end

function M:GetCurData()
	local count = self:GetCount()

	return self.inviteList[count]
end

function M:RemoveInvite(inviteInfo)
	for k, v in pairs(self.inviteList) do
		if v == inviteInfo then
			table.remove(self.inviteList, k)

			return
		end
	end
end

function M:AddInviteFriend(type, stayTime, pid)
	if not self.myInviteFriendList[type] then
		return false
	end

	if self.myInviteFriendList[type][pid] then
		return false
	end

	local data = {
		type = type,
		pid = pid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = stayTime
	}
	self.myInviteFriendList[type][pid] = data

	return true
end

function M:AddInviteGroup(type, stayTime, groupId)
	if not groupId then
		return false
	end

	if not self.myInviteGroupList[type] then
		return false
	end

	if self.myInviteGroupList[type][groupId] then
		return false
	end

	local data = {
		type = type,
		groupId = groupId,
		timestamp = gLuaDataManager.serverTime,
		stayTime = stayTime
	}
	self.myInviteGroupList[type][groupId] = data

	return true
end

function M:GetInviteFriendList(type)
	local list = self.myInviteFriendList[type]

	if not list then
		return
	end

	return self:ClearList(list)
end

function M:GetInviteGroupList(type)
	local list = self.myInviteGroupList[type]

	if not list then
		return
	end

	return self:ClearList(list)
end

function M:ClearList(list)
	for k, v in pairs(list) do
		if v.stayTime < gLuaDataManager.serverTime - v.timestamp then
			list[k] = nil
		end
	end

	return list
end

function M:IsInviteFriendCD(type, pid)
	local list = self.myInviteFriendList[type]

	if not list then
		return false
	end

	self:ClearList(list)

	return self.myInviteFriendList[type][pid]
end

function M:IsInviteGroupCD(type, groupId)
	local list = self.myInviteGroupList[type]

	if not list then
		return false
	end

	self:ClearList(list)

	return self.myInviteGroupList[type][groupId]
end

function M:AddApplyList(type, stayTime, id)
	if not self.myApplyList[type] then
		return false
	end

	if self.myApplyList[type][id] then
		return false
	end

	local data = {
		type = type,
		pid = id,
		timestamp = gLuaDataManager.serverTime,
		stayTime = stayTime
	}
	self.myApplyList[type][id] = data
end

function M:IsApplyCD(type, id)
	local list = self.myApplyList[type]

	if not list then
		return false
	end

	self:ClearList(list)

	return self.myApplyList[type] and self.myApplyList[type][id]
end

gInviteManager = gInviteManager or C_InviteManager.new()
