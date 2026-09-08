-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoMinorNpcCultivationData.lua
-- Decompiled from: 00101_PlayerInfoMinorNpcCultivationData.lua_62efefe085fe.luajit

C_PlayerInfoMinorNpcCultivationData = DefClass("C_PlayerInfoMinorNpcCultivationData", C_PlayerInfoMinorNpcCultivationData, C_PlayerDataBase)
local M = C_PlayerInfoMinorNpcCultivationData

M.InitPlayerInfo = function(self, info)
	local t = self.DataSet_Template
	local npcCultivationInfo = info.InfoMinor.InfoNpcCultivation
	t.npcCultivationInfos = {}
	t.npcCultivationInfosDic = {}
	t.unlockedNpcCultivationInfos = {}
	t.unlockedNpcCultivationInfosDic = {}
	local npcCardInfos = npcCultivationInfo.NpcCardInfos
	local lockedCardInfos = npcCultivationInfo.LockedCardInfos

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
		NpcInteractTotalCounterDict = npcCultivationInfo.NpcInteractTotalCounterDict or {},
		chatGroupRenameDict = npcCultivationInfo.chatGroupRenameDict or {}
	}
	t.availableGiftSendCount = npcCultivationInfo.AvailableGiftSendCount
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
	local lstNpcChats = npcCultivationInfo.NpcChats

	for i = 1, #lstNpcChats do
		t.NpcChats[lstNpcChats[i].TemplateId] = lstNpcChats[i]
	end

	t.NpcGroupChats = {}
	local lstGroupChats = npcCultivationInfo.NpcGroupChats

	for i = 1, #lstGroupChats do
		t.NpcGroupChats[lstGroupChats[i].TemplateId] = lstGroupChats[i]
	end

	t.InteractPoint = npcCultivationInfo.InteractPoint

	gNpcDaliyManager:OnQueueListSync(npcCultivationInfo.NpcEventQueueList)
	self.bindData:RefreshData(t)
end

M.OnLogOut = function(self)
	self.bindData:Clear()
end
