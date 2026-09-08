-- Original chunk: @Lua\LuaFiles\LX6\Manager\GangMemberManager.lua
-- Decompiled from: 00360_GangMemberManager.lua_6a7f436acd30.luajit

C_GangMemberManager = DefClass("C_GangMemberManager", C_GangMemberManager)
local M = C_GangMemberManager

M.ctor = function(self)
	self.gangMembers = {}
	self.limit = 0
	self.normalAgentQueue = {}
	self.globalCooldownEndTime = 0
	self.pendingSummonTemplateId = 0
	self.pendingReplaceTemplateId = 0
	self.pendingSummonPos = nil
	self.pendingSummonFacing = -1
	self.pendingSummonCb = nil

	self.destroyCb = function(err)
		if err == LTConfig.MessageConfig.Ok then
			local cb = self.pendingSummonCb

			self:ClearPendingReplacement()

			if cb then
				cb(err)
			end
		end
	end

	self.summonCb = function(err)
		if err ~= LTConfig.MessageConfig.Ok then
			self:StartGlobalCooldown()
		end

		if self.pendingSummonCb then
			self.pendingSummonCb(err)
		end

		self:ClearPendingReplacement()
	end
end

M.ClearPendingReplacement = function(self)
	self.pendingSummonTemplateId = 0
	self.pendingReplaceTemplateId = 0
	self.pendingSummonPos = nil
	self.pendingSummonFacing = -1
	self.pendingSummonCb = nil
end

M.SyncGangBossSummonOrder = function(self, orderedTemplatedIds)
	table.clear(self.normalAgentQueue)

	for i = 1, #orderedTemplatedIds do
		table.insert(self.normalAgentQueue, orderedTemplatedIds[i])
	end
end

M.GetEarliestNormalAgentId = function(self)
	return self.normalAgentQueue[1] or 0
end

M.IsGlobalCooldown = function(self)
	return gLogicTime.time <= self.globalCooldownEndTime
end

M.GetGlobalCooldownRemaining = function(self)
	return math.max(0, self.globalCooldownEndTime - gLogicTime.time)
end

M.StartGlobalCooldown = function(self)
	self.globalCooldownEndTime = gLogicTime.time + LTConfig.CompanionAgentConfig.GlobalCoolDown
end

M.RequestSummon = function(self, templateId, pos, facing, cb)
	if self:IsGlobalCooldown() then
		return false
	end

	gClientToGameDelegate:AskSummonGangMember(templateId, pos, facing).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			self:StartGlobalCooldown()
		end

		if cb then
			cb(err)
		end
	end

	return true
end

M.RequestReplaceNormalAgent = function(self, templateId, pos, facing, cb)
	if self:IsGlobalCooldown() or self.pendingSummonTemplateId == 0 then
		return false
	end

	local replaceTemplateId = self:GetEarliestNormalAgentId()

	if replaceTemplateId ~= 0 then
		return false
	end

	self.pendingSummonTemplateId = templateId
	self.pendingReplaceTemplateId = replaceTemplateId
	self.pendingSummonPos = pos
	self.pendingSummonFacing = facing
	self.pendingSummonCb = cb
	gClientToGameDelegate:AskDestroyGangMember(replaceTemplateId).Callback = self.destroyCb

	return true
end

M.MarkGangMemberDestroyed = function(self, templateId)
	local info = self.gangMembers[templateId]

	if info then
		info.InstanceId = 0
		info.IsDead = false
		info.HpPercent = 1
	end
end

M.RequestDestroyGangMember = function(self, templateId, cb)
	gClientToGameDelegate:AskDestroyGangMember(templateId).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			self:MarkGangMemberDestroyed(templateId)
		end

		if cb then
			cb(err)
		end
	end
end

M.RequestDestroyAllGangMember = function(self, cb)
	gClientToGameDelegate:AskDestroyAllGangMember().Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			for templateId, _ in pairs(self.gangMembers) do
				self:MarkGangMemberDestroyed(templateId)
			end
		end

		if cb then
			cb(err)
		end
	end
end

M.OnInit = function(self)
end

M.SyncGangBossFullDetails = function(self, fullDetails)
	self.gangMembers = fullDetails.full.GangMembers
	self.limit = fullDetails.CurrentBattleAgentCount
end

M.SyncGangBossGangMemberDetails = function(self, membersInfos)
	self.gangMembers[membersInfos.TemplateId] = membersInfos

	if self.pendingReplaceTemplateId ~= membersInfos.TemplateId and ulong.equals(membersInfos.InstanceId, 0) then
		local templateId = self.pendingSummonTemplateId
		local pos = self.pendingSummonPos
		local facing = self.pendingSummonFacing
		self.pendingReplaceTemplateId = 0
		gClientToGameDelegate:AskSummonGangMember(templateId, pos, facing).Callback = self.summonCb
	end

	gMessageManager:SendMessage(gEventConstants.GANG_MEMBER_INFO_CHANGE, membersInfos.TemplateId)
end

M.SyncGangBossCurrentBattleAgentCount = function(self, count)
	self.limit = count
end

M.GetGangMemberInfoAll = function(self)
	return self.gangMembers
end

M.GetGangMemberInfoByTemplateId = function(self, templateId)
	return self.gangMembers[templateId]
end

gGangMemberManager = gGangMemberManager or C_GangMemberManager.new()
