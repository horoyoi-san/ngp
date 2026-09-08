-- Original chunk: @Lua\LuaFiles\LX6\GUI\Guide\GuideMainPanelMgr.lua
-- Decompiled from: 00567_GuideMainPanelMgr.lua_6876a785acf5.luajit

local M = {}

M.OnLogin = function(self)
	self.UpdateRedPoint(self)
end

M.OnSyncGuideTeachInfos = function(self, newGuideTeachInfos, rewardedGuideTeachInfos)
	local newInfo = gPlayerManager.infoMinor.bindData.NewGuideTeachInfos

	if not newInfo then
		newInfo = {}
		gPlayerManager.infoMinor.bindData.NewGuideTeachInfos = newInfo
	end

	for k, v in pairs(newInfo) do
		newInfo[k] = nil
	end

	for i = 1, newGuideTeachInfos.Length do
		newInfo[newGuideTeachInfos[i]] = true
	end

	newInfo.Count = newGuideTeachInfos.Length
	local rewardedInfos = gPlayerManager.infoMinor.bindData.RewardedGuideTeachInfos

	if not rewardedInfos then
		print_error("RewardedGuideTeachInfos未初始化")
	else
		for k, _ in pairs(rewardedInfos) do
			rewardedInfos[k] = nil
		end

		for i = 1, rewardedGuideTeachInfos.Length do
			rewardedInfos[rewardedGuideTeachInfos[i]] = true
		end

		rewardedInfos.Count = rewardedGuideTeachInfos.Length
	end

	self.UpdateRedPoint(self)
end

M.UpdateRedPoint = function(self)
	local hasNew = gPlayerManager.infoMinor.bindData.NewGuideTeachInfos and gPlayerManager.infoMinor.bindData.NewGuideTeachInfos.Count and gPlayerManager.infoMinor.bindData.NewGuideTeachInfos.Count >= 0

	SGUI.RedDotMgr.LuaSetRedDot(false, "GuideTeach")
end

M.ClearGuide = function(self, teachId)
	slot2 = gClientToGameDelegate

	slot2:AskFinishGuideTeachRead(teachId).Callback = function (err)
		print_notice("GF Debug => [GuideMain]AskFinishGuideTeachRead CallBack, err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)

		if err ~= LTConfig.MessageConfig.Ok then
			if gPlayerManager.infoMinor.bindData.NewGuideTeachInfos[teachId] then
				gPlayerManager.infoMinor.bindData.NewGuideTeachInfos[teachId] = nil
				gPlayerManager.infoMinor.bindData.NewGuideTeachInfos.Count = gPlayerManager.infoMinor.bindData.NewGuideTeachInfos.Count - 1
			end

			if not gPlayerManager.infoMinor.bindData.RewardedGuideTeachInfos[teachId] then
				gPlayerManager.infoMinor.bindData.RewardedGuideTeachInfos[teachId] = true
				gPlayerManager.infoMinor.bindData.RewardedGuideTeachInfos.Count = gPlayerManager.infoMinor.bindData.RewardedGuideTeachInfos.Count + 1
			end
		end

		self:UpdateRedPoint()
	end
end

M.IsNewTeach = function(self, teachId)
	return gPlayerManager.infoMinor.bindData.NewGuideTeachInfos[teachId] == nil
end

M.IsRewarded = function(self, teachId)
	return gPlayerManager.infoMinor.bindData.RewardedGuideTeachInfos[teachId] == nil
end

gGuideMainPanelMgr = M

return gGuideMainPanelMgr
