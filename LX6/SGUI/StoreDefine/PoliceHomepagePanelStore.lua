-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceHomepagePanelStore.lua
-- Decompiled from: 02074_PoliceHomepagePanelStore.lua_9ab0f356a0d4.luajit

C_PoliceHomepagePanelStore = DefClass("C_PoliceHomepagePanelStore", C_PoliceHomepagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceHomepagePanelStore = C_PoliceHomepagePanelStore
local M = C_PoliceHomepagePanelStore
local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.mgr = gPoliceJobManager.panelMgr
	self.DAILY_TASK_STATE = {
		["^\rS~"] = 2,
		["\\xfd\\xfe517\n\\xd6"] = 1,
		["T\rS~"] = 0
	}
end

M.OnAwake = function(self)
	self.subStore = nil
	self.bindData.takeBtn.luaClick = self.CreateAction(self, "OnFinishWork", self.mgr)
	self.bindData.beginBtn.luaClick = self.CreateAction(self, "OnBeginWork", self.mgr)
	self.bindData.noticeBtn.luaClick = self.CreateActionWithArgs(self, "SwitchCurrentPanel", {
		secondShowType = gClientConst.PoliceShowType.Notice
	}, self.mgr)
	self.bindData.dailyTaskScroll.luaInitContent = self.CreateAction(self, self.OnInitContent)
	self.bindData.dailyTaskBtn.luaClick = self.CreateAction(self, "OnGoToDailyTaskHyperLink", self.mgr)
end

M.InitView = function(self, data)
	self.mgr:RenderCurrentSpirit(self.bindData.avatar)

	self.bindData.takeBtn.interactable = self.mgr:CheckCanExit()

	self:RefreshTakeWorkBtn()

	self.showIncidentId = 0

	self:RefreshDailyTask()
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.SUMMON_STATE_SWITCH] = self.CreateAction(self, self.RefreshPage),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self.CreateAction(self, self.OnSystemUnlock),
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, self.RefreshBtn),
		[gEventConstants.POLICE_SWITCH_POLICE_INFO] = self.CreateAction(self, self.RefreshDailyTask)
	}
end

M.OnExecuteExitAction = function(self)
	self:ClearMessageEvents()
	self.mgr:CloseCurrentPanel()
end

M.RefreshPage = function(self)
	self.bindData.noticeBtn.redKey = self.mgr:GetCaseRewardRedDot()
	local widget = self.bindData.contentScroll.content
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	self.mgr:RenderSummaryTemplate(store.summery, false)
	self.mgr:RenderPoliceLicenseTemplate(store.license)

	self.supportList = self.mgr:GetPoliceDispatchItemList()
	self.preTime = gLogicTime.time

	store.supportList.onGetTIndex = function(index)
		local data = self.supportList[index + 1]

		return data.tIndex
	end

	store.supportList.luaSimpleRenderItem = function(btn, index)
		local data = self.supportList[index + 1]

		if data then
			self.mgr:RenderSupportItem(btn, data)
		end
	end

	store.supportList.luaSimpleClick = function(_, index)
		local data = self.supportList[index + 1]

		if data then
			self.mgr:CallDispatch(data)
		end
	end

	store.supportList:SetSimpleList(#self.supportList)

	store.activity = BOOL2CTL[#self.supportList >= 0]
	self.subStore = store

	self:RefreshBtn()
end

M.RefreshBtn = function(self)
	local isPoliceWork = gSpiritJobManager:CheckIsCurrentjob(JobClassConfig.Police)
	self.bindData.showTakeBtn = isPoliceWork and 1 or 0

	if not isPoliceWork then
		local violation = self.mgr:CheckLastViolation()

		if table.isNilOrEmpty(violation) or violation.LeaveDueTime < gCS.TimeManager.ServerUnixTime then
			self.bindData.beginBtn.interactable = true

			self.StopValidationTimer(self)
		else
			self.bindData.beginBtn.interactable = false

			self.StartValidationTimer(self)
			self.RefreshValidationDesc(self)
		end
	end
end

M.RefreshValidationDesc = function(self)
	local violation = self.mgr:CheckLastViolation()

	if table.isNilOrEmpty(violation) or violation.LeaveDueTime < gCS.TimeManager.ServerUnixTime then
		self.RefreshBtn(self)
		self.StopValidationTimer(self)
	else
		local remainTime = violation.LeaveDueTime - gCS.TimeManager.ServerUnixTime
		local text = gString.Format(LTConfig.PoliceConfig.PoliceHomePageValidation, remainTime)
		self.bindData.validationText = text
		local time = violation.LeaveDueTime - violation.Time

		if time <= 0 then
			if self.bindData.validationCountDown then
				self.bindData.validationCountDown.value = remainTime / time
			end
		elseif self.bindData.validationCountDown then
			self.bindData.validationCountDown.value = 1
		end
	end
end

M.StartValidationTimer = function(self)
	self.StopValidationTimer(self)

	self.validationTimer = coroutine.start(function ()
		while true do
			coroutine.wait(1)
			self:RefreshValidationDesc()
		end
	end)
end

M.StopValidationTimer = function(self)
	if self.validationTimer then
		coroutine.stop(self.validationTimer)

		self.validationTimer = nil
	end
end

M.ClearData = function(self)
	self.supportList = nil

	self.StopValidationTimer(self)
end

M.OnSystemUnlock = function(self, _, id)
	if id ~= LTConfig.PoliceConfig.PoliceStartWorkSystemUnlock then
		self.RefreshTakeWorkBtn(self)
	end
end

M.RefreshTakeWorkBtn = function(self)
	local active = false

	if gPoliceJobManager:IsRaidSupportExamine(gRaidDataManager.RaidId) then
		local systemUnlockId = LTConfig.PoliceConfig.PoliceStartWorkSystemUnlock

		if systemUnlockId <= 0 then
			active = gSystemUnlockMgr:IsUnlock(systemUnlockId)
		else
			active = true
		end
	end

	self.bindData.takeBtn.gameObject:SetActive(active)
	self.bindData.beginBtn.gameObject:SetActive(active)
end

M.RefreshDailyTask = function(self)
	if gPoliceJobManager.curIncidentInfo and gPoliceJobManager.curIncidentInfo.Id <= 0 then
		if gPoliceJobManager.curIncidentInfo.hasGetReward then
			self.bindData.dailyTaskCtrl = self.DAILY_TASK_STATE.DONE
		else
			self.bindData.dailyTaskCtrl = self.DAILY_TASK_STATE.DEALING

			if self.showIncidentId == gPoliceJobManager.curIncidentInfo.Id then
				self.showIncidentId = gPoliceJobManager.curIncidentInfo.Id

				self.bindData.dailyTaskScroll:SetContentDirty()
			end
		end
	else
		self.bindData.dailyTaskCtrl = self.DAILY_TASK_STATE.NONE
	end
end

M.OnInitContent = function(self, text)
	local cfg = LTConfig.PoliceIncidentConfig.GetConfig(self.showIncidentId)

	if cfg then
		text.text = cfg.Des
	end
end
