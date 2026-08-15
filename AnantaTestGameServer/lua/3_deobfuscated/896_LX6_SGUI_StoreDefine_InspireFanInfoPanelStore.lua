C_InspireFanInfoPanelStore = DefClass("C_InspireFanInfoPanelStore", C_InspireFanInfoPanelStore, C_StoreGroup)
GroupName2Class.InspireFanInfoPanelStore = C_InspireFanInfoPanelStore
local M = C_InspireFanInfoPanelStore

function M:OnAwake()
	local function ClosePanel()
		gPanelManager:Close(gPanelId.INSPIRE_FAN_INFO_PANEL)
	end

	self:RegisterSingleEvent(gEventConstants.ON_YANJIE_CONTENT_CLOSE, ClosePanel)

	self.bindData.fullscreenBtn.luaClick = ClosePanel
end

function M:OnShow(panelId, data)
	self.SubGroup.YanjieNewMemberCenterPanel:InitModel()
	self.SubGroup.YanjieNewMemberCenterPanel:InitView()
end

function M:OnDestroy()
	self:ClearMessageEvents()
end
