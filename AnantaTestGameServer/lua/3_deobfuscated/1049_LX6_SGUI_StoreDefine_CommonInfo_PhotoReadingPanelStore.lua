C_PhotoReadingPanelStore = DefClass("C_PhotoReadingPanelStore", C_PhotoReadingPanelStore, C_CommonInfoPanelsBaseStore)
GroupName2Class.PhotoReadingPanelStore = C_PhotoReadingPanelStore
local M = C_PhotoReadingPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.ClosePanel)
end

function M:InitOnShow(data, panelTypeCfg)
	local cfg = LTConfig.InformationConfig.GetConfig(data[1].id)
	self.bindData.title = cfg.Title
	self.bindData.image = cfg.Image
end
