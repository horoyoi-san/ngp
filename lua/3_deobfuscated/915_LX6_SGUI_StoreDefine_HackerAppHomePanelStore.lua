C_HackerAppHomePanelStore = DefClass("C_HackerAppHomePanelStore", C_HackerAppHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.HackerAppHomePanelStore = C_HackerAppHomePanelStore
local M = C_HackerAppHomePanelStore

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.fullScreenButton.luaClick = self:CreateAction("OnExitClick")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_HACKER_APP_CONTENT_CLOSE] = self:CreateAction("CloseContentPanel")
	}
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:OnRenderTab(index, widget)
	if self.panelArgs then
		gClientUtils.InitNavAreasInChildren(widget, self.panelArgs.panelId)
	end

	M.base.OnRenderTab(self, index, widget)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
