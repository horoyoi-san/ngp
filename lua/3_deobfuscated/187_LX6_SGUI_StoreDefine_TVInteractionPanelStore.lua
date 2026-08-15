C_TVInteractionPanelStore = DefClass("C_TVInteractionPanelStore", C_TVInteractionPanelStore, C_StoreGroup)
GroupName2Class.TVInteractionPanelStore = C_TVInteractionPanelStore
local M = C_TVInteractionPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.closeBtn.luaClick = self:CreateAction("PlayChangeTVState", gHomeInteractionManager)
	self.bindData.openBtn.luaClick = self:CreateAction("PlayChangeTVState", gHomeInteractionManager)
	self.bindData.exitBtn.luaClick = self:CreateAction("PlayExitTV", gHomeInteractionManager)
	self.bindData.tabBtn.luaClick = self:CreateAction("PlayChangeTV", gHomeInteractionManager)
end

function M:OnShow(panelId, data)
	gHomeInteractionManager:RegisterStore(self)
	self:RefreshInteraction()
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

function M:RefreshInteraction()
	self.bindData.inAction = 0
	self.bindData.isOpen = gHomeInteractionManager.tvState and 1 or 0
end
