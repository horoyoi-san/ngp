C_OnlineIngameMissionPanelStore = DefClass("C_OnlineIngameMissionPanelStore", C_OnlineIngameMissionPanelStore, C_StoreGroup)
GroupName2Class.OnlineIngameMissionPanelStore = C_OnlineIngameMissionPanelStore
local M = C_OnlineIngameMissionPanelStore

function M:ctor()
	self.msgEvents = {
		[gEventConstants.LINK_HUD_INFO_CHANGE] = self:CreateAction("OnRefreshInfo")
	}
end

function M:OnAwake()
	self:RegisterMessageEvents(self.msgEvents)

	self.mgr = gLinkManager
end

function M:OnClose()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self:OnRefreshInfo()
end

function M:OnRefreshInfo()
	self.bindData.numLabel = self.mgr.LinkFailureCount
	self.bindData.isWarning = boolToNumber(self.mgr.LinkFailureCount <= 0)
end
