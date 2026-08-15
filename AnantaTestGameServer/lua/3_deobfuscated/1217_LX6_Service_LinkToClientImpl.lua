local LinkToClientImpl = gRpcChecker:CreateRpcImpl()

function LinkToClientImpl.SendCustomHotPatchMatchToClient(data)
	return
end

function LinkToClientImpl.SyncLinkMemberAdd(linkId, mode, member)
	gLinkManager:WaitMemberInfo(member.Pid, function ()
		gLinkManager:OnLinkMemberChange(mode, member, true)
	end)
end

function LinkToClientImpl.SyncLinkMemberRemove(linkId, mode, member)
	gLinkManager:WaitMemberInfo(member.Pid, function ()
		gLinkManager:OnLinkMemberChange(mode, member, false)
	end)
end

function LinkToClientImpl.SyncLinkMemberOnline(linkId, mode, member)
	gLinkManager:WaitMemberInfo(member.Pid, function ()
		gLinkManager:OnChangeMemberOnlineState(member, true, mode)
	end)
end

function LinkToClientImpl.SyncLinkMemberOffline(linkId, mode, member)
	gLinkManager:WaitMemberInfo(member.Pid, function ()
		gLinkManager:OnChangeMemberOnlineState(member, false, mode)
	end)
end

function LinkToClientImpl.ShowMemberLinkMessage(pid, msgType, message)
	gLinkManager:WaitMemberInfo(pid, function ()
		gLinkManager:ShowLinkMsg(pid, msgType)
	end)
end

return LinkToClientImpl
