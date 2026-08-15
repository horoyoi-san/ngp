local M = {}

function M:OnLogin()
	self:UpdateRedPoint()
end

function M:OnSyncNewGuideTeachInfos()
	self:UpdateRedPoint()
end

function M:UpdateRedPoint()
	if gPlayerManager.infoMinor.bindData.NewGuideTeachInfos and gPlayerManager.infoMinor.bindData.NewGuideTeachInfos.Count and gPlayerManager.infoMinor.bindData.NewGuideTeachInfos.Count > 0 then
		gRedPointMgr:SetNewTip(gPanelId.S_GUIDE_MAIN_PANEL)
	else
		gRedPointMgr:ClearNewTip(gPanelId.S_GUIDE_MAIN_PANEL)
	end
end

function M:ClearGuide(teachId)
	gClientToGameDelegate:AskFinishGuideTeachRead(teachId).Callback = function (err)
		print_notice("GF Debug => [GuideMain]AskFinishGuideTeachRead CallBack, err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)

		if err == LTConfig.MessageConfig.Ok then
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

function M:IsNewTeach(teachId)
	return gPlayerManager.infoMinor.bindData.NewGuideTeachInfos[teachId] ~= nil
end

function M:IsRewarded(teachId)
	return gPlayerManager.infoMinor.bindData.RewardedGuideTeachInfos[teachId] ~= nil
end

gGuideMainPanelMgr = M

return gGuideMainPanelMgr
