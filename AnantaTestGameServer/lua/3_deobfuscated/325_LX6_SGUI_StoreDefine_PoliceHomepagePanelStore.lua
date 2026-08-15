local RedDotMgr = SGUI.RedDotMgr
C_PoliceHomepagePanelStore = DefClass("C_PoliceHomepagePanelStore", C_PoliceHomepagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceHomepagePanelStore = C_PoliceHomepagePanelStore
local M = C_PoliceHomepagePanelStore
local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.mgr = gPoliceJobManager.panelMgr
end

function M:OnAwake()
	self.subStore = nil
	self.bindData.takeBtn.luaClick = self:CreateAction("OnFinishWork", self.mgr)
	self.bindData.beginBtn.luaClick = self:CreateAction("OnBeginWork", self.mgr)
	self.bindData.noticeBtn.luaClick = self:CreateActionWithArgs("SwitchCurrentPanel", {
		secondShowType = gClientConst.PoliceShowType.Notice
	}, self.mgr)
end

function M:InitView(data)
	self.mgr:RenderCurrentSpirit(self.bindData.avatar)

	self.bindData.takeBtn.interactable = self.mgr:CheckCanExit()

	self:RefreshTakeWorkBtn()
end

function M:GetMessageEvents()
	return {
		[gEventConstants.SUMMON_STATE_SWITCH] = self:CreateAction(self.RefreshPage),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction(self.OnSystemUnlock),
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction(self.RefreshBtn)
	}
end

function M:OnExecuteExitAction()
	self:ClearMessageEvents()
	self.mgr:CloseCurrentPanel()
end

function M:RefreshPage()
	RedDotMgr.LuaSetRedDot(self.mgr:CheckHasAward(), self.bindData.noticeBtn.redKey)

	local widget = self.bindData.contentScroll.content
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	self.mgr:RenderSummaryTemplate(store.summery, false)
	self.mgr:RenderPoliceLicenseTemplate(store.license)

	self.supportList = self.mgr:GetPoliceDispatchItemList()
	self.preTime = gLogicTime.time

	function store.supportList.onGetTIndex(index)
		local data = self.supportList[index + 1]

		return data.tIndex
	end

	function store.supportList.luaSimpleRenderItem(btn, index)
		local data = self.supportList[index + 1]

		if data then
			self.mgr:RenderSupportItem(btn, data)
		end
	end

	function store.supportList.luaSimpleClick(_, index)
		local data = self.supportList[index + 1]

		if data then
			self.mgr:CallDispatch(data)
		end
	end

	store.supportList:SetSimpleList(#self.supportList)

	store.activity = BOOL2CTL[#self.supportList > 0]
	self.subStore = store

	self:RefreshBtn()
end

function M:RefreshBtn()
	local isPoliceWork = gSpiritJobManager:CheckIsCurrentjob(JobClassConfig.Police)
	self.bindData.showTakeBtn = isPoliceWork and 1 or 0

	if not isPoliceWork then
		local violation = self.mgr:CheckLastViolation()

		if table.isNilOrEmpty(violation) or violation.LeaveDueTime <= gCS.TimeManager.ServerUnixTime then
			self.bindData.beginBtn.interactable = true

			self:StopValidationTimer()
		else
			self.bindData.beginBtn.interactable = false

			self:StartValidationTimer()
			self:RefreshValidationDesc()
		end
	end
end

function M:RefreshValidationDesc()
	local violation = self.mgr:CheckLastViolation()

	if table.isNilOrEmpty(violation) or violation.LeaveDueTime <= gCS.TimeManager.ServerUnixTime then
		self:RefreshBtn()
		self:StopValidationTimer()
	else
		local remainTime = violation.LeaveDueTime - gCS.TimeManager.ServerUnixTime
		local text = gString.Format(LTConfig.PoliceConfig.PoliceHomePageValidation, remainTime)
		self.bindData.validationText = text
		local time = violation.LeaveDueTime - violation.Time

		if time > 0 then
			if self.bindData.validationCountDown then
				self.bindData.validationCountDown.value = remainTime / time
			end
		elseif self.bindData.validationCountDown then
			self.bindData.validationCountDown.value = 1
		end
	end
end

function M:StartValidationTimer()
	self:StopValidationTimer()

	self.validationTimer = coroutine.start(function ()
		while true do
			coroutine.wait(1)
			self:RefreshValidationDesc()
		end
	end)
end

function M:StopValidationTimer()
	if self.validationTimer then
		coroutine.stop(self.validationTimer)

		self.validationTimer = nil
	end
end

function M:ClearData()
	self.supportList = nil

	self:StopValidationTimer()
end

function M:OnSystemUnlock(_, id)
	if id == LTConfig.PoliceConfig.PoliceStartWorkSystemUnlock then
		self:RefreshTakeWorkBtn()
	end
end

function M:RefreshTakeWorkBtn()
	local systemUnlockId = LTConfig.PoliceConfig.PoliceStartWorkSystemUnlock

	if systemUnlockId > 0 then
		self.startWorkUnlock = gSystemUnlockMgr:IsUnlock(systemUnlockId)
	else
		self.startWorkUnlock = true
	end

	self.bindData.takeBtn.gameObject:SetActive(self.startWorkUnlock)
	self.bindData.beginBtn.gameObject:SetActive(self.startWorkUnlock)
end
