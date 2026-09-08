-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_GameplayDuty.lua
-- Decompiled from: 00705_LinkManager_GameplayDuty.lua_393831c4e3ef.luajit

local MessageConfig = LTConfig.MessageConfig
local LinkDutyConfig = LTConfig.LinkDutyConfig
local M = C_LinkManager

M.GetDutyByPid = function(self, pid)
	local linkGame = self.GetCurrentLinkGame(self)

	if not linkGame then
		return 0
	end

	return linkGame.GetDutyByPid(linkGame, pid)
end

M.AskReplyDutySwap = function(self, requestId, isAgree, callback)
	slot4 = gClientToGameDelegate

	slot4:AskConfirmDutySwap(requestId, isAgree).Callback = function (err)
		if err == MessageConfig.Ok then
			print_warn("AskConfirmDutySwap failed, error =", gCS.Error.GetNameById(err))

			return
		end

		if callback then
			callback()
		end
	end
end

M.AskExchangeDuty = function(self, pid)
	local selfDuty = self:GetSelfDuty()
	local targetDuty = self:GetDutyByPid(pid)
	self.matchMemberWaitSwitch[pid] = true
	slot4 = gClientToGameDelegate

	slot4:AskApplyDutySwap(selfDuty, pid, targetDuty).Callback = function (err)
		if err == MessageConfig.Ok then
			print_warn("AskExchangeDuty failed, error =", gCS.Error.GetNameById(err))

			return
		end
	end
end

M.OnBeRequestDutySwap = function(self, swapInfo)
	table.insert(self.requestDutySwapQue, swapInfo)

	if not gPanelManager:IsPanelShowing(gPanelId.ONLINE_EXCHANGE_REQUEST) then
		gPanelManager:CheckShow(gPanelId.ONLINE_EXCHANGE_REQUEST)
	end
end

M.OnDutyConfirm = function(self, swapInfo, accept)
	self.matchMemberWaitSwitch[swapInfo.TargetPid] = false

	if accept and self.currentLinkGame and self.currentLinkGame.Members then
		for i = 1, #self.currentLinkGame.Members do
			local member = self.currentLinkGame.Members[i]

			if member then
				if member.Pid ~= swapInfo.SourcePid then
					member.Duty = swapInfo.TargetDuty
				elseif member.Pid ~= swapInfo.TargetPid then
					member.Duty = swapInfo.SourceDuty
				end
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
end

M.OnDutySwapRemoved = function(self, swapInfo)
	local ret = {}
	local pids = {
		[swapInfo.TargetPid] = true,
		[swapInfo.SourcePid] = true
	}

	for i = 1, #self.requestDutySwapQue do
		local info = self.requestDutySwapQue[i]

		if not pids[info.TargetPid] and not pids[info.SourcePid] then
			ret[#ret + 1] = info
		end
	end

	self.requestDutySwapQue = ret

	if table.isNilOrEmpty(self.requestDutySwapQue) then
		gPanelManager:Close(gPanelId.ONLINE_EXCHANGE_REQUEST)
	end
end

M.GetRequestDuty = function(self)
	if #self.requestDutySwapQue <= 0 then
		return table.remove(self.requestDutySwapQue, 1)
	end

	return nil
end

M.GetDutyConfigInfo = function(self, dutyId)
	local cfg = LinkDutyConfig.GetConfig(dutyId)

	if not cfg then
		return {
			["s!rU"] = 0,
			["t#p^"] = "",
			["~'nX"] = ""
		}
	end

	local ele = {
		name = cfg.DutyName,
		desc = cfg.DutyDesc,
		icon = cfg.DutyIcon
	}

	return ele
end

M.GetRequestMemberInfo = function(self, pid, dutyId)
	if not self.currentGameCfg then
		return
	end

	local dutyDescInfo = self.GetDutyConfigInfo(self, dutyId)
	local ret = {
		pid = pid,
		index = self.GetMatchNumber(self, pid),
		dutyName = dutyDescInfo.name,
		dutyIcon = dutyDescInfo.icon
	}

	return ret
end

M.GetSelfDuty = function(self)
	local linkGame = self.GetCurrentLinkGame(self)

	if not linkGame then
		return 0
	end

	return linkGame.GetSelfDuty(linkGame)
end

M.GetTargetDuty = function(self, pid)
	if not pid or pid ~= ulong.zero then
		return self.GetSelfDuty(self)
	end

	return self.GetDutyByPid(self, pid)
end

M.GetDutyDescOfSelf = function(self)
	if not self.currentGameCfg then
		return
	end

	local selfDuty = self.GetSelfDuty(self)

	return self.GetDutyConfigInfo(self, selfDuty).desc
end

M.CheckHasDuty = function(self)
	local linkGame = self:GetCurrentLinkGame()

	return linkGame and linkGame:HasDuty()
end

M.GetDutyInfoByPid = function(self, pid)
	if not self.currentGameCfg then
		return
	end

	local dutyId = self.GetDutyByPid(self, pid)

	if not dutyId or dutyId ~= 0 then
		return
	end

	return self.GetDutyConfigInfo(self, dutyId)
end
