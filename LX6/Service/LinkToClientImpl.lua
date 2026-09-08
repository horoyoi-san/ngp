-- Original chunk: @Lua\LuaFiles\LX6\Service\LinkToClientImpl.lua
-- Decompiled from: 02363_LinkToClientImpl.lua_27ff0afe2d95.luajit

slot0 = gRpcChecker
local LinkToClientImpl = slot0:CreateRpcImpl()

LinkToClientImpl.SendCustomHotPatchMatchToClient = function(data)
end

LinkToClientImpl.SyncLinkMemberAdd = function(linkId, mode, member)
	slot3 = gLinkManager

	slot3:WaitMemberInfo(member.Pid, function ()
		gLinkManager:OnLinkMemberChange(mode, member, true)
	end)
end

LinkToClientImpl.SyncLinkMemberRemove = function(linkId, mode, member)
	slot3 = gLinkManager

	slot3:WaitMemberInfo(member.Pid, function ()
		gLinkManager:OnLinkMemberChange(mode, member, false)
	end)
end

LinkToClientImpl.SyncLinkMemberOnline = function(linkId, mode, member)
	slot3 = gLinkManager

	slot3:WaitMemberInfo(member.Pid, function ()
		gLinkManager:OnChangeMemberOnlineState(member, true, mode)
	end)
end

LinkToClientImpl.SyncLinkMemberOffline = function(linkId, mode, member)
	slot3 = gLinkManager

	slot3:WaitMemberInfo(member.Pid, function ()
		gLinkManager:OnChangeMemberOnlineState(member, false, mode)
	end)
end

LinkToClientImpl.ShowMemberLinkMessage = function(pid, msgType, message)
	slot3 = gLinkManager

	slot3:WaitMemberInfo(pid, function ()
		gLinkManager:ShowLinkMsg(pid, msgType)
	end)
end

return LinkToClientImpl
