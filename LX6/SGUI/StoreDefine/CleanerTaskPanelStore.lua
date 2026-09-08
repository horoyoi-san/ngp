-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerTaskPanelStore.lua
-- Decompiled from: 01433_CleanerTaskPanelStore.lua_8b12f0f13e3b.luajit

C_CleanerTaskPanelStore = DefClass("C_CleanerTaskPanelStore", C_CleanerTaskPanelStore, C_StoreGroup)
GroupName2Class.CleanerTaskPanelStore = C_CleanerTaskPanelStore
local M = C_CleanerTaskPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.finishBtn.luaClick = self:CreateAction(self.OnFinishBtnClick)
	self.bindData.openAppBtn.luaClick = self:CreateAction(self.OnOpenAppBtnClick)
	self.bindData.finishBtn.luaLongPress = self:CreateAction(self.OnFinishBtnClick)
	self.bindData.openAppBtn.luaLongPress = self:CreateAction(self.OnOpenAppBtnClick)

	self.bindData.openAppBtn:SetActive(self:CheckHasWasherJob())

	self.bindData.scanBtn.luaClick = self:CreateAction(self.OnClickScanBtn)

	if not gCS.LuaUtils.IsNonMobileAdaptive() and self.bindData.heightBox then
		self.bindData.heightBox.luaSizeChanged = self.CreateAction(self, "OnSizeChanged")
	end

	self.isCompleteSoundPlayed = false
	self.msgEvents = {
		[gEventConstants.CURRENT_TASK_CHANGE] = self.CreateAction(self, self.OnCurrentTaskChange),
		[gEventConstants.WASH_PROGRESS_CHANGE] = self.CreateAction(self, self.OnProgressChange),
		[gEventConstants.ON_GLUE_PROGRESS_CHANGE] = self.CreateAction(self, self.OnGlueProgressChange)
	}
end

M.OnEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	self:ClearMessageEvents()
	gTaskUtils:SendMobileTaskPanelChange(0)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, data)
	self._cachedProgressList = nil
	self._cachedProgress = nil
	self._cachedCurIndex = nil
	self._cachedTextIdList = nil
	self._hasNewData = false
	self.isGlueMode = data and data.isGlueMode or false
	self.bindData.isCleanerCtrl = self.isGlueMode and 1 or 0
	self.bindData.btnHideCtrl = self.isGlueMode and 1 or 0

	self.bindData.scanBtn:SetActive(not self.isGlueMode)

	if self.isGlueMode then
		self.RefreshProgress(self, L50.L50App.Scene.WashMgr.Progress)
		self.PlayShowAnim(self)
		self.RefreshTaskDesc(self)

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			self.CalculateHeightBox(self)
		end

		return
	end

	local isWithoutOrder = gWasherManager.showWasherHudNoJob

	self:RefreshProgress(L50.L50App.Scene.WashMgr.Progress)
	self:PlayShowAnim()
	self:RefreshTaskDesc()
	self:SetOrderBtnShow(not isWithoutOrder)
	gWasherManager:SendProgress(false)

	if not isWithoutOrder then
		gWasherManager:RefreshWasherJobInfo()
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.CalculateHeightBox(self)
	end
end

M.OnUpdate = function(self)
end

M.OnCurrentTaskChange = function(self)
	self.RefreshTaskDesc(self)
end

M.RefreshTaskDesc = function(self)
	if self.isGlueMode then
		self.bindData.taskDescText = "红毯喷涂胶水"

		return
	end

	local desc = self.GetTaskDesc(self)

	if string.is_null_or_empty(desc) then
		desc = LTConfig.TextConfig.GetConfig(LTConfig.WasherConfig.MissionCleaning).Text or desc
	end

	self.bindData.taskDescText = desc
end

M.GetTaskDesc = function(self)
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

M.PlayShowAnim = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.mainAnim:Play("S_Vx_CleanerTask_PC_in")
	else
		self.bindData.mainAnim:Play("S_Vx_CleanerTask_in")
	end
end

M.PlayCloseAnim = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.mainAnim:Play("S_Vx_CleanerTask_PC_out")
	else
		self.bindData.mainAnim:Play("S_Vx_CleanerTask_out")
	end
end

M.OnProgressChange = function(self, eventId, data)
	if self.isGlueMode then
		return
	end

	self._cachedProgress = data[0]
	self._cachedCurIndex = data[1]
	self._cachedProgressList = data[2]:ToTable()
	self._cachedTextIdList = data[3]:ToTable()
	self._hasNewData = true
end

