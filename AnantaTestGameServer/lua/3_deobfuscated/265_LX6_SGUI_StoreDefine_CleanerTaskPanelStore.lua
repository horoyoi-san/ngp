C_CleanerTaskPanelStore = DefClass("C_CleanerTaskPanelStore", C_CleanerTaskPanelStore, C_StoreGroup)
GroupName2Class.CleanerTaskPanelStore = C_CleanerTaskPanelStore
local M = C_CleanerTaskPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.finishBtn.luaClick = self:CreateAction(self.OnFinishBtnClick)
	self.bindData.openAppBtn.luaClick = self:CreateAction(self.OnOpenAppBtnClick)
	self.bindData.finishBtn.luaLongPress = self:CreateAction(self.OnFinishBtnClick)
	self.bindData.openAppBtn.luaLongPress = self:CreateAction(self.OnOpenAppBtnClick)

	self.bindData.openAppBtn:SetActive(self:CheckHasWasherJob())

	self.isCompleteSoundPlayed = false
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(data)
	gMessageManager:AddMessageListener(gEventConstants.WASH_PROGRESS_CHANGE, self:CreateAction(self.OnProgressChange))

	local isCar = data and data.isCar
	local isWithoutOrder = gWasherManager.isWithoutOrder
	self.bindData.isCar = 0

	self:RefreshProgress(L50.L50App.Scene.WashMgr.Progress)
	self:PlayShowAnim()
	self:RefreshTaskDesc()
	self:SetOrderBtnShow(not isWithoutOrder)
	gWasherManager:SendProgress(false)
	gWasherManager:RefreshWasherJobInfo()
end

function M:RefreshTaskDesc()
	local desc = self:GetTaskDesc()

	if string.is_null_or_empty(desc) then
		desc = LTConfig.TextConfig.GetConfig(LTConfig.WasherConfig.MissionCleaning).Text or desc
	end

	self.bindData.taskDescText = desc
end

function M:GetTaskDesc()
	if not self.parent then
		self.parent = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	end

	if not self.parent.curTaskInfo then
		return
	end

	if self.parent.isInTaskRaid then
		return self.parent.curTaskInfo.WorkDescription or ""
	else
		return self.parent.curTaskInfo.EventObjective or ""
	end
end

function M:PlayShowAnim()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.mainAnim:Play("S_Vx_CleanerTask_PC_in")
	else
		self.bindData.mainAnim:Play("S_Vx_CleanerTask_in")
	end
end

function M:PlayCloseAnim()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.mainAnim:Play("S_Vx_CleanerTask_PC_out")
	else
		self.bindData.mainAnim:Play("S_Vx_CleanerTask_out")
	end
end

function M:OnProgressChange(eventId, data)
	self:RefreshProgress(data[0])
end

function M:RefreshProgress(progress)
	self.bindData.totalRate = math.floor(progress * 1000) * 0.1

	if not self.isCompleteSoundPlayed and self.bindData.totalRate >= 99.9 then
		self.isCompleteSoundPlayed = true

		gSoundMgr:PlaySoundByTid(LTConfig.SoundConfig.CleanerCompleteSoundId)
	end
end

function M:OnClose()
	gMessageManager:RemoveMessageListener(gEventConstants.WASH_PROGRESS_CHANGE, self:CreateAction(self.OnProgressChange))
	self:PlayCloseAnim()
end

function M:OnLanguageChange(lang)
	self:RefreshTaskDesc()
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnFinishBtnClick()
	gWasherManager:AskFinishWasherMission(true)
end

function M:OnOpenAppBtnClick()
	gWasherManager:AskFinishWasherMission(false)
end

function M:CheckHasWasherJob()
	local availableJobIdList = gSpiritJobManager.GetCurSpiritAvailableJobIdList()

	if availableJobIdList then
		for _, jobId in ipairs(availableJobIdList) do
			local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
			local jobClassId = urbanJobCfg and urbanJobCfg.JobClass or 0

			if LTConfig.UrbanJobJobClassConfig.Washer == jobClassId then
				return true
			end
		end
	end

	return false
end

function M:SetOrderBtnShow(isShow)
	self.bindData.btnHideCtrl = isShow and 0 or 1
end
