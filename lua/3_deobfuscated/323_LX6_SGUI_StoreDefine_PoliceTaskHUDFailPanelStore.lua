local PoliceConfig = LTConfig.PoliceConfig
C_PoliceTaskHUDFailPanelStore = DefClass("C_PoliceTaskHUDFailPanelStore", C_PoliceTaskHUDFailPanelStore, C_StoreGroup)
GroupName2Class.PoliceTaskHUDFailPanelStore = C_PoliceTaskHUDFailPanelStore
local M = C_PoliceTaskHUDFailPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnBack()
	gPanelManager:Close(self.m_Id)
end

function M:OnShow(panelId, data)
	self.bindData.descLabel = gPoliceJobManager.panelMgr:GetViolationDesc(data.Id)

	Timer.New(self:CreateAction("OnBack"), PoliceConfig.ForceQuitNoticeShowTime):Start()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
