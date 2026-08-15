local RedDotMgr = SGUI.RedDotMgr
C_PoliceAPPBeginPanelStore = DefClass("C_PoliceAPPBeginPanelStore", C_PoliceAPPBeginPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceAPPBeginPanelStore = C_PoliceAPPBeginPanelStore
local M = C_PoliceAPPBeginPanelStore

function M:ctor()
	self.mgr = gPoliceJobManager.panelMgr
	self.lastUpdateTime = 0
end

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.takeBtn.luaClick = self:CreateAction("OnBeginWork", self.mgr)
	self.bindData.noticeBtn.luaClick = self:CreateActionWithArgs("SwitchCurrentPanel", {
		secondShowType = gClientConst.PoliceShowType.Notice
	}, self.mgr)
end

function M:InitView(data)
	self.mgr:RenderCurrentSpirit(self.bindData.avatar)
end

function M:OnExecuteExitAction()
	self.mgr:CloseCurrentPanel()
end

function M:RefreshPage()
	RedDotMgr.LuaSetRedDot(self.mgr:CheckHasAward(), self.bindData.noticeBtn.redKey)
	self.mgr:RenderSummaryTemplate(self.bindData.summery, true)
	self.mgr:RenderPoliceLicenseTemplate(self.bindData.license)
	self:RefreshNotice()
end

function M:RefreshNotice()
	self.lastUpdateTime = gLogicTime.time
	local violation = self.mgr:CheckLastViolation()

	if table.isNilOrEmpty(violation) or violation.LeaveDueTime <= gCS.TimeManager.ServerUnixTime then
		self.bindData.disable = boolToNumber(false)

		return
	end

	self.bindData.disable = boolToNumber(true)
	self.bindData.disablLabel = self.mgr:GetViolationBeginDesc(violation.LeaveDueTime)
end

function M:OnUpdate()
	if gLogicTime.time - self.lastUpdateTime > 1 then
		self:RefreshNotice()
	end
end
