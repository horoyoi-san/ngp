C_GangMemberManager = DefClass("C_GangMemberManager", C_GangMemberManager)
local M = C_GangMemberManager

function M:ctor()
	self.gangMembers = {}
	self.limit = 0
end

function M:OnInit()
	return
end

function M:SyncGangBossFullDetails(fullDetails)
	self.gangMembers = fullDetails.full.GangMembers
	self.limit = fullDetails.CurrentBattleAgentCount
end

function M:SyncGangBossGangMemberDetails(membersInfos)
	self.gangMembers[membersInfos.TemplateId] = membersInfos

	gMessageManager:SendMessage(gEventConstants.GANG_MEMBER_INFO_CHANGE, membersInfos.TemplateId)
end

function M:SyncGangBossCurrentBattleAgentCount(count)
	self.limit = count
end

function M:GetGangMemberInfoAll()
	return self.gangMembers
end

function M:GetGangMemberInfoByTemplateId(templateId)
	return self.gangMembers[templateId]
end

gGangMemberManager = gGangMemberManager or C_GangMemberManager.new()
