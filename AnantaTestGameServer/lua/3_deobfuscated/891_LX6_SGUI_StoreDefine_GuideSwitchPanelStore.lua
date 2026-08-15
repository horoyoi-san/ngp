C_GuideSwitchPanelStore = DefClass("C_GuideSwitchPanelStore", C_GuideSwitchPanelStore, C_StoreGroup)
GroupName2Class.GuideSwitchPanelStore = C_GuideSwitchPanelStore
local M = C_GuideSwitchPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.closeAniName = "S_Vx_GuideSwitchPanel_close"
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	self.bindData.videoPlayer:Init()
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
	self.panelId = panelId

	if data and data.videoId then
		local isLoop = data.isLoop == true

		self.bindData.videoPlayer:PlayVideo(data.videoId, isLoop)
	end
end

function M:OnClose()
	self.bindData.videoPlayer:Stop()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
end

function M:OnCloseBtnClick()
	gUIUtils:PlayAniClosePanel(self.bindData.openAndCloseAnimation, self.closeAniName, gPanelId.S_GUIDE_SWITCH_PANEL)
end
