local NpcCultivationVoiceConfig = LTConfig.NpcCultivationVoiceConfig
local M = {
	MSG_TYPE = {
		FACE_TO_FACE = 2,
		DETAIL = 1,
		MENU = 3,
		NONE = 0
	},
	CANNOT_INTERACT_REASON = {
		CANNOT = 2,
		OK = 0,
		LOCK = 1
	},
	GetNpcCultivationInfo = function (self, id)
		local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos or {}

		for i = 1, #list do
			if list[i].TemplateId == id then
				return list[i]
			end
		end

		return nil
	end,
	GetUnlockedNpcCultivationInfo = function (self, id)
		local list = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos or {}

		for i = 1, #list do
			if list[i].TemplateId == id then
				return list[i]
			end
		end

		return nil
	end,
	TransformFavor = function (self, favor)
		local absFavor = math.abs(favor)
		absFavor = absFavor < 1 and math.ceil(absFavor) or math.floor(absFavor)

		return favor >= 0 and absFavor or -absFavor
	end
}

function M:CreateNpcCardInfo(info, npcCultivationId)
	local cardInfo = {
		TemplateId = info and info.TemplateId or 0,
		Favor = info and self:TransformFavor(info.Favor) or 0,
		UnlockedTags = info and info.UnlockedTags and info.UnlockedTags or {},
		Collections = info and info.Collections and info.Collections or {},
		ActivateTimestamp = info and info.ActivateTimestamp or gCS.TimeManager.ServerUnixTime,
		NpcInteractCounterDict = info and info.NpcInteractCounterDict or {},
		IsDead = info and info.IsDead or false,
		HouseDailyTopic = info and info.HouseDailyTopic or -1,
		LastTriggerFestivalDialog = info and info.LastTriggerFestivalDialog or 0,
		LastTriggerBirthdayDialog = info and info.LastTriggerBirthdayDialog or 0,
		RecentReceivedGifts = info and info.RecentReceivedGifts and info.RecentReceivedGifts or {},
		NpcBringUp = info and info.NpcBringUp or false,
		LastChangeRoomTimestamp = info and info.LastChangeRoomTimestamp or 0,
		NpcLastMoveInTimestamp = info and info.NpcLastMoveInTimestamp or 0,
		FinishFirstSeparateInvitation = info and info.FinishFirstSeparateInvitation,
		FinishFirstMoveInHouse = info and info.FinishFirstMoveInHouse or false,
		LongLiveInHouseTriggerCount = info and info.LongLiveInHouseTriggerCount or 0,
		FinishFavorDialogs = info and info.FinishFavorDialogs or {},
		HasTastedDesiredLiaoli = info and info.HasTastedDesiredLiaoli or false,
		HasTastedDislikeLiaoli = info and info.HasTastedDislikeLiaoli or false,
		FinishAddFavorTopics = info and info.FinishAddFavorTopics or {},
		UnlockedStoryDict = info and info.UnlockedStoryDict and info.UnlockedStoryDict or {},
		InteractedStories = info and info.InteractedStories and info.InteractedStories or {},
		HasNoInteractedStory = info and info.HasNoInteractedStory or false,
		UnlockedVoice = info and info.UnlockedVoice and info.UnlockedVoice or {},
		HasUninteractedNpcVoice = info and info.HasUninteractedNpcVoice or false,
		InteractedVoices = info and info.InteractedVoices and info.InteractedVoices or {},
		FavorLevelReward = info and info.FavorLevelReward or 6,
		InteractDays = info and info.InteractDays or 0,
		GroupNpcPhotoPosList = info and info.GroupNpcPhotoPosList or {},
		SingleNpcPhotoPosList = info and info.SingleNpcPhotoPosList or {},
		TodayChatPosList = info and info.TodayChatPosList or {},
		FirstChatPosList = info and info.FirstChatPosList or {},
		ActiveGiftTags = info and info.ActiveGiftTags or {},
		LastInteractTime = info and info.LastInteractTime or 0
	}

	return cardInfo
end

local npcRoomSuccessVoiceIdDic = nil

function M.OnConfigHotfix(eventId, data)
	local list = data:ToTable()

	if array.contains(list, "NpcCultivationVoiceConfig") then
		npcRoomSuccessVoiceIdDic = nil
	end

	if array.contains(list, "NormalNpcConfig") then
		npcToNpcCultivationIdDic = nil
	end
end

function M:CheckIsUnlocked(npcCardId)
	local index = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfosDic[npcCardId]
	local favorInfo = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos[index]

	if favorInfo then
		return true
	end

	return false
end

function M:CheckIfCanInteract(npcCardId)
	if not self:CheckIsUnlocked(npcCardId) then
		local index = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfosDic[npcCardId]

		if not index then
			return false
		end

		local favorInfo = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos[index]

		if not favorInfo then
			return false
		end
	end

	return true
end

function M:TryGetNpcCultivationInfo(npcCardId)
	if self:CheckIsUnlocked(npcCardId) then
		local index = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfosDic[npcCardId]
		local favorInfo = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos[index]

		return favorInfo
	else
		local index = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfosDic[npcCardId]

		if not index then
			return nil
		end

		local favorInfo = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos[index]

		return favorInfo
	end

	return nil
end

function M:RemoveUnlockNpcCultivationInfo(npcCardId)
	local index = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfosDic[npcCardId]

	if not index then
		return
	end

	local favorInfo = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos[index]

	if not favorInfo then
		return
	end

	table.remove(gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos, index)

	gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfosDic[npcCardId] = nil

	self:RefreshUnlockedNpcCultivationInfosDic()
end

function M:RefreshUnlockedNpcCultivationInfosDic()
	local lockedCardInfos = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos

	for i = 1, #lockedCardInfos do
		local info = lockedCardInfos[i]
		gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfosDic[info.TemplateId] = i
	end
end

function M:GetInteractableNpcSet()
	local npcInfos = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos
	local unlockedNpcInfos = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos
	local npcCardInfoSet = {}

	if not table.isNilOrEmpty(npcInfos) then
		for _, info in pairs(npcInfos) do
			npcCardInfoSet[info.TemplateId] = info
		end
	end

	if not table.isNilOrEmpty(unlockedNpcInfos) then
		for _, info in pairs(unlockedNpcInfos) do
			npcCardInfoSet[info.TemplateId] = info
		end
	end

	return npcCardInfoSet
end

gNpcInteracsUtils = M
