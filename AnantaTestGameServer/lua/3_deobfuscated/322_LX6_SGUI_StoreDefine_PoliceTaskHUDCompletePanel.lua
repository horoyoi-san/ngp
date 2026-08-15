C_PoliceTaskHUDCompletePanel = DefClass("C_PoliceTaskHUDCompletePanel", C_PoliceTaskHUDCompletePanel, C_StoreGroup)
GroupName2Class.PoliceTaskHUDCompletePanel = C_PoliceTaskHUDCompletePanel
local M = C_PoliceTaskHUDCompletePanel

function M:ctor()
	return
end

function M:OnAwake()
	return
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

function M:OnShow(panelId, data)
	self.areaIndex = data.areaIndex

	Timer.New(self:CreateAction("OnBack"), LTConfig.PoliceConfig.ForceQuitNoticeShowTime):Start()
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

function M:OnBack()
	gPanelManager:Close(self.m_Id)
end
