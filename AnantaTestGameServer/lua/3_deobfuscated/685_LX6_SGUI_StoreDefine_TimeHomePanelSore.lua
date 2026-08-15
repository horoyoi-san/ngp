C_TimeHomePanelSore = DefClass("C_TimeHomePanelSore", C_TimeHomePanelSore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.TimeHomePanelSore = C_TimeHomePanelSore
local M = C_TimeHomePanelSore

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.fullScreenButton.luaClick = self:CreateAction("OnExitClick")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_TIME_APP_CONTENT_SHOW] = self:CreateAction("ShowContentPanel"),
		[gEventConstants.ON_TIME_APP_CONTENT_CLOSE] = self:CreateAction("CloseContentPanel")
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

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
