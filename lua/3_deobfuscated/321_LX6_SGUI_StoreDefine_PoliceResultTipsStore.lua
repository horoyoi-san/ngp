local PoliceConfig = LTConfig.PoliceConfig
C_PoliceResultTipsStore = DefClass("C_PoliceResultTipsStore", C_PoliceResultTipsStore, C_StoreGroup)
GroupName2Class.PoliceResultTipsStore = C_PoliceResultTipsStore
local M = C_PoliceResultTipsStore

function M:ctor()
	self.timer = nil
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction(self.OpenPanel)
end

function M:OnShow(panelId, data)
	self.bindData.noticeType = data and data.notice or 0
	self.timer = Timer.New(function ()
		self:OnExit()
	end, PoliceConfig.ForceQuitNoticeShowTime):Start()
end

function M:OnClose()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function M:OpenPanel()
	gPoliceJobManager.panelMgr:OpenNoticePanel()
	self:OnExit()
end

function M:OnExit()
	gPanelManager:Close(gPanelId.POLICE_RESULT_TIPS)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
