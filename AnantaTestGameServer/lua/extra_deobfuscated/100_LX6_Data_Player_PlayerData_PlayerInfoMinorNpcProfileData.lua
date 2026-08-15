C_PlayerInfoMinorNpcProfileData = DefClass("C_PlayerInfoMinorNpcProfileData", C_PlayerInfoMinorNpcProfileData, C_PlayerDataBase)
local M = C_PlayerInfoMinorNpcProfileData

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template
	local npcProfileInfos = info.InfoMinor.InfoNpcProfile
	local profileDic = npcProfileInfos.NpcProfiles
	t.npcTrustInfo = {}

	for _, pInfo in pairs(profileDic) do
		t.npcTrustInfo[pInfo.ProfileId] = self:CreatNpcProfileInfo(pInfo)
	end

	t.progressRewards = {}

	if npcProfileInfos.ProgressRewards then
		for i = 1, npcProfileInfos.ProgressRewards.Count do
			table.insert(t.progressRewards, npcProfileInfos.ProgressRewards[i])
		end
	end

	self.bindData:RefreshData(t)
end

function M:CreatNpcProfileInfo(trustNpcInfo)
	local info = {
		ProfileId = trustNpcInfo.ProfileId,
		TrustValue = trustNpcInfo.TrustValue,
		ActivateTime = trustNpcInfo.ActivateTime,
		IsNew = trustNpcInfo.IsNew,
		IsMaxTrustReward = trustNpcInfo.IsMaxTrustReward,
		GotRewardList = {}
	}

	for i = 1, trustNpcInfo.GotRewardList.Count do
		table.insert(info.GotRewardList, trustNpcInfo.GotRewardList[i])
	end

	info.FinishTargetList = {}

	for i = 1, trustNpcInfo.FinishTargetList.Count do
		table.insert(info.FinishTargetList, trustNpcInfo.FinishTargetList[i])
	end

	info.TargetStateList = {}

	if trustNpcInfo.TargetStateList then
		for i = 1, trustNpcInfo.TargetStateList.Count do
			local state = trustNpcInfo.TargetStateList[i]
			info.TargetStateList[state.TargetId] = state.IsNew
		end
	end

	return info
end

function M:OnLogOut()
	self.bindData:Clear()
end
