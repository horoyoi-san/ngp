-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceAPPBeginPanelStore.lua
-- Decompiled from: 02080_PoliceAPPBeginPanelStore.lua_c4e389fe50ee.luajit

C_PoliceAPPBeginPanelStore = DefClass("C_PoliceAPPBeginPanelStore", C_PoliceAPPBeginPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceAPPBeginPanelStore = C_PoliceAPPBeginPanelStore
local M = C_PoliceAPPBeginPanelStore

M.ctor = function(self)
	self.mgr = gPoliceJobManager.panelMgr
	self.lastUpdateTime = 0
end

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.takeBtn.luaClick = self.CreateAction(self, "OnBeginWork", self.mgr)
	self.bindData.noticeBtn.luaClick = self.CreateActionWithArgs(self, "SwitchCurrentPanel", {
		secondShowType = gClientConst.PoliceShowType.Notice
	}, self.mgr)
end

M.InitView = function(self, data)
	self.mgr:RenderCurrentSpirit(self.bindData.avatar)
end

M.OnExecuteExitAction = function(self)
	self.mgr:CloseCurrentPanel()
end

M.RefreshPage = function(self)
	self.mgr:RenderSummaryTemplate(self.bindData.summery, true)
	self.mgr:RenderPoliceLicenseTemplate(self.bindData.license)
	self:RefreshNotice()
end

M.RefreshNotice = function(self)
	self.lastUpdateTime = gLogicTime.time
	local violation = self.mgr:CheckLastViolation()

	if table.isNilOrEmpty(violation) or violation.LeaveDueTime < gCS.TimeManager.ServerUnixTime then
		self.bindData.disable = boolToNumber(false)

		return
	end

	self.bindData.disable = boolToNumber(true)
	self.bindData.disablLabel = self.mgr:GetViolationBeginDesc(violation.LeaveDueTime)
end

M.OnUpdate = function(self)
	if gLogicTime.time - self.lastUpdateTime <= 1 then
		self.RefreshNotice(self)
	end
end