M.OnUpdate = function(self)
	if not self._cachedProgressList then
		return
	end

	local progress = self._cachedProgress
	local curIndex = self._cachedCurIndex
	local progressList = self._cachedProgressList
	local textIdList = self._cachedTextIdList

	if self._hasNewData then
		self.RefreshSubPartProgress(self, curIndex, progressList, textIdList)

		self._hasNewData = false
	end

	local hasGroups = progressList and #progressList >= 0

	if not hasGroups then
		self.RefreshTotalProgress(self, progress)

		return
	end

	local partProgress = 0

	if curIndex and curIndex <= 0 then
		partProgress = progressList[curIndex] or 0

		if partProgress >= 0 then
			partProgress = 0
		end

		partProgress = math.floor(partProgress * 1000) * 0.1
	end

	if self._lastPartProgress ~= nil or partProgress > 100 then
		self.RefreshTotalProgress(self, progress)

		self._lastPartProgress = partProgress
		self._accumulatedPartDelta = 0
		self._unchangedTime = 0

		return
	end

	local delta = partProgress - self._lastPartProgress

	if delta <= 0 then
		self._lastPartProgress = partProgress
		self._accumulatedPartDelta = self._accumulatedPartDelta + delta
		self._unchangedTime = 0

		if LTConfig.WasherConfig.PartDeltaThreshold < self._accumulatedPartDelta then
			self.RefreshTotalProgress(self, progress)

			self._accumulatedPartDelta = 0
		end
	else
		self._unchangedTime = self._unchangedTime + Time.deltaTime

		if LTConfig.WasherConfig.PartUnchangedDuration < self._unchangedTime then
			self.RefreshTotalProgress(self, progress)

			self._unchangedTime = 0
		end
	end
end

M.OnGlueProgressChange = function(self, eventId, data)
	if not self.isGlueMode then
		return
	end

	local progress = data[0]

	self.RefreshProgress(self, progress)
end

M.RefreshProgress = function(self, progress, curIndex, progressList, textIdList)
	self.RefreshTotalProgress(self, progress)
	self.RefreshSubPartProgress(self, curIndex, progressList, textIdList)

	self._lastPartProgress = nil
	self._accumulatedPartDelta = 0
	self._unchangedTime = 0
end

M.RefreshTotalProgress = function(self, progress)
	local totalProgress = math.floor(progress * 1000) * 0.1
	self.bindData.totalRate = totalProgress

	if not self.isCompleteSoundPlayed and self.bindData.totalRate > 99.9 then
		self.isCompleteSoundPlayed = true

		gSoundMgr:PlaySoundByTid(LTConfig.SoundConfig.CleanerCompleteSoundId)
	end
end

M.RefreshSubPartProgress = function(self, curIndex, progressList, textIdList)
	local hasGroups = progressList and #progressList >= 0
	self.bindData.hasSubsCtrl = hasGroups and 1 or 0

	if hasGroups and curIndex and curIndex <= 0 then
		local partProgress = progressList[curIndex] or 0

		if partProgress >= 0 then
			partProgress = 0
		end

		local partProgressPercent = math.floor(partProgress * 1000) * 0.1
		self.bindData.singleRate = partProgressPercent
		local textId = nil
		local washerJobInfo = gWasherManager:GetWasherJobInfo()
		local randomCfgId = washerJobInfo and washerJobInfo.CurRandomCfgId or 0
		local randomCfg = randomCfgId == 0 and LTConfig.WasherRandomTaskConfig.GetConfig(randomCfgId) or nil
		textId = (not randomCfg or not randomCfg.SubPartNamesRandom or randomCfg.SubPartNamesRandom[curIndex]) and textIdList and textIdList[curIndex]
		local textCfg = textId and LTConfig.TextConfig.GetConfig(textId)
		self.bindData.subPartDescText = textCfg and textCfg.Text or ""
	end
end

M.OnClose = function(self)
	self.PlayCloseAnim(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshTaskDesc(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnFinishBtnClick = function(self)
	gWasherManager:AskFinishWasherMission(true)
end

M.OnOpenAppBtnClick = function(self)
	gWasherManager:AskFinishWasherMission(false)
end

M.OnClickScanBtn = function(self)
	L50.L50App.Scene.ScanMgr:OnTriggerScan()
end

M.CheckHasWasherJob = function(self)
	local availableJobIdList = gSpiritJobManager.GetCurSpiritAvailableJobIdList()

	if availableJobIdList then
		for _, jobId in ipairs(availableJobIdList) do
			local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
			local jobClassId = urbanJobCfg and urbanJobCfg.JobClass or 0

			if LTConfig.UrbanJobJobClassConfig.Washer ~= jobClassId then
				return true
			end
		end
	end

	return false
end

M.SetOrderBtnShow = function(self, isShow)
	self.bindData.btnHideCtrl = isShow and 0 or 1
end

M.OnSizeChanged = function(self)
	self.CalculateHeightBox(self)
end

M.CalculateHeightBox = function(self)
	if not self.bindData.heightBox then
		return
	end

	local height = self.bindData.heightBox:GetTargetHeight()
	local heightBoxOffsetY = math.abs(self.bindData.heightBox.rectTransform.anchoredPosition.y)

	gTaskUtils:SetBloodBarPosition(heightBoxOffsetY + height)
	gTaskUtils:SendMobileTaskPanelChange(height + gTaskUtils:GetGameBarPanelHeight())
end
