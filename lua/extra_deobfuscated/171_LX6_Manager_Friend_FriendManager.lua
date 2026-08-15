local M = {
	cs = LX6.Manager.FriendManager.Instance,
	friendRelation = {},
	k_EmptyTable = {}
}
local mt = {
	__index = function (self, k)
		if k == "friendPids" then
			return self:GetFriendPidList()
		end

		return rawget(self, k)
	end
}

setmetatable(M, mt)

local friendRelationMt = {
	__index = function (_, pid)
		return M:GetFriendRelation(pid)
	end
}

setmetatable(M.friendRelation, friendRelationMt)

local emptyTableMt = {
	__newindex = function (_, _)
		print_error("do not write to this table!")
	end
}

setmetatable(M.k_EmptyTable, emptyTableMt)

function M:GetFriendRelation(pid)
	if self._friendRelationCache and self._friendRelationCache.Pid == pid then
		return self._friendRelationCache
	end

	self._friendRelationCache = self.cs:GetFriendRelation(pid)

	return self._friendRelationCache
end

function M:GetFriendPidList()
	local list = self.cs:LuaGetFriendPidList()

	return list and list:ToTable() or self.k_EmptyTable
end

function M:IsFriend(pid)
	if not ulong.check(pid) then
		if pid ~= nil then
			print_error("FriendManager.IsFriend: pid is not ulong!", pid)
		end

		return false
	end

	return self.cs:IsFriend(pid)
end

function M:GetSimplePlayerInfo(pid, callback, noCache, useDefaultIfNotFound)
	if not ulong.check(pid) then
		if pid ~= nil then
			print_error("FriendManager.GetSimplePlayerInfo: pid is not ulong!", pid)
		end

		callback(nil)

		return
	end

	self.cs:GetSimplePlayerInfo(pid, callback, noCache, useDefaultIfNotFound)
end

function M:GetSimplePlayerInfoByPidList(pidList, callback, noCache, useDefaultIfNotFound)
	if table.isNilOrEmpty(pidList) then
		if callback then
			callback(self.k_EmptyTable)
		end

		return
	end

	local csCallback = nil

	if callback then
		function csCallback(data)
			if data then
				callback(data:ToTable())
			else
				callback(self.k_EmptyTable)
			end
		end
	end

	self.cs:GetSimplePlayerInfoByPidList(self.cs.ToUlongList(pidList), csCallback, noCache, useDefaultIfNotFound)
end

function M:ApplyFriend(pid, cb)
	if self:IsInBlackList(pid) then
		gMainPhoneUtils.ShowFrontContent({
			showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
			description = LTConfig.TextScriptTextConfig.GetConfig(89901127).Text,
			onConfirmCallback = function ()
				self:RemoveFromBlackList(pid, function (err)
					if err == LTConfig.MessageConfig.Ok then
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

function M:ResponseApplyFriend(pid, accept, name)
	self.cs:ResponseApplyFriend(pid, accept, name)
end

function M:ApplyFriendResponseList(pidList, accept)
	self.cs:ApplyFriendResponseList(self.cs.ToUlongList(pidList), accept)
end

function M:DeleteFriend(pid, cb, noNotify)
	if noNotify then
		self.cs:DeleteFriend(pid, cb, noNotify)
	elseif cb then
		self.cs:DeleteFriend(pid, cb)
	else
		self.cs:DeleteFriend(pid)
	end
end

function M:AskFriendRed(cb)
	if cb then
		self.cs:AskFriendRed(cb)
	else
		self.cs:AskFriendRed()
	end
end

function M:AskApplyFriend(pid, cb)
	self.cs:ApplyFriend(pid, cb)
end

function M:AskDeleteFriend(pid, cb, noNotify)
	self.cs:DeleteFriend(pid, cb, noNotify)
end

function M:AskApplyFriendResponse(pid, accept)
	self.cs:ApplyFriendResponse(pid, accept)
end

function M:IsInBlackList(pid)
	return self.cs:IsInBlackList(pid)
end

function M:GetFriendRemarkName(pid)
	return self.cs:GetFriendRemarkName(pid)
end

function M:ChangeFriendRemark(pid, remark, callback)
	self.cs:ChangeFriendRemark(pid, remark, callback)
end

function M:AddToBlackList(pid, callback)
	self.cs:AddToBlackList(pid, callback)
end

function M:RemoveFromBlackList(pid, callback)
	self.cs:RemoveFromBlackList(pid, callback)
end

function M:AddToSpecialList(pid, callback)
	self.cs:AddToSpecialList(pid, callback)
end

function M:RemoveFromSpecialList(pid, callback)
	self.cs:RemoveFromSpecialList(pid, callback)
end

function M:IsSpecialFriend(pid)
	return self.cs:IsSpecialFriend(pid)
end

function M:SetRejectAllFriendApply(reject, cb)
	self.cs:SetRejectAllFriendApply(reject, cb)
end

function M:GetBlackList()
	local list = self.cs:LuaGetBlackList()

	return list and list:ToTable() or self.k_EmptyTable
end

function M:GetSpecialList()
	local list = self.cs:LuaGetSpecialList()

	return list and list:ToTable() or self.k_EmptyTable
end

function M:IsRejectAllFriendApply()
	return self.cs.IsRejectAllFriendApply
end

function M:GetPlayerRealName(pid, callback, noCache)
	if not callback then
		return self.cs:GetPlayerRealName(pid)
	end

	return self.cs:GetPlayerRealName(pid, callback, noCache)
end

function M:NoticeUpdateFriendInfo(pidList)
	pidList = pidList and pidList:ToTable() or self.k_EmptyTable

	gMessageManager:SendMessage(gEventConstants.UPDATE_FRIEND_INFO, pidList)
end

gFriendManager = M
