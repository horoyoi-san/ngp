C_PlayerInfoMinorNpcCultivationData = DefClass("C_PlayerInfoMinorNpcCultivationData", C_PlayerInfoMinorNpcCultivationData, C_PlayerDataBase)
local M = C_PlayerInfoMinorNpcCultivationData

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template
	t.npcCultivationInfos = {}
	t.npcCultivationInfosDic = {}
	t.unlockedNpcCultivationInfos = {}
	t.unlockedNpcCultivationInfosDic = {}
	local npcCardInfos = info.InfoMinor.InfoNpcCultivation.NpcCardInfos
	local lockedCardInfos = info.InfoMinor.InfoNpcCultivation.LockedCardInfos

	for i = 1, #npcCardInfos do
		local info = npcCardInfos[i]
		t.npcCultivationInfos[i] = gNpcInteracsUtils:CreateNpcCardInfo(info)
		t.npcCultivationInfosDic[t.npcCultivationInfos[i].TemplateId] = i
	end

	for i = 1, #lockedCardInfos do
		local info = lockedCardInfos[i]
		t.unlockedNpcCultivationInfos[i] = gNpcInteracsUtils:CreateNpcCardInfo(info)
		t.unlockedNpcCultivationInfosDic[t.unlockedNpcCultivationInfos[i].TemplateId] = i
	end

	t.playerNpcCultivationInfo = {
		NpcInteractTotalCounterDict = info.InfoMinor.InfoNpcCultivation.NpcInteractTotalCounterDict or {}
	}
	t.availableGiftSendCount = info.InfoMinor.InfoNpcCultivation.AvailableGiftSendCount
	t.LiveInHouseNpcs = {}
	t.LiveInHouseNpcId2Bedroom = {}
	local listInHouseNpcs = {}

	for i = 1, #listInHouseNpcs do
		local npcInfo = listInHouseNpcs[i]
		local npcId = npcInfo.CultivationId
		t.LiveInHouseNpcs[i] = npcInfo
		t.LiveInHouseNpcId2Bedroom[npcId] = npcInfo.Bedroom
	end

	t.LogicNpcInfos = {}
	t.NormalNpcAwakeValue = {}
	local records = {}
	local tab = {}

	for i = 1, #records do
		local record = records[i]
		tab[record.CultivationId] = record
	end

	t.NpcChats = {}
	local lstNpcChats = info.InfoMinor.InfoNpcCultivation.NpcChats

	for i = 1, #lstNpcChats do
		t.NpcChats[lstNpcChats[i].TemplateId] = lstNpcChats[i]
	end

	t.NpcGroupChats = {}
	local lstGroupChats = info.InfoMinor.InfoNpcCultivation.NpcGroupChats

	for i = 1, #lstGroupChats do
		t.NpcGroupChats[lstGroupChats[i].TemplateId] = lstGroupChats[i]
	end

	t.InteractPoint = info.InfoMinor.InfoNpcCultivation.InteractPoint

	gNpcDaliyManager:OnQueueListSync(info.InfoMinor.InfoNpcCultivation.NpcEventQueueList)
	self.bindData:RefreshData(t)
end

function M:OnLogOut()
	self.bindData:Clear()
end
