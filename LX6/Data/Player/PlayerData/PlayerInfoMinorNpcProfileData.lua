-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoMinorNpcProfileData.lua
-- Decompiled from: 00102_PlayerInfoMinorNpcProfileData.lua_b0e184d9b86a.luajit

C_PlayerInfoMinorNpcProfileData = DefClass("C_PlayerInfoMinorNpcProfileData", C_PlayerInfoMinorNpcProfileData, C_PlayerDataBase)
local M = C_PlayerInfoMinorNpcProfileData

M.InitPlayerInfo = function(self, info)
	local t = self.DataSet_Template
	local npcProfileInfos = info.InfoMinor.InfoNpcProfile
	local profileDic = npcProfileInfos.NpcProfiles
	t.npcTrustInfo = {}

	for _, pInfo in pairs(profileDic) do
		t.npcTrustInfo[pInfo.ProfileId] = self.CreatNpcProfileInfo(self, pInfo)
	end

	t.progressRewardsWithWeb = {}

	if npcProfileInfos.ProgressRewardsWithWeb then
		for webId, webProgressList in pairs(npcProfileInfos.ProgressRewardsWithWeb) do
			t.progressRewardsWithWeb[webId] = {}

			if webProgressList.GotProgressRewardList then
				for i = 1, webProgressList.GotProgressRewardList.Count do
					table.insert(t.progressRewardsWithWeb[webId], webProgressList.GotProgressRewardList[i])
				end
			end
		end
	end

	self.bindData:RefreshData(t)
end

M.CreatNpcProfileInfo = function(self, trustNpcInfo)
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

M.OnLogOut = function(self)
	self.bindData:Clear()
end
