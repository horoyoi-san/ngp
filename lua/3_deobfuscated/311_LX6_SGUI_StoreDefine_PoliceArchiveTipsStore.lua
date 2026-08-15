local PoliceConfig = LTConfig.PoliceConfig
C_PoliceArchiveTipsStore = DefClass("C_PoliceArchiveTipsStore", C_PoliceArchiveTipsStore, C_StoreGroup)
GroupName2Class.PoliceArchiveTipsStore = C_PoliceArchiveTipsStore
local M = C_PoliceArchiveTipsStore

function M:ctor()
	self.timer = nil
	self.mgr = gPoliceJobManager.panelMgr
end

function M:OnAwake()
	self.bindData.arrowBtn.luaClick = self:CreateAction(self.OnArrowClick)
end

function M:OnShow(panelId, data)
	local agentId = data and data.agentId or 0
	local info = self.mgr:GetAgentInfo(agentId)
	self.bindData.headIcon = info.icon
	self.bindData.nameLabel = info.name
	self.timer = Timer.New(function ()
		self:_OnExit()
	end, PoliceConfig.FakeFileTipDisplayTime):Start()
end

function M:OnClose()
	return
end

function M:OnArrowClick()
	gMainPageManager:PoliceArchiveOpenTrigger()
	self:_OnExit()
end

function M:_OnExit()
	gPanelManager:Close(self.m_Id)

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end
